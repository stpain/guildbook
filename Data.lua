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
    PaperDollStats = {
        Current = {},
    },
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
    -- DEATHKNIGHT = { 
    --     FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:128:192|t", 
    --     FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:128:192|t", 
    --     FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:128:192|t", 
    --     IconID = 135771, 
    --     Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DEATHKNIGHT", 
    --     RGB={ 0.77, 0.12, 0.23 }, 
    --     FontColour='|cffC41F3B', 
    --     Specializations={'Frost','Blood','Unholy', "Frost (Tank)"} 
    -- },
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
        Specializations={'Balance','Cat' ,'Bear', 'Restoration',}
    },
    HUNTER = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:64:128|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:64:128|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:64:128|t", 
        IconID = 626000, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\HUNTER", 
        RGB={ 0.67, 0.83, 0.45 }, 
        FontColour='|cffABD473', 
        Specializations={'Beast Master', 'Marksmanship','Survival',} 
    },
    MAGE = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:0:64|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:0:64|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:0:64|t", 
        IconID = 626001, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\MAGE", 
        RGB={ 0.25, 0.78, 0.92 }, 
        FontColour='|cff40C7EB', 
        Specializations={'Arcane', 'Fire','Frost',} 
    },
    PALADIN = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:128:192|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:128:192|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:128:192|t", 
        IconID = 626003, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\PALADIN", 
        RGB={ 0.96, 0.55, 0.73 }, 
        FontColour='|cffF58CBA', 
        Specializations={'Holy','Protection','Retribution',} 
    },
    PRIEST = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:128:192:64:128|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:128:192:64:128|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:128:192:64:128|t", 
        IconID = 626004, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\PRIEST", 
        RGB={ 1.00, 1.00, 1.00 }, 
        FontColour='|cffFFFFFF', 
        Specializations={'Discipline','Holy','Shadow',} 
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
        Specializations={'Elemental', 'Enhancement', 'Restoration', 'Warden'} 
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
        Specializations={'Arms','Fury','Protection',} 
    },
}

Guildbook.Data.Talents = {}


