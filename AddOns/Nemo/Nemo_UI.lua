local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--*****************************************************
--DataBroker Menu functions
--*****************************************************
function Nemo.UI.SortMenu(item1, item2)
	return item1.id < item2.id
end

function Nemo.UI.MenuChangeRotation(self, rotationname)
	Nemo.UI.SelectRotation( rotationname )
end

function Nemo.UI.MenuCreate(self, _level)
	local level = _level or 1
	local id = 1
	local info = {}
	Nemo.UI.Menu = {}

	for rtk, rotation in pairs(Nemo.D.RTMC) do
		info = {
			id = id,
			text = rotation.text,
			icon = nil,
			func = Nemo.UI.MenuChangeRotation,
			arg1 = rotation.text,
			notCheckable = true,
		}
		Nemo.UI.Menu[id] = info
		id = id + 1
	end
	table.sort(Nemo.UI.Menu, Nemo.UI.SortMenu)
end

function Nemo.UI.InitMenu(self, _level)
	local level = _level or 1
	for _, value in pairs(Nemo.UI.Menu) do
		UIDropDownMenu_AddButton(value, level)
	end
end

function Nemo.UI.MenuOnClick(self, button)
	if button == "LeftButton" then
		GameTooltip:Hide()
		if (not Nemo.UI.MenuFrame) then
			Nemo.UI.MenuFrame = CreateFrame("Frame", "NemoMenuFrame", UIParent, "UIDropDownMenuTemplate")
		end
		Nemo.UI.MenuCreate()
		UIDropDownMenu_Initialize(Nemo.UI.MenuFrame, Nemo.UI.InitMenu, "MENU")
		ToggleDropDownMenu(1, nil, Nemo.UI.MenuFrame, self, 20, 4)
	elseif button == "RightButton" then
		Nemo.UI.CreateMainFrame()
	end
end

--*****************************************************
--Action UI Utility functions
--*****************************************************
function Nemo.UI:GetMacrotextTooltip( macrotext )
	if ( macrotext ) then
		local spell = macrotext:match("^%s*#show%a*%s*(.*)")
		if ( spell ) then
			spell = string.gsub(spell, "(;.*)", "")
			spell = string.gsub(spell, "(\n.*)", "")
			spell = strtrim(spell)
			return spell
		end
	end
end
function Nemo.UI:GetActionTexture( NemoSABFrame )
	local lTexture		= "Interface\\Icons\\INV_Misc_QuestionMark"
	if ( not NemoSABFrame or not NemoSABFrame._nemo_action_db ) then
		return lTexture
	end
	local bHasType = not Nemo:isblank(NemoSABFrame._nemo_action_db.at)
	local lType    = NemoSABFrame._nemo_action_db.at
	local bHasAtt1 = not Nemo:isblank(NemoSABFrame._nemo_action_db.att1)
	local lAtt1    = NemoSABFrame._nemo_action_db.att1
	local bHasAtt2 = not Nemo:isblank(NemoSABFrame._nemo_action_db.att2)
	local lAtt2    = NemoSABFrame._nemo_action_db.att2
	local lTargetType, lTargetGID = GetActionInfo( NemoSABFrame._nemo_external_slot or 0 )
