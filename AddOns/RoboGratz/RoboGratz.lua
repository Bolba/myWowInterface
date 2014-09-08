RoboGratz = LibStub("AceAddon-3.0"):NewAddon("RoboGratz", "AceEvent-3.0", "AceTimer-3.0")

local defaults = {
    delay = 20,
    delayPlayer = 10,
    answerDelay = {
        min = 2,
        max = 5
    },
    gz = {
        { msg = "gz  {name}", weight = 10 },
        { msg = "gz ", weight = 40 },
        { msg = "gratz ", weight = 30 },
        { msg = "GZ {name}", weight = 10 },
        { msg = "gratz {name}", weight = 10 }
    },
    greet = {
        { msg = "Hallo {name}", weight = 10 },
        { msg = "Hi ", weight = 40 },
        { msg = "Huhu ", weight = 30 },
        { msg = "hallo {name}", weight = 10 },
        { msg = "hai", weight = 10 }
    },
    bye = {
        { msg = "bye {name}", weight = 10 },
        { msg = "tschüss ", weight = 40 },
        { msg = "bb ", weight = 30 },
        { msg = "bis denn {name}", weight = 10 },
        { msg = "tschüss", weight = 10 }
    },
    re = {
        { msg = "wb  {name}", weight = 50 },
        { msg = "wb ", weight = 50 }
    },
    ident_greet = { "abend", "hallo", "huhu", "servus", "sers", "was geht", "halo", "guten morgen", "moin", "hai", "hi", "tag", "holla", "guten abend", "hiya", "hi ya", "hello" },
    ident_bye = { "bye", "tschüss", "tschau", "bis morgen", "bis dann", "bb", "gute nacht", "g8", "nachti", "gn8", "Tschöö" },
    ident_re = { "re", "rehi" }
}

local function weighted_total(choices)
    local total = 0
    for i, v in ipairs(choices) do
        total = total + v.weight
    end
    return total
end

local function weighted_random_choice(choices)
    local threshold = math.random(0, weighted_total(choices))
    local last_choice
    for i, v in ipairs(choices) do
        threshold = threshold - v.weight
        if threshold <= 0 then return v.msg end
        last_choice = v.msg
    end
    return last_choice
end

function RoboGratz:OnEnable()
    self:RegisterEvent("CHAT_MSG_GUILD")
    self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
    self.lastAutoGreet = 0;
end

function RoboGratz:OnDisable()
    self:UnregisterAllEvents()
end

function RoboGratz:ChatMessage(msg)
    SendChatMessage(msg, "GUILD")
end

function RoboGratz:AwnserRequest(identType, awnserType, msg, senderName)
    for i = 1, #defaults[identType] do
        if (string.find(string.gsub(msg, "(.*)", " %1 "), "[^%a]" .. defaults[identType][i] .. "[^%a]")) then
            self:ScheduleTimer("ChatMessage",
                math.random(defaults.answerDelay.min, defaults.answerDelay.max),
                string.gsub(weighted_random_choice(defaults[awnserType]), "{name}", senderName))
            self.lastAutoGreet = time() + defaults.delay
            return
        end
    end
end

function RoboGratz:CHAT_MSG_GUILD(...)

    local _, msg, senderName = ...
    msg = string.lower(msg)
    senderName = string.gsub(senderName, "%-[^|]+", "")

    if (senderName == UnitName("player")) then
        self.lastAutoGreet = time() + defaults.delayPlayer
        return
    end

    if (self.lastAutoGreet < time()) then
        self:AwnserRequest('ident_re', 're', msg, senderName)
        self:AwnserRequest('ident_greet', 'greet', msg, senderName)
        self:AwnserRequest('ident_bye', 'bye', msg, senderName)
    end
end

function RoboGratz:CHAT_MSG_GUILD_ACHIEVEMENT(...)

    local _, _, senderName = ...
    senderName = string.gsub(senderName, "%-[^|]+", "")

    if (senderName == UnitName("player")) then
        self.lastAutoGreet = time() + defaults.delayPlayer
        return
    end

    if (self.lastAutoGreet < time()) then
        self:ScheduleTimer("ChatMessage",
            math.random(defaults.answerDelay.min, defaults.answerDelay.max),
            string.gsub(weighted_random_choice(defaults.gz), "{name}", senderName))
        self.lastAutoGreet = time() + defaults.delay
    end
end

