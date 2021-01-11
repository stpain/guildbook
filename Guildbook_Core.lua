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

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------
local build = 4.0
local locale = GetLocale()
local L = Guildbook.Locales


Guildbook.FONT_COLOUR = '|cff0070DE'
Guildbook.PlayerMixin = nil
Guildbook.GuildBankCommit = {
    Commit = nil,
    Character = nil,
}
Guildbook.NUM_TALENT_ROWS = 7.0
Guildbook.COMMS_DELAY = 0.0

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDBOOK1 = '/guildbook'
SlashCmdList['GUILDBOOK'] = function(msg)
    if msg == '-help' then
        print(':(')

    elseif msg == '-stats' then
        --local base, casting = GetManaRegen();
        Guildbook:GetCharacterStats()
    end
end



---------------------------------------------------------------------------------------------------------------------------------------------------------------
--debug printers
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.DebugColours = {
    ['error'] = '|cffC41E3A', --dk
    ['comms_in'] = '|cffAAD372', --hunter
    ['func'] = '|cff00FF98', --monk
    ['comms_out'] = '|cff0070DD', --shaman
}

-- table to hold debug messages
Guildbook.DebugLog = {}

--- add debug message to debugger window
-- @param type string value used for lookup in Guildbook.DebugColours
-- @param err string function name message originates from
-- @param msg string the message to print
function Guildbook.DEBUG(type, err, msg)
    for i = 1, 20 do
        Guildbook.DebuggerWindow.Listview[i]:Hide()
    end
    if err and msg then
        table.insert(Guildbook.DebugLog, string.format("%s [%s%s|r], %s", date("%T"), Guildbook.DebugColours[type], err, msg))
    else
        table.insert(Guildbook.DebugLog, 'oops something went wrong!')
    end
    if Guildbook.DebugLog and next(Guildbook.DebugLog) then
        local i = #Guildbook.DebugLog - 19
        if i < 1 then
            i = 1
        end
        Guildbook.DebuggerWindow.ScrollBar:SetMinMaxValues(1, i)
        Guildbook.DebuggerWindow.ScrollBar:SetValue(i)
        C_Timer.After(0, function()
            for i = 1, 20 do
                Guildbook.DebuggerWindow.Listview[i]:Show()
            end
        end)
    end
end
local DEBUG = Guildbook.DEBUG


-- create the debugging window
Guildbook.DebuggerWindow = CreateFrame('FRAME', 'GuildbookDebugFrame', UIParent, "UIPanelDialogTemplate")
Guildbook.DebuggerWindow:SetPoint('CENTER', 0, 0)
Guildbook.DebuggerWindow:SetFrameStrata('HIGH')
Guildbook.DebuggerWindow:SetSize(800, 280)
Guildbook.DebuggerWindow:SetMovable(true)
Guildbook.DebuggerWindow:EnableMouse(true)
Guildbook.DebuggerWindow:RegisterForDrag("LeftButton")
Guildbook.DebuggerWindow:SetScript("OnDragStart", Guildbook.DebuggerWindow.StartMoving)
Guildbook.DebuggerWindow:SetScript("OnDragStop", Guildbook.DebuggerWindow.StopMovingOrSizing)
_G['GuildbookDebugFrameClose']:SetScript('OnClick', function()
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL['Debug'] = false
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
    end
    if GuildbookOptionsDebugCB:GetChecked() == true then
        Guildbook.DebuggerWindow:Show()
    else
        Guildbook.DebuggerWindow:Hide()
    end
end)

Guildbook.DebuggerWindow.header = Guildbook.DebuggerWindow:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
Guildbook.DebuggerWindow.header:SetPoint('TOP', 0, -9)
Guildbook.DebuggerWindow.header:SetText('Guildbook Debug')

Guildbook.DebuggerWindow.Listview = {}
for i = 1, 20 do
    local f = CreateFrame('BUTTON', tostring('SRBLP_LogsListview'..i), Guildbook.DebuggerWindow)
    f:SetPoint('TOPLEFT', Guildbook.DebuggerWindow, 'TOPLEFT', 8, (i * -12) -18)
    f:SetPoint('TOPRIGHT', Guildbook.DebuggerWindow, 'TOPRIGHT', -8, (i * -12) -18)
    f:SetHeight(12)
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
        local s = Guildbook.DebuggerWindow.ScrollBar:GetValue()
        Guildbook.DebuggerWindow.ScrollBar:SetValue(s - delta)
    end)
    Guildbook.DebuggerWindow.Listview[i] = f
end