Guildbook.Data.TalentTabsToBackground = {
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

Guildbook.Data.ProfSpecToProfId = {
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
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:76:140:226:290|t', 
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:76:140:226:290|t',
    },
    ["First Aid"] = { 
        ID = 14,  --?
        Name = 'FirstAid', 
        Icon = 'Interface\\Icons\\Spell_Holy_SealOfSacrifice', 
        IconID = 135966,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:76:140:226:290|t', 
        FontStringIconMEDIUM ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:18:18:0:0:512:512:76:140:226:290|t', 
        FontStringIconLARGE ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:28:28:0:0:512:512:76:140:226:290|t', 
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

    { Name = 'MAINHANDSLOT'},
    { Name = 'SECONDARYHANDSLOT'},
    { Name = 'RANGEDSLOT'},
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


Guildbook.DarkmoonFaireSchedule = {}
Guildbook.DarkmoonFaireSchedule[2021] = {
    [1] = {
        start = 4,
        ends = 10,
        location = "Elwynn",
    },
    [2] = {
        start = 8,
        ends = 14,
        location = "Mulgore",
    },
    [3] = {
        start = 8,
        ends = 14,
        location = "Elwynn",
    },
    [4] = {
        start = 5,
        ends = 11,
        location = "Mulgore",
    },
    [5] = {
        start = 10,
        ends = 16,
        location = "Elwynn",
    },
    [6] = {
        start = 7,
        ends = 13,
        location = "Mulgore",
    },
    [7] = {
        start = 5,
        ends = 11,
        location = "Elwynn",
    },
    [8] = {
        start = 9,
        ends = 15,
        location = "Terokkar",
    },
    [9] = {
        start = 6,
        ends = 12,
        location = "Elwynn",
    },
    [10] = {
        start = 4,
        ends = 10,
        location = "Mulgore",
    },
    [11] = {
        start = 8,
        ends = 14,
        location = "Terokkar",
    },
    [12] = {
        start = 6,
        ends = 12,
        location = "Elwynn",
    },
}
    -- this is a guess at the 2022 schedule
Guildbook.DarkmoonFaireSchedule[2022] = {
    [1] = {
        start = 10,
        ends = 16,
        location = "Mulgore",
    },
    [2] = {
        start = 7,
        ends = 13,
        location = "Terokkar",
    },
    [3] = {
        start = 7,
        ends = 13,
        location = "Elwynn",
    },
    [4] = {
        start = 4,
        ends = 10,
        location = "Mulgore",
    },
    [5] = {
        start = 9,
        ends = 15,
        location = "Terokkar",
    },
    [6] = {
        start = 6,
        ends = 12,
        location = "Elwynn",
    },
    [7] = {
        start = 4,
        ends = 10,
        location = "Mulgore",
    },
    [8] = {
        start = 8,
        ends = 14,
        location = "Terokkar",
    },
    [9] = {
        start = 5,
        ends = 11,
        location = "Elwynn",
    },
    [10] = {
        start = 10,
        ends = 16,
        location = "Mulgore",
    },
    [11] = {
        start = 7,
        ends = 13,
        location = "Terokkar",
    },
    [12] = {
        start = 5,
        ends = 11,
        location = "Elwynn",
    },
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
		['Terokkar'] = {
			['Start'] = 235455,
			['OnGoing'] = 235454,
			['End'] = 235453,
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
	[L["BREWFEST"]] = {
		['Start'] = { 
			day = 20, 
			month = 9,
		},
		['End'] = { 
			day = 6, 
			month = 10,
		},
		['Texture'] = {
			['Start'] = 235442,
			['OnGoing'] = 235441,
			['End'] = 235440,
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


--[[
    big project to take on here but making the avatars filterable etc will be a big help - also can be used to help with hsl dev
]]
Guildbook.Data.Avatars = {
    {
        ["race"] = "",
        ["fileID"] = 1066003,
    }, -- [1]
    {
        ["race"] = "",
        ["fileID"] = 1066004,
    }, -- [2]
    {
        ["race"] = "",
        ["fileID"] = 1066005,
    }, -- [3]
    {
        ["race"] = "",
        ["fileID"] = 1066006,
    }, -- [4]
    {
        ["race"] = "",
        ["fileID"] = 1066007,
    }, -- [5]
    {
        ["race"] = "",
        ["fileID"] = 1066008,
    }, -- [6]
    {
        ["race"] = "",
        ["fileID"] = 1066009,
    }, -- [7]
    {
        ["race"] = "",
        ["fileID"] = 1066010,
    }, -- [8]
    {
        ["race"] = "",
        ["fileID"] = 1066011,
    }, -- [9]
    {
        ["race"] = "",
        ["fileID"] = 1066012,
    }, -- [10]
    {
        ["race"] = "",
        ["fileID"] = 1066013,
    }, -- [11]
    {
        ["race"] = "",
        ["fileID"] = 1066014,
    }, -- [12]
    {
        ["race"] = "",
        ["fileID"] = 1066015,
    }, -- [13]
    {
        ["race"] = "",
        ["fileID"] = 1066016,
    }, -- [14]
    {
        ["race"] = "",
        ["fileID"] = 1066017,
    }, -- [15]
    {
        ["race"] = "",
        ["fileID"] = 1066018,
    }, -- [16]
    {
        ["race"] = "",
        ["fileID"] = 1066019,
    }, -- [17]
    {
        ["race"] = "",
        ["fileID"] = 1066020,
    }, -- [18]
    {
        ["race"] = "",
        ["fileID"] = 1066021,
    }, -- [19]
    {
        ["race"] = "",
        ["fileID"] = 1066022,
    }, -- [20]
    {
        ["race"] = "",
        ["fileID"] = 1066023,
    }, -- [21]
    {
        ["race"] = "",
        ["fileID"] = 1066024,
    }, -- [22]
    {
        ["race"] = "",
        ["fileID"] = 1066026,
    }, -- [23]
    {
        ["race"] = "",
        ["fileID"] = 1066027,
    }, -- [24]
    {
        ["race"] = "",
        ["fileID"] = 1066028,
    }, -- [25]
    {
        ["race"] = "",
        ["fileID"] = 1066029,
    }, -- [26]
    {
        ["race"] = "",
        ["fileID"] = 1066030,
    }, -- [27]
    {
        ["race"] = "",
        ["fileID"] = 1066031,
    }, -- [28]
    {
        ["race"] = "",
        ["fileID"] = 1066032,
    }, -- [29]
    {
        ["race"] = "",
        ["fileID"] = 1066033,
    }, -- [30]
    {
        ["race"] = "",
        ["fileID"] = 1066034,
    }, -- [31]
    {
        ["race"] = "",
        ["fileID"] = 1066035,
    }, -- [32]
    {
        ["race"] = "",
        ["fileID"] = 1066037,
    }, -- [33]
    {
        ["race"] = "",
        ["fileID"] = 1066038,
    }, -- [34]
    {
        ["race"] = "",
        ["fileID"] = 1066040,
    }, -- [35]
    {
        ["race"] = "",
        ["fileID"] = 1066041,
    }, -- [36]
    {
        ["race"] = "",
        ["fileID"] = 1066042,
    }, -- [37]
    {
        ["race"] = "",
        ["fileID"] = 1066043,
    }, -- [38]
    {
        ["race"] = "",
        ["fileID"] = 1066044,
    }, -- [39]
    {
        ["race"] = "",
        ["fileID"] = 1066046,
    }, -- [40]
    {
        ["race"] = "",
        ["fileID"] = 1066047,
    }, -- [41]
    {
        ["race"] = "",
        ["fileID"] = 1066048,
    }, -- [42]
    {
        ["race"] = "",
        ["fileID"] = 1066049,
    }, -- [43]
    {
        ["race"] = "",
        ["fileID"] = 1066050,
    }, -- [44]
    {
        ["race"] = "",
        ["fileID"] = 1066052,
    }, -- [45]
    {
        ["race"] = "",
        ["fileID"] = 1066053,
    }, -- [46]
    {
        ["race"] = "",
        ["fileID"] = 1066054,
    }, -- [47]
    {
        ["race"] = "",
        ["fileID"] = 1066055,
    }, -- [48]
    {
        ["race"] = "",
        ["fileID"] = 1066056,
    }, -- [49]
    {
        ["race"] = "",
        ["fileID"] = 1066057,
    }, -- [50]
    {
        ["race"] = "",
        ["fileID"] = 1066058,
    }, -- [51]
    {
        ["race"] = "",
        ["fileID"] = 1066059,
    }, -- [52]
    {
        ["race"] = "",
        ["fileID"] = 1066060,
    }, -- [53]
    {
        ["race"] = "",
        ["fileID"] = 1066061,
    }, -- [54]
    {
        ["race"] = "",
        ["fileID"] = 1066062,
    }, -- [55]
    {
        ["race"] = "",
        ["fileID"] = 1066063,
    }, -- [56]
    {
        ["race"] = "",
        ["fileID"] = 1066064,
    }, -- [57]
    {
        ["race"] = "",
        ["fileID"] = 1066065,
    }, -- [58]
    {
        ["race"] = "",
        ["fileID"] = 1066066,
    }, -- [59]
    {
        ["race"] = "",
        ["fileID"] = 1066067,
    }, -- [60]
    {
        ["race"] = "",
        ["fileID"] = 1066068,
    }, -- [61]
    {
        ["race"] = "",
        ["fileID"] = 1066069,
    }, -- [62]
    {
        ["race"] = "",
        ["fileID"] = 1066070,
    }, -- [63]
    {
        ["race"] = "",
        ["fileID"] = 1066071,
    }, -- [64]
    {
        ["race"] = "",
        ["fileID"] = 1066073,
    }, -- [65]
    {
        ["race"] = "",
        ["fileID"] = 1066074,
    }, -- [66]
    {
        ["race"] = "",
        ["fileID"] = 1066075,
    }, -- [67]
    {
        ["race"] = "",
        ["fileID"] = 1066076,
    }, -- [68]
    {
        ["race"] = "",
        ["fileID"] = 1066078,
    }, -- [69]
    {
        ["race"] = "",
        ["fileID"] = 1066079,
    }, -- [70]
    {
        ["race"] = "",
        ["fileID"] = 1066080,
    }, -- [71]
    {
        ["race"] = "",
        ["fileID"] = 1066081,
    }, -- [72]
    {
        ["race"] = "",
        ["fileID"] = 1066082,
    }, -- [73]
    {
        ["race"] = "",
        ["fileID"] = 1066083,
    }, -- [74]
    {
        ["race"] = "",
        ["fileID"] = 1066084,
    }, -- [75]
    {
        ["race"] = "",
        ["fileID"] = 1066085,
    }, -- [76]
    {
        ["race"] = "",
        ["fileID"] = 1066086,
    }, -- [77]
    {
        ["race"] = "",
        ["fileID"] = 1066087,
    }, -- [78]
    {
        ["race"] = "",
        ["fileID"] = 1066089,
    }, -- [79]
    {
        ["race"] = "",
        ["fileID"] = 1066090,
    }, -- [80]
    {
        ["race"] = "",
        ["fileID"] = 1066091,
    }, -- [81]
    {
        ["race"] = "",
        ["fileID"] = 1066092,
    }, -- [82]
    {
        ["race"] = "",
        ["fileID"] = 1066093,
    }, -- [83]
    {
        ["race"] = "",
        ["fileID"] = 1066094,
    }, -- [84]
    {
        ["race"] = "",
        ["fileID"] = 1066095,
    }, -- [85]
    {
        ["race"] = "",
        ["fileID"] = 1066097,
    }, -- [86]
    {
        ["race"] = "",
        ["fileID"] = 1066098,
    }, -- [87]
    {
        ["race"] = "",
        ["fileID"] = 1066099,
    }, -- [88]
    {
        ["race"] = "",
        ["fileID"] = 1066100,
    }, -- [89]
    {
        ["race"] = "",
        ["fileID"] = 1066101,
    }, -- [90]
    {
        ["race"] = "",
        ["fileID"] = 1066103,
    }, -- [91]
    {
        ["race"] = "",
        ["fileID"] = 1066104,
    }, -- [92]
    {
        ["race"] = "",
        ["fileID"] = 1066105,
    }, -- [93]
    {
        ["race"] = "",
        ["fileID"] = 1066106,
    }, -- [94]
    {
        ["race"] = "",
        ["fileID"] = 1066107,
    }, -- [95]
    {
        ["race"] = "",
        ["fileID"] = 1066108,
    }, -- [96]
    {
        ["race"] = "",
        ["fileID"] = 1066109,
    }, -- [97]
    {
        ["race"] = "",
        ["fileID"] = 1066110,
    }, -- [98]
    {
        ["race"] = "",
        ["fileID"] = 1066111,
    }, -- [99]
    {
        ["race"] = "",
        ["fileID"] = 1066112,
    }, -- [100]
    {
        ["race"] = "",
        ["fileID"] = 1066113,
    }, -- [101]
    {
        ["race"] = "",
        ["fileID"] = 1066114,
    }, -- [102]
    {
        ["race"] = "",
        ["fileID"] = 1066115,
    }, -- [103]
    {
        ["race"] = "",
        ["fileID"] = 1066116,
    }, -- [104]
    {
        ["race"] = "",
        ["fileID"] = 1066118,
    }, -- [105]
    {
        ["race"] = "",
        ["fileID"] = 1066119,
    }, -- [106]
    {
        ["race"] = "",
        ["fileID"] = 1066120,
    }, -- [107]
    {
        ["race"] = "",
        ["fileID"] = 1066121,
    }, -- [108]
    {
        ["race"] = "",
        ["fileID"] = 1066122,
    }, -- [109]
    {
        ["race"] = "",
        ["fileID"] = 1066123,
    }, -- [110]
    {
        ["race"] = "",
        ["fileID"] = 1066124,
    }, -- [111]
    {
        ["race"] = "",
        ["fileID"] = 1066125,
    }, -- [112]
    {
        ["race"] = "",
        ["fileID"] = 1066126,
    }, -- [113]
    {
        ["race"] = "",
        ["fileID"] = 1066127,
    }, -- [114]
    {
        ["race"] = "",
        ["fileID"] = 1066128,
    }, -- [115]
    {
        ["race"] = "",
        ["fileID"] = 1066129,
    }, -- [116]
    {
        ["race"] = "",
        ["fileID"] = 1066130,
    }, -- [117]
    {
        ["race"] = "",
        ["fileID"] = 1066131,
    }, -- [118]
    {
        ["race"] = "",
        ["fileID"] = 1066132,
    }, -- [119]
    {
        ["race"] = "",
        ["fileID"] = 1066133,
    }, -- [120]
    {
        ["race"] = "",
        ["fileID"] = 1066134,
    }, -- [121]
    {
        ["race"] = "",
        ["fileID"] = 1066135,
    }, -- [122]
    {
        ["race"] = "",
        ["fileID"] = 1066136,
    }, -- [123]
    {
        ["race"] = "",
        ["fileID"] = 1066137,
    }, -- [124]
    {
        ["race"] = "",
        ["fileID"] = 1066138,
    }, -- [125]
    {
        ["race"] = "",
        ["fileID"] = 1066139,
    }, -- [126]
    {
        ["race"] = "",
        ["fileID"] = 1066140,
    }, -- [127]
    {
        ["race"] = "",
        ["fileID"] = 1066141,
    }, -- [128]
    {
        ["race"] = "",
        ["fileID"] = 1066142,
    }, -- [129]
    {
        ["race"] = "",
        ["fileID"] = 1066143,
    }, -- [130]
    {
        ["race"] = "",
        ["fileID"] = 1066144,
    }, -- [131]
    {
        ["race"] = "",
        ["fileID"] = 1066145,
    }, -- [132]
    {
        ["race"] = "",
        ["fileID"] = 1066146,
    }, -- [133]
    {
        ["race"] = "",
        ["fileID"] = 1066147,
    }, -- [134]
    {
        ["race"] = "",
        ["fileID"] = 1066148,
    }, -- [135]
    {
        ["race"] = "",
        ["fileID"] = 1066149,
    }, -- [136]
    {
        ["race"] = "",
        ["fileID"] = 1066150,
    }, -- [137]
    {
        ["race"] = "",
        ["fileID"] = 1066151,
    }, -- [138]
    {
        ["race"] = "",
        ["fileID"] = 1066152,
    }, -- [139]
    {
        ["race"] = "",
        ["fileID"] = 1066153,
    }, -- [140]
    {
        ["race"] = "",
        ["fileID"] = 1066154,
    }, -- [141]
    {
        ["race"] = "",
        ["fileID"] = 1066156,
    }, -- [142]
    {
        ["race"] = "",
        ["fileID"] = 1066158,
    }, -- [143]
    {
        ["race"] = "",
        ["fileID"] = 1066159,
    }, -- [144]
    {
        ["race"] = "",
        ["fileID"] = 1066160,
    }, -- [145]
    {
        ["race"] = "",
        ["fileID"] = 1066161,
    }, -- [146]
    {
        ["race"] = "",
        ["fileID"] = 1066162,
    }, -- [147]
    {
        ["race"] = "",
        ["fileID"] = 1066163,
    }, -- [148]
    {
        ["race"] = "",
        ["fileID"] = 1066164,
    }, -- [149]
    {
        ["race"] = "",
        ["fileID"] = 1066165,
    }, -- [150]
    {
        ["race"] = "",
        ["fileID"] = 1066166,
    }, -- [151]
    {
        ["race"] = "",
        ["fileID"] = 1066167,
    }, -- [152]
    {
        ["race"] = "",
        ["fileID"] = 1066168,
    }, -- [153]
    {
        ["race"] = "",
        ["fileID"] = 1066169,
    }, -- [154]
    {
        ["race"] = "",
        ["fileID"] = 1066170,
    }, -- [155]
    {
        ["race"] = "",
        ["fileID"] = 1066171,
    }, -- [156]
    {
        ["race"] = "",
        ["fileID"] = 1066172,
    }, -- [157]
    {
        ["race"] = "",
        ["fileID"] = 1066173,
    }, -- [158]
    {
        ["race"] = "",
        ["fileID"] = 1066174,
    }, -- [159]
    {
        ["race"] = "",
        ["fileID"] = 1066175,
    }, -- [160]
    {
        ["race"] = "",
        ["fileID"] = 1066176,
    }, -- [161]
    {
        ["race"] = "",
        ["fileID"] = 1066177,
    }, -- [162]
    {
        ["race"] = "",
        ["fileID"] = 1066178,
    }, -- [163]
    {
        ["race"] = "",
        ["fileID"] = 1066179,
    }, -- [164]
    {
        ["race"] = "",
        ["fileID"] = 1066180,
    }, -- [165]
    {
        ["race"] = "",
        ["fileID"] = 1066181,
    }, -- [166]
    {
        ["race"] = "",
        ["fileID"] = 1066182,
    }, -- [167]
    {
        ["race"] = "",
        ["fileID"] = 1066183,
    }, -- [168]
    {
        ["race"] = "",
        ["fileID"] = 1066184,
    }, -- [169]
    {
        ["race"] = "",
        ["fileID"] = 1066185,
    }, -- [170]
    {
        ["race"] = "",
        ["fileID"] = 1066186,
    }, -- [171]
    {
        ["race"] = "",
        ["fileID"] = 1066187,
    }, -- [172]
    {
        ["race"] = "",
        ["fileID"] = 1066188,
    }, -- [173]
    {
        ["race"] = "",
        ["fileID"] = 1066189,
    }, -- [174]
    {
        ["race"] = "",
        ["fileID"] = 1066190,
    }, -- [175]
    {
        ["race"] = "",
        ["fileID"] = 1066191,
    }, -- [176]
    {
        ["race"] = "",
        ["fileID"] = 1066192,
    }, -- [177]
    {
        ["race"] = "",
        ["fileID"] = 1066193,
    }, -- [178]
    {
        ["race"] = "",
        ["fileID"] = 1066194,
    }, -- [179]
    {
        ["race"] = "",
        ["fileID"] = 1066195,
    }, -- [180]
    {
        ["race"] = "",
        ["fileID"] = 1066196,
    }, -- [181]
    {
        ["race"] = "",
        ["fileID"] = 1066197,
    }, -- [182]
    {
        ["race"] = "",
        ["fileID"] = 1066198,
    }, -- [183]
    {
        ["race"] = "",
        ["fileID"] = 1066199,
    }, -- [184]
    {
        ["race"] = "",
        ["fileID"] = 1066200,
    }, -- [185]
    {
        ["race"] = "",
        ["fileID"] = 1066201,
    }, -- [186]
    {
        ["race"] = "",
        ["fileID"] = 1066202,
    }, -- [187]
    {
        ["race"] = "",
        ["fileID"] = 1066203,
    }, -- [188]
    {
        ["race"] = "",
        ["fileID"] = 1066204,
    }, -- [189]
    {
        ["race"] = "",
        ["fileID"] = 1066205,
    }, -- [190]
    {
        ["race"] = "",
        ["fileID"] = 1066206,
    }, -- [191]
    {
        ["race"] = "",
        ["fileID"] = 1066207,
    }, -- [192]
    {
        ["race"] = "",
        ["fileID"] = 1066208,
    }, -- [193]
    {
        ["race"] = "",
        ["fileID"] = 1066209,
    }, -- [194]
    {
        ["race"] = "",
        ["fileID"] = 1066210,
    }, -- [195]
    {
        ["race"] = "",
        ["fileID"] = 1066211,
    }, -- [196]
    {
        ["race"] = "",
        ["fileID"] = 1066212,
    }, -- [197]
    {
        ["race"] = "",
        ["fileID"] = 1066213,
    }, -- [198]
    {
        ["race"] = "",
        ["fileID"] = 1066214,
    }, -- [199]
    {
        ["race"] = "",
        ["fileID"] = 1066215,
    }, -- [200]
    {
        ["race"] = "",
        ["fileID"] = 1066216,
    }, -- [201]
    {
        ["race"] = "",
        ["fileID"] = 1066217,
    }, -- [202]
    {
        ["race"] = "",
        ["fileID"] = 1066218,
    }, -- [203]
    {
        ["race"] = "",
        ["fileID"] = 1066219,
    }, -- [204]
    {
        ["race"] = "",
        ["fileID"] = 1066220,
    }, -- [205]
    {
        ["race"] = "",
        ["fileID"] = 1066221,
    }, -- [206]
    {
        ["race"] = "",
        ["fileID"] = 1066222,
    }, -- [207]
    {
        ["race"] = "",
        ["fileID"] = 1066223,
    }, -- [208]
    {
        ["race"] = "",
        ["fileID"] = 1066224,
    }, -- [209]
    {
        ["race"] = "",
        ["fileID"] = 1066225,
    }, -- [210]
    {
        ["race"] = "",
        ["fileID"] = 1066226,
    }, -- [211]
    {
        ["race"] = "",
        ["fileID"] = 1066227,
    }, -- [212]
    {
        ["race"] = "",
        ["fileID"] = 1066228,
    }, -- [213]
    {
        ["race"] = "",
        ["fileID"] = 1066229,
    }, -- [214]
    {
        ["race"] = "",
        ["fileID"] = 1066230,
    }, -- [215]
    {
        ["race"] = "",
        ["fileID"] = 1066231,
    }, -- [216]
    {
        ["race"] = "",
        ["fileID"] = 1066232,
    }, -- [217]
    {
        ["race"] = "",
        ["fileID"] = 1066233,
    }, -- [218]
    {
        ["race"] = "",
        ["fileID"] = 1066234,
    }, -- [219]
    {
        ["race"] = "",
        ["fileID"] = 1066235,
    }, -- [220]
    {
        ["race"] = "",
        ["fileID"] = 1066236,
    }, -- [221]
    {
        ["race"] = "",
        ["fileID"] = 1066237,
    }, -- [222]
    {
        ["race"] = "",
        ["fileID"] = 1066238,
    }, -- [223]
    {
        ["race"] = "",
        ["fileID"] = 1066239,
    }, -- [224]
    {
        ["race"] = "",
        ["fileID"] = 1066240,
    }, -- [225]
    {
        ["race"] = "",
        ["fileID"] = 1066241,
    }, -- [226]
    {
        ["race"] = "",
        ["fileID"] = 1066242,
    }, -- [227]
    {
        ["race"] = "",
        ["fileID"] = 1066243,
    }, -- [228]
    {
        ["race"] = "",
        ["fileID"] = 1066244,
    }, -- [229]
    {
        ["race"] = "",
        ["fileID"] = 1066245,
    }, -- [230]
    {
        ["race"] = "",
        ["fileID"] = 1066246,
    }, -- [231]
    {
        ["race"] = "",
        ["fileID"] = 1066247,
    }, -- [232]
    {
        ["race"] = "",
        ["fileID"] = 1066248,
    }, -- [233]
    {
        ["race"] = "",
        ["fileID"] = 1066249,
    }, -- [234]
    {
        ["race"] = "",
        ["fileID"] = 1066250,
    }, -- [235]
    {
        ["race"] = "",
        ["fileID"] = 1066251,
    }, -- [236]
    {
        ["race"] = "",
        ["fileID"] = 1066252,
    }, -- [237]
    {
        ["race"] = "",
        ["fileID"] = 1066253,
    }, -- [238]
    {
        ["race"] = "",
        ["fileID"] = 1066254,
    }, -- [239]
    {
        ["race"] = "",
        ["fileID"] = 1066255,
    }, -- [240]
    {
        ["race"] = "",
        ["fileID"] = 1066256,
    }, -- [241]
    {
        ["race"] = "",
        ["fileID"] = 1066257,
    }, -- [242]
    {
        ["race"] = "",
        ["fileID"] = 1066258,
    }, -- [243]
    {
        ["race"] = "",
        ["fileID"] = 1066259,
    }, -- [244]
    {
        ["race"] = "",
        ["fileID"] = 1066260,
    }, -- [245]
    {
        ["race"] = "",
        ["fileID"] = 1066261,
    }, -- [246]
    {
        ["race"] = "",
        ["fileID"] = 1066262,
    }, -- [247]
    {
        ["race"] = "",
        ["fileID"] = 1066263,
    }, -- [248]
    {
        ["race"] = "",
        ["fileID"] = 1066264,
    }, -- [249]
    {
        ["race"] = "",
        ["fileID"] = 1066266,
    }, -- [250]
    {
        ["race"] = "",
        ["fileID"] = 1066267,
    }, -- [251]
    {
        ["race"] = "",
        ["fileID"] = 1066268,
    }, -- [252]
    {
        ["race"] = "",
        ["fileID"] = 1066269,
    }, -- [253]
    {
        ["race"] = "",
        ["fileID"] = 1066270,
    }, -- [254]
    {
        ["race"] = "",
        ["fileID"] = 1066271,
    }, -- [255]
    {
        ["race"] = "",
        ["fileID"] = 1066272,
    }, -- [256]
    {
        ["race"] = "",
        ["fileID"] = 1066273,
    }, -- [257]
    {
        ["race"] = "",
        ["fileID"] = 1066274,
    }, -- [258]
    {
        ["race"] = "",
        ["fileID"] = 1066275,
    }, -- [259]
    {
        ["race"] = "",
        ["fileID"] = 1066276,
    }, -- [260]
    {
        ["race"] = "",
        ["fileID"] = 1066277,
    }, -- [261]
    {
        ["race"] = "",
        ["fileID"] = 1066278,
    }, -- [262]
    {
        ["race"] = "",
        ["fileID"] = 1066279,
    }, -- [263]
    {
        ["race"] = "",
        ["fileID"] = 1066280,
    }, -- [264]
    {
        ["race"] = "",
        ["fileID"] = 1066281,
    }, -- [265]
    {
        ["race"] = "",
        ["fileID"] = 1066282,
    }, -- [266]
    {
        ["race"] = "",
        ["fileID"] = 1066283,
    }, -- [267]
    {
        ["race"] = "",
        ["fileID"] = 1066284,
    }, -- [268]
    {
        ["race"] = "",
        ["fileID"] = 1066285,
    }, -- [269]
    {
        ["race"] = "",
        ["fileID"] = 1066286,
    }, -- [270]
    {
        ["race"] = "",
        ["fileID"] = 1066287,
    }, -- [271]
    {
        ["race"] = "",
        ["fileID"] = 1066288,
    }, -- [272]
    {
        ["race"] = "",
        ["fileID"] = 1066289,
    }, -- [273]
    {
        ["race"] = "",
        ["fileID"] = 1066290,
    }, -- [274]
    {
        ["race"] = "",
        ["fileID"] = 1066291,
    }, -- [275]
    {
        ["race"] = "",
        ["fileID"] = 1066292,
    }, -- [276]
    {
        ["race"] = "",
        ["fileID"] = 1066293,
    }, -- [277]
    {
        ["race"] = "",
        ["fileID"] = 1066294,
    }, -- [278]
    {
        ["race"] = "",
        ["fileID"] = 1066295,
    }, -- [279]
    {
        ["race"] = "",
        ["fileID"] = 1066296,
    }, -- [280]
    {
        ["race"] = "",
        ["fileID"] = 1066298,
    }, -- [281]
    {
        ["race"] = "",
        ["fileID"] = 1066299,
    }, -- [282]
    {
        ["race"] = "",
        ["fileID"] = 1066300,
    }, -- [283]
    {
        ["race"] = "",
        ["fileID"] = 1066301,
    }, -- [284]
    {
        ["race"] = "",
        ["fileID"] = 1066302,
    }, -- [285]
    {
        ["race"] = "",
        ["fileID"] = 1066303,
    }, -- [286]
    {
        ["race"] = "",
        ["fileID"] = 1066304,
    }, -- [287]
    {
        ["race"] = "",
        ["fileID"] = 1066305,
    }, -- [288]
    {
        ["race"] = "",
        ["fileID"] = 1066306,
    }, -- [289]
    {
        ["race"] = "",
        ["fileID"] = 1066307,
    }, -- [290]
    {
        ["race"] = "",
        ["fileID"] = 1066308,
    }, -- [291]
    {
        ["race"] = "",
        ["fileID"] = 1066309,
    }, -- [292]
    {
        ["race"] = "",
        ["fileID"] = 1066310,
    }, -- [293]
    {
        ["race"] = "",
        ["fileID"] = 1066311,
    }, -- [294]
    {
        ["race"] = "",
        ["fileID"] = 1066312,
    }, -- [295]
    {
        ["race"] = "",
        ["fileID"] = 1066313,
    }, -- [296]
    {
        ["race"] = "",
        ["fileID"] = 1066314,
    }, -- [297]
    {
        ["race"] = "",
        ["fileID"] = 1066315,
    }, -- [298]
    {
        ["race"] = "",
        ["fileID"] = 1066316,
    }, -- [299]
    {
        ["race"] = "",
        ["fileID"] = 1066317,
    }, -- [300]
    {
        ["race"] = "",
        ["fileID"] = 1066318,
    }, -- [301]
    {
        ["race"] = "",
        ["fileID"] = 1066319,
    }, -- [302]
    {
        ["race"] = "",
        ["fileID"] = 1066320,
    }, -- [303]
    {
        ["race"] = "",
        ["fileID"] = 1066321,
    }, -- [304]
    {
        ["race"] = "",
        ["fileID"] = 1066322,
    }, -- [305]
    {
        ["race"] = "",
        ["fileID"] = 1066323,
    }, -- [306]
    {
        ["race"] = "",
        ["fileID"] = 1066324,
    }, -- [307]
    {
        ["race"] = "",
        ["fileID"] = 1066325,
    }, -- [308]
    {
        ["race"] = "",
        ["fileID"] = 1066326,
    }, -- [309]
    {
        ["race"] = "",
        ["fileID"] = 1066327,
    }, -- [310]
    {
        ["race"] = "",
        ["fileID"] = 1066328,
    }, -- [311]
    {
        ["race"] = "",
        ["fileID"] = 1066329,
    }, -- [312]
    {
        ["race"] = "",
        ["fileID"] = 1066330,
    }, -- [313]
    {
        ["race"] = "",
        ["fileID"] = 1066331,
    }, -- [314]
    {
        ["race"] = "",
        ["fileID"] = 1066332,
    }, -- [315]
    {
        ["race"] = "",
        ["fileID"] = 1066333,
    }, -- [316]
    {
        ["race"] = "",
        ["fileID"] = 1066334,
    }, -- [317]
    {
        ["race"] = "",
        ["fileID"] = 1066335,
    }, -- [318]
    {
        ["race"] = "",
        ["fileID"] = 1066336,
    }, -- [319]
    {
        ["race"] = "",
        ["fileID"] = 1066337,
    }, -- [320]
    {
        ["race"] = "",
        ["fileID"] = 1066339,
    }, -- [321]
    {
        ["race"] = "",
        ["fileID"] = 1066340,
    }, -- [322]
    {
        ["race"] = "",
        ["fileID"] = 1066341,
    }, -- [323]
    {
        ["race"] = "",
        ["fileID"] = 1066342,
    }, -- [324]
    {
        ["race"] = "",
        ["fileID"] = 1066343,
    }, -- [325]
    {
        ["race"] = "",
        ["fileID"] = 1066344,
    }, -- [326]
    {
        ["race"] = "",
        ["fileID"] = 1066345,
    }, -- [327]
    {
        ["race"] = "",
        ["fileID"] = 1066346,
    }, -- [328]
    {
        ["race"] = "",
        ["fileID"] = 1066347,
    }, -- [329]
    {
        ["race"] = "",
        ["fileID"] = 1066348,
    }, -- [330]
    {
        ["race"] = "",
        ["fileID"] = 1066349,
    }, -- [331]
    {
        ["race"] = "",
        ["fileID"] = 1066350,
    }, -- [332]
    {
        ["race"] = "",
        ["fileID"] = 1066351,
    }, -- [333]
    {
        ["race"] = "",
        ["fileID"] = 1066352,
    }, -- [334]
    {
        ["race"] = "",
        ["fileID"] = 1066353,
    }, -- [335]
    {
        ["race"] = "",
        ["fileID"] = 1066354,
    }, -- [336]
    {
        ["race"] = "",
        ["fileID"] = 1066355,
    }, -- [337]
    {
        ["race"] = "",
        ["fileID"] = 1066356,
    }, -- [338]
    {
        ["race"] = "",
        ["fileID"] = 1066357,
    }, -- [339]
    {
        ["race"] = "",
        ["fileID"] = 1066358,
    }, -- [340]
    {
        ["race"] = "",
        ["fileID"] = 1066359,
    }, -- [341]
    {
        ["race"] = "",
        ["fileID"] = 1066360,
    }, -- [342]
    {
        ["race"] = "",
        ["fileID"] = 1066361,
    }, -- [343]
    {
        ["race"] = "",
        ["fileID"] = 1066362,
    }, -- [344]
    {
        ["race"] = "",
        ["fileID"] = 1066363,
    }, -- [345]
    {
        ["race"] = "",
        ["fileID"] = 1066364,
    }, -- [346]
    {
        ["race"] = "",
        ["fileID"] = 1066366,
    }, -- [347]
    {
        ["race"] = "",
        ["fileID"] = 1066367,
    }, -- [348]
    {
        ["race"] = "",
        ["fileID"] = 1066368,
    }, -- [349]
    {
        ["race"] = "",
        ["fileID"] = 1066369,
    }, -- [350]
    {
        ["race"] = "",
        ["fileID"] = 1066370,
    }, -- [351]
    {
        ["race"] = "",
        ["fileID"] = 1066371,
    }, -- [352]
    {
        ["race"] = "",
        ["fileID"] = 1066372,
    }, -- [353]
    {
        ["race"] = "",
        ["fileID"] = 1066373,
    }, -- [354]
    {
        ["race"] = "",
        ["fileID"] = 1066374,
    }, -- [355]
    {
        ["race"] = "",
        ["fileID"] = 1066375,
    }, -- [356]
    {
        ["race"] = "",
        ["fileID"] = 1066376,
    }, -- [357]
    {
        ["race"] = "",
        ["fileID"] = 1066377,
    }, -- [358]
    {
        ["race"] = "",
        ["fileID"] = 1066378,
    }, -- [359]
    {
        ["race"] = "",
        ["fileID"] = 1066379,
    }, -- [360]
    {
        ["race"] = "",
        ["fileID"] = 1066380,
    }, -- [361]
    {
        ["race"] = "",
        ["fileID"] = 1066381,
    }, -- [362]
    {
        ["race"] = "",
        ["fileID"] = 1066382,
    }, -- [363]
    {
        ["race"] = "",
        ["fileID"] = 1066383,
    }, -- [364]
    {
        ["race"] = "",
        ["fileID"] = 1066384,
    }, -- [365]
    {
        ["race"] = "",
        ["fileID"] = 1066385,
    }, -- [366]
    {
        ["race"] = "",
        ["fileID"] = 1066386,
    }, -- [367]
    {
        ["race"] = "",
        ["fileID"] = 1066387,
    }, -- [368]
    {
        ["race"] = "",
        ["fileID"] = 1066388,
    }, -- [369]
    {
        ["race"] = "",
        ["fileID"] = 1066389,
    }, -- [370]
    {
        ["race"] = "",
        ["fileID"] = 1066390,
    }, -- [371]
    {
        ["race"] = "",
        ["fileID"] = 1066391,
    }, -- [372]
    {
        ["race"] = "",
        ["fileID"] = 1066392,
    }, -- [373]
    {
        ["race"] = "",
        ["fileID"] = 1066393,
    }, -- [374]
    {
        ["race"] = "",
        ["fileID"] = 1066394,
    }, -- [375]
    {
        ["race"] = "",
        ["fileID"] = 1066395,
    }, -- [376]
    {
        ["race"] = "",
        ["fileID"] = 1066396,
    }, -- [377]
    {
        ["race"] = "",
        ["fileID"] = 1066397,
    }, -- [378]
    {
        ["race"] = "",
        ["fileID"] = 1066398,
    }, -- [379]
    {
        ["race"] = "",
        ["fileID"] = 1066399,
    }, -- [380]
    {
        ["race"] = "",
        ["fileID"] = 1066400,
    }, -- [381]
    {
        ["race"] = "",
        ["fileID"] = 1066401,
    }, -- [382]
    {
        ["race"] = "",
        ["fileID"] = 1066402,
    }, -- [383]
    {
        ["race"] = "",
        ["fileID"] = 1066403,
    }, -- [384]
    {
        ["race"] = "",
        ["fileID"] = 1066404,
    }, -- [385]
    {
        ["race"] = "",
        ["fileID"] = 1066405,
    }, -- [386]
    {
        ["race"] = "",
        ["fileID"] = 1066406,
    }, -- [387]
    {
        ["race"] = "",
        ["fileID"] = 1066407,
    }, -- [388]
    {
        ["race"] = "",
        ["fileID"] = 1066408,
    }, -- [389]
    {
        ["race"] = "",
        ["fileID"] = 1066409,
    }, -- [390]
    {
        ["race"] = "",
        ["fileID"] = 1066410,
    }, -- [391]
    {
        ["race"] = "",
        ["fileID"] = 1066411,
    }, -- [392]
    {
        ["race"] = "",
        ["fileID"] = 1066412,
    }, -- [393]
    {
        ["race"] = "",
        ["fileID"] = 1066413,
    }, -- [394]
    {
        ["race"] = "",
        ["fileID"] = 1066414,
    }, -- [395]
    {
        ["race"] = "",
        ["fileID"] = 1066415,
    }, -- [396]
    {
        ["race"] = "",
        ["fileID"] = 1066416,
    }, -- [397]
    {
        ["race"] = "",
        ["fileID"] = 1066417,
    }, -- [398]
    {
        ["race"] = "",
        ["fileID"] = 1066418,
    }, -- [399]
    {
        ["race"] = "",
        ["fileID"] = 1066419,
    }, -- [400]
    {
        ["race"] = "",
        ["fileID"] = 1066420,
    }, -- [401]
    {
        ["race"] = "",
        ["fileID"] = 1066421,
    }, -- [402]
    {
        ["race"] = "",
        ["fileID"] = 1066422,
    }, -- [403]
    {
        ["race"] = "",
        ["fileID"] = 1066424,
    }, -- [404]
    {
        ["race"] = "",
        ["fileID"] = 1066425,
    }, -- [405]
    {
        ["race"] = "",
        ["fileID"] = 1066426,
    }, -- [406]
    {
        ["race"] = "",
        ["fileID"] = 1066427,
    }, -- [407]
    {
        ["race"] = "",
        ["fileID"] = 1066428,
    }, -- [408]
    {
        ["race"] = "",
        ["fileID"] = 1066429,
    }, -- [409]
    {
        ["race"] = "",
        ["fileID"] = 1066430,
    }, -- [410]
    {
        ["race"] = "",
        ["fileID"] = 1066431,
    }, -- [411]
    {
        ["race"] = "",
        ["fileID"] = 1066432,
    }, -- [412]
    {
        ["race"] = "",
        ["fileID"] = 1066433,
    }, -- [413]
    {
        ["race"] = "",
        ["fileID"] = 1066434,
    }, -- [414]
    {
        ["race"] = "",
        ["fileID"] = 1066435,
    }, -- [415]
    {
        ["race"] = "",
        ["fileID"] = 1066436,
    }, -- [416]
    {
        ["race"] = "",
        ["fileID"] = 1066437,
    }, -- [417]
    {
        ["race"] = "",
        ["fileID"] = 1066438,
    }, -- [418]
    {
        ["race"] = "",
        ["fileID"] = 1066439,
    }, -- [419]
    {
        ["race"] = "",
        ["fileID"] = 1066440,
    }, -- [420]
    {
        ["race"] = "",
        ["fileID"] = 1066441,
    }, -- [421]
    {
        ["race"] = "",
        ["fileID"] = 1066442,
    }, -- [422]
    {
        ["race"] = "",
        ["fileID"] = 1066443,
    }, -- [423]
    {
        ["race"] = "",
        ["fileID"] = 1066444,
    }, -- [424]
    {
        ["race"] = "",
        ["fileID"] = 1066445,
    }, -- [425]
    {
        ["race"] = "",
        ["fileID"] = 1066446,
    }, -- [426]
    {
        ["race"] = "",
        ["fileID"] = 1066447,
    }, -- [427]
    {
        ["race"] = "",
        ["fileID"] = 1066448,
    }, -- [428]
    {
        ["race"] = "",
        ["fileID"] = 1066449,
    }, -- [429]
    {
        ["race"] = "",
        ["fileID"] = 1066450,
    }, -- [430]
    {
        ["race"] = "",
        ["fileID"] = 1066451,
    }, -- [431]
    {
        ["race"] = "",
        ["fileID"] = 1066452,
    }, -- [432]
    {
        ["race"] = "",
        ["fileID"] = 1066453,
    }, -- [433]
    {
        ["race"] = "",
        ["fileID"] = 1066454,
    }, -- [434]
    {
        ["race"] = "",
        ["fileID"] = 1066455,
    }, -- [435]
    {
        ["race"] = "",
        ["fileID"] = 1066456,
    }, -- [436]
    {
        ["race"] = "",
        ["fileID"] = 1066457,
    }, -- [437]
    {
        ["race"] = "",
        ["fileID"] = 1066458,
    }, -- [438]
    {
        ["race"] = "",
        ["fileID"] = 1066459,
    }, -- [439]
    {
        ["race"] = "",
        ["fileID"] = 1066460,
    }, -- [440]
    {
        ["race"] = "",
        ["fileID"] = 1066461,
    }, -- [441]
    {
        ["race"] = "",
        ["fileID"] = 1066462,
    }, -- [442]
    {
        ["race"] = "",
        ["fileID"] = 1066463,
    }, -- [443]
    {
        ["race"] = "",
        ["fileID"] = 1066464,
    }, -- [444]
    {
        ["race"] = "",
        ["fileID"] = 1066465,
    }, -- [445]
    {
        ["race"] = "",
        ["fileID"] = 1066466,
    }, -- [446]
    {
        ["race"] = "",
        ["fileID"] = 1066467,
    }, -- [447]
    {
        ["race"] = "",
        ["fileID"] = 1066468,
    }, -- [448]
    {
        ["race"] = "",
        ["fileID"] = 1066469,
    }, -- [449]
    {
        ["race"] = "",
        ["fileID"] = 1066470,
    }, -- [450]
    {
        ["race"] = "",
        ["fileID"] = 1066471,
    }, -- [451]
    {
        ["race"] = "",
        ["fileID"] = 1066472,
    }, -- [452]
    {
        ["race"] = "",
        ["fileID"] = 1066473,
    }, -- [453]
    {
        ["race"] = "",
        ["fileID"] = 1066474,
    }, -- [454]
    {
        ["race"] = "",
        ["fileID"] = 1066475,
    }, -- [455]
    {
        ["race"] = "",
        ["fileID"] = 1066476,
    }, -- [456]
    {
        ["race"] = "",
        ["fileID"] = 1066477,
    }, -- [457]
    {
        ["race"] = "",
        ["fileID"] = 1066478,
    }, -- [458]
    {
        ["race"] = "",
        ["fileID"] = 1066479,
    }, -- [459]
    {
        ["race"] = "",
        ["fileID"] = 1066480,
    }, -- [460]
    {
        ["race"] = "",
        ["fileID"] = 1066481,
    }, -- [461]
    {
        ["race"] = "",
        ["fileID"] = 1066482,
    }, -- [462]
    {
        ["race"] = "",
        ["fileID"] = 1066483,
    }, -- [463]
    {
        ["race"] = "",
        ["fileID"] = 1066484,
    }, -- [464]
    {
        ["race"] = "",
        ["fileID"] = 1066485,
    }, -- [465]
    {
        ["race"] = "",
        ["fileID"] = 1066486,
    }, -- [466]
    {
        ["race"] = "",
        ["fileID"] = 1066487,
    }, -- [467]
    {
        ["race"] = "",
        ["fileID"] = 1066488,
    }, -- [468]
    {
        ["race"] = "",
        ["fileID"] = 1066489,
    }, -- [469]
    {
        ["race"] = "",
        ["fileID"] = 1066490,
    }, -- [470]
    {
        ["race"] = "",
        ["fileID"] = 1066491,
    }, -- [471]
    {
        ["race"] = "",
        ["fileID"] = 1066492,
    }, -- [472]
    {
        ["race"] = "",
        ["fileID"] = 1066493,
    }, -- [473]
    {
        ["race"] = "",
        ["fileID"] = 1066494,
    }, -- [474]
    {
        ["race"] = "",
        ["fileID"] = 1066495,
    }, -- [475]
    {
        ["race"] = "",
        ["fileID"] = 1066496,
    }, -- [476]
    {
        ["race"] = "",
        ["fileID"] = 1066497,
    }, -- [477]
    {
        ["race"] = "",
        ["fileID"] = 1066498,
    }, -- [478]
    {
        ["race"] = "",
        ["fileID"] = 1066499,
    }, -- [479]
    {
        ["race"] = "",
        ["fileID"] = 1066500,
    }, -- [480]
    {
        ["race"] = "",
        ["fileID"] = 1066501,
    }, -- [481]
    {
        ["race"] = "",
        ["fileID"] = 1066502,
    }, -- [482]
    {
        ["race"] = "",
        ["fileID"] = 1066503,
    }, -- [483]
    {
        ["race"] = "",
        ["fileID"] = 1066504,
    }, -- [484]
    {
        ["race"] = "",
        ["fileID"] = 1066505,
    }, -- [485]
    {
        ["race"] = "",
        ["fileID"] = 1066506,
    }, -- [486]
    {
        ["race"] = "",
        ["fileID"] = 1066507,
    }, -- [487]
    {
        ["race"] = "",
        ["fileID"] = 1066508,
    }, -- [488]
    {
        ["race"] = "",
        ["fileID"] = 1066509,
    }, -- [489]
    {
        ["race"] = "",
        ["fileID"] = 1066510,
    }, -- [490]
    {
        ["race"] = "",
        ["fileID"] = 1066511,
    }, -- [491]
    {
        ["race"] = "",
        ["fileID"] = 1066512,
    }, -- [492]
    {
        ["race"] = "",
        ["fileID"] = 1066513,
    }, -- [493]
    {
        ["race"] = "",
        ["fileID"] = 1066514,
    }, -- [494]
    {
        ["race"] = "",
        ["fileID"] = 1066515,
    }, -- [495]
    {
        ["race"] = "",
        ["fileID"] = 1066516,
    }, -- [496]
    {
        ["race"] = "",
        ["fileID"] = 1066517,
    }, -- [497]
    {
        ["race"] = "",
        ["fileID"] = 1066518,
    }, -- [498]
    {
        ["race"] = "",
        ["fileID"] = 1066519,
    }, -- [499]
    {
        ["race"] = "",
        ["fileID"] = 1066520,
    }, -- [500]
    {
        ["race"] = "",
        ["fileID"] = 1066521,
    }, -- [501]
    {
        ["race"] = "",
        ["fileID"] = 1066522,
    }, -- [502]
    {
        ["race"] = "",
        ["fileID"] = 1066523,
    }, -- [503]
    {
        ["race"] = "",
        ["fileID"] = 1066524,
    }, -- [504]
    {
        ["race"] = "",
        ["fileID"] = 1066525,
    }, -- [505]
    {
        ["race"] = "",
        ["fileID"] = 1066526,
    }, -- [506]
    {
        ["race"] = "",
        ["fileID"] = 1066527,
    }, -- [507]
    {
        ["race"] = "",
        ["fileID"] = 1066528,
    }, -- [508]
    {
        ["race"] = "",
        ["fileID"] = 1066529,
    }, -- [509]
    {
        ["race"] = "",
        ["fileID"] = 1066530,
    }, -- [510]
    {
        ["race"] = "",
        ["fileID"] = 1066531,
    }, -- [511]
    {
        ["race"] = "",
        ["fileID"] = 1066532,
    }, -- [512]
    {
        ["race"] = "",
        ["fileID"] = 1066533,
    }, -- [513]
    {
        ["race"] = "",
        ["fileID"] = 1067178,
    }, -- [514]
    {
        ["race"] = "",
        ["fileID"] = 1067179,
    }, -- [515]
    {
        ["race"] = "",
        ["fileID"] = 1067180,
    }, -- [516]
    {
        ["race"] = "",
        ["fileID"] = 1067181,
    }, -- [517]
    {
        ["race"] = "",
        ["fileID"] = 1067182,
    }, -- [518]
    {
        ["race"] = "",
        ["fileID"] = 1067183,
    }, -- [519]
    {
        ["race"] = "",
        ["fileID"] = 1067184,
    }, -- [520]
    {
        ["race"] = "",
        ["fileID"] = 1067185,
    }, -- [521]
    {
        ["race"] = "",
        ["fileID"] = 1067186,
    }, -- [522]
    {
        ["race"] = "",
        ["fileID"] = 1067187,
    }, -- [523]
    {
        ["race"] = "",
        ["fileID"] = 1067188,
    }, -- [524]
    {
        ["race"] = "",
        ["fileID"] = 1067189,
    }, -- [525]
    {
        ["race"] = "",
        ["fileID"] = 1067190,
    }, -- [526]
    {
        ["race"] = "",
        ["fileID"] = 1067191,
    }, -- [527]
    {
        ["race"] = "",
        ["fileID"] = 1067192,
    }, -- [528]
    {
        ["race"] = "",
        ["fileID"] = 1067193,
    }, -- [529]
    {
        ["race"] = "",
        ["fileID"] = 1067194,
    }, -- [530]
    {
        ["race"] = "",
        ["fileID"] = 1067195,
    }, -- [531]
    {
        ["race"] = "",
        ["fileID"] = 1067196,
    }, -- [532]
    {
        ["race"] = "",
        ["fileID"] = 1067197,
    }, -- [533]
    {
        ["race"] = "",
        ["fileID"] = 1067198,
    }, -- [534]
    {
        ["race"] = "",
        ["fileID"] = 1067199,
    }, -- [535]
    {
        ["race"] = "",
        ["fileID"] = 1067200,
    }, -- [536]
    {
        ["race"] = "",
        ["fileID"] = 1067201,
    }, -- [537]
    {
        ["race"] = "",
        ["fileID"] = 1067202,
    }, -- [538]
    {
        ["race"] = "",
        ["fileID"] = 1067203,
    }, -- [539]
    {
        ["race"] = "",
        ["fileID"] = 1067204,
    }, -- [540]
    {
        ["race"] = "",
        ["fileID"] = 1067205,
    }, -- [541]
    {
        ["race"] = "",
        ["fileID"] = 1067206,
    }, -- [542]
    {
        ["race"] = "",
        ["fileID"] = 1067207,
    }, -- [543]
    {
        ["race"] = "",
        ["fileID"] = 1067208,
    }, -- [544]
    {
        ["race"] = "",
        ["fileID"] = 1067209,
    }, -- [545]
    {
        ["race"] = "",
        ["fileID"] = 1067210,
    }, -- [546]
    {
        ["race"] = "",
        ["fileID"] = 1067211,
    }, -- [547]
    {
        ["race"] = "",
        ["fileID"] = 1067212,
    }, -- [548]
    {
        ["race"] = "",
        ["fileID"] = 1067213,
    }, -- [549]
    {
        ["race"] = "",
        ["fileID"] = 1067214,
    }, -- [550]
    {
        ["race"] = "",
        ["fileID"] = 1067215,
    }, -- [551]
    {
        ["race"] = "",
        ["fileID"] = 1067216,
    }, -- [552]
    {
        ["race"] = "",
        ["fileID"] = 1067217,
    }, -- [553]
    {
        ["race"] = "",
        ["fileID"] = 1067218,
    }, -- [554]
    {
        ["race"] = "",
        ["fileID"] = 1067219,
    }, -- [555]
    {
        ["race"] = "",
        ["fileID"] = 1067220,
    }, -- [556]
    {
        ["race"] = "",
        ["fileID"] = 1067221,
    }, -- [557]
    {
        ["race"] = "",
        ["fileID"] = 1067222,
    }, -- [558]
    {
        ["race"] = "",
        ["fileID"] = 1067223,
    }, -- [559]
    {
        ["race"] = "",
        ["fileID"] = 1067224,
    }, -- [560]
    {
        ["race"] = "",
        ["fileID"] = 1067225,
    }, -- [561]
    {
        ["race"] = "",
        ["fileID"] = 1067226,
    }, -- [562]
    {
        ["race"] = "",
        ["fileID"] = 1067227,
    }, -- [563]
    {
        ["race"] = "",
        ["fileID"] = 1067228,
    }, -- [564]
    {
        ["race"] = "",
        ["fileID"] = 1067229,
    }, -- [565]
    {
        ["race"] = "",
        ["fileID"] = 1067230,
    }, -- [566]
    {
        ["race"] = "",
        ["fileID"] = 1067231,
    }, -- [567]
    {
        ["race"] = "",
        ["fileID"] = 1067232,
    }, -- [568]
    {
        ["race"] = "",
        ["fileID"] = 1067233,
    }, -- [569]
    {
        ["race"] = "",
        ["fileID"] = 1067234,
    }, -- [570]
    {
        ["race"] = "",
        ["fileID"] = 1067235,
    }, -- [571]
    {
        ["race"] = "",
        ["fileID"] = 1067236,
    }, -- [572]
    {
        ["race"] = "",
        ["fileID"] = 1067237,
    }, -- [573]
    {
        ["race"] = "",
        ["fileID"] = 1067238,
    }, -- [574]
    {
        ["race"] = "",
        ["fileID"] = 1067239,
    }, -- [575]
    {
        ["race"] = "",
        ["fileID"] = 1067240,
    }, -- [576]
    {
        ["race"] = "",
        ["fileID"] = 1067241,
    }, -- [577]
    {
        ["race"] = "",
        ["fileID"] = 1067242,
    }, -- [578]
    {
        ["race"] = "",
        ["fileID"] = 1067243,
    }, -- [579]
    {
        ["race"] = "",
        ["fileID"] = 1067244,
    }, -- [580]
    {
        ["race"] = "",
        ["fileID"] = 1067245,
    }, -- [581]
    {
        ["race"] = "",
        ["fileID"] = 1067246,
    }, -- [582]
    {
        ["race"] = "",
        ["fileID"] = 1067247,
    }, -- [583]
    {
        ["race"] = "",
        ["fileID"] = 1067248,
    }, -- [584]
    {
        ["race"] = "",
        ["fileID"] = 1067249,
    }, -- [585]
    {
        ["race"] = "",
        ["fileID"] = 1067250,
    }, -- [586]
    {
        ["race"] = "",
        ["fileID"] = 1067251,
    }, -- [587]
    {
        ["race"] = "",
        ["fileID"] = 1067252,
    }, -- [588]
    {
        ["race"] = "",
        ["fileID"] = 1067253,
    }, -- [589]
    {
        ["race"] = "",
        ["fileID"] = 1067254,
    }, -- [590]
    {
        ["race"] = "",
        ["fileID"] = 1067255,
    }, -- [591]
    {
        ["race"] = "",
        ["fileID"] = 1067256,
    }, -- [592]
    {
        ["race"] = "",
        ["fileID"] = 1067257,
    }, -- [593]
    {
        ["race"] = "",
        ["fileID"] = 1067258,
    }, -- [594]
    {
        ["race"] = "",
        ["fileID"] = 1067259,
    }, -- [595]
    {
        ["race"] = "",
        ["fileID"] = 1067260,
    }, -- [596]
    {
        ["race"] = "",
        ["fileID"] = 1067261,
    }, -- [597]
    {
        ["race"] = "",
        ["fileID"] = 1067262,
    }, -- [598]
    {
        ["race"] = "",
        ["fileID"] = 1067263,
    }, -- [599]
    {
        ["race"] = "",
        ["fileID"] = 1067264,
    }, -- [600]
    {
        ["race"] = "",
        ["fileID"] = 1067265,
    }, -- [601]
    {
        ["race"] = "",
        ["fileID"] = 1067266,
    }, -- [602]
    {
        ["race"] = "",
        ["fileID"] = 1067267,
    }, -- [603]
    {
        ["race"] = "",
        ["fileID"] = 1067268,
    }, -- [604]
    {
        ["race"] = "",
        ["fileID"] = 1067269,
    }, -- [605]
    {
        ["race"] = "",
        ["fileID"] = 1067270,
    }, -- [606]
    {
        ["race"] = "",
        ["fileID"] = 1067271,
    }, -- [607]
    {
        ["race"] = "",
        ["fileID"] = 1067272,
    }, -- [608]
    {
        ["race"] = "",
        ["fileID"] = 1067273,
    }, -- [609]
    {
        ["race"] = "",
        ["fileID"] = 1067274,
    }, -- [610]
    {
        ["race"] = "",
        ["fileID"] = 1067275,
    }, -- [611]
    {
        ["race"] = "",
        ["fileID"] = 1067276,
    }, -- [612]
    {
        ["race"] = "",
        ["fileID"] = 1067277,
    }, -- [613]
    {
        ["race"] = "",
        ["fileID"] = 1067278,
    }, -- [614]
    {
        ["race"] = "",
        ["fileID"] = 1067279,
    }, -- [615]
    {
        ["race"] = "",
        ["fileID"] = 1067280,
    }, -- [616]
    {
        ["race"] = "",
        ["fileID"] = 1067281,
    }, -- [617]
    {
        ["race"] = "",
        ["fileID"] = 1067282,
    }, -- [618]
    {
        ["race"] = "",
        ["fileID"] = 1067283,
    }, -- [619]
    {
        ["race"] = "",
        ["fileID"] = 1067284,
    }, -- [620]
    {
        ["race"] = "",
        ["fileID"] = 1067285,
    }, -- [621]
    {
        ["race"] = "",
        ["fileID"] = 1067286,
    }, -- [622]
    {
        ["race"] = "",
        ["fileID"] = 1067287,
    }, -- [623]
    {
        ["race"] = "",
        ["fileID"] = 1067288,
    }, -- [624]
    {
        ["race"] = "",
        ["fileID"] = 1067289,
    }, -- [625]
    {
        ["race"] = "",
        ["fileID"] = 1067290,
    }, -- [626]
    {
        ["race"] = "",
        ["fileID"] = 1067291,
    }, -- [627]
    {
        ["race"] = "",
        ["fileID"] = 1067292,
    }, -- [628]
    {
        ["race"] = "",
        ["fileID"] = 1067293,
    }, -- [629]
    {
        ["race"] = "",
        ["fileID"] = 1067294,
    }, -- [630]
    {
        ["race"] = "",
        ["fileID"] = 1067295,
    }, -- [631]
    {
        ["race"] = "",
        ["fileID"] = 1067296,
    }, -- [632]
    {
        ["race"] = "",
        ["fileID"] = 1067297,
    }, -- [633]
    {
        ["race"] = "",
        ["fileID"] = 1067298,
    }, -- [634]
    {
        ["race"] = "",
        ["fileID"] = 1067299,
    }, -- [635]
    {
        ["race"] = "",
        ["fileID"] = 1067300,
    }, -- [636]
    {
        ["race"] = "",
        ["fileID"] = 1067301,
    }, -- [637]
    {
        ["race"] = "",
        ["fileID"] = 1067302,
    }, -- [638]
    {
        ["race"] = "",
        ["fileID"] = 1067303,
    }, -- [639]
    {
        ["race"] = "",
        ["fileID"] = 1067304,
    }, -- [640]
    {
        ["race"] = "",
        ["fileID"] = 1067305,
    }, -- [641]
    {
        ["race"] = "",
        ["fileID"] = 1067306,
    }, -- [642]
    {
        ["race"] = "",
        ["fileID"] = 1067307,
    }, -- [643]
    {
        ["race"] = "",
        ["fileID"] = 1067308,
    }, -- [644]
    {
        ["race"] = "",
        ["fileID"] = 1067309,
    }, -- [645]
    {
        ["race"] = "",
        ["fileID"] = 1067310,
    }, -- [646]
    {
        ["race"] = "",
        ["fileID"] = 1067311,
    }, -- [647]
    {
        ["race"] = "",
        ["fileID"] = 1067312,
    }, -- [648]
    {
        ["race"] = "",
        ["fileID"] = 1067313,
    }, -- [649]
    {
        ["race"] = "",
        ["fileID"] = 1067314,
    }, -- [650]
    {
        ["race"] = "",
        ["fileID"] = 1067315,
    }, -- [651]
    {
        ["race"] = "",
        ["fileID"] = 1067316,
    }, -- [652]
    {
        ["race"] = "",
        ["fileID"] = 1067317,
    }, -- [653]
    {
        ["race"] = "",
        ["fileID"] = 1067318,
    }, -- [654]
    {
        ["race"] = "",
        ["fileID"] = 1067319,
    }, -- [655]
    {
        ["race"] = "",
        ["fileID"] = 1067320,
    }, -- [656]
    {
        ["race"] = "",
        ["fileID"] = 1067321,
    }, -- [657]
    {
        ["race"] = "",
        ["fileID"] = 1067322,
    }, -- [658]
    {
        ["race"] = "",
        ["fileID"] = 1067323,
    }, -- [659]
    {
        ["race"] = "",
        ["fileID"] = 1067324,
    }, -- [660]
    {
        ["race"] = "",
        ["fileID"] = 1067325,
    }, -- [661]
    {
        ["race"] = "",
        ["fileID"] = 1067326,
    }, -- [662]
    {
        ["race"] = "",
        ["fileID"] = 1067327,
    }, -- [663]
    {
        ["race"] = "",
        ["fileID"] = 1067328,
    }, -- [664]
    {
        ["race"] = "",
        ["fileID"] = 1067329,
    }, -- [665]
    {
        ["race"] = "",
        ["fileID"] = 1067330,
    }, -- [666]
    {
        ["race"] = "",
        ["fileID"] = 1067331,
    }, -- [667]
    {
        ["race"] = "",
        ["fileID"] = 1067332,
    }, -- [668]
    {
        ["race"] = "",
        ["fileID"] = 1067335,
    }, -- [669]
    {
        ["race"] = "",
        ["fileID"] = 1067337,
    }, -- [670]
    {
        ["race"] = "",
        ["fileID"] = 1067338,
    }, -- [671]
    {
        ["race"] = "",
        ["fileID"] = 1067339,
    }, -- [672]
    {
        ["race"] = "",
        ["fileID"] = 1067343,
    }, -- [673]
    {
        ["race"] = "",
        ["fileID"] = 1067344,
    }, -- [674]
    {
        ["race"] = "",
        ["fileID"] = 1067345,
    }, -- [675]
    {
        ["race"] = "",
        ["fileID"] = 1067346,
    }, -- [676]
    {
        ["race"] = "",
        ["fileID"] = 1067347,
    }, -- [677]
    {
        ["race"] = "",
        ["fileID"] = 1067348,
    }, -- [678]
    {
        ["race"] = "",
        ["fileID"] = 1067349,
    }, -- [679]
    {
        ["race"] = "",
        ["fileID"] = 1067350,
    }, -- [680]
    {
        ["race"] = "",
        ["fileID"] = 1067351,
    }, -- [681]
    {
        ["race"] = "",
        ["fileID"] = 1067352,
    }, -- [682]
    {
        ["race"] = "",
        ["fileID"] = 1067353,
    }, -- [683]
    {
        ["race"] = "",
        ["fileID"] = 1067354,
    }, -- [684]
    {
        ["race"] = "",
        ["fileID"] = 1067355,
    }, -- [685]
    {
        ["race"] = "",
        ["fileID"] = 1067356,
    }, -- [686]
    {
        ["race"] = "",
        ["fileID"] = 1067357,
    }, -- [687]
    {
        ["race"] = "",
        ["fileID"] = 1067358,
    }, -- [688]
    {
        ["race"] = "",
        ["fileID"] = 1067359,
    }, -- [689]
    {
        ["race"] = "",
        ["fileID"] = 1067360,
    }, -- [690]
    {
        ["race"] = "",
        ["fileID"] = 1067361,
    }, -- [691]
    {
        ["race"] = "",
        ["fileID"] = 1067362,
    }, -- [692]
    {
        ["race"] = "",
        ["fileID"] = 1067363,
    }, -- [693]
    {
        ["race"] = "",
        ["fileID"] = 1067364,
    }, -- [694]
    {
        ["race"] = "",
        ["fileID"] = 1067365,
    }, -- [695]
    {
        ["race"] = "",
        ["fileID"] = 1067366,
    }, -- [696]
    {
        ["race"] = "",
        ["fileID"] = 1067367,
    }, -- [697]
    {
        ["race"] = "",
        ["fileID"] = 1067368,
    }, -- [698]
    {
        ["race"] = "",
        ["fileID"] = 1067369,
    }, -- [699]
    {
        ["race"] = "",
        ["fileID"] = 1067370,
    }, -- [700]
    {
        ["race"] = "",
        ["fileID"] = 1067371,
    }, -- [701]
    {
        ["race"] = "",
        ["fileID"] = 1067372,
    }, -- [702]
    {
        ["race"] = "",
        ["fileID"] = 1067373,
    }, -- [703]
    {
        ["race"] = "",
        ["fileID"] = 1067376,
    }, -- [704]
    {
        ["race"] = "",
        ["fileID"] = 1067378,
    }, -- [705]
    {
        ["race"] = "",
        ["fileID"] = 1067379,
    }, -- [706]
    {
        ["race"] = "",
        ["fileID"] = 1067380,
    }, -- [707]
    {
        ["race"] = "",
        ["fileID"] = 1067381,
    }, -- [708]
    {
        ["race"] = "",
        ["fileID"] = 1067382,
    }, -- [709]
    {
        ["race"] = "",
        ["fileID"] = 1067383,
    }, -- [710]
    {
        ["race"] = "",
        ["fileID"] = 1067384,
    }, -- [711]
    {
        ["race"] = "",
        ["fileID"] = 1067385,
    }, -- [712]
    {
        ["race"] = "",
        ["fileID"] = 1067386,
    }, -- [713]
    {
        ["race"] = "",
        ["fileID"] = 1067388,
    }, -- [714]
    {
        ["race"] = "",
        ["fileID"] = 1067389,
    }, -- [715]
    {
        ["race"] = "",
        ["fileID"] = 1067390,
    }, -- [716]
    {
        ["race"] = "",
        ["fileID"] = 1067391,
    }, -- [717]
    {
        ["race"] = "",
        ["fileID"] = 1067392,
    }, -- [718]
    {
        ["race"] = "",
        ["fileID"] = 1067394,
    }, -- [719]
    {
        ["race"] = "",
        ["fileID"] = 1067395,
    }, -- [720]
    {
        ["race"] = "",
        ["fileID"] = 1067396,
    }, -- [721]
    {
        ["race"] = "",
        ["fileID"] = 1067398,
    }, -- [722]
    {
        ["race"] = "",
        ["fileID"] = 1067399,
    }, -- [723]
    {
        ["race"] = "",
        ["fileID"] = 1067400,
    }, -- [724]
    {
        ["race"] = "",
        ["fileID"] = 1067401,
    }, -- [725]
    {
        ["race"] = "",
        ["fileID"] = 1067402,
    }, -- [726]
    {
        ["race"] = "",
        ["fileID"] = 1067403,
    }, -- [727]
    {
        ["race"] = "",
        ["fileID"] = 1067404,
    }, -- [728]
    {
        ["race"] = "",
        ["fileID"] = 1067405,
    }, -- [729]
    {
        ["race"] = "",
        ["fileID"] = 1067406,
    }, -- [730]
    {
        ["race"] = "",
        ["fileID"] = 1067407,
    }, -- [731]
    {
        ["race"] = "",
        ["fileID"] = 1067409,
    }, -- [732]
    {
        ["race"] = "",
        ["fileID"] = 1067410,
    }, -- [733]
    {
        ["race"] = "",
        ["fileID"] = 1067413,
    }, -- [734]
    {
        ["race"] = "",
        ["fileID"] = 1067414,
    }, -- [735]
    {
        ["race"] = "",
        ["fileID"] = 1067415,
    }, -- [736]
    {
        ["race"] = "",
        ["fileID"] = 1067418,
    }, -- [737]
    {
        ["race"] = "",
        ["fileID"] = 1067420,
    }, -- [738]
    {
        ["race"] = "",
        ["fileID"] = 1067421,
    }, -- [739]
    {
        ["race"] = "",
        ["fileID"] = 1067422,
    }, -- [740]
    {
        ["race"] = "",
        ["fileID"] = 1067424,
    }, -- [741]
    {
        ["race"] = "",
        ["fileID"] = 1067425,
    }, -- [742]
    {
        ["race"] = "",
        ["fileID"] = 1067426,
    }, -- [743]
    {
        ["race"] = "",
        ["fileID"] = 1067427,
    }, -- [744]
    {
        ["race"] = "",
        ["fileID"] = 1067428,
    }, -- [745]
    {
        ["race"] = "",
        ["fileID"] = 1067429,
    }, -- [746]
    {
        ["race"] = "",
        ["fileID"] = 1067430,
    }, -- [747]
    {
        ["race"] = "",
        ["fileID"] = 1067431,
    }, -- [748]
    {
        ["race"] = "",
        ["fileID"] = 1067432,
    }, -- [749]
    {
        ["race"] = "",
        ["fileID"] = 1067433,
    }, -- [750]
    {
        ["race"] = "",
        ["fileID"] = 1067434,
    }, -- [751]
    {
        ["race"] = "",
        ["fileID"] = 1067435,
    }, -- [752]
    {
        ["race"] = "",
        ["fileID"] = 1067436,
    }, -- [753]
    {
        ["race"] = "",
        ["fileID"] = 1067437,
    }, -- [754]
    {
        ["race"] = "",
        ["fileID"] = 1067438,
    }, -- [755]
    {
        ["race"] = "",
        ["fileID"] = 1067439,
    }, -- [756]
    {
        ["race"] = "",
        ["fileID"] = 1067440,
    }, -- [757]
    {
        ["race"] = "",
        ["fileID"] = 1067441,
    }, -- [758]
    {
        ["race"] = "",
        ["fileID"] = 1067442,
    }, -- [759]
    {
        ["race"] = "",
        ["fileID"] = 1067443,
    }, -- [760]
    {
        ["race"] = "",
        ["fileID"] = 1067445,
    }, -- [761]
    {
        ["race"] = "",
        ["fileID"] = 1067446,
    }, -- [762]
    {
        ["race"] = "",
        ["fileID"] = 1067447,
    }, -- [763]
    {
        ["race"] = "",
        ["fileID"] = 1067448,
    }, -- [764]
    {
        ["race"] = "",
        ["fileID"] = 1067449,
    }, -- [765]
    {
        ["race"] = "",
        ["fileID"] = 1067450,
    }, -- [766]
    {
        ["race"] = "",
        ["fileID"] = 1067451,
    }, -- [767]
    {
        ["race"] = "",
        ["fileID"] = 1067452,
    }, -- [768]
    {
        ["race"] = "",
        ["fileID"] = 1067453,
    }, -- [769]
    {
        ["race"] = "",
        ["fileID"] = 1067456,
    }, -- [770]
    {
        ["race"] = "",
        ["fileID"] = 1067457,
    }, -- [771]
    {
        ["race"] = "",
        ["fileID"] = 1067458,
    }, -- [772]
    {
        ["race"] = "",
        ["fileID"] = 1067460,
    }, -- [773]
    {
        ["race"] = "",
        ["fileID"] = 1067461,
    }, -- [774]
    {
        ["race"] = "",
        ["fileID"] = 1067462,
    }, -- [775]
    {
        ["race"] = "",
        ["fileID"] = 1067463,
    }, -- [776]
    {
        ["race"] = "",
        ["fileID"] = 1067464,
    }, -- [777]
    {
        ["race"] = "",
        ["fileID"] = 1067465,
    }, -- [778]
    {
        ["race"] = "",
        ["fileID"] = 1067466,
    }, -- [779]
    {
        ["race"] = "",
        ["fileID"] = 1067467,
    }, -- [780]
    {
        ["race"] = "",
        ["fileID"] = 1067468,
    }, -- [781]
    {
        ["race"] = "",
        ["fileID"] = 1067469,
    }, -- [782]
    {
        ["race"] = "",
        ["fileID"] = 1067470,
    }, -- [783]
    {
        ["race"] = "",
        ["fileID"] = 1067471,
    }, -- [784]
    {
        ["race"] = "",
        ["fileID"] = 1067472,
    }, -- [785]
    {
        ["race"] = "",
        ["fileID"] = 1067473,
    }, -- [786]
    {
        ["race"] = "",
        ["fileID"] = 1067474,
    }, -- [787]
    {
        ["race"] = "",
        ["fileID"] = 1067475,
    }, -- [788]
    {
        ["race"] = "",
        ["fileID"] = 1067476,
    }, -- [789]
    {
        ["race"] = "",
        ["fileID"] = 1396616,
    }, -- [790]
    {
        ["race"] = "",
        ["fileID"] = 1396617,
    }, -- [791]
    {
        ["race"] = "",
        ["fileID"] = 1396618,
    }, -- [792]
    {
        ["race"] = "",
        ["fileID"] = 1396619,
    }, -- [793]
    {
        ["race"] = "",
        ["fileID"] = 1396620,
    }, -- [794]
    {
        ["race"] = "",
        ["fileID"] = 1396621,
    }, -- [795]
    {
        ["race"] = "",
        ["fileID"] = 1396622,
    }, -- [796]
    {
        ["race"] = "",
        ["fileID"] = 1396623,
    }, -- [797]
    {
        ["race"] = "",
        ["fileID"] = 1396624,
    }, -- [798]
    {
        ["race"] = "",
        ["fileID"] = 1396625,
    }, -- [799]
    {
        ["race"] = "",
        ["fileID"] = 1396626,
    }, -- [800]
    {
        ["race"] = "",
        ["fileID"] = 1396627,
    }, -- [801]
    {
        ["race"] = "",
        ["fileID"] = 1396628,
    }, -- [802]
    {
        ["race"] = "",
        ["fileID"] = 1396629,
    }, -- [803]
    {
        ["race"] = "",
        ["fileID"] = 1396630,
    }, -- [804]
    {
        ["race"] = "",
        ["fileID"] = 1396631,
    }, -- [805]
    {
        ["race"] = "",
        ["fileID"] = 1396632,
    }, -- [806]
    {
        ["race"] = "",
        ["fileID"] = 1396633,
    }, -- [807]
    {
        ["race"] = "",
        ["fileID"] = 1396634,
    }, -- [808]
    {
        ["race"] = "",
        ["fileID"] = 1396635,
    }, -- [809]
    {
        ["race"] = "",
        ["fileID"] = 1396636,
    }, -- [810]
    {
        ["race"] = "",
        ["fileID"] = 1396637,
    }, -- [811]
    {
        ["race"] = "",
        ["fileID"] = 1396638,
    }, -- [812]
    {
        ["race"] = "",
        ["fileID"] = 1396639,
    }, -- [813]
    {
        ["race"] = "",
        ["fileID"] = 1396640,
    }, -- [814]
    {
        ["race"] = "",
        ["fileID"] = 1396641,
    }, -- [815]
    {
        ["race"] = "",
        ["fileID"] = 1396642,
    }, -- [816]
    {
        ["race"] = "",
        ["fileID"] = 1396643,
    }, -- [817]
    {
        ["race"] = "",
        ["fileID"] = 1396644,
    }, -- [818]
    {
        ["race"] = "",
        ["fileID"] = 1396645,
    }, -- [819]
    {
        ["race"] = "",
        ["fileID"] = 1396646,
    }, -- [820]
    {
        ["race"] = "",
        ["fileID"] = 1396647,
    }, -- [821]
    {
        ["race"] = "",
        ["fileID"] = 1396648,
    }, -- [822]
    {
        ["race"] = "",
        ["fileID"] = 1396649,
    }, -- [823]
    {
        ["race"] = "",
        ["fileID"] = 1396650,
    }, -- [824]
    {
        ["race"] = "",
        ["fileID"] = 1396651,
    }, -- [825]
    {
        ["race"] = "",
        ["fileID"] = 1396652,
    }, -- [826]
    {
        ["race"] = "",
        ["fileID"] = 1396653,
    }, -- [827]
    {
        ["race"] = "",
        ["fileID"] = 1396654,
    }, -- [828]
    {
        ["race"] = "",
        ["fileID"] = 1396655,
    }, -- [829]
    {
        ["race"] = "",
        ["fileID"] = 1396656,
    }, -- [830]
    {
        ["race"] = "",
        ["fileID"] = 1396657,
    }, -- [831]
    {
        ["race"] = "",
        ["fileID"] = 1396658,
    }, -- [832]
    {
        ["race"] = "",
        ["fileID"] = 1396659,
    }, -- [833]
    {
        ["race"] = "",
        ["fileID"] = 1396660,
    }, -- [834]
    {
        ["race"] = "",
        ["fileID"] = 1396661,
    }, -- [835]
    {
        ["race"] = "",
        ["fileID"] = 1396662,
    }, -- [836]
    {
        ["race"] = "",
        ["fileID"] = 1396663,
    }, -- [837]
    {
        ["race"] = "",
        ["fileID"] = 1396664,
    }, -- [838]
    {
        ["race"] = "",
        ["fileID"] = 1396665,
    }, -- [839]
    {
        ["race"] = "",
        ["fileID"] = 1396666,
    }, -- [840]
    {
        ["race"] = "",
        ["fileID"] = 1396667,
    }, -- [841]
    {
        ["race"] = "",
        ["fileID"] = 1396668,
    }, -- [842]
    {
        ["race"] = "",
        ["fileID"] = 1396669,
    }, -- [843]
    {
        ["race"] = "",
        ["fileID"] = 1396670,
    }, -- [844]
    {
        ["race"] = "",
        ["fileID"] = 1396671,
    }, -- [845]
    {
        ["race"] = "",
        ["fileID"] = 1396672,
    }, -- [846]
    {
        ["race"] = "",
        ["fileID"] = 1396673,
    }, -- [847]
    {
        ["race"] = "",
        ["fileID"] = 1396674,
    }, -- [848]
    {
        ["race"] = "",
        ["fileID"] = 1396675,
    }, -- [849]
    {
        ["race"] = "",
        ["fileID"] = 1396676,
    }, -- [850]
    {
        ["race"] = "",
        ["fileID"] = 1396677,
    }, -- [851]
    {
        ["race"] = "",
        ["fileID"] = 1396678,
    }, -- [852]
    {
        ["race"] = "",
        ["fileID"] = 1396679,
    }, -- [853]
    {
        ["race"] = "",
        ["fileID"] = 1396680,
    }, -- [854]
    {
        ["race"] = "",
        ["fileID"] = 1396681,
    }, -- [855]
    {
        ["race"] = "",
        ["fileID"] = 1396682,
    }, -- [856]
    {
        ["race"] = "",
        ["fileID"] = 1396683,
    }, -- [857]
    {
        ["race"] = "",
        ["fileID"] = 1396684,
    }, -- [858]
    {
        ["race"] = "",
        ["fileID"] = 1396685,
    }, -- [859]
    {
        ["race"] = "",
        ["fileID"] = 1396686,
    }, -- [860]
    {
        ["race"] = "",
        ["fileID"] = 1396687,
    }, -- [861]
    {
        ["race"] = "",
        ["fileID"] = 1396688,
    }, -- [862]
    {
        ["race"] = "",
        ["fileID"] = 1396689,
    }, -- [863]
    {
        ["race"] = "",
        ["fileID"] = 1396690,
    }, -- [864]
    {
        ["race"] = "",
        ["fileID"] = 1396691,
    }, -- [865]
    {
        ["race"] = "",
        ["fileID"] = 1396692,
    }, -- [866]
    {
        ["race"] = "",
        ["fileID"] = 1396693,
    }, -- [867]
    {
        ["race"] = "",
        ["fileID"] = 1396694,
    }, -- [868]
    {
        ["race"] = "",
        ["fileID"] = 1396695,
    }, -- [869]
    {
        ["race"] = "",
        ["fileID"] = 1396696,
    }, -- [870]
    {
        ["race"] = "",
        ["fileID"] = 1396697,
    }, -- [871]
    {
        ["race"] = "",
        ["fileID"] = 1396698,
    }, -- [872]
    {
        ["race"] = "",
        ["fileID"] = 1396699,
    }, -- [873]
    {
        ["race"] = "",
        ["fileID"] = 1396700,
    }, -- [874]
    {
        ["race"] = "",
        ["fileID"] = 1396701,
    }, -- [875]
    {
        ["race"] = "",
        ["fileID"] = 1396702,
    }, -- [876]
    {
        ["race"] = "",
        ["fileID"] = 1396703,
    }, -- [877]
    {
        ["race"] = "",
        ["fileID"] = 1396704,
    }, -- [878]
    {
        ["race"] = "",
        ["fileID"] = 1396705,
    }, -- [879]
    {
        ["race"] = "",
        ["fileID"] = 1396706,
    }, -- [880]
    {
        ["race"] = "",
        ["fileID"] = 1396707,
    }, -- [881]
    {
        ["race"] = "",
        ["fileID"] = 1396708,
    }, -- [882]
    {
        ["race"] = "",
        ["fileID"] = 1401832,
    }, -- [883]
    {
        ["race"] = "",
        ["fileID"] = 1401833,
    }, -- [884]
    {
        ["race"] = "",
        ["fileID"] = 1401834,
    }, -- [885]
    {
        ["race"] = "",
        ["fileID"] = 1401835,
    }, -- [886]
    {
        ["race"] = "",
        ["fileID"] = 1401836,
    }, -- [887]
    {
        ["race"] = "",
        ["fileID"] = 1401837,
    }, -- [888]
    {
        ["race"] = "",
        ["fileID"] = 1401838,
    }, -- [889]
    {
        ["race"] = "",
        ["fileID"] = 1401839,
    }, -- [890]
    {
        ["race"] = "",
        ["fileID"] = 1401840,
    }, -- [891]
    {
        ["race"] = "",
        ["fileID"] = 1401841,
    }, -- [892]
    {
        ["race"] = "",
        ["fileID"] = 1401842,
    }, -- [893]
    {
        ["race"] = "",
        ["fileID"] = 1401843,
    }, -- [894]
    {
        ["race"] = "",
        ["fileID"] = 1401844,
    }, -- [895]
    {
        ["race"] = "",
        ["fileID"] = 1401845,
    }, -- [896]
    {
        ["race"] = "",
        ["fileID"] = 1401846,
    }, -- [897]
    {
        ["race"] = "",
        ["fileID"] = 1401847,
    }, -- [898]
    {
        ["race"] = "",
        ["fileID"] = 1401848,
    }, -- [899]
    {
        ["race"] = "",
        ["fileID"] = 1401849,
    }, -- [900]
    {
        ["race"] = "",
        ["fileID"] = 1401850,
    }, -- [901]
    {
        ["race"] = "",
        ["fileID"] = 1401851,
    }, -- [902]
    {
        ["race"] = "",
        ["fileID"] = 1401852,
    }, -- [903]
    {
        ["race"] = "",
        ["fileID"] = 1401853,
    }, -- [904]
    {
        ["race"] = "",
        ["fileID"] = 1401854,
    }, -- [905]
    {
        ["race"] = "",
        ["fileID"] = 1401855,
    }, -- [906]
    {
        ["race"] = "",
        ["fileID"] = 1401856,
    }, -- [907]
    {
        ["race"] = "",
        ["fileID"] = 1401857,
    }, -- [908]
    {
        ["race"] = "",
        ["fileID"] = 1401858,
    }, -- [909]
    {
        ["race"] = "",
        ["fileID"] = 1401859,
    }, -- [910]
    {
        ["race"] = "",
        ["fileID"] = 1401860,
    }, -- [911]
    {
        ["race"] = "",
        ["fileID"] = 1401861,
    }, -- [912]
    {
        ["race"] = "",
        ["fileID"] = 1401862,
    }, -- [913]
    {
        ["race"] = "",
        ["fileID"] = 1401863,
    }, -- [914]
    {
        ["race"] = "",
        ["fileID"] = 1401864,
    }, -- [915]
    {
        ["race"] = "",
        ["fileID"] = 1401865,
    }, -- [916]
    {
        ["race"] = "",
        ["fileID"] = 1401866,
    }, -- [917]
    {
        ["race"] = "",
        ["fileID"] = 1401867,
    }, -- [918]
    {
        ["race"] = "",
        ["fileID"] = 1401868,
    }, -- [919]
    {
        ["race"] = "",
        ["fileID"] = 1401869,
    }, -- [920]
    {
        ["race"] = "",
        ["fileID"] = 1401870,
    }, -- [921]
    {
        ["race"] = "",
        ["fileID"] = 1401871,
    }, -- [922]
    {
        ["race"] = "",
        ["fileID"] = 1401872,
    }, -- [923]
    {
        ["race"] = "",
        ["fileID"] = 1401873,
    }, -- [924]
    {
        ["race"] = "",
        ["fileID"] = 1401874,
    }, -- [925]
    {
        ["race"] = "",
        ["fileID"] = 1401875,
    }, -- [926]
    {
        ["race"] = "",
        ["fileID"] = 1401876,
    }, -- [927]
    {
        ["race"] = "",
        ["fileID"] = 1401877,
    }, -- [928]
    {
        ["race"] = "",
        ["fileID"] = 1401878,
    }, -- [929]
    {
        ["race"] = "",
        ["fileID"] = 1401879,
    }, -- [930]
    {
        ["race"] = "",
        ["fileID"] = 1401880,
    }, -- [931]
    {
        ["race"] = "",
        ["fileID"] = 1401881,
    }, -- [932]
    {
        ["race"] = "",
        ["fileID"] = 1401882,
    }, -- [933]
    {
        ["race"] = "",
        ["fileID"] = 1401883,
    }, -- [934]
    {
        ["race"] = "",
        ["fileID"] = 1401884,
    }, -- [935]
    {
        ["race"] = "",
        ["fileID"] = 1401885,
    }, -- [936]
    {
        ["race"] = "",
        ["fileID"] = 1401886,
    }, -- [937]
    {
        ["race"] = "",
        ["fileID"] = 1401887,
    }, -- [938]
    {
        ["race"] = "",
        ["fileID"] = 1401888,
    }, -- [939]
    {
        ["race"] = "",
        ["fileID"] = 1401889,
    }, -- [940]
    {
        ["race"] = "",
        ["fileID"] = 1401890,
    }, -- [941]
    {
        ["race"] = "",
        ["fileID"] = 1401891,
    }, -- [942]
    {
        ["race"] = "",
        ["fileID"] = 1401892,
    }, -- [943]
    {
        ["race"] = "",
        ["fileID"] = 1401893,
    }, -- [944]
    {
        ["race"] = "",
        ["fileID"] = 1401894,
    }, -- [945]
    {
        ["race"] = "",
        ["fileID"] = 1416162,
    }, -- [946]
    {
        ["race"] = "",
        ["fileID"] = 1416163,
    }, -- [947]
    {
        ["race"] = "",
        ["fileID"] = 1416164,
    }, -- [948]
    {
        ["race"] = "",
        ["fileID"] = 1416165,
    }, -- [949]
    {
        ["race"] = "",
        ["fileID"] = 1416166,
    }, -- [950]
    {
        ["race"] = "",
        ["fileID"] = 1416167,
    }, -- [951]
    {
        ["race"] = "",
        ["fileID"] = 1416168,
    }, -- [952]
    {
        ["race"] = "",
        ["fileID"] = 1416169,
    }, -- [953]
    {
        ["race"] = "",
        ["fileID"] = 1416170,
    }, -- [954]
    {
        ["race"] = "",
        ["fileID"] = 1416171,
    }, -- [955]
    {
        ["race"] = "",
        ["fileID"] = 1416172,
    }, -- [956]
    {
        ["race"] = "",
        ["fileID"] = 1416173,
    }, -- [957]
    {
        ["race"] = "",
        ["fileID"] = 1416174,
    }, -- [958]
    {
        ["race"] = "",
        ["fileID"] = 1416175,
    }, -- [959]
    {
        ["race"] = "",
        ["fileID"] = 1416176,
    }, -- [960]
    {
        ["race"] = "",
        ["fileID"] = 1416177,
    }, -- [961]
    {
        ["race"] = "",
        ["fileID"] = 1416178,
    }, -- [962]
    {
        ["race"] = "",
        ["fileID"] = 1416179,
    }, -- [963]
    {
        ["race"] = "",
        ["fileID"] = 1416180,
    }, -- [964]
    {
        ["race"] = "",
        ["fileID"] = 1416181,
    }, -- [965]
    {
        ["race"] = "",
        ["fileID"] = 1416182,
    }, -- [966]
    {
        ["race"] = "",
        ["fileID"] = 1416183,
    }, -- [967]
    {
        ["race"] = "",
        ["fileID"] = 1416184,
    }, -- [968]
    {
        ["race"] = "",
        ["fileID"] = 1416185,
    }, -- [969]
    {
        ["race"] = "",
        ["fileID"] = 1416186,
    }, -- [970]
    {
        ["race"] = "",
        ["fileID"] = 1416187,
    }, -- [971]
    {
        ["race"] = "",
        ["fileID"] = 1416188,
    }, -- [972]
    {
        ["race"] = "",
        ["fileID"] = 1416189,
    }, -- [973]
    {
        ["race"] = "",
        ["fileID"] = 1416190,
    }, -- [974]
    {
        ["race"] = "",
        ["fileID"] = 1416191,
    }, -- [975]
    {
        ["race"] = "",
        ["fileID"] = 1416192,
    }, -- [976]
    {
        ["race"] = "",
        ["fileID"] = 1416193,
    }, -- [977]
    {
        ["race"] = "",
        ["fileID"] = 1416194,
    }, -- [978]
    {
        ["race"] = "",
        ["fileID"] = 1416195,
    }, -- [979]
    {
        ["race"] = "",
        ["fileID"] = 1416196,
    }, -- [980]
    {
        ["race"] = "",
        ["fileID"] = 1416197,
    }, -- [981]
    {
        ["race"] = "",
        ["fileID"] = 1416198,
    }, -- [982]
    {
        ["race"] = "",
        ["fileID"] = 1416199,
    }, -- [983]
    {
        ["race"] = "",
        ["fileID"] = 1416200,
    }, -- [984]
    {
        ["race"] = "",
        ["fileID"] = 1416201,
    }, -- [985]
    {
        ["race"] = "",
        ["fileID"] = 1416202,
    }, -- [986]
    {
        ["race"] = "",
        ["fileID"] = 1416203,
    }, -- [987]
    {
        ["race"] = "",
        ["fileID"] = 1416204,
    }, -- [988]
    {
        ["race"] = "",
        ["fileID"] = 1416205,
    }, -- [989]
    {
        ["race"] = "",
        ["fileID"] = 1416206,
    }, -- [990]
    {
        ["race"] = "",
        ["fileID"] = 1416207,
    }, -- [991]
    {
        ["race"] = "",
        ["fileID"] = 1416208,
    }, -- [992]
    {
        ["race"] = "",
        ["fileID"] = 1416209,
    }, -- [993]
    {
        ["race"] = "",
        ["fileID"] = 1416210,
    }, -- [994]
    {
        ["race"] = "",
        ["fileID"] = 1416211,
    }, -- [995]
    {
        ["race"] = "",
        ["fileID"] = 1416212,
    }, -- [996]
    {
        ["race"] = "",
        ["fileID"] = 1416213,
    }, -- [997]
    {
        ["race"] = "",
        ["fileID"] = 1416214,
    }, -- [998]
    {
        ["race"] = "",
        ["fileID"] = 1416215,
    }, -- [999]
    {
        ["race"] = "",
        ["fileID"] = 1416216,
    }, -- [1000]
    {
        ["race"] = "",
        ["fileID"] = 1416217,
    }, -- [1001]
    {
        ["race"] = "",
        ["fileID"] = 1416218,
    }, -- [1002]
    {
        ["race"] = "",
        ["fileID"] = 1416219,
    }, -- [1003]
    {
        ["race"] = "",
        ["fileID"] = 1416220,
    }, -- [1004]
    {
        ["race"] = "",
        ["fileID"] = 1416221,
    }, -- [1005]
    {
        ["race"] = "",
        ["fileID"] = 1416222,
    }, -- [1006]
    {
        ["race"] = "",
        ["fileID"] = 1416223,
    }, -- [1007]
    {
        ["race"] = "",
        ["fileID"] = 1416224,
    }, -- [1008]
    {
        ["race"] = "",
        ["fileID"] = 1416225,
    }, -- [1009]
    {
        ["race"] = "",
        ["fileID"] = 1416226,
    }, -- [1010]
    {
        ["race"] = "",
        ["fileID"] = 1416227,
    }, -- [1011]
    {
        ["race"] = "",
        ["fileID"] = 1416228,
    }, -- [1012]
    {
        ["race"] = "",
        ["fileID"] = 1416229,
    }, -- [1013]
    {
        ["race"] = "",
        ["fileID"] = 1416230,
    }, -- [1014]
    {
        ["race"] = "",
        ["fileID"] = 1416231,
    }, -- [1015]
    {
        ["race"] = "",
        ["fileID"] = 1416232,
    }, -- [1016]
    {
        ["race"] = "",
        ["fileID"] = 1416233,
    }, -- [1017]
    {
        ["race"] = "",
        ["fileID"] = 1416234,
    }, -- [1018]
    {
        ["race"] = "",
        ["fileID"] = 1416235,
    }, -- [1019]
    {
        ["race"] = "",
        ["fileID"] = 1416236,
    }, -- [1020]
    {
        ["race"] = "",
        ["fileID"] = 1416237,
    }, -- [1021]
    {
        ["race"] = "",
        ["fileID"] = 1416238,
    }, -- [1022]
    {
        ["race"] = "",
        ["fileID"] = 1416239,
    }, -- [1023]
    {
        ["race"] = "",
        ["fileID"] = 1416240,
    }, -- [1024]
    {
        ["race"] = "",
        ["fileID"] = 1416241,
    }, -- [1025]
    {
        ["race"] = "",
        ["fileID"] = 1416242,
    }, -- [1026]
    {
        ["race"] = "",
        ["fileID"] = 1416243,
    }, -- [1027]
    {
        ["race"] = "",
        ["fileID"] = 1416244,
    }, -- [1028]
    {
        ["race"] = "",
        ["fileID"] = 1416245,
    }, -- [1029]
    {
        ["race"] = "",
        ["fileID"] = 1416246,
    }, -- [1030]
    {
        ["race"] = "",
        ["fileID"] = 1416247,
    }, -- [1031]
    {
        ["race"] = "",
        ["fileID"] = 1416248,
    }, -- [1032]
    {
        ["race"] = "",
        ["fileID"] = 1416249,
    }, -- [1033]
    {
        ["race"] = "",
        ["fileID"] = 1416250,
    }, -- [1034]
    {
        ["race"] = "",
        ["fileID"] = 1416251,
    }, -- [1035]
    {
        ["race"] = "",
        ["fileID"] = 1416252,
    }, -- [1036]
    {
        ["race"] = "",
        ["fileID"] = 1416253,
    }, -- [1037]
    {
        ["race"] = "",
        ["fileID"] = 1416254,
    }, -- [1038]
    {
        ["race"] = "",
        ["fileID"] = 1416255,
    }, -- [1039]
    {
        ["race"] = "",
        ["fileID"] = 1416256,
    }, -- [1040]
    {
        ["race"] = "",
        ["fileID"] = 1416257,
    }, -- [1041]
    {
        ["race"] = "",
        ["fileID"] = 1416258,
    }, -- [1042]
    {
        ["race"] = "",
        ["fileID"] = 1416259,
    }, -- [1043]
    {
        ["race"] = "",
        ["fileID"] = 1416260,
    }, -- [1044]
    {
        ["race"] = "",
        ["fileID"] = 1416261,
    }, -- [1045]
    {
        ["race"] = "",
        ["fileID"] = 1416262,
    }, -- [1046]
    {
        ["race"] = "",
        ["fileID"] = 1416263,
    }, -- [1047]
    {
        ["race"] = "",
        ["fileID"] = 1416264,
    }, -- [1048]
    {
        ["race"] = "",
        ["fileID"] = 1416265,
    }, -- [1049]
    {
        ["race"] = "",
        ["fileID"] = 1416266,
    }, -- [1050]
    {
        ["race"] = "",
        ["fileID"] = 1416267,
    }, -- [1051]
    {
        ["race"] = "",
        ["fileID"] = 1416268,
    }, -- [1052]
    {
        ["race"] = "",
        ["fileID"] = 1416269,
    }, -- [1053]
    {
        ["race"] = "",
        ["fileID"] = 1416270,
    }, -- [1054]
    {
        ["race"] = "",
        ["fileID"] = 1416271,
    }, -- [1055]
    {
        ["race"] = "",
        ["fileID"] = 1416272,
    }, -- [1056]
    {
        ["race"] = "",
        ["fileID"] = 1416273,
    }, -- [1057]
    {
        ["race"] = "",
        ["fileID"] = 1416274,
    }, -- [1058]
    {
        ["race"] = "",
        ["fileID"] = 1416275,
    }, -- [1059]
    {
        ["race"] = "",
        ["fileID"] = 1416276,
    }, -- [1060]
    {
        ["race"] = "",
        ["fileID"] = 1416277,
    }, -- [1061]
    {
        ["race"] = "",
        ["fileID"] = 1416278,
    }, -- [1062]
    {
        ["race"] = "",
        ["fileID"] = 1416279,
    }, -- [1063]
    {
        ["race"] = "",
        ["fileID"] = 1416280,
    }, -- [1064]
    {
        ["race"] = "",
        ["fileID"] = 1416281,
    }, -- [1065]
    {
        ["race"] = "",
        ["fileID"] = 1416282,
    }, -- [1066]
    {
        ["race"] = "",
        ["fileID"] = 1416283,
    }, -- [1067]
    {
        ["race"] = "",
        ["fileID"] = 1416284,
    }, -- [1068]
    {
        ["race"] = "",
        ["fileID"] = 1416285,
    }, -- [1069]
    {
        ["race"] = "",
        ["fileID"] = 1416286,
    }, -- [1070]
    {
        ["race"] = "",
        ["fileID"] = 1416287,
    }, -- [1071]
    {
        ["race"] = "",
        ["fileID"] = 1416288,
    }, -- [1072]
    {
        ["race"] = "",
        ["fileID"] = 1416289,
    }, -- [1073]
    {
        ["race"] = "",
        ["fileID"] = 1416290,
    }, -- [1074]
    {
        ["race"] = "",
        ["fileID"] = 1416291,
    }, -- [1075]
    {
        ["race"] = "",
        ["fileID"] = 1416292,
    }, -- [1076]
    {
        ["race"] = "",
        ["fileID"] = 1416293,
    }, -- [1077]
    {
        ["race"] = "",
        ["fileID"] = 1416294,
    }, -- [1078]
    {
        ["race"] = "",
        ["fileID"] = 1416295,
    }, -- [1079]
    {
        ["race"] = "",
        ["fileID"] = 1416296,
    }, -- [1080]
    {
        ["race"] = "",
        ["fileID"] = 1416297,
    }, -- [1081]
    {
        ["race"] = "",
        ["fileID"] = 1416298,
    }, -- [1082]
    {
        ["race"] = "",
        ["fileID"] = 1416299,
    }, -- [1083]
    {
        ["race"] = "",
        ["fileID"] = 1416300,
    }, -- [1084]
    {
        ["race"] = "",
        ["fileID"] = 1416301,
    }, -- [1085]
    {
        ["race"] = "",
        ["fileID"] = 1416302,
    }, -- [1086]
    {
        ["race"] = "",
        ["fileID"] = 1416303,
    }, -- [1087]
    {
        ["race"] = "",
        ["fileID"] = 1416304,
    }, -- [1088]
    {
        ["race"] = "",
        ["fileID"] = 1416305,
    }, -- [1089]
    {
        ["race"] = "",
        ["fileID"] = 1416306,
    }, -- [1090]
    {
        ["race"] = "",
        ["fileID"] = 1416307,
    }, -- [1091]
    {
        ["race"] = "",
        ["fileID"] = 1416308,
    }, -- [1092]
    {
        ["race"] = "",
        ["fileID"] = 1416309,
    }, -- [1093]
    {
        ["race"] = "",
        ["fileID"] = 1416310,
    }, -- [1094]
    {
        ["race"] = "",
        ["fileID"] = 1416311,
    }, -- [1095]
    {
        ["race"] = "",
        ["fileID"] = 1416312,
    }, -- [1096]
    {
        ["race"] = "",
        ["fileID"] = 1416313,
    }, -- [1097]
    {
        ["race"] = "",
        ["fileID"] = 1416314,
    }, -- [1098]
    {
        ["race"] = "",
        ["fileID"] = 1416315,
    }, -- [1099]
    {
        ["race"] = "",
        ["fileID"] = 1416316,
    }, -- [1100]
    {
        ["race"] = "",
        ["fileID"] = 1416317,
    }, -- [1101]
    {
        ["race"] = "",
        ["fileID"] = 1416318,
    }, -- [1102]
    {
        ["race"] = "",
        ["fileID"] = 1416319,
    }, -- [1103]
    {
        ["race"] = "",
        ["fileID"] = 1416320,
    }, -- [1104]
    {
        ["race"] = "",
        ["fileID"] = 1416321,
    }, -- [1105]
    {
        ["race"] = "",
        ["fileID"] = 1416322,
    }, -- [1106]
    {
        ["race"] = "",
        ["fileID"] = 1416323,
    }, -- [1107]
    {
        ["race"] = "",
        ["fileID"] = 1416324,
    }, -- [1108]
    {
        ["race"] = "",
        ["fileID"] = 1416325,
    }, -- [1109]
    {
        ["race"] = "",
        ["fileID"] = 1416326,
    }, -- [1110]
    {
        ["race"] = "",
        ["fileID"] = 1416327,
    }, -- [1111]
    {
        ["race"] = "",
        ["fileID"] = 1416328,
    }, -- [1112]
    {
        ["race"] = "",
        ["fileID"] = 1416329,
    }, -- [1113]
    {
        ["race"] = "",
        ["fileID"] = 1416330,
    }, -- [1114]
    {
        ["race"] = "",
        ["fileID"] = 1416331,
    }, -- [1115]
    {
        ["race"] = "",
        ["fileID"] = 1416332,
    }, -- [1116]
    {
        ["race"] = "",
        ["fileID"] = 1416333,
    }, -- [1117]
    {
        ["race"] = "",
        ["fileID"] = 1416334,
    }, -- [1118]
    {
        ["race"] = "",
        ["fileID"] = 1416335,
    }, -- [1119]
    {
        ["race"] = "",
        ["fileID"] = 1416336,
    }, -- [1120]
    {
        ["race"] = "",
        ["fileID"] = 1416337,
    }, -- [1121]
    {
        ["race"] = "",
        ["fileID"] = 1416338,
    }, -- [1122]
    {
        ["race"] = "",
        ["fileID"] = 1416339,
    }, -- [1123]
    {
        ["race"] = "",
        ["fileID"] = 1416340,
    }, -- [1124]
    {
        ["race"] = "",
        ["fileID"] = 1416341,
    }, -- [1125]
    {
        ["race"] = "",
        ["fileID"] = 1416342,
    }, -- [1126]
    {
        ["race"] = "",
        ["fileID"] = 1416343,
    }, -- [1127]
    {
        ["race"] = "",
        ["fileID"] = 1416344,
    }, -- [1128]
    {
        ["race"] = "",
        ["fileID"] = 1416345,
    }, -- [1129]
    {
        ["race"] = "",
        ["fileID"] = 1416346,
    }, -- [1130]
    {
        ["race"] = "",
        ["fileID"] = 1416347,
    }, -- [1131]
    {
        ["race"] = "",
        ["fileID"] = 1416348,
    }, -- [1132]
    {
        ["race"] = "",
        ["fileID"] = 1416349,
    }, -- [1133]
    {
        ["race"] = "",
        ["fileID"] = 1416350,
    }, -- [1134]
    {
        ["race"] = "",
        ["fileID"] = 1416351,
    }, -- [1135]
    {
        ["race"] = "",
        ["fileID"] = 1416352,
    }, -- [1136]
    {
        ["race"] = "",
        ["fileID"] = 1416353,
    }, -- [1137]
    {
        ["race"] = "",
        ["fileID"] = 1416354,
    }, -- [1138]
    {
        ["race"] = "",
        ["fileID"] = 1416355,
    }, -- [1139]
    {
        ["race"] = "",
        ["fileID"] = 1416356,
    }, -- [1140]
    {
        ["race"] = "",
        ["fileID"] = 1416357,
    }, -- [1141]
    {
        ["race"] = "",
        ["fileID"] = 1416358,
    }, -- [1142]
    {
        ["race"] = "",
        ["fileID"] = 1416359,
    }, -- [1143]
    {
        ["race"] = "",
        ["fileID"] = 1416360,
    }, -- [1144]
    {
        ["race"] = "",
        ["fileID"] = 1416361,
    }, -- [1145]
    {
        ["race"] = "",
        ["fileID"] = 1416362,
    }, -- [1146]
    {
        ["race"] = "",
        ["fileID"] = 1416363,
    }, -- [1147]
    {
        ["race"] = "",
        ["fileID"] = 1416364,
    }, -- [1148]
    {
        ["race"] = "",
        ["fileID"] = 1416365,
    }, -- [1149]
    {
        ["race"] = "",
        ["fileID"] = 1416366,
    }, -- [1150]
    {
        ["race"] = "",
        ["fileID"] = 1416367,
    }, -- [1151]
    {
        ["race"] = "",
        ["fileID"] = 1416368,
    }, -- [1152]
    {
        ["race"] = "",
        ["fileID"] = 1416369,
    }, -- [1153]
    {
        ["race"] = "",
        ["fileID"] = 1416370,
    }, -- [1154]
    {
        ["race"] = "",
        ["fileID"] = 1416371,
    }, -- [1155]
    {
        ["race"] = "",
        ["fileID"] = 1416372,
    }, -- [1156]
    {
        ["race"] = "",
        ["fileID"] = 1416373,
    }, -- [1157]
    {
        ["race"] = "",
        ["fileID"] = 1416374,
    }, -- [1158]
    {
        ["race"] = "",
        ["fileID"] = 1416375,
    }, -- [1159]
    {
        ["race"] = "",
        ["fileID"] = 1416376,
    }, -- [1160]
    {
        ["race"] = "",
        ["fileID"] = 1416377,
    }, -- [1161]
    {
        ["race"] = "",
        ["fileID"] = 1416378,
    }, -- [1162]
    {
        ["race"] = "",
        ["fileID"] = 1416379,
    }, -- [1163]
    {
        ["race"] = "",
        ["fileID"] = 1416380,
    }, -- [1164]
    {
        ["race"] = "",
        ["fileID"] = 1416381,
    }, -- [1165]
    {
        ["race"] = "",
        ["fileID"] = 1416382,
    }, -- [1166]
    {
        ["race"] = "",
        ["fileID"] = 1416383,
    }, -- [1167]
    {
        ["race"] = "",
        ["fileID"] = 1416384,
    }, -- [1168]
    {
        ["race"] = "",
        ["fileID"] = 1416385,
    }, -- [1169]
    {
        ["race"] = "",
        ["fileID"] = 1416386,
    }, -- [1170]
    {
        ["race"] = "",
        ["fileID"] = 1416387,
    }, -- [1171]
    {
        ["race"] = "",
        ["fileID"] = 1416388,
    }, -- [1172]
    {
        ["race"] = "",
        ["fileID"] = 1416389,
    }, -- [1173]
    {
        ["race"] = "",
        ["fileID"] = 1416390,
    }, -- [1174]
    {
        ["race"] = "",
        ["fileID"] = 1416391,
    }, -- [1175]
    {
        ["race"] = "",
        ["fileID"] = 1416392,
    }, -- [1176]
    {
        ["race"] = "",
        ["fileID"] = 1416393,
    }, -- [1177]
    {
        ["race"] = "",
        ["fileID"] = 1416394,
    }, -- [1178]
    {
        ["race"] = "",
        ["fileID"] = 1416395,
    }, -- [1179]
    {
        ["race"] = "",
        ["fileID"] = 1416396,
    }, -- [1180]
    {
        ["race"] = "",
        ["fileID"] = 1416397,
    }, -- [1181]
    {
        ["race"] = "",
        ["fileID"] = 1416398,
    }, -- [1182]
    {
        ["race"] = "",
        ["fileID"] = 1416399,
    }, -- [1183]
    {
        ["race"] = "",
        ["fileID"] = 1416400,
    }, -- [1184]
    {
        ["race"] = "",
        ["fileID"] = 1416401,
    }, -- [1185]
    {
        ["race"] = "",
        ["fileID"] = 1416402,
    }, -- [1186]
    {
        ["race"] = "",
        ["fileID"] = 1416403,
    }, -- [1187]
    {
        ["race"] = "",
        ["fileID"] = 1416404,
    }, -- [1188]
    {
        ["race"] = "",
        ["fileID"] = 1416405,
    }, -- [1189]
    {
        ["race"] = "",
        ["fileID"] = 1416406,
    }, -- [1190]
    {
        ["race"] = "",
        ["fileID"] = 1416407,
    }, -- [1191]
    {
        ["race"] = "",
        ["fileID"] = 1416408,
    }, -- [1192]
    {
        ["race"] = "",
        ["fileID"] = 1416409,
    }, -- [1193]
    {
        ["race"] = "",
        ["fileID"] = 1416410,
    }, -- [1194]
    {
        ["race"] = "",
        ["fileID"] = 1416417,
    }, -- [1195]
    {
        ["race"] = "",
        ["fileID"] = 1416418,
    }, -- [1196]
    {
        ["race"] = "",
        ["fileID"] = 1416419,
    }, -- [1197]
    {
        ["race"] = "",
        ["fileID"] = 1416420,
    }, -- [1198]
    {
        ["race"] = "",
        ["fileID"] = 1416421,
    }, -- [1199]
    {
        ["race"] = "",
        ["fileID"] = 1416422,
    }, -- [1200]
    {
        ["race"] = "",
        ["fileID"] = 1416423,
    }, -- [1201]
    {
        ["race"] = "",
        ["fileID"] = 1416424,
    }, -- [1202]
    {
        ["race"] = "",
        ["fileID"] = 1416425,
    }, -- [1203]
    {
        ["race"] = "",
        ["fileID"] = 1416426,
    }, -- [1204]
    {
        ["race"] = "",
        ["fileID"] = 1416427,
    }, -- [1205]
    {
        ["race"] = "",
        ["fileID"] = 1416428,
    }, -- [1206]
    {
        ["race"] = "",
        ["fileID"] = 1416429,
    }, -- [1207]
}