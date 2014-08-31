--Initialize local variables--
local version = "5.4.8.0"
local isModel = false
local isCustom = false
local ModelPique_ItemId_Table = {}
local ModelPique_SpellId_Table = {}
local ModelPique_BattlePetId_Table = {}
local ModelPique_ItemToSpell_Table = {}
local ModelPique_SpellName_Table = {}
local ModelPique_Camera_Table = {}
local buttonTable = {}
local buttonNum
local button = CreateFrame("Button", "ModelPique_Button", DressUpFrame, "UIPanelButtonTemplate")
button:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", 0, 0)
button:SetWidth(100)
button:SetHeight(22)
button:Hide()
local frame, model

--Global to local variables--
local pairs = pairs
local strmatch = string.match
local tonumber = tonumber
local format = string.format

--Functions--
local function ModelPique_ShowModel(modelName, displayId, battlePet)
	if not displayId then return end
	frame = nil
	model = nil
	if SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() then
		--if battlePet then return end--let blizzard handle display of battle pets
		frame, model = SideDressUpFrame, SideDressUpModel
		isModel = false
	else
		frame, model = DressUpFrame, DressUpModel
		isModel=true
		DressUpFrameTitleText:SetText(format("%s%s","Model Pique v",version))
		DressUpFrameDescriptionText:SetText(modelName)
		DressUpFrameDescriptionText:SetPoint("CENTER", "DressUpFrameTitleText", "BOTTOM", "0", "-22")
		DressUpFrameDescriptionText:SetFontObject(GameFontNormal)
	end
	if not frame:IsShown() or frame.mode ~= "battlepet" then
		SetDressUpBackground(frame, "Pet")
		ShowUIPanel(frame)
	end
	if frame == DressUpFrame then
		SetPortraitTexture(DressUpFramePortrait, displayId)
	end
	local camera = ModelPique_Camera_Table[displayId]
	if camera then
		model:SetModelScale(camera.S)
		model:SetPosition(camera.X, camera.Y, camera.Z)
		frame.mode = "battlepet"
		frame.ResetButton:Hide()
		model:SetDisplayInfo(displayId)
		isCustom = true
	else
		frame.mode = "battlepet"
		frame.ResetButton:Hide()
		model:SetDisplayInfo(displayId)
	end
end

local function ModelPique_GetDisplayID(link)
	if not link then return end
	local item = tonumber(strmatch(link, "item:(%d+)"))
	local spellId = tonumber(strmatch(link, "spell:(%d+)"))
	local enchant = tonumber(strmatch(link, "enchant:(%d+)"))
	local battlePet = tonumber(strmatch(link, "battlepet:(%d+)"))
	if item then
		local compare = ModelPique_ItemId_Table[item]
		if type(compare) == "table" then
			buttonNum = 1
			buttonTable = compare
			if buttonTable[buttonNum].button ~= "" then
				button:SetText(buttonTable[buttonNum].button)
				button:Show()
			end
			ModelPique_ShowModel(ModelPique_GetDisplayID(GetSpellLink(buttonTable[buttonNum].id)))
			return
		end
		spellId = ModelPique_ItemToSpell_Table[item]
		if not spellId and compare then 
			for k,v in pairs(ModelPique_SpellId_Table) do
				if v == compare and k ~= item then
					spellId = k
				end
			end
		end
	end
	local modelName = ModelPique_SpellName_Table[spellId] or GetSpellInfo(spellId or enchant) or strmatch(link,"%[(.*)%]")
	return modelName, ModelPique_ItemId_Table[item] or ModelPique_SpellId_Table[spellId or enchant] or ModelPique_BattlePetId_Table[battlePet], battlePet
end

button:SetScript("OnClick", function(self, button, down)
	buttonNum = buttonNum < #buttonTable and buttonNum + 1 or 1
	ModelPique_ShowModel(ModelPique_GetDisplayID(GetSpellLink(buttonTable[buttonNum].id)))
	ModelPique_Button:SetText(buttonTable[buttonNum].button)
end)

hooksecurefunc("DressUpItemLink",function(link)
	if not IsDressableItem(link) then
		if isCustom then
			model:SetModelScale(2)
			model:SetPosition(0,0,0)
			isCustom = false
		end
		ModelPique_Button:Hide()
		ModelPique_ShowModel(ModelPique_GetDisplayID(link))
	else
		if isModel then
			if isCustom then
				model:SetModelScale(2)
				Model_Reset(model)
				isCustom = false
			end
			ModelPique_Button:Hide()
			DressUpFrameTitleText:SetText(DRESSUP_FRAME)
			DressUpFrameDescriptionText:SetText(DRESSUP_FRAME_INSTRUCTIONS)
			DressUpFrameDescriptionText:SetPoint("CENTER", "DressUpFrameTitleText", "BOTTOM", "10", "-22")
			DressUpFrameDescriptionText:SetFontObject("GameFontNormalSmall")
			SetPortraitTexture(DressUpFramePortrait, "player")
			local _, fileName = UnitRace("player")
				SetDressUpBackground(DressUpFrame, fileName)
			DressUpModel:SetUnit("player")
			DressUpModel:TryOn(link)
		end
		isModel = false
	end
end)

