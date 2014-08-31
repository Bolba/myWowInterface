function ZoneLevelInfo_init(zoneDefault)

	local currentLocale,currentLocaleSupported,L,Z = ZoneLevelInfo_locale();

	local continentNumberTable = { GetMapContinents() };

	local _;	-- throw-away variables

	local zones = {};
	local zoneNumberTable = {};
	for ckey, continent in next, continentNumberTable do
		zones[continent..zoneDefault]={0,0,"C"};
		zoneNumberTable[ckey] = { GetMapZones(ckey) };
	end


	-------------------------------
	-- Database Load

	local zoneDetail = ZoneLevelInfo_DB();

	local missingZones = false;
	for ckey, mapContinents in next, zoneNumberTable do
		for zkey, mapZoneName in next, mapContinents do
			if (zoneDetail[Z[mapZoneName]]) then
				--if (mapZoneName == continentNumberTable[5]) then	--fix for malestrom being a zone and a continent, cheers Blizz!!
				--	local mapZoneNameTemp = mapZoneName..zoneDefault;
				--	zones[mapZoneNameTemp] = zoneDetail[Z[mapZoneName]];
				--else
					zones[mapZoneName] = zoneDetail[Z[mapZoneName]];
				--end
			else
				zones[mapZoneName] = zoneDefault;
				missingZones = true;
				if (currentLocaleSupported) then
					DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600ZoneLevelInfo ERROR - zone not known: ["..ckey..":"..zkey..":"..mapZoneName.."]");
				end
			end
		end
	end


	-------------------------------
	-- Database Load

	if (missingZones) then
		if (currentLocaleSupported) then
			--DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600ZoneLevelInfo ERROR - one or more missing zones. ZoneLevelInfo is out of date or has a bug. Please report on Curse with the missing zones if this is the current game release version.");
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600ZoneLevelInfo "..L["MISSING ZONES ERROR"]);
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600ZoneLevelInfo ERROR - your locale ["..GetLocale().."] is not supported. Loaded ["..currentLocale.."]. There will probably be a lot of missing info.");
		end
	end

	return currentLocale,currentLocaleSupported,L,zones,zoneNumberTable,continentNumberTable,missingZones;

end	