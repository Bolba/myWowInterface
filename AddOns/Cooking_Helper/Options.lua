
SlashCmdList["COOKINGHELPER"] = function()
InterfaceOptionsFrame_OpenToCategory("Cooking Helper")
InterfaceOptionsFrame_OpenToCategory("Cooking Helper") -- have to call this twice now due to UI changes in 5.3.0
end

SLASH_COOKINGHELPER1 = "/cookhelp"

local CH_Options = CreateFrame("Frame", "CH_Options", InterfaceOptionsFramePanelContainer)
CH_Options:Hide()
CH_Options.name = "Cooking Helper"
InterfaceOptions_AddCategory(CH_Options)

CH_Options.cancel = 
	function(self)

		MaxRecSlider:SetValue(CH_MaxRecipes)
		_G[MaxRecSlider:GetName() .. "Text"]:SetText(format("%u", CH_MaxRecipes))

		_G["AltsOnCheck"]:SetChecked(CookingHelperAltsOn)
		_G["ShowQuestsCheck"]:SetChecked(CH_ShowQuests)
	end

CH_Options.okay =
	function(self)

		CH_MaxRecipes = MaxRecSlider:GetValue()

		if (ShowQuestsCheck:GetChecked()) then
			CH_ShowQuests = true
		else
			CH_ShowQuests = false
		end

		if (AltsOnCheck:GetChecked()) then
			CookingHelperAltsOn = true
		else
			CookingHelperAltsOn = false
		end
	end

CH_Options.default = 
	function(self)

		CookingHelperAltsOn = true
		AltsOnCheck:SetChecked(true)

		CH_ShowQuests = false
		ShowQuestsCheck:SetChecked(false)

		CH_MaxRecipes = 6
		MaxRecSlider:SetValue(6)
		_G[MaxRecSlider:GetName() .. "Text"]:SetText(format("%u", 6))

		CookingHelperDB = {}
		CH_Known = {}
		local pName = UnitName("player")
		local pRealm = GetRealmName()
		local pIndex = pRealm .. " - " .. pName
		CookingHelperDB[pIndex] = {}
		CookingHelperDB[pIndex]["Realm"] = pRealm
		CookingHelperDB[pIndex]["Name"] = pName
		CookingHelperDB[pIndex]["Cooking"] = 0
	end

local CH_Opt_Title = CH_Options:CreateFontString("CH_OptionsConfigTitle", "ARTWORK", "GameFontNormalLarge")
CH_Opt_Title:SetPoint("TOPLEFT", 16, -16)
CH_Opt_Title:SetText("Cooking Helper Options")

local CH_MaxRec_Title = CH_Options:CreateFontString(nil, "ARTWORK", "GameFontNormal")
CH_MaxRec_Title:SetPoint("TOPLEFT", CH_Options, "TOPLEFT", 16, -60)
CH_MaxRec_Title:SetText("Max number of recipes to show in tootip")

local MaxRecSlider = CreateFrame("Slider", "MaxRecSlider", CH_Options, "OptionsSliderTemplate")
MaxRecSlider:SetWidth(300)
MaxRecSlider:SetPoint("TOPLEFT", CH_Options, "TOPLEFT", 16, -90)
MaxRecSlider:SetMinMaxValues(0,30)
MaxRecSlider:SetOrientation("HORIZONTAL")
MaxRecSlider:SetValueStep(1)
_G[MaxRecSlider:GetName() .. "Low"]:SetText("0")
_G[MaxRecSlider:GetName() .. "High"]:SetText("30")

MaxRecSlider:SetScript("OnValueChanged", function(_, value)
	_G[MaxRecSlider:GetName() .. "Text"]:SetText(format("%u", value))
end)

local AltsOnCheck = CreateFrame("CheckButton", "AltsOnCheck", CH_Options, "OptionsCheckButtonTemplate")
_G[AltsOnCheck:GetName() .. "Text" ]:SetText("  Show Alts")
AltsOnCheck:SetPoint("TOPLEFT", CH_Options, "TOPLEFT", 12, -130)

local ShowQuestsCheck = CreateFrame("CheckButton", "ShowQuestsCheck", CH_Options, "OptionsCheckButtonTemplate")
_G[ShowQuestsCheck:GetName() .. "Text" ]:SetText("  Show Quest Info")
ShowQuestsCheck:SetPoint("TOPLEFT", CH_Options, "TOPLEFT", 12, -170)