Guildbook.DebuggerWindow.ScrollBar = CreateFrame('SLIDER', 'GuildbookDebugFrameScrollBar', Guildbook.DebuggerWindow, "UIPanelScrollBarTemplate")
Guildbook.DebuggerWindow.ScrollBar:SetPoint('TOPLEFT', Guildbook.DebuggerWindow, 'TOPRIGHT', -24, -44)
Guildbook.DebuggerWindow.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.DebuggerWindow, 'BOTTOMRIGHT', -8, 26)
Guildbook.DebuggerWindow.ScrollBar:EnableMouse(true)
Guildbook.DebuggerWindow.ScrollBar:SetValueStep(1)
Guildbook.DebuggerWindow.ScrollBar:SetValue(1)
Guildbook.DebuggerWindow.ScrollBar:SetMinMaxValues(1, 1)
Guildbook.DebuggerWindow.ScrollBar:SetScript('OnValueChanged', function(self)
    if Guildbook.DebugLog then
        local scrollPos = math.floor(self:GetValue())
        if scrollPos == 0 then
            scrollPos = 1
        end
        for i = 1, 20 do
            if Guildbook.DebugLog[(i - 1) + scrollPos] then
                Guildbook.DebuggerWindow.Listview[i]:Hide()
                Guildbook.DebuggerWindow.Listview[i].msg = Guildbook.DebugLog[(i - 1) + scrollPos]
                Guildbook.DebuggerWindow.Listview[i]:Show()
            end
        end
    end
end)


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Init()
    DEBUG('func', 'init', 'running init')
    
    local version = GetAddOnMetadata('Guildbook', "Version")

    self.ContextMenu_DropDown = CreateFrame("Frame", "GuildbookContextMenu", UIParent, "UIDropDownMenuTemplate")
    self.ContextMenu = {}

    AceComm:Embed(self)
    self:RegisterComm('Guildbook', 'ON_COMMS_RECEIVED')

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
            DEBUG('func', 'init', 'minimap icon saved var setting: false, hiding minimap button')
        end
    end)


    ------- this section will be adjusted when player profiles move in to profiles tab fully
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
            Guildbook.DebuggerWindow:Show()
        else
            Guildbook.DebuggerWindow:Hide()
        end
        GuildbookOptionsShowMinimapButton:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])

        if GUILDBOOK_CHARACTER['AttunementsKeys'] then
            GuildbookOptionsAttunementKeysUBRS:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['UBRS'])
            GuildbookOptionsAttunementKeysMC:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['MC'])
            GuildbookOptionsAttunementKeysONY:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['ONY'])
            GuildbookOptionsAttunementKeysBWL:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['BWL'])
            GuildbookOptionsAttunementKeysNAXX:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['NAXX'])
        end

        Guildbook.CommsDelaySlider:SetValue(GUILDBOOK_GLOBAL['CommsDelay'])
    end

    -- stagger some start up calls to prevent chat spam, use 3s interval
    C_Timer.After(3, function()
        Guildbook:CharacterStats_OnChanged()
    end)
    C_Timer.After(6, function()
        Guildbook:CleanUpGuildRosterData(Guildbook:GetGuildName(), 'checking guild data')
    end)
    C_Timer.After(9, function()
        Guildbook:SendGuildCalendarEvents()
    end)
    C_Timer.After(12, function()
        Guildbook:SendGuildCalendarDeletedEvents()
    end)
    C_Timer.After(15, function()
        Guildbook:RequestGuildCalendarEvents()
    end)
    C_Timer.After(18, function()
        Guildbook:RequestGuildCalendarDeletedEvents()
    end)

    -- this enables us to prevent character model capturing until the player is fully loaded
    Guildbook.LoadTime = GetTime()
    DEBUG('func', 'init', tostring('Load time '..date("%T")))
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function Guildbook:CreateTooltipPanel(name, parent, anchor, x, y, w, h, headerText) --, headerFont, headerFontSize)
    local f = CreateFrame('FRAME', anme, parent)
    f:SetPoint(anchor, x, y)
    f:SetSize(w, h)
    f.background = f:CreateTexture("$parentBackground", 'BACKGROUND')
    f.background:SetPoint('TOPLEFT', 3, -3)
    f.background:SetPoint('BOTTOMRIGHT', -3, 3)
    f.background:SetColorTexture(0,0,0,0.6)
    f:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    f.header = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    f.header:SetPoint('TOP', 0, -10)
    f.header:SetText(headerText)
    f.header:SetFont("Fonts\\FRIZQT__.TTF", 14)
    f.header:SetTextColor(1,1,1,1)
    return f