--Item Data table--
ModelPique_ItemId_Table = {
------------------------------------------
--**************************************--
--*************** MOUNTS ***************--
--**************************************--
------------------------------------------
--1.11.1 and earlier
[18796]=14573,--Swift Brown Wolf
[21176]=15676,--Black Qiraji Battle Tank
[12302]=9695,--Ancient Frostsaber
[12303]=9991,--Black Nightsaber
[12330]=2326,--Red Wolf
[12351]=1166,--Winter Wolf
[12353]=2410,--White Stallion
[12354]=2408,--Palomino
[13086]=10426,--Winterspring Frostsaber
[13317]=6471,--Ivory Raptor
[13326]=9474,--White Mechanostrider Mod B
[13327]=10666,--Icy Blue Mechanostrider Mod A
[13328]=2784,--Black Ram
[13329]=2787,--Frost Ram
[13334]=10720,--Green Skeletal Warhorse
[13335]=10718,--Rivendare's Deathcharger
[15292]=12245,--Green Kodo
[15293]=12242,--Teal Kodo
[18766]=14331,--Swift Frostsaber
[18767]=14332,--Swift Mistsaber
[18772]=14374,--Swift Green Mechanostrider
[18773]=14376,--Swift White Mechanostrider
[18774]=14377,--Swift Yellow Mechanostrider
[18776]=14582,--Swift Palomino
[18777]=14583,--Swift Brown Steed
[18778]=14338,--Swift White Steed
[18785]=14346,--Swift White Ram
[18786]=14347,--Swift Brown Ram
[18787]=14576,--Swift Gray Ram
[18788]=14339,--Swift Blue Raptor
[18789]=14344,--Swift Olive Raptor
[18790]=14342,--Swift Orange Raptor
[18791]=10721,--Purple Skeletal Warhorse
[18793]=14349,--Great White Kodo
[18794]=14578,--Great Brown Kodo
[18795]=14579,--Great Gray Kodo
[8586]=6469,--Mottled Red Raptor
[18797]=14575,--Swift Timber Wolf
[18798]=14574,--Swift Gray Wolf
[18902]=14632,--Swift Stormsaber
[19029]=14776,--Frostwolf Howler
[19030]=14777,--Stormpike Battle Charger
[19872]=15289,--Swift Razzashi Raptor
[19902]=15290,--Swift Zulian Tiger
[21218]=15672,--Blue Qiraji Battle Tank
[21321]=15681,--Red Qiraji Battle Tank
[21323]=15679,--Green Qiraji Battle Tank
[21324]=15680,--Yellow Qiraji Battle Tank
[8591]=6472,--Turquoise Raptor
[1132]=247,--Timber Wolf
[2414]=2409,--Pinto
[5655]=2405,--Chestnut Mare
[5656]=2404,--Brown Horse
[5665]=2327,--Dire Wolf
[5668]=2328,--Brown Wolf
[5864]=2736,--Gray Ram
[5872]=2785,--Brown Ram
[5873]=2786,--White Ram
[8563]=9473,--Red Mechanostrider
[8588]=4806,--Emerald Raptor
[2411]=2402,--Black Stallion
[8592]=6473,--Violet Raptor
[8595]=6569,--Blue Mechanostrider
[8629]=6448,--Striped Nightsaber
[8631]=6080,--Striped Frostsaber
[8632]=6444,--Spotted Frostsaber
[13321]=10661,--Green Mechanostrider
[13322]=9476,--Unpainted Mechanostrider
[13331]=10670,--Red Skeletal Horse
[13332]=10671,--Blue Skeletal Horse
[13333]=10672,--Brown Skeletal Horse
[15277]=12246,--Gray Kodo
[15290]=11641,--Brown Kodo
--2.0
[23720]=17158,--Riding Turtle
--2.0.1
[25477]=17719,--Swift Red Wind Rider
[25532]=17722,--Swift Yellow Wind Rider
[25533]=17721,--Swift Purple Wind Rider
[25531]=17720,--Swift Green Wind Rider
[25470]=17697,--Golden Gryphon
[25471]=17694,--Ebon Gryphon
[25472]=17696,--Snowy Gryphon
[25474]=17699,--Tawny Wind Rider
[25475]=17700,--Blue Wind Rider
[25476]=17701,--Green Wind Rider
[28915]=21074,--Dark Riding Talbuk
[28936]=18697,--Swift Pink Hawkstrider
[29102]=19375,--Cobalt War Talbuk
[29103]=19377,--White War Talbuk
[29104]=19378,--Silver War Talbuk
[29105]=19376,--Tan War Talbuk
[29223]=19484,--Swift Green Hawkstrider
[29224]=19482,--Swift Purple Hawkstrider
[29227]=19375,--Cobalt War Talbuk
[29228]=19303,--Dark War Talbuk
[29229]=19378,--Silver War Talbuk
[29230]=19376,--Tan War Talbuk
[29231]=19377,--White War Talbuk
[29465]=14372,--Black Battlestrider
[29466]=14348,--Black War Kodo
[29467]=14577,--Black War Ram
[29468]=14337,--Black War Steed
[29469]=14334,--Black War Wolf
[29470]=10719,--Red Skeletal Warhorse
[29471]=14330,--Black War Tiger
[29472]=14388,--Black War Raptor
[29745]=19871,--Great Blue Elekk
[29746]=19873,--Great Green Elekk
[29747]=19872,--Great Purple Elekk
[30480]=19250,--Fiery Warhorse
[31829]=21073,--Cobalt Riding Talbuk
[31830]=21073,--Cobalt Riding Talbuk
[31831]=21075,--Silver Riding Talbuk
[31832]=21075,--Silver Riding Talbuk
[31833]=21077,--Tan Riding Talbuk
[31834]=21077,--Tan Riding Talbuk
[31835]=21076,--White Riding Talbuk
[31836]=21076,--White Riding Talbuk
[28481]=17063,--Brown Elekk
[28927]=18696,--Red Hawkstrider
[29220]=19480,--Blue Hawkstrider
[29221]=19478,--Black Hawkstrider
[29222]=19479,--Purple Hawkstrider
[29743]=19870,--Purple Elekk
[29744]=19869,--Gray Elekk
--2.1
[32319]=21156,--Blue Riding Nether Ray
[25473]=17759,--Swift Blue Gryphon
[25528]=17703,--Swift Green Gryphon
[25529]=17717,--Swift Purple Gryphon
[32314]=21152,--Green Riding Nether Ray
[32316]=21155,--Purple Riding Nether Ray
[32317]=21158,--Red Riding Nether Ray
[32318]=21157,--Silver Riding Nether Ray
[25527]=17718,--Swift Red Gryphon
[32857]=21520,--Onyx Netherwing Drake
[32858]=21521,--Azure Netherwing Drake
[32859]=21525,--Cobalt Netherwing Drake
[32860]=21523,--Purple Netherwing Drake
[32861]=21522,--Veridian Netherwing Drake
[32862]=21524,--Violet Netherwing Drake
[32768]=21473,--Raven Lord
--2.1.1
[32458]=17890,--Ashes of Al'ar
--2.1.2
[30609]=20344,--Swift Nether Drake
--2.2
[33977]=22350,--Swift Brewfest Ram
[33976]=22265,--Brewfest Ram
--2.2.2
[33182]=21939,--Swift Flying Broom
[33184]=21939,--Swift Magic Broom
[33176]=21939,--Flying Broom
--[33183]=,--Old Magic Broom
--2.3
[25596]=17890,--Peep the Phoenix Mount
[33809]=22464,--Amani War Bear
[33999]=22473,--Cenarion War Hippogryph
[34061]=22720,--Turbo-Charged Flying Machine
[34092]=22620,--Merciless Nether Drake
[34060]=22719,--Flying Machine
[34129]=20359,--Swift Warstrider
--2.4
[35513]=19483,--Swift White Hawkstrider
[35906]=23928,--Black War Elekk
--2.4.2
[37676]=24725,--Vengeful Nether Drake
--2.4.3
[43516]=27507,--Brutal Nether Drake
[37719]=24745,--Swift Zhevra
[37828]=24757,--Great Brewfest Kodo
[37012]=25159,--Headless Horseman's Mount
[43599]=27567,--Big Blizzard Bear
[37011]=21939,--Magic Broom
[39476]=24758,--Fresh Goblin Brewfest Hops
[39477]=22265,--Fresh Dwarven Brewfest Hops
--3.0.1
[41508]=25871,--Mechano-Hog
[44502]=25871,--Mechano-Hog(Recipe)
[40775]=28108,--Winged Steed of the Ebon Blade
--3.0.2
[44413]=25870,--Mekgineer's Chopper
[44503]=25870,--Mekgineer's Chopper(Recipe)
[44221]=17697,--Loaned Gryphon Reins
[44229]=17699,--Loaned Wind Rider Reins
[44168]=28045,--Time-Lost Proto-Drake
[43952]=27785,--Azure Drake
[43954]=27796,--Twilight Drake
[43955]=25835,--Red Drake
[43951]=25833,--Bronze Drake
[44151]=28041,--Blue Proto-Drake
[43953]=25832,--Blue Drake
[44178]=25836,--Albino Drake
[44558]=28060,--Magnificent Flying Carpet
[44689]=27913,--Armored Snowy Gryphon
[44690]=27914,--Armored Blue Wind Rider
[43986]=25831,--Black Drake
[44554]=28082,--Flying Carpet
[44223]=27818,--Black War Bear
[43956]=27247,--Black War Mammoth
[43961]=27242,--Grand Ice Mammoth
[43962]=28428,--White Polar Bear
[44077]=27245,--Black War Mammoth
[44080]=27246,--Ice Mammoth
[44086]=27239,--Grand Ice Mammoth
[43958]=27248,--Ice Mammoth
[44224]=27819,--Black War Bear
[44225]=27820,--Armored Brown Bear
[44226]=27821,--Armored Brown Bear
[44230]=27243,--Wooly Mammoth
[44231]=27244,--Wooly Mammoth
[44234]=27238,--Traveler's Tundra Mammoth
[44235]=27237,--Traveler's Tundra Mammoth
--3.0.3
[44160]=28044,--Red Proto-Drake
[44707]=28053,--Green Proto-Drake
[43959]=27241,--Grand Black War Mammoth
--3.0.8
[44175]=28042,--Plagued Proto-Drake
--3.0.9
[44164]=28040,--Black Proto-Drake
[44083]=27240,--Grand Black War Mammoth
--3.1
[46109]=29161,--Sea Turtle
[44843]=27525,--Blue Dragonhawk
[45693]=28890,--Mimiron's Head
[45725]=22471,--Argent Hippogryph
[44842]=28402,--Red Dragonhawk
[45125]=28912,--Stormwind Steed
[45586]=29258,--Ironforge Ram
[45589]=28571,--Gnomeregan Mechanostrider
[45590]=29255,--Exodar Elekk
[45591]=29256,--Darnassian Nightsaber
[45592]=29259,--Thunder Bluff Kodo
[45593]=29261,--Darkspear Raptor
[45595]=29260,--Orgrimmar Wolf
[45596]=29262,--Silvermoon Hawkstrider
[45597]=29257,--Forsaken Warhorse
[46101]=10718,--Blue Skeletal Warhorse
[46099]=207,--Black Wolf
[46100]=12241,--White Kodo
[46308]=29130,--Black Skeletal Horse
--3.1.1
[46171]=25593,--Furious Gladiator's Frost Wyrm
--3.1.2
[45802]=28954,--Rusted Proto-Drake
[46752]=29043,--Swift Gray Steed
[46744]=14333,--Swift Moonsaber
[46745]=28606,--Great Red Elekk
[46746]=28605,--White Skeletal Warhorse
[46743]=14343,--Swift Purple Raptor
[46748]=28612,--Swift Violet Ram
[46749]=14335,--Swift Burgundy Wolf
[46750]=28556,--Great Golden Kodo
[46751]=28607,--Swift Red Hawkstrider
[46747]=14375,--Turbostrider
--3.1.3
[45801]=28953,--Ironbound Proto-Drake
--3.2
[44177]=28043,--Violet Proto-Drake
[46813]=22474,--Silver Covenant Hippogryph
[46814]=29696,--Sunreaver Dragonhawk
[49286]=23647,--X-51 Nether-Rocket X-TREME
[46708]=25511,--Deadly Gladiator's Frost Wyrm
[49285]=23656,--X-51 Nether-Rocket
[46102]=29102,--Venomhide Ravasaur
[46815]=28888,--Quel'dorei Steed
[46816]=28889,--Sunreaver Hawkstrider
[47101]=29754,--Ochre Skeletal Warhorse
[47179]=28919,--Argent Charger
[47180]=28918,--Argent Warhorse
[49044]=29284,--Swift Alliance Steed
[49096]=29937,--Crusader's White Warhorse
[49098]=29938,--Crusader's Black Warhorse
[49282]=25335,--Big Battle Bear
[49284]=21974,--Swift Spectral Tiger
[49290]=29344,--Magic Rooster
[47100]=29755,--Striped Dawnsaber
[49283]=21973,--Spectral Tiger
--3.2.2
[49636]=30346,--Onyxian Drake
[49046]=29283,--Swift Horde Wolf
[49288]=30141,--Little Ivory Raptor Whistle
[49289]=30518,--Little White Stallion Bridle
--3.3
[50818]=31007,--Invincible
[50818]=31007,--Invincible(Recipe)
--3.3.2
[51954]=31156,--Bloodbathed Frostbrood Vanquisher
[50250]=30989,--Big Love Rocket
--3.3.3
[47840]=29794,--Relentless Gladiator's Frost Wyrm
[51955]=31154,--Icebound Frostbrood Vanquisher
[54797]=28063,--Frosty Flying Carpet
[54798]=28063,--Frosty Flying Carpet(Recipe)
[54069]=31803,--Blazing Hippogryph
[54860]=31992,--X-53 Touring Rocket
[52200]=25279,--Crimson Deathcharger
[54811]=31958,--Celestial Steed
--3.3.5
[54068]=31721,--Wooly White Rhino
--4.0.1
[65891]=35750,--Sandstone Drake
[67538]=35750,--Sandstone Drake(Recipe)
[63043]=35751,--Vitreous Stone Drake
[62900]=35551,--Volcanic Stone Drake
[62901]=35757,--Drake of the East Wind
[63039]=35754,--Drake of the West Wind
[63040]=35553,--Drake of the North Wind
[63041]=35755,--Drake of the South Wind
[63042]=35740,--Phosphorescent Stone Drake
[50435]=31047,--Wrathful Gladiator's Frost Wyrm
[63125]=37145,--Dark Phoenix
[64998]=37160,--Spectral Steed
[64999]=37159,--Spectral Wolf
[65356]=35754,--Drake of the West Wind
[63044]=35136,--Brown Riding Camel
[63045]=35134,--Tan Riding Camel
[63046]=35135,--Grey Riding Camel
[64883]=15672,--Ultramarine Qiraji Battle Tank
--4.0.3
[67151]=34955,--Subdued Seahorse
[54465]=34956,--Abyssal Seahorse
[68008]=37231,--Mottled Drake
[60954]=34410,--Fossilized Raptor
[62462]=35250,--Goblin Turbo-Trike
[62298]=36213,--Golden King
[67107]=37138,--Kor'kron Annihilator
[62461]=35249,--Goblin Trike
--4.1
[69747]=38261,--Amani Battle Bear
[69213]=38018,--Flameward Hippogryph
[69224]=38031,--Pureblood Fire Hawk
[68825]=37800,--Amani Dragonhawk
[68823]=14341,--Armored Razzashi Raptor
[68824]=37799,--Swift Zulian Panther
[69228]=38048,--Savage Raptor
[69846]=38260,--Winged Guardian
[69846]=38260,--Winged Guardian(Recipe)
--4.2
[69230]=38046,--Corrupted Fire Hawk
[71339]=38756,--Vicious Gladiator's Twilight Drake
[70909]=38668,--Vicious War Steed
[70910]=38607,--Vicious War Wolf
[71665]=38783,--Flametalon of Alysrazor
--4.3
[77067]=39561,--Blazing Drake
[77069]=39563,--Life-Binder's Handmaiden
[78919]=39229,--Experiment 12-B
[77068]=39562,--Twilight Harbinger
[71954]=38755,--Ruthless Gladiator's Twilight Drake
[74269]=31803,--Blazing Hippogryph
[76889]=39546,--Spectral Gryphon
[76902]=39547,--Spectral Wind Rider
[73839]=39095,--Swift Mountain Horse
[71718]=17011,--Swift Shorestrider
[72140]=1281,--Swift Forest Strider
[72145]=16992,--Swift Springstrider
[72146]=1961,--Swift Lovebird
[72575]=37204,--White Riding Camel
[73766]=39060,--Darkmoon Dancing Bear
[76755]=39530,--Tyrael's Charger
[78924]=40029,--Heart of the Aspects
[73838]=39096,--Mountain Horse
[72582]=38972,--Corrupted Hippogryph
--4.3.2
[79771]=40568,--Feldrake
--5.0.1
[83088]=42502,--Jade Panther
[83845]=42502,--Jade Panther(Recipe)
[79802]=40590,--Jade Cloud Serpent
[82453]=42185,--Jeweled Onyx Panther
[83877]=42185,--Jeweled Onyx Panther(Recipe)
[84101]=42703,--Grand Expedition Yak
[85429]=41991,--Golden Cloud Serpent
[85430]=41989,--Azure Cloud Serpent
[87768]=41990,--Onyx Cloud Serpent
[87769]=41592,--Crimson Cloud Serpent
[87771]=43689,--Heavenly Onyx Cloud Serpent
[87773]=43692,--Heavenly Crimson Cloud Serpent
[87774]=43693,--Heavenly Golden Cloud Serpent
[87777]=46087,--Astral Cloud Serpent
[87781]=43704,--Azure Riding Crane
[87782]=43705,--Golden Riding Crane
[87783]=43706,--Regal Riding Crane
[87788]=43711,--Grey Riding Yak
[87789]=43712,--Blonde Riding Yak
[89154]=44633,--Crimson Pandaren Phoenix
[89304]=43686,--Thundering August Cloud Serpent
[89305]=44759,--Green Shado-Pan Riding Tiger
[89306]=44757,--Red Shado-Pan Riding Tiger
[89307]=43900,--Blue Shado-Pan Riding Tiger
[89362]=44807,--Brown Riding Goat
[89390]=44837,--White Riding Goat
[89391]=44836,--Black Riding Goat
[89783]=45264,--Son of Galleon
[83087]=42499,--Ruby Panther
[83931]=42499,--Ruby Panther(Recipe)
[81354]=41711,--Azure Water Strider
[83089]=42501,--Sunstone Panther
[83830]=42501,--Sunstone Panther(Recipe)
[83090]=42500,--Sapphire Panther
[83932]=42500,--Sapphire Panther(Recipe)
[81559]=41903,--Pandaren Kite
[85666]=43562,--Thundering Jade Cloud Serpent
[89785]=45271,--Pandaren Kite
[85262]=43090,--Amber Scorpion
[83086]=42498,--Obsidian Nightwing
[87250]=43637,--Depleted-Kyparium Rocket
[87251]=43638,--Geosynchronous World Spinner
[89363]=44808,--Red Flying Cloud
[82811]=42352,--Great Red Dragon Turtle
[87801]=43722,--Great Green Dragon Turtle
[87802]=43723,--Great Black Dragon Turtle
[87803]=43724,--Great Blue Dragon Turtle
[87804]=43725,--Great Brown Dragon Turtle
[87805]=43726,--Great Purple Dragon Turtle
[85870]=43254,--Imperial Quilen
[82765]=42250,--Green Dragon Turtle
[87795]=43717,--Black Dragon Turtle
[87796]=43718,--Blue Dragon Turtle
[87797]=43719,--Brown Dragon Turtle
[87799]=43720,--Purple Dragon Turtle
[87800]=43721,--Red Dragon Turtle
[89682]=44635,--Oddly-Shaped Horn
[89697]=45163,--Bag of Kafa Beans
[89770]=45242,--Tuft of Yak Fur
[87775]=43695,--Heavenly Jade Cloud Serpent
[87776]=43697,--Heavenly Azure Cloud Serpent
--5.0.4
[90655]=45797,--Thundering Ruby Cloud Serpent
[90711]=45520,--Emerald Pandaren Phoenix
[90712]=45522,--Violet Pandaren Phoenix
[90710]=45521,--Ashen Pandaren Phoenix
[91010]=42352,--Great Red Dragon Turtle
[91011]=43723,--Great Black Dragon Turtle
[91012]=43722,--Great Green Dragon Turtle
[91013]=43724,--Great Blue Dragon Turtle
[91014]=43725,--Great Brown Dragon Turtle
[91015]=43726,--Great Purple Dragon Turtle
[91004]=42250,--Green Dragon Turtle
[91005]=43719,--Brown Dragon Turtle
[91006]=43720,--Purple Dragon Turtle
[91007]=43721,--Red Dragon Turtle
[91008]=43717,--Black Dragon Turtle
[91009]=43718,--Blue Dragon Turtle
--5.0.5
[85785]=38757,--Cataclysmic Gladiator's Twilight Drake
--5.1
[93168]=46929,--Grand Armored Gryphon
[93169]=46930,--Grand Armored Wyvern
[93385]=47166,--Grand Gryphon
[93386]=47165,--Grand Wyvern
[91802]=42147,--Jade Pandaren Kite
[92724]=46729,--Swift Windsteed
--5.2
[93666]=47238,--Spawn of Horridon
[95057]=47981,--Thundering Cobalt Cloud Serpent
[95059]=47983,--Clutch of Ji-Kun
[95564]=48100,--Golden Primal Direhorn
[95565]=48101,--Crimson Primal Direhorn
[95041]=47976,--Malevolent Gladiator's Cloud Serpent
[95416]=46686,--Sky Golem
[93662]=47256,--Armored Skyscreamer
[93671]=48014,--Ghastly Charger
[94228]=47716,--Cobalt Primordial Direhorn
[94229]=47715,--Slate Primordial Direhorn
[94230]=47718,--Amber Primordial Direhorn
[94231]=47717,--Jade Primordial Direhorn
[94290]=47825,--Bone-White Primal Raptor
[94291]=47826,--Red Primal Raptor
[94292]=47828,--Black Primal Raptor
[94293]=47827,--Green Primal Raptor
[95341]=48020,--Armored Bloodwing
--5.3
[98405]=48858,--Brawler's Burly Mushan Beast
[98104]=48815,--Armored Red Dragonhawk
[98259]=48816,--Armored Blue Dragonhawk
[97989]=48714,--Enchanted Fey Dragon
[98618]=48931,--Hearthsteed
--5.4
[104327]=51359,--Prideful Gladiator's Cloud Serpent
[103638]=51484,--Ashhide Mushan Beast
[104246]=51481,--Kor'kron War Wolf
[104253]=51485,--Kor'kron Juggernaut
[104269]=51488,--Thundering Onyx Cloud Serpent
[104325]=51361,--Tyrannical Gladiator's Cloud Serpent
[104326]=51360,--Grievous Gladiator's Cloud Serpent
[104208]=51479,--Spawn of Galakras
[102514]=51037,--Vicious Warsaber
[102533]=51048,--Vicious Skeletal Warhorse
[103630]=17158,--Riding Turtle
[104011]=51323,--Stormcrow
[101675]=49295,--Shimmering Moonstone
[104329]=51484,--Ash-Covered Horn
[104346]=51591,--Golden Glider
--5.4.1
[106246]=51993,--Emerald Hippogryph
--5.4.2
[107951]=53038,--Iron Skyreaver
--5.4.7
[109013]=53774,--Armored Dread Raven
--5.4.8
[112326]=55896,--Warforged Nightmare
[112327]=55907,--Grinning Reaver
------------------------------------------
--**************************************--
--************* COMPANIONS *************--
--**************************************--
------------------------------------------
--1.11.1 and earlier
[12264]=9563,--Worg Pup
[21277]=10269,--Tranquil Mechanical Yeti
[12529]=27718,--Smolderweb Hatchling
[20769]=15436,--Disgusting Oozeling
[15996]=901,--Lifelike Toad
[16044]=901,--Lifelike Toad(Recipe)
[11474]=6294,--Sprite Darter Hatchling
[11825]=8909,--Pet Bombling
[11828]=8909,--Pet Bombling(Recipe)
[11826]=8910,--Lil' Smoky
[11827]=8910,--Lil' Smoky(Recipe)
[10398]=7920,--Mechanical Chicken
[11026]=6295,--Tree Frog
[11027]=901,--Wood Frog
[19450]=14938,--Jubling
--[19462]=,--Unhatched Jubling Egg
[11023]=5369,--Ancona Chicken
[8499]=6290,--Crimson Whelpling
[8500]=4615,--Great Horned Owl
[8501]=6299,--Hawk Owl
[10360]=1206,--Black Kingsnake
[10361]=2957,--Brown Snake
[10392]=6303,--Crimson Snake
[10393]=2177,--Undercity Cockroach
[10394]=1072,--Brown Prairie Dog
[10822]=6288,--Dark Whelpling
[8498]=6291,--Emerald Whelpling
[8494]=6192,--Hyacinth Macaw
[13582]=10993,--Zergling
[13583]=10990,--Panda Cub
[13584]=10992,--Mini Diablo
[20371]=15369,--Murky
[8485]=5556,--Bombay Cat
[8486]=5586,--Cornish Rex Cat
[8487]=5554,--Orange Tabby Cat
[8488]=5555,--Silver Tabby Cat
[8489]=9990,--White Kitten
[8490]=5585,--Siamese Cat
[8491]=5448,--Black Tabby Cat
[8492]=5207,--Green Wing Macaw
[8495]=6190,--Senegal
[8496]=6191,--Cockatiel
[8497]=328,--Snowshoe Rabbit
[4401]=7937,--Mechanical Squirrel
[4408]=7937,--Mechanical Squirrel(Recipe)
[23015]=2176,--Whiskers the Rat
[11110]=304,--Westfall Chicken
[21301]=15660,--Father Winter's Helper
[21305]=15663,--Winter's Little Helper
[21308]=15904,--Winter Reindeer
[23083]=16587,--Spirit of Summer
--[22200]=,--Silver Shafted Arrow
[22235]=15992,--Peddlefeet
[23002]=16259,--Speedy
[23007]=16257,--Mr. Wiggles
[21309]=13610,--Tiny Snowman
--1.12.1
[18964]=14657,--Loggerhead Snapjaw
[19054]=14779,--Tiny Red Dragon
[19055]=14778,--Tiny Green Dragon
--2.0
[23713]=16943,--Hippogryph Hatchling
--2.0.1
[31760]=20996,--Miniwing
[29363]=19600,--Mana Wyrmling
[29364]=4626,--Brown Rabbit
[29902]=19986,--Red Moth
[29958]=20029,--Blue Dragonhawk Hatchling
[27445]=18269,--Magical Crawdad
[29901]=19987,--Blue Moth
[29903]=19985,--Yellow Moth
[29904]=19999,--White Moth
[29953]=20026,--Golden Dragonhawk Hatchling
[29956]=20027,--Red Dragonhawk Hatchling
[29957]=20037,--Silver Dragonhawk Hatchling
[32588]=21362,--Bananas
--2.0.3
[23712]=37949,--White Tiger Cub
--2.1
[22114]=15984,--Gurky
[25535]=17723,--Netherwhelp
[32616]=21382,--Egbert
[32617]=21381,--Willy
[32622]=21393,--Peanut
[29960]=20042,--Firefly
[30360]=15398,--Lurky
--2.2.2
[32233]=22349,--Wolpertinger
[33154]=21900,--Sinister Squashling
--2.3
[34478]=22855,--Tiny Sporebat
[34535]=6293,--Azure Whelpling
[33993]=22459,--Mojo
[34493]=22966,--Dragon Kite
[34425]=22776,--Clockwork Rocket Bot
[34492]=22903,--Rocket Chicken
--2.4
[35504]=23574,--Phoenix Hatchling
[33816]=22388,--Toothy
[33818]=22389,--Muckbreath
[35349]=23507,--Snarly
[35350]=23506,--Chuck
--2.4.2
[38628]=25457,--Nether Ray Fry
[34955]=8409,--Searing Scorchling
[38050]=25002,--Ethereal Soul-Trader
[39656]=25900,--Mini Tyrael
[32498]=21328,--Lucky
--2.4.3
[37297]=24393,--Spirit of Competition
--[37710]=25332,--Crashin' Thrashin' Racer
--3.0.1
[21168]=15595,--Baby Shark
[40653]=16633,--Stinker
--3.0.2
[38658]=4185,--Vampiric Batling
[39973]=28089,--Ghostly Skull
[43698]=27627,--Giant Sewer Rat
[44723]=28216,--Pengu
[39896]=45919,--Tickbird Hatchling
[39899]=28215,--White Tickbird Hatchling
[44721]=28217,--Proto-Drake Whelp
[44481]=26524,--Grindgear Toy Gorilla
[44482]=27829,--Trusty Copper Racer
--3.0.3
[39286]=28456,--Frosty
[44738]=45937,--Kirin Tor Familiar
[39898]=28084,--Cobra Hatchling
[44819]=16189,--Baby Blizzard Bear
--3.0.8
[44841]=28397,--Little Fawn
--3.1
[44822]=2955,--Albino Snake
[45942]=29060,--XS-001 Constructor Bot
[44794]=6302,--Spring Rabbit
[44965]=28482,--Teldrassil Sproutling
[44970]=28489,--Dun Morogh Cub
[44971]=4732,--Tirisfal Batling
[44973]=15470,--Durotar Scorpion
[44974]=16205,--Elwynn Lamb
[44980]=28502,--Mulgore Hatchling
[44983]=45880,--Strand Crawler
[44984]=28493,--Ammen Vale Lashling
[44998]=28946,--Argent Squire
[45002]=28539,--Mechanopeep
[45022]=28948,--Argent Gruntling
[45057]=28599,--Wind-Up Train Wrecker
[45606]=46939,--Sen'jin Fetish
[44982]=45960,--Enchanted Broom
[44601]=27829,--Heavy Copper Racer
[44599]=27829,--Zippy Copper Racer
[45047]=28811,--Sandbox Tiger
--3.1.2
[45180]=28734,--Murkimus the Gladiator
--3.1.3
[46767]=29279,--Warbot
--3.2
[48112]=29805,--Darting Hatchling
[48116]=29803,--Gundrak Hatchling
[48118]=29802,--Leaping Hatchling
[48120]=29809,--Obsidian Hatchling
[48122]=29810,--Ravasaur Hatchling
[48124]=29808,--Razormaw Hatchling
[48126]=29806,--Razzashi Hatchling
[48114]=29807,--Deviate Hatchling
[46707]=22629,--Pint-Sized Pink Pachyderm
[46802]=29348,--Grunty
[46544]=25384,--Curious Wolvar Pup
[46545]=25173,--Curious Oracle Hatchling
[46820]=29372,--Shimmering Wyrmling
[46821]=29372,--Shimmering Wyrmling
[46396]=25384,--Wolvar Orphan Whistle
[46397]=25173,--Oracle Orphan Whistle
--3.2.2
[49362]=30356,--Onyxian Whelpling
[41133]=26452,--Mr. Chilly
[44810]=45968,--Plump Turkey
[49665]=30414,--Pandaren Monk
[49693]=30507,--Lil' K.T.
[46831]=29404,--Macabre Marionette
[49287]=30157,--Tuskarr Kite
[49343]=30409,--Spectral Tiger Cub
--3.3
[46398]=11709,--Calico Cat
[49646]=30462,--Core Hound Pup
[49912]=31174,--Perky Pug
[34518]=21304,--Golden Pig
[34519]=22938,--Silver Pig
[37298]=24620,--Essence of Competition
[22781]=16189,--Poley
[45047]=28811,--Sandbox Tiger
--3.3.2
[49662]=30412,--Gryphon Hatchling
[49663]=30413,--Wind Rider Cub
[50446]=31073,--Toxic Wasteling
--3.3.3
[53641]=31722,--Frigid Frostling
[54847]=32031,--Lil' XT
[54436]=22778,--Blue Clockwork Rocket Bot
--[54343]=25332,--Blue Crashin' Thrashin' Racer 
--3.3.5
[56806]=32670,--Mini Thor
--4.0.1
[63138]=37136,--Dark Phoenix Hatchling
[64403]=33217,--Fox Kit
[63398]=36220,--Armadillo Pup
[63355]=36499,--Rustberg Seagull
[64996]=36499,--Rustberg Seagull
[67128]=32031,--Landro's Lil' XT
[67418]=36896,--Deathy
[66076]=9905,--Mr. Grubbs
[65362]=37199,--Guild Page
[65363]=37198,--Guild Herald
[65364]=37196,--Guild Herald
[65661]=32699,--Blue Mini Jouster
[65662]=32707,--Gold Mini Jouster
[65361]=37200,--Guild Page
--4.0.3
[60955]=34413,--Fossilized Hatchling
[46892]=28734,--Murkimus the Gladiator
[49664]=30402,--Zipao Tiger
[62540]=35338,--Lil' Deathwing
[62769]=15393,--Eat the Egg
[48527]=29819,--Onyx Panther
[68385]=37541,--Lil' Ragnaros
[68618]=37526,--Moonkin Hatchling
[68619]=37527,--Moonkin Hatchling
[67600]=6290,--Lil&#039; Alexstrasza
[60847]=34262,--Crawling Claw
[66080]=28435,--Tiny Flamefly
[59597]=33512,--Personal World Destroyer
[60216]=33559,--De-Weaponized Mechanical Companion
[64372]=36211,--Clockwork Gnome
[67274]=36902,--Enchanted Lantern
[67308]=36902,--Enchanted Lantern(Recipe)
[67275]=36901,--Magic Lamp
[67312]=36901,--Magic Lamp(Recipe)
[67282]=45878,--Elementium Geode
[46325]=45943,--Withers
[60869]=45940,--Pebble
[64494]=36637,--Tiny Shale Spider
[66067]=37154,--Singing Sunflower
[66073]=38135,--Scooter the Snail
[54810]=31956,--Celestial Dragon
[46709]=17192,--MiniZep Controller
--4.0.6
[68673]=27718,--Smolderweb Hatchling
--4.1
[69991]=22855,--Tiny Sporebat
[69824]=38232,--Voodoo Figurine
[69821]=38229,--Pterrordax Hatchling
[68840]=30507,--Landro's Lichling
[68841]=37846,--Nightsaber Cub
[69648]=38134,--Legs
[69847]=38359,--Guardian Cub
[70099]=16943,--Cenarion Hatchling
[68833]=37814,--Panther Cub
[69239]=37712,--Winterspring Cub
[69992]=29372,--Shimmering Wyrmling
[69251]=38065,--Lashtail Hatchling
--4.2
[71033]=38614,--Lil' Tarecgosa
[72068]=38359,--Guardian Cub
[70908]=38539,--Feline Familiar
[71076]=38638,--Creepy Crate
[71726]=38803,--Murkablo
[70140]=38455,--Hyjal Bear Cub
[72045]=38342,--Horde Balloon
[71137]=38691,--Brewfest Keg Pony
[71140]=38693,--Nuts
[71387]=38776,--Brilliant Kaliri
[72042]=38343,--Alliance Balloon
[70160]=38429,--Crimson Lasher
--4.3
[73953]=39109,--Sea Pony
[71624]=38777,--Purple Puffer
[72153]=39694,--Sand Scarab
[73762]=38344,--Darkmoon Balloon
[73764]=46001,--Darkmoon Monkey
[73765]=38809,--Darkmoon Turtle
[73797]=45939,--Lumpy
[73903]=15381,--Darkmoon Tonk
[73905]=17192,--Darkmoon Zeppelin
[72134]=38919,--Gregarious Grell
[74981]=39137,--Darkmoon Cub
[76062]=39380,--Fetish Shaman
[78916]=40019,--Soul of the Aspects
[75040]=38344,--Flimsy Darkmoon Balloon
[75041]=38340,--Flimsy Green Balloon
[75042]=38341,--Flimsy Yellow Balloon
[74610]=39163,--Lunar Lantern
[74611]=39333,--Festival Lantern
[77158]=39319,--Darkmoon "Tiger"
--4.3.2
[79744]=40538,--Eye of the Legion
--5.0.1
[85513]=43865,--Thundering Serpent Hatchling
[87526]=45386,--Mechanical Pandaren Dragonling
[80008]=45957,--Darkmoon Rabbit
[85220]=44655,--Terrible Turnip
[85222]=46385,--Red Cricket
[85447]=47955,--Tiny Goldfish
[85578]=45894,--Feral Vermling
[85871]=43255,--Lucky Quilen Cub
[89587]=41833,--Porcupette
[89686]=45987,--Jade Tentacle
[89736]=45195,--Venus
[87567]=44792,--Food
[87568]=44791,--Food
[88148]=43868,--Jade Crane Chick
[82774]=15905,--Jade Owl
[90470]=15905,--Jade Owl(Recipe)
[82775]=42297,--Sapphire Cub
[90471]=42297,--Sapphire Cub(Recipe)
[86562]=43597,--Hopling
[86563]=45854,--Aqua Strider
[86564]=45938,--Grinder
[88147]=43127,--Singing Cricket
[84105]=42721,--Fishy
[89367]=44792,--Yu'lon Kite
[89368]=44791,--Chi-Ji Kite
--5.0.3
[74622]=16587,--Fire Spirit
[89640]=45072,--Life Spirit
[89641]=45073,--Water Spirit
--5.0.4
[90897]=33217,--Fox Kit
[90898]=33217,--Fox Kit
[90173]=45942,--Pandaren Water Spirit
[90177]=45527,--Baneling
[90953]=30409,--Spectral Cub
[90953]=30409,--Spectral Cub
[90953]=30409,--Spectral Cub
--5.1
[90900]=44551,--Imperial Moth
[91040]=46174,--Darkmoon Eye
[92707]=46720,--Cinder Kitten
[92798]=46809,--Pandaren Fire Spirit
[92799]=46810,--Pandaren Air Spirit
[92800]=46811,--Pandaren Earth Spirit
[93031]=46897,--Mr. Bigglesworth
[90902]=40521,--Imperial Silkworm
[91031]=46171,--Darkmoon Glowfly
[91003]=46163,--Darkmoon Hatchling
[93029]=46921,--Stitched Pup
[93025]=46882,--Clock'em
[93032]=46896,--Fungal Abomination
[93033]=46900,--Harbinger of Flame
[93034]=46923,--Corefire Imp
[93035]=46902,--Ashstone Core
[93036]=46903,--Untamed Hatchling
[93037]=46905,--Death Talon Whelpguard
[93038]=46925,--Chrominius
[93039]=46924,--Viscidus Globule
[93040]=46922,--Anubisath Idol
[93041]=46909,--Mini Mindslayer
[93030]=46898,--Giant Bone Spider
[92959]=39331,--Darkmoon "Cougar"
[92968]=46695,--Darkmoon "Murloc"
[92969]=46696,--Darkmoon "Rocket"
[92956]=39330,--Darkmoon "Snow Leopard"
[92970]=46697,--Darkmoon "Wyvern"
[92966]=46693,--Darkmoon "Dragon"
[92958]=39332,--Darkmoon "Nightsaber"
[92967]=46694,--Darkmoon "Gryphon"
--5.2
[95422]=48055,--Zandalari Anklerender
[93669]=47348,--Gusting Grimoire
[94124]=47848,--Sunreaver Micro-Sentry
[94125]=47252,--Living Sandling
[94126]=47731,--Zandalari Kneebiter
[94152]=47708,--Son of Animus
[94190]=47732,--Spectral Porcupette
[94208]=47747,--Sunfur Panda
[94209]=47749,--Snowy Panda
[94210]=47748,--Mountain Panda
[94595]=48091,--Spawn of G'nathus
[94835]=48001,--Ji-Kun Hatchling
[94025]=47634,--Red Panda
[95423]=48056,--Zandalari Footslasher
[95424]=48057,--Zandalari Toenibbler
[95621]=29279,--Warbot
[94191]=48211,--Stunted Direhorn
[94573]=48213,--Direhorn Runt
[94574]=48212,--Pygmy Direhorn
[94903]=47711,--Pierre
[94932]=47959,--Tiny Red Carp
[94933]=47957,--Tiny Blue Carp
[94934]=47958,--Tiny Green Carp
[94935]=47960,--Tiny White Carp
--5.3
[98550]=48934,--Blossoming Ancient
[100870]=49081,--Murkimus Tyrannicus
[97821]=48651,--Gahz'rooki
[97548]=48878,--Lil' Bad Wolf
[97549]=48857,--Menagerie Custodian
[97550]=48856,--Netherspace Abyssal
[97551]=48662,--Fiendish Imp
[97552]=48855,--Tideskipper
[97961]=48708,--Filthling
[97554]=48661,--Coilfang Stalker
[97555]=48664,--Pocket Reaver
[97556]=48668,--Lesser Voidcaller
[97557]=48663,--Phoenix Hawk Hatchling
[97558]=48667,--Tito
[97959]=48704,--Living Fluid
[97960]=48705,--Viscous Horror
[97553]=48666,--Tainted Waveling
--5.4
[101570]=855,--Moon Moon
[104317]=51505,--Rotten Little Helper
[100905]=49084,--Rascal-Bot
[101771]=49846,--Xu-Fu, Cub of Xuen
[102145]=49835,--Chi-Chi, Hatchling of Chi-Ji
[102146]=49845,--Zao, Calfling of Niuzao
[102147]=49836,--Yu'la, Broodling of Yu'lon
[103637]=47858,--Vengeful Porcupette
[103670]=49289,--Lil' Bling
[104156]=40908,--Ashleaft Spriteling
[104157]=51413,--Azure Crane Chick
[104158]=51268,--Blackfuse Bombling
[104159]=51271,--Ruby Droplet
[104160]=51408,--Dandelion Frolicker
[104162]=51417,--Droplet of Y'Shaarj
[104163]=51267,--Gooey Sha-ling
[104164]=51270,--Jademist Dancer
[104165]=51269,--Kovok
[104166]=51272,--Ominous Flame
[104167]=51279,--Skunky Alemental
[104168]=51278,--Spineclaw Crab
[104169]=47991,--Gulp Froglet
[104202]=51475,--Bonkers
[104291]=51502,--Gu'chi Swarmling
[104295]=47856,--Harmonious Porcupette
[104307]=51504,--Jadefire Spirit
[104332]=51530,--Sky Lantern
[104333]=51530,--Flimsy Sky Lantern
[104161]=51277,--Death Adder Hatchling
--5.4.1
[106240]=51988,--Alterac Brew-Pup
[106244]=51990,--Murkalot
--5.4.2
[106256]=51994,--Treasure Goblin
[108438]=37526,--Moonkin Hatchling
--[104318]=51507,--Crashin' Thrashin' Flyer
--5.4.7
[109014]=53719,--Dread Hatchling
------------------------------------------
--**************************************--
--************* CONTAINERS *************--
--**************************************--
------------------------------------------
--1.11.1 and earlier
[20768]={
[1]={["id"]=20769, ["button"]=""},--Disgusting Oozeling
},--Oozing Bag
[21310]={
[1]={["id"]=26045, ["button"]="1/4"},--Tiny Snowman
[2]={["id"]=26529, ["button"]="2/4"},--Winter Reindeer
[3]={["id"]=26533, ["button"]="3/4"},--Father Winter's Helper
[4]={["id"]=26541, ["button"]="4/4"},--Winter's Little Helper
},--Gaily Wrapped Present
[21327]={
[1]={["id"]=21325, ["button"]="1/2"},--Mechanical Greench
[2]={["id"]=21213, ["button"]="2/2"},--Preserved Holly
},--Ticking Present
--2.2.2
[34077]={
[1]={["id"]=47977, ["button"]=""},--Magic Broom
},--Crudely Wrapped Gift
--2.4
[35348]={
[1]={["id"]=46426, ["button"]="1/4"},--Chuck
[2]={["id"]=43698, ["button"]="2/4"},--Muckbreath
[3]={["id"]=46425, ["button"]="3/4"},--Snarly
[4]={["id"]=43697, ["button"]="4/4"},--Toothy
},--Bag of Fishing Treasures
--2.4.3
[37586]={
[1]={["id"]=42609, ["button"]="1/2"},--Sinister Squashling
[2]={["id"]=47977, ["button"]="2/2"},--Magic Broom
},--Handful of Treats
--3.0.2
[39883]={
[1]={["id"]=61351, ["button"]="1/5"},--Cobra Hatchling
[2]={["id"]=61348, ["button"]="2/5"},--Tickbird Hatchling
[3]={["id"]=61349, ["button"]="3/5"},--White Tickbird Hatchling
[4]={["id"]=61350, ["button"]="4/5"},--Proto-Drake Whelp
[5]={["id"]=61294, ["button"]="5/5"},--Green Proto-Drake
},--Cracked Egg
[44751]={
[1]={["id"]=54753, ["button"]=""},--White Polar Bear
},--Hyldnir Spoils
--3.1
[45072]={
[1]={["id"]=61725, ["button"]="1/2"},--Spring Rabbit
[2]={["id"]=102349, ["button"]="2/2"},--Swift Springstrider
},--Brightly Colored Egg
[46007]={
[1]={["id"]=62561, ["button"]=""},--Strand Crawler
},--Bag of Fishing Treasures
--3.3
[50301]={
[1]={["id"]=62857, ["button"]=""},--Sandbox Tiger
},--Landro's Pet Box
--3.3.2
[52676]={
[1]={["id"]=59568, ["button"]=""},--Blue Drake
},--Cache of the Ley-Guardian
--3.3.3
[54535]={
[1]={["id"]=49379, ["button"]="1/2"},--Great Brewfest Kodo
[2]={["id"]=43900, ["button"]="2/2"},--Swift Brewfest Ram
},--Keg-Shaped Treasure Chest
[54536]={
[1]={["id"]=74932, ["button"]=""},--Frigid Frostling
},--Satchel of Chilled Goods
[54537]={
[1]={["id"]=71840, ["button"]="1/2"},--Toxic Wasteling
[2]={["id"]=71342, ["button"]="2/2"},--Big Love Rocket
},--Heart-Shaped Box
[51316]={
[1]={["id"]=73313, ["button"]=""},--Crimson Deathcharger
},--Unsealed Chest
--4.0.1
[54516]={
[1]={["id"]=42609, ["button"]="1/4"},--Sinister Squashling
[2]={["id"]=47977, ["button"]="2/4"},--Magic Broom
[3]={["id"]=42667, ["button"]="3/4"},--Flying Broom
[4]={["id"]=48025, ["button"]="4/4"},--Headless Horseman's Mount
},--Loot-Filled Pumpkin
[67414]={
[1]={["id"]=62561, ["button"]=""},--Strand Crawler
},--Bag of Shiny Things
--4.0.3
[61387]={
[1]={["id"]=93739, ["button"]=""},--Mr. Grubbs
},--Hidden Stash
[68384]={
[1]={["id"]=95786, ["button"]="1/2 (Alliance)"},--Moonkin Hatchling
[2]={["id"]=95909, ["button"]="2/2 (Horde)"},--Moonkin Hatchling
},--Moonkin Egg
[64657]={
[1]={["id"]=93326, ["button"]=""},--Sandstone Drake
},--Canopic Jar
--4.2
[71631]={
[1]={["id"]=45890, ["button"]=""},--Searing Scorchling
},--Zen'Vorka's Cache
--4.3
[77956]={
[1]={["id"]=107516, ["button"]="1/2 (Alliance)"},--Spectral Gryphon
[2]={["id"]=107517, ["button"]="2/2 (Horde)"},--Spectral Wind Rider
},--Spectral Mount Crate
--5.0.1
[85497]={
[1]={["id"]=123784, ["button"]=""},--Red Cricket
},--Chirping Package
[86623]={
[1]={["id"]=147124, ["button"]="1/13"},--Lil' Bling
[2]={["id"]=82173, ["button"]="2/13"},--De-Weaponized Mechanical Companion
[3]={["id"]=126885, ["button"]="3/13"},--Mechanical Pandaren Dragonling
[4]={["id"]=81937, ["button"]="4/13"},--Personal World Destroyer
[5]={["id"]=19772, ["button"]="5/13"},--Lifelike Toad
[6]={["id"]=15049, ["button"]="6/13"},--Lil' Smoky
[7]={["id"]=4055, ["button"]="7/13"},--Mechanical Squirrel
[8]={["id"]=15048, ["button"]="8/13"},--Pet Bombling
[9]={["id"]=26010, ["button"]="9/13"},--Tranquil Mechanical Yeti
[10]={["id"]=126507, ["button"]="10/13"},--Depleted-Kyparium Rocket
[11]={["id"]=126508, ["button"]="11/13"},--Geosynchronous World Spinner
[12]={["id"]=60424, ["button"]="12/13 (Alliance)"},--Mekgineer's Chopper
[13]={["id"]=55531, ["button"]="13/13 (Horde)"},--Mechano-Hog
},--Blingtron 4000 Gift Package
--5.1
[92960]={
[1]={["id"]=132580, ["button"]="1/2"},--Imperial Silkworm
[2]={["id"]=132574, ["button"]="2/2"},--Imperial Moth
},--Silkworm Cocoon
[91086]={
[1]={["id"]=132789, ["button"]=""},--Darkmoon Eye
},--Darkmoon Pet Supplies
--5.2
[94295]={
[1]={["id"]=138643, ["button"]="1/3"},--Green Primal Raptor
[2]={["id"]=138642, ["button"]="2/3"},--Black Primal Raptor
[3]={["id"]=138641, ["button"]="3/3"},--Red Primal Raptor
},--Primal Egg
[94296]={
[1]={["id"]=138643, ["button"]="1/3"},--Green Primal Raptor
[2]={["id"]=138642, ["button"]="2/3"},--Black Primal Raptor
[3]={["id"]=138641, ["button"]="3/3"},--Red Primal Raptor
},--Cracked Primal Egg
[93724]={
[1]={["id"]=135025, ["button"]="1/16"},--Darkmoon "Murloc"
[2]={["id"]=135026, ["button"]="2/16"},--Darkmoon "Rocket"
[3]={["id"]=135027, ["button"]="3/16"},--Darkmoon "Wyvern"
[4]={["id"]=135022, ["button"]="4/16"},--Darkmoon "Dragon"
[5]={["id"]=135023, ["button"]="5/16"},--Darkmoon "Gryphon"
[6]={["id"]=135009, ["button"]="6/16"},--Darkmoon "Cougar"
[7]={["id"]=135007, ["button"]="7/16"},--Darkmoon "Snow Leopard"
[8]={["id"]=135008, ["button"]="8/16"},--Darkmoon "Nightsaber"
[9]={["id"]=107926, ["button"]="9/16"},--Darkmoon "Tiger"
[10]={["id"]=103076, ["button"]="10/16"},--Darkmoon Balloon
[11]={["id"]=103544, ["button"]="11/16"},--Darkmoon Tonk
[12]={["id"]=103074, ["button"]="12/16"},--Darkmoon Turtle
[13]={["id"]=105122, ["button"]="13/16"},--Darkmoon Cub
[14]={["id"]=101733, ["button"]="14/16"},--Darkmoon Monkey
[15]={["id"]=103549, ["button"]="15/16"},--Darkmoon Zeppelin
[16]={["id"]=132762, ["button"]="16/16"},--Darkmoon Hatchling
},--Darkmoon Game Prize
--Winter Veil 2013
[104319]={
--[1]={["id"]=148577, ["button"]="1/4 (2013)"},--Crashin' Thrashin' Flyer
[1]={["id"]=65451, ["button"]="1/2 (2010)"},--MiniZep
--[2]={["id"]=49352, ["button"]="2/3 (2008)"},--Crashin' Thrashin' Racer
[2]={["id"]=54187, ["button"]="2/2 (2007)"},--Clockwork Rocket Bot
},--Winter Veil Gift
[93626]={
[1]={["id"]=148567, ["button"]="1/10 (2013)"},--Rotten Little Helper
[2]={["id"]=103125, ["button"]="2/10 (2012)"},--Lumpy
[3]={["id"]=65451, ["button"]="3/10 (2010)"},--MiniZep
--[4]={["id"]=49352, ["button"]="4/12 (2008)"},--Crashin' Thrashin' Racer
[4]={["id"]=54187, ["button"]="4/10 (2007)"},--Clockwork Rocket Bot
--[6]={["id"]=75111, ["button"]="6/12"},--Blue Crashin' Thrashin' Racer
[5]={["id"]=75134, ["button"]="5/10"},--Blue Clockwork Rocket Bot
[6]={["id"]=62949, ["button"]="6/10"},--Wind-Up Train Wrecker
[7]={["id"]=61022, ["button"]="7/10"},--Heavy Copper Racer
[8]={["id"]=61021, ["button"]="8/10"},--Zippy Copper Racer
[9]={["id"]=60838, ["button"]="9/10"},--Trusty Copper Racer
[10]={["id"]=60832, ["button"]="10/10"},--Grindgear Toy Gorilla
},--Stolen Present
}

