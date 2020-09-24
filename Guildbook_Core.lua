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
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDHELPERCLASSIC1 = '/guildbook'
SLASH_GUILDHELPERCLASSIC2 = '/g-k'
SlashCmdList['GUILDHELPERCLASSIC'] = function(msg)
    if msg == '-help' then
        Guildbook:ScanPlayerProfession()
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--local variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------
local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG
local PRINT = Guildbook.PRINT

local PRINT_COLOUR = '|cffFF7D0A'

--set constants
local FRIENDS_FRAME_WIDTH = FriendsFrame:GetWidth()
local GUILD_FRAME_WIDTH = GuildFrame:GetWidth()
local GUILD_INFO_FRAME_WIDTH = GuildInfoFrame:GetWidth()

-- config stuff
Guildbook.GuildFrame = {
    ColumnHeaders = {
        { Text = 'Rank', Width = 70, },
        { Text = 'Note', Width = 80, },
        { Text = 'Main Spec', Width = 80, },
        { Text = 'Profession 1', Width = 90, },
        { Text = 'Profession 2', Width = 90, },
        { Text = 'Online', Width = 65, },
    },
    ColumnTabs = {},
    ColumnWidths = {
        Rank = 67.0,
        Note = 77.0,
        MainSpec = 77.0,
        Profession1 = 87.0,
        Profession2 = 87.0,
        Online = 52.0,
    },
    ColumnMarginX = 1.0,
}
Guildbook.FONT_COLOUR = ''
Guildbook.PlayerMixin = nil
Guildbook.CharDataMsgkeys = {
    [1] = 'guid',
    [2] = 'name',
    [3] = 'class',
    [4] = 'level',
    [5] = 'fishing',
    [6] = 'cooking',
    [7] = 'firstaid',
    [8] = 'prof1',
    [9] = 'prof1level',
    [10] = 'prof2',
    [11] = 'prof2level',
    [12] = 'main',
    [13] = 'mainspec',
    [14] = 'offspec',
    [15] = 'mainspecispvp',
    [16] = 'offspecispvp',
    [17] = 'guildname',
}
Guildbook.GuildBankCommit = {
    Commit = nil,
    Character = nil,
}

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Init()
    DEBUG('running init')

    self.ContextMenu_DropDown = CreateFrame("Frame", "GuildbookContextMenu", UIParent, "UIDropDownMenuTemplate")
    self.ContextMenu = {}

    -- adjust blizz layout and add widget
    GuildFrameGuildListToggleButton:Hide()

    GuildFrame:HookScript('OnShow', function(self)
        self:SetWidth(810)
        FriendsFrame:SetWidth(810)
    end)
    
    GuildFrame:HookScript('OnHide', function(self)
        self:SetWidth(GUILD_FRAME_WIDTH)
        FriendsFrame:SetWidth(FRIENDS_FRAME_WIDTH)
    end)
    
    --extend the guild info frame to full guild frame height
    GuildInfoFrame:SetPoint('TOPLEFT', GuildFrame, 'TOPRIGHT', 1, 0)
    GuildInfoFrame:SetPoint('BOTTOMLEFT', GuildFrame, 'BOTTOMRIGHT', 1, 0) 
    
    --extend the player detail frame to full height
    GuildMemberDetailFrame:SetPoint('TOPLEFT', GuildFrame, 'TOPRIGHT', 1, 0)
    GuildMemberDetailFrame:SetPoint('BOTTOMLEFT', GuildFrame, 'BOTTOMRIGHT', 1, 0)

    GuildInfoTextBackground:ClearAllPoints()
    GuildInfoTextBackground:SetPoint('TOPLEFT', GuildInfoFrame, 'TOPLEFT', 11, -32)
    GuildInfoTextBackground:SetPoint('BOTTOMRIGHT', GuildInfoFrame, 'BOTTOMRIGHT', -11, 40)
    GuildInfoFrameScrollFrame:SetPoint('BOTTOMRIGHT', GuildInfoTextBackground, 'BOTTOMRIGHT', -31, 7)

   
    for k, col in ipairs(self.GuildFrame.ColumnHeaders) do
        local tab = CreateFrame('BUTTON', 'GuildbookGuildFrameColumnHeader'..col.Text, GuildFrame)--, "OptionsFrameTabButtonTemplate")
        if col.Text == 'Rank' then
            tab:SetPoint('LEFT', GuildFrameColumnHeader4, 'RIGHT', -2.0, 0.0)
        else
            tab:SetPoint('LEFT', self.GuildFrame.ColumnTabs[k-1], 'RIGHT', -2.0, 0.0)
        end
        tab:SetSize(col.Width, GuildFrameColumnHeader4:GetHeight())
        tab.text = tab:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        tab.text:SetPoint('LEFT', tab, 'LEFT', 8.0, 0.0)
        tab.text:SetText(col.Text)
        tab.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
        tab.text:SetTextColor(1,1,1,1)
        tab.background = tab:CreateTexture('$parentBackground', 'BACKGROUND')
        tab.background:SetAllPoints(tab)
        tab.background:SetTexture(131139)
        tab.background:SetTexCoord(0.0, 0.00, 0.0 ,0.75, 0.97, 0.0, 0.97, 0.75)
        if (col.Text == 'Rank') or (col.Text == 'Note') or (col.Text == 'Online') then -- for now so it only works on blizz columns
            tab:SetScript('OnClick', function()
                SortGuildRoster(col.Text);
            end)
        end
        self.GuildFrame.ColumnTabs[k] = tab
    end
    
    GuildFrameNotesText:ClearAllPoints()
    GuildFrameNotesText:SetPoint('TOPLEFT', GuildFrameNotesLabel, 'BOTTOMLEFT', 0.0, -3.0)
    GuildFrameNotesText:SetPoint('BOTTOMRIGHT', GuildFrame, 'BOTTOMRIGHT', -12.0, 30.0)
   
    GuildListScrollFrame:ClearAllPoints()
    GuildListScrollFrame:SetPoint('TOPLEFT', GuildFrame, 'TOPLEFT', 11.0, -87.0)
    GuildListScrollFrame:SetPoint('TOPRIGHT', GuildFrame, 'TOPRIGHT', -32.0, -87.0)
    
    GuildFrameButton1:ClearAllPoints()
    GuildFrameButton1:SetPoint('TOPLEFT', GuildFrame, 'TOPLEFT', 8.0, -82.0)
    GuildFrameButton1:SetPoint('TOPRIGHT', GuildFrame, 'TOPRIGHT', -32.0, -82.0)
    GuildFrameButton1:GetHighlightTexture():SetAllPoints(GuildFrameButton1)
    
    for i = 1, 13 do
        -- adjust Name column position
        _G['GuildFrameButton'..i..'Name']:ClearAllPoints()
        _G['GuildFrameButton'..i..'Name']:SetPoint('TOPLEFT', _G['GuildFrameButton'..i], 'TOPLEFT', 7.0, -3.0)
        -- hook the click event
        _G['GuildFrameButton'..i]:HookScript('OnClick', function(self, button)
            if (button == 'LeftButton') and (GuildMemberDetailFrame:IsVisible()) then
                --print(_G['GuildFrameButton'..i..'Name']:GetText())
                Guildbook.GuildMemberDetailFrame:ClearText()
                local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(GetGuildRosterSelection())
                if isOnline then
                    local requestSent = C_ChatInfo.SendAddonMessage('gb-mdf-req', 'requestdata', 'WHISPER', name)
                    if requestSent then
                        DEBUG('sent data request to '..name)
                    end
                    Guildbook:CharacterDataRequest(name)
                end
                Guildbook.GuildMemberDetailFrame:UpdateLabels()
            end
        end)
    end
    
    local function formatGuildFrameButton(button, col)
        --button:SetFont("Fonts\\FRIZQT__.TTF", 10)
        button:SetJustifyH('LEFT')
        button:SetTextColor(col[1], col[2], col[3], col[4])
    end
    
    GuildFrameButton1.GuildbookColumnRank = GuildFrameButton1:CreateFontString('$parentGuildbookRank', 'OVERLAY', 'GameFontNormalSmall')
    GuildFrameButton1.GuildbookColumnRank:SetPoint('LEFT', _G['GuildFrameButton1Class'], 'RIGHT', -12.0, 0)
    GuildFrameButton1.GuildbookColumnRank:SetSize(self.GuildFrame.ColumnWidths['Rank'], GuildFrameButton1:GetHeight())
    formatGuildFrameButton(GuildFrameButton1.GuildbookColumnRank, {1,1,1,1})
    
    GuildFrameButton1.GuildbookColumnNote = GuildFrameButton1:CreateFontString('$parentGuildbookNote', 'OVERLAY', 'GameFontNormalSmall')
    GuildFrameButton1.GuildbookColumnNote:SetPoint('LEFT', GuildFrameButton1.GuildbookColumnRank, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
    GuildFrameButton1.GuildbookColumnNote:SetSize(self.GuildFrame.ColumnWidths['Note'], GuildFrameButton1:GetHeight())
    formatGuildFrameButton(GuildFrameButton1.GuildbookColumnNote, {1,1,1,1})
    
    GuildFrameButton1.GuildbookColumnMainSpec = GuildFrameButton1:CreateFontString('$parentGuildbookMainSpec', 'OVERLAY', 'GameFontNormalSmall')
    GuildFrameButton1.GuildbookColumnMainSpec:SetPoint('LEFT', GuildFrameButton1.GuildbookColumnNote, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
    GuildFrameButton1.GuildbookColumnMainSpec:SetSize(self.GuildFrame.ColumnWidths['MainSpec'], GuildFrameButton1:GetHeight())
    formatGuildFrameButton(GuildFrameButton1.GuildbookColumnMainSpec, {1,1,1,1})
    
    GuildFrameButton1.GuildbookColumnProfession1 = GuildFrameButton1:CreateFontString('$parentGuildbookProfession1', 'OVERLAY', 'GameFontNormalSmall')
    GuildFrameButton1.GuildbookColumnProfession1:SetPoint('LEFT', GuildFrameButton1.GuildbookColumnMainSpec, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
    GuildFrameButton1.GuildbookColumnProfession1:SetSize(self.GuildFrame.ColumnWidths['Profession1'], GuildFrameButton1:GetHeight())
    formatGuildFrameButton(GuildFrameButton1.GuildbookColumnProfession1, {1,1,1,1})
    
    GuildFrameButton1.GuildbookColumnProfession2 = GuildFrameButton1:CreateFontString('$parentGuildbookProfession2', 'OVERLAY', 'GameFontNormalSmall')
    GuildFrameButton1.GuildbookColumnProfession2:SetPoint('LEFT', GuildFrameButton1.GuildbookColumnProfession1, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
    GuildFrameButton1.GuildbookColumnProfession2:SetSize(self.GuildFrame.ColumnWidths['Profession2'], GuildFrameButton1:GetHeight())
    formatGuildFrameButton(GuildFrameButton1.GuildbookColumnProfession2, {1,1,1,1})

    GuildFrameButton1.GuildbookColumnOnline = GuildFrameButton1:CreateFontString('$parentGuildbookOnline', 'OVERLAY', 'GameFontNormalSmall')
    GuildFrameButton1.GuildbookColumnOnline:SetPoint('LEFT', GuildFrameButton1.GuildbookColumnProfession2, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
    GuildFrameButton1.GuildbookColumnOnline:SetSize(self.GuildFrame.ColumnWidths['Online'], GuildFrameButton1:GetHeight())
    formatGuildFrameButton(GuildFrameButton1.GuildbookColumnOnline, {1,1,1,1})
    
    for i = 2, 13 do
        local button = _G['GuildFrameButton'..i]
        button:ClearAllPoints()
        button:SetPoint('TOPLEFT', _G['GuildFrameButton'..(i-1)], 'BOTTOMLEFT', 0.0, 0.0)
        button:SetPoint('TOPRIGHT', _G['GuildFrameButton'..(i-1)], 'BOTTOMRIGHT', 0.0, 0.0)
        button:GetHighlightTexture():SetAllPoints(button)
    
        button.GuildbookColumnRank = button:CreateFontString('$parentGuildbookRank', 'OVERLAY', 'GameFontNormalSmall')
        button.GuildbookColumnRank:SetPoint('LEFT', _G['GuildFrameButton'..i..'Class'], 'RIGHT', -12.0, 0)
        button.GuildbookColumnRank:SetSize(self.GuildFrame.ColumnWidths['Rank'], button:GetHeight())
        formatGuildFrameButton(button.GuildbookColumnRank, {1,1,1,1})
    
        button.GuildbookColumnNote = button:CreateFontString('$parentGuildbookNote', 'OVERLAY', 'GameFontNormalSmall')
        button.GuildbookColumnNote:SetPoint('LEFT', button.GuildbookColumnRank, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
        button.GuildbookColumnNote:SetSize(self.GuildFrame.ColumnWidths['Note'], button:GetHeight())
        formatGuildFrameButton(button.GuildbookColumnNote, {1,1,1,1})
    
        button.GuildbookColumnMainSpec = button:CreateFontString('$parentGuildbookMainSpec', 'OVERLAY', 'GameFontNormalSmall')
        button.GuildbookColumnMainSpec:SetPoint('LEFT', button.GuildbookColumnNote, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
        button.GuildbookColumnMainSpec:SetSize(self.GuildFrame.ColumnWidths['MainSpec'], button:GetHeight())
        formatGuildFrameButton(button.GuildbookColumnMainSpec, {1,1,1,1})  
    
        button.GuildbookColumnProfession1 = button:CreateFontString('$parentGuildbookProfession1', 'OVERLAY', 'GameFontNormalSmall')
        button.GuildbookColumnProfession1:SetPoint('LEFT', button.GuildbookColumnMainSpec, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
        button.GuildbookColumnProfession1:SetSize(self.GuildFrame.ColumnWidths['Profession1'], button:GetHeight())
        formatGuildFrameButton(button.GuildbookColumnProfession1, {1,1,1,1})   
    
        button.GuildbookColumnProfession2 = button:CreateFontString('$parentGuildbookProfession2', 'OVERLAY', 'GameFontNormalSmall')
        button.GuildbookColumnProfession2:SetPoint('LEFT', button.GuildbookColumnProfession1, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
        button.GuildbookColumnProfession2:SetSize(self.GuildFrame.ColumnWidths['Profession2'], button:GetHeight())
        formatGuildFrameButton(button.GuildbookColumnProfession2, {1,1,1,1})   

        button.GuildbookColumnOnline = button:CreateFontString('$parentGuildbookOnline', 'OVERLAY', 'GameFontNormalSmall')
        button.GuildbookColumnOnline:SetPoint('LEFT', button.GuildbookColumnProfession2, 'RIGHT', self.GuildFrame.ColumnMarginX, 0)
        button.GuildbookColumnOnline:SetSize(self.GuildFrame.ColumnWidths['Online'], button:GetHeight())
        formatGuildFrameButton(button.GuildbookColumnOnline, {1,1,1,1})   
    end
    
    hooksecurefunc("GuildStatus_Update", function()
        local numTotal, numOnline, numOnlineAndMobile = GetNumGuildMembers()
        for i = 1, 13 do
            local button = _G['GuildFrameButton'..i]
            local idx = tonumber(button.guildIndex)
            button:Show()
            --clear text
            button.GuildbookColumnRank:SetText('')
            button.GuildbookColumnNote:SetText('')
            button.GuildbookColumnMainSpec:SetText('')
            button.GuildbookColumnProfession1:SetText('')
            button.GuildbookColumnProfession2:SetText('')
            button.GuildbookColumnOnline:SetText('')
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(idx)
            local offline = 'online'
            if isOnline == false then            
                local yearsOffline, monthsOffline, daysOffline, hoursOffline = GetGuildRosterLastOnline(idx)
                --print(string.format('%d, %s - years %s, months %s, days %s, hours %s', idx, name, yearsOffline, monthsOffline, daysOffline, hoursOffline))
                if yearsOffline and yearsOffline > 0 then
                    offline = string.format('%s years', yearsOffline)
                else
                    if monthsOffline and monthsOffline > 0 then
                        offline = string.format('%s months', monthsOffline)
                    else
                        if daysOffline and daysOffline > 0 then
                            offline = string.format('%s days', daysOffline)
                        else
                            if hoursOffline and hoursOffline > 0 then
                                offline = string.format('%s hours', hoursOffline)
                            else
                                offline = '< an hour'
                            end
                        end
                    end
                end
                --print('status, '..offline)
            end
            -- update font colours
            if isOnline == false then
                formatGuildFrameButton(button.GuildbookColumnRank, {0.5,0.5,0.5,1})
                formatGuildFrameButton(button.GuildbookColumnNote, {0.5,0.5,0.5,1})
                formatGuildFrameButton(button.GuildbookColumnMainSpec, {0.5,0.5,0.5,1})
                formatGuildFrameButton(button.GuildbookColumnProfession1, {0.5,0.5,0.5,1})
                formatGuildFrameButton(button.GuildbookColumnProfession2, {0.5,0.5,0.5,1})
                formatGuildFrameButton(button.GuildbookColumnOnline, {0.5,0.5,0.5,1})
            else
                formatGuildFrameButton(button.GuildbookColumnRank, {1,1,1,1})
                formatGuildFrameButton(button.GuildbookColumnNote, {1,1,1,1})
                formatGuildFrameButton(button.GuildbookColumnMainSpec, {1,1,1,1})
                formatGuildFrameButton(button.GuildbookColumnProfession1, {1,1,1,1})
                formatGuildFrameButton(button.GuildbookColumnProfession2, {1,1,1,1})
                formatGuildFrameButton(button.GuildbookColumnOnline, {1,1,1,1})
            end                
            --change class text colour
            _G['GuildFrameButton'..i..'Class']:SetText(string.format('%s%s|r', self.Data.Class[class].FontColour, classDisplayName))
            -- set known columns
            button.GuildbookColumnRank:SetText(rankName)    
            button.GuildbookColumnNote:SetText(publicNote)
            --offline = _G['GuildFrameGuildStatusButton'..idx..'Online']:GetText()
            button.GuildbookColumnOnline:SetText(offline)
            -- clear unknown columns
            button.GuildbookColumnMainSpec:SetText('-')
            button.GuildbookColumnProfession1:SetText('-')
            button.GuildbookColumnProfession2:SetText('-')
            -- loop local cache and update columns
            local guildName = Guildbook:GetGuildName()
            if guildName then
                if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] and next(GUILDBOOK_GLOBAL.GuildRosterCache[guildName]) then
                    if GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID] then
                        local ms, os = GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID]['MainSpec'], GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID]['OffSpec']
                        local prof1 = GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID]['Profession1']
                        local prof2 = GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID]['Profession2']
                        button.GuildbookColumnMainSpec:SetText(ms)
                        --button.GuildbookColumnMainSpec:SetText(string.format('%s %s', self.Data.SpecFontStringIconSMALL[GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID]['Class']][ms], ms))
                        button.GuildbookColumnProfession1:SetText(prof1)
                        button.GuildbookColumnProfession2:SetText(prof2)
                        -- button.GuildbookColumnProfession1:SetText(string.format('%s %s', self.Data.Profession[prof1].FontStringIconSMALL, prof1))
                        -- button.GuildbookColumnProfession2:SetText(string.format('%s %s', self.Data.Profession[prof2].FontStringIconSMALL, prof2))
                    end
                end
            end
            if Guildbook.GuildFrame.StatsFrame:IsVisible() then
                button:Hide()
            end
            if (GuildFrameLFGButton:GetChecked() == false) and(i > numOnline) then
                button:Hide()
            end
        end
    end)

    local function toggleGuildFrames(frame)
        for f, _ in pairs(Guildbook.GuildFrame.Frames) do
            _G['GuildbookGuildFrame'..f]:Hide()
        end
        if frame == 'none' then
            for i = 1, 13 do
                _G['GuildFrameButton'..i]:Show()
            end
            GuildFrameLFGFrame:Show()
        else
            for i = 1, 13 do
                _G['GuildFrameButton'..i]:Hide()
            end
            GuildFrameLFGFrame:Hide()
            Guildbook.GuildFrame[frame]:Show()
        end
    end

    self.GuildFrame.RosterButton = CreateFrame('BUTTON', 'GuildbookGuildFrameRosterButton', GuildFrame, "UIPanelButtonTemplate")
    self.GuildFrame.RosterButton:SetPoint('RIGHT', GuildFrameGuildInformationButton, 'LEFT', -2, 0)
    self.GuildFrame.RosterButton:SetSize(85, GuildFrameGuildInformationButton:GetHeight())
    self.GuildFrame.RosterButton:SetText('Guild Roster')
    self.GuildFrame.RosterButton:SetNormalFontObject(GameFontNormalSmall)
    self.GuildFrame.RosterButton:SetHighlightFontObject(GameFontNormalSmall)
    self.GuildFrame.RosterButton:SetScript('OnClick', function(self)
        GuildRoster()
        toggleGuildFrames('none')
    end)
    
    self.GuildFrame.Frames = {
        ['StatsFrame'] = { Text = 'Statistics', Width = 85.0, OffsetY = -87.0 },
        ['TradeSkillFrame'] = { Text = 'Professions', Width = 85.0, OffsetY = -174.0 },
        ['GuildBankFrame'] = { Text = 'Guild Bank', Width = 85.0, OffsetY = -261.0 },
        ['GuildCalenderFrame'] = { Text = 'Calender', Width = 75.0, OffsetY = -338.0 },
    }

    for frame, button in pairs(self.GuildFrame.Frames) do
        self.GuildFrame[frame] = CreateFrame('FRAME', tostring('GuildbookGuildFrame'..frame), GuildFrame)
        self.GuildFrame[frame]:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            bgFile = "interface/framegeneral/ui-background-marble",
            tile = true,
            tileEdge = false,
            tileSize = 200,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        self.GuildFrame[frame]:SetPoint('TOPLEFT', GuildFrame, 'TOPLEFT', 2.00, -55.0)
        self.GuildFrame[frame]:SetPoint('BOTTOMRIGHT', GuildFrame, 'TOPRIGHT', -4.00, -325.0)
        self.GuildFrame[frame]:SetFrameLevel(6)
        self.GuildFrame[frame]:Hide()

        self.GuildFrame[tostring('GuildbookGuildFrame'..frame..'Button')] = CreateFrame('BUTTON', tostring('GuildbookGuildFrame'..frame..'Button'), GuildFrame, "UIPanelButtonTemplate")
        self.GuildFrame[tostring('GuildbookGuildFrame'..frame..'Button')]:SetPoint('LEFT', Guildbook.GuildFrame.RosterButton, 'LEFT', button.OffsetY, 0)
        self.GuildFrame[tostring('GuildbookGuildFrame'..frame..'Button')]:SetSize(button.Width, GuildFrameGuildInformationButton:GetHeight())
        self.GuildFrame[tostring('GuildbookGuildFrame'..frame..'Button')]:SetText(button.Text)
        self.GuildFrame[tostring('GuildbookGuildFrame'..frame..'Button')]:SetNormalFontObject(GameFontNormalSmall)
        self.GuildFrame[tostring('GuildbookGuildFrame'..frame..'Button')]:SetHighlightFontObject(GameFontNormalSmall)
        self.GuildFrame[tostring('GuildbookGuildFrame'..frame..'Button')]:SetScript('OnClick', function(self)
            toggleGuildFrames(frame)
        end)
    end

    --134441

    self.ScanGuildBankButton = CreateFrame('BUTTON', 'GuildbookBankFrameScanBankButton', BankFrame)
    self.ScanGuildBankButton:SetPoint('TOPLEFT', BankCloseButton, 'BOTTOMRIGHT', -10, -50)
    self.ScanGuildBankButton:SetSize(60, 60)
    self.ScanGuildBankButton.background = self.ScanGuildBankButton:CreateTexture('$parentBakground', 'BACKGROUND')
    self.ScanGuildBankButton.background:SetAllPoints(self.ScanGuildBankButton)
    self.ScanGuildBankButton.background:SetTexture(136831)
    self.ScanGuildBankButton.icon = self.ScanGuildBankButton:CreateTexture('$parentBakground', 'ARTWORK')
    self.ScanGuildBankButton.icon:SetPoint('TOPLEFT', 4, -12)
    self.ScanGuildBankButton.icon:SetPoint('BOTTOMRIGHT', -28, 20)
    self.ScanGuildBankButton.icon:SetTexture(136453)
    -- self.ScanGuildBankButton:SetText('Guildbook Scan Bank')
    -- self.ScanGuildBankButton:SetNormalFontObject(GameFontNormalSmall)
    -- self.ScanGuildBankButton:SetHighlightFontObject(GameFontNormalSmall)
    self.ScanGuildBankButton:SetScript('OnClick', function(self)
        Guildbook:ScanCharacterContainers()
        PRINT(Guildbook.FONT_COLOUR, 'scanning bank, sending data to all online guild members.')
    end)
    self.ScanGuildBankButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', -28, -10)
        GameTooltip:AddLine('Guildbook: Scan bank and update online players.')
        GameTooltip:Show()
    end)
    self.ScanGuildBankButton:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    
    self:SetupStatsFrame()
    self:SetupTradeSkillFrame()
    self:SetupGuildBankFrame()
    self:SetupGuildCalenderFrame()

    -- TODO: translate old guild memer detail frame into new code style
    self.GuildMemberDetailFrame:DrawLabels()          
    self.GuildMemberDetailFrame:DrawText()

    --register the addon message prefixes
    -- TODO: migrate this to use AceComm
    local memberDetailFrameRequestPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-mdf-req')
    DEBUG('registered details request prefix: '..tostring(memberDetailFrameRequestPrefix))

    local memberDetailFrameSentPrefix = C_ChatInfo.RegisterAddonMessagePrefix('gb-mdf-data')
    DEBUG('registered details sent prefix: '..tostring(memberDetailFrameSentPrefix))

    local requestCharacterInfo = C_ChatInfo.RegisterAddonMessagePrefix('gb-char-stats')
    DEBUG('registered char data req prefix: '..tostring(requestCharacterInfo))

    AceComm:Embed(self)
    self:RegisterComm(addonName, 'ON_COMMS_RECEIVED')

    --create stored variable tables
    if GUILDBOOK_GLOBAL == nil then
        GUILDBOOK_GLOBAL = self.Data.DefaultGlobalSettings
        DEBUG('created global saved variable table')
    else
        DEBUG('global variables exists')
    end
    if GUILDBOOK_CHARACTER == nil then
        GUILDBOOK_CHARACTER = self.Data.DefaultCharacterSettings
        DEBUG('created character saved variable table')
    else
        DEBUG('character variables exists')
    end
    --added later
    if not GUILDBOOK_GLOBAL['GuildRosterCache'] then
        GUILDBOOK_GLOBAL['GuildRosterCache'] = {}
    end

    self.LOADED = true

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
            tooltip:AddLine(tostring(PRINT_COLOUR..addonName))
            tooltip:AddDoubleLine('|cffffffffLeft Click|r Options')
            tooltip:AddDoubleLine('|cffffffffRight Click|r Guild')
        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    self.MinimapIcon:Register('GuildbookMinimapIcon', self.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])
    C_Timer.After(1, function()
        if GUILDBOOK_GLOBAL['ShowMinimapButton'] == false then
            self.MinimapIcon:Hide('GuildbookMinimapIcon')
            DEBUG('minimap icon saved var setting: false, hiding minimap button')
        end
    end)


    GuildbookOptionsMainSpecDD_Init()
    GuildbookOptionsOffSpecDD_Init()

    --the OnShow event doesnt fire for the first time the options frame is shown? set the values here
    UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, GUILDBOOK_CHARACTER['MainSpec'])
    UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, GUILDBOOK_CHARACTER['OffSpec'])
    GuildbookOptionsMainCharacterNameInputBox:SetText(GUILDBOOK_CHARACTER['MainCharacter'])
    GuildbookOptionsMainSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['MainSpecIsPvP'])
    GuildbookOptionsOffSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['OffSpecIsPvP'])
    GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
    GuildbookOptionsShowMinimapButton:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])

    local version = GetAddOnMetadata('Guildbook', "Version")
    PRINT(PRINT_COLOUR, 'loaded (version '..version..')')

    if GUILDBOOK_GAMEOBJECTS then
        StaticPopup_Show('GuildbookReset')
    end

    -- allow time for loading and whats nots, then send character data
    C_Timer.After(5, function()
        Guildbook:SendCharacterStats()
    end)

