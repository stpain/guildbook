--[==[

Copyright ©2022 Samuel Thomas Pain

The contents of this addon, excluding third-party resources, are
copyrighted to their authors with all rights reserved.

This addon is free to use and the authors hereby grants you the following rights:

1. 	You may make modifications to this addon for private use only, you
    may not publicize any portion of this addon.

2. 	Do not modify the name of this addon, including the addon folders.

3. 	This copyright notice shall be included in all copies or substantial
    portions of the Software.

All rights not explicitly addressed in this license are reserved by
the copyright holders.

]==]--


local addonName, Guildbook = ...

Guildbook.addonLoaded = false

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local LCI = LibStub:GetLibrary("LibCraftInfo-1.0")

local Tradeskills = CreateFromMixins(CallbackRegistryMixin);
local Roster = CreateFromMixins(CallbackRegistryMixin);
local Database = CreateFromMixins(CallbackRegistryMixin);
local Character = CreateFromMixins(CallbackRegistryMixin);
local Comms = CreateFromMixins(CallbackRegistryMixin);

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------

local locale = GetLocale()
local L = Guildbook.Locales

Guildbook.PLAYER_FACTION = nil;

local TOOLTIP_DIVIDER_WIDE = "|TInterface/COMMON/UI-TooltipDivider:8:250|t"
Guildbook.PlayerMixin = nil
Guildbook.player = {}
Guildbook.COMMS_DELAY = 0.0
Guildbook.COMM_LOCK_COOLDOWN = 20.0
Guildbook.GUILD_NAME = nil;

Guildbook.Colours = {
    Blue = CreateColor(0.1, 0.58, 0.92, 1),
    Orange = CreateColor(0.79, 0.6, 0.15, 1),
    Yellow = CreateColor(1.0, 0.82, 0, 1),
    Green = CreateColor(84/255,174/255,45/255),
    LightRed = CreateColor(216/255,69/255,75/255),
    BlizzBlue = CreateColor(0,191/255,243/255),
    Grey = CreateColor(0.5,0.5,0.5),
}
for class, t in pairs(Guildbook.Data.Class) do
    Guildbook.Colours[class] = CreateColor(t.RGB[1], t.RGB[2], t.RGB[3], 1)
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDBOOK1 = '/guildbook'
SLASH_GUILDBOOK2 = '/gbk'
SLASH_GUILDBOOK3 = '/gb'
SlashCmdList['GUILDBOOK'] = function(msg)
    --print("["..msg.."]")
    if msg == 'open' then
        GuildbookUI:Show()

    elseif GuildbookUI[msg] then
        GuildbookUI:OpenTo(msg)

    elseif msg == L["SEARCH"] or msg == L["SEARCH"]:lower() then
		GuildbookUI:OpenTo("search")
		
	elseif msg == L["CALENDAR"] or msg == L["CALENDAR"]:lower() then
		GuildbookUI:OpenTo("calendar")
		
	elseif msg == L["HOME"] or msg == L["HOME"]:lower() then
		GuildbookUI:OpenTo("home")
		
	elseif msg == L["TRADESKILLS"] or msg == L["TRADESKILLS"]:lower() or msg == 'ts' then
		GuildbookUI:OpenTo("tradeskills")
		
	elseif msg == L["CHAT"] or msg == L["CHAT"]:lower() then
		GuildbookUI:OpenTo("chat")
		
	elseif msg == 'bank' then
		GuildbookUI:OpenTo("guildbank")
		
	elseif msg == 'options' then
	    InterfaceOptionsFrame_OpenToCategory(addonName)
       -- InterfaceOptionsFrame_OpenToCategory(addonName)
	   
	elseif msg == 'debug' then
		Guildbook.DebuggerWindow:Show()
    
    elseif msg == "version" and Guildbook.version then
        Guildbook:PrintMessage(Guildbook.version)

    elseif msg == "test" then

    end
end








--[[
/////////////////////////////////////////////////////////////////

    @class Database

    the database class provides functions to update the account wide 
    saved variables and the per character saved variables
    whenever a value is changed a callback is triggered

/////////////////////////////////////////////////////////////////
]]
Database:GenerateCallbackEvents({
    "OnCharacterTableChanged", -- only this clients UI needs to listen to this
    --"OnCharacterTradeskillRecipesChanged", -- and this
    "OnPlayerCharacterTableChanged",
    "OnPlayerCharacterTradeskillsInfoChanged",
    "OnPlayerCharacterTradeskillRecipesChanged",
    "OnGuildbookConfigChanged",
})
Database.currentGuildName = nil;

--to save spamming data we use basic queue/timer system, these bool values determine if a callback is queued or not
Database.onCharacterTableChanged_IsTriggered = false;
Database.onPlayerCharacterTableChanged_IsTriggered = false;
Database.onPlayerCharacterTradeskillsInfoChanged_IsTriggered = false;
Database.onPlayerCharacterTradeskillRecipesChanged_IsTriggered = false;
--Database.onCharacterTradeskillRecipesChanged_IsTriggered = false;

function Database:SetupGuildRosterCache()

    if type(self.currentGuildName) == "string" then

        if type(GUILDBOOK_GLOBAL.GuildRosterCache) == "table" then

            if not GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] then
                GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] = {}
                Guildbook.DEBUG("databaseMixin", "SetupGuildRosterCache", string.format("set up cache for %s", self.currentGuildName))
            end

        end
    end
end


function Database:UpdateGuildbookConfig(setting, newValue)

    --DevTools_Dump({setting, newValue})
    
    if GUILDBOOK_GLOBAL then
        if GUILDBOOK_GLOBAL.config then
            if GUILDBOOK_GLOBAL.config[setting] ~= nil then
                GUILDBOOK_GLOBAL.config[setting] = newValue;
                Guildbook.DEBUG("databaseMixin", "Database:UpdateGuildbookConfig", string.format("set %s to new value %s", setting, tostring(newValue)))
                self:TriggerEvent("OnGuildbookConfigChanged", self, GUILDBOOK_GLOBAL.config)
            else
                GUILDBOOK_GLOBAL.config[setting] = newValue;
                Guildbook.DEBUG("databaseMixin", "Database:UpdateGuildbookConfig", string.format("created new config setting for %s set value as %s", setting, tostring(newValue)))
                self:TriggerEvent("OnGuildbookConfigChanged", self, GUILDBOOK_GLOBAL.config)
            end
        end
    end
end



function Database:DeleteCharacterFromCache(guid, character)

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] then

        Guildbook.DEBUG("databaseMixin", "Database:DeleteCharacterFromCache", string.format("deleting character %s", character.Name or "unknown character"), character)

        GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] = nil;

    end

end



function Database:CharacterExists(guid)

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] then
        return true;
    end

    return false;
end



function Database:FindCharacterAlts(guid)

    local alts = {};

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] then
        
        for _guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName]) do
            if character.MainCharacter == guid then
                table.insert(alts, character)
            end
        end

    end

    return alts;

end



function Database:AddNewCharacter(guid, nameRealm, level, class, race, gender, publicNote, rankName)

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] then

        local character = {
            Name = Ambiguate(nameRealm, "none"),
            Class = class,
            Level = level,
            Race = race,
            Gender = gender,
            PublicNote = publicNote,
            OfficerNote = "",
            RankName = rankName,
            MainSpec = '-',
            OffSpec = '-',
            MainSpecIsPvP = false,
            OffSpecIsPvP = false,
            Profession1 = '-',
            Profession1Level = 0,
            Profession2 = '-',
            Profession2Level = 0,
            FishingLevel = 0,
            CookingLevel = 0,
            FirstAidLevel = 0,
            MainCharacter = '-',
            Availability = {
                Monday = nil,
                Tuesday = nil,
                Wednesday = nil,
                Thursday = nil,
                Friday = nil,
                Saturday = nil,
                Sunday = nil,
            },
            CalendarEvents = {},
            Talents = {
                primary = {},
        
            },
            PaperDollStats = {
                Current = {},
            },
            Inventory = {
                Current = {},
            },
            profile = {},
            Alts = {},
        }

        GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] = character;
        Guildbook.DEBUG("databaseMixin", "AddNewCharacter", string.format(">>> added %s", nameRealm))
    end

end




---update a character table in the account wide saved var (guild roster cache) - t[guid][key] = info
---@param guid string the target character guid - used as a key
---@param key string the field to update
---@param info any the new data to set
function Database:UpdateCharacterTable(guid, key, info)

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] then
        local characterTable = GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid];
        characterTable[key] = info;

        Guildbook.DEBUG("databaseMixin", "Database:UpdateCharacterTable", string.format("updated %s for %s", key, characterTable.Name), info)

        ---to avoid multiple triggers we add a small queue system
        if self.onCharacterTableChanged_IsTriggered == false then
           C_Timer.After(1.5, function()
                self:TriggerEvent("OnCharacterTableChanged", self, guid, characterTable)
                self.onCharacterTableChanged_IsTriggered = false;
           end)
           self.onCharacterTableChanged_IsTriggered = true;
        end
    end

end



---a specific function to be used during the roster scan that takes in basic character info and updates in 1 go
---@param rankName any
---@param level any
---@param race any
---@param gender any
---@param publicNote any
function Database:UpdateCharacterTable_RosterScan(guid, rankName, level, race, gender, publicNote)

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] then
        local characterTable = GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid];

        characterTable.RankName = rankName;
        characterTable.Race = race;
        characterTable.Level = tonumber(level);
        characterTable.PublicNote = publicNote;
        characterTable.Gender = gender;

        -- Guildbook.DEBUG("databaseMixin", "Database:UpdateCharacterTable_RosterScan", string.format("updated %s", characterTable.Name), {
        --     ["rank"] = rankName, 
        --     ["level"] = level, 
        --     ["race"] = race, 
        --     ["gender"] = gender, 
        --     ["public note"] = publicNote,
        -- })

    end
end




function Database:UpdateCharacterTradeskillRecipes(guid, tradeskill, recipes)

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] then
        local characterTable = GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid];
        characterTable[tradeskill] = recipes;

        Guildbook.DEBUG("databaseMixin", "Database:UpdateCharacterTradeskillRecipes", string.format("updated %s for %s", tradeskill, characterTable.Name), recipes)

        ---this function should be moved into the tradeskill class and possibly re worked ???
        Guildbook:RequestTradeskillData()
    end

end


---fetch character info using guid and key
---@param guid string the characters GUID
---@param key string the key to fetch
---@return any
function Database:GetCharacterInfo(guid, key)
    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName] and GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid] then
        local characterName = GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid].Name
        Guildbook.DEBUG("databaseMixin", "Database:GetCharacterInfo", string.format("found %s for %s", key, characterName), {
            character = characterName,
            key = key,
            value = GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid][key],
        })
        return GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid][key];

    else
        --local characterName = GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid].Name or "no name or character table"
        Guildbook.DEBUG("databaseMixin", "Database:GetCharacterInfo", string.format("unable to find %s", key))
        return false;
    end
    return false;
end



function Database:FetchCharacterTableByGUID(guid)

    if type(guid) ~= "string" then
        Guildbook.DEBUG("databaseMixin", "Database:FetchCharacterTableByGUID", "guid is not of type string", {guid = guid})
        return;
    end

    --removed the debug here as it can be spammy
    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] then
        --Guildbook.DEBUG("databaseMixin", "Database:FetchCharacterTableByGUID", string.format("found character table for %s", GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid].Name))
        return GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid];

    elseif guid:find("Player-") then
        local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(guid)
        Guildbook.DEBUG("databaseMixin", "Database:FetchCharacterTableByGUID", string.format("unable to find character table for %s-%s", name or "no-name", realm or "no-realm"))
        return false;
    end

    return false;
end



--- THIS WAS SUCH A DUMB IDEA AND I DO NOT KNOW WHY I DID IT THIS WAY AS A BETTER OPTION WOULD BE t[key][tab] !!!!!!!!!!!!!!!!!!!!!!!
--- so this next function is kinda backwards atm, i should fix it but meh

---update the per character saved variable table
---@param key string the table key to update
---@param info any the new value
---@param tab string optional, a child table of GUILDBOOK_CHARACTER to update, ie GUILDBOOK_CHARACTER[tab][key] = info
function Database:UpdatePlayerCharacterTable(key, info, tab)

    if not GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER = Guildbook.Data.DefaultCharacterSettings;
    end

    local t = nil;

    if type(tab) ~= "string" then
        t = GUILDBOOK_CHARACTER;
        Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", "using the GUILDBOOK_CHARACTER table")
    else
        if GUILDBOOK_CHARACTER[tab] then
            if type(GUILDBOOK_CHARACTER[tab]) == "table" then
                t = GUILDBOOK_CHARACTER[tab];
                Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", string.format("using GUILDBOOK_CHARACTER[%s] table", tab))
            else
                GUILDBOOK_CHARACTER[tab] = {}
                t = GUILDBOOK_CHARACTER[tab];
                Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", string.format("GUILDBOOK_CHARACTER[%s] table did NOT exists, created and using new table", tab))
            end
        else
            GUILDBOOK_CHARACTER[tab] = {};
            t = GUILDBOOK_CHARACTER[tab];
            Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", string.format("%s does NOT exist, created GUILDBOOK_CHARACTER[%s] table", tab, tab))
        end
    end

    if type(t) ~= "table" then
        Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", string.format("table not found for key: %s, opt tab: %s > db update cancelled", key, tab or "-"), {
            ["key"] = key,
            ["info"] = info,
            ["tab"] = tab or "-",
        })
        return;
    end

    if t then
        t[key] = nil;
        t[key] = info;
        Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", string.format("set or updated %s", key), info)
        ---to avoid multiple triggers in < 1s we add a small queue system
        if self.onPlayerCharacterTableChanged_IsTriggered == false then
            C_Timer.After(3.0, function()
                self:TriggerEvent("OnPlayerCharacterTableChanged", self, GUILDBOOK_CHARACTER)
                self.onPlayerCharacterTableChanged_IsTriggered = false;
            end)
            self.onPlayerCharacterTableChanged_IsTriggered = true;
        end
    end
end



function Database:UpdatePlayerCharacterTradeskillsInfo(prof1, prof1Level, prof1Spec, prof2, prof2Level, prof2Spec, fishing, cooking, firstAid)

    if not GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER = Guildbook.Data.DefaultCharacterSettings;
    end

    if type(prof1) == "string" then
        GUILDBOOK_CHARACTER.Profession1 = prof1;
    end
    if type(prof1Level) == "number" then
        GUILDBOOK_CHARACTER.Profession1Level = prof1Level;
    end
    if type(prof1Spec) == "number" then
        GUILDBOOK_CHARACTER.Profession1Spec = prof1Spec;
    end

    if type(prof2) == "string" then
        GUILDBOOK_CHARACTER.Profession2 = prof2;
    end
    if type(prof2Level) == "number" then
        GUILDBOOK_CHARACTER.Profession2Level = prof2Level;
    end
    if type(prof2Spec) == "number" then
        GUILDBOOK_CHARACTER.Profession2Spec = prof2Spec;
    end

    if type(fishing) == "number" then
        GUILDBOOK_CHARACTER.FishingLevel = fishing;
    end
    if type(cooking) == "number" then
        GUILDBOOK_CHARACTER.CookingLevel = cooking;
    end
    if type(firstAid) == "number" then
        GUILDBOOK_CHARACTER.FirstAidLevel = firstAid;
    end

    Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTradeskillsInfo", "updated player character tradeskills info", {prof1, prof1Level, prof1Spec, prof2, prof2Level, prof2Spec, fishing, cooking, firstAid})

    ---to avoid multiple triggers we use a queue system, as players could power level professions lets increase the queue timer to 10s
    if self.onPlayerCharacterTradeskillsInfoChanged_IsTriggered == false then
       C_Timer.After(10.0, function()
            self:TriggerEvent("OnPlayerCharacterTradeskillsInfoChanged", self)
            self.onPlayerCharacterTradeskillsInfoChanged_IsTriggered = false;
       end)
       self.onPlayerCharacterTradeskillsInfoChanged_IsTriggered = true;
    end

end



function Database:UpdatePlayerCharacterTradeskillRecipes(prof, recipes)

    if not GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER = Guildbook.Data.DefaultCharacterSettings;
    end

    GUILDBOOK_CHARACTER[prof] = recipes;

    Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTradeskillRecipes", string.format("updated or set recipes for %s", prof), recipes)

    ---to avoid multiple triggers we use a queue system, as players could power level professions lets increase the queue timer to 10s
    if self.onPlayerCharacterTradeskillRecipesChanged_IsTriggered == false then
        C_Timer.After(10.0, function()
             self:TriggerEvent("OnPlayerCharacterTradeskillRecipesChanged", self, prof) --we just need the prof name to use to find the data
             self.onPlayerCharacterTradeskillRecipesChanged_IsTriggered = false;
        end)
        self.onPlayerCharacterTradeskillRecipesChanged_IsTriggered = true;
     end

end


function Database:Init()

    Guildbook.DEBUG("databaseMixin", "Database:Init", "initialising the database class")

    CallbackRegistryMixin.OnLoad(self)

    ---setup the UI callback
    self:RegisterCallback("OnCharacterTableChanged", GuildbookUI.OnCharacterTableChanged, GuildbookUI)

    -- the database MUST always use the players guild NOT whatever guild is being viewed
    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        self.currentGuildName = guildName;

        self:SetupGuildRosterCache()
    end

    -- self.listener = CreateFrame("FRAME")

    -- self.listener:SetScript("OnEvent", function(_, event, ...)

    -- end)

end

Guildbook.Database = Database;






--[[
/////////////////////////////////////////////////////////////////

    @class Classes

    this class would be used to handle info etc for the character classes, textures, spec names, icons, colours etc

/////////////////////////////////////////////////////////////////
]]
local Classes = {}
Classes.Specializations = {
    ["DEATHKNIGHT"] = {
        {
            ["Frost (DPS)"] = {
                role = "DPS",
                talentBackground = "DeathKnightFrost",
                atlas = "",
            },
            ["Frost (Tank)"] = {
                role = "DPS",
                talentBackground = "DeathKnightFrost"
            },
            ["Blood"] = {
                role = "Tank",
                talentBackground = "DeathKnightBlood"
            },
            ["Unholy"] = {
                role = "DPS",
                talentBackground = "DeathKnightUnholy"
            },
        },
    },
}









--[[
/////////////////////////////////////////////////////////////////

    @class Tradeskills


/////////////////////////////////////////////////////////////////
]]
--local Tradeskills = {}
Tradeskills:GenerateCallbackEvents({
    "OnRecipeItemDataReceived", --hmm?
});
Tradeskills.CurrentLocale = GetLocale()
Tradeskills.TradeskillNames = {
    ["Alchemy"] = 171,
    ["Blacksmithing"] = 164,
    ["Enchanting"] = 333,
    ["Engineering"] = 202,
    ["Inscription"] = 773,
    ["Jewelcrafting"] = 755,
    ["Leatherworking"] = 165,
    ["Tailoring"] = 197,
    ["Mining"] = 186,
    ["Herbalism"] = 182,
    ["Skinning"] = 393,
    ["Cooking"] = 185,
}
Tradeskills.SpecializationSpellsIDs = {
    --Alchemy:
    [28672] = 171,
    [28677] = 171,
    [28675] = 171,
    --Engineering:
    [20222] = 202,
    [20219] = 202,
    --Tailoring:
    [26798] = 197,
    [26797] = 197,
    [26801] = 197,
    --Blacksmithing:
    [9788] = 164,
    [17039] = 164,
    [17040] = 164,
    [17041] = 164,
    [9787] = 164,
    --Leatherworking:
    [10656] = 165,
    [10658] = 165,
    [10660] = 165,
}
Tradeskills.TradeskillIDsToLocaleName = {
	enUS = {
		[164] = "Blacksmithing",
		[165] = "Leatherworking",
		[171] = "Alchemy",
		[182] = "Herbalism",
		[185] = "Cooking",
		[186] = "Mining",
		[197] = "Tailoring",
		[202] = "Engineering",
		[333] = "Enchanting",
		[356] = "Fishing",
		[393] = "Skinning",
		[755] = "Jewelcrafting",
		[773] = "Inscription",
		[129] = "First Aid"
	},
	deDE = {
		[164] = "Schmiedekunst",
		[165] = "Lederverarbeitung",
		[171] = "Alchimie",
		[182] = "Kräuterkunde",
		[185] = "Kochkunst",
		[186] = "Bergbau",
		[197] = "Schneiderei",
		[202] = "Ingenieurskunst",
		[333] = "Verzauberkunst",
		[356] = "Angeln",
		[393] = "Kürschnerei",
		[755] = "Juwelenschleifen",
		[773] = "Inschriftenkunde",
		[129] = "Erste Hilfe",
	},
	frFR = {
		[164] = "Forge",
		[165] = "Travail du cuir",
		[171] = "Alchimie",
		[182] = "Herboristerie",
		[185] = "Cuisine",
		[186] = "Minage",
		[197] = "Couture",
		[202] = "Ingénierie",
		[333] = "Enchantement",
		[356] = "Pêche",
		[393] = "Dépeçage",
		[755] = "Joaillerie",
		[773] = "Calligraphie",
		[129] = "Secourisme",
	},
	esMX = {
		[164] = "Herrería",
        [165] = {"Peletería", "Marroquinería"},
		[171] = "Alquimia",
        [182] = {"Herboristería", "Botánica"},
		[185] = "Cocina",
		[186] = "Minería",
        [197] = {"Sastrería", "Costura"},
		[202] = "Ingeniería",
		[333] = "Encantamiento",
		[356] = "Pesca",
		[393] = "Desuello",
		[755] = "Joyería",
		[773] = "Inscripción",
		[129] = "Primeros auxilios",
	},
    -- discovered this locale exists also maybe esAL ?
    esES = {
        [164] = "Herrería",
        [165] = {"Peletería", "Marroquinería"},
        [171] = "Alquimia",
        [182] = {"Herboristería", "Botánica"},
        [185] = "Cocina",
        [186] = "Minería",
        [197] = {"Sastrería", "Costura"},
        [202] = "Ingeniería",
        [333] = "Encantamiento",
        [356] = "Pesca",
        [393] = "Desuello",
        [755] = "Joyería",
        [773] = "Inscripción",
        [129] = "Primeros auxilios",
    },
	ptBR = {
		[164] = "Ferraria",
		[165] = "Couraria",
		[171] = "Alquimia",
		[182] = "Herborismo",
		[185] = "Culinária",
		[186] = "Mineração",
		[197] = "Alfaiataria",
		[202] = "Engenharia",
		[333] = "Encantamento",
		[356] = "Pesca",
		[393] = "Esfolamento",
		[755] = "Joalheria",
		[773] = "Escrivania",
		[129] = "Primeiros Socorros",
	},
	ruRU = {
		[164] = "Кузнечное дело",
		[165] = "Кожевничество",
		[171] = "Алхимия",
		[182] = "Травничество",
		[185] = "Кулинария",
		[186] = "Горное дело",
		[197] = "Портняжное дело",
		[202] = "Инженерное дело",
		[333] = "Наложение чар",
		[356] = "Рыбная ловля",
		[393] = "Снятие шкур",
		[755] = "Ювелирное дело",
		[773] = "Начертание",
		[129] = "Первая помощь",
	},
	zhCN = {
		[164] = "锻造",
		[165] = "制皮",
		[171] = "炼金术",
		[182] = "草药学",
		[185] = "烹饪",
		[186] = "采矿",
		[197] = "裁缝",
		[202] = "工程学",
		[333] = "附魔",
		[356] = "钓鱼",
		[393] = "剥皮",
		[755] = "珠宝加工",
		[773] = "铭文",
		[129] = "急救",
	},
	zhTW = {
		[164] = "鍛造",
		[165] = "製皮",
		[171] = "鍊金術",
		[182] = "草藥學",
		[185] = "烹飪",
		[186] = "採礦",
		[197] = "裁縫",
		[202] = "工程學",
		[333] = "附魔",
		[356] = "釣魚",
		[393] = "剝皮",
		[755] = "珠寶設計",
		[773] = "銘文學",
		[129] = "急救", --Worked on PTR -Belrand
	},
	koKR = {
		[164] = "대장기술",
		[165] = "가죽세공",
		[171] = "연금술",
		[182] = "약초채집",
		[185] = "요리",
		[186] = "채광",
		[197] = "재봉술",
		[202] = "기계공학",
		[333] = "마법부여",
		[356] = "낚시",
		[393] = "무두질",
		[755] = "보석세공",
		[773] = "주문각인",
		[129] = "응급치료",
	},
}

-- Invert the table so we can look up the ID by name(s)
function tInvert(t)
    local s = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            for i, value in ipairs(v) do
                s[value] = k
            end
        else
            s[v] = k
        end
    end
    return s
end

