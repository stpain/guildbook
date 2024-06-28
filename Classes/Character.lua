

local _, addon = ...;

local Database = addon.Database;
local Character = {};
local Tradeskills = addon.Tradeskills;
local L = addon.Locales;


--will use a specID as found from spellbook tabs-1 (ignore general) and then get the spec name from this table
--for display the name value can be used to grab the locale
local classData = {
    DEATHKNIGHT = { 
        specializations={'Blood','Frost','Unholy'} 
    },
    ["DEATH KNIGHT"] = { 
        specializations={'Blood','Frost','Unholy'} 
    },
    DRUID = { 
        specializations={'Balance', 'Cat' ,'Bear', 'Restoration',}
    },
    HUNTER = { 
        specializations={'Beast Master', 'Marksmanship','Survival',} 
    },
    MAGE = { 
        specializations={'Arcane', 'Fire','Frost',} 
    },
    PALADIN = { 
        specializations={'Holy','Protection','Retribution',} 
    },
    PRIEST = { 
        specializations={'Discipline','Holy','Shadow',} 
    },
    ROGUE = { 
        specializations={'Assassination','Combat','Subtlety',} -- outlaw = combat
    },
    SHAMAN = { 
        specializations={'Elemental', 'Enhancement', 'Restoration'} 
    },
    WARLOCK = {  
        specializations={'Affliction','Demonology','Destruction',} 
    },
    WARRIOR = { 
        specializations={'Arms','Fury','Protection',} 
    },
}

local raceFileStringToId = {
    Human = 1,
    Orc = 2,
    Dwarf = 3,
    NightElf = 4,
    Scourge = 5,
    Tauren = 6,
    Gnome = 7,
    Troll = 8,
    Goblin = 9,
    BloodElf = 10,
    Draenei = 11,

    Worgen = 22,
    Pandaren = 24,
    PandarenAlliance = 25,
    PandarenHorde = 26,
}

function Character:GetGuid()
    return self.data.guid;
end

function Character:SetGuid(guid)
    self.data.guid = guid;
end

function Character:SetOnlineStatus(info, broadcast)
    self.data.onlineStatus = info;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetOnlineStatus", "onlineStatus")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "onlineStatus", self.data.name))
end

function Character:GetOnlineStatus()
    return self.data.onlineStatus;
end


function Character:SetName(name)
    self.data.name = name;
end

function Character:GetName(colourized, ambiguate)
    if colourized then
        if type(self.data.class) == "number" then
            local _, class = GetClassInfo(self.data.class);
            if ambiguate then
                return RAID_CLASS_COLORS[class]:WrapTextInColorCode(Ambiguate(self.data.name, ambiguate));
            else
                return RAID_CLASS_COLORS[class]:WrapTextInColorCode(self.data.name);
            end
        end
    end
    return self.data.name;
end

function Character:SetRank(index)
    if self.data.rank ~= index then
        self.data.rank = index;
        addon:TriggerEvent("Character_OnDataChanged", self)
        addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "rank", self.data.name))
    end
end

function Character:GetRank()
    return self.data.rank;
end

function Character:SetLevel(level, broadcast)
    if self.data.level ~= level then
        self.data.level = level;
        addon:TriggerEvent("Character_OnDataChanged", self)
        if broadcast then
            addon:TriggerEvent("Character_BroadcastChange", self, "SetLevel", "level")
        end
        addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "level", self.data.name))
    end
end

function Character:GetLevel()
    return self.data.level;
end


function Character:SetRace(race, broadcast)
    if self.data.race ~= race then
        self.data.race = race;
        addon:TriggerEvent("Character_OnDataChanged", self)
        if broadcast then
            addon:TriggerEvent("Character_BroadcastChange", self, "SetRace", "race")
        end
        addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "race", self.data.name))
    end
end

function Character:GetRace()
    local raceInfo = C_CreatureInfo.GetRaceInfo(self.data.race)
    return raceInfo;
end

function Character:GetFaction()
    return C_CreatureInfo.GetFactionInfo(self.data.race)
end

function Character:SetClass(class)
    self.data.class = class;
end

function Character:GetClass()
    return self.data.class;
end


function Character:SetGender(gender, broadcast)
    if self.data.gender ~= gender then
        self.data.gender = gender;
        addon:TriggerEvent("Character_OnDataChanged", self)
        if broadcast then
            addon:TriggerEvent("Character_BroadcastChange", self, "SetGender", "gender")
        end
        addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "gender", self.data.name))
    end
