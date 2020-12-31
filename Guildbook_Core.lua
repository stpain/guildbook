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

local build = 3.31
local locale = GetLocale()

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--debug printers
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.ErrorColours = {
    ['func'] = '|cffC41F3B',
    ['comms'] = '|cff0070DE',
}
function Guildbook.DEBUG(timestamp, err, msg)
    if timestamp and err and msg then
        table.insert(Guildbook.DebugLog, string.format("%s [|cffABD473%s|r], %s", timestamp, err, msg))
    else
        table.insert(Guildbook.DebugLog, 'oops something went wrong!')
    end
    if Guildbook.DebugLog and next(Guildbook.DebugLog) then
        local i = #Guildbook.DebugLog - 19
        if i < 1 then
            i = 1
        end
        Guildbook.DebugFrame.ScrollBar:SetMinMaxValues(1, i)
        Guildbook.DebugFrame.ScrollBar:SetValue(i)
        for i = 1, 20 do
            Guildbook.DebugFrame.Listview[i]:Hide()
            Guildbook.DebugFrame.Listview[i]:Show()
        end
    end
end

Guildbook.DebugLog = {}

Guildbook.DebugFrame = CreateFrame('FRAME', 'SRBLPUI', UIParent, "UIPanelDialogTemplate")
Guildbook.DebugFrame:SetPoint('CENTER', 0, 0)
Guildbook.DebugFrame:SetSize(800, 260)
Guildbook.DebugFrame:SetMovable(true)
Guildbook.DebugFrame:EnableMouse(true)
Guildbook.DebugFrame:RegisterForDrag("LeftButton")
Guildbook.DebugFrame:SetScript("OnDragStart", Guildbook.DebugFrame.StartMoving)
Guildbook.DebugFrame:SetScript("OnDragStop", Guildbook.DebugFrame.StopMovingOrSizing)

Guildbook.DebugFrame.header = Guildbook.DebugFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
Guildbook.DebugFrame.header:SetPoint('TOP', 0, -9)
Guildbook.DebugFrame.header:SetText('Guildbook Debug')

Guildbook.DebugFrame.Listview = {}
for i = 1, 20 do
    local f = CreateFrame('BUTTON', tostring('SRBLP_LogsListview'..i), Guildbook.DebugFrame)
    f:SetPoint('TOPLEFT', Guildbook.DebugFrame, 'TOPLEFT', 8, (i * -11) -20)
    f:SetPoint('TOPRIGHT', Guildbook.DebugFrame, 'TOPRIGHT', -8, (i * -11) -20)
    f:SetHeight(10)
    f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
    f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
    f.Message = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    f.Message:SetPoint('LEFT', 8, 0)
    f.Message:SetSize(780, 20)
    f.Message:SetJustifyH('LEFT')
    f.Message:SetTextColor(1,1,1,1)
    f.msg = nil
    f:SetScript('OnShow', function(self)
        if self.msg then
            self.Message:SetText(self.msg)
        else
            self:Hide()
        end
    end)
    f:SetScript('OnHide', function(self)
        self.Message:SetText(' ')
    end)
    f:SetScript('OnMouseWheel', function(self, delta)
        local s = Guildbook.DebugFrame.ScrollBar:GetValue()
        Guildbook.DebugFrame.ScrollBar:SetValue(s - delta)
    end)
    Guildbook.DebugFrame.Listview[i] = f
end

Guildbook.DebugFrame.ScrollBar = CreateFrame('SLIDER', 'GuildbookDebugFrameScrollBar', Guildbook.DebugFrame, "UIPanelScrollBarTemplate")
Guildbook.DebugFrame.ScrollBar:SetPoint('TOPLEFT', Guildbook.DebugFrame, 'TOPRIGHT', -24, -44)
Guildbook.DebugFrame.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.DebugFrame, 'BOTTOMRIGHT', -8, 26)
Guildbook.DebugFrame.ScrollBar:EnableMouse(true)
Guildbook.DebugFrame.ScrollBar:SetValueStep(1)
Guildbook.DebugFrame.ScrollBar:SetValue(1)
Guildbook.DebugFrame.ScrollBar:SetMinMaxValues(1, 1)
Guildbook.DebugFrame.ScrollBar:SetScript('OnValueChanged', function(self)
    if Guildbook.DebugLog then
        local scrollPos = math.floor(self:GetValue())
        if scrollPos == 0 then
            scrollPos = 1
        end
        for i = 1, 20 do
            if Guildbook.DebugLog[(i - 1) + scrollPos] then
                Guildbook.DebugFrame.Listview[i]:Hide()
                Guildbook.DebugFrame.Listview[i].msg = Guildbook.DebugLog[(i - 1) + scrollPos]
                Guildbook.DebugFrame.Listview[i]:Show()
            end
        end
    end
end)

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------
local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG

Guildbook.FONT_COLOUR = '|cff0070DE'
Guildbook.PlayerMixin = nil
Guildbook.GuildBankCommit = {
    Commit = nil,
    Character = nil,
}
Guildbook.NUM_TALENT_ROWS = 7.0

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDBOOK1 = '/guildbook'
SlashCmdList['GUILDBOOK'] = function(msg)
    if msg == '-help' then
        print(':(')

    elseif msg == '-scanbank' then
        Guildbook:ScanCharacterContainers()

    elseif msg == '-talents' then
        Guildbook:GetPlayerTalentInfo(UnitGUID('player'))

    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Init()
    DEBUG(GetServerTime(), 'init', 'running init')
    
    local version = GetAddOnMetadata('Guildbook', "Version")

    self.ContextMenu_DropDown = CreateFrame("Frame", "GuildbookContextMenu", UIParent, "UIDropDownMenuTemplate")
    self.ContextMenu = {}

    AceComm:Embed(self)
    self:RegisterComm(addonName, 'ON_COMMS_RECEIVED')

    --create stored variable tables
    if GUILDBOOK_GLOBAL == nil or GUILDBOOK_GLOBAL == {} then
        GUILDBOOK_GLOBAL = self.Data.DefaultGlobalSettings
        DEBUG(GetServerTime(), 'init', 'created global saved variable table')
    else
        DEBUG(GetServerTime(), 'init', 'global variables exists')
    end
    if GUILDBOOK_CHARACTER == nil or GUILDBOOK_CHARACTER == {} then
        GUILDBOOK_CHARACTER = self.Data.DefaultCharacterSettings
        DEBUG(GetServerTime(), 'init', 'created character saved variable table')
    else
        DEBUG(GetServerTime(), 'init', 'character variables exists')
    end
    --added later
    if not GUILDBOOK_GLOBAL['GuildRosterCache'] then
        GUILDBOOK_GLOBAL['GuildRosterCache'] = {}
    end
    if GUILDBOOK_GLOBAL['Build'] == nil then
        GUILDBOOK_GLOBAL['Build'] = 0
    end
    if tonumber(GUILDBOOK_GLOBAL['Build']) < build then
        GUILDBOOK_GLOBAL['Build'] = build
        StaticPopup_Show('GuildbookUpdates', version, Guildbook.News[build])
    end
    -- added later again
    if not GUILDBOOK_GLOBAL['Calendar'] then
        GUILDBOOK_GLOBAL['Calendar'] = {}
    end
    if not GUILDBOOK_GLOBAL['CalendarDeleted'] then
        GUILDBOOK_GLOBAL['CalendarDeleted'] = {}
    end
    if not GUILDBOOK_GLOBAL['LastCalendarTransmit'] then
        GUILDBOOK_GLOBAL['LastCalendarTransmit'] = GetServerTime()
    end
    if not GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] then
        GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] = GetServerTime()
    end

    local ldb = LibStub("LibDataBroker-1.1")
    self.MinimapButton = ldb:NewDataObject('GuildbookMinimapIcon', {
        type = "data source",
        icon = 134939,
        OnClick = function(self, button)
            if button == "LeftButton" then
                if InterfaceOptionsFrame:IsVisible() then
                    InterfaceOptionsFrame:Hide()
                else
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                end
            elseif button == 'RightButton' then
                ToggleFriendsFrame(3)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(tostring('|cff0070DE'..addonName))
            tooltip:AddDoubleLine('|cffffffffLeft Click|r Options')
            tooltip:AddDoubleLine('|cffffffffRight Click|r Guild')
        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    self.MinimapIcon:Register('GuildbookMinimapIcon', self.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])
    -- used a timer here for some reason to force hiding
    C_Timer.After(1, function()
        if GUILDBOOK_GLOBAL['ShowMinimapButton'] == false then
            self.MinimapIcon:Hide('GuildbookMinimapIcon')
            DEBUG('init', 'minimap icon saved var setting: false, hiding minimap button')
        end
    end)

    GuildbookOptionsMainSpecDD_Init()
    GuildbookOptionsOffSpecDD_Init()

    --the OnShow event doesnt fire for the first time the options frame is shown? set the values here
    -- these are all xml define widgets - REMOVE at some point?
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, GUILDBOOK_CHARACTER['MainSpec'])
        UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, GUILDBOOK_CHARACTER['OffSpec'])
        GuildbookOptionsMainCharacterNameInputBox:SetText(GUILDBOOK_CHARACTER['MainCharacter'])
        GuildbookOptionsMainSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['MainSpecIsPvP'])
        GuildbookOptionsOffSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['OffSpecIsPvP'])
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
        if GUILDBOOK_GLOBAL['Debug'] == true then
            Guildbook.DebugFrame:Show()
        else
            Guildbook.DebugFrame:Hide()
        end
        GuildbookOptionsShowMinimapButton:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])

        if GUILDBOOK_CHARACTER['AttunementsKeys'] then
            GuildbookOptionsAttunementKeysUBRS:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['UBRS'])
            GuildbookOptionsAttunementKeysMC:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['MC'])
            GuildbookOptionsAttunementKeysONY:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['ONY'])
            GuildbookOptionsAttunementKeysBWL:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['BWL'])
            GuildbookOptionsAttunementKeysNAXX:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['NAXX'])
        end
    end

    -- allow time for loading and whats nots, then send character data
    C_Timer.After(2, function()
        --Guildbook:SendCharacterStats()
        Guildbook:CharacterStats_OnChanged()
    end)

    Guildbook:CleanUpGuildRosterData(Guildbook:GetGuildName(), 'checking guild data...[1]')
    C_Timer.After(3, function()
        Guildbook:CleanUpGuildRosterData(Guildbook:GetGuildName(), 'checking guild data...[2]')
    end)

    -- set up delays for calendar data syncing to prevent mass chat spam on log in
    C_Timer.After(5, function()
        Guildbook:SendGuildCalendarEvents()
    end)
    C_Timer.After(10, function()
        Guildbook:SendGuildCalendarDeletedEvents()
    end)
    C_Timer.After(15, function()
        Guildbook:RequestGuildCalendarEvents()
    end)
    C_Timer.After(20, function()
        Guildbook:RequestGuildCalendarDeletedEvents()
    end)

end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:GetGuildName()
    local guildName = false
    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        return guildName
    end
end

