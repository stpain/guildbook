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
    code logic

    1 addon loaded = create saved vars
    2 play entering world = get player info (faction,race etc)
    3 load
        scan player professions
        scan talents
        scan inventory
        check privacy
        send calendar data
        send tradeskill recipes
]]

local addonName, Guildbook = ...

Guildbook.addonLoaded = false

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local LCI = LibStub:GetLibrary("LibCraftInfo-1.0")



---------------------------------------------------------------------------------------------------------------------------------------------------------------
--variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------

local locale = GetLocale()
local L = Guildbook.Locales

Guildbook.lastProfTransmit = GetTime()
Guildbook.FONT_COLOUR = '|cff0070DE'
Guildbook.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
Guildbook.ContextMenu_Separator_Wide = "|TInterface/COMMON/UI-TooltipDivider:8:250|t"
Guildbook.PlayerMixin = nil

Guildbook.COMMS_DELAY = 0.0
Guildbook.COMM_LOCK_COOLDOWN = 20.0
Guildbook.GUILD_NAME = nil;

Guildbook.Colours = {
    Blue = CreateColor(0.1, 0.58, 0.92, 1),
    Orange = CreateColor(0.79, 0.6, 0.15, 1),
    Yellow = CreateColor(1.0, 0.82, 0, 1),
    LightRed = CreateColor(216/255,69/255,75/255),
    BlizzBlue = CreateColor(0,191/255,243/255),
}
for class, t in pairs(Guildbook.Data.Class) do
    Guildbook.Colours[class] = CreateColor(t.RGB[1], t.RGB[2], t.RGB[3], 1)
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDBOOK1 = '/guildbook'
SLASH_GUILDBOOK2 = '/gbk'
SLASH_GUILDBOOK3 = '/gb'
SlashCmdList['GUILDBOOK'] = function(msg)
    --print("["..msg.."]")
    if msg == 'open' then
        GuildbookUI:Show()

    elseif GuildbookUI[msg] then
        GuildbookUI:OpenTo(msg)
    
    elseif msg == "version" and Guildbook.version then
        Guildbook:PrintMessage(Guildbook.version)

    elseif msg == "test" then

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
        Guildbook.DEBUG('func', 'init', 'debug active')
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
    Guildbook.DEBUG('func', 'init', tostring('Load time '..date("%T")))

    -- grab version number
    self.version = tonumber(GetAddOnMetadata('Guildbook', "Version"))
    self:SendVersionData()

    -- this makes the bank/calendar legacy features work
    if not self.GuildFrame then
        self.GuildFrame = {
            --"GuildBankFrame",
            "GuildCalendarFrame",
        }
    end
    --self:SetupGuildBankFrame()
    self:SetupGuildCalendarFrame()

    --create stored variable tables
    if GUILDBOOK_GLOBAL == nil or GUILDBOOK_GLOBAL == {} then
        GUILDBOOK_GLOBAL = self.Data.DefaultGlobalSettings
        Guildbook.DEBUG('func', 'init', 'created global saved variable table')
    else
        Guildbook.DEBUG('func', 'init', 'global variables exists')
    end
    if GUILDBOOK_CHARACTER == nil or GUILDBOOK_CHARACTER == {} then
        GUILDBOOK_CHARACTER = self.Data.DefaultCharacterSettings
        Guildbook.DEBUG('func', 'init', 'created character saved variable table')
    else
        Guildbook.DEBUG('func', 'init', 'character variables exists')
    end
    if not GUILDBOOK_GLOBAL.GuildRosterCache then
        GUILDBOOK_GLOBAL.GuildRosterCache = {}
        Guildbook.DEBUG('func', 'init', 'created guild roster cache')
    else
        Guildbook.DEBUG('func', 'init', 'guild roster cache exists')
    end
    if not GUILDBOOK_GLOBAL.Calendar then
        GUILDBOOK_GLOBAL.Calendar = {}
        Guildbook.DEBUG('func', 'init', 'created global calendar table')
    else
        Guildbook.DEBUG('func', 'init', 'global calendar table exists')
    end
    if not GUILDBOOK_GLOBAL.CalendarDeleted then
        GUILDBOOK_GLOBAL.CalendarDeleted = {}
        Guildbook.DEBUG('func', 'init', 'created global calendar deleted events table')
    else
        Guildbook.DEBUG('func', 'init', 'global calendar deleted events table exists')
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
            showTooltipTradeskillsRecipesForCharacter = false,
            showMinimapButton = true,
            showMinimapCalendarButton = true,
            showTooltipCharacterInfo = true,
            showTooltipMainCharacter = true,
            showTooltipMainSpec = true,
            showTooltipProfessions = true,
            parsePublicNotes = false,
            showInfoMessages = true,
            blockCommsDuringCombat = false,
            blockCommsDuringInstance = false,
        }
        Guildbook.DEBUG('func', 'init', "created default config table")
    end

    if GUILDBOOK_GLOBAL.config.showInfoMessages == nil then
        GUILDBOOK_GLOBAL.config.showInfoMessages = true
        Guildbook.DEBUG('func', 'init', "no info message value, adding as true")
        GuildbookOptionsShowInfoMessages:SetChecked(true)
    end

    if GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == nil then
        GUILDBOOK_GLOBAL.config.blockCommsDuringCombat = true;
        Guildbook.DEBUG('func', 'init', "no blockCommsDuringCombat, adding as true")
        GuildbookOptionsBlockCommsDuringCombat:SetChecked(true)
    end
    if GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == nil then
        GUILDBOOK_GLOBAL.config.blockCommsDuringInstance = true;
        Guildbook.DEBUG('func', 'init', "no blockCommsDuringInstance, adding as true")
        GuildbookOptionsBlockCommsDuringInstance:SetChecked(true)
    end

    local config = GUILDBOOK_GLOBAL.config
    GuildbookOptionsTooltipTradeskill:SetChecked(config.showTooltipTradeskills and config.showTooltipTradeskills or false)
    GuildbookOptionsTooltipTradeskillRecipes:SetChecked(config.showTooltipTradeskillsRecipes and config.showTooltipTradeskillsRecipes or false)
    GuildbookOptionsTooltipTradeskillRecipesForCharacter:SetChecked(config.showTooltipTradeskillsRecipesForCharacter and config.showTooltipTradeskillsRecipesForCharacter or false)

    GuildbookOptionsShowMinimapButton:SetChecked(config.showMinimapButton)
    GuildbookOptionsShowMinimapCalendarButton:SetChecked(config.showMinimapCalendarButton)

    GuildbookOptionsTooltipInfo:SetChecked(config.showTooltipCharacterInfo)
    GuildbookOptionsTooltipInfoMainSpec:SetChecked(config.showTooltipMainSpec)
    GuildbookOptionsTooltipInfoProfessions:SetChecked(config.showTooltipProfessions)
    GuildbookOptionsTooltipInfoMainCharacter:SetChecked(config.showTooltipMainCharacter)

    GuildbookOptionsShowInfoMessages:SetChecked(config.showInfoMessages)

    GuildbookOptionsBlockCommsDuringCombat:SetChecked(config.blockCommsDuringCombat)
    GuildbookOptionsBlockCommsDuringInstance:SetChecked(config.blockCommsDuringInstance)

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
        local character = Guildbook:GetCharacterFromCache(UnitGUID("player"))
        if not character then
            return;
        end
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
                                    if GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipesForCharacter then
                                        if character.Profession1 and (character.Profession1 == recipe.profession) then
                                            self:AddLine(recipe.name, 1,1,1,1)
                                        elseif character.Profession2 and (character.Profession2 == recipe.profession) then
                                            self:AddLine(recipe.name, 1,1,1,1)
                                        end
                                    else
                                        if GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipes then
                                            self:AddLine(recipe.name, 1,1,1,1)
                                        end
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
            
            -- this is for my own personal benefit remove for releases
            -- local gold = select(11, GetItemInfo(link))
            -- self:AddLine(GetCoinTextureString(gold))
        end

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
            local character = Guildbook:GetCharacterFromCache(guid)
            if not character then
                return;
            end
            self:AddLine(" ")
            self:AddLine('Guildbook:', 0.00, 0.44, 0.87, 1)
            if GUILDBOOK_GLOBAL.config.showTooltipMainSpec == true then
                if character.MainSpec then
                    local icon = Guildbook:GetClassSpecAtlasName(character.Class, character.MainSpec)
                    local iconString = CreateAtlasMarkup(icon, 24,24)
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
                if character.profile and character.profile.realBio then
                    --self:AddLine(" ")
                    self:AddLine(Guildbook.Colours.Orange:WrapTextInColorCode(character.profile.realBio), 1,1,1,true)
                end
            end
            if GUILDBOOK_GLOBAL.config.showTooltipMainCharacter == true then
                if character.MainCharacter then
                    local main = Guildbook:GetCharacterFromCache(character.MainCharacter)
                    if main then
                        C_Timer.After(0.1, function()
                            self:AppendText(" ["..Guildbook.Colours[main.Class]:WrapTextInColorCode(main.Name).."]")
                        end)
                    end
                end
            end
        end
    end)
end