--Spell Data table--
ModelPique_SpellId_Table = {
------------------------------------------
--**************************************--
--*************** MOUNTS ***************--
--**************************************--
------------------------------------------
--only spells
[48778]=25280,--Acherus Deathcharger
[127180]=43708,--Albino Riding Crane
[127209]=43709,--Black Riding Yak
[127213]=43710,--Brown Riding Yak
[123160]=42837,--Crimson Riding Crane
[127271]=43713,--Crimson Water Strider
[89520]=36022,--Goblin Mini Hotrod
[127278]=43716,--Golden Water Strider
[97501]=38032,--Green Fire Hawk


[127274]=43714,--Jade Water Strider
[127178]=43707,--Jungle Riding Crane
[127272]=43715,--Orange Water Strider
[123182]=41089,--White Riding Yak
--1.11.1 and earlier
[23250]=14573,--Swift Brown Wolf
[26656]=15676,--Black Qiraji Battle Tank
[16056]=9695,--Ancient Frostsaber
[16055]=9991,--Black Nightsaber
[16080]=2326,--Red Wolf
[16081]=1166,--Winter Wolf
[16083]=2410,--White Stallion
[16082]=2408,--Palomino
[17229]=10426,--Winterspring Frostsaber
[17450]=6471,--Ivory Raptor
[15779]=9474,--White Mechanostrider Mod B
[17459]=10666,--Icy Blue Mechanostrider Mod A
[17461]=2784,--Black Ram
[17460]=2787,--Frost Ram
[17465]=10720,--Green Skeletal Warhorse
[17481]=10718,--Rivendare's Deathcharger
[18991]=12245,--Green Kodo
[18992]=12242,--Teal Kodo
[23221]=14331,--Swift Frostsaber
[23219]=14332,--Swift Mistsaber
[23225]=14374,--Swift Green Mechanostrider
[23223]=14376,--Swift White Mechanostrider
[23222]=14377,--Swift Yellow Mechanostrider
[23227]=14582,--Swift Palomino
[23229]=14583,--Swift Brown Steed
[23228]=14338,--Swift White Steed
[23240]=14346,--Swift White Ram
[23238]=14347,--Swift Brown Ram
[23239]=14576,--Swift Gray Ram
[23241]=14339,--Swift Blue Raptor
[23242]=14344,--Swift Olive Raptor
[23243]=14342,--Swift Orange Raptor
[23246]=10721,--Purple Skeletal Warhorse
[23247]=14349,--Great White Kodo
[23249]=14578,--Great Brown Kodo
[23248]=14579,--Great Gray Kodo
[16084]=6469,--Mottled Red Raptor
[23251]=14575,--Swift Timber Wolf
[23252]=14574,--Swift Gray Wolf
[23338]=14632,--Swift Stormsaber
[23509]=14776,--Frostwolf Howler
[23510]=14777,--Stormpike Battle Charger
[24242]=15289,--Swift Razzashi Raptor
[24252]=15290,--Swift Zulian Tiger
[25953]=15672,--Blue Qiraji Battle Tank
[26054]=15681,--Red Qiraji Battle Tank
[26056]=15679,--Green Qiraji Battle Tank
[26055]=15680,--Yellow Qiraji Battle Tank
[10796]=6472,--Turquoise Raptor
[580]=247,--Timber Wolf
[472]=2409,--Pinto
[6648]=2405,--Chestnut Mare
[458]=2404,--Brown Horse
[6653]=2327,--Dire Wolf
[6654]=2328,--Brown Wolf
[6777]=2736,--Gray Ram
[6899]=2785,--Brown Ram
[6898]=2786,--White Ram
[10873]=9473,--Red Mechanostrider
[8395]=4806,--Emerald Raptor
[470]=2402,--Black Stallion
[10799]=6473,--Violet Raptor
[10969]=6569,--Blue Mechanostrider
[10793]=6448,--Striped Nightsaber
[8394]=6080,--Striped Frostsaber
[10789]=6444,--Spotted Frostsaber
[17453]=10661,--Green Mechanostrider
[17454]=9476,--Unpainted Mechanostrider
[17462]=10670,--Red Skeletal Horse
[17463]=10671,--Blue Skeletal Horse
[17464]=10672,--Brown Skeletal Horse
[18989]=12246,--Gray Kodo
[18990]=11641,--Brown Kodo
--2.0
[30174]=17158,--Riding Turtle
--2.0.1
[32246]=17719,--Swift Red Wind Rider
[32296]=17722,--Swift Yellow Wind Rider
[32297]=17721,--Swift Purple Wind Rider
[32295]=17720,--Swift Green Wind Rider
[32235]=17697,--Golden Gryphon
[32239]=17694,--Ebon Gryphon
[32240]=17696,--Snowy Gryphon
[32243]=17699,--Tawny Wind Rider
[32244]=17700,--Blue Wind Rider
[32245]=17701,--Green Wind Rider
[39316]=21074,--Dark Riding Talbuk
[33660]=18697,--Swift Pink Hawkstrider
[34896]=19375,--Cobalt War Talbuk
[34897]=19377,--White War Talbuk
[34898]=19378,--Silver War Talbuk
[34899]=19376,--Tan War Talbuk
[35025]=19484,--Swift Green Hawkstrider
[35027]=19482,--Swift Purple Hawkstrider
[34896]=19375,--Cobalt War Talbuk
[34790]=19303,--Dark War Talbuk
[34898]=19378,--Silver War Talbuk
[34899]=19376,--Tan War Talbuk
[34897]=19377,--White War Talbuk
[22719]=14372,--Black Battlestrider
[22718]=14348,--Black War Kodo
[22720]=14577,--Black War Ram
[22717]=14337,--Black War Steed
[22724]=14334,--Black War Wolf
[22722]=10719,--Red Skeletal Warhorse
[22723]=14330,--Black War Tiger
[22721]=14388,--Black War Raptor
[35713]=19871,--Great Blue Elekk
[35712]=19873,--Great Green Elekk
[35714]=19872,--Great Purple Elekk
[36702]=19250,--Fiery Warhorse
[39315]=21073,--Cobalt Riding Talbuk
[39315]=21073,--Cobalt Riding Talbuk
[39317]=21075,--Silver Riding Talbuk
[39317]=21075,--Silver Riding Talbuk
[39318]=21077,--Tan Riding Talbuk
[39318]=21077,--Tan Riding Talbuk
[39319]=21076,--White Riding Talbuk
[39319]=21076,--White Riding Talbuk
[34406]=17063,--Brown Elekk
[34795]=18696,--Red Hawkstrider
[35020]=19480,--Blue Hawkstrider
[35022]=19478,--Black Hawkstrider
[35018]=19479,--Purple Hawkstrider
[35711]=19870,--Purple Elekk
[35710]=19869,--Gray Elekk
--2.1
[39803]=21156,--Blue Riding Nether Ray
[32242]=17759,--Swift Blue Gryphon
[32290]=17703,--Swift Green Gryphon
[32292]=17717,--Swift Purple Gryphon
[39798]=21152,--Green Riding Nether Ray
[39801]=21155,--Purple Riding Nether Ray
[39800]=21158,--Red Riding Nether Ray
[39802]=21157,--Silver Riding Nether Ray
[32289]=17718,--Swift Red Gryphon
[41513]=21520,--Onyx Netherwing Drake
[41546]=21520,--Onyx Netherwing Drake(Recipe)
[41514]=21521,--Azure Netherwing Drake
[41547]=21521,--Azure Netherwing Drake(Recipe)
[41515]=21525,--Cobalt Netherwing Drake
[41543]=21525,--Cobalt Netherwing Drake(Recipe)
[41516]=21523,--Purple Netherwing Drake
[41544]=21523,--Purple Netherwing Drake(Recipe)
[41517]=21522,--Veridian Netherwing Drake
[41549]=21522,--Veridian Netherwing Drake(Recipe)
[41518]=21524,--Violet Netherwing Drake
[41548]=21524,--Violet Netherwing Drake(Recipe)
[41252]=21473,--Raven Lord
--2.1.1
[40192]=17890,--Ashes of Al'ar
--2.1.2
[37015]=20344,--Swift Nether Drake
--2.2
[43900]=22350,--Swift Brewfest Ram
[43899]=22265,--Brewfest Ram
--2.2.2
[42668]=21939,--Swift Flying Broom
[42668]=21939,--Swift Magic Broom
[42667]=21939,--Flying Broom
--2.3
[32345]=17890,--Peep the Phoenix Mount
[43688]=22464,--Amani War Bear
[43927]=22473,--Cenarion War Hippogryph
[44151]=22720,--Turbo-Charged Flying Machine
[44157]=22720,--Turbo-Charged Flying Machine(Recipe)
[44744]=22620,--Merciless Nether Drake
[44153]=22719,--Flying Machine
[44155]=22719,--Flying Machine(Recipe)
[35028]=20359,--Swift Warstrider
--2.4
[46628]=19483,--Swift White Hawkstrider
[48027]=23928,--Black War Elekk
--2.4.2
[49193]=24725,--Vengeful Nether Drake
--2.4.3
[58615]=27507,--Brutal Nether Drake
[49322]=24745,--Swift Zhevra
[49379]=24757,--Great Brewfest Kodo
[48025]=25159,--Headless Horseman's Mount
[58983]=27567,--Big Blizzard Bear
[47977]=21939,--Magic Broom
[66050]=22265,--Fresh Dwarven Brewfest Hops
[66051]=24758,--Fresh Goblin Brewfest Hops
--3.0.1
[55531]=25871,--Mechano-Hog
[60866]=25871,--Mechano-Hog(Recipe)
[54729]=28108,--Winged Steed of the Ebon Blade
--3.0.2
[60424]=25870,--Mekgineer's Chopper
[60867]=25870,--Mekgineer's Chopper(Recipe)
[64749]=17697,--Loaned Gryphon Reins
[60126]=17697,--Loaned Gryphon Reins(Recipe)
[64762]=17699,--Loaned Wind Rider Reins
[60128]=17699,--Loaned Wind Rider Reins(Recipe)
[60002]=28045,--Time-Lost Proto-Drake
[59567]=27785,--Azure Drake
[59571]=27796,--Twilight Drake
[59570]=25835,--Red Drake
[59569]=25833,--Bronze Drake
[59996]=28041,--Blue Proto-Drake
[59568]=25832,--Blue Drake
[60025]=25836,--Albino Drake
[61309]=28060,--Magnificent Flying Carpet
[60971]=28060,--Magnificent Flying Carpet(Recipe)
[61229]=27913,--Armored Snowy Gryphon
[61230]=27914,--Armored Blue Wind Rider
[59650]=25831,--Black Drake
[61451]=28082,--Flying Carpet
[60969]=28082,--Flying Carpet(Recipe)
[60118]=27818,--Black War Bear
[59785]=27247,--Black War Mammoth
[61470]=27242,--Grand Ice Mammoth
[54753]=28428,--White Polar Bear
[59788]=27245,--Black War Mammoth
[59797]=27246,--Ice Mammoth
[61469]=27239,--Grand Ice Mammoth
[59799]=27248,--Ice Mammoth
[60119]=27819,--Black War Bear
[60114]=27820,--Armored Brown Bear
[60116]=27821,--Armored Brown Bear
[59791]=27243,--Wooly Mammoth
[59793]=27244,--Wooly Mammoth
[61447]=27238,--Traveler's Tundra Mammoth
[61425]=27237,--Traveler's Tundra Mammoth
--3.0.3
[59961]=28044,--Red Proto-Drake
[61294]=28053,--Green Proto-Drake
[61465]=27241,--Grand Black War Mammoth
--3.0.8
[60021]=28042,--Plagued Proto-Drake
--3.0.9
[59976]=28040,--Black Proto-Drake
[61467]=27240,--Grand Black War Mammoth
--3.1
[64731]=29161,--Sea Turtle
[61996]=27525,--Blue Dragonhawk
[63796]=28890,--Mimiron's Head
[63844]=22471,--Argent Hippogryph
[61997]=28402,--Red Dragonhawk
[63232]=28912,--Stormwind Steed
[63636]=29258,--Ironforge Ram
[63638]=28571,--Gnomeregan Mechanostrider
[63639]=29255,--Exodar Elekk
[63637]=29256,--Darnassian Nightsaber
[63641]=29259,--Thunder Bluff Kodo
[63635]=29261,--Darkspear Raptor
[63640]=29260,--Orgrimmar Wolf
[63642]=29262,--Silvermoon Hawkstrider
[63643]=29257,--Forsaken Warhorse
[64656]=10718,--Blue Skeletal Warhorse
[64658]=207,--Black Wolf
[64657]=12241,--White Kodo
[64977]=29130,--Black Skeletal Horse
--3.1.1
[65439]=25593,--Furious Gladiator's Frost Wyrm
--3.1.2
[63963]=28954,--Rusted Proto-Drake
[65640]=29043,--Swift Gray Steed
[65638]=14333,--Swift Moonsaber
[65637]=28606,--Great Red Elekk
[65645]=28605,--White Skeletal Warhorse
[65644]=14343,--Swift Purple Raptor
[65643]=28612,--Swift Violet Ram
[65646]=14335,--Swift Burgundy Wolf
[65641]=28556,--Great Golden Kodo
[65639]=28607,--Swift Red Hawkstrider
[65642]=14375,--Turbostrider
--3.1.3
[63956]=28953,--Ironbound Proto-Drake
--3.2
[60024]=28043,--Violet Proto-Drake
[66087]=22474,--Silver Covenant Hippogryph
[66088]=29696,--Sunreaver Dragonhawk
[46199]=23647,--X-51 Nether-Rocket X-TREME
[64927]=25511,--Deadly Gladiator's Frost Wyrm
[46197]=23656,--X-51 Nether-Rocket
[64659]=29102,--Venomhide Ravasaur
[66090]=28888,--Quel'dorei Steed
[66091]=28889,--Sunreaver Hawkstrider
[66846]=29754,--Ochre Skeletal Warhorse
[66906]=28919,--Argent Charger
[67466]=28918,--Argent Warhorse
[68057]=29284,--Swift Alliance Steed
[68187]=29937,--Crusader's White Warhorse
[68188]=29938,--Crusader's Black Warhorse
[51412]=25335,--Big Battle Bear
[42777]=21974,--Swift Spectral Tiger
[65917]=29344,--Magic Rooster
[66847]=29755,--Striped Dawnsaber
[42776]=21973,--Spectral Tiger
--3.2.2
[69395]=30346,--Onyxian Drake
[68056]=29283,--Swift Horde Wolf
[68769]=30141,--Little Ivory Raptor Whistle
[68768]=30518,--Little White Stallion Bridle
--3.3
[72286]=31007,--Invincible
--3.3.2
[72808]=31156,--Bloodbathed Frostbrood Vanquisher
[71342]=30989,--Big Love Rocket
--3.3.3
[67336]=29794,--Relentless Gladiator's Frost Wyrm
[72807]=31154,--Icebound Frostbrood Vanquisher
[75596]=28063,--Frosty Flying Carpet
[75597]=28063,--Frosty Flying Carpet(Recipe)
[74856]=31803,--Blazing Hippogryph
[75973]=31992,--X-53 Touring Rocket
[73313]=25279,--Crimson Deathcharger
[75614]=31958,--Celestial Steed
--3.3.5
[74918]=31721,--Wooly White Rhino
--4.0.1
[93326]=35750,--Sandstone Drake
[93328]=35750,--Sandstone Drake(Recipe)
[88746]=35751,--Vitreous Stone Drake
[88331]=35551,--Volcanic Stone Drake
[88335]=35757,--Drake of the East Wind
[88741]=35754,--Drake of the West Wind
[88742]=35553,--Drake of the North Wind
[88744]=35755,--Drake of the South Wind
[88718]=35740,--Phosphorescent Stone Drake
[71810]=31047,--Wrathful Gladiator's Frost Wyrm
[88990]=37145,--Dark Phoenix
[92231]=37160,--Spectral Steed
[92232]=37159,--Spectral Wolf
[88741]=35754,--Drake of the West Wind
[88748]=35136,--Brown Riding Camel
[88749]=35134,--Tan Riding Camel
[88750]=35135,--Grey Riding Camel
[92155]=15672,--Ultramarine Qiraji Battle Tank
--4.0.3
[98718]=34955,--Subdued Seahorse
[75207]=34956,--Abyssal Seahorse
[93623]=37231,--Mottled Drake
[84751]=34410,--Fossilized Raptor
[87091]=35250,--Goblin Turbo-Trike
[90621]=36213,--Golden King
[93644]=37138,--Kor'kron Annihilator
[87090]=35249,--Goblin Trike
--4.1
[98204]=38261,--Amani Battle Bear
[97359]=38018,--Flameward Hippogryph
[97493]=38031,--Pureblood Fire Hawk
[96503]=37800,--Amani Dragonhawk
[96491]=14341,--Armored Razzashi Raptor
[96499]=37799,--Swift Zulian Panther
[97581]=38048,--Savage Raptor
[98727]=38260,--Winged Guardian
--4.2
[97560]=38046,--Corrupted Fire Hawk
[101282]=38756,--Vicious Gladiator's Twilight Drake
[100332]=38668,--Vicious War Steed
[100333]=38607,--Vicious War Wolf
[101542]=38783,--Flametalon of Alysrazor
--4.3
[107842]=39561,--Blazing Drake
[107845]=39563,--Life-Binder's Handmaiden
[110039]=39229,--Experiment 12-B
[107844]=39562,--Twilight Harbinger
[101821]=38755,--Ruthless Gladiator's Twilight Drake
[74856]=31803,--Blazing Hippogryph
[107516]=39546,--Spectral Gryphon
[107517]=39547,--Spectral Wind Rider
[103196]=39095,--Swift Mountain Horse
[101573]=17011,--Swift Shorestrider
[102346]=1281,--Swift Forest Strider
[102349]=16992,--Swift Springstrider
[102350]=1961,--Swift Lovebird
[102488]=37204,--White Riding Camel
[103081]=39060,--Darkmoon Dancing Bear
[107203]=39530,--Tyrael's Charger
[110051]=40029,--Heart of the Aspects
[103195]=39096,--Mountain Horse
[102514]=38972,--Corrupted Hippogryph
--4.3.2
[113120]=40568,--Feldrake
--5.0.1
[121837]=42502,--Jade Panther
[121844]=42502,--Jade Panther(Recipe)
[113199]=40590,--Jade Cloud Serpent
[120043]=42185,--Jeweled Onyx Panther
[120045]=42185,--Jeweled Onyx Panther(Recipe)
[122708]=42703,--Grand Expedition Yak
[123993]=41991,--Golden Cloud Serpent
[123992]=41989,--Azure Cloud Serpent
[127154]=41990,--Onyx Cloud Serpent
[127156]=41592,--Crimson Cloud Serpent
[127158]=43689,--Heavenly Onyx Cloud Serpent
[127161]=43692,--Heavenly Crimson Cloud Serpent
[127164]=43693,--Heavenly Golden Cloud Serpent
[127170]=46087,--Astral Cloud Serpent
[127174]=43704,--Azure Riding Crane
[127176]=43705,--Golden Riding Crane
[127177]=43706,--Regal Riding Crane
[127216]=43711,--Grey Riding Yak
[127220]=43712,--Blonde Riding Yak
[129552]=44633,--Crimson Pandaren Phoenix
[129918]=43686,--Thundering August Cloud Serpent
[129932]=44759,--Green Shado-Pan Riding Tiger
[129935]=44757,--Red Shado-Pan Riding Tiger
[129934]=43900,--Blue Shado-Pan Riding Tiger
[130086]=44807,--Brown Riding Goat
[130137]=44837,--White Riding Goat
[130138]=44836,--Black Riding Goat
[130965]=45264,--Son of Galleon
[121838]=42499,--Ruby Panther
[121841]=42499,--Ruby Panther(Recipe)
[118089]=41711,--Azure Water Strider
[121839]=42501,--Sunstone Panther
[121843]=42501,--Sunstone Panther(Recipe)
[121836]=42500,--Sapphire Panther
[121842]=42500,--Sapphire Panther(Recipe)
[118737]=41903,--Pandaren Kite
[124408]=43562,--Thundering Jade Cloud Serpent
[130985]=45271,--Pandaren Kite
[123886]=43090,--Amber Scorpion
[121820]=42498,--Obsidian Nightwing
[126507]=43637,--Depleted-Kyparium Rocket
[127138]=43637,--Depleted-Kyparium Rocket(Recipe)
[126508]=43638,--Geosynchronous World Spinner
[127139]=43638,--Geosynchronous World Spinner(Recipe)
[130092]=44808,--Red Flying Cloud
[120822]=42352,--Great Red Dragon Turtle
[127293]=43722,--Great Green Dragon Turtle
[127295]=43723,--Great Black Dragon Turtle
[127302]=43724,--Great Blue Dragon Turtle
[127308]=43725,--Great Brown Dragon Turtle
[127310]=43726,--Great Purple Dragon Turtle
[124659]=43254,--Imperial Quilen
[120395]=42250,--Green Dragon Turtle
[127286]=43717,--Black Dragon Turtle
[127287]=43718,--Blue Dragon Turtle
[127288]=43719,--Brown Dragon Turtle
[127289]=43720,--Purple Dragon Turtle
[127290]=43721,--Red Dragon Turtle
[130678]=44635,--Oddly-Shaped Horn
[130730]=45163,--Bag of Kafa Beans
[130895]=45242,--Tuft of Yak Fur
[127165]=43695,--Heavenly Jade Cloud Serpent
[127169]=43697,--Heavenly Azure Cloud Serpent
--5.0.4
[132036]=45797,--Thundering Ruby Cloud Serpent
[132118]=45520,--Emerald Pandaren Phoenix
[132119]=45522,--Violet Pandaren Phoenix
[132117]=45521,--Ashen Pandaren Phoenix
[120822]=42352,--Great Red Dragon Turtle
[127295]=43723,--Great Black Dragon Turtle
[127293]=43722,--Great Green Dragon Turtle
[127302]=43724,--Great Blue Dragon Turtle
[127308]=43725,--Great Brown Dragon Turtle
[127310]=43726,--Great Purple Dragon Turtle
[120395]=42250,--Green Dragon Turtle
[127288]=43719,--Brown Dragon Turtle
[127289]=43720,--Purple Dragon Turtle
[127290]=43721,--Red Dragon Turtle
[127286]=43717,--Black Dragon Turtle
[127287]=43718,--Blue Dragon Turtle
--5.0.5
[124550]=38757,--Cataclysmic Gladiator's Twilight Drake
--5.1
[135416]=46929,--Grand Armored Gryphon
[135418]=46930,--Grand Armored Wyvern
[136163]=47166,--Grand Gryphon
[136164]=47165,--Grand Wyvern
[133023]=42147,--Jade Pandaren Kite
[134573]=46729,--Swift Windsteed
--5.2
[136471]=47238,--Spawn of Horridon
[139442]=47981,--Thundering Cobalt Cloud Serpent
[139448]=47983,--Clutch of Ji-Kun
[140249]=48100,--Golden Primal Direhorn
[140250]=48101,--Crimson Primal Direhorn
[139407]=47976,--Malevolent Gladiator's Cloud Serpent
[134359]=46686,--Sky Golem
[95416]=46686,--Sky Golem(Recipe)
[136400]=47256,--Armored Skyscreamer
[136505]=48014,--Ghastly Charger
[138423]=47716,--Cobalt Primordial Direhorn
[138425]=47715,--Slate Primordial Direhorn
[138424]=47718,--Amber Primordial Direhorn
[138426]=47717,--Jade Primordial Direhorn
[138640]=47825,--Bone-White Primal Raptor
[138641]=47826,--Red Primal Raptor
[138642]=47828,--Black Primal Raptor
[138643]=47827,--Green Primal Raptor
[139595]=48020,--Armored Bloodwing
--5.3
[142641]=48858,--Brawler's Burly Mushan Beast
[142266]=48815,--Armored Red Dragonhawk
[142478]=48816,--Armored Blue Dragonhawk
[142878]=48714,--Enchanted Fey Dragon
[142073]=48931,--Hearthsteed
--5.4
[148620]=51359,--Prideful Gladiator's Cloud Serpent
[148428]=51484,--Ashhide Mushan Beast
[148396]=51481,--Kor'kron War Wolf
[148417]=51485,--Kor'kron Juggernaut
[148476]=51488,--Thundering Onyx Cloud Serpent
[148618]=51361,--Tyrannical Gladiator's Cloud Serpent
[148619]=51360,--Grievous Gladiator's Cloud Serpent
[148392]=51479,--Spawn of Galakras
[146615]=51037,--Vicious Warsaber
[146622]=51048,--Vicious Skeletal Warhorse
[30174]=17158,--Riding Turtle
[147595]=51323,--Stormcrow
[145133]=49295,--Shimmering Moonstone
[148626]=51484,--Ash-Covered Horn
[148773]=51591,--Golden Glider
--5.4.1
[149801]=51993,--Emerald Hippogryph
--5.4.2
[153489]=53038,--Iron Skyreaver
--5.4.7
[155741]=53774,--Armored Dread Raven
--5.4.8
[163024]=55896,--Warforged Nightmare
[163025]=55907,--Grinning Reaver
------------------------------------------
--**************************************--
--************* COMPANIONS *************--
--**************************************--
------------------------------------------
--spells only
[66520]=29605,--Jade Tiger
[40319]=21304,--Lucky
[93815]=38311,--Bubbles
[93461]=32031,--Landro's Lil' XT
[93818]=36583,--Lizzy
[75936]=28734,--Murkimus the Gladiator
[89929]=36129,--Rumbling Rockling
[89930]=36130,--Swirling Stormling
[89931]=36131,--Whirling Waveling
[148068]=51742,--Ashwing Moth
[143732]=49086,--Crafty
[148069]=51301,--Flamering Moth
[123214]=42872,--Gilnean Raven
[123212]=32790,--Shore Crawler
[148065]=51740,--Skywisp Moth
[89929]=36129,--Rumbling Rockling
[89930]=36130,--Swirling Stormling
[89931]=36131,--Whirling Waveling
--1.11.1 and earlier
[15999]=9563,--Worg Pup
[26010]=10269,--Tranquil Mechanical Yeti
[26011]=10269,--Tranquil Mechanical Yeti(Recipe)
[12529]=27718,--Smolderweb Hatchling
[25162]=15436,--Disgusting Oozeling
[19772]=901,--Lifelike Toad
[19793]=901,--Lifelike Toad(Recipe)
[15067]=6294,--Sprite Darter Hatchling
[15048]=8909,--Pet Bombling
[15628]=8909,--Pet Bombling(Recipe)
[15049]=8910,--Lil' Smoky
[15633]=8910,--Lil' Smoky(Recipe)
[12243]=7920,--Mechanical Chicken
[10704]=6295,--Tree Frog
[10703]=901,--Wood Frog
[23811]=14938,--Jubling
[23851]=14938,--Jubling(Recipe)
--[23851]=,--Unhatched Jubling Egg
[10685]=5369,--Ancona Chicken
[10697]=6290,--Crimson Whelpling
[10707]=4615,--Great Horned Owl
[10706]=6299,--Hawk Owl
[10714]=1206,--Black Kingsnake
[10716]=2957,--Brown Snake
[10717]=6303,--Crimson Snake
[10688]=2177,--Undercity Cockroach
[10709]=1072,--Brown Prairie Dog
[10695]=6288,--Dark Whelpling
[10698]=6291,--Emerald Whelpling
[10682]=6192,--Hyacinth Macaw
[17709]=10993,--Zergling
[17707]=10990,--Panda Cub
[17708]=10992,--Mini Diablo
[24696]=15369,--Murky
[10673]=5556,--Bombay Cat
[10674]=5586,--Cornish Rex Cat
[10676]=5554,--Orange Tabby Cat
[10678]=5555,--Silver Tabby Cat
[10679]=9990,--White Kitten
[10677]=5585,--Siamese Cat
[10675]=5448,--Black Tabby Cat
[10683]=5207,--Green Wing Macaw
[10684]=6190,--Senegal
[10680]=6191,--Cockatiel
[10711]=328,--Snowshoe Rabbit
[4055]=7937,--Mechanical Squirrel
[3928]=7937,--Mechanical Squirrel(Recipe)
[28740]=2176,--Whiskers the Rat
[13548]=304,--Westfall Chicken
[26533]=15660,--Father Winter's Helper
[26541]=15663,--Winter's Little Helper
[26529]=15904,--Winter Reindeer
[28871]=16587,--Spirit of Summer
--[27662]=,--Silver Shafted Arrow
[27570]=15992,--Peddlefeet
[28738]=16259,--Speedy
[28739]=16257,--Mr. Wiggles
[26045]=13610,--Tiny Snowman
--1.12.1
[23429]=14657,--Loggerhead Snapjaw
[23530]=14779,--Tiny Red Dragon
[23531]=14778,--Tiny Green Dragon
--2.0
[30156]=16943,--Hippogryph Hatchling
--2.0.1
[39181]=20996,--Miniwing
[35156]=19600,--Mana Wyrmling
[35239]=4626,--Brown Rabbit
[35909]=19986,--Red Moth
[36031]=20029,--Blue Dragonhawk Hatchling
[33050]=18269,--Magical Crawdad
[33062]=18269,--Magical Crawdad(Recipe)
[35907]=19987,--Blue Moth
[35910]=19985,--Yellow Moth
[35911]=19999,--White Moth
[36027]=20026,--Golden Dragonhawk Hatchling
[36028]=20027,--Red Dragonhawk Hatchling
[36029]=20037,--Silver Dragonhawk Hatchling
[40549]=21362,--Bananas
--2.0.3
[30152]=37949,--White Tiger Cub
--2.1
[27241]=15984,--Gurky
[32298]=17723,--Netherwhelp
[42426]=17723,--Netherwhelp(Recipe)
[40614]=21382,--Egbert
[40613]=21381,--Willy
[40634]=21393,--Peanut
[36034]=20042,--Firefly
[24988]=15398,--Lurky
--2.2.2
[39709]=22349,--Wolpertinger
[42609]=21900,--Sinister Squashling
--2.3
[45082]=22855,--Tiny Sporebat
[10696]=6293,--Azure Whelpling
[43918]=22459,--Mojo
[43923]=22459,--Mojo(Recipe)
[45127]=22966,--Dragon Kite
[54187]=22776,--Clockwork Rocket Bot
[45125]=22903,--Rocket Chicken
--2.4
[46599]=23574,--Phoenix Hatchling
[43697]=22388,--Toothy
[43698]=22389,--Muckbreath
[46425]=23507,--Snarly
[46426]=23506,--Chuck
--2.4.2
[51716]=25457,--Nether Ray Fry
[45890]=8409,--Searing Scorchling
[49964]=25002,--Ethereal Soul-Trader
[53082]=25900,--Mini Tyrael
[53085]=25900,--Mini Tyrael(Recipe)
[40405]=21328,--Lucky
[40406]=21328,--Lucky(Recipe)
--2.4.3
[48406]=24393,--Spirit of Competition
--[49352]=25332,--Crashin' Thrashin' Racer
--3.0.1
[25849]=15595,--Baby Shark
[40990]=16633,--Stinker
--3.0.2
[51851]=4185,--Vampiric Batling
[53316]=28089,--Ghostly Skull
[59250]=27627,--Giant Sewer Rat
[61357]=28216,--Pengu
[61348]=45919,--Tickbird Hatchling
[61349]=28215,--White Tickbird Hatchling
[61350]=28217,--Proto-Drake Whelp
[60832]=26524,--Grindgear Toy Gorilla
[60838]=27829,--Trusty Copper Racer
--3.0.3
[52615]=28456,--Frosty
[62456]=28456,--Frosty(Recipe)
[61472]=45937,--Kirin Tor Familiar
[61457]=45937,--Kirin Tor Familiar(Recipe)
[61351]=28084,--Cobra Hatchling
[61855]=16189,--Baby Blizzard Bear
--3.0.8
[61991]=28397,--Little Fawn
--3.1
[10713]=2955,--Albino Snake
[64351]=29060,--XS-001 Constructor Bot
[64347]=29060,--XS-001 Constructor Bot(Recipe)
[61725]=6302,--Spring Rabbit
[62491]=28482,--Teldrassil Sproutling
[62508]=28489,--Dun Morogh Cub
[62510]=4732,--Tirisfal Batling
[62513]=15470,--Durotar Scorpion
[62516]=16205,--Elwynn Lamb
[62542]=28502,--Mulgore Hatchling
[62561]=45880,--Strand Crawler
[62562]=28493,--Ammen Vale Lashling
[62609]=28946,--Argent Squire
[62674]=28539,--Mechanopeep
[62746]=28948,--Argent Gruntling
[62949]=28599,--Wind-Up Train Wrecker
[63712]=46939,--Sen'jin Fetish
[62564]=45960,--Enchanted Broom
[61022]=27829,--Heavy Copper Racer
[61021]=27829,--Zippy Copper Racer
[62857]=28811,--Sandbox Tiger
--3.1.2
[63318]=28734,--Murkimus the Gladiator
--3.1.3
[65682]=29279,--Warbot
--3.2
[67413]=29805,--Darting Hatchling
[67415]=29803,--Gundrak Hatchling
[67416]=29802,--Leaping Hatchling
[67417]=29809,--Obsidian Hatchling
[67418]=29810,--Ravasaur Hatchling
[67419]=29808,--Razormaw Hatchling
[67420]=29806,--Razzashi Hatchling
[67414]=29807,--Deviate Hatchling
[44369]=22629,--Pint-Sized Pink Pachyderm
[66030]=29348,--Grunty
[65382]=25384,--Curious Wolvar Pup
[65381]=25173,--Curious Oracle Hatchling
[66096]=29372,--Shimmering Wyrmling
[66096]=29372,--Shimmering Wyrmling
[65353]=25384,--Wolvar Orphan Whistle
[65360]=25384,--Wolvar Orphan Whistle(Recipe)
[65352]=25173,--Oracle Orphan Whistle
[65359]=25173,--Oracle Orphan Whistle(Recipe)
--3.2.2
[69002]=30356,--Onyxian Whelpling
[55068]=26452,--Mr. Chilly
[61773]=45968,--Plump Turkey
[69541]=30414,--Pandaren Monk
[69677]=30507,--Lil' K.T.
[66175]=29404,--Macabre Marionette
[68767]=30157,--Tuskarr Kite
[68810]=30409,--Spectral Tiger Cub
--3.3
[65358]=11709,--Calico Cat
[69452]=30462,--Core Hound Pup
[70613]=31174,--Perky Pug
[45174]=21304,--Golden Pig
[45175]=22938,--Silver Pig
[48408]=24620,--Essence of Competition
[28505]=16189,--Poley
[62857]=28811,--Sandbox Tiger
--3.3.2
[69535]=30412,--Gryphon Hatchling
[69536]=30413,--Wind Rider Cub
[71840]=31073,--Toxic Wasteling
--3.3.3
[74932]=31722,--Frigid Frostling
[75906]=32031,--Lil' XT
[75134]=22778,--Blue Clockwork Rocket Bot
--[75111]=25332,--Blue Crashin' Thrashin' Racer 
--3.3.5
[78381]=32670,--Mini Thor
--4.0.1
[89039]=37136,--Dark Phoenix Hatchling
[90637]=33217,--Fox Kit
[89670]=36220,--Armadillo Pup
[89472]=36499,--Rustberg Seagull
[89472]=36499,--Rustberg Seagull
[93624]=32031,--Landro's Lil' XT
[94070]=36896,--Deathy
[93739]=9905,--Mr. Grubbs
[92396]=37199,--Guild Page
[92397]=37198,--Guild Herald
[92398]=37196,--Guild Herald
[78683]=32699,--Blue Mini Jouster
[78685]=32707,--Gold Mini Jouster
[92395]=37200,--Guild Page
--4.0.3
[84752]=34413,--Fossilized Hatchling
[63318]=28734,--Murkimus the Gladiator
[69539]=30402,--Zipao Tiger
[87344]=35338,--Lil' Deathwing
[87863]=15393,--Eat the Egg
[67527]=29819,--Onyx Panther
[95787]=37541,--Lil' Ragnaros
[95786]=37526,--Moonkin Hatchling
[95909]=37527,--Moonkin Hatchling
[84263]=34262,--Crawling Claw
[93813]=28435,--Tiny Flamefly
[81937]=33512,--Personal World Destroyer
[84412]=33512,--Personal World Destroyer(Recipe)
[82173]=33559,--De-Weaponized Mechanical Companion
[84413]=33559,--De-Weaponized Mechanical Companion(Recipe)
[90523]=36211,--Clockwork Gnome
[93836]=36902,--Enchanted Lantern
[93841]=36902,--Enchanted Lantern(Recipe)
[93837]=36901,--Magic Lamp
[93843]=36901,--Magic Lamp(Recipe)
[93838]=45878,--Elementium Geode
[65046]=45943,--Withers
[84492]=45940,--Pebble
[91343]=36637,--Tiny Shale Spider
[93823]=37154,--Singing Sunflower
[93817]=38135,--Scooter the Snail
[75613]=31956,--Celestial Dragon
[65451]=17192,--MiniZep Controller
--4.0.6
[16450]=27718,--Smolderweb Hatchling
--4.1
[45082]=22855,--Tiny Sporebat
[98587]=38232,--Voodoo Figurine
[98571]=38229,--Pterrordax Hatchling
[96817]=30507,--Landro's Lichling
[96819]=37846,--Nightsaber Cub
[98079]=38134,--Legs
[98736]=38359,--Guardian Cub
[99578]=16943,--Cenarion Hatchling
[96571]=37814,--Panther Cub
[97638]=37712,--Winterspring Cub
[66096]=29372,--Shimmering Wyrmling
[97779]=38065,--Lashtail Hatchling
--4.2
[100576]=38614,--Lil' Tarecgosa
[98736]=38359,--Guardian Cub
[100330]=38539,--Feline Familiar
[100684]=38638,--Creepy Crate
[101606]=38803,--Murkablo
[99663]=38455,--Hyjal Bear Cub
[101989]=38342,--Horde Balloon
[100959]=38691,--Brewfest Keg Pony
[100970]=38693,--Nuts
[101424]=38776,--Brilliant Kaliri
[101986]=38343,--Alliance Balloon
[99668]=38429,--Crimson Lasher
--4.3
[103588]=39109,--Sea Pony
[101493]=38777,--Purple Puffer
[102353]=39694,--Sand Scarab
[103076]=38344,--Darkmoon Balloon
[101733]=46001,--Darkmoon Monkey
[103074]=38809,--Darkmoon Turtle
[103125]=45939,--Lumpy
[103544]=15381,--Darkmoon Tonk
[103549]=17192,--Darkmoon Zeppelin
[102317]=38919,--Gregarious Grell
[105122]=39137,--Darkmoon Cub
[105633]=39380,--Fetish Shaman
[110029]=40019,--Soul of the Aspects
[140218]=38344,--Flimsy Darkmoon Balloon
[105228]=38340,--Flimsy Green Balloon
[105229]=38341,--Flimsy Yellow Balloon
[104047]=39163,--Lunar Lantern
[104049]=39333,--Festival Lantern
[107926]=39319,--Darkmoon "Tiger"
--4.3.2
[112994]=40538,--Eye of the Legion
--5.0.1
[127813]=43865,--Thundering Serpent Hatchling
[126885]=45386,--Mechanical Pandaren Dragonling
[127135]=45386,--Mechanical Pandaren Dragonling(Recipe)
[114090]=45957,--Darkmoon Rabbit
[123778]=44655,--Terrible Turnip
[123784]=46385,--Red Cricket
[124000]=47955,--Tiny Goldfish
[124152]=45894,--Feral Vermling
[124660]=43255,--Lucky Quilen Cub
[118414]=41833,--Porcupette
[130726]=45987,--Jade Tentacle
[130759]=45195,--Venus
[127006]=44792,--Food
[127008]=44791,--Food
[127816]=43868,--Jade Crane Chick
[120501]=15905,--Jade Owl
[131897]=15905,--Jade Owl(Recipe)
[120507]=42297,--Sapphire Cub
[131898]=42297,--Sapphire Cub(Recipe)
[126247]=43597,--Hopling
[126249]=45854,--Aqua Strider
[126251]=45938,--Grinder
[127815]=43127,--Singing Cricket
[122748]=42721,--Fishy
[127006]=44792,--Yu'lon Kite
[127007]=44792,--Yu'lon Kite(Recipe)
[127008]=44791,--Chi-Ji Kite
[127009]=44791,--Chi-Ji Kite(Recipe)
--5.0.3
[110955]=16587,--Fire Spirit
[130649]=45072,--Life Spirit
[130650]=45073,--Water Spirit
--5.0.4
[90637]=33217,--Fox Kit
[90637]=33217,--Fox Kit
[131590]=45942,--Pandaren Water Spirit
[131650]=45527,--Baneling
[132759]=30409,--Spectral Cub
[132759]=30409,--Spectral Cub
[68810]=30409,--Spectral Tiger Cub
--5.1
[132574]=44551,--Imperial Moth
[132789]=46174,--Darkmoon Eye
[134538]=46720,--Cinder Kitten
[134892]=46809,--Pandaren Fire Spirit
[134894]=46810,--Pandaren Air Spirit
[134895]=46811,--Pandaren Earth Spirit
[135256]=46897,--Mr. Bigglesworth
[132580]=40521,--Imperial Silkworm
[132579]=40521,--Imperial Silkworm(Recipe)
[132785]=46171,--Darkmoon Glowfly
[132762]=46163,--Darkmoon Hatchling
[135257]=46921,--Stitched Pup
[135156]=46882,--Clock'em
[135255]=46896,--Fungal Abomination
[135258]=46900,--Harbinger of Flame
[135259]=46923,--Corefire Imp
[135261]=46902,--Ashstone Core
[135263]=46903,--Untamed Hatchling
[135265]=46905,--Death Talon Whelpguard
[135264]=46925,--Chrominius
[135266]=46924,--Viscidus Globule
[135267]=46922,--Anubisath Idol
[135268]=46909,--Mini Mindslayer
[135254]=46898,--Giant Bone Spider
[135009]=39331,--Darkmoon "Cougar"
[135025]=46695,--Darkmoon "Murloc"
[135026]=46696,--Darkmoon "Rocket"
[135007]=39330,--Darkmoon "Snow Leopard"
[135027]=46697,--Darkmoon "Wyvern"
[135022]=46693,--Darkmoon "Dragon"
[135008]=39332,--Darkmoon "Nightsaber"
[135023]=46694,--Darkmoon "Gryphon"
--5.2
[139932]=48055,--Zandalari Anklerender
[136484]=47348,--Gusting Grimoire
[138082]=47848,--Sunreaver Micro-Sentry
[137977]=47252,--Living Sandling
[138087]=47731,--Zandalari Kneebiter
[138161]=47708,--Son of Animus
[138285]=47732,--Spectral Porcupette
[138380]=47747,--Sunfur Panda
[138381]=47749,--Snowy Panda
[138382]=47748,--Mountain Panda
[138913]=48091,--Spawn of G'nathus
[139148]=48001,--Ji-Kun Hatchling
[137568]=47634,--Red Panda
[139933]=48056,--Zandalari Footslasher
[139934]=48057,--Zandalari Toenibbler
[65682]=29279,--Warbot
[138287]=48211,--Stunted Direhorn
[139153]=48213,--Direhorn Runt
[138825]=48212,--Pygmy Direhorn
[138824]=47711,--Pierre
[139196]=47711,--Pierre(Recipe)
[139361]=47959,--Tiny Red Carp
[139362]=47957,--Tiny Blue Carp
[139363]=47958,--Tiny Green Carp
[139365]=47960,--Tiny White Carp
--5.3
[142880]=48934,--Blossoming Ancient
[143637]=49081,--Murkimus Tyrannicus
[141789]=48651,--Gahz'rooki
[141433]=48878,--Lil' Bad Wolf
[141434]=48857,--Menagerie Custodian
[141435]=48856,--Netherspace Abyssal
[141451]=48662,--Fiendish Imp
[141436]=48855,--Tideskipper
[142030]=48708,--Filthling
[141446]=48661,--Coilfang Stalker
[141447]=48664,--Pocket Reaver
[141448]=48668,--Lesser Voidcaller
[141449]=48663,--Phoenix Hawk Hatchling
[141450]=48667,--Tito
[142028]=48704,--Living Fluid
[142029]=48705,--Viscous Horror
[141437]=48666,--Tainted Waveling
--5.4
[144761]=855,--Moon Moon
[148567]=51505,--Rotten Little Helper
[143703]=49084,--Rascal-Bot
[143714]=49084,--Rascal-Bot(Recipe)
[145696]=49846,--Xu-Fu, Cub of Xuen
[145697]=49835,--Chi-Chi, Hatchling of Chi-Ji
[145699]=49845,--Zao, Calfling of Niuzao
[145698]=49836,--Yu'la, Broodling of Yu'lon
[148427]=47858,--Vengeful Porcupette
[147124]=49289,--Lil' Bling
[148046]=40908,--Ashleaft Spriteling
[148047]=51413,--Azure Crane Chick
[148049]=51268,--Blackfuse Bombling
[148050]=51271,--Ruby Droplet
[148051]=51408,--Dandelion Frolicker
[148058]=51417,--Droplet of Y'Shaarj
[148059]=51267,--Gooey Sha-ling
[148060]=51270,--Jademist Dancer
[148061]=51269,--Kovok
[148062]=51272,--Ominous Flame
[148063]=51279,--Skunky Alemental
[148066]=51278,--Spineclaw Crab
[148067]=47991,--Gulp Froglet
[148373]=51475,--Bonkers
[148527]=51502,--Gu'chi Swarmling
[148530]=47856,--Harmonious Porcupette
[148552]=51504,--Jadefire Spirit
[148684]=51530,--Sky Lantern
[148684]=51530,--Flimsy Sky Lantern
[148052]=51277,--Death Adder Hatchling
--5.4.1
[149787]=51988,--Alterac Brew-Pup
[149792]=51990,--Murkalot
--5.4.2
[149810]=51994,--Treasure Goblin
[154165]=37526,--Moonkin Hatchling
--[148577]=51507,--Crashin' Thrashin' Flyer
--5.4.7
[155748]=53719,--Dread Hatchling
}