function Guildbook:ScanCharacterContainers()
    if BankFrame:IsVisible() then
        local guid = UnitGUID('player')
        if not self.PlayerMixin then
            self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            self.PlayerMixin:SetGUID(guid)
        end
        if self.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(self.PlayerMixin)

            if not GUILDBOOK_CHARACTER['GuildBank'] then
                GUILDBOOK_CHARACTER['GuildBank'] = {
                    [name] = {
                        Data = {},
                        Commit = GetServerTime()
                    }
                }
            else
                GUILDBOOK_CHARACTER['GuildBank'][name] = {
                    Commit = GetServerTime(),
                    Data = {},
                }
            end

            -- player bags
            for bag = 0, 4 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local id = select(10, GetContainerItemInfo(bag, slot))
                    local count = select(2, GetContainerItemInfo(bag, slot))
                    if id and count then
                        if not GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] then
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = count
                        else
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] + count
                        end
                    end
                end
            end

            -- main bank
            for slot = 1, 28 do
                local id = select(10, GetContainerItemInfo(-1, slot))
                local count = select(2, GetContainerItemInfo(-1, slot))
                if id and count then
                    if not GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] then
                        GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = count
                    else
                        GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] + count
                    end
                end
            end

            -- bank bags
            for bag = 5, 11 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local id = select(10, GetContainerItemInfo(bag, slot))
                    local count = select(2, GetContainerItemInfo(bag, slot))
                    if id and count then
                        if not GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] then
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = count
                        else
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] + count
                        end
                    end
                end
            end

            local bankUpdate = {
                type = 'GUILD_BANK_DATA_RESPONSE',
                payload = {
                    Data = GUILDBOOK_CHARACTER['GuildBank'][name].Data,
                    Commit = GUILDBOOK_CHARACTER['GuildBank'][name].Commit,
                    Bank = name,
                }
            }
            self:Transmit(bankUpdate, 'GUILD', sender, 'BULK')
            DEBUG(GetServerTime(), 'ScanCharacterContainers', 'sending guild bank data due to new commit')
        end
    end
end

function Guildbook:ScanTradeSkill()
    local prof = GetTradeSkillLine()
    GUILDBOOK_CHARACTER[prof] = {}
    for i = 1, GetNumTradeSkills() do
        local name, type, _, _, _, _ = GetTradeSkillInfo(i)
        if (name and type ~= "header") then
            local itemLink = GetTradeSkillItemLink(i)
            local itemID = select(1, GetItemInfoInstant(itemLink))
            local itemName = select(1, GetItemInfo(itemID))
            DEBUG(GetServerTime(), 'ScanTradeSkill', string.format('|cff0070DETrade item|r: %s, with ID: %s', name, itemID))
            if itemName and itemID then
                GUILDBOOK_CHARACTER[prof][itemID] = {}
            end
            local numReagents = GetTradeSkillNumReagents(i);
            if numReagents > 0 then
                for j = 1, numReagents, 1 do
                    local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(i, j)
                    local reagentLink = GetTradeSkillReagentItemLink(i, j)
                    local reagentID = select(1, GetItemInfoInstant(reagentLink))
                    if reagentName and reagentID and reagentCount then
                        DEBUG(GetServerTime(), 'ScanTradeSkill', string.format('    Reagent name: %s, with ID: %s, Needed: %s', reagentName, reagentID, reagentCount))
                        GUILDBOOK_CHARACTER[prof][itemID][reagentID] = reagentCount
                    end
                end
            end
        end
    end
end

function Guildbook:ScanCraftSkills_Enchanting()
    local currentCraftingWindow = GetCraftSkillLine(1)
    if currentCraftingWindow == 'Enchanting' then
        GUILDBOOK_CHARACTER['Enchanting'] = {}
        for i = 1, GetNumCrafts() do
            local name, _, type, _, _, _, _ = GetCraftInfo(i)
            if (name and type ~= "header") then
                local itemID = select(7, GetSpellInfo(name))
                DEBUG(GetServerTime(), 'ScanTradeSkill_Enchanting', string.format('|cff0070DETrade item|r: %s, with ID: %s', name, itemID))
                if itemID then
                    GUILDBOOK_CHARACTER['Enchanting'][itemID] = {}
                end
                local numReagents = GetCraftNumReagents(i);
                DEBUG(GetServerTime(), 'ScanTradeSkill_Enchanting', string.format('this recipe has %s reagents', numReagents))
                if numReagents > 0 then
                    for j = 1, numReagents do
                        local reagentName, reagentTexture, reagentCount, playerReagentCount = GetCraftReagentInfo(i, j)
                        local reagentLink = GetCraftReagentItemLink(i, j)
                        if reagentName and reagentCount then
                            DEBUG(GetServerTime(), 'ScanTradeSkill_Enchanting', string.format('reagent number: %s with name %s and count %s', j, reagentName, reagentCount))
                            if reagentLink then
                                local reagentID = select(1, GetItemInfoInstant(reagentLink))
                                DEBUG(GetServerTime(), 'Enchanting', 'reagent id: '..reagentID)
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


--- scan the characters current guild cache and check for any characters with name/class/spec data not matching guid data
function Guildbook:CleanUpGuildRosterData(guild, msg)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guild] then
        print(string.format('%s Guildbook|r, %s', Guildbook.FONT_COLOUR, msg))
        local currentGUIDs = {}
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            currentGUIDs[guid] = true
        end
        for guid, info in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
            if not currentGUIDs[guid] then
                GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] = nil
                print(string.format('removed %s from roster cache', info.Name))
            else
                if not self.PlayerMixin then
                    self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                else
                    self.PlayerMixin:SetGUID(guid)
                end
                if self.PlayerMixin:IsValid() then
                    local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
                    local name = C_PlayerInfo.GetName(self.PlayerMixin)
                    -- local raceId = C_PlayerInfo.GetRace(self.PlayerMixin)
                    -- if raceId then
                    --     local raceName = C_CreatureInfo.GetRaceInfo(raceId).clientFileString
                    --     if info.Race ~= raceName:upper() then
                    --         info.Race = raceName:upper()
                    --         print(name..'has error with race, updating race to mixin value')
                    --     end
                    -- end
                    -- info.Race = nil
                    if name and class then
                        if info.Class ~= class then
                            print(name..' has error with class, updating class to mixin value')
                            info.Class = class
                        end
                        if info.Name ~= name then
                            print(info.Name..' has error with name, updating name to mixin value')
                            info.Name = name
                            --print(info.Name, name)
                        end
                        local ms = false
                        if info.MainSpec ~= '-' then
                            for _, spec in pairs(Guildbook.Data.Class[class].Specializations) do
                                if info.MainSpec == spec then
                                    ms = true
                                end
                            end
                        elseif info.MainSpec == '-' then
                            ms = true
                        end
                        if ms == false then
                            print(name..' has error with main spec, setting to default')
                            info.MainSpec = '-'
                        end
                        local os = false
                        if info.OffSpec ~= '-' then
                            for _, spec in pairs(Guildbook.Data.Class[class].Specializations) do
                                if info.OffSpec == spec then
                                    os = true
                                end
                            end
                        elseif info.OffSpec == '-' then
                            os = true
                        end
                        if os == false then
                            print(name..' has error with off spec, setting to default')
                            info.OffSpec = '-'
                        end
    
                    end
                end
            end
        end
    end
