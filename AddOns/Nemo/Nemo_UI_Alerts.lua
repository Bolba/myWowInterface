local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--*****************************************************
--Alert Utility functions
--*****************************************************
function Nemo.AddAlertInteractiveLabelToAction( RotationName, RotationKey, ActionKey, AlertName )
	local NemoSABFrame   =  Nemo.AButtons.Frames[RotationName][ActionKey]
	local lActionAlertIL =  Nemo.AButtons.Frames[RotationName][ActionKey].nemoail	--nemo alert interactive label
	if ( not lActionAlertIL ) then
		Nemo.AButtons.Frames[RotationName][ActionKey].nemoail = Nemo.UI:Create("InteractiveLabel")
		lActionAlertIL = Nemo.AButtons.Frames[RotationName][ActionKey].nemoail
	end
	
	
	local lAlertDBKey = Nemo:SearchTable(Nemo.D.ATMC, "text", AlertName)
	local lAlertDB = Nemo.D.ATMC[lAlertDBKey]
	local lActionDB = Nemo.D.RTMC[RotationKey].children[ActionKey]
-- Nemo:dprint(debugstack())

	if ( Nemo:isblank( lAlertDB ) ) then return end							-- Exit if Alert DB does not exist

	--Set the image location---------------------------------------------------------------
	lActionAlertIL.frame:ClearAllPoints()
	lActionAlertIL.frame:SetPoint("CENTER", UIParent, "CENTER", lAlertDB.tx, lAlertDB.ty)

	--Set the image size-------------------------------------------------------------------	
	local lSize = (Nemo:NilToNumeric(lAlertDB.vats,100)/100)
	lActionAlertIL:SetImageSize(100*lSize, 100*lSize)

	--Set the image vertex color-----------------------------------------------------------
	lActionAlertIL.image:SetVertexColor(lAlertDB.vatr or 1, lAlertDB.vatg or 1, lAlertDB.vatb or 1, lAlertDB.vata or 1)
	
	--Set the texture---------------------------------------------------------------------
	if ( Nemo:isblank( lAlertDB.tp ) or lAlertDB.tp == '_None' ) then
		lActionAlertIL:SetImage('')
	elseif ( lAlertDB.tp == '_Icon' ) then
		 
		local lTexture = Nemo.UI:GetActionTexture( NemoSABFrame )
		if ( lTexture ) then
			lActionAlertIL:SetImage(lTexture)
		else
			lActionAlertIL:SetImage("Interface\\ICONS\\INV_Misc_Fish_09")
		end
	else
		lActionAlertIL:SetImage(lAlertDB.tp)
	end
	--Show the text------------------------------------------------------------------------
	lActionAlertIL:SetText( lAlertDB.txt )
	lActionAlertIL:SetFont( (lAlertDB.f or "Fonts\\FRIZQT__.TTF"), (lAlertDB.fs or 12) )
	lActionAlertIL.frame:EnableMouse(false)
	--Unblock the playsound
	lActionAlertIL.nemolastsoundplayed = 0
	lActionAlertIL.frame:Hide()
end
function Nemo.AddAlert( AlertName, ShowError, AudibleAlert, AudibleAlertCustom, TexturePath, TextureSize, TextureR, TextureG, TextureB, TextureA, TextureX, TextureY, Text, FontSize, Font )
-- print('adding alert0')
	if ( Nemo.UI.EntryHasErrors( AlertName ) ) then
		if ( Nemo.UI.sgMain and ShowError ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], AlertName) ) end
		return nil
	end
-- print('adding alert1')
	local lAlertExists   = Nemo:SearchTable(Nemo.D.ATMC, "text", AlertName)
	local lNewAlertValue = 'Nemo.UI:CreateAlertPanel([=['..AlertName..']=])'
	local lNewAlertText  = AlertName
	if ( Nemo.D.UpdateMode==0 and lAlertExists ) then
		local iSuffix = 0
		lNewAlertText = lNewAlertText..'_'
		while lAlertExists do
			iSuffix = iSuffix+1
			lAlertExists = Nemo:SearchTable(Nemo.D.ATMC, "text", lNewAlertText..iSuffix)
		end
		lNewAlertValue = 'Nemo.UI:CreateAlertPanel([=['..lNewAlertText..iSuffix..']=])'
		lNewAlertText = lNewAlertText..iSuffix
	end
	local lNewAlert = { value = lNewAlertValue, text = lNewAlertText }
	lAlertExists = Nemo:SearchTable(Nemo.D.ATMC, "text", lNewAlertText)
	if ( lAlertExists ) then
		if ( Nemo.UI.sgMain and ShowError ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], lNewAlertText) ) end
		if ( Nemo.D.UpdateMode==3 ) then return lNewAlertText, lAlertExists end --do not update or create new object if they exist
	else
