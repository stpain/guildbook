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

-- buttons, labels and texts NEED TO GO THROUGH THESE AND REMOVE OLD STRINGS

L['OptionsAbout'] = 'Guildbook options and about.'
L['Version'] = 'Version'
L['Author'] = 'Author: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'


L["GUILDBOOK_LOADER_HEADER"]        = "Welcome to Guildbook"
L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "Used for the following"

--mod blizz stuff
L['Online'] = 'Online'
L['MainSpec'] = 'Main Spec'
L['Rank'] = 'Rank'
L['Note'] = 'Note'
L['Profession1'] = 'Profession 1'
L['Profession2'] = 'Profession 2'


-- roster listview and tooltip
L["name"]                           = "Name"
L["level"]                          = "Level"
L["mainSpec"]                       = "Main Spec"
L["prof1"]                          = "Trade"
L["location"]                       = "Location"
L["rankName"]                       = "Rank"
L["publicNote"]                     = "Public Note"
L["class"]                          = "Class"
L["attunements"]                    = "Attunements"


-- xml strings
L["PROFILE_TITLE"]                  = "Profile"
L["REAL_NAME"]                      = "Name"
L["REAL_DOB"]                       = "Birthday"
L["REAL_BIO"]                       = "Bio"
L["AVATAR"]                         = "Avatar"
L["MAIN_CHARACTER"]                 = "Main character"
L["MAIN_SPEC"]                      = "Main spec"
L["OFF_SPEC"]                       = "Off spec"
L["PRIVACY"]                        = "Privacy"
L["PRIVACY_ABOUT"]                  = "Set the lowest rank you wish to share data with."
L["INVENTORY"]                      = "Inventory"
L["TALENTS"]                        = "Talents"

L["PROFILES"]                       = "Profiles"
L["TRADESKILLS"]                    = "Tradeskills (Professions)"
L["CHAT"]                           = "Chat"
L["ROSTER"]                         = "Roster"
L["CALENDAR"]                       = "Calendar"
L["SEARCH"]                         = "Search"
L["MY_PROFILE"]                     = "My profile"
L["OPEN_PROFILE"]                   = "Open profile"
L["OPEN_CHAT"]                      = "Open chat"
L["INVITE_TO_GROUP"]                = "Invite to group"
L["SEND_TRADE_ENQUIRY"]             = "Send message about item"
L["REFRESH_ROSTER"]                 = "Refresh roster"
L["EDIT"]                           = "Edit profile"
L["GUILD_BANK"]                     = "Guild bank (Legacy feature)"
L["ALTS"]                           = "Alt characters"
L["USE_MAIN_PROFILE"]               = "Use main character profile"
L["MY_SACKS"]                       = "My containers"
L["BAGS"]                           = "Bags"
L["BANK"]                           = "Bank"
L["STATS"]                          = "Statistics"

L["PRIVACY_HEADER"]                 = "Privacy settings"

--dialog strings
L["SCANNING_TRADESKILL_DATA"]       = "Scanning recipes\n\n"
L["SEND_TRADESKILL_DATA_WARNING"]   = "\n\n|cffC41F3BWARNING - this option should only be used when necessary, it could cause issues for addons if the chat message system is abused!"

-- class and spec
L['DEATHKNIGHT']                    = 'Deathknight'
L['DRUID']                          = 'Druid'
L['HUNTER']                         = 'Hunter'
L['MAGE']                           = 'Mage'
L['PALADIN']                        = 'Paladin'
L['PRIEST']                         = 'Priest'
L['SHAMAN']                         = 'Shaman'
L['ROGUE']                          = 'Rogue'
L['WARLOCK']                        = 'Warlock'
L['WARRIOR']                        = 'Warrior'
--mage/dk
L['Arcane']                         = 'Arcane'
L['Fire']                           = 'Fire'
L['Frost']                          = 'Frost'
L['Blood']                          = 'Blood'
L['Unholy']                         = 'Unholy'
--druid/shaman
L['Restoration']                    = 'Restoration'
L['Enhancement']                    = 'Enhancement'
L['Elemental']                      = 'Elemental'
L['Cat']                            = 'Cat'
L['Bear']                           = 'Bear'
L['Balance']                        = 'Balance'
--rogue
L['Assassination']                  = 'Assassination'
L['Combat']                         = 'Combat'
L['Subtlety']                       = 'Subtlety'
--hunter
L['Marksmanship']                   = 'Marksmanship'
L['Beast Master']                   = 'Beast Master'
L['Survival']                       = 'Survival'
--warlock
L['Destruction']                    = 'Destruction'
L['Affliction']                     = 'Affliction'
L['Demonology']                     = 'Demonology'
--warrior/paladin/priest
L['Fury']                           = 'Fury'
L['Arms']                           = 'Arms'
L['Protection']                     = 'Protection'
L['Retribution']                    = 'Retribution'
L['Holy']                           = 'Holy'
L['Discipline']                     = 'Discipline'
L['Shadow']                         = 'Shadow'

