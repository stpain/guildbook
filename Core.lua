--[==[

Copyright ©2020 Samuel Thomas Pain

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


--[[
    code logic

    1 addon loaded = create saved vars
    2 play entering world = get player info (faction,race etc)
    3 load
        scan player professions
        scan talents
        scan inventory
        check privacy
        send calendar data
        send tradeskill recipes
]]

local addonName, Guildbook = ...

Guildbook.addonLoaded = false

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local LCI = LibStub:GetLibrary("LibCraftInfo-1.0")



---------------------------------------------------------------------------------------------------------------------------------------------------------------
--variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------

local locale = GetLocale()
local L = Guildbook.Locales

Guildbook.lastProfTransmit = GetTime()
Guildbook.FONT_COLOUR = '|cff0070DE'
Guildbook.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
Guildbook.ContextMenu_Separator_Wide = "|TInterface/COMMON/UI-TooltipDivider:8:250|t"
Guildbook.PlayerMixin = nil

Guildbook.COMMS_DELAY = 0.0
Guildbook.COMM_LOCK_COOLDOWN = 20.0
Guildbook.GUILD_NAME = nil;

Guildbook.Colours = {
    Blue = CreateColor(0.1, 0.58, 0.92, 1),
    Orange = CreateColor(0.79, 0.6, 0.15, 1),
    Yellow = CreateColor(1.0, 0.82, 0, 1),
    LightRed = CreateColor(216/255,69/255,75/255),
    BlizzBlue = CreateColor(0,191/255,243/255),
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
    
    elseif msg == "version" and Guildbook.version then
        Guildbook:PrintMessage(Guildbook.version)

    elseif msg == "test" then

    end
end








--[[
    working on making the code easier to read and manage
    at the moment everything is just in the Guildbook addon table

    so making some tables to seperate various features and/or functions

    Character - will handle anything related to the players character
    Tradeskill - will target tradeskill specific jobs
    Database ?
    Guild ?
]]






--[[
    Tradeskills Class
]]
local Tradeskills = {}
Tradeskills.CurrentLocale = GetLocale()
Tradeskills.TradeskillNames = {
    "Alchemy",
    "Blacksmithing",
    "Enchanting",
    "Engineering",
    "Inscription",
    "Jewelcrafting",
    "Leatherworking",
    "Tailoring",
    "Mining",
    "Herbalism",
    "Skinning",
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
		--[-1] = "First Aid"
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
	},
	esMX = {
		[164] = "Herrería",
		[165] = "Peletería",
		[171] = "Alquimia",
		[182] = "Herboristería",
		[185] = "Cocina",
		[186] = "Minería",
		[197] = "Sastrería",
		[202] = "Ingeniería",
		[333] = "Encantamiento",
		[356] = "Pesca",
		[393] = "Desuello",
		[755] = "Joyería",
		[773] = "Inscripción",
	},
	-- discovered this locale exists also maybe esAL ?
	esES = {
        [164] = "Herrería",
        [165] = "Peletería",
        [171] = "Alquimia",
        [182] = "Herboristería",
        [185] = "Cocina",
        [186] = "Minería",
        [197] = "Sastrería",
        [202] = "Ingeniería",
        [333] = "Encantamiento",
        [356] = "Pesca",
        [393] = "Desuello",
        [755] = "Joyería",
        [773] = "Inscripción",
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
	},
}
Tradeskills.TradeskillLocaleNameToID = tInvert(Tradeskills.TradeskillIDsToLocaleName[Tradeskills.CurrentLocale])

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
end

Guildbook.Tradeskills = Tradeskills;















--[[
    Database class

    the database class provides functions to update the account wide saved variables and the per character saved variables
    whenever a value is changed a callback is triggered
]]
local Database = CreateFromMixins(CallbackRegistryMixin)
Database:GenerateCallbackEvents({
    "OnCharacterTableChanged", -- only this clients UI needs to listen to this
    "OnPlayerCharacterTableChanged",
    "OnPlayerCharacterTradeskillsInfoChanged",
    "OnPlayerCharacterTradeskillRecipesChanged",
    -- "OnPlayerCharacterTalentsChanged",
    -- "OnPlayerCharacterInventoryChanged",
})
Database.currentGuildName = nil;
Database.onCharacterTableChanged_IsTriggered = false;
Database.onPlayerCharacterTableChanged_IsTriggered = false;
Database.onPlayerCharacterTradeskillsInfoChanged_IsTriggered = false;
Database.onPlayerCharacterTradeskillRecipesChanged_IsTriggered = false;


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


---fetch character info using guid and key
---@param guid string the characters GUID
---@param key string the key to fetch
---@return any
function Database:GetCharacterInfo(guid, key)
    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName] and GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid] then
        local characterName = GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid].Name
        Guildbook.DEBUG("databaseMixin", "Database:GetCharacterInfo", string.format("found %s for %s", key, characterName))
        return GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid][key];

    else
        local characterName = GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid].Name or "no name or character table"
        Guildbook.DEBUG("databaseMixin", "Database:GetCharacterInfo", string.format("unable to find %s for %s", key, characterName))
        return GUILDBOOK_GLOBAL['GuildRosterCache'][self.currentGuildName][guid][key];
    end
    return false;
end