-- print('adding alert')
		table.insert( Nemo.D.ATMC, lNewAlert)
		if ( Nemo.UI.sgMain ) then
			Nemo.UI.fMain:SetStatusText( '' )-- Clear any previous errors
		end
	end
	lAlertExists = Nemo:SearchTable(Nemo.D.ATMC, "text", lNewAlertText)
	if ( lAlertExists ) then 
		local AlertDB = Nemo.D.ATMC[lAlertExists]
		if ( not Nemo:isblank(AudibleAlert) )	then AlertDB.aa  = AudibleAlert end
		if ( not Nemo:isblank(AudibleAlertCustom) )	then AlertDB.aac = AudibleAlertCustom end
		if ( not Nemo:isblank(TexturePath) )    then AlertDB.tp    = TexturePath end
		if ( not Nemo:isblank(TextureSize) )    then AlertDB.vats  = TextureSize end
		if ( not Nemo:isblank(TextureR) )   	then AlertDB.vatr  = TextureR end
		if ( not Nemo:isblank(TextureG) )		then AlertDB.vatg  = TextureG end
		if ( not Nemo:isblank(TextureB) )		then AlertDB.vatb  = TextureB end
		if ( not Nemo:isblank(TextureA) )		then AlertDB.vata  = TextureA end
		if ( not Nemo:isblank(TextureX) ) 		then AlertDB.tx  = TextureX end
		if ( not Nemo:isblank(TextureY) ) 		then AlertDB.ty  = TextureY end
		if ( not Nemo:isblank(Text) ) 			then AlertDB.txt = Text end
		if ( not Nemo:isblank(FontSize) ) 		then AlertDB.fs  = FontSize end
		if ( not Nemo:isblank(Font) ) 			then AlertDB.f   = Font end
	end
	if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end
	Nemo.AButtons.bInitComplete = false	-- New Alert added with main AddAlert function
	return lNewAlertText, lAlertExists
end
function Nemo.GetAlertExportString( AlertName )
	local lAlertExists =  Nemo:SearchTable(Nemo.D.ATMC, "text", AlertName or '')
	if ( not lAlertExists ) then return end
	local AlertDB = Nemo.D.ATMC[lAlertExists]
-- print("here exporting string "..AlertDB.aac)
	local lAExport = 'Nemo.AddAlert([=['..AlertName..']=],false'
	if ( not Nemo:isblank(AlertDB.aa) )	  then lAExport = lAExport..',[=['..AlertDB.aa..']=]' else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.aac) )  then lAExport = lAExport..',[=['..AlertDB.aac..']=]' else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.tp) )	  then lAExport = lAExport..',[=['..AlertDB.tp..']=]' else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.vats) ) then lAExport = lAExport..','..AlertDB.vats else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.vatr) ) then lAExport = lAExport..','..AlertDB.vatr else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.vatg) ) then lAExport = lAExport..','..AlertDB.vatg else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.vatb) ) then lAExport = lAExport..','..AlertDB.vatb else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.vata) ) then lAExport = lAExport..','..AlertDB.vata else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.tx) )	  then lAExport = lAExport..','..AlertDB.tx else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.ty) )	  then lAExport = lAExport..','..AlertDB.ty else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.txt) )  then lAExport = lAExport..',[=['..AlertDB.txt..']=]' else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.fs) )	  then lAExport = lAExport..','..AlertDB.fs else lAExport = lAExport..',nil' end
	if ( not Nemo:isblank(AlertDB.f) )	  then lAExport = lAExport..',[=['..AlertDB.f..']=]);' else lAExport = lAExport..',nil);' end
-- print("returning exported string "..lAExport)
	return lAExport.."\n"
end
--*****************************************************
--Alerts Panel
--*****************************************************
function Nemo.UI:CreateAlertsPanel()
	-- Pause or rightsgPanel fill layout so we can position correctly
	Nemo.UI.sgMain.tgMain.sgPanel:PauseLayout()
	
	-- New alert name edit box
	local ebAlertName = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebAlertName )
	ebAlertName:SetLabel( L["alerts/ebAlertName/l"] )
	ebAlertName:SetWidth(250)
	ebAlertName:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", 0, 0);
	ebAlertName:SetCallback( "OnEnterPressed", Nemo.UI.ebAlertNameOnEnterPressed )

	Nemo.UI.sgMain.tgMain.sgPanel:ResumeLayout()
end
--Alerts Panel Callbacks----------------------------
function Nemo.UI.ebAlertNameOnEnterPressed(...)
	local lNewAlertName = select(3, ...)
	local _,lNewAlertKey = Nemo.AddAlert( lNewAlertName, true )
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.ATM.value.."\001"..Nemo.D.ATMC[lNewAlertKey].value)
	

	
	-- local args = {...}
	-- if ( Nemo.UI.EntryHasErrors( args[3] ) ) then
		-- Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )
		-- return
	-- end
	-- local NewAlert = { value = 'Nemo.UI:CreateAlertPanel([=['..args[3]..']=])', text = args[3] }
	-- if ( Nemo:SearchTable(Nemo.D.ATMC, "text", args[3]) ) then
		-- Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], args[3]) )
	-- else
		-- Nemo.UI.fMain:SetStatusText( "" ) 										--Clear any previous errors
		-- table.insert( Nemo.D.ATMC, NewAlert)
		-- Nemo.UI.sgMain.tgMain:RefreshTree()
		-- Nemo.AButtons.bInitComplete = false
	-- end
