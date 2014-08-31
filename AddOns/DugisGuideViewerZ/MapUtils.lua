local mapdata = LibStub("LibMapData-1.0-Dugi")
local astrolabe = DongleStub("Astrolabe-1.0-Dugi")
local DGV = DugisGuideViewer
DGV.astrolabe = astrolabe
DGV.mapdata = mapdata
local GetCreateTable, InitTable = DGV.GetCreateTable, DGV.InitTable

--/run DGV:ShowMapData(mapId, ...)
function DGV:ShowMapData(mapId, ...)
	local tbl = {}
	local mapData = {}
	tbl[mapId] = mapData
	local numFloors = select("#", ...)
	SetMapByID(mapId)
	local _, TLx, TLy, BRx, BRy = GetCurrentMapZone();
	if ( TLx and TLy and BRx and BRy ) then
		if not ( TLx < BRx ) then
			TLx = -TLx;
			BRx = -BRx;
		end
		if not ( TLy < BRy) then
			TLy = -TLy;
			BRy = -BRy;
		end
		mapData.width = BRx - TLx
		mapData.height = BRy - TLy
		mapData.xOffset = TLx
		mapData.yOffset = TLy
	end
	if ( numFloors > 0 ) then
		for i = 1, numFloors do
			local f = select(i, ...)
			SetDungeonMapLevel(f);
			local _, TLx, TLy, BRx, BRy = GetCurrentMapDungeonLevel();
			if ( TLx and TLy and BRx and BRy ) then
				mapData[f] = {};
				if not ( TLx < BRx ) then
					TLx = -TLx;
					BRx = -BRx;
				end
				if not ( TLy < BRy) then
					TLy = -TLy;
					BRy = -BRy;
				end
				mapData[f].width = BRx - TLx
				mapData[f].height = BRy - TLy
				mapData[f].xOffset = TLx
				mapData[f].yOffset = TLy
			end
		end
	end
	DGV:DebugFormat("ShowMapData", "tbl", tbl)
end

function DGV:GetMapNameFromID(mapId)
	return mapdata:MapLocalize(mapId)
end

function DGV:GetMapIDFromName(mapName)
	return mapdata:MapAreaId(mapName)
end

--[[function DGV:InitMapping( )
	DGV:initAnts()
	DGV.DugisArrow:initArrow()
end]]

function DGV:TranslateWorldMapPosition(map, floor, x, y, M, F)
	return astrolabe:TranslateWorldMapPosition(map, floor, x, y, M, F)
end

function DGV:PlaceIconOnMinimap( icon, mapID, mapFloor, x, y)
	if x and y and mapID then
		astrolabe:PlaceIconOnMinimap(icon, mapID, mapFloor, x, y)
	else
		DebugPrint("Error: unable to place icon")
	end
end

function DGV:GetMapID(ContToUse, ZoneToUse)
	return astrolabe:GetMapID(ContToUse, ZoneToUse)
end

function DGV:PlaceIconOnWorldMap( frame, icon, mapID, mapFloor, x, y )		
	if x and y and mapID then
		astrolabe:PlaceIconOnWorldMap(frame, icon, mapID, mapFloor, x, y )
	else
		DebugPrint("Error: unable to place waypoint ")
	end
	
	DGV:CheckForArrowChange()
	
	if DGV.WrongInstanceFloor --[[or not DGV.WaypointsShown]] then
		--DebugPrint("####Hide icon: WrongInstanceFloor")
		icon.icon:Hide()
	else
		icon.icon:Show()
	end
end

function DGV:ComputeDistance( m1, f1, x1, y1, m2, f2, x2, y2 )
	
	return astrolabe:ComputeDistance( m1, f1, x1, y1, m2, f2, x2, y2 )
end

function DGV:IsValidDistance( m, f, x, y )
	local dist, dx, dy = DGV:GetDistanceFromPlayer(m, f, x, y)
	if dist and dx and dy then
		return true
	end
end

function DGV:GetDistanceFromPlayer(m, f, x, y)
	local pmap, pfloor, px, py = DGV:GetPlayerPosition()
	return astrolabe:ComputeDistance(pmap, pfloor, px, py, m, f, x/100, y/100) 
end

function DGV:WorldMapFrameOnShow()
	DGV:OnMapChangeUpdateArrow( )
end
WorldMapFrame:HookScript( "OnShow", DGV.WorldMapFrameOnShow )


function DGV:GetUnitPosition( unit, noMapChange )
	return astrolabe:GetUnitPosition( unit, noMapChange )
end


function DGV:GetPlayerPosition()

    local x, y = GetPlayerMapPosition("player")
    if x and y and x > 0 and y > 0 then
	local map, floor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
        floor = floor or self:GetDefaultFloor(map)
        return map, floor, x, y
    end

    if WorldMapFrame:IsVisible() then
        return
    end

    SetMapToCurrentZone()
    local x, y = GetPlayerMapPosition("player")

    if x <= 0 and y <= 0 then
        return
    end

    local map, floor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
    floor = floor or self:GetDefaultFloor(map)
    return map, floor, x, y
end

function DGV:GetPlayerMapPositionDisruptive()
	local orig_mapId, orig_level = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
	SetMapToCurrentZone()
	local DugisArrow = DGV.Modules.DugisArrow
	local m1, f1, x1, y1 =  DGV.astrolabe:GetUnitPosition("player")
	if not m1 or m1==0 then
		m1, f1, x1, y1 = 
			DugisArrow.map, DugisArrow.floor,
			DugisArrow.pos_x, DugisArrow.pos_y
	end
	if orig_mapId~=m1 or orig_level~=f1 then
		SetMapByID(orig_mapId)
		SetDungeonMapLevel(orig_level)
	end
	return m1, f1, x1, y1
end

function DGV:GetDefaultFloor(map)
    local floors = astrolabe:GetNumFloors(map) == 0 and 0 or 1
    return floors == 0 and 0 or 1
end

--Go backwards mapid -> cz for carbonite
local czLookup = {}
do
	local continents = GetCreateTable(GetMapContinents())
	local zones = GetCreateTable()
	local c, z
	for c in continents:IPairs() do
		wipe(zones)
		InitTable(zones)
		zones:InsertList(GetMapZones(c))
		SetMapZoom(c, 0)
		zones[0] = GetCurrentMapAreaID()
		for z, name in ipairs(zones) do
			SetMapZoom(c, z)
			local mapId = GetCurrentMapAreaID()
			zones[z] = mapId
			czLookup[mapId] = {c, z, name}
		end
	end
	continents:Pool()
	zones:Pool()
end

function DGV:GetZoneIdByName(name)
	if type(name)~="string" then return nil end
	name = name:lower():trim()
	for id, tbl in pairs(czLookup) do
		if tbl[3]:lower():trim()==name then
			return id
		end
	end
end

local function getCZ(mapId)
	local c, z 
	if czLookup[mapId] then 
		c, z = unpack(czLookup[mapId])
	end
	return c or 0, z or 0
end

function DGV:GetCZByMapId(mapId)
	return getCZ(mapId)
end

function DGV.ContinentMapIterator(invariant, control)
	while true do
		control, tbl = next(czLookup, control)
		if not control then return end
		if tbl[1]==invariant then
			return control
		end
	end
end