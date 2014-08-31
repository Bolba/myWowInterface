local DGV = DugisGuideViewer
local DGU
if not DGV then return end

local Guides = DGV:RegisterModule("Guides")
local _
local BF = LibStub("LibBabble-Faction-3.0")
local BFR = BF:GetReverseLookupTable()

function Guides:Initialize()
	DGU = DugisGuideUser
	local Main = DugisMain

	local GetQuestDifficultyColor = GetQuestDifficultyColor
	local visualRows
	
	local CurrentAction
	local CurrentQuestName
	local JustTurnedInQID = -1 --A quest that has just been turned in has its isComplete status indeterminate in quest log
	local CurrentTag
	
	local i
	local L = DugisLocals
	local crowheight
	
	local SCROLL_BACKGROUND = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\bg_home.tga"
	local SCROLLESS_BACKGROUND = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\bg_currentguide.tga"
	
	local GetCurrentGuideTypeTabInfo
	
	local function GetCurrentGuideLeftScrollFrame()
		local tabInfo = GetCurrentGuideTypeTabInfo()
		if tabInfo and tabInfo.RightFrame.firstHeading then
			tabInfo.RightFrame.firstHeading:SetPoint("TOPLEFT", tabInfo.RightFrame.panel, "BOTTOMLEFT", -10, -8)
			tabInfo.RightFrame.panel:Show()
			DugisPreloadButton:ClearAllPoints()
			DugisPreloadButton:SetParent(tabInfo.RightFrame)
			DugisPreloadButton:SetPoint("TOPRIGHT", 0, -13)
			DugisPreloadButton:Show()
		end
		return tabInfo and tabInfo.RightFrame
	end
	
	local function GetCurrentGuideLeftShouldScroll()
		local tabInfo = GetCurrentGuideTypeTabInfo()
		return tabInfo and tabInfo:RightShouldScroll()
	end
	
	local function IterateCurrentHolidays(invariant, control)
		if not control then control = 0 end
		control = control + 1
		Calendar_LoadUI()
		local _, presentMonth, presentDay, presentYear = CalendarGetDate()
		CalendarSetAbsMonth(presentMonth, presentYear)
		local numEvents = CalendarGetNumDayEvents(0, presentDay)
		if control > numEvents then return end
		local _, _, _, calendarType = CalendarGetDayEvent(0, presentDay, control)
		if calendarType=="HOLIDAY" then
			return control, CalendarGetHolidayInfo(0, presentDay, control)
		end
	end
	
	local function SetCurrentEventIcon(icon)
		local textureBase
		for index, _, _, tex in IterateCurrentHolidays do
			if tex and tex~="" then 
				textureBase = tex
				break
			end
		end
		if not textureBase then
			icon:SetTexture("Interface\\Icons\\achievement_bg_masterofallbgs")
		else
			icon:SetTexture("Interface\\Calendar\\Holidays\\"..textureBase.."Start")
			icon:SetTexCoord(0, 0.7109375, 0, 0.7109375)
		end
	end
	
	local tabs = {
		[1] = {text = "Home",		title = "Home",					LeftFrame = DGVHomeFrame, 						RightFrame = DGVSearchFrame, rightShouldScroll = true},
		[2] = {text = "Current Guide",								LeftFrame = GetCurrentGuideLeftScrollFrame, 	RightFrame = DGVCurrentGuideFrame,	rightShouldScroll = true, leftShouldScroll = GetCurrentGuideLeftShouldScroll},
		[3] = {text = "Settings",	title = "Settings for Dugi Guides", 											RightFrame = DGVScrollFrame3},
		[11] = {text = "Help",		title = "Help",									LeftFrame = DGVHomeFrame,		RightFrame = DGVScrollFrame11,	icon="Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\help-i"},
		[5] = {text = "Leveling", 	title = "Leveling Guides", 	guidetype = "L",	LeftFrame = DGVHomeFrame, 		RightFrame = DGVScrollFrame4,	icon="Interface\\Icons\\Achievement_Level_90", rightShouldScroll = true},
		[6] = {text = "Dungeons", 	title = "Dungeon Guides", 	guidetype = "I",	LeftFrame = DGVHomeFrame,		RightFrame = DGVScrollFrame5,	icon="Interface\\Icons\\Achievement_Dungeon_GloryoftheHERO", rightShouldScroll = true},
		[7] = {text = "Dailies",	title = "Daily Guides",	guidetype = "D",		LeftFrame = DGVHomeFrame,		RightFrame = DGVScrollFrame6,	icon="Interface\\Icons\\Achievement_general_25kdailyquests", rightShouldScroll = true},
		[8] = {text = "Events",		title = "Event Guides", 	guidetype = "E",	LeftFrame = DGVHomeFrame,		RightFrame = DGVScrollFrame7,	icon=SetCurrentEventIcon, rightShouldScroll = true},
		[9] = {text = "Achievements",	title = "Achievement Guides", guidetype = "A",LeftFrame = DGVHomeFrame,		RightFrame = DGVScrollFrame8,	icon="Interface\\Icons\\ACHIEVEMENT_GUILDPERK_HONORABLEMENTION", rightShouldScroll = true},
		[10] = {text = "Professions", 	title = "Profession Guides", guidetype = "P",LeftFrame = DGVHomeFrame,		RightFrame = DGVScrollFrame9,	icon="Interface\\Icons\\INV_Scroll_11", rightShouldScroll = true},
		[4] = {text = "Suggest Guides", title = "Suggested Guides", 				LeftFrame = DGVHomeFrame, 		RightFrame = DGVScrollFrame10, 	icon="Interface\\Icons\\INV_Misc_Orb_01", rightShouldScroll = true},
	}
	local SEARCH_TAB, SUGGEST_TAB = 1,4
	local currentGuideTabInfo = tabs[2]
	
	local function AccessValue(valueOrAccessor)
		if type(valueOrAccessor)=="function" then 
			return valueOrAccessor() 
		else return valueOrAccessor end
	end
	
	local function TabInfoRightShouldScroll(self)
		return self.rightShouldScroll
	end
	
	local function TabInfoLeftShouldScroll(self)
		return AccessValue(self.leftShouldScroll)
	end
	
	local activeTabInfo, PopulateSuggestedGuides
	local function TabInfoActivate(self)
		if activeTabInfo==self then return end
		if activeTabInfo then
			if activeTabInfo:RightShouldScroll() then
				activeTabInfo.rightScrollHistory = Main.rightScroll.bar:GetValue()
			end
			if activeTabInfo.LeftFrame then
				local leftFrame = AccessValue(activeTabInfo.LeftFrame)
				if leftFrame then
					leftFrame:Hide()
				end
			end
			activeTabInfo.RightFrame:Hide()
			DugisReloadButton:Hide() DugisResetButton:Hide() DugisPercentButton:Hide()
		end
		activeTabInfo = self
		
		Main.title:SetText(self.title)
		Main.title:Show()
		
		if self.text ~= "Home" then
			DGV.Search:Hide()
			DGV.Search:ClearText()
		end
		
		if self.text == "Suggest Guides" then
			PopulateSuggestedGuides()
		end

		if self.text == "Current Guide" then	
			DugisReloadButton:Show() DugisResetButton:Show() DugisPercentButton:Show() 
			DGV.Search:Show()
			DGV:TabTextRefresh()
			Main.rightScroll:SetPoint("BOTTOM", Main.rightFrameHost, 0, 30)
		end
		
		if self.guidetype then
			DugisPreloadButton:SetParent(Main)
			DugisPreloadButton:ClearAllPoints()
			DugisPreloadButton:SetPoint("BOTTOMRIGHT", Main.rightFrameHost, 0, 3)
			DugisPreloadButton:Show()
			Main.rightScroll:SetPoint("BOTTOM", Main.rightFrameHost, 0, 30)
		end
		
		if self.text ~= "Current Guide" and not self.guidetype then
			Main.rightScroll:SetPoint("BOTTOM", Main.rightFrameHost)
			DugisPreloadButton:Hide()
		end
		
		self.RightFrame:Show()
		if self:RightShouldScroll() then
			Main.rightScroll:SetScrollChild(self.RightFrame)
			self.RightFrame:SetWidth(400)
			Main.rightScroll.bar:SetValue(self.rightScrollHistory or 1)
			Main.rightScroll:Show()
		else
			Main.rightScroll:Hide()
			self.RightFrame:SetAllPoints(Main.rightFrameHost)
		end
		
		Main.leftScroll:Hide()
		local leftFrame = AccessValue(self.LeftFrame)
		if leftFrame then
			leftFrame:Show()
			if self:LeftShouldScroll() then
				DugisMainBorder.bg:SetTexture(SCROLL_BACKGROUND)
				Main.leftScroll:SetScrollChild(leftFrame)
				leftFrame:SetWidth(350)
				Main.leftScroll.bar:SetValue(self.leftScrollHistory or 1)
				Main.leftScroll:Show()
				
				if self.text=="Current Guide" then
					self.leftScrollMax = GetCurrentGuideTypeTabInfo().rightScrollMax
				end
			else
				DugisMainBorder.bg:SetTexture(SCROLLESS_BACKGROUND)
				leftFrame:SetAllPoints(Main.leftFrameHost)
			end
			Main.leftFrameHost:Show()
			Main.rightFrameHost:ClearAllPoints()
			Main.rightFrameHost:SetPoint("TOPLEFT", 375, -44)
			Main.rightFrameHost:SetPoint("BOTTOMRIGHT", -25, 0)
			
			if leftFrame==DGVHomeFrame then
				Main.title:Hide()
				DGV.Search:ShowGlobal()
			end
		else
			Main.leftFrameHost:Hide()
			DugisMainBorder.bg:SetTexture(SCROLLESS_BACKGROUND)
			Main.rightFrameHost:ClearAllPoints()
			Main.rightFrameHost:SetPoint("TOPLEFT", 0, -44)
			Main.rightFrameHost:SetPoint("BOTTOMRIGHT", -25, 0)
		end
		if self.RightFrame.panel and self.RightFrame.firstHeading then
			self.RightFrame.firstHeading:SetPoint("TOPLEFT", self.RightFrame, "TOPLEFT", 0, -5)
			self.RightFrame.panel:Hide()
		end
	end
	
	for _,tab in ipairs(tabs) do
		tab.Activate = TabInfoActivate
		tab.RightShouldScroll = TabInfoRightShouldScroll
		tab.LeftShouldScroll = TabInfoLeftShouldScroll
	end
	
	GetCurrentGuideTypeTabInfo = function()
		if DGV:isValidGuide(CurrentTitle) == true then
			local guideType = DGV.gtype[CurrentTitle]
			for _,tabInfo in ipairs(tabs) do
				if tabInfo.guidetype==guideType then
					return tabInfo
				end
			end
		end
	end
	
	
	function DGV:GetLastGuideNumRows()
		--return LastGuideNumRows
		return #visualRows
	end
	
	local suspendViewFrameUpdate = false
	local function SuspendViewFrameUpdate()
		suspendViewFrameUpdate = true
	end

	local function ResumeViewFrameUpdate()
		suspendViewFrameUpdate = false
		DGV:ViewFrameUpdate()
	end

	function DGV:ReloadButtonOnClick()
		DGV:DisplayViewTab(CurrentTitle)
	end

	function DGV:ResetButtonOnClick()
		SuspendViewFrameUpdate()
		local i
		for i = 1, #visualRows do
			if DGV:GetQuestState(i) == "X" or (DGV:GetQuestState(i) == "C") then
				DGV:ClrChk(i)	
			end
		end
		ResumeViewFrameUpdate()
		DGV:MoveToNextQuest(1)
		DGV:AutoScroll(0)
	end

	function DGV:GetQuestState(index, guideName)
		return DGU.QuestState[string.format("%s:%d", guideName or CurrentTitle, index)]
	end

	function DGV:SetQuestState(index, setting)
		--self:DebugFormat("SetQuestState", "index", index, "setting", setting, "stack", debugstack(2))
		DGU.QuestState[CurrentTitle..':'..index] = setting
		--Update visual state of potetial PRE tagged rows
		DGV:ViewFrameUpdate()
	end

	function DGV:GetQIDByLogIndex(lindex)
		return select(9, GetQuestLogTitle(lindex))
	end

	function DGV:GetGuideIndexByQID(qid, action)
		local i
		for i=1, #visualRows do
			if DGV.qid[i] == qid and (not action or DGV.actions[i] == action) then return i end
		end	
	 end

	function DGV:CompleteQID(qid, state)
		local i
		for i = 1, #visualRows do
			if DGV.qid[i] == qid and DGV.actions[i] == state then
				DGV:SetChkToComplete(i)
			end
		end
	end

	function printAllquests(name)
		local i
		local numq, _ = GetNumQuestLogEntries()
		for i=1,numq do
			local title, _, _, _, isHeader = GetQuestLogTitle(i)
			if not isHeader then
				DebugPrint("Quest title"..title)
			end
		end
	end

	function DGV:IsCompleteLootQO(calledfrom, itemid, guideIndex)
		--Loot completion
		if not guideIndex then guideIndex = DGU.CurrentQuestIndex end
		local lootitem, lootqty 	= DGV:ReturnTag("L", guideIndex)
		local optional 				= DGV:ReturnTag("O", guideIndex)			
		local inlog 				= DGV:GetQuestLogIndexByQID(DGV.qid[guideIndex])
		local flag = 0

		if calledfrom == "CMSG" then
			if (lootitem and (GetItemCount(lootitem) + 1) >= lootqty) and lootitem == itemid then  
				if (optional and inlog) or (not optional) then
				flag = 1
				end
			end
		elseif calledfrom == "QLU" then
			if lootitem and GetItemCount(lootitem) >= lootqty then  
				if (optional and inlog) or (not optional) then
				flag = 1
				end
			end
		end
		
		if flag == 1 then
			return true
		end
	end

	function DGV:QuestPartComplete(guideIndex)
		local questpart = self:ReturnTag("QIDP", guideIndex)
		if questpart then
			local qid 				=  DGV.qid[guideIndex]
			local logidx 			=  DGV:GetQuestLogIndexByQID(qid)
			local desc, _, done 	=  GetQuestLogLeaderBoard(tonumber(questpart), logidx)		
			if done and logidx then 
				return true
			end
		end
	end
	
	--Update the look of the frame on QLU
	function DGV:ViewFrameUpdate()
		if suspendViewFrameUpdate or not Main:IsVisible() then return end
		local i, qid
		for i, qid in ipairs(DGV.actions) do
			DGV:SetQuestColor(i)
			DGV:SetQuestText(i)
			visualRows[i].Button:SetNormalTexture(DGV:getIcon(DGV.actions[i], i ))		
		end
	end

	function DGV:UpdatePlayerLevels(playerLevel)
		local i
		playerLevel = playerLevel or UnitLevel("player")
		if DGV:isValidGuide(CurrentTitle) == true then
			local guidesize = DGV:GetLastGuideNumRows()	
			for i=1, guidesize do		
				local reqlvl = self:ReturnTag("PL", i)	
				if reqlvl and reqlvl <= playerLevel and DGV:GetQuestState(i) ~= "C" and not strmatch(self.actions[i], "[f]") then
					self:SetChkToComplete(i)
					if i == DGU.CurrentQuestIndex then self:MoveToNextQuest() end
				end
			end
		end
	end
	
	local function EvaluateMAP(map)
		if map then 
			if DGV:GetPlayerMapPositionDisruptive() == tonumber(map) then return true end
		end
	end
	
	local function EvaluatePHA(pha)
		if GetCurrentMapAreaID() == 928 and NUM_WORLDMAP_POIS == 0 then 
			WorldMapFrame_Update()
			if NUM_WORLDMAP_POIS == 0 then return true end
		end
		if GetCurrentMapAreaID() == 928 then 			
			local lowest = 6
			for i=1, NUM_WORLDMAP_POIS do
				local _, _, _, _, _, _, _, _, _, poiID = GetMapLandmarkInfo(i)				
				if WorldMap_IsSpecialPOI(poiID) then 
					if SPECIAL_POI_INFO[poiID].phase < lowest then 
						lowest = SPECIAL_POI_INFO[poiID].phase
					end
				end
			end
			if lowest ~= 6 then
				return lowest >= tonumber(pha)
			end
		end
	end
	
	local function EvaluateOID(oid)
		local index = DGV:GetGuideIndexByQID(tonumber(oid), "A")
		return index and DGV:GetQuestState(index) == "C"
	end		

	local function EvaluatePRE(pre)
		local index = DGV:GetGuideIndexByQID(tonumber(pre), "T")
		--if index then DebugPrint("Debug EvaluatePRE: pre="..tonumber(pre).." DGV:GetQuestState(index)="..DGV:GetQuestState(index)) end
		return index and DGV:GetQuestState(index) == "C"
	end

	local function EvaluateREP(factionId, standingRequirement)
		local name, _, standingID = GetFactionInfoByID(tonumber(factionId))
		--DebugPrint("Debug EvaluateREP: standingID="..tostring(standingID).." name="..tostring(name).." factionId="..tonumber(factionId))
		return standingID >= tonumber(standingRequirement)
	end

	local function EvaluateFS(factionId, standingRequirement)
		local name, _, _, _, _, barValue = GetFactionInfoByID(tonumber(factionId))
		return barValue >= tonumber(standingRequirement)
	end

	local function GetVisualRow(i, row)
		if row then return _G[row..i] else return visualRows[i] end
	end

	local function CheckInitOpt(i, row)
		local Row = GetVisualRow(i, row)
		if Row.Opt.text==nil then
			local optional 		= DGV:ReturnTag("O", i)
			local pre			= DGV:ReturnTag("PRE", i)
			local pha			= DGV:ReturnTag("PHA", i)			
			local rep, standing	= DGV:ReturnTag("REP", i)
			local friend, level	= DGV:ReturnTag("FS", i)
			local prof, _		= DGV:ReturnTag("OP", i)
			if optional then
				Row.Opt.text = string.format(" (%s)", L.Optional)
				Row.Opt.optional = true
			elseif pre then
				Row.Opt.text = string.format(" (%s)", L["Pre-quest required"])
				Row.Opt.pre = tonumber(pre)
			elseif pha then
				Row.Opt.text = string.format(" (%s)", L["Stage required"])
				Row.Opt.pha = tonumber(pha)				
			elseif rep then
				Row.Opt.text = string.format(" (%s)", L["Reputation Required"])
				Row.Opt.rep, Row.Opt.standing = tonumber(rep), tonumber(standing)
			elseif friend then
				Row.Opt.text = string.format(" (%s)", L["Reputation Required"])
				Row.Opt.friend, Row.Opt.level = tonumber(friend), tonumber(level)
			elseif prof then
				Row.Opt.text = string.format(" (%s)", L["Profession Required"])
				Row.Opt.prof = true	
			else
				Row.Opt.text	= ""
			end
		end
	end
	 
	function DGV:SetQuestColor(i) 
		local Row = GetVisualRow(i)
		local questpart = self:ReturnTag("QIDP", i)
		if DGV:CheckForSkip(i) then CheckInitOpt(i) end
		
		
		if (Row.Opt.optional and i~= DGU.CurrentQuestIndex and self:GetQuestState(i) ~= "C") or 
			(Row.Opt.prof and i~= DGU.CurrentQuestIndex and self:GetQuestState(i) ~= "C") or
			(Row.Opt.pre and not EvaluatePRE(Row.Opt.pre)) or 
			(Row.Opt.pha and not EvaluatePHA(Row.Opt.pha)) or
			(Row.Opt.rep and not EvaluateREP(Row.Opt.rep, Row.Opt.standing)) or
			(Row.Opt.friend and not EvaluateFS(Row.Opt.friend, Row.Opt.level)) then
			Row.Name:SetTextColor(0.75, 0.75, 0.75, 1)
			Row.Desc:SetTextColor(0.75, 0.75, 0.75, 1) 
			Row.Opt:SetTextColor(0.75, 0.75, 0.75, 1) 
			Row.Opt:SetFontObject("GameFontHighlightSmall",5)
			return
		elseif (strmatch(self.actions[i], "[ACT]") and self:UserSetting(DGV_QUESTCOLORON)) or (questpart and strmatch(self.actions[i], "[NK]") and self:UserSetting(DGV_QUESTCOLORON)) then	--set difficulty color on A/C/T actions
			local color  = self:GetQuestDiffColor(i)
			if color then
				Row.Name:SetTextColor(color.r, color.g, color.b, 1) 
				Row.Opt:SetTextColor(color.r, color.g, color.b, 1) 		
			end
			return
		end
		DGV:SetQuestTextNormal(i)
	end

	function DGV:GetQuestDiffColor(i)
		local color
		local qid = self.qid[i]
		if qid then
			local level = DGV:GetQuestLevel(qid)
			if level then
				color = GetQuestDifficultyColor(level)
			end
		end
		return color
	end

	function DGV:SetAllQuestColor()
		local i, qid
		for i, qid in ipairs(DGV.actions) do
			DGV:SetQuestColor(i)
		end
	end

	function DGV:GetQuestLevel(qid)
		if self.ReqLevel[qid] then
			return self.ReqLevel[qid][1]
		end
	end

	function DGV:GetReqQuestLevel(qid)
		if self.ReqLevel[qid] then
			return self.ReqLevel[qid][2]
		end
	end

	function DGV:SetChkToComplete(i)
		if DGV:isValidGuide(CurrentTitle) == true then
			self:SetQuestState(i, "C")
			visualRows[i].Chk:SetChecked(1)
		end
	end



	function DGV:AchieveCompleteFromAchieveID(achieveID, achieveIndex)
		if achieveID ~= 6856 and 
			achieveID ~= 6716 and 
			achieveID ~= 6846 and 
			achieveID ~= 6754 and 
			achieveID ~= 6857 and 
			achieveID ~= 6850 and 
			achieveID ~= 6855 and 
			achieveID ~= 6847 and 
			achieveID ~= 6858 and -- Exclude lorewalker achievement 
			self:UserSetting(DGV_ACCOUNTWIDEACH) then -- Account Wide Achievement
			if (select(4, GetAchievementInfo(achieveID))) then return true end
		end 
		if achieveIndex then
			return (select(3, GetAchievementCriteriaInfo(achieveID, achieveIndex)))
		end
		
	end

	function DGV:AchieveCompleteFromGuideIndex(guideindx)
		--achieve
		if self.gtype[CurrentTitle] == "A" or "E" then 
			local comp, categoryID, description, completed, achieveID, achieveIndex, ret
			achieveID = self:ReturnTag("AID", guideindx)
			achieveIndex = self:ReturnTag("AC", guideindx)
			
			if achieveID then
				ret = self:AchieveCompleteFromAchieveID(achieveID, achieveIndex)
				return ret
			end
		end
	end

	function DGV:PrintAchieve(achieveID, achieveIndex)
		local name, completed, description, ccompleted, cdescription
		
		_, name, _, completed, _, _, _, description, _, _, _ = GetAchievementInfo(achieveID)
		if completed == true then comp = " complete" else comp = " NOT complete" end

		if achieveIndex then
			cdescription, _, ccompleted = GetAchievementCriteriaInfo(achieveID, achieveIndex)
			if ccompleted == true then ccomp = " complete" else ccomp = " NOT complete" end
			DebugPrint("["..achieveID.."] "..name..comp.." STEP: ["..achieveIndex.."] "..cdescription..ccomp)	
		else
			DebugPrint("["..achieveID.."] "..name..comp)			
		end
	end

	function DGV:PrintAllGuideAchieves()
		for i=1, #visualRows do
			local achieveID = self:ReturnTag("AID", i)
			local achieveIndex = self:ReturnTag("AC", i)
			if achieveID then self:PrintAchieve(achieveID, achieveIndex) end
		end
	end

	function DGV:SetQuestsState()
		SuspendViewFrameUpdate()
		local i
		if DGU.QuestState then
			
			--Find all previously completed quests and check them
			for i=1, #visualRows do			
				local qid = self.qid[i]
				local state = self:GetQuestState(i)
				if state == "X" or DGU.toskip[qid] then --User skipped	
					self:SetChktoX(i)	
				elseif state == "C" then
					self:SetChkToComplete(i)
				end
			end
			
			self:UpdateMainFrame()

		end	
		--ResumeViewFrameUpdate()	--UpdateMainFrame will ResumeViewFrameUpdate()
	end

	function DGV:HasQuestBeenTurnedIn(qid)
		if qid then
			return IsQuestFlaggedCompleted(qid)
		end
		-- if DGU.turnedinquests[qid] then
			-- return true
		-- end
	end
	
	local function IsPlayerLevelWithinRange(playerLevel, range)
		if not range then return end
		local minimum, operator, maximum = range:match("%((%d+)(.)(%d*)")
		minimum = tonumber(minimum); maximum = tonumber(maximum)
		if not maximum and operator=="+" then maximum=GetMaxPlayerLevel() end
		return 
			minimum 
			and minimum <= playerLevel 
			and maximum 
			and (maximum > playerLevel or maximum == GetMaxPlayerLevel()),
			minimum,
			maximum
	end

	local function IterateGuidesInRange(invariant, control)
		local playerLevel = DGU.PlayerLevel or UnitLevel("player")
		while true do
			control = next(DGV.guides, control)
			if not control then return end
			local pass, minimum, maximum = IsPlayerLevelWithinRange(playerLevel, DGV:GetGuideRange(control))
			if pass then
				return control, minimum, maximum
			end
		end
	end
	
	local inRangeLabels = {}
	local inRangeButtons = {}
	local function AskDungeonGuideSuggest(...)
		if DGV:UserSetting(DGV_GUIDESUGGESTMODE) then
			local suggestedGuide = DGV:GetFormattedTitle((select(1, ...)))
			DugisGuideSuggestFrame.Title:SetText(L["Suggested Dungeon Guide"]..":")
			DugisGuideSuggestFrame.Or:SetText(L["Alternative Dungeon Guides"]..":")
			DugisGuideSuggestFrame.GuideTitle:SetText("|cffffffff"..suggestedGuide.."|r")
			DugisGuideSuggestFrame:SetFrameStrata("TOOLTIP")
			DugisGuideSuggestFrame.Title2:Hide()
			DugisGuideSuggestFrame.CompleteYesButton:Hide()			
			DugisGuideSuggestFrame:Show()
			DugisGuideSuggestFrame.suggestedGuide = suggestedGuide
			for _,label in ipairs(inRangeLabels) do
				label:Hide()
			end
			for _,button in ipairs(inRangeButtons) do
				button:Hide()
			end

			DugisGuideSuggestFrame:SetHeight(120)
			DugisGuideSuggestFrame.Or:Hide()
			
			
			local lastFontString
			for i=2,select("#", ...) do
				local dungeonGuide = select(i, ...)
				local formatted = DGV:GetFormattedTitle(dungeonGuide)
				
				local fontString,button = inRangeLabels[i-1],inRangeButtons[i-1]
				if not fontString then
					fontString = DugisGuideSuggestFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
					fontString:SetJustifyH("LEFT")
					fontString:SetWidth(240)
					fontString:SetHeight(25)
					fontString:SetPoint(
						"TOPLEFT", 
						lastFontString or  DugisGuideSuggestFrame.Or, 
						"BOTTOMLEFT", 
						(lastFontString and 0) or 20, 0)
					tinsert(inRangeLabels, fontString)
					
					button = CreateFrame("Button", nil, DugisGuideSuggestFrame, "UIPanelButtonTemplate")



					button:SetWidth(55)
					button:SetHeight(23)
					button:SetPoint("LEFT", fontString, "RIGHT", 5, 0)
					button:SetText("Go")
					tinsert(inRangeButtons, button)
				end
				fontString:SetText("|cffffffff"..formatted.."|r")
				fontString:Show()
				button:SetScript("OnClick", 
					function()
						print("|cff11ff11Dugi Guides: |r"..DGV:GetFormattedTitle(formatted).."|cff11ff11 selected.|r")
						DGV:DisplayViewTab(DGV:GetRawTitle(formatted))
						PlaySoundFile("Sound\\Interface\\AlarmClockWarning3.ogg")
						DugisGuideSuggestFrame:Hide()
					end)
				button:Show()
				lastFontString = fontString
			end
			if select("#", ...)>1 then
				DugisGuideSuggestFrame:SetHeight(DugisGuideSuggestFrame:GetHeight()+(select("#", ...)-1)*25+35)
				DugisGuideSuggestFrame.Or:Show()
			end
		end
	end
	
	local dungeonMatches
	local function MatchDungeonGuides(currentZone, playerLevel)
		if not currentZone then
			currentZone = DGV:GetPlayerMapPositionDisruptive()
		end
		if not playerLevel then
			playerLevel = UnitLevel("player")
		end
		local preferredSuggestionFound
		if not dungeonMatches then dungeonMatches = {} end
		wipe(dungeonMatches)
		if DGV.guidelist["I"] then 
			for _,title in ipairs(DGV.guidelist["I"]) do
				local zone = tonumber(title:match("^(%d+)"))
				if not zone then
					zone = tonumber(DGV:GetMapIDFromName(title:match("^(.-)%s?%(")))
				end
				if currentZone==zone then
					if CurrentTitle==title then return end
					local range = DGV:GetGuideRange(title)
					if not preferredSuggestionFound and IsPlayerLevelWithinRange(playerLevel, range) then
						preferredSuggestionFound = true
						tinsert(dungeonMatches, 1, title)
					else
						tinsert(dungeonMatches, title)
					end
				end
			end
		end 
		if dungeonMatches and #dungeonMatches>0 then
			AskDungeonGuideSuggest(unpack(dungeonMatches))
			return true
		end
	end
	
	local function SuggestDungeonsByLevelRange(playerLevel)
		if not dungeonMatches then dungeonMatches = {} end
		wipe(dungeonMatches)
		for guideInRange in IterateGuidesInRange do
			if DGV.gtype[guideInRange] == "I" then
				tinsert(dungeonMatches, guideInRange)
			end
		end
		if dungeonMatches and #dungeonMatches>0 then
			AskDungeonGuideSuggest(unpack(dungeonMatches))
			return true
		end
	end

	function DGV:DugisSuggestButtonOnClick()
		local playerLevel = UnitLevel("player")
		if activeTabInfo.text=="Leveling" then
			DGV:AskGuideSuggest(playerLevel)
		elseif activeTabInfo.text=="Dungeons" then
			local currentZone = DGV:GetPlayerMapPositionDisruptive()
			if not MatchDungeonGuides(currentZone, playerLevel) then
				SuggestDungeonsByLevelRange(playerLevel)
			end
		end
	end
	
	-- 
	-- Guide Suggest
	--
	function DGV:AskGuideSuggest(playerLevel)
		if not playerLevel then
			playerLevel = UnitLevel("player")
		end

		if self:UserSetting(DGV_GUIDESUGGESTMODE) then
			local suggestedGuide = self:GetSuggestedGuide(playerLevel)
			if not suggestedGuide then print("|cff11ff11Dugi Guides: |rPlayer level "..UnitLevel("player").." guide not installed."); return end
			suggestedGuide = self:GetFormattedTitle(suggestedGuide)
			DugisGuideSuggestFrame.Title:SetText(L["Suggested Leveling Guide"]..":")
			DugisGuideSuggestFrame.Or:SetText(L["Alternative Leveling Guides"]..":")
			DugisGuideSuggestFrame.GuideTitle:SetText("|cffffffff"..suggestedGuide.."|r")
			DugisGuideSuggestFrame:SetFrameStrata("TOOLTIP")
			DugisGuideSuggestFrame.Title2:Show()
			DugisGuideSuggestFrame.CompleteYesButton:Show()
			DugisGuideSuggestFrame:Show()
			DugisGuideSuggestFrame.suggestedGuide = suggestedGuide
			for _,label in ipairs(inRangeLabels) do
				label:Hide()
			end
			for _,button in ipairs(inRangeButtons) do
				button:Hide()
			end
			DugisGuideSuggestFrame:SetHeight(120)
			DugisGuideSuggestFrame.Or:Hide()
			local lastFontString
			local rangeCount = 0
			for guideInRange,minimum in IterateGuidesInRange do
				if minimum > 1 then

					local formatted = self:GetFormattedTitle(guideInRange)
					if formatted~=suggestedGuide and self.gtype[guideInRange] == "L" then
						rangeCount = rangeCount + 1
						local fontString,button = inRangeLabels[rangeCount],inRangeButtons[rangeCount]
						if not fontString then
							fontString = DugisGuideSuggestFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
							fontString:SetJustifyH("LEFT")
							fontString:SetWidth(240)
							fontString:SetHeight(25)
							fontString:SetPoint(
								"TOPLEFT", 
								lastFontString or  DugisGuideSuggestFrame.Or, 
								"BOTTOMLEFT", 
								(lastFontString and 0) or 20, 0)
							tinsert(inRangeLabels, fontString)
							
							button = CreateFrame("Button", nil, DugisGuideSuggestFrame, "UIPanelButtonTemplate")



							button:SetWidth(55)
							button:SetHeight(23)
							button:SetPoint("LEFT", fontString, "RIGHT", 5, 0)
							button:SetText("Go")
							tinsert(inRangeButtons, button)
						end
						fontString:SetText("|cffffffff"..formatted.."|r")
						fontString:Show()
						button:SetScript("OnClick", 
							function()
								print("|cff11ff11Dugi Guides: |r"..DGV:GetFormattedTitle(formatted).."|cff11ff11 selected.|r")
								DGV:DisplayViewTab(DGV:GetRawTitle(formatted))
								PlaySoundFile("Sound\\Interface\\AlarmClockWarning3.ogg")
								DugisGuideSuggestFrame:Hide()
							end)
						button:Show()
						lastFontString = fontString
					end
				end
			end
			if rangeCount>0 then
				DugisGuideSuggestFrame:SetHeight(DugisGuideSuggestFrame:GetHeight()+rangeCount*25+35)
				DugisGuideSuggestFrame.Or:Show()
			end
		end

	end

	function DGV:SuggestButtonOnClick(firstTime)
		local suggestedGuide
		
		if firstTime then 
			suggestedGuide = DGV:GetSuggestedGuide(UnitLevel("player"))
		else 
			suggestedGuide = DugisGuideSuggestFrame.suggestedGuide
		end
		
		if suggestedGuide then 
			DebugPrint("#SUGGESTED:"..suggestedGuide) 
		else 
			DebugPrint("#SUGGESTED: NIL")
			print("|cff11ff11Dugi Guides: |rPlayer level "..UnitLevel("player").." guide not installed.")
		end
		
		if suggestedGuide then
			print("|cff11ff11Dugi Guides: |r"..DGV:GetFormattedTitle(suggestedGuide).."|cff11ff11 selected.|r")
			DGV:DisplayViewTab(DGV:GetRawTitle(suggestedGuide))
			PlaySoundFile("Sound\\Interface\\AlarmClockWarning3.ogg")
		end
		
		DugisGuideSuggestFrame:Hide()
	end

	function DGV:CompleteCurrentQuest()
		if CurrentTitle == nil or DGV.gtype[CurrentTitle] ~= "L" then 
			print("|cff11ff11Dugi Guides:|r No leveling guide loaded. Select a leveling guide first by clicking the suggest button or choose one manually.")
		else 
			local logindex
			local i = DGU.CurrentQuestIndex
			while i <= #visualRows do
					logindex = self:GetQuestLogIndexByQID(self.qid[i])
					if not logindex and (DGV:GetQuestState(i) ~= "C") then
						self:SetChktoX(i)
				end
				i = i + 1
			end		
			DugisGuideSuggestFrame:Hide()
			DGV:DisplayViewTab(CurrentTitle)
			self:MoveToNextQuest()
			print("|cff11ff11Dugi Guides:|r Skipped (|cffcc0000x|r) all steps not related to Quests in Log.")
		end
	end

	function DGV:LevelUpSuggestGuide(playerLevel)
		--Don't suggest new guide when player can't move to next zone
		--502 DK Start Zone, 539, 611, 545, 678, 679, Worgen Start Zone, 605, 544, 681, 682 Goblin Start Zone
		local mapId = GetCurrentMapAreaID()
		DebugPrint("Current mapID:"..mapId)
		if mapId == 502 or mapId == 539 or mapId == 611 or mapId == 545 or mapId == 678 or mapId == 679 or mapId == 605 or mapId == 544 or mapId == 681 or mapId == 682 or mapId == 808 then return end 

		local suggestedGuide = self:GetSuggestedGuide(playerLevel)

		if suggestedGuide ~= CurrentTitle then
			DGV:AskGuideSuggest(playerLevel)
		end
	end

	local function _CycleThroughGuides(guideName, playerLevel)
		local safety = 0
		playerLevel = playerLevel or UnitLevel("player")
		DebugPrint("playerLevel is"..playerLevel.." unitlevel is"..UnitLevel("player"))
		
		while guideName and safety < 50 do
			local LevelRange = DGV:GetGuideRange(guideName)
			if IsPlayerLevelWithinRange(playerLevel, LevelRange) then
				return guideName
			end
			
			safety = safety + 1
			guideName = DGV.nextzones[guideName]
		end
	end

	function DGV:GetSuggestedGuide(playerLevel)
		
		if CurrentTitle then DebugPrint("[SG] Start at current guide:"..CurrentTitle) end
		
		local suggestion
		--Only search starting with CurrentTitle if we are on a Leveling guide
		if DGV.gtype[CurrentTitle] == "L" then suggestion = _CycleThroughGuides(self:GetRawTitle(CurrentTitle), playerLevel) end
		
		if suggestion then DebugPrint("[SG] Suggestion from current guide:"..suggestion) return suggestion end 
			
		local playerClass, engPlayerClass = UnitClass("player")
		local playerRace,  engPlayerRace  = UnitRace("player") 
		local playerFaction,  engPlayerFaction  = UnitFactionGroup("player") 
		local guideName
		-- 
		-- Starting Zones
		--
		local startguides = 
		{
				BloodElf = "462(1-10 Blood Elf)#462(1-12 Blood Elf)#462(1-13 Blood Elf)", 
				Orc = "4(1-4 Orc)#4(1-6 Orc)#4(1-7 Orc)", 
				Troll = "4(1-4 Troll)#4(1-6 Troll)#4(1-7 Troll)", 
				Goblin = "605(1-5 Goblin)",
				Tauren = "9(1-9 Tauren)#9(1-11 Tauren)#9(1-12 Tauren)", 
				Scourge = "20(1-9 Undead)#20(1-11 Undead)#20(1-12 Undead)", 
				Undead = "20(1-9 Undead)#20(1-11 Undead)#20(1-12 Undead)", 
				Dwarf = "27(1-5 Dwarf)#27(1-6 Dwarf)#27(1-7 Dwarf)", 
				Gnome = "27(1-5 Gnome)#27(1-6 Gnome)#27(1-7 Gnome)", 
				Draenei = "464(1-10 Draenei)#464(1-12 Draenei)#464(1-13 Draenei)", 
				Human = "30(1-9 Human)#30(1-11 Human)#30(1-12 Human)", 
				NightElf = "41(1-9 Night Elf)#41(1-11 Night Elf)#41(1-12 Night Elf)", 
				Worgen = "539(1-12 Worgen)", 
				DeathKnight = "502(55-59 Death Knight)",
				Pandaren = "808(1-12 Pandaren)",
		}
		
		if (engPlayerClass == "DEATHKNIGHT") then
			guideName = startguides["DeathKnight"]
		elseif (engPlayerRace == "Pandaren") and (engPlayerFaction == "Alliance") then 
			guideName = startguides["Human"]
		elseif (engPlayerRace == "Pandaren") and (engPlayerFaction == "Horde") then 
			guideName = startguides["Orc"]
		else 
			guideName = startguides[engPlayerRace] 
		end
		--DebugPrint("guideName"..guideName)
		DebugPrint("[SG] No guide found, begin with starting playerRace"..engPlayerRace)
		suggestion = _CycleThroughGuides(guideName, playerLevel)

		if suggestion then DebugPrint("[SG] Suggestion is: "..self:GetFormattedTitle(suggestion)) return self:GetFormattedTitle(suggestion) end



	end

	function DGV:ReturnGuideTag(tag, Title)
		local GuideTitle = Title or CurrentTitle
		local GuideTags = self.guidetags[GuideTitle]
		
		if not GuideTags then return end
		
		if tag == "PZ" then
			return GuideTags:match("|PZ|")
		elseif tag == "SG" then
			local _, _, check 	= GuideTags:find("|SG|([^|]+)|")
			return check and loadstring("return "..check)()
		end
	end

	function DGV:GetQuestDescription(guideIndex)
		local self = DGV
		local isCollect, desc
		local action 	 = DGV.actions[guideIndex]
		local questTitle = DGV.quests1L[guideIndex]
		local questDesc  = DGV:RemoveParen(DGV.quests2[guideIndex]) 
		local npcID		 = DGV:ReturnTag("NPC", guideIndex)
		
		questDesc 	= self:GetLocalizedNPC(npcID) or questDesc	
		questTitle 	= self:TranslateQuestObjective(guideIndex) or questTitle
		
		if (DGV:ReturnTag("T", guideIndex)) then isCollect = true end
		
		if action == "A" then
			if questDesc ~= "" then
				desc = L["Accept"].." |cfff0c502'"..questTitle.."'|r ("..questDesc..")"
			else
				desc = L["Accept"].." |cfff0c502'"..questTitle.."'|r"
			end
		elseif action == "T" then
			if questDesc ~= "" then
				desc = L["Turn in"].." |cfff0c502'"..questTitle.."'|r ("..questDesc..")"
			else
				desc = L["Turn in"].." |cfff0c502'"..questTitle.."'|r"
			end
		elseif action == "F" then
			desc = L["Fly to"].." |cfff0c502"..questTitle.."|r"
		elseif action == "R" then
			desc = L["Go to"].." |cfff0c502"..questTitle.."|r"
		elseif action == "C" then
			desc = L["Complete"].." |cfff0c502'"..questTitle.."'|r"
		elseif action == "R" then
			desc = L["Travel to"].." |cfff0c502"..questTitle.."|r"
		elseif action == "H" then
			desc = L["Hearth to"].." |cfff0c502"..questTitle.."|r"
		elseif action == "h" then
			desc = L["Set Hearth at"].." |cfff0c502"..questTitle.."|r"
		elseif action == "f" then
			desc = L["Grab"].." |cfff0c502"..questTitle.."|r flight path"				
		elseif action == "U" then
			desc = L["Use"].." |cfff0c502"..questTitle.."|r"
		elseif action == "K" then
			desc = L["Kill"].." |cfff0c502"..questTitle.."|r"
		elseif action == "B" then
			desc = L["Buy"].." |cfff0c502"..questTitle.."|r"
		elseif isCollect == true then
			desc = L["Collect"].." |cfff0c502"..questTitle.."|r" 			
		else
			desc = "|cfff0c502"..questTitle.."|r"
		end
		return desc
	end

	--Map current quest. GetQuestWorldMapAreaID return 0 if player is not on quest
	
	function DGV:MapCurrentObjective(guideIndex, onclick)
	if DGV:isValidGuide(CurrentTitle) == true then
		guideIndex = guideIndex or DGU.CurrentQuestIndex
		local mapID, mapFloor, desc, i, TomTomUID, qid
		
		if self:UserSetting(DGV_WAYPOINTSON) or onclick then
			desc = DGV:GetQuestDescription(guideIndex)
			qid = self.qid[guideIndex]
			
			-- Get the mapFloor and mapID
			if self:ReturnTag("Z", guideIndex) then 
				mapID, mapFloor = self:ReturnTag("Z", guideIndex)
				if mapFloor == nil then 
					if IsInInstance() or mapID == 504 or mapID == 321 then --Dalaran and Orgrimmar
						mapFloor = 1 
					else 
						mapFloor = 0 
					end
				end			
				--DebugPrint("Mapping with |Z|mapID mapFloor| tag mapId: "..mapID)
				--if mapFloor then DebugPrint("Note floor"..mapFloor) end
			-- Use guide header if a valid Guide Zone is stated 	
			elseif self:GetMapNameFromID(self.GuideMapID) then 
				--DebugPrint("Mapping with Guide zone: "..self.GuideMapID)
				if IsInInstance() or mapID == 504 or mapID == 321 then --Dalaran and Orgrimmar
					mapID, mapFloor = self.GuideMapID, 1 

				else 
					mapID, mapFloor = self.GuideMapID, 0 
				end
			-- Use the QID zone. 
			elseif qid and GetQuestWorldMapAreaID(qid) ~= 0 then 
				--DebugPrint("Mapping with QID zone: "..GetQuestWorldMapAreaID(qid) )
				mapID, mapFloor = GetQuestWorldMapAreaID(qid), GetCurrentMapDungeonLevel()
			end
				
			--Remove previous objective's mapping
			DGV:RemoveAllWaypoints()
			
			if DGV:ReturnTag("PPOS", guideIndex) then
				if WorldMapFrame:IsShown() then HideUIPanel(WorldMapFrame) end

				local x, y
				mapID, mapFloor, x, y = DGV:GetPlayerPosition()

				if self:UserSetting(DGV_CARBONITEARROW) and DGV.carboniteloaded and x then
					self.WaypointsShown = false
					DGV.DugisArrow:AddWaypoint(mapID, mapFloor, x*100, y*100, desc, guideIndex)
				elseif self:UserSetting(DGV_TOMTOMARROW) and DGV.tomtomloaded and x then
					self.WaypointsShown = false
					DGV.DugisArrow:AddWaypoint(mapID, mapFloor, x*100, y*100, desc, guideIndex)
					DGV:SafeSetMapQuestId(DGV.qid[guideIndex]);
				elseif x then
					self.WaypointsShown = true
					DGV.DugisArrow:AddWaypoint(mapID, mapFloor, x*100, y*100, desc, guideIndex)
					DGV:SafeSetMapQuestId(DGV.qid[guideIndex]);
				end
				return					
			end				
			
			--Get coordinate from current guide step
			local XYVals = DGV:getCoords(guideIndex)
			if not XYVals then return end
			local isCircular = self:ReturnTag("W", guideIndex)~=nil
			if isCircular and #XYVals == 1 then DugisGuideUser.FinalizeWaypoint = nil end

			for i, coord in ipairs(XYVals) do
				local x, y = unpack(coord)	
				if self:UserSetting(DGV_CARBONITEARROW) and DGV.carboniteloaded then
					self.WaypointsShown = false
