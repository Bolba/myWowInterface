local Nemo 		= LibStub("AceAddon-3.0"):GetAddon("Nemo")
local L       	= LibStub("AceLocale-3.0"):GetLocale("Nemo")

--********************************************************************************************
-- Locals
--********************************************************************************************
local strsub, strsplit, strlower, strmatch, strtrim, strfind = string.sub, string.split, string.lower, string.match, string.trim, string.find
local format, tonumber, tostring = string.format, tonumber, tostring

function Nemo:OnCommReceived(prefix, message, distribution, sender)
	if ( not StaticPopup_Visible( "NEMO_YESNOPOPUP" ) ) then
		local lNemoPopup = Nemo.UI.CreateYesNoPopupDialog(string.format(L["rotation/received/l"], sender))
		StaticPopupDialogs["NEMO_YESNOPOPUP"].OnAccept = function ()
			Nemo.D.UpdateMode = 0													--Create new rotation, do not update existing
			Nemo.UI.RotationImport( message, true )
		end
	end
end

function Nemo.SetSnapshotData(SpellID, DestID, AuraType )
	if ( Nemo:isblank( Nemo.D.P.TS[SpellID..':'..DestID] ) ) then
		Nemo.D.P.TS[SpellID..':'..DestID] = {}										-- New tracked spells (TS) entry
	end
	if ( AuraType and ( AuraType == "BUFF" or AuraType == "DEBUFF" ) ) then
		Nemo.D.P.TS[SpellID..':'..DestID].atype    = Nemo.D.AuraTypes[AuraType]		-- Some events in COMBAT_LOG_EVENT_UNFILTERED send nil Aura Type so protect against that
	end
	Nemo.D.P.TS[SpellID..':'..DestID].smsh     = UnitSpellHaste("player")/100		-- Spell modifier spell haste
	local base, posBuff, negBuff = UnitAttackPower("player");
	local effectiveAP = base + posBuff + negBuff;
	Nemo.D.P.TS[SpellID..':'..DestID].smap     = effectiveAP						-- Attack Power when aura applied
	Nemo.D.P.TS[SpellID..':'..DestID].smcc     = {}									-- Spell modifier crit chance table
	Nemo.D.P.TS[SpellID..':'..DestID].smbd     = {}									-- Spell modifier bonus damage table
	for spellTreeID = 1, 7 do
		Nemo.D.P.TS[SpellID..':'..DestID].smcc[tostring(spellTreeID)] = GetSpellCritChance(spellTreeID)		-- Crit chance when aura applied
		Nemo.D.P.TS[SpellID..':'..DestID].smbd[tostring(spellTreeID)] = GetSpellBonusDamage(spellTreeID)	-- Bonus damage when aura applied
	end
	Nemo.D.P.TS[SpellID..':'..DestID].lut=GetTime()									-- Last update time
	Nemo.D.P.TS[SpellID..':'..DestID].lat=GetTime()									-- Last applied time, does not update with ticks
end

function Nemo:UNIT_POWER(_,uId,powerType)
	if (uId~="player") then return end
	local powertype = "SPELL_POWER_"..powerType
	--Check if it was a power gain then see how much it was to calculate the pgr and ttm
	if (Nemo.D.P[powertype] and uId=="player") then
		local power = UnitPower("player", powerType)
		local powermax = UnitPowerMax("player", powerType)
		if ( Nemo.D.P[powertype].lut == 0) then Nemo.D.P[powertype].lut=GetTime() end	--Initialize last update timer(lut) if needed
		local elapsed = GetTime() - Nemo.D.P[powertype].lut
-- Nemo:dprint("pgr elapsed="..elapsed)			
		if (elapsed > 0 and power > Nemo.D.P[powertype].pdp) then
			Nemo.D.P[powertype].pgr=(power-Nemo.D.P[powertype].pdp)/elapsed				--Power gain rate(pgr)=power-previous data point(pdp)/elapsed
-- Nemo:dprint(".pgr["..powertype.."]="..Nemo.D.P[powertype].pgr)			
			Nemo.D.P[powertype].ttm=(powermax-power)/Nemo.D.P[powertype].pgr			--Time to max(ttm)
		end
		Nemo.D.P[powertype].pdp=power
		Nemo.D.P[powertype].lut=GetTime()--last update time in seconds
	end
