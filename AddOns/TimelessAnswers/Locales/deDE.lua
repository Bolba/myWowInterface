--[[
	German localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/deDE/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the German localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "deDE", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "Zeitlose Fragen geladen."
L["ANSWER_FOUND"] = "|cFF00FF00Antwort gefunden:|r Option %d. %s"
L["ANSWER_NOT_FOUND"] = "Antwort %q für die Frage %q wurde in den Auswahlmöglichkeiten nicht gefunden."
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00ZA -|r |cFFFF0000Fehler:|r %s"
L["IN_RAID"] = "Quest kann nicht, während in einer RAID-Gruppe abgeschlossen werden." -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00ZA -|r %s"
L["QUESTION_FOUND"] = "|cFF00FF00Frage gefunden:|r %s"
L["QUESTION_NOT_FOUND"] = "Frage %q nicht gefunden."


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "Na dann lasst uns Euer Wissen auf die Probe stellen! "
L["That is correct!"] = "Das ist richtig!"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Die Todesritter von Arthas wurden in einer schwebenden Zitadelle ausgebildet, die dem Lichkönig gewaltsam entrissen wurde, als viele von ihnen rebellierten. Wie lautet der Name dieser Festung?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Bevor Knurrreißer zu einem Worgen wurde, hatte er eine Familie. Wie hieß seine Frau?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Bevor Arthas sie von den Toten auferstehen ließ, um der Geißel zu dienen, gehörte Sindragosa zu welchem Drachenschwarm?"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Bevor sich die ursprüngliche Horde gebildet hatte, verbreitete sich unter den Orcs rasend schnell eine hochansteckende Krankheit. Welchen Namen gaben die Orcs dieser Krankheit?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Die ersten braunhäutigen Orcs tauchten einige Jahre nach dem Dritten Krieg auf Azeroth auf, als das Dunkle Portal reaktiviert wurde. Wie werden diese Orcs genannt?"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Dieser Draenei war einst ein gesunder Paladin, wurde jedoch krank und zu einem Zerschlagenen, nachdem er gegen die Brennende Legion gekämpft hatte. Später wurde er ein mächtiger Schamane. Wie lautet sein Name?"
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Der Ausdruck \"Lar'korwi\" stammt aus der taurischen Sprache Taurahe. Was bedeutet er?"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Während des Angriffs auf Eiskrone griffen Streitkräfte der Horde auf ehrlose Weise Soldaten der Allianz an, als diese gegen die Geißel kämpften und versuchten, ein Tor einzunehmen. Wie lautet der Name dieses Tors?"
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Malfurion Sturmgrimm war einer der Gründer dieser Gruppe, die den wichtigsten druidischen Bund auf Azeroth darstellt. Wie lautet ihr Name?"
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Was ist die Heimatwelt der Astralen?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welcher titanische Bewahrer der Lehren war ein Mitglied des elitären Pantheons?"
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Es ist noch nicht allzu lange her, da versuchte dieser Troll der Zandalari, ein Terrorhorn zu zähmen. Er reiste zur Insel der Riesen, überlebte allerdings sein Abenteuer nicht. Wie lautete sein Name?"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welcher Loa ist unter anderem als \"Freund der Nacht\" bekannt?"
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Sukkubusdämonen weiden sich daran, Qualen zu verursachen und dienen der Legion, indem sie alptraumhafte Verhöre durchführen. Welcher Spezies gehören sie an?"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Wie nennt man untote Murlocs?"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Than Kurdran Wildhammer erlitt kürzlich einen tragischen Verlust, als sein tapferer Greif in einem Feuer ums Leben kam. Wie lautete der Name dieses Greifs?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Die Draenei witzeln gern, dass \"Exodar\" in der Sprache der Naaru eine bestimmte Bedeutung hat. Welche?"
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! In der Bibliothek von Eisenschmiede gibt es eine Nachbildung des Skeletts eines ungewöhnlich großen Widders. Wie hieß dieser legendäre Widder?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welche Verteidigerin des Scharlachroten Kreuzzugs wurde erschlagen, als sie den Schreckenslord Beltheris tötete?"
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welcher Abgesandte der Horde war der Meinung, dass Silbermond ein wenig zu sauber und hell war?"
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Dieses Hordenschiff wurde von Goblins konstruiert. Ursprünglich war es dazu gedacht, Thrall und Aggra zum Mahlstrom zu befördern, jedoch wurde es in einem Überraschungsangriff der Allianz zerstört. Auf welchen Namen war es getauft worden?"
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welche Königin wachte nach dem Kataklysmus und dem Angriff der Verlassenen auf ihre Nation über die Flucht ihres Volkes?"
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welches Gebilde in den Zangarmarschen stand unter der Kontrolle der Naga, die versuchten, das wertvolle und nur begrenzt vorhandene Wasser der Scherbenwelt abzupumpen?"
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Was erhielten die Nachtelfen von den Drachenaspekten nach dem Krieg der Ahnen?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welcher Beweis hat Prinz Arthas dazu bewegt, während des Dritten Krieges die Einwohner von Stratholme zu töten?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welches ist der höchste Rang, den ein Druide erreichen kann?"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Wie heißt der graue Hengst von Tirion Fordring?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welcher der folgenden Ausdrücke bedeutet \"Danke schön\" auf Drakonisch, der Sprache der Drachen?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Wie genau hieß die erste Frau von König Varian Wrynn?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Während seiner Zeit als Tutor war Stalvan Dunstmantel besessen von einer seiner Schülerinnen, einer jungen Frau namens Tilloa. Wie lautete der Name ihres jüngeren Bruders?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Weiße Wölfe waren einst das bevorzugte Reittier von welchem Orcklan?"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Wer ist aktuell der Anführer der Gnome?"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Auf wessen Grab befindet sich die Inschrift: \"Möge die blutige Krone verloren und vergessen bleiben.\"?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Wer war der erste auf Azeroth erschaffene Todesritter?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Wer war der erste Satyr, der je erschaffen wurde?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Welcher gewaltige Protodrache wurde von Loken gefangen und in \"Klingenschuppe\" verwandelt?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "Na dann lasst uns Euer Wissen auf die Probe stellen! Wer waren die drei jungen Drachen des Zwielichts, die die Dracheneier im Obsidiansanktum bewachten?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = true
L["Archdruid."] = "Erzdruide."
L["Belan shi."] = true
L["Blue dragonflight."] = "Zum blauen Drachenschwarm."
L["Calissa Harrington."] = true
L["Cenarion Circle."] = "Der Zirkel des Cenarius."
L["Coilfang Reservoir."] = "Der Echsenkessel."
L["Defective elekk turd."] = "Wertloser Elekkdung."
L["Draka's Fury."] = "Drakas Furor."
L["Frostwolf clan."] = "Frostwolfklan."
L["Gelbin Mekkatorque."] = "Gelbin Mekkadrill."
L["Giles."] = true
L["Holia Sunshield."] = "Holia Sonnenschild."
L["K'aresh."] = true
L["King Terenas Menethil II."] = "König Terenas Menethil II."
L["Mag'har."] = true
L["Mirador."] = true
L["Mord'rethar."] = true
L["Mueh'zala."] = true
L["Mur'ghouls."] = "Mur'ghuls."
L["Nobundo."] = true
L["Nordrassil."] = true
L["Norgannon."] = true
L["Queen Mia Greymane."] = "Königin Mia Graumähne."
L["Red pox."] = "Rote Pocken."
L["Sayaad."] = true
L["Sharp claw."] = "Scharfe Klaue."
L["Sky'ree."] = "Hori'zee."
L["Tainted grain."] = "Verseuchtes Getreide."
L["Talak."] = true
L["Tatai."] = true
L["Tenebron, Vesperon, and Shadron."] = "Tenebron, Vesperon, und Shadron."
L["Teron Gorefiend."] = "Teron Blutschatten."
L["Tiffin Ellerian Wrynn."] = true
L["Toothgnasher."] = "Knirschzahn."
L["Veranus."] = true
L["Xavius."] = true

