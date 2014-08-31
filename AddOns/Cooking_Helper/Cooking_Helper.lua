local prof_idx = 0
local my_level = 0
local CookingWindow = false
local AltDB = {}
local pName = ""
local pRealm = ""
local pIndex = ""
local iLink = nil
local tt_cleared = true
local known_symbol = " |TInterface/Icons/INV_Misc_Food_15:14|t"
local GRAY = "|cff909090"
local GREEN = "|cff40BF40"
local ORANGE = "|cffFF8040"
local RED = "|cffFF0000"
local WHITE = "|cffFFFFFF"
local YELLOW = "|cffFFFF00"
local skillName = ""
local faction = nil


local CookingHelper = CreateFrame("Frame", "CookingHelper", UIParent)

-- Hidden tooltip used to scan for quest info
local CH_QuestTT = CreateFrame("GameTooltip", "CH_QuestTT", UIParent, "GameTooltipTemplate")
CH_QuestTT:Hide()

-- create button for basic campfire
local FBtn = CreateFrame("Button", "FireButton", UIParent, "SecureActionButtonTemplate")
FBtn:SetWidth(32)
FBtn:SetHeight(32)
FBtn:Hide()
local FTxtr = FBtn:CreateTexture()
FTxtr:SetTexture("Interface\\Icons\\Spell_Fire_Fire")
FTxtr:SetAllPoints()
FBtn:SetAttribute("type", "spell")
FBtn:SetAttribute("spell", 818) -- spell 818 is Cooking Fire


local function CookingHelper_SortList(x, y)
	if (x.Cooking == y.Cooking) then
		return (x.Name < y.Name)
	else
		return (x.Cooking > y.Cooking)
	end
end

local function CookingHelper_Init()

	skillName, _, _, _, _, _, _, _, _ = GetSpellInfo(2550)

	if (CookingHelperAltsOn == nil) then
		CookingHelperAltsOn = true
	end

	_G["AltsOnCheck"]:SetChecked(CookingHelperAltsOn)

	if (CH_ShowQuests == nil) then
		CH_ShowQuests = false
	end

	_G["ShowQuestsCheck"]:SetChecked(CH_ShowQuests)

	if (CH_MaxRecipes == nil) then
		CH_MaxRecipes = 6
	end

	MaxRecSlider:SetValue(CH_MaxRecipes)
	_G[MaxRecSlider:GetName() .. "Text"]:SetText(format("%u", CH_MaxRecipes))

	pName = UnitName("player")
	pRealm = GetRealmName()
	pIndex = pRealm .. " - " .. pName

	if (not CookingHelperDB) then -- first time addon used
		CookingHelperDB = {}
	end
	if (not CookingHelperDB[pIndex]) then -- first time character used addon
		CookingHelperDB[pIndex] = {}
		CookingHelperDB[pIndex]["Realm"] = pRealm
		CookingHelperDB[pIndex]["Name"] = pName
		CookingHelperDB[pIndex]["Cooking"] = 0
	end
	for index, character in pairs(CookingHelperDB) do -- copy characters from main DB to local DB (if in current realm)
		if CookingHelperDB[index]["Realm"] then
			if (character["Realm"] == pRealm) then
				if (character["Name"] == pName) then
					my_level = character["Cooking"]
				else
					if (character["Cooking"] > 0) then -- ignore characters with 0 cooking
						tinsert(AltDB, character)
					end
				end
			end
		end
	end

	if (not CH_Known) then -- intitialize Known table
		CH_Known = {}
	end

	if (not CH_Known[pIndex]) then -- intitialize player in Known table
		CH_Known[pIndex] = {}
	end

	table.sort(AltDB, CookingHelper_SortList) -- sort table from highest cooking to lowest, and sort alphabetically if they are the same

end

