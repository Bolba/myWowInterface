--[[--------------------------------------------------------------------
	Item Tooltip Cleaner
	Removes extraneous lines from item tooltips.
	Copyright (c) 2010-2014 Akkorian, Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/addons/info19129-ItemTooltipCleaner.html
	http://www.curse.com/addons/wow/itemtooltipcleaner
----------------------------------------------------------------------]]

local ADDON_NAME, namespace = ...
local L = namespace.L
local db

local defaults = {
	bonusColor = { 0, 1, 0 },
	enchantColor = { 0, 0.8, 1 },
	reforgeColor = { 1, 0.5, 1 },
	hideBlank = true,
	hideItemLevel = true,
	hideMadeBy = true,
	hideReforged = true,
	hideRequirements = true,
	hideRequirementsMet = true,
	hideRightClickBuy = true,
	hideRightClickSocket = true,
	hideTransmog = true,
	hideTransmogLabel = true,
--	hideDurability = false,
--	hideEquipmentSets = true,
--	hideRaidDifficulty = false,
--	hideSellValue = false,
--	hideSetBonuses = false,
--	hideSetItems = false,
--	hideSoulbound = false,
--	hideUnique = false,
--	hideUpgradeLevel = false,
}

namespace.settings = settings

------------------------------------------------------------------------

local format, gsub, ipairs, strmatch, unpack = format, gsub, ipairs, strmatch, unpack

local ITEM_SOCKETABLE  = ITEM_SOCKETABLE
local ITEM_SOULBOUND   = ITEM_SOULBOUND
local ITEM_UNIQUE      = ITEM_UNIQUE
local ITEM_UNIQUE_EQUIPPABLE = ITEM_UNIQUE_EQUIPPABLE
local ITEM_VENDOR_STACK_BUY  = ITEM_VENDOR_STACK_BUY
local REFORGED         = REFORGED

local raidDifficultyLabels = {
	[RAID_FINDER]        = true, -- Raid Finder
	[PLAYER_DIFFICULTY4] = true, -- Flexible
	[ITEM_HEROIC]        = true, -- Heroic
}

local function topattern(str, plain)
	str = gsub(str, "%%%d?$?c", ".+")
	str = gsub(str, "%%%d?$?d", "%%d+")
	str = gsub(str, "%%%d?$?s", ".+")
	str = gsub(str, "([%(%)])", "%%%1")
	return plain and str or ("^" .. str)
end

local S_DURABILITY      = topattern(DURABILITY_TEMPLATE)
local S_ENCHANTED       = topattern(ENCHANTED_TOOLTIP_LINE)
local S_ITEM_LEVEL      = topattern(ITEM_LEVEL)
local S_ITEM_SET_BONUS  = topattern(ITEM_SET_BONUS)
local S_ITEM_SET_BONUS_GRAY = topattern(ITEM_SET_BONUS_GRAY)
local S_ITEM_SET_NAME   = topattern(ITEM_SET_NAME)
local S_MADE_BY         = topattern(ITEM_CREATED_BY)
local S_REFORGED        = "^(.+)" .. topattern(strsub(REFORGE_TOOLTIP_LINE, (strfind(REFORGE_TOOLTIP_LINE, " ?[%(（]"))), true)
local S_REQ_CLASS       = topattern(ITEM_CLASSES_ALLOWED)
local S_REQ_LEVEL       = topattern(ITEM_MIN_LEVEL)
local S_REQ_RACE        = topattern(ITEM_RACES_ALLOWED)
local S_REQ_REPUTATION  = topattern(ITEM_REQ_REPUTATION)
local S_REQ_SKILL       = topattern(ITEM_REQ_SKILL)
local S_TRANSMOGRIFIED  = "^" .. gsub(TRANSMOGRIFIED, "%%s", "(.+)")
local S_UNIQUE_MULTIPLE = topattern(ITEM_UNIQUE_MULTIPLE)
local S_UPGRADE_LEVEL   = topattern(ITEM_UPGRADE_TOOLTIP_FORMAT)

local cache = setmetatable({ }, { __mode = "kv" }) -- weak table to enable garbage collection
namespace.cache = cache -- so it can be wiped when an option changes

local lines = setmetatable({ }, { __index = function(lines, tooltip)
	local lines_tooltip = setmetatable({ name = tooltip:GetName() }, { __index = function(lines_tooltip, line)
		local obj = _G[lines_tooltip.name .. "TextLeft" .. i]
		lines_tooltip[line] = obj
		return obj
	end })
	lines[tooltip] = lines_tooltip
	return lines_tooltip
end })

local inSetList