end
function Nemo:UNIT_AURA(_,uId)
	if ( uId == "player" ) then
		if ( Nemo.D.PClass == "MONK") then --MONK stagger calculations
			local staggerLight = GetSpellInfo(124275)
			local staggerModerate = GetSpellInfo(124274)
			local staggerHeavy = GetSpellInfo(124273)

			local _,_,_,_,_,_,staggerE,_,_,_,_,_,_,_, staggerA = UnitDebuff("player", staggerLight)
			if (Nemo:isblank(staggerA)) then _,_,_,_,_,_,staggerE,_,_,_,_,_,_,_, staggerA = UnitDebuff("player", staggerModerate) end
			if (Nemo:isblank(staggerA)) then _,_,_,_,_,_,staggerE,_,_,_,_,_,_,_, staggerA = UnitDebuff("player", staggerHeavy) end

			staggerA=Nemo:NilToNumeric( staggerA )
			staggerP=Nemo:NilToNumeric( ( (staggerA/UnitHealthMax("player")) * 100) )
			staggerE=Nemo:NilToNumeric( staggerE )
			staggerT=Nemo:NilToNumeric( staggerA*(staggerE-GetTime()) )
			Nemo.D.P["STAGGER"].percent=staggerP
			Nemo.D.P["STAGGER"].total=staggerT
		end
		if (Nemo.D.PClass == "WARLOCK") then --WARLOCK Metamorphosis tracking
			local lPlayerHasMeta = UnitBuff("player", GetSpellInfo(103958))
			if ( Nemo.D.P["METAMORPHOSIS"].appliedtimestamp == 0 ) then
				--Check if Meta was applied
				if ( lPlayerHasMeta ) then
					Nemo.D.P["METAMORPHOSIS"].appliedtimestamp = GetTime()
				end
			elseif ( not lPlayerHasMeta ) then
				Nemo.D.P["METAMORPHOSIS"].appliedtimestamp = 0
			end	
		end
	end
end
function Nemo:UNIT_HEALTH(_,uId)
	local lTrackedGUID = UnitGUID(uId)
	-- Scenario 1, we only calculate timetodie on enemy units
	if ( UnitIsFriend("player",uId) ) then
		return
	end
	-- Scenario 2, unit is not being tracked yet
	if ( not Nemo.D.P.TU[lTrackedGUID] ) then
		Nemo.D.P.TU[lTrackedGUID] = {}
		Nemo.D.P.TU[lTrackedGUID].lut = GetTime()
	end
	-- Scenario 3, unit is being tracked, but has not initialized the timetodie
	if ( Nemo.D.P.TU[lTrackedGUID] and Nemo.D.P.TU[lTrackedGUID].timetodie == nil ) then
		Nemo.D.P.InitTimeToDie(lTrackedGUID, uId)
		Nemo.D.P.TU[lTrackedGUID].lut = GetTime()
	end
	-- Scenario 4, unit was healed to full health for some reason, initialized the timetodie and return
	if ( Nemo.GetUnitHealth(uId) == UnitHealthMax(uId) ) then
		Nemo.D.P.InitTimeToDie(lTrackedGUID, uId)
		return													-- Unit is full health initialize and return
	end
	-- At this point we have a valid tracked unit with a valid timetodie
	local lCurrentTime	= GetTime()
	Nemo.D.P.TU[lTrackedGUID].timetodie_datapoints	= Nemo.D.P.TU[lTrackedGUID].timetodie_datapoints + 1
	Nemo.D.P.TU[lTrackedGUID].timeSum	 			= Nemo.D.P.TU[lTrackedGUID].timeSum + lCurrentTime										--xsum Ex
	Nemo.D.P.TU[lTrackedGUID].healthSum 			= Nemo.D.P.TU[lTrackedGUID].healthSum + Nemo.GetUnitHealth(uId)							--ysum Ey
	Nemo.D.P.TU[lTrackedGUID].healthMean			= Nemo.D.P.TU[lTrackedGUID].healthMean + (lCurrentTime * Nemo.GetUnitHealth(uId))		--xysum Exy
	Nemo.D.P.TU[lTrackedGUID].timeMean				= Nemo.D.P.TU[lTrackedGUID].timeMean + (lCurrentTime * lCurrentTime)					--xxsum Exx

	local lDiff = (Nemo.D.P.TU[lTrackedGUID].healthSum * Nemo.D.P.TU[lTrackedGUID].timeMean - Nemo.D.P.TU[lTrackedGUID].healthMean * Nemo.D.P.TU[lTrackedGUID].timeSum)
	local ProjectedTimeToDeath = nil
	if ( lDiff > 0 ) then
		ProjectedTimeToDeath = (lDiff) / (Nemo.D.P.TU[lTrackedGUID].healthSum * Nemo.D.P.TU[lTrackedGUID].timeSum - Nemo.D.P.TU[lTrackedGUID].healthMean * Nemo.D.P.TU[lTrackedGUID].timetodie_datapoints) - lCurrentTime  -- projected time
	end
	if ( not ProjectedTimeToDeath or ProjectedTimeToDeath < 0 or Nemo.D.P.TU[lTrackedGUID].timetodie_datapoints < 2) then	-- Not enough data
		return
	else
		ProjectedTimeToDeath = ceil(ProjectedTimeToDeath)
	end
	Nemo.D.P.TU[lTrackedGUID].timetodie = ProjectedTimeToDeath
	-- END Target time to die calculations