function Database:FetchCharacterTableByGUID(guid)

    if self.currentGuildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName] and GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid] then
        Guildbook.DEBUG("databaseMixin", "Database:FetchCharacterTableByGUID", string.format("found character table for %s", GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid].Name))
        return GUILDBOOK_GLOBAL.GuildRosterCache[self.currentGuildName][guid];

    else
        Guildbook.DEBUG("databaseMixin", "Database:FetchCharacterTableByGUID", "unable to find character table")
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
        print("t = GUILDBOOK_CHARACTER")
    else
        if GUILDBOOK_CHARACTER[tab] then
            t = GUILDBOOK_CHARACTER[tab];
        else
            GUILDBOOK_CHARACTER[tab] = {};
            t = GUILDBOOK_CHARACTER[tab];
        end
        print("t =", tab)
    end

    if type(t) ~= "table" then
        Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", string.format("table not found for key: %s, opt tab: %s", key, tab or "-"), {
            ["key"] = key,
            ["info"] = info,
            ["tab"] = tab or "-",
        })
        return;
    end

    if t then
        t[key] = info;
        Guildbook.DEBUG("databaseMixin", "Database:UpdatePlayerCharacterTable", string.format("set or updated %s", key), info)
        ---to avoid multiple triggers in < 1s we add a small queue system
        if self.onPlayerCharacterTableChanged_IsTriggered == false then
            C_Timer.After(1.5, function()
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

    CallbackRegistryMixin.OnLoad(self)

    ---setup the UI callback
    Database:RegisterCallback("OnCharacterTableChanged", GuildbookUI.OnCharacterTableChanged, GuildbookUI)

    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        self.currentGuildName = guildName;
    end

end

Guildbook.Database = Database;










--[[
    Character class

    the Character class listens for changes to the players character and sends this data to the Database class
]]
local Character = {}
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
    for _, slot in ipairs(self.InventorySlots) do
        local link = GetInventoryItemLink('player', GetInventorySlotInfo(slot)) or false;
        if link ~= nil then
            t[slot] = link;
        end
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
                Name = name,
                Index = talentIndex,
                Link = GetTalentLink(tabIndex, talentIndex),
            });
        end
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
        Profession1Level = 0,
        Profession2Level = 0,
        Profession1Spec = nil,
        Profession2Spec = nil,
        FishingLevel = 0,
        CookingLevel = 0,
        FirstAidLevel = 0,
    }

    Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", "scanning for tradeskill info")
    for s = 1, GetNumSkillLines() do
        local skill, isHeader, isExpanded, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)

        ---make sure these headers are open so we get proper results, discovered the skill line might not get updated if left perma open so collapse it first then expand again to resfresh the level
        if skill == "Professions" or skill == "Secondary Skills" then
            CollapseSkillHeader(s)
            ExpandSkillHeader(s)
        end

        ---return the ui to previous state
        if isExpanded then
            ExpandSkillHeader(s)
        else
            CollapseSkillHeader(s)
        end

        local engSkill = Tradeskills:GetEnglishNameFromTradeskillName(skill)
        if engSkill then
            if engSkill == 'Fishing' then 
                Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", "found fishing updating level")
                characterTradeskillsInfo.FishingLevel = level

            elseif engSkill == 'Cooking' then
                Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", "found cooking updating level")
                characterTradeskillsInfo.CookingLevel = level

            elseif engSkill == 'First Aid' then
                Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", "found first aid updating level")
                characterTradeskillsInfo.FirstAidLevel = level

            else
                for _, prof in pairs(Tradeskills.TradeskillNames) do
                    if prof == engSkill then
                        Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("found %s", prof))

                        if characterTradeskillsInfo.Profession1 == '-' then
                            characterTradeskillsInfo.Profession1 = engSkill
                            Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("setting Profession1 as %s", engSkill))
                            characterTradeskillsInfo.Profession1Level = level

                        else
                            if characterTradeskillsInfo.Profession2 == '-' then
                                characterTradeskillsInfo.Profession2 = engSkill
                                Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("setting Profession2 as %s", engSkill))
                                characterTradeskillsInfo.Profession2Level = level
                            end
                        end

                        -- if characterTradeskillsInfo.Profession1 == characterTradeskillsInfo.Profession2 then
                        --     characterTradeskillsInfo.Profession2 = engSkill
                        --     characterTradeskillsInfo.Profession2Level = level
                        --     Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("updated setting for Profession2 > set as %s", engSkill))
                        -- end
                    end
                end
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
        if engSpellName then
            if engSpellName ~= "Cooking" and engSpellName ~= "Fishing" and engSpellName ~= "First Aid" then
                if characterTradeskillsInfo.Profession1 == "-" then
                    characterTradeskillsInfo.Profession1 = engSpellName;
                    Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("updated prof1 to %s via spellbook scan", engSpellName))
                elseif characterTradeskillsInfo.Profession2 == "-" then
                    characterTradeskillsInfo.Profession2 = engSpellName;
                    Guildbook.DEBUG("characterMixin", "Character:ScanForTradeskillInfo", string.format("updated prof2 to %s via spellbook scan", engSpellName))
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

            elseif characterTradeskillsInfo.Profession2 == engProf then
                characterTradeskillsInfo.Profession2Spec = tonumber(spellID)
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
end


---scan the players currently opened tradeskill recipes and trigger the changed event
function Character:ScanTradeskillRecipes()
    local localeProf = GetTradeSkillLine() -- this returns local name
    if localeProf == "UNKNOWN" then
        return; -- exit as the window isnt open
    end

    local englishProf = Tradeskills:GetEnglishNameFromTradeskillName(localeProf)
    if not englishProf then
        Guildbook.DEBUG("func", "Character:ScanTradeskillRecipes", "englishProf not known")
        return; -- english prof name acts as a key so we must have it to continue
    end

    Guildbook.DEBUG("func", "Character:ScanTradeskillRecipes", string.format("scanning for tradeskill recipes [%s]", englishProf))

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

    Database:UpdatePlayerCharacterTradeskillRecipes(englishProf, tradeskillRecipes)

end


---scan the players enchanting recipes and trigger the changed event
function Character:ScanEnchantingRecipes()
    local currentCraftingWindow = GetCraftSkillLine(1)
    if currentCraftingWindow == nil then
        return; -- exit as no craft open
    end

    local englishProf = Tradeskills:GetEnglishNameFromTradeskillName(currentCraftingWindow)
    if not englishProf then
        return; -- english prof name acts as a key so we must have it to continue
    end

    Guildbook.DEBUG("func", "Character:ScanEnchantingRecipes", string.format("scanning for tradeskill recipes [%s]", englishProf))

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
    for _, tradeskill in ipairs(Tradeskills.TradeskillNames) do
        local isCurrentTradeskill = false;
        if characterData.Profession1 == tradeskill or characterData.Profession2 == tradeskill then
            isCurrentTradeskill = true;
            Guildbook.DEBUG("func", "Character:RemoveOldTradeskillRecipeTables", string.format("Keeping %s table for %s", tradeskill, characterName), characterData)
        end
        if isCurrentTradeskill == false and characterData[tradeskill] then
            characterData[tradeskill] = nil;
            Guildbook.DEBUG("func", "Character:RemoveOldTradeskillRecipeTables", string.format("Removed %s table from %s", tradeskill, characterName), characterData)
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
        Guildbook.DEBUG("func", "Character:GetPaperDollStats", "using 'Current' as spec name for paper doll stats")
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



function Character:OnChatMessageSystem(message)
    local skill, value = message:match(self.SkillUpPattern)
    if skill and value then
        local englishProf = Tradeskills:GetEnglishNameFromTradeskillName(skill)
        if englishProf then
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

            Guildbook.DEBUG("func", "Character:OnChatMessageSystem", string.format("dbKey %s value %s", dbKey, value))
            if type(dbKey) == "string" and type(value) == "number" then
                Database:UpdatePlayerCharacterTable(dbKey, value)
            end
        end
    end
end



---initialises Character, sets up the listener for events
function Character:Init()

    CallbackRegistryMixin.OnLoad(self)

    self.listener = CreateFrame("Frame")
    self.listener:RegisterEvent("TRADE_SKILL_UPDATE")
    self.listener:RegisterEvent("CRAFT_UPDATE")
    self.listener:RegisterEvent("SKILL_LINES_CHANGED")
    self.listener:RegisterEvent("CHARACTER_POINTS_CHANGED")
    self.listener:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.listener:RegisterEvent("CHAT_MSG_SKILL")

    self.listener:SetScript("OnEvent", function(_, event, ...)
        Guildbook.DEBUG("event", "Character:OnEvent", string.format("event: %s", event))

        if event == "TRADE_SKILL_UPDATE" then
            self:ScanTradeskillRecipes()

        elseif event == "CRAFT_UPDATE" then
            self:ScanEnchantingRecipes()

        elseif event == "SKILL_LINES_CHANGED" then

            ---during the scan we'll expand some headers which will cause the event to fire again, so lets ignore this if a scan has just happened
            ---i could add the boolean check to the end of the func maybe? would make things more accurate and remove a C_Timer call ?
            if self.TradeskillInfoScanActive == false then
                self.TradeskillInfoScanActive = true;
                self:ScanForTradeskillInfo()
                C_Timer.After(1.0, function()
                    self.TradeskillInfoScanActive = false;
                end)
            end

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

        end
    end)
end


Guildbook.Character = Character;





















