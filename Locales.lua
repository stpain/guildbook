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





--[[
    this file will need to be translated with the help of the community

    if anyone modifies this could they please drop me a message on curse or git so i can include any translations
]]

-- add this to proper helpAbout section when finished 
--Written by Kylanda@Pyrewood Village, translations
--French, Belrand@Auberdine / Belrand#1998

local addonName, Guildbook = ...

-- locales table
local L = {}

L["UPDATE_NEWS"] = [[
"Bug fixes for recent updates, a lot of code was written when the addon had been running and therefore I missed some (a lot of) bugs during the addon load process which cause major issues, I've also added extra checks around certain functions and var type checking.

Profiles!
Finally should now be working after migrating to a new code structure which has taken far to long to finish (sorry about that).

Features!
* added a sync button to the calendar
* view recipes from the default Blizzard roster"
]]
L["DIALOG_SHOW_UPDATES"]			= "Display again"
L["DIALOG_DONT_SHOW_UPDATES"]		= "Confirm & hide"

--options page
L['OptionsAbout'] = 'Guildbook options and about. Thanks to Belrand@Auberdine for the French translations'
L['Version'] = 'Version'
L['Author'] = 'Author: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'

-- this is the start of the option ui updates, will go through the option panel and rewrite it with locales for stuff
--[[ Added to Options.xml and moved it with the other options further down for the time being -Belrand
L["TOOLTIP_SHOW_TRADESKILLS"]		= "Display a list of tradeskills that use the current item. (Data is taken from Guildbook database)"
L["TOOLTIP_SHOW_RECIPES"]			= "Include recipes that use the current item under each tradeskill."
L["TOOLTIP_SHOW_RECIPES"]			= "Only show recipes for your characters tradeskills."
--]]
L["OPTIONS"]						= "Options & Settings"
L["MINIMAP_CALENDAR_RIGHTCLICK"]	= "Right click for menu"
L["MINIMAP_CALENDAR_EVENTS"]		= "Events"

L["DIALOG_CHARACTER_FIRST_LOAD"]	= "Welcome to Guildbook, click below to scan your characters professions."

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
You can use /guildbook, /gbk or /gb.
/guildbook open - this will open Guildbook
/guildbook [interface] - this will open to a specific area (roster, tradeskills, chat, profiles, calendar, stats, guildbank, search, privacy)

]]
local homeIcon = CreateAtlasMarkup("poi-town", 16, 16)
local homeHelp = 
[[
Home: 
A brand new display for your guild's roster featuring an Activity Feed showing who has come online/offline as well as level up and showcasing team up request from guild member using the LFG tool.

]]
local profileIcon = CreateAtlasMarkup("GarrMission_MissionIcon-Recruit", 16, 16)
local profileHelp = 
[[
Profile:
Edit as you wish, add your personal information or not.
You can select your spec(s) and edit your main character. If you use multiple accounts you can add another character which you can then select as a main. (Alts are set by selecting a main character from the alts profile).

]]
local tradeskillIcon = CreateAtlasMarkup("Mobile-Blacksmithing", 16, 16)
local tradeskillHelp = 
[[
Tradeskills (Professions):
Guildbook will process recipe/item IDs when it loads, this process can take a few minutes. Once complete you can view available crafts by profession and/or by equipment slot (head, hands, feet etc).

Guildbook will share your tradeskill recipes with other guild members. 
Open your tradeskill to trigger the scan of the recipes. This will save to your character and account database for the guild and sends to online guild members. Once this process is complete, future data will be sent to all online guild members when you log in. 

You can also push data by opening a tradeskill (cooldown enabled to prevent spam).
You can also use the import/export feature, click the icon above the profession list and follow the instructions.

]]
local rosterIcon = CreateAtlasMarkup("poi-workorders", 16, 16)
local rosterHelp = [[
Guild Viewer:
You can view characters from other guilds you are a member of here, the information is the raw data from the addons saved variables file. Select which guild to see a list of its members, select a character to view information.

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
Coming soon

]]
L["HELP_ABOUT_CREDITS"]				= string.format("%s %s %s %s %s %s %s %s %s %s %s %s %s %s", slashCommandsIcon, slashCommandsHelp, homeIcon, homeHelp, profileIcon, profileHelp, tradeskillIcon, tradeskillHelp, rosterIcon, rosterHelp, searchIcon, searchHelp, bankIcon, bankHelp)



L["CALENDAR_TOOLTIP_LOCKOUTS"] 		= "Lockouts"



--mod blizz guild roster, these are key/values in the ModBlizz file that add extra columns
L['Online']                         = 'Online'
L['MainSpec']                       = 'Main Spec'
L['Rank']                           = 'Rank'
L['Note']                           = 'Note'
L['Profession1']                    = 'Profession 1'
L['Profession2']                    = 'Profession 2'
L["Fishing"]						= "Fishing"


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
L["PRIVACY_ABOUT"]                  = "Set the lowest rank you wish to share data with. Profile data includes name, birthday, bio and avatar. Inventory data is the equipment your character has (this is |cffFFD100NOT|r your bags/bank). Talents are, well, your talents!"
L["INVENTORY"]                      = "Inventory"
L["TALENTS"]                        = "Talents"

L["ROSTER_MY_CHARACTERS"]			= "My characters"
L["ROSTER_ALL_CLASSES"]				= "All"
L["ROSTER_ALL_RANKS"]				= "All"

L["ROSTER_VIEW_RECIPES"]			= "Click to view recipes"

L["TRADESKILLS"]					= "Professions"
L["TRADESKILLS_RECIPES"]			= "Recipes"
L["TRADESKILLS_REAGENTS"]			= "Reagents"
L["TRADESKILLS_CHARACTERS"]			= "Characters"
L["TRADESKILL_GUILD_RECIPES"]		= "Guild Recipes"
L["TRADESKILLS_SHARE_RECIPES"]		= "Share this characters recipes"
L["TRADESKILLS_EXPORT_RECIPES"]		= "Import or export tradeskill data"
L["IMPORT"]							= "Import"
L["EXPORT"]							= "Export"
L["CAN_CRAFT"]                      = "[Guildbook] are you able to craft %s ?"
L["REMOVE_RECIPE_FROM_PROF_SS"]		= "Remove %s from %s ?"
L["REMOVE_RECIPE_FROM_PROF"]		= "Right click to remove from this tradeskill."
L["PROCESSED_RECIPES_SS"]			= "Processed %s of %s recipes"
L["TRADESKILL_SLOT_FILTER_S"]		= "Filter %s items"
L["TRADESKILL_SLOT_REMOVE"]			= "Clear filters"
L["HEAD"]							= "head"
L["SHOULDER"]						= "shoulder"
L["BACK"]							= "back"
L["CHEST"]							= "chest"
L["WRIST"]							= "wrist"
L["HANDS"]							= "hands"	
L["WAIST"]							= "waist"
L["LEGS"]							= "legs"
L["FEET"]							= "feet"
L["WEAPONS"]						= "weapons"
L["OFF_HAND"]						= "off hand"	
L["MISC"]							= "misc"
L["CONSUMABLES"]					= "consumables"


L["PHASE2GB"]						= "With the arrival of guild banks to TBCC i have removed the guild bank system from Guildbook. I am working on something to replace it though!"
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

L["HOME"]							= "Home"
L["PROFILES"]                       = "Profiles"
L["CHAT"]                           = "Chat"
L["GUILD_VIEWER"]                   = "Guild Viewer"
L["CALENDAR"]                       = "Calendar"
L["SEARCH"]                         = "Search"
L["MY_PROFILE"]                     = "My profile"
L["OPEN_PROFILE"]                   = "Open profile"
L["OPEN_CHAT"]                      = "Open chat"
L["INVITE_TO_GROUP"]                = "Invite to group"
L["SEND_TRADE_ENQUIRY"]             = "Send message about item"
L["REFRESH_ROSTER"]                 = "Refresh roster"
L["EDIT"]                           = "Edit profile"
L["GUILD_BANK"]                     = "Guild bank"
L["ALTS"]                           = "Alt characters"
L["USE_MAIN_PROFILE"]               = "Use main character profile"
L["MY_SACKS"]                       = "My containers"
L["BAGS"]                           = "Bags"
L["BANK"]                           = "Bank"
L["STATS"]                          = "Statistics"

--news feed stuff
L["GUILD_ACTIVTY_HEADER"]			= "Activity Feed"
L["GUILD_MEMBERS_HEADER"]			= "Members (|cffFFD100hold shift for more info|r)"
L["GUILD_MEMBERS_OFFLINE"]			= "Show offline"
L["NF_PLAYER_LEVEL_UP_SS"]			= "%s just hit level %s!"
L["NF_PLAYER_LOGIN_S"]				= "%s came online"
L["NF_PLAYER_LOGOUT_S"]				= "%s logged out"
--L["NF_LFG_CREATED_S"]				= "%s"



--privacy and options

L["PRIVACY_SHARE_LFG"]				= "Share when you use the group finder"
L["PRIVACY_SHARE_LEVEL_UP"]			= "Send news that you leveled up"
--L[""]

L["OPT_SHOW_MINIMAP_BUTTON"]		= "Toggle the minimap button"
L["OPT_SHOW_MINIMAP_CALENDAR"]		= "Toggle the minimap calendar button"
L["OPT_MOD_BLIZZ_ROSTER"]			= "Modify the default Blizzard guild roster UI"
L["OPT_COMBAT_COMMS_LOCK"]			= "Block data comms during combat"
L["OPT_INSTANCE_COMMS_LOCK"]		= "Block data comms during an instance (raids/dungeons)"

L["OPT_TT_CHAR_SHOW_INFO"]			= "Show character info"
L["OPT_TT_CHAR_MAIN_SPEC"]			= "Main Spec"
L["OPT_TT_CHAR_TRADESKILLS"]		= "Tradeskills"
L["OPT_TT_CHAR_MAIN_CHAR"]			= "Main character"

L["OPT_TT_TRADESKILLS_SHOW"]		= "Show tradeskills (professions)"
L["OPT_TT_TRADESKILLS_RECIPES"]		= "Show recipes"
L["OPT_TT_TRADESKILLS_PERSONAL"]	= "Only show recipes for your characters tradeskills"

--options dialogs boxes
--Dialogs.lua
L["OPT_RELOAD_UI"]                  = "Reload UI"
L["OPT_SETTINGS_CHANGED"]           = "Settings have changed and a UI reload is required!"
L["OPT_DELETE_GUILD_DATA"]          = 'Delete all data for %s'
L["OPT_RESET_CHAR_DATA" ]           = 'Reset data for '..select(1, UnitName("player"))..' to default values?'
L["OPT_RESET_CACHE_CHAR_DATA"]      = 'Reset data for %s?' --couldn't be tested -Belrand
L["OPT_RESET_GLOBAL_SETTINGS"]      = 'Reset global settings to default values? \n\nThis will delete all data about all guilds you are a member of.'
--Options.xml these are loaded at the end of the file with other xml variables
L["OPT_SH_MINIMAP_BUTTON"]          = 'Show / Hide Minimap Button'
L["OPT_SH_MINICAL_BUTTON"]          = 'Show / Hide Minimap calendar button'
L["OPT_BLIZZROSTER"]                = 'Show the wide view for the default Blizzard guild roster.'
--L["OPT_INFO_MESSAGE"]
L["OPT_BLOCK_DATA_COMBAT"]          = 'Guildbook will block all incoming and outgoing data comms while you are in combat lockdown. Guild members wont be able to make requests that target you.'
L["OPT_BLOCK_DATA_INSTANCE"]        = 'Guildbook will block all incoming and outgoing data comms while you are in an instance. Guild members wont be able to make requests that target you.'

L["OPT_TT_DIALOG_SCI"]              = 'Show additional guild member info in tooltip'
L["OPT_TT_DIALOG_SCMS"]             = 'Show characters main spec'
L["OPT_TT_DIALOG_SCP"]              = 'Show characters professions'
L["OPT_TT_DIALOG_SMC"]              = 'Show main character'
--
L["OPT_TT_DIALOG_DPL"]              = "Display a list of tradeskills that use the current item. (Data is taken from Guildbook database)"
L["OPT_TT_DIALOG_DLR"]              = "Include recipes that use the current item under each tradeskill."
L["OPT_TT_DIALOG_DLRCO"]            = "Only show recipes for your characters tradeskills."