end
function Nemo:UNIT_SPELLCAST_START(_,uID,_,_,_,sID)
	if ( sID and uID == "player" ) then
		Nemo.D.lastcastedspellid = sID
		Nemo.SetSpellInfo( sID, 'lastcastedtime', GetTime())
		Nemo:doprint(GetTime().." UNIT_SPELLCAST_START:Player "..tostring(Nemo.D.lastcastedspellid).." "..tostring(Nemo.GetSpellName(sID)))
	end
end
function Nemo:UNIT_SPELLCAST_CHANNEL_START(_,uID,_,_,_,sID)
	if ( sID and uID == "player" ) then
		Nemo.D.lastcastedspellid = sID
		Nemo.SetSpellInfo( sID, 'lastcastedtime', GetTime())
		Nemo:doprint(GetTime().." UNIT_SPELLCAST_CHANNEL_START:Player "..tostring(Nemo.D.lastcastedspellid).." "..tostring(Nemo.GetSpellName(sID)))
	end
end
function Nemo:UNIT_SPELLCAST_SUCCEEDED(_,uID,_,_,_,sID)
	if ( sID and uID == "player" and Nemo.GetSpellCastTime(sID) == 0 ) then				-- Only update last casted time for instant or channeled spells
		Nemo.D.lastcastedspellid = sID
		Nemo.SetSpellInfo( sID, 'lastcastedtime', GetTime())
		Nemo:doprint(GetTime().." UNIT_SPELLCAST_SUCCEEDED:Player "..tostring(Nemo.D.lastcastedspellid).." "..tostring(Nemo.GetSpellName(sID)))
	end
end
function Nemo:UNIT_COMBAT(_,uID,Action,_3,Amount)	
	if ( uID == "player" and Action == "WOUND" and Amount and Amount > 0 ) then
		-- print("UNIT_COMBAT uID="..uID..",Action="..tostring(Action)..",Amount="..tostring(Amount))
		Nemo.D.P["DAMAGE_TAKEN"][Nemo.D.DamageTakenIndex] = { timestamp = GetTime(), amount = Amount }
		if ( Nemo.D.DamageTakenIndex >= Nemo.D.DamageTakenMaxHits ) then
			Nemo.D.DamageTakenIndex = 1
		else
			Nemo.D.DamageTakenIndex = Nemo.D.DamageTakenIndex + 1
		end
	end
