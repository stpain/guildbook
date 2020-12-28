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

Guildbook.Data = {}

Guildbook.Data.DefaultGlobalSettings = {
    Debug = false,
    ShowMinimapButton = true,
    GuildRosterCache = {},
    Build = 0.0,
}

Guildbook.Data.DefaultCharacterSettings = {
    MainSpec = '-',
    OffSpec = '-',
    MainSpecIsPvP = false,
    OffSpecIsPvP = false,
    Profession1 = '-',
    Profession1Level = 0,
    Profession2 = '-',
    Profession2Level = 0,
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
    AttunementsKeys = {
        UBRS = false,
        MC = false,
        ONY = false,
        BWL = false,
        NAXX = false,
    },
    CalendarEvents = {},
    GuildBank = {},
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
    ['DEATH KNIGHT'] = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:128:192|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:128:192|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:128:192|t", 
        IconID = 135771, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DEATHKNIGHT", 
        RGB={ 0.77, 0.12, 0.23 }, 
        FontColour='|cffC41F3B', 
        Specializations={'Frost','Blood','Unholy',} 
    },
    DRUID = { 
        FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:192:256:0:64|t", 
        FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:192:256:0:64|t", 
        FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:192:256:0:64|t", 
        IconID = 625999, 
        Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DRUID", 
        RGB={ 1.00, 0.49, 0.04 }, 
        FontColour='|cffFF7D0A', 
        Specializations={'Balance','Restoration','Cat','Bear',} 
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
        Specializations={'Fire','Frost','Arcane',} 
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
        Specializations={'Assassination','Combat','Subtlety',} 
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
    },
    Blacksmithing = { 
        ID = 2, 
        Name = 'Blacksmithing', 
        Icon = 'Interface\\Icons\\Trade_Blacksmithing', 
        IconID = 136241,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:77:141:3:67|t', 
    },
    Enchanting = { 
        ID = 3, 
        Name = 'Enchanting', 
        Icon = 'Interface\\Icons\\Trade_Engraving', 
        IconID = 136244,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:153:217:3:67|t', 
    },
    Engineering = { 
        ID = 4, 
        Name = 'Engineering', 
        Icon = 'Interface\\Icons\\Trade_Engineering', 
        IconID = 136243,
        FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:227:291:3:67|t', 
    },
    Inscription = { 
        ID = 5, 
        Name = 'Inscription', 
        Icon = 'Interface\\Icons\\INV_Inscription_Tradeskill01', 
        IconID = 237171,
        FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:3:67:79:143|t', 
    },
    Jewelcrafting = { 
        ID = 6, 
        Name = 'Jewelcrafting', 
        Icon = 'Interface\\Icons\\INV_MISC_GEM_01', 
        IconID = 134071,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:77:141:79:143|t', 
    },
    Leatherworking = { 
        ID = 7, 
        Name = 'Leatherworking', 
        Icon = 'Interface\\Icons\\INV_Misc_ArmorKit_17', 
        IconID = 136247,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:153:217:79:143|t', 
    },
    Tailoring = { 
        ID = 8, 
        Name = 'Tailoring', 
        Icon = 'Interface\\Icons\\Trade_Tailoring', 
        IconID = 136249,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:227:291:79:143|t', 
    },
    Herbalism = { 
        ID = 9, 
        Name = 'Herbalism', 
        Icon = 'Interface\\Icons\\INV_Misc_Flower_02', 
        IconID = 133939,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:38:102:153:217|t', 
    },
    Skinning = { 
        ID = 10, 
        Name = 'Skinning', 
        Icon = 'Interface\\Icons\\INV_Misc_Pelt_Wolf_01', 
        IconID = 134366,
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:187:251:153:217|t', 
    },
    Mining = { 
        ID = 11, 
        Name = 'Mining', 
        Icon = 'Interface\\Icons\\Spell_Fire_FlameBlades',
        IconID = 136248, 
        FontStringIconSMALL ='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:112:176:153:217|t', 
    },
    Cooking = { 
        ID = 12, 
        Name = 'Cooking', 
        Icon = 'Interface\\Icons\\inv_misc_food_15', 
        IconID = 133971,
        FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:2:66:226:290|t', 
    },
    Fishing = { 
        ID = 13, 
        Name = 'Fishing', 
        Icon = 'Interface\\Icons\\Trade_Fishing' , 
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
}

Guildbook.Data.Professions = {
    { Name = 'Alchemy', TradeSkill = true, },
    { Name = 'Blacksmithing', TradeSkill = true, },
    { Name = 'Enchanting', TradeSkill = true, },
    { Name = 'Engineering', TradeSkill = true, },
    { Name = 'Inscription', TradeSkill = true, },
    { Name = 'Jewelcrafting', TradeSkill = true, },
    { Name = 'Leatherworking', TradeSkill = true, },
    { Name = 'Tailoring', TradeSkill = true, },
    --{ Name = 'Cooking', TradeSkill = true, },
    { Name = 'Mining', TradeSkill = true, },
}

