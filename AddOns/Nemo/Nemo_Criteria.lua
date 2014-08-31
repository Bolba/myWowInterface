local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--********************************************************************************************
-- Locals
--********************************************************************************************
local strsub, strsplit, strlower, strmatch, strtrim, strfind = string.sub, string.split, string.lower, string.match, string.trim, string.find
local format, tonumber, tostring = string.format, tonumber, tostring
local tsort, tinsert = table.sort, table.insert
local select, pairs, next, type = select, pairs, next, type
local error, assert = error, assert

-- WoW API
local _G = _G
local IsCurrentAction = IsCurrentAction
local IsSpellInRange = IsSpellInRange
local GetGlyphSocketInfo = GetGlyphSocketInfo
local GetNumGlyphSockets = GetNumGlyphSockets
local GetSpellInfo = GetSpellInfo
local GetSpellLink = GetSpellLink
local GetTime = GetTime
local UnitExists = UnitExists
local UnitGUID   = UnitGUID
local UnitHealth = UnitHealth

--********************************************************************************************
-- Creat root tree tables
--********************************************************************************************
local PLAYER_CRITERIA	=1
local PET_CRITERIA		=2
local UNIT_CRITERIA		=3
local ITEM_CRITERIA		=4
local SPELL_CRITERIA	=5
local CLASS_CRITERIA	=6
local TALENTS_CRITERIA	=7
local MISC_CRITERIA		=8
local GROUP_CRITERIA	=9
Nemo.D.criteria   		={}
Nemo.D.criteriatree		={}
Nemo.D.criteriatree[PLAYER_CRITERIA]={ value='return "d/player"', text=L["d/player"], icon="Interface\\Icons\\Achievement_Character_Human_Female", children = {} }
Nemo.D.criteriatree[PET_CRITERIA]={ value='return "d/pet"', text=L["d/pet"], icon="Interface\\Icons\\INV_Box_PetCarrier_01", children = {} }
Nemo.D.criteriatree[UNIT_CRITERIA]={ value='return "d/unit"', text=L["d/unit"],icon="Interface\\Worldmap\\SkullGear_64Grey", children = {} }
Nemo.D.criteriatree[ITEM_CRITERIA]={ value='return "d/item"', text=L["d/item"],icon="Interface\\PaperDollInfoFrame\\UI-GearManager-ItemIntoBag", children = {} }
Nemo.D.criteriatree[SPELL_CRITERIA]={ value='return "d/spell"', text=L["d/spell"],icon="Interface\\SPELLBOOK\\Spellbook-Icon", children = {} }
Nemo.D.criteriatree[CLASS_CRITERIA]={ value='return "d/class"', text=L["d/class"],icon="Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES",iconCoords=CLASS_ICON_TCOORDS[ select(2,UnitClass("player")) ], children = {} }
Nemo.D.criteriatree[TALENTS_CRITERIA]={ value='return "d/talents"', text=L["d/talents"],icon="Interface\\BUTTONS\\UI-MicroButton-Talents-Up", children = {} }
Nemo.D.criteriatree[MISC_CRITERIA]={ value='return "d/misc"', text=L["d/misc"],icon="Interface\\TARGETINGFRAME\\PortraitQuestBadge", children = {}	}
Nemo.D.criteriatree[GROUP_CRITERIA]={ value='return "d/group"', text=L["d/group"],icon="Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon", children = {}	}
--********************************************************************************************
--UTILITY FUNCTIONS
--********************************************************************************************
if true then
Nemo.GetActionFrame=function( action )
	local NemoSABFrame    	= nil
	-- Get the secure action frame from the action parameter
	if ( action and action._nemo_action_text ) then
		NemoSABFrame = action
	elseif ( Nemo.DB.profile.options.srk and not Nemo:isblank(action) ) then
		local lAKey = Nemo:SearchTable(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children, "text", action)
		if ( lAKey
			and Nemo.AButtons.Frames[Nemo.DB.profile.options.sr]
			and Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][lAKey]
			) then
			NemoSABFrame = Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][lAKey]
		end
	end
	return NemoSABFrame
end
Nemo.GetAutoAttackActionSlot=function()
	for i = 1,72 do
		if ( IsAttackAction(i) ) then
		return i
		end
	end
	return nil
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.AppendCriteriaDebug=function( text )
	if ( Nemo.UI.sgMain and Nemo.UI.sgMain.tgMain.sgPanel.cbInfo and Nemo.UI.sgMain.tgMain.sgPanel.cbInfo:GetValue() == true and Nemo.D.CriteriaSABFrame ) then
		Nemo.D.CriteriaSABFrame._nemo_criteria_result = tostring(Nemo.D.CriteriaSABFrame._nemo_criteria_result).."\n"..format(" |cffF95C25[|r%.3f ms|cffF95C25]|r", Nemo.D.GetDebugTimerElapsed() )..tostring(text)
	end
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetHastedTime=function(unhastedTime)
	return unhastedTime / (1 + UnitSpellHaste("player") / 100)
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetItemId=function(item)
	if (Nemo:isblank(item)) then
		return nil
	end
	local _,_,itemID = strfind(item or '', "item:(%d+):")
	if (not Nemo:isblank(itemID)) then
		return itemID
	end
	local s1,s2,iS,s3 = strfind(item or "", "%[(.*)%]")
	_,_,itemID = strfind( select(2,GetItemInfo( iS or item )) or '', "item:(%d+):" )
	if (not Nemo:isblank(itemID)) then
		return itemID
	end
	return nil
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitItemInventoryId=function(unit, slot)
    local itemID, nSlot = nil
    if ( Nemo:IsNumeric(slot) ) then
        nSlot = slot
    else
        nSlot = GetInventorySlotInfo(slot)
    end
    itemID = GetInventoryItemID(unit, nSlot)
    if ( itemID and not GetInventoryItemBroken(unit, nSlot) ) then
        return itemID
    end
    return nil
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetItemName=function(item)
	return GetItemInfo( Nemo.GetItemId(item) or "") or item
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellID=function(spell)
	local sSpell = tostring(spell)
	if ( not Nemo.D.SpellInfo[sSpell] ) then
		local spellLink = GetSpellLink( sSpell or 0 )
		local spellID = strmatch(tostring(spellLink) or '', "spell:(%d+)");
		if ( spellID ) then return spellID end
			-- if ( not Nemo.D.SpellInfo[tostring(spellID)] ) then
				-- Nemo.D.SpellInfo[tostring(spellID)] = {}
				-- Nemo.D.SpellInfo[tostring(spellID)].spellid = tostring(spellID)
				-- if ( GetSpellInfo(spellID) ) then
					-- Nemo.D.SpellInfo[tostring(spellID)].spellname = GetSpellInfo(spellID)
					-- Nemo.D.SpellInfo[GetSpellInfo(spellID)] = Nemo.D.SpellInfo[tostring(spellID)] 	-- Point the textname key to the string spellid key for easy lookup
					-- Nemo.D.SpellInfo['['..GetSpellInfo(spellID)..']'] = Nemo.D.SpellInfo[tostring(spellID)] -- Point the deserialized link textname key to the string spellid key for easy lookup
				-- end
				-- if ( GetSpellLink(spellID) ) then
					-- Nemo.D.SpellInfo[GetSpellLink(spellID)] = Nemo.D.SpellInfo[tostring(spellID)] 	-- Point the link key to the string spellid key for easy lookup
				-- end
			-- end
			-- return Nemo.D.SpellInfo[tostring(spellID)].spellid
		-- end
		return nil
	else
		return Nemo.D.SpellInfo[sSpell].spellid
	end
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellName=function(spell)
	local sSpell = tostring(spell)
	if ( not Nemo.D.SpellInfo[sSpell] ) then
		return GetSpellInfo( Nemo.GetSpellID(sSpell) or 0 ) or spell or ''
	else
		return Nemo.D.SpellInfo[sSpell].spellname
	end
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerSpellCritChance=function(spellschool)
	local sSchool = spellschool or 6
	local minCrit = GetSpellCritChance(sSchool)
	local lCritChance
	for i=(sSchool+1), 7 do
		lCritChance = GetSpellCritChance(i)
		minCrit = min(minCrit, lCritChance)
	end
	return minCrit
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.SetActionDisabled=function(action)
	if ( Nemo.DB.profile.options.srk and not Nemo:isblank(action) ) then
		local lAKey = Nemo:SearchTable(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children, "text", action)
		if ( lAKey and Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lAKey].dis ~= true ) then
			Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lAKey].dis = true
			if ( Nemo.UI.sgMain and Nemo.UI.STL and Nemo.UI.STL[3]) then
				Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].value)
			end
			_G[Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][lAKey].fn.."Icon"]:SetVertexColor(.8, .1, .1)	-- Set the icon tint to red
		end
	end
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.SetActionEnabled=function(action)
	if ( Nemo.DB.profile.options.srk and not Nemo:isblank(action) ) then
		local lAKey = Nemo:SearchTable(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children, "text", action)
		if ( lAKey and Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lAKey].dis ~= false ) then
			Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lAKey].dis = false
			if ( Nemo.UI.sgMain and Nemo.UI.STL and Nemo.UI.STL[3]) then
				Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].value)
			end
			_G[Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][lAKey].fn.."Icon"]:SetVertexColor(1, 1, 1)	-- Set the icon tint to white
		end
	end
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.ToggleActionDisabled=function(action)
	if ( Nemo.DB.profile.options.srk and not Nemo:isblank(action) ) then

		local lAKey = Nemo:SearchTable(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children, "text", action)

		if ( lAKey and Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lAKey].dis == true ) then
			Nemo.SetActionEnabled(action)
		elseif ( lAKey ) then
			Nemo.SetActionDisabled(action)
		end
	end
end
end