end
function Nemo:COMBAT_LOG_EVENT_UNFILTERED(_,_TS,_E,_,sGUID,sName,_,_,dGUID,dName,_,_,sID,_,_,AT)
	--                                      1   2  3 4     5     6 7 8     9     1 1 1   1 1 1
	--                                                                           0 1 2   3 4 5
	--http://www.wowpedia.org/API_COMBAT_LOG_EVENT
	--http://www.wowpedia.org/API_UnitGUID
	local lTimeStamp   = _TS			-- Timestamp
	local lEvent	   = _E 			-- Event
	local lSourceGUID  = sGUID  		-- SourceGUID
	local lSourceName  = sName  		-- SourceName
	local lDestGUID    = dGUID  		-- DestGUID
	local lDestName    = dName  		-- DestName
	local lSpellID 	   = tostring(sID)	-- SpellID
	local lAuraType	   = AT		 		-- AuraType
	local lSourceType  = tonumber(lSourceGUID:sub(5,5), 16) -- [0]="player", [1]="world object", [3]="NPC", [4]="pet", [5]="vehicle"
	local lDestType    = tonumber(lDestGUID:sub(5,5), 16) -- [0]="player", [1]="world object", [3]="NPC", [4]="pet", [5]="vehicle"

	if ( lSourceType ) then lSourceType = Nemo.D.knownGUIDTypes[ (lSourceType % 8) ] or nil end
	if ( lDestType ) then lDestType = Nemo.D.knownGUIDTypes[ (lDestType % 8) ] or nil end

	if ( lEvent == "UNIT_DIED" or lEvent == "UNIT_DESTROYED" ) then		-- Unit death, cleanup any tracked spells and units
		Nemo.D.P.DeleteTS(lSpellID, lDestGUID)
		Nemo.D.P.DeleteTU(lDestGUID)
	end

	if ( not Nemo.D.P.TU[lSourceGUID] and not Nemo:isblank(lSourceName) ) then
		Nemo.D.P.TU[lSourceGUID] = {}							-- Create table for new data player source tracked unit = Nemo.D.P.TU
		Nemo.D.P.TU[lSourceGUID].lut = GetTime()				-- last update time
	end
	if ( not Nemo.D.P.TU[lDestGUID] and not Nemo:isblank(lDestName) ) then
		Nemo.D.P.TU[lDestGUID] = {}								-- Create table for new data player destination tracked unit = Nemo.D.P.TU
		Nemo.D.P.TU[lDestGUID].lut = GetTime()					-- last update time
	end		
	if ( Nemo.GetUnitGUIDIsGroupMember(lSourceGUID)
		and strfind(tostring(lEvent),"DAMAGE")
		and (lDestType == "NPC" or lDestType == "vehicle")		-- NPCs are sometimes vehicles
		) then													-- Only track units for DAMAGE events
		if ( lDestName and lDestGUID and Nemo.D.P.TU[lDestGUID] ) then
			Nemo.D.P.TU[lDestGUID].ldt = GetTime()				-- track hurt NPCs in tracked units last damaged time
			Nemo.D.P.TU[lDestGUID].lut = GetTime()				-- hurt NPCs in tracked units last update time
		end
	end  

	if ( lSpellID and ( lEvent == "SPELL_AURA_REMOVED" or lEvent == "SPELL_AURA_BROKEN" or lEvent == "SPELL_AURA_BROKEN_SPELL" )  ) then
		Nemo.D.TU.RemoveAura( lDestName, lSpellID, lSourceGUID )	-- Battleground Aura remove
	end
	if ( lSourceGUID == UnitGUID("player") and lSpellID and ( lEvent == "SPELL_AURA_REMOVED" or lEvent == "SPELL_AURA_BROKEN" or lEvent == "SPELL_AURA_BROKEN_SPELL" ) ) then
		Nemo.D.P.DeleteTS(lSpellID, lDestGUID)						-- Player Aura removed, cleanup tracked spells
	end
	if ( lSourceGUID == UnitGUID("player") and lSpellID and ( lEvent == "SPELL_MISS" or lEvent == "SPELL_MISSED" ) ) then
		if ( Nemo.D.lastcastedspellid == lSpellID ) then Nemo.D.lastcastedspellid = '' end	-- Reset Last casted spell if the spell missed
	end
	if ( lSpellID and ( lEvent == "SPELL_AURA_APPLIED" or lEvent == "SPELL_AURA_REFRESH" or lEvent == "SPELL_AURA_APPLIED_DOSE")  ) then
		Nemo.D.TU.ApplyAura( lDestName, lDestGUID, lAuraType )		-- Battleground Aura applied tracking
	end

	if ( (lSourceGUID == UnitGUID("player") or lSourceGUID == UnitGUID("pet") ) and lSpellID and 
		( lEvent == "SPELL_AURA_APPLIED"
		or lEvent == "SPELL_AURA_REFRESH"
		or lEvent == "SPELL_AURA_APPLIED_DOSE"
		or lEvent == "SPELL_AURA_APPLIED_DOSE"
		or lEvent == "SPELL_CAST_SUCCESS" -- Agony refresh at 10 stacks only fires a UNIT_SPELLCAST_SUCCESS event
		)
	) then 	-- Player Aura applied tracking
		Nemo:doprint("SetSnapshotData "..lEvent..":Source="..lSourceType.." Dest="..tostring(lDestType).." "..tostring(lSpellID).." "..tostring(Nemo.GetSpellName(lSpellID)).." lAuraType="..tostring(lAuraType) )
		Nemo.SetSnapshotData(lSpellID, lDestGUID, lAuraType )
	end

	if ( lSourceGUID == UnitGUID("player") 	-- Travel Time tracking
		and lSpellID
		and Nemo.D.TRAVELTIME_EVENTS[lEvent]
		and Nemo.D.SpellInfo[lSpellID]
		and Nemo.D.SpellInfo[lSpellID].travelstartspell									-- Start spell exists for this spellid
		) then
		local lStartSpellDB = Nemo.D.SpellInfo[Nemo.D.SpellInfo[lSpellID].travelstartspell]
		if ( lStartSpellDB.lastcastedtime ) then
			lStartSpellDB.traveltime = GetTime()-lStartSpellDB.lastcastedtime
		end
	end

	if ( lSourceGUID == UnitGUID("player") and 	-- DoT and HoT tick tracking
		 lSpellID and
		 lDestGUID and
		 Nemo.D.P.TS[lSpellID..':'..lDestGUID] and
		 ( lEvent == "SPELL_PERIODIC_DAMAGE" or lEvent == "SPELL_PERIODIC_MISSED" or lEvent == "SPELL_PERIODIC_HEAL" or lEvent == "SPELL_DAMAGE" )
		) then
		Nemo.D.P.TS[lSpellID..':'..lDestGUID].lut=GetTime()					-- Refresh last update time to prevent audit from deleting tracked spell
	end
