--[[
	French localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/frFR/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the French localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "frFR", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "Réponses Timeless Loaded." -- Needs review
L["ANSWER_FOUND"] = "|cFF00FF00Réponse Trouvée:|r Option %d. %s" -- Needs review
L["ANSWER_NOT_FOUND"] = "Réponse de %q pour la question %q ne figure pas dans les options de potins." -- Needs review
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00RT -|r |cFFFF0000Erreur:|r %s" -- Needs review
L["IN_RAID"] = "Quête ne peut être terminée alors que dans un groupe de raid." -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00RT -|r %s" -- Needs review
L["QUESTION_FOUND"] = "|cFF00FF00Question Trouvée:|r %s" -- Needs review
L["QUESTION_NOT_FOUND"] = "Question de %q introuvable." -- Needs review


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire !"
L["That is correct!"] = "C’est exact !"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Les chevaliers de la mort d’Arthas s’entraînaient dans une citadelle volante qui fut conquise quand de nombreux chevaliers se révoltèrent contre le roi-liche. Comment s’appelait la forteresse ?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Avant que Grondéventre ne fût transformé en worgen, il avait une famille. Comment s’appelait sa femme ?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Avant d’être relevée d’entre les morts par Arthas pour servir le Fléau, à quel Vol draconique appartenait Sindragosa ?"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Avant la formation de la Horde originale, une maladie très contagieuse commença à se répandre parmi les orcs. Comment les orcs appelaient-ils cette maladie ?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Les premiers orcs à peau brune commencèrent à faire leur apparition en Azeroth plusieurs années après la Troisième guerre, quand la porte des Ténèbres fut réactivée. Comment s’appellent ces orcs ?"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Autrefois vaillant paladin, ce draenei tomba malade après avoir combattu la Légion ardente et devint un Roué. Plus tard, il se révéla être un puissant chaman."
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Que signifie lar’korwi en Taurahe, la langue des taurens ?"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Lors de l’assaut sur la Couronne de glace, les troupes de la Horde attaquèrent de façon déshonorante les soldats de l’Alliance qui affrontaient déjà le Fléau et tentaient de capturer cette porte."
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Malfurion Hurlorage participa à la fondation de ce groupe, la première organisation druidique d’Azeroth."
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Comment s’appelle le monde des éthériens ?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Comment s’appelle le titan gardien du savoir et membre du Panthéon."
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Il n’y a pas si longtemps, ce frêle Zandalari se mit en tête de dompter un navrecorne. Il se rendit sur l’île des Géants, mais fut tué au cours de sa quête. Comment s’appelait ce troll ?"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! L’un des noms de ce loa est « ami de la nuit »."
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Les succubes aiment faire naître l’angoisse chez leurs victimes, et elles servent la Légion en menant des interrogatoires cauchemardesques. De quelle espèce sont ces démons ?"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Dites-moi, héros, comment s’appellent les murlocs morts-vivants ?"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Le thane Kurdran Marteau-hardi a récemment subi une terrible perte quand son vaillant griffon fut tué par le feu. Comment s’appelait son griffon ?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Les draeneï aiment plaisanter sur la signification du mot Exodar dans la langue des naaru."
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! La bibliothèque de Forgefer abrite la réplique d’un squelette de bélier particulièrement imposant. Comment s’appelait ce bélier légendaire ?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Ce défenseur de la Croisade écarlate fut tué en mettant fin aux jours du seigneur de l’effroi Beltheris."
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Cet émissaire de la Horde trouvait Lune-d’Argent un peu trop propre et éclatante."
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Ce bateau de la Horde fut construit par les gobelins. À l’origine destiné à transporter Thrall et Aggra au Maelström, il fut détruit lors d’une attaque surprise de l’Alliance."
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Cette reine a supervisé l’évacuation de son peuple suite au Cataclysme et à l’attaque des Réprouvés. De qui s’agit-il ?"
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Cette installation, située dans le marécage de Zangar, était contrôlée par les nagas qui tentaient de drainer une ressource limitée et précieuse en Outreterre : l’eau."
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Qu’ont donné les Aspects dragons aux elfes de la nuit à la fin de la guerre des Anciens ?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Quelles preuves convainquirent le prince Arthas de massacrer les habitants de Stratholme au cours de la Troisième guerre ?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Quel est le plus haut rang dans la hiérarchie druidique ?"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Comment s’appelle l’étalon gris de Tirion Fordring ?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Quelle expression signifie « merci » en draconique, la langue des dragons ?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Comment s’appelait la première femme du roi Varian Wrynn ?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Alors qu’il était employé comme précepteur, Stalvan Mantebrume nourrit une obsession pour l’un de ses étudiants, une jeune femme répondant au nom de Tilloa. Comment s’appelait son frère cadet ?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Les loups blancs étaient autrefois la monture préférée de quel clan ?"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Qui est le dirigeant actuel du peuple gnome ?"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Quelle tombe porte l’inscription : « Que la couronne sanglante reste perdue et oubliée. » ?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Qui fut le premier chevalier de la mort créé en Azeroth ?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Comment s’appelle le premier satyre créé ?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Comment s’appelait le proto-dragon puissant capturé par Loken et transformé en Tranchécaille ?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "Très bien, mettons à l’épreuve vos connaissances de l’histoire ! Qui étaient les trois jeunes drakes du Crépuscule qui gardaient les œufs de dragon du Crépuscule au sanctum Obsidien ?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = "Achérus."
L["Archdruid."] = "Archidruide."
L["Belan shi."] = true
L["Blue dragonflight."] = "Le Vol draconique bleu."
L["Calissa Harrington."] = true
L["Cenarion Circle."] = "Le Cercle cénarien."
L["Coilfang Reservoir."] = "Le réservoir de Glissecroc."
L["Defective elekk turd."] = "Fiente d’elekk anormale."
L["Draka's Fury."] = "La Fureur de Draka."
L["Frostwolf clan."] = "Le clan Loup-de-givre."
L["Gelbin Mekkatorque."] = "Gelbin Mekkanivelle."
L["Giles."] = true
L["Holia Sunshield."] = "Holia Soltarge."
L["K'aresh."] = "K’aresh."
L["King Terenas Menethil II."] = "Le roi Terenas Menethil II."
L["Mag'har."] = "Les mag’har."
L["Mirador."] = true
L["Mord'rethar."] = "Mord’rethar."
L["Mueh'zala."] = "Mueh’zala."
L["Mur'ghouls."] = "Les mur’goules."
L["Nobundo."] = true
L["Nordrassil."] = true
L["Norgannon."] = true
L["Queen Mia Greymane."] = "La reine Mia Grisetête."
L["Red pox."] = "La fièvre rouge."
L["Sayaad."] = true
L["Sharp claw."] = "Griffe aiguisée."
L["Sky'ree."] = "Ciel'ree."
L["Tainted grain."] = "Du grain pestiféré."
L["Talak."] = true
L["Tatai."] = "Tataï."
L["Tenebron, Vesperon, and Shadron."] = "Ténébron, Vespéron et Obscuron."
L["Teron Gorefiend."] = "Teron Fielsang."
L["Tiffin Ellerian Wrynn."] = true
L["Toothgnasher."] = "Grincedents."
L["Veranus."] = true
L["Xavius."] = true