--date time
L['January']                        = 'January'
L['February']                       = 'February'
L['March']                          = 'March'
L['April']                          = 'April'
L['May']                            = 'May'
L['June']                           = 'June'
L['July']                           = 'July'
L['August']                         = 'August'
L['September']                      = 'September'
L['October']                        = 'October'
L['November']                       = 'November'
L['December']                       = 'December'

-- L['GuildBank'] = 'Guild Bank'
-- L['Events'] = 'Events'
-- L['WorldEvents'] = 'World Events'
-- L['Attunements'] = 'Attunements'
-- L["Guild"] = "Guild"


-- L['Roles'] = 'Roles'
-- L['Tank'] = 'Tank'
-- L['Melee'] = 'Melee'
-- L['Ranged'] = 'Ranged'
-- L['Healer'] = 'Healer'
-- L['ClassRoleSummary'] = 'Class & Role Summary'
-- L['RoleChart'] = 'Roles (Online Members)'
-- L['ClassChart'] = 'Classes (All Members)'

--------------------------------------------------------------------------------------------
-- help text tooltips
--------------------------------------------------------------------------------------------
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
    L['OptionsAbout'] = 'Guildbook erlaubt es Spielern, mehrere Informationen mit ihren Gildenmitgliedern zu teilen. Nutze die unten aufgeführten Optionen, um deine Charakter-Ausrichtung/Twinks für deinen Charakter zu setzen.'
    L['Summary'] = 'Zusammenfassung'
    L['SummaryHeader'] = 'Gildenübersicht'
    L['Roster'] = 'Roster'
    L['CharacterLevel'] = 'Charakter Level'
    L['Name'] = 'Name'
    L['Roles'] = 'Rolle(n)'
    L['Tank'] = 'Tank'
    L['Melee'] = 'Nahkampf'
    L['Ranged'] = 'Fernkampf'
    L['Healer'] = 'Heiler'
    L['ClassRoleSummary'] = 'Klassen- & Rollenzusammenfassung'
    L['RoleChart'] = 'Rollen (Online Mitglieder)'
    L['ClassChart'] = 'Klassen (Alle Mitglieder)'
    L['Online'] = 'Online'
    L['Offline'] = 'Offline'
    L['SearchFor'] = 'Suche...'
    L['Info'] = 'Info'
    L['Specializations'] = 'Spezialisierung'
    L['ItemLevel'] = 'Item Level'
    L['MainSpec'] = 'Main Spec'
    L['Main'] = 'Main:'
    L['Rank'] = 'Rang'
    L['Note'] = 'Notiz'
    L['OffSpec'] = 'Off Spec:'
    L['IsPvpSpec'] = '  PVP'
    L['Class'] = 'Klasse'
    L['FirstAid'] = 'Erste Hilfe'
    L['Fishing'] = 'Angeln'
    L['Cooking'] = 'Kochkunst'
    L['Professions'] = 'Fertigkeiten'
    L['Profession1'] = 'Beruf 1'
    L['Profession2'] = 'Beruf 2'
    L['Profiles'] = 'Profile'
    L['Profile'] = 'Profil'
    L['Chat'] = 'Chat'
    L['Statistics'] = 'Statistik'
    L['Calendar'] = 'Kalender'
    L['GuildBank'] = 'Gildenbank'
    L['EditCharacterInfo'] = 'Deine Charakter Informationen sollten unten eingeblendet sein. Aktualisiere deine Spezialisierungen und - falls dies ein Twink ist - gib den Namen deines Mainchars an.\nDrücke <Bestätigen>, um die Informationen mit der Gilde zu teilen.'
    L['SaveCharacterData'] = 'Bestätigen'
    L['MainCharacterNameInputDesc'] = 'Main Char'
    L['MainCharacter'] = 'Main Char'
    L['Gems'] = 'Gems'
    L['Enchants'] = 'Verzauberungen'
    L['ilvl'] = 'ilvl'
    L['Guild Information'] = 'Gilden Information'
    L['ClassRolesSummary'] = 'Klassen- & Rollenzusammenfassung'
    L['RaidRoster'] = 'Raid Roster |cffffffff(Rechtsklick auf einen Spieler für mehr Optionen.)|r'
    L['Cancel'] = 'Abbrechen'
    L['GuildBank'] = 'Gildenbank'

    --professions
    L['Alchemy'] = "Alchimie"
    L["Blacksmithing"] = "Schmiedekunst"
    L["Enchanting"] = "Verzauberkunst"
    L["Engineering"] = "Ingenieurskunst"
    --['Inscription'] = 'Inscription',
    L['Jewelcrafting'] = 'Juwelenschleifen'
    L['Tailoring'] = "Schneiderei"
    L['Leatheroworking'] = "Lederverarbeitung"
    L['Herbalism'] = "Kräuterkunde"
    L['Skinning'] = "Kürschnerei"
    L['Mining'] = "Bergbau"
    L['First Aid'] = 'Erste Hilfe'
    L['Fishing'] = 'Angeln'
    L['Cooking'] = 'Kochkunst'

    -- class and spec
    L['DEATHKNIGHT'] = 'Todesritter'
    L['DRUID'] = 'Druide'
    L['HUNTER'] = 'Jäger'
    L['MAGE'] = 'Magíer'
    L['PALADIN'] = 'Paladin'
    L['PRIEST'] = 'Priester'
    L['SHAMAN'] = 'Schamane'
    L['ROGUE'] = 'Schurke'
    L['WARLOCK'] = 'Hexenmeister'
    L['WARRIOR'] = 'Krieger'
    --mage/dk
    L['Arcane'] = 'Arkan'
    L['Fire'] = 'Feuer'
    L['Frost'] = 'Frost'
    L['Blood'] = 'Blut'
    L['Unholy'] = 'Unheilig'
    --druid/shaman
    L['Restoration'] = 'Wiederherst.'
    L['Enhancement'] = 'Verstärk.'
    L['Elemental'] = 'Elementar.'
    L['Cat'] = 'Katze'
    L['Bear'] = 'Bär'
	L['Feral Combat'] = 'Wilder Kampf'
    L['Balance'] = 'Gleichgewicht'
    --rogue
    L['Assassination'] = 'Meucheln'
    L['Combat'] = 'Kampf'
    L['Subtlety'] = 'Täuschung'
    --hunter
    L['Marksmanship'] = 'Treffsicherheit'
    L['Beast Master'] = 'Tierherrschaft'
    L['Survival'] = 'Überleben'
    --warlock
    L['Destruction'] = 'Zerstörung'
    L['Affliction'] = 'Gebrechen'
    L['Demonology'] = 'Dämonologie'
    --warrior/paladin/priest
    L['Fury'] = 'Furor'
    L['Arms'] = 'Waffen'
    L['Protection'] = 'Schutz'
    L['Retribution'] = 'Vergeltung'
    L['Holy'] = 'Heilig'
    L['Discipline'] = 'Disziplin'
    L['Shadow'] = 'Schatten'




--[[
    french
]]
elseif locale == 'frFR' then

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
    L["Blacksmithing"] = "Forge"
    L["Enchanting"] = "Enchantement"
    L["Engineering"] = "Ingénierie"
    --['Inscription'] = 'Inscription',
    --['Jewelcrafting'] = 'Jewelcrafting',
    L['Tailoring'] = "Couturier"
    L['Leatheroworking'] = "Travail du cuir"
    L['Herbalism'] = "Herboristerie"
    L['Skinning'] = "Dépecage"
    L['Mining'] = "Minage"
    L['First Aid'] = 'Secourisme'
    L['Fishing'] = 'Pêche'
    L['Cooking'] = 'Cuisine'
    
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


-- these were taken from the game however some seem to be incorrect so any fixes please post on the curse page for others to see (and me)
Guildbook.ProfessionNames = {
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


-- key binding header
BINDING_HEADER_GENERAL = "General"
BINDING_CATEGORY_GUILDBOOK = "Guildbook"