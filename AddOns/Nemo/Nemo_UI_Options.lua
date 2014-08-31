local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--*****************************************************
--Options Panel
--*****************************************************
function Nemo.UI:CreateOptionsPanel()
	Nemo.UI.sgMain.tgMain.sgPanel:PauseLayout()--Pause the layout so you can position correctly

	-- Anchor X offset from left
	Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorX = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorX )
	local ebAnchorX = Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorX
	ebAnchorX:SetLabel( L["options/ebAnchorX/l"] )
	ebAnchorX:SetWidth(100)
	ebAnchorX:SetPoint("TOPLEFT", Nemo.UI.sgMain.tgMain.sgPanel.frame, "TOPLEFT", 0, 0)
	ebAnchorX:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["options/ebAnchorX/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ebAnchorX:SetCallback( "OnLeave", Nemo.UI.HideTooltip )
	ebAnchorX:SetCallback( "OnEnterPressed", function(self)
		local lNewValue = Nemo:NilToNumeric( self:GetText() )
		if ( InCombatLockdown() ) then
			print(L["utils/debug/prefix"]..L["common/error/anchor1"])
			self:SetText( Nemo.DB.profile.options.anchor.x )
		else
			Nemo.UI.fAnchor:ClearAllPoints()
			Nemo.DB.profile.options.anchor.x = lNewValue
			self:SetText( lNewValue )
			Nemo.UI.fAnchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", Nemo.DB.profile.options.anchor.x, Nemo.DB.profile.options.anchor.y)
			Nemo.UI.fAnchor.moveable = false
		end
	end )
	ebAnchorX:SetText( Nemo.DB.profile.options.anchor.x )
	
	-- Anchor Y offset from left
	Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorY = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorY )
	local ebAnchorY = Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorY
	ebAnchorY:SetLabel( L["options/ebAnchorY/l"] )
	ebAnchorY:SetWidth(100)
	ebAnchorY:SetPoint("TOPLEFT", ebAnchorX.frame, "TOPRIGHT", 0, 0)
	ebAnchorY:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["options/ebAnchorY/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ebAnchorY:SetCallback( "OnLeave", Nemo.UI.HideTooltip )
	ebAnchorY:SetCallback( "OnEnterPressed", function(self)
		local lNewValue = Nemo:NilToNumeric( self:GetText() )
		if ( InCombatLockdown() ) then
			print(L["utils/debug/prefix"]..L["common/error/anchor1"])
			self:SetText( Nemo.DB.profile.options.anchor.y )
		else
			Nemo.UI.fAnchor:ClearAllPoints()
			Nemo.DB.profile.options.anchor.y = lNewValue
			self:SetText( lNewValue )
			Nemo.UI.fAnchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", Nemo.DB.profile.options.anchor.x, Nemo.DB.profile.options.anchor.y)
			Nemo.UI.fAnchor.moveable = false
		end
	end )
	ebAnchorY:SetText( Nemo.DB.profile.options.anchor.y )
	
	-- Show anchor frame button
	local bShowAnchor = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bShowAnchor )
	bShowAnchor:SetText( L["options/bShowAnchor/l"] )
	bShowAnchor:SetWidth(140)
	bShowAnchor:SetPoint("TOPLEFT", ebAnchorY.frame, "TOPRIGHT", 5, -20)
	bShowAnchor:SetCallback( "OnClick", function()
		if ( InCombatLockdown() ) then
			print(L["utils/debug/prefix"]..L["common/error/anchor1"])
			return
		end

		if ( ElvUI and Nemo.ElvUI and type(Nemo.ElvUI.ToggleConfigMode)=='function' ) then -- make sure the Nemo.ElvUI.ToggleConfigMode function exists
			if ( Nemo.UI.fMain ) then Nemo.UI.fMain:Hide() end				--Hide the main gui
			Nemo.UI.fAnchor.moveable = true
			Nemo.ElvUI:ToggleConfigMode()
			return
		else
			-- Nemo.AButtons.SetAllMouse()
			Nemo.UI.fAnchor.moveable = true
		end

		Nemo.UI.fAnchor.Texture:SetAlpha(1)
		Nemo.UI.fAnchor:EnableMouse(true)
		Nemo.UI.fAnchor:SetFrameStrata("TOOLTIP")
		Nemo.AButtons.bInitComplete = false	-- Actions need to disable their clicks so only frame is draggable
	end)

	-- Reset anchor frame button
	local bResetAnchor = Nemo.UI:Create("Button")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( bResetAnchor )
	bResetAnchor:SetText( L["options/bResetAnchor/l"] )
	bResetAnchor:SetWidth(140)
	bResetAnchor:SetPoint("TOPLEFT", bShowAnchor.frame, "TOPRIGHT", 0, 0)
	bResetAnchor:SetCallback( "OnClick", function()
		if ( InCombatLockdown() ) then
			print(L["utils/debug/prefix"]..L["common/error/anchor1"])
			return
		end
		if ( ElvUI and Nemo.ElvUI ) then
			print(L["utils/debug/prefix"]..L["common/error/anchor2"])
			return
		end
		-- Nemo.AButtons.SetAllMouse()
		local x,y = UIParent:GetCenter()
		Nemo.DB.profile.options.anchor.x = x
		Nemo.DB.profile.options.anchor.y = y
		Nemo.UI.fAnchor:ClearAllPoints()
		Nemo.UI.fAnchor:SetFrameStrata("TOOLTIP")
		Nemo.UI.fAnchor:SetPoint("CENTER", UIParent, "CENTER")
		Nemo.UI.AnchorPostDrag()
	end)

	-- Hide out of combat CheckBox
	local cbHideOOCombat = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbHideOOCombat )
	cbHideOOCombat:SetLabel( L["options/cbHideOOCombat/l"] )
	cbHideOOCombat:SetWidth(400)
	cbHideOOCombat:SetPoint("TOPLEFT", ebAnchorX.frame, "BOTTOMLEFT", 0, 0);
	cbHideOOCombat:SetCallback( "OnValueChanged", function(self)
		Nemo.DB.profile.options.hideoutofcombat = self:GetValue()
	end )
	if (Nemo:isblank(Nemo.DB.profile.options.hideoutofcombat)) then
		cbHideOOCombat:SetValue(false)
		Nemo.DB.profile.options.hideoutofcombat=false
	else
		cbHideOOCombat:SetValue( Nemo.DB.profile.options.hideoutofcombat)
	end

	-- HideNemoIcon CheckBox
	local cbHideNemoIcon = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbHideNemoIcon )
	cbHideNemoIcon:SetLabel( L["options/cbHideNemoIcon/l"] )
	cbHideNemoIcon:SetWidth(400)
	cbHideNemoIcon:SetPoint("TOPLEFT", cbHideOOCombat.frame, "BOTTOMLEFT", 0, 0);
	cbHideNemoIcon:SetCallback( "OnValueChanged", function(self) Nemo.DB.profile.options.hidenemoicon = self:GetValue() end )
	if (Nemo:isblank(Nemo.DB.profile.options.hidenemoicon)) then cbHideNemoIcon:SetValue(false);Nemo.DB.profile.options.hidenemoicon=false else cbHideNemoIcon:SetValue( Nemo.DB.profile.options.hidenemoicon) end

	-- HideNemoActions CheckBox
	local cbHideNemoActions = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbHideNemoActions )
	cbHideNemoActions:SetLabel( L["options/cbHideNemoActions/l"] )
	cbHideNemoActions:SetWidth(400)
	cbHideNemoActions:SetPoint("TOPLEFT", cbHideNemoIcon.frame, "BOTTOMLEFT", 0, 0);
	cbHideNemoActions:SetCallback( "OnValueChanged", function(self)
		Nemo.DB.profile.options.hidenemoactions = self:GetValue()
		-- Nemo.AButtons.bInitComplete = false			-- Hide Nemo Actions option was changed
	end )
	if (Nemo:isblank(Nemo.DB.profile.options.hidenemoactions)) then cbHideNemoActions:SetValue(false);Nemo.DB.profile.options.hidenemoactions=false else cbHideNemoActions:SetValue( Nemo.DB.profile.options.hidenemoactions) end

	-- HideBlizzardGlow CheckBox
	local cbHideBlizzardGlow = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbHideBlizzardGlow )
	cbHideBlizzardGlow:SetLabel( L["options/cbHideBlizzardGlow/l"] )
	cbHideBlizzardGlow:SetWidth(400)
	cbHideBlizzardGlow:SetPoint("TOPLEFT", cbHideNemoActions.frame, "BOTTOMLEFT", 0, 0);
	cbHideBlizzardGlow:SetCallback( "OnValueChanged", function(self) Nemo.DB.profile.options.hideblizzardglow = self:GetValue() end )
	if (Nemo:isblank(Nemo.DB.profile.options.hideblizzardglow)) then cbHideBlizzardGlow:SetValue(false);Nemo.DB.profile.options.hideblizzardglow=false else cbHideBlizzardGlow:SetValue( Nemo.DB.profile.options.hideblizzardglow) end

	-- UseSimpleglow CheckBox
	local cbUseSimpleGlow = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbUseSimpleGlow )
	cbUseSimpleGlow:SetLabel( L["options/cbUseSimpleGlow/l"] )
	cbUseSimpleGlow:SetWidth(400)
	cbUseSimpleGlow:SetPoint("TOPLEFT", cbHideBlizzardGlow.frame, "BOTTOMLEFT", 0, 0);
	cbUseSimpleGlow:SetCallback( "OnValueChanged", function(self) Nemo.DB.profile.options.simpleglow = self:GetValue() end )
	if (Nemo:isblank(Nemo.DB.profile.options.simpleglow)) then cbUseSimpleGlow:SetValue(false);Nemo.DB.profile.options.simpleglow=false else cbUseSimpleGlow:SetValue( Nemo.DB.profile.options.simpleglow) end

	-- EnableClickThroughActions CheckBox
	local cbEnableClickThroughActions = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( cbEnableClickThroughActions )
	cbEnableClickThroughActions:SetLabel( L["options/cbEnableClickThroughActions/l"] )
	cbEnableClickThroughActions:SetWidth(400)
	cbEnableClickThroughActions:SetPoint("TOPLEFT", cbUseSimpleGlow.frame, "BOTTOMLEFT", 0, 0);
	cbEnableClickThroughActions:SetCallback( "OnValueChanged", function(self)
		Nemo.DB.profile.options.clickthroughactions = self:GetValue()
		Nemo.AButtons.bInitComplete = false	-- EnableClickThroughActions was changed initialization needed
	end )
	if (Nemo:isblank(Nemo.DB.profile.options.clickthroughactions)) then cbEnableClickThroughActions:SetValue(false);Nemo.DB.profile.options.clickthroughactions=false else cbEnableClickThroughActions:SetValue( Nemo.DB.profile.options.clickthroughactions) end
	
	-- UI Scale editbox
	Nemo.UI.sgMain.tgMain.sgPanel.ebNemoScale = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebNemoScale )
	local ebNemoScale = Nemo.UI.sgMain.tgMain.sgPanel.ebNemoScale
	ebNemoScale:SetLabel( L["options/ebNemoScale/l"] )
	ebNemoScale:SetWidth(100)
	ebNemoScale:SetPoint("TOPLEFT", cbEnableClickThroughActions.frame, "BOTTOMLEFT", 0, 0)
	ebNemoScale:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["options/ebNemoScale/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ebNemoScale:SetCallback( "OnLeave", Nemo.UI.HideTooltip )
	ebNemoScale:SetCallback( "OnEnterPressed", function(self)
		local lNewValue = self:GetText()
		if ( Nemo:NilToNumeric( lNewValue )>=.5 and Nemo:NilToNumeric( lNewValue )<= 2 ) then
			Nemo.UI.fMain.frame:Hide()
			Nemo.UI.fMain.frame:SetScale( lNewValue )
			Nemo.UI.fMain.frame:Show()
			Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.OTM.value)
			Nemo.DB.profile.options.uiscale = lNewValue
			self:SetText( lNewValue )
		end
	end )
	ebNemoScale:SetText( Nemo.DB.profile.options.uiscale or 1 )
	
	-- KeyBind Font Size
	Nemo.UI.sgMain.tgMain.sgPanel.ebKeybindFontSize = Nemo.UI:Create("EditBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( Nemo.UI.sgMain.tgMain.sgPanel.ebKeybindFontSize )
	local ebKeybindFontSize = Nemo.UI.sgMain.tgMain.sgPanel.ebKeybindFontSize
	ebKeybindFontSize:SetLabel( L["options/ebKeybindFontSize/l"] )
	ebKeybindFontSize:SetWidth(100)
	ebKeybindFontSize:SetPoint("TOPLEFT", ebNemoScale.frame, "TOPRIGHT", 0, 0)
	ebKeybindFontSize:SetCallback( "OnEnter", function(self) Nemo.UI.ShowTooltip(self.frame, L["options/ebKeybindFontSize/tt"], "LEFT", "RIGHT", 0, 0, "text") end )
	ebKeybindFontSize:SetCallback( "OnLeave", Nemo.UI.HideTooltip )
	ebKeybindFontSize:SetCallback( "OnEnterPressed", function(self)
		
		local lNewValue = self:GetText()
		if ( Nemo:NilToNumeric( lNewValue )>=0 and Nemo:NilToNumeric( lNewValue )<= 100 ) then
			Nemo.DB.profile.options.keybindfontsize = lNewValue
			self:SetText( lNewValue )
		end
	end )
	ebKeybindFontSize:SetText( Nemo.DB.profile.options.keybindfontsize or 12 )
	
	-- Print Highest Priority CheckBox
	local PrintHighestPriority = Nemo.UI:Create("CheckBox")
	Nemo.UI.sgMain.tgMain.sgPanel:AddChild( PrintHighestPriority )
	PrintHighestPriority:SetLabel( L["options/cbPrintHighestPriority/l"] )
	PrintHighestPriority:SetWidth(400)
	PrintHighestPriority:SetPoint("TOPLEFT", ebNemoScale.frame, "BOTTOMLEFT", 0, 0);
	PrintHighestPriority:SetCallback( "OnValueChanged", function(self) Nemo.DB.profile.options.printhp = self:GetValue() end )
	if (Nemo:isblank(Nemo.DB.profile.options.printhp)) then
		PrintHighestPriority:SetValue(false)
		Nemo.DB.profile.options.printhp=false
	else
		PrintHighestPriority:SetValue( Nemo.DB.profile.options.printhp)
	end

end
function Nemo.UI.AnchorPostDrag()
	xOfs, yOfs = Nemo.UI.fAnchor:GetCenter()
	Nemo.UI.fAnchor:StopMovingOrSizing()
	Nemo.UI.fAnchor.isMoving=false
	Nemo.DB.profile.options.anchor.x = xOfs
	Nemo.DB.profile.options.anchor.y = yOfs
	Nemo.UI.fAnchor.moveable = false
	Nemo.UI.fAnchor:SetMovable(false)
	Nemo.UI.fAnchor:EnableMouse(false)
	Nemo.UI.fAnchor.Texture:SetAlpha(0)
	GameTooltip:Hide()
	-- Nemo.AButtons.SetAllMouse()
	Nemo.AButtons.bInitComplete = false	-- Nemo Anchor post drag Actions need to reenable their clicks after anchor drag
	Nemo.UI.fAnchor:SetFrameStrata("HIGH")
	if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then
		if ( Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorX ) then
			Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorX:SetText( Nemo.DB.profile.options.anchor.x )
		end
		if ( Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorY ) then
			Nemo.UI.sgMain.tgMain.sgPanel.ebAnchorY:SetText( Nemo.DB.profile.options.anchor.y )
		end
		return
	end
end