end
--*****************************************************
--Specific Alert Panel
--*****************************************************
function Nemo.UI:CreateAlertPanel(AlertName)
	Nemo.UI.DB = {}
	Nemo.UI.DB = Nemo.D.ATMC[Nemo.UI.STL[2]]

	-- Pause or rightsgPanel fill layout so we can position correctly
	Nemo.UI.sgMain.tgMain.sgPanel:PauseLayout()
	
	-- Hide all alerts
	Nemo.D.lastalertname = AlertName

	-- Rename Alert edit box
	local ebRenameAlert = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebRenameAlert )
	ebRenameAlert:SetLabel( L["alert/ebRenameAlert/l"] )
	ebRenameAlert:SetWidth(485)
	ebRenameAlert:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", 0, 0)
	ebRenameAlert:SetCallback( "OnEnterPressed", Nemo.UI.ebRenameAlertOnEnterPressed )
	ebRenameAlert:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ebRenameAlert/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebRenameAlert:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebRenameAlert:SetText( Nemo.UI.DB.text )
	
	
	-- Copy Alert edit box
	local ebCopyAlert = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ebCopyAlert )
	ebCopyAlert:SetLabel( L["alert/ebCopyAlert/l"] )
	ebCopyAlert:SetWidth(485)
	ebCopyAlert:SetPoint("TOPLEFT", ebRenameAlert.frame, "BOTTOMLEFT", 0, 0);
	ebCopyAlert:SetCallback( "OnEnterPressed", Nemo.UI.ebCopyAlertOnEnterPressed )
	ebCopyAlert:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ebCopyAlert/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, -10, "text") end )
	ebCopyAlert:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	
	-- Move up interactive label
	local ilAlMoveUp = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlMoveUp )
	ilAlMoveUp:SetWidth(40);ilAlMoveUp:SetHeight(40)
	ilAlMoveUp:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Up")
	ilAlMoveUp:SetImageSize(40, 40)
	ilAlMoveUp:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Highlight")
	ilAlMoveUp:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", -5, -545);
	ilAlMoveUp:SetCallback( "OnClick", function() Nemo.UI.bMoveAlert(-1) end )
	ilAlMoveUp:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ilAlMoveUp/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilAlMoveUp:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Move down interactive label
	local ilAlMoveDown = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlMoveDown )
	ilAlMoveDown:SetWidth(40);ilAlMoveDown:SetHeight(40)
	ilAlMoveDown:SetImage("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Up")
	ilAlMoveDown:SetImageSize(40, 40)
	ilAlMoveDown:SetHighlight("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Highlight")
	ilAlMoveDown:SetPoint("TOPLEFT", ilAlMoveUp.frame, "BOTTOMLEFT", 0, 5);
	ilAlMoveDown:SetCallback( "OnClick", function() Nemo.UI.bMoveAlert(1) end )
	ilAlMoveDown:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ilAlMoveDown/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ilAlMoveDown:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )

	-- Delete Alert button
	local bAlertDelete = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bAlertDelete )
	bAlertDelete:SetWidth(100)
	bAlertDelete:SetText(L["common/delete"])
	bAlertDelete:SetPoint("TOPLEFT", ilAlMoveDown.frame, "TOPRIGHT", 0, -10);
	bAlertDelete:SetCallback( "OnClick", Nemo.UI.bAlertDeleteOnClick )
	bAlertDelete:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/bAlertDelete/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	bAlertDelete:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	
	-- Visual Options InteractiveLabel
	local ilAlertVisualOptions = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertVisualOptions )
	ilAlertVisualOptions:SetText( L["alert/ilAlertVisualOptions/l"] )
	ilAlertVisualOptions:SetPoint("TOPLEFT", ebCopyAlert.frame, "BOTTOMLEFT", 0, 0);

	-- Texture Path EditBox
	Nemo.UI.sgMain.tgMain.sgPanel.ebTexturePath = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebTexturePath )
	local ebTexturePath = Nemo.UI.sgMain.tgMain.sgPanel.ebTexturePath
	ebTexturePath:SetLabel( L["alert/ebTexturePath/l"] )
	ebTexturePath:SetWidth(485)
	ebTexturePath:SetCallback( "OnEnterPressed", function(self) Nemo.UI.ebTexturePathOnEnterPressed(self, true) end )
	ebTexturePath:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ebTexturePath/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	ebTexturePath:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebTexturePath:SetText( Nemo.UI.DB.tp or "" )
	
	-- TexturePresetsVisual Alert Type Dropdown
	Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedTextures = Nemo.UI:Create("Dropdown")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedTextures )
	local ddPredefinedTextures = Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedTextures
	ddPredefinedTextures:SetList(Nemo.D.AlertTextures, Nemo.D.AlertTexturesSortOrder)
	ddPredefinedTextures:SetLabel( L["alert/ddPredefinedTextures/l"] )
	ddPredefinedTextures:SetWidth(487)
	ddPredefinedTextures:SetPoint("TOPLEFT", ilAlertVisualOptions.frame, "BOTTOMLEFT", 0, 0)
	ddPredefinedTextures:SetCallback( "OnValueChanged", function(self) Nemo.UI.ddPredefinedTexturesOnValueChanged(self, true) end )
	ddPredefinedTextures:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ddPredefinedTextures/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	ddPredefinedTextures:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ddPredefinedTextures:SetValue( Nemo.UI.DB.tp or '_None' )
	ebTexturePath:SetPoint("TOPLEFT", ddPredefinedTextures.frame, "BOTTOMLEFT", 0, 0)

		
	-- Alert Texture X sub InteractiveLabel
	local ilAlertTextureXSub = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertTextureXSub )
	ilAlertTextureXSub:SetWidth(20)
	ilAlertTextureXSub:SetImage("Interface\\BUTTONS\\UI-MinusButton-Up")
	ilAlertTextureXSub:SetHighlight("Interface\\BUTTONS\\UI-PlusButton-Hilight")
	ilAlertTextureXSub:SetImageSize(20, 20)
	ilAlertTextureXSub:SetPoint("TOPLEFT", ebTexturePath.frame, "BOTTOMLEFT", 0, -12);
	ilAlertTextureXSub:SetCallback( "OnClick",function() Nemo.UI.TransformAlertTexture(-1,0,0,true) end )
	
	-- Alert Texture X add InteractiveLabel
	local ilAlertTextureXAdd = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertTextureXAdd )
	ilAlertTextureXAdd:SetWidth(20)
	ilAlertTextureXAdd:SetImage("Interface\\BUTTONS\\UI-PlusButton-Up")
	ilAlertTextureXAdd:SetHighlight("Interface\\BUTTONS\\UI-PlusButton-Hilight")
	ilAlertTextureXAdd:SetImageSize(20, 20)
	ilAlertTextureXAdd:SetPoint("TOPLEFT", ilAlertTextureXSub.frame, "TOPRIGHT", 0, 0);
	ilAlertTextureXAdd:SetCallback( "OnClick",function() Nemo.UI.TransformAlertTexture(1,0,0,true) end )

	-- Alert Texture X Slider
	Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureX = Nemo.UI:Create("Slider")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureX )
	local sAlertTextureX = Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureX
	sAlertTextureX:SetLabel( L["alert/sAlertTextureX/l"] )
	sAlertTextureX:SetWidth(450)
	sAlertTextureX:SetPoint("TOPLEFT", ilAlertTextureXAdd.frame, "TOPRIGHT", 0, 12);
	sAlertTextureX:SetSliderValues( ceil(-1*(Nemo.D.SW/2)) , ceil((Nemo.D.SW/2)), 1)
	sAlertTextureX:SetCallback( "OnValueChanged", function() Nemo.UI.sAlertTextureXOnValueChanged(true) end )
	sAlertTextureX:SetValue(Nemo.UI.DB.tx or 0)

	-- Alert Texture Y sub InteractiveLabel
	local ilAlertTextureYSub = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertTextureYSub )
	ilAlertTextureYSub:SetWidth(20)
	ilAlertTextureYSub:SetImage("Interface\\BUTTONS\\UI-MinusButton-Up")
	ilAlertTextureYSub:SetHighlight("Interface\\BUTTONS\\UI-PlusButton-Hilight")
	ilAlertTextureYSub:SetImageSize(20, 20)
	ilAlertTextureYSub:SetPoint("TOPLEFT", ilAlertTextureXSub.frame, "BOTTOMLEFT", 0, -25);
	ilAlertTextureYSub:SetCallback( "OnClick",function() Nemo.UI.TransformAlertTexture(0,-1,0,true) end )
	
	-- Alert Texture Y add InteractiveLabel
	local ilAlertTextureYAdd = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertTextureYAdd )
	ilAlertTextureYAdd:SetWidth(20)
	ilAlertTextureYAdd:SetImage("Interface\\BUTTONS\\UI-PlusButton-Up")
	ilAlertTextureYAdd:SetHighlight("Interface\\BUTTONS\\UI-PlusButton-Hilight")
	ilAlertTextureYAdd:SetImageSize(20, 20)
	ilAlertTextureYAdd:SetPoint("TOPLEFT", ilAlertTextureYSub.frame, "TOPRIGHT", 0, 0);
	ilAlertTextureYAdd:SetCallback( "OnClick",function() Nemo.UI.TransformAlertTexture(0,1,0,true) end )

	-- Alert Texture Y Slider
	Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureY = Nemo.UI:Create("Slider")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureY )
	local sAlertTextureY = Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureY
	sAlertTextureY:SetLabel( L["alert/sAlertTextureY/l"] )
	sAlertTextureY:SetWidth(450)
	sAlertTextureY:SetPoint("TOPLEFT", ilAlertTextureYAdd.frame, "TOPRIGHT", 0, 12);
	sAlertTextureY:SetSliderValues( ceil(-1*(Nemo.D.SH/2)) , ceil((Nemo.D.SH/2)), 1)
	sAlertTextureY:SetCallback( "OnValueChanged", function() Nemo.UI.sAlertTextureYOnValueChanged(true) end )
	sAlertTextureY:SetValue(Nemo.UI.DB.ty or 0)

	-- Alert Texture Scale sub InteractiveLabel
	local ilAlertTextureSSub = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertTextureSSub )
	ilAlertTextureSSub:SetWidth(20)
	ilAlertTextureSSub:SetImage("Interface\\BUTTONS\\UI-MinusButton-Up")
	ilAlertTextureSSub:SetHighlight("Interface\\BUTTONS\\UI-PlusButton-Hilight")
	ilAlertTextureSSub:SetImageSize(20, 20)
	ilAlertTextureSSub:SetPoint("TOPLEFT", ilAlertTextureYSub.frame, "BOTTOMLEFT", 0, -25);
	ilAlertTextureSSub:SetCallback( "OnClick",function() Nemo.UI.TransformAlertTexture(0,0,-1,true) end )
	
	-- Alert Texture Scale add InteractiveLabel
	local ilAlertTextureSAdd = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertTextureSAdd )
	ilAlertTextureSAdd:SetWidth(20)
	ilAlertTextureSAdd:SetImage("Interface\\BUTTONS\\UI-PlusButton-Up")
	ilAlertTextureSAdd:SetHighlight("Interface\\BUTTONS\\UI-PlusButton-Hilight")
	ilAlertTextureSAdd:SetImageSize(20, 20)
	ilAlertTextureSAdd:SetPoint("TOPLEFT", ilAlertTextureSSub.frame, "TOPRIGHT", 0, 0);
	ilAlertTextureSAdd:SetCallback( "OnClick",function() Nemo.UI.TransformAlertTexture(0,0,1,true) end )

	-- Alert Texture Scale Slider
	Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureS = Nemo.UI:Create("Slider")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureS )
	local sAlertTextureS = Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureS
	sAlertTextureS:SetLabel( L["alert/sAlertTextureS/l"] )
	sAlertTextureS:SetWidth(450)
	sAlertTextureS:SetPoint("TOPLEFT", ilAlertTextureSAdd.frame, "TOPRIGHT", 0, 12);
	sAlertTextureS:SetSliderValues( 10 , 500, 1)
	sAlertTextureS:SetCallback( "OnValueChanged", function() Nemo.UI.sAlertTextureSOnValueChanged(true) end )
	sAlertTextureS:SetValue(Nemo.UI.DB.vats or 100)
	
	-- Make the color picker frame movable
	local CPF = ColorPickerFrame	
	CPF:SetMovable(true)
	CPF:EnableMouse(true)
	CPF:HookScript("OnMouseDown", function(self, ...) self:StartMoving() end)
	CPF:HookScript("OnMouseUp", function(self, ...) self:StopMovingOrSizing() end)
	CPF:SetPoint("TOP", UIParent, "TOP", 0, 0)
		
	-- Texture Vertex ColorPicker
	Nemo.UI.sgMain.tgMain.sgPanel.cpTVertexColor = Nemo.UI:Create("ColorPicker")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.cpTVertexColor )
	local cpTVertexColor = Nemo.UI.sgMain.tgMain.sgPanel.cpTVertexColor
	cpTVertexColor:SetLabel( L["alert/cpTVertexColor/l"] )
	cpTVertexColor:SetHasAlpha(true)
	cpTVertexColor:SetWidth(400)
	cpTVertexColor:SetPoint("TOPLEFT", ilAlertTextureSSub.frame, "BOTTOMLEFT", 0, 0)
	cpTVertexColor:SetCallback( "OnValueChanged", Nemo.UI.cpTVertexColorOnValueChanged )
	cpTVertexColor:SetCallback( "OnValueConfirmed", Nemo.UI.cpTVertexColorOnValueConfirmed )
	cpTVertexColor:SetColor(Nemo.UI.DB.vatr or 1, Nemo.UI.DB.vatg or 1, Nemo.UI.DB.vatb or 1, Nemo.UI.DB.vata or 1)

	-- AlertText EditBox
	Nemo.UI.sgMain.tgMain.sgPanel.ebText = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebText )
	local ebText = Nemo.UI.sgMain.tgMain.sgPanel.ebText
	ebText:SetLabel( L["alert/ebText/l"] )
	ebText:SetWidth(435)
	ebText:SetPoint("TOPLEFT", cpTVertexColor.frame, "BOTTOMLEFT", 0, 0)
	ebText:SetCallback( "OnEnterPressed", Nemo.UI.ebTextOnEnterPressed )
	ebText:SetText( Nemo.UI.DB.txt or "" )
	
	-- Font Size EditBox
	Nemo.UI.sgMain.tgMain.sgPanel.ebFontSize = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebFontSize )
	local ebFontSize = Nemo.UI.sgMain.tgMain.sgPanel.ebFontSize
	ebFontSize:SetLabel( L["alert/ebFontSize/l"] )
	ebFontSize:SetWidth(50)
	ebFontSize:SetPoint("TOPLEFT", ebText.frame, "TOPRIGHT", 0, 0)
	ebFontSize:DisableButton(true)
	ebFontSize:SetCallback( "OnEnterPressed", Nemo.UI.ebFontSizeOnEnterPressed )
	ebFontSize:SetText( Nemo.UI.DB.fs or 12 )
	
	-- Font EditBox
	Nemo.UI.sgMain.tgMain.sgPanel.ebFontPath = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebFontPath )
	local ebFontPath = Nemo.UI.sgMain.tgMain.sgPanel.ebFontPath
	ebFontPath:SetLabel( L["alert/ebFontPath/l"] )
	ebFontPath:SetWidth(485)
	ebFontPath:SetCallback( "OnEnterPressed", Nemo.UI.ebFontPathOnEnterPressed )
	ebFontPath:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ebFontPath/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	ebFontPath:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebFontPath:SetText( Nemo.UI.DB.f or "Fonts\\FRIZQT__.TTF" )
	
	-- Predefined Fonts Dropdown
	Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedFonts = Nemo.UI:Create("Dropdown")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedFonts )
	local ddPredefinedFonts = Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedFonts
	ddPredefinedFonts:SetList(Nemo.D.AlertFonts, Nemo.D.AlertFontsSortOrder)
	ddPredefinedFonts:SetLabel( L["alert/ddPredefinedFonts/l"] )
	ddPredefinedFonts:SetWidth(487)
	ddPredefinedFonts:SetPoint("TOPLEFT", ebText.frame, "BOTTOMLEFT", 0, 0)
	ddPredefinedFonts:SetCallback( "OnValueChanged", Nemo.UI.ddPredefinedFontsOnValueChanged )
	ddPredefinedFonts:SetValue( Nemo.UI.DB.f or "" )
	ebFontPath:SetPoint("TOPLEFT", ddPredefinedFonts.frame, "BOTTOMLEFT", 0, 0)
		
	-- Audio Options InteractiveLabel
	local ilAlertAudioOptions = Nemo.UI:Create("InteractiveLabel")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ilAlertAudioOptions )
	ilAlertAudioOptions:SetText( L["alert/ilAlertAudioOptions/l"] )
	ilAlertAudioOptions:SetPoint("TOPLEFT", ebFontPath.frame, "BOTTOMLEFT", 0, 0);

	-- Custom Audio EditBox
	Nemo.UI.sgMain.tgMain.sgPanel.ebAudioCustom = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebAudioCustom )
	local ebAudioCustom = Nemo.UI.sgMain.tgMain.sgPanel.ebAudioCustom
	ebAudioCustom:SetLabel( L["alert/ebAudioCustom/l"] )
	ebAudioCustom:SetWidth(335)
	ebAudioCustom:SetCallback( "OnEnterPressed", Nemo.UI.ebAudioCustomOnEnterPressed )
	ebAudioCustom:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ebAudioCustom/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	ebAudioCustom:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ebAudioCustom:SetText( Nemo.UI.DB.aac or "" )

	-- Audio Alert Dropdown
	local ddAudioAlert = Nemo.UI:Create("Dropdown")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( ddAudioAlert )
	ddAudioAlert:SetList(Nemo.D.Sounds, Nemo.D.SoundsSortOrder)
	ddAudioAlert:SetLabel( L["alert/ddAudioAlert/l"] )
	ddAudioAlert:SetWidth(150)
	ddAudioAlert:SetPoint("TOPLEFT", ilAlertAudioOptions.frame, "BOTTOMLEFT", 0, 0)
	ddAudioAlert:SetCallback( "OnValueChanged", function(self) Nemo.UI.ddAudioAlertOnValueChanged(self, true) end )
	ddAudioAlert:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["alert/ddAudioAlert/tt"], "BOTTOMRIGHT", "TOPRIGHT", 0, 0, "text") end )
	ddAudioAlert:SetCallback( "OnLeave", function() Nemo.UI.HideTooltip() end )
	ddAudioAlert:SetValue( Nemo.UI.DB.aa or "")--Audio Alert
	Nemo.UI.ddAudioAlertOnValueChanged(ddAudioAlert, false)
	ebAudioCustom:SetPoint("TOPLEFT", ddAudioAlert.frame, "TOPRIGHT", 0, 0)
	
	-- Test Alert Interactive Label
	Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert = Nemo.UI:Create("InteractiveLabel")

	
	Nemo.UI.sgMain.tgMain.sgPanel:ResumeLayout()
	
	Nemo.UI.TransformAlertTexture(0, 0, 0, true)
	Nemo.UI.ShowTestAlert( Nemo.D.lastalertname )
