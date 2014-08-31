local LSP = LibStub:GetLibrary("LibSimcraftParser")
if not LSP then return end

function LSP.GetClassExceptionsFor_SHAMAN()
  return {
    spells = {
			strike = '17364',
			stormlash = '120687'
    },
    properties = {
    },
    constraints = {
    }
  }
end
