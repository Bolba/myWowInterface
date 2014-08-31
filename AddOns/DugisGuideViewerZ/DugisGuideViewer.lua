--[[ 
===============================================================
Dugi Guides Addon License Agreement

Copyright (c) 2010-2013 Dugi Guides LTD
All rights reserved.

File Source: http://www.ultimatewowguide.com 
Author Name: Fransisco Brevoort
Email: fbrevoort@xtra.co.nz 

The contents of this addon, excluding third-party resources, are
copyrighted to its author with all rights reserved, under United
States copyright law and various international treaties.

In particular, please note that you may not distribute this addon in
any form, with or without modifications, including as part of a
compilation, without prior written permission from its author.

The author of this addon hereby grants you the following rights:

1. You may use this addon for private use only.

2. You may make modifications to this addon for private use only.

All rights not explicitly addressed in this license are reserved by
the copyright holder.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local _
DugisGuideViewer = {
	events = {},
	globalHandlers = {},
	eventFrame = CreateFrame("Frame"),
	RegisterEvent = function(self, event, method)
		self.eventFrame:RegisterEvent(event)
		if self.events[event] then
			local existingRegistration = self.events[event]
			if type(existingRegistration)~="table" then
				if existingRegistration==method then return end
				self.events[event] = self.GetCreateTable(existingRegistration, method or event)
			else
				for _,exItem in existingRegistration:IPairs() do
					if exItem==method then return end
				end
				existingRegistration:Insert(method or event)
			end
		else
			self.events[event] = method or event
		end
	end,
	UnregisterEvent = function(self, event, method)
		local existingRegistration = self.events[event]
		if existingRegistration and type(existingRegistration)=="table" then
			assert(#existingRegistration>1)
			method = method or event
			existingRegistration:RemoveFirst(method)
			if #existingRegistration==1 then
				self.events[event] = existingRegistration[1]
				existingRegistration:Pool()
			end
			return
		end
		self.eventFrame:UnregisterEvent(event)
		self.events[event] = nil
	end,
	version = GetAddOnMetadata("DugisGuideViewer", "Version"),
	RegisterGlobalEventHandler = function(self, method)
		self.globalHandlers[method] = true
	end,
	UnregisterGlobalEventHandler = function(self, method)
		self.globalHandlers[method] = nil
	end,
}
local DugisGuideViewer = DugisGuideViewer

DugisGuideViewer.eventFrame:SetScript("OnEvent", function(self, event, ...)
	local entry = DugisGuideViewer.events[event]
	--if DugisGuideViewer.DebugFormat then DugisGuideViewer:DebugFormat("OnEvent", "event", event) end
	if type(entry)=="table" then
		for _,method in entry:IPairs() do
			if method and DugisGuideViewer[method] then
				DugisGuideViewer[method](DugisGuideViewer, event, ...)
			end
		end
	else
		if entry and DugisGuideViewer[entry] then
			DugisGuideViewer[entry](DugisGuideViewer, event, ...)
		end
	end
	for method in pairs(DugisGuideViewer.globalHandlers) do
		method(event, ...)
	end
end)

DugisGuideViewer:RegisterEvent("ADDON_LOADED")

DugisGuideUser = {
	QuestState = {}, --Tristate either skipped (x), finished (check) or neither (empty)
	turnedinquests = {},
	toskip = {},
	Debug = {},
}

local FirstTime = 1
local L = DugisLocals

if GetLocale() == "enUS" then
	DugisGuideViewer.Localize = 0
else
	DugisGuideViewer.Localize = 1
	
end

--local LastGuideNumRows = 0
local Debug = 0--Print Debug Messages
local Localize = 0	--Print Localization Error messages
local SettingsRevision = 5

DugisGuideViewer.Debug = Debug and Debug>0 and 1 or nil
DugisGuideViewer.ARTWORK_PATH = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\"
DugisGuideViewer.BACKGRND_PATH = "Interface\\DialogFrame\\UI-DialogBox-Background"
DugisGuideViewer.EDGE_PATH = "Interface\\DialogFrame\\UI-DialogBox-Border"

BINDING_HEADER_DUGI = L["Dugi Guides"]
_G["BINDING_NAME_CLICK DugisGuideViewer_TargetFrame:RightButton"] = L["Target Button"]
BINDING_NAME_DUGI_ITEM_BUTTON = L["Floating Item Button"]

function LocalizePrint(message)
	if Localize == 1 then
		print(message)
	end
end

function DebugPrint(message)
	if Debug == 1 then
		print(message)
	end
end

local function LoadSettings()
	local self = DugisGuideViewer
	--Settings Page Checkboxes
	DGV_QUESTLEVELON = 1
	DGV_LOCKSMALLFRAME = 2
	DGV_LOCKLARGEFRAME = 3
	DGV_WAYPOINTSON = 4
	DGV_ITEMBUTTONON = 5
	DGV_ENABLEQW = 6
	DGV_DUGIARROW = 7
	DGV_SHOWCORPSEARROW = 8
	DGV_CLASSICARROW = 9
	DGV_CARBONITEARROW = 10
	DGV_TOMTOMARROW = 11
	DGV_SHOWANTS = 12
	DGV_AUTOQUESTACCEPT = 13
	DGV_DISPLAYCOORDINATES = 14
	DGV_AUTOQUESTACCEPTALL = 15
	DGV_AUTOSELL = 16
	DGV_REMOVEMAPFOG = 17
	DGV_SMALLFRAMEBORDER = 18
	DGV_TARGETBUTTON = 19
	DGV_TARGETBUTTONSHOW = 20
	DGV_SHOWONOFF = 21
	DGV_STICKYFRAME = 22
	--DGV_AUTOSTICK = 24
	DGV_DISPLAYMAPCOORDINATES = 23
	DGV_ENABLEMODELDB = 24
	DGV_ENABLENPCNAMEDB = 25
	DGV_ENABLEQUESTLEVELDB = 26
	DGV_ANCHOREDSMALLFRAME = 27
	DGV_QUESTCOLORON = 28
	DGV_MAPPREVIEWHIDEBORDER = 29
	DGV_UNLOADMODULES = 30
	DGV_FIXEDWIDTHSMALL = 31
	DGV_MOVEWATCHFRAME = 32
	DGV_WATCHFRAMEBORDER = 33
	DGV_WORLDMAPTRACKING = 34
	DGV_AUTOQUESTITEMLOOT = 35
	DGV_ACCOUNTWIDEACH = 36
	DGV_EMBEDDEDTOOLTIP = 37
	DGV_OBJECTIVECOUNTER = 38
	DGV_MULTISTEPMODE = 39
	DGV_FIXEDWIDEFRAME = 40
	DGV_AUTOEQUIPSMARTSET = 41
	DGV_SHOWAUTOEQUIPPROMPT = 42
	DGV_DISABLEWATCHFRAMEMOD = 43	
	DGV_AUTOREPAIR = 44
	DGV_AUTOREPAIRGUILD = 45
	DGV_HIGHLIGHTSTEPONENTER = 46
	DGV_MANUALWAYPOINT = 47
	DGV_TOMTOMEMULATION = 48
	DGV_LOCKMODELFRAME = 49
	DGV_JOURNALFRAME = 50
	DGV_GUIDESUGGESTMODE = 51	
	
	--Sliders
	DGV_MINIBLOBQUALITY = 200
	DGV_SHOWTOOLTIP = 201
	DGV_RECORDSIZE = 202
	DGV_MAPPREVIEWDURATION = 203
	DGV_SMALLFRAMEFONTSIZE = 204
	DGV_TARGETBUTTONSCALE = 205
	DGV_ITEMBUTTONSCALE = 206
	
	--Dropdowns
	DGV_GUIDEDIFFICULTY = 100
	DGV_SMALLFRAMETRANSITION = 101
	DGV_LARGEFRAMEBORDER = 102
	DGV_STEPCOMPLETESOUND = 103
	DGV_ANTCOLOR = 104
	DGV_TAXIFLIGHTMASTERS = 109
	DGV_GASTATCAPLEVELDIFFERENCE = 111
	DGV_SMALLFRAMEDOCKING = 112
		
	--DGV_MINIBLOBS = 104
	DGV_TOOLTIPANCHOR = 105
	DGV_MAPPREVIEWPOIS = 106
	DGV_QUESTCOMPLETESOUND = 107
	DGV_DISPLAYPRESET = 108
	DGV_GASMARTSETTARGET = 110
	
	--Custom
	DGV_TARGETBUTTONCUSTOM = 300
	DGV_PROFILECUSTOM = 301
	DGV_GAWINCRITERIACUSTOM = 302

	local defaults = {
		profile = {
			char = {
				settings = {
					QuestRecordTable = {},
					QuestRecordEnabled = true,
					ModelViewer = {	pos_x = 300, pos_y = 45, relativePoint="CENTER"},
					StickyFrame = {	pos_x = 485, pos_y = 130, relativePoint="CENTER"},
					FirstTime = true,
					EssentialsMode = 0,
					SettingsRevision = 0,
					WatchFrameSnapped = true,
					GuideOn = true,
					sz = 51, --Num check boxes
					[DGV_QUESTLEVELON]			= { category = "Other",	text = "Display Quest Level", 	checked = false,	tooltip = "Show the quest level on the large and small frames", module = "Guides"},
					[DGV_QUESTCOLORON] 		= { category = "Other",	text = "Color Code Quest", 	checked = true,		tooltip = "Color code quest against your character's level", module = "Guides"},
					[DGV_LOCKSMALLFRAME] 		= { category = "Frames",	text = "Lock Small Frame", 	checked = false,	tooltip = "Lock small frame into place", module = "SmallFrame"},
					[DGV_MOVEWATCHFRAME] 		= { category = "Frames",	text = "Move Watch Frame", 	checked = false,	tooltip = "Allow movement of the watch frame, not available if 'Watch Frame Compatibility Mode' is on", module = "DugisWatchFrame"},
					[DGV_ANCHOREDSMALLFRAME] 	= { category = "Display",	text = "Anchored Small Frame", 	checked = true,	tooltip = "Allow a fixed Anchored Small Frame that will integrate with the Objective Tracker", module = "SmallFrame"},
					[DGV_LOCKLARGEFRAME] 		= { category = "Frames",	text = "Lock Large Frame", 	checked = false,	tooltip = "Lock large frame into place", module = "Guides"},
					[DGV_WAYPOINTSON]			= { category = "Waypoints",	text = "Automatic Waypoints", 	checked = true,		tooltip = "Automatically map waypoints from the Small Frame or from the Objective Tracker in essential mode",},
					[DGV_ITEMBUTTONON] 		= { category = "Questing",	text = "Floating Item Button",		checked = true,		tooltip = "Shows a small window to click when an item is needed for a quest",},
					[DGV_ENABLEQW] 			= { category = "Display",	text = "Automatic Quest Matching", checked = true,		tooltip = "Disable Blizzard's Automatic Quest Tracking feature and use Dugi Automatic Quest Matching feature which will sync your Objective tracker with the current guide.\n\nManually tracked quests will not be removed.", },
					[DGV_DUGIARROW]			= { category = "Waypoints",	text = "Show Dugi Arrow",	checked = true,		tooltip = "Show Dugis waypoint arrow",},
					[DGV_SHOWCORPSEARROW]		= { category = "Waypoints",	text = "Show Corpse Arrow",	checked = true,		tooltip = "Show the corpse arrow to direct you to your body", indent = true,},
					[DGV_CLASSICARROW]			= { category = "Waypoints",	text = "Classic Arrow",		checked = true,		tooltip = "Switch between modern and classic arrow icons", indent = true,},
					[DGV_CARBONITEARROW] 		= { category = "Waypoints",	text = "Use Carbonite Arrow",	checked = true,	tooltip = "Use the Carbonite arrow instead of the built in arrow",},
					[DGV_TOMTOMARROW] 		= { category = "Waypoints",	text = "Use TomTom Arrow", 	checked = false,	tooltip = "Use the TomTom arrow instead of the built in arrow",},
					[DGV_SHOWANTS] 			= { category = "Waypoints",	text = "Show Ant Trail",	checked = true,		tooltip = "Display ant trail between waypoints on the world map",},
					[DGV_AUTOQUESTACCEPT] 		= { category = "Questing",	text = "Auto Quest Accept",	checked = false,	tooltip = "Automatically accept and turn in quests from NPCs. Disable with shift",},
					[DGV_AUTOQUESTACCEPTALL]	= { category = "Questing",	text = "Only Quests In Current Guide",	checked = true,	tooltip = "Auto quest accept feature will only accept quests in current guide", indent = true, module = "Guides"},							
					[DGV_AUTOSELL]         		= { category = "Other",		text = "Auto Sell Greys",    	checked = true,    	tooltip = "Automatically sell grey quality items to merchant NPCs",},
					[DGV_AUTOREPAIR]			= { category = "Other",		text = "Auto Repair",    		checked = false,    tooltip = "Automatically repair all damaged equipment at repair NPC",},
					[DGV_AUTOREPAIRGUILD]		= { category = "Other",		text = "Use Guild Bank",    	checked = false,   	tooltip = "Use guild funds when repairing automatically", indent=true,},
					[DGV_GUIDESUGGESTMODE] 		= { category = "Questing",	text = "Guide Suggest Mode",	checked = true,		tooltip = "Suggest guides for your player on level up", module = "Guides"},
					[DGV_SMALLFRAMEBORDER] 		= { category = "Borders",	text = "Small Frame Border",	checked = true,		tooltip = "Use the same border that is selected for the large frame", module = "SmallFrame"},
					[DGV_WATCHFRAMEBORDER] 		= { category = "Borders",	text = "Watch Frame Border",	checked = true,		tooltip = "Use the same border that is selected for the large frame", module = "DugisWatchFrame"},
					[DGV_REMOVEMAPFOG]     		= { category = "Maps",		text = "Remove Map Fog",  	checked = true,    	tooltip = "View undiscovered areas of the world map, type /reload in your chat box after change of settings",},
					[DGV_HIGHLIGHTSTEPONENTER]	= { category = "Tooltip",	text = "Highlight Guide Steps",	checked = true,	tooltip = "Guide step text color intensifies when moused over", module = "SmallFrame"},
					[DGV_DISPLAYCOORDINATES]	= { category = "Tooltip",	text = "Tooltip Coordinates",	checked = false,	tooltip = "Show destination coordinates in the status frame tooltip", module = "Guides"},
					[DGV_TARGETBUTTON] 		= { category = "Target",	text = "Target Button",		checked = true,		tooltip = "Target the NPC needed for the quest step", module = "Target"},
					[DGV_TARGETBUTTONSHOW]		= { category = "Target",	text = "Show Target Button",	checked = true,		tooltip = "Show target button frame", indent = "true", module = "Target"},
					[DGV_SHOWONOFF]			= { category = "Frames",	text = "Show DG Icon Button",	checked = true,		tooltip = "Show the On/Off button which enables or disables the guide", },
					[DGV_STICKYFRAME]			= { category = "Frames",	text = "Enable Sticky Frame",	checked = true,		tooltip = "Shift click a quest step to track in the frame", module = "StickyFrame" },
					--[DGV_AUTOSTICK] 		= { category = "Other",		text = "Auto Stick", 		checked = true,		tooltip = "This feature will automatically add 'as you go...' step into sticky frame",},
					[DGV_DISPLAYMAPCOORDINATES] 	= { category = "Maps",		text = "Map Coordinates",  	checked = true,    	tooltip = "Show Player and Mouse coordinates at the bottom of the map.",},
					[DGV_WORLDMAPTRACKING] 		= { category = "Maps",		text = "World Map Tracking",  	checked = true,    	tooltip = "Add minimap tracking icons on the world map.",},
					[DGV_ENABLEMODELDB]		= { category = "Memory",	text = "Model Database",	checked = true,		tooltip = "Allows model viewer to function", module = "NpcsF"},
					[DGV_ENABLENPCNAMEDB]		= { category = "Memory",	text = "NPC Name Database",	checked = true,		tooltip = "Provides localized NPC names. Required for target button.", module = "Disabled"},
					[DGV_ENABLEQUESTLEVELDB]		= { category = "Memory",	text = "Quest Level Database",	checked = true,		tooltip = "Shows minimum level required for quests.\n\nAlso used for color coding the quests.", module = "ReqLevel"},
					[DGV_UNLOADMODULES]		= { category = "Memory",	text = "Unload Modules",	checked = false,	tooltip = "Unloading modules will allow the addon to run on low memory setting in Essential Mode but will require a UI reload to return back to normal. ", module = "Guides"},
					[DGV_MAPPREVIEWHIDEBORDER]	= { category = "Map Preview",	text = "Hide Border",		checked = true,		tooltip = "Hides the minimized map border when map preview is on.",},
					[DGV_AUTOQUESTITEMLOOT]	= { category = "Questing",	text = "Auto Quest Item Loot",	checked = true,		tooltip = "Automatically loot quest items.",},
					[DGV_ACCOUNTWIDEACH]		= { category = "Other",text = "Account Wide Achievement",	checked = true,		tooltip = "Detects account wide achievements completion.", module = "Guides"},
					[DGV_EMBEDDEDTOOLTIP]		= { category = "Display",	text = "Embedded Tooltip",	checked = true,	tooltip = "Displays tooltip information under guide step", module = "Guides"},
					[DGV_FIXEDWIDTHSMALL]		= { category = "Display",	text = "Fixed Width Small Frame",	checked = true,	tooltip = "Floating Small Frame won't adjust size horizontally and remain the same width as the Objective Tracker.", module = "Guides"},
					[DGV_OBJECTIVECOUNTER]		= { category = "Display",	text = "Show Quest Objectives",	checked = true,		tooltip = "Display quest objectives in small/anchored frame instead of the watch frame", module = "Guides"},
					[DGV_MULTISTEPMODE]		= { category = "Display",	text = "Multi-step Mode",	checked = true,	tooltip = "Allow status frame to show all currently relevant quests.", module = "Guides"},
					[DGV_FIXEDWIDEFRAME]		= { category = "Display",	text = "Wider Objective Tracker",	checked = false,	tooltip = "Increases the width of the Objective tracker",},
					[DGV_AUTOEQUIPSMARTSET]		= { category = "Gear Set",		text = "Auto Equip Smart Set",	checked = true,		tooltip = "Automatically maintain the best item for each slot as player level, active spec and inventory changes occur.", module = "GearAdvisor"},
					[DGV_SHOWAUTOEQUIPPROMPT]	= { category = "Gear Set",		text = "Show Auto Equip Prompt",checked = true,		tooltip = "Display a prompt to verify before committing auto equip changes", module = "GearAdvisor"},
					[DGV_DISABLEWATCHFRAMEMOD]	= { category = "Frames",		text = "Watch Frame Compatibility Mode",checked = true,		tooltip = "Lock Watch Frame to its default position. Enable this option if you use other addons that also modify or move the watch frame, a /reload maybe required to move the watch frame with other addons.", module = "DugisWatchFrame"},
					[DGV_MANUALWAYPOINT]		= { category = "Waypoints",		text = "Manual Waypoints",checked = true,		tooltip = "Enable user placed waypoints on the world map by pressing Ctrl + Right click or Shift + Right click to link them together, disable this option if the hotkey conflict with another addon",},
					[DGV_TOMTOMEMULATION]		= { category = "Waypoints",		text = "TomTom Addon Emulation",checked = true,		tooltip = "Enable /way commands and compatibility with other addons that use TomTom addon (eg LightHeaded)",},					
					[DGV_LOCKMODELFRAME]		= { category = "Frames", text = "Lock Model Frame",  checked = true,  tooltip = "Lock model viewer frame into place", module = "ModelViewer"},
					[DGV_JOURNALFRAME]			= { category = "Frames",		text = "NPC Journal Button", checked = true,		tooltip = "Enable NPC Journal Frame",},					

					[DGV_TARGETBUTTONCUSTOM]	= { category = "Target",	text = "Customize Macro",		checked = false,	tooltip = "Customize Target Macro", module = "Target", indent = true, editBox = "",},

					[DGV_GAWINCRITERIACUSTOM] = {category = "Gear Scoring", text = "Gear Scoring Priority", tooltip = "Determines how gear should be scored, in order of greatest to least importance.", module = "GearAdvisor",
						options = {
							"Active Talent Specialization",
							"Inactive Talent Specialization",
							"Highest Vendor Price"
						}
					},
					
					[DGV_GASTATCAPLEVELDIFFERENCE] = {category = "Gear Scoring", text = "Stat Cap Level Difference", tooltip = "Player/Target level difference. Used in determining caps for hit and expertise.", module = "GearAdvisor",
						checked = 2,
						options = {
							{	text = "Even (PvP)", value = 0, },
							{	text = "+1", value = 1, },
							{	text = "+2 (Heroic Dungeon)", value = 2, },
							{	text = "+3 (Raid)", value = 3, },
						}
					},
					
					[DGV_GASMARTSETTARGET] = {category = "Gear Set", text = "Smart Gear Set", tooltip = "Determines which scoring configuration should be used to equip gear with Dugi Smart Set.", module = "GearAdvisor",
						checked = "Active Talent Specialization",
						options = {}
					},

					[DGV_GUIDEDIFFICULTY]		= { category = "Questing",	text = "Leveling Mode",			checked = "Normal", module = "Guides",
						options = {
							{	text = "Easy", colorCode = GREEN_FONT_COLOR_CODE, },
							{	text = "Normal", colorCode = YELLOW_FONT_COLOR_CODE, },
							{	text = "Hard", colorCode = ORANGE_FONT_COLOR_CODE, },
						}
					},
					[DGV_SMALLFRAMETRANSITION] 	= { category = "Borders",		text = "Small Frame Effect",	checked = "Flash", module = "SmallFrame",
						options = {
							{	text = "Flash", },
							{	text = "Scroll", },
						}
					},
					[DGV_LARGEFRAMEBORDER] 		= { category = "Borders",		text = "Borders",	checked = "ElvUI",
						options = {
							{	text = "Default", },
							{	text = "BlackGold", },
							{	text = "Bronze", },
							{	text = "DarkWood", },
							{	text = "ElvUI", },
							{	text = "Eternium", },
							{	text = "Gold", },
							{	text = "Metal", },
							{	text = "MetalRust", },
							{	text = "OnePixel", },
							{	text = "Stone", },
							{	text = "StonePattern", },
							{	text = "Thin", },
							{	text = "Wood", },
						}
					},
					[DGV_STEPCOMPLETESOUND]		= { category = "Questing",	text = "Step Complete Sound", checked = "Sound\\Interface\\MapPing.wav", module = "Guides",
						options = {
							{	text = "None", 			value	= nil },
							{	text = "Map Ping", 		value = [[Sound\Interface\MapPing.wav]]},
							{	text = "Window Close", 		value = [[Sound\Interface\AuctionWindowClose.wav]]},
							{	text = "Window Open", 		value = [[Sound\Interface\AuctionWindowOpen.wav]]},
							{	text = "Boat Docked", 		value = [[Sound\Doodad\BoatDockedWarning.wav]]},
							{	text = "Bell Toll Alliance", 	value = [[Sound\Doodad\BellTollAlliance.wav]]},
							{	text = "Bell Toll Horde",	value = [[Sound\Doodad\BellTollHorde.wav]]},
							{	text = "Explosion",		value = [[Sound\Doodad\Hellfire_Raid_FX_Explosion05.wav]]},
							{	text = "Shing!",		value = [[Sound\Doodad\PortcullisActive_Closed.wav]]},
							{	text = "Wham!",			value = [[Sound\Doodad\PVP_Lordaeron_Door_Open.wav]]},
							{	text = "Simon Chime",		value = [[Sound\Doodad\SimonGame_LargeBlueTree.wav]]},
							{	text = "War Drums",		value = [[Sound\Event Sounds\Event_wardrum_ogre.wav]]},
							{	text = "Humm",			value = [[Sound\Spells\SimonGame_Visual_GameStart.wav]]},
							{	text = "Short Circuit",		value = [[Sound\Spells\SimonGame_Visual_BadPress.wav]]},
						}
					},
					[DGV_ANTCOLOR]		= { category = "Waypoints",	text = "Ant Trail Color", checked = "Interface\\COMMON\\Indicator-Green",

						options = {
							{	text = "Gray", colorCode = GRAY_FONT_COLOR_CODE,	value	= [[Interface\COMMON\Indicator-Gray]] },
							{	text = "Green",  colorCode = GREEN_FONT_COLOR_CODE,	value = [[Interface\COMMON\Indicator-Green]]},
							{	text = "Red", colorCode = RED_FONT_COLOR_CODE,	value = [[Interface\COMMON\Indicator-Red]]},
							{	text = "Yellow", colorCode = YELLOW_FONT_COLOR_CODE,	value = [[Interface\COMMON\Indicator-Yellow]]},
						}
					},
					[DGV_TAXIFLIGHTMASTERS]		= { category = "Waypoints",	text = "Use Flightmasters", checked = "Auto",
						options = {
							{	text = "Auto", colorCode = GREEN_FONT_COLOR_CODE, value = "Auto" },
							{	text = "Always", colorCode = YELLOW_FONT_COLOR_CODE, value = "Always" },
							{	text = "Never", colorCode = RED_FONT_COLOR_CODE, value = "Never" },
						}
					},						
					[DGV_QUESTCOMPLETESOUND]		= { category = "Questing",	text = "Quest Complete Sound", checked = "Sound\\Creature\\Peon\\PeonBuildingComplete1.wav", module = "DugisWatchFrame",
						options = {
							{	text = "None", 			value	= nil },
							{	text = "Default", 		value = [[Sound\Creature\Peon\PeonBuildingComplete1.wav]]},
							{	text = "Troll Male", 		value = [[Sound\Character\Troll\TrollVocalMale\TrollMaleCongratulations01.wav]]},
							{	text = "Troll Female",		value = [[Sound\Character\Troll\TrollVocalFemale\TrollFemaleCongratulations01.wav]]},
							{	text = "Tauren Male",		value = [[Sound\Creature\Tauren\TaurenYes3.wav]]},
							{	text = "Tauren Female",		value = [[Sound\Character\Tauren\TaurenVocalFemale\TaurenFemaleCongratulations01.wav]]},
							{	text = "Undead Male",		value = [[Sound\Character\Scourge\ScourgeVocalMale\UndeadMaleCongratulations02.wav]]},
							{	text = "Undead Female",		value = [[Sound\Character\Scourge\ScourgeVocalFemale\UndeadFemaleCongratulations01.wav]]},
							{	text = "Orc Male",		value = [[Sound\Character\Orc\OrcVocalMale\OrcMaleCongratulations02.wav]]},
							{	text = "Orc Female",		value = [[Sound\Character\Orc\OrcVocalFemale\OrcFemaleCongratulations01.wav]]},
							{	text = "NightElf Female",	value = [[Sound\Character\NightElf\NightElfVocalFemale\NightElfFemaleCongratulations02.wav]]},
							{	text = "NightElf Male",		value = [[Sound\Character\NightElf\NightElfVocalMale\NightElfMaleCongratulations01.wav]]},
							{	text = "Human Female",		value = [[Sound\Character\Human\HumanVocalFemale\HumanFemaleCongratulations01.wav]]},
							{	text = "Human Male",		value = [[Sound\Character\Human\HumanVocalMale\HumanMaleCongratulations01.wav]]},
							{	text = "Gnome Male",		value = [[Sound\Character\Gnome\GnomeVocalMale\GnomeMaleCongratulations03.wav]]},
							{	text = "Gnome Female",		value = [[Sound\Character\Gnome\GnomeVocalFemale\GnomeFemaleCongratulations01.wav]]},
							{	text = "Dwarf Male",		value = [[Sound\Character\Dwarf\DwarfVocalMale\DwarfMaleCongratulations04.wav]]},
							{	text = "Dwarf Female",		value = [[Sound\Character\Dwarf\DwarfVocalFemale\DwarfFemaleCongratulations01.wav]]},
							{	text = "Draenei Male",		value = [[Sound\Character\Draenei\DraeneiMaleCongratulations02.wav]]},
							{	text = "Draenei Female",	value = [[Sound\Character\Draenei\DraeneiFemaleCongratulations03.wav]]},
							{	text = "BloodElf Female",	value = [[Sound\Character\BloodElf\BloodElfFemaleCongratulations03.wav]]},
							{	text = "BloodElf Male",		value = [[Sound\Character\BloodElf\BloodElfMaleCongratulations02.wav]]},
							{	text = "Worgen Male",		value = [[Sound\Character\PCWorgenMale\VO_PCWorgenMale_Congratulations01.wav]]},
							{	text = "Worgen Female",		value = [[Sound\Character\PCWorgenFemale\VO_PCWorgenFemale_Congratulations01.wav]]},
							{	text = "Goblin Male",		value = [[Sound\Character\PCGoblinMale\VO_PCGoblinMale_Congratulations01.wav]]},
							{	text = "Goblin Female",		value = [[Sound\Character\PCGoblinFemale\VO_PCGoblinFemale_Congratulations01.wav]]},
							{	text = "Pandaren Male",		value = [[Sound\Character\PCPandarenMale\VO_PCPandarenMale_Congratulations02.wav]]},
							{	text = "Pandaren Female",		value = [[Sound\Character\PCPandarenFemale\VO_PCPandarenFemale_Congratulations02.wav]]},						
						}
					},
					[DGV_TOOLTIPANCHOR]			= {category = "Tooltip",	text = "Tooltip Anchor", checked = "Default", module = "SmallFrame",
						options = {



							{	text = "Default", },
							{	text = "Bottom", },
							{	text = "Top", },
							{	text = "Left", },
							{	text = "Right", },
							{	text = "Bottom Left", },
							{	text = "Bottom Right", },
							{	text = "Top Left", },
							{	text = "Top Right", },
						}
					},
					[DGV_MAPPREVIEWPOIS]			= {category = "Map Preview",	text = "Quest Objectives", checked = "Single Quest",
						options = {
							{	text = "All Available Quests", },
							{	text = "All Tracked Quests", },
							{	text = "Single Quest", },
						}
					},
					[DGV_DISPLAYPRESET]			= {category = "Display",	text = "Recommended Preset Settings", checked = "Multi-step - Anchored", module = "SmallFrame",
						options = {
							{	text = "Minimal", },
							{	text = "Minimal - No Borders", },
							{	text = "Standard", },
							{	text = "Standard - Anchored", },
							{	text = "Multi-step", },
							{	text = "Multi-step - Anchored", },							
						}
					},
					[DGV_SMALLFRAMEDOCKING] = {category = "Frames", text = "Small Frame Behavior", checked = "Auto", module = "SmallFrame",
						tooltip = "Decides how the Small Frame will expand when it is not anchored inside the Watch Frame.",
						options = {
							{ text = "Auto", },
							{ text = "Relative to Watch Frame", },
							{ text = "Expand Down", },
							{ text = "Expand Up", },
							{ text = "Expand in Both Directions", },
						}
					},
					[DGV_MINIBLOBQUALITY]		= { category = "Maps",	text = "Minimap Blob Quality",	checked = 0 },
					[DGV_SHOWTOOLTIP]			= { category = "Tooltip",	text = "Auto Tooltip (%ds)", checked = 5, module = "SmallFrame", tooltip ="Amount of time the Tooltip will remain in view from the last mouse over on small frame" },
					[DGV_MAPPREVIEWDURATION]	= {	category = "Map Preview",	text = "Duration (%ds)", checked = 5, tooltip = "Amount of time the Map Preview should remain in view (zero to disable).  Enabling this feature will automatically set the world map to windowed mode on reload." },
					[DGV_SMALLFRAMEFONTSIZE]	= {	category = "Display",	text = "Small Frame Font Size (%d)", checked = 12, module = "SmallFrame", tooltip = "Size of the font in the Small Frame." },
					[DGV_TARGETBUTTONSCALE]	    = {	category = "Display",	text = "Target Button Size (%d)", checked = 1, module = "Target", tooltip = "Size of the target button." },
					[DGV_ITEMBUTTONSCALE]	    = {	category = "Display",	text = "Item Button Size (%d)", checked = 1, module = "SmallFrame", tooltip = "Size of the item button." },
					[DGV_RECORDSIZE]			= { checked = 50 },
				},
			},
		}
	}
	self.db 		= LibStub("AceDB-3.0"):New("DugisGuideViewerProfiles", defaults)
	self.chardb		= self.db.profile.char.settings
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
end

function DugisGuideViewer:GuideOn()
	return DugisGuideViewer.chardb.GuideOn
end

function DugisGuideViewer:ProfileChanged()
	self.chardb = self.db.profile.char.settings
	self:ForceAllSettingsTreeCategories()
	self:SettingFrameChkOnClick()
end

local function Dugi_Fix()
	CurrentTitle = nil
	DugisGuideViewer.CurrentTitle = nil
	DugisGuideUser.CurrentQuestIndex = nil
	CurrentQuestName = nil
	DugisGuideUser = (DugisGuideUser and wipe(DugisGuideUser)) or  {}
	DugisGuideUser.toskip = {}
	DugisGuideUser.QuestState = {}
	DugisGuideUser.turnedinquests = {}
	DugisGuideUser.watchedQuests = {}
	DugisGuideUser.removedQuests = {}
	DugisGuideUser.DugisFlightmasterDataTable = {}
	DugisGuideViewerDB = nil
	DugisGuideViewer:ClearScreen()
end

local function ResetDB()
	local essentials = DugisGuideViewer.chardb.EssentialsMode
	local rev = DugisGuideViewer.chardb.SettingsRevision
	local guid = DugisGuideUser.CharacterGUID
	Dugi_Fix()
	LoadSettings()
	DugisGuideViewer.chardb.FirstTime = true
	DugisGuideUser.CharacterGUID = UnitGUID("player") or guid or "PRIOR_RESET"
	DugisGuideViewer.chardb.SettingsRevision = SettingsRevision
	DugisGuideViewer.chardb.EssentialsMode = essentials
end

function DugisGuideViewer:OnInitialize()
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("CHAT_MSG_SYSTEM");
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_WATCH_UPDATE")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_AUTOCOMPLETE")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_COMPLETE")	
	self:RegisterEvent("UI_INFO_MESSAGE")
	--self:RegisterEvent("QUEST_QUERY_COMPLETE")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("ACHIEVEMENT_EARNED")
	self:RegisterEvent("CRITERIA_UPDATE")
	self:RegisterEvent("TRADE_SKILL_UPDATE")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("PET_BATTLE_OPENING_START")
	
	CATEGORY_TREE = { 
		{ value = "Questing", 	text = L["Questing"], 	icon = nil },
		{ value = "Waypoints", 	text = L["Waypoints"], icon = nil },
		{ value = "Display", 	text = L["Display"], 	icon = nil },
		{ value = "Borders", 	text = L["Borders"], 	icon = nil },
		{ value = "Frames", 	text = L["Frames"], 	icon = nil },
		{ value = "Maps", 		text = L["Maps"], 		icon = nil },
		{ value = "Map Preview",text = L["Map Preview"],icon = nil },
		{ value = "Target",		text = L["Target Button"],	icon = nil },
		{ value = "Tooltip", 	text = L["Tooltip"], 	icon = nil },
		{ value = "Gear Scoring",		text = L["Gear Scoring"],		icon = nil },
		{ value = "Gear Set",		text = L["Gear Set"],		icon = nil },
		{ value = "Memory", 	text = L["Memory"], 	icon = nil },
		{ value = "Other", 		text = L["Other"], 	icon = nil },
		{ value = "Profiles", 	text = L["Profiles"] },
	}

	if not DugisGuideViewer:IsModuleRegistered("Guides") then tremove(CATEGORY_TREE, 12) end --Memory will be empty
	if not DugisGuideViewer:IsModuleRegistered("Guides") then tremove(CATEGORY_TREE, 9) end --Tooltip
	if not DugisGuideViewer:IsModuleRegistered("Target") then tremove(CATEGORY_TREE, 8) end --Target
	if not DugisGuideViewer:IsModuleRegistered("Guides") then tremove(CATEGORY_TREE, 3) end --Display
	
	LoadSettings()
	if DugisGuideViewerDB and DugisGuideViewerDB.char then --migrate old user data
		local settings = DugisGuideViewerDB.char[self.db.keys.profile] and DugisGuideViewerDB.char[self.db.keys.profile].settings
		if settings and settings.SettingsRevision==self.chardb.SettingsRevision then
			for k, v in pairs(settings) do
				self.db.profile.char.settings[k] = v
			end
		end
		DugisGuideViewerDB = nil
	end
	if self.chardb.SettingsRevision~=SettingsRevision then
		DugisGuideViewer:DebugFormat("resetting self.chardb.settings.SettingsRevision", "revision", self.chardb.SettingsRevision)
		ResetDB()
		self.chardb.SettingsRevision=SettingsRevision;
	end
	if not DugisGuideViewer:IsModuleRegistered("Guides") then
		self.chardb.EssentialsMode = 1
	end
	--self:InitMapping( )
	DugisGuideViewer:UpdateMainFrame()
	DugisGuideViewer:initAnts()
end

function DugisGuideViewer:initAnts()
	local addon
	for addon=1, GetNumAddOns() do
		local name, _, _, _, loadable  = GetAddOnInfo(addon)
		if name == "Carbonite" and loadable == 1 then DugisGuideViewer.carboniteloaded = true 
		elseif name == "TomTom" and loadable == 1 then DugisGuideViewer.tomtomloaded = true
		elseif name == "SexyMap" and loadable == 1 then DugisGuideViewer.sexymaploaded = false		
		elseif name == "nUI" and loadable == 1 then DugisGuideViewer.nuiloaded = false
		elseif name == "Tukui" and loadable == 1 then DugisGuideViewer.tukuiloaded = false
		elseif name == "ElvUI" and loadable == 1 then DugisGuideViewer.elvuiloaded = false
		elseif name == "ShestakUI" and loadable == 1 then DugisGuideViewer.shestakuiloaded = false
		elseif name == "Mapster" and loadable == 1 then DugisGuideViewer.mapsterloaded = true
		elseif name == "Armory" and loadable == 1 then DugisGuideViewer.armoryloaded = true
		elseif name == "Outfitter" and loadable == 1 then DugisGuideViewer.outfitterloaded = true
		elseif name == "ArkInventory" and loadable == 1 then DugisGuideViewer.arkinventoryloaded = true end
	end
	
	--if DugisGuideViewer.tomtomloaded then TomTom.profile.persistence.cleardistance = 0 end
end

function DugisGuideViewer:GetFontWidth(text, fonttype)
	local font = fonttype or "GameFontNormal"

	if not DugisFW then CreateFrame( "GameTooltip", "DugisFW" ) end
	local frame = DugisFW
	local fontstring = frame:CreateFontString("tmpfontstr","ARTWORK", font)
	fontstring:SetText(text)
	local fontwidth = fontstring:GetStringWidth()
	return fontwidth
end

function DugisGuideViewer:PrintTable( tbl )
	local key, val, val2
	
	DebugPrint("Table Contents:")
	
	if not tbl then DebugPrint("Table Empty") return end
	
	for key, val in pairs(tbl) do
		if type(val) == "table" then
			for _, val2 in pairs(val) do
				self:PrintBoolTbl(key,val2)
			end
		else
			self:PrintBoolTbl(key,val)
		end
	end
end

function DugisGuideViewer:PrintBoolTbl(key, val)
	local printstr = "key: "
	if type(key) == "boolean" then
		if key == true then printstr = printstr.."true" else printstr = printstr.."false" end
	else
		printstr = printstr..key
	end
	
	printstr = printstr.." val: "
	if type(val) == "boolean" then
		if val == true then printstr = printstr.."true" else printstr = printstr.."false" end
	else
		printstr = printstr..val
	end
	
	DebugPrint(printstr)
end

function DugisGuideViewer:OnLoad()
	--DugisGuideViewer.Target:Init( )
	--DugisGuideViewer.chardb.GuideOn = true
	--DugisGuideViewer.StickyFrame:Init( )
	DugisGuideViewer.AutoQuestAccept:Enable( )
	
	self:SetAllBorders()
	DugisGuideViewer:SetMemoryOptions()

	DugisGuideViewer:SetEssentialsOnCancelReload()
	DugisGuideViewer.chardb.GuideOn = DugisGuideViewer:GuideOn() and DugisGuideViewer:ReloadModules()
	DugisGuideViewer:SettingFrameChkOnClick(_, true)
	
	if (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) then 
		DugisGuideViewer:SetDB(false, DGV_ANCHOREDSMALLFRAME)
		DugisGuideViewer:SetDB(false, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(false, DGV_MOVEWATCHFRAME)
		DugisGuideViewer:UpdateCompletionVisuals()
	end

	collectgarbage()
	DugisGuideViewer:UpdateIconStatus()
	--if DugisGuideViewer.GuideOn and DugisGuideViewer.chardb.EssentialsMode ~= 1 then DelayandMoveToNextQuest(3) end
	if DugisGuideViewer:IsModuleLoaded("DugisWatchFrame") and self:UserSetting(DGV_DISABLEWATCHFRAMEMOD) then
		DugisGuideViewer.Modules.DugisWatchFrame:Reset()
	end
	DugisGuideViewer:RefreshQuestWatch()
	DugisGuideUser.PetBattleOn = false
	
	if DugisGuideViewer:UserSetting(DGV_ENABLENPCNAMEDB) == false then
		DugisGuideViewer:SetDB(true, DGV_ENABLENPCNAMEDB)
	end
end

function DugisGuideViewer:SetMemoryOptions()
	--[[if not DugisGuideViewer:UserSetting(DGV_ENABLEMODELDB) then 
		--table.wipe(self.ModelViewer.npcDB)
		--table.wipe(self.ModelViewer.objDB)
		--self.ModelViewer.npcDB = {}
		--self.ModelViewer.objDB = {}
		--DebugPrint("#Wipe Objects")
		DugisGuideViewer.UnloadModule("NpcsF")
		DugisGuideViewer.UnloadModule("ObjectsF")
		DugisGuideViewer.UnloadModule("NpcsT")
		DugisGuideViewer.UnloadModule("ObjectsT")
		DugisGuideViewer.UnloadModule("ModelViewer")
	elseif DugisGuideViewer.GuideOn then
		DugisGuideViewer:LoadModule("ModelViewer")
		DugisGuideViewer.LoadModule("NpcsF")
		DugisGuideViewer.LoadModule("ObjectsF")
		DugisGuideViewer.LoadModule("NpcsT")
		DugisGuideViewer.LoadModule("ObjectsT")
	end
	
	if not DugisGuideViewer:UserSetting(DGV_ENABLENPCNAMEDB) then 
		--table.wipe(DugisNPCs)
		DugisNPCs = {}
		DebugPrint("#Wipe NPC table")
	end
	
	if not DugisGuideViewer:UserSetting(DGV_ENABLEQUESTLEVELDB) then
		--table.wipe(self.ReqLevel)
		self.ReqLevel = {}
		DebugPrint("#Wipe ReqLevel table")
	end]]
	
	collectgarbage()
end

local function Disable(frame)
	if frame then 
		--DebugPrint("frame type:"..frame:GetObjectType())
		if frame:GetObjectType() == "CheckButton" then
			frame:SetChecked(0)
			frame.Text:SetTextColor(0.5, 0.5, 0.5)
		end
		frame:Disable() 
	end
end

local function Enable(frame)
	if frame then
		if frame:GetObjectType() == "CheckButton" then
			frame.Text:SetTextColor(1, 1, 1) 
		end
		frame:Enable() 
	end
end

local profileCache = {}
local profileList = {}
function getProfileList(noCurrent, noDefaults)
	wipe(profileList)
	if not noDefaults then
		profileList[1] = L["Default"]
		profileList[2] = DugisGuideViewer.db.keys.char
		profileList[3] = tinsert(profileList, DugisGuideViewer.db.keys.realm)
		profileList[4] = UnitClass("player")
	end
	
	wipe(profileCache)
	DugisGuideViewer.db:GetProfiles(profileCache)
	for _,v in ipairs(profileCache) do
		if not tContains(profileList, v) then
			tinsert(profileList, v)
		end
	end
	
	if noCurrent then
		for i,v in ipairs(profileList) do
			if v==DugisGuideViewer.db.keys.profile then
				tremove(profileList, i)
				break
			end
		end
	end
	
	return profileList
end

function DugisGuideViewer:UpdateOrderedListView(optionIndex, ...)
	local SettingsDB = 	DugisGuideViewer.chardb
	local container = _G["DGV_OrderedListContainer"..optionIndex]
	local height = 16*#SettingsDB[optionIndex].options
	if height==0 then height=1 end
	container:SetHeight(height)
	local lastShown
	for i=1,select("#", ...) do
		local option = SettingsDB[optionIndex].options[i]
		local child = select(i, ...)
		if option then
			if type(option)=="string" then
				child.text:SetText(L[option])
			else
				local _, specName = GetSpecializationInfo(option)
				child.text:SetText(specName)
			end
			child:Show()
			lastShown = child
		else
			child:Hide()
		end
	end
	return lastShown
end

local gearScoringCriteria = {}
local function GetGearScoringCriteria()
	wipe(gearScoringCriteria)
	for _, option in ipairs(DugisGuideViewer.chardb[DGV_GASMARTSETTARGET].options) do
		if option~="None" then
			tinsert(gearScoringCriteria, option)
		end
	end
	tinsert(gearScoringCriteria, "Highest Vendor Price")
	for _,option in ipairs(DugisGuideViewer.chardb[DGV_GAWINCRITERIACUSTOM].options) do
		local index = DugisGuideViewer.tIndexOfFirst(gearScoringCriteria, option)
		if index then tremove(gearScoringCriteria, index) end
	end
	return gearScoringCriteria
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetSettingsCategoryFrame(category, parent)
	local self = DugisGuideViewer
	local frameName = string.format("DGV_%sCategoryFrame", category)
	local frame = _G[frameName]
	if not frame then



		frame =  CreateFrame("Frame", frameName, parent)
		frame:SetAllPoints(parent)
	
		local fontstring = frame:CreateFontString(nil,"ARTWORK", "GameFontNormalLarge")
		fontstring:SetText(L[category])
		fontstring:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -16)
	end
	
	local SettingsDB = 	DugisGuideViewer.chardb
	local top = -40
	for SettingNum = 1, SettingsDB.sz do
		if SettingsDB[SettingNum].category==category
			and(not DugisGuideViewer:GetDB(SettingNum, "module") 
			or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(SettingNum, "module")))
		then
			local chkBoxName = "DGV.ChkBox"..SettingNum
			local chkBox = _G[chkBoxName]
			if not chkBox then

				chkBox = CreateFrame("CheckButton", chkBoxName, frame, "InterfaceOptionsCheckButtonTemplate")
				if SettingsDB[SettingNum].indent then
					chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top)
				else
					chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top)
				end
				chkBox.Text:SetText(L[SettingsDB[SettingNum].text])
				chkBox:SetHitRectInsets(0, 0, 0, 0)
				chkBox:RegisterForClicks("LeftButtonDown")
				chkBox:SetScript("OnClick", function() DugisGuideViewer:SettingFrameChkOnClick (chkBox) 	   end)
				chkBox:SetScript("OnEnter", function() DugisGuideViewer:SettingsTooltip_OnEnter(chkBox, event) end)
				chkBox:SetScript("OnLeave", function() DugisGuideViewer:SettingsTooltip_OnLeave(chkBox, event) end)
				top = top - chkBox:GetHeight()
			end
			chkBox:SetChecked(SettingsDB[SettingNum].checked)
		end
	end
	
	--Customize macro edit box
	if SettingsDB[DGV_TARGETBUTTONCUSTOM].category==category
		and(not DugisGuideViewer:GetDB(DGV_TARGETBUTTONCUSTOM, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_TARGETBUTTONCUSTOM, "module")))
	then
		local macroFrame = _G["DGV.MacroFrame"]
		local textBox =  _G["DGV.InputBox"..DGV_TARGETBUTTONCUSTOM]
		local chkBox =  _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]
		if not macroFrame then
			macroFrame = CreateFrame("Frame", "DGV.MacroFrame", frame)
			textBox = CreateFrame("EditBox", "DGV.InputBox"..DGV_TARGETBUTTONCUSTOM,  macroFrame, "InputBoxTemplate")
			chkBox = CreateFrame("CheckButton", "DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM, frame, "InterfaceOptionsCheckButtonTemplate")
			if SettingsDB[DGV_TARGETBUTTONCUSTOM].indent then
				chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top)
			else
				chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top)
			end
			chkBox.Text:SetText(L[SettingsDB[DGV_TARGETBUTTONCUSTOM].text])
			chkBox:SetHitRectInsets(0, -200, 0, 0)
			chkBox:RegisterForClicks("LeftButtonDown")
			chkBox:SetScript("OnClick", function() DugisGuideViewer:SettingFrameChkOnClick (chkBox)	   end)
			chkBox:SetScript("OnEnter", function() DugisGuideViewer:SettingsTooltip_OnEnter(chkBox, event) end)
			chkBox:SetScript("OnLeave", function() DugisGuideViewer:SettingsTooltip_OnLeave(chkBox, event) end)

			top = top - chkBox:GetHeight()

			macroFrame:SetSize(260, 90)
			macroFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top)
			DugisGuideViewer:SetFrameBackdrop(macroFrame, "Interface\\Tooltips\\UI-Tooltip-Background", "Interface\\Tooltips\\UI-Tooltip-Border", 5, 5, 5, 5)
			macroFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
			macroFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

			textBox:SetMultiLine(true)
			textBox:SetSize(260, 90)
			textBox:SetAutoFocus(false)
			textBox:ClearAllPoints( )
			textBox:SetPoint("TOPLEFT", macroFrame, "TOPLEFT", 10, -10)
			textBox:SetPoint("BOTTOMRIGHT", macroFrame, "BOTTOMRIGHT", -10, -10)
			textBox:SetMaxLetters(215)
			textBox:SetFont("Fonts\\FRIZQT__.TTF", 11)
			_G[textBox:GetName().."Left"]:SetTexture(nil)
			_G[textBox:GetName().."Middle"]:SetTexture(nil)
			_G[textBox:GetName().."Right"]:SetTexture(nil)
			
			textBox:Show()
			
			top = top - macroFrame:GetHeight()
			
			local button = DugisGuideViewer:CreateButton("DGV_ApplyMacroButton", frame, "Apply", function() DugisGuideViewer.Modules.Target:CustomizeMacro() end)
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top-3)
			local right = button:GetWidth()
			
			button = DugisGuideViewer:CreateButton("DGV_ResetMacroButton", frame, "Default", function() DugisGuideViewer.Modules.Target:ResetMacro() end)
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", 40 + right, top-3)
			local right2 = button:GetWidth()
			
			button = DugisGuideViewer:CreateButton("DGV_ClearMacroButton", frame, "Clear", function() DugisGuideViewer.Modules.Target:ClearMacro() end)

			button:SetPoint("TOPLEFT", frame, "TOPLEFT", 40 + right + right2, top-3)

			
			top = top-3-button:GetHeight()
		end
		
		chkBox:SetChecked(SettingsDB[DGV_TARGETBUTTONCUSTOM].checked)
		textBox:SetText(self.chardb[DGV_TARGETBUTTONCUSTOM].editBox)
	end
	
	--Reset GA Blacklist Button
	if category=="Gear Set" and not DGV_ResetGABlacklistButton then
		local button = CreateFrame("Button", "DGV_ResetGABlacklistButton", frame, "UIPanelButtonTemplate")
		local btnText = L["Reset Ban List"]
		local fontwidth = DugisGuideViewer:GetFontWidth(btnText, "GameFontHighlight")
		button:SetText(btnText)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", 
			function() 
				if self.chardb.GA_Blacklist then
					wipe(self.chardb.GA_Blacklist)
					self.Modules.GearAdvisor.AutoEquipSmartSet(nil, true, true)
				end
			end)
	end
	
	--custom new profile
	if category=="Profiles" then
		local profileFrame = _G["DGV.CustomProfileFrame"]
		local textBox =  _G["DGV.InputBox"..DGV_PROFILECUSTOM]
		if not profileFrame then
			profileFrame = CreateFrame("Frame", "DGV.CustomProfileFrame", frame)
			profileFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, top)
			profileFrame:SetPoint("RIGHT")
			
			-- new profile
			textBox = CreateFrame("EditBox", "DGV.InputBox"..DGV_PROFILECUSTOM,  profileFrame, "InputBoxTemplate")
			local newButton = DugisGuideViewer:CreateButton("DGV_NewProfileButton", profileFrame, L["OK"], function() DugisGuideViewer.db:SetProfile(textBox:GetText()) end)
			textBox:SetMultiLine(false)
			textBox:SetSize(200, 15)
			textBox:SetAutoFocus(false)
			textBox:ClearAllPoints( )
			textBox:SetPoint("BOTTOMLEFT", 3, 0)
			newButton:SetPoint("LEFT", textBox, "RIGHT", 3)
			newButton:SetWidth(50)
			newButton:Show()
			textBox:Show()
			
			local dropdown_text = textBox:CreateFontString("DGV_CustomProfileFrameTitle", "ARTWORK", "GameFontHighlight")
			dropdown_text:SetText(L["New Profile"])
			dropdown_text:SetPoint("BOTTOMLEFT", textBox, "TOPLEFT", -5, 7)
			profileFrame:SetHeight(22+dropdown_text:GetHeight())
			
			top = top - 5 - profileFrame:GetHeight()
		end
		
		textBox:SetText(self.db.keys.profile)
	end
	
	--Smart Set Target Configuration Dropdown
	wipe(SettingsDB[DGV_GASMARTSETTARGET].options)
	local targetOptions = SettingsDB[DGV_GASMARTSETTARGET].options
	tinsert(targetOptions, "None")
	tinsert(targetOptions, "Active Talent Specialization")
	tinsert(targetOptions, L["%s (PvP)"]:format("Active Talent Specialization"))
	if GetSpecialization(false, false, 2) then
		tinsert(targetOptions, "Inactive Talent Specialization")
		tinsert(targetOptions, L["%s (PvP)"]:format("Inactive Talent Specialization"))
	end
	for specNum=1,GetNumSpecializations() do
		tinsert(targetOptions, (select(2,GetSpecializationInfo(specNum))))
		tinsert(targetOptions, L["%s (PvP)"]:format(select(2,GetSpecializationInfo(specNum))))
	end
	if SettingsDB[DGV_GASMARTSETTARGET].category==category  and not DGV_GASmartSetTargetDropdown then
		top = top - 24
		local dropdown = self:CreateDropdown("DGV_GASmartSetTargetDropdown", frame, SettingsDB[DGV_GASMARTSETTARGET].text, DGV_GASMARTSETTARGET, self.GASmartSetTargetDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-dropdown:GetHeight()
	end
	if DGV_GASmartSetTargetDropdown then
		UIDropDownMenu_Initialize(DGV_GASmartSetTargetDropdown, DGV_GASmartSetTargetDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_GASmartSetTargetDropdown, DugisGuideViewer:UserSetting(DGV_GASMARTSETTARGET))
	end
	
	--Equip Set button

	if category=="Gear Set" and not DGV_EquipSetButton then
		local button = CreateFrame("Button", "DGV_EquipSetButton", frame, "UIPanelButtonTemplate")
		local btnText = L["Equip Set"]
		local fontwidth = DugisGuideViewer:GetFontWidth(btnText, "GameFontHighlight")
		button:SetText(btnText)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		--button:SetPoint("TOPLEFT", "DGV.ChkBox6", "BOTTOMLEFT", "0", "-3")
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() DugisGuideViewer.Modules.GearAdvisor.AutoEquipSmartSet(nil, true, true) end)
	end
	
	--Stat Cap Level Difference Dropdown
	if SettingsDB[DGV_GASTATCAPLEVELDIFFERENCE].category==category
		and(not DugisGuideViewer:GetDB(DGV_GASTATCAPLEVELDIFFERENCE, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_GASTATCAPLEVELDIFFERENCE, "module")))
		and not DGV_StatCapLevelDifferenceDropdown
	then
		top = top - 24
		local dropdown = self:CreateDropdown("DGV_StatCapLevelDifferenceDropdown", frame, "Stat Cap Level Difference", DGV_GASTATCAPLEVELDIFFERENCE, self.StatCapLevelDifferenceDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-dropdown:GetHeight()
	end
	if DGV_StatCapLevelDifferenceDropdown then
		UIDropDownMenu_Initialize(DGV_StatCapLevelDifferenceDropdown, DGV_StatCapLevelDifferenceDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_StatCapLevelDifferenceDropdown, DugisGuideViewer:UserSetting(DGV_GASTATCAPLEVELDIFFERENCE))
	end
	
	if SettingsDB[DGV_GAWINCRITERIACUSTOM].category==category and not DugisGearScoringLabel then
		top = top - 5
		local fontstring = frame:CreateFontString("DugisGearScoringLabel","ARTWORK", "GameFontNormal")
		fontstring:SetText(SettingsDB[DGV_GAWINCRITERIACUSTOM].text)
		fontstring:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, top)
		fontstring:SetJustifyV("TOP")
		top = top - fontstring:GetStringHeight() - 5
		
		local orderedListContainer = CreateFrame("Frame", "DGV_OrderedListContainer"..DGV_GAWINCRITERIACUSTOM, frame)
		orderedListContainer.optionIndex = DGV_GAWINCRITERIACUSTOM
		orderedListContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 27, top)
		orderedListContainer:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
		local lastListItem
		for i=1,5+GetNumSpecializations()*2 do
			local listItem = CreateFrame("Frame", nil, orderedListContainer, "DugisOrderedListItemTemplate")
			listItem:SetID(i)
			if lastListItem then
				listItem:SetPoint("TOP", lastListItem, "BOTTOM")
			else
				listItem:SetPoint("TOP", orderedListContainer)
			end
			lastListItem = listItem
		end
		local lastShown = DugisGuideViewer:UpdateOrderedListView(DGV_GAWINCRITERIACUSTOM, orderedListContainer:GetChildren())
		top = top - orderedListContainer:GetHeight() - 5
		
		local addString = frame:CreateFontString("DugisGearScoringAddLabel","ARTWORK", "GameFontNormal")
		addString:SetText(L["Add"])
		addString:SetWidth(addString:GetStringWidth())
		addString:SetHeight(40)
		addString:SetPoint("TOPLEFT", orderedListContainer, "BOTTOMLEFT")
		
		local dropdown = self:CreateDropdown(
				"DugisGearScoringDropdown", 
				frame, 
				nil, 
				nil, 
				function(button)
					local options = DugisGuideViewer.chardb[DGV_GAWINCRITERIACUSTOM].options
					if not tContains(options, button.value) then
						local indexOfFalse = DugisGuideViewer.tIndexOfFirst(options, false)
						if indexOfFalse then
							options[indexOfFalse] = button.value
						else
							tinsert(options, button.value)
						end
						DugisGuideViewer:UpdateOrderedListView(DGV_GAWINCRITERIACUSTOM, orderedListContainer:GetChildren())
					end
				end, 
				function() 
					return GetGearScoringCriteria() 
				end)
		dropdown:SetPoint("LEFT", addString, "RIGHT", -10)
	end
		
	--Disable Ant Trail option
	if DugisGuideViewer.carboniteloaded and SettingsDB[DGV_SHOWANTS].category==category then
		local ChkBox = _G["DGV.ChkBox"..DGV_SHOWANTS]

		--ChkBox:SetChecked(0)
		ChkBox:Disable()
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5)
	
	elseif SettingsDB[DGV_CARBONITEARROW].category==category then
		local ChkBox = _G["DGV.ChkBox"..DGV_CARBONITEARROW]

		--ChkBox:SetChecked(0)
		ChkBox:Disable()
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 	
	end
	
	if not DugisGuideViewer.tomtomloaded and SettingsDB[DGV_TOMTOMARROW].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_TOMTOMARROW]		

		--ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end
	
	if DugisGuideViewer.tomtomloaded and SettingsDB[DGV_TOMTOMEMULATION].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_TOMTOMEMULATION]		

		--ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end	
	
	if (DugisGuideViewer.tomtomloaded or DugisGuideViewer.mapsterloaded) and SettingsDB[DGV_DISPLAYMAPCOORDINATES].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_DISPLAYMAPCOORDINATES]		

		ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end

	if (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) and SettingsDB[DGV_MOVEWATCHFRAME].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_MOVEWATCHFRAME]		

		ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end
	
	if (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) and SettingsDB[DGV_WATCHFRAMEBORDER].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_WATCHFRAMEBORDER]		

		ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end		
	
	if SettingsDB[DGV_ANCHOREDSMALLFRAME].category==category then
		local ChkBox = _G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]
		if not (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded)
		then
			Enable(ChkBox)
		else
			Disable(ChkBox)
		end
	end
	
	if not DugisGuideViewer:UserSetting(DGV_AUTOREPAIR) then
		DugisGuideViewer:SetDB(false, DGV_AUTOREPAIRGUILD)
		local Chk = _G["DGV.ChkBox"..DGV_AUTOREPAIRGUILD]
		Disable(Chk)
	else
		local Chk = _G["DGV.ChkBox"..DGV_AUTOREPAIRGUILD]
		Enable(Chk)
	end
	
	--Reset Frames Position Button
	if category=="Frames" and not DGV_ResetFramesButton then
		local button = CreateFrame("Button", "DGV_ResetFramesButton", frame, "UIPanelButtonTemplate")
		local btnText = L["Reset Frames Position"]
		local fontwidth = DugisGuideViewer:GetFontWidth(btnText, "GameFontHighlight")
		button:SetText(btnText)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		--button:SetPoint("TOPLEFT", "DGV.ChkBox6", "BOTTOMLEFT", "0", "-3")
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() DugisGuideViewer:InitFramePositions() end)
	end
	
	--Reset Profile Button
	if category=="Profiles" and not DGV_ResetProfileButton then
		local button = CreateFrame("Button", "DGV_ResetProfileButton", frame, "UIPanelButtonTemplate")
		local btnText = L["Reset Profile"]
		local fontwidth = DugisGuideViewer:GetFontWidth(btnText, "GameFontHighlight")
		button:SetText(btnText)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		--button:SetPoint("TOPLEFT", "DGV.ChkBox6", "BOTTOMLEFT", "0", "-3")
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() 
			DugisGuideViewer.db:ResetProfile()
		end)
	end
	
	--Memory settings Apply button
	if category=="Memory" and not DGV_MemoryApplyButton and DugisGuideViewer:IsModuleRegistered("Guides") then
		local button = CreateFrame("Button", "DGV_MemoryApplyButton", frame, "UIPanelButtonTemplate")
		local btnText = L["Apply Memory Settings"]
		local fontwidth = DugisGuideViewer:GetFontWidth(btnText, "GameFontHighlight")
		button:SetText(btnText)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() DugisGuideViewer:ReloadModules() end)
	end
	
	--[[--Memory settings Garbage Collect
	if category=="Memory" then
		local button = CreateFrame("Button", "DGV_CollectGarbageButton", frame, "UIPanelButtonTemplate")
		local btnText = L["Collect Garbage"]
		local fontwidth = DugisGuideViewer:GetFontWidth(btnText, "GameFontHighlight")
		button:SetText(btnText)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() collectgarbage() end)
	end]]

	top = top - 24
	--Guide Suggest Difficulty Dropdown
	if SettingsDB[DGV_GUIDEDIFFICULTY].category==category
		and(not DugisGuideViewer:GetDB(DGV_GUIDEDIFFICULTY, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_GUIDEDIFFICULTY, "module")))
		and not DGV_GuideSuggestDropdown
	then
		local dropdown = self:CreateDropdown("DGV_GuideSuggestDropdown", frame, "Leveling Mode", DGV_GUIDEDIFFICULTY, self.GuideSuggestDropDown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		--top = top-22-dropdown:GetHeight()
	end
	if DGV_GuideSuggestDropdown then
		UIDropDownMenu_Initialize(DGV_GuideSuggestDropdown, DGV_GuideSuggestDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_GuideSuggestDropdown, DugisGuideViewer:UserSetting(DGV_GUIDEDIFFICULTY))
	end
	
	--Status Frame Effect Dropdown
	if SettingsDB[DGV_SMALLFRAMETRANSITION].category==category 
		and(not DugisGuideViewer:GetDB(DGV_SMALLFRAMETRANSITION, "module") 
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_SMALLFRAMETRANSITION, "module")))
		and not DGV_StatusFrameEffectDropdown
	then
		local dropdown = self:CreateDropdown("DGV_StatusFrameEffectDropdown", frame, "Small Frame Effect", DGV_SMALLFRAMETRANSITION, self.StatusFrameEffectDropDown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
	end
	if DGV_StatusFrameEffectDropdown then
		UIDropDownMenu_Initialize(DGV_StatusFrameEffectDropdown, DGV_StatusFrameEffectDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_StatusFrameEffectDropdown, DugisGuideViewer:UserSetting(DGV_SMALLFRAMETRANSITION))
	end

	--Large Frame Border  Dropdown
	if SettingsDB[DGV_LARGEFRAMEBORDER].category==category  and not DGV_LargeFrameBorderDropdown then
		local dropdown = self:CreateDropdown("DGV_LargeFrameBorderDropdown", frame, "Borders", DGV_LARGEFRAMEBORDER, self.LargeFrameBorderDropdown_OnClick)
		local left = 3
		if DGV_StatusFrameEffectDropdownTitle then left = DGV_StatusFrameEffectDropdownTitle:GetWidth() + 20 end
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
		top = top-22-dropdown:GetHeight()
	end
	if DGV_LargeFrameBorderDropdown then
		UIDropDownMenu_Initialize(DGV_LargeFrameBorderDropdown, DGV_LargeFrameBorderDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_LargeFrameBorderDropdown, DugisGuideViewer:UserSetting(DGV_LARGEFRAMEBORDER))
	end
	
	--Step Complete Sound Dropdown
	if SettingsDB[DGV_STEPCOMPLETESOUND].category==category
		and(not DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND, "module")))
		and not DGV_StepCompleteSoundDropdown
	then
		local dropdown = self:CreateDropdown("DGV_StepCompleteSoundDropdown", frame, "Step Complete Sound", DGV_STEPCOMPLETESOUND, self.StepCompleteSoundDropdown_OnClick)
		local left = 3
		if DGV_GuideSuggestDropdownTitle then left = DGV_GuideSuggestDropdownTitle:GetWidth() + 20 end
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
		top = top-22-dropdown:GetHeight()
	elseif SettingsDB[DGV_STEPCOMPLETESOUND].category==category and DGV_GuideSuggestDropdown then
		top = top-22-DGV_GuideSuggestDropdown:GetHeight()
	end
	if DGV_StepCompleteSoundDropdown then
		UIDropDownMenu_Initialize(DGV_StepCompleteSoundDropdown, DGV_StepCompleteSoundDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_StepCompleteSoundDropdown, DugisGuideViewer:UserSetting(DGV_STEPCOMPLETESOUND))
	end

	--Ant Trail Color Dropdown
	if SettingsDB[DGV_ANTCOLOR].category==category and not DGV_AntColorDropdown then
		local dropdown = self:CreateDropdown("DGV_AntColorDropdown", frame, "Ant Trail Color", DGV_ANTCOLOR, self.AntColorDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
	end
	if DGV_AntColorDropdown then
		UIDropDownMenu_Initialize(DGV_AntColorDropdown, DGV_AntColorDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_AntColorDropdown, DugisGuideViewer:UserSetting(DGV_ANTCOLOR))
	end
	
	--Flightmaster Handling Dropdown
	if SettingsDB[DGV_TAXIFLIGHTMASTERS].category==category and not DGV_TaxiFlightmasterDropdown then
		local dropdown = self:CreateDropdown("DGV_TaxiFlightmasterDropdown", frame, "Use Flightmasters", DGV_TAXIFLIGHTMASTERS, self.TaxiFlightmasterDropdown_OnClick)
		local left = 3
		if DGV_AntColorDropdownTitle then left = DGV_AntColorDropdownTitle:GetWidth() + 20 end
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
		top = top-22-dropdown:GetHeight()
	end
	if DGV_TaxiFlightmasterDropdown then
		UIDropDownMenu_Initialize(DGV_TaxiFlightmasterDropdown, DGV_TaxiFlightmasterDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_TaxiFlightmasterDropdown, DugisGuideViewer:UserSetting(DGV_TAXIFLIGHTMASTERS))
	end	

	--Quest Complete Sound Dropdown
	if SettingsDB[DGV_QUESTCOMPLETESOUND].category==category
		and(not DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND, "module")))
		and not DGV_QuestCompleteSoundDropdown
	then
		local dropdown = self:CreateDropdown("DGV_QuestCompleteSoundDropdown", frame, "Quest Complete Sound", DGV_QUESTCOMPLETESOUND, self.QuestCompleteSoundDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end
	if DGV_QuestCompleteSoundDropdown then
		UIDropDownMenu_Initialize(DGV_QuestCompleteSoundDropdown, DGV_QuestCompleteSoundDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_QuestCompleteSoundDropdown, DugisGuideViewer:UserSetting(DGV_QUESTCOMPLETESOUND))
	end
	
	--Tooltip Anchor
	if SettingsDB[DGV_TOOLTIPANCHOR].category==category  and not DGV_TooltipAnchorDropdown then
		local dropdown = self:CreateDropdown("DGV_TooltipAnchorDropdown", frame, "Tooltip Anchor", DGV_TOOLTIPANCHOR, self.TooltipAnchorDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end
	if DGV_TooltipAnchorDropdown then
		UIDropDownMenu_Initialize(DGV_TooltipAnchorDropdown, DGV_TooltipAnchorDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_TooltipAnchorDropdown, DugisGuideViewer:UserSetting(DGV_TOOLTIPANCHOR))
	end
	
	--Map Preview POIs
	if SettingsDB[DGV_MAPPREVIEWPOIS].category==category and not DGV_MapPreviewPOIsDropdown then
		local dropdown = self:CreateDropdown("DGV_MapPreviewPOIsDropdown", frame, "Preview Quest Objectives", DGV_MAPPREVIEWPOIS, self.MapPreviewPOIsDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)



		top = top-22-dropdown:GetHeight()

	end
	if DGV_MapPreviewPOIsDropdown then
		UIDropDownMenu_Initialize(DGV_MapPreviewPOIsDropdown, DGV_MapPreviewPOIsDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_MapPreviewPOIsDropdown, DugisGuideViewer:UserSetting(DGV_MAPPREVIEWPOIS))
	end


	
	if DugisGuideViewer:IsModuleRegistered("SmallFrame") and SettingsDB[DGV_DISPLAYPRESET].category==category and not DGV_DisplayPresetDropdown then
		local dropdown = self:CreateDropdown("DGV_DisplayPresetDropdown", frame, "Recommended Preset Settings", DGV_DISPLAYPRESET, self.DisplayPresetDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end
	if DugisGuideViewer:IsModuleRegistered("SmallFrame") and DGV_DisplayPresetDropdown then
		UIDropDownMenu_Initialize(DGV_DisplayPresetDropdown, DGV_DisplayPresetDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_DisplayPresetDropdown, DugisGuideViewer:UserSetting(DGV_DISPLAYPRESET))
	end
	
	if DugisGuideViewer:IsModuleRegistered("SmallFrame") and SettingsDB[DGV_SMALLFRAMEDOCKING].category==category and not DGV_SmallFrameDockingDropdown then
		local dropdown = self:CreateDropdown("DGV_SmallFrameDockingDropdown", frame, SettingsDB[DGV_SMALLFRAMEDOCKING].text, DGV_SMALLFRAMEDOCKING, self.SmallFrameDockingDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end
	if DugisGuideViewer:IsModuleRegistered("SmallFrame") and DGV_SmallFrameDockingDropdown then
		UIDropDownMenu_Initialize(DGV_SmallFrameDockingDropdown, DGV_SmallFrameDockingDropdown.initFunc)
		UIDropDownMenu_SetSelectedValue(DGV_SmallFrameDockingDropdown, DugisGuideViewer:UserSetting(DGV_SMALLFRAMEDOCKING))
	end
	
	-- select profile
	if category=="Profiles" then
		local dropdown = DGV_SelectProfileDropdown
		if not dropdown then
			dropdown = self:CreateDropdown(
				"DGV_SelectProfileDropdown", 
				frame, 
				"Existing Profiles", 
				nil, 
				function(button) 
					DugisGuideViewer.db:SetProfile(button.value)
				end, 
				function() return getProfileList() end)
			dropdown:SetPoint("TOPLEFT", 3, top)
			top = top-22-dropdown:GetHeight()
		end
		UIDropDownMenu_SetSelectedValue(DGV_SelectProfileDropdown, DugisGuideViewer.db.keys.profile)
	end

	
	-- copy from profile
	if category=="Profiles" then
		local dropdown = DGV_CopyProfileDropdown
		if not dropdown then
			dropdown = self:CreateDropdown(
				"DGV_CopyProfileDropdown", 
				frame, 
				"Copy From", 
				nil, 
				function(button)
					DugisGuideViewer.db:CopyProfile(button.value)
				end, 
				function() return getProfileList(true, true) end)
			dropdown:SetPoint("TOPLEFT", 3, top)
			top = top-22-dropdown:GetHeight()
		end
	end
	
	-- delete a profile
	if category=="Profiles" then
		local dropdown = DGV_DeleteProfileDropdown
		if not dropdown then
			dropdown = self:CreateDropdown(
				"DGV_DeleteProfileDropdown", 
				frame, 
				"Delete a Profile", 
				nil, 
				function(button)
					DugisGuideViewer.db:DeleteProfile(button.value)
				end, 
				function() return getProfileList(true, true) end)
			dropdown:SetPoint("TOPLEFT", 3, top)
			top = top-22-dropdown:GetHeight()
		end
	end
	
	--Mini Blob Quality Slider
	--[[if SettingsDB[DGV_MINIBLOBQUALITY].category==category then
		local slider = self:CreateSlider("DGV_MiniBlobQualitySlider", frame, "Minimap Blob Quality", 
			DGV_MINIBLOBQUALITY, 0, 1, 8/30, 1, "Low", "High", function() DugisGuideViewer:UpdateMiniBlobs() end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, top)
		if DugisGuideViewer.carboniteloaded or  GetCVarBool( "rotateMinimap" ) then
			_G[slider:GetName() .. 'Text']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'Low']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'High']:SetTextColor(0.5, 0.5, 0.5)
			slider:Disable()
		end
		top = top-30-slider:GetHeight()
	end--]]
	
	--Show Tooltip Slider
	if SettingsDB[DGV_SHOWTOOLTIP].category==category and not DGV_ShowTooltipSlider and DugisGuideViewer:IsModuleLoaded("SmallFrame") then
		local slider = self:CreateSlider("DGV_ShowTooltipSlider", frame, SettingsDB[DGV_SHOWTOOLTIP].text, 
			DGV_SHOWTOOLTIP, 0, 120, 1, 5, "0", "120", function() DugisGuideViewer:ShowAutoTooltip() end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, top)
		top = top-30-slider:GetHeight()
	end
	if DGV_ShowTooltipSlider then
		DGV_ShowTooltipSlider:SetValue(DugisGuideViewer:GetDB(DGV_SHOWTOOLTIP) or 5)
	end
	
	--DGV_SMALLFRAMEFONTSIZE
	if SettingsDB[DGV_SMALLFRAMEFONTSIZE].category==category and not DGV_SmallFrameFontSize then
		local slider = self:CreateSlider("DGV_SmallFrameFontSize", frame, SettingsDB[DGV_SMALLFRAMEFONTSIZE].text, 
			DGV_SMALLFRAMEFONTSIZE, 10, 20, 1, 8, "10", "20")
		slider:HookScript("OnMouseUp", function()
			if DugisGuideViewer:IsModuleLoaded("SmallFrame") then
				DugisGuideViewer:UpdateSmallFrame()
			end
		end)
		top = -57
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 300, top)
		top = top-35-slider:GetHeight()
	end
	if DGV_SmallFrameFontSize and DugisGuideViewer:IsModuleLoaded("SmallFrame") then
		DGV_SmallFrameFontSize:SetValue(DugisGuideViewer:GetDB(DGV_SMALLFRAMEFONTSIZE) or 5)
	end
	
	--DGV_TARGETBUTTONSCALE
	if SettingsDB[DGV_TARGETBUTTONSCALE].category==category and not DGV_TargetButtonScale then
		local slider = self:CreateSlider("DGV_TargetButtonScale", frame, SettingsDB[DGV_TARGETBUTTONSCALE].text, 
			DGV_TARGETBUTTONSCALE, 1, 10, 1, 1, "1", "10")
		slider:HookScript("OnMouseUp", function()
			if DugisGuideViewer:IsModuleLoaded("Target") then
				DugisGuideViewer:FinalizeTarget()
			end
		end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 300, top)
		top = top-35-slider:GetHeight()
	end
	if DGV_TargetButtonScale and DugisGuideViewer:IsModuleLoaded("Target") then
		DGV_TargetButtonScale:SetValue(DugisGuideViewer:GetDB(DGV_TARGETBUTTONSCALE) or 5)
	
	end
	
	--DGV_ITEMBUTTONSCALE
	if SettingsDB[DGV_ITEMBUTTONSCALE].category==category and not DGV_ItemButtonScale then
		local slider = self:CreateSlider("DGV_ItemButtonScale", frame, SettingsDB[DGV_ITEMBUTTONSCALE].text, 
			DGV_ITEMBUTTONSCALE, 1, 10, 1, 1, "1", "10")
		slider:HookScript("OnMouseUp", function()
			if DugisGuideViewer:IsModuleLoaded("Guides") then
				DugisGuideViewer:SetUseItem(DugisGuideUser.CurrentQuestIndex)
			else 
				local questId = DugisGuideViewer.DugisArrow:GetFirstWaypointQuestId()
				DugisGuideViewer:SetUseItemByQID(questId)
			end
		end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 300, top)
		top = top-30-slider:GetHeight()
	end
	if DGV_ItemButtonScale and DugisGuideViewer:IsModuleLoaded("SmallFrame") then
		DGV_ItemButtonScale:SetValue(DugisGuideViewer:GetDB(DGV_ITEMBUTTONSCALE) or 5)
	end	
	
	--Map Preview Slider
	if SettingsDB[DGV_MAPPREVIEWDURATION].category==category and not DGV_MapPreviewSlider then
		local slider = self:CreateSlider("DGV_MapPreviewSlider", frame, SettingsDB[DGV_MAPPREVIEWDURATION].text, 
			DGV_MAPPREVIEWDURATION, 0, 120, 1, 10, "0", "120")
		slider:HookScript("OnMouseUp", function()
			if DugisGuideViewer:IsModuleLoaded("MapPreview") then
				DugisGuideViewer.MapPreview:ConfigChanged()
			end
		end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, top)
		if DugisGuideViewer.carboniteloaded then
			_G[slider:GetName() .. 'Text']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'Low']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'High']:SetTextColor(0.5, 0.5, 0.5)
			slider:Disable()
		end
		top = top-30-slider:GetHeight()
	end
	if DGV_MapPreviewSlider then
		DGV_MapPreviewSlider:SetValue(DugisGuideViewer:GetDB(DGV_MAPPREVIEWDURATION) or 1)
	end
	
	return frame
