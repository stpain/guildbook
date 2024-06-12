local name, addon = ...;

local json = LibStub('JsonLua-1.0');

local Database = {}

local configUpdates = {

    --tradeskills
    tradeskillsRecipesListviewShowItemID = false,
    tradeskillsShareCooldowns = false,
    tradeskillsShowAllRecipeInfoTooltip = false,
    tradeskillsShowMyRecipeInfoTooltip = false,
    tradeskillsShowAllRecipesUsingTooltip = false,
    tradeskillsShowMyRecipesUsingTooltip = false,

    --settings
    chatGuildHistoryLimit = 30,
    chatWhisperHistoryLimit = 30,
    showMainCharacterInChat = true,
    showMainCharacterSpecInChat = true,
    wholeNineYards = false,
    enhancedPaperDoll = true,

    modBlizzRoster = false,
}

local dbUpdates = {
    calendar = {
        events = {},
    },
    dailies = {
        quests = {},
        characters = {},
    },
    chats = { --some errors about this causing a bug, maybe old version not getting update in the past
        guild = {},
    },
    --agenda = {},
    itemLists = {},

    recruitment = {},
}
local dbToRemove = {
    "worldEvents",
    "calendar.birthdays",
    "news",
}

function Database:Init()

    local version = tonumber(GetAddOnMetadata(name, "Version"));

    if not GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL = {
            config = {
                chatGuildHistoryLimit = 50,
                chatWhisperHistoryLimit = 50,
            },
            minimapButton = {},
            calendarButton = {},
            guilds = {},
            myCharacters = {},
            characterDirectory = {},
            chats = {
                guild = {},
            },
            debug = false,
            version = version,
            calendar = {
                events = {},
            },
            dailies = {
                quests = {},
                characters = {},
            },
        }
    end

    self.db = GUILDBOOK_GLOBAL;

    for k, v in pairs(dbUpdates) do
        if not self.db[k] then
            self.db[k] = v;
        end
    end
    for k, v in ipairs(dbToRemove) do
        if v:find(".", nil, true) then --if k:find(".", nil, true) then
            local k1, k2 = strsplit(".", v)
            if k1 and k2 then
                if self.db[k1] and self.db[k1][k2] then
                    self.db[k1][k2] = nil
                    addon.LogDebugMessage("warning", string.format("removed %s from %s", k2, k1))
                end
            end
        else
            self.db[v] = nil;
            addon.LogDebugMessage("warning", string.format("removed %s from db", v))
        end
    end

    for k, v in pairs(configUpdates) do
        if not self.db.config[k] then
            self.db.config[k] = v;
        end
    end

    --there might be old data so clear it out
    if type(GUILDBOOK_CHARACTER) == "table" then
        if not GUILDBOOK_CHARACTER.syncData then
            GUILDBOOK_CHARACTER = nil;
        end
    end


    --per character settings
    if not GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER = {
            syncData = {
                mainCharacter = 0,
                publicNote = 0,
                mainSpec = 0,
                offSpec = 0,
                mainSpecIsPvP = 0,
                offSpecIsPvP = 0,
                profile = 0,
                profession1 = 0,
                profession1Level = 0,
                profession1Spec = 0,
                profession1Recipes = 0,
                profession2 = 0,
                profession2Level = 0,
                profession2Spec = 0,
                profession2Recipes = 0,
                cookingLevel = 0,
                cookingRecipes = 0,
                fishingLevel = 0,
                firstAidLevel = 0,
                firstAidRecipes = 0,
                talents = 0,
                glyphs = 0,
                inventory = 0,
                paperDollStats = 0,
                resistances = 0,
                auras = 0,
                containers = 0,
                lockouts = 0,
            },
        }
    end

    self.charDb = GUILDBOOK_CHARACTER;

    self:RemoveRedundantGuildSavedVaariableFields()


    addon:TriggerEvent("StatusText_OnChanged", "[Database_OnInitialised]")
    addon:TriggerEvent("Database_OnInitialised")
end

function Database:RemoveRedundantGuildSavedVaariableFields()
    if self.db then
        for guildName, guild in pairs(self.db.guilds) do
            guild.info = nil
            guild.calendar = nil
            guild.banks = nil
            guild.bankRules = nil
        end
    end
end

function Database:Reset()

    GUILDBOOK_GLOBAL = nil;

    addon.guilds = {}
    addon.characters = {}

    self:Init()
end

function Database:InsertNewsEevnt(event)
    if self.db and self.db.news then
        table.insert(self.db.news, event)
        addon:TriggerEvent("Database_OnNewsEventAdded", event)
    end
end

function Database:ResetKey(key, newVal)
    if self.db[key] then
        self.db[key] = newVal;
    end
end

function Database:ImportData(data)
    local import = json.decode(data)
    if import then
        if import.name and import.data and import.version then
            DevTools_Dump(import)
        end
    end
end

function Database:InsertCharacter(character)
    if self.db then
        self.db.characterDirectory[character.name] = character;
        addon:TriggerEvent("StatusText_OnChanged", string.format("[InsertCharacter] %s", character.name))
    end
end

function Database:DeleteCharacter(nameRealm)
    if self.db then
         if self.db.characterDirectory[nameRealm] then
            self.db.characterDirectory[nameRealm] = nil;
                if addon.characters[nameRealm] then
                    addon.characters[nameRealm] = nil;
                end
            addon:TriggerEvent("Database_OnCharacterRemoved", nameRealm)
         end
    end
end