end


function Guildbook:Transmit(data, channel, target, priority)
    local serialized = LibSerialize:Serialize(data);
    local compressed = LibDeflate:CompressDeflate(serialized);
    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);

    self:SendCommMessage(addonName, encoded, channel, target, priority);
end

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
        self:Transmit(response, distribution, sender, "BULK")
    end
end

function Guildbook:OnTradeSkillsReceived(data, distribution, sender)
    C_Timer.After(4.0, function()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            for guid, character in pairs(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName]) do
                if character.Name == sender then                
                    character[data.payload.profession] = data.payload.recipes
                    DEBUG('set: '..character.Name..' prof: '..data.payload.profession)
                end
            end
        end
        self.GuildFrame.TradeSkillFrame.RecipesTable = data.payload.recipes
    end)
end

function Guildbook:CharacterDataRequest(target)
    local request = {
        type = 'CHARACTER_DATA_REQUEST'
    }
    self:Transmit(request, 'WHISPER', target, 'NORMAL')
end

function Guildbook:OnCharacterDataRequested(request, distribution, sender)
    if distribution ~= 'WHISPER' then
        return
    end
    local guid = UnitGUID('player')
    local level = UnitLevel('player')
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
        self:Transmit(response, 'WHISPER', sender, 'NORMAL')
    end