end

function Guildbook:CleanUpCharacterSettings()
    if GUILDBOOK_CHARACTER then
        if GUILDBOOK_CHARACTER['UNKNOWN'] then
            GUILDBOOK_CHARACTER['UNKNOWN'] = nil
        end
    end
end

function Guildbook.GetProfessionData()
    local myCharacter = { Fishing = 0, Cooking = 0, FirstAid = 0, Prof1 = '-', Prof1Level = 0, Prof2 = '-', Prof2Level = 0 }
    for s = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)
        if Guildbook.GetEnglish[locale][skill] == 'Fishing' then 
            myCharacter.Fishing = level
        elseif Guildbook.GetEnglish[locale][skill] == 'Cooking' then
            myCharacter.Cooking = level
        elseif Guildbook.GetEnglish[locale][skill] == 'First Aid' then
            myCharacter.FirstAid = level
        else
            for k, prof in pairs(Guildbook.Data.Profession) do
                if prof.Name == Guildbook.GetEnglish[locale][skill] then
                    if myCharacter.Prof1 == '-' then
                        myCharacter.Prof1 = Guildbook.GetEnglish[locale][skill]
                        myCharacter.Prof1Level = level
                    elseif myCharacter.Prof2 == '-' then
                        myCharacter.Prof2 = Guildbook.GetEnglish[locale][skill]
                        myCharacter.Prof2Level = level
                    end
                end
            end
        end
    end
    if GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER['Profession1'] = myCharacter.Prof1
        GUILDBOOK_CHARACTER['Profession1Level'] = myCharacter.Prof1Level
        GUILDBOOK_CHARACTER['Profession2'] = myCharacter.Prof2
        GUILDBOOK_CHARACTER['Profession2Level'] = myCharacter.Prof2Level
    end
end

--- talent scanning for tbc new feature
function Guildbook:GetTalentInfo()
    local talents = {}
    for tabIndex = 1, GetNumTalentTabs() do
        local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
            table.insert(talents, {
                Tab = tabIndex,
                Row = row,
                Col = column,
                Rank = rank,
                MxRnk = maxRank,
                Icon = iconTexture,
                Name = name,
            })
            --print(string.format("Tab %s [%s] > TalentIndex %s > name=%s, icon=%s, tier=%s, column=%s, rank=%s, maxRank=%s", spec, fileName, talentIndex, name, iconTexture, tier, column, rank, maxRank))
        end
    end
    return talents
end


function Guildbook.GetInstanceInfo()
    local t = {}
    if GetNumSavedInstances() > 0 then
        for i = 1, GetNumSavedInstances() do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
            tinsert(t, { Name = name, ID = id, Resets = date('*t', tonumber(GetTime() + reset)) })
        end
    end
    return t
end

function Guildbook.GetItemLevel()
    local character, itemlevel, itemCount = {}, 0, 0
	for k, slot in ipairs(Guildbook.Data.InventorySlots) do
		character[slot.Name] = GetInventoryItemID('player', slot.Id)
		if character[slot.Name] ~= nil then
			local iName, iLink, iRarety, ilvl = GetItemInfo(character[slot.Name])
			itemlevel = itemlevel + ilvl
			itemCount = itemCount + 1
		end
	end	
	return math.floor(itemlevel/itemCount)
end

function Guildbook:IsGuildMemberOnline(info)
    local guildName = Guildbook:GetGuildName()
    if guildName then
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            if isOnline and info == guid then
                return true
            end
        end
    end
end

function Guildbook:Transmit(data, channel, target, priority)
    local serialized = LibSerialize:Serialize(data);
    local compressed = LibDeflate:CompressDeflate(serialized);
    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    self:SendCommMessage(addonName, encoded, channel, target, priority);
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


function Guildbook:UpdateListviewSelectedTextures(listview)
    for k, button in ipairs(listview) do
        if button.data and button.data.Selected == true then
            button:GetHighlightTexture():SetVertexColor(1, 1, 0);
            button:LockHighlight()
        else
            button:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8);
            button:UnlockHighlight();
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- talent comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendTalentInfoRequest(target, spec)
    local request = {
        type = "TALENT_INFO_REQUEST",
        payload = spec, -- dual spec future feature
    }
    self:Transmit(request, "WHISPER", target, "NORMAL")
    DEBUG(GetServerTime(), 'SendTalentInfoRequest', string.format('sent request for talents from %s', target))
end

