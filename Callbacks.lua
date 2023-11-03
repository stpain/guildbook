local name, addon = ...;


Mixin(addon, CallbackRegistryMixin)
addon:GenerateCallbackEvents({
    "Database_OnInitialised",
    "Database_OnCharacterAdded", 
    "Database_OnCharacterRemoved", 
    "Database_OnConfigChanged",
    "Database_OnDailyQuestCompleted",
    "Database_OnCalendarDataChanged",

    "Character_OnProfileSelected",
    "Character_OnDataChanged",
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

    "UI_OnSizeChanged",

    "Chat_OnMessageReceived",
    "Chat_OnMessageSent",
    "Chat_OnChatOpened",
    "Chat_OnHistoryDeleted",

    "StatusText_OnChanged",
    --"LogDebugMessage",
    
    "Comms_OnMessageReceived",

    "Guildbook_OnSearch",

    "Quest_OnTurnIn",
    "Quest_OnAccepted",
    --"Quest_OnDailyFavouriteChanged",
})
CallbackRegistryMixin.OnLoad(addon);