local Comms = {}
---this value can be adjusted but its purpose is to allow all bulk comms to be received before we process the data - there is a settings slider for this which needs to be hooked up maybe or just set as a default value
Comms.DELAY = 2.0;
Comms.PREFIX = "GUILDBOOK";
Comms.MessageTypes = {

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



function Comms:Init()

    AceComm:Embed(self)
    self:RegisterComm(self.PREFIX)

    ---tradeskill data is always shared so hook up the callbacks so we can send updates
    Database:RegisterCallback("OnPlayerCharacterTradeskillsInfoChanged", self.SendCharacterTradeskillInfo, self)
    Database:RegisterCallback("OnPlayerCharacterTradeskillRecipesChanged", self.SendCharacterTradeskillsRecipes, self)

    ---this is a slightly special case as some of the table data is under privacy rules - this is basically spec and primary profs
    Database:RegisterCallback("OnPlayerCharacterTableChanged", self.SendPlayerCharacterUpdates, self)

    ---lets not be rude
    self:SayHello()
end


---send an addon message through the aceComm lib
---@param data table the data to send including a comm type
---@param channel string the addon channel to use for the comm
---@param targetGUID string the targets GUID, this is used to make comms work on conneted realms - only required for WHISPER comms
---@param priority string the prio to use
function Comms:Transmit(data, channel, targetGUID, priority)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in combat")
            return;
        end
    end
    if not Guildbook:GetGuildName() then
        return;
    end

    -- add the version and sender guid to the message
    data["version"] = tonumber(GetAddOnMetadata('Guildbook', "Version"));
    data["senderGUID"] = UnitGUID("player")

    -- clean up the target name when using a whisper
    if channel == 'WHISPER' then

        --find character first before looping roster
        --local character = Guildbook:GetCharacterFromCache(targetGUID)
        local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(targetGUID)

        --Guildbook.DEBUG('commsMixin', 'SendCommMessage', string.format("found character table for targetGUID"), {name = name, realm = realm})

        if name and realm then -- type(character) == "table" and character.FullName then
            
            --local target = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and string.format("%s-%s", name, realm) or name;
            local target = realm ~= "" and string.format("%s-%s", name, realm) or name;

            local totalMembers, _, _ = GetNumGuildMembers()
            for i = 1, totalMembers do
                local name, rankName, _, _, _, _, _, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)

                if guid == targetGUID then
                    if isOnline == true then
                        local serialized = LibSerialize:Serialize(data);
                        local compressed = LibDeflate:CompressDeflate(serialized);
                        local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
                    
                        if encoded and channel and priority then
                            Guildbook.DEBUG('commsMixin', 'SendCommMessage_TargetOnline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority), data)
                            self:SendCommMessage(Comms.PREFIX, encoded, channel, target, priority)
                        end
                    else
                        Guildbook.DEBUG('error', 'SendCommMessage_TargetOffline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
                    end
                    return; --no need to keep checking the roster at this point
                end
            end
        end

    elseif channel == "GUILD" then
        local serialized = LibSerialize:Serialize(data);
        local compressed = LibDeflate:CompressDeflate(serialized);
        local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    
        if encoded and channel and priority then
            Guildbook.DEBUG('commsMixin', 'SendCommMessage_NoTarget', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, 'nil', priority))
            self:SendCommMessage(Comms.PREFIX, encoded, channel, nil, priority)
        end
    end
end


function Comms:OnCommReceived(prefix, message, distribution, sender)

    ---check if we want to process comms data
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in combat")
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
        self:ProcessIncomingData(data)
    end)
end


function Comms:ProcessIncomingData(data)

    if data.type and self[data.type] then
        Guildbook.DEBUG('commsMixin', "Comms:ProcessIncomingData", string.format("Comms func %s exists", data.type), data)
        self[data.type](Comms, data)

    else
        Guildbook.DEBUG('commsMixin', "Comms:ProcessIncomingData", string.format("Comms func %s does NOT exist", data.type), data)

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
    Guildbook:CheckPrivacyRankSettings() -- double check all ranks are good
    local ranks = {}
    for i = 1, GuildControlGetNumRanks() do
        ranks[GuildControlGetRankName(i)] = i;
    end
    local privacyRank = GUILDBOOK_GLOBAL.config.privacy[rule];
    local senderRank = GuildControlGetRankName(C_GuildInfo.GetGuildRankOrder(targetGUID))
    ---lower ranks are actually higher in the guild
    if ranks[senderRank] and ranks[privacyRank] and (ranks[senderRank] <= ranks[privacyRank]) then
        return true;
    end
    return false;
end


---send a responce that something isnt shared
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



function Comms:PRIVACY_NOTICE(data)
    Guildbook.DEBUG("commsMixin", "Comms:PRIVACY_NOTICE", "-", data)
end


function Comms:SayHello()

    local greeting = {
        type = "CHARACTER_ONLINE",
        payload = "hello world",
    }

    self:Transmit(greeting, "GUILD", nil, "NORMAL")
end


