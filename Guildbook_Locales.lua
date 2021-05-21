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
    this file will need to be translated with the help of the community

    if anyone modifies this could they please drop me a message on curse or git so i can include any translations
]]


local addonName, Guildbook = ...

-- locales table
local L = {}

-- buttons, labels and texts
L['CharacterName'] = 'Data Recipient'
L['OptionsAbout'] = 'Guildbook options and about.'
L['Version'] = 'Version'
L['Author'] = 'Author: |cffffffffstpain (|r|cffF58CBACopperbolts|r, |cffABD473Windstalker|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'
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
L['Search'] = 'Search'
L['Info'] = 'Info'
L['Specializations'] = 'Specializations'
L['ItemLevel'] = 'Item Level'
L['MainSpec'] = 'Main Spec'
L['Main'] = 'Main:'
L['Rank'] = 'Rank'
L['Note'] = 'Note'
L['OffSpec'] = 'Off Spec:'
L['IsPvpSpec'] = ' PVP'
L['Class'] = 'Class'
L['FirstAid'] = 'First Aid'
L['Fishing'] = 'Fishing'
L['Cooking'] = 'Cooking'
L['Professions'] = 'Professions'
L['Profession1'] = 'Profession 1'
L['Profession2'] = 'Profession 2'
L['Profiles'] = 'Profiles'
L['Profile'] = 'Profile'
L['Home'] = 'Home'
L['Chat'] = 'Chat'
L['Statistics'] = 'Statistics'
L['Calendar'] = 'Calendar'
L['GuildBank'] = 'Guild Bank'
L['EditCharacterInfo'] = 'Information about your character should be displayed below, update your specializations and if this is an alt provide your main character name.\nClick confirm to share with guild.'
L['SaveCharacterData'] = 'Confirm'
L['MainCharacterNameInputDesc'] = 'Main character'
L['MainCharacter'] = 'Main Character'
L['Gems'] = 'Gems'
L['Enchants'] = 'Enchants'
L['ilvl'] = 'ilvl'
L['Guild Information'] = 'Guild Information'
L['ClassRolesSummary'] = 'Class & Role Summary'
L['RaidRoster'] = 'Raid Roster |cffffffff(Right click player for more options)|r'
L['Cancel'] = 'Cancel'
L['GuildBank'] = 'Guild Bank'
L['Events'] = 'Events'
L['WorldEvents'] = 'World Events'
L['Attunements'] = 'Attunements'
L["Guild"] = "Guild"
L["name"] = "Name"
L["level"] = "Level"
L["mainSpec"] = "Main Spec"
L["prof1"] = "Trade"
L["location"] = "Location"
L["rankName"] = "Rank"
L["publicNote"] = "Public Note"
L["class"] = "Class"

--professions
L['Alchemy'] = 'Alchemy'
L['Blacksmithing'] = 'Blacksmithing'
L['Enchanting'] = 'Enchanting'
L['Engineering'] = 'Engineering'
L['Inscription'] = 'Inscription'
L['Jewelcrafting'] = 'Jewelcrafting'
L['Leatherworking'] = 'Leatherworking'
L['Tailoring'] = 'Tailoring'
L['Herbalism'] = 'Herbalism'
L['Skinning'] = 'Skinning'
L['Mining'] = 'Mining'
L['Cooking'] = 'Cooking'
L['Fishing'] = 'Fishing'
L['First Aid'] = 'First Aid'


-- class and spec
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

--date time
L['January'] = 'January'
L['February'] = 'February'
L['March'] = 'March'
L['April'] = 'April'
L['May'] = 'May'
L['June'] = 'June'
L['July'] = 'July'
L['August'] = 'August'
L['September'] = 'September'
L['October'] = 'October'
L['November'] = 'November'
L['December'] = 'December'
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
them you will need to open profiles tab and mouse-over 
players of the various race/gender combinations for your 
faction. The limitation here is that the models shown 
will keep the characteristic's of the character you mouse 
over. 
This shouldn't be to detrimental as most characters will 
have a head/helm piece which hides the face and hair etc.|r
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



-- grab the clients locale
local locale = GetLocale()



