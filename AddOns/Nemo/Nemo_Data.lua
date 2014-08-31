local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo", true)

--********************************************************************************************
-- Locals
--********************************************************************************************
-- Lua APIs
local strsub, strsplit, strlower, strmatch, strtrim = string.sub, string.split, string.lower, string.match, string.trim
local format, tonumber, tostring = string.format, tonumber, tostring
local tsort, tinsert = table.sort, table.insert
local select, pairs, next, type = select, pairs, next, type
local error, assert = error, assert
local rawget, rawset = rawget, rawset

-- WoW APIs
local _G = _G
local GetTime    = GetTime
local UnitGUID   = UnitGUID

function Nemo.D.Initialize()
	Nemo.D.Prefix 		= 'Nemo'																		--Addon communications channel prefix
	Nemo.D.SoundChannel = 'Master'																		--Sound valume control to use for alerts
	Nemo.D.SW			= ceil( GetScreenWidth() )														--Screen Width
	Nemo.D.SH			= ceil( GetScreenHeight() )														--Screen Height
	Nemo.D.ScoreUpdateInterval	= .5																	--How often we should update the tracked battleground names
	Nemo.D.ScoreLastUpdate		= GetTime()
	Nemo.D.Specs 		= {}																			--Specializations
	Nemo.D.SpecsSorted	= {}																			--Specializations Sort Order for drop down
	Nemo.D.SpellInfo    = {}																			--Table to hold information about spells ex: ticktimes, traveltimes, base duration
	Nemo.D.CriteriaSABFrame = {}																		--Current criteria frame being processed by engine
	Nemo.D.ImportType   = nil																			--The type of import rotation or actionpack
	Nemo.D.ImportVersion= nil																			--The version the import was created in
	Nemo.D.ImportName   = nil																			--Name of the import could be rotation / action pack
	Nemo.D.ImportIndex  = nil																			--The index of the action pack table insert
	Nemo.D.DamageTakenIndex  	= 1																		--The index of Nemo.D.P["DAMAGE_TAKEN"]
	Nemo.D.DamageTakenMaxHits  	= 100																	--Maximum number of Nemo.D.P["DAMAGE_TAKEN"] hits to track
	Nemo.D.DebugTimerStart		= debugprofilestop()
	Nemo.D.UpdateMode   = 0																				--0=create new names for existing objects do not update
																										--1=update existing objects
																										--3=Abort updates if objects already exist + do not create if object does not exist
																										
	Nemo.D.MapName		= nil																			--Current Map Name
	Nemo.D.MapFloor		= nil																			--Current Map Floor
	Nemo.D.MapW			= nil																			--Current Map Width
	Nemo.D.MapH			= nil																			--Current Map Height
	Nemo.D.LastChatSpam = GetTime()																		--Used to throttle the chat spam for action initialization
	Nemo.D.LastQueueSlot1 = nil																			--Used to identify queue slot 1 changes for print highest priority action to chat window option 

	--Save the tree keys for short syntax lookup, we may chose to add more menus to the main tree later on
	Nemo.D.OTK  = Nemo:SearchTable(Nemo.DB.profile.treeMain, "value", "Nemo.UI:CreateOptionsPanel()")	--Options Tree Key
	Nemo.D.OTM  = Nemo.DB.profile.treeMain[Nemo.D.OTK]													--Options Tree main

	Nemo.D.LTK  = Nemo:SearchTable(Nemo.DB.profile.treeMain, "value", "Nemo.UI:CreateListsPanel()")		--Lists Tree Key
	Nemo.D.LTM  = Nemo.DB.profile.treeMain[Nemo.D.LTK]													--Lists profile tree main
	Nemo.D.LTMC = Nemo.DB.profile.treeMain[Nemo.D.LTK].children											--Lists profile tree main children

	Nemo.D.RTK  = Nemo:SearchTable(Nemo.DB.profile.treeMain, "value", "Nemo.UI:CreateRotationsPanel()")	--Rotations Tree Key
	Nemo.D.RTM  = Nemo.DB.profile.treeMain[Nemo.D.RTK]													--Rotations profile tree main
	Nemo.D.RTMC = Nemo.DB.profile.treeMain[Nemo.D.RTK].children											--Rotations profile tree main children

	Nemo.D.ATK  = Nemo:SearchTable(Nemo.DB.profile.treeMain, "value", "Nemo.UI:CreateAlertsPanel()")	--Alerts Tree Key
	Nemo.D.ATM  = Nemo.DB.profile.treeMain[Nemo.D.ATK]													--Alerts profile tree main
	Nemo.D.ATMC = Nemo.DB.profile.treeMain[Nemo.D.ATK].children											--Alerts profile tree main children
	Nemo.D.PClass = select(2, UnitClass("player") )
	Nemo.D.knownGUIDTypes = {[0]="player", [1]="world object", [3]="NPC", [4]="pet", [5]="vehicle"}		--GUID types
	Nemo.D.AuraTypes = { ["BUFF"] = 1, ["DEBUFF"] = 2, }
	Nemo.D.TRAVELTIME_EVENTS = {																		--Events that trigger travel time tracking
		["RANGE_DAMAGE"] = true,
		["RANGE_MISSED"] = true,
		["SPELL_MISSED"] = true,
		["SPELL_DAMAGE"] = true,
		["SPELL_HEAL"] = true,
		["SPELL_ENERGIZE"] = true,
		["SPELL_DRAIN"] = true,
		["SPELL_LEECH"] = true,
		["SPELL_SUMMON"] = true,
		["SPELL_CREATE"] = true,
		["SPELL_INTERRUPT"] = true,
		["SPELL_AURA_APPLIED"] = true,
		["SPELL_AURA_REFRESH"] = true,
		["SPELL_PERIODIC_MISSED"] = true,
		["SPELL_PERIODIC_DAMAGE"] = true,
		["SPELL_PERIODIC_HEAL"] = true,
		["SPELL_PERIODIC_ENERGIZE"] = true,
		["SPELL_PERIODIC_DRAIN"] = true,
		["SPELL_PERIODIC_LEECH"] = true,
		["SPELL_DISPEL_FAILED"] = true,
	};
	Nemo.D.TU={}--Tracked unit data for battleground targets, playername is the key
	Nemo.D.TU.AddPlayer=function(playername)
		if ( not Nemo.D.TU[playername] ) then