function Guildbook:PLAYER_ENTERING_WORLD()
    Guildbook.DEBUG("event", "PLAYER_ENTERING_WORLD", "")
    if not GUILDBOOK_GLOBAL then
        Guildbook.DEBUG("func", "PEW", "GUILDBOOK_GLOBAL is nil or false")
        return;
    end
    -- store some info, used for character models, faction textures etc
    self.player = {
        faction = nil,
        race = nil,
    }
    C_Timer.After(1.0, function()
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
    GuildRoster() -- this will trigger a roster scan but we set addonLoaded as false at top of file to skip the auto roster scan so this is first scan
    C_Timer.After(3.0, function()
        local guildName = self:GetGuildName()
        if not guildName then
            Guildbook.DEBUG("event", "PEW", "not in a guild or no guild name")
            return -- if not in a guild just exit for now, all saved vars have been created and the player race/faction stored for the session
        end
        self:ScanGuildRoster(function()
            Guildbook:Load() -- once the roster has been scanned continue to load, its a bit meh but it means we get a full roster scan before loading
        end)
    end)
    self.EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end



--[[
    working on reducing the chat spam i've noticed during the addon loading

    so far ive adjust the character data by removing profession info
    talents no longer send updates as this broke privacy rules
]]
function Guildbook:Load()
    Guildbook.DEBUG("func", "Load", "loading addon")

    --- update the per character saved var with current data, THESE CALLS DO NOT SEND ANY COMMS
    self:GetPaperDollStats()
    self:GetCharacterTalentInfo("primary")

    -- this will make sure rank changes are handled, just set any privacy rule to the lowest rank if its wrong
    self:CheckPrivacyRankSettings()

    -- scan for prof data and update online guild members, THIS DOES SEND COMMS including prof name, level, spec and the secondary prof levels but NOT RECIPE DATA
    self:GetCharacterProfessions()

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
                ToggleFriendsFrame(3)
            elseif button == "LeftButton" then
                if GuildbookUI then
                    if GuildbookUI:IsVisible() then
                        GuildbookUI:Hide()
                    else
                        GuildbookUI:Show()
                    end
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(tostring('|cff0070DE'..addonName))
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_LEFTCLICK"])
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_LEFTCLICK_SHIFT"])
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_RIGHTCLICK"])
            tooltip:AddDoubleLine(L["MINIMAP_TOOLTIP_MIDDLECLICK"])
        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    self.MinimapIcon:Register('GuildbookMinimapIcon', self.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])

    self.MinimapCalendarButton = ldb:NewDataObject('GuildbookMinimapCalendarIcon', {
        type = "data source",
        icon = 134939,
        OnClick = function(self, button)
            if button == "RightButton" then
                if self.flyout and self.flyout:IsVisible() then
                    self.flyout:Hide()
                end
                if self.flyout then
                    self.flyout.delayTimer = 2.0;
                    self.flyout:Show()
                    GameTooltip:Hide()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end
            else
                GuildbookUI:OpenTo("calendar")
                Guildbook.GuildFrame.GuildCalendarFrame:ClearAllPoints()
                Guildbook.GuildFrame.GuildCalendarFrame:SetParent(GuildbookUI.calendar)
                Guildbook.GuildFrame.GuildCalendarFrame:SetPoint("TOPLEFT", 0, -26) --this has button above the frame so lower it a bit
                Guildbook.GuildFrame.GuildCalendarFrame:SetPoint("BOTTOMRIGHT", -2, 0)
                Guildbook.GuildFrame.GuildCalendarFrame:Show()
        
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:ClearAllPoints()
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('TOPLEFT', GuildbookUI.calendar, 'TOPRIGHT', 4, 50)
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('BOTTOMRIGHT', GuildbookUI.calendar, 'BOTTOMRIGHT', 254, 0)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            local now = date('*t')
            tooltip:AddLine('Guildbook')
            tooltip:AddLine(string.format("%s %s %s", now.day, Guildbook.Data.Months[now.month], now.year), 1,1,1,1)
            tooltip:AddLine(L["MINIMAP_CALENDAR_RIGHTCLICK"], 0.1, 0.58, 0.92, 1)
            -- get events for next 7 days
            local upcomingEvents = Guildbook:GetCalendarEvents(time(now), 7)
            if upcomingEvents and next(upcomingEvents) then
                tooltip:AddLine(' ')
                tooltip:AddLine(L['Events'])
                for k, event in ipairs(upcomingEvents) do
                    tooltip:AddDoubleLine(event.title, string.format("%s %s", event.date.day, Guildbook.Data.Months[event.date.month]), 1,1,1,1,1,1,1,1)
                end
            end
        end,
    })
    self.MinimapCalendarIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapCalendarButton'] then GUILDBOOK_GLOBAL['MinimapCalendarButton'] = {} end
    self.MinimapCalendarIcon:Register('GuildbookMinimapCalendarIcon', self.MinimapCalendarButton, GUILDBOOK_GLOBAL['MinimapCalendarButton'])

    local minimapCalendarButton = _G['LibDBIcon10_GuildbookMinimapCalendarIcon']
    for i = 1, minimapCalendarButton:GetNumRegions() do
        local region = select(i, minimapCalendarButton:GetRegions())
        if (region:GetObjectType() == 'Texture') then
            region:Hide()
        end
    end
    -- modify the minimap icon to match the blizz calendar button
    minimapCalendarButton:SetSize(44,44)
    minimapCalendarButton:SetNormalTexture("Interface\\Calendar\\UI-Calendar-Button")
    minimapCalendarButton:GetNormalTexture():SetTexCoord(0.0, 0.390625, 0.0, 0.78125)
    minimapCalendarButton:SetPushedTexture("Interface\\Calendar\\UI-Calendar-Button")
    minimapCalendarButton:GetPushedTexture():SetTexCoord(0.5, 0.890625, 0.0, 0.78125)
    minimapCalendarButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    minimapCalendarButton.DateText = minimapCalendarButton:CreateFontString(nil, 'OVERLAY', 'GameFontBlack')
    minimapCalendarButton.DateText:SetPoint('CENTER', -1, -1)
    minimapCalendarButton.DateText:SetText(date('*t').day)
    -- setup a ticker to update the date, kinda overkill maybe ?
    C_Timer.NewTicker(1, function()
        minimapCalendarButton.DateText:SetText(date('*t').day)
    end)
    -- force the size to be bigger, maybe not worth it but maybe
    -- minimapCalendarButton:SetScript("OnUpdate", function(self)
    --     self:SetSize(44,44)
    -- end)
    minimapCalendarButton.flyout = GuildbookMinimapCalendarDropdown
    minimapCalendarButton.flyout:SetParent(minimapCalendarButton)
    minimapCalendarButton.flyout:ClearAllPoints()
    minimapCalendarButton.flyout:SetPoint("TOPRIGHT", -5, -5)
    minimapCalendarButton.menu = {
        {
            text = L["CHAT"],
            func = function()
                GuildbookUI:OpenTo("chat")
            end,
        },
        {
            text = L["ROSTER"],
            func = function()
                GuildbookUI:OpenTo("roster")
            end,
        },
        {
            text = L["TRADESKILLS"],
            func = function() 
                GuildbookUI:OpenTo("tradeskills")
            end,
        },
        {
            text = L["OPEN_PROFILE"],
            func = function()
                GuildbookUI:Show()
                GuildbookUI:OpenTo("profiles")
                GuildbookUI.profiles:LoadCharacter("player")
            end,
        },
        {
            text = L["OPTIONS"],
            func = function()
                InterfaceOptionsFrame_OpenToCategory(addonName)
                InterfaceOptionsFrame_OpenToCategory(addonName)
            end,
        },
    }

    local config = GUILDBOOK_GLOBAL.config
    GuildbookOptionsModifyDefaultGuildRoster:SetChecked(config.modifyDefaultGuildRoster == true and true or false)
    if config.modifyDefaultGuildRoster == true then
        self:ModBlizzUI()
    end
    if config.showMinimapButton == false then
        self.MinimapIcon:Hide('GuildbookMinimapIcon')
        Guildbook.DEBUG('func', "Load", 'minimap icon saved var setting: false, hiding minimap button')
    end
    if config.showMinimapCalendarButton == false then
        self.MinimapCalendarIcon:Hide('GuildbookMinimapCalendarIcon')
        Guildbook.DEBUG('func', "Load", 'minimap calendar icon saved var setting: false, hiding minimap calendar button')
    end

    Guildbook:SendPrivacyInfo(nil, "GUILD")
    Guildbook.DEBUG("func", "Load", "sending privacy settings")

    ---initiate the tradeskill recipe/item request process - this isnt a great method and i plan to change this by using another addon to hold the data
    self.recipeIdsQueried, self.craftIdsQueried = {}, {}
    C_Timer.After(4, function()

        -- check the extra addon SV
        if not GUILDBOOK_TSDB then
            GUILDBOOK_TSDB = {}
        end
        if not GUILDBOOK_TSDB.recipeItems then
            GUILDBOOK_TSDB.recipeItems = {}
            Guildbook.DEBUG('tsdb', 'init', "created guildbook tradeskill database for items recipes")
        end
        if not GUILDBOOK_TSDB.enchantItems then
            GUILDBOOK_TSDB.enchantItems = {}
            Guildbook.DEBUG('tsdb', 'init', "created guildbook tradeskill database for enchanting recipes")
        end
        self:RequestTradeskillData()
        Guildbook.DEBUG("func", "Load", [[requesting tradeskill recipe\item data]])
    end)

    ---request calendar data, using a 4s stagger to allow all comms to send
    C_Timer.After(2, function()
        Guildbook:SendGuildCalendarEvents()
        Guildbook.DEBUG("func", "Load", "send calendar events")
    end)
    C_Timer.After(6, function()
        Guildbook:SendGuildCalendarDeletedEvents()
        Guildbook.DEBUG("func", "Load", "send deleted calendar events")
    end)
    C_Timer.After(10, function()
        Guildbook:RequestGuildCalendarEvents()
        Guildbook.DEBUG("func", "Load", "requested calendar events")
    end)
    C_Timer.After(14, function()
        Guildbook:RequestGuildCalendarDeletedEvents()
        Guildbook.DEBUG("func", "Load", "requested deleted calendar events")
    end)

    --TODO: update this to new db comms
    ---check and send profession recipe data
    local prof1 = self:GetCharacterInfo(UnitGUID("player"), "Profession1")
    if Guildbook.Data.Profession[prof1] then
        if GUILDBOOK_CHARACTER[prof1] then
            C_Timer.After(18, function()
                --self:SendTradeskillData(UnitGUID("player"), GUILDBOOK_CHARACTER[prof1], prof1, "GUILD", nil)
                self:DB_SendCharacterData(UnitGUID("player"), prof1, GUILDBOOK_CHARACTER[prof1], "GUILD", nil, "NORMAL")
                Guildbook.DEBUG("func", "Load", string.format("send prof recipes for %s", prof1))
            end)
        end
    end
    local prof2 = self:GetCharacterInfo(UnitGUID("player"), "Profession2")
    if Guildbook.Data.Profession[prof2] then
        if GUILDBOOK_CHARACTER[prof2] then
            C_Timer.After(22, function()
                --self:SendTradeskillData(UnitGUID("player"), GUILDBOOK_CHARACTER[prof2], prof2, "GUILD", nil)
                self:DB_SendCharacterData(UnitGUID("player"), prof2, GUILDBOOK_CHARACTER[prof2], "GUILD", nil, "NORMAL")
                Guildbook.DEBUG("func", "Load", string.format("send prof recipes for %s", prof2))
            end)
        end
    end

    if not GUILDBOOK_GLOBAL.guildBankRemoved then
        GUILDBOOK_GLOBAL.guildBankRemoved = false;
    end
    if (tonumber(self.version) == 4.9662) and GUILDBOOK_GLOBAL.guildBankRemoved == false then
        local news = L["PHASE2GB"]
        StaticPopup_Show('GuildbookUpdates', self.version, news)
    end

    self.addonLoaded = true
    self.GUILD_NAME = self:GetGuildName()



    -- quick clean up
    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems then
        for _, recipe in pairs(GUILDBOOK_TSDB.enchantItems) do
            recipe.charactersWithRecipe = nil
        end
    end
    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems then
        for _, recipe in pairs(GUILDBOOK_TSDB.recipeItems) do
            recipe.charactersWithRecipe = nil
        end
    end

end






-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local localProfNames = tInvert(Guildbook.ProfessionNames[locale])
---return the english name for a profession
---@param prof string the profession to convert back to english
---@return any
function Guildbook:GetEnglishProf(prof)
    local id = localProfNames[prof]
    if id then
        return Guildbook.ProfessionNames.enUS[id]
    end
end

---return the localized name of a profession
---@param prof string the profession to localize
---@return any
function Guildbook:GetLocaleProf(prof)
    for id, name in pairs(self.ProfessionNames["enUS"]) do
        if name == prof then
            return self.ProfessionNames[locale][id]
        end
    end
    return prof;
end

---return the atlas name for the specified class and spec, this function will handle any differences between Guildbook and the in game atlas names
---@param class string the characters class, or the class to use for the atlas
---@param spec string the characters spec, or the spec to use for the atlas
---@return string atlas the string for the atlas to use
function Guildbook:GetClassSpecAtlasName(class, spec)
    -- if none then
    --     --Mobile-MechanicIcon-Slowing questlegendaryturnin Icon-Death
    -- end
    local c, s = class, spec
    if class == "SHAMAN" then 
        if spec == "Warden" then
            c = "WARRIOR"
            s = "Protection"
        end
    elseif class == "DEATHKNIGHT" then
        if spec == "Frost (Tank)" then
            s = "Frost"
        end
    else
        if spec == "Bear" then
            s = "Guardian"
        elseif spec == "Cat" then
            s = "Feral"
        elseif spec == "Beast Master" or spec == "BeastMaster" then
            s = "BeastMastery"
        elseif spec == "Combat" then
            s = "Outlaw"
        end
    end
    if c == nil and s == nil then
        return "questlegendaryturnin"
    end

    return string.format("GarrMission_ClassIcon-%s-%s", c, s)
end


function Guildbook.CapitalizeString(s)
    if type(s) == "string" then
        return string.gsub(s, '^%a', string.upper)
    end
end


function Guildbook:MakeFrameMoveable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
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
    if not GUILDBOOK_GLOBAL then
        return;
    end
    if not GUILDBOOK_GLOBAL.config then
        return;
    end
    if GUILDBOOK_GLOBAL.config.showInfoMessages == true then
        print(string.format('[%sGuildbook|r] %s', Guildbook.FONT_COLOUR, msg))
    end
end


