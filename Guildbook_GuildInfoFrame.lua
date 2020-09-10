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

Guildbook.GuildInfoFrame = {}

local LibGraph = LibStub("LibGraph-2.0");

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG
local PRINT = Guildbook.PRINT

--set constants
local FRIENDS_FRAME_WIDTH = FriendsFrame:GetWidth()
local GUILD_FRAME_WIDTH = GuildFrame:GetWidth()
local GUILD_INFO_FRAME_WIDTH = GuildInfoFrame:GetWidth()

--adjust some blizz layout
GuildInfoFrame:SetWidth(GUILD_INFO_FRAME_WIDTH + 175)
GuildInfoTextBackground:ClearAllPoints()
GuildInfoTextBackground:SetPoint('TOPLEFT', GuildInfoFrame, 'TOPLEFT', 11, -32)
GuildInfoTextBackground:SetPoint('BOTTOMRIGHT', GuildInfoFrame, 'BOTTOMRIGHT', -11, 40)
GuildInfoFrameScrollFrame:SetPoint('BOTTOMRIGHT', GuildInfoTextBackground, 'BOTTOMRIGHT', -31, 7)

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--create addition frames and tab buttons
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook.GuildInfoFrame:Init()
    self.InfoTab = CreateFrame('BUTTON', 'GuildInfoFrameTab1', GuildInfoFrame, "CharacterFrameTabButtonTemplate")
    self.InfoTab:SetID(1)
    self.InfoTab:SetPoint("TOPLEFT", "GuildInfoFrame", "BOTTOMLEFT", 2, 7)
    self.InfoTab:SetText(L['Info'])
    self.InfoTab:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(GuildInfoFrame, 1);
        GuildInfoTextBackground:Show()
        GuildInfoTitle:SetText(L['Guild Information'])
        Guildbook.GuildInfoFrame.SummaryFrame:Hide()
        Guildbook.GuildInfoFrame.ProfessionsFrame:Hide()
    end)

    self.SummaryTab = CreateFrame('BUTTON', 'GuildInfoFrameTab2', GuildInfoFrame, "CharacterFrameTabButtonTemplate")
    self.SummaryTab:SetID(2)
    self.SummaryTab:SetPoint('LEFT', self.InfoTab, 'RIGHT', -18, 0)
    self.SummaryTab:SetText(L['ClassRoles'])
    self.SummaryTab:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(GuildInfoFrame, 2);
        GuildInfoTextBackground:Hide()
        GuildInfoTitle:SetText(L['ClassRolesSummary'])
        Guildbook.GuildInfoFrame.SummaryFrame:Show()
        Guildbook.GuildInfoFrame.ProfessionsFrame:Hide()
    end)

    self.ProfessionsTab = CreateFrame('BUTTON', 'GuildInfoFrameTab3', GuildInfoFrame, "CharacterFrameTabButtonTemplate")
    self.ProfessionsTab:SetID(3)
    self.ProfessionsTab:SetPoint('LEFT', self.SummaryTab, 'RIGHT', -18, 0)
    self.ProfessionsTab:SetText(L['Professions'])
    self.ProfessionsTab:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(GuildInfoFrame, 4);
        GuildInfoTextBackground:Hide()
        GuildInfoTitle:SetText(L['Professions'])
        Guildbook.GuildInfoFrame.SummaryFrame:Hide()
        Guildbook.GuildInfoFrame.ProfessionsFrame:Show()
    end)

    --set tab info
    PanelTemplates_SetNumTabs(GuildInfoFrame, 3);
    PanelTemplates_SetTab(GuildInfoFrame, 1) 

    ------------------------------------------------------------------------------------------------------
    -- summary frame
    ------------------------------------------------------------------------------------------------------
    self.SummaryFrame = CreateFrame('FRAME', 'GuildbookGuildInfoFrameSummaryFrame', GuildInfoFrame)
    self.SummaryFrame:SetPoint('TOPLEFT', GuildInfoFrame, 'TOPLEFT', 0, -24)
    self.SummaryFrame:SetPoint('BOTTOMRIGHT', GuildInfoFrame, 'BOTTOMRIGHT', 0, 0)
    self.SummaryFrame:Hide()
    self.SummaryFrame:SetScript('OnShow', function(self)
        Guildbook.GuildInfoFrame.SummaryFrame:UpdateClassChart()
        self:GetClassRoleFromCache()
    end)

    self.SummaryFrame.RoleHeader = self.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameRoleHeader', 'OVERLAY', 'GameFontNormal')
    self.SummaryFrame.RoleHeader:SetPoint('TOPLEFT', 20, -22)
    self.SummaryFrame.RoleHeader:SetText(L['RoleChart'])
    self.SummaryFrame.RoleHeader:SetTextColor(1,1,1,1)
    self.SummaryFrame.RoleHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.SummaryFrame.ClassHeader = self.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameClassHeader', 'OVERLAY', 'GameFontNormal')
    self.SummaryFrame.ClassHeader:SetPoint('TOPLEFT', 16, -175)
    self.SummaryFrame.ClassHeader:SetText(L['ClassChart'])
    self.SummaryFrame.ClassHeader:SetTextColor(1,1,1,1)
    self.SummaryFrame.ClassHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.SummaryFrame.MinLevelSlider = CreateFrame('SLIDER', 'GuildbookGuildInfoFrameminLevelSlider', self.SummaryFrame, 'OptionsSliderTemplate')
    self.SummaryFrame.MinLevelSlider:SetPoint('TOPLEFT', 250, -215)
    self.SummaryFrame.MinLevelSlider:SetThumbTexture("Interface/Buttons/UI-SliderBar-Button-Horizontal")
    self.SummaryFrame.MinLevelSlider:SetSize(150, 16)
    self.SummaryFrame.MinLevelSlider:SetOrientation('HORIZONTAL')
    self.SummaryFrame.MinLevelSlider:SetMinMaxValues(1, 60) 
    self.SummaryFrame.MinLevelSlider:SetValueStep(1.0)
    _G[Guildbook.GuildInfoFrame.SummaryFrame.MinLevelSlider:GetName()..'Low']:SetText('1')
    _G[Guildbook.GuildInfoFrame.SummaryFrame.MinLevelSlider:GetName()..'High']:SetText('60')
    self.SummaryFrame.MinLevelSlider:SetValue(60)
    self.SummaryFrame.MinLevelSlider:SetScript('OnValueChanged', function(self)
        --print(math.floor(self:GetValue()))
    end)
    self.SummaryFrame.MinLevelSlider_Title = self.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameminLevelTitle', 'OVERLAY', 'GameFontNormal')
    self.SummaryFrame.MinLevelSlider_Title:SetPoint('BOTTOM', self.SummaryFrame.MinLevelSlider, 'TOP', 0, 5)
    self.SummaryFrame.MinLevelSlider_Title:SetText('Character min level')

    self.SummaryFrame.ClassCount = {
        { Class = 'DEATHKNIGHT', Count = 0 },
        { Class = 'DRUID', Count = 0 },
        { Class = 'HUNTER', Count = 0 },
        { Class = 'MAGE', Count = 0 },
        { Class = 'PALADIN', Count = 0 },
        { Class = 'PRIEST', Count = 0 },
        { Class = 'ROGUE', Count = 0 },
        { Class = 'SHAMAN', Count = 0 },
        { Class = 'WARLOCK', Count = 0},
        { Class = 'WARRIOR', Count  = 0 }
    }

    local segCol = 0.66 --adjustment % of class colours
    self.SummaryFrame.ClassSummaryPieChart = LibGraph:CreateGraphPieChart('GuildbookClassSummaryCountChart', self.SummaryFrame, 'BOTTOMLEFT', 'BOTTOMLEFT', 15, 35, 180, 180)
    function self.SummaryFrame.ClassSummaryPieChart_SelectionFunc(_, segment)
        if type(segment) == 'number' and segment > 0 and segment < 11 then
            GameTooltip:SetOwner(self.SummaryFrame, 'ANCHOR_CURSOR')
            --GameTooltip:AddLine('|cffffffffClass Info|r')
            GameTooltip:AddDoubleLine('|cffffffff'..self.SummaryFrame.ClassCount[segment].Class..'|r', self.SummaryFrame.ClassCount[segment].Count)
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end
    self.SummaryFrame.ClassSummaryPieChart:SetSelectionFunc(Guildbook.GuildInfoFrame.SummaryFrame.ClassSummaryPieChart_SelectionFunc)
    for k, class in pairs(self.SummaryFrame.ClassCount) do
        local r, g, b = unpack(Guildbook.Data.Class[class.Class].RGB)
        self.SummaryFrame.ClassSummaryPieChart:AddPie(10, {r*segCol, g*segCol, b*segCol});
    end
    self.SummaryFrame.ClassSummaryPieChart:CompletePie({0,0,0})
    
    self.SummaryFrame.Roles = {
		Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
		Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
		Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
        Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 },
    }
    self.SummaryFrame.RoleCharts = {}
    local roles = { 'Tank', 'Melee', 'Healer', 'Ranged' }
    for i = 1, 4 do
        local role = roles[i]
        local chart = LibGraph:CreateGraphPieChart('GuildbookTankPieChart', self.SummaryFrame, 'TOPLEFT', 'TOPLEFT', (25 + ((i - 1) * 100)), -50, 90, 90)
        local title = self.SummaryFrame:CreateFontString('$parentRolePieChartTitle', 'OVERLAY', 'GameFontNormal')
        title:SetPoint('TOP', chart, 'BOTTOM', 0, -5)
        title:SetText(role)
        local deg = 0
        if role == 'Tank' or role == 'Healer' then
            deg = 4
        else
            deg = 6
        end
        for class, count in pairs(self.SummaryFrame.Roles[role]) do
            local r, g, b = unpack(Guildbook.Data.Class[class].RGB)
            chart:AddPie((100 / deg), {r*segCol, g*segCol, b*segCol})
        end
        self.SummaryFrame.RoleCharts[role] = chart
    end

    function self.SummaryFrame:ResetClassCount()
        for k, v in ipairs(self.ClassCount) do
            v.Count = 0
        end
        self.ClassSummaryPieChart:ResetPie()
    end
    
    --currently just calling blizz api - maybe use local cache?
    function self.SummaryFrame:UpdateClassChart()
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
        Guildbook.GuildInfoFrame.SummaryFrame.ClassSummaryPieChart:CompletePie({0,0,0})
    end

    function self.SummaryFrame:GetClassRoleFromCache()
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


    ------------------------------------------------------------------------------------------------------
    -- profession frame
    ------------------------------------------------------------------------------------------------------
    self.ProfessionsFrame = CreateFrame('FRAME', 'GuildbookGuildInfoFrameProfessionsFrame', GuildInfoFrame)
    self.ProfessionsFrame:SetPoint('TOPLEFT', GuildInfoFrame, 'TOPLEFT', 0, -24)
    self.ProfessionsFrame:SetPoint('BOTTOMRIGHT', GuildInfoFrame, 'BOTTOMRIGHT', 0, 0)
    self.ProfessionsFrame:Hide()
    self.ProfessionsFrame:SetScript('OnShow', function(self)

    end)

end


Guildbook.GuildInfoFrame:Init()