-- if ( NemoSABFrame._nemo_action_text == '[A]Ancestral Swiftness' ) then
-- print( "GetActionTexture  lType="..tostring(lType) )		
-- print( "   lAtt1="..tostring(lAtt1) )		
-- print( "   bHasAtt1="..tostring(bHasAtt1) )		
-- end

	if ( not bHasType ) then
		NemoSABFrame._nemo_getactiontexture_status = L["action/_nemo_getactiontexture_status/e2"]
		return lTexture
	end
	
	if ( lType == "spell" and bHasAtt2 ) then	-- Handle a spell type action
		local lSpellID 		= Nemo.GetSpellID(lAtt2)
		local lNemoSpellDB	= Nemo.D.SpellInfo[lSpellID]
		
		if ( lNemoSpellDB and lNemoSpellDB.texture ) then
			NemoSABFrame._nemo_getactiontexture_status = "|cff00FF00OK|r"
			return lNemoSpellDB.texture
		elseif ( lSpellID and GetSpellInfo( lSpellID ) and GetSpellTexture( GetSpellInfo( lSpellID ) ) ) then
			lTexture = GetSpellInfo( lSpellID )
			NemoSABFrame._nemo_getactiontexture_status = "|cff00FF00OK|r"
			return GetSpellTexture( lTexture )
		elseif ( NemoSABFrame._nemo_external_frame and tostring(NemoSABFrame._nemo_gid) == tostring(lTargetGID) and lType == lTargetType ) then
			lTexture = ( _G[NemoSABFrame._nemo_external_frame:GetName().."Icon"]:GetTexture() or "Interface\\Icons\\INV_Misc_QuestionMark" )
			NemoSABFrame._nemo_getactiontexture_status = "|cff00FF00OK|r"
			return lTexture
		end
		
		-- Nemo:dprint( 'couldnt find spell in nemo Nemo.D.SpellInfo['..tostring(lAtt2)..'] Nemo.GetSpellID='..tostring(Nemo.GetSpellID(lAtt2)) )			
		NemoSABFrame._nemo_getactiontexture_status = L["action/_nemo_getactiontexture_status/e3"]
		return "Interface\\Icons\\INV_Misc_QuestionMark"

		
		--return GetSpellTexture( Nemo.GetSpellID(lAtt2) ) or ""
	elseif ( lType == "macro" and bHasAtt1 ) then
-- Nemo:dprint( 'lType == macro '..lAtt1 )			
		lTexture = select(2, GetMacroInfo( lAtt1 ) ) or ""
		NemoSABFrame._nemo_getactiontexture_status = "|cff00FF00Macro|r"
		return lTexture
	elseif ( lType == "macrotext" and Nemo.UI:GetMacrotextTooltip(lAtt1) and bHasAtt1 ) then
		lTexture = GetSpellTexture( Nemo.GetSpellID( Nemo.UI:GetMacrotextTooltip(lAtt1) ) )
		NemoSABFrame._nemo_getactiontexture_status = "|cff00FF00Macrotext|r"
		return lTexture
	elseif ( lType == "item" and bHasAtt1 ) then
		lTexture = select(10, GetItemInfo( lAtt1 ) ) or lAtt1
		NemoSABFrame._nemo_getactiontexture_status = "|cff00FF00Item|r"
		return lTexture
	else
		return ""
	end
end
function Nemo.UI.GetActionLink( actiontype, att1, att2 )
	if ( Nemo:isblank(actiontype) ) then return nil end
	if ( actiontype == "spell" and (not Nemo:isblank(att2)) ) then
		return GetSpellLink( Nemo.GetSpellID( att2 ) )
	elseif ( actiontype == "macrotext" and Nemo.UI:GetMacrotextTooltip(att1) and not Nemo:isblank(att1) ) then
		return GetSpellLink( Nemo.GetSpellID( Nemo.UI:GetMacrotextTooltip(att1) ) )
	elseif ( actiontype == "item" and (not Nemo:isblank(att1)) ) then
		return select(2, GetItemInfo( att1 ) ) or nil
	end
end
function Nemo.UI.ShowTooltip(frame, text, anchor1, anchor2, xOff, yOff, ttType)
 	if ( Nemo:isblank( text) ) then return end
	if ( frame ) then GameTooltip:SetOwner(frame, "ANCHOR_NONE") end
	if ( anchor1 ) then GameTooltip:SetPoint(anchor1 or "LEFT", frame, anchor2 or "RIGHT", xOff, yOff) end
	if ( ttType == "link" ) then
		GameTooltip:SetHyperlink(text or "")
	elseif ( ttType == "action" ) then
		GameTooltip:SetAction(text)
	elseif ( ttType == "text" ) then
		GameTooltip:SetText(text or "")
	end
	GameTooltip:Show()
