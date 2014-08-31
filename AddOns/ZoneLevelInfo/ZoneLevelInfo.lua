-- Initialise

local ZLI_VERSION = "1.8.0";

local L,zones,zoneNumberTable,continentNumberTable;	--arrays
local currentLocale;					--strings
local currentLocaleSupported,missingZones;		--booleans

local zoneDefault=" ";

local notActive = true;
local ZLI_DEV = false;

local lastX,lastY = 100;
local lastTime = 0;

local savedZoneName = "";
local savedMapText = "";
local savedPetLevels = "";

local savedScale = 0;
--local indentX = 75;   --was 60
--local indentY = 50;  --was -40, now negative at use

ZoneLevelInfoSettings = {};
local ZoneLevelInfoDefaultsVersion = 3;
local ZoneLevelInfoDefaults = {
		 ["fontLarge"]		= 22
		,["fontOutline"]	= true
		,["showAtZoneZoom"]	= true
		,["scale"]		= 100
		,["indentX"]		= 75
		,["indentY"]		= 50
		,["showPetLevels"]	= true
	};

local ZoneLevelInfo_Frame = CreateFrame("frame");
ZoneLevelInfo_Frame:RegisterEvent("ADDON_LOADED");

local _;	-- throw-away variables

---------
--REFERENCE:
--
--WorldMapDetailFrame (MAIN FRAME)
--WorldMapFrameAreaFrame (DETAIL CONTAINER)
--WorldMapFrameAreaLabel (ZONE NAMES)
--WorldMapFrameAreaDescription (ADDITIONAL TEXT, PVP)
--WorldMapFrameAreaPetLevels (PET LEVELS)
--WorldMapZoneInfo (BOTTOM)
--
--



	-------------------------------
	-- OnUpdate functions
	-- moved out of OnUpdate as *Phanx* pointed out it was creating this function every time it ran.

	local function ZoneLevelInfo_LevelColour(maxLevelZone, minLevelZone) 

		local playerLevel = UnitLevel("player");
		local levelNull = maxLevelZone + ceil(GetQuestGreenRange()/2) + 1;
		local levelVeryHard = minLevelZone - 3;
		local levelHard = minLevelZone;
		local levelLow = maxLevelZone;
		local colour = {["R"]=1, ["G"]=1, ["B"]=1};

		if ( minLevelZone <= 0 ) then	-- capital city / unknown area
			colour = {["R"]=0.5, ["G"]=0.5, ["B"]=0.5};
		elseif ( playerLevel >= levelNull ) then	-- grey, little/no xp
			colour = {["R"]=0.5, ["G"]=0.5, ["B"]=0.5};
		elseif ( playerLevel <= levelVeryHard ) then	-- solid red, hard & probably no quests.
			--colour = {["R"]=1, ["G"]=0.2, ["B"]=0}; not blizz colours
			colour = {["R"]=1, ["G"]=0.1, ["B"]=0.1};
		elseif (  ( playerLevel > levelHard and playerLevel < levelLow )
		        or( (levelLow-levelHard)<2 and (playerLevel==levelLow or playerLevel==levelHard) ) ) then -- yellow, the 'sweetspot'
			--colour = {["R"]=1, ["G"]=1, ["B"]=0.2}; not blizz colours
			colour = {["R"]=1, ["G"]=1, ["B"]=0};
		elseif ( playerLevel >= levelLow and playerLevel < levelNull ) then -- green, on the easy side
			--colour = {["R"]=0, ["G"]=1, ["B"]=0.2}; not blizz colours
			colour = {["R"]=0.25, ["G"]=0.75, ["B"]=0.25};
		elseif ( playerLevel > levelVeryHard and playerLevel <= levelHard ) then -- orange, tough going
			--colour = {["R"]=1, ["G"]=0.6, ["B"]=0.2}; not blizz colours
			colour = {["R"]=1, ["G"]=0.5, ["B"]=0.25};
		end

		return colour;
	end

