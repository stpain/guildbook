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
    }
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
    }
}

Guildbook.Data.Class = {
    DEATHKNIGHT = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:128:192|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:128:192|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:128:192|t", IconID = 135771, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DEATHKNIGHT", RGB={ 0.77, 0.12, 0.23 }, FontColour='|cffC41F3B', Specializations={'Frost','Blood','Unholy',} },
    ['DEATH KNIGHT'] = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:128:192|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:128:192|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:128:192|t", IconID = 135771, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DEATHKNIGHT", RGB={ 0.77, 0.12, 0.23 }, FontColour='|cffC41F3B', Specializations={'Frost','Blood','Unholy',} },
    DRUID = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:192:256:0:64|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:192:256:0:64|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:192:256:0:64|t", IconID = 625999, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\DRUID", RGB={ 1.00, 0.49, 0.04 }, FontColour='|cffFF7D0A', Specializations={'Balance','Restoration','Cat','Bear',} },
    HUNTER = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:64:128|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:64:128|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:64:128|t", IconID = 626000, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\HUNTER", RGB={ 0.67, 0.83, 0.45 }, FontColour='|cffABD473', Specializations={'Marksmanship','Beast Master','Survival',} },
    MAGE = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:0:64|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:0:64|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:0:64|t", IconID = 626001, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\MAGE", RGB={ 0.25, 0.78, 0.92 }, FontColour='|cff40C7EB', Specializations={'Fire','Frost','Arcane',} },
    PALADIN = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:128:192|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:128:192|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:128:192|t", IconID = 626003, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\PALADIN", RGB={ 0.96, 0.55, 0.73 }, FontColour='|cffF58CBA', Specializations={'Protection','Retribution','Holy',} },
    PRIEST = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:128:192:64:128|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:128:192:64:128|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:128:192:64:128|t", IconID = 626004, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\PRIEST", RGB={ 1.00, 1.00, 1.00 }, FontColour='|cffFFFFFF', Specializations={'Holy','Discipline','Shadow',} },
    ROGUE = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:128:192:0:64|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:128:192:0:64|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:128:192:0:64|t", IconID = 626005, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\ROGUE", RGB={ 1.00, 0.96, 0.41 }, FontColour='|cffFFF569', Specializations={'Assassination','Combat','Subtlety',} },
    SHAMAN = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:64:128:64:128|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:64:128:64:128|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:64:128:64:128|t", IconID = 626006, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\SHAMAN", RGB={ 0.00, 0.44, 0.87 }, FontColour='|cff0070DE', Specializations={'Elemental','Restoration','Enhancement',} },
    WARLOCK = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:192:256:64:128|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:192:256:64:128|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:192:256:64:128|t", IconID = 626007, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\WARLOCK", RGB={ 0.53, 0.53, 0.93 }, FontColour='|cff8787ED', Specializations={'Affliction','Demonology','Destruction',} },
    WARRIOR = { FontStringIconSMALL="|TInterface\\WorldStateFrame\\ICONS-CLASSES:16:16:0:2:256:256:0:64:0:64|t", FontStringIconMEDIUM="|TInterface\\WorldStateFrame\\ICONS-CLASSES:22:22:0:2:256:256:0:64:0:64|t", FontStringIconLARGE="|TInterface\\WorldStateFrame\\ICONS-CLASSES:28:28:0:2:256:256:0:64:0:64|t", IconID = 626008, Icon="Interface\\Addons\\Guildbook\\Icons\\Class\\WARRIOR", RGB={ 0.78, 0.61, 0.43 }, FontColour='|cffC79C6E', Specializations={'Protection','Arms','Fury',} },
}