end
function Nemo.UI.EntryHasErrors( text, bAllowBlank)
	if ( (not bAllowBlank) and Nemo:isblank( text ) ) then return 1 end 		-- Blank
	if ( text and string.find(text, '%[=%[') ) then return 2 end				-- Nesting
	if ( text and string.find(text, '%]=%]') ) then return 3 end				-- Nesting
	if ( text and string.find(text, '%[==%[') ) then return 4 end				-- Nesting
	if ( text and string.find(text, '%]==%]') ) then return 5 end				-- Nesting
	if ( text and string.find(text, 'update') ) then return 5 end				-- update is a command line arg
	return nil
end

function Nemo.UI.HideTooltip()
	GameTooltip:Hide()
end
function Nemo.UI:SetSelectedTreeLevel(ttable, button, buttonpathtable, level)
	level = level or 1
	for k,v in pairs(ttable) do
		if ( v.value == buttonpathtable[level] ) then
			tinsert(Nemo.UI.STL, k)
			if ( level ~= button.level ) then									--Selected Tree Button Level
				Nemo.UI:SetSelectedTreeLevel(ttable[k].children, button, buttonpathtable, level+1)
			end
			return
		end
	end
end
function Nemo.UI.SelectRotation(rotationname, bQuiet)
	local lRotationKey = Nemo:SearchTable(Nemo.D.RTMC, "text", rotationname)
	if ( lRotationKey ) then
		Nemo.DB.profile.options.srk = lRotationKey	--srk=selected rotation key
		Nemo.DB.profile.options.sr  = rotationname	--sr=selected rotation
		if ( not bQuiet ) then print(L["utils/debug/prefix"]..format(L["rotations/selected"], rotationname)) end
	end

	Nemo.Engine.Queue = {}	-- Clear the queue
end
function Nemo.UI.UpdateRotations()
	if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value) end
	Nemo.D.DeleteClassDefaultRotations()
	Nemo.D.UpdateMode = 1 --Update existing objects
	Nemo.D.ImportClassDefaultRotations()
	Nemo.DB.profile.options.lastloadedversion = GetAddOnMetadata("Nemo", "Version")
	if ( Nemo:isblank(Nemo.DB.profile.options.sr) ) then
		Nemo.UI.SetRotationForCurrentSpec()			  			  -- Select the rotation that matches the current specialization or talentgroup
	else
		Nemo.UI.SelectRotation(Nemo.DB.profile.options.sr, false) -- Select the last loaded rotation
	end
	if ( Nemo.UI.sgMain ) then
		Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value)
	end
end
--*****************************************************
--Create Yes/No Dialog function
--*****************************************************
function Nemo.UI.CreateYesNoPopupDialog(DialogText, hasEditBox, EditBoxText)
	StaticPopupDialogs["NEMO_YESNOPOPUP"] = {
		text = DialogText,
		button1 = L["common/yes"],
		button2 = L["common/no"],
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		hasEditBox = (hasEditBox or false),
		OnShow = function (self, data)
			if hasEditBox then
				self.editBox:SetText(EditBoxText)
				self.editBox:SetFocus(0)
				self.editBox:SetCursorPosition(0)
				self.editBox:HighlightText()
			end
		end,
	}
	StaticPopup_Show("NEMO_YESNOPOPUP")
end
--*****************************************************
--Create Text Dialog function
--*****************************************************
function Nemo.UI.CreateTextPopupDialog(DialogText, hasEditBox, EditBoxText)
	StaticPopupDialogs["NEMO_TEXTPOPUP"] = {
		text = DialogText,
		button1 = L["common/done"],
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		hasEditBox = (hasEditBox or false),
		OnShow = function (self, data)
			if hasEditBox then
				self.editBox:SetText(EditBoxText)
				self.editBox:SetFocus(0)
				self.editBox:SetCursorPosition(0)
				self.editBox:HighlightText()
			end
		end,
	}
	return StaticPopup_Show("NEMO_TEXTPOPUP")
