local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--*****************************************************
--Action Utility functions
--*****************************************************
function Nemo.AddAction( ActionName, ShowError, ActionType, Att1, Att2, X,Y,H,W, AlertName, Criteria)
	if ( Nemo.UI.EntryHasErrors( ActionName ) ) then
		if ( Nemo.UI.sgMain ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], ActionName) ) end
		return
	end
	-- Create the rotation if needed
-- Nemo:dprint("AddAction to rotationname="..Nemo.D.ImportName)
	local lRotationKey = nil
	if ( Nemo.D.ImportType and Nemo.D.ImportType == 'actionpack' and Nemo.DB.profile.options.srk ) then
		lRotationKey  = Nemo.DB.profile.options.srk
	else
		lRotationKey  = Nemo:SearchTable(Nemo.D.RTMC, "text", Nemo.D.ImportName)
	end
-- Nemo:dprint("AddAction lRotationKey="..tostring(lRotationKey))
	if ( not lRotationKey ) then
		if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then Nemo.UI.fMain:SetStatusText( L["rotations/rimportfail/E6"] ) end
		print( L["utils/debug/prefix"]..L["rotations/rimportfail/E5"] )
		return
	end
	
	-- Create the action
	local lActionExists   = Nemo:SearchTable(Nemo.D.RTMC[lRotationKey].children, "text", ActionName)
	local lNewActionValue = 'Nemo.UI:CAP([=['..ActionName..']=])'
	local lNewActionText  = ActionName
	if ( Nemo.D.UpdateMode==0 and lActionExists ) then
-- Nemo:dprint("found duplicate action="..ActionName.." Nemo.D.UpdateMode="..Nemo.D.UpdateMode)
		local iSuffix = 0
		lNewActionText = lNewActionText..'_'
		while lActionExists do
			iSuffix = iSuffix+1
			lActionExists = Nemo:SearchTable(Nemo.D.RTMC[lRotationKey].children, "text", lNewActionText..iSuffix)
		end
		lNewActionValue = 'Nemo.UI:CAP([=['..lNewActionText..iSuffix..']=])'
		lNewActionText = lNewActionText..iSuffix
	end
	local lNewAction = { value = lNewActionValue, text = lNewActionText}
	lActionExists   = Nemo:SearchTable(Nemo.D.RTMC[lRotationKey].children, "text", lNewActionText)
	if ( lActionExists ) then
		if ( Nemo.UI.sgMain and ShowError ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], lNewActionText) ) end	
		if ( Nemo.D.UpdateMode==0 ) then  --Mode0 = Create new names, do not update existing ones
			if ( Nemo.UI.sgMain ) then Nemo.UI.fMain:SetStatusText( '' ) end -- Clear any previous errors
			if ( Nemo.D.ImportType and Nemo.D.ImportType == 'rotation' ) then
				table.insert( Nemo.D.RTMC[lRotationKey].children, lNewAction)
			else
				Nemo.D.ImportIndex = Nemo.D.ImportIndex + 1
				table.insert( Nemo.D.RTMC[lRotationKey].children, Nemo.D.ImportIndex, lNewAction)
			end
		elseif ( Nemo.D.UpdateMode==3 ) then  --Mode3 = do not update or create new objects if they exist
			return lNewActionText, lActionExists
		end
	else
		if ( Nemo.UI.sgMain ) then Nemo.UI.fMain:SetStatusText( '' ) end -- Clear any previous errors
		if ( Nemo.D.ImportType and Nemo.D.ImportType == 'rotation' ) then
			table.insert( Nemo.D.RTMC[lRotationKey].children, lNewAction)
		else
			Nemo.D.ImportIndex = Nemo.D.ImportIndex + 1
			table.insert( Nemo.D.RTMC[lRotationKey].children, Nemo.D.ImportIndex, lNewAction)
		end
	end
	lActionExists   = Nemo:SearchTable(Nemo.D.RTMC[lRotationKey].children, "text", lNewActionText)
	if ( lActionExists ) then 
		local ActionDB = Nemo.D.RTMC[lRotationKey].children[lActionExists]
		if ( not Nemo:isblank(ActionType) ) then ActionDB.at   = ActionType end
		if ( not Nemo:isblank(Att1) )       then ActionDB.att1 = Att1 end
		if ( not Nemo:isblank(Att2) )       then ActionDB.att2 = Att2 end		
		if ( not Nemo:isblank(X) and Nemo:isblank(ActionDB.x) )	then ActionDB.x = X end --Only update if the database is blank and the update is not blank
		if ( not Nemo:isblank(Y) and Nemo:isblank(ActionDB.y) )	then ActionDB.y = Y end
		if ( not Nemo:isblank(H) and Nemo:isblank(ActionDB.h) )	then ActionDB.h = H end
		if ( not Nemo:isblank(W) and Nemo:isblank(ActionDB.w) )	then ActionDB.w = W end
		if ( not Nemo:isblank(AlertName) ) 	then ActionDB.an = AlertName end
		if ( not Nemo:isblank(Criteria) ) 	then ActionDB.criteria = Criteria end
	end
	if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end
	Nemo.AButtons.bInitComplete = false
	return lNewActionText, lActionExists