--Battle pet data table--
ModelPique_BattlePetId_Table = {
--1.11.1 and earlier
[39]=7937,--Mechanical Squirrel
[40]=5556,--Bombay Cat
[41]=5586,--Cornish Rex Cat
[42]=5448,--Black Tabby Cat
[43]=5554,--Orange Tabby Cat
[44]=5585,--Siamese Cat
[45]=5555,--Silver Tabby Cat
[46]=9990,--White Kitten
[47]=6191,--Cockatiel
[49]=6192,--Hyacinth Macaw
[50]=5207,--Green Wing Macaw
[51]=6190,--Senegal
[52]=5369,--Ancona Chicken
[55]=2177,--Undercity Cockroach
[56]=6288,--Dark Whelpling
[58]=6290,--Crimson Whelpling
[59]=6291,--Emerald Whelpling
[64]=901,--Wood Frog
[65]=6295,--Tree Frog
[67]=6299,--Hawk Owl
[68]=4615,--Great Horned Owl
[70]=1072,--Brown Prairie Dog
[72]=328,--Snowshoe Rabbit
[75]=1206,--Black Kingsnake
[77]=2957,--Brown Snake
[78]=6303,--Crimson Snake
[83]=7920,--Mechanical Chicken
[85]=8909,--Pet Bombling
[86]=8910,--Lil' Smoky
[87]=6294,--Sprite Darter Hatchling
[89]=9563,--Worg Pup
[90]=27718,--Smolderweb Hatchling
[92]=10990,--Panda Cub
[93]=10992,--Mini Diablo
[94]=10993,--Zergling
[95]=901,--Lifelike Toad
[106]=14938,--Jubling
[107]=15369,--Murky
[114]=15436,--Disgusting Oozeling
[116]=10269,--Tranquil Mechanical Yeti
[117]=13610,--Tiny Snowman
[118]=15904,--Winter Reindeer
[119]=15660,--Father Winter's Helper
[120]=15663,--Winter's Little Helper
[121]=15984,--Gurky
[122]=15992,--Peddlefeet
[125]=16259,--Speedy
[126]=16257,--Mr. Wiggles
[127]=2176,--Whiskers the Rat
[128]=16587,--Spirit of Summer
--1.12.1
[57]=6293,--Azure Whelpling
[69]=6298,--Snowy Owl
[74]=2955,--Albino Snake
[111]=15398,--Lurky
[757]=14778,--Tiny Green Dragon
[758]=14779,--Tiny Red Dragon
[1168]=15395,--Murki
[1352]=22938,--Chubbs
--2.0
[130]=16943,--Hippogryph Hatchling
--2.0.1
[132]=18269,--Magical Crawdad
[136]=19600,--Mana Wyrmling
[137]=4626,--Brown Rabbit
[138]=19987,--Blue Moth
[139]=19986,--Red Moth
[140]=19985,--Yellow Moth
[141]=19999,--White Moth
[142]=20026,--Golden Dragonhawk Hatchling
[143]=20027,--Red Dragonhawk Hatchling
[144]=20037,--Silver Dragonhawk Hatchling
[149]=20996,--Miniwing
[156]=21362,--Bananas
--2.1
[131]=17723,--Netherwhelp
[146]=20042,--Firefly
[155]=21328,--Lucky
[157]=21381,--Willy
[158]=21382,--Egbert
[159]=21393,--Peanut
--2.2
[145]=20029,--Blue Dragonhawk Hatchling
--2.2.2
[153]=22349,--Wolpertinger
--2.3
[162]=21900,--Sinister Squashling
[163]=22388,--Toothy
[164]=22389,--Muckbreath
[165]=22459,--Mojo
[167]=22855,--Tiny Sporebat
[168]=22903,--Rocket Chicken
[169]=22966,--Dragon Kite
[191]=22776,--Clockwork Rocket Bot
--2.4
[124]=16189,--Poley
[160]=16633,--Stinker
[166]=22629,--Pint-Sized Pink Pachyderm
[170]=21304,--Golden Pig
[171]=22938,--Silver Pig
[172]=8409,--Searing Scorchling
[173]=23507,--Snarly
[174]=23506,--Chuck
[175]=23574,--Phoenix Hatchling
[1073]=15398,--Terky
--2.4.2
[183]=25002,--Ethereal Soul-Trader
[186]=25457,--Nether Ray Fry
[189]=25900,--Mini Tyrael
--2.4.3
[179]=24393,--Spirit of Competition
[180]=24620,--Essence of Competition
--3.0.1
[115]=15595,--Baby Shark
--3.0.2
[84]=304,--Westfall Chicken
[187]=4185,--Vampiric Batling
[190]=28089,--Ghostly Skull
[193]=27627,--Giant Sewer Rat
[194]=45919,--Tickbird Hatchling
[195]=28215,--White Tickbird Hatchling
[196]=28217,--Proto-Drake Whelp
[197]=28084,--Cobra Hatchling
[198]=28216,--Pengu
--3.0.3
[188]=28456,--Frosty
[199]=45937,--Kirin Tor Familiar
[202]=16189,--Baby Blizzard Bear
--3.0.8
[203]=28397,--Little Fawn
--3.1
[211]=45880,--Strand Crawler
[214]=28946,--Argent Squire
[216]=28948,--Argent Gruntling
--3.1.1
[209]=16205,--Elwynn Lamb
[212]=28493,--Ammen Vale Lashling
[213]=45960,--Enchanted Broom
[218]=46939,--Sen'jin Fetish
--3.1.3
[227]=29279,--Warbot
--3.2
[229]=29372,--Shimmering Wyrmling
[234]=29803,--Gundrak Hatchling
[235]=29802,--Leaping Hatchling
[236]=29809,--Obsidian Hatchling
--3.2.2
[201]=45968,--Plump Turkey
[1351]=29404,--Macabre Marionette
--3.3
[228]=29348,--Grunty
[248]=30414,--Pandaren Monk
[250]=31174,--Perky Pug
--3.3.2
[246]=30413,--Wind Rider Cub
--3.3.3
[200]=6302,--Spring Rabbit
[204]=28482,--Teldrassil Sproutling
[205]=28489,--Dun Morogh Cub
[215]=28539,--Mechanopeep
[224]=11709,--Calico Cat
[226]=25384,--Curious Wolvar Pup
[237]=29810,--Ravasaur Hatchling
[238]=29808,--Razormaw Hatchling
[242]=30409,--Spectral Tiger Cub
[245]=30412,--Gryphon Hatchling
[249]=30507,--Lil' K.T.
[253]=31722,--Frigid Frostling
[254]=22778,--Blue Clockwork Rocket Bot
--3.3.5
[192]=26452,--Mr. Chilly
[206]=4732,--Tirisfal Batling
[207]=15470,--Durotar Scorpion
[210]=28502,--Mulgore Hatchling
[217]=28734,--Murkimus the Gladiator
[225]=25173,--Curious Oracle Hatchling
[232]=29805,--Darting Hatchling
[233]=29807,--Deviate Hatchling
[239]=29806,--Razzashi Hatchling
[243]=30356,--Onyxian Whelpling
[256]=32031,--Lil' XT
--4.0.1
[220]=45943,--Withers
[266]=34413,--Fossilized Hatchling
[277]=36211,--Clockwork Gnome
[291]=37154,--Singing Sunflower
--4.0.3
[259]=32699,--Blue Mini Jouster
[262]=33559,--De-Weaponized Mechanical Companion
[265]=45940,--Pebble
[267]=36902,--Enchanted Lantern
[279]=36637,--Tiny Shale Spider
[285]=32031,--Landro's Lil' XT
[287]=28435,--Tiny Flamefly
[293]=45878,--Elementium Geode
[296]=37526,--Moonkin Hatchling
[297]=37541,--Lil' Ragnaros
--4.1
[302]=30507,--Landro's Lichling
[307]=38065,--Lashtail Hatchling
--4.2
[323]=38693,--Nuts
[331]=38343,--Alliance Balloon
--4.2.2
[311]=38359,--Guardian Cub
--4.3
[330]=46001,--Darkmoon Monkey
[335]=38809,--Darkmoon Turtle
[336]=38344,--Darkmoon Balloon
[337]=45939,--Lumpy
[338]=15381,--Darkmoon Tonk
[339]=17192,--Darkmoon Zeppelin
[343]=39137,--Darkmoon Cub
--5.0.1
[231]=29605,--Jade Tiger
[374]=42906,--Black Lamb
[378]=328,--Rabbit
[379]=134,--Squirrel
[381]=41833,--Porcupette
[383]=43798,--Eternal Strider
[385]=4959,--Mouse
[386]=1072,--Prairie Dog
[387]=1206,--Snake
[388]=45880,--Shore Crab
[389]=41886,--Tiny Harvester
[390]=45889,--Deer
[391]=328,--Mountain Cottontail
[392]=1141,--Redridge Rat
[393]=2177,--Cockroach
[394]=856,--Sheep
[395]=41887,--Fledgling Buzzard
[396]=2536,--Dusk Spiderling
[397]=16633,--Skunk
[398]=1141,--Black Rat
[399]=3126,--Rat Snake
[400]=45905,--Widow Spiderling
[401]=32789,--Strand Crab
[402]=36944,--Swamp Moth
[403]=6189,--Parrot
[404]=4959,--Long-tailed Mole
[405]=36578,--Tree Python
[406]=7511,--Beetle
[407]=45902,--Forest Spiderling
[408]=36583,--Lizard Hatchling
[409]=42509,--Polly
[410]=1141,--Wharf Rat
[411]=21362,--Baby Ape
[412]=45902,--Spider
[414]=15469,--Scorpid
[415]=8971,--Fire Beetle
[416]=41960,--Scorpling
[417]=1141,--Rat
[418]=1986,--Water Snake
[419]=6297,--Small Frog
[420]=901,--Toad
[421]=36671,--Crimson Moth
[422]=1986,--Moccasin
[423]=28507,--Lava Crab
[424]=2177,--Roach
[425]=4268,--Ash Viper
[427]=45904,--Ash Spiderling
[428]=42051,--Molten Hatchling
[429]=41981,--Lava Beetle
[430]=15467,--Gold Beetle
[431]=35804,--Rattlesnake
[432]=15469,--Stripe-Tailed Scorpid
[433]=36585,--Spiky Lizard
[434]=10000,--Ram
[437]=42068,--Little Black Ram
[438]=2954,--King Snake
[439]=45917,--Restless Shadeling
[440]=42203,--Snow Cub
[441]=36342,--Alpine Hare
[442]=2177,--Irradiated Roach
[443]=328,--Grasslands Cottontail
[445]=45936,--Tiny Twister
[446]=42218,--Jade Oozeling
[447]=654,--Fawn
[448]=1560,--Hare
[449]=45899,--Brown Marmot
[450]=9904,--Maggot
[452]=36620,--Red-Tailed Chipmunk
[453]=42229,--Infested Bear Cub
[454]=1141,--Undercity Rat
[455]=42334,--Blighted Squirrel
[456]=42265,--Blighthawk
[457]=9904,--Festering Maggot
[458]=45952,--Lost of Lordaeron
[459]=5585,--Cat
[460]=42335,--Ruby Sapling
[461]=9906,--Larva
[463]=42342,--Spirit Crab
[464]=42343,--Grey Moth
[465]=42344,--Ravager Hatchling
[466]=36583,--Spiny Lizard
[467]=7511,--Dung Beetle
[468]=46940,--Creepy Crawly
[469]=36644,--Twilight Beetle
[470]=36236,--Twilight Spider
[471]=7920,--Robo-Chick
[472]=26532,--Rabid Nut Varmint 5000
[473]=27881,--Turquoise Turtle
[474]=42362,--Cheetah Cub
[475]=45896,--Giraffe Calf
[476]=1547,--Gazelle
[477]=45958,--Gazelle Fawn
[478]=36944,--Forest Moth
[479]=328,--Elfin Rabbit
[480]=36648,--Topaz Shale Hatchling
[482]=4268,--Rock Viper
[483]=36583,--Horny Toad
[484]=45906,--Desert Spider
[485]=42381,--Stone Armadillo
[486]=45890,--Mule Deer
[487]=36620,--Alpine Chipmunk
[488]=36580,--Coral Snake
[489]=42745,--Spawn of Onyxia
[491]=5586,--Sand Kitten
[492]=7511,--Stinkbug
[493]=42407,--Shimmershell Snail
[494]=42416,--Silithid Hatchling
[495]=6297,--Frog
[496]=42409,--Rusty Snail
[497]=2177,--Tainted Cockroach
[498]=36944,--Tainted Moth
[499]=1141,--Tainted Rat
[500]=46003,--Minfernal
[502]=6297,--Spotted Bell Frog
[503]=36944,--Silky Moth
[504]=45913,--Diemetradon Hatchling
[505]=42415,--Twilight Iguana
[506]=45908,--Venomspitter Hatchling
[507]=6300,--Crested Owl
[508]=42412,--Darkshore Cub
[509]=42202,--Tiny Bog Beast
[511]=35804,--Sidewinder
[512]=35113,--Scarab Hatchling
[513]=42523,--Qiraji Guardling
[514]=42553,--Flayer Youngling
[515]=42554,--Sporeling Sprout
[517]=45998,--Warpstalker Hatchling
[518]=42575,--Clefthoof Runt
[519]=45923,--Fel Flame
[521]=45988,--Fledgling Nether Ray
[523]=45885,--Devouring Maggot
[525]=45968,--Turkey
[528]=45953,--Scalded Basilisk Hatchling
[529]=42617,--Fjord Worg Pup
[530]=42781,--Oily Slimeling
[535]=30159,--Water Waveling
[536]=25390,--Tundra Penguin
[539]=4959,--Grotto Vole
[540]=1141,--Carrion Rat
[541]=2177,--Fire-Proof Roach
[542]=6297,--Mac Frog
[543]=2177,--Locust
[544]=36944,--Oasis Moth
[545]=15469,--Leopard Scorpid
[546]=42771,--Tol'vir Scarab
[547]=45820,--Nordrassil Wisp
[548]=30412,--Wildhammer Gryphon Hatchling
[549]=45900,--Yellow-Bellied Marmot
[550]=4959,--Highlands Mouse
[553]=1141,--Stowaway Rat
[554]=36605,--Crimson Shale Hatchling
[555]=45897,--Deepholm Cockroach
[556]=15467,--Crystal Beetle
[557]=42467,--Nether Faerie Dragon
[558]=42757,--Arctic Fox Kit
[559]=45879,--Crimson Geode
[560]=45995,--Sea Gull
[562]=36544,--Coral Adder
[564]=27883,--Emerald Turtle
[565]=6297,--Jungle Darter
[566]=45852,--Mirror Strider
[567]=2955,--Temple Snake
[568]=38380,--Silkbead Snail
[569]=38831,--Garden Frog
[570]=40093,--Masked Tanuki
[571]=35802,--Grove Viper
[572]=45880,--Spirebound Crab
[573]=45994,--Sandy Petrel
[626]=4732,--Bat
[627]=10090,--Infected Squirrel
[628]=37686,--Infected Fawn
[629]=32790,--Shore Crawler
[630]=42872,--Gilnean Raven
[631]=36578,--Emerald Boa
[632]=36583,--Ash Lizard
[633]=16633,--Mountain Skunk
[634]=45909,--Crystal Spider
[635]=1986,--Adder
[637]=20923,--Skittering Cavern Crawler
[638]=2177,--Nether Roach
[639]=1072,--Borean Marmot
[640]=328,--Snowshoe Hare
[641]=328,--Arctic Hare
[644]=22175,--Fjord Rat
[645]=45970,--Highlands Turkey
[646]=304,--Chicken
[647]=134,--Grizzly Squirrel
[648]=5379,--Huge Toad
[649]=1924,--Biletoad
[650]=44655,--Terrible Turnip
[652]=47955,--Tiny Goldfish
[671]=43255,--Lucky Quilen Cub
[675]=1141,--Stormwind Rat
[678]=40226,--Jungle Grub
[680]=43347,--Kuitan Mongoose
[699]=45911,--Jumping Spider
[702]=6296,--Leopard Tree Frog
[703]=43194,--Masked Tanuki Pup
[706]=40089,--Bandicoon
[707]=41834,--Bandicoon Kit
[708]=45991,--Malayan Quillrat
[709]=45990,--Malayan Quillrat Pup
[710]=43360,--Marsh Fiddler
[711]=42856,--Sifang Otter
[712]=42983,--Sifang Otter Pup
[713]=27679,--Softshell Snapling
[714]=44816,--Feverbite Hatchling
[716]=45910,--Amethyst Spiderling
[717]=45996,--Savory Beetle
[718]=36955,--Luyu Moth
[722]=28434,--Mei Li Sparkler
[723]=42859,--Spiny Terrapin
[724]=36388,--Alpine Foxling
[725]=42757,--Alpine Foxling Kit
[726]=45999,--Plains Monitor
[727]=4959,--Prairie Mouse
[728]=304,--Szechuan Chicken
[729]=6302,--Tolai Hare
[730]=28998,--Tolai Hare Pup
[731]=4440,--Zooey Snake
[732]=36956,--Amber Moth
[733]=43344,--Grassland Hopper
[737]=43347,--Mongoose
[739]=43346,--Mongoose Pup
[740]=4959,--Yakrat
[741]=45984,--Silent Hedgehog
[742]=45985,--Clouded Hedgehog
[743]=45882,--Rapana Whelk
[744]=45898,--Resilient Roach
[745]=15469,--Crunchy Scorpion
[746]=45881,--Emperor Crab
[747]=46000,--Effervescent Glowfly
[748]=36956,--Gilded Moth
[749]=43428,--Golden Civet
[750]=43259,--Golden Civet Kitten
[751]=40584,--Dancing Water Skimmer
[752]=6297,--Yellow-Bellied Bullfrog
[755]=2177,--Death's Head Cockroach
[756]=36944,--Fungal Moth
[802]=43865,--Thundering Serpent Hatchling
[817]=43875,--Wild Jade Hatchling
[818]=45064,--Wild Golden Hatchling
[821]=45894,--Feral Vermling
[823]=22447,--Highlands Skunk
[834]=45938,--Grinder
[836]=45854,--Aqua Strider
[837]=36603,--Emerald Shale Hatchling
[838]=36604,--Amethyst Shale Hatchling
[847]=42721,--Fishy
[848]=45957,--Darkmoon Rabbit
[851]=36583,--Horned Lizard
[872]=2954,--Slither
[873]=2958,--Fangs
[874]=1418,--Teensy
[875]=26184,--Clucks
[876]=45555,--Foe Reaper 800
[877]=36342,--Flipsy
[880]=45558,--Darkwidow
[881]=43193,--Blackfang
[882]=40338,--Webwinder
[885]=29963,--Nanners
[886]=45561,--Young Beaky
[887]=45560,--Eyegouger
--5.0.3
[844]=45386,--Mechanical Pandaren Dragonling
[845]=15905,--Jade Owl
[849]=44791,--Chi-Ji Kite
[856]=45987,--Jade Tentacle
[889]=45564,--Mumtar
[890]=45563,--Spike
[891]=45567,--Ripper
[892]=45565,--Springtail
[893]=45895,--Longneck
[894]=45569,--Flutterby
[895]=36313,--Oozer
[896]=45568,--Mister Pinch
[897]=45570,--Acidous
[898]=42670,--Odoron
[899]=1986,--Constrictor
[900]=45572,--Rockhide
[901]=45573,--Ambershell
[902]=43221,--Bounder
[904]=45576,--Prancer
[905]=45574,--Rasp
[906]=45577,--Glimmer
[907]=45578,--Whirls
[908]=45579,--Cluckatron
[909]=45580,--Gizmo
[911]=45581,--Firetooth
[912]=45582,--Flameclaw
[915]=45583,--Cho'guana
[916]=22175,--Plague
[917]=45584,--Indigon
[921]=45587,--Ultramus
[922]=45585,--Beamer
[923]=45586,--Hatewalker
[924]=39352,--Lacewing
[925]=45590,--Beacon
[926]=45589,--Willow
[927]=45591,--Blizzy
[928]=45637,--Frostmaw
[929]=45593,--Tinygos
[931]=45594,--Plop
[932]=45595,--Corpsefeeder
[933]=45597,--Subject 142
[934]=45599,--Plaguebringer
[935]=45598,--Bleakspinner
[936]=20265,--Carrion
[937]=45600,--Obsidion
[938]=45601,--Veridia
[939]=45602,--Garnestrasz
[944]=45884,--Moltar
[945]=45611,--Ignious
[946]=44533,--Comet
[947]=45612,--Nightstalker
[948]=45613,--Bishibosh
[949]=21900,--Jack
[950]=8189,--Sploder
[951]=32670,--Goliath
[952]=29279,--ED-005
[953]=45614,--Fungor
[954]=45615,--Tripod
[955]=45616,--Glitterfly
[959]=45619,--Cragmaw
[960]=45620,--Gnasher
[961]=45621,--Chomps
[962]=45622,--Netherbite
[963]=45623,--Jadefire
[964]=22587,--Arcanus
[965]=45624,--Warble
[966]=45625,--Gobbles
[967]=45626,--Dinner
[968]=45629,--Mort
[969]=45628,--Stitch
[970]=45630,--Spooky Strangler
[971]=45632,--Rot
[974]=45634,--Blight
[975]=45635,--Fleshrender
[976]=37327,--Cadavus
[977]=19290,--Bloom
[978]=45636,--Beakmaster X-225
[979]=23947,--Grizzle
[995]=45099,--Brood of Mothallus
[996]=45652,--Toothbreaker
[997]=45651,--Siren
[998]=45080,--Woodcarver
[999]=45653,--Needleback
[1000]=36955,--Lightstalker
[1001]=45654,--Bleat
[1002]=23926,--Lapin
[1003]=30971,--Piqua
[1007]=40121,--Mutilator
[1008]=45658,--Pounder
[1009]=45657,--Crusher
[1010]=45660,--Whiskers
[1011]=45661,--Stormlash
[1012]=43352,--Chirrup
--5.0.4
[868]=45942,--Pandaren Water Spirit
[878]=45556,--Dipsy
[883]=45559,--Emeralda
[888]=45562,--Burgle
[913]=30356,--Blaze
[941]=45606,--Anklor
[942]=21950,--Croaker
[943]=45603,--Dampwing
[957]=2838,--Dramaticus
[958]=5379,--Prince Wart
[983]=33293,--Fracture
[987]=19634,--Amythel
[988]=45646,--Twilight
[990]=45647,--Spring
[991]=45648,--Pyth
[992]=45650,--Dor the Wall
[994]=45617,--Skyshaper
[1004]=45655,--Skimmer
[1013]=44779,--Wanderer's Festival Hatchling
[1042]=46385,--Red Cricket
--5.1
[1040]=40521,--Imperial Silkworm
[1067]=46193,--Honky-Tonk
[1124]=46809,--Pandaren Fire Spirit
[1125]=46810,--Pandaren Air Spirit
[1127]=30409,--Spectral Cub
[1128]=40714,--Sumprush Rodent
[1145]=46897,--Mr. Bigglesworth
[1146]=46921,--Stitched Pup
[1147]=46900,--Harbinger of Flame
[1150]=46902,--Ashstone Core
[1152]=46925,--Chrominius
[1156]=46909,--Mini Mindslayer
[1160]=46941,--Arcane Eye
[1161]=47636,--Infinite Whelpling
[1163]=46948,--Anodized Robo Cub
[1164]=47021,--Cogblade Raptor
[1165]=47635,--Nexus Whelpling
--5.2
[240]=29819,--Onyx Panther
[241]=30157,--Tuskarr Kite
[244]=30462,--Core Hound Pup
[247]=30402,--Zipao Tiger
[251]=31073,--Toxic Wasteling
[255]=31956,--Celestial Dragon
[258]=32670,--Mini Thor
[260]=32707,--Gold Mini Jouster
[261]=33512,--Personal World Destroyer
[264]=34262,--Crawling Claw
[268]=35338,--Lil' Deathwing
[270]=37136,--Dark Phoenix Hatchling
[271]=36499,--Rustberg Gull
[272]=36220,--Armadillo Pup
[278]=33217,--Fox Kit
[280]=37200,--Guild Page
[281]=37199,--Guild Page
[282]=37198,--Guild Herald
[283]=37196,--Guild Herald
[286]=9905,--Mr. Grubbs
[289]=38135,--Scooter the Snail
[292]=36901,--Magic Lamp
[294]=36896,--Deathy
[298]=37527,--Moonkin Hatchling
[301]=37814,--Panther Cub
[303]=37846,--Nightsaber Cub
[306]=37712,--Winterspring Cub
[308]=38134,--Legs
[309]=38229,--Pterrordax Hatchling
[310]=38232,--Voodoo Figurine
[316]=16943,--Cenarion Hatchling
[317]=38455,--Hyjal Bear Cub
[318]=38429,--Crimson Lasher
[319]=38539,--Feline Familiar
[320]=38614,--Lil' Tarecgosa
[321]=38638,--Creepy Crate
[325]=38776,--Brilliant Kaliri
[328]=38777,--Purple Puffer
[329]=38803,--Murkablo
[332]=38342,--Horde Balloon
[333]=38919,--Gregarious Grell
[340]=39109,--Sea Pony
[341]=39163,--Lunar Lantern
[342]=39333,--Festival Lantern
[344]=38340,--Green Balloon
[345]=38341,--Yellow Balloon
[346]=39380,--Fetish Shaman
[347]=40019,--Soul of the Aspects
[348]=40538,--Eye of the Legion
[380]=40713,--Bucktooth Flapper
[532]=42708,--Stunted Shardhorn
[534]=42709,--Imperial Eagle Chick
[537]=42735,--Dragonbone Hatchling
[538]=42737,--Scourged Whelpling
[552]=42783,--Twilight Fiendling
[665]=39694,--Sand Scarab
[677]=40089,--Shy Bandicoon
[679]=43485,--Summit Kid
[753]=36671,--Garden Moth
[754]=20042,--Shrine Fly
[792]=43868,--Jade Crane Chick
[819]=43874,--Wild Crimson Hatchling
[820]=43127,--Singing Cricket
[835]=43597,--Hopling
[846]=42297,--Sapphire Cub
[850]=44792,--Yu'lon Kite
[855]=45195,--Venus
[879]=45557,--Flufftail
[884]=45639,--Moonstalker
[903]=45527,--Baneling
[956]=45618,--Stompy
[972]=45633,--Sleet
[973]=45631,--Drogar
[980]=5990,--Incinderous
[981]=45643,--Ashtail
[982]=45644,--Kali
[984]=45645,--Crystallus
[985]=36436,--Ruby
[986]=42988,--Helios
[989]=34913,--Clatter
[993]=45649,--Fangor
[1005]=32661,--Mollus
[1006]=45656,--Diamond
[1039]=44551,--Imperial Moth
[1061]=46163,--Darkmoon Hatchling
[1062]=46171,--Darkmoon Glowfly
[1063]=46174,--Darkmoon Eye
[1065]=46174,--Judgement
[1066]=46192,--Fezwick
[1068]=36743,--Crow
[1117]=46720,--Cinder Kitten
[1126]=46811,--Pandaren Earth Spirit
[1129]=46862,--Ka'wi the Gorger
[1142]=46882,--Clock'em
[1143]=46898,--Giant Bone Spider
[1144]=46896,--Fungal Abomination
[1149]=46923,--Corefire Imp
[1151]=46903,--Untamed Hatchling
[1153]=46905,--Death Talon Whelpguard
[1154]=46924,--Viscidus Globule
[1155]=46922,--Anubisath Idol
[1157]=46936,--Harpy Youngling
[1158]=46937,--Stunted Yeti
[1159]=46938,--Lofty Libram
[1162]=46947,--Fluxfire Feline
[1166]=46953,--Kun-Lai Runt
[1167]=46954,--Emerald Proto-Whelp
[1174]=47348,--Gusting Grimoire
[1175]=47633,--Thundertail Flapper
[1176]=47634,--Red Panda
[1177]=47252,--Living Sandling
[1178]=47848,--Sunreaver Micro-Sentry
[1179]=47690,--Electrified Razortooth
[1180]=47731,--Zandalari Kneebiter
[1181]=47887,--Elder Python
[1182]=47989,--Swamp Croaker
[1183]=47708,--Son of Animus
[1184]=48211,--Stunted Direhorn
[1185]=47732,--Spectral Porcupette
[1187]=47740,--Gorespine
[1188]=47754,--No-No
[1189]=47742,--Greyhoof
[1190]=42986,--Lucky Yi
[1191]=47743,--Ti'un the Wanderer
[1192]=47744,--Kafi
[1193]=41372,--Dos-Ryga
[1194]=47745,--Nitun
[1195]=44096,--Skitterer Xi'a
[1196]=47747,--Sunfur Panda
[1197]=47749,--Snowy Panda
[1198]=47748,--Mountain Panda
[1201]=48091,--Spawn of G'nathus
[1202]=48001,--Ji-Kun Hatchling
[1204]=47711,--Pierre
[1206]=47959,--Tiny Red Carp
[1207]=47957,--Tiny Blue Carp
[1208]=47958,--Tiny Green Carp
[1209]=47960,--Tiny White Carp
[1211]=48055,--Zandalari Anklerender
[1212]=48056,--Zandalari Footslasher
[1213]=48057,--Zandalari Toenibbler
--5.3
[1200]=48212,--Pygmy Direhorn
[1205]=48213,--Direhorn Runt
[1226]=48878,--Lil' Bad Wolf
[1227]=48857,--Menagerie Custodian
[1228]=48856,--Netherspace Abyssal
[1229]=48662,--Fiendish Imp
[1230]=48855,--Tideskipper
[1231]=48666,--Tainted Waveling
[1232]=48661,--Coilfang Stalker
[1233]=48664,--Pocket Reaver
[1234]=48668,--Lesser Voidcaller
[1235]=48663,--Phoenix Hawk Hatchling
[1236]=48667,--Tito
[1237]=48651,--Gahz'rooki
[1238]=48650,--Unborn Val'kyr
[1243]=48704,--Living Fluid
[1244]=48705,--Viscous Horror
[1245]=48708,--Filthling
[1247]=48877,--Doopy
[1248]=48934,--Blossoming Ancient
--5.4
[1130]=14779,--Crimson
[1131]=42926,--Glowy
[1132]=46863,--Marley
[1133]=40002,--Tiptoe
[1134]=42781,--Sludgy
[1135]=20749,--Dusty
[1136]=44445,--Whispertail
[1137]=1418,--Darnak the Tunneler
[1138]=39741,--Pandaren Water Spirit
[1139]=39747,--Pandaren Fire Spirit
[1140]=41252,--Pandaren Air Spirit
[1141]=40079,--Pandaren Earth Spirit
[1255]=49081,--Murkimus Tyrannicus
[1256]=49084,--Rascal-Bot
[1259]=40338,--Widowling
[1266]=49846,--Xu-Fu, Cub of Xuen
[1267]=49262,--Xu-Fu, Cub of Xuen
[1268]=48211,--Trike
[1269]=49282,--Screamer
[1271]=51712,--Chaos
[1276]=855,--Moon Moon
[1277]=49289,--Lil' B
[1278]=49288,--Au
[1279]=21304,--Banks
[1280]=42430,--Brewly
[1281]=43127,--Chirps
[1282]=49290,--Tonsa
[1283]=43876,--Knowledge
[1284]=45960,--Patience
[1285]=27563,--Wisdom
[1286]=51599,--Summer
[1287]=46947,--Stormoen
[1288]=49299,--Nairn
[1289]=45957,--Monte
[1290]=43350,--Rikki
[1291]=51008,--Socks
[1292]=30414,--Bolo
[1293]=30414,--Li
[1295]=30414,--Yen
[1296]=42162,--Carpe Diem
[1297]=2069,--River
[1298]=45073,--Spirus
[1299]=28456,--Cindy
[1300]=35338,--Dah'da
[1301]=6290,--Alex
[1303]=49835,--Chi-Chi, Hatchling of Chi-Ji
[1304]=49836,--Yu'la, Broodling of Yu'lon
[1305]=49845,--Zao, Calfling of Niuzao
[1311]=50743,--Chi-Chi, Hatchling of Chi-Ji
[1317]=49263,--Yu'la, Broodling of Yu'lon
[1319]=49430,--Zao, Calfling of Niuzao
[1320]=49289,--Lil' Bling
[1321]=51413,--Azure Crane Chick
[1322]=51268,--Blackfuse Bombling
[1323]=40908,--Ashleaf Spriteling
[1324]=51742,--Ashwing Moth
[1325]=51301,--Flamering Moth
[1326]=51740,--Skywisp Moth
[1328]=51271,--Ruby Droplet
[1329]=51408,--Dandelion Frolicker
[1330]=51277,--Death Adder Hatchling
[1331]=51417,--Droplet of Y'Shaarj
[1332]=51267,--Gooey Sha-ling
[1333]=51270,--Jademist Dancer
[1334]=51269,--Kovok
[1335]=51272,--Ominous Flame
[1336]=51279,--Skunky Alemental
[1337]=51278,--Spineclaw Crab
[1338]=47991,--Gulp Froglet
[1339]=51451,--Lil' Oondasta
[1343]=51475,--Bonkers
[1344]=47858,--Vengeful Porcupette
[1345]=51502,--Gu'chi Swarmling
[1346]=47856,--Harmonious Porcupette
[1348]=51504,--Jadefire Spirit
[1349]=51505,--Rotten Little Helper
[1350]=51530,--Sky Lantern
--5.4.1
[1363]=51988,--Alterac Brew-Pup
[1364]=51990,--Murkalot
--5.4.2
[1365]=51994,--Treasure Goblin
--5.4.7

}