-- print("Added TU playername="..playername)
			Nemo.D.TU[playername] = {}
			Nemo.D.TU[playername].auras = {}
			Nemo.D.TU[playername].lut = GetTime()--unit last update time
		end
	end
	Nemo.D.TU.ApplyAura=function(playername, spell, sourceguid)
		if ( not Nemo.D.TU[playername] ) then return end
		if ( not Nemo.D.TU[playername].auras[spell] ) then
			Nemo.D.TU[playername].auras[spell] = {}
			Nemo.D.TU[playername].auras[spell].sguid = sourceguid
		end
		Nemo.D.TU[playername].auras[spell].lat = GetTime()--last applied time
		Nemo.D.TU[playername].auras[spell].lut = GetTime()--aura last update time
		Nemo.D.TU[playername].lut = GetTime()--unit last update time
	end
	Nemo.D.TU.RemoveAura=function(playername, spell)
		if ( not Nemo.D.TU[playername] ) then return end
		if ( Nemo.D.TU[playername].auras[spell] ) then
			Nemo.D.TU[playername].auras[spell] = nil
			-- table.remove( Nemo.D.TU[playername].auras, spell )
		end
		Nemo.D.TU[playername].lut = GetTime()--unit last update time
	end
	Nemo.D.POWER_TYPES = {
		[0]	= "SPELL_POWER_MANA",
		"SPELL_POWER_RAGE",
		"SPELL_POWER_FOCUS",
		"SPELL_POWER_ENERGY",
		"SPELL_POWER_HAPPINESS",
		"SPELL_POWER_RUNES",
		"SPELL_POWER_RUNIC_POWER",
		"SPELL_POWER_SOUL_SHARDS",
		"SPELL_POWER_ECLIPSE",
		"SPELL_POWER_HOLY_POWER",
		"SPELL_POWER_ALTERNATE",
		"SPELL_POWER_DARK_FORCE",
		"SPELL_POWER_CHI",
		"SPELL_POWER_SHADOW_ORBS",
		"SPELL_POWER_BURNING_EMBERS",
		"SPELL_POWER_DEMONIC_FURY",
	}
	Nemo.D.P={ --Custom player tracked data for use in criteria
		--pdp=previous data point, used to calculate power gain rate in Nemo_events.lua
		--pgr=power gain rate
		--ttm=time to max power
		--lut=last update time
		["SPELL_POWER_MANA"]			={ pdp=0, pgr=0, lut=0, ttm=0, },--0
		["SPELL_POWER_RAGE"]			={ pdp=0, pgr=0, lut=0, ttm=0, },--1
		["SPELL_POWER_FOCUS"]			={ pdp=0, pgr=0, lut=0, ttm=0, },--2
		["SPELL_POWER_ENERGY"]			={ pdp=0, pgr=0, lut=0, ttm=0, },--3
		["SPELL_POWER_HAPPINESS"]		={ pdp=0, pgr=0, lut=0, ttm=0, },--4
		["SPELL_POWER_RUNES"]			={ pdp=0, pgr=0, lut=0, ttm=0, },--5
		["SPELL_POWER_RUNIC_POWER"]		={ pdp=0, pgr=0, lut=0, ttm=0, },--6
		["SPELL_POWER_SOUL_SHARDS"]		={ pdp=0, pgr=0, lut=0, ttm=0, },--7
		["SPELL_POWER_ECLIPSE"]			={ pdp=0, pgr=0, lut=0, ttm=0, },--8
		["SPELL_POWER_HOLY_POWER"]		={ pdp=0, pgr=0, lut=0, ttm=0, },--9
		["SPELL_POWER_ALTERNATE"]		={ pdp=0, pgr=0, lut=0, ttm=0, },--10 I saw this one while questing
		["SPELL_POWER_ALTERNATE_POWER"]	={ pdp=0, pgr=0, lut=0, ttm=0, },--10 Not sure if this one is really used
		["SPELL_POWER_DARK_FORCE"]		={ pdp=0, pgr=0, lut=0, ttm=0, },--11
		["SPELL_POWER_CHI"]				={ pdp=0, pgr=0, lut=0, ttm=0, },--12
		["SPELL_POWER_SHADOW_ORBS"]		={ pdp=0, pgr=0, lut=0, ttm=0, },--13
		["SPELL_POWER_BURNING_EMBERS"]	={ pdp=0, pgr=0, lut=0, ttm=0, },--14
		["SPELL_POWER_DEMONIC_FURY"]	={ pdp=0, pgr=0, lut=0, ttm=0, },--15
		["STAGGER"]						={ percent=0, total=0 },		 --Monk stagger amounts
		["METAMORPHOSIS"]				={ appliedtimestamp=0 },		 --Warlock Metamorphosis tracking in Nemo_Events
		["LCT"]							={},							 --Last casted times for player casted spells
		["TS"]							={},							 --Tracked spells table for dot and hot ticks
		["TU"]							={},							 --Tracked units table for mob counts
		["TTTD"]						={},							 --Target time to die
		["CHAT_TRIGGERS"]				={},							 --List of chat triggers to pass criteria
		["DAMAGE_TAKEN"]				={},							 --Damage taken
		["ECT"]							=nil,							 --Entered combat gettime
	}
	Nemo.D.P.DeleteTS=function(spellID, destGUID)						 --Delete a tracked spell using spellID, destGUID
		if ( Nemo.D.P.TS[(spellID or "")..':'..(destGUID or "")] ) then Nemo.D.P.TS[(spellID or "")..':'..(destGUID or "")] = nil end
	end
	Nemo.D.P.DeleteTU=function(trackedGUID)								 --Delete a tracked unit
		if ( Nemo.D.P.TU[trackedGUID] ) then Nemo.D.P.TU[trackedGUID] = nil end
	end
	Nemo.D.P.InitTimeToDie=function(trackedGUID, uId)					--Tracked units timetodie
		Nemo.D.P.TU[trackedGUID].timetodie				= 600			--Default time to die is 10 minutes or 600 seconds
		Nemo.D.P.TU[trackedGUID].timetodie_datapoints	= 1		
		Nemo.D.P.TU[trackedGUID].timeSum				= GetTime()																--xsum
		Nemo.D.P.TU[trackedGUID].healthSum				= Nemo.GetUnitHealth(uId)												--ysum
		Nemo.D.P.TU[trackedGUID].timeMean				= Nemo.D.P.TU[trackedGUID].timeSum * Nemo.D.P.TU[trackedGUID].timeSum	--xxsum
		Nemo.D.P.TU[trackedGUID].healthMean				= Nemo.D.P.TU[trackedGUID].timeSum * Nemo.D.P.TU[trackedGUID].healthSum	--xysum
	end
	Nemo.D.P.AuditTrackedData=function()											--Audit tracked spells and units, fires in the engine	
		for k,v in pairs(Nemo.D.P.TS) do
			-- Todo: This is causing a lot of garbage collection, need a new way to delete the tracked spells besides = nil
			if ( GetTime()-v.lut > 15 ) then Nemo.D.P.TS[k] = nil end	 		--Delete tracked spells that have not been updated in 15 seconds, Warlock doom ticks at 13 second intervals...strange
		end
		for k,v in pairs(Nemo.D.P.TU) do
			if ( GetTime()-v.lut > 3 ) then Nemo.D.P.TU[k] = nil end		--Delete tracked units that have not been updated in 3 seconds
		end
		for k,v in pairs(Nemo.D.TU) do
			if ( type(v)=="table" ) then
				for k1,v1 in pairs(v.auras) do
					if ( GetTime()-v1.lut > 60 ) then
