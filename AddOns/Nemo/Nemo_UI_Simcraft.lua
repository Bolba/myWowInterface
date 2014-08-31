local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo", true)

-- Lua APIs
local gsub, gmatch, strlower = string.gsub, string.gmatch, string.lower
local format, strupper, strmatch, strfind = string.format, string.upper, string.match, string.find 
local tonumber, tostring = tonumber, tostring
local tinsert, tconcat = table.insert, table.concat
local select, pairs, ipairs = select, pairs, ipairs

Nemo.D.SimcraftImport 	= {}
local Importer = Nemo.D.SimcraftImport
Importer.compress 	= false
Importer.classProperties = {}
Importer.classConstraints = {}

--********************************************************************************************
-- Locals
--********************************************************************************************
-- Spells that shouldn't be included in a character's default rotation, regardless of class
local function GetIgnoredSpells()
    local interrupts = { 2139, 57994, 1766, 147362, 6652, 116705, 96231, 47528 }
    local ignoredSpells = {}
    for _, id in pairs(interrupts) do
        ignoredSpells[tostring(id)] = true
    end
    ignoredSpells['6603'] = true -- Auto Attack
    ignoredSpells['75'] = true -- Auto Shot
    return ignoredSpells
end
-- Debuffs applied by more than one class
local function GetStandardRaidDebuffs()
    local debuffs = { 113746, 81326, 1490, 115798, 109466, 115804 }
    local isStandard = {}
    for _, id in pairs(debuffs) do
        isStandard[tostring(id)] = true
    end
    return isStandard
end

local function GetClassSpecificInfo(infoType, which, cache, memoize)
  local cached = cache[which]
  -- explicitly test for nil, as 'false' is meaningful for memoization
  if cached == nil or not memoize then 
    if memoize then
      cache[which] = false
    end
    local exceptions = Nemo.LibSimcraftParser['GetClassExceptionsFor_' .. Nemo.D.PClass]
    if exceptions then
      local category = exceptions()[infoType]
      if category then
        local result = category[which]
        if result then
          if memoize then
            cache[which] = result
          end
          return result
        end
      end
    end
  end
  return cached
end
local function GetSpell(spell)
	local result = GetClassSpecificInfo('spells', spell, Nemo.D.SpellInfo, false)
	if tonumber(result) then
		return Nemo.D.SpellInfo[result]
	else
		-- Nemo:doprint('|cffFF0000Attempting|r: GetSpell.GetClassSpecificInfo('..tostring(spell)..')='..tostring(result) )
		return result
	end
end
local function GetClassProperty(property)
  return GetClassSpecificInfo('properties', property, Importer.classProperties, true)
end
local function GetClassConstraint(spell)
  return GetClassSpecificInfo('constraints', spell, Importer.classConstraints, true)
end

local ignoredSpells = GetIgnoredSpells()
local standardDebuffs = GetStandardRaidDebuffs()
Importer.rotationname 	= tostring(math.floor(GetTime())) -- Timestamp; full name to follow

--************************************************************************************************
--Simcraft parser (Best effort :P)
--************************************************************************************************
local Compiler = { currentError = {}, actionCount = 0 }
--
-- The main compile function. It delegates to compilers for specific constructs.
--
function Compiler.Compile(node)
	if not node or type(node) ~= 'table' or not node.name then
		return "Error compiling AST node: " .. tostring(node)
	end
	local command = 'Compile' .. node.name
  -- Nemo:doprint('  Compile command='..command)
	if command then
    -- A bit of cute dynamic language abuse; sometimes compile functions are called directly though
		local result, err = Compiler[command](node)
		if type(err) == 'table' then err = tconcat(err, "\n") end
		return result, err
	else
		return "Error compiling AST node: Unrecognized node type " .. node.name
	end