Tradeskills.TradeskillLocaleNameToID = tInvert(Tradeskills.TradeskillIDsToLocaleName[Tradeskills.CurrentLocale])

-- returns true if the tradeskill is a valid tradeskill
function Tradeskills:IsTradeskill(tradeskillName, tradeskillID)
    if type(tradeskillName) == "string" then
        for id, name in pairs(self.TradeskillIDsToLocaleName[GetLocale()]) do
            if type(name) == "table" then
                for i, value in ipairs(name) do
                    if value == tradeskillName then
                        return true
                    end
                end
            else
                if name == tradeskillName then
                    return true
                end
            end
        end
    else
        if type(tradeskillID) == "number" then
            for id, name in pairs(self.TradeskillIDsToLocaleName[GetLocale()]) do
                if id == tradeskillID then
                    return true;
                end
            end
        end
    end
end

function Tradeskills:GetEnglishNameFromID(tradeskillID)
    if self.TradeskillIDsToLocaleName.enUS[tradeskillID] then
        return self.TradeskillIDsToLocaleName.enUS[tradeskillID];
    end
end

function Tradeskills:GetEnglishNameFromTradeskillName(tradeskillName)
    local tradeskillID = self.TradeskillLocaleNameToID[tradeskillName]
    if tradeskillID then
        local tradeskill = self:GetEnglishNameFromID(tradeskillID)
        return tostring(tradeskill);
    end
    return false;
end


function Tradeskills:RequestRecipeInfo()

end



function Tradeskills:FindCharactersWithRecipe(recipe)
    local charactersWithRecipe = {}
    local sorting = {}
    if recipe.enchant == true then
        for k, guid in ipairs(Guildbook.charactersWithEnchantRecipe[recipe.itemID]) do
            table.insert(sorting, {
                guid = guid,
                online = Roster.onlineStatus[guid].isOnline and 1 or 0,
            })
        end
    else
        for k, guid in ipairs(Guildbook.charactersWithRecipe[recipe.itemID]) do
            table.insert(sorting, {
                guid = guid,
                online = Roster.onlineStatus[guid].isOnline and 1 or 0,
            })
        end
    end
    table.sort(sorting, function(a,b)
        return a.online > b.online
    end)
    for k, character in ipairs(sorting) do
        table.insert(charactersWithRecipe, character.guid)
    end

    return charactersWithRecipe;
end


---load the characters tradeskills, currently this is triggered by the new home tab member listview
---@param prof string the profession to load recipes for or `allRecipes` for all of the characters recipes
---@param character table optional character table to use, overrides the guid arg
function Tradeskills:LoadGuildMemberTradeskills(prof, character)

    --hide the selected texture and flush the listviews
    for _, button in ipairs(GuildbookTradeskillProfessionListview.profButtons) do
        button.selected:Hide()
    end
    GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Flush()
    GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:Flush()

    if prof == "Enchanting" then
        if not Guildbook.tradeskillEnchantRecipesKeys then
            return;
        end
        if next(Guildbook.tradeskillEnchantRecipesKeys) == nil then
            GuildbookUI:SetInfoText("tradeskill enchant recipes not processed yet, key mapping not ready")
            return
        end

    else
        if not Guildbook.tradeskillRecipesKeys then
            return;
        end
        if next(Guildbook.tradeskillRecipesKeys) == nil then
            GuildbookUI:SetInfoText("tradeskill recipes not processed yet, key mapping not ready")
            return
        end
        
    end

    if type(character) ~= "table" then
        return
    end
    if prof == "Enginnering" then prof = "Engineering" end -- fix it back due to blizz spelling error
    local recipes = {}
    if prof ~= "allRecipes" and character[prof] then
        for itemID, _ in pairs(character[prof]) do
            if prof == "Enchanting" then
                local key = Guildbook.tradeskillEnchantRecipesKeys[itemID]
                table.insert(recipes, Guildbook.tradeskillRecipes[key])
            else
                local key = Guildbook.tradeskillRecipesKeys[itemID]
                table.insert(recipes, Guildbook.tradeskillRecipes[key])
            end
        end

    ---if no prof is given then load all the characters recipes
    elseif prof == "allRecipes" then
        local prof1 = character.Profession1
        if prof1 and character[prof1] then
            for itemID, _ in pairs(character[prof1]) do
                if prof1 == "Enchanting" then
                    local key = Guildbook.tradeskillEnchantRecipesKeys[itemID]
                    table.insert(recipes, Guildbook.tradeskillRecipes[key])
                else
                    local key = Guildbook.tradeskillRecipesKeys[itemID]
                    table.insert(recipes, Guildbook.tradeskillRecipes[key])
                end
            end
        end
        local prof2 = character.Profession2
        if prof2 and character[prof2] then
            for itemID, _ in pairs(character[prof2]) do
                if prof2 == "Enchanting" then
                    local key = Guildbook.tradeskillEnchantRecipesKeys[itemID]
                    table.insert(recipes, Guildbook.tradeskillRecipes[key])
                else
                    local key = Guildbook.tradeskillRecipesKeys[itemID]
                    table.insert(recipes, Guildbook.tradeskillRecipes[key])
                end
            end
        end
    end
    if recipes and next(recipes) ~= nil then
        GuildbookUI:SetInfoText(string.format("found %s recipes for %s [%s]", #recipes, prof, character.Name))
        table.sort(recipes, function(a,b)
            if type(a.expansion) ~= "number" and type(b.expansion) ~= "number" then
                return a.rarity  > b.rarity;
            end
            if a.expansion == b.expansion then
                if a.rarity == b.rarity then
                    return a.name < b.name
                else
                    return a.rarity > b.rarity
                end
            else
                return a.expansion > b.expansion
            end
        end)
        GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(recipes)

        -- the items in this list need to be changed to take a character name
        --GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:InsertTable({guid}) -- why?
    end
    GuildbookUI:OpenTo("tradeskills")
end



function Tradeskills:Init()

    Guildbook.DEBUG("func", "Tradeskills:Init", "initialising the tradeskills class")
    
    CallbackRegistryMixin.OnLoad(self)

end

Guildbook.Tradeskills = Tradeskills;










--[[
/////////////////////////////////////////////////////////////////

    @class Roster


/////////////////////////////////////////////////////////////////
]]
--local Roster = CreateFromMixins(CallbackRegistryMixin)
Roster:GenerateCallbackEvents({
    "OnGuildRosterScan",
    "OnMemberStatusChanged",
    "OnMemberJoin",
    "OnMemberLeave",
    "OnGuildSelectionChanged",
})
Roster.currentPlayerRealm = nil;
Roster.currentGuildName = nil;
Roster.onlineStatus = {};
Roster.guidToCharacterNameRealm = {}; --?
Roster.characterNameRealmToGUID = {}; --?
Roster.scanMembersTicker = nil;
Roster.scanMembersTickerActive = false;

function Roster:ScanMembers()

    Guildbook.DEBUG("rosterMixin", "ScanMembers", "scanning guild roster")

    if self.scanMembersTickerActive == false then

        Guildbook.DEBUG("rosterMixin", "ScanMembers", "scan ticker not active starting new ticker")
        
        self.scanMembersTickerActive = true;
        
        local totalMembers, onlineMember, _ = GetNumGuildMembers()
        local i = 1;
        
        self.scanMembersTicker = C_Timer.NewTicker(0.001, function() -- i assume 0.001 allows for up to 999 members per second ? should be quick enough, not sure its required but it gives the api time ?
            
            if i > totalMembers then
                return;
            end
        
            local nameRealm, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)

            if not guid then
                return;
            end

            if not guid:find("Player-") then
                return;
            end

            local _, _, _, race, gender, _, realm = GetPlayerInfoByGUID(guid)
            gender = (gender == 3) and "FEMALE" or "MALE"

            self.onlineStatus[guid] = {
                isOnline = isOnline,
                zone = zone,
            }
            
            self.guidToCharacterNameRealm[guid] = nameRealm;

            self.characterNameRealmToGUID[nameRealm] = guid;

            if Database:CharacterExists(guid) == false then
                Guildbook.DEBUG("rosterMixin", "ScanMembers", string.format("adding new character %s", nameRealm))
                Database:AddNewCharacter(guid, nameRealm, level, class, race, gender, publicNote, rankName)
            end

            Database:UpdateCharacterTable_RosterScan(guid, rankName, level, race, gender, publicNote)

            if i == totalMembers then

                self.scanMembersTickerActive = false;

                self:ScanForAlts()

                self:RemoveMembers()

                self:TriggerEvent("OnGuildRosterScan")

            end

            i = i + 1;

        end, totalMembers)

    else

        Guildbook.DEBUG("rosterMixin", "ScanMembers", "scan ticker is active, skipping scan")

    end

end



function Roster:RemoveMembers()

    if Guildbook.addonLoaded == false then
        return;
    end

    if self.currentGuildName == nil then
        return;
    end

    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] then

        for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName]) do

            if not self.guidToCharacterNameRealm[guid] then

                Database:DeleteCharacterFromCache(guid, character)

            end

        end

    end
end



function Roster:ScanForAlts()

    if Guildbook.addonLoaded == false then
        return;
    end

    if self.currentGuildName == nil then
        return;
    end

    --temp local table t = { [mainCharacterGUID] = { altCharacterGUID1, altCharacterGUID2, ... } }
    local t = {}

    --loop the roster cache and find any characters where a main character is set
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] then

        for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName]) do
            if character.MainCharacter and character.MainCharacter:find("Player-") then

                --add the main character to the temp table
                if not t[character.MainCharacter] then
                    t[character.MainCharacter] = {}
                end

                --add the current character guid to the main character table
                table.insert(t[character.MainCharacter], guid)

            end
        end

        --loop the temp table and update any main characters with alt guid info
        for mainCharacter, alts in pairs(t) do

            Database:UpdateCharacterTable(mainCharacter, "Alts", alts)

        end

    end

end


---get the current ranks for the guild and loop the config table to make sure any old ranks are corrected
function Roster:CheckPrivacyRankSettings()
    local ranks = {}
    local numRanks = GuildControlGetNumRanks()
    for i = 1, numRanks do
        ranks[GuildControlGetRankName(i)] = i;
    end
    local lowestRank = GuildControlGetRankName(numRanks)
    if type(lowestRank) == "string" and #lowestRank > 0 then
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.config and GUILDBOOK_GLOBAL.config.privacy then
            for rule, rank in pairs(GUILDBOOK_GLOBAL.config.privacy) do
                if not ranks[rank] then
                    if rank == "none" then
                        
                    else
                        -- set the rank to lowest, this is to cover times where a rank is deleted
                        GUILDBOOK_GLOBAL.config.privacy[rule] = lowestRank
                        Guildbook:PrintMessage(L["PRIVACY_CONFIG_ERROR_SS"]:format(rule , lowestRank))
                        Guildbook.DEBUG("rosterMixin", "CheckPrivacyRankSettings", string.format("changed rank: %s to lowest rank (%s) for rule: %s", rank, lowestRank, rule))
                    end
                end
            end
        end
    else
        Guildbook.DEBUG("rosterMixin", "CheckPrivacyRankSettings", string.format("unable to check ranks, found %s ranks but lowest not recognised", numRanks))
    end
end



---find the current characters main character and return either the table or just name
---@param guid string the current characters guid
---@param colourize boolean apply the class colour 
---@param returnTable boolean return the main characters data table [otherwise just name]
---@return boolean|table any if successful then returns either the main characters table or just name otherwise returns false
function Roster:FindMainCharacterFromGUID(guid, colourize, returnTable)

    local currentCharacter = Database:FetchCharacterTableByGUID(guid)

    if type(currentCharacter) == "table" then

        if type(currentCharacter.MainCharacter) == "string" and currentCharacter.MainCharacter:find("Player-") then

            local mainCharacter = Database:FetchCharacterTableByGUID(currentCharacter.MainCharacter);

            if type(mainCharacter) == "table" then

                if returnTable == true then
                    return mainCharacter;

                else

                    if colourize == true and type(mainCharacter.Class) == "string" then
                        return Guildbook.Colours[mainCharacter.Class]:WrapTextInColorCode(mainCharacter.Name or "Unknown");
                    else
                        return mainCharacter.Name or "Unknown";
                    end
                    
                end

            end
        end
    end

    return false;
end



function Roster:GetGuildMemberGUID(characterName)

    local totalMembers, onlineMember, _ = GetNumGuildMembers()

    for i = 1, totalMembers do
        
        local nameRealm, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)

        if nameRealm == characterName then
            return guid
        end
    end
end



function Roster:OnChatMessageSystem(...)
    local msg = ...

    --- log out doesnt use a player link so this provides a string easily
    local loggedOut = ERR_FRIEND_OFFLINE_S:gsub("%%s", ".*")
    if msg:find(loggedOut) then
        local characterName, _ = strsplit(" ", msg)

        GuildbookUI.home:OnNewsFeedReceived(nil, {
            newsType = "logout",
            text = string.format(L["NF_PLAYER_LOGOUT_S"], characterName)
        })

        local guid = self.characterNameRealmToGUID[characterName] or self.characterNameRealmToGUID[characterName.."-"..self.currentPlayerRealm]
        if guid then
            if not self.onlineStatus[guid] then
                self.onlineStatus[guid] = {}
            end
            self.onlineStatus[guid].isOnline = false;

            self:TriggerEvent("OnMemberStatusChanged", guid, self.onlineStatus[guid])
        end

    end

    -- log in does use a player link so takes a bit of work to get the name
    local loggedIn = ERR_FRIEND_ONLINE_SS:gsub("%%s", ".+"):gsub('%[','%%%1')
    if msg:find(loggedIn:sub(6)) then
        local name = strsplit(" ", msg)
        local s, e = name:find("%["), name:find("%]")
        local characterName = name:sub(s+1, e-1)

        GuildbookUI.home:OnNewsFeedReceived(nil, {
            newsType = "login",
            text = string.format(L["NF_PLAYER_LOGIN_S"], characterName)
        })

        local guid = self.characterNameRealmToGUID[characterName] or self.characterNameRealmToGUID[characterName.."-"..self.currentPlayerRealm]
        if guid then
            if not self.onlineStatus[guid] then
                self.onlineStatus[guid] = {}
            end
            self.onlineStatus[guid].isOnline = true;

            self:TriggerEvent("OnMemberStatusChanged", guid, self.onlineStatus[guid])
        end
    end


    local joinedGuild = ERR_GUILD_JOIN_S:gsub("%%s", ".*")
    if msg:find(joinedGuild) then
        local name, _ = strsplit(" ", msg)
        Guildbook.DEBUG("event", "CHAT_MSG_SYSTEM", string.format("%s joined a guild", name))

        GuildbookUI.home:OnNewsFeedReceived(nil, {
            newsType = "playerJoinedGuild",
            text = string.format(L["NF_MEMBER_JOIN"], name)
        })
    end
end



function Roster:Init()

    Guildbook.DEBUG("rosterMixin", "Roster:Init", "initialising the roster class")

    CallbackRegistryMixin.OnLoad(self)

    self:CheckPrivacyRankSettings()

    self:RegisterCallback("OnGuildRosterScan", GuildbookUI.home.UpdateMemberList, GuildbookUI.home)
    self:RegisterCallback("OnMemberStatusChanged", GuildbookUI.home.UpdateMemberList, GuildbookUI.home)

    self.currentPlayerRealm = GetNormalizedRealmName()

    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        self.currentGuildName = guildName;
    end

    self.listener = CreateFrame("FRAME")
    self.listener:RegisterEvent("GUILD_ROSTER_UPDATE")
    self.listener:RegisterEvent("CHAT_MSG_SYSTEM")
    self.listener:SetScript("OnEvent", function(_, event, ...)
    
        if event == "GUILD_ROSTER_UPDATE" then
            C_Timer.After(3.0, function()
                self:ScanMembers()
            end)

        elseif event == "CHAT_MSG_SYSTEM" then
            self:OnChatMessageSystem(...)

        end

    end)

    self:ScanMembers()

    
end


Guildbook.Roster = Roster;







--[[
/////////////////////////////////////////////////////////////////

    @class Character

    the Character class listens for changes to the players character and sends this data to the Database class

/////////////////////////////////////////////////////////////////
]]
--local Character = CreateFromMixins(CallbackRegistryMixin)
Character:GenerateCallbackEvents({
    "OnLFGListingCreated",
    "OnPlayerLevelUp",
})
Character.profession1 = nil;
Character.profession2 = nil;
Character.InventorySlots = {
    "HEADSLOT",
    "NECKSLOT",
    "SHOULDERSLOT",
    "BACKSLOT",
    "CHESTSLOT",
    "SHIRTSLOT",
    "TABARDSLOT",
    "WRISTSLOT",
    "MAINHANDSLOT",
    "RANGEDSLOT",
    "HANDSSLOT",
    "WAISTSLOT",
    "LEGSSLOT",
    "FEETSLOT",
    "FINGER0SLOT",
    "FINGER1SLOT",
    "TRINKET0SLOT",
    "TRINKET1SLOT",
    "MAINHANDSLOT",
    "SECONDARYHANDSLOT",
    "RANGEDSLOT",
}
Character.StatIDs = {
    [1] = 'Strength',
    [2] = 'Agility',
    [3] = 'Stamina',
    [4] = 'Intellect',
    [5] = 'Spirit',
}
Character.SpellSchools = {
    [2] = 'Holy',
    [3] = 'Fire',
    [4] = 'Nature',
    [5] = 'Frost',
    [6] = 'Shadow',
    [7] = 'Arcane',
}
Character.TradeskillInfoScanActive = false;
Character.SkillUpPattern = ERR_SKILL_UP_SI:gsub("%%.", "(.*)")


---format number to 2dp for character stat data/display
---@param num number the number value to format
---@return ... number the formatted number or 1
function Character:FormatNumberForCharacterStats(num)
    if type(num) == 'number' then
        local trimmed = string.format("%.2f", num)
        return tonumber(trimmed)
    else
        return 1.0;
    end
end


---changed this to now store a datetime table for the actual reset instead of the duration in seconds
function Character:GetInstanceInfo()
    local t = {}
    local today = date("*t")
    if GetNumSavedInstances() > 0 then
        for i = 1, GetNumSavedInstances() do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
            local resets = date("*t", time(today) + reset);
            table.insert(t, { 
                Name = name,
                ID = id, 
                Resets = resets, 
                Encounters = numEncounters, 
                Progress = encounterProgress 
            })
            --local msg = string.format("name=%s, id=%s, reset=%s, difficulty=%s, locked=%s, numEncounters=%s", tostring(name), tostring(id), tostring(reset), tostring(difficulty), tostring(locked), tostring(numEncounters))
        end
    end
    return t
end



---scan the character paperdoll sheet for their inventory and update the per character saved var
---@param setName string the name to identify this gear set, defaults to "Current"
function Character:GetInventory(setName)

    if not setName then
        setName = "Current";
    end

    local t = {}
    local itemLevel, itemCount = 0, 0
    for _, slot in ipairs(self.InventorySlots) do
        local link = GetInventoryItemLink('player', GetInventorySlotInfo(slot)) or false;
        if link ~= nil then
            t[slot] = link;
            if link ~= false then
                local _, _, _, ilvl = GetItemInfo(link)
                if not ilvl then ilvl = 0 end
                itemLevel = itemLevel + ilvl;
                itemCount = itemCount + 1;
            end
        end
    end

    --- added the item level stat to this function so we can grab the characters ilvl for their gear sets
    --local itemLvl = math.floor(itemLevel/itemCount)
    local ilvl = self:FormatNumberForCharacterStats(itemLevel/itemCount)
    if ilvl > 0 then
        Database:UpdatePlayerCharacterTable(setName, ilvl, "ItemLevel")
    else
        Database:UpdatePlayerCharacterTable(setName, 0, "ItemLevel")
    end

    ---some players may choose not to share this info with everyone in their guild so all we need to do is update the database
    Database:UpdatePlayerCharacterTable(setName, t, "Inventory")
end


---returns the characters ilvl for their current gear
---@return number itemLevel gear ilvl
function Character:GetItemLevel()
    local itemLevel, itemCount = 0, 0
	for _, slot in ipairs(self.InventorySlots) do
		local link = GetInventoryItemLink('player', GetInventorySlotInfo(slot))
		if link then
			local _, _, _, ilvl = GetItemInfo(link)
            if not ilvl then ilvl = 0 end
			itemLevel = itemLevel + ilvl;
			itemCount = itemCount + 1;
		end
    end
    -- due to an error with LibSerialize which is now fixed we make sure we return a number
    if math.floor(itemLevel/itemCount) > 0 then
        return math.floor(itemLevel/itemCount)
    else
        return 0
    end
end


---scan the players talents and update the GUILDBOOK_CHARACTER table
function Character:ScanPlayerTalents()
    local tabs, talents = {}, {}
    for tabIndex = 1, GetNumTalentTabs() do
        local _, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
        local engSpec = Guildbook.Data.TalentBackgroundToSpec[fileName]
        table.insert(tabs, {
            points = pointsSpent, 
            spec = engSpec,
            texture = fileName,
        });
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
            table.insert(talents, {
                Tab = tabIndex,
                Row = row,
                Col = column,
                Rank = rank,
                MxRnk = maxRank,
                Icon = iconTexture,
                Index = talentIndex,
                Link = GetTalentLink(tabIndex, talentIndex),
            });
        end
    end

    if GUILDBOOK_CHARACTER.smartGuessMainSpec == true then
        table.sort(tabs, function(a, b)
            return a.points > b.points;
        end)

        Database:UpdatePlayerCharacterTable("MainSpec", tabs[1].spec)
    end

    ---some players may choose not to share this info with everyone in their guild so all we need to do is update the database
    Database:UpdatePlayerCharacterTable("primary", tabs, "TalentTabs")
    Database:UpdatePlayerCharacterTable("primary", talents, "Talents")
end


---scan the players skills and update the GUILDBOOK_CHARACTER table
function Character:ScanForTradeskillInfo()

    local characterTradeskillsInfo = {
        Profession1 = "-",
        Profession2 = "-",
        Profession1Level = nil,
        Profession2Level = nil,
        Profession1Spec = -1, -- doing this will cause and changes to show as no spec, GetSpellInfo(-1) returns a nil/empty result and the UI checks for a spell name returned
        Profession2Spec = -1,
        FishingLevel = nil,
        CookingLevel = nil,
        FirstAidLevel = nil,
    }

    local tradeskillsToLevel = {}
    for i = 1, GetNumSkillLines() do
        local name, _, _, rank = GetSkillLineInfo(i);
        if Tradeskills:IsTradeskill(name) and type(rank) == "number" then
            tradeskillsToLevel[name] = rank;
            Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("found %s [%s]", name, rank))
        end
    end

    for tradeskillName, rank in pairs(tradeskillsToLevel) do
        if type(rank) == "number" then
            if Tradeskills:GetEnglishNameFromTradeskillName(tradeskillName) == "Fishing" then
                characterTradeskillsInfo.FishingLevel = rank;
            end
            if Tradeskills:GetEnglishNameFromTradeskillName(tradeskillName) == "Cooking" then
                characterTradeskillsInfo.CookingLevel = rank;
            end
            if Tradeskills:GetEnglishNameFromTradeskillName(tradeskillName) == "First Aid" then
                characterTradeskillsInfo.FirstAidLevel = rank;
            end
        end
    end

    local _, _, offset, numSlots = GetSpellTabInfo(1)
    for j = offset+1, offset+numSlots do
        -- get spell id
        local _, spellID = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)

        ---this could be used as a backup to get the player tradeskills, wont help with prof level though nor for gathering profs
        local localeSpellName = GetSpellInfo(spellID)
        local engSpellName = Tradeskills:GetEnglishNameFromTradeskillName(localeSpellName)

        ---herbalism is listed as "Find herbs" with a spell ID of 2383 so just override this
        if spellID == 2383 then
            engSpellName = "Herbalism";

        ---mining is listed as "Find minerals" so override this too
        elseif spellID == 2580 then
            engSpellName = "Mining";
        end

        ---if the skill headers for professions wernt expanding when scanned then we have no data returned, 
        ---so we can get the prof names via the spellbook tab, prof level will default back to 1 but recipes will work as the prof name acts as a key
        if engSpellName ~= false then
            if engSpellName ~= "Cooking" and engSpellName ~= "Fishing" and engSpellName ~= "First Aid" then
                if characterTradeskillsInfo.Profession1 == "-" then
                    characterTradeskillsInfo.Profession1 = engSpellName;
                    if type(tradeskillsToLevel[engSpellName]) == "number" then
                        characterTradeskillsInfo.Profession1Level = tradeskillsToLevel[engSpellName];
                        Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("set prof1 as %s [%s] via spellbook scan", engSpellName, tradeskillsToLevel[engSpellName]))
                    else
                        Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("set prof1 as %s [unknown level] via spellbook scan", engSpellName))
                    end

                else
                    if characterTradeskillsInfo.Profession2 == "-" and characterTradeskillsInfo.Profession1 ~= engSpellName then
                        characterTradeskillsInfo.Profession2 = engSpellName;
                        if type(tradeskillsToLevel[engSpellName]) == "number" then
                            characterTradeskillsInfo.Profession2Level = tradeskillsToLevel[engSpellName];
                            Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("set prof2 as %s [%s] via spellbook scan", engSpellName, tradeskillsToLevel[engSpellName]))
                        else
                            Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("set prof2 as %s [unknown level] via spellbook scan", engSpellName))
                        end
                    end
                end
            end
        end

        -- check if spell is a prof spec
        if Tradeskills.SpecializationSpellsIDs[spellID] then
            -- grab the english name for prof
            local engProf = Tradeskills:GetEnglishNameFromID(Tradeskills.SpecializationSpellsIDs[spellID])
            -- assign the prof spec
            if characterTradeskillsInfo.Profession1 == engProf then
                characterTradeskillsInfo.Profession1Spec = tonumber(spellID)

            else
                if characterTradeskillsInfo.Profession2 == engProf and characterTradeskillsInfo.Profession1 ~= engProf then
                    characterTradeskillsInfo.Profession2Spec = tonumber(spellID)
                end
            end
        end
    end

    ---clean up any old data
    self:RemoveOldTradeskillRecipeTables()

    Database:UpdatePlayerCharacterTradeskillsInfo(
        characterTradeskillsInfo.Profession1,
        characterTradeskillsInfo.Profession1Level,
        characterTradeskillsInfo.Profession1Spec,
        characterTradeskillsInfo.Profession2,
        characterTradeskillsInfo.Profession2Level,
        characterTradeskillsInfo.Profession2Spec,
        characterTradeskillsInfo.FishingLevel,
        characterTradeskillsInfo.CookingLevel,
        characterTradeskillsInfo.FirstAidLevel
    )

    --lets also make the Character class extra useful by storing some info itself
    self.profession1 = characterTradeskillsInfo.Profession1
    self.profession2 = characterTradeskillsInfo.Profession2