end
function Nemo.GetActionExportString( RotationName, ActionName )
	local lRotationExists = Nemo:SearchTable(Nemo.D.RTMC, "text", RotationName)
	local lActionExists   = nil
	if ( lRotationExists ) then
		lActionExists = Nemo:SearchTable(Nemo.D.RTMC[lRotationExists].children, "text", ActionName)
	end
	if ( not lActionExists ) then return end
	local ActionDB = Nemo.D.RTMC[lRotationExists].children[lActionExists]
	local lAExport = 'Nemo.AddAction([=['..ActionName..']=],false'	
	if ( not Nemo:isblank(ActionDB.at) ) 		then lAExport = lAExport..',[=['..ActionDB.at..']=]' else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(ActionDB.att1) )      then lAExport = lAExport..',[=['..ActionDB.att1..']=]' else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(ActionDB.att2) )      then lAExport = lAExport..',[=['..ActionDB.att2..']=]' else lAExport = lAExport..',nil' end		
	if ( not Nemo:isblank(ActionDB.x) ) 		then lAExport = lAExport..','..ActionDB.x else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(ActionDB.y) ) 		then lAExport = lAExport..','..ActionDB.y else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(ActionDB.h) ) 		then lAExport = lAExport..','..ActionDB.h else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(ActionDB.w) ) 		then lAExport = lAExport..','..ActionDB.w else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(ActionDB.an) ) 		then lAExport = lAExport..',[=['..ActionDB.an..']=]' else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(ActionDB.criteria) )	then lAExport = lAExport..',[=['..ActionDB.criteria..']=]);' else lAExport = lAExport..',nil);' end
	return lAExport.."\n"
end
function Nemo.SetActionCriteriaFunction( NemoSABFrame )
	-- Create the criteria function from the ActionDB.criteria field
	-- local NemoSABFrame = nil
	if ( not NemoSABFrame ) then return end
	local ret1
	-- if ( Nemo.AButtons.Frames[RotationDB.text] and Nemo.AButtons.Frames[RotationDB.text][ActionDB.value] ) then
		-- NemoSABFrame = Nemo.AButtons.Frames[RotationDB.text][ActionDB.value]
-- print( "NemoSABFrame="..NemoSABFrame._nemo_action_text)
	-- end
	if (string.find( NemoSABFrame._nemo_action_db.criteria or "", '--_nemo_enable_lua' ) ) then
		NemoSABFrame._nemo_action_db.fCriteria, ret1=loadstring((NemoSABFrame._nemo_action_db.criteria or "return false"))			-- Create Function for engine to check the criteria with full lua allowed in criteria
	else
		NemoSABFrame._nemo_action_db.fCriteria, ret1=loadstring("return "..(NemoSABFrame._nemo_action_db.criteria or "false"))		-- Create Function for engine to check the criteria with prepended return
	end
	if ( not NemoSABFrame._nemo_action_db.fCriteria ) then
		print(L["utils/debug/prefix"]..L["action/bCriteriaTest/loadstringerror"].." "..tostring(NemoSABFrame._nemo_rotation_text)..":"..tostring(NemoSABFrame._nemo_action_text))
		NemoSABFrame._nemo_syntax_status = L["action/_nemo_syntax_status/e1"]..":"..ret1
	else
		-- if ( NemoSABFrame ) then NemoSABFrame._nemo_syntax_status = L["action/_nemo_syntax_status/pass"] end
		NemoSABFrame._nemo_syntax_status = L["action/_nemo_syntax_status/pass"]
	end
	NemoSABFrame._nemo_criteria_ran_once = false