end

function Character:GetGender()
    return self.data.gender;
end


function Character:SetPublicNote(note, broadcast)
    if self.data.publicNote ~= note then
        self.data.publicNote = note;
        addon:TriggerEvent("Character_OnDataChanged", self)
        if broadcast then
            addon:TriggerEvent("Character_BroadcastChange", self, "SetPublicNote", "publicNote")
        end
        addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "public note", self.data.name))
    end
end

function Character:GetPublicNote()
    return self.data.publicNote;
end

function Character:SetContainers(containers, broadcast)
    self.data.containers = containers;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetContainers", "containers")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "containers", self.data.name))
end

function Character:GetContainers()
    return self.data.containers;
end

function Character:GetSpecializations()
    if type(self.data.class) == "number" then
        local _, class = GetClassInfo(self.data.class);
        return classData[class].specializations;
    end
    return {}
end

function Character:SetSpec(spec, specID, broadcast)
    local k;
    if spec == "primary" then
        self.data.mainSpec = specID;
        k = "mainSpec";
    elseif spec == "secondary" then
        self.data.offSpec = specID;
        k = "offSpec";
    end
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetSpec", spec)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "spec", self.data.name))
end

function Character:GetSpec(spec)
    if type(self.data.class) == "number" then
        local _, class = GetClassInfo(self.data.class);
        if spec == "primary" then
            local specName = classData[class].specializations[self.data.mainSpec]
            return L[specName], specName, self.data.mainSpec;
        elseif spec == "secondary" then
            local specName = classData[class].specializations[self.data.offSpec]
            return L[specName], specName, self.data.offSpec;
        end
    else

    end
end


function Character:SetSpecIsPvp(spec, isPvp)
    --print("set isPvp", spec, isPvp)
    if spec == "primary" then
        self.data.mainSpecIsPvP = isPvp;
    elseif spec == "secondary" then
        self.data.offSpecIsPvP = isPvp;
    end
    --addon:TriggerEvent("Character_OnDataChanged", self)
end

function Character:GetSpecIsPvp(spec)
    if spec == "primary" then
        return self.data.mainSpecIsPvP;
    elseif spec == "secondary" then
        return self.data.offSpecIsPvP;
    end
end

function Character:GetTradeskillCooldowns()
    if self.data.tradeskillCooldowns then
        return self.data.tradeskillCooldowns
    else
        return {}
    end
end

function Character:UpdateTradeskillCooldowns(cooldowns, broadcast)

    if not self.data.tradeskillCooldowns then
        self.data.tradeskillCooldowns = {}
    end

    if type(cooldowns) == "table" then
        for k, cd in ipairs(cooldowns) do
            self.data.tradeskillCooldowns[cd.name] = cd
        end
    end

    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "UpdateTradeskillCooldowns", "tradeskillCooldowns")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format("updated tradeskill cooldowns for %s", self.data.name))
end

function Character:SetTradeskill(slot, id, broadcast)
    --print("SetTradeskill called", slot, id, tostring(broadcast))
    local k;
    if slot == 1 then
        self.data.profession1 = id;
        k = "profession1"
    elseif slot == 2 then
        self.data.profession2 = id;
        k = "profession2"
    end
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        --print("Broadcasting update SetTradeskill")
        addon:TriggerEvent("Character_BroadcastChange", self, "SetTradeskill", k)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "tradeskill", self.data.name))
end

function Character:GetTradeskill(slot)
    if slot == 1 then
        return self.data.profession1;
    elseif slot == 2 then
        return self.data.profession2;
    end
end


function Character:SetTradeskillLevel(slot, level, broadcast)
    local k;
    if slot == 1 then
        self.data.profession1Level = level;
        k = "profession1Level"
    elseif slot == 2 then
        self.data.profession2Level = level;
        k = "profession2Level"
    end
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetTradeskillLevel", k)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "tradeskill level", self.data.name))
end

function Character:GetTradeskillLevel(slot)
    if slot == 1 then
        return self.data.profession1Level;
    elseif slot == 2 then
        return self.data.profession2Level;
    end
end


