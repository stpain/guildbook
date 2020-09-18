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
    self.GuildFrame.StatsFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.StatsFrame, 'TOP', 0, 4)
    self.GuildFrame.StatsFrame.Header:SetText('Class and Role Summary')
    self.GuildFrame.StatsFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.StatsFrame.MinLevelSlider = CreateFrame('SLIDER', 'GuildbookGuildInfoFrameMinLevelSlider', self.GuildFrame.StatsFrame, 'OptionsSliderTemplate')
    self.GuildFrame.StatsFrame.MinLevelSlider:SetPoint('TOPLEFT', 35, -80)
    self.GuildFrame.StatsFrame.MinLevelSlider:SetThumbTexture("Interface/Buttons/UI-SliderBar-Button-Horizontal")
    self.GuildFrame.StatsFrame.MinLevelSlider:SetSize(125, 16)
    self.GuildFrame.StatsFrame.MinLevelSlider:SetOrientation('HORIZONTAL')
    self.GuildFrame.StatsFrame.MinLevelSlider:SetMinMaxValues(1, 60) 
    self.GuildFrame.StatsFrame.MinLevelSlider:SetValueStep(1.0)
    _G[Guildbook.GuildFrame.StatsFrame.MinLevelSlider:GetName()..'Low']:SetText(' ')
    _G[Guildbook.GuildFrame.StatsFrame.MinLevelSlider:GetName()..'High']:SetText(' ')
    self.GuildFrame.StatsFrame.MinLevelSlider:SetValue(60)
    self.GuildFrame.StatsFrame.MinLevelSlider:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.StatsFrame.MinLevelSlider_Text:SetText(math.floor(Guildbook.GuildFrame.StatsFrame.MinLevelSlider:GetValue()))
        Guildbook.GuildFrame.StatsFrame:GetClassRoleFromCache()
    end)
    self.GuildFrame.StatsFrame.MinLevelSlider.tooltipText = 'Show data for characters with a minimun level'
    self.GuildFrame.StatsFrame.MinLevelSlider_Title = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameMinLevelSliderTitle', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.MinLevelSlider_Title:SetPoint('BOTTOM', self.GuildFrame.StatsFrame.MinLevelSlider, 'TOP', 0, 5)
    self.GuildFrame.StatsFrame.MinLevelSlider_Title:SetText('Character min level')

    self.GuildFrame.StatsFrame.MinLevelSlider_Text = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameMinLevelSliderText', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetPoint('LEFT', Guildbook.GuildFrame.StatsFrame.MinLevelSlider, 'RIGHT', 8, 0)
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetText(math.floor(Guildbook.GuildFrame.StatsFrame.MinLevelSlider:GetValue()))
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetFont("Fonts\\FRIZQT__.TTF", 12)

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

    local selectedCharacter = nil
    local selectedProfession = nil

    self.GuildFrame.TradeSkillFrame:SetScript('OnShow', function(self)
        self:ClearCharactersListview()
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        Guildbook.GuildFrame.TradeSkillFrame.ProfessionIcon:SetTexture(nil)
        Guildbook.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('Select a profession to see members of your guild who are trained in that profession.')
    end)

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
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('Select a profession to see members of your guild who are trained in that profession.')
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
                Guildbook.GuildFrame.TradeSkillFrame:ClearCharactersListview()
                selectedProfession = prof.Name
                Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValue(1)
                Guildbook.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof.Name)
                Guildbook.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearRecipesListview()
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
                selectedCharacter = self.data.Name
                DEBUG('selected '..self.data.Name)
                Guildbook.GuildFrame.TradeSkillFrame:ClearRecipesListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook:SendTradeSkillsRequest(selectedCharacter, selectedProfession)
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
            local c = #self.CharactersWithProf
            if c <= 10 then
                self.CharactersListviewScrollBar:SetMinMaxValues(1, 2)
                self.CharactersListviewScrollBar:SetValue(2)
                self.CharactersListviewScrollBar:SetValue(1)
                self.CharactersListviewScrollBar:SetMinMaxValues(1, 1)
                DEBUG('set minmax to 1,1')
            else
                self.CharactersListviewScrollBar:SetMinMaxValues(1, (c - 9))
                self.CharactersListviewScrollBar:SetValue(2)
                self.CharactersListviewScrollBar:SetValue(1)
                DEBUG('set minmax to 1,'..(c-9))
            end
        end
    end

    function self.GuildFrame.TradeSkillFrame:ClearCharactersListview()
        for i = 1, 10 do
            self.CharactersListviewRows[i].selected = false
            self.CharactersListviewRows[i]:Hide()
        end
    end

    function self.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
        self:ClearCharactersListview()
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
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:SetSize(235, 210)
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
        if next(Guildbook.GuildFrame.TradeSkillFrame.Recipes) then
            local scrollPos = math.floor(self:GetValue())
            if scrollPos == 0 then
                scrollPos = 1
            end
            for i = 1, 10 do
                if Guildbook.GuildFrame.TradeSkillFrame.Recipes[(i - 1) + scrollPos] then
                    Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows[i]:Hide()
                    Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows[i].data = Guildbook.GuildFrame.TradeSkillFrame.Recipes[(i - 1) + scrollPos]
                    Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows[i]:Show()
                end
            end
        end
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
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.Link = self.data.Link
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetTexture(self.data.Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetText(self.data.Link)
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
            Guildbook.GuildFrame.TradeSkillFrame.UpdateRowBackground(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
        end)
        self.GuildFrame.TradeSkillFrame.RecipesListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:ClearRecipesListview()
        for i = 1, 10 do
            self.RecipesListviewRows[i].selected = false
            self.RecipesListviewRows[i]:Hide()
        end
    end

    function self.GuildFrame.TradeSkillFrame:RefreshRecipesListview(data)
        self:ClearRecipesListview()
        if data and next(data) then
            wipe(self.Recipes)
            for itemID, reagents in pairs(data) do
                local itemLink = select(2, GetItemInfo(itemID))
                local itemRarity = select(3, GetItemInfo(itemID))
                local itemIcon = select(10, GetItemInfo(itemID))
                local recipeItem = {
                    Link = itemLink,
                    Rarity = tonumber(itemRarity),
                    Reagents = {},
                    Icon = tonumber(itemIcon),
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

            table.sort(self.Recipes, function(a, b)
                if a.Rarity and b.Rarity then
                    return a.Rarity > b.Rarity
                end
            end)

            local c = #self.Recipes
            if c <= 10 then
                self.RecipesListviewScrollBar:SetMinMaxValues(1, 2)
                self.RecipesListviewScrollBar:SetValue(2)
                self.RecipesListviewScrollBar:SetValue(1)
                self.RecipesListviewScrollBar:SetMinMaxValues(1, 1)
                DEBUG('set minmax to 1,1')
            else
                self.RecipesListviewScrollBar:SetMinMaxValues(1, (c - 9))
                self.RecipesListviewScrollBar:SetValue(2)
                self.RecipesListviewScrollBar:SetValue(1)
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
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:SetSize(240, 210)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background = self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background:SetAllPoints(Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)

    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem = CreateFrame('FRAME', 'GuildbookGuildFrameReagentsListviewParentRecipeItem', self.GuildFrame.TradeSkillFrame.ReagentsListviewParent)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetPoint('TOPLEFT', 4, -4)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetSize(200, 25)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.Link = nil
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnEnter', function(self)
        if self.Link then
            GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
            GameTooltip:SetHyperlink(self.Link)
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon = self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:CreateTexture('$parentRecipeItemIcon', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetPoint('LEFT', 4, 0)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetSize(25, 25)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName = self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:CreateFontString('$parentRecipeItemName', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetPoint('TOPLEFT', self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon, 'TOPRIGHT', 4, -4)

    for i = 1, 8 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameRecipesListviewRow'..i), self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent, 'TOPLEFT', 4, ((i - 1) * -22) - 35)
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
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.Link = nil
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetTexture(nil)
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetText(' ')
        for k, v in ipairs(self.ReagentsListviewRows) do
            v.icon:SetTexture(nil)
            v.text:SetText(' ')
        end
    end

    function self.GuildFrame.TradeSkillFrame:UpdateReagents(recipe)
        self:ClearReagentsListview()
        wipe(self.Reagents)

        if recipe and recipe.Reagents then
            for k, v in ipairs(recipe.Reagents) do
                if v.Link then
                    local icon = select(10, GetItemInfo(v.Link))
                    local name = select(1, GetItemInfo(v.Link))
                    self.ReagentsListviewRows[k].icon:SetTexture(icon)
                    self.ReagentsListviewRows[k].text:SetText(string.format('[%s] %s', v.Count, name))
                end
            end
        end
    end


end





function Guildbook:SetupGuildBankFrame()

    local slotBackground = 130766

    self.GuildFrame.GuildBankFrame:SetScript('OnShow', function(self)

    end)

    self.GuildFrame.GuildBankFrame.Header = self.GuildFrame.GuildBankFrame:CreateFontString('GuildbookGuildInfoFrameGuildBankFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildBankFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildBankFrame, 'TOP', 0, 4)
    self.GuildFrame.GuildBankFrame.Header:SetText('Guild Bank')
    self.GuildFrame.GuildBankFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildBankFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.GuildBankFrame.BankSlots = {}
    local slotIdx, slotWidth = 1, 36
    for column = 1, 14 do
        local x = ((column - 1) * slotWidth) + 256
        for row = 1, 7 do            
            local y = ((row -1) * -slotWidth) - 10
            local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameGuildBankFrameCol'..column..'Row'..row), self.GuildFrame.GuildBankFrame)
            f:SetSize(slotWidth, slotWidth)
            f:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame, 'TOPLEFT', x, y)
            f:SetBackdrop({
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 16,
                --bgFile = "interface/framegeneral/ui-background-marble",
                tile = true,
                tileEdge = false,
                tileSize = 200,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
            f.background:SetPoint('TOPLEFT', -10, 10)
            f.background:SetPoint('BOTTOMRIGHT', 10, -10)
            f.background:SetTexture(130766)
            f.icon = f:CreateTexture('$parentBackground', 'ARTWORK')
            f.icon:SetPoint('TOPLEFT', 2, -2)
            f.icon:SetPoint('BOTTOMRIGHT', -2, 2)
            f.data = nil

            self.GuildFrame.GuildBankFrame.BankSlots[slotIdx] = f
            slotIdx = slotIdx + 1
        end
    end

    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop = self.GuildFrame.GuildBankFrame:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetPoint('TOPRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -3, -4)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetSize(30, 200)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.7)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom = self.GuildFrame.GuildBankFrame:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', -4, 4)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.41)

    self.GuildFrame.GuildBankFrame.RecipesListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameRecipesListviewScrollBar', Guildbook.GuildFrame.GuildBankFrame, "UIPanelScrollBarTemplate")
    self.GuildFrame.GuildBankFrame.RecipesListviewScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -26, -26)
    self.GuildFrame.GuildBankFrame.RecipesListviewScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', -10, 22)
    self.GuildFrame.GuildBankFrame.RecipesListviewScrollBar:EnableMouse(true)
    self.GuildFrame.GuildBankFrame.RecipesListviewScrollBar:SetValueStep(1)
    self.GuildFrame.GuildBankFrame.RecipesListviewScrollBar:SetValue(1)
    self.GuildFrame.GuildBankFrame.RecipesListviewScrollBar:SetScript('OnValueChanged', function(self)
    
    end)


    function self.GuildFrame.GuildBankFrame:RefreshSlots(db)
        local slot = 1
        for id, count in pairs(db) do
            local t = select(10, GetItemInfo(id))
            self.BankSlots[slot].icon:SetTexture(t)
            slot = slot + 1
        end
    end










end











































function Guildbook:SetupGuildCalenderFrame()

    self.GuildFrame.GuildCalenderFrame:SetScript('OnShow', function(self)

    end)

    self.GuildFrame.GuildCalenderFrame.Header = self.GuildFrame.GuildCalenderFrame:CreateFontString('GuildbookGuildInfoFrameGuildCalenderFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildCalenderFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildCalenderFrame, 'TOP', 0, 4)
    self.GuildFrame.GuildCalenderFrame.Header:SetText('Guild Calender')
    self.GuildFrame.GuildCalenderFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildCalenderFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)


end