Guildbook.Data.Profession = {
    ['-'] = { ID = 0, Name = 'Unknown', Icon = '', FontStringIconSMALL='', },
    Alchemy = { ID = 1, Name = 'Alchemy' , Icon= 'Interface\\Icons\\Trade_Alchemy' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:3:67:3:67|t',},
    Blacksmithing = { ID = 2, Name = 'Blacksmithing' , Icon= 'Interface\\Icons\\Trade_Blacksmithing' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:77:141:3:67|t', },
    Enchanting = { ID = 3, Name = 'Enchanting' , Icon= 'Interface\\Icons\\Trade_Engraving' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:153:217:3:67|t', },
    Engineering = { ID = 4, Name = 'Engineering' , Icon= 'Interface\\Icons\\Trade_Engineering' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:227:291:3:67|t', },
    Inscription = { ID = 5, Name = 'Inscription' , Icon= 'Interface\\Icons\\INV_Inscription_Tradeskill01' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:3:67:79:143|t', },
    Jewelcrafting = { ID = 6, Name = 'Jewelcrafting' , Icon= 'Interface\\Icons\\INV_MISC_GEM_01' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:77:141:79:143|t', },
    Leatherworking = { ID = 7, Name = 'Leatherworking' , Icon= 'Interface\\Icons\\INV_Misc_ArmorKit_17' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:153:217:79:143|t', },
    Tailoring = { ID = 8, Name = 'Tailoring' , Icon= 'Interface\\Icons\\Trade_Tailoring' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:227:291:79:143|t', },
    Herbalism = { ID = 9, Name = 'Herbalism' , Icon= 'Interface\\Icons\\INV_Misc_Flower_02' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:38:102:153:217|t', },
    Skinning = { ID = 10, Name = 'Skinning' , Icon= 'Interface\\Icons\\INV_Misc_Pelt_Wolf_01' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:187:251:153:217|t', },
    Mining = { ID = 11, Name = 'Mining' , Icon= 'Interface\\Icons\\Spell_Fire_FlameBlades' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:112:176:153:217|t', },
    Cooking = { ID = 12, Name = 'Cooking', Icon = 'Interface\\Icons\\inv_misc_food_15' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:2:66:226:290|t', },
    Fishing = { ID = 13, Name = 'Fishing', Icon = 'Interface\\Icons\\Trade_Fishing' , FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:151:215:226:290|t', },
    FirstAid = { ID = 14, Name = 'FirstAid', Icon = 'Interface\\Icons\\Spell_Holy_SealOfSacrifice', FontStringIconSMALL='|TInterface\\Addons\\Guildbook\\Icons\\Professions\\IconTextures:14:14:0:0:512:512:76:140:226:290|t', },
}

Guildbook.Data.ProfToID = {
    Alchemy = 'a',
    Blacksmithing = 'b',
    Enchanting = 'c',
    Engineering = 'd',
    Inscription = 'e',
    Jewelcrafting = 'f',
    Leatherworking = 'g',
    Tailoring = 'h',
    Herbalism = 'i',
    Skinning = 'j',
    Mining = 'k',
    Cooking = 'l',
    Fishing = 'm',
    FirstAid = 'n',
}

Guildbook.Data.ProfFromID = {
    ['a'] = 'Alchemy',
    ['b'] = 'Blacksmithing',
    ['c'] = 'Enchanting',
    ['d'] = 'Engineering',
    ['e'] = 'Inscription',
    ['f'] = 'Jewelcrafting',
    ['g'] = 'Leatherworking',
    ['h'] = 'Tailoring',
    ['i'] = 'Herbalism',
    ['j'] = 'Skinning',
    ['k'] = 'Mining',
    ['l'] = 'Cooking',
    ['m'] = 'Fishing',
    ['n'] = 'FirstAid',
}

Guildbook.Data.SpecToID = {
    Balance = 'a',
    Bear = 'b',
    Cat = 'c',
    Restoration = 'd',
    Frost = 'e',
    Blood = 'f',
    Unholy = 'g',
    ['Beast Master'] = 'h',
    Marksmanship = 'i',
    Survival = 'j',
    Assassination = 'k',
    Combat = 'l',
    Subtlety = 'm',
    Fire = 'n',
    Arcane = 'o',
    Holy = 'p',
    Discipline = 'q',
    Shadow = 'r',
    Elemental = 's',
    Enhancement = 't',
    Demonology = 'u',
    Affliction = 'v',
    Destruction = 'w',
    Arms = 'x',
    Fury = 'y',
    Protection = 'z',
    Retribution = '0',
    Feral = '1', --hmm maybe used?
}

Guildbook.Data.SpecFromID = {
    ['a'] = 'Balance',
    ['b'] = 'Bear',
    ['c'] = 'Cat',
    ['d'] = 'Restoration',
    ['e'] = 'Frost',
    ['f'] = 'Blood',
    ['g'] = 'Unholy',
    ['h'] = 'Beast Master',
    ['i'] = 'Marksmanship',
    ['j'] = 'Survival',
    ['k'] = 'Assassination',
    ['l'] = 'Combat',
    ['m'] = 'Subtlety',
    ['n'] = 'Fire',
    ['o'] = 'Arcane',
    ['p'] = 'Holy',
    ['q'] = 'Discipline',
    ['r'] = 'Shadow',
    ['s'] = 'Elemental',
    ['t'] = 'Enhancement',
    ['u'] = 'Demonology',
    ['v'] = 'Affliction',
    ['w'] = 'Destruction',
    ['x'] = 'Arms',
    ['y'] = 'Fury',
    ['z'] = 'Protection',
    ['0'] = 'Retribution',
    ['1'] = 'Feral', --hmm maybe used?
}

Guildbook.Data.SpecFontStringIconSMALL = { 
    DRUID = { ['-'] = '', Balance = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:0:63|t", Bear = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", Cat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", Feral = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:63:126|t", Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:189:252:126:188|t" },
    DEATHKNIGHT = { ['-'] = '', Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:63:126|t", Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:0:63|t", Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:126:188|t"},
    ['DEATH KNIGHT'] = { ['-'] = '', Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:63:126|t", Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:0:63|t", Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:567:640:126:188|t"},
    HUNTER = { ['-'] = '', ['Beast Master'] = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:252:315:0:63|t", Marksmanship = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:252:315:63:126|t", Survival = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:252:315:126:188|t"},
    ROGUE = { ['-'] = '', Assassination = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:126:188:0:63|t", Combat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:126:188:63:126|t", Subtlety = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:126:188:126:188|t"},
    MAGE = { ['-'] = '', Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:63:126:126:188|t", Fire = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:63:126:63:126|t", Arcane = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:63:126:0:63|t"},
    PRIEST = { ['-'] = '', Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:378:441:63:126|t", Discipline = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:378:441:0:63|t", Shadow = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:378:441:126:188|t"},
    SHAMAN = { ['-'] = '', Elemental = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:315:378:0:63|t", Enhancement = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:315:378:63:126|t", Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:315:378:126:188|t" },
    WARLOCK = { ['-'] = '', Demonology = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:441:504:63:126|t", Affliction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:441:504:0:63|t", Destruction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:441:504:126:188|t"},
    WARRIOR = { ['-'] = '', Arms = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:0:63:0:63|t", Fury = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:0:63:63:126|t", Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:0:63:126:188|t"},
    PALADIN = { ['-'] = '', Retribution = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:504:567:126:188|t", Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:504:567:0:63|t", Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:14:14:0:0:1024:256:504:567:63:126|t"},
}

Guildbook.Data.SpecFontStringIconLARGE = { 
    DRUID = { ['-'] = '', Balance = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:0:63|t", Bear = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:63:126|t", Cat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:63:126|t", Feral = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:63:126|t", Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:189:252:126:188|t" },
    DEATHKNIGHT = { ['-'] = '', Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:63:126|t", Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:0:63|t", Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:126:188|t"},
    ['DEATH KNIGHT'] = { ['-'] = '', Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:63:126|t", Blood = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:0:63|t", Unholy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:567:640:126:188|t"},
    HUNTER = { ['-'] = '', ['Beast Master'] = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:252:315:0:63|t", Marksmanship = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:252:315:63:126|t", Survival = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:252:315:126:188|t"},
    ROGUE = { ['-'] = '', Assassination = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:126:188:0:63|t", Combat = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:126:188:63:126|t", Subtlety = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:126:188:126:188|t"},
    MAGE = { ['-'] = '', Frost = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:63:126:126:188|t", Fire = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:63:126:63:126|t", Arcane = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:63:126:0:63|t"},
    PRIEST = { ['-'] = '', Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:378:441:63:126|t", Discipline = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:378:441:0:63|t", Shadow = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:378:441:126:188|t"},
    SHAMAN = { ['-'] = '', Elemental = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:315:378:0:63|t", Enhancement = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:315:378:63:126|t", Restoration = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:315:378:126:188|t" },
    WARLOCK = { ['-'] = '', Demonology = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:441:504:63:126|t", Affliction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:441:504:0:63|t", Destruction = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:441:504:126:188|t"},
    WARRIOR = { ['-'] = '', Arms = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:0:63:0:63|t", Fury = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:0:63:63:126|t", Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:0:63:126:188|t"},
    PALADIN = { ['-'] = '', Retribution = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:504:567:126:188|t", Holy = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:504:567:0:63|t", Protection = "|TInterface\\Addons\\Guildbook\\Icons\\Specialization\\Textures:28:28:0:0:1024:256:504:567:63:126|t"},
}

Guildbook.Data.SpecToRole = {
    DRUID = { Restoration = 'Healer', Balance = 'Ranged', Cat = 'Melee',  Bear = 'Tank', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    SHAMAN = { Elemental = 'Ranged', Enhancement = 'Melee', Restoration = 'Healer', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    HUNTER = { Marksmanship = 'Ranged', ['Beast Master'] = 'Ranged', Survival = 'Ranged', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    PALADIN = { Holy = 'Healer', Protection = 'Tank', Retribution = 'Melee', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    WARRIOR = { Arms = 'Melee', Fury = 'Melee', Protection = 'Tank', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    ROGUE = { Assassination = 'Melee', Combat = 'Melee', Subtlety = 'Melee', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    PRIEST = { Holy = 'Healer', Discipline = 'Healer', Shadow = 'Ranged', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    WARLOCK = { Demonology = 'Ranged', Affliction = 'Ranged', Destruction = 'Ranged', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    MAGE = { Frost = 'Ranged', Fire = 'Ranged', Arcane = 'Ranged', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    DEATHKNIGHT = { Frost = 'Tank', Blood = 'Tank', Unholy = 'Melee', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
    ['DEATH KNIGHT'] = { Frost = 'Tank', Blood = 'Tank', Unholy = 'Melee', unknown = 'Unknown', pvp = 'PvP', ['-'] = '-' },
}

Guildbook.Data.RoleIcons = {
    Healer = { Icon = '', FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t", FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:20:39:1:20|t" },
    Tank = { Icon = '', FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t", FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:0:19:22:41|t" },
    Melee = { Icon = '', FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t", FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:20:39:22:41|t" },
    Ranged = { Icon = '', FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t", FontStringIconLARGE = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:24:24:0:0:64:64:20:39:22:41|t" },
    Damage = { Icon = '', FontStringIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t" },
    ['-'] = { Icon = '', FontStringIcon = '', FontStringIconLARGE = '' },
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

Guildbook.ProfessionDescriptions = {
    Alchemy = 'Mix potions, elixirs, flasks, oils and other alchemical substances into vials using herbs and other reagents. Your concoctions can restore health and mana, enhance attributes, or provide any number of other useful (or not-so-useful) effects. High level alchemists can also transmute essences and metals into other essences and metals. Alchemists can specialize as a Master of Potions, Master of Elixirs, or a Master of Transmutation.',
    Blacksmithing = 'Smith various melee weapons, mail and plate armor, and other useful trade goods like skeleton keys, shield-spikes and weapon chains to prevent disarming. Blacksmiths can also make various stones to provide temporary physical buffs to weapons.',
    Enchanting = 'Imbue all manner of equipable items with magical properties and enhancements using dusts, essences and shards gained by disenchanting (breaking down) magical items that are no longer useful. Enchanters can also make a few low-level wands, as well as oils that can be applied to weapons providing a temporary magical buff.',
    Engineering = 'Engineer a wide range of mechanical devices—including trinkets, guns, goggles, explosives and mechanical pets—using metal, minerals, and stone. As most engineering products can only be used by suitably adept engineers, it is not as profitable as the other professions; it is, however, often taken to be one of the most entertaining, affording its adherents with numerous unconventional and situationally useful abilities. Engineers can specialize as Goblin or Gnomish engineers.',
    Inscription = "Inscribe glyphs that modify existing spells and abilities for all classes, in addition to various scrolls, staves, playing cards and off-hand items. A scribe can also create vellums for the storing of an Enchanter\'s spells and scribe-only scrolls used to teleport around the world (albeit a tad randomly). Also teaches you the [Milling] ability, which crushes herbs into various pigments used, in turn, for a scribe's ink."	,
    Jewelcrafting = 'Cut and polish powerful gems that can be socketed into armor and weapons to augment their attributes or fashioned into rings, necklaces, trinkets, and jeweled headpieces. Also teaches you the [Prospecting] ability, which sifts through raw ores to uncover the precious gems needed for your craft.',
    Leatherworking = 'Work leather and hides into goods such as leather and mail armor, armor kits, and some capes. Leatherworkers can also produce a number of utility items including large profession bags, ability-augmenting drums, and riding crops to increase mount speed.'	,
    Tailoring = 'Sew cloth armor and many kinds of bags using dye, thread and cloth gathered from humanoid enemies during your travels. Tailors can also fashion nets to slow enemies with, rideable flying carpets, and magical threads which empower items they are stitched into.',
}