function Character:SetTradeskillSpecs(specs, broadcast)

    if type(specs) == "table" then
        for k, spec in ipairs(specs) do
            if spec.tradeskillID == self.data.profession1 then
                self.data.profession1Spec = spec.spellID

                if broadcast then
                    addon:TriggerEvent("Character_BroadcastChange", self, "SetTradeskillSpec", "profession1Spec")
                end

            end
            if spec.tradeskillID == self.data.profession2 then
                self.data.profession2Spec = spec.spellID

                if broadcast then
                    addon:TriggerEvent("Character_BroadcastChange", self, "SetTradeskillSpec", "profession2Spec")
                end
            end
        end
    end

    addon:TriggerEvent("Character_OnDataChanged", self)
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "tradeskill spec", self.data.name))
end

function Character:GetTradeskillSpec(slot)
    if slot == 1 then
        return self.data.profession1Spec;
    elseif slot == 2 then
        return self.data.profession2Spec;
    end
end


function Character:SetTradeskillRecipes(slot, recipes, broadcast)
    local k;
    if slot == 1 then
        self.data.profession1Recipes = recipes;
        k = "profession1Recipes"
    elseif slot == 2 then
        self.data.profession2Recipes = recipes;
        k = "profession2Recipes"
    end
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetTradeskillRecipes", k)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "tradeskill recipes", self.data.name))
end

function Character:GetTradeskillRecipes(slot)
    if slot == 1 then
        return self.data.profession1Recipes;
    elseif slot == 2 then
        return self.data.profession2Recipes;
    end
end


function Character:SetCookingRecipes(recipes, broadcast)
    self.data.cookingRecipes = recipes;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetCookingRecipes", "cookingRecipes")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "cooking recipes", self.data.name))
end

function Character:GetCookingRecipes()
    return self.data.cookingRecipes;
end


function Character:CanCraftItem(item)

    --grab item tradeskill first
    if item.tradeskillID == 185 then
        if type(self.data.firstAidRecipes) == "table" then
            for k, spellID in ipairs(self.data.cookingRecipes) do
                if spellID == item.spellID then
                    return true;
                end
            end
        end
    elseif item.tradeskillID == 129 then
        if type(self.data.firstAidRecipes) == "table" then
            for k, spellID in ipairs(self.data.firstAidRecipes) do
                if spellID == item.spellID then
                    return true;
                end
            end
        end
    else
        if type(self.data.profession1Recipes) == "table" then
            for k, spellID in ipairs(self.data.profession1Recipes) do
                if spellID == item.spellID then
                    return true;
                end
            end
        end
    
        if type(self.data.profession2Recipes) == "table" then
            for k, spellID in ipairs(self.data.profession2Recipes) do
                if spellID == item.spellID then
                    return true;
                end
            end
        end
    end
    return false;
end


function Character:SetCookingLevel(level, broadcast)
    self.data.cookingLevel = level;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetCookingLevel", "cookingLevel")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "cooking level", self.data.name))
end

function Character:GetCookingLevel()
    return self.data.cookingLevel;
end


function Character:SetFishingLevel(level, broadcast)
    self.data.fishingLevel = level;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetFishingLevel", "fishingLevel")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "fishing level", self.data.name))
end

function Character:GetFishingLevel()
    return self.data.fishingLevel;
end

function Character:SetFirstAidRecipes(recipes, broadcast)
    self.data.firstAidRecipes = recipes;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetFirstAidRecipes", "firstAidRecipes")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "first aid recipes", self.data.name))
end

function Character:GetFirstAidRecipes()
    return self.data.firstAidRecipes;
end

function Character:SetFirstAidLevel(level, broadcast)
    self.data.firstAidLevel = level;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetFirstAidLevel", "firstAidLevel")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "first aid level", self.data.name))
end

function Character:GetFirstAidLevel()
    return self.data.firstAidLevel;
end


function Character:SetProfileDob(timeStamp)
    self.data.profile.dob = timeStamp;
    addon:TriggerEvent("Character_OnDataChanged", self)
end

function Character:GetProfileDob()
    if not self.data.profile then
        return "";
    end
    return self.data.profile.dob;
end


function Character:SetProfileName(name)
    self.data.profile.name = name;
    addon:TriggerEvent("Character_OnDataChanged", self)
end

function Character:GetProfileName()
    if not self.data.profile then
        return "";
    end
    return self.data.profile.name;
end


function Character:SetProfileBio(bio)
    self.data.profile.bio = bio;
    addon:TriggerEvent("Character_OnDataChanged", self)