---send player talent info to the target, this will first check if the target is allowed to see this info as per privacy rules
---@param targetGUID string the targets guid
function Comms:SendCharacterTalentsInfo(targetGUID)

    if self:CheckPrivacyRuleForTargetGUID(targetGUID, "shareTalentsMinRank") == false then
        self:SendPrivacyNotice(targetGUID, "shareTalentsMinRank")
        return;
    end

    local talentsInfo = {
        type = "CHARACTER_TALENTS_INFO_UPDATE",
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

    local profileInfo = {
        type = "CHARACTER_PROFILE_INFO",
        payload = GUILDBOOK_CHARACTER.profile,
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
        type = "CHARACTER_INVENTORY_INFO_UPDATE",
        payload = {
            inventory = GUILDBOOK_CHARACTER.Inventory,
        },
    }

    Guildbook.DEBUG("commsMixin", "Comms:SendCharacterTalentsInfo", "-", inventoryInfo)
    self:Transmit(inventoryInfo, "WHISPER", targetGUID, "BULK")
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
    Guildbook.DEBUG("commsMixin", "Comms:SendTradeskillInfoToTargetGUID", character.Name or "unknown character", tradeskillsInfoUpdate)
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
            self:Transmit(self.playerCharacterTradeskillRecipesUpdate, "GUILD", nil, "NORMAL")
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


function Comms:CHARACTER_ONLINE(data)

    Guildbook.DEBUG("commsMixin", "Comms:CHARACTER_ONLINE", "someone came online", data)

    local randomDelay = math.random(1,3)

    C_Timer.After(randomDelay, function()
        self:SayHelloBack(data.senderGUID)
    end)

    ---update the player who just logged in, these calls will perform a privacy check before sending data
    ---using the stagger system i implemented in the original comms system, it just helps to reduce overloading the chat channels
    
    C_Timer.After(randomDelay + 1.0, function()
        self:SendCharacterTalentsInfo(data.senderGUID);
    end)

    C_Timer.After(randomDelay + 2.0, function()
        self:SendCharacterInventoryInfo(data.senderGUID);
    end)

    C_Timer.After(randomDelay + 3.0, function()
        self:SendCharacterProfileInfo(data.senderGUID);
    end)

    --lets also whisper them our current tradeskills info, this doesnt need a privacy check
    C_Timer.After(randomDelay + 4.0, function()
        self:SendTradeskillInfoToTargetGUID(data.senderGUID);
    end)

    -- should we also whisper our recipes? will need to loop for both profs
    C_Timer.After(randomDelay + 5.0, function()
        --self:SendTradeskillsRecipesToTargetGUID(data.senderGUID);
    end)

end




function Comms:CHARACTER_TRADESKILLS_RECIPES_UPDATE(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "error CHARACTER_TRADESKILLS_RECIPES_UPDATE", "data is not a table", data)
        return;
    end

    if data.senderGUID and data.payload.tradeskill then
        if type(data.payload.recipes) == "table" then
            Database:UpdateCharacterTable(data.senderGUID, data.payload.tradeskill, data.payload.recipes)
        end
    end

end


function Comms:CHARACTER_TRADESKILLS_INFO_UPDATE(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "error CHARACTER_TRADESKILLS_INFO_UPDATE", "data is not a table", data)
        return;
    end

    if data.senderGUID and type(data.payload) == "table" then
        for k, v in pairs(data.payload) do
            Database:UpdateCharacterTable(data.senderGUID, k, v)
        end
    end

end



function Comms:CHARACTER_TALENTS_INFO_UPDATE(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "error CHARACTER_TALENTS_INFO_UPDATE", "data is not a table", data)
        return;
    end

    if data.senderGUID then
        Database:UpdateCharacterTable(data.senderGUID, "Talents", data.payload.talents)
        Database:UpdateCharacterTable(data.senderGUID, "TalentTabs", data.payload.talentTabs)
    end

end



function Comms:CHARACTER_INVENTORY_INFO_UPDATE(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "error CHARACTER_INVENTORY_INFO_UPDATE", "data is not a table", data)
        return;
    end

    if data.senderGUID then
        Database:UpdateCharacterTable(data.senderGUID, "Inventory", data.payload.inventory)
    end

end



function Comms:PLAYER_CHARACTER_UPDATE(data)

    if type(data) ~= "table" then
        Guildbook.DEBUG('commsMixin', "error PLAYER_CHARACTER_UPDATE", "data is not a table", data)
        return;
    end

    if data.senderGUID and type(data.payload) == "table" then
        for k, v in pairs(data.payload) do
            if type(k) == "string" then
                Database:UpdateCharacterTable(data.senderGUID, k, v)
            else
                Guildbook.DEBUG('commsMixin', "error PLAYER_CHARACTER_UPDATE", "updating db, key is not a string value", {
                    ["key"] = k,
                    ["value"] = v,
                })
            end
        end
    end

end




































































--init, this sets the saved var stuff
--pew, this will trigger a guild roster scan, this creates the db entries for each character and checks them for errors
--load, if the roster scan is successful this will be called and continue loading the addon, this will scan the client character for prof info etc

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init, this will setup the saved variables first
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Init()
    -- get this open first if debug is on
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
    AceComm:Embed(self)
    self:RegisterComm('Guildbook', 'ON_COMMS_RECEIVED')

    -- this enables us to prevent character model capturing until the player is fully loaded
    Guildbook.LoadTime = GetTime()
    Guildbook.DEBUG('func', 'init', tostring('Load time '..date("%T")))

    -- grab version number
    self.version = tonumber(GetAddOnMetadata('Guildbook', "Version"))
    self:SendVersionData()

    -- this makes the bank/calendar legacy features work
    if not self.GuildFrame then
        self.GuildFrame = {
            --"GuildBankFrame",
            "GuildCalendarFrame",
        }
    end
    --self:SetupGuildBankFrame()
    self:SetupGuildCalendarFrame()

    --create stored variable tables
    if GUILDBOOK_GLOBAL == nil or GUILDBOOK_GLOBAL == {} then
        GUILDBOOK_GLOBAL = self.Data.DefaultGlobalSettings
        Guildbook.DEBUG('func', 'init', 'created global saved variable table')
    else
        Guildbook.DEBUG('func', 'init', 'global variables exists')
    end
    if GUILDBOOK_CHARACTER == nil or GUILDBOOK_CHARACTER == {} then
        GUILDBOOK_CHARACTER = self.Data.DefaultCharacterSettings
        Guildbook.DEBUG('func', 'init', 'created character saved variable table')
    else
        Guildbook.DEBUG('func', 'init', 'character variables exists')
    end
    if not GUILDBOOK_GLOBAL.GuildRosterCache then
        GUILDBOOK_GLOBAL.GuildRosterCache = {}
        Guildbook.DEBUG('func', 'init', 'created guild roster cache')
    else
        Guildbook.DEBUG('func', 'init', 'guild roster cache exists')
    end
    if not GUILDBOOK_GLOBAL.Calendar then
        GUILDBOOK_GLOBAL.Calendar = {}
        Guildbook.DEBUG('func', 'init', 'created global calendar table')
    else
        Guildbook.DEBUG('func', 'init', 'global calendar table exists')
    end
    if not GUILDBOOK_GLOBAL.CalendarDeleted then
        GUILDBOOK_GLOBAL.CalendarDeleted = {}
        Guildbook.DEBUG('func', 'init', 'created global calendar deleted events table')
    else
        Guildbook.DEBUG('func', 'init', 'global calendar deleted events table exists')
    end
    if not GUILDBOOK_GLOBAL.LastCalendarTransmit then
        GUILDBOOK_GLOBAL.LastCalendarTransmit = GetServerTime()
    end
    if not GUILDBOOK_GLOBAL.LastCalendarDeletedTransmit then
        GUILDBOOK_GLOBAL.LastCalendarDeletedTransmit = GetServerTime()
    end

    if not GUILDBOOK_GLOBAL.myCharacters then
        GUILDBOOK_GLOBAL.myCharacters = {}
    end
    if not GUILDBOOK_GLOBAL.myCharacters[UnitGUID("player")] then
        GUILDBOOK_GLOBAL.myCharacters[UnitGUID("player")] = false;
    end
    if not GUILDBOOK_GLOBAL.myLockouts then
        GUILDBOOK_GLOBAL.myLockouts = {}
    end

    if not GUILDBOOK_GLOBAL['CommsDelay'] then
        GUILDBOOK_GLOBAL['CommsDelay'] = 1.0
    end
    Guildbook.CommsDelaySlider:SetValue(GUILDBOOK_GLOBAL['CommsDelay'])
    self.COMMS_DELAY = GUILDBOOK_GLOBAL['CommsDelay']

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
                                        self:AddLine(Guildbook.ContextMenu_Separator_Wide)
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
                        self:AddLine(Guildbook.ContextMenu_Separator_Wide)
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
            local character = Guildbook:GetCharacterFromCache(guid)
            if not character then
                return;
            end
            self:AddLine(" ")
            self:AddLine('Guildbook:', 0.00, 0.44, 0.87, 1)
            if GUILDBOOK_GLOBAL.config.showTooltipMainSpec == true then
                if character.MainSpec then
                    local icon = Guildbook:GetClassSpecAtlasName(character.Class, character.MainSpec)
                    local iconString = CreateAtlasMarkup(icon, 24,24)
                    self:AddLine(iconString.. "  |cffffffff"..character.MainSpec)
                end
            end
            if GUILDBOOK_GLOBAL.config.showTooltipProfessions == true then
                if character.Profession1 ~= '-' and Guildbook.Data.Profession[character.Profession1] then
                    self:AddDoubleLine(character.Profession1, character.Profession1Level, 1,1,1,1,1,1,1,1)
                end
                if character.Profession2 ~= '-' and Guildbook.Data.Profession[character.Profession2] then
                    self:AddDoubleLine(character.Profession2, character.Profession2Level, 1,1,1,1,1,1,1,1)
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
                        C_Timer.After(0.1, function()
                            self:AppendText(" ["..Guildbook.Colours[main.Class]:WrapTextInColorCode(main.Name).."]")
                        end)
                    end
                end
            end
        end
    end)
end




function Guildbook:PLAYER_ENTERING_WORLD()

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
    -- store some info, used for character models, faction textures etc
    self.player = {
        faction = nil,
        race = nil,
    }
    C_Timer.After(1.0, function()
        if not Guildbook.PlayerMixin then
            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(UnitGUID('player'))
        else
            Guildbook.PlayerMixin:SetGUID(UnitGUID('player'))
        end
        if Guildbook.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
            -- double check mixin
            if not name then
                return
            end
            local raceID = C_PlayerInfo.GetRace(Guildbook.PlayerMixin)
            self.player.race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:upper()
            self.player.faction = C_CreatureInfo.GetFactionInfo(raceID).groupTag
        end
    end)
    GuildRoster() -- this will trigger a roster scan but we set addonLoaded as false at top of file to skip the auto roster scan so this is first scan
    C_Timer.After(3.0, function()
        local guildName = self:GetGuildName()
        if not guildName then
            Guildbook.DEBUG("event", "PEW", "not in a guild or no guild name")
            return -- if not in a guild just exit for now, all saved vars have been created and the player race/faction stored for the session
        end
        self:ScanGuildRoster(function()
            Guildbook:Load() -- once the roster has been scanned continue to load, its a bit meh but it means we get a full roster scan before loading
        end)
    end)
    self.EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end



