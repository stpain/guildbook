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

Guildbook.addonLoaded = false

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local LCI = LibStub:GetLibrary("LibCraftInfo-1.0")



---------------------------------------------------------------------------------------------------------------------------------------------------------------
--variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- this used to match the toc but for simplicity i've made it just an integer
local build = 31;
local locale = GetLocale()
local L = Guildbook.Locales

Guildbook.lastProfTransmit = GetTime()
Guildbook.profScanDialogOpen = false;
Guildbook.FONT_COLOUR = '|cff0070DE'
Guildbook.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
Guildbook.ContextMenu_Separator_Wide = "|TInterface/COMMON/UI-TooltipDivider:8:250|t"
Guildbook.PlayerMixin = nil
Guildbook.GuildBankCommit = {
    Commit = nil,
    Character = nil,
}
Guildbook.NUM_TALENT_ROWS = 7.0
Guildbook.COMMS_DELAY = 0.0

local DEBUG = Guildbook.DEBUG



---------------------------------------------------------------------------------------------------------------------------------------------------------------
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDBOOK1 = '/guildbook'
SlashCmdList['GUILDBOOK'] = function(msg)
    if msg == 'open' then
        GuildbookUI:Show()

    elseif msg == '-profs' then

    end
end




--init, this sets the saved var stuff
--pew, this will trigger a guild roster scan, this creates the db entries for each character and checks them for errors
--load, if the roster scan is successful this will be called and continue loading the addon, this will scan the client character for prof info etc

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init, this will setup the saved variables first
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Init()
    -- get this open first if debug is on
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.Debug == true then
        Guildbook.DebuggerWindow:Show()
        DEBUG('func', 'init', 'debug active')
    else
        Guildbook.DebuggerWindow:Hide()
    end
    if GUILDBOOK_GLOBAL then
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL.Debug and GUILDBOOK_GLOBAL.Debug or false)
    end
    
    --register comms
    AceComm:Embed(self)
    self:RegisterComm('Guildbook', 'ON_COMMS_RECEIVED')

    -- this enables us to prevent character model capturing until the player is fully loaded
    Guildbook.LoadTime = GetTime()
    DEBUG('func', 'init', tostring('Load time '..date("%T")))

    -- grab version number
    self.version = tonumber(GetAddOnMetadata('Guildbook', "Version"))
    self:SendVersionData()

    -- this makes the bank/calendar legacy features work
    if not self.GuildFrame then
        self.GuildFrame = {
            "GuildBankFrame",
            "GuildCalendarFrame",
        }
    end
    self:SetupGuildBankFrame()
    self:SetupGuildCalendarFrame()

    --create stored variable tables
    if GUILDBOOK_GLOBAL == nil or GUILDBOOK_GLOBAL == {} then
        GUILDBOOK_GLOBAL = self.Data.DefaultGlobalSettings
        DEBUG('func', 'init', 'created global saved variable table')
    else
        DEBUG('func', 'init', 'global variables exists')
    end
    if GUILDBOOK_CHARACTER == nil or GUILDBOOK_CHARACTER == {} then
        GUILDBOOK_CHARACTER = self.Data.DefaultCharacterSettings
        DEBUG('func', 'init', 'created character saved variable table')
    else
        DEBUG('func', 'init', 'character variables exists')
    end
    if not GUILDBOOK_GLOBAL.GuildRosterCache then
        GUILDBOOK_GLOBAL.GuildRosterCache = {}
        DEBUG('func', 'init', 'created guild roster cache')
    else
        DEBUG('func', 'init', 'guild roster cache exists')
    end
    if not GUILDBOOK_GLOBAL.Calendar then
        GUILDBOOK_GLOBAL.Calendar = {}
        DEBUG('func', 'init', 'created global calendar table')
    else
        DEBUG('func', 'init', 'global calendar table exists')
    end
    if not GUILDBOOK_GLOBAL.CalendarDeleted then
        GUILDBOOK_GLOBAL.CalendarDeleted = {}
        DEBUG('func', 'init', 'created global calendar deleted events table')
    else
        DEBUG('func', 'init', 'global calendar deleted events table exists')
    end
    if not GUILDBOOK_GLOBAL.LastCalendarTransmit then
        GUILDBOOK_GLOBAL.LastCalendarTransmit = GetServerTime()
    end
    if not GUILDBOOK_GLOBAL.LastCalendarDeletedTransmit then
        GUILDBOOK_GLOBAL.LastCalendarDeletedTransmit = GetServerTime()
    end

    if not GUILDBOOK_GLOBAL["myCharacters"] then
        GUILDBOOK_GLOBAL["myCharacters"] = {}
    end
    if not GUILDBOOK_GLOBAL["myCharacters"][UnitGUID("player")] then
        GUILDBOOK_GLOBAL["myCharacters"][UnitGUID("player")] = false;
    end

    if not GUILDBOOK_GLOBAL['CommsDelay'] then
        GUILDBOOK_GLOBAL['CommsDelay'] = 1.0
    end
    Guildbook.CommsDelaySlider:SetValue(GUILDBOOK_GLOBAL['CommsDelay'])

    if not GUILDBOOK_GLOBAL.config then
        local lowestRank = GuildControlGetRankName(GuildControlGetNumRanks())
        GUILDBOOK_GLOBAL.config = {
            privacy = {
                shareInventoryMinRank = lowestRank,
                shareTalentsMinRank = lowestRank,
                shareProfileMinRank = lowestRank,
            },
            modifyDefaultGuildRoster = true,
            showTooltipTradeskills = true,
            showTooltipTradeskillsRecipes = true,
            showMinimapButton = true,
            showMinimapCalendarButton = true,
            showTooltipCharacterInfo = true,
            showTooltipMainCharacter = true,
            showTooltipMainSpec = true,
            showTooltipProfessions = true,
            parsePublicNotes = false,
        }
        DEBUG('func', 'init', "created default config table")
    end

    if self.version < 5.0 then
        if not GUILDBOOK_GLOBAL.configUpdate then
            local lowestRank = GuildControlGetRankName(GuildControlGetNumRanks())
            GUILDBOOK_GLOBAL.config = {
                privacy = {
                    shareInventoryMinRank = lowestRank,
                    shareTalentsMinRank = lowestRank,
                    shareProfileMinRank = lowestRank,
                },
                modifyDefaultGuildRoster = true,
                showTooltipTradeskills = true,
                showTooltipTradeskillsRecipes = true,
                showMinimapButton = true,
                showMinimapCalendarButton = true,
                showTooltipCharacterInfo = true,
                showTooltipMainCharacter = true,
                showTooltipMainSpec = true,
                showTooltipProfessions = true,
                parsePublicNotes = false,
            }
        end
    end

    local config = GUILDBOOK_GLOBAL.config
    GuildbookOptionsTooltipTradeskill:SetChecked(config.showTooltipTradeskills and config.showTooltipTradeskills or false)
    GuildbookOptionsTooltipTradeskillRecipes:SetChecked(config.showTooltipTradeskillsRecipes and config.showTooltipTradeskillsRecipes or false)

    GuildbookOptionsShowMinimapButton:SetChecked(config.showMinimapButton)
    GuildbookOptionsShowMinimapCalendarButton:SetChecked(config.showMinimapCalendarButton)

    GuildbookOptionsTooltipInfo:SetChecked(config.showTooltipCharacterInfo)
    GuildbookOptionsTooltipInfoMainSpec:SetChecked(config.showTooltipMainSpec)
    GuildbookOptionsTooltipInfoProfessions:SetChecked(config.showTooltipProfessions)
    GuildbookOptionsTooltipInfoMainCharacter:SetChecked(config.showTooltipMainCharacter)

    if config.showTooltipCharacterInfo == false then
        GuildbookOptionsTooltipInfoMainSpec:Disable()
        GuildbookOptionsTooltipInfoProfessions:Disable()
        GuildbookOptionsTooltipInfoMainCharacter:Disable()
    else
        GuildbookOptionsTooltipInfoMainSpec:Enable()
        GuildbookOptionsTooltipInfoProfessions:Enable()
        GuildbookOptionsTooltipInfoMainCharacter:Enable()
    end

    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        if not GUILDBOOK_GLOBAL then
            return;
        end
        local name, link = GameTooltip:GetItem()
        if link then
            local itemID = GetItemInfoInstant(link)
            if itemID then
                if GUILDBOOK_GLOBAL.config and GUILDBOOK_GLOBAL.config.showTooltipTradeskills and Guildbook.tradeskillRecipes then
                    local headerAdded = false;
                    local profs = {}
                    for k, recipe in ipairs(Guildbook.tradeskillRecipes) do
                        if recipe.reagents then
                            for id, _ in pairs(recipe.reagents) do
                                if id == itemID then
                                    if headerAdded == false then
                                        --self:AddLine(" ")
                                        self:AddLine(Guildbook.ContextMenu_Separator_Wide)
                                        self:AddLine(L["TOOLTIP_ITEM_RECIPE_HEADER"])
                                        headerAdded = true;
                                    end
                                    if not profs[recipe.profession] then
                                        profs[recipe.profession] = true
                                        if GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipes then
                                            self:AddLine(" ")
                                        end
                                        self:AddLine(Guildbook.Data.Profession[recipe.profession].FontStringIconMEDIUM.."  "..recipe.profession)
                                    end
                                    if GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipes then
                                        self:AddLine(recipe.name, 1,1,1,1)
                                    end
                                end
                            end
                        end
                    end
                    if headerAdded == true then
                        self:AddLine(Guildbook.ContextMenu_Separator_Wide)
                        --self:AddLine(" ")
                    end
                end
            end
        end

        -- local characters = {}
        -- if 1 == 1 then -- place holder for a options setting
        --     if GUILDBOOK_GLOBAL.MySacks then
        --         if GUILDBOOK_GLOBAL.MySacks.Banks then
        --             for guid, items in pairs(GUILDBOOK_GLOBAL.MySacks.Banks) do
        --                 if items[itemID] then
        --                     table.insert(characters, {
        --                         guid = guid,
        --                         count = items[itemID].count,
        --                     })
        --                 end
        --             end
        --         end
        --     end
        -- end

    end)

    local tooltipIcon = CreateFrame("FRAME", "GuildbookTooltipIcon")
    tooltipIcon:SetSize(1,1)
    tooltipIcon.icon = tooltipIcon:CreateTexture(nil, "BACKGROUND")
    tooltipIcon.icon:SetAllPoints()
    -- hook the tooltip for guild characters
    GameTooltip:HookScript('OnTooltipSetUnit', function(self)
        if not GUILDBOOK_GLOBAL then
            return;
        end
        if GUILDBOOK_GLOBAL.config.showTooltipCharacterInfo == false then
            return;
        end
        local _, unit = self:GetUnit()
        local guid = unit and UnitGUID(unit) or nil
        if guid and guid:find('Player') then        
            if Guildbook:IsCharacterInGuildCache(guid) then
                local guildName = Guildbook:GetGuildName()
                if not guildName then
                    return
                end
                local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
                self:AddLine(" ")
                self:AddLine('Guildbook:', 0.00, 0.44, 0.87, 1)
                if GUILDBOOK_GLOBAL.config.showTooltipMainSpec == true then
                    if character.MainSpec then
                        local mainSpec = false;
                        if character.MainSpec == "Bear" then
                            mainSpec = "Guardian"
                        elseif character.MainSpec == "Cat" then
                            mainSpec = "Feral"
                        elseif character.MainSpec == "Beast Master" then
                            mainSpec = "BeastMastery"
                        end
                        local iconString = CreateAtlasMarkup(string.format("GarrMission_ClassIcon-%s-%s", character.Class, mainSpec and mainSpec or character.MainSpec), 24,24)
                        self:AddLine(iconString.. "  |cffffffff"..character.MainSpec)
                    end
                end
                if GUILDBOOK_GLOBAL.config.showTooltipProfessions == true then
                    if character.Profession1 ~= '-' and Guildbook.Data.Profession[character.Profession1] then
                        self:AddDoubleLine(character.Profession1, character.Profession1Level, 1,1,1,1,1,1,1,1)
                    end
                    if character.Profession2 ~= '-' and Guildbook.Data.Profession[character.Profession2] then
                        self:AddDoubleLine(character.Profession2, character.Profession2Level, 1,1,1,1,1,1,1,1)
                    end
                end
                --self:AddTexture(Guildbook.Data.Class[character.Class].Icon,{width = 36, height = 36})
                if 1 == 1 then
                    if character.profile then
                        self:AddLine(" ")
                        self:AddLine(character.profile.realBio, 1,1,1,1, 1)
                    end
                end
                if GUILDBOOK_GLOBAL.config.showTooltipMainCharacter == true then
                    if character.MainCharacter and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] and GUILDBOOK_GLOBAL.GuildRosterCache[guildName][character.MainCharacter] then
                        self:AddDoubleLine(L['MAIN_CHARACTER'], GUILDBOOK_GLOBAL.GuildRosterCache[guildName][character.MainCharacter].Name, 1, 1, 1, 1, 1, 1, 1, 1) 
                    end
                end
            end
        end
    end)

    --remove after a few updates
    GUILDBOOK_GLOBAL.TooltipInfo = nil
    GUILDBOOK_GLOBAL.TooltipInfoMainSpec = nil
    GUILDBOOK_GLOBAL.TooltipInfoMainCharacter = nil
    GUILDBOOK_GLOBAL.TooltipInfoProfessions = nil
    GUILDBOOK_GLOBAL.ShowMinimapButton = nil
    GUILDBOOK_GLOBAL.ShowMinimapCalendarButton = nil
    GUILDBOOK_GLOBAL['Build'] = nil
    GUILDBOOK_GLOBAL.Modules = nil