end

function Guildbook:OnCharacterDataReceived(data, distribution, sender)
    local guildName = self:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
        if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID] then
            local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID]
            character.Level = tonumber(data.payload.Level)
            character.Class = data.payload.Class
            character.Name = data.payload.Name
            character.Profession1Level = tonumber(data.payload.Profession1Level)
            character.OffSpec = data.payload.OffSpec
            character.Profession1 = data.payload.Profession1
            character.MainCharacter = data.payload.MainCharacter
            character.MainSpec = data.payload.MainSpec
            character.MainSpecIsPvP = data.payload.MainSpecIsPvP
            character.Profession2Level = tonumber(data.payload.Profession2Level)
            character.Profession2 = data.payload.Profession2
            character.AttunementsKeys = data.payload.AttunementsKeys
            character.Availability = data.payload.Availability
            character.OffSpecIsPvP = data.payload.OffSpecIsPvP
        end
    end
end

function Guildbook:SendGuildBankCommitRequest(bankCharacter)
    local request = {
        type = 'GUILD_BANK_COMMIT_REQUEST',
        payload = bankCharacter,
    }
    self:Transmit(request, 'GUILD', nil, 'NORMAL')
    DEBUG('sending guild bank commit request to guild, for bank character: '..bankCharacter)
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
            DEBUG('responding to guild bank commit request, sent commit: '..GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit)
        end
    end