end


---scan the players currently opened tradeskill recipes
function Character:ScanTradeskillRecipes()
    local englishProf = nil;

    local localeProf, currentLevel, maxLevel = GetTradeSkillLine();

    --if no prof name/level were returned lets try to get it from the ui 
    if type(localeProf) ~= "string" then

        --we need this fontstring to exist before trying
        if TradeSkillFrameTitleText then
            localeProf = TradeSkillFrameTitleText:GetText()
        end
        
        --now try to get the current/max levels
        local rankText = TradeSkillRankFrameSkillRank and TradeSkillRankFrameSkillRank:GetText() or nil;
        if rankText and rankText:find("/") then
            local currentLevel, maxLevel = strsplit("/", rankText)
            if type(currentLevel) == "string" then
                currentLevel = tonumber(currentLevel)
            end
            if type(maxLevel) == "string" then
                maxLevel = tonumber(maxLevel)
            end
            Guildbook.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", string.format("found prof level [%s] from UI text", currentLevel))
        end
    end

    --check everything is all good
    if type(localeProf) == "string" and type(currentLevel) == "number" and type(maxLevel) == "number" then
        englishProf = Tradeskills:GetEnglishNameFromTradeskillName(localeProf)
        if englishProf == false then
            Guildbook.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", "englishProf not known")
            return;
        end

    else
        Guildbook.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", string.format("variables not correct type > %s %s %s", localeProf, currentLevel, maxLevel))
        return;
    end

    if englishProf == nil then
        Guildbook.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", "engLishProf is nil", localeProf)
        return;
    end

    Guildbook.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", string.format("found [%s] with current level [%s] scanning for recipes", englishProf, currentLevel))

    local tradeskillRecipes = {}
    local numTradeskills = GetNumTradeSkills()
    for i = 1, numTradeskills do
        local name, _type, _, _, _ = GetTradeSkillInfo(i)
        if name and (_type == "optimal" or _type == "medium" or _type == "easy" or _type == "trivial") then -- this was a fix thanks to Sigma regarding their addon showing all recipes
            local link = GetTradeSkillItemLink(i)
            if link then
                --print(name, link)
                local itemID = GetItemInfoInstant(link)
                if itemID then
                    tradeskillRecipes[itemID] = {}
                    --local reagents = {}
                    local numReagents = GetTradeSkillNumReagents(i);
                    if numReagents > 0 then
                        for j = 1, numReagents do
                            local _, _, reagentCount, _ = GetTradeSkillReagentInfo(i, j)
                            local reagentLink = GetTradeSkillReagentItemLink(i, j)
                            local reagentID = GetItemInfoInstant(reagentLink)
                            if reagentID and reagentCount then
                                tradeskillRecipes[itemID][reagentID] = reagentCount
                            end
                        end
                    end

                    --moving forward this will be a new format but i need to add some defence code before we implement this
                    -- local tradeskillItemInfo = {
                    --     link = link,
                    --     itemID = itemID,
                    --     reagents = reagents,
                    -- }
                end
            end
        end
    end

    local myProf1 = Database:GetCharacterInfo(UnitGUID("player"), "Profession1")
    if myProf1 == englishProf then
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, currentLevel)

    else
        local myProf2 = Database:GetCharacterInfo(UnitGUID("player"), "Profession2")
        if myProf2 == englishProf then
            Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, currentLevel)
        end
    end

    if englishProf == "Cooking" then
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, nil, nil, nil, currentLevel, nil)

    elseif englishProf == "Fishing" then -- not sure this is possible in classic/tbc etc
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, nil, nil, currentLevel, nil, nil)

    elseif englishProf == "First Aid" then
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, nil, nil, nil, nil, currentLevel)

    end

    Database:UpdatePlayerCharacterTradeskillRecipes(englishProf, tradeskillRecipes)

end


---scan the players enchanting recipes and trigger the changed event
function Character:ScanEnchantingRecipes()

    local englishProf = nil;

    local localeProf, currentLevel, maxLevel = GetCraftDisplaySkillLine(); -- this could change if/when wrath happens, https://wowpedia.fandom.com/wiki/API_GetCraftDisplaySkillLine suggests it was removed in patch 3.0.2

    --if no prof name/level were returned lets try to get it from the ui 
    if type(localeProf) ~= "string" then

        --we need this fontstring to exist before trying
        if CraftFrameTitleText then
            localeProf = CraftFrameTitleText:GetText()
        end
        
        --now try to get the current/max levels
        local rankText = CraftRankFrameSkillRank and CraftRankFrameSkillRank:GetText() or nil;
        if rankText and rankText:find("/") then
            local currentLevel, maxLevel = strsplit("/", rankText)
            if type(currentLevel) == "string" then
                currentLevel = tonumber(currentLevel)
            end
            if type(maxLevel) == "string" then
                maxLevel = tonumber(maxLevel)
            end
            Guildbook.DEBUG("characterMixin", "Character:ScanEnchantingRecipes", string.format("found prof level [%s] from UI text", currentLevel))
        end
    end

    --check everything is all good
    if type(localeProf) == "string" and type(currentLevel) == "number" and type(maxLevel) == "number" then

        englishProf = Tradeskills:GetEnglishNameFromTradeskillName(localeProf)
        if englishProf == false then
            Guildbook.DEBUG("characterMixin", "Character:ScanEnchantingRecipes", "englishProf not known")
            return;
        end

    else
        Guildbook.DEBUG("characterMixin", "Character:ScanEnchantingRecipes", string.format("variables not correct type > %s %s %s", localeProf, currentLevel, maxLevel))
        return;
    end

    if englishProf == nil then
        Guildbook.DEBUG("characterMixin", "Character:ScanEnchantingRecipes", "englishProf is nil", localeProf)
        return;
    end

    Guildbook.DEBUG("characterMixin", "Character:ScanEnchantingRecipes", string.format("found [%s] with current level [%s] scanning for recipes", englishProf, currentLevel))

    local tradeskillRecipes = {}
    if englishProf == "Enchanting" then -- check we have enchanting open
        local numCrafts = GetNumCrafts()
        for i = 1, numCrafts do
            local name, _, _type, _, _, _, _ = GetCraftInfo(i)
            if name and (_type == "optimal" or _type == "medium" or _type == "easy" or _type == "trivial") then -- this was a fix thanks to Sigma regarding their addon showing all recipes
                local _, _, _, _, _, _, itemID = GetSpellInfo(name)
                if itemID then
                    tradeskillRecipes[itemID] = {}
                    local numReagents = GetCraftNumReagents(i);
                    if numReagents > 0 then
                        for j = 1, numReagents do
                            local _, _, reagentCount = GetCraftReagentInfo(i, j)
                            local reagentLink = GetCraftReagentItemLink(i, j)
                            if reagentLink then
                                local reagentID = select(1, GetItemInfoInstant(reagentLink))
                                if reagentID and reagentCount then
                                    tradeskillRecipes[itemID][reagentID] = reagentCount
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local myProf1 = Database:GetCharacterInfo(UnitGUID("player"), "Profession1")
    if myProf1 == englishProf then
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, currentLevel)

    else
        local myProf2 = Database:GetCharacterInfo(UnitGUID("player"), "Profession2")
        if myProf2 == englishProf then
            Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, currentLevel)
        end
    end

    if englishProf == "Cooking" then
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, nil, nil, nil, currentLevel, nil)

    elseif englishProf == "Fishing" then -- not sure this is possible in classic/tbc etc
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, nil, nil, currentLevel, nil, nil)

    elseif englishProf == "First Aid" then
        Database:UpdatePlayerCharacterTradeskillsInfo(nil, nil, nil, nil, nil, nil, nil, nil, currentLevel)

    end

    Database:UpdatePlayerCharacterTradeskillRecipes(englishProf, tradeskillRecipes)
end


---remove any old/unused recipe tables, defaults to GUILDBOOK_CHARACTER if no table provided
function Character:RemoveOldTradeskillRecipeTables(characterData)
    local characterName = "-";
    if characterData and characterData.Name then
        characterName = characterData.Name;
    else
        characterName = UnitName("player")
    end
    if not characterData then
        characterData = GUILDBOOK_CHARACTER;
    end
    for tradeskill, id in pairs(Tradeskills.TradeskillNames) do
        local isCurrentTradeskill = false;
        if characterData.Profession1 == tradeskill or characterData.Profession2 == tradeskill then
            isCurrentTradeskill = true;
            Guildbook.DEBUG("characterMixin", "Character:RemoveOldTradeskillRecipeTables", string.format("Keeping %s table for %s", tradeskill, characterName), characterData)
        end
        if isCurrentTradeskill == false and characterData[tradeskill] then
            characterData[tradeskill] = nil;
            Guildbook.DEBUG("characterMixin", "Character:RemoveOldTradeskillRecipeTables", string.format("Removed %s table from %s", tradeskill, characterName), characterData)
        end
    end
end


---scan the paperdoll frame for character stats and update the GUILDBOOK_CHARACTER table
---@param specName string the name to save stats under, defaults to current if not provided
function Character:GetPaperDollStats(specName)

    ---to make things work for wrath we will have to move the paperdoll stats into a sub table 'current' and then we can use the same system as inventory to hold stats per spec
    if GUILDBOOK_CHARACTER.PaperDollStats and not GUILDBOOK_CHARACTER.PaperDollStats.Current then
        GUILDBOOK_CHARACTER.PaperDollStats.Current = {}

        ---copy the values into new table
        for k, v in pairs(GUILDBOOK_CHARACTER.PaperDollStats) do
            GUILDBOOK_CHARACTER.PaperDollStats.Current[k] = v;
        end

        ---remove any values that arent a table
        for k, v in pairs(GUILDBOOK_CHARACTER.PaperDollStats) do
            if type(v) ~= "table" then
                GUILDBOOK_CHARACTER.PaperDollStats[k] = nil;
            elseif k == "Defence" then -- defence is a table
                GUILDBOOK_CHARACTER.PaperDollStats[k] = nil;
            end
        end
    else
        GUILDBOOK_CHARACTER.PaperDollStats = {
            Current = {},
        }
    end

    GUILDBOOK_CHARACTER.Current = nil;

    local stats = {};

    if specName == nil then
        specName = "Current";
        Guildbook.DEBUG("characterMixin", "Character:GetPaperDollStats", "using 'Current' as spec name for paper doll stats")
    end

    ---do i need to wipe it each time?
    wipe(stats);

    ---go through getting each stat value
    local numSkills = GetNumSkillLines();
    local skillIndex = 0;
    local currentHeader = nil;

    for i = 1, numSkills do
        local skillName = select(1, GetSkillLineInfo(i));
        local isHeader = select(2, GetSkillLineInfo(i));

        if isHeader ~= nil and isHeader then
            currentHeader = skillName;
        else
            if (currentHeader == "Weapon Skills" and skillName == 'Defense') then
                skillIndex = i;
                break;
            end
        end
    end

    local baseDef, modDef;
    if (skillIndex > 0) then
        baseDef = select(4, GetSkillLineInfo(skillIndex));
        modDef = select(6, GetSkillLineInfo(skillIndex));
    else
        baseDef, modDef = UnitDefense('player')
    end

    local posBuff = 0;
    local negBuff = 0;
    if ( modDef > 0 ) then
        posBuff = modDef;
    elseif ( modDef < 0 ) then
        negBuff = modDef;
    end
    stats.Defence = {
        Base = self:FormatNumberForCharacterStats(baseDef),
        Mod = self:FormatNumberForCharacterStats(modDef),
    }

    local baseArmor, effectiveArmor, armr, posBuff, negBuff = UnitArmor('player');
    stats.Armor = self:FormatNumberForCharacterStats(baseArmor)
    stats.Block = self:FormatNumberForCharacterStats(GetBlockChance());
    stats.Parry = self:FormatNumberForCharacterStats(GetParryChance());
    stats.ShieldBlock = self:FormatNumberForCharacterStats(GetShieldBlock());
    stats.Dodge = self:FormatNumberForCharacterStats(GetDodgeChance());

    --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
    stats.Expertise = self:FormatNumberForCharacterStats(GetExpertise()); --will display mainhand expertise but it stores offhand expertise as well, need to find a way to access it
    --local base, casting = GetManaRegen();

    --to work with all versions we have to adjust the values we get
    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        stats.SpellHit = self:FormatNumberForCharacterStats(GetSpellHitModifier());
        stats.MeleeHit = self:FormatNumberForCharacterStats(GetHitModifier());
        stats.RangedHit = self:FormatNumberForCharacterStats(GetHitModifier());
        
    elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
        stats.SpellHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier());
        stats.MeleeHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier());
        stats.RangedHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_RANGED));

    else
    
    end

    stats.RangedCrit = self:FormatNumberForCharacterStats(GetRangedCritChance());
    stats.MeleeCrit = self:FormatNumberForCharacterStats(GetCritChance());

    stats.Haste = self:FormatNumberForCharacterStats(GetHaste());
    local base, casting = GetManaRegen()
    stats.ManaRegen = base and self:FormatNumberForCharacterStats(base) or 0;
    stats.ManaRegenCasting = casting and self:FormatNumberForCharacterStats(casting) or 0;

    local minCrit = 100
    for id, school in pairs(self.SpellSchools) do
        if GetSpellCritChance(id) < minCrit then
            minCrit = GetSpellCritChance(id)
        end
        stats['SpellDmg'..school] = self:FormatNumberForCharacterStats(GetSpellBonusDamage(id));
        stats['SpellCrit'..school] = self:FormatNumberForCharacterStats(GetSpellCritChance(id));
    end
    stats.SpellCrit = self:FormatNumberForCharacterStats(minCrit)

    stats.HealingBonus = self:FormatNumberForCharacterStats(GetSpellBonusHealing());

    local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
    local mainSpeed, offSpeed = UnitAttackSpeed("player");
    local mlow = (lowDmg + posBuff + negBuff) * percentmod
    local mhigh = (hiDmg + posBuff + negBuff) * percentmod
    local olow = (offlowDmg + posBuff + negBuff) * percentmod
    local ohigh = (offhiDmg + posBuff + negBuff) * percentmod
    if mainSpeed < 1 then mainSpeed = 1 end
    if mlow < 1 then mlow = 1 end
    if mhigh < 1 then mhigh = 1 end
    if olow < 1 then olow = 1 end
    if ohigh < 1 then ohigh = 1 end

    if offSpeed then
        if offSpeed < 1 then 
            offSpeed = 1
        end
        stats.MeleeDmgOH = self:FormatNumberForCharacterStats((olow + ohigh) / 2.0)
        stats.MeleeDpsOH = self:FormatNumberForCharacterStats(((olow + ohigh) / 2.0) / offSpeed)
    else
        --offSpeed = 1
        stats.MeleeDmgOH = self:FormatNumberForCharacterStats(0)
        stats.MeleeDpsOH = self:FormatNumberForCharacterStats(0)
    end
    stats.MeleeDmgMH = self:FormatNumberForCharacterStats((mlow + mhigh) / 2.0)
    stats.MeleeDpsMH = self:FormatNumberForCharacterStats(((mlow + mhigh) / 2.0) / mainSpeed)

    local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
    local low = (lowDmg + posBuff + negBuff) * percent
    local high = (hiDmg + posBuff + negBuff) * percent
    if speed < 1 then speed = 1 end
    if low < 1 then low = 1 end
    if high < 1 then high = 1 end
    local dmg = (low + high) / 2.0
    stats.RangedDmg = self:FormatNumberForCharacterStats(dmg)
    stats.RangedDps = self:FormatNumberForCharacterStats(dmg/speed)

    local base, posBuff, negBuff = UnitAttackPower('player')
    stats.AttackPower = self:FormatNumberForCharacterStats(base + posBuff + negBuff)

    for k, stat in pairs(self.StatIDs) do
        local a, b, c, d = UnitStat("player", k);
        stats[stat] = self:FormatNumberForCharacterStats(b)
    end


    Database:UpdatePlayerCharacterTable(specName, stats, "PaperDollStats")
end


---check any system messages for a skill up and update the db
---@param message string the system message sent
function Character:OnChatMessageSystem(message)
    local skill, value = message:match(self.SkillUpPattern)
    if skill and value then
        local englishProf = Tradeskills:GetEnglishNameFromTradeskillName(skill)
        if englishProf ~= false then
            local dbKey;

            --just need to grab the correct key for the character table
            if englishProf == "Fishing" then
                dbKey = "FishingLevel"
            elseif englishProf == "Cooking" then
                dbKey = "CookingLevel"
            elseif englishProf == "First Aid" or englishProf == "FirstAid" then
                dbKey = "FirstAidLevel"
            
            --check for main professions
            elseif englishProf == GUILDBOOK_CHARACTER.Profession1 then
                dbKey = "Profession1Level"
            elseif englishProf == GUILDBOOK_CHARACTER.Profession2 then
                dbKey = "Profession2Level"
            end

            Guildbook.DEBUG("characterMixin", "Character:OnChatMessageSystem", string.format("dbKey %s value %s", dbKey, value))
            if type(dbKey) == "string" and type(value) == "number" then
                Database:UpdatePlayerCharacterTable(dbKey, value)
            end
        end
    end
end



---initialises Character, sets up the listener for events
function Character:Init()

    Guildbook.DEBUG("characterMixin", "Character:Init", "initialising the character class")

    CallbackRegistryMixin.OnLoad(self)

    self.listener = CreateFrame("Frame")
    self.listener:RegisterEvent("TRADE_SKILL_UPDATE")
    self.listener:RegisterEvent("CRAFT_UPDATE")
    self.listener:RegisterEvent("SKILL_LINES_CHANGED")
    self.listener:RegisterEvent("CHARACTER_POINTS_CHANGED")
    self.listener:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.listener:RegisterEvent("CHAT_MSG_SKILL")
    self.listener:RegisterEvent("PLAYER_LEVEL_UP")

    --lets grab some data as we've loaded, these calls will updste the db which will trigger an outward comms
    self:GetInventory()
    self:GetPaperDollStats()
    self:ScanPlayerTalents()
    self:ScanForTradeskillInfo()

    self.listener:SetScript("OnEvent", function(_, event, ...)
        Guildbook.DEBUG("event", "Character:OnEvent", string.format("event: %s", event))

        if event == "TRADE_SKILL_UPDATE" then
            --delay this (0 would maybe work) to make sure we get the correct text, i think it needs a frame update to happen for the fontstring text to be updated ?
            C_Timer.After(0.1, function()
                self:ScanTradeskillRecipes()
            end)

        elseif event == "CRAFT_UPDATE" then
            C_Timer.After(0.1, function()
                self:ScanEnchantingRecipes()
            end)

        elseif event == "SKILL_LINES_CHANGED" then
            self:ScanForTradeskillInfo()

        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            self:GetInventory()

            self:GetPaperDollStats()

        elseif event == "CHARACTER_POINTS_CHANGED" then
            self:ScanPlayerTalents()

            ---as talents can/do effect crit chance, hit chance, power etc we should scan the paperdoll stats as well
            ---this will default to Current at the moment
            self:GetPaperDollStats()

        elseif event == "CHAT_MSG_SKILL" then
            --DevTools_Dump({...})
            local message = ...
            self:OnChatMessageSystem(message)

        elseif event == "PLAYER_LEVEL_UP" then
            local newLevel = ...
            self:TriggerEvent("OnPlayerLevelUp", self, {
                newsType = "playerLevelUp",
                text = string.format(L["NF_PLAYER_LEVEL_UP_SS"], UnitName("player"), newLevel)
            })


        end
    end)



    hooksecurefunc(C_LFGList, "CreateListing", function(activities)

        for i = 1, 3 do
            local fullName, shortName, categoryID, groupID, itemLevel, filters, minLevel, maxPlayers = C_LFGList.GetActivityInfo(activities[i])

            if fullName then

                local activityCategoryName = categoryID and C_LFGList.GetCategoryInfo(categoryID) or "-";

                self:TriggerEvent("OnLFGListingCreated", self, {
                    activityName = activityCategoryName,
                    activityLocation = fullName,
                })
            end
        end
    end)
    
    hooksecurefunc(C_LFGList, "RemoveListing", function(info)
        
    end)
end


Guildbook.Character = Character;









--[[
    Chats class

    this class makes use of the chat filters to grab messages sent
    and then using the triggers the ui can get updates
]]
-- local Chats = CreateFromMixins(CallbackRegistryMixin)
-- Chats:GenerateCallbackEvents({
--     "OnGuildMessage",
--     "OnPartyMessage",
--     "OnRaidMessage",
--     "OnWhisperMessage",
-- })
-- Chats.channels = {
--     guild = {},
--     whispers = {},
--     party = {},
--     raid = {},
-- }












--[[
/////////////////////////////////////////////////////////////////

    @class Comms

/////////////////////////////////////////////////////////////////
]]
--local Comms = CreateFromMixins(CallbackRegistryMixin)
Comms:GenerateCallbackEvents({
    "OnNewsFeedReceived",
})
--local Comms = {}
---this value can be adjusted but its purpose is to allow all bulk comms to be received before we process the data - there is a settings slider for this which needs to be hooked up maybe or just set as a default value
Comms.DELAY = 2.0;
Comms.PREFIX = "GUILDBOOK";
Comms.version = nil;
Comms.versionsChecked = {};
Comms.privacyRules = {
    shareInventoryMinRank = "Inventory",
    shareTalentsMinRank = "Talents",
    shareProfileMinRank = "Profile",
}

---these values control when we send data about the players recipes
Comms.sendPlayerCharacterTradeskillRecipes_IsQueued = false;
Comms.sendPlayerCharacterTradeskillRecipesQueueTimer = 3.0;
Comms.playerCharacterTradeskillRecipesUpdate = {};

---these values control when we send data about the players tradeskills
Comms.sendPlayerCharacterTradeskillsInfo_IsQueued = false;
Comms.sendPlayerCharacterTradeskillsInfoQueueTimer = 3.0;
Comms.playerCharacterTradeskillsInfoUpdate = {};

---these values control when we send data about the players character
Comms.sendPlayerCharacterUpdates_IsQueued = false;
Comms.sendPlayerCharacterUpdatesQueueTimer = 3.0;
Comms.playerCharacterUpdate = {};


