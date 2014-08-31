local open, exit, date = io.open, os.exit, os.date
local bit = bit or require('bit')

local file, err = open('sc_spell_lists.inc')
if not file then
  print(err)
  exit(1)
end
local contents = file:read('*a')
file:close()

local dump = require('dump')

local classes = { "other", "warrior", "paladin", "hunter", "rogue", "priest",
  "deathknight", "shaman", "mage", "warlock", "monk", "druid" }
local classMasks = {}
for i = 2, #classes do
  classMasks[bit.lshift(1, i - 2)] = classes[i]
end
local races = { "", "human", "orc", "dwarf", "nightelf", "undead", "tauren",
  "gnome", "troll", "goblin", "bloodelf", "draenei",
  "", "", "", "", "", "", "", "", "", "",
  "worgen", "pandaren", "pandaren", "pandaren" }

local function ExtractListData(structs)
  local clean = structs:gsub('#.-\n', '\n') -- Purge C preprocessor directives
    :gsub('^', 'local t = {}\n')
    :gsub('\n[^\n]-__([%w_]+)[^=]*=', '\nt["%1"] =') -- Clean C declarations
    -- From a line like: 37, // Some Ability => ['37'] = 'Some Ability',
    :gsub('(%d+),[ \t]*//[ \t]*([^\n]+)\n', '["%1"] = [=[%2]=],\n') 
    :gsub('//', '--') -- Convert C++ comments to Lua comments
    :gsub('$', '\nreturn t\n')
  return assert(loadstring(clean))()
end

local function ConvertData(simcFormatted)
  local spells = { racial = {}, class = {} }
  local all = {}
  for _, c in pairs(classes) do
    spells.class[c] = {}
  end
  for k, v in pairs(simcFormatted) do
    if k:match('race') then
      for i, r in ipairs(races) do
        if #r > 0 then
          spells.racial[r] = {}
          for _, abilities in pairs(v[i]) do
            for id, name in pairs(abilities) do
              if id ~= 0 and id ~= 1 then -- Faster than type check
                spells.racial[r][id] = { n = name }
              end
            end
          end
        end
      end
    elseif k:match('glyph') then
      -- ignore for now
    else
      for i, c in ipairs(classes) do
        for _, tree in pairs(v[i]) do
          for id, name in pairs(tree) do
            if id ~= 0 and id ~= 1 then -- Faster than type check
              local spell = { n = name }
              spells.class[c][id] = spell
              all[id] = spell
            end
          end
        end
      end
    end
  end
  return spells, all
end