end

function Guildbook:OnGuildBankCommitReceived(data, distribution, sender)
    if distribution == 'WHISPER' then
        if GUILDBOOK_CHARACTER['GuildBank'] and GUILDBOOK_CHARACTER['GuildBank'][data.payload.Character] then
            if tonumber(data.payload.Commit) >= tonumber(GUILDBOOK_CHARACTER['GuildBank'][data.payload.Character].Commit) then --remove the >= should be >
                DEBUG('commit is newer than saved var commit')
                if Guildbook.GuildBankCommit['Commit'] == nil then
                    Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
                    Guildbook.GuildBankCommit['Character'] = sender
                    Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
                    DEBUG('cached first response')
                else
                    if tonumber(data.payload.Commit) > tonumber(Guildbook.GuildBankCommit['Commit']) then
                        Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
                        Guildbook.GuildBankCommit['Character'] = sender
                        Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
                        DEBUG('commit is newer than cached response')
                    end
                end
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
        DEBUG('sent request for guild bank data from: '..Guildbook.GuildBankCommit['Character'])
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
        DEBUG('sending guild bank data to: '..sender..' as requested')
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
            GUILDBOOK_CHARACTER['GuildBank'][data.payload] = {
                Commit = data.payload.Commit,
                Data = data.payload.Data,
            }
        end
    end
    self.GuildFrame.GuildBankFrame:ProcessBankData(data.payload.Data)
    self.GuildFrame.GuildBankFrame:RefreshSlots()