end

local function IterateReturns(...)
		local i, tbl = 0, {...}
		return function ()
			i = i + 1
			if i <= #(tbl) then return tbl[i] end
		end
	end

function DugisGuideViewer:CreateSettingsTree(parent)
	if DugisGuideViewer.SettingsTree then
		DugisGuideViewer.SettingsTree.frame:ClearAllPoints()
		DugisGuideViewer.SettingsTree.frame:Hide()
		AceGUI:Release(DugisGuideViewer.SettingsTree)
	end
	local treeGroup = AceGUI:Create("TreeGroup")
	treeGroup:SetTree(CATEGORY_TREE)		
	treeGroup:EnableButtonTooltips(false)
	--treeGroup.frame:SetBackdrop(nil);
	treeGroup.frame:SetParent(parent)
	treeGroup.treeframe:SetBackdropColor(0,0,0,0);
	treeGroup.border:SetBackdropColor(0,0,0,0);
	treeGroup.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, 0)
	treeGroup.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 12)
				
	treeGroup:SetCallback("OnGroupSelected", function(group, event, value)
		for child in IterateReturns(treeGroup.border:GetChildren()) do
			child:Hide()
		end
		GetSettingsCategoryFrame(value, treeGroup.border):Show()

	end)
	treeGroup:SelectByValue(CATEGORY_TREE[1].value)
	treeGroup.frame:Show()
	treeGroup.frame:GetScript("OnSizeChanged")(treeGroup.frame)
	DugisGuideViewer.SettingsTree = treeGroup;