end
--*****************************************************
--Action Panel
--*****************************************************
function Nemo.UI:CAP(ActionName)--CAP=Create Action Panel
	Nemo.UI.DB = {}

	Nemo.UI.sgMain.tgMain:RefreshTree() 										-- Gets rid of the rotation from the tree
	Nemo.UI.sgMain.tgMain.sgPanel:ReleaseChildren() 							-- clears the right panel
	
	Nemo.UI.SelectRotation(Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]].text, true)	-- Select the rotation first
	Nemo.UI.DB = Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]]
	
	Nemo.UI.sgMain.tgMain.sgPanel:ResumeLayout()	-- Pause or resume the righ tsgPanel fill layout if you need it or not
	
	-- Criteria tree goes in the sgPanel
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria = Nemo.UI:Create("TreeGroup")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria )
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria:SetTree( Nemo.D.criteriatree )

	Nemo.UI.sgMain.tgMain.sgPanel:SetHeight(200)
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria:SetTreeWidth( 350, true )
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria:SetFullWidth(true)
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria:SetCallback( "OnGroupSelected", Nemo.UI.tgCriteriaOnGroupSelected )

	-- Create the criteria panel
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel = Nemo.UI:Create("SimpleGroup")
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria:AddChild(Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel)
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel:SetLayout("List")
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel:SetFullWidth(true)

	-- The first attribute for the action type most action types only have 2 params http://www.wowpedia.org/SecureActionButtonTemplate
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel.mlebCriteria = Nemo.UI:Create( "MultiLineEditBox" )
	local mlebCriteria = Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel.mlebCriteria
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( mlebCriteria )
	mlebCriteria:SetLabel( L["action/mlebCriteria/l"] )
	mlebCriteria:SetHeight(200)
	mlebCriteria:SetWidth(500)
	mlebCriteria:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.frame, "BOTTOMLEFT", 0, 0)
	mlebCriteria:SetCallback( "OnEnterPressed" , function(self)
		Nemo.UI.DB.criteria = self:GetText()
		Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
	end )
	mlebCriteria.editBox:SetScript("OnMouseUp",function(self, button)
		Nemo.UI.fMain:SetStatusText( '' )
		local Text, Cursor = self:GetText(), self:GetCursorPosition()
		self:Insert( "" ) -- Delete selected text
		local TextNew, CursorNew = self:GetText(), self:GetCursorPosition()
		self:SetText( Text ) --Restore previous text
		self:SetCursorPosition( Cursor )
		local Start, End = CursorNew, #Text - ( #TextNew - CursorNew )
		self:HighlightText( Start, End )
		local lHighlightedText = tostring(string.sub(self:GetText(), (Start+1), End))
		local spellLink = GetSpellLink( lHighlightedText )
		if ( spellLink ) then
			print(L["utils/debug/prefix"]..spellLink)
			Nemo.UI.fMain:SetStatusText( spellLink )
		elseif ( select(2, GetItemInfo( lHighlightedText ) ) ) then
			print(L["utils/debug/prefix"]..select(2, GetItemInfo( lHighlightedText ) ) )
			Nemo.UI.fMain:SetStatusText( select(2, GetItemInfo( lHighlightedText ) ) )
		end
	end )
	mlebCriteria:SetText( Nemo.UI.DB.criteria or "")

	-- And button
	local bCriteriaAnd = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bCriteriaAnd )
	bCriteriaAnd:SetText( L["action/bCriteriaAnd/l"] )
	bCriteriaAnd:SetWidth(85)
	bCriteriaAnd:SetPoint("TOPLEFT", mlebCriteria.frame, "BOTTOMLEFT", 65, 27);
	bCriteriaAnd:SetCallback( "OnClick", function()
		Nemo.UI.DB.criteria=mlebCriteria:GetText().." and "
		mlebCriteria:SetText( Nemo.UI.DB.criteria )
		Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
	end )

	-- Or button
	local bCriteriaOr = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bCriteriaOr )
	bCriteriaOr:SetText( L["action/bCriteriaOr/l"] )
	bCriteriaOr:SetWidth(85)
	bCriteriaOr:SetPoint("TOPLEFT", bCriteriaAnd.frame, "TOPRIGHT", 0, 0);
	bCriteriaOr:SetCallback( "OnClick", function()
		Nemo.UI.DB.criteria=mlebCriteria:GetText().." or "
		mlebCriteria:SetText( Nemo.UI.DB.criteria )
		Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
	end )

	-- Not button
	local bCriteriaNot = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bCriteriaNot )
	bCriteriaNot:SetText( L["action/bCriteriaNot/l"] )
	bCriteriaNot:SetWidth(85)
	bCriteriaNot:SetPoint("TOPLEFT", bCriteriaOr.frame, "TOPRIGHT", 0, 0);
	bCriteriaNot:SetCallback( "OnClick", function()
		Nemo.UI.DB.criteria=mlebCriteria:GetText().." not "
		mlebCriteria:SetText( Nemo.UI.DB.criteria )
		Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
	end )

	-- Clear button
	local bCriteriaClear = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bCriteriaClear )
	bCriteriaClear:SetText( L["common/clear"] )
	bCriteriaClear:SetWidth(85)
	bCriteriaClear:SetPoint("TOPLEFT", bCriteriaNot.frame, "TOPRIGHT", 0, 0);
	bCriteriaClear:SetCallback( "OnClick", function()
		Nemo.UI.DB.criteria=""
		mlebCriteria:SetText( Nemo.UI.DB.criteria )
		Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
	end )

	-- Test button
	-- local bCriteriaTest = Nemo.UI:Create("Button")
	-- Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bCriteriaTest )
	-- bCriteriaTest:SetText( L["common/test"] )
	-- bCriteriaTest:SetWidth(85)
	-- bCriteriaTest:SetPoint("TOPRIGHT", mlebCriteria.frame, "BOTTOMRIGHT", 100, 27);
	-- bCriteriaTest:SetCallback( "OnClick", Nemo.UI.bCriteriaTestOnClick )
	-- bCriteriaTest:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, Nemo.UI.DB.tr,"BOTTOM","TOP", 0, 0, "text") end )
	-- bCriteriaTest:SetCallback( "OnLeave", Nemo.UI.HideTooltip )

	-- Action type dropdown
	local ddActionType = Nemo.UI:Create("Dropdown")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ddActionType )
	ddActionType:SetList(Nemo.D.ActionTypes, Nemo.D.ActionSortOrder)
	ddActionType:SetLabel( L["action/ddActionType/l"] )
	ddActionType:SetWidth(100)
	ddActionType:SetPoint("TOPLEFT", mlebCriteria.frame, "BOTTOMLEFT", -5, 4);
	ddActionType:SetCallback( "OnValueChanged", function() Nemo.UI.DB.at=ddActionType:GetValue(); Nemo.AButtons.bInitComplete = false end )
	ddActionType:SetValue( Nemo.UI.DB.at or "")
	ddActionType:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ddActionType/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	ddActionType:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- The first attribute for the action type most action types only have 2 params http://www.wowpedia.org/SecureActionButtonTemplate
	local mlebActionTypeAtt1 = Nemo.UI:Create( "MultiLineEditBox" )
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( mlebActionTypeAtt1 )
	mlebActionTypeAtt1:SetLabel( L["action/mlebActionTypeAtt1/l"] )
	mlebActionTypeAtt1:SetHeight(80)
	mlebActionTypeAtt1:SetPoint("TOPLEFT", ddActionType.frame, "TOPRIGHT", 0, -5)
	mlebActionTypeAtt1:SetCallback( "OnEnterPressed" , function(self)
		Nemo.UI.DB.att1 = strtrim(self:GetText())
		mlebActionTypeAtt1:SetText(Nemo.UI.DB.att1)
		Nemo.UI.SetebTexture( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
		Nemo.AButtons.bInitComplete = false	-- Action attribute1 was changed initialization needed
	end )
	mlebActionTypeAtt1:SetText( Nemo.UI.DB.att1 or "")
	mlebActionTypeAtt1:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, Nemo.UI.GetAttTooltip("att1"), "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	mlebActionTypeAtt1:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- The second attribute http://www.wowpedia.org/SecureActionButtonTemplate
	local mlebActionTypeAtt2 = Nemo.UI:Create( "MultiLineEditBox" )
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( mlebActionTypeAtt2 )
	mlebActionTypeAtt2:SetLabel( L["action/mlebActionTypeAtt2/l"] )
	mlebActionTypeAtt2:SetHeight(80)
	mlebActionTypeAtt2:SetPoint("TOPLEFT", mlebActionTypeAtt1.frame, "TOPRIGHT", 5, 0)
	mlebActionTypeAtt2:SetCallback( "OnEnterPressed" , function(self)
		Nemo.UI.DB.att2 = strtrim(self:GetText())
		mlebActionTypeAtt2:SetText(Nemo.UI.DB.att2)
		Nemo.UI.SetebTexture( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
		Nemo.AButtons.bInitComplete = false	-- Action attribute2 was changed initialization needed 
	end)
	mlebActionTypeAtt2:SetText( Nemo.UI.DB.att2 or "")
	mlebActionTypeAtt2:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, Nemo.UI.GetAttTooltip("att2"), "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	mlebActionTypeAtt2:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	mlebActionTypeAtt2:SetCallback( "OnTextChanged", function(self) Nemo.UI.mlebActionTypeAttOnTextChanged( ddActionType:GetValue(), mlebActionTypeAtt1:GetText(), self:GetText()) end)
	mlebActionTypeAtt1:SetCallback( "OnTextChanged", function(self) Nemo.UI.mlebActionTypeAttOnTextChanged( ddActionType:GetValue(), self:GetText(), mlebActionTypeAtt2:GetText()) end)

	-- Spell Link interactive label
	Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link )
	local ilAtt2Link = Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link
	ilAtt2Link:SetWidth(300)
	ilAtt2Link.Tooltip=nil
	ilAtt2Link:SetPoint("TOPLEFT", mlebActionTypeAtt2.frame, "TOPLEFT", 52, -4);
	ilAtt2Link:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(Nemo.UI.sgMain.tgMain.frame, self.Tooltip, "TOPRIGHT", "TOPRIGHT", 0, 0, "link") end )
	ilAtt2Link:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	Nemo.UI.mlebActionTypeAttOnTextChanged( ddActionType:GetValue(), mlebActionTypeAtt1:GetText(), mlebActionTypeAtt2:GetText() )

	-- Information MultiLineEditBox where we display debug information
	Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo = Nemo.UI:Create( "MultiLineEditBox" )
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo )
	local mlebInfo = Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo
	mlebInfo:SetNumLines(13)
	mlebInfo:SetWidth(500)
	mlebInfo:SetLabel("")
	mlebInfo:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", 0, 0)
	mlebInfo:SetText( "" )
	mlebInfo:SetCallback( "OnEnter", function(self)
		Nemo.UI.ShowTooltip(self.frame, L["action/mlebInfo/tt"], "TOPRIGHT", "TOPLEFT", 0, 0, "text")
		Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo._nemo_debug_paused = true
	end )
	mlebInfo:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip(); Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo._nemo_debug_paused = false end )
	mlebInfo:DisableButton( true )
	mlebInfo.frame:Hide()
	
	-- ExportActionPack InteractiveLabel
	Nemo.UI.sgMain.tgMain.sgPanel.ilExportActionPack = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ilExportActionPack )
	local ilExportActionPack = Nemo.UI.sgMain.tgMain.sgPanel.ilExportActionPack
	ilExportActionPack:SetWidth(24)
	ilExportActionPack.Tooltip=nil
	ilExportActionPack:SetImage('Interface\\Addons\\Nemo\\Textures\\Package')
	ilExportActionPack:SetImageSize(24,24)
	
	ilExportActionPack:SetPoint("TOPRIGHT", mlebCriteria.frame, "BOTTOMRIGHT", -50, 25);
	ilExportActionPack:SetCallback( "OnClick", function()
		local lActionPack = Nemo.UI.GetActionPack()
		if ( StaticPopup_Visible( "NEMO_TEXTPOPUP" ) ) then
			StaticPopup_Hide("NEMO_TEXTPOPUP")
		end
		local lDialog = Nemo.UI.CreateTextPopupDialog(L["common/ctrlc"], true, lActionPack)
		if lDialog then
			lDialog:SetFrameStrata("TOOLTIP")
			lDialog:ClearAllPoints()
			lDialog:SetPoint("CENTER", UIParent, "CENTER")
		end
	end )
	ilExportActionPack:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame,  L["action/ilExportActionPack/tt"], "BOTTOM", "TOP", 0, 0, "text") end )
	ilExportActionPack:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	
	-- Information CheckBox
	Nemo.UI.sgMain.tgMain.sgPanel.cbInfo = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.cbInfo )
	local cbInfo = Nemo.UI.sgMain.tgMain.sgPanel.cbInfo
	cbInfo:SetWidth(20)
	cbInfo.Tooltip=nil
	cbInfo:SetPoint("TOPRIGHT", mlebCriteria.frame, "BOTTOMRIGHT", -20, 25);
	cbInfo:SetImage("Interface\\FriendsFrame\\InformationIcon")
	cbInfo:SetCallback( "OnValueChanged", function(self)
		if ( self:GetValue() == true ) then
			Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo.frame._nemo_sabframe = Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]]
			Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.frame:Hide()
			mlebInfo.frame:Show()
		else
			Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo.frame._nemo_sabframe = nil
			Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.frame:Show()
			mlebInfo.frame:Hide()
		end
	end )
	cbInfo:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame,  L["action/cbInfo/tt"], "BOTTOM", "TOP", 0, 0, "text") end )
	cbInfo:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Texture Icon
	Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon = Nemo.UI:Create("Icon")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon )
	local ebTextureIcon = Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon
	Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon:SetWidth(64)
	Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon:SetHeight(64)
	Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon:SetImageSize(64,64) -- Set the size of the image.
	Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon:SetPoint("TOPLEFT", ddActionType.frame, "BOTTOMLEFT", 5, -5);
	Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon:SetImage( Nemo.UI:GetActionTexture( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] ) )
	ebTextureIcon:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(Nemo.UI.sgMain.tgMain.frame, Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link.Tooltip, "TOPRIGHT", "TOPRIGHT", 0, 0, "link") end )
	ebTextureIcon:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Button X offset relative to CENTER of Nemo.UI.fAnchor
	local ebXOffset = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebXOffset )
	ebXOffset:SetLabel( L["action/ebXOffset/l"] )
	ebXOffset:SetWidth(80)
	ebXOffset:SetPoint("TOPLEFT", mlebActionTypeAtt1.frame, "BOTTOMLEFT", -5, 5);
	ebXOffset:SetCallback( "OnEnterPressed", function(self)
		if ( IsShiftKeyDown() ) then
			Nemo.UI.SetMultiActionValue( 'x', self:GetText() )
		end
		Nemo.UI.DB.x = self:GetText()
		Nemo.AButtons.bInitComplete = false	-- Action X offset was changed
	end )
	ebXOffset:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ebXOffset/tt"], "BOTTOMLEFT", "TOPLEFT", 0, 0, "text") end )
	ebXOffset:SetText( Nemo.UI.DB.x )

	-- Button Y offset relative to CENTER of Nemo.UI.fAnchor
	local ebYOffset = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebYOffset )
	ebYOffset:SetLabel( L["action/ebYOffset/l"] )
	ebYOffset:SetWidth(80)
	ebYOffset:SetPoint("TOPLEFT", ebXOffset.frame, "TOPRIGHT", 0, 0);
	ebYOffset:SetCallback( "OnEnterPressed", function(self)
		if ( IsShiftKeyDown() ) then
			Nemo.UI.SetMultiActionValue( 'y', self:GetText() )
		end
		Nemo.UI.DB.y = self:GetText()
		Nemo.AButtons.bInitComplete = false	-- Action Y offset was changed
	end )
	ebYOffset:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ebYOffset/tt"], "BOTTOMLEFT", "TOPLEFT", 0, 0, "text") end )
	ebYOffset:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebYOffset:SetText( Nemo.UI.DB.y )

	-- Button Height
	local ebHeight = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebHeight )
	ebHeight:SetLabel( L["action/ebHeight/l"] )
	ebHeight:SetWidth(80)
	ebHeight:SetPoint("TOPLEFT", ebYOffset.frame, "TOPRIGHT", 0, 0);
	ebHeight:SetCallback( "OnEnterPressed", function(self)
		if ( IsShiftKeyDown() ) then
			Nemo.UI.SetMultiActionValue( 'h', self:GetText() )
		end
		Nemo.UI.DB.h = self:GetText()
		Nemo.AButtons.bInitComplete = false	-- Action height was changed
	end )
	ebHeight:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ebHeight/tt"], "BOTTOMLEFT", "TOPLEFT", 0, 0, "text") end )
	ebHeight:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebHeight:SetText( Nemo.UI.DB.h )

	-- Button Width
	local ebWidth = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebWidth )
	ebWidth:SetLabel( L["action/ebWidth/l"] )
	ebWidth:SetWidth(80)
	ebWidth:SetPoint("TOPLEFT", ebHeight.frame, "TOPRIGHT", 0, 0);
	ebWidth:SetCallback( "OnEnterPressed", function(self)
		if ( IsShiftKeyDown() ) then
			Nemo.UI.SetMultiActionValue( 'w', self:GetText() )
		end
		Nemo.UI.DB.w = self:GetText()
		Nemo.AButtons.bInitComplete = false	-- Action Width was changed
	end )
	ebWidth:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ebWidth/tt"], "BOTTOMLEFT", "TOPLEFT", 0, 0, "text") end )
	ebWidth:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebWidth:SetText( Nemo.UI.DB.w )

	-- CheckBox disable button, same thing as right clicking it
	local cbDisableButton = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbDisableButton )
	cbDisableButton:SetLabel( L["action/cbDisableButton/l"] )
	cbDisableButton:SetWidth(75)
	cbDisableButton:SetPoint("TOPLEFT", ebWidth.frame, "TOPRIGHT", 5, -17);
	cbDisableButton:SetCallback( "OnValueChanged", function(self)
		Nemo.UI.DB.dis = self:GetValue();
		-- Nemo.AButtons.bInitComplete = false
	end )
	if (Nemo:isblank(Nemo.UI.DB.dis)) then cbDisableButton:SetValue(false);Nemo.UI.DB.dis=false else cbDisableButton:SetValue( Nemo.UI.DB.dis) end
	cbDisableButton:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/cbDisableButton/tt"], "BOTTOMLEFT", "TOPLEFT", 0, 0, "text") end )
	cbDisableButton:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- CheckBox mouse button
	local cbMouseEnableButton = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbMouseEnableButton )
	cbMouseEnableButton:SetLabel( L["action/cbMouseEnableButton/l"] )
	cbMouseEnableButton:SetWidth(75)
	cbMouseEnableButton:SetPoint("TOPLEFT", cbDisableButton.frame, "BOTTOMLEFT", 0, -17);
	cbMouseEnableButton:SetCallback( "OnValueChanged", function(self)
		if ( IsShiftKeyDown() ) then
			Nemo.UI.SetMultiActionValue( 'mouseenabled', self:GetValue() )
		end
		Nemo.UI.DB.mouseenabled = self:GetValue();
		Nemo.AButtons.bInitComplete = false
	end )
	if ( Nemo:isblank(Nemo.UI.DB.mouseenabled) ) then
		cbMouseEnableButton:SetValue(true);
		Nemo.UI.DB.mouseenabled=true
	else
		cbMouseEnableButton:SetValue( Nemo.UI.DB.mouseenabled)
	end
	cbMouseEnableButton:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/cbMouseEnableButton/tt"], "BOTTOMLEFT", "TOPLEFT", 0, 0, "text") end )
	cbMouseEnableButton:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )


	-- Move up Action interactive label
	local ilAMoveUp = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAMoveUp )
	ilAMoveUp:SetWidth(40);ilAMoveUp:SetHeight(40)
	ilAMoveUp:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Up")
	ilAMoveUp:SetImageSize(40, 40)
	ilAMoveUp:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Highlight")
	ilAMoveUp:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", -5, -545);
	ilAMoveUp:SetCallback( "OnClick", function() Nemo.UI.bMoveAction(-1) end )
	ilAMoveUp:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ilAMoveUp/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilAMoveUp:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Move down Action interactive label
	local ilAMoveDown = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAMoveDown )
	ilAMoveDown:SetWidth(40);ilAMoveDown:SetHeight(40)
	ilAMoveDown:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Up")
	ilAMoveDown:SetImageSize(40, 40)
	ilAMoveDown:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Highlight")
	ilAMoveDown:SetPoint("TOPLEFT", ilAMoveUp.frame, "BOTTOMLEFT", 0, 5);
	ilAMoveDown:SetCallback( "OnClick", function() Nemo.UI.bMoveAction(1) end )
	ilAMoveDown:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ilAMoveDown/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilAMoveDown:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Keybind
	local bActionKeybind = Nemo.UI:Create("Keybinding")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bActionKeybind )
	bActionKeybind:SetWidth(100)
	bActionKeybind:SetLabel(L["common/hotkey/l"])
	bActionKeybind:SetPoint("TOPLEFT", ilAMoveDown.frame, "TOPRIGHT", 0, 10);
	bActionKeybind:SetCallback( "OnKeyChanged", function(self)
		if ( InCombatLockdown() ) then Nemo.UI.fMain:SetStatusText( L["common/error/keybindincombat"] )	end
		Nemo.UI.DB.hk = self:GetKey();
		Nemo.AButtons.bInitComplete = false;
		self:SetKey( Nemo.UI.DB.hk or L["action/bActionKeybind/blizzard"])
	end )
	bActionKeybind:SetKey( Nemo.UI.DB.hk or L["action/bActionKeybind/blizzard"] )
	bActionKeybind.label:SetPoint("TOPLEFT", bActionKeybind.frame, "TOPLEFT", -40, 0);

	-- Delete Action button
	local bActionDelete = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bActionDelete )
	bActionDelete:SetWidth(100)
	bActionDelete:SetText(L["common/delete"])
	bActionDelete:SetPoint("TOPLEFT", bActionKeybind.frame, "TOPRIGHT", 0, -20);
	bActionDelete:SetCallback( "OnClick", Nemo.UI.bActionDeleteOnClick )
	bActionDelete:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/bActionDelete/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	bActionDelete:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Action Alert Name dropdown
	local ebActionAlertName = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebActionAlertName )
	ebActionAlertName:SetLabel( L["action/ebAlertName/l"] )
	ebActionAlertName:SetWidth(160)
	ebActionAlertName:SetPoint("TOPLEFT", ebXOffset.frame, "BOTTOMLEFT", 0, -3)
	ebActionAlertName:SetCallback( "OnEnterPressed", Nemo.UI.ebActionAlertNameOnEnterPressed )
	ebActionAlertName:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ebAlertName/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebActionAlertName:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebActionAlertName:SetText( Nemo.UI.DB.an or nil )

	-- Rename Action edit box
	local ebRenameAction = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebRenameAction )
	ebRenameAction:SetLabel( L["action/ebRenameAction/l"] )
	ebRenameAction:SetWidth(160)
	ebRenameAction:SetPoint("TOPLEFT", ebActionAlertName.frame, "TOPRIGHT", 0, 0)
	ebRenameAction:SetCallback( "OnEnterPressed", Nemo.UI.ebRenameActionOnEnterPressed )
	ebRenameAction:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["action/ebRenameAction/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebRenameAction:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebRenameAction:SetText( Nemo.UI.DB.text )

end
--Action Panel Callbacks-------------------------------
function Nemo.UI:CreateCriteriaPanel(...)
	local args = {...}
	if ( not Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria ) then return end
	for argi=1,Nemo.D.criteria[args[1]].a do									--Build the criteria options based on Nemo.D.criteria
		Nemo.UI["ebArg"..argi] = Nemo.UI:Create("EditBox")
		Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel:AddChild( Nemo.UI["ebArg"..argi] )
		Nemo.UI["ebArg"..argi]:SetFullWidth(true)
		Nemo.UI["ebArg"..argi]:SetLabel( Nemo.D.criteria[args[1]]["a"..argi.."l"] or L["action/ebArg/l"]..argi )
		Nemo.UI["ebArg"..argi]:SetText( Nemo.D.criteria[args[1]]["a"..argi.."dv"] or "" )
		Nemo.UI["ebArg"..argi]:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, Nemo.D.criteria[args[1]]["a"..argi.."tt"], "BOTTOMLEFT", "TOPRIGHT", 0, 0, "text") end )
		Nemo.UI["ebArg"..argi]:SetCallback( "OnLeave", Nemo.UI.HideTooltip )
		Nemo.UI["ebArg"..argi]:DisableButton(true)
	end
	-- Add Criteria button
	local bCriteriaAdd = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel:AddChild( bCriteriaAdd )
	bCriteriaAdd:SetText( L["action/bCriteriaAdd/l"] )
	bCriteriaAdd:SetFullWidth(true)
	bCriteriaAdd:SetPoint("BOTTOMRIGHT", Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel.frame, "BOTTOMRIGHT", 0, 0);
	bCriteriaAdd:SetCallback( "OnClick", function() Nemo.UI.CriteriaAddOnClick(args[1]) end )