Guildbook.Data.SpecFontStringIconSMALL = { 
    DRUID = { 
        ['-'] = '', 
        Balance = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:0:63|t", 
        Bear = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", 
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
        Restoration = 'Healer', 
        Balance = 'Ranged', 
        Cat = 'Melee',  
        Bear = 'Tank', 
        unknown = 'Unknown',
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    SHAMAN = { 
        Elemental = 'Ranged', 
        Enhancement = 'Melee', 
        Restoration = 'Healer', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    HUNTER = { 
        Marksmanship = 'Ranged', 
        ['Beast Master'] = 'Ranged', 
        Survival = 'Ranged', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    PALADIN = { 
        Holy = 'Healer', 
        Protection = 'Tank', 
        Retribution = 'Melee', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    WARRIOR = { 
        Arms = 'Melee', 
        Fury = 'Melee', 
        Protection = 'Tank', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    ROGUE = { 
        Assassination = 'Melee', 
        Combat = 'Melee', 
        Subtlety = 'Melee', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    PRIEST = { 
        Holy = 'Healer', 
        Discipline = 'Healer', 
        Shadow = 'Ranged', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    WARLOCK = { 
        Demonology = 'Ranged', 
        Affliction = 'Ranged', 
        Destruction = 'Ranged', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    MAGE = { 
        Frost = 'Ranged', 
        Fire = 'Ranged', 
        Arcane = 'Ranged', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    DEATHKNIGHT = { 
        Frost = 'Tank', 
        Blood = 'Tank', 
        Unholy = 'Melee', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
        ['-'] = '-' 
    },
    ['DEATH KNIGHT'] = { 
        Frost = 'Tank', 
        Blood = 'Tank', 
        Unholy = 'Melee', 
        unknown = 'Unknown', 
        pvp = 'PvP', 
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
    [0] = 'Not Available',
    [1] = 'Morning',
    [2] = 'Afternoon',
    [3] = 'Evening',
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

--pos was an old value used to determine display position
Guildbook.Data.InventorySlots = {
    { Name = 'INVSLOT_HEAD', Id = 1, Pos = 0, Display = 'Head' },
    { Name = 'INVSLOT_NECK', Id = 2, Pos = 0, Display = 'Neck' },
    { Name = 'INVSLOT_SHOULDER', Id = 3, Pos = 0, Display = 'Shoulder' },
    { Name = 'INVSLOT_CHEST', Id = 5, Pos = 0, Display = 'Chest' },
    { Name = 'INVSLOT_WAIST', Id = 6, Pos = 1, Display = 'Waist' },
    { Name = 'INVSLOT_LEGS', Id = 7, Pos = 1, Display = 'Legs' },
    { Name = 'INVSLOT_FEET', Id = 8, Pos = 1, Display = 'Feet' },
    { Name = 'INVSLOT_WRIST', Id = 9, Pos = 0, Display = 'Wrist' },
    { Name = 'INVSLOT_HAND', Id = 10, Pos = 1, Display = 'Hand' },
    { Name = 'INVSLOT_FINGER1', Id = 11, Pos = 1, Display = 'Finger 1' },
    { Name = 'INVSLOT_FINGER2', Id = 12, Pos = 1, Display = 'Finger 2' },
    { Name = 'INVSLOT_TRINKET1', Id = 13, Pos = 1, Display = 'Trinket 1' },
    { Name = 'INVSLOT_TRINKET2', Id = 14, Pos = 1, Display = 'Trinket 2' },
    { Name = 'INVSLOT_BACK', Id = 15, Pos = 0, Display = 'Back' },
    { Name = 'INVSLOT_MAINHAND', Id = 16, Pos = 0, Display = 'Main Hand' },
    { Name = 'INVSLOT_OFFHAND', Id = 17, Pos = 0, Display = 'Off Hand' },
    { Name = 'INVSLOT_RANGED', Id = 18, Pos = 0, Display = 'Range' },
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
	['Darkmoon Faire'] = {
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
	['Love is in the Air'] = {
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
	['Hallows End'] = {
		['Start'] = { 
			day = 18, 
			month = 10,
		},
		['End'] = { 
			day = 21, 
			month = 11,
		},
		['Texture'] = {
			['Start'] = 235468,
			['OnGoing'] = 235467,
			['End'] = 235466,
		}
	},
}


-- Guildbook.itemdata = {}
-- Guildbook.itemdata["MoltenCore"] = {
-- 	MapID = 2717,
-- 	InstanceID = 409,
-- 	AtlasMapID = "MoltenCore",
-- 	AtlasMapFile = "MoltenCore",
-- 	ContentType = RAID40_CONTENT,
-- 	LoadDifficulty = RAID40_DIFF,
-- 	items = {
-- 		{	--MCLucifron
-- 			name = "Lucifron",
-- 			npcID = 12118,
-- 			Level = 999,
-- 			DisplayIDs = {{13031},{12030}},
-- 			AtlasMapBossID = 1,
-- 			['loot'] = {
-- 				{ 1, 16800 },	-- Arcanist Boots
-- 				{ 2, 16805 },	-- Felheart Gloves
-- 				{ 3, 16829 },	-- Cenarion Boots
-- 				{ 4, 16837 },	-- Earthfury Boots
-- 				{ 5, 16859 },	-- Lawbringer Boots
-- 				{ 6, 16863 },	-- Gauntlets of Might
-- 				{ 16, 18870 },	-- Helm of the Lifegiver
-- 				{ 17, 17109 },	-- Choker of Enlightenment
-- 				{ 18, 19145 },	-- Robe of Volatile Power
-- 				{ 19, 19146 },	-- Wristguards of Stability
-- 				{ 20, 18872 },	-- Manastorm Leggings
-- 				{ 21, 18875 },	-- Salamander Scale Pants
-- 				{ 22, 18861 },	-- Flamewaker Legplates
-- 				{ 23, 18879 },	-- Heavy Dark Iron Ring
-- 				{ 24, 19147 },	-- Ring of Spell Power
-- 				{ 25, 17077 },	-- Crimson Shocker
-- 				{ 26, 18878 },	-- Sorcerous Dagger
-- 				{ 30, 16665 },	-- Tome of Tranquilizing Shot
-- 			},
-- 		},
-- 		{	--MCMagmadar
-- 			name = "Magmadar",
-- 			npcID = 11982,
-- 			Level = 999,
-- 			DisplayIDs = {{10193}},
-- 			AtlasMapBossID = 2,
-- 			['loot'] = {
-- 				{ 1,  16814 },	-- Pants of Prophecy
-- 				{ 2,  16796 },	-- Arcanist Leggings
-- 				{ 3,  16810 },	-- Felheart Pants
-- 				{ 4,  16822 },	-- Nightslayer Pants
-- 				{ 5,  16835 },	-- Cenarion Leggings
-- 				{ 6,  16847 },	-- Giantstalker's Leggings
-- 				{ 7,  16843 },	-- Earthfury Legguards
-- 				{ 8,  16855 },	-- Lawbringer Legplates
-- 				{ 9,  16867 },	-- Legplates of Might
-- 				{ 11, 18203 },	-- Eskhandar's Right Claw
-- 				{ 16, 17065 },	-- Medallion of Steadfast Might
-- 				{ 17, 18829 },	-- Deep Earth Spaulders
-- 				{ 18, 18823 },	-- Aged Core Leather Gloves
-- 				{ 19, 19143 },	-- Flameguard Gauntlets
-- 				{ 20, 19136 },	-- Mana Igniting Cord
-- 				{ 21, 18861 },	-- Flamewaker Legplates
-- 				{ 22, 19144 },	-- Sabatons of the Flamewalker
-- 				{ 23, 18824 },	-- Magma Tempered Boots
-- 				{ 24, 18821 },	-- Quick Strike Ring
-- 				{ 25, 18820 },	-- Talisman of Ephemeral Power
-- 				{ 26, 19142 },	-- Fire Runed Grimoire
-- 				{ 27, 17069 },	-- Striker's Mark
-- 				{ 28, 17073 },	-- Earthshaker
-- 				{ 29, 18822 },	-- Obsidian Edged Blade
-- 			},
-- 		},
-- 		{	--MCGehennas
-- 			name = "Gehennas",
-- 			npcID = 12259,
-- 			Level = 999,
-- 			DisplayIDs = {{13030},{12002}},
-- 			AtlasMapBossID = 3,
-- 			['loot'] = {
-- 				{ 1,  16812 },	-- Gloves of Prophecy
-- 				{ 2,  16826 },	-- Nightslayer Gloves
-- 				{ 3,  16849 },	-- Giantstalker's Boots
-- 				{ 4,  16839 },	-- Earthfury Gauntlets
-- 				{ 5,  16860 },	-- Lawbringer Gauntlets
-- 				{ 6,  16862 },	-- Sabatons of Might
-- 				{ 16, 18870 },	-- Helm of the Lifegiver
-- 				{ 17, 19145 },	-- Robe of Volatile Power
-- 				{ 18, 19146 },	-- Wristguards of Stability
-- 				{ 19, 18872 },	-- Manastorm Leggings
-- 				{ 20, 18875 },	-- Salamander Scale Pants
-- 				{ 21, 18861 },	-- Flamewaker Legplates
-- 				{ 22, 18879 },	-- Heavy Dark Iron Ring
-- 				{ 23, 19147 },	-- Ring of Spell Power
-- 				{ 24, 17077 },	-- Crimson Shocker
-- 				{ 25, 18878 },	-- Sorcerous Dagger
-- 			},
-- 		},
-- 		{	--MCGarr
-- 			name = "Garr",
-- 			npcID = 12057,
-- 			Level = 999,
-- 			DisplayIDs = {{12110}, {5781}},
-- 			AtlasMapBossID = 4,
-- 			['loot'] = {
-- 				{ 1, 18564 },	-- Bindings of the Windseeker
-- 				{ 3,  16813 },	-- Circlet of Prophecy
-- 				{ 4,  16795 },	-- Arcanist Crown
-- 				{ 5,  16808 },	-- Felheart Horns
-- 				{ 6,  16821 },	-- Nightslayer Cover
-- 				{ 7,  16834 },	-- Cenarion Helm
-- 				{ 8,  16846 },	-- Giantstalker's Helmet
-- 				{ 9,  16842 },	-- Earthfury Helmet
-- 				{ 10,  16854 },	-- Lawbringer Helm
-- 				{ 11,  16866 },	-- Helm of Might
-- 				{ 16, 18829 },	-- Deep Earth Spaulders
-- 				{ 17, 18823 },	-- Aged Core Leather Gloves
-- 				{ 18, 19143 },	-- Flameguard Gauntlets
-- 				{ 19, 19136 },	-- Mana Igniting Cord
-- 				{ 20, 18861 },	-- Flamewaker Legplates
-- 				{ 21, 19144 },	-- Sabatons of the Flamewalker
-- 				{ 22, 18824 },	-- Magma Tempered Boots
-- 				{ 23, 18821 },	-- Quick Strike Ring
-- 				{ 24, 18820 },	-- Talisman of Ephemeral Power
-- 				{ 25, 19142 },	-- Fire Runed Grimoire
-- 				{ 26, 17066 },	-- Drillborer Disk
-- 				{ 27, 17071 },	-- Gutgore Ripper
-- 				{ 28, 17105 },	-- Aurastone Hammer
-- 				{ 29, 18832 },	-- Brutality Blade
-- 				{ 30, 18822 },	-- Obsidian Edged Blade
-- 			},
-- 		},
-- 		{	--MCShazzrah
-- 			name = "Shazzrah",
-- 			npcID = 12264,
-- 			Level = 999,
-- 			DisplayIDs = {{13032}},
-- 			AtlasMapBossID = 5,
-- 			['loot'] = {
-- 				{ 1,  16811 },	-- Boots of Prophecy
-- 				{ 2,  16801 },	-- Arcanist Gloves
-- 				{ 3,  16803 },	-- Felheart Slippers
-- 				{ 4,  16824 },	-- Nightslayer Boots
-- 				{ 5,  16831 },	-- Cenarion Gloves
-- 				{ 6,  16852 },	-- Giantstalker's Gloves
-- 				{ 16, 18870 },	-- Helm of the Lifegiver
-- 				{ 17, 19145 },	-- Robe of Volatile Power
-- 				{ 18, 19146 },	-- Wristguards of Stability
-- 				{ 19, 18872 },	-- Manastorm Leggings
-- 				{ 20, 18875 },	-- Salamander Scale Pants
-- 				{ 21, 18861 },	-- Flamewaker Legplates
-- 				{ 22, 18879 },	-- Heavy Dark Iron Ring
-- 				{ 23, 19147 },	-- Ring of Spell Power
-- 				{ 24, 17077 },	-- Crimson Shocker
-- 				{ 25, 18878 },	-- Sorcerous Dagger
-- 			},
-- 		},
-- 		{	--MCGeddon
-- 			name = "Baron Geddon",
-- 			npcID = 12056,
-- 			Level = 999,
-- 			DisplayIDs = {{12129}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  18563 },	-- Bindings of the Windseeker
-- 				{ 3,  16797 },	-- Arcanist Mantle
-- 				{ 4,  16807 },	-- Felheart Shoulder Pads
-- 				{ 5,  16836 },	-- Cenarion Spaulders
-- 				{ 6,  16844 },	-- Earthfury Epaulets
-- 				{ 7,  16856 },	-- Lawbringer Spaulders
-- 				{ 16, 18829 },	-- Deep Earth Spaulders
-- 				{ 17, 18823 },	-- Aged Core Leather Gloves
-- 				{ 18, 19143 },	-- Flameguard Gauntlets
-- 				{ 19, 19136 },	-- Mana Igniting Cord
-- 				{ 20, 18861 },	-- Flamewaker Legplates
-- 				{ 21, 19144 },	-- Sabatons of the Flamewalker
-- 				{ 22, 18824 },	-- Magma Tempered Boots
-- 				{ 23, 18821 },	-- Quick Strike Ring
-- 				{ 24, 17110 },	-- Seal of the Archmagus
-- 				{ 25, 18820 },	-- Talisman of Ephemeral Power
-- 				{ 26, 19142 },	-- Fire Runed Grimoire
-- 				{ 27, 18822 },	-- Obsidian Edged Blade
-- 			},
-- 		},
-- 		{	--MCGolemagg
-- 			name = "Golemagg the Incinerator",
-- 			npcID = 11988,
-- 			Level = 999,
-- 			DisplayIDs = {{11986}},
-- 			AtlasMapBossID = 7,
-- 			['loot'] = {
-- 				{ 1,  16815 },	-- Robes of Prophecy
-- 				{ 2,  16798 },	-- Arcanist Robes
-- 				{ 3,  16809 },	-- Felheart Robes
-- 				{ 4,  16820 },	-- Nightslayer Chestpiece
-- 				{ 5,  16833 },	-- Cenarion Vestments
-- 				{ 6,  16845 },	-- Giantstalker's Breastplate
-- 				{ 7,  16841 },	-- Earthfury Vestments
-- 				{ 8,  16853 },	-- Lawbringer Chestguard
-- 				{ 9,  16865 },	-- Breastplate of Might
-- 				{ 11, 17203 },	-- Sulfuron Ingot
-- 				{ 16, 18829 },	-- Deep Earth Spaulders
-- 				{ 17, 18823 },	-- Aged Core Leather Gloves
-- 				{ 18, 19143 },	-- Flameguard Gauntlets
-- 				{ 19, 19136 },	-- Mana Igniting Cord
-- 				{ 20, 18861 },	-- Flamewaker Legplates
-- 				{ 21, 19144 },	-- Sabatons of the Flamewalker
-- 				{ 22, 18824 },	-- Magma Tempered Boots
-- 				{ 23, 18821 },	-- Quick Strike Ring
-- 				{ 24, 18820 },	-- Talisman of Ephemeral Power
-- 				{ 25, 19142 },	-- Fire Runed Grimoire
-- 				{ 26, 17072 },	-- Blastershot Launcher
-- 				{ 27, 17103 },	-- Azuresong Mageblade
-- 				{ 28, 18822 },	-- Obsidian Edged Blade
-- 				{ 29, 18842 },	-- Staff of Dominance
-- 			},
-- 		},
-- 		{ -- MCSulfuron
-- 			name = "Sulfuron Harbinger",
-- 			npcID = 12098,
-- 			Level = 999,
-- 			DisplayIDs = {{13030},{12030}},
-- 			AtlasMapBossID = 8,
-- 			['loot'] = {
-- 				{ 1,  16816 }, -- Mantle of Prophecy
-- 				{ 2,  16823 }, -- Nightslayer Shoulder Pads
-- 				{ 3,  16848 }, -- Giantstalker's Epaulets
-- 				{ 4,  16868 }, -- Pauldrons of Might
-- 				{ 16, 18870 }, -- Helm of the Lifegiver
-- 				{ 17, 19145 }, -- Robe of Volatile Power
-- 				{ 18, 19146 }, -- Wristguards of Stability
-- 				{ 19, 18872 }, -- Manastorm Leggings
-- 				{ 20, 18875 }, -- Salamander Scale Pants
-- 				{ 21, 18861 }, -- Flamewaker Legplates
-- 				{ 22, 18879 }, -- Heavy Dark Iron Ring
-- 				{ 23, 19147 }, -- Ring of Spell Power
-- 				{ 24, 17077 }, -- Crimson Shocker
-- 				{ 25, 18878 }, -- Sorcerous Dagger
-- 				{ 26, 17074 }, -- Shadowstrike
-- 			},
-- 		},
-- 		{ -- MCMajordomo
-- 			name = "Majordomo Executus",
-- 			npcID = 12018,
-- 			Level = 999,
-- 			ObjectID = 179703,
-- 			DisplayIDs = {{12029},{13029},{12002}},
-- 			AtlasMapBossID = 9,
-- 			['loot'] = {
-- 				{ 1,  19139 }, -- Fireguard Shoulders
-- 				{ 2,  18810 }, -- Wild Growth Spaulders
-- 				{ 3,  18811 }, -- Fireproof Cloak
-- 				{ 4,  18808 }, -- Gloves of the Hypnotic Flame
-- 				{ 5,  18809 }, -- Sash of Whispered Secrets
-- 				{ 6,  18812 }, -- Wristguards of True Flight
-- 				{ 7,  18806 }, -- Core Forged Greaves
-- 				{ 8,  19140 }, -- Cauterizing Band
-- 				{ 9,  18805 }, -- Core Hound Tooth
-- 				{ 10, 18803 }, -- Finkle's Lava Dredger
-- 				{ 16, 18703 }, -- Ancient Petrified Leaf
-- 				{ 18, 18646 }, -- The Eye of Divinity
-- 			},
-- 		},
-- 		{ -- MCRagnaros
-- 			name = "Ragnaros",
-- 			npcID = 11502,
-- 			Level = 999,
-- 			DisplayIDs = {{11121}},
-- 			AtlasMapBossID = 10,
-- 			['loot'] = {
-- 				{ 1, 17204 }, -- Eye of Sulfuras
-- 				{ 2, 19017 }, -- Essence of the Firelord
-- 				{ 4,  16922 }, -- Leggings of Transcendence
-- 				{ 5,  16915 }, -- Netherwind Pants
-- 				{ 6,  16930 }, -- Nemesis Leggings
-- 				{ 7,  16909 }, -- Bloodfang Pants
-- 				{ 8,  16901 }, -- Stormrage Legguards
-- 				{ 9,  16938 }, -- Dragonstalker's Legguards
-- 				{ 10,  16946 }, -- Legplates of Ten Storms
-- 				{ 11,  16954 }, -- Judgement Legplates
-- 				{ 12,  16962 }, -- Legplates of Wrath
-- 				{ 14, 17082 }, -- Shard of the Flame
-- 				{ 16, 18817 }, -- Crown of Destruction
-- 				{ 17, 18814 }, -- Choker of the Fire Lord
-- 				{ 18, 17102 }, -- Cloak of the Shrouded Mists
-- 				{ 19, 17107 }, -- Dragon's Blood Cape
-- 				{ 20, 19137 }, -- Onslaught Girdle
-- 				{ 21, 17063 }, -- Band of Accuria
-- 				{ 22, 19138 }, -- Band of Sulfuras
-- 				{ 23, 18815 }, -- Essence of the Pure Flame
-- 				{ 24, 17106 }, -- Malistar's Defender
-- 				{ 25, 18816 }, -- Perdition's Blade
-- 				{ 26, 17104 }, -- Spinal Reaper
-- 				{ 27, 17076 }, -- Bonereaver's Edge
-- 			},
-- 		},
-- 		{ -- MCRANDOMBOSSDROPS
-- 			name = "All bosses",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  18264 }, -- Plans: Elemental Sharpening Stone
-- 				{ 3,  18292 }, -- Schematic: Core Marksman Rifle
-- 				{ 4,  18291 }, -- Schematic: Force Reactive Disk
-- 				{ 5, 18290 }, -- Schematic: Biznicks 247x128 Accurascope
-- 				{ 7, 18259 }, -- Formula: Enchant Weapon - Spell Power
-- 				{ 8, 18260 }, -- Formula: Enchant Weapon - Healing Power
-- 				{ 16, 18252 }, -- Pattern: Core Armor Kit
-- 				{ 18, 18265 }, -- Pattern: Flarecore Wraps
-- 				{ 19, 21371 }, -- Pattern: Core Felcloth Bag
-- 				{ 21, 18257 }, -- Recipe: Major Rejuvenation Potion
-- 			},
-- 		},
-- 		{ -- MCTrashMobs
-- 			name = "Trash",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  16817 }, -- Girdle of Prophecy
-- 				{ 2,  16802 }, -- Arcanist Belt
-- 				{ 3,  16806 }, -- Felheart Belt
-- 				{ 4,  16827 }, -- Nightslayer Belt
-- 				{ 5,  16828 }, -- Cenarion Belt
-- 				{ 6,  16851 }, -- Giantstalker's Belt
-- 				{ 7,  16838 }, -- Earthfury Belt
-- 				{ 8,  16858 }, -- Lawbringer Belt
-- 				{ 9,  16864 }, -- Belt of Might
-- 				{ 12, 17011 }, -- Lava Core
-- 				{ 13, 17010 }, -- Fiery Core
-- 				{ 14, 11382 }, -- Blood of the Mountain
-- 				{ 15, 17012 }, -- Core Leather
-- 				{ 16, 16819 }, -- Vambraces of Prophecy
-- 				{ 17, 16799 }, -- Arcanist Bindings
-- 				{ 18, 16804 }, -- Felheart Bracers
-- 				{ 19, 16825 }, -- Nightslayer Bracelets
-- 				{ 20, 16830 }, -- Cenarion Bracers
-- 				{ 21, 16850 }, -- Giantstalker's Bracers
-- 				{ 22, 16840 }, -- Earthfury Bracers
-- 				{ 23, 16857 }, -- Lawbringer Bracers
-- 				{ 24, 16861 }, -- Bracers of Might
-- 			},
-- 		},
-- 	},
-- }

-- Guildbook.itemdata["Onyxia"] = {
-- 	MapID = 2159,
-- 	InstanceID = 249,
-- 	AtlasMapID = "Onyxia",
-- 	AtlasMapFile = "OnyxiasLair",
-- 	ContentType = RAID40_CONTENT,
-- 	LoadDifficulty = RAID40_DIFF,
-- 	items = {
-- 		{ -- Onyxia
-- 			name = "Onyxia",
-- 			npcID = 10184,
-- 			Level = 999,
-- 			DisplayIDs = {{8570}},
-- 			AtlasMapBossID = 3,
-- 			['loot'] = {
-- 				{ 1,  16921 }, -- Halo of Transcendence
-- 				{ 2,  16914 }, -- Netherwind Crown
-- 				{ 3,  16929 }, -- Nemesis Skullcap
-- 				{ 4,  16908 }, -- Bloodfang Hood
-- 				{ 5,  16900 }, -- Stormrage Cover
-- 				{ 6,  16939 }, -- Dragonstalker's Helm
-- 				{ 7,  16947 }, -- Helmet of Ten Storms
-- 				{ 8,  16955 }, -- Judgement Crown
-- 				{ 9,  16963 }, -- Helm of Wrath
-- 				{ 11, 18423 }, -- Head of Onyxia
-- 				{ 12, 15410 }, -- Scale of Onyxia
-- 				{ 16, 18705 }, -- Mature Black Dragon Sinew
-- 				{ 18, 18205 }, -- Eskhandar's Collar
-- 				{ 19, 17078 }, -- Sapphiron Drape
-- 				{ 20, 18813 }, -- Ring of Binding
-- 				{ 21, 17064 }, -- Shard of the Scale
-- 				{ 22, 17067 }, -- Ancient Cornerstone Grimoire
-- 				{ 23, 17068 }, -- Deathbringer
-- 				{ 24, 17075 }, -- Vis'kag the Bloodletter
-- 				{ 26, 17966 }, -- Onyxia Hide Backpack
-- 				{ 27, 11938 }, -- Sack of Gems
-- 				-- Hidden items
-- 				{ 0, 17962 }, -- Blue Sack of Gems
-- 				{ 0, 17963 }, -- Green Sack of Gems
-- 				{ 0, 17964 }, -- Gray Sack of Gems
-- 				{ 0, 17965 }, -- Yellow Sack of Gems
-- 				{ 0, 17969 }, -- Red Sack of Gems
-- 			},
-- 		},
-- 	},
-- }

-- Guildbook.itemdata["Zul'Gurub"] = {
-- 	MapID = 1977,
-- 	InstanceID = 309,
-- 	AtlasMapID = "Zul'Gurub", -- ??
-- 	AtlasMapFile = "ZulGurub",
-- 	ContentType = RAID20_CONTENT,
-- 	LoadDifficulty = RAID20_DIFF,
-- 	ContentPhase = 4,
-- 	items = {
-- 		{ -- ZGJeklik
-- 			name = "High Priestess Jeklik",
-- 			npcID = 14517,
-- 			Level = 999,
-- 			DisplayIDs = {{15219}},
-- 			AtlasMapBossID = 1,
-- 			['loot'] = {
-- 				{ 1,  19721 }, -- Primal Hakkari Shawl
-- 				{ 2,  19724 }, -- Primal Hakkari Aegis
-- 				{ 3,  19723 }, -- Primal Hakkari Kossack
-- 				{ 4,  19722 }, -- Primal Hakkari Tabard
-- 				{ 5,  19717 }, -- Primal Hakkari Armsplint
-- 				{ 6,  19716 }, -- Primal Hakkari Bindings
-- 				{ 7,  19718 }, -- Primal Hakkari Stanchion
-- 				{ 8,  19719 }, -- Primal Hakkari Girdle
-- 				{ 9,  19720 }, -- Primal Hakkari Sash
-- 				{ 16, 19918 }, -- Jeklik's Crusher
-- 				{ 18, 19923 }, -- Jeklik's Opaline Talisman
-- 				{ 19, 19928 }, -- Animist's Spaulders
-- 				{ 20, 20262 }, -- Seafury Boots
-- 				{ 21, 20265 }, -- Peacekeeper Boots
-- 				{ 22, 19920 }, -- Primalist's Band
-- 				{ 23, 19915 }, -- Zulian Defender
-- 			},
-- 		},
-- 		{ -- ZGVenoxis
-- 			name = "High Priest Venoxis",
-- 			npcID = 14507,
-- 			Level = 999,
-- 			DisplayIDs = {{15217}},
-- 			AtlasMapBossID = 2,
-- 			['loot'] = {
-- 				{ 1,  19721 }, -- Primal Hakkari Shawl
-- 				{ 2,  19724 }, -- Primal Hakkari Aegis
-- 				{ 3,  19723 }, -- Primal Hakkari Kossack
-- 				{ 4,  19722 }, -- Primal Hakkari Tabard
-- 				{ 5,  19717 }, -- Primal Hakkari Armsplint
-- 				{ 6,  19716 }, -- Primal Hakkari Bindings
-- 				{ 7,  19718 }, -- Primal Hakkari Stanchion
-- 				{ 8,  19719 }, -- Primal Hakkari Girdle
-- 				{ 9,  19720 }, -- Primal Hakkari Sash
-- 				{ 16, 19904 }, -- Runed Bloodstained Hauberk
-- 				{ 17, 19903 }, -- Fang of Venoxis
-- 				{ 19, 19907 }, -- Zulian Tigerhide Cloak
-- 				{ 20, 19906 }, -- Blooddrenched Footpads
-- 				{ 21, 19905 }, -- Zanzil's Band
-- 				{ 22, 19900 }, -- Zulian Stone Axe
-- 			},
-- 		},
-- 		{ -- ZGMarli
-- 			name = "High Priestess Mar'li",
-- 			npcID = 14510,
-- 			Level = 999,
-- 			DisplayIDs = {{15220}},
-- 			AtlasMapBossID = 4,
-- 			['loot'] = {
-- 				{ 1,  19721 }, -- Primal Hakkari Shawl
-- 				{ 2,  19724 }, -- Primal Hakkari Aegis
-- 				{ 3,  19723 }, -- Primal Hakkari Kossack
-- 				{ 4,  19722 }, -- Primal Hakkari Tabard
-- 				{ 5,  19717 }, -- Primal Hakkari Armsplint
-- 				{ 6,  19716 }, -- Primal Hakkari Bindings
-- 				{ 7,  19718 }, -- Primal Hakkari Stanchion
-- 				{ 8,  19719 }, -- Primal Hakkari Girdle
-- 				{ 9,  19720 }, -- Primal Hakkari Sash
-- 				{ 16, 20032 }, -- Flowing Ritual Robes
-- 				{ 17, 19927 }, -- Mar'li's Touch
-- 				{ 19, 19871 }, -- Talisman of Protection
-- 				{ 20, 19919 }, -- Bloodstained Greaves
-- 				{ 21, 19925 }, -- Band of Jin
-- 				{ 22, 19930 }, -- Mar'li's Eye
-- 			},
-- 		},
-- 		{ -- ZGMandokir
-- 			name = "Bloodlord Mandokir",
-- 			npcID = 11382,
-- 			Level = 999,
-- 			DisplayIDs = {{11288}},
-- 			AtlasMapBossID = 5,
-- 			['loot'] = {
-- 				{ 1,  19721 }, -- Primal Hakkari Shawl
-- 				{ 2,  19724 }, -- Primal Hakkari Aegis
-- 				{ 3,  19723 }, -- Primal Hakkari Kossack
-- 				{ 4,  19722 }, -- Primal Hakkari Tabard
-- 				{ 5,  19717 }, -- Primal Hakkari Armsplint
-- 				{ 6,  19716 }, -- Primal Hakkari Bindings
-- 				{ 7,  19718 }, -- Primal Hakkari Stanchion
-- 				{ 8,  19719 }, -- Primal Hakkari Girdle
-- 				{ 9,  19720 }, -- Primal Hakkari Sash
-- 				{ 11, 22637 }, -- Primal Hakkari Idol
-- 				{ 16, 19872 }, -- Swift Razzashi Raptor
-- 				{ 17, 20038 }, -- Mandokir's Sting
-- 				{ 18, 19867 }, -- Bloodlord's Defender
-- 				{ 19, 19866 }, -- Warblade of the Hakkari
-- 				{ 20, 19874 }, -- Halberd of Smiting
-- 				{ 22, 19878 }, -- Bloodsoaked Pauldrons
-- 				{ 23, 19870 }, -- Hakkari Loa Cloak
-- 				{ 24, 19869 }, -- Blooddrenched Grips
-- 				{ 25, 19895 }, -- Bloodtinged Kilt
-- 				{ 26, 19877 }, -- Animist's Leggings
-- 				{ 27, 19873 }, -- Overlord's Crimson Band
-- 				{ 28, 19863 }, -- Primalist's Seal
-- 				{ 29, 19893 }, -- Zanzil's Seal
-- 			},
-- 		},
-- 		{ -- ZGGrilek
-- 			name = "Gri'lek",
-- 			npcID = 15082,
-- 			Level = 999,
-- 			DisplayIDs = {{8390}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  19961 }, -- Gri'lek's Grinder
-- 				{ 2,  19962 }, -- Gri'lek's Carver
-- 				{ 4,  19939 }, -- Gri'lek's Blood
-- 			},
-- 		},
-- 		{ -- ZGHazzarah
-- 			name = "Hazza'rah",
-- 			npcID = 15083,
-- 			Level = 999,
-- 			DisplayIDs = {{15267}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  19967 }, -- Thoughtblighter
-- 				{ 2,  19968 }, -- Fiery Retributer
-- 				{ 4,  19942 }, -- Hazza'rah's Dream Thread
-- 			},
-- 		},
-- 		{ -- ZGRenataki
-- 			name = "Renataki",
-- 			npcID = 15084,
-- 			Level = 999,
-- 			DisplayIDs = {{15268}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  19964 }, -- Renataki's Soul Conduit
-- 				{ 2,  19963 }, -- Pitchfork of Madness
-- 				{ 4,  19940 }, -- Renataki's Tooth
-- 			},
-- 		},
-- 		{ -- ZGWushoolay
-- 			name = "Wushoolay",
-- 			npcID = 15085,
-- 			Level = 999,
-- 			DisplayIDs = {{15269}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  19993 }, -- Hoodoo Hunting Bow
-- 				{ 2,  19965 }, -- Wushoolay's Poker
-- 				{ 4,  19941 }, -- Wushoolay's Mane
-- 			},
-- 		},
-- 		{ -- ZGGahzranka
-- 			name = "Gahz'ranka",
-- 			npcID = 15114,
-- 			Level = 999,
-- 			DisplayIDs = {{15288}},
-- 			AtlasMapBossID = 7,
-- 			['loot'] = {
-- 				{ 1,  19945 }, -- Foror's Eyepatch
-- 				{ 2,  19944 }, -- Nat Pagle's Fish Terminator
-- 				{ 4,  19947 }, -- Nat Pagle's Broken Reel
-- 				{ 5,  19946 }, -- Tigule's Harpoon
-- 				{ 7,  22739 }, -- Tome of Polymorph: Turtle
-- 			},
-- 		},
-- 		{ -- ZGThekal
-- 			name = "High Priest Thekal",
-- 			npcID = 14509,
-- 			Level = 999,
-- 			DisplayIDs = {{15216}},
-- 			AtlasMapBossID = 8,
-- 			['loot'] = {
-- 				{ 1,  19721 }, -- Primal Hakkari Shawl
-- 				{ 2,  19724 }, -- Primal Hakkari Aegis
-- 				{ 3,  19723 }, -- Primal Hakkari Kossack
-- 				{ 4,  19722 }, -- Primal Hakkari Tabard
-- 				{ 5,  19717 }, -- Primal Hakkari Armsplint
-- 				{ 6,  19716 }, -- Primal Hakkari Bindings
-- 				{ 7,  19718 }, -- Primal Hakkari Stanchion
-- 				{ 8,  19719 }, -- Primal Hakkari Girdle
-- 				{ 9,  19720 }, -- Primal Hakkari Sash
-- 				{ 16, 19902 }, -- Swift Zulian Tiger
-- 				{ 17, 19897 }, -- Betrayer's Boots
-- 				{ 18, 19896 }, -- Thekal's Grasp
-- 				{ 20, 19899 }, -- Ritualistic Legguards
-- 				{ 21, 20260 }, -- Seafury Leggings
-- 				{ 22, 20266 }, -- Peacekeeper Leggings
-- 				{ 23, 19898 }, -- Seal of Jin
-- 				{ 24, 19901 }, -- Zulian Slicer
-- 			},
-- 		},
-- 		{ -- ZGArlokk
-- 			name = "High Priestess Arlokk",
-- 			npcID = 14515,
-- 			Level = 999,
-- 			DisplayIDs = {{15218}},
-- 			AtlasMapBossID = 9,
-- 			['loot'] = {
-- 				{ 1,  19721 }, -- Primal Hakkari Shawl
-- 				{ 2,  19724 }, -- Primal Hakkari Aegis
-- 				{ 3,  19723 }, -- Primal Hakkari Kossack
-- 				{ 4,  19722 }, -- Primal Hakkari Tabard
-- 				{ 5,  19717 }, -- Primal Hakkari Armsplint
-- 				{ 6,  19716 }, -- Primal Hakkari Bindings
-- 				{ 7,  19718 }, -- Primal Hakkari Stanchion
-- 				{ 8,  19719 }, -- Primal Hakkari Girdle
-- 				{ 9,  19720 }, -- Primal Hakkari Sash
-- 				{ 16, 19910 }, -- Arlokk's Grasp
-- 				{ 17, 19909 }, -- Will of Arlokk
-- 				{ 19, 19913 }, -- Bloodsoaked Greaves
-- 				{ 20, 19912 }, -- Overlord's Onyx Band
-- 				{ 21, 19922 }, -- Arlokk's Hoodoo Stick
-- 				{ 23, 19914 }, -- Panther Hide Sack
-- 			},
-- 		},
-- 		{ -- ZGJindo
-- 			name = "Jin'do the Hexxer",
-- 			npcID = 11380,
-- 			Level = 999,
-- 			DisplayIDs = {{11311}},
-- 			AtlasMapBossID = 10,
-- 			['loot'] = {
-- 				{ 1,  19721 }, -- Primal Hakkari Shawl
-- 				{ 2,  19724 }, -- Primal Hakkari Aegis
-- 				{ 3,  19723 }, -- Primal Hakkari Kossack
-- 				{ 4,  19722 }, -- Primal Hakkari Tabard
-- 				{ 5,  19717 }, -- Primal Hakkari Armsplint
-- 				{ 6,  19716 }, -- Primal Hakkari Bindings
-- 				{ 7,  19718 }, -- Primal Hakkari Stanchion
-- 				{ 8,  19719 }, -- Primal Hakkari Girdle
-- 				{ 9,  19720 }, -- Primal Hakkari Sash
-- 				{ 11, 22637 }, -- Primal Hakkari Idol
-- 				{ 16, 19885 }, -- Jin'do's Evil Eye
-- 				{ 17, 19891 }, -- Jin'do's Bag of Whammies
-- 				{ 18, 19890 }, -- Jin'do's Hexxer
-- 				{ 19, 19884 }, -- Jin'do's Judgement
-- 				{ 21, 19886 }, -- The Hexxer's Cover
-- 				{ 22, 19875 }, -- Bloodstained Coif
-- 				{ 23, 19888 }, -- Overlord's Embrace
-- 				{ 24, 19929 }, -- Bloodtinged Gloves
-- 				{ 25, 19894 }, -- Bloodsoaked Gauntlets
-- 				{ 26, 19889 }, -- Blooddrenched Leggings
-- 				{ 27, 19887 }, -- Bloodstained Legplates
-- 				{ 28, 19892 }, -- Animist's Boots
-- 			},
-- 		},
-- 		{ -- ZGHakkar
-- 			name = "Hakkar",
-- 			npcID = 14834,
-- 			Level = 999,
-- 			DisplayIDs = {{15295}},
-- 			AtlasMapBossID = 11,
-- 			['loot'] = {
-- 				{ 1,  19857 }, -- Cloak of Consumption
-- 				--{ 2,  20257, [ATLASLOOT_IT_ALLIANCE] = 20264 }, -- Seafury Gauntlets
-- 				--{ 3,  20264, [ATLASLOOT_IT_HORDE] = 20257 }, -- Peacekeeper Gauntlets
-- 				{ 3,  19855 }, -- Bloodsoaked Legplates
-- 				{ 4,  19876 }, -- Soul Corrupter's Necklace
-- 				{ 5,  19856 }, -- The Eye of Hakkar
-- 				{ 7, 19802 }, -- Heart of Hakkar
-- 				{ 16,  19861 }, -- Touch of Chaos
-- 				{ 17,  19853 }, -- Gurubashi Dwarf Destroyer
-- 				{ 18, 19862 }, -- Aegis of the Blood God
-- 				{ 19, 19864 }, -- Bloodcaller
-- 				{ 20, 19865 }, -- Warblade of the Hakkari
-- 				{ 21, 19866 }, -- Warblade of the Hakkari
-- 				{ 22, 19852 }, -- Ancient Hakkari Manslayer
-- 				{ 23, 19859 }, -- Fang of the Faceless
-- 				{ 24, 19854 }, -- Zin'rokh, Destroyer of Worlds
-- 			},
-- 		},
-- 		{ -- ZGShared
-- 			name = "High Priest Shared loot",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  22721 }, -- Band of Servitude
-- 				{ 2,  22722 }, -- Seal of the Gurubashi Berserker
-- 				{ 4,  22720 }, -- Zulian Headdress
-- 				{ 5,  22718 }, -- Blooddrenched Mask
-- 				{ 6,  22711 }, -- Cloak of the Hakkari Worshipers
-- 				{ 7,  22712 }, -- Might of the Tribe
-- 				{ 8,  22715 }, -- Gloves of the Tormented
-- 				{ 9,  22714 }, -- Sacrificial Gauntlets
-- 				{ 10, 22716 }, -- Belt of Untapped Power
-- 				{ 11, 22713 }, -- Zulian Scepter of Rites
-- 			},
-- 		},
-- 		{ -- ZGTrash1
-- 			name = "Trash",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  20263 }, -- Gurubashi Helm
-- 				{ 2,  20259 }, -- Shadow Panther Hide Gloves
-- 				{ 3,  20261 }, -- Shadow Panther Hide Belt
-- 				{ 4,  19921 }, -- Zulian Hacker
-- 				{ 5,  19908 }, -- Sceptre of Smiting
-- 				{ 16,  20258 }, -- Zulian Ceremonial Staff
-- 				{ 17, 19726 }, -- Bloodvine
-- 				{ 18, 19774 }, -- Souldarite
-- 				{ 19, 19767 }, -- Primal Bat Leather
-- 				{ 20, 19768 }, -- Primal Tiger Leather
-- 				{ 7, 19706 }, -- Bloodscalp Coin
-- 				{ 8, 19701 }, -- Gurubashi Coin
-- 				{ 9, 19700 }, -- Hakkari Coin
-- 				{ 10, 19699 }, -- Razzashi Coin
-- 				{ 11, 19704 }, -- Sandfury Coin
-- 				{ 12, 19705 }, -- Skullsplitter Coin
-- 				{ 13, 19702 }, -- Vilebranch Coin
-- 				{ 14, 19703 }, -- Witherbark Coin
-- 				{ 15, 19698 }, -- Zulian Coin
-- 				{ 22, 19708 }, -- Blue Hakkari Bijou
-- 				{ 23, 19713 }, -- Bronze Hakkari Bijou
-- 				{ 24, 19715 }, -- Gold Hakkari Bijou
-- 				{ 25, 19711 }, -- Green Hakkari Bijou
-- 				{ 26, 19710 }, -- Orange Hakkari Bijou
-- 				{ 27, 19712 }, -- Purple Hakkari Bijou
-- 				{ 28, 19707 }, -- Red Hakkari Bijou
-- 				{ 29, 19714 }, -- Silver Hakkari Bijou
-- 				{ 30, 19709 }, -- Yellow Hakkari Bijou
-- 			},
-- 		},
-- 		{ -- ZGEnchants
-- 			name = "Enchants",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  19789 }, -- Prophetic Aura
-- 				{ 2,  19787 }, -- Presence of Sight
-- 				{ 3,  19788 }, -- Hoodoo Hex
-- 				{ 4,  19784 }, -- Death's Embrace
-- 				{ 5,  19790 }, -- Animist's Caress
-- 				{ 6,  19785 }, -- Falcon's Call
-- 				{ 7,  19786 }, -- Vodouisant's Vigilant Embrace
-- 				{ 8,  19783 }, -- Syncretist's Sigil
-- 				{ 9,  19782 }, -- Presence of Might
-- 				{ 16, 20077 }, -- Zandalar Signet of Might
-- 				{ 17, 20076 }, -- Zandalar Signet of Mojo
-- 				{ 18, 20078 }, -- Zandalar Signet of Serenity
-- 				{ 20, 22635 }, -- Savage Guard
-- 			},
-- 		},
-- 		{ -- ZGMuddyChurningWaters
-- 			name = "Muddy Churning Waters",
-- 			ExtraList = true,
-- 			AtlasMapBossID = "1'",
-- 			['loot'] = {
-- 				{ 1,  19975 }, -- Zulian Mudskunk
-- 			},
-- 		},
-- 		{ -- ZGJinxedHoodooPile
-- 			name = "Jinxed Hoodoo Pile",
-- 			ExtraList = true,
-- 			AtlasMapBossID = "2'",
-- 			['loot'] = {
-- 				{ 1,  19727 }, -- Blood Scythe
-- 				{ 3,  19820 }, -- Punctured Voodoo Doll
-- 				{ 4,  19818 }, -- Punctured Voodoo Doll
-- 				{ 5,  19819 }, -- Punctured Voodoo Doll
-- 				{ 6,  19814 }, -- Punctured Voodoo Doll
-- 				{ 7,  19821 }, -- Punctured Voodoo Doll
-- 				{ 8,  19816 }, -- Punctured Voodoo Doll
-- 				{ 9,  19817 }, -- Punctured Voodoo Doll
-- 				{ 10, 19815 }, -- Punctured Voodoo Doll
-- 				{ 11, 19813 }, -- Punctured Voodoo Doll
-- 			},
-- 		},
-- 	},
-- }

