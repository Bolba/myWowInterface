--[[
	Spanish localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/esES/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the Spanish localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "esES", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "Respuestas Timeless cargado." -- Needs review
L["ANSWER_FOUND"] = "|cFF00FF00respuesta Encontrado:|r opción %d. %s" -- Needs review
L["ANSWER_NOT_FOUND"] = "Respuesta de %q para la pregunta %q no se encuentra en las opciones de chismes." -- Needs review
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00RT -|r |cFFFF0000error:|r %s" -- Needs review
L["IN_RAID"] = "Misión no puede completarse, mientras que en un grupo de banda." -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00RT -|r %s" -- Needs review
L["QUESTION_FOUND"] = "|cFF00FF00pregunta Encontrado:|r %s" -- Needs review
L["QUESTION_NOT_FOUND"] = "Pregunta de %q no se encuentra." -- Needs review


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "¡Pongamos a prueba tus conocimientos de historia! "
L["That is correct!"] = "¡Has acertado!"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "¡Pongamos a prueba tus conocimientos de historia! Los caballeros de la Muerte de Arthas se entrenaban en una ciudadela flotante que fue tomada por la fuerza cuando un grupo de caballeros se rebeló contra el Rey Exánime. ¿Cómo se llama la fortaleza?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "¡Pongamos a prueba tus conocimientos de historia! Rasgagruñido tenía familia antes de convertirse en huargen. ¿Cómo se llamaba su mujer?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿A qué Vuelo pertenecía Sindragosa antes de que Arthas la resucitara de entre los muertos para servir a la Plaga?"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "¡Pongamos a prueba tus conocimientos de historia! Antes de que se formara la primera Horda, una enfermedad altamente contagiosa se propagó entre los orcos. ¿Cómo la llamaban?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "¡Pongamos a prueba tus conocimientos de historia! Los orcos de piel marrón aparecieron en Azeroth unos años después de la Tercera Guerra, cuando se reactivó el Portal Oscuro. ¿Cómo se llaman esos orcos?"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "¡Pongamos a prueba tus conocimientos de historia! Un draenei que antaño fue un robusto paladín cayó enfermo tras luchar contra la Legión Ardiente y se convirtió en un Perdido. Ahora es un poderoso chamán. ¿Cómo se llama?"
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué significa \"lar'kowi\" en taurahe, el idioma de los tauren?"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "¡Pongamos a prueba tus conocimientos de historia! Durante el asalto a Corona de Hielo, un grupo de la Horda atacó deshonrosamente a los soldados de la Alianza mientras luchaban contra la Plaga. ¿Cómo se llamaba la puerta que intentaban capturar?"
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cuál es la organización druídica más importante de Azeroth, fundada por Malfurion Tempestira, entre otros?"
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cómo se llama el mundo natal de los etéreos?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cómo se llamaba el titán tradicionalista que era un miembro de élite del Panteón?"
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "¡Pongamos a prueba tus conocimientos de historia! No hace mucho, un débil trol Zandalari intentó domar un cuernoatroz. Aunque viajó a la Isla de los Gigantes, murió antes de cumplir su misión. ¿Cómo se llamaba?"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué loa se conoce también como \"amigo de la noche\"?"
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "¡Pongamos a prueba tus conocimientos de historia! Los súcubos disfrutan provocando angustia y sirven a la Legión llevando a cabo interrogatorios dignos de las peores pesadillas. ¿A qué especie pertenece el súcubo?"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "¡Pongamos a prueba tus conocimientos de historia! Dime, ¿cómo se llama a los múrlocs no-muertos?"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "¡Pongamos a prueba tus conocimientos de historia! El señor feudal Kurdran Martillo Salvaje sufrió una pérdida terrible hace poco, cuando su valiente grifo murió en un incendio. ¿Cómo se llamaba el grifo?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "¡Pongamos a prueba tus conocimientos de historia! Según un chiste popular entre los draenei, ¿qué significa Exodar en el idioma de los naaru?"
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "¡Pongamos a prueba tus conocimientos de historia! La biblioteca de Forjaz alberga una réplica del esqueleto de un carnero inusualmente grande. ¿Cómo se llamaba este carnero legendario?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué defensor de la Cruzada Escarlata murió tras matar al señor del terror Beltheris?"
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué emisario de la Horda opinó que la Ciudad de Lunargenta era demasiado limpia y luminosa?"
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "¡Pongamos a prueba tus conocimientos de historia! Los goblins fabricaron un barco que debía llevar a Thrall y a Aggra a La Vorágine, pero la Alianza lo destruyó en un ataque sorpresa. ¿Cómo se llamaba el barco?"
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué reina supervisó la evacuación de su pueblo cuando se desató el Cataclismo y los Renegados invadieron su reino?"
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué estructura de la Marisma de Zangar tomaron los naga para drenar el agua de Terrallende, su recurso más valioso y limitado?"
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué dieron los dragones Aspectos a los elfos de la noche tras la Guerra de los Ancestros?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué prueba convenció al príncipe Arthas para masacrar a los habitantes de Stratholme durante la Tercera Guerra?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cuál es el rango más alto que puede alcanzar un druida?"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cómo se llama el corcel gris de Tirion Vadín?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cómo se dice \"Gracias\" en dracónico, el idioma de los dragones?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cómo se llamaba la mujer del rey Varian Wrynn?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "¡Pongamos a prueba tus conocimientos de historia! Cuando trabajaba como tutor, Stalvan Mantoniebla se obsesionó con una de sus pupilas, una joven llamada Tilloa. ¿Cómo se llamaba el hermano menor de Tilloa?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué clan orco utiliza lobos blancos como montura?"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Quién es el líder actual de los gnomos?"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿A quién pertenece la lápida que reza \"Que la corona manchada de sangre permanezca en el olvido\"?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Quién fue el primer caballero de la Muerte de Azeroth?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Quién fue el primer sátiro?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Qué poderoso protodraco fue capturado por Loken y transformado en Tajoescama?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "¡Pongamos a prueba tus conocimientos de historia! ¿Cómo se llamaban los tres jóvenes dracos Crepusculares que protegían huevos de dragón Crepuscular en el Sagrario Obsidiana?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = true
L["Archdruid."] = "Archidruida."
L["Belan shi."] = true
L["Blue dragonflight."] = "El Vuelo Azul."
L["Calissa Harrington."] = true
L["Cenarion Circle."] = "El Círculo Cenarion."
L["Coilfang Reservoir."] = "La Reserva Colmillo Torcido."
L["Defective elekk turd."] = "Estiércol de elekk defectuoso."
L["Draka's Fury."] = "Furia de Draka."
L["Frostwolf clan."] = "El clan Lobo Gélido."
L["Gelbin Mekkatorque."] = true
L["Giles."] = true
L["Holia Sunshield."] = "Holia Escusol."
L["K'aresh."] = true
L["King Terenas Menethil II."] = "El rey Terenas Menethil II."
L["Mag'har."] = true
L["Mirador."] = true
L["Mord'rethar."] = true
L["Mueh'zala."] = true
L["Mur'ghouls."] = "Mur'crófagos."
L["Nobundo."] = true
L["Nordrassil."] = true
L["Norgannon."] = true
L["Queen Mia Greymane."] = "La reina Mia Cringris."
L["Red pox."] = "Peste roja."
L["Sayaad."] = true
L["Sharp claw."] = "Garra afilada."
L["Sky'ree."] = "Cielo'ree."
L["Tainted grain."] = "Grano contaminado."
L["Talak."] = true
L["Tatai."] = true
L["Tenebron, Vesperon, and Shadron."] = "Tenebron, Vesperon y Shadron."
L["Teron Gorefiend."] = "Teron Sanguino."
L["Tiffin Ellerian Wrynn."] = true
L["Toothgnasher."] = "Rechinador."
L["Veranus."] = true
L["Xavius."] = true