end




function Guildbook:PLAYER_ENTERING_WORLD()
    DEBUG("event", "PLAYER_ENTERING_WORLD", "")
    if not GUILDBOOK_GLOBAL then
        DEBUG("func", "PEW", "GUILDBOOK_GLOBAL is nil or false")
        return;
    end
    GuildRoster() -- this will trigger a roster scan but we set addonLoaded as false to skip the auto roster scan
    C_Timer.After(1, function()
        self:ScanGuildRoster(function()
            Guildbook:Load() -- once the roster has been scanned continue to load
        end)
    end)
    -- store some info
    self.player = {
        faction = nil,
        race = nil,
    }
    C_Timer.After(2.0, function()
        if not Guildbook.PlayerMixin then
            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(UnitGUID('player'))
        else
            Guildbook.PlayerMixin:SetGUID(UnitGUID('player'))
        end
        if Guildbook.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
            -- double check mixin
            if not name then
                return
            end
            local raceID = C_PlayerInfo.GetRace(Guildbook.PlayerMixin)
            self.player.race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:upper()
            self.player.faction = C_CreatureInfo.GetFactionInfo(raceID).groupTag
        end
    end)
end




function Guildbook:Load()
    DEBUG("func", "Load", "loading addon")

    self:GetCharacterProfessions()
    self:CheckPrivacyRankSettings() -- this will make sure rank changes are handled, just set any privacy rule to the lowest rank if its wrong

    local ldb = LibStub("LibDataBroker-1.1")
    self.MinimapButton = ldb:NewDataObject('GuildbookMinimapIcon', {
        type = "data source",
        icon = 134068,
        OnClick = function(self, button)
            if button == "RightButton" then
                if InterfaceOptionsFrame:IsVisible() then
                    InterfaceOptionsFrame:Hide()
                else
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                end
            elseif button == 'MiddleButton' then
                if IsShiftKeyDown() then
                    FriendsFrame:Show()
                else
                    ToggleFriendsFrame(3)
                end
            elseif button == "LeftButton" then
                if GuildbookUI then
                    if GuildbookUI:IsVisible() then
                        GuildbookUI:Hide()
                    else
                        if IsShiftKeyDown() then
                            GuildbookUI:OpenTo("chat")
                        else
                            GuildbookUI:OpenTo("roster")
                        end
                    end
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(tostring('|cff0070DE'..addonName))
            tooltip:AddDoubleLine('|cffffffffLeft Click|r Open Guildbook')
            tooltip:AddDoubleLine("Shift + "..'|cffffffffLeft Click|r Open Chat')
            tooltip:AddDoubleLine('|cffffffffRight Click|r Options')
        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    self.MinimapIcon:Register('GuildbookMinimapIcon', self.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])

    self.MinimapCalendarButton = ldb:NewDataObject('GuildbookMinimapCalendarIcon', {
        type = "data source",
        icon = 134939,
        OnClick = function(self, button)
            if GuildbookUI:IsVisible() then
                GuildbookUI:Hide()
                return;
            end
            GuildbookUI:OpenTo("calendar")
            Guildbook.GuildFrame.GuildCalendarFrame:ClearAllPoints()
            Guildbook.GuildFrame.GuildCalendarFrame:SetParent(GuildbookUI.calendar)
            Guildbook.GuildFrame.GuildCalendarFrame:SetPoint("TOPLEFT", 0, -26) --this has button above the frame so lower it a bit
            Guildbook.GuildFrame.GuildCalendarFrame:SetPoint("BOTTOMRIGHT", -2, 0)
            Guildbook.GuildFrame.GuildCalendarFrame:Show()
    
            Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:ClearAllPoints()
            Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('TOPLEFT', GuildbookUI.calendar, 'TOPRIGHT', 4, 50)
            Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('BOTTOMRIGHT', GuildbookUI.calendar, 'BOTTOMRIGHT', 254, 0)
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            local now = date('*t')
            tooltip:AddLine('Guildbook')
            tooltip:AddLine(string.format("%s %s %s", now.day, L[Guildbook.Data.Months[now.month]], now.year), 1,1,1,1)
            tooltip:AddLine(' ')
            tooltip:AddLine(L['Events'])
            -- get events for next 7 days
            local upcomingEvents = Guildbook:GetCalendarEvents(time(now), 7)
            if upcomingEvents and next(upcomingEvents) then
                for k, event in ipairs(upcomingEvents) do
                    tooltip:AddDoubleLine(event.title, string.format("%s %s",event.date.day, string.sub(L[Guildbook.Data.Months[event.date.month]], 1, 3)), 1,1,1,1,1,1,1,1)
                end
            end
        end,
    })
    self.MinimapCalendarIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapCalendarButton'] then GUILDBOOK_GLOBAL['MinimapCalendarButton'] = {} end
    self.MinimapCalendarIcon:Register('GuildbookMinimapCalendarIcon', self.MinimapCalendarButton, GUILDBOOK_GLOBAL['MinimapCalendarButton'])
    for i = 1, _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:GetNumRegions() do
        local region = select(i, _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:GetRegions())
        if (region:GetObjectType() == 'Texture') then
            region:Hide()
        end
    end
    -- modify the minimap icon to match the blizz calendar button
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:SetSize(40,40)
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:SetNormalTexture("Interface\\Calendar\\UI-Calendar-Button")
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:GetNormalTexture():SetTexCoord(0.0, 0.390625, 0.0, 0.78125)
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:SetPushedTexture("Interface\\Calendar\\UI-Calendar-Button")
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:GetPushedTexture():SetTexCoord(0.5, 0.890625, 0.0, 0.78125)
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon'].Text = _G['LibDBIcon10_GuildbookMinimapCalendarIcon']:CreateFontString(nil, 'OVERLAY', 'GameFontBlack')
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon'].Text:SetPoint('CENTER', -1, -1)
    _G['LibDBIcon10_GuildbookMinimapCalendarIcon'].Text:SetText(date('*t').day)
    -- setup a ticker to update the date, kinda overkill maybe ?
    C_Timer.NewTicker(1, function()
        _G['LibDBIcon10_GuildbookMinimapCalendarIcon'].Text:SetText(date('*t').day)
    end)

    local config = GUILDBOOK_GLOBAL.config
    GuildbookOptionsModifyDefaultGuildRoster:SetChecked(config.modifyDefaultGuildRoster == true and true or false)
    if config.modifyDefaultGuildRoster == true then
        self:ModBlizzUI()
    end
    if config.showMinimapButton == false then
        self.MinimapIcon:Hide('GuildbookMinimapIcon')
        DEBUG('func', "Load", 'minimap icon saved var setting: false, hiding minimap button')
    end
    if config.showMinimapCalendarButton == false then
        self.MinimapCalendarIcon:Hide('GuildbookMinimapCalendarIcon')
        DEBUG('func', "Load", 'minimap calendar icon saved var setting: false, hiding minimap calendar button')
    end

    Guildbook:SendPrivacyInfo("GUILD", nil)
    DEBUG("func", "Load", "sending privacy settings")

    -- stagger some start up calls to prevent chat spam, use 3s interval
    C_Timer.After(3, function()
        if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER.Profession1 then
            local prof = GUILDBOOK_CHARACTER.Profession1
            if GUILDBOOK_CHARACTER[prof] and next(GUILDBOOK_CHARACTER[prof]) ~= nil then
                self:SendTradeskillData(prof, "GUILD", nil)
                Guildbook.lastProfTransmit = GetTime()
                DEBUG("func", "Load", string.format("sending %s data", prof))
            end
        end
    end)
    C_Timer.After(6, function()
        if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER.Profession2 then
            local prof = GUILDBOOK_CHARACTER.Profession2
            if GUILDBOOK_CHARACTER[prof] and next(GUILDBOOK_CHARACTER[prof]) ~= nil then
                self:SendTradeskillData(prof, "GUILD", nil)
                Guildbook.lastProfTransmit = GetTime()
                DEBUG("func", "Load", string.format("sending %s data", prof))
            end
        end
    end)
    C_Timer.After(9, function()
        if GUILDBOOK_CHARACTER.Cooking and type(GUILDBOOK_CHARACTER.Cooking) == "table" and next(GUILDBOOK_CHARACTER.Cooking) ~= nil then
            self:SendTradeskillData("Cooking", "GUILD", nil)
            Guildbook.lastProfTransmit = GetTime()
            DEBUG("func", "Load", string.format("sending %s data", "cooking"))
        end    
    end)
    -- these let us know what to query
    self.recipeIdsQueried, self.craftIdsQueried = {}, {}
    C_Timer.After(12, function()
        self:RequestTradeskillData()
        DEBUG("func", "Load", "requested tradeskill recipe\\item data")
    end)
    C_Timer.After(15, function()
        Guildbook:SendGuildCalendarEvents()
        DEBUG("func", "Load", "send calendar events")
    end)
    C_Timer.After(18, function()
        Guildbook:SendGuildCalendarDeletedEvents()
        DEBUG("func", "Load", "send deleted calendar events")
    end)
    C_Timer.After(21, function()
        Guildbook:RequestGuildCalendarEvents()
        DEBUG("func", "Load", "requested calendar events")
    end)
    C_Timer.After(24, function()
        Guildbook:RequestGuildCalendarDeletedEvents()
        DEBUG("func", "Load", "requested deleted calendar events")
    end)

    if not GUILDBOOK_GLOBAL.configUpdate then
        local news = "There has been some changes made to how Guildbook stores your settings. For this update only, they have been reset to default values, you should check and make any changes as needed."
        StaticPopup_Show('GuildbookUpdates', self.version, news)
    end

    self.addonLoaded = true
end







-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local localProfNames = tInvert(Guildbook.ProfessionNames[locale])
function Guildbook:GetEnglishProf(prof)
    local id = localProfNames[prof]
    if id then
        return Guildbook.ProfessionNames.enUS[id]
    end
end

function Guildbook:MakeFrameMoveable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end


function Guildbook:RequestTradeskillData()
    if self.addonLoaded == false then
        return;
    end
    local delay = GUILDBOOK_GLOBAL['Debug'] and 0.01 or 0.25
    local recipeIdsToQuery = {}
    if not self.tradeskillRecipes then
        self.tradeskillRecipes = {}
    else
        wipe(self.tradeskillRecipes)
    end
    local guild = self.GetGuildName()
    if not guild then
        return;
    end
    if not GUILDBOOK_GLOBAL then
        return;
    end
    if not GUILDBOOK_GLOBAL.GuildRosterCache[guild] then
        return;
    end
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
        if character.Profession1 and character.Profession1 ~= "-" then
            local prof = character.Profession1
            if character[prof] and next(character[prof]) ~= nil then
                for recipeID, reagents in pairs(character[prof]) do
                    if prof == "Enchanting" then
                        if not self.craftIdsQueried[recipeID] then
                            self.craftIdsQueried[recipeID] = true;
                            table.insert(recipeIdsToQuery, {
                                recipeID = recipeID,
                                prof = "Enchanting", 
                                reagents = reagents or false,
                            })
                        end
                    else
                        if not self.recipeIdsQueried[recipeID] then
                            self.recipeIdsQueried[recipeID] = true;
                            table.insert(recipeIdsToQuery, {
                                recipeID = recipeID,
                                prof = prof, 
                                reagents = reagents or false,
                            })
                        end
                    end
                end
            end
        end
        if character.Profession2 and character.Profession2 ~= "-" then
            local prof = character.Profession2
            if character[prof] and next(character[prof]) ~= nil then
                for recipeID, reagents in pairs(character[prof]) do
                    if prof == "Enchanting" then
                        if not self.craftIdsQueried[recipeID] then
                            self.craftIdsQueried[recipeID] = true;
                            table.insert(recipeIdsToQuery, {
                                recipeID = recipeID,
                                prof = "Enchanting", 
                                reagents = reagents or false,
                            })
                        end
                    else
                        if not self.recipeIdsQueried[recipeID] then
                            self.recipeIdsQueried[recipeID] = true;
                            table.insert(recipeIdsToQuery, {
                                recipeID = recipeID,
                                prof = prof, 
                                reagents = reagents or false,
                            })
                        end
                    end
                end
            end
        end
        if character.Cooking and type(character.Cooking) == "table" then
            for recipeID, reagents in pairs(character.Cooking) do
                if not self.recipeIdsQueried[recipeID] then
                    self.recipeIdsQueried[recipeID] = true;
                    table.insert(recipeIdsToQuery, {
                        recipeID = recipeID,
                        prof = "Cooking", 
                        reagents = reagents or false,
                    })
                end
            end
        end
    end
    if #recipeIdsToQuery > 0 then
        local recipesToProcess = #recipeIdsToQuery;
        local startTime = time();
        self:PrintMessage(string.format("found %s recipes, estimated duration %s", #recipeIdsToQuery, SecondsToTime(#recipeIdsToQuery*delay)))
        table.sort(recipeIdsToQuery, function(a,b)
            if a.prof == b.prof then
                return a.recipeID < b.recipeID
            else
                return a.prof < b.prof
            end
        end)
        local i = 1;
        DEBUG('func', 'tradeskill data requst', string.format("found %s recipes, estimated duration %s", #recipeIdsToQuery, SecondsToTime(#recipeIdsToQuery*delay)))
        C_Timer.NewTicker(delay, function()
            if i > #recipeIdsToQuery then
                return;
            end
            local recipeID = recipeIdsToQuery[i].recipeID
            local prof = recipeIdsToQuery[i].prof
            local reagents = recipeIdsToQuery[i].reagents
            local l, r, n, e, x, ic = false, false, false, false, 0, false
            local _, spellID = LCI:GetItemSource(recipeID)
            if spellID then
                x = LCI:GetCraftXPack(spellID)
            end
            if prof == 'Enchanting' then
                l = GetSpellLink(recipeID)
                r = 1
                n = GetSpellInfo(recipeID)
                if not n then
                    n = "unknown"
                end
                e = true
            else
                n, l, r, _, _, _, _, _, _, ic = GetItemInfo(recipeID)
            end
            if not l and not n and not r and not ic then
                if prof == 'Enchanting' then                    
                    local spell = Spell:CreateFromSpellID(recipeID)
                    spell:ContinueOnSpellLoad(function()
                        l = GetSpellLink(recipeID)
                        n, _, ic = GetSpellInfo(recipeID)
                        if not n then
                            n = "unknown"
                        end
                        if not ic then
                            ic = 136244
                        end
                        e = true
                        table.insert(self.tradeskillRecipes, {
                            itemID = recipeID,
                            reagents = reagents,
                            rarity = 1,
                            link = l,
                            icon = ic,
                            expsanion = x;
                            enchant = e,
                            name = n,
                            profession = prof,
                        })
                        recipesToProcess = recipesToProcess - 1;
                        --DEBUG('func', 'tradeskill data requst', string.format("added recipeID %s prof %s link %s", recipeID, prof, l))
                    end)
                else
                    local item = Item:CreateFromItemID(recipeID)
                    item:ContinueOnItemLoad(function()
                        l = item:GetItemLink()
                        r = item:GetItemQuality()
                        n = item:GetItemName()
                        ic = item:GetItemIcon()
                        table.insert(self.tradeskillRecipes, {
                            itemID = recipeID,
                            reagents = reagents,
                            rarity = r,
                            link = l,
                            icon = ic,
                            expansion = x;
                            enchant = false,
                            name = n,
                            profession = prof,
                        })
                        recipesToProcess = recipesToProcess - 1;
                        --DEBUG('func', 'tradeskill data requst', string.format("added recipeID %s prof %s link %s", recipeID, prof, l))
                    end)
                end
            else
                if prof == "Enchanting" then
                    ic = 136244
                end
                table.insert(self.tradeskillRecipes, {
                    itemID = recipeID,
                    reagents = reagents,
                    rarity = r,
                    link = l,
                    icon = ic,
                    enchant = e,
                    expansion = x;
                    name = n,
                    profession = prof,
                })
                recipesToProcess = recipesToProcess - 1;
                --DEBUG('func', 'tradeskill data requst', string.format("added recipeID %s prof %s link %s", recipeID, prof, l))
            end
            i = i + 1;
            if recipesToProcess == 0 then
                self:PrintMessage(string.format("all tradeskill recipes processed, took %s", SecondsToTime(time()-startTime)))
                DEBUG('func', 'tradeskill data requst', string.format("all tradeskill recipes processed, took %s", SecondsToTime(time()-startTime)))
            end
        end, #recipeIdsToQuery)
    else
        DEBUG('func', 'tradeskill data requst', "no new recipes to query")
    end
end

local helperIcons = 1
function Guildbook:CreateHelperIcon(parent, relTo, anchor, relPoint, x, y, tooltiptext)
    local f = CreateFrame('FRAME', tostring('GuildbookHelperIcons'..helperIcons), parent)
    f:SetPoint(relTo, anchor, relPoint, x, y)
    f:SetSize(20, 20)
    f.texture = f:CreateTexture('$parentTexture', 'ARTWORK')
    f.texture:SetAllPoints(f)
    f.texture:SetTexture(374216)
    f:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
        GameTooltip:AddLine(tooltiptext)
        GameTooltip:Show()
    end)
    f:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    helperIcons = helperIcons + 1
    return f
end

function Guildbook:TrimNumber(num)
    if type(num) == 'number' then
        local trimmed = string.format("%.2f", num)
        return tonumber(trimmed)
    else
        return 1
    end
end

function Guildbook:GetCalendarEvents(start, duration)
    local guildName = Guildbook:GetGuildName()
    if not guildName then
        return
    end
    local events = {}
    local today = date('*t')
    local finish = (time(today) + (60*60*24*duration))
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['Calendar'] and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            --local eventTimeStamp = time(event.date)
                if time(event.date) >= start and time(event.date) <= finish then
                    table.insert(events, event)
                    DEBUG('func', 'Guildbook:GetCalendarEvents', 'found: '..event.title)
                end
            --end
        end
    end
    return events
end

local spellSchools = {
    [2] = 'Holy',
    [3] = 'Fire',
    [4] = 'Nature',
    [5] = 'Frost',
    [6] = 'Shadow',
    [7] = 'Arcane',
}
local statIDs = {
    [1] = 'Strength',
    [2] = 'Agility',
    [3] = 'Stamina',
    [4] = 'Intellect',
    [5] = 'Spirit',
}
function Guildbook:GetPaperDollStats()
    if GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER['PaperDollStats'] = {}

        local numSkills = GetNumSkillLines();
        local skillIndex = 0;
        local currentHeader = nil;
    
        for i = 1, numSkills do
            local skillName = select(1, GetSkillLineInfo(i));
            local isHeader = select(2, GetSkillLineInfo(i));
    
            if isHeader ~= nil and isHeader then
                currentHeader = skillName;
            else
                if (currentHeader == "Weapon Skills" and skillName == 'Defense') then
                    skillIndex = i;
                    break;
                end
            end
        end
    
        local baseDef, modDef;
        if (skillIndex > 0) then
            baseDef = select(4, GetSkillLineInfo(skillIndex));
            modDef = select(6, GetSkillLineInfo(skillIndex));
        else
            baseDef, modDef = UnitDefense('player')
        end
    
        local posBuff = 0;
        local negBuff = 0;
        if ( modDef > 0 ) then
            posBuff = modDef;
        elseif ( modDef < 0 ) then
            negBuff = modDef;
        end
        GUILDBOOK_CHARACTER['PaperDollStats'].Defence = {
            Base = self:TrimNumber(baseDef),
            Mod = self:TrimNumber(modDef),
        }

        local baseArmor, effectiveArmor, armr, posBuff, negBuff = UnitArmor('player');
        GUILDBOOK_CHARACTER['PaperDollStats'].Armor = self:TrimNumber(baseArmor)
        GUILDBOOK_CHARACTER['PaperDollStats'].Block = self:TrimNumber(GetBlockChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].Parry = self:TrimNumber(GetParryChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].ShieldBlock = self:TrimNumber(GetShieldBlock());
        GUILDBOOK_CHARACTER['PaperDollStats'].Dodge = self:TrimNumber(GetDodgeChance());

        --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
        --local base, casting = GetManaRegen();
        GUILDBOOK_CHARACTER['PaperDollStats'].SpellHit = self:TrimNumber(GetSpellHitModifier());
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeHit = self:TrimNumber(GetHitModifier());

        GUILDBOOK_CHARACTER['PaperDollStats'].RangedCrit = self:TrimNumber(GetRangedCritChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeCrit = self:TrimNumber(GetCritChance());

        -- GUILDBOOK_CHARACTER['PaperDollStats'].SpellDamage = {}
        -- GUILDBOOK_CHARACTER['PaperDollStats'].SpellCrit = {}
        for id, school in pairs(spellSchools) do
            GUILDBOOK_CHARACTER['PaperDollStats']['SpellDmg'..school] = self:TrimNumber(GetSpellBonusDamage(id));        
            GUILDBOOK_CHARACTER['PaperDollStats']['SpellCrit'..school] = self:TrimNumber(GetSpellCritChance(id));
        end

        GUILDBOOK_CHARACTER['PaperDollStats'].HealingBonus = self:TrimNumber(GetSpellBonusHealing());

        local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
        local mainSpeed, offSpeed = UnitAttackSpeed("player");
        local mlow = (lowDmg + posBuff + negBuff) * percentmod
        local mhigh = (hiDmg + posBuff + negBuff) * percentmod
        local olow = (offlowDmg + posBuff + negBuff) * percentmod
        local ohigh = (offhiDmg + posBuff + negBuff) * percentmod
        if mainSpeed < 1 then mainSpeed = 1 end
        if mlow < 1 then mlow = 1 end
        if mhigh < 1 then mhigh = 1 end
        if olow < 1 then olow = 1 end
        if ohigh < 1 then ohigh = 1 end

        if offSpeed then
            if offSpeed < 1 then 
                offSpeed = 1
            end
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDmgOH = self:TrimNumber((olow + ohigh) / 2.0)
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDpsOH = self:TrimNumber(((olow + ohigh) / 2.0) / offSpeed)
        else
            --offSpeed = 1
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDmgOH = self:TrimNumber(0)
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDpsOH = self:TrimNumber(0)
        end
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDmgMH = self:TrimNumber((mlow + mhigh) / 2.0)
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDpsMH = self:TrimNumber(((mlow + mhigh) / 2.0) / mainSpeed)

        local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
        local low = (lowDmg + posBuff + negBuff) * percent
        local high = (hiDmg + posBuff + negBuff) * percent
        if speed < 1 then speed = 1 end
        if low < 1 then low = 1 end
        if high < 1 then high = 1 end
        local dmg = (low + high) / 2.0
        GUILDBOOK_CHARACTER['PaperDollStats'].RangedDmg = self:TrimNumber(dmg)
        GUILDBOOK_CHARACTER['PaperDollStats'].RangedDps = self:TrimNumber(dmg/speed)

        local base, posBuff, negBuff = UnitAttackPower('player')
        GUILDBOOK_CHARACTER['PaperDollStats'].AttackPower = self:TrimNumber(base + posBuff + negBuff)

        for k, stat in pairs(statIDs) do
            local a, b, c, d = UnitStat("player", k);
            GUILDBOOK_CHARACTER['PaperDollStats'][stat] = self:TrimNumber(b)
            --DEBUG('func', 'GetPaperDollStats', string.format("%s = %s", stat, b))
        end

        for k, v in pairs(GUILDBOOK_CHARACTER['PaperDollStats']) do
            if type(v) ~= 'table' then
                --DEBUG('func', 'GetPaperDollStats', string.format("%s = %s", k, string.format("%.2f", v)))
            else
                for x, y in pairs(v) do
                    local trimmed = string.format("%.2f", y)
                    --DEBUG('func', 'GetPaperDollStats', string.format("%s = %s", x, string.format("%.2f", y)))
                end
            end
        end
    end
end


function Guildbook:IsCharacterInGuildCache(guid)
    if guid:find('Player') then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
                return true
            else
                return false
            end
        end
    end
end


function Guildbook:GetCharacterFromCache(guid)
    if guid:find('Player') then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
                return GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
            else
                return false;
            end
        end
    end
end

---update the character table in the account wide saved variables
---@param guid string the characters GUID
---@param key string key to update
---@param value any new value
function Guildbook:SetCharacterInfo(guid, key, value)
    if guid:find('Player') then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
                GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] = self.Data.DefaultCharacterSettings
                DEBUG("db_func", "SetCharacterInfo", string.format("created new db entry for %s", guid))
            end
            local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
            character[key] = value;
            DEBUG("db_func", "SetCharacterInfo", string.format("updated %s for %s", key, (character.Name and character.Name or guid)))
        end
    end
end

---fetch character info using guid and key
---@param guid string the characters GUID
---@param key string the key to fetch
---@return any
function Guildbook:GetCharacterInfo(guid, key)
    if guid:find('Player') then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
            return GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid][key];
        end
    end
end

--- return the players guild name if they belong to one
function Guildbook:GetGuildName()
    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        return guildName
    end
end


--- print a message
-- @param msg string the message to print
function Guildbook:PrintMessage(msg)
    print(string.format('[%sGuildbook|r] %s', Guildbook.FONT_COLOUR, msg))
end

---check if you share data with this players rank
---@param player string target or senders name
---@param rule string the privacy setting (key) to check
---@return boolean
function Guildbook:ShareWithPlayer(player, rule)
    if not GUILDBOOK_GLOBAL then
        return false;
    end
    if not GUILDBOOK_GLOBAL.config then
        return false;
    end
    if not GUILDBOOK_GLOBAL.config.privacy then
        return false;
    end
    if not GUILDBOOK_GLOBAL.config.privacy[rule] then
        return false;
    end
    if GUILDBOOK_GLOBAL.config.privacy[rule] == "none" then
        return false;
    end
    self:CheckPrivacyRankSettings() -- double check all ranks are good
    local ranks = {}
    for i = 1, GuildControlGetNumRanks() do
        ranks[GuildControlGetRankName(i)] = i;
    end
    local privacyRank = GUILDBOOK_GLOBAL.config.privacy[rule]
    local senderRank = GuildControlGetRankName(C_GuildInfo.GetGuildRankOrder(self:GetGuildMemberGUID(player)))
    if ranks[senderRank] and ranks[privacyRank] and (ranks[senderRank] <= ranks[privacyRank]) then
        return true;
    end
    return false;
end

function Guildbook:CheckPrivacyRankSettings()
    local ranks = {}
    for i = 1, GuildControlGetNumRanks() do
        ranks[GuildControlGetRankName(i)] = i;
    end
    local lowestRank = GuildControlGetRankName(GuildControlGetNumRanks())
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.config and GUILDBOOK_GLOBAL.config.privacy then
        for rule, rank in pairs(GUILDBOOK_GLOBAL.config.privacy) do
            if not ranks[rank] then
                GUILDBOOK_GLOBAL.config.privacy[rule] = lowestRank
                DEBUG("func", "CheckPrivacyRankSettings", string.format("changed rank: %s to lowest rank (%s)", rank, lowestRank))
            end
        end
    end
end

function Guildbook:ScanPlayerBags()
    if not GUILDBOOK_GLOBAL then
        return;
    end
    if not GUILDBOOK_GLOBAL.MySacks then -- my sacks is an addon i made which im going to use in guildbook
        GUILDBOOK_GLOBAL.MySacks = {
            Bags = {},
            Banks = {},
        }
    end
    GUILDBOOK_GLOBAL.MySacks.Bags[UnitGUID("player")] = {}
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local icon, count, _, quality, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
            if id and count and link and quality then
                if not GUILDBOOK_GLOBAL.MySacks.Bags[UnitGUID("player")][id] then
                    GUILDBOOK_GLOBAL.MySacks.Bags[UnitGUID("player")][id] = {count = count, link = link, quality = quality, icon = icon}
                else
                    GUILDBOOK_GLOBAL.MySacks.Bags[UnitGUID("player")][id].count = GUILDBOOK_GLOBAL.MySacks.Bags[UnitGUID("player")][id].count + count;
                end
            end
        end
    end
end


function Guildbook:ScanPlayerBank()
    if not GUILDBOOK_GLOBAL.MySacks then -- my sacks is an addon i made which im going to use in guildbook
        GUILDBOOK_GLOBAL.MySacks = {
            Bags = {},
            Banks = {},
        }
    end
    GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")] = {}
    -- main bank
    for slot = 1, 28 do
        local icon, count, _, quality, _, _, link, _, _, id = GetContainerItemInfo(-1, slot)
        if id and count and link and quality then
            if not GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id] then
                GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id] = {count = count, link = link, quality = quality, icon = icon}
            else
                GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id].count = GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id].count + count;
            end
        end
    end
    -- bank bags
    for bag = 5, 11 do
        for slot = 1, GetContainerNumSlots(bag) do
            local icon, count, _, quality, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
            if id and count and link and quality then
                if not GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id] then
                    GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id] = {count = count, link = link, quality = quality, icon = icon}
                else
                    GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id].count = GUILDBOOK_GLOBAL.MySacks.Banks[UnitGUID("player")][id].count + count;
                end
            end
        end
    end