-- Guildbook.itemdata["BlackwingLair"] = {
-- 	MapID = 2677,
-- 	InstanceID = 469,
-- 	AtlasMapID = "BlackwingLair",
-- 	AtlasMapFile = "BlackwingLair",
-- 	ContentType = RAID40_CONTENT,
-- 	LoadDifficulty = RAID40_DIFF,
-- 	ContentPhase = 3,
-- 	items = {
-- 		{ -- BWLRazorgore
-- 			name = "Razorgore the Untamed",
-- 			npcID = 12435,
-- 			Level = 999,
-- 			DisplayIDs = {{10115}},
-- 			AtlasMapBossID = 1,
-- 			['loot'] = {
-- 				{ 1,  16926 }, -- Bindings of Transcendence
-- 				{ 2,  16918 }, -- Netherwind Bindings
-- 				{ 3,  16934 }, -- Nemesis Bracers
-- 				{ 4,  16911 }, -- Bloodfang Bracers
-- 				{ 5,  16904 }, -- Stormrage Bracers
-- 				{ 6,  16935 }, -- Dragonstalker's Bracers
-- 				{ 7,  16943 }, -- Bracers of Ten Storms
-- 				{ 8,  16951 }, -- Judgement Bindings
-- 				{ 9,  16959 }, -- Bracelets of Wrath
-- 				{ 16, 19336 }, -- Arcane Infused Gem
-- 				{ 17, 19337 }, -- The Black Book
-- 				{ 19, 19370 }, -- Mantle of the Blackwing Cabal
-- 				{ 20, 19369 }, -- Gloves of Rapid Evolution
-- 				{ 21, 19335 }, -- Spineshatter
-- 				{ 22, 19334 }, -- The Untamed Blade
-- 			},
-- 		},
-- 		{ -- BWLVaelastrasz
-- 			name = "Vaelastrasz the Corrupt",
-- 			npcID = 13020,
-- 			Level = 999,
-- 			DisplayIDs = {{13992}},
-- 			AtlasMapBossID = 2,
-- 			['loot'] = {
-- 				{ 1,  16925 }, -- Belt of Transcendence
-- 				{ 2,  16818 }, -- Netherwind Belt
-- 				{ 3,  16933 }, -- Nemesis Belt
-- 				{ 4,  16910 }, -- Bloodfang Belt
-- 				{ 5,  16903 }, -- Stormrage Belt
-- 				{ 6,  16936 }, -- Dragonstalker's Belt
-- 				{ 7,  16944 }, -- Belt of Ten Storms
-- 				{ 8,  16952 }, -- Judgement Belt
-- 				{ 9,  16960 }, -- Waistband of Wrath
-- 				{ 16, 19339 }, -- Mind Quickening Gem
-- 				{ 17, 19340 }, -- Rune of Metamorphosis
-- 				{ 19, 19372 }, -- Helm of Endless Rage
-- 				{ 20, 19371 }, -- Pendant of the Fallen Dragon
-- 				{ 21, 19348 }, -- Red Dragonscale Protector
-- 				{ 22, 19346 }, -- Dragonfang Blade
-- 			},
-- 		},
-- 		{ -- BWLLashlayer
-- 			name = "Broodlord Lashlayer",
-- 			npcID = 12017,
-- 			Level = 999,
-- 			DisplayIDs = {{14308}},
-- 			AtlasMapBossID = 3,
-- 			['loot'] = {
-- 				{ 1,  16919 }, -- Boots of Transcendence
-- 				{ 2,  16912 }, -- Netherwind Boots
-- 				{ 3,  16927 }, -- Nemesis Boots
-- 				{ 4,  16906 }, -- Bloodfang Boots
-- 				{ 5,  16898 }, -- Stormrage Boots
-- 				{ 6,  16941 }, -- Dragonstalker's Greaves
-- 				{ 7,  16949 }, -- Greaves of Ten Storms
-- 				{ 8,  16957 }, -- Judgement Sabatons
-- 				{ 9,  16965 }, -- Sabatons of Wrath
-- 				{ 16, 19341 }, -- Lifegiving Gem
-- 				{ 17, 19342 }, -- Venomous Totem
-- 				{ 19, 19373 }, -- Black Brood Pauldrons
-- 				{ 20, 19374 }, -- Bracers of Arcane Accuracy
-- 				{ 21, 19350 }, -- Heartstriker
-- 				{ 22, 19351 }, -- Maladath, Runed Blade of the Black Flight
-- 				{ 24, 20383 }, -- Head of the Broodlord Lashlayer
-- 			},
-- 		},
-- 		{ -- BWLFiremaw
-- 			name = "Firemaw",
-- 			npcID = 11983,
-- 			Level = 999,
-- 			DisplayIDs = {{6377}},
-- 			AtlasMapBossID = 4,
-- 			['loot'] = {
-- 				{ 1,  16920 }, -- Handguards of Transcendence
-- 				{ 2,  16913 }, -- Netherwind Gloves
-- 				{ 3,  16928 }, -- Nemesis Gloves
-- 				{ 4,  16907 }, -- Bloodfang Gloves
-- 				{ 5,  16899 }, -- Stormrage Handguards
-- 				{ 6,  16940 }, -- Dragonstalker's Gauntlets
-- 				{ 7,  16948 }, -- Gauntlets of Ten Storms
-- 				{ 8,  16956 }, -- Judgement Gauntlets
-- 				{ 9,  16964 }, -- Gauntlets of Wrath
-- 				{ 13, 19344 }, -- Natural Alignment Crystal
-- 				{ 14, 19343 }, -- Scrolls of Blinding Light
-- 				{ 16, 19394 }, -- Drake Talon Pauldrons
-- 				{ 17, 19398 }, -- Cloak of Firemaw
-- 				{ 18, 19399 }, -- Black Ash Robe
-- 				{ 19, 19400 }, -- Firemaw's Clutch
-- 				{ 20, 19396 }, -- Taut Dragonhide Belt
-- 				{ 21, 19401 }, -- Primalist's Linked Legguards
-- 				{ 22, 19402 }, -- Legguards of the Fallen Crusader
-- 				{ 24, 19365 }, -- Claw of the Black Drake
-- 				{ 25, 19353 }, -- Drake Talon Cleaver
-- 				{ 26, 19355 }, -- Shadow Wing Focus Staff
-- 				{ 28, 19397 }, -- Ring of Blackrock
-- 				{ 29, 19395 }, -- Rejuvenating Gem
-- 			},
-- 		},
-- 		{ -- BWLEbonroc
-- 			name = "Ebonroc",
-- 			npcID = 14601,
-- 			Level = 999,
-- 			DisplayIDs = {{6377}},
-- 			AtlasMapBossID = 5,
-- 			['loot'] = {
-- 				{ 1,  16920 }, -- Handguards of Transcendence
-- 				{ 2,  16913 }, -- Netherwind Gloves
-- 				{ 3,  16928 }, -- Nemesis Gloves
-- 				{ 4,  16907 }, -- Bloodfang Gloves
-- 				{ 5,  16899 }, -- Stormrage Handguards
-- 				{ 6,  16940 }, -- Dragonstalker's Gauntlets
-- 				{ 7,  16948 }, -- Gauntlets of Ten Storms
-- 				{ 8,  16956 }, -- Judgement Gauntlets
-- 				{ 9,  16964 }, -- Gauntlets of Wrath
-- 				{ 11, 19345 }, -- Aegis of Preservation
-- 				{ 12, 19406 }, -- Drake Fang Talisman
-- 				{ 13, 19395 }, -- Rejuvenating Gem
-- 				{ 16, 19394 }, -- Drake Talon Pauldrons
-- 				{ 17, 19407 }, -- Ebony Flame Gloves
-- 				{ 18, 19396 }, -- Taut Dragonhide Belt
-- 				{ 19, 19405 }, -- Malfurion's Blessed Bulwark
-- 				{ 21, 19368 }, -- Dragonbreath Hand Cannon
-- 				{ 22, 19353 }, -- Drake Talon Cleaver
-- 				{ 23, 19355 }, -- Shadow Wing Focus Staff
-- 				{ 26, 19403 }, -- Band of Forced Concentration
-- 				{ 27, 19397 }, -- Ring of Blackrock

-- 			},
-- 		},
-- 		{ -- BWLFlamegor
-- 			name = "Flamegor",
-- 			npcID = 11981,
-- 			Level = 999,
-- 			DisplayIDs = {{6377}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  16920 }, -- Handguards of Transcendence
-- 				{ 2,  16913 }, -- Netherwind Gloves
-- 				{ 3,  16928 }, -- Nemesis Gloves
-- 				{ 4,  16907 }, -- Bloodfang Gloves
-- 				{ 5,  16899 }, -- Stormrage Handguards
-- 				{ 6,  16940 }, -- Dragonstalker's Gauntlets
-- 				{ 7,  16948 }, -- Gauntlets of Ten Storms
-- 				{ 8,  16956 }, -- Judgement Gauntlets
-- 				{ 9,  16964 }, -- Gauntlets of Wrath
-- 				{ 11, 19395 }, -- Rejuvenating Gem
-- 				{ 12, 19431 }, -- Styleen's Impeding Scarab
-- 				{ 16, 19394 }, -- Drake Talon Pauldrons
-- 				{ 17, 19430 }, -- Shroud of Pure Thought
-- 				{ 18, 19396 }, -- Taut Dragonhide Belt
-- 				{ 19, 19433 }, -- Emberweave Leggings
-- 				{ 21, 19367 }, -- Dragon's Touch
-- 				{ 22, 19353 }, -- Drake Talon Cleaver
-- 				{ 23, 19357 }, -- Herald of Woe
-- 				{ 24, 19355 }, -- Shadow Wing Focus Staff
-- 				{ 26, 19432 }, -- Circle of Applied Force
-- 				{ 27, 19397 }, -- Ring of Blackrock
-- 			},
-- 		},
-- 		{ -- BWLChromaggus
-- 			name = "Chromaggus",
-- 			npcID = 14020,
-- 			Level = 999,
-- 			DisplayIDs = {{14367}},
-- 			AtlasMapBossID = 7,
-- 			['loot'] = {
-- 				{ 1,  16924 }, -- Pauldrons of Transcendence
-- 				{ 2,  16917 }, -- Netherwind Mantle
-- 				{ 3,  16932 }, -- Nemesis Spaulders
-- 				{ 4,  16832 }, -- Bloodfang Spaulders
-- 				{ 5,  16902 }, -- Stormrage Pauldrons
-- 				{ 6,  16937 }, -- Dragonstalker's Spaulders
-- 				{ 7,  16945 }, -- Epaulets of Ten Storms
-- 				{ 8,  16953 }, -- Judgement Spaulders
-- 				{ 9,  16961 }, -- Pauldrons of Wrath
-- 				{ 16, 19389 }, -- Taut Dragonhide Shoulderpads
-- 				{ 17, 19386 }, -- Elementium Threaded Cloak
-- 				{ 18, 19390 }, -- Taut Dragonhide Gloves
-- 				{ 19, 19388 }, -- Angelista's Grasp
-- 				{ 20, 19393 }, -- Primalist's Linked Waistguard
-- 				{ 21, 19392 }, -- Girdle of the Fallen Crusader
-- 				{ 22, 19385 }, -- Empowered Leggings
-- 				{ 23, 19391 }, -- Shimmering Geta
-- 				{ 24, 19387 }, -- Chromatic Boots
-- 				{ 26, 19361 }, -- Ashjre'thul, Crossbow of Smiting
-- 				{ 27, 19349 }, -- Elementium Reinforced Bulwark
-- 				{ 28, 19347 }, -- Claw of Chromaggus
-- 				{ 29, 19352 }, -- Chromatically Tempered Sword
-- 			},
-- 		},
-- 		{ -- BWLNefarian
-- 			name = "Nefarian",
-- 			npcID = 11583,
-- 			Level = 999,
-- 			DisplayIDs = {{11380}},
-- 			AtlasMapBossID = 8,
-- 			['loot'] = {
-- 				{ 1,  16923 }, -- Robes of Transcendence
-- 				{ 2,  16916 }, -- Netherwind Robes
-- 				{ 3,  16931 }, -- Nemesis Robes
-- 				{ 4,  16905 }, -- Bloodfang Chestpiece
-- 				{ 5,  16897 }, -- Stormrage Chestguard
-- 				{ 6,  16942 }, -- Dragonstalker's Breastplate
-- 				{ 7,  16950 }, -- Breastplate of Ten Storms
-- 				{ 8,  16958 }, -- Judgement Breastplate
-- 				{ 9,  16966 }, -- Breastplate of Wrath
-- 				{ 11, 19003 }, -- Head of Nefarian
-- 				{ 16, 19360 }, -- Lok'amir il Romathis
-- 				{ 17, 19363 }, -- Crul'shorukh, Edge of Chaos
-- 				{ 18, 19364 }, -- Ashkandi, Greatsword of the Brotherhood
-- 				{ 19, 19356 }, -- Staff of the Shadow Flame
-- 				{ 21, 19375 }, -- Mish'undare, Circlet of the Mind Flayer
-- 				{ 22, 19377 }, -- Prestor's Talisman of Connivery
-- 				{ 23, 19378 }, -- Cloak of the Brood Lord
-- 				{ 24, 19380 }, -- Therazane's Link
-- 				{ 25, 19381 }, -- Boots of the Shadow Flame
-- 				{ 26, 19376 }, -- Archimtiros' Ring of Reckoning
-- 				{ 27, 19382 }, -- Pure Elementium Band
-- 				{ 28, 19379 }, -- Neltharion's Tear
-- 				{ 30, 11938 }, -- Sack of Gems
-- 				-- Hidden items
-- 				{ 0, 17962 }, -- Blue Sack of Gems
-- 				{ 0, 17963 }, -- Green Sack of Gems
-- 				{ 0, 17964 }, -- Gray Sack of Gems
-- 				{ 0, 17965 }, -- Yellow Sack of Gems
-- 				{ 0, 17969 }, -- Red Sack of Gems
-- 			},
-- 		},
-- 		{ -- BWLTrashMobs
-- 			name = "Trash",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  19436 }, -- Cloak of Draconic Might
-- 				{ 2,  19439 }, -- Interlaced Shadow Jerkin
-- 				{ 3,  19437 }, -- Boots of Pure Thought
-- 				{ 4,  19438 }, -- Ringo's Blizzard Boots
-- 				{ 5,  19434 }, -- Band of Dark Dominion
-- 				{ 6,  19435 }, -- Essence Gatherer
-- 				{ 7,  19362 }, -- Doom's Edge
-- 				{ 8,  19354 }, -- Draconic Avenger
-- 				{ 9,  19358 }, -- Draconic Maul
-- 				{ 11, 18562 }, -- Elementium Ore
-- 			},
-- 		},
-- 		T2_SET,
-- 	},
-- }

