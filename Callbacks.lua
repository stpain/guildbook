local name, addon = ...;


Mixin(addon, CallbackRegistryMixin)
addon:GenerateCallbackEvents({
    "Database_OnInitialised",
    "Database_OnCharacterAdded", 
    "Database_OnCharacterRemoved", 
    "Database_OnConfigChanged",
    "Database_OnDailyQuestCompleted",
    "Database_OnDailyQuestDeleted",
    "Database_OnCalendarDataChanged",
    "Database_OnNewsEventAdded",

    "Database_OnItemListChanged",
    "Database_OnItemListItemAdded",
    "Database_OnItemListItemRemoved",

    "Tradeskill_OnItemAddedToList",

    "Character_OnProfileSelected",
    "Character_OnDataChanged",
    "Character_OnNewsEvent",
    "Character_OnTradeskillSelected",
    "Character_BroadcastChange",
    "Character_ExportEquipment",
    
    "Profile_OnItemDataLoaded",

    "Player_Regen_Disabled",
    "Player_Regen_Enabled",

    "Guildbank_TimeStampRequest",
    "Guildbank_OnTimestampsReceived",
    "Guildbank_DataRequest",
    "Guildbank_OnDataReceived",
    "Guildbank_StatusInfo",

    "Calendar_OnDayItemAdded",
    
    --"Blizzard_OnTradeskillUpdate",
    "Blizzard_OnGuildRosterUpdate",
    "Blizzard_OnInitialGuildRosterScan",

    "Roster_OnSelectionChanged",

    "UI_OnSizeChanged",

    "Chat_OnMessageReceived",
    "Chat_OnMessageSent",
    "Chat_OnChatOpened",
    "Chat_OnHistoryDeleted",

    "StatusText_OnChanged",
    "LogDebugMessage",
    
    "Comms_OnMessageReceived",

    "Guildbook_OnSearch",
    "Guildbook_OnExport",

    "Quest_OnTurnIn",
    "Quest_OnAccepted",
    --"Quest_OnDailyFavouriteChanged",
})
CallbackRegistryMixin.OnLoad(addon);