end

-- THIS FUNCTION WILL GO AWAY WHEN GUILD BANKS GET ADDED
--- scans the players bags and bank for guild bank sharing
--- creates a table in the character saved vars with scan time so we can check which data is newest
function Guildbook:ScanPlayerContainers()
    --if BankFrame:IsVisible() then
        local name = Ambiguate(UnitName("player"), 'none')

        local copper = GetMoney()

        if not GUILDBOOK_GLOBAL["GuildBank"] then
            GUILDBOOK_GLOBAL["GuildBank"] = {}
        end
        GUILDBOOK_GLOBAL["GuildBank"][name] = {
            Commit = GetServerTime(),
            Data = {},
            Money = copper,
        }

        -- player bags
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
                if id and count then
                    if not GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] then
                        GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] = count
                    else
                        GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] + count
                    end
                end
            end
        end

        -- main bank
        for slot = 1, 28 do
            local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(-1, slot)
            if id and count then
                if not GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] then
                    GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] = count
                else
                    GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] + count
                end
            end
        end

        -- bank bags
        for bag = 5, 11 do
            for slot = 1, GetContainerNumSlots(bag) do
                local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
                if id and count then
                    if not GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] then
                        GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] = count
                    else
                        GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] = GUILDBOOK_GLOBAL["GuildBank"][name].Data[id] + count
                    end
                end
            end
        end

        local bankUpdate = {
            type = 'GUILD_BANK_DATA_RESPONSE',
            payload = {
                Data = GUILDBOOK_GLOBAL["GuildBank"][name].Data,
                Commit = GUILDBOOK_GLOBAL["GuildBank"][name].Commit,
                Money = GUILDBOOK_GLOBAL["GuildBank"][name].Money,
                Bank = name,
            }
        }
        self:Transmit(bankUpdate, 'GUILD', nil, 'BULK')
        --DEBUG('comms_out', 'ScanPlayerContainers', 'sending guild bank data due to new commit')

    --end
