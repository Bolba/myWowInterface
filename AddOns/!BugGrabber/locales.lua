local bugGrabberParentAddon, parentAddonTable = ...
local addon = parentAddonTable.BugGrabber
-- Bail out in case we didn't load up for some reason, which
-- happens for example when an embedded BugGrabber finds a
-- standalone !BugGrabber addon.
if not addon then return end

-- We don't need to bail out here if BugGrabber has been loaded from
-- some other embedding addon already, because :LoadTranslations is
-- only invoked on login. All we do is replace the method with a new
-- one that will never be invoked.

function addon:LoadTranslations(locale, L)
	if locale == "koKR" then
L["ADDON_CALL_PROTECTED"] = "[%s] 애드온 '%s' 보호된 함수 호출 '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (애드온 '.*' 보호된 함수 호출 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r와 |cffffff7f%s|r는 함께 공존할 수 없습니다. |cffffff7f%s|r에 의해 중지되었습니다. 만약 당신이 원하면, 접속을 종료한 후, |cffffff7fBugGrabber|r를 중지하고 |cffffff7f%s|r를 재활성하세요." -- Needs review
L["BUGGRABBER_STOPPED"] = "이것은 초당 %d개 이상의 오류를 발견하였기에 |cffffff7fBugGrabber|r의 오류 캡쳐가 중지되었으며, 캡쳐는 %d초 후 재개됩니다." -- Needs review
L["NO_DISPLAY_1"] = "|cffff4411당신은 미표시 애드온과 함께 !BugGrabber를 실행할 것으로 보입니다. !BugGrabber는 게임 오류 확인을 위한 슬래시 명령어를 제공하고 있지만, 표시 애드온은 당신이 더 편리한 방법으로 이러한 오류를 관리할 수 있습니다.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411표준 !BugGrabber 표시는|r |cff44ff44BugSack|r|cffff4411으로 불러오며, 그리고 아마도 당신은 !BugGrabber를 발견한 동일 사이트에서 찾을 수 있습니다.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cffff4411만약 당신이 이것에 대해 다시 떠올리고 싶지 않다면, |cff44ff44/stopnag|r|cffff4411를 실행하세요.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber는 오류에 관해 성가시게 하지 않으며 |r|cff44ff44BugSack|r|cffff4411의 다음 패치때까지만 입니다.|r" -- Needs review
L["USAGE"] = "사용법: /buggrabber <1-%d>." -- Needs review

	elseif locale == "deDE" then
L["ADDON_CALL_PROTECTED"] = "[%s] AddOn '%s' hat versucht die geschützte Funktion '%s' aufzurufen."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (AddOn '.*' hat versucht die geschützte Funktion '.*' aufzurufen.)$"
L["ADDON_DISABLED"] = "|cffffff00!BugGrabber und %s können nicht zusammen laufen, %s wurde deshalb deaktiviert. Wenn du willst, kannst du ausloggen, !BugGrabber deaktivieren und %s wieder aktivieren.|r"
L["BUGGRABBER_STOPPED"] = "|cffffff00In deinem UI treten zu viele Fehler auf, als Folge davon könnte dein Spiel langsamer laufen. Deaktiviere oder aktualisiere die fehlerhaften Addons, wenn du diese Meldung nicht mehr sehen willst.|r"
L["ERROR_DETECTED"] = "%s |cffffff00gefangen, klicke auf den Link für mehr Informationen.|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber kann selbst keine Fehler von anderen Spielern anzeigen. Bitte installiere BugSack oder ein vergleichbares Display-Addon, das dir diese Funktionalität bietet.|r"
L["NO_DISPLAY_1"] = "|cffffff00Anscheinend benutzt du !BugGrabber ohne dazugehörigem Display-Addon. Zwar bietet !BugGrabber Slash-Befehle, um auf die Fehler zuzugreifen, mit einem Display-Addon wäre die Fehlerverwaltung aber bequemer.|r"
L["NO_DISPLAY_2"] = "|cffffff00Die Standardanzeige heißt BugSack und kann vermutlich auf der Seite gefunden werden, wo du auch !BugGrabber gefunden hast.|r"
L["NO_DISPLAY_STOP"] = "|cffffff00Wenn du diesen Hinweis nicht mehr sehen willst, gib /stopnag ein.|r"
L["STOP_NAG"] = "|cffffff00!BugGrabber wird bis zum nächsten Patch nicht mehr auf ein fehlendes Display-Addon hinweisen.|r"
L["USAGE"] = "|cffffff00Benutzung: /buggrabber <1-%d>.|r"

	elseif locale == "esES" then