end
--*****************************************************
--Draggable Anchor Frame
--*****************************************************
function Nemo.UI:InitAnchorFrame()
	Nemo.UI.fAnchor=CreateFrame("Frame", "Nemo.UI.fAnchor", UIParent)
	Nemo.UI.fAnchor.Texture = Nemo.UI.fAnchor:CreateTexture("OVERLAY")
	Nemo.UI.fAnchor.Texture:SetAllPoints()
	Nemo.UI.fAnchor.Texture:SetTexture("Interface\\ICONS\\INV_Misc_Fish_09",1.0, 0.5, 0)
	Nemo.UI.fAnchor.Texture:SetAlpha(0)
	Nemo.UI.fAnchor:ClearAllPoints()
	if ((not Nemo:isblank(Nemo.DB.profile.options.anchor.x)) and
	    (not Nemo:isblank(Nemo.DB.profile.options.anchor.y))
		) then
		Nemo.UI.fAnchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", Nemo.DB.profile.options.anchor.x, Nemo.DB.profile.options.anchor.y)
	else
		Nemo.UI.fAnchor:SetPoint("CENTER", UIParent, "CENTER")
	end
	Nemo.UI.fAnchor:SetWidth(Nemo:NilToNumeric( Nemo.DB.profile.options.anchor.w,50));
	Nemo.UI.fAnchor:SetHeight(Nemo:NilToNumeric( Nemo.DB.profile.options.anchor.h,50));
	Nemo.UI.fAnchor.moveable = false
	Nemo.UI.fAnchor.timetoupdate=Nemo.DB.profile.options.updateinterval
	Nemo.UI.fAnchor.threadtimetoupdate=Nemo.DB.profile.options.threadupdateinterval
	Nemo.UI.fAnchor.engineready=true
	Nemo.UI.fAnchor.fUpdate=function() end
	Nemo.UI.fAnchor:SetFrameStrata("HIGH")
	Nemo.UI.fAnchor:SetFrameLevel(120)

	Nemo.UI.fAnchor:SetScript("OnEnter", function(self)
		if ( self.moveable ) then
			Nemo.UI.ShowTooltip(self, L["options/fAnchor/tt"], "BOTTOM", "TOP", 0, 0, "text")
			if ( not InCombatLockdown() ) then
				self:SetMovable(true)
				self:EnableMouse(true)
			end
		else
			if ( not InCombatLockdown() ) then
				self:SetMovable(false)
				self:EnableMouse(false)
			end
			GameTooltip:Hide()
		end
	end)

-- Nemo.UI.fAnchor:SetScript("OnEvent", function(self, event, ...)	Nemo:dprint(event) end)
-- Nemo.UI.fAnchor:RegisterAllEvents();

	Nemo.UI.fAnchor:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	Nemo.UI.fAnchor:SetScript("OnMouseDown", function(self, button)
		if ( self.moveable and button == "LeftButton" and not self.isMoving ) then
			self:StartMoving()
			self.isMoving = true
		end
	end)
	Nemo.UI.fAnchor:SetScript("OnMouseUp", function(self, button)
		if ( button=="LeftButton" and self.isMoving ) then
			self:StopMovingOrSizing()
			self.isMoving = false
		end
		if ( button=="RightButton" ) then
			if ( InCombatLockdown() ) then
				print(L["utils/debug/prefix"]..L["common/error/anchor1"])
				return
			end
			Nemo.UI.AnchorPostDrag()
		end
	end)
	Nemo.UI.fAnchor:SetScript("OnUpdate", function(self, elapsed) Nemo.UI.fAnchorOnUpdate(self, elapsed) end)
	if ( ElvUI and Nemo.ElvUI ) then
		Nemo.ElvUI:CreateMover(Nemo.UI.fAnchor, 'NemoMover', L["common/nemo"], nil, nil, function() Nemo.UI.AnchorPostDrag() end)
	end
end
function Nemo.UI.fAnchorOnUpdate(self, elapsed)
	self.timetoupdate = self.timetoupdate - elapsed
	self.threadtimetoupdate = self.threadtimetoupdate - elapsed
	
	if (self.timetoupdate <= 0) then
		Nemo.UI.fAnchor.fUpdate()														-- Debug function to override
		if ( self.bEngineCanFire ) then
			self.bEngineCanFire = false
			Nemo.Engine.Fire()
		end
		for k, thread in pairs(Nemo.D.Threads) do
			if coroutine.status(thread) ~= "dead" then
				coroutine.resume(thread)
			end
		end
		self.timetoupdate = Nemo.DB.profile.options.updateinterval
	end
	if (self.threadtimetoupdate <= 0) then
		for k, thread in pairs(Nemo.D.Threads) do
			if coroutine.status(thread) ~= "dead" then
				coroutine.resume(thread)
			end
		end
		self.threadtimetoupdate = Nemo.DB.profile.options.threadupdateinterval
	end
