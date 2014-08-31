--[[
	Russian localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/ruRU/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the Russian localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "ruRU", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "Timeless ответы загружено." -- Needs review
L["ANSWER_FOUND"] = "|cFF00FF00Найдено Ответ:|r выбор %d. %s" -- Needs review
L["ANSWER_NOT_FOUND"] = "Ответ %q для вопроса %q не найден в настройках сплетни." -- Needs review
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00Tо -|r |cFFFF0000ошибка:|r %s" -- Needs review
L["IN_RAID"] = "Квест не может быть завершена, а в рейде." -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00Tо -|r %s" -- Needs review
L["QUESTION_FOUND"] = "|cFF00FF00Найдено Вопрос:|r %s" -- Needs review
L["QUESTION_NOT_FOUND"] = "Вопрос от %q не найден." -- Needs review


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "Давай проверим, знаешь ли ты историю! "
L["That is correct!"] = "Правильно!"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "Давай проверим, знаешь ли ты историю! Рыцари смерти Артаса обучались в летучей цитадели, которую они потом захватили, восстав против Короля-лича. Как называется эта крепость?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "Давай проверим, знаешь ли ты историю! Прежде чем Терзающий Рев стал воргеном, у него была семья. Как звали его жену?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "Давай проверим, знаешь ли ты историю! К роду каких драконов принадлежала Синдрагоса, прежде чем Артас превратил ее в нежить и заставил служить Плети?"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "Давай проверим, знаешь ли ты историю! Еще до того, как была создана Орда, среди орков стремительно распространилась болезнь. Как орки назвали ее?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "Давай проверим, знаешь ли ты историю! Через некоторое время после окончания Третьей войны, когда вновь открылся Темный портал, в Азероте стали появляться орки с коричневой кожей. Как назывались эти орки?"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "Давай проверим, знаешь ли ты историю! Этот дреней, некогда здоровый и полный сил паладин, серьезно заболел после битв с Пылающим Легионом и пополнил ряды Сломленных. Впоследствии он стал могущественным шаманом."
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "Давай проверим, знаешь ли ты историю! Что означает \"лар'корви\" в переводе с таурахе, языка тауренов?"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "Давай проверим, знаешь ли ты историю! Во время штурма Ледяной Короны воины Орды предательски напали на солдат Альянса, пытавшихся одолеть силы Плети и захватить ворота. Как назывались эти ворота?"
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "Давай проверим, знаешь ли ты историю! Основателем этого общества друидов, которое сейчас главное в Азероте, был Малфурион Ярость Бури."
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "Давай проверим, знаешь ли ты историю! Как называется родной мир эфириалов?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "Давай проверим, знаешь ли ты историю! Назовите имя хранителя знаний титанов, включенного в особый Пантеон."
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "Давай проверим, знаешь ли ты историю! Не так давно этот слабый зандаларский тролль намеревался укротить дикорога. Хотя ему удалось добраться до Острова Великанов, там его настигла смерть. Как звали этого тролля?"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "Давай проверим, знаешь ли ты историю! Этого лоа называют Другом ночи."
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "Давай проверим, знаешь ли ты историю! Демоны-суккубы Пылающего Легиона обожают причинять другим страдания, истязая жертв во время допросов. К какой расе принадлежат суккубы?"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "Давай проверим, знаешь ли ты историю! Скажи, герой, как зовут мурлоков, ставших нежитью?"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "Давай проверим, знаешь ли ты историю! Тан Курдран Громовой Молот недавно пережил тяжелую утрату: его грифон погиб при пожаре. Как звали этого грифона?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "\"Давай проверим, знаешь ли ты историю! Дренеи часто шутят, что на языке наару Экзодар означает именно это."
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "Давай проверим, знаешь ли ты историю! В библиотеке Стальгорна хранится копия скелета чрезвычайно большого барана. Как звали это легендарное животное?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "Давай проверим, знаешь ли ты историю! Как звали члена Алого ордена, погибшего в момент победы над повелителем ужаса Белтерисом?"
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "Давай проверим, знаешь ли ты историю! Как звали посланника Орды, считавшего, что в Луносвете слишком светло и чисто?"
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "Давай проверим, знаешь ли ты историю! Этот корабль Орды построили гоблины. Изначально планировалось, что Аггра и Тралл доберутся на нем до Водоворота, но корабль был уничтожен в результате внезапной атаки Альянса."
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "Давай проверим, знаешь ли ты историю! Эта королева приказала эвакуировать своих подданных после того, как настал Катаклизм и Отрекшиеся напали на ее владения."
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "Давай проверим, знаешь ли ты историю! Наги захватили эту постройку, расположенную в Зангартопи, и с помощью нее выкачивали воду Запределья, которой и так немного."
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "Давай проверим, знаешь ли ты историю! Что Аспекты подарили ночным эльфам после Войны древних?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "Давай проверим, знаешь ли ты историю! Какое доказательство заставило принца Артаса устроить резню в Стратхольме во время Третьей войны?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "Давай проверим, знаешь ли ты историю! Каково высшее звание для друида?"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "Давай проверим, знаешь ли ты историю! Как зовут серого скакуна Тириона Фордринга?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "Давай проверим, знаешь ли ты историю! Как сказать \"спасибо\" на языке драконов?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "Давай проверим, знаешь ли ты историю! Как звали первую жену короля Вариана Ринна?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "Давай проверим, знаешь ли ты историю! Работая учителем, Сталван Мистмантл сильно увлекся одной из своих подопечных, молодой женщиной по имени Тиллоа. А как звали ее младшего брата?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "Давай проверим, знаешь ли ты историю! Какой клан орков предпочитал белых волков в качестве ездовых животных?"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "Давай проверим, знаешь ли ты историю! Кто сейчас возглавляет гномов?"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "Давай проверим, знаешь ли ты историю! На чьей могиле написано \"Да останется потерянной и забытой окровавленная корона\"?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "Давай проверим, знаешь ли ты историю! Кто был превращен в первого рыцаря смерти в Азероте?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "Давай проверим, знаешь ли ты историю! Кто был первым сатиром?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "Давай проверим, знаешь ли ты историю! Какого могучего протодракона Локен превратил в Острокрылую?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "Давай проверим, знаешь ли ты историю! Как звали трех молодых драконов, охранявших яйца сумеречных драконов в Обсидиановом святилище?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = "Акерус."
L["Archdruid."] = "Верховный друид."
L["Belan shi."] = "Белан ши."
L["Blue dragonflight."] = "Род синих драконов."
L["Calissa Harrington."] = "Калисса Харрингтон."
L["Cenarion Circle."] = "Круг Кенария."
L["Coilfang Reservoir."] = "Резервуар Кривого Клыка."
L["Defective elekk turd."] = "Гнусное отродье элекка."
L["Draka's Fury."] = "Ярость Дреки."
L["Frostwolf clan."] = "Клан Северного Волка."
L["Gelbin Mekkatorque."] = "Гелбин Меггакрут."
L["Giles."] = "Джайлс."
L["Holia Sunshield."] = "Холия Солнечный Щит."
L["K'aresh."] = "К'ареш."
L["King Terenas Menethil II."] = "Король Теренас Менетил II."
L["Mag'har."] = "Маг'хар."
L["Mirador."] = "Мирадор."
L["Mord'rethar."] = "Морд'ретар."
L["Mueh'zala."] = "Муэх'зала."
L["Mur'ghouls."] = "Мур'далаки."
L["Nobundo."] = "Нобундо."
L["Nordrassil."] = "Нордрассил."
L["Norgannon."] = "Норганнон."
L["Queen Mia Greymane."] = "Королева Миа Седогрив."
L["Red pox."] = "Красная оспа."
L["Sayaad."] = "Сайаад."
L["Sharp claw."] = "Острый коготь."
L["Sky'ree."] = "Небесная."
L["Tainted grain."] = "Нечистое зерно."
L["Talak."] = "Талак."
L["Tatai."] = "Татай."
L["Tenebron, Vesperon, and Shadron."] = "Тенеброн, Весперон и Шадрон."
L["Teron Gorefiend."] = "Терон Кровожад."
L["Tiffin Ellerian Wrynn."] = "Тиффин Эллериан Ринн."
L["Toothgnasher."] = "Щелкозуб."
L["Veranus."] = "Веранус."
L["Xavius."] = "Ксавий."