end

function Character:GetProfileBio()
    if not self.data.profile then
        return "";
    end
    return self.data.profile.bio;
end

--used to set dispaly text and detect when changes occur
function Character:GetProfile()
    local t = {};
    if not self.data.profile then
        return false;
    end
    t.name = self.data.profile.name;
    t.bio = self.data.profile.bio;
    t.mainSpec = self.data.mainSpec;
    t.mainSpecIsPvp = self.data.mainSpecIsPvP;
    t.offSpec = self.data.offSpec;
    t.offSpecIsPvP = self.data.offSpecIsPvP;
    t.mainCharacter = self.data.mainCharacter;
    t.alts = self.data.alts;
    return t;
end

function Character:SetTalents(spec, talents, broadcast)
    self.data.talents[spec] = talents;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetTalents", "talents", spec)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "talents", self.data.name))
end

function Character:GetTalents(spec)
    if self.data.talents[spec] then
        return self.data.talents[spec];
    end
end


function Character:SetGlyphs(spec, glyphs, broadcast)
    if not self.data.glyphs then
        self.data.glyphs = {}
    end
    --DevTools_Dump(glyphs)
    if spec and type(glyphs) == "table" then
        self.data.glyphs[spec] = glyphs;
        if broadcast then
            addon:TriggerEvent("Character_BroadcastChange", self, "SetGlyphs", "glyphs", spec)
        end
        addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "glyphs", self.data.name))
    end
    --DevTools_Dump(self.data.glyphs)
end

-- function Character:GetGlyphs(spec)
--     if self.data.glyphs[spec] then
--         return self.data.glyphs[spec];
--     end
-- end

function Character:GetItemLevel(set)

    if not set then
        set = "current"
    end

    local numItems, totalItemlevel = 0, 0;

    if self.data.inventory[set] then
        for slot, link in pairs(self.data.inventory[set]) do
            if slot ~= "TABARDSLOT" then
                if type(link) == "string" then
                    --print(link)
                    --local n, l, q, ilvl = GetItemInfo(link)
                    local actualItemLevel, previewLevel, sparseItemLevel = C_Item.GetDetailedItemLevelInfo(link)
                    --print(actualItemLevel, previewLevel, sparseItemLevel, link)
                    --print(ilvl)
                    if type(actualItemLevel) == "number" then
                        numItems = numItems + 1;
                        totalItemlevel = totalItemlevel + actualItemLevel;

                    end
                end
            end
        end

        if numItems > 0 then
            return (totalItemlevel/numItems)
        else
            return 1;
        end
    else
        return 1;
    end
end

function Character:SetEquipmentSets(sets, broadcast)
    for name, itemIDs in pairs(sets) do
        self.data.inventory[name] = itemIDs;
    end
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetEquipmentSets", "inventory", sets)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "equipment sets", self.data.name))
end

function Character:SetInventory(set, inventory, broadcast)
    self.data.inventory[set] = inventory;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetInventory", "inventory", set)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "inventory (gear)", self.data.name))
end

function Character:GetInventory(set)
    return self.data.inventory[set] or {};
end

function Character:SetAuras(set, res, broadcast)
    self.data.auras[set] = res;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetAuras", "auras", set)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "auras", self.data.name))
end

function Character:GetAuras(set)
    return self.data.auras[set] or {};
end

function Character:SetResistances(set, res, broadcast)
    self.data.resistances[set] = res;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetResistances", "resistances", set)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "resistances", self.data.name))
end

function Character:GetResistances(set)
    return self.data.resistances[set] or {};
end

function Character:SetPaperdollStats(set, stats, broadcast)
    self.data.paperDollStats[set] = stats;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetPaperdollStats", "paperDollStats", set)
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "stats", self.data.name))
end

function Character:GetPaperdollStats(set)
    if self.data.paperDollStats[set] then
        return self.data.paperDollStats[set] or {};
    end
end

function Character:GetAlts()
    return self.data.alts or {}
end

--sets the object called from as the main character for the alts passed in
function Character:UpdateAlts(alts, broadcast)
    self.data.alts = alts;
    if addon.thisGuild then
        Database:SetMainCharacterForAlts(addon.thisGuild, self.data.name, alts)
    end
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "UpdateAlts", "alts")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "alts", self.data.name))
end