local function AddMinedInfo(categorized, spellList)
  local function DiscardZero(val)
    if not val then return end
    if tostring(val) == '' or tonumber(val) and tonumber(val) == 0 then
      return nil
    end
    return val
  end
  local function IsUseless(struct)
    if bit.band(struct[36][1], 0x40) ~= 0 then return true end -- passive
    local usefulProperties = { 
      [4] = 'speed', [15] = 'cooldown', [18] = 'duration', [21] = 'max_stack', 
      [22] = 'proc_chance', [23] = 'initial_stack', [30] = 'cast_min',
      [31] = 'cast_max', [35] = 'replacement_id' 
    }
    for i = 1, #struct do
      if usefulProperties[i] and DiscardZero(struct[i]) then
        return false
      end
    end
    return true
  end
  local file, err = open('sc_spell_data.inc')
  if not file then
    print(err)
    exit(1)
  end
  local supplement = {}
  local awaitingMode, seekingBrace, parsing = true, false, false
  local i, size, mode
  for line in file:lines() do
    if awaitingMode then
      local prefix, amount = line:match('#define%s+([%w_]+)SIZE%s+(%S+)')
      if amount then
        size = tonumber(amount) or assert(loadstring('return ' .. amount))()
        mode = prefix:gsub('%A', ''):lower()
        if mode ~= 'spell' and mode ~= 'spelleffect' then
          break
        end
        i = 1
        awaitingMode, seekingBrace = false, true
      end
    elseif seekingBrace and line:match('^[^/]+{') then
      seekingBrace, parsing = false, true
    elseif parsing then
      if i <= size then
        local struct = line:match('^%s*(%b{})')
        if struct then
          struct = assert(loadstring('return ' .. struct))()
          if mode == 'spell' then
            local s = struct
            local name, id, school, passive = s[1], tostring(s[2]), s[5], bit.band(s[36][1], 0x40) ~= 0
            local mask, duration, replaces = s[6], DiscardZero(s[18]), DiscardZero(tostring(s[35]))
            if spellList[id] then
              local sid = spellList[id]
              sid.s, sid.d, sid.r = school, duration, replaces
              if passive then
                sid.passive = 1
                spellList[id] = nil -- There's still a reference in categorized though; will delete it later
              end
            elseif not IsUseless(struct) then
              if mask > 0 then
                local matches = {}
                for i, c in pairs(classMasks) do
                  if bit.band(i, mask) ~= 0 then matches[#matches+1] = c end
                end
                local spell = { n = name, s = school, d = duration, r = replaces }
                for _, class in pairs(matches) do
                  categorized.class[class][id] = spell
                  spellList[id] = spell
                end
              else
                local alias = name:gsub('%s','_'):gsub('-','_'):gsub('[^%w_]',''):lower()
                local spell = supplement[alias]
                if spell then
                  spell[#spell+1] = id
                else
                  supplement[alias] = { id }
                end
              end
            end
          elseif mode == 'spelleffect' then
            local id = tostring(struct[3])
            if spellList[id] then
              local spell = spellList[id]
              spell.t = spell.t or DiscardZero(struct[11])
              spell.b = spell.b or DiscardZero(tostring(struct[17]))
            end
          end
          i = i + 1
        end
      else
        parsing, awaitingMode = false, true
      end
    end
  end
  file:close()
  return supplement
end

local function MergeSynonyms(db)
  for _, spells in pairs(db.class) do
    local names = {}
    for id, spell in pairs(spells) do
      if spell.passive then
        spells[id] = nil
      else
        names[spell.n] = names[spell.n] or {}
        table.insert(names[spell.n], id)
      end
    end
    for name, ids in pairs(names) do
      if #ids > 1 then
        local idSet = {}
        for k, v in pairs(ids) do idSet[v] = true end
        local triggerSpells = {}
        for i = 1, #ids do
          local s = spells[ids[i]]
          if s.b and idSet[s.b] then -- Triggers spell of same name
            triggerSpells[#triggerSpells+1] = ids[i]
          end
          s.n = string.format('%s(%d)', s.n, ids[i])
        end
        local seeAlso = {}
        for _, id in pairs(triggerSpells) do
          for i = 1, #ids do
            if ids[i] ~= id then
              local main = spells[id]
              if ids[i] == main.b then
                local aura = spells[ids[i]]
                aura.n = aura.n .. (aura.d and "(Aura)" or "(Effect)")
                aura.u = id
              else
                seeAlso[ids[i]] = true
              end
            end
          end
        end
        if #seeAlso > 0 then
          for id, _ in pairs(seeAlso) do
            if not spells[id].u then
              print('Unhandled spell ambiguity')
              exit(1)
            end
          end
        end
      end
    end
    for _, spell in pairs(spells) do
      if spell.n:match('%(Aura%)$') then
        spell.n = spell.n:gsub('%(Aura%)$', '')
        spell.a = 1
      end
      if spell.n:match('%(Effect%)$') then
        spell.n = spell.n:gsub('%(Effect%)$', '')
        spell.e = 1
      end
      if spell.n:match('%(%d+%)$') then
        spell.n = spell.n:gsub('%(%d+%)$', '')
        spell['?'] = 1
      end
    end
  end
end

local function Librarize(spells, supplement)
  local other = {}
  local lib = {}
  lib[1] = '-- Generated on ' .. date('%Y-%m-%d') .. '\n\n'
  lib[#lib+1] = [=[
local LSP	= LibStub:GetLibrary("LibSimcraftParser")
if not LSP then return end

local SpellInfo = {}
LSP.GetSpellInfoForClass = function(class)
  local choice = string.lower(class:gsub('%A', ''))
  index = SpellInfo['GetClassSpells_' .. choice]
  return index and index()
end
LSP.GetSpellInfoForRace = function(race)
  local choice = string.lower(race:gsub('%A', ''))
  index = SpellInfo['GetRacialSpells_' .. choice]
  return index and index()
end
LSP.GetSupplementalSpellInfo = function(name)
  if not name or name == '' then return end
  local alias = name:gsub('%s','_'):gsub('-','_'):gsub('[^%w_]',''):lower()
  local get = SpellInfo['GetUnknown_' .. alias:sub(1, 1)]
  local spells = get and get()
  if not spells or not spells[alias] then return end
  local result = {}
  for i, id in pairs(spells[alias]) do
    result[i] = id
  end
  return result
end

]=]
  local function Append(data)
    lib[#lib+1] = ' return '
    lib[#lib+1] = dump.tostring(data):gsub('(["%d]),\n', '%1,')
                                     :gsub('},%s*},', '}},')
                                     :gsub('= {\n', '= {')
                                     :gsub('%s=%s', '=')
                                     :gsub('\t', '')
                                     :gsub('n="[^"]*",', '')
    lib[#lib+1] = '\nend\n\n'
  end
  for k, v in pairs(spells) do
    if k == 'class' then
      for class, ids in pairs(v) do
        if class ~= 'other' then
          lib[#lib+1] = 'function SpellInfo.GetClassSpells_' .. class .. '()\n'
          Append(ids)
        end
      end
    elseif k == 'racial' then
      for race, ids in pairs(v) do
        lib[#lib+1] = 'function SpellInfo.GetRacialSpells_' .. race .. '()\n'
        Append(ids)
      end
    end
  end
  local chars = {}
  for i = string.byte('0'), string.byte('z') do
    if i <= string.byte('9') or i >= string.byte('a') then
      chars[string.char(i)] = {}
    end
  end
  for spell, ids in pairs(supplement) do
    local char = spell:sub(1,1)
    chars[char][spell] = ids
  end
  for letter, spells in pairs(chars) do
    lib[#lib+1] = 'function SpellInfo.GetUnknown_' .. letter .. '()\n'
    Append(spells)
  end
  return table.concat(lib)
end

local extracted = ExtractListData(contents)
local spells, flattened = ConvertData(extracted)
local supplement = AddMinedInfo(spells, flattened)
MergeSynonyms(spells)
local lib = Librarize(spells, supplement)
-- dump.tofile(spells, 'LibSimcraftParser_Class_' .. date('%Y%m%d') .. '.lua')
local output, err = open('LibSimcraftParser_Spells_' .. date('%Y%m%d') .. '.lua', 'w')
if not file then
  print(err)
  exit(1)
end
output:write(lib)
output:close()