L["OPT_CHAT_SMCO"]                  = 'Show the characters main character name (if an alt) in the guild chat messages. Can only show data where the player has set this value'
L["OPT_CHAT_SMS"]                   = 'Show the characters main spec in the guild chat messages. Can only show data where the player has set this value.'


--Buttons
L["YES"]                            = 'Yes'
L["CANCEL"]                         = 'Cancel'
L["RESET"]                          = 'Reset'
L["DELETE"]                         = "Delete"


--guildViewer
L["GUILD_VIEWER_HEADER"]			= "You can view characters from other guilds you are a member of here, the information is the raw data from the addons saved variables file. Select which guild to see a list of its members, select a character to view information."

L["RESET_AVATAR"]					= "Reset avatar"

L["PRIVACY_HEADER"]                 = "Privacy settings"
L["NONE"]                           = "None"
L["SHARING_NOBODY"]		    		= "Sharing with nobody"
L["SHARING_WITH"]		    		= "Sharing with"

L["MAIN_CHARACTER_ADD_ALT"]			= "Add character.\n|cffFFFF00Use this to add a character from a different account. You will then be able to select it as main character."
L["MAIN_CHARACTER_REMOVE_ALT"]		= "Remove character"
L["DIALOG_MAIN_CHAR_ADD"]			= "Type the name of your character, must be a guild member."
L["DIALOG_MAIN_CHAR_REMOVE"]		= "Please enter the characters name."
L["DIALOG_MAIN_CHAR_ADD_FOUND"]		= "Found character: %s Level: %s %s"

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

--odds
L["Warden"]							= "Warden"
L["Frost (Tank)"]					= "Frost (Tank)"

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
L["ATTENDING"]                      = "Attend"
L["LATE"]                      		= "Late"
L["TENTATIVE"]                      = "Tentative"
L["DECLINE"]                        = "Decline"

L["TIME"]							= "Time"
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

















-- grab the clients locale
local locale = GetLocale()