end
function Nemo:ACTIVE_TALENT_GROUP_CHANGED()
	Nemo.UI.SetRotationForCurrentSpec()
end
function Nemo:PLAYER_ENTERING_WORLD()
	Nemo.AButtons.bInitComplete		= false
	Nemo.UI.fAnchor.bEngineCanFire	= true
	if ( Nemo.DB.profile.options.lastloadedversion and GetAddOnMetadata("Nemo", "Version") > Nemo.DB.profile.options.lastloadedversion ) then
		Nemo.UI.UpdateRotations()											  -- Force update new nemo version
	elseif ( not Nemo.DB.profile.options.lastloadedversion ) then
		Nemo.DB.profile.options.lastloadedversion = GetAddOnMetadata("Nemo", "Version")
		Nemo.D.UpdateMode=3 												  -- Do not create or update objects if they exist on import
		Nemo.D.ImportClassDefaultLists()
		Nemo.D.ImportClassDefaultRotations()
		if ( Nemo:isblank(Nemo.DB.profile.options.sr) ) then
			Nemo.UI.SetRotationForCurrentSpec()			  					  -- Select the rotation that matches the current specialization or talentgroup
		else
			Nemo.UI.SelectRotation(Nemo.DB.profile.options.sr, false) 		  -- Select the last loaded rotation
		end
	elseif ( Nemo.DB.profile.options.lastloadedversion and GetAddOnMetadata("Nemo", "Version") == Nemo.DB.profile.options.lastloadedversion ) then
		if ( Nemo:isblank(Nemo.DB.profile.options.sr) ) then
			Nemo.UI.SetRotationForCurrentSpec()			  					  -- Select the rotation that matches the current specialization or talentgroup
		else
			Nemo.UI.SelectRotation(Nemo.DB.profile.options.sr, false) 		  -- Select the last loaded rotation
		end
	end
		