end


function Guildbook:TrimNumber(num)
    local trimmed = string.format("%.2f", num)
    return tonumber(trimmed)
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
function Guildbook:GetCharacterStats()
    if GUILDBOOK_CHARACTER then
        if not GUILDBOOK_CHARACTER['PaperDollStats'] then
            GUILDBOOK_CHARACTER['PaperDollStats'] = {}
        end

        GUILDBOOK_CHARACTER['PaperDollStats'].Block = self:TrimNumber(GetBlockChance())
        GUILDBOOK_CHARACTER['PaperDollStats'].ShieldBlock = self:TrimNumber(GetShieldBlock());
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeCrit = self:TrimNumber(GetCritChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].Dodge = self:TrimNumber(GetDodgeChance());
        --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
        --local base, casting = GetManaRegen();
        GUILDBOOK_CHARACTER['PaperDollStats'].Parry = self:TrimNumber(GetParryChance());
        GUILDBOOK_CHARACTER['PaperDollStats'].RangedCrit = self:TrimNumber(GetRangedCritChance());

        GUILDBOOK_CHARACTER['PaperDollStats'].SpellDamage = {}
        GUILDBOOK_CHARACTER['PaperDollStats'].SpellCrit = {}
        for id, school in pairs(spellSchools) do
            GUILDBOOK_CHARACTER['PaperDollStats'].SpellDamage[school] = self:TrimNumber(GetSpellBonusDamage(id));        
            GUILDBOOK_CHARACTER['PaperDollStats'].SpellCrit[school] = self:TrimNumber(GetSpellCritChance(id));
        end

        GUILDBOOK_CHARACTER['PaperDollStats'].HealingBonus = self:TrimNumber(GetSpellBonusHealing());

        GUILDBOOK_CHARACTER['PaperDollStats'].SpellHit = self:TrimNumber(GetSpellHitModifier());
        GUILDBOOK_CHARACTER['PaperDollStats'].MeleeHit = self:TrimNumber(GetHitModifier())


        for k, stat in pairs(statIDs) do
            local _, value, _, _ = UnitStat("player", k);
            GUILDBOOK_CHARACTER['PaperDollStats'][stat] = self:TrimNumber(value)
            --DEBUG('func', 'GetCharacterStats', string.format("%s = %s", stat, value))
        end

        for k, v in pairs(GUILDBOOK_CHARACTER['PaperDollStats']) do
            if type(v) ~= 'table' then
                DEBUG('func', 'GetCharacterStats', string.format("%s = %s", k, string.format("%.2f", v)))
            else
                for x, y in pairs(v) do
                    local trimmed = string.format("%.2f", y)
                    DEBUG('func', 'GetCharacterStats', string.format("%s = %s", x, string.format("%.2f", y)))
                end
            end
        end

        -- local ap = 0
        -- for k, stat in pairs(statIDs) do
        --     local _, value, _, _ = UnitStat("player", k);
        --     print(k, stat, value)
        --     ap = ap + GetAttackPowerForStat(k, value)
        -- end
        -- print(ap)

    end

end

--- return the players guild name if they belong to 1
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


--- scans the players bags and bank for guild bank sharing
--- creates a table in the character saved vars with scan time so we can check which data is newest
function Guildbook:ScanPlayerContainers()
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
                        Commit = GetServerTime(),
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
            --DEBUG('comms_out', 'ScanPlayerContainers', 'sending guild bank data due to new commit')
        end
    end
end


--- scan the players trade skills
--- this is used to get data about the players professions, recipes and reagents
function Guildbook:ScanTradeSkill()
    local prof = GetTradeSkillLine()
    GUILDBOOK_CHARACTER[prof] = {}
    for i = 1, GetNumTradeSkills() do
        local name, type, _, _, _, _ = GetTradeSkillInfo(i)
        if (name and type ~= "header") then
            local itemLink = GetTradeSkillItemLink(i)
            local itemID = select(1, GetItemInfoInstant(itemLink))
            local itemName = select(1, GetItemInfo(itemID))
            DEBUG('func', 'ScanTradeSkill', string.format('|cff0070DETrade item|r: %s, with ID: %s', name, itemID))
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
                        DEBUG('func', 'ScanTradeSkill', string.format('    Reagent name: %s, with ID: %s, Needed: %s', reagentName, reagentID, reagentCount))
                        GUILDBOOK_CHARACTER[prof][itemID][reagentID] = reagentCount
                    end
                end
            end
        end
    end
end