end
function Nemo.UI.GetActionPack()
	local lLists	    = ''
	local lAction		= ''
	local lAlert       	= ''
	local lShiftKeyDown = IsShiftKeyDown() 
	local lIsAltKeyDown = IsAltKeyDown() 
	local lImportPrefix = "Nemo.D.ImportType=\"actionpack\";\nNemo.D.ImportVersion="..GetAddOnMetadata("Nemo", "Version")..";\nNemo.D.ImportName=[=["..tostring(Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].text).."]=];\n"
	


	lAction = lAction..Nemo.GetActionExportString( Nemo.DB.profile.options.sr, Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].text )
	--Append to the list string if a list is found in the criteria
	if ( Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].criteria and ( string.find(Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].criteria, 'InList%(') ) ) then
		for lListName in string.gmatch(Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].criteria, 'InList%(".-","(.-)"') do --The criteria could use multiple lists
			local lListKey = Nemo:SearchTable(Nemo.D.LTMC, "text", lListName)
			if ( lListKey ) then
				for EntryKey,_ in pairs(Nemo.D.LTMC[lListKey].entrytree) do
					local EntryDB = Nemo.D.LTMC[lListKey].entrytree[EntryKey]
-- print("list value="..EntryDB.value)
					local lID, lType = strmatch( EntryDB.value, 'CreateListEntryPanel%("([^"]+)","(%a)"%)' )