--[[
    german  - thanks to Nezzquikk from discord for these translations
]]
if locale == "deDE" then


	--options page
	L['OptionsAbout'] = 'Guildbook options and about. Thanks to Belrand@Auberdine for the French translations.'
	L['Version'] = 'Version'
	L['Author'] = 'Autor: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'

	-- this is the start of the option ui updates, will go through the option panel and rewrite it with locales for stuff
	L["TOOLTIP_SHOW_TRADESKILLS"]		= "Zeigt eine Liste der Berufe an, die den aktuellen Gegenstand verwenden. (Die Daten stammen aus der Guildbook-Datenbank)"
	L["TOOLTIP_SHOW_RECIPES"]			= "Fügen Sie Rezepte, die den aktuellen Gegenstand verwenden, unter jeder Fertigkeit ein."
	L["TOOLTIP_SHOW_RECIPES"]			= "Zeige nur Rezepte für die Berufe deiner Charaktere an."

	L["OPTIONS"]						= "Optionen & Einstellungen"
	L["MINIMAP_CALENDAR_RIGHTCLICK"]	= "Rechtsklick für Menü"
	L["MINIMAP_CALENDAR_EVENTS"]		= "Ereignisse"

	L["DIALOG_CHARACTER_FIRST_LOAD"]	= "Willkommen bei Guildbook, klicken Sie unten, um die Berufe Ihrer Charaktere zu scannen."

	L["NEW_VERSION_1"] = "Eine neue Version ist verfügbar, behebt wahrscheinlich ein paar Dinge, könnte aber auch etwas anderes kaputt machen!"
	L["NEW_VERSION_2"] = "Es gibt eine völlig neue, fantastische Version von Guildbook, die bei allen guten Addon-Anbietern heruntergeladen werden kann!"
	L["NEW_VERSION_3"] = "lol, wenn du dachtest, dass das letzte Update nicht viel gebracht hat, solltest du dir das neue holen, das macht wahrscheinlich ungefähr das gleiche.....oder weniger!"
	L["NEW_VERSION_4"] = "Hordies sind rot, Allianzen sind blau, Guildbook-Updates sind super schlau!"

	L["GUILDBOOK_DATA_SHARE_HEADER"]	= "Gildenbuchdaten freigeben \n\nSie können Ihre Berufe teilen, indem Sie auf exportieren klicken, um einen Zeichenkette zu erzeugen. Kopieren Sie diesen dann und fügen Sie ihn z. B. in Discord ein. \nUm Daten von Berufen zu importieren, füge eine Zeichenkette in das Feld unten ein und klicke auf importieren."
	L["GUILDBOOK_LOADER_HEADER"]        = "Willkommen bei Guildbook"
	L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "Wird für Folgendes verwendet"

	L["HELP_ABOUT"]						= "Hilfe & Infos"

	-- this is just a quick thing, will make the how section more fleshed out
	-- this is a nasty way to do this, its horrible and i need to make the help & about much better
	local slashCommandsIcon = CreateTextureMarkup(136377, 64, 64, 16, 16, 0, 1, 0, 1, 0, 0)
	local slashCommandsHelp = [[
	Slash commands:
	Sie können /guildbook, /gbk oder /gb verwenden.
	/guildbook open - dies öffnet das Guildbook
	/guildbook [Ansicht] - öffnet einen bestimmten Bereich (Gilde, Berufe, Chat, Profile, Kalender, Statistiken, Gildenbank, Suche, Datenschutz)

	]]
	local rosterIcon = CreateAtlasMarkup("poi-workorders", 16, 16)
	local rosterHelp = [[
	Gildenfenster:
	Sie können das Gildenfenster sortieren, indem Sie auf die Spaltenüberschriften klicken. Du kannst das Gildenfenster auch nach Klasse oder Rang filtern, indem du mit der rechten Maustaste auf die Überschriften klickst. Unter "Klasse" gibt es die Möglichkeit, das Gildenfenster nur nach deinen eigenen Charakteren zu filtern!

	]]
	local tradeskillIcon = CreateAtlasMarkup("Mobile-Blacksmithing", 16, 16)
	local tradeskillHelp = 
	[[
	Berufe:
	Guildbook verarbeitet die Rezept-/Gegenstände-IDs, wenn es geladen wird; dieser Vorgang kann einige Minuten dauern. Sobald dies abgeschlossen ist, können Sie die verfügbaren Gegenstände nach Beruf und/oder nach Ausrüstungsplatz (Kopf, Hände, Füße usw.) anzeigen.

	Mit Guildbook könnt ihr eure Rezepte mit anderen Gildenmitgliedern teilen. 
	Öffnen Sie das Fenster eines Berufs, um den Scan der Rezepte auszulösen. Dies wird in Ihrer Charakter- und Account-Datenbank für die Gilde gespeichert und an die Online-Gildenmitglieder gesendet. Sobald dieser Vorgang abgeschlossen ist, werden zukünftige Daten an alle Online-Gildenmitglieder gesendet, wenn ihr euch einloggt. 

	Ihr könnt auch Daten verschicken, indem ihr das Fenster eines Berufs öffnet (Abklingzeit aktiviert, um Spam zu verhindern).
	Ihr könnt auch die Import/Export-Funktion nutzen, indem ihr auf das Symbol über der Berufsliste klickt und den Anweisungen folgt.


	]]
	local profileIcon = CreateAtlasMarkup("GarrMission_MissionIcon-Recruit", 16, 16)
	local profileHelp = 
	[[
	Profil:
	Bearbeiten Sie ihr Profil nach Belieben, fügen Sie Ihre persönlichen Informationen optional hinzu.
	Sie können Ihre Spezialisierungen auswählen und Ihre Hauptfigur bearbeiten. Wenn Sie mehrere Konten verwenden, können Sie einen weiteren Charakter hinzufügen, den Sie dann als Hauptcharakter auswählen können. (Alts werden durch Auswahl eines Hauptcharakters aus dem Alt-Profil festgelegt).

	]]
	local searchIcon = CreateAtlasMarkup("shop-games-magnifyingglass", 16, 16)
	local searchHelp = 
	[[
	Suchen:
	Verwenden Sie diese Funktion, um Ihre Gilden-Datenbank zu durchsuchen: Suchen Sie ein Rezept, ein Rezeptmuster oder einen Charakternamen.

	]]
	local bankIcon = CreateAtlasMarkup("ShipMissionIcon-Treasure-Map", 16, 16)
	local bankHelp = [[
	Demnächst verfügbar
	]]
	L["HELP_ABOUT_CREDITS"]				= string.format("%s %s %s %s %s %s %s %s %s %s %s %s", slashCommandsIcon, slashCommandsHelp, rosterIcon, rosterHelp, tradeskillIcon, tradeskillHelp, profileIcon, profileHelp, searchIcon, searchHelp, bankIcon, bankHelp)



	--mod blizz guild roster, these are key/values in the ModBlizz file that add extra columns
	L['Online']                         = 'Online'
	L['MainSpec']                       = 'Main Spec'
	L['Rank']                           = 'Rank'
	L['Note']                           = 'Notiz'
	L['Profession1']                    = 'Beruf 1'
	L['Profession2']                    = 'Beruf 2'


	-- roster listview and tooltip, these are also sort keys and should be lower case
	L["name"]                           = "Name"
	L["level"]                          = "Level"
	L["mainSpec"]                       = "Main Spec"
	L["prof1"]                          = "Berufe"
	L["location"]                       = "Ort"
	L["rankName"]                       = "Rang"
	L["publicNote"]                     = "Öffentl. Notiz"
	L["class"]                          = "Klasse"
	L["attunements"]                    = "Errungschaften"


	-- xml strings
	L["PROFILE_TITLE"]                  = "Profil"
	L["REAL_NAME"]                      = "Name"
	L["REAL_DOB"]                       = "Geburtsdatum"
	L["REAL_BIO"]                       = "Bio"
	L["AVATAR"]                         = "Avatar"
	L["MAIN_CHARACTER"]                 = "Hauptcharakter"
	L["ALT_CHARACTERS"]                 = "Alt-Charakter"
	L["MAIN_SPEC"]                      = "Main spec"
	L["OFF_SPEC"]                       = "Off spec"
	L["PRIVACY"]                        = "Datenschutz"
	L["PRIVACY_ABOUT"]                  = "Legen Sie den niedrigsten Rang fest, für den Sie Daten freigeben möchten. Zu den Profildaten gehören Name, Geburtstag, Lebenslauf und Avatar. Inventardaten sind die Ausrüstung, die dein Charakter besitzt (Welche |cffFFD100NICHT|r in deinen Taschen/Bank liegt). Talentspezialisierung ist, nun ja, deine Talentspezialisierungen!"
	L["INVENTORY"]                      = "Inventar"
	L["TALENTS"]                        = "Talentspezialisierung"

	L["ROSTER_MY_CHARACTERS"]			= "Mein Charakter"
	L["ROSTER_ALL_CLASSES"]				= "Alle"
	L["ROSTER_ALL_RANKS"]				= "Alle"

	L["TRADESKILLS"]					= "Berufe"
	L["TRADESKILLS_RECIPES"]			= "Rezepte"
	L["TRADESKILLS_CHARACTERS"]			= "Charaktere"
	L["TRADESKILL_GUILD_RECIPES"]		= "Gildenrezepte"
	L["TRADESKILLS_SHARE_RECIPES"]		= "Teilen Sie die Rezepte dieses Charakters"
	L["TRADESKILLS_EXPORT_RECIPES"]		= "Importieren oder exportieren von Berufsinhalten"
	L["IMPORT"]							= "importieren"
	L["EXPORT"]							= "exportieren"
	L["CAN_CRAFT"]                      = "[Guildbook] bist du in der Lage %s herzustellen?"
	L["REMOVE_RECIPE_FROM_PROF_SS"]		= "Entferne %s von %s ?"
	L["REMOVE_RECIPE_FROM_PROF"]		= "Klicken Sie mit der rechten Maustaste, um sie aus diesem Beruf zu entfernen."
	L["PROCESSED_RECIPES_SS"]			= "Verarbeitet %s von %s Rezepten"
	L["TRADESKILL_SLOT_FILTER_S"]		= "Filter %s Gegenstände"
	L["TRADESKILL_SLOT_REMOVE"]			= "Filter aufheben"
	L["HEAD"]							= "Kopf"
	L["SHOULDER"]						= "Schultern"
	L["BACK"]							= "Rücken"
	L["CHEST"]							= "Brust"
	L["WRIST"]							= "Handgelenk"
	L["HANDS"]							= "Hände"	
	L["WAIST"]							= "Taille"
	L["LEGS"]							= "Beine"
	L["FEET"]							= "Füße"
	L["WEAPONS"]						= "Waffen"
	L["OFF_HAND"]						= "Schildhand"	
	L["MISC"]							= "Sonstiges"
	L["CONSUMABLES"]					= "Verbrauchsmaterial"


	L["PHASE2GB"]						= "Mit der Einführung der Gildenbanken in TBCC habe ich das Gildenbanksystem aus dem Gildenbuch entfernt. Ich arbeite aber an einem Ersatz!"
	L['GUILDBANK']						= "Gildenbank"
	L["GUILDBANK_HEADER_ITEM"]			= "Gegenstandslink"
	L["GUILDBANK_HEADER_COUNT"]			= "Zählen"
	L["GUILDBANK_SORT_TYPE"]			= "Typ"
	L["GUILDBANK_HEADER_SUBTYPE"]		= "Untertyp"
	L["GUILDBANK_SORT_BANK"]			= "Quelle"
	L["GUILDBANK_REFRESH"]				= "Aktualisieren"
	L["GUILDBANK_ALL_BANKS"]			= "Alle Banken"
	L["GUILDBANK_ALL_TYPES"]			= "Alle Typen"
	L["GUILDBANK_REQUEST_COMMITS"]		= "Anfordern von Commits für "
	L["GUILDBANK_REQUEST_INFO"]			= "Anfordern von Daten von "
	L["GUILDBANK_FUNDS"]				= "Gold verfügbar"
	L["GUILDBANK_CURRENCY"]				= "Währung"

	L["PROFILES"]                       = "Profile"
	L["CHAT"]                           = "Chat"
	L["ROSTER"]                         = "Gilde"
	L["CALENDAR"]                       = "Kalender"
	L["SEARCH"]                         = "Suche"
	L["MY_PROFILE"]                     = "Mein Profile"
	L["OPEN_PROFILE"]                   = "Profil öffnen"
	L["OPEN_CHAT"]                      = "Chat öffnen"
	L["INVITE_TO_GROUP"]                = "Zur Gruppe einladen"
	L["SEND_TRADE_ENQUIRY"]             = "Nachricht über Gegenstand schicken"
	L["REFRESH_ROSTER"]                 = "Gilde aktualisieren"
	L["EDIT"]                           = "Profil bearbeiten"
	L["GUILD_BANK"]                     = "Nutzloser Tooltip!"
	L["ALTS"]                           = "Alt-Charakter"
	L["USE_MAIN_PROFILE"]               = "Profil des Hauptcharakters verwenden"
	L["MY_SACKS"]                       = "Meine Behälter"
	L["BAGS"]                           = "Taschen"
	L["BANK"]                           = "Bank"
	L["STATS"]                          = "Statistiken"

	L["RESET_AVATAR"]					= "Avatar zurücksetzen"

	L["PRIVACY_HEADER"]                 = "Datenschutzeinstellungen"
	L["NONE"]                           = "Keine"
	L["SHARING_NOBODY"]		    		= "Teilen mit niemandem"
	L["SHARING_WITH"]		    		= "Teilen mit"

	L["MAIN_CHARACTER_ADD_ALT"]			= "Charakter hinzufügen.\n|cffFFFF00Verwenden Sie dies, um einen Charakter von einem anderen Konto hinzuzufügen. Sie können ihn dann als Hauptcharakter auswählen."
	L["MAIN_CHARACTER_REMOVE_ALT"]		= "Charakter entfernen"
	L["DIALOG_MAIN_CHAR_ADD"]			= "Gib den Namen deines Charakters ein, er muss ein Gildenmitglied sein."
	L["DIALOG_MAIN_CHAR_REMOVE"]		= "Bitte geben Sie den Namen des Charakters ein."
	L["DIALOG_MAIN_CHAR_ADD_FOUND"]		= "Charakter gefunden: %s Level: %s %s"

	--attributes
	L["STRENGTH"]						= "Strength"
	L["AGILITY"]						= "Beweglichkeit"
	L["STAMINA"]						= "Ausdauer"
	L["INTELLECT"]						= "Intelligenz"
	L["SPIRIT"]							= "Willenskraft"
	--defence
	L["ARMOR"]							= "Rüstung"
	L["DEFENSE"]						= "Verteidigung"
	L["DODGE"]							= "Ausweichen"
	L["PARRY"]							= "Parieren"
	L["BLOCK"]							= "Blocken"
	--melee
	L["EXPERTISE"]						= "Fachwissen"
	L["HIT_CHANCE"]						= "Hit"
	L["MELEE_CRIT"]						= "Crit"
	L["MH_DMG"]							= "Main hand Schaden"
	L["OH_DMG"] 						= "Off hand Schaden"
	L["MH_DPS"] 						= "Main hand Schaden"
	L["OH_DPS"] 						= "Off hand Schaden"
	--ranged
	L["RANGED_HIT"] 					= "Hit"
	L["RANGED_CRIT"] 					= "Crit"
	L["RANGED_DMG"] 					= "Schaden"
	L["RANGED_DPS"] 					= "Dps"
	--spells
	L["SPELL_HASTE"] 					= "Tempowertung"
	L["MANA_REGEN"] 					= "Mana-Regenerierung"
	L["MANA_REGEN_CASTING"] 			= "Mana-Regenerierung (während dem casten)"
	L["SPELL_HIT"] 						= "Hit"
	L["SPELL_CRIT"] 					= "Crit"
	L["HEALING_BONUS"] 					= "Heilbonus"
	L["SPELL_DMG_HOLY"] 				= "Heilig"
	L["SPELL_DMG_FROST"] 				= "Frost"
	L["SPELL_DMG_SHADOW"] 				= "Schatten"
	L["SPELL_DMG_ARCANE"] 				= "Arkan"
	L["SPELL_DMG_FIRE"] 				= "Feuer"
	L["SPELL_DMG_NATURE"] 				= "Natur"



	-- class and spec
	-- class is upper case
	L['DEATHKNIGHT']                    = 'Todesritter'
	L['DRUID']                          = 'Druid'
	L['HUNTER']                         = 'Jäger'
	L['MAGE']                           = 'Magier'
	L['PALADIN']                        = 'Paladin'
	L['PRIEST']                         = 'Priester'
	L['SHAMAN']                         = 'Schamane'
	L['ROGUE']                          = 'Schurke'
	L['WARLOCK']                        = 'Hexenmeister'
	L['WARRIOR']                        = 'Krieger'
	--mage/dk
	L['Arcane']                         = 'Arkan'
	L['Fire']                           = 'Feuer'
	L['Frost']                          = 'Frost'
	L['Blood']                          = 'Blut'
	L['Unholy']                         = 'Unheilig'
	--druid/shaman
	L['Restoration']                    = 'Wiederherstellung'
	L['Enhancement']                    = 'Verstärkung'
	L['Elemental']                      = 'Elementar'
	L["Warden"]							= "Warden"
	L['Cat']                            = 'Katze'
	L['Bear']                           = 'Bär'
	L['Balance']                        = 'Gleichgewicht'
	L['Guardian']                       = 'Wächter'
	L["Feral"]							= "Wildheit"
	--rogue
	L['Assassination']                  = 'Meucheln'
	L['Combat']                         = 'Kampf'
	L['Subtlety']                       = 'Täuschung'
	--hunter
	L['Marksmanship']                   = 'Treffsicherheit'
	L['Beast Master']                   = 'Tierherrschaft'
	L['BeastMaster']                   	= 'Tierherrschaft' -- the smart detect spec system could return this value
	L['Survival']                       = 'Überleben'
	--warlock
	L['Destruction']                    = 'Zerstörung'
	L['Affliction']                     = 'Gebrechen'
	L['Demonology']                     = 'Dämonologie'
	--warrior/paladin/priest
	L['Fury']                           = 'Furor'
	L['Arms']                           = 'Waffen'
	L['Protection']                     = 'Schutz'
	L['Retribution']                    = 'Vergeltung'
	L['Holy']                           = 'Heilig'
	L['Discipline']                     = 'Disziplin'
	L['Shadow']                         = 'Schatten'

	--odds
	L["Warden"]							= "Warden"
	L["Frost (Tank)"]					= "Frost (Tank)"

	--date time
	L['JANUARY']                        = 'Januar'
	L['FEBRUARY']                       = 'Februar'
	L['MARCH']                          = 'März'
	L['APRIL']                          = 'April'
	L['MAY']                            = 'Mai'
	L['JUNE']                           = 'Juni'
	L['JULY']                           = 'Juli'
	L['AUGUST']                         = 'August'
	L['SEPTEMBER']                      = 'September'
	L['OCTOBER']                        = 'Oktober'
	L['NOVEMBER']                       = 'November'
	L['DECEMBER']                       = 'Dezember'

	L["MONDAY"]			    			= "Montag"
	L["TUESDAY"]			    		= "Dienstag"
	L["WEDNESDAY"]			    		= "Mittwoch"
	L["THURSDAY"]			    		= "Donnerstag"
	L["FRIDAY"]			   				= "Freitag"
	L["SATURDAY"]			    		= "Samstag"
	L["SUNDAY"]			    			= "Sonntag"


	-- old stuff but might use again
	L['GuildBank']                      = 'Gildenbank'
	L['Events']                         = 'Ereignisse'
	L['WorldEvents']                    = 'Weltereignisse'
	L['Attunements']                    = 'Errungenschaften'
	L["Guild"]                          = "Gilde"


	L['Roles']                          = 'Rollen'
	L['Tank']                           = 'Tank'
	L['Melee']                          = 'Nahkampf'
	L['Ranged']                         = 'Fernkampf'
	L['Healer']                         = 'Heiler'
	L['ClassRoleSummary']               = 'Klasse & Rollen Zusammenfassung'
	L['RoleChart']                      = 'Rollen (Mitglieder Online)'
	L['ClassChart']                     = 'Klasse (Alle Mitglieder)'

	-- calendar help icon
	L['calendarHelpText'] = [[
	Kalender

	|cffffffffGuildbook bietet einen spielinternen Kalender für Gilden, um 
	Ereignisse zu planen. Er basiert lose auf einer älteren Version des
	Blizzard-Kalenders und funktioniert auf ähnliche Weise. Derzeit 
	werden bis zu 3 Ereignisse pro Tag auf den Tageskacheln angezeigt (eine Option zum Zugriff auf mehr 
	wird noch hinzugefügt).|r

	|cff00BFF3Der Kalender sendet/empfängt Daten, wenn sich ein Spieler anmeldet, 
	wenn ein Ereignis erstellt oder gelöscht wird und wenn ein Ereignis geändert wird. 
	Ereignisse sollten mit Gildenmitgliedern synchronisiert werden, obwohl dies nicht garantiert ist 
	da das davon abhängt, dass es genügend Überschneidungen zwischen den Spielersitzungen gibt.

	Die gesendeten Daten sind auf 4 Wochen begrenzt, um die Nachfrage nach den Addon-Chat 
	zu senken. Ereignisse können für jedes Datum erstellt und  synchronisiert werden, sobald sie 
	innerhalb von 4 Wochen nach dem aktuellen Datum liegen|r.
	]]

	--guildbank help icon
	L["GUILDBANKHELPTEXT"]	= [[
	Gildenbank

	|cffffffffGuildbook bietet eine spielinterne Gildenbank für die Gilde 
	um das Inventar des Bankcharakters zu teilen.
	|r

	|cff00BFF3Um die Gildenbank zu benutzen, fügen Sie das Wort 'Gildenbank'
	in die öffentliche Notiz des Charakters ein, der als Bank verwendet werden soll
	(dadurch wird er zum Dropdown-Menü hinzugefügt).
	Der besagte Charakter muss dann seine Bank öffnen 
	um sein Inventar mit den angeschlossenen Gildenmitgliedern zu synchronisieren.

	Die Gildenbank sendet/empfängt Daten, wenn sich ein Spieler anmeldet, 
	Es werden nur die aktuellsten Daten verwendet, daher sollten Bankcharaktere
	ihr Inventar nach jeder Änderung synchronisieren.

	Es werden mehrere Bankcharaktere unterstützt.|r
	]]


	--legacy stuff
	L["SELECT_BANK_CHARACTER"]          = "Bankcharakter auswählen"
	L["DUNGEON"]                        = "Dungeon"
	L["RAID"]                           = "Raid"
	L['PVP']							= 'PVP'
	L["MEETING"]                        = "Meeting"
	L["OTHER"]                          = "Andere"
	L["GUILD_CALENDAR"]                 = "Gildenkalender"
	L["INSTANCE_LOCKS"]                 = "Instanzsperren"
	L["CREATE_EVENT"]                   = "Ereignis erstellen"
	L["DELETE_EVENT"]                   = "Ereignis löschen"
	L["EVENT"]                          = "Ereignis"
	L["EVENT_TYPE"]                     = "Ereignistyp"
	L["TITLE"]                          = "Titel"
	L["DESCRIPTION"]                    = "Beschreibung"
	L["UPDATE"]                         = "Aktualisierung"
	L["ATTENDING"]                      = "Antretend"
	L["TENTATIVE"]                      = "Abwesend"
	L["DECLINE"]                        = "Abbrechen"

	L["YEARS"]                          = "Jahre"
	L["MONTHS"]                         = "Monate"
	L["DAYS"]                           = "Tage"
	L["HOURS"]                          = "Stunden"
	L['< an hour']			    		= '< eine Stunde'

	L["GENERAL"]			    		= "Allgemein"
	L["MINIMAP_TOOLTIP_LEFTCLICK"]		= '|cffffffffLinksklick|r öffne Guildbook'
	L["MINIMAP_TOOLTIP_LEFTCLICK_SHIFT"]= "Shift + "..'|cffffffffLinksklick|r öffne Chat'
	L["MINIMAP_TOOLTIP_RIGHTCLICK"]		= '|cffffffffRechtsklick|r Optionen'
	L["MINIMAP_TOOLTIP_MIDDLECLICK"]	= "|cffffffffMittlere Muastaste|r Öffne Blizzard Gildenfenster"

	L["MC"]								= "Geschmolzener Kern"
	L["BWL"]							= "Pechschwingenhort"
	L["AQ20"]                           = "AQ20"
	L["AQ40"]							= "AQ40"
	L["Naxxramas"]						= "Naxxramas"
	L["ZG"]								= "Zul'Gurub"
	L["Onyxia"]							= "Onyxia"
	L["Magtheridon"]					= "Magtheridons Kammer"
	L["SSC"]							= "Höhle des Schlangenschreins"
	L["TK"]								= "Festung der Stürme"
	L["Gruul"]							= "Gruuls Unterschlupf"
	L["Hyjal"]							= "Hyjalgipfel"
	L["SWP"]							= "Sonnenbrunnenplateau"
	L["BT"]								= "Schwarzer Tempel"
	L["Karazhan"]						= "Karazhan"

	--availability (Data.lua)
	L['Not Available'] 					= 'Nicht verfügbar'
	L['Morning'] 						= 'Morgens'
	L['Afternoon'] 						= 'Nachmittag'
	L['Evening'] 						= 'Abend'

	--world events
	L["DARKMOON_FAIRE"]					= "Dunkelmond-Jahrmarkt"
	L["DMF display"]					= '|cffffffffDunkelmond-Jahrmarkt - ' --this is needed for the calendar
	L["LOVE IS IN THE AIR"]				= "Liebe liegt in der Luft"
	L["CHILDRENS_WEEK"]					= "Kinderwoche"				
	L["MIDSUMMER_FIRE_FESTIVAL"]		= "Sonnenwendfest"
	L["HARVEST_FESTIVAL"]				= "Erntedankfest"
	L["HALLOWS_END"]					= "Schlotternächte"
	L["FEAST_OF_WINTER_VEIL"]			= "Winterhauchfest"
	L["BREWFEST"]						= "Braufest"
