--[[
    working on reducing the chat spam i've noticed during the addon loading

    so far ive adjust the character data by removing profession info
    talents no longer send updates as this broke privacy rules
]]
function Guildbook:Load()
    Guildbook.DEBUG("func", "Load", "loading addon")

    -- this will make sure rank changes are handled, just set any privacy rule to the lowest rank if its wrong
    self:CheckPrivacyRankSettings()


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
                if GuildbookUI then
                    if GuildbookUI:IsVisible() then
                        GuildbookUI:Hide()
                    else
                        GuildbookUI:Show()
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
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('BOTTOMRIGHT', GuildbookUI.calendar, 'BOTTOMRIGHT', 254, 0)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            local now = date('*t')
            tooltip:AddLine('Guildbook')
            tooltip:AddLine(string.format("%s %s %s", now.day, Guildbook.Data.Months[now.month], now.year), 1,1,1,1)
            tooltip:AddLine(L["MINIMAP_CALENDAR_RIGHTCLICK"], 0.1, 0.58, 0.92, 1)
            -- get events for next 7 days
            local upcomingEvents = Guildbook:GetCalendarEvents(time(now), 7)
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
            text = L["CHAT"],
            func = function()
                GuildbookUI:OpenTo("chat")
            end,
        },
        {
            text = L["ROSTER"],
            func = function()
                GuildbookUI:OpenTo("roster")
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

    ---initiate the tradeskill recipe/item request process - this isnt a great method and i plan to change this by using another addon to hold the data
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

    ---request calendar data, using a 4s stagger to allow all comms to send
    C_Timer.After(2, function()
        Guildbook:SendGuildCalendarEvents()
        Guildbook.DEBUG("func", "Load", "send calendar events")
    end)
    C_Timer.After(6, function()
        Guildbook:SendGuildCalendarDeletedEvents()
        Guildbook.DEBUG("func", "Load", "send deleted calendar events")
    end)
    C_Timer.After(10, function()
        Guildbook:RequestGuildCalendarEvents()
        Guildbook.DEBUG("func", "Load", "requested calendar events")
    end)
    C_Timer.After(14, function()
        Guildbook:RequestGuildCalendarDeletedEvents()
        Guildbook.DEBUG("func", "Load", "requested deleted calendar events")
    end)

    if GUILDBOOK_GLOBAL.showUpdateNews == nil then
        GUILDBOOK_GLOBAL.showUpdateNews = true;
    end
    if GUILDBOOK_GLOBAL.showUpdateNews == true then
        StaticPopup_Show('GuildbookUpdates', self.version)
    end

    self.addonLoaded = true
    self.GUILD_NAME = self:GetGuildName()


    --GUILDBOOK_GLOBAL.guildBankRemoved = nil

    -- quick clean up
    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems then
        for _, recipe in pairs(GUILDBOOK_TSDB.enchantItems) do
            recipe.charactersWithRecipe = nil
        end
    end
    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems then
        for _, recipe in pairs(GUILDBOOK_TSDB.recipeItems) do
            recipe.charactersWithRecipe = nil
        end
    end



    Database:Init()
    Character:Init()
    Comms:Init()


end






-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---return the localized name of a profession
---@param prof string the profession to localize
---@return any
function Guildbook:GetLocaleProf(prof)
    for id, name in pairs(self.ProfessionNames["enUS"]) do
        if name == prof then
            return self.ProfessionNames[locale][id]
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
    if GUILDBOOK_GLOBAL.config.showInfoMessages == true then
        print(string.format('[%sGuildbook|r] %s', Guildbook.FONT_COLOUR, msg))
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
    local today = date('*t')
    local finish = (time(today) + (60*60*24*duration))
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['Calendar'] and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            --local eventTimeStamp = time(event.date)
                if time(event.date) >= start and time(event.date) <= finish then
                    table.insert(events, event)
                    Guildbook.DEBUG('func', 'Guildbook:GetCalendarEvents', 'found: '..event.title)
                end
            --end
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

---update the character table in the account wide saved variables
---@param guid string the characters GUID
---@param key string key to update
---@param value any new value
function Guildbook:SetCharacterInfo(guid, key, value)
    if guid:find('Player') then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
                GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] = self.Data.DefaultCharacterSettings
                Guildbook.DEBUG("db_func", "SetCharacterInfo", string.format("created new db entry for %s", guid))
            end
            local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
            character[key] = value;
            Guildbook.DEBUG("db_func", "SetCharacterInfo", string.format("updated %s for %s", key, (character.Name and character.Name or guid)))
        end
    end
end

---fetch character info using guid and key
---@param guid string the characters GUID
---@param key string the key to fetch
---@return any
function Guildbook:GetCharacterInfo(guid, key)
    if guid:find('Player') then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
            return GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid][key];
        end
    end
    return false;
end


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

---generate a serialize string of guild members recipes using tradeskill and recipeID as keys to reduce size. the serialized table is t[prof][recipeID] = {reagents={}, characters={guid1, guid2}}
---@return string encoded a serialized, compressed and encoded table suitable for displaying
function Guildbook:SerializeGuildTradeskillRecipes()
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


