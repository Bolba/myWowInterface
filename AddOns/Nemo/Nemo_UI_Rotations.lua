local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--*****************************************************
--Rotation Utility functions
--*****************************************************
function Nemo.UI.SetRotationForCurrentSpec()
	local specID = GetSpecialization()
	if ( specID and specID>0 ) then
		for rtk,rotation in pairs(Nemo.D.RTMC) do
			if ( rotation.ts == specID ) then
				Nemo.UI.SelectRotation( rotation.text, false )
				return
			end
		end
	end
	local talentGroup = GetActiveSpecGroup()
	if ( talentGroup and talentGroup > 0 ) then
		for rtk,rotation in pairs(Nemo.D.RTMC) do
			if ( rotation.ts == ( talentGroup+3 ) ) then
				Nemo.UI.SelectRotation( rotation.text, false )
				return
			end
		end
	end

end
function Nemo.UI.GetRotationForActiveTalentGroup()
	local talentGroup = GetActiveSpecGroup()
	if ( talentGroup and talentGroup > 0 ) then
		for rtk,rotation in pairs(Nemo.D.RTMC) do
			if ( rotation.ts == ( talentGroup+3 ) ) then return rotation.text end
		end
	end
end
function Nemo.AddRotation( RotationName, ShowError, TalentSpec )
	if ( Nemo.UI.EntryHasErrors( RotationName ) ) then
		if ( Nemo.UI.sgMain and ShowError ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], RotationName) ) end
		return nil
	end
	local lRotationExists   = Nemo:SearchTable(Nemo.D.RTMC, "text", RotationName)
	local lNewRotationValue = 'Nemo.UI:CreateRotationPanel([=['..RotationName..']=])'
	local lNewRotationText  = RotationName
	if ( Nemo.D.UpdateMode==0 and lRotationExists ) then
		local iSuffix = 0
		lNewRotationText = lNewRotationText..'_'
		while lRotationExists do
			iSuffix = iSuffix+1
			lRotationExists = Nemo:SearchTable(Nemo.D.RTMC, "text", lNewRotationText..iSuffix)
		end
		lNewRotationValue = 'Nemo.UI:CreateRotationPanel([=['..lNewRotationText..iSuffix..']=])'
		lNewRotationText = lNewRotationText..iSuffix
	end
	Nemo.D.ImportName = lNewRotationText
	local lNewRotation = { value = lNewRotationValue, text = lNewRotationText, icon="Interface\\PaperDollInfoFrame\\UI-GearManager-Undo", children = {} }
	lRotationExists = Nemo:SearchTable(Nemo.D.RTMC, "text", lNewRotationText)
	if ( lRotationExists ) then
		if ( Nemo.UI.sgMain and ShowError ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], lNewRotationText) ) end
	else
		table.insert( Nemo.D.RTMC, lNewRotation)
		if ( Nemo.UI.sgMain ) then Nemo.UI.fMain:SetStatusText( '' ) end -- Clear any previous errors
		lRotationExists = Nemo:SearchTable(Nemo.D.RTMC, "text", lNewRotationText)
	end
	lRotationExists = Nemo:SearchTable(Nemo.D.RTMC, "text", lNewRotationText)
	if ( lRotationExists ) then 
		local RotationDB = Nemo.D.RTMC[lRotationExists]
		if ( not Nemo:isblank(TalentSpec) ) then RotationDB.ts   = TalentSpec end
	end
	if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end	
	Nemo.AButtons.bInitComplete = false	-- Rotation was added
	return lNewRotationText, lRotationExists
end
function Nemo.GetRotationExportString( RotationName )
	local lRotationExists = Nemo:SearchTable(Nemo.D.RTMC, "text", RotationName)
	if ( not lRotationExists ) then return end
	local RotationDB = Nemo.D.RTMC[lRotationExists]
	local lRExport = 'Nemo.AddRotation([=['..RotationName..']=],false'	
	if ( not Nemo:isblank(RotationDB.ts) ) then lRExport = lRExport..','..RotationDB.ts..');' else lRExport = lRExport..',nil);' end
	return lRExport.."\n"
