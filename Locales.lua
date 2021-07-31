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

-- add this to proper helpAbout section when finished 
--Written by Kylanda@Pyrewood Village, translations
--French, Belrand@Auberdine

local addonName, Guildbook = ...

-- locales table
local L = {}

--options page
L['OptionsAbout'] = 'Guildbook options and about. Thanks to Belrand@Auberdine for the French translations'
L['Version'] = 'Version'
L['Author'] = 'Author: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'



L["NEW_VERSION_1"] = "new version available, probably fixes a few things, might break something else though!"
L["NEW_VERSION_2"] = "there is a totally new awesome version of guildbook, available to downlaod from all good addon providers!"
L["NEW_VERSION_3"] = "lol, if you thought the last update did not a lot, you should get the new one, probably does about the same.....or less!"
L["NEW_VERSION_4"] = "hordies are red, alliance are blue, guildbook updates just for you!"

L["GUILDBOOK_DATA_SHARE_HEADER"]	= "Guildbook data share \n\nYou can share your tradeskill data by clicking export to generate a data string. Then copy/paste this to somewhere like discord. \nTo import tradeskill data paste a data string into the box below and click import."
L["GUILDBOOK_LOADER_HEADER"]        = "Welcome to Guildbook"
L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "Used for the following"

L["HELP_ABOUT"]						= "Help & about"

-- this is just a quick thing, will make the how section more fleshed out
-- this is a nasty way to do this, its horrible and i need to make the help & about much better
local slashCommandsIcon = CreateTextureMarkup(136377, 64, 64, 16, 16, 0, 1, 0, 1, 0, 0)
local slashCommandsHelp = [[
Slash commands:
/guildbook open - this will open Guildbook
/guildbook [interface] - this will open to a specific area (roster, tradeskills, chat, profiles, calendar, stats, guildbank, search, privacy)

]]
local tradeskillIcon = CreateAtlasMarkup("Mobile-Blacksmithing", 16, 16)
local tradeskillHelp = 
[[
Tradeskills (Professions):
Guildbook will share your tradeskill recipes with other guild members. 
Open your tradeskill to trigger the scan of the recipes. Wait patiently as it scans (~100 recipes per second). This will save to your character and account database for the guild and sends to online guild members. 
Once this process is complete, future data will be sent to all online guild members when you log in. You can also push data by opening a tradeskill (cooldown enabled to prevent spam).
If you need to share recipes from an offline guild member, select their tradeskill from the roster, once loaded click the button in the top right of the recipes listview (cooldown enabled to prevent spam).

]]
local profileIcon = CreateAtlasMarkup("GarrMission_MissionIcon-Recruit", 16, 16)
local profileHelp = 
[[
Profile:
Edit as you wish, add your personal information or not.
Show your main spec, list your alts.

]]
local searchIcon = CreateAtlasMarkup("shop-games-magnifyingglass", 16, 16)
local searchHelp = 
[[
Search:
Use this feature to browse your guild database- Find a recipe, pattern, character name.

]]
local bankIcon = CreateAtlasMarkup("ShipMissionIcon-Treasure-Map", 16, 16)
local bankHelp = [[
Guild bank:
The guild bank feature works using a commit system, whenever a guildbank character views their bank, the data is sent to all online guild members as a 'commit'. When you view the guild bank, Guildbook will send a request to online guild members for their commit timestamp and then select the member with the latest commit.
Guildbook then sends a request to that member for the commit data.

As this process involves a lot of comms, there is a cooldown of 30s between requesting bank data, and the request process is staggered so that comms messages dont cause issues for other addons.
]]
L["HELP_ABOUT_CREDITS"]				= string.format("%s %s %s %s %s %s %s %s %s %s", slashCommandsIcon, slashCommandsHelp, tradeskillIcon, tradeskillHelp, profileIcon, profileHelp, searchIcon, searchHelp, bankIcon, bankHelp)



--mod blizz guild roster, these are key/values in the ModBlizz file that add extra columns
L['Online']                         = 'Online'
L['MainSpec']                       = 'Main Spec'
L['Rank']                           = 'Rank'
L['Note']                           = 'Note'
L['Profession1']                    = 'Profession 1'
L['Profession2']                    = 'Profession 2'


-- roster listview and tooltip, these are also sort keys and should be lower case
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
L["ALT_CHARACTERS"]                 = "Alt characters"
L["MAIN_SPEC"]                      = "Main spec"
L["OFF_SPEC"]                       = "Off spec"
L["PRIVACY"]                        = "Privacy"
L["PRIVACY_ABOUT"]                  = "Set the lowest rank you wish to share data with."
L["INVENTORY"]                      = "Inventory"
L["TALENTS"]                        = "Talents"

L["ROSTER_ALL_CLASSES"]				= "All"
L["ROSTER_ALL_RANKS"]				= "All"