-------------------------------
-- OnUpdate
function ZoneLevelInfo_OnUpdate(self, elapsed)


	-------------------------------
	-- OnUpdate main procedure

	if (notActive) then return; end

	local x, y = GetCursorPosition();
	local theTime = GetTime();
	local mapText = WorldMapFrameAreaLabel:GetText();
	local petLevels = WorldMapFrameAreaPetLevels:GetText();
	local mapDescription = WorldMapFrameAreaDescription:GetText();
	if (mapText) then mapText = mapText:gsub("|.+$",""); end    -- get rid of 
	local scale = WorldMapDetailFrame:GetEffectiveScale();
	if (lastX==x and lastY==y and mapText==savedMapText and petLevels==savedPetLevels and scale==savedScale and (lastTime+0.5)>theTime) then return; else lastX = x; lastY = y; lastTime=theTime; end
	local currentContinentIndex = GetCurrentMapContinent();
	local zoneName;
	if (currentContinentIndex==0) then
		if (mapText) then
			if (zones[mapText..zoneDefault]) then
				zoneName = mapText..zoneDefault;
			elseif (zones[mapText]) then
				zoneName = mapText;
			else
				x = x / scale;
				y = y / scale;
				local width = WorldMapDetailFrame:GetWidth();
				local height = WorldMapDetailFrame:GetHeight();
				local centerX, centerY = WorldMapDetailFrame:GetCenter();
				local topleftX = centerX - (width/2);
				local topleftY = centerY + (height/2);
				x = (x - topleftX) / width;
				y = (topleftY - y) / height;
				zoneName, _, _, _, _, _, _, _ = UpdateMapHighlight(x, y);
				zoneName = zoneName..zoneDefault;
			end
		end
		x = 0;
		y = 0;
	elseif (zones[mapText]) then
		zoneName = mapText;
		x = 0;
		y = 0;
	else
		x = x / scale;
		y = y / scale;
		local width = WorldMapDetailFrame:GetWidth();
		local height = WorldMapDetailFrame:GetHeight();
		local centerX, centerY = WorldMapDetailFrame:GetCenter();
		local topleftX = centerX - (width/2);
		local topleftY = centerY + (height/2);
		x = (x - topleftX) / width;
		y = (topleftY - y) / height;
		--local _;	-- global variable bleeding pointed out by Antonz ! -- moved to top
		zoneName, _, _, _, _, _, _, _ = UpdateMapHighlight(x, y);
	end

	if (zoneName and not zones[zoneName]) or (x<0 or x>1 or y<0 or y>1) then
		zoneName = nil;
	end
	
	if (zoneName == nil) then
		local currentZoneIndex = GetCurrentMapZone();
		if ( currentZoneIndex > 0 ) then
			if ( currentContinentIndex > 0 and ZoneLevelInfoSettings.showAtZoneZoom ) then
				zoneName = zoneNumberTable[currentContinentIndex][currentZoneIndex];
			end
		else
			if ( currentContinentIndex > 0 ) then
				zoneName = continentNumberTable[currentContinentIndex]..zoneDefault;
			end
		end
	end

	if (scale ~= savedScale) then
		savedScale = scale;
		ZoneLevelInfoFrame_MainText:SetPoint("TOPLEFT","WorldMapDetailFrame","TOPLEFT",floor(ZoneLevelInfoSettings.indentX*(savedScale+0.3)), floor(-ZoneLevelInfoSettings.indentY*(savedScale+0.3)));
	end


	if (zoneName == savedZoneName and mapText == savedMapText and petLevels == savedPetLevels) then
		return
	else
		savedZoneName  = zoneName;
		savedMapText   = mapText;
		savedPetLevels = petLevels;

		if (savedZoneName == nil) then
			ZoneLevelInfoFrame_MainText:SetTextColor(0.5, 0.5, 0.5);
			ZoneLevelInfoFrame_MainText:SetText(savedMapText);
			ZoneLevelInfoFrame_Key:SetText("");
			ZoneLevelInfoFrame_LevelRange:SetText("");
			ZoneLevelInfoFrame_ExtraText:SetText("");
			ZoneLevelInfoFrame_ExtraText2:SetText("");
		else
			local zoneInfo = zones[savedZoneName];
			local controlInfo = "";
			local levelRange = "";
			local extraText = "";
			local extraText2 = "";
			local setControlColour, setLevelColour;
			if (zoneInfo[3] == "N") then
				controlInfo = L["Contested Zone"];
				setControlColour = {["R"]=1, ["G"]=1, ["B"]=0};

			elseif (zoneInfo[3] == "H") then
				controlInfo = L["Horde"];
				setControlColour = {["R"]=1, ["G"]=0.1, ["B"]=0.1};

			elseif (zoneInfo[3] == "A") then
				controlInfo = L["Alliance"];
				setControlColour = {["R"]=0, ["G"]=0.5, ["B"]=1};

			elseif (zoneInfo[3] == "X") then
				controlInfo = L["PvP Combat Zone"];
				setControlColour = {["R"]=1, ["G"]=0.5, ["B"]=0.25};

			elseif (zoneInfo[3] == "S") then
				controlInfo = L["Sanctuary"];
				setControlColour = {["R"]=0.25, ["G"]=0.75, ["B"]=0.25};

			elseif (zoneInfo[3] == "C") then
				setControlColour = {["R"]=1, ["G"]=0.75, ["B"]=0.15};

			else -- should not be any 'else'
				setControlColour = {["R"]=1, ["G"]=1, ["B"]=1};
			end



			local setLevelColour = ZoneLevelInfo_LevelColour(0,0);
			if (zoneInfo == zoneDefault) then
				levelRange = "["..L["unknown zone"].."]";

			elseif (zoneInfo[1] < 0 and zoneInfo[2] < 0) then
				levelRange = L["Capital City"];

			elseif (zoneInfo[1] == 0 and zoneInfo[2] == 0 and zoneInfo[3] ~= "C" and (not ZoneLevelInfoSettings.showPetLevels or not zoneInfo.pet)) then
				--levelRange = L["Staging Area"];
				levelRange = ZoneLevelInfoFrame_ExtraText:GetText();
				ZoneLevelInfoFrame_ExtraText:SetText("");
				setLevelColour = {["R"]=1, ["G"]=1, ["B"]=0.2};

			elseif (zoneInfo[1] > 0 and zoneInfo[2] > 0) then
				if (zoneInfo[1] < zoneInfo[2]) then
					levelRange = "["..zoneInfo[1].."-"..zoneInfo[2].."]";
					setLevelColour = ZoneLevelInfo_LevelColour(zoneInfo[2], zoneInfo[1]);
				else
					levelRange = "["..zoneInfo[1].."]";
					setLevelColour = ZoneLevelInfo_LevelColour(zoneInfo[1], zoneInfo[1]);
				end
			end
			if (zoneInfo["Note"]) then
				if (levelRange ~= "") then
					levelRange = levelRange.." ";
				end;
				levelRange = levelRange..L[zoneInfo["Note"]];
			end


			extraText = "";
			--if (savedMapText ~= nil and savedMapText ~= "BLAH!" and currentContinentIndex > 0 and not zones[savedMapText]) then
			if (savedMapText ~= nil and savedMapText ~= "BLAH!" and not zones[savedMapText] and not zones[savedMapText..zoneDefault]) then
				if (zoneInfo[3]=="C") then
					controlInfo = savedMapText;
				else
					extraText = savedMapText;
				end
			elseif (zoneInfo[3]~="C" and not zones[savedZoneName]) then
				extraText = savedZoneName;
			end

	-------------------------
	-- Pet Levels Managemnent
	-------------------------
			--if you want to check if people have pet battles unlocked. At the moment we always show if on.
			--local _, _, _, _, locked = C_PetJournal.GetPetLoadOutInfo(1);
			
			local petText = nil;

			if (zoneInfo.pet and ZoneLevelInfoSettings.showPetLevels and currentContinentIndex>0) then
				local petMinLevel = zoneInfo.pet[1];
				local petMaxLevel = zoneInfo.pet[2];
				-- *** START SECTION WorldMapFrame.lua (5.2.0.16650) lines 1337 (ya, rly.) to 1359 ***
				-- *** wow.go-hero.net/framexml/16650/WorldMapFrame.lua#1337 ***
				local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
				local color
				if (teamLevel) then
					if (teamLevel < petMinLevel) then
						--add 2 to the min level because it's really hard to fight higher level pets
						color = GetRelativeDifficultyColor(teamLevel, petMinLevel + 2);
					elseif (teamLevel > petMaxLevel) then
						color = GetRelativeDifficultyColor(teamLevel, petMaxLevel);
					else
						--if your team is in the level range, no need to call the function, just make it yellow
						color = QuestDifficultyColors["difficult"];
					end
				else
					--If you unlocked pet battles but have no team, level ranges are meaningless so make them grey
					color = QuestDifficultyColors["header"];
				end
				color = ConvertRGBtoColorString(color);
				-- *** END SECTION WorldMapFrame.lua (5.2.0.16650) lines 1337 to 1359 ***
				-- *** wow.go-hero.net/framexml/16650/WorldMapFrame.lua#1337 ***
				if (petMinLevel ~= petMaxLevel) then
					petText = color .. "(" .. petMinLevel .. "-" .. petMaxLevel .. ")";
				else
					petText = color .. "(" .. petMinLevel .. ")";
				end
			end
			if (petText) then
				if (levelRange == nil) then
					levelRange = "";
				elseif (levelRange:len() > 0) then
					levelRange = levelRange .. "   ";
				end
				levelRange = levelRange .. "|cff7f7f7fPet: " .. petText;
			end
				

			--FOR DEBUGGING
			if (ZLI_DEV) then
				if (savedPetLevels and ZoneLevelInfoSettings.showPetLevels) then
					local s,e = savedPetLevels:find("|c");
					if (s) then
						local petTextBlizzard = savedPetLevels:sub(s);
						if (petText) then
							if (petText == petTextBlizzard) then
								petTextBlizzard = nil;
							end
						end
						if (petTextBlizzard) then
							DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00ZoneLevelInfo PET MISMATCH ERROR: " .. savedZoneName .. ": " .. petTextBlizzard);
						end
					end
				end
			end



	-------------------------
	-- Output Level Detail
	-------------------------

			ZoneLevelInfoFrame_MainText:SetTextColor(setControlColour["R"], setControlColour["G"], setControlColour["B"]);
			ZoneLevelInfoFrame_Key:SetTextColor(setControlColour["R"], setControlColour["G"], setControlColour["B"]);
			ZoneLevelInfoFrame_LevelRange:SetTextColor(setLevelColour["R"], setLevelColour["G"], setLevelColour["B"]);
			ZoneLevelInfoFrame_ExtraText:SetTextColor(setControlColour["R"], setControlColour["G"], setControlColour["B"]);
			ZoneLevelInfoFrame_ExtraText2:SetTextColor(setControlColour["R"], setControlColour["G"], setControlColour["B"]);

			ZoneLevelInfoFrame_MainText:SetText(savedZoneName);
			ZoneLevelInfoFrame_Key:SetText(controlInfo);
			ZoneLevelInfoFrame_LevelRange:SetText(levelRange);
			ZoneLevelInfoFrame_ExtraText:SetText(extraText);
			ZoneLevelInfoFrame_ExtraText2:SetText(mapDescription);

		end
	end