L["ADDON_CALL_PROTECTED"] = "[%s] El accesorio '%s' ha intentado llamar a la función protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (El accesorio '.*' ha intentado llamar a la función protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r y |cffffff7f%s|r no pueden coexistir juntos. |cffffff7f%s|r ha sido desactivado por este motivo. Si lo deseas, puedes salir, desactivar |cffffff7fBugGrabber|r y reactivar |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r ha detenido la captuta de errores, ya que ha capturado más de %d errores por segundo. La captura se reanudará en %d segundos." -- Needs review
L["NO_DISPLAY_1"] = "|cffff441Parece que estás ejecutando !BugGrabber sin un accessorio de visualización para acompañarlo. Aunque !BugGrabber proporciona un comando para ver a los errores en el juego, un addon de visualización pueden ayudar a gestionar estos errores de una manera más conveniente.|r  " -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411El accesorio estándar de visualización para !BugGrabber se llama |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar descargó BugSack.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cff4411Si no quieres verá este mensaje nuevamente, por favor escriba |r|cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411BugGrabber no te recordará sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 de nuevo hasta el próximo parche.|r" -- Needs review
L["USAGE"] = "Uso: /buggrabber <1-%d>." -- Needs review

	elseif locale == "zhTW" then
L["ADDON_CALL_PROTECTED"] = "[%s] 插件 '%s' 嘗試調用保護功能 '%s'。"
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (插件 '.*' 嘗試調用保護功能 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r 和 |cffffff7f%s|r 不能共存。|cffffff7f%s|r 已停用。可在插件介面停用 |cffffff7fBugGrabber|r，再用 |cffffff7f%s|r。" -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r 現正暫停，因為每秒捕捉到超過%d個錯誤。它會在%d秒後重新開始。" -- Needs review
L["USAGE"] = "用法：/buggrabber <1-%d>。" -- Needs review

	elseif locale == "zhCN" then
L["ADDON_CALL_PROTECTED"] = "[%s] 插件 '%s' 尝试调用保护功能 '%s'。"
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (插件 '.*' 尝试调用保护功能 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r 和 |cffffff7f%s|r 不能共存。|cffffff7f%s|r 已停用。可在插件界面停用 |cffffff7fBugGrabber|r 再用 |cffffff7f%s|r。" -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r 现正暂停，因为每秒捕捉到超过%d个错误。它会在%d秒后重新开始。" -- Needs review
L["NO_DISPLAY_STOP"] = "|cffff4411如果你不希望再次被提醒, 请输入 |cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["USAGE"] = "用法：/buggrabber <1-%d>。" -- Needs review

	elseif locale == "ruRU" then
L["ADDON_CALL_PROTECTED"] = "[%s] Аддон '%s' пытался вызвать защищенную функцию '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (Аддон '.*' пытался вызвать защищенную функцию '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r и |cffffff7f%s|r не могут работать вместе. Поэтому |cffffff7f%s|r был отключен. Если хотите, можете выйти из игрового мира,отключить |cffffff7fBugGrabber|r и включить |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r прекратил захватывать ошибки, так как захватил более %d ошибок  в секунду. Захват возобновится через %d секунд." -- Needs review
L["NO_DISPLAY_1"] = "|cffff4411Кажется, !BugGrabber запущен без поддержки аддона для отображения информации. Хотя !BugGrabber предоставляет слеш-команды для доступа к внутриигровым ошибкам, визуализирующий аддон может показать их в более удобной форме.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411Стандартный аддон для отображения информации от !BugGrabber называется |r|cff44ff44BugSack|r|cffff4411, и может быть найден там же, где вы нашли !BugGrabber.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cffff4411Если вам не нравятся напоминания об этом, наберите |cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber больше не будет напоминать об отсутствующем |r|cff44ff44BugSack|r|cffff4411 до следующего патча.|r" -- Needs review
L["USAGE"] = "Использование: /buggrabber <1-%d>." -- Needs review

	elseif locale == "frFR" then
L["ADDON_CALL_PROTECTED"] = "[%s] L'AddOn '%s' a tenté d'appeler la fonction protégée '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (L'AddOn '.*' a tenté d'appeler la fonction protégée '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r et |cffffff7f%s|r ne peuvent pas être lancés en même temps. |cffffff7f%s|r a été désactivé. Si vous le souhaitez, vous pouvez vous déconnecter, désactiver |cffffff7fBugGrabber|r et réactiver |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r a cessé de capturer des erreurs, car plus de %d erreurs ont été capturées par seconde. La capture sera reprise dans %d secondes." -- Needs review
L["NO_DISPLAY_1"] = "|cffff4411Vous ne semblez pas utiliser !BugGrabber avec un add-on d'affichage. Bien que les erreurs enregistrées par !BugGrabber soient accessibles par ligne de commande, un add-on d'affichage peut vous aidez à gérer ces erreurs plus aisément.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411L'add-on d'affichage originel s'appelle |r|cff44ff44BugSack|r|cffff4411, vous devriez pouvoir le trouver sur le même site que !BugGrabber.|r" -- Needs review
L["NO_DISPLAY_STOP"] = [=[|cffff4411Pour ne plus voir ce rappel, utiliser la commande |cff44ff44/stopnag|r|cffff4411.|r
]=] -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber ne vous rappellera plus l'existence de |r|cff44ff44BugSack|r|cffff4411 jusqu'à la prochaine mise à jour.|r" -- Needs review
L["USAGE"] = "Utilisation: /buggrabber <1-%d>." -- Needs review

	elseif locale == "esMX" then
L["ADDON_CALL_PROTECTED"] = "[%s] El accesorio '%s' ha intentado llamar a la función protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (El accesorio '.*' ha intentado llamar a la función protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r y |cffffff7f%s|r no pueden coexistir juntos. |cffffff7f%s|r ha sido desactivado por este motivo. Si lo deseas, puedes salir, desactivar |cffffff7fBugGrabber|r y reactivar |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r ha detenido la captuta de errores, ya que ha capturado más de %d errores por segundo. La captura se reanudará en %d segundos." -- Needs review
L["NO_DISPLAY_1"] = "|cffff441Parece que estás ejecutando !BugGrabber sin un accessorio de visualización para acompañarlo. Aunque !BugGrabber proporciona un comando para ver a los errores en el juego, un addon de visualización pueden ayudar a gestionar estos errores de una manera más conveniente.|r  " -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411El accesorio estándar de visualización para !BugGrabber se llama |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar descargó BugSack.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cff4411Si no quieres verá este mensaje nuevamente, por favor escriba |r|cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411BugGrabber no te recordará sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 de nuevo hasta el próximo parche.|r" -- Needs review
L["USAGE"] = "Uso: /buggrabber <1-%d>." -- Needs review

	elseif locale == "ptBR" then
L["ADDON_CALL_PROTECTED"] = "[%s] O AddOn '%s' tentou chamar a função protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (AddOn '.*' tentou chamar a função protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r e |cffffff7f%s|r não podem existir juntos. |cffffff7f%s|r foi desabilitado por causa disso. Se você quiser, você pode sair, desabilitar o |cffffff7fBugGrabber|r e habilitar o |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r parou de capturar erros, já que capturou mais de %d erros por segundo. A captura será resumida em %d segundos." -- Needs review
L["NO_DISPLAY_1"] = "|cffff4411Aparentemente você está usando !BugGrabber sem nenhum addon de exibição para acompanhá-lo. Apesar do !BugGrabber fornecer um comando para acessar os erros dentro do jogo, um addon de exibição pode ajudar você a gerenciar esses erros de uma forma mais conveniente.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411O exibidor padrão do !BugGrabber é conhecido por |r|cff44ff44BugSack|r|cffff4411, e pode provavelmente ser encontrado no mesmo site onde você achou o !BugGrabber.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cffff4411Se você não deseja ser lembrado disso novamente, por favor utilize o comando |cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber não irá perturbar sobre não ter detectado o |r|cff44ff44BugSack|r|cffff4411 até a próxima atualização.|r" -- Needs review
L["USAGE"] = "Uso: /buggraber <1-%d>" -- Needs review

	elseif locale == "itIT" then
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r e |cffffff7f%s|r non possono essere contemporaneamente installati. |cffffff7f%s|r è stato quindi disabilitato. Se vuoi, puoi uscire dal gioco, disabilitare |cffffff7fBugGrabber|r e riattivare |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r ha smesso di catturare errori, poichè ha catturato più di %d errori al second. La cattura riprenderà tra %d secondi." -- Needs review
L["NO_DISPLAY_1"] = "lcffff4411Sembra che tu stia eseguendo !BugGrabber senza alcun addon che ne visualizzi gli errori. Anche se !BugGrabber ha un comando per visualizzarli nella chat, un addon aggiuntivo per visualizzarli potrebbe esserti utile.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411L'addon standard per la visualizzazione degli errori catturati da !BugGrabber si chiama |r|cff44ff44BugSack|r|cffff4411, e molto probabilmente lo puoi trovare sullo stesso sito dove hai trovato !BugGrabber.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cffff4411Se non vuoi visualizzare più questo messaggio, esegui il comando |cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber non ti ricorderà più di installare |r|cff44ff44BugSack|r|cffff4411 fino al prossimo aggiornamento.|r" -- Needs review
L["USAGE"] = "Uso: /buggrabber <1-%d>." -- Needs review

	end
end

