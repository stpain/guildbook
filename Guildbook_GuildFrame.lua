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


function Guildbook:SetupSummaryFrame()
    self.GuildFrame.SummaryFrame.RoleHeader = self.GuildFrame.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameRoleHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.SummaryFrame.RoleHeader:SetPoint('TOPLEFT', 20, -22)
    self.GuildFrame.SummaryFrame.RoleHeader:SetText(L['RoleChart'])
    self.GuildFrame.SummaryFrame.RoleHeader:SetTextColor(1,1,1,1)
    self.GuildFrame.SummaryFrame.RoleHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.SummaryFrame.MinLevelSlider = CreateFrame('SLIDER', 'GuildbookGuildInfoFrameminLevelSlider', self.GuildFrame.SummaryFrame, 'OptionsSliderTemplate')
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetPoint('TOPLEFT', 250, -215)
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetThumbTexture("Interface/Buttons/UI-SliderBar-Button-Horizontal")
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetSize(150, 16)
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetOrientation('HORIZONTAL')
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetMinMaxValues(1, 60) 
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetValueStep(1.0)
    _G[Guildbook.GuildFrame.SummaryFrame.MinLevelSlider:GetName()..'Low']:SetText('1')
    _G[Guildbook.GuildFrame.SummaryFrame.MinLevelSlider:GetName()..'High']:SetText('60')
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetValue(60)
    self.GuildFrame.SummaryFrame.MinLevelSlider:SetScript('OnValueChanged', function(self)
        --print(math.floor(self:GetValue()))
    end)
    self.GuildFrame.SummaryFrame.MinLevelSlider_Title = self.GuildFrame.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameminLevelTitle', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.SummaryFrame.MinLevelSlider_Title:SetPoint('BOTTOM', self.GuildFrame.SummaryFrame.MinLevelSlider, 'TOP', 0, 5)
    self.GuildFrame.SummaryFrame.MinLevelSlider_Title:SetText('Character min level')

    self.GuildFrame.SummaryFrame.ClassCount = {
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
    self.GuildFrame.SummaryFrame.ClassSummaryPieChart = LibGraph:CreateGraphPieChart('GuildbookClassSummaryCountChart', self.GuildFrame.SummaryFrame, 'TOPRIGHT', 'TOPRIGHT', -15, -35, 180, 180)
    self.GuildFrame.SummaryFrame.ClassHeader = self.GuildFrame.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameClassHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.SummaryFrame.ClassHeader:SetPoint('BOTTOM', Guildbook.GuildFrame.SummaryFrame.ClassSummaryPieChart, 'TOP', 0, 2)
    self.GuildFrame.SummaryFrame.ClassHeader:SetText('Class Summary')
    self.GuildFrame.SummaryFrame.ClassHeader:SetTextColor(1,1,1,1)
    self.GuildFrame.SummaryFrame.ClassHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)
    local function classSummaryPieChart_SelectionFunc(_, segment)
        if type(segment) == 'number' and segment > 0 and segment < 11 then
            GameTooltip:SetOwner(self.GuildFrame.SummaryFrame, 'ANCHOR_CURSOR')
            --GameTooltip:AddLine('|cffffffffClass Info|r')
            GameTooltip:AddDoubleLine('|cffffffff'..self.GuildFrame.SummaryFrame.ClassCount[segment].Class..'|r', self.GuildFrame.SummaryFrame.ClassCount[segment].Count)
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end
    self.GuildFrame.SummaryFrame.ClassSummaryPieChart:SetSelectionFunc(classSummaryPieChart_SelectionFunc)
    for k, class in pairs(self.GuildFrame.SummaryFrame.ClassCount) do
        local r, g, b = unpack(Guildbook.Data.Class[class.Class].RGB)
        self.GuildFrame.SummaryFrame.ClassSummaryPieChart:AddPie(10, {r*segCol, g*segCol, b*segCol});
    end
    self.GuildFrame.SummaryFrame.ClassSummaryPieChart:CompletePie({0,0,0})
    
    self.GuildFrame.SummaryFrame.Roles = {
		Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
		Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
		Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
        Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 },
    }
    self.GuildFrame.SummaryFrame.RoleCharts = {}
    local roles = { 'Tank', 'Melee', 'Healer', 'Ranged' }
    for i = 1, 4 do
        local role = roles[i]
        local chart = LibGraph:CreateGraphPieChart('GuildbookTankPieChart', self.GuildFrame.SummaryFrame, 'TOPLEFT', 'TOPLEFT', (25 + ((i - 1) * 100)), -50, 90, 90)
        local title = self.GuildFrame.SummaryFrame:CreateFontString('$parentRolePieChartTitle', 'OVERLAY', 'GameFontNormal')
        title:SetPoint('TOP', chart, 'BOTTOM', 0, -5)
        title:SetText(role)
        local deg = 0
        if role == 'Tank' or role == 'Healer' then
            deg = 4
        else
            deg = 6
        end
        for class, count in pairs(self.GuildFrame.SummaryFrame.Roles[role]) do
            local r, g, b = unpack(Guildbook.Data.Class[class].RGB)
            chart:AddPie((100 / deg), {r*segCol, g*segCol, b*segCol})
        end
        self.GuildFrame.SummaryFrame.RoleCharts[role] = chart
    end

    function self.GuildFrame.SummaryFrame:ResetClassCount()
        for k, v in ipairs(self.ClassCount) do
            v.Count = 0
        end
        self.ClassSummaryPieChart:ResetPie()
    end
    
    --currently just calling blizz api - maybe use local cache?
    function self.GuildFrame.SummaryFrame:UpdateClassChart()
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
        Guildbook.GuildFrame.SummaryFrame.ClassSummaryPieChart:CompletePie({0,0,0})
    end

    function self.GuildFrame.SummaryFrame:GetClassRoleFromCache()
        if GUILDBOOK_GLOBAL and next(GUILDBOOK_GLOBAL.GuildRosterCache) then
            self.Roles = {
                Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
                Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
                Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
                Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 }
            }
            for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache) do
                self.Roles[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]][character.Class] = self.Roles[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]][character.Class] + 1
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


    self.GuildFrame.SummaryFrame:SetScript('OnShow', function(self)
        self:GetClassRoleFromCache()
        self:UpdateClassChart()
    end)
    
end

--Guildbook.GuildInfoFrame:Init()