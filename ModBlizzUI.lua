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
local L = Guildbook.Locales

--set constants
local ROSTER_VISIBLE = true
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
        { Text = 'MainSpec', Width = 100, },
        { Text = 'Profession1', Width = 90, },
        { Text = 'Profession2', Width = 90, },
        { Text = 'Online', Width = 65, },
    },
    ColumnTabs = {},
    ColumnWidths = {
        Rank = 67.0,
        Note = 77.0,
        MainSpec = 97.0,
        Profession1 = 87.0,
        Profession2 = 87.0,
        Online = 52.0,
    },
    ColumnMarginX = 1.0,
}


function Guildbook:ModBlizzUI()

    -- adjust blizz layout and add widgets
    GuildFrameGuildListToggleButton:Hide()

    GuildFrame:HookScript('OnShow', function(self)
        self:SetWidth(830)
        FriendsFrame:SetWidth(830)
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
        tab.text = tab:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        tab.text:SetPoint('LEFT', tab, 'LEFT', 8.0, 0.0)
        tab.text:SetText(L[col.Text])
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
    end
    
    local function formatGuildFrameButton(button, col)
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
            local offline = L['Online']
            if isOnline == false then            
                local yearsOffline, monthsOffline, daysOffline, hoursOffline = GetGuildRosterLastOnline(idx)
                if yearsOffline and yearsOffline > 0 then
                    offline = string.format('%s %s', yearsOffline, L["YEARS"])
                else
                    if monthsOffline and monthsOffline > 0 then
                        offline = string.format('%s %s', monthsOffline, L["MONTHS"])
                    else
                        if daysOffline and daysOffline > 0 then
                            offline = string.format('%s %s', daysOffline, L["DAYS"])
                        else
                            if hoursOffline and hoursOffline > 0 then
                                offline = string.format('%s %s', hoursOffline, L["HOURS"])
                            else
                                offline = L['< an hour']
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
                if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] and GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID] then
                    local character = GUILDBOOK_GLOBAL.GuildRosterCache[guildName][GUID]
                    button.GuildbookColumnMainSpec:SetText(character.MainSpec)
                    button.GuildbookColumnProfession1:SetText(character.Profession1)
                    button.GuildbookColumnProfession2:SetText(character.Profession2)
                else
                    button.GuildbookColumnMainSpec:SetText('-')
                    button.GuildbookColumnProfession1:SetText('-')
                    button.GuildbookColumnProfession2:SetText('-')           
                end
            end
            if (GuildFrameLFGButton:GetChecked() == false) and(i > numOnline) then
                button:Hide()
            end
        end
    end)
    
end