end
function Nemo.DeleteRotation( RotationName )
	if ( InCombatLockdown() ) then print(L["utils/debug/prefix"]..L["common/error/deleteincombat"]); return end
	if ( Nemo.UI.fMain ) then Nemo.UI.fMain:SetStatusText( '' ) end

	local DeleteKey				= nil
	local DeleteKeyText			= nil
	local bHideGUI      		= true
	local userSettingForHide	= Nemo.DB.profile.options.hidenemoactions
	
	if ( Nemo:isblank(RotationName) ) then
		bHideGUI  = false
		DeleteKey = Nemo.UI.STL[2]

	else
		DeleteKey = Nemo:SearchTable(Nemo.D.RTMC, "text", RotationName)
	end
	if ( DeleteKey ) then
		DeleteKeyText = Nemo.D.RTMC[DeleteKey].text
		SABDeleteKey = Nemo:SearchTable(Nemo.AButtons.Frames[DeleteKeyText], "text", DeleteKeyText)
		tremove(Nemo.D.RTMC, DeleteKey)
		if ( Nemo.DB.profile.options.sr == DeleteKeyText ) then
			Nemo.DB.profile.options.srk = nil
			Nemo.DB.profile.options.sr  = nil
		end
		if ( Nemo.UI.fMain and bHideGUI ) then Nemo.UI.fMain:Hide() end					--Hide the main gui if deleting from localization file
		if ( Nemo.AButtons.Frames[DeleteKeyText] ) then
			
			Nemo.DB.profile.options.hidenemoactions = true
			for atk, NemoSABFrame in pairs(Nemo.AButtons.Frames[DeleteKeyText]) do
				NemoSABFrame:EnableMouse(false)
				NemoSABFrame:Hide()
			end
			--if ( Nemo.AButtons.Frames[DeleteKeyText] ) then Nemo.AButtons.Frames[DeleteKeyText] = nil end  -- Something is strange about deleted frames, they dont refresh textures so don't delete frames, just reuse them
			Nemo.DB.profile.options.hidenemoactions = userSettingForHide
		end
		Nemo.AButtons.bInitComplete = false												-- Rotation was deleted
		Nemo.UI.HideTooltip()
		if ( Nemo.UI.sgMain ) then
			Nemo.UI.sgMain.tgMain:RefreshTree() 										-- Gets rid of the rotation from the tree
			Nemo.UI.sgMain.tgMain.sgPanel:ReleaseChildren() 							-- clears the right panel
			Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value)
		end
		if (Nemo.D.LDB) then															-- cleanup lib data broker text
			if ( not Nemo:isblank(Nemo.DB.profile.options.sr) ) then
				Nemo.D.LDB.text = L["common/nemo"].." "..tostring( Nemo.DB.profile.options.sr or "" )
			else
				Nemo.D.LDB.text = L["common/nemo"]
			end
		end
	end
