local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")
local LM		= LibStub('Masque', true)

--*****************************************************
--Locals
--*****************************************************
-- Lua APIs
local strsub, strsplit, strlower, strmatch, strtrim, strfind = string.sub, string.split, string.lower, string.match, string.trim, string.find
local format, tonumber, tostring = string.format, tonumber, tostring
local tsort, tinsert = table.sort, table.insert
local select, pairs, next, type = select, pairs, next, type
local error, assert = error, assert

-- WoW APIs
local _G = _G
local IsSpellInRange = IsSpellInRange
local GetSpellInfo = GetSpellInfo
local UnitExists = UnitExists
local GetSpellLink = GetSpellLink
local GetTime = GetTime

--********************************************************************************************
-- Nemo Secure Action Buttons tables
--********************************************************************************************
Nemo.AButtons					= {} 				--Action Buttons
Nemo.AButtons.Frames			= {}				--The Action Button Frames
Nemo.AButtons.ExternalButtons	= {}				--Saved table of external buttons
--Nemo.AButtons.SlotToSABFrame	= {}				--Convert action slots to external frames that we care about
Nemo.AButtons.RFrames			= {}				--The Rotation Button Frames used for binding a key to a rotation
Nemo.AButtons.bInitComplete 	= false				--The boolean to tell the engine the buttons need to be reinitialized
Nemo.AButtons.bInInit			= false				--The boolean to throttle calls to initialize
Nemo.AButtons.LastInit      	= GetTime()			--Last Initialization time stamp

--********************************************************************************************
-- Functions
--********************************************************************************************
Nemo.AButtons.SetCombatAttributes = function ( NemoSABFrame, ButtonFrameName, rtk, RotationText, atk, ActionText  )
	--********************************************************************************************
	-- Combat SAFE
	-- Sets the combat insensitive attributes
	--********************************************************************************************
	NemoSABFrame.fn								= ButtonFrameName					-- Frame name for shorter syntax
	NemoSABFrame._nemo_rotation_tree_key		= rtk								-- Rotation Tree Key
	NemoSABFrame._nemo_rotation_text			= RotationText						-- Rotation Name
	NemoSABFrame._nemo_action_tree_key	 		= atk								-- Action Tree Key
	NemoSABFrame._nemo_action_text				= ActionText						-- Action Name
	NemoSABFrame._nemo_action_db				= Nemo.D.RTMC[rtk].children[atk]	-- Action DB
	NemoSABFrame._nemo_criteria_ran_once 		= false								-- Reset the criteria ran once boolean
	NemoSABFrame._nemo_count_red				= 1
	NemoSABFrame._nemo_count_green				= 1
	NemoSABFrame._nemo_count_blue				= 1
	NemoSABFrame._nemo_count_alpha				= 1
	NemoSABFrame:GetNormalTexture():SetAlpha(0)										-- Hide the normal texture, it leaves a box around the icons

	--lButtonFrame:SetFrameStrata("MEDIUM")											-- Default frame strata
	if ( NemoSABFrame._nemo_action_db.at and NemoSABFrame._nemo_action_db.at == "spell" ) then
		NemoSABFrame._nemo_gid = Nemo.GetSpellID( NemoSABFrame._nemo_action_db.att2 )	-- Set global id (_nemo_gid)
	elseif ( NemoSABFrame._nemo_action_db.at and NemoSABFrame._nemo_action_db.at == "macro" ) then
		NemoSABFrame._nemo_gid = NemoSABFrame._nemo_action_db.att1
	elseif ( NemoSABFrame._nemo_action_db.at and NemoSABFrame._nemo_action_db.at == "item" ) then
		NemoSABFrame._nemo_gid = Nemo.GetItemId( NemoSABFrame._nemo_action_db.att1 )
	end
	NemoSABFrame._nemo_last_external_frame_check = GetTime()
end

function Nemo.AButtons.Initialize()
	--********************************************************************************************
	-- Combat UNSAFE
	-- Creates all the secure action buttons only when out of combat
	--********************************************************************************************
	local bInCombat = InCombatLockdown()
	if ( Nemo.AButtons.bInInit ) then -- Only initialize if we are not in the process of initializing
		return
	else
		Nemo.AButtons.bInInit 		= true
		Nemo.AButtons.LastInit 		= GetTime()												-- Update timer to throttle initializations
		Nemo.AButtons.bInitComplete	= true													-- Default the init complete to true, let checks set it back to false
	end

	-- if ( not bInCombat ) then
		-- Nemo.AButtons.SetAllMouse()
	-- else
		-- Nemo.AButtons.bInitComplete	= false
	-- end
	if ( bInCombat ) then Nemo.AButtons.bInitComplete = false end

	for rtk,rotation in pairs(Nemo.D.RTMC) do												-- Loop through the rotations to create all the buttons
		if ( not Nemo.AButtons.Frames[rotation.text] ) then Nemo.AButtons.Frames[rotation.text] = {} end
		if ( not bInCombat ) then
			Nemo.AButtons.SetRotationHotKey( rotation )										-- Create the rotation button and bind hotkey
		else
			-- Inform user initialization needs player to exit combat
			if ( (GetTime() - Nemo.D.LastChatSpam) > 20  ) then
				print( L["utils/debug/prefix"]..L["common/chatwarn/initpending"] )
				Nemo.D.LastChatSpam = GetTime()
			end
			Nemo.AButtons.bInitComplete = false												-- Partial initialization fail
		end

		for atk,action in pairs(Nemo.D.RTMC[rtk].children) do								-- Loop through the actions in this rotation and create the Nemo secure action buttons
			local lButtonFrame 		= nil
			local lButtonFrameName	= "Nemo.AButtons.Frames."..rotation.text.."."..atk

			if ( not bInCombat ) then
				--------------------------------------------------------------------------------------
				-- Combat sensitive methods
				if ( not Nemo.AButtons.Frames[rotation.text][atk] ) then
					Nemo.AButtons.Frames[rotation.text][atk] = CreateFrame("Button", "Nemo.AButtons.Frames."..rotation.text.."."..atk, Nemo.UI.fAnchor, "SecureActionButtonTemplate, ActionButtonTemplate")
				end

				lButtonFrame = Nemo.AButtons.Frames[rotation.text][atk]
				Nemo.AButtons.SetCombatAttributes( lButtonFrame, lButtonFrameName, rtk, rotation.text, atk, action.text  )
				if ( not Nemo:isblank(action.an) ) then
					Nemo.AddAlertInteractiveLabelToAction( rotation.text, rtk, atk, action.an ) 		-- Add nemo alert interactive label
				else
					Nemo.UI.HideVisualAlert( Nemo.AButtons.Frames[rotation.text][atk] )
					Nemo.AButtons.Frames[rotation.text][atk].nemoail = nil								-- Delete nemo alert interactive label
				end

				if ( not Nemo:isblank(action.hk) ) then													-- Setup HotKey
					SetBinding(action.hk, nil) 															-- Unbind the key first
					SetBindingClick( action.hk , lButtonFrameName)										-- Set the key binding
				end

				_G[lButtonFrameName.."HotKey"]:ClearAllPoints()
				_G[lButtonFrameName.."HotKey"]:SetPoint("TOPRIGHT", lButtonFrame, "TOPRIGHT", Nemo:NilToNumeric(action.w, 50)*.05*-1, (-.30 * (Nemo.DB.profile.options.keybindfontsize or 12)) )

				if ( not lButtonFrame._nemo_blizzard_overlay_exists ) then
					lButtonFrame._nemo_blizzard_overlay_exists = true
					ActionButton_HideOverlayGlow(lButtonFrame)							 				-- If we call the blizzard ActionButton_HideOverlayGlow blizzard creates a glow overlay frame on our nemo action
				end

				-- Setup the the rest of the button
				Nemo.AButtons.SetPosition( lButtonFrame )
				Nemo.AButtons.SetDimensions( lButtonFrame, action )
				Nemo.AButtons.SetSABAttributes( lButtonFrame )
				lButtonFrame:SetScript("OnEnter", function(self) Nemo.AButtons.OnEnter( self ) end)
				lButtonFrame:SetScript("OnLeave", function(self) Nemo.UI.HideTooltip() end )
				Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[rotation.text][atk] )				-- Create the criteria function from the action.criteria field, after the frame is created
				if ( LM ) then																			-- LibMasque registered
					LM:Group('Nemo', 'Action Buttons'):AddButton(Nemo.AButtons.Frames[rotation.text][atk])
				end
				lButtonFrame:RegisterForClicks("AnyUp")													-- Have to register for anyup otherwise right click doesnt work
				Nemo.AButtons.SetMouse( lButtonFrame )													-- Mouse has to be disabled very last so blizzard functions do not enable it
			elseif ( bInCombat and Nemo.AButtons.Frames[rotation.text] and Nemo.AButtons.Frames[rotation.text][atk] ) then
				lButtonFrame = Nemo.AButtons.Frames[rotation.text][atk]
				Nemo.AButtons.SetCombatAttributes( lButtonFrame, lButtonFrameName, rtk, rotation.text, atk, action.text  )
				Nemo.SetActionCriteriaFunction( Nemo.AButtons.Frames[rotation.text][atk] )				-- Create the criteria function from the action.criteria field, after the frame is created
				if ( LM ) then																			-- LibMasque registered
					LM:Group('Nemo', 'Action Buttons'):AddButton(Nemo.AButtons.Frames[rotation.text][atk])
				end
				lButtonFrame:RegisterForClicks("AnyUp")													-- Have to register for anyup otherwise right click doesnt work
				Nemo.AButtons.SetMouse( lButtonFrame )													-- Mouse has to be disabled very last so blizzard functions do not enable it
			end
		end
	end
	Nemo.AButtons.bInInit = false
