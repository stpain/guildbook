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

