local LSP = LibStub:GetLibrary("LibSimcraftParser")
if not LSP then return end

function LSP.GetClassExceptionsFor_HUNTER()
  return {
    spells = {
			beast_within = '34471'
    },
    properties = {
    },
    constraints = {
      ['1978'] = function(formatted) -- Serpent Sting
				return string.format('not Nemo.GetSpellLastCasted(%s)', formatted)
      end,
      ['53351'] = function(formatted) -- Kill Shot
				return string.format('Nemo.GetUnitHealthPercent("target") <= 20 and Nemo.CriteriaGroupPasses("ReadyToCast",%s)', formatted)
      end,
      ['82692'] = function(formatted) -- Focus Fire
        return 'Nemo.GetUnitHasBuffNameStacks("player", "19615" --[[Frenzy]]) >= 5'
      end,
			['34026'] = function(formatted) -- Kill Command
				return string.format([=[
if Nemo.CriteriaGroupPasses("ReadyToCast",%s) then 
  for i=1,NUM_PET_ACTION_SLOTS do 
    local name,_,_,standard = GetPetActionInfo(i)
    if name and not standard then 
      if GetPetActionSlotUsable(i) then
				return true
			end
    end
  end
end
return false
--_nemo_enable_lua]=], formatted)
			end,
    }
  }
end