end

-- TODO: add script for when a player drops a prof
SkillDetailStatusBarUnlearnButton:HookScript('OnClick', function()

end)

function Guildbook:TRADE_SKILL_UPDATE()
    C_Timer.After(1, function()
        DEBUG('trade skill update, scanning skills')
        self:ScanTradeSkill()
    end)
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
                GUILDBOOK_CHARACTER['GuildBank'][name].Commit = GetServerTime()
                GUILDBOOK_CHARACTER['GuildBank'][name].Data = {}
            end

            -- player bags
            for bag = 0, 4 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local id = select(10, GetContainerItemInfo(bag, slot))
                    local count = select(2, GetContainerItemInfo(bag, slot))
                    if id and count then
                        if not GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] then
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = count
                            --print('adding first item to gb data')
                        else
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] + count
                            --print('updating item as already in data')
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
            DEBUG('sending guild bank data due to new commit')
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
            DEBUG(string.format('|cff0070DETrade item|r: %s, with ID: %s', name, itemID))
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
                        DEBUG(string.format('    Reagent name: %s, with ID: %s, Needed: %s', reagentName, reagentID, reagentCount))
                        GUILDBOOK_CHARACTER[prof][itemID][reagentID] = reagentCount
                    end
                end
            end
        end
    end
end

