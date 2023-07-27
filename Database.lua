local name, addon = ...;

local json = LibStub('JsonLua-1.0');

local Database = {}

local configUpdates = {

    --tradeskills
    tradeskillsRecipesListviewShowItemID = false,


    --settings
    chatGuildHistoryLimit = 50,
    chatWhisperHistoryLimit = 50,

    tradeskillsShowAllRecipeInfoTooltip = false,
    tradeskillsShowMyRecipeInfoTooltip = false,

    tradeskillsShowAllRecipesUsingTooltip = false,
    tradeskillsShowMyRecipesUsingTooltip = false,
}

function Database:Init()

    local version = tonumber(GetAddOnMetadata(name, "Version"));

    if not GUILDBOOK_GLOBAL.version then
        GUILDBOOK_GLOBAL = nil
    else
        if GUILDBOOK_GLOBAL.version < version then
            
        end
    end

    if not GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL = {
            config = {
                chatGuildHistoryLimit = 50,
                chatWhisperHistoryLimit = 50,
            },
            minimapButton = {},
            calendarButton = {},
            guilds = {},
            worldEvents = {},
            myCharacters = {},
            characterDirectory = {},
            chats = {
                guild = {},
            },
            debug = false,
            version = version,
        }
    end

    self.db = GUILDBOOK_GLOBAL;

    for k, v in pairs(configUpdates) do
        if not self.db.config[k] then
            self.db.config[k] = v;
        end
    end

    addon:TriggerEvent("StatusText_OnChanged", "[Database_OnInitialised]")
    addon:TriggerEvent("Database_OnInitialised")
end

function Database:Reset()

    GUILDBOOK_WRATH_GLOBAL = {
        config = {
            chatGuildHistoryLimit = 50,
            chatWhisperHistoryLimit = 50,
        },        
        minimapButton = {},
        calendarButton = {},
        guilds = {},
        worldEvents = {},
        myCharacters = {},
        characterDirectory = {},
        chats = {
            guild = {},
        },
        debug = false,
    }

    self.db = GUILDBOOK_WRATH_GLOBAL;

    addon.guilds = {}
    addon.characters = {}

    addon:TriggerEvent("StatusText_OnChanged", "[Database:Reset]")
    addon:TriggerEvent("Database_OnInitialised")
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

function Database:GetCharacter(nameRealm)
    if self.db and self.db.characterDirectory[nameRealm] then
        return self.db.characterDirectory[nameRealm];
    end
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

addon.Database = Database;