end

function DugisGuideViewer:ForceAllSettingsTreeCategories()
	for _,node in ipairs(CATEGORY_TREE) do
		GetSettingsCategoryFrame(node.value, DugisGuideViewer.SettingsTree.border):Hide()
	end
	local tree = DugisGuideViewer.SettingsTree
	local status = tree.status or tree.localstatus
	tree:SelectByValue(status.selected)
end

--Smart Set Target Dropdown
function DugisGuideViewer.GASmartSetTargetDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedValue(DGV_GASmartSetTargetDropdown, button.value )
	DugisGuideViewer:SetDB(button.value, DGV_GASMARTSETTARGET)
end

--StatCapLevelDifferenceDropdown
function DugisGuideViewer.StatCapLevelDifferenceDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedValue(DGV_StatCapLevelDifferenceDropdown, button.value )
	DugisGuideViewer:SetDB(button.value, DGV_GASTATCAPLEVELDIFFERENCE)
	DugisGuideViewer.Modules.GearAdvisor.ResetCalculateScoreCache()
end

--Guide Suggest Dropdown
function DugisGuideViewer.GuideSuggestDropDown_OnClick(button)
	--UIDropDownMenu_SetSelectedID(DGV_GuideSuggestDropdown, button:GetID() )
	UIDropDownMenu_SetSelectedValue(DGV_GuideSuggestDropdown, button.value )
	
	DugisGuideViewer:SetDB(button.value, DGV_GUIDEDIFFICULTY)
	DebugPrint("button.value"..button.value.."button.id"..button:GetID())
	if DugisGuideViewer:IsModuleLoaded("Guides") then DugisGuideViewer:TabTextRefresh() end