function Guildbook:GetGuildName()
    local guildName = false
    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        return guildName
    end
end

function Guildbook:SendCharacterStats()
    local profs = self:GetCharacterProfessions()
    local spec = self:GetCharacterSpecs()
    local guid = UnitGUID('player')
    local level = UnitLevel('player')
    if not self.PlayerMixin then
        self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        self.PlayerMixin:SetGUID(guid)
    end
    if self.PlayerMixin:IsValid() then
        local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
        local name = C_PlayerInfo.GetName(self.PlayerMixin)
        local profs = self:GetCharacterProfessions()
        local specs = self:GetCharacterSpecs()
        local guildName = self:GetGuildName()
        if guildName then
            local msg = tostring(guid..'$'..name..'$'..class..'$'..level..'$'..profs..'$'..GUILDBOOK_CHARACTER['MainCharacter']..'$'..specs..'$'..guildName)
            ChatThrottleLib:SendAddonMessage("NORMAL",  "gb-char-stats", msg, "GUILD")
        end
    end
end

--TODO: add func to drop prof if a player deletes a prof
function Guildbook:GetCharacterProfessions()
    local myCharacter = { Fishing = 0, Cooking = 0, FirstAid = 0, Prof1 = '-', Prof1Level = 0, Prof2 = '-', Prof2Level = 0 }
    for s = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)
        if skill == 'Fishing' then 
            myCharacter.Fishing = level
        elseif skill == 'Cooking' then
            myCharacter.Cooking = level
        elseif skill == 'First Aid' then
            myCharacter.FirstAid = level
        else
            for k, prof in pairs(Guildbook.Data.Profession) do
                if skill == prof.Name then
                    if myCharacter.Prof1 == '-' then
                        myCharacter.Prof1 = skill
                        myCharacter.Prof1Level = level
                    elseif myCharacter.Prof2 == '-' then
                        myCharacter.Prof2 = skill
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
    local prof1Id = self.Data.ProfToID[myCharacter.Prof1]
    local prof2Id = self.Data.ProfToID[myCharacter.Prof2]
    return string.format('%s$%s$%s$%s$%s$%s$%s', myCharacter.Fishing, myCharacter.Cooking, myCharacter.FirstAid, prof1Id, myCharacter.Prof1Level, prof2Id, myCharacter.Prof2Level)