--this was to add alt and spec info the guild chat channel, however using just a filter only really allows the message to eb modified not the sender part - will leave in for now though
function Comms.CharacterSpecAndMainChatFilter(self, event, msg, author, ...)

    local guid = select(10, ...)
    local character = Database:FetchCharacterTableByGUID(guid)

    if character then
        local atlas = nil;
        local main = nil;

        -- check if we want to show spec icon
        if (GUILDBOOK_GLOBAL.config.showSpecGuildChat == true) and character.Class and character.MainSpec and (character.MainSpec ~= "-") then
            local icon = Guildbook:GetClassSpecAtlasName(character.Class, character.MainSpec)
            atlas = CreateAtlasMarkup(icon, 12,12)
        end

        -- check if we want to add main character namew
        if (GUILDBOOK_GLOBAL.config.showMainCharacterGuildChat == true) and character.MainCharacter then
            local mainChar = Database:FetchCharacterTableByGUID(character.MainCharacter)
            if mainChar and (guid ~= character.MainCharacter) then
                main = Guildbook.Colours[mainChar.Class]:WrapTextInColorCode(mainChar.Name)
            end
        end

        if main ~= nil then
            return false, string.format("[%s] %s", main, msg), author, ...
        end

        return false, msg, author, ...

    else
        return false, msg, author, ...
    end

end



---this listens to the database class for config changes
---@param db table the Database class
---@param config table the currrent config values
function Comms:OnGuildbookConfigChanged(db, config)

    if config.showMainCharacterGuildChat == false then
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_GUILD", self.CharacterSpecAndMainChatFilter)
    else
        ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", self.CharacterSpecAndMainChatFilter)
    end
end




function Comms:Init()

    Guildbook.DEBUG("commsMixin", "Comms:Init", "initialising the comms class")

    CallbackRegistryMixin.OnLoad(self)

    AceComm:Embed(self)
    self:RegisterComm(self.PREFIX)

    self.version = tonumber(GetAddOnMetadata('Guildbook', "Version"));

    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.config then
        if GUILDBOOK_GLOBAL.config.showMainCharacterGuildChat == false then
            ChatFrame_RemoveMessageEventFilter("CHAT_MSG_GUILD", self.CharacterSpecAndMainChatFilter)
        else
            ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", self.CharacterSpecAndMainChatFilter)
        end
    end

    Database:RegisterCallback("OnGuildbookConfigChanged", self.OnGuildbookConfigChanged, self)

    ---tradeskill data is always shared so hook up the callbacks so we can send updates
    Database:RegisterCallback("OnPlayerCharacterTradeskillsInfoChanged", self.SendCharacterTradeskillInfo, self)
    Database:RegisterCallback("OnPlayerCharacterTradeskillRecipesChanged", self.SendCharacterTradeskillsRecipes, self)

    ---this is a slightly special case as some of the table data is under privacy rules - this is basically spec and primary profs
    Database:RegisterCallback("OnPlayerCharacterTableChanged", self.SendPlayerCharacterUpdates, self)


    self:RegisterCallback("OnNewsFeedReceived", GuildbookUI.home.OnNewsFeedReceived, GuildbookUI.home)

    Character:RegisterCallback("OnLFGListingCreated", self.SendLFGListingCreated, self)
    Character:RegisterCallback("OnPlayerLevelUp", self.SendNewsUpdate, self)

    --Roster:RegisterCallback("On")

    ---lets not be rude
    self:SayHello()
end


---send an addon message through the aceComm lib
---@param data table the data to send including a comm type
---@param channel string the addon channel to use for the comm
---@param targetGUID string the targets GUID, this is used to make comms work on conneted realms - only required for WHISPER comms
---@param priority string the prio to use
---@param uiMessage string a message to display in the addon UI top right status text area
function Comms:Transmit(data, channel, targetGUID, priority, uiMessage)

    -- if type(targetGUID) == "string" and Roster.onlineStatus[targetGUID] and Roster.onlineStatus[targetGUID].isOnline ~= true then
    --     Guildbook.DEBUG('commsMixin', 'Comms:Transmit', "cancel transmit as target is offline", data)
    --     return;
    -- end

    if targetGUID == UnitGUID("player") then
        Guildbook.DEBUG('commsMixin', 'Comms:Transmit', "cancel transmit as target is player", data)
        --return;
    end

    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI:SetInfoText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI:SetInfoText("blocked data comms while in combat")
            return;
        end
    end
    if IsInGuild() and GetGuildInfo("player") then
        -- we just want to make sure we are in a guild here to stop spam
    else
        return;
    end

    -- add the version and sender guid to the message
    data["version"] = self.version;
    data["senderGUID"] = UnitGUID("player")

    -- clean up the target name when using a whisper
    if channel == 'WHISPER' then

        -- i dont like this approach but if i get reports of spam messages this might have to exist as the solution, on a positive it frees up the ui to show online list better
        local totalMembers = GetNumGuildMembers()
        for i = 1, totalMembers do
            local nameRealm, _, _, _, _, _, _, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            if guid == targetGUID and isOnline == true then
                Guildbook.DEBUG('commsMixin', 'SendCommMessage_TargetOnline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority), data)
                
                local target = Ambiguate(nameRealm, "none")

                local serialized = LibSerialize:Serialize(data);
                local compressed = LibDeflate:CompressDeflate(serialized);
                local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
            
                if encoded and channel and priority and target then
                
                    self:SendCommMessage(Comms.PREFIX, encoded, channel, target, priority)
    
                    if uiMessage and type(uiMessage) == "string" then
                        GuildbookUI:SetInfoText(uiMessage)
                    end

                    return; -- stop looping the roster

                end
            end
        end
        

        -- local target = false;
        -- if Roster.guidToCharacterNameRealm[targetGUID] then
        --     target = Ambiguate(Roster.guidToCharacterNameRealm[targetGUID], "none")
        -- end

        -- if type(target) ~= "string" then
        --     Guildbook.DEBUG('commsMixin', 'SendCommMessage_TargetOnline', "cancel transmit, target not of type string, will try using GetPlayerInfoByGUID")
        
        --     local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(targetGUID)

        --     if realm == "" then
        --         target = string.format("%s-%s", name, GetNormalizedRealmName());
        --     else
        --         target = string.format("%s-%s", name, realm);
        --     end

        --     if type(target) ~= "string" then
        --         Guildbook.DEBUG('commsMixin', 'SendCommMessage_TargetOnline', "cancel transmit, target not of type string")
        --         return
        --     end
        -- end

        -- if type(target) == "string" then            

        --     local serialized = LibSerialize:Serialize(data);
        --     local compressed = LibDeflate:CompressDeflate(serialized);
        --     local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
        
        --     if encoded and channel and priority then

        --         -- i dont like this approach but if i get reports of spam messages this might have to exist as the solution, on a positive it frees up the ui to show online list better
        --         local totalMembers = GetNumGuildMembers()
        --         for i = 1, totalMembers do
        --             local nameRealm, _, _, _, _, _, _, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
        --             if guid == targetGUID and isOnline == true then
        --                 Guildbook.DEBUG('commsMixin', 'SendCommMessage_TargetOnline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority), data)
                        
        --                 local target = Ambiguate(nameRealm, "none")
                        
        --                 self:SendCommMessage(Comms.PREFIX, encoded, channel, target, priority)
        
        --                 if uiMessage and type(uiMessage) == "string" then
        --                     GuildbookUI:SetInfoText(uiMessage)
        --                 end
        --                 return;
        --             end
        --         end
        --     end
        -- end

    elseif channel == "GUILD" then
        local serialized = LibSerialize:Serialize(data);
        local compressed = LibDeflate:CompressDeflate(serialized);
        local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    
        if encoded and channel and priority then
            Guildbook.DEBUG('commsMixin', 'SendCommMessage_NoTarget', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, 'nil', priority))
            self:SendCommMessage(Comms.PREFIX, encoded, channel, nil, priority)

            if uiMessage and type(uiMessage) == "string" then
                GuildbookUI:SetInfoText(uiMessage)
            end
        end
    end
end


function Comms:OnCommReceived(prefix, message, distribution, sender)

    ---check if we want to process comms data
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI:SetInfoText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI:SetInfoText("blocked data comms while in combat")
            return;
        end
    end

    if prefix ~= self.PREFIX then 
        return 
    end
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message);
    if not decoded then
        return;
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then
        return;
    end
    local success, data = LibSerialize:Deserialize(decompressed);
    if not success or type(data) ~= "table" then
        return;
    end

    Guildbook.DEBUG('commsMixin', string.format("Comms:OnCommsReceived <%s>", distribution), string.format("%s from %s", data.type, sender), data)
    
    ---before we process the data pause to allow all messages to be put together again
    C_Timer.After(self.DELAY, function()
        self:ProcessIncomingData(data, sender)
    end)
end


function Comms:ProcessIncomingData(data, sender)

    if type(data) == "table" and type(data.type) == "string" then

        Guildbook.DEBUG('commsMixin', "Comms:ProcessIncomingData", string.format("%s has sent data of type %s", sender, data.type), data)

        if self.MessageHandlers[data.type] then

            Guildbook.DEBUG('commsMixin', "Comms:ProcessIncomingData", string.format("MessageHandler %s does exist", data.type), data)
            GuildbookUI:SetInfoText(string.format("incoming data from %s [%s]", sender, data.type))
            self.MessageHandlers[data.type](self, data, sender)

        else
            Guildbook.DEBUG('commsMixin', "Comms:ProcessIncomingData", string.format("MessageHandler %s does NOT exist", data.type), data)
        end

    else
        Guildbook.DEBUG('commsMixin', "Comms:ProcessIncomingData", string.format("[%s] data sent is NOT a table and data.type is NOT a string", sender), data)
    end

end


function Comms:CheckPrivacyRuleForTargetGUID(targetGUID, rule)
    if not targetGUID then
        return false;
    end
    if not GUILDBOOK_GLOBAL then
        return false;
    end
    if not GUILDBOOK_GLOBAL.config then
        return false;
    end
    if not GUILDBOOK_GLOBAL.config.privacy then
        return false;
    end
    if not GUILDBOOK_GLOBAL.config.privacy[rule] then
        return false;
    end
    if GUILDBOOK_GLOBAL.config.privacy[rule] == "none" then
        return false;
    end
    Roster:CheckPrivacyRankSettings() -- double check all ranks are good
    local ranks = {}
    for i = 1, GuildControlGetNumRanks() do
        ranks[GuildControlGetRankName(i)] = i;
    end
    local privacyRank = GUILDBOOK_GLOBAL.config.privacy[rule];
    local targetRank = GuildControlGetRankName(C_GuildInfo.GetGuildRankOrder(targetGUID))
    local character = Database:FetchCharacterTableByGUID(targetGUID)
    if type(character) ~= "table" then
        return false;
    end
    local targetName = character.Name or "unknown name or character"
    ---lower ranks are actually higher in the guild
    if ranks[targetRank] and ranks[privacyRank] then
        Guildbook.DEBUG("commsMixin", "CheckPrivacyRuleForTargetGUID", "got rank values", {
            targetRank = ranks[targetRank],
            privayRank = ranks[privacyRank],
            targetCharacter = targetName,
        })
        if ranks[targetRank] <= ranks[privacyRank] then
            Guildbook.DEBUG("commsMixin", "CheckPrivacyRuleForTargetGUID", string.format("privacy rule %s is ok to share with %s", rule, targetName))
            return true;
        end
    end
    return false;
end


---send a response that something isnt shared
---@param targetGUID string the targetGUID to send data to
---@param rule string the privacy rule being queried
function Comms:SendPrivacyNotice(targetGUID, rule)

    local privacyNotice = {
        type = "PRIVACY_NOTICE",
        payload = rule,
    }

    Guildbook.DEBUG("commsMixin", "Comms:SendPrivacyNotice", "-", privacyNotice)
    self:Transmit(privacyNotice, "WHISPER", targetGUID, "NORMAL")
end



function Comms:OnPrivacyNotice(data, sender)
    Guildbook.DEBUG("commsMixin", "Comms:OnPrivacyNotice", "-", data)
    GuildbookUI:SetInfoText(string.format("%s does not share %s", sender, self.privacyRules[data.payload]))
end



function Comms:SayHello()

    local greeting = {
        type = "CHARACTER_ONLINE",
        payload = {
            version = self.version,
        }
    }

    self:Transmit(greeting, "GUILD", nil, "NORMAL")
end


---send a request for the target characters profile, talents and inventory
---@param targetGUID any
function Comms:RequestCharacterInfo(targetGUID)

    local request = {
        type = "REQUEST_CHARACTER_INFO",
        payload = {
            inventory = true,
            talents = true,
            profile = true,
        }
    }

    local targetCharacterName = Roster.guidToCharacterNameRealm[targetGUID] or "unknown character"

    Guildbook.DEBUG("commsMixin", "Comms:RequestCharacterInfo", string.format("requesting character info from %s", targetCharacterName), request.payload)
    self:Transmit(request, "WHISPER", targetGUID, "NORMAL", string.format("requesting character info from %s", targetCharacterName))
end


---send player talent info to the target, this will first check if the target is allowed to see this info as per privacy rules
---@param targetGUID string the targets guid
function Comms:SendCharacterTalentsInfo(targetGUID)

    if self:CheckPrivacyRuleForTargetGUID(targetGUID, "shareTalentsMinRank") == false then
        self:SendPrivacyNotice(targetGUID, "shareTalentsMinRank")
        return;
    end

    local talentsInfo = {
        type = "CHARACTER_TALENTS_UPDATE",
        payload = {
            talents = GUILDBOOK_CHARACTER.Talents,
            talentTabs = GUILDBOOK_CHARACTER.TalentTabs,
        },
    }

    Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTalentsInfo", "-", talentsInfo)
    self:Transmit(talentsInfo, "WHISPER", targetGUID, "BULK")
end



function Comms:SendCharacterProfileInfo(targetGUID)

    if self:CheckPrivacyRuleForTargetGUID(targetGUID, "shareProfileMinRank") == false then
        self:SendPrivacyNotice(targetGUID, "shareProfileMinRank")
        return;
    end

    local profile = GUILDBOOK_CHARACTER.profile;
    if type(profile) ~= "table" then
        
        local _, class = UnitClass("player")
        local avatar = Guildbook.Data.Class[class].IconID;

        profile = {
            avatar = avatar,
            realDob = "",
            realName = "",
            realBio = "",
        }
    end

    local profileInfo = {
        type = "CHARACTER_PROFILE_UPDATE",
        payload = profile,
    }

    Guildbook.DEBUG("commsMixin", "Comms:SendCharacterProfileInfo", "-", profileInfo)
    self:Transmit(profileInfo, "WHISPER", targetGUID, "NORMAL")
end


---send player inventory info to the target, this will first check if the target is allowed to see this info as per privacy rules
---@param targetGUID string the targets guid
function Comms:SendCharacterInventoryInfo(targetGUID)

    if self:CheckPrivacyRuleForTargetGUID(targetGUID, "shareInventoryMinRank") == false then
        self:SendPrivacyNotice(targetGUID, "shareInventoryMinRank")
        return;
    end

    local inventoryInfo = {
        type = "CHARACTER_INVENTORY_UPDATE",
        payload = {
            inventory = GUILDBOOK_CHARACTER.Inventory,
        },
    }

    Guildbook.DEBUG("commsMixin", "Comms:endCharacterInventoryInfo", "-", inventoryInfo)
    self:Transmit(inventoryInfo, "WHISPER", targetGUID, "BULK")
end


---send player paper doll stats, no check required for this, could be added i guess ?
---@param targetGUID string the targets guid
function Comms:SendCharacterPaperDollStatsInfo(targetGUID)

    local paperDollStatsInfo = {
        type = "CHARACTER_PAPERDOLLSTATS_UPDATE",
        payload = {
            paperDollStats = GUILDBOOK_CHARACTER.PaperDollStats,
        },
    }

    Guildbook.DEBUG("commsMixin", "Comms:endCharacterInventoryInfo", "-", paperDollStatsInfo)
    self:Transmit(paperDollStatsInfo, "WHISPER", targetGUID, "BULK")
end


---send player character tradeskill info including prof name, level and spec
function Comms:SendCharacterTradeskillInfo(databaseMixin)

    --DevTools_Dump({tradeskillsInfo})

    self.playerCharacterTradeskillsInfoUpdate = {
        type = "CHARACTER_TRADESKILLS_INFO_UPDATE",
        payload = {
            Profession1 = GUILDBOOK_CHARACTER.Profession1,
            Profession1Level = GUILDBOOK_CHARACTER.Profession1Level,
            Profession1Spec = GUILDBOOK_CHARACTER.Profession1Spec,

            Profession2 = GUILDBOOK_CHARACTER.Profession2,
            Profession2Level = GUILDBOOK_CHARACTER.Profession2Level,
            Profession2Spec = GUILDBOOK_CHARACTER.Profession2Spec,

            FishingLevel = GUILDBOOK_CHARACTER.FishingLevel,
            CookingLevel = GUILDBOOK_CHARACTER.CookingLevel,
            FirstAidLevel = GUILDBOOK_CHARACTER.FirstAidLevel,
        }
    }

    if self.sendPlayerCharacterTradeskillsInfo_IsQueued == false then
        Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTradeskillInfo", "queuing player character tradeskill info", self.playerCharacterTradeskillsInfoUpdate)
        C_Timer.After(self.sendPlayerCharacterTradeskillsInfoQueueTimer, function()
            self:Transmit(self.playerCharacterTradeskillsInfoUpdate, "GUILD", nil, "NORMAL")
            Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTradeskillInfo", "sending tradeskill info", self.playerCharacterTradeskillsInfoUpdate)
            self.sendPlayerCharacterTradeskillsInfo_IsQueued = false;
        end)
        self.sendPlayerCharacterTradeskillsInfo_IsQueued = true;
    else
        Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTradeskillInfo", "player character tradeskill info already in queue", self.playerCharacterTradeskillsInfoUpdate)
    end

end



function Comms:SendTradeskillInfoToTargetGUID(targetGUID)

    local tradeskillsInfoUpdate = {
        type = "CHARACTER_TRADESKILLS_INFO_UPDATE",
        payload = {
            Profession1 = GUILDBOOK_CHARACTER.Profession1,
            Profession1Level = GUILDBOOK_CHARACTER.Profession1Level,
            Profession1Spec = GUILDBOOK_CHARACTER.Profession1Spec,

            Profession2 = GUILDBOOK_CHARACTER.Profession2,
            Profession2Level = GUILDBOOK_CHARACTER.Profession2Level,
            Profession2Spec = GUILDBOOK_CHARACTER.Profession2Spec,

            FishingLevel = GUILDBOOK_CHARACTER.FishingLevel,
            CookingLevel = GUILDBOOK_CHARACTER.CookingLevel,
            FirstAidLevel = GUILDBOOK_CHARACTER.FirstAidLevel,
        }
    }

    self:Transmit(tradeskillsInfoUpdate, "WHISPER", targetGUID, "NORMAL")
    local character = Database:FetchCharacterTableByGUID(targetGUID)
    if type(character) == "table" then
        Guildbook.DEBUG("commsMixin", "Comms:SendTradeskillInfoToTargetGUID", character.Name or "unknown character", tradeskillsInfoUpdate)
    end
end


---send the player characters tradeskill recipes
---@param tradeskillName string the prof name for these recipes
function Comms:SendCharacterTradeskillsRecipes(databaseMixin, tradeskillName)

    self.playerCharacterTradeskillRecipesUpdate = {
        type = "CHARACTER_TRADESKILLS_RECIPES_UPDATE",
        payload = {
            tradeskill = tradeskillName,
            recipes = GUILDBOOK_CHARACTER[tradeskillName],
        }
    }

    if self.sendPlayerCharacterTradeskillRecipes_IsQueued == false then
        Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTradeskillsRecipes", "queuing player character tradeskill recipes", self.playerCharacterTradeskillRecipesUpdate)
        C_Timer.After(self.sendPlayerCharacterTradeskillRecipesQueueTimer, function()
            self:Transmit(self.playerCharacterTradeskillRecipesUpdate, "GUILD", nil, "BULK")
            Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTradeskillsRecipes", "sending tradeskill recipes", self.playerCharacterTradeskillRecipesUpdate)
            self.sendPlayerCharacterTradeskillRecipes_IsQueued = false;
        end)
        self.sendPlayerCharacterTradeskillRecipes_IsQueued = true;
    else
        Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTradeskillsRecipes", "player character tradeskill recipes already in queue", self.playerCharacterTradeskillRecipesUpdate)
    end
end




function Comms:SendTradeskillsRecipesToTargetGUID(tradeskillName, targetGUID)

    if type(tradeskillName) == "string" and GUILDBOOK_CHARACTER[tradeskillName] then

        local tradeskillsRecipesUpdate = {
            type = "CHARACTER_TRADESKILLS_RECIPES_UPDATE",
            payload = {
                tradeskill = tradeskillName,
                recipes = GUILDBOOK_CHARACTER[tradeskillName],
            }
        }

        self:Transmit(tradeskillsRecipesUpdate, "WHISPER", targetGUID, "BULK")
        local character = Database:FetchCharacterTableByGUID(targetGUID)
        Guildbook.DEBUG("commsMixin", "Comms:SendTradeskillsRecipesToTargetGUID", character.Name or "unknown character", tradeskillsRecipesUpdate)
    end
end



---send player character info, this function must only send top level key/value pairs as we handle the incoming data in a loop and update character table `t[k] = v`
---@param databaseMixin any
---@param characterSavedVar any
function Comms:SendPlayerCharacterUpdates(databaseMixin, characterSavedVar)

    ---profile, inventory and talents must abide by privacy rules and so cannot be sent via this function
    self.playerCharacterUpdate = {
        type = "PLAYER_CHARACTER_UPDATE",
        payload = {
            MainSpec = characterSavedVar.MainSpec,
            OffSpec = characterSavedVar.OffSpec,
            MainCharacter = characterSavedVar.MainCharacter,
            PaperDollStats = characterSavedVar.PaperDollStats,
            ItemLevel = characterSavedVar.ItemLevel,
            ---we can add in here ilvl, main, alts etc - need to check how they were set up though
        }
    }

    ---as player character data could be updated multiple times very quickly lets make sure we dont spam the chat channels and add a short cooldown buffer
    if self.sendPlayerCharacterUpdates_IsQueued == false then
        Guildbook.DEBUG("commsMixin", "Comms:SendPlayerCharacterUpdates", "queuing player character updates", self.playerCharacterUpdate)
        C_Timer.After(self.sendPlayerCharacterUpdatesQueueTimer, function()
            self:Transmit(self.playerCharacterUpdate, "GUILD", nil, "NORMAL")
            Guildbook.DEBUG("commsMixin", "Comms:SendPlayerCharacterUpdates", "sending player character updates", self.playerCharacterUpdate)
            self.sendPlayerCharacterUpdates_IsQueued = false;
        end)
        self.sendPlayerCharacterUpdates_IsQueued = true;
    else
        Guildbook.DEBUG("commsMixin", "Comms:SendPlayerCharacterUpdates", "player character updates already in queue", self.playerCharacterUpdate)
    end
end


-- im keeping this activity/news seperate as i might incorporate the notification bar above the chat window...?
function Comms:SendLFGListingCreated(_, info)

    local listing = {
        type = "LFG_LISTING_CREATED",
        payload = {
            activityCategoryName = info.activityName,
            activityLocation = info.activityLocation,
        }
    }

    self:Transmit(listing, "GUILD", nil, "NORMAL")

end


---comment
---@param _ table this will be the callback owner table, ignore it
---@param info table this will be sent as the payload it will need a `newsType` and `text` fields currently - just needs to match what the template contains/requires
function Comms:SendNewsUpdate(_, info)

    local news = {
        type = "NEWS_FEED_UPDATE",
        payload = info,
    }

    self:Transmit(news, "GUILD", nil, "NORMAL")
end


---tell whoever just came online what your spec and main is etc, this can use the same message type as the general update as the on receieve just loops the main table keys
---@param targetGUID any
function Comms:SayHelloBack(targetGUID)

    local msg = {
        type = "PLAYER_CHARACTER_UPDATE",
        payload = {
            MainSpec = GUILDBOOK_CHARACTER.MainSpec,
            OffSpec = GUILDBOOK_CHARACTER.OffSpec,
            MainCharacter = GUILDBOOK_CHARACTER.MainCharacter,
        }
    }

    self:Transmit(msg, "WHISPER", targetGUID, "NORMAL")
end


function Comms:TellGuildMemberItsTimeToUpdate(targetGUID)

    local update = {
        type = "GUILDBOOK_UPDATE",
        payload = {
            version = self.version,
        }
    }

    self:Transmit(update, "WHISPER", targetGUID, "NORMAL")
end


function Comms:OnUpdateMessage(data)
    if type(data.payload.version) == "number" then
        if self.version < data.payload.version then
            if not self.versionsChecked[data.payload.version] then
                local msgID = math.random(4)
                Guildbook:PrintMessage(L["NEW_VERSION_"..msgID])
                self.versionsChecked[data.payload.version] = true;
            end
        end
    end
end



