--[[
    this file will need to be translated with the help of the community

    if anyone modifies this could they please drop me a message on curse or git so i can include any translations

	I plan to move all locales inside the L table in time
]]


local addonName, addon = ...


--[[
	code:
		HT = helptip
		TT = tooltip
]]
local L = {

	--====================================================================================
	--ribbon
	--====================================================================================
	RIBBON_VIEW_HISTORY_BACK_TT = "Go back",
	GUIDE = "Guide (Instances)",

	--====================================================================================
	--profile (member details not guild treeview)
	--====================================================================================
	PROFILE_SIDEPANE_HT = "Character information such as name, main character, specialization and skills are listed here.\n\nYou can click on tradeskills to view available recipes.\n\nYou can select between the characters equipment and talents.\n\nAny alt characters are shown below.",
	PROFILE_INVENTORY_HT = "The characters resistances, auras and stats are shown here.\n\nThese might not be accurate at the time of viewing.\nBecause equipment and buffs (both personal and from others) can change stats/resistances, Guildbook will take a 'snapshot' of all these elements, this way you can relate the stats shown with the equipment/auras at the time.",

	--====================================================================================
	--tradeskills
	--====================================================================================
	TRADESKILLS_LISTVIEW_HT = "Select each profession to view craftable items.",
	TRADESKILLS_RECIPES_LISTVIEW_HT = "Recipes and reagents shown here.\n\nSelect a recipe to see who can craft it.",
	TRADESKILLS_CRAFTERS_LISTVIEW_HT = "Players able to craft an item will be listed here.",

	TRADESKILLS_RECIPES_SHOW_ITEMID_CB = "Show ItemID",

	--====================================================================================
	--guild bank
	--====================================================================================
	BANK_CHARACTER_LISTVIEW_HT = "Guild bank characters are listed here, select a character to view the bank items.\n\nYour own characters also show here so you can view personal bank/alt items.",
	BANK_CHARACTER_REFRESH_HT = "Click here to refresh the Guild bank data.\n\nThere will be a delay as each bank character's data gets requested. Guildbook will use the latest data available from players online.",

	--====================================================================================
	--settings
	--====================================================================================

	--character
	CHARACTER = "Character",
	SETTINGS_CHARACTER_GENERAL = "Set your characters specialization and if you have alts select which is your main.",
	SETTINGS_CHARACTER_TRADESKILLS = "%s\n\n%d recipe(s)",
	SETTINGS_CHARACTER_TRADESKILLS_MISSING_DATA = "No data found for profession.\n\nYou can either open your professions or right click for more options.",
	SETTINGS_CHARACTER_TRADESKILLS_HEADER = "Profession data and last sync times are shown below, right click for more options.",


	--guild
	SETTINGS_GUILD_MOD_BLIZZ_ROSTER = "Modify the default roster to show more info (requires UI reload to remove).",

	--tradeskills
	TRADESKILLS = "Tradeskills.",
	REAGENT = "Reagent",
	COUNT = "Count",
	SETTINGS_TRADESKILLS_GENERAL = "Show tooltip information for tradeskill items and reagents.",
	SETTINGS_TRADESKILLS_TT_RECIPE_INFO_ALL = "Show recipe info in the tooltip (all tradeskills).",
	SETTINGS_TRADESKILLS_TT_RECIPE_INFO_MY = "Show recipe info in the tooltip (only my tradeskills).",
	SETTINGS_TRADESKILLS_TT_REAGENT_FOR_ALL = "Show all recipes that can use an item in the tooltip.",
	SETTINGS_TRADESKILLS_TT_REAGENT_FOR_MY = "Show only my recipes that can use an item in the tooltip.",

	SETTINGS_TRADESKILLS_TT_RECIPE_INFO_HEADER = "Recipe reagent info",
	SETTINGS_TRADESKILLS_TT_REAGENT_FOR_HEADER = "This is a reagent for the following recipes.",

	--guild bank
	GUILDBANK = "Guild Bank",
	SETTINGS_GUILDBANK_GENERAL = "",

	--chat
	CHAT = "Chat",
	SETTINGS_CHAT_GENERAL = "Set the limits for your message history. Larger limits may cause issues on busy accounts.",

	--addon
	ADDON = "Addon",
	SETTINGS_ADDON_GENERAL = "Addon config options, if something goes wrong you can enable debug or reset the addon completely.",
	SETTINGS_ADDON_DEBUG_LABEL = "Debug",


	--\n|cffF52323Warning!
	--help
	SETTINGS_HELP_TEXT_GENERAL = "Welcome to Guildbook. This addon aims to provide guilds and their members a way to see, share and help each other. Features provided include character equipment and talents, tradeskills and available recipes. You can also see your characters instance reset data, information about alts and track dailies.\n\n|cffFFC000Things to get you started;|r\nSet main spec (found in Settings > Character)\nOpen your professions (including cooking and first aid)\nOpen your talents.",
	SETTINGS_HELP_TEXT_TRADESKILLS = string.format("%s |cffFFC000Tradeskills (Professions)|r\nIn order to share your recipes you'll need to open each of your professions, this will allow Guildbook to scan the available recipes and share with the other guild members (must be online).", CreateAtlasMarkup("Mobile-Blacksmithing", 26, 26, 0, 13)),
	SETTINGS_HELP_TEXT_TALENTS = string.format("%s |cffFFC000Talents|r\nFor guild members to view your characters spec/talents you'll need to open the talents interface. Guildbook will be able to scan your currently active spec and share this.", CreateAtlasMarkup("minortalents-icon-book", 26, 26, 0, 13)),
	SETTINGS_HELP_TEXT_DAILIES = string.format("%s |cffFFC000Dailies|r\nYou can track daily quest progress across your characters using Guildbook. The addon will learn daily quests as you find them, quests in green text are in your quest log, old hand in data is shown in grey, current quest turn in data is white.", CreateAtlasMarkup("QuestRepeatableTurnin", 26, 26, 0, 13)),
	SETTINGS_HELP_TEXT_ALTS = string.format("%s |cffFFC000Alts|r\nIf you have alt characters you can view information about them such as tradeskills and gold.\nTo change data for an alt, right click and choose from the context menu options.", CreateAtlasMarkup("socialqueuing-icon-group", 26, 26, 0, 13)),

	--====================================================================================
	--paperdoll stuff
	--====================================================================================



	--====================================================================================
	--calendar
	--====================================================================================



	--====================================================================================
	--roster
	--====================================================================================
	ROSTER_LISTVIEW_HT = "Click the tradeskill icons to view character recipes.\n\nRight click for more options",


	--====================================================================================
	--default blizz roster
	--====================================================================================

}


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
L["EQUIPMENT"]                      = "Equipment"
L["TALENTS"]                        = "Talents"