end

--Status Frame Effect dropdown
function DugisGuideViewer.StatusFrameEffectDropDown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_StatusFrameEffectDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_SMALLFRAMETRANSITION)
	
	local options = DugisGuideViewer:GetDB(DGV_SMALLFRAMETRANSITION, "options")
	if button.value == options[1].text then
		--UIFrameFadeIn(DugisSmallFrame, 0.8, 0, 1)
		DugisGuideViewer.Modules.SmallFrame:PlayFlashAnimation( )
		DugisGuideViewer.Modules.DugisWatchFrame:PlayFlashAnimation( )
	elseif button.value == options[2].text then
		DugisGuideViewer.Modules.SmallFrame:StartFrameTransition( )
	end
end

function DugisGuideViewer:SetFrameBackdrop(frame, bgFile, edgeFile, left, right, top, bottom, edgeSize)
	if not frame then return end
	if not bgFile and not edgeFile then
		frame:SetBackdrop(nil)
	else
		frame:SetBackdrop( { 
			bgFile = bgFile, 
			edgeFile = edgeFile, tile = true, tileSize = 32, edgeSize = edgeSize or 32, 
			insets = { left = left, right = right, top = top, bottom = bottom }
		})
	end
end

function DugisGuideViewer:GetBorderPath()
	return self.ARTWORK_PATH.."Border-"..DugisGuideViewer:UserSetting(DGV_LARGEFRAMEBORDER)