end





local function ZoneLevelInfo_SetFonts(fontLarge,fontOutlineBool)

		local minSize = ceil((6+1)/0.75);
		local maxSize = 24;

		if (fontLarge>maxSize) then fontLarge=maxSize elseif (fontLarge<minSize) then fontLarge=minSize end;
		local fontSmall = floor(fontLarge*0.75)-1;
		local fontSpacing = fontLarge;
		if (fontLarge > 18) then
			fontSpacing = fontSpacing + fontLarge - 18;
		elseif (fontLarge < 14) then
			fontSpacing = 14;
		end

		local theFont,_ = GameFontHighlight:GetFont();
		local fontOutline = "";
		if (fontOutlineBool) then fontOutline = "OUTLINE"; end
		
		ZoneLevelInfoFrame_MainText:SetFont(theFont,fontLarge,fontOutline);
		ZoneLevelInfoFrame_Key:SetFont(theFont,fontSmall,fontOutline);
		ZoneLevelInfoFrame_LevelRange:SetFont(theFont,fontSmall,fontOutline);
		ZoneLevelInfoFrame_ExtraText:SetFont(theFont,fontSmall,fontOutline);
		ZoneLevelInfoFrame_ExtraText2:SetFont(theFont,fontSmall,fontOutline);
		ZoneLevelInfoFrame_Key:SetPoint("BOTTOMLEFT", "ZoneLevelInfoFrame_MainText", "BOTTOMLEFT", 0, -fontSpacing);
		ZoneLevelInfoFrame_LevelRange:SetPoint("BOTTOMLEFT", "ZoneLevelInfoFrame_Key", "BOTTOMLEFT", 0, -fontSpacing);
		ZoneLevelInfoFrame_ExtraText:SetPoint("BOTTOMLEFT", "ZoneLevelInfoFrame_LevelRange", "BOTTOMLEFT", 0, -fontSpacing);
		ZoneLevelInfoFrame_ExtraText2:SetPoint("BOTTOMLEFT", "ZoneLevelInfoFrame_ExtraText", "BOTTOMLEFT", 0, -fontSpacing);