function Guildbook:CheckPrivacyRankSettings()
    local ranks = {}
    for i = 1, GuildControlGetNumRanks() do
        ranks[GuildControlGetRankName(i)] = i;
    end
    local lowestRank = GuildControlGetRankName(GuildControlGetNumRanks())
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.config and GUILDBOOK_GLOBAL.config.privacy then
        for rule, rank in pairs(GUILDBOOK_GLOBAL.config.privacy) do
            if not ranks[rank] then
                if rank == "none" then
                    
                else
                    -- set the rank to lowest, this is to cover times where a rank is deleted
                    GUILDBOOK_GLOBAL.config.privacy[rule] = lowestRank
                    Guildbook.DEBUG("func", "CheckPrivacyRankSettings", string.format("changed rank: %s to lowest rank (%s)", rank, lowestRank))
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
                    if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] then
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = count
                    else
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] + count
                    end
                end
            end
        end

        -- main bank
        for slot = 1, 28 do
            local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(-1, slot)
            if id and count then
                if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] then
                    GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = count
                else
                    GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] + count
                end
            end
        end

        -- bank bags
        for bag = 5, 11 do
            for slot = 1, GetContainerNumSlots(bag) do
                local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
                if id and count then
                    if not GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] then
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = count
                    else
                        GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][guid].Data[id] + count
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

    -- a lookup table to use for finding an tradeskill from the main table { [recipeID] = key }
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
    end
    
    local statusBar = GuildbookUI.tradeskills.statusBar
    statusBar:SetValue(0)
    statusBar:Show()
    local statusBarText = GuildbookUI.tradeskills.statusBarText
    statusBarText:SetText("Loading...")
    statusBarText:Show()

    if #recipeIdsToQuery > 0 then
        local startTime = time();
        self:PrintMessage(string.format("found %s recipes, estimated duration %s", #recipeIdsToQuery, SecondsToTime(#recipeIdsToQuery*delay)))
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
                            expsanion = expansion,
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
                        expsanion = expansion,
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

                self:PrintMessage(string.format("all tradeskill recipes processed, took %s", SecondsToTime(time()-startTime)))
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
        GuildbookUI.statusText:SetText(string.format("starting roster scan at %s:%s:%s", start.hour, start.min, start.sec))
        self.scanRosterTicker = C_Timer.NewTicker(0.0001, function()
            local percent = (i/totalMembers) * 100
            GuildbookUI.statusText:SetText(string.format("roster scan %s%%",string.format("%.1f", percent)))
            GuildbookUI.statusBar:SetValue(i/totalMembers)
            if not currentGUIDs[i] then
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
                        --info.FullName = string.format("%s-%s", name, realm)
                        
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
                GuildbookUI.statusText:SetText(string.format("finished roster scan, took %s, %s new characters, removed %s characters from db", SecondsToTime(finished), (#newGUIDs or 0), removedCount))
                C_Timer.After(0.05, function()
                    if GuildbookUI then
                        GuildbookUI.roster:ParseGuildRoster()
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

--- get the players current talents
-- as there is no dual spec for now we just default to using talents[1] and updating Talents.Current
-- when dual spec arrives we will have to adjust this
function Guildbook:GetCharacterTalentInfo(activeTalents)
    if GUILDBOOK_CHARACTER then
        if not GUILDBOOK_CHARACTER['Talents'] then
            GUILDBOOK_CHARACTER['Talents'] = {}
        end
        --wipe(GUILDBOOK_CHARACTER['Talents'])
        GUILDBOOK_CHARACTER['Talents'][activeTalents] = {}
        -- will need dual spec set up for wrath
        local tabs = {}
        for tabIndex = 1, GetNumTalentTabs() do
            local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
            local engSpec = Guildbook.Data.TalentBackgroundToSpec[fileName]
            table.insert(tabs, {points = pointsSpent, spec = engSpec})
            for talentIndex = 1, GetNumTalents(tabIndex) do
                local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
                table.insert(GUILDBOOK_CHARACTER['Talents'][activeTalents], {
                    Tab = tabIndex,
                    Row = row,
                    Col = column,
                    Rank = rank,
                    MxRnk = maxRank,
                    Icon = iconTexture,
                    Name = name,
                    Index = talentIndex,
                    Link = GetTalentLink(tabIndex, talentIndex),
                })
            end
        end
        table.sort(tabs, function(a,b)
            return a.points > b.points
        end)
        if GUILDBOOK_CHARACTER.smartGuessMainSpec then
            GUILDBOOK_CHARACTER.MainSpec = tabs[1].spec
        end
        self:SetCharacterInfo(UnitGUID("player"), "Talents", GUILDBOOK_CHARACTER.Talents)

        --- to avoid breaking the privacy rules this must only be sent when requested
        -- self:DB_SendCharacterData(UnitGUID("player"), "MainSpec", GUILDBOOK_CHARACTER.MainSpec, "GUILD", nil, "NORMAL")
        -- self:DB_SendCharacterData(UnitGUID("player"), "Talents", GUILDBOOK_CHARACTER.Talents, "GUILD", nil, "NORMAL")
    end
end





function Guildbook:GetGuildMemberGUID(player)
    GuildRoster()
    local guildName = Guildbook:GetGuildName()
    if guildName then
        local totalMembers, _, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
            if name == player then
                return GUID;
            end
        end
    end
    return false;
end












-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
    changes 4.98

    to make the adon work for connected realms this function was changed to take a targetGUID instead of a target name
    using a guid we can fetch the character info from the addons guild roster cache
    this info will contain name, realm and fullName fields which can be used to send the message

    functions that call Guildbook:Transmit will need to be adjusted to pass in the targetGUID
    no errors will be thrown as the function will check for a valid character from the cache before attempting to send
    this change only effects calls that use the WHISPER channel any calls using the GUILD channel will be uneffected
]]

---send an addon message through the aceComm lib
---@param data table the data to send including a comm type
---@param channel string the addon channel to use for the comm
---@param targetGUID string the targets GUID, this is used to make comms work on conneted realms - only required for WHISPER comms
---@param priority string the prio to use
function Guildbook:Transmit(data, channel, targetGUID, priority)


    ---until i go through everything, for now im going to just redirct to the comms class
    --Comms:Transmit(data, channel, targetGUID, priority)
    --if 1 == 1 then return end




    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in combat")
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
    if channel == 'WHISPER' then

        --find character first before looping roster
        local character = self:GetCharacterFromCache(targetGUID)
        local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(targetGUID)

        if name and realm then
            local target = realm ~= "" and string.format("%s-%s", name, realm) or name;

            local totalMembers, _, _ = GetNumGuildMembers()
            for i = 1, totalMembers do
                local name, rankName, _, _, _, _, _, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)

                -- i think we can move the privacy check in here using the rankName value to work out if we share with the target
                -- we can then also have a central place to send a privacy error message to the target

                if guid == targetGUID then
                    if isOnline == true then
                        local serialized = LibSerialize:Serialize(data);
                        local compressed = LibDeflate:CompressDeflate(serialized);
                        local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
                    
                        if addonName and encoded and channel and priority then
                            Guildbook.DEBUG('comms_out', 'SendCommMessage_TargetOnline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority), data)
                            self:SendCommMessage(addonName, encoded, channel, target, priority)
                        end
                    else
                        Guildbook.DEBUG('error', 'SendCommMessage_TargetOffline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
                    end
                    return; --no need to keep checking the roster at this point
                end
            end
        end

    elseif channel == "GUILD" then
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

function Guildbook:SendVersionData()
    if not self.version then
        return
    end
    local version = {
        type = "VERSION_INFO",
        payload = self.version,
    }
    --self:Transmit(version, "GUILD", nil, "NORMAL")
end

local versionsChecked = {}
function Guildbook:OnVersionInfoRecieved(data, distribution, sender)
    -- we dont care about our own version check
    if data.senderGUID == UnitGUID("player") then
        return;
    end
    if data.payload then
        if tonumber(self.version) < tonumber(data.payload) then
            if not versionsChecked[data.payload] then -- if we havent seen this version number then inform the player
                local msgID = math.random(4)
                print(string.format('[%sGuildbook|r] %s', Guildbook.FONT_COLOUR, L["NEW_VERSION_"..msgID]))
                versionsChecked[data.payload] = true;
            end            
        elseif tonumber(self.version) > tonumber(data.payload) then
            self:SendVersionData() -- if our version is newer send it back to inform the player
        end
    end
    -- the idea here is to update characters when they come online, allowing 30s means the player logging on has time for addons to load up
    -- the issue is however, they might log off before 30s which results in the 'No playername ...' system messages
    -- TODO: revise this system and improve

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- send anything comms
--[[
    the idea of this set of comms is to create a more universal method of sending data
    it will be using the newer roster cache get/set functions
    it allows the addon to send a specific key/value
]]
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---send a request for character data
---@param guid string the guid for the character
---@param key string the key for the data requested
---@param channel string should be WHISPER for almost all requests
---@param target string the characters name you are whispering
---@param priority string should be NORMAL for almost all requests
function Guildbook:DB_RequestCharacterData(guid, key, channel, target, priority)
    if not guid then
        return
    end
    local transmition = {
        type = "DB_GET",
        payload = {
            guid = guid,
            key = key,
        }
    }
    if type(channel) ~= "string" then
        channel = "WHISPER";
    end
    self:Transmit(transmition, channel, guid, priority)
end

function Guildbook:DB_OnDataRequest(data, distribution, sender)
    if not data then
        return;
    end
    if distribution ~= "WHISPER" then
        return;
    end
    if data.type == "DB_GET" then
        if (type(data.payload.guid) == "string") and (data.payload.guid == UnitGUID("player")) then
            if GUILDBOOK_CHARACTER and (type(data.payload.key) == "string") and (GUILDBOOK_CHARACTER[data.payload.key]) then
                self:DB_SendCharacterData(UnitGUID("player"), data.payload.key, GUILDBOOK_CHARACTER[data.payload.key], "WHISPER", data.senderGUID, "NORMAL")
            else

            end
        end
    end
end

function Guildbook:DB_SendCharacterData(guid, key, info, channel, target, priority)
    if not guid then
        return
    end
    if type(key) ~= "string" then
        return
    end
    local transmition = {
        type = "DB_SET",
        payload = {
            guid = guid,
            key = key,
            info = info,
        }
    }
    self:Transmit(transmition, channel, target, priority)
end


function Guildbook:DB_OnDataReceived(data, distribution, sender)
    if not data then
        return;
    end
    if not data.payload then
        return;
    end
    if type(data.payload.key) ~= "string" then
        return;
    end
    if data.payload.guid and data.payload.info then
        Guildbook.DEBUG("db_func", "DB_OnDataReceived", string.format("received %s info from %s", data.payload.key, sender), data)
        self:SetCharacterInfo(data.payload.guid, data.payload.key, data.payload.info)
    end

    --for new users, the addon will have scanned their professions but because there would be no data during the load for this function to loop the key mapping wouldnt be complete
    --so if we get tradeskill data call the function, it only makes requests where data is missing so will skip repeated requests
    --need to sort out some callbacks but for now we check if the key was a profession and if so request data
    --this function will only request data for recipes where data hasnt been requested


    if Guildbook.Data.Profession[data.payload.key] then
        Guildbook.DEBUG('db_func', 'DB_OnDataReceived', string.format("received data for %s, calling function > RequestTradeskillData", data.payload.key))
        self:RequestTradeskillData()

        local guid, prof = data.payload.guid, data.payload.key;

        C_Timer.After(self.COMMS_DELAY, function()
            if GuildbookUI.tradeskills.awaitingCharacterRecipes == true then
                GuildbookTradeskillProfessionListview:LoadCharacterTradeskillRecipes(guid, prof)
                GuildbookUI.tradeskills.awaitingCharacterRecipes = false;
            end    
        end)
    end

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

















































-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- tradeskills comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendTradeSkillsRequest(target, profession)
    local request = {
        type = "TRADESKILLS_REQUEST",
        payload = profession,
    }
    self:Transmit(request, "WHISPER", target, "NORMAL")
end

function Guildbook:OnTradeSkillsRequested(request, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER[request.payload] then
        local response = {
            type    = "TRADESKILLS_RESPONSE",
            payload = {
                profession = request.payload,
                recipes = GUILDBOOK_CHARACTER[request.payload],
            }
        }
        self:Transmit(response, 'GUILD', nil, "BULK")
    end
end

function Guildbook:SendTradeskillData(guid, recipes, prof, channel, target)
    local response = {
        type    = "TRADESKILLS_RESPONSE",
        payload = {
            guid = guid,
            profession = prof,
            recipes = recipes,
        }
    }
    self:Transmit(response, channel, target, "BULK")
end



function Guildbook:OnTradeSkillsReceived(response, distribution, sender)
    --Guildbook.DEBUG('comms_in', 'OnTradeSkillsReceived', string.format("prof data from %s", sender))
    if response.payload.profession and type(response.payload.recipes) == 'table' then
        C_Timer.After(Guildbook.COMMS_DELAY, function()
            local character;
            if response.payload.guid then
                character = self:GetCharacterFromCache(response.payload.guid)
            else
                character = self:GetCharacterFromCache(response.senderGUID)
            end
            if not character then
                return
            end
            local prof = response.payload.profession
            if not prof then
                return
            end
            if type(prof) ~= "string" then
                return
            end
            Guildbook.DEBUG("func", "OnTradeSkillsReceived", string.format("received %s data from %s", prof, sender))

            --set the recipes, changed this to just set what is received to reflect the current recpes
            character[prof] = response.payload.recipes
            Guildbook.DEBUG("func", "OnTradeSkillsReceived", string.format("created or reset table for %s", prof))

            --character[response.payload.profession] = response.payload.recipes
            GuildbookUI.statusText:SetText(string.format("%s data for [|cffffffff%s|r] sent by %s", prof, character.Name, sender))
            Guildbook.DEBUG('func', 'OnTradeSkillsReceived', 'updating db, set: '..character.Name..' prof: '..response.payload.profession)
            C_Timer.After(1, function()
                self:RequestTradeskillData()
            end)
        end)
    end
end









-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
        Guildbook.DEBUG("func", "RequestGuildBankCommits", string.format("request guild bank commits for %s", character.Name))
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
            Guildbook.DEBUG('comms_out', 'OnGuildBankCommitRequested', string.format("%s has requested guild bank commits for %s", sender, data.bankCharactersName))
            self:Transmit(response, 'WHISPER', data.senderGUID, 'NORMAL')
        end
    end
end

-- use the new table
local lastCommitResponse = -1000;
function Guildbook:OnGuildBankCommitReceived(data, distribution, sender)
    if distribution == 'WHISPER' then
        lastCommitResponse = GetTime()
        Guildbook.DEBUG("func", "OnGuildBankCommitReceived", string.format("sender: %s commit time: %s", sender, data.payload.Commit))

        --data.payload.CharacterGUID is the actual bank character
        --data.senderGUID is the player with the latest commit for the bank character

        ---if we have no data for this characterGUID then just save the commit
        if not self.BankCharacters[data.payload.CharacterGUID].Commit then
            self.BankCharacters[data.payload.CharacterGUID].Commit = data.payload.Commit;
            self.BankCharacters[data.payload.CharacterGUID].Source = data.senderGUID;
            Guildbook.DEBUG("func", "OnGuildBankCommitReceived", string.format("%s has latest commit time", sender))

        ---if we do have data we want to check if this commit is newer and if so then save it
        else
            if tonumber(data.payload.Commit) > tonumber(self.BankCharacters[data.payload.CharacterGUID].Commit) then
                self.BankCharacters[data.payload.CharacterGUID].Commit = data.payload.Commit;
                self.BankCharacters[data.payload.CharacterGUID].Source = data.senderGUID;
                Guildbook.DEBUG("func", "OnGuildBankCommitReceived", string.format("%s has latest commit time", sender))
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
    Guildbook.DEBUG('comms_out', 'RequestGuildBankItems', string.format("requesting guild bank items from %s", source))
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
        Guildbook.DEBUG('comms_out', 'OnGuildBankDataRequested', string.format('%s has requested bank data, sending data for bank character %s', sender, data.payload))
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
            GUILDBOOK_GLOBAL["GuildBank"][data.payload.Bank] = {
                Commit = data.payload.Commit,
                Data = data.payload.Data,
                Money = data.payload.Money,
            }
        end
    end
    -- self.GuildFrame.GuildBankFrame:ProcessBankData(data.payload.Data, data.payload.Money)
    -- self.GuildFrame.GuildBankFrame:RefreshSlots()

    -- how do we know the timing of all this????
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
                Guildbook.DEBUG('func', 'OnGuildCalendarEventCreated', 'this event already exists in your db')
            end
        end
        if exists == false then
            table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], data.payload)
            Guildbook.DEBUG('func', 'OnGuildCalendarEventCreated', string.format('Received guild calendar event, title: %s', data.payload.title))
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
    Guildbook.DEBUG('func', 'SendGuildCalendarEventAttend', string.format('Sending calendar event attend update to guild, event title: %s, attend: %s', event.title, attend))
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
                Guildbook.DEBUG('func', 'OnGuildCalendarEventAttendReceived', string.format('Updated event %s: %s has set attending to %s', v.title, sender, data.payload.a))
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
    Guildbook.DEBUG('func', 'SendGuildCalendarEventDeleted', string.format('Guild calendar event deleted, event title: %s', event.title))
    self:Transmit(calendarEventDeleted, 'GUILD', nil, 'NORMAL')
end

function Guildbook:OnGuildCalendarEventDeleted(data, distribution, sender)
    self.GuildFrame.GuildCalendarFrame.EventFrame:RegisterEventDeleted(data.payload)
    Guildbook.DEBUG('func', 'OnGuildCalendarEventDeleted', string.format('Guild calendar event %s has been deleted', data.payload.title))
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
                    Guildbook.DEBUG("func", 'SendGuildCalendarEvents', "event has no date table "..event.title)
                else
                    if event.date.month >= today.month and event.date.year >= today.year and event.date.month <= future.month and event.date.year <= future.year then
                        table.insert(events, event)
                        Guildbook.DEBUG('func', 'SendGuildCalendarEvents', string.format('Added event: %s to transmit table', event.title))
                    end
                end
            end
            local calendarEvents = {
                type = 'GUILD_CALENDAR_EVENTS',
                payload = events,
            }
            self:Transmit(calendarEvents, 'GUILD', nil, 'BULK')
            Guildbook.DEBUG('func', 'SendGuildCalendarEvents', string.format('range=%s-%s-%s to %s-%s-%s', today.day, today.month, today.year, future.day, future.month, future.year))
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
            Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('Received event: %s', recievedEvent.title))
            local exists = false
            -- loop our db for a match
            for _, dbEvent in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if dbEvent.created == recievedEvent.created and dbEvent.owner == recievedEvent.owner then
                    exists = true
                    Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', 'event exists!')
                    -- loop the db events for attending guid
                    for guid, info in pairs(dbEvent.attend) do
                        local name;
                        if not Guildbook.PlayerMixin then
                            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                        else
                            Guildbook.PlayerMixin:SetGUID(guid)
                        end
                        if Guildbook.PlayerMixin:IsValid() then
                            name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                        end
                        if not name then
                            name = '[unknown name]'
                        end
                        -- is there a matching guid 
                        if recievedEvent.attend and recievedEvent.attend[guid] then
                            if tonumber(info.Updated) < tonumber(recievedEvent.attend[guid].Updated) then
                                info.Status = recievedEvent.attend[guid].Status
                                info.Updated = recievedEvent.attend[guid].Updated
                                Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("updated %s attend status for %s", name, dbEvent.title))
                            end
                        else
                            Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("%s wasn't in the sent event attending data", name))
                        end
                    end
                    -- loop the recieved event attending table and add any missing players
                    for guid, info in pairs(recievedEvent.attend) do
                        local name = '-'
                        if not Guildbook.PlayerMixin then
                            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                        else
                            Guildbook.PlayerMixin:SetGUID(guid)
                        end
                        if Guildbook.PlayerMixin:IsValid() then
                            name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                        end
                        if not dbEvent.attend[guid] then
                            dbEvent.attend[guid] = {}
                            dbEvent.attend[guid].Updated = GetServerTime()
                            dbEvent.attend[guid].Status = info.Status
                            Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("added %s attend status for %s", name, dbEvent.title))
                        end
                    end
                end
            end
            if exists == false then
                table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], recievedEvent)
                Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('This event is a new event, adding to db: %s', recievedEvent.title))
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
            Guildbook.DEBUG('func', 'SendGuildCalendarDeletedEvents', 'Sending deleted calendar events to guild')
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
                Guildbook.DEBUG('func', 'OnGuildCalendarEventsDeleted', 'Added event to deleted table')
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
    Guildbook.DEBUG('func', 'OnGuildCalendarEventUpdated', string.format("%s has updated the event %s", sender, data.payload.title))
