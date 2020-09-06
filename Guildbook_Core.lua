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

local HBD = LibStub("HereBeDragons-2.0")
local Pins = LibStub("HereBeDragons-Pins-2.0")

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--local variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------
local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG
local PRINT = Guildbook.PRINT
local tinsert, tsort = table.insert, table.sort
local ceil, floor = math.ceil, math.floor

--set constants
local FRIENDS_FRAME_WIDTH = FriendsFrame:GetWidth()
local GUILD_FRAME_WIDTH = GuildFrame:GetWidth()
local GUILD_INFO_FRAME_WIDTH = GuildInfoFrame:GetWidth()

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--global variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.PLAYER_RACE = select(2, UnitRace("player")):upper()
Guildbook.PLAYER_CLASS = select(2, UnitClass("player")):upper()
if Guildbook.PLAYER_CLASS == 'DEATH KNIGHT' then
    Guildbook.PLAYER_CLASS = 'DEATHKNIGHT'
end
Guildbook.PLAYER_GENDER = Guildbook.GetGender('player')
Guildbook.PLAYER_NAME = UnitName('player')

Guildbook.FONT_COLOUR = ''
Guildbook.LastTarget = nil

Guildbook.GameTooltip = {
    Item = {},
    ItemKeys = { 'ItemName', 'ItemLink', 'ItemRarity', 'ItemLevel', 'ItemMinLevel', 'ItemType', 'ItemSubType', 'ItemStockCount', 'ItemEquipLocation', 'ItemIcon', 'ItemSellPrice', 'ItemClassID', 'ItemSubClassID', 'ItemBindType' },
}
Guildbook.Bags = {
    PlayerBags = {},
    PlayerKingring ={},
    PlayerBank = {},
}


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDHELPERCLASSIC1 = '/guildbook'
SLASH_GUILDHELPERCLASSIC2 = '/g-k'
SlashCmdList['GUILDHELPERCLASSIC'] = function(msg)
    if msg == '-help' then
        
    elseif msg == '-reset-character' then

    elseif msg == '-test' then
        Guildbook.Bags.ScanPlayerBags()
    elseif msg == '-debug' then
        if GUILDBOOK_GLOBAL then
            GUILDBOOK_GLOBAL['Debug'] = not GUILDBOOK_GLOBAL['Debug']
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook.Init()
    DEBUG('running init')

    --extend the guild info frame to full guild frame height
    GuildInfoFrame:SetPoint('TOPLEFT', GuildFrame, 'TOPRIGHT', 1, 0)
    GuildInfoFrame:SetPoint('BOTTOMLEFT', GuildFrame, 'BOTTOMRIGHT', 1, 0) 

    --extend the player detail frame to full height
    GuildMemberDetailFrame:SetPoint('TOPLEFT', GuildFrame, 'TOPRIGHT', 1, 0)
    GuildMemberDetailFrame:SetPoint('BOTTOMLEFT', GuildFrame, 'BOTTOMRIGHT', 1, 0) 

    --hook functions to the guild list buttons, when changing between member info/status the buttons change so hook on both
    for i = 1, 13 do
        _G['GuildFrameButton'..i]:HookScript('OnClick', function(self, button)
            if (button == 'LeftButton') and (GuildMemberDetailFrame:IsVisible()) then
                Guildbook.GuildMemberDetailFrame:ClearText()
                local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(GetGuildRosterSelection())
                if isOnline then
                    local requestSent = C_ChatInfo.SendAddonMessage('gb-mdf-req', 'requestdata', 'WHISPER', name)
                    if requestSent then
                        DEBUG('sent data request to '..name)
                    end
                end
                Guildbook.GuildMemberDetailFrame:UpdateLabels()
            end
        end)
        _G['GuildFrameGuildStatusButton'..i]:HookScript('OnClick', function(self, button)
            if (button == 'LeftButton') and (GuildMemberDetailFrame:IsVisible()) then
                Guildbook.GuildMemberDetailFrame:ClearText()
                local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(GetGuildRosterSelection())
                if isOnline then
                    local requestSent = C_ChatInfo.SendAddonMessage('gb-mdf-req', 'requestdata', 'WHISPER', name)
                    if requestSent then
                        DEBUG('sent data request to '..name)
                    end
                end
                Guildbook.GuildMemberDetailFrame:UpdateLabels()
            end
        end)
    end

    --create the quest xp fontstring and tooltip
    Guildbook.QuestInfoRewardsFrame_XP = QuestInfoRewardsFrame:CreateFontString('GuildbookQuestInfoRewardsFrame_XP', 'OVERLAY')
    Guildbook.QuestInfoRewardsFrame_XP:SetPoint('BOTTOMRIGHT', -5, 0)
    Guildbook.QuestInfoRewardsFrame_XP:SetTextColor(0,0,0,1)
    Guildbook.QuestInfoRewardsFrame_XP:SetFont("Fonts\\FRIZQT__.TTF", 14)
    for i = 1, 6 do
        _G['QuestLogTitle'..i]:HookScript('OnClick', function() GameTooltip:Hide() Guildbook.GetQuestLogInfo() end)
    end

    --register the addon message prefixes
    local memberDetailFrameRequestPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-mdf-req')
    DEBUG('registered details request prefix: '..tostring(memberDetailFrameRequestPrefix))
    local memberDetailFrameSentPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-mdf-data')
    DEBUG('registered details sent prefix: '..tostring(memberDetailFrameSentPrefix))
    local summaryRequestPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-sum-req')
    DEBUG('registered summary request prefix: '..tostring(summaryRequestPrefix))
    local summarySentPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-sum-data')
    DEBUG('registered summary sent prefix: '..tostring(summarySentPrefix))
    local gatheringData = C_ChatInfo.RegisterAddonMessagePrefix('gb-gat-data')
    DEBUG('registered gathering data prefix: '..tostring(gatheringData))
    local raidRosterDataRequestPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-raid-req')
    DEBUG('registered summary sent prefix: '..tostring(raidRosterDataRequestPrefix))
    local raidRosterSentRequestPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-raid-data')
    DEBUG('registered gathering data prefix: '..tostring(raidRosterSentRequestPrefix))
    local gatheringDatabaseDataPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-gat-db')
    DEBUG('registered gathering data prefix: '..tostring(gatheringDatabaseDataPrefix))

    --drawn the additional labels and text for the guild member detail frame
    Guildbook.GuildMemberDetailFrame:DrawLabels()          
    Guildbook.GuildMemberDetailFrame:DrawText()

    --draw the class bar chart
    Guildbook.SummaryFrame:DrawClassChart()
    Guildbook.SummaryFrame:DrawRoleChart()

    --draw raid frame roster
    Guildbook.RaidRosterFrame:DrawListView()
    Guildbook.RaidRosterFrame:DrawGroups()

    --create stored variable tables
    if GUILDBOOK_GLOBAL == nil then
        GUILDBOOK_GLOBAL = Guildbook.Data.DefaultGlobalSettings
        DEBUG('created global saved variable table')
    else
        DEBUG('global variables exists')
    end
    if GUILDBOOK_CHARACTER == nil then
        GUILDBOOK_CHARACTER = Guildbook.Data.DefaultCharacterSettings
        DEBUG('created character saved variable table')
    else
        DEBUG('character variables exists')
    end
    if GUILDBOOK_GAMEOBJECTS == nil then
        GUILDBOOK_GAMEOBJECTS = {}
        DEBUG('created game object table')
    else
        DEBUG('game object table exists')
    end
    if not GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] then
        GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] = 8.0
    end
    if not GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] then
        GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] = 8.0
    end

    Guildbook.LOADED = true

    Guildbook.FONT_COLOUR = '|cffFF7D0A'

    GameTooltip:HookScript("OnTooltipSetItem", Guildbook.OnTooltipSetItem)
    GameTooltip:HookScript("OnTooltipCleared", Guildbook.OnTooltipCleared)

    local ldb = LibStub("LibDataBroker-1.1")
    Guildbook.MinimapButton = ldb:NewDataObject('GuildbookMinimapIcon', {
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
                ToggleDropDownMenu(1, nil, Guildbook.MinimapGatheringMenu, "cursor", 3, -3, nil, nil, 2) --add this somewhere else ?
                Guildbook.Gathering.UpdateMapGatheringIcons()
                Guildbook.Gathering.UpdateWorldMapGatheringIcons()
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(tostring(Guildbook.FONT_COLOUR..addonName))
            tooltip:AddDoubleLine('|cffffffffLeft Click|r Open options menu')
            tooltip:AddDoubleLine('|cffffffffRight Click|r Toggle gathering map menu')
        end,
    })
    Guildbook.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    Guildbook.MinimapIcon:Register('GuildbookMinimapIcon', Guildbook.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])
    if GUILDBOOK_GLOBAL['ShowMinimapButton'] == false then
        Guildbook.MinimapIcon:Hide('GuildbookMinimapIcon')
    end

    --minimap game object context menu
    Guildbook.MinimapGatheringMenu = CreateFrame("Frame", "GuildbookMinimapGatheringMenu", UIParent, "UIDropDownMenuTemplate")
    --hook a function to update world maps when player changes zone viewed - events are slow to update map ID
    WorldMapFrame.ScrollContainer:HookScript('OnMouseUp', function(self)
        Guildbook.Gathering.UpdateWorldMapGatheringIcons(WorldMapFrame:GetMapID()) 
    end)
    WorldMapFrame:HookScript('OnShow', function(self)
        Guildbook.Gathering.UpdateWorldMapGatheringIcons(WorldMapFrame:GetMapID()) 
    end)
    WorldMapFrame:HookScript('OnHide', function(self)
        Pins:RemoveAllMinimapIcons("GuildbookGatheringMinimapIcons") 
        Pins:RemoveAllWorldMapIcons("GuildbookGatheringMinimapIcons") 
        Guildbook.Gathering.ClearGatheringIcons()
    end)

    GuildbookOptionsMainSpecDD_Init()
    GuildbookOptionsOffSpecDD_Init()
    GuildbookGameObjectDropDown_Init()

    --the OnShow event doesnt fire for the first time the options frame is shown? set the values here
    UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, GUILDBOOK_CHARACTER['MainSpec'])
    UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, GUILDBOOK_CHARACTER['OffSpec'])
    GuildbookOptionsMainCharacterNameInputBox:SetText(GUILDBOOK_CHARACTER['MainCharacter'])
    GuildbookOptionsMainSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['MainSpecIsPvP'])
    GuildbookOptionsOffSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['OffSpecIsPvP'])
    GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
    GuildbookOptionsShowMinimapButton:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])
    --GuildbookOptionsGatheringDatabaseListViewSendSelectedItemsToGuild:SetText(Guildbook.Data.StatusIconStringsSMALL['Mail'])
    --GuildbookOptionsGatheringDatabaseSendSelectedItemsRecipient:SetText(L['CharacterName'])

    GuildbookOptionsMinimapIconSizeSlider:SetValue(tonumber(GUILDBOOK_CHARACTER['MinimapGatheringIconSize']))
    GuildbookOptionsMinimapIconSizeSlider.tooltipText = 'Minimap icon size'
    GuildbookOptionsMinimapIconSizeSliderText:SetText(string.format("%.0f", tostring(GUILDBOOK_CHARACTER['MinimapGatheringIconSize'])))
    GuildbookOptionsMinimapIconSizeSliderLow:SetText('2');
    GuildbookOptionsMinimapIconSizeSliderHigh:SetText('20')

    GuildbookOptionsWorldmapIconSizeSlider:SetValue(tonumber(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize']))
    GuildbookOptionsWorldmapIconSizeSlider.tooltipText = 'World map icon size'
    GuildbookOptionsWorldmapIconSizeSliderText:SetText(string.format("%.0f", tostring(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'])))
    GuildbookOptionsWorldmapIconSizeSliderLow:SetText('2');
    GuildbookOptionsWorldmapIconSizeSliderHigh:SetText('20')

    if not GUILDBOOK_CHARACTER['TooltipItemData'] then
        GUILDBOOK_CHARACTER['TooltipItemData'] = true
    end
    GuildbookOptionsShowItemInfoTooltipCB:SetChecked(GUILDBOOK_CHARACTER['TooltipItemData'])
    if not GUILDBOOK_CHARACTER['TooltipBankData'] then
        GUILDBOOK_CHARACTER['TooltipBankData'] = true
    end
    GuildbookOptionsShowItemInfoTooltipCB:SetChecked(GUILDBOOK_CHARACTER['TooltipBankData'])

    --GuildbookGuildInfoFrameRaidRosterFrameRosterListViewScrollbar:SetValue(1)

    local version = GetAddOnMetadata(addonName, "Version")

    PRINT(Guildbook.FONT_COLOUR, 'loaded (version '..version..')')


    --gathering database quick fix
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        for k, v in ipairs(GUILDBOOK_GAMEOBJECTS) do
            if string.find(v['ItemName'], ':') then
                DEBUG('found \':\' in item name, removing symbol')
                v['ItemName'] = string.gsub(v['ItemName'],':', '')
            end
            if string.find(v['SourceName'], ':') then
                DEBUG('found \':\' in source name, removing symbol')
                v['ISourceName'] = string.gsub(v['SourceName'],':', '')
            end
        end
    end

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--tooltip extension
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.TooltipLineAdded = false
function Guildbook.OnTooltipSetItem(tooltip, ...)
    local name, link = GameTooltip:GetItem()
    if link then
        for i = 1, 14 do
            Guildbook.GameTooltip.Item[Guildbook.GameTooltip.ItemKeys[i]] = select(i, GetItemInfo(link))
        end
        if not Guildbook.TooltipLineAdded then
            if GUILDBOOK_CHARACTER['TooltipItemData'] == true then
                tooltip:AddLine(' ') --create a line break
                tooltip:AddLine(Guildbook.FONT_COLOUR.."Guildbook:|r")
                if type(Guildbook.GameTooltip.Item['ItemSellPrice']) == 'number' then
                    tooltip:AddDoubleLine('Value', GetCoinTextureString(Guildbook.GameTooltip.Item['ItemSellPrice']), 1, 1, 1, 1, 1, 1)
                end
                tooltip:AddDoubleLine('Type', Guildbook.GameTooltip.Item['ItemType'], 1, 1, 1, 1, 1, 1)
                tooltip:AddDoubleLine('Item Level', Guildbook.GameTooltip.Item['ItemLevel'], 1, 1, 1, 1, 1, 1)
            end
            tooltip:AddLine(' ')
            if GUILDBOOK_CHARACTER['TooltipBankData'] == true then
                if GUILDBOOK_CHARACTER['BankItems'] and next(GUILDBOOK_CHARACTER['BankItems']) then    
                    local itemExists = false            
                    for k, v in ipairs(GUILDBOOK_CHARACTER['BankItems']) do
                        if tonumber(v['ItemID']) == tonumber(Guildbook.GetItemIdFromLink(link)) then
                            tooltip:AddDoubleLine(tostring(Guildbook.FONT_COLOUR.."Bank"), v['Count'], 1,1,1,1,1,1)
                            itemExists = true
                        end
                    end
                    local t = tostring(Guildbook.GetDateFormatted(GUILDBOOK_CHARACTER['BankItemsScanTime'])..'-'..Guildbook.GetTimeFormatted(GUILDBOOK_CHARACTER['BankItemsScanTime']))
                    if itemExists == true then
                        tooltip:AddDoubleLine('Last Scaned:', t, 1,1,1,1,1,1)
                    end
                end
            end
            if LootFrame:IsVisible() then
                Guildbook.Bags.SmartLootScanPlayerBags()
                tooltip:AddLine(Guildbook.FONT_COLOUR..'Lowest value items in bags:')
                for i = 1, GetNumLootItems() do
                    if next(Guildbook.Bags.PlayerBags) and Guildbook.Bags.PlayerBags[i] then
                        tooltip:AddDoubleLine(tostring(i..' '..Guildbook.Bags.PlayerBags[i].Name..', Bag: '..Guildbook.Bags.PlayerBags[i].BagID..', Slot: '..Guildbook.Bags.PlayerBags[i].SlotID), GetCoinTextureString(Guildbook.Bags.PlayerBags[i].SlotValue), 1, 1, 1, 1, 1, 1)
                    end
                end
                tooltip:AddLine(' ')
            end
			Guildbook.TooltipLineAdded = true
		end
    end
end

function Guildbook.OnTooltipCleared(tooltip, ...)
    Guildbook.TooltipLineAdded = false
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--core functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--creates a tooltip when clicking on quests to show xp rewards
function Guildbook.GetQuestLogInfo()
    local questIndex = GetQuestLogSelection()
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questIndex)
    if GUILDBOOK_GLOBAL['QuestRewardsXP'] and GUILDBOOK_GLOBAL['QuestRewardsXP'][tostring(questID)] then
        GameTooltip:SetOwner(QuestLogFrame, "ANCHOR_CURSOR")
        GameTooltip:AddLine(Guildbook.FONT_COLOUR.."Guildbook:|r")
        GameTooltip:AddDoubleLine(title, tostring('XP '..GUILDBOOK_GLOBAL['QuestRewardsXP'][tostring(questID)]), 1, 1, 1, 1, 1, 1)
        GameTooltip:Show()
    else
        GameTooltip:Hide()
    end
end

function Guildbook.Bags.SmartLootScanPlayerBags()
    Guildbook.Bags.PlayerBags = {}
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag,slot)
            if link then
                local id = select(10, GetContainerItemInfo(bag, slot))
                local count = select(2, GetContainerItemInfo(bag, slot))
                local name = select(1, GetItemInfo(link))
                local price = select(11, GetItemInfo(link))
                local rarity = select(3, GetItemInfo(link))
                local iType = select(12, GetItemInfo(link)) -- 0=consumable, 2=weapon, 4=armour, 7=trade goods, 9=recipe, 12=quest
                local iSubType = select(13, GetItemInfo(link)) --does nothing much in classic, keep if tbc or wrath provide sub type data
                if rarity == 1 then
                    if tonumber(iType) == 2 then
                        if (iSubType ~= 14) and (iSubType ~= 20) then --ignore misc & fishing poles
                            --print('added weapon: '..name..' rarity: '..rarity..' sub type: '..iSubType)
                            tinsert(Guildbook.Bags.PlayerBags, { 
                                Name = name, 
                                ItemID = tonumber(id), 
                                SlotValue = tonumber(count * price),
                                BagID = bag,
                                SlotID = slot,
                            })
                        end
                    elseif tonumber(iType) == 4 then
                        if iSubType > 0 and iSubType < 5 then --include only cloth, leather, mail & plate, this ignores 
                            --print('added armour: '..name..' rarity: '..rarity..' sub type: '..iSubType)
                            tinsert(Guildbook.Bags.PlayerBags, { 
                                Name = name, 
                                ItemID = tonumber(id), 
                                SlotValue = tonumber(count * price),
                                BagID = bag,
                                SlotID = slot,
                            })
                        end
                    end
                elseif rarity == 0 then
                    --print('added junk: '..name..' rarity: '..rarity..' sub type: '..iSubType)
                    tinsert(Guildbook.Bags.PlayerBags, { 
                        Name = name, 
                        ItemID = tonumber(id), 
                        SlotValue = tonumber(count * price),
                        BagID = bag,
                        SlotID = slot,
                    }) 
                end
            end
        end
    end
    table.sort(Guildbook.Bags.PlayerBags, function(a, b)
        if a.Rarity == b.Rarity then
            return a.SlotValue < b.SlotValue
        else
            return a.Rarity < b.Rarity
        end
    end)
end

function Guildbook.Bags.ScanPlayerBankBags()
    GUILDBOOK_CHARACTER['BankItems'] = {}
    GUILDBOOK_CHARACTER['BankItemsScanTime'] = date('*t')
    for slot = 1, 28 do
        local link = GetContainerItemLink(-1,slot)
        if link then
            local id = tonumber(Guildbook.GetItemIdFromLink(link))
            local count = select(2, GetContainerItemInfo(-1, slot))
            local added = false
            if next(GUILDBOOK_CHARACTER['BankItems']) then
                for k, v in ipairs(GUILDBOOK_CHARACTER['BankItems']) do
                    if tonumber(v['ItemID']) == id then
                        v['Count'] = tonumber(v['Count'] + count)
                        added = true
                    end
                end
            end
            if added == false then
                tinsert(GUILDBOOK_CHARACTER['BankItems'], { 
                    ItemID = tonumber(id), 
                    Count = tonumber(count) 
                })
            end
        end
    end
    for bag = 5, 11 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag,slot)
            if link then
                local id = tonumber(Guildbook.GetItemIdFromLink(link))
                local count = select(2, GetContainerItemInfo(bag, slot))
                local added = false
                if next(GUILDBOOK_CHARACTER['BankItems']) then
                    for k, v in ipairs(GUILDBOOK_CHARACTER['BankItems']) do
                        if tonumber(v['ItemID']) == id then
                            v['Count'] = tonumber(v['Count'] + count)
                            added = true
                        end
                    end
                end
                if added == false then
                    tinsert(GUILDBOOK_CHARACTER['BankItems'], { 
                        ItemID = tonumber(id), 
                        Count = tonumber(count) 
                    })
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--events, self refers to the addon as its overriden in the call during the init
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--set up event listener
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_ADDON')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_GUILD')
Guildbook.EventFrame:RegisterEvent('LOOT_OPENED')
Guildbook.EventFrame:RegisterEvent('BANKFRAME_OPENED')
Guildbook.EventFrame:RegisterEvent('UNIT_SPELLCAST_SENT')
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('QUEST_ACCEPTED')
Guildbook.EventFrame:RegisterEvent('QUEST_TURNED_IN')
Guildbook.EventFrame:RegisterEvent('QUEST_REMOVED')
Guildbook.EventFrame:RegisterEvent('ZONE_CHANGED')
Guildbook.EventFrame:RegisterEvent('ZONE_CHANGED_INDOORS')
Guildbook.EventFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
Guildbook.EventFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
--Guildbook.EventFrame:RegisterEvent('UI_ERROR_MESSAGE')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    DEBUG('EVENT='..tostring(event))
    --Guildbook.GetArgs(...)
    Guildbook.Events[event](Guildbook, ...) --override the 'self' arguement with the addon namespace, convention?
end)