end
--Alert Panel Callbacks----------------------------
function Nemo.UI.ebRenameAlertOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3] ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )
		return
	end
	local OldAlertText = Nemo.D.ATMC[Nemo.UI.STL[2]].text
	local NewAlertText = args[3]
	local NewAlertValue = 'Nemo.UI:CreateAlertPanel([=['..args[3]..']=])'
	
	for rtk,rotation in pairs(Nemo.D.RTMC) do
		for atk,action in pairs(Nemo.D.RTMC[rtk].children) do
			if ( action.an == OldAlertText ) then
				action.an = NewAlertText -- Loop through actions and rename the alert
			end
		end
	end
	
	if ( Nemo:SearchTable(Nemo.D.ATMC, "text", args[3]) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], args[3]) )
	else
		Nemo.UI.fMain:SetStatusText( "" ) -- Clear any previous errors
		Nemo.D.ATMC[Nemo.UI.STL[2]].text = NewAlertText
		Nemo.D.ATMC[Nemo.UI.STL[2]].value = NewAlertValue	
		Nemo.UI.sgMain.tgMain:RefreshTree()
		Nemo.AButtons.bInitComplete = false --Alert Renamed
		Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.ATM.value.."\001"..NewAlertValue)
	end
end
function Nemo.UI.ebCopyAlertOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3] ) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )
		return
	end
	local NewAlert = Nemo:CopyTable( Nemo.D.ATMC[Nemo.UI.STL[2]] )
	NewAlert.text = args[3]
	NewAlert.value = 'Nemo.UI:CreateAlertPanel([=['..args[3]..']=])'
	if ( Nemo:SearchTable(Nemo.D.ATMC, "text", args[3]) ) then
		Nemo.UI.fMain:SetStatusText( string.format(L["common/error/exists"], args[3]) )
	else
		Nemo.UI.fMain:SetStatusText( "" ) -- Clear any previous errors
		table.insert( Nemo.D.ATMC, NewAlert)
		Nemo.UI.sgMain.tgMain:RefreshTree()
	end