end
--
-- The "top level" compiler function; "the" APL is the root of the AST.
--
function Compiler.CompileAPL(node)
  local function CategorizeLists(root, nodes)
    local results = { [root] = {} }
    for _, n in ipairs(nodes) do
      local assignedTo = n.specification.to
      if assignedTo.id == root then
        if #assignedTo.subproperties == 0 then
          tinsert(results[root], n)
        elseif assignedTo.subproperties[1] ~= 'precombat' then
          local path = root .. '.' .. tconcat(assignedTo.subproperties, '.')
          results[path] = results[path] or {}
          tinsert(results[path], n)
        end
      end
      -- else not an action
    end
    return results
  end

	local lists = CategorizeLists('actions', node.statements)
  local actions, err = Compiler.CompileList('actions', lists)
  if err then
    return nil, err
  end
	local output = [==[Nemo.AddRotation([=[SC_%s]=],false,nil);
Nemo.D.ImportName=[=[SC_%s]=];
Nemo.D.ImportVersion=%s;
Nemo.D.ImportType="rotation";
%s
%s]==]
	local version = GetAddOnMetadata("Nemo", "Version")
  local spec = GetSpecialization()
  local specName = spec and select(2, GetSpecializationInfo(spec)) or ''
	local name = format('%s_%s', specName, Importer.rotationname)
  local criteriaGroup = GetClassConstraint('CriteriaGroup')
  if not criteriaGroup then
    criteriaGroup = [==[Nemo.AddAction([=[ReadyToCast]=],false,nil,nil,nil,nil,nil,nil,nil,nil,
[=[Nemo.GetSpellCooldownLessThanGCD(select(1,...))
and Nemo.GetPlayerHasEnoughPower(select(1,...))
--_nemo_criteria_group]=]);]==]
  end 
	return format(output, name, name, version, criteriaGroup, actions)
end
function Compiler.GetNameClause(statement)
  local clauses = statement.criteria.specifications
  if clauses.name and clauses.name.from.value then
    return clauses.name.from.value.id
  end
end
--
-- A "statement" is a line in an APL. For practical purposes, this means an
-- action, but it could be expanded to include any information in the input.
--
function Compiler.CompileStatement(node, additionalCriteria, tag)
  local name = node.specification.from.value.id
  local actionType, param1, param2, spell, isTalent
  if name == 'use_item' then
    -- Nemo:doprint('    CompileStatement actionType=use_item' )
    name = Compiler.GetNameClause(node)
    actionType = 'Item'
    param1 = Nemo.GetItemId(name)
    if Nemo:isblank(param1) then -- Unrecognized item; skip it
      Nemo:doprint('|cffFF0000Note|r: CompileStatement Unrecognized item='..tostring(name or '<nil>') )
      return ''
    end
  else
    -- Nemo:doprint('    CompileStatement actionType=Spell' )
    actionType = 'Spell'
    spell = GetSpell(name)
    if not spell or ignoredSpells[tostring(spell.spellid)] then -- Skip action
      Nemo:doprint('|cffFF0000Note|r: CompileStatement skipping spell='..tostring(name or '<nil>'))
      return ''
    end
    name = spell.spellname
    param1 = 'target'
    param2 = '[=[' .. spell.spellid .. ']=]'
    for i=1, GetNumTalents() do
      if name == GetTalentInfo(i) then
        isTalent = true
        break
      end
    end
  end
  Compiler.currentAction = { 
    ['type'] = actionType, id = spell and spell.spellid or param1
  }
  -- Nemo:doprint(format('CompileStatement type: %s id: %s name: %s', actionType, Compiler.currentAction.id, name or '<nil>'))
  local prereqs, err
  if additionalCriteria then
    prereqs, err = Compiler.CompileOperation(additionalCriteria.from)
  end
  if err then
    return '', err
  end
  local actionCriteria, skip = Compiler.Compile(node.criteria)
  if skip then
    return ''
  end
  local criteria = Compiler.AppendCriteria(prereqs or '', actionCriteria)
  if isTalent then
    local enabled = format('Nemo.GetTalentEnabled(%s)', Compiler.ExpandID(spell.spellid))
		if not criteria:find(enabled, 1, true) then
			criteria = Compiler.AppendCriteria(enabled, criteria)
		end
  end
  if tag then
    if #name > 12 then
      name = name:sub(1,12) .. '...' -- Simplistic, but should be adequate
    end
    name = name .. tag
  end
  Compiler.actionCount = Compiler.actionCount + 1
  name = format('%d: %s', Compiler.actionCount, name)
  local dimensions = 'nil,nil,nil,nil'
  if criteria:match('_nemo_autonomous') then
    local x, y, h, w
    local defaultX, defaultY, defaultH, defaultW = 0, 0, 50, 50
    h, w = math.floor((defaultH * 2) / 3), math.floor((defaultW * 2) / 3)
    if criteria:match('_nemo_icon_criteria') then
      x, y = defaultX + defaultW - math.floor(w / 2), defaultY - defaultH + math.floor(h / 2)
    else
      x, y = defaultX + defaultW + 1, defaultY
    end
    dimensions = format('%d,%d,%d,%d', x, y, h, w)
  end
  local output = [==[Nemo.AddAction([=[%s]=],false,[=[%s]=],[=[%s]=],%s,%s,nil,[=[%s]=]);]==]
  return format(output, name, strlower(actionType), tostring(param1), tostring(param2), dimensions, criteria)
