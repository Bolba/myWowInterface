--[[--------------------------------------------------------------------
	Item Tooltip Cleaner
	Removes extraneous lines from item tooltips.
	Copyright (c) 2010-2014 Akkorian, Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/addons/info19129-ItemTooltipCleaner.html
	http://www.curse.com/addons/wow/itemtooltipcleaner
----------------------------------------------------------------------]]

local ADDON_NAME, namespace = ...

local panel = LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(ADDON_NAME, nil, function(self)
	local db = ItemTooltipCleanerSettings
	local L = namespace.L


	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(self, ADDON_NAME, GetAddOnMetadata(ADDON_NAME, "Notes"))


	local colorBonus = LibStub("PhanxConfig-ColorPicker").CreateColorPicker(self, L.BONUS_COLOR)
	colorBonus:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -8)
	function colorBonus:GetValue()
		return unpack(db.bonusColor)
	end
	function colorBonus:Callback(r, g, b)
		db.bonusColor[1] = r
		db.bonusColor[2] = g
		db.bonusColor[3] = b
		wipe(namespace.cache)
	end

	local colorEnchant = LibStub("PhanxConfig-ColorPicker").CreateColorPicker(self, L.ENCHANT_COLOR)
	colorEnchant:SetPoint("TOPLEFT", colorBonus, "BOTTOMLEFT", 0, -8)
	function colorEnchant:GetValue()
		return unpack(db.enchantColor)
	end
	function colorEnchant:Callback(r, g, b)
		db.enchantColor[1] = r
		db.enchantColor[2] = g
		db.enchantColor[3] = b
		wipe(namespace.cache)
	end

	local colorReforge = LibStub("PhanxConfig-ColorPicker").CreateColorPicker(self, L.REFORGE_COLOR)
	colorReforge:SetPoint("TOPLEFT", colorEnchant, "BOTTOMLEFT", 0, -8)
	function colorReforge:GetValue()
		return unpack(db.reforgeColor)
	end
	function colorReforge:Callback(r, g, b)
		db.reforgeColor[1] = r
		db.reforgeColor[2] = g
		db.reforgeColor[3] = b
		wipe(namespace.cache)
	end


	local checks = {}
	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local function OnClick(this, checked)
		db[this.key] = not not checked
		wipe(namespace.cache)
		--print("Wiped cache.")
	end


	local checkBlank = CreateCheckbox(self, L.HIDE_BLANK)
	checkBlank:SetPoint("TOPLEFT", colorReforge, "BOTTOMLEFT", 0, -42)
	checkBlank.Callback = OnClick
	checkBlank.key = "hideBlank"
	tinsert(checks, checkBlank)

	local checkDura = CreateCheckbox(self, L.HIDE_DURABILITY)
	checkDura:SetPoint("TOPLEFT", checkBlank, "BOTTOMLEFT", 0, -42)
	checkDura.Callback = OnClick
	checkDura.key = "hideDurability"
	tinsert(checks, checkDura)

	local checkEquipSets = CreateCheckbox(self, L.HIDE_EQUIPSETS)
	checkEquipSets:SetPoint("TOPLEFT", checkDura, "BOTTOMLEFT", 0, -8)
	function checkEquipSets:Callback(checked)
		if checked then
			SetCVar("dontShowEquipmentSetsOnItems", 1)
		else
			SetCVar("dontShowEquipmentSetsOnItems", 0)
		end
		wipe(namespace.cache)
	end

	local checkILevel = CreateCheckbox(self, L.HIDE_ILEVEL)
	checkILevel:SetPoint("TOPLEFT", checkEquipSets, "BOTTOMLEFT", 0, -8)
	checkILevel.Callback = OnClick
	checkILevel.key = "hideItemLevel"
	tinsert(checks, checkILevel)

	local checkUpgrade = CreateCheckbox(self, L.HIDE_UPGRADE)
	checkUpgrade:SetPoint("TOPLEFT", checkILevel, "BOTTOMLEFT", 0, -8)
	checkUpgrade.Callback = OnClick
	checkUpgrade.key = "hideUpgradeLevel"
	tinsert(checks, checkUpgrade)

	local checkBuy = CreateCheckbox(self, L.HIDE_CLICKBUY)
	checkBuy:SetPoint("TOPLEFT", checkUpgrade, "BOTTOMLEFT", 0, -8)
	checkBuy.Callback = OnClick
	checkBuy.key = "hideRightClickBuy"
	tinsert(checks, checkBuy)

	local checkSocket = CreateCheckbox(self, L.HIDE_CLICKSOCKET)
	checkSocket:SetPoint("TOPLEFT", checkBuy, "BOTTOMLEFT", 0, -8)
	checkSocket.Callback = OnClick
	checkSocket.key = "hideRightClickSocket"
	tinsert(checks, checkSocket)

	local checkValue = CreateCheckbox(self, L.HIDE_VALUE, L.HIDE_VALUE_TIP)
	checkValue:SetPoint("TOPLEFT", checkSocket, "BOTTOMLEFT", 0, -8)
	checkValue.Callback = OnClick
	checkValue.key = "hideSellValue"
	tinsert(checks, checkValue)


	local checkDifficulty = CreateCheckbox(self, format(L.HIDE_DIFFICULTY))
	checkDifficulty:SetPoint("TOPLEFT", notes, "BOTTOM", 0, -8)
	checkDifficulty.Callback = OnClick
	checkDifficulty.key = "hideRaidDifficulty"
	tinsert(checks, checkDifficulty)

	local checkMadeBy = CreateCheckbox(self, format(L.HIDE_TAG, L.MADE_BY))
	checkMadeBy:SetPoint("TOPLEFT", checkDifficulty, "BOTTOMLEFT", 0, -8)
	checkMadeBy.Callback = OnClick
	checkMadeBy.key = "hideMadeBy"
	tinsert(checks, checkMadeBy)

	local checkReforged = CreateCheckbox(self, format(L.HIDE_TAG, REFORGED))
	checkReforged:SetPoint("TOPLEFT", checkMadeBy, "BOTTOMLEFT", 0, -8)
	checkReforged.Callback = OnClick
	checkReforged.key = "hideReforged"
	tinsert(checks, checkReforged)

	local checkSoulbound = CreateCheckbox(self, format(L.HIDE_TAG, ITEM_SOULBOUND))
	checkSoulbound:SetPoint("TOPLEFT", checkReforged, "BOTTOMLEFT", 0, -8)
	checkSoulbound.Callback = OnClick
	checkSoulbound.key = "hideSoulbound"
	tinsert(checks, checkSoulbound)

	local checkUnique = CreateCheckbox(self, format(L.HIDE_TAG, ITEM_UNIQUE))
	checkUnique:SetPoint("TOPLEFT", checkSoulbound, "BOTTOMLEFT", 0, -8)
	checkUnique.Callback = OnClick
	checkUnique.key = "hideUnique"
	tinsert(checks, checkUnique)


	local checkSetBonuses = CreateCheckbox(self, "Hide set bonuses")
	checkSetBonuses:SetPoint("TOPLEFT", checkUnique, "BOTTOMLEFT", 0, -42)
	checkSetBonuses.Callback = OnClick
	checkSetBonuses.key = "hideSetBonuses"
	tinsert(checks, checkSetBonuses)

	local checkSetItems = CreateCheckbox(self, "Hide set item list")
	checkSetItems:SetPoint("TOPLEFT", checkSetBonuses, "BOTTOMLEFT", 0, -8)
	checkSetItems.Callback = OnClick
	checkSetItems.key = "hideSetItems"
	tinsert(checks, checkSetItems)

	local checkReqs, checkReqsMet = CreateCheckbox(self, L.HIDE_REQUIREMENTS, L.HIDE_REQUIREMENTS_TIP)
	checkReqs:SetPoint("TOPLEFT", checkSetItems, "BOTTOMLEFT", 0, -8)
	checkReqs.Callback = OnClick
	checkReqs.key = "hideRequirements"
	tinsert(checks, checkReqs)
	function checkReqs:Callback(checked)
		db.hideRequirements = checked
		checkReqsMet:SetEnabled(checked)
		wipe(namespace.cache)
	end

	checkReqsMet = CreateCheckbox(self, L.HIDE_REQUIREMENTS_MET)
	checkReqsMet:SetPoint("TOPLEFT", checkReqs, "BOTTOMLEFT", 26, -8)
	checkReqsMet.Callback = OnClick
	checkReqsMet.key = "hideRequirementsMetOnly"
	tinsert(checks, checkReqsMet)

	local checkTransmog, checkTransmogLabel = CreateCheckbox(self, L.HIDE_TRANSMOG)
	checkTransmog:SetPoint("TOPLEFT", checkReqsMet, "BOTTOMLEFT", -26, -8)
	checkTransmog.key = "hideTransmog"
	tinsert(checks, checkTransmog)
	function checkTransmog:Callback(checked)
		db.hideTransmog = checked
		checkTransmogLabel:SetEnabled(checked)
		wipe(namespace.cache)
	end

	checkTransmogLabel = CreateCheckbox(self, L.HIDE_TRANSMOG_LABEL, L.HIDE_TRANSMOG_LABEL_TIP)
	checkTransmogLabel:SetPoint("TOPLEFT", checkTransmog, "BOTTOMLEFT", 26, -8)
	checkTransmogLabel.Callback = OnClick
	checkTransmogLabel.key = "hideTransmogLabelOnly"
	tinsert(checks, checkTransmogLabel)


	LibStub("LibAboutPanel").new(ADDON_NAME, ADDON_NAME)


	self.refresh = function(self)
		colorBonus:SetValue(unpack(db.bonusColor))
		colorEnchant:SetValue(unpack(db.enchantColor))
		colorReforge:SetValue(unpack(db.reforgeColor))

		for _, check in pairs(checks) do
			check:SetChecked(db[check.key])
		end

		checkEquipSets:SetChecked(GetCVarBool("dontShowEquipmentSetsOnItems"))

		checkReqsMet:SetEnabled(db.hideRequirements)
		checkTransmogLabel:SetEnabled(db.hideTransmog)
	end
end)

SLASH_ITEMTOOLTIPCLEANER1 = "/itc"
SlashCmdList["ITEMTOOLTIPCLEANER"] = function() InterfaceOptionsFrame_OpenToCategory(panel) end