end


--- scan the players trade skills
--- this is used to get data about the players professions, recipes and reagents
function Guildbook:ScanTradeSkill()
    local localeProf = GetTradeSkillLine() -- this returns local name
    if Guildbook:GetEnglishProf(localeProf) then
        local prof = Guildbook:GetEnglishProf(localeProf) --convert to english
        -- if prof == "Cooking" then
        --     return
        -- end
        GUILDBOOK_CHARACTER[prof] = {}
        if self:GetCharacterInfo(UnitGUID("player"), "Profession1") == "-" then
            self:SetCharacterInfo(UnitGUID("player"), "Profession1", prof)
        else
            if self:GetCharacterInfo(UnitGUID("player"), "Profession2") == "-" then
                self:SetCharacterInfo(UnitGUID("player"), "Profession2", prof)
            end
        end
        DEBUG("func", "ScanTradeskill", "created or reset table for "..prof)
        local i = 1;
        local c = GetNumTradeSkills()
        C_Timer.NewTicker(0.01, function()
            local name, _type, _, _, _ = GetTradeSkillInfo(i)
            if (name and _type ~= "header") then
                local itemLink = GetTradeSkillItemLink(i)
                local itemID = GetItemInfoInstant(itemLink)
                if itemLink:find("ightfin") then
                end
                if itemID then
                    GUILDBOOK_CHARACTER[prof][itemID] = {}
                end
                local numReagents = GetTradeSkillNumReagents(i);
                if numReagents > 0 then
                    for j = 1, numReagents do
                        local _, _, reagentCount, _ = GetTradeSkillReagentInfo(i, j)
                        local reagentLink = GetTradeSkillReagentItemLink(i, j)
                        local reagentID = GetItemInfoInstant(reagentLink)
                        if reagentID and reagentCount then
                            GUILDBOOK_CHARACTER[prof][itemID][reagentID] = reagentCount
                        end
                    end
                end
            end
            if i == c then
                self:SetCharacterInfo(UnitGUID("player"), prof, GUILDBOOK_CHARACTER[prof])
                local elapsed = GetTime() - Guildbook.lastProfTransmit
                if elapsed > 15 then
                    self:SendTradeskillData(prof, "GUILD", nil)
                    Guildbook.lastProfTransmit = GetTime()
                    DEBUG("func", "Scantradeskill", "sending data for "..prof)
                else
                    DEBUG("func", "Scantradeskill", string.format("%s remaining before comm lock off", 15-elapsed))
                end
            end
            i = i + 1;
        end, GetNumTradeSkills())
    end
end

--- scan the players enchanting recipes, enchanting works a little differently 
--- this is used to get data about the players professions, recipes and reagents
function Guildbook:ScanCraftSkills_Enchanting()
    local currentCraftingWindow = GetCraftSkillLine(1)
    if Guildbook:GetEnglishProf(currentCraftingWindow) == "Enchanting" then -- check we have enchanting open
        GUILDBOOK_CHARACTER['Enchanting'] = {}
        if self:GetCharacterInfo(UnitGUID("player"), "Profession1") == "-" then
            self:SetCharacterInfo(UnitGUID("player"), "Profession1", "Enchanting")
        else
            if self:GetCharacterInfo(UnitGUID("player"), "Profession2") == "-" then
                self:SetCharacterInfo(UnitGUID("player"), "Profession2", "Enchanting")
            end
        end
        local i = 1;
        local c = GetNumCrafts()
        C_Timer.NewTicker(0.01, function()
            local name, _, _type, _, _, _, _ = GetCraftInfo(i)
            if (name and _type ~= "header") then
                local _, _, _, _, _, _, itemID = GetSpellInfo(name)
                DEBUG('func', 'ScanTradeSkill_Enchanting', string.format('|cff0070DETrade item|r: %s, with ID: %s', name, itemID))
                if itemID then
                    GUILDBOOK_CHARACTER['Enchanting'][itemID] = {}
                end
                local numReagents = GetCraftNumReagents(i);
                DEBUG('func', 'ScanTradeSkill_Enchanting', string.format('this recipe has %s reagents', numReagents))
                if numReagents > 0 then
                    for j = 1, numReagents do
                        local reagentName, reagentTexture, reagentCount, playerReagentCount = GetCraftReagentInfo(i, j)
                        local reagentLink = GetCraftReagentItemLink(i, j)
                        if reagentName and reagentCount then
                            DEBUG('func', 'ScanTradeSkill_Enchanting', string.format('reagent number: %s with name %s and count %s', j, reagentName, reagentCount))
                            if reagentLink then
                                local reagentID = select(1, GetItemInfoInstant(reagentLink))
                                DEBUG('func', 'Enchanting', 'reagent id: '..reagentID)
                                if reagentID and reagentCount then
                                    GUILDBOOK_CHARACTER['Enchanting'][itemID][reagentID] = reagentCount
                                end
                            end
                        end
                    end
                end
            end
            if i == c then
                self:SetCharacterInfo(UnitGUID("player"), "Enchanting", GUILDBOOK_CHARACTER.Enchanting)
                local elapsed = GetTime() - Guildbook.lastProfTransmit
                if elapsed > 15 then
                    self:SendTradeskillData("Enchanting", "GUILD", nil)
                    Guildbook.lastProfTransmit = GetTime()
                    DEBUG("func", "Scantradeskill", "sending data for Enchanting")
                else
                    DEBUG("func", "Scantradeskill", string.format("%s remaining before comm lock off", 15-elapsed))
                end
            end
            i = i + 1;
        end, c)
    end
end

local profAbbrev = {
    ["alch"] = "Alchemy",
    ["bs"] = "Blacksmithing",
    ["ench"] = "Enchanting",
    ["eng"] = "Engineering",
    ["insc"] = "Inscription",
    ["lw"] = "Leatherworking",
    ["jc"] = "Jewelcrafting",
    ["tail"] = "Tailoring",
    ["mine"] = "Mining",
    ["herb"] = "Herbalism",
    ["skin"] = "Skinning",
}
local specAbbrev = {

}
function Guildbook:ParseMemberNote(note, character)
    if note:find("{gb,") then
        local s = string.find(note, "{gb,")
        local e = string.find(note, "}")
        if s and e then
            local data = note:sub(s+1,e-1)
            local prefix, spec, prof1, prof2 = strsplit(",", data)
            if profAbbrev[prof1] then
                character.Profession1 = profAbbrev[prof1]
            end
            if profAbbrev[prof2] then
                character.Profession2 = profAbbrev[prof2]
            end
        end
    end
end