--[[
    french | In order to avoid missing new things, I sorted the whole locale back to match the original one - Belrand
]]
elseif locale == 'frFR' then
	L["UPDATE_NEWS"] = [[
"Fix de bugs pour les màj récentes, j'ai aussi rajouté des vérifications supplémentaires autour de certaines fonctions.

Les Profiles!
Ils devraient enfin marcher! J'ai migré le tout vers une nouvelle structure du code qui a mis bien trop de temps (désolé pour ça).

Nouveautés!
*Ajout d'un bouton de synchronisation au calendrier 
*Ouvrir les recettes de guilde depuis la fenêtre de guilde Blizzard"
-Stpain

"Beaucoup de changements ont eu lieu et pour mieux organiser la traduction, j'ai du tout restructurer.
Si vous rencontrez des erreurs, merci de me le signaler sur Discord"
-Belrand#1998
]]
	L["DIALOG_SHOW_UPDATES"]			= "Afficher à nouveau"
    L["DIALOG_DONT_SHOW_UPDATES"]		= "Ok, ne plus montrer"

   --options page
    L['OptionsAbout'] = 'Guildbook options et informations. Traduction française par Belrand#1998 (Discord)'
    L['Version'] = 'Version'
    L['Author'] = 'Auteur: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'

    -- this is the start of the option ui updates, will go through the option panel and rewrite it with locales for stuff
    --[[ Added to Options.xml and moved it with the other options further down for the time being -Belrand
    L["TOOLTIP_SHOW_TRADESKILLS"]		= "Affiche une liste de professions utilisant un objet survolé (Les données sont prises de la base de donnée de Guildbook)"
    L["TOOLTIP_SHOW_RECIPES"]			= "Affiche les recettes utilisant l'objet sous chaque profession"
    L["TOOLTIP_SHOW_RECIPES"]			= "N'affiche les recettes que pour les professions de vos personnages"
    --]]
    L["OPTIONS"]						= "Options & Paramètres"
    L["MINIMAP_CALENDAR_RIGHTCLICK"]	= "Clique droit pour menu"
    L["MINIMAP_CALENDAR_EVENTS"]		= "Evénements"

    L["DIALOG_CHARACTER_FIRST_LOAD"]	= "Bienvenue sur Guildbook, cliquer ci-dessous pour scanner vos professions"

    L["NEW_VERSION_1"] = "Une nouvelle version est disponible, probablement pour réparer certaines choses...ou en casser d'autres!"
	L["NEW_VERSION_2"] = "Il y a une nouvelle version de Guildbook, disponible en téléchargement chez tous les bons distributeurs d'Addons!"
	L["NEW_VERSION_3"] = "Haha, si vous pensiez que la dernière MàJ ne changeait pas grand chose, vous devriez télécharger la nouvelle, elle fera probablement la même chose...ou moins!"
	L["NEW_VERSION_4"] = "La Horde est rouge, l'Alliance est bleue, télécharge la nouvelle mise à jour sale paresseux!"

	L["GUILDBOOK_DATA_SHARE_HEADER"]    = "Partage de données Guildbook \n\nVous pouvez partager vos données de Métiers en cliquant sur Exporter pour générer une chaîne caractères. Ensuite, faites un Copier/Coller de cette chaîne quelque part.\nPour importez des données de Métiers, il suffit de coller la chaîne de caractère \nci-dessous et cliquer sur Importer."
	L["GUILDBOOK_LOADER_HEADER"]        = "Bienvenue sur Guildbook"
	L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "Utilisé pour:"

    L["HELP_ABOUT"]						= "Aide & Infos"