function Guildbook:OnTalentInfoRequest(request, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    local talents = Guildbook:GetTalentInfo()
    local response = {
        type = "TALENT_INFO_RESPONSE",
        payload = talents,
    }
    self:Transmit(response, distribution, sender, "BULK")
    DEBUG(GetServerTime(), 'OnTalentInfoRequest', string.format('sending talents data to %s', sender))
end

function Guildbook:OnTalentInfoReceived(data, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    if type(data.payload) == 'table' then
        self.GuildFrame.ProfilesFrame:LoadCharacterTalents(data.payload)
    end
    DEBUG(GetServerTime(), 'OnTalentInfoReceived', string.format("received talent data from %s", sender))
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
    DEBUG(GetServerTime(), 'SendTradeSkillsRequest', string.format('sent request for %s from %s', profession, target))
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
        self:Transmit(response, distribution, sender, "BULK")
        DEBUG(GetServerTime(), 'OnTradeSkillsRequested', string.format('sending %s data to %s', request.payload, sender))
    end
end

function Guildbook:OnTradeSkillsReceived(data, distribution, sender)
    if data.payload.profession and type(data.payload.recipes) == 'table' then
        C_Timer.After(3.0, function()
            local guildName = Guildbook:GetGuildName()
            if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
                for guid, character in pairs(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName]) do
                    if character.Name == sender then                
                        character[data.payload.profession] = data.payload.recipes
                        DEBUG(GetServerTime(), 'OnTradeSkillsReceived', 'set: '..character.Name..' prof: '..data.payload.profession)
                    end
                end
            end
            --self.GuildFrame.TradeSkillFrame.RecipesTable = data.payload.recipes
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

-- limited to once per minute to reduce chat spam
local characterStatsLastSent = -math.huge
function Guildbook:CharacterStats_OnChanged()
    if characterStatsLastSent + 60.0 < GetTime() then
        local d = self:GetCharacterDataPayload()
        if type(d) == 'table' and d.payload.GUID then
            self:Transmit(d, 'GUILD', sender, 'NORMAL')
            DEBUG(GetServerTime(), 'CharacterStats_OnChanged', 'sending character stats on guild channel')
        end
        characterStatsLastSent = GetTime()
    else
        DEBUG(GetServerTime(), 'CharacterStats_OnChanged', tostring(string.format('character stats not sent, %s before next transmition', (characterStatsLastSent + 60.0 - GetTime()))))
    end
end

function Guildbook:GetCharacterDataPayload()
    local guid = UnitGUID('player')
    local level = UnitLevel('player')
    local ilvl = self:GetItemLevel()
    self.GetProfessionData()
    if not self.PlayerMixin then
        self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        self.PlayerMixin:SetGUID(guid)
    end
    if self.PlayerMixin:IsValid() then
        local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
        local name = C_PlayerInfo.GetName(self.PlayerMixin)
        local response = {
            type = 'CHARACTER_DATA_RESPONSE',
            payload = {
                GUID = guid,
                Level = level,
                ItemLevel = ilvl,
                Class = class,
                Name = name,
                Profession1Level = GUILDBOOK_CHARACTER["Profession1Level"],
                OffSpec = GUILDBOOK_CHARACTER["OffSpec"],
                Profession1 = GUILDBOOK_CHARACTER["Profession1"],
                MainCharacter = GUILDBOOK_CHARACTER["MainCharacter"],
                MainSpec = GUILDBOOK_CHARACTER["MainSpec"],
                MainSpecIsPvP = GUILDBOOK_CHARACTER["MainSpecIsPvP"],
                Profession2Level = GUILDBOOK_CHARACTER["Profession2Level"],
                Profession2 = GUILDBOOK_CHARACTER["Profession2"],
                AttunementsKeys = GUILDBOOK_CHARACTER["AttunementsKeys"],
                Availability = GUILDBOOK_CHARACTER["Availability"],
                OffSpecIsPvP = GUILDBOOK_CHARACTER["OffSpecIsPvP"],
            }
        }
        return response
    end
end

function Guildbook:OnCharacterDataRequested(request, distribution, sender)
    if distribution ~= 'WHISPER' then
        return
    end
    local d = self:GetCharacterDataPayload()
    if type(d) == 'table' and d.payload.GUID then
        self:Transmit(d, 'WHISPER', sender, 'NORMAL')
        DEBUG(GetServerTime(), 'OnCharacterDataRequested', 'WHISPER='..sender)
    end
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
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Level = tonumber(data.payload.Level)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].ItemLevel = tonumber(data.payload.ItemLevel)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Class = data.payload.Class
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Name = data.payload.Name
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession1Level = tonumber(data.payload.Profession1Level)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].OffSpec = data.payload.OffSpec
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession1 = data.payload.Profession1
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].MainCharacter = data.payload.MainCharacter
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].MainSpec = data.payload.MainSpec
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].MainSpecIsPvP = data.payload.MainSpecIsPvP
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession2Level = tonumber(data.payload.Profession2Level)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession2 = data.payload.Profession2
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].AttunementsKeys = data.payload.AttunementsKeys
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Availability = data.payload.Availability
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].OffSpecIsPvP = data.payload.OffSpecIsPvP
        DEBUG(GetServerTime(), 'OnCharacterDataReceived', string.format('OnCharacterDataReceived > sender=%s', data.payload.Name))
        C_Timer.After(1, function()
            Guildbook:UpdateGuildMemberDetailFrame(data.payload.GUID)
        end)        
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendGuildBankCommitRequest(bankCharacter)
    local request = {
        type = 'GUILD_BANK_COMMIT_REQUEST',
        payload = bankCharacter,
    }
    self:Transmit(request, 'GUILD', nil, 'NORMAL')
    DEBUG(GetServerTime(), 'SendGuildBankCommitRequest', string.format('SendGuildBankCommitRequest > character=%s', bankCharacter))
end

function Guildbook:OnGuildBankCommitRequested(data, distribution, sender)
    if distribution == 'GUILD' then
        if GUILDBOOK_CHARACTER['GuildBank'] and GUILDBOOK_CHARACTER['GuildBank'][data.payload] and GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit then
            local response = {
                type = 'GUILD_BANK_COMMIT_RESPONSE',
                payload = { 
                    Commit = GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit,
                    Character = data.payload
                }
            }
            self:Transmit(response, 'WHISPER', sender, 'NORMAL')
            DEBUG(GetServerTime(), 'OnGuildBankCommitRequested', string.format('character=%s, commit=%s', data.payload, GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit))
        end
    end
end

function Guildbook:OnGuildBankCommitReceived(data, distribution, sender)
    if distribution == 'WHISPER' then
        DEBUG(GetServerTime(), 'OnGuildBankCommitReceived', string.format('Received a commit for bank character %s from %s - commit time: %s', data.payload.Character, sender, data.payload.Commit))
        if Guildbook.GuildBankCommit['Commit'] == nil then
            Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
            Guildbook.GuildBankCommit['Character'] = sender
            Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
            DEBUG(GetServerTime(), 'OnGuildBankCommitReceived', string.format('First response added to temp table, %s->%s', sender, data.payload.Commit))
        else
            if tonumber(data.payload.Commit) > tonumber(Guildbook.GuildBankCommit['Commit']) then
                Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
                Guildbook.GuildBankCommit['Character'] = sender
                Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
                DEBUG(GetServerTime(), 'OnGuildBankCommitReceived', string.format('Response commit is newer than temp table commit, updating info - %s->%s', sender, data.payload.Commit))
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
        DEBUG(GetServerTime(), 'SendGuildBankDataRequest', string.format('Sending request for guild bank data to %s for bank character %s', Guildbook.GuildBankCommit['Character'], Guildbook.GuildBankCommit['BankCharacter']))
    end