--- scan the characters current guild cache
-- this will check name and class against the return values from PlayerMixin using guid, sometimes players create multipole characters before settling on a class
-- we also check the player entries for profression errors, talents table and spec data
-- any entries not found the current guild roster will be removed (=nil)
function Guildbook:ScanGuildRoster(callback)
    local guild = self:GetGuildName()
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache then
        if not GUILDBOOK_GLOBAL.GuildRosterCache[guild] then
            GUILDBOOK_GLOBAL.GuildRosterCache[guild] = {}
            DEBUG("func", "ScanGuildRoster", "created roster cache for "..guild)
        end
        if self.scanRosterTicker then
            self.scanRosterTicker:Cancel()
        end
        local memberGUIDs = {}
        local currentGUIDs = {}
        local guidsToRemove = {}
        local newGUIDs = {}
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        GUILDBOOK_GLOBAL['RosterExcel'] = {}
        for i = 1, totalMembers do
            --local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            local name, rankName, _, level, class, zone, publicNote, officerNote, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            if not GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] then
                GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] = {
                    Name = Ambiguate(name, 'none'),
                    Class = class,
                    Level = level,
                    PublicNote = publicNote,
                    officerNote = officerNote,
                    RankName = rankName,
                    Talents = {
                        primary = {},
                        secondary = {},
                    },
                    Alts = {},
                    MainCharacter = "-",
                    Profession1 = "-",
                    Profession1Level = 0,
                    Profession2 = "-",
                    Profession2Level = 0,
                    MainSpec = "-",
                    MainSpecIsPvP = false,
                    OffSpec = "-",
                    OffSpecIsPvP = false,
                };
                table.insert(newGUIDs, guid)
            end
            currentGUIDs[i] = { GUID = guid, lvl = level, exists = true, online = isOnline, rank = rankName, pubNote = publicNote, offNote = officerNote}
            memberGUIDs[guid] = true;
            --name = Ambiguate(name, 'none')
            --table.insert(GUILDBOOK_GLOBAL['RosterExcel'], string.format("%s,%s,%s,%s,%s", name, class, rankName, level, publicNote))
        end
        local i = 1;
        local start = date('*t')
        local started = time()
        GuildbookUI.statusText:SetText(string.format("starting roster scan at %s:%s:%s", start.hour, start.min, start.sec))
        self.scanRosterTicker = C_Timer.NewTicker(0.01, function()
            local percent = (i/totalMembers) * 100
            GuildbookUI.statusText:SetText(string.format("roster scan %s%%",string.format("%.1f", percent)))
            GuildbookUI.statusBar:SetValue(i/totalMembers)
            if not currentGUIDs[i] then
                return;
            end
            local guid = currentGUIDs[i].GUID
            local info = GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid]
            if info then
                if not self.PlayerMixin then
                    self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                else
                    self.PlayerMixin:SetGUID(guid)
                end
                if self.PlayerMixin:IsValid() then
                    local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
                    local name = C_PlayerInfo.GetName(self.PlayerMixin)
                    if name and class then
                        local raceID = C_PlayerInfo.GetRace(self.PlayerMixin)
                        local race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:upper()
                        local sex = (C_PlayerInfo.GetSex(self.PlayerMixin) == 1 and "FEMALE" or "MALE")
                        local faction = C_CreatureInfo.GetFactionInfo(raceID).groupTag
                        
                        info.Faction = faction;
                        info.Race = race;
                        info.Gender = sex;
                        info.Class = class;
                        info.Name = Ambiguate(name, 'none');
                        info.PublicNote = currentGUIDs[i].pubNote;
                        info.OfficerNote = currentGUIDs[i].offNote;
                        info.RankName = currentGUIDs[i].rank;
                        info.Level = currentGUIDs[i].lvl;

                        -- this was a bug found where i used Prof1 instead of Profession1
                        if not info.Profession1 then
                            info.Profession1 = (info.Prof1 and info.Prof1 or "-")
                        end
                        if not info.Profession2 then
                            info.Profession2 = (info.Prof2 and info.Prof2 or "-")
                        end
                        -- if info.Profession1 == "-" and info.Profession2 == "-" then
                        --     DEBUG("func", "ScanGuildRoster", string.format("no prof keys for %s", info.Name))
                        -- end
                        -- remove the old
                        info.Prof1 = nil
                        info.Prof2 = nil
                        if not info.Profession1Level then
                            info.Profession1Level = (info.Prof1Level and info.Prof1Level or "-")
                        end
                        if not info.Profession2Level then
                            info.Profession2Level = (info.Prof2Level and info.Prof2Level or "-")
                        end
                        -- remove the old
                        info.Prof1Level = nil
                        info.Prof2Level = nil

                        for _, prof in ipairs(Guildbook.Data.Professions) do
                            if info[prof.Name] then
                                --DEBUG("func", "ScanGuildRoster", string.format("found %s in %s db", prof.Name, info.Name))
                                local exists = false;
                                if info.Profession1 == prof.Name then
                                    exists = true;
                                end
                                if info.Profession2 == prof.Name then
                                    exists = true;
                                end
                                if exists == false then
                                    if info.Profession1 == "-" then
                                        info.Profession1 = prof.Name
                                        DEBUG("func", "ScanGuildRoster", string.format("set %s profession1 as %s because it was blank", info.Name, prof.Name))
                                    else
                                        if info.Profession2 == "-" then
                                            info.Profession2 = prof.Name
                                            DEBUG("func", "ScanGuildRoster", string.format("set %s profession2 as %s because it was blank", info.Name, prof.Name))
                                        else
                                            info[prof.Name] = nil
                                            DEBUG("func", "ScanGuildRoster", string.format("|cffC41F3Bremoved|r %s from %s", prof.Name, info.Name))
                                        end
                                    end
                                end
                            end
                        end

                        if info.UNKNOWN then
                            info.UNKNOWN = nil
                            DEBUG('func', 'ScanGuildRoster', string.format('removed table UNKNOWN from %s', name))
                        end

                        if info.AttunementsKeys then
                            info.AttunementsKeys = nil;
                        end

                        if info.MainCharacter then
                            info.Alts = {}
                            for _guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
                                if info.MainCharacter ~= "-" and character.MainCharacter == info.MainCharacter then
                                    table.insert(info.Alts, _guid)
                                end
                            end
                        end
                    end
                end
            end
            i = i + 1;
            if i > totalMembers then
                local finished = time() - started
                GuildbookUI.statusBar:SetValue(0)
                local removedCount = 0;
                for guid, _ in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
                    if not memberGUIDs[guid] then
                        GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] = nil;
                        removedCount = removedCount + 1;
                    end
                end
                if #newGUIDs > 0 then

                end
                if removedCount > 0 then
                    
                end
                GuildbookUI.statusText:SetText(string.format("finished roster scan, took %s, %s new characters, removed %s characters from db", SecondsToTime(finished), (#newGUIDs or 0), removedCount))
                C_Timer.After(0.1, function()
                    if GuildbookUI then
                        GuildbookUI.roster:ParseGuildRoster()
                    end
                end)
                if callback then
                    callback()
                end
            end
        end, totalMembers)

    end
end



--- scan the players professions
-- get the name of any professions the player has, the profession level
-- also check the secondary professions fishing, cooking, first aid
-- this will update the character saved var which is then read when a request comes in
function Guildbook:GetCharacterProfessions()
    DEBUG("func", "GetCharacterProfessions", "scanning character skills for profession info")
    local myCharacter = { Fishing = 0, Cooking = 0, FirstAid = 0, Prof1 = '-', Prof1Level = 0, Prof2 = '-', Prof2Level = 0 }
    for s = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)
        if Guildbook:GetEnglishProf(skill) == 'Fishing' then 
            DEBUG("func", "GetCharacterProfessions", "found fishing updating level")
            myCharacter.Fishing = level
        elseif Guildbook:GetEnglishProf(skill) == 'Cooking' then
            DEBUG("func", "GetCharacterProfessions", "found cooking updating level")
            myCharacter.Cooking = level
        elseif Guildbook:GetEnglishProf(skill) == 'First Aid' then
            DEBUG("func", "GetCharacterProfessions", "found first aid updating level")
            myCharacter.FirstAid = level
        else
            for k, prof in pairs(Guildbook.Data.Profession) do
                if prof.Name == Guildbook:GetEnglishProf(skill) then
                    DEBUG("func", "GetCharacterProfessions", string.format("found %s", prof.Name))
                    if myCharacter.Prof1 == '-' then
                        myCharacter.Prof1 = Guildbook:GetEnglishProf(skill)
                        DEBUG("func", "GetCharacterProfessions", string.format("setting Profession1 as %s", prof.Name))
                        myCharacter.Prof1Level = level
                    else
                        if myCharacter.Prof2 == '-' then
                            myCharacter.Prof2 = Guildbook:GetEnglishProf(skill)
                            DEBUG("func", "GetCharacterProfessions", string.format("setting Profession2 as %s", prof.Name))
                            myCharacter.Prof2Level = level
                        end
                    end
                    if myCharacter.Prof1 == myCharacter.Prof2 then
                        myCharacter.Prof2 = Guildbook:GetEnglishProf(skill)
                        myCharacter.Prof2Level = level
                        DEBUG("func", "GetCharacterProfessions", string.format("updated setting for Profession2 > set as %s", prof.Name))
                    end
                end
            end
        end
    end
    if GUILDBOOK_CHARACTER then
        local guid = UnitGUID("player")
        GUILDBOOK_CHARACTER['Profession1'] = myCharacter.Prof1
        GUILDBOOK_CHARACTER['Profession1Level'] = myCharacter.Prof1Level
        GUILDBOOK_CHARACTER['Profession2'] = myCharacter.Prof2
        GUILDBOOK_CHARACTER['Profession2Level'] = myCharacter.Prof2Level

        GUILDBOOK_CHARACTER['FishingLevel'] = myCharacter.Fishing
        GUILDBOOK_CHARACTER['CookingLevel'] = myCharacter.Cooking
        GUILDBOOK_CHARACTER['FirstAidLevel'] = myCharacter.FirstAid

        -- going to move away from this old per character system and use the newer db functions and the global sv file
        self:SetCharacterInfo(guid, "Profession1", myCharacter.Prof1)
        self:SetCharacterInfo(guid, "Profession1Level", myCharacter.Prof1Level)
        self:SetCharacterInfo(guid, "Profession2", myCharacter.Prof2)
        self:SetCharacterInfo(guid, "Profession2Level", myCharacter.Prof2Level)
    end
end


-- https://wow.gamepedia.com/API_GetActiveTalentGroup -- dual spec api for wrath

--- get the players current talents
-- as there is no dual spec for now we just default to using talents[1] and updating Talents.Current
-- when dual spec arrives we will have to adjust this
function Guildbook:GetCharacterTalentInfo(activeTalents)
    if GUILDBOOK_CHARACTER then
        if not GUILDBOOK_CHARACTER['Talents'] then
            GUILDBOOK_CHARACTER['Talents'] = {}
        end
        wipe(GUILDBOOK_CHARACTER['Talents'])
        GUILDBOOK_CHARACTER['Talents'][activeTalents] = {}
        -- will need dual spec set up for wrath
        for tabIndex = 1, GetNumTalentTabs() do
            local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
            for talentIndex = 1, GetNumTalents(tabIndex) do
                local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
                table.insert(GUILDBOOK_CHARACTER['Talents'][activeTalents], {
                    Tab = tabIndex,
                    Row = row,
                    Col = column,
                    Rank = rank,
                    MxRnk = maxRank,
                    Icon = iconTexture,
                    Name = name,
                })
                --DEBUG('func', 'GetCharacterTalentInfo', string.format("Tab %s: %s %s points", tabIndex, name, rank))
            end
        end
        self:SetCharacterInfo(UnitGUID("player"), "Talents", GUILDBOOK_CHARACTER.Talents)
    end
end


--- not used at the moment
function Guildbook.GetInstanceInfo()
    local t = {}
    if GetNumSavedInstances() > 0 then
        for i = 1, GetNumSavedInstances() do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
            tinsert(t, { Name = name, ID = id, Resets = reset, Encounters = numEncounters, Progress = encounterProgress })
            local msg = string.format("name=%s, id=%s, reset=%s, difficulty=%s, locked=%s, numEncounters=%s", tostring(name), tostring(id), tostring(reset), tostring(difficulty), tostring(locked), tostring(numEncounters))
            --print(msg)
        end
    end
    return t
end


--- check the players current gear and calculate the mean item level
function Guildbook.GetItemLevel()
    local character, itemLevel, itemCount = {}, 0, 0
	for k, slot in ipairs(Guildbook.Data.InventorySlots) do
		character[slot.Name] = GetInventoryItemID('player', slot.Name)
		if character[slot.Name] ~= nil then
			local iName, iLink, iRarety, ilvl = GetItemInfo(character[slot.Name])
            if not ilvl then ilvl = 0 end
			itemLevel = itemLevel + ilvl
			itemCount = itemCount + 1
		end
    end
    -- due to an error with LibSerialize which is now fixed we make sure we return a number
    if math.floor(itemLevel/itemCount) > 0 then
        return math.floor(itemLevel/itemCount)
    else
        return 0
    end
end


--- get the players currently equipped gear
function Guildbook:GetCharacterInventory()
    if GUILDBOOK_CHARACTER then
        if not GUILDBOOK_CHARACTER['Inventory'] then
            GUILDBOOK_CHARACTER['Inventory'] = {
                Current = {}
            }
        end
        for k, slot in ipairs(Guildbook.Data.InventorySlots) do
            local link = GetInventoryItemLink('player', GetInventorySlotInfo(slot.Name)) or false
            GUILDBOOK_CHARACTER['Inventory'].Current[slot.Name] = link
            --DEBUG('func', 'GetCharacterInventory', string.format("added %s at slot %s", link or 'false', slot.Name))
        end
        self:SetCharacterInfo(UnitGUID("player"), "Inventory", GUILDBOOK_CHARACTER['Inventory'])
    end
end

function Guildbook:GetGuildMemberGUID(player)
    local guildName = Guildbook:GetGuildName()
    if guildName then
        local totalMembers, _, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
            if Ambiguate(name, "none") == Ambiguate(player, "none") then
                return GUID;
            end
        end
    end
    return false;
end

function Guildbook:IsGuildMemberOnline(player)
    local online = false
    local zone;
    local guildName = Guildbook:GetGuildName()
    if guildName then
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, classDisplayName, _zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i)
            --DEBUG('func', 'IsGuildMemberOnline', string.format("player %s is online %s", name, tostring(isOnline)))
            if Ambiguate(name, 'none') == Ambiguate(player, 'none') then
                online = isOnline
                zone = _zone
                --print("found", name, "is online")
            end
        end
    end
    return online, zone
end


function Guildbook:GetCharacterDataPayload()
    local guid = UnitGUID('player')
    local ilvl = self:GetItemLevel()
    self.GetCharacterProfessions() -- this gets the basic prof info for primary and seconday professions
    self:GetPaperDollStats() -- this gets the paperdoll stats

    local response = {
        type = 'CHARACTER_DATA_RESPONSE',
        payload = {
            GUID = guid,
            ItemLevel = ilvl,
            Profession1Level = GUILDBOOK_CHARACTER["Profession1Level"],
            OffSpec = GUILDBOOK_CHARACTER["OffSpec"],
            Profession1 = GUILDBOOK_CHARACTER["Profession1"],
            MainCharacter = GUILDBOOK_CHARACTER["MainCharacter"],
            MainSpec = GUILDBOOK_CHARACTER["MainSpec"],
            MainSpecIsPvP = GUILDBOOK_CHARACTER["MainSpecIsPvP"],
            Profession2Level = GUILDBOOK_CHARACTER["Profession2Level"],
            Profession2 = GUILDBOOK_CHARACTER["Profession2"],
            OffSpecIsPvP = GUILDBOOK_CHARACTER["OffSpecIsPvP"],
            CookingLevel = GUILDBOOK_CHARACTER["CookingLevel"],
            FishingLevel = GUILDBOOK_CHARACTER["FishingLevel"],
            FirstAidLevel = GUILDBOOK_CHARACTER["FirstAidLevel"],

            CharStats = GUILDBOOK_CHARACTER['PaperDollStats']
        }
    }
    return response
end






