function Database:GetCharacter(nameRealm)
    if self.db and self.db.characterDirectory[nameRealm] then
        return self.db.characterDirectory[nameRealm];
    end
end

function Database:GetCharacterNameFromGUID(guid)
    if self.db and self.db.characterDirectory then
        for nameRealm, data in pairs(self.db.characterDirectory) do
            if data.guid and (data.guid == guid) then
                return nameRealm;
            end
        end
    end
end

function Database:InsertCalendarEvent(event)
    if self.db and self.db.calendar then
        if not self.db.calendar.events then
            self.db.calendar.events = {}
        end
        event.guid = string.format("CalendarEvent-%s", time())
        table.insert(self.db.calendar.events, event)
        addon:TriggerEvent("Database_OnCalendarDataChanged")
    end
end

function Database:DeleteCalendarEvent(event)
    if self.db and self.db.calendar and self.db.calendar.events then
        local keyToRemove;
        for k, v in ipairs(self.db.calendar.events) do
            if (v.guid == event.guid) then
                keyToRemove = k
            end
        end
        if keyToRemove then
            table.remove(self.db.calendar.events, keyToRemove)
            addon:TriggerEvent("Database_OnCalendarDataChanged")
        end
    end
end

function Database:GetCalendarEventsBetween(_from, _to)

    local t = {}
    if not _to then
        _to = _from
    end
    local from = time(_from)
    local to = time(_to)
    if self.db and self.db.calendar and self.db.calendar.events then
        for k, event in ipairs(self.db.calendar.events) do
            if (event.timestamp >= from) and (event.timestamp <= to) then
                table.insert(t, event)
            end
        end
    end
    return t;
end

function Database:GetCalendarEventsForPeriod(fromTimestamp, period)

    local t = {}
    period = period or 1
    local to = fromTimestamp + (60*60*24*period)

    if self.db and self.db.calendar and self.db.calendar.events then
        for k, event in ipairs(self.db.calendar.events) do
            if (event.timestamp >= fromTimestamp) and (event.timestamp <= to) then
                table.insert(t, event)
            end
        end
    end
    return t;
end

function Database:SetConfig(conf, val)
    if self.db and self.db.config then
        self.db.config[conf] = val
        addon:TriggerEvent("Database_OnConfigChanged", conf, val)
    end
end

function Database:GetConfig(conf)
    if self.db and self.db.config then
        return self.db.config[conf];
    end
    return false;
end

function Database:DeleteDailyQuest(questID)
    if self.db and self.db.dailies and self.db.dailies.quests[questID] then
        self.db.dailies.quests[questID] = nil

        if self.db and self.db.dailies and self.db.dailies.characters then
            for nameRealm, quests in pairs(self.db.dailies.characters) do
                quests[questID] = nil
            end
        end
        addon:TriggerEvent("Database_OnDailyQuestDeleted", questID)
    end
end

function Database:GetDailyQuestInfo(questID)
    if self.db and self.db.dailies and self.db.dailies.quests[questID] then
        return self.db.dailies.quests[questID]
    end
    return false;
end

function Database:GetDailyQuestIDsForCharacter(nameRealm, onlyFavourites)
    local t = {}
    if self.db and self.db.dailies and self.db.dailies.characters[nameRealm] then
        for questID, turnInInfo in pairs(self.db.dailies.characters[nameRealm]) do
            if onlyFavourites then
                if onlyFavourites == turnInInfo.isFavorite then
                    table.insert(t, questID)
                end
            else
                table.insert(t, questID)
            end
        end
    end
    return t;
end

function Database:GetDailyQuestInfoForCharacter(nameRealm, onlyFavourites)
    local t = {}
    if self.db and self.db.dailies and self.db.dailies.characters[nameRealm] then
        for questID, turnInInfo in pairs(self.db.dailies.characters[nameRealm]) do
            local turnIn = {}
            for k, v in pairs(turnInInfo) do
                turnIn[k] = v;
            end
            turnIn.questID = questID;
            if onlyFavourites then
                if onlyFavourites == turnInInfo.isFavorite then
                    table.insert(t, turnIn)
                end
            else
                table.insert(t, turnIn)
            end
        end
    end
    return t;
end

function Database:SetCharacterSyncData(key, val)
    if self.charDb then
        self.charDb.syncData[key] = val;
    end
end


function Database:GetCharacterSyncData(key)
    if self.charDb then
        return self.charDb.syncData[key];
    end
    return 0;
end


function Database:GetCharacterAlts(mainCharacter)

    local alts = {}

    if type(mainCharacter) == "string" then
        if self.db then
            for nameRealm, info in pairs(self.db.characterDirectory) do
                if info.mainCharacter == mainCharacter then
                    table.insert(alts, nameRealm)
                end
            end
        end        
    end

    return alts;
end



function Database:InsertRecruitmentCSV(csv)
    if self.db and self.db.recruitment then
        
        local existingEntries = {}
        for k, v in ipairs(self.db.recruitment) do
            existingEntries[v.name] = true;
        end

        for k, v in ipairs(csv) do
            if not existingEntries[v.name] then
                table.insert(self.db.recruitment, v)
            end
        end
    end
end

function Database:DeleteAllRecruit()
    if self.db and self.db.recruitment then
        self.db.recruitment = {}
    end
end

function Database:GetAllRecruitment()
    if self.db and self.db.recruitment then
        return self.db.recruitment;
    end
    return {};
end

function Database:CleanUpRecruitment()
    if self.db and self.db.recruitment then
        for k, v in ipairs(self.db.recruitment) do
            v.isSelected = nil;
        end
    end
end

addon.Database = Database;