local helperIcons = 1
---create and return a yellow 'i' icon with a mouseover tooltip
---@param parent any global frame name or string frame name
---@param relTo any global frame name or string frame name
---@param anchor string anchor point
---@param relPoint string anchor point
---@param x number x offset
---@param y number y offset
---@param tooltiptext string text to display in tooltip
---@return ... frame the icon frame
function Guildbook:CreateHelperIcon(parent, anchor, relTo, relPoint, x, y, tooltiptext)
    local f = CreateFrame('FRAME', tostring('GuildbookHelperIcons'..helperIcons), parent)
    f:SetPoint(anchor, relTo, relPoint, x, y)
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

---format number to 2dp for character stat data/display
---@param num number the number value to format
---@return ... number the formatted number or 1
function Guildbook:FormatNumberForCharacterStats(num)
    if type(num) == 'number' then
        local trimmed = string.format("%.2f", num)
        return tonumber(trimmed)
    else
        return 1
    end
end

---get guild calendar events between given range
---@param start number the number representing the start date/time as returned by time()
---@param duration number the duration of the range, expressed as number of days
---@return table events table of events
function Guildbook:GetCalendarEvents(start, duration)
    if type(self.GUILD_NAME) ~= "string" then
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
                    Guildbook.DEBUG('func', 'Guildbook:GetCalendarEvents', 'found: '..event.title)
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
            Base = self:FormatNumberForCharacterStats(baseDef),
            Mod = self:FormatNumberForCharacterStats(modDef),
        }

        local baseArmor, effectiveArmor, armr, posBuff, negBuff = UnitArmor('player');
        GUILDBOOK_CHARACTER['PaperDollStats'].Armor = self:FormatNumberForCharacterStats(baseArmor)
        GUILDBOOK_CHARACTER['PaperDollStats'].Block = self:FormatNumberForCharacterStats(GetBlockChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].Parry = self:FormatNumberForCharacterStats(GetParryChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].ShieldBlock = self:FormatNumberForCharacterStats(GetShieldBlock());
        GUILDBOOK_CHARACTER['PaperDollStats'].Dodge = self:FormatNumberForCharacterStats(GetDodgeChance());

        --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
		GUILDBOOK_CHARACTER['PaperDollStats'].Expertise = self:FormatNumberForCharacterStats(GetExpertise()); --will display mainhand expertise but it stores offhand expertise as well, need to find a way to access it
        --local base, casting = GetManaRegen();
        GUILDBOOK_CHARACTER['PaperDollStats'].SpellHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier());
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier());
	    GUILDBOOK_CHARACTER['PaperDollStats'].RangedHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_RANGED));

        GUILDBOOK_CHARACTER['PaperDollStats'].RangedCrit = self:FormatNumberForCharacterStats(GetRangedCritChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeCrit = self:FormatNumberForCharacterStats(GetCritChance());

	    GUILDBOOK_CHARACTER['PaperDollStats'].Haste = self:FormatNumberForCharacterStats(GetHaste());
        local base, casting = GetManaRegen()
	    GUILDBOOK_CHARACTER['PaperDollStats'].ManaRegen = base and self:FormatNumberForCharacterStats(base) or 0;
	    GUILDBOOK_CHARACTER['PaperDollStats'].ManaRegenCasting = casting and self:FormatNumberForCharacterStats(casting) or 0;

        local minCrit = 100
        for id, school in pairs(spellSchools) do
            if GetSpellCritChance(id) < minCrit then
                minCrit = GetSpellCritChance(id)
            end
            GUILDBOOK_CHARACTER['PaperDollStats']['SpellDmg'..school] = self:FormatNumberForCharacterStats(GetSpellBonusDamage(id));
            GUILDBOOK_CHARACTER['PaperDollStats']['SpellCrit'..school] = self:FormatNumberForCharacterStats(GetSpellCritChance(id));
        end
        GUILDBOOK_CHARACTER['PaperDollStats'].SpellCrit = self:FormatNumberForCharacterStats(minCrit)

        GUILDBOOK_CHARACTER['PaperDollStats'].HealingBonus = self:FormatNumberForCharacterStats(GetSpellBonusHealing());

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
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDmgOH = self:FormatNumberForCharacterStats((olow + ohigh) / 2.0)
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDpsOH = self:FormatNumberForCharacterStats(((olow + ohigh) / 2.0) / offSpeed)
        else
            --offSpeed = 1
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDmgOH = self:FormatNumberForCharacterStats(0)
            GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDpsOH = self:FormatNumberForCharacterStats(0)
        end
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDmgMH = self:FormatNumberForCharacterStats((mlow + mhigh) / 2.0)
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeDpsMH = self:FormatNumberForCharacterStats(((mlow + mhigh) / 2.0) / mainSpeed)

        local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
        local low = (lowDmg + posBuff + negBuff) * percent
        local high = (hiDmg + posBuff + negBuff) * percent
        if speed < 1 then speed = 1 end
        if low < 1 then low = 1 end
        if high < 1 then high = 1 end
        local dmg = (low + high) / 2.0
        GUILDBOOK_CHARACTER['PaperDollStats'].RangedDmg = self:FormatNumberForCharacterStats(dmg)
        GUILDBOOK_CHARACTER['PaperDollStats'].RangedDps = self:FormatNumberForCharacterStats(dmg/speed)

        local base, posBuff, negBuff = UnitAttackPower('player')
        GUILDBOOK_CHARACTER['PaperDollStats'].AttackPower = self:FormatNumberForCharacterStats(base + posBuff + negBuff)

        for k, stat in pairs(statIDs) do
            local a, b, c, d = UnitStat("player", k);
            GUILDBOOK_CHARACTER['PaperDollStats'][stat] = self:FormatNumberForCharacterStats(b)
        end
        self:SetCharacterInfo(UnitGUID("player"), "PaperDollStats", GUILDBOOK_CHARACTER['PaperDollStats'])
    end
end

---fetch the character table from the cache/db
---@param guid string the characters guid
---@return table character returns either the character table from the cache or false
function Guildbook:GetCharacterFromCache(guid)
    if type(self.GUILD_NAME) ~= "string" then
        return
    end
    if type(guid) == "string" and guid:find('Player') then
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][self.GUILD_NAME] then
            if GUILDBOOK_GLOBAL['GuildRosterCache'][self.GUILD_NAME][guid] then
                return GUILDBOOK_GLOBAL['GuildRosterCache'][self.GUILD_NAME][guid]
            else
                return false;
            end
        else
            return false;
        end
    else
        return false;
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
                Guildbook.DEBUG("db_func", "SetCharacterInfo", string.format("created new db entry for %s", guid))
            end
            local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
            character[key] = value;
            Guildbook.DEBUG("db_func", "SetCharacterInfo", string.format("updated %s for %s", key, (character.Name and character.Name or guid)))
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
    return false;
end

---sends all character data to the target player (inventory, profile, talents and privacy) using a 3 second stagger
---@param player string character to send data to
---@param mod number a stagger modifier, if nil defaults as 1
function Guildbook:SendMyCharacterData_Staggered(player, mod)
    if not mod then 
        mod = 1
    end
    Guildbook.DEBUG("func", "SendMyCharacterData_Staggered", "sending data to "..player)
    self:SendCharacterData(player, "WHISPER")

    ---these next 4 calls will check the target is allowed to receive the info before sending
    C_Timer.After(3 * mod, function()
        self:SendInventoryInfo(player, "WHISPER")
    end)
    C_Timer.After(6 * mod, function()
        self:SendTalentInfo(player, "WHISPER")
    end)
    C_Timer.After(9 * mod, function()
        self:SendProfileInfo(player, "WHISPER")
    end)
    C_Timer.After(12 * mod, function()
        self:SendPrivacyInfo(player, "WHISPER")
    end)

end

local playersUpdated = {}
---sends my character data to target player, has a 30 second comm lock if already sent - doesnt send tradeskill recipes
---@param player any
function Guildbook:UpdatePlayer(player)
    if not player then
        return
    end
    if playersUpdated[player] then
        if (GetTime() - playersUpdated[player]) > 30 then
            self:SendMyCharacterData_Staggered(player)
            playersUpdated[player] = GetTime()
        end
    else
        self:SendMyCharacterData_Staggered(player)
        playersUpdated[player] = GetTime()
    end
end

local characterTradeskills = {
    ['Alchemy'] = false,
    ['Blacksmithing'] = false,
    ['Enchanting'] = false,
    ['Engineering'] = false,
    ['Inscription'] = false,
    ['Jewelcrafting'] = false,
    ['Leatherworking'] = false,
    ['Tailoring'] = false,
    ['Cooking'] = false,
    ['Mining'] = false,
}

---generate a serialize string of guild members recipes using tradeskill and recipeID as keys to reduce size. the serialized table is t[prof][recipeID] = {reagents={}, characters={guid1, guid2}}
---@return string encoded a serialized, compressed and encoded table suitable for displaying
function Guildbook:SerializeGuildTradeskillRecipes()
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
    local export = { 
        type = "TRADESKILLS",
        recipes = {},
    }
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
        for prof, _ in pairs(characterTradeskills) do
            if character.Profession1 == prof or character.Profession2 == prof then
                if character[prof] and next(character[prof]) ~= nil then
                    if not export.recipes[prof] then
                        export.recipes[prof] = {}
                    end
                    for recipeID, reagents in pairs(character[prof]) do
                        if not export.recipes[prof][recipeID] then
                            export.recipes[prof][recipeID] = {
                                reagents = reagents,
                                characters = {
                                    [guid] = 1,
                                }
                            }
                        else
                            if not export.recipes[prof][recipeID].characters[guid] then
                                export.recipes[prof][recipeID].characters[guid] = 1;
                            end
                        end
                    end
                end
            end
        end
    end
    if export then
        local serialized = LibSerialize:Serialize(export);
        local compressed = LibDeflate:CompressDeflate(serialized);
        local encoded    = LibDeflate:EncodeForPrint(compressed);
        return encoded;
    end
end


function Guildbook:ImportGuildTradeskillRecipes(text)
    local decoded = LibDeflate:DecodeForPrint(text);
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
    if data.type ~= "TRADESKILLS" then
        return;
    end
    for prof, recipes in pairs(data.recipes) do
        for recipeID, recipeInfo in pairs(recipes) do
            --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("importing %s data", prof), data.recipes[prof])
            for guid, _ in pairs(recipeInfo.characters) do
                local character = self:GetCharacterFromCache(guid)
                if character then
                    -- first set the character prof key values if missing
                    if character.Profession1 == "-" then
                        character.Profession1 = prof;
                        --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("added %s as prof1 for %s", prof, character.Name))
                    else
                        if character.Profession2 == "-" and character.Profession1 ~= prof then
                            character.Profession2 = prof;
                            --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("added %s as prof2 for %s", prof, character.Name))
                        end
                    end
                    -- create the prof table
                    if not character[prof] then
                        character[prof] = {}
                        --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("created %s table for %s", prof, character.Name))
                    end
                    -- add the recipes
                    character[prof][recipeID] = recipeInfo.reagents
                    --Guildbook.DEBUG("func", "ImportGuildTradeskillRecipes", string.format("added %s to %s for %s", recipeID, prof, character.Name))
                end
            end
        end
    end
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
    local target = self:GetGuildMemberGUID(player)
    if not target then
        return
    end
    target = Ambiguate(target, "none")
    local senderRank = GuildControlGetRankName(C_GuildInfo.GetGuildRankOrder(target))
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
                if rank == "none" then
                    
                else
                    -- set the rank to lowest, this is to cover times where a rank is deleted
                    GUILDBOOK_GLOBAL.config.privacy[rule] = lowestRank
                    Guildbook.DEBUG("func", "CheckPrivacyRankSettings", string.format("changed rank: %s to lowest rank (%s)", rank, lowestRank))
                end
            end
        end
    end
end


---this is used by the tradeskill recipe listview to set the reagent icon border colour
function Guildbook:ScanPlayerBags()
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
            if itemID and itemCount then
                if not GuildbookUI.playerContainerItems[itemID] then
                    GuildbookUI.playerContainerItems[itemID] = itemCount
                else
                    GuildbookUI.playerContainerItems[itemID] = GuildbookUI.playerContainerItems[itemID] + itemCount
                end
            end
        end
    end
