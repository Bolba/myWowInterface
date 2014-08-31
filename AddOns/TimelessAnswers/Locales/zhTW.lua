--[[
	Traditional Chinese localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/zhTW/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the Traditional Chinese localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "zhTW", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "載入Timeless Answers。"
L["ANSWER_FOUND"] = "|cFF00FF00答案:|r 選項 %d. %s"
L["ANSWER_NOT_FOUND"] = "答案「%s」並未在問題「%s」的選項中發現。"
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r |cFFFF0000錯誤:|r %s"
L["IN_RAID"] = "任務不能同時在一個團隊來完成。" -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r %s"
L["QUESTION_FOUND"] = "|cFF00FF00問題:|r %s"
L["QUESTION_NOT_FOUND"] = "問題「%s」未發現。"


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "那就讓我們來測試你的歷史知識吧!"
L["That is correct!"] = "正確！"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "那就讓我們來測試你的歷史知識吧!阿薩斯的死亡騎士是在一個飄浮的堡壘訓練而成，該堡壘在他們對巫妖王的叛亂中被武力攻下。這個堡壘的名稱是什麼?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "那就讓我們來測試你的歷史知識吧!在利普斯納爾變成狼人之前，他原本也有自己的家庭。他的妻子叫什麼名字?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "那就讓我們來測試你的歷史知識吧!在被阿薩斯復活以聽命於天譴軍團之前，辛德拉苟莎曾屬於哪個龍族軍團？"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "那就讓我們來測試你的歷史知識吧!在原本的部落成立前，一種傳染性極高的疾病在獸人中快速流傳。獸人們稱呼它為什麼?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "那就讓我們來測試你的歷史知識吧!棕色皮膚的獸人首度出現在艾澤拉斯，是第三次大戰的數年後，黑暗之門再度被開啟的時候。這些獸人叫什麼？"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "那就讓我們來測試你的歷史知識吧!原本是一位健康的聖騎士，這位德萊尼在與燃燒軍團作戰時生了病，並成為破碎者之一。他後來成為一位強大的薩滿。"
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "那就讓我們來測試你的歷史知識吧!在牛頭人語中，拉克維代表什麼意思？"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "那就讓我們來測試你的歷史知識吧!在攻擊寒冰皇冠的戰役中，部落的軍隊罔顧榮耀攻擊了聯盟正在與天譴軍團作戰並嘗試攻下這座門的聯盟士兵。"
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "那就讓我們來測試你的歷史知識吧!由瑪法里恩·怒風協助創立的，最早的艾澤拉斯德魯伊組織是哪一個？"
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "那就讓我們來測試你的歷史知識吧!以太族的家鄉在哪裡?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "那就讓我們來測試你的歷史知識吧!哪一位萬神殿的成員是該組織的博識者?"
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "那就讓我們來測試你的歷史知識吧!不久以前，有個脆弱的贊達拉食人妖想要馴服一隻恐角龍。雖然他遠赴巨獸島，卻在旅途中喪生。他的名字是？"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "那就讓我們來測試你的歷史知識吧!這個羅亞的其中一個名字是「夜晚之友」。"
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "那就讓我們來測試你的歷史知識吧!魅魔以製造苦痛為樂，並聽命於軍團，施行惡夢般的審訊。魅魔屬於哪個種族？"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "我們來測驗一下歷史知識吧!告訴我，英雄，不死魚人叫什麼？"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "那就讓我們來測試你的歷史知識吧!庫德蘭·蠻錘族長最近承受了悲劇性的損失，他英勇的獅鷲獸被火燒死了。這頭獅鷲獸的名字叫什麼?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "那就讓我們來測試你的歷史知識吧!德萊尼喜歡開玩笑說，用那魯的語言來講，艾克索達有這個意思。"
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "那就讓我們來測試你的歷史知識吧!鐵爐堡的圖書館有著一個巨大公羊的骷髏仿製品。這隻傳說中的公羊叫什麼?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "那就讓我們來測試你的歷史知識吧!這位血色十字軍在刺殺驚懼領主貝塞利斯時犧牲了。"
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "那就讓我們來測試你的歷史知識吧!覺得銀月城有點太過明亮乾淨的部落使者是哪位？"
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "那就讓我們來測試你的歷史知識吧!這艘部落的船是由哥布林所製造。原本是要帶索爾及阿格拉前往大漩渦，但在聯盟的突襲之下被摧毀了。"
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "那就讓我們來測試你的歷史知識吧!這位女王在大災變發生，及被遺忘者攻擊她的王國後疏散了她的子民。"
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "那就讓我們來測試你的歷史知識吧!有一棟建築物，在贊格沼澤，被納迦所控制，想要抽取一種珍貴的資源:外域的水源。"
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "那就讓我們來測試你的歷史知識吧!守護巨龍在先祖之戰過後給了夜精靈什麼東西?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "那就讓我們來測試你的歷史知識吧!在第三次大戰中，阿薩斯王子得到了什麼證據，促使他屠殺斯坦索姆的人民?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "那就讓我們來測試你的歷史知識吧!德魯伊被授予的最高階級是什麼？"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "那就讓我們來測試你的歷史知識吧!提里奧·弗丁的灰馬叫什麼名字?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "那就讓我們來測試你的歷史知識吧!在龍的語言中，哪一句是「謝謝你」?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "那就讓我們來測試你的歷史知識吧!瓦里安·烏瑞恩國王的第一任妻子，正確的名字是哪個?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "那就讓我們來測試你的歷史知識吧!斯塔文·密斯特曼托在身為導師時，瘋狂愛上了他的一個學生，一個年輕的女人名叫蒂羅亞。她的弟弟叫什麼名字?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "那就讓我們來測試你的歷史知識吧!白狼曾經是哪個獸人氏族鍾愛的坐騎？"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "那就讓我們來測試你的歷史知識吧!現任的地精領袖是誰？"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "那就讓我們來測試你的歷史知識吧!是誰的墓地上有刻著這麼一段話:「願血染的王冠永遠被遺失和忘卻」?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "那就讓我們來測試你的歷史知識吧!誰是艾澤拉斯第一位被創造的死亡騎士?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "那就讓我們來測試你的歷史知識吧!誰是第一個被創造出來的薩特?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "那就讓我們來測試你的歷史知識吧!被洛肯捕捉並轉化為銳鱗的強大元龍叫什麼名字?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "那就讓我們來測試你的歷史知識吧!是哪三隻年輕的暮光飛龍在黑曜聖所守護著暮光飛龍的蛋?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = "亞榭洛。"
L["Archdruid."] = "大德魯伊。"
L["Belan shi."] = "貝拉許。"
L["Blue dragonflight."] = "藍龍軍團。"
L["Calissa Harrington."] = "凱莉莎‧哈林頓。"
L["Cenarion Circle."] = "塞納里奧議會。"
L["Coilfang Reservoir."] = "盤牙蓄湖。"
L["Defective elekk turd."] = "殘缺的伊萊克糞便。"
L["Draka's Fury."] = "德拉卡之怒。"
L["Frostwolf clan."] = "霜狼氏族。"
L["Gelbin Mekkatorque."] = "傑爾賓‧梅卡托克。"
L["Giles."] = "基爾斯。"
L["Holia Sunshield."] = "霍利亞‧桑希爾德。"
L["K'aresh."] = "凱瑞西。"
L["King Terenas Menethil II."] = "泰瑞納斯‧米奈希爾二世。"
L["Mag'har."] = "瑪格哈。"
L["Mirador."] = "米拉多爾。"
L["Mord'rethar."] = "默德雷薩。"
L["Mueh'zala."] = "繆薩拉。"
L["Mur'ghouls."] = "屍化魚人。"
L["Nobundo."] = "諾柏多。"
L["Nordrassil."] = "諾達希爾。"
L["Norgannon."] = "諾甘農。"
L["Queen Mia Greymane."] = "米雅‧葛雷邁恩皇后。"
L["Red pox."] = "紅疹。"
L["Sayaad."] = "薩亞德。"
L["Sharp claw."] = "鋒利的爪子。"
L["Sky'ree."] = "史蓋瑞。"
L["Tainted grain."] = "受汙染的穀物。"
L["Talak."] = "塔拉科。"
L["Tatai."] = "塔泰。"
L["Tenebron, Vesperon, and Shadron."] = "坦納伯朗、維斯佩朗和夏德朗。"
L["Teron Gorefiend."] = "泰朗‧血魔。"
L["Tiffin Ellerian Wrynn."] = "蒂芬‧艾蕾瑞安‧烏瑞恩。"
L["Toothgnasher."] = "磨齒羊。"
L["Veranus."] = "維拉努斯。"
L["Xavius."] = "薩維斯。"

