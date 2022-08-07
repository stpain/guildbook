--[[
    the Database object is intended to initialise the saved variables and check/update the table keys
]]

local addonName, addon = ...;

Database = {};

Database.keys = {
    global = {
        ActivityFeed = {},
        GuildRosterCache = {},
        Debug = false,
        MinimapButton = {},
        WorkOrders = {},
    },
    config = {
		modifyDefaultGuildRoster = true,

		showTooltipTradeskills = false,

		showInfoMessages = true,
		showMinimapButton = false,

        blockCommsDuringCombat = false,
		blockCommsDuringInstance = false,

		showMainCharacterGuildChat = true,
        
        showTooltipMainSpec = true,
		showTooltipMainCharacter = true,

		showTooltipCharacterProfile = true,
	},
    privacy = {
        shareInventoryMinRank = "",
        shareTalentsMinRank = "",
        shareProfileMinRank = "",
    },
};

Database.keysToRemove = {
    global = {
        "CommsDelay",
        "reversedActivityFeed",
        "LastCalendarDeletedTransmit",
        "LastCalendarTransmit",
        "lastVersionUpdate",
        "Calendar",
        "CalendarDeleted",
    },
    config = {
        "parsePublicNotes",
        "showMinimapCalendarButton",
        "showSpecGuildChat",
        "showTooltipProfessions",
        "showTooltipTradeskillsRecipesForCharacter",
        "showTooltipTradeskillsRecipes",
        "showTooltipCharacterInfo",
    },
    privacy = {

    },
};

function Database:Init()

    --setup and check the account wide saved variables
    if not GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL = {};
        addon.DEBUG("func", "Database:Init", "declared global saved variables as new table")
    end

    for k, v in pairs(self.keys.global) do
        if not GUILDBOOK_GLOBAL[k] then
            GUILDBOOK_GLOBAL[k] = v;
        end
    end
    addon.DEBUG("func", "Database:Init", "copied global saved variable keys")
    for k, v in pairs(self.keysToRemove.global) do
        if GUILDBOOK_GLOBAL[v] then
            GUILDBOOK_GLOBAL[v] = nil;
        end
    end
    addon.DEBUG("func", "Database:Init", "removed old global saved variable keys")

    --setup the account wide config saved variables
    if not GUILDBOOK_CONFIG then
        GUILDBOOK_CONFIG = {};
        addon.DEBUG("func", "Database:Init", "declared config saved variables as new table")
    end
    for k, v in pairs(self.keys.config) do
        if not GUILDBOOK_CONFIG[k] then
            GUILDBOOK_CONFIG[k] = v;
        end
    end
    addon.DEBUG("func", "Database:Init", "copied config saved variable keys")
    for k, v in pairs(self.keysToRemove.config) do
        if GUILDBOOK_CONFIG[v] then
            GUILDBOOK_CONFIG[v] = nil;
        end
    end
    addon.DEBUG("func", "Database:Init", "removed old config saved variable keys")

    if GUILDBOOK_GLOBAL.config then
        for k, v in pairs(GUILDBOOK_GLOBAL.config) do
            if k ~= "privacy" then
                if GUILDBOOK_CONFIG[k] then
                    GUILDBOOK_CONFIG[k] = v;
                end
            end
        end
        addon.DEBUG("func", "Database:Init", "copied old config variables into new saved variables")
    end

    --setup the account wide privacy saved variables
    if not GUILDBOOK_PRIVACY then
        GUILDBOOK_PRIVACY = {};
        addon.DEBUG("func", "Database:Init", "declared privacy saved variables as new table")
    end
    for k, v in pairs(self.keys.privacy) do
        if not GUILDBOOK_PRIVACY[k] then
            GUILDBOOK_PRIVACY[k] = v;
        end
    end
    addon.DEBUG("func", "Database:Init", "copied privacy saved variable keys")
    if GUILDBOOK_GLOBAL.config and GUILDBOOK_GLOBAL.config.privacy then
        for k, v in pairs(GUILDBOOK_GLOBAL.config.privacy) do
            if GUILDBOOK_PRIVACY[k] then
                GUILDBOOK_PRIVACY[k] = v;
            end
        end
        addon.DEBUG("func", "Database:Init", "copied old privacy variables into new saved variables")
    end
    for k, v in pairs(self.keysToRemove.privacy) do
        if GUILDBOOK_PRIVACY[v] then
            GUILDBOOK_PRIVACY[v] = nil;
        end
    end
    addon.DEBUG("func", "Database:Init", "removed old privacy saved variable keys")

    addon:TriggerEvent("OnDatabaseInitialised")
end

function Database:GuildExists(guildName)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
        return true;
    end
    return false;
end

function Database:CreateNewGuildRosterCache(guildName)
    if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName] = {};
    end
end

function Database:SetGuildMemberData(guildName, guid, data)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] and GUILDBOOK_GLOBAL.GuildRosterCache[guildName][guid] then
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][guid] = data;
    end
end

function Database:GetGuildMemberData(guildName, guid)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] and GUILDBOOK_GLOBAL.GuildRosterCache[guildName][guid] then
        return GUILDBOOK_GLOBAL.GuildRosterCache[guildName][guid];
    end
end


function Database:GetGuildRosterCache(guildName)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
        return GUILDBOOK_GLOBAL.GuildRosterCache[guildName];
    end
end

function Database:SetGuildRosterCache(guildName, cache)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName] = cache;
        addon.DEBUG("func", "Database:SetGuildRosterCache", string.format("set roster cache for %s", guildName), cache)
    end
end


function Database:SetConfigSetting(config, newValue)
    if GUILDBOOK_CONFIG then
        GUILDBOOK_CONFIG[config] = newValue;
    end
end

function Database:GetConfigSetting(config)
    if GUILDBOOK_CONFIG and GUILDBOOK_CONFIG[config] then
        return GUILDBOOK_CONFIG[config];
    end
end


function Database:SetPrivacySetting(privacy, newValue)

end

function Database:GetPrivacySetting(privacy)

end

addon.Database = Database;