end
--*****************************************************
--Main Configuration window
--*****************************************************
function Nemo.UI.CreateMainFrame()
	if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then
		return
	end

	Nemo.UI.fMain = Nemo.UI:Create("Frame")
	Nemo.UI.fMain:SetTitle(L["common/nemo"]..' '..L["common/versionprefix"]..GetAddOnMetadata("Nemo", "Version"))
	Nemo.UI.fMain:SetWidth(750)
	Nemo.UI.fMain:SetHeight(700)
	Nemo.UI.fMain:SetLayout("Fill")
	Nemo.UI.fMain:EnableResize(false)
	Nemo.UI.fMain:SetCallback("OnClose", function() Nemo.UI.HideTestAlert(Nemo.D.lastalertname) end)
	Nemo.UI.fMain.frame:SetScale( Nemo.DB.profile.options.uiscale or 1 )

	-- simplegroup to hold the Main treegroup, treegroups require fill layouts to display properly
	Nemo.UI.sgMain = Nemo.UI:Create("SimpleGroup")
	Nemo.UI.sgMain:SetLayout("Fill")
	Nemo.UI.fMain:AddChild(Nemo.UI.sgMain)

	-- Main treegroup on the left
	Nemo.UI.sgMain.tgMain = Nemo.UI:Create( "TreeGroup" )
	Nemo.UI.sgMain:AddChild(Nemo.UI.sgMain.tgMain)
	Nemo.UI.sgMain.tgMain:SetTree( Nemo.DB.profile.treeMain )
	Nemo.UI.sgMain.tgMain:SetCallback( "OnGroupSelected", Nemo.UI.tgMainOnGroupSelected )
	Nemo.UI.sgMain.tgMain:SetTreeWidth( 200, false )
	Nemo.UI.sgMain.tgMain:EnableButtonTooltips(true)

	-- Main simple group panel on right
	Nemo.UI.sgMain.tgMain.sgPanel = Nemo.UI:Create("SimpleGroup")
	Nemo.UI.sgMain.tgMain:AddChild(Nemo.UI.sgMain.tgMain.sgPanel)
	Nemo.UI.sgMain.tgMain.sgPanel:SetFullWidth(true)
	Nemo.UI.sgMain.tgMain.sgPanel:SetHeight(0)
	Nemo.UI.sgMain.tgMain.sgPanel:SetLayout("Fill")

end

--Main UI Callbacks-------------------------------
function Nemo.UI.tgMainOnGroupSelected(self, functionname, buttonvalue)
	local lUniqueValue = ""
	self:RefreshTree()															--Call wowace RefreshTree so .selected gets updated
	Nemo.UI.sgMain.tgMain.sgPanel:ReleaseChildren()								--Clears the right panel
	Nemo.UI.STL 					= {}										--Reset the Selected Tree Level (STL)
	Nemo.UI.HideTestAlert()														--Hide the test alert incase the user was editing an alert
	
	if strfind(buttonvalue, "\001") then
		for token in string.gmatch(buttonvalue, "[^\001]+") do
			lUniqueValue = token												--Last token is the unique value
		end
	else
		lUniqueValue=buttonvalue
	end
	
	for k,button in pairs(Nemo.UI.sgMain.tgMain.buttons) do						--Loop through the tree menu buttons to find the one that matches what was selected
		if ( button.value == lUniqueValue and button.selected) then
			Nemo.UI:SetSelectedTreeLevel(Nemo.DB.profile.treeMain, button, { strsplit("\001", button.uniquevalue) } )
			Nemo.D.RunCode( button.value, '', "Nemo.UI.tgMainOnGroupSelected error pcall:", false, true  )	-- Use the wowace .value field to create a function
		end
	end
end