---thre stagger delays here should be monitored and adjusted if any reports show them to close or, maybe even reduced if all is good
function Comms:OnCharacterOnline(data, sender)

    Guildbook.DEBUG("commsMixin", "Comms:OnCharacterOnline", "someone came online", data)

    --- lets check their version info and tell them to update if they're running older version
    if type(data.payload.version) == "number" then
        if self.version < data.payload.version then
            if not self.versionsChecked[data.payload.version] then
                local msgID = math.random(4)
                Guildbook:PrintMessage(L["NEW_VERSION_"..msgID])
                self.versionsChecked[data.payload.version] = true;
            end

        elseif self.version > data.payload.version then
            self:TellGuildMemberItsTimeToUpdate(data.senderGUID)
        end
    end

    --local randomDelay = math.random(2,5)

    C_Timer.After(0.5, function()
        self:SayHelloBack(data.senderGUID)
    end)

    ---update the player who just logged in, these calls will perform a privacy check before sending data
    ---using the stagger system i implemented in the original comms system, it just helps to reduce overloading the chat channels
    
    C_Timer.After(2.0, function()
        self:SendCharacterTalentsInfo(data.senderGUID);
    end)

    C_Timer.After(3.5, function()
        self:SendCharacterInventoryInfo(data.senderGUID);
    end)

    C_Timer.After(5.0, function()
        self:SendCharacterProfileInfo(data.senderGUID);
    end)

    --lets also whisper them our current tradeskills info, this doesnt need a privacy check
    C_Timer.After(6.5, function()
        self:SendTradeskillInfoToTargetGUID(data.senderGUID);
    end)

    local guid = UnitGUID("player")
    if guid:find("Player-") then
        local myProf1 = Database:GetCharacterInfo(UnitGUID("player"), "Profession1")
        local myProf2 = Database:GetCharacterInfo(UnitGUID("player"), "Profession2")

        -- should we also whisper our recipes? will need to loop for both profs - LEAVE THE GAP BETWEEN PROFS AS 3s
        if myProf1 and Tradeskills.TradeskillNames[myProf1] then
            C_Timer.After(8.0, function()
                self:SendTradeskillsRecipesToTargetGUID(myProf1, data.senderGUID);
            end)
        end
        if myProf2 and Tradeskills.TradeskillNames[myProf2] then
            C_Timer.After(11.0, function()
                self:SendTradeskillsRecipesToTargetGUID(myProf2, data.senderGUID);
            end)
        end
    end

end




function Comms:OnCharacterTradeskillsRecipesUpdate(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterTradeskillsRecipesUpdate", "data is not a table", data)
        return;
    end

    if data.senderGUID and data.payload.tradeskill then
        if type(data.payload.recipes) == "table" then
            Database:UpdateCharacterTradeskillRecipes(data.senderGUID, data.payload.tradeskill, data.payload.recipes)
        end
    end

end


function Comms:OnCharacterTradeskillsInfoUpdate(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterTradeskillsInfoUpdate", "data is not a table", data)
        return;
    end

    if data.senderGUID and type(data.payload) == "table" then
        for k, v in pairs(data.payload) do
            Database:UpdateCharacterTable(data.senderGUID, k, v)
        end
    end

end



function Comms:OnCharacterTalentsUpdate(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterTalentsUpdate", "data is not a table", data)
        return;
    end

    if data.senderGUID then
        Database:UpdateCharacterTable(data.senderGUID, "Talents", data.payload.talents)
        Database:UpdateCharacterTable(data.senderGUID, "TalentTabs", data.payload.talentTabs)
    end

end



function Comms:OnCharacterPaperDollStatsUpdate(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterPaperDollStatsUpdate", "data is not a table", data)
        return;
    end

    if data.senderGUID then
        Database:UpdateCharacterTable(data.senderGUID, "PaperDollStats", data.payload.talents)
    end

end



function Comms:OnCharacterInventoryUpdate(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterInventoryUpdate", "data is not a table", data)
        return;
    end

    if data.senderGUID then
        Database:UpdateCharacterTable(data.senderGUID, "Inventory", data.payload.inventory)
    end

end



function Comms:OnCharacterUpdate(data)
    --print("OnCharacterUpdate")

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterUpdate", "data is not a table", data)
        return;
    end

    if data.senderGUID and type(data.payload) == "table" then
        --print("got a table to loop")
        for k, v in pairs(data.payload) do
            Guildbook.DEBUG('commsMixin', "Comms:OnCharacterUpdate", string.format("updating %s", k), data.payload)
            if type(k) == "string" then
                Database:UpdateCharacterTable(data.senderGUID, k, v)
            else
                Guildbook.DEBUG('commsMixin', "Comms:OnCharacterUpdate", "updating db, key is not a string value", {
                    ["key"] = k,
                    ["value"] = v,
                })
            end
        end
    end

end



function Comms:OnLFGListingCreated(data, sender)

    if type(data) == "table" then
        self:TriggerEvent("OnNewsFeedReceived", self, {
            newsType = "lfg",
            text = string.format(L["NF_LFG_CREATED_S"], sender, data.payload.activityLocation, data.payload.activityCategoryName),
        })

        --we could add the chat window ui widget for DF/GF notifications here
        --when the data comes in just show the widget and update the text shown etc
        --have a timer to fade it out
    end

end



function Comms:OnNewsFeedUpdate(data, sender)

    if type(data) == "table" then
        self:TriggerEvent("OnNewsFeedReceived", self, data.payload)
    end

end



function Comms:OnCharacterProfileUpdate(data, sender)

    --DevTools_Dump({data})

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterInventoryUpdate", "data is not a table", data)
        return;
    end

    if type(data.payload) ~= "table" then
        Guildbook.DEBUG('commsMixin', "Comms:OnCharacterInventoryUpdate", "data.payload is not a table", data)
        return;
    end

    if data.senderGUID and data.payload.avatar then -- check if an avatar field exists
        Database:UpdateCharacterTable(data.senderGUID, "profile", data.payload) -- yes this uses a lower case key
    end

end


function Comms:OnCharacterInfoRequested(data, sender)


    if data.payload.inventory == true then
        self:SendCharacterInventoryInfo(data.senderGUID)
    end

    if data.payload.talents == true then
        C_Timer.After(1.0, function()
            self:SendCharacterTalentsInfo(data.senderGUID)
        end)
    end

    if data.payload.profile == true then
        C_Timer.After(2.0, function()
            self:SendCharacterProfileInfo(data.senderGUID)
        end)
    end

    if data.payload.profile == true then
        C_Timer.After(3.0, function()
            self:SendCharacterPaperDollStatsInfo(data.senderGUID)
        end)
    end

end


---pointers to the message handler functions, this table allows message functions to be added/removed enabled/disabled etc
Comms.MessageHandlers = {
    ["PRIVACY_NOTICE"] = Comms.OnPrivacyNotice,
    ["CHARACTER_ONLINE"] = Comms.OnCharacterOnline,
    ["CHARACTER_TALENTS_UPDATE"] = Comms.OnCharacterTalentsUpdate,
    ["CHARACTER_PROFILE_UPDATE"] = Comms.OnCharacterProfileUpdate,
    ["CHARACTER_PAPERDOLLSTATS_UPDATE"] = Comms.OnCharacterPaperDollStatsUpdate,
    ["CHARACTER_INVENTORY_UPDATE"] = Comms.OnCharacterInventoryUpdate,
    ["CHARACTER_TRADESKILLS_INFO_UPDATE"] = Comms.OnCharacterTradeskillsInfoUpdate,
    ["CHARACTER_TRADESKILLS_RECIPES_UPDATE"] = Comms.OnCharacterTradeskillsRecipesUpdate,
    ["PLAYER_CHARACTER_UPDATE"] = Comms.OnCharacterUpdate,
    ["GUILDBOOK_UPDATE"] = Comms.OnUpdateMessage,
    ["LFG_LISTING_CREATED"] = Comms.OnLFGListingCreated,
    ["NEWS_FEED_UPDATE"] = Comms.OnNewsFeedUpdate,
    ["REQUEST_CHARACTER_INFO"] = Comms.OnCharacterInfoRequested,
}


Guildbook.Comms = Comms;

















































--init, this sets the saved var stuff
--pew, this will trigger a guild roster scan, this creates the db entries for each character and checks them for errors
--load, if the roster scan is successful this will be called and continue loading the addon, this will scan the client character for prof info etc

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init, this will setup the saved variables first
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Init()
    Guildbook.DEBUG('func', 'init', 'running init func')

    -- get this open first if debug is on
    Guildbook.DEBUG('func', 'init', 'checking for debug setting')
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.Debug == true then
        Guildbook.DebuggerWindow:Show()
        Guildbook.DEBUG('func', 'init', 'debug active')
    else
        Guildbook.DebuggerWindow:Hide()
    end
    if GUILDBOOK_GLOBAL then
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL.Debug and GUILDBOOK_GLOBAL.Debug or false)
    end
    

    --register comms
    Guildbook.DEBUG('func', 'init', 'registering comms (old prefix)')
    AceComm:Embed(self)
    self:RegisterComm('Guildbook', 'ON_COMMS_RECEIVED')

    -- this enables us to prevent character model capturing until the player is fully loaded
    Guildbook.LoadTime = GetTime()
        -- grab version number
    self.version = tonumber(GetAddOnMetadata('Guildbook', "Version"))
    Guildbook.DEBUG('func', 'init', string.format("Load time: %s > current version; %s", date("%T"), self.version))

    -- this makes the bank/calendar legacy features work
    Guildbook.DEBUG('func', 'init', 'setting up old guild frames for legacy features')
    if not self.GuildFrame then
        self.GuildFrame = {
            --"GuildBankFrame", -- thsi was converted into the new ui
            "GuildCalendarFrame",
        }
    end
    --self:SetupGuildBankFrame()
    self:SetupGuildCalendarFrame()

    --create stored variable tables
    Guildbook.DEBUG('func', 'init', 'checking for GUILDBOOK_GLOBAL table')
    if GUILDBOOK_GLOBAL == nil or GUILDBOOK_GLOBAL == {} then
        GUILDBOOK_GLOBAL = self.Data.DefaultGlobalSettings
        Guildbook.DEBUG('func', 'init', 'created global saved variable table')
    else
        Guildbook.DEBUG('func', 'init', 'global variables exists')
    end

    Guildbook.DEBUG('func', 'init', 'checking for GUILDBOOK_CHARACTER table')
    if GUILDBOOK_CHARACTER == nil or GUILDBOOK_CHARACTER == {} then
        GUILDBOOK_CHARACTER = self.Data.DefaultCharacterSettings
        Guildbook.DEBUG('func', 'init', 'created character saved variable table')
    else
        Guildbook.DEBUG('func', 'init', 'character variables exists')
    end

    Guildbook.DEBUG('func', 'init', 'checking for guild roster cache parent table')
    if not GUILDBOOK_GLOBAL.GuildRosterCache then
        GUILDBOOK_GLOBAL.GuildRosterCache = {}
        Guildbook.DEBUG('func', 'init', 'created guild roster cache')
    else
        Guildbook.DEBUG('func', 'init', 'guild roster cache exists')
    end

    Guildbook.DEBUG('func', 'init', 'checking calendar table exists')
    if not GUILDBOOK_GLOBAL.Calendar then
        GUILDBOOK_GLOBAL.Calendar = {}
        Guildbook.DEBUG('func', 'init', 'created global calendar table')
    else
        Guildbook.DEBUG('func', 'init', 'global calendar table exists')
    end

    Guildbook.DEBUG('func', 'init', 'checking calendar deleted table exists')
    if not GUILDBOOK_GLOBAL.CalendarDeleted then
        GUILDBOOK_GLOBAL.CalendarDeleted = {}
        Guildbook.DEBUG('func', 'init', 'created global calendar deleted events table')
    else
        Guildbook.DEBUG('func', 'init', 'global calendar deleted events table exists')
    end

    Guildbook.DEBUG('func', 'init', 'checking calendar last transmit table')
    if not GUILDBOOK_GLOBAL.LastCalendarTransmit then
        GUILDBOOK_GLOBAL.LastCalendarTransmit = GetServerTime()
    end
    if not GUILDBOOK_GLOBAL.LastCalendarDeletedTransmit then
        GUILDBOOK_GLOBAL.LastCalendarDeletedTransmit = GetServerTime()
    end

    Guildbook.DEBUG('func', 'init', 'checking my characters table')
    if not GUILDBOOK_GLOBAL.myCharacters then
        GUILDBOOK_GLOBAL.myCharacters = {}
    end
    if not GUILDBOOK_GLOBAL.myCharacters[UnitGUID("player")] then
        GUILDBOOK_GLOBAL.myCharacters[UnitGUID("player")] = false;
    end

    Guildbook.DEBUG('func', 'init', 'checking my lockouts table')
    if not GUILDBOOK_GLOBAL.myLockouts then
        GUILDBOOK_GLOBAL.myLockouts = {}
    end

    Guildbook.DEBUG('func', 'init', 'removing old news feed if exists')
    if GUILDBOOK_GLOBAL.NewsFeed then
        GUILDBOOK_GLOBAL.NewsFeed = nil;
    end

    Guildbook.DEBUG('func', 'init', 'checking activity feed table')
    if not GUILDBOOK_GLOBAL.ActivityFeed then
        GUILDBOOK_GLOBAL.ActivityFeed = {}
    end

    --going to just hard reset this, should only have 50 news entries which is small
    --will abuse the listbox and have this work in reverse so latest is at top
    if not GUILDBOOK_GLOBAL.reversedActivityFeed then
        GUILDBOOK_GLOBAL.ActivityFeed = {}
        GUILDBOOK_GLOBAL.reversedActivityFeed = true;
    end

    Guildbook.DEBUG('func', 'init', 'checking comms delay setting')
    if not GUILDBOOK_GLOBAL['CommsDelay'] then
        GUILDBOOK_GLOBAL['CommsDelay'] = 1.0
    end
    Guildbook.CommsDelaySlider:SetValue(GUILDBOOK_GLOBAL['CommsDelay'])
    self.COMMS_DELAY = GUILDBOOK_GLOBAL['CommsDelay']


    Guildbook.DEBUG('func', 'init', 'checking config settings')
    if not GUILDBOOK_GLOBAL.config then
        local lowestRank = GuildControlGetRankName(GuildControlGetNumRanks())
        GUILDBOOK_GLOBAL.config = {
            privacy = {
                shareInventoryMinRank = lowestRank,
                shareTalentsMinRank = lowestRank,
                shareProfileMinRank = lowestRank,
            },
            modifyDefaultGuildRoster = true,
            showTooltipTradeskills = true,
            showTooltipTradeskillsRecipes = true,
            showTooltipTradeskillsRecipesForCharacter = false,
            showMinimapButton = true,
            showMinimapCalendarButton = true,
            showTooltipCharacterInfo = true,
            showTooltipMainCharacter = true,
            showSpecGuildChat = true,
            showMainCharacterGuildChat = true,
            showTooltipMainSpec = true,
            showTooltipProfessions = true,
            parsePublicNotes = false,
            showInfoMessages = true,
            blockCommsDuringCombat = false,
            blockCommsDuringInstance = false,
        }
        Guildbook.DEBUG('func', 'init', "created default config table")

    end

    if GUILDBOOK_GLOBAL.config.showInfoMessages == nil then
        GUILDBOOK_GLOBAL.config.showInfoMessages = true
        Guildbook.DEBUG('func', 'init', "no info message value, adding as true")
        GuildbookOptionsShowInfoMessages:SetChecked(true)
    end

    if GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == nil then
        GUILDBOOK_GLOBAL.config.blockCommsDuringCombat = true;
        Guildbook.DEBUG('func', 'init', "no blockCommsDuringCombat, adding as true")
        GuildbookOptionsBlockCommsDuringCombat:SetChecked(true)
    end
    if GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == nil then
        GUILDBOOK_GLOBAL.config.blockCommsDuringInstance = true;
        Guildbook.DEBUG('func', 'init', "no blockCommsDuringInstance, adding as true")
        GuildbookOptionsBlockCommsDuringInstance:SetChecked(true)
    end
    GUILDBOOK_GLOBAL.config.addGuildChatSpecAndMainCharacterInfo = nil

    local config = GUILDBOOK_GLOBAL.config
    GuildbookOptionsTooltipTradeskill:SetChecked(config.showTooltipTradeskills and config.showTooltipTradeskills or false)
    GuildbookOptionsTooltipTradeskillRecipes:SetChecked(config.showTooltipTradeskillsRecipes and config.showTooltipTradeskillsRecipes or false)
    GuildbookOptionsTooltipTradeskillRecipesForCharacter:SetChecked(config.showTooltipTradeskillsRecipesForCharacter and config.showTooltipTradeskillsRecipesForCharacter or false)

    GuildbookOptionsShowMinimapButton:SetChecked(config.showMinimapButton)
    GuildbookOptionsShowMinimapCalendarButton:SetChecked(config.showMinimapCalendarButton)

    GuildbookOptionsTooltipInfo:SetChecked(config.showTooltipCharacterInfo)
    GuildbookOptionsTooltipInfoMainSpec:SetChecked(config.showTooltipMainSpec)
    GuildbookOptionsTooltipInfoProfessions:SetChecked(config.showTooltipProfessions)
    GuildbookOptionsTooltipInfoMainCharacter:SetChecked(config.showTooltipMainCharacter)
    GuildbookOptionsShowSpecGuildChat:SetChecked(config.showSpecGuildChat)
    GuildbookOptionsShowMainCharacterGuildChat:SetChecked(config.showMainCharacterGuildChat)

    GuildbookOptionsShowInfoMessages:SetChecked(config.showInfoMessages)

    GuildbookOptionsBlockCommsDuringCombat:SetChecked(config.blockCommsDuringCombat)
    GuildbookOptionsBlockCommsDuringInstance:SetChecked(config.blockCommsDuringInstance)

    if config.showTooltipCharacterInfo == false then
        GuildbookOptionsTooltipInfoMainSpec:Disable()
        GuildbookOptionsTooltipInfoProfessions:Disable()
        GuildbookOptionsTooltipInfoMainCharacter:Disable()
    else
        GuildbookOptionsTooltipInfoMainSpec:Enable()
        GuildbookOptionsTooltipInfoProfessions:Enable()
        GuildbookOptionsTooltipInfoMainCharacter:Enable()
    end

    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        if not GUILDBOOK_GLOBAL then
            return;
        end
        local name, link = GameTooltip:GetItem()
        local character = Guildbook:GetCharacterFromCache(UnitGUID("player"))
        if not character then
            return;
        end
        if link then
            local itemID = GetItemInfoInstant(link)
            if itemID then
                if GUILDBOOK_GLOBAL.config and GUILDBOOK_GLOBAL.config.showTooltipTradeskills and Guildbook.tradeskillRecipes then
                    local headerAdded = false;
                    local profs = {}
                    for k, recipe in ipairs(Guildbook.tradeskillRecipes) do
                        if recipe.reagents then
                            for id, _ in pairs(recipe.reagents) do
                                if id == itemID then
                                    if headerAdded == false then
                                        --self:AddLine(" ")
                                        self:AddLine(TOOLTIP_DIVIDER_WIDE)
                                        self:AddLine(L["TOOLTIP_ITEM_RECIPE_HEADER"])
                                        headerAdded = true;
                                    end
                                    if not profs[recipe.profession] then
                                        profs[recipe.profession] = true
                                        if GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipes then
                                            self:AddLine(" ")
                                        end
                                        self:AddLine(Guildbook.Data.Profession[recipe.profession].FontStringIconMEDIUM.."  "..recipe.profession)
                                    end
                                    if GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipesForCharacter then
                                        if character.Profession1 and (character.Profession1 == recipe.profession) then
                                            self:AddLine(recipe.name, 1,1,1,1)
                                        elseif character.Profession2 and (character.Profession2 == recipe.profession) then
                                            self:AddLine(recipe.name, 1,1,1,1)
                                        end
                                    else
                                        if GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipes then
                                            self:AddLine(recipe.name, 1,1,1,1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if headerAdded == true then
                        self:AddLine(TOOLTIP_DIVIDER_WIDE)
                        --self:AddLine(" ")
                    end
                end
            end
            
            -- this is for my own personal benefit remove for releases
            -- local gold = select(11, GetItemInfo(link))
            -- self:AddLine(GetCoinTextureString(gold))
        end

    end)

    local tooltipIcon = CreateFrame("FRAME", "GuildbookTooltipIcon")
    tooltipIcon:SetSize(1,1)
    tooltipIcon.icon = tooltipIcon:CreateTexture(nil, "BACKGROUND")
    tooltipIcon.icon:SetAllPoints()
    -- hook the tooltip for guild characters
    GameTooltip:HookScript('OnTooltipSetUnit', function(self)
        if InCombatLockdown() then
            return;
        end
        if not GUILDBOOK_GLOBAL then
            return;
        end
        if GUILDBOOK_GLOBAL.config.showTooltipCharacterInfo == false then
            return;
        end
        local _, unit = self:GetUnit()
        local guid = unit and UnitGUID(unit) or nil
        if guid and guid:find('Player') then
            local character = Database:FetchCharacterTableByGUID(guid)
            if not character then
                return;
            end
            self:AddLine(" ")
            --self:AddLine('Guildbook:', 0.00, 0.44, 0.87, 1)
            if GUILDBOOK_GLOBAL.config.showTooltipMainSpec == true then
                if character.Class and character.MainSpec then
                    local displayClass;
						if L[character.Class] then 
							displayClass = Guildbook.CapitalizeString(L[character.Class]);
						else
							displayClass = Guildbook.CapitalizeString(character.Class);
						end
                    local class = Guildbook.Colours[character.Class]:WrapTextInColorCode(displayClass);
                    local spec;
                    if L[character.MainSpec] then
                        spec = Guildbook.Colours[character.Class]:WrapTextInColorCode(L[character.MainSpec]);
                    else
                        spec = Guildbook.Colours[character.Class]:WrapTextInColorCode(character.MainSpec);
                    end
                    local atlas = Guildbook:GetClassSpecAtlasName(character.Class, character.MainSpec)
                    if atlas then
                        if L[character.MainSpec] then
                            if (GetLocale() == "frFR") or (GetLocale() == "esES") or (GetLocale() == "esMX") or (GetLocale() == "ptBR") then
								self:AddLine(string.format("%s %s %s", CreateAtlasMarkup(atlas, 20,20), class, spec))
							else
								self:AddLine(string.format("%s %s %s", CreateAtlasMarkup(atlas, 20,20), spec, class))
							end
                        else
                            self:AddLine(string.format("%s %s %s", CreateAtlasMarkup(atlas, 20,20), spec, class))
                        end
                    else
                        if L[character.MainSpec] then
                            if (GetLocale() == "frFR") or (GetLocale() == "esES") or (GetLocale() == "esMX") or (GetLocale() == "ptBR") then
								self:AddLine(string.format("%s %s", class, spec))
							else
								self:AddLine(string.format("%s %s", spec, class))
							end
                        else
                            self:AddLine(string.format("%s %s", spec, class))
                        end
                    end
                end
            end
            if GUILDBOOK_GLOBAL.config.showTooltipProfessions == true then
                if character.Profession1 ~= '-' and Guildbook.Data.Profession[character.Profession1] then
                    self:AddDoubleLine(Guildbook:GetLocaleProf(character.Profession1), character.Profession1Level, 1,1,1,1,1,1,1,1)
                end
                if character.Profession2 ~= '-' and Guildbook.Data.Profession[character.Profession2] then
                    self:AddDoubleLine(Guildbook:GetLocaleProf(character.Profession2), character.Profession2Level, 1,1,1,1,1,1,1,1)
                end
            end
            --self:AddTexture(Guildbook.Data.Class[character.Class].Icon,{width = 36, height = 36})
            if 1 == 1 then
                if character.profile and character.profile.realBio then
                    --self:AddLine(" ")
                    self:AddLine(Guildbook.Colours.Orange:WrapTextInColorCode(character.profile.realBio), 1,1,1,true)
                end
            end
            if GUILDBOOK_GLOBAL.config.showTooltipMainCharacter == true then
                if character.MainCharacter then
                    local main = Guildbook:GetCharacterFromCache(character.MainCharacter)
                    if main then
                        C_Timer.After(0.5, function()

                            -- check the unit is the same
                            local _, currentUnit = self:GetUnit()
                            if currentUnit and (UnitGUID(currentUnit) == guid) then
                                self:AppendText(" ["..Guildbook.Colours[main.Class]:WrapTextInColorCode(main.Name).."]")
                            end
                        end)
                    end
                end
            end
        end
    end)
end



local guildExistsTicker;
function Guildbook:PLAYER_ENTERING_WORLD(...)

    local isInitialLogin, isReloadUI = ...

    if self.addonLoaded == true then
        local lockouts = Character:GetInstanceInfo()
        GUILDBOOK_GLOBAL.myLockouts[UnitGUID("player")] = lockouts;
        return;
    end

    Guildbook.DEBUG("event", "PLAYER_ENTERING_WORLD", "")
    if not GUILDBOOK_GLOBAL then
        Guildbook.DEBUG("func", "PEW", "GUILDBOOK_GLOBAL is nil or false")
        return;
    end

    GuildRoster() -- this will trigger a roster scan but we set addonLoaded as false at top of file to skip the auto roster scan so this is first scan

    --this is used by the character model mouseover stuff, kinda from the old days but not got round to fixing yet :(
    C_Timer.After(5.0, function()

        local lr, er = UnitRace("player")
        self.player = {
            faction = UnitFactionGroup("player"),
            race = er:upper(),
        }
    end)

    Guildbook.DEBUG("event", "PLAYER_ENTERING_WORLD", "checking guild name exists")


    -- ok i kinda wrote this blind so need to see if it works

    --every 10s see if a guild name exists and if so load and cancel the ticker
    guildExistsTicker = C_Timer.NewTicker(10, function()

        --print("trying to find guild name")
    
        local guildName = self:GetGuildName()
        if type(guildName) == "string" then

            --print(guildName)

            Database:Init()
            Character:Init()
            Comms:Init()
            Roster:Init()
            Tradeskills:Init()
    
            Guildbook:Load()
    
            if type(GUILDBOOK_GLOBAL.ActivityFeed) == "table" and type(GUILDBOOK_GLOBAL.ActivityFeed[guildName]) == "table" then
                GuildbookUI.home.newsFeed.DataProvider:InsertTable(GUILDBOOK_GLOBAL.ActivityFeed[guildName])
            end

            guildExistsTicker:Cancel()
        end
        
    end, 30) --30 iters should cover 5mins which should be enough for players to get an inv to guild for alts etc, no point in havign thsi go off for several hours


    self.EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end



--[[
    working on reducing the chat spam i've noticed during the addon loading

    so far ive adjust the character data by removing profession info
    talents no longer send updates as this broke privacy rules
]]
function Guildbook:Load()
    Guildbook.DEBUG("func", "Load", "loading addon")

    local ldb = LibStub("LibDataBroker-1.1")
    self.MinimapButton = ldb:NewDataObject('GuildbookMinimapIcon', {
        type = "data source",
        icon = 134068,
        OnClick = function(self, button)
            if button == "RightButton" then
                if InterfaceOptionsFrame:IsVisible() then
                    InterfaceOptionsFrame:Hide()
                else
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                end
            elseif button == 'MiddleButton' then
                ToggleFriendsFrame(3)
            elseif button == "LeftButton" then
                if IsShiftKeyDown() then
					if GuildbookUI then
						if GuildbookUI:IsVisible() then
							GuildbookUI:Hide()
						else
							GuildbookUI:OpenTo("chat")
						end
					end
				else
					if GuildbookUI then
						if GuildbookUI:IsVisible() then
							GuildbookUI:Hide()
						else
							GuildbookUI:Show()
						end
					end
				end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(tostring('|cff0070DE'..addonName))
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_LEFTCLICK"])
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_LEFTCLICK_SHIFT"])
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_RIGHTCLICK"])
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_MIDDLECLICK"])
        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    self.MinimapIcon:Register('GuildbookMinimapIcon', self.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])

    self.MinimapCalendarButton = ldb:NewDataObject('GuildbookMinimapCalendarIcon', {
        type = "data source",
        icon = 134939,
        OnClick = function(self, button)
            if button == "RightButton" then
                if self.flyout and self.flyout:IsVisible() then
                    self.flyout:Hide()
                end
                if self.flyout then
                    self.flyout.delayTimer = 2.0;
                    self.flyout:Show()
                    GameTooltip:Hide()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end
            else
                GuildbookUI:OpenTo("calendar")
                Guildbook.GuildFrame.GuildCalendarFrame:ClearAllPoints()
                Guildbook.GuildFrame.GuildCalendarFrame:SetParent(GuildbookUI.calendar)
                Guildbook.GuildFrame.GuildCalendarFrame:SetPoint("TOPLEFT", 0, -26) --this has button above the frame so lower it a bit
                Guildbook.GuildFrame.GuildCalendarFrame:SetPoint("BOTTOMRIGHT", -2, 0)
                Guildbook.GuildFrame.GuildCalendarFrame:Show()
        
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:ClearAllPoints()
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('TOPLEFT', GuildbookUI.calendar, 'TOPRIGHT', 4, 50)
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('BOTTOMRIGHT', GuildbookUI.calendar, 'BOTTOMRIGHT', 274, 0)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            local now = date('*t')
            tooltip:AddLine('Guildbook')
            tooltip:AddLine(string.format("%s %s %s", now.day, Guildbook.Data.Months[now.month], now.year), 1,1,1,1)
            tooltip:AddLine(L["MINIMAP_CALENDAR_RIGHTCLICK"], 0.1, 0.58, 0.92, 1)
            -- get events for next 7 days
            local upcomingEvents = Guildbook:GetCalendarEvents(date('*t'), 7)
            --DevTools_Dump({upcomingEvents})
            if upcomingEvents and next(upcomingEvents) then
                tooltip:AddLine(' ')
                tooltip:AddLine(L['Events'])
                for k, event in ipairs(upcomingEvents) do
                    tooltip:AddDoubleLine(event.title, string.format("%s %s", event.date.day, Guildbook.Data.Months[event.date.month]), 1,1,1,1,1,1,1,1)
                end
            end
        end,
    })
    self.MinimapCalendarIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapCalendarButton'] then GUILDBOOK_GLOBAL['MinimapCalendarButton'] = {} end
    self.MinimapCalendarIcon:Register('GuildbookMinimapCalendarIcon', self.MinimapCalendarButton, GUILDBOOK_GLOBAL['MinimapCalendarButton'])

    local minimapCalendarButton = _G['LibDBIcon10_GuildbookMinimapCalendarIcon']
    for i = 1, minimapCalendarButton:GetNumRegions() do
        local region = select(i, minimapCalendarButton:GetRegions())
        if (region:GetObjectType() == 'Texture') then
            region:Hide()
        end
    end
    -- modify the minimap icon to match the blizz calendar button
    minimapCalendarButton:SetSize(44,44)
    minimapCalendarButton:SetNormalTexture("Interface\\Calendar\\UI-Calendar-Button")
    minimapCalendarButton:GetNormalTexture():SetTexCoord(0.0, 0.390625, 0.0, 0.78125)
    minimapCalendarButton:SetPushedTexture("Interface\\Calendar\\UI-Calendar-Button")
    minimapCalendarButton:GetPushedTexture():SetTexCoord(0.5, 0.890625, 0.0, 0.78125)
    minimapCalendarButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    minimapCalendarButton.DateText = minimapCalendarButton:CreateFontString(nil, 'OVERLAY', 'GameFontBlack')
    minimapCalendarButton.DateText:SetPoint('CENTER', -1, -1)
    minimapCalendarButton.DateText:SetText(date('*t').day)
    -- setup a ticker to update the date, kinda overkill maybe ?
    C_Timer.NewTicker(1, function()
        minimapCalendarButton.DateText:SetText(date('*t').day)
    end)
    -- force the size to be bigger, maybe not worth it but maybe
    -- minimapCalendarButton:SetScript("OnUpdate", function(self)
    --     self:SetSize(44,44)
    -- end)
    minimapCalendarButton.flyout = GuildbookMinimapCalendarDropdown
    minimapCalendarButton.flyout:SetParent(minimapCalendarButton)
    minimapCalendarButton.flyout:ClearAllPoints()
    minimapCalendarButton.flyout:SetPoint("TOPRIGHT", -5, -5)
    minimapCalendarButton.menu = {
        {
            text = L["HOME"],
            func = function()
                GuildbookUI:OpenTo("home")
            end,
        },
        {
            text = L["CHAT"],
            func = function()
                GuildbookUI:OpenTo("chat")
            end,
        },
        {
            text = L["GUILD_VIEWER"],
            func = function()
                GuildbookUI:OpenTo("guildViewer")
            end,
        },
        {
            text = L["TRADESKILLS"],
            func = function() 
                GuildbookUI:OpenTo("tradeskills")
            end,
        },
        {
            text = L["OPEN_PROFILE"],
            func = function()
                GuildbookUI:Show()
                GuildbookUI:OpenTo("profiles")
                GuildbookUI.profiles:LoadCharacter("player")
            end,
        },
        {
            text = L["OPTIONS"],
            func = function()
                InterfaceOptionsFrame_OpenToCategory(addonName)
                InterfaceOptionsFrame_OpenToCategory(addonName)
            end,
        },
    }

    local config = GUILDBOOK_GLOBAL.config
    GuildbookOptionsModifyDefaultGuildRoster:SetChecked(config.modifyDefaultGuildRoster == true and true or false)
    if config.modifyDefaultGuildRoster == true then
        self:ModBlizzUI()
    end
    if config.showMinimapButton == false then
        self.MinimapIcon:Hide('GuildbookMinimapIcon')
        Guildbook.DEBUG('func', "Load", 'minimap icon saved var setting: false, hiding minimap button')
    end
    if config.showMinimapCalendarButton == false then
        self.MinimapCalendarIcon:Hide('GuildbookMinimapCalendarIcon')
        Guildbook.DEBUG('func', "Load", 'minimap calendar icon saved var setting: false, hiding minimap calendar button')
    end

    Guildbook:SendPrivacyInfo(nil, "GUILD")
    Guildbook.DEBUG("func", "Load", "sending privacy settings")

    self.recipeIdsQueried, self.craftIdsQueried = {}, {}
    C_Timer.After(4, function()

        -- check the extra addon SV
        if not GUILDBOOK_TSDB then
            GUILDBOOK_TSDB = {}
        end
        if not GUILDBOOK_TSDB.recipeItems then
            GUILDBOOK_TSDB.recipeItems = {}
            Guildbook.DEBUG('tsdb', 'init', "created guildbook tradeskill database for items recipes")
        end
        if not GUILDBOOK_TSDB.enchantItems then
            GUILDBOOK_TSDB.enchantItems = {}
            Guildbook.DEBUG('tsdb', 'init', "created guildbook tradeskill database for enchanting recipes")
        end
        self:RequestTradeskillData()
        Guildbook.DEBUG("func", "Load", [[requesting tradeskill recipe\item data]])
    end)

    if not GUILDBOOK_GLOBAL.lastVersionUpdate then
        GUILDBOOK_GLOBAL.lastVersionUpdate = {}
    end

    local updates = L["UPDATE_NEWS"]

    if not GUILDBOOK_GLOBAL.lastVersionUpdate[self.version] then
        StaticPopup_Show('GuildbookUpdates', self.version, updates)

        GUILDBOOK_GLOBAL.lastVersionUpdate[self.version] = true;
    end

    GUILDBOOK_GLOBAL.showUpdateNews = nil;

    self.addonLoaded = true
    self.GUILD_NAME = self:GetGuildName()


    --GUILDBOOK_GLOBAL.guildBankRemoved = nil

    -- quick clean up
    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems then
        for _, recipe in pairs(GUILDBOOK_TSDB.enchantItems) do
            recipe.charactersWithRecipe = nil
            if recipe.expsanion then
                local exp = recipe.expsanion;
                recipe.expansion = exp;
                recipe.expsanion = nil;
            end
        end
    end
    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems then
        for _, recipe in pairs(GUILDBOOK_TSDB.recipeItems) do
            recipe.charactersWithRecipe = nil
        end
    end


end






-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---return the localized name of a profession
---@param prof string the profession to localize
---@return any
function Guildbook:GetLocaleProf(prof)
    for id, name in pairs(Guildbook.ProfessionNames["enUS"]) do
        if name == prof then
            if Guildbook.ProfessionNames[GetLocale()][id] then
                return Guildbook.ProfessionNames[GetLocale()][id]
            end
        end
    end
    return prof;
end

---return the atlas name for the specified class and spec, this function will handle any differences between Guildbook and the in game atlas names
---@param class string the characters class, or the class to use for the atlas
---@param spec string the characters spec, or the spec to use for the atlas
---@return string atlas the string for the atlas to use
function Guildbook:GetClassSpecAtlasName(class, spec)
    -- if none then
    --     --Mobile-MechanicIcon-Slowing questlegendaryturnin Icon-Death
    -- end
    local c, s = class, spec
    if class == "SHAMAN" then 
        if spec == "Warden" then
            c = "WARRIOR"
            s = "Protection"
        end
    elseif class == "DEATHKNIGHT" then
        if spec == "Frost (Tank)" then
            s = "Frost"
        end
    else
        if spec == "Bear" then
            s = "Guardian"
        elseif spec == "Cat" then
            s = "Feral"
        elseif spec == "Beast Master" or spec == "BeastMaster" then
            s = "BeastMastery"
        elseif spec == "Combat" then
            s = "Outlaw"
        end
    end
    if c == nil and s == nil then
        return "questlegendaryturnin"
    end

    return string.format("GarrMission_ClassIcon-%s-%s", c, s)
end


function Guildbook.CapitalizeString(s)
    if type(s) == "string" then
        s = s:lower()
        return string.gsub(s, '^%a', string.upper)
    end
end


function Guildbook:MakeFrameMoveable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end


--- return the players guild name if they belong to one
function Guildbook:GetGuildName()
    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        return guildName
    end
end


--- print a message
-- @param msg string the message to print
function Guildbook:PrintMessage(msg)
    if not GUILDBOOK_GLOBAL then
        return;
    end
    if not GUILDBOOK_GLOBAL.config then
        return;
    end
    if GUILDBOOK_GLOBAL.config.showInfoMessages == true and type(self.Colours) == "table" then
        print(string.format("[%s|r] %s", self.Colours.BlizzBlue:WrapTextInColorCode("Guildbook"), msg))
    end
end


local helperIcons = 1
---create and return a yellow 'i' icon with a mouseover tooltip
---@param parent any global frame name or string frame name
---@param relTo any global frame name or string frame name
---@param anchor string anchor point
---@param relPoint string anchor point
---@param x number x offset
---@param y number y offset
---@param tooltiptext string text to display in tooltip
---@return ... frame the icon frame
function Guildbook:CreateHelperIcon(parent, anchor, relTo, relPoint, x, y, tooltiptext)
    local f = CreateFrame('FRAME', tostring('GuildbookHelperIcons'..helperIcons), parent)
    f:SetPoint(anchor, relTo, relPoint, x, y)
    f:SetSize(20, 20)
    f.texture = f:CreateTexture('$parentTexture', 'ARTWORK')
    f.texture:SetAllPoints(f)
    f.texture:SetTexture(374216)
    f:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
        GameTooltip:AddLine(tooltiptext)
        GameTooltip:Show()
    end)
    f:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    helperIcons = helperIcons + 1
    return f
end


---get guild calendar events between given range
---@param start number the number representing the start date/time as returned by time()
---@param duration number the duration of the range, expressed as number of days
---@return table events table of events
function Guildbook:GetCalendarEvents(start, duration)
    if type(self.GUILD_NAME) ~= "string" then
        return
    end
    local events = {}

    local year, month, day = start.year, start.month, start.day;
    local finish = date("*t", time(start) + (60*60*24*duration))

    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['Calendar'] and GUILDBOOK_GLOBAL['Calendar'][self.GUILD_NAME] then
        for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][self.GUILD_NAME]) do

            if ( event.date.year >= start.year and event.date.month >= start.month and event.date.day >= start.day ) and ( event.date.year <= finish.year and event.date.month <= finish.month and event.date.day <= finish.day ) then
                table.insert(events, event)
                Guildbook.DEBUG('func', 'Guildbook:GetCalendarEvents', 'found: '..event.title)
            end
        end
    end
    return events
end


---fetch the character table from the cache/db
---@param guid string the characters guid
---@return table character returns either the character table from the cache or false
function Guildbook:GetCharacterFromCache(guid)
    if type(self.GUILD_NAME) ~= "string" then
        return
    end
    if type(guid) == "string" and guid:find('Player') then
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][self.GUILD_NAME] then
            if GUILDBOOK_GLOBAL['GuildRosterCache'][self.GUILD_NAME][guid] then
                return GUILDBOOK_GLOBAL['GuildRosterCache'][self.GUILD_NAME][guid]
            else
                return false;
            end
        else
            return false;
        end
    else
        return false;
    end
end




---generate a serialize string of guild members recipes using tradeskill and recipeID as keys to reduce size. the serialized table is t[prof][recipeID] = {reagents={}, characters={guid1, guid2}}
---@return string encoded a serialized, compressed and encoded table suitable for displaying
function Guildbook:SerializeGuildTradeskillRecipes()
    local characterTradeskills = {
        ['Alchemy'] = false,
        ['Blacksmithing'] = false,
        ['Enchanting'] = false,
        ['Engineering'] = false,
        ['Inscription'] = false,
        ['Jewelcrafting'] = false,
        ['Leatherworking'] = false,
        ['Tailoring'] = false,
        ['Cooking'] = false,
        ['Mining'] = false,
    }
    local guild = self.GetGuildName()
    if not guild then
        return;
    end
    if not GUILDBOOK_GLOBAL then
        return;
    end
    if not GUILDBOOK_GLOBAL.GuildRosterCache[guild] then
        return;
    end
    local export = { 
        type = "TRADESKILLS",
        recipes = {},
    }
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
        for prof, _ in pairs(characterTradeskills) do
            if character.Profession1 == prof or character.Profession2 == prof then
                if character[prof] and next(character[prof]) ~= nil then
                    if not export.recipes[prof] then
                        export.recipes[prof] = {}
                    end
                    for recipeID, reagents in pairs(character[prof]) do
                        if not export.recipes[prof][recipeID] then
                            export.recipes[prof][recipeID] = {
                                reagents = reagents,
                                characters = {
                                    [guid] = 1,
                                }
                            }
                        else
                            if not export.recipes[prof][recipeID].characters[guid] then
                                export.recipes[prof][recipeID].characters[guid] = 1;
                            end
                        end
                    end
                end
            end
        end
    end
    characterTradeskills = nil;
    if export then
        local serialized = LibSerialize:Serialize(export);
        local compressed = LibDeflate:CompressDeflate(serialized);
        local encoded    = LibDeflate:EncodeForPrint(compressed);
        return encoded;
    end
end


function Guildbook:ImportGuildTradeskillRecipes(text)
    local decoded = LibDeflate:DecodeForPrint(text);
    if not decoded then
        return;
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then
        return;
    end
    local success, data = LibSerialize:Deserialize(decompressed);
    if not success or type(data) ~= "table" then
        return;
    end
    if data.type ~= "TRADESKILLS" then
        return;
    end
    for prof, recipes in pairs(data.recipes) do
        for recipeID, recipeInfo in pairs(recipes) do
            --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("importing %s data", prof), data.recipes[prof])
            for guid, _ in pairs(recipeInfo.characters) do
                local character = self:GetCharacterFromCache(guid)
                if character then
                    -- first set the character prof key values if missing
                    if character.Profession1 == "-" then
                        character.Profession1 = prof;
                        --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("added %s as prof1 for %s", prof, character.Name))
                    else
                        if character.Profession2 == "-" and character.Profession1 ~= prof then
                            character.Profession2 = prof;
                            --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("added %s as prof2 for %s", prof, character.Name))
                        end
                    end
                    -- create the prof table
                    if not character[prof] then
                        character[prof] = {}
                        --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("created %s table for %s", prof, character.Name))
                    end
                    -- add the recipes
                    character[prof][recipeID] = recipeInfo.reagents
                    --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("added %s to %s for %s", recipeID, prof, character.Name))
                end
            end
        end
    end
