--[[--------------------------------------------------------------------
	Item Tooltip Cleaner
	Removes extraneous lines from item tooltips.
	Copyright (c) 2010-2014 Akkorian, Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/addons/info19129-ItemTooltipCleaner.html
	http://www.curse.com/addons/wow/itemtooltipcleaner
----------------------------------------------------------------------]]

local ADDON_NAME, namespace = ...
local GAME_LOCALE = GetLocale()
local L = {}
namespace.L = L

L.ENCHANT_REQUIRES = "Enchantment Requires"
L.SOCKET_REQUIRES = "Socket Requires"
L.MADE_BY = "Made by"

L.BONUS_COLOR = "Bonus color"
L.ENCHANT_COLOR = "Enchant color"
L.REFORGE_COLOR = "Reforge color"

L.HIDE_BLANK = "Hide blank lines"
L.HIDE_CLICKBUY = "Hide buying instructions"
L.HIDE_CLICKSOCKET = "Hide socketing instructions"
L.HIDE_DIFFICULTY = "Hide raid difficulty tags"
L.HIDE_DURABILITY = "Hide durability"
L.HIDE_EQUIPSETS = "Hide equipment sets"
L.HIDE_ILEVEL = "Hide item levels"
L.HIDE_REQUIREMENTS = "Hide requirements"
L.HIDE_REQUIREMENTS_TIP = "Hide class, level, race, reputation, and tradeskill requirements."
L.HIDE_REQUIREMENTS_MET = "Only met requirements"
L.HIDE_TAG = "Hide %q tags"
L.HIDE_TRANSMOG = "Hide transmogrified info"
L.HIDE_TRANSMOG_LABEL = "Only label"
L.HIDE_TRANSMOG_LABEL_TIP = "Hide the \"Transmogrified to\" label, but leave the name of the transmogrified item."
L.HIDE_UPGRADE = "Hide upgrade level"
L.HIDE_VALUE = "Hide vendor values"
L.HIDE_VALUE_TIP = "Hide vendor values, except while interacting with a vendor, at the auction house, or choosing a quest reward."

------------------------------------------------------------------------
--	German
--	Last updated 2013-11-30 by Phanx
-- Previous contributors: litastep
------------------------------------------------------------------------

if GAME_LOCALE == "deDE" then

	L.ENCHANT_REQUIRES = "Verzauberung benötigt"
	L.SOCKET_REQUIRES = "Sockel benötigt"
	L.MADE_BY = "Hergestellt von"

	L.BONUS_COLOR = "Bonusfarbe"
	L.ENCHANT_COLOR = "Verzauberungsfarbe"
	L.REFORGE_COLOR = "Umschmiedefarbe"

	L.HIDE_BLANK = "Leerzeilen ausblenden"
	L.HIDE_CLICKBUY = "Instruktionen zum Kauf ausblenden"
	L.HIDE_CLICKSOCKET = "Instruktionen zum Sockeln ausblenden"
	L.HIDE_DIFFICULTY = "Schlachtzugsschwierigkeit ausblenden"
	L.HIDE_DURABILITY = "Haltbarkeit ausblenden"
	L.HIDE_EQUIPSETS = "Ausrüstungssets ausblenden"
	L.HIDE_ILEVEL = "Gegenstandsstufen ausblenden"
	L.HIDE_REQUIREMENTS = "Anforderungen ausblenden"
	L.HIDE_REQUIREMENTS_TIP = "Anforderungen an Stufe, Ruf und Fertigkeit für Gegenstände, Verzauberungen und Sockel ausblenden."
	L.HIDE_REQUIREMENTS_MET = "Nur erfülltes Anforderungen"
	L.HIDE_TAG = "Etikett %q ausblenden"
	L.HIDE_TRANSMOG = "Transmogrifikationsinfo ausblenden"
	L.HIDE_TRANSMOG_LABEL = "Nur das Etikett"
	L.HIDE_TRANSMOG_LABEL_TIP = "Das Etikett \"Transmogrifiziert zu\" ausblenden, aber den Namen des transmogrifizierten Gegenstand gezeigt halten."
	L.HIDE_UPGRADE = "Aufwerten"
	L.HIDE_VALUE = "Händlerpreis ausblenden"
	L.HIDE_VALUE_TIP = "Händlerpreis ausblenden, außer wenn das Händlerfenster, Auktionsfenster oder Questbelohnungsfenster angezeigt wird."

------------------------------------------------------------------------
--	Spanish
--	Last updated 2012-07-21 by Phanx
------------------------------------------------------------------------