end
function Nemo.UI.bAlertDeleteOnClick(...)
	if ( InCombatLockdown() ) then Nemo.UI.fMain:SetStatusText( L["common/error/deleteincombat"] ) return end
	local deleteKey = Nemo.UI.STL[2]
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.ATM.value)
	Nemo.UI.HideTestAlert(Nemo.D.ATMC[deleteKey].text)
	
	for rtk,rotation in pairs(Nemo.D.RTMC) do
		for atk,action in pairs(Nemo.D.RTMC[rtk].children) do
			if ( action.an == Nemo.D.ATMC[deleteKey].text ) then
				action.an = nil -- Delete the alert name from the action
			end
		end
	end
	tremove(Nemo.D.ATMC, deleteKey) -- Now delete from the alert tree main children
	
	Nemo.UI.sgMain.tgMain:RefreshTree()
	Nemo.UI.sgMain.tgMain.sgPanel:ReleaseChildren() 							-- clears the right panel
	Nemo.AButtons.bInitComplete = false											-- Alert Deleted initialization needed to remove textures
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.ATM.value)						-- Select the Alert main tree
end
function Nemo.UI.bMoveAlert(movevalue)
	local SavedValue	= Nemo.D.ATMC[Nemo.UI.STL[2]].value
	local SavedAlert	= Nemo:CopyTable(Nemo.UI.DB)							-- Deepcopy the Alert from the profile db
	local maxKey		= #(Nemo.D.ATMC)
	tremove(Nemo.D.ATMC, Nemo.UI.STL[2])
	Nemo.UI.STL[2] = Nemo.UI.STL[2]+movevalue									-- Now change the key value to up or down
	if ( Nemo.UI.STL[2] < 1) then Nemo.UI.STL[2] = 1 end
	if ( Nemo.UI.STL[2] > maxKey ) then Nemo.UI.STL[2] = maxKey end
	tinsert(Nemo.D.ATMC, Nemo.UI.STL[2], SavedAlert)
	Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.ATM.value.."\001"..SavedValue)