end







-- THIS FUNCTION WILL GO AWAY WHEN GUILD BANKS GET ADDED
--- scans the players bags and bank for guild bank sharing
--- creates a table in the character saved vars with scan time so we can check which data is newest
function Guildbook:ScanPlayerContainers()
    --if BankFrame:IsVisible() then
        local guid = UnitGUID("player")

        local copper = GetMoney()

        if not GUILDBOOK_GLOBAL["GuildBank"] then
            GUILDBOOK_GLOBAL["GuildBank"] = {}
        end
        GUILDBOOK_GLOBAL["GuildBank"][guid] = {
            Commit = GetServerTime(),
            Data = {},
            Money = copper,
        }

        -- player bags
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
                if id and count then
                    local _, _, _, _, _, classID, subClassID = GetItemInfoInstant(link)
                    ---if we get a weapon or armour item then use the link so we know suffixes/enchants etc
                    if classID == 2 or classID == 4 then
                        if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] then
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] = count
                        else
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] + count
                        end
                    else
                        if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] then
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = count
                        else
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] + count
                        end
                    end

                end
            end
        end

        -- main bank
        for slot = 1, 28 do
            local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(-1, slot)
            if id and count then
                local _, _, _, _, _, classID, subClassID = GetItemInfoInstant(link)
                ---if we get a weapon or armour item then use the link so we know suffixes/enchants etc
                if classID == 2 or classID == 4 then
                    if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] then
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] = count
                    else
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] + count
                    end
                else
                    if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] then
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = count
                    else
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] + count
                    end
                end

            end
        end

        -- bank bags
        for bag = 5, 11 do
            for slot = 1, GetContainerNumSlots(bag) do
                local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
                if id and count then
                    local _, _, _, _, _, classID, subClassID = GetItemInfoInstant(link)
                    ---if we get a weapon or armour item then use the link so we know suffixes/enchants etc
                    if classID == 2 or classID == 4 then
                        if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] then
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] = count
                        else
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[link] + count
                        end
                    else
                        if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] then
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = count
                        else
                            GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] + count
                        end
                    end
    
                end
            end
        end

        local bankUpdate = {
            type = 'GUILD_BANK_DATA_RESPONSE',
            payload = {
                Data = GUILDBOOK_GLOBAL["GuildBank"][guid].Data,
                Commit = GUILDBOOK_GLOBAL["GuildBank"][guid].Commit,
                Money = GUILDBOOK_GLOBAL["GuildBank"][guid].Money,
                Bank = guid,
            }
        }
        self:Transmit(bankUpdate, 'GUILD', nil, 'BULK')
        --DEBUG('comms_out', 'ScanPlayerContainers', 'sending guild bank data due to new commit')

    --end
end







---this is used by the tradeskill recipe listview to set the reagent icon border colour
function Guildbook:ScanPlayerBags()
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
            if itemID and itemCount then
                if not GuildbookUI.playerContainerItems[itemID] then
                    GuildbookUI.playerContainerItems[itemID] = itemCount
                else
                    GuildbookUI.playerContainerItems[itemID] = GuildbookUI.playerContainerItems[itemID] + itemCount
                end
            end
        end
    end
end

---this is used by the tradeskill recipe listview to set the reagent icon border colour
function Guildbook:ScanPlayerBank()
    -- main bank
    for slot = 1, GetContainerNumSlots(-1) do
        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(-1, slot)
        if itemID and itemCount then
            if not GuildbookUI.playerContainerItems[itemID] then
                GuildbookUI.playerContainerItems[itemID] = itemCount
            else
                GuildbookUI.playerContainerItems[itemID] = GuildbookUI.playerContainerItems[itemID] + itemCount
            end
        end
    end
    -- bank bags
    for bag = 5, 11 do
        for slot = 1, GetContainerNumSlots(bag) do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
            if itemID and itemCount then
                if not GuildbookUI.playerContainerItems[itemID] then
                    GuildbookUI.playerContainerItems[itemID] = itemCount
                else
                    GuildbookUI.playerContainerItems[itemID] = GuildbookUI.playerContainerItems[itemID] + itemCount
                end
            end
        end
    end
end