elseif GAME_LOCALE == "esES" or GAME_LOCALE == "esMX" then

	L.ENCHANT_REQUIRES = "Encantamiento requiere"
	L.SOCKET_REQUIRES = "Ranura requiere"
	L.MADE_BY = "Hecho por"

	L.BONUS_COLOR = "Color de bonos"
	L.ENCHANT_COLOR = "Color de encantamientos"
	L.REFORGE_COLOR = "Color de estadísticas reforjadas"

	L.HIDE_BLANK = "Ocultar líneas vacias"
	L.HIDE_CLICKBUY = "Ocultar instrucciones de comprar"
	L.HIDE_CLICKSOCKET = "Ocultar instrucciones de gemas"
	L.HIDE_DIFFICULTY = "Occultar dificultad de banda"
	L.HIDE_DURABILITY = "Ocultar durabilidad"
	L.HIDE_EQUIPSETS = "Ocultar equipamientos"
	L.HIDE_ILEVEL = "Ocultar niveles de objecto"
	L.HIDE_REQUIREMENTS = "Ocultar requisitos"
	L.HIDE_REQUIREMENTS_TIP = "Ocultar los requisitos de nivel, reputación y habilidad para los objetos, encantamientos y ranuras."
	L.HIDE_REQUIREMENTS_MET = "Sólo satisfechas"
	L.HIDE_TAG = "Ocultar %q"
	L.HIDE_TRANSMOG = "Ocultar info transfiguración"
	L.HIDE_TRANSMOG_LABEL = "Sólo etiqueta"
	L.HIDE_TRANSMOG_LABEL_TIP = "Sólo ocultar la etiqueta \"Transfigurado a\", manteniendo visible el nombre del objeto transfigurado."
	L.HIDE_UPGRADE = "Ocultar nivel de mejora"
	L.HIDE_VALUE = "Ocultar precio de venta"
	L.HIDE_VALUE_TIP = "Ocultar los precios de venta, excepto en la interacción con con un vendedor, en la casa de subastas, o en la elección de una recompensa de misión."

------------------------------------------------------------------------
--	French
--	Last updated ...
------------------------------------------------------------------------

elseif GAME_LOCALE == "frFR" then

	L.ENCHANT_REQUIRES = "L'enchantement requiert"
	L.SOCKET_REQUIRES = "Le sertissage requiert"
	L.MADE_BY = "Artisan"

--	L.BONUS_COLOR = ""
--	L.ENCHANT_COLOR = ""
--	L.REFORGE_COLOR = ""

	L.HIDE_BLANK = "Masquer lignes vides"
--	L.HIDE_CLICKBUY = ""
--	L.HIDE_CLICKSOCKET = ""
--	L.HIDE_DIFFICULTY = ""
--	L.HIDE_DURABILITY = ""
--	L.HIDE_EQUIPSETS = ""
--	L.HIDE_ILEVEL = ""
--	L.HIDE_REQUIREMENTS = ""
--	L.HIDE_REQUIREMENTS_TIP = ""
--	L.HIDE_REQUIREMENTS_MET = ""
--	L.HIDE_TAG = ""
--	L.HIDE_TRANSMOG = ""
--	L.HIDE_TRANSMOG_LABEL = ""
--	L.HIDE_TRANSMOG_LABEL_TIP = ""
--	L.HIDE_UPGRADE = ""
--	L.HIDE_VALUE = ""
--	L.HIDE_VALUE_TIP = ""

------------------------------------------------------------------------
--	Italian
--	Last updated ...
------------------------------------------------------------------------

elseif GAME_LOCALE == "itIT" then

	L.ENCHANT_REQUIRES = "L'incantamento richiede"
	L.SOCKET_REQUIRES = "L'incavo richiede"
	L.MADE_BY = "Creazione di"

--	L.BONUS_COLOR = ""
--	L.ENCHANT_COLOR = ""
--	L.REFORGE_COLOR = ""

	L.HIDE_BLANK = "Nascondere righe vuote"
--	L.HIDE_CLICKBUY = ""
--	L.HIDE_CLICKSOCKET = ""
--	L.HIDE_DIFFICULTY = ""
	L.HIDE_DURABILITY = "Nascondere durabilità"
--	L.HIDE_EQUIPSETS = ""
--	L.HIDE_ILEVEL = ""
--	L.HIDE_REQUIREMENTS = ""
--	L.HIDE_REQUIREMENTS_TIP = ""
--	L.HIDE_REQUIREMENTS_MET = ""
--	L.HIDE_TAG = ""
--	L.HIDE_TRANSMOG = ""
--	L.HIDE_TRANSMOG_LABEL = ""
--	L.HIDE_TRANSMOG_LABEL_TIP = ""
--	L.HIDE_UPGRADE = ""
--	L.HIDE_VALUE = ""
--	L.HIDE_VALUE_TIP = ""

