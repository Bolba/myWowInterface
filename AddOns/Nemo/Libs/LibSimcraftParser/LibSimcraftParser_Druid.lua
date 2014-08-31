local LSP = LibStub:GetLibrary("LibSimcraftParser")
if not LSP then return end

function LSP.GetClassExceptionsFor_DRUID()
  return {
    spells = {
      mangle_bear = "33878",
      mangle_cat = "33876",
      swipe_bear = "779",
      swipe_cat = "62078",
      thrash_bear = "77758",
      thrash_cat = "106830",
      king_of_the_jungle = "102543",
      omen_of_clarity = "135700",
			lunar_eclipse = "48518",
			solar_eclipse = "48517"
    },
    properties = {
      combo_points = 'GetComboPoints("player", "target")',
			eclipse_dir = '(Nemo.GetUnitHasBuffID("player","112071") and 0\nor (Nemo.GetEclipseDirection("sun") and 1 or -1))'
    },
    constraints = {
      ['CriteriaGroup'] = [==[Nemo.AddAction([=[ReadyToCast]=],false,nil,nil,nil,nil,nil,nil,nil,nil,
[=[Nemo.GetSpellCooldownLessThanGCD(select(1,...))
and (Nemo.GetUnitHasBuffName("player", "Clearcasting")
or Nemo.GetPlayerHasEnoughPower(select(1,...)))
--_nemo_criteria_group]=]);]==],

      ['5221'] = function(formatted) -- Shred
        return string.format('Nemo.CriteriaGroupPasses("ReadyToCast",%s)\n--_nemo_autonomous\n--_nemo_icon_criteria', formatted)
      end,
      ['6785'] = function(formatted) -- Ravage
        return string.format('Nemo.CriteriaGroupPasses("ReadyToCast",%s)\n--_nemo_autonomous\n--_nemo_icon_criteria', formatted)
      end,
      ['9005'] = function(formatted) -- Pounce
        return string.format('Nemo.CriteriaGroupPasses("ReadyToCast",%s)\n--_nemo_autonomous\n--_nemo_icon_criteria', formatted)
      end,
    }
  }
end
