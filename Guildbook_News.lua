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
}