end











-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- events
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:ADDON_LOADED(...)
    if tostring(...):lower() == addonName:lower() then
        self:Init()
    end
end

function Guildbook:UPDATE_MOUSEOVER_UNIT()
    -- delay any model loading while players addons sort themselves out
    if Guildbook.LoadTime and Guildbook.LoadTime + 8.0 > GetTime() then
        return
    end
    local guid = UnitGUID('mouseover')
    if guid and guid:find('Player') then
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
            if race and self.player and self.player.faction == C_CreatureInfo.GetFactionInfo(raceID).groupTag then
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
    if not Guildbook.PlayerMixin then
        Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        Guildbook.PlayerMixin:SetGUID(guid)
    end
    if Guildbook.PlayerMixin:IsValid() then
        local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
        if class then
            if not Guildbook.GuildChatLog then
                Guildbook.GuildChatLog = {}
            end
            GuildbookUI.chat:AddGuildChatMessage({
                formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[class].FontColour, sender, msg),
                sender = sender,
                target = "guild",
                message = msg,
                chatID = guid,
                senderGUID = guid,
            })
        end
    end
end

function Guildbook:CHAT_MSG_WHISPER(...)
    local msg, sender, _, _, _, _, _, _, _, _, _, guid = ...
    -- local msg = select(1, ...)
    -- local sender = select(2, ...)
    -- local guid = select(12, ...) -- sender guid
    sender = Ambiguate(sender, "none")
    if not Guildbook.PlayerMixin then
        Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        Guildbook.PlayerMixin:SetGUID(guid)
    end
    if Guildbook.PlayerMixin:IsValid() then
        local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
        if class then
            GuildbookUI.chat:AddChatMessage({
                formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[class].FontColour, sender, msg),
                sender = sender,
                target = Ambiguate(UnitName("player"), "none"),
                message = msg,
                chatID = guid,
                senderGUID = guid,
            })
        end
    end
