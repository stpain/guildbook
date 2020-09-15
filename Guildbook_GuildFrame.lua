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

--guild frame member detail frame extension
--adds spec and prof data to the detail frame

local addonName, Guildbook = ...

local LibGraph = LibStub("LibGraph-2.0");

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG
local PRINT = Guildbook.PRINT


function Guildbook:SetupStatsFrame()

    self.GuildFrame.StatsFrame.Header = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.Header:SetPoint('TOPLEFT', Guildbook.GuildFrame.StatsFrame, 'TOPLEFT', 16, -16)
    self.GuildFrame.StatsFrame.Header:SetText('Class and Role Summary')
    self.GuildFrame.StatsFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.StatsFrame.MinLevelSlider = CreateFrame('SLIDER', 'GuildbookGuildInfoFrameminLevelSlider', self.GuildFrame.StatsFrame, 'OptionsSliderTemplate')
    self.GuildFrame.StatsFrame.MinLevelSlider:SetPoint('TOPLEFT', 35, -80)
    self.GuildFrame.StatsFrame.MinLevelSlider:SetThumbTexture("Interface/Buttons/UI-SliderBar-Button-Horizontal")
    self.GuildFrame.StatsFrame.MinLevelSlider:SetSize(125, 16)
    self.GuildFrame.StatsFrame.MinLevelSlider:SetOrientation('HORIZONTAL')
    self.GuildFrame.StatsFrame.MinLevelSlider:SetMinMaxValues(1, 60) 
    self.GuildFrame.StatsFrame.MinLevelSlider:SetValueStep(1.0)
    _G[Guildbook.GuildFrame.StatsFrame.MinLevelSlider:GetName()..'Low']:SetText('1')
    _G[Guildbook.GuildFrame.StatsFrame.MinLevelSlider:GetName()..'High']:SetText('60')
    self.GuildFrame.StatsFrame.MinLevelSlider:SetValue(60)
    self.GuildFrame.StatsFrame.MinLevelSlider:SetScript('OnValueChanged', function(self)
        --print(math.floor(self:GetValue()))
        Guildbook.GuildFrame.StatsFrame:GetClassRoleFromCache()
    end)
    self.GuildFrame.StatsFrame.MinLevelSlider.tooltipText = 'Show data for characters with a minimun level'
    self.GuildFrame.StatsFrame.MinLevelSlider_Title = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameminLevelTitle', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.MinLevelSlider_Title:SetPoint('BOTTOM', self.GuildFrame.StatsFrame.MinLevelSlider, 'TOP', 0, 5)
    self.GuildFrame.StatsFrame.MinLevelSlider_Title:SetText('Character min level')

    self.GuildFrame.StatsFrame.ClassCount = {
        { Class = 'DEATHKNIGHT', Count = 0 },
        { Class = 'DRUID', Count = 0 },
        { Class = 'HUNTER', Count = 0 },
        { Class = 'MAGE', Count = 0 },
        { Class = 'PALADIN', Count = 0 },
        { Class = 'PRIEST', Count = 0 },
        { Class = 'ROGUE', Count = 0 },
        { Class = 'SHAMAN', Count = 0 },
        { Class = 'WARLOCK', Count = 0},
        { Class = 'WARRIOR', Count  = 0 },
    }

    local segCol = 0.66 --adjustment % of class colours
    self.GuildFrame.StatsFrame.ClassSummaryPieChart = LibGraph:CreateGraphPieChart('GuildbookClassSummaryCountChart', self.GuildFrame.StatsFrame, 'BOTTOMRIGHT', 'BOTTOMRIGHT', -15, 15, 180, 180)
    self.GuildFrame.StatsFrame.ClassHeader = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameClassHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.ClassHeader:SetPoint('BOTTOM', Guildbook.GuildFrame.StatsFrame.ClassSummaryPieChart, 'TOP', 0, 2)
    self.GuildFrame.StatsFrame.ClassHeader:SetText('Classes')
    self.GuildFrame.StatsFrame.ClassHeader:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.ClassHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)
    local function classSummaryPieChart_SelectionFunc(_, segment)
        if type(segment) == 'number' and segment > 0 and segment < 11 then
            GameTooltip:SetOwner(self.GuildFrame.StatsFrame, 'ANCHOR_CURSOR')
            --GameTooltip:AddLine('|cffffffffClass Info|r')
            GameTooltip:AddDoubleLine('|cffffffff'..self.GuildFrame.StatsFrame.ClassCount[segment].Class..'|r', self.GuildFrame.StatsFrame.ClassCount[segment].Count)
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end
    self.GuildFrame.StatsFrame.ClassSummaryPieChart:SetSelectionFunc(classSummaryPieChart_SelectionFunc)
    for k, class in pairs(self.GuildFrame.StatsFrame.ClassCount) do
        local r, g, b = unpack(Guildbook.Data.Class[class.Class].RGB)
        self.GuildFrame.StatsFrame.ClassSummaryPieChart:AddPie(10, {r*segCol, g*segCol, b*segCol});
    end
    self.GuildFrame.StatsFrame.ClassSummaryPieChart:CompletePie({0,0,0})
    
    self.GuildFrame.StatsFrame.Roles = {
		Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
		Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
		Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
        Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 },
    }
    self.GuildFrame.StatsFrame.RoleCharts = {}
    local roles = { 'Tank', 'Melee', 'Healer', 'Ranged' }
    for i = 1, 4 do
        local role = roles[i]
        local chart = LibGraph:CreateGraphPieChart('GuildbookTankPieChart', self.GuildFrame.StatsFrame, 'BOTTOMLEFT', 'BOTTOMLEFT', (25 + ((i - 1) * 100)), 30, 90, 90)
        local title = self.GuildFrame.StatsFrame:CreateFontString('$parentRolePieChartTitle', 'OVERLAY', 'GameFontNormal')
        title:SetPoint('TOP', chart, 'BOTTOM', 0, -5)
        title:SetText(role)
        local deg = 0
        if role == 'Tank' or role == 'Healer' then
            deg = 4
        else
            deg = 6
        end
        for class, count in pairs(self.GuildFrame.StatsFrame.Roles[role]) do
            local r, g, b = unpack(Guildbook.Data.Class[class].RGB)
            chart:AddPie((100 / deg), {r*segCol, g*segCol, b*segCol})
        end
        self.GuildFrame.StatsFrame.RoleCharts[role] = chart
    end
    self.GuildFrame.StatsFrame.RoleHeader = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameRoleHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.RoleHeader:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.StatsFrame.RoleCharts['Tank'], 'TOPLEFT', 0, 10)
    self.GuildFrame.StatsFrame.RoleHeader:SetText('Roles')
    self.GuildFrame.StatsFrame.RoleHeader:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.RoleHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    function self.GuildFrame.StatsFrame:ResetClassCount()
        for k, v in ipairs(self.ClassCount) do
            v.Count = 0
        end
        self.ClassSummaryPieChart:ResetPie()
    end
    
    --currently just calling blizz api - maybe use local cache?
    function self.GuildFrame.StatsFrame:UpdateClassChart()
        self:ResetClassCount()
        GuildRoster()
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            if class then
                for k, v in ipairs(self.ClassCount) do
                    if v.Class == class:upper() then
                        v.Count = v.Count + 1
                    end
                end
            end
        end
        table.sort(self.ClassCount, function(a, b) 
            if a.Count == b.Count then
                return a.Class > b.Class
            else
                return a.Count < b.Count
            end
        end)
        for k, v in ipairs(self.ClassCount) do
            local r, g, b = unpack(Guildbook.Data.Class[v.Class].RGB)
            self.ClassSummaryPieChart:AddPie(tonumber((v.Count / totalMembers) * 100), {r*segCol, g*segCol, b*segCol});
        end
        Guildbook.GuildFrame.StatsFrame.ClassSummaryPieChart:CompletePie({0,0,0})
    end

    function self.GuildFrame.StatsFrame:GetClassRoleFromCache()
        local guildName = Guildbook:GetGuildName()
        if guildName then
            if GUILDBOOK_GLOBAL then
                if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
                    GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] = {}
                    PRINT(Guildbook.FONT_COLOUR, 'local guild cache data not available, db created please wait for other players to send data')
                    return
                end
                if next(GUILDBOOK_GLOBAL.GuildRosterCache[guildName]) then
                    self.Roles = {
                        Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
                        Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
                        Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
                        Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 }
                    }
                    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guildName]) do
                        if character.MainSpec ~= '-' then
                            if tonumber(character.Level) >= self.MinLevelSlider:GetValue() then
                                self.Roles[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]][character.Class] = self.Roles[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]][character.Class] + 1
                            end
                        end
                    end
                    for role, classes in pairs(self.Roles) do
                        self.RoleCharts[role]:ResetPie()
                        local total = 0
                        for class, count in pairs(classes) do
                            total = total + count
                        end
                        if total > 0 then
                            for class, count in pairs(classes) do
                                if count > 0 then
                                    self.RoleCharts[role]:AddPie((count/total) * 100, Guildbook.Data.Class[class].RGB)
                                end
                            end
                            self.RoleCharts[role]:CompletePie({0,0,0})
                        end
                    end
                end
            end
        end
    end


    self.GuildFrame.StatsFrame:SetScript('OnShow', function(self)
        self:GetClassRoleFromCache()
        self:UpdateClassChart()
    end)
    
