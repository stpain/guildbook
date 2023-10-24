local name, addon = ...;


--[[
{
    version = "",
    notes = "",
},
]]


--[[

    todo:
        minimap button options
        home view
        lockout/events view
        tradeskill scan link
]]


addon.changeLog = {
    {
        version = "6.51",
        notes = "Quick fix to Dailies favourites bug",
    },
    {
        version = "6.5",
        notes = "Dailies view now shows previous quest completion times in grey.\n\nUpdated more menu styling.\n\nStarted working on a help section, this is found under settings > help.\n\nAdded the ability to set favourites to daily quests and then filter the list so you can track specific daily quests per character.\n\nAdded more missing glyphs!",
    },
    {
        version = "6.45",
        notes = "Added missing glyphs as reported.\n\nAdded new 'Dailies' view to help players track which characters have completed daily quests, it learns daily quests over time by scanning your log. More to come on this!\n\nMinor changes to things like using class colours for character names in some menus.\n\nWork in progress to update some template styling.\n\nAdded Bnet chat to the chat events, currently untested!",
    },
}