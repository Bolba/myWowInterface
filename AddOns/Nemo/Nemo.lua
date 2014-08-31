Nemo         	 		= LibStub("AceAddon-3.0"):NewAddon("Nemo","AceConsole-3.0","AceEvent-3.0","AceSerializer-3.0","AceTimer-3.0","AceComm-3.0","AceHook-3.0")
Nemo.UI			 		= LibStub("AceGUI-3.0")
Nemo.MD			 		= LibStub("LibMapData-1.0")
Nemo.LibSimcraftParser	= LibStub("LibSimcraftParser")

Nemo.D					= {} --General data table to hold stuff
Nemo.ElvUI				= nil
local L      			= LibStub("AceLocale-3.0"):GetLocale("Nemo")
local addon				= ...

if ( ElvUI ) then
	local EP 	 = LibStub("LibElvUIPlugin-1.0")
	Nemo.ElvUI   = unpack(ElvUI);
	Nemo.D.ElvUI = Nemo.ElvUI:NewModule('Nemo')
	Nemo.ElvUI:RegisterModule(Nemo.D.ElvUI:GetName())
	Nemo.D.ElvUI.Initialize = function()
		LibStub("LibElvUIPlugin-1.0"):RegisterPlugin(addon, Nemo.D.ElvUI.AddOptionMenu)
	end
end
function Nemo:ProcessSlashCommand(commandargs)
	if (Nemo:isblank(commandargs)) then
		if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then
			Nemo.UI.fMain:Hide()
		else
			Nemo.UI.CreateMainFrame()
		end	
	elseif (commandargs=="debug") then
		Nemo:CreateDebugFrame()
	elseif (commandargs=="help") then
		print( L["common/help"] )
	elseif ( commandargs=="resetscale" ) then
		Nemo.DB.profile.options.uiscale = 1
		if ( Nemo.UI.fMain ) then
			if (Nemo.UI.fMain.frame) then Nemo.UI.fMain.frame:SetScale(1) end
			if (Nemo.UI.fMain:IsShown()) then 
				Nemo.UI.fMain:Hide()
				Nemo.UI.CreateMainFrame()
			end
		end
	elseif (commandargs=="update") then
		Nemo.UI.UpdateRotations()
	else
		Nemo.UI.SelectRotation(commandargs, false)
	end
end

function Nemo:OnInitialize()
	Nemo.DB = LibStub("AceDB-3.0"):New("NemoDB", Nemo:GetDefaults())
	Nemo.DB:RegisterDefaults(Nemo:GetDefaults())								-- Register default treeMain profile
end