--event handler, self=addon
Guildbook.Events = {
    ['ADDON_LOADED'] = function(self, ...)
        if select(1, ...):lower() == addonName:lower() then
            self:Init()
            self.Gathering.UpdateMapGatheringIcons()
            self.Gathering.UpdateWorldMapGatheringIcons()
        end
    end,
    ['GUILD_ROSTER_UPDATE'] = function(self, ...)
        if GuildbookGuildInfoFrameSummaryFrame:IsVisible() then
            self.SummaryFrame:UpdateClassBars()
        end
        if GuildMemberDetailFrame:IsVisible() then     
            self.GuildMemberDetailFrame:HandleRosterUpdate()
        end
        if GuildbookGuildInfoFrameRaidRosterFrame:IsVisible() then
            self.RaidRosterFrame:ScanGuildMembers()
        end
    end,
    ['CHAT_MSG_ADDON'] = function(self, ...)
        local prefix = select(1, ...)
        DEBUG('handle addon msg: '..prefix)
        if string.find(prefix, 'mdf') then
            self.GuildMemberDetailFrame:HandleAddonMessage(...)
        elseif string.find(prefix, 'sum') then
            self.SummaryFrame:HandleAddonMessage(...)
        elseif string.find(prefix, 'gat') then
            self.Gathering.ParseGatheringData(true, ...)
        elseif string.find(prefix, 'gat-db') then
            self.Gathering.ParseGatheringData(false, ...)
        elseif string.find(prefix, 'raid') then
            self.RaidRosterFrame:HandleAddonMessage(...)
        end
    end,
    ['UNIT_SPELLCAST_SENT'] = function(self, ...)
        local target = select(2, ...)
        local c = UnitClass('target')
        if c then
            DEBUG('target has class of '..c)
        else
            DEBUG('target has no class')
        end
        if target then
            Guildbook.LastTarget = target
            local spell = select(4, ...)
            local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell)
            DEBUG('cast: '..name..' at '..target)
        end
    end,
    ['LOOT_OPENED'] = function(self, ...)
        self.Gathering.ScanLoot()
        --self.Bags.SmartLootScanPlayerBags()
    end,
    ['QUEST_ACCEPTED'] = function(self, ...)
        local questID = select(2, ...)
        if not GUILDBOOK_GLOBAL['QuestRewardsXP'] then
            GUILDBOOK_GLOBAL['QuestRewardsXP'] = {}
        end
        GUILDBOOK_GLOBAL['QuestRewardsXP'][tostring(questID)] = tonumber(GetRewardXP())
    end,
    ['QUEST_TURNED_IN'] = function(self, ...)
        local questID = select(2, ...)
        if not GUILDBOOK_GLOBAL['QuestRewardsXP'] then
            GUILDBOOK_GLOBAL['QuestRewardsXP'] = {}
        end
        GUILDBOOK_GLOBAL['QuestRewardsXP'][tostring(questID)] = nil
    end,
    ['QUEST_REMOVED'] = function(self, ...)
        local questID = select(2, ...)
        if not GUILDBOOK_GLOBAL['QuestRewardsXP'] then
            GUILDBOOK_GLOBAL['QuestRewardsXP'] = {}
        end
        GUILDBOOK_GLOBAL['QuestRewardsXP'][tostring(questID)] = nil
    end,
    ['ZONE_CHANGED'] = function(self, ...)
        self.Gathering.UpdateMapGatheringIcons()
        self.Gathering.UpdateWorldMapGatheringIcons()
    end,
    ['ZONE_CHANGED_INDOORS'] = function(self, ...)
        self.Gathering.UpdateMapGatheringIcons()
        self.Gathering.UpdateWorldMapGatheringIcons()
    end,
    ['ZONE_CHANGED_NEW_AREA'] = function(self, ...)
        self.Gathering.UpdateMapGatheringIcons()
        self.Gathering.UpdateWorldMapGatheringIcons()
    end,
    ['CHAT_MSG_GUILD'] = function(self, ...)
        local msg = select(1, ...)
        local sender = select(5, ...)
        if msg:lower() == 'ding' then
            -- SendChatMessage('{rt5}{rt1}{rt5}{rt1}{rt5}{rt1}{rt5}', 'GUILD')
            -- SendChatMessage('{rt1}GRATZ{rt1}{rt5}{rt1}', 'GUILD')
            -- SendChatMessage('{rt5}{rt1}{rt5}{rt1}{rt5}{rt1}{rt5}', 'GUILD')
            -- SendChatMessage('{rt1}{rt5}{rt1}GRATZ{rt1}', 'GUILD')
            -- SendChatMessage('{rt5}{rt1}{rt5}{rt1}{rt5}{rt1}{rt5}', 'GUILD')
        end
    end,
    ['BANKFRAME_OPENED'] = function(self)
        self.Bags.ScanPlayerBankBags()
    end,
    ['UI_ERROR_MESSAGE'] = function(self, ...)
        Guildbook.GetArgs(...)
        local t = select(1, ...)
        if GetGameMessageInfo(t) == 'ERR_INV_FULL' then
            --Guildbook.Bags.PlayerBags = {}
--            self.Bags.SmartLootScanPlayerBags()
        end
    end,
    ['COMBAT_LOG_EVENT_UNFILTERED'] = function(self, ...)
        local d = {CombatLogGetCurrentEventInfo()}
        if tostring(d[2]) == 'SPELL_DAMAGE' then
            -- for i = 1, #d do
            --     --print(i, d[i])
            -- end
            if d[18] == true then
                --print(d[13], 'critical hit for: '..d[15], d[5], d[9])
            end
        elseif tostring(d[2]) == "SPELL_HEAL" then
            -- for i = 1, #d do
            --     --print(i, d[i])
            -- end
            if d[18] == true then
                --print(d[13], 'critical hit for: '..d[15], d[5], d[9])
                --SendChatMessage(tostring(d[5]..' - '..d[13]..' Critical hit '..d[9]..' for: '..d[15]), 'PARTY')
            end
        end
    end
}