-- print("list lID="..tostring(lID)) 
					if ( not lType or not lID) then
						print(L["utils/debug/prefix"]..string.format(L["rotations/exportfail/E1"], tostring(lListName) ) )
						return 
					end
					lLists = lLists..Nemo.GetListEntryExportString( lListKey, EntryKey )
				end
				Nemo.UI.fMain:SetStatusText( "" )-- Clear any errors
			else
				Nemo.UI.fMain:SetStatusText( string.format(L["rotation/export/error1"], Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].text, tostring(lListName) ) ) -- The action references a list that does not exists
			end
		
		end			
	end
	--Append to the alertname string if an alert is used
	lAlert = (Nemo.GetAlertExportString( Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].an ) or '')
	-- Nemo:dprint("lAlertString===========================\n"..tostring(lAlertString))

-- Nemo:dprint("--lLists===========================\n"..tostring(lLists))
-- Nemo:dprint("--lAction===========================\n"..tostring(lAction))
-- Nemo:dprint("--lAlertString===========================\n"..tostring(lAlertString))

	if ( lShiftKeyDown ) then	
		return lImportPrefix..lLists..lAction..lAlert  -- script format
	elseif ( lIsAltKeyDown ) then
		return "<<code lua>>\n"..lImportPrefix..lLists..lAction..lAlert..'<</code>>'  -- wiki creole format
	else
		return '[==['..Nemo:Serialize( lImportPrefix..lLists..lAction..lAlert )..']==]'  -- One line export
	end