function Character:SetMainCharacter(main, broadcast)
    self.data.mainCharacter = main;

    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetMainCharacter", "mainCharacter")
    end
    addon:TriggerEvent("StatusText_OnChanged", string.format(" set %s for %s", "main character", self.data.name))

end

function Character:GetMainCharacter()
    return self.data.mainCharacter;
end


function Character:GetTradeskillIcon(slot)
    if type(self.data["profession"..slot]) == "number" then
        return Tradeskills:TradeskillIDToAtlas(self.data["profession"..slot])
    end
    return "questlegendaryturnin";
end

function Character:GetTradeskillName(slot)
    if type(self.data["profession"..slot]) == "number" then
        return Tradeskills:GetLocaleNameFromID(self.data["profession"..slot])
    end
    return "-";
end

function Character:GetProfileAvatar()
    if type(self.data.race) == "number" and type(self.data.gender) == "number" then
        local raceInfo = C_CreatureInfo.GetRaceInfo(self.data.race)
        local gender = (self.data.gender == 3) and "female" or "male" --GetPlayerInfoByGUID returns 2=MALE 3=FEMALE
        return string.format("raceicon-%s-%s", raceInfo.clientFileString:lower(), gender)
    else

    end
    return "questlegendaryturnin"
end


--this will return spec info as it exists in the game ui
--mainSpec will be whatever primary spec is
--unlike the character profile which can be any spec as main as per the players choice
--use this when getign character data specific to a spec
--use the .data.mainSpec for display only
function Character:GetSpecInfo()

    local t = {
        primary = {
            [1] = { id = 1, points = 0 },
            [2] = { id = 2, points = 0 },
            [3] = { id = 3, points = 0 },
        },
        secondary = {
            [1] = { id = 1, points = 0 },
            [2] = { id = 2, points = 0 },
            [3] = { id = 3, points = 0 },
        },
    }

    for k, spec in ipairs({"primary", "secondary"}) do
        if self.data.talents[spec] then
            for k, v in ipairs(self.data.talents[spec]) do
                t[spec][v.tabID].points = t[spec][v.tabID].points + v.rank
            end
        end
        table.sort(t[spec], function(a,b)
            return a.points > b.points
        end)
    end

    return t;
    
end

function Character:GetClassSpecAtlasInfo()
    if type(self.data.class) == "number" then
        local _, class = GetClassInfo(self.data.class)
        if class then
            local t = {}
            for k, s in ipairs(classData[class].specializations) do
                if s == "Beast Master" then
                    s = "BeastMastery";
                end
                if s == "Cat" then
                    s = "Feral";
                end
                if s == "Bear" then
                    s = "Guardian";
                end
                if s == "Combat" then
                    s = "Outlaw";
                end
                table.insert(t, string.format("GarrMission_ClassIcon-%s-%s", class, s))
            end
            return t
        end
    end
    return {}
end

function Character:GetClassSpecAtlasName(spec)

    if type(self.data.class) == "number" then
        local _, class = GetClassInfo(self.data.class)

        if spec then
            
            local s;
            if spec == "primary" then
                s = classData[class].specializations[self.data.mainSpec]
            elseif spec == "secondary" then
                s = classData[class].specializations[self.data.offSpec]


            elseif type(spec) == "number" then

                if class == "DRUID" then
                    if spec == 3 then
                        spec = 4;
                    end
                end

                s = classData[class].specializations[spec]
            end

            if s == "Beast Master" then
                s = "BeastMastery";
            end
            if s == "Cat" then
                s = "Feral";
            end
            if s == "Bear" then
                s = "Guardian";
            end
            if s == "Combat" then
                s = "Outlaw";
            end

            if s then
                return string.format("GarrMission_ClassIcon-%s-%s", class, s), s;
            else
                return string.format("classicon-%s", class):lower(), "";
            end
        else
            return string.format("classicon-%s", class):lower(), "";
        end
    end

    return "questlegendaryturnin";

end

-- function Character:RegisterCallbacks()
--     addon:RegisterCallback("Blizzard_OnTradeskillUpdate", self.Blizzard_OnTradeskillUpdate, self)
-- end


-- function Character:Blizzard_OnTradeskillUpdate(prof, recipes)

--     if self.data.guid == UnitGUID("player") then

--         if prof == 185 then
--             self:SetCookingRecipes(recipes)
--             return;
--         end