end

function Guildbook:OnGuildBankDataRequested(data, distribution, sender)
    if distribution == 'WHISPER' then
        local response = {
            type = 'GUILD_BANK_DATA_RESPONSE',
            payload = {
                Data = GUILDBOOK_CHARACTER['GuildBank'][data.payload].Data,
                Commit = GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit,
                Bank = data.payload,
            }
        }
        self:Transmit(response, 'WHISPER', sender, 'BULK')
        DEBUG(GetServerTime(), 'OnGuildBankDataRequested', 'Sending guild bank data to: '..sender..' as requested')
    end
end

function Guildbook:OnGuildBankDataReceived(data, distribution, sender)
    if distribution == 'WHISPER' or distribution == 'GUILD' then
        if not GUILDBOOK_CHARACTER['GuildBank'] then
            GUILDBOOK_CHARACTER['GuildBank'] = {
                [data.payload.Bank] = {
                    Commit = data.payload.Commit,
                    Data = data.payload.Data,
                }
            }
        else
            GUILDBOOK_CHARACTER['GuildBank'][data.payload.Bank] = {
                Commit = data.payload.Commit,
                Data = data.payload.Data,
            }
        end
    end
    --self.GuildFrame.GuildBankFrame:ProcessBankData(data.payload.Data)
    --self.GuildFrame.GuildBankFrame:RefreshSlots()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- calendar data comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local calDelay = 120.0

function Guildbook:RequestGuildCalendarDeletedEvents(event)
    local calendarEvents = {
        type = 'GUILD_CALENDAR_EVENTS_DELETED_REQUESTED',
        payload = '-',
    }
    self:Transmit(calendarEvents, 'GUILD', nil, 'NORMAL')
    DEBUG(GetServerTime(), 'RequestGuildCalendarDeletedEvents', 'Sending calendar events deleted request')
end

function Guildbook:RequestGuildCalendarEvents(event)
    local calendarEventsDeleted = {
        type = 'GUILD_CALENDAR_EVENTS_REQUESTED',
        payload = '-',
    }
    self:Transmit(calendarEventsDeleted, 'GUILD', nil, 'NORMAL')
    DEBUG(GetServerTime(), 'RequestGuildCalendarEvents', 'Sending calendar events request')
end

function Guildbook:SendGuildCalendarEvent(event)
    local calendarEvent = {
        type = 'GUILD_CALENDAR_EVENT_CREATED',
        payload = event,
    }
    self:Transmit(calendarEvent, 'GUILD', nil, 'NORMAL')
    DEBUG(GetServerTime(), 'SendGuildCalendarEvent', string.format('Sending calendar event to guild, event title: %s', event.title))
end

function Guildbook:OnGuildCalendarEventCreated(data, distribution, sender)
    DEBUG(GetServerTime(), 'OnGuildCalendarEventCreated', string.format('Received a calendar event created from %s', sender))
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
            if event.created == data.payload.created then
                exists = true
                DEBUG(GetServerTime(), 'OnGuildCalendarEventCreated', 'this event already exists in your db')
            end
        end
        if exists == false then
            table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], data.payload)
            DEBUG(GetServerTime(), 'OnGuildCalendarEventCreated', string.format('Received guild calendar event, title: %s', data.payload.title))
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
    DEBUG(GetServerTime(), 'SendGuildCalendarEventAttend', string.format('Sending calendar event attend update to guild, event title: %s, attend: %s', event.title, attend))
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
                DEBUG(GetServerTime(), 'OnGuildCalendarEventAttendReceived', string.format('Updated event: %s attend, data from %s, attend: %s', v.title, sender, data.payload.a))
            end
        end
    end
    C_Timer.After(1, function()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateAttending()
    end)
end

function Guildbook:SendGuildCalendarEventDeleted(event)
    local calendarEventDeleted = {
        type = 'GUILD_CALENDAR_EVENT_DELETED',
        payload = event,
    }
    self:Transmit(calendarEventDeleted, 'GUILD', nil, 'NORMAL')
    DEBUG(GetServerTime(), 'SendGuildCalendarEventDeleted', string.format('Sending calendar event deleted to guild, event title: %s', event.title))
end

function Guildbook:OnGuildCalendarEventDeleted(data, distribution, sender)
    self.GuildFrame.GuildCalendarFrame.EventFrame:RegisterEventDeleted(data.payload)
    DEBUG(GetServerTime(), 'OnGuildCalendarEventDeleted', 'event='..data.payload.title)
    C_Timer.After(1, function()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
    end)
end


-- this will be restricted to only send events that fall within a month, this should reduce chat spam
-- it is further restricted to send not within 2 minutes of previous send
function Guildbook:SendGuildCalendarEvents()
    local today = date('*t')
    local future = date('*t', (time(today) + (60*60*24*28)))
    local events = {}
    if GetServerTime() > GUILDBOOK_GLOBAL['LastCalendarTransmit'] + 120.0 then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
            for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if event.date.month >= today.month and event.date.year >= today.year and event.date.month <= future.month and event.date.year <= future.year then
                    table.insert(events, event)
                    --DEBUG(GetServerTime(), ' ', string.format('Added event: %s to this months sending table', event.title))
                end
            end
            local calendarEvents = {
                type = 'GUILD_CALENDAR_EVENTS',
                payload = events,
            }
            self:Transmit(calendarEvents, 'GUILD', nil, 'BULK')
            DEBUG(GetServerTime(), 'SendGuildCalendarEvents', string.format('range=%s-%s-%s to %s-%s-%s', today.day, today.month, today.year, future.day, future.month, future.year))
        end
        GUILDBOOK_GLOBAL['LastCalendarTransmit'] = GetServerTime()
    end