---scan all guild members profesion recipeIDs and if no data make a request with a staggered loop
function Guildbook:RequestTradeskillData()
    if self.addonLoaded == false then
        return;
    end

    -- for debugging speed things up
    local delay = GUILDBOOK_GLOBAL['Debug'] and 0.05 or 0.1

    -- a sequential table of IDs to process { recipeID = number, prof = string, reagents = table or false}
    local recipeIdsToQuery = {}

    -- a lookup table holding character guids for each recipeID { [recipeID] = { guid1, guid2, guid3, ...} }
    self.charactersWithRecipe = {}

    -- a lookup table holding character guids for each enchanting recipeID { [recipeID] = { guid1, guid2, guid3, ...} } enchants are spells not items
    self.charactersWithEnchantRecipe = {}
    
    -- a sequential table for all tradeskill items, this doesnt need to wiped each time i dont think anyways - this must never be sorted as the keys are mapped
    if not self.tradeskillRecipes then
        self.tradeskillRecipes = {}
    end

    -- a lookup table to use for finding a tradeskill from the main table { [recipeID] = key }
    self.tradeskillRecipesKeys = {}

    -- a lookup table to use for finding an enchant from the main table { [recipeID] = key }
    self.tradeskillEnchantRecipesKeys = {}

    -- if we have no guild then exit
    if type(self.GUILD_NAME) ~= "string" then
        return;
    end

    -- if we have no saved var then exit
    if not GUILDBOOK_GLOBAL then
        return;
    end

    -- if we have no saved var then exit
    if not GUILDBOOK_GLOBAL.GuildRosterCache[self.GUILD_NAME] then
        return;
    end
    Guildbook.DEBUG("func", "RequestTradeskillData", "begin looping character cache")

    -- loop all the recipes we have from all members
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[self.GUILD_NAME]) do
        if character.Profession1 and character.Profession1 ~= "-" then
            local prof = character.Profession1
            if character[prof] and next(character[prof]) ~= nil then
                for recipeID, reagents in pairs(character[prof]) do
                    if prof == "Enchanting" then
                        if not self.charactersWithEnchantRecipe[recipeID] then
                            self.charactersWithEnchantRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithEnchantRecipe[recipeID], guid)
                        if not self.craftIdsQueried[recipeID] then
                            
                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems and GUILDBOOK_TSDB.enchantItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.enchantItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = "Enchanting", 
                                    reagents = reagents or false,
                                })
                            end
                            self.craftIdsQueried[recipeID] = true;
                        end
                    else
                        if not self.charactersWithRecipe[recipeID] then
                            self.charactersWithRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithRecipe[recipeID], guid)
                        if not self.recipeIdsQueried[recipeID] then

                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems and GUILDBOOK_TSDB.recipeItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.recipeItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = prof, 
                                    reagents = reagents or false,
                                })
                            end
                            self.recipeIdsQueried[recipeID] = true;
                        end
                    end
                end
            end
        end
        if character.Profession2 and character.Profession2 ~= "-" then
            local prof = character.Profession2
            if character[prof] and next(character[prof]) ~= nil then
                for recipeID, reagents in pairs(character[prof]) do
                    if prof == "Enchanting" then
                        if not self.charactersWithEnchantRecipe[recipeID] then
                            self.charactersWithEnchantRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithEnchantRecipe[recipeID], guid)
                        if not self.craftIdsQueried[recipeID] then
                            
                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems and GUILDBOOK_TSDB.enchantItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.enchantItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = "Enchanting", 
                                    reagents = reagents or false,
                                })
                            end
                            self.craftIdsQueried[recipeID] = true;
                        end
                    else
                        if not self.charactersWithRecipe[recipeID] then
                            self.charactersWithRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithRecipe[recipeID], guid)
                        if not self.recipeIdsQueried[recipeID] then

                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems and GUILDBOOK_TSDB.recipeItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.recipeItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = prof, 
                                    reagents = reagents or false,
                                })
                            end
                            self.recipeIdsQueried[recipeID] = true;
                        end
                    end
                end
            end
        end
        if character.Cooking and type(character.Cooking) == "table" then
            for recipeID, reagents in pairs(character.Cooking) do
                if not self.charactersWithRecipe[recipeID] then
                    self.charactersWithRecipe[recipeID] = {}
                end
                table.insert(self.charactersWithRecipe[recipeID], guid)
                if not self.recipeIdsQueried[recipeID] then

                    -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems and GUILDBOOK_TSDB.recipeItems[recipeID] then
                        table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.recipeItems[recipeID])
                    else
                        table.insert(recipeIdsToQuery, {
                            recipeID = recipeID,
                            prof = "Cooking", 
                            reagents = reagents or false,
                        })
                    end
                    self.recipeIdsQueried[recipeID] = true;
                end
            end
        end
        if character["First Aid"] and type(character["First Aid"]) == "table" then
            for recipeID, reagents in pairs(character["First Aid"]) do
                if not self.charactersWithRecipe[recipeID] then
                    self.charactersWithRecipe[recipeID] = {}
                end
                table.insert(self.charactersWithRecipe[recipeID], guid)
                if not self.recipeIdsQueried[recipeID] then

                    -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems and GUILDBOOK_TSDB.recipeItems[recipeID] then
                        table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.recipeItems[recipeID])
                    else
                        table.insert(recipeIdsToQuery, {
                            recipeID = recipeID,
                            prof = "First Aid", 
                            reagents = reagents or false,
                        })
                    end
                    self.recipeIdsQueried[recipeID] = true;
                end
            end
        end
    end
    
    local statusBar = GuildbookUI.tradeskills.statusBar
    statusBar:SetValue(0)
    statusBar:Show()
    local statusBarText = GuildbookUI.tradeskills.statusBarText
    statusBarText:SetText("Loading...")
    statusBarText:Show()

    if #recipeIdsToQuery > 0 then
        local startTime = time();
        --self:PrintMessage(string.format("found %s recipes, estimated duration %s", #recipeIdsToQuery, SecondsToTime(#recipeIdsToQuery*delay)))
        table.sort(recipeIdsToQuery, function(a,b)
            if a.prof == b.prof then
                return a.recipeID > b.recipeID -- sort highest id first, should help display newest expansion items sooner
            else
                return a.prof < b.prof
            end
        end)
        local i = 1;
        Guildbook.DEBUG('func', 'tradeskill data requst', string.format("found %s recipes, estimated duration %s", #recipeIdsToQuery, SecondsToTime(#recipeIdsToQuery*delay)))

        C_Timer.NewTicker(delay, function()
            if not recipeIdsToQuery[i] then
                return
            end

            local recipeID = recipeIdsToQuery[i].recipeID

            local prof = recipeIdsToQuery[i].prof
            local reagents = recipeIdsToQuery[i].reagents

            local link, rarity, name, expansion, icon = false, false, false, 0, false

            local _, spellID = LCI:GetItemSource(recipeID)

            local _, _, _, equipLoc, _, itemClassID, itemSubClassID = GetItemInfoInstant(recipeID)
            if not equipLoc then
                equipLoc = "INVTYPE_NON_EQUIP"
            end
            if prof == "Enchanting" then
                equipLoc = "INVTYPE_NON_EQUIP";
            end

            if spellID then
                expansion = LCI:GetCraftXPack(spellID)
            end
            if prof == 'Enchanting' then
                link = GetSpellLink(recipeID)
                rarity = 1
                name = GetSpellInfo(recipeID)
                if not name then
                    name = "unknown"
                end
            else
                name, link, rarity, _, _, _, _, _, _, icon = GetItemInfo(recipeID)
            end
            if not link and not name and not rarity and not icon then
                if prof == 'Enchanting' then                    
                    local spell = Spell:CreateFromSpellID(recipeID)
                    spell:ContinueOnSpellLoad(function()
                        link = GetSpellLink(recipeID)
                        name, _, icon = GetSpellInfo(recipeID)
                        if not name then
                            name = "unknown"
                        end
                        if not icon then
                            icon = 136244
                        end
                        local recipe = {
                            itemID = recipeID,
                            reagents = reagents,
                            rarity = 1,
                            link = link,
                            icon = icon,
                            expansion = expansion,
                            enchant = true,
                            name = name,
                            profession = prof,
                            equipLocation = equipLoc,
                            class = -1,
                            subClass = -1,
                            --charactersWithRecipe = self.charactersWithEnchantRecipe[recipeID],
                        }
                        table.insert(self.tradeskillRecipes, recipe)
                        if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems then
                            GUILDBOOK_TSDB.enchantItems[recipeID] = recipe;
                        end
                    end)
                else
                    local item = Item:CreateFromItemID(recipeID)
                    item:ContinueOnItemLoad(function()
                        link = item:GetItemLink()
                        rarity = item:GetItemQuality()
                        name = item:GetItemName()
                        icon = item:GetItemIcon()
                        local recipe = {
                            itemID = recipeID,
                            reagents = reagents,
                            rarity = rarity,
                            link = link,
                            icon = icon,
                            expansion = expansion,
                            enchant = false,
                            name = name,
                            profession = prof,
                            equipLocation = equipLoc,
                            class = itemClassID,
                            subClass = itemSubClassID,
                            --charactersWithRecipe = self.charactersWithRecipe[recipeID],
                        }
                        table.insert(self.tradeskillRecipes, recipe)
                        if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems then
                            GUILDBOOK_TSDB.recipeItems[recipeID] = recipe;
                        end
                    end)
                end
            else
                if prof == "Enchanting" then
                    local recipe = {
                        itemID = recipeID,
                        reagents = reagents,
                        rarity = 1,
                        link = link,
                        icon = icon,
                        expansion = expansion,
                        enchant = true,
                        name = name,
                        profession = prof,
                        equipLocation = equipLoc,
                        class = -1,
                        subClass = -1,
                        --charactersWithRecipe = self.charactersWithEnchantRecipe[recipeID],
                    }
                    table.insert(self.tradeskillRecipes, recipe)
                    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems then
                        GUILDBOOK_TSDB.enchantItems[recipeID] = recipe;
                    end
                else
                    local recipe = {
                        itemID = recipeID,
                        reagents = reagents,
                        rarity = rarity,
                        link = link,
                        icon = icon,
                        expansion = expansion,
                        enchant = false,
                        name = name,
                        profession = prof,
                        equipLocation = equipLoc,
                        class = itemClassID,
                        subClass = itemSubClassID,
                        --charactersWithRecipe = self.charactersWithRecipe[recipeID],
                    }
                    table.insert(self.tradeskillRecipes, recipe)
                    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems then
                        GUILDBOOK_TSDB.recipeItems[recipeID] = recipe;
                    end
                end
            end

            statusBar:SetValue(i / #recipeIdsToQuery)
            statusBarText:SetText(string.format(L["PROCESSED_RECIPES_SS"], i, #recipeIdsToQuery))

            i = i + 1;
            if i > #recipeIdsToQuery then

                --- create or update the recipeID key mapping
                for k, v in ipairs(self.tradeskillRecipes) do
                    if v.enchant then
                        self.tradeskillEnchantRecipesKeys[v.itemID] = k
                    else
                        self.tradeskillRecipesKeys[v.itemID] = k
                    end
                    statusBar:SetValue(k / #self.tradeskillRecipes)
                    statusBarText:SetText(string.format("mapping keys %s of %s", k, #self.tradeskillRecipes))
                end

                statusBar:Hide()
                statusBarText:SetText("")
                statusBarText:Hide()

                --self:PrintMessage(string.format("all tradeskill recipes processed, took %s", SecondsToTime(time()-startTime)))
                Guildbook.DEBUG('func', 'tradeskill data requst', string.format("all tradeskill recipes processed, took %s", SecondsToTime(time()-startTime)))

                return;
            end

        end, #recipeIdsToQuery)


    -- if we have no recipes to request then update the key mapping
    else
        --- create or update the recipeID key mapping
        for k, v in ipairs(self.tradeskillRecipes) do
            if v.enchant then
                self.tradeskillEnchantRecipesKeys[v.itemID] = k
            else
                self.tradeskillRecipesKeys[v.itemID] = k
            end
            statusBar:SetValue(k / #self.tradeskillRecipes)
            statusBarText:SetText(string.format("mapping keys %s of %s", k, #self.tradeskillRecipes))
        end
        statusBar:Hide()
        statusBar:SetValue(0)
        statusBarText:SetText("")
        statusBarText:Hide()
        Guildbook.DEBUG('func', 'tradeskill data requst', "no new recipes to query")
    end
end








--- scan the characters current guild cache
-- this will check name and class against the return values from PlayerMixin using guid, sometimes players create multipole characters before settling on a class
-- we also check the player entries for profression errors, talents table and spec data
-- any entries not found the current guild roster will be removed (=nil)
function Guildbook:ScanGuildRoster(callback)
    local guild = self:GetGuildName()
    if not guild then
        Guildbook.DEBUG("func", "ScanGuildRoster", "no guild")
        return 
    end
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache then
        if not GUILDBOOK_GLOBAL.GuildRosterCache[guild] then
            GUILDBOOK_GLOBAL.GuildRosterCache[guild] = {}
            Guildbook.DEBUG("func", "ScanGuildRoster", "created roster cache for "..guild)
        end
        if self.scanRosterTicker then
            self.scanRosterTicker:Cancel()
        end
        local memberGUIDs = {}
        local currentGUIDs = {}
        if not self.onlineZoneInfo then
            self.onlineZoneInfo = {}
        end
        local faction = self.player.faction
        if not faction then
            return;
        end
        local newGUIDs = {}
        local totalMembers, onlineMember, _ = GetNumGuildMembers()
        GUILDBOOK_GLOBAL['RosterExcel'] = {}
        for i = 1, totalMembers do
            --local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            local name, rankName, _, level, class, zone, publicNote, officerNote, isOnline, _, _, achievementPoints, _, _, _, _, guid = GetGuildRosterInfo(i)
            name = Ambiguate(name, 'none')
            if not GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] then
                GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] = {
                    Name = name,
                    Class = class,
                    Level = level,
                    PublicNote = publicNote,
                    officerNote = officerNote,
                    RankName = rankName,
                    Talents = {
                        primary = {},
                        secondary = {},
                    },
                    Alts = {},
                    MainCharacter = "-",
                    Profession1 = "-",
                    Profession1Level = 0,
                    Profession2 = "-",
                    Profession2Level = 0,
                    MainSpec = "-",
                    MainSpecIsPvP = false,
                    OffSpec = "-",
                    OffSpecIsPvP = false,
                };
                table.insert(newGUIDs, guid)
            end
            currentGUIDs[i] = { name = name, GUID = guid, lvl = level, exists = true, online = isOnline, rank = rankName, pubNote = publicNote, offNote = officerNote}
            memberGUIDs[guid] = true;
            self.onlineZoneInfo[guid] = {
                online = isOnline,
                zone = zone,
            }
            --name = Ambiguate(name, 'none')
            --table.insert(GUILDBOOK_GLOBAL['RosterExcel'], string.format("%s,%s,%s,%s,%s", name, class, rankName, level, publicNote))
        end
        local i = 1;
        local start = date('*t')
        local started = time()
        GuildbookUI:SetInfoText(string.format("starting roster scan at %s:%s:%s", start.hour, start.min, start.sec))
        self.scanRosterTicker = C_Timer.NewTicker(0.001, function()
            local percent = (i/totalMembers) * 100
            GuildbookUI:SetInfoText(string.format("roster scan %s%%",string.format("%.1f", percent)))
            GuildbookUI.statusBar:SetValue(i/totalMembers)
            if not currentGUIDs[i] then
                --print("no guid")
                return;
            end
            local guid = currentGUIDs[i].GUID
            local info = GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid]

            if info then
                local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid)

                    if name and class and race and sex and realm then

                        sex = (sex == 3) and "FEMALE" or "MALE"
                        
                        info.Faction = faction;
                        info.Race = race;
                        info.Gender = sex;
                        info.Class = class;
                        info.Name = Ambiguate(name, 'none');

                        --for connected realms we need the full name
                        if realm == "" then
                            realm = GetNormalizedRealmName()
                        end
                        --info.Realm = realm;
                        
                        info.PublicNote = currentGUIDs[i].pubNote;
                        info.OfficerNote = currentGUIDs[i].offNote;
                        info.RankName = currentGUIDs[i].rank;
                        info.Level = currentGUIDs[i].lvl;

                        if not info.MainSpec then
                            info.MainSpec = "-"
                        end
                        if info.MainSpec == nil then
                            info.MainSpec = "-"
                        end

                        if info.MainCharacter then
                            info.Alts = {}
                            for _guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
                                if info.MainCharacter ~= "-" and character.MainCharacter == info.MainCharacter then
                                    table.insert(info.Alts, _guid)
                                end
                            end
                        end
                    end
                --end
            end
            i = i + 1;
            if i > totalMembers then
                local finished = time() - started
                GuildbookUI.statusBar:SetValue(0)
                local removedCount = 0;
                for guid, _ in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
                    if not memberGUIDs[guid] then
                        GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] = nil;
                        removedCount = removedCount + 1;
                    end
                end
                if #newGUIDs > 0 then

                end
                if removedCount > 0 then
                    
                end
                GuildbookUI:SetInfoText(string.format("finished roster scan, took %s, %s new characters, removed %s characters from db", SecondsToTime(finished), (#newGUIDs or 0), removedCount))
                C_Timer.After(0.05, function()
                    if GuildbookUI then
                        --GuildbookUI.roster:ParseGuildRoster()
                    end
                end)

                --this is to continue loading the addon it only happens during the loading sequence
                if callback then
                    callback()
                end
            end
        end, totalMembers)

    end
end



-- https://wow.gamepedia.com/API_GetActiveTalentGroup -- dual spec api for wrath












-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
    this function remains to provide some backwards compatibilty while players get themselves updated etc

    the calendar and guild bank will need to be updated to work with the new comms class as well so this wont be removed until then
]]

---send an addon message through the aceComm lib
---@param data table the data to send including a comm type
---@param channel string the addon channel to use for the comm
---@param targetGUID string the targets GUID, this is used to make comms work on conneted realms - only required for WHISPER comms
---@param priority string the prio to use
function Guildbook:Transmit(data, channel, targetGUID, priority)


    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI:SetInfoText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI:SetInfoText("blocked data comms while in combat")
            return;
        end
    end
    if not self:GetGuildName() then
        return;
    end

    -- add the version and sender guid to the message
    data["version"] = tostring(self.version);
    data["senderGUID"] = UnitGUID("player")

    -- clean up the target name when using a whisper
    if channel == "GUILD" then
        local serialized = LibSerialize:Serialize(data);
        local compressed = LibDeflate:CompressDeflate(serialized);
        local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    
        if addonName and encoded and channel and priority then
            Guildbook.DEBUG('comms_out', 'SendCommMessage_NoTarget', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, 'nil', priority))
            self:SendCommMessage(addonName, encoded, channel, nil, priority)
        end
    end


    -- local ok, serialized = pcall(LibSerialize.Serialize, LibSerialize, data)
    -- if not ok then
    --     LoadAddOn("Blizzard_DebugTools")
    --     DevTools_Dump(data)
    --     return
    -- end

    -- local serialized = LibSerialize:Serialize(data);
    -- local compressed = LibDeflate:CompressDeflate(serialized);
    -- local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);

    -- if addonName and encoded and channel and priority then
    --     Guildbook.DEBUG('comms_out', 'SendCommMessage', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
    --     self:SendCommMessage(addonName, encoded, channel, target, priority)
    -- end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- privacy comms

--[[
    this section should be moved in the Character class ?

    its still required as a player may change their privacy at any point during game play and we then need to make sure any of their data is removed from other players
]]
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lastPrivacyTransmit = -1000
local privacyTransmitQueued = false

---comment
---@param target string targets guid
---@param channel any
function Guildbook:SendPrivacyInfo(target, channel)
    if not GUILDBOOK_GLOBAL.config and not GUILDBOOK_GLOBAL.config.privacy then
        return;
    end
    local privacy = {
        type = "PRIVACY_INFO",
        payload = {
            privacy = GUILDBOOK_GLOBAL.config.privacy,
        },
    }
    --this was spamming for some reason so added a 15s delay, might be awkward but better than spamming chat channels
    if (lastPrivacyTransmit + 15) < GetTime() then
        self:Transmit(privacy, channel, target, "NORMAL")
        lastPrivacyTransmit = GetTime()
    else
        if privacyTransmitQueued == false then
            C_Timer.After(15, function()
                self:Transmit(privacy, channel, target, "NORMAL")
                privacyTransmitQueued = false
            end)
            privacyTransmitQueued = true;
        end
    end
end

function Guildbook:OnPrivacyReceived(data, distribution, sender)
    if not data.payload.privacy then
        return
    end
    if data.senderGUID and data.senderGUID ~= UnitGUID("player") then
        local character = self:GetCharacterFromCache(data.senderGUID)
        if not character then
            return;
        end
        local ranks = {}
        for i = 1, GuildControlGetNumRanks() do
            ranks[GuildControlGetRankName(i)] = i;
        end
        local myRank = GuildControlGetRankName(C_GuildInfo.GetGuildRankOrder(UnitGUID("player")))
        if not ranks[myRank] then
            return
        end
        if data.payload.privacy.shareProfileMinRank and ranks[data.payload.privacy.shareProfileMinRank] and type(ranks[data.payload.privacy.shareProfileMinRank]) == "number" then
            if ranks[myRank] > ranks[data.payload.privacy.shareProfileMinRank] then
                character.profile = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s profile data", character.Name))
            end
        else
            if data.payload.privacy.shareProfileMinRank and data.payload.privacy.shareProfileMinRank == "none" then
                character.profile = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s profile data", character.Name))
            end
        end
        if data.payload.privacy.shareInventoryMinRank and ranks[data.payload.privacy.shareInventoryMinRank] and type(ranks[data.payload.privacy.shareInventoryMinRank]) == "number" then
            if ranks[myRank] > ranks[data.payload.privacy.shareInventoryMinRank] then
                character.Inventory = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s inventory data", character.Name))
            end
        else
            if data.payload.privacy.shareInventoryMinRank and data.payload.privacy.shareInventoryMinRank == "none" then
                character.Inventory = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s inventory data", character.Name))
            end
        end
        if data.payload.privacy.shareTalentsMinRank and ranks[data.payload.privacy.shareTalentsMinRank] and type(ranks[data.payload.privacy.shareTalentsMinRank]) == "number" then
            if ranks[myRank] > ranks[data.payload.privacy.shareTalentsMinRank] then
                character.Talents = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s talents data", character.Name))
            end
        else
            if data.payload.privacy.shareTalentsMinRank and data.payload.privacy.shareTalentsMinRank == "none" then
                character.Talents = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s talents data", character.Name))
            end
        end
    end
end


function Guildbook:OnPrivacyError(code, sender)
    if code == 0 then
        Guildbook.DEBUG("error", "PrivacyError", string.format("%s not sharing inventory", sender))
    elseif code == 1 then
        Guildbook.DEBUG("error", "PrivacyError", string.format("%s not sharing talents", sender))
    elseif code == 2 then
        Guildbook.DEBUG("error", "PrivacyError", string.format("%s not sharing profile", sender))
    end
end












































------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.BankCharacters = {}
Guildbook.BankRequests = {}
-- update for new guild bank ui
-- send request for each character > add character to table as normal

function Guildbook:RequestGuildBankCommits(charactersGUID)
    self.BankCharacters[charactersGUID] = {}
    local character = self:GetCharacterFromCache(charactersGUID)
    if character then
        local request = {
            type = 'GUILD_BANK_COMMIT_REQUEST',
            bankCharactersGUID = charactersGUID,
            bankCharactersName = character.Name,
        }
        Guildbook.DEBUG("guildBankMixin", "RequestGuildBankCommits", string.format("request guild bank commits for %s", character.Name))
        self:Transmit(request, 'GUILD', nil, 'NORMAL')
    end
end


-- this will still work as its just checking the saved var data for a bank character commit
function Guildbook:OnGuildBankCommitRequested(data, distribution, sender)
    if distribution == 'GUILD' then
        if GUILDBOOK_GLOBAL["GuildBank"] and GUILDBOOK_GLOBAL["GuildBank"][data.bankCharactersGUID] and GUILDBOOK_GLOBAL["GuildBank"][data.bankCharactersGUID].Commit then
            local response = {
                type = 'GUILD_BANK_COMMIT_RESPONSE',
                payload = { 
                    Commit = GUILDBOOK_GLOBAL["GuildBank"][data.bankCharactersGUID].Commit,
                    CharacterGUID = data.bankCharactersGUID
                }
            }
            Guildbook.DEBUG('guildBankMixin', 'OnGuildBankCommitRequested', string.format("%s has requested guild bank commits for %s", sender, data.bankCharactersName))
            self:Transmit(response, 'WHISPER', data.senderGUID, 'NORMAL')
        end
    end
end

-- use the new table
local lastCommitResponse = -1000;
function Guildbook:OnGuildBankCommitReceived(data, distribution, sender)
    if distribution == 'WHISPER' then
        lastCommitResponse = GetTime()
        Guildbook.DEBUG("guildBankMixin", "OnGuildBankCommitReceived", string.format("sender: %s commit time: %s", sender, data.payload.Commit))

        --data.payload.CharacterGUID is the actual bank character
        --data.senderGUID is the player with the latest commit for the bank character

        ---if we have no data for this characterGUID then just save the commit
        if not self.BankCharacters[data.payload.CharacterGUID].Commit then
            self.BankCharacters[data.payload.CharacterGUID].Commit = data.payload.Commit;
            self.BankCharacters[data.payload.CharacterGUID].Source = data.senderGUID;
            Guildbook.DEBUG("guildBankMixin", "OnGuildBankCommitReceived", string.format("%s has latest commit time", sender))

        ---if we do have data we want to check if this commit is newer and if so then save it
        else
            if tonumber(data.payload.Commit) > tonumber(self.BankCharacters[data.payload.CharacterGUID].Commit) then
                self.BankCharacters[data.payload.CharacterGUID].Commit = data.payload.Commit;
                self.BankCharacters[data.payload.CharacterGUID].Source = data.senderGUID;
                Guildbook.DEBUG("guildBankMixin", "OnGuildBankCommitReceived", string.format("%s has latest commit time", sender))
            end
        end
    end
end


-- this will be used in loop, for bank, info in pairs(Guildbook.BankCharacters) do. info = { Commit = commit time, Source = player with newest data }
function Guildbook:RequestGuildBankItems(source, bank)
    if not source then
        return;
    end
    local request = {
        type = 'GUILD_BANK_DATA_REQUEST',
        payload = bank,
    }
    Guildbook.DEBUG('guildBankMixin', 'RequestGuildBankItems', string.format("requesting guild bank items from %s", source))
    self:Transmit(request, 'WHISPER', source, 'NORMAL')
end



-- this should remain the same as its ust returning data using a character name as key
function Guildbook:OnGuildBankDataRequested(data, distribution, sender)
    if distribution == 'WHISPER' then
        local response = {
            type = 'GUILD_BANK_DATA_RESPONSE',
            payload = {
                Data = GUILDBOOK_GLOBAL["GuildBank"][data.payload].Data,
                Commit = GUILDBOOK_GLOBAL["GuildBank"][data.payload].Commit,
                Money = GUILDBOOK_GLOBAL["GuildBank"][data.payload].Money,
                Bank = data.payload,
            }
        }
        self:Transmit(response, 'WHISPER', data.senderGUID, 'BULK')
        Guildbook.DEBUG('guildBankMixin', 'OnGuildBankDataRequested', string.format('%s has requested bank data, sending data for bank character %s', sender, data.payload))
    end
end

-- this should also remain the same as we just save the data
function Guildbook:OnGuildBankDataReceived(data, distribution, sender)
    if distribution == 'WHISPER' or distribution == 'GUILD' then
        if not GUILDBOOK_GLOBAL["GuildBank"] then
            GUILDBOOK_GLOBAL["GuildBank"] = {
                [data.payload.Bank] = {
                    Commit = data.payload.Commit,
                    Data = data.payload.Data,
                    Money = data.payload.Money,
                }
            }
        else
            if data.payload.Bank == "GuildBank" then

                --if its the guild bank we dont want to overwrite tabs not sent
                if type(data.payload.Data) == "table" then
                    for tabID, tabItems in ipairs(data.payload.Data) do

                        -- if the tab exists update it
                        if GUILDBOOK_GLOBAL["GuildBank"][data.payload.Bank][tabID] then
                            GUILDBOOK_GLOBAL["GuildBank"][data.payload.Bank][tabID] = tabItems;
                        end
                    end
                end

            else
                GUILDBOOK_GLOBAL["GuildBank"][data.payload.Bank] = {
                    Commit = data.payload.Commit,
                    Data = data.payload.Data,
                    Money = data.payload.Money,
                }
            end
        end
    end

end


















-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- calendar data comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local calDelay = 120.0

function Guildbook:RequestGuildCalendarDeletedEvents()
    local calendarEvents = {
        type = 'GUILD_CALENDAR_EVENTS_DELETED_REQUESTED',
        payload = '-',
    }
    self:Transmit(calendarEvents, 'GUILD', nil, 'NORMAL')
    --Guildbook.DEBUG('comms_out', 'RequestGuildCalendarDeletedEvents', 'Sending calendar events deleted request')
end

function Guildbook:RequestGuildCalendarEvents()
    local calendarEventsDeleted = {
        type = 'GUILD_CALENDAR_EVENTS_REQUESTED',
        payload = '-',
    }
    self:Transmit(calendarEventsDeleted, 'GUILD', nil, 'NORMAL')
    --Guildbook.DEBUG('comms_out', 'RequestGuildCalendarEvents', 'Sending calendar events request')
end

function Guildbook:SendGuildCalendarEvent(event)
    local calendarEvent = {
        type = 'GUILD_CALENDAR_EVENT_CREATED',
        payload = event,
    }
    self:Transmit(calendarEvent, 'GUILD', nil, 'NORMAL')

    GuildbookUI.home:OnNewsFeedReceived(nil, {
        newsType = "calendarEventCreated",
        text = string.format(L["NF_CAL_EVENT_CREATE"], event.title, UnitName("player"))
    })
    --Guildbook.DEBUG('comms_out', 'SendGuildCalendarEvent', string.format('Sending calendar event to guild, event title: %s', event.title))
end

function Guildbook:OnGuildCalendarEventCreated(data, distribution, sender)
    --Guildbook.DEBUG('comms_in', 'OnGuildCalendarEventCreated', string.format('Received a calendar event created from %s', sender))
    local guildName = Guildbook:GetGuildName()
    if guildName then
        if not GUILDBOOK_GLOBAL['Calendar'] then
            GUILDBOOK_GLOBAL['Calendar'] = {
                [guildName] = {},
            }
        else
            if not GUILDBOOK_GLOBAL['Calendar'][guildName] then
                GUILDBOOK_GLOBAL['Calendar'][guildName] = {}
            end
        end
        local exists = false
        for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            if event.created == data.payload.created and event.owner == data.payload.owner then
                exists = true
                Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventCreated', 'this event already exists in your db')
            end
        end
        if exists == false then
            table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], data.payload)

            -- when i redesign the calendar into a mixin callback fun bag i can (in theory) use th same callback/triggers but for now just need to add the news
            GuildbookMixin:OnNewsFeedReceived(nil, {
                newsType = "calendarEventCreated",
                text = string.format("Calendar event %s created by %s", data.payload.title, sender)
            })
            Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventCreated', string.format('Received guild calendar event, title: %s', data.payload.title))
        end
    end
end

function Guildbook:SendGuildCalendarEventAttend(event, attend)
    local calendarEvent = {
        type = 'GUILD_CALENDAR_EVENT_ATTEND',
        payload = {
            e = event,
            a = attend,
            guid = UnitGUID('player'),
        },
    }
    self:Transmit(calendarEvent, 'GUILD', nil, 'NORMAL')
    Guildbook.DEBUG('calendarMixin', 'SendGuildCalendarEventAttend', string.format('Sending calendar event attend update to guild, event title: %s, attend: %s', event.title, attend))
end

function Guildbook:OnGuildCalendarEventAttendReceived(data, distribution, sender)
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for k, v in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            if v.created == data.payload.e.created and v.owner == data.payload.e.owner then
                v.attend[data.payload.guid] = {
                    ['Updated'] = GetServerTime(),
                    ['Status'] = tonumber(data.payload.a),
                }
                Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventAttendReceived', string.format('Updated event %s: %s has set attending to %s', v.title, sender, data.payload.a))
            end
        end
    end
    --C_Timer.After(1, function()
    if Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:IsVisible() then
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateAttending()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateClassTabs()
    end
    --end)
end

function Guildbook:SendGuildCalendarEventDeleted(event)
    local calendarEventDeleted = {
        type = 'GUILD_CALENDAR_EVENT_DELETED',
        payload = event,
    }
    Guildbook.DEBUG('calendarMixin', 'SendGuildCalendarEventDeleted', string.format('Guild calendar event deleted, event title: %s', event.title))
    self:Transmit(calendarEventDeleted, 'GUILD', nil, 'NORMAL')
end

function Guildbook:OnGuildCalendarEventDeleted(data, distribution, sender)
    self.GuildFrame.GuildCalendarFrame.EventFrame:RegisterEventDeleted(data.payload)
    Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventDeleted', string.format('Guild calendar event %s has been deleted', data.payload.title))
    C_Timer.After(1, function()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
    end)
end


-- this will be restricted to only send events that fall within a month, this should reduce chat spam
-- it is further restricted to send not within 2 minutes of previous send
function Guildbook:SendGuildCalendarEvents()
    local today = date('*t')
    local future = date('*t', (time(today) + (60*60*24*28)))
    local events = {}
    -- calendar events use a global variable to check last send as they cover all characters and are sent on login
    -- if character A logs in to check AH, mail etc they would send data, then if character B logs in they would be sending the same data
    -- so we will use a variable in account saved vars to prevent spam, delay set at 3mins
    if GetServerTime() > GUILDBOOK_GLOBAL['LastCalendarTransmit'] + 180.0 then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
            for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if not event.date then
                    Guildbook.DEBUG("calendarMixin", 'SendGuildCalendarEvents', "event has no date table "..event.title)
                else
                    if event.date.month >= today.month and event.date.year >= today.year and event.date.month <= future.month and event.date.year <= future.year then
                        table.insert(events, event)
                        Guildbook.DEBUG('calendarMixin', 'SendGuildCalendarEvents', string.format('Added event: %s to transmit table', event.title))
                    end
                end
            end
            local calendarEvents = {
                type = 'GUILD_CALENDAR_EVENTS',
                payload = events,
            }
            self:Transmit(calendarEvents, 'GUILD', nil, 'BULK')
            Guildbook.DEBUG('calendarMixin', 'SendGuildCalendarEvents', string.format('range=%s-%s-%s to %s-%s-%s', today.day, today.month, today.year, future.day, future.month, future.year))
        end
        GUILDBOOK_GLOBAL['LastCalendarTransmit'] = GetServerTime()
    end
end

function Guildbook:OnGuildCalendarEventsReceived(data, distribution, sender)
    local guildName = Guildbook:GetGuildName()
    local today = date('*t')
    local monthStart = date('*t', time(today))
    if not GUILDBOOK_GLOBAL['Calendar'] then
        GUILDBOOK_GLOBAL['Calendar'] = {}
    end
    if guildName then
        if not GUILDBOOK_GLOBAL['Calendar'][guildName] then
            GUILDBOOK_GLOBAL['Calendar'][guildName] = {}
        end
    end
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        -- loop the events sent to us
        for k, recievedEvent in ipairs(data.payload) do
            Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventsReceived', string.format('Received event: %s', recievedEvent.title))
            local exists = false
            -- loop our db for a match
            for _, dbEvent in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if dbEvent.created == recievedEvent.created and dbEvent.owner == recievedEvent.owner then
                    exists = true
                    Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventsReceived', 'event exists!')
                    -- loop the db events for attending guid
                    for guid, info in pairs(dbEvent.attend) do
                        local character = Database:FetchCharacterTableByGUID(guid)
                        if type(character) == "table" then
                            -- is there a matching guid 
                            if recievedEvent.attend and recievedEvent.attend[guid] then
                                if tonumber(info.Updated) < tonumber(recievedEvent.attend[guid].Updated) then
                                    info.Status = recievedEvent.attend[guid].Status
                                    info.Updated = recievedEvent.attend[guid].Updated
                                    Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventsReceived', string.format("updated %s attend status for %s", character.Name or "no name", dbEvent.title))
                                end
                            else
                                Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventsReceived', string.format("%s wasn't in the sent event attending data", character.Name or "no name"))
                            end
                        end
                    end
                    -- loop the recieved event attending table and add any missing players
                    for guid, info in pairs(recievedEvent.attend) do
                        local character = Database:FetchCharacterTableByGUID(guid)
                        if not dbEvent.attend[guid] then
                            dbEvent.attend[guid] = {}
                            dbEvent.attend[guid].Updated = GetServerTime()
                            dbEvent.attend[guid].Status = info.Status
                            Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventsReceived', string.format("added %s attend status for %s", character.Name or "no name", dbEvent.title))
                        end
                    end
                end
            end
            if exists == false then
                table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], recievedEvent)
                Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventsReceived', string.format('This event is a new event, adding to db: %s', recievedEvent.title))
            end
        end
    end
    if Guildbook.GuildFrame.GuildCalendarFrame:IsVisible() then
        Guildbook.GuildFrame.GuildCalendarFrame:MonthChanged()
    end
end

function Guildbook:SendGuildCalendarDeletedEvents()
    if GetServerTime() > GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] + 120.0 then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
            local calendarDeletedEvents = {
                type = 'GUILD_CALENDAR_DELETED_EVENTS',
                payload = GUILDBOOK_GLOBAL['CalendarDeleted'][guildName],
            }
            Guildbook.DEBUG('calendarMixin', 'SendGuildCalendarDeletedEvents', 'Sending deleted calendar events to guild')
            self:Transmit(calendarDeletedEvents, 'GUILD', nil, 'BULK')
        end
        GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] = GetServerTime()
    end
end


function Guildbook:OnGuildCalendarEventsDeleted(data, distribution, sender)
    --Guildbook.DEBUG('comms_in', 'OnGuildCalendarEventsDeleted', string.format('Received calendar events deleted from %s', sender))
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
        for k, v in pairs(data.payload) do
            if not GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] then
                GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] = true
                Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventsDeleted', 'Added event to deleted table')
            end
        end
    end
    C_Timer.After(0.5, function()
        if Guildbook.GuildFrame and Guildbook.GuildFrame.GuildCalendarFrame then
            Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
        end
    end)
end


function Guildbook:PushEventUpdate(event)
    local response = {
        type = 'GUILD_CALENDAR_EVENT_UPDATE',
        payload = event,
    }
    self:Transmit(response, 'GUILD', nil, 'NORMAL')
end


function Guildbook:OnGuildCalendarEventUpdated(data, distribution, sender)
    if distribution ~= 'GUILD' then
        return
    end
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for _, event in ipairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            if event.owner == data.payload.owner and event.created == data.payload.created then
                event.title = data.payload.title
                event.desc = data.payload.desc
            end
        end
    end
    Guildbook.DEBUG('calendarMixin', 'OnGuildCalendarEventUpdated', string.format("%s has updated the event %s", sender, data.payload.title), data)
end




function Guildbook:RemoveOldEventsFromSavedVarFile()
    local today = date('*t')
    local weeks8 = 60*60*24*55
    local timeToday = time(today)
    --local thePast = date('*t', (time(today) - weeks8)) -- 8 weeks ago (minus 1 day)
    local guildName = Guildbook:GetGuildName()

    local eventCount = 0;
    --lets clean up the calendar deleted table
    if GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
        local eventsToDelete = {}
        for k, v in pairs(GUILDBOOK_GLOBAL['CalendarDeleted'][guildName]) do
            local guid, timestamp = strsplit(">", k)
            local removeEvent = false;
            local _event = nil;
            -- loop the calendar to find a match, an event can be identified by its owner and created values as these combine into a unique string ID (time being a value that will change each second)
            for i, event in ipairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                eventCount = eventCount + 1;
                --print(guid, event.owner)
                --print(timestamp, event.created)
                
                if event.owner == guid and tonumber(timestamp) == tonumber(event.created) then
                    local eventTimestamp = time(event.date)
                    if eventTimestamp < (timeToday - weeks8) then
                        removeEvent = true;
                        _event = event;
                    end
                end
            end
            if eventCount > 0 then
                if (removeEvent == true and type(_event) == "table") then
                    eventsToDelete[k] = _event.title
                end
            end
        end

        if eventsToDelete and next(eventsToDelete) then
            for eventID, eventTitle in pairs(eventsToDelete) do
                Guildbook.DEBUG('calendarMixin', 'RemoveOldEventsFromSavedVarFile', string.format("removing %s from saved var calendar deleted table", eventTitle))
                GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][eventID] = nil;
            end
        end

        if eventCount == 0 then
            Guildbook.DEBUG('calendarMixin', 'RemoveOldEventsFromSavedVarFile', "wiping all deleted data as no events found in calendar")
            --GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] = {}
        end
    end


    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for i, event in ipairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            local eventTimestamp = time(event.date)
            --print("event time:", eventTimestamp, "timeToday:", timeToday, "diff:", timeToday-eventTimestamp, "8 weeks:", weeks8)

            if eventTimestamp < (timeToday - weeks8) then
                Guildbook.DEBUG('calendarMixin', 'RemoveOldEventsFromSavedVarFile', string.format("event %s is more then 8 weeks old, removing from saved var", event.title), event)
                GUILDBOOK_GLOBAL['Calendar'][guildName][i] = nil;
            end
        end
    end
