--[[
	Italian localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/itIT/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the Italian localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "itIT", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "Risposte Senzatempo Caricate."
L["ANSWER_FOUND"] = "|cFF00FF00Risposta Trovata:|r Opzioni %d. %s"
L["ANSWER_NOT_FOUND"] = "Risposta di %q per la Domanda %q non trovata nelle Opzioni delle Risposte."
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r |cFFFF0000Errore:|r %s"
L["IN_RAID"] = "Quest non può essere completata, mentre in un gruppo raid." -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r %s"
L["QUESTION_FOUND"] = "|cFF00FF00Domanda Trovata:|r %s"
L["QUESTION_NOT_FOUND"] = "Domanda %q non trovata."


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "Mettiamo alla prova la tua cultura storica allora! "
L["That is correct!"] = "Questo è Corretto!"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "Mettiamo alla prova la tua cultura storica allora! I Cavalieri della Morte di Arthas furono addestrati su una cittadella fluttuante che venne conquistata con la forza quando molti di loro si ribellarono al Re dei Lich. Qual è il nome di tale fortezza?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "Mettiamo alla prova la tua cultura storica allora! Prima che Ghignotruce diventasse un Worgen, egli aveva una famiglia. Qual era il nome di sua moglie?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "Mettiamo alla prova la tua cultura storica allora! Prima che venisse resuscitata da Arthas per servire il Flagello, di quale stormo faceva parte Sindragosa?"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "Mettiamo alla prova la tua cultura storica allora! Prima della formazione dell'Orda, un morbo estremamente contagioso iniziò a diffondersi rapidamente tra gli Orchi. Come chiamavano essi questa malattia?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "Mettiamo alla prova la tua cultura storica allora! Orchi dalla pelle scura iniziarono a comparire su Azeroth dopo la Terza Guerra, in seguito alla riapertura del Portale Oscuro. Qual era il nome di questi Orchi?"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "Mettiamo alla prova la tua cultura storica allora! Chi fu il Draenei, in origine un valoroso Paladino e poi diventato un potente Sciamano, che si ammalò dopo lo scontro con la Legione Infuocata per poi diventare uno dei Corrotti?"
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "Mettiamo alla prova la tua cultura storica allora! In Taur-ahe, la lingua dei Tauren, cosa significa la parola \"lar'korwi\"?"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome del cancello presso cui, durante l'assalto alla Corona di Ghiaccio, le forze dell'Orda attaccarono a tradimento i soldati dell'Alleanza mentre erano impegnati a combattere il Flagello?"
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "Mettiamo alla prova la tua cultura storica allora! Quale fu il gruppo creato con l'aiuto di Malfurion Grantempesta e che ora rappresenta la principale organizzazione druidica di Azeroth?"
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome del pianeta natale degli Eterei?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome del custode delle conoscenze dei Titani che faceva parte del Pantheon?"
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "Mettiamo alla prova la tua cultura storica allora! Non molto tempo fa, un fragile Troll Zandalari tentò di addomesticare un cornofurente ma, durante il suo viaggio sull'Isola dei Giganti, rimase ucciso. Qual era il suo nome?"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome del Loa conosciuto anche come \"Amico della Notte\"?"
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "Mettiamo alla prova la tua cultura storica allora! Le Succubi adorano causare agonia e tormento, e le loro abilità trovano massima espressione nei terribili interrogatori che eseguono per conto della Legione. Di quale specie fanno parte?"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "Mettiamo alla prova la tua cultura storica allora! Dimmi, eroe, come vengono chiamati i Murloc non morti?"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "Mettiamo alla prova la tua cultura storica allora! Il Thane Kurdran Granmartello ha recentemente subito una tragica perdita con la morte del suo fidato grifone durante un incendio. Qual era il nome di questo grifone?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "Mettiamo alla prova la tua cultura storica allora! I Draenei sono soliti scherzare sul fatto che nella lingua dei Naaru, la parola Exodar ha quale significato?"
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "Mettiamo alla prova la tua cultura storica allora! La libreria di Forgiardente contiene una replica di un insolito scheletro di montone. Qual era il nome di questa leggendaria creatura?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome del difensore della Crociata Scarlatta ucciso mentre cercava di distruggere il Signore del Terrore Beltheris?"
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "Mettiamo alla prova la tua cultura storica allora! Qual era il nome dell'emissario dell'Orda che riteneva Lunargenta un po' troppo luminosa e pulita?"
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome della nave costruita dai Goblin, originariamente pensata per portare Thrall e Aggra all'interno del Maelstrom e poi distrutta in un attacco a sorpresa da parte dell'Alleanza?"
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome della regina che ha supervisionato l'evacuazione della sua gente dopo l'avvento del Cataclisma e dell'attacco della sua nazione da parte dei Reietti?"
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "Mettiamo alla prova la tua cultura storica allora! Quale struttura, situata nelle Paludi di Zangar, era sotto il controllo dei Naga mentre cercavano di recuperare dell'acqua, una delle più preziose e limitate risorse delle Terre Esterne?"
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "Mettiamo alla prova la tua cultura storica allora! Cosa donarono gli Aspetti del Drago agli Elfi della Notte dopo la fine della Guerra degli Antichi?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "Mettiamo alla prova la tua cultura storica allora! Quale prova spinse il Principe Arthas a massacrare gli abitanti di Stratholme durante la Terza Guerra?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "Mettiamo alla prova la tua cultura storica allora! Qual è la riconoscenza più alta a cui un Druido può aspirare?"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome dello stallone grigio di Tirion Fordring?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "Mettiamo alla prova la tua cultura storica allora! Quale frase in lingua draconica, il linguaggio dei draghi, significa \"Grazie\"?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "Mettiamo alla prova la tua cultura storica allora! Quale di questi è il nome corretto della prima moglie di Re Varian Wrynn?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "Mettiamo alla prova la tua cultura storica allora! Mentre lavorava come insegnante, Stalvan Foscomanto diventò ossessionato da una delle sue studentesse, una giovane donna di nome Tilloa. Qual era il nome del fratello più giovane di questa ragazza?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "Mettiamo alla prova la tua cultura storica allora! I Lupi Bianchi erano un tempo la cavalcatura preferita di quale clan degli Orchi?"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome dell'attuale capo degli Gnomi?"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "Mettiamo alla prova la tua cultura storica allora! Chi è colui la cui tomba riporta l'iscrizione \"Possa la corona insanguinata rimanere perduta e dimenticata\"?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "Mettiamo alla prova la tua cultura storica allora! Chi fu il primo Cavaliere della Morte creato su Azeroth?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "Mettiamo alla prova la tua cultura storica allora! Chi è stato il primo Satiro a essere stato creato?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "Mettiamo alla prova la tua cultura storica allora! Qual è il nome del poderoso Proto-Draco catturato da Loken e trasformato poi in Scagliafusa?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "Mettiamo alla prova la tua cultura storica allora! Chi furono i tre giovani Drachi del Crepuscolo incaricati di proteggere le uova all'interno del Santuario di Ossidiana?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = true
L["Archdruid."] = "Arcidruido."
L["Belan shi."] = true
L["Blue dragonflight."] = "Stormo dei Draghi Blu."
L["Calissa Harrington."] = true
L["Cenarion Circle."] = "Circolo Cenariano."
L["Coilfang Reservoir."] = "Bacino Spinaguzza."
L["Defective elekk turd."] = "Pezzo di sterco di elekk difettoso."
L["Draka's Fury."] = "Furia di Draka."
L["Frostwolf clan."] = "Lupi Bianchi."
L["Gelbin Mekkatorque."] = "Gelbin Mekkatork."
L["Giles."] = true
L["Holia Sunshield."] = "Holia Scusasole."
L["K'aresh."] = true
L["King Terenas Menethil II."] = "Re Terenas Menethil II."
L["Mag'har."] = true
L["Mirador."] = true
L["Mord'rethar."] = true
L["Mueh'zala."] = true
L["Mur'ghouls."] = "Mur'ghoul."
L["Nobundo."] = true
L["Nordrassil."] = true
L["Norgannon."] = true
L["Queen Mia Greymane."] = "Regina Mia Mantogrigio."
L["Red pox."] = "Esantema del Sangue."
L["Sayaad."] = true
L["Sharp claw."] = "Artiglio Affilato."
L["Sky'ree."] = true
L["Tainted grain."] = "Grano Corrotto."
L["Talak."] = true
L["Tatai."] = true
L["Tenebron, Vesperon, and Shadron."] = "Tenebron, Vesperon, e Shadron."
L["Teron Gorefiend."] = "Teron Malacarne."
L["Tiffin Ellerian Wrynn."] = true
L["Toothgnasher."] = "Dentinfami."
L["Veranus."] = true
L["Xavius."] = true