end


--============================
--= Register the Slash Command
--============================
SlashCmdList["ZLI"] = function(_msg)
	if (_msg) then
		local _, _, cmd, arg1 = string.find(string.upper(_msg), "([%w]+)%s*(.*)$");
		if ("DEFAULT" == cmd or "RESET" == cmd) then		-- reset the list
			for ZLI_default_key,ZLI_default_value in next,ZoneLevelInfoDefaults do
				ZoneLevelInfoSettings[ZLI_default_key] = ZLI_default_value;
			end
			ZoneLevelInfo_SetFonts(ZoneLevelInfoSettings.fontLarge,ZoneLevelInfoSettings.fontOutline);
			ZoneLevelInfoFrame:SetScale(ZoneLevelInfoSettings.scale/100);
			ZoneLevelInfoFrame_MainText:SetPoint("TOPLEFT","WorldMapDetailFrame","TOPLEFT",floor(ZoneLevelInfoSettings.indentX*(savedScale+0.3)), floor(-ZoneLevelInfoSettings.indentY*(savedScale+0.3)));
			WorldMapFrameAreaLabel:Hide();
			ZoneLevelInfoFrame:Show();
			notActive=false;
			local confirmMsg = "ZoneLevelInfo: defaults reset";
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00".. confirmMsg);

		elseif ("SIZE" == cmd) then		-- set the text size
			local confirmMsg = "ZoneLevelInfo size ";
			local setSize = arg1:match("^%s*(%d+)%s*$");
			if (setSize ~= nil and tonumber(setSize)>=10 and tonumber(setSize)<=24) then
				ZoneLevelInfoSettings.fontLarge = floor(tonumber(setSize));
				ZoneLevelInfo_SetFonts(ZoneLevelInfoSettings.fontLarge,ZoneLevelInfoSettings.fontOutline);
				confirmMsg = confirmMsg .. "set to " ..ZoneLevelInfoSettings.fontLarge;
			else
				confirmMsg = confirmMsg .. "currently " ..ZoneLevelInfoSettings.fontLarge..". Settable range: 10-24.";
				if (arg1 ~= "") then
					confirmMsg = confirmMsg .. " (Option unknown: '"..arg1.."')";
				end
			end
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("OUTLINE" == cmd) then
			local confirmMsg = "ZoneLevelInfo map text outline switched ";
			if (ZoneLevelInfoSettings.fontOutline) then
				ZoneLevelInfoSettings.fontOutline = false;
				confirmMsg = confirmMsg .. "off.";
			else
				ZoneLevelInfoSettings.fontOutline = true;
				confirmMsg = confirmMsg .. "on.";
			end
			ZoneLevelInfo_SetFonts(ZoneLevelInfoSettings.fontLarge,ZoneLevelInfoSettings.fontOutline);
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("ZONE" == cmd) then
			local confirmMsg = "ZoneLevelInfo details at zone zoom-level switched ";
			if (ZoneLevelInfoSettings.showAtZoneZoom) then
				ZoneLevelInfoSettings.showAtZoneZoom = false;
				confirmMsg = confirmMsg .. "off.";
			else
				ZoneLevelInfoSettings.showAtZoneZoom = true;
				confirmMsg = confirmMsg .. "on.";
			end
			ZoneLevelInfo_SetFonts(ZoneLevelInfoSettings.fontLarge,ZoneLevelInfoSettings.fontOutline);
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("PET" == cmd) then
			local confirmMsg = "ZoneLevelInfo pet level details shown switched ";
			if (ZoneLevelInfoSettings.showPetLevels) then
				ZoneLevelInfoSettings.showPetLevels = false;
				confirmMsg = confirmMsg .. "off.";
			else
				ZoneLevelInfoSettings.showPetLevels = true;
				confirmMsg = confirmMsg .. "on.";
			end
			ZoneLevelInfo_SetFonts(ZoneLevelInfoSettings.fontLarge,ZoneLevelInfoSettings.fontOutline);
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("TOGGLE" == cmd) then
			local confirmMsg = "ZoneLevelInfo switched ";
			if (notActive) then
				WorldMapFrameAreaLabel:Hide();
				WorldMapFrameAreaPetLevels:Hide();
				WorldMapFrameAreaDescription:Hide();
				ZoneLevelInfoFrame:Show();
				notActive=false;
				confirmMsg = confirmMsg .. "ON";
			else
				WorldMapFrameAreaLabel:Show();
				WorldMapFrameAreaPetLevels:Show();
				WorldMapFrameAreaDescription:Show();
				ZoneLevelInfoFrame:Hide();
				notActive=true;
				confirmMsg = confirmMsg .. "OFF";
			end
			confirmMsg = confirmMsg .. ". This setting is not saved between sessions.";
			ZoneLevelInfo_SetFonts(ZoneLevelInfoSettings.fontLarge,ZoneLevelInfoSettings.fontOutline);
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("SCALE" == cmd) then		-- set the frame scale (relative to world map frame)
			local confirmMsg = "ZoneLevelInfo scale ";
			local setScale = arg1:match("^%s*(%d+)%s*$");
			if (setScale ~= nil and tonumber(setScale)>=20 and tonumber(setScale)<=500) then
				ZoneLevelInfoSettings.scale = floor(tonumber(setScale));
				ZoneLevelInfoFrame:SetScale(ZoneLevelInfoSettings.scale/100);
				confirmMsg = confirmMsg .. "set to " ..ZoneLevelInfoSettings.scale.."%.";
			else
				confirmMsg = confirmMsg .. "currently " ..ZoneLevelInfoSettings.scale.."%. Settable range: 20-500.";
				if (arg1 ~= "") then
					confirmMsg = confirmMsg .. " (Option unknown: '"..arg1.."')";
				end
			end
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("INDENTX" == cmd) then		-- set the X indent
			local confirmMsg = "ZoneLevelInfo indentX ";
			local setIndent = arg1:match("^%s*(%d+)%s*$");
			if (setIndent ~= nil and tonumber(setIndent)>=0 and tonumber(setIndent)<=10000) then
				ZoneLevelInfoSettings.indentX = floor(tonumber(setIndent));
				ZoneLevelInfoFrame_MainText:SetPoint("TOPLEFT","WorldMapDetailFrame","TOPLEFT",floor(ZoneLevelInfoSettings.indentX*(savedScale+0.3)), floor(-ZoneLevelInfoSettings.indentY*(savedScale+0.3)));
				confirmMsg = confirmMsg .. "set to " ..ZoneLevelInfoSettings.indentX..".";
			else
				confirmMsg = confirmMsg .. "currently " ..ZoneLevelInfoSettings.indentX..". Settable range: 0-10000.";
				if (arg1 ~= "") then
					confirmMsg = confirmMsg .. " (Option unknown: '"..arg1.."')";
				end
			end
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("INDENTY" == cmd) then		-- set the Y indent
			local confirmMsg = "ZoneLevelInfo indentY ";
			local setIndent = arg1:match("^%s*(%d+)%s*$");
			if (setIndent ~= nil and tonumber(setIndent)>=0 and tonumber(setIndent)<=10000) then
				ZoneLevelInfoSettings.indentY = floor(tonumber(setIndent));
				ZoneLevelInfoFrame_MainText:SetPoint("TOPLEFT","WorldMapDetailFrame","TOPLEFT",floor(ZoneLevelInfoSettings.indentX*(savedScale+0.3)), floor(-ZoneLevelInfoSettings.indentY*(savedScale+0.3)));
				confirmMsg = confirmMsg .. "set to " ..ZoneLevelInfoSettings.indentY..".";
			else
				confirmMsg = confirmMsg .. "currently " ..ZoneLevelInfoSettings.indentY..". Settable range: 0-10000.";
				if (arg1 ~= "") then
					confirmMsg = confirmMsg .. " (Option unknown: '"..arg1.."')";
				end
			end
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		elseif ("DEV" == cmd) then		-- enable dev mode
			ZLI_DEV = true;
			WorldMapFrameAreaLabel:Show();
			WorldMapFrameAreaPetLevels:Show();
			WorldMapFrameAreaDescription:Show();
			local confirmMsg = "ZoneLevelInfo Developer mode enabled. Reload UI or relog to disable.";
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. confirmMsg);

		else -- either a gap command or an incorrect option
			local badCmd = "";
			if (_msg ~= "" and _msg ~= "?" and _msg ~= "HELP") then badCmd = " Unknown command: '" .. _msg .. "'"; end;

			local outlineSetting="OFF";
			if (ZoneLevelInfoSettings.fontOutline) then outlineSetting="ON"; end
			local showAtZoneZoom="OFF";
			if (ZoneLevelInfoSettings.showAtZoneZoom) then showAtZoneZoom="ON"; end
			local showPetLevels="OFF";
			if (ZoneLevelInfoSettings.showPetLevels) then showPetLevels="ON"; end
			local zliShow="ON";
			if (notActive) then zliShow="OFF"; end

			local helpMsg = "/zonelevelinfo or /zli " .. badCmd .. "\n" ..
				"/zli default: resets options (size:22; outline:ON; zone:ON; toggle:ON).\n" ..
				"/zli size n: sets zone text size to 'n', where 'n' is 10-24. ["..ZoneLevelInfoSettings.fontLarge.."]\n" ..
				"/zli outline: toggles text outline on/off. ["..outlineSetting.."]\n" ..
				"/zli zone: toggles ZoneLevelInfo details on zone zoom-level. ["..showAtZoneZoom.."]\n" ..
				"/zli pet: toggles ZoneLevelInfo pet levels on/off. ["..showPetLevels.."]\n" ..
				"/zli toggle: toggles ZoneLevelInfo on/off for the current session ["..zliShow.."]";
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. helpMsg);
		end
	end