end
function Nemo.UI.CriteriaAddOnClick(criteriakey)
	local lCriteria = Nemo.D.criteria[criteriakey].f() or ""
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel.mlebCriteria:SetText( (Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel.mlebCriteria:GetText() or "")..lCriteria )
	Nemo.UI.DB.criteria = (Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel.mlebCriteria:GetText() or "")
	
	Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] )
	
	-- Nemo.AButtons.bInitComplete = false											-- Criteria Add was clicked need initialization to create new criteria function
end
function Nemo.UI.tgCriteriaOnGroupSelected(...)
	local args = {...}
	args[1]:RefreshTree()														--Refresh the tree so .selected gets updated
	Nemo.UI.sgMain.tgMain.sgPanel.tgCriteria.sgCriteriaPanel:ReleaseChildren()	--Clears the right panel in the criteria tree
	Nemo.UI.SelectedCriteriaTreeButton=nil										--Save the selected criteria for global scope
	for k,v in pairs(args[1].buttons) do
		if ( v.selected ) then Nemo.UI.SelectedCriteriaTreeButton = v end
	end
	if( not Nemo.UI.SelectedCriteriaTreeButton ) then
		--Nemo:dprint("Error: tgCriteriaOnGroupSelected called without a button selection")
	else
		local func, errorMessage = loadstring(Nemo.UI.SelectedCriteriaTreeButton.value)	-- Use the .value field to create a function specific to the button
		if( not func ) then	Nemo:dprint("Error: tgCriteriaOnGroupSelected loadingstring:"..Nemo.UI.SelectedCriteriaTreeButton.value.." Error:"..errorMessage) return end
		local success, errorMessage = pcall(func);								-- Call the button specific function we loaded
		if( not success ) then
			print(L["utils/debug/prefix"].."Error criteria pcall:"..errorMessage)
		end
	end