--         if prof == 129 then
--             self:SetFirstAidRecipes(recipes)
--             return
--         end

--         if prof == 356 then
            
--             return;
--         end

--         if self.data.profession1 == "-" then
--             self:SetTradeskill(1, prof);
--             self:SetTradeskillRecipes(1, recipes)
--             return;
--         else
--             if self.data.profession1 == prof then
--                 self:SetTradeskillRecipes(1, recipes)
--                 return;
--             end
--         end

--         if self.data.profession2 == "-" then
--             self:SetTradeskill(2, prof);
--             self:SetTradeskillRecipes(2, recipes)
--             return;
--         else
--             if self.data.profession2 == prof then
--                 self:SetTradeskillRecipes(2, recipes)
--                 return;
--             end
--         end

--     end
-- end


function Character:SetLockouts(lockouts)
    self.data.lockouts = lockouts;
end


function Character:GetLockouts()
    return self.data.lockouts or {};
end

function Character:SetDateJoined(timestamp)
    self.data.joined = timestamp
end

function Character:GetDateJoined()
    return self.data.joined or time()
end


function Character:SetAchievementPoints(points, broadcast)
    self.data.achievementPoints = points;
    addon:TriggerEvent("Character_OnDataChanged", self)
    if broadcast then
        addon:TriggerEvent("Character_BroadcastChange", self, "SetAchievementPoints", "achievementPoints")
    end
end



function Character:CreateFromData(data)
    --if (data.race == false) or (data.gender == false) then
        self.ticker = C_Timer.NewTicker(1, function()
            local _, _, _, englishRace, sex = GetPlayerInfoByGUID(data.guid)
            if englishRace and sex then
                if addon.characters[data.name] then
                    addon.characters[data.name]:SetGender(sex)
                    addon.characters[data.name]:SetRace(raceFileStringToId[englishRace])
                    addon.characters[data.name].ticker:Cancel()
                end
            end
        end)
    --end
    return Mixin({data = data}, self)
end


function Character:CreateEmpty()
    local character = {
        guid = "",
        name = "",
        class = false,
        gender = false,
        level = 0,
        race = false,
        rank = 0,
        onlineStatus = {
            isOnline = false,
            zone = "",
        },
        alts = {},
        mainCharacter = false,
        publicNote = "",
        mainSpec = false,
        offSpec = false,
        mainSpecIsPvP = false,
        offSpecIsPvP = false,
        profile = {},
        profession1 = "-",
        profession1Level = 0,
        profession1Spec = false,
        profession1Recipes = {},
        profession2 = "-",
        profession2Level = 0,
        profession2Spec = false,
        profession2Recipes = {},
        cookingLevel = 0,
        cookingRecipes = {},
        fishingLevel = 0,
        firstAidLevel = 0,
        firstAidRecipes = {},
        talents = {},
        glyphs = {},
        inventory = {
            current = {},
        },
        paperDollStats = {
            current = {},
        },
        resistances = {
            current = {},
        },
        auras = {
            current = {},
        },
        containers = {},
        lockouts = {},
        tradeskillCooldowns = {},
        achievementPoints = 0,
    }
    return character;
end

function Character:SetData(data)
    self.data = data;
end

function Character:ResetData()

    self.data.mainSpec = false
    self.data.offSpec = false
    self.data.mainSpecIsPvP = false
    self.data.offSpecIsPvP = false
    self.data.profile = {}
    self.data.profession1 = "-"
    self.data.profession1Level = 0
    self.data.profession1Spec = false
    self.data.profession1Recipes = {}
    self.data.profession2 = "-"
    self.data.profession2Level = 0
    self.data.profession2Spec = false
    self.data.profession2Recipes = {}
    self.data.cookingLevel = 0
    self.data.cookingRecipes = {}
    self.data.fishingLevel = 0
    self.data.firstAidLevel = 0
    self.data.firstAidRecipes = {}
    self.data.talents = {}
    self.data.glyphs = {}
    self.data.inventory = {
        current = {},
    }
    self.data.paperDollStats = {
        current = {},
    }
    self.data.resistances = {
        current = {},
    }
    self.data.auras = {
        current = {},
    }
    self.data.containers = {}
    self.data.lockouts = {}
    self.data.tradeskillCooldowns = {}
    self.data.achievementPoints = 0
    addon:TriggerEvent("Character_OnDataChanged", self)
end


addon.Character = Character;


