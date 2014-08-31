local RaresTip = CreateFrame('GameTooltip', 'RaresTip', UIParent, 'GameTooltipTemplate')

-- I'm aware this needs some cleanup
local rares = {
[50750] = { "Aethis", 87649 },
[50817] = { "Ahone the Wanderer", 86588 },
[50821] = { "Ai-Li Skymirror", 86589 },
[50822] = { "Ai-Ran the Shifting Cloud", 86590 },
[50787] = { "Arness the Scale", 90723 },
[51059] = { "Blackhoof", 86565 },
[50828] = { "Bonobos", 86591 },
[50341] = { "Borginn Darkfist", 86570 },
[50768] = { "Cournith Waterstrider", 90721 },
[50334] = { "Dak the Breaker", 86567 },
[50772] = { "Eshelon", 87222 },
[51078] = { "Ferdinand", 87652 },
[50340] = { "Gaarn the Toxic", 90725 },
[50739] = { "Gar'lok", 86578 },
[50331] = { "Go-Kan", 90719 },
[50354] = { "Havak", 86573 },
[50836] = { "Ik-Ik the Nimble", 86593 },
[50351] = { "Jonn-Dar", 86572 },
[50355] = { "Kah'tir", 87218 },
[50749] = { "Kal'tik the Blight", 86579 },
[50349] = { "Kang the Soul Thief", 86571 },
[50347] = { "Karr the Darkener", 86564 },
[50332] = { "Korda Torros", 86566 },
[50338] = { "Kor'nas Nightsavage", 87642 },
[50363] = { "Krax'ik", 87646 },
[50356] = { "Krol the Blade", 86574 },
[50734] = { "Lith'ik the Stalker", 87221 },
[50333] = { "Lon the Bull", 87219 },
[50840] = { "Major Nanners", 86594 },
[50823] = { "Mister Ferocious", 87652 },
[50806] = { "Moldo One-Eye", 86586 },
[50350] = { "Morgrinn Crackfang", 87643 },
[50776] = { "Nalash Verdantis", 86563 },
[50364] = { "Nal'lak the Ripper", 86576 },
[50811] = { "Nasra Spothide", 86587 },
[50789] = { "Nessos the Oracle", 86584 },
[50344] = { "Norlaxx", 87220 },
[50805] = { "Omnis Grinlok", 86585 },
[50352] = { "Qu'nas", 90717 },
[50816] = { "Ruun Ghostpaw", 90720 },
[50780] = { "Sahn Tidehunter", 86582 },
[50783] = { "Salyin Warscout", 86583 },
[50782] = { "Sarnak", 87650 },
[50831] = { "Scritch", 86592 },
[50766] = { "Sele'na", 86580 },
[50791] = { "Siltriss the Sharpener", 87223 },
[50733] = { "Ski'thik", 86577 },
[50830] = { "Spriggin", 90724 },
[50339] = { "Sulik'shor", 86569 },
[50832] = { "The Yowler", 87225 },
[50388] = { "Torik-Ethis", 90718 },
[50359] = { "Urgolax", 86575 },
[50808] = { "Urobi the Walker", 87651 },
[50336] = { "Yorik Sharpeye", 86568 },
[50820] = { "Yul Wildpaw", 87224 },
[50769] = { "Zai the Outcast", 86581 },
-- 5.2 Isle of Thunder Rares
[50358] = { "Haywire Sunreaver Construct", 94124 },
[70530] = { "Ra'sha", 95566 },
[69347] = { "Incomplete Drakkari Colossus", 94823 },
[69767] = { "Ancient Mogu Guardian", 94826 },
[69339] = { "Electromancer Ju'le", 94825 },
[69471] = { "Spirit of Warlord Teng", 94707 },
[70080] = { "Windweaver Akil'amon", 94709 },
[69633] = { "Kor'dok", 94720 },
[69749] = { "Qi'nor", 94824 },
[69396] = { "Cera", 94706 },
[69341] = { "Echo of Kros", 94708 },
-- 5.2 Warbringers and their mounts
[69769] = { "Zandalari Warbringer (Slate)", 94229 },
[69841] = { "Zandalari Warbringer (Amber)", 94230 },
[69842] = { "Zandalari Warbringer (Jade)", 94231 },
-- other MoP NPCs/Rares
[65003] = { "Martar the Not-So-Smart", 87780 },
[66281] = { "Fixxul Lonelyheart", 90078 },
[66911] = { "Lorbu Sadsummon ", 90078 },
[66900] = { "Huggalon the Heart Watcher", 90067 },
[58883] = { "Feverbite", 89365 },
[66464] = { "Zhing", 89697 },
[66587] = { "Pengsong", 89770 },
[58895] = { "Sungraze Behemoth", 89682 },
[61848] = { "Wild Onyx Serpent", 93360 },
[66162] = { "Scotty", 89373 },
[64403] = { "Alani", 90655 },
[62767] = { "Gokk'lok", 88417 },
[66467] = { "G'nathus", 94595 },
--Battered Hilt droppers
--[36788] = { "", 50380 },[37712] = { "", 50380 },[37713] = { "", 50380 },[36723] = { "", 50380 },[36886] = { "", 50380 },[38175] = { "", 50380 },[37711] = { "", 50380 },[36891] = { "", 50380 },[38172] = { "", 50380 },[36879] = { "", 50380 },[38177] = { "", 50380 },[36522] = { "", 50380 },[36620] = { "", 50380 },[36516] = { "", 50380 },[36564] = { "", 50380 },[36499] = { "", 50380 },[36478] = { "", 50380 },[38173] = { "", 50380 },[36666] = { "", 50380 },[36896] = { "", 50380 },[38176] = { "", 50380 },[36842] = { "", 50380 },[36830] = { "", 50380 },[36892] = { "", 50380 },[36893] = { "", 50380 },[31260] = { "", 50380 },[36840] = { "", 50380 },
-- Thunderfury Bindings
[12056] = { "Baron Geddon", 18563 },
[12057] = { "Garr", 18564 },
-- 5.4 Timeless Isle Rares
[71920] = { "Cursed Hozen Swabby", 104015 },
[72193] = { "Karkanos", 104035 },
[72875] = { "Ordon Candlekeeper", 86565 },
[72895] = { "Burning Berserker", 86566 },
[72777] = { "Gulp Frog", 86580 },
[73021] = { "Spectral Windwalker", 104336 },
[73025] = { "Spectral Mistweaver", 104334 },
[72898] = { "High Priest of Ordos", 104329 },
[72048] = { "Rattleskew", 104321 },
[73157] = { "Rock Moss", 104313 },
[72896] = { "Eternal Kilnmaster", 104309 },
[73173] = { "Urdur the Cauterizer", 104306 },
[72897] = { "Blazebound Chanter", 104304 },
[73171] = { "Champion of the Black Flame", 104302 },
[73172] = { "Flintlord Gairan", 104298 },
[72894] = { "Ordon Fire-Watcher", 104296 }, -- actually dropped by other NPCs as well, including two Rares, see 104296#dropped-by - the Ordon Fire-Watcher was just the only one without another unique drop
[72766] = { "Ancient Spineclaw", 104293 },
[72909] = { "Gu'chi the Swarmbringer", 104291 },
[72877] = { "Ashleaf Sprite", 104289 },
[73158] = { "Emerald Gander", 104287 },
[72762] = { "Brilliant Windfeather", 104287 },
[73277] = { "Leafmender", 104156 },
[73167] = { "Huolon", 104269 },
[72970] = { "Golganarr", 104262 },
[72809] = { "Eroded Cliffdweller", 104262 },
[72007] = { "Master Kukuru (pet drops in chests opened with keys sold by NPC)", 104202 },
[73166] = { "Monstrous Spineclaw", 104168 },
[73162] = { "Foreboding Flame", 104166 },
[73163] = { "Imperial Python", 104161 },
[73282] = { "Garnia", 104159 },
[73166] = { "Monstrous Spineclaw", 104168 },
[72892] = { "Ordon Oathguard", 104330 },
[73666] = { "Archiereus of Flame (summoned)", 86574 },
[73174] = { "Archiereus of Flame", 86574 },
[73161] = { "Great Turtle Furyshell", 86584 },
[72045] = { "Chelon", 86584 },
[73018] = { "Spectral Brewmaster", 104335 },
[73169] = { "Jakur of Ordon", 104331 },
[72888] = { "Molten Guardian", 104328 },
[71864] = { "Spelurk", 104320 },
[72771] = { "Damp Shambler", 104312 },
[72769] = { "Spirit of Jadefire", 104307 },
[73170] = { "Watcher Osu", 104305 },
[72245] = { "Zesqua", 104303 },
[73175] = { "Cinderfall", 104299 },
[73281] = { "Dread Ship Vazuvius", 104294 },
[72841] = { "Death Adder", 104292 },
[72908] = { "Spotted Swarmer", 104290 },
[72876] = { "Quivering Firestorm Egg", 104286 },
[72049] = { "Cranegnasher", 104268 },
[72808] = { "Tsavo'ka", 104268 },
[72805] = { "Primal Stalker", 104268 },
[72775] = { "Bufo", 104169 },
[71919] = { "Zhu-Gon the Sour", 104167 },
[72767] = { "Jademist Dancer", 104164 },
--[72767] = { "        Jademist Dancer", 104288 }, -- less interesting than the pet

-- misc
[32491] = { "Time-Lost Proto-Drake", 44168 },

--[] = { "",  },

}