local function CookingHelper_OnEvent(self, event, arg1, ...)

	if (event == "CHAT_MSG_SKILL") then
		if (strfind(arg1, skillName) ~= nil) then
			_, _, _, _, prof_idx, _ = GetProfessions()
			_, _, my_level, _, _, _ = GetProfessionInfo(prof_idx)
		end

	elseif (event == "TRADE_SKILL_UPDATE") then -- update CH_Known (added in 1.8)
		if (GetTradeSkillLine() == skillName) then
			local cnt = 0
			local newcnt = 0
			for i = 1, GetNumTradeSkills() do
				cnt = cnt + 1
				iLink = GetTradeSkillItemLink(i)
				if (iLink ~= nil) then
					local recNameBeg = strfind(iLink, "|h%[")
					local recNameEnd = strfind(iLink, "|h|r")
					local recName = strsub(iLink, recNameBeg + 3, recNameEnd - 2)
					if (not CH_Known[pIndex][recName]) then
						newcnt = newcnt + 1
						CH_Known[pIndex][recName] = true
					end
				end
			end
		end

	elseif (event == "TRADE_SKILL_SHOW") then
		if (GetTradeSkillLine() == skillName) then -- refresh cooking level for current character
			CookingWindow = true
			_, _, _, _, prof_idx, _ = GetProfessions()
			_, _, my_level, _, _, _ = GetProfessionInfo(prof_idx)
			-- add basic campfire button
			FBtn:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 0, -80)
			FBtn:Show()

		else	-- another trade skill window was opened
			CookingWindow = false
			FBtn:Hide()
		end

	elseif (event == "TRADE_SKILL_CLOSE") then
		FBtn:Hide()
		if (CookingWindow == true) then
			CookingHelperDB[pIndex]["Cooking"] = my_level -- update saved variable when closing skill window
		end

	elseif (event == "ADDON_LOADED") then

		if (arg1 == "Cooking_Helper") then
			CookingHelper_Init()
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then
		faction, _ = UnitFactionGroup("player")
		CookingHelper:UnregisterEvent("PLAYER_ENTERING_WORLD")

	end
end

local function AltCooking(frame, recipe)
	local message = nil
	local altMessage = nil
	local alt_needs = false
	local alt_cooking = 0
	local apIndex = ""

	for index, character in pairs(AltDB) do -- check if there are alts that this is an orange or yellow level for
		if character["Cooking"] then
			apIndex = pRealm .. " - " .. character["Name"]
			alt_cooking = character["Cooking"]
			if ( (recipe["orange"]) and (alt_cooking >= recipe["orange"]) and (alt_cooking < recipe["yellow"]) ) then -- orange level
				alt_needs = true
				altMessage = ORANGE .. character["Name"]

				if ( (CH_Known) and (CH_Known[apIndex]) and (CH_Known[apIndex][recipe_name]) ) then -- recipe is known by alt
					altMessage = altMessage .. known_symbol
				end

				if message then
					message = message .. " " .. altMessage
				else
					message = "   " .. altMessage
				end
			end
			if ( (recipe["yellow"]) and (alt_cooking >= recipe["yellow"]) and (alt_cooking < recipe["green"]) ) then -- yellow level
				alt_needs = true
				altMessage = YELLOW .. character["Name"]

				if ( (CH_Known) and (CH_Known[apIndex]) and (CH_Known[apIndex][recipe_name]) ) then -- recipe is known by alt
					altMessage = altMessage .. known_symbol
				end

				if message then
					message = message .. " " .. altMessage
				else
					message = "   " .. altMessage
				end
			end
		end
	end

	if (alt_needs == false) then -- no player has orange or yellow for this recipe, so list green then red
		for index, character in pairs(AltDB) do -- list green
			if character["Cooking"] then
				apIndex = pRealm .. " - " .. character["Name"]
				alt_cooking = character["Cooking"]
				if ( (recipe["green"]) and (alt_cooking >= recipe["green"]) and (alt_cooking < recipe["gray"]) ) then
					altMessage = GREEN .. character["Name"]

					if ( (CH_Known) and (CH_Known[apIndex]) and (CH_Known[apIndex][recipe_name]) ) then -- recipe is known by alt
						altMessage = altMessage .. known_symbol
					end

					if message then
						message = message .. " " .. altMessage
					else
						message = "   " .. altMessage
					end
				end
			end
		end

		for index, character in pairs(AltDB) do -- list red
			if character["Cooking"] then
				alt_cooking = character["Cooking"]

				if ( (alt_cooking < recipe["gray"]) and (not recipe["green"]) ) then
					altMessage = RED .. character["Name"]
					if message then
						message = message .. " " .. altMessage
					else
						message = "   " .. altMessage
					end

				elseif ( (recipe["green"]) and (alt_cooking < recipe["green"]) and (not recipe["yellow"]) ) then
					altMessage = RED .. character["Name"]
					if message then
						message = message .. " " .. altMessage
					else
						message = "   " .. altMessage
					end

				elseif ( (recipe["yellow"]) and (alt_cooking < recipe["yellow"]) and (not recipe["orange"]) ) then
					altMessage = RED .. character["Name"]
					if message then
						message = message .. " " .. altMessage
					else
						message = "   " .. altMessage
					end

				elseif ( (recipe["orange"]) and (alt_cooking < recipe["orange"]) ) then
					altMessage = RED .. character["Name"]
					if message then
						message = message .. " " .. altMessage
					else
						message = "   " .. altMessage
					end
				end
			end
		end
	end

	if message then
		frame:AddLine(message)
	end
end

local function MyCooking(frame, recipeID, recipe)

	local recipe_str = ""
	local return_str = ""
	local showifKnown = "" 
	recipe_name, _, _, _, _, _, _, _, _ = GetSpellInfo(recipeID)

	if ( (CH_Known) and (CH_Known[pIndex]) and (CH_Known[pIndex][recipe_name]) ) then
		showifKnown = known_symbol
	end

	if my_level >= recipe["gray"] then -- recipe is gray
		recipe_str = GRAY .. skillName .. ": " .. recipe_name .. showifKnown .. "|r"
		frame:AddLine(recipe_str)
		return_str = "gray"

	else
		if not recipe["green"] then -- only level is gray, but can't be learned yet
			return_str = "red"
			frame:AddLine(RED .. skillName .. ": " .. recipe_name .. GRAY .. " (" .. recipe["gray"] .. ")|r")

		else -- green is available

			if my_level >= recipe["green"] then -- green level recipe
				return_str = "green"
				recipe_str = GREEN .. skillName .. ": " .. recipe_name .. showifKnown
				recipe_str = recipe_str .. GRAY .. " (" .. recipe["gray"] .. ")|r"
				frame:AddLine(recipe_str)

			else -- red, orange, or yellow level recipe

				if not recipe["yellow"] then -- green is first level, but can't be learned yet
					return_str = "red"
					frame:AddLine(RED .. skillName .. ": " .. recipe_name .. GREEN .. " (" .. recipe["green"] .. ")" .. GRAY .. " (" .. recipe["gray"] .. ")|r")

				else -- yellow is available

					if my_level >= recipe["yellow"] then -- yellow level recipe
						return_str = "yellow"
						recipe_str = YELLOW .. skillName .. ": " .. recipe_name .. showifKnown
						recipe_str = recipe_str .. GREEN .. " (" .. recipe["green"] .. ")" .. GRAY .. " (" .. recipe["gray"] .. ")|r"
						frame:AddLine(recipe_str)

					else -- red or orange level recipe

						if not recipe["orange"] then -- yellow is first level, but can't be learned yet
							return_str = "red"
							frame:AddLine(RED .. skillName .. ": " .. recipe_name .. YELLOW .. " (" .. recipe["yellow"] .. ")" .. GREEN .. " (" .. recipe["green"] .. ")|r")

						else -- orange is available

							if my_level >= recipe["orange"] then -- orange level recipe
								return_str = "orange"
								recipe_str = ORANGE .. skillName .. ": " .. recipe_name .. showifKnown
								recipe_str = recipe_str .. YELLOW .. " (" .. recipe["yellow"] .. ")" .. GREEN .. " (" .. recipe["green"] .. ")|r"
								frame:AddLine(recipe_str)

							else -- orange is first level, but can't be learned yet
								return_str = "red"
								frame:AddLine(RED .. skillName .. ": " .. recipe_name .. ORANGE .. " (" .. recipe["orange"] .. ")" .. YELLOW .. " (" .. recipe["yellow"] .. ")|r")

							end
						end
					end
				end
			end
		end
	end
	return return_str
end

local function CookingHelper_IsItem(self)
	if (tt_cleared) then
		tt_cleared = false
		local _,link = self:GetItem()
		if link then
			local _, _, _, _, _, _, iSubType, _, _, _ = GetItemInfo(link)

			if iSubType == skillName then

				-- get itemID from link
				local _, _, _, itemID, _, _, _ = string.find(link, "(item:(%d+):(%d+):(%d+):(%d+))")
				local iID = tonumber(itemID)

				-- add recipes to tooltip
				local meat_data = CH_MeatTable[iID]
				if meat_data then

					local recipeCount = 0

					for _ in pairs(meat_data) do recipeCount = recipeCount + 1 end

					if (recipeCount > CH_MaxRecipes) then -- exceeds max recipe count specified in options, so suppress full listing
						self:AddLine(WHITE .. skillName .. ": Used in " .. recipeCount .. " recipe(s)" .."|r")
					else
						for i = 1, recipeCount + 1 do
							local recipeID = meat_data["recipe" .. i]
							local recipe_data = CH_RecipeTable[recipeID]
							if recipe_data then
								local mySkill = MyCooking(self, recipeID, recipe_data)
								if ( (CookingHelperAltsOn == true) and (mySkill ~= "orange") and (mySkill ~= "yellow") ) then
									AltCooking(self, recipe_data)
								end
							end
							i = i + 1
						end
					end

					-- add quest info if available

					local quest = CH_QuestTable[iID]
					if (quest and CH_ShowQuests) then

						for idx, val in pairs(quest) do
							if ( (val["faction"] == faction) or (val["faction"] == "Both") ) then
									local questText = "   "
									CH_QuestTT:SetOwner(UIParent, "ANCHOR_NONE") -- absolutely necessary for this to happen every scan
									CH_QuestTT:SetHyperlink(("quest:%s"):format(tostring(idx)))
									questText = questText .. CH_QuestTTTextLeft1:GetText() .. " (x"
									if (val["qty"]) then
										questText = questText .. val["qty"] .. "   "
									else
										questText = questText .. "?   "
									end
									if (val["lvl"]) then
										questText = questText .. "Lvl " .. val["lvl"] .. ")"
									else
										questText = questText .. "Lvl ?)"
									end
									self:AddLine(questText)
									CH_QuestTT:Hide()
							end
						end
					end

					-- add notes if available
					if ( (CH_NotesTable[iID]) and (CH_NotesTable[iID]["notes"]) ) then
						self:AddLine(WHITE .. CH_NotesTable[iID]["notes"] .."|r")
					end
				else
					-- meat not in table, item ID listed for lookup
					self:AddLine(WHITE .. "Item ID ".. iID .. "|r")
				end
				self:Show()
			end
		end
	end
end

-- register events
CookingHelper:RegisterEvent("ADDON_LOADED")
CookingHelper:RegisterEvent("PLAYER_ENTERING_WORLD")
CookingHelper:RegisterEvent("TRADE_SKILL_SHOW")
CookingHelper:RegisterEvent("TRADE_SKILL_CLOSE")
CookingHelper:RegisterEvent("TRADE_SKILL_UPDATE") -- added in 1.80 for CH_Known DB
CookingHelper:RegisterEvent("CHAT_MSG_SKILL")
CookingHelper:SetScript("OnEvent", CookingHelper_OnEvent)

GameTooltip:HookScript("OnTooltipSetItem", CookingHelper_IsItem)
GameTooltip:HookScript("OnTooltipCleared", function(self) tt_cleared = true end)

ItemRefTooltip:HookScript("OnTooltipSetItem", CookingHelper_IsItem)
ItemRefTooltip:HookScript("OnTooltipCleared", function(self) tt_cleared = true end)