--Item to spell data table--
ModelPique_ItemToSpell_Table = {
------------------------------------------
--**************************************--
--*************** MOUNTS ***************--
--**************************************--
------------------------------------------
--1.11.1 and earlier
[18796]=23250,--Swift Brown Wolf
[21176]=26656,--Black Qiraji Battle Tank
[12302]=16056,--Ancient Frostsaber
[12303]=16055,--Black Nightsaber
[12330]=16080,--Red Wolf
[12351]=16081,--Winter Wolf
[12353]=16083,--White Stallion
[12354]=16082,--Palomino
[13086]=17229,--Winterspring Frostsaber
[13317]=17450,--Ivory Raptor
[13326]=15779,--White Mechanostrider Mod B
[13327]=17459,--Icy Blue Mechanostrider Mod A
[13328]=17461,--Black Ram
[13329]=17460,--Frost Ram
[13334]=17465,--Green Skeletal Warhorse
[13335]=17481,--Rivendare's Deathcharger
[15292]=18991,--Green Kodo
[15293]=18992,--Teal Kodo
[18766]=23221,--Swift Frostsaber
[18767]=23219,--Swift Mistsaber
[18772]=23225,--Swift Green Mechanostrider
[18773]=23223,--Swift White Mechanostrider
[18774]=23222,--Swift Yellow Mechanostrider
[18776]=23227,--Swift Palomino
[18777]=23229,--Swift Brown Steed
[18778]=23228,--Swift White Steed
[18785]=23240,--Swift White Ram
[18786]=23238,--Swift Brown Ram
[18787]=23239,--Swift Gray Ram
[18788]=23241,--Swift Blue Raptor
[18789]=23242,--Swift Olive Raptor
[18790]=23243,--Swift Orange Raptor
[18791]=23246,--Purple Skeletal Warhorse
[18793]=23247,--Great White Kodo
[18794]=23249,--Great Brown Kodo
[18795]=23248,--Great Gray Kodo
[8586]=16084,--Mottled Red Raptor
[18797]=23251,--Swift Timber Wolf
[18798]=23252,--Swift Gray Wolf
[18902]=23338,--Swift Stormsaber
[19029]=23509,--Frostwolf Howler
[19030]=23510,--Stormpike Battle Charger
[19872]=24242,--Swift Razzashi Raptor
[19902]=24252,--Swift Zulian Tiger
[21218]=25953,--Blue Qiraji Battle Tank
[21321]=26054,--Red Qiraji Battle Tank
[21323]=26056,--Green Qiraji Battle Tank
[21324]=26055,--Yellow Qiraji Battle Tank
[8591]=10796,--Turquoise Raptor
[1132]=580,--Timber Wolf
[2414]=472,--Pinto
[5655]=6648,--Chestnut Mare
[5656]=458,--Brown Horse
[5665]=6653,--Dire Wolf
[5668]=6654,--Brown Wolf
[5864]=6777,--Gray Ram
[5872]=6899,--Brown Ram
[5873]=6898,--White Ram
[8563]=10873,--Red Mechanostrider
[8588]=8395,--Emerald Raptor
[2411]=470,--Black Stallion
[8592]=10799,--Violet Raptor
[8595]=10969,--Blue Mechanostrider
[8629]=10793,--Striped Nightsaber
[8631]=8394,--Striped Frostsaber
[8632]=10789,--Spotted Frostsaber
[13321]=17453,--Green Mechanostrider
[13322]=17454,--Unpainted Mechanostrider
[13331]=17462,--Red Skeletal Horse
[13332]=17463,--Blue Skeletal Horse
[13333]=17464,--Brown Skeletal Horse
[15277]=18989,--Gray Kodo
[15290]=18990,--Brown Kodo
--2.0
[23720]=30174,--Riding Turtle
--2.0.1
[25477]=32246,--Swift Red Wind Rider
[25532]=32296,--Swift Yellow Wind Rider
[25533]=32297,--Swift Purple Wind Rider
[25531]=32295,--Swift Green Wind Rider
[25470]=32235,--Golden Gryphon
[25471]=32239,--Ebon Gryphon
[25472]=32240,--Snowy Gryphon
[25474]=32243,--Tawny Wind Rider
[25475]=32244,--Blue Wind Rider
[25476]=32245,--Green Wind Rider
[28915]=39316,--Dark Riding Talbuk
[28936]=33660,--Swift Pink Hawkstrider
[29102]=34896,--Cobalt War Talbuk
[29103]=34897,--White War Talbuk
[29104]=34898,--Silver War Talbuk
[29105]=34899,--Tan War Talbuk
[29223]=35025,--Swift Green Hawkstrider
[29224]=35027,--Swift Purple Hawkstrider
[29227]=34896,--Cobalt War Talbuk
[29228]=34790,--Dark War Talbuk
[29229]=34898,--Silver War Talbuk
[29230]=34899,--Tan War Talbuk
[29231]=34897,--White War Talbuk
[29465]=22719,--Black Battlestrider
[29466]=22718,--Black War Kodo
[29467]=22720,--Black War Ram
[29468]=22717,--Black War Steed
[29469]=22724,--Black War Wolf
[29470]=22722,--Red Skeletal Warhorse
[29471]=22723,--Black War Tiger
[29472]=22721,--Black War Raptor
[29745]=35713,--Great Blue Elekk
[29746]=35712,--Great Green Elekk
[29747]=35714,--Great Purple Elekk
[30480]=36702,--Fiery Warhorse
[31829]=39315,--Cobalt Riding Talbuk
[31830]=39315,--Cobalt Riding Talbuk
[31831]=39317,--Silver Riding Talbuk
[31832]=39317,--Silver Riding Talbuk
[31833]=39318,--Tan Riding Talbuk
[31834]=39318,--Tan Riding Talbuk
[31835]=39319,--White Riding Talbuk
[31836]=39319,--White Riding Talbuk
[28481]=34406,--Brown Elekk
[28927]=34795,--Red Hawkstrider
[29220]=35020,--Blue Hawkstrider
[29221]=35022,--Black Hawkstrider
[29222]=35018,--Purple Hawkstrider
[29743]=35711,--Purple Elekk
[29744]=35710,--Gray Elekk
--2.1
[32319]=39803,--Blue Riding Nether Ray
[25473]=32242,--Swift Blue Gryphon
[25528]=32290,--Swift Green Gryphon
[25529]=32292,--Swift Purple Gryphon
[32314]=39798,--Green Riding Nether Ray
[32316]=39801,--Purple Riding Nether Ray
[32317]=39800,--Red Riding Nether Ray
[32318]=39802,--Silver Riding Nether Ray
[25527]=32289,--Swift Red Gryphon
[32857]=41513,--Onyx Netherwing Drake
[32858]=41514,--Azure Netherwing Drake
[32859]=41515,--Cobalt Netherwing Drake
[32860]=41516,--Purple Netherwing Drake
[32861]=41517,--Veridian Netherwing Drake
[32862]=41518,--Violet Netherwing Drake
[32768]=41252,--Raven Lord
--2.1.1
[32458]=40192,--Ashes of Al'ar
--2.1.2
[30609]=37015,--Swift Nether Drake
--2.2
[33977]=43900,--Swift Brewfest Ram
[33976]=43899,--Brewfest Ram
--2.2.2
[33182]=42668,--Swift Flying Broom
[33184]=42668,--Swift Magic Broom
[33176]=42667,--Flying Broom
--2.3
[25596]=32345,--Peep the Phoenix Mount
[33809]=43688,--Amani War Bear
[33999]=43927,--Cenarion War Hippogryph
[34061]=44151,--Turbo-Charged Flying Machine
[34092]=44744,--Merciless Nether Drake
[34060]=44153,--Flying Machine
[34129]=35028,--Swift Warstrider
--2.4
[35513]=46628,--Swift White Hawkstrider
[35906]=48027,--Black War Elekk
--2.4.2
[37676]=49193,--Vengeful Nether Drake
--2.4.3
[43516]=58615,--Brutal Nether Drake
[37719]=49322,--Swift Zhevra
[37828]=49379,--Great Brewfest Kodo
[37012]=48025,--Headless Horseman's Mount
[43599]=58983,--Big Blizzard Bear
[37011]=47977,--Magic Broom
[37750]=66052,--Fresh Brewfest Hops
[39476]=66051,--Fresh Goblin Brewfest Hops
--3.0.1
[41508]=55531,--Mechano-Hog
[44502]=55531,--Mechano-Hog(Recipe)
[40775]=54729,--Winged Steed of the Ebon Blade
--3.0.2
[44413]=60424,--Mekgineer's Chopper
[44503]=60424,--Mekgineer's Chopper(Recipe)
[44221]=64749,--Loaned Gryphon Reins
[44229]=64762,--Loaned Wind Rider Reins
[44168]=60002,--Time-Lost Proto-Drake
[43952]=59567,--Azure Drake
[43954]=59571,--Twilight Drake
[43955]=59570,--Red Drake
[43951]=59569,--Bronze Drake
[44151]=59996,--Blue Proto-Drake
[43953]=59568,--Blue Drake
[44178]=60025,--Albino Drake
[44558]=61309,--Magnificent Flying Carpet
[44689]=61229,--Armored Snowy Gryphon
[44690]=61230,--Armored Blue Wind Rider
[43986]=59650,--Black Drake
[44554]=61451,--Flying Carpet
[44223]=60118,--Black War Bear
[43956]=59785,--Black War Mammoth
[43961]=61470,--Grand Ice Mammoth
[43962]=54753,--White Polar Bear
[44077]=59788,--Black War Mammoth
[44080]=59797,--Ice Mammoth
[44086]=61469,--Grand Ice Mammoth
[43958]=59799,--Ice Mammoth
[44224]=60119,--Black War Bear
[44225]=60114,--Armored Brown Bear
[44226]=60116,--Armored Brown Bear
[44230]=59791,--Wooly Mammoth
[44231]=59793,--Wooly Mammoth
[44234]=61447,--Traveler's Tundra Mammoth
[44235]=61425,--Traveler's Tundra Mammoth
--3.0.3
[44160]=59961,--Red Proto-Drake
[44707]=61294,--Green Proto-Drake
[43959]=61465,--Grand Black War Mammoth
--3.0.8
[44175]=60021,--Plagued Proto-Drake
--3.0.9
[44164]=59976,--Black Proto-Drake
[44083]=61467,--Grand Black War Mammoth
--3.1
[46109]=64731,--Sea Turtle
[44843]=61996,--Blue Dragonhawk
[45693]=63796,--Mimiron's Head
[45725]=63844,--Argent Hippogryph
[44842]=61997,--Red Dragonhawk
[45125]=63232,--Stormwind Steed
[45586]=63636,--Ironforge Ram
[45589]=63638,--Gnomeregan Mechanostrider
[45590]=63639,--Exodar Elekk
[45591]=63637,--Darnassian Nightsaber
[45592]=63641,--Thunder Bluff Kodo
[45593]=63635,--Darkspear Raptor
[45595]=63640,--Orgrimmar Wolf
[45596]=63642,--Silvermoon Hawkstrider
[45597]=63643,--Forsaken Warhorse
[46101]=64656,--Blue Skeletal Warhorse
[46099]=64658,--Black Wolf
[46100]=64657,--White Kodo
[46308]=64977,--Black Skeletal Horse
--3.1.1
[46171]=65439,--Furious Gladiator's Frost Wyrm
--3.1.2
[45802]=63963,--Rusted Proto-Drake
[46752]=65640,--Swift Gray Steed
[46744]=65638,--Swift Moonsaber
[46745]=65637,--Great Red Elekk
[46746]=65645,--White Skeletal Warhorse
[46743]=65644,--Swift Purple Raptor
[46748]=65643,--Swift Violet Ram
[46749]=65646,--Swift Burgundy Wolf
[46750]=65641,--Great Golden Kodo
[46751]=65639,--Swift Red Hawkstrider
[46747]=65642,--Turbostrider
--3.1.3
[45801]=63956,--Ironbound Proto-Drake
--3.2
[44177]=60024,--Violet Proto-Drake
[46813]=66087,--Silver Covenant Hippogryph
[46814]=66088,--Sunreaver Dragonhawk
[49286]=46199,--X-51 Nether-Rocket X-TREME
[46708]=64927,--Deadly Gladiator's Frost Wyrm
[49285]=46197,--X-51 Nether-Rocket
[46102]=64659,--Venomhide Ravasaur
[46815]=66090,--Quel'dorei Steed
[46816]=66091,--Sunreaver Hawkstrider
[47101]=66846,--Ochre Skeletal Warhorse
[47179]=66906,--Argent Charger
[47180]=67466,--Argent Warhorse
[49044]=68057,--Swift Alliance Steed
[49096]=68187,--Crusader's White Warhorse
[49098]=68188,--Crusader's Black Warhorse
[49282]=51412,--Big Battle Bear
[49284]=42777,--Swift Spectral Tiger
[49290]=65917,--Magic Rooster
[47100]=66847,--Striped Dawnsaber
[49283]=42776,--Spectral Tiger
--3.2.2
[49636]=69395,--Onyxian Drake
[49046]=68056,--Swift Horde Wolf
[49288]=68769,--Little Ivory Raptor Whistle
[49289]=68768,--Little White Stallion Bridle
--3.3
[50818]=72286,--Invincible
[50818]=72286,--Invincible(Recipe)
--3.3.2
[51954]=72808,--Bloodbathed Frostbrood Vanquisher
[50250]=71342,--Big Love Rocket
--3.3.3
[47840]=67336,--Relentless Gladiator's Frost Wyrm
[51955]=72807,--Icebound Frostbrood Vanquisher
[54797]=75596,--Frosty Flying Carpet
[54798]=75596,--Frosty Flying Carpet(Recipe)
[54069]=74856,--Blazing Hippogryph
[54860]=75973,--X-53 Touring Rocket
[52200]=73313,--Crimson Deathcharger
[54811]=75614,--Celestial Steed
--3.3.5
[54068]=74918,--Wooly White Rhino
--4.0.1
[65891]=93326,--Sandstone Drake
[67538]=93326,--Sandstone Drake(Recipe)
[63043]=88746,--Vitreous Stone Drake
[62900]=88331,--Volcanic Stone Drake
[62901]=88335,--Drake of the East Wind
[63039]=88741,--Drake of the West Wind
[63040]=88742,--Drake of the North Wind
[63041]=88744,--Drake of the South Wind
[63042]=88718,--Phosphorescent Stone Drake
[50435]=71810,--Wrathful Gladiator's Frost Wyrm
[63125]=88990,--Dark Phoenix
[64998]=92231,--Spectral Steed
[64999]=92232,--Spectral Wolf
[65356]=88741,--Drake of the West Wind
[63044]=88748,--Brown Riding Camel
[63045]=88749,--Tan Riding Camel
[63046]=88750,--Grey Riding Camel
[64883]=92155,--Ultramarine Qiraji Battle Tank
--4.0.3
[67151]=98718,--Subdued Seahorse
[54465]=75207,--Abyssal Seahorse
[68008]=93623,--Mottled Drake
[60954]=84751,--Fossilized Raptor
[62462]=87091,--Goblin Turbo-Trike
[62298]=90621,--Golden King
[67107]=93644,--Kor'kron Annihilator
[62461]=87090,--Goblin Trike
--4.1
[69747]=98204,--Amani Battle Bear
[69213]=97359,--Flameward Hippogryph
[69224]=97493,--Pureblood Fire Hawk
[68825]=96503,--Amani Dragonhawk
[68823]=96491,--Armored Razzashi Raptor
[68824]=96499,--Swift Zulian Panther
[69228]=97581,--Savage Raptor
[69846]=98727,--Winged Guardian
[69846]=98727,--Winged Guardian(Recipe)
--4.2
[69230]=97560,--Corrupted Fire Hawk
[71339]=101282,--Vicious Gladiator's Twilight Drake
[70909]=100332,--Vicious War Steed
[70910]=100333,--Vicious War Wolf
[71665]=101542,--Flametalon of Alysrazor
--4.3
[77067]=107842,--Blazing Drake
[77069]=107845,--Life-Binder's Handmaiden
[78919]=110039,--Experiment 12-B
[77068]=107844,--Twilight Harbinger
[71954]=101821,--Ruthless Gladiator's Twilight Drake
[74269]=74856,--Blazing Hippogryph
[76889]=107516,--Spectral Gryphon
[76902]=107517,--Spectral Wind Rider
[73839]=103196,--Swift Mountain Horse
[71718]=101573,--Swift Shorestrider
[72140]=102346,--Swift Forest Strider
[72145]=102349,--Swift Springstrider
[72146]=102350,--Swift Lovebird
[72575]=102488,--White Riding Camel
[73766]=103081,--Darkmoon Dancing Bear
[76755]=107203,--Tyrael's Charger
[78924]=110051,--Heart of the Aspects
[73838]=103195,--Mountain Horse
[72582]=102514,--Corrupted Hippogryph
--4.3.2
[79771]=113120,--Feldrake
--5.0.1
[83088]=121837,--Jade Panther
[83845]=121837,--Jade Panther(Recipe)
[79802]=113199,--Jade Cloud Serpent
[82453]=120043,--Jeweled Onyx Panther
[83877]=120043,--Jeweled Onyx Panther(Recipe)
[84101]=122708,--Grand Expedition Yak
[85429]=123993,--Golden Cloud Serpent
[85430]=123992,--Azure Cloud Serpent
[87768]=127154,--Onyx Cloud Serpent
[87769]=127156,--Crimson Cloud Serpent
[87771]=127158,--Heavenly Onyx Cloud Serpent
[87773]=127161,--Heavenly Crimson Cloud Serpent
[87774]=127164,--Heavenly Golden Cloud Serpent
[87777]=127170,--Astral Cloud Serpent
[87781]=127174,--Azure Riding Crane
[87782]=127176,--Golden Riding Crane
[87783]=127177,--Regal Riding Crane
[87788]=127216,--Grey Riding Yak
[87789]=127220,--Blonde Riding Yak
[89154]=129552,--Crimson Pandaren Phoenix
[89304]=129918,--Thundering August Cloud Serpent
[89305]=129932,--Green Shado-Pan Riding Tiger
[89306]=129935,--Red Shado-Pan Riding Tiger
[89307]=129934,--Blue Shado-Pan Riding Tiger
[89362]=130086,--Brown Riding Goat
[89390]=130137,--White Riding Goat
[89391]=130138,--Black Riding Goat
[89783]=130965,--Son of Galleon
[83087]=121838,--Ruby Panther
[83931]=121838,--Ruby Panther(Recipe)
[81354]=118089,--Azure Water Strider
[83089]=121839,--Sunstone Panther
[83830]=121839,--Sunstone Panther(Recipe)
[83090]=121836,--Sapphire Panther
[83932]=121836,--Sapphire Panther(Recipe)
[81559]=118737,--Pandaren Kite
[85666]=124408,--Thundering Jade Cloud Serpent
[89785]=130985,--Pandaren Kite
[85262]=123886,--Amber Scorpion
[83086]=121820,--Obsidian Nightwing
[87250]=126507,--Depleted-Kyparium Rocket
[87251]=126508,--Geosynchronous World Spinner
[89363]=130092,--Red Flying Cloud
[82811]=120822,--Great Red Dragon Turtle
[87801]=127293,--Great Green Dragon Turtle
[87802]=127295,--Great Black Dragon Turtle
[87803]=127302,--Great Blue Dragon Turtle
[87804]=127308,--Great Brown Dragon Turtle
[87805]=127310,--Great Purple Dragon Turtle
[85870]=124659,--Imperial Quilen
[82765]=120395,--Green Dragon Turtle
[87795]=127286,--Black Dragon Turtle
[87796]=127287,--Blue Dragon Turtle
[87797]=127288,--Brown Dragon Turtle
[87799]=127289,--Purple Dragon Turtle
[87800]=127290,--Red Dragon Turtle
[89682]=130678,--Oddly-Shaped Horn
[89697]=130730,--Bag of Kafa Beans
[89770]=130895,--Tuft of Yak Fur
--5.0.4
[90655]=132036,--Thundering Ruby Cloud Serpent
[90711]=132118,--Emerald Pandaren Phoenix
[90712]=132119,--Violet Pandaren Phoenix
[90710]=132117,--Ashen Pandaren Phoenix
[91010]=120822,--Great Red Dragon Turtle
[91011]=127295,--Great Black Dragon Turtle
[91012]=127293,--Great Green Dragon Turtle
[91013]=127302,--Great Blue Dragon Turtle
[91014]=127308,--Great Brown Dragon Turtle
[91015]=127310,--Great Purple Dragon Turtle
[91004]=120395,--Green Dragon Turtle
[91005]=127288,--Brown Dragon Turtle
[91006]=127289,--Purple Dragon Turtle
[91007]=127290,--Red Dragon Turtle
[91008]=127286,--Black Dragon Turtle
[91009]=127287,--Blue Dragon Turtle
--5.0.5
[85785]=124550,--Cataclysmic Gladiator's Twilight Drake
--5.1
[93168]=135416,--Grand Armored Gryphon
[93169]=135418,--Grand Armored Wyvern
[93385]=136163,--Grand Gryphon
[93386]=136164,--Grand Wyvern
[91802]=133023,--Jade Pandaren Kite
[92724]=134573,--Swift Windsteed
--5.2
[93666]=136471,--Spawn of Horridon
[95057]=139442,--Thundering Cobalt Cloud Serpent
[95059]=139448,--Clutch of Ji-Kun
[95564]=140249,--Golden Primal Direhorn
[95565]=140250,--Crimson Primal Direhorn
[95041]=139407,--Malevolent Gladiator's Cloud Serpent
[95416]=134359,--Sky Golem
[93662]=136400,--Armored Skyscreamer
[93671]=136505,--Ghastly Charger
[94228]=138423,--Cobalt Primordial Direhorn
[94229]=138425,--Slate Primordial Direhorn
[94230]=138424,--Amber Primordial Direhorn
[94231]=138426,--Jade Primordial Direhorn
[94290]=138640,--Bone-White Primal Raptor
[94291]=138641,--Red Primal Raptor
[94292]=138642,--Black Primal Raptor
[94293]=138643,--Green Primal Raptor
[95341]=139595,--Armored Bloodwing
--5.3
[98405]=142641,--Brawler's Burly Mushan Beast
[98104]=142266,--Armored Red Dragonhawk
[98259]=142478,--Armored Blue Dragonhawk
[97989]=142878,--Enchanted Fey Dragon
[98618]=142073,--Hearthsteed
--5.4
[104327]=148620,--Prideful Gladiator's Cloud Serpent
[103638]=148428,--Ashhide Mushan Beast
[104246]=148396,--Kor'kron War Wolf
[104253]=148417,--Kor'kron Juggernaut
[104269]=148476,--Thundering Onyx Cloud Serpent
[104325]=148618,--Tyrannical Gladiator's Cloud Serpent
[104326]=148619,--Grievous Gladiator's Cloud Serpent
[104208]=148392,--Spawn of Galakras
[102514]=146615,--Vicious Warsaber
[102533]=146622,--Vicious Skeletal Warhorse
[103630]=30174,--Riding Turtle
[104011]=147595,--Stormcrow
[101675]=145133,--Shimmering Moonstone
[104329]=148626,--Ash-Covered Horn
[104346]=148773,--Golden Glider
--5.4.1
[106246]=149801,--Emerald Hippogryph
--5.4.2
[107951]=153489,--Iron Skyreaver
--5.4.7
[109013]=155741,--Armored Dread Raven
--5.4.8
[112326]=163024,--Warforged Nightmare
[112327]=163025,--Grinning Reaver
------------------------------------------
--**************************************--
--************* COMPANIONS *************--
--**************************************--
------------------------------------------
--1.11.1 and earlier
[12264]=15999,--Worg Pup
[21277]=26010,--Tranquil Mechanical Yeti
[12529]=16450,--Smolderweb Hatchling
[20769]=25162,--Disgusting Oozeling
[15996]=19772,--Lifelike Toad
[16044]=19772,--Lifelike Toad(Recipe)
[11474]=15067,--Sprite Darter Hatchling
[11825]=15048,--Pet Bombling
[11828]=15048,--Pet Bombling(Recipe)
[11826]=15049,--Lil' Smoky
[11827]=15049,--Lil' Smoky(Recipe)
[10398]=12243,--Mechanical Chicken
[11026]=10704,--Tree Frog
[11027]=10703,--Wood Frog
[19450]=23811,--Jubling
[19462]=23851,--Unhatched Jubling Egg
[11023]=10685,--Ancona Chicken
[8499]=10697,--Crimson Whelpling
[8500]=10707,--Great Horned Owl
[8501]=10706,--Hawk Owl
[10360]=10714,--Black Kingsnake
[10361]=10716,--Brown Snake
[10392]=10717,--Crimson Snake
[10393]=10688,--Undercity Cockroach
[10394]=10709,--Brown Prairie Dog
[10822]=10695,--Dark Whelpling
[8498]=10698,--Emerald Whelpling
[8494]=10682,--Hyacinth Macaw
[13582]=17709,--Zergling
[13583]=17707,--Panda Cub
[13584]=17708,--Mini Diablo
[20371]=24696,--Murky
[8485]=10673,--Bombay Cat
[8486]=10674,--Cornish Rex Cat
[8487]=10676,--Orange Tabby Cat
[8488]=10678,--Silver Tabby Cat
[8489]=10679,--White Kitten
[8490]=10677,--Siamese Cat
[8491]=10675,--Black Tabby Cat
[8492]=10683,--Green Wing Macaw
[8495]=10684,--Senegal
[8496]=10680,--Cockatiel
[8497]=10711,--Snowshoe Rabbit
[4401]=4055,--Mechanical Squirrel
[4408]=4055,--Mechanical Squirrel(Recipe)
[23015]=28740,--Whiskers the Rat
[11110]=13548,--Westfall Chicken
[21301]=26533,--Father Winter's Helper
[21305]=26541,--Winter's Little Helper
[21308]=26529,--Winter Reindeer
[23083]=28871,--Spirit of Summer
[22200]=27662,--Silver Shafted Arrow
[22235]=27570,--Peddlefeet
[23002]=28738,--Speedy
[23007]=28739,--Mr. Wiggles
[21309]=26045,--Tiny Snowman
--1.12.1
[18964]=23429,--Loggerhead Snapjaw
[19054]=23530,--Tiny Red Dragon
[19055]=23531,--Tiny Green Dragon
--2.0
[23713]=30156,--Hippogryph Hatchling
--2.0.1
[31760]=39181,--Miniwing
[29363]=35156,--Mana Wyrmling
[29364]=35239,--Brown Rabbit
[29902]=35909,--Red Moth
[29958]=36031,--Blue Dragonhawk Hatchling
[27445]=33050,--Magical Crawdad
[29901]=35907,--Blue Moth
[29903]=35910,--Yellow Moth
[29904]=35911,--White Moth
[29953]=36027,--Golden Dragonhawk Hatchling
[29956]=36028,--Red Dragonhawk Hatchling
[29957]=36029,--Silver Dragonhawk Hatchling
[32588]=40549,--Bananas
--2.0.3
[23712]=30152,--White Tiger Cub
--2.1
[22114]=27241,--Gurky
[25535]=32298,--Netherwhelp
[32616]=40614,--Egbert
[32617]=40613,--Willy
[32622]=40634,--Peanut
[29960]=36034,--Firefly
[30360]=24988,--Lurky
--2.2.2
[32233]=39709,--Wolpertinger
[33154]=42609,--Sinister Squashling
--2.3
[34478]=45082,--Tiny Sporebat
[34535]=10696,--Azure Whelpling
[33993]=43918,--Mojo
[34493]=45127,--Dragon Kite
[34425]=54187,--Clockwork Rocket Bot
[34492]=45125,--Rocket Chicken
--2.4
[35504]=46599,--Phoenix Hatchling
[33816]=43697,--Toothy
[33818]=43698,--Muckbreath
[35349]=46425,--Snarly
[35350]=46426,--Chuck
--2.4.2
[38628]=51716,--Nether Ray Fry
[34955]=45890,--Searing Scorchling
[38050]=49964,--Ethereal Soul-Trader
[39656]=53082,--Mini Tyrael
[32498]=40405,--Lucky
--2.4.3
[37297]=48406,--Spirit of Competition
--[37710]=49352,--Crashin' Thrashin' Racer
--3.0.1
[21168]=25849,--Baby Shark
[40653]=40990,--Stinker
--3.0.2
[38658]=51851,--Vampiric Batling
[39973]=53316,--Ghostly Skull
[43698]=59250,--Giant Sewer Rat
[44723]=61357,--Pengu
[39896]=61348,--Tickbird Hatchling
[39899]=61349,--White Tickbird Hatchling
[44721]=61350,--Proto-Drake Whelp
[44481]=60832,--Grindgear Toy Gorilla
[44482]=60838,--Trusty Copper Racer
--3.0.3
[39286]=52615,--Frosty
[44738]=61472,--Kirin Tor Familiar
[39898]=61351,--Cobra Hatchling
[44819]=61855,--Baby Blizzard Bear
--3.0.8
[44841]=61991,--Little Fawn
--3.1
[44822]=10713,--Albino Snake
[45942]=64351,--XS-001 Constructor Bot
[44794]=61725,--Spring Rabbit
[44965]=62491,--Teldrassil Sproutling
[44970]=62508,--Dun Morogh Cub
[44971]=62510,--Tirisfal Batling
[44973]=62513,--Durotar Scorpion
[44974]=62516,--Elwynn Lamb
[44980]=62542,--Mulgore Hatchling
[44983]=62561,--Strand Crawler
[44984]=62562,--Ammen Vale Lashling
[44998]=62609,--Argent Squire
[45002]=62674,--Mechanopeep
[45022]=62746,--Argent Gruntling
[45057]=62949,--Wind-Up Train Wrecker
[45606]=63712,--Sen'jin Fetish
[44982]=62564,--Enchanted Broom
[44601]=61022,--Heavy Copper Racer
[44599]=61021,--Zippy Copper Racer
[45047]=62857,--Sandbox Tiger
--3.1.2
[45180]=63318,--Murkimus the Gladiator
--3.1.3
[46767]=65682,--Warbot
--3.2
[48112]=67413,--Darting Hatchling
[48116]=67415,--Gundrak Hatchling
[48118]=67416,--Leaping Hatchling
[48120]=67417,--Obsidian Hatchling
[48122]=67418,--Ravasaur Hatchling
[48124]=67419,--Razormaw Hatchling
[48126]=67420,--Razzashi Hatchling
[48114]=67414,--Deviate Hatchling
[46707]=44369,--Pint-Sized Pink Pachyderm
[46802]=66030,--Grunty
[46544]=65382,--Curious Wolvar Pup
[46545]=65381,--Curious Oracle Hatchling
[46820]=66096,--Shimmering Wyrmling
[46821]=66096,--Shimmering Wyrmling
[46396]=65353,--Wolvar Orphan Whistle
[46397]=65352,--Oracle Orphan Whistle
--3.2.2
[49362]=69002,--Onyxian Whelpling
[41133]=55068,--Mr. Chilly
[44810]=61773,--Plump Turkey
[49665]=69541,--Pandaren Monk
[49693]=69677,--Lil' K.T.
[46831]=66175,--Macabre Marionette
[49287]=68767,--Tuskarr Kite
[49343]=68810,--Spectral Tiger Cub
--3.3
[46398]=65358,--Calico Cat
[49646]=69452,--Core Hound Pup
[49912]=70613,--Perky Pug
[34518]=45174,--Golden Pig
[34519]=45175,--Silver Pig
[37298]=48408,--Essence of Competition
[22781]=28505,--Poley
[45047]=62857,--Sandbox Tiger
--3.3.2
[49662]=69535,--Gryphon Hatchling
[49663]=69536,--Wind Rider Cub
[50446]=71840,--Toxic Wasteling
--3.3.3
[53641]=74932,--Frigid Frostling
[54847]=75906,--Lil' XT
[54436]=75134,--Blue Clockwork Rocket Bot
--[54343]=75111,--Blue Crashin' Thrashin' Racer 
--3.3.5
[56806]=78381,--Mini Thor
--4.0.1
[63138]=89039,--Dark Phoenix Hatchling
[64403]=90637,--Fox Kit
[63398]=89670,--Armadillo Pup
[63355]=89472,--Rustberg Seagull
[64996]=89472,--Rustberg Seagull
[67128]=93624,--Landro's Lil' XT
[67418]=94070,--Deathy
[66076]=93739,--Mr. Grubbs
[65362]=92396,--Guild Page
[65363]=92397,--Guild Herald
[65364]=92398,--Guild Herald
[65661]=78683,--Blue Mini Jouster
[65662]=78685,--Gold Mini Jouster
[65361]=92395,--Guild Page
--4.0.3
[60955]=84752,--Fossilized Hatchling
[46892]=63318,--Murkimus the Gladiator
[49664]=69539,--Zipao Tiger
[62540]=87344,--Lil' Deathwing
[62769]=87863,--Eat the Egg
[48527]=67527,--Onyx Panther
[68385]=95787,--Lil' Ragnaros
[68618]=95786,--Moonkin Hatchling
[68619]=95909,--Moonkin Hatchling
[60847]=84263,--Crawling Claw
[66080]=93813,--Tiny Flamefly
[59597]=81937,--Personal World Destroyer
[60216]=82173,--De-Weaponized Mechanical Companion
[64372]=90523,--Clockwork Gnome
[67274]=93836,--Enchanted Lantern
[67308]=93836,--Enchanted Lantern(Recipe)
[67275]=93837,--Magic Lamp
[67312]=93837,--Magic Lamp(Recipe)
[67282]=93838,--Elementium Geode
[46325]=65046,--Withers
[60869]=84492,--Pebble
[64494]=91343,--Tiny Shale Spider
[66067]=93823,--Singing Sunflower
[66073]=93817,--Scooter the Snail
[54810]=75613,--Celestial Dragon
[46709]=65451,--MiniZep Controller
--4.0.6
[68673]=16450,--Smolderweb Hatchling
--4.1
[69991]=45082,--Tiny Sporebat
[69824]=98587,--Voodoo Figurine
[69821]=98571,--Pterrordax Hatchling
[68840]=96817,--Landro's Lichling
[68841]=96819,--Nightsaber Cub
[69648]=98079,--Legs
[69847]=98736,--Guardian Cub
[70099]=99578,--Cenarion Hatchling
[68833]=96571,--Panther Cub
[69239]=97638,--Winterspring Cub
[69992]=66096,--Shimmering Wyrmling
[69251]=97779,--Lashtail Hatchling
--4.2
[71033]=100576,--Lil' Tarecgosa
[72068]=98736,--Guardian Cub
[70908]=100330,--Feline Familiar
[71076]=100684,--Creepy Crate
[71726]=101606,--Murkablo
[70140]=99663,--Hyjal Bear Cub
[72045]=101989,--Horde Balloon
[71137]=100959,--Brewfest Keg Pony
[71140]=100970,--Nuts
[71387]=101424,--Brilliant Kaliri
[72042]=101986,--Alliance Balloon
[70160]=99668,--Crimson Lasher
--4.3
[73953]=103588,--Sea Pony
[71624]=101493,--Purple Puffer
[72153]=102353,--Sand Scarab
[73762]=103076,--Darkmoon Balloon
[73764]=101733,--Darkmoon Monkey
[73765]=103074,--Darkmoon Turtle
[73797]=103125,--Lumpy
[73903]=103544,--Darkmoon Tonk
[73905]=103549,--Darkmoon Zeppelin
[72134]=102317,--Gregarious Grell
[74981]=105122,--Darkmoon Cub
[76062]=105633,--Fetish Shaman
[78916]=110029,--Soul of the Aspects
[75040]=140218,--Flimsy Darkmoon Balloon
[75041]=105228,--Flimsy Green Balloon
[75042]=105229,--Flimsy Yellow Balloon
[74610]=104047,--Lunar Lantern
[74611]=104049,--Festival Lantern
[77158]=107926,--Darkmoon "Tiger"
--4.3.2
[79744]=112994,--Eye of the Legion
--5.0.1
[85513]=127813,--Thundering Serpent Hatchling
[87526]=126885,--Mechanical Pandaren Dragonling
[80008]=114090,--Darkmoon Rabbit
[85220]=123778,--Terrible Turnip
[85222]=123784,--Red Cricket
[85447]=124000,--Tiny Goldfish
[85578]=124152,--Feral Vermling
[85871]=124660,--Lucky Quilen Cub
[89587]=118414,--Porcupette
[89686]=130726,--Jade Tentacle
[89736]=130759,--Venus
[87567]=127006,--Food
[87568]=127008,--Food
[88148]=127816,--Jade Crane Chick
[82774]=120501,--Jade Owl
[90470]=120501,--Jade Owl(Recipe)
[82775]=120507,--Sapphire Cub
[90471]=120507,--Sapphire Cub(Recipe)
[86562]=126247,--Hopling
[86563]=126249,--Aqua Strider
[86564]=126251,--Grinder
[88147]=127815,--Singing Cricket
[84105]=122748,--Fishy
[89367]=127006,--Yu'lon Kite
[89368]=127008,--Chi-Ji Kite
[74622]=110955,--Fire Spirit
[89640]=130649,--Life Spirit
[89641]=130650,--Water Spirit
--5.0.4
[90897]=90637,--Fox Kit
[90898]=90637,--Fox Kit
[90173]=131590,--Pandaren Water Spirit
[90177]=131650,--Baneling
[90953]=132759,--Spectral Cub
[90953]=132759,--Spectral Cub
[90953]=132759,--Spectral Cub
--5.1
[90900]=132574,--Imperial Moth
[91040]=132789,--Darkmoon Eye
[92707]=134538,--Cinder Kitten
[92798]=134892,--Pandaren Fire Spirit
[92799]=134894,--Pandaren Air Spirit
[92800]=134895,--Pandaren Earth Spirit
[93031]=135256,--Mr. Bigglesworth
[90902]=132580,--Imperial Silkworm
[91031]=132785,--Darkmoon Glowfly
[91003]=132762,--Darkmoon Hatchling
[93029]=135257,--Stitched Pup
[93025]=135156,--Clock'em
[93032]=135255,--Fungal Abomination
[93033]=135258,--Harbinger of Flame
[93034]=135259,--Corefire Imp
[93035]=135261,--Ashstone Core
[93036]=135263,--Untamed Hatchling
[93037]=135265,--Death Talon Whelpguard
[93038]=135264,--Chrominius
[93039]=135266,--Viscidus Globule
[93040]=135267,--Anubisath Idol
[93041]=135268,--Mini Mindslayer
[93030]=135254,--Giant Bone Spider
[92959]=135009,--Darkmoon "Cougar"
[92968]=135025,--Darkmoon "Murloc"
[92969]=135026,--Darkmoon "Rocket"
[92956]=135007,--Darkmoon "Snow Leopard"
[92970]=135027,--Darkmoon "Wyvern"
[92966]=135022,--Darkmoon "Dragon"
[92958]=135008,--Darkmoon "Nightsaber"
[92967]=135023,--Darkmoon "Gryphon"
--5.2
[95422]=139932,--Zandalari Anklerender
[93669]=136484,--Gusting Grimoire
[94124]=138082,--Sunreaver Micro-Sentry
[94125]=137977,--Living Sandling
[94126]=138087,--Zandalari Kneebiter
[94152]=138161,--Son of Animus
[94190]=138285,--Spectral Porcupette
[94208]=138380,--Sunfur Panda
[94209]=138381,--Snowy Panda
[94210]=138382,--Mountain Panda
[94595]=138913,--Spawn of G'nathus
[94835]=139148,--Ji-Kun Hatchling
[94025]=137568,--Red Panda
[95423]=139933,--Zandalari Footslasher
[95424]=139934,--Zandalari Toenibbler
[95621]=65682,--Warbot
[94191]=138287,--Stunted Direhorn
[94573]=139153,--Direhorn Runt
[94574]=138825,--Pygmy Direhorn
[94903]=138824,--Pierre
[94932]=139361,--Tiny Red Carp
[94933]=139362,--Tiny Blue Carp
[94934]=139363,--Tiny Green Carp
[94935]=139365,--Tiny White Carp
--5.3
[98550]=142880,--Blossoming Ancient
[100870]=143637,--Murkimus Tyrannicus
[97821]=141789,--Gahz'rooki
[97548]=141433,--Lil' Bad Wolf
[97549]=141434,--Menagerie Custodian
[97550]=141435,--Netherspace Abyssal
[97551]=141451,--Fiendish Imp
[97552]=141436,--Tideskipper
[97961]=142030,--Filthling
[97554]=141446,--Coilfang Stalker
[97555]=141447,--Pocket Reaver
[97556]=141448,--Lesser Voidcaller
[97557]=141449,--Phoenix Hawk Hatchling
[97558]=141450,--Tito
[97959]=142028,--Living Fluid
[97960]=142029,--Viscous Horror
[97553]=141437,--Tainted Waveling
--5.4
[101570]=144761,--Moon Moon
[104317]=148567,--Rotten Little Helper
[100905]=143703,--Rascal-Bot
[101771]=145696,--Xu-Fu, Cub of Xuen
[102145]=145697,--Chi-Chi, Hatchling of Chi-Ji
[102146]=145699,--Zao, Calfling of Niuzao
[102147]=145698,--Yu'la, Broodling of Yu'lon
[103637]=148427,--Vengeful Porcupette
[103670]=147124,--Lil' Bling
[104156]=148046,--Ashleaft Spriteling
[104157]=148047,--Azure Crane Chick
[104158]=148049,--Blackfuse Bombling
[104159]=148050,--Ruby Droplet
[104160]=148051,--Dandelion Frolicker
[104162]=148058,--Droplet of Y'Shaarj
[104163]=148059,--Gooey Sha-ling
[104164]=148060,--Jademist Dancer
[104165]=148061,--Kovok
[104166]=148062,--Ominous Flame
[104167]=148063,--Skunky Alemental
[104168]=148066,--Spineclaw Crab
[104169]=148067,--Gulp Froglet
[104202]=148373,--Bonkers
[104291]=148527,--Gu'chi Swarmling
[104295]=148530,--Harmonious Porcupette
[104307]=148552,--Jadefire Spirit
[104332]=148684,--Sky Lantern
[104333]=148684,--Flimsy Sky Lantern
[104161]=148052,--Death Adder Hatchling
--5.4.1
[106240]=149787,--Alterac Brew-Pup
[106244]=149792,--Murkalot
--5.4.2
[106256]=149810,--Treasure Goblin
[108438]=154165,--Moonkin Hatchling
--[104318]=148577,--Crashin' Thrashin' Flyer
--5.4.7
[109014]=155748,--Dread Hatchling
}