--- scan the players enchanting recipes, enchanting works a little differently 
--- this is used to get data about the players professions, recipes and reagents
function Guildbook:ScanCraftSkills_Enchanting()
    local currentCraftingWindow = GetCraftSkillLine(1)
    if currentCraftingWindow == 'Enchanting' then
        GUILDBOOK_CHARACTER['Enchanting'] = {}
        for i = 1, GetNumCrafts() do
            local name, _, type, _, _, _, _ = GetCraftInfo(i)
            if (name and type ~= "header") then
                local itemID = select(7, GetSpellInfo(name))
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
        end
    end
end


--- scan the characters current guild cache
-- this will check name and class against the return values from PlayerMixin using guid, sometimes players create multipole characters before settling on a class
-- we also check the player entries for profression errors, talents table and spec data
-- any entries not found the current guild roster will be removed (=nil)
function Guildbook:CleanUpGuildRosterData(guild, msg)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[guild] then
        Guildbook:PrintMessage(msg)
        local currentGUIDs = {}
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        GUILDBOOK_GLOBAL['RosterExcel'] = {}
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            --local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            currentGUIDs[guid] = true
            table.insert(GUILDBOOK_GLOBAL['RosterExcel'], string.format("%s,%s,%s,%s,%s", name, class, rankName, level, publicNote))
        end
        for guid, info in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guild]) do
            if not currentGUIDs[guid] then
                GUILDBOOK_GLOBAL.GuildRosterCache[guild][guid] = nil
                Guildbook:PrintMessage(string.format('removed %s from roster cache', info.Name))
            else
                if not self.PlayerMixin then
                    self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                else
                    self.PlayerMixin:SetGUID(guid)
                end
                if self.PlayerMixin:IsValid() then
                    local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
                    local name = C_PlayerInfo.GetName(self.PlayerMixin)
                    if name and class then
                        if not info.Class or (info.Class ~= class) then
                            info.Class = class
                            DEBUG('func', 'CleanUpGuildRosterData', name..' has error with class, updating class to mixin value')
                        end
                        if not info.Name or (info.Name ~= name) then
                            info.Name = name
                            DEBUG('func', 'CleanUpGuildRosterData', info.Name..' has error with name, updating name to mixin value')
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
                            DEBUG('func', 'CleanUpGuildRosterData', name..' has error with main spec, setting to default')
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
                            DEBUG('func', 'CleanUpGuildRosterData', name..' has error with off spec, setting to default')
                            info.OffSpec = '-'
                        end
                        for prof, _ in pairs(Guildbook.Data.Profession) do
                            for k, v in pairs(info) do
                                if k == prof then
                                    if info.Profession1 == prof or info.Profession2 == prof then
                                        DEBUG('func', 'CleanUpGuildRosterData', string.format('%s matches prof1 or prof2 keeping data', prof))
                                    else
                                        if prof == 'Cooking' or prof == 'Fishing' or prof == 'FirstAid' then

                                        else
                                            info[prof] = nil
                                            DEBUG('func', 'CleanUpGuildRosterData', string.format('removing %s from %s as no longer trained', prof, name))
                                        end
                                    end
                                end
                            end
                        end
                        if not info.Talents then
                            info.Talents = {
                                [1] = {},
                                [2] = {},
                            }
                            DEBUG('func', 'CleanUpGuildRosterData', string.format('added talent tables to %s', name))
                        end
                    end
                end
            end
        end
    end
end

-- dont really need this but might be useful
function Guildbook:CleanUpCharacterSettings()
    if GUILDBOOK_CHARACTER then
        if GUILDBOOK_CHARACTER['UNKNOWN'] then
            GUILDBOOK_CHARACTER['UNKNOWN'] = nil
        end
    end
end


--- scan the players professions
-- get the name of any professions the player has, the profession level
-- also check the secondary professions fishing, cooking, first aid
-- this will update the character saved var which is then read when a request comes in
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
                -- using GetEnglish to cover non english clients checking against addon lookup tables
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

        GUILDBOOK_CHARACTER['Fishing'] = myCharacter.Fishing
        GUILDBOOK_CHARACTER['Cooking'] = myCharacter.Cooking
        GUILDBOOK_CHARACTER['FirstAid'] = myCharacter.FirstAid
    end
end


-- https://wow.gamepedia.com/API_GetActiveTalentGroup -- dual spec api for wrath