L["TRADESKILLS"]					= "Professions"
L["TRADESKILLS_RECIPES"]			= "Recipes"
L["TRADESKILLS_CHARACTERS"]			= "Characters"
L["TRADESKILL_GUILD_RECIPES"]		= "Guild Recipes"
L["TRADESKILLS_SHARE_RECIPES"]		= "Share this characters recipes"
L["TRADESKILLS_EXPORT_RECIPES"]		= "Import or export tradeskill data"

L['GUILDBANK']						= "Guild bank"
L["GUILDBANK_HEADER_ITEM"]			= "Item link"
L["GUILDBANK_HEADER_COUNT"]			= "Count"
L["GUILDBANK_SORT_TYPE"]			= "Type"
L["GUILDBANK_HEADER_SUBTYPE"]		= "Subtype"
L["GUILDBANK_SORT_BANK"]			= "Source"
L["GUILDBANK_REFRESH"]				= "Refresh"
L["GUILDBANK_ALL_BANKS"]			= "All banks"
L["GUILDBANK_ALL_TYPES"]			= "All types"
L["GUILDBANK_REQUEST_COMMITS"]		= "requesting commits for "
L["GUILDBANK_REQUEST_INFO"]			= "requesting data from "
L["GUILDBANK_FUNDS"]				= "Gold available"
L["GUILDBANK_CURRENCY"]				= "Currency"

L["PROFILES"]                       = "Profiles"
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

L["RESET_AVATAR"]					= "Reset avatar"

L["PRIVACY_HEADER"]                 = "Privacy settings"

--attributes
L["STRENGTH"]						= "Strength"
L["AGILITY"]						= "Agility"
L["STAMINA"]						= "Stamina"
L["INTELLECT"]						= "Intellect"
L["SPIRIT"]							= "Spirit"
--defence
L["ARMOR"]							= "Armor"
L["DEFENSE"]						= "Defence"
L["DODGE"]							= "Dodge"
L["PARRY"]							= "Parry"
L["BLOCK"]							= "Block"
--melee
L["EXPERTISE"]						= "Expertise"
L["HIT_CHANCE"]						= "Hit"
L["MELEE_CRIT"]						= "Crit"
L["MH_DMG"]							= "Main hand dmg"
L["OH_DMG"] 						= "Off hand dmg"
L["MH_DPS"] 						= "Main hand dps"
L["OH_DPS"] 						= "Off hand dps"
--ranged
L["RANGED_HIT"] 					= "Hit"
L["RANGED_CRIT"] 					= "Crit"
L["RANGED_DMG"] 					= "Damage"
L["RANGED_DPS"] 					= "Dps"
--spells
L["SPELL_HASTE"] 					= "Haste"
L["MANA_REGEN"] 					= "Mana Regen"
L["MANA_REGEN_CASTING"] 			= "Mana Regen (casting)"
L["SPELL_HIT"] 						= "Hit"
L["SPELL_CRIT"] 					= "Crit"
L["HEALING_BONUS"] 					= "Healing bonus"
L["SPELL_DMG_HOLY"] 				= "Holy"
L["SPELL_DMG_FROST"] 				= "Frost"
L["SPELL_DMG_SHADOW"] 				= "Shadow"
L["SPELL_DMG_ARCANE"] 				= "Arcane"
L["SPELL_DMG_FIRE"] 				= "Fire"
L["SPELL_DMG_NATURE"] 				= "Nature"



-- class and spec
-- class is upper case
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
L["Warden"]							= "Warden"
L['Cat']                            = 'Cat'
L['Bear']                           = 'Bear'
L['Balance']                        = 'Balance'
L['Guardian']                       = 'Guardian'
L["Feral"]							= "Feral"
--rogue
L['Assassination']                  = 'Assassination'
L['Combat']                         = 'Combat'
L['Subtlety']                       = 'Subtlety'
--hunter
L['Marksmanship']                   = 'Marksmanship'
L['Beast Master']                   = 'Beast Master'
L['BeastMaster']                   	= 'Beast Master' -- the smart detect spec system could return this value
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
L['JANUARY']                        = 'January'
L['FEBRUARY']                       = 'February'
L['MARCH']                          = 'March'
L['APRIL']                          = 'April'
L['MAY']                            = 'May'
L['JUNE']                           = 'June'
L['JULY']                           = 'July'
L['AUGUST']                         = 'August'
L['SEPTEMBER']                      = 'September'
L['OCTOBER']                        = 'October'
L['NOVEMBER']                       = 'November'
L['DECEMBER']                       = 'December'

L["MONDAY"]			    			= "Monday"
L["TUESDAY"]			    		= "Tuesday"
L["WEDNESDAY"]			    		= "Wednesday"
L["THURSDAY"]			    		= "Thursday"
L["FRIDAY"]			   				= "Friday"
L["SATURDAY"]			    		= "Saturday"
L["SUNDAY"]			    			= "Sunday"