end
function Nemo.AButtons.GetAnchored( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Returns boolean
	--********************************************************************************************
	if ( not NemoSABFrame or not NemoSABFrame._nemo_action_db ) then return end -- Exit if profile tree is not available
	local point, relativeTo, relativePoint, xOfs, yOfs = NemoSABFrame:GetPoint()
	local lAnchored = false
	if ( point and point == "TOPLEFT" and relativeTo == Nemo.UI.fAnchor and relativePoint == "TOPLEFT" ) then
		lAnchored = true
	end

	if ( (not Nemo:isblank(NemoSABFrame._nemo_action_db.x)) or (not Nemo:isblank(NemoSABFrame._nemo_action_db.y)) ) then
		return false
	elseif ( not lAnchored ) then
		return false
	else
		return true
	end
end
function Nemo.AButtons.SaveExternalButton( SABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Sets external actions information if visible for macro and button type actions
	--********************************************************************************************

-- Nemo:dprint("SaveExternalButton "..tostring( SABFrame:GetName() ) )

	if ( Nemo.AButtons.ExternalButtons[SABFrame] ) then return end

	local lSlot = Nemo:NilToNumeric( SABFrame._state_action or SABFrame.action or SABFrame or 0, 0 )
	if ( lSlot == 0 ) then return end
	-- if ( _G["BT4Button"..lSlot] and SABFrame:GetName() ~= _G["BT4Button"..lSlot]:GetName() ) then	-- Have to recursive call for bartender frames before visible check
		-- Nemo.AButtons.SaveExternalButton( _G["BT4Button"..lSlot] )
	-- end
	-- Recursive call to handle Bartender frames before visible check return
	-- if ( _G["BT4Button"..lSlot] and SABFrame:GetName() ~= _G["BT4Button"..lSlot]:GetName() ) then
	-- if ( _G["BT4Button"..lSlot] and SABFrame:GetName() ~= _G["BT4Button"..lSlot]:GetName() ) then Nemo.AButtons.SaveExternalButton( _G["BT4Button"..lSlot] ) end
	-- if ( _G["BT4Button"..lSlot*10] and SABFrame:GetName() ~= _G["BT4Button"..lSlot*10]:GetName() ) then Nemo.AButtons.SaveExternalButton( _G["BT4Button"..lSlot*10] ) end
	-- if ( _G["BT4Button"..lSlot*100] and SABFrame:GetName() ~= _G["BT4Button"..lSlot*100]:GetName() ) then Nemo.AButtons.SaveExternalButton( _G["BT4Button"..lSlot*100] ) end
	
	-- Nemo.AButtons.AddExternalFrame( SABFrame )
	-- Nemo.AButtons.AddExternalFrame( _G["BT4Button"..lSlot] )
	-- Nemo.AButtons.AddExternalFrame( _G["BT4Button"..(lSlot*10)] )
	-- Nemo.AButtons.AddExternalFrame( _G["BT4Button"..(lSlot*100)] )
	
	if ( not SABFrame:IsVisible() ) then return end

	-- Save the external button to ExternalButtons table
	Nemo.AButtons.ExternalButtons[SABFrame] = true
end
function Nemo.AButtons.FramePassesExternalRequirements( NemoSABFrame, SABFrame )
-- if ( NemoSABFrame._nemo_action_text == "Savage Defense" and SABFrame:GetName() == "ElvUI_Bar1Button4" ) then
-- print("FramePassesExternalRequirements "..tostring(NemoSABFrame._nemo_action_text) )
-- end
	NemoSABFrame._nemo_external_frame_result = ''
	if ( not SABFrame:IsVisible() ) then
		NemoSABFrame._nemo_external_frame_result = 'Failed: IsVisible=false'
		return nil
	end	-- Action is not visible
	local lSABSlot 							= SABFrame._state_action or SABFrame.action or 0
	if ( lSABSlot == 0 ) then
		NemoSABFrame._nemo_external_frame_result = 'Failed: lSABSlot=0'
		return nil
	end
	if ( not Nemo:IsNumeric(lSABSlot) ) then
		NemoSABFrame._nemo_external_frame_result = 'Failed: lSABSlot=Table'
		return nil
	end

	local lSABType, lSABGlobalID, lSubType	= GetActionInfo( lSABSlot )
	local lSABMacroName 					= GetMacroInfo( lSABGlobalID or 0 )
	local lNemoSABGlobalID					= NemoSABFrame._nemo_gid
-- if ( NemoSABFrame._nemo_action_text == "Savage Defense" and SABFrame:GetName() == "ElvUI_Bar1Button4" ) then
-- print("    "..tostring(NemoSABFrame._nemo_action_text).." slot and hotkey match to "..tostring(SABFrame:GetName()) )
-- end

-- if ( NemoSABFrame._nemo_action_text == "Savage Defense" and SABFrame:GetName() == "ElvUI_Bar1Button4" ) then
-- print("    "..tostring(NemoSABFrame._nemo_action_text).." sab frame is visible "..tostring(SABFrame:GetName()) )
-- end
	if ( (not lSABType) or (not (NemoSABFrame._nemo_action_db.at == lSABType )) ) then
		NemoSABFrame._nemo_external_frame_result = 'Failed: Action type mismatch'
		return nil
	end
	if ( not (tostring(lSABGlobalID) == tostring(lNemoSABGlobalID)) and not (tostring(lSABMacroName) == tostring(lNemoSABGlobalID)) ) then
		NemoSABFrame._nemo_external_frame_result = 'Failed: Action global ID mismatch '..tostring(lNemoSABGlobalID)..'~='..tostring(lSABGlobalID)..' and '..tostring(lNemoSABGlobalID)..'~='..tostring(lSABMacroName)
		return nil
	end


	if ( not _G[SABFrame:GetName().."HotKey"] or ( _G[SABFrame:GetName().."HotKey"] and Nemo:isblank(_G[SABFrame:GetName().."HotKey"]:GetText()) ) ) then
		NemoSABFrame._nemo_external_frame_result = 'Failed: HotKey is blank'
		return nil
	end
-- if ( NemoSABFrame._nemo_action_text == "Savage Defense" and SABFrame:GetName() == "ElvUI_Bar1Button4" ) then
-- print("    "..tostring(NemoSABFrame._nemo_action_text).." full match to "..tostring(SABFrame:GetName()) )
-- end
	NemoSABFrame._nemo_external_frame_result = 'Passed GID='..tostring(lSABGlobalID)
	return SABFrame, lSABSlot
end
function Nemo.AButtons.SetExternalHighlightFrame( NemoSABFrame )
	local bCurrentRotation	= (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text))

	if ( not bCurrentRotation ) then return end

	local lTimeSinceLastCheck = GetTime()-( NemoSABFrame._nemo_last_external_frame_check or 0 )
	if ( not NemoSABFrame._nemo_external_frame and lTimeSinceLastCheck > 1 ) then -- Force the update checks to only happen once every 1 second
-- if ( NemoSABFrame._nemo_action_text == "Revealing Strike" ) then
-- print("SetExternalHighlightFrame "..tostring(NemoSABFrame._nemo_action_text) )
-- end
-- local startDTime = debugprofilestop()
		NemoSABFrame._nemo_last_external_frame_check = GetTime()
		if ( NemoSABFrame._nemo_action_db.dis == true ) then return end -- action is disabled dont bother with finding the external frame
		-- We dont have a external frame set look for a matching one
		local count = 1
		for SABFrame,v in pairs(Nemo.AButtons.ExternalButtons) do
			local ResultFrame, ResultSlot = Nemo.AButtons.FramePassesExternalRequirements( NemoSABFrame, SABFrame )
			if ( ResultFrame ) then
				Nemo.AButtons.HideOverlays( NemoSABFrame )
				Nemo.AButtons.HideOverlays( NemoSABFrame._nemo_external_frame )
				NemoSABFrame._nemo_external_frame = ResultFrame
				NemoSABFrame._nemo_external_slot  = ResultSlot
-- Nemo:eprint(lTimeSinceLastCheck.." Checked ("..count..") frames. Time to find external frame:"..NemoSABFrame._nemo_action_text, startDTime, .20)
-- Nemo:dprint("    "..NemoSABFrame._nemo_action_text.." matched ResultFrame["..tostring( ResultFrame:GetName() ).."]Slot["..ResultSlot.."] breaking out of loop" )
				break
			end
			count = count +1
		end
-- if ( not NemoSABFrame._nemo_external_frame ) then
-- Nemo:eprint(" Checked ("..count..") frames. Failed to find external frame:"..NemoSABFrame._nemo_action_text, startDTime, 0)
-- end
	elseif ( NemoSABFrame._nemo_external_frame and lTimeSinceLastCheck > 1 ) then
		NemoSABFrame._nemo_last_external_frame_check = GetTime()
		-- We already have one, validate it and if it doesnt match remove it and recursive call it
		if ( not Nemo.AButtons.FramePassesExternalRequirements( NemoSABFrame, NemoSABFrame._nemo_external_frame ) ) then
-- Nemo:dprint("    "..NemoSABFrame._nemo_action_text.." failed external match removing external frame ResultFrame["..tostring( NemoSABFrame._nemo_external_frame:GetName() ).."]" )
			Nemo.AButtons.HideOverlays( NemoSABFrame )
			Nemo.AButtons.HideOverlays( NemoSABFrame._nemo_external_frame )		-- We are removing the external frame so hide the nemo overlay
			NemoSABFrame._nemo_external_frame = nil
			NemoSABFrame._nemo_external_slot = nil
		end
	end

end

function Nemo.AButtons.SelectBehavior( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Shows or hides a single Nemo Secure Action button graphics / alerts
	-- This is the mother function for displaying actions
	-- NemoSABFrame  = The secure action button frame from table Nemo.AButtons.Frames[rotation.text][action]
	if ( not NemoSABFrame or not NemoSABFrame._nemo_action_db ) then return end

	Nemo.AButtons.SetExternalHighlightFrame( NemoSABFrame )
	Nemo.AButtons.SetFrame( NemoSABFrame )
	Nemo.AButtons.SetIcon( NemoSABFrame )
	Nemo.AButtons.SetCooldown( NemoSABFrame )
	Nemo.AButtons.SetCount( NemoSABFrame )
	Nemo.AButtons.SetActionHotKey( NemoSABFrame )
	Nemo.AButtons.SetOverlay( NemoSABFrame )
	Nemo.AButtons.SetAudioAlert( NemoSABFrame )
	Nemo.AButtons.SetVisualAlert( NemoSABFrame )
	Nemo.AButtons.SetDebugInfo( NemoSABFrame )
end
function Nemo.AButtons.SetRotationHotKey( tRotation )
	--********************************************************************************************
	-- Combat UNSAFE
	-- Create a invisible button to bind a key for rotation selection
	--********************************************************************************************
	local lButtonName = "Nemo.AButtons.RFrames."..tRotation.text
	if ( not Nemo.AButtons.RFrames[tRotation.text] ) then
		Nemo.AButtons.RFrames[tRotation.text] = CreateFrame("Button", lButtonName, Nemo.UI.fAnchor, "SecureActionButtonTemplate, ActionButtonTemplate")
	end
	Nemo.AButtons.RFrames[tRotation.text]:SetAlpha(0)
	Nemo.AButtons.RFrames[tRotation.text]:SetWidth(0)
	Nemo.AButtons.RFrames[tRotation.text]:SetHeight(0)
	Nemo.AButtons.RFrames[tRotation.text]:EnableMouse(false)
	Nemo.AButtons.RFrames[tRotation.text]:SetAttribute("type", "macro")
	Nemo.AButtons.RFrames[tRotation.text]:SetAttribute("macrotext","/nemo "..tRotation.text)

	if ( not Nemo:isblank(tRotation.hk) ) then
		SetBinding(tRotation.hk, nil) -- Unbind the key first
		SetBindingClick(tRotation.hk, lButtonName)
	end
end
function Nemo.AButtons.SetPosition( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Sets the Nemo Action Button position if out of combat
	--********************************************************************************************
	if ( not NemoSABFrame._nemo_action_db ) then return end -- Exit if profile tree is not available
	if ( not InCombatLockdown() ) then
		NemoSABFrame:ClearAllPoints()
		NemoSABFrame:SetPoint("TOPLEFT", Nemo.UI.fAnchor, "TOPLEFT", Nemo:NilToNumeric(NemoSABFrame._nemo_action_db.x), Nemo:NilToNumeric(NemoSABFrame._nemo_action_db.y))
	end
end

function Nemo.AButtons.SetDimensions( NemoSABFrame )
	--********************************************************************************************
	-- Combat UNSAFE
	-- Sets the Nemo Action Button dimensions
	--********************************************************************************************
	if ( not NemoSABFrame._nemo_action_db ) then return end -- Exit if profile tree is not available
	local widthPercent	= string.match( NemoSABFrame._nemo_action_db.w or '', '([%d%.,]+)%%' )
	local heightPercent	= string.match( NemoSABFrame._nemo_action_db.h or '', '([%d%.,]+)%%' )
	local widthNumber = Nemo:NilToNumeric(NemoSABFrame._nemo_action_db.w, 50)
	local heightNumber = Nemo:NilToNumeric(NemoSABFrame._nemo_action_db.h, 50)
	if ( widthPercent ) then widthNumber = (widthPercent/100)*50 end
	if ( heightPercent ) then heightNumber = (heightPercent/100)*50 end	
	NemoSABFrame:SetSize(widthNumber, heightNumber)
end

function Nemo.AButtons.SetFrame( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Sets the nemo secure action frame to be shown or hidden
	----------------------------------------------------------------------------------------------
	local bInCombat			= InCombatLockdown()
	local bShowFrame 		= true
	local bCurrentRotation	= (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text))

	--Individual conditions to hide frame
	if ( Nemo.DB.profile.options.hidenemoactions ) then	bShowFrame = false end

	if ( bShowFrame and not bInCombat ) then
-- Nemo:dprint("showing frame "..NemoSABFrame.fn..":"..NemoSABFrame._nemo_action_text)
		NemoSABFrame:Show()
	elseif ( not bInCombat ) then
		NemoSABFrame:Hide()
	end
end

function Nemo.AButtons.SetIcon( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Sets the action icon texture and tint
	----------------------------------------------------------------------------------------------
	local bCurrentRotation				= (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text))
	local bIconLinked					= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_icon_criteria')            	-- Icon linked to criteria action passing
	local bHideIconTexture				= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_hide_icon_texture')			-- User wants to hide the icon texture
	local lDisplaysQueueSlot			= Nemo:NilToNumeric( string.match( strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_queue_slot%s(%d+)' ), 0 )
	local lDisplaysQueueSlotAnimated	= Nemo:NilToNumeric( string.match( strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_queue_slot_animated%s(%d+)' ), 0 )
	local lFromAnimatedFrame			= nil
	local lQueueSlot					= lDisplaysQueueSlot + lDisplaysQueueSlotAnimated	-- Only one of these should be in the comment text so just take the sum to get the queue slot
	local bAnchored						= Nemo.AButtons.GetAnchored( NemoSABFrame )
	local bShowIcon						= false
	local lTexture						= nil
	
	NemoSABFrame._nemo_seticon_result = ''	
	
	--Individual conditions to show icon
	if ( Nemo.Engine.GetQueueSlot( NemoSABFrame ) == 1 ) then bShowIcon = true end
	if ( lDisplaysQueueSlot > 0 and not bAnchored ) then bShowIcon = true end
	if ( lDisplaysQueueSlotAnimated > 0 ) then bShowIcon = true end
	if ( bCurrentRotation and not bAnchored and not bIconLinked ) then bShowIcon = true end
	if ( bCurrentRotation and not bAnchored and bIconLinked and NemoSABFrame._nemo_criteria_passed ) then bShowIcon = true end

	--Individual conditions to hide icon
	if (
		Nemo:isblank( Nemo.DB.profile.options.srk )
		or not Nemo.D.RTMC[Nemo.DB.profile.options.srk]
		or not bCurrentRotation
		or Nemo.D.InPetBattle
		or ( Nemo.DB.profile.options.hideoutofcombat and not InCombatLockdown() )
		or Nemo.UI.fAnchor.Texture:GetAlpha() == 1 -- Anchor frame is shown so only show the anchor fish texture
		) then
		bShowIcon = false
	end

	----------------------------------------------------------------------------------------------
	-- Get and set the correct texture to display
	if ( lQueueSlot > 0 ) then
		if ( not Nemo.Engine.Queue[lQueueSlot] ) then
			lTexture = nil
		else
			lTexture = Nemo.UI:GetActionTexture( Nemo.Engine.Queue[lQueueSlot] )       -- NemoSABFrame has _nemo_queue_slot comment so display the Engine.Queue texture instead
			for atk,action in pairs(Nemo.D.RTMC[Nemo.DB.profile.options.srk].children) do
				if ( action.criteria and ( string.find(action.criteria, '_nemo_queue_slot_animated%s'..(lQueueSlot+1)) ) ) then
					lFromAnimatedFrame = Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][atk]
					break
				end
			end
		end
	else
		lTexture = Nemo.UI:GetActionTexture( NemoSABFrame )
	end
	if ( _G[NemoSABFrame.fn.."Icon"]:GetTexture() ~= lTexture ) then _G[NemoSABFrame.fn.."Icon"]:SetTexture( lTexture )  end
	NemoSABFrame._nemo_seticon_result = NemoSABFrame._nemo_seticon_result..tostring( lTexture )
	
	----------------------------------------------------------------------------------------------
	-- Tint color
	if ( NemoSABFrame._nemo_action_db.dis ) then
		_G[NemoSABFrame.fn.."Icon"]:SetVertexColor(.8, .1, .1)                                                                            -- Set the icon tint to red if action is disabled
	else
		if ( NemoSABFrame._nemo_external_frame and Nemo.AButtons.GetAnchored(NemoSABFrame) ) then      -- Set the vertex color to the external action only for anchored actions
			_G[NemoSABFrame.fn.."Icon"]:SetVertexColor( _G[NemoSABFrame._nemo_external_frame:GetName().."Icon"]:GetVertexColor() )
		else
			_G[NemoSABFrame.fn.."Icon"]:SetVertexColor(1.0, 1.0, 1.0)                                     -- white default
		end
	end
		
	----------------------------------------------------------------------------------------------
	-- LibMasque handling + Texture handling
	if ( LM ) then
		local lLMAlpha = 0
		if ( bShowIcon ) then lLMAlpha = 1 end
		if ( LM:GetNormal(NemoSABFrame) ) then LM:GetNormal(NemoSABFrame):SetAlpha(lLMAlpha) end
		if ( LM:GetBackdrop(NemoSABFrame) ) then LM:GetBackdrop(NemoSABFrame):SetAlpha(lLMAlpha) end
		if ( LM:GetGloss(NemoSABFrame) ) then LM:GetGloss(NemoSABFrame):SetAlpha(lLMAlpha) end
	elseif ( bHideIconTexture ) then
		_G[NemoSABFrame.fn.."Icon"]:SetAlpha(0)
	end

	----------------------------------------------------------------------------------------------
	-- Set the icon x,y location or move the icon if the action is a animated queue slot
	_G[NemoSABFrame.fn.."Icon"]:ClearAllPoints()
	local lInGCD = Nemo.GetPlayerGCD()
	local lTotalAnimationTimeSeconds = .5	-- With haste, this value has to be under 1 second. Most people are under 1 second GCD with haste
	if ( lDisplaysQueueSlotAnimated > 0 and lInGCD > 0 and Nemo.Engine.Queue[lQueueSlot] and lFromAnimatedFrame ) then
		if ( not NemoSABFrame._nemo_global_cooldown or NemoSABFrame._nemo_global_cooldown == 0 ) then NemoSABFrame._nemo_global_cooldown = lInGCD end
-- Nemo:dprint("Processing X,Y for "..tostring(NemoSABFrame._nemo_action_text))
-- Nemo:dprint("    lInGCD="..tostring(lInGCD))
		--we have 1 second to get the icon from x,y of top left of _nemo_queue_slot_animation_(myqueueslot+1) TO _nemo_queue_slot_animation_(myqueueslot)

		local point, relativeTo, relativePoint, lFrom_TOPLEFT_x, lFrom_TOPLEFT_y = lFromAnimatedFrame:GetPoint(TOPLEFT)
		lFrom_TOPLEFT_x = Nemo:NilToNumeric(lFrom_TOPLEFT_x)
		lFrom_TOPLEFT_y = Nemo:NilToNumeric(lFrom_TOPLEFT_y)
		local point, relativeTo, relativePoint, lTo_TOPLEFT_x, lTo_TOPLEFT_y   = NemoSABFrame:GetPoint(TOPLEFT)
		lTo_TOPLEFT_x = Nemo:NilToNumeric(lTo_TOPLEFT_x)
		lTo_TOPLEFT_y = Nemo:NilToNumeric(lTo_TOPLEFT_y)
	

		
		--local lXDistanceBetweenQueueSlots = Nemo.Distance(lFrom_TOPLEFT_x, lFrom_TOPLEFT_y, lTo_TOPLEFT_x, lTo_TOPLEFT_y) --60
		local lXDistanceBetweenQueueSlots = -(lFrom_TOPLEFT_x - lTo_TOPLEFT_x)	--70
-- Nemo:dprint("    lXDistanceBetweenQueueSlots="..tostring(lXDistanceBetweenQueueSlots))

		--local lXPixelMoveRatePerSecond = lXDistanceBetweenQueueSlots/lTotalAnimationTimeSeconds  -- 60/.5=120 pixels per second
		local lAnimationTimeRemaining = ( lInGCD - lTotalAnimationTimeSeconds ) -- We want to be in position before cooldown ends, gcd=.8 -.5=.3 secondsremaining
		if ( lAnimationTimeRemaining < 0 ) then lAnimationTimeRemaining = 0 end
		

-- Nemo:dprint("    lAnimationTimeRemaining="..tostring(lAnimationTimeRemaining))

		local lAnimationPercentComplete = 1 - (lAnimationTimeRemaining/lTotalAnimationTimeSeconds)	-- (.5-.3)/.5=.4
-- Nemo:dprint("    lAnimationPercentComplete="..tostring(lAnimationPercentComplete))

		local lXOffsetWeShouldBeAt = -(lXDistanceBetweenQueueSlots - (lAnimationPercentComplete * lXDistanceBetweenQueueSlots))
		
		local lYLocationWeShouldBeAt = lTo_TOPLEFT_y
		
		_G[NemoSABFrame.fn.."Icon"]:SetPoint("TOPLEFT", Nemo.UI.fAnchor, "TOPLEFT", lXOffsetWeShouldBeAt, lYLocationWeShouldBeAt)
	else
		_G[NemoSABFrame.fn.."Icon"]:SetAllPoints( NemoSABFrame )
		NemoSABFrame._nemo_global_cooldown = 0
	end
	
	----------------------------------------------------------------------------------------------
	-- Icon sizing
	local widthPercent	= string.match( NemoSABFrame._nemo_action_db.w or '', '([%d%.,]+)%%' )
	local heightPercent	= string.match( NemoSABFrame._nemo_action_db.h or '', '([%d%.,]+)%%' )
	local widthNumber = Nemo:NilToNumeric(NemoSABFrame._nemo_action_db.w, 50)
	local heightNumber = Nemo:NilToNumeric(NemoSABFrame._nemo_action_db.h, 50)
	if ( widthPercent ) then widthNumber = (widthPercent/100)*50 end
	if ( heightPercent ) then heightNumber = (heightPercent/100)*50 end	
	_G[NemoSABFrame.fn.."Icon"]:SetSize(widthNumber, heightNumber)
		
	----------------------------------------------------------------------------------------------
	-- Show or hide the icon
	if ( bShowIcon ) then
		_G[NemoSABFrame.fn.."Icon"]:Show()
		NemoSABFrame._nemo_seticon_result = NemoSABFrame._nemo_seticon_result.." |cffF95C25ShowIcon:|r "..tostring( bShowIcon ).." |cffF95C25IconShown:|r "..tostring( _G[NemoSABFrame.fn.."Icon"]:IsShown() )
	else
		_G[NemoSABFrame.fn.."Icon"]:Hide()
		NemoSABFrame._nemo_seticon_result = NemoSABFrame._nemo_seticon_result.." |cffF95C25ShowIcon:|r "..tostring( bShowIcon ).." |cffF95C25IconShown:|r "..tostring( _G[NemoSABFrame.fn.."Icon"]:IsShown() )
	end
end

function Nemo.AButtons.SetCooldown( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Update the cooldown timer on action button
	--********************************************************************************************
	local cooldown 			= _G[NemoSABFrame.fn.."Cooldown"]
	local bShowCooldown 	= _G[NemoSABFrame.fn.."Icon"]:IsShown()
	local bCurrentRotation	= (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text))
	local lQueueSlot		= Nemo:NilToNumeric( string.match( NemoSABFrame._nemo_action_db.criteria or "", '--_nemo_queue_slot%s(%d+)' ), 0 )
	local lQueueFrame		= Nemo.Engine.Queue[lQueueSlot]

	cooldown:Hide()	-- Initialize the cooldown to hidden

	if ( not bCurrentRotation ) then
		NemoSABFrame._nemo_cooldown_duration = 0
		return 0 	-- Exit for buttons that are not part of current rotation
	end
	local start
	local duration = 0
	local enable

	if ( lQueueSlot > 0 and lQueueFrame ) then NemoSABFrame = lQueueFrame end	-- Check if action is a queue slot type then set to queue frame before checking frame attributes

	if ( NemoSABFrame._nemo_external_frame and NemoSABFrame._nemo_external_slot and strfind(strlower(NemoSABFrame._nemo_external_frame:GetName() or ""), 'pet') ) then
		start, duration, enable = GetPetActionCooldown( NemoSABFrame._nemo_external_slot )
	elseif ( NemoSABFrame._nemo_external_frame and NemoSABFrame._nemo_external_slot) then
 		start, duration, enable = GetActionCooldown( NemoSABFrame._nemo_external_slot )
	elseif ( NemoSABFrame._nemo_action_db.at == "spell" and not Nemo:isblank( Nemo.GetSpellID(NemoSABFrame._nemo_action_db.att2) ) ) then
		start, duration, enable = GetSpellCooldown( Nemo.GetSpellID(NemoSABFrame._nemo_action_db.att2) )
	elseif ( NemoSABFrame._nemo_action_db.at == "item" and not Nemo:isblank( NemoSABFrame._nemo_action_db.att1 ) and Nemo.GetItemId(NemoSABFrame._nemo_action_db.att1) ) then
		start, duration, enable = GetItemCooldown( Nemo.GetItemId(NemoSABFrame._nemo_action_db.att1) )
	end
	
	if ( duration and duration > 0 and bShowCooldown ) then
		cooldown:Show()
		CooldownFrame_SetTimer(cooldown, Nemo:NilToNumeric(start,GetTime()), Nemo:NilToNumeric(duration), enable)
	else
		duration = 0
	end
	
	NemoSABFrame._nemo_cooldown_start		= start
	NemoSABFrame._nemo_cooldown_duration	= duration
	NemoSABFrame._nemo_cooldown_enable		= enable
	return duration
end

function Nemo.AButtons.SetCount( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Update the count text (dot ticks, item counts) on nemo secure action button
	--********************************************************************************************
	local text				= _G[NemoSABFrame.fn.."Count"]
	local bOverride			= strfind(NemoSABFrame._nemo_action_db.criteria or "", 'Nemo%.SetCountInfo%(')
	local lQueueSlot		= Nemo:NilToNumeric( string.match( NemoSABFrame._nemo_action_db.criteria or "", '--_nemo_queue_slot%s(%d+)' ), 0 )
	local lQueueFrame		= Nemo.Engine.Queue[lQueueSlot]
	local bShowCount		= _G[NemoSABFrame.fn.."Icon"]:IsShown()
	if ( bShowCount ) then
		text:Show()
	else
		text:Hide()
	end

	local count=nil

	if ( lQueueSlot > 0 and lQueueFrame and _G[lQueueFrame.fn.."Count"] ) then
		count = _G[lQueueFrame.fn.."Count"]:GetText()
	elseif ( bOverride and NemoSABFrame.GetCount ) then	-- User overides abstract GetCount method
		count = NemoSABFrame.GetCount()
	elseif ( NemoSABFrame._nemo_external_frame and strfind(strlower(NemoSABFrame._nemo_external_frame:GetName() or ""), 'pet') ) then
		count = 0 --No way to retrieve info about pet slots
	elseif ( NemoSABFrame._nemo_external_slot and ( GetActionCount( NemoSABFrame._nemo_external_slot ) > 0 or Nemo:NilToNumeric( _G[NemoSABFrame._nemo_external_frame:GetName().."Count"]:GetText(), 0 ) > 0 ) ) then
		count = GetActionCount( NemoSABFrame._nemo_external_slot )
		if ( not count or count <= 0 ) then
			count = Nemo:NilToNumeric( _G[NemoSABFrame._nemo_external_frame:GetName().."Count"]:GetText(), 0 )
		end
	elseif ( NemoSABFrame._nemo_action_db.at == "item" and (not Nemo:isblank(NemoSABFrame._nemo_action_db.att1) and IsConsumableItem(NemoSABFrame._nemo_action_db.att1)) ) then
		count = GetItemCount(NemoSABFrame._nemo_action_db.att1, false, true)
	elseif ( NemoSABFrame._nemo_action_db.at == "spell" and (not Nemo:isblank(NemoSABFrame._nemo_action_db.att1) ) and (not Nemo:isblank(NemoSABFrame._nemo_action_db.att2) ) ) then
		if ( Nemo.D.PClass == "SHAMAN" and strfind(strlower(Nemo.GetSpellName( NemoSABFrame._nemo_action_db.att2 )), "totem")) then --Totem ticks
			for slot = 1, 4 do
				local haveTotem, totemName, startTime, duration = GetTotemInfo(slot)
				if ( totemName and totemName == Nemo.GetSpellName( NemoSABFrame._nemo_action_db.att2 ) ) then
					count = ceil( ( (startTime + duration) - GetTime() )/2 )
				end
			end
		elseif ( Nemo.D.SpellInfo[NemoSABFrame._nemo_action_db.att2] and Nemo.D.SpellInfo[NemoSABFrame._nemo_action_db.att2].baseticktime ) then
-- Nemo:dprint("found spellinfo for "..Nemo.GetSpellID(NemoSABFrame._nemo_action_db.att2).." baseticktime="..Nemo.D.SpellInfo[Nemo.GetSpellID(NemoSABFrame._nemo_action_db.att2)].baseticktime )
			count = Nemo.GetUnitHasMySpellTicksRemaining( NemoSABFrame._nemo_action_db.att1, NemoSABFrame._nemo_action_db.att2, Nemo.D.SpellInfo[Nemo.GetSpellID(NemoSABFrame._nemo_action_db.att2)].baseticktime or 2 )
-- Nemo:dprint("   count1 for "..Nemo.GetSpellID(NemoSABFrame._nemo_action_db.att2).."  count="..count )
		elseif ( Nemo.D.SpellInfo[NemoSABFrame._nemo_action_db.att2] and Nemo.D.SpellInfo[NemoSABFrame._nemo_action_db.att2].triggersid ) then -- Check the database for a triggered spell id to use to count
		
-- if ( tostring(NemoSABFrame._nemo_action_db.att2) == '1978' ) then
-- print( "found triggersid for "..NemoSABFrame._nemo_action_db.att2 )
-- end
			local lCountedSpellID = Nemo.D.SpellInfo[NemoSABFrame._nemo_action_db.att2].triggersid
			local lCountedSpellBaseTickTime = 2
			if ( Nemo.D.SpellInfo[lCountedSpellID] and Nemo.D.SpellInfo[lCountedSpellID].baseticktime ) then
				lCountedSpellBaseTickTime = Nemo.D.SpellInfo[lCountedSpellID].baseticktime
			end
			count = Nemo.GetUnitHasMySpellTicksRemaining(NemoSABFrame._nemo_action_db.att1, lCountedSpellID, lCountedSpellBaseTickTime)
-- if ( tostring(NemoSABFrame._nemo_action_db.att2) == '1978' ) then
-- print( "    CountSpell="..lCountedSpellID )
-- print( "    lCountedSpellBaseTickTime="..lCountedSpellBaseTickTime )
-- print( "    count="..tostring(count) )
-- end
		else
			count = Nemo.GetUnitHasMySpellTicksRemaining( NemoSABFrame._nemo_action_db.att1, NemoSABFrame._nemo_action_db.att2, 2 ) -- Default base tick time is 2 seconds
-- Nemo:dprint("   count3 for "..Nemo.GetSpellID(NemoSABFrame._nemo_action_db.att2).."  count="..count )
		end
	end
	
	--------------------------------------------------------------
	--Vertex
	text:SetVertexColor(NemoSABFrame._nemo_count_red, NemoSABFrame._nemo_count_green, NemoSABFrame._nemo_count_blue, NemoSABFrame._nemo_count_alpha )
	
	if ( bOverride and not Nemo:IsNumeric(count) ) then
		text:SetText(count)
	elseif ( Nemo:NilToNumeric(count,0) > 99 ) then
		text:SetText("*")
	elseif ( Nemo:NilToNumeric(count,0) > 0 ) then
		text:SetText( math.ceil(count) )
	else
		text:SetText("")
	end
end

function Nemo.AButtons.SetActionHotKey( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Create the hotkey font string and sets the Nemo Action Button HotKey text and binding
	--********************************************************************************************
	local text 				= _G[NemoSABFrame.fn.."HotKey"]
	local bShowHotkey		= _G[NemoSABFrame.fn.."Icon"]:IsShown()
	if ( bShowHotkey ) then
		text:Show()
	else
		text:Hide()
		return
	end
	local lQueueSlot		= Nemo:NilToNumeric( string.match( NemoSABFrame._nemo_action_db.criteria or "", '--_nemo_queue_slot%s(%d+)' ), 0 )
	local lQueueFrame		= Nemo.Engine.Queue[lQueueSlot]
	local lFontSize			= Nemo:NilToNumeric( Nemo.DB.profile.options.keybindfontsize, 12 )
	if ( lFontSize < 1 ) then lFontSize = 12 end
	text:ClearAllPoints()
	text:SetPoint("TOPRIGHT", NemoSABFrame, "TOPRIGHT", Nemo:NilToNumeric(NemoSABFrame._nemo_action_db.w, 50)*.05*-1, (-.30 * lFontSize) )
	if ( lFontSize > 0 ) then
		text:SetFont( (Nemo.DB.profile.options.keybindfont or "Fonts\\ARIALN.TTF"), lFontSize, "OUTLINE" )
	end
	
	if ( lQueueSlot > 0 and lQueueFrame and _G[lQueueFrame.fn.."HotKey"] and _G[lQueueFrame.fn.."HotKey"]:GetText() ) then
		text:SetText( _G[lQueueFrame.fn.."HotKey"]:GetText() )
	elseif ( lQueueSlot > 0 and not lQueueFrame ) then
		text:SetText( "" )
	elseif ( NemoSABFrame._nemo_action_db.hk and (text:GetText() == NemoSABFrame._nemo_action_db.hk) ) then    	-- User set a Nemo binding and it matches so no text to set

	elseif ( NemoSABFrame._nemo_action_db.hk and (text:GetText() ~= NemoSABFrame._nemo_action_db.hk) ) then 	-- User set a Nemo binding and we need to update the text
		text:SetText(NemoSABFrame._nemo_action_db.hk)
	elseif ( NemoSABFrame._nemo_external_frame
			and _G[NemoSABFrame._nemo_external_frame:GetName().."HotKey"]
			and _G[NemoSABFrame._nemo_external_frame:GetName().."HotKey"]:GetText() ) then						-- No Nemo binding set, use external frame keybind
		text:SetTextColor( _G[NemoSABFrame._nemo_external_frame:GetName().."HotKey"]:GetTextColor() )
		text:SetText( _G[NemoSABFrame._nemo_external_frame:GetName().."HotKey"]:GetText() )
	else																										-- Default to blank
		text:Hide()
	end

end
function Nemo.AButtons.SetMouse( NemoSABFrame )
	--********************************************************************************************
	-- Combat UNSAFE
	-- Sets the mouse enable boolean
	--********************************************************************************************

	local bInCombat		= InCombatLockdown()
	if ( NemoSABFrame._nemo_action_db.mouseenabled == nil ) then
		NemoSABFrame._nemo_action_db.mouseenabled = true
	end

	if ( Nemo.UI.fAnchor.Texture:GetAlpha() == 1 ) then
		NemoSABFrame:EnableMouse( false )	-- Disable the mouse click for actions so user can click through stack and drag the anchor frame
	elseif ( not bInCombat ) then
		if ( Nemo.DB.profile.options.clickthroughactions ) then
			NemoSABFrame:EnableMouse( false )
		else
			NemoSABFrame:EnableMouse( NemoSABFrame._nemo_action_db.mouseenabled )
		end
	end
end

function Nemo.AButtons.SetOverlay( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Determine which overlays to show (Nemo Icon and Orange outline)
	--********************************************************************************************
	local bAutonomous							= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_autonomous')
	local bCurrentRotation						= ( Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text) )
	local bDisabled								= ( NemoSABFrame._nemo_action_db.dis == true )
	local bIsLocked								= ( NemoSABFrame._nemo_external_frame and NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by )
	local bIsLockedByActionInCurrentRotation	= ( bIsLocked and bCurrentRotation and tostring(NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by._nemo_rotation_text) == Nemo.DB.profile.options.sr )
	
	NemoSABFrame._nemo_set_overlay_result = ''
	
	-- Criteria to show overlays
	if ( bCurrentRotation and bAutonomous and NemoSABFrame._nemo_criteria_passed and not Nemo.D.InPetBattle) then
-- Nemo:dprint("showing bAutonomous overlay for frame "..tostring( NemoSABFrame:GetName() ) )
		Nemo.AButtons.ShowOverlays( NemoSABFrame )	-- autonomous actions only overlay nemo actions
		NemoSABFrame._nemo_set_overlay_result = 'NemoOverlay: Shown autonomous'
	elseif ( bCurrentRotation and Nemo.Engine.GetQueueSlot( NemoSABFrame ) == 1 and NemoSABFrame._nemo_external_frame and not Nemo.D.InPetBattle) then
-- Nemo:dprint("showing external overlay externalFrameName="..tostring( NemoSABFrame._nemo_external_frame:GetName() ) )
		NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by = NemoSABFrame	-- Lock the overlay by this action so other actions with same spellid cant overwrite the showing
		Nemo.AButtons.ShowOverlays( NemoSABFrame._nemo_external_frame )
		NemoSABFrame._nemo_set_overlay_result = 'ExternalOverlay: Shown queue slot=1'
	elseif ( bCurrentRotation and Nemo.Engine.GetQueueSlot( NemoSABFrame ) == 1 and not Nemo.D.InPetBattle) then
-- Nemo:dprint("showing nemo overlay for frame "..tostring( NemoSABFrame:GetName() ) )
		Nemo.AButtons.ShowOverlays( NemoSABFrame )
		NemoSABFrame._nemo_set_overlay_result = 'NemoOverlay: Shown queue slot=1'
	elseif ( bIsLockedByActionInCurrentRotation and NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by ~= NemoSABFrame ) then
		-- Action overlay is already being handled by lock, but need this blank if to make sure it doesn't fall into else hide statement
		NemoSABFrame._nemo_set_overlay_result = 'ExternalOverlay: Shown lockedby='..tostring(NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by._nemo_action_text)
	else
		Nemo.AButtons.HideOverlays( NemoSABFrame )
		NemoSABFrame._nemo_set_overlay_result = 'Overlays: Hide lockedby='..tostring(NemoSABFrame._nemo_action_text)
		if ( NemoSABFrame._nemo_external_frame and NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by == NemoSABFrame) then
			Nemo.AButtons.HideOverlays( NemoSABFrame._nemo_external_frame )
			NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by = nil
		end
		
		-- local clear_nemo_overlay_locked_by=function()
			-- if ( NemoSABFrame._nemo_external_frame ) then NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by = nil end
		-- end
		-- if ( not bCurrentRotation and not bIsLockedByActionInCurrentRotation ) then
			-- NemoSABFrame._nemo_set_overlay_result = 'ExternalOverlay: Hide not current rotation'
			-- Nemo.AButtons.HideOverlays( NemoSABFrame._nemo_external_frame )
			-- clear_nemo_overlay_locked_by()
		-- elseif ( bCurrentRotation and bDisabled and not bIsLocked ) then
			-- NemoSABFrame._nemo_set_overlay_result = 'ExternalOverlay: Hide disabled'
			-- Nemo.AButtons.HideOverlays( NemoSABFrame._nemo_external_frame )
			-- if ( NemoSABFrame._nemo_external_frame ) then NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by = nil end
		-- elseif ( NemoSABFrame._nemo_external_frame and NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by == NemoSABFrame) then
			-- NemoSABFrame._nemo_set_overlay_result = 'ExternalOverlay: Hide lockedby='..tostring(NemoSABFrame._nemo_action_text)
			-- Nemo.AButtons.HideOverlays( NemoSABFrame._nemo_external_frame )
			-- if ( NemoSABFrame._nemo_external_frame ) then NemoSABFrame._nemo_external_frame._nemo_overlay_locked_by = nil end
		-- end
	end
end
function Nemo.AButtons.SetAudioAlert( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Plays the alert audio alert associated with the action
	--********************************************************************************************
	local bCurrentRotation	= (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text))
	local bAutonomous		= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_autonomous')		-- Autonomous action
	local bPlaySound		= false
	local lElapsed			= ( GetTime() - Nemo:NilToNumeric(NemoSABFrame.nemolastsoundplayed,0) )

	--Individual conditions to play sound
	if ( Nemo.Engine.GetQueueSlot( NemoSABFrame ) == 1 and NemoSABFrame.nemolastsoundplayed == 0  ) then bPlaySound = true end
	if ( bCurrentRotation and bAutonomous and NemoSABFrame._nemo_criteria_passed and NemoSABFrame.nemolastsoundplayed == 0 ) then bPlaySound = true end

	--Individual conditions to deblock sound playing
	if ( Nemo:isblank( NemoSABFrame._nemo_action_db.an ) ) then NemoSABFrame.nemolastsoundplayed = 0 end
	if ( lElapsed > 1.5) then -- Reallow the sound playing after 1.5 seconds or a global cooldown
		NemoSABFrame.nemolastsoundplayed = 0
	end

	if ( not bPlaySound ) then return end
	local lAlertDBKey = Nemo:SearchTable(Nemo.D.ATMC, "text", NemoSABFrame._nemo_action_db.an)
	local lAlertDB = Nemo.D.ATMC[lAlertDBKey]
	if ( Nemo:isblank( lAlertDB ) ) then return end							-- Exit if Alert Name does not exist
--Nemo:dprint("playingsound "..NemoSABFrame.fn..":"..NemoSABFrame._nemo_action_text)
	if ( Nemo:isblank( lAlertDB.aa ) or lAlertDB.aa == '_None' or lElapsed <= 3 or ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) ) then
		--Play comfort noise if there is no audible alert, or lElapsed <= 3, or the gui is open
	-- Nemo:dprint("comfortnoise aa="..tostring(lAlertDB.aa).." lElapsed="..tostring(lElapsed).." guiopen="..tostring(Nemo.UI.sgMain) )
		NemoSABFrame.nemolastsoundplayed = GetTime()
	elseif ( not Nemo:isblank( lAlertDB.aac ) and lAlertDB.aa == '_Custom' ) then
	-- Nemo:dprint("custom")
		PlaySoundFile(lAlertDB.aac, Nemo.D.SoundChannel)
		NemoSABFrame.nemolastsoundplayed = GetTime()
	else
	-- Nemo:dprint("playing="..lAlertDB.aa)
		PlaySound(lAlertDB.aa, Nemo.D.SoundChannel)
		NemoSABFrame.nemolastsoundplayed = GetTime()
	end
end
function Nemo.AButtons.SetVisualAlert( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Determine if visual alert is shown
	--********************************************************************************************
	local bAutonomous 		= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_autonomous')	-- Autonomous
	local bCurrentRotation	= (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text))
	local bIconShown		= _G[NemoSABFrame.fn.."Icon"]:IsShown()
	local bShowVisualAlert	= false

	--Individual conditions to show visual alert
	if ( bIconShown and Nemo.Engine.GetQueueSlot( NemoSABFrame ) == 1 ) then bShowVisualAlert = true end
	if ( bIconShown and bCurrentRotation and bAutonomous and NemoSABFrame._nemo_criteria_passed ) then bShowVisualAlert = true end

	if ( bShowVisualAlert ) then
		Nemo.UI.ShowVisualAlert( NemoSABFrame )
	else
		Nemo.UI.HideVisualAlert( NemoSABFrame )
	end
end
function Nemo.AButtons.SetDebugInfo( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Show debug information in the action gui
	--********************************************************************************************
	if ( not Nemo.UI.sgMain
		or not Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo
		or not Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo.frame:IsShown()
		or (
			Nemo.AButtons.Frames[Nemo.DB.profile.options.sr]
			and Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]] ~= NemoSABFrame
			)
		) then return end

-- if ( NemoSABFrame._nemo_action_text == "Ambush" ) then
-- print( "selected tree frame="..tostring(Nemo.AButtons.Frames[Nemo.DB.profile.options.sr][Nemo.UI.STL[3]]) )
-- print( "NemoSABFrame="..tostring(NemoSABFrame) )
-- end
	local lText = NemoSABFrame._nemo_action_text.."\n"
	lText = lText.."|cffF95C25Syntax:|r "..( NemoSABFrame._nemo_syntax_status or "").."\n"
	lText = lText.."|cffF95C25Criteria:|r "..( NemoSABFrame._nemo_criteria_status or "").."\n"
	lText = lText.."|cffF95C25Criteria Result:|r "..( NemoSABFrame._nemo_criteria_result or "").."\n"
	
	lText = lText.."|cffF95C25Texture:|r "..tostring(NemoSABFrame._nemo_getactiontexture_status)..' '..tostring(NemoSABFrame._nemo_seticon_result).."\n"	
	if ( NemoSABFrame._nemo_external_frame ) then
		lText = lText.."|cffF95C25ExternalFrame:|r "..tostring( NemoSABFrame._nemo_external_frame:GetName() )..' '..tostring( NemoSABFrame._nemo_external_frame_result )..' '..tostring( NemoSABFrame._nemo_set_overlay_result ).."\n"
	else
		lText = lText.."|cffF95C25ExternalFrame:|r nil\n"
	end
	
	lText = lText.."[Queue Slot#][Rotation Order#][Action Name][Time until needed]\n"
	lText = lText.."------------------------------------------------\n"
	
	for k, v in pairs(Nemo.Engine.Queue) do
		lText = lText.."["..k.."]["..v._nemo_action_tree_key.."]["..v._nemo_action_text.."]["..tostring( v._nemo_time_until_needed ).."]\n"
	end

	if ( not Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo._nemo_debug_paused ) then
		Nemo.UI.sgMain.tgMain.sgPanel.mlebInfo:SetText( lText )
	end
end
function Nemo.AButtons.SetQueueInfo( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Sets the queue information for the action
	--********************************************************************************************
	local bSuccess		  	= nil
	local bCriteriaPassed 	= false
	local bQueueAction		= true
	local bDisabled			= (NemoSABFrame._nemo_action_db.dis == true)
	local bRunOnce			= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_run_once')			-- only execute this actions criteria once
	local bCriteriaGroup	= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_criteria_group')	-- criteria group
	local bAutonomous		= strfind(strlower(NemoSABFrame._nemo_action_db.criteria or "") or "", '--_nemo_autonomous')		-- autonomous actions do not go into the queue rotation and highlight themselves
	local lQueueSlot		= Nemo:NilToNumeric( string.match( NemoSABFrame._nemo_action_db.criteria or "", '--_nemo_queue_slot%s(%d+)' ), 0 )

	-- Criteria processing
	if ( bCriteriaGroup or ( bRunOnce and NemoSABFrame._nemo_criteria_ran_once ) ) then
		-- Do not process criteria for bCriteriaGroup, or bRunOnce
	else
		Nemo.D.CriteriaSABFrame = NemoSABFrame															-- Set a global CriteriaSABFrame so that any failing criteria function calls can set error information
		NemoSABFrame._nemo_criteria_result = ''															-- Reset the criteria result text
		bSuccess, bCriteriaPassed = pcall(NemoSABFrame._nemo_action_db.fCriteria, NemoSABFrame )		-- Process criteria for everything else
		Nemo.D.CriteriaSABFrame = nil																	-- Set CriteriaSABFrame to nil so other internal functions calling criteria do not append to debug string
		if ( bRunOnce ) then NemoSABFrame._nemo_criteria_ran_once = true end
	end
	NemoSABFrame._nemo_criteria_passed = bCriteriaPassed												-- For external reference to avoid wasted cpu on function calling
	if ( bCriteriaGroup ) then
		NemoSABFrame._nemo_criteria_status = L["action/_nemo_criteria_status/i2"]						-- Add button is a criteria group text to debug
	elseif ( bDisabled ) then
		NemoSABFrame._nemo_criteria_status = L["action/_nemo_criteria_status/i3"]						-- Add button is disabled text to debug
	elseif ( not bSuccess ) then
		NemoSABFrame._nemo_criteria_status = L["action/_nemo_criteria_status/e1"]..tostring(bCriteriaPassed)
	else
		if ( not bCriteriaPassed or bDisabled) then
			if ( bDisabled ) then
				NemoSABFrame._nemo_criteria_status = L["action/_nemo_criteria_status/i1"]				-- button is disabled localization
			else
				NemoSABFrame._nemo_criteria_status = L["action/_nemo_criteria_status/fail"]
			end
		else
			NemoSABFrame._nemo_criteria_status = L["action/_nemo_criteria_status/pass"]
		end
	end


	-- Queue timing control
	NemoSABFrame._nemo_time_until_needed = Nemo.GetActionTimeUntilNeeded( NemoSABFrame )				-- Always set the time until needed

	-- Queue entry control
	if (
		bAutonomous			-- Action is autonomous and does not go into the queue
		or lQueueSlot > 0	-- Action displays a queue slot and does not go into the queue
		or bDisabled		-- Action is disabled
		) then
		bQueueAction = false
	end
	if ( bQueueAction and bCriteriaPassed) then
-- print("criteria passed checking if "..NemoSABFrame._nemo_action_text.." is already in queue")
		if ( not Nemo.Engine.ActionExistsInQueue(NemoSABFrame) ) then	-- Add to queue if it doesnt exist
-- print("  adding "..NemoSABFrame._nemo_action_text)
			Nemo.Engine.AddToQueue( NemoSABFrame )
		end
	else
-- print("criteria failed or not bQueueAction for "..NemoSABFrame._nemo_action_text.." remove it from queue")
		Nemo.Engine.RemoveFromQueue( NemoSABFrame )
	end
end

function Nemo.AButtons.SetSABAttributes( NemoSABFrame )
	--********************************************************************************************
	-- Combat UNSAFE
	-- Sets the left click and right click attributes to the action type
	--********************************************************************************************
	if ( not NemoSABFrame._nemo_action_db ) then return end -- Exit if profile tree is not available

	NemoSABFrame:SetAttribute("*type2", "macro")
	NemoSABFrame:SetAttribute("*macrotext2", '/script Nemo.AButtons.OnRightClick("'..NemoSABFrame.fn..'")' )

	-- Do not disable left clicking on stacked frames otherwise keybinds do not work
	if ( Nemo.D.RTMC[NemoSABFrame._nemo_rotation_tree_key].children[NemoSABFrame._nemo_action_tree_key].at == "spell" ) then
		NemoSABFrame:SetAttribute( "type1", "spell")
		NemoSABFrame:SetAttribute( "unit1", NemoSABFrame._nemo_action_db.att1 or "target")
		NemoSABFrame:SetAttribute( "spell1", Nemo.GetSpellName( NemoSABFrame._nemo_action_db.att2 ) )
	end
	if ( NemoSABFrame._nemo_action_db.at == "macro" ) then
		NemoSABFrame:SetAttribute( "type1", "macro")
		NemoSABFrame:SetAttribute( "macro1", NemoSABFrame._nemo_action_db.att1 )
	end
	if ( NemoSABFrame._nemo_action_db.at == "macrotext" ) then
		NemoSABFrame:SetAttribute( "type1", "macro")
		NemoSABFrame:SetAttribute( "macrotext1", NemoSABFrame._nemo_action_db.att1 )
	end
	if ( NemoSABFrame._nemo_action_db.at == "item" ) then
		NemoSABFrame:SetAttribute( "type1", "item")
		NemoSABFrame:SetAttribute( "item1", Nemo.GetItemName( NemoSABFrame._nemo_action_db.att1 ) )
	end
end
function Nemo.AButtons.OnEnter( NemoSABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Show the action tooltip
	--********************************************************************************************
	if ( not NemoSABFrame._nemo_action_db ) then return end -- Exit if profile tree is not available
	local lQueueSlot		= Nemo:NilToNumeric( string.match( NemoSABFrame._nemo_action_db.criteria or "", '--_nemo_queue_slot%s(%d+)' ), 0 )
	GameTooltip_SetDefaultAnchor(GameTooltip, NemoSABFrame)											-- Set the gametooltip anchor to default
	local lExternalFrame = nil
	local lExternalSlot  = nil

	-- User is mousing over the anchor, use the highest priority action to figure out tooltip
	----------------------------------------------------------------------------------------------------------------------------------------
	if ( Nemo.AButtons.GetAnchored(NemoSABFrame) ) then
		local _, lQS1Type, lQS1GID, _, lQS1Link, _, lQS1ExternalSlot = Nemo.Engine.GetQueueSlotInfo(1)
		if ( lQS1ExternalSlot ) then
			GameTooltip:SetAction( lQS1ExternalSlot )												-- Queue slot 1 has a external slot id so use it to make a link
		elseif ( lQS1Link ) then
			GameTooltip:SetHyperlink( lQS1Link )													-- Queue slot 1 does not have a external slot id so create tooltip
		end
	else
		-- User is mousing over a deanchored action, use the NemoSABFrame._nemo_action_db to figure out tooltip
		----------------------------------------------------------------------------------------------------------------------------------------
		local link						= Nemo.UI.GetActionLink( NemoSABFrame._nemo_action_db.at, NemoSABFrame._nemo_action_db.att1, NemoSABFrame._nemo_action_db.att2 )

		if ( lQueueSlot > 0 ) then
			local lQueueFrame = Nemo.Engine.Queue[lQueueSlot]
			if ( lQueueFrame ) then
				link = Nemo.UI.GetActionLink( lQueueFrame._nemo_action_db.at, lQueueFrame._nemo_action_db.att1, lQueueFrame._nemo_action_db.att2 )
				if ( link) then GameTooltip:SetHyperlink( link ) end
				-- print(L["utils/debug/prefix"]..tostring(Nemo.DB.profile.options.sr)..':'..lQueueFrame._nemo_action_text)
			end
		elseif ( NemoSABFrame._nemo_external_frame and strfind(NemoSABFrame._nemo_external_frame:GetName(), 'PetActionButton') ) then
			GameTooltip:SetPetAction( NemoSABFrame._nemo_external_slot )
			-- print(L["utils/debug/prefix"]..tostring(NemoSABFrame._nemo_rotation_text)..':'..tostring(NemoSABFrame._nemo_action_text))
		elseif ( NemoSABFrame._nemo_external_slot ) then
			GameTooltip:SetAction( NemoSABFrame._nemo_external_slot )
			-- print(L["utils/debug/prefix"]..tostring(NemoSABFrame._nemo_rotation_text)..':'..tostring(NemoSABFrame._nemo_action_text))
		elseif ( link ) then
			GameTooltip:SetHyperlink( link )
			-- print(L["utils/debug/prefix"]..tostring(NemoSABFrame._nemo_rotation_text)..':'..tostring(NemoSABFrame._nemo_action_text))
		end
	end
	GameTooltip:Show()
end

function Nemo.AButtons.OnRightClick( ButtonName )
	--********************************************************************************************
	-- Combat UNSAFE
	-- Right click function of actions buttons disables/enables a action
	--********************************************************************************************
	local NemoSABFrame 		= _G[ButtonName]
	if ( Nemo:isblank(NemoSABFrame) ) then return end
	if ( not NemoSABFrame._nemo_action_db ) then return end 												-- Return if profile tree is not available

	local bAnchored 		= Nemo.AButtons.GetAnchored( NemoSABFrame )
	local bCurrentRotation	= (Nemo.DB.profile.options.sr and (Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text))

	if ( IsShiftKeyDown() ) then
		-- To help the user find what buttons are overlapping let them shift right click
		if ( bAnchored and Nemo.Engine.Queue[1]	and Nemo.Engine.Queue[1]._nemo_action_text ) then
			print(L["utils/debug/prefix"]..Nemo.DB.profile.options.sr..':'..Nemo.Engine.Queue[1]._nemo_action_text )
			Nemo.UI.CreateMainFrame()
			Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.DB.profile.options.srk].value.."\001"..Nemo.D.RTMC[Nemo.DB.profile.options.srk].children[Nemo.Engine.Queue[1]._nemo_action_tree_key].value)
		elseif ( bAnchored and not Nemo.Engine.Queue[1] ) then
			print(L["utils/debug/prefix"]..NemoSABFrame._nemo_rotation_text..':'..NemoSABFrame._nemo_action_text)
			-- Do not show the action because the user clicked on the stack with no highest priority so no way to tell which button was clicked
		else
			print(L["utils/debug/prefix"]..NemoSABFrame._nemo_rotation_text..':'..NemoSABFrame._nemo_action_text)
			Nemo.UI.CreateMainFrame()
			Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[NemoSABFrame._nemo_rotation_tree_key].value.."\001"..Nemo.D.RTMC[NemoSABFrame._nemo_rotation_tree_key].children[NemoSABFrame._nemo_action_tree_key].value)
		end
		return
	end
	if ( bAnchored or not bCurrentRotation ) then return end							-- Do not allow right clicking disable on anchored actions or non current rotation actions
	if ( NemoSABFrame._nemo_action_db.dis == true ) then
		NemoSABFrame._nemo_action_db.dis = false										-- Set profile DB disabled to false
		_G[NemoSABFrame.fn.."Icon"]:SetVertexColor(1, 1, 1)								-- Set the icon tint to white
	else
		NemoSABFrame._nemo_action_db.dis = true											-- Set profile DB disabled to true
		_G[NemoSABFrame.fn.."Icon"]:SetVertexColor(.8, .1, .1)							-- Set the icon tint to red
	end
	--if ( Nemo.UI.sgMain and Nemo.UI.STL and Nemo.UI.STL[3]) then						--Refresh the gui if it is open and we have a action selected
		--Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].value.."\001"..Nemo.D.RTMC[Nemo.UI.STL[2]].children[Nemo.UI.STL[3]].value)
	if ( Nemo.UI.sgMain
		and Nemo.UI.STL
		and Nemo.UI.STL[3]
		and Nemo.UI.STL[3] == NemoSABFrame._nemo_action_tree_key
		and Nemo.DB.profile.options.sr
		and Nemo.DB.profile.options.sr == NemoSABFrame._nemo_rotation_text
		) then  --Update the action disabled checkbox if the gui is open and the action is selected
		Nemo.UI.sgMain.tgMain:SelectByValue(Nemo.D.RTM.value.."\001"..Nemo.D.RTMC[NemoSABFrame._nemo_rotation_tree_key].value.."\001"..Nemo.D.RTMC[NemoSABFrame._nemo_rotation_tree_key].children[NemoSABFrame._nemo_action_tree_key].value)
	end
end
function Nemo:ActionButton_ShowOverlayGlow( self )
	--********************************************************************************************
	-- Combat SAFE
	-- Post Hooked ActionButton_ShowOverlayGlow
	--********************************************************************************************
	if ( Nemo.DB.profile.options.hideblizzardglow ) then
		if self.overlay then
			self.overlay:Hide()
		end
	end
	Nemo.AButtons.SaveExternalButton(self)
end

function Nemo:ActionButton_HideOverlayGlow( self )
	--********************************************************************************************
	-- Combat SAFE
	-- Post Hooked ActionButton_HideOverlayGlow
	--********************************************************************************************
	Nemo.AButtons.SaveExternalButton(self)
end

function Nemo:ActionButton_Update( self )
	--********************************************************************************************
	-- Combat SAFE
	-- Secure post hook that maintains a Nemo table of external actions that call ActionButton_Update
	--********************************************************************************************
	Nemo.AButtons.SaveExternalButton(self)
end

function Nemo.AButtons.ShowOverlays( SABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Shows the overlay glow on the secure action frame
	--********************************************************************************************
	if ( SABFrame ) then
--Nemo:dprint("Nemo.AButtons.ShowOverlays SABFrame=true")
		-- Nemo overlay frame
		local w, h = SABFrame:GetSize()
		if ( not SABFrame.nemooverlay ) then
--Nemo:dprint("Creating SABFrame.nemooverlay ontop of frame "..SABFrame:GetName())
			SABFrame.nemooverlay = CreateFrame("Frame", SABFrame:GetName()..".nemooverlay", SABFrame)
			SABFrame.nemooverlay:SetPoint("BOTTOM", SABFrame)
		end
		-- Nemo Icon
		if ( not SABFrame.nemooverlay.ni ) then -- nemo icon
			SABFrame.nemooverlay.ni = SABFrame.nemooverlay:CreateTexture(nil, 'OVERLAY')
			SABFrame.nemooverlay.ni:SetTexture('Interface\\Addons\\Nemo\\Textures\\nemo')
		end
		SABFrame.nemooverlay.ni:SetSize(1.1 * w, 1.2 * h)
		SABFrame.nemooverlay.ni:SetPoint("BOTTOM", SABFrame, -.2 * w, -.5 * h)
		SABFrame.nemooverlay.ni:SetAlpha(.75)

		-- Nemo simple glow
		if ( not SABFrame.nemooverlay.sg ) then
-- Nemo:dprint("Creating simple glow ontop of frame "..SABFrame:GetName())
			SABFrame.nemooverlay.sg = SABFrame:CreateTexture(nil, 'OVERLAY') -- simple glow
			SABFrame.nemooverlay.sg:SetTexture('Interface\\Buttons\\UI-ActionButton-Border')
		end
		SABFrame.nemooverlay.sg:SetBlendMode('ADD')
		SABFrame.nemooverlay.sg:SetSize(2.2 * w, 2.2 * h)
		SABFrame.nemooverlay.sg:SetPoint("CENTER", SABFrame)
		SABFrame.nemooverlay.sg:SetVertexColor(.976, .361, .145)

		if ( Nemo.DB.profile.options.hidenemoicon ) then SABFrame.nemooverlay.ni:SetAlpha(0) else SABFrame.nemooverlay.ni:SetAlpha(1) end	-- ni = nemo icon
		if ( Nemo.DB.profile.options.simpleglow ) then
			SABFrame.nemooverlay.sg:SetAlpha(1)
-- Nemo:dprint("showing simple glow ontop of frame "..SABFrame:GetName())
		else
			SABFrame.nemooverlay.sg:SetAlpha(0)
-- Nemo:dprint("hiding simple glow ontop of frame "..SABFrame:GetName())
		end
		SABFrame.nemooverlay:SetAlpha(1)

	end
end
function Nemo.AButtons.HideOverlays( SABFrame )
	--********************************************************************************************
	-- Combat SAFE
	-- Hides the overlay glow on SABFrame
	-- SABFrame  = Any secure action button frame
	--********************************************************************************************
	if ( SABFrame and SABFrame.nemooverlay ) then
		SABFrame.nemooverlay:SetAlpha(0)
		SABFrame.nemooverlay.sg:SetAlpha(0)	-- Nemo simple glow
		SABFrame.nemooverlay.ni:SetAlpha(0)	-- Nemo icon
	end
end










