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


-- TODO: tidy this file up, make better lookup tables

local addonName, Guildbook = ...
local L = Guildbook.Locales

Guildbook.Data = {}

Guildbook.Data.Months = {
    L['JANUARY'],
    L['FEBRUARY'],
    L['MARCH'],
    L['APRIL'],
    L['MAY'],
    L['JUNE'],
    L['JULY'],
    L['AUGUST'],
    L['SEPTEMBER'],
    L['OCTOBER'],
    L['NOVEMBER'],
    L['DECEMBER']
}

Guildbook.Data.DefaultConfigSettings = {
    privacy = {
        shareInventoryMinRank = "none",
        shareTalentsMinRank = "none",
        shareProfileMinRank = "none",
    },
    modifyDefaultGuildRoster = true,
    showTooltipTradeskills = true,
    showTooltipTradeskillsRecipes = true,
    showMinimapButton = true,
    showMinimapCalendarButton = true,
    showTooltipCharacterInfo = true,
    showTooltipMainCharacter = true,
    showTooltipMainSpec = true,
    showTooltipProfessions = true,
    parsePublicNotes = false,
}

Guildbook.Data.DefaultGlobalSettings = {
    Debug = false,
    GuildRosterCache = {},
    Calendar = {},
    CalendarDeleted = {},
    CommsDelay = 1.0,
}

Guildbook.Data.DefaultCharacterSettings = {
    Name = "",
    Class = "",
    Race = "",
    Gender = "",
    PublicNote = "",
    OfficerNote = "",
    RankName = "",
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
    PaperDollStats = {},
    Inventory = {
        Current = {},
    },
    profile = {},
    Alts = {},
}

Guildbook.Data.RaceIcons = {
    FEMALE = {
        HUMAN = 130904,
        DWARF = 130902,
        NIGHTELF = 130905,
        GNOME = 130903,
        ORC = 130906,
        TROLL = 130909,
        TAUREN = 130908,
        SCOURGE = 130907
    },
    MALE = {
        HUMAN = 130914,
        DWARF = 130912,
        NIGHTELF = 130915,
        GNOME = 130913,
        ORC = 130916,
        TROLL = 130919,
        TAUREN = 130918,
        SCOURGE = 130917
    },
    [1] = {
        HUMAN = 130904,
        DWARF = 130902,
        NIGHTELF = 130905,
        GNOME = 130903,
        ORC = 130906,
        TROLL = 130909,
        TAUREN = 130908,
        SCOURGE = 130907
    },
    [0] = {
        HUMAN = 130914,
        DWARF = 130912,
        NIGHTELF = 130915,
        GNOME = 130913,
        ORC = 130916,
        TROLL = 130919,
        TAUREN = 130918,
        SCOURGE = 130917
    }
}

Guildbook.Data.Class = {
    DEATHKNIGHT = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:128:192|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:128:192|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:128:192|t", 
        IconID = 135771, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DEATHKNIGHT", 
        RGB={ 0.77, 0.12, 0.23 }, 
        FontColour='|cffC41F3B', 
        Specializations={'Frost','Blood','Unholy',} 
    },
    -- ['DEATH KNIGHT'] = { 
    --     FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:128:192|t", 
    --     FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:128:192|t", 
    --     FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:128:192|t", 
    --     IconID = 135771, 
    --     Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DEATHKNIGHT", 
    --     RGB={ 0.77, 0.12, 0.23 }, 
    --     FontColour='|cffC41F3B', 
    --     Specializations={'Frost','Blood','Unholy',} 
    -- },
    DRUID = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:192:256:0:64|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:192:256:0:64|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:192:256:0:64|t", 
        IconID = 625999, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DRUID", 
        RGB={ 1.00, 0.49, 0.04 }, 
        FontColour='|cffFF7D0A', 
        Specializations={'Balance','Restoration','Cat' ,'Bear',}
    },
    HUNTER = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:64:128|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:64:128|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:64:128|t", 
        IconID = 626000, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\HUNTER", 
        RGB={ 0.67, 0.83, 0.45 }, 
        FontColour='|cffABD473', 
        Specializations={'Marksmanship','Beast Master','Survival',} 
    },
    MAGE = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:0:64|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:0:64|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:0:64|t", 
        IconID = 626001, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\MAGE", 
        RGB={ 0.25, 0.78, 0.92 }, 
        FontColour='|cff40C7EB', 
        Specializations={'Fire','Frost' ,'Arcane',} 
    },
    PALADIN = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:128:192|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:128:192|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:128:192|t", 
        IconID = 626003, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\PALADIN", 
        RGB={ 0.96, 0.55, 0.73 }, 
        FontColour='|cffF58CBA', 
        Specializations={'Protection','Retribution','Holy',} 
    },
    PRIEST = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:128:192:64:128|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:128:192:64:128|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:128:192:64:128|t", 
        IconID = 626004, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\PRIEST", 
        RGB={ 1.00, 1.00, 1.00 }, 
        FontColour='|cffFFFFFF', 
        Specializations={'Holy','Discipline','Shadow',} 
    },
    ROGUE = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:128:192:0:64|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:128:192:0:64|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:128:192:0:64|t", 
        IconID = 626005, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\ROGUE", 
        RGB={ 1.00, 0.96, 0.41 }, 
        FontColour='|cffFFF569', 
        Specializations={'Assassination','Combat','Subtlety',} -- outlaw could need adding in here
    },
    SHAMAN = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:64:128|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:64:128|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:64:128|t", 
        IconID = 626006, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\SHAMAN", 
        RGB={ 0.00, 0.44, 0.87 }, 
        FontColour='|cff0070DE', 
        Specializations={'Elemental','Restoration','Enhancement',} 
    },
    WARLOCK = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:192:256:64:128|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:192:256:64:128|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:192:256:64:128|t", 
        IconID = 626007, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\WARLOCK", 
        RGB={ 0.53, 0.53, 0.93 }, 
        FontColour='|cff8787ED', 
        Specializations={'Affliction','Demonology','Destruction',} 
    },
    WARRIOR = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:0:64|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:0:64|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:0:64|t", 
        IconID = 626008, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\WARRIOR", 
        RGB={ 0.78, 0.61, 0.43 }, 
        FontColour='|cffC79C6E', 
        Specializations={'Protection','Arms','Fury',} 
    },
}

Guildbook.Data.Talents = {
    DEATHKNIGHT = {
        [1] = "DeathKnightBlood", 
        [2] = "DeathKnightFrost", 
        [3] = "DeathKnightUnholy",
    },
	DRUID = {
        [1] = "DruidBalance", 
        [2] = "DruidFeralCombat", 
        [3] = "DruidRestoration",
    },
	HUNTER = {
        [1] = "HunterBeastMastery", 
        [2] = "HunterMarksmanship", 
        [3] = "HunterSurvival",
    },
--	"HunterPetCunning", "HunterPetFerocity", "HunterPetTenacity",},
	MAGE = {
        [1] = "MageArcane", 
        [2] = "MageFire", 
        [3] = "MageFrost",
    },
	PALADIN = {
        [1] = "PaladinHoly", 
        [2] = "PaladinProtection",
        [3] = "PaladinCombat",
    },
	PRIEST = {
        [1] = "PriestDiscipline", 
        [2] = "PriestHoly", 
        [3] = "PriestShadow",
    },
	ROGUE = {
        [1] = "RogueAssassination", 
        [2] = "RogueCombat", 
        [3] = "RogueSubtlety",
    },
	SHAMAN = {
        [1] = "ShamanElementalCombat", 
        [2] = "ShamanEnhancement", 
        [3] = "ShamanRestoration",
    },
	WARLOCK = {
        [1] = "WarlockCurses", 
        [2] = "WarlockSummoning", 
        [3] = "WarlockDestruction",
    },
	WARRIOR = {
        [1] = "WarriorArms", 
        [2] = "WarriorFury", 
        [3] = "WarriorProtection",
    },
}

Guildbook.Data.TalentBackgrounds = {
	["DeathKnightBlood"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\DEATHKNIGHT\\Blood", 
	["DeathKnightFrost"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\DEATHKNIGHT\\Frost", 
	["DeathKnightUnholy"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\DEATHKNIGHT\\Unholy", 
	["DruidBalance"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\DRUID\\Balance",  
	["DruidFeralCombat"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\DRUID\\Bear", 
	["DruidRestoration"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\DRUID\\Restoration", 
	["HunterBeastMastery"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\HUNTER\\BeastMaster", 
	["HunterMarksmanship"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\HUNTER\\Marksmanship",  
	["HunterSurvival"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\HUNTER\\Survival", 
	["MageArcane"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\MAGE\\Arcane", 
	["MageFire"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\MAGE\\Fire",  
	["MageFrost"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\MAGE\\Frost", 
	["PaladinCombat"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\PALADIN\\Retribution",  
	["PaladinHoly"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\PALADIN\\Holy",  
	["PaladinProtection"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\PALADIN\\Protection", 
	["PriestDiscipline"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\PRIEST\\Discipline",  
	["PriestHoly"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\PRIEST\\Holy",  
	["PriestShadow"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\PRIEST\\Shadow", 
	["RogueAssassination"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\ROGUE\\Assassination",  
	["RogueCombat"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\ROGUE\\Combat",  
	["RogueSubtlety"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\ROGUE\\Subtlety", 
	["ShamanElementalCombat"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\SHAMAN\\Elemental", 
	["ShamanEnhancement"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\SHAMAN\\Enhancement",  
	["ShamanRestoration"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\SHAMAN\\Restoration", 
	["WarlockCurses"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\WARLOCK\\Affliction",  
	["WarlockDestruction"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\WARLOCK\\Destruction",  
	["WarlockSummoning"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\WARLOCK\\Demonology", 
	["WarriorArms"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\WARRIOR\\Arms",  
	["WarriorFury"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\WARRIOR\\Fury",  
	["WarriorProtection"] = "Interface\\Addons\\Guildbook\\Icons\\Specialization\\WARRIOR\\Protection", 
}

Guildbook.Data.TalentBackgroundToSpec = {
	["DeathKnightBlood"] = "Blood",
	["DeathKnightFrost"] = "Frost",
	["DeathKnightUnholy"] = "Unholy",
	["DruidBalance"] = "Balance",
	["DruidFeralCombat"] = "Bear",
	["DruidRestoration"] = "Restoration",
	["HunterBeastMastery"] = "BeastMaster",
	["HunterMarksmanship"] = "IMarksmanship",
	["HunterSurvival"] = "Survival",
	["MageArcane"] = "Arcane",
	["MageFire"] = "Fire",
	["MageFrost"] = "Frost",
	["PaladinCombat"] = "Retribution",
	["PaladinHoly"] = "Holy",
	["PaladinProtection"] = "Protection",
	["PriestDiscipline"] = "Discipline",
	["PriestHoly"] = "Holy",
	["PriestShadow"] = "Shadow",
	["RogueAssassination"] = "Assassination",
	["RogueCombat"] = "Combat",
	["RogueSubtlety"] = "Subtlety",
	["ShamanElementalCombat"] = "Elemental",
	["ShamanEnhancement"] = "Enhancement",
	["ShamanRestoration"] = "Restoration",
	["WarlockCurses"] = "Affliction",
	["WarlockDestruction"] = "Destruction",
	["WarlockSummoning"] = "Demonology",
	["WarriorArms"] = "Arms",
	["WarriorFury"] = "Fury",
	["WarriorProtection"] = "Protection",
}

Guildbook.Data.Profession = {
    ['-'] = { 
        ID = 0, 
        Name = 'Unknown', 
        Icon = '', 
        FontStringIconSMALL='', 
    },
    Alchemy = { 
        ID = 1, 
        Name = 'Alchemy', 
        Icon = 'Interface\\Icons\\Trade_Alchemy', 
        IconID = 136240, 
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:3:67:3:67|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:3:67:3:67|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:3:67:3:67|t',
    },
    Blacksmithing = { 
        ID = 2, 
        Name = 'Blacksmithing', 
        Icon = 'Interface\\Icons\\Trade_Blacksmithing', 
        IconID = 136241,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:77:141:3:67|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:77:141:3:67|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:77:141:3:67|t',
    },
    Enchanting = { 
        ID = 3, 
        Name = 'Enchanting', 
        Icon = 'Interface\\Icons\\Trade_Engraving', 
        IconID = 136244,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:153:217:3:67|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:153:217:3:67|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:153:217:3:67|t',
    },
    Engineering = { 
        ID = 4, 
        Name = 'Engineering', 
        Icon = 'Interface\\Icons\\Trade_Engineering', 
        IconID = 136243,
        FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:227:291:3:67|t',
        FontStringIconMEDIUM='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:227:291:3:67|t',
        FontStringIconLARGE='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:227:291:3:67|t',
    },
    Inscription = { 
        ID = 5, 
        Name = 'Inscription', 
        Icon = 'Interface\\Icons\\INV_Inscription_Tradeskill01', 
        IconID = 237171,
        FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:3:67:79:143|t',
        FontStringIconMEDIUM='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:3:67:79:143|t',
        FontStringIconLARGE='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:3:67:79:143|t',
    },
    Jewelcrafting = { 
        ID = 6, 
        Name = 'Jewelcrafting', 
        Icon = 'Interface\\Icons\\INV_MISC_GEM_01', 
        IconID = 134071,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:77:141:79:143|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:77:141:79:143|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:77:141:79:143|t',
    },
    Leatherworking = { 
        ID = 7, 
        Name = 'Leatherworking', 
        Icon = 'Interface\\Icons\\INV_Misc_ArmorKit_17', 
        IconID = 136247,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:153:217:79:143|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:153:217:79:143|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:153:217:79:143|t',
    },
    Tailoring = { 
        ID = 8, 
        Name = 'Tailoring', 
        Icon = 'Interface\\Icons\\Trade_Tailoring', 
        IconID = 136249,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:227:291:79:143|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:227:291:79:143|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:227:291:79:143|t',
    },
    Herbalism = { 
        ID = 9, 
        Name = 'Herbalism', 
        Icon = 'Interface\\Icons\\INV_Misc_Flower_02', 
        IconID = 133939,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:38:102:153:217|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:38:102:153:217|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:38:102:153:217|t',
    },
    Skinning = { 
        ID = 10, 
        Name = 'Skinning', 
        Icon = 'Interface\\Icons\\INV_Misc_Pelt_Wolf_01', 
        IconID = 134366,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:187:251:153:217|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:187:251:153:217|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:187:251:153:217|t',
    },
    Mining = { 
        ID = 11, 
        Name = 'Mining', 
        Icon = 'Interface\\Icons\\Spell_Fire_FlameBlades',
        IconID = 136248, 
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:112:176:153:217|t',
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:112:176:153:217|t',
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:112:176:153:217|t',
    },
    Cooking = { 
        ID = 12, 
        Name = 'Cooking', 
        Icon = 'Interface\\Icons\\inv_misc_food_15', 
        IconID = 133971,
        FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:2:66:226:290|t',
        FontStringIconMEDIUM='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:2:66:226:290|t',
        FontStringIconLARGE='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:2:66:226:290|t',
    },
    Fishing = { 
        ID = 13, 
        Name = 'Fishing', 
        Icon = 'Interface\\Icons\\Trade_Fishing', 
        IconID = 136245,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:151:215:226:290|t', 
    },
    FirstAid = { 
        ID = 14, 
        Name = 'FirstAid', 
        Icon = 'Interface\\Icons\\Spell_Holy_SealOfSacrifice', 
        IconID = 135966,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:76:140:226:290|t', 
    },
    ["First Aid"] = { 
        ID = 14, 
        Name = 'FirstAid', 
        Icon = 'Interface\\Icons\\Spell_Holy_SealOfSacrifice', 
        IconID = 135966,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:76:140:226:290|t', 
    },
}

-- this is used to add prof names to player table, these should only be primary profs
Guildbook.Data.Professions = {
    { Name = 'Alchemy', TradeSkill = true, },
    { Name = 'Blacksmithing', TradeSkill = true, },
    { Name = 'Enchanting', TradeSkill = true, },
    { Name = 'Engineering', TradeSkill = true, },
    { Name = 'Inscription', TradeSkill = true, },
    { Name = 'Jewelcrafting', TradeSkill = true, },
    { Name = 'Leatherworking', TradeSkill = true, },
    { Name = 'Tailoring', TradeSkill = true, },
    { Name = 'Mining', TradeSkill = true, },
}

Guildbook.Data.SpecFontStringIconSMALL = { 
    DRUID = { 
        ['-'] = '', 
        Balance = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:0:63|t", 
        Bear = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", 
        Guardian = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", 
        Cat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", 
        Feral = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", 
        Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:126:188|t" 
    },
    DEATHKNIGHT = { 
        ['-'] = '', 
        Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:63:126|t", 
        Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:0:63|t", 
        Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:126:188|t"
    },
    ['DEATH KNIGHT'] = { 
        ['-'] = '', 
        Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:63:126|t", 
        Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:0:63|t", 
        Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:126:188|t"
    },
    HUNTER = { 
        ['-'] = '', 
        ['Beast Master'] = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:252:315:0:63|t", 
        Marksmanship = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:252:315:63:126|t", 
        Survival = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:252:315:126:188|t"
    },
    ROGUE = { 
        ['-'] = '', 
        Assassination = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:126:188:0:63|t", 
        Combat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:126:188:63:126|t", 
        Subtlety = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:126:188:126:188|t"
    },
    MAGE = { 
        ['-'] = '', 
        Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:63:126:126:188|t", 
        Fire = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:63:126:63:126|t", 
        Arcane = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:63:126:0:63|t"
    },
    PRIEST = { 
        ['-'] = '', 
        Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:378:441:63:126|t", 
        Discipline = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:378:441:0:63|t", 
        Shadow = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:378:441:126:188|t"
    },
    SHAMAN = { 
        ['-'] = '', 
        Elemental = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:315:378:0:63|t", 
        Enhancement = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:315:378:63:126|t", 
        Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:315:378:126:188|t" 
    },
    WARLOCK = { 
        ['-'] = '', 
        Demonology = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:441:504:63:126|t", 
        Affliction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:441:504:0:63|t", 
        Destruction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:441:504:126:188|t"
    },
    WARRIOR = { 
        ['-'] = '', 
        Arms = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:0:63:0:63|t", 
        Fury = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:0:63:63:126|t", 
        Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:0:63:126:188|t"
    },
    PALADIN = { 
        ['-'] = '', 
        Retribution = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:504:567:126:188|t", 
        Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:504:567:0:63|t", 
        Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:504:567:63:126|t"
    },
}

Guildbook.Data.SpecFontStringIconLARGE = { 
    DRUID = { 
        ['-'] = '', 
        Balance = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:0:63|t", 
        Bear = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:63:126|t", 
        Cat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:63:126|t", 
        Feral = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:63:126|t", 
        Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:126:188|t" 
    },
    DEATHKNIGHT = { 
        ['-'] = '', 
        Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:63:126|t", 
        Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:0:63|t", 
        Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:126:188|t"
    },
    ['DEATH KNIGHT'] = { 
        ['-'] = '', 
        Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:63:126|t", 
        Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:0:63|t", 
        Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:126:188|t"
    },
    HUNTER = { 
        ['-'] = '', 
        ['Beast Master'] = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:252:315:0:63|t",
        Marksmanship = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:252:315:63:126|t", 
        Survival = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:252:315:126:188|t"
    },
    ROGUE = { 
        ['-'] = '', 
        Assassination = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:126:188:0:63|t", 
        Combat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:126:188:63:126|t", 
        Outlaw = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:126:188:63:126|t", 
        Subtlety = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:126:188:126:188|t"
    },
    MAGE = { 
        ['-'] = '', 
        Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:63:126:126:188|t", 
        Fire = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:63:126:63:126|t", 
        Arcane = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:63:126:0:63|t"
    },
    PRIEST = { 
        ['-'] = '', 
        Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:378:441:63:126|t", 
        Discipline = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:378:441:0:63|t", 
        Shadow = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:378:441:126:188|t"
    },
    SHAMAN = { 
        ['-'] = '', 
        Elemental = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:315:378:0:63|t", 
        Enhancement = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:315:378:63:126|t", 
        Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:315:378:126:188|t" 
    },
    WARLOCK = { 
        ['-'] = '', 
        Demonology = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:441:504:63:126|t", 
        Affliction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:441:504:0:63|t", 
        Destruction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:441:504:126:188|t"
    },
    WARRIOR = { 
        ['-'] = '', 
        Arms = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:0:63:0:63|t", 
        Fury = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:0:63:63:126|t", 
        Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:0:63:126:188|t"
    },
    PALADIN = { 
        ['-'] = '', 
        Retribution = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:504:567:126:188|t", 
        Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:504:567:0:63|t", 
        Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:504:567:63:126|t"
    },
}

Guildbook.Data.SpecToRole = {
    DRUID = { 
        Restoration = L['Healer'], 
        Balance = L['Ranged'], 
        Cat = L['Melee'],  
        Bear = L['Tank'] , 
        unknown = 'Unknown',
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    SHAMAN = { 
        Elemental = L['Ranged'], 
        Enhancement = L['Melee'], 
        Restoration = L['Healer'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    HUNTER = { 
        Marksmanship = L['Ranged'], 
        ['Beast Master'] = L['Ranged'], 
        Survival = L['Ranged'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    PALADIN = { 
        Holy = L['Healer'], 
        Protection = L['Tank'] , 
        Retribution = L['Melee'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    WARRIOR = { 
        Arms = L['Melee'], 
        Fury = L['Melee'], 
        Protection = L['Tank'] , 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    ROGUE = { 
        Assassination = L['Melee'], 
        Combat = L['Melee'], 
        Subtlety = L['Melee'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    PRIEST = { 
        Holy = L['Healer'], 
        Discipline = L['Healer'], 
        Shadow = L['Ranged'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    WARLOCK = { 
        Demonology = L['Ranged'], 
        Affliction = L['Ranged'], 
        Destruction = L['Ranged'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    MAGE = { 
        Frost = L['Ranged'], 
        Fire = L['Ranged'], 
        Arcane = L['Ranged'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    DEATHKNIGHT = { 
        Frost = L['Tank'] , 
        Blood = L['Tank'] , 
        Unholy = L['Melee'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
    ['DEATH KNIGHT'] = { 
        Frost = L['Tank'] , 
        Blood = L['Tank'] , 
        Unholy = L['Melee'], 
        unknown = 'Unknown', 
        pvp = L['PVP'], 
        ['-'] = '-' 
    },
}

Guildbook.Data.RoleIcons = {
    Healer = { 
        Icon = '', 
        FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t", 
        FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:20:39:1:20|t" 
    },
    Tank = { 
        Icon = '', 
        FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t", 
        FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:0:19:22:41|t" 
    },
    Melee = { 
        Icon = '', 
        FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t", 
        FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:20:39:22:41|t" 
    },
    Ranged = { 
        Icon = '', 
        FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t", 
        FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:20:39:22:41|t" 
    },
    Damage = { 
        Icon = '', 
        FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t" 
    },
    ['-'] = { 
        Icon = '', 
        FontStringIcon = '', 
        FontStringIconLARGE = '' 
    },
}

Guildbook.Data.StatusIconStringsSMALL = {
    ['-'] = '',
	Offline = "|TInterface\\Addons\\Guildbook\\Icons\\OBJECTICONS:24:24:0:0:256:256:160:192:0:32|t", --red dot gold border
	Online = "|TInterface\\Addons\\Guildbook\\Icons\\OBJECTICONS:24:24:0:0:256:256:224:256:0:32|t", --green dot gold border
	Factions = "|TInterface\\Addons\\Guildbook\\Icons\\OBJECTICONS:24:24:0:0:256:256:64:96:64:96|t",
	PVP = "|TInterface\\Addons\\Guildbook\\Icons\\OBJECTICONS:24:24:0:0:256:256:32:64:192:224|t", --yellow swords crossed
    Skull = "|TInterface\\Addons\\Guildbook\\Icons\\OBJECTICONS:24:24:0:0:256:256:224:256:192:224|t",
    YellowQuestionMark = "|TInterface\\Addons\\Guildbook\\Icons\\OBJECTICONS:24:24:0:0:256:256:64:96:32:64|t",
    Mail = "|TInterface\\Addons\\Guildbook\\Icons\\OBJECTICONS:18:18:-1:-2:256:256:224:256:64:96|t",
}

Guildbook.Data.Availability = {
    [0] = L['Not Available'] ,
    [1] = L['Morning'],
    [2] = L['Afternoon'],
    [3] = L['Evening'],
}

Guildbook.EquipmentSlots = { 
    { Id = 1, Name = "Head", Pos = 0 },
    { Id = 2, Name = "Neck", Pos = 0 }, 
    { Id = 3, Name = "Shoulder", Pos = 0 }, 
    { Id = 15, Name = "Back", Pos = 0 }, 
    { Id = 5, Name = "Chest", Pos = 0 }, 
    { Id = 9, Name = "Wrist", Pos = 0 }, 
    { Id = 10, Name = "Hands", Pos = 1 }, 
    { Id = 6, Name = "Waist", Pos = 1 }, 
    { Id = 7, Name = "Legs", Pos = 1 }, 
    { Id = 8, Name = "Feet", Pos = 1 }, 
    { Id = 11, Name = "Ring 1", Pos = 1 }, 
    { Id = 12, Name = "Ring 2", Pos = 1 }, 
    { Id = 13, Name = "Trinket 1", Pos = 1 }, 
    { Id = 14, Name = "Trinket 2", Pos = 1 }, 
    { Id = 16, Name = "Main Hand", Pos = 0 }, 
    { Id = 17, Name = "Off Hand", Pos = 0 },
    { Id = 18, Name = "Ranged", Pos = 0 }
}

--local x = radius * math.cos(buff.Angle)
--local y = radius * math.sin(buff.Angle)
--pos was an old value used to determine display position
Guildbook.Data.InventorySlots = {
    { Name = 'HEADSLOT', Constant = 'INVSLOT_HEAD', Angle = 2.3, offsetX = -21.0, offsetY = 100.0 },
    { Name = 'NECKSLOT', Constant = 'INVSLOT_NECK', Angle = 2.6, offsetX = -35.0, offsetY = 67.0 },
    { Name = 'SHOULDERSLOT', Constant = 'INVSLOT_SHOULDER', Angle = 2.9, offsetX = -42.0, offsetY = 34.0 },
    { Name = 'BACKSLOT', Constant = 'INVSLOT_BACK', Angle = 0.2, offsetX = -46.0, offsetY = 1.0 },
    { Name = 'CHESTSLOT', Constant = 'INVSLOT_CHEST', Angle = 3.1, offsetX = -46.0, offsetY = -32.0 },
    { Name = 'SHIRTSLOT', Constant = 'INVSLOT_BODY', Angle = 4.3, offsetX = -42.0, offsetY = -65.0 },
    { Name = 'TABARDSLOT', Constant = 'INVSLOT_TABARD', Angle = 4.3, offsetX = -35.0, offsetY = -98.0 },
    { Name = 'WRISTSLOT', Constant = 'INVSLOT_WRIST', Angle = 4.3, offsetX = -21.0, offsetY = -131.0 },

    { Name = 'HANDSSLOT', Constant = 'INVSLOT_HAND', Angle = 1.7, offsetX = 221.0, offsetY = 100.0 },
    { Name = 'WAISTSLOT', Constant = 'INVSLOT_WAIST', Angle = 3.4, offsetX = 235.0, offsetY = 67.0 },
    { Name = 'LEGSSLOT', Constant = 'INVSLOT_LEGS', Angle = 3.7, offsetX = 242.0, offsetY = 34.0 },
    { Name = 'FEETSLOT', Constant = 'INVSLOT_FEET', Angle = 4.0, offsetX = 246.0, offsetY = 1.0 },
    { Name = 'FINGER0SLOT', Constant = 'INVSLOT_FINGER1', Angle = 1.4, offsetX = 246.0, offsetY = -32.0 },
    { Name = 'FINGER1SLOT', Constant = 'INVSLOT_FINGER2', Angle = 1.1, offsetX = 242.0, offsetY = -65.0 },
    { Name = 'TRINKET0SLOT', Constant = 'INVSLOT_TRINKET1', Angle = 0.8, offsetX = 235.0, offsetY = -98.0 },
    { Name = 'TRINKET1SLOT', Constant = 'INVSLOT_TRINKET2', Angle = 0.5, offsetX = 221.0, offsetY = -131.0 },

    { Name = 'MAINHANDSLOT', Angle = -3.9, offsetX = 48.0, offsetY = -125.0 },
    { Name = 'SECONDARYHANDSLOT', Angle = -2.9, offsetX = 152.0, offsetY = -125.0 },
    { Name = 'RANGEDSLOT', Angle = 0.9, offsetX = 100.0, offsetY = -135.0 },
}

Guildbook.Data.InventorySlotNames = {
    { Name = 'HEADSLOT'},
    { Name = 'NECKSLOT'},
    { Name = 'SHOULDERSLOT'},
    { Name = 'BACKSLOT'},
    { Name = 'CHESTSLOT'},
    { Name = 'SHIRTSLOT'},
    { Name = 'TABARDSLOT'},
    { Name = 'WRISTSLOT'},

    { Name = 'MAINHANDSLOT'},
    { Name = 'RANGEDSLOT'},

    { Name = 'HANDSSLOT'},
    { Name = 'WAISTSLOT'},
    { Name = 'LEGSSLOT'},
    { Name = 'FEETSLOT'},
    { Name = 'FINGER0SLOT'},
    { Name = 'FINGER1SLOT'},
    { Name = 'TRINKET0SLOT'},
    { Name = 'TRINKET1SLOT'},

    { Name = 'SECONDARYHANDSLOT'},
}

Guildbook.Data.ProfessionDescriptions = {
    Alchemy = 'Mix potions, elixirs, flasks, oils and other alchemical substances into vials using herbs and other reagents. Your concoctions can restore health and mana, enhance attributes, or provide any number of other useful (or not-so-useful) effects. High level alchemists can also transmute essences and metals into other essences and metals. Alchemists can specialize as a Master of Potions, Master of Elixirs, or a Master of Transmutation.',
    Blacksmithing = 'Smith various melee weapons, mail and plate armor, and other useful trade goods like skeleton keys, shield-spikes and weapon chains to prevent disarming. Blacksmiths can also make various stones to provide temporary physical buffs to weapons.',
    Enchanting = 'Imbue all manner of equipable items with magical properties and enhancements using dusts, essences and shards gained by disenchanting (breaking down) magical items that are no longer useful. Enchanters can also make a few low-level wands, as well as oils that can be applied to weapons providing a temporary magical buff.',
    Engineering = 'Engineer a wide range of mechanical devices—including trinkets, guns, goggles, explosives and mechanical pets—using metal, minerals, and stone. As most engineering products can only be used by suitably adept engineers, it is not as profitable as the other professions; it is, however, often taken to be one of the most entertaining, affording its adherents with numerous unconventional and situationally useful abilities. Engineers can specialize as Goblin or Gnomish engineers.',
    Inscription = "Inscribe glyphs that modify existing spells and abilities for all classes, in addition to various scrolls, staves, playing cards and off-hand items. A scribe can also create vellums for the storing of an Enchanter\'s spells and scribe-only scrolls used to teleport around the world (albeit a tad randomly). Also teaches you the [Milling] ability, which crushes herbs into various pigments used, in turn, for a scribe's ink."	,
    Jewelcrafting = 'Cut and polish powerful gems that can be socketed into armor and weapons to augment their attributes or fashioned into rings, necklaces, trinkets, and jeweled headpieces. Also teaches you the [Prospecting] ability, which sifts through raw ores to uncover the precious gems needed for your craft.',
    Leatherworking = 'Work leather and hides into goods such as leather and mail armor, armor kits, and some capes. Leatherworkers can also produce a number of utility items including large profession bags, ability-augmenting drums, and riding crops to increase mount speed.'	,
    Tailoring = 'Sew cloth armor and many kinds of bags using dye, thread and cloth gathered from humanoid enemies during your travels. Tailors can also fashion nets to slow enemies with, rideable flying carpets, and magical threads which empower items they are stitched into.',
    Cooking = '',
    Mining = '',
}

Guildbook.CalendarWorldEvents = {
	[L["DARKMOON_FAIRE"]] = {
		['Elwynn'] = {
			['Start'] = 235448,
			['OnGoing'] = 235447,
			['End'] = 235446,
		},
		['Mulgore'] = {
			['Start'] = 235451,
			['OnGoing'] = 235450,
			['End'] = 235449,
		},
	},
	[L["LOVE IS IN THE AIR"]] = {
		['Start'] = { 
			day = 7, 
			month = 2,
		},
		['End'] = { 
			day = 20, 
			month = 2,
		},
		['Texture'] = {
			['Start'] = 235468,
			['OnGoing'] = 235467,
			['End'] = 235466,
		}
	},
	[L["CHILDRENS_WEEK"]] = {
		['Start'] = { 
			day = 1, 
			month = 5,
		},
		['End'] = { 
			day = 7, 
			month = 5,
		},
		['Texture'] = {
			['Start'] = 235445,
			['OnGoing'] = 235444,
			['End'] = 235443,
		}
	},
	[L["MIDSUMMER_FIRE_FESTIVAL"]] = {
		['Start'] = { 
			day = 20, 
			month = 7,
		},
		['End'] = { 
			day = 3, 
			month = 8,
		},
		['Texture'] = {
			['Start'] = 235474,
			['OnGoing'] = 235473,
			['End'] = 235472,
		}
	},
	[L["HARVEST_FESTIVAL"]] = {
		['Start'] = { 
			day = 27, 
			month = 9,
		},
		['End'] = { 
			day = 4, 
			month = 10,
		},
		['Texture'] = {
			['Start'] = 235465,
			['OnGoing'] = 235464,
			['End'] = 235463,
		}
	},
	[L["HALLOWS_END"]] = {
		['Start'] = { 
			day = 18, 
			month = 10,
		},
		['End'] = { 
			day = 2, 
			month = 11,
		},
		['Texture'] = {
			['Start'] = 235462,
			['OnGoing'] = 235461,
			['End'] = 235460,
		}
	},
	[L["FEAST_OF_WINTER_VEIL"]] = {
		['Start'] = { 
			day = 15, 
			month = 12,
		},
		['End'] = { 
			day = 2, 
			month = 1,
		},
		['Texture'] = {
			['Start'] = 235485,
			['OnGoing'] = 235484,
			['End'] = 235482,
		}
	},
}

Guildbook.Data.Factions = {
    ['Alliance'] = {
        'HUMAN',
        'NIGHTELF',
        'GNOME',
        'DWARF',
        'DRAENEI'
    },
    ['Horde'] = {
        'BLOODELF',
        'ORC',
        'TROLL',
        'SCOURGE',
        'TAUREN',
    },
}

Guildbook.RaceBackgrounds = {
    ['BLOODELF'] = { 
        IconID = 131921, 
        FileName = 'interface/glues/models/ui_bloodelf/ui_bloodelf.m2', 
    },
    ['DRAENEI'] = { 
        IconID = 131934, 
        FileName = 'interface/glues/models/ui_draenei/ui_draenei.m2', 
    },
    ['DWARF'] = { 
        IconID = 131940, 
        FileName = 'interface/glues/models/ui_dwarf/ui_dwarf.m2', 
    },
    ['HUMAN'] = { 
        IconID = 131948, 
        FileName = 'interface/glues/models/ui_human/ui_human.m2', 
    },
    ['TBC'] = { 
        IconID = 131982, 
        FileName = 'interface/glues/models/ui_mainmenu_burningcrusade/ui_mainmenu_burningcrusade.m2', 
    },
    ['NIGHTELF'] = { 
        IconID = 131993, 
        FileName = 'interface/glues/models/ui_nightelf/ui_nightelf.m2',
    },
    ['ORC'] = { 
        IconID = 132003, 
        FileName = 'interface/glues/models/ui_orc/ui_orc.m2', 
    },
    ['SCOURGE'] = { 
        IconID = 132035, 
        FileName = 'interface/glues/models/ui_scourge/ui_scourge.m2', 
    },
    ['TAUREN'] = { 
        IconID = 132046, 
        FileName = 'interface/glues/models/ui_tauren/ui_tauren.m2', 
    },
    ['DEATHKNIGHT'] = { 
        IconID = 236082, 
        FileName = 'interface/glues/models/ui_deathknight/ui_deathknight.m2', 
    },
    ['WRATH'] = { 
        IconID = 236122, 
        FileName = 'interface/glues/models/ui_mainmenu_northrend/ui_mainmenu_northrend.m2', 
    },
    ['WORGEN'] = { 
        IconID = 313254, 
        FileName = 'interface/glues/models/ui_worgen/ui_worgen.m2', 
    },
    ['GOBLIN'] = { 
        IconID = 319097, 
        FileName = 'interface/glues/models/ui_goblin/ui_goblin.m2', 
    },
    ['CHARACTERSELECT'] = { 
        IconID = 343630, 
        FileName = 'interface/glues/models/ui_characterselect/ui_characterselect.m2', 
    },
    ['TROLL'] = { 
        IconID = 429097, 
        FileName = 'interface/glues/models/ui_troll/ui_troll.m2', 
    },
    ['GNOME'] = { 
        IconID = 430171, 
        FileName = 'interface/glues/models/ui_gnome/ui_gnome.m2', 
    },
    
}
