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

Guildbook.News = {
    [0.0] = 'basic version, no news',
    [1.0] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Enchanting recipes should now be scanned
Minor UI tweaks and improvements

|cff0070DEUpdates|r:
Character profession data now saved. When you request profession data Guildbook will first check if you have any data on file, if not its sends a request otherwise it loads from file. This reduces the impact on server resources (chat systems).
As a result of this change there will be some issues between this version and the previous version, some compatability has been included while guild members update their addon.
You will still be able to request data from older versions, but this will not be stored locally. 
Older versions will not be able to receive profession data from you.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [2.0] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Addon loading and saved variables have been worked on after some reports of errors when loading addon

|cff0070DEUpdates|r:
Removed all older chat messages, this means the addon will only work with other guild members also using the latest version!

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [3.0] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
General UI improvements

|cff0070DEUpdates|r:
Guild Calendar! This follows a similar design to retail but with limited features.
You can create and delete events, assign an event a type, provide a title and description, set your participation and view others who are attending.


|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [3.1] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
General UI improvements

|cff0070DEUpdates|r:
Profession tab changes, added mouse wheel scrolling to the recipes listview! (About time)
Added some info for online/offline status of characters after selecting a profession.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [3.11] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Fixed bug with bank not showing for multiple bank alts

|cff0070DEUpdates|r:
Improved profession UI, recipes and reagents now appear with first click.
Search current character recipes.

players not able to see bank scan button can use the slash command /guidbook -scanbank

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [3.2] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
-

|cff0070DEUpdates|r:
Updated to work with ElvUI!

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [3.3] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
-

|cff0070DEUpdates|r:
Added a delete guild option for when the unthinkable happens, try not to need it!

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [3.31] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Fixed bug when searching profession recipes where search term was case sensetive

|cff0070DEUpdates|r:
You can now use the shift+click and ctrl+click on profession recipes to either copy the link into a chat message or view the item on your character.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.0] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
-

|cff0070DEUpdates|r:
Profiles! You can view guild members details including gear, talents and professions through the new profiles UI.

New UI, professions have been merged into the new profiles area and make better use of the frame size.
The guild bank has been temporarily added to the profiles hub, *if* The Burning Crusade is released then this will be re-purposed as there is an in game guild bank.
Soft Res has been removed, there are far better addons for this purpose.

More features to be added soon, but need to level my hunter!

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.1] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
-

|cff0070DEUpdates|r:
Guild Bank button is now back on the main row at the bottom of the UI, very sorry for any confusion or distruption caused by the recent changes.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.11] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Working on some locale updates, if the addon breaks revert to a previous version and please submit a bug, thanks.

|cff0070DEUpdates|r:
Calendar events can now have their titles and descriptions edited by the event owner.
The 'Push' and 'Request' buttons in the calendar have been added to help cover any times where events fail to sync (most likely due to a timing restriction).
Event attendee listview and class tabs no longer show declined players.

Some translations have been added for the professions, more are needed!

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.12] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Fixed a calendar bug with event attending not syncing, please report if this isnt resolved, thanks.

|cff0070DEUpdates|r:
Added textures to raid events in calendar, textures are loaded depending on the event title, use the event dropdown to get the correct titles.
Added most fixed dateworld events.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.13] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Sorry quick fix for an issue with an API not returning a value

|cff0070DEUpdates|r:


|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.14] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Calendar sync fixes, after deleting my saved variables file I found a bug which has now been fixed.
Fix error where table didnt exist.
Adjusted the comms/ui delay on profiles and seems better.

|cff0070DEUpdates|r:
Removed the old options for character profile, its all now in profiles

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.15] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
More calendar fixes, sorry for any issues you've been having, these bugs don't show themselves well when testing solo.

|cff0070DEUpdates|r:
Added the ZG texture to calendar

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    -- forgot to bump the toc, same news as 415
    [4.16] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
More calendar fixes, sorry for any issues you've been having, these bugs don't show themselves well when testing solo.

|cff0070DEUpdates|r:
Added the ZG texture to calendar

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.17] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
-

|cff0070DEUpdates|r:
Improved the calendar a bit more and added the minimap calendar button.
Added raid lockouts to the calendar UI.
Added attunements to the profile home tab.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.18] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
-

|cff0070DEUpdates|r:
More calendar tweeks, fixed the shaded texture days not in current month.
Added events to the tooltip for the calendar minimap button.
Players Guild hotkey now opens to roster to mimic default Blizzar behaviour.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [4.19] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
-

|cff0070DEUpdates|r:
More calendar tweeks, fixed the shaded texture days not in current month.
Added events to the tooltip for the calendar minimap button.
Players Guild hotkey now opens to roster to mimic default Blizzar behaviour.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
}