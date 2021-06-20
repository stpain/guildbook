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
    [5] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
added more checks to player names containing realm name, this could cause issues when sending requests to players

|cff0070DEUpdates|r:
-

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [6] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
fixed error in guild cache clean up

|cff0070DEUpdates|r:
-

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [7] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
more bug fixing on the clean up function, was having issues where guild member data was being wiped - should be fixed

|cff0070DEUpdates|r:
started working on the detail frame, the popout window, going to slowly redesign it

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [8] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
added new attunement widget the guild member detail frame

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [9] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
set up the check box to show if the character is online when searching

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [10] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
As a quick fix for the laggy search function i've added a search button, normally the function would run as you type but its causing lag and it irritated me.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [11] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
Added more profession locales

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [12] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
I've been working on a new UI for guildbook, for a few reasons 1 of which is to avoid issues with other addons.

I'm still in the process of updating the code and moving things into the new UI, its mostly just the calendar to convert and update.

If you have the minimap button you can middle click on it to open the new UI (click with the mouse scroll wheel) or use this slash command

/run GuildbookUI:Show()

Any feedback on the new UI is greatly appreciated, curseforge comments are a good place for this or 1 of the wow addon discords.

Regards

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [13] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Worked on the tradeskills section, this was having issues so please report issues so i can look into anything.

|cff0070DEUpdates|r:
A few small updates, minimap button now focuses on the new UI.
Started work on the profile ribbon menu, the search box does nothing at the moment.

Sorry for it not being ready, i was caught out by the sudden news of pre patch.

Regards

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [14] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
Attune!

The roster tooltip will display data for players who have the Attune addon, its a great addon and well worth downloading.

Also, profiles! Work in progress due to new character.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [15] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Roster level issue should now be resolved.

|cff0070DEUpdates|r:
Menu has been moved into the ribbon style menu, the button icons will becoem better thought out!

Added some backgrounds to each section and move the profile info (main spec etc) into 'My profile', to set a main character you will need to log in with that character first!

Removed older profile scripts.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [16] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
fixed bug with clicking default blizz roster

|cff0070DEUpdates|r:
Icons now set up!

Added alts to roster tooltip, these can be set via your profile.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [17] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
made some changes to the comms timings, if you experience issues try adjusting the comms delay found in the main options interface
removed old and unused code

|cff0070DEUpdates|r:

Remember to download Attune!

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [18] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
still looking into models and profs issues

|cff0070DEUpdates|r:
Profession recipes should now show with TBC items first then Classic listed under.

Calendar, I have updated the event frame and added the new raids, for calendar icons to work the event title must be the name set by the dropdown menu!

Started work on updating the stats info, however, between a nasty cold and levelling a shaman my dev time is low :(

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [19] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
fixed the sort issue on the profession items, should now show correctly first time

|cff0070DEUpdates|r:
added the old wide view for the default roster UI back, there is a check box in the options menu to toggle this on/off

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [20] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
okay...i have tinkered with the prof scanning, if debug is turned on you'll see a small window next to the prof window with info of what happened

|cff0070DEUpdates|r:
added a check button to toggle between normal font and a default blizzard font, the blizzard font will work on all languages, sorry my other font doesnt :(

Bindings! yes i have added a few key bindings,

game menu > key bindings > Guildbook

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [21] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
further prof scan/sync tweeking

|cff0070DEUpdates|r:
fixed a texture bug with beast master hunters

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [22] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
mouse over link bug fixed

|cff0070DEUpdates|r:


|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [23] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
Profession sharing button! If you use a UI mod such as Elvui, use the slash cmd /guildbook -profs to open the window (when you open a prof window)

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [24] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Ok so i just saw a HUGE error I'd made in some logic which might explain some issues, anyways profiles should load properly now, mega sorry.

|cff0070DEUpdates|r:


|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [25] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:


|cff0070DEUpdates|r:
Moved the guild bank data into the account wide saved var, hopefully this will make it easier.

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [26] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
Guild Bank, it seems that other addons that modify your bags/bank will prevent Guildbook from scanning these containers, if you have issues please try to disable these addons on your bank alts when you need to scan.

|cff0070DEUpdates|r:
Search! I have started working on the search feature, you can currently view profiles by clicking the search result, more to come!

|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [27] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
minor bug fixes

|cff0070DEUpdates|r:


|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
    [28] = [[
Welcome to Guildbook and thank you for using the addon.

|cff06B200Bug fixes|r:
made a change to the bank scanning, should now just scan regardless of bag addons used

|cff0070DEUpdates|r:


|cffC41F3BIssues|r:
Please report bugs at curseforge 
(ctrl+c to copy website)
    ]],
}