-- old stuff but might use again
L['GuildBank']                      = 'Guild Bank'
L['Events']                         = 'Events'
L['WorldEvents']                    = 'World Events'
L['Attunements']                    = 'Attunements'
L["Guild"]                          = "Guild"


L['Roles']                          = 'Roles'
L['Tank']                           = 'Tank'
L['Melee']                          = 'Melee'
L['Ranged']                         = 'Ranged'
L['Healer']                         = 'Healer'
L['ClassRoleSummary']               = 'Class & Role Summary'
L['RoleChart']                      = 'Roles (Online Members)'
L['ClassChart']                     = 'Classes (All Members)'

-- calendar help icon
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

--guildbank help icon
L["GUILDBANKHELPTEXT"]	= [[
Guild Bank

|cffffffffGuildbook provides an in-game guild bank for guild 
to share bank character's inventory.
|r

|cff00BFF3To use the Guild Bank, add the word 'Guildbank'
to the Public Note of the character being used as a bank
(this will add them to the dropdown menu).
Said character must then open his bank 
to sync his inventory with connected Guild Members.

The guild bank sends/receives data when a player logs in, 
only the most recent data is being used, thus bank characters
should sync their inventory after every change within it.

Multiple bank characters are supported.|r
]]


--legacy stuff
L["SELECT_BANK_CHARACTER"]          = "Select bank character"
L["DUNGEON"]                        = "Dungeon"
L["RAID"]                           = "Raid"
L['PVP']							= 'PVP'
L["MEETING"]                        = "Meeting"
L["OTHER"]                          = "Other"
L["GUILD_CALENDAR"]                 = "Guild Calendar"
L["INSTANCE_LOCKS"]                 = "Instance locks"
L["CREATE_EVENT"]                   = "Create event"
L["DELETE_EVENT"]                   = "Delete event"
L["EVENT"]                          = "Event"
L["EVENT_TYPE"]                     = "Event type"
L["TITLE"]                          = "Title"
L["DESCRIPTION"]                    = "Description"
L["UPDATE"]                         = "Update"
L["ATTENDING"]                      = "Attending"
L["TENTATIVE"]                      = "Tentative"
L["DECLINE"]                        = "Decline"

L["YEARS"]                          = "years"
L["MONTHS"]                         = "months"
L["DAYS"]                           = "days"
L["HOURS"]                          = "hours"
L['< an hour']			    		= '< an hour'

L["GENERAL"]			    		= "General"
L["MINIMAP_TOOLTIP_LEFTCLICK"]		= '|cffffffffLeft Click|r Open Guildbook'
L["MINIMAP_TOOLTIP_LEFTCLICK_SHIFT"]= "Shift + "..'|cffffffffLeft Click|r Open Chat'
L["MINIMAP_TOOLTIP_RIGHTCLICK"]		= '|cffffffffRight Click|r Options'
L["MINIMAP_TOOLTIP_MIDDLECLICK"]	= "|cffffffffMiddle Click|r Open Blizzard roster"

L["MC"]								= "Molten Core"
L["BWL"]							= "Blackwing Lair"
L["AQ20"]                           = "AQ20"
L["AQ40"]							= "AQ40"
L["Naxxramas"]						= "Naxxramas"
L["ZG"]								= "Zul'Gurub"
L["Onyxia"]							= "Onyxia"
L["Magtheridon"]					= "Magtheridon's Lair"
L["SSC"]							= "Serpentshrine Cavern"
L["TK"]								= "Tempest Keep"
L["Gruul"]							= "Gruul's Lair"
L["Hyjal"]							= "Hyjal Summit"
L["SWP"]							= "Sunwell Plateau"
L["BT"]								= "Black Temple"
L["Karazhan"]						= "Karazhan"

--availability (Data.lua)
L['Not Available'] 					= 'Not Available'
L['Morning'] 						= 'Morning'
L['Afternoon'] 						= 'Afternoon'
L['Evening'] 						= 'Evening'

--world events
L["DARKMOON_FAIRE"]					= "Darkmoon Faire"
L["DMF display"]					= '|cffffffffDarkmoon Faire - ' --this is needed for the calendar
L["LOVE IS IN THE AIR"]				= "Love is in the air"
L["CHILDRENS_WEEK"]					= "Children's Week"				
L["MIDSUMMER_FIRE_FESTIVAL"]		= "Midsummer Fire Festival"
L["HARVEST_FESTIVAL"]				= "Harvest Festival"
L["HALLOWS_END"]					= "Hallows End"
L["FEAST_OF_WINTER_VEIL"]			= "Feast of Winter Veil"

-- grab the clients locale
local locale = GetLocale()