-- 					local c, z = getCZ(mapID)
-- 					if czLookup[mapID] then
-- 						TomTomUID = TomTom:AddZWaypoint(c, z, x, y, desc)
-- 					else
-- 						TomTomUID = TomTom:AddWaypoint(x, y, desc)
-- 					end
					DGV.DugisArrow:AddWaypoint(mapID, mapFloor, x, y, desc, guideIndex)
					--TomTom:SetCrazyArrow (carbonite) not working atm, for now coordinates are returned backwards
					--if i == #XYVals then TomTom:SetCrazyArrow(DugisArrow.waypoints[1].tomtom, 5, desc) DugisArrow:Hide() end	
				elseif self:UserSetting(DGV_TOMTOMARROW) and DGV.tomtomloaded then
					self.WaypointsShown = false
-- 					local opts = {}
-- 					opts.title = desc				
-- 					TomTomUID = TomTom:AddMFWaypoint(mapID, mapFloor, x/100, y/100, opts)
					DGV.DugisArrow:AddWaypoint(mapID, mapFloor, x, y, desc, guideIndex)
-- 					if i == #XYVals then TomTom:SetCrazyArrow(DGV.DugisArrow.waypoints[1].tomtom, 5, desc) DGV.DugisArrow:Hide() end
					DGV:SafeSetMapQuestId(DGV.qid[guideIndex]);	
				else
					self.WaypointsShown = true
					--Guide uses player zone tag and text zone name, text matches zone name 
					--if not self:IsValidDistance( mapID, mapFloor, x, y ) and CurrentTitle:match("|PZ|") and string.find(GetZoneText(), self.CurrentZoneName) then
					if not self:IsValidDistance( mapID, mapFloor, x, y ) and DGV:ReturnGuideTag("PZ") and string.find(GetZoneText(), self.CurrentZoneName) then
						mapID, mapFloor = self:GetPlayerPosition( "player" )
						DebugPrint("Error: No valid distance, changing mapID, mapFloor to current player position")
					end
					--DebugPrint("self.CurrentZoneName="..self.CurrentZoneName.."GetZoneText()="..GetZoneText())
					DGV.DugisArrow:AddWaypoint(mapID, mapFloor, x, y, desc, guideIndex)
					--if i == 1 then DGV.DugisArrow:setArrow( mapID, mapFloor, x, y, desc ) DGV.DugisArrow:Show() end
					DGV:SafeSetMapQuestId(DGV.qid[guideIndex]);
				end			
			end
			
		end
	end
	end

	function DGV:AutoScroll(indx)
		if Main.rightScroll:GetScrollChild() ~= DGVCurrentGuideFrame then return end
		if indx and crowheight then
			local val = (crowheight * indx) - 100
			if val < 0 then val = 0 end
			Main.rightScroll.bar:SetValue(val)
		end	
	end

	--Large frame checkbox checked by user
	function DugisGuideViewer_CheckButton_OnEvent(self, event,...)
		name = self:GetName()
		local _, _, boxindex = name:find("DGVRow([^ ]*)Chk")
		boxindex = tonumber(boxindex)
		--local chkboxname = "DGVRow"..boxindex.."Chk"

		local oldChk	 =  DGV:GetQuestState(boxindex)
		local clearBox
		
		if event == "RightButton" then clearBox = 1 end
		
		DGV:TriStateChk(boxindex, clearBox)		
		
		local chk	 =  DGV:GetQuestState(boxindex)
		
		--If user is checking box, move to next step
		if visualRows[boxindex].Chk:GetChecked() == 1 then
			--if not manualmode or chk == "X" then
			if chk == "X" then 
				DGV:SkipQuest(boxindex)	
			end
			
			
			--If CQI just got checked (either by user or because it has same QID as another user checked)
			if visualRows[DGU.CurrentQuestIndex].Chk:GetChecked() == 1 then
				DGV:MoveToNextQuest()
			elseif DGV:UserSetting(DGV_MULTISTEPMODE) and visualRows[boxindex].Chk:GetChecked() == 1 then
				DGV:MoveToNextQuest()
			end
			if boxindex == #visualRows then
				DGV:LoadNextGuide()
			end	
		--User is unchecking box, move to prev step
		else--if _G[chkboxname]:GetChecked() == 0 then
			DGV:ClrChk(boxindex)
			
			if oldChk == "X" then
			DGV:UnSkipQuest(boxindex)
			end
			
			--If CQI just got unchecked (either by user or because it has same QID as another user unchecked)
			local nextindex = DGV:FindNextUnchecked()
			if nextindex < DGU.CurrentQuestIndex then
				DGV:MoveToPrevQuest()
			elseif DGV:UserSetting(DGV_MULTISTEPMODE) then 
				DGV:MoveToNextQuest()
			end

		
		end		

		DGV:SetPercentComplete()

	end

	function DGV:LoadNextGuide()
		local nextguide = DGV.nextzones[CurrentTitle]
		DGV:DisplayViewTab(nextguide)
		if CurrentTitle ~= nil and UnitLevel("player") >= 9 then 
			if self.gtype[CurrentTitle] == "L" then
				DGV:AskGuideSuggest()
			end
		end
	end

	function DGV:TriStateChk(index, clear)
		local stickyFrameChk
		local LargeFramebutton 	= visualRows[index].Chk
		local questState 		= self:GetQuestState(index)
			
		local stickyFrameIndex 	= self.Modules.StickyFrame.revStickyQuests[index]
		
		if stickyFrameIndex then
			stickyFrameChk 	= _G["DGV_SFRow"..stickyFrameIndex.."Chk"]
		end
			
		if clear or questState == "X" then
			self:SetQuestState(index, "U")
			LargeFramebutton:SetCheckedTexture("")
			LargeFramebutton:SetChecked(0)
			if stickyFrameIndex then
				stickyFrameChk:SetCheckedTexture("")
				stickyFrameChk:SetChecked(0)
			end		
		elseif questState == "C" then
			self:SetQuestState(index, "X")
			LargeFramebutton:SetCheckedTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
			LargeFramebutton:SetChecked(1)
			if stickyFrameIndex then
				stickyFrameChk:SetCheckedTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
				stickyFrameChk:SetChecked(1)
			end	
		elseif questState == "U" then
			self:SetQuestState(index, "C")
			LargeFramebutton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
			LargeFramebutton:SetChecked(1)
			if stickyFrameIndex then
				stickyFrameChk:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
				stickyFrameChk:SetChecked(1)
			end			
		end
	end

	function DGV:SetChktoX(index)
		self:SetQuestState(index, "X")
		local LargeFramebutton = visualRows[index].Chk
		LargeFramebutton:SetCheckedTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		LargeFramebutton:SetChecked(1)
	end

	function DGV:ClrChk(index)
		self:SetQuestState(index, "U")
		local LargeFramebutton = visualRows[index].Chk
		LargeFramebutton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		LargeFramebutton:SetChecked(0)
	end

	--User chose to skip the quest and is now changing their mind
	function DGV:UnSkipQuest(qindex)
		local qid = DGV.qid[qindex]
		
		if strmatch(self.actions[qindex], "[ACTNK]") then	
			--Mark all quests with this same qid
			self:UnSkip(qid)
			self:UnSkipPostReqs(qid)	
		else
			DGV:ClrChk(qindex)
		end
		WatchFrame_Update()
	end

	--User chose to not do this quest
	function DGV:SkipQuest(qindex)
		local qid = DGV.qid[qindex]
		
		local logindex = DGV:GetQuestLogIndexByQID(DGV.qid[qindex])
		if logindex then RemoveQuestWatch(logindex)	end	
		WatchFrame_Update()
		
		if strmatch(self.actions[qindex], "[ACTNK]") then
			self:Skip(qid)
			self:SkipPostReqs(qid)
		else --Other tag type only skip this one, not the chain
			DGV:SetChktoX(qindex)
		end
	end

	function DGV:SetQuestTextNormal(i)
		local Row = GetVisualRow(i)
		Row.Name:SetTextColor(1, 0.82, 0, 1) 
		Row.Desc:SetTextColor(1, 1, 1, 1) 
		Row.Opt:SetText("")
	end
	
	function DGV.IterateRelevantSteps(invariant, control)
		if not control then
			control = DGU.CurrentQuestIndex
			return control
		else
			local qid = DGV.qid[control]
			control = control + 1
			if control < DGV:GetLastGuideNumRows() then --prevent last row error
				if (qid==DGV.qid[control] and qid==DGV.qid[control - 1]) and (strmatch(DGV.actions[control], "[NCK]") and strmatch(DGV.actions[control - 1], "[NCK]")) or 
					DGV:CheckForSkip(control) or 
					DGV:GetQuestState(control) == "C" or 
					DGV:GetQuestState(control) == "X" then
					return DGV.IterateRelevantSteps(invariant, control)
				end
			
				if strmatch(DGV.actions[DGU.CurrentQuestIndex], "[RFH]") and strmatch(DGV.actions[DGU.CurrentQuestIndex + 1], "[ATBhUf]") then  
					if control <= #visualRows and strmatch(DGV.actions[control], "[ATBhUf]") then
						return control
					end
				end
	
				if strmatch(DGV.actions[DGU.CurrentQuestIndex], "[RFH]") and strmatch(DGV.actions[DGU.CurrentQuestIndex + 1], "[CNK]") then  
					if control <= #visualRows and strmatch(DGV.actions[control], "[CNKBU]") and not DGV:ReturnTag("MD", DGU.CurrentQuestIndex) and not DGV:ReturnTag("MD", control) then
						return control
					elseif control <= #visualRows and DGV:ReturnTag("U", control) and not strmatch(DGV.actions[control], "[RFH]") and not DGV:ReturnTag("MD", DGU.CurrentQuestIndex) and not DGV:ReturnTag("MD", control) then
						return control
					end
				end			
	
				if strmatch(DGV.actions[DGU.CurrentQuestIndex], "[BhUf]") and strmatch(DGV.actions[DGU.CurrentQuestIndex + 1], "[AT]") then  
					if control <= #visualRows and strmatch(DGV.actions[control], "[ATBhUf]") then
						return control
					end
				end
	
				if strmatch(DGV.actions[DGU.CurrentQuestIndex], "[AT]") then  
					if control <= #visualRows and strmatch(DGV.actions[control], "[ATBhUf]") then
						return control
					end
				end
				
				if strmatch(DGV.actions[DGU.CurrentQuestIndex], "[CNK]") then  
					if control <= #visualRows and strmatch(DGV.actions[control], "[CNKBU]") and not DGV:ReturnTag("MD", DGU.CurrentQuestIndex) and not DGV:ReturnTag("MD", control) then
						return control
					elseif control <= #visualRows and DGV:ReturnTag("U", control) and not strmatch(DGV.actions[control], "[RFH]") and not DGV:ReturnTag("MD", DGU.CurrentQuestIndex) and not DGV:ReturnTag("MD", control) then
						return control
					end
				end	
			end			
		end
	end

	function DGV:WatchQuest()
		local logindex
		DGU.removedQuests = {}
		if self:UserSetting(DGV_ENABLEQW) and DGV:isValidGuide(CurrentTitle) == true then
			for logindex = 1, GetNumQuestLogEntries() do
				local qid = DGV:GetQIDByLogIndex(logindex)
				if not DGU.watchedQuests[qid] then					
					if DGV.carboniteloaded and qid ~= 0 then 
						Nx.Quest.Watch:RemoveWatch(qid, logindex)
					else
						RemoveQuestWatch(logindex)
					end 
				end
				if DGU.watchedQuests[qid] ~= nil and not IsQuestWatched(logindex) then --clean up watchedQuest
					DGU.watchedQuests[qid] = nil
				end 
			end
		end
		
		if (self:UserSetting(DGV_ENABLEQW) or self:UserSetting(DGV_OBJECTIVECOUNTER)) and DGV:isValidGuide(CurrentTitle) == true then
			local i = DGU.CurrentQuestIndex
			if strmatch(self.actions[DGU.CurrentQuestIndex], "[R]") then
				logindex = self:GetQuestLogIndexByQID(self.qid[i])
				i = i + 1
			end
			local skiplogindex = nil
			local onceonly = false
			while i <= #visualRows and strmatch(self.actions[i], "[CTNK]") do
				if self:GetQuestState(i) ~= "X" then
					if DGV.carboniteloaded then
						logindex = self:GetCarboniteQuestLogIndexByQID(self.qid[i])	
					else
						logindex = self:GetQuestLogIndexByQID(self.qid[i])				
					end
					
					if logindex and DGV.carboniteloaded then
						Nx.Quest.Watch:Add(logindex)
					elseif logindex then
						if self:UserSetting(DGV_OBJECTIVECOUNTER) and self:UserSetting(DGV_MULTISTEPMODE) then
							RemoveQuestWatch(logindex)
							DGU.removedQuests[self.qid[i]] = true
						elseif self:UserSetting(DGV_OBJECTIVECOUNTER) and not self:UserSetting(DGV_MULTISTEPMODE) and (skiplogindex ~= logindex) and not onceonly and not strmatch(self.actions[DGU.CurrentQuestIndex], "[R]") then
							RemoveQuestWatch(logindex)
							skiplogindex = logindex
							onceonly = true
							DGU.removedQuests[self.qid[i]] = true
						elseif skiplogindex ~= logindex or strmatch(self.actions[DGU.CurrentQuestIndex], "[R]") then
							AddQuestWatch(logindex)
						end
					end
				end
				i = i + 1
			end
		end
			
		if self:UserSetting(DGV_ENABLEQW) and DGV:isValidGuide(CurrentTitle) == true then
			if DGV.carboniteloaded and strmatch(self.actions[DGU.CurrentQuestIndex], "[CTNK]") and DGV.qid[DGU.CurrentQuestIndex] then 
				local cqid = DGV.qid[DGU.CurrentQuestIndex]
				cqid = tonumber(cqid)
				local cqidpart = DGV:ReturnTag("QIDP", DGU.CurrentQuestIndex)
				cqidpart = tonumber(cqidpart)
				if cqid and strmatch(self.actions[DGU.CurrentQuestIndex], "[T]") then
					Nx.Quest.Tracking[cqid] = 1
					Nx.Quest:TrackOnMap(cqid, 0, true, true, true)
				elseif cqid and cqidpart == 1 then 
					Nx.Quest.Tracking[cqid] = 2
					Nx.Quest:TrackOnMap(cqid, 1, true, true, true)
				elseif cqid and cqidpart == 2 then 
					Nx.Quest.Tracking[cqid] = 4
					Nx.Quest:TrackOnMap(cqid, 2, true, true, true)
				elseif cqid and cqidpart == 3 then 
					Nx.Quest.Tracking[cqid] = 8
					Nx.Quest:TrackOnMap(cqid, 3, true, true, true)							
				elseif cqid and cqidpart == 4 then 
					Nx.Quest.Tracking[cqid] = 16
					Nx.Quest:TrackOnMap(cqid, 4, true, true, true)
				elseif cqid then 
					Nx.Quest.Tracking[cqid] = 2
					Nx.Quest:TrackOnMap(cqid, 1, true, true, true)
				end
			end
		end
		
		if (self:UserSetting(DGV_ENABLEQW) or self:UserSetting(DGV_OBJECTIVECOUNTER)) and DGV:isValidGuide(CurrentTitle) == true then
			WatchFrame_Update()	
		end
	end	
	
	local function QuestLogFrameTrackButton_OnClick(self) 
		local log_index = GetQuestLogSelection()
		if not log_index then return end
		local qid = DGV:GetQIDByLogIndex(log_index)
		if IsQuestWatched(log_index) then	
			DGU.watchedQuests[qid] = true --manually watched quests
		else
			DGU.watchedQuests[qid] = nil		
		end
	end	
	
	QuestLogFrameTrackButton:HookScript("OnClick", QuestLogFrameTrackButton_OnClick)
	
	function DGV:havelootitem(qid)
		local havel
		local lootitem, lootqty 	= DGV:ReturnTag("L", qid)
		if lootitem and (GetItemCount(lootitem) >= lootqty) then havel = true else havel = false end
		return havel
	end

	function DGV:haveuseitem(qid)
		local haveu
		local useitem 				= DGV:ReturnTag("U", qid)
		local uinbag 				= DGV:InBag(useitem)
		if (useitem and uinbag) then haveu = true else haveu = false end 
		return haveu
	end

	function DGV:CheckForSkip(indx) 
		--local lootitem			 	= DGV:ReturnTag("L", indx)
		local optional 				= DGV:ReturnTag("O", indx)
		local pre 					= DGV:ReturnTag("PRE", indx)
		local oid 					= DGV:ReturnTag("OID", indx)
		local rep, standing			= DGV:ReturnTag("REP", indx)
		local friend, level			= DGV:ReturnTag("FS", indx)		
		local useitem 				= DGV:ReturnTag("U", indx)
		local inlog 				= DGV:GetQuestLogIndexByQID(DGV.qid[indx])
		local action				= DGV.actions[indx]
		local toohigh				= DGV:IsQuestTooHigh(indx)
		local hasprof, _			= DGV:ReturnTag("OP", indx)
		local pha					= DGV:ReturnTag("PHA", indx)
		local map1, map2, map3, map4 = DGV:ReturnTag("MAP", indx)
		local haveuse
		haveuse = self:haveuseitem(indx)
		--haveloot = havelootitem(indx)
		local inmap 
		if map1 then 
			if EvaluateMAP(map1) then 
				inmap = true 
			elseif EvaluateMAP(map2) then 
				inmap = true
			elseif EvaluateMAP(map3) then 
				inmap = true
			elseif EvaluateMAP(map4) then 
				inmap = true
			else
				inmap = false
			end
		end
		--|L| + "A" + Optional - skipped if the user does not have the item (and quantity) needed. 
		--|U| + "A" + Optional - skipped if the user does not have the item to use
		
		--[[
		local loginfo
		local qid = DGV.qid[indx]
		if inlog and qid and indx then
			loginfo = "qid:"..qid.."guideindex"..indx.."logindex:"..inlog
		elseif qid and indx then
			loginfo = "qid:"..qid.."guideindex"..indx
		elseif indx then
			loginfo = "guideindex"..indx
		end
		DebugLog(loginfo)
		--]]
		
		--if optional and action == "A" and (haveloot or haveuse)  then
		if optional and action == "A" and haveuse then
			--DebugPrint("Detected use/loot item in bag, display quest")
			return false
		elseif hasprof and not DGV:HasProfession(hasprof) then
			return true
		elseif optional and inmap then 
			return false				
		elseif optional and not inlog then
			--DebugPrint("SKIP: optional and not in log.")
			return true	
		--elseif optional and ((action =="A" and useitem and not haveuse) or (lootitem and not haveloot)) then
		elseif optional and (action =="A" and useitem and not haveuse) then
			DebugPrint("SKIP: not enough loot or no use item")
			return true
		elseif rep and not EvaluateREP(rep, standing) then
			return true		
		elseif friend and not EvaluateFS(friend, level) then
			return true
		elseif oid and EvaluateOID(oid) then
			return true
		elseif inlog then
			return false				
		elseif pre and not EvaluatePRE(pre) then
			return true
		elseif pha and not EvaluatePHA(pha) then 
			return true											
		elseif toohigh then
			return true
		else
			return false
		end
		
	end

	function DGV:CheckForLocation(indx) 
		--R - Run, F - Fly, b - Boat, H - use hearth
		local action = DGV.actions[indx]
		if indx == DGU.CurrentQuestIndex and (action == "R" or action == "F" or action == "b" or action == "H") then
			local subzonetext = string.trim(GetSubZoneText()) -- returns blank if no subzone
			local zonetext = GetZoneText() 
			local quest = self:RemoveParen(self.quests1L[indx])
			if subzonetext == quest or zonetext == quest then			
				return true
			end
		end
	end

	local function CheckForWaypointLocation(indx)
		if CurrentTitle ~= nil then 
			if indx == DGU.CurrentQuestIndex and (DGV.actions[indx] == "R" or DGV.actions[indx] == "H") and not DGV.tags[DGU.CurrentQuestIndex]:match("(|WR|)") then 
				if DGV.DugisArrow.waypoints and #DGV.DugisArrow.waypoints==1 and 
					DGV.DugisArrow:getFirstWaypoint()==DGV.DugisArrow:DidPlayerReachWaypoint() then
					return true
				end
			end
		end 
	end

	function DGV:UpdateTravelToLocation()
		local waypointObjective = CheckForWaypointLocation(DGU.CurrentQuestIndex) 
		if waypointObjective then 
			DGV:SetChkToComplete(DGU.CurrentQuestIndex)
			DGV:MoveToNextQuest()
		end
	end
	
	--Check for current hearthstone location
	function DGV:CheckForHearth(indx)
		if indx == DGU.CurrentQuestIndex then
			local action = DGV.actions[indx]
			if action == "h" then
				local quest = DGV.quests1L[indx]
				if GetBindLocation() == quest then			
					return true
				end
			end
		end
	end 

	function DGV:FindNextUnchecked( )
		local indx = 1
		while indx < #visualRows do
			--self:DebugFormat("FindNextUnchecked", "self:GetQuestState(indx)", self:GetQuestState(indx), "DGV:CheckForSkip(indx)", DGV:CheckForSkip(indx))
			if self:GetQuestState(indx) == "U" and DGV:CheckForSkip(indx) == false then
				break
			end
			indx = indx + 1
		end
		return indx
	end

	--Move to next quest after CurrentQuest we are on
	--Or specific quest with MoveToIndex
	function DGV:MoveToNextQuest(MoveToIndex)
		local checkMoved = DGU.CurrentQuestIndex
		DGU.CurrentQuestIndex = MoveToIndex or DGU.CurrentQuestIndex
		if not DGU.CurrentQuestIndex then return end
		if DGU.CurrentQuestIndex <= #visualRows then
			local i
			for i = 1, #visualRows do
				visualRows[i]:SetNormalTexture("")
			end
			visualRows[DGU.CurrentQuestIndex]:SetNormalTexture("")

			--Phasing out the global CQI
			DGU.CurrentQuestIndex = DGV:FindNextUnchecked()
		
			if DGV:havelootitem(DGU.CurrentQuestIndex) == true then


				DebugPrint("#####havelootitem(DGU.CurrentQuestIndex) ")
				DGV:SetChkToComplete(DGU.CurrentQuestIndex)
				DGV:MoveToNextQuest()    
			end	
			
			if self:ReturnTag("AS", DGU.CurrentQuestIndex) and self:UserSetting(DGV_AUTOSTICK) then
				local row = visualRows[DGU.CurrentQuestIndex]
				self.Modules.StickyFrame:AddRow(row)
				DGV:SetChkToComplete(DGU.CurrentQuestIndex)
				DGV:MoveToNextQuest()   
			end
			self.UpdateStickyFrame( )
			
			if checkMoved ~= DGU.CurrentQuestIndex or MoveToIndex then
				DGV:SetQuestColor(DGU.CurrentQuestIndex)
				CurrentAction = DGV.actions[DGU.CurrentQuestIndex] 	
				CurrentQuestName = DGV.quests1L[DGU.CurrentQuestIndex] 
	
				DGV:SetUseItem(DGU.CurrentQuestIndex)
				DGV:SetTarget(DGU.CurrentQuestIndex)
						
				DGV:MapCurrentObjective() 
				DGV:WatchQuest()
				
				if DGV:IsModelDataOn() then self:ShowModel(DGU.CurrentQuestIndex) end
				
				DGV:SetPercentComplete()
	
				--if not MoveToIndex then
				DGV:PlayCompletionSound(DGV_STEPCOMPLETESOUND)
				--end
				DGV:UpdateMiniBlobs()								
				DGV:CompleteOnZoneCheck()
			end
			visualRows[DGU.CurrentQuestIndex]:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\highlight.tga")
			DGV:UpdateCompletionVisuals()
		end
		
	end

	function DGV:MoveToPrevQuest()
			local checkMoved = DGU.CurrentQuestIndex
			visualRows[DGU.CurrentQuestIndex]:SetNormalTexture("")
			
			local nextindex = DGV:FindNextUnchecked()
			DGU.CurrentQuestIndex = nextindex
		
			DGV:SetQuestColor(DGU.CurrentQuestIndex)

			CurrentAction = DGV.actions[DGU.CurrentQuestIndex] 
			CurrentQuestName = DGV.quests1L[DGU.CurrentQuestIndex] 

			if self:ReturnTag("AS", DGU.CurrentQuestIndex) and self:UserSetting(DGV_AUTOSTICK) then
				local row = visualRows[DGU.CurrentQuestIndex]
				self.Modules.StickyFrame:AddRow(row)
				DGV:SetChkToComplete(DGU.CurrentQuestIndex)
				DGV:MoveToNextQuest()   
			end
			self:UpdateStickyFrame( )
			
			if checkMoved ~= DGU.CurrentQuestIndex then
				DGV:SetUseItem(DGU.CurrentQuestIndex)
				DGV:SetTarget(DGU.CurrentQuestIndex)
				DGV:MapCurrentObjective()
				DGV:WatchQuest()
				if DGV:IsModelDataOn() then self:ShowModel(DGU.CurrentQuestIndex) end
			
				DGV:UpdateSmallFrame()
				DGV:UpdateMiniBlobs()
				
				DGV:SetPercentComplete()
				
				DGV:CompleteOnZoneCheck()
			end
			visualRows[DGU.CurrentQuestIndex]:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\highlight.tga")
			DGV:UpdateCompletionVisuals()			
	end

	--Uncheck quests and start from beginning of quest progress
	function DGV:ResetAllQuests()
		SuspendViewFrameUpdate()
		for i = 1, #visualRows do
			DGV:ClrChk(i)
		end
		ResumeViewFrameUpdate()
		if not self.preLoadMode then
			CurrentQuestName = DGV.quests1L[1]
			CurrentAction = DGV.actions[1]
			DGU.CurrentQuestIndex = 1
			DGV:UpdateSmallFrame()
			DGV:SetUseItem(DGU.CurrentQuestIndex)
			DGV:SetTarget(DGU.CurrentQuestIndex)
			--QueryQuestsCompleted()
		end
	end
	
	function DGV:WipeOutViewTab()
		local i
		for i =1, #visualRows do
			visualRows[i]:Hide()
		end
		wipe(visualRows)
		DugisPercentButtonName:Hide()	
	end

	--Format: "39(9-14)#39(10-15)#39(11-17)"
	function DGV:GetRawTitle(FormattedTitle)
		if self.rawtitle[FormattedTitle] then
			return self.rawtitle[FormattedTitle]
		else
			return FormattedTitle
		end
	end
	
	local function _GetTitleMapID(title)
		return tonumber(title:match("[%d]*"))
	end


	--Format: Elwynn Forest (1-9 Human)
	--RawTitle, optional GuideDifficulty "Easy" "Normal" or "Hard"
	function DGV:GetFormattedTitle(RawTitle, GuideDifficulty)
		if not RawTitle then return end
		local GuideLevelRange, LocalizedMapName 


		
		local BeforeParen = RawTitle:match("([^%(]*)")
		if BeforeParen then BeforeParen = strtrim(BeforeParen) end
			
		--"(1-9 Human)"
		GuideLevelRange = DGV:GetGuideRange(RawTitle, GuideDifficulty)

		--"Elwynn Forest"

		LocalizedMapName 	= self:GetMapNameFromID(_GetTitleMapID(RawTitle)) or BeforeParen
		
		--"Elwynn Forest (1-9 Human)"
		if GuideLevelRange and LocalizedMapName then
			GuideLevelRange = LocalizedMapName.." "..GuideLevelRange
		end
		
		local ret = GuideLevelRange or RawTitle or "No Title"
		return ret
	end

	--title: 30(1-9 Human) or "478(62-64)" or "27(5-10 Dwarf & Gnome)" or "492(77-80 |cfff0c502Lore|r)"

	local function _GetTitleLevels(title)
		local race, race2, levels
		title = title:match("%([^%)]*%)") --"(1-9 Human)" or "(62-64)"
			

		if title then 
			if title:match("%d*-%d*%s.*|r") then --"(77-80 |cfff0c502Lore|r)"
				return title 
			else
				race  = title:match("%d%s([%a%s]*)") --"Human"
				if race then race = race:trim() end
				race2 = title:match("&%s([%a%s]*)")  --"Gnome" from "Dwarf & Gnome"
				
				--if title then DebugPrint("title="..title.."#") end
				--if race then DebugPrint("race="..race.."#") end
				--if race2 then DebugPrint("race2="..race2.."#") end
				
				levels = title:match("(%d+-%d+)")   --"1-9"
				if levels and race then  
					race = DGV:localize( race, "RACE")
					
					if race2 then
						race2 = DGV:localize( race2, "RACE")
						race = race.." & "..race2
					end
					title = "("..levels.." "..race..")" --"(1-9 Humano)"
				end	
			end
		end 
			
		return title

	end

	--RawTitle: "30(1-9 Human)#30(1-11 Human)#30(1-12 Human)"
	function DGV:GetGuideRange(RawTitle, GuideDifficulty)
		
		local Hard, Normal, Easy= strsplit("#", RawTitle, 3)

		local level = GuideDifficulty or DGV:UserSetting(DGV_GUIDEDIFFICULTY)
		local GuideRange
		
		--"(1-9 Human)" or "(11-17)"
		if Easy and level == "Easy" then
			GuideRange = _GetTitleLevels(Easy)
		elseif Normal and level == "Normal" then
			GuideRange = _GetTitleLevels(Normal)
		elseif Hard then
			GuideRange = _GetTitleLevels(Hard)
		end
		return GuideRange-- or RawTitle
	end
	

	--Called from clicking on a guide title
	function DGV:DisplayViewTab(title)
		if InCombatLockdown() then print("|cff11ff11Dugi Guides: |r|cffcc0000Cannot load guides during combat.|r Please try again."); return end
		
		if title ~= CurrentTitle then
			self:ClearStickyFrame()
			DGU.CurrentQuestIndex = 1
		end
		
		--Clear existing guide if any and load this guide
		if title == nil or DGV:isValidGuide(title) == false then
			 DGV:ClearScreen()

			CurrentTitle = nil 
			
		else--if title ~= CurrentTitle then
					
			CurrentTitle = title
			self.CurrentTitle = title
			
			self.GuideMapID = _GetTitleMapID(CurrentTitle)
			self.CurrentZoneName = self:GetMapNameFromID(self.GuideMapID) or title:match("(%w*)%s?%(")
			
			DGV:ParseRows(title, string.split("\n","\n"..self.guides[title]()))
		


			if not self.preLoadMode then
				DGV:QuestsBackgroundTranslator()
			end
			
			DGV:PopulateObjectives(title)
			
			--if not self.preLoadMode then
				local name = title..":1"
				if DGU.QuestState[name] == nil then
					DGV:ResetAllQuests()					
				end
			--end
				
			DGV:SetQuestsState()
			
			if not self.preLoadMode then
				DGV:UpdateProfessions()
				DGV:UpdatePlayerLevels()
				DGV:ShowViewTab()
				DelayandMoveToNextQuest(5)		

				DGV:SetAllPercents()
				visualRows[DGU.CurrentQuestIndex]:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\highlight.tga")
				DGV:AutoScroll(CurrentQuestIndex)
			end
		end
	end
	
	function Dugis_OnMouseWheel(self, delta)
		local current = self.bar:GetValue()
		local _, Max = self.bar:GetMinMaxValues()
		Max = Max or 1
		if (delta < 0) and (current < Max) then
			self.bar:SetValue(current + 100)
		elseif (delta > 0) and (current > 1) then
			self.bar:SetValue(current - 100)
		end
	end
	
	local function getColor(percent)
	local red, green, blue, alpha
		if percent < 25 then
			red = 1
			green = 0
			blue = 0
			alpha = 1
		elseif percent < 50 then
			red = 1
			green = 0.5
			blue = 0
			alpha = 1
		elseif percent < 75 then
			red = 1
			green = 1
			blue = 0
			alpha = 1
		else
			red = 0
			green = 1
			blue = 0
			alpha = 1
		end
		return red, green, blue, alpha
	end




	-- 
	-- Preload Feature
	--
	local thread
	local preloadFrame = CreateFrame("Frame")
	local preloadCounter = 0
	local preloadThrottle = 0.25
	preloadFrame:SetScript("OnUpdate" , function(self, elapsed)
		preloadCounter = preloadCounter + elapsed
		if preloadCounter >= preloadThrottle and DGV.preLoadMode then
			preloadCounter = preloadCounter - preloadThrottle
			if coroutine.status(thread) ~= "dead" then
				coroutine.resume(thread)
			end
		end
	end)
	
	local function GetCreateRowHeading(tabNum, title, originalTabNum)
		for _,rh in ipairs(Guides.rowHeadings) do
			if rh.tabNum==tabNum and rh.headingTitle==DGV.headings[title] 
				and (not originalTabNum or originalTabNum==rh.originalTabNum)
				and rh:IsShown()
			then
				return rh
			end
		end
		local label

		for _,rh in ipairs(Guides.rowHeadings) do
			if rh.tabNum==tabNum and not rh:IsShown() then
				label = rh
				break
			end
		end
		if not label then
			label = CreateFrame("Button", "DugisTab"..tabNum.."Heading"..#Guides.rowHeadings, tabs[tabNum].RightFrame, "DugisGuideListingTemplate")
			label.Title:SetFont(GameFontHighlightLarge:GetFont())
			label.Title:SetPoint("RIGHT")
			tinsert(Guides.rowHeadings, label)
		end
		local anchor
		for _,tabLabel in ipairs(Guides.rowHeadings) do
			if tabLabel.tabNum==tabNum and tabLabel:IsShown() then
				anchor = tabLabel

			end
		end
		if not anchor then
			label:SetPoint("TOPLEFT", 0, -5)
		else
			label:SetPoint("LEFT")
			--label:SetPoint("TOP", anchor, "BOTTOM", 0, -5)
			label.anchor = anchor
		end
		label.tabNum = tabNum
		label.headingTitle = DGV.headings[title]
		label.guideType = tabs[label.tabNum].guidetype
		label.originalTabNum = originalTabNum
		label.Title:SetText(label.headingTitle)
		label:Show()
		--SetCollapsedBehavior(label)
		return label
	end
	
	local function GetCreateTabRow(tabNum, rowNum, title, originalTabNum)
		if tabs[tabNum].visualRows and tabs[tabNum].visualRows[rowNum] then
			local row = tabs[tabNum].visualRows[rowNum]
			row.originalTabNum = originalTabNum
			return row
		end
		local name = "DugisTab"..tabNum.."Row"..rowNum

		local row = _G[name]
		if not row then
			if title then
				row = CreateFrame("Button", name, GetCreateRowHeading(tabNum, title, originalTabNum), "DugisGuideListingTemplate" )
				row:GetParent().lastChild = row
			else
				row = CreateFrame("Button", name, tabs[tabNum].RightFrame, "DugisGuideListingTemplate" )
			end
			row:SetNormalTexture("");
			row.highlight:SetAllPoints()
			row.highlight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
			if not tabs[tabNum].visualRows then
				tabs[tabNum].visualRows = {}
			end
			tabs[tabNum].visualRows[rowNum] = row
		end
		row.originalTabNum = originalTabNum
		--row:Show()
		return row
	end

	local function preLoad( )
		local guideNum, tabNum
		local self = DGV
		local currentGuide = CurrentTitle
		local currentGuideType = activeTabInfo.guidetype
		
		--DugisPreloadButton:Disable()

		for tabNum = 1, #tabs do --SIDE_TAB_START, #tabs do 
			local guideType = tabs[tabNum].guidetype
			local guideList = self.guidelist[guideType] -- "L" guide list
			
			if guideType == currentGuideType and guideList then	
				--DebugPrint("guideType="..currentGuideType)
				for guideNum = 1, #guideList do
					
					local guideName = guideList[guideNum]
					local guideRow = GetCreateTabRow(tabNum, guideNum).Percent
					--DebugPrint("guideName="..guideName)
					
					--DebugPrint("tab"..tabNum.."row"..guideNum)
					DGV:DisplayViewTab(guideName)
					DGV:SetPercent(guideName, guideRow)
					
					coroutine.yield()
				end
			end
		end
		
		--DGV:SetAllPercents()
		
		DGV:DisplayViewTab(currentGuide)
		
		collectgarbage()
		
		self.preLoadMode = nil
		--DugisPreloadButton:Enable()
		
		DebugPrint("####END")
	end

	function DGV:PreloadButtonOnClick()
		self.preLoadMode = true
		thread = coroutine.create(preLoad)
	end

	function DGV:IsPreloadQuestComplete(questLine, guideIndex)

		local qComplete, QuestComplete
		local qid 			= tonumber(questLine:match("|QID|(%d+)")) --self.qid[guideIndex]
		local oid			= tonumber(questLine:match("|OID|(%d+)"))		
		local logIndx 		= self:GetQuestLogIndexByQID(qid)
		local action 		= questLine:match("^(%a)") --self.actions[guideIndex]
		local questState	= self:GetQuestState(guideIndex)
		local questPart 	= questLine:match("|QID|%d+%.(%d+)") --self:ReturnTag("QIDP", guideIndex)
		local needsLoot 	= questLine:match("|L|(%d+)%s?(%d*)|")--self:ReturnTag("L", guideIndex)
		local isDaily		= questLine:match("|D|")--self:ReturnTag("D", guideIndex)
		
		if logIndx then _, _, _, _, _, _, qComplete, _, _ = GetQuestLogTitle(logIndx) end
		
		if qComplete == 1 or self:QuestPartComplete(guideIndex) or (needsLoot and self:IsCompleteLootQO("QLU", nil, guideIndex)) or (not isDaily and self:HasQuestBeenTurnedIn(qid)) 
			 or self:ProfessionCompletedAtGuideIndex(guideIndex) or self:CheckForLocation(guideIndex) or self:AchieveCompleteFromGuideIndex(guideIndex) or self:CheckForHearth(guideIndex) then QuestComplete = true else QuestComplete = nil end
		
		if (action == "A" and logIndx) or (QuestComplete and action ~= "T") or (QuestComplete and action == "T" and not logIndx) or questState == "C" or (oid and EvaluateOID(oid)) then--and strmatch(action, "[NFfRBbh]") and not questPart and not needsLoot) then 
			QuestComplete = true
		end

		return QuestComplete
	end

	local percentsSet = false --takes for-ev-er and only needs to be done once
	function DGV:SetAllPercents()
		if percentsSet then return end
		percentsSet = true
		local guidename, text, t, i, guideRow
		local red, green, blue, alpha
		
		
		if DGU["QuestState"] then
			for t = 1, #tabs do 
				local gtype = tabs[t].guidetype
				if gtype and DGV.guidelist[gtype] then
					for i = 1, #DGV.guidelist[gtype] do --Each guide title
						guidename 	= 	DGV.guidelist[gtype][i]
						guideRow = GetCreateTabRow(t, i).Percent
						if not guideRow:GetText() then
							DGV:SetPercent(guidename, guideRow)
						end
						--DebugPrint("guidename="..guidename.."*".."gtype"..gtype)
					end
				end
			end
		end
		collectgarbage()
	end

	function DGV:SetPercent(guidename, guideRow)
		local guidesize, unchecked, j, percent
		
		guidesize 	= 	DGV:GetLastGuideNumRows()			
		unchecked 	=	0
		
		for j=1, guidesize do
			local status = DGV:GetQuestState(j,guidename)
			if not status or status == "U" then 
				unchecked = unchecked + 1
			end
		end
		if unchecked == 1  then percent = 100 else percent = 100 - ((unchecked / guidesize) * 100) end
		
		if percent == 0 then
			guideRow:SetText("")
		else
			text = string.format("%.0f",percent)
			guideRow:SetText(text.."%")
			
			red, green, blue, alpha = getColor(percent)
			guideRow:SetTextColor(red, green, blue, alpha)
			--DebugPrint("percent="..percent)
		end
		
	end
	
	local function SetCurrentGuideTabPercentComplete()
		local currentGType = DGV.gtype[CurrentTitle]
		for t = 1, #tabs do 
			local gtype = tabs[t].guidetype
			if gtype==currentGType then
				local guides = gtype and DGV.guidelist[gtype]
				if guides then
					for i = 1, #guides do --Each guide title
						guidename = guides[i]
						if guidename==CurrentTitle then
							DGV:SetPercent(guidename, GetCreateTabRow(t, i).Percent)
						end
					end
				end
			end
		end
	end

	function DGV:SetPercentComplete()

		local percent, i
		local unchecked = 0
		local red, green, blue, alpha
		
		if DGV:isValidGuide(CurrentTitle) == true then
			DugisPercentButtonName:Show()
			for i=1, #visualRows do	
				if DGV:GetQuestState(i) == "U" then unchecked = unchecked + 1 end	
			end
			
			if unchecked == 1  then
				percent = 100
			else
				percent = 100 - ((unchecked / #visualRows) * 100)
			end
				

			local text = string.format("%.0f",percent)
			DugisPercentButtonName:SetText(text.."% "..L["Complete"])
			
			red, green, blue, alpha = getColor(percent)
			DugisPercentButtonName:SetTextColor(red, green, blue, alpha) 

		else
			DugisPercentButtonName:SetText("")
		end
		SetCurrentGuideTabPercentComplete()
	end
	
	local function AddToChains( tbl, key, val)
		key = tonumber(key) 
		val = tonumber(val)
			
		if not key or not val then return end
		
		if tbl[key] and not tContains(tbl[key], val) then
			tinsert( tbl[key], val )
			--DebugPrint("insert val:"..val)
		else
			tbl[key] = {val}
		end
	end

	local ChainsRaw = ""
	function DGV:RegisterQuestChains(text)
		ChainsRaw = ChainsRaw .. text .."\n"
		--print("registered "..#text.." bytes of chains")
		local postReqs = {}
		local breadCrumbs = {}
		local val, id, pos, start
		local lineCount, dbgCount, lineStart,lineEnd,lineText = 1, 1, 1, 0, 1
		
		while (lineStart and dbgCount < 15000) do
			lineStart, lineEnd, lineText = strfind( ChainsRaw, "%s*(.-)%s*\n", lineEnd + 1 )	
			if lineStart then
				if strfind( lineText, "=") then
					local postReq, preReq = lineText:match( "(%d+)%s*=%s*(%d+)" )
					if strfind ( lineText, "OR" ) then
						AddToChains( breadCrumbs, postReq, preReq)
						for val in string.gmatch(lineText,"OR%s*(%d+)") do
							AddToChains( breadCrumbs, postReq, val)
						end
					elseif postReq and preReq then
						AddToChains( postReqs, preReq, postReq)
						for val in string.gmatch(lineText,"AND%s*(%d+)") do
							AddToChains( postReqs, val, postReq)
						end
					end
				elseif strfind( lineText, ",") then
					local preReq, postReq = lineText:match( "(%d+)%s*,%s*(%d+)" )
					local commaSep = {}
					local mainChain = {}
					
					for val in string.gmatch(lineText,"%,([^%,]*)") do tinsert(commaSep, val) end 		--Create chain data split at ','
					for val in string.gmatch(lineText,"[%,AND]%s*(%d+)") do tinsert(mainChain, val) end --Create main chain of qids
					for _, val in pairs(mainChain) do AddToChains( postReqs, preReq, val ) end
									
					for start = 1, #commaSep do	--Add sub chains
						for pos = start+1, #commaSep do
							if strfind ( commaSep[start], "AND" ) then	 
								for id in string.gmatch( commaSep[start], "(%d+)") do
									if start + 1 <= #commaSep then AddToChains( postReqs, id, commaSep[start+1] ) end
								end
							else
								for id in string.gmatch( commaSep[pos], "(%d+)") do
									AddToChains( postReqs, commaSep[start], id)
								end
							end
						end
					end
				end	
			end

			--if lineText then DebugPrint("lineText="..lineText) end
			lineCount = lineCount + 1
			dbgCount = dbgCount + 1
		end
			
		--DebugPrint("###linecount="..lineCount.."dbgCount="..dbgCount)
		self.postReqs = postReqs
		self.breadCrumbs = breadCrumbs
		
		ChainsRaw = ""
	end

	function DGV:UnSkipPostReqs(qid)
		local postNum, postReq
		base = base or 1
		
		if not self.postReqs[qid] or base > 50 then return end
		
		for _, postReq in pairs(self.postReqs[qid]) do	
			self:UnSkip(postReq)
			self:UnSkipPostReqs( postReq, base + 1 )
		end	
	end


	function DGV:UnSkip(qid)
		local guideIndex

		if DGU.toskip[qid] then DGU.toskip[qid] = nil end
		for guideIndex = 1, #visualRows do
			if (DGV.qid[guideIndex] == qid) and (self:GetQuestState(guideIndex) == "X") and strmatch(self.actions[guideIndex], "[ACTNK]") then 
				DGV:ClrChk(guideIndex)
			end
		end
	end

	function DGV:SkipPostReqs(qid, base)
		local postNum, postReq
		base = base or 1

		
		if not self.postReqs[qid] or base > 50 then return end
		
		for _, postReq in pairs(self.postReqs[qid]) do	
			self:Skip(postReq)
			self:SkipPostReqs( postReq, base + 1 )
		end	
	end

	function DGV:Skip(qid)
		local guideIndex
		
		if DGU.toskip[qid] then DGU.toskip[qid] = true end	
		for guideIndex = 1, #visualRows do
			if (DGV.qid[guideIndex] == qid) and (self:GetQuestState(guideIndex) ~= "C") and strmatch(self.actions[guideIndex], "[ACTNK]") then 
				DGV:SetChktoX(guideIndex)
			end
		end
	end

	function DGV:SkipBreadCrumbs(qid)
		local postNum, postReq

		if self.breadCrumbs[qid] then
			for postNum = 1, #self.breadCrumbs[qid] do
				postReq = self.breadCrumbs[qid][postNum]
				self:Skip(postReq)
			end
		end
	end
	
	function DGV:GetToolTipSize(tooltip)
		if tooltip then
			local textobj = _G[tooltip:GetName().."TextLeft1"]
			
			local ttwidth, ttheight = tooltip:GetSize()
			local fwidth = textobj:GetStringWidth()
			local fheight = textobj:GetStringHeight()
			local pad = tooltip:GetPadding()	
			return ttwidth, ttheight, fwidth, fheight, pad
		end
	end

	function DGV:Tooltip_OnEnter(self, event, ...)
		
			local name = self:GetName()
			local text = _G[self:GetName().."Desc"]:GetText()
			
			CreateFrame( "GameTooltip", "LargeFrameTooltip", nil, "GameTooltipTemplate" ); 
			LargeFrameTooltip:SetOwner(_G[name], "ANCHOR_CURSOR")
			LargeFrameTooltip:SetParent(UIParent)
			LargeFrameTooltipTextLeft1:SetFont("Fonts\\FRIZQT__.TTF", 11)
			
			LargeFrameTooltip:SetPadding(5)
			LargeFrameTooltip:AddLine(text, 1, 1, 1, 1,true)
			LargeFrameTooltip:Show()

			--[[
			local ttwidth, ttheight, fwidth, fheight, pad = DGV:GetToolTipSize(LargeFrameTooltip)
			
			--DebugPrint("fwidth:"..fwidth.." fheight:"..fheight.." ttwidth"..ttwidth.." ttheight"..ttheight.." pad"..pad)
			
			local scaleFactor = fwidth / ttwidth
			local maxScale = 1.3
			if (scaleFactor > 1) then
				local newwidth
				if scaleFactor > maxScale then
					scaleFactor = maxScale

				end
				
				if(scaleFactor < 1.10) then
					newwidth = fwidth * 1.10
				else 
					newwidth = ttwidth * scaleFactor
				end
				LargeFrameTooltip:SetWidth(newwidth)
				LargeFrameTooltipTextLeft1:SetWidth(newwidth - 15)
				LargeFrameTooltip:SetHeight(LargeFrameTooltipTextLeft1:GetHeight() + 20)

				ttwidth, ttheight, fwidth, fheight, pad = DGV:GetToolTipSize()
				--DebugPrint("2fwidth:"..fwidth.." fheight:"..fheight.." ttwidth"..ttwidth.." ttheight"..ttheight.." pad"..pad)
			end
			--]]
			LargeFrameTooltip:SetFrameStrata("TOOLTIP")
	end

	function DGV:Tooltip_OnLeave()
		if LargeFrameTooltip then LargeFrameTooltip:Hide() end
	end

	local icontbl = {
		[1] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept.tga", text = "Accept Quest"},
		[2] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin.tga", text = "Turn in Quest"},
		[3] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\partial_cog.tga", text = "General Task"},
		[4] = {path = "Interface\\Minimap\\TRACKING\\Ammunition", text = "Kill NPC"},
		[5] = {path = "Interface\\Minimap\\TRACKING\\Banker", text = "Collect Item"},
		[6] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\speak.tga", text = "Speak to"},
		[7] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\vehicle.tga", text = "Use Vehicle"},		
		[8] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\flightpath.tga", text = "Get Flight Path"},
		[9] = {path = "Interface\\Minimap\\TRACKING\\Auctioneer", text = "Buy Item"},
		[10] = {path = "Interface\\Minimap\\TRACKING\\None", text = "Use Item"},
		[11] = {path = "Interface\\Minimap\\TRACKING\\Profession", text = "Special Note"},
		[12] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\resting.tga", text = "Set Hearthstone"},
		[13] = {path = "Interface\\Minimap\\TRACKING\\Innkeeper", text = "Use Hearthstone"},
		[14] = {path = "Interface\\Minimap\\TRACKING\\FlightMaster", text = "Fly to"},
		[15] = {path = "Interface\\Minimap\\TRACKING\\StableMaster", text = "Travel to"},
		[16] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\multi_daily.tga", text = "Random Daily"},
		[17] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\dungeon.tga", text = "Use Dungeon Finder"},
		[18] = {path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\AchievementIcon.tga", text = "Achievement Task"},		
	}

	function DGV:IsQuestTooHigh(guideIndex)
		local reqLevel = self:GetReqQuestLevel(self.qid[guideIndex])
		if reqLevel and reqLevel >  UnitLevel("player") then return true end
	end

	function DGV:IsQuestTooLow(guideIndex)
		if self:GetQuestDiffColor(guideIndex) == QuestDifficultyColors["trivial"] then
			return true

		end
	end

	function DGV:getIcon(objectiveType, i)
		local isDaily, isDungeon, isTooHigh, isKill, isCollect, button, isAlchemy, isBlacksmith, isCooking, isDisenchant, isEnchanting, isEngineering, isFishing, isFirstaid, isHerb, isInscription, isJewel, isLeather, isMining, isSkinning, isSmelting, isTailoring, isMount, isCompanion, isClass, isTabard, isQpart, isSpeak, isVehicle, isMulti, isAchievement, isAchievementpart, isLoot, isUse
		
		button = visualRows[i].Button
		isTooHigh = self:IsQuestTooHigh(i)
		if button and not isTooHigh and button.validTexture then
			return button.validTexture
		elseif button and isTooHigh and button.tooHighTexture then
			return button.tooHighTexture
		end
		
		if (DGV.daily[i]) then isDaily = true end
		if (DGV:ReturnTag("I", i)) then isDungeon = true end
		if (DGV:ReturnTag("K", i)) then isKill = true end
		if (DGV:ReturnTag("T", i)) then isCollect = true end
		if (DGV:ReturnTag("AL", i)) then isAlchemy = true end
		if (DGV:ReturnTag("BL", i)) then isBlacksmith = true end
		if (DGV:ReturnTag("CO", i)) then isCooking = true end
		if (DGV:ReturnTag("DI", i)) then isDisenchant = true end
		if (DGV:ReturnTag("ENC", i)) then isEnchanting = true end
		if (DGV:ReturnTag("ENG", i)) then isEngineering = true end
		if (DGV:ReturnTag("FIS", i)) then isFishing = true end
		if (DGV:ReturnTag("FIR", i)) then isFirstaid = true end
		if (DGV:ReturnTag("HE", i)) then isHerb = true end
		if (DGV:ReturnTag("IN", i)) then isInscription = true end	
		if (DGV:ReturnTag("JE", i)) then isJewel = true end
		if (DGV:ReturnTag("LE", i)) then isLeather = true end
		if (DGV:ReturnTag("MI", i)) then isMining = true end
		if (DGV:ReturnTag("SK", i)) then isSkinning = true end
		if (DGV:ReturnTag("SM", i)) then isSmelting = true end
		if (DGV:ReturnTag("TA", i)) then isTailoring = true end
		if (DGV:ReturnTag("MO", i)) then isMount = true end
		if (DGV:ReturnTag("COM", i)) then isCompanion = true end
		if (DGV:ReturnTag("CL", i)) then isClass = true end
		if (DGV:ReturnTag("TAB", i)) then isTabard = true end
		if (DGV:ReturnTag("QIDP", i)) then isQpart = true end
		if (DGV:ReturnTag("S", i)) then isSpeak = true end
		if (DGV:ReturnTag("V", i)) then isVehicle = true end
		if (DGV:ReturnTag("MD", i)) then isMulti = true end
		if (DGV:ReturnTag("AID", i)) then isAchievement = true end
		if (DGV:ReturnTag("AC", i)) then isAchievementpart = true end
		if (DGV:ReturnTag("L", i)) then isLoot = true end
		if (DGV:ReturnTag("U", i)) then isUse = true end
		
		if isTooHigh and objectiveType == "A" then
			button.tooHighTexture = self.ARTWORK_PATH.."accept_g.tga"	
			return button.tooHighTexture		
		elseif isTooHigh and objectiveType == "T" then
			button.tooHighTexture = self.ARTWORK_PATH.."turnin_g.tga"
			return button.tooHighTexture		
		elseif isDaily and objectiveType == "A" then
			button.validTexture = self.ARTWORK_PATH.."accept_d.tga"
			return button.validTexture	
		elseif isDungeon then
			--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\dungeon.tga" 
			button.validTexture = icontbl[17].path
			return button.validTexture	
		elseif isAlchemy then
			button.validTexture = self.ARTWORK_PATH.."alchemy.tga" 
			return button.validTexture
		elseif isBlacksmith then
			button.validTexture = self.ARTWORK_PATH.."blacksmithing.tga" 
			return button.validTexture
		elseif isCooking then
			button.validTexture = self.ARTWORK_PATH.."cooking.tga" 
			return button.validTexture
		elseif isDisenchant then
			button.validTexture = self.ARTWORK_PATH.."disenchant.tga" 
			return button.validTexture
		elseif isEnchanting then
			button.validTexture = self.ARTWORK_PATH.."enchanting.tga" 
			return button.validTexture
		elseif isEngineering then
			button.validTexture = self.ARTWORK_PATH.."engineering.tga" 
			return button.validTexture
		elseif isFishing then
			button.validTexture = self.ARTWORK_PATH.."fishing.tga" 
			return button.validTexture
		elseif isFirstaid then
			button.validTexture = self.ARTWORK_PATH.."firstaid.tga" 
			return button.validTexture
		elseif isHerb then
			button.validTexture = self.ARTWORK_PATH.."herbalism.tga" 
			return button.validTexture
		elseif isInscription then
			button.validTexture = self.ARTWORK_PATH.."inscription.tga" 
			return button.validTexture
		elseif isJewel then
			button.validTexture = self.ARTWORK_PATH.."jewelcrafting.tga" 
			return button.validTexture
		elseif isLeather then
			button.validTexture = self.ARTWORK_PATH.."leatherworking.tga" 
			return button.validTexture		
		elseif isMining then
			button.validTexture = self.ARTWORK_PATH.."mining.tga" 
			return button.validTexture
		elseif isSkinning then
			button.validTexture = self.ARTWORK_PATH.."skinning.tga" 
			return button.validTexture
		elseif isSmelting then
			button.validTexture = self.ARTWORK_PATH.."smelting.tga" 
			return button.validTexture		
		elseif isTailoring then
			button.validTexture = self.ARTWORK_PATH.."tailoring.tga" 
			return button.validTexture
		elseif isMount then
			button.validTexture = self.ARTWORK_PATH.."mount.tga" 
			return button.validTexture
		elseif isCompanion then
			button.validTexture = self.ARTWORK_PATH.."companion.tga" 
			return button.validTexture
		elseif isClass then
			button.validTexture = "Interface\\Minimap\\TRACKING\\Class" 
			return button.validTexture
		elseif isTabard then
			button.validTexture = self.ARTWORK_PATH.."tabard.tga" 
			return button.validTexture		
		elseif (objectiveType == "K" ) and (isLoot or isCollect) then
			button.validTexture = self.ARTWORK_PATH.."kill_collect.tga"
			return button.validTexture		
		elseif isMulti then
			--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\multi_daily.tga"
			button.validTexture = icontbl[16].path
			return button.validTexture			
		elseif (objectiveType == "A" ) then 
			--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept.tga"
			button.validTexture = icontbl[1].path
			return button.validTexture
		elseif (objectiveType == "C") then
			if isKill and isCollect then 
				--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\kill_collect.tga"
				button.validTexture = self.ARTWORK_PATH.."kill_collect.tga"
				return button.validTexture
			elseif isKill and isSpeak then
				button.validTexture = self.ARTWORK_PATH.."speak_kill.tga" 
				return button.validTexture		
			elseif isKill and isUse then 
				button.validTexture = self.ARTWORK_PATH.."cog_kill.tga" 
				return button.validTexture
			elseif isKill then 
				--return "Interface\\Minimap\\TRACKING\\Ammunition"
				button.validTexture = icontbl[4].path
				return button.validTexture				
			elseif isCollect then 
				--return "Interface\\Minimap\\TRACKING\\Banker"
				button.validTexture = icontbl[5].path
				return button.validTexture						
			elseif isSpeak then
				button.validTexture = icontbl[6].path
				return button.validTexture				
			else
				--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\partial_cog.tga"
				button.validTexture = icontbl[3].path
				return button.validTexture
			end
		elseif (objectiveType == "T") then
			--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin.tga"
			button.validTexture = icontbl[2].path
			return button.validTexture
		elseif isVehicle then
			if isSpeak then 
				button.validTexture = self.ARTWORK_PATH.."speak_vehicle.tga" 
				return button.validTexture
			else
				button.validTexture = self.ARTWORK_PATH.."vehicle.tga"
				return button.validTexture
			end								
		elseif (objectiveType == "R") then 
			--return "Interface\\Minimap\\TRACKING\\StableMaster"
			if isSpeak then 
				button.validTexture = self.ARTWORK_PATH.."speak_vehicle.tga" 
				return button.validTexture
			else
				button.validTexture = icontbl[15].path 
				return button.validTexture
			end
		elseif (objectiveType == "F" ) then 
			--return "Interface\\Minimap\\TRACKING\\FlightMaster"
			button.validTexture = icontbl[14].path
			return button.validTexture
		elseif (objectiveType == "b" ) then 
			--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waves.tga"
			button.validTexture = icontbl[15].path
			return button.validTexture		
		elseif (objectiveType == "H" ) then  
			--return "Interface\\Minimap\\TRACKING\\Innkeeper"
			button.validTexture = icontbl[13].path
			return button.validTexture			
		elseif (objectiveType == "B" ) then 
			--return "Interface\\Minimap\\TRACKING\\Auctioneer"
			button.validTexture = icontbl[9].path
			return button.validTexture			
		elseif (objectiveType == "U" ) then  
			--return "Interface\\Minimap\\TRACKING\\None"
			button.validTexture = icontbl[10].path
			return button.validTexture			
		elseif (objectiveType == "h" ) then 
			--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\resting.tga"
			button.validTexture = icontbl[12].path
			return button.validTexture
		elseif (objectiveType == "f") then 
			--return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\flightpath.tga"
			button.validTexture = icontbl[8].path
			return button.validTexture				
		elseif isAchievementpart then
			button.validTexture = self.ARTWORK_PATH.."AchievementIcon_p.tga" 
			return button.validTexture	
		elseif isAchievement then
			button.validTexture = icontbl[18].path 
			return button.validTexture							
		elseif (objectiveType == "N" ) and isQpart then  
			if isSpeak then 
				button.validTexture = self.ARTWORK_PATH.."speak.tga" 
				return button.validTexture
			elseif isCollect and isKill then
				button.validTexture = self.ARTWORK_PATH.."kill_collect.tga"
				return button.validTexture
			elseif isCollect then
				button.validTexture = icontbl[5].path
				return button.validTexture				
			elseif isKill and isUse then
				button.validTexture = self.ARTWORK_PATH.."cog_kill.tga" 
				return button.validTexture
			elseif isKill then
				button.validTexture = icontbl[4].path 
				return button.validTexture							
			else
				button.validTexture = icontbl[3].path
				return button.validTexture
			end		
		elseif isLoot then
			button.validTexture = icontbl[5].path
			return button.validTexture		
		elseif (objectiveType == "N" ) then  
			button.validTexture = icontbl[11].path
			return button.validTexture		
		else-- (objectiveType == "K" ) then  
			--return "Interface\\Minimap\\TRACKING\\Ammunition"
			button.validTexture = icontbl[4].path
			return button.validTexture		
		end		
	end


	function DGV:HasCoord(guideIndex)
		local coord = "%(([%d.]+),%s?([%d.]+)%)"
		local note = DGV.quests2[guideIndex]
		if note:find(coord) or DGV:ReturnTag("PPOS", guideIndex) then 
			return true 
		end
	end

	--Return a table of current coordinates from the Note tag
	function DGV:getCoords(guideIndex)

		local XYVals = {}
		local coord = "%(([%d.]+),%s?([%d.]+)%)"
		local note = DGV.quests2[guideIndex]
		local x, y
		
		if note:find(coord) then
			for x,y in note:gmatch(coord) do
				--if self:UserSetting(DGV_CARBONITEARROW) then --hax: return backwards
				--	table.insert(XYVals, 1, {tonumber(x), tonumber(y)})
				--else
					table.insert(XYVals, {tonumber(x), tonumber(y)})
				--end
			end
		end
		return XYVals
	end

	local xyzon
	function DGV:Retxyz(t, i)
			if i == 1 and t == "AAA" then
				xyzon = true
				t = ""
			elseif i == 1 then
				xyzon = false
			end
			
			if xyzon then
				local textd = ""
				local chard
				local data = 0
				for j = 1, #t do
					local c = t:sub(j,j)
					local cb = string.byte(c, 1)
					local k = 3
					chard = ""
					if cb < 128 - k then 
						chard = string.char(cb + k) 
					elseif cb < 192  then 
						local joined = bit.bor(bit.band(63, cb), data) 	
						joined = joined + k
						local upper2 = bit.bor(bit.rshift(bit.band(192,joined), 6), 192) 
						local lower2 = bit.bor(bit.band(63, joined), 128) 
						chard = string.char(upper2)..string.char(lower2)
					elseif cb < 224  and cb > 193  			then 
						data = bit.lshift(bit.band(3, cb),6)
					else
						DebugPrint("Range Err")
					end	
					textd = textd..chard
				end
				t = textd
				--DebugPrint("t="..t)
			end
		return t
	end

	--Parse rows and fill up 3 items: Objective type (actions), Quest name, Note Tag (actions, quests, tags)
	function DGV:ParseRows(guidetitle, rowinfo,...)
		local i
		local indx = 1
		local myClass 	= DGV:revlocalize(UnitClass("player"), "CLASS")	
		local myRace 	= DGV:revlocalize(UnitRace("player"), "RACE")
		local myGender
		if UnitSex("player") == 3 then myGender = "Female" else myGender = "Male" end 
		
		--Clear old data from tables
		
		--[[
		local key, value
		for key, value in pairs(DGV.actions) do
			DGV.actions[key] = nil
			DGV.quests1[key] = nil
			DGV.quests1L[key] = nil
			DGV.quests2[key] = nil
		end
		--]]
		--[[DGV.actions = {}
		DGV.quests1 = {}
		DGV.quests1L = {}
		DGV.quests2 = {}]]
		wipe(DGV.actions)
		wipe(DGV.quests1)
		wipe(DGV.quests1L)
		wipe(DGV.quests2)
		
		--Loop through all rows
		for i = 1, select ("#", ...) do
			local text = select(i, ...)

			text = self:Retxyz(text, i)
			--if i < 5 then DebugPrint("text="..text) end
			local _, _, classes 	= text:find("|C|([^|]+)|")         
			local _, _, races 		= text:find("|R|([^|]+)|")             	
			local _, _, daily 		= text:find("(|D|)")
			local _, _, gender 		= text:find("|G|([^|]+)|")
			
				if text ~= "" and (not classes or classes:find(myClass)) and (not races or races:find(myRace)) and (not gender or myGender == gender) then
					
					local _, _, action, quest, tag = text:find("^(%a) ([^|]*)(.*)") 
					
					if action and quest then 
						action=action:trim()
						quest = quest:trim()
						--Find Use items
						local _, _, useitem = tag:find("|U|([^|]+)|") 
						DGV.useitem[indx] = useitem

						--If there is a second objective line, retrieve that
						local quest2, questtest
						questtest = tag
						local _, _, questtest = questtest:find("|[NW]R?|([^|]+)|")
						if questtest then
						quest2 = questtest
						else
						quest2 = ""
						end


						local qid = tag:match("|QID|(%d+)")
						qid = tonumber(qid)
						
						DGV.actions[indx] = action:trim()
						DGV.quests1[indx] = quest:trim()
						DGV.quests1L[indx] = quest:trim()
						DGV.quests2[indx] = quest2:trim()
						DGV.tags[indx] = tag
						DGV.qid[indx] = qid
						DGV.daily[indx] = daily
						indx = indx + 1
					end
			end
		end
	end
	
	function DGV:InBag(itemid)
		local bag, slot
		if itemid then
			for bag=0,4 do
				for slot=1,GetContainerNumSlots(bag) do
					local item = GetContainerItemLink(bag, slot)
					if item and string.find(item, "item:"..itemid) then return true end
				end
			end
		end
		return false
	end

	--Fill screen with 3 items: Objective type (actions), Quest name, Note Tag (actions, quests, tags)
	function DGV:PopulateObjectives(title, SearchMode)
		--DGV:DebugFormat("PopulateObjectives", "stack", debugstack())
			local numrows = 0
			local rowspacing = 0
			crowheight = 34.4
			local i
			local rowObj
			local SearchResults = {}
			
			SuspendViewFrameUpdate()

		
			--Clear any old data
			for i =1, #visualRows do
				rowObj = visualRows[i]
				rowObj:Hide()
				rowObj:SetNormalTexture("")
				rowObj.Name:SetText("")
				rowObj.Desc:SetText("")
				--DGV:SetQuestTextNormal(i)
			end
			wipe(visualRows)	
			
			self:SetViewTabTitle(self:GetFormattedTitle(title))
					
			for i = 1 , #DGV.actions do 
				
				local dgvRowName = "DGVRow"..i
				rowObj 	= _G[dgvRowName]
				if rowObj == nil then
					rowObj = CreateFrame("Button", dgvRowName, currentGuideTabInfo.RightFrame, "DugisQuestRowTemplate")
				end
				rowObj:Show()
				rowObj:ClearAllPoints()
				visualRows[i] = rowObj
				DGV:SetQuestTextNormal(i)

				-- set optimization fields
				rowObj.Button.validTexture = nil
				rowObj.Button.tooHighTexture = nil
				rowObj.Name.levelText = nil
				rowObj.Desc:SetText(gsub(DGV.quests2[i], "(%[[^%]]+%])", "|cfff0c502%1|r"))
				rowObj.Opt.text = nil
				rowObj.Opt.pre = nil
				rowObj.Opt.rep = nil
				rowObj.Opt.standing = nil
				rowObj.Opt.friend = nil
				rowObj.Opt.level = nil				
				rowObj.Opt.optional = nil
				--visualRows[i] = rowObj
				
				if not SearchMode then 
					if i == 1 then rowObj:SetPoint("TOPLEFT", 0, -3) else rowObj:SetPoint("TOP", visualRows[i-1], "BOTTOM", 0, rowspacing )  end
				
				else
					if self.Search:InSearchResults( i ) then
						if SearchResults[1] == nil then
							--DebugPrint("FIRST Search result #"..i)
							rowObj:SetPoint("TOPLEFT", 0, -3)
						else
							--DebugPrint("Search result #"..i.." anchored to"..SearchResults[#SearchResults])					
							rowObj:SetPoint("TOP", "DGVRow"..SearchResults[#SearchResults], "BOTTOM", 0, rowspacing ) 
						end
						table.insert(SearchResults, i)
					else
						rowObj:Hide()
					end
				end
				
				rowObj.Chk:SetChecked(0)
				rowObj.Chk:Show()
				rowObj.Chk:RegisterForClicks("LeftButtonUp", "RightButtonUp")
				rowObj.Button:SetNormalTexture(DGV:getIcon(DGV.actions[i], i ))	
				
				
				if not self:HasCoord(i) then rowObj.WayPoint:Disable() else rowObj.WayPoint:Enable() end
				if self:ReturnTag("NT", i) then rowObj.Chk:Disable() else rowObj.Chk:Enable() end
				
				--DGV:SetQuestText(i)
				--DGV:SetQuestColor(i)
				
				numrows = numrows + 1
			end

			local fwidth = DGV:GetFontWidth(L["Reload"])


			DugisReloadButton:SetText(L["Reload"]) 
			DugisReloadButton:SetWidth(fwidth + 20)
			
			fwidth = DGV:GetFontWidth(L["Reset"])
			DugisResetButton:SetText(L["Reset"])
			DugisResetButton:SetWidth(fwidth + 20)
			
			--[[fwidth = DGV:GetFontWidth(L["Suggest"])
			DugisSuggestButton:SetText(L["Suggest"])
			DugisSuggestButton:SetWidth(fwidth + 35)]]
			
			--[[fwidth = DGV:GetFontWidth(L["Preload"])
			DugisPreloadButton:SetText(L["Preload"])
			DugisPreloadButton:SetWidth(fwidth + 35)]]		
			
			activeTabInfo.rightScrollMax = (crowheight * numrows)
			if activeTabInfo.rightScrollMax<=1 then activeTabInfo.rightScrollMax = activeTabInfo.RightFrame:GetHeight() end
			
			--LastGuideNumRows = numrows
			--ResumeViewFrameUpdate() --SetQuestsState() will ResumeViewFrame
	end

	function DGV:SetQuestText( i ) 
		
		local qName 	= DGV.quests1L[i]

		local level 	= DGV:GetQuestLevel(self.qid[i])
		local questpart = self:ReturnTag("QIDP", i)
		
		local Row = GetVisualRow(i)
		
		if (level and strmatch(self.actions[i], "[ACT]") and self:UserSetting(DGV_QUESTLEVELON)) or (level and questpart and strmatch(self.actions[i], "[NK]") and self:UserSetting(DGV_QUESTLEVELON)) then
			if not Row.Name.levelText and DGV.Localize == 0 then
				Row.Name.levelText = string.format("[%d] %s", level, qName)
			end
			qName = Row.Name.levelText
		end
		
		if Row.Name:GetText()~=qName then --optimization
			local width = self:GetFontWidth(qName)	
			Row.Name:SetWidth(width + 10)	
			Row.Name:SetText(qName)
		end
		
		if DGV:CheckForSkip(i) then CheckInitOpt(i) end
		Row.Opt:SetText(Row.Opt.text)
		
		if (Row.Opt.optional or
			Row.Opt.prof or 
			(Row.Opt.pre and not EvaluatePRE(Row.Opt.pre)) or 
			(Row.Opt.pha and not EvaluatePHA(Row.Opt.pha)) or 			
			(Row.Opt.rep and not EvaluateREP(Row.Opt.rep, Row.Opt.standing))) or 
			(Row.Opt.friend and not EvaluateFS(Row.Opt.friend, Row.Opt.level)) then
			Row.Opt:Show()
		else
			Row.Opt:Hide()	
		end
	end

	-- 
	-- Tab Functions
	--

	-- function DGV:SaveLastScrollBar(lasttab)
		-- SliderVal[lasttab] = Dugis_VSlider:GetValue()
	-- end

	-- function DGV:RestoreScrollBar(currenttab)
		-- DGV:DebugFormat("RestoreScrollBar", "currenttab", currenttab, "SliderVal[currenttab]", SliderVal[currenttab], "SliderMax[currenttab]", SliderMax[currenttab])
		-- Dugis_VSlider:SetValue(SliderVal[currenttab])
		-- Dugis_VSlider:SetMinMaxValues(1, SliderMax[currenttab])
	-- end

	function DGV:ShowViewTab()
		Main.currentGuideTab:GetScript("OnClick")(Main.currentGuideTab)
	end

	function DGV:SetViewTabTitle(title)
		Main.title:SetText(title)
	end

	--Update the guide level range on guide listings when difficulty is changed

	function DGV:TabTextRefresh()
		local i, GuideRow
		
		DGV:SetViewTabTitle(self:GetFormattedTitle(CurrentTitle))
		
		for i = 1, #tabs do
			local TabInfo	= tabs[i]
					

			local gtype = TabInfo.guidetype
			if gtype then
				if DGV.guidelist[gtype] then
					for j =1 , #DGV.guidelist[gtype] do  				
						GuideRow = _G["DugisTab"..i.."Row"..j]
						GuideRow.Title:SetText(self:GetFormattedTitle(DGV.guidelist[gtype][j]))
					end
				else
					GuideRow = _G["DugisTab"..i.."Row"..1]
					GuideRow.Title:SetText(L["No Guide Loaded"])
				end
			end
		end
	end
	
	local ToggleCollapsed
	Guides.rowHeadings = {}
	if not DGU.subCategoriesExpanded then
		DGU.subCategoriesExpanded = {}
	end
	
	--Load a guide from a tab
	function DugisGuideViewer_TabRow_OnEvent(self, event, ...)

		if tContains(Guides.rowHeadings, self) then
			ToggleCollapsed(self)
			return
		end
		
		local rowtitle = _G[self:GetName().."Title"]:GetText()
		
		if rowtitle ~= L["No Guide Loaded"] and not rowtitle:find("__") then
			--DGV:DisplayViewTab(DGV:GetRawTitle(rowtitle))
			--DebugPrint("rowtitle"..rowtitle.."_GetTitleName".._GetTitleName(rowtitle).."*".."titlename"..DGV:GetRawTitle(_GetTitleName(rowtitle)))
			--DGV:DisplayViewTab(DGV:GetRawTitle(_GetTitleName(rowtitle)))

			DGV:DisplayViewTab(DGV:GetRawTitle(rowtitle))
			print("|cff11ff11Dugi Guides: |r"..DGV:GetFormattedTitle(rowtitle).."|cff11ff11 selected.|r")
		end
	end
	
	local _G = _G
	local function EnumerateTabRows(invariant, control)
		if not control then
			control = 1
		else
			control = control + 1
		end
		local result = _G[format("DugisTab%dRow%d", invariant, control)]
		return result and control, result
	end
	
	local function SetCollapsedBehavior(label)
		local expandedKey = ((not label.originalTabNum and "") 
			or label.originalTabNum)..label.headingTitle
		local expanded = DGU.subCategoriesExpanded and DGU.subCategoriesExpanded[expandedKey]
		for i,row in EnumerateTabRows,label.tabNum do
			local affectShown = DGV.headings[row.title]==label.headingTitle 
					and (not label.originalTabNum or label.originalTabNum==row.originalTabNum)
			if not affectShown then
				affectShown = row:GetParent()==label and row.title
			end
			if affectShown then
				if expanded and (label.tabNum~=SEARCH_TAB or
						DGV.Search:InSearchResults(DGV.headings[row.title],
							DGV:GetFormattedTitle(row.title))) 
				then
					row:Show()
				else 
					row:Hide()
				end
			end
		end
		
		for _,rh in ipairs(Guides.rowHeadings) do
			if rh.anchor==label then
				rh:SetPoint(
					"TOP", 
					(expanded and label.lastChild) or label, 
					"BOTTOM", 0, -5)
			end
		end
		
		if expanded then
			label:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
		else
			label:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
		end
	end
	
	local function SetAllHeaderStates()
		for _,headerLabel in ipairs(Guides.rowHeadings) do
			SetCollapsedBehavior(headerLabel)
		end
	end
	
	ToggleCollapsed = function(label, event, button)
		local expandedKey = ((not label.originalTabNum and "") 
			or label.originalTabNum)..label.headingTitle
		if not DGU.subCategoriesExpanded then
			DGU.subCategoriesExpanded = {}
		end
		DGU.subCategoriesExpanded[expandedKey] = 
			not DGU.subCategoriesExpanded[expandedKey]
		SetCollapsedBehavior(label)
	end
	
	local function VerifyRank(rank, minimum, maximum)
		if minimum and rank<minimum then return end
		if maximum and rank>=maximum then return end
		return true
	end
	
	function DGV.SuggestProfessionGuidePredicate(englishProfArg1, minRank1, maxRank1, englishProfArg2, minRank2, maxRank2)
		local profIndex1, profIndex2 = GetProfessions()
		local localProf1, rank1
		if profIndex1 then localProf1, _, rank1 = GetProfessionInfo(profIndex1) end
		local localProf2, rank2
		if profIndex2 then localProf2, _, rank2 = GetProfessionInfo(profIndex2) end
		local localProfArg1 = L[englishProfArg1]
		local matchArg1 = (localProfArg1==localProf1 and VerifyRank(rank1, minRank1, maxRank1)) or (localProfArg1==localProf2 and VerifyRank(rank2, minRank1, maxRank1))
		if matchArg1 and not englishProfArg2 then return true end
		if englishProfArg2 then
			local localProfArg2 = L[englishProfArg2]
			local matchArg2 = (localProfArg2==localProf1 and VerifyRank(rank1, minRank2, maxRank2)) or (localProfArg2==localProf2 and VerifyRank(rank2, minRank2, maxRank2))
			return matchArg1 and matchArg2
		end
	end
	
	function DGV.SuggestCurrentHolidayPredicate(guideTextureBase)
		for index, _, _, textureBase in IterateCurrentHolidays do
			if textureBase==guideTextureBase then return true end
		end
	end
	
	function DGV.SuggestReputationAchievementPredicate(reputation)
		local _, _, standingId = GetFactionInfoByID(reputation)
		if standingId<8 then return true end
	end
	
	function DGV.SuggestQuestAchievementPredicate(qid)
		local isCompleted = IsQuestFlaggedCompleted(qid) 
		if isCompleted then return true end
	end	
	
	local function IterateSuggestedGuides(invariant, control)
		if invariant=="I" or invariant=="L" then
			for guideInRange,minimum in IterateGuidesInRange,nil,control do
				if DGV.gtype[guideInRange] == invariant then
					return guideInRange
				end
			end
		else
			while true do
				control = next(DGV.guides, control)
				if not control then return end
				if DGV.gtype[control] == invariant then
					if DGV:ReturnGuideTag("SG", control) then
						return control
					end
				end
			end
		end
	end
	
	PopulateSuggestedGuides = function()
		local yofs = -5
		local rowheight = 14
		local rowCount = 0
		local lastHeading
		
		for _,rh in ipairs(Guides.rowHeadings) do
			if rh.tabNum==SUGGEST_TAB then
				rh:ClearAllPoints()
				for _,row in EnumerateTabRows,SUGGEST_TAB do
					row.title = nil
					row:Hide()
				end
				rh:Hide()
			end
		end
		for _,tabInfo in ipairs(tabs) do
			if tabInfo.guidetype then
				local headingLabel = nil
				for guide in IterateSuggestedGuides,tabInfo.guidetype do
					if not headingLabel then
						headingLabel = GetCreateRowHeading(SUGGEST_TAB)
						headingLabel.headingTitle = tabInfo.title
						headingLabel.Title:SetText("|cfff0c502"..headingLabel.headingTitle.."|r")
					end
					rowCount = rowCount +1
					local guideRow = GetCreateTabRow(SUGGEST_TAB, rowCount)
					guideRow:Show()
					guideRow:SetParent(headingLabel)
					headingLabel.lastChild = guideRow
					if lastHeading~=headingLabel then
						guideRow:SetPoint("TOPLEFT", headingLabel, "BOTTOMLEFT", 0, -5 ) 
					else 
						guideRow:SetPoint("TOPLEFT", "DugisTab"..SUGGEST_TAB.."Row"..rowCount-1, "BOTTOMLEFT", 0, yofs) 
					end
					lastHeading = headingLabel
					guideRow.Title:SetText(DGV:GetFormattedTitle(guide))
					guideRow.Title:Show()
					guideRow.title = guide
				end
			end
		end
		SetAllHeaderStates()
		local tabInfo = tabs[SUGGEST_TAB]
		tabInfo.rightScrollMax = rowheight * rowCount +  50
	end
	
	function DGV:InitializeTabs()
		local yofs = -5
		local rowheight = 14
		local i, j, SettingNum, IconNum
		local GuideRow

		Main.homeTab.tabInfo = tabs[1]
		Main.currentGuideTab.tabInfo = tabs[2]
		Main.settingsTab.tabInfo = tabs[3]
		DGV:CreateSettingsTree(tabs[3].RightFrame)
		tabs[3]:Activate()
		PopulateSuggestedGuides()

		for i = 4, #tabs do
			local selection	= DGVHomeFrame["selection"..i-3]
			local TabInfo	= tabs[i]
			selection.tabInfo = TabInfo
			
			selection.text:SetText(L[TabInfo.text])
			local texture = TabInfo.icon
			if type(texture)=="function" then
				texture(selection.icon)
			else
				selection.icon:SetTexture(texture)
			end
			selection.tooltip = L[TabInfo.title]
			

			if TabInfo.text == "Help" then
				--For technical support please contact:
				if not DGV_HelpURLEditBox then
					local logo = CreateFrame("Button", nil, TabInfo.RightFrame)
					logo:SetNormalTexture([[Interface\AddOns\DugisGuideViewerZ\Artwork\logo.tga"]])
					logo:SetPoint("TOPLEFT", -30, 0)
					logo:SetHeight(64)
					logo:SetWidth(256)

					local techSupport = TabInfo.RightFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
					techSupport:SetText(L["For technical support please contact:"])
					techSupport:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", 16, 0)
					
					local helpUrl = CreateFrame("EditBox", "DGV_HelpURLEditBox", TabInfo.RightFrame)
					helpUrl:SetFontObject(GameFontHighlight)
					helpUrl:SetTextInsets(2,2,2,2)
					helpUrl:SetMultiLine(true)
					helpUrl:SetAutoFocus(false)
					local setText = 
						function() 
							helpUrl:SetText("http://www.dugiguides.com/support/")
						end
					setText()
					helpUrl:SetScript("OnTextChanged", function(self, user) if user then setText();helpUrl:HighlightText(); end end)

					helpUrl:SetScript("OnEditFocusGained", function() helpUrl:HighlightText() end)
					helpUrl:SetScript("OnMouseDown", function() helpUrl:HighlightText() end)
					helpUrl:SetScript("OnEditFocusLost", function() helpUrl:HighlightText(0,0) end)
					helpUrl:SetPoint("TOPLEFT", techSupport, "BOTTOMLEFT", 0, 0)
					helpUrl:SetWidth("500")
					helpUrl:SetHeight("20")
					helpUrl:Show()
					
					local videoTutorial = TabInfo.RightFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
					videoTutorial:SetText(L["Video tutorials are available from the link below:"])
					videoTutorial:SetPoint("TOPLEFT", DGV_HelpURLEditBox, "BOTTOMLEFT", 0, -16)
					
					local videoUrl= CreateFrame("EditBox", "DGV_VideoURLEditBox", TabInfo.RightFrame)
					videoUrl:SetFontObject(GameFontHighlight)
					videoUrl:SetTextInsets(2,2,2,2)
					videoUrl:SetMultiLine(true)
					videoUrl:SetAutoFocus(false)
					local setText = 
						function() 
							videoUrl:SetText("http://www.dugiguides.com/videos/")
						end
					setText()
					videoUrl:SetScript("OnTextChanged", function(self, user) if user then setText();videoUrl:HighlightText(); end end)
					videoUrl:SetScript("OnEditFocusGained", function() videoUrl:HighlightText() end)
					videoUrl:SetScript("OnMouseDown", function() videoUrl:HighlightText() end)
					videoUrl:SetScript("OnEditFocusLost", function() videoUrl:HighlightText(0,0) end)
					videoUrl:SetPoint("TOPLEFT", videoTutorial, "BOTTOMLEFT", 0, 0)
					videoUrl:SetWidth("500")
					videoUrl:SetHeight("20")
					videoUrl:Show()		
									
					local iconRefHeading = TabInfo.RightFrame:CreateFontString(nil,"ARTWORK", "GameFontNormalLarge")
					iconRefHeading:SetText(L["Icon Reference"])
					iconRefHeading:SetPoint("TOPLEFT", DGV_VideoURLEditBox, "BOTTOMLEFT", 0, -16) 
				
					local wrow1 = 0
					local wrow2 = 0
					local wrow3 = 0
					local wmax = 0
					for IconNum = 1, #icontbl do
						local width = self:GetFontWidth(L[icontbl[IconNum].text], "GameFontHighlight")
						if width > wmax then wmax = width end
					
						if IconNum == 6 then
							wrow1 = wmax
							wmax = 0
						elseif IconNum == 12 then
							wrow2 = wmax
							wmax = 0
						elseif IconNum == #icontbl then
							wrow3 = wmax
							wmax = 0
						end
						
					end
					
					for IconNum = 1, #icontbl do
						local icon = CreateFrame("Button", "DGV_Settingsicon"..IconNum, TabInfo.RightFrame, "IconReferenceTemplate")
									
						icon.Button:SetNormalTexture(icontbl[IconNum].path)
						icon.Name:SetText(L[icontbl[IconNum].text])
						icon.Name:SetJustifyH("LEFT")
						
						if IconNum < 7 then icon:SetWidth(wrow1 + 50) icon.Name:SetWidth(wrow1 + 50) elseif IconNum < 13 then icon:SetWidth(wrow2 + 50) icon.Name:SetWidth(wrow2 + 50) elseif IconNum < 19 then icon:SetWidth(wrow3 + 50) icon.Name:SetWidth(wrow3 + 50)  end
						if IconNum == 1 then
							icon:SetPoint("TOPLEFT", iconRefHeading, "BOTTOMLEFT",  5, 0)

							--icon:SetPoint("TOPLEFT", 20, -20) 
						elseif IconNum == 7 then
							icon:SetPoint("LEFT", "DGV_Settingsicon1", "RIGHT", -15, 0)
						elseif IconNum == 13 then
							icon:SetPoint("LEFT", "DGV_Settingsicon7", "RIGHT", -15, 0)	
						else
							icon:SetPoint("TOP", "DGV_Settingsicon"..(IconNum-1), "BOTTOM", 0, 13)
						end				
					end
				end
			end
			
			
			
			--[[if i == SIDE_TAB_START then 
				TabFrame.Icon:SetPoint("TOPLEFT", "DugisMainframe", "TOPRIGHT", "0", "-22" ) 
			else
				TabFrame.Icon:SetPoint("TOP", _G["DugisTab"..(i-1).."Icon"], "BOTTOM", "0", "-15" ) 
			end]]
		
			--[[TabFrame.Title:SetText(L[TabInfo.title])
			TabFrame.Desc:SetText(L[TabInfo.desc])		
			TabFrame.Desc:SetWidth(500)]]
			
			
			local gtype = TabInfo.guidetype
			if gtype then
				if DGV.guidelist[gtype] then
					if not TabInfo.RightFrame.panel then
						TabInfo.RightFrame.panel = CreateFrame("Frame", nil, TabInfo.RightFrame, "DugisSelectionPanelTemplate")
						TabInfo.RightFrame.panel:SetPoint("TOPLEFT", 10, -5)
						if type(texture)=="function" then
							texture(TabInfo.RightFrame.panel.icon)
						else
							TabInfo.RightFrame.panel.icon:SetTexture(texture)
						end
						TabInfo.RightFrame.panel.text:SetText(L[TabInfo.text])
					end
					local lastHeading
					for j =1 , #DGV.guidelist[gtype] do
						local title = DGV.guidelist[gtype][j]
						local headingLabel = GetCreateRowHeading(i, title)
						if not TabInfo.RightFrame.firstHeading then
							TabInfo.RightFrame.firstHeading = headingLabel
						end
						GuideRow = GetCreateTabRow(i, j, title)
						if lastHeading~=headingLabel then	
							GuideRow:SetPoint("TOPLEFT", headingLabel, "BOTTOMLEFT", 0, "-5" ) 
						else 
							GuideRow:SetPoint("TOPLEFT", "DugisTab"..i.."Row"..j-1, "BOTTOMLEFT", "0", yofs) 
						end
						lastHeading = headingLabel
						GuideRow.Title:SetText(self:GetFormattedTitle(title))
						GuideRow.Title:Show()
						GuideRow.title = title
					end
					SetAllHeaderStates()
					TabInfo.rightScrollMax = rowheight * #DGV.guidelist[gtype] +  50
				else
					GuideRow = GetCreateTabRow(i, 1)
					GuideRow:SetPoint("TOPLEFT", TabInfo.RightFrame, "TOPLEFT", xofs, "-5" )
					GuideRow.Title:SetText(L["No Guide Loaded"])
					GuideRow.Title:Show()
				end
			end
		end
	end
	
	function DGV:PopulateGlobalSearchResults()
		local yofs = -5
		local rowheight = 14
		local rowCount = 0
		for _,rh in ipairs(Guides.rowHeadings) do
			if rh.tabNum==SEARCH_TAB then
				rh:ClearAllPoints()
				for _,row in EnumerateTabRows,SEARCH_TAB do
					row.title = nil
					row:Hide()
				end
				rh:Hide()
			end
		end
		for i=1,#tabs do
			local gtype = tabs[i].guidetype
			if gtype and DGV.guidelist[gtype] then
				local subCat = DGV.guidelist[gtype]
				--DGV:DebugFormat("PopulateGlobalSearchResults", "gtype", gtype)
				local lastHeading
				for j =1 , #subCat do
					local title = subCat[j]
					if DGV.Search:InSearchResults(DGV.headings[title], DGV:GetFormattedTitle(title)) then
						tabs[SEARCH_TAB]:Activate()
						rowCount = rowCount +1
						local headingLabel = GetCreateRowHeading(SEARCH_TAB, title, i)
						headingLabel.Title:SetText(tabs[headingLabel.originalTabNum].text.." - "..headingLabel.headingTitle)
						GuideRow = GetCreateTabRow(SEARCH_TAB, rowCount, title, i)
						GuideRow:Show()
						GuideRow:SetParent(headingLabel)
						headingLabel.lastChild = GuideRow
						if lastHeading~=headingLabel then
							GuideRow:SetPoint("TOPLEFT", headingLabel, "BOTTOMLEFT", 0, "-5" ) 
						else 
							GuideRow:SetPoint("TOPLEFT", "DugisTab1Row"..rowCount-1, "BOTTOMLEFT", "0", yofs) 
						end
						lastHeading = headingLabel
						GuideRow.Title:SetText(self:GetFormattedTitle(title))
						GuideRow.Title:Show()
						GuideRow.title = title
						headingLabel.guideType = gtype
					end
				end
			end
		end
		local tabInfo = tabs[SEARCH_TAB]
		tabInfo.rightScrollMax = rowheight * rowCount +  50
		if tabInfo==activeTabInfo then
			SetAllHeaderStates()
		end
		--tabInfo:Activate()
		--DGV:RestoreScrollBar(SEARCH_TAB)
		--DGV:DebugFormat("PopulateGlobalSearchResults", "SliderMax[SEARCH_TAB]", SliderMax[SEARCH_TAB])
	end
	
	function Guides:Load()

		DGV:RegisterEvent("UNIT_ENTERED_VEHICLE")
		DGV:RegisterEvent("UNIT_EXITED_VEHICLE")
		DGV:RegisterEvent("GOSSIP_CLOSED")
		if not DGV.guides then DGV.guides = {} end
		if not DGV.guidetags then DGV.guidetags = {} end
		if not DGV.nextzones then DGV.nextzones = {} end
		if not DGV.gtype then DGV.gtype = {} end
		if not DGV.rawtitle then DGV.rawtitle = {} end
		if not DGV.guidelist then DGV.guidelist = {} end
		if not DGV.headings then DGV.headings = {} end
		
		--DGV.queryquests = {}
		DGV.actions = {}
		DGV.quests1 = {}
		DGV.quests1L = {} --localized quest list
		DGV.quests2 = {}
		DGV.useitem = {}
		DGV.qid = {}
		DGV.daily = {}
		DGV.MappedPoints = {}
		DGV.tags = {}
		DGV.coords = {}
		if not DGU.watchedQuests then DGU.watchedQuests = {} end
		if not DGU.removedQuests then DGU.removedQuests = {} end
		DGV.postReqs = {}
		DGV.breadCrumbs = {}
		DGV.visualRows = {}
		visualRows = DGV.visualRows

		function DGV:CompleteQuest()
			DebugPrint("Finished a quest, HookScript QuestFrameCompleteQuestButton")
			local qid = DGV:GetQIDFromQuestName(GetTitleText())
			--if qid then

			--	DGU.turnedinquests[qid] = true
			--end

			if CurrentAction and qid then DebugPrint("HOOK qid is"..qid.."*".."action ="..CurrentAction.."*".."titletext="..GetTitleText()) end

			local acceptandcomplete 			= DGV:ReturnTag("E")
			if acceptandcomplete then DebugPrint("Detected accept and complete tag") end

			if not  DGV.quests1L[DGU.CurrentQuestIndex] then return end
			local _, _, questnoparen = DGV.quests1L[DGU.CurrentQuestIndex]:find("([^%(]*)")
			questnoparen = questnoparen:trim()

			if (CurrentAction == "T" and DGV.qid[DGU.CurrentQuestIndex] == qid) or
				(acceptandcomplete and GetTitleText() == L[questnoparen] )
			then
				if qid then DebugPrint("Detected curent quest turned in"..qid) end
				DGV:SetChkToComplete(DGU.CurrentQuestIndex)
				DGV:MoveToNextQuest()
			else
			        DGV:CompleteQID(qid, "T")
			end
			JustTurnedInQID = qid
		end

		function DGV:ClearScreen()
			DGV:SetViewTabTitle(L["No Guide Loaded"])
			DGV:LoadInitialView(L["No Guide Loaded. Right Click Here To Select One"], "Interface\\Minimap\\TRACKING\\Class" )
			DGV:WipeOutViewTab()
			wipe(DGV.actions)
			DGV:UpdateSmallFrame()
		end

		function DGV:isValidGuide(title)
			if self.guides[title] then
				return true
			end
			return false
		end
		
		function DGV:ShowLargeWindow()
			--DugisMainframe:SetHeight(400)
			DGV:AutoScroll(DGU.CurrentQuestIndex)
			DugisMainBorder:Show()
			DugisMainBorder.bg:Show()
			--DugisSmallFrameLogo:Show()
			DugisMain:Show()
			PlaySound("igCharacterInfoOpen")
			--DugisReloadButton:Show()
			--DugisSuggestButton:Show()
			--DugisResetButton:Show()
			--DGV:SetAllBorders()
			DugisMainBorder:SetHeight(420)
		end
		
		function DGV:CheckForFloorChange()
			if CurrentAction == "R" then
				local map, floor = self:ReturnTag("F")
				if map and floor and floor == DGV.DugisArrow.floor and map == DGV.DugisArrow.map then
					--DebugPrint("Detected correct floor in dungeon")
					DGV:SetChkToComplete(DGU.CurrentQuestIndex)
					DGV:MoveToNextQuest()
				end
				
			end
		end
		
		function DGV:UpdateMainFrame()
			SuspendViewFrameUpdate()
			local i, guideIndex
			local setChecked = false 
			
			--Abandoned Quest
			if AbandonQID and DGU.CurrentQuestIndex then
				local logidx = self:GetQuestLogIndexByQID(AbandonQID)
				if not logidx then --user abandoned quest but it hasn't registered yet			
					for i =1, #visualRows do
						if self.qid[i] == AbandonQID and strmatch(self.actions[i], "[ACTNKR]") then
							self:ClrChk(i)
						end
					end
					local nextindex = self:FindNextUnchecked()
					if nextindex < DGU.CurrentQuestIndex then
						self:MoveToPrevQuest()
					end
					AbandonQID = nil	
				end
			end	

			--Check for all completed or user uncompleted quests in quest log 
			for guideIndex = 1, #visualRows do
				local qComplete, QuestComplete
				local qid 			= self.qid[guideIndex]
				local logIndx 		= self:GetQuestLogIndexByQID(qid)
				local action 		= self.actions[guideIndex]
				local questState	= self:GetQuestState(guideIndex)
				local questPart 	= self:ReturnTag("QIDP", guideIndex)
				local needsLoot 	= self:ReturnTag("L", guideIndex)
				local isDaily		= self:ReturnTag("D", guideIndex)
				local reqlvl 		= self:ReturnTag("PL", guideIndex)
				local playerLevel	= UnitLevel("player")
				
				if logIndx then _, _, _, _, _, _, qComplete, _, _ = GetQuestLogTitle(logIndx) end
				
				if qComplete == 1 or self:QuestPartComplete(guideIndex) or (needsLoot and self:IsCompleteLootQO("QLU", nil, guideIndex)) or (not isDaily and self:HasQuestBeenTurnedIn(qid)) 
					 or self:ProfessionCompletedAtGuideIndex(guideIndex) or self:CheckForLocation(guideIndex) or self:AchieveCompleteFromGuideIndex(guideIndex) or self:CheckForHearth(guideIndex) then QuestComplete = true else QuestComplete = nil end
						
				if (action == "A" and logIndx) or (QuestComplete and action ~= "T") or (QuestComplete and action == "T" and not logIndx) or (questState == "C" and strmatch(action, "[NFfRBbh]") and not questPart and not needsLoot) or (reqlvl and reqlvl <= playerLevel and not action == "f") then 
					self:SetChkToComplete(guideIndex)
					setChecked = true
				end
				guideIndex = guideIndex + 1
			end
			
			if setChecked and not self.preLoadMode then
				if (self:FindNextUnchecked() ~= DGU.CurrentQuestIndex) then
					self:MoveToNextQuest(self:FindNextUnchecked())
				else
					self:MoveToNextQuest()
				end
			end 
			
			self.UpdateStickyFrame( )
			ResumeViewFrameUpdate()
			if DGV:isValidGuide(CurrentTitle) ~= true then DGV:ClearScreen() end
		end
		
		-- function DGV:UpdateQueryQuests()
			-- if DGV.queryquests then
				-- local quest
				-- for quest, _ in pairs(DGV.queryquests) do
					-- DGU.turnedinquests[quest] = true
				-- end
				-- DGV.queryquests = {}
			-- end
		-- end
		
		local lastInstanceEntered
		local function CheckDungeonZoneIn()
			if IsInInstance() then
				local currentZone = DGV:GetPlayerMapPositionDisruptive() --required to override MapPreview
				if currentZone==lastInstanceEntered then return end --one suggestion per entry
				lastInstanceEntered = currentZone
				MatchDungeonGuides(currentZone)
			end
		end
		
		function DGV:CompleteOnZoneCheck()
			if DGV:ReturnTag("CHKMAP", DGU.CurrentQuestIndex) then 
				DGV:MoveToNextQuest()
			end
			
			local correctzone = DGV:CheckForLocation(DGU.CurrentQuestIndex)
			if correctzone then 
				DGV:SetChkToComplete(DGU.CurrentQuestIndex)
				DGV:MoveToNextQuest()
			end
		end
		
		function DGV:Zone_OnEvent()
			DGV:CompleteOnZoneCheck()
			CheckDungeonZoneIn()
		end
		
		function DGV:CHAT_MSG_SYSTEM(event, msg)
			--Detect hearth, quest accept or quest complete
			local msgqid, curqid, questnoparen
			local _, _, loc 	= msg:find(L["(.*) is now your home."])
			local _, _, accept = msg:find(L["Quest accepted: (.*)"])
			
			if DGV:isValidGuide(self.CurrentTitle) == false then return end
			
			if loc then --Set Hearth	
				questnoparen = DGV.quests1[DGU.CurrentQuestIndex]:match("([^%(]*)")
				questnoparen = questnoparen:trim()
				if CurrentAction == "h" and questnoparen == loc then
					DebugPrint( "Detected setting hearth to ".. loc.."message:".. msg)
					DGV:SetChkToComplete(DGU.CurrentQuestIndex)
					DGV:MoveToNextQuest()
				end

			elseif accept then	--Quest accept
				curqid 		= DGV.qid[DGU.CurrentQuestIndex]
				msgqid 		= DGV:GetQIDFromQuestName(accept)	
				--DebugPrint("accept ="..accept.."quest id is"..msgqid.."*".."action ="..CurrentAction.."*")
				
				if CurrentAction == "A" and msgqid == curqid then
					DGV:SetChkToComplete(DGU.CurrentQuestIndex)
					DGV:MoveToNextQuest()
				else --not current quest but accept by user into log
					DGV:CompleteQID(msgqid, "A")
				end
				
				--Skip breadcrumbs if any
				self:SkipBreadCrumbs(msgqid)
			end

		end
		
		--[[function DGV:UI_INFO_MESSAGE(err, msg)
			if (CurrentAction == "f") then
			DebugPrint("CurrentAction="..CurrentAction.."msg="..msg.."ERR_NEWTAXIPATH="..ERR_NEWTAXIPATH)
				if msg == ERR_NEWTAXIPATH then
					DebugPrint("Detected completed new flight path")
					DGV:SetChkToComplete(DGU.CurrentQuestIndex)
					DGV:MoveToNextQuest()	
				end
			end
		end]]--
		


		local LOOT_SELF_REGEX = gsub(LOOT_ITEM_SELF, "%%s", "(.+)") --"You receive item: %s."
		local LOOT_PUSHED_REGEX = gsub(LOOT_ITEM_PUSHED_SELF, "%%s", "(.+)") --"You receive loot: %s."
		function DGV:CHAT_MSG_LOOT(event, msg)			
			if CurrentTitle ~= nil then
				local guideIndex, itemid
				local itemlink = string.match(msg, LOOT_SELF_REGEX) or string.match(msg, LOOT_PUSHED_REGEX)
				
				if itemlink then itemid = string.match(itemlink, "item:(%d+):")	end
				
				for guideIndex = 1, #visualRows do
					if DGV:ReturnTag("L", guideIndex) then 
						if DGV:IsCompleteLootQO("CMSG", itemid, guideIndex) then 
							DGV:SetChkToComplete(guideIndex) 
							DGV:MoveToNextQuest()
						end
					end 
				end 
			end
		end
		
		function DGV:UpdateAchieveFrame()
			if DGV:isValidGuide(CurrentTitle) == true then
				if DGV.gtype[CurrentTitle] == "A" or "E" then --achieve guide type
					local i
					for i=1, #visualRows do
						if self:AchieveCompleteFromGuideIndex(i) then 
							self:SetChkToComplete(i)
							if i == DGU.CurrentQuestIndex then DebugPrint("3") self:MoveToNextQuest() end		
						end
					end
				end
			end
		end
		
		local achieveDelay
		local achvTime = 0
		function onAchUpdate(self,elapsed)
			achvTime = achvTime + elapsed
			if achvTime >= 3 then
				DebugPrint("***Calling UpdateAchieveFrame()")
				achieveDelay:Hide()
				achvTime = 0
				DGV:UpdateAchieveFrame()

			end
		end

		if not achieveDelay then
			achieveDelay = CreateFrame("frame")
			achieveDelay:SetScript("OnUpdate", onAchUpdate)
			achieveDelay:Hide()
		end

		function achieveDelayStart( )
			achvTime = 0
			achieveDelay:Show()
		end
		
		function DGV:Guide_CRITERIA_UPDATE()
			if DGV.gtype[CurrentTitle] == "A" or "E" then
				achieveDelayStart( ) 	
			end
		end
		
		function DGV:PLAYER_LEVEL_UP(self, level)
			--skip quest that is grey ! or too high level, and check again on playerlevel up event to see if they can pick them up
			DGU.PlayerLevel = tonumber(level)
			DGV:UpdatePlayerLevels(DGU.PlayerLevel)
			DGV:LevelUpSuggestGuide(DGU.PlayerLevel)
			--Delay because it doesn't register new player level immediately
			DelayandMoveToNextQuest(3)
		end
		
		function DGV:GOSSIP_CLOSED()
			DebugPrint("###GOSSIP_CLOSED")
			if self:ReturnTag("V") or DGV.actions[DGU.CurrentQuestIndex] == "F" then
				if UnitInVehicle("player") == 1 or UnitControllingVehicle("player") == true then
					DGV:SetChkToComplete(DGU.CurrentQuestIndex)
					DGV:MoveToNextQuest()
				end
			end
		end
		
		function DGV:UNIT_ENTERED_VEHICLE()
			DebugPrint("###UNIT_ENTERED_VEHICLE")
			if self:ReturnTag("V") or DGV.actions[DGU.CurrentQuestIndex] == "F" then
				if UnitInVehicle("player") == 1 or UnitControllingVehicle("player") == true then
					DGV:SetChkToComplete(DGU.CurrentQuestIndex)
					DGV:MoveToNextQuest()
				end
			end
		end
		
		function DGV:UNIT_EXITED_VEHICLE()
			DebugPrint("###UNIT_EXITED_VEHICLE")
			self:MapCurrentObjective()
		end		

		--title: 		A string describing the zone and level range
		--nextguide: 	(Optional) The next guide to load when this guide is completed
		--faction:		Values: Horde, Alliance or nil means both factions
		--guidetype: 	Levling(L), Dailies(D) or Events(E) type of guide
		--rowinfo: 		Containins the actual guide data
		--tag: 			Guide options like |PZ|
		function DGV:RegisterGuide(heading, title, nextguide, faction, guidetype, tag, rowinfo)
			local myfaction = UnitFactionGroup("player") --No need to localize
			
			if faction == myfaction or faction == nil then	
				--DebugPrint( "Title:"..title.."nextguide:"..nextguide.."faction:"..faction.."guidetype"..guidetype)
				
				self.guides[title] 	= rowinfo
				self.guidetags[title] 	= tag
				self.nextzones[title] 	= nextguide
				self.gtype[title] 	= guidetype
				self.headings[title] 	= heading
				
				--Save backwards lookup from display title to raw title
				local title1 = self:GetFormattedTitle(title, "Easy")
				local title2 = self:GetFormattedTitle(title, "Normal")
				local title3 = self:GetFormattedTitle(title, "Hard")
						

				if title1 then
					self.rawtitle[title1] = title
				end
				
				if title2 then
					self.rawtitle[title2] = title
				end
				
				if title3 then
					self.rawtitle[title3] = title
				end
				
				if guidetype == "L" then 			
					if not self.guidelist["L"] then self.guidelist["L"] ={} end
					table.insert(self.guidelist["L"], title)
				elseif guidetype == "I" then
					if not self.guidelist["I"] then self.guidelist["I"] ={} end
					table.insert(self.guidelist["I"], title)
				elseif guidetype == "D" then
					if not self.guidelist["D"] then self.guidelist["D"] ={} end
					table.insert(self.guidelist["D"], title)
				elseif guidetype == "E" then
					if not self.guidelist["E"] then self.guidelist["E"] ={} end
					table.insert(self.guidelist["E"], title)
				elseif guidetype == "A" then
					if not self.guidelist["A"] then self.guidelist["A"] ={} end
					table.insert(self.guidelist["A"], title)
				elseif guidetype == "P" then
					if not self.guidelist["P"] then self.guidelist["P"] ={} end
					table.insert(self.guidelist["P"], title)
				end
			end
		end

		function DGV:GetUnfinishedGuideIndexByQID(qid)
			local i
			for i=1, #visualRows do
				if DGV.qid[i] == qid and DGV:GetQuestState(i)~="C" then return i end
			end	
		end
	

		function DGV:ReturnTag(tag, i)
			i = i or DGU.CurrentQuestIndex
			local tags = DGV.tags[i]
			
			if not tags then return end
			if tag == "O" then return tags:find("|O|")
			elseif tag == "MAP" then
				local map1, map2, map3, map4 = tags:match("|MAP|(%d+),?%s?(%d*),?%s?(%d*),?%s?(%d*)|")
				if map1 == "" then map1 = nil end
				if map2 == "" then map2 = nil end
				if map3 == "" then map3 = nil end
				if map4 == "" then map4 = nil end				
				return map1, map2, map3, map4
			elseif tag == "PRE" then
				return tags:match("|PRE|(%d+)")
			elseif tag == "PHA" then
				return tags:match("|PHA|(%d+)")
			elseif tag == "OID" then
				return tags:match("|OID|(%d+)")
			elseif tag == "REP" then
				return tags:match("|REP|(%d+),%s*(%d)")	
			elseif tag == "FS" then
				return tags:match("|FS|(%d+),%s*(%d+)")					
			elseif tag == "E" then return 1
			elseif tag == "QIDP" then
				local qidpart = tags:match("|QID|%d+%.(%d+)")
				return qidpart
			elseif tag == "L" then
				local _, _, lootitem, lootqty = tags:find("|L|(%d+)%s?(%d*)|")
				lootqty = tonumber(lootqty) or 1
				return lootitem, lootqty
			elseif tag == "P" then

				local profession, professionlvl = tags:match("|P|(%w+%s?%w*)%s+(%d+)")
				if profession then 
					if L[profession] then profession = L[profession] end
				end
				return profession, tonumber(professionlvl)
			elseif tag == "OP" then
				local profession, professionlvl = tags:match("|OP|(%w+%s?%w*)%s+(%d+)")
				if profession then 
					if L[profession] then profession = L[profession] end
				end
				return profession, tonumber(professionlvl)				
			elseif tag == "PL" then
				local playerlvl = tags:match("|PL|(%d+)|")
				return tonumber(playerlvl)
			elseif tag == "PM" then --ex: |PM|Alchemy|75|
				local profession, maxlevel = tags:match("|PM|(%w+%s?%w*)%s*|(%d+)|")

				if profession then 
					if L[profession] then profession = L[profession] end
				end
				return profession, tonumber(maxlevel)
			elseif tag == "Z" then --ex: |Z|mapID mapFloor|
				local mapID, mapFloor = tags:match("|Z|(%d+)%s?(%d*)|")
				return tonumber(mapID), tonumber(mapFloor)
			elseif tag == "F" then --ex: |F|mapID mapFloor|
				local mapID, mapFloor = tags:match("|F|(%d+)%s?(%d*)|")
				return tonumber(mapID), tonumber(mapFloor)
			elseif tag == "NPC" then --ex: |NPC|37087| or |NPC|708, 704, 705|
				local npc1, npc2, npc3, npc4, npc5 = tags:match("|NPC|(%d+),?%s?(%d*),?%s?(%d*),?%s?(%d*),?%s?(%d*)|")
				if npc1 == "" then npc1 = nil end
				if npc2 == "" then npc2 = nil end
				if npc3 == "" then npc3 = nil end
				if npc4 == "" then npc4 = nil end
				if npc5 == "" then npc5 = nil end
				return npc1, npc2, npc3, npc4, npc5
			elseif tag == "OBJ" then --ex: |OBJ|37087| or |OBJ|708, 704, 705|
				local obj1, obj2, obj3, obj4, obj5 = tags:match("|OBJ|(%d+),?%s?(%d*),?%s?(%d*),?%s?(%d*),?%s?(%d*)|")
				if obj1 == "" then obj1 = nil end
				if obj2 == "" then obj2 = nil end
				if obj3 == "" then obj3 = nil end
				if obj4 == "" then obj4 = nil end
				if obj5 == "" then obj5 = nil end
				return obj1, obj2, obj3, obj4, obj5
			elseif tag == "S" then 
				if tags:match("|N|Speak ") or tags:match("|N|Talk ") or tags:match(" Speak ") or tags:match(" speak ") or tags:match(" Talk ") or tags:match(" talk ") or tags:match("|N|Parle") or tags:match("|N|Discuter") or tags:match(" Parle ") or tags:match(" parle ") or tags:match(" Discuter ") or tags:match(" discuter ") then
					return true
				end
			elseif tag == "K" then 
				if tags:match(" Kill ") or tags:match(" kill ") or tags:match("|N|Kill ") or tags:match("|N|kill ") or tags:match(" killing ") or tags:match(" en tuant ") or tags:match("Slay ") or tags:match("slay ") or tags:match("Defeat ") or tags:match("defeat ") or tags:match("ExÃ©cuter ") or tags:match("exÃ©cuter ") or ((tags:match("] from ") or tags:match("] sur ") or tags:match("drop") or tags:match("obtenu")) or tags:match(" damage ") or tags:match("|N|Damage ") or tags:match(" attack ") or tags:match("|N|Attack ") and tags:match("|NPC|")) then
					return true
				end
			elseif tag == "T" then 
				if (tags:find("(%[[^%]]+%])") and not tags:match("|U|")) or tags:match("|T|") then 
					return true
				end				
			end
			
			return select(3, tags:find("|"..tag.."|([^|]*)|?"))
		end

		function DGV:IterateGuideIndicesWithQID(qid, delegate)
			local i
			for i=1, #visualRows do
				if DGV.qid[i] == qid then
					delegate(i)
				end
			end
		end
		
		function DGV.DeselectTopTabs()
			Main.homeTab:Enable();
			Main.homeTab:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			Main.homeTab.selectedGlow:Hide();
			
			Main.currentGuideTab:Enable();
			Main.currentGuideTab:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			Main.currentGuideTab.selectedGlow:Hide();
			
			Main.settingsTab:SetChecked(false)
		end
	end
	
	function Guides:OnModulesLoaded()
		DGV:InitializeTabs()
		DGV:HideLargeWindow()	
		DGV:ShowViewTab()
		
		--Load saved guide
		if DGV:isValidGuide(CurrentTitle) == true  then
			DGV:DisplayViewTab(CurrentTitle)		
		else --Load Default 	
			DGV:ClearScreen()
			if DGV.chardb.FirstTime then
				DGV.chardb.FirstTime = false
				DGV:InitFramePositions()
				DGV:SuggestButtonOnClick(true)			
			end		
		end
	end
	
	hooksecurefunc("QuestLogTitleButton_OnClick", function()
		if Guides.loaded then
			local log_index = GetQuestLogSelection()
			local qid = DGV:GetQIDByLogIndex(log_index)
			if IsQuestWatched(log_index) then	
				DGU.watchedQuests[qid] = true --manually watched quests
			else
				DGU.watchedQuests[qid] = nil
			end
		end
	end)

	hooksecurefunc("WorldMapTrackQuest_Toggle", function()
		if Guides.loaded then
			local log_index = WORLDMAP_SETTINGS.selectedQuest.questLogIndex
			local qid = DGV:GetQIDByLogIndex(log_index)
			if IsQuestWatched(log_index) then	
				DGU.watchedQuests[qid] = true --manually watched quests
			else
				DGU.watchedQuests[qid] = nil
			end
		end
	end)	

	hooksecurefunc("WatchFrameLinkButtonTemplate_OnLeftClick", function()
		if Guides.loaded then
			local log_index = GetQuestLogSelection()
			local qid = DGV:GetQIDByLogIndex(log_index)
			if not IsQuestWatched(log_index) then				
				DGU.watchedQuests[qid] = nil
			end
		end
	end)		
	
	function Guides:Unload()
		DGV:UnregisterEvent("UNIT_ENTERED_VEHICLE")
		DGV:UnregisterEvent("UNIT_EXITED_VEHICLE")
		DGV:UnregisterEvent("GOSSIP_CLOSED")
		for i = 1, #tabs do
			local j
			for j=1,math.huge,1 do

				local row=_G["DugisTab"..i.."Row"..j]
				if not row then break end
				row:Hide()
			end
		end
		
		QuestLogFrameTrackButton_OnClick = DGV.NoOp
		DGV:HideLargeWindow()
		if DGV:UserSetting(DGV_UNLOADMODULES) then
			wipe(DGV.guides)
			DGV.guides = nil
			wipe(DGV.guidetags)
			DGV.guidetags = nil
			wipe(DGV.nextzones)
			DGV.nextzones = nil
			wipe(DGV.gtype)
			DGV.gtype = nil
			wipe(DGV.rawtitle)
			DGV.rawtitle = nil
			wipe(DGV.guidelist)
			DGV.guidelist = nil
			wipe(DGV.headings)
			DGV.headings = nil
		end
		
		--wipe(DGV.queryquests)
		--DGV.queryquests = nil
		wipe(DGV.actions)
		DGV.actions = nil
		wipe(DGV.quests1)
		DGV.quests1 = nil
		wipe(DGV.quests1L)
		DGV.quests1L = nil --localized quest list
		wipe(DGV.quests2)
		DGV.quests2 = nil
		wipe(DGV.useitem)
		DGV.useitem = nil
		wipe(DGV.qid)
		DGV.qid = nil
		wipe(DGV.daily)
		DGV.daily = nil
		wipe(DGV.MappedPoints)
		DGV.MappedPoints = nil
		wipe(DGV.tags)
		DGV.tags = nil
		wipe(DGV.coords)
		DGV.coords = nil
		--wipe(DGU.watchedQuests)
		--DGU.watchedQuests = nil
		wipe(DGV.postReqs)
		DGV.postReqs = nil
		wipe(DGV.breadCrumbs)
		DGV.breadCrumbs = nil
		wipe(DGV.visualRows)
		DGV.visualRows = nil
		visualRows = nil
	end
end
