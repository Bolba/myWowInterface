local DGV = DugisGuideViewer
local QuestPOI = DGV:RegisterModule("QuestPOI")
QuestPOI.essential = true

local QuestPOIFrame

local astrolabe = DongleStub("Astrolabe-1.0-Dugi")
local lastWaypoint
local scanning 

function QuestPOI:Initialize()
	local L = DugisLocals
	
	function DGV:InitializeQuestPOI()
		DGV:UpdateMiniBlobs()
	end

	function DGV:GetPOIByQID(qid)
		return DGV:IterateQuestPOIs(function(poi)
			local id = poi.questId or (poi.quest and poi.quest.questId)
			if id==qid then return poi end
		end, "WorldMapPOIFrame")
	end

	--WatchFrameLines
	--WorldMapPOIFrame
	function DGV:IterateQuestPOIs(delegate, parentName, numericPoiType)
		if not parentName then parentName="WorldMapPOIFrame" end
		if not numericPoiType then numericPoiType=QUEST_POI_NUMERIC end
		local numEntries = QuestMapUpdateAllQuests()
		local numEntries = QuestMapUpdateAllQuests()
		local breakVal = false
		if _G["poi"..parentName.."_Swap"] then
			breakVal = delegate(_G["poi"..parentName.."_Swap"])
		end
		if breakVal then return breakVal end
		local questCount = 0
		local numCompletedQuests = 0
		for i = 1, numEntries do
			local questId, questLogIndex = QuestPOIGetQuestIDByVisibleIndex(i);
		if ( questLogIndex and questLogIndex > 0 ) then
				questCount = questCount + 1;
				local isComplete = select(7, GetQuestLogTitle(questLogIndex))
				if ( isComplete ) then
					numCompletedQuests = numCompletedQuests + 1;
				end
				local poiButton = _G["poi"..parentName..tostring(numericPoiType).."_"..tostring(questCount - numCompletedQuests)];
				if poiButton then
					breakVal = delegate(poiButton)
					if breakVal then return breakVal end
				end
			end
		end
		return false
	end
	
	local function OnClick(self, button)
		if QuestPOI.loaded and DGV:UserSetting(DGV_MANUALWAYPOINT) then
			local qid = self.questId
			DGV.MapPreview.ForceMapPreview =
				(not WorldMapFrame:IsShown() or DGV.MapPreview:IsAnimating())
				and DGV:GetDB(DGV_MAPPREVIEWDURATION)~=0 and not DGV.carboniteloaded
			--DGV:DebugFormat("WatchFrameQuestPOI_OnClick", "forceMapPreview", DGV.MapPreview.ForceMapPreview)

			--local poi = DGV:GetPOIByQID(qid)
			--DGV:DebugFormat("OnClick", "QuestPOI.loaded", QuestPOI.loaded, "poi", poi, "qid", qid, "self", self);
			if self then
				DGV.DugisArrow:QuestPOIWaypoint(self, true)
			end
			if not DGV:IsPlayerAtBlizzardDestination() then DGV.MapPreview:FadeInMap() end
		end
	end
	
	local existingButtons = {}
	local function SetOnClick(parentName, buttonType, buttonIndex, questId)
		local buttonName = "poi"..parentName..buttonType.."_"..buttonIndex;
		if tContains(existingButtons, buttonName) then return end
		tinsert(existingButtons, buttonName)
		local poiButton = _G[buttonName];
		local swapButton;
		
		if poiButton then
			if parentName == "WatchFrameLines" then
				poiButton:HookScript("OnClick", OnClick)
			elseif parentName == "WorldMapPOIFrame" then
				poiButton:HookScript("OnClick", function(...) 
					DGV.Modules.DugisArrow:WorldMapQuestPOI_OnClick(...)
				end)
			end
		end
	end
	
	hooksecurefunc("QuestPOI_DisplayButton", SetOnClick)
	
	function QuestPOI:ObjectivesChanged()
		if not DGV:GetDB(DGV_WAYPOINTSON) or 
		DGV.chardb.EssentialsMode ~= 1 or  
		not DugisGuideViewer.GuideOn() or
		(DGV.Tomtomloaded and TomTom.profile.poi.setClosest == true) or
		(DGV.Modules.DugisArrow:getNumWaypoints() > 0 and not DGV.Modules.DugisArrow:GetFirstWaypointQuestId()) then
			if lastWaypoint then lastWaypoint = nil end
			return
		end   
	
		if scanning then
			return
		else
			scanning = true
		end
	
		local map, floor = GetCurrentMapAreaID()
		local floors = astrolabe:GetNumFloors(map)
		floor = floor and floor or (floors == 0 and 0 or 1)
	
		local px, py = GetPlayerMapPosition("player")
	
		if not px or not py or px <= 0 or py <= 0 then
			scanning = false
			return
		end
	
		local cvar = GetCVarBool("questPOI")
		SetCVar("questPOI", 1)
	
		local closest
		local closestdist = math.huge
	
		QuestPOIUpdateIcons()


	
		local watchIndex = 1
		while true do

			local questIndex = GetQuestIndexForWatch(watchIndex)
	
			if not questIndex then
				break			
			end


	
			local qid = select(9, GetQuestLogTitle(questIndex))
			local completed, x, y, objective = QuestPOIGetIconInfo(qid)
	
			if x and y then
				local dist, xd, yd = astrolabe:ComputeDistance(map, floor, px, py, map, floor, x, y)
				if dist < closestdist then
					closest = watchIndex
					closestdist = dist
				end
			end
			watchIndex = watchIndex + 1
		end
	
		if closest then
			local questIndex = GetQuestIndexForWatch(closest)
			local title = GetQuestLogTitle(questIndex)
			local qid = select(9, GetQuestLogTitle(questIndex))
			local completed, x, y, objective = QuestPOIGetIconInfo(qid)	
	
			if completed then
				title = L["Turn in"].." |cfff0c502'"..title.."'|r"
			else 
				title = "|cfff0c502"..title.."|r"
			end
			
			if lastWaypoint ~= x and x then
				DGV:RemoveAllWaypoints()
				DGV:AddCustomWaypoint(x, y, title, map, floor, qid)		
				lastWaypoint = x
				DGV:SafeSetMapQuestId(qid) 
				DGV:UpdateMiniBlobs()
			end
		else
			DGV:RemoveAllWaypoints()
			lastWaypoint = nil
		end
	
		SetCVar("questPOI", cvar and 1 or 0)
		scanning = false
	end
	
	if not ObjectivesChangedDelayFrame then
		ObjectivesChangedDelayFrame = CreateFrame("Frame")
		ObjectivesChangedDelayFrame:Hide() 
	end 
	
	function QuestPOI:ObjectivesChangedDelay(delay, func) 
		if ObjectivesChangedDelayFrame:IsShown() then return end
		ObjectivesChangedDelayFrame.func = func
		ObjectivesChangedDelayFrame.delay = delay 
		ObjectivesChangedDelayFrame:Show()
	end
	
	ObjectivesChangedDelayFrame:SetScript("OnUpdate", function(self, elapsed) 
		self.delay = self.delay - elapsed 
		if self.delay <= 0 then  
			self:Hide() 
			QuestPOI:ObjectivesChanged()
		end
	end)	
	
	function QuestPOI:Load()
		DGV:InitializeQuestPOI()
	end

	function QuestPOI:Unload()
	end
end