-- Guildbook.itemdata["TheRuinsofAhnQiraj"] = { -- AQ20
-- 	MapID = 3429,
-- 	InstanceID = 509,
-- 	AtlasMapID = "TheRuinsofAhnQiraj",
-- 	AtlasMapFile = "TheRuinsofAhnQiraj",
-- 	ContentType = RAID20_CONTENT,
-- 	LoadDifficulty = RAID20_DIFF,
-- 	ContentPhase = 5,
-- 	items = {
-- 		{ -- AQ20Kurinnaxx
-- 			name = "Kurinnaxx",
-- 			npcID = 15348,
-- 			Level = 999,
-- 			DisplayIDs = {{15742}},
-- 			AtlasMapBossID = 1,
-- 			['loot'] = {
-- 				{ 1,  21499 }, -- Vestments of the Shifting Sands
-- 				{ 2,  21498 }, -- Qiraji Sacrificial Dagger
-- 				{ 4,  21502 }, -- Sand Reaver Wristguards
-- 				{ 5,  21501 }, -- Toughened Silithid Hide Gloves
-- 				{ 6,  21500 }, -- Belt of the Inquisition
-- 				{ 7,  21503 }, -- Belt of the Sand Reaver
-- 				{ 19, 20885 }, -- Qiraji Martial Drape
-- 				{ 20, 20889 }, -- Qiraji Regal Drape
-- 				{ 21, 20888 }, -- Qiraji Ceremonial Ring
-- 				{ 22, 20884 }, -- Qiraji Magisterial Ring
-- 			},
-- 		},
-- 		{ -- AQ20Rajaxx
-- 			name = "General Rajaxx",
-- 			npcID = 15341,
-- 			Level = 999,
-- 			DisplayIDs = {{15376}},
-- 			AtlasMapBossID = 2,
-- 			['loot'] = {
-- 				{ 1,  21493 }, -- Boots of the Vanguard
-- 				{ 2,  21492 }, -- Manslayer of the Qiraji
-- 				{ 4,  21496 }, -- Bracers of Qiraji Command
-- 				{ 5,  21494 }, -- Southwind's Grasp
-- 				{ 6,  21495 }, -- Legplates of the Qiraji Command
-- 				{ 7,  21497 }, -- Boots of the Qiraji General
-- 				--{ 9,  "INV_Box_01", nil, AL["Trash"] },
-- 				{ 10,  21810 }, -- Treads of the Wandering Nomad
-- 				{ 11,  21809 }, -- Fury of the Forgotten Swarm
-- 				{ 12,  21806 }, -- Gavel of Qiraji Authority
-- 				{ 19, 20885 }, -- Qiraji Martial Drape
-- 				{ 20, 20889 }, -- Qiraji Regal Drape
-- 				{ 21, 20888 }, -- Qiraji Ceremonial Ring
-- 				{ 22, 20884 }, -- Qiraji Magisterial Ring
-- 			},
-- 		},
-- 		{ -- AQ20Moam
-- 			name = "Moam",
-- 			npcID = 15340,
-- 			Level = 999,
-- 			DisplayIDs = {{15392}},
-- 			AtlasMapBossID = 3,
-- 			['loot'] = {
-- 				{ 1,  21472 }, -- Dustwind Turban
-- 				{ 2,  21467 }, -- Thick Silithid Chestguard
-- 				{ 3,  21479 }, -- Gauntlets of the Immovable
-- 				{ 4,  21471 }, -- Talon of Furious Concentration
-- 				{ 6,  21455 }, -- Southwind Helm
-- 				{ 7,  21468 }, -- Mantle of Maz'Nadir
-- 				{ 8,  21474 }, -- Chitinous Shoulderguards
-- 				{ 9,  21470 }, -- Cloak of the Savior
-- 				{ 10, 21469 }, -- Gauntlets of Southwind
-- 				{ 11, 21476 }, -- Obsidian Scaled Leggings
-- 				{ 12, 21475 }, -- Legplates of the Destroyer
-- 				{ 13, 21477 }, -- Ring of Fury
-- 				{ 14, 21473 }, -- Eye of Moam
-- 				{ 16, 20890 }, -- Qiraji Ornate Hilt
-- 				{ 17, 20886 }, -- Qiraji Spiked Hilt
-- 				{ 21, 20888 }, -- Qiraji Ceremonial Ring
-- 				{ 22, 20884 }, -- Qiraji Magisterial Ring
-- 				{ 24, 22220 }, -- Plans: Black Grasp of the Destroyer
-- 				--{ 24, 22194 }, -- Black Grasp of the Destroyer
-- 			},
-- 		},
-- 		{ -- AQ20Buru
-- 			name = "Buru the Gorger",
-- 			npcID = 15370,
-- 			Level = 999,
-- 			DisplayIDs = {{15654}},
-- 			AtlasMapBossID = 4,
-- 			['loot'] = {
-- 				--{ 1,  21487, [ATLASLOOT_IT_ALLIANCE] = 21486 }, -- Slimy Scaled Gauntlets
-- 				--{ 2,  21486 }, -- Gloves of the Swarm
-- 				{ 2,  21485 }, -- Buru's Skull Fragment
-- 				{ 5,  21491 }, -- Scaled Bracers of the Gorger
-- 				{ 6,  21489 }, -- Quicksand Waders
-- 				{ 7,  21490 }, -- Slime Kickers
-- 				{ 8,  21488 }, -- Fetish of Chitinous Spikes
-- 				{ 16, 20890 }, -- Qiraji Ornate Hilt
-- 				{ 17, 20886 }, -- Qiraji Spiked Hilt
-- 				{ 20, 20885 }, -- Qiraji Martial Drape
-- 				{ 21, 20889 }, -- Qiraji Regal Drape
-- 				{ 22, 20888 }, -- Qiraji Ceremonial Ring
-- 				{ 23, 20884 }, -- Qiraji Magisterial Ring
-- 			},
-- 		},
-- 		{ -- AQ20Ayamiss
-- 			name = "Ayamiss the Hunter",
-- 			npcID = 15369,
-- 			Level = 999,
-- 			DisplayIDs = {{15431}},
-- 			AtlasMapBossID = 5,
-- 			['loot'] = {
-- 				{ 1,  21479 }, -- Gauntlets of the Immovable
-- 				{ 2,  21478 }, -- Bow of Taut Sinew
-- 				{ 3,  21466 }, -- Stinger of Ayamiss
-- 				{ 5,  21484 }, -- Helm of Regrowth
-- 				{ 6,  21480 }, -- Scaled Silithid Gauntlets
-- 				{ 7,  21482 }, -- Boots of the Fiery Sands
-- 				{ 8,  21481 }, -- Boots of the Desert Protector
-- 				{ 9,  21483 }, -- Ring of the Desert Winds
-- 				{ 16, 20890 }, -- Qiraji Ornate Hilt
-- 				{ 17, 20886 }, -- Qiraji Spiked Hilt
-- 				{ 20, 20885 }, -- Qiraji Martial Drape
-- 				{ 21, 20889 }, -- Qiraji Regal Drape
-- 				{ 22, 20888 }, -- Qiraji Ceremonial Ring
-- 				{ 23, 20884 }, -- Qiraji Magisterial Ring
-- 			},
-- 		},
-- 		{ -- AQ20Ossirian
-- 			name = "Ossirian the Unscarred",
-- 			npcID = 15339,
-- 			Level = 999,
-- 			DisplayIDs = {{15432}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  21460 }, -- Helm of Domination
-- 				--{ 2,  21454, [ATLASLOOT_IT_ALLIANCE] = 21453 }, -- Runic Stone Shoulders
-- 				--{ 3,  21453 }, -- Mantle of the Horusath
-- 				{ 3,  21456 }, -- Sandstorm Cloak
-- 				{ 4,  21464 }, -- Shackles of the Unscarred
-- 				{ 5,  21457 }, -- Bracers of Brutality
-- 				{ 6,  21462 }, -- Gloves of Dark Wisdom
-- 				{ 7,  21458 }, -- Gauntlets of New Life
-- 				{ 8,  21463 }, -- Ossirian's Binding
-- 				{ 9, 21461 }, -- Leggings of the Black Blizzard
-- 				{ 10, 21459 }, -- Crossbow of Imminent Doom
-- 				{ 11, 21715 }, -- Sand Polished Hammer
-- 				{ 12, 21452 }, -- Staff of the Ruins
-- 				{ 16, 20890 }, -- Qiraji Ornate Hilt
-- 				{ 17, 20886 }, -- Qiraji Spiked Hilt
-- 				{ 20, 20888 }, -- Qiraji Ceremonial Ring
-- 				{ 21, 20884 }, -- Qiraji Magisterial Ring
-- 				{ 23, 21220 }, -- Head of Ossirian the Unscarred
-- 			},
-- 		},
-- 		{ -- AQ20Trash
-- 			name = "Trash",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				--{ 1,  21804, [ATLASLOOT_IT_ALLIANCE] = 21803 }, -- Coif of Elemental Fury
-- 				--{ 2,  21803 }, -- Helm of the Holy Avenger
-- 				{ 2,  21805 }, -- Polished Obsidian Pauldrons
-- 				{ 5,  20873 }, -- Alabaster Idol
-- 				{ 6,  20869 }, -- Amber Idol
-- 				{ 7,  20866 }, -- Azure Idol
-- 				{ 8,  20870 }, -- Jasper Idol
-- 				{ 9,  20868 }, -- Lambent Idol
-- 				{ 10, 20871 }, -- Obsidian Idol
-- 				{ 11, 20867 }, -- Onyx Idol
-- 				{ 12, 20872 }, -- Vermillion Idol
-- 				{ 14, 21761 }, -- Scarab Coffer Key
-- 				{ 15, 21156 }, -- Scarab Bag
-- 				{ 16, 21801 }, -- Antenna of Invigoration
-- 				{ 17, 21800 }, -- Silithid Husked Launcher
-- 				{ 18, 21802 }, -- The Lost Kris of Zedd
-- 				{ 20, 20864 }, -- Bone Scarab
-- 				{ 21, 20861 }, -- Bronze Scarab
-- 				{ 22, 20863 }, -- Clay Scarab
-- 				{ 23, 20862 }, -- Crystal Scarab
-- 				{ 24, 20859 }, -- Gold Scarab
-- 				{ 25, 20865 }, -- Ivory Scarab
-- 				{ 26, 20860 }, -- Silver Scarab
-- 				{ 27, 20858 }, -- Stone Scarab
-- 				{ 29, 22203 }, -- Large Obsidian Shard
-- 				{ 30, 22202 }, -- Small Obsidian Shard
-- 			},
-- 		},
-- 		{ -- AQ20ClassBooks
-- 			name = "Class books",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  21284 }, -- Codex of Greater Heal V
-- 				{ 2,  21287 }, -- Codex of Prayer of Healing V
-- 				{ 3,  21285 }, -- Codex of Renew X
-- 				{ 4,  21279 }, -- Tome of Fireball XII
-- 				{ 5,  21214 }, -- Tome of Frostbolt XI
-- 				{ 6,  21280 }, -- Tome of Arcane Missiles VIII
-- 				{ 7,  21281 }, -- Grimoire of Shadow Bolt X
-- 				{ 8,  21283 }, -- Grimoire of Corruption VII
-- 				{ 9,  21282 }, -- Grimoire of Immolate VIII
-- 				{ 10, 21300 }, -- Handbook of Backstab IX
-- 				{ 11, 21303 }, -- Handbook of Feint V
-- 				{ 12, 21302 }, -- Handbook of Deadly Poison V
-- 				{ 13, 21294 }, -- Book of Healing Touch XI
-- 				{ 14, 21296 }, -- Book of Rejuvenation XI
-- 				{ 15, 21295 }, -- Book of Starfire VII
-- 				{ 16, 21306 }, -- Guide: Serpent Sting IX
-- 				{ 17, 21304 }, -- Guide: Multi-Shot V
-- 				{ 18, 21307 }, -- Guide: Aspect of the Hawk VII
-- 				{ 19, 21291 }, -- Tablet of Healing Wave X
-- 				{ 20, 21292 }, -- Tablet of Strength of Earth Totem V
-- 				{ 21, 21293 }, -- Tablet of Grace of Air Totem III
-- 				{ 22, 21288 }, -- Libram: Blessing of Wisdom VI
-- 				{ 23, 21289 }, -- Libram: Blessing of Might VII
-- 				{ 24, 21290 }, -- Libram: Holy Light IX
-- 				{ 25, 21298 }, -- Manual of Battle Shout VII
-- 				{ 26, 21299 }, -- Manual of Revenge VI
-- 				{ 27, 21297 }, -- Manual of Heroic Strike IX
-- 			},
-- 		},
-- 		AQ_SCARABS,
-- 		AQ_ENCHANTS,
-- 		AQ_OPENING,
-- 	},
-- }