end

---this is used by the tradeskill recipe listview to set the reagent icon border colour
function Guildbook:ScanPlayerBank()
    -- main bank
    for slot = 1, GetContainerNumSlots(-1) do
        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(-1, slot)
        if itemID and itemCount then
            if not GuildbookUI.playerContainerItems[itemID] then
                GuildbookUI.playerContainerItems[itemID] = itemCount
            else
                GuildbookUI.playerContainerItems[itemID] = GuildbookUI.playerContainerItems[itemID] + itemCount
            end
        end
    end
    -- bank bags
    for bag = 5, 11 do
        for slot = 1, GetContainerNumSlots(bag) do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
            if itemID and itemCount then
                if not GuildbookUI.playerContainerItems[itemID] then
                    GuildbookUI.playerContainerItems[itemID] = itemCount
                else
                    GuildbookUI.playerContainerItems[itemID] = GuildbookUI.playerContainerItems[itemID] + itemCount
                end
            end
        end
    end
end


---scan all guild members profesion recipeIDs and if no data make a request with a staggered loop
function Guildbook:RequestTradeskillData()
    if self.addonLoaded == false then
        return;
    end

    -- for debugging speed things up
    local delay = GUILDBOOK_GLOBAL['Debug'] and 0.05 or 0.1

    -- a sequential table of IDs to process { recipeID = number, prof = string, reagents = table or false}
    local recipeIdsToQuery = {}

    -- a lookup table holding character guids for each recipeID { [recipeID] = { guid1, guid2, guid3, ...} }
    self.charactersWithRecipe = {}

    -- a lookup table holding character guids for each enchanting recipeID { [recipeID] = { guid1, guid2, guid3, ...} } enchants are spells not items
    self.charactersWithEnchantRecipe = {}
    
    -- a sequential table for all tradeskill items, this doesnt need to wiped each time i dont think anyways - this must never be sorted as the keys are mapped
    if not self.tradeskillRecipes then
        self.tradeskillRecipes = {}
    end

    -- a lookup table to use for finding an tradeskill from the main table { [recipeID] = key }
    self.tradeskillRecipesKeys = {}

    -- a lookup table to use for finding an enchant from the main table { [recipeID] = key }
    self.tradeskillEnchantRecipesKeys = {}

    -- if we have no guild then exit
    if type(self.GUILD_NAME) ~= "string" then
        return;
    end

    -- if we have no saved var then exit
    if not GUILDBOOK_GLOBAL then
        return;
    end

    -- if we have no saved var then exit
    if not GUILDBOOK_GLOBAL.GuildRosterCache[self.GUILD_NAME] then
        return;
    end
    Guildbook.DEBUG("func", "RequestTradeskillData", "begin looping character cache")

    -- loop all the recipes we have from all members
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[self.GUILD_NAME]) do
        if character.Profession1 and character.Profession1 ~= "-" then
            local prof = character.Profession1
            if character[prof] and next(character[prof]) ~= nil then
                for recipeID, reagents in pairs(character[prof]) do
                    if prof == "Enchanting" then
                        if not self.charactersWithEnchantRecipe[recipeID] then
                            self.charactersWithEnchantRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithEnchantRecipe[recipeID], guid)
                        if not self.craftIdsQueried[recipeID] then
                            
                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems and GUILDBOOK_TSDB.enchantItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.enchantItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = "Enchanting", 
                                    reagents = reagents or false,
                                })
                            end
                            self.craftIdsQueried[recipeID] = true;
                        end
                    else
                        if not self.charactersWithRecipe[recipeID] then
                            self.charactersWithRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithRecipe[recipeID], guid)
                        if not self.recipeIdsQueried[recipeID] then

                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems and GUILDBOOK_TSDB.recipeItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.recipeItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = prof, 
                                    reagents = reagents or false,
                                })
                            end
                            self.recipeIdsQueried[recipeID] = true;
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
                        if not self.charactersWithEnchantRecipe[recipeID] then
                            self.charactersWithEnchantRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithEnchantRecipe[recipeID], guid)
                        if not self.craftIdsQueried[recipeID] then
                            
                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems and GUILDBOOK_TSDB.enchantItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.enchantItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = "Enchanting", 
                                    reagents = reagents or false,
                                })
                            end
                            self.craftIdsQueried[recipeID] = true;
                        end
                    else
                        if not self.charactersWithRecipe[recipeID] then
                            self.charactersWithRecipe[recipeID] = {}
                        end
                        table.insert(self.charactersWithRecipe[recipeID], guid)
                        if not self.recipeIdsQueried[recipeID] then

                            -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                            if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems and GUILDBOOK_TSDB.recipeItems[recipeID] then
                                table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.recipeItems[recipeID])
                            else
                                table.insert(recipeIdsToQuery, {
                                    recipeID = recipeID,
                                    prof = prof, 
                                    reagents = reagents or false,
                                })
                            end
                            self.recipeIdsQueried[recipeID] = true;
                        end
                    end
                end
            end
        end
        if character.Cooking and type(character.Cooking) == "table" then
            for recipeID, reagents in pairs(character.Cooking) do
                if not self.charactersWithRecipe[recipeID] then
                    self.charactersWithRecipe[recipeID] = {}
                end
                table.insert(self.charactersWithRecipe[recipeID], guid)
                if not self.recipeIdsQueried[recipeID] then

                    -- if the user has the tradeskill db addon loaded check there for item data first and add to table if exists
                    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems and GUILDBOOK_TSDB.recipeItems[recipeID] then
                        table.insert(self.tradeskillRecipes, GUILDBOOK_TSDB.recipeItems[recipeID])
                    else
                        table.insert(recipeIdsToQuery, {
                            recipeID = recipeID,
                            prof = "Cooking", 
                            reagents = reagents or false,
                        })
                    end
                    self.recipeIdsQueried[recipeID] = true;
                end
            end
        end
    end
    
    local statusBar = GuildbookUI.tradeskills.statusBar
    statusBar:SetValue(0)
    statusBar:Show()
    local statusBarText = GuildbookUI.tradeskills.statusBarText
    statusBarText:SetText("Loading...")
    statusBarText:Show()

    if #recipeIdsToQuery > 0 then
        local startTime = time();
        self:PrintMessage(string.format("found %s recipes, estimated duration %s", #recipeIdsToQuery, SecondsToTime(#recipeIdsToQuery*delay)))
        table.sort(recipeIdsToQuery, function(a,b)
            if a.prof == b.prof then
                return a.recipeID > b.recipeID -- sort highest id first, should help display newest expansion items sooner
            else
                return a.prof < b.prof
            end
        end)
        local i = 1;
        Guildbook.DEBUG('func', 'tradeskill data requst', string.format("found %s recipes, estimated duration %s", #recipeIdsToQuery, SecondsToTime(#recipeIdsToQuery*delay)))

        C_Timer.NewTicker(delay, function()
            if not recipeIdsToQuery[i] then
                return
            end

            local recipeID = recipeIdsToQuery[i].recipeID

            local prof = recipeIdsToQuery[i].prof
            local reagents = recipeIdsToQuery[i].reagents

            local link, rarity, name, expansion, icon = false, false, false, 0, false

            local _, spellID = LCI:GetItemSource(recipeID)

            local _, _, _, equipLoc, _, itemClassID, itemSubClassID = GetItemInfoInstant(recipeID)
            if not equipLoc then
                equipLoc = "INVTYPE_NON_EQUIP"
            end
            if prof == "Enchanting" then
                equipLoc = "INVTYPE_NON_EQUIP";
            end

            if spellID then
                expansion = LCI:GetCraftXPack(spellID)
            end
            if prof == 'Enchanting' then
                link = GetSpellLink(recipeID)
                rarity = 1
                name = GetSpellInfo(recipeID)
                if not name then
                    name = "unknown"
                end
            else
                name, link, rarity, _, _, _, _, _, _, icon = GetItemInfo(recipeID)
            end
            if not link and not name and not rarity and not icon then
                if prof == 'Enchanting' then                    
                    local spell = Spell:CreateFromSpellID(recipeID)
                    spell:ContinueOnSpellLoad(function()
                        link = GetSpellLink(recipeID)
                        name, _, icon = GetSpellInfo(recipeID)
                        if not name then
                            name = "unknown"
                        end
                        if not icon then
                            icon = 136244
                        end
                        local recipe = {
                            itemID = recipeID,
                            reagents = reagents,
                            rarity = 1,
                            link = link,
                            icon = icon,
                            expsanion = expansion,
                            enchant = true,
                            name = name,
                            profession = prof,
                            equipLocation = equipLoc,
                            class = -1,
                            subClass = -1,
                            --charactersWithRecipe = self.charactersWithEnchantRecipe[recipeID],
                        }
                        table.insert(self.tradeskillRecipes, recipe)
                        if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems then
                            GUILDBOOK_TSDB.enchantItems[recipeID] = recipe;
                        end
                    end)
                else
                    local item = Item:CreateFromItemID(recipeID)
                    item:ContinueOnItemLoad(function()
                        link = item:GetItemLink()
                        rarity = item:GetItemQuality()
                        name = item:GetItemName()
                        icon = item:GetItemIcon()
                        local recipe = {
                            itemID = recipeID,
                            reagents = reagents,
                            rarity = rarity,
                            link = link,
                            icon = icon,
                            expansion = expansion,
                            enchant = false,
                            name = name,
                            profession = prof,
                            equipLocation = equipLoc,
                            class = itemClassID,
                            subClass = itemSubClassID,
                            --charactersWithRecipe = self.charactersWithRecipe[recipeID],
                        }
                        table.insert(self.tradeskillRecipes, recipe)
                        if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems then
                            GUILDBOOK_TSDB.recipeItems[recipeID] = recipe;
                        end
                    end)
                end
            else
                if prof == "Enchanting" then
                    local recipe = {
                        itemID = recipeID,
                        reagents = reagents,
                        rarity = 1,
                        link = link,
                        icon = icon,
                        expsanion = expansion,
                        enchant = true,
                        name = name,
                        profession = prof,
                        equipLocation = equipLoc,
                        class = -1,
                        subClass = -1,
                        --charactersWithRecipe = self.charactersWithEnchantRecipe[recipeID],
                    }
                    table.insert(self.tradeskillRecipes, recipe)
                    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.enchantItems then
                        GUILDBOOK_TSDB.enchantItems[recipeID] = recipe;
                    end
                else
                    local recipe = {
                        itemID = recipeID,
                        reagents = reagents,
                        rarity = rarity,
                        link = link,
                        icon = icon,
                        expansion = expansion,
                        enchant = false,
                        name = name,
                        profession = prof,
                        equipLocation = equipLoc,
                        class = itemClassID,
                        subClass = itemSubClassID,
                        --charactersWithRecipe = self.charactersWithRecipe[recipeID],
                    }
                    table.insert(self.tradeskillRecipes, recipe)
                    if GUILDBOOK_TSDB and GUILDBOOK_TSDB.recipeItems then
                        GUILDBOOK_TSDB.recipeItems[recipeID] = recipe;
                    end
                end
            end

            statusBar:SetValue(i / #recipeIdsToQuery)
            statusBarText:SetText(string.format(L["PROCESSED_RECIPES_SS"], i, #recipeIdsToQuery))

            i = i + 1;
            if i > #recipeIdsToQuery then

                --- create or update the recipeID key mapping
                for k, v in ipairs(self.tradeskillRecipes) do
                    if v.enchant then
                        self.tradeskillEnchantRecipesKeys[v.itemID] = k
                    else
                        self.tradeskillRecipesKeys[v.itemID] = k
                    end
                    statusBar:SetValue(k / #self.tradeskillRecipes)
                    statusBarText:SetText(string.format("mapping keys %s of %s", k, #self.tradeskillRecipes))
                end

                statusBar:Hide()
                statusBarText:SetText("")
                statusBarText:Hide()

                self:PrintMessage(string.format("all tradeskill recipes processed, took %s", SecondsToTime(time()-startTime)))
                Guildbook.DEBUG('func', 'tradeskill data requst', string.format("all tradeskill recipes processed, took %s", SecondsToTime(time()-startTime)))

                return;
            end

        end, #recipeIdsToQuery)


    -- if we have no recipes to request then update the key mapping
    else
        --- create or update the recipeID key mapping
        for k, v in ipairs(self.tradeskillRecipes) do
            if v.enchant then
                self.tradeskillEnchantRecipesKeys[v.itemID] = k
            else
                self.tradeskillRecipesKeys[v.itemID] = k
            end
            statusBar:SetValue(k / #self.tradeskillRecipes)
            statusBarText:SetText(string.format("mapping keys %s of %s", k, #self.tradeskillRecipes))
        end
        statusBar:Hide()
        statusBar:SetValue(0)
        statusBarText:SetText("")
        statusBarText:Hide()
        --self:PrintMessage(string.format("tradeskill recipe mapping updated"))
        Guildbook.DEBUG('func', 'tradeskill data requst', "no new recipes to query")
    end
end


function Guildbook:CheckCharacterProfessionsForErrors()

end


local profSpecData = {
    --Alchemy:
    [28672] = 171,
    [28677] = 171,
    [28675] = 171,
    --Engineering:
    [20222] = 202,
    [20219] = 202,
    --Tailoring:
    [26798] = 197,
    [26797] = 197,
    [26801] = 197,
    --Blacksmithing:
    [9788] = 164,
    [17039] = 164,
    [17040] = 164,
    [17041] = 164,
    [9787] = 164,
    --Leatherworking:
    [10656] = 165,
    [10658] = 165,
    [10660] = 165,
}

--- scan the players professions
-- get the name of any professions the player has, the profession level
-- also check the secondary professions fishing, cooking, first aid
-- this will update the character saved var which is then read when a request comes in
function Guildbook:GetCharacterProfessions()
    Guildbook.DEBUG("func", "GetCharacterProfessions", "scanning character skills for profession info")

    -- scan for prof specs
    --reset the data, this covers whenever a player unlearns a prof
    GUILDBOOK_CHARACTER.Profession1Spec = false
    GUILDBOOK_CHARACTER.Profession2Spec = false
    -- get spell count in general tab pf spell book
    local _, _, offset, numSlots = GetSpellTabInfo(1)
    for j = offset+1, offset+numSlots do
        -- get spell id
        local _, spellID = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
        -- check if spell is a prof spec
        if profSpecData[spellID] then
            -- grab the english name for prof
            local engProf = Guildbook.ProfessionNames.enUS[profSpecData[spellID]]
            -- assign the prof spec
            if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER.Profession1 and (GUILDBOOK_CHARACTER.Profession1 == engProf) then
                GUILDBOOK_CHARACTER.Profession1Spec = tonumber(spellID)
            elseif GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER.Profession2 and (GUILDBOOK_CHARACTER.Profession2 == engProf) then
                GUILDBOOK_CHARACTER.Profession2Spec = tonumber(spellID)
            end
        end
    end

    -- scan for prof info
    local myCharacter = { Fishing = 0, Cooking = 0, FirstAid = 0, Prof1 = '-', Prof1Level = 0, Prof2 = '-', Prof2Level = 0 }
    for s = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)
        if Guildbook:GetEnglishProf(skill) == 'Fishing' then 
            Guildbook.DEBUG("func", "GetCharacterProfessions", "found fishing updating level")
            myCharacter.Fishing = level
        elseif Guildbook:GetEnglishProf(skill) == 'Cooking' then
            Guildbook.DEBUG("func", "GetCharacterProfessions", "found cooking updating level")
            myCharacter.Cooking = level
        elseif Guildbook:GetEnglishProf(skill) == 'First Aid' then
            Guildbook.DEBUG("func", "GetCharacterProfessions", "found first aid updating level")
            myCharacter.FirstAid = level
        else
            for k, prof in pairs(Guildbook.Data.Profession) do
                if prof.Name == Guildbook:GetEnglishProf(skill) then
                    Guildbook.DEBUG("func", "GetCharacterProfessions", string.format("found %s", prof.Name))
                    if myCharacter.Prof1 == '-' then
                        myCharacter.Prof1 = Guildbook:GetEnglishProf(skill)
                        Guildbook.DEBUG("func", "GetCharacterProfessions", string.format("setting Profession1 as %s", prof.Name))
                        myCharacter.Prof1Level = level
                    else
                        if myCharacter.Prof2 == '-' then
                            myCharacter.Prof2 = Guildbook:GetEnglishProf(skill)
                            Guildbook.DEBUG("func", "GetCharacterProfessions", string.format("setting Profession2 as %s", prof.Name))
                            myCharacter.Prof2Level = level
                        end
                    end
                    if myCharacter.Prof1 == myCharacter.Prof2 then
                        myCharacter.Prof2 = Guildbook:GetEnglishProf(skill)
                        myCharacter.Prof2Level = level
                        Guildbook.DEBUG("func", "GetCharacterProfessions", string.format("updated setting for Profession2 > set as %s", prof.Name))
                    end
                end
            end
        end
    end
    if GUILDBOOK_CHARACTER then
        local guid = UnitGUID("player")

        --update the per character saved var
        GUILDBOOK_CHARACTER['Profession1'] = myCharacter.Prof1
        GUILDBOOK_CHARACTER['Profession1Level'] = myCharacter.Prof1Level
        GUILDBOOK_CHARACTER['Profession2'] = myCharacter.Prof2
        GUILDBOOK_CHARACTER['Profession2Level'] = myCharacter.Prof2Level

        GUILDBOOK_CHARACTER['FishingLevel'] = myCharacter.Fishing
        GUILDBOOK_CHARACTER['CookingLevel'] = myCharacter.Cooking
        GUILDBOOK_CHARACTER['FirstAidLevel'] = myCharacter.FirstAid

        -- both of these functions will return out if their respective tradeskill windows are not open so they are safe to call here
        C_Timer.After(2.0, function()
            self:ScanTradeskillRecipes()
            self:ScanEnchantingRecipes()
        end)

    end
end


--- scan the players trade skills
--- this is used to get data about the players professions, recipes and reagents
function Guildbook:ScanTradeskillRecipes(pushRecipes)
    local localeProf = GetTradeSkillLine() -- this returns local name
    if localeProf == "UNKNOWN" then
        return; -- exit as the window isnt open
    end
    if Guildbook:GetEnglishProf(localeProf) then
        local prof = Guildbook:GetEnglishProf(localeProf) --convert to english
        if not prof then
            Guildbook.DEBUG("func", "ScanTradeskillRecipes", "couldnt get english name for tradeskill, scan cancelled")
            return
        end
        GUILDBOOK_CHARACTER[prof] = {}
        if self:GetCharacterInfo(UnitGUID("player"), "Profession1") == "-" then
            self:SetCharacterInfo(UnitGUID("player"), "Profession1", prof)
        else
            if self:GetCharacterInfo(UnitGUID("player"), "Profession2") == "-" then
                self:SetCharacterInfo(UnitGUID("player"), "Profession2", prof)
            end
        end
        Guildbook.DEBUG("func", "ScanTradeskillRecipes", "created or reset table for "..prof)
        -- get the current recipe count, we will compare this to the scan count to determine if we send data
        local numTradeskills = GetNumTradeSkills()
        for i = 1, numTradeskills do
            local name, _type, _, _, _ = GetTradeSkillInfo(i)
            if name and (_type == "optimal" or _type == "medium" or _type == "easy" or _type == "trivial") then -- this was a fix thanks to Sigma regarding their addon showing all recipes
                local link = GetTradeSkillItemLink(i)
                if link then
                    local itemID = GetItemInfoInstant(link)
                    if itemID then
                        GUILDBOOK_CHARACTER[prof][itemID] = {}
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
                end
            end
        end
    end
end

--- scan the players enchanting recipes, enchanting works a little differently 
--- this is used to get data about the players professions, recipes and reagents
function Guildbook:ScanEnchantingRecipes(pushRecipes)
    local currentCraftingWindow = GetCraftSkillLine(1)
    if currentCraftingWindow == nil then
        return; -- exit as no craft open
    end
    local engProf = Guildbook:GetEnglishProf(currentCraftingWindow)
    if Guildbook:GetEnglishProf(currentCraftingWindow) == "Enchanting" then -- check we have enchanting open
        GUILDBOOK_CHARACTER['Enchanting'] = {}
        if self:GetCharacterInfo(UnitGUID("player"), "Profession1") == "-" then
            self:SetCharacterInfo(UnitGUID("player"), "Profession1", "Enchanting")
        else
            if self:GetCharacterInfo(UnitGUID("player"), "Profession2") == "-" then
                self:SetCharacterInfo(UnitGUID("player"), "Profession2", "Enchanting")
            end
        end
        local numCrafts = GetNumCrafts()
        for i = 1, numCrafts do
            local name, _, _type, _, _, _, _ = GetCraftInfo(i)
            if name and (_type == "optimal" or _type == "medium" or _type == "easy" or _type == "trivial") then -- this was a fix thanks to Sigma regarding their addon showing all recipes
                local _, _, _, _, _, _, itemID = GetSpellInfo(name)
                if itemID then
                    GUILDBOOK_CHARACTER['Enchanting'][itemID] = {}
                    local numReagents = GetCraftNumReagents(i);
                    if numReagents > 0 then
                        for j = 1, numReagents do
                            local _, _, reagentCount = GetCraftReagentInfo(i, j)
                            local reagentLink = GetCraftReagentItemLink(i, j)
                            if reagentLink then
                                local reagentID = select(1, GetItemInfoInstant(reagentLink))
                                if reagentID and reagentCount then
                                    GUILDBOOK_CHARACTER['Enchanting'][itemID][reagentID] = reagentCount
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


---send your characters tradeskill data including recipes to all onlinie guild members, this sends using a stagger system with a 2s stagger, total time to send is about 2.5s
function Guildbook:SendCharacterTradeskillData()

    if not GUILDBOOK_CHARACTER then
        return;
    end

    local guid = UnitGUID("player")

    if type(GUILDBOOK_CHARACTER.Profession1) == "string" then
        self:DB_SendCharacterData(guid, "Profession1", GUILDBOOK_CHARACTER.Profession1, "GUILD", nil, "NORMAL")
    end
    if type(GUILDBOOK_CHARACTER.Profession1Level) == "number" then
        C_Timer.After(0.2, function()
            self:DB_SendCharacterData(guid, "Profession1Level", GUILDBOOK_CHARACTER.Profession1Level, "GUILD", nil, "NORMAL")
        end)
    end
    if type(GUILDBOOK_CHARACTER.Profession2) == "string" then
        C_Timer.After(0.4, function()
            self:DB_SendCharacterData(guid, "Profession2", GUILDBOOK_CHARACTER.Profession2, "GUILD", nil, "NORMAL")
        end)
    end
    if type(GUILDBOOK_CHARACTER.Profession2Level) == "number" then
        C_Timer.After(0.6, function()
            self:DB_SendCharacterData(guid, "Profession2Level", GUILDBOOK_CHARACTER.Profession2Level, "GUILD", nil, "NORMAL")
        end)
    end
    if type(GUILDBOOK_CHARACTER.Cooking) == "number" then
        C_Timer.After(0.8, function()
            self:DB_SendCharacterData(guid, "CookingLevel", GUILDBOOK_CHARACTER.Cooking, "GUILD", nil, "NORMAL")
        end) 
    end  
    if type(GUILDBOOK_CHARACTER.Fishing) == "number" then
        C_Timer.After(1.0, function()
            self:DB_SendCharacterData(guid, "FishingLevel", GUILDBOOK_CHARACTER.Fishing, "GUILD", nil, "NORMAL")
        end)
    end
    if type(GUILDBOOK_CHARACTER.FirstAid) == "number" then
        C_Timer.After(1.2, function()
            self:DB_SendCharacterData(guid, "FirstAidLevel", GUILDBOOK_CHARACTER.FirstAid, "GUILD", nil, "NORMAL")
        end)
    end
    if type(GUILDBOOK_CHARACTER.Profession1Spec) == "number" then
        C_Timer.After(1.4, function()            
            self:DB_SendCharacterData(guid, "Profession1Spec", GUILDBOOK_CHARACTER.Profession2Spec, "GUILD", nil, "NORMAL")
        end)
    end
    if type(GUILDBOOK_CHARACTER.Profession2Spec) == "number" then
        C_Timer.After(1.6, function()            
            self:DB_SendCharacterData(guid, "Profession2Spec", GUILDBOOK_CHARACTER.Profession2Spec, "GUILD", nil, "NORMAL")
        end)
    end
    C_Timer.After(1.8, function()
        local prof1 = self:GetCharacterInfo(UnitGUID("player"), "Profession1")
        if Guildbook.Data.Profession[prof1] then
            if GUILDBOOK_CHARACTER[prof1] then
                self:DB_SendCharacterData(UnitGUID("player"), prof1, GUILDBOOK_CHARACTER[prof1], "GUILD", nil, "NORMAL")
                Guildbook.DEBUG("func", "Load", string.format("send prof recipes for %s", prof1))
            end
        end  
    end)
    C_Timer.After(2.2, function()
        local prof2 = self:GetCharacterInfo(UnitGUID("player"), "Profession2")
        if Guildbook.Data.Profession[prof2] then
            if GUILDBOOK_CHARACTER[prof2] then
                self:DB_SendCharacterData(UnitGUID("player"), prof2, GUILDBOOK_CHARACTER[prof2], "GUILD", nil, "NORMAL")
                Guildbook.DEBUG("func", "Load", string.format("send prof recipes for %s", prof2))
            end
        end  
    end)

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
    if not guild then 
        return 
    end
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache then
        if not GUILDBOOK_GLOBAL.GuildRosterCache[guild] then
            GUILDBOOK_GLOBAL.GuildRosterCache[guild] = {}
            Guildbook.DEBUG("func", "ScanGuildRoster", "created roster cache for "..guild)
        end
        if self.scanRosterTicker then
            self.scanRosterTicker:Cancel()
        end
        local memberGUIDs = {}
        local currentGUIDs = {}
        if not self.onlineZoneInfo then
            self.onlineZoneInfo = {}
        end
        local faction = self.player.faction
        if not faction then
            return;
        end
        local newGUIDs = {}
        local totalMembers, onlineMember, _ = GetNumGuildMembers()
        GUILDBOOK_GLOBAL['RosterExcel'] = {}
        for i = 1, totalMembers do
            --local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            local name, rankName, _, level, class, zone, publicNote, officerNote, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            name = Ambiguate(name, 'none')
            if not GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] then
                GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] = {
                    Name = name,
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
            self.onlineZoneInfo[guid] = {
                online = isOnline,
                zone = zone,
            }
            --name = Ambiguate(name, 'none')
            --table.insert(GUILDBOOK_GLOBAL['RosterExcel'], string.format("%s,%s,%s,%s,%s", name, class, rankName, level, publicNote))
        end
        local i = 1;
        local start = date('*t')
        local started = time()
        GuildbookUI.statusText:SetText(string.format("starting roster scan at %s:%s:%s", start.hour, start.min, start.sec))
        self.scanRosterTicker = C_Timer.NewTicker(0.0001, function()
            local percent = (i/totalMembers) * 100
            GuildbookUI.statusText:SetText(string.format("roster scan %s%%",string.format("%.1f", percent)))
            GuildbookUI.statusBar:SetValue(i/totalMembers)
            if not currentGUIDs[i] then
                return;
            end
            local guid = currentGUIDs[i].GUID
            local info = GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid]
            if info then
                local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid)
                -- if not self.PlayerMixin then
                --     self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                -- else
                --     self.PlayerMixin:SetGUID(guid)
                -- end
                -- if self.PlayerMixin:IsValid() then
                    -- local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
                    -- local name = C_PlayerInfo.GetName(self.PlayerMixin)
                    if name and class and race and sex and realm then
                        --local raceID = C_PlayerInfo.GetRace(self.PlayerMixin)
                        --local race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:upper()
                        --local sex = (C_PlayerInfo.GetSex(self.PlayerMixin) == 1 and "FEMALE" or "MALE")
                        sex = (sex == 3) and "FEMALE" or "MALE"
                        --local faction = C_CreatureInfo.GetFactionInfo(raceID).groupTag
                        
                        info.Faction = faction;
                        info.Race = race;
                        info.Gender = sex;
                        info.Class = class;
                        info.Name = Ambiguate(name, 'none');
                        info.PublicNote = currentGUIDs[i].pubNote;
                        info.OfficerNote = currentGUIDs[i].offNote;
                        info.RankName = currentGUIDs[i].rank;
                        info.Level = currentGUIDs[i].lvl;

                        if not info.MainSpec then
                            info.MainSpec = "-"
                        end
                        if info.MainSpec == nil then
                            info.MainSpec = "-"
                        end

                        -- this was a bug found where i used Prof1 instead of Profession1
                        -- if not info.Profession1 then
                        --     info.Profession1 = (info.Prof1 and info.Prof1 or "-")
                        -- end
                        -- if not info.Profession2 then
                        --     info.Profession2 = (info.Prof2 and info.Prof2 or "-")
                        -- end
                        -- if info.Profession1 == "-" and info.Profession2 == "-" then
                        --     Guildbook.DEBUG("func", "ScanGuildRoster", string.format("no prof keys for %s", info.Name))
                        -- end
                        -- remove the old
                        -- info.Prof1 = nil
                        -- info.Prof2 = nil
                        -- if not info.Profession1Level then
                        --     info.Profession1Level = (info.Prof1Level and info.Prof1Level or "-")
                        -- end
                        -- if not info.Profession2Level then
                        --     info.Profession2Level = (info.Prof2Level and info.Prof2Level or "-")
                        -- end
                        -- remove the old
                        -- info.Prof1Level = nil
                        -- info.Prof2Level = nil

                        for _, prof in ipairs(Guildbook.Data.Professions) do
                            if info[prof.Name] then
                                --Guildbook.DEBUG("func", "ScanGuildRoster", string.format("found %s in %s db", prof.Name, info.Name))
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
                                        Guildbook.DEBUG("func", "ScanGuildRoster", string.format("set %s profession1 as %s because it was blank", info.Name, prof.Name))
                                    else
                                        if info.Profession2 == "-" then
                                            info.Profession2 = prof.Name
                                            Guildbook.DEBUG("func", "ScanGuildRoster", string.format("set %s profession2 as %s because it was blank", info.Name, prof.Name))
                                        else
                                            info[prof.Name] = nil
                                            Guildbook.DEBUG("func", "ScanGuildRoster", string.format("|cffC41F3Bremoved|r %s from %s", prof.Name, info.Name))
                                        end
                                    end
                                end
                            end
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
                --end
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
                C_Timer.After(0.05, function()
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


function Guildbook:RequestOnlineMembersProfessionData(onlineMembers)
    if not onlineMembers then
        return
    end
    if type(onlineMembers) ~= "table" then
        return
    end
    local numOnline = #onlineMembers

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
        --wipe(GUILDBOOK_CHARACTER['Talents'])
        GUILDBOOK_CHARACTER['Talents'][activeTalents] = {}
        -- will need dual spec set up for wrath
        local tabs = {}
        for tabIndex = 1, GetNumTalentTabs() do
            local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
            local engSpec = Guildbook.Data.TalentBackgroundToSpec[fileName]
            table.insert(tabs, {points = pointsSpent, spec = engSpec})
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
                    Link = GetTalentLink(tabIndex, talentIndex),
                })
            end
        end
        table.sort(tabs, function(a,b)
            return a.points > b.points
        end)
        if GUILDBOOK_CHARACTER.smartGuessMainSpec then
            GUILDBOOK_CHARACTER.MainSpec = tabs[1].spec
        end
        self:SetCharacterInfo(UnitGUID("player"), "Talents", GUILDBOOK_CHARACTER.Talents)

        --- to avoid breaking the privacy rules this must only be sent when requested
        -- self:DB_SendCharacterData(UnitGUID("player"), "MainSpec", GUILDBOOK_CHARACTER.MainSpec, "GUILD", nil, "NORMAL")
        -- self:DB_SendCharacterData(UnitGUID("player"), "Talents", GUILDBOOK_CHARACTER.Talents, "GUILD", nil, "NORMAL")
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
            --Guildbook.DEBUG('func', 'GetCharacterInventory', string.format("added %s at slot %s", link or 'false', slot.Name))
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


-- horrible system but nothing better developed yet
function Guildbook:IsGuildMemberOnline(player, guid)
    -- if self.onlineMembers and self.onlineMembers[player] then
    --     Guildbook.DEBUG("func", "IsPlayerOnline", string.format("%s is online: %s", player, tostring(self.onlineMembers[player])))
    --     return self.onlineMembers[player];
    -- end
        -- leaving this for now
        local online = false
        local guildName = Guildbook:GetGuildName()
        if guildName then
            local totalMembers, onlineMembers, _ = GetNumGuildMembers()
            for i = 1, totalMembers do
                local name, _, _, _, _, zone, _, _, isOnline = GetGuildRosterInfo(i)
                name = Ambiguate(name, "none")
                --Guildbook.DEBUG('func', 'IsGuildMemberOnline', string.format("player %s is online %s", name, tostring(isOnline)))
                if name == Ambiguate(player, 'none') then
                    return isOnline, zone;
                end
            end
        end
        return false, "offline"
end


















-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Transmit(data, channel, target, priority)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in combat")
            return;
        end
    end
    if not self:GetGuildName() then
        return;
    end

    -- add the version and sender guid to the message
    data["version"] = tostring(self.version);
    data["senderGUID"] = UnitGUID("player")

    -- clean up the target name when using a whisper
    if channel == 'WHISPER' then
        target = Ambiguate(target, 'none')
    end

    -- only send to online players, this was to reduce/remove chat spam, its not 100% efficient but knowing who is online is a grey area
    if target ~= nil then
        local totalMembers, _, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
            name = Ambiguate(name, "none")
            if name == target then
                if isOnline == true then
                    local serialized = LibSerialize:Serialize(data);
                    local compressed = LibDeflate:CompressDeflate(serialized);
                    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
                
                    if addonName and encoded and channel and priority then
                        Guildbook.DEBUG('comms_out', 'SendCommMessage_TargetOnline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
                        self:SendCommMessage(addonName, encoded, channel, target, priority)
                    end
                else
                    Guildbook.DEBUG('error', 'SendCommMessage_TargetOffline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
                end
            end
        end
    else
        local serialized = LibSerialize:Serialize(data);
        local compressed = LibDeflate:CompressDeflate(serialized);
        local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    
        if addonName and encoded and channel and priority then
            Guildbook.DEBUG('comms_out', 'SendCommMessage_NoTarget', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
            self:SendCommMessage(addonName, encoded, channel, target, priority)
        end
    end


    -- local ok, serialized = pcall(LibSerialize.Serialize, LibSerialize, data)
    -- if not ok then
    --     LoadAddOn("Blizzard_DebugTools")
    --     DevTools_Dump(data)
    --     return
    -- end

    -- local serialized = LibSerialize:Serialize(data);
    -- local compressed = LibDeflate:CompressDeflate(serialized);
    -- local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);

    -- if addonName and encoded and channel and priority then
    --     Guildbook.DEBUG('comms_out', 'SendCommMessage', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
    --     self:SendCommMessage(addonName, encoded, channel, target, priority)
    -- end
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

local versionsChecked = {}
function Guildbook:OnVersionInfoRecieved(data, distribution, sender)
    -- we dont care about our own version check
    if data.senderGUID == UnitGUID("player") then
        return;
    end
    if data.payload then
        if tonumber(self.version) < tonumber(data.payload) then
            if not versionsChecked[data.payload] then -- if we havent seen this version number then inform the player
                local msgID = math.random(4)
                print(string.format('[%sGuildbook|r] %s', Guildbook.FONT_COLOUR, L["NEW_VERSION_"..msgID]))
                versionsChecked[data.payload] = true;
            end            
        elseif tonumber(self.version) > tonumber(data.payload) then
            self:SendVersionData() -- if our version is newer send it back to inform the player
        end
    end
    -- the idea here is to update characters when they come online, allowing 30s means the player logging on has time for addons to load up
    -- the issue is however, they might log off before 30s which results in the 'No playername ...' system messages
    -- TODO: revise this system and improve

    -- revision 1 is to simpy reduce the wait to 5s as the update func has a built in 30s comm lock for alt switchers etc
    C_Timer.After(5, function()
        self:UpdatePlayer(sender)
    end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- send anything comms
--[[
    the idea of this set of comms is to create a more universal method of sending data
    it will be using the newer roster cache get/set functions
    it allows the addon to send a specific key/value
]]
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---send a request for character data
---@param guid string the guid for the character
---@param key string the key for the data requested
---@param channel string should be WHISPER for almost all requests
---@param target string the characters name you are whispering
---@param priority string should be NORMAL for almost all requests
function Guildbook:DB_RequestCharacterData(guid, key, channel, target, priority)
    if not guid then
        return
    end
    local transmition = {
        type = "DB_GET",
        payload = {
            guid = guid,
            key = key,
        }
    }
    self:Transmit(transmition, channel, target, priority)
end

function Guildbook:DB_OnDataRequest(data, distribution, sender)

end

function Guildbook:DB_SendCharacterData(guid, key, info, channel, target, priority)
    if not guid then
        return
    end
    if type(key) ~= "string" then
        return
    end
    local transmition = {
        type = "DB_SET",
        payload = {
            guid = guid,
            key = key,
            info = info,
        }
    }
    self:Transmit(transmition, channel, target, priority)
end


function Guildbook:DB_OnDataReceived(data, distribution, sender)
    if not data then
        return;
    end
    if not data.payload then
        return;
    end
    if type(data.payload.key) ~= "string" then
        return;
    end
    if data.payload.guid and data.payload.info then
        Guildbook.DEBUG("db_func", "DB_OnDataReceived", string.format("received %s info from %s", data.payload.key, sender), data)
        self:SetCharacterInfo(data.payload.guid, data.payload.key, data.payload.info)
    end

    --for new users, the addon will have scanned their professions but because there would be no data during the load for this function to loop the key mapping wouldnt be complete
    --so if we get tradeskill data call the function, it only makes requests where data is missing so will skip repeated requests
    --need to sort out some callbacks but for now we check if the key was a profession and if so request data
    --this function will only request data for recipes where data hasnt been requested


    if Guildbook.Data.Profession[data.payload.key] then
        Guildbook.DEBUG('db_func', 'DB_OnDataReceived', string.format("received data for %s, calling function > RequestTradeskillData", data.payload.key))
        self:RequestTradeskillData()
    end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- privacy comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lastPrivacyTransmit = -1000
local privacyTransmitQueued = false
function Guildbook:SendPrivacyInfo(target, channel)
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
        local character = self:GetCharacterFromCache(data.senderGUID)
        if not character then
            return;
        end
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
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s profile data", character.Name))
            end
        else
            if data.payload.privacy.shareProfileMinRank and data.payload.privacy.shareProfileMinRank == "none" then
                character.profile = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s profile data", character.Name))
            end
        end
        if data.payload.privacy.shareInventoryMinRank and ranks[data.payload.privacy.shareInventoryMinRank] and type(ranks[data.payload.privacy.shareInventoryMinRank]) == "number" then
            if ranks[myRank] > ranks[data.payload.privacy.shareInventoryMinRank] then
                character.Inventory = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s inventory data", character.Name))
            end
        else
            if data.payload.privacy.shareInventoryMinRank and data.payload.privacy.shareInventoryMinRank == "none" then
                character.Inventory = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s inventory data", character.Name))
            end
        end
        if data.payload.privacy.shareTalentsMinRank and ranks[data.payload.privacy.shareTalentsMinRank] and type(ranks[data.payload.privacy.shareTalentsMinRank]) == "number" then
            if ranks[myRank] > ranks[data.payload.privacy.shareTalentsMinRank] then
                character.Talents = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s talents data", character.Name))
            end
        else
            if data.payload.privacy.shareTalentsMinRank and data.payload.privacy.shareTalentsMinRank == "none" then
                character.Talents = nil;
                Guildbook.DEBUG("error", "OnPrivacyReceived", string.format("removed %s talents data", character.Name))
            end
        end
    end
end


function Guildbook:OnPrivacyError(code, sender)
    if code == 0 then
        Guildbook.DEBUG("error", "PrivacyError", string.format("%s not sharing inventory", sender))
    elseif code == 1 then
        Guildbook.DEBUG("error", "PrivacyError", string.format("%s not sharing talents", sender))
    elseif code == 2 then
        Guildbook.DEBUG("error", "PrivacyError", string.format("%s not sharing profile", sender))
    end
end









-- profile, talents and inventory have a privacy setting option and so these comms stay under the request/send system where the addon checks the requesting character



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

function Guildbook:SendProfileInfo(target, channel)
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER.profile then
        local response = {
            type = "PROFILE_INFO_RESPONSE",
            payload = GUILDBOOK_CHARACTER.profile
        }
        if self:ShareWithPlayer(target, "shareProfileMinRank") == true then
            self:Transmit(response, channel, target, "BULK")
        else
            self:Transmit({
                type = "PRIVACY_ERROR",
                payload = 2,
            },
            channel, 
            target, 
            "NORMAL")
        end
    end
end

function Guildbook:OnProfileRequest(request, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    self:SendProfileInfo(sender, "WHISPER")
end

function Guildbook:OnProfileReponse(response, distribution, sender)
    if not response.senderGUID then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][response.senderGUID] then
                GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][response.senderGUID].profile = response.payload;
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

function Guildbook:SendTalentInfo(target, channel)
    self:GetCharacterTalentInfo('primary')
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER['Talents'] then
        local response = {
            type = "TALENT_INFO_RESPONSE",
            payload = {
                guid = UnitGUID('player'),
                talents = GUILDBOOK_CHARACTER['Talents'],
            }
        }
        if self:ShareWithPlayer(target, "shareTalentsMinRank") == true then
            self:Transmit(response, channel, target, "BULK")
        else
            self:Transmit({
                type = "PRIVACY_ERROR",
                payload = 1,
            },
            channel, 
            target, 
            "NORMAL")
        end
    end
end

function Guildbook:OnTalentInfoRequest(request, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    self:SendTalentInfo(sender, "WHISPER")
end

function Guildbook:OnTalentInfoReceived(response, distribution, sender)
    if not response.senderGUID then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        self:SetCharacterInfo(response.senderGUID, "Talents", response.payload.talents)
        Guildbook.DEBUG('func', 'OnTalentInfoReceived', string.format('updated %s talents', sender))
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

---sends your characters inventory to the target - checks if target has permission to view data
---@param target string the name of player to send data to
---@param channel string the chat channel to use
function Guildbook:SendInventoryInfo(target, channel)
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
            if self:ShareWithPlayer(target, "shareInventoryMinRank") == true then
                self:Transmit(response, channel, target, "BULK")
            else
                self:Transmit({
                    type = "PRIVACY_ERROR",
                    payload = 0,
                },
                channel, 
                target, 
                "NORMAL")
            end
        end
    end)
end

function Guildbook:OnCharacterInventoryRequest(data, distribution, sender)
    if distribution ~= 'WHISPER' then
        return
    end
    self:SendInventoryInfo(sender, "WHISPER")
end


function Guildbook:OnCharacterInventoryReceived(response, distribution, sender)
    if not response.senderGUID then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][response.senderGUID].Inventory = response.payload.inventory
            Guildbook.DEBUG('func', 'OnCharacterInventoryReceived', string.format('updated %s inventory', sender))
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

function Guildbook:SendTradeskillData(guid, recipes, prof, channel, target)
    local response = {
        type    = "TRADESKILLS_RESPONSE",
        payload = {
            guid = guid,
            profession = prof,
            recipes = recipes,
        }
    }
    self:Transmit(response, channel, target, "BULK")
end



function Guildbook:OnTradeSkillsReceived(response, distribution, sender)
    --Guildbook.DEBUG('comms_in', 'OnTradeSkillsReceived', string.format("prof data from %s", sender))
    if response.payload.profession and type(response.payload.recipes) == 'table' then
        C_Timer.After(Guildbook.COMMS_DELAY, function()
            local character;
            if response.payload.guid then
                character = self:GetCharacterFromCache(response.payload.guid)
            else
                character = self:GetCharacterFromCache(response.senderGUID)
            end
            if not character then
                return
            end
            local i, j = 0, 0;
            local prof = response.payload.profession
            if not prof then
                return
            end
            if type(prof) ~= "string" then
                return
            end
            Guildbook.DEBUG("func", "OnTradeSkillsReceived", string.format("received %s data from %s", prof, sender))
            if not character[prof] then
                character[prof] = {}
                Guildbook.DEBUG("func", "OnTradeSkillsReceived", string.format("created table for %s", prof))
            end
            for recipeID, reagents in pairs(response.payload.recipes) do
                -- local item = Item:CreateFromItemID(recipeID)
                -- item:ContinueOnItemLoad(function()
                
                -- end)
                if not character[prof][recipeID] then
                    character[prof][recipeID] = reagents
                    j = j + 1;
                end
                i = i + 1;
            end

            --character[response.payload.profession] = response.payload.recipes
            GuildbookUI.statusText:SetText(string.format("%s data for [|cffffffff%s|r] sent by %s", prof, character.Name, sender))
            Guildbook.DEBUG('func', 'OnTradeSkillsReceived', 'updating db, set: '..character.Name..' prof: '..response.payload.profession)
            C_Timer.After(1, function()
                self:RequestTradeskillData()
            end)
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
end

---send character data, includes ilvl offSpec, mainSpec, mainCharacter, mainIsPvp, offIsPvp, paperDollStats
---@param target any
---@param channel any
function Guildbook:SendCharacterData(target, channel)
    local guid = UnitGUID('player')
    local ilvl = self:GetItemLevel()
    self:GetPaperDollStats() -- this gets the paperdoll stats and saves the data to the per character saved var
    C_Timer.After(1.0, function()
        local response = {
            type = 'CHARACTER_DATA_RESPONSE',
            payload = {
                GUID = guid,
                ItemLevel = ilvl,
                OffSpec = GUILDBOOK_CHARACTER["OffSpec"],
                MainCharacter = GUILDBOOK_CHARACTER["MainCharacter"],
                MainSpec = GUILDBOOK_CHARACTER["MainSpec"],
                MainSpecIsPvP = GUILDBOOK_CHARACTER["MainSpecIsPvP"],
                OffSpecIsPvP = GUILDBOOK_CHARACTER["OffSpecIsPvP"],
                CharStats = GUILDBOOK_CHARACTER['PaperDollStats']
            }
        }
        self:Transmit(response, channel, target, 'BULK')
    end)
end


function Guildbook:OnCharacterDataRequested(request, distribution, sender)
    if distribution ~= 'WHISPER' then
        return
    end
    self:SendCharacterData(sender, "WHISPER")
end

function Guildbook:OnCharacterDataReceived(data, distribution, sender)
    if not data.payload.GUID then
        return
    end
    local character = self:GetCharacterFromCache(data.payload.GUID)
    if not character then
        return
    end

    -- the plan is to move around some of the comms data, by using a loop here and checking for the key we can start to remove some of the data
    for k, v in pairs(character) do
        if data.payload[k] then
            character[k] = data.payload[k]
            Guildbook.DEBUG("func", "OnCharacterDataReceived", string.format("updated %s for %s", k, character.Name))
        end
    end

    -- keep this as is to avoid issues between versions
    if data.payload.CharStats then
        character.PaperDollStats = data.payload.CharStats
    end

    Guildbook.DEBUG('func', 'OnCharacterDataReceived', string.format('%s sent their character data', sender))
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        GuildbookUI.statusText:SetText(string.format("received character data from %s", sender))
        GuildbookUI.profiles:LoadStats()
    end)
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
    --Guildbook.DEBUG('comms_out', 'RequestGuildCalendarDeletedEvents', 'Sending calendar events deleted request')
end

function Guildbook:RequestGuildCalendarEvents()
    local calendarEventsDeleted = {
        type = 'GUILD_CALENDAR_EVENTS_REQUESTED',
        payload = '-',
    }
    self:Transmit(calendarEventsDeleted, 'GUILD', nil, 'NORMAL')
    --Guildbook.DEBUG('comms_out', 'RequestGuildCalendarEvents', 'Sending calendar events request')
end

function Guildbook:SendGuildCalendarEvent(event)
    local calendarEvent = {
        type = 'GUILD_CALENDAR_EVENT_CREATED',
        payload = event,
    }
    self:Transmit(calendarEvent, 'GUILD', nil, 'NORMAL')
    --Guildbook.DEBUG('comms_out', 'SendGuildCalendarEvent', string.format('Sending calendar event to guild, event title: %s', event.title))
end

function Guildbook:OnGuildCalendarEventCreated(data, distribution, sender)
    --Guildbook.DEBUG('comms_in', 'OnGuildCalendarEventCreated', string.format('Received a calendar event created from %s', sender))
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
                Guildbook.DEBUG('func', 'OnGuildCalendarEventCreated', 'this event already exists in your db')
            end
        end
        if exists == false then
            table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], data.payload)
            Guildbook.DEBUG('func', 'OnGuildCalendarEventCreated', string.format('Received guild calendar event, title: %s', data.payload.title))
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
    Guildbook.DEBUG('func', 'SendGuildCalendarEventAttend', string.format('Sending calendar event attend update to guild, event title: %s, attend: %s', event.title, attend))
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
                Guildbook.DEBUG('func', 'OnGuildCalendarEventAttendReceived', string.format('Updated event %s: %s has set attending to %s', v.title, sender, data.payload.a))
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
    Guildbook.DEBUG('func', 'SendGuildCalendarEventDeleted', string.format('Guild calendar event deleted, event title: %s', event.title))
    self:Transmit(calendarEventDeleted, 'GUILD', nil, 'NORMAL')
end

function Guildbook:OnGuildCalendarEventDeleted(data, distribution, sender)
    self.GuildFrame.GuildCalendarFrame.EventFrame:RegisterEventDeleted(data.payload)
    Guildbook.DEBUG('func', 'OnGuildCalendarEventDeleted', string.format('Guild calendar event %s has been deleted', data.payload.title))
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
                    Guildbook.DEBUG("func", 'SendGuildCalendarEvents', "event has no date table "..event.title)
                else
                    if event.date.month >= today.month and event.date.year >= today.year and event.date.month <= future.month and event.date.year <= future.year then
                        table.insert(events, event)
                        Guildbook.DEBUG('func', 'SendGuildCalendarEvents', string.format('Added event: %s to transmit table', event.title))
                    end
                end
            end
            local calendarEvents = {
                type = 'GUILD_CALENDAR_EVENTS',
                payload = events,
            }
            self:Transmit(calendarEvents, 'GUILD', nil, 'BULK')
            Guildbook.DEBUG('func', 'SendGuildCalendarEvents', string.format('range=%s-%s-%s to %s-%s-%s', today.day, today.month, today.year, future.day, future.month, future.year))
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
            Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('Received event: %s', recievedEvent.title))
            local exists = false
            -- loop our db for a match
            for _, dbEvent in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if dbEvent.created == recievedEvent.created and dbEvent.owner == recievedEvent.owner then
                    exists = true
                    Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', 'event exists!')
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
                                Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("updated %s attend status for %s", name, dbEvent.title))
                            end
                        else
                            Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("%s wasn't in the sent event attending data", name))
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
                            Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format("added %s attend status for %s", name, dbEvent.title))
                        end
                    end
                end
            end
            if exists == false then
                table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], recievedEvent)
                Guildbook.DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('This event is a new event, adding to db: %s', recievedEvent.title))
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
            Guildbook.DEBUG('func', 'SendGuildCalendarDeletedEvents', 'Sending deleted calendar events to guild')
            self:Transmit(calendarDeletedEvents, 'GUILD', nil, 'BULK')
        end
        GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] = GetServerTime()
    end
end


function Guildbook:OnGuildCalendarEventsDeleted(data, distribution, sender)
    --Guildbook.DEBUG('comms_in', 'OnGuildCalendarEventsDeleted', string.format('Received calendar events deleted from %s', sender))
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
        for k, v in pairs(data.payload) do
            if not GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] then
                GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] = true
                Guildbook.DEBUG('func', 'OnGuildCalendarEventsDeleted', 'Added event to deleted table')
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
    Guildbook.DEBUG('func', 'OnGuildCalendarEventUpdated', string.format("%s has updated the event %s", sender, data.payload.title))
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