end

function DugisGuideViewer:SetAllBorders( )
	self:SetSmallFrameBorder( )
	self:SetFrameBackdrop(DugisMainBorder, DugisGuideViewer.chardb.EssentialsMode>0 and self.BACKGRND_PATH, self:GetBorderPath(), 10, 3, 11, 5)
	if DugisGuideViewer:IsModuleLoaded("ModelViewer") then
		self:SetFrameBackdrop(self.Modules.ModelViewer.Frame, self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
	end
	self:SetFrameBackdrop(DugisGuideSuggestFrame,  self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
	self:SetFrameBackdrop(DugisEquipPromptFrame,  self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
	if DugisGuideViewer:IsModuleLoaded("StickyFrame") then
		self:SetFrameBackdrop(self.Modules.StickyFrame.Frame, "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", self:GetBorderPath(), 10, 4, 12, 5)
	end
	self:SetFrameBackdrop(DugisRecordFrame,  self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
end

function DugisGuideViewer:SetSmallFrameBorder( )
	--Use same border as large frame
	if DugisGuideViewer:UserSetting(DGV_SMALLFRAMEBORDER) 
	then
		self:SetFrameBackdrop(DugisSmallFrameContainer, self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
	else
		self:SetFrameBackdrop(DugisSmallFrameContainer, nil)
	end
end

function DugisGuideViewer:DisplayPreset()
	if DugisGuideViewer:GetDB(DGV_DISPLAYPRESET)=="Minimal - No Borders" then 
		DugisGuideViewer:SetDB(false, DGV_ANCHOREDSMALLFRAME)
		_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]:SetChecked(0)
		DugisGuideViewer:SetDB(true, DGV_ENABLEQW)
		_G["DGV.ChkBox"..DGV_ENABLEQW]:SetChecked(1)
		DugisGuideViewer:SetDB(false, DGV_MULTISTEPMODE)
		_G["DGV.ChkBox"..DGV_MULTISTEPMODE]:SetChecked(0)
		DugisGuideViewer:SetDB(false, DGV_OBJECTIVECOUNTER)
		_G["DGV.ChkBox"..DGV_OBJECTIVECOUNTER]:SetChecked(0)
		DugisGuideViewer:SetDB(false, DGV_SMALLFRAMEBORDER)						
		DugisGuideViewer:SetDB(false, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(false, DGV_EMBEDDEDTOOLTIP)
		_G["DGV.ChkBox"..DGV_EMBEDDEDTOOLTIP]:SetChecked(0)
		DugisGuideViewer:SetDB(false, DGV_FIXEDWIDTHSMALL)
		_G["DGV.ChkBox"..DGV_FIXEDWIDTHSMALL]:SetChecked(0)
		DugisGuideViewer:SetDB("Scroll", DGV_SMALLFRAMETRANSITION)
	elseif DugisGuideViewer:GetDB(DGV_DISPLAYPRESET)=="Minimal" then 
		DugisGuideViewer:SetDB(false, DGV_ANCHOREDSMALLFRAME)
		_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]:SetChecked(0)
		DugisGuideViewer:SetDB(true, DGV_ENABLEQW)
		_G["DGV.ChkBox"..DGV_ENABLEQW]:SetChecked(1)
		DugisGuideViewer:SetDB(false, DGV_MULTISTEPMODE)
		_G["DGV.ChkBox"..DGV_MULTISTEPMODE]:SetChecked(0)
		DugisGuideViewer:SetDB(false, DGV_OBJECTIVECOUNTER)
		_G["DGV.ChkBox"..DGV_OBJECTIVECOUNTER]:SetChecked(0)
		DugisGuideViewer:SetDB(true, DGV_SMALLFRAMEBORDER)				
		DugisGuideViewer:SetDB(true, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(false, DGV_EMBEDDEDTOOLTIP)
		_G["DGV.ChkBox"..DGV_EMBEDDEDTOOLTIP]:SetChecked(0)
		DugisGuideViewer:SetDB(false, DGV_FIXEDWIDTHSMALL)
		_G["DGV.ChkBox"..DGV_FIXEDWIDTHSMALL]:SetChecked(0)
		DugisGuideViewer:SetDB("Scroll", DGV_SMALLFRAMETRANSITION)
	elseif DugisGuideViewer:GetDB(DGV_DISPLAYPRESET)=="Standard" then 
		DugisGuideViewer:SetDB(false, DGV_ANCHOREDSMALLFRAME)
		_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]:SetChecked(0)
		DugisGuideViewer:SetDB(true, DGV_ENABLEQW)
		_G["DGV.ChkBox"..DGV_ENABLEQW]:SetChecked(1)
		DugisGuideViewer:SetDB(false, DGV_MULTISTEPMODE)
		_G["DGV.ChkBox"..DGV_MULTISTEPMODE]:SetChecked(0)
		DugisGuideViewer:SetDB(false, DGV_OBJECTIVECOUNTER)
		_G["DGV.ChkBox"..DGV_OBJECTIVECOUNTER]:SetChecked(0)
		DugisGuideViewer:SetDB(true, DGV_SMALLFRAMEBORDER)						
		DugisGuideViewer:SetDB(true, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(true, DGV_EMBEDDEDTOOLTIP)
		_G["DGV.ChkBox"..DGV_EMBEDDEDTOOLTIP]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_FIXEDWIDTHSMALL)
		_G["DGV.ChkBox"..DGV_FIXEDWIDTHSMALL]:SetChecked(1)	
		DugisGuideViewer:SetDB("Flash", DGV_SMALLFRAMETRANSITION)
	elseif DugisGuideViewer:GetDB(DGV_DISPLAYPRESET)=="Standard - Anchored" then 
		DugisGuideViewer:SetDB(true, DGV_ANCHOREDSMALLFRAME)
		_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_ENABLEQW)
		_G["DGV.ChkBox"..DGV_ENABLEQW]:SetChecked(1)
		DugisGuideViewer:SetDB(false, DGV_MULTISTEPMODE)
		_G["DGV.ChkBox"..DGV_MULTISTEPMODE]:SetChecked(0)
		DugisGuideViewer:SetDB(false, DGV_OBJECTIVECOUNTER)
		_G["DGV.ChkBox"..DGV_OBJECTIVECOUNTER]:SetChecked(0)
		DugisGuideViewer:SetDB(true, DGV_SMALLFRAMEBORDER)						
		DugisGuideViewer:SetDB(true, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(true, DGV_EMBEDDEDTOOLTIP)
		_G["DGV.ChkBox"..DGV_EMBEDDEDTOOLTIP]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_FIXEDWIDTHSMALL)
		_G["DGV.ChkBox"..DGV_FIXEDWIDTHSMALL]:SetChecked(1)	
		DugisGuideViewer:SetDB("Flash", DGV_SMALLFRAMETRANSITION)
	elseif DugisGuideViewer:GetDB(DGV_DISPLAYPRESET)=="Multi-step" then 
		DugisGuideViewer:SetDB(false, DGV_ANCHOREDSMALLFRAME)

		_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]:SetChecked(0)
		DugisGuideViewer:SetDB(true, DGV_ENABLEQW)
		_G["DGV.ChkBox"..DGV_ENABLEQW]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_MULTISTEPMODE)
		_G["DGV.ChkBox"..DGV_MULTISTEPMODE]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_OBJECTIVECOUNTER)
		_G["DGV.ChkBox"..DGV_OBJECTIVECOUNTER]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_SMALLFRAMEBORDER)						
		DugisGuideViewer:SetDB(true, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(true, DGV_EMBEDDEDTOOLTIP)
		_G["DGV.ChkBox"..DGV_EMBEDDEDTOOLTIP]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_FIXEDWIDTHSMALL)
		_G["DGV.ChkBox"..DGV_FIXEDWIDTHSMALL]:SetChecked(1)	
		DugisGuideViewer:SetDB("Flash", DGV_SMALLFRAMETRANSITION)
	elseif DugisGuideViewer:GetDB(DGV_DISPLAYPRESET)=="Multi-step - Anchored" then 
		DugisGuideViewer:SetDB(true, DGV_ANCHOREDSMALLFRAME)
		_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_ENABLEQW)
		_G["DGV.ChkBox"..DGV_ENABLEQW]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_MULTISTEPMODE)
		_G["DGV.ChkBox"..DGV_MULTISTEPMODE]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_OBJECTIVECOUNTER)
		_G["DGV.ChkBox"..DGV_OBJECTIVECOUNTER]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_SMALLFRAMEBORDER)						
		DugisGuideViewer:SetDB(true, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(true, DGV_EMBEDDEDTOOLTIP)
		_G["DGV.ChkBox"..DGV_EMBEDDEDTOOLTIP]:SetChecked(1)
		DugisGuideViewer:SetDB(true, DGV_FIXEDWIDTHSMALL)
		_G["DGV.ChkBox"..DGV_FIXEDWIDTHSMALL]:SetChecked(1)	
		DugisGuideViewer:SetDB("Flash", DGV_SMALLFRAMETRANSITION)				
	end
	DugisGuideViewer:RefreshQuestWatch()
	DugisGuideViewer:UpdateSmallFrame()
end

function DugisGuideViewer:QUEST_ACCEPTED(self, event, qid)
	if not DugisGuideViewer:IsModuleLoaded("Guides") or not DugisGuideViewer:GuideOn() then return end
	local logindex = DugisGuideViewer:GetQuestLogIndexByQID(qid)
	if ( AUTO_QUEST_WATCH == "0" and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS and DugisGuideViewer:UserSetting(DGV_ENABLEQW)) then
		if DugisGuideViewer.chardb.EssentialsMode ~= 1 then 
			if DugisGuideViewer:UserSetting(DGV_OBJECTIVECOUNTER) and qid and not DugisGuideUser.removedQuests[qid] then 
				AddQuestWatch(logindex);
				QuestLog_Update();
			end
		elseif DugisGuideViewer.chardb.EssentialsMode == 1 then
			AddQuestWatch(logindex);
			QuestLog_Update();
		end
	end
end

function DugisGuideViewer:QUEST_WATCH_UPDATE(arg1, arg2, arg3, arg4)
	if not DugisGuideViewer:IsModuleLoaded("Guides") or not DugisGuideViewer:GuideOn() then return end
	local qid = DugisGuideViewer:GetQIDByLogIndex(arg2)
	if ( AUTO_QUEST_WATCH == "0" and GetNumQuestLeaderBoards(arg2) > 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS and DugisGuideViewer:UserSetting(DGV_ENABLEQW)) then
		if DugisGuideViewer.chardb.EssentialsMode ~= 1 then 
			if DugisGuideViewer:UserSetting(DGV_OBJECTIVECOUNTER) and qid and not DugisGuideUser.removedQuests[qid] then 
				AddQuestWatch(arg2,MAX_QUEST_WATCH_TIME);
				QuestLog_Update();
			end
		elseif DugisGuideViewer.chardb.EssentialsMode == 1 then
			AddQuestWatch(arg2,MAX_QUEST_WATCH_TIME);
			QuestLog_Update();
		end
	end
end
	

function DugisGuideViewer:RefreshQuestWatch()
	if self:UserSetting(DGV_ENABLEQW) and DugisGuideViewer.chardb.EssentialsMode ~= 1 and DugisGuideViewer:IsModuleLoaded("Guides") and DugisGuideViewer.GuideOn() then
		if AUTO_QUEST_WATCH == "1" then
			SetCVar("autoQuestWatch", 0, InterfaceOptionsObjectivesPanelAutoQuestTracking.event)
			AUTO_QUEST_WATCH = "0"
			InterfaceOptionsObjectivesPanelAutoQuestTracking:SetChecked(0)
			InterfaceOptionsPanel_CheckButton_Update(InterfaceOptionsObjectivesPanelAutoQuestTracking)
		end
		if DugisGuideViewer.chardb.EssentialsMode ~= 1 then 
			DugisGuideViewer:WatchQuest() 
		end
	else
		if DugisGuideViewer.chardb.EssentialsMode ~= 1 and DugisGuideViewer:IsModuleLoaded("Guides") and DugisGuideViewer.GuideOn() then 
			for logindex = 1, GetNumQuestLogEntries() do
				local qid = DugisGuideViewer:GetQIDByLogIndex(logindex)
				if not DugisGuideUser.watchedQuests[qid] then
					RemoveQuestWatch(logindex)
				end
			end
			WatchFrame_Update()
		end
	end
	
	if self:UserSetting(DGV_ENABLEQW) and DugisGuideViewer.chardb.EssentialsMode == 1 and AUTO_QUEST_WATCH == "0" then
		SetCVar("autoQuestWatch", 1, InterfaceOptionsObjectivesPanelAutoQuestTracking.event)
		AUTO_QUEST_WATCH = "1"
		InterfaceOptionsObjectivesPanelAutoQuestTracking:SetChecked(1)
		InterfaceOptionsPanel_CheckButton_Update(InterfaceOptionsObjectivesPanelAutoQuestTracking)
	end
end 

--Large Frame Border Dropdown
function DugisGuideViewer.LargeFrameBorderDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_LargeFrameBorderDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_LARGEFRAMEBORDER)
	DugisGuideViewer:SetAllBorders( )
	WatchFrame_Update()
	NPCJournalFrame:UpdateBorders()
