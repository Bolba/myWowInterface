local LSP = LibStub:GetLibrary("LibSimcraftParser")
if not LSP then return end

function LSP.GetClassExceptionsFor_ROGUE()
  return {
    spells = {
    },
    properties = {
      combo_points = 'GetComboPoints("player", "target")',
			anticipation_charges = 'Nemo.GetUnitHasBuffNameStacks("player", "115189" --[[Anticipation]])'
    },
		constraints = {
      ['703'] = function(formatted) -- Garrote
				return '(Nemo.GetUnitHasBuffName("player", "1784" --[[Stealth]])\nor Nemo.GetUnitHasBuffName("player", "51713" --[[Shadow Dance]]))'
      end,
      ['14183'] = function(formatted) -- Premeditation
				return '(Nemo.GetUnitHasBuffName("player", "1784" --[[Stealth]])\nor Nemo.GetUnitHasBuffName("player", "51713" --[[Shadow Dance]]))'
      end,
      ['1833'] = function(formatted) -- Cheap Shot
				return '(Nemo.GetUnitHasBuffName("player", "1784" --[[Stealth]])\nor Nemo.GetUnitHasBuffName("player", "51713" --[[Shadow Dance]]))'
      end,
      ['8676'] = function(formatted) -- Ambush
				return '(Nemo.GetUnitHasBuffName("player", "1784" --[[Stealth]])\nor Nemo.GetUnitHasBuffName("player", "51713" --[[Shadow Dance]]))\n--_nemo_autonomous\n--_nemo_icon_criteria'
      end,
      ['53'] = function(formatted) -- Backstab
				return string.format('Nemo.GetUnitHasDebuffNameTimeleft("target", "89775" --[[Hemorrhage]], "PLAYER") > 3\nand not (Nemo.GetUnitHasBuffName("player", "1784" --[[Stealth]])\nor Nemo.GetUnitHasBuffName("player", "51713" --[[Shadow Dance]])) \nand Nemo.CriteriaGroupPasses("ReadyToCast",%s)\n--_nemo_autonomous\n--_nemo_icon_criteria', formatted)
      end,
      ['1856'] = function(formatted) -- Vanish
				return string.format('Nemo.GetPlayerCombatTime() > 10\nand Nemo.GetUnitThreatSituation("player", "target") < 2\nand Nemo.CriteriaGroupPasses("ReadyToCast",%s)', formatted)
      end,
		}
  }
end
