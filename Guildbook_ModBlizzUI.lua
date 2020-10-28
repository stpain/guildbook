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

]==]

local addonName, Guildbook = ...

--set constants
local FRIENDS_FRAME_WIDTH = FriendsFrame:GetWidth()
local GUILD_FRAME_WIDTH = GuildFrame:GetWidth()
local GUILD_INFO_FRAME_WIDTH = GuildInfoFrame:GetWidth()
local GUILD_MEMBER_DETAIL_FRAME_WIDTH = GuildMemberDetailFrame:GetWidth()
local GUILD_INFORMATION_BUTTON_WIDTH = GuildFrameGuildInformationButton:GetWidth()
C_Timer.After(5, function() 
    GuildFrameGuildInformationButton:ClearAllPoints()
    GuildFrameGuildInformationButton:SetPoint('RIGHT', GuildFrameAddMemberButton, 'LEFT', -2.0, 0)
    GuildFrameGuildInformationButton:SetWidth(GUILD_INFORMATION_BUTTON_WIDTH)
end)
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

function Guildbook:ModBlizzUI()

    -- experimental stuff
    GuildMemberDetailFrame:SetWidth(GUILD_MEMBER_DETAIL_FRAME_WIDTH + 120)
    GuildMemberRemoveButton:SetWidth((GUILD_MEMBER_DETAIL_FRAME_WIDTH + 100) / 2)
    GuildMemberGroupInviteButton:SetWidth((GUILD_MEMBER_DETAIL_FRAME_WIDTH + 100) / 2)
    for k, v in pairs({GuildMemberDetailFrame:GetRegions()}) do
        if v:GetObjectType() == 'Texture' then
            if v:GetTexture() and v:GetTexture():lower() == 'interface\\friendsframe\\ui-guildmember-patch' then
                v:Hide()
            end
        end
    end
    local w = GuildMemberNoteBackground:GetWidth()
    GuildMemberNoteBackground:SetWidth(w * 1.65)
    w = PersonalNoteText:GetWidth()
    PersonalNoteText:SetWidth(w * 1.65)

    local w = GuildMemberOfficerNoteBackground:GetWidth()
    GuildMemberOfficerNoteBackground:SetWidth(w * 1.65)
    w = OfficerNoteText:GetWidth()
    OfficerNoteText:SetWidth(w * 1.65)

    -- adjust blizz layout and add widgets
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

    -- because elvui alters the column order we just need to know if its loaded to then adjust anchor point
    local anchor = IsAddOnLoaded('ElvUI') and GuildFrameColumnHeader2 or GuildFrameColumnHeader4
    for k, col in ipairs(self.GuildFrame.ColumnHeaders) do
        local tab = CreateFrame('BUTTON', 'GuildbookGuildFrameColumnHeader'..col.Text, GuildFrame)--, "OptionsFrameTabButtonTemplate")
        if col.Text == 'Rank' then
            tab:SetPoint('LEFT', anchor, 'RIGHT', -2.0, 0.0)
        else
            tab:SetPoint('LEFT', self.GuildFrame.ColumnTabs[k-1], 'RIGHT', -2.0, 0.0)
        end
        tab:SetSize(col.Width, GuildFrameColumnHeader4:GetHeight())
        tab.text = tab:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        tab.text:SetPoint('LEFT', tab, 'LEFT', 8.0, 0.0)
        tab.text:SetText(col.Text)
        tab.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
        tab.text:SetTextColor(1,1,1,1)
        --if elvui == false then
            tab.background = tab:CreateTexture('$parentBackground', 'BACKGROUND')
            tab.background:SetAllPoints(tab)
            tab.background:SetTexture(131139)
            tab.background:SetTexCoord(0.0, 0.00, 0.0 ,0.75, 0.97, 0.0, 0.97, 0.75)
        --end
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
    
    local x = IsAddOnLoaded('ElvUI') and 86.0 or 7.0
    for i = 1, 13 do
        -- adjust Name column position
        _G['GuildFrameButton'..i..'Name']:ClearAllPoints()
        _G['GuildFrameButton'..i..'Name']:SetPoint('TOPLEFT', _G['GuildFrameButton'..i], 'TOPLEFT', x, -3.0)
        -- hook the click event
        _G['GuildFrameButton'..i]:HookScript('OnClick', function(self, button)
            if (button == 'LeftButton') and (GuildMemberDetailFrame:IsVisible()) then
                local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(GetGuildRosterSelection())
                if isOnline then
                    Guildbook:UpdateGuildMemberDetailFrameLabels()
                    Guildbook:ClearGuildMemberDetailFrame()
                    Guildbook.GuildMemberDetailFrame.CurrentMemberGUID = nil
                    Guildbook:CharacterDataRequest(name)
                end
            end
        end)
    end
    
    local function formatGuildFrameButton(button, col)
        --button:SetFont("Fonts\\FRIZQT__.TTF", 10)
        button:SetJustifyH('LEFT')
        button:SetTextColor(col[1], col[2], col[3], col[4])
    end
    
    local anchor = IsAddOnLoaded('ElvUI') and GuildFrameButton1Zone or GuildFrameButton1Class
    local x = IsAddOnLoaded('ElvUI') and 12.0 or -12.0
    GuildFrameButton1.GuildbookColumnRank = GuildFrameButton1:CreateFontString('$parentGuildbookRank', 'OVERLAY', 'GameFontNormalSmall')
    GuildFrameButton1.GuildbookColumnRank:SetPoint('LEFT', anchor, 'RIGHT', x, 0)
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
        local anchor = IsAddOnLoaded('ElvUI') and _G['GuildFrameButton'..i..'Zone'] or _G['GuildFrameButton'..i..'Class']
        local button = _G['GuildFrameButton'..i]
        button:ClearAllPoints()
        button:SetPoint('TOPLEFT', _G['GuildFrameButton'..(i-1)], 'BOTTOMLEFT', 0.0, 0.0)
        button:SetPoint('TOPRIGHT', _G['GuildFrameButton'..(i-1)], 'BOTTOMRIGHT', 0.0, 0.0)
        button:GetHighlightTexture():SetAllPoints(button)
    
        local x = IsAddOnLoaded('ElvUI') and 12.0 or -12.0
        button.GuildbookColumnRank = button:CreateFontString('$parentGuildbookRank', 'OVERLAY', 'GameFontNormalSmall')
        button.GuildbookColumnRank:SetPoint('LEFT', anchor, 'RIGHT', x, 0)
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
            if class and classDisplayName then
                _G['GuildFrameButton'..i..'Class']:SetText(string.format('%s%s|r', self.Data.Class[class].FontColour, classDisplayName))
            end
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
            SortGuildRoster('Online')
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
    self.GuildFrame.RosterButton:SetSize(65, GuildFrameGuildInformationButton:GetHeight())
    self.GuildFrame.RosterButton:SetText('Roster')
    self.GuildFrame.RosterButton:SetNormalFontObject(GameFontNormalSmall)
    self.GuildFrame.RosterButton:SetHighlightFontObject(GameFontNormalSmall)
    self.GuildFrame.RosterButton:SetScript('OnClick', function(self)
        GuildRoster()
        toggleGuildFrames('none')
    end)
    
    self.GuildFrame.Frames = {
        ['StatsFrame'] = { Text = 'Statistics', Width = 76.0, OffsetY = -79.0 },
        ['TradeSkillFrame'] = { Text = 'Professions', Width = 85.0, OffsetY = -166.0 },
        ['GuildBankFrame'] = { Text = 'Guild Bank', Width = 85.0, OffsetY = -253.0 },
        ['GuildCalendarFrame'] = { Text = 'Calendar', Width = 75.0, OffsetY = -330.0 },
        ['SoftReserveFrame'] = { Text = 'Soft Res', Width = 70.0, OffsetY = -402.0 },
    }

    for frame, button in pairs(self.GuildFrame.Frames) do
        self.GuildFrame[frame] = CreateFrame('FRAME', tostring('GuildbookGuildFrame'..frame), GuildFrame)
        self.GuildFrame[frame]:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            bgFile = "interface/framegeneral/ui-background-marble",
            tile = true,
            tileEdge = false,
            tileSize = 300,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        self.GuildFrame[frame]:SetPoint('TOPLEFT', GuildFrame, 'TOPLEFT', 2.00, -55.0)
        if frame == 'GuildCalendarFrame' or frame == 'GuildBankFrame' or frame == 'SoftReserveFrame' then
            self.GuildFrame[frame]:SetPoint('BOTTOMRIGHT', GuildFrame, 'BOTTOMRIGHT', -4.00, 25.0)
        else
            self.GuildFrame[frame]:SetPoint('BOTTOMRIGHT', GuildFrame, 'BOTTOMRIGHT', -4.00, 25.0)
            --self.GuildFrame[frame]:SetPoint('BOTTOMRIGHT', GuildFrame, 'TOPRIGHT', -4.00, -325.0)
        end        
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

    self.ScanGuildBankButton = CreateFrame('BUTTON', 'GuildbookBankFrameScanBankButton', BankFrame)
    self.ScanGuildBankButton:SetPoint('TOPLEFT', BankCloseButton, 'BOTTOMRIGHT', -10, -50)
    self.ScanGuildBankButton:SetSize(60, 60)
    self.ScanGuildBankButton.background = self.ScanGuildBankButton:CreateTexture('$parentBackground', 'BACKGROUND')
    self.ScanGuildBankButton.background:SetAllPoints(self.ScanGuildBankButton)
    self.ScanGuildBankButton.background:SetTexture(136831)
    self.ScanGuildBankButton.icon = self.ScanGuildBankButton:CreateTexture('$parentBackground', 'ARTWORK')
    self.ScanGuildBankButton.icon:SetPoint('TOPLEFT', 4, -12)
    self.ScanGuildBankButton.icon:SetPoint('BOTTOMRIGHT', -28, 20)
    self.ScanGuildBankButton.icon:SetTexture(136453)
    self.ScanGuildBankButton:SetScript('OnClick', function(self)
        Guildbook:ScanCharacterContainers()
    end)
    self.ScanGuildBankButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', -28, -10)
        GameTooltip:AddLine('Guildbook: Scan bank and update online players.')
        GameTooltip:Show()
    end)
    self.ScanGuildBankButton:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    
end