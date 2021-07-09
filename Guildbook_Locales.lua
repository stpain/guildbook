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
L['OptionsAbout'] = 'Guildbook options and about. Thanks to Belrand@Auberdine for the French translations'
L['Version'] = 'Version'
L['Author'] = 'Author: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'

L["GUILDBOOK_LOADER_HEADER"]        = "Welcome to Guildbook"
L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "Used for the following"

--mod blizz guild roster
L['Online']                         = 'Online'
L['MainSpec']                       = 'Main Spec'
L['Rank']                           = 'Rank'
L['Note']                           = 'Note'
L['Profession1']                    = 'Profession 1'
L['Profession2']                    = 'Profession 2'


-- roster listview and tooltip, these are also sort keys hence the lowercase usage
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

L["MONDAY"]			    = "Monday"
L["TUESDAY"]			    = "Tuesday"
L["WEDNESDAY"]			    = "Wednesday"
L["THURSDAY"]			    = "Thursday"
L["FRIDAY"]			    = "Friday"
L["SATURDAY"]			    = "Saturday"
L["SUNDAY"]			    = "Sunday"


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

L["GENERAL"]						= "General"

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
	L["class"]                          = "Classe" --doesn't fit
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
	L['Cat']                            = 'Chat'
	L['Bear']                           = 'Ours'
	L['Balance']                        = 'Equilibre'
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
	L['PVP']							= 'JcJ'
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
	L["YEARS"]                          = "années"
	L["MONTHS"]                         = "mois"
	L["DAYS"]                           = "jours"
	
	--keybinds
	L["GENERAL"]						= "Général"
	L["OPEN"]							= "Ouvrir"
	
	--raids name
	L["MC"]								= "Coeur du Magma"
	L["BWL"]							= "Repaire de l'Aile noire"
	L["AQ20"]                           = "AQ20"
	L["AQ40"]							= "AQ40"
	L["Naxxramas"]						= "Naxxramas"
	L["ZG"]								= "Zul'Gurub"
	L["Onyxia"]							= "Onyxia"
	L["Magtheridon"]					= "Repaire de Magtheridon"
	L["SSC"]							= "Caverne du sanctuaire du Serpent" --this is way too long wtf
	L["TK"]								= "Donjon de la tempête"
	L["Gruul"]							= "Repaire de Gruul"
	L["Hyjal"]							= "Sommet d'Hyjal"
	L["SWP"]							= "Plateau du Puits de soleil"
	L["BT"]								= "Temple noir"
	L["Karazhan"]						= "Karazhan"
	
	--availability (Data.lua)
	L['Not Available'] 					= 'Indisponible'
	L['Morning'] 						= 'Matin'
	L['Afternoon'] 						= 'Après-midi'
	L['Evening'] 						= 'Soir'
	
	--world events
	L["DARKMOON_FAIRE"]					= "Foire de Sombrelune"
	L["DMF display"]					= '|cffffffffFoire de Sombrelune - '
	L["LOVE IS IN THE AIR"]				= "De l'amour dans l'air"
	L["CHILDRENS_WEEK"]					= "Semaine des enfants"				
	L["MIDSUMMER_FIRE_FESTIVAL"]		= "Fête du Feu du solstice d'été"
	L["HARVEST_FESTIVAL"]				= "Fête des moissons"
	L["HALLOWS_END"]					= "Sanssaint "
	L["FEAST_OF_WINTER_VEIL"]			= "Voile d'hiver"



--------------------------------------------------------------------------------------------
-- help text tooltips
--------------------------------------------------------------------------------------------
--calendar help icon
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
est en ligne, seul les données les plus récentes sont utilisées. as a result 
Il est donc conseillé que les personnages banque fassent une
synchronisation de leur inventaire après chaque changement dedans.

De multiples personnages banques sont supportés.|r
]]

end


Guildbook.Locales = L


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
--BINDING_HEADER_GENERAL = "General"
BINDING_CATEGORY_GUILDBOOK = "Guildbook"
BINDING_HEADER_GENERAL 	= L["GENERAL"]
BINDING_NAME_Open 		= L["OPEN"]
BINDING_NAME_Chat 		= L["CHAT"]
BINDING_NAME_Calendar 	= L["CALENDAR"]