function Nemo:OnEnable()
	Nemo.D.Initialize()															-- Initialize data
	Nemo.UI:InitAnchorFrame()
	Nemo:SecureHook("ActionButton_ShowOverlayGlow")
	Nemo:SecureHook("ActionButton_HideOverlayGlow")	
	Nemo:SecureHook("ActionButton_Update")

	if (LibStub and LibStub:GetLibrary('LibDataBroker-1.1', true)) then
		Nemo.D.LDB = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(L["common/nemo"], {
			type = 'launcher',
			text = L["common/nemo"],
			icon = 'Interface\\ICONS\\INV_Misc_Fish_09',
			OnClick = Nemo.UI.MenuOnClick,
			OnTooltipShow = function(tooltip)
				if not tooltip or not tooltip.AddLine then return end
				tooltip:AddLine(L["common/nemo"])
				tooltip:AddLine(L["common/LDB/tt1"])
				tooltip:AddLine(L["common/LDB/tt2"])
			end,
		})
	end
	
	Nemo:CreateDebugFrame1()
	Nemo:RegisterChatCommand("nemo", "ProcessSlashCommand")
	Nemo:RegisterComm(Nemo.D.Prefix)
	
	Nemo.MD:RegisterCallback("MapChanged", function(_,_MN,_MF,_W,_H)
        Nemo.D.MapName = _MN
        Nemo.D.MapFloor = _MF
        Nemo.D.MapW = _W or 0
        Nemo.D.MapH = _H or 0
    end)
	
	Nemo:RegisterEvent("PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_WORLD")	
	Nemo:RegisterEvent("ADDON_LOADED", "ADDON_LOADED")
	Nemo:RegisterEvent("UNIT_POWER", "UNIT_POWER")
	Nemo:RegisterEvent("UNIT_AURA", "UNIT_AURA")
	Nemo:RegisterEvent("UNIT_HEALTH", "UNIT_HEALTH")
	Nemo:RegisterEvent("UNIT_SPELLCAST_START", "UNIT_SPELLCAST_START")
	Nemo:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_START")
	Nemo:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_SUCCEEDED")
	Nemo:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "COMBAT_LOG_EVENT_UNFILTERED")
	Nemo:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED")
	Nemo:RegisterEvent("PET_BATTLE_OPENING_START", "PET_BATTLE_OPENING_START")
	Nemo:RegisterEvent("PET_BATTLE_CLOSE", "PET_BATTLE_CLOSE")
	Nemo:RegisterEvent("PLAYER_TOTEM_UPDATE", "PLAYER_TOTEM_UPDATE")
	Nemo:RegisterEvent("PLAYER_REGEN_ENABLED", "PLAYER_REGEN_ENABLED")
	Nemo:RegisterEvent("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_DISABLED")
	Nemo:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", "UPDATE_BATTLEFIELD_SCORE")
	Nemo:RegisterEvent("UNIT_COMBAT", "UNIT_COMBAT")
	
	Nemo:RegisterEvent('CHAT_MSG_INSTANCE_CHAT', "CHAT_MSG", "INSTANCE_CHAT")
	Nemo:RegisterEvent('CHAT_MSG_INSTANCE_CHAT_LEADER', "CHAT_MSG", "INSTANCE_CHAT_LEADER")
	Nemo:RegisterEvent("CHAT_MSG_BN_WHISPER", "CHAT_MSG", "BN_WHISPER")
	Nemo:RegisterEvent("CHAT_MSG_CHANNEL", "CHAT_MSG_CHANNEL")
	Nemo:RegisterEvent("CHAT_MSG_EMOTE", "CHAT_MSG", "EMOTE")
	Nemo:RegisterEvent("CHAT_MSG_GUILD", "CHAT_MSG", "GUILD")
	Nemo:RegisterEvent("CHAT_MSG_OFFICER", "CHAT_MSG", "OFFICER")
	Nemo:RegisterEvent("CHAT_MSG_PARTY", "CHAT_MSG", "PARTY")
	Nemo:RegisterEvent("CHAT_MSG_PARTY_LEADER", "CHAT_MSG", "PARTY_LEADER")
	Nemo:RegisterEvent("CHAT_MSG_RAID", "CHAT_MSG", "RAID")
	Nemo:RegisterEvent("CHAT_MSG_RAID_LEADER", "CHAT_MSG", "RAID_LEADER")
	Nemo:RegisterEvent("CHAT_MSG_RAID_WARNING", "CHAT_MSG", "RAID_WARNING")
	Nemo:RegisterEvent("CHAT_MSG_SAY", "CHAT_MSG", "SAY")
	Nemo:RegisterEvent("CHAT_MSG_WHISPER", "CHAT_MSG", "WHISPER")
	Nemo:RegisterEvent("CHAT_MSG_YELL", "CHAT_MSG", "YELL")
	
	Nemo:RegisterEvent("SYSMSG", "CHAT_MSG", "SYSMSG");
	Nemo:RegisterEvent("UI_INFO_MESSAGE", "CHAT_MSG", "UI_INFO_MESSAGE");
	Nemo:RegisterEvent("UI_ERROR_MESSAGE", "CHAT_MSG", "UI_ERROR_MESSAGE");
end