-- Guildbook.itemdata["TheTempleofAhnQiraj"] = { -- AQ40
-- 	MapID = 3428,
-- 	InstanceID = 531,
-- 	AtlasMapID = "TheTempleofAhnQiraj",
-- 	AtlasMapFile = "TheTempleofAhnQiraj",
-- 	ContentType = RAID40_CONTENT,
-- 	LoadDifficulty = RAID40_DIFF,
-- 	ContentPhase = 5,
-- 	items = {
-- 		{ -- AQ40Skeram
-- 			name = "The Prophet Skeram",
-- 			npcID = 15263,
-- 			Level = 999,
-- 			DisplayIDs = {{15345}},
-- 			AtlasMapBossID = 1,
-- 			['loot'] = {
-- 				{ 1,  21699 }, -- Barrage Shoulders
-- 				{ 2,  21814 }, -- Breastplate of Annihilation
-- 				{ 3,  21708 }, -- Beetle Scaled Wristguards
-- 				{ 4,  21698 }, -- Leggings of Immersion
-- 				{ 5,  21705 }, -- Boots of the Fallen Prophet
-- 				{ 6,  21704 }, -- Boots of the Redeemed Prophecy
-- 				{ 7,  21706 }, -- Boots of the Unwavering Will
-- 				{ 9,  21702 }, -- Amulet of Foul Warding
-- 				{ 10, 21700 }, -- Pendant of the Qiraji Guardian
-- 				{ 11, 21701 }, -- Cloak of Concentrated Hatred
-- 				{ 12, 21707 }, -- Ring of Swarming Thought
-- 				{ 13, 21703 }, -- Hammer of Ji'zhi
-- 				{ 14, 21128 }, -- Staff of the Qiraji Prophets
-- 				{ 16, 21237 }, -- Imperial Qiraji Regalia
-- 				{ 17, 21232 }, -- Imperial Qiraji Armaments
-- 				{ 19, 22222 }, -- Plans: Thick Obsidian Breastplate
-- 				--{ 20, 22196 }, -- Thick Obsidian Breastplate
-- 			},
-- 		},
-- 		{ -- AQ40Trio
-- 			name = "Bug Trio",
-- 			npcID = {15543, 15544, 15511},
-- 			Level = 999,
-- 			DisplayIDs = {{15657},{15658},{15656}},
-- 			AtlasMapBossID = 2,
-- 			['loot'] = {
-- 				{ 1,  21693 }, -- Guise of the Devourer
-- 				{ 2,  21694 }, -- Ternary Mantle
-- 				{ 3,  21697 }, -- Cape of the Trinity
-- 				{ 4,  21696 }, -- Robes of the Triumvirate
-- 				{ 5,  21692 }, -- Triad Girdle
-- 				{ 6,  21695 }, -- Angelista's Touch
-- 				{ 8,  21237 }, -- Imperial Qiraji Regalia
-- 				{ 9,  21232 }, -- Imperial Qiraji Armaments
-- 				--{ 11, "INV_BOX_02", nil, format(AL["%s killed last"] , AL["Lord Kri"]) },
-- 				{ 12, 21680 }, -- Vest of Swift Execution
-- 				{ 13, 21681 }, -- Ring of the Devoured
-- 				{ 14, 21685 }, -- Petrified Scarab
-- 				{ 15, 21603 }, -- Wand of Qiraji Nobility
-- 				--{ 16, "INV_BOX_02", nil, format(AL["%s killed last"] , AL["Vem"]) },
-- 				{ 17, 21690 }, -- Angelista's Charm
-- 				{ 18, 21689 }, -- Gloves of Ebru
-- 				{ 19, 21691 }, -- Ooze-ridden Gauntlets
-- 				{ 20, 21688 }, -- Boots of the Fallen Hero
-- 				--{ 22, "INV_BOX_02", nil, format(AL["%s killed last"] , AL["Princess Yauj"]) },
-- 				{ 23, 21686 }, -- Mantle of Phrenic Power
-- 				{ 24, 21684 }, -- Mantle of the Desert's Fury
-- 				{ 25, 21683 }, -- Mantle of the Desert Crusade
-- 				{ 26, 21682 }, -- Bile-Covered Gauntlets
-- 				{ 27, 21687 }, -- Ukko's Ring of Darkness
-- 			},
-- 		},
-- 		{ -- AQ40Sartura
-- 			name = "Battleguard Sartura",
-- 			npcID = 15516,
-- 			Level = 999,
-- 			DisplayIDs = {{15583}},
-- 			AtlasMapBossID = 3,
-- 			['loot'] = {
-- 				{ 1,  21669 }, -- Creeping Vine Helm
-- 				{ 2,  21678 }, -- Necklace of Purity
-- 				{ 3,  21671 }, -- Robes of the Battleguard
-- 				{ 4,  21672 }, -- Gloves of Enforcement
-- 				{ 5,  21674 }, -- Gauntlets of Steadfast Determination
-- 				{ 6,  21675 }, -- Thick Qirajihide Belt
-- 				{ 7,  21676 }, -- Leggings of the Festering Swarm
-- 				{ 8,  21668 }, -- Scaled Leggings of Qiraji Fury
-- 				{ 9,  21667 }, -- Legplates of Blazing Light
-- 				{ 10, 21648 }, -- Recomposed Boots
-- 				{ 11, 21670 }, -- Badge of the Swarmguard
-- 				{ 12, 21666 }, -- Sartura's Might
-- 				{ 13, 21673 }, -- Silithid Claw
-- 				{ 16, 21237 }, -- Imperial Qiraji Regalia
-- 				{ 17, 21232 }, -- Imperial Qiraji Armaments
-- 			},
-- 		},
-- 		{ -- AQ40Fankriss
-- 			name = "Fankriss the Unyielding",
-- 			npcID = 15510,
-- 			Level = 999,
-- 			DisplayIDs = {{15743}},
-- 			AtlasMapBossID = 4,
-- 			['loot'] = {
-- 				{ 1,  21665 }, -- Mantle of Wicked Revenge
-- 				{ 2,  21639 }, -- Pauldrons of the Unrelenting
-- 				{ 3,  21627 }, -- Cloak of Untold Secrets
-- 				{ 4,  21663 }, -- Robes of the Guardian Saint
-- 				{ 5,  21652 }, -- Silithid Carapace Chestguard
-- 				{ 6,  21651 }, -- Scaled Sand Reaver Leggings
-- 				{ 7,  21645 }, -- Hive Tunneler's Boots
-- 				{ 8,  21650 }, -- Ancient Qiraji Ripper
-- 				{ 9,  21635 }, -- Barb of the Sand Reaver
-- 				{ 11, 21664 }, -- Barbed Choker
-- 				{ 12, 21647 }, -- Fetish of the Sand Reaver
-- 				{ 13, 22402 }, -- Libram of Grace
-- 				{ 14, 22396 }, -- Totem of Life
-- 				{ 16, 21237 }, -- Imperial Qiraji Regalia
-- 				{ 17, 21232 }, -- Imperial Qiraji Armaments
-- 			},
-- 		},
-- 		{ -- AQ40Viscidus
-- 			name = "Viscidus",
-- 			npcID = 15299,
-- 			Level = 999,
-- 			DisplayIDs = {{15686}},
-- 			AtlasMapBossID = 5,
-- 			['loot'] = {
-- 				{ 1,  21624 }, -- Gauntlets of Kalimdor
-- 				{ 2,  21623 }, -- Gauntlets of the Righteous Champion
-- 				{ 3,  21626 }, -- Slime-coated Leggings
-- 				{ 4,  21622 }, -- Sharpened Silithid Femur
-- 				{ 6,  21677 }, -- Ring of the Qiraji Fury
-- 				{ 7,  21625 }, -- Scarab Brooch
-- 				{ 8,  22399 }, -- Idol of Health
-- 				{ 16, 21237 }, -- Imperial Qiraji Regalia
-- 				{ 17, 21232 }, -- Imperial Qiraji Armaments
-- 				{ 19, 20928 }, -- Qiraji Bindings of Command
-- 				{ 20, 20932 }, -- Qiraji Bindings of Dominance
-- 			},
-- 		},
-- 		{ -- AQ40Huhuran
-- 			name = "Princess Huhuran",
-- 			npcID = 15509,
-- 			Level = 999,
-- 			DisplayIDs = {{15739}},
-- 			AtlasMapBossID = 6,
-- 			['loot'] = {
-- 				{ 1,  21621 }, -- Cloak of the Golden Hive
-- 				{ 2,  21618 }, -- Hive Defiler Wristguards
-- 				{ 3,  21619 }, -- Gloves of the Messiah
-- 				{ 4,  21617 }, -- Wasphide Gauntlets
-- 				{ 5,  21620 }, -- Ring of the Martyr
-- 				{ 6,  21616 }, -- Huhuran's Stinger
-- 				{ 16, 21237 }, -- Imperial Qiraji Regalia
-- 				{ 17, 21232 }, -- Imperial Qiraji Armaments
-- 				{ 19, 20928 }, -- Qiraji Bindings of Command
-- 				{ 20, 20932 }, -- Qiraji Bindings of Dominance
-- 			},
-- 		},
-- 		{ -- AQ40Emperors
-- 			name = "Twin Emperors",
-- 			npcID = {15275, 15276},
-- 			Level = 999,
-- 			DisplayIDs = {{15761},{15778}},
-- 			AtlasMapBossID = 7,
-- 			['loot'] = {
-- 				--{ 1, "INV_Box_01", nil, AL["Emperor Vek'lor"] , nil },
-- 				{ 2,  20930 }, -- Vek'lor's Diadem
-- 				{ 3,  21602 }, -- Qiraji Execution Bracers
-- 				{ 4,  21599 }, -- Vek'lor's Gloves of Devastation
-- 				{ 5,  21598 }, -- Royal Qiraji Belt
-- 				{ 6,  21600 }, -- Boots of Epiphany
-- 				{ 7,  21601 }, -- Ring of Emperor Vek'lor
-- 				{ 8,  21597 }, -- Royal Scepter of Vek'lor
-- 				{ 9,  20735 }, -- Formula: Enchant Cloak - Subtlety
-- 				{ 12, 21232 }, -- Imperial Qiraji Armaments
-- 				--{ 16, "INV_Box_01", nil, AL["Emperor Vek'nilash"] , nil },
-- 				{ 17, 20926 }, -- Vek'nilash's Circlet
-- 				{ 18, 21608 }, -- Amulet of Vek'nilash
-- 				{ 19, 21604 }, -- Bracelets of Royal Redemption
-- 				{ 20, 21605 }, -- Gloves of the Hidden Temple
-- 				{ 21, 21609 }, -- Regenerating Belt of Vek'nilash
-- 				{ 22, 21607 }, -- Grasp of the Fallen Emperor
-- 				{ 23, 21606 }, -- Belt of the Fallen Emperor
-- 				{ 24, 21679 }, -- Kalimdor's Revenge
-- 				{ 25, 20726 }, -- Formula: Enchant Gloves - Threat
-- 				{ 27, 21237 }, -- Imperial Qiraji Regalia
-- 			},
-- 		},
-- 		{ -- AQ40Ouro
-- 			name = "Ouro",
-- 			npcID = 15517,
-- 			Level = 999,
-- 			DisplayIDs = {{15509}},
-- 			AtlasMapBossID = 8,
-- 			['loot'] = {
-- 				{ 1,  21615 }, -- Don Rigoberto's Lost Hat
-- 				{ 2,  21611 }, -- Burrower Bracers
-- 				{ 3,  23558 }, -- The Burrower's Shell
-- 				{ 4,  23570 }, -- Jom Gabbar
-- 				{ 5,  21610 }, -- Wormscale Blocker
-- 				{ 6,  23557 }, -- Larvae of the Great Worm
-- 				{ 16, 21237 }, -- Imperial Qiraji Regalia
-- 				{ 17, 21232 }, -- Imperial Qiraji Armaments
-- 				{ 19,  20927 }, -- Ouro's Intact Hide
-- 				{ 20,  20931 }, -- Skin of the Great Sandworm
-- 			},
-- 		},
-- 		{ -- AQ40CThun
-- 			name = "C'Thun",
-- 			npcID = 15727,
-- 			Level = 999,
-- 			DisplayIDs = {{15787}},
-- 			AtlasMapBossID = 9,
-- 			['loot'] = {
-- 				{ 1,  22732 }, -- Mark of C'Thun
-- 				{ 2,  21583 }, -- Cloak of Clarity
-- 				{ 3,  22731 }, -- Cloak of the Devoured
-- 				{ 4,  22730 }, -- Eyestalk Waist Cord
-- 				{ 5,  21582 }, -- Grasp of the Old God
-- 				{ 6,  21586 }, -- Belt of Never-ending Agony
-- 				{ 7,  21585 }, -- Dark Storm Gauntlets
-- 				{ 8,  21581 }, -- Gauntlets of Annihilation
-- 				{ 9,  21596 }, -- Ring of the Godslayer
-- 				{ 10, 21579 }, -- Vanquished Tentacle of C'Thun
-- 				{ 11, 21839 }, -- Scepter of the False Prophet
-- 				{ 12, 21126 }, -- Death's Sting
-- 				{ 13, 21134 }, -- Dark Edge of Insanity
-- 				{ 16, 20929 }, -- Carapace of the Old God
-- 				{ 17, 20933 }, -- Husk of the Old God
-- 				{ 19, 21221 }, -- Eye of C'Thun
-- 				{ 21, 22734 }, -- Base of Atiesh
-- 			},
-- 		},
-- 		{ -- AQ40Trash1
-- 			name = "Trash",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  21838 }, -- Garb of Royal Ascension
-- 				{ 2,  21888 }, -- Gloves of the Immortal
-- 				{ 3,  21889 }, -- Gloves of the Redeemed Prophecy
-- 				{ 4,  21856 }, -- Neretzek, The Blood Drinker
-- 				{ 5,  21837 }, -- Anubisath Warhammer
-- 				{ 6,  21836 }, -- Ritssyn's Ring of Chaos
-- 				{ 7,  21891 }, -- Shard of the Fallen Star
-- 				{ 16, 21218 }, -- Blue Qiraji Resonating Crystal
-- 				{ 17, 21324 }, -- Yellow Qiraji Resonating Crystal
-- 				{ 18, 21323 }, -- Green Qiraji Resonating Crystal
-- 				{ 19, 21321 }, -- Red Qiraji Resonating Crystal
-- 			},
-- 		},
-- 		AQ_SCARABS,
-- 		AQ_ENCHANTS,
-- 		AQ_OPENING,
-- 	},
-- }

