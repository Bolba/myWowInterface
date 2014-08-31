-------------------------------
-- Database
-- ========
--
-- zoneDetail array -
--                 1,2: low level, high level
--					0,0 will not show any level range
--					<0,<0 denotes a capital city
--					x,y (anything else) will show as level range
--
--                 3: zone type
--					N - contested zone or neutral (sanctuary) capital city
--					A - Alliance controlled/favored
--					H - Horde controlled/favored
--					C - Continent (loaded automatically during init)
--					X - PvP combat zone (Wintergrasp, etc)
--
-------------------------------

function ZoneLevelInfo_DB()

	local zoneDetail = {

	-- KALOMDOR and EASTERN KINGDOMS
		 ["Ironforge"] = {-1,-1,"A"}
		,["Stormwind City"] = {-1,-1,"A"}
		,["Darnassus"] = {-1,-1,"A"}
		,["The Exodar"] = {-1,-1,"A"}
		,["Deeprun Tram"] = {-1,-1,"A"}
		,["Silvermoon City"] = {-1,-1,"H"}
		,["Undercity"] = {-1,-1,"H"}
		,["Orgrimmar"] = {-1,-1,"H"}
		,["Thunder Bluff"] = {-1,-1,"H"}
		,["Ahn'Qiraj: The Fallen Kingdom"] = {0,0,"N"}
		,["GM Island"] = {0,0,"N"}
		,["Moonglade"] = {0,0,"N"}
		,["The Steam Pools"] = {0,0,"N"}
		,["The Veiled Sea"] = {0,0,"N"}
		,["Ruins of Gilneas City"] = {1,5,"A",["Note"]="Worgen only"}
		,["Ruins of Gilneas"] = {1,12,"A",["Note"]="Worgen only"}
		,["Dun Morogh"] = {1,10,"A"}
		,["Elwynn Forest"] = {1,10,"A"}
		,["Azuremyst Isle"] = {1,10,"A"}
		,["Teldrassil"] = {1,10,"A"}
		,["Eversong Woods"] = {1,10,"H"}
		,["Tirisfal Glades"] = {1,10,"H"}
		,["Durotar"] = {1,10,"H"}
		,["Mulgore"] = {1,10,"H"}
		,["Westfall"] = {10,15,"A"}
		,["Loch Modan"] = {10,20,"A"}
		,["Bloodmyst Isle"] = {10,20,"A"}
		,["Darkshore"] = {10,20,"A"}
		,["Ghostlands"] = {10,20,"H"}
		,["Silverpine Forest"] = {10,20,"H"}
		,["Azshara"] = {10,20,"H"}
		,["Northern Barrens"] = {10,20,"H"}
		,["Redridge Mountains"] = {15,20,"A"}
		,["Duskwood"] = {20,25,"A"}
		,["Hillsbrad Foothills"] = {20,25,"H"}
		,["Ashenvale"] = {20,25,"N"}
		,["Arathi Highlands"] = {25,30,"N"}
		,["Northern Stranglethorn"] = {25,30,"N"}
		,["Wetlands"] = {20,25,"A"}
		,["Stonetalon Mountains"] = {25,30,"N"}
		,["The Cape of Stranglethorn"] = {30,35,"N"}
		,["The Hinterlands"] = {30,35,"N"}
		,["Southern Barrens"] = {30,35,"N"}
		,["Desolace"] = {30,35,"N"}
		,["Stranglethorn Vale"] = {25,35,"N"}
		,["Western Plaguelands"] = {35,40,"N"}
		,["Dustwallow Marsh"] = {35,40,"N"}
		,["Feralas"] = {35,40,"N"}
		,["Badlands"] = {44,48,"N"}
		,["Swamp of Sorrows"] = {52,54,"N"}
		,["Eastern Plaguelands"] = {40,45,"N"}
		,["Thousand Needles"] = {40,45,"N"}
		,["Searing Gorge"] = {47,51,"N"}
		,["Felwood"] = {45,50,"N"}
		,["Tanaris"] = {45,50,"N"}
		,["Un'Goro Crater"] = {50,55,"N"}
		,["Winterspring"] = {50,55,"N"}
		,["Burning Steppes"] = {49,52,"N"}
		,["Blackrock Mountain"] = {50,60,"N"}
		,["Deadwind Pass"] = {0,0,"N"}
		,["Plaguelands: The Scarlet Enclave"] = {55,58,"N"}
		,["Blasted Lands"] = {54,60,"N"}
		,["Silithus"] = {55,60,"N"}
		,["Isle of Quel'Danas"] = {70,70,"N"}
		,["Vashj'ir"] = {80,82,"N"}
		,["Kelp'thar Forest"] = {80,82,"N"}	--Vashj'ir
		,["Shimmering Expanse"] = {80,82,"N"}	--Vashj'ir
		,["Abyssal Depths"] = {80,82,"N"}	--Vashj'ir
		,["Mount Hyjal"] = {80,82,"N"}
		,["Twilight Highlands"] = {84,85,"N"}
		,["Uldum"] = {83,84,"N"}
	-- ELSEWHERE IN AZEROTH
		,["Deepholm"] = {82,83,"N"}
		,["Kezan"] = {1,5,"H",["Note"]="Goblin only"}
		,["The Lost Isles"] = {5,12,"H",["Note"]="Goblin only"}
		,["The Maelstrom"] = {0,0,"S"}
		,["Tol Barad"] = {84,85,"X"}
		,["Tol Barad Peninsula"] = {85,85,"N"}
	-- OUTLANDS
		,["Hellfire Peninsula"] = {58,63,"N"}
		,["Zangarmarsh"] = {60,64,"N"}
		,["Terokkar Forest"] = {62,65,"N"}
		,["Nagrand"] = {64,67,"N"}
		,["Blade's Edge Mountains"] = {65,68,"N"}
		,["Netherstorm"] = {67,70,"N"}
		,["Shadowmoon Valley"] = {67,70,"N"}
		,["Shattrath City"] = {-1,-1,"S"}
	-- NORTHREND
		,["Borean Tundra"] = {68,72,"N"}
		,["Howling Fjord"] = {68,72,"N"}
		,["Dragonblight"] = {71,75,"N"}
		,["Grizzly Hills"] = {73,75,"N"}
		,["Crystalsong Forest"] = {77,80,"N"}
		,["Zul'Drak"] = {74,76,"N"}
		,["Sholazar Basin"] = {76,78,"N"}
		,["Hrothgar's Landing"] = {77,80,"N"}
		,["Icecrown"] = {77,80,"N"}
		,["The Storm Peaks"] = {77,80,"N"}
		,["Wintergrasp"] = {77,80,"X"}
		,["Dalaran"] = {-1,-1,"S"}
	-- New Mistst starting zones
		,["Ammen Vale"] = {1,5,"A"}
		,["Camp Narache"] = {1,5,"H"}
		,["Echo Isles"] = {1,5,"H"}
		,["Shadowglen"] = {1,5,"A"}
		,["Valley of Trials"] = {1,5,"H"}
		,["Coldridge Valley"] = {1,5,"A"}
		,["Deathknell"] = {1,5,"H"}
		,["New Tinkertown"] = {1,5,"A"}
		,["Northshire"] = {1,5,"A"}
		,["Sunstrider Isle"] = {1,5,"H"}
	-- PANDARIA
		,["Dread Wastes"] = {89,90,"N"}
		,["Krasarang Wilds"] = {86,87,"N"}
		,["Kun-Lai Summit"] = {87,88,"N"}
		,["Shrine of Seven Stars"] = {-1,-1,"A"}
		,["Shrine of Two Moons"] = {-1,-1,"H"}
		,["The Jade Forest"] = {85,86,"N"}
		,["The Veiled Stair"] = {87,87,"N"}
		,["Townlong Steppes"] = {88,89,"N"}
		,["Vale of Eternal Blossoms"] = {90,90,"N"}
		,["Valley of the Four Winds"] = {86,87,"N"}
		,["Isle of Giants"] = {90,90,"N"}
		,["Isle of Thunder"] = {90,90,"N"}
		,["Timeless Isle"] = {90,90,"N"}
	-- END OF LEVEL DATA
		};