end
function Nemo.UI.ddPredefinedTexturesOnValueChanged(self, bShowAlert)
	if ( Nemo:isblank( self:GetValue() ) or self:GetValue() == '_None' ) then
		Nemo.UI.sgMain.tgMain.sgPanel.ebTexturePath:SetText('')
		Nemo.UI.DB.tp = nil
	else
		Nemo.UI.sgMain.tgMain.sgPanel.ebTexturePath:SetText( Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedTextures:GetValue() )
		Nemo.UI.DB.tp = Nemo.UI.sgMain.tgMain.sgPanel.ddPredefinedTextures:GetValue()
	end
	Nemo.AButtons.bInitComplete = false	-- Alert predefined texture dropdown changed
	if ( bShowAlert ) then Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text ) end		
end
function Nemo.UI.ebTexturePathOnEnterPressed(self, bShowAlert)
	if ( Nemo:isblank( self:GetText() ) or self:GetText() == '_None' ) then
		Nemo.UI.DB.tp = nil
	else
		Nemo.UI.DB.tp = Nemo.UI.sgMain.tgMain.sgPanel.ebTexturePath:GetText()
	end
	Nemo.AButtons.bInitComplete = false	-- Alert Texture path changed
	if ( bShowAlert ) then Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text ) end	
end
function Nemo.UI.TransformAlertTexture(xInc, yInc, scale, bShowAlert)
	Nemo.UI.DB.tx = Nemo:NilToNumeric(Nemo.UI.DB.tx,0) + xInc
	Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureX:SetValue(Nemo.UI.DB.tx)
	Nemo.UI.DB.ty = Nemo:NilToNumeric(Nemo.UI.DB.ty,0) + yInc
	Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureY:SetValue(Nemo.UI.DB.ty)
	Nemo.UI.DB.vats = Nemo:NilToNumeric(Nemo.UI.DB.vats,100) + scale
	Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureS:SetValue(Nemo.UI.DB.vats)
	Nemo.AButtons.bInitComplete = false	-- Alert texture transformation changed
	if ( bShowAlert ) then Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text ) end	