--Spell Name data table--
ModelPique_SpellName_Table = {
--2.4.3
--[49352]="Crashin' Thrashin' Racer",
--3.2
[65353]="Wolvar Orphan",
[65352]="Oracle Orphan",
--3.3.3
--[75111]="Blue Crashin' Thrashin' Racer",
--4.0.3
[65451]="MiniZep",
--4.3
[107926]='Darkmoon "Tiger"',
--5.1
[135009]='Darkmoon "Cougar"',
[135025]='Darkmoon "Murloc"',
[135026]='Darkmoon "Rocket"',
[135007]='Darkmoon "Snow Leopard"',
[135027]='Darkmoon "Wyvern"',
[135022]='Darkmoon "Dragon"',
[135008]='Darkmoon "Nightsaber"',
[135023]='Darkmoon "Gryphon"',
--5.4
--[148577]="Crashin' Thrashin' Flyer",
}

--Camera data table--
ModelPique_Camera_Table = {
[27829]={["X"]=0,["Y"]=0,["Z"]=1.3,["S"]=0.3},
[48858]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.4},
[29060]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[28811]={["X"]=0,["Y"]=0,["Z"]=0.9,["S"]=1},
[11641]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[27242]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.6},
[40590]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[41991]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[51502]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[29259]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[48213]={["X"]=5,["Y"]=0,["Z"]=0,["S"]=0.6},
[48020]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[51269]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.9},
[46922]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.6},
[48211]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.6},
[46909]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.7},
[45264]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.4},
[4185]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.4},
[34955]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[24757]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[37154]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[20042]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.2},
[28556]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[12245]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[16943]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.4},
[27239]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[51591]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.7},
[38229]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.4},
[27248]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.6},
[28063]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[14778]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.7},
[10269]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[46925]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[41989]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[48212]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.5},
[45271]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.6},
[35750]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[38134]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[2177]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[40029]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.3},
[14348]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[42721]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[12246]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[12242]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[45195]={["X"]=0,["Y"]=0,["Z"]=0.3,["S"]=0.5},
[28435]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[21381]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.7},
[39319]={["X"]=0,["Y"]=0,["Z"]=0.9,["S"]=1},
[9905]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.6},
[53774]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.7},
[14579]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[21382]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.6},
[35757]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.7},
[51484]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[44635]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[28082]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[24758]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[41592]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[45987]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[4732]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.4},
[27245]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.2},
[43689]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[37541]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.6},
[48100]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[45521]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[40521]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[48101]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[45520]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[48855]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[46171]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[35755]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.7},
[45522]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[43562]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[30462]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[30346]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[28060]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.6},
[46087]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[42147]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[44655]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.7},
[47981]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[20996]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.7},
[25835]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[39563]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[28948]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[47716]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[35553]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[47983]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[37231]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[47715]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[44633]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[47959]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[25836]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[47955]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[47718]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[47597]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[47717]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[35754]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[47958]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[47976]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[39332]={["X"]=0,["Y"]=0,["Z"]=0.6,["S"]=1.2},
[47960]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[48661]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[51361]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[45797]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[51360]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[39330]={["X"]=0,["Y"]=0,["Z"]=0.6,["S"]=1.2},
[28063]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.6},
[27240]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[25833]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[27246]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[27785]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[51359]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[14349]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[34956]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[24393]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[27247]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[43693]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[39331]={["X"]=0,["Y"]=0,["Z"]=0.6,["S"]=1.2},
[51484]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[47256]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.6},
[27238]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[41903]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.7},
[51488]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[47238]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=0.8},
[27244]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[27237]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[41990]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[28217]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[24620]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[43692]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[14578]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[35551]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[40568]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.8},
[43686]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[43695]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[43697]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1},
[36583]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
[55907]={["X"]=0,["Y"]=0,["Z"]=0,["S"]=1.5},
}