-- print(" Aura "..k1.."expired on playername="..k)
						v1 = nil --Remove auras older than 60 seconds
					end
				end
				if ( GetTime()-v.lut > 60 ) then v = nil end --Remove tracked units that have not been updated in 60 seconds
			end
		end
	end
	Nemo.D.ResetDebugTimer=function()
		Nemo.D.DebugTimerStart = debugprofilestop()
	end
	Nemo.D.GetDebugTimerElapsed=function(minElapsed)
		local lReturn = ( debugprofilestop()-Nemo.D.DebugTimerStart )
		if ( lReturn > ( minElapsed or 0 ) ) then
			-- print(format(" E: %f ms:", elapsedTime)..tostring(suffix) )
		else
			lReturn = 0
		end
		return lReturn
	end
	Nemo.D.RunCode=function( code, lseprefix, pcalleprefix, ShowLSErrors, ShowPCErrors  )
		--lseprefix = loadstring error print message prefix
		--lsegui   = loadstring error gui message
		--pcall error prefix
		local func, errorMessage = loadstring(code)
		if( not func ) then
			if ( ShowLSErrors ) then
				print( lseprefix..errorMessage )
				if ( Nemo.UI.fMain and Nemo.UI.fMain:IsShown() ) then Nemo.UI.fMain:SetStatusText( lseprefix..errorMessage ) end
			end
			return 1
		end
		success, errorMessage = pcall(func);								-- Call the function we loaded
		if( not success ) then
			if ( ShowPCErrors ) then print(pcalleprefix..errorMessage) end
			return 1
		end
		return 0
	end
	Nemo.D.Threads = {}
	Nemo.D.ActionTypes = {
		["spell"]    =L["action/actiontypes/spell"],
		["macro"]    =L["action/actiontypes/macro"],
		["macrotext"]=L["action/actiontypes/macrotext"],
		["item"]     =L["action/actiontypes/item"],
	}
	Nemo.D.ActionSortOrder = {	"spell", "macro", "macrotext", "item" }

	Nemo.D.AlertTextures	= {
		["_None"]	=L["alert/sounds/_None"],
		['_Icon']	=L["alert/visual/_Icon"],
		["Interface\\Addons\\Nemo\\Textures\\ArcaneMissiles"]	=L["alert/visual/ArcaneMissiles"],
		["Interface\\Addons\\Nemo\\Textures\\ArtOfWar"]			=L["alert/visual/ArtOfWar"],
		["Interface\\Addons\\Nemo\\Textures\\FrozenFingers"]	=L["alert/visual/FrozenFingers"],
		["Interface\\Addons\\Nemo\\Textures\\GrandCrusader"]	=L["alert/visual/GrandCrusader"],
		["Interface\\Addons\\Nemo\\Textures\\HotStreak"]		=L["alert/visual/HotStreak"],
		["Interface\\GLUES\\MODELS\\UI_BLOODELF\\LEAFGREEN_32"]	=L["alert/visual/Leaf"],
		["Interface\\Addons\\Nemo\\Textures\\Maelstrom"]		=L["alert/visual/Maelstrom"],
		["Interface\\Addons\\Nemo\\Textures\\Rime"]				=L["alert/visual/Rime"],
		["Interface\\SPELLBOOK\\UI-Glyph-Rune1"]				=L["alert/visual/Rune1"],
		["Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-26"]	=L["alert/visual/DragonHead"],
	}
	Nemo.D.AlertTexturesSortOrder = {
		"_None",
		"_Icon",
		"Interface\\Addons\\Nemo\\Textures\\ArcaneMissiles",
		"Interface\\Addons\\Nemo\\Textures\\ArtOfWar",
		"Interface\\Addons\\Nemo\\Textures\\FrozenFingers",
		"Interface\\Addons\\Nemo\\Textures\\GrandCrusader",
		"Interface\\Addons\\Nemo\\Textures\\HotStreak",
		"Interface\\GLUES\\MODELS\\UI_BLOODELF\\LEAFGREEN_32",
		"Interface\\Addons\\Nemo\\Textures\\Maelstrom",
		"Interface\\Addons\\Nemo\\Textures\\Rime",
		"Interface\\SPELLBOOK\\UI-Glyph-Rune1",
		"Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-26",
	}
	Nemo.D.AlertFonts	= {
		["Fonts\\ARIALN.TTF"]	=L["alert/visual/ARIALN"],
		["Fonts\\FRIZQT__.TTF"]	=L["alert/visual/FRIZQT__"],
		["Fonts\\MORPHEUS.ttf"]	=L["alert/visual/MORPHEUS"],
		["Fonts\\skurri.ttf"]	=L["alert/visual/skurri"],
	}
	Nemo.D.AlertFontsSortOrder = {
		"Fonts\\ARIALN.TTF",
		"Fonts\\FRIZQT__.TTF",
		"Fonts\\MORPHEUS.ttf",
		"Fonts\\skurri.ttf",
	}
	Nemo.D.Sounds = {
		["_None"]					=L["alert/sounds/_None"],
		["_Custom"]					=L["alert/sounds/_Custom"],
		["AuctionWindowClose"]		=L["alert/sounds/AuctionWindowClose"],
		["AuctionWindowOpen"]		=L["alert/sounds/AuctionWindowOpen"],
		["FISHING REEL IN"]			=L["alert/sounds/FISHING REEL IN"],
		["HumanExploration"]		=L["alert/sounds/HumanExploration"],
		["igBackPackOpen"]			=L["alert/sounds/igBackPackOpen"],
		["igPVPUpdate"]				=L["alert/sounds/igPVPUpdate"],
		["LEVELUP"]    				=L["alert/sounds/LEVELUP"],
		["LOOTWINDOWCOINSOUND"]   	=L["alert/sounds/LOOTWINDOWCOINSOUND"],
		["MapPing"]					=L["alert/sounds/MapPing"],
		["PVPENTERQUEUE"]			=L["alert/sounds/PVPENTERQUEUE"],
		["PVPTHROUGHQUEUE"]			=L["alert/sounds/PVPTHROUGHQUEUE"],
		["QUESTADDED"]				=L["alert/sounds/QUESTADDED"],
		["QUESTCOMPLETED"]			=L["alert/sounds/QUESTCOMPLETED"],
		["RaidWarning"]				=L["alert/sounds/RaidWarning"],
		["ReadyCheck"]				=L["alert/sounds/ReadyCheck"],
		["TellMessage"]				=L["alert/sounds/TellMessage"],

	}
	Nemo.D.SoundsSortOrder = {
		"_None",
		"_Custom",
		"AuctionWindowClose",
		"AuctionWindowOpen",
		"FISHING REEL IN",
		"HumanExploration",
		"igBackPackOpen",
		"igPVPUpdate",
		"LEVELUP",
		"LOOTWINDOWCOINSOUND",
		"MapPing",
		"PVPENTERQUEUE",
		"PVPTHROUGHQUEUE",
		"QUESTADDED",
		"QUESTCOMPLETED",
		"RaidWarning",
		"ReadyCheck",
		"TellMessage",
	}

	Nemo.D.DebuffExclusions = {							-- Ignore these debbuffs for debuff type checking
		[GetSpellInfo(15822)]   = true,					-- Dreamless Sleep
		[GetSpellInfo(24360)]   = true,					-- Greater Dreamless Sleep
		[GetSpellInfo(28504)]   = true,					-- Major Dreamless Sleep
		[GetSpellInfo(24306)]   = true,					-- Delusions of Jin'do
		[GetSpellInfo(46543)]   = true,					-- Ignite Mana
		[GetSpellInfo(16567)]   = true,					-- Tainted Mind
		[GetSpellInfo(39052)]   = true,					-- Sonic Burst
		[GetSpellInfo(30129)]   = true,					-- Charred Earth - Nightbane debuff, can't be cleansed, but shows as magic
		[GetSpellInfo(31651)]   = true,					-- Banshee Curse, Melee hit rating debuff
		[GetSpellInfo(124275)]  = true,					-- Light Stagger, cant be cured
	}
	Nemo.D.BlacklistedInitSpells = {					-- Do not initialize these spells to save memory in SpellInfo
		['83964']   = true,								-- Bartering
		['78635']   = true,								-- Mr. Popularity
		['90265']   = true,								-- Master Riding
		
		-- Monk
		['116092']   = true,							-- Afterlife
	}

	Nemo.D.ImportClassDefaultLists=function()			-- Load the shared lists from the localization file
		for listnameindex=1,100 do
			if ( L[Nemo.D.PClass..'_DEFAULT_LISTS_'..listnameindex]~=Nemo.D.PClass..'_DEFAULT_LISTS_'..listnameindex ) then-- If the localization doesnt get defaulted to itself by wowace
				local lListName = L[Nemo.D.PClass..'_DEFAULT_LISTS_'..listnameindex]
				for listentryindex=1,100 do
					if ( L['SHARED_LISTS_'..lListName..'_'..listentryindex]~='SHARED_LISTS_'..lListName..'_'..listentryindex ) then
						local lAddEntryString =L['SHARED_LISTS_'..lListName..'_'..listentryindex]
						Nemo.D.RunCode( lAddEntryString, L["utils/debug/prefix"]..L["rotations/importfail"], L["utils/debug/prefix"]..L["rotations/importfail"], true, true  )
					else
						break
					end
				end
			else
				break
			end
		end
		if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end
	end
	Nemo.D.ImportClassDefaultRotations=function()			   -- Load the class rotations from the localization file
		for rotationindex=1,100 do
			if ( L[Nemo.D.PClass..'_DEFAULT_ROTATIONS_'..rotationindex]~=Nemo.D.PClass..'_DEFAULT_ROTATIONS_'..rotationindex ) then	-- If the localization doesnt get defaulted to itself by wowace
				local lRotationString = L[Nemo.D.PClass..'_DEFAULT_ROTATIONS_'..rotationindex]
				Nemo.D.RunCode( 'Nemo.UI.RotationImport([==['..lRotationString..']==])', L["utils/debug/prefix"]..L["rotations/rimportfail"], L["utils/debug/prefix"]..L["rotations/rimportfail"], true, true  )
			else
				break
			end
		end
		if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end
	end
	Nemo.D.DeleteClassDefaultRotations=function()			   -- Load the class rotations from the localization file
		for rotationindex=1,100 do
			if ( L[Nemo.D.PClass..'_DEFAULT_ROTATIONS_'..rotationindex]~=Nemo.D.PClass..'_DEFAULT_ROTATIONS_'..rotationindex  ) then-- If the localization doesnt get defaulted to itself by wowace
				local lRotationString = L[Nemo.D.PClass..'_DEFAULT_ROTATIONS_'..rotationindex]	-- Get the serialized rotation string from localization
				-- We have to use import rotation to deserialize the string and set Nemo.D.ImportName so we know what rotation to delete
				Nemo.D.RunCode( 'Nemo.UI.RotationImport([==['..lRotationString..']==])', L["utils/debug/prefix"]..L["rotations/rimportfail"], L["utils/debug/prefix"]..L["rotations/rimportfail"], true, true  )
				Nemo.DeleteRotation( Nemo.D.ImportName )
			else
				break
			end
		end
		if ( Nemo.UI.sgMain ) then Nemo.UI.sgMain.tgMain:RefreshTree() end
	end

	Nemo.D.SpellInfo = Nemo.LibSimcraftParser.GetSpellDB(false, Nemo.D.BlacklistedInitSpells ) --useSupplementalSpellStore=false
	
	Nemo.D.InitCriteriaClassTree()					   -- Initialize the class criteria and default rotations
	if ( Nemo:isblank(Nemo.DB.profile.options.sr) ) then
		Nemo.UI.SetRotationForCurrentSpec()			   -- Select the rotation that matches the current specialization or talentgroup
	else
		Nemo.UI.SelectRotation(Nemo.DB.profile.options.sr, false) -- Select the last loaded rotation
	end
