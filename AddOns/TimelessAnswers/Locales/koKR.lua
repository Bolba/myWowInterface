--[[
	Korean localisation strings for Timeless Answers.
	
	Translation Credits: http://wow.curseforge.com/addons/timeless-answers/localization/translators/
	
	Please update http://www.wowace.com/addons/timeless-answers/localization/koKR/ for any translation additions or changes.
	Once reviewed, the translations will be automatically incorperated in the next build by the localization application.
	
	These translations are released under the Public Domain.
]]--

-- Get addon name
local addon = ...

-- Create the Korean localisation table
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "koKR", false)
if not L then return; end

-- Messages output to the user's chat frame
L["ADDON_LOADED"] = "영원한 답변로드." -- Needs review
L["ANSWER_FOUND"] = "|cFF00FF00발견 답변:|r 선택권 %d. %s" -- Needs review
L["ANSWER_NOT_FOUND"] = "질문에 대한 %q 의 대답은 %q 는 소문 옵션에서 찾을 수 없습니다." -- Needs review
L["ERROR_MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r |cFFFF0000오류:|r %s" -- Needs review
L["IN_RAID"] = "퀘스트는 RAID 그룹에있는 동안 완료 할 수 없습니다." -- Needs review
L["MESSAGE_PREFIX"] = "|cFFFFFF00TA -|r %s" -- Needs review
L["QUESTION_FOUND"] = "|cFF00FF00발견 질문:|r %s" -- Needs review
L["QUESTION_NOT_FOUND"] = "%q 에서 문제를 찾을 수 없습니다." -- Needs review


-- Gossip from the NPC that's neither an answer nor a question
L["Let us test your knowledge of history, then! "] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! "
L["That is correct!"] = "맞았어요!"


-- The complete gossip text from when the NPC asks the question
L["Let us test your knowledge of history, then! Arthas's death knights were trained in a floating citadel that was taken by force when many of them rebelled against the Lich King. What was the fortress's name?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 아서스의 죽음의 기사들은 공중에 떠있는 요새에서 훈련을 받았죠. 그리고 리치 왕으로부터 독립을 한 후에 이곳을 탈환했습니다. 이 요새는 어디인가요?"
L["Let us test your knowledge of history, then! Before Ripsnarl became a worgen, he had a family. What was his wife's name?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 으르렁니가 늑대인간이 되기 전에 그에게는 가족이 있었죠. 으르렁니의 아내의 이름이 무엇이었죠?"
L["Let us test your knowledge of history, then! Before she was raised from the dead by Arthas to serve the Scourge, Sindragosa was a part of what dragonflight?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 아서스가 언데드로 되살려 스컬지의 종복이 되기 전, 신드라고사는 어느 용군단의 일원이었죠?"
L["Let us test your knowledge of history, then! Before the original Horde formed, a highly contagious sickness began spreading rapidly among the orcs. What did the orcs call it?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 호드가 생기기 이전, 오크들 사이에서 급속도로 퍼져나간 전염병이 있었어요. 오크들은 이 병을 뭐라고 불렀죠?"
L["Let us test your knowledge of history, then! Brown-skinned orcs first began showing up on Azeroth several years after the Third War, when the Dark Portal was reactivated. What are these orcs called?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 3차 대전쟁이 일어나고 몇 년이 지난 후 어둠의 문이 다시 열렸을 때, 갈색 피부의 오크들이 아제로스에 모습을 보였죠. 이 오크들이 누구죠?"
L["Let us test your knowledge of history, then! Formerly a healthy paladin, this draenei fell ill after fighting the Burning Legion and becoming one of the Broken. He later became a powerful shaman."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 한때 건장한 성기사였던 이 드레나이는 불타는 군단과 싸우던 도중 건강이 악화되어 뒤틀린 드레나이가 되었습니다. 후에 그는 강력한 주술사가 되었지요. 이 드레나이는 누군가요?"
L["Let us test your knowledge of history, then! In Taur-ahe, the language of the tauren, what does lar'korwi mean?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 타우렌어로 \"라르코르위\"는 무엇을 뜻하죠?"
L["Let us test your knowledge of history, then! In the assault on Icecrown, Horde forces dishonorably attacked Alliance soldiers who were busy fighting the Scourge and trying to capture this gate."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 얼음왕관 전투에서 호드는 이 관문에서 스컬지와 싸우는 얼라이언스에게 기습 공격을 감행했습니다. 이 관문의 이름이 무엇이죠?"
L["Let us test your knowledge of history, then! Malfurion Stormrage helped found this group, which is the primary druidic organization of Azeroth."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 말퓨리온 스톰레이지의 도움으로 설립된 아제로스 최대의 드루이드 집단이 무엇이죠?"
L["Let us test your knowledge of history, then! Name the homeworld of the ethereals."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 에테리얼의 고향은 어디인가요?"
L["Let us test your knowledge of history, then! Name the titan lore-keeper who was a member of the elite Pantheon."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 고위 판테온의 일원으로 티탄의 역사를 기록하는 임무를 맡은 이 자는 누구죠?"
L["Let us test your knowledge of history, then! Not long ago, this frail Zandalari troll sought to tame a direhorn. Although he journeyed to the Isle of Giants, he was slain in his quest. What was his name?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 얼마 전에 이 나약한 잔달라 트롤은 공포뿔을 조련하기 위한 여행을 떠났습니다. 괴수의 섬에 도착한 그는 안타깝게도 도중에 죽었죠. 그의 이름은 무엇인가요?"
L["Let us test your knowledge of history, then! One name for this loa is \"Night's Friend\"."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 이 로아의 이름은 \"어두운 밤의 절친한 벗\"을 뜻합니다. 이 로아는 누구일까요?"
L["Let us test your knowledge of history, then! Succubus demons revel in causing anguish, and they serve the Legion by conducting nightmarish interrogations. What species is the succubus?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 서큐버스들은 고통을 주는 것을 즐기고 그들의 끔찍한 고문 수법은 악몽과도 같다고 합니다. 서큐버스는 어떤 종에 속하죠?"
L["Let us test your knowledge of history, then! Tell me, hero, what are undead murlocs called?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 대답해보세요, 영웅이여. 언데드인 멀록을 뭐라고 부르죠?"
L["Let us test your knowledge of history, then! Thane Kurdran Wildhammer recently suffered a tragic loss when his valiant gryphon was killed in a fire. What was this gryphon's name?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 영주 쿠르드란 와일드해머는 근래에 자신이 아끼는 그리폰을 화재로 잃었습니다. 이 그리폰의 이름이 무엇인가요?"
L["Let us test your knowledge of history, then! The draenei like to joke that in the language of the naaru, the word Exodar has this meaning."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 드레나이는 나루의 언어로 농담을 하는 걸 좋아하죠. 엑소다르가 그중 한 예인데요, 엑소다르가 무엇을 의미하죠?"
L["Let us test your knowledge of history, then! The Ironforge library features a replica of an unusually large ram's skeleton. What was the name of this legendary ram?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 아이언포지의 도서관에는 비정상적으로 거대한 산양의 두개골이 있죠. 이 전설적인 산양의 이름은 무엇인가요?"
L["Let us test your knowledge of history, then! This defender of the Scarlet Crusade was killed while slaying the dreadlord Beltheris."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 붉은십자군 소속이었던 이 수호자는 공포의 군주 벨테리스를 처치하는 도중에 전사했어요. 이 자가 누군가요?"
L["Let us test your knowledge of history, then! This emissary of the Horde felt that Silvermoon City was a little too bright and clean."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 호드의 사절 중 하나였던 이 자는 실버문이 너무 밝고 깨끗하다고 불평했었죠. 이 자는 누구죠?"
L["Let us test your knowledge of history, then! This Horde ship was crafted by goblins. Originally intended to bring Thrall and Aggra to the Maelstrom, the ship was destroyed in a surprise attack by the Alliance."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 고블린들이 만든 이 호드 함선은 원래 스랄과 아그라를 혼돈의 소용돌이로 보내기 위해 만든 것이었어요. 하지만 얼라이언스의 기습 공격으로 파괴되었죠. 이 함선의 이름은 무엇인가요?"
L["Let us test your knowledge of history, then! This queen oversaw the evacuation of her people after the Cataclysm struck and the Forsaken attacked her nation."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 대격변이 일어날 당시 이 여왕은 포세이큰이 공격해왔을 때 자신의 백성들을 대피시겠죠. 이 사람은 누군가요?"
L["Let us test your knowledge of history, then! This structure, located in Zangarmarsh, was controlled by naga who sought to drain a precious and limited resource: the water of Outland."] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 아웃랜드의 귀중한 물을 독차지하기 위해 나가가 장가르 습지대에 만든 구조물이 뭐죠?"
L["Let us test your knowledge of history, then! What did the Dragon Aspects give the night elves after the War of the Ancients?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 고대의 전쟁 이후 용의 위상들이 나이트 엘프에게 무엇을 선물했죠?"
L["Let us test your knowledge of history, then! What evidence drove Prince Arthas to slaughter the people of Stratholme during the Third War?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 3차 대전쟁 때 아서스 왕자가 무엇 때문에 스트라솔름의 주민들을 학살했나요?"
L["Let us test your knowledge of history, then! What is the highest rank bestowed on a druid?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 드루이드에게 내려지는 가장 높은 호칭이 무엇이죠?"
L["Let us test your knowledge of history, then! What is the name of Tirion Fordring's gray stallion?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 티리온 폴드링이 타고 다니는 회색 말의 이름이 무엇이죠?"
L["Let us test your knowledge of history, then! What phrase means \"Thank you\" in Draconic, the language of dragons?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! \"감사합니다.\"를 용들의 언어인 용언으로 뭐라고 할까요?"
L["Let us test your knowledge of history, then! Which of these is the correct name for King Varian Wrynn's first wife?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 국왕 바리안 린의 첫 번째 아내는 누구였죠?"
L["Let us test your knowledge of history, then! While working as a tutor, Stalvan Mistmantle became obsessed with one of his students, a young woman named Tilloa. What was the name of her younger brother?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 학자인 시절에 스탈반 미스트맨틀은 제자였던 틸로아라는 젊은 여자에게 집착에 가까운 애정을 느꼈습니다. 여기서 틸로아는 누구의 누나였죠?"
L["Let us test your knowledge of history, then! White wolves were once the favored mounts of which orc clan?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 하얀 늑대를 즐겨 타던 오크 부족의 이름이 뭐였죠?"
L["Let us test your knowledge of history, then! Who is the current leader of the gnomish people?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 지금 노움을 다스리고 있는 지도자가 누구죠?"
L["Let us test your knowledge of history, then! Whose tomb includes the inscription \"May the bloodied crown stay lost and forgotten\"?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! \"부디 그 피 묻은 왕관이 영원히 돌아오지 않고 잊혀지기를\" 이 글귀가 새겨진 무덤은 누구의 것이죠?"
L["Let us test your knowledge of history, then! Who was the first death knight to be created on Azeroth?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 아제로스에서 생겨난 첫 번째 죽음의 기사가 누구죠?"
L["Let us test your knowledge of history, then! Who was the first satyr to be created?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 처음으로 창조된 사티로스는 누구인가요?"
L["Let us test your knowledge of history, then! Who was the mighty proto-dragon captured by Loken and transformed into Razorscale?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 한때 강력한 원시비룡이었지만 로켄에게 사로잡혀 칼날비늘이 되어버린 이 용의 이름은 무엇이죠?"
L["Let us test your knowledge of history, then! Who were the three young twilight drakes guarding twilight dragon eggs in the Obsidian Sanctum?"] = "당신이 역사를 얼마나 잘 아는지 시험해볼게요! 흑요석 성소에서 황혼의 비룡의 알들을 지키던 어린 황혼의 비룡 셋이 누구였죠?"


-- The complete gossip option text of the correct answer from when the NPC asks the question
L["Acherus."] = "아케루스."
L["Archdruid."] = "대드루이드."
L["Belan shi."] = "벨랑 쉬."
L["Blue dragonflight."] = "푸른용군단."
L["Calissa Harrington."] = "칼리사 해링턴."
L["Cenarion Circle."] = "세나리온 의회."
L["Coilfang Reservoir."] = "갈퀴송곳니 저수지."
L["Defective elekk turd."] = "불량 엘레크 똥덩어리."
L["Draka's Fury."] = "드라카의 분노호."
L["Frostwolf clan."] = "서리늑대 부족."
L["Gelbin Mekkatorque."] = "겔빈 멕카토크."
L["Giles."] = "자일스."
L["Holia Sunshield."] = "홀리아 선쉴드."
L["K'aresh."] = "크아레쉬."
L["King Terenas Menethil II."] = "국왕 테레나스 메네실 2세."
L["Mag'har."] = "마그하르."
L["Mirador."] = "미라도르."
L["Mord'rethar."] = "모드레타르."
L["Mueh'zala."] = "무에젤라."
L["Mur'ghouls."] = "멀구울."
L["Nobundo."] = "노분도."
L["Nordrassil."] = "놀드랏실."
L["Norgannon."] = "노르간논."
L["Queen Mia Greymane."] = "왕비 미아 그레이메인."
L["Red pox."] = "붉은 천연두."
L["Sayaad."] = "세이야드."
L["Sharp claw."] = "뾰족한 발톱."
L["Sky'ree."] = "스카이리."
L["Tainted grain."] = "오염된 곡물."
L["Talak."] = "탈라크."
L["Tatai."] = "타타이."
L["Tenebron, Vesperon, and Shadron."] = "테네브론, 베스페론, 샤드론."
L["Teron Gorefiend."] = "테론 고어핀드."
L["Tiffin Ellerian Wrynn."] = "티핀 엘레리안 린."
L["Toothgnasher."] = "이갈이산양."
L["Veranus."] = "베라누스."
L["Xavius."] = "자비우스."