end

function Guildbook:GetCharacterSpecs()
    local ms = self.Data.SpecToID[GUILDBOOK_CHARACTER['MainSpec']]
    local os = self.Data.SpecToID[GUILDBOOK_CHARACTER['OffSpec']]
    local mspvp, ospvp = 0, 0
    if GUILDBOOK_CHARACTER['MainSpecIsPvP'] == true then
        mspvp = 1
    end
    if GUILDBOOK_CHARACTER['OffSpecIsPvP'] == true then
        ospvp = 1
    end
    return string.format('%s$%s$%s$%s', ms, os, mspvp, ospvp)
end

function Guildbook:ParseCharacterData_OLD(msg)
    if not GUILDBOOK_GLOBAL['GuildRosterCache'] then
        GUILDBOOK_GLOBAL['GuildRosterCache'] = {}
    end
    local i, t = 1, {}
    for d in string.gmatch(msg, '[^$]+') do
        t[Guildbook.CharDataMsgkeys[i]] = d
        i = i + 1
    end
    local guildName = t['guildname']
    if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] = {}
    end
    --convert values back
    local prof1 = self.Data.ProfFromID[t['prof1']]
    local prof2 = self.Data.ProfFromID[t['prof2']]
    local ms = self.Data.SpecFromID[t['mainspec']]
    local os = self.Data.SpecFromID[t['offspec']]
    local mspvp, ospvp = false, false
    if GUILDBOOK_CHARACTER['MainSpecIsPvP'] == 1 then
        mspvp = true
    end
    if GUILDBOOK_CHARACTER['OffSpecIsPvP'] == 1 then
        ospvp = true
    end
    if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']] then
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']] = {
            Name = t['name'],
            Class = t['class'],
            Level = tonumber(t['level']),
            MainSpec = ms,
            OffSpec = os,
            MainSpecIsPvP = mspvp,
            OffSpecIsPvP = ospvp,
            Profession1 = prof1,
            Profession1Level = tonumber(t['prof1level']),
            Profession2 = prof2,
            Profession2Level = tonumber(t['prof2level']),
            MainCharacter = t['main'],
            FishingLevel = tonumber(t['fishing']),
            CookingLevel = tonumber(t['cooking']),
            FirstAidLevek = tonumber(t['firstaid']),
        }
    else
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].Name = t['name']
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].Class = t['class']
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].Level = tonumber(t['level'])
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].MainSpec = ms
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].OffSpec = os
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].MainSpecIsPvP = mspvp
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].OffSpecIsPvP = ospvp
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].Profession1 = prof1
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].Profession1Level = tonumber(t['prof1level'])
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].Profession2 = prof2
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].Profession2Level = tonumber(t['prof2level'])
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].MainCharacter = t['main']
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].FishingLevel = tonumber(t['fishing'])
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].CookingLevel = tonumber(t['cooking'])
        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][t['guid']].FirstAidLevel = tonumber(t['firstaid'])
    end