end
function Nemo.UI.mlebActionTypeAttOnTextChanged(...)
	local args = {...}
	if ( not Nemo:isblank( args[1] ) and args[1]=="spell" ) then
		local spellID = Nemo.GetSpellID( args[3] )
		Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link:SetText( (GetSpellLink( spellID ) or "")..' '..(spellID or "") )
		Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link.Tooltip = GetSpellLink( spellID )
	end
	if ( not Nemo:isblank( args[1] ) and args[1]=="macrotext" ) then
		local spellID = Nemo.GetSpellID( Nemo.UI:GetMacrotextTooltip( args[2] ) )
		Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link:SetText( (GetSpellLink( spellID ) or "")..' '..(spellID or "") )
		Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link.Tooltip = GetSpellLink( spellID )
	end
	if ( not Nemo:isblank( args[1] ) and args[1]=="item" ) then
		local itemID = Nemo.GetItemId( args[2] )
		if ( itemID ) then
			Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link:SetText( (select(2,GetItemInfo( itemID )) or "")..' '..(itemID or "") )
			Nemo.UI.sgMain.tgMain.sgPanel.ilAtt2Link.Tooltip = select(2,GetItemInfo( itemID ))
		end
	end
end
function Nemo.UI.SetMultiActionValue( key, value)
	for atk, action in pairs( Nemo.D.RTMC[Nemo.UI.STL[2]].children ) do
		action[key] = value
	end