--- get the players current talents
-- as there is no dual spec for now we just default to using talents[1] and updating Talents.Current
-- when dual spec arrives we will have to adjust this
function Guildbook:GetCharacterTalentInfo()
    if GUILDBOOK_CHARACTER then
        if not GUILDBOOK_CHARACTER['Talents'] then
            GUILDBOOK_CHARACTER['Talents'] = {
                [1] = {},
                [2] = {},  
            }
        end
        -- will need dual spec set up for wrath
        for tabIndex = 1, GetNumTalentTabs() do
            local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
            for talentIndex = 1, GetNumTalents(tabIndex) do
                local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
                table.insert(GUILDBOOK_CHARACTER['Talents'][1], {
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
    end
end


--- not used at the moment
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


--- check the players current gear and calculate the mean item level
function Guildbook.GetItemLevel()
    local character, itemLevel, itemCount = {}, 0, 0
	for k, slot in ipairs(Guildbook.Data.InventorySlots) do
		character[slot.Name] = GetInventoryItemID('player', slot.Name)
		if character[slot.Name] ~= nil then
			local iName, iLink, iRarety, ilvl = GetItemInfo(character[slot.Name])
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
function Guildbook.GetCharacterInventory()
    if GUILDBOOK_CHARACTER then
        if not GUILDBOOK_CHARACTER['Inventory'] then
            GUILDBOOK_CHARACTER['Inventory'] = {
                Current = {}
            }
        end
        for k, slot in ipairs(Guildbook.Data.InventorySlots) do
            local link = GetInventoryItemLink('player', GetInventorySlotInfo(slot.Name)) or false
            GUILDBOOK_CHARACTER['Inventory'].Current[slot.Name] = link
            DEBUG('func', 'GetCharacterInventory', string.format("added %s at slot %s", link or 'false', slot.Name))
        end
    end
end


function Guildbook:IsGuildMemberOnline(player)
    local online = false
    local guildName = Guildbook:GetGuildName()
    if guildName then
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i)
            --DEBUG('func', 'IsGuildMemberOnline', string.format("player %s is online %s", name, tostring(isOnline)))
            if Ambiguate(name, 'none') == Ambiguate(player, 'none') then
                online = isOnline
            end
        end
    end
    return online
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
-- comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Transmit(data, channel, target, priority)
    if target ~= nil then
        --local name = Ambiguate(target, 'none')
        if self:IsGuildMemberOnline(target) == false then
            DEBUG('error', 'Guildbook:Transmit', string.format("player %s is not online", target))
            return
        end
    end

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
        --target = Ambiguate(target, 'none')
    end
    if addonName and encoded and channel and priority then
        DEBUG('comms_out', 'SendCommMessage', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority))
        self:SendCommMessage(addonName, encoded, channel, target, priority)
    end
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
    Guildbook:GetCharacterTalentInfo()
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER['Talents'] then
        local response = {
            type = "TALENT_INFO_RESPONSE",
            payload = {
                guid = UnitGUID('player'),
                talents = GUILDBOOK_CHARACTER['Talents'],
            }
        }
        -- send to all online players
        --self:Transmit(response, distribution, sender, "BULK")
        self:Transmit(response, 'GUILD', nil, "BULK")
    else
        DEBUG('error', 'OnTalentInfoRequest', string.format('unable to send talents, requested from %s', sender))
    end
end

function Guildbook:OnTalentInfoReceived(data, distribution, sender)
    if distribution ~= "GUILD" then
        return
    end
    if not data.payload.guid then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.guid].Talents = data.payload.talents
            DEBUG('func', 'OnTalentInfoReceived', string.format('updated %s talents', sender))
        end
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
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER['Inventory'] then
        local response = {
            type = 'INVENTORY_RESPONSE',
            payload = {
                guid = UnitGUID('player'),
                inventory = GUILDBOOK_CHARACTER['Inventory'], --send it all for now
            }
        }
        -- send to everyone?
        self:Transmit(response, 'GUILD', nil, 'BULK')
    end
end


function Guildbook:OnCharacterInventoryReceived(data, distribution, sender)
    if distribution ~= 'GUILD' then
        return
    end
    if not data.payload.guid then
        return
    end
    C_Timer.After(Guildbook.COMMS_DELAY, function()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.guid].Inventory = data.payload.inventory
            DEBUG('func', 'OnCharacterInventoryReceived', string.format('updated %s inventory', sender))
        end
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
    --DEBUG('comms_out', 'SendTradeSkillsRequest', string.format('sent request for %s\'s from %s', target, profession))
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
        --self:Transmit(response, distribution, sender, "BULK")
        --DEBUG('comms_out', 'OnTradeSkillsRequested', string.format('sending %s data to %s', request.payload, sender))
    end
