

local _, addon = ...;

local Character = {};
local Tradeskills = addon.Tradeskills;
local L = addon.Locales;


--will use a specID as found from spellbook tabs-1 (ignore general) and then get the spec name from this table
--for display the name value can be used to grab the locale
local classData = {
    DEATHKNIGHT = { 
        specializations={'Frost','Blood','Unholy'} 
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
        specializations={'Assassination','Combat','Subtlety',} -- outlaw could need adding in here
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

function Character:GetGuid()
    return self.data.guid;
end

function Character:SetGuid(guid)
    self.data.guid = guid;
end

function Character:SetOnlineStatus(info)
    self.data.onlineStatus = info;
    addon:TriggerEvent("OnCharacterChanged", self)
end

function Character:GetOnlineStatus()
    return self.data.onlineStatus;
end


function Character:SetName(name)
    self.data.name = name;
end

function Character:GetName()
    return self.data.name;
end


function Character:SetLevel(level)
    self.data.level = level;
end

function Character:GetLevel()
    return self.data.level;
end


function Character:SetRace(race)
    self.data.race = race;
end

function Character:GetRace()
    return self.data.race;
end


function Character:SetClass(class)
    self.data.class = class;
end

function Character:GetClass()
    return self.data.class;
end


function Character:SetGender(gender)
    self.data.gender = gender;
end

function Character:GetGender()
    return self.data.gender;
end


function Character:SetPublicNote(note)
    self.data.publicNote = note;
end

function Character:GetPublicNote()
    return self.data.publicNote;
end


function Character:GetSpecializations()
    return classData[self.data.class].specializations;
end

function Character:SetSpec(spec, specID)
    if spec == "primary" then
        self.data.mainSpec = specID; 
    elseif spec == "secondary" then
        self.data.offSpec = specID;
    end
    --print("set spec", spec, specID)
end

function Character:GetSpec(spec)
    if spec == "primary" then
        local specName = classData[self.data.class].specializations[self.data.mainSpec]
        return L[specName], specName, self.data.mainSpec;
    elseif spec == "secondary" then
        local specName = classData[self.data.class].specializations[self.data.offSpec]
        return L[specName], specName, self.data.offSpec;
    end
end


function Character:SetSpecIsPvp(spec, isPvp)
    --print("set isPvp", spec, isPvp)
    if spec == "primary" then
        self.data.mainSpecIsPvP = isPvp;
    elseif spec == "secondary" then
        self.data.offSpecIsPvP = isPvp;
    end
end

function Character:GetSpecIsPvp(spec)
    if spec == "primary" then
        return self.data.mainSpecIsPvP;
    elseif spec == "secondary" then
        return self.data.offSpecIsPvP;
    end
end


function Character:SetTradeskill(slot, id)
    if slot == 1 then
        self.data.profession1 = id;
    elseif slot == 2 then
        self.data.profession2 = id;
    end
end

function Character:GetTradeskill(slot)
    if slot == 1 then
        return self.data.profession1;
    elseif slot == 2 then
        return self.data.profession2;
    end
end


function Character:SetTradeskillLevel(slot, level)
    if slot == 1 then
        self.data.profession1Level = level;
    elseif slot == 2 then
        self.data.profession2Level = level;
    end
end

function Character:GetTradeskillLevel(slot)
    if slot == 1 then
        return self.data.profession1Level;
    elseif slot == 2 then
        return self.data.profession2Level;
    end
end


function Character:SetTradeskillSpec(slot, spec)
    if slot == 1 then
        self.data.profession1Spec = spec;
    elseif slot == 2 then
        self.data.profession2Spec = spec;
    end
end

function Character:GetTradeskillSpec(slot)
    if slot == 1 then
        return self.data.profession1Spec;
    elseif slot == 2 then
        return self.data.profession2Spec;
    end
end


function Character:SetTradeskillRecipes(slot, recipes)
    if slot == 1 then
        self.data.profession1Recipes = recipes;
    elseif slot == 2 then
        self.data.profession2Recipes = recipes;
    end
end

function Character:GetTradeskillRecipes(slot)
    if slot == 1 then
        return self.data.profession1Recipes;
    elseif slot == 2 then
        return self.data.profession2Recipes;
    end
end


function Character:SetCookingRecipes(recipes)
    self.data.cookingRecipes = recipes;
end

function Character:GetCookingRecipes()
    return self.data.cookingRecipes;
end


function Character:CanCraftItem(item)

    --addon.DEBUG("func", "Character:CanCraftItem", string.format("looking for crafters for %s", item.name))

    if self.data.profession1 == item.tradeskill then
        --addon.DEBUG("func", "Character:CanCraftItem", string.format("found matching prof 1 for %s", self.data.name))
        for k, itemID in pairs(self.data.profession1Recipes) do
            if itemID == item.itemID then
                return true;
            end
        end
    end

    if self.data.profession2 == item.tradeskill then
        --addon.DEBUG("func", "Character:CanCraftItem", string.format("found matching prof 2 for %s", self.data.name))
        for k, itemID in pairs(self.data.profession2Recipes) do
            if itemID == item.itemID then
                return true;
            end
        end
    end

    if item.tradeskill == 185 then --cooking
        for k, itemID in pairs(self.data.cookingRecipes) do
            if itemID == item.itemID then
                return true;
            end
        end
    end
end


function Character:SetCookingLevel(level)
    self.data.cookingLevel = level;
end

function Character:GetCookingLevel()
    return self.data.cookingLevel;
end


function Character:SetFishingLevel(level)
    self.data.fishingLevel = level;
end

function Character:GetFishingLevel()
    return self.data.fishingLevel;
end


function Character:SetFirstAidLevel(level)
    self.data.firstAidLevel = level;
end

function Character:GetFirstAidLevel()
    return self.data.firstAidLevel;
end


function Character:SetProfileDob(timeStamp)
    self.data.profile.dob = timeStamp;
end

function Character:GetProfileDob()
    if not self.data.profile then
        return "";
    end
    return self.data.profile.dob;
end


function Character:SetProfileName(name)
    self.data.profile.name = name;
end

function Character:GetProfileName()
    if not self.data.profile then
        return "";
    end
    return self.data.profile.name;
end


function Character:SetProfileBio(bio)
    self.data.profile.bio = bio;
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

function Character:SetTalents(spec, talents)
    self.data.talents[spec] = talents;
end

function Character:GetTalents(spec)
    if self.data.talents[spec] then
        return self.data.talents[spec];
    end
end


function Character:SetGlyphs(spec, glyphs)
    self.data.glyphs[spec] = glyphs;
end

function Character:GetGlyphs(spec)
    if self.data.glyphs[spec] then
        return self.data.glyphs[spec];
    end
end


function Character:SetInventory(inventory)
    self.data.inventory = inventory;
end

function Character:GetInventory()
    return self.data.inventory;
end


function Character:SetPaperdollStats(name, stats)
    self.data.paperDollStats[name] = stats;
end

function Character:GetPaperdollStats(name)
    if self.data.paperDollStats[name] then
        return self.data.paperDollStats[name];
    end
end


function Character:SetMainCharacter(main)
    self.data.mainCharacter = main;
end

function Character:GetMainCharacter()
    return self.data.mainCharacter;
end

function Character:SetAlts(alts)
    self.data.alts = alts;
end

function Character:GetAlts()
    return self.data.alts;
end


function Character:AddNewAlt(guid)
    table.insert(self.data.alts, guid)
end

function Character:RemoveAlt(guid)
    local i;
    for k, _guid in ipairs(self.data.alts) do
        if _guid == guid then
            i = k;
        end
    end
    if type(i) == "number" then
        table.remove(self.data.alts, i)
    end
end

function Character:GetClassSpecAtlasName(spec)

    local c = self.data.class
    local _, s = self:GetSpec(spec)

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

    if c == nil then
        return "questlegendaryturnin"
    end
    if s == nil then
        return "questlegendaryturnin"
    end

    return string.format("GarrMission_ClassIcon-%s-%s", c, s)
end


function Character:CreateFromData(guid, data)

    local prof1Recipes = nil;
    if type(data.Profession1) == "string" then

        if data[data.Profession1] then
            prof1Recipes = {};
            for itemID, _ in pairs(data[data.Profession1]) do
                table.insert(prof1Recipes, itemID)
            end
            data.Profession1Recipes = prof1Recipes;
        end

        local tradeskillID = Tradeskills:GetTradeskillIDFromEnglishName(data.Profession1)
        data.Profession1 = tradeskillID;

    end

    local prof2Recipes= nil;
    if type(data.Profession2) == "string" then

        if data[data.Profession2] then
            prof2Recipes = {};
            for itemID, _ in pairs(data[data.Profession2]) do
                table.insert(prof2Recipes, itemID)
            end
            data.Profession2Recipes = prof2Recipes;
        end

        local tradeskillID = Tradeskills:GetTradeskillIDFromEnglishName(data.Profession2)
        data.Profession2 = tradeskillID;
    end



    --DevTools_Dump({data})
    if type(data) == "table" then

        return Mixin({
            data = {
                guid = guid,
                name = data.Name,
                class = data.Class,
                gender = data.Gender,
                level = data.Level,
                race = data.Race,
                rankName = data.RankName,
                alts = data.Alts,
                mainCharacter = data.MainCharacter or false,
                publicNote = data.PublicNote,
                mainSpec = data.MainSpec,
                offSpec = data.OffSpec,
                mainSpecIsPvP = data.MainSpecIsPvP,
                offSpecIsPvP = data.OffSpecIsPvP,
                profile = data.profile,
                profession1 = data.Profession1,
                profession1Level = data.Profession1Level,
                profession1Spec = data.Profession1Spec,
                profession1Recipes = data.Profession1Recipes or {},
                profession2 = data.Profession2,
                profession2Level = data.Profession2Level,
                profession2Spec = data.Profession2Spec,
                profession2Recipes = data.Profession2Recipes or {},
                cookingLevel = data.CookingLevel,
                cookingRecipes = data.Cooking or {},
                fishingLevel = data.FishingLevel,
                firstAidLevel = data.FirstAidLevel,
                talents = data.Talents or {},
                glyphs = data.Glyphs or {},
                inventory = data.Inventory,
                paperDollStats = data.PaperDollStats,
                onlineStatus = {
                    isOnline = false,
                    zone = "",
                }
            },
        }, self)
    end
end


function Character:SetData(data)

    -- local prof1 = data.Profession1;
    -- local prof2 = data.Profession2;

    -- if type(prof1) == "string" then
    --     prof1 = Tradeskills:GetTradeskillIDFromEnglishName(prof1)
    -- end
    -- if type(prof2) == "string" then
    --     prof1 = Tradeskills:GetTradeskillIDFromEnglishName(prof2)
    -- end

    -- if data.Name == "Silvessa" then
    --     print(prof1, prof2)
    --     DevTools_Dump({data[prof1]})
    -- end

    self.data = {
        name = data.Name,
        class = data.Class,
        gender = data.Gender,
        level = data.Level,
        race = data.Race,
        rankName = data.RankName,
        alts = data.Alts,
        mainCharacter = data.MainCharacter or false,
        publicNote = data.PublicNote,
        mainSpec = data.MainSpec,
        offSpec = data.OffSpec,
        mainSpecIsPvP = data.MainSpecIsPvP,
        offSpecIsPvP = data.OffSpecIsPvP,
        profile = data.profile,
        profession1 = data.Profession1,
        profession1Level = data.Profession1Level,
        profession1Spec = data.Profession1Spec,
        profession1Recipes = data.Profession1Recipes or {},
        profession2 = data.Profession2,
        profession2Level = data.Profession2Level,
        profession2Spec = data.Profession2Spec,
        profession2Recipes = data.Profession2Recipes or {},
        cookingLevel = data.CookingLevel,
        cookingRecipes = data.Cooking or {},
        fishingLevel = data.FishingLevel,
        firstAidLevel = data.FirstAidLevel,
        talents = data.Talents or {},
        glyphs = data.Glyphs or {},
        inventory = data.Inventory,
        paperDollStats = data.PaperDollStats,
        onlineStatus = {
            isOnline = false,
            zone = "",
        }
    }
end


function Character:GetData()
    local data = {
        Name = self.data.name,
        Class = self.data.class,
        Gender = self.data.gender,
        Level = self.data.level,
        Race = self.data.race,
        Alts = self.data.alts,
        MainCharacter = self.data.mainCharacter,
        RankName = self.data.rankName,
        PublicNote = self.data.publicNote,
        MainSpec = self.data.mainSpec,
        OffSpec = self.data.offSpec,
        MainSpecIsPvP = self.data.mainSpecIsPvP,
        OffSpecIsPvP = self.data.offSpecIsPvP,
        profile = self.data.profile,
        Profession1 = self.data.profession1,
        Profession1Level = self.data.profession1Level,
        Profession1Spec = self.data.profession1Spec,
        Profession1Recipes = self.data.profession1Recipes,
        Profession2 = self.data.profession2,
        Profession2Level = self.data.profession2Level,
        Profession2Spec = self.data.profession2Spec,
        Profession2Recipes = self.data.profession2Recipes,
        CookingLevel = self.data.cookingLevel,
        Cooking = self.data.cookingRecipes or {},
        FishingLevel = self.data.fishingLevel,
        FirstAidLevel = self.data.firstAidLevel,
        Talents = self.data.talents,
        Glyphs = self.data.glyphs,
        Inventory = self.data.inventory,
        PaperDollStats = self.data.paperDollStats,
    }
    return data;
end

function Character:ResetData()
    local name = self.data.name;
    local guid = self.data.guid;
    self.data = {
        name = "",
        level = 0,
        class = "",
        race = "",
        gender = "",
        guid = guid,

        mainCharacter = false,
        publicNote = "",
        alts = {},

        mainSpec = 1,
        mainSpecIsPvP = false,
        offSpec = 2,
        offSpecIsPvP = false,

        profession1 = "-",
        profession2 = "-",
        profession1Level = 0,
        profession2Level = 0,
        profession1Recipes = {},
        profession2Recipes = {},
        profession1Spec = 0,
        profession2Spec = 0,

        cooking = {},

        cookingLevel = 0,
        firstAidLevel = 0,
        fishingLevel = 0,

        talents = {
            primary = {},
            secondary = {},
        },
        glyphs = {
            primary = {},
            secondary = {},
        },

        inventory = {},

        rankName = "",
        profile = {
            dob = false,
            name = "",
            bio = "",
            avatar = false,
        },

        paperDollStats = {
            current = {},
            primary = {},
            secondary = {},
        },

        onlineStatus = {
            isOnline = false,
            zone = "",
        }
    }
    if guid == UnitGUID("player") then
        addon:TriggerEvent("Character_OnDataChanged")
    end
    --addon.DEBUG("func", "Character:ResetData", string.format("reset data for %s", name))
end

function Character:New()
    --addon.DEBUG("func", "Character:New", string.format("created new character object"))
    return Mixin({ 
        data = {
            name = "",
            level = 0;
            class = "",
            race = "",
            gender = "",

            mainCharacter = false,
            publicNote = "",
            alts = {},

            mainSpec = 1,
            mainSpecIsPvP = false,
            offSpec = 2,
            offSpecIsPvP = false,

            profession1 = "-",
            profession2 = "-",
            profession1Level = 0,
            profession2Level = 0,
            profession1Recipes = 0,
            profession2Recipes = 0,
            profession1Spec = 0,
            profession2Spec = 0,

            cooking = {},

            cookingLevel = 0,
            firstAidLevel = 0,
            fishingLevel = 0,

            talents = {
                primary = {},
                secondary = {},
            },
            glyphs = {
                primary = {},
                secondary = {},
            },

            inventory = {},

            rankName = "",
            profile = {
                dob = false,
                name = "",
                bio = "",
                avatar = false,
            },

            paperDollStats = {
                current = {},
                primary = {},
                secondary = {},
            },
        },
    }, self)
end

addon.Character = Character;