--[[
    german  - this needs to be updated
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

    L['OptionsAbout'] = 'Guildbook options et informations. Traduction française par Belrand@Auberdine'
	L['Version'] = 'Version'
	L['Author'] = 'Auteur: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff) |r'
		
	L["NEW_VERSION_1"] = "Une nouvelle version est disponible, probablement pour réparer certaines choses...ou en casser d'autres!"
	L["NEW_VERSION_2"] = "Il y a une nouvelle version de Guildbook, disponible en téléchargement chez tous les bons distributeurs d'Addons!"
	L["NEW_VERSION_3"] = "Haha, si vous pensiez que la dernière MàJ ne changeait pas grand chose, vous devriez télécharger la nouvelle, elle fera probablement la même chose...ou moins!"
	L["NEW_VERSION_4"] = "La Horde est rouge, l'Alliance est bleue, télécharge la nouvelle mise à jour sale paresseux!"

	L["GUILDBOOK_LOADER_HEADER"]        = "Bienvenue sur Guildbook"
	L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "Utilisé pour:"

	--mod blizz guild roster
	L['Online']                         = 'En Ligne'
	L['MainSpec']                       = 'Spé Principale'
	L['Rank']                           = 'Rang'
	L['Note']                           = 'Note'
	L['Profession1']                    = 'Métier 1'
	L['Profession2']                    = 'Métier 2'


	-- roster listview and tooltip, these are also sort keys hence the lowercase usage
	L["name"]                           = "Nom"
	L["level"]                          = "Niv."
	L["mainSpec"]                       = "Spé Principale"
	L["prof1"]                          = "Métiers"
	L["location"]                       = "Zone"
	L["rankName"]                       = "Rang"
	L["publicNote"]                     = "Note Publique"
	L["class"]                          = "Class." --this fit better but "Classe" is more appropriate
	L["attunements"]                    = "Accès"


	-- xml strings
	L["PROFILE_TITLE"]                  = "Profile"
	L["REAL_NAME"]                      = "Nom"
	L["REAL_DOB"]                       = "Anniversaire"
	L["REAL_BIO"]                       = "Biographie"
	L["AVATAR"]                         = "Avatar"
	L["MAIN_CHARACTER"]                 = "Personnage Principal"
	L["MAIN_SPEC"]                      = "Spé Principale"
	L["OFF_SPEC"]                       = "Spé Secondaire"
	L["PRIVACY"]                        = "Confidentialité"
	L["PRIVACY_ABOUT"]                  = "Choisir à partir de quel Rang vous souhaitez partager vos données."
	L["INVENTORY"]                      = "Inventaire"
	L["TALENTS"]                        = "Talents"

	L["PROFILES"]                       = "Profiles"
	L["TRADESKILLS"]                    = "Métiers (Recettes)"
	L["CHAT"]                           = "Chat"
	L["ROSTER"]                         = "Roster"
	L["CALENDAR"]                       = "Calendrier"
	L["SEARCH"]                         = "Rechercher"
	L["MY_PROFILE"]                     = "Mon profile"
	L["OPEN_PROFILE"]                   = "Ouvrir profile"
	L["OPEN_CHAT"]                      = "Ouvrir chat"
	L["INVITE_TO_GROUP"]                = "Inviter dans un groupe"
	L["SEND_TRADE_ENQUIRY"]             = "Envoyer un message à propos de l'objet"
	L["REFRESH_ROSTER"]                 = "Rafraîchir roster"
	L["EDIT"]                           = "Modifier profile"
	L["GUILD_BANK"]                     = "Banque de Guilde (Fonctionnalité héritée)"
	L["ALTS"]                           = "Personnages secondaires"
	L["USE_MAIN_PROFILE"]               = "Utiliser profil du Personnage Principal"
	L["MY_SACKS"]                       = "Mes sacs"
	L["BAGS"]                           = "Sacs"
	L["BANK"]                           = "Banque"
	L["STATS"]                          = "Statistiques"

	L["PRIVACY_HEADER"]                 = "Paramètres de confidentialité"

	-- class and spec
	L['DEATHKNIGHT']                    = 'Chevalier de la mort'
	L['DRUID']                          = 'Druide'
	L['HUNTER']                         = 'Chasseur'
	L['MAGE']                           = 'Mage'
	L['PALADIN']                        = 'Paladin'
	L['PRIEST']                         = 'Prêtre'
	L['SHAMAN']                         = 'Chaman'
	L['ROGUE']                          = 'Voleur'
	L['WARLOCK']                        = 'Démoniste'
	L['WARRIOR']                        = 'Guerrier'
	--mage/dk
	L['Arcane']                         = 'Arcane'
	L['Fire']                           = 'Feu'
	L['Frost']                          = 'Givre'
	L['Blood']                          = 'Sang'
	L['Unholy']                         = 'Impie'
	--druid/shaman
	L['Restoration']                    = 'Restauration'
	L['Enhancement']                    = 'Amélioration'
	L['Elemental']                      = 'Elémentaire'
	L["Warden"]			    = "Protecteur"
	L['Cat']                            = 'Chat'
	L['Bear']                           = 'Ours'
	L['Guardian']                       = 'Gardien'
	L['Balance']                        = 'Equilibre'
	L["Feral"]			    = "Farouche"
	--rogue
	L['Assassination']                  = 'Assassinat'
	L['Combat']                         = 'Combat'
	L['Subtlety']                       = 'Finesse'
	--hunter
	L['Marksmanship']                   = 'Précision'
	L['Beast Master']                   = 'Maîtrise des Bêtes'
	L['Survival']                       = 'Survie'
	--warlock
	L['Destruction']                    = 'Destruction'
	L['Affliction']                     = 'Affliction'
	L['Demonology']                     = 'Démonologie'
	--warrior/paladin/priest
	L['Fury']                           = 'Fureur'
	L['Arms']                           = 'Armes'
	L['Protection']                     = 'Protection'
	L['Retribution']                    = 'Vindicte'
	L['Holy']                           = 'Sacré'
	L['Discipline']                     = 'Discipline'
	L['Shadow']                         = 'Ombre'
		
	--attributes
	L["STRENGTH"]				= "Force"
	L["AGILITY"]				= "Agilité"
	L["STAMINA"]				= "Endurance"
	L["INTELLECT"]				= "Intelligence"
	L["SPIRIT"]				= "Esprit"
	--defence
	L["ARMOR"]				= "Armure"
	L["DEFENSE"]				= "Défense"
	L["DODGE"]				= "Esquive"
	L["PARRY"]				= "Parade"
	L["BLOCK"]				= "Blocage"
	--melee
	L["EXPERTISE"]				= "Expertise"
	L["HIT_CHANCE"]				= "Chance de toucher"
	L["MELEE_CRIT"]				= "Chance de crit"
	L["MH_DMG"]				= "Dégâts main droite"
	L["OH_DMG"]				= "Dégâts main gauche"
	L["MH_DPS"]				= "DPS main droite"
	L["OH_DPS"]				= "DPS main gauche"
	--ranged
	L["RANGED_HIT"]				= "Chance de toucher"
	L["RANGED_CRIT"]			= "Chance de crit"
	L["RANGED_DMG"]				= "Dégâts"
	L["RANGED_DPS"]				= "DPS"
	--spells
	L["SPELL_HASTE"]			= "Hâte"
	L["MANA_REGEN"]				= "Régen mana"
	L["MANA_REGEN_CASTING"] 		= "Régen mana(incantation)"
	L["SPELL_HIT"]				= "Chance de toucher"
	L["HEALING_BONUS"]			= "Pouvoir de guérison"
	L["SPELL_DMG_HOLY"]			= "Sacré"
	L["SPELL_DMG_FROST"]			= "Givre"
	L["SPELL_DMG_SHADOW"]			= "Ombre"
	L["SPELL_DMG_ARCANE"]			= "Arcane"
	L["SPELL_DMG_FIRE"]			= "Feu"
	L["SPELL_DMG_NATURE"]			= "Nature"

	--date time
	L['JANUARY']                        = 'Janvier'
	L['FEBRUARY']                       = 'Février'
	L['MARCH']                          = 'Mars'
	L['APRIL']                          = 'Avril'
	L['MAY']                            = 'Mai'
	L['JUNE']                           = 'Juin'
	L['JULY']                           = 'Juillet'
	L['AUGUST']                         = 'Août'
	L['SEPTEMBER']                      = 'Septembre'
	L['OCTOBER']                        = 'Octobre'
	L['NOVEMBER']                       = 'Novembre'
	L['DECEMBER']                       = 'Décembre'
	
	L["MONDAY"]                         = "Lundi"
	L["TUESDAY"]                        = "Mardi"
	L["WEDNESDAY"]                      = "Mercredi"
	L["THURSDAY"]                       = "Jeudi"
	L["FRIDAY"]                         = "Vendredi"
	L["SATURDAY"]                       = "Samedi"
	L["SUNDAY"]                         = "Dimanche"
		
	L["YEARS"]                          = "années"
	L["MONTHS"]                         = "mois"
	L["DAYS"]                           = "jours"
	L['< an hour']			    = 'moins d\'1h'


	-- old stuff but might use again
	L['GuildBank']                      = 'Banque de Guilde'
	L['Events']                         = 'Evénements'
	L['WorldEvents']                    = 'Evénements mondiaux'
	L['Attunements']                    = 'Accès'
	L["Guild"]                          = "Guilde"


	L['Roles']                          = 'Rôles'
	L['Tank']                           = 'Tank'
	L['Melee']                          = 'Mêlée'
	L['Ranged']                         = 'Distance'
	L['Healer']                         = 'Soigneur'
	L['ClassRoleSummary']               = 'Classes & Rôles'
	L['RoleChart']                      = 'Rôles (Membres en ligne)'
	L['ClassChart']                     = 'Classes (Tous les Membres)'
	
	--legacy stuff
	L["SELECT_BANK_CHARACTER"]          = "Sélectionner la Banque"
	L["DUNGEON"]                        = "Donjon"
	L["RAID"]                           = "Raid"
	L['PVP']			    = 'JcJ'
	L["MEETING"]                        = "Réunion"
	L["OTHER"]                          = "Autre"
	L["GUILD_CALENDAR"]                 = "Calendrier de Guild"
	L["INSTANCE_LOCKS"]                 = "Instances verrouilées"
	L["CREATE_EVENT"]                   = "Créer événement"
	L["DELETE_EVENT"]                   = "Suppr. événement"
	L["EVENT"]                          = "Evénement"
	L["EVENT_TYPE"]                     = "Type d'événement"
	L["TITLE"]                          = "Titre"
	L["DESCRIPTION"]                    = "Description"
	L["UPDATE"]                         = "Mise à jour"
	L["ATTENDING"]                      = "Présent"
	L["TENTATIVE"]                      = "Tentative"
	L["DECLINE"]                        = "Décliner"
	L["RESET_AVATAR"]		    		= "Défaut"
	
	--keybinds
	L["GENERAL"]			    = "Général"
	L["OPEN"]			    = "Ouvrir"
	L["MINIMAP_TOOLTIP_LEFTCLICK"]			    = '|cffffffffClique Gauche|r Ouvrir Guildbook'
	L["MINIMAP_TOOLTIP_LEFTCLICK_SHIFT"]		    = "MAJ + "..'|cffffffffClique Gauche|r Open Chat'
	L["MINIMAP_TOOLTIP_RIGHTCLICK"]			    = '|cffffffffClique Droit|r Options'
	L["MINIMAP_TOOLTIP_MIDDLECLICK"]	= "|cffffffffMiddle Click|r Open Blizzard roster"
	
	--raids name
	L["MC"]				    = "Coeur du Magma"
	L["BWL"]			    = "Repaire de l'Aile noire"
	L["AQ20"]                           = "AQ20"
	L["AQ40"]			    = "AQ40"
	L["Naxxramas"]			    = "Naxxramas"
	L["ZG"]				    = "Zul'Gurub"
	L["Onyxia"]			    = "Onyxia"
	L["Magtheridon"]		    = "Repaire de Magtheridon"
	L["SSC"]			    = "Caverne du sanctuaire du Serpent" --this is way too long wtf
	L["TK"]				    = "Donjon de la tempête"
	L["Gruul"]			    = "Repaire de Gruul"
	L["Hyjal"]			    = "Sommet d'Hyjal"
	L["SWP"]			    = "Plateau du Puits de soleil"
	L["BT"]				    = "Temple noir"
	L["Karazhan"]			    = "Karazhan"
	
	--availability (Data.lua)
	L['Not Available'] 		    = 'Indisponible'
	L['Morning'] 			    = 'Matin'
	L['Afternoon'] 			    = 'Après-midi'
	L['Evening'] 			    = 'Soir'
	
	--world events
	L["DARKMOON_FAIRE"]		    = "Foire de Sombrelune"
	L["DMF display"]		    = '|cffffffffFoire de Sombrelune - '
	L["LOVE IS IN THE AIR"]		    = "De l'amour dans l'air"
	L["CHILDRENS_WEEK"]		    = "Semaine des enfants"				
	L["MIDSUMMER_FIRE_FESTIVAL"]	    = "Fête du Feu du solstice d'été"
	L["HARVEST_FESTIVAL"]		    = "Fête des moissons"
	L["HALLOWS_END"]		    = "Sanssaint "
	L["FEAST_OF_WINTER_VEIL"]	    = "Voile d'hiver"



	L['calendarHelpText'] = [[
Calendrier

|cffffffffGuildbook fournit un calendrier en jeu pour les guildes afin de
planifier des événements. Il est vaguement basé sur une ancienne version du
Calendrier Blizzard et fonctionne de manière similaire. Actuellement
jusqu'à 3 événements par jour seront affichés (une option pour en afficher 
plus sera ajoutée plus tard) sur les cases de la grille calendaire.|r

|cff00BFF3Le calendrier envoie/reçoit des données lorsqu'un joueur se connecte,
lorsqu'un événement est créé (ou supprimé) et lorsqu'un événement est modifié.
Les événements devraient se synchroniser avec les membres de la guilde,
mais cela n'est pas garanti car il repose sur une superposition suffisante 
entre les sessions des joueurs.

Les données envoyées sont limitées à 4 semaines pour réduire la demande sur 
les systèmes chat par l'addon, les événements peuvent être créés pour n'importe
quelle date et se synchroniseront dans les 4 semaines suivant la date actuelle|r.
]]


--guildbank help icon
	L["GUILDBANKHELPTEXT"]	= [[
Guild Bank

|cffffffffGuildbook fournit une banque de guilde en jeu 
pour paratager les inventaires de votre personnage banque.
|r

|cff00BFF3Pour utiliser la Banque de Guilde, ajouter le mot 
'Guildbank' à la note publique du personnage utilisé comme banque
(ceci va l'ajouter au menu déroulant).
Le dit personnage doit ensuite ouvrir sa banque pour lancer
la synchronisation de son inventaire avec 
les membres de la guilde connectés.

La Banque de Guilde envoie/reçoit des données quand un joueur
est en ligne, seul les données les plus récentes sont utilisées. 
Il est donc conseillé que les personnages banque fassent une
synchronisation de leur inventaire après chaque changement dedans.

De multiples personnages banques sont supportés.|r
]]

--[[ chinese
]]

elseif locale == "zhCN" then
	L['OptionsAbout'] = 'Guildbook 选项。 感谢 祈福@獅心洛薩 的中文翻译'
	L['Version'] = '版本'
	L['Author'] = '作者: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'

	L["GUILDBOOK_LOADER_HEADER"]        = "欢迎来到 Guildbook"
	L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "用于以下用途"

	--mod blizz guild roster
	L['Online']                         = '最后上线'
	L['MainSpec']                       = '主天赋'
	L['Rank']                           = '会阶'
	L['Note']                           = '备注'
	L['Profession1']                    = '专业 1'
	L['Profession2']                    = '专业 2'


	-- roster listview and tooltip, these are also sort keys hence the lowercase usage
	L["name"]                           = "名字"
	L["level"]                          = "等级"
	L["mainSpec"]                       = "主天赋"
	L["prof1"]                          = "专业"
	L["location"]                       = "地区"
	L["rankName"]                       = "会阶"
	L["publicNote"]                     = "备注"
	L["class"]                          = "职业"
	L["attunements"]                    = "Attunements"


	-- xml strings
	L["PROFILE_TITLE"]                  = "个人信息"
	L["REAL_NAME"]                      = "名字"
	L["REAL_DOB"]                       = "生日"
	L["REAL_BIO"]                       = "简介"
	L["AVATAR"]                         = "头像"
	L["MAIN_CHARACTER"]                 = "主角色"
	L["MAIN_SPEC"]                      = "主天赋"
	L["OFF_SPEC"]                       = "副天赋"
	L["PRIVACY"]                        = "隐私"
	L["PRIVACY_ABOUT"]                  = "设置您要与之共享数据的最低公会级别."
	L["INVENTORY"]                      = "装备"
	L["TALENTS"]                        = "天赋"

	L["PROFILES"]                       = "个人信息"
	L["TRADESKILLS"]                    = "商业技能（专业）"
	L["CHAT"]                           = "聊天"
	L["ROSTER"]                         = "名册"
	L["CALENDAR"]                       = "日历"
	L["SEARCH"]                         = "搜索"
	L["MY_PROFILE"]                     = "我的信息"
	L["OPEN_PROFILE"]                   = "打开个人信息"
	L["OPEN_CHAT"]                      = "打开聊天"
	L["INVITE_TO_GROUP"]                = "邀请"
	L["SEND_TRADE_ENQUIRY"]             = "询问关于此物品的信息"
	L["REFRESH_ROSTER"]                 = "刷新公会名册"
	L["EDIT"]                           = "编辑个人信息"
	L["GUILD_BANK"]                     = "公会银行（传统功能）"
	L["ALTS"]                           = "其他角色"
	L["USE_MAIN_PROFILE"]               = "使用主角色的个人信息"
	L["MY_SACKS"]                       = "我的背包（所有角色）"
	L["BAGS"]                           = "背包"
	L["BANK"]                           = "银行"
	L["STATS"]                          = "统计数据"

	L["PRIVACY_HEADER"]                 = "隐私设置"

	-- class and spec
	L['DEATHKNIGHT']                    = '死亡骑士'
	L['DRUID']                          = '德鲁伊'
	L['HUNTER']                         = '猎人'
	L['MAGE']                           = '法师'
	L['PALADIN']                        = '圣骑士'
	L['PRIEST']                         = '牧师'
	L['SHAMAN']                         = '萨满'
	L['ROGUE']                          = '潜行者'
	L['WARLOCK']                        = '术士'
	L['WARRIOR']                        = '战士'
	--mage/dk
	L['Arcane']                         = '奥术'
	L['Fire']                           = '火焰'
	L['Frost']                          = '冰霜'
	L['Blood']                          = '鲜血'
	L['Unholy']                         = '邪恶'
	--druid/shaman
	L['Restoration']                    = '恢复'
	L['Enhancement']                    = '增强'
	L['Elemental']                      = '元素'
	L['Cat']                            = '猫'
	L['Bear']                           = '熊'
	L['Balance']                        = '平衡'
	--rogue
	L['Assassination']                  = '奇袭'
	L['Combat']                         = '战斗'
	L['Subtlety']                       = '敏锐'
	--hunter
	L['Marksmanship']                   = '射击'
	L['Beast Master']                   = '野兽控制'
	L['Survival']                       = '生存'
	--warlock
	L['Destruction']                    = '毁灭'
	L['Affliction']                     = '痛苦'
	L['Demonology']                     = '恶魔学识'
	--warrior/paladin/priest
	L['Fury']                           = '狂怒'
	L['Arms']                           = '武器'
	L['Protection']                     = '防御'
	L['Retribution']                    = '惩戒'
	L['Holy']                           = '神圣'
	L['Discipline']                     = '戒律'
	L['Shadow']                         = '暗影'

	--date time
	L['January']                        = '一月'
	L['February']                       = '二月'
	L['March']                          = '三月'
	L['April']                          = '四月'
	L['May']                            = '五月'
	L['June']                           = '六月'
	L['July']                           = '七月'
	L['August']                         = '八月'
	L['September']                      = '九月'
	L['October']                        = '十月'
	L['November']                       = '十一月'
	L['December']                       = '十二月'


	-- old stuff but might use again
	L['GuildBank']                      = '公会银行'
	L['Events']                         = '活动'
	L['WorldEvents']                    = '世界活动'
	L['Attunements']                    = 'Attunements'
	L["Guild"]                          = "公会"


	L['Roles']                          = '职责'
	L['Tank']                           = '坦克'
	L['Melee']                          = 'Melee'
	L['Ranged']                         = '近战'
	L['Healer']                         = '治疗'
	L['ClassRoleSummary']               = '职业和角色摘要'
	L['RoleChart']                      = '职责（在线会员）'
	L['ClassChart']                     = '职业（所有成员）'

	-- calendar help icon
	L['calendarHelpText'] = [[
	Calendar

	|cffffffffGuildbook 为公会提供了一个游戏内日历来安排活动。 它基于旧版本的暴雪
	日历，并以类似的方式运行。 目前每天最多会显示 3 个事件（将添加访
	问更多选项）在当天的日历上。|r

	|cff00BFF3当玩家登录、创建或删除事件以及修改事件时，日历会发送/接收数据。事件应该
	与公会成员同步，尽管这不能保证,因为它依赖于玩家会话之间有足够的重叠。

	发送的数据限制为 4 周，以减少对插件聊天系统的需求，可以为任何日期创建事件，
	并在当前日期的 4 周内同步.|r
	]]


	--legacy stuff
	L["SELECT_BANK_CHARACTER"]          = "选择作为公会银行的角色"
	L["DUNGEON"]                        = "副本"
	L["RAID"]                           = "团队副本"
	L["MEETING"]                        = "会议"
	L["OTHER"]                          = "其他"
	L["GUILD_CALENDAR"]                 = "公会日历"
	L["INSTANCE_LOCKS"]                 = "副本进度"
	L["CREATE_EVENT"]                   = "创建活动"
	L["DELETE_EVENT"]                   = "删除活动"
	L["EVENT"]                          = "活动"
	L["EVENT_TYPE"]                     = "活动类型"
	L["TITLE"]                          = "标题"
	L["DESCRIPTION"]                    = "说明"
	L["UPDATE"]                         = "更新"
	L["ATTENDING"]                      = "参加"
	L["TENTATIVE"]                      = "替补"
	L["DECLINE"]                        = "退出"

	L["YEARS"]                          = "年"
	L["MONTHS"]                         = "月"
	L["DAYS"]                           = "天"
	L["HOURS"]                          = "小时"




end


Guildbook.Locales = L


-- these were taken from the game however some seem to be incorrect so any fixes please post on the curse page for others to see (and me)

-- first aid has a proper value but i dont know it so adding as -1
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
		--[-1] = "First Aid"
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
	-- discovered this locale exists also maybe esAL ?
	esES = {
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
--BINDING_HEADER_GENERAL = "General"
BINDING_CATEGORY_GUILDBOOK = "Guildbook"
BINDING_HEADER_GENERAL 	= L["GENERAL"]
BINDING_NAME_Open 	= L["OPEN"]
BINDING_NAME_Chat 	= L["CHAT"]
BINDING_NAME_Calendar 	= L["CALENDAR"]