end
function Compiler.GenerateTag(criteria, prefix)
  local function Tag(value)
    local pre = prefix or ''
    if value.id == 'cooldown' then pre = pre .. 'cd.' end
    local val = value.subproperties[1] or value.id
    return format(' [%s%s%s]', pre, val:sub(1,10), #val > 10 and '...' or '') 
  end
  if not criteria then return end
  local exp = criteria.from
  if not exp then return end
  if exp.value and exp.value.id then 
    return Tag(exp.value)
  end
  if exp.arg and exp.arg.value and exp.arg.value.id then 
    return Tag(exp.arg.value, '!')
  elseif exp.lhs.value and exp.lhs.value.id then
    return Tag(exp.lhs.value)
  end
end
function Compiler.CompileList(root, list, additionalCriteria, tag)
  local done = {}
  for _, node in ipairs(list[root]) do
    local action = node.specification.from.value.id
    if action == 'run_action_list' or action == 'swap_action_list' then
      local name = Compiler.GetNameClause(node)
      Nemo:doprint('Compiling List ' .. (name or '<default>'))
      if name ~= 'default' then
        local swap
        for path, sublist in pairs(list) do
          swap = path:match('.*%.' .. name .. '$')
          if swap then break end
        end
        if swap then
          done[#done+1] = Compiler.CompileList(swap, list, 
            node.criteria.specifications['if'], name == 'aoe' and ' [aoe]')
        end
      end
    else
      tag = tag or Compiler.GenerateTag(additionalCriteria)
      done[#done+1] = Compiler.CompileStatement(node, additionalCriteria, tag)
    end
  end
  return tconcat(done, '\n')
end
function Compiler.AppendCriteria(criteria, other)
  local additional = other or ''
  if #criteria == 0 then
    return additional
  elseif #additional > 0 then
    return criteria .. "\nand " .. additional
  else
    return criteria
  end
end
--
-- This compiles the clauses that follow an action name, including 'if='
--
function Compiler.CompileCriteria(node)
-- Nemo:doprint('  CompileCriteria node='..tostring(node) )
	local cond = node.specifications
  local Append = Compiler.AppendCriteria
  local ExpandID = Compiler.ExpandID
	-- Handle clauses other than 'if=', and append the standard CD/power check
	local function CompileAdditionalCriteria()
		local criteria = ''
		local action = Compiler.currentAction
		local valid = { ['>'] = true, ['<'] = true, ['>='] = true, ['<='] = true }
		if cond.time then
			local op = valid[cond.time.operator] and cond.time.operator or '>='
			local val = ' ' .. (Compiler.CompileOperation(cond.time.from) or 0)
			criteria = Append(criteria, 'Nemo.GetPlayerCombatTime() ' .. op .. val)
		end
		if cond.time_to_die then
			local op = cond.time_to_die.operator
			op = valid[op] and op or '>='
			local val = ' ' .. (Compiler.CompileOperation(cond.time_to_die.from) or 0)
			criteria = Append(criteria, 'Nemo.GetTargetTimeToDie() ' .. op .. val)
		end
		if cond.line_cd and action and action['type'] == 'Spell' then
			local op = valid[cond.line_cd.operator] and cond.line_cd.operator or '>='
			local val = Compiler.CompileOperation(cond.line_cd.from) or 0
			local func = 'Nemo.GetSpellLastCastedElapsed(' .. ExpandID(action.id) .. ') '
			criteria = Append(criteria, func .. op .. ' ' .. val)
		end
		if cond.health_percentage then
			local op = cond.health_percentage.operator
			op = valid[op] and op or '<='
			local val = Compiler.CompileOperation(cond.health_percentage.from) or 100
			local func = 'Nemo.GetUnitHealthPercent("target") '
			criteria = Append(criteria, func .. op .. ' ' .. val)
		end
		if action and action['type'] == 'Spell' then
      local classCriteria = GetClassConstraint(action.id)
      if classCriteria then
        criteria = Append(criteria, classCriteria(ExpandID(action.id)))
      else
        local cost = select(4, GetSpellInfo(action.id)) or 0
        local cd = GetSpellBaseCooldown(action.id) or 0
        if cost > 0 or cd/1000 > 1.5 then
          local criteriaGroup = format('Nemo.CriteriaGroupPasses("%s", %s)',
            'ReadyToCast', ExpandID(action.id))
          criteria = Append(criteria, criteriaGroup)
        end
      end
		end
		if criteria == '' then
			criteria = 'true'
		end
		return criteria
	end
	local criteria, err = ''
	if (
		cond.bloodlust
		or cond.invulnerable
		or cond.vulnerable
		or cond.moving
		or cond.sync
		or cond.flying
		or cond.haste
		or cond.wait_on_ready
		) then
		return '', "Unsupported action modifier; skipping action"
	elseif cond['if'] then
		criteria, err = Compiler.CompileOperation(cond['if'].from)
		if err then
			return '', err
		end
	end
	return Append(criteria, CompileAdditionalCriteria())
end
--
-- The bulk of the structural work is done here; this function compiles the
-- subexpressions of an assignment or other operation.
--
function Compiler.CompileOperation(node)
  local err = Compiler.currentError
  local function Try(form, ...)
    for _, arg in pairs({...}) do
      if arg == err then
        return err
      end
    end
    return format(form, ...)
  end
  -- A version of Try for "non-fatal" omissions, like &miss_react
  local function TryAny(form, left, right)
    if left ~= err then
      if right ~= err then
        return format(form, left, right)
      else
        return left
      end
    elseif right ~= err then
      return right
    else
      return err
    end
  end
  -- The main recursive expression code generator
  local function Do(exp)
    if exp.value then
      return Try('%s', Compiler.Compile(exp))
    end
    local op = exp.name
    if op == 'Subtract' then
      return Try('(%s - %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Negate' then
      return Try('-(%s)', Do(exp.arg))
    elseif op == 'Add' then
      return Try('(%s + %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Multiply' then
      return Try('(%s * %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Divide' then
      return Try('(%s / %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Less' then
      return Try('(%s < %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Greater' then
      return Try('(%s > %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'LessEq' then
      return Try('(%s <= %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'GreaterEq' then
      return Try('(%s >= %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Equals' then
      return Try('(%s == %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Not' then
      return Try('(not %s)', Do(exp.arg))
    elseif op == 'NotEq' then
      return Try('(%s ~= %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Or' then
      return TryAny('(%s \nor %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'And' then
      return TryAny('(%s \nand %s)', Do(exp.lhs), Do(exp.rhs))
    elseif op == 'Floor' then
      return Try('math.floor(%s)', Do(exp.arg))
    elseif op == 'Ceiling' then
      return Try('math.ceil(%s)', Do(exp.arg))
    elseif op == 'Abs' then
      return Try('math.abs(%s)', Do(exp.arg))
    elseif op == 'In' then
      return Try('string.find(%s, %s, 1, true)', 
                    Do(exp.rhs), Do(exp.lhs)) -- Note side reversal
    elseif op == 'NotIn' then
      return Try('not string.find(%s, %s, 1, true)', 
                    Do(exp.rhs), Do(exp.lhs)) -- Note side reversal
    else
      tinsert(err, "Error compiling expression: " .. op)
      return err
    end
  end
  local expression = Do(node)
  if expression == err then
    local e = tconcat(err, "\n")
    -- Nemo:dprint(e)
    Compiler.currentError = {}
    return nil, e
  else
    return expression
  end
end
--
-- Handles numeric literals
--
function Compiler.CompileValue(node)
  local num = tonumber(node.value)
  if num then
    return num
  end
  return Compiler.Compile(node.value)
end
function Compiler.ExpandID(spell)
  local info = tonumber(spell) and GetSpell(spell) or spell
  return format('"%s" --[[%s]] ', info.spellid, info.spellname)
end
--
-- The hard part :P This handles the translations of all "properties,"
-- the chainable simc literal strings. Any class-specific handling (or 
-- potential second compiler passes) should be done in the respective 
-- class exception file.
-- Note that regexes shouldn't be required for any property translations.
--
function Compiler.CompileProperty(node)
  -- Checks for properties named after Nemo.D.POWER_TYPES
  local function IsPowerType(name)
    local candidate = 'SPELL_POWER_' .. strupper(name)
    for _, pow in pairs(Nemo.D.POWER_TYPES) do
      if candidate == pow or (candidate .. 'S') == pow then
        return true
      end
    end
    return false
  end
  local function GetAuraInfo(spell, filter, simcDesignation)
    if IsHelpfulSpell(spell) or simcDesignation and simcDesignation == 'buff' then
      return 'Buff', 'player', ''
    else
      return 'Debuff', 'target', filter and ',"PLAYER"' or ''
    end
  end

  local ExpandID = Compiler.ExpandID
  local p = node.id
  local action = Compiler.currentAction
  -- ** Properties which refer to the current action **
	if p == 'miss_react' or p == 'cooldown_react' or p == 'cast_delay' or 
		p == 'ptr' or p == 'multiplier' or p == 'time_to_bloodlust' or p == 'swing'
		or p == 'merge_ignite' or p == 'consume_interval' or p == 'enabled'
	then
		return 'true'
	elseif p == 'cast_time' and action then
    return format('Nemo.GetSpellCastTime(%s)', ExpandID(action.id))
  elseif p == 'ticking' and action then
    local info = GetSpell(action.id)
    if info then
      local aura, target, _ = GetAuraInfo(info.spellname)
      local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'baseduration')
      return format('Nemo.GetUnitHas%sID("%s",%s,"PLAYER")', 
        aura, target, ExpandID(spell))
    end
  elseif p == 'active' and action then
		local info = GetSpell(action.id)
		if info then
			return format('Nemo.GetTotemSpellActive(%s)', ExpandID(info))
		end
  elseif p == 'ticks' and action then
    -- Number of times spell has ticked on a unit so far
    local info = GetSpell(action.id)
    if info then
      local name = info.spellname
      local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseticktime')
      local time = spell and spell.baseticktime or info.tooltipticktime or 2
      local remaining = format('Nemo.GetUnitHasMySpellTicksRemaining("target",%s,%.1f)',
        ExpandID(spell or info), time)
      local total = format('Nemo.GetSpellTotalTicksOnUnit(%s,%.1f,"target")', 
        ExpandID(spell or info), time)
      return format('(%s - %s)', total, remaining)
    end
  elseif p == 'ticks_remain' and action then
    local info = GetSpell(action.id)
    if info then
      local name = info.spellname
      local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseticktime')
      local time = spell and spell.baseticktime or info.tooltipticktime or 2
      return format('Nemo.GetUnitHasMySpellTicksRemaining("target",%s,%.1f)', ExpandID(spell or info), time)
    end
  elseif p == 'remains' and action then
    local info = GetSpell(action.id)
    if info then
      local name = info.spellname
      local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
      local isStandard = standardDebuffs[action.id] or spell and standardDebuffs[spell.spellid]
      local aura, target, filter = GetAuraInfo(info.spellname, not isStandard)
      local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
      return format('Nemo.GetUnitHas%sNameTimeleft("%s",%s %s)', aura, target, ExpandID(spell or info), filter)
    end
  elseif p == 'tick_time' and action then
    local info = GetSpell(action.id)
    if info then
      local name = info.spellname
      local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseticktime')
      local time = spell and spell.baseticktime or info.tooltipticktime or 2
      return format('Nemo.GetSpellTickTimeOnUnit(%s,%.1f,"target")', ExpandID(spell or info), time)
    end
  elseif p == 'n_ticks' and action then
    local info = GetSpell(action.id)
    if info then
      local name = info.spellname
      local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseticktime')
      local time = spell and spell.baseticktime or info.tooltipticktime or 2
      return format('Nemo.GetSpellTotalTicksOnUnit(%s,%.1f,"target")', 
      ExpandID(spell or info), time)
    end
  elseif p == 'travel_time' and action then
    return format('Nemo.GetSpellTravelTime(%s)', ExpandID(action.id)) 
  elseif p == 'charges' and action then
    return format('Nemo.GetSpellCharges(%s)', ExpandID(action.id)) 
  elseif p == 'in_flight' and action then
    return format('Nemo.GetSpellLastCastedElapsed(%s) < ' ..
        'Nemo.GetSpellTravelTime(%s)', ExpandID(action.id), ExpandID(action.id))
  elseif p == 'cooldown' then
    if #node.subproperties == 0 and action then
       -- refers to *initial* CD of current action (not remaining CD)
       return format('((GetSpellBaseCooldown(%s) or 0) / 1000)', ExpandID(action.id))
    else
      local name, prop = unpack(node.subproperties)
      local info = GetSpell(name)
      if info and prop == 'remains' then
        return format('Nemo.GetSpellCooldown(%s)', ExpandID(info))
      end
    end
  -- ** Properties which refer to the player **
  elseif p == 'gcd' then
    return 'Nemo.GetPlayerGCD()'
  elseif p == 'level' then
    return 'UnitLevel("player")' -- Should we make a Nemo API wrapper for this?
  elseif p == 'health' then
    return 'Nemo.GetUnitHealthPercent("player")'
  elseif p == 'time' then
    return 'Nemo.GetPlayerCombatTime()'
  elseif IsPowerType(p) or p == 'rune' then
    if #node.subproperties == 0 then
      return format('Nemo.GetUnitPower("player","SPELL_POWER_%s")', strupper(p))
    elseif p == 'rune' then
      local rune = node.subproperties[1]
			local prop = GetClassProperty(rune)
			if prop then return prop end
		else
      local prop = node.subproperties[1]
      if prop == 'pct' then
        return format('Nemo.GetUnitPowerPercent("player","SPELL_POWER_%s")', 
          strupper(p))
      elseif prop == 'max' then
        return format('UnitPowerMax("player","SPELL_POWER_%s")', strupper(p))
      elseif prop == 'deficit' then
        local max = format('UnitPowerMax("player","SPELL_POWER_%s")', strupper(p))
        local now = format('Nemo.GetUnitPower("player","SPELL_POWER_%s")', strupper(p))
        return format('(%s - %s)', max, now)
      elseif prop == 'regen' then
				return 'Nemo.GetPlayerPowerRegen()'
      elseif prop == 'time_to_max' then
				return 'Nemo.GetPlayerTimeToMaxPower()'
      elseif prop == 'cooldown_remains' then
      end
    end
  -- ** Properties which refer to the target **
  elseif p == 'active_enemies' then
    return 'Nemo.GetHurtNPCCount()'
  elseif p == 'target' then
    local prop = node.subproperties[1] or ''
    if prop == 'level' then
      return 'UnitLevel("target")'
    elseif prop == 'health' and node.subproperties[2] == 'pct' then
      return 'Nemo.GetUnitHealthPercent("target")'
    elseif prop == 'health_pct' then
      return 'Nemo.GetUnitHealthPercent("target")'
    elseif prop == 'time_to_die' then
      return 'Nemo.GetTargetTimeToDie()'
    end
  -- ** Properties which refer to spells other than the current action **
  elseif p == 'action' then
    local name, prop = unpack(node.subproperties)
    local info = GetSpell(name)
    if info and prop == 'cast_time' then
      return format('Nemo.GetSpellCastTime(%s)', ExpandID(info))
    elseif info and prop == 'in_flight' then
      return format('Nemo.GetSpellLastCastedElapsed(%s) < ' ..
        'Nemo.GetSpellTravelTime(%s)', ExpandID(info), ExpandID(info))
    elseif info and (prop == 'tick_dmg' or prop == 'tick_damage') then
      -- TODO: Modify Nemo.GetSpellApplied_X to use D.SpellInfo for spell tree
      -- information, instead of requiring it be passed as a param
      local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'schools')
      -- TODO: Add API wrapper for Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh 
      local hasTick = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'baseticktime')
      if spell and hasTick then
        local school, schoolID = next(spell.schools)
        return format('Nemo.GetSpellCurrentBonusDPS(%s, %d, %.1f)',
        ExpandID(spell == hasTick and spell or info), schoolID, hasTick.baseticktime)
      end
    end
	elseif p == 'totem' then 
		local totem, prop = unpack(node.subproperties)
		local slot
		if totem == 'fire' then
			slot = 1
		elseif totem == 'earth' then
			slot = 2
		elseif totem == 'water' then
			slot = 3
		elseif totem == 'air' then
			slot = 4
		end
		if slot then
			if prop == 'active' then
				return format('Nemo.GetTotemSlotActive(%d --[[%s]])', slot, totem)
			end
		end
	elseif p == 'talent' then
		local name, prop = unpack(node.subproperties)
    local info = GetSpell(name)
    if info and prop == 'enabled' then
			return format('Nemo.GetTalentEnabled(%s)', ExpandID(info))
		end
	elseif p == 'glyph' then
		local name, prop = unpack(node.subproperties)
		for i=1, GetNumGlyphs() do
			local glyph,_,_,_,_,link = GetGlyphInfo(i)
			local simcraftName = strlower(string.gsub(glyph:gsub('%s','_'):gsub('-','_'), '[^%w_]', ''))
			if simcraftName == name and prop == 'enabled' then
				local _,_,_,_,_,spell = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
				return format('Nemo.GetPlayerHasGlyphSpellActive("%s")', spell)
			end
		end
	elseif p == 'stat' then
		local prop = unpack(node.subproperties)
    if prop == 'attack_power' then
			return format('Nemo.GetPlayerEffectiveAttackPower()')
		end
	-- ** Buffs and debuffs **
	elseif p == 'buff' or p == 'debuff' or p == 'aura' then
		local name, prop = unpack(node.subproperties)
		if name == 'bloodlust' or name == 'heroism' then
			return 'Nemo.GetUnitHasBuffNameInList("player", "_Bloodlust Buffs")'
		end
		local info = GetSpell(name)
-- Nemo:doprint('name = '..tostring(name)..' info='..tostring(info) )
		if info and prop then
			local isStandard = info and standardDebuffs[tostring(info.spellid)]
			local aura, target, filter = GetAuraInfo(info.spellname, not isStandard, p)
			if prop == 'remains' then
				local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
				return format('Nemo.GetUnitHas%sNameTimeleft("%s",%s %s)', aura, target, ExpandID(spell or info), filter)
			elseif prop == 'cooldown_remains' then
				return format('Nemo.GetSpellCooldown(%s)', ExpandID(info))
			elseif prop == 'up' then
				local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
				return format('Nemo.GetUnitHas%sID("%s",%s %s)', aura, target, ExpandID(spell or info), filter)
			elseif prop == 'down' then
				local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
				return format('not Nemo.GetUnitHas%sID("%s",%s %s)', aura, target, ExpandID(spell or info), filter)
			elseif prop == 'stack' or prop == 'stacks' or prop == 'react' then
				local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
				return format('Nemo.GetUnitHas%sNameStacks("%s",%s %s)', aura, target, ExpandID(spell or info), filter)
			elseif prop == 'value' then
				-- Refers to the amount a buff is changing something; probably not used
			end
		end
	-- ** DoTs **
	elseif p == 'dot' then
		local name, prop = unpack(node.subproperties)
		local info = GetSpell(name)
		if info and prop then
			if prop == 'remains' then
				local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
				return format('Nemo.GetUnitHasDebuffNameTimeleft("target",%s,"PLAYER")', ExpandID(spell or info))
			elseif prop == 'duration' then
				local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'baseduration')
				if spell then
					return format('select(6, UnitDebuff("target", "%s")) --[[duration]]', spell.spellname)
				end
			elseif prop == 'ticking' then
				local spell = Nemo.D.FindSpellByNameAndProperty(name, 'baseduration')
				return format('Nemo.GetUnitHasDebuffName("target",%s,"PLAYER")', ExpandID(spell or info))
			elseif prop == 'ticks_remain' or prop == 'react' then
				local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'baseticktime')
				local time = spell and spell.baseticktime or info.tooltipticktime or 2
				return format('Nemo.GetUnitHasMySpellTicksRemaining("target",%s,%.1f)',
				ExpandID(spell or info), time)
			elseif prop == 'attack_power' then
				return format('Nemo.GetSpellAppliedAttackPower(%s, "target")', ExpandID(info))
			elseif prop == 'spell_power' then
				local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'schools')
				if spell then
					local school, schoolID = next(spell.schools)
					return format('Nemo.GetSpellAppliedBonusDamage(%s, %d, "target")', ExpandID(spell), schoolID)
				end
			elseif prop == 'haste_pct' then
				local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'baseticktime')
				if spell then
					return format('(%.1f / Nemo.GetSpellTickTimeOnUnit(%s, %.1f, "target")', spell.baseticktime, ExpandID(spell), spell.baseticktime)
				end
			elseif prop == 'crit_pct' then
				local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'schools')
				if spell then
					local school, schoolID = next(spell.schools)
					return format('Nemo.GetSpellAppliedCritPercent(%s, %d, "target")', ExpandID(spell), schoolID)
				end
		  elseif prop == 'tick_dmg' or prop == 'tick_damage' then
				local spell = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'schools')
				local hasTick = Nemo.D.FindSpellByNameAndProperty(info.spellname, 'baseticktime')
				if spell and hasTick then
					local school, schoolID = next(spell.schools)
					return format('Nemo.GetSpellAppliedBonusDPS(%s, %d, %.1f, "target")', ExpandID(spell == hasTick and spell or info), schoolID, hasTick.baseticktime)
				end
		  elseif prop == 'crit_dmg' then
			-- TODO: Add Nemo.GetSpellAppliedCritDamageBonus
		  end
		end
	else
		local prop = GetClassProperty(p)
		if prop then return prop end
	end
	-- Any property not explicitly mentioned above will simply be ignored during
	-- expression parsing (as will the expression that includes it, if it was
	-- essential to the meaning of the expression)
	local rest = '.' .. tconcat(node.subproperties, '.')
	Nemo:doprint('Error compiling property: ' .. p .. rest)
	tinsert(Compiler.currentError, 'Error compiling property: ' .. p .. rest)
	return Compiler.currentError
end
--
-- External interface
--
function Nemo.UI.ParseSimcraftRotation(rotation)
	local parsed, err = Nemo.LibSimcraftParser.GetSimcraftAST(rotation)
	if err then
		-- Nemo:dprint(err)
		return '[==[' .. Nemo:Serialize(err) .. ']==]'
	end
	local result, err = Compiler.Compile(parsed.result)
	-- Nemo:dprint(result)
	if err then
		-- Nemo:dprint(err)
		return '[==[' .. Nemo:Serialize(err) .. ']==]'
	end
	return '[==[' .. Nemo:Serialize(result) .. ']==]'
end