end
--*****************************************************
--Rotations Panel
--*****************************************************
function Nemo.UI:CreateRotationsPanel()
	-- Pause or resume the rightsgPanel fill layout if you need it or not
	Nemo.UI.sgMain.tgMain.sgPanel:PauseLayout()
	-- new rotation name edit box
	Nemo.UI.sgMain.tgMain.sgPanel.ebRotationName = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebRotationName )
	Nemo.UI.sgMain.tgMain.sgPanel.ebRotationName:SetLabel( L["rotations/ebRotationName/l"] )
	Nemo.UI.sgMain.tgMain.sgPanel.ebRotationName:SetWidth(480)
	Nemo.UI.sgMain.tgMain.sgPanel.ebRotationName:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", 5, 0);
	Nemo.UI.sgMain.tgMain.sgPanel.ebRotationName:SetCallback( "OnEnterPressed", Nemo.UI.ebRotationNameOnEnterPressed )

	-- Rotation Import edit box
	local mlebRotationImport = Nemo.UI:Create("MultiLineEditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( mlebRotationImport )
	mlebRotationImport:SetLabel( L["rotations/mlebRotationImport/l"] )
	mlebRotationImport:SetWidth(480)
	mlebRotationImport:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.ebRotationName.frame, "BOTTOMLEFT", 0, 0)
	mlebRotationImport:SetCallback( "OnEnterPressed", function(self)
		Nemo.D.UpdateMode = 0 --Create new names, do not update		
		Nemo.UI.RotationImport( self:GetText(), true )
	end )

	Nemo.UI.sgMain.tgMain.sgPanel:ResumeLayout()
end
--Rotations Panel Callbacks----------------------------
function Nemo.UI.ebRotationNameOnEnterPressed(...)
	local lNewRotationName = select(3,...)
	Nemo.AddRotation( lNewRotationName, true )
end
function Nemo.UI.RotationImport( ImportString, ShowErrors )
	local success, iString
	
	if ( strfind( ImportString, "actions%+%=") or strfind( ImportString, "actions%=") ) then
		success, iString = Nemo:Deserialize( Nemo.UI.ParseSimcraftRotation( ImportString ) )
	elseif ( strfind( ImportString, '~JNemo') ) then
	
-- Nemo:dprint("need to deserialize")	
		success, iString = Nemo:Deserialize( ImportString )
	else
-- Nemo:dprint("script import")	
		--Fix the newlines on or,and
		-- ImportString = string.gsub(ImportString, '%)and', ")\nand")
		-- ImportString = string.gsub(ImportString, '%)%sand%s', ")\nand ")
		-- ImportString = string.gsub(ImportString, '%sand%sNemo', "\nand Nemo")
		-- ImportString = string.gsub(ImportString, '%)or', ")\nor")
		-- ImportString = string.gsub(ImportString, '%)%sor%s', ")\nor ")		
		-- ImportString = string.gsub(ImportString, '%sor%sNemo', "\nor Nemo")

		ImportString = string.gsub(ImportString, "\10", "\n")
		
		-- local tests=[[1
-- 2]];Nemo:dprint( strbyte( tests, 2) )
		
	-- Nemo:dprint( "1"..tostring( string.match([[test
-- test1]],"\10") ).."2" )

		ImportString = Nemo:Serialize( ImportString )  -- Serialize the import string to preserve spaces and new lines
		success, iString = Nemo:Deserialize( ImportString )

		--Option 2 does not work
		-- success = true
		-- iString = ImportString
		
	end	
	
	if ( not success or Nemo:isblank( iString ) or type(iString) == "table" ) then
		if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() and ShowErrors ) then Nemo.UI.fMain:SetStatusText( L["rotations/rimportfail"]..':E1' ) end
		if ( ShowErrors ) then print(L["utils/debug/prefix"]..L["rotations/rimportfail"]..':E1' ) end
		return
	end
	
-- Nemo:dprint("calling import on ==========================\n"..tostring(iString))
	--pcall stuff
	if ( Nemo.D.RunCode( iString, L["utils/debug/prefix"]..L["rotations/rimportfail"]..':E2', L["utils/debug/prefix"].."Error import pcall:", true, true  ) == 0 ) then
		if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then
			if ( Nemo.D.ImportType and Nemo.D.ImportType == 'actionpack' ) then
				Nemo.UI.fMain:SetStatusText( L["rotation/actionpackimportsuccess"]..(Nemo.D.ImportName or "") )
			else
				Nemo.UI.fMain:SetStatusText( L["rotations/importsuccess"]..(Nemo.D.ImportName or "") )
			end
		end
	end
	
	-- local func, errorMessage = loadstring(iString)
	-- if( not func and ShowErrors ) then
		-- print(L["utils/debug/prefix"]..L["rotations/rimportfail"]..':E2' )
		-- Nemo:dprint(tostring(errorMessage))
		-- if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then Nemo.UI.fMain:SetStatusText( L["rotations/rimportfail"]..':E2:' ) end
		-- return
	-- end
	
	-- success, errorMessage = pcall(func);								-- Call the button specific function we loaded
	-- if( not success ) then
		-- print(L["utils/debug/prefix"].."Error import pcall:"..errorMessage)
	-- end