end

function Guildbook:CHAT_MSG_SYSTEM(...)
    local msg = ...
    local joinedGuild = ERR_GUILD_JOIN_S:gsub("%%s", ".*")
    if msg:find(joinedGuild) then
        local name, _ = strsplit(" ", msg)
        if Ambiguate(name, "none") ~= Ambiguate(UnitName("player"), "none") then
            return;
        end
        Guildbook.DEBUG("event", "CHAT_MSG_SYSTEM", "player joined a guild")
        C_Timer.After(3.0, function()
            GuildRoster() -- this will trigger a roster scan but we set addonLoaded as false at top of file to skip the auto roster scan so this is first scan
            C_Timer.After(1.5, function()
                self:ScanGuildRoster(function()
                    Guildbook:Load() -- once the roster has been scanned continue to load, its a bit meh but it means we get a full roster scan before loading
                end)
            end)
        end)
    end
end

function Guildbook:GUILD_ROSTER_UPDATE(...)
    if self.addonLoaded == false then
        return;
    end
    C_Timer.After(0.1, function()
        self:ScanGuildRoster()
    end)
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




--- handle comms
function Guildbook:ON_COMMS_RECEIVED(prefix, message, distribution, sender)

    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in combat")
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

    if data.type == "DB_SET" then
        self:DB_OnDataReceived(data, distribution, sender)

    elseif data.type == "DB_GET" then
        self:DB_OnDataRequest(data, distribution, sender)

    -- tradeskills
    elseif data.type == "TRADESKILLS_REQUEST" then
        self:OnTradeSkillsRequested(data, distribution, sender)

    elseif data.type == "TRADESKILLS_RESPONSE" then
        self:OnTradeSkillsReceived(data, distribution, sender);


    -- privacy
    elseif data.type == "PRIVACY_INFO" then
        self:OnPrivacyReceived(data, distribution, sender)

    elseif data.type == "PRIVACY_ERROR" then
        self:OnPrivacyError(tonumber(data.payload), sender)

    elseif data.type == "VERSION_INFO" then
        self:OnVersionInfoRecieved(data, distribution, sender)




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

function Guildbook:GUILD_INVITE_REQUEST(...)
    local _, guildName = ...
end

--set up event listener

--TODO: these will slowly be removed and stuff moved into 'classes' so to speak, leaving a lot of code in for now as somethign will likely go wrong
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('GUILD_INVITE_REQUEST')
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_OPENED')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_CLOSED')
Guildbook.EventFrame:RegisterEvent('BAG_UPDATE_DELAYED')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_GUILD')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_WHISPER')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_SYSTEM')
Guildbook.EventFrame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    if Guildbook[event] then
        Guildbook[event](Guildbook, ...)
    end
end)