end

function Guildbook:OnTradeSkillsReceived(data, distribution, sender)
    --DEBUG('comms_in', 'OnTradeSkillsReceived', string.format("prof data from %s", sender))
    if data.payload.profession and type(data.payload.recipes) == 'table' then
        C_Timer.After(Guildbook.COMMS_DELAY, function()
            local guildName = Guildbook:GetGuildName()
            if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
                for guid, character in pairs(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName]) do
                    if character.Name == sender then                
                        character[data.payload.profession] = data.payload.recipes
                        DEBUG('func', 'OnTradeSkillsReceived', 'updating db, set: '..character.Name..' prof: '..data.payload.profession)
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
    --DEBUG('comms_out', 'CharacterDataRequest', string.format("sent character data request to %s", target))
end

-- limited to reduce chat spam, such as power levelling a profession etc
local characterStatsDelay = 30.0
local characterStatsLastSent = GetTime()
local characterStatsQueued = false
function Guildbook:CharacterStats_OnChanged()
    local remaining = string.format("%.1d", (characterStatsLastSent + characterStatsDelay - GetTime()))
    if characterStatsLastSent + characterStatsDelay < GetTime() then
        local d = self:GetCharacterDataPayload()
        if type(d) == 'table' and d.payload.GUID then
            self:Transmit(d, 'GUILD', sender, 'NORMAL')
        end
        characterStatsLastSent = GetTime()
    else
        if characterStatsQueued == false then
            C_Timer.After(math.floor(tonumber(remaining)), function()
                local d = self:GetCharacterDataPayload()
                if type(d) == 'table' and d.payload.GUID then
                    self:Transmit(d, 'GUILD', sender, 'NORMAL')
                end
                characterStatsLastSent = GetTime()
                characterStatsQueued = false
            end)
            characterStatsQueued = true
        end
        DEBUG('func', 'CharacterStats_OnChanged', tostring(string.format('character stats added to queue, %s seconds before sending', (characterStatsLastSent + characterStatsDelay - GetTime()))))
    end
end


--- i need to remove the inventory and set up a new comms for it 
function Guildbook:GetCharacterDataPayload()
    local guid = UnitGUID('player')
    local level = UnitLevel('player')
    local ilvl = self:GetItemLevel()
    self.GetProfessionData()
    self.GetCharacterInventory()
    self:GetCharacterStats()
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
                Cooking = GUILDBOOK_CHARACTER["Cooking"],
                Fishing = GUILDBOOK_CHARACTER["Fishing"],
                FirstAid = GUILDBOOK_CHARACTER["FirstAid"],

                CharStats = GUILDBOOK_CHARACTER['PaperDollStats']
                --CurrentEquipment = GUILDBOOK_CHARACTER['Inventory'].Current
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
        --DEBUG('comms_out', 'OnCharacterDataRequested', 'sending character data to '..sender)
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
        for k, v in ipairs({'Cooking', 'Fishing', 'FirstAid'}) do
            if data.payload[v] then
                GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID][v] = data.payload[v]
            end
        end
        if data.payload.CharStats then
            DEBUG('func', 'OnCharacterDataReceived', sender..' has sent base stats')
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].PaperDollStats = data.payload.CharStats
        end

        -- if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Inventory then
        --     GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Inventory = {}
        -- end
        -- GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Inventory.Current = data.payload.CurrentEquipment

        DEBUG('func', 'OnCharacterDataReceived', string.format('OnCharacterDataReceived > sender=%s', data.payload.Name))
        C_Timer.After(Guildbook.COMMS_DELAY, function()
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
    --DEBUG('comms_out', 'SendGuildBankCommitRequest', string.format('SendGuildBankCommitRequest > character=%s', bankCharacter))
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
            --DEBUG('comms_out', 'OnGuildBankCommitRequested', string.format('character=%s, commit=%s', data.payload, GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit))
        end
    end
end

function Guildbook:OnGuildBankCommitReceived(data, distribution, sender)
    if distribution == 'WHISPER' then
        --DEBUG('comms_in', 'OnGuildBankCommitReceived', string.format('Received a commit for bank character %s from %s - commit time: %s', data.payload.Character, sender, data.payload.Commit))
        if Guildbook.GuildBankCommit['Commit'] == nil then
            Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
            Guildbook.GuildBankCommit['Character'] = sender
            Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
            --DEBUG('comms_in', 'OnGuildBankCommitReceived', string.format('First response added to temp table, %s->%s', sender, data.payload.Commit))
        else
            if tonumber(data.payload.Commit) > tonumber(Guildbook.GuildBankCommit['Commit']) then
                Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
                Guildbook.GuildBankCommit['Character'] = sender
                Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
                --DEBUG('comms_in', 'OnGuildBankCommitReceived', string.format('Response commit is newer than temp table commit, updating info - %s->%s', sender, data.payload.Commit))
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
        --DEBUG('comms_out', 'SendGuildBankDataRequest', string.format('Sending request for guild bank data to %s for bank character %s', Guildbook.GuildBankCommit['Character'], Guildbook.GuildBankCommit['BankCharacter']))
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
        --DEBUG('comms_out', 'OnGuildBankDataRequested', 'Sending guild bank data to: '..sender..' as requested')
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
    self.GuildFrame.GuildBankFrame:ProcessBankData(data.payload.Data)
    self.GuildFrame.GuildBankFrame:RefreshSlots()
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
    --DEBUG('comms_out', 'RequestGuildCalendarDeletedEvents', 'Sending calendar events deleted request')
end

function Guildbook:RequestGuildCalendarEvents(event)
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
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateAttending()
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
                if event.date.month >= today.month and event.date.year >= today.year and event.date.month <= future.month and event.date.year <= future.year then
                    table.insert(events, event)
                    DEBUG('func', 'SendGuildCalendarEvents', string.format('Added event: %s to comms table', event.title))
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
    if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] then
        for k, event in ipairs(data.payload) do
            DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('Received event: %s', event.title))
            local exists = false
            for _, e in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if e.created == event.created and e.owner == event.owner then
                    exists = true
                    DEBUG('func', 'OnGuildCalendarEventsReceived', 'event exists!')
                    -- check and update attend
                    for guid, info in pairs(e.attend) do
                        if tonumber(info.Updated) < event.attend[guid].Updated then
                            info.Status = event.attend[guid].Status
                            info.Updated = event.attend[guid].Updated
                            DEBUG('func', 'OnGuildCalendarEventsReceived', 'Updated attend status for event: '..event.title)
                        end
                    end
                end
            end
            if exists == false then
                table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], event)
                DEBUG('func', 'OnGuildCalendarEventsReceived', string.format('This event is a new event, adding to db: %s', event.title))
            end
        end
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
    self.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