--tradeskills view headers
L["TRADESKILLS"]					= "Professions"
L["TRADESKILLS_RECIPES"]			= "Recipes"
L["TRADESKILLS_CRAFTERS"]			= "Crafters"

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
L["GUILD_BANK"]                     = "Containers (legacy feture)"
L["ALTS"]                           = "Alt characters"
L["USE_MAIN_PROFILE"]               = "Use main character profile"
L["MY_SACKS"]                       = "My containers"
L["BAGS"]                           = "Bags"
L["BANK"]                           = "Bank"
L["STATS"]                          = "Statistics"

--paperdoll stats, these are case sensitive
L["attributes"] 					= "Attributes"
L["STRENGTH"]						= "Strength"
L["AGILITY"]						= "Agility"
L["STAMINA"]						= "Stamina"
L["INTELLECT"]						= "Intellect"
L["SPIRIT"]							= "Spirit"

L["defence"] 						= "Defense"
L["ARMOR"]							= "Armor"
L["DEFENSE"]						= "Defence"
L["DODGE"]							= "Dodge"
L["PARRY"]							= "Parry"
L["BLOCK"]							= "Block"

L["melee"] 							= "Melee"
L["EXPERTISE"]						= "Expertise"
L["HIT_CHANCE"]						= "Hit"
L["MELEE_CRIT"]						= "Crit"
L["MH_DMG"]							= "Main hand dmg"
L["OH_DMG"] 						= "Off hand dmg"
L["MH_DPS"] 						= "Main hand dps"
L["OH_DPS"] 						= "Off hand dps"

L["ranged"]							= "Ranged"
L["RANGED_HIT"] 					= "Hit"
L["RANGED_CRIT"] 					= "Crit"
L["RANGED_DMG"] 					= "Damage"
L["RANGED_DPS"] 					= "Dps"

L["spell"] 							= "Spell"
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


--spec locals
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
L["BREWFEST"]						= "Brewfest"
L["PILGRIMS_BOUNTY"]						= "Pilgrims Bounty"

















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
	--French, Belrand@Auberdine
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


addon.Locales = L


-- key binding header
--BINDING_HEADER_GENERAL = "General"
BINDING_CATEGORY_GUILDBOOK = "Guildbook"
BINDING_HEADER_GENERAL 	= L["GENERAL"]
BINDING_NAME_Open 	= L["OPEN"]