end

--Step Complete Sound Dropdown
function DugisGuideViewer.StepCompleteSoundDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_StepCompleteSoundDropdown, button:GetID() )
	DebugPrint("Debug StepCompleteSoundDropdown_OnClick: button.text="..button.value)
	DugisGuideViewer:SetDB(button.value, DGV_STEPCOMPLETESOUND)
	--DugisGuideViewer:SetDB(button.value, DGV_STEPCOMPLETESOUND, "value")
	DebugPrint("Debug StepCompleteSoundDropdown_OnClick: DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND)="..DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND))
	PlaySoundFile(DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND))
end

--Ant Trail Color Dropdown
function DugisGuideViewer.AntColorDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_AntColorDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_ANTCOLOR)
	DugisGuideViewer.Ants:UpdateAntTrailDot(10)
end

--Flightmaster Handling Dropdown
function DugisGuideViewer.TaxiFlightmasterDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_TaxiFlightmasterDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_TAXIFLIGHTMASTERS)
	if DugisGuideViewer.Modules.Taxi and DugisGuideViewer.Modules.Taxi.ResetMovementCache then
		DugisGuideViewer.Modules.Taxi:ResetMovementCache()
	end
end

--Quest Complete Sound Dropdown
function DugisGuideViewer.QuestCompleteSoundDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_QuestCompleteSoundDropdown, button:GetID() )
	DebugPrint("Debug QuestCompleteSoundDropdown_OnClick: button.text="..button.value)
	DugisGuideViewer:SetDB(button.value, DGV_QUESTCOMPLETESOUND)
	--DugisGuideViewer:SetDB(button.value, DGV_STEPCOMPLETESOUND, "value")
	DebugPrint("Debug QuestCompleteSoundDropdown_OnClick: DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND)="..DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND))
	PlaySoundFile(DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND))
end

function DugisGuideViewer.TooltipAnchorDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_TooltipAnchorDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_TOOLTIPANCHOR)
	DugisGuideViewer:UpdateCompletionVisuals()
end

function DugisGuideViewer.MapPreviewPOIsDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_MapPreviewPOIsDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_MAPPREVIEWPOIS)
	DugisGuideViewer.MapPreview:ConfigChanged()
end

function DugisGuideViewer.DisplayPresetDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_DisplayPresetDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_DISPLAYPRESET)
	DugisGuideViewer:DisplayPreset()
end

function DugisGuideViewer.SmallFrameDockingDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_SmallFrameDockingDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_SMALLFRAMEDOCKING)
	DugisGuideViewer.Modules.SmallFrame:SetDockingMode()
end

-- 
-- Database
--
function DugisGuideViewer:GetDB(key, field)
	if not DugisGuideViewer.chardb[key] then
		DebugPrint("key:"..key.." does not exist in database")
		return
	end
	
	if field then
		local func = loadstring("return DugisGuideViewer.chardb["..tostring(key).."]."..field)
		return func()
	else
		return DugisGuideViewer.chardb[key].checked
	end
end

function DugisGuideViewer:SetDB(value, key, field)
	if not DugisGuideViewer.chardb[key] then
		DebugPrint("key:"..key.." does not exist in database")
		return
	end
	
	if field then 
		local func = loadstring("DugisGuideViewer.chardb["..tostring(key).."]."..field.."="..tostring(value))
		--DebugPrint("func="..func)
		func()
	else
		--DebugPrint("DugisGuideViewer.chardb["..key.."].checked ="..value)
		DugisGuideViewer.chardb[key].checked = value
	end
end

function DugisGuideViewer:UserSetting(name)

	local settings = self.chardb
	
	if not settings[name] then 
		DebugPrint("Error: UserSetting"..name.." not found")
	end

	return self:GetDB(name)--settings[name].checked
end

function DugisGuideViewer:SettingFrameChkOnClick(box, skip)
	local i, boxindex
	--local DGVsettings = self.chardb
	
	if box then
		_, _, boxindex = box:GetName():find("DGV.ChkBox([%d]*)")
		boxindex = tonumber(boxindex)
	end
	
	--Save to DB
	for i = 1, self.chardb.sz do
		if _G["DGV.ChkBox"..i] then
		if _G["DGV.ChkBox"..i]:GetChecked() then self.chardb[i].checked = true else self.chardb[i].checked = false end
		end
	end
	if _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM] then
		if _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]:GetChecked() then 
			self.chardb[DGV_TARGETBUTTONCUSTOM].checked = true 
		else 
			self.chardb[DGV_TARGETBUTTONCUSTOM].checked = false 
		end
	end
	
	if not DugisGuideViewer:UserSetting(DGV_ENABLEQUESTLEVELDB) then
		DugisGuideViewer:SetDB(false, DGV_QUESTLEVELON)
		local Chk = _G["DGV.ChkBox"..DGV_QUESTLEVELON]
		Disable(Chk)
	else
		local Chk = _G["DGV.ChkBox"..DGV_QUESTLEVELON]
		Enable(Chk)
	end
	
	if not DugisGuideViewer:UserSetting(DGV_AUTOREPAIR) then
		DugisGuideViewer:SetDB(false, DGV_AUTOREPAIRGUILD)
		local Chk = _G["DGV.ChkBox"..DGV_AUTOREPAIRGUILD]
		Disable(Chk)
	else
		local Chk = _G["DGV.ChkBox"..DGV_AUTOREPAIRGUILD]
		Enable(Chk)
	end
	
	--Quest Level On
	if boxindex == DGV_QUESTLEVELON then
		if DugisGuideViewer:UserSetting(DGV_QUESTLEVELON) and DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		elseif DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		end
	end
	
	--Color Code On
	if boxindex == DGV_QUESTCOLORON then
		if DugisGuideViewer:UserSetting(DGV_QUESTCOLORON) and DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		elseif DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		end
	end
		
	--Large Frame Lock
	if DugisGuideViewer:UserSetting(DGV_LOCKLARGEFRAME) then 
		DugisMainBorder:EnableMouse(false)
		DugisMainBorder:SetMovable(false)
	else
		DugisMainBorder:EnableMouse(true)
		DugisMainBorder:SetMovable(true)
	end
	
	--Model Viewer Frame Lock
	if DugisGuideViewer:UserSetting(DGV_LOCKMODELFRAME) and DugisGuideViewer:IsModuleLoaded("ModelViewer") then 
		DugisGuideViewer.Modules.ModelViewer.Frame:SetMovable(false)
		DugisGuideViewer.Modules.ModelViewer.Frame:EnableMouse(false)
	elseif DugisGuideViewer:IsModuleLoaded("ModelViewer") then
		DugisGuideViewer.Modules.ModelViewer.Frame:SetMovable(true)
		DugisGuideViewer.Modules.ModelViewer.Frame:EnableMouse(true)
	end	
		
	if DugisGuideViewer:UserSetting(DGV_ITEMBUTTONON) then
		self:SetUseItem(DugisGuideUser.CurrentQuestIndex)
	else
		DugisGuideViewerActionItemFrame:Hide()		
		DugisGuideViewerQuestItemFrame:Hide()
	end
	
	if boxindex == DGV_ENABLEMODELDB then
		DugisGuideViewer:UpdateSmallFrame()
	end
	
	if not self:UserSetting(DGV_ENABLENPCNAMEDB) then
		DugisGuideViewer:SetDB(false, DGV_TARGETBUTTON)
		--self.Target:Disable()
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTON]
		Disable(ChkBox)
	else
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTON]
		Enable(ChkBox)
	end

	
	if DugisGuideViewer:UserSetting(DGV_TARGETBUTTON) then
		DugisGuideViewer:SetTarget(DugisGuideUser.CurrentQuestIndex)
		
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTONSHOW]
		local ChkBox2 = _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]
		Enable(ChkBox)
		Enable(ChkBox2)
	else
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTONSHOW]
		local ChkBox2 = _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]
		Disable(ChkBox)
		Disable(ChkBox2)
	end

	if DugisGuideViewer:IsModuleLoaded("Target") then