-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Transmit(data, channel, target, priority)
    local inInstance, _ = IsInInstance()
    if inInstance then
        GuildbookUI.statusText:SetText("unable to transmit data while in an instance")
    end
    if not self:GetGuildName() then
        return;
    end
    if target ~= nil then
        if self:IsGuildMemberOnline(target) == false then
            DEBUG('error', 'Guildbook:Transmit', string.format("player %s is not online", target))
            return
        end
    end
    -- add the current build number
    data["version"] = tostring(self.version);
    data["senderGUID"] = UnitGUID("player")

    -- local ok, serialized = pcall(LibSerialize.Serialize, LibSerialize, data)
    -- if not ok then
    --     LoadAddOn("Blizzard_DebugTools")
    --     DevTools_Dump(data)
    --     return
    -- end

    local serialized = LibSerialize:Serialize(data);
    local compressed = LibDeflate:CompressDeflate(serialized);
    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    if channel == 'WHISPER' then
        target = Ambiguate(target, 'none')
    end
    if addonName and encoded and channel and priority then
        DEBUG('comms_out', 'SendCommMessage', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
        self:SendCommMessage(addonName, encoded, channel, target, priority)
    end
end

function Guildbook:SendVersionData()
    if not self.version then
        return
    end
    local version = {
        type = "VERSION_INFO",
        payload = self.version,
    }
    self:Transmit(version, "GUILD", nil, "NORMAL")
end


function Guildbook:OnVersionInfoRecieved(data, distribution, sender)
    if data.senderGUID == UnitGUID("player") then
        --return;
    end
    if data.payload then
        if tonumber(self.version) < tonumber(data.payload) then
            if IsInInstance() or InCombatLockdown() then
                self:PrintMessage("new version available, probably fixes a few things, might break something else though!")
            else
                StaticPopup_Show("GuildbookUpdateAvailable", self.version, data.payload)
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- privacy comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lastPrivacyTransmit = -1000
local privacyTransmitQueued = false
function Guildbook:SendPrivacyInfo(channel, target)
    if not GUILDBOOK_GLOBAL.config and not GUILDBOOK_GLOBAL.config.privacy then
        return;
    end
    local privacy = {
        type = "PRIVACY_INFO",
        payload = {
            privacy = GUILDBOOK_GLOBAL.config.privacy,
        },
    }
    --this was spamming for some reason so added a 15s delay, might be awkward but better than spamming chat channels
    if (lastPrivacyTransmit + 15) < GetTime() then
        self:Transmit(privacy, channel, target, "NORMAL")
        lastPrivacyTransmit = GetTime()
    else
        if privacyTransmitQueued == false then
            C_Timer.After(15, function()
                self:Transmit(privacy, channel, target, "NORMAL")
                privacyTransmitQueued = false
            end)
            privacyTransmitQueued = true;
        end
    end
end

function Guildbook:OnPrivacyReceived(data, distribution, sender)
    if not data.payload.privacy then
        return
    end
    if data.senderGUID and data.senderGUID ~= UnitGUID("player") then
        local guildName = Guildbook:GetGuildName()
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] and GUILDBOOK_GLOBAL.GuildRosterCache[guildName][data.senderGUID] then
            local character = GUILDBOOK_GLOBAL.GuildRosterCache[guildName][data.senderGUID]
            local ranks = {}
            for i = 1, GuildControlGetNumRanks() do
                ranks[GuildControlGetRankName(i)] = i;
            end
            local myRank = GuildControlGetRankName(C_GuildInfo.GetGuildRankOrder(UnitGUID("player")))
            if not ranks[myRank] then
                return
            end
            if data.payload.privacy.shareProfileMinRank and ranks[data.payload.privacy.shareProfileMinRank] and type(ranks[data.payload.privacy.shareProfileMinRank]) == "number" then
                if ranks[myRank] > ranks[data.payload.privacy.shareProfileMinRank] then
                    character.profile = nil;
                    DEBUG("error", "OnPrivacyReceived", string.format("removed %s profile data"), character.Name)
                end
            else
                if data.payload.privacy.shareProfileMinRank and data.payload.privacy.shareProfileMinRank == "none" then
                    character.profile = nil;
                    DEBUG("error", "OnPrivacyReceived", string.format("removed %s profile data"), character.Name)
                end
            end
            if data.payload.privacy.shareInventoryMinRank and ranks[data.payload.privacy.shareInventoryMinRank] and type(ranks[data.payload.privacy.shareInventoryMinRank]) == "number" then
                if ranks[myRank] > ranks[data.payload.privacy.shareInventoryMinRank] then
                    character.Inventory = nil;
                    DEBUG("error", "OnPrivacyReceived", string.format("removed %s inventory data"), character.Name)
                end
            else
                if data.payload.privacy.shareInventoryMinRank and data.payload.privacy.shareInventoryMinRank == "none" then
                    character.Inventory = nil;
                    DEBUG("error", "OnPrivacyReceived", string.format("removed %s inventory data"), character.Name)
                end
            end
            if data.payload.privacy.shareTalentsMinRank and ranks[data.payload.privacy.shareTalentsMinRank] and type(ranks[data.payload.privacy.shareTalentsMinRank]) == "number" then
                if ranks[myRank] > ranks[data.payload.privacy.shareTalentsMinRank] then
                    character.Talents = nil;
                    DEBUG("error", "OnPrivacyReceived", string.format("removed %s talents data"), character.Name)
                end
            else
                if data.payload.privacy.shareTalentsMinRank and data.payload.privacy.shareTalentsMinRank == "none" then
                    character.Talents = nil;
                    DEBUG("error", "OnPrivacyReceived", string.format("removed %s talents data"), character.Name)
                end
            end
        end
    end
end


function Guildbook:OnPrivacyError(code, sender)
    if code == 0 then
        DEBUG("error", "PrivacyError", string.format("%s not sharing inventory", sender))
    elseif code == 1 then
        DEBUG("error", "PrivacyError", string.format("%s not sharing talents", sender))
    elseif code == 2 then
        DEBUG("error", "PrivacyError", string.format("%s not sharing profile", sender))
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- profile comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendProfileRequest(target)
    local request = {
        type = "PROFILE_INFO_REQUEST",
        payload = target,
    }
    self:Transmit(request, "WHISPER", target, "NORMAL")
end

function Guildbook:OnProfileRequest(request, distribution, sender)
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER.profile then
        local response = {
            type = "PROFILE_INFO_RESPONSE",
            payload = GUILDBOOK_CHARACTER.profile
        }
        if self:ShareWithPlayer(sender, "shareProfileMinRank") == true then
            self:Transmit(response, "WHISPER", sender, "BULK")
        else
            self:Transmit({
                type = "PRIVACY_ERROR",
                payload = 2,
            },
            "WHISPER", 
            sender, 
            "NORMAL")
        end
    end
end

function Guildbook:OnProfileReponse(response, distribution, sender)
    if not response.senderGUID then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][response.senderGUID] then
                GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][response.senderGUID].profile = response.payload.profile;
            end
        end

        GuildbookUI.statusText:SetText(string.format("received profile from %s", sender))
        GuildbookUI.profiles:LoadProfile()
    end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- talent comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendTalentInfoRequest(target, spec)
    local request = {
        type = "TALENT_INFO_REQUEST",
        payload = spec, -- dual spec future feature, maybe just return all talents data?
    }
    self:Transmit(request, "WHISPER", target, "NORMAL")
end

function Guildbook:OnTalentInfoRequest(request, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    Guildbook:GetCharacterTalentInfo('primary')
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER['Talents'] then
        local response = {
            type = "TALENT_INFO_RESPONSE",
            payload = {
                guid = UnitGUID('player'),
                talents = GUILDBOOK_CHARACTER['Talents'],
            }
        }
        if self:ShareWithPlayer(sender, "shareTalentsMinRank") == true then
            self:Transmit(response, "WHISPER", sender, "BULK")
        else
            self:Transmit({
                type = "PRIVACY_ERROR",
                payload = 1,
            },
            "WHISPER", 
            sender, 
            "NORMAL")
        end
    end
end

function Guildbook:OnTalentInfoReceived(response, distribution, sender)
    if not response.senderGUID then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        self:SetCharacterInfo(response.senderGUID, "Talents", response.payload.talents)
        DEBUG('func', 'OnTalentInfoReceived', string.format('updated %s talents', sender))
        GuildbookUI.statusText:SetText(string.format("received talents from %s", sender))
        GuildbookUI.profiles:LoadTalents("primary")
    end)
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- inventory comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:SendInventoryRequest(target)
    local request = {
        type = 'INVENTORY_REQUEST',
        payload = 'Current', -- do we cover for different builds, pve, pvp, dual spec etc
    }
    self:Transmit(request, 'WHISPER', target, 'NORMAL')
end


function Guildbook:OnCharacterInventoryRequest(data, distribution, sender)
    if distribution ~= 'WHISPER' then
        return
    end
    self:GetCharacterInventory()
    C_Timer.After(0.5, function()
        if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER['Inventory'] then
            local response = {
                type = 'INVENTORY_RESPONSE',
                payload = {
                    guid = UnitGUID('player'),
                    inventory = GUILDBOOK_CHARACTER['Inventory'], --send it all for now
                }
            }
            if self:ShareWithPlayer(sender, "shareInventoryMinRank") == true then
                self:Transmit(response, "WHISPER", sender, "BULK")
            else
                self:Transmit({
                    type = "PRIVACY_ERROR",
                    payload = 0,
                },
                "WHISPER", 
                sender, 
                "NORMAL")
            end
        end
    end)
end


function Guildbook:OnCharacterInventoryReceived(response, distribution, sender)
    if not response.senderGUID then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][response.senderGUID].Inventory = response.payload.inventory
            DEBUG('func', 'OnCharacterInventoryReceived', string.format('updated %s inventory', sender))
        end
        GuildbookUI.statusText:SetText(string.format("received inventory from %s", sender))
        GuildbookUI.profiles:LoadInventory()
    end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- tradeskills comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendTradeSkillsRequest(target, profession)
    local request = {
        type = "TRADESKILLS_REQUEST",
        payload = profession,
    }
    self:Transmit(request, "WHISPER", target, "NORMAL")
end

function Guildbook:OnTradeSkillsRequested(request, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER[request.payload] then
        local response = {
            type    = "TRADESKILLS_RESPONSE",
            payload = {
                profession = request.payload,
                recipes = GUILDBOOK_CHARACTER[request.payload],
            }
        }
        self:Transmit(response, 'GUILD', nil, "BULK")
    end
end

function Guildbook:SendTradeskillData(prof, channel, target)
    local response = {
        type    = "TRADESKILLS_RESPONSE",
        payload = {
            profession = prof,
            recipes = GUILDBOOK_CHARACTER[prof],
        }
    }
    self:Transmit(response, channel, target, "BULK")
end


-- MAKE IT SEND THE GUID


function Guildbook:OnTradeSkillsReceived(response, distribution, sender)
    --DEBUG('comms_in', 'OnTradeSkillsReceived', string.format("prof data from %s", sender))
    if response.payload.profession and type(response.payload.recipes) == 'table' then
        C_Timer.After(Guildbook.COMMS_DELAY, function()
            local guildName = Guildbook:GetGuildName()
            if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] and GUILDBOOK_GLOBAL.GuildRosterCache[guildName][response.senderGUID] then
                local character = GUILDBOOK_GLOBAL.GuildRosterCache[guildName][response.senderGUID]
                local i = 0;
                for k, v in pairs(response.payload.recipes) do
                    i = i + 1;
                end
                if character.Profession1 == "-" then
                    if character.Profession2 == "-" and (character.Profession1 ~= response.payload.profession) then
                        Guildbook:CharacterDataRequest(sender)
                    end
                end
                character[response.payload.profession] = response.payload.recipes
                GuildbookUI.statusText:SetText(string.format("received tradeskill response from %s, got %s %s recipes", sender, i, response.payload.profession))
                DEBUG('func', 'OnTradeSkillsReceived', 'updating db, set: '..sender..' prof: '..response.payload.profession)
                C_Timer.After(1, function()
                    self:RequestTradeskillData()
                end)
            end
        end)
    end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- character data comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:CharacterDataRequest(target)
    local request = {
        type = 'CHARACTER_DATA_REQUEST'
    }
    self:Transmit(request, 'WHISPER', target, 'NORMAL')
    --DEBUG('comms_out', 'CharacterDataRequest', string.format("sent character data request to %s", target))
end

function Guildbook:OnCharacterDataRequested(request, distribution, sender)
    if distribution ~= 'WHISPER' then
        return
    end
    local guid = UnitGUID('player')
    local ilvl = self:GetItemLevel()
    self.GetCharacterProfessions() -- this gets the basic prof info for primary and seconday professions
    self:GetPaperDollStats() -- this gets the paperdoll stats
    C_Timer.After(1.0, function()
        local response = {
            type = 'CHARACTER_DATA_RESPONSE',
            payload = {
                GUID = guid,
                ItemLevel = ilvl,
                Profession1Level = GUILDBOOK_CHARACTER["Profession1Level"],
                OffSpec = GUILDBOOK_CHARACTER["OffSpec"],
                Profession1 = GUILDBOOK_CHARACTER["Profession1"],
                MainCharacter = GUILDBOOK_CHARACTER["MainCharacter"],
                MainSpec = GUILDBOOK_CHARACTER["MainSpec"],
                MainSpecIsPvP = GUILDBOOK_CHARACTER["MainSpecIsPvP"],
                Profession2Level = GUILDBOOK_CHARACTER["Profession2Level"],
                Profession2 = GUILDBOOK_CHARACTER["Profession2"],
                OffSpecIsPvP = GUILDBOOK_CHARACTER["OffSpecIsPvP"],
                CookingLevel = GUILDBOOK_CHARACTER["CookingLevel"],
                FishingLevel = GUILDBOOK_CHARACTER["FishingLevel"],
                FirstAidLevel = GUILDBOOK_CHARACTER["FirstAidLevel"],

                CharStats = GUILDBOOK_CHARACTER['PaperDollStats']
            }
        }
        self:Transmit(response, 'WHISPER', sender, 'BULK')
    end)