------------------------------------------------------------------------
--	Portuguese
--	Last updated 2011-12-11 by Phanx
------------------------------------------------------------------------

elseif GAME_LOCALE == "ptBR" then

	L.ENCHANT_REQUIRES = "Encantamento requer"
	L.SOCKET_REQUIRES = "Engaste requer"
	L.MADE_BY = "Criado por"

	L.BONUS_COLOR = "Cor do bônus"
	L.ENCHANT_COLOR = "Cor do encantamentos"
--	L.REFORGE_COLOR = ""

	L.HIDE_BLANK = "Ocultar linhas vazias"
	L.HIDE_CLICKBUY = "Ocultar instruções para comprar"
	L.HIDE_CLICKSOCKET = "Ocultar instruções para engastar"
--	L.HIDE_DIFFICULTY = ""
	L.HIDE_DURABILITY = "Ocultar durabilidade"
	L.HIDE_EQUIPSETS = "Ocultar conjunto de equipamentos"
	L.HIDE_ILEVEL = "Ocultar níveis de itens"
	L.HIDE_REQUIREMENTS = "Ocultar requisitos"
	L.HIDE_REQUIREMENTS_TIP = "Ocultar os requisitos de nível, reputação e habilidade para os itens, encantamentos e engastes."
--	L.HIDE_REQUIREMENTS_MET = ""
	L.HIDE_TAG = "Ocultar texto %q"
--	L.HIDE_TRANSMOG = ""
--	L.HIDE_TRANSMOG_LABEL = ""
--	L.HIDE_TRANSMOG_LABEL_TIP = ""
--	L.HIDE_UPGRADE = ""
	L.HIDE_VALUE = "Esconder preço de venda"
	L.HIDE_VALUE_TIP = "Ocultar preço de venda, exceto quando interagem com um vendedor, na casa de leilões, o da escolha uma recompensa de missão."

------------------------------------------------------------------------
--	Russian
--	Last updated 2014-08-18 by Yafis
-- Previous contributors: D_Angel
------------------------------------------------------------------------

elseif GAME_LOCALE == "ruRU" then

	L.ENCHANT_REQUIRES = "Для наложения чар"
	L.SOCKET_REQUIRES = "Для (использования )?гнезда [тп][ре][ер][бс][уо][ен][та][сж]я?( должен быть не младше)?"
	L.MADE_BY = "Изготовитель"

	L.BONUS_COLOR = "Цвет бонусы"
	L.ENCHANT_COLOR = "Цвет зачарования"
	L.REFORGE_COLOR = "Цвет перековки"

	L.HIDE_BLANK = "Скрыть пустые строки"
	L.HIDE_CLICKBUY = "Скрыть инструкцию о покупке"
	L.HIDE_CLICKSOCKET = "Скрыть инструкции о гнездах"
	L.HIDE_DIFFICULTY = "Скрыть сложность рейда"
	L.HIDE_DURABILITY = "Скрыть прочность"
	L.HIDE_EQUIPSETS = "Скрыть комплекты экипировки"
	L.HIDE_ILEVEL = "Скрыть уровень предметов"
	L.HIDE_REQUIREMENTS = "Скрыть требования"
	L.HIDE_REQUIREMENTS_TIP = "Скрыть требования уровня, репутации и навыка профессии для предметов, чар и гнезд."
	L.HIDE_REQUIREMENTS_MET = "Только довольные требования"
	L.HIDE_TAG = "Скрыть текст %q"
	L.HIDE_TRANSMOG = "Скрыть информацию об трансмогрификации"
	L.HIDE_TRANSMOG_LABEL = "Только ярлык"
	L.HIDE_TRANSMOG_LABEL_TIP = "Скрыть ярлык трансмогрификации, но оставить имя трансмогрифицированного предмета."
	L.HIDE_UPGRADE = "Скрыть уровень улучшения"
	L.HIDE_VALUE = "Скрыть цену торговцев"
	L.HIDE_VALUE_TIP = "Скрыть цену торговцев, кроме случаев взаимодействия с торговцем, в аукционном доме, или при выборе награды за задание."

------------------------------------------------------------------------
--	Korean
--	Last updated ...
------------------------------------------------------------------------

elseif GAME_LOCALE == "koKR" then

	L.ENCHANT_REQUIRES = "마법부여"
	L.SOCKET_REQUIRES = "보석 홈"
	L.MADE_BY = "제작자"

--	L.BONUS_COLOR = ""
--	L.ENCHANT_COLOR = ""
--	L.REFORGE_COLOR = ""