-- 		if DugisGuideViewer:UserSetting(DGV_TARGETBUTTONSHOW) then
-- 			DugisGuideViewer.Modules.Target.Frame:Show()
-- 		else
-- 			DugisGuideViewer.Modules.Target.Frame:Hide()
-- 		end
		DugisGuideViewer:FinalizeTarget()
	end
	
	if self:UserSetting(DGV_TARGETBUTTONCUSTOM) then
		local inputBox = _G["DGV.InputBox"..DGV_TARGETBUTTONCUSTOM]
		Enable(inputBox)
	else
		local inputBox = _G["DGV.InputBox"..DGV_TARGETBUTTONCUSTOM]
		Disable(inputBox)
	end
	
	if self:UserSetting(DGV_SHOWONOFF) then
		DugisOnOffButton:Show()
	else
		DugisOnOffButton:Hide()
	end

	if self:UserSetting(DGV_ENABLEQW) ~= DugisGuideUser.EnableQWStatus then
		DugisGuideViewer:RefreshQuestWatch()
		DugisGuideUser.EnableQWStatus = self:UserSetting(DGV_ENABLEQW)
	elseif DugisGuideViewer:IsModuleLoaded("Guides") and DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then 
		DugisGuideViewer:WatchQuest() 
	end
	
	--[[
	if self:UserSetting(DGV_FIXEDWIDEFRAME) then
		SetCVar( "watchFrameWidth", 1, InterfaceOptionsObjectivesPanelWatchFrameWidth.event);
		InterfaceOptionsObjectivesPanelWatchFrameWidth:SetChecked(1)
		InterfaceOptionsPanel_CheckButton_Update(InterfaceOptionsObjectivesPanelWatchFrameWidth)	
		WatchFrame_SetWidth(GetCVar("watchFrameWidth"))
	else
		SetCVar( "watchFrameWidth", 0, InterfaceOptionsObjectivesPanelWatchFrameWidth.event);
		InterfaceOptionsObjectivesPanelWatchFrameWidth:SetChecked(0)
		InterfaceOptionsPanel_CheckButton_Update(InterfaceOptionsObjectivesPanelWatchFrameWidth)	
		WatchFrame_SetWidth(GetCVar("watchFrameWidth"))
	end
	]]--
    
    if NPCJournalFrame and NPCJournalFrame.Enable then
        if self:UserSetting(DGV_JOURNALFRAME) then
            NPCJournalFrame:Enable()
        else
            NPCJournalFrame:Disable()
        end
    end
    
	if DugisGuideViewer:IsModuleLoaded("DugisArrow") then
		if self:UserSetting(DGV_DUGIARROW) and self.Modules.DugisArrow:getNumWaypoints()>0 then
			self.DugisArrow:Show()
			Enable(_G["DGV.ChkBox"..DGV_SHOWCORPSEARROW])
			Enable(_G["DGV.ChkBox"..DGV_CLASSICARROW])
		else
			Disable(_G["DGV.ChkBox"..DGV_SHOWCORPSEARROW])
			Disable(_G["DGV.ChkBox"..DGV_CLASSICARROW])
			self.DugisArrow:Hide()

		end
		DugisGuideViewer.DugisArrow:setArrowTexture( )
	end
	
	if self:UserSetting(DGV_DISABLEWATCHFRAMEMOD) then	
		if DugisGuideViewer:IsModuleLoaded("DugisWatchFrame") and not DugisGuideUser.DisableWF then
			DugisGuideViewer.Modules.DugisWatchFrame:Reset()
		end
		
		DugisGuideViewer:SetDB(false, DGV_MOVEWATCHFRAME)
		if _G["DGV.ChkBox"..DGV_MOVEWATCHFRAME] then
			_G["DGV.ChkBox"..DGV_MOVEWATCHFRAME]:SetChecked(0)
		end
		DugisGuideUser.DisableWF = true
	else
		DugisGuideUser.DisableWF = false
	end	

	if not self:UserSetting(DGV_WATCHFRAMEBORDER) and DugisGuideViewer:IsModuleLoaded("DugisWatchFrame") and self:UserSetting(DGV_DISABLEWATCHFRAMEMOD) then
		DugisGuideViewer.Modules.DugisWatchFrame:Reset()		
	end		
	
	if boxindex == DGV_TOMTOMARROW or boxindex == DGV_CARBONITEARROW then
		DebugPrint("Switch arrow type")
		self:RemoveAllWaypoints()
		if DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then
			self:MapCurrentObjective()
		end
	end

	DugisGuideViewer:UpdateStickyFrame( )
	if DugisGuideViewer:IsModuleLoaded("SmallFrame")  then
		DugisGuideViewer:SetSmallFrameBorder( )
		DugisGuideViewer.Modules.SmallFrame:ResetFloating()
		DugisGuideViewer:ShowAutoTooltip()
		DugisGuideViewer:UpdateSmallFrame()
	end


	DugisGuideViewer.Modules.WorldMapTracking:UpdateTrackingMap()
	if DugisGuideViewer.SafeMapUpdate then
		DugisGuideViewer:SafeMapUpdate()
	else
		RefreshWorldMap()
	end
end

function DugisGuideViewer:SettingsTooltip_OnEnter(chk, event)
	local _, _, boxindex = chk:GetName():find("DGV.ChkBox([%d]*)")
	boxindex = tonumber(boxindex)
	
	local DGVsettings = self.chardb
		
	if DGVsettings[boxindex].tooltip ~= "\"\"" then
		GameTooltip:SetOwner( chk, "ANCHOR_BOTTOMLEFT")
		GameTooltip:AddLine(L[DGVsettings[boxindex].tooltip], 1, 1, 1, 1, true)
		GameTooltip:Show()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOMLEFT", chk, "TOPLEFT", 25, 0)
	end
end

function DugisGuideViewer:SettingsTooltip_OnLeave(self, event)
	GameTooltip:Hide()
end

function DugisGuideViewer:RegisterData(uniqueDataName, getDataFunction)
    if not self.datas then
        self.datas = {}
    end

    self.datas[uniqueDataName] = getDataFunction
end   

function DugisGuideViewer:GetData(uniqueDataName)
    if self.datas and self.datas[uniqueDataName] then
        return self.datas[uniqueDataName]()
    end
    return ""
end     
     

local function ToggleConfig()
	if DugisMainBorder:IsVisible() == 1 then
		DugisGuideViewer:HideLargeWindow()
	else
		--UIFrameFadeIn(DugisMainframe, 0.5, 0, 1)
		--UIFrameFadeIn(Dugis, 0.5, 0, 1)
		DugisGuideViewer:ShowLargeWindow()
	end
    
    if NPCJournalFrame and NPCJournalFrame.Update then
        NPCJournalFrame:Update()
    end
end

SLASH_DG1 = "/dugi"
SlashCmdList["DG"] = function(msg)	
	if msg == "" then 				-- "/dg" command
		print("|cff11ff11/dugi way xx xx - |rPlace waypoint in current zone.")
		print("|cff11ff11/dugi fix - |rReset all Saved Variable setting.")
		print("|cff11ff11/dugi reset - |rReset all frame position.")
		print("|cff11ff11/dugi on - |rEnable Dugi Addon.")
		print("|cff11ff11/dugi off - |rDisable Dugi Addon.")
		print("|cff11ff11/dugi config - |rDisplay settings menu.")
	elseif msg  == "on" then
		DugisGuideViewer:TurnOn()
		DugisGuideViewer:UpdateIconStatus()
	elseif msg  == "off" then
		DugisGuideViewer:TurnOff()
		DugisGuideViewer:UpdateIconStatus()
	elseif msg  == "config" then
		ToggleConfig()
	elseif msg  == "reset" then 	--"/dg reset" command
		print("|cff11ff11" .. "Dugis Frame Reset" )
		DugisGuideViewer:InitFramePositions()
	elseif msg == "fix" then
		print("|cff11ff11" .. "Dugis Clear Variables" )
		ResetDB()
		--DugisGuideViewer:ReloadModules()
	elseif msg == "dgr" then
		DugisGuideViewer:ShowRecord()
	elseif msg == "dgr limit" then
		DugisGuideViewer:ToggleRecordLimit()
	elseif string.find(msg, "dgr ")==1 then
		DugisGuideViewer:RecordNote(string.sub(msg, 5))	
	elseif string.find(msg, "way ")==1 then
		 local x,y,zone = string.sub(msg, 5):match("%s*([%d.]+)[,%s]+([%d.]+)%s*(.*)")
		 if x and y then
			DugisGuideViewer:AddManualWaypoint(tonumber(x)/100, tonumber(y)/100, zone)
		end
	elseif msg == "way" then		
		local zone, mapFloor, x, y = DugisGuideViewer:GetPlayerPosition()
		DugisGuideViewer:AddManualWaypoint(x, y, zone, mapFloor)
	end
end

function DugisGuideViewer:RemoveParen(text)
	if text then
		local _, _, noparen = text:find("([^%(]*)")
		noparen = noparen:trim()
		
		return noparen
	end
end

function DugisGuideViewer:OnOff_OnClick(self, event)
	if event == "LeftButton" then
		DugisGuideViewer:ToggleOnOff()
	elseif event == "RightButton" then
		ToggleConfig()
	end
end

function DugisGuideViewer:ToggleOnOff()
	if InCombatLockdown() then return end
	if DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode == 0 then
		DugisGuideViewer:TurnOnEssentials()
		DugisGuideViewer:RefreshQuestWatch()
	elseif DugisGuideViewer:GuideOn() then
		DugisGuideViewer:TurnOff()
	else
		DugisGuideViewer.chardb.EssentialsMode = 0
		DugisGuideViewer:TurnOn()
		--DugisGuideViewer:SettingFrameChkOnClick()
	end
	DugisGuideViewer:UpdateIconStatus()
end

function DugisGuideViewer:TurnOnEssentials()
	DugisGuideViewer:RemoveAllWaypoints()
	DugisGuideViewer.chardb.GuideOn = true
	DugisGuideViewer.chardb.EssentialsMode = 1
	DugisGuideViewer:ReloadModules()
	--DugisGuideViewer:SettingFrameChkOnClick()
	DugisGuideViewer:UpdateIconStatus()
	WatchFrame_Update()
end

function DugisGuideViewer:TurnOff()
	if not DugisGuideViewer:GuideOn() then return end
	print("|cff11ff11" .. "Dugi Guides Off" )
	DugisGuideViewer.chardb.GuideOn = false
	DugisGuideViewer.eventFrame:UnregisterAllEvents()
	DugisGuideViewer:HideLargeWindow()
	-- if DugisGuideViewer.ModelViewer.Frame then  --not created when memory setting is restricted
	--	DugisGuideViewer.ModelViewer.Frame:Hide()
	-- end
	--DugisSmallFrameLogo:Hide()
	--DugisGuideViewer.Canvas:Hide()
	--DugisGuideViewer.DugisArrow:Disable()
	DugisGuideViewer.AutoQuestAccept:Disable( )
	--DugisGuideViewer.Target:Disable( )
	--DugisGuideViewer.StickyFrame:Disable()
	--DugisGuideViewer.SmallFrame:Disable()
	DugisGuideViewer:ReloadModules()
end

function DugisGuideViewer:TurnOn()
	if DugisGuideViewer:GuideOn() then return end
	if WorldMapFrame:IsShown() then HideUIPanel(WorldMapFrame) end
	print("|cff11ff11" .. "Dugi Guides On" )
	if not DugisGuideViewer:IsModuleRegistered("Guides") then
		DugisGuideViewer.chardb.EssentialsMode = 1
	end
	DugisGuideViewer.chardb.GuideOn = true
	DugisGuideViewer:OnInitialize()	
	--DugisGuideViewer.ModelViewer:ShowCurrentModel()
	--DugisSmallFrameLogo:Show()
	--DugisGuideViewer.Canvas:Show()
	--DugisGuideViewer.DugisArrow:Enable()
	DugisGuideViewer.AutoQuestAccept:Enable( )
	--DugisGuideViewer.Target:Enable( )
	--DugisGuideViewer.StickyFrame:Enable()
	--DugisGuideViewer.SmallFrame:Enable()
	DugisGuideViewer:SetEssentialsOnCancelReload()
	DugisGuideViewer.chardb.GuideOn = DugisGuideViewer:ReloadModules()
	if DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then DugisGuideViewer:MoveToNextQuest() end
	--DugisGuideViewer:ShowLargeWindow()
	DugisGuideViewer:RefreshQuestWatch()
end

if not DugisGuideViewerDelayFrame then
	DugisGuideViewerDelayFrame = CreateFrame("Frame")
	DugisGuideViewerDelayFrame:Hide()
end

function DelayandMoveToNextQuest(delay, reload, func)
	if DugisGuideViewerDelayFrame:IsShown() then return end
	DugisGuideViewerDelayFrame.func = func
	DugisGuideViewerDelayFrame.delay = delay
	DugisGuideViewerDelayFrame.reload = reload
	DugisGuideViewerDelayFrame:Show()
end

DugisGuideViewerDelayFrame:SetScript("OnUpdate", function(self, elapsed)
	self.delay = self.delay - elapsed
	if self.delay <= 0 then
		self:Hide()
		if DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode ~= 1 then
			DugisGuideViewer:MoveToNextQuest(DugisGuideViewer:FindNextUnchecked())
		end
		if self.reload then -- reload again to populate special tags			
			DugisGuideViewer:DisplayViewTab(DugisGuideViewer.CurrentTitle, true)
		end
	end
end)

local orig = AbandonQuest
function AbandonQuest(...)
	local i = GetQuestLogSelection()
	AbandonQID = select(9, GetQuestLogTitle(i))
	DebugPrint("Clicked abandon on"..AbandonQID)
	return orig(...)
end

