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
L['Summary'] = 'Summary'
L['SummaryHeader'] = 'Guild Summary'
L['Roster'] = 'Roster'
L['CharacterLevel'] = 'Character Level'
L['Name'] = 'Name'
L['Roles'] = 'Roles'
L['Tank'] = 'Tank'
L['Melee'] = 'Melee'
L['Ranged'] = 'Ranged'
L['Healer'] = 'Healer'
L['ClassRoleSummary'] = 'Class & Role Summary'
L['RoleChart'] = 'Roles (Online Members)'
L['ClassChart'] = 'Classes (All Members)'
L['Online'] = 'Online'
L['Offline'] = 'Offline'
L['SearchFor'] = 'Search...'
L['Info'] = 'Info'
L['Specializations'] = 'Specializations'
L['ItemLevel'] = 'Item Level'
L['MainSpec'] = 'Main Spec'
L['Main'] = 'Main:'
L['Rank'] = 'Rank'
L['Note'] = 'Note'
L['OffSpec'] = 'Off Spec:'
L['IsPvpSpec'] = 'PVP'
L['Class'] = 'Class'
L['FirstAid'] = 'First Aid'
L['Fishing'] = 'Fishing'
L['Cooking'] = 'Cooking'
L['Professions'] = 'Professions'
L['Profession1'] = 'Profession 1'
L['Profession2'] = 'Profession 2'
L['Profiles'] = 'Profiles'
L['Chat'] = 'Chat'
L['Statistics'] = 'Statistics'
L['Calendar'] = 'Calendar'
L['GuildBank'] = 'Guild Bank'
L['EditCharacterInfo'] = 'Information about your character should be displayed below, update your specializations and if this is an alt provide your main character name.\nClick confirm to share with guild.'
L['SaveCharacterData'] = 'Confirm'
L['MainCharacterNameInputDesc'] = 'If this is an alt add your Main Character name' -- word better???
L['MainCharacter'] = 'Main Character'
L['Gems'] = 'Gems'
L['Enchants'] = 'Enchants'
L['ilvl'] = 'ilvl'
L['Guild Information'] = 'Guild Information'
L['ClassRolesSummary'] = 'Class & Role Summary'
L['RaidRoster'] = 'Raid Roster |cffffffff(Right click player for more options)|r'


--------------------------------------------------------------------------------------------
-- help text tooltips
--------------------------------------------------------------------------------------------
L['profilesHelpText'] = [[
Profiles.

|cffffffffYou can search for characters or items using Guildbook.

When you search a drop-down list will show possible
matches, this list is limited and if the results count 
exceeds the limit it won't show, so if nothing appears 
keep typing to narrow the results.

Recipe items will show a sub menu of characters who can 
craft the item. Click the character to view the recipe 
item in their 'Professions' tab.|r

|cff00BFF3Character models are not available by default, to display 
them you will need to open profiles and mouse-over the 
various race/gender combinations for your faction. The 
limitation here is that the models shown will keep the 
characteristic's of the character you mouse over. This 
shouldn't be to detrimental as most characters will have 
a head/helm piece which hides the face and hair etc.|r
]]


L['calendarHelpText'] = [[
Calendar

|cffffffffGuildbook provides an in-game calendar for guilds to 
schedule events. It's loosely based on an older version of the
Blizzard calendar and functions in a similar manner. Currently 
up to 3 events per day will be shown (an option to access more 
will be added) on the day tiles.|r

|cff00BFF3The calendar sends/receives data when a player logs in, 
when an event is created or deleted and when an event is modified. 
Events should sync with guild members although this is not guaranteed 
as it relies on there being enough overlap between player sessions.

Data sent is limited to 4 weeks to reduce demand on the addon chat 
systems, events can be created for any date and will sync once they 
fall within 4 weeks of the current date|r.
]]

--------------------------------------------------------------------------------------------
-- class and spec
--------------------------------------------------------------------------------------------
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