--[[
    german
]]
if locale == "deDE" then

    -- buttons, labels and texts
    L['CharacterName'] = 'Data Recipient'
    L['OptionsAbout'] = 'Guildbook allows players to share more detail about their characters with guild members. Use the options below your to set spec/alt information for your character.'
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
    L['IsPvpSpec'] = '  PVP'
    L['Class'] = 'Class'
    L['FirstAid'] = 'First Aid'
    L['Fishing'] = 'Fishing'
    L['Cooking'] = 'Cooking'
    L['Professions'] = 'Professions'
    L['Profession1'] = 'Profession 1'
    L['Profession2'] = 'Profession 2'
    L['Profiles'] = 'Profiles'
    L['Profile'] = 'Profile'
    L['Chat'] = 'Chat'
    L['Statistics'] = 'Statistics'
    L['Calendar'] = 'Calendar'
    L['GuildBank'] = 'Guild Bank'
    L['EditCharacterInfo'] = 'Information about your character should be displayed below, update your specializations and if this is an alt provide your main character name.\nClick confirm to share with guild.'
    L['SaveCharacterData'] = 'Confirm'
    L['MainCharacterNameInputDesc'] = 'Main character'
    L['MainCharacter'] = 'Main Character'
    L['Gems'] = 'Gems'
    L['Enchants'] = 'Enchants'
    L['ilvl'] = 'ilvl'
    L['Guild Information'] = 'Guild Information'
    L['ClassRolesSummary'] = 'Class & Role Summary'
    L['RaidRoster'] = 'Raid Roster |cffffffff(Right click player for more options)|r'
    L['Cancel'] = 'Cancel'
    L['GuildBank'] = 'Guild Bank'

    --professions
    L['Alchemy'] = "Alchimie"
    L["Blacksmithing"] = "Schmiedekunst"
    L["Enchanting"] = "Verzauberkunst"
    L["Engineering"] = "Ingenieurskunst"
    --['Inscription'] = 'Inscription',
    --['Jewelcrafting'] = 'Jewelcrafting',
    L['Tailoring'] = "Schneiderei"
    L['Leatheroworking'] = "Lederverarbeitung"
    L['Herbalism'] = "Kräuterkunde"
    L['Skinning'] = "Kürschnerei"
    L['Mining'] = "Bergbau"
    L['First Aid'] = 'Erste Hilfe'
    L['Fishing'] = 'Angeln'
    L['Cooking'] = 'Kochkunst'

    -- class and spec
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




