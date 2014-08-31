--[[
	Simplified Chinese localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/zhCN/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the Simplified Chinese localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "zhCN", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "Timeless Answers已经加载"
L["ANSWER_FOUND"] = "cFF00FF00查询答案:|r 选项 %d. %s"
L["ANSWER_NOT_FOUND"] = "答案 %q 未在问题 %q 的选项中发现。"
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r |cFFFF0000错误:|r %s"
L["IN_RAID"] = "任务不能同时在一个团队来完成。" -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r %s"
L["QUESTION_FOUND"] = "|cFF00FF00查询题目:|r %s"
L["QUESTION_NOT_FOUND"] = "问题 %q 未找到。"


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "那就让我们来测试一下你的历史知识吧！"
L["That is correct!"] = "答对了！"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "答对了！阿尔萨斯用来训练死亡骑士，后来又由于大部分死亡骑士背叛巫妖王而被占领的浮空堡垒叫什么名字？"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "答对了！在撕心狼变成狼人之前，他也曾有过家室。他的妻子叫什么名字？"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "答对了！在被阿尔萨斯复活为亡灵，并加入天灾军团之前，辛达苟萨曾属于哪个巨龙军团？"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "答对了！在最初的部落建立之前，有一种高传染性的病毒在兽人间快速传播。兽人们称这种病为什么？"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "答对了！在第三次大战过去数年之后，黑暗之门重新开启时，艾泽拉斯首次出现了棕色皮肤的兽人，这些兽人被称为什么？"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "答对了！有一位德莱尼人，他曾是一个健康的圣骑士，但在与燃烧军团作战时，他身染恶疾，变成了破碎者。后来，他成了一个强大的萨满。这个德莱尼人是谁？"
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "答对了！在牛头人的语言中，lar'korwi是什么意思？"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "答对了！在突袭冰冠堡垒时，部落军队无耻地偷袭正与天灾军团激战的联盟士兵，并试图占领的那座城门叫什么名字？"
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "答对了！由玛法里奥·怒风协助建立的，艾泽拉斯最主要的德鲁伊组织叫什么名字？"
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "答对了！虚灵的家乡叫什么名字？"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "答对了！隶属于万神精锐的泰坦知识守护者叫什么名字？"
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "答对了！不久之前，一个脆弱的赞达拉巨魔想要驯服一头恐角龙。虽然他登上了巨兽岛，却在任务过程中遇害。请问这个巨魔叫什么名字？"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "答对了！头衔中包含“夜晚之友”的是哪位神灵？"
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "答对了！魅魔热衷于制造痛苦，她们在燃烧军团中专门负责进行可怕的拷问工作。请问魅魔属于哪个品种的恶魔？"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "答对了！告诉我，英雄，亡灵鱼人被称作什么？"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "答对了！大领主库德兰·蛮锤最近痛失爱将，他英勇的狮鹫在一次大火中不幸丧生。这头狮鹫叫什么名字？"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "答对了！根据德莱尼人的玩笑，“埃索达”在纳鲁语中是什么意思？"
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "答对了！铁炉堡图书馆中展出了一具巨型山羊的骨架复制品。这头传奇山羊叫什么名字？"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "答对了！一位血色十字军保卫者在刺杀恐惧魔王贝塞利斯时遇害，她叫什么名字？"
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "答对了！嫌弃银月城过于明亮和干净的部落大使叫什么名字？"
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "答对了！由地精制造，原计划搭载萨尔和阿格娜前往大漩涡，却被联盟意外摧毁的部落舰船叫什么名字？"
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "答对了！有一位王后，在大灾变和遗忘者袭击她的国度时，她井井有条地安排了人民的疏散工作。这位王后叫什么名字？"
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "答对了！赞加沼泽有一个地方，那里为纳迦所控制，他们还试图在那里抽取一种珍贵而稀有的资源：外域之水。这个地方叫什么名字？"
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "答对了！在上古之战后，守护巨龙们给了暗夜精灵什么东西？"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "答对了！在第三次大战期间，是什么证据促使阿尔萨斯王子屠杀了斯坦索姆的居民？"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "答对了！德鲁伊的最高称号是什么？"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "答对了！提里奥·弗丁的灰色公马叫什么名字？"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "答对了！下列哪句话是龙语中“谢谢你”的意思？"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "答对了！瓦里安·乌瑞恩国王的第一任妻子的正确名字是什么？"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "答对了！在担任家庭教师期间，斯塔文·密斯特曼托爱上了自己的学生，一个名叫蒂罗亚的年轻姑娘。请问她的弟弟叫什么名字？"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "答对了！白狼曾是哪个兽人氏族最喜爱的坐骑？"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "答对了！侏儒如今的领袖是谁？"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "答对了！下列哪一位的墓志铭上刻有“愿血染的王冠永远被遗失和忘却”这句话？"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "答对了！艾泽拉斯出现的第一个死亡骑士是谁？"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "答对了！这个世界上的第一个萨特是谁？"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "答对了！不久之前，一个脆弱的赞达拉巨魔想要驯服一头恐角龙。虽然他登上了巨兽岛，却在任务过程中遇害。请问这个巨魔叫什么名字？"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "答对了！在黑曜石圣殿守护暮光龙蛋的三头暮光幼龙分别叫什么？"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = "阿彻鲁斯。"
L["Archdruid."] = "大德鲁伊。"
L["Belan shi."] = true
L["Blue dragonflight."] = "蓝龙军团。"
L["Calissa Harrington."] = "卡莉莎·哈林顿。"
L["Cenarion Circle."] = "塞纳里奥议会。"
L["Coilfang Reservoir."] = "盘牙水库。"
L["Defective elekk turd."] = "残次的雷象粪便。"
L["Draka's Fury."] = "德拉卡的狂怒。"
L["Frostwolf clan."] = "霜狼氏族。"
L["Gelbin Mekkatorque."] = "格尔宾·梅卡托克。"
L["Giles."] = "基尔斯。"
L["Holia Sunshield."] = "霍利亚·萨希尔德。"
L["K'aresh."] = "卡雷什。"
L["King Terenas Menethil II."] = "泰瑞纳斯·米奈希尔二世国王。"
L["Mag'har."] = "玛格汉兽人。"
L["Mirador."] = "米拉多尔。"
L["Mord'rethar."] = "莫德雷萨。"
L["Mueh'zala."] = "缪萨拉。"
L["Mur'ghouls."] = "行尸鱼人。"
L["Nobundo."] = "努波顿。"
L["Nordrassil."] = "诺达希尔。"
L["Norgannon."] = "诺甘农。"
L["Queen Mia Greymane."] = "米亚·格雷迈恩王后。"
L["Red pox."] = "红色天灾。"
L["Sayaad."] = "萨亚德。"
L["Sharp claw."] = "锋利的爪子。"
L["Sky'ree."] = "斯卡雷。"
L["Tainted grain."] = "被污染的粮食。"
L["Talak."] = "塔拉克。"
L["Tatai."] = "塔泰。"
L["Tenebron, Vesperon, and Shadron."] = "塔尼布隆、维斯匹隆和沙德隆。"
L["Teron Gorefiend."] = "塔隆·血魔。"
L["Tiffin Ellerian Wrynn."] = "蒂芬·艾莉安·乌瑞恩。"
L["Toothgnasher."] = "磨齿。"
L["Veranus."] = "维拉努斯。"
L["Xavius."] = "萨维斯。"