--********************************************************************************************
--PLAYER CRITERIA
--********************************************************************************************
if true then
Nemo.GetPlayerCombatTime=function()
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	if ( Nemo.D.P.EnteredCombatTime and Nemo.D.P.EnteredCombatTime > 0) then
		lReturn = (GetTime() - Nemo.D.P.EnteredCombatTime)
	end
	Nemo.AppendCriteriaDebug( 'GetPlayerCombatTime()='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/player/GetPlayerCombatTime"]={
	a=2,
	a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
	a2l=L["d/common/seconds/l"],a2dv="60",a2tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetPlayerCombatTime()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerCombatTime")', text=L["d/player/GetPlayerCombatTime"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerDamageTaken=function(seconds)
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	local lCurrentTime = GetTime()
    for k, v in pairs(Nemo.D.P["DAMAGE_TAKEN"]) do
        if ( v and v["timestamp"] ) then
            if ( (lCurrentTime - v["timestamp"]) <= seconds ) then
				lReturn = lReturn + (v["amount"] or 0)
			end
        end
    end
	Nemo.AppendCriteriaDebug( 'GetPlayerDamageTaken(seconds='..tostring(seconds)..')='..tostring(lReturn)..' hits['..#(Nemo.D.P["DAMAGE_TAKEN"])..']'  )
	return lReturn
end
Nemo.D.criteria["d/player/GetPlayerDamageTaken"]={
	a=3,
	a1l=L["d/common/seconds/l"],a1dv="5",a1tt=L["d/common/seconds/tt"],
	a2l=L["d/common/co/l"],a2dv=">",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="100000",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetPlayerDamageTaken(%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerDamageTaken")', text=L["d/player/GetPlayerDamageTaken"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerEffectiveAttackPower=function()
	local base, posBuff, negBuff = UnitAttackPower("player");
	local effective = base + posBuff + negBuff;
	return effective
end
Nemo.D.criteria["d/player/GetPlayerEffectiveAttackPower"]={
	a=2,
	a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
	a2l=L["d/common/count/l"],a2dv="6000",a2tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetPlayerEffectiveAttackPower()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerEffectiveAttackPower")', text=L["d/player/GetPlayerEffectiveAttackPower"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerGCD=function()
	Nemo.D.ResetDebugTimer()
	local GCD = Nemo.GetSpellCooldown(L[Nemo.D.PClass..'_GCD_SPELL'])
	Nemo.AppendCriteriaDebug( 'GetPlayerGCD()='..tostring(GCD) )
	return GCD
end
Nemo.D.criteria["d/player/GetPlayerGCD"]={
	a=2,
	a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
	a2l=L["d/common/seconds/l"],a2dv="60",a2tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetPlayerGCD()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerGCD")', text=L["d/player/GetPlayerGCD"] } )

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerHasAutoAttackOn=function()
	local ma = Nemo.GetAutoAttackActionSlot()
	if ma then
		if not IsCurrentAction(ma) then
			return false
		else
			return true
		end
	else
		return nil
	end
end
Nemo.D.criteria["d/player/GetPlayerHasAutoAttackOn"]={
	a=0,
	f=function () return format('Nemo.GetPlayerHasAutoAttackOn()==true') end
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerHasAutoAttackOn")', text=L["d/player/GetPlayerHasAutoAttackOn"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerHasEnoughPower=function(...)
	Nemo.D.ResetDebugTimer()
	local lnPowerType
	local lsPowerType
	local lRequiredPower
	local lSpell
	local lWait
	local bPowerLevelPasses = true
	if ( not select(2,...) ) then -- Only one arg so arg1 == spellid
		lSpell = select(1,...)
		_,_,_,lRequiredPower,_,lnPowerType,_,_,_ = GetSpellInfo( Nemo.GetSpellID(lSpell) )
		lRequiredPower	= Nemo:NilToNumeric(lRequiredPower,0)
		if ( lnPowerType ) then
			lsPowerType = Nemo.D.POWER_TYPES[lnPowerType]
		else
			lnPowerType	= UnitPowerType("player")
			lsPowerType	= "SPELL_POWER_"..select(2, UnitPowerType("player"))
		end
		lWait 			= 0
	elseif( select(3,...) ) then -- We have at least 3 args so arg3 = spellid
		lRequiredPower	= Nemo:NilToNumeric(select(2,...),0)
		lSpell 			= select(3,...)
		_,_,_,lRequiredPower,_,lnPowerType,_,_,_ = GetSpellInfo( Nemo.GetSpellID(lSpell) )
		if ( Nemo:NilToNumeric(select(2,...),0) > 0 ) then
			lRequiredPower = Nemo:NilToNumeric(select(2,...),0)	-- Override required power if it is set in parameter 2
		else
			lRequiredPower = Nemo:NilToNumeric(lRequiredPower,0) -- Else use the GetSpellInfo result
		end
		if ( lnPowerType ) then
			lsPowerType = Nemo.D.POWER_TYPES[lnPowerType]
		else
			lnPowerType = UnitPowerType("player")
			lsPowerType	= select(1,...) or "SPELL_POWER_"..select(2, UnitPowerType("player"))
		end
		lRequiredPower	= Nemo:NilToNumeric(lRequiredPower,0)
		lWait 			= Nemo:NilToNumeric(select(4,...),0)
	end

	local lCurrentPower = UnitPower("player", lnPowerType) or 0
	local lPowerInWaitSeconds = lCurrentPower
	if ( Nemo.D.P[lsPowerType] and Nemo.D.P[lsPowerType].pgr ) then
		local lPowerGainedPerSecond = ( Nemo.D.P[lsPowerType].pgr or 0 )
		lPowerInWaitSeconds = lCurrentPower + ( lWait * lPowerGainedPerSecond )
	end
	if ( lRequiredPower > UnitPowerMax("player", lnPowerType) ) then lRequiredPower = UnitPowerMax("player", lnPowerType) end

	if ( lPowerInWaitSeconds < lRequiredPower ) then
		bPowerLevelPasses = false
	end
	Nemo.AppendCriteriaDebug( 'GetPlayerHasEnoughPower(PowerType='..tostring(lsPowerType)..",RequiredPower="..tostring(lRequiredPower)..",spell="..tostring(lSpell)..",wait="..tostring(lWait)..')='..tostring(bPowerLevelPasses) )
	return bPowerLevelPasses
end
Nemo.D.criteria["d/player/GetPlayerHasEnoughPower"]={
	a=4,
	a1l=L["d/common/power/l"],a1dv="SPELL_POWER_"..select(2, UnitPowerType("player")),a1tt=L["d/common/power/tt"],
	a2l=L["d/common/powerrequired/l"],a2dv="0",a2tt=L["d/common/powerrequired/tt"],
	a3l=L["d/common/sp/l"],a3dv=L["d/common/sp/dv"],a3tt=L["d/common/sp/tt"],
	a4l=L["d/common/seconds/l"],a4dv="0",a4tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetPlayerHasEnoughPower(%s,%s,%q,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerHasEnoughPower")', text=L["d/player/GetPlayerHasEnoughPower"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerHasGlyphSpellActive=function(spell)
	if spell then
		for i=1,GetNumGlyphSockets() do
			local lGSID = tostring( select(4, GetGlyphSocketInfo(i)) )
			local lGSN = Nemo.GetSpellName(lGSID)
			if ( spell==lGSID or spell==lGSN or Nemo.GetSpellID(spell)==lGSID ) then
				return true
			end
		end
	end
	return false
end
Nemo.D.criteria["d/player/GetPlayerHasGlyphSpellActive"]={
	a=1,
	a1l=L["d/common/gs/l"],a1dv='',a1tt=L["d/common/gs/tt"],
	f=function () return format('Nemo.GetPlayerHasGlyphSpellActive(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerHasGlyphSpellActive")', text=L["d/player/GetPlayerHasGlyphSpellActive"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerIsAutoCastingSpell=function(spell)
	local lSID = Nemo.GetSpellName(spell)
	if ( lSID ) then
		local _,autostate = GetSpellAutocast(lSID)
		return autostate
	end
end
Nemo.D.criteria["d/player/GetPlayerIsAutoCastingSpell"]={
	a=1,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetPlayerIsAutoCastingSpell(%q)', Nemo.UI["ebArg1"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerIsAutoCastingSpell")', text=L["d/player/GetPlayerIsAutoCastingSpell"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerIsSolo=function(checklfgstatus)
	Nemo.D.ResetDebugTimer()
	local lPlayerIsSolo = true
	local members = GetNumGroupMembers()
	if ( members > 0 ) then lPlayerIsSolo = false end
	if ( checklfgstatus and lPlayerIsSolo ) then
		if ( GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
			or GetLFGQueueStats(LE_LFG_CATEGORY_LFR)
			or GetLFGQueueStats(LE_LFG_CATEGORY_RF)
			or GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO)
			) then
			lPlayerIsSolo = false
		end
	end
	Nemo.AppendCriteriaDebug( 'GetPlayerIsSolo(checklfgstatus='..tostring(checklfgstatus)..')='..tostring(lPlayerIsSolo) )
	return lPlayerIsSolo
end
Nemo.D.criteria["d/player/GetPlayerIsSolo"]={
	a=1,
	a1l=L["d/common/truefalse/l"],a1dv="false",a1tt=L["d/common/truefalse/tt"],
	f=function () return format('Nemo.GetPlayerIsSolo(%s)', Nemo.UI["ebArg1"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerIsSolo")', text=L["d/player/GetPlayerIsSolo"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerKnowsSpell=function(spell)
	Nemo.D.ResetDebugTimer()
	local lReturn = IsPlayerSpell( Nemo.GetSpellID(spell) )
	Nemo.AppendCriteriaDebug( 'GetPlayerKnowsSpell(spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/player/GetPlayerKnowsSpell"]={
	a=1,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetPlayerKnowsSpell(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerKnowsSpell")', text=L["d/player/GetPlayerKnowsSpell"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerPowerRegen=function()
	Nemo.D.ResetDebugTimer()
	
	local lNumericCurrentPowerType, lStringCurrentPowerType = UnitPowerType("player")
	lStringCurrentPowerType = "SPELL_POWER_"..lStringCurrentPowerType
	if ( lNumericCurrentPowerType ) then
		lStringCurrentPowerType = Nemo.D.POWER_TYPES[lNumericCurrentPowerType]
	end
	local lPowerGainedPerSecond = ( Nemo.D.P[lStringCurrentPowerType].pgr or 0 )
		
	Nemo.AppendCriteriaDebug( 'GetPlayerPowerRegen(CurrentPowerType='..tostring(lStringCurrentPowerType)..')='..tostring(lPowerGainedPerSecond) )
	return lPowerGainedPerSecond
end
Nemo.D.criteria["d/player/GetPlayerPowerRegen"]={
	a=2,
	a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
	a2l=L["d/common/count/l"],a2dv="5",a2tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetPlayerPowerRegen()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerPowerRegen")', text=L["d/player/GetPlayerPowerRegen"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPlayerTimeToMaxPower=function()
	Nemo.D.ResetDebugTimer()
	
	local lNumericCurrentPowerType, lStringCurrentPowerType = UnitPowerType("player")
	lStringCurrentPowerType = "SPELL_POWER_"..lStringCurrentPowerType
	if ( lNumericCurrentPowerType ) then
		lStringCurrentPowerType = Nemo.D.POWER_TYPES[lNumericCurrentPowerType]
	end
	local lTimeToMaxPower = ( Nemo.D.P[lStringCurrentPowerType].ttm or 0 )
		
	Nemo.AppendCriteriaDebug( 'GetPlayerTimeToMaxPower(CurrentPowerType='..tostring(lStringCurrentPowerType)..')='..tostring(lTimeToMaxPower) )
	return lTimeToMaxPower
end
Nemo.D.criteria["d/player/GetPlayerTimeToMaxPower"]={
	a=2,
	a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
	a2l=L["d/common/seconds/l"],a2dv="60",a2tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetPlayerTimeToMaxPower()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPlayerTimeToMaxPower")', text=L["d/player/GetPlayerTimeToMaxPower"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetPowerTimeToValue=function(powertype, powervalue, bool)
	Nemo.D.ResetDebugTimer()
	local lReturn = 600
	local lCurrentPower = Nemo.GetUnitPower("player",powertype,bool)
	local lStringPowerType = Nemo.D.POWER_TYPES[powertype]

	if ( lCurrentPower >= powervalue ) then
		lReturn = 0
	elseif ( Nemo.D.P[lStringPowerType] and Nemo.D.P[lStringPowerType].pgr ) then	
		local lPowerGainedPerSecond = ( Nemo.D.P[lStringPowerType].pgr or 0 )
		lReturn = (powervalue-lCurrentPower)/lPowerGainedPerSecond
	end
	
	Nemo.AppendCriteriaDebug( 'GetPowerTimeToValue(powertype='..tostring(powertype)..',powervalue='..tostring(powervalue)..',bool='..tostring(bool)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/player/GetPowerTimeToValue"]={
	a=3,
	a1l=L["d/common/power/l"],a1dv="SPELL_POWER_"..select(2, UnitPowerType("player")),a1tt=L["d/common/power/tt"],
	a2l=L["d/common/powerrequired/l"],a2dv="0",a2tt=L["d/common/powerrequired/tt"],
	a3l=L["d/common/truefalse/l"],a3dv="false",a3tt=L["d/common/truefalse/tt"],
	f=function () return format('Nemo.GetPowerTimeToValue(%s,%s,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[PLAYER_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/player/GetPowerTimeToValue")', text=L["d/player/GetPowerTimeToValue"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
end


--********************************************************************************************
--PET CRITERIA
--********************************************************************************************
Nemo.GetPetSpellKnown=function(spell)
	local lSID=Nemo.GetSpellID(spell)
	if ( lSID ) then
		return IsSpellKnown(lSID, true)
	end
end
Nemo.D.criteria["d/pet/GetPetSpellKnown"]={
	a=1,
	a1l=L["d/common/sp/l"],a1dv='',a1tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetPetSpellKnown(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[PET_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/pet/GetPetSpellKnown")', text=L["d/pet/GetPetSpellKnown"] } )
--********************************************************************************************
--UNIT CRITERIA
--********************************************************************************************
Nemo.GetHurtNPCCount=function()
	Nemo.D.ResetDebugTimer()
	local lCount 	= 0
	local lTracked	= 0
	for k,v in pairs(Nemo.D.P.TU) do
		if ( v.ldt and ((GetTime()-v.ldt) < 10) ) then -- Only lCount NPCs hurt in the last 5 seconds
			lCount = lCount+1
		end
		lTracked = lTracked+1
	end
	Nemo.AppendCriteriaDebug( 'GetHurtNPCCount()='..tostring(lCount)..' Tracking='..tostring(lTracked)  )
	return lCount
end
Nemo.D.criteria["d/unit/GetHurtNPCCount"]={
	a=2,
	a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
	a2l=L["d/common/count/l"],a2dv="2",a2tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetHurtNPCCount()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetHurtNPCCount")', text=L["d/unit/GetHurtNPCCount"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetTargetTimeToDie=function()
	Nemo.D.ResetDebugTimer()
	local lReturn = 600
	local lTrackedGUID = UnitGUID("target")
	if ( Nemo.D.P.TU[lTrackedGUID] and Nemo.D.P.TU[lTrackedGUID].timetodie ) then
		lReturn = Nemo.D.P.TU[lTrackedGUID].timetodie
	end
	Nemo.AppendCriteriaDebug( 'GetTargetTimeToDie()='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetTargetTimeToDie"]={
	a=2,
	a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
	a2l=L["d/common/seconds/l"],a2dv="10",a2tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetTargetTimeToDie()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetTargetTimeToDie")', text=L["d/unit/GetTargetTimeToDie"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitCastingInterruptibleSpell=function(unit)
	Nemo.D.ResetDebugTimer()
	local lReturn = false
	local unitCasting, _, _, _, startTime, _, _, _, CantInterrupt = UnitCastingInfo(unit)
	if (not unitCasting) then
		unitCasting, _, _, _, startTime, _, _, CantInterrupt = UnitChannelInfo(unit)
	end
	if ( unitCasting ) then
		if ( CantInterrupt == nil or CantInterrupt == false ) then
			lReturn = true
		end
	end
	Nemo.AppendCriteriaDebug( 'GetUnitCastingInterruptibleSpell(unit='..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitCastingInterruptibleSpell"]={
	a=1,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetUnitCastingInterruptibleSpell(%q)', Nemo.UI["ebArg1"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitCastingInterruptibleSpell")', text=L["d/unit/GetUnitCastingInterruptibleSpell"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitCastingSpell=function(unit, spell)
	Nemo.D.ResetDebugTimer()
	local lReturn = false
	local unitCasting, _, _, _, startTime = UnitCastingInfo(unit)
	if (not unitCasting) then
		unitCasting, _, _, _, startTime = UnitChannelInfo(unit)
	end
	if (unitCasting) then
		hasbeencasting =  GetTime() - (startTime/1000)
		if ( Nemo.GetSpellName( spell ) ==  unitCasting ) then
			lReturn = true
		end
	end
	Nemo.AppendCriteriaDebug( 'GetUnitCastingSpell(unit='..tostring(unit)..',spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitCastingSpell"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/sp/l"],a2dv=L["d/common/sp/dv"],a2tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetUnitCastingSpell(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitCastingSpell")', text=L["d/unit/GetUnitCastingSpell"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitCastingSpellInList=function(unit, list)
	local unitCasting, startTime; unitCasting, _, _, _, startTime = UnitCastingInfo(unit)
	if (not unitCasting) then
		unitCasting, _, _, _, startTime = UnitChannelInfo(unit)
	end
	if (unitCasting) then
		hasbeencasting = GetTime() - (startTime/1000)
		local TreeLevel2=Nemo:SearchTable(Nemo.D.LTMC, "value", 'Nemo.UI:CreateListPanel([=['..list..']=])')
		for k, v in pairs(Nemo.D.LTMC[TreeLevel2].entrytree) do
			local _,_,spellID = strfind(v.value, '"(.*)","s"')
			if ( Nemo.GetSpellName( spellID ) ==  unitCasting ) then
				return true
			end
		end
	end
	return false
end
Nemo.D.criteria["d/unit/GetUnitCastingSpellInList"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/list/l"],a2dv=L["d/common/list/dv"],a2tt=L["d/common/list/tt"],
	f=function () return format('Nemo.GetUnitCastingSpellInList(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitCastingSpellInList")', text=L["d/unit/GetUnitCastingSpellInList"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitCastTimeleft=function(unit)
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	local unitCasting, _, _, _, startTime, endTime = UnitCastingInfo(unit)

	if (not unitCasting) then
		unitCasting, _, _, _, startTime, endTime = UnitChannelInfo(unit)
	end
	if ( unitCasting and endTime and endTime > 0) then
		lReturn = (endTime/1000) - GetTime()
	else
		lReturn = 0
	end
	Nemo.AppendCriteriaDebug( 'GetUnitCastTimeleft(unit='..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitCastTimeleft"]={
	a=3,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/seconds/l"],a3dv="2.5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetUnitCastTimeleft(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitCastTimeleft")', text=L["d/unit/GetUnitCastTimeleft"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitDebuffTimeleftInList=function(unit, list, filter)
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	
	local TreeLevel2=Nemo:SearchTable(Nemo.D.LTMC, "value", 'Nemo.UI:CreateListPanel([=['..list..']=])')
	for k, v in pairs(Nemo.D.LTMC[TreeLevel2].entrytree) do
		local _,_,spellID = strfind(v.value, '"(.*)","s"')
		local name,_,_,_,_,_,expirationTime=UnitDebuff(unit, Nemo.GetSpellName(spellID), nil, filter)
		if ( name ) then
			lReturn = expirationTime - GetTime()
			if lReturn < 0 then lReturn = 0 end
		end
	end
	
	Nemo.AppendCriteriaDebug( 'GetUnitDebuffTimeleftInList(unit='..tostring(unit)..',list='..tostring(list)..',filter='..tostring(filter)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitDebuffTimeleftInList"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/list/l"],a2dv=L["d/common/list/dv"],a2tt=L["d/common/list/tt"],
	f=function () return format('Nemo.GetUnitDebuffTimeleftInList(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitDebuffTimeleftInList")', text=L["d/unit/GetUnitDebuffTimeleftInList"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitExists=function(unit)
	Nemo.D.ResetDebugTimer()
	local lReturn = false
	if ( unit and UnitExists(unit) ) then
		lReturn = true
	end
	Nemo.AppendCriteriaDebug( 'GetUnitExists(unit='..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitExists"]={
	a=1,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetUnitExists(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitExists")', text=L["d/unit/GetUnitExists"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitGUIDIsGroupMember=function(unitGUID)
	local group, num = nil, 0
	local unitID
	local lLowestHealthPercent = 100
	local lLowestUnitID = "player"

	if ( UnitGUID("player") == unitGUID ) then
-- print("unitGUID=playerGUID")
		return true
	end
	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	end
	for i = 1, num do
		unitID = group..i;
-- print("checking if "..unitGUID.."=="..UnitGUID(unitID))
		if ( UnitGUID(unitID) == unitGUID ) then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasBuffID=function(unit, buffid)
	Nemo.D.ResetDebugTimer()
	local found = false
	for i = 1, 40 do
		name, _, _, _, _, _, _, _, _, _, spellID=UnitBuff(unit, i)
		if (not name or found) then
			break
		end
		if ( (not Nemo:isblank(name)) and spellID and tostring(spellID)==tostring(buffid)) then
			found = true
		end
	end
	Nemo.AppendCriteriaDebug( 'GetUnitHasBuffID(unit='..tostring(unit)..","..tostring(buffid)..')='..tostring(found) )
	return found
end
Nemo.D.criteria["d/unit/GetUnitHasBuffID"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/buffid/l"],a2dv=L["d/common/buffid/dv"],a2tt=L["d/common/buffid/tt"],
	f=function () return format('Nemo.GetUnitHasBuffID(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasBuffID")', text=L["d/unit/GetUnitHasBuffID"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasBuffIDStacks=function(unit, buffid)
	local bs=0;
	for i = 1, 40 do
		name,_,_,stacks,_,_,_,_,_,_,spellID=UnitBuff(unit, i)
		if (not name) then break end
		if ( (not Nemo:isblank(name) ) and spellID and tostring(spellID)==tostring(buffid) ) then
			bs=stacks or 0
			return bs
		end
	end
	return bs
end
Nemo.D.criteria["d/unit/GetUnitHasBuffIDStacks"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/buffid/l"],a2dv=L["d/common/buffid/dv"],a2tt=L["d/common/buffid/tt"],
	a3l=L["d/common/co/l"],a3dv=">=",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/stacks/l"],a4dv="2",a4tt=L["d/common/stacks/tt"],
	f=function () return format('Nemo.GetUnitHasBuffIDStacks(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasBuffIDStacks")', text=L["d/unit/GetUnitHasBuffIDStacks"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasBuffName=function(unit, buff, filter)
	Nemo.D.ResetDebugTimer()
	local lReturn = false
	if ( buff and UnitBuff(unit, Nemo.GetSpellName(buff), nil, filter) ) then lReturn = true end
	Nemo.AppendCriteriaDebug( 'GetUnitHasBuffName(unit='..tostring(unit)..',buff='..tostring(buff)..',filter='..tostring(filter)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitHasBuffName"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/buff/l"],a2dv=L["d/common/buff/dv"],a2tt=L["d/common/buff/tt"],
	f=function () return format('Nemo.GetUnitHasBuffName(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasBuffName")', text=L["d/unit/GetUnitHasBuffName"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasBuffNameInList=function(unit, list)
	local TreeLevel2=Nemo:SearchTable(Nemo.D.LTMC, "value", 'Nemo.UI:CreateListPanel([=['..list..']=])')
	for k,v in pairs(Nemo.D.LTMC[TreeLevel2].entrytree) do
		local _,_,spellID = strfind(v.value, '"(.*)","s"')
		if ( spellID and Nemo.GetUnitHasBuffName( unit, spellID ) ) then
			return true
		end
	end
	return false
end
Nemo.D.criteria["d/unit/GetUnitHasBuffNameInList"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/list/l"],a2dv=L["d/common/list/dv"],a2tt=L["d/common/list/tt"],
	f=function () return format('Nemo.GetUnitHasBuffNameInList(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasBuffNameInList")', text=L["d/unit/GetUnitHasBuffNameInList"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasBuffNameStacks=function(unit, buff)
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	local name,_,_,stacks=UnitBuff(unit, Nemo.GetSpellName(buff))
	
	if ( name ) then lReturn = Nemo:NilToNumeric(stacks) end
	Nemo.AppendCriteriaDebug( 'GetUnitHasBuffNameStacks(unit='..tostring(unit)..',buff='..tostring(buff)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitHasBuffNameStacks"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/buff/l"],a2dv=L["d/common/buff/dv"],a2tt=L["d/common/buff/tt"],
	a3l=L["d/common/co/l"],a3dv=">=",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/stacks/l"],a4dv="2",a4tt=L["d/common/stacks/tt"],
	f=function () return format('Nemo.GetUnitHasBuffNameStacks(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasBuffNameStacks")', text=L["d/unit/GetUnitHasBuffNameStacks"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasBuffNameTimeleft=function(unit, buff)
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	local name,_,_,_,_,_,expirationTime=UnitBuff(unit, Nemo.GetSpellName(buff))
	if ( name ) then
		lReturn = ( expirationTime - GetTime() )
		if lReturn < 0 then	lReturn = 0	end
	end
	Nemo.AppendCriteriaDebug( 'GetUnitHasBuffNameTimeleft(unit='..tostring(unit)..',buff='..tostring(buff)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitHasBuffNameTimeleft"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/buff/l"],a2dv=L["d/common/buff/dv"],a2tt=L["d/common/buff/tt"],
	a3l=L["d/common/co/l"],a3dv=">=",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/seconds/l"],a4dv="2.5",a4tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetUnitHasBuffNameTimeleft(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasBuffNameTimeleft")', text=L["d/unit/GetUnitHasBuffNameTimeleft"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasCurableDebuffType=function(unit, dtype)
	for i = 1, 40 do
		name,_,_,_,debuffType=UnitDebuff(unit, i, 1)
		if (not name) then
			break
		end
		if ( not Nemo:isblank(name) and debuffType and debuffType==dtype and not Nemo.D.DebuffExclusions[name] ) then
			return true
		end
	end
	return false
end
Nemo.D.criteria["d/unit/GetUnitHasCurableDebuffType"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debufftype/l"],a2dv=L["d/common/debufftype/dv"],a2tt=L["d/common/debufftype/tt"],
	f=function () return format('Nemo.GetUnitHasCurableDebuffType(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasCurableDebuffType")', text=L["d/unit/GetUnitHasCurableDebuffType"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasDebuffID=function(unit, debuffid, filter)
	local debuffid = Nemo.GetSpellID(debuffid)
	for i = 1, 40 do
		local name, _, _, _, _, _, _, _, _, _, spellID=UnitDebuff(unit, i, nil, filter)
		if (not name or not debuffid) then
			break
		end
		if ( not Nemo:isblank(name) and spellID and tostring(spellID) == debuffid ) then
			return true
		end
	end
	return false
end
Nemo.D.criteria["d/unit/GetUnitHasDebuffID"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuffid/l"],a2dv=L["d/common/debuffid/dv"],a2tt=L["d/common/debuffid/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffID(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasDebuffID")', text=L["d/unit/GetUnitHasDebuffID"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasDebuffName=function(unit, debuff, filter)
	if ( debuff and UnitDebuff(unit, Nemo.GetSpellName(debuff), nil, filter) ) then
		return true
	else
	if ( Nemo.D.TU[unit] and Nemo.D.TU[unit].auras[debuff] ) then
		if ( not filter ) then
			return true
		elseif ( string.lower(filter) == "player" and Nemo.D.TU[unit].auras[debuff].sguid == UnitGUID("player") ) then --sguid = sourceguid
			return true
		end
	end
	return false
	end
end
Nemo.D.criteria["d/unit/GetUnitHasDebuffName"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuff/l"],a2dv=L["d/common/debuff/dv"],a2tt=L["d/common/debuff/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffName(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasDebuffName")', text=L["d/unit/GetUnitHasDebuffName"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasDebuffNameInList=function(unit, list)
	local TreeLevel2=Nemo:SearchTable(Nemo.D.LTMC, "value", 'Nemo.UI:CreateListPanel([=['..list..']=])')
	for k, v in pairs(Nemo.D.LTMC[TreeLevel2].entrytree) do
		local _,_,spellID = strfind(v.value, '"(.*)","s"')
		if ( Nemo.GetUnitHasDebuffName( unit, spellID, '' ) ) then
			return true
		end
	end
	if ( Nemo.D.TU[unit] ) then
		for k, v in pairs(Nemo.D.LTMC[TreeLevel2].entrytree) do
			local _,_,spellID = strfind(v.value, '"(.*)","s"')
			if ( Nemo.D.TU[unit].auras[spellID] ) then
				return true
			end
		end
	end
	return false
end
Nemo.D.criteria["d/unit/GetUnitHasDebuffNameInList"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/list/l"],a2dv=L["d/common/list/dv"],a2tt=L["d/common/list/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffNameInList(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasDebuffNameInList")', text=L["d/unit/GetUnitHasDebuffNameInList"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasDebuffNameStacks=function(unit, debuff, filter)
	Nemo.D.ResetDebugTimer()
	local stacks = 0
	local name,_,_,stacks=UnitDebuff(unit, Nemo.GetSpellName(debuff), nil, filter)
	Nemo.AppendCriteriaDebug( 'GetUnitHasDebuffNameStacks(unit='..tostring(unit)..',debuff='..tostring(debuff)..',filter='..tostring(filter)..')='..tostring(stacks) )
	return Nemo:NilToNumeric(stacks, 0)
end
Nemo.D.criteria["d/unit/GetUnitHasDebuffNameStacks"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuff/l"],a2dv=L["d/common/debuff/dv"],a2tt=L["d/common/debuff/tt"],
	a3l=L["d/common/co/l"],a3dv=">=",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/stacks/l"],a4dv="2",a4tt=L["d/common/stacks/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffNameStacks(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasDebuffNameStacks")', text=L["d/unit/GetUnitHasDebuffNameStacks"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasDebuffNameTimeleft=function(unit, debuff, filter)
	Nemo.D.ResetDebugTimer()
	local timeleft = 0
	local name,_,_,_,_,_,expirationTime=UnitDebuff(unit, Nemo.GetSpellName(debuff), nil, filter)
	if ( name ) then
		timeleft = expirationTime - GetTime()
		if timeleft < 0 then timeleft = 0 end
	end
	Nemo.AppendCriteriaDebug( 'GetUnitHasDebuffNameTimeleft(unit='..tostring(unit)..',debuff='..tostring(debuff)..',filter='..tostring(filter)..')='..tostring(timeleft) )
	return timeleft
end
Nemo.D.criteria["d/unit/GetUnitHasDebuffNameTimeleft"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuff/l"],a2dv=L["d/common/debuff/dv"],a2tt=L["d/common/debuff/tt"],
	a3l=L["d/common/co/l"],a3dv=">=",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/seconds/l"],a4dv="2.5",a4tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffNameTimeleft(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasDebuffNameTimeleft")', text=L["d/unit/GetUnitHasDebuffNameTimeleft"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasDebuffType=function(unit, dtype)
	for i = 1, 40 do
		name,_,_,_,debuffType=UnitDebuff(unit, i)
		if (not name) then break end
		if ( (not Nemo:isblank(name)) and debuffType and debuffType==dtype and (not Nemo.D.DebuffExclusions[name]) ) then
			return true
		end
	end
	return false
end
Nemo.D.criteria["d/unit/GetUnitHasDebuffType"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debufftype/l"],a2dv=L["d/common/debufftype/dv"],a2tt=L["d/common/debufftype/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffType(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasDebuffType")', text=L["d/unit/GetUnitHasDebuffType"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/unit/GetUnitHasMyBuffName"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/buff/l"],a2dv=L["d/common/buff/dv"],a2tt=L["d/common/buff/tt"],
	f=function () return format('Nemo.GetUnitHasBuffName(%q,%q,"PLAYER")', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasMyBuffName")', text=L["d/unit/GetUnitHasMyBuffName"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/unit/GetUnitHasMyDebuffID"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuffid/l"],a2dv=L["d/common/debuffid/dv"],a2tt=L["d/common/debuffid/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffID(%q,%q,"PLAYER")', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasMyDebuffID")', text=L["d/unit/GetUnitHasMyDebuffID"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/unit/GetUnitHasMyDebuffName"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuff/l"],a2dv=L["d/common/debuff/dv"],a2tt=L["d/common/debuff/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffName(%q,%q,"PLAYER")', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasMyDebuffName")', text=L["d/unit/GetUnitHasMyDebuffName"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/unit/GetUnitHasMyDebuffNameStacks"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuff/l"],a2dv=L["d/common/debuff/dv"],a2tt=L["d/common/debuff/tt"],
	a3l=L["d/common/co/l"],a3dv=">=",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/stacks/l"],a4dv="2",a4tt=L["d/common/stacks/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffNameStacks(%q,%q,"PLAYER")%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasMyDebuffNameStacks")', text=L["d/unit/GetUnitHasMyDebuffNameStacks"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/unit/GetUnitHasMyDebuffNameTimeleft"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/debuff/l"],a2dv=L["d/common/debuff/dv"],a2tt=L["d/common/debuff/tt"],
	a3l=L["d/common/co/l"],a3dv=">=",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/seconds/l"],a4dv="2",a4tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetUnitHasDebuffNameTimeleft(%q,%q,"PLAYER")%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasMyDebuffNameTimeleft")', text=L["d/unit/GetUnitHasMyDebuffNameTimeleft"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHasMySpellTicksRemaining=function(unit, spell, baseticktime)
	Nemo.D.ResetDebugTimer()
	local lspellID	= Nemo.GetSpellID(spell)
	local lunitGUID = nil
	local lReturn	= 0
	if ( unit and UnitExists(unit) ) then
		lunitGUID = UnitGUID(unit)
	end
	if ( not baseticktime ) then
		if ( Nemo.D.SpellInfo[spell] and Nemo.D.SpellInfo[spell].baseticktime ) then
			baseticktime = Nemo.D.SpellInfo[spell].baseticktime
		else
			baseticktime = 2
		end
	end
	if ( lspellID and lunitGUID and Nemo.D.P.TS[lspellID..':'..lunitGUID] ) then
 		local lHastedTickTime = Nemo.GetSpellTickTimeOnUnit(lspellID, baseticktime, unit)
		if ( Nemo.D.P.TS[lspellID..':'..lunitGUID].atype == Nemo.D.AuraTypes["DEBUFF"] ) then
			lReturn = math.ceil( Nemo.GetUnitHasDebuffNameTimeleft(unit,lspellID,"PLAYER") / (lHastedTickTime or 2) )
		elseif ( Nemo.D.P.TS[lspellID..':'..lunitGUID].atype == Nemo.D.AuraTypes["BUFF"] ) then
			lReturn = math.ceil( Nemo.GetUnitHasBuffNameTimeleft(unit,lspellID,"PLAYER") / (lHastedTickTime or 2) )
		end
	end
	Nemo.AppendCriteriaDebug( 'GetUnitHasMySpellTicksRemaining(unit='..tostring(unit)..",spell="..tostring(spell)..",baseticktime="..tostring(baseticktime)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitHasMySpellTicksRemaining"]={
	a=3,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/sp/l"],a2dv=L["d/common/sp/dv"],a2tt=L["d/common/sp/tt"],
	a3l=L["d/common/ticktime/l"],a3dv="2",a3tt=L["d/common/ticktime/tt"],
	f=function () return format('Nemo.GetUnitHasMySpellTicksRemaining(%q,%q,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHasMySpellTicksRemaining")', text=L["d/unit/GetUnitHasMySpellTicksRemaining"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHealth=function(unit)
	return UnitHealth(unit) or 0
end
Nemo.D.criteria["d/unit/GetUnitHealth"]={
	a=3,
	a1l=L["d/common/un/l"],a1dv="player",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/co/l"],a2dv="<",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/he/l"],a3dv="15000",a3tt=L["d/common/he/tt"],
	f=function () return format('Nemo.GetUnitHealth(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHealth")', text=L["d/unit/GetUnitHealth"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHealthLost=function(unit)
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	if ( unit and UnitExists(unit) ) then
		lReturn = ( UnitHealthMax(unit) - UnitHealth(unit) ) or 0
	end
	Nemo.AppendCriteriaDebug( 'GetUnitHealthLost(unit='..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitHealthLost"]={
	a=3,
	a1l=L["d/common/un/l"],a1dv="player",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/co/l"],a2dv="<",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/he/l"],a3dv="15000",a3tt=L["d/common/he/tt"],
	f=function () return format('Nemo.GetUnitHealthLost(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHealthLost")', text=L["d/unit/GetUnitHealthLost"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitHealthPercent=function(unit)
	Nemo.D.ResetDebugTimer()
	local lReturn = (Nemo.GetUnitHealth(unit)/UnitHealthMax(unit)*100)
	Nemo.AppendCriteriaDebug( 'GetUnitHealthPercent(unit='..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitHealthPercent"]={
	a=3,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/co/l"],a2dv="<",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/pe/l"],a3dv="75",a3tt=L["d/common/pe/tt"],
	f=function () return format('Nemo.GetUnitHealthPercent(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitHealthPercent")', text=L["d/unit/GetUnitHealthPercent"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitIsMoving=function(unit)
	return (GetUnitSpeed(unit) > 0)
end
Nemo.D.criteria["d/unit/GetUnitIsMoving"]={
	a=1,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetUnitIsMoving(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitIsMoving")', text=L["d/unit/GetUnitIsMoving"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitIsPlayerControlled=function(unit)
	return UnitPlayerControlled(unit)
end
Nemo.D.criteria["d/unit/GetUnitIsPlayerControlled"]={
	a=1,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetUnitIsPlayerControlled(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitIsPlayerControlled")', text=L["d/unit/GetUnitIsPlayerControlled"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/unit/GetUnitIsUnit"]={
	a=2,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/un/l"],a2dv="focus",a2tt=L["d/common/un/tt"],
	f=function () return format('UnitIsUnit(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitIsUnit")', text=L["d/unit/GetUnitIsUnit"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitNumberItemsEquippedInList=function(unit, list)
	local count = 0
	if ( unit and list ) then
		local TreeLevel2=Nemo:SearchTable(Nemo.D.LTMC, "value", 'Nemo.UI:CreateListPanel([=['..list..']=])')
		for slot = 1, EQUIPPED_LAST do
			local lWearingItemID = Nemo.GetUnitItemInventoryId(unit, slot)
			if (not Nemo:isblank(lWearingItemID)) then
				for k,v in pairs(Nemo.D.LTMC[TreeLevel2].entrytree) do
					local _,_,itemID = strfind(v.value, '"(.*)","i"')
					if ( itemID and itemID == tostring(lWearingItemID) ) then
						count = count + 1
					end
				end
			end
		end
	end
	return count
end
Nemo.D.criteria["d/unit/GetUnitNumberItemsEquippedInList"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="player",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="4",a3tt=L["d/common/count/tt"],
	a4l=L["d/common/list/l"],a4dv=L["d/common/list/dv"],a4tt=L["d/common/list/tt"],
	f=function () return format('Nemo.GetUnitNumberItemsEquippedInList(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg4"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitNumberItemsEquippedInList")', text=L["d/unit/GetUnitNumberItemsEquippedInList"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitPower=function(unit, powertype, bool)
	Nemo.D.ResetDebugTimer()
	local lReturn = Nemo:NilToNumeric(UnitPower(unit, powertype, bool))
	Nemo.AppendCriteriaDebug( 'GetUnitPower(unit='..tostring(unit)..",powertype="..tostring(powertype)..",bool="..tostring(bool)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/unit/GetUnitPower"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="player",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/power/l"],a2dv="SPELL_POWER_MANA",a2tt=L["d/common/power/tt"],
	a3l=L["d/common/co/l"],a3dv="<",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/count/l"],a4dv="0",a4tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetUnitPower(%q,%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitPower")', text=L["d/unit/GetUnitPower"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitPowerPercent=function(unit, powertype)
	return Nemo:NilToNumeric( Nemo.GetUnitPower(unit, powertype)/UnitPowerMax(unit, powertype)*100)
end
Nemo.D.criteria["d/unit/GetUnitPowerPercent"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="target",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/power/l"],a2dv="SPELL_POWER_MANA",a2tt=L["d/common/power/tt"],
	a3l=L["d/common/co/l"],a3dv="<",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/pe/l"],a4dv="75",a4tt=L["d/common/pe/tt"],
	f=function () return format('Nemo.GetUnitPowerPercent(%q,%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitPowerPercent")', text=L["d/unit/GetUnitPowerPercent"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetUnitThreatSituation=function(unit, otherunit)
	return UnitThreatSituation(unit, otherunit) or -1
end
Nemo.D.criteria["d/unit/GetUnitThreatSituation"]={
	a=4,
	a1l=L["d/common/un/l"],a1dv="player",a1tt=L["d/common/un/tt"],
	a2l=L["d/common/un/l"],a2dv="target",a2tt=L["d/common/un/tt"],
	a3l=L["d/common/co/l"],a3dv="==",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/threatstatus/l"],a4dv=L["d/common/threatstatus/dv"],a4tt=L["d/common/threatstatus/tt"],
	f=function () return format('Nemo.GetUnitThreatSituation(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[UNIT_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/unit/GetUnitThreatSituation")', text=L["d/unit/GetUnitThreatSituation"] } )
--********************************************************************************************
--ITEM CRITERIA
--********************************************************************************************
if true then
Nemo.GetItemCooldown=function(item)
	if ( Nemo:isblank( Nemo.GetItemId( item ) ) ) then
		return 999
	end
	local startICD, inICD = GetItemCooldown( Nemo.GetItemId( item ) )
	local ICDRemains = (Nemo:NilToNumeric(startICD) + Nemo:NilToNumeric(inICD) - GetTime())
	if ICDRemains < 0 then ICDRemains = 0 end
	return ICDRemains
end
Nemo.D.criteria["d/item/GetItemCooldown"]={
	a=3,
	a1l=L["d/common/item/l"],a1dv="",a1tt=L["d/common/item/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/seconds/l"],a3dv="2.5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetItemCooldown(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[ITEM_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/item/GetItemCooldown")', text=L["d/item/GetItemCooldown"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetItemCooldownLessThanGCD=function(item)
	local GCD = Nemo.GetSpellCooldown(L[Nemo.D.PClass..'_GCD_SPELL'])
	local ICD = Nemo.GetItemCooldown(item)
	if ICD <= (GCD+1) then
		return true
	else
		return false
	end
end
Nemo.D.criteria["d/item/GetItemCooldownLessThanGCD"]={
	a=1,
	a1l=L["d/common/item/l"],a1dv="",a1tt=L["d/common/item/tt"],
	f=function () return format('Nemo.GetItemCooldownLessThanGCD(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[ITEM_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/item/GetItemCooldownLessThanGCD")', text=L["d/item/GetItemCooldownLessThanGCD"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetItemCount=function(item)
	return GetItemCount( item )
end
Nemo.D.criteria["d/item/GetItemCount"]={
	a=3,
	a1l=L["d/common/item/l"],a1dv="",a1tt=L["d/common/item/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="3",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetItemCount(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[ITEM_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/item/GetItemCount")', text=L["d/item/GetItemCount"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetItemInRangeOfUnit=function(item, unit)
	return IsItemInRange(item, unit)
end
Nemo.D.criteria["d/item/GetItemInRangeOfUnit"]={
	a=2,
	a1l=L["d/common/item/l"],a1dv="",a1tt=L["d/common/item/tt"],
	a2l=L["d/common/un/l"],a2dv="target",a2tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetItemInRangeOfUnit(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[ITEM_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/item/GetItemInRangeOfUnit")', text=L["d/item/GetItemInRangeOfUnit"] } )
end
--********************************************************************************************
--SPELL CRITERIA
--********************************************************************************************
if true then
Nemo.GetSpellAppliedAttackPower=function(spell, unit)
	local lspellID = Nemo.GetSpellID(spell)
	local lunitGUID = UnitGUID(unit)
	if ( lspellID and lunitGUID and Nemo.D.P.TS[lspellID..':'..lunitGUID] ) then
		return Nemo.D.P.TS[lspellID..':'..lunitGUID].smap
	else
		return 0
	end
end
Nemo.D.criteria["d/spell/GetSpellAppliedAttackPower"]={
	a=2,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/un/l"],a2dv="target",a2tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellAppliedAttackPower(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellAppliedAttackPower")', text=L["d/spell/GetSpellAppliedAttackPower"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellAppliedBonusDamage=function(spell, spellTreeID, unit)
	Nemo.D.ResetDebugTimer()
	local lspellID = Nemo.GetSpellID(spell)
	local lunitGUID = UnitGUID(unit)
	local lReturn = 0
	if ( lspellID and lunitGUID and spellTreeID and Nemo.D.P.TS[lspellID..':'..lunitGUID] ) then
		lReturn = Nemo.D.P.TS[lspellID..':'..lunitGUID].smbd[tostring(spellTreeID)]
	end
	Nemo.AppendCriteriaDebug( 'GetSpellAppliedBonusDamage(spell='..tostring(spell)..',spellTreeID='..tostring(spellTreeID)..',unit='..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellAppliedBonusDamage"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/spellschool/l"],a2dv="6",a2tt=L["d/common/spellschool/tt"],
	a3l=L["d/common/un/l"],a3dv="target",a3tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellAppliedBonusDamage(%q,%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellAppliedBonusDamage")', text=L["d/spell/GetSpellAppliedBonusDamage"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellAppliedBonusDPS=function(spell, spellTreeID, baseticktime, unit)
 	local lCritChance  = Nemo.GetSpellAppliedCritPercent(spell, spellTreeID, unit) or 0
	local lBonusDamage = Nemo.GetSpellAppliedBonusDamage(spell, spellTreeID, unit) or 0
	local lTickTime    = Nemo.GetSpellTickTimeOnUnit(spell, baseticktime, unit) or 0
	--Spell power base and spell power coeffecient are not dynamic so there is no need to include them in this bonus DPS calculation
	if ( lTickTime > 0 ) then
		return ( lBonusDamage * (1 + 1 * lCritChance / 100) / lTickTime )
	else
		return 0
	end
end
Nemo.D.criteria["d/spell/GetSpellAppliedBonusDPS"]={
	a=4,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/spellschool/l"],a2dv="6",a2tt=L["d/common/spellschool/tt"],
	a3l=L["d/common/ticktime/l"],a3dv="2",a3tt=L["d/common/ticktime/tt"],
	a4l=L["d/common/un/l"],a4dv="target",a4tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellAppliedBonusDPS(%q,%s,%s,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellAppliedBonusDPS")', text=L["d/spell/GetSpellAppliedBonusDPS"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellAppliedCritPercent=function(spell, spellTreeID, unit)
	local lspellID = Nemo.GetSpellID(spell)
	local lunitGUID = UnitGUID(unit)
	if ( lspellID and lunitGUID and spellTreeID and Nemo.D.P.TS[lspellID..':'..lunitGUID] ) then
		return Nemo.D.P.TS[lspellID..':'..lunitGUID].smcc[tostring(spellTreeID)]
	else
		return 0
	end
end
Nemo.D.criteria["d/spell/GetSpellAppliedCritPercent"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/spellschool/l"],a2dv="6",a2tt=L["d/common/spellschool/tt"],
	a3l=L["d/common/un/l"],a3dv="target",a3tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellAppliedCritPercent(%q,%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellAppliedCritPercent")', text=L["d/spell/GetSpellAppliedCritPercent"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellAppliedDuration=function(spell, unit, filter)
	Nemo.D.ResetDebugTimer()
	local lSpellName	= Nemo.GetSpellName(spell)
	local lDuration		= select(6, UnitDebuff(unit, lSpellName, nil, filter))
	if ( lDuration == nil ) then lDuration = select(6, UnitBuff(unit, lSpellName, nil, filter)) or 0 end
	if ( lDuration < 0 ) then lDuration = 0 end
	Nemo.AppendCriteriaDebug( 'GetSpellAppliedDuration(spell='..tostring(spell)..',unit='..tostring(unit)..')='..tostring(lDuration) )
	return lDuration
end
Nemo.D.criteria["d/spell/GetSpellAppliedDuration"]={
	a=4,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/un/l"],a2dv="target",a2tt=L["d/common/un/tt"],
	a3l=L["d/common/co/l"],a3dv=">",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/seconds/l"],a4dv="15",a4tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetSpellAppliedDuration(%q,%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellAppliedDuration")', text=L["d/spell/GetSpellAppliedDuration"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellAppliedHastePercent=function(spell, unit)
	Nemo.D.ResetDebugTimer()
	local lspellID = Nemo.GetSpellID(spell)
	local lunitGUID = UnitGUID(unit)
	local lReturn = 0
	if ( lspellID and lunitGUID and Nemo.D.P.TS[lspellID..':'..lunitGUID] ) then
		lReturn = Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh or 0		--smsh=spell modifier spell haste
	end
	Nemo.AppendCriteriaDebug( 'GetSpellAppliedHastePercent(spell='..tostring(spell)..',unit='..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellAppliedHastePercent"]={
	a=2,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/un/l"],a2dv="target",a2tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellAppliedHastePercent(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellAppliedHastePercent")', text=L["d/spell/GetSpellAppliedHastePercent"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellCurrentBonusDPS=function(spell, spellTreeID, baseticktime)
 	local lCritChance  	= GetSpellCritChance(spellTreeID) or 0
	local lBonusDamage 	= GetSpellBonusDamage(spellTreeID) or 0
	local lHaste 		= ( 1 + ( UnitSpellHaste("player") / 100 ) )
	local lTickTime    	= ( baseticktime / lHaste ) or 0

	--Spell power base and spell power coeffecient are not dynamic so there is no need to include them in this bonus DPS calculation
	if ( lTickTime > 0 ) then
		return ( lBonusDamage * (1 + 1 * lCritChance / 100) / lTickTime )
	else
		return 0
	end
end
Nemo.D.criteria["d/spell/GetSpellCurrentBonusDPS"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/spellschool/l"],a2dv="6",a2tt=L["d/common/spellschool/tt"],
	a3l=L["d/common/ticktime/l"],a3dv="2",a3tt=L["d/common/ticktime/tt"],
	f=function () return format('Nemo.GetSpellCurrentBonusDPS(%q,%s,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellCurrentBonusDPS")', text=L["d/spell/GetSpellCurrentBonusDPS"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellCastTime=function(spell)
	Nemo.D.ResetDebugTimer()
	local lReturn = Nemo:NilToNumeric( select(7, GetSpellInfo( Nemo.GetSpellID( spell ) ) ) ) / 1000
	if ( lReturn < 0 ) then lReturn = 0 end -- Serpent sting returned -100000000 cast time so need this protection
	Nemo.AppendCriteriaDebug( 'GetSpellCastTime(spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellCastTime"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/seconds/l"],a3dv="2.5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetSpellCastTime(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellCastTime")', text=L["d/spell/GetSpellCastTime"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellCharges=function(spell)
	return GetSpellCharges( Nemo.GetSpellID(spell) ) or 0
end
Nemo.D.criteria["d/spell/GetSpellCharges"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv="==",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/charges/l"],a3dv="2",a3tt=L["d/common/charges/tt"],
	f=function () return format('Nemo.GetSpellCharges(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellCharges")', text=L["d/spell/GetSpellCharges"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellCooldown=function(spell)
	Nemo.D.ResetDebugTimer()
	local startSCD, inSCD = GetSpellCooldown( spell or 0 )
	local SCDleft = Nemo:NilToNumeric( Nemo:NilToNumeric( startSCD ) + Nemo:NilToNumeric( inSCD ) - GetTime() )
	if SCDleft < 0 then SCDleft = 0	end	
	--Nemo.AppendCriteriaDebug( 'GetSpellCooldown(spell='..tostring(spell)..')='..tostring(SCDleft) ) -- Something with converting numeric to string is causing memory leak
	Nemo.AppendCriteriaDebug( 'GetSpellCooldown(spell='..tostring(spell)..')=' )
	return SCDleft
end
Nemo.D.criteria["d/spell/GetSpellCooldown"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/seconds/l"],a3dv="2.5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetSpellCooldown(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellCooldown")', text=L["d/spell/GetSpellCooldown"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellCooldownLessThanGCD=function(spell)
	Nemo.D.ResetDebugTimer()
	local GCD = Nemo.GetSpellCooldown(L[Nemo.D.PClass..'_GCD_SPELL'])
	local SCD = Nemo.GetSpellCooldown(spell)
	local lReturn = false
	if SCD <= (GCD+1) then
		lReturn = true
	else
		lReturn = false
	end
	Nemo.AppendCriteriaDebug( 'GetSpellCooldownLessThanGCD(spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellCooldownLessThanGCD"]={
	a=1,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetSpellCooldownLessThanGCD(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellCooldownLessThanGCD")', text=L["d/spell/GetSpellCooldownLessThanGCD"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellDamage=function(spell) -- Returns tooltipinitialdamagehit, tooltiptickamount, tooltipticktime, isdot
	local tooltipinitialdamagehit	= 0
	local tooltiptickamount 		= 0
	local tooltipticktime 			= 0
	local lIsDot					= false
	if ( Nemo.D.SpellInfo[spell] and Nemo:NilToNumeric(Nemo.D.SpellInfo[spell].tooltipinitialdamagehit,0) > 0 ) then -- check the nemo spellDB first for spell damage
		tooltipinitialdamagehit = Nemo.D.SpellInfo[spell].tooltipinitialdamagehit or 0
		tooltiptickamount		= Nemo.D.SpellInfo[spell].tooltiptickamount or 0
		tooltipticktime 		= Nemo.D.SpellInfo[spell].tooltipticktime or 0
	else
		local lSpellID 					= Nemo.GetSpellID( spell )
		if ( lSpellID ) then
			local lDes = GetSpellDescription(lSpellID)
			NemoTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			NemoTooltip:SetSpellByID(lSpellID)
			local lParsedLine = nil
			local lSpellFound = false
			for _ttline = 1, NemoTooltip:NumLines() do
				if ( _G["NemoTooltipTextLeft".._ttline] ) then lParsedLine = ""..(_G["NemoTooltipTextLeft".._ttline]:GetText() or ""); end
				if ( _G["NemoTooltipTextRight".._ttline] ) then lParsedLine = lParsedLine..(_G["NemoTooltipTextRight".._ttline]:GetText() or ""); end
				if ( not Nemo:isblank( lParsedLine ) ) then
-- print('GetSpellDamage lParsedLine['..lSpellID..']='..lParsedLine)
					lIsDot			= string.find( lParsedLine, 'every%s[%d%.,]+%ssec' )
					tooltipticktime	= string.match( lParsedLine, 'every%s([%d%.,]+)%ssec' )
					if ( lIsDot ) then


					else
						tooltipinitialdamagehit	= string.match( lParsedLine, 'Deal%s([%d%.,]+)%s[%w_]+%sdamage' )
					end
				end
			end

			tooltipinitialdamagehit = Nemo:NilToNumeric(string.gsub( tooltipinitialdamagehit or '', ',', '' ), 0)	-- remove commas and return a numeric value
			tooltiptickamount 		= Nemo:NilToNumeric(string.gsub( tooltiptickamount or '', ',', '' ), 0)
			tooltipticktime 		= Nemo:NilToNumeric(string.gsub( tooltipticktime or '', ',', '' ), 0)

-- print( "  tooltipinitialdamagehit="..tostring(tooltipinitialdamagehit) )
-- print( "  tooltiptickamount="..tostring(tooltiptickamount) )
-- print( "  tooltipticktime="..tostring(tooltipticktime) )


			NemoTooltip:Hide()
		end
	end
	return tooltipinitialdamagehit, tooltiptickamount, tooltipticktime
end
Nemo.D.criteria["d/spell/GetSpellDamage"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="3",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetSpellDamage(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellDamage")', text=L["d/spell/GetSpellDamage"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellInRangeOfUnit=function(spell, unit)
	Nemo.D.ResetDebugTimer()
	local lReturn = false
	if ( UnitExists(unit) ) then
		lReturn = (IsSpellInRange( Nemo.GetSpellName(spell),unit)==1)
	end
	Nemo.AppendCriteriaDebug( 'GetSpellInRangeOfUnit(spell='..tostring(spell)..",unit="..tostring(unit)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellInRangeOfUnit"]={
	a=2,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/un/l"],a2dv="target",a2tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellInRangeOfUnit(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellInRangeOfUnit")', text=L["d/spell/GetSpellInRangeOfUnit"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellIsUsable=function(spell)
	Nemo.D.ResetDebugTimer()
	local lSID = Nemo.GetSpellID(spell)
	local lReturn = false
	
	if ( lSID and IsPlayerSpell(lSID) ) then		
		lReturn = IsUsableSpell( lSID )
	end
	
	Nemo.AppendCriteriaDebug( 'GetSpellIsUsable(spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellIsUsable"]={
	a=1,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetSpellIsUsable(%q)', Nemo.UI["ebArg1"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellIsUsable")', text=L["d/spell/GetSpellIsUsable"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellLastCasted=function(spell)
	Nemo.D.ResetDebugTimer()
	local lReturn = false
	if ( Nemo.GetSpellID( Nemo.D.lastcastedspellid ) == Nemo.GetSpellID( spell ) ) then
		lReturn = true
	end
	Nemo.AppendCriteriaDebug( 'GetSpellLastCasted(spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellLastCasted"]={
	a=1,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetSpellLastCasted(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellLastCasted")', text=L["d/spell/GetSpellLastCasted"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellLastCastedElapsed=function(spell)
	Nemo.D.ResetDebugTimer()
	local lReturn = 999999
	local sSpellID = Nemo.GetSpellID(spell)
	if ( sSpellID and Nemo.D.SpellInfo[sSpellID] and Nemo.D.SpellInfo[sSpellID].lastcastedtime ) then
		lReturn = ( GetTime()-Nemo.D.SpellInfo[sSpellID].lastcastedtime )
	end
	Nemo.AppendCriteriaDebug( 'GetSpellLastCastedElapsed(spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellLastCastedElapsed"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/seconds/l"],a3dv="2.5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetSpellLastCastedElapsed(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellLastCastedElapsed")', text=L["d/spell/GetSpellLastCastedElapsed"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellPowerCost=function(spell)
	return Nemo:NilToNumeric( select(4, GetSpellInfo( Nemo.GetSpellID( spell ) ) ) )
end
Nemo.D.criteria["d/spell/GetSpellPowerCost"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="3",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetSpellPowerCost(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellPowerCost")', text=L["d/spell/GetSpellPowerCost"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellRechargeTimeRemaining=function( spell )
	local _,_,cdStart, cdDuration = GetSpellCharges( Nemo.GetSpellID(spell) )
	if ( cdStart and cdDuration and cdStart<GetTime() ) then
		local lEndTime = cdStart + cdDuration
		return ( lEndTime - GetTime() )
	else
		return 0
	end
end
Nemo.D.criteria["d/spell/GetSpellRechargeTimeRemaining"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/seconds/l"],a3dv="2.5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetSpellRechargeTimeRemaining(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellRechargeTimeRemaining")', text=L["d/spell/GetSpellRechargeTimeRemaining"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellAddTicksOnUnit=function(spell, unit, baseduration, baseticktime)
	local lspellID = Nemo.GetSpellID(spell)
	local lunitGUID = UnitGUID(unit)
	if ( not baseticktime ) then if ( Nemo.D.SpellInfo[spell] and Nemo.D.SpellInfo[spell].baseticktime ) then baseticktime = Nemo.D.SpellInfo[spell].baseticktime; else baseticktime = 2; end end
	if ( lspellID and lunitGUID and Nemo.D.P.TS[lspellID..':'..lunitGUID] and Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh ) then
		local lHaste = (1 + Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh )
-- print(" baseduration="..baseduration)
-- print(" baseticktime="..baseticktime)
-- print(" Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh="..Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh)
-- print(" lHaste="..lHaste)
		return math.ceil( baseduration / ( baseticktime / lHaste ) )
	else
		return 0
	end
end
Nemo.D.criteria["d/spell/GetSpellAddTicksOnUnit"]={
	a=4,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/un/l"],a2dv="target",a2tt=L["d/common/un/tt"],
	a3l=L["d/common/baseduration/l"],a3dv="90",a3tt=L["d/common/baseduration/tt"],
	a4l=L["d/common/ticktime/l"],a4dv="15",a4tt=L["d/common/ticktime/tt"],
	f=function () return format('Nemo.GetSpellAddTicksOnUnit(%q,%q,%s,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellAddTicksOnUnit")', text=L["d/spell/GetSpellAddTicksOnUnit"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellTickTimeOnUnit=function(spell, baseticktime, unit)
	local lspellID = Nemo.GetSpellID(spell)
	local lunitGUID = UnitGUID(unit)
	local lHaste = 1
	local lBaseTickTime = baseticktime or 2
	if ( Nemo.D.SpellInfo[spell] and Nemo.D.SpellInfo[spell].baseticktime ) then
		lBaseTickTime = Nemo.D.SpellInfo[spell].baseticktime
	end
	if ( lspellID and lunitGUID and Nemo.D.P.TS[lspellID..':'..lunitGUID] and Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh ) then
		lHaste = ( lHaste + Nemo.D.P.TS[lspellID..':'..lunitGUID].smsh )
	end
	return lBaseTickTime / lHaste
end
Nemo.D.criteria["d/spell/GetSpellTickTimeOnUnit"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/ticktime/l"],a2dv="15",a2tt=L["d/common/ticktime/tt"],
	a3l=L["d/common/un/l"],a3dv="target",a3tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellTickTimeOnUnit(%q,%s,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellTickTimeOnUnit")', text=L["d/spell/GetSpellTickTimeOnUnit"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellTotalTicksOnUnit=function(spell, baseticktime, unit)
	local lspellID = Nemo.GetSpellID(spell)
	local lunitGUID = UnitGUID(unit)
	local lspellDuration = 0
	if ( not baseticktime ) then if ( Nemo.D.SpellInfo[spell] and Nemo.D.SpellInfo[spell].baseticktime ) then baseticktime = Nemo.D.SpellInfo[spell].baseticktime; else baseticktime = 2; end end
	if ( lspellID and lunitGUID and Nemo.D.P.TS[lspellID..':'..lunitGUID] ) then
		local lTickTime = Nemo.GetSpellTickTimeOnUnit(spell, baseticktime, unit)
		local lAuraType = Nemo.D.P.TS[lspellID..':'..lunitGUID].atype
		if ( lAuraType and lAuraType == Nemo.D.AuraTypes["DEBUFF"] ) then
			lspellDuration = select(6, UnitDebuff("target", Nemo.GetSpellName(lspellID), nil, "PLAYER") );
			if ( lspellDuration ) then return math.ceil( lspellDuration / lTickTime ) end
		elseif ( lAuraType and lAuraType == Nemo.D.AuraTypes["BUFF"] ) then
			lspellDuration = select(6, UnitBuff("target", Nemo.GetSpellName(lspellID), nil, "PLAYER") )
			if ( lspellDuration ) then return math.ceil( lspellDuration / lTickTime ) end
		end
	end
	return 0
end
Nemo.D.criteria["d/spell/GetSpellTotalTicksOnUnit"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/ticktime/l"],a2dv="2",a2tt=L["d/common/ticktime/tt"],
	a3l=L["d/common/un/l"],a3dv="target",a3tt=L["d/common/un/tt"],
	f=function () return format('Nemo.GetSpellTotalTicksOnUnit(%q,%s,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellTotalTicksOnUnit")', text=L["d/spell/GetSpellTotalTicksOnUnit"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellTravelTime=function( spell )
	Nemo.D.ResetDebugTimer()
	local lReturn = 0
	local sSpellID = Nemo.GetSpellID(spell)
	if ( sSpellID and Nemo.D.SpellInfo[sSpellID] ) then
		lReturn = Nemo.D.SpellInfo[sSpellID].traveltime or 0
	end
	Nemo.AppendCriteriaDebug( 'GetSpellTravelTime(spell='..tostring(spell)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/spell/GetSpellTravelTime"]={
	a=1,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.GetSpellTravelTime(%q)', Nemo.UI["ebArg1"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/GetSpellTravelTime")', text=L["d/spell/GetSpellTravelTime"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.SetSpellInfo=function( spell, attribute, value)
	local sSpellID = Nemo.LibSimcraftParser.SetSpellInfo(Nemo.D.SpellInfo, nil, spell)
	if ( sSpellID ) then
		Nemo.D.SpellInfo[sSpellID][attribute] = value
		return true
	else
		return false
	end
end
Nemo.D.criteria["d/spell/SetSpellInfo"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/attribute/l"],a2dv='',a2tt=L["d/common/attribute/tt"],
	a3l=L["d/common/value/l"],a3dv='',a3tt=L["d/common/value/tt"],
	f=function () return format('Nemo.SetSpellInfo(%q,%q,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/SetSpellInfo")', text=L["d/spell/SetSpellInfo"] } )

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.SetSpellTravelTime=function( startspell, endspell )
	local sStartID	= Nemo.LibSimcraftParser.SetSpellInfo(Nemo.D.SpellInfo, nil, startspell)
	local sEndID	= Nemo.LibSimcraftParser.SetSpellInfo(Nemo.D.SpellInfo, nil, endspell)
-- Nemo:dprint("SetSpellTravelTime sEndID="..tostring(sEndID))
	if ( sStartID and Nemo.D.SpellInfo[sStartID] and sEndID and Nemo.D.SpellInfo[sEndID] ) then
-- Nemo:dprint("SetSpellTravelTime setting endspell="..Nemo.D.SpellInfo[sEndID].spellid.." travelstartspell="..Nemo.D.SpellInfo[sStartID].spellid)
		Nemo.D.SpellInfo[sEndID].travelstartspell = Nemo.D.SpellInfo[sStartID].spellid
		return true
	else
		return false
	end
end
Nemo.D.criteria["d/spell/SetSpellTravelTime"]={
	a=2,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/sp/l"],a2dv=L["d/common/sp/dv"],a2tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.SetSpellTravelTime(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[SPELL_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/spell/SetSpellTravelTime")', text=L["d/spell/SetSpellTravelTime"] } )
end
--********************************************************************************************
--CLASS CRITERIA
--********************************************************************************************
Nemo.D.InitCriteriaClassTree=function()
	Nemo.D.class = {}
	--COMMON CLASS CRITERIA--------------------------------------------------------------------------------------------------
		Nemo.GetWeaponEnchant=function(slot, spell)
			spell = Nemo.GetSpellName( spell )
			local hasMainHandEnchant, _, _, hasOffHandEnchant, _, _, hasThrownEnchant, _, _ = GetWeaponEnchantInfo()
			if ( slot and strlower(slot) == 'mainhand' ) then
				slot = 16
				if ( not hasMainHandEnchant) then return false end
			elseif ( slot and strlower(slot) == 'offhand' ) then
				slot = 17
				if ( not hasOffHandEnchant) then return false end
			elseif ( slot and strlower(slot) == 'thrown' ) then
				slot = 18
				if ( not hasThrownEnchant) then return false end
			end
			NemoTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			NemoTooltip:SetInventoryItem("player", slot)
			local _parsedline = nil
			local lSpellFound = false
			for _ttline = 1, NemoTooltip:NumLines() do
				if ( _G["NemoTooltipTextLeft".._ttline] ) then _parsedline = ""..(_G["NemoTooltipTextLeft".._ttline]:GetText() or ""); end
				if ( _G["NemoTooltipTextRight".._ttline] ) then _parsedline = _parsedline..(_G["NemoTooltipTextRight".._ttline]:GetText() or ""); end
				if ( not Nemo:isblank( _parsedline ) and strfind(_parsedline, spell) ) then lSpellFound = true; break end
			end
			NemoTooltip:Hide()
			return lSpellFound
		end
		Nemo.D.criteria["d/class/common/GetEnergy"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/energy/l"],a2dv="5",a2tt=L["d/common/energy/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_ENERGY)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		Nemo.D.criteria["d/class/common/GetEnergyTimeToMax"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/seconds/l"],a2dv="5",a2tt=L["d/common/seconds/tt"],
			f=function () return format('Nemo.D.P["SPELL_POWER_ENERGY"].ttm%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		Nemo.D.criteria["d/class/common/GetEnergyRegenRate"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/count/l"],a2dv="15",a2tt=L["d/common/count/tt"],
			f=function () return format('Nemo.D.P["SPELL_POWER_ENERGY"].pgr%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		Nemo.D.criteria["d/class/common/GetComboPoints"]={--Combo points
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/combopoints/l"],a2dv="4",a2tt=L["d/common/combopoints/tt"],
			f=function () return format('GetComboPoints("player","target")%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		Nemo.D.criteria["d/class/common/GetWeaponEnchant"]={--Get weapon enchant
			a=2,
			a1l=L["d/common/ws/l"],a1dv="mainhand",a1tt=L["d/common/ws/tt"],
			a2l=L["d/common/sp/l"],a2dv=32910,a2tt=L["d/common/sp/tt"],
			f=function () return format('Nemo.GetWeaponEnchant(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
	if (Nemo.D.PClass == "DEATHKNIGHT") then---------------------------------------------------------------------------------
		if ( not Nemo.D.class.dk ) then Nemo.D.class.dk = {} end
		Nemo.GetRuneCounts=function()
			Nemo.D.class.dk.bloodrunes  = 0;Nemo.D.class.dk.unholyrunes = 0;Nemo.D.class.dk.frostrunes  = 0;Nemo.D.class.dk.deathrunes  = 0
			for i = 1, 6 do
				local start, duration, runeReady = GetRuneCooldown(i)
				if (GetRuneType(i) == 1 and runeReady) then
					Nemo.D.class.dk.bloodrunes = Nemo.D.class.dk.bloodrunes + 1
				elseif (GetRuneType(i) == 2 and runeReady) then
					Nemo.D.class.dk.unholyrunes = Nemo.D.class.dk.unholyrunes + 1
				elseif (GetRuneType(i) == 3 and runeReady) then
					Nemo.D.class.dk.frostrunes = Nemo.D.class.dk.frostrunes + 1
				elseif (GetRuneType(i) == 4 and runeReady) then
					Nemo.D.class.dk.deathrunes = Nemo.D.class.dk.deathrunes + 1
				end
			end
		end
		--------------------------------------------------------------------------------------
		Nemo.GetDeathStrikeHealPercent=function()
			Nemo.D.ResetDebugTimer()
			local lAmount = 7 * (1 + .2 * Nemo.GetUnitHasBuffNameStacks("player", 50421) )
			Nemo.AppendCriteriaDebug( 'GetDeathStrikeHealPercent()='..tostring(lAmount) )	
			return lAmount
		end
		Nemo.D.criteria["d/class/deathknight/GetDeathStrikeHealPercent"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/count/l"],a2dv="0",a2tt=L["d/common/count/tt"],
			f=function () return format('Nemo.GetDeathStrikeHealPercent()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetDeathStrikeHealPercent")', text=L["d/class/deathknight/GetDeathStrikeHealPercent"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetGhoulExists=function()
			Nemo.D.ResetDebugTimer()
			local haveGhoul, name, startTime, duration, icon = GetTotemInfo(1)
			Nemo.AppendCriteriaDebug( 'GetGhoulExists()='..tostring(haveGhoul) )	
			return haveGhoul
		end
		Nemo.D.criteria["d/class/deathknight/GetGhoulExists"]={
			a=0,
			f=function () return 'Nemo.GetGhoulExists()' end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetGhoulExists")', text=L["d/class/deathknight/GetGhoulExists"] } )
		--------------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/deathknight/GetRunicPower"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv="<=",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/deathknight/rp"],a2dv="76",a2tt=L["d/class/deathknight/rptt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_RUNIC_POWER)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetRunicPower")', text=L["d/class/deathknight/GetRunicPower"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetRuneSlotCooldown=function(slot)
			local cdStart, cdDuration, runeReady = GetRuneCooldown(slot)
			local lEndTime = 0
			if ( Nemo:NilToNumeric( cdStart, 0) > 0 ) then lEndTime = (cdStart + cdDuration) end
			if ( runeReady ) then
				return 0
			elseif ( lEndTime >  GetTime() ) then
				return (lEndTime - GetTime())
			else
				return 0
			end
		end
		Nemo.D.criteria["d/class/deathknight/GetRuneSlotCooldown"]={
			a=3,
			a1l=L["d/class/deathknight/runeslot/l"],a1dv="1",a1tt=L["d/class/deathknight/runeslot/tt"],
			a2l=L["d/common/co/l"],a2dv="<",a2tt=L["d/common/co/tt"],
			a3l=L["d/common/seconds/l"],a3dv="1",a3tt=L["d/common/seconds/tt"],
			f=function () return format('Nemo.GetRuneSlotCooldown(%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetRuneSlotCooldown")', text=L["d/class/deathknight/GetRuneSlotCooldown"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetBloodRuneCooldown=function()
			local cdStart, cdDuration, rune1Ready = GetRuneCooldown(1)
			local lEndTime = 0
			if ( Nemo:NilToNumeric( cdStart, 0) > 0 ) then lEndTime = (cdStart + cdDuration) end
			cdStart,cdDuration,rune2Ready = GetRuneCooldown(2)
			if ( Nemo:NilToNumeric( cdStart, 0) > 0 and (cdStart + cdDuration) < lEndTime ) then lEndTime = (cdStart + cdDuration) end
			if ( rune1Ready or rune2Ready ) then
				return 0
			elseif ( lEndTime > 0 ) then
				return lEndTime - GetTime()
			else
				return 0
			end
		end
		Nemo.D.criteria["d/class/deathknight/GetBloodRuneCooldown"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/seconds/l"],a2dv="2",a2tt=L["d/common/seconds/tt"],
			f=function () return format('Nemo.GetBloodRuneCooldown()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetBloodRuneCooldown")', text=L["d/class/deathknight/GetBloodRuneCooldown"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetBloodRuneCount=function()
			Nemo.D.ResetDebugTimer()
			Nemo.GetRuneCounts()
			Nemo.AppendCriteriaDebug( 'GetBloodRuneCount()='..tostring(Nemo.D.class.dk.bloodrunes) )	
			return Nemo.D.class.dk.bloodrunes
		end
		Nemo.D.criteria["d/class/deathknight/GetBloodRuneCount"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/deathknight/br"],a2dv="1",a2tt=L["d/class/deathknight/brtt"],
			f=function () return format('Nemo.GetBloodRuneCount()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetBloodRuneCount")', text=L["d/class/deathknight/GetBloodRuneCount"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetFrostRuneCooldown=function()
			local cdStart, cdDuration, rune1Ready = GetRuneCooldown(3)
			local lEndTime = 0
			if ( Nemo:NilToNumeric( cdStart, 0) > 0 ) then lEndTime = (cdStart + cdDuration) end
			cdStart,cdDuration,rune2Ready = GetRuneCooldown(4)
			if ( Nemo:NilToNumeric( cdStart, 0) > 0 and (cdStart + cdDuration) < lEndTime ) then lEndTime = (cdStart + cdDuration) end
			if ( rune1Ready or rune2Ready ) then
				return 0
			elseif ( lEndTime > 0 ) then
				return lEndTime - GetTime()
			else
				return 0
			end
		end
		Nemo.D.criteria["d/class/deathknight/GetFrostRuneCooldown"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/seconds/l"],a2dv="2",a2tt=L["d/common/seconds/tt"],
			f=function () return format('Nemo.GetFrostRuneCooldown()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetFrostRuneCooldown")', text=L["d/class/deathknight/GetFrostRuneCooldown"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetFrostRuneCount=function() Nemo.GetRuneCounts();return Nemo.D.class.dk.frostrunes end
		Nemo.D.criteria["d/class/deathknight/GetFrostRuneCount"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/deathknight/fr"],a2dv="1",a2tt=L["d/class/deathknight/frtt"],
			f=function () return format('Nemo.GetFrostRuneCount()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetFrostRuneCount")', text=L["d/class/deathknight/GetFrostRuneCount"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetUnholyRuneCooldown=function()
			local cdStart, cdDuration, rune1Ready = GetRuneCooldown(5)
			local lEndTime = 0
			if ( Nemo:NilToNumeric( cdStart, 0) > 0 ) then lEndTime = (cdStart + cdDuration) end
			cdStart,cdDuration,rune2Ready = GetRuneCooldown(6)
			if ( Nemo:NilToNumeric( cdStart, 0) > 0 and (cdStart + cdDuration) < lEndTime ) then lEndTime = (cdStart + cdDuration) end
			if ( rune1Ready or rune2Ready ) then
				return 0
			elseif ( lEndTime > 0 ) then
				return lEndTime - GetTime()
			else
				return 0
			end
		end
		Nemo.D.criteria["d/class/deathknight/GetUnholyRuneCooldown"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/seconds/l"],a2dv="2",a2tt=L["d/common/seconds/tt"],
			f=function () return format('Nemo.GetUnholyRuneCooldown()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetUnholyRuneCooldown")', text=L["d/class/deathknight/GetUnholyRuneCooldown"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetUnholyRuneCount=function() Nemo.GetRuneCounts();return Nemo.D.class.dk.unholyrunes end
		Nemo.D.criteria["d/class/deathknight/GetUnholyRuneCount"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/deathknight/ur"],a2dv="1",a2tt=L["d/class/deathknight/urtt"],
			f=function () return format('Nemo.GetUnholyRuneCount()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetUnholyRuneCount")', text=L["d/class/deathknight/GetUnholyRuneCount"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetDeathRuneCount=function() Nemo.GetRuneCounts();return Nemo.D.class.dk.deathrunes end
		Nemo.D.criteria["d/class/deathknight/GetDeathRuneCount"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/deathknight/dr"],a2dv="1",a2tt=L["d/class/deathknight/drtt"],
			f=function () return format('Nemo.GetDeathRuneCount()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetDeathRuneCount")', text=L["d/class/deathknight/GetDeathRuneCount"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetTotalRuneCount=function()
			local lTotal = 0
			for i = 1, 6 do
				local _,_, runeReady = GetRuneCooldown(i)
				if ( runeReady ) then
					lTotal  = lTotal + 1
				end
			end
			return lTotal
		end
		Nemo.D.criteria["d/class/deathknight/GetTotalRuneCount"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/deathknight/dr"],a2dv="1",a2tt=L["d/class/deathknight/drtt"],
			f=function () return format('Nemo.GetTotalRuneCount()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetTotalRuneCount")', text=L["d/class/deathknight/GetTotalRuneCount"] } )
		--------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------
		Nemo.GetTotalDepletedRunes=function()
			local lTotal = 0

			local _,_,rune1Ready = GetRuneCooldown(1)
			local _,_,rune2Ready = GetRuneCooldown(2)
			if ( not rune1Ready and not rune2Ready ) then lTotal = lTotal + 1 end
			_,_,rune1Ready = GetRuneCooldown(3)
			_,_,rune2Ready = GetRuneCooldown(4)
			if ( not rune1Ready and not rune2Ready ) then lTotal = lTotal + 1 end
			_,_,rune1Ready = GetRuneCooldown(5)
			_,_,rune2Ready = GetRuneCooldown(6)
			if ( not rune1Ready and not rune2Ready ) then lTotal = lTotal + 1 end
			return lTotal
		end
		Nemo.D.criteria["d/class/deathknight/GetTotalDepletedRunes"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">=",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/deathknight/dr"],a2dv="1",a2tt=L["d/class/deathknight/drtt"],
			f=function () return format('Nemo.GetTotalDepletedRunes()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/deathknight/GetTotalDepletedRunes")', text=L["d/class/deathknight/GetTotalDepletedRunes"] } )
	elseif (Nemo.D.PClass == "DRUID") then----------------------------------------------------
		if ( not Nemo.D.class.druid ) then Nemo.D.class.druid = {} end
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetComboPoints")', text=L["d/class/common/GetComboPoints"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetEnergy")', text=L["d/class/common/GetEnergy"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetEnergyRegenRate")', text=L["d/class/common/GetEnergyRegenRate"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetEnergyTimeToMax")', text=L["d/class/common/GetEnergyTimeToMax"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetMushroomCount=function()
			Nemo.D.class.druid.mc = 0;
			for i = 1, 3 do
				local haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
				if ( haveTotem ) then
					Nemo.D.class.druid.mc = Nemo.D.class.druid.mc + 1
				end
			end
			return Nemo.D.class.druid.mc
		end
		Nemo.D.criteria["d/class/druid/GetMushroomCount"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/count/l"],a2dv="0",a2tt=L["d/common/count/tt"],
			f=function () return format('Nemo.GetMushroomCount()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/druid/GetMushroomCount")', text=L["d/class/druid/GetMushroomCount"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetEclipseDirection=function(direction)
			local lDir = GetEclipseDirection()
			if lDir == direction then
				return true
			else
				return false
			end
		end
		Nemo.D.criteria["d/class/druid/GetEclipseDirection"]={
			a=1,
			a1l=L["d/common/eclipse/l"],a1dv="moon",a1tt=L["d/common/eclipse/tt"],
			f=function () return format('Nemo.GetEclipseDirection(%q)', Nemo.UI["ebArg1"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/druid/GetEclipseDirection")', text=L["d/class/druid/GetEclipseDirection"] } )
	elseif (Nemo.D.PClass == "HUNTER") then---------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/hunter/GetFocus"]={--Focus
			a=2,
			a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/focus/l"],a2dv="50",a2tt=L["d/common/focus/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_FOCUS)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/hunter/GetFocus")', text=L["d/class/hunter/GetFocus"] } )
	elseif (Nemo.D.PClass == "MAGE") then---------------------------------------------------------------------------------

	elseif (Nemo.D.PClass == "MONK") then---------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetEnergy")', text=L["d/class/common/GetEnergy"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetEnergyTimeToMax")', text=L["d/class/common/GetEnergyTimeToMax"] } )
		--------------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/monk/GetChi"]={--Chi
			a=2,
			a1l=L["d/common/co/l"],a1dv="<",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/monk/GetChi/l"],a2dv="3",a2tt=L["d/class/monk/GetChi/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_CHI)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/monk/GetChi")', text=L["d/class/monk/GetChi"] } )
		--------------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/monk/GetStaggerTotal"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/monk/stagger/l"],a2dv=L["d/class/monk/stagger/dv"],a2tt=L["d/class/monk/stagger/tt"],
			f=function () return format('Nemo.D.P["STAGGER"].total%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/monk/GetStaggerTotal")', text=L["d/class/monk/GetStaggerTotal"] } )
	elseif (Nemo.D.PClass == "PALADIN") then---------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/paladin/GetHolyPower"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv="==",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/count/l"],a2dv="3",a2tt=L["d/common/count/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_HOLY_POWER)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/paladin/GetHolyPower")', text=L["d/class/paladin/GetHolyPower"] } )
	elseif (Nemo.D.PClass == "PRIEST") then---------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/priest/GetShadowOrbs"]={--Shadow Orbs
			a=2,
			a1l=L["d/common/co/l"],a1dv="==",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/count/l"],a2dv="3",a2tt=L["d/common/count/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_SHADOW_ORBS)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/priest/GetShadowOrbs")', text=L["d/class/priest/GetShadowOrbs"] } )
	elseif (Nemo.D.PClass == "ROGUE") then---------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetComboPoints")', text=L["d/class/common/GetComboPoints"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetEnergy")', text=L["d/class/common/GetEnergy"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetEnergyTimeToMax")', text=L["d/class/common/GetEnergyTimeToMax"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetWeaponEnchant")', text=L["d/class/common/GetWeaponEnchant"] } )
	elseif (Nemo.D.PClass == "SHAMAN") then---------------------------------------------------------------------------------
		if ( not Nemo.D.class.shaman ) then Nemo.D.class.shaman = {} end
		Nemo.D.class.shaman.td = {}--totem data
		Nemo.D.class.shaman.td[1] = {}--Fire
		Nemo.D.class.shaman.td[2] = {}--Earth
		Nemo.D.class.shaman.td[3] = {}--Water
		Nemo.D.class.shaman.td[4] = {}--Air
		Nemo.GetMappedTotemSlotDistance=function(slot)
			local lDTT, lDX, lDY = Nemo.MD:DistanceAndDirection(Nemo.D.MapName, Nemo.D.MapFloor, Nemo:NilToNumeric(Nemo.D.class.shaman.td[slot].x, 0), Nemo:NilToNumeric(Nemo.D.class.shaman.td[slot].y, 0) )
			return lDTT
		end
		--------------------------------------------------------------------------------------
		Nemo.GetTotemSlotActive=function(slot) return GetTotemInfo(slot) end
		Nemo.D.criteria["d/class/shaman/GetTotemSlotActive"]={
			a=1,
			a1l=L["d/class/shaman/totemslot/l"],a1dv='1',a1tt=L["d/class/shaman/totemslot/tt"],
			f=function () return format('Nemo.GetTotemSlotActive(%s)', Nemo.UI["ebArg1"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/shaman/GetTotemSlotActive")', text=L["d/class/shaman/GetTotemSlotActive"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetTotemSpellActive=function(spell)
			Nemo.D.ResetDebugTimer()
			local lReturn = false
			local lSpell = Nemo.GetSpellName(spell);
			for i = 1, 4 do
				local _,totemName,_,_ = GetTotemInfo(i);
				if ( totemName and lSpell and totemName == lSpell ) then lReturn = true end
			end
			Nemo.AppendCriteriaDebug( 'GetTotemSpellActive(spell='..tostring(lSpell)..')='..tostring(lReturn) )
			return lReturn
		end
		Nemo.D.criteria["d/class/shaman/GetTotemSpellActive"]={--Get totem spell active
			a=1,
			a1l=L["d/class/shaman/totemspell/l"],a1dv='',a1tt=L["d/class/shaman/totemspell/tt"],
			f=function () return format('Nemo.GetTotemSpellActive(%s)', Nemo.UI["ebArg1"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/shaman/GetTotemSpellActive")', text=L["d/class/shaman/GetTotemSpellActive"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetTotemSlotDistance=function(slot, yards)
			local lDTT = Nemo.GetMappedTotemSlotDistance(slot)
			if ( lDTT and yards and lDTT < yards and Nemo.D.class.shaman.td[slot].x ~= 0 and Nemo.D.class.shaman.td[slot].y ~= 0 ) then
				return true
			else
				return false
			end
		end
		Nemo.D.criteria["d/class/shaman/GetTotemSlotDistance"]={
			a=2,
			a1l=L["d/class/shaman/totemslot/l"],a1dv="1",a1tt=L["d/class/shaman/totemslot/tt"],
			a2l=L["d/common/dy/l"],a2dv="10",a2tt=L["d/common/dy/tt"],
			f=function () return format('Nemo.GetTotemSlotDistance(%s,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/shaman/GetTotemSlotDistance")', text=L["d/class/shaman/GetTotemSlotDistance"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetTotemSlotTimeLeft=function(slot)
			local haveTotem, totemName, startTime, duration = GetTotemInfo(slot)
			if ( haveTotem ) then
				return ((startTime + duration) - GetTime())
			else
				return 0
			end
		end
		Nemo.D.criteria["d/class/shaman/GetTotemSlotTimeLeft"]={--Get totem time left
			a=3,
			a1l=L["d/class/shaman/totemslot/l"],a1dv="1",a1tt=L["d/class/shaman/totemslot/tt"],
			a2l=L["d/common/co/l"],a2dv="<=",a2tt=L["d/common/co/tt"],
			a3l=L["d/common/seconds/l"],a3dv="2",a3tt=L["d/common/seconds/tt"],
			f=function () return format('Nemo.GetTotemSlotTimeLeft(%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/shaman/GetTotemSlotTimeLeft")', text=L["d/class/shaman/GetTotemSlotTimeLeft"] } )
		--------------------------------------------------------------------------------------
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/common/GetWeaponEnchant")', text=L["d/class/common/GetWeaponEnchant"] } )
	elseif (Nemo.D.PClass == "WARLOCK") then---------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/warlock/GetBurningEmbers"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/warlock/burningembers/l"],a2dv='2',a2tt=L["d/class/warlock/burningembers/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_BURNING_EMBERS)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/warlock/GetBurningEmbers")', text=L["d/class/warlock/GetBurningEmbers"] } )
		--------------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/warlock/GetBurningEmbersSegs"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/warlock/burningemberss/l"],a2dv='2',a2tt=L["d/class/warlock/burningemberss/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_BURNING_EMBERS, true)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/warlock/GetBurningEmbersSegs")', text=L["d/class/warlock/GetBurningEmbersSegs"] } )
		--------------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/warlock/GetDemonicFury"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/warlock/df/l"],a2dv='2',a2tt=L["d/class/warlock/df/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_DEMONIC_FURY)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/warlock/GetDemonicFury")', text=L["d/class/warlock/GetDemonicFury"] } )
		--------------------------------------------------------------------------------------
		Nemo.GetSecondsInMetamorphosis=function()
			if ( Nemo.D.P["METAMORPHOSIS"].appliedtimestamp > 0 ) then
				return (GetTime() - Nemo.D.P["METAMORPHOSIS"].appliedtimestamp)
			end
			return 0
		end
		Nemo.D.criteria["d/class/warlock/GetSecondsInMetamorphosis"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/common/seconds/l"],a2dv="3",a2tt=L["d/common/seconds/tt"],
			f=function () return format('Nemo.GetSecondsInMetamorphosis()%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/warlock/GetSecondsInMetamorphosis")', text=L["d/class/warlock/GetSecondsInMetamorphosis"] } )
		--------------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/warlock/GetSoulShards"]={
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/warlock/soulshards/l"],a2dv='2',a2tt=L["d/class/warlock/soulshards/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_SOUL_SHARDS)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/warlock/GetSoulShards")', text=L["d/class/warlock/GetSoulShards"] } )
	elseif (Nemo.D.PClass == "WARRIOR") then---------------------------------------------------------------------------------
		Nemo.D.criteria["d/class/warrior/GetRage"]={--Rage
			a=2,
			a1l=L["d/common/co/l"],a1dv=">",a1tt=L["d/common/co/tt"],
			a2l=L["d/class/warrior/rage/l"],a2dv="110",a2tt=L["d/class/warrior/rage/tt"],
			f=function () return format('Nemo.GetUnitPower("player",SPELL_POWER_RAGE)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
		}
		tinsert( Nemo.D.criteriatree[CLASS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/class/warrior/GetRage")', text=L["d/class/warrior/GetRage"] } )
	end
	Nemo.D.UpdateMode=3 --Do not create or update objects if they exist on import
	Nemo.D.ImportClassDefaultLists()
end

--********************************************************************************************
--TALENTS CRITERIA
--********************************************************************************************
Nemo.GetTalentEnabled=function(talent)
	local lSpellID = Nemo.GetSpellID(talent)
	if ( lSpellID ) then
		for ti = 1, GetNumTalents(1) do
			name,_,_,_,selected,_=GetTalentInfo(ti, nil, GetActiveSpecGroup())
			if (name == GetSpellInfo(lSpellID) and selected) then
				return true
			end
		end
	end
	return false
end
Nemo.D.criteria["d/talents/GetTalentEnabled"]={
	a=1,
	a1l=L["d/common/ta"],a1dv=L["d/common/tadv"],a1tt=L["d/common/tatt"],
	f=function () return format('Nemo.GetTalentEnabled(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[TALENTS_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/talents/GetTalentEnabled")', text=L["d/talents/GetTalentEnabled"] } )
--********************************************************************************************
--MISC CRITERIA
--********************************************************************************************
Nemo.GetActionCriteriaState=function(action)
	Nemo.D.ResetDebugTimer()
	lReturn = false
	local NemoSABFrame = Nemo.GetActionFrame(action)
	if ( NemoSABFrame and NemoSABFrame._nemo_criteria_passed == true ) then
		lReturn = true
	end
	Nemo.AppendCriteriaDebug( 'GetActionCriteriaState(action='..tostring(action)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/misc/GetActionCriteriaState"]={
	a=1,
	a1l=L["d/misc/an/l"],a1dv='',a1tt=L["d/misc/an/tt"],
	f=function () return format('Nemo.GetActionCriteriaState(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/GetActionCriteriaState")', text=L["d/misc/GetActionCriteriaState"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetActionDisabled=function(action)
	if ( Nemo.DB.profile.options.srk and not Nemo:isblank(action) ) then
		local lAKey = Nemo:SearchTable(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children, "text", action)
		if ( lAKey and Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lAKey].dis == true ) then
			return true
		end
	end
	return false
end
Nemo.D.criteria["d/misc/GetActionDisabled"]={
	a=1,
	a1l=L["d/misc/an/l"],a1dv='',a1tt=L["d/misc/an/tt"],
	f=function () return format('Nemo.GetActionDisabled(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/GetActionDisabled")', text=L["d/misc/GetActionDisabled"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetActionTimeUntilNeeded=function( action )

	local lTimeUntilNeeded	= 999
	-- Get the secure action frame from the action parameter
	local NemoSABFrame = Nemo.GetActionFrame(action)

	if ( NemoSABFrame and NemoSABFrame._nemo_action_db ) then
		if (
			strfind( tostring(NemoSABFrame._nemo_action_db.criteria) or "", '_nemo_time_until_needed')
			or strfind( tostring(NemoSABFrame._nemo_action_db.criteria) or "", '%.SetSecondsUntilNeeded')
			) then
			lTimeUntilNeeded = NemoSABFrame._nemo_time_until_needed
		else
			if ( not Nemo:isblank(NemoSABFrame._nemo_action_db.at) and not Nemo:isblank(NemoSABFrame._nemo_action_db.att2) and NemoSABFrame._nemo_action_db.at == "spell" ) then
				lTimeUntilNeeded = Nemo.GetSpellCooldown( NemoSABFrame._nemo_action_db.att2 ) or 999
			elseif ( not Nemo:isblank(NemoSABFrame._nemo_action_db.at) and not Nemo:isblank(NemoSABFrame._nemo_action_db.att1) and NemoSABFrame._nemo_action_db.at == "item"  ) then
				lTimeUntilNeeded = Nemo.GetItemCooldown( NemoSABFrame._nemo_action_db.att1 ) or 999
			end
		end
	end
	return lTimeUntilNeeded
end
Nemo.D.criteria["d/misc/GetActionTimeUntilNeeded"]={
	a=1,
	a1l=L["d/misc/an/l"],a1dv='',a1tt=L["d/misc/an/tt"],
	f=function () return format('Nemo.GetActionTimeUntilNeeded(%q)', Nemo.UI["ebArg1"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/GetActionTimeUntilNeeded")', text=L["d/misc/GetActionTimeUntilNeeded"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetChatTextTriggered=function(text, channelname, timer)
	if ( text and not Nemo.D.P.CHAT_TRIGGERS[text] ) then
		Nemo.D.P.CHAT_TRIGGERS[text] = {}
		Nemo.D.P.CHAT_TRIGGERS[text].lut = 0	-- Last update time
		Nemo.D.P.CHAT_TRIGGERS[text].channelname = channelname
		Nemo.D.P.CHAT_TRIGGERS[text].timer = Nemo:NilToNumeric(timer)
	end
	local lElapsed = GetTime() - Nemo.D.P.CHAT_TRIGGERS[text].lut
	if ( text and Nemo.D.P.CHAT_TRIGGERS[text] and lElapsed <= Nemo.D.P.CHAT_TRIGGERS[text].timer ) then
		return true
	else
		return false
	end
end
Nemo.D.criteria["d/misc/GetChatTextTriggered"]={
	a=3,
	a1l=L["d/misc/chattext/l"],a1dv='Pulling in 1',a1tt=L["d/misc/chattext/tt"],
	a2l=L["d/misc/chatchannel/l"],a2dv=L["d/misc/chatchannel/dv"],a2tt=L["d/misc/chatchannel/tt"],
	a3l=L["d/common/seconds/l"],a3dv="5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetChatTextTriggered(%q,%q,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/GetChatTextTriggered")', text=L["d/misc/GetChatTextTriggered"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/misc/Autonomous"]={
	a=0,
	f=function () return "\n--_nemo_autonomous\n" end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/Autonomous")', text=L["d/misc/Autonomous"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/misc/ActionDisableAnotherAction"]={
	a=1,
	a1l=L["d/misc/an/l"],a1dv='',a1tt=L["d/misc/an/tt"],
	f=function ()
		local lCriteria       = "--_nemo_enable_lua\n"
		local lMacrotext      = ""
		local lDisActionName  = Nemo.UI["ebArg1"]:GetText() or ""
		lCriteria = lCriteria..format('if ( Nemo.GetActionDisabled(%q) and not Nemo.GetActionDisabled(%q) ) then Nemo.SetActionDisabled(%q) end', Nemo.UI["ebArg1"]:GetText(), Nemo.UI.DB.text, Nemo.UI.DB.text ).."\n"
		lCriteria = lCriteria..format('if ( not Nemo.GetActionDisabled(%q) and Nemo.GetActionDisabled(%q) ) then Nemo.SetActionEnabled(%q) end', Nemo.UI["ebArg1"]:GetText(), Nemo.UI.DB.text, Nemo.UI.DB.text )
		local lDisActionKey = Nemo:SearchTable(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children, "text", lDisActionName );
		local lSID
		if ( lDisActionKey and Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lDisActionKey].at == 'spell' ) then
			lSID = Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lDisActionKey].att2	-- The disable action type is a spell so use the spell id to generate a #showtooltip
		end
		lMacrotext = '#show '..tostring(lSID).."\n"
		lMacrotext = lMacrotext ..format('/run Nemo.ToggleActionDisabled(%q)', lDisActionName )
		Nemo.UI.DB.at   = 'macrotext'
		Nemo.UI.DB.att1 = lMacrotext
		Nemo.UI.DB.att2 = ''
		Nemo.UI.DB.criteria = ''
		Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.UI.STP)
		return lCriteria
	end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/ActionDisableAnotherAction")', text=L["d/misc/ActionDisableAnotherAction"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.CriteriaGroupPasses=function(actionname, ...)
	local lActionKey = Nemo:SearchTable(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children, "text", actionname )
	if ( lActionKey ) then
		local lNemoSABFrame = Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][lActionKey]
-- print( "CriteriaGroupPasses " )
		local lSuccess, lCriteriaPassed = pcall(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[lActionKey].fCriteria, ... )
-- print( "lSuccess="..tostring(lSuccess) )
		if ( lSuccess and lCriteriaPassed ) then
			return true
		end
	end
	return false
end
Nemo.D.criteria["d/misc/CriteriaGroupPasses"]={
	a=2,
	a1l=L["d/misc/an/l"],a1dv='',a1tt=L["d/misc/an/tt"],
	a2l=L["d/common/sp/l"],a2dv=L["d/common/sp/dv"],a2tt=L["d/common/sp/tt"],
	f=function () return format('Nemo.CriteriaGroupPasses(%q,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/CriteriaGroupPasses")', text=L["d/misc/CriteriaGroupPasses"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetQueueSlotGID=function(queue_slot)
	Nemo.D.ResetDebugTimer()
	lReturn = 0
	if ( Nemo.Engine.Queue[queue_slot] and Nemo.Engine.Queue[queue_slot]._nemo_gid ) then
		lReturn = Nemo.Engine.Queue[queue_slot]._nemo_gid
	end
	Nemo.AppendCriteriaDebug( 'GetQueueSlotGID(queue_slot='..tostring(queue_slot)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/misc/GetQueueSlotGID"]={
	a=3,
	a1l=L["d/common/slot/l"],a1dv="1",a1tt=L["d/common/slot/tt"],
	a2l=L["d/common/co/l"],a2dv="==",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/gid/l"],a3dv="77767",a3tt=L["d/common/gid/tt"],
	f=function () return format('Nemo.GetQueueSlotGID(%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/GetQueueSlotGID")', text=L["d/misc/GetQueueSlotGID"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetQueueSlotMatchesActionName=function(queue_slot, action_name)
	Nemo.D.ResetDebugTimer()
	lReturn = false
	if ( Nemo.Engine.Queue[queue_slot] and Nemo.Engine.Queue[queue_slot]._nemo_action_text and Nemo.Engine.Queue[queue_slot]._nemo_action_text == action_name) then
		lReturn = true
	end
	Nemo.AppendCriteriaDebug( 'GetQueueSlotMatchesActionName(queue_slot='..tostring(queue_slot)..',action_name='..tostring(action_name)..')='..tostring(lReturn) )
	return lReturn
end
Nemo.D.criteria["d/misc/GetQueueSlotMatchesActionName"]={
	a=2,
	a1l=L["d/common/count/l"],a1dv="1",a1tt=L["d/common/count/tt"],
	a2l=L["d/misc/an/l"],a2dv='',a2tt=L["d/misc/an/tt"],
	f=function () return format('Nemo.GetQueueSlotMatchesActionName(%s,%q)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/GetQueueSlotMatchesActionName")', text=L["d/misc/GetQueueSlotMatchesActionName"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/misc/DisplayQueueSlot"]={
	a=1,
	a1l=L["d/common/count/l"],a1dv="1",a1tt=L["d/common/count/tt"],
	f=function () return format("--_nemo_queue_slot %s", Nemo.UI["ebArg1"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/DisplayQueueSlot")', text=L["d/misc/DisplayQueueSlot"] } )

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/misc/LinkIconToCriteria"]={
	a=0,
	f=function () return "\n--_nemo_icon_criteria\n" end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/LinkIconToCriteria")', text=L["d/misc/LinkIconToCriteria"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/misc/CriteriaGroup"]={
	a=0,
	f=function () return "\n--_nemo_criteria_group\n" end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/CriteriaGroup")', text=L["d/misc/CriteriaGroup"] } )

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/misc/EnableLua"]={
	a=0,
	f=function () return "\n--_nemo_enable_lua\n" end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/EnableLua")', text=L["d/misc/EnableLua"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.D.criteria["d/misc/RunOnce"]={
	a=0,
	f=function () return "\n--_nemo_run_once\n" end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/RunOnce")', text=L["d/misc/RunOnce"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.SetActionValue=function( NemoSABFrame, ValueName, Value )
	if ( NemoSABFrame and ValueName) then
-- print("setting "..NemoSABFrame._nemo_action_text.." QCP="..tostring(bCriteriaPassed))
		-- if ( not NemoSABFrame[ValueName] ) then
			-- table.insert( NemoSABFrame, ValueName)
		-- end
		NemoSABFrame[ValueName] = Value
	end
	return true
end
Nemo.D.criteria["d/misc/SetActionValue"]={
	a=2,
	a1l=L["d/common/valuename/l"],a1dv="_nemo_time_until_needed",a1tt=L["d/common/valuename/tt"],
	a2l=L["d/common/value/l"],a2dv="5",a2tt=L["d/common/value/tt"],
	f=function () return format('Nemo.SetActionValue(select(1,...),%q,%s)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/SetActionValue")', text=L["d/misc/SetActionValue"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.SetCountInfo=function( NemoSABFrame, Count, Font, Size, Red, Green, Blue, Alpha )
	if ( NemoSABFrame ) then
-- print("setting "..NemoSABFrame._nemo_action_text.." QCP="..tostring(bCriteriaPassed))
		if ( Count ) then
			NemoSABFrame.GetCount=function()
				return Count
			end
		end
		if ( Font ) then --set font
		end
		if ( Size ) then --set size
		end
		if ( Red and Green and Blue and Alpha ) then --set tint
			NemoSABFrame._nemo_count_red	= Red
			NemoSABFrame._nemo_count_green	= Green
			NemoSABFrame._nemo_count_blue	= Blue
			NemoSABFrame._nemo_count_alpha	= Alpha
		else
			NemoSABFrame._nemo_count_red	= 1
			NemoSABFrame._nemo_count_green	= 1
			NemoSABFrame._nemo_count_blue	= 1
			NemoSABFrame._nemo_count_alpha	= 1
		end
	end
	return true
end
Nemo.D.criteria["d/misc/SetCountInfo"]={
	a=3,
	a1l=L["d/common/count/l"],a1dv="5",a1tt=L["d/common/count/tt"],
	a2l=L["alert/ebFontPath/l"],a2dv='Fonts\\FRIZQT__.TTF',a2tt=L["alert/ebFontPath/tt"],
	a3l=L["alert/ebFontSize/l"],a3dv="11",a3tt=L["alert/ebFontSize/tt"],
	f=function () return format('Nemo.SetCountInfo(select(1,...),%q,%q,%s,1,1,1,1)', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/SetCountInfo")', text=L["d/misc/SetCountInfo"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.SetSecondsUntilNeeded=function( NemoSABFrame, Seconds )
	Nemo.D.ResetDebugTimer()
	if ( NemoSABFrame ) then
-- print("setting "..NemoSABFrame._nemo_action_text.." Seconds="..tostring(Seconds))
		-- Equivalent to Nemo.SetActionValue(select(1,...),"_nemo_time_until_needed", Seconds)
		NemoSABFrame._nemo_time_until_needed = Seconds
	end
	Nemo.AppendCriteriaDebug( 'SetSecondsUntilNeeded(NemoSABFrame='..tostring(NemoSABFrame._nemo_action_text)..',Seconds='..tostring(Seconds)..')='..tostring(NemoSABFrame._nemo_time_until_needed) )
	return true
end
Nemo.D.criteria["d/misc/SetSecondsUntilNeeded"]={
	a=1,
	a1l=L["d/common/seconds/l"],a1dv="5",a1tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.SetSecondsUntilNeeded(select(1,...),%s)', Nemo.UI["ebArg1"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[MISC_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/misc/SetSecondsUntilNeeded")', text=L["d/misc/SetSecondsUntilNeeded"] } )

--********************************************************************************************
--GROUP CRITERIA
--********************************************************************************************
Nemo.GetHealableLowestHealthPercent=function(spell)
	local group, num
	local unitID
	local lLowestHealthPercent = 100
	local lLowestUnitID = "player"
	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	else
		return Nemo.GetUnitHealthPercent("player"), "player"
	end
	for i = 1, num do
		unitID = group..i;
		local lUnitHealthPercent = Nemo.GetUnitHealthPercent(unitID)
		if ( lUnitHealthPercent < lLowestHealthPercent and Nemo.GetSpellInRangeOfUnit(spell,unitID) ) then
			lLowestHealthPercent = lUnitHealthPercent
			lLowestUnitID = unitID
		end
	end
	return lLowestHealthPercent, lLowestUnitID
end
Nemo.D.criteria["d/group/GetHealableLowestHealthPercent"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv="<",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/pe/l"],a3dv="60",a3tt=L["d/common/pe/tt"],
	f=function () return format('Nemo.GetHealableLowestHealthPercent(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetHealableLowestHealthPercent")', text=L["d/group/GetHealableLowestHealthPercent"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetNumberOfGroupMembersWithCurableDebuffType=function(dtype)
	local group, num
	local numberofgroupmembers = 0
	local unitID
	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	elseif ( Nemo.GetUnitHasCurableDebuffType("player", dtype) ) then
		return 1
	end
	if ( group ) then
		for i = 1, num do
			unitID = group..i;
			if ( Nemo.GetUnitHasCurableDebuffType(unitID, dtype) ) then
				numberofgroupmembers = numberofgroupmembers + 1
			end
		end
	end
	return numberofgroupmembers
end
Nemo.D.criteria["d/group/GetNumberOfGroupMembersWithCurableDebuffType"]={
	a=3,
	a1l=L["d/common/debufftype/l"],a1dv=L["d/common/debufftype/dv"],a1tt=L["d/common/debufftype/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="3",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetNumberOfGroupMembersWithCurableDebuffType(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetNumberOfGroupMembersWithCurableDebuffType")', text=L["d/group/GetNumberOfGroupMembersWithCurableDebuffType"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetNumHurtPlayers=function( minpercent, distIndex )
	local group, num
	local unitID
	local lHurtCount = 0
	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	elseif ( (100 - Nemo.GetUnitHealthPercent("player")) > 0 ) then
		return 1
	end
	if ( group ) then
		for i = 1, num do
			unitID = group..i;
			local lUHealthPercentLost = 100 - Nemo.GetUnitHealthPercent(unitID)
			local bInRange = CheckInteractDistance(unitID, distIndex)
			if ( bInRange and minpercent and minpercent >= 0 and lUHealthPercentLost > minpercent ) then
				lHurtCount = lHurtCount + 1
			end
		end
	end
	return lHurtCount
end
Nemo.D.criteria["d/group/GetNumHurtPlayers"]={
	a=4,
	a1l=L["d/common/pe/l"],a1dv="10",a1tt=L["d/common/pe/tt"],
	a2l=L["d/common/di/l"],a2dv="3",a2tt=L["d/common/di/tt"],
	a3l=L["d/common/co/l"],a3dv=">",a3tt=L["d/common/co/tt"],
	a4l=L["d/common/count/l"],a4dv="5",a4tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetNumHurtPlayers(%s,%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText(), Nemo.UI["ebArg4"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetNumHurtPlayers")', text=L["d/group/GetNumHurtPlayers"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetTotalHealthLoss=function( maxlossperunit )
	local group, num
	local unitID
	local lTotalHealthLost = 0

	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	else
		return Nemo.GetUnitHealthLost("player")
	end
	if ( group ) then
		for i = 1, num do
			unitID = group..i;
			local lUHealthLost = Nemo.GetUnitHealthLost(unitID)
			if ( maxlossperunit and maxlossperunit > 0 and lUHealthLost > maxlossperunit ) then lUHealthLost = maxlossperunit end -- Cap the total health loss so you do not go over what you are capable of healing
			if ( lUHealthLost > 0 ) then
				lTotalHealthLost = lTotalHealthLost + lUHealthLost
			end
		end
	end
	return lTotalHealthLost
end
Nemo.D.criteria["d/group/GetTotalHealthLoss"]={
	a=3,
	a1l=L["d/common/he/l"],a1dv="40000",a1tt=L["d/common/he/tt"],
	a2l=L["d/common/co/l"],a2dv=">",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/he/l"],a3dv="120000",a3tt=L["d/common/he/tt"],
	f=function () return format('Nemo.GetTotalHealthLoss(%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetTotalHealthLoss")', text=L["d/group/GetTotalHealthLoss"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetTotalHealthLossWithMyBuffName=function(spell, maxlossperunit)
	Nemo.D.ResetDebugTimer()
	local group, num
	local unitID
	local lTotalHealthLost = 0

	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	elseif ( Nemo.GetUnitHasBuffName("player", spell, "PLAYER") ) then
		lTotalHealthLost = Nemo.GetUnitHealthLost("player")
	end
	if ( group ) then
		for i = 1, num do
			unitID = group..i;
			local lUHealthLost = Nemo.GetUnitHealthLost(unitID)
			if ( maxlossperunit and maxlossperunit > 0 and lUHealthLost > maxlossperunit ) then lUHealthLost = maxlossperunit end -- Cap the total health loss so you do not go over what you are capable of healing
			if ( lUHealthLost > 0 and Nemo.GetUnitHasBuffName(unitID, spell, "PLAYER") ) then
				lTotalHealthLost = lTotalHealthLost + lUHealthLost
			end
		end
	end
	Nemo.AppendCriteriaDebug( 'GetTotalHealthLossWithMyBuffName(spell='..tostring(spell)..',maxlossperunit='..tostring(maxlossperunit)..')='..tostring(lTotalHealthLost) )
	return lTotalHealthLost
end
Nemo.D.criteria["d/group/GetTotalHealthLossWithMyBuffName"]={
	a=4,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv="<",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/he/l"],a3dv="1200300",a3tt=L["d/common/he/tt"],
	a4l=L["d/common/he/l"],a4dv="30000",a4tt=L["d/common/he/tt"],
	f=function () return format('Nemo.GetTotalHealthLossWithMyBuffName(%q,%s)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg4"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetTotalHealthLossWithMyBuffName")', text=L["d/group/GetTotalHealthLossWithMyBuffName"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellOldestRaidBuffNameDuration=function(spell)
	local lOldest = 0

	--Nemo.D.P.TS[lSpellID..':'..lDestGUID]
	local lSpellID = Nemo.GetSpellID( spell )
	for k,v in pairs (Nemo.D.P.TS) do
		local lTrackedSpellID = string.match( k , '^(%d+):' )
		local lDuration = ( GetTime()-v.lat ) --last applied time
		if ( lSpellID == lTrackedSpellID and lDuration > lOldest ) then
			lOldest = lDuration
		end
	end
	return lOldest
end
Nemo.D.criteria["d/group/GetSpellOldestRaidBuffNameDuration"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/seconds/l"],a3dv="2.5",a3tt=L["d/common/seconds/tt"],
	f=function () return format('Nemo.GetSpellOldestRaidBuffNameDuration(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText()) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetSpellOldestRaidBuffNameDuration")', text=L["d/group/GetSpellOldestRaidBuffNameDuration"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellNumberOfGroupMembersApplied=function(spell)
	local group, num
	local numberofgroupmembers = 0
	local unitID
	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	elseif ( Nemo.GetUnitHasBuffName("player", spell, "PLAYER") ) then
		return 1
	end
	if ( group ) then
		for i = 1, num do
			unitID = group..i;
			if ( Nemo.GetUnitHasBuffName(unitID, spell, "PLAYER") ) then
				numberofgroupmembers = numberofgroupmembers + 1
			end
		end
	end
	return numberofgroupmembers
end
Nemo.D.criteria["d/group/GetSpellNumberOfGroupMembersApplied"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="3",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetSpellNumberOfGroupMembersApplied(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetSpellNumberOfGroupMembersApplied")', text=L["d/group/GetSpellNumberOfGroupMembersApplied"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetNumberOfGroupMembersMissingBuff=function(spell)
	Nemo.D.ResetDebugTimer()
	local group, num
	local count = 0
	local unitID
	if IsInRaid() then
		group, num = "raid", GetNumGroupMembers()
	elseif IsInGroup() then
		group, num = "party", GetNumSubgroupMembers()
	elseif ( not Nemo.GetUnitHasBuffName("player", spell, "PLAYER") ) then
		return 1
	end
	if ( group ) then
		for i = 1, num do
			unitID = group..i;
			if ( not Nemo.GetUnitHasBuffName(unitID, spell, "PLAYER") ) then
				count = count + 1
			end
		end
		if ( group == "party" ) then
			if ( not Nemo.GetUnitHasBuffName("player", spell, "PLAYER") ) then
				count = count + 1
			end
		end
	end
	Nemo.AppendCriteriaDebug( 'GetNumberOfGroupMembersMissingBuff(spell='..tostring(spell)..')='..tostring(count) )
	return count
end
Nemo.D.criteria["d/group/GetNumberOfGroupMembersMissingBuff"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="1",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetNumberOfGroupMembersMissingBuff(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetNumberOfGroupMembersMissingBuff")', text=L["d/group/GetNumberOfGroupMembersMissingBuff"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
Nemo.GetSpellNumberOfUnitsApplied=function(spell)
	local lspellID = Nemo.GetSpellID(spell)
	local lCount=0
	for k,v in pairs(Nemo.D.P.TS) do
		if ( strfind(k, lspellID) ) then
			lCount = lCount + 1
		end
	end
	return lCount
end
Nemo.D.criteria["d/group/GetSpellNumberOfUnitsApplied"]={
	a=3,
	a1l=L["d/common/sp/l"],a1dv=L["d/common/sp/dv"],a1tt=L["d/common/sp/tt"],
	a2l=L["d/common/co/l"],a2dv=">=",a2tt=L["d/common/co/tt"],
	a3l=L["d/common/count/l"],a3dv="3",a3tt=L["d/common/count/tt"],
	f=function () return format('Nemo.GetSpellNumberOfUnitsApplied(%q)%s%s', Nemo.UI["ebArg1"]:GetText(), Nemo.UI["ebArg2"]:GetText(), Nemo.UI["ebArg3"]:GetText() ) end,
}
tinsert( Nemo.D.criteriatree[GROUP_CRITERIA].children, { value='Nemo.UI:CreateCriteriaPanel("d/group/GetSpellNumberOfUnitsApplied")', text=L["d/group/GetSpellNumberOfUnitsApplied"] } )
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------