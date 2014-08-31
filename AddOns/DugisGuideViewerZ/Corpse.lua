local DGV = DugisGuideViewer
if not DGV then return end

local Corpse = DGV:RegisterModule("Corpse")
Corpse.essential = true

local L = DugisLocals

function Corpse:Initialize()

	local function PlayerEventPredicate()
		local inInstance, _ = IsInInstance()
		if DGV.carboniteloaded or DGV.tomtomloaded or (not DGV.GuideOn()) or inInstance then return end
		return DGV:UserSetting(DGV_SHOWCORPSEARROW)
	end

	local playerAliveReaction, playerDeadReaction, playerUnghostReaction
	function Corpse:Load()
	
		local function GetCorpsePositionDisruptive()
			local orig_mapId, orig_level = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
			SetMapToCurrentZone()
			local corpseX, corpseY = GetCorpseMapPosition()
			local m1, f1, x1, y1 =  DGV.astrolabe:GetUnitPosition("player")
			if corpseX and corpseX~=0 then
				if orig_mapId~=m1 or orig_level~=f1 then
					SetMapByID(orig_mapId)
					SetDungeonMapLevel(orig_level)
				end
				return m1, f1, corpseX, corpseY
			end
			local c = DGV:GetCZByMapId(GetCurrentMapAreaID())
			if c then
				for mapID in DGV.ContinentMapIterator,c do
					SetMapByID(mapID)
					corpseX, corpseY = GetCorpseMapPosition()
					if corpseX and corpseX~=0 then
						local corpseFloor = DGV:GetDefaultFloor(mapID)
						SetMapByID(orig_mapId)
						SetDungeonMapLevel(orig_level)
						return mapID, corpseFloor, corpseX, corpseY
					end
				end
			end
			SetMapByID(orig_mapId)
			SetDungeonMapLevel(orig_level)
		end
		
		function Corpse:GetPosition()
			if not UnitIsDeadOrGhost("player") then return end
			local corpseX, corpseY = GetCorpseMapPosition()
			if not corpseX or corpseX==0 then
				return GetCorpsePositionDisruptive()
			end
			local m = GetCurrentMapAreaID()
			local f = DGV:GetDefaultFloor(m)
			return m, f, corpseX, corpseY
		end
	
		playerAliveReaction = DGV.RegisterReaction("PLAYER_ALIVE"):WithPredicate(PlayerEventPredicate):WithAction(
			function()
				DebugPrint("PLAYER_ALIVE")
				DGV.DugisArrow:Show()
				local corpseX, corpseY = GetCorpseMapPosition()
				DebugPrint("corpseX:"..corpseX.." corpseY:"..corpseY)
			end)
			
		playerDeadReaction = DGV.RegisterReaction("PLAYER_DEAD"):WithPredicate(PlayerEventPredicate):WithAction(
			function()
				DebugPrint("PLAYER_DEAD")
				DGV:RemoveAllWaypoints()
				
				local desc = L["My Corpse"]
				local m, f, x, y = DGV:GetPlayerPosition()
				DebugPrint("corpse position:".."M:"..m.." f:"..f.." x"..x.." y"..y)

				DGV.DugisArrow:AddWaypoint( m, f, x*100, y*100, desc)
				DGV.DugisArrow:setArrow( m, f, x*100, y*100, desc )
			end)
			
		playerUnghostReaction = DGV.RegisterReaction("PLAYER_UNGHOST"):WithPredicate(PlayerEventPredicate):WithAction(
			function()
				DebugPrint("PLAYER_UNGHOST")
				DGV:RemoveAllWaypoints()
				if DGV.chardb.EssentialsMode ~= 1 then 
					DGV:MapCurrentObjective()
				end 
			end)
	end
	
	function Corpse:Unload()
		playerAliveReaction:Dispose()
		playerDeadReaction:Dispose()
		playerUnghostReaction:Dispose()
	end
end