function Guildbook:CHARACTER_POINTS_CHANGED(...)
    if tonumber(...) < 0 then
        if self.talentPointsChangedTimer then
            self.talentPointsChangedTimer:Cancel()
        else
            self.talentPointsChangedTimer = C_Timer.NewTimer(10.0, function()
                self:GetCharacterTalentInfo("primary")
            end)
        end
    end
end



function Guildbook:SKILL_LINES_CHANGED()
    if self.addonLoaded then
        self:GetCharacterProfessions()
    end
end


---the time waited before sending character tradeskill data, as players could be power leveling a prof we dont want to spam everytime the level up
local scanDelay = 15.0

local tradeskillScanQueued = false;
function Guildbook:TRADE_SKILL_UPDATE()
    if self.addonLoaded then
        self:ScanTradeskillRecipes()
        if tradeskillScanQueued == true then
            Guildbook.DEBUG("event", "TRADES_KILL_UPDATE", "craft scan queued already")
        else
            tradeskillScanQueued = true;
            C_Timer.After(scanDelay, function()
                self:SendCharacterTradeskillData()
                tradeskillScanQueued = false;
                Guildbook.DEBUG("event", "TRADES_KILL_UPDATE", "craft scan queue reset")
            end)
        end
    end
end

local craftsScanQueued = false;
function Guildbook:CRAFT_UPDATE()
    if self.addonLoaded then
        self:ScanEnchantingRecipes()
        if craftsScanQueued == true then
            Guildbook.DEBUG("event", "CRAFT_UPDATE", "craft scan queued already")
        else
            craftsScanQueued = true;
            C_Timer.After(scanDelay, function()
                self:SendCharacterTradeskillData()
                craftsScanQueued = false;
                Guildbook.DEBUG("event", "CRAFT_UPDATE", "craft scan queue reset")
            end)
        end
    end
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
    -- local onlineMsg = ERR_FRIEND_ONLINE_SS:gsub("%[",""):gsub("%]",""):gsub("%%s", ".*")
    -- if msg:find(onlineMsg) then
    --     local name, _ = strsplit(" ", msg)
    --     local brokenLink = name:sub(2, #name-1)
    --     local player = brokenLink:sub(brokenLink:find(":")+1, brokenLink:find("%[")-1)
    --     if player then
    --         if not self.onlineMembers then
    --             self.onlineMembers = {}
    --         end
    --         self.onlineMembers[player] = true
    --         Guildbook.DEBUG("event", "CHAT_MSG_SYSTEM", string.format("set %s as online", player))
    --     end
    -- end
    local joinedGuild = ERR_GUILD_JOIN_S:gsub("%%s", ".*")
    if msg:find(joinedGuild) then
        local name, _ = strsplit(" ", msg)
        if Ambiguate(name, "none") ~= Ambiguate(UnitName("player"), "none") then
            return;
        end
        Guildbook.DEBUG("event", "CHAT_MSG_SYSTEM", "player joined a guild")
        C_Timer.After(3.0, function()
            GuildRoster() -- this will trigger a roster scan but we set addonLoaded as false at top of file to skip the auto roster scan so this is first scan
            C_Timer.After(1.5, function()
                self:ScanGuildRoster(function()
                    Guildbook:Load() -- once the roster has been scanned continue to load, its a bit meh but it means we get a full roster scan before loading
                end)
            end)
        end)
    end
    -- local offlineMsg = ERR_FRIEND_OFFLINE_S:gsub("%%s", ".*")
    -- if msg:find(offlineMsg) then
    --     local player, _ = strsplit(" ", msg)
    --     if player then
    --         if not self.onlineMembers then
    --             self.onlineMembers = {}
    --         end
    --         self.onlineMembers[player] = false
    --         Guildbook.DEBUG("event", "CHAT_MSG_SYSTEM", string.format("set %s as offline", player))
    --     end
    -- end
end

function Guildbook:GUILD_ROSTER_UPDATE(...)
    if self.addonLoaded == false then
        return;
    end
    C_Timer.After(0.1, function()
        self:ScanGuildRoster()
    end)
end

function Guildbook:BAG_UPDATE_DELAYED()
    self:ScanPlayerBags()
end


function Guildbook:BANKFRAME_OPENED()

end

-- added this to the closed event to be extra accurate
local bankScanned = false;
function Guildbook:BANKFRAME_CLOSED()
    if bankScanned == false then
        Guildbook.DEBUG("event", "BANKFRAME_CLOSED", "scanning items")
        self:ScanPlayerBank()
        bankScanned = true;
    else
        bankScanned = false;
    end
end


function Guildbook:PLAYER_EQUIPMENT_CHANGED()
    self:GetCharacterInventory()
end



--- handle comms
function Guildbook:ON_COMMS_RECEIVED(prefix, message, distribution, sender)

    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringInstance == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in an instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        if GUILDBOOK_GLOBAL.config and (GUILDBOOK_GLOBAL.config.blockCommsDuringCombat == true) then
            GuildbookUI.statusText:SetText("blocked data comms while in combat")
            return;
        end
    end

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
    -- if not data.senderGUID then
    --     data.senderGUID = self:GetGuildMemberGUID(sender)
    -- end

    Guildbook.DEBUG('comms_in', string.format("ON_COMMS_RECEIVED <%s>", distribution), string.format("%s from %s", data.type, sender), data)

    if data.type == "DB_SET" then
        self:DB_OnDataReceived(data, distribution, sender)

    -- tradeskills
    elseif data.type == "TRADESKILLS_REQUEST" then
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




--==================================
    elseif data.type == 'GUILD_BANK_COMMIT_REQUEST' then
        self:OnGuildBankCommitRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_COMMIT_RESPONSE' then
        self:OnGuildBankCommitReceived(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_REQUEST' then
        self:OnGuildBankDataRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_RESPONSE' then
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

function Guildbook:GUILD_INVITE_REQUEST(...)
    local _, guildName = ...
end

--set up event listener
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('GUILD_INVITE_REQUEST')
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
Guildbook.EventFrame:RegisterEvent('PLAYER_LEVEL_UP')
Guildbook.EventFrame:RegisterEvent('TRADE_SKILL_UPDATE')
Guildbook.EventFrame:RegisterEvent('CRAFT_UPDATE')
Guildbook.EventFrame:RegisterEvent('SKILL_LINES_CHANGED')
Guildbook.EventFrame:RegisterEvent('RAID_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_OPENED')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_CLOSED')
Guildbook.EventFrame:RegisterEvent('BAG_UPDATE_DELAYED')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_GUILD')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_WHISPER')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_SYSTEM')
Guildbook.EventFrame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
Guildbook.EventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
Guildbook.EventFrame:RegisterEvent('CHARACTER_POINTS_CHANGED')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    if Guildbook[event] then
        Guildbook[event](Guildbook, ...)
    end
end)
