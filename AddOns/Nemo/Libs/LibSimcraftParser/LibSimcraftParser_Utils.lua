--********************************************************************************************
-- Locals
--********************************************************************************************
local LSP 		= LibStub:GetLibrary("LibSimcraftParser")

--********************************************************************************************
-- Functions
--********************************************************************************************
function LSP.GetSchoolsFromMask(mask)
  local masks = { physical = 0x1, holy = 0x2, fire = 0x4, nature = 0x8,
    frost = 0x10, shadow = 0x20, arcane = 0x40 }
  local trees = { 'physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane' }
  local schools = {}
  for id, name in ipairs(trees) do
    if bit.band(mask, masks[name]) ~= 0 then
      schools[name] = id
    end
  end
  return next(schools) and schools or nil
end

function LSP.ToSec(ms)
  return tonumber(string.format('%.1f', ms / 1000))
end

function LSP.Decompress(spell)
  local pretty = {}
  for k, v in pairs(spell) do -- Looping lets us avoid testing for absent properties
    if k == '?' then
      pretty.hasAmbiguousName = true
    elseif k == 'd' then
      pretty.duration = LSP.ToSec(v)
    elseif k == 'a' then
      pretty.isAura = true
    elseif k == 'u' then
      pretty.triggeredBy = v
    elseif k == 'b' then
      pretty.triggersSpell = v
    elseif k == 't' then
      pretty.tickTime = LSP.ToSec(v)
      pretty.valueAttribute = v
    elseif k == 's' then
      pretty.spellSchools = LSP.GetSchoolsFromMask(v)
    elseif k == 'e' then
      pretty.isEffect = true
    elseif k == 'r' then
      pretty.replacesSpell = v
    else
      pretty[k] = v
    end
  end
  return pretty
end
function LSP.IsBlank(value)
	if ( value == nil ) then return true end
	if ( value == "" ) then return true end
	return false
end