end
--*****************************************************
--Specific Rotation Panel
--*****************************************************
function Nemo.UI:CreateRotationPanel(RotationName)
	Nemo.UI.DB = {}
	Nemo.UI.DB = Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]]
	Nemo.UI.SelectRotation(Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]].text, true)
	-- Pause or resume the rightsgPanel fill layout if you need it or not
	Nemo.UI.sgMain.tgMain.sgPanel:PauseLayout()
	Nemo.AButtons.bInitComplete = false	-- Rotation Panel gui was opened

	-- Rename Rotation edit box
	local ebRenameRotation = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebRenameRotation )
	ebRenameRotation:SetLabel( L["rotation/ebRenameRotation/l"] )
	ebRenameRotation:SetWidth(480)
	ebRenameRotation:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", 0, 0)
	ebRenameRotation:SetCallback( "OnEnterPressed", Nemo.UI.ebRenameRotationOnEnterPressed )
	ebRenameRotation:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ebRenameRotation/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebRenameRotation:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebRenameRotation:SetText( Nemo.UI.DB.text )

	-- New Action edit box
	local ebActionName = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebActionName )
	ebActionName:SetLabel( L["rotation/ebActionName/l"] )
	ebActionName:SetWidth(480)
	ebActionName:SetPoint("TOPLEFT", ebRenameRotation.frame, "BOTTOMLEFT", 0, 0)
	ebActionName:SetCallback( "OnEnterPressed", Nemo.UI.ebActionNameOnEnterPressed )
	ebActionName:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ebActionName/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebActionName:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Copy Rotation edit box
	local ebCopyRotation = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebCopyRotation )
	ebCopyRotation:SetLabel( L["rotation/ebCopyRotation/l"] )
	ebCopyRotation:SetWidth(480)
	ebCopyRotation:SetPoint("TOPLEFT", ebActionName.frame, "BOTTOMLEFT", 0, 0);
	ebCopyRotation:SetCallback( "OnEnterPressed", Nemo.UI.ebCopyRotationOnEnterPressed )
	ebCopyRotation:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ebCopyRotation/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebCopyRotation:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Rotation export
	local ebRotationExport = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebRotationExport )
	ebRotationExport:SetLabel( L["rotation/ebRotationExport/l"] )
	ebRotationExport:SetWidth(480)
	ebRotationExport:SetPoint("TOPLEFT", ebCopyRotation.frame, "BOTTOMLEFT", 0, 0)
	ebRotationExport:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ebRotationExport/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebRotationExport:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Export button
	local bExport = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bExport )
	bExport:SetText( L["rotation/bExport/l"] )
	bExport:SetWidth(100)
	bExport:SetPoint("TOPLEFT", ebRotationExport.frame, "BOTTOMLEFT", 0, 0);
	bExport:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/bExport/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	bExport:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	bExport:SetCallback( "OnClick", function()
		ebRotationExport:SetText( Nemo.UI.RotationExport() )
		ebRotationExport.editbox:SetFocus(0)
		ebRotationExport.editbox:SetCursorPosition(0)
		ebRotationExport.editbox:HighlightText()
	end )

	local ebShareExport = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebShareExport )
	ebShareExport:SetLabel( L["rotation/ebShareExport/l"] )
	ebShareExport:SetWidth(480)
	ebShareExport:SetPoint("TOPLEFT", bExport.frame, "BOTTOMLEFT", 0,0)
	ebShareExport:SetCallback( "OnEnterPressed", function(self) Nemo.UI.ebShareExportOnEnterPressed(self) end )
	ebShareExport:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ebShareExport/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebShareExport:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Bind to spec Dropdown
	Nemo.UI.sgMain.tgMain.sgPanel.ddBindToSpec = Nemo.UI:Create("Dropdown")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ddBindToSpec )
	local ddBindToSpec = Nemo.UI.sgMain.tgMain.sgPanel.ddBindToSpec
	--todo write a get talent spec function
	ddBindToSpec:SetList( Nemo.UI.ddBindToSpecGetList() )
	ddBindToSpec:SetLabel( L["rotation/ddBindToSpec/l"] )
	ddBindToSpec:SetWidth(480)
	ddBindToSpec:SetPoint("TOPLEFT", ebShareExport.frame, "BOTTOMLEFT", 0, 0)
	ddBindToSpec:SetCallback( "OnValueChanged", Nemo.UI.ddBindToSpecOnValueChanged )
	ddBindToSpec:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ddBindToSpec/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	ddBindToSpec:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ddBindToSpec:SetValue( Nemo.UI.DB.ts or nil )

	-- ActionPack Import
	local mlebActionPackImport = Nemo.UI:Create("MultiLineEditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( mlebActionPackImport )
	mlebActionPackImport:SetLabel( L["rotation/mlebActionPackImport/l"] )
	mlebActionPackImport:SetWidth(480)
	mlebActionPackImport:SetPoint("TOPLEFT", ddBindToSpec.frame, "BOTTOMLEFT", 0, 0)
	mlebActionPackImport:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/mlebActionPackImport/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	mlebActionPackImport:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	mlebActionPackImport:SetCallback( "OnEnterPressed", function(self)
		Nemo.D.UpdateMode = 0 --Create new names, do not update
		if ( not string.match( self:GetText(), 'Nemo%.D%.ImportType="actionpack"' ) ) then
			if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then Nemo.UI.fMain:SetStatusText( L["rotations/rimportfail/E4"] ) end
			return
		end
		Nemo.D.ImportIndex = 0
		Nemo.UI.RotationImport( self:GetText(), true )
	end )

	-- Move up Rotation interactive label
	local ilRMoveUp = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilRMoveUp )
	ilRMoveUp:SetWidth(40);ilRMoveUp:SetHeight(40)
	ilRMoveUp:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Up")
	ilRMoveUp:SetImageSize(40, 40)
	ilRMoveUp:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Highlight")
	ilRMoveUp:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", -5, -545);
	ilRMoveUp:SetCallback( "OnClick", function() Nemo.UI.bMoveRotation(-1) end )
	ilRMoveUp:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ilRMoveUp/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilRMoveUp:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Move down Rotation interactive label
	local ilRMoveDown = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilRMoveDown )
	ilRMoveDown:SetWidth(40);ilRMoveDown:SetHeight(40)
	ilRMoveDown:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Up")
	ilRMoveDown:SetImageSize(40, 40)
	ilRMoveDown:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Highlight")
	ilRMoveDown:SetPoint("TOPLEFT", ilRMoveUp.frame, "BOTTOMLEFT", 0, 5);
	ilRMoveDown:SetCallback( "OnClick", function() Nemo.UI.bMoveRotation(1) end )
	ilRMoveDown:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/ilRMoveDown/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilRMoveDown:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- HotKey Keybind
	local bRotationKeybind = Nemo.UI:Create("Keybinding")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bRotationKeybind )
	bRotationKeybind:SetWidth(100)
	bRotationKeybind:SetLabel(L["common/hotkey/l"])
	bRotationKeybind:SetPoint("TOPLEFT", ilRMoveDown.frame, "TOPRIGHT", 0, 10);
	bRotationKeybind:SetCallback( "OnKeyChanged", function(self)
		if ( InCombatLockdown() ) then Nemo.UI.fMain:SetStatusText( L["common/error/keybindincombat"] )	end
		for rtk,rotation in pairs(Nemo.D.RTMC) do
			if ( rotation.hk == self:GetKey() ) then
				rotation.hk = nil -- Clear out any matching keybinds
			end
		end
		Nemo.UI.DB.hk = self:GetKey()
		Nemo.AButtons.bInitComplete = false		-- Rotation Keybind was changed
		self:SetKey( Nemo.UI.DB.hk or L["action/bActionKeybind/blizzard"])
	end )
	bRotationKeybind:SetKey( Nemo.UI.DB.hk or L["rotation/bRotationKeybind/l"] )
	bRotationKeybind:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/bRotationKeybind/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	bRotationKeybind:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Delete Rotation button
	local bRotationDelete = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bRotationDelete )
	bRotationDelete:SetWidth(100)
	bRotationDelete:SetPoint("TOPLEFT", bRotationKeybind.frame, "TOPRIGHT", 0, -20);
	bRotationDelete:SetText(L["common/delete"])
	bRotationDelete:SetCallback( "OnClick", function() Nemo.DeleteRotation() end )
	bRotationDelete:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["rotation/bRotationDelete/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	bRotationDelete:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	Nemo.UI.sgMain.tgMain.sgPanel:ResumeLayout()
end
--Rotation Panel Callbacks-----------------------------
function Nemo.UI.ebRenameRotationOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3] ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )
		return
	end
	local NewRotationText = args[3]
	local NewRotationValue = 'Nemo.UI:CreateRotationPanel([=['..args[3]..']=])'
	if ( Nemo:SearchTable(Nemo.D.RTMC, "text", args[3]) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], args[3]) )
	else
		Nemo.UI.fMain:SetStatusText( "" ) 										-- Clear any previous errors
		Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]].text = NewRotationText
		Nemo.DB.profile.treeMain[Nemo.UI.STL[1]].children[Nemo.UI.STL[2]].value = NewRotationValue
		Nemo.UI.sgMain.tgMain:RefreshTree() 									-- Refresh the tree
		Nemo.AButtons.bInitComplete = false										-- Rotation was renamed
		Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..NewRotationValue)
	end