-- this is just a quick thing, will make the how section more fleshed out
-- this is a nasty way to do this, its horrible and i need to make the help & about much better
local slashCommandsIcon = CreateTextureMarkup(136377, 64, 64, 16, 16, 0, 1, 0, 1, 0, 0)
local slashCommandsHelp = [[
Slash commands:
Commandes slashs:
/guildbook open : Cela va ouvrir Guildbook
/gb ou /gbk peut être employer à la place de /guildbook

]]
local homeIcon = CreateAtlasMarkup("poi-town", 16, 16)
local homeHelp = 
[[
Acceuil:
Un nouvel affichage pour le registre de votre guilde avec un Fil d'Actualité montrant qui se (dé)connecte ou gagne un niveau ainsi que les demandes de groupes de vos guildeux via l'outil de Recherche de groupe. 

]]
local profileIcon = CreateAtlasMarkup("GarrMission_MissionIcon-Recruit", 16, 16)
local profileHelp = 
[[
Profile:
Vous pouvez sélection votre(vos) spé(s) et sélectionn un personnage principal. Si vous utilisez plusieurs comptes, vous pouvez ajouter un autre personnage que vous pouvez ajouter comme personnage principal. (Les autres personnages seront automatiquement ajouté en sélectionnant le personnage principal.

]]
local tradeskillIcon = CreateAtlasMarkup("Mobile-Blacksmithing", 16, 16)
local tradeskillHelp = 
[[
Métiers (Professions):
Guild va traiter les recettes/ID d'objets quand il chargera, ce procédé peut prendre quelques minutes. Une fois complété, vous pouvez voir les recettes disponibles par métier et/ou par slot d'équipement (tête, mains, pieds, etc).

Guildbook va partager vos recettes connues avec les autres membre de votre guilde.
Ouvrez votre profession pour déclencher le scan des recettes. Cela va les sauvegarder à votre personnage et compte dans la base de données de la guilde et les envoyer aux membres en ligne. Une fois ce processus terminé, les données futures seront envoyé aux membres en ligne quand vous vous connecterez.

Vous pouvez manuellement envoyer des données en ouvrant un métier (léger temps de recharge pour éviter le spam).
Vous pouvez aussi utiliser l'outil d'import/export, cliquez sur l'icône au dessus des professions et suivez les instructions.

]]
local rosterIcon = CreateAtlasMarkup("poi-workorders", 16, 16)
local rosterHelp = [[
Registres de Guildes:
Vous pouvez voir les personnages des autres guildes dont vous êtes membres ici, l'information est prise "tel quel" des donnés de votre addons depuis le fichier "SavedVariable".
Vous pouvez sélectionner la guilde que vous voulez pour voir ses membres et cliquez sur eux pour voir leurs infos.

]]
local searchIcon = CreateAtlasMarkup("shop-games-magnifyingglass", 16, 16)
local searchHelp = 
[[
Recherche:
Utiliser cette fonction pour explorer la base de données de votre Guilde - Trouver une recette, schéma, nom de personnage.

]]
local bankIcon = CreateAtlasMarkup("ShipMissionIcon-Treasure-Map", 16, 16)
local bankHelp = [[
Banque de guilde:
Coming soon

]]
L["HELP_ABOUT_CREDITS"]				= string.format("%s %s %s %s %s %s %s %s %s %s %s %s %s %s", slashCommandsIcon, slashCommandsHelp, homeIcon, homeHelp, profileIcon, profileHelp, tradeskillIcon, tradeskillHelp, rosterIcon, rosterHelp, searchIcon, searchHelp, bankIcon, bankHelp)



    L["CALENDAR_TOOLTIP_LOCKOUTS"] 		= "Verrouillage"



    --mod blizz guild roster, these are key/values in the ModBlizz file that add extra columns
	L['Online']                         = 'En Ligne'
	L['MainSpec']                       = 'Spé Principale'
	L['Rank']                           = 'Rang'
	L['Note']                           = 'Note'
	L['Profession1']                    = 'Métier 1'
	L['Profession2']                    = 'Métier 2'
    L["Fishing"]						= "Pêche"


	-- roster listview and tooltip, these are also sort keys hence the lowercase usage
	L["name"]                           = "Nom"
	L["level"]                          = "Niv."
	L["mainSpec"]                       = "Spé Principale"
	L["prof1"]                          = "Métiers"
	L["location"]                       = "Zone"
	L["rankName"]                       = "Rang"
	L["publicNote"]                     = "Note Publique"
	L["class"]                          = "Classe"
	L["attunements"]                    = "Accès"


	-- xml strings
	L["PROFILE_TITLE"]                  = "Profil"
	L["REAL_NAME"]                      = "Nom"
	L["REAL_DOB"]                       = "Anniversaire"
	L["REAL_BIO"]                       = "Biographie"
	L["AVATAR"]                         = "Avatar"
	L["MAIN_CHARACTER"]                 = "Personnage Principal"
	L["ALT_CHARACTERS"]                 = "Autres Persos"
	L["MAIN_SPEC"]                      = "Spé Principale"
	L["OFF_SPEC"]                       = "Spé Secondaire"
	L["PRIVACY"]                        = "Confidentialité"
	L["PRIVACY_ABOUT"]                  = "Choisir à partir de quel Rang vous souhaitez partager vos données.\nProfil contient Nom, Anniversaire et Avatar. \nInventaire contient l'équipement de votre personnage (|cffFFD100PAS|r vos sacs/banques). \nLes Talents sont...vos Talents."
	L["INVENTORY"]                      = "Inventaire"
	L["TALENTS"]                        = "Talents"

	L["ROSTER_MY_CHARACTERS"]			= "Mes personnages"
	L["ROSTER_ALL_CLASSES"]				= "Toutes"
	L["ROSTER_ALL_RANKS"]				= "Tous"

	L["ROSTER_VIEW_RECIPES"]			= "Cliquez pour voir les recettes"

    --tradeskills
	L["TRADESKILLS"]		    		= "Métiers"
	L["TRADESKILLS_RECIPES"]	   		= "Recettes"
    L["TRADESKILLS_REAGENTS"]			= "Compsants"
	L["TRADESKILLS_CHARACTERS"]	    	= "Personnages"
	L["TRADESKILL_GUILD_RECIPES"]	    = "Recettes en Guilde"
	L["TRADESKILLS_SHARE_RECIPES"]	    = "Partager les recettes du personnage"
	L["TRADESKILLS_EXPORT_RECIPES"]		= "Importer ou exporter données de Métiers"
	L["IMPORT"]							= "Importer"
	L["EXPORT"]							= "Exporter"
	L["CAN_CRAFT"]                      = "[Guildbook] Peux-tu faire %s ?"
	L["REMOVE_RECIPE_FROM_PROF_SS"]		= "Enlever %s de %s ?"
	L["REMOVE_RECIPE_FROM_PROF"]		= "Clique droit pour enlever de cette profession."
	L["PROCESSED_RECIPES_SS"]			= "Traité %s de %s recettes"
	L["TRADESKILL_SLOT_FILTER_S"]		= "Filtré par objets : %s"
	L["TRADESKILL_SLOT_REMOVE"]			= "Réinitialiser filtres"
	L["HEAD"]							= "Tête"
	L["SHOULDER"]						= "Épaule"
	L["BACK"]							= "Dos"
	L["CHEST"]							= "Torse"
	L["WRIST"]							= "Poignets"
	L["HANDS"]							= "Mains"
	L["WAIST"]							= "Taille"
	L["LEGS"]							= "Jambes"
	L["FEET"]							= "Pieds"
	L["WEAPONS"]						= "Armes"
	L["OFF_HAND"]						= "Main gauche"
	L["MISC"]							= "Autres"
	L["CONSUMABLES"]					= "Consommables"



	--guildbank
	L["PHASE2GB"]						= "Avec l'arrivée des banques de guilde sur TBCC, j'ai décidé d'enlever le système de banque de Guildbook. Néanmoins, je travaille sur quelque chose afin de le remplacer!"
	L['GUILDBANK']						= "Banque de Guilde"
	L["GUILDBANK_HEADER_ITEM"]			= "Objets"
	L["GUILDBANK_HEADER_COUNT"]			= "Nombre"
	L["GUILDBANK_SORT_TYPE"]			= "Catégorie"
	L["GUILDBANK_HEADER_SUBTYPE"]		= "Sous-catégorie"
	L["GUILDBANK_SORT_BANK"]			= "Source"
	L["GUILDBANK_REFRESH"]				= "Actualiser"
	L["GUILDBANK_ALL_BANKS"]			= "Toutes les banques"
	L["GUILDBANK_ALL_TYPES"]			= "Toutes les catégories"
	L["GUILDBANK_REQUEST_COMMITS"]		= "requête d'un commit de "
	L["GUILDBANK_REQUEST_INFO"]			= "requête de données de "
	L["GUILDBANK_FUNDS"]				= "Or disponible"
	L["GUILDBANK_CURRENCY"]				= "Monnaie"

	L["HOME"]							= "Accueil"
	L["PROFILES"]                       = "Profils"
	L["CHAT"]                           = "Chat"
	L["GUILD_VIEWER"]                   = "Registres de guildes"
	L["CALENDAR"]                       = "Calendrier"
	L["SEARCH"]                         = "Rechercher"
	L["MY_PROFILE"]                     = "Mon profil"
	L["OPEN_PROFILE"]                   = "Ouvrir profil"
	L["OPEN_CHAT"]                      = "Ouvrir chat"
	L["INVITE_TO_GROUP"]                = "Inviter dans un groupe"
	L["SEND_TRADE_ENQUIRY"]             = "Envoyer un message à propos de l'objet"
	L["REFRESH_ROSTER"]                 = "Rafraîchir registre"
	L["EDIT"]                           = "Modifier profil"
	L["GUILD_BANK"]                     = "Banque de Guilde"
	L["ALTS"]                           = "Personnages secondaires"
	L["USE_MAIN_PROFILE"]               = "Utiliser profil du Personnage Principal"
	L["MY_SACKS"]                       = "Mes sacs"
	L["BAGS"]                           = "Sacs"
	L["BANK"]                           = "Banque"
	L["STATS"]                          = "Statistiques"

    --news feed stuff
    L["GUILD_ACTIVTY_HEADER"]			= "Fil d'Actualité"
    L["GUILD_MEMBERS_HEADER"]			= "Membres (|cffFFD100maj enfoncé pour plus d'info|r)"
    L["GUILD_MEMBERS_OFFLINE"]			= "Voir les membres déconnectés"
	L["NF_PLAYER_LEVEL_UP_SS"]			= "%s a atteint le niveau %s!"
	L["NF_PLAYER_LOGIN_S"]				= "%s s'est connecté"
	L["NF_PLAYER_LOGOUT_S"]				= "%s s'est déconnecté"
	--L["NF_LFG_CREATED_S"]				= "%s"



   --privacy and options

    L["PRIVACY_SHARE_LFG"]				= "Partager votre usage de l'outil RDG"
    L["PRIVACY_SHARE_LEVEL_UP"]			= "Partager vos prises de niveau"
   --L[""]

    L["OPT_SHOW_MINIMAP_BUTTON"]		= "Afficher le bouton de la minicarte"
    L["OPT_SHOW_MINIMAP_CALENDAR"]		= "Afficher le bouton calendrier de la minicarte"
    L["OPT_MOD_BLIZZ_ROSTER"]			= "Modifier l'onglet de Guilde de Blizzard"
    L["OPT_COMBAT_COMMS_LOCK"]			= "Bloquer le traffic de données pendant les combats"
    L["OPT_INSTANCE_COMMS_LOCK"]		= "Bloquer le traffic de données dans les instances"

    L["OPT_TT_CHAR_SHOW_INFO"]			= "Montrer info des personnages"
    L["OPT_TT_CHAR_MAIN_SPEC"]			= "Spé Principale"
    L["OPT_TT_CHAR_TRADESKILLS"]		= "Métiers"
    L["OPT_TT_CHAR_MAIN_CHAR"]			= "Personnage Principal"

    L["OPT_TT_TRADESKILLS_SHOW"]		= "Montrer les métiers"
    L["OPT_TT_TRADESKILLS_RECIPES"]		= "Montrer les recettes"
	L["OPT_TT_TRADESKILLS_PERSONAL"]	= "Ne montrer les recetters que pour vos métiers"

   --options dialogs boxes
   --Dialogs.lua
    L["OPT_RELOAD_UI"]                  = "Rercharger Interface"
    L["OPT_SETTINGS_CHANGED"]           = "Certains Paramètres ont été changés et un rechargement de l'interface est nécessaire"
    L["OPT_DELETE_GUILD_DATA"]          = 'Supprimer les données de %s?'
    L["OPT_RESET_CHAR_DATA" ]           = 'Réinitialiser les données de '..select(1, UnitName("player"))..' aux valeurs par défaut?'
    L["OPT_RESET_CACHE_CHAR_DATA"]      = 'Réinitialiser les données de %s?' --couldn't be tested -Belrand
    L["OPT_RESET_GLOBAL_SETTINGS"]      = 'Réinitialiser les données globales de l\'addon? \n\nCela va supprimer les données concernant les guildes dont vous êtes membres.'
    --Options.xml these are loaded at the end of the file with other xml variables
    L["OPT_SH_MINIMAP_BUTTON"]          = 'Activer/Désactiver bouton de la minicarte'
    L["OPT_SH_MINICAL_BUTTON"]          = 'Activer/Désactiver bouton calendrier de la minicarte'
    L["OPT_BLIZZROSTER"]                = 'Modifier l\'onglet de guilde Blizzard'
    --L["OPT_INFO_MESSAGE"]
    L["OPT_BLOCK_DATA_COMBAT"]          = "Guildbook va bloquer l'échange de données tant que vous êtes en combat"
    L["OPT_BLOCK_DATA_INSTANCE"]        = "Guildbook va bloquer l'échange de données tant que vous êtes dans une instance"

    L["OPT_TT_DIALOG_SCI"]              = "Montrer plus d'info sur le membre de guilde dans le tooltip"
    L["OPT_TT_DIALOG_SCMS"]             = "Montrer la spé principale du personnage dans le tooltip"
    L["OPT_TT_DIALOG_SCP"]              = "Montrer les métiers du personnages dans le tooltip"
    L["OPT_TT_DIALOG_SMC"]              = "Monter le personnage principale dans le tooltip"
    --
    L["OPT_TT_DIALOG_DPL"]              = "Affiche une liste de métiers utilisant l'objet comme régent (basé sur vos données Guildbook)"
    L["OPT_TT_DIALOG_DLR"]              = "Inclure les recettes utilisant l'objet comme régent sous chaque métier"
    L["OPT_TT_DIALOG_DLRCO"]            = "Ne montrer que les recettes de VOS personnages"

    L["OPT_CHAT_SMCO"]                  = "Montrer le personnage principal d'un reroll dans le chat de guilde (selon de la préférence du dit joueur)"
    L["OPT_CHAT_SMS"]                   = "Montrer la spécialisation du personnage dans le chat de guilde (selon de la préférence du dit joueur)"


    --Buttons
	L["YES"] = 'Oui'
	L["CANCEL"] = 'Annuler'
	L["RESET"] = 'Reset'
	L["DELETE"] = "Supprimer"


--guildViewer
    L["GUILD_VIEWER_HEADER"]			= "Vous pouvez voir les personnages des autres guildes dont vous êtes membres ici, l'information est prise \"tel quel\" des donnés de votre addons. Sélectionnez la guilde que vous voulez pour voir ses membres et cliquez sur eux pour voir leurs infos."

    L["RESET_AVATAR"]					= "Défaut"

	L["PRIVACY_HEADER"]                 = "Paramètres de confidentialité"
	L["NONE"] 			    			= "Aucun"
	L["SHARING_NOBODY"]		    		= "Partager avec personne"
	L["SHARING_WITH"]		    		= "Partager avec"

	L["MAIN_CHARACTER_ADD_ALT"]			= "Ajouter personage.\n|cffFFFF00Utilisez ceci pour ajouter un personnage venant d'un compte autre compte. Vous serez ensuite capable de le sélectionner comme personnage principal."
	L["MAIN_CHARACTER_REMOVE_ALT"]		= "Enlever personnage"
	L["DIALOG_MAIN_CHAR_ADD"]			= "Tapez le nom du personnage, il doit être membre de la guilde."
	L["DIALOG_MAIN_CHAR_REMOVE"]		= "SVP, entrez le nom du personnage."
	L["DIALOG_MAIN_CHAR_ADD_FOUND"]		= "Personnage trouvé: %s Niveau %s %s"

	--attributes
	L["STRENGTH"]                   = "Force"
	L["AGILITY"]                    = "Agilité"
	L["STAMINA"]                    = "Endurance"
	L["INTELLECT"]                  = "Intelligence"
	L["SPIRIT"]                     = "Esprit"
	--defence
	L["ARMOR"]                      = "Armure"
	L["DEFENSE"]                    = "Défense"
	L["DODGE"]                      = "Esquive"
	L["PARRY"]                      = "Parade"
	L["BLOCK"]                      = "Blocage"
	--melee
	L["EXPERTISE"]                  = "Expertise"
	L["HIT_CHANCE"]                 = "Chance de toucher"
	L["MELEE_CRIT"]                 = "Chance de crit"
	L["MH_DMG"]                     = "Dégâts main droite"
	L["OH_DMG"]                     = "Dégâts main gauche"
	L["MH_DPS"]                     = "DPS main droite"
	L["OH_DPS"]                     = "DPS main gauche"
	--ranged
	L["RANGED_HIT"]                 = "Chance de toucher"
	L["RANGED_CRIT"]                = "Chance de crit"
	L["RANGED_DMG"]                 = "Dégâts"
	L["RANGED_DPS"]                 = "DPS"
	--spells
	L["SPELL_HASTE"]                = "Hâte"
	L["MANA_REGEN"]                 = "Régen mana"
	L["MANA_REGEN_CASTING"] 		= "Régen mana(incantation)"
	L["SPELL_HIT"]                  = "Chance de toucher"
	L["HEALING_BONUS"]              = "Pouvoir de guérison"
	L["SPELL_DMG_HOLY"]             = "Sacré"
	L["SPELL_DMG_FROST"]			= "Givre"
	L["SPELL_DMG_SHADOW"]			= "Ombre"
	L["SPELL_DMG_ARCANE"]			= "Arcane"
	L["SPELL_DMG_FIRE"]             = "Feu"
	L["SPELL_DMG_NATURE"]			= "Nature"



	-- class and spec
	-- class is upper case
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
	L["Warden"]			    = "Gardien"
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
	L['BeastMaster']                   	= 'Maîtrise des Bêtes' -- the smart detect spec system could return this value
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

    --odds
    L["Warden"]							= "Gardien"
    L["Frost (Tank)"]					= "Givre (Tank)"

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

-- calendar help icon
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


	--legacy stuff
	L["SELECT_BANK_CHARACTER"]          = "Sélectionner la Banque"
	L["DUNGEON"]                        = "Donjon"
	L["RAID"]                           = "Raid"
	L['PVP']                            = 'JcJ'
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
	L["LATE"]                           = "Retard"
	L["TENTATIVE"]                      = "Tentative"
	L["DECLINE"]                        = "Décliner"

	L["TIME"]							= "Time"
	L["YEARS"]                          = "années"
	L["MONTHS"]                         = "mois"
	L["DAYS"]                           = "jours"
	L["HOURS"]                          = "heures"
	L['< an hour']			    		= 'moins d\'1h'

	L["GENERAL"]                        = "Général"
	L["MINIMAP_TOOLTIP_LEFTCLICK"]      = '|cffffffffClique Gauche|r Ouvrir Guildbook'
	L["MINIMAP_TOOLTIP_LEFTCLICK_SHIFT"]= "MAJ + "..'|cffffffffClique Gauche|r Ouvrir Chat'
	L["MINIMAP_TOOLTIP_RIGHTCLICK"]	    = '|cffffffffClique Droit|r Options'
	L["MINIMAP_TOOLTIP_MIDDLECLICK"]	= "|cffffffffClique molette|r Ouvrir l'onglet de guilde Blizzard"

	--raids name
	L["MC"]				    = "Coeur du Magma"
	L["BWL"]			    = "Repaire de l'Aile noire"
	L["AQ20"]               = "AQ20"
	L["AQ40"]			    = "AQ40"
	L["Naxxramas"]		    = "Naxxramas"
	L["ZG"]				    = "Zul'Gurub"
	L["Onyxia"]			    = "Onyxia"
	L["Magtheridon"]		= "Repaire de Magtheridon"
	L["SSC"]			    = "Caverne du sanctuaire du Serpent" --this is way too long wtf
	L["TK"]				    = "Donjon de la tempête"
	L["Gruul"]			    = "Repaire de Gruul"
	L["Hyjal"]			    = "Sommet d'Hyjal"
	L["SWP"]			    = "Plateau du Puits de soleil"
	L["BT"]				    = "Temple noir"
	L["Karazhan"]			= "Karazhan"

	--availability (Data.lua)
	L['Not Available'] 		    = 'Indisponible'
	L['Morning'] 			    = 'Matin'
	L['Afternoon'] 			    = 'Après-midi'
	L['Evening'] 			    = 'Soir'

	--world events
	L["DARKMOON_FAIRE"]					= "Foire de Sombrelune"
	L["DMF display"]					= '|cffffffffFoire de Sombrelune - ' --this is needed for the calendar
	L["LOVE IS IN THE AIR"]				= "De l'amour dans l'air"
	L["CHILDRENS_WEEK"]					= "Semaine des enfants"			
	L["MIDSUMMER_FIRE_FESTIVAL"]		= "Fête du Feu du solstice d'été"
	L["HARVEST_FESTIVAL"]				= "Fête des moissons"
	L["HALLOWS_END"]					= "Sanssaint "
	L["FEAST_OF_WINTER_VEIL"]			= "Voile d'hiver"
	L["BREWFEST"]						= "Fête des Brasseurs"















--thanks to Эхо from discord for these translations

elseif locale == "ruRU" then

	--options page
	L['OptionsAbout'] = 'Опции Guildbook. Спасибо Калимер@Пламегор и гильдии <Чистое небо>@Рок-Делар за перевод на русский язык. Если Вы обнаружили опечатку или ошибку - сообщите Эхо#8608 (Discord)'
	L['Version'] = 'Версия'
	L['Author'] = 'Автор: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'
	
	L["OPTIONS"]                        = "Опции и настройки"
	L["MINIMAP_CALENDAR_RIGHTCLICK"]    = "Щелкните ПКМ, чтобы открыть меню"
	L["MINIMAP_CALENDAR_EVENTS"]        = "События"
	
	L["DIALOG_CHARACTER_FIRST_LOAD"]    = "Добро пожаловать в Guildbook. Нажмите, чтобы просканировать профессии ваших персонажей."
	
	L["NEW_VERSION_1"] = "Доступна новая версия. Возможно, кое-что исправлено, а может быть мы что-то и сломали!"
	L["NEW_VERSION_2"] = "Доступна совершенно новая классная версия аддона, которую можно скачать из открытых источников!"
	L["NEW_VERSION_3"] = "Хах, если вы думали, что последнее обновление было незначительным, то скачайте новое. Оно примерно такое же... или даже еще меньше!"
	L["NEW_VERSION_4"] = "Орда - красная, Альянс - синий, новая обнова - только для тебя!"
	
	L["GUILDBOOK_DATA_SHARE_HEADER"]    = "Поделиться данными Guildbook \n\nВы можете поделиться информацией о своих профессиях, нажав кнопку «Экспорт», чтобы сгенерировать код. Затем скопируйте его и вставьте куда-нибудь - например, в Discord. \nЧтобы импортировать данные - нажмите соответствующую кнопку."
	L["GUILDBOOK_LOADER_HEADER"]        = "Добро пожаловать в Guildbook"
	L["TOOLTIP_ITEM_RECIPE_HEADER"]     = "Используется для"
	
	L["HELP_ABOUT"]                     = "Помощь & Об аддоне"
	
	-- this is just a quick thing, will make the how section more fleshed out
	-- this is a nasty way to do this, its horrible and i need to make the help & about much better
	local slashCommandsIcon = CreateTextureMarkup(136377, 64, 64, 16, 16, 0, 1, 0, 1, 0, 0)
	local slashCommandsHelp = [[
	Команды:
	Вы можете использовать /guildbook, /gbk или /gb.
	/guildbook open - открыть Guildbook
	/guildbook [interface] - открыть определенный раздел (список гильдии, профессии, чат, профили, календарь, статистика, банк гильдии, поиск, приватность)
	
	]]
	local rosterIcon = CreateAtlasMarkup("poi-workorders", 16, 16)
	local rosterHelp = [[
	Список гильдии:
	Вы можете отсортировать список гильдии, кликнув по названию колонки. Например, нажав на заголовок "Класс" или "Звание" вы отфильтруете всех участников в опреденном порядке.
	
	]]
	local tradeskillIcon = CreateAtlasMarkup("Mobile-Blacksmithing", 16, 16)
	local tradeskillHelp = 
	[[
	Профессии:
	Guildbook будет сканировать рецепты игроков при загрузке и этот процесс может занять несколько минут. После завершения вы сможете посмотреть доступные рецепты по профессиям или слотам экипировки (голова, кисти рук, ступни и т.д.).
	
	Guildbook отправляет список ваших рецептов другим членам гильдии. Откройте окно профессии, чтобы запустить сканирование рецептов. Полученные данные будут сохранены в вашем профиле и отправлены членам гильдии, находящимся в сети. 
	Данные будут отправляться каждый раз, когда вы входите в игру и открываете окно профессии. Обновление можно запустить вручную: нажмите кнопку "Импорт/экспорт" над списком профессий и следуйте инструкциям. 
	
	]]
	local profileIcon = CreateAtlasMarkup("GarrMission_MissionIcon-Recruit", 16, 16)
	local profileHelp = 
	[[
	Профиль:
	Редактируйте по своему желанию. Добавлять персональную информацию о себе или нет - решать только вам.
	Вы можете выбрать свою основную специализацию и указать основного персонажа. Если вы используете несколько учетных записей, вы можете добавить еще одного персонажа, которого затем можно будет выбрать в качестве основного. (Альты устанавливаются выбором главного героя из профиля альтов).
	
	]]
	local searchIcon = CreateAtlasMarkup("shop-games-magnifyingglass", 16, 16)
	local searchHelp = 
	[[
	Поиск:
	Используйте этот инструмент для поиска внутри своей гильдии. Ищите название рецепта, имя персонажа и многое другое.
	
	]]
	local bankIcon = CreateAtlasMarkup("ShipMissionIcon-Treasure-Map", 16, 16)
	local bankHelp = [[
	Coming soon
	]]
	L["HELP_ABOUT_CREDITS"]             = string.format("%s %s %s %s %s %s %s %s %s %s %s %s", slashCommandsIcon, slashCommandsHelp, rosterIcon, rosterHelp, tradeskillIcon, tradeskillHelp, profileIcon, profileHelp, searchIcon, searchHelp, bankIcon, bankHelp)
	
	
	
	--mod blizz guild roster, these are key/values in the ModBlizz file that add extra columns
	L['Online']                         = 'В сети'
	L['MainSpec']                       = 'Специализация'
	L['Rank']                           = 'Звание'
	L['Note']                           = 'Заметка'
	L['Profession1']                    = 'Профессия 1'
	L['Profession2']                    = 'Профессия 2'
	
	
	-- roster listview and tooltip, these are also sort keys and should be lower case
	L["name"]                           = "Имя"
	L["level"]                          = "Ур."
	L["mainSpec"]                       = "Специализация"
	L["prof1"]                          = "Профессии"
	L["location"]                       = "Зона"
	L["rankName"]                       = "Звание"
	L["publicNote"]                     = "Заметка"
	L["class"]                          = "Класс"
	L["attunements"]                    = "Достижения"
	
	
	-- xml strings
	L["PROFILE_TITLE"]                  = "Профиль"
	L["REAL_NAME"]                      = "Имя"
	L["REAL_DOB"]                       = "День рождения"
	L["REAL_BIO"]                       = "О себе"
	L["AVATAR"]                         = "Аватар"
	L["MAIN_CHARACTER"]                 = "Основной персонаж"
	L["ALT_CHARACTERS"]                 = "Альт"
	L["MAIN_SPEC"]                      = "Специализация"
	L["OFF_SPEC"]                       = "Оффспек"
	L["PRIVACY"]                        = "Приватность"
	L["PRIVACY_ABOUT"]                  = "Установите минимиальное звание, кому будет предоставлена информация профиля. Данные профиля включают имя, дату рождения, о себе и аватар. Инвентарь включает надетую экипировку (НЕ сумки/банк). Таланты, как ни странно, это ваши таланты"
	L["INVENTORY"]                      = "Инвентарь"
	L["TALENTS"]                        = "Таланты"
	
	L["ROSTER_MY_CHARACTERS"]           = "Мои персонажи"
	L["ROSTER_ALL_CLASSES"]             = "Все классы"
	L["ROSTER_ALL_RANKS"]               = "Все звания"
	
	L["TRADESKILLS"]                    = "Профессии"
	L["TRADESKILLS_RECIPES"]            = "Рецепты"
	L["TRADESKILLS_CHARACTERS"]         = "Персонажи"
	L["TRADESKILL_GUILD_RECIPES"]       = "Гильдейские рецепты"
	L["TRADESKILLS_SHARE_RECIPES"]      = "Поделиться рецептами этого персонажа"
	L["TRADESKILLS_EXPORT_RECIPES"]     = "Импорт/экспорт"
	L["IMPORT"]                         = "Импорт"
	L["EXPORT"]                         = "Экспорт"
	L["CAN_CRAFT"]                      = "[Guildbook] умеешь ли ты делать %s ?"
	L["REMOVE_RECIPE_FROM_PROF_SS"]     = "Удалить %s из %s ?"
	L["REMOVE_RECIPE_FROM_PROF"]        = "Кликни ПКМ, чтобы удалить из этой профессии."
	L["PROCESSED_RECIPES_SS"]           = "Обработано %s из %s рецептов"
	L["TRADESKILL_SLOT_FILTER_S"]       = "Фильтр: %s"
	L["TRADESKILL_SLOT_REMOVE"]         = "Сбросить фильтры"
	L["HEAD"]                           = "голова"
	L["SHOULDER"]                       = "плечи"
	L["BACK"]                           = "спина"
	L["CHEST"]                          = "грудь"
	L["WRIST"]                          = "наручи"
	L["HANDS"]                          = "кисти рук"    
	L["WAIST"]                          = "пояс"
	L["LEGS"]                           = "ноги"
	L["FEET"]                           = "ступни"
	L["WEAPONS"]                        = "оружие"
	L["OFF_HAND"]                       = "левая рука"  
	L["MISC"]                           = "разное"
	L["CONSUMABLES"]                    = "расходуемые"
	
	
	L["PHASE2GB"]                       = "С появлением гильдейских банков в TBCC аналогичная система в Guildbook удалена. Я работаю над тем, чтобы заменить его чем-либо!"
	L['GUILDBANK']                      = "Банк гильдии"
	L["GUILDBANK_HEADER_ITEM"]          = "Item link"
	L["GUILDBANK_HEADER_COUNT"]         = "Count"
	L["GUILDBANK_SORT_TYPE"]            = "Type"
	L["GUILDBANK_HEADER_SUBTYPE"]       = "Subtype"
	L["GUILDBANK_SORT_BANK"]            = "Source"
	L["GUILDBANK_REFRESH"]              = "Refresh"
	L["GUILDBANK_ALL_BANKS"]            = "All banks"
	L["GUILDBANK_ALL_TYPES"]            = "All types"
	L["GUILDBANK_REQUEST_COMMITS"]      = "requesting commits for "
	L["GUILDBANK_REQUEST_INFO"]         = "requesting data from "
	L["GUILDBANK_FUNDS"]                = "Gold available"
	L["GUILDBANK_CURRENCY"]             = "Currency"
	
	L["PROFILES"]                       = "Профили"
	L["CHAT"]                           = "Чат"
	L["ROSTER"]                         = "Список гильдии"
	L["CALENDAR"]                       = "Календарь"
	L["SEARCH"]                         = "Поиск"
	L["MY_PROFILE"]                     = "Мой профиль"
	L["OPEN_PROFILE"]                   = "Открыть профиль"
	L["OPEN_CHAT"]                      = "Открыть чат"
	L["INVITE_TO_GROUP"]                = "Пригласить в группу"
	L["SEND_TRADE_ENQUIRY"]             = "Отправить сообщение о предмете"
	L["REFRESH_ROSTER"]                 = "Обновить список"
	L["EDIT"]                           = "Редактировать профиль"
	L["GUILD_BANK"]                     = "Бесполезная подсказка!"
	L["ALTS"]                           = "Все персонажи"
	L["USE_MAIN_PROFILE"]               = "Использовать профиль основного персонажа"
	L["MY_SACKS"]                       = "Мои сумки"
	L["BAGS"]                           = "Сумки"
	L["BANK"]                           = "Банк"
	L["STATS"]                          = "Статистика"
	
	L["RESET_AVATAR"]                   = "Удалить аватар"
	
	L["PRIVACY_HEADER"]                 = "Настройки приватности"
	L["NONE"]                           = ""
	L["SHARING_NOBODY"]                 = "Ни с кем не делиться"
	L["SHARING_WITH"]                   = "Поделиться с"
	
	L["MAIN_CHARACTER_ADD_ALT"]         = "Добавить персонажа.\n|cffFFFF00Используйте это, чтобы добавить персонажа с другой учетной записи, после чего вы сможете указать его как основного"
	L["MAIN_CHARACTER_REMOVE_ALT"]      = "Удалить персонажа"
	L["DIALOG_MAIN_CHAR_ADD"]           = "Введите имя вашего персонажа. Он должен быть членом гильдии."
	L["DIALOG_MAIN_CHAR_REMOVE"]        = "Пожалуйста, введите имя персонажа."
	L["DIALOG_MAIN_CHAR_ADD_FOUND"]     = "Найти персонажа: %s Уровень: %s %s"
	
	--attributes
	L["STRENGTH"]                       = "Сила"
	L["AGILITY"]                        = "Ловкость"
	L["STAMINA"]                        = "Выносливость"
	L["INTELLECT"]                      = "Интеллект"
	L["SPIRIT"]                         = "Дух"
	--defence
	L["ARMOR"]                          = "Броня"
	L["DEFENSE"]                        = "Защита"
	L["DODGE"]                          = "Уклонение"
	L["PARRY"]                          = "Парирование"
	L["BLOCK"]                          = "Блок"
	--melee
	L["EXPERTISE"]                      = "Мастерство"
	L["HIT_CHANCE"]                     = "Меткость"
	L["MELEE_CRIT"]                     = "Крит"
	L["MH_DMG"]                         = "Урон основного оружия"
	L["OH_DMG"]                         = "Урон оружия в левой руке"
	L["MH_DPS"]                         = "УвС основного оружия"
	L["OH_DPS"]                         = "УвС оружия в левой руке"
	--ranged
	L["RANGED_HIT"]                     = "Меткость"
	L["RANGED_CRIT"]                    = "Крит"
	L["RANGED_DMG"]                     = "Урон"
	L["RANGED_DPS"]                     = "УвС"
	--spells
	L["SPELL_HASTE"]                    = "Скорость чтения заклинаний"
	L["MANA_REGEN"]                     = "Реген маны"
	L["MANA_REGEN_CASTING"]             = "Реген маны (при прочтении заклинаний)"
	L["SPELL_HIT"]                      = "Меткость"
	L["SPELL_CRIT"]                     = "Крит"
	L["HEALING_BONUS"]                  = "Бонус исцеления"
	L["SPELL_DMG_HOLY"]                 = "Свет"
	L["SPELL_DMG_FROST"]                = "Лёд"
	L["SPELL_DMG_SHADOW"]               = "Тьма"
	L["SPELL_DMG_ARCANE"]               = "Тайная магия"
	L["SPELL_DMG_FIRE"]                 = "Огонь"
	L["SPELL_DMG_NATURE"]               = "Природа"
	
	
	
	-- class and spec
	-- class is upper case
	L['DEATHKNIGHT']                    = 'Рыцарь смерти'
	L['DRUID']                          = 'Друид'
	L['HUNTER']                         = 'Охотник'
	L['MAGE']                           = 'Маг'
	L['PALADIN']                        = 'Паладин'
	L['PRIEST']                         = 'Жрец'
	L['SHAMAN']                         = 'Шаман'
	L['ROGUE']                          = 'Разбойник'
	L['WARLOCK']                        = 'Чернокнижник'
	L['WARRIOR']                        = 'Воин'
	--mage/dk
	L['Arcane']                         = 'Тайная магия'
	L['Fire']                           = 'Огонь'
	L['Frost']                          = 'Лёд'
	L['Blood']                          = 'Кровь'
	L['Unholy']                         = 'Нечестивость'
	--druid/shaman
	L['Restoration']                    = 'Восстановление'
	L['Enhancement']                    = 'Совершенствование'
	L['Elemental']                      = 'Стихии'
	L["Warden"]                         = "Страж"
	L['Cat']                            = 'Кот'
	L['Bear']                           = 'Медведь'
	L['Balance']                        = 'Баланс'
	L['Guardian']                       = 'Страж'
	L["Feral"]                          = "Сила зверя"
	--rogue
	L['Assassination']                  = 'Ликвидация'
	L['Combat']                         = 'Бой'
	L['Subtlety']                       = 'Скрытность'
	--hunter
	L['Marksmanship']                   = 'Стрельба'
	L['Beast Master']                   = 'Чувство зверя'
	L['BeastMaster']                    = 'Чувство зверя' -- the smart detect spec system could return this value
	L['Survival']                       = 'Выживание'
	--warlock
	L['Destruction']                    = 'Разрушение'
	L['Affliction']                     = 'Колдовство'
	L['Demonology']                     = 'Демонология'
	--warrior/paladin/priest
	L['Fury']                           = 'Неиствовство'
	L['Arms']                           = 'Оружие'
	L['Protection']                     = 'Защита'
	L['Retribution']                    = 'Воздаяние'
	L['Holy']                           = 'Свет'
	L['Discipline']                     = 'Послушание'
	L['Shadow']                         = 'Тьма'
	
	--odds
	L["Warden"]                         = "Страж"
	L["Frost (Tank)"]                   = "Лёд (Танк)"
	
	--date time
	L['JANUARY']                        = 'Января'
	L['FEBRUARY']                       = 'Февраля'
	L['MARCH']                          = 'Марта'
	L['APRIL']                          = 'Апреля'
	L['MAY']                            = 'Мая'
	L['JUNE']                           = 'Июня'
	L['JULY']                           = 'Июля'
	L['AUGUST']                         = 'Августа'
	L['SEPTEMBER']                      = 'Сентября'
	L['OCTOBER']                        = 'Октября'
	L['NOVEMBER']                       = 'Ноября'
	L['DECEMBER']                       = 'Декабря'
	
	L["MONDAY"]                         = "Понедельник"
	L["TUESDAY"]                        = "Вторник"
	L["WEDNESDAY"]                      = "Среда"
	L["THURSDAY"]                       = "Четверг"
	L["FRIDAY"]                         = "Пятница"
	L["SATURDAY"]                       = "Суббота"
	L["SUNDAY"]                         = "Воскресенье"
	
	
	-- old stuff but might use again
	L['GuildBank']                      = 'Банк гильдии'
	L['Events']                         = 'События'
	L['WorldEvents']                    = 'Мировые события'
	L['Attunements']                    = 'Достижения'
	L["Guild"]                          = "Гильдия"
	
	
	L['Roles']                          = 'Роли'
	L['Tank']                           = 'Танк'
	L['Melee']                          = 'Ближний бой'
	L['Ranged']                         = 'Дальний бой'
	L['Healer']                         = 'Целитель'
	L['ClassRoleSummary']               = 'Сводка по классам и ролям'
	L['RoleChart']                      = 'Роли (участники в сети'
	L['ClassChart']                     = 'Классы (все участники)'
	
	-- calendar help icon
	L['calendarHelpText'] = [[
	Calendar
	
	|cffffffffВ [Guildbook] включён внутриигровой календарь событий гильдии, основанный на старой версии календаря
	Blizzard. В слоте каждого дня отображается до трёх событий (в будущем их количество будет увеличено).|r
	
	|cff00BFF3Календарь синхронизирует данные между игроками, когда игрок входит в игру, а также при создании, удалении или изменении события. Синхронизацию между всеми игроками гильдии нельзя гарантировать, так как для передачи данных между игроками они должны быть в сети.
	
	Для уменьшения объёма передаваемых данных синхронизируются только события ближайших 4 недель.
	Вы можете создавать события на любые даты, но они будут синхронизироваться только когда до них будет оставаться менее 4 недель.|r.
	]]
	
	--guildbank help icon
	L["GUILDBANKHELPTEXT"]  = [[
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
	L["SELECT_BANK_CHARACTER"]          = "Выбрать банковского персонажа"
	L["DUNGEON"]                        = "Подземелье"
	L["RAID"]                           = "Рейд"
	L['PVP']                            = 'PvP'
	L["MEETING"]                        = "Встреча"
	L["OTHER"]                          = "Другое"
	L["GUILD_CALENDAR"]                 = "Календарь гильдии"
	L["INSTANCE_LOCKS"]                 = "Заблокированные подземелья"
	L["CREATE_EVENT"]                   = "Создать событие"
	L["DELETE_EVENT"]                   = "Удалить событие"
	L["EVENT"]                          = "Событие"
	L["EVENT_TYPE"]                     = "Тип события"
	L["TITLE"]                          = "Заголовок"
	L["DESCRIPTION"]                    = "Описание"
	L["UPDATE"]                         = "Обновить"
	L["ATTENDING"]                      = "Посетить"
	L["TENTATIVE"]                      = "Возможно"
	L["DECLINE"]                        = "Отклонить"
	
	L["YEARS"]                          = "годы"
	L["MONTHS"]                         = "месяцев"
	L["DAYS"]                           = "дней"
	L["HOURS"]                          = "часов"
	L['< an hour']                      = '< меньше часа'
	
	L["GENERAL"]                        = "Основные"
	L["MINIMAP_TOOLTIP_LEFTCLICK"]      = '|cffffffffLeft Click|r Открыть Guildbook'
	L["MINIMAP_TOOLTIP_LEFTCLICK_SHIFT"]= "Shift + "..'|cffffffffLeft Click|r Открыть чат'
	L["MINIMAP_TOOLTIP_RIGHTCLICK"]     = '|cffffffffRight Click|r Опции'
	L["MINIMAP_TOOLTIP_MIDDLECLICK"]    = "|cffffffffMiddle Click|r Открыть окно гильдии Blizzard"
	
	L["MC"]                             = "Огненные недра"
	L["BWL"]                            = "Логово Крыла Тьмы"
	L["AQ20"]                           = "Руины Ан'Киража"
	L["AQ40"]                           = "Храм Ан'Киража"
	L["Naxxramas"]                      = "Наксрамас"
	L["ZG"]                             = "Зул'Гуруб"
	L["Onyxia"]                         = "Логово Ониксии"
	L["Magtheridon"]                    = "Логовора Магтеридона"
	L["SSC"]                            = "Змеиное Святилище"
	L["TK"]                             = "Крепость Бурь"
	L["Gruul"]                          = "Логово Груула"
	L["Hyjal"]                          = "Вершина Хиджала"
	L["SWP"]                            = "Плато Солнечного колодца"
	L["BT"]                             = "Черный храм"
	L["Karazhan"]                       = "Каражан"
	
	--availability (Data.lua)
	L['Not Available']                  = 'Недоступен'
	L['Morning']                        = 'Утро'
	L['Afternoon']                      = 'После полудня'
	L['Evening']                        = 'Вечер'
	
	--world events
	L["DARKMOON_FAIRE"]                 = "Ярмарка Новолуния"
	L["DMF display"]                    = '|cffffffffЯрмарка Новолуния - ' --this is needed for the calendar
	L["LOVE IS IN THE AIR"]             = "Любовная лихорадка"
	L["CHILDRENS_WEEK"]                 = "Детская неделя"             
	L["MIDSUMMER_FIRE_FESTIVAL"]        = "Огненный солнцеворот"
	L["HARVEST_FESTIVAL"]               = "Неделя урожая"
	L["HALLOWS_END"]                    = "Тыквовин"
	L["FEAST_OF_WINTER_VEIL"]           = "Праздник Зимнего покрова"
	L["BREWFEST"]						= "Хмельной фестиваль"
	












--[[ 
	chinese
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












elseif locale == "ruRU" then

	--options page
	L['OptionsAbout'] = 'Guildbook options and about. Thanks to Belrand@Auberdine for the French translations'
	L['Version'] = 'Version'
	L['Author'] = 'Author: |cffffffffstpain (|r|cffF58CBACopperbolts|r |cffffffffand|r |cff0070DEKylanda|r|cffffffff)|r'

	-- this is the start of the option ui updates, will go through the option panel and rewrite it with locales for stuff
	L["TOOLTIP_SHOW_TRADESKILLS"]		= "Display a list of tradeskills that use the current item. (Data is taken from Guildbook database)"
	L["TOOLTIP_SHOW_RECIPES"]			= "Include recipes that use the current item under each tradeskill."
	L["TOOLTIP_SHOW_RECIPES"]			= "Only show recipes for your characters tradeskills."

	L["OPTIONS"]						= "Options & Settings"
	L["MINIMAP_CALENDAR_RIGHTCLICK"]	= "Right click for menu"
	L["MINIMAP_CALENDAR_EVENTS"]		= "Events"

	L["DIALOG_CHARACTER_FIRST_LOAD"]	= "Welcome to Guildbook, click below to scan your characters professions."

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
	You can use /guildbook, /gbk or /gb.
	/guildbook open - this will open Guildbook
	/guildbook [interface] - this will open to a specific area (roster, tradeskills, chat, profiles, calendar, stats, guildbank, search, privacy)

	]]
	local rosterIcon = CreateAtlasMarkup("poi-workorders", 16, 16)
	local rosterHelp = [[
	Roster:
	You can sort the roster by clicking the column headers. You can also filter the roster by class or rank, to do this right click the headers. There is the option under class to filter the roster to just your own characters too!

	]]
	local tradeskillIcon = CreateAtlasMarkup("Mobile-Blacksmithing", 16, 16)
	local tradeskillHelp = 
	[[
	Tradeskills (Professions):
	Guildbook will process recipe/item IDs when it loads, this process can take a few minutes. Once complete you can view available crafts by profession and/or by equipment slot (head, hands, feet etc).

	Guildbook will share your tradeskill recipes with other guild members. 
	Open your tradeskill to trigger the scan of the recipes. This will save to your character and account database for the guild and sends to online guild members. Once this process is complete, future data will be sent to all online guild members when you log in. 

	You can also push data by opening a tradeskill (cooldown enabled to prevent spam).
	You can also use the import/export feature, click the icon above the profession list and follow the instructions.

	]]
	local profileIcon = CreateAtlasMarkup("GarrMission_MissionIcon-Recruit", 16, 16)
	local profileHelp = 
	[[
	Profile:
	Edit as you wish, add your personal information or not.
	You can select your spec(s) and edit your main character. If you use multiple accounts you can add another character which you can then select as a main. (Alts are set by selecting a main character from the alts profile).

	]]
	local searchIcon = CreateAtlasMarkup("shop-games-magnifyingglass", 16, 16)
	local searchHelp = 
	[[
	Search:
	Use this feature to browse your guild database- Find a recipe, pattern, character name.

	]]
	local bankIcon = CreateAtlasMarkup("ShipMissionIcon-Treasure-Map", 16, 16)
	local bankHelp = [[
	Coming soon
	]]
	L["HELP_ABOUT_CREDITS"]				= string.format("%s %s %s %s %s %s %s %s %s %s %s %s", slashCommandsIcon, slashCommandsHelp, rosterIcon, rosterHelp, tradeskillIcon, tradeskillHelp, profileIcon, profileHelp, searchIcon, searchHelp, bankIcon, bankHelp)



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
	L["PRIVACY_ABOUT"]                  = "Set the lowest rank you wish to share data with. Profile data includes name, birthday, bio and avatar. Inventory data is the equipment your character has (this is |cffFFD100NOT|r your bags/bank). Talents are, well, your talents!"
	L["INVENTORY"]                      = "Inventory"
	L["TALENTS"]                        = "Talents"

	L["ROSTER_MY_CHARACTERS"]			= "My characters"
	L["ROSTER_ALL_CLASSES"]				= "All"
	L["ROSTER_ALL_RANKS"]				= "All"

	L["TRADESKILLS"]					= "Professions"
	L["TRADESKILLS_RECIPES"]			= "Recipes"
	L["TRADESKILLS_CHARACTERS"]			= "Characters"
	L["TRADESKILL_GUILD_RECIPES"]		= "Guild Recipes"
	L["TRADESKILLS_SHARE_RECIPES"]		= "Share this characters recipes"
	L["TRADESKILLS_EXPORT_RECIPES"]		= "Import or export tradeskill data"
	L["IMPORT"]							= "Import"
	L["EXPORT"]							= "Export"
	L["CAN_CRAFT"]                      = "[Guildbook] are you able to craft %s ?"
	L["REMOVE_RECIPE_FROM_PROF_SS"]		= "Remove %s from %s ?"
	L["REMOVE_RECIPE_FROM_PROF"]		= "Right click to remove from this tradeskill."
	L["PROCESSED_RECIPES_SS"]			= "Processed %s of %s recipes"
	L["TRADESKILL_SLOT_FILTER_S"]		= "Filter %s items"
	L["TRADESKILL_SLOT_REMOVE"]			= "Clear filters"
	L["HEAD"]							= "head"
	L["SHOULDER"]						= "shoulder"
	L["BACK"]							= "back"
	L["CHEST"]							= "chest"
	L["WRIST"]							= "wrist"
	L["HANDS"]							= "hands"	
	L["WAIST"]							= "waist"
	L["LEGS"]							= "legs"
	L["FEET"]							= "feet"
	L["WEAPONS"]						= "weapons"
	L["OFF_HAND"]						= "off hand"	
	L["MISC"]							= "misc"
	L["CONSUMABLES"]					= "consumables"


	L["PHASE2GB"]						= "With the arrival of guild banks to TBCC i have removed the guild bank system from Guildbook. I am working on something to replace it though!"
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
	L["GUILD_BANK"]                     = "Useless tooltip!"
	L["ALTS"]                           = "Alt characters"
	L["USE_MAIN_PROFILE"]               = "Use main character profile"
	L["MY_SACKS"]                       = "My containers"
	L["BAGS"]                           = "Bags"
	L["BANK"]                           = "Bank"
	L["STATS"]                          = "Statistics"

	L["RESET_AVATAR"]					= "Reset avatar"

	L["PRIVACY_HEADER"]                 = "Privacy settings"
	L["NONE"]                           = "None"
	L["SHARING_NOBODY"]		    		= "Sharing with nobody"
	L["SHARING_WITH"]		    		= "Sharing with"

	L["MAIN_CHARACTER_ADD_ALT"]			= "Add character.\n|cffFFFF00Use this to add a character from a different account. You will then be able to select it as main character."
	L["MAIN_CHARACTER_REMOVE_ALT"]		= "Remove character"
	L["DIALOG_MAIN_CHAR_ADD"]			= "Type the name of your character, must be a guild member."
	L["DIALOG_MAIN_CHAR_REMOVE"]		= "Please enter the characters name."
	L["DIALOG_MAIN_CHAR_ADD_FOUND"]		= "Found character: %s Level: %s %s"

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

	--odds
	L["Warden"]							= "Warden"
	L["Frost (Tank)"]					= "Frost (Tank)"

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

--Options.xml dialog boxes
OPT_SH_MINIMAP_BUTTON = L["OPT_SH_MINIMAP_BUTTON"]
OPT_SH_MINICAL_BUTTON = L["OPT_SH_MINICAL_BUTTON"]
OPT_BLIZZROSTER = L["OPT_BLIZZROSTER"]
OPT_INFO_MESSAGE = L["OPT_INFO_MESSAGE"] --Unused
OPT_BLOCK_DATA_COMBAT = L["OPT_BLOCK_DATA_COMBAT"]
OPT_BLOCK_DATA_INSTANCE = L["OPT_BLOCK_DATA_INSTANCE"]
OPT_TT_DIALOG_SCI = L["OPT_TT_DIALOG_SCI"]
OPT_TT_DIALOG_SCMS = L["OPT_TT_DIALOG_SCMS"]
OPT_TT_DIALOG_SCP = L["OPT_TT_DIALOG_SCP"]
OPT_TT_DIALOG_SMC = L["OPT_TT_DIALOG_SMC"]
OPT_TT_DIALOG_DPL = L["OPT_TT_DIALOG_DPL"]
OPT_TT_DIALOG_DLR = L["OPT_TT_DIALOG_DLR"]
OPT_TT_DIALOG_DLRCO = L["OPT_TT_DIALOG_DLRCO"]
OPT_CHAT_SMCO = L["OPT_CHAT_SMCO"]
OPT_CHAT_SMS = L["OPT_CHAT_SMS"]