end

function Guildbook:OnCharacterDataReceived(data, distribution, sender)
    local guildName = self:GetGuildName()
    if guildName then
        if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
            GUILDBOOK_GLOBAL.GuildRosterCache[guildName] = {}
        end
        if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID] = {}
        end
        local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID]
        character.MainCharacter = data.payload.MainCharacter
        character.MainSpec = data.payload.MainSpec
        character.MainSpecIsPvP = data.payload.MainSpecIsPvP
        character.OffSpec = data.payload.OffSpec
        character.OffSpecIsPvP = data.payload.OffSpecIsPvP
        character.Profession1 = data.payload.Profession1
        character.Profession2 = data.payload.Profession2

        -- number values
        for k, v in ipairs({"ItemLevel", "Profession1Level", "Profession2Level", 'CookingLevel', 'FishingLevel', 'FirstAidLevel'}) do
            if data.payload[v] then
                character[v] = tonumber(data.payload[v])
            end
        end
        if data.payload.CharStats then
            character.PaperDollStats = data.payload.CharStats
        end

        DEBUG('func', 'OnCharacterDataReceived', string.format('OnCharacterDataReceived > sender=%s', sender))
        C_Timer.After(Guildbook.COMMS_DELAY, function()
            GuildbookUI.statusText:SetText(string.format("received character data from %s", sender))
            GuildbookUI.profiles:LoadStats()
        end)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendGuildBankCommitRequest(bankCharacter)
    DEBUG('func', 'SendGuildBankCommitRequest', 'clearing data from temp table')
    Guildbook.GuildBankCommit['Commit'] = nil
    Guildbook.GuildBankCommit['Character'] = nil
    Guildbook.GuildBankCommit['BankCharacter'] = nil
    local request = {
        type = 'GUILD_BANK_COMMIT_REQUEST',
        payload = bankCharacter,
    }
    DEBUG('comms_out', 'SendGuildBankCommitRequest', string.format('SendGuildBankCommitRequest > character=%s', bankCharacter))
    self:Transmit(request, 'GUILD', nil, 'NORMAL')
end

function Guildbook:OnGuildBankCommitRequested(data, distribution, sender)
    if distribution == 'GUILD' then
        if GUILDBOOK_GLOBAL["GuildBank"] and GUILDBOOK_GLOBAL["GuildBank"][data.payload] and GUILDBOOK_GLOBAL["GuildBank"][data.payload].Commit then
            local response = {
                type = 'GUILD_BANK_COMMIT_RESPONSE',
                payload = { 
                    Commit = GUILDBOOK_GLOBAL["GuildBank"][data.payload].Commit,
                    Character = data.payload
                }
            }
            DEBUG('comms_out', 'OnGuildBankCommitRequested', string.format('character=%s, commit=%s', data.payload, GUILDBOOK_GLOBAL["GuildBank"][data.payload].Commit))
            self:Transmit(response, 'WHISPER', sender, 'NORMAL')
        end
    end
end

function Guildbook:OnGuildBankCommitReceived(data, distribution, sender)
    if distribution == 'WHISPER' then
        DEBUG('comms_in', 'OnGuildBankCommitReceived', string.format('Received a commit for bank character %s from %s - commit time: %s', data.payload.Character, sender, data.payload.Commit))
        if Guildbook.GuildBankCommit['Commit'] == nil then
            Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
            Guildbook.GuildBankCommit['Character'] = sender
            Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
            DEBUG('comms_in', 'OnGuildBankCommitReceived', string.format('First response added to temp table, %s->%s', sender, data.payload.Commit))
        else
            if tonumber(data.payload.Commit) > tonumber(Guildbook.GuildBankCommit['Commit']) then
                Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
                Guildbook.GuildBankCommit['Character'] = sender
                Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
                DEBUG('comms_in', 'OnGuildBankCommitReceived', string.format('Response commit is newer than temp table commit, updating info - %s->%s', sender, data.payload.Commit))
            end
        end
    end
end

function Guildbook:SendGuildBankDataRequest()
    if Guildbook.GuildBankCommit['Character'] ~= nil then
        local request = {
            type = 'GUILD_BANK_DATA_REQUEST',
            payload = Guildbook.GuildBankCommit['BankCharacter']
        }
        self:Transmit(request, 'WHISPER', Guildbook.GuildBankCommit['Character'], 'NORMAL')
        DEBUG('comms_out', 'SendGuildBankDataRequest', string.format('Sending request for guild bank data to %s for bank character %s', Guildbook.GuildBankCommit['Character'], Guildbook.GuildBankCommit['BankCharacter']))
    end
end

function Guildbook:OnGuildBankDataRequested(data, distribution, sender)
    if distribution == 'WHISPER' then
        local response = {
            type = 'GUILD_BANK_DATA_RESPONSE',
            payload = {
                Data = GUILDBOOK_GLOBAL["GuildBank"][data.payload].Data,
                Commit = GUILDBOOK_GLOBAL["GuildBank"][data.payload].Commit,
                Money = GUILDBOOK_GLOBAL["GuildBank"][data.payload].Money,
                Bank = data.payload,
            }
        }
        self:Transmit(response, 'WHISPER', sender, 'BULK')
        DEBUG('comms_out', 'OnGuildBankDataRequested', string.format('%s has requested bank data, sending data for bank character %s', sender, data.payload))
    end
end

function Guildbook:OnGuildBankDataReceived(data, distribution, sender)
    if distribution == 'WHISPER' or distribution == 'GUILD' then
        if not GUILDBOOK_GLOBAL["GuildBank"] then
            GUILDBOOK_GLOBAL["GuildBank"] = {
                [data.payload.Bank] = {
                    Commit = data.payload.Commit,
                    Data = data.payload.Data,
                    Money = data.payload.Money,
                }
            }
        else
            GUILDBOOK_GLOBAL["GuildBank"][data.payload.Bank] = {
                Commit = data.payload.Commit,
                Data = data.payload.Data,
                Money = data.payload.Money,
            }
        end
    end
    self.GuildFrame.GuildBankFrame:ProcessBankData(data.payload.Data, data.payload.Money)
    self.GuildFrame.GuildBankFrame:RefreshSlots()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- calendar data comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local calDelay = 120.0

function Guildbook:RequestGuildCalendarDeletedEvents()
    local calendarEvents = {
        type = 'GUILD_CALENDAR_EVENTS_DELETED_REQUESTED',
        payload = '-',
    }
    self:Transmit(calendarEvents, 'GUILD', nil, 'NORMAL')
    --DEBUG('comms_out', 'RequestGuildCalendarDeletedEvents', 'Sending calendar events deleted request')
end

function Guildbook:RequestGuildCalendarEvents()
    local calendarEventsDeleted = {
        type = 'GUILD_CALENDAR_EVENTS_REQUESTED',
        payload = '-',
    }
    self:Transmit(calendarEventsDeleted, 'GUILD', nil, 'NORMAL')
    --DEBUG('comms_out', 'RequestGuildCalendarEvents', 'Sending calendar events request')
end

function Guildbook:SendGuildCalendarEvent(event)
    local calendarEvent = {
        type = 'GUILD_CALENDAR_EVENT_CREATED',
        payload = event,
    }
    self:Transmit(calendarEvent, 'GUILD', nil, 'NORMAL')
    --DEBUG('comms_out', 'SendGuildCalendarEvent', string.format('Sending calendar event to guild, event title: %s', event.title))
end

function Guildbook:OnGuildCalendarEventCreated(data, distribution, sender)
    --DEBUG('comms_in', 'OnGuildCalendarEventCreated', string.format('Received a calendar event created from %s', sender))
    local guildName = Guildbook:GetGuildName()
    if guildName then
        if not GUILDBOOK_GLOBAL['Calendar'] then
            GUILDBOOK_GLOBAL['Calendar'] = {
                [guildName] = {},
            }
        else
            if not GUILDBOOK_GLOBAL['Calendar'][guildName] then
                GUILDBOOK_GLOBAL['Calendar'][guildName] = {}
            end
        end
        local exists = false
        for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            if event.created == data.payload.created and event.owner == data.payload.owner then
                exists = true
                DEBUG('func', 'OnGuildCalendarEventCreated', 'this event already exists in your db')
            end
        end
        if exists == false then
            table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], data.payload)
            DEBUG('func', 'OnGuildCalendarEventCreated', string.format('Received guild calendar event, title: %s', data.payload.title))
        end
    end
end

function Guildbook:SendGuildCalendarEventAttend(event, attend)
    local calendarEvent = {
        type = 'GUILD_CALENDAR_EVENT_ATTEND',
        payload = {
            e = event,
            a = attend,
            guid = UnitGUID('player'),
        },
    }
    self:Transmit(calendarEvent, 'GUILD', nil, 'NORMAL')
    DEBUG('func', 'SendGuildCalendarEventAttend', string.format('Sending calendar event attend update to guild, event title: %s, attend: %s', event.title, attend))
end

function Guildbook:OnGuildCalendarEventAttendReceived(data, distribution, sender)
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for k, v in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            if v.created == data.payload.e.created and v.owner == data.payload.e.owner then
                v.attend[data.payload.guid] = {
                    ['Updated'] = GetServerTime(),
                    ['Status'] = tonumber(data.payload.a),
                }
                DEBUG('func', 'OnGuildCalendarEventAttendReceived', string.format('Updated event %s: %s has set attending to %s', v.title, sender, data.payload.a))
            end
        end
    end
    --C_Timer.After(1, function()
    if Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:IsVisible() then
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateAttending()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateClassTabs()
    end
    --end)
end

function Guildbook:SendGuildCalendarEventDeleted(event)
    local calendarEventDeleted = {
        type = 'GUILD_CALENDAR_EVENT_DELETED',
        payload = event,
    }
    DEBUG('func', 'SendGuildCalendarEventDeleted', string.format('Guild calendar event deleted, event title: %s', event.title))
    self:Transmit(calendarEventDeleted, 'GUILD', nil, 'NORMAL')
end

function Guildbook:OnGuildCalendarEventDeleted(data, distribution, sender)
    self.GuildFrame.GuildCalendarFrame.EventFrame:RegisterEventDeleted(data.payload)
    DEBUG('func', 'OnGuildCalendarEventDeleted', string.format('Guild calendar event %s has been deleted', data.payload.title))
    --C_Timer.After(1, function()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
    --end)
end


-- this will be restricted to only send events that fall within a month, this should reduce chat spam
-- it is further restricted to send not within 2 minutes of previous send
function Guildbook:SendGuildCalendarEvents()
    local today = date('*t')
    local future = date('*t', (time(today) + (60*60*24*28)))
    local events = {}
    -- calendar events use a global variable to check last send as they cover all characters and are sent on login
    -- if character A logs in to check AH, mail etc they would send data, then if character B logs in they would be sending the same data
    -- so we will use a variable in account saved vars to prevent spam, delay set at 3mins
    if GetServerTime() > GUILDBOOK_GLOBAL['LastCalendarTransmit'] + 180.0 then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
            for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if not event.date then
                    DEBUG("func", 'SendGuildCalendarEvents', "event has no date table "..event.title)
                else
                    if event.date.month >= today.month and event.date.year >= today.year and event.date.month <= future.month and event.date.year <= future.year then
                        table.insert(events, event)
                        DEBUG('func', 'SendGuildCalendarEvents', string.format('Added event: %s to transmit table', event.title))
                    end
                end
            end
            local calendarEvents = {
                type = 'GUILD_CALENDAR_EVENTS',
                payload = events,
            }
            self:Transmit(calendarEvents, 'GUILD', nil, 'BULK')
            DEBUG('func', 'SendGuildCalendarEvents', string.format('range=%s-%s-%s to %s-%s-%s', today.day, today.month, today.year, future.day, future.month, future.year))
        end
        GUILDBOOK_GLOBAL['LastCalendarTransmit'] = GetServerTime()
    end
end