end
function Nemo.UI.ebActionNameOnEnterPressed(...)
	local lNewActionName = select(3, ...)
	Nemo.D.ImportName = Nemo.D.RTMC[Nemo.UI.STL[2]].text
	Nemo.D.ImportType = 'rotation'
	local _,lNewActionKey = Nemo.AddAction( lNewActionName, true )
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].children[lNewActionKey].value)
end
function Nemo.UI.ebCopyRotationOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3] ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )
		return
	end
	if ( Nemo:SearchTable(Nemo.D.RTMC, "text", args[3]) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], args[3]) )
	else
		Nemo.UI.fMain:SetStatusText( "" )
		local NewRotation = Nemo:CopyTable( Nemo.D.RTMC[Nemo.UI.STL[2]] )
		NewRotation.text = args[3]
		NewRotation.value = 'Nemo.UI:CreateRotationPanel([=['..args[3]..']=])'
		table.insert( Nemo.D.RTMC, NewRotation)
		Nemo.UI.sgMain.tgMain:RefreshTree() 									-- Gets rid of the action from the tree
		Nemo.AButtons.bInitComplete = false										-- Rotation was copied
	end
end

function Nemo.UI.RotationExport()
	local lLists	    = ''
	local lRotation     = ''
	local lActions      = ''
	local lAlerts       = ''
	local lShiftKeyDown = IsShiftKeyDown() 
	local lIsAltKeyDown = IsAltKeyDown() 
	local lImportPrefix = "Nemo.D.ImportType=\"rotation\";\nNemo.D.ImportVersion="..GetAddOnMetadata("Nemo", "Version")..";\nNemo.D.ImportName=[=["..tostring(Nemo.DB.profile.options.sr).."]=];\n"

	lRotation = Nemo.GetRotationExportString( Nemo.DB.profile.options.sr )
	
	for atk,action in pairs(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children) do
		--Append to the action string
		lActions = lActions..Nemo.GetActionExportString( Nemo.DB.profile.options.sr, action.text )
		--Append to the list string if a list is found in the criteria
		if ( action.criteria and ( string.find(action.criteria, 'InList%(') ) ) then
			for lListName in string.gmatch(action.criteria, 'InList%(".-","(.-)"') do --The criteria could use multiple lists
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
					Nemo.UI.fMain:SetStatusText( string.format(L["rotation/export/error1"], action.text, tostring(lListName) ) ) -- The action references a list that does not exists
				end
			
			end			
		end
		--Append to the alertname string if an alert is used
		lAlerts = lAlerts..(Nemo.GetAlertExportString( action.an ) or '')
		-- Nemo:dprint("lAlertString===========================\n"..tostring(lAlertString))
	end