end
function Nemo.UI.bActionDeleteOnClick(...)
	if ( InCombatLockdown() ) then Nemo.UI.fMain:SetStatusText( L["common/error/deleteincombat"] ) return end
	Nemo.UI.fMain:SetStatusText( '' )
	local deleteAKey    = Nemo.UI.STL[3]

	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value)	-- Select parent tree before deleting so table does not get messed up
	Nemo.AButtons.Frames[Nemo.D.RTMC[Nemo.UI.STL[2]].text][deleteAKey]:Hide()
	-- Nemo.AButtons.Frames[Nemo.D.RTMC[Nemo.UI.STL[2]].text][deleteAKey]=nil		-- Hide and remove the associated ActionButtonFrame (15-Oct-13 this was causing a bug with macrotext icons and other icons to not display in autonomous actions)
	tremove(Nemo.D.RTMC[Nemo.UI.STL[2]].children, deleteAKey)
	Nemo.UI.sgMain.tgMain:RefreshTree() 										-- Gets rid of the action from the tree
	Nemo.UI.sgMain.tgMain.sgPanel:ReleaseChildren() 							-- clears the right panel
	Nemo.AButtons.bInitComplete = false											-- Action deleted initialization is needed
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value)
end
function Nemo.UI.bMoveAction(movevalue)
	if ( InCombatLockdown() ) then Nemo.UI.fMain:SetStatusText( L["common/error/priorityincombat"] ) return end	
	local SavedAction	= Nemo:CopyTable(Nemo.UI.DB)							-- Deepcopy the action from the profile db
	local SavedNemoFrame= Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]]
	local maxKey		= #(Nemo.D.RTMC[Nemo.UI.STL[2]].children)
	tremove(Nemo.D.RTMC[Nemo.UI.STL[2]].children, Nemo.UI.STL[3])
	
	Nemo.UI.sgMain.tgMain:RefreshTree() 										-- Gets rid of the action from the tree
	Nemo.UI.sgMain.tgMain.sgPanel:ReleaseChildren() 							-- clears the right panel
	
	
	Nemo.UI.STL[3] = Nemo.UI.STL[3]+movevalue									-- Now change the key value to up or down
	if ( Nemo.UI.STL[3] < 1) then Nemo.UI.STL[3] = 1 end
	if ( Nemo.UI.STL[3] > maxKey ) then Nemo.UI.STL[3] = maxKey end
	tinsert(Nemo.D.RTMC[Nemo.UI.STL[2]].children, (Nemo.UI.STL[3]), SavedAction)
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].value)
	Nemo.UI.SetebTexture( SavedNemoFrame )
	Nemo.AButtons.bInitComplete = false	--initialization needed otherwise shift right click doesnt work after move
end
function Nemo.UI.ebRenameActionOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3] ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )
		return
	end
	local NewActionText = args[3]
	local NewActionValue = 'Nemo.UI:CAP([=['..NewActionText..']=])'

	if ( Nemo:SearchTable(Nemo.D.RTMC[Nemo.UI.STL[2]].children, "text", NewActionText) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], NewActionText) )
	else
		Nemo.UI.fMain:SetStatusText( "" ) 											-- Clear any previous errors
		Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].text = NewActionText
		Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].value = NewActionValue
		Nemo.UI.sgMain.tgMain:RefreshTree() 									-- Refresh the tree
		Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].value)
		Nemo.AButtons.bInitComplete = false	-- Action Alert renamed, this initialization is needed
	end
end
function Nemo.UI.ebActionAlertNameOnEnterPressed(...)
	if ( Nemo.UI.EntryHasErrors( select(3,...) ) and not Nemo:isblank( select(3,...) ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], select(3,...) ) )
		return
	elseif ( not Nemo:SearchTable(Nemo.D.ATMC, "text", select(3,...)) and not Nemo:isblank( select(3,...) ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/dnexist"], select(3,...) ) )
		return
	else
		Nemo.UI.fMain:SetStatusText( '' )
		Nemo.UI.DB.an = select(3,...)
	end
	Nemo.AButtons.bInitComplete = false	-- Alert added to action, this initialization is needed
end


function Nemo.UI.SetebTexture( NemoSABFrame )
-- print("SetebTexture "..tostring( NemoSABFrame:GetName() ) )
	local texture = Nemo.UI:GetActionTexture( NemoSABFrame )
-- print("setting image to "..tostring(texture))
	Nemo.UI.sgMain.tgMain.sgPanel.ebTextureIcon:SetImage( texture )
end
function Nemo.UI.GetAttTooltip(...)
	local args = {...}
	--args[1] = att1 or att2
	if ( Nemo:isblank(Nemo.UI.DB.at) ) then return end
	local lLKey='action/mleditbox/'..(Nemo.UI.DB.at or "")..'/'..args[1]..'tt' 	--Build the localization key
	return L[lLKey]
end