end

-- TODO: add script for when a player drops a prof
-- SkillDetailStatusBarUnlearnButton:HookScript('OnClick', function()

-- end)


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- soft reserve
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:RequestRaidSoftReserves()
    local request = {
        type = 'RAID_SOFT_RESERVES_REQUEST',
    }
    self:Transmit(request, 'RAID', nil, 'NORMAL')
    --DEBUG('comms_out', 'RequestRaidSoftReserves', 'Sent a request on RAID channel for soft reserves')
end

function Guildbook:OnRaidSoftReserveRequested(data, distribution, sender)
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER['SoftReserve'] then
        local response = {
            type = 'RAID_SOFT_RESERVE_RESPONSE',
            payload = GUILDBOOK_CHARACTER['SoftReserve'],
        }
        self:Transmit(response, 'RAID', nil, 'NORMAL')
        --DEBUG('comms_out', 'OnRaidSoftReserveRequested', 'Soft reserve response sent')
    end
end

function Guildbook:OnRaidSoftReserveReceived(data, distribution, sender)
    --DEBUG('comms_in', 'OnRaidSoftReserveReceived', 'Soft reserve response receieved from: '..sender)
    if self.GuildFrame.SoftReserveFrame.SelectedRaid ~= nil then
        if data.payload and data.payload[self.GuildFrame.SoftReserveFrame.SelectedRaid] then
            DEBUG('func', 'OnRaidSoftReserveReceived', string.format('%s has a soft reserved %s for %s', sender, data.payload[self.GuildFrame.SoftReserveFrame.SelectedRaid], self.GuildFrame.SoftReserveFrame.SelectedRaid))
            for i = 1, 40 do
                local name, _, _, level, class, fileName, _, online, _, role, isML, _ = GetRaidRosterInfo(i)
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


function Guildbook:PLAYER_ENTERING_WORLD()
    self:ModBlizzUI()
    self:SetupStatsFrame()
    --self:SetupTradeSkillFrame()
    self:SetupGuildBankFrame()
    self:SetupGuildCalendarFrame()
    self:SetupGuildMemberDetailframe()
    --self:SetupSoftReserveFrame()
    self:SetupProfilesFrame()
    self:SetupChatFrame()
    self.EventFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')

    --LoadAddOn("Blizzard_DebugTools")

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
        --DevTools_Dump(self.player)
    end)