end



function Guildbook:SetupTradeSkillFrame()

    self.GuildFrame.TradeSkillFrame.SelectedCharacter = nil
    self.GuildFrame.TradeSkillFrame.SelectedProfession = nil

    self.GuildFrame.TradeSkillFrame.Header = self.GuildFrame.TradeSkillFrame:CreateFontString('GuildbookGuildInfoFrameTradeSkillFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.TradeSkillFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.TradeSkillFrame, 'TOP', 0, 4)
    self.GuildFrame.TradeSkillFrame.Header:SetText('Trade Skills')
    self.GuildFrame.TradeSkillFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.TradeSkillFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.TradeSkillFrame.ProfessionIcon = self.GuildFrame.TradeSkillFrame:CreateTexture('$parentProfIcon', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.ProfessionIcon:SetPoint('TOPLEFT', 8, -8)
    self.GuildFrame.TradeSkillFrame.ProfessionIcon:SetSize(40, 40)

    self.GuildFrame.TradeSkillFrame.ProfessionDescription = self.GuildFrame.TradeSkillFrame:CreateFontString('GuildbookGuildInfoFrameTradeSkillFrameProfessionDescription', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetPoint('TOPLEFT', self.GuildFrame.TradeSkillFrame.ProfessionIcon, 'TOPRIGHT', 4, 6)
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetSize(730, 50)
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('Trade Skills')
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetTextColor(1,1,1,1)

    --130968
    self.GuildFrame.TradeSkillFrame.TopBorder = self.GuildFrame.TradeSkillFrame:CreateTexture('GuildbookGuildInfoFrameTradeSkillFrameTopBorder', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.TopBorder:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPLEFT', 4, -50)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetPoint('TOPRIGHT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPRIGHT', -4, -50)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetHeight(10)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetTexture(130968)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetTexCoord(0.1, 1.0, 0.0, 0.3)


    local profButtonPosY = 0
    for i = 10, 1, -1 do
        local prof = Guildbook.Data.Professions[i]
        if prof.TradeSkill == true then
            local f = CreateFrame('BUTTON', 'GuildbookTradeSkillFrameProfessionButton'..prof.Name, self.GuildFrame.TradeSkillFrame, "UIPanelButtonTemplate")
            f:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'BOTTOMLEFT', 6, profButtonPosY + 4)
            f:SetSize(120, 22)
            f:SetText(prof.Name)
            f:SetNormalFontObject(GameFontNormalSmall)
            f:SetHighlightFontObject(GameFontNormalSmall)
            f:SetScript('OnClick', function(self)
                Guildbook.GuildFrame.TradeSkillFrame:ClearCharactersListeview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearCharactersListeview()
                Guildbook.GuildFrame.TradeSkillFrame.SelectedProfession = prof.Name
                Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValue(1)
                Guildbook.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof.Name)
                Guildbook.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearRecipesListeview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionIcon:SetTexture(Guildbook.Data.Profession[prof.Name].Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText(Guildbook.Data.ProfessionDescriptions[prof.Name])
                DEBUG('selected '..prof.Name)
                Guildbook.GuildFrame.TradeSkillFrame.UpdateRowBackground(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows)
                Guildbook.GuildFrame.TradeSkillFrame.UpdateRowBackground(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
            end)
            profButtonPosY = profButtonPosY + 21
        end
    end

    local listviewConfig = {
        Rows = {},
        HoverColour = {0.5,0.55,1.0,0.3},
        SelectedColour = {1.0,0.88,0.21,0.3},
        BackgroundColour_Odd = {0.2,0.2,0.2,0.3},
        BackgroundColour_Even = {0.2,0.2,0.2,0.1},
    }

    self.GuildFrame.TradeSkillFrame.CharactersWithProf = {'test'}
    self.GuildFrame.TradeSkillFrame.CharactersListviewRows = {}
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameCharactersListviewParent', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'BOTTOMLEFT', 125, 4)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent:SetSize(136, 210)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.background = self.GuildFrame.TradeSkillFrame.CharactersListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.background:SetAllPoints(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop = self.GuildFrame.TradeSkillFrame.CharactersListviewParent:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'TOPRIGHT', -1, 2)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetSize(30, 180)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.7)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom = self.GuildFrame.TradeSkillFrame.CharactersListviewParent:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'BOTTOMRIGHT', -2, 0)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.4)

    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameCharactersListviewScrollBar', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, "UIPanelScrollBarTemplate")
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'TOPRIGHT', 28, -17)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'BOTTOMRIGHT', 0, 16)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValueStep(1)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValue(1)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
    end)

    -- create characters with prof listview
    for i = 1, 10 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameCharactersListviewRow'..i), self.GuildFrame.TradeSkillFrame.CharactersListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'TOPLEFT', 0, (i - 1) * -21)
        f:SetSize(self.GuildFrame.TradeSkillFrame.CharactersListviewParent:GetWidth(), 20)
        f:EnableMouse(true)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.leftBackground = f:CreateTexture('$parentLeftBackground', 'BACKGROUND')
        f.leftBackground:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
        f.leftBackground:SetPoint('BOTTOMRIGHT', f, 'BOTTOMLEFT', (self.GuildFrame.TradeSkillFrame.CharactersListviewParent:GetWidth() / 2), 0)
        f.rightBackground = f:CreateTexture('$parentRightBackground', 'BACKGROUND')
        f.rightBackground:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 0, 0)
        f.rightBackground:SetPoint('BOTTOMLEFT', f, 'BOTTOMRIGHT', (self.GuildFrame.TradeSkillFrame.CharactersListviewParent:GetWidth() / 2) * -1, 0)
        f.id = i
        f.selected = false
        f.data = nil
        if f.id % 2 == 0 then
            f.leftBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Even))
            f.rightBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Even))
        else
            f.leftBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Odd))
            f.rightBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Odd))
        end
        f:SetScript('OnMouseDown', function(self)
            for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows) do
                v.selected = false
            end
            self.selected = not self.selected
            if self.data then
                Guildbook.GuildFrame.TradeSkillFrame.SelectedCharacter = self.data.Name
                DEBUG('selected '..self.data.Name)
                Guildbook.GuildFrame.TradeSkillFrame:RefreshRecipesListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
            end
        end)
        f:SetScript('OnMouseUp', function(self)
            Guildbook.GuildFrame.TradeSkillFrame.UpdateRowBackground(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows)
        end)
        f:SetScript('OnEnter', function(self)
            if self.selected == true then
                f.leftBackground:SetColorTexture(unpack(listviewConfig.SelectedColour))
                f.rightBackground:SetColorTexture(unpack(listviewConfig.SelectedColour))
            else
                f.leftBackground:SetColorTexture(unpack(listviewConfig.HoverColour))
                f.rightBackground:SetColorTexture(unpack(listviewConfig.HoverColour))
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                self.Text:SetText(self.data.Name)
            end
        end)
        f:SetScript('OnHide', function(self)
            self.data = nil
            self.Text:SetText(' ')
        end)
        f:SetScript('OnLeave', function(self)
            Guildbook.GuildFrame.TradeSkillFrame.UpdateRowBackground(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows)
        end)
        self.GuildFrame.TradeSkillFrame.CharactersListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame.UpdateRowBackground(listview)
        for k, f in ipairs(listview) do
            if f.selected == true then
                f.leftBackground:SetColorTexture(unpack(listviewConfig.SelectedColour))
                f.rightBackground:SetColorTexture(unpack(listviewConfig.SelectedColour))
            else
                if f.id % 2 == 0 then
                    f.leftBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Even))
                    f.rightBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Even))
                else
                    f.leftBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Odd))
                    f.rightBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Odd))
                end
            end
        end
    end

    function self.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof)
        DEBUG('getting players with prof '..prof)
        local guildName = Guildbook:GetGuildName()
        if guildName then
            wipe(self.CharactersWithProf)
            for guid, character in pairs(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName]) do
                if (character.Profession1 == prof) or (character.Profession2 == prof) then
                    DEBUG('found matching profession with '..character.Name)
                    table.insert(self.CharactersWithProf, {
                        Name = character.Name,
                    })
                    DEBUG('added '..character.Name..' to list')
                end
                if prof == 'Cooking' and tonumber(character.Cooking) > 0.0 then
                    table.insert(self.CharactersWithProf, {
                        Name = character.Name,
                    })
                    DEBUG('added '..character.Name..' to list')
                end
            end
            
            -- for testing
            -- for x = 1, 20 do
            --     table.insert(self.CharactersWithProf, {
            --         Name = tostring('test '..x),
            --     })
            -- end


            local c = #self.CharactersWithProf
            if c <= 10 then
                self.CharactersListviewScrollBar:SetMinMaxValues(1, 1)
                DEBUG('set minmax to 1,1')
            else
                self.CharactersListviewScrollBar:SetMinMaxValues(1, (c - 9))
                DEBUG('set minmax to 1,'..(c-9))
            end
        end
    end

    function self.GuildFrame.TradeSkillFrame:ClearCharactersListeview()
        for i = 1, 10 do
            self.CharactersListviewRows[i].selected = false
            self.CharactersListviewRows[i]:Hide()
        end
    end

    function self.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
        self:ClearCharactersListeview()
        if next(self.CharactersWithProf) then
            local scrollPos = math.floor(self.CharactersListviewScrollBar:GetValue())
            if scrollPos == 0 then
                scrollPos = 1
            end
            for i = 1, 10 do
                if self.CharactersWithProf[(i - 1) + scrollPos] then
                    self.CharactersListviewRows[i]:Hide()
                    self.CharactersListviewRows[i].data = self.CharactersWithProf[(i - 1) + scrollPos]
                    self.CharactersListviewRows[i]:Show()
                end
            end
        end
    end

    -- recipes
    self.GuildFrame.TradeSkillFrame.Recipes = {'test'}
    self.GuildFrame.TradeSkillFrame.RecipesListviewRows = {}
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameRecipesListviewParent', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'BOTTOMRIGHT', 28, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:SetSize(275, 210)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.background = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.background:SetAllPoints(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPRIGHT', -1, 2)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetSize(30, 180)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.7)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', -2, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.4)

    self.GuildFrame.TradeSkillFrame.RecipesListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameRecipesListviewScrollBar', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, "UIPanelScrollBarTemplate")
    self.GuildFrame.TradeSkillFrame.RecipesListviewScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPRIGHT', 28, -17)
    self.GuildFrame.TradeSkillFrame.RecipesListviewScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', 0, 16)
    self.GuildFrame.TradeSkillFrame.RecipesListviewScrollBar:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.RecipesListviewScrollBar:SetValueStep(1)
    self.GuildFrame.TradeSkillFrame.RecipesListviewScrollBar:SetValue(1)
    self.GuildFrame.TradeSkillFrame.RecipesListviewScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.TradeSkillFrame:RefreshRecipesListview()
    end)

    -- create characters with prof listview
    for i = 1, 10 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameRecipesListviewRow'..i), self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPLEFT', 0, (i - 1) * -21)
        f:SetSize(self.GuildFrame.TradeSkillFrame.RecipesListviewParent:GetWidth(), 20)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.leftBackground = f:CreateTexture('$parentLeftBackground', 'BACKGROUND')
        f.leftBackground:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
        f.leftBackground:SetPoint('BOTTOMRIGHT', f, 'BOTTOMLEFT', (self.GuildFrame.TradeSkillFrame.RecipesListviewParent:GetWidth() / 2), 0)
        f.rightBackground = f:CreateTexture('$parentRightBackground', 'BACKGROUND')
        f.rightBackground:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 0, 0)
        f.rightBackground:SetPoint('BOTTOMLEFT', f, 'BOTTOMRIGHT', (self.GuildFrame.TradeSkillFrame.RecipesListviewParent:GetWidth() / 2) * -1, 0)
        f.id = i
        f.selected = false
        f.data = nil
        if f.id % 2 == 0 then
            f.leftBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Even))
            f.rightBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Even))
        else
            f.leftBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Odd))
            f.rightBackground:SetColorTexture(unpack(listviewConfig.BackgroundColour_Odd))
        end
        f:SetScript('OnMouseDown', function(self)
            for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows) do
                v.selected = false
            end
            self.selected = not self.selected
            if self.data then
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook.GuildFrame.TradeSkillFrame:UpdateReagents(f.data)
            end
        end)
        f:SetScript('OnMouseUp', function(self)
            Guildbook.GuildFrame.TradeSkillFrame.UpdateRowBackground(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
        end)
        f:SetScript('OnEnter', function(self)
            if self.selected == true then
                f.leftBackground:SetColorTexture(unpack(listviewConfig.SelectedColour))
                f.rightBackground:SetColorTexture(unpack(listviewConfig.SelectedColour))
            else
                f.leftBackground:SetColorTexture(unpack(listviewConfig.HoverColour))
                f.rightBackground:SetColorTexture(unpack(listviewConfig.HoverColour))
            end
            if self.data then
                GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
                GameTooltip:SetHyperlink(f.data.Link)
                GameTooltip:Show()
            else
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                self.Text:SetText(self.data.Link)
            end
        end)
        f:SetScript('OnHide', function(self)
            self.data = nil
            self.Text:SetText(' ')
        end)
        f:SetScript('OnLeave', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            Guildbook.GuildFrame.TradeSkillFrame.UpdateRowBackground(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
        end)
        self.GuildFrame.TradeSkillFrame.RecipesListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:ClearRecipesListeview()
        for i = 1, 10 do
            self.RecipesListviewRows[i].selected = false
            self.RecipesListviewRows[i]:Hide()
        end
    end

    function self.GuildFrame.TradeSkillFrame:RefreshRecipesListview()
        self:ClearRecipesListeview()
        if self.SelectedCharacter and self.SelectedProfession then
            wipe(self.Recipes)
            -- set up comms to whisper for data
            --using this for testing only
            if GUILDBOOK_CHARACTER[self.SelectedProfession] then
                for itemID, reagents in pairs(GUILDBOOK_CHARACTER[self.SelectedProfession]) do
                    local itemLink = select(2, GetItemInfo(itemID))
                    local itemRarity = select(3, GetItemInfo(itemID))
                    local recipeItem = {
                        Link = itemLink,
                        Rarity = tonumber(itemRarity),
                        Reagents = {},
                    }
                    for reagentID, count in pairs(reagents) do
                        local reagentLink = select(2, GetItemInfo(reagentID))
                        local reagentRarity = select(3, GetItemInfo(reagentID))
                        table.insert(recipeItem.Reagents, {
                            Link = reagentLink,
                            Rarity = tonumber(reagentRarity),
                            Count = tonumber(count),
                        })
                    end
                    table.insert(self.Recipes, recipeItem)
                end
            end

            table.sort(self.Recipes, function(a, b)
                if a.Rarity and b.Rarity then
                    return a.Rarity > b.Rarity
                end
            end)

            if next(self.Recipes) then
                local scrollPos = math.floor(self.RecipesListviewScrollBar:GetValue())
                if scrollPos == 0 then
                    scrollPos = 1
                end
                for i = 1, 10 do
                    if self.Recipes[(i - 1) + scrollPos] then
                        self.RecipesListviewRows[i]:Hide()
                        self.RecipesListviewRows[i].data = self.Recipes[(i - 1) + scrollPos]
                        self.RecipesListviewRows[i]:Show()
                    end
                end
            end

            local c = #self.Recipes
            if c <= 10 then
                self.RecipesListviewScrollBar:SetMinMaxValues(1, 1)
                DEBUG('set minmax to 1,1')
            else
                self.RecipesListviewScrollBar:SetMinMaxValues(1, (c - 9))
                DEBUG('set minmax to 1,'..(c-9))
            end

        end

    end

    print(GuildFrameBarLeft:GetTexture())

    -- reagents
    self.GuildFrame.TradeSkillFrame.Reagents = {'test'}
    self.GuildFrame.TradeSkillFrame.ReagentsListviewRows = {}
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameReagentsListviewParent', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', 28, 0)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:SetSize(200, 210)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background = self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background:SetAllPoints(Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)
    for i = 1, 8 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameRecipesListviewRow'..i), self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent, 'TOPLEFT', 4, ((i - 1) * -22) - 8)
        f:SetSize(self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:GetWidth(), 20)

        f.icon = f:CreateTexture('$parentIcon', 'ARTWORK')
        f.icon:SetPoint('LEFT', 4, 0)
        f.icon:SetSize(20, 20)

        f.text = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.text:SetPoint('LEFT', f.icon, 'RIGHT', 4, 0)
        f.text:SetTextColor(1,1,1,1)

        self.GuildFrame.TradeSkillFrame.ReagentsListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:ClearReagentsListview()
        for k, v in ipairs(self.ReagentsListviewRows) do
            v.icon:SetTexture(nil)
            v.text:SetText(' ')
        end
    end

    function self.GuildFrame.TradeSkillFrame:UpdateReagents(recipe)
        self:ClearReagentsListview()
        wipe(self.Reagents)

        for k, v in ipairs(recipe.Reagents) do
            local icon = select(10, GetItemInfo(v.Link))
            local name = select(1, GetItemInfo(v.Link))
            self.ReagentsListviewRows[k].icon:SetTexture(icon)
            self.ReagentsListviewRows[k].text:SetText(string.format('[%s] %s', v.Count, name))

        end
    end


end