end

-- events
function Guildbook:ADDON_LOADED(...)
    if tostring(...):lower() == addonName:lower() then
        self:Init()
    end
end

function Guildbook:GUILD_ROSTER_UPDATE(...)
    if GuildMemberDetailFrame:IsVisible() then     
        self.GuildMemberDetailFrame:HandleRosterUpdate()
    end
end

function Guildbook:CHAT_MSG_ADDON(...)
    local prefix = select(1, ...)
    local msg = select(2, ...)
    local sender = select(5, ...)
    if string.find(prefix, 'mdf') then
        DEBUG('member detail frame msg event')
        self.GuildMemberDetailFrame:HandleAddonMessage(...)
    elseif prefix == 'gb-char-stats' then
        DEBUG('character stats msg event')
        self:ParseCharacterData_OLD(msg)
    end
end

function Guildbook:PLAYER_LEVEL_UP()
    C_Timer.After(3, function()
        self:SendCharacterStats()
    end)
end

function Guildbook:SKILL_LINES_CHANGED()
    C_Timer.After(3, function()
        DEBUG('sending char data due to skill line event')
        self:SendCharacterStats()
    end)
end

local tradeDelay, bankDelay = 10, 10
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
            DEBUG(string.format('please allow 10 secs between requests, %d seconds remaining', remaining))
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
        if lastGuildBankRequest[sender] + tradeDelay < GetTime() then
            self:OnTradeSkillsRequested(data, distribution, sender)
            lastGuildBankRequest[sender] = GetTime()
        else
            local remaining = string.format("%.1d", (lastGuildBankRequest[sender] + tradeDelay - GetTime()))
            DEBUG(string.format('please allow 10 secs between requests, %d seconds remaining', remaining))
        end
        self:OnGuildBankDataRequested(data, distribution, sender)
    elseif data.type == 'GUILD_BANK_DATA_RESPONSE' then
        self:OnGuildBankDataReceived(data, distribution, sender)
    end
end

--set up event listener
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('CHAT_MSG_ADDON')
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('PLAYER_LEVEL_UP')
Guildbook.EventFrame:RegisterEvent('SKILL_LINES_CHANGED')
Guildbook.EventFrame:RegisterEvent('TRADE_SKILL_UPDATE')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    --DEBUG('EVENT='..tostring(event))
    Guildbook[event](Guildbook, ...)
end)