end

function Guildbook:OnGuildCalendarEventsReceived(data, distribution, sender)
    DEBUG(GetServerTime(), 'OnGuildCalendarEventsReceived', string.format('Received calendar events from %s', sender))
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for k, event in ipairs(data.payload) do
            DEBUG(GetServerTime(), 'OnGuildCalendarEventsReceived', string.format('Scanning events received, event: %s', event.title))
            local exists = false
            for _, e in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if e.created == event.created and e.owner == event.owner then
                    exists = true
                    DEBUG(GetServerTime(), 'OnGuildCalendarEventsReceived', '    event exists!')

                    -- check and update attend
                    for guid, info in pairs(e.attend) do
                        if tonumber(info.Updated) < event.attend[guid].Updated then
                            info.Status = event.attend[guid].Status
                            info.Updated = event.attend[guid].Updated
                            DEBUG(GetServerTime(), 'OnGuildCalendarEventsReceived', 'Updated attend status for event: '..event.title)
                        end
                    end
                end
            end
            if exists == false then
                table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], event)
                DEBUG(GetServerTime(), 'OnGuildCalendarEventsReceived', string.format('This event is a new event, adding to db: %s', event.title))
            end
        end
    end
end

function Guildbook:SendGuildCalendarDeletedEvents()
    DEBUG(GetServerTime(), 'SendGuildCalendarDeletedEvents', 'Sending calendar deleted events')
    if GetServerTime() > GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] + 120.0 then
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
            local calendarDeletedEvents = {
                type = 'GUILD_CALENDAR_DELETED_EVENTS',
                payload = GUILDBOOK_GLOBAL['CalendarDeleted'][guildName],
            }
            self:Transmit(calendarDeletedEvents, 'GUILD', nil, 'BULK')
            DEBUG(GetServerTime(), 'SendGuildCalendarDeletedEvents', 'Sending deleted calendar events to guild')
        end
        GUILDBOOK_GLOBAL['LastCalendarDeletedTransmit'] = GetServerTime()
    end
end


function Guildbook:OnGuildCalendarEventsDeleted(data, distribution, sender)
    DEBUG(GetServerTime(), 'OnGuildCalendarEventsDeleted', string.format('Received calendar events deleted from %s', sender))
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
        for k, v in pairs(data.payload) do
            if not GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] then
                GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][k] = true
                DEBUG(GetServerTime(), 'OnGuildCalendarEventsDeleted', 'Added event to deleted table')
            end
        end
    end
    self.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
end

-- TODO: add script for when a player drops a prof
SkillDetailStatusBarUnlearnButton:HookScript('OnClick', function()

end)


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- soft reserve
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:RequestRaidSoftReserves()
    local request = {
        type = 'RAID_SOFT_RESERVES_REQUEST',
    }
    self:Transmit(request, 'RAID', nil, 'NORMAL')
    DEBUG(GetServerTime(), 'RequestRaidSoftReserves', 'Sent a request on RAID channel for soft reserves')
end

function Guildbook:OnRaidSoftReserveRequested(data, distribution, sender)
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER['SoftReserve'] then
        local response = {
            type = 'RAID_SOFT_RESERVE_RESPONSE',
            payload = GUILDBOOK_CHARACTER['SoftReserve'],
        }
        self:Transmit(response, 'RAID', nil, 'NORMAL')
        DEBUG(GetServerTime(), 'OnRaidSoftReserveRequested', 'Soft reserve response sent')
    end
end

function Guildbook:OnRaidSoftReserveReceived(data, distribution, sender)
    DEBUG(GetServerTime(), 'OnRaidSoftReserveReceived', 'Soft reserve response receieved from: '..sender)
    if self.GuildFrame.SoftReserveFrame.SelectedRaid ~= nil then
        if data.payload and data.payload[self.GuildFrame.SoftReserveFrame.SelectedRaid] then
            DEBUG(GetServerTime(), 'OnRaidSoftReserveReceived', string.format('%s has a soft reserved %s for %s', sender, data.payload[self.GuildFrame.SoftReserveFrame.SelectedRaid], self.GuildFrame.SoftReserveFrame.SelectedRaid))
            for i = 1, 40 do
                name, _, _, level, class, fileName, _, online, _, role, isML, _ = GetRaidRosterInfo(i)
                -- this may not be quite right check for realms (name-realm)
                if name and (name == sender) then
                    self.GuildFrame.SoftReserveFrame.RaidRosterList[i].data = {
                        Character = name,
                        ItemID = tonumber(data.payload[self.GuildFrame.SoftReserveFrame.SelectedRaid]),
                        Class = fileName,
                    }
                    self.GuildFrame.SoftReserveFrame.RaidRosterList[i]:Show()
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- events
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:ADDON_LOADED(...)
    if tostring(...):lower() == addonName:lower() then
        self:Init()
    end
end

function Guildbook:TRADE_SKILL_UPDATE()
    C_Timer.After(1, function()
        DEBUG(GetServerTime(), 'TRADE_SKILL_UPDATE', 'scanning skills')
        self:ScanTradeSkill()
    end)
end

function Guildbook:CRAFT_UPDATE()
    C_Timer.After(1, function()
        DEBUG(GetServerTime(), 'CRAFT_UPDATE', 'scanning skills enchanting')
        self:ScanCraftSkills_Enchanting()
    end)
end

function Guildbook:PLAYER_ENTERING_WORLD()
    self:ModBlizzUI()
    self:SetupStatsFrame()
    --self:SetupTradeSkillFrame()
    --self:SetupGuildBankFrame()
    self:SetupGuildCalendarFrame()
    self:SetupGuildMemberDetailframe()
    --self:SetupSoftReserveFrame()
    self:SetupProfilesFrame()
    self.EventFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')
end

function Guildbook:RAID_ROSTER_UPDATE()
    DEBUG(GetServerTime(), 'RAID_ROSTER_UPDATE', 'Raid roster update event')
    --self:RequestRaidSoftReserves()
end


