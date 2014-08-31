--[[
	Brazilian Portuguese localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/ptBR/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the Brazilian Portuguese localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "ptBR", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "Respostas Timeless Loaded." -- Needs review
L["ANSWER_FOUND"] = "|cFF00FF00Encontrado Resposta:|r opção %d. %s" -- Needs review
L["ANSWER_NOT_FOUND"] = "Resposta de %q para a pergunta %q não encontrado nas opções de fofocas." -- Needs review
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00RT -|r |cFFFF0000Erro :|r %s" -- Needs review
L["IN_RAID"] = "Procura não pode ser concluída, enquanto em um grupo de ataque." -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00RT -|r %s" -- Needs review
L["QUESTION_FOUND"] = "|cFF00FF00Pergunta Encontrado:|r %s" -- Needs review
L["QUESTION_NOT_FOUND"] = "Pergunta de %q não foi encontrado." -- Needs review


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "Vamos testar seu conhecimento de história, então! "
L["That is correct!"] = "Isso mesmo!"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "Vamos testar seu conhecimento de história, então! Os cavaleiros da morte de Arthas eram treinados em uma cidadela flutuante que foi tomada à força depois que muitos deles se rebelaram contra o Lich Rei. Qual era o nome da fortaleza?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "Vamos testar seu conhecimento de história, então! Antes de Rosnarrasga se tornar um worgen, ele tinha uma família. Qual era o nome de sua esposa?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "Vamos testar seu conhecimento de história, então! Antes de ser trazida de volta dos mortos por Arthas para servir ao Flagelo, Sindragosa fazia parte de qual Revoada Dragônica?"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "Vamos testar seu conhecimento de história, então! Antes da Horda original ser formada, uma doença altamente contagiosa se espalhou rapidamente pelos orcs. Como os orcs a chamavam?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "Vamos testar seu conhecimento de história, então! Os orcs de pele marrom foram vistos pela primeira vez em Azeroth vários anos depois da Terceira Guerra, quando o Portal Negro foi reativado. Como eram chamados esses orcs?"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "Vamos testar seu conhecimento de história, então! Antes um paladino vigoroso, este draenei adoeceu depois de enfrentar a Legião Ardente e se tornar um dos Degradados. Ele se tornou um poderoso xamã depois disso."
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "Vamos testar seu conhecimento de história, então! Em taurahe, a língua dos taurens, o que significa lar'korwi?"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "Vamos testar seu conhecimento de história, então! No ataque à Coroa de Gelo, as forças da Horda atacaram desonestamente os soldados da Aliança que estavam ocupados combatendo o Flagelo e tentando capturar o portão."
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "Vamos testar seu conhecimento de história, então! Malfurion Tempesfúria ajudou a fundar este grupo, que é a organização druídica primária de Azeroth."
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "Vamos testar seu conhecimento de história, então! Qual é o nome do mundo natal dos etéreos?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "Vamos testar seu conhecimento de história, então! Quem era o titã guardião do conhecimento que era membro do Panteão de elite?"
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "Vamos testar seu conhecimento de história, então! Não faz muito tempo, este frágil troll Zandalari tentou domar um escornante. Apesar de ter partido para a Ilha de Gigantes, ele morreu durante a tarefa. Qual era seu nome?"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "Vamos testar seu conhecimento de história, então! Um dos nomes desse loa é \"Amigo da Noite\"."
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "Vamos testar seu conhecimento de história, então! Os demônios Súcubos se deliciam ao causar angústia, e eles servem à Legião conduzindo interrogatórios torturantes. De qual espécie são os Súcubos?"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "Vamos testar seu conhecimento de história, então! Diga-me herói, como são chamados os murlocs mortos-vivos?"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "Vamos testar seu conhecimento de história, então! O Thane Kurdran Martelo Feroz sofreu recentemente uma perda trágica quando seu valente grifo foi morto em um incêndio. Qual era o nome do grifo?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "Vamos testar seu conhecimento de história, então! Os draeneis gostam de brincar que no idioma dos naarus, a palavra Exodar tem esse significado."
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "Vamos testar seu conhecimento de história, então! A biblioteca de Altaforja possui uma réplica de um esqueleto excepcionalmente grande de carneiro. Qual era o nome deste carneiro lendário?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "Vamos testar seu conhecimento de história, então! Esta defensora da Cruzada Escarlate foi morta no combate em que derrotou o Senhor do Medo Beltheris."
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "Vamos testar seu conhecimento de história, então! Este emissário da Horda disse que Luaprata era claro e limpo demais para o gosto dele."
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "Vamos testar seu conhecimento de história, então! Este navio da Horda foi construído por goblins. Originalmente deveria levar Thrall e Aggra para Voragem, mas o navio foi destruído pela Aliança em um ataque surpresa."
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "Vamos testar seu conhecimento de história, então! Esta rainha supervisionou a evacuação de sua cidade durante o Cataclismo e os Renegados atacaram sua terra natal."
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "Vamos testar seu conhecimento de história, então!  Esta estrutura, localizada no Pântano Zíngaro era controlada por nagas que buscavam drenar um precioso e escasso recurso: as águas de Terralém."
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "Vamos testar seu conhecimento de história, então! O que os Aspectos presentearam aos elfos noturnos depois da Guerra dos Antigos?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "Vamos testar seu conhecimento de história, então! Que evidências levaram o príncipe Arthas a expurgar o povo de Stratholme durante a Terceira Guerra?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "Vamos testar seu conhecimento de história, então! Qual o maior grau de hierarquia conferido a um druida?"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "Vamos testar seu conhecimento de história, então! Qual é o nome do garanhão cinza de Tirion Fordring?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "Vamos testar seu conhecimento de história, então! Que frase significa \"Obrigado\" em dracônico, a língua dos dragões?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "Vamos testar seu conhecimento de história, então! Qual desses é o nome correto da primeira esposa do Rei Varian Wrynn?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "Vamos testar seu conhecimento de história, então! Enquanto trabalhava como tutor, Galvão Brumanto se tornou obcecado com uma de suas alunas. Uma jovenzinha chamada Tirsa. Qual era o nome do irmão mais novo dela?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "Vamos testar seu conhecimento de história, então! Lobos brancos costumavam ser as montarias favoritas de qual clã orc?"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "Vamos testar seu conhecimento de história, então! Quem é o líder atual dos gnomos?"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "Vamos testar seu conhecimento de história, então! Na tumba de quem está a inscrição: \"Que a coroa ensanguentada jaza em esquecimento\"?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "Vamos testar seu conhecimento de história, então! Quem foi o primeiro cavaleiro da morte a ser criado em Azeroth?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "Vamos testar seu conhecimento de história, então! Quem foi o primeiro sátiro a ser criado?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "Vamos testar seu conhecimento de história, então! Quem era o poderoso potodraco capturado por Loken e transformado em Navalhada?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "Vamos testar seu conhecimento de história, então! Quem eram os três jovens dragões do crepúsculo que guardavam os ovos de dragão do crepúsculo no Santuário Obsidiano?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = "Áquerus."
L["Archdruid."] = "Arquidruida."
L["Belan shi."] = true
L["Blue dragonflight."] = "Revoada Dragônica Azul."
L["Calissa Harrington."] = true
L["Cenarion Circle."] = "Círculo Cenariano."
L["Coilfang Reservoir."] = "Reservatório Presacurva."
L["Defective elekk turd."] = "Cocô defeiituoso de elekk."
L["Draka's Fury."] = "Fúria de Draka."
L["Frostwolf clan."] = "Clã Lobo do Gelo."
L["Gelbin Mekkatorque."] = true
L["Giles."] = "Gaspar."
L["Holia Sunshield."] = "Holia Solbroquel."
L["K'aresh."] = true
L["King Terenas Menethil II."] = "Rei Terenas Menethil II."
L["Mag'har."] = true
L["Mirador."] = true
L["Mord'rethar."] = true
L["Mueh'zala."] = true
L["Mur'ghouls."] = "Mur'niçais."
L["Nobundo."] = "Nobambo."
L["Nordrassil."] = true
L["Norgannon."] = true
L["Queen Mia Greymane."] = "Rainha Mia Greymane."
L["Red pox."] = "Varíola vermelha."
L["Sayaad."] = true
L["Sharp claw."] = "Garra afiada."
L["Sky'ree."] = true
L["Tainted grain."] = "Grãos corrompidos."
L["Talak."] = true
L["Tatai."] = true
L["Tenebron, Vesperon, and Shadron."] = "Tenebron, Vesperon e Shadron."
L["Teron Gorefiend."] = "Teron Sanguinávido."
L["Tiffin Ellerian Wrynn."] = "Talian Ellerian Wrynn."
L["Toothgnasher."] = "Rangedente."
L["Veranus."] = "Veranes."
L["Xavius."] = true