--	L.HIDE_BLANK = ""
--	L.HIDE_CLICKBUY = ""
--	L.HIDE_CLICKSOCKET = ""
--	L.HIDE_DIFFICULTY = ""
--	L.HIDE_DURABILITY = ""
--	L.HIDE_EQUIPSETS = ""
--	L.HIDE_ILEVEL = ""
--	L.HIDE_REQUIREMENTS = ""
--	L.HIDE_REQUIREMENTS_TIP = ""
--	L.HIDE_REQUIREMENTS_MET = ""
--	L.HIDE_TAG = ""
--	L.HIDE_TRANSMOG = ""
--	L.HIDE_TRANSMOG_LABEL = ""
--	L.HIDE_TRANSMOG_LABEL_TIP = ""
--	L.HIDE_UPGRADE = ""
--	L.HIDE_VALUE = ""
--	L.HIDE_VALUE_TIP = ""

------------------------------------------------------------------------
--	Simplified Chinese
--	Last updated 2013-04-15 by lsjyzjl
-- Previous contributors: digmouse
------------------------------------------------------------------------

elseif GAME_LOCALE == "zhCN" then

	L.ENCHANT_REQUIRES = "附魔要求"
	L.SOCKET_REQUIRES = "插槽要求"
	L.MADE_BY = "由谁制造"

	L.BONUS_COLOR = "加成颜色"
	L.ENCHANT_COLOR = "强化属性颜色"
	L.REFORGE_COLOR = "重铸颜色"

	L.HIDE_BLANK = "隐藏空行"
	L.HIDE_CLICKBUY = "隐藏购买提示"
	L.HIDE_CLICKSOCKET = "隐藏镶嵌宝石提示"
--	L.HIDE_DIFFICULTY = ""
	L.HIDE_DURABILITY = "隐藏耐久度"
	L.HIDE_EQUIPSETS = "隐藏装备方案"
	L.HIDE_ILEVEL = "隐藏物品等级"
	L.HIDE_REQUIREMENTS = "隐藏需求"
	L.HIDE_REQUIREMENTS_TIP = "隐藏物品、附魔和插槽的等级、声望和技能需求。"
	L.HIDE_REQUIREMENTS_MET = "仅符合条件"
	L.HIDE_TAG = "隐藏 %q 标签"
	L.HIDE_TRANSMOG = "隐藏幻化信息"
	L.HIDE_TRANSMOG_LABEL = "仅标签"
	L.HIDE_TRANSMOG_LABEL_TIP = "隐藏\"幻化为\"的标签,但保留幻化物品名称."
	L.HIDE_UPGRADE = "隐藏升级的等级"
	L.HIDE_VALUE = "隐藏卖价"
	L.HIDE_VALUE_TIP = "除非和商人交易，否则隐藏卖价。"

------------------------------------------------------------------------
--	Traditional Chinese
--	Last updated 2013-04-17 by BNSSNB
------------------------------------------------------------------------

elseif GAME_LOCALE == "zhTW" then

	L.ENCHANT_REQUIRES = "附魔需要"
	L.SOCKET_REQUIRES = "插槽需求"
	L.MADE_BY = "製造於"

	L.BONUS_COLOR = "加成顏色"
	L.ENCHANT_COLOR = "附魔顏色"
	L.REFORGE_COLOR = "重鑄顏色"

	L.HIDE_BLANK = "隱藏空白行"
	L.HIDE_CLICKBUY = "隱藏購買說明"
	L.HIDE_CLICKSOCKET = "隱藏插槽說明"
--	L.HIDE_DIFFICULTY = ""
	L.HIDE_DURABILITY = "隱藏耐久度"
	L.HIDE_EQUIPSETS = "隱藏套裝資訊"
	L.HIDE_ILEVEL = "隱藏物品等級"
	L.HIDE_REQUIREMENTS = "隱藏需要條件"
	L.HIDE_REQUIREMENTS_TIP = "隱藏職業、等級、種族、聲望與專業技能的需要。"
	L.HIDE_REQUIREMENTS_MET = "僅符合需求"
	L.HIDE_TAG = "隐藏%q行"
	L.HIDE_TRANSMOG = "隱藏塑型訊息"
	L.HIDE_TRANSMOG_LABEL = "只有標籤"
	L.HIDE_TRANSMOG_LABEL_TIP = "隱藏\"塑型為\"的標籤，但保留塑型物品的名稱。"
	L.HIDE_UPGRADE = "隱藏升級的等級"
	L.HIDE_VALUE = "隱藏商店價格"
	L.HIDE_VALUE_TIP = "隱藏商店價格，除非與商店互動，或是在拍賣場，或是選擇任務獎賞的時候。"

end