function Guildbook:GUILD_ROSTER_UPDATE(...)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] then
        local guildName = Guildbook:GetGuildName()
        if guildName then
            if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
                GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] = {}
            end
            local totalMembers, onlineMembers, _ = GetNumGuildMembers()
            for i = 1, totalMembers do
                local name, _, _, level, _, _, _, _, _, _, class, _, _, _, _, _, guid = GetGuildRosterInfo(i)
                if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
                    GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] = {
                        ['MainSpec'] = '-',
                        ['OffSpec'] = '-',
                        ['MainSpecIsPvP'] = false,
                        ['OffSpecIsPvP'] = false,
                        ['Profession1'] = '-',
                        ['Profession1Level'] = 0,
                        ['Profession2'] = '-',
                        ['Profession2Level'] = 0,
                        ['MainCharacter'] = '-',
                    }
                    GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid].Name = name
                    GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid].Level = level
                    GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid].Class = class
                end
            end
            -- Guildbook:CleanUpGuildRosterData(guildName, 'checking guild data...[1]')
            -- C_Timer.After(3, function()
            --     Guildbook:CleanUpGuildRosterData(guildName, 'checking guild data...[2]')
            -- end)
        end
    end
end

function Guildbook:PLAYER_LEVEL_UP()
    C_Timer.After(3, function()
        Guildbook:CharacterStats_OnChanged()
    end)
end

function Guildbook:SKILL_LINES_CHANGED()
    C_Timer.After(3, function()
        Guildbook:CharacterStats_OnChanged()
    end)
end

-- added to automate the guildl bank scan
function Guildbook:BANKFRAME_OPENED()
    for i = 1, GetNumGuildMembers() do
        local _, _, _, _, _, _, publicNote, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if publicNote:lower():find('guildbank') and GUID == UnitGUID('player') then
            self:ScanCharacterContainers()
        end
    end
end

--- handle comms
-- create a 10 sec period between request responses to reduce chat spam
local tradeDelay, bankDelay = 30, 10
local tradeDelayRequestQueued = false
local lastTradeSkillRequest = {}
local lastGuildBankRequest = {}
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


    if data.type == "TRADESKILLS_REQUEST" then
        if not lastTradeSkillRequest[sender] then
            lastTradeSkillRequest[sender] = -math.huge
        end
        if lastTradeSkillRequest[sender] + tradeDelay < GetTime() then
            self:OnTradeSkillsRequested(data, distribution, sender)
            lastTradeSkillRequest[sender] = GetTime()
        else
            local remaining = string.format("%.1d", (lastTradeSkillRequest[sender] + tradeDelay - GetTime()))
            print(string.format('Guildbook: profession requested within 30s, this request has been queued and will be sent in %s seconds', remaining))
            if tradeDelayRequestQueued == false then
                C_Timer.After((lastTradeSkillRequest[sender] + tradeDelay - GetTime()), function()
                    self:OnTradeSkillsRequested(data, distribution, sender)
                    tradeDelayRequestQueued = false
                end)
                tradeDelayRequestQueued = true
            end
        end

    elseif data.type == "TRADESKILLS_RESPONSE" then
        self:OnTradeSkillsReceived(data, distribution, sender);

    elseif data.type == 'CHARACTER_DATA_REQUEST' then
        self:OnCharacterDataRequested(data, distribution, sender)

    elseif data.type == 'CHARACTER_DATA_RESPONSE' then
        self:OnCharacterDataReceived(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_COMMIT_REQUEST' then
        self:OnGuildBankCommitRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_COMMIT_RESPONSE' then
        self:OnGuildBankCommitReceived(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_REQUEST' then
        if not lastGuildBankRequest[sender] then
            lastGuildBankRequest[sender] = -math.huge
        end
        if lastGuildBankRequest[sender] + bankDelay < GetTime() then
            self:OnGuildBankDataRequested(data, distribution, sender)
            lastGuildBankRequest[sender] = GetTime()
        end

    elseif data.type == 'GUILD_BANK_DATA_RESPONSE' then
        self:OnGuildBankDataReceived(data, distribution, sender)

    elseif data.type == 'RAID_SOFT_RESERVES_REQUEST' then
        self:OnRaidSoftReserveRequested(data, distribution, sender)

    elseif data.type == 'RAID_SOFT_RESERVE_RESPONSE' then
        self:OnRaidSoftReserveReceived(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENT_CREATED' then
        self:OnGuildCalendarEventCreated(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENTS' then
        self:OnGuildCalendarEventsReceived(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENT_DELETED' then
        self:OnGuildCalendarEventDeleted(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_DELETED_EVENTS' then
        self:OnGuildCalendarEventsDeleted(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENT_ATTEND' then
        self:OnGuildCalendarEventAttendReceived(data, distribution, sender)

    elseif data.type == 'GUILD_CALENDAR_EVENTS_REQUESTED' then
        local today = date('*t')
        self:SendGuildCalendarEvents()

    elseif data.type == 'GUILD_CALENDAR_EVENTS_DELETED_REQUESTED' then
        self:SendGuildCalendarDeletedEvents()

    elseif data.type == 'TALENT_INFO_REQUEST' then
        DEBUG(GetServerTime(), 'talent request', 'request from '..sender)
        self:OnTalentInfoRequest(data, distribution, sender)

    elseif data.type == 'TALENT_INFO_RESPONSE' then
        DEBUG(GetServerTime(), 'talent response', 'response from '..sender)
        self:OnTalentInfoReceived(data, distribution, sender)

    end
end


--set up event listener
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('PLAYER_LEVEL_UP')
Guildbook.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
Guildbook.EventFrame:RegisterEvent('SKILL_LINES_CHANGED')
Guildbook.EventFrame:RegisterEvent('TRADE_SKILL_UPDATE')
Guildbook.EventFrame:RegisterEvent('CRAFT_UPDATE')
Guildbook.EventFrame:RegisterEvent('RAID_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_OPENED')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    --DEBUG(GetServerTime(), event, ' ')
    Guildbook[event](Guildbook, ...)
end)