end

























-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- events
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:UPDATE_MOUSEOVER_UNIT()
    -- delay any model loading while players addons sort themselves out
    if Guildbook.LoadTime and Guildbook.LoadTime + 8.0 > GetTime() then
        return
    end

    if not self.player.faction then
        local lr, er = UnitRace("player")
        self.player = {
            faction = UnitFactionGroup("player"),
            race = er:upper(),
        }
    end

    local guid = UnitGUID('mouseover')
    if guid and guid:find('Player-') then

        if not Guildbook.PlayerMixin then
            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            Guildbook.PlayerMixin:SetGUID(guid)
        end
        if Guildbook.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
            -- double check mixin
            if not name then
                return
            end
            --local _, class, _ = C_PlayerInfo.GetClass(Guildbook.PlayerMixin)
            local sex = C_PlayerInfo.GetSex(Guildbook.PlayerMixin)
            if sex == 0 then
                sex = 'MALE'
            else
                sex = 'FEMALE'
            end
            local raceID = C_PlayerInfo.GetRace(Guildbook.PlayerMixin)
            local race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:upper()
            local faction = C_CreatureInfo.GetFactionInfo(raceID).groupTag
            if race and self.player.faction == C_CreatureInfo.GetFactionInfo(raceID).groupTag then
                GuildbookUI.profiles:AddCharacterModelFrame('mouseover', race, sex)
            end
        end
    end
end

function Guildbook:CHAT_MSG_GUILD(...)
    local sender = select(5, ...)
    local msg = select(1, ...)
    if not msg then
        return
    end
    local guid = select(12, ...)

    local character = Database:FetchCharacterTableByGUID(guid)
    if type(character) ~= "table" then
        return;
    end
    if type(character.Class) ~= "string" then
        return;
    end
    GuildbookUI.chat:AddGuildChatMessage({
        formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[character.Class].FontColour, sender, msg),
        sender = sender,
        target = "guild",
        message = msg,
        chatID = guid,
        senderGUID = guid,
    })

    GuildbookUI.home:OnNewsFeedReceived(nil, {
        newsType = "guildChat",
        text = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[character.Class].FontColour, sender, msg),
    })
end

function Guildbook:CHAT_MSG_WHISPER(...)
    local msg, sender, _, _, _, _, _, _, _, _, _, guid = ...
    -- local msg = select(1, ...)
    -- local sender = select(2, ...)
    -- local guid = select(12, ...) -- sender guid
    sender = Ambiguate(sender, "none")
    if guid and guid:find("Player-") then
        local lc, englishClass = GetPlayerInfoByGUID(guid)

        if englishClass and self.Data.Class[englishClass] then
            GuildbookUI.chat:AddChatMessage({
                formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[englishClass].FontColour, sender, msg),
                sender = sender,
                target = Ambiguate(UnitName("player"), "none"),
                message = msg,
                chatID = guid,
                senderGUID = guid,
            })
        end
    end

    -- if not Guildbook.PlayerMixin then
    --     Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    -- else
    --     Guildbook.PlayerMixin:SetGUID(guid)
    -- end
    -- if Guildbook.PlayerMixin:IsValid() then
    --     local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
    --     if class then
    --         GuildbookUI.chat:AddChatMessage({
    --             formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[class].FontColour, sender, msg),
    --             sender = sender,
    --             target = Ambiguate(UnitName("player"), "none"),
    --             message = msg,
    --             chatID = guid,
    --             senderGUID = guid,
    --         })
    --     end
    -- end
end


function Guildbook:BAG_UPDATE_DELAYED()
    self:ScanPlayerBags()
end






-- added to automate the guild bank scan
function Guildbook:BANKFRAME_OPENED()
    for i = 1, GetNumGuildMembers() do
        local _, _, _, _, _, _, publicNote, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if publicNote:lower():find('guildbank') and GUID == UnitGUID('player') then
            self:ScanPlayerContainers()
        end
    end
    self:ScanPlayerBank()
end

-- added this to the closed event to be extra accurate
local bankScanned = false;
function Guildbook:BANKFRAME_CLOSED()
    if bankScanned == false then
        Guildbook.DEBUG("event", "BANKFRAME_CLOSED", "scanning items")
        for i = 1, GetNumGuildMembers() do
            local _, _, _, _, _, _, publicNote, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
            if publicNote:lower():find('guildbank') and GUID == UnitGUID('player') then
                self:ScanPlayerContainers()
            end
        end
        self:ScanPlayerBank()
        bankScanned = true;
    else
        bankScanned = false;
    end
end





-- added to automate the guild bank scan
function Guildbook:GUILDBANKFRAME_OPENED()
    for i = 1, GetNumGuildMembers() do
        local _, _, _, _, _, _, publicNote, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if publicNote:lower():find('guildbank') and GUID == UnitGUID('player') then
            --print("scan guild bank on open")
        end
    end
end

-- added this to the closed event to be extra accurate
local bankScanned = false;
function Guildbook:GUILDBANKFRAME_CLOSED()
    if bankScanned == false then
        Guildbook.DEBUG("event", "BANKFRAME_CLOSED", "scanning items")
        for i = 1, GetNumGuildMembers() do
            local _, _, _, _, _, _, publicNote, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
            if publicNote:lower():find('guildbank') and GUID == UnitGUID('player') then
                --print("scan guild bank on close")
            end
        end
        bankScanned = true;
    else
        bankScanned = false;
    end
end





--[[
    ////////////////////////////////////////////

    this still exists due to the calendar and guild bank using the old comm system

    ////////////////////////////////////////////
]]

--- handle comms
function Guildbook:ON_COMMS_RECEIVED(prefix, message, distribution, sender)

    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI:SetInfoText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI:SetInfoText("blocked data comms while in combat")
            return;
        end
    end

    if prefix ~= addonName then 
        return 
    end
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message);
    if not decoded then
        return;
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then
        return;
    end
    local success, data = LibSerialize:Deserialize(decompressed);
    if not success or type(data) ~= "table" then
        return;
    end

    Guildbook.DEBUG('comms_in', string.format("ON_COMMS_RECEIVED <%s>", distribution), string.format("%s from %s", data.type, sender), data)

    -- tradeskills
    if data.type == "TRADESKILLS_REQUEST" then
        --self:OnTradeSkillsRequested(data, distribution, sender)

    elseif data.type == "TRADESKILLS_RESPONSE" then
        --self:OnTradeSkillsReceived(data, distribution, sender);


    -- privacy
    elseif data.type == "PRIVACY_INFO" then
        --self:OnPrivacyReceived(data, distribution, sender)

    elseif data.type == "PRIVACY_ERROR" then
        --self:OnPrivacyError(tonumber(data.payload), sender)

    elseif data.type == "VERSION_INFO" then
        --self:OnVersionInfoRecieved(data, distribution, sender)




--==================================
elseif data.type == 'GUILD_BANK_COMMIT_REQUEST' then
    self:OnGuildBankCommitRequested(data, distribution, sender)

elseif data.type == 'GUILD_BANK_COMMIT_RESPONSE' then
    self:OnGuildBankCommitReceived(data, distribution, sender)

elseif data.type == 'GUILD_BANK_DATA_REQUEST' then
    self:OnGuildBankDataRequested(data, distribution, sender)

elseif data.type == 'GUILD_BANK_DATA_RESPONSE' then
    self:OnGuildBankDataReceived(data, distribution, sender)
--==================================





    
--- these need better naming should decide before 4.x is released?
    elseif data.type == 'GUILD_CALENDAR_EVENT_CREATED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventCreated(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENTS' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventsReceived(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENT_DELETED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventDeleted(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_DELETED_EVENTS' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventsDeleted(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENT_ATTEND' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventAttendReceived(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENTS_REQUESTED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:SendGuildCalendarEvents()

    elseif data.type == 'GUILD_CALENDAR_EVENTS_DELETED_REQUESTED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:SendGuildCalendarDeletedEvents()

    elseif data.type == 'GUILD_CALENDAR_EVENT_UPDATE' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventUpdated(data, distribution, sender)
    end
end



--set up event listener

--TODO: these will slowly be removed and stuff moved into 'classes' so to speak, leaving a lot of code in for now as somethign will likely go wrong
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_OPENED')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_CLOSED')

-- if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
--     Guildbook.EventFrame:RegisterEvent('GUILDBANKFRAME_OPENED')
--     Guildbook.EventFrame:RegisterEvent('GUILDBANKFRAME_CLOSED')
-- end

Guildbook.EventFrame:RegisterEvent('BAG_UPDATE_DELAYED')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_GUILD')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_WHISPER')
Guildbook.EventFrame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)

    if event == "ADDON_LOADED" then
        if ... == addonName then
            Guildbook:PrintMessage(L["ADDON_LOADED"])
            Guildbook:Init()
        end

    else


        if Guildbook[event] then
            Guildbook[event](Guildbook, ...)
        end

    end
end)