--Occurs BEFORE QuestFrameCompleteQuestButton OnClick (works with questguru, doesn't work with carbonite)
function Dugis_RewardComplete_Click()
	DebugPrint("QuestRewardCompleteButton_OnClick")
	if IsAddOnLoaded("QuestGuru") and DugisGuideViewer:isValidGuide(CurrentTitle) == true then
		DugisGuideViewer:CompleteQuest()
	end
end
hooksecurefunc("QuestRewardCompleteButton_OnClick", Dugis_RewardComplete_Click);

--Occurs AFTER QuestFrameCompleteQuestButton OnClick (doesn't work with questguru, works with carbonite)
QuestFrameCompleteQuestButton:HookScript("OnClick", function(...)
	DebugPrint("QuestFrameCompleteQuestButton")
	if (IsAddOnLoaded("QuestGuru") == nil) and DugisGuideViewer:isValidGuide(CurrentTitle) == true then
		DugisGuideViewer:CompleteQuest()
	end
end)

function DugisGuideViewer:OnDragStart(frame)
  if not self:UserSetting(DGV_LOCKSMALLFRAME) then
    frame:StartMoving();
    frame.isMoving = true;
  end
end

function DugisGuideViewer:OnDragStop(self)
  self:StopMovingOrSizing();
  self.isMoving = false;
end

function DugisGuideViewer:WayPoint_OnClick(frame)
	local rowNum = frame:GetParent().guideIndex
	if not rowNum then
		_, _, rowNum = frame:GetName():find("DGVRow([^ ]*)WayPoint")
		rowNum = tonumber(rowNum)
	end
	DugisGuideViewer:MapCurrentObjective(rowNum, true)
	DugisGuideViewer:ShowAutoTooltip()
	DugisGuideViewer:SafeSetMapQuestId(DugisGuideViewer.qid[rowNum]);
	if not DugisGuideViewer:IsPlayerAtBlizzardDestination() then DugisGuideViewer.MapPreview:FadeInMap() end
end

function DugisGuideViewer:Button_OnEnter(frame)
	local rowNum = frame:GetParent().guideIndex
	if not rowNum then
		_, _, rowNum = frame:GetName():find("DGVRow([^ ]*)Button")
		rowNum = tonumber(rowNum)
	end
	if not rowNum then return end
	id = self.visualRows[rowNum].Button.tag_id
	tagType = self.visualRows[rowNum].Button.tagType
	GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
	if tagType == "item" then
	  	GameTooltip:SetItemByID(id)
	elseif tagType == "spell" then
		GameTooltip:SetSpellByID(id)
	elseif tagType == "aid" then
		GameTooltip:SetAchievementByID(id)
	elseif tagType == "qid" then
		GameTooltip:SetHyperlink(("quest:%s"):format(tostring(id)))	
	end
end

function DugisGuideViewer:HideLargeWindow()	
	DugisMainBorder:Hide()
	--Dugis:Hide()
	PlaySound("igCharacterInfoClose")
end

function DugisGuideViewer_Close_ButtonClick()
	DugisGuideViewer:HideLargeWindow()
	--DugisSmallFrameLogo:Hide()
end

--[[
function DugisGuideViewer:MinimizeDungeonMap()
	DGV_DungeonFrame:Hide()
	DugisSmallFrameMaximize:Show()
end
--]]
-- 
-- Events
--



function DugisGuideViewer:PLAYER_LOGIN()
	local guid = UnitGUID("player")
	if DugisGuideUser.CharacterGUID == "PRIOR_RESET" then DugisGuideUser.CharacterGUID = guid end
	if DugisGuideUser.CharacterGUID and DugisGuideUser.CharacterGUID~=guid then
		print("|cff11ff11Dugi Guides: |rNew character detected. Wiping settings.")
		ResetDB()
		self.chardb.EssentialsMode = 1
		self:ReloadModules()
		self:SettingFrameChkOnClick()
	end
	
	--QueryQuestsCompleted()
	DugisGuideViewer:InitializeMapOverlays()
	DugisGuideViewer:InitializeQuestPOI()
end

function DugisGuideViewer:PLAYER_LOGOUT( )
end

function DugisGuideViewer:ZONE_CHANGED()
	self:Zone_OnEvent()
end

function DugisGuideViewer:ZONE_CHANGED_NEW_AREA()
	self:Zone_OnEvent()
	
		
	DugisGuideViewer.OnMapChangeUpdateArrow()
	--DugisGuideViewer.DugisArrow:Show()
	
end

function DugisGuideViewer:ZONE_CHANGED_INDOORS()
	self:Zone_OnEvent()
end

function DugisGuideViewer:QUEST_DETAIL()
	DugisGuideViewer:OnQuestDetail()
end

function DugisGuideViewer:QUEST_AUTOCOMPLETE(...)
	DugisGuideViewer:OnAutoComplete(...)
	DugisGuideViewer:UpdateCompletionVisuals()
end

function DugisGuideViewer:QUEST_COMPLETE()
	DugisGuideViewer:OnQuestComplete()
	DugisGuideViewer:UpdateCompletionVisuals()
end

local function OnQuestObjectivesComplete()
	DugisGuideViewer:PlayCompletionSound(DGV_QUESTCOMPLETESOUND)
	DugisGuideViewer:UpdateCompletionVisuals()
end

local completedLogQuests,lastCompletedLogQuests = nil, {}
function DugisGuideViewer:QUEST_LOG_UPDATE()
	DugisGuideViewer:UpdateRecord()
	--PATCH: If I call OnLoad from PLAYER_LOGIN, 
	--GetNumQuestLogEntries == 0 when it is not.
	--Value seems to be stable after initial QLU event
	if FirstTime then  
		FirstTime = nil
		DugisGuideViewer:OnLoad()
	else
		DugisGuideViewer:UpdateMainFrame()
		local i
		lastCompletedLogQuests, completedLogQuests = completedLogQuests, lastCompletedLogQuests
		wipe(completedLogQuests)
		for i=1,GetNumQuestLogEntries() do
			local link = GetQuestLink(i)
			local qid = link and tonumber(link:match("|Hquest:(%d+):"))
			if qid then
				local title, _, _, _, _, _, questFinished = GetQuestLogTitle(i)
				local n = GetNumQuestLeaderBoards(i)
				if n>1 then
					for j=1,n do
						local text, objtype, finished = GetQuestLogLeaderBoard(j, i)
						if not finished then
							questFinished = false
						end
					end
				end
				--DugisGuideViewer:DebugFormat("QUEST_LOG_UPDATE", "qid", qid, "title", title, "questFinished", questFinished, "lastCompletedLogQuests", lastCompletedLogQuests)

				if lastCompletedLogQuests and questFinished and not tContains(lastCompletedLogQuests, qid) then
					OnQuestObjectivesComplete()

					tinsert(completedLogQuests, qid)
				elseif questFinished then
					tinsert(completedLogQuests, qid)
				end
			end
		end
		if not lastCompletedLogQuests then lastCompletedLogQuests = {} end
	end

	if DugisGuideViewer:GuideOn() then
		DugisGuideViewer.DugisArrow:OnQuestLogChanged()
		
		if DugisGuideViewer:GetDB(DGV_WAYPOINTSON) and DugisGuideViewer.chardb.EssentialsMode == 1 then 
			DugisGuideViewer.Modules.QuestPOI:ObjectivesChangedDelay(3)
		end
	end
end

function DugisGuideViewer:TRADE_SKILL_UPDATE()
	DugisGuideViewer:UpdateProfessions()
end

function DugisGuideViewer:ACHIEVEMENT_EARNED()
	DugisGuideViewer:UpdateAchieveFrame()
end

function DugisGuideViewer:ADDON_LOADED(event, addon)
	if addon == "DugisGuideViewerZ" then
		self:UnregisterEvent("ADDON_LOADED")
		DugisGuideViewer:OnInitialize()
		if DugisGuideViewer:GetDB(DGV_MAPPREVIEWDURATION) > 0 then
			SetCVar("miniWorldMap", 1)
		end
	end
end

function DugisGuideViewer:UpdateIconStatus()
	local icon = DugisGuideViewer.ARTWORK_PATH.."iconbutton"
	if DugisGuideViewer:GuideOn() and DugisGuideViewer.chardb.EssentialsMode == 1 then
		icon = DugisGuideViewer.ARTWORK_PATH.."iconbutton_s"
	elseif not DugisGuideViewer:GuideOn() then
		icon = DugisGuideViewer.ARTWORK_PATH.."iconbutton_c"
	end
	DugisOnOffButton:SetNormalTexture(icon)
	if DugisGuideViewer.LDB then
		DugisGuideViewer.LDB:SetIconStatus(icon)
	end
end

function DugisGuideViewer:GetQuestLogIndexByQID(qid)
	local i
	for i=1,50 do
		local qid2 = select(9, GetQuestLogTitle(i))
		if qid2 == qid then return i end
	end
end

function DugisGuideViewer:GetCarboniteQuestLogIndexByQID(qid)
	if not Nx.Quest.CurQ then return end
	local i
	for i=1,40 do
		if Nx.Quest.CurQ[i] then
			local curq = Nx.Quest.CurQ[i];
			local qid2 = curq.QId;
			if qid2 == qid then return i end
		end
	end
end

function DugisGuideViewer:GetItemIdFromLink(link)
	--|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0|h[Broken Fang]|h|r
	return tonumber(link:match(".+|Hitem:([^:]+):.+"))
end

function DugisGuideViewer:InitFramePositions()
	if DugisGuideViewer:IsModuleLoaded("StickyFrame") then
		self.Modules.StickyFrame.Frame:ClearAllPoints()
		self.Modules.StickyFrame.Frame:SetPoint("CENTER", 225, 180)
	end

	sidebarButtonFrame.ResetSidebarIconPosition()
	
	DugisMainBorder:ClearAllPoints()
	DugisMainBorder:SetPoint("CENTER", 0, 0)
	
	if DugisGuideViewer:IsModuleLoaded("DugisWatchFrame") then
		DugisGuideViewer.Modules.DugisWatchFrame:Reset()
	end

	DugisGuideViewerActionItemFrame:ClearAllPoints()
	DugisGuideViewerQuestItemFrame:ClearAllPoints()
	DugisOnOffButton:ClearAllPoints()
	if DugisGuideViewer:IsModuleLoaded("SmallFrame") and DugisGuideViewer:UserSetting(DGV_ANCHOREDSMALLFRAME) then
		DugisGuideViewer.Modules.SmallFrame:Reset()
		DugisGuideViewerActionItemFrame:SetPoint("BOTTOMLEFT", "DugisSmallFrameContainer", "TOPLEFT", 13, 35)
		DugisGuideViewerQuestItemFrame:SetPoint("BOTTOMLEFT", "DugisSmallFrameContainer", "TOPLEFT", 13, 35)
		DugisOnOffButton:SetPoint("BOTTOMLEFT", "DugisSmallFrameContainer", "TOPLEFT", 10, 31 )
	elseif DugisGuideViewer:IsModuleLoaded("SmallFrame") then 
		DugisGuideViewer.Modules.SmallFrame:Reset()
		DugisGuideViewerActionItemFrame:SetPoint("BOTTOMLEFT", "DugisSmallFrameContainer", "TOPLEFT", 13, -6)
		DugisGuideViewerQuestItemFrame:SetPoint("BOTTOMLEFT", "DugisSmallFrameContainer", "TOPLEFT", 13, -6)
		DugisOnOffButton:SetPoint("BOTTOMLEFT", "DugisSmallFrameContainer", "TOPLEFT", 10, -10 )	
	else
		DugisGuideViewerActionItemFrame:SetPoint("RIGHT", "DugisMainBorder", "LEFT", -34, -15)
		DugisGuideViewerQuestItemFrame:SetPoint("RIGHT", "DugisMainBorder", "LEFT", -34, -15)
		DugisOnOffButton:SetPoint("RIGHT", "DugisMainBorder", "LEFT", 0, 15 )
	end
	local actionShown = DugisGuideViewerActionItemFrame:IsShown()
	local questShown = DugisGuideViewerQuestItemFrame:IsShown()
	DugisGuideViewerActionItemFrame:Show()
	DugisGuideViewerQuestItemFrame:Show()
	DugisGuideViewerActionItemFrame:ClearAllPoints()
	DugisGuideViewerQuestItemFrame:ClearAllPoints()
	if not actionShown then
		DugisGuideViewerActionItemFrame:Hide()
	end
	if not questShown then
		DugisGuideViewerQuestItemFrame:Hide()
	end
	
	if DugisGuideViewer:IsModuleLoaded("ModelViewer") then
		DugisGuideViewer.Modules.ModelViewer:ResetPosition() 
	end

	if DugisGuideViewer:IsModuleLoaded("Target") then
		self.Modules.Target.Frame:ClearAllPoints()
		self.Modules.Target.Frame:SetPoint("LEFT", "DugisGuideViewerActionItemFrame", "RIGHT", "5", "0")
		self.Modules.Target.Frame:SetPoint("LEFT", "DugisGuideViewerQuestItemFrame", "RIGHT", "5", "0")
	end

	if DugisGuideViewer:IsModuleLoaded("DugisArrow") then
		DugisGuideViewer.DugisArrow:ResetPosition()
	end
end

function getQuestIndexByQuestName(name)
	local i
	local numq, _ = GetNumQuestLogEntries()
	for i=1,numq do
		local title, _, _, _, isHeader = GetQuestLogTitle(i)
		if not isHeader then
			if name == title then
				return i
			end

		end
	end
end

function DugisGuideViewer:GetQIDFromQuestName(name)
	local logindx = getQuestIndexByQuestName(name)
	local qid
	if logindx then
		qid = select(9, GetQuestLogTitle(logindx))
	end
	return qid
end

function DugisGuideViewer:CreateFlashFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	local texture = frame:CreateTexture()
	texture:SetAllPoints(frame)
	texture:SetTexture(1, 1, 1, 0.5)
	frame:SetBackdrop( { bgFile = nil, edgeFile = DugisGuideViewer.ARTWORK_PATH.."Border-Flash.tga", tile = true, tileSize = 32, edgeSize = 10, insets = { 0, 0, 0, 0 } })
	
	local flashGroup = parent:CreateAnimationGroup()
	local flash = flashGroup:CreateAnimation("Alpha")

	--SmallFrame:ResetFloating()

	flash:SetDuration(0.5)
	flash:SetSmoothing("OUT")
	flash:SetScript("OnUpdate", function(self)
		local back = frame
		--DebugPrint("progress="..progress)
		local progress = 1 - self:GetSmoothProgress()
		back:SetAlpha(progress)

		if progress == 0 then
			--if progress >= 0.25 then
			flash:Stop()
		end

		if flash:IsPlaying() then
			back:Show()
		elseif flash:IsStopped() then
			back:Hide()
		end
	end)

	frame:ClearAllPoints()

	frame:SetPoint("CENTER", parent, 1, -1)
	return flashGroup, flash, frame
end

function DugisGuideViewer:UpdateCompletionVisuals()
	DugisGuideViewer:UpdateSmallFrame()
	DugisGuideViewer.Modules.DugisWatchFrame:PlayFlashAnimation()
end

local lastTime = GetTime()
function DugisGuideViewer:PlayCompletionSound(soundSetting)
	local now = GetTime()
	--DugisGuideViewer:DebugFormat("PlayCompletionSound", "lastTime", lastTime, "now", now, "sound", DugisGuideViewer:GetDB(soundSetting))
	if now-lastTime > 2 then
		PlaySoundFile(DugisGuideViewer:GetDB(soundSetting))
	end
	lastTime = now
end

local lastCUFire
function DugisGuideViewer:CRITERIA_UPDATE()
	local elapsed = GetTime()
	if lastCUFire==elapsed then return end
	lastCUFire = elapsed
	DugisGuideViewer:Guide_CRITERIA_UPDATE()
	DugisGuideViewer:WatchFrame_CRITERIA_UPDATE()
end


function DugisGuideViewer.TableAppend(t, ...)
	local n = select("#", ...)
	for i=1,n do
		tinsert(t, (select(i, ...)))
	end
end

function DugisGuideViewer:PET_BATTLE_OPENING_START()
	DugisGuideUser.PetBattleOn = true
	if self:UserSetting(DGV_SHOWONOFF) == true then	DugisOnOffButton:Hide() end
	if DugisGuideViewer:GuideOn() then 
		--DugisGuideViewer:TurnOff()
		if DugisGuideViewer:IsModuleLoaded("SmallFrame") and (not WatchFrame.collapsed or not DugisGuideViewer:UserSetting(DGV_ANCHOREDSMALLFRAME)) then 
			DugisGuideViewer.Modules.SmallFrame.Frame:Hide()
		end
		if DugisGuideViewer:IsModuleLoaded("DugisArrow") and DugisGuideViewer.Modules.DugisArrow.waypoints then
			DugisGuideViewer.DugisArrow:Hide()
		end	
		if DugisGuideViewer:IsModuleLoaded("Target") and DugisGuideViewer.CurrentTitle then
			DugisGuideViewer.Modules.Target.Frame:Hide()
			DugisGuideViewerActionItemFrame:Hide()
			DugisGuideViewerQuestItemFrame:Hide()			
		end
		DugisGuideViewer:UpdateIconStatus()
	end
	DugisGuideViewer:RegisterEvent("PET_BATTLE_OVER")
end

function DugisGuideViewer:PET_BATTLE_OVER()
	DugisGuideUser.PetBattleOn = false
	if self:UserSetting(DGV_SHOWONOFF) then	DugisOnOffButton:Show() end
	if DugisGuideViewer:GuideOn() then
		if DugisGuideViewer:IsModuleLoaded("SmallFrame") and (not WatchFrame.collapsed or not DugisGuideViewer:UserSetting(DGV_ANCHOREDSMALLFRAME)) then
			DugisGuideViewer.Modules.SmallFrame.Frame:Show()
		end
		if DugisGuideViewer:IsModuleLoaded("DugisArrow") and DugisGuideViewer.Modules.DugisArrow.waypoints then
			DugisGuideViewer.DugisArrow:Show()
		end

		if DugisGuideViewer:IsModuleLoaded("Target") and DugisGuideViewer.CurrentTitle then
			DugisGuideViewer:FinalizeTarget()		
		end
				
		--DugisGuideViewer:TurnOn()
		DugisGuideViewer:UpdateIconStatus()
		if not DugisGuideViewer.CurrentTitle and DugisGuideViewer:UserSetting(DGV_ANCHOREDSMALLFRAME) then -- trick to fix WatchFrame border adjustment. 
			WatchFrame.userCollapsed = true;
			WatchFrame_Collapse(WatchFrame)
		end
	end
	DugisGuideViewer:UnregisterEvent("PET_BATTLE_OVER")
end
