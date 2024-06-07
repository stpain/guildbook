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
        version = "7.21",
        notes = "Little bump as last update didn't get to curseforge.\n\nAdded option to show main character in guild chat, go to Settings > Chat to enable/disable.\n\nAdded some QoL features to the tradeskills view including being able to craft directly from the recipe details.\n\nAdded ability to delete daily quests via the quest header/section, this will remove all quests under that header for all characters.\n\nAdded guild challenges info the home view. Also added optional filters for the class chart.\n\nAdded the default shift and ctrl key press combos to various item links in various UIs.",
        icon = "ClassHall-QuestIcon-Desaturated",
    },
    {
        version = "7.2",
        notes = "Added option to show main character in guild chat, go to Settings > Chat to enable/disable.\n\nAdded some QoL features to the tradeskills view including being able to craft directly from the recipe details.\n\nAdded ability to delete daily quests via the quest header/section, this will remove all quests under that header for all characters.\n\nAdded guild challenges info the home view. Also added optional filters for the class chart.\n\nAdded the default shift and ctrl key press combos to various item links in various UIs.",
        icon = "ClassHall-QuestIcon-Desaturated",
    },
    {
        version = "7.12",
        notes = "Minor fix to character ilvl, updated to the new api from Blizzard for Cata (and retail).\n\nAdded a check on money changed to keep alts data correct",
        icon = "ClassHall-QuestIcon-Desaturated",
    },
    {
        version = "7.11",
        notes = "Minor fix to faction rep labels showing 1 below.\n\nRemoved duplicate Druid option from Item Sets class dropdown.",
        icon = "ClassHall-QuestIcon-Desaturated",
    },
    {
        version = "7.1",
        notes = "Tradeskills fixed!\n\nNew feature! Item lists. You can browse item sets, dungeon, raid and faction items and build item lists for your characters.\nOn first use the addon will need to load the item data, once complete you can browse anytime. To start, enter a name for the list and then browse the items and drag them over.\nYou can also add items from the new tradeskill UI, click the green + button to see your lists.\nIf an item drops you'll get a notification its on a list.\n\nA checkbox was added the roster view to show your alts (the alts view will receive updates next).",
        icon = "ShipMissionIcon-Combat-Mission",
    },
    {
        version = "7.0",
        notes = "Cataclysm.\n\nUpdated the tradeskills to show recipe and item information along with guild crafters.\n\nUpdated the profile view to show talents and Prime Glyphs (note it'll take time for player data to propagate).\n\nSlight change to the roster view, now shows ilvl (rank removed), you can also hover the ilvl area to see ilvl's for all equipment sets.",
        icon = "ClassHall-QuestIcon-Desaturated",
    },
    {
        version = "6.81",
        notes = "Minor bug fix.\n\nAdded default option to login reminder.",
        icon = "ClassHall-QuestIcon-Desaturated",
    },
    {
        version = "6.8",
        notes = "Changes to the addon Comms, a bug was found with tradeskill data sharing, should now sync properly\n\nHome tab is currently work in progress but wanted to get comms issue fixed and updated.\n\nFix for Druid specs, not all 4 were covered properly.\n\nTradeskill cooldown tracking added (account only for now).\n\nAdded more glyphs.",
        icon = "ClassHall-QuestIcon-Desaturated",
    },
    {
        version = "6.7",
        notes = "Improved character settings area. You can now set/delete and push profession data.\n\nUpdated alt/main character logic, should now update correctly.\n\nAdded tracking of data sync (UI coming soon).\n\nQuick fix to instance lockout sorting\n\nAdded more glyphs (thanks for reports).\n\nAdded a check before glyph report popup, now checks if player is in instance/group.\n\nMoved import/export into its own view.\n\nExporting now shows the character info on the left.\n\nImporting is coming, this will create a gear set for your character with a prefix to the set name.\n\nWorking on feature to show all alts even those not in guild, only visible to you at the moment.",
    },
    {
        version = "6.6",
        notes = "Tradeskills bugs and fixes! There was a bug when scanning character tradeskills (Enchanting). The addon should now pick up your professions and recipes.\n\nWhen a profession is shared in game via the Blizzard chat link, clicking this will promt a data request with the link sender.\n\nFixed an issue with the Comms where addon data messages would overwrite themselves instead of using a unique payload event name.\n\nMinor change to the minimap button tooltip, this will now update itself as intended.\n\nFixed issue with tradeskill settings checkboxes, you can now select/deselect any or none.\n\nMinor fix to lockout sorting, lockouts now use both name and max players for sorting, (some 10/25 mix ups had happened).\n\nMinor fix to chats, these should now delete when clicking the delete button.\n\nCalendar updates, you can now add notes by right clicking on a day.\n\nAdded a tab view to the calendar side panel, toggle between lockouts and personal events/notes.",
    },
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