end
function Nemo.UI.sAlertTextureXOnValueChanged( bShowAlert)
	Nemo.UI.DB.tx = Nemo:NilToNumeric(Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureX:GetValue(),0)
	Nemo.AButtons.bInitComplete = false	-- Alert X value changed
	if ( bShowAlert ) then Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text ) end	
end
function Nemo.UI.sAlertTextureYOnValueChanged( bShowAlert)
	Nemo.UI.DB.ty = Nemo:NilToNumeric(Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureY:GetValue(),0)
	Nemo.AButtons.bInitComplete = false -- Alert Y value changed
	if ( bShowAlert ) then Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text ) end	
end
function Nemo.UI.sAlertTextureSOnValueChanged( bShowAlert)
	Nemo.UI.DB.vats = Nemo:NilToNumeric(Nemo.UI.sgMain.tgMain.sgPanel.sAlertTextureS:GetValue(),0)
	Nemo.AButtons.bInitComplete = false	-- Alert Texture changed
	if ( bShowAlert ) then Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text ) end	
end
function Nemo.UI.ebTextOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3], true ) ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) ) return end
	Nemo.UI.DB.txt = args[3]
	Nemo.AButtons.bInitComplete = false -- Alert text changed
	Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text )
end
function Nemo.UI.ebFontSizeOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3] ) ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )	return end
	Nemo.UI.DB.fs = args[3]
	Nemo.AButtons.bInitComplete = false	-- Font Size changed
	Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text )
end
function Nemo.UI.ebFontPathOnEnterPressed(...)
	local args = {...}
	if ( Nemo.UI.EntryHasErrors( args[3], true ) ) then Nemo.UI.fMain:SetStatusText( string.format(L["common/error/unsafestring"], args[3]) )	return end
	Nemo.UI.DB.f = args[3]
	Nemo.AButtons.bInitComplete = false-- Alert Fonts path changed
	Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text )
end
function Nemo.UI.ddPredefinedFontsOnValueChanged(...)
	local args = {...}
	Nemo.UI.DB.f = args[3]
	Nemo.UI.sgMain.tgMain.sgPanel.ebFontPath:SetText( Nemo.UI.DB.f )
	Nemo.AButtons.bInitComplete = false	-- Alert Fonts changed
	Nemo.UI.ShowTestAlert( Nemo.D.ATMC[Nemo.UI.STL[2]].text )
end
function Nemo.UI.cpTVertexColorOnValueChanged(...)
	local args = {...}
	local lR = args[3]
	local lG = args[4]
	local lB = args[5]
	local lA = args[6]
	-- local lAlertName = Nemo.D.ATMC[Nemo.UI.STL[2]].text
	-- local lAlertDBKey = Nemo:SearchTable(Nemo.D.ATMC, "text", lAlertName)
	-- local lAlertDB = Nemo.D.ATMC[lAlertDBKey]
	-- if ( Nemo:isblank( lAlertDB ) ) then return end							-- Exit if Alert DB does not exist
	Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert.image:SetVertexColor(lR, lG, lB, lA)
