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

local addonName, Guildbook = ...

--some of these options are from my old addon and will be remove in time if not used
local L = {}
L['CharacterName'] = 'Data Recipient'
L['OptionsHeader'] = 'Guildbook allows players to share more detail about their characters with guild members. Use the options below your to set spec/alt information for your character.'
L['GearScoreDetected'] = 'GearScore detected, Guildbook will share your GearScore with your guild.'
L['Summary'] = 'Summary'
L['SummaryHeader'] = 'Guild Summary'
L['Roster'] = 'Roster'
L['RaidSpecs'] = 'Raid Specs'
L['GuildTrade'] = 'Guild Trade'
L['GuildTradeDesc'] = 'Guild Trade, search for a player to craft that epic gem or get the latest enchants. Select a profession to see addon users who have shared their profession crafts.'
L['RosterHeader'] = 'Guild roster' --add more about the roster ???
L['Level'] = 'Level'
L['Name'] = 'Name'
L['Role'] = 'Role'
L['ClassRoles'] = 'Class Roles'
L['RoleChart'] = 'Roles (Online Members)'
L['ClassChart'] = 'Classes (All Members)'
L['ClassSummaryMinLevel'] = 'Set the min level for characters to be shown in the class summary chart'
L['RescanRoster'] = 'Rescan Roster'
L['ShowOfflineCB'] = 'Online'
L['Online'] = 'Online'
L['Offline'] = 'Offline'
L['SearchName'] = 'Search members'
L['PlayerNotesInfo'] = 'Character Notes & Info'
L['Info'] = 'Info'
L['Specializations'] = 'Specializations'
L['ItemLevel'] = 'Item Level'
L['GearScore'] = 'Gear Score'
L['MainSpec'] = 'Main Spec:'
L['Main'] = 'Main:'
L['OffSpec'] = 'Off Spec:'
L['IsPvpSpec'] = 'PVP'
L['Class'] = 'Class'
L['FirstAid'] = 'First Aid'
L['Fishing'] = 'Fishing'
L['Cooking'] = 'Cooking'
L['ProfessionRecipes'] = 'Profession Recipes'
L['Professions'] = 'Professions'
L['Profession1'] = 'Profession 1'
L['ShareProfession'] = 'Share Recipes'
L['ShareProfTooltip'] = 'This will open the profession window so Guildbook can scan your recipes.'
L['Profession2'] = 'Profession 2'
L['Profile'] = 'Profile'
L['EditCharacterInfo'] = 'Information about your character should be displayed below, update your specializations and if this is an alt provide your main character name.\nClick confirm to share with guild.'
L['SaveCharacterData'] = 'Confirm'
L['MainCharacterNameInputDesc'] = 'If this is an alt add your Main Character name' -- word better???
L['SortClass'] = 'Click to sort guild members by Class'
L['SortName'] = 'Click to sort guild members by Name'
L['SortLevel'] = 'Click to sort guild members by Level'
L['SortRole'] = 'Click to sort guild members by role Tanks > Healer > Damage (uses primary spec)'
L['MainCharacter'] = 'Main Character'
L['Raids'] = 'Raids'
L['RaidSelectDesc'] = 'Select the raid and difficulty from the drop down to view reccommended information.'
L['Gems'] = 'Gems'
L['Enchants'] = 'Enchants'
L['Tanks'] = 'Tanks'
L['Melee'] = 'Melee'
L['Ranged'] = 'Ranged'
L['Healers'] = 'Healers'
L['ilvl'] = 'ilvl'
L['Guild Information'] = 'Guild Information'
L['ClassRolesSummary'] = 'Class & Role Summary'
L['RaidRoster'] = 'Raid Roster |cffffffff(Right click player for more options)|r'

--THE LIST BELOW ISNT USED YET SO CAN BE IGNORED FOR TRANSLATION.
--keep these as upper as its the return value from an api
L['DEATHKNIGHT'] = 'Deathknight'
L['DRUID'] = 'Druid'
L['HUNTER'] = 'Hunter'
L['MAGE'] = 'Mage'
L['PALADIN'] = 'Paladin'
L['PRIEST'] = 'Priest'
L['SHAMAN'] = 'Shaman'
L['ROGUE'] = 'Rogue'
L['WARLOCK'] = 'Warlock'
L['WARRIOR'] = 'Warrior'
--class specifications
--mage/dk
L['Arcane'] = 'Arcane'
L['Fire'] = 'Fire'
L['Frost'] = 'Frost'
L['Blood'] = 'Blood'
L['Unholy'] = 'Unholy'
--druid/shaman
L['Restoration'] = 'Restoration'
L['Enhancement'] = 'Enhancement'
L['Elemental'] = 'Elemental'
L['Cat'] = 'Cat'
L['Bear'] = 'Bear'
L['Balance'] = 'Balance'
--rogue
L['Assassination'] = 'Assassination'
L['Combat'] = 'Combat'
L['Subtlety'] = 'Subtlety'
--hunter
L['Marksmanship'] = 'Marksmanship'
L['Beast Master'] = 'Beast Master'
L['Survival'] = 'Survival'
--warlock
L['Destruction'] = 'Destruction'
L['Affliction'] = 'Affliction'
L['Demonology'] = 'Demonology'
--warrior/paladin/priest
L['Fury'] = 'Fury'
L['Arms'] = 'Arms'
L['Protection'] = 'Protection'
L['Retribution'] = 'Retribution'
L['Holy'] = 'Holy'
L['Discipline'] = 'Discipline'
L['Shadow'] = 'Shadow'

local locale = GetLocale()
--USE THIS TO CREATE LOCALES - SWAP 'deDE' FOR THE COUNTRY/LANGUAGE YOU ARE TRANSLATING INTO
if locale == "deDE" then


elseif locale == '' then


end

Guildbook.Locales = L

-- this will be a lookup table to convert to english for function args etc
Guildbook.GetEnglish = {
    ['enUS'] = {
        ['Alchemy'] = 'Alchemy',
        ['Blacksmithing'] = 'Blacksmithing',
        ['Enchanting'] = 'Enchanting',
        ['Engineering'] = 'Engineering',
        ['Inscription'] = 'Inscription',
        ['Jewelcrafting'] = 'Jewelcrafting',
        ['Leatherworking'] = 'Leatherworking',
        ['Tailoring'] = 'Tailoring',
        ['Herbalism'] = 'Herbalism',
        ['Skinning'] = 'Skinning',
        ['Mining'] = 'Mining',
        ['Cooking'] = 'Cooking',
        ['Fishing'] = 'Fishing',
        ['First Aid'] = 'First Aid',
    },
    ['deDE'] = {
        ["Alchimie"] = "Alchemy",
        ["Schmiedekunst"] = "Blacksmithing",
        ["Verzauberkunst"] = "Enchanting",
        ["Ingenieurskunst"] = "Engineering",
        --['Inscription'] = 'Inscription',
        --['Jewelcrafting'] = 'Jewelcrafting',
        ["Lederverarbeitung"] = "Leatherworking",
        ["Schneiderei"] = "Tailoring",
        ["Lederverarbeitung"] = "Leatherworking",
        ["Kräuterkunde"] = "Herbalism",
        ["Kürschnerei"] = "Skinning",
        ["Bergbau"] = "Mining",
        ['Erste Hilfe'] = 'First Aid',
        ['Angeln'] = 'Fishing',
        ['Kochkunst'] = 'Cooking',
    },
}