--*****************
--* PETS DATABASE
--*****************
	local zonePetLevels = {

	-- KALOMDOR	
		 ["Ahn'Qiraj: The Fallen Kingdom"] = {16,17}
		,["Ashenvale"] = {4,6}
		,["Azshara"] = {3,6}
		,["Azuremyst Isle"] = {1,2}
		,["Bloodmyst Isle"] = {3,6}
		,["Darkshore"] = {3,6}
		,["Darnassus"] = {1,3}
		,["Desolace"] = {7,9}
		,["Durotar"] = {1,2}
		,["Dustwallow Marsh"] = {12,13}
		,["The Exodar"] = {1,3}
		,["Felwood"] = {14,15}
		,["Feralas"] = {11,12}
		,["Moonglade"] = {15,16}
		,["Mount Hyjal"] = {22,24}
		,["Mulgore"] = {1,2}
		,["Northern Barrens"] = {3,4}
		,["Orgrimmar"] = {1,1}
		,["Silithus"] = {16,17}
		,["Southern Barrens"] = {9,10}
		,["Stonetalon Mountains"] = {5,7}
		,["Tanaris"] = {13,14}
		,["Teldrassil"] = {1,2}
		,["Thousand Needles"] = {13,14}
		,["Thunder Bluff"] = {1,3}
		,["Uldum"] = {23,24}
		,["Un'Goro Crater"] = {15,16}
		,["Winterspring"] = {17,18}
	-- EASTERN KINGDOMS
		,["Arathi Highlands"] = {7,8}
		,["Badlands"] = {13,14}
		,["Blasted Lands"] = {16,17}
		,["Burning Steppes"] = {15,16}
		,["Deadwind Pass"] = {17,18}
		,["Dun Morogh"] = {1,2}
		,["Duskwood"] = {5,7}
		,["Eastern Plaguelands"] = {12,13}
		,["Elwynn Forest"] = {1,2}
		,["Eversong Woods"] = {1,2}
		,["Ghostlands"] = {3,6}
		,["Hillsbrad Foothills"] = {6,7}
		,["Ironforge"] = {1,3}
		,["Loch Modan"] = {3,6}
		,["Northern Stranglethorn"] = {7,9}
		,["Redridge Mountains"] = {4,6}
		,["Searing Gorge"] = {13,14}
		,["Silverpine Forest"] = {3,6}
		,["Silvermoon City"] = {1,3}
		,["Stormwind City"] = {1,1}
		,["Stranglethorn Vale"] = {7,10}
		,["Swamp of Sorrows"] = {14,15}
		,["The Hinterlands"] = {11,12}
		,["The Cape of Stranglethorn"] = {9,10}
		,["Tirisfal Glades"] = {1,2}
		,["Undercity"] = {1,3}
		,["Western Plaguelands"] = {10,11}
		,["Westfall"] = {3,4}
		,["Wetlands"] = {6,7}
		,["Twilight Highlands"] = {23,24}
		,["Tol Barad"] = {23,24}
		,["Tol Barad Peninsula"] = {23,24}
	--CATACLYSM
		,["Deepholm"] = {22,23}
	--OUTLAND
		,["Blade's Edge Mountains"] = {18,20}
		,["Hellfire Peninsula"] = {17,18}
		,["Nagrand"] = {18,19}
		,["Netherstorm"] = {20,21}
		,["Shadowmoon Valley"] = {20,21}
		,["Terokkar Forest"] = {18,19}
		,["Zangarmarsh"] = {18,19}
	--NORTHREND
		,["Borean Tundra"] = {20,22}
		,["Crystalsong Forest"] = {22,23}
		,["Dragonblight"] = {22,23}
		,["Grizzly Hills"] = {21,22}
		,["Howling Fjord"] = {20,22}
		,["Icecrown"] = {22,23}
		,["Sholazar Basin"] = {21,22}
		,["The Storm Peaks"] = {22,23}
		,["Zul'Drak"] = {22,23}
	--PANDARIA
		,["Dread Wastes"] = {24,25}
		,["Krasarang Wilds"] = {23,25}
		,["Kun-Lai Summit"] = {23,25}
		,["The Jade Forest"] = {23,25}
		,["Townlong Steppes"] = {24,25}
		,["Vale of Eternal Blossoms"] = {24,25}
		,["Valley of the Four Winds"] = {23,25}
		,["Isle of Thunder"] = {25,25}
		,["Timeless Isle"] = {25,25}
	--END OF PET DATA
		};

	local pet_zone,pet_level;

	for pet_zone,pet_level in next,zonePetLevels do
		if (zoneDetail[pet_zone] ~= nil) then
			zoneDetail[pet_zone]["pet"] = pet_level;
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00ZoneLevelInfo DATABASE ERROR: Pet zone not found: "..pet_zone);
		end
	end

	return zoneDetail;
end;