-- this method used in the following functions is derived from SymbiosisTip by Wildbreath
-- http://www.wowinterface.com/downloads/info21405-SymbiosisTip.html

GameTooltip:HookScript('OnTooltipSetUnit', function(self)

    if not UnitExists("mouseover")  then RaresTip:Hide() return end

    local id = tonumber(UnitGUID("mouseover"):sub(6,10), 16)

    if not rares[id] then RaresTip:Hide() return end

--    print("S",rares[id][1])
    local itemID = rares[id][2]
--    print("I",itemID)
    GetItemInfo(itemID)
    RaresTip:SetOwner(self, "ANCHOR_TOP")
    RaresTip:SetItemByID(itemID)
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
    if icon then
       _G['RaresTipTextLeft1']:SetText('|T'..icon..':22|t '..name..'            |cffaee623[RaresTip]|r')
    end
    RaresTip:Show()

end)

-- sigh, this somehow doesn't work
GameTooltip:HookScript("OnShow", function(self)

    if not UnitExists("mouseover")  then RaresTip:Hide() return end

    RaresTip:SetWidth(math.max(self:GetWidth(), RaresTip:GetWidth()))
    self:SetWidth(math.max(self:GetWidth(), RaresTip:GetWidth()))

end)

GameTooltip:HookScript("OnHide", function(self) RaresTip:Hide() end)

hooksecurefunc(GameTooltip, "FadeOut", function(self) RaresTip:FadeOut() end)


-- -- the effects of the following should be tested extensively before it's added to live code
--for _,v in ipairs(rares) do
--   GetItemInfo(v[2])
--end