function Guildbook:OnGuildCalendarEventsReceived(data, distribution, sender)
    local guildName = Guildbook:GetGuildName()
    local today = date('*t')
    local monthStart = date('*t', time(today))
    if not GUILDBOOK_GLOBAL['Calendar'] then
        GUILDBOOK_GLOBAL['Calendar'] = {}
    end
    if guildName then
        if not GUILDBOOK_GLOBAL['Calendar'][guildName] then
            GUILDBOOK_GLOBAL['Calendar'][guildName] = {}
        end
    end
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        -- loop the events sent to us
        for k, recievedEvent in ipairs(data.payload) do
            DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('Received event: %s', recievedEvent.title))
            local exists = false
            -- loop our db for a match
            for _, dbEvent in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if dbEvent.created == recievedEvent.created and dbEvent.owner == recievedEvent.owner then
                    exists = true
                    DEBUG('func', 'OnGuildCalendarEventsReceived', 'event exists!')
                    -- loop the db events for attending guid
                    for guid, info in pairs(dbEvent.attend) do
                        local name;
                        if not Guildbook.PlayerMixin then
                            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                        else
                            Guildbook.PlayerMixin:SetGUID(guid)
                        end
                        if Guildbook.PlayerMixin:IsValid() then
                            name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                        end
                        if not name then
                            name = '[unknown name]'
                        end
                        -- is there a matching guid 
                        if recievedEvent.attend and recievedEvent.attend[guid] then
                            if tonumber(info.Updated) < tonumber(recievedEvent.attend[guid].Updated) then
                                info.Status = recievedEvent.attend[guid].Status
                                info.Updated = recievedEvent.attend[guid].Updated
                                DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("updated %s attend status for %s", name, dbEvent.title))
                            end
                        else
                            DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("%s wasn't in the sent event attending data", name))
                        end
                    end
                    -- loop the recieved event attending table and add any missing players
                    for guid, info in pairs(recievedEvent.attend) do
                        local name = '-'
                        if not Guildbook.PlayerMixin then
                            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                        else
                            Guildbook.PlayerMixin:SetGUID(guid)
                        end
                        if Guildbook.PlayerMixin:IsValid() then
                            name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                        end
                        if not dbEvent.attend[guid] then
                            dbEvent.attend[guid] = {}
                            dbEvent.attend[guid].Updated = GetServerTime()
                            dbEvent.attend[guid].Status = info.Status
                            DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("added %s attend status for %s", name, dbEvent.title))
                        end
                    end
                end
            end
            if exists == false then
                table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], recievedEvent)
                DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('This event is a new event, adding to db: %s', recievedEvent.title))
            end
        end
    end
    if Guildbook.GuildFrame.GuildCalendarFrame:IsVisible() then
        Guildbook.GuildFrame.GuildCalendarFrame:MonthChanged()
    end
end

function Guildbook:SendGuildCalendarDeletedEvents()
    if GetServerTime() > GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] + 120.0 then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
            local calendarDeletedEvents = {
                type = 'GUILD_CALENDAR_DELETED_EVENTS',
                payload = GUILDBOOK_GLOBAL['CalendarDeleted'][guildName],
            }
            DEBUG('func', 'SendGuildCalendarDeletedEvents', 'Sending deleted calendar events to guild')
            self:Transmit(calendarDeletedEvents, 'GUILD', nil, 'BULK')
        end
        GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] = GetServerTime()
    end
end


function Guildbook:OnGuildCalendarEventsDeleted(data, distribution, sender)
    --DEBUG('comms_in', 'OnGuildCalendarEventsDeleted', string.format('Received calendar events deleted from %s', sender))
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
        for k, v in pairs(data.payload) do
            if not GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] then
                GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] = true
                DEBUG('func', 'OnGuildCalendarEventsDeleted', 'Added event to deleted table')
            end
        end
    end
    C_Timer.After(0.5, function()
        if Guildbook.GuildFrame and Guildbook.GuildFrame.GuildCalendarFrame then
            Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
        end
    end)
end


function Guildbook:PushEventUpdate(event)
    local response = {
        type = 'GUILD_CALENDAR_EVENT_UPDATE',
        payload = event,
    }
    self:Transmit(response, 'GUILD', nil, 'NORMAL')
end


function Guildbook:OnGuildCalendarEventUpdated(data, distribution, sender)
    if distribution ~= 'GUILD' then
        return
    end
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for _, event in ipairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
            if event.owner == data.payload.owner and event.created == data.payload.created then
                event.title = data.payload.title
                event.desc = data.payload.desc
            end
        end
    end
    DEBUG('func', 'OnGuildCalendarEventUpdated', string.format("%s has updated the event %s", sender, data.payload.title))
end





-- TODO: add script for when a player drops a prof
-- SkillDetailStatusBarUnlearnButton:HookScript('OnClick', function()

-- end)












-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- events
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:ADDON_LOADED(...)
    if tostring(...):lower() == addonName:lower() then
        self:Init()
    end
end

local lastTradeskillScan = GetTime()
function Guildbook:TRADE_SKILL_UPDATE()
    local elapsed = GetTime() - lastTradeskillScan
    lastTradeskillScan = GetTime()
    if elapsed < 0.8 then
        DEBUG('func', 'TRADE_SKILL_UPDATE', 'update event within 0.8s of previous......event skipped')
        return;
    end
    self:GetCharacterProfessions()
    C_Timer.After(1.25, function()
        DEBUG('func', 'TRADE_SKILL_UPDATE', 'scanning skills')
        self:ScanTradeSkill()
    end)
end

local lastTradeskillScan_Crafts = GetTime()
function Guildbook:CRAFT_UPDATE()
    local elapsed = GetTime() - lastTradeskillScan_Crafts
    lastTradeskillScan_Crafts = GetTime()
    if elapsed < 0.8 then
        DEBUG('func', 'CRAFT_UPDATE', 'update event within 0.8s of previous......event skipped')
        return;
    end
    self:GetCharacterProfessions()
    C_Timer.After(1.25, function()
        DEBUG('func', 'CRAFT_UPDATE', 'scanning skills enchanting')
        self:ScanCraftSkills_Enchanting()
    end)
end

function Guildbook:UPDATE_MOUSEOVER_UNIT()
    -- delay any model loading while players addons sort themselves out
    if Guildbook.LoadTime and Guildbook.LoadTime + 8.0 > GetTime() then
        return
    end
    local guid = UnitGUID('mouseover')
    if guid and guid:find('Player') then
        if not Guildbook.PlayerMixin then
            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            Guildbook.PlayerMixin:SetGUID(guid)
        end
        if Guildbook.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
            -- double check mixin
            if not name then
                return
            end
            --local _, class, _ = C_PlayerInfo.GetClass(Guildbook.PlayerMixin)
            local sex = C_PlayerInfo.GetSex(Guildbook.PlayerMixin)
            if sex == 0 then
                sex = 'MALE'
            else
                sex = 'FEMALE'
            end
            local raceID = C_PlayerInfo.GetRace(Guildbook.PlayerMixin)
            local race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:upper()
            local faction = C_CreatureInfo.GetFactionInfo(raceID).groupTag
            if race and self.player and self.player.faction == C_CreatureInfo.GetFactionInfo(raceID).groupTag then
                GuildbookUI.profiles:AddCharacterModelFrame('mouseover', race, sex)
            end
        end
    end
end

function Guildbook:CHAT_MSG_GUILD(...)
    local sender = select(5, ...)
    local msg = select(1, ...)
    if not msg then
        return
    end
    local guid = select(12, ...)
    if not Guildbook.PlayerMixin then
        Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        Guildbook.PlayerMixin:SetGUID(guid)
    end
    if Guildbook.PlayerMixin:IsValid() then
        local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
        if class then
            if not Guildbook.GuildChatLog then
                Guildbook.GuildChatLog = {}
            end
            GuildbookUI.chat:AddGuildChatMessage({
                formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[class].FontColour, sender, msg),
                sender = sender,
                target = "guild",
                message = msg,
                chatID = guid,
                senderGUID = guid,
            })
        end
    end
end

function Guildbook:CHAT_MSG_WHISPER(...)
    local msg, sender, _, _, _, _, _, _, _, _, _, guid = ...
    -- local msg = select(1, ...)
    -- local sender = select(2, ...)
    -- local guid = select(12, ...) -- sender guid
    sender = Ambiguate(sender, "none")
    if not Guildbook.PlayerMixin then
        Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        Guildbook.PlayerMixin:SetGUID(guid)
    end
    if Guildbook.PlayerMixin:IsValid() then
        local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
        if class then
            GuildbookUI.chat:AddChatMessage({
                formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[class].FontColour, sender, msg),
                sender = sender,
                target = Ambiguate(UnitName("player"), "none"),
                message = msg,
                chatID = guid,
                senderGUID = guid,
            })
        end
    end
end

function Guildbook:CHAT_MSG_SYSTEM(...)
    local msg = ...
    local onlineMsg = ERR_FRIEND_ONLINE_SS:gsub("%[",""):gsub("%]",""):gsub("%%s", ".*")
    if msg:find(onlineMsg) then
        --print("online")
    end
    local offlineMsg = ERR_FRIEND_OFFLINE_S:gsub("%%s", ".*")
    if msg:find(offlineMsg) then
        --print("offline")
    end
end

function Guildbook:GUILD_ROSTER_UPDATE(...)
    if self.addonLoaded == false then
        return;
    end
    C_Timer.After(0.1, function()
        self:ScanGuildRoster()
    end)
end

function Guildbook:BAG_UPDATE()
    self:ScanPlayerBags()
end

-- added to automate the guild bank scan
function Guildbook:BANKFRAME_OPENED()
    for i = 1, GetNumGuildMembers() do
        local _, _, _, _, _, _, publicNote, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if publicNote:lower():find('guildbank') and GUID == UnitGUID('player') then
            self:ScanPlayerContainers()
        end
    end
    self:ScanPlayerBank()
end


function Guildbook:PLAYER_EQUIPMENT_CHANGED()
    self:GetCharacterInventory()
end





--- handle comms
function Guildbook:ON_COMMS_RECEIVED(prefix, message, distribution, sender)
    if prefix ~= addonName then 
        return 
    end
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message);
    if not decoded then
        return;
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then
        return;
    end
    local success, data = LibSerialize:Deserialize(decompressed);
    if not success or type(data) ~= "table" then
        return;
    end
    if data.version and data.version == self.version then
        --return;
    end

    -- this is a little plaster while we move into the newer comms
    -- its not great as it loops the roster each call but allows for older versions to still work
    if not data.senderGUID then
        data.senderGUID = self:GetGuildMemberGUID(sender)
    end

    DEBUG('comms_in', 'ON_COMMS_RECEIVED', string.format("%s from %s", data.type, sender))

    -- tradeskills
    if data.type == "TRADESKILLS_REQUEST" then
        self:OnTradeSkillsRequested(data, distribution, sender)

    elseif data.type == "TRADESKILLS_RESPONSE" then
        self:OnTradeSkillsReceived(data, distribution, sender);

    
    -- character data
    elseif data.type == 'CHARACTER_DATA_REQUEST' then
        self:OnCharacterDataRequested(data, distribution, sender)

    elseif data.type == 'CHARACTER_DATA_RESPONSE' then
        self:OnCharacterDataReceived(data, distribution, sender)


    -- profile
    elseif data.type == 'PROFILE_INFO_REQUEST' then
        self:OnProfileRequest(data, distribution, sender)

    elseif data.type == 'PROFILE_INFO_RESPONSE' then
        self:OnProfileReponse(data, distribution, sender)


    -- talents
    elseif data.type == 'TALENT_INFO_REQUEST' then
        self:OnTalentInfoRequest(data, distribution, sender)

    elseif data.type == 'TALENT_INFO_RESPONSE' then
        self:OnTalentInfoReceived(data, distribution, sender)


    -- inventory
    elseif data.type == 'INVENTORY_REQUEST' then
        self:OnCharacterInventoryRequest(data, distribution, sender)

    elseif data.type == 'INVENTORY_RESPONSE' then
        self:OnCharacterInventoryReceived(data, distribution, sender)


    -- privacy
    elseif data.type == "PRIVACY_INFO" then
        self:OnPrivacyReceived(data, distribution, sender)

    elseif data.type == "PRIVACY_ERROR" then
        self:OnPrivacyError(tonumber(data.payload), sender)

    elseif data.type == "VERSION_INFO" then
        self:OnVersionInfoRecieved(data, distribution, sender)



        
--- these will be removed slowly as we potentially move into TBC
--==================================
    elseif data.type == 'GUILD_BANK_COMMIT_REQUEST' then
        if not Guildbook.GuildFrame.GuildBankFrame then
            return
        end
        self:OnGuildBankCommitRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_COMMIT_RESPONSE' then
        if not Guildbook.GuildFrame.GuildBankFrame then
            return
        end
        self:OnGuildBankCommitReceived(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_REQUEST' then
        if not Guildbook.GuildFrame.GuildBankFrame then
            return
        end
        self:OnGuildBankDataRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_RESPONSE' then
        if not Guildbook.GuildFrame.GuildBankFrame then
            return
        end
        self:OnGuildBankDataReceived(data, distribution, sender)
--==================================





    
--- these need better naming should decide before 4.x is released?
    elseif data.type == 'GUILD_CALENDAR_EVENT_CREATED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventCreated(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENTS' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventsReceived(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENT_DELETED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventDeleted(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_DELETED_EVENTS' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventsDeleted(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENT_ATTEND' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventAttendReceived(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENTS_REQUESTED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:SendGuildCalendarEvents()

    elseif data.type == 'GUILD_CALENDAR_EVENTS_DELETED_REQUESTED' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:SendGuildCalendarDeletedEvents()

    elseif data.type == 'GUILD_CALENDAR_EVENT_UPDATE' then
        if not Guildbook.GuildFrame.GuildCalendarFrame then
            return
        end
        self:OnGuildCalendarEventUpdated(data, distribution, sender)
    end
end


--set up event listener
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
Guildbook.EventFrame:RegisterEvent('PLAYER_LEVEL_UP')
Guildbook.EventFrame:RegisterEvent('TRADE_SKILL_UPDATE')
Guildbook.EventFrame:RegisterEvent('CRAFT_UPDATE')
Guildbook.EventFrame:RegisterEvent('RAID_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_OPENED')
Guildbook.EventFrame:RegisterEvent('BAG_UPDATE')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_GUILD')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_WHISPER')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_SYSTEM')
Guildbook.EventFrame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
Guildbook.EventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    if Guildbook[event] then
        Guildbook[event](Guildbook, ...)
    end
end)