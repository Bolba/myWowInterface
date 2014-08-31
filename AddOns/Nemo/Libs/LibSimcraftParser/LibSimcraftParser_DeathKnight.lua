local LSP = LibStub:GetLibrary("LibSimcraftParser")
if not LSP then return end

function LSP.GetClassExceptionsFor_DEATHKNIGHT()
  return {
    spells = {
    },
    properties = {
			unholy = 'Nemo.GetUnholyRuneCount()',
			blood = 'Nemo.GetBloodRuneCount()',
			frost = 'Nemo.GetFrostRuneCount()',
			death = 'Nemo.GetDeathRuneCount()'
    },
    constraints = {
      ['43265'] = function(formatted) -- Death and Decay
        return 'Nemo.GetSpellCooldownLessThanGCD("43265")\n--_nemo_autonomous\n--_nemo_icon_criteria'
      end,
    }
  }
end