-- Nemo:dprint("--lLists===========================\n"..tostring(lLists))
-- Nemo:dprint("--lActions===========================\n"..tostring(lActions))
-- Nemo:dprint("--lAlertString===========================\n"..tostring(lAlertString))

	if ( lShiftKeyDown ) then	
		return lImportPrefix..lRotation..lLists..lActions..lAlerts  -- script format
	elseif ( lIsAltKeyDown ) then
		return "<<code lua>>\n"..lImportPrefix..lRotation..lLists..lActions..lAlerts..'<</code>>'  -- wiki creole format
	else
		return '[==['..Nemo:Serialize( lImportPrefix..lRotation..lLists..lActions..lAlerts )..']==]'  -- One line export
	end
end

function Nemo.UI.ebShareExportOnEnterPressed( self )

	local lExport = Nemo.UI.RotationExport(false)
	if ( not Nemo:isblank( lExport ) and not Nemo:isblank( self:GetText() ) ) then
		Nemo:SendCommMessage(Nemo.D.Prefix, lExport, 'WHISPER', self:GetText())
	end
end
function Nemo.UI.ddBindToSpecGetList()
	Nemo.D.Specs = {}
	Nemo.D.SpecsSorted = {}
	for specID = 1, 3 do
		local id, name, description, icon, background, role = GetSpecializationInfo(specID)
		if name then
			Nemo.D.Specs[specID] = name
		end
	end
	Nemo.D.Specs[4]=L["rotation/ddBindToSpecGetList/primary"]
	Nemo.D.Specs[5]=L["rotation/ddBindToSpecGetList/secondary"]
	Nemo.D.Specs[6]=L["alert/sounds/_None"]

	return Nemo.D.Specs
end
function Nemo.UI.ddBindToSpecOnValueChanged(...)
	local args = {...}
	Nemo.UI.DB.ts = args[1]:GetValue()
end
function Nemo.UI.bMoveRotation(movevalue)
	local SavedRotation	= Nemo:CopyTable(Nemo.UI.DB)									-- Deepcopy the action from the profile db
	local maxKey		= #(Nemo.D.RTMC)
	tremove(Nemo.D.RTMC, Nemo.UI.STL[2])
	Nemo.UI.STL[2] = Nemo.UI.STL[2]+movevalue											-- Now change the key value to up or down
	if ( Nemo.UI.STL[2] < 1) then Nemo.UI.STL[2] = 1 end
	if ( Nemo.UI.STL[2] > maxKey ) then Nemo.UI.STL[2] = maxKey end
	tinsert(Nemo.D.RTMC, Nemo.UI.STL[2], SavedRotation)
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value)
	-- Nemo.AButtons.bInitComplete = false												-- Rotation was moved in tree
end