--[[
    french
]]
elseif locale == 'frFR' then

    -- buttons, labels and texts
    L['CharacterName'] = 'Destinataire des données'
    L['OptionsAbout'] = 'Guildbook permet aux joueurs de partager les détails de leurs personnages avec les membres de guilde. Utilisez les options ci-dessous pour régler les informations de spécialisation et alt de votre personnage.'
    L['Summary'] = 'Résumé'
    L['SummaryHeader'] = 'Résumé de guilde'
    L['Roster'] = 'Roster'
    L['CharacterLevel'] = 'Niveau du personnage'
    L['Name'] = 'Nom'
    L['Roles'] = 'Roles'
    L['Tank'] = 'Tank'
    L['Melee'] = 'Mêlée'
    L['Ranged'] = 'Distance'
    L['Healer'] = 'Soigneur'
    L['ClassRoleSummary'] = 'Résumé de classe et role'
    L['RoleChart'] = 'Roles (Members en ligne)'
    L['ClassChart'] = 'Classes (Tous les membres)'
    L['Online'] = 'En ligne'
    L['Offline'] = 'Hors ligne'
    L['SearchFor'] = 'Recherche...'
    L['Info'] = 'Info'
    L['Specializations'] = 'Spécialisations'
    L['ItemLevel'] = 'Item Level'
    L['MainSpec'] = 'Spé principale'
    L['Main'] = 'Principale:'
    L['Rank'] = 'Rang'
    L['Note'] = 'Note'
    L['OffSpec'] = 'Spé secondaire:'
    L['IsPvpSpec'] = '  JcJ'
    L['Class'] = 'Classe'
    L['FirstAid'] = 'Secourisme'
    L['Fishing'] = 'Pêche'
    L['Cooking'] = 'Cuisine'
    L['Professions'] = 'Métiers'
    L['Profession1'] = 'Métier 1'
    L['Profession2'] = 'Métier 2'
    L['Profiles'] = 'Profiles'
    L['Profile'] = 'Profile'
    L['Chat'] = 'Chat'
    L['Statistics'] = 'Statistiques'
    L['Calendar'] = 'Calendrier'
    L['GuildBank'] = 'Banque de guilde'
    L['EditCharacterInfo'] = 'Les information à propos de votre personnage devrait être affiché ci-dessous, réglez votre spécialisation et votre personnage principale pour un alt.\nCliquez sur Confirme pour partager avec votre guilde.'
    L['SaveCharacterData'] = 'Confirme'
    L['MainCharacterNameInputDesc'] = 'Personnage principale'
    L['MainCharacter'] = 'Personnage principale'
    L['Gems'] = 'Gemmes'
    L['Enchants'] = 'Enchantements'
    L['ilvl'] = 'ilvl'
    L['Guild Information'] = 'Information de guilde'
    L['ClassRolesSummary'] = 'Résumé de classes & roles'
    L['RaidRoster'] = 'Raid Roster |cffffffff(Click droit sur un joueur pour les options)|r'
    L['Cancel'] = 'Annulé'
    L['GuildBank'] = 'Banque de guilde'

    --professions
    L['Alchemy'] = "Alchimie"
    L["Blacksmithing"] = "Forge"
    L["Enchanting"] = "Enchantement"
    L["Engineering"] = "Ingénierie"
    --['Inscription'] = 'Inscription',
    --['Jewelcrafting'] = 'Joaillerie',
    L['Tailoring'] = "Couture"
    L['Leatherworking'] = "Travail du cuir"
    L['Herbalism'] = "Herboristerie"
    L['Skinning'] = "Dépeçage"
    L['Mining'] = "Minage"
    L['First Aid'] = 'Secourisme'
    L['Fishing'] = 'Pêche'
    L['Cooking'] = 'Cuisine'
    
    -- class and spec
    L['DEATHKNIGHT'] = 'Deathknight'
    L['DRUID'] = 'Druide'
    L['HUNTER'] = 'Chasseur'
    L['MAGE'] = 'Mage'
    L['PALADIN'] = 'Paladin'
    L['PRIEST'] = 'Prêtre'
    L['SHAMAN'] = 'Chaman'
    L['ROGUE'] = 'Voleur'
    L['WARLOCK'] = 'Démoniste'
    L['WARRIOR'] = 'Guerrier'
    --mage/dk
    L['Arcane'] = 'Arcane'
    L['Fire'] = 'Feu'
    L['Frost'] = 'Givre'
    L['Blood'] = 'Blood'
    L['Unholy'] = 'Unholy'
    --druid/shaman
    L['Restoration'] = 'Restoration'
    L['Enhancement'] = 'Amélioration'
    L['Elemental'] = 'Elémentaire'
    L['Cat'] = 'Félin'
    L['Bear'] = 'Ours'
    L['Balance'] = 'Equilibre'
    --rogue
    L['Assassination'] = 'Assassination'
    L['Combat'] = 'Combat'
    L['Subtlety'] = 'Finesse'
    --hunter
    L['Marksmanship'] = 'Précision'
    L['Beast Master'] = 'Maîtrise des bêtes'
    L['Survival'] = 'Survie'
    --warlock
    L['Destruction'] = 'Destruction'
    L['Affliction'] = 'Affliction'
    L['Demonology'] = 'Démonologie'
    --warrior/paladin/priest
    L['Fury'] = 'Fureur'
    L['Arms'] = 'Armes'
    L['Protection'] = 'Protection'
    L['Retribution'] = 'Vindicte'
    L['Holy'] = 'Sacré'
    L['Discipline'] = 'Discipline'
    L['Shadow'] = 'Ombre'


end




Guildbook.Locales = L

Guildbook.AvailableLocales = {
    ['enUS'] = true,
    ['deDE'] = true,
    ['frFR'] = true,
}

-- this will be a lookup table to convert to english for function args etc
if Guildbook.AvailableLocales[locale] then
    Guildbook.GetEnglish = {}
    for k, v in pairs(L) do
        Guildbook.GetEnglish[v] = k
    end
end


Guildbook.ProfessionNames = {
	enUS = {
		[129] = "First Aid",
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
	},
	deDE = {
		[129] = "Erste Hilfe",
		[164] = "Schmiedekunst",
		[165] = "Lederverarbeitung",
		[171] = "Alchemie",
		[182] = "Kräuterkunde",
		[185] = "Kochkunst",
		[186] = "Bergbau",
		[197] = "Schneiderei",
		[202] = "Ingenieurskunst",
		[333] = "Verzauberkunst",
		[356] = "Angeln",
		[393] = "Kürschnerei",
		[755] = "Juwelierskunst",
		[773] = "Inschriftenkunde",
	},
	frFR = {
		[129] = "Secourisme",
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