end


function Guildbook:TRADE_SKILL_UPDATE()
    C_Timer.After(1, function()
        DEBUG('func', 'TRADE_SKILL_UPDATE', 'scanning skills')
        self:ScanTradeSkill()
    end)
end


function Guildbook:CRAFT_UPDATE()
    C_Timer.After(1, function()
        DEBUG('func', 'CRAFT_UPDATE', 'scanning skills enchanting')
        self:ScanCraftSkills_Enchanting()
    end)
end


function Guildbook:UPDATE_MOUSEOVER_UNIT()
    -- delay any model loading while players addons sort themselves out
    if Guildbook.LoadTime + 8.0 > GetTime() then
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
            if race and self.player.faction == C_CreatureInfo.GetFactionInfo(raceID).groupTag then
                if self.GuildFrame.ProfilesFrame.DetailsTab:IsVisible() then
                    self.GuildFrame.ProfilesFrame.DetailsTab:AddModelFrame('mouseover', race, sex)
                end
            end
        end
    end
end


function Guildbook:CHAT_MSG_GUILD(...)
    local sender = select(5, ...)
    local msg = select(1, ...)
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
            self:AddGuildChatMessage(Guildbook.GuildChatLog, string.format("%s [%s%s|r]: %s", date("%T"), Guildbook.Data.Class[class].FontColour, sender, msg))
        end
    end
end


function Guildbook:PLAYER_TALENT_UPDATE(...)

end


function Guildbook:PLAYER_EQUIPMENT_CHANGED(...)

end


function Guildbook:RAID_ROSTER_UPDATE()
    DEBUG('func', 'RAID_ROSTER_UPDATE', 'Raid roster update event')
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

-- added to automate the guild bank scan
function Guildbook:BANKFRAME_OPENED()
    for i = 1, GetNumGuildMembers() do
        local _, _, _, _, _, _, publicNote, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if publicNote:lower():find('guildbank') and GUID == UnitGUID('player') then
            self:ScanPlayerContainers()
        end
    end
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
    DEBUG('comms_in', 'ON_COMMS_RECEIVED', string.format("%s from %s", data.type, sender))

    if data.type == "TRADESKILLS_REQUEST" then
        self:OnTradeSkillsRequested(data, distribution, sender)

    elseif data.type == "TRADESKILLS_RESPONSE" then
        self:OnTradeSkillsReceived(data, distribution, sender);

    elseif data.type == 'CHARACTER_DATA_REQUEST' then
        self:OnCharacterDataRequested(data, distribution, sender)

    elseif data.type == 'CHARACTER_DATA_RESPONSE' then
        self:OnCharacterDataReceived(data, distribution, sender)

    elseif data.type == 'TALENT_INFO_REQUEST' then
        self:OnTalentInfoRequest(data, distribution, sender)

    elseif data.type == 'TALENT_INFO_RESPONSE' then
        self:OnTalentInfoReceived(data, distribution, sender)

    elseif data.type == 'INVENTORY_REQUEST' then
        self:OnCharacterInventoryRequest(data, distribution, sender)

    elseif data.type == 'INVENTORY_RESPONSE' then
        self:OnCharacterInventoryReceived(data, distribution, sender)



        
--- these will be removed slowly as we potentially move into TBC
--==================================
    elseif data.type == 'GUILD_BANK_COMMIT_REQUEST' then
        self:OnGuildBankCommitRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_COMMIT_RESPONSE' then
        self:OnGuildBankCommitReceived(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_REQUEST' then
        self:OnGuildBankDataRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_RESPONSE' then
        self:OnGuildBankDataReceived(data, distribution, sender)

    elseif data.type == 'RAID_SOFT_RESERVES_REQUEST' then
        self:OnRaidSoftReserveRequested(data, distribution, sender)

    elseif data.type == 'RAID_SOFT_RESERVE_RESPONSE' then
        self:OnRaidSoftReserveReceived(data, distribution, sender)
--==================================






--- these need better naming should decide before 4.x is released?
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
        self:SendGuildCalendarEvents()

    elseif data.type == 'GUILD_CALENDAR_EVENTS_DELETED_REQUESTED' then
        self:SendGuildCalendarDeletedEvents()


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
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_GUILD')
Guildbook.EventFrame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
--Guildbook.EventFrame:RegisterEvent('PLAYER_TALENT_UPDATE')
Guildbook.EventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    --DEBUG( event, ' ')
    Guildbook[event](Guildbook, ...)
end)