end

SLASH_ZLI1 = "/zonelevelinfo";
SLASH_ZLI2 = "/zli";	



--============================
--= Loaded
--============================

local function ZoneLevelInfo_OnEvent(self, event, arg1, ...)
	if ( event == "ADDON_LOADED" and arg1:lower() == "zonelevelinfo" ) then

		currentLocale,currentLocaleSupported,L,zones,zoneNumberTable,continentNumberTable,missingZones = ZoneLevelInfo_init(zoneDefault);

		local defaultReset = false;
		if (ZoneLevelInfoDefaultsVersion ~= ZoneLevelInfoSettings["defaultVersion"]) then
			defaultReset = true;
			ZoneLevelInfoSettings = {};
			ZoneLevelInfoSettings["defaultVersion"] = ZoneLevelInfoDefaultsVersion;
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00ZoneLevelInfo defaults are being reset (new version).");
		end
		for ZLI_default_key,ZLI_default_value in next,ZoneLevelInfoDefaults do
			if (ZoneLevelInfoSettings[ZLI_default_key] == nil or defaultReset) then
				ZoneLevelInfoSettings[ZLI_default_key] = ZLI_default_value;
			end
		end

		ZoneLevelInfo_SetFonts(ZoneLevelInfoSettings.fontLarge,ZoneLevelInfoSettings.fontOutline);
		ZoneLevelInfoFrame:SetScale(ZoneLevelInfoSettings.scale/100);

		local okMessage = "OK";
		if (missingZones) then
			okMessage = "with errors, see above..";
		end

		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00ZoneLevelInfo "..ZLI_VERSION.." loaded for ["..currentLocale.."] "..okMessage..". For options use /zli");

		WorldMapFrameAreaLabel:Hide();
		WorldMapFrameAreaPetLevels:Hide();
		WorldMapFrameAreaDescription:Hide();
		--WorldMapZoneInfo:Hide();
		notActive=false;

		--FOR FINDING THE TEXT FIELDS!!
		--local k,v;
		--for k,v in pairs(_G) do
		--	if (k:find("WorldMapFrameArea") ~= nil) then
		--		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00" .. k);
		--	end
		--end

	end
end
ZoneLevelInfo_Frame:SetScript("OnEvent", ZoneLevelInfo_OnEvent);