-- Guildbook.itemdata["Naxxramas"] = {
-- 	MapID = 3456,
-- 	InstanceID = 533,
-- 	AtlasMapID = "Naxxramas",
-- 	AtlasMapFile = "Naxxramas",
-- 	ContentType = RAID40_CONTENT,
-- 	LoadDifficulty = RAID40_DIFF,
-- 	ContentPhase = 6,
-- 	items = {
-- 		-- The Arachnid Quarter
-- 		{ -- NAXAnubRekhan
-- 			name = "Anub'Rekhan",
-- 			npcID = 15956,
-- 			Level = 999,
-- 			DisplayIDs = {{15931}},
-- 			--AtlasMapBossID = BLUE.."1",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22369 }, -- Desecrated Bindings
-- 				{ 5,  22362 }, -- Desecrated Wristguards
-- 				{ 6,  22355 }, -- Desecrated Bracers
-- 				{ 8,  22935 }, -- Touch of Frost
-- 				{ 9,  22938 }, -- Cryptfiend Silk Cloak
-- 				{ 10, 22936 }, -- Wristguards of Vengeance
-- 				{ 11, 22939 }, -- Band of Unanswered Prayers
-- 				{ 12, 22937 }, -- Gem of Nerubis
-- 			},
-- 		},
-- 		{ -- NAXGrandWidowFaerlina
-- 			name = "Grand Widow Faerlina",
-- 			npcID = 15953,
-- 			Level = 999,
-- 			DisplayIDs = {{15940}},
-- 			--AtlasMapBossID = BLUE.."2",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22369 }, -- Desecrated Bindings
-- 				{ 5,  22362 }, -- Desecrated Wristguards
-- 				{ 6,  22355 }, -- Desecrated Bracers
-- 				{ 8,  22943 }, -- Malice Stone Pendant
-- 				{ 9,  22941 }, -- Polar Shoulder Pads
-- 				{ 10, 22940 }, -- Icebane Pauldrons
-- 				{ 11, 22942 }, -- The Widow's Embrace
-- 				{ 12, 22806 }, -- Widow's Remorse
-- 			},
-- 		},
-- 		{ -- NAXMaexxna
-- 			name = "Maexxna",
-- 			npcID = 15952,
-- 			Level = 999,
-- 			DisplayIDs = {{15928}},
-- 			--AtlasMapBossID = BLUE.."3",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22371 }, -- Desecrated Gloves
-- 				{ 5,  22364 }, -- Desecrated Handguards
-- 				{ 6,  22357 }, -- Desecrated Gauntlets
-- 				{ 8,  22947 }, -- Pendant of Forgotten Names
-- 				{ 9,  23220 }, -- Crystal Webbed Robe
-- 				{ 10, 22954 }, -- Kiss of the Spider
-- 				{ 11, 22807 }, -- Wraith Blade
-- 				{ 12, 22804 }, -- Maexxna's Fang
-- 			},
-- 		},
-- 		-- The Plague Quarter
-- 		{ -- NAXNoththePlaguebringer
-- 			name = "Noth the Plaguebringer",
-- 			npcID = 15954,
-- 			Level = 999,
-- 			DisplayIDs = {{16590}},
-- 			--AtlasMapBossID = PURP.."1",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22370 }, -- Desecrated Belt
-- 				{ 5,  22363 }, -- Desecrated Girdle
-- 				{ 6,  22356 }, -- Desecrated Waistguard
-- 				{ 8,  23030 }, -- Cloak of the Scourge
-- 				{ 9,  23031 }, -- Band of the Inevitable
-- 				{ 10, 23028 }, -- Hailstone Band
-- 				{ 11, 23029 }, -- Noth's Frigid Heart
-- 				{ 12, 23006 }, -- Libram of Light
-- 				{ 13, 23005 }, -- Totem of Flowing Water
-- 				{ 14, 22816 }, -- Hatchet of Sundered Bone
-- 			},
-- 		},
-- 		{ -- NAXHeigantheUnclean
-- 			name = "Heigan the Unclean",
-- 			npcID = 15936,
-- 			Level = 999,
-- 			DisplayIDs = {{16309}},
-- 			--AtlasMapBossID = PURP.."2",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22370 }, -- Desecrated Belt
-- 				{ 5,  22363 }, -- Desecrated Girdle
-- 				{ 6,  22356 }, -- Desecrated Waistguard
-- 				{ 8,  23035 }, -- Preceptor's Hat
-- 				{ 9,  23033 }, -- Icy Scale Coif
-- 				{ 10, 23019 }, -- Icebane Helmet
-- 				{ 11, 23036 }, -- Necklace of Necropsy
-- 				{ 12, 23068 }, -- Legplates of Carnage
-- 			},
-- 		},
-- 		{ -- NAXLoatheb
-- 			name = "Loatheb",
-- 			npcID = 16011,
-- 			Level = 999,
-- 			DisplayIDs = {{16110}},
-- 			--AtlasMapBossID = PURP.."3",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22366 }, -- Desecrated Leggings
-- 				{ 5,  22359 }, -- Desecrated Legguards
-- 				{ 6,  22352 }, -- Desecrated Legplates
-- 				{ 8,  23038 }, -- Band of Unnatural Forces
-- 				{ 9,  23037 }, -- Ring of Spiritual Fervor
-- 				{ 10, 23042 }, -- Loatheb's Reflection
-- 				{ 11, 23039 }, -- The Eye of Nerub
-- 				{ 12, 22800 }, -- Brimstone Staff
-- 			},
-- 		},
-- 		-- The Military Quarter
-- 		{ -- NAXInstructorRazuvious
-- 			name = "Instructor Razuvious",
-- 			npcID = 16061,
-- 			Level = 999,
-- 			DisplayIDs = {{16582}},
-- 			--AtlasMapBossID = _RED.."1",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22372 }, -- Desecrated Sandals
-- 				{ 5,  22365 }, -- Desecrated Boots
-- 				{ 6,  22358 }, -- Desecrated Sabatons
-- 				{ 8,  23017 }, -- Veil of Eclipse
-- 				{ 9,  23219 }, -- Girdle of the Mentor
-- 				{ 10, 23018 }, -- Signet of the Fallen Defender
-- 				{ 11, 23004 }, -- Idol of Longevity
-- 				{ 12, 23009 }, -- Wand of the Whispering Dead
-- 				{ 13, 23014 }, -- Iblis, Blade of the Fallen Seraph
-- 			},
-- 		},
-- 		{ -- NAXGothiktheHarvester
-- 			name = "Gothik the Harvester",
-- 			npcID = 16060,
-- 			Level = 999,
-- 			DisplayIDs = {{16279}},
-- 			--AtlasMapBossID = _RED.."2",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22372 }, -- Desecrated Sandals
-- 				{ 5,  22365 }, -- Desecrated Boots
-- 				{ 6,  22358 }, -- Desecrated Sabatons
-- 				{ 8,  23032 }, -- Glacial Headdress
-- 				{ 9,  23020 }, -- Polar Helmet
-- 				{ 10, 23023 }, -- Sadist's Collar
-- 				{ 11, 23021 }, -- The Soul Harvester's Bindings
-- 				{ 12, 23073 }, -- Boots of Displacement
-- 			},
-- 		},
-- 		{ -- NAXTheFourHorsemen
-- 			name = "The Four Horsemen",
-- 			npcID = {16064, 16065, 30549, 16063},
-- 			Level = 999,
-- 			DisplayIDs = {{16155},{16153},{10729},{16154}},
-- 			--AtlasMapBossID = _RED.."3",
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22351 }, -- Desecrated Robe
-- 				{ 5,  22350 }, -- Desecrated Tunic
-- 				{ 6,  22349 }, -- Desecrated Breastplate
-- 				{ 8,  23071 }, -- Leggings of Apocalypse
-- 				{ 9,  23025 }, -- Seal of the Damned
-- 				{ 10, 23027 }, -- Warmth of Forgiveness
-- 				{ 11, 22811 }, -- Soulstring
-- 				{ 12, 22809 }, -- Maul of the Redeemed Crusader
-- 				{ 13, 22691 }, -- Corrupted Ashbringer
-- 			},
-- 		},
-- 		-- The Construct Quarter
-- 		{ -- NAXPatchwerk
-- 			name = "Patchwerk",
-- 			npcID = 16028,
-- 			Level = 999,
-- 			DisplayIDs = {{16174}},
-- 			AtlasMapBossID = 1,
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22368 }, -- Desecrated Shoulderpads
-- 				{ 5,  22361 }, -- Desecrated Spaulders
-- 				{ 6,  22354 }, -- Desecrated Pauldrons
-- 				{ 8,  22960 }, -- Cloak of Suturing
-- 				{ 9,  22961 }, -- Band of Reanimation
-- 				{ 10, 22820 }, -- Wand of Fates
-- 				{ 11, 22818 }, -- The Plague Bearer
-- 				{ 12, 22815 }, -- Severance
-- 			},
-- 		},
-- 		{ -- NAXGrobbulus
-- 			name = "Grobbulus",
-- 			npcID = 15931,
-- 			Level = 999,
-- 			DisplayIDs = {{16035}},
-- 			AtlasMapBossID = 2,
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22368 }, -- Desecrated Shoulderpads
-- 				{ 5,  22361 }, -- Desecrated Spaulders
-- 				{ 6,  22354 }, -- Desecrated Pauldrons
-- 				{ 8,  22968 }, -- Glacial Mantle
-- 				{ 9,  22967 }, -- Icy Scale Spaulders
-- 				{ 10, 22810 }, -- Toxin Injector
-- 				{ 11, 22803 }, -- Midnight Haze
-- 				{ 12, 22988 }, -- The End of Dreams
-- 			},
-- 		},
-- 		{ -- NAXGluth
-- 			name = "Gluth",
-- 			npcID = 15932,
-- 			Level = 999,
-- 			DisplayIDs = {{16064}},
-- 			AtlasMapBossID = 3,
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22983 }, -- Rime Covered Mantle
-- 				{ 5,  22981 }, -- Gluth's Missing Collar
-- 				{ 6,  22994 }, -- Digested Hand of Power
-- 				{ 7,  23075 }, -- Death's Bargain
-- 				{ 8,  22813 }, -- Claymore of Unholy Might
-- 				{ 16, 22368 }, -- Desecrated Shoulderpads
-- 				{ 17, 22369 }, -- Desecrated Bindings
-- 				{ 18, 22370 }, -- Desecrated Belt
-- 				{ 19, 22372 }, -- Desecrated Sandals
-- 				{ 20, 22361 }, -- Desecrated Spaulders
-- 				{ 21, 22362 }, -- Desecrated Wristguards
-- 				{ 22, 22363 }, -- Desecrated Girdle
-- 				{ 23, 22365 }, -- Desecrated Boots
-- 				{ 24, 22354 }, -- Desecrated Pauldrons
-- 				{ 25, 22355 }, -- Desecrated Bracers
-- 				{ 26, 22356 }, -- Desecrated Waistguard
-- 				{ 27, 22358 }, -- Desecrated Sabatons
-- 			},
-- 		},
-- 		{ -- NAXThaddius
-- 			name = "Thaddius",
-- 			npcID = 15928,
-- 			Level = 999,
-- 			DisplayIDs = {{16137}},
-- 			AtlasMapBossID = 4,
-- 			['loot'] = {
-- 				{ 1,  22726 }, -- Splinter of Atiesh
-- 				{ 2,  22727 }, -- Frame of Atiesh
-- 				{ 4,  22367 }, -- Desecrated Circlet
-- 				{ 5,  22360 }, -- Desecrated Headpiece
-- 				{ 6,  22353 }, -- Desecrated Helmet
-- 				{ 8,  23000 }, -- Plated Abomination Ribcage
-- 				{ 9,  23070 }, -- Leggings of Polarity
-- 				{ 10, 23001 }, -- Eye of Diminution
-- 				{ 11, 22808 }, -- The Castigator
-- 				{ 12, 22801 }, -- Spire of Twilight
-- 			},
-- 		},
-- 		-- Frostwyrm Lair
-- 		{ -- NAXSapphiron
-- 			name = "Sapphiron",
-- 			npcID = 15989,
-- 			Level = 999,
-- 			DisplayIDs = {{16033}},
-- 			--AtlasMapBossID = GREN.."1",
-- 			['loot'] = {
-- 				{ 1,  23050 }, -- Cloak of the Necropolis
-- 				{ 2,  23045 }, -- Shroud of Dominion
-- 				{ 3,  23040 }, -- Glyph of Deflection
-- 				{ 4,  23047 }, -- Eye of the Dead
-- 				{ 5,  23041 }, -- Slayer's Crest
-- 				{ 6,  23046 }, -- The Restrained Essence of Sapphiron
-- 				{ 7,  23049 }, -- Sapphiron's Left Eye
-- 				{ 8,  23048 }, -- Sapphiron's Right Eye
-- 				{ 9,  23043 }, -- The Face of Death
-- 				{ 10, 23242 }, -- Claw of the Frost Wyrm
-- 				{ 16, 23549 }, -- Fortitude of the Scourge
-- 				{ 17, 23548 }, -- Might of the Scourge
-- 				{ 18, 23545 }, -- Power of the Scourge
-- 				{ 19, 23547 }, -- Resilience of the Scourge
-- 			},
-- 		},
-- 		{ -- NAXKelThuzard
-- 			name = "Kel'Thuzad",
-- 			npcID = 15990,
-- 			Level = 999,
-- 			DisplayIDs = {{15945}},
-- 			--AtlasMapBossID = GREN.."2",
-- 			['loot'] = {
-- 				{ 1,  23057 }, -- Gem of Trapped Innocents
-- 				{ 2,  23053 }, -- Stormrage's Talisman of Seething
-- 				{ 3,  22812 }, -- Nerubian Slavemaker
-- 				{ 4,  22821 }, -- Doomfinger
-- 				{ 5,  22819 }, -- Shield of Condemnation
-- 				{ 6,  22802 }, -- Kingsfall
-- 				{ 7,  23056 }, -- Hammer of the Twisting Nether
-- 				{ 8,  23054 }, -- Gressil, Dawn of Ruin
-- 				{ 9,  23577 }, -- The Hungering Cold
-- 				{ 10, 22798 }, -- Might of Menethil
-- 				{ 11, 22799 }, -- Soulseeker
-- 				{ 13, 22520 }, -- The Phylactery of Kel'Thuzad
-- 				{ 16, 23061 }, -- Ring of Faith
-- 				{ 17, 23062 }, -- Frostfire Ring
-- 				{ 18, 23063 }, -- Plagueheart Ring
-- 				{ 19, 23060 }, -- Bonescythe Ring
-- 				{ 20, 23064 }, -- Ring of the Dreamwalker
-- 				{ 21, 23067 }, -- Ring of the Cryptstalker
-- 				{ 22, 23065 }, -- Ring of the Earthshatterer
-- 				{ 23, 23066 }, -- Ring of Redemption
-- 				{ 24, 23059 }, -- Ring of the Dreadnaught
-- 				{ 26, 22733 }, -- Staff Head of Atiesh
-- 			},
-- 		},
-- 		{ -- NAXTrash
-- 			name = "Trash",
-- 			ExtraList = true,
-- 			['loot'] = {
-- 				{ 1,  23664 }, -- Pauldrons of Elemental Fury
-- 				{ 2,  23667 }, -- Spaulders of the Grand Crusader
-- 				{ 3,  23069 }, -- Necro-Knight's Garb
-- 				{ 4,  23226 }, -- Ghoul Skin Tunic
-- 				{ 5,  23663 }, -- Girdle of Elemental Fury
-- 				{ 6,  23666 }, -- Belt of the Grand Crusader
-- 				{ 7,  23665 }, -- Leggings of Elemental Fury
-- 				{ 8,  23668 }, -- Leggings of the Grand Crusader
-- 				{ 9,  23237 }, -- Ring of the Eternal Flame
-- 				{ 10, 23238 }, -- Stygian Buckler
-- 				{ 11, 23044 }, -- Harbinger of Doom
-- 				{ 12, 23221 }, -- Misplaced Servo Arm
-- 				{ 16, 22376 }, -- Wartorn Cloth Scrap
-- 				{ 17, 22373 }, -- Wartorn Leather Scrap
-- 				{ 18, 22374 }, -- Wartorn Chain Scrap
-- 				{ 19, 22375 }, -- Wartorn Plate Scrap
-- 				{ 21, 23055 }, -- Word of Thawing
-- 				{ 22, 22682 }, -- Frozen Rune
-- 			},
-- 		},
-- 	},
-- }