local function ReformatLine(tooltip, line, text)
	if text == " " and db.hideBlank then
		if tooltip.shownMoneyFrames then
			for j = 1, tooltip.shownMoneyFrames do
				if select(2,_G[tooltip:GetName().."MoneyFrame"..j]:GetPoint("LEFT")) == line then
					return
				end
			end
		end
		-- can't cache this because it breaks the money display
		line:SetText("")
	return end

	if cache[text] then
		-- can't cache blank lines so check that first
		line:SetText(cache[text])
	return end

	if strmatch(text, S_ENCHANTED) then
		-- no cache for colors yet
		line:SetText(strmatch(text, S_ENCHANTED))
		line:SetTextColor(unpack(db.enchantColor))
	return end

	if strmatch(text, S_REFORGED) then
		-- no cache for colors yet
		line:SetTextColor(unpack(db.reforgeColor))
		if db.hideReforged then
			line:SetText(strmatch(text, S_REFORGED))
		end
	return end

	if db.hideTransmog then
		local new = strmatch(text, S_TRANSMOGRIFIED)
		if new then
			--print("Found transmog line:", new)
			if db.hideTransmogLabelOnly then
				cache[text] = new
				return line:SetText(new)
			else
				cache[text] = ""
				return line:SetText("")
			end
		return end
	end

	if inSetList then
		if strmatch(text, "^ .") then -- don't match " "
			--print("Found set item:", text)
			if db.hideSetItems then
				cache[text] = ""
				line:SetText("")
			end
			return
		else
			--print("End of set list:", text)
			inSetList = nil
		end
	elseif strmatch(text, S_ITEM_SET_NAME) then
		--print("Found set name:", text)
		inSetList = true
		return
	end

	if (text == ITEM_SOCKETABLE and db.hideRightClickSocket)
	or (text == ITEM_SOULBOUND and db.hideSoulbound)
	or (text == ITEM_VENDOR_STACK_BUY and db.hideRightClickBuy)
	or (text == REFORGED and db.hideReforged)
	or (db.hideRaidDifficulty and raidDifficultyLabels[text])
	or (db.hideDurability and strmatch(text, S_DURABILITY))
	or (db.hideItemLevel and strmatch(text, S_ITEM_LEVEL))
	or (db.hideMadeBy and strmatch(text, S_MADE_BY))
	or (db.hideUpgradeLevel and strmatch(text, S_UPGRADE_LEVEL))
	or (db.hideUnique and (text == ITEM_UNIQUE or text == ITEM_UNIQUE_EQUIPPABLE or strmatch(text, S_UNIQUE_MULTIPLE)))
	or (db.hideSetBonuses and (strmatch(text, S_ITEM_SET_BONUS) or strmatch(text, S_ITEM_SET_BONUS_GRAY)))
	then
		cache[text] = ""
		line:SetText("")
	return end

	if db.hideRequirements and (
		strmatch(text, S_REQ_CLASS)
		or strmatch(text, S_REQ_RACE)
		or strmatch(text, S_REQ_LEVEL)
		or strmatch(text, S_REQ_REPUTATION)
		or strmatch(text, S_REQ_SKILL)
		or strmatch(text, L.ENCHANT_REQUIRES)
		or strmatch(text, L.SOCKET_REQUIRES)
	) then
		if db.hideRequirementsMet then
			-- hide only if met
			local r, g, b = line:GetTextColor()
			if g > 0.9 and b > 0.9 then
				cache[text] = ""
				line:SetText("")
			end
		else
			cache[text] = ""
			line:SetText("")
		end
	return end

	if strmatch(text, "^%+%d+") then
		-- no cache for colors yet
		local r, g, b = line:GetTextColor()
		if r < 0.1 and g > 0.9 and b < 0.1 then
			line:SetTextColor(unpack(db.bonusColor))
		end
	return end
end

local function ReformatItemTooltip(tooltip)
	local tooltipName = tooltip:GetName()
	for i = 2, tooltip:NumLines() do
		local line = _G[tooltipName .. "TextLeft" .. i]
		local text = line:GetText()
		if text then
			ReformatLine(tooltip, line, text)
		end
	end
	inSetList = nil
	tooltip:Show()
end

------------------------------------------------------------------------

local itemTooltips = {
	-- Default UI
	"GameTooltip",
	"ItemRefTooltip",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
	"ItemRefShoppingTooltip3",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ShoppingTooltip3",
	"WorldMapCompareTooltip1",
	"WorldMapCompareTooltip2",
	"WorldMapCompareTooltip3",
	-- Addons
	"AtlasLootTooltipTEMP",
}

local Loader = CreateFrame("Frame")
Loader:RegisterEvent("ADDON_LOADED")
Loader:SetScript("OnEvent", function(self, event, arg)
	-- Initialize addon settings:
	if arg == ADDON_NAME then
		if not ItemTooltipCleanerSettings then
			ItemTooltipCleanerSettings = {}
		end
		db = ItemTooltipCleanerSettings
		for k, v in pairs(defaults) do
			if type(db[k]) ~= type(v) then
				db[k] = v
			end
		end
	end

	-- Hook tooltips:
	for i, tooltip in pairs(itemTooltips) do
		if _G[tooltip] then
			_G[tooltip]:HookScript("OnTooltipSetItem", ReformatItemTooltip)
			itemTooltips[i] = nil
		end
	end
	if not next(itemTooltips) then
		self:UnregisterEvent(event)
		self:SetScript("OnEvent", nil)
	end
end)

------------------------------------------------------------------------

local showPriceFrames = {
	"AuctionFrame",
	"MerchantFrame",
	"QuestRewardPanel",
	"QuestFrameRewardPanel",
}

local prehook = GameTooltip_OnTooltipAddMoney

function GameTooltip_OnTooltipAddMoney(...)
	if not db.hideSellValue then
		return prehook(...)
	end
	for _, name in pairs(showPriceFrames) do
		local frame = _G[name]
		if frame and frame:IsShown() then
			return prehook(...)
		end
	end
end