end

function Nemo:ADDON_LOADED()
	if ( LibStub["libs"]["LibActionButton-1.0"] and LibStub["libs"]["LibActionButton-1.0"].activeButtons ) then	-- Add LibActionButton external buttons
		for k, v in pairs( LibStub["libs"]["LibActionButton-1.0"].activeButtons ) do
			-- Nemo:dprint( "LibActionButtonName="..tostring(k:GetName()) )
			Nemo.AButtons.SaveExternalButton(k)
		end
	end
end


function Nemo:PET_BATTLE_OPENING_START()
	Nemo.D.InPetBattle = true
end

function Nemo:PET_BATTLE_CLOSE()
	Nemo.D.InPetBattle = false
	Nemo.UI.fAnchor.bEngineCanFire = true	-- Turn the engine back on
end

function Nemo:PLAYER_TOTEM_UPDATE(_,slot)
	--                            1   2  3    4
	local lSlot = slot -- Totem Slot
	local haveTotem, totemName, startTime, duration = GetTotemInfo(lSlot)
	if ( Nemo.D.class.shaman and haveTotem and Nemo.D.class.shaman.td[lSlot] ) then
		local lOffset = { 3.92699081699,5.49778714378,0.78539816339, 2.35619449019 } -- radian offsets of totem angle drops
		local lFacing = GetPlayerFacing()
		local lPX, lPY = GetPlayerMapPosition("player")
		local lTX, lTY = Nemo.MD:MapArea( Nemo.D.MapName, Nemo.D.MapFloor )
		lTX = (3/lTX)*math.cos(lFacing+lOffset[lSlot]) -- Totems drop 3 yards out / map dimensions
		lTY = (3/lTY)*math.sin(lFacing+lOffset[lSlot])
		lTX = lPX + lTX
		lTY = lPY + lTY
		Nemo.D.class.shaman.td[lSlot].x = lTX
		Nemo.D.class.shaman.td[lSlot].y = lTY
		return
	elseif ( Nemo.D.class.shaman and Nemo.D.class.shaman.td[lSlot] ) then
		Nemo.D.class.shaman.td[lSlot].x = 0
		Nemo.D.class.shaman.td[lSlot].y = 0
	end
end

function Nemo:PLAYER_REGEN_ENABLED()
	Nemo.D.P.EnteredCombatTime = 0
end

function Nemo:PLAYER_REGEN_DISABLED()
	Nemo.D.P.EnteredCombatTime = GetTime()
	Nemo.UI.fAnchor.bEngineCanFire = true	-- Turn the engine back on
end

function Nemo:UPDATE_BATTLEFIELD_SCORE()
	local lTime = GetTime()
	if ( ( lTime - Nemo.D.ScoreLastUpdate ) < Nemo.D.ScoreUpdateInterval ) then return end --Return if we have not waited for ScoreUpdateInterval
	
	local numScore = GetNumBattlefieldScores()
	
	for index = 1, numScore do
		local name, _, _, _, _, faction, _, _, classToken, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(index)
		if not name then break end

		Nemo.D.TU.AddPlayer(name)

	end
end


function Nemo:CHAT_MSG(ChannelName,_E,message)
	-- print("CHAT_MSG on "..ChannelName..",message="..tostring(message))
	for triggertext,v in pairs(Nemo.D.P.CHAT_TRIGGERS) do
		if ( strfind(strlower(message), strlower(triggertext)) and strlower(v.channelname) == strlower(ChannelName) ) then
			v.lut = GetTime()
		end
	end
end
function Nemo:CHAT_MSG_CHANNEL(_E,message,_sender,_,_,_,_,_,_,ChannelName)
	-- print("CHAT_MSG_CHANNEL on "..ChannelName)
	for triggertext,v in pairs(Nemo.D.P.CHAT_TRIGGERS) do
		if ( strfind(strlower(message), strlower(triggertext)) and strlower(v.channelname) == strlower(ChannelName) ) then
			v.lut = GetTime()
		end
	end
end