end
function Nemo.UI.cpTVertexColorOnValueConfirmed(...)
	local args = {...}
	-- local lAlertName = Nemo.D.ATMC[Nemo.UI.STL[2]].text
	Nemo.UI.DB.vatr = args[3]
	Nemo.UI.DB.vatg = args[4]
	Nemo.UI.DB.vatb = args[5]
	Nemo.UI.DB.vata = args[6]	
	Nemo.AButtons.bInitComplete = false	-- Visual Alert Texture vertex color changed
	Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert.image:SetVertexColor(Nemo.UI.DB.vatr, Nemo.UI.DB.vatg, Nemo.UI.DB.vatb, Nemo.UI.DB.vata)
end

function Nemo.UI.ddAudioAlertOnValueChanged(self, bPlaySound)
	Nemo.UI.DB.aa=self:GetValue()
	if ( Nemo:isblank( Nemo.UI.DB.aa ) or Nemo.UI.DB.aa == '_None' ) then
		Nemo.UI.sgMain.tgMain.sgPanel.ebAudioCustom.frame:Hide()
	elseif ( Nemo.UI.DB.aa == '_Custom' ) then
		Nemo.UI.sgMain.tgMain.sgPanel.ebAudioCustom.frame:Show()
	else
		Nemo.UI.sgMain.tgMain.sgPanel.ebAudioCustom.frame:Hide()
		if ( bPlaySound ) then PlaySound(Nemo.UI.DB.aa, Nemo.D.SoundChannel) end		
	end
	Nemo.AButtons.bInitComplete = false -- Drop Down Audio Alert Changed
end

function Nemo.UI.ebAudioCustomOnEnterPressed(...)
	local args = {...}
	Nemo.UI.DB.aac=args[3]
	-- Play one of WoW's built-in sound files
	-- Sound\\Spells\\AbolishMagic.wav
	-- Play a sound file from Nemo Sounds folder:
	-- Interface\\AddOns\\Nemo\\Sounds\\Vanish.mp3	
	PlaySoundFile(Nemo.UI.DB.aac, Nemo.D.SoundChannel)
	Nemo.AButtons.bInitComplete = false -- Audio Custom file changed
end
function Nemo.UI.ShowVisualAlert( NemoSABFrame )
	local lEditingAlert = false
	if ( Nemo.UI.sgMain and Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert and Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert.frame:IsShown() ) then
		lEditingAlert = true
	end
	if ( NemoSABFrame.nemoail and not lEditingAlert ) then
		NemoSABFrame.nemoail.frame:Show()--Nemo Alert Interactive Label
	else
		Nemo.UI.HideVisualAlert( NemoSABFrame )
	end
end
function Nemo.UI.HideVisualAlert( NemoSABFrame )
	if ( NemoSABFrame.nemoail ) then
		NemoSABFrame.nemoail.frame:Hide()
	end
end
function Nemo.UI.ShowTestAlert( AlertName )
-- if( AlertName) then print("ShowTestAlert"..tostring(AlertName))	end
	if ( Nemo:isblank( AlertName ) ) then return end
	
	local TestAlertIL = Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert
	if ( Nemo:isblank( Nemo.UI.DB ) ) then return end							-- Exit if Alert DB does not exist

	--Set the image location---------------------------------------------------------------
	TestAlertIL.frame:ClearAllPoints()
	TestAlertIL.frame:SetPoint("CENTER", UIParent, "CENTER", Nemo.UI.DB.tx, Nemo.UI.DB.ty)

	--Set the image size-------------------------------------------------------------------	
	local lSize = (Nemo:NilToNumeric(Nemo.UI.DB.vats,100)/100)
	TestAlertIL:SetImageSize(100*lSize, 100*lSize)

	--Set the image vertex color-----------------------------------------------------------
	TestAlertIL.image:SetVertexColor(Nemo.UI.DB.vatr or 1, Nemo.UI.DB.vatg or 1, Nemo.UI.DB.vatb or 1, Nemo.UI.DB.vata or 1)
	
	--Show the texture---------------------------------------------------------------------
	if ( Nemo:isblank( Nemo.UI.DB.tp ) or Nemo.UI.DB.tp == '_None' ) then
		TestAlertIL:SetImage('')
	elseif ( Nemo.UI.DB.tp == '_Icon' ) then
		local lTexture = "Interface\\ICONS\\INV_Misc_Fish_09"
		if ( Nemo.Engine.Queue[1] and _G[Nemo.Engine.Queue[1].fn.."Icon"] ) then
			lTexture = _G[Nemo.Engine.Queue[1].fn.."Icon"]:GetTexture() or "Interface\\ICONS\\INV_Misc_Fish_09"
		end
		TestAlertIL:SetImage(lTexture)
	else
		TestAlertIL:SetImage(Nemo.UI.DB.tp)
	end
	--Show the text------------------------------------------------------------------------
	TestAlertIL:SetText( Nemo.UI.DB.txt )
	TestAlertIL:SetFont( (Nemo.UI.DB.f or "Fonts\\FRIZQT__.TTF"), (Nemo.UI.DB.fs or 12) )
	
	TestAlertIL.frame:EnableMouse(false)
	TestAlertIL.frame:Show()
end

function Nemo.UI.HideTestAlert()
	if ( Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert ) then Nemo.UI.sgMain.tgMain.sgPanel.ilTestAlert.frame:Hide() end
	-- if ( not Nemo:isblank( AlertName ) and Nemo.UI.AlertFrames[AlertName] ) then
--fix this, hiding text is not working	
-- print(GetTime().."HideVisualAlert hiding"..tostring(Nemo.UI.AlertFrames[AlertName].frame:GetName() ) )
		-- Nemo.UI.AlertFrames[AlertName]:SetImage('')
		-- Nemo.UI.AlertFrames[AlertName]:SetText('')
		-- Nemo.UI.AlertFrames[AlertName].frame:Hide()
	-- end
	
end