end
function Nemo.D.FindSpellByNameAndProperty(spellName, property)
  local info = Nemo.D.SpellInfo[spellName]
  if not info then return end
  local function Search(spell, searched)
    if spell[property] then
      return spell
    end
    searched[spell.spellid] = true
    if spell.related then
      for _, id in ipairs(spell.related) do
        if not searched[id] then
          local try = Nemo.D.SpellInfo[id]
          if Search(try, searched) then
            return try
          end
        end
      end
    end
    return false
  end
  return Search(info, {})
end
function Nemo:GetDefaults()
	--*****************************************************
	--Default profile tree
	--*****************************************************
	return {
		profile = {
			options = {
				anchor = {},
				updateinterval = .05,
				threadupdateinterval = .01,
				simpleglow = true,
				hidenemoactions = false,
				printhp = false,
			},
			treeMain = {
				{
					value = "Nemo.UI:CreateOptionsPanel()",
					text = L["maintree/options"],
					icon = "Interface\\Icons\\INV_Misc_Gear_01",
				},
				{
					value = "Nemo.UI:CreateListsPanel()",
					text = L["maintree/lists"],
					icon = "Interface\\Icons\\TRADE_ARCHAEOLOGY_HIGHBORNE_SCROLL",
					children = {},
				},
				{
					value = "Nemo.UI:CreateRotationsPanel()",
					text = L["maintree/rotations"],
					icon = "Interface\\PaperDollInfoFrame\\UI-GearManager-Undo",
					children = {},
				},
				{
					value = "Nemo.UI:CreateAlertsPanel()",
					text = L["maintree/alerts"],
					icon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
					children = {},
				},
			},
		},
	}
end

