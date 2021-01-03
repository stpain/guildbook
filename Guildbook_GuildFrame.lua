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

-- TODO: comment this file before i forget

local addonName, Guildbook = ...

local LibGraph = LibStub("LibGraph-2.0");

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- statistics frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupStatsFrame()

    --self.GuildFrame.StatsFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.StatsFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.StatsFrame, 'TOPRIGHT', -2, 2, 'Stats')

    -- this value is used to adjust the colours of the pie charts, makes them less windows 98
    local segCol = 0.66

    -- header text
    self.GuildFrame.StatsFrame.Header = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.StatsFrame, 'TOP', 0, 4)
    self.GuildFrame.StatsFrame.Header:SetText('Class and Role Summary')
    self.GuildFrame.StatsFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    -- slider to adjust min character level, this appears where the blizz show online/offline checkbox would be to keep relevent styling
    self.GuildFrame.StatsFrame.MinLevelSlider = CreateFrame('SLIDER', 'GuildbookGuildInfoFrameMinLevelSlider', self.GuildFrame.StatsFrame, 'OptionsSliderTemplate')
    self.GuildFrame.StatsFrame.MinLevelSlider:SetPoint('BOTTOMRIGHT', self.GuildFrame.StatsFrame, 'TOPRIGHT', -30, 12)
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
    self.GuildFrame.StatsFrame.MinLevelSlider.tooltipText = 'Show data for characters with a minimum level - |cffffffffRole data only|r'
    -- slider label
    self.GuildFrame.StatsFrame.MinLevelSlider_Label = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameMinLevelSliderLabel', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.MinLevelSlider_Label:SetPoint('RIGHT', self.GuildFrame.StatsFrame.MinLevelSlider, 'LEFT', -10, 0)
    self.GuildFrame.StatsFrame.MinLevelSlider_Label:SetText('Character level')
    -- slider value text
    self.GuildFrame.StatsFrame.MinLevelSlider_Text = self.GuildFrame.StatsFrame:CreateFontString('GuildbookGuildInfoFrameMinLevelSliderText', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetPoint('LEFT', Guildbook.GuildFrame.StatsFrame.MinLevelSlider, 'RIGHT', 8, 0)
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetText(math.floor(Guildbook.GuildFrame.StatsFrame.MinLevelSlider:GetValue()))
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.MinLevelSlider_Text:SetFont("Fonts\\FRIZQT__.TTF", 12)

    -- parent frame for the role pie charts, border/background currently unused but left here for future changes if any
    self.GuildFrame.StatsFrame.RoleFrame = CreateFrame('FRAME', 'GuildbookGuildFrameStatsFrameRoleFrame', self.GuildFrame.StatsFrame)
    self.GuildFrame.StatsFrame.RoleFrame:SetPoint('TOPLEFT', self.GuildFrame.StatsFrame, 'TOPLEFT', 10, -10)
    self.GuildFrame.StatsFrame.RoleFrame:SetSize(450, 160)
    -- self.GuildFrame.StatsFrame.RoleFrame:SetBackdrop({
    --     edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    --     edgeSize = 12,
    --     --bgFile = "interface/framegeneral/ui-background-marble",
    --     tile = true,
    --     tileEdge = false,
    --     --tileSize = 200,
    --     insets = { left = 4, right = 4, top = 4, bottom = 4 }
    -- })

    -- class counts by role
    self.GuildFrame.StatsFrame.Roles = {
		Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
		Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
		Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
        Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 },
    }

    -- table to hold the pie charts, this allows them to be referenced/looped and values assigned by role
    self.GuildFrame.StatsFrame.RoleCharts = {}
    local roles = { 'Tank', 'Melee', 'Healer', 'Ranged' }
    for i = 1, 4 do
        local role = roles[i]
        local chart = LibGraph:CreateGraphPieChart('GuildbookTankPieChart', self.GuildFrame.StatsFrame.RoleFrame, 'LEFT', 'LEFT', ((i - 1) * 110) + 2, 2, 100, 100)
        local title = self.GuildFrame.StatsFrame:CreateFontString('$parentRolePieChartTitle', 'OVERLAY', 'GameFontNormal')
        title:SetPoint('TOP', chart, 'BOTTOM', 0, 0)
        title:SetText(role)
        local seg = 0
        if role == 'Tank' or role == 'Healer' then
            seg = 4
        else
            seg = 6
        end
        for class, count in pairs(self.GuildFrame.StatsFrame.Roles[role]) do
            local r, g, b = unpack(Guildbook.Data.Class[class].RGB)
            chart:AddPie((100 / seg), {r*segCol, g*segCol, b*segCol})
        end
        self.GuildFrame.StatsFrame.RoleCharts[role] = chart
    end

    -- role frame header
    self.GuildFrame.StatsFrame.RoleHeader = self.GuildFrame.StatsFrame.RoleFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameRoleHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.RoleHeader:SetPoint('TOP', Guildbook.GuildFrame.StatsFrame.RoleFrame, 'TOP', 0, -5)
    self.GuildFrame.StatsFrame.RoleHeader:SetText('Roles')
    self.GuildFrame.StatsFrame.RoleHeader:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.RoleHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    -- profession parent frame
    self.GuildFrame.StatsFrame.ProfessionFrame = CreateFrame('FRAME', 'GuildbookGuildFrameStatsFrameProfessionFrame', self.GuildFrame.StatsFrame)
    self.GuildFrame.StatsFrame.ProfessionFrame:SetPoint('TOPLEFT', self.GuildFrame.StatsFrame.RoleFrame, 'BOTTOMLEFT', 0, -10)
    self.GuildFrame.StatsFrame.ProfessionFrame:SetPoint('TOPRIGHT', self.GuildFrame.StatsFrame.RoleFrame, 'BOTTOMRIGHT', 0, -10)
    self.GuildFrame.StatsFrame.ProfessionFrame:SetPoint('BOTTOM', self.GuildFrame.StatsFrame, 'BOTTOM', 0, 10)
    --self.GuildFrame.StatsFrame.ProfessionFrame:SetSize(450, 60)
    -- self.GuildFrame.StatsFrame.ProfessionFrame:SetBackdrop({
    --     edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    --     edgeSize = 12,
    --     bgFile = "interface/framegeneral/ui-background-rock",
    --     tile = true,
    --     tileEdge = false,
    --     tileSize = 200,
    --     insets = { left = 4, right = 4, top = 4, bottom = 4 }
    -- })

    -- profession counts
    self.GuildFrame.StatsFrame.ProfessionCount = {
        { Name = 'Alchemy', Count = 0, },
        { Name = 'Blacksmithing', Count = 0, },
        { Name = 'Enchanting', Count = 0, },
        { Name = 'Engineering', Count = 0, },
        { Name = 'Inscription', Count = 0, },
        { Name = 'Jewelcrafting', Count = 0, },
        { Name = 'Leatherworking', Count = 0, },
        { Name = 'Tailoring', Count = 0, },
    }

    -- profession table, this holds the profession widget so they can be looped and updated by profession
    self.GuildFrame.StatsFrame.Professions = {}
    for k, prof in pairs(Guildbook.GuildFrame.StatsFrame.ProfessionCount) do
        local f = CreateFrame('FRAME', tostring('$parent'..prof.Name), Guildbook.GuildFrame.StatsFrame.ProfessionFrame)
        f:SetPoint('BOTTOMLEFT', ((k-1) * 55) + 5, 15)
        f:SetSize(55, 25)
        f.icon = f:CreateTexture(tostring('$parentIcon'..prof.Name), 'ARTWORK')
        f.icon:SetPoint('LEFT', 0, 0)
        f.icon:SetSize(25, 25)

        f.text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormal')
        f.text:SetPoint('LEFT', f.icon, 'RIGHT', 5, 0)
        f.text:SetTextColor(1,1,1,1)
        f.text:SetText(prof.Count)

        -- quick fix, this can be removed when inscription arrives in wrath
        if prof.Name == 'Inscription' then
            f.icon:SetTexture('Interface/Addons/Guildbook/Icons/Professions/IconTextures')
            f.icon:SetTexCoord(0.0, 0.13, 0.15, 0.27)
        else
            f.icon:SetTexture(Guildbook.Data.Profession[prof.Name].Icon)
        end

        f:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_TOP')
            GameTooltip:AddLine('|cffffffff'..prof.Name..'|r')
            GameTooltip:Show()
        end)
        f:SetScript('OnLeave', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)
        Guildbook.GuildFrame.StatsFrame.Professions[prof.Name] = f
    end

    -- profession frame header
    self.GuildFrame.StatsFrame.ProfessionHeader = self.GuildFrame.StatsFrame.ProfessionFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameProfessionHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.ProfessionHeader:SetPoint('TOP', Guildbook.GuildFrame.StatsFrame.ProfessionFrame, 'TOP', 0, -5)
    self.GuildFrame.StatsFrame.ProfessionHeader:SetText('Professions')
    self.GuildFrame.StatsFrame.ProfessionHeader:SetTextColor(1,1,1,1)
    self.GuildFrame.StatsFrame.ProfessionHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    -- func: this loops the clients guild roster data, counts professions and then updates the pie charts
    function self.GuildFrame.StatsFrame:GetProfessionCount()
        for k, prof in pairs(self.ProfessionCount) do
            prof.Count = 0
        end
        local guildName = Guildbook:GetGuildName()
        if guildName then
            if GUILDBOOK_GLOBAL then
                if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
                    GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] = {}
                    return
                end
                if next(GUILDBOOK_GLOBAL.GuildRosterCache[guildName]) then
                    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[guildName]) do
                        if character['Profession1'] ~= '-' then
                            for k, prof in pairs(self.ProfessionCount) do
                                if prof.Name == character['Profession1'] then
                                    prof.Count = prof.Count + 1
                                end
                            end
                        end
                        if character['Profession2'] ~= '-' then
                            for k, prof in pairs(self.ProfessionCount) do
                                if prof.Name == character['Profession2'] then
                                    prof.Count = prof.Count + 1
                                end
                            end
                        end
                    end
                end
            end
        end
        for k, prof in pairs(self.ProfessionCount) do
            Guildbook.GuildFrame.StatsFrame.Professions[prof.Name].text:SetText(prof.Count)
        end
    end

    -- class count table
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

    -- class count parent frame
    self.GuildFrame.StatsFrame.ClassFrame = CreateFrame('FRAME', 'GuildbookGuildFrameStatsFrameClassFrame', self.GuildFrame.StatsFrame)
    self.GuildFrame.StatsFrame.ClassFrame:SetPoint('TOPLEFT', self.GuildFrame.StatsFrame.RoleFrame, 'TOPRIGHT', 10, 0)
    self.GuildFrame.StatsFrame.ClassFrame:SetPoint('BOTTOMLEFT', self.GuildFrame.StatsFrame.ProfessionFrame, 'BOTTOMRIGHT', 20, 0)
    self.GuildFrame.StatsFrame.ClassFrame:SetPoint('RIGHT', self.GuildFrame.StatsFrame, 'RIGHT', -10, 0)
    self.GuildFrame.StatsFrame.ClassFrame:SetSize(450, 60)
    -- self.GuildFrame.StatsFrame.ClassFrame:SetBackdrop({
    --     edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    --     edgeSize = 12,
    --     --bgFile = "interface/framegeneral/ui-background-marble",
    --     tile = true,
    --     tileEdge = false,
    --     --tileSize = 200,
    --     insets = { left = 4, right = 4, top = 4, bottom = 4 }
    -- })
    
    -- class count pie chart
    self.GuildFrame.StatsFrame.ClassSummaryPieChart = LibGraph:CreateGraphPieChart('GuildbookClassSummaryCountChart', self.GuildFrame.StatsFrame.ClassFrame, 'LEFT', 'LEFT', 10, 0, 180, 180)
    
    -- class count header
    self.GuildFrame.StatsFrame.ClassHeader = self.GuildFrame.StatsFrame.ClassFrame:CreateFontString('GuildbookGuildInfoFrameStatsFrameClassHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.StatsFrame.ClassHeader:SetPoint('TOP', Guildbook.GuildFrame.StatsFrame.ClassFrame, 'TOP', 0, -5)
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

    -- set the function to call when pie chart segment is moused over
    self.GuildFrame.StatsFrame.ClassSummaryPieChart:SetSelectionFunc(classSummaryPieChart_SelectionFunc)
    
    -- set default values
    for k, class in pairs(self.GuildFrame.StatsFrame.ClassCount) do
        local r, g, b = unpack(Guildbook.Data.Class[class.Class].RGB)
        self.GuildFrame.StatsFrame.ClassSummaryPieChart:AddPie(10, {r*segCol, g*segCol, b*segCol});
    end
    self.GuildFrame.StatsFrame.ClassSummaryPieChart:CompletePie({0,0,0})

    -- func: this set all class counts to 0
    function self.GuildFrame.StatsFrame:ResetClassCount()
        for k, v in ipairs(self.ClassCount) do
            v.Count = 0
        end
        self.ClassSummaryPieChart:ResetPie()
    end
    
    -- func: loop the guild roster, here we use the blizz roster as it contains class data, then update the pie chart
    -- future option to add by level sorting?
    function self.GuildFrame.StatsFrame:UpdateClassChart()
        self:ResetClassCount()
        GuildRoster()
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local _, _, _, level, _, _, _, _, _, _, class, _, _, _, _, _, guid = GetGuildRosterInfo(i)
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

    -- func: loop the client guild roster cache and fetch spec data, we will use the character spec to determine role using the lookup table in Guildbook_Data
    -- when wrath comes along consider the DK specs>role data
    function self.GuildFrame.StatsFrame:GetClassRoleFromCache()
        local guildName = Guildbook:GetGuildName()
        if guildName then
            if GUILDBOOK_GLOBAL then
                if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
                    GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] = {}
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
                            if character.Level and tonumber(character.Level) >= self.MinLevelSlider:GetValue() then
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

    -- when we open the stats frame reset UI
    self.GuildFrame.StatsFrame:SetScript('OnShow', function(self)
        self:GetClassRoleFromCache()
        self:UpdateClassChart()
        self:GetProfessionCount()
    end)
end
















-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- calendar
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:SetupGuildCalendarFrame()

    --self.GuildFrame.GuildCalendarFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.GuildCalendarFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.GuildCalendarFrame, 'TOPRIGHT', -2, 2, 'Calendar')

    self.GuildFrame.GuildCalendarFrame.date = date('*t')

    local weekdays = {
        [1] = 'Monday',
        [2] = 'Tuesday',
        [3] = 'Wednesday',
        [4] = 'Thursday',
        [5] = 'Friday',
        [6] = 'Saturday',
        [7] = 'Sunday',
    }

    local monthNames = {
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
    }

    local status = {
        [0] = 'Decline',
        [1] = 'Confirmed',
        [2] = 'Tentative',
    }

    local daysInMonth = {
        [0] = 31.0, --used to calculate days before current month if current month is january
        [1] = 31.0,
        [2] = 28.0,
        [3] = 31.0,
        [4] = 30.0,
        [5] = 31.0,
        [6] = 30.0,
        [7] = 31.0,
        [8] = 31.0,
        [9] = 30.0,
        [10] = 31.0,
        [11] = 30.0,
        [12] = 31.0,
    }
    -- make quick calculation to see if leap year?

    local eventTypes = {
        { 
            text = 'Raid', 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 1
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'Raid')
            end, 
        },
        { 
            text = 'PVP', 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 2
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'PVP')
            end, 
        },
        { 
            text = 'Dungeon', 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 3
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'Dungeon')
            end, 
        },
        { 
            text = 'Meeting', 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 4
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'Meeting')
            end,  
        },
        { 
            text = 'Other', 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 5
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'Other')
            end,  
        },
    }
    local eventTypesReversed = {
        'Raid',
        'PVP',
        'Dungeon',
        'Meeting',
        'Other',
        'Event',
    }

    function self.GuildFrame.GuildCalendarFrame:GetDaysInMonth(month, year)
        local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
        local d = days_in_month[month]         
        -- check for leap year
        if (month == 2) then
            if year % 4 == 0 then
                if year % 100 == 0 then                
                    if year % 400 == 0 then                    
                        d = 29
                        end
                    else                
                    d = 29
                end
            end
        end
        -- print(d)
        return d
    end

    function self.GuildFrame.GuildCalendarFrame:GetMonthStart(month, year)
        local today = date('*t')
        today.day = 0
        today.month = month
        today.year = year
        local monthStart = date('*t', time(today))
        --print(monthStart.wday)
        return monthStart.wday
    end

    self.GuildFrame.GuildCalendarFrame.Header = self.GuildFrame.GuildCalendarFrame:CreateFontString('GuildbookGuildInfoFrameGuildCalendarFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildCalendarFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildCalendarFrame, 'TOP', 0, 4)
    self.GuildFrame.GuildCalendarFrame.Header:SetText('Guild Calendar')
    self.GuildFrame.GuildCalendarFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildCalendarFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.GuildCalendarFrame.NextMonthButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameNextMonthButton', self.GuildFrame.GuildCalendarFrame) --, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.NextMonthButton:SetPoint('TOP', 90, 25)
    self.GuildFrame.GuildCalendarFrame.NextMonthButton:SetSize(30, 30)
    self.GuildFrame.GuildCalendarFrame.NextMonthButton:SetNormalTexture(130866)
    self.GuildFrame.GuildCalendarFrame.NextMonthButton:SetPushedTexture(130865)
    self.GuildFrame.GuildCalendarFrame.NextMonthButton:SetScript('OnClick', function(self)
        if self:GetParent().date.month == 12 then
            self:GetParent().date.month = 1
            self:GetParent().date.year = self:GetParent().date.year + 1
        else
            self:GetParent().date.month = self:GetParent().date.month + 1
        end
        self:GetParent():MonthChanged()
    end)

    self.GuildFrame.GuildCalendarFrame.PrevMonthButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFramePrevMonthButton', self.GuildFrame.GuildCalendarFrame) --, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.PrevMonthButton:SetPoint('TOP', -90, 25)
    self.GuildFrame.GuildCalendarFrame.PrevMonthButton:SetSize(30, 30)
    self.GuildFrame.GuildCalendarFrame.PrevMonthButton:SetNormalTexture(130869)
    self.GuildFrame.GuildCalendarFrame.PrevMonthButton:SetPushedTexture(130868)
    self.GuildFrame.GuildCalendarFrame.PrevMonthButton:SetScript('OnClick', function(self)
        if self:GetParent().date.month == 1 then
            self:GetParent().date.month = 12
            self:GetParent().date.year = self:GetParent().date.year - 1
        else
            self:GetParent().date.month = self:GetParent().date.month - 1
        end
        self:GetParent():MonthChanged()
    end)

    self.GuildFrame.GuildCalendarFrame.CalendarParent = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameParent', Guildbook.GuildFrame.GuildCalendarFrame)
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetPoint('TOP', 0, -23)
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetPoint('BOTTOM', 0, 0)
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetWidth(490)

    -- draw days
    local CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH = 90 / 256 - 0.001
    local CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT = 90 / 256 - 0.001
    local dayW, dayH = 70, 53

    for i = 1, 7 do
        local f = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameDayHeaders'..i, Guildbook.GuildFrame.GuildCalendarFrame)
        f:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.GuildCalendarFrame.CalendarParent, 'TOPLEFT', (i - 1) * dayW, 1)
        f:SetSize(dayW, 18)
        f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
        f.background:SetAllPoints(f)
        f.background:SetTexture(235428)
        f.background:SetTexCoord(0.0, 0.35, 0.71, 0.81)
        f.text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.text:SetPoint('CENTER', 0, 0)
        f.text:SetTextColor(1,1,1,1)
        f.text:SetText(weekdays[i])
    end

    self.GuildFrame.GuildCalendarFrame.MonthView = {}
    local i, d = 1, 1
    for week = 1, 6 do
        for day = 1, 7 do
            local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameGuildCalendarFrameWeek'..week..'Day'..day), Guildbook.GuildFrame.GuildCalendarFrame.CalendarParent)
            f:SetPoint('TOPLEFT', ((day - 1) * dayW), ((week - 1) * dayH) * -1)
            f:SetSize(dayW, dayH)
            f:SetHighlightTexture(235438)
            f:GetHighlightTexture():SetTexCoord(0.0, 0.35, 0.0, 0.7)
            f:RegisterForClicks('AnyDown')
            f:SetEnabled(true)

            local texLeft = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
            local texRight = texLeft + CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
            local texTop = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
            local texBottom = texTop + CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
            f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
            f.background:SetPoint('TOPLEFT', 0, 0)
            f.background:SetPoint('BOTTOMRIGHT', 0, 0)
            f.background:SetTexture(235428)
            f.background:SetTexCoord(texLeft, texRight, texTop, texBottom)

            f.currentDayTexture = f:CreateTexture('$parentCurrentDayTexture', 'ARTWORK')
            f.currentDayTexture:SetPoint('TOPLEFT', -15, 15)
            f.currentDayTexture:SetPoint('BOTTOMRIGHT', 16, -10)
            f.currentDayTexture:SetTexture(235433)
            f.currentDayTexture:SetTexCoord(0.05, 0.55, 0.05, 0.55)
            f.currentDayTexture:Hide()

            f.eventTexture = f:CreateTexture('$parentBackground', 'ARTWORK')
            f.eventTexture:SetPoint('TOPLEFT', 0, 0)
            f.eventTexture:SetPoint('BOTTOMRIGHT', 0, 0)
            f.eventTexture:SetTexture(235448)
            f.eventTexture:SetTexCoord(0.0, 0.71, 0.0, 0.71)

            for e = 1, 3 do
                f['eventButton'..e] = CreateFrame('BUTTON', tostring('GuildbookGuildFrameGuildCalendarFrameWeek'..week..'Day'..day..'Button'..e), f)
                f['eventButton'..e]:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 1, ((e - 1) * 10) + 3)
                f['eventButton'..e]:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -1, ((e - 1) * 10) + 3)
                f['eventButton'..e]:SetHeight(10)
                f['eventButton'..e]:SetNormalFontObject(GameFontNormalSmall)
                f['eventButton'..e]:SetHighlightTexture(404984)
                f['eventButton'..e]:GetHighlightTexture():SetTexCoord(0.0, 0.6, 0.75, 0.85)
                f['eventButton'..e]:Hide()
                f['eventButton'..e].event = nil
                f['eventButton'..e]:SetScript('OnClick', function(self)
                    if self.event then
                        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:Hide()
                        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.event = self.event
                        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.dayButton = self:GetParent()
                        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:Show()
                    end
                end)
            end

            f.date = {}
            f.data = {} -- used ?
            f.events = {}

            f.dateText = f:CreateFontString('$parentDateText', 'OVERLAY', 'GameFontNormalSmall')
            f.dateText:SetPoint('TOPLEFT', 3, -3)
            f.dateText:SetTextColor(1,1,1,1)

            f:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                if f.dmf ~= false then
                    GameTooltip:AddLine('Darkmoon Faire '..f.dmf)
                end
                if self.events then
                    for k, v in ipairs(self.events) do
                        GameTooltip:AddLine('|cffffffff'..v.title)
                    end
                end
                GameTooltip:Show()
            end)
            f:SetScript('OnLeave', function(self)
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            end)

            f:SetScript('OnShow', function(self)
                for i = 1, 3 do
                    f['eventButton'..i]:Hide()
                    f['eventButton'..i]:SetText('')
                    f['eventButton'..i].event = nil
                end
                if self.events then
                    for k, event in ipairs(self.events) do
                        f['eventButton'..k]:Show()
                        f['eventButton'..k]:SetText('|cffffffff'..event.title)
                        f['eventButton'..k].event = event
                    end
                end
            end)
            
            f:SetScript('OnClick', function(self, button)
                if button == 'LeftButton' then
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:Hide()
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.date = self.date
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.event = nil
                    if #self.events > 2.0 then
                        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.enabled = false
                    else
                        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.enabled = true
                    end
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:Show()
                end
            end)

            Guildbook.GuildFrame.GuildCalendarFrame.MonthView[i] = f
            i = i + 1
        end
    end

    function self.GuildFrame.GuildCalendarFrame:GetWorldEventsForDay(day, month)
        local worldEvent = {}
        for worldEvent, info in pairs(Guildbook.CalendarWorldEvents) do
            if worldEvent ~= 'Darkmoon Faire' then
                if info.Start.day == day and info.Start.month == month then

                end
                if info.End.day == day and info.End.month == month then

                end
            end
        end
    end

    -- decided to limit calendar to current month only in order to reduce chat traffic

    function self.GuildFrame.GuildCalendarFrame:MonthChanged()
        self.Header:SetText(monthNames[self.date.month]..' '..self.date.year)
        local monthStart = self:GetMonthStart(self.date.month, self.date.year)
        local daysInMonth = self:GetDaysInMonth(self.date.month, self.date.year)
        local daysInLastMonth = 0
        if self.date.month == 1 then
            daysInLastMonth = self:GetDaysInMonth(12, self.date.year - 1)
        else
            daysInLastMonth = self:GetDaysInMonth(self.date.month - 1, self.date.year)
        end
        local d, nm = 1, 1
        for i, day in ipairs(Guildbook.GuildFrame.GuildCalendarFrame.MonthView) do
            day.events = nil
            day.dmf = false
            day:Disable()
            day.dateText:SetText(' ')
            day.eventTexture:SetTexture(nil)
            if i < monthStart then
                day.dateText:SetText((daysInLastMonth - monthStart + 2) + (i - 1))
                day.dateText:SetTextColor(0.5, 0.5, 0.5, 1)
            end
            if i >= monthStart and d <= daysInMonth then
                -- if d == self.date.day then
                --     day.currentDayTexture:Show()
                -- else
                --     day.currentDayTexture:Hide()
                -- end
                day.dateText:SetText(d)
                day.dateText:SetTextColor(1,1,1,1)
                day:Enable()
                day.date = {
                    day = d,
                    month = self.date.month,
                    year = self.date.year,
                }
                day:Hide()
                local dmf = 'Elwynn'
                if day.date.month % 2 == 0 then
                    dmf = 'Mulgore'
                end
                if i == 7 then
                    day.eventTexture:SetTexture(Guildbook.CalendarWorldEvents['Darkmoon Faire'][dmf]['Start'])
                    day.dmf = dmf
                end
                if i > 7 and i < 14 then
                    day.eventTexture:SetTexture(Guildbook.CalendarWorldEvents['Darkmoon Faire'][dmf]['OnGoing'])
                    day.dmf = dmf
                end
                if i == 14 then
                    day.eventTexture:SetTexture(Guildbook.CalendarWorldEvents['Darkmoon Faire'][dmf]['End'])
                    day.dmf = dmf
                end
                day.events = self:GetEventsForDate(day.date)
                day:Show()
                d = d + 1
            end
            if i > (daysInMonth + (monthStart - 1)) then
                day.dateText:SetText(nm)
                day.dateText:SetTextColor(0.5, 0.5, 0.5, 1)
                nm = nm + 1
            end
        end
    end

    self.GuildFrame.GuildCalendarFrame.EventFrame = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameEventFrame', self.GuildFrame.GuildCalendarFrame) --, "UIPanelDialogTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('TOPLEFT', GuildFrame, 'TOPRIGHT', 4, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('BOTTOMRIGHT', GuildFrame, 'BOTTOMRIGHT', 254, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame:SetBackdrop({
        edgeFile = "interface/dialogframe/ui-dialogbox-border",
        edgeSize = 32,
        bgFile = "interface/dialogframe/ui-dialogbox-background-dark",
        tile = true,
        tileEdge = false,
        tileSize = 200,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    self.GuildFrame.GuildCalendarFrame.EventFrame:Hide()
    self.GuildFrame.GuildCalendarFrame.EventFrame.data = nil
    self.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 6

    self.GuildFrame.GuildCalendarFrame.EventFrame.HeaderText = self.GuildFrame.GuildCalendarFrame.EventFrame:CreateFontString('$parentHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildCalendarFrame.EventFrame.HeaderText:SetPoint('TOP', 0, -16)

    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameCreateEventButton', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetPoint('BOTTOMLEFT', 10, 10)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetSize(115, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetText('Create Event')
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetScript('OnClick', function()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:CreateEvent()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameCancelEventButton', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:SetPoint('LEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton, 'RIGHT', 0, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:SetSize(115, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:SetText('Delete Event')
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:SetScript('OnClick', function(self)
        Guildbook:SendGuildCalendarEventDeleted(self:GetParent().event)
        self:GetParent().event = nil
        self:GetParent().CancelEventButton:Disable()
        self:GetParent().CreateEventButton:Enable()
        self:GetParent().EventTitleEditbox:SetText('')
        self:GetParent().EventTitleEditbox:Enable()
        self:GetParent().EventDescriptionEditbox:SetText('')
        self:GetParent().EventDescriptionEditbox:Enable()
        self:GetParent().AttendEventButton_Confirm:Disable()
        self:GetParent().AttendEventButton_Tentative:Disable()
        self:GetParent().AttendEventButton_Unable:Disable()
        self:GetParent():ResetClassCounts()
        self:GetParent():ResetAttending()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameCancelButton', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetPoint('TOPRIGHT', -10, -10)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetSize(24, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetNormalTexture(130832)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.85)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetHighlightTexture(130831)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetScript('OnClick', function(self)
        self:GetParent():Hide()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox = CreateFrame('EDITBOX', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventTitleEditbox', self.GuildFrame.GuildCalendarFrame.EventFrame, "InputBoxTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetPoint('TOPLEFT', 26, -70)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetSize(100, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:ClearFocus()
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetAutoFocus(false)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetMaxLetters(15)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox.header = self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:CreateFontString('$parentHeader', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox.header:SetPoint('BOTTOMLEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox, 'TOPLEFT', 0, 2)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox.header:SetText('Title')

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown = CreateFrame('FRAME', "GuildbookGuildFrameGuildCalendarFrameEventFrameEventTypeDropdown", self.GuildFrame.GuildCalendarFrame.EventFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown:SetPoint('LEFT', Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox, 'RIGHT', -10, -2)
    UIDropDownMenu_SetWidth(self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 75)
    UIDropDownMenu_SetText(self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'Event')
    _G['GuildbookGuildFrameGuildCalendarFrameEventFrameEventTypeDropdownButton']:SetScript('OnClick', function(self)
        EasyMenu(eventTypes, Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 10, 10, 'NONE')
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventDescriptionEditboxParent', self.GuildFrame.GuildCalendarFrame.EventFrame)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent:SetPoint('TOPLEFT', 20, -120)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent:SetSize(206, 80)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox = CreateFrame('EDITBOX', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventDescriptionEditbox', self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent) --, "InputBoxTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:SetPoint('TOP', Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent, 'TOP', 0, -8)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent, 'BOTTOM', 0, 8)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:SetWidth(186)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:SetFontObject(ChatFontNormal)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:ClearFocus()
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:SetAutoFocus(false)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:SetMaxLetters(100)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:SetMultiLine(true)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox.header = self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:CreateFontString('$parentHeader', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox.header:SetPoint('BOTTOMLEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox, 'TOPLEFT', -4, 8)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox.header:SetText('Description')

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventAttendeesListviewParent', self.GuildFrame.GuildCalendarFrame.EventFrame)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:SetPoint('TOPLEFT', 20, -250)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:SetSize(206, 120)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:EnableMouse(true)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendingListview = {}
    for i = 1, 10 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameGuildCalendarFrameEventFrameAttendListviewRow'..i), self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent)
        f:SetPoint('TOPLEFT', 0, ((i - 1) * -11) - 6)
        f:SetPoint('TOPRIGHT', -25, ((i - 1) * -11) - 6)
        f:SetHeight(11)
        f.character = f:CreateFontString('$parentCharacter', 'OVERLAY', 'GameFontNormalSmall')
        f.character:SetPoint('LEFT', 10, 0)
        f.character:SetText('Copperbolts')
        f.status = f:CreateFontString('$parentStatus', 'OVERLAY', 'GameFontNormalSmall')
        f.status:SetPoint('LEFT', 100, 0)
        f.status:SetText('Confirmed')
        self.GuildFrame.GuildCalendarFrame.EventFrame.AttendingListview[i] = f
    end
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventAttendeesListviewScrollBar', self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, "UIPanelScrollBarTemplate")
    --self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventAttendeesListviewScrollBar', self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, "OptionsSliderTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetOrientation('VERTICAL')
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetPoint('TOPRIGHT', -10, -25)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetHeight(78)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetWidth(10)
    --self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetPoint('TOPLEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, 'TOPRIGHT', -14, -22)
    --self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetPoint('BOTTOMRIGHT', self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, 'BOTTOMRIGHT', -14, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:EnableMouse(true)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetValueStep(1)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetValue(1)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetMinMaxValues(1,4)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateAttending()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameAttendEventButtonConfirm', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetPoint('TOPLEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent, 'BOTTOMLEFT', 0, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetSize(68, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetNormalFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetHighlightFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetDisabledFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetText('Attending')
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetScript('OnClick', function(self)
        local event = self:GetParent().event
        local guildName = Guildbook:GetGuildName()
        if guildName and event then
            Guildbook:SendGuildCalendarEventAttend(event, 1)
        end
    end)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameAttendEventButtonTentative', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetPoint('LEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm, 'RIGHT', 0, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetSize(68, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetNormalFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetHighlightFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetDisabledFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetText('Tentative')
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetScript('OnClick', function(self)
        local event = self:GetParent().event
        local guildName = Guildbook:GetGuildName()
        if guildName and event then
            Guildbook:SendGuildCalendarEventAttend(event, 2)
        end
    end)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameAttendEventButtonUnable', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable:SetPoint('LEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative, 'RIGHT', 0, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable:SetSize(68, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable:SetNormalFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable:SetHighlightFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable:SetDisabledFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable:SetText('Decline')
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Unable:SetScript('OnClick', function(self)
        local event = self:GetParent().event
        local guildName = Guildbook:GetGuildName()
        if guildName and event then
            Guildbook:SendGuildCalendarEventAttend(event, 0)
        end
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.ClassTabs = {}
    local classes = {
        [1] = 'DRUID',
        [2] = 'HUNTER',
        [3] = 'MAGE',
        [4] = 'PALADIN',
        [5] = 'PRIEST',
        [6] = 'ROGUE',
        [7] = 'SHAMAN',
        [8] = 'WARLOCK',
        [9] = 'WARRIOR',
    }
    for i = 1, 9 do 
        local class = Guildbook.Data.Class[classes[i]]
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameGuildCalendarFrameEventFrameClassTab'..classes[i]), self.GuildFrame.GuildCalendarFrame.EventFrame)
        f:SetPoint('TOPLEFT', self.GuildFrame.GuildCalendarFrame.EventFrame, 'TOPRIGHT', -4, (i * -32) + 10)
        f:SetSize(40, 40)
        -- tab border texture
        f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
        f.background:SetAllPoints(f)
        f.background:SetTexture(136831)
        -- class icon texture
        f.icon = f:CreateTexture('$parentBakground', 'ARTWORK')
        f.icon:SetPoint('TOPLEFT', 1, -6)
        f.icon:SetPoint('BOTTOMRIGHT', -15, 9)
        f.icon:SetTexture(class.Icon)
        f.icon:SetBlendMode('ADD')
        f.icon:SetVertexColor(0.3,0.3,0.3)
        -- class count text
        f.text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall') --Small')
        f.text:SetPoint('BOTTOMRIGHT', -18, 14)
        f.text:SetTextColor(1,1,1,1)
        f.text:SetText('0')
        f.text:SetFont("Fonts\\FRIZQT__.TTF", 10, 'OUTLINE')

        self.GuildFrame.GuildCalendarFrame.EventFrame.ClassTabs[classes[i]] = f
    end

    function self.GuildFrame.GuildCalendarFrame.EventFrame:ResetClassCounts()
        for k, v in pairs(self.ClassTabs) do
            v.icon:SetVertexColor(0.3,0.3,0.3)
            v.text:SetText('0')
        end
    end

    function self.GuildFrame.GuildCalendarFrame.EventFrame:ResetAttending()
        for k, v in ipairs(self.AttendingListview) do
            v.character:SetText('')
            v.status:SetText('')
        end
        self.EventAttendeesListviewScrollBar:SetValue(2)
        self.EventAttendeesListviewScrollBar:SetValue(1)
    end

    function self.GuildFrame.GuildCalendarFrame.EventFrame:UpdateClassTabs()
        if self.event and next(self.event.attend) then            
            local i = 0
            for guid, info in pairs(self.event.attend) do
                i = i + 1
                if not Guildbook.PlayerMixin then
                    Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                else
                    Guildbook.PlayerMixin:SetGUID(guid)
                end
                if Guildbook.PlayerMixin:IsValid() then
                    local _, class, _ = C_PlayerInfo.GetClass(Guildbook.PlayerMixin)
                    --local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                    if class then
                        local count = tonumber(self.ClassTabs[class].text:GetText())
                        self.ClassTabs[class].text:SetText(count + 1)
                        self.ClassTabs[class].icon:SetVertexColor(1,1,1)
                    end
                end
            end
        end
    end

    function self.GuildFrame.GuildCalendarFrame.EventFrame:UpdateAttending()
        local scroll = math.floor(self.EventAttendeesListviewScrollBar:GetValue())
        for k = 1, 10 do
            self.AttendingListview[k].character:SetText('')
            self.AttendingListview[k].status:SetText('')
        end
        if self.event and next(self.event.attend) then            
            local i = 0
            for guid, info in pairs(self.event.attend) do
                i = i + 1
                if not Guildbook.PlayerMixin then
                    Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                else
                    Guildbook.PlayerMixin:SetGUID(guid)
                end
                if Guildbook.PlayerMixin:IsValid() then
                    local _, class, _ = C_PlayerInfo.GetClass(Guildbook.PlayerMixin)
                    local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                    if name and class then
                        local count = tonumber(self.ClassTabs[class].text:GetText())
                        if i > ((scroll * 10) - 10) and i <= (scroll * 10) then
                            self.AttendingListview[i].character:SetText(Guildbook.Data.Class[class].FontColour..name)
                            self.AttendingListview[i].status:SetText(status[info.Status])
                        end
                    end
                end
            end
        end
    end

    self.GuildFrame.GuildCalendarFrame.EventFrame:SetScript('OnShow', function(self)
        self:ResetClassCounts()
        self:UpdateClassTabs()
        self:ResetAttending()
        self:UpdateAttending()
        if self.date then
            self.HeaderText:SetText(string.format('%s/%s/%s', self.date.day, self.date.month, self.date.year))
        end
        if self.event then
            self.EventTitleEditbox:SetText(self.event.title)
            self.EventTitleEditbox:Disable()
            self.EventDescriptionEditbox:SetText(self.event.desc)
            self.EventDescriptionEditbox:Disable()
            self.CreateEventButton:Disable()
            self.AttendEventButton_Confirm:Enable()
            self.AttendEventButton_Tentative:Enable()
            self.AttendEventButton_Unable:Enable()
            UIDropDownMenu_SetText(self.EventTypeDropdown, eventTypesReversed[self.event.type])
            if self.event.owner == UnitGUID('player') then
                self.CancelEventButton:Enable()
            else
                self.CreateEventButton:Disable()
            end
        else
            if self.enabled == true then
                self.CreateEventButton:Enable()
            else
                self.CreateEventButton:Disable()
            end
            self.CancelEventButton:Disable()
            self.EventTitleEditbox:SetText('')
            self.EventTitleEditbox:Enable()
            self.EventDescriptionEditbox:SetText('')
            self.EventDescriptionEditbox:Enable()
            self.AttendEventButton_Confirm:Disable()
            self.AttendEventButton_Tentative:Disable()
            self.AttendEventButton_Unable:Disable()
        end
    end)



    function self.GuildFrame.GuildCalendarFrame.EventFrame:RegisterEventDeleted(event)
        local guildName = Guildbook:GetGuildName()
        if guildName and event then
            if not GUILDBOOK_GLOBAL['CalendarDeleted'] then
                GUILDBOOK_GLOBAL['CalendarDeleted'] = {
                    [guildName] = {}
                }
            else
                if not GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
                    GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] = {}
                end
            end
            GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][tostring(event.owner..'>'..event.created)] = true
        end
    end

    function self.GuildFrame.GuildCalendarFrame.EventFrame:RemoveDeletedEvents()
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL['Calendar'][guildName] and GUILDBOOK_GLOBAL['CalendarDeleted'][guildName] then
            local keys = {}
            for k, v in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                if GUILDBOOK_GLOBAL['CalendarDeleted'][guildName][tostring(v.owner..'>'..v.created)] then
                    table.insert(keys, k)
                end
            end
            if next(keys) then
                for _, key in ipairs(keys) do
                    GUILDBOOK_GLOBAL['Calendar'][guildName][key] = nil
                end
            end
        end
        self:GetParent():MonthChanged()
    end


    function self.GuildFrame.GuildCalendarFrame.EventFrame:CreateEvent()
        local event = nil
        local title = self.EventTitleEditbox:GetText()
        local description = self.EventDescriptionEditbox:GetText()
        if description:len() == 0 then
            description = '-'
        end
        if title:len() > 0 and description:len() > 0 then
            event = {
                ['created'] = GetServerTime(),
                ['owner'] = UnitGUID('player'),
                ['type'] = self.eventType,
                ['title'] = title,
                ['desc'] = description,
                ['attend'] = {},
                ['date'] = self.date
            }
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
                if not GUILDBOOK_CHARACTER['MyEvents'] then
                    GUILDBOOK_CHARACTER['MyEvents'] = {}
                end
                table.insert(GUILDBOOK_CHARACTER['MyEvents'], {
                    ['created'] = GetServerTime(),
                    ['type'] = self.eventType,
                    ['title'] = title,
                    ['desc'] = description,
                })
                table.insert(GUILDBOOK_GLOBAL['Calendar'][guildName], event)
                self.EventTitleEditbox:SetText('')
                self.EventDescriptionEditbox:SetText('')
                self.eventType = 0
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'Event')
                print('|cffffffffEvent created!|r')
                Guildbook:SendGuildCalendarEvent(event)
                self:GetParent():MonthChanged()
            end
        else
            print('|cffffffffYou have not set a title!|r')
        end
    end

    
    function self.GuildFrame.GuildCalendarFrame:GetEventsForDate(date)
        local events = {}
        if date.day and date.month and date.year then
            local guildName = Guildbook:GetGuildName()
            if guildName and GUILDBOOK_GLOBAL['Calendar'] and GUILDBOOK_GLOBAL['Calendar'][guildName] then
                for k, event in pairs(GUILDBOOK_GLOBAL['Calendar'][guildName]) do
                    if event.date.day == date.day and event.date.month == date.month and event.date.year == date.year then
                        table.insert(events, event)
                        DEBUG('func', 'GuildCalendarFrame:GetEventsForDate', 'found: '..event.title)
                    end
                end
            end
        end
        return events
    end

    self.GuildFrame.GuildCalendarFrame:SetScript('OnShow', function(self)
        self:MonthChanged()
    end)

end











-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- profiles
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:SetupProfilesFrame()

    local helpText = [[
Guildbook.
|cffffffffYou can search for characters or items using Guildbook.

When you search a drop-down list will show possible matches, this list is
limited and if the results count exceeds the limit it won't show, so if 
nothing appears keep typing to narrow the results.

Recipe items will show a sub menu of characters who can craft the item.
Click the character to view the recipe item in their 'Professions' tab.
]]

    self.GuildFrame.ProfilesFrame.selectedGUID = nil

    self.GuildFrame.ProfilesFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.ProfilesFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.ProfilesFrame, 'TOPRIGHT', -2, 2, helpText)

    self.GuildFrame.ProfilesFrame:SetScript('OnShow', function(self)
        if not self.selectedGUID then
            self:LoadCharacterDetails(UnitGUID('player'), nil)
            self.DetailsTab:Show()
        end
    end)

    function self.GuildFrame.ProfilesFrame:ToggleTabs(id, frame)
        PanelTemplates_SetTab(Guildbook.GuildFrame.ProfilesFrame, id)
        self.DetailsTab:Hide()
        self.ProfessionsTab:Hide()
        self.TalentsTab:Hide()
        self:HideTalentGrid()
        frame:Show()
        self.activeTabID = id
        self.activeTabName = frame
    end
    
    local searchResults = {}
    local characterResults, professionResults, specResults, recipeResults = {}, {}, {}, {}
    self.GuildFrame.ProfilesFrame.SearchBox = CreateFrame('EDITBOX', 'GuildbookGuildFrameProfilesFrameSearchBox', self.GuildFrame.ProfilesFrame, "InputBoxTemplate")
    --self.GuildFrame.ProfilesFrame.SearchBox:SetPoint('LEFT', Guildbook.GuildFrame.ProfilesFrame.SearchProfessionCheckbox, 'RIGHT', 100, 0)
    self.GuildFrame.ProfilesFrame.SearchBox:SetPoint('TOP', -50, 22)
    self.GuildFrame.ProfilesFrame.SearchBox:SetSize(300, 22)
    self.GuildFrame.ProfilesFrame.SearchBox:ClearFocus()
    self.GuildFrame.ProfilesFrame.SearchBox:SetAutoFocus(false)
    self.GuildFrame.ProfilesFrame.SearchBox:SetMaxLetters(15)
    self.GuildFrame.ProfilesFrame.SearchBox:SetText('Search for...')
    self.GuildFrame.ProfilesFrame.SearchBox:SetScript('OnEditFocusGained', function(self)
        if self:GetText() == 'Search for...' then
            self:SetText('')
        else
            Guildbook.GuildFrame.ProfilesFrame:SearchText_OnChanged(self:GetText())
        end
    end)
    self.GuildFrame.ProfilesFrame.SearchBox:SetScript('OnTextChanged', function(self)
        Guildbook.GuildFrame.ProfilesFrame:SearchText_OnChanged(self:GetText())
    end)
    function self.GuildFrame.ProfilesFrame:SearchText_OnChanged(text)
        if text:len() > 1 then
            wipe(searchResults)
            wipe(characterResults)
            wipe(recipeResults)
            local guildName = Guildbook:GetGuildName()
            -- local match = false
            if guildName then
                local characterName
                for guid, character in pairs(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName]) do
                    if not Guildbook.PlayerMixin then
                        Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                    else
                        Guildbook.PlayerMixin:SetGUID(guid)
                    end
                    if Guildbook.PlayerMixin:IsValid() then
                        characterName = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                    end
                    -- search professions for recipe item match
                    if character.Profession1 ~= '-' then
                        local prof = tostring(character.Profession1)
                        if character[prof] then
                            for itemID, reagents in pairs(character[prof]) do
                                local itemName
                                if prof == 'Enchanting' then
                                    itemName = select(1, GetSpellInfo(itemID))
                                else
                                    itemName = select(1, GetItemInfo(itemID))
                                end
                                if itemName and itemName:lower():find(text:lower()) then
                                    if not recipeResults[itemName] then
                                        recipeResults[itemName] = {}
                                    end
                                    table.insert(recipeResults[itemName], {
                                        GUID = guid,
                                        Name = characterName,
                                    })
                                    --DEBUG('func', 'ProfilesFrame:SearchText_OnChanged', itemName..'-'..characterName..' inserted')
                                end
                            end
                        end
                    end
                    if character.Profession2 ~= '-' then
                        local prof = tostring(character.Profession2)
                        if character[prof] then
                            for itemID, reagents in pairs(character[prof]) do
                                local itemName
                                if prof == 'Enchanting' then
                                    itemName = select(1, GetSpellInfo(itemID))
                                else
                                    itemName = select(1, GetItemInfo(itemID))
                                end
                                if itemName and itemName:lower():find(text:lower()) then
                                    if not recipeResults[itemName] then
                                        recipeResults[itemName] = {}
                                    end
                                    table.insert(recipeResults[itemName], {
                                        GUID = guid,
                                        Name = characterName,
                                    })
                                    --DEBUG('func', 'ProfilesFrame:SearchText_OnChanged', itemName..'-'..characterName..' inserted')
                                end
                            end
                        end
                    end
                    -- search characters
                    if (character.Name:lower():find(text:lower())) then
                        table.insert(characterResults, {
                            GUID = guid,
                            Name = characterName,
                        })
                    end

                    searchResults = {
                        {
                            text = 'Characters',
                            isTitle = true,
                            notCheckable = true,
                        },
                    }
                    if next(characterResults) then
                        for k, info in ipairs(characterResults) do
                            table.insert(searchResults, {
                                text = info.Name,
                                notCheckable = true,
                                func = function()
                                    Guildbook.GuildFrame.ProfilesFrame:LoadCharacterDetails(info.GUID, nil)
                                    Guildbook.GuildFrame.ProfilesFrame.SearchBox:ClearFocus()
                                    Guildbook.GuildFrame.ProfilesFrame:ToggleTabs(1, self.DetailsTab)
                                end,
                            })
                        end
                    end
                    table.insert(searchResults, {
                        text = 'Recipe Items',
                        isTitle = true,
                        notCheckable = true,
                    })
                    if next(recipeResults) then
                        for itemName, characters in pairs(recipeResults) do
                            local characterList = {}
                            for k, info in ipairs(characters) do
                                table.insert(characterList, {
                                    text = info.Name,
                                    notCheckable = true,
                                    func = function()
                                        Guildbook.GuildFrame.ProfilesFrame:LoadCharacterDetails(info.GUID, itemName)
                                        Guildbook.GuildFrame.ProfilesFrame.SearchBox:ClearFocus()
                                        Guildbook.GuildFrame.ProfilesFrame:ToggleTabs(3, self.ProfessionsTab)
                                    end,
                                })
                            end
                            table.insert(searchResults, {
                                text = itemName,
                                notCheckable = true,
                                func = function()
                                    Guildbook.GuildFrame.ProfilesFrame.SearchBox:ClearFocus()
                                end,
                                hasArrow = true,
                                menuList = characterList
                            })
                        end
                    end
                end
            end
            -- monitor this limit
            if #searchResults > 2 and #searchResults < 60 then
                EasyMenu(searchResults, Guildbook.ContextMenu_DropDown, Guildbook.GuildFrame.ProfilesFrame.SearchBox, -10, 0)
            end
        else
            CloseDropDownMenus()
        end
    end

    function self.GuildFrame.ProfilesFrame:LoadCharacterDetails(guid, recipeFilter)
        self.selectedGUID = guid
        self:HideTalentGrid()
        self.ProfessionsTab:ClearReagentsListview()
        self.ProfessionsTab:ClearRecipesListview(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container)
        self.ProfessionsTab:ClearRecipesListview(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container)
        if not Guildbook.PlayerMixin then
            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            Guildbook.PlayerMixin:SetGUID(guid)
        end
        if Guildbook.PlayerMixin:IsValid() then
            --local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
            --local _, class, _ = C_PlayerInfo.GetClass(Guildbook.PlayerMixin)
            local sex = C_PlayerInfo.GetSex(Guildbook.PlayerMixin)
            local race = C_CreatureInfo.GetRaceInfo(C_PlayerInfo.GetRace(Guildbook.PlayerMixin)).clientFileString:upper()
            local raceTexture = Guildbook.Data.RaceIcons[C_PlayerInfo.GetSex(Guildbook.PlayerMixin)][race]
            local guildName = Guildbook:GetGuildName()

            if guid and race and raceTexture and guildName then
                if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
                    local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
                    -- load race background
                    C_Timer.After(0.2, function()
                        self.DetailsTab:ShowModelViewer(race)
                    end)
                    -- load race portrait
                    self.DetailsTab.Overlay.portrait:SetTexture(raceTexture)
                    -- load class icon
                    self.DetailsTab.Overlay.class:SetTexture(Guildbook.Data.Class[character.Class].IconID)
                    self.DetailsTab.Overlay.classText:SetText(string.format("%s%s", character.Class:sub(1,1), character.Class:sub(2):lower()))
                    -- set name and colour
                    self.DetailsTab.Overlay.name:SetText(character.Name)
                    local r, g, b = unpack(Guildbook.Data.Class[character.Class].RGB)
                    self.DetailsTab.Overlay.name:SetTextColor(r, g, b, 1)
                    -- set talent backgrounds
                    self.TalentsTab.Tab1.background:SetTexture(Guildbook.Data.TalentBackgrounds[Guildbook.Data.Talents[character.Class][1]])
                    self.TalentsTab.Tab2.background:SetTexture(Guildbook.Data.TalentBackgrounds[Guildbook.Data.Talents[character.Class][2]])
                    self.TalentsTab.Tab3.background:SetTexture(Guildbook.Data.TalentBackgrounds[Guildbook.Data.Talents[character.Class][3]])
                    -- update info panel
                    for k, v in pairs(self.DetailsTab.Overlay.InfoPanel.labels) do
                        --self.DetailsTab.Overlay.InfoPanel[k].Label:SetText('-')
                        self.DetailsTab.Overlay.InfoPanel[k].Level:SetText('-')
                        self.DetailsTab.Overlay.InfoPanel[k].Icon:SetTexture(nil)
                        if k:find('Profession') then
                            if character[k] then
                                self.DetailsTab.Overlay.InfoPanel[k].Label:SetText(character[k])
                                self.DetailsTab.Overlay.InfoPanel[k].Level:SetText(character[k..'Level'])
                                self.DetailsTab.Overlay.InfoPanel[k].Icon:SetTexture(Guildbook.Data.Profession[character[k]].IconID)
                            else
                                self.DetailsTab.Overlay.InfoPanel[k].Level:SetText(character[k])
                                --self.DetailsTab.Overlay.InfoPanel[k].Icon:SetTexture(Guildbook.Data.Profession[k].IconID)
                            end
                        else
                            self.DetailsTab.Overlay.InfoPanel[k].Icon:SetTexture(Guildbook.Data.Profession[k].IconID)
                        end
                    end

                    -- as there is potentially a large amount of data to send/receive we will stagger the calls
                    -- request order = talents, professions

                    -- send request for latest data - this could be made a manual operation but will leave as auto for now
                    -- load talents without checking saved vars, comms delay here is short
                    Guildbook:SendTalentInfoRequest(character.Name, 1)
                    C_Timer.After(0.5, function()
                        self:LoadCharacterTalents(character.Talents[1])
                        DEBUG('func', 'LoadCharacterDetails', 'loading talents from file')
                    end)

                    -- professions
                    -- load prof data from saved var file if it exists first, the comms delay here is noticable
                    if character['Profession1'] ~= '-' then
                        local prof1 = character['Profession1']
                        if character[prof1] and next(character[prof1]) then
                            self.ProfessionsTab:SetRecipesListviewData(prof1, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, character[prof1], recipeFilter)
                        end
                        C_Timer.After(1.0, function()
                            Guildbook:SendTradeSkillsRequest(character.Name, prof1)
                        end)
                        C_Timer.After(1.5, function()
                            Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:SetRecipesListviewData(prof1, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, character[prof1], recipeFilter)
                        end)
                    end
                    if character['Profession2'] ~= '-' then
                        local prof2 = character['Profession2']
                        if character[prof2] and next(character[prof2]) then
                            self.ProfessionsTab:SetRecipesListviewData(prof2, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, character[prof2], recipeFilter)
                        end
                        C_Timer.After(1.5, function()
                            Guildbook:SendTradeSkillsRequest(character.Name, prof2)
                        end)
                        C_Timer.After(2.0, function()
                            Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:SetRecipesListviewData(prof2, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, character[prof2], recipeFilter)
                        end)
                    end
                end
            else
                DEBUG('func', 'ProfilesFrame:LoadCharacterDetails', 'mixin error')
            end
        end
        CloseDropDownMenus()
    end

    function self.GuildFrame.ProfilesFrame:LoadCharacterTalents(talents)
        if type(talents) == 'table' then
            DEBUG('func', 'ProfilesFrame:LoadCharacterTalents', 'loading character talents')
            for k, info in ipairs(talents) do
                --print(info.Name, info.Rank, info.MaxRank, info.Icon, info.Tab, info.Row, info.Col)
                if self.TalentsTab.TalentGrid[info.Tab] and self.TalentsTab.TalentGrid[info.Tab][info.Row] then
                    self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col]:Show()
                    self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Icon:SetTexture(info.Icon)
                    --self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].talentIndex = info.TalentIndex
                    self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].name = info.Name
                    self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].rank = info.Rank
                    self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].maxRank = info.MxRnk
                    --self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Points:SetText(info.Rank) --string.format("%s / %s", info.Rank, info.MxRnk))
                    self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Points:Show()
                    self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].pointsBackground:Show()
                    if info.Rank > 0 then
                        self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Icon:SetDesaturated(false)
                        self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].background:SetVertexColor(1.0, 0.82, 0.0)
                        if info.Rank < info.MxRnk then
                            self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Points:SetText('|cff40BF40'..info.Rank)
                        else
                            self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Points:SetText('|cffFFFF00'..info.Rank)
                        end
                    else
                        self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Icon:SetDesaturated(true)
                        self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].background:SetVertexColor(0.5, 0.5, 0.5)
                        self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].Points:Hide()
                        self.TalentsTab.TalentGrid[info.Tab][info.Row][info.Col].pointsBackground:Hide()
                    end
                else

                end
            end
        end
    end
    
    self.GuildFrame.ProfilesFrame.HomeButton = CreateFrame('BUTTON', '$parentTab4', Guildbook.GuildFrame.ProfilesFrame, 'OptionsFrameTabButtonTemplate')
    self.GuildFrame.ProfilesFrame.HomeButton:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.ProfilesFrame, 'TOPLEFT', 50, 0)
    --self.GuildFrame.ProfilesFrame.HomeButton:SetSize(60, 30)
    self.GuildFrame.ProfilesFrame.HomeButton:SetText('Home')
    self.GuildFrame.ProfilesFrame.HomeButton:SetID(4)
    self.GuildFrame.ProfilesFrame.HomeButton:SetScript('OnClick', function(self)
        -- PanelTemplates_SetTab(Guildbook.GuildFrame.ProfilesFrame, 4)
        -- --Guildbook.GuildFrame.ProfilesFrame.HomeTab:Show()
        -- Guildbook.GuildFrame.ProfilesFrame.DetailsTab:Hide()
        -- Guildbook.GuildFrame.ProfilesFrame.TalentsTab:Hide()
        -- Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:Hide()

        -- --for now just load the player, will add editing in time
        -- Guildbook.GuildFrame.ProfilesFrame:LoadCharacterDetails(UnitGUID('player'), nil)
        -- Guildbook.GuildFrame.ProfilesFrame.DetailsTab:Show()
        -- PanelTemplates_SetTab(Guildbook.GuildFrame.ProfilesFrame, 4)
    end)

    self.GuildFrame.ProfilesFrame.HomeTab = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameHomeTab', self.GuildFrame.ProfilesFrame)
    self.GuildFrame.ProfilesFrame.HomeTab:SetPoint('TOPLEFT', self.GuildFrame.ProfilesFrame, 'TOPLEFT', 2, -2)
    self.GuildFrame.ProfilesFrame.HomeTab:SetPoint('BOTTOMRIGHT', self.GuildFrame.ProfilesFrame, 'BOTTOMRIGHT', -2, 2)
    self.GuildFrame.ProfilesFrame.HomeTab:Hide()
    
    self.GuildFrame.ProfilesFrame.DetailsButton = CreateFrame('BUTTON', '$parentTab1', Guildbook.GuildFrame.ProfilesFrame, 'OptionsFrameTabButtonTemplate')
    self.GuildFrame.ProfilesFrame.DetailsButton:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.ProfilesFrame, 'TOPRIGHT', -255, 0)
    --self.GuildFrame.ProfilesFrame.DetailsButton:SetSize(60, 30)
    self.GuildFrame.ProfilesFrame.DetailsButton:SetText('Details')
    self.GuildFrame.ProfilesFrame.DetailsButton:SetID(1)
    self.GuildFrame.ProfilesFrame.DetailsButton:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(Guildbook.GuildFrame.ProfilesFrame, 1)
        Guildbook.GuildFrame.ProfilesFrame.DetailsTab:Show()
        Guildbook.GuildFrame.ProfilesFrame.TalentsTab:Hide()
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:Hide()
    end)

    self.GuildFrame.ProfilesFrame.TalentButton = CreateFrame('BUTTON', '$parentTab2', Guildbook.GuildFrame.ProfilesFrame, 'OptionsFrameTabButtonTemplate')
    self.GuildFrame.ProfilesFrame.TalentButton:SetPoint('LEFT', Guildbook.GuildFrame.ProfilesFrame.DetailsButton, 'RIGHT', -16, 0)
    --self.GuildFrame.ProfilesFrame.TalentButton:SetSize(60, 30)
    self.GuildFrame.ProfilesFrame.TalentButton:SetText('Talents')
    self.GuildFrame.ProfilesFrame.TalentButton:SetID(2)
    self.GuildFrame.ProfilesFrame.TalentButton:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(Guildbook.GuildFrame.ProfilesFrame, 2)
        Guildbook.GuildFrame.ProfilesFrame.DetailsTab:Hide()
        Guildbook.GuildFrame.ProfilesFrame.TalentsTab:Show()
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:Hide()
    end)

    self.GuildFrame.ProfilesFrame.ProfessionsButton = CreateFrame('BUTTON', '$parentTab3', Guildbook.GuildFrame.ProfilesFrame, 'OptionsFrameTabButtonTemplate')
    self.GuildFrame.ProfilesFrame.ProfessionsButton:SetPoint('LEFT', Guildbook.GuildFrame.ProfilesFrame.TalentButton, 'RIGHT', -16, 0)
    --self.GuildFrame.ProfilesFrame.ProfessionsButton:SetSize(60, 30)
    self.GuildFrame.ProfilesFrame.ProfessionsButton:SetText('Professions')
    self.GuildFrame.ProfilesFrame.ProfessionsButton:SetID(3)
    self.GuildFrame.ProfilesFrame.ProfessionsButton:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(Guildbook.GuildFrame.ProfilesFrame, 3)
        Guildbook.GuildFrame.ProfilesFrame.DetailsTab:Hide()
        Guildbook.GuildFrame.ProfilesFrame.TalentsTab:Hide()
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:Show()
    end)

    self.GuildFrame.ProfilesFrame.DetailsTab = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameDetailsTab', self.GuildFrame.ProfilesFrame)
    self.GuildFrame.ProfilesFrame.DetailsTab:SetPoint('TOPLEFT', self.GuildFrame.ProfilesFrame, 'TOPLEFT', 2, -2)
    self.GuildFrame.ProfilesFrame.DetailsTab:SetPoint('BOTTOMRIGHT', self.GuildFrame.ProfilesFrame, 'BOTTOMRIGHT', -2, 2)
    self.GuildFrame.ProfilesFrame.DetailsTab:Hide()

    self.GuildFrame.ProfilesFrame.DetailsTab.ModelViewers = {}
    for k, v in pairs(Guildbook.RaceBackgrounds) do
        local f = CreateFrame('Model', 'GuildbookGuildFrameProfilesFrameModelViewer'..k, self.GuildFrame.ProfilesFrame.DetailsTab)
        --f:SetFrameStrata('LOW')
        --f:SetFrameLevel(0)
        f:SetPoint('TOPLEFT', 2, -2)
        f:SetPoint('BOTTOMRIGHT', -3, 3)
        f:SetModel(v.FileName)
        f:SetModelAlpha(0.9)
        f:Hide()
        self.GuildFrame.ProfilesFrame.DetailsTab.ModelViewers[k] = f
    end

    function self.GuildFrame.ProfilesFrame.DetailsTab:ShowModelViewer(model)
        for k, v in pairs(self.ModelViewers) do
            v:Hide()
        end
        self.ModelViewers[model]:Show()
    end

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameDetailsTabOverlay', self.GuildFrame.ProfilesFrame.DetailsTab)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay:SetAllPoints(self.GuildFrame.ProfilesFrame.DetailsTab)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay:SetFrameLevel(999)

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portraitBackground = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay:CreateTexture('$parentPortrait', 'BACKGROUND')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portraitBackground:SetPoint('TOPLEFT', -33, 33)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portraitBackground:SetSize(220, 220)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portraitBackground:SetTexture(652158)

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portrait = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay:CreateTexture('$parentPortrait', 'OVERLAY')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portrait:SetPoint('TOPLEFT', 30, -27)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portrait:SetSize(90, 90)

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.class = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay:CreateTexture('$parentClass', 'OVERLAY')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.class:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portrait, 'BOTTOMLEFT', -5.0, -15.0)
    --self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.class:SetPoint('TOPRIGHT', Guildbook.GuildFrame.ProfilesFrame.DetailsTab.Overlay.portrait, 'BOTTOMRIGHT', 0, 0)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.class:SetSize(25, 25)

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.classText = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalLarge')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.classText:SetPoint('LEFT', Guildbook.GuildFrame.ProfilesFrame.DetailsTab.Overlay.class,'RIGHT', 8, 0)
    --self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.classText:SetFont("Fonts\\FRIZQT__.TTF", 24, 'OUTLINE')

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.name = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalLarge')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.name:SetPoint('TOP', 0, -24)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.name:SetFont("Fonts\\FRIZQT__.TTF", 24, 'OUTLINE')

    -- zone/location
    -- guidl rank
    -- level, current xp, rested xp
    -- ilvl
    -- prof info
    -- spec, talent points 1/1/1

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel = CreateFrame('FRAME', "GuildbookGuildFrameProfilesFrameDetailsFrameAboutFrame", self.GuildFrame.ProfilesFrame.DetailsTab.Overlay)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:SetPoint('BOTTOMLEFT', 20, 20)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:SetSize(190, 140)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.background = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:CreateTexture("$parentBackground", 'BACKGROUND')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.background:SetPoint('TOPLEFT', 3, -3)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.background:SetPoint('BOTTOMRIGHT', -3, 3)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.background:SetColorTexture(0,0,0,0.6)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.header = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.header:SetPoint('TOP', 0, -10)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.header:SetText('Professions')
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.header:SetFont("Fonts\\FRIZQT__.TTF", 14)
    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.header:SetTextColor(1,1,1,1)

    self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.labels = {
        ['Profession1'] = {
            label = 'Profession1',
            offset = -20.0,
        },
        ['Profession2'] = {
            label = 'Profession2',
            offset = -40.0,
        },
        ['Cooking'] = {
            label = 'Cooking',
            offset = -60.0,
        },
        ['Fishing'] = {
            label = 'Fishing',
            offset = -80.0,
        },
        ['FirstAid'] = {
            label = 'First Aid',
            offset = -100.0,
        },
    }
    for k, v in pairs(self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel.labels) do
        local label = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        label:SetPoint('TOPLEFT', 32, v.offset - 12)
        label:SetText(v.label)
        label:SetTextColor(1,1,1,1)

        local level = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        level:SetPoint('TOPLEFT', 142, v.offset - 12)
        level:SetText(v.label)
        level:SetTextColor(1,1,1,1)

        local icon = self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel:CreateTexture(nil, 'ARTWORK')
        icon:SetPoint('TOPLEFT', 12, v.offset - 12)
        icon:SetSize(16, 16)
        self.GuildFrame.ProfilesFrame.DetailsTab.Overlay.InfoPanel[k] = { Label = label, Level = level, Icon = icon}
    end

    
    self.GuildFrame.ProfilesFrame.TalentsTab = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameTalentsTab', self.GuildFrame.ProfilesFrame)
    self.GuildFrame.ProfilesFrame.TalentsTab:SetPoint('TOPLEFT', self.GuildFrame.ProfilesFrame, 'TOPLEFT', 2, -2)
    self.GuildFrame.ProfilesFrame.TalentsTab:SetPoint('BOTTOMRIGHT', self.GuildFrame.ProfilesFrame, 'BOTTOMRIGHT', -2, 2)
    self.GuildFrame.ProfilesFrame.TalentsTab:Hide()

    self.GuildFrame.ProfilesFrame.TalentsTab.ScrollFrame = CreateFrame("ScrollFrame", "GuildbookGuildFrameProfilesFrameTalentsTabScrollFrame", self.GuildFrame.ProfilesFrame.TalentsTab, "UIPanelScrollFrameTemplate")
    self.GuildFrame.ProfilesFrame.TalentsTab.ScrollFrame:SetPoint("TOPLEFT", 2, -12)
    self.GuildFrame.ProfilesFrame.TalentsTab.ScrollFrame:SetPoint("BOTTOMRIGHT", -32, 6)
    self.GuildFrame.ProfilesFrame.TalentsTab.ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local newValue = self:GetVerticalScroll() - (delta * 20)
        if (newValue < 0) then
            newValue = 0;
        elseif (newValue > self:GetVerticalScrollRange()) then
            newValue = self:GetVerticalScrollRange()
        end
        self:SetVerticalScroll(newValue)
    end)
    local scrollChild = CreateFrame("Frame", nil, self.GuildFrame.ProfilesFrame.TalentsTab.ScrollFrame)
    scrollChild:SetPoint("TOPLEFT", 0, 0)
    scrollChild:SetSize(771, (Guildbook.NUM_TALENT_ROWS * 59) + 19)
    self.GuildFrame.ProfilesFrame.TalentsTab.ScrollFrame:SetScrollChild(scrollChild)

    -- create talent grid
    self.GuildFrame.ProfilesFrame.TalentsTab.TalentGrid = {}
    local colPoints = { 19.0, 78.0, 137.0, 196.0 }
    local rowPoints = { 19.0, 78.0, 137.0, 196.0, 255.0, 314.0, 373.0, 432.0, 491.0, 550.0, 609.0 }
    for spec = 1, 3 do
        self.GuildFrame.ProfilesFrame.TalentsTab.TalentGrid[spec] = {}
        for row = 1, Guildbook.NUM_TALENT_ROWS do
            self.GuildFrame.ProfilesFrame.TalentsTab.TalentGrid[spec][row] = {}
            for col = 1, 4 do
                local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameProfilesFrameTalentsTabScrollFrameTalent'..spec..row..col), scrollChild)
                f:SetSize(40, 40)
                f:SetPoint('TOPLEFT', (colPoints[col] + ((spec - 1) * 257.0)), rowPoints[row] * -1)

                -- background texture inc border
                f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
                f.background:SetPoint('TOPLEFT', -11, 11)
                f.background:SetPoint('BOTTOMRIGHT', 11, -11)
                f.background:SetTexture(130765)
                -- talent icon texture
                f.Icon = f:CreateTexture('$parentBackground', 'ARTWORK')
                f.Icon:SetPoint('TOPLEFT', 2, -2)
                f.Icon:SetPoint('BOTTOMRIGHT', -2, 2)
                -- talent points texture
                f.pointsBackground = f:CreateTexture('$parentPointsBackground', 'ARTWORK')
                f.pointsBackground:SetTexture(136960)
                f.pointsBackground:SetPoint('BOTTOMRIGHT', 16, -16)
                -- talents points font string
                f.Points = f:CreateFontString('$parentPointsText', 'OVERLAY', 'GameFontNormalSmall')
                f.Points:SetPoint('CENTER', f.pointsBackground, 'CENTER', 1, 0)

                f:SetScript('OnEnter', function(self)
                    if self.name then
                        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                        --GameTooltip:SetSpellByID(self.spellID)
                        GameTooltip:AddLine(self.name)
                        GameTooltip:AddLine(string.format("|cffffffff%s / %s|r", self.rank, self.maxRank))
                        GameTooltip:Show()
                    else
                        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                    end
                end)
                f:SetScript('OnLeave', function(self)
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)

                self.GuildFrame.ProfilesFrame.TalentsTab.TalentGrid[spec][row][col] = f
            end
        end
    end

    function self.GuildFrame.ProfilesFrame:HideTalentGrid()
        for spec = 1, 3 do
            for row = 1, Guildbook.NUM_TALENT_ROWS do
                for col = 1, 4 do
                    self.TalentsTab.TalentGrid[spec][row][col]:Hide()
                end
            end
        end
    end

    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundTop = self.GuildFrame.ProfilesFrame.TalentsTab:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundTop:SetPoint('TOPRIGHT', Guildbook.GuildFrame.ProfilesFrame.TalentsTab, 'TOPRIGHT', -3, -4)
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundTop:SetSize(30, 280)
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.9)
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundBottom = self.GuildFrame.ProfilesFrame.TalentsTab:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundBottom:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.ProfilesFrame.TalentsTab, 'BOTTOMRIGHT', -4, 4)
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.ProfilesFrame.TalentsTab.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.41)


    -- remove these frames
    local w, h = 257.0, 335.0
    local l, r, u, d = 0, 0.56, 0, 0.61
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab1 = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameTalentsTab_1', self.GuildFrame.ProfilesFrame.TalentsTab)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab1:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.TalentsTab, 'TOPLEFT', 2, -2)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab1:SetSize(w, h)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab1.background = self.GuildFrame.ProfilesFrame.TalentsTab.Tab1:CreateTexture('$parentBackground', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab1.background:SetAllPoints(Guildbook.GuildFrame.ProfilesFrame.TalentsTab.Tab1)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab1.background:SetTexCoord(l, r, u, d)

    self.GuildFrame.ProfilesFrame.TalentsTab.Tab2 = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameTalentsTab_2', self.GuildFrame.ProfilesFrame.TalentsTab)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab2:SetPoint('LEFT', Guildbook.GuildFrame.ProfilesFrame.TalentsTab.Tab1, 'RIGHT', 0, 0)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab2:SetSize(w, h)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab2.background = self.GuildFrame.ProfilesFrame.TalentsTab.Tab2:CreateTexture('$parentBackground', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab2.background:SetAllPoints(Guildbook.GuildFrame.ProfilesFrame.TalentsTab.Tab2)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab2.background:SetTexCoord(l, r, u, d)

    self.GuildFrame.ProfilesFrame.TalentsTab.Tab3 = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameTalentsTab_3', self.GuildFrame.ProfilesFrame.TalentsTab)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab3:SetPoint('LEFT', Guildbook.GuildFrame.ProfilesFrame.TalentsTab.Tab2, 'RIGHT', 0, 0)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab3:SetSize(w, h)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab3.background = self.GuildFrame.ProfilesFrame.TalentsTab.Tab3:CreateTexture('$parentBackground', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab3.background:SetAllPoints(Guildbook.GuildFrame.ProfilesFrame.TalentsTab.Tab3)
    self.GuildFrame.ProfilesFrame.TalentsTab.Tab3.background:SetTexCoord(l, r, u, d)






    self.GuildFrame.ProfilesFrame.ProfessionsTab = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameProfessionsTab', self.GuildFrame.ProfilesFrame)
    self.GuildFrame.ProfilesFrame.ProfessionsTab:SetPoint('TOPLEFT', self.GuildFrame.ProfilesFrame, 'TOPLEFT', 2, -2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab:SetPoint('BOTTOMRIGHT', self.GuildFrame.ProfilesFrame, 'BOTTOMRIGHT', -2, 2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab:Hide()
    self.GuildFrame.ProfilesFrame.ProfessionsTab:SetScript('OnShow', function(self)
        self:RefreshListview(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container)
        self:RefreshListview(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container)
    end)

    self.GuildFrame.ProfilesFrame.ProfessionsTab.TopBorder = self.GuildFrame.ProfilesFrame.ProfessionsTab:CreateTexture('GuildbookGuildInfoFrameProfilesFrameProfessionsTabTopBorder', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.TopBorder:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab, 'TOPLEFT', 2, -30)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.TopBorder:SetPoint('TOPRIGHT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab, 'TOPRIGHT', -2, -30)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.TopBorder:SetHeight(12)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.TopBorder:SetTexture(130968)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.TopBorder:SetTexCoord(0.1, 1.0, 0.0, 0.3)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.TopBorder:SetVertexColor(0.5,0.5,0.5,1)

    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container = CreateFrame('FRAME', nil, self.GuildFrame.ProfilesFrame.ProfessionsTab)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab, 'TOPLEFT', 2, -37)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab, 'BOTTOMLEFT', 250, 2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:SetSize(250, 210)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.background = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.background:SetAllPoints(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.background:SetColorTexture(0.2,0.2,0.2,0.2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:EnableMouse(true)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:SetScript('OnMouseWheel', function(self, delta)
        local s = self.ScrollBar:GetValue()
        self.ScrollBar:SetValue(s - delta)
    end)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.binding = {}
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.rows = {}

    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.header = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.header:SetPoint('TOP', 0, 29)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.header:SetTextColor(1,1,1,1)

    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundTop = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundTop:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, 'TOPRIGHT', -1, 2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundTop:SetSize(30, 280)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.9)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundBottom = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundBottom:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, 'BOTTOMRIGHT', -2, 0)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.41)

    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.ScrollBar = CreateFrame('SLIDER', nil, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, "UIPanelScrollBarTemplate")
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.ScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, 'TOPRIGHT', 28, -17)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, 'BOTTOMRIGHT', 0, 16)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.ScrollBar:EnableMouse(true)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.ScrollBar:SetValueStep(1)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.ScrollBar:SetValue(1)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.ScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:RefreshListview(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container) --, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.binding)
    end)

    for i = 1, 15 do
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameProfileFrameProfTabProf1'..i), self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container, 'TOPLEFT', 0, (i - 1) * -20)
        f:SetSize(257, 19)
        f:SetEnabled(true)
        f:RegisterForClicks('AnyDown')
        f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
        f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.Text:SetText('test text')
        f.id = i
        f.selected = false
        f.data = nil
        f:SetScript('OnClick', function(self)
            Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:ClearListviewSelected()
            if self.data then
                self.data.Selected = not self.data.Selected
            end
            Guildbook:UpdateListviewSelectedTextures(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.rows)
            if self.data then
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:ClearReagentsListview()
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:UpdateReagents(f.data)
                if self.data.Enchant then
                    Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.link = 'spell:'..self.data.ItemID
                    Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.spellID = self.data.ItemID
                else
                    Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.link = self.data.Link
                end
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemIcon:SetTexture(self.data.Icon)
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemName:SetText(self.data.Link)
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                self.Text:SetText(self.data.Link)
            else
                self:Hide()
            end
            Guildbook:UpdateListviewSelectedTextures(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.rows)
        end)
        f:SetScript('OnHide', function(self)
            self.data = nil
            self.Text:SetText(' ')
        end)
        self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.rows[i] = f
    end


    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container = CreateFrame('FRAME', nil, self.GuildFrame.ProfilesFrame.ProfessionsTab)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab, 'TOPLEFT', 277, -37)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab, 'BOTTOMLEFT', 277, 2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:SetSize(250, 210)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.background = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.background:SetAllPoints(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.background:SetColorTexture(0.2,0.2,0.2,0.2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:EnableMouse(true)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:SetScript('OnMouseWheel', function(self, delta)
        local s = self.ScrollBar:GetValue()
        self.ScrollBar:SetValue(s - delta)
    end)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.binding = {}
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.rows = {}

    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.header = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.header:SetPoint('TOP', 0, 29)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.header:SetTextColor(1,1,1,1)

    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundTop = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundTop:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, 'TOPRIGHT', -1, 2)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundTop:SetSize(30, 280)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.9)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundBottom = self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundBottom:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, 'BOTTOMRIGHT', -2, 0)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.41)

    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.ScrollBar = CreateFrame('SLIDER', nil, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, "UIPanelScrollBarTemplate")
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.ScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, 'TOPRIGHT', 28, -17)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, 'BOTTOMRIGHT', 0, 16)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.ScrollBar:EnableMouse(true)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.ScrollBar:SetValueStep(1)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.ScrollBar:SetValue(1)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.ScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:RefreshListview(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container) --, Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.binding)
    end)

    for i = 1, 15 do
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameProfileFrameProfTabProf2'..i), self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, 'TOPLEFT', 0, (i - 1) * -20)
        f:SetSize(257, 19)
        f:SetEnabled(true)
        f:RegisterForClicks('AnyDown')
        f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
        f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.Text:SetText('test text')
        f.id = i
        f.selected = false
        f.data = nil
        f:SetScript('OnClick', function(self)
            Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:ClearListviewSelected()
            if self.data then
                self.data.Selected = not self.data.Selected
            end
            Guildbook:UpdateListviewSelectedTextures(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.rows)
            if self.data then
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:ClearReagentsListview()
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:UpdateReagents(f.data)
                if self.data.Enchant then
                    Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.link = 'spell:'..self.data.ItemID
                    Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.spellID = self.data.ItemID
                else
                    Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.link = self.data.Link
                end
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemIcon:SetTexture(self.data.Icon)
                Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemName:SetText(self.data.Link)
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                self.Text:SetText(self.data.Link)
            else
                self:Hide()
            end
            Guildbook:UpdateListviewSelectedTextures(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.rows)
        end)
        f:SetScript('OnHide', function(self)
            self.data = nil
            self.Text:SetText(' ')
        end)
        self.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.rows[i] = f
    end








    function self.GuildFrame.ProfilesFrame.ProfessionsTab:ClearListviewSelected()
        for k, v in ipairs(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.rows) do
            if v.data then
                v.data.Selected = false
            end
        end
        Guildbook:UpdateListviewSelectedTextures(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession1Container.rows)
        for k, v in ipairs(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.rows) do
            if v.data then
                v.data.Selected = false
            end
        end
        Guildbook:UpdateListviewSelectedTextures(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container.rows)
    end

    function self.GuildFrame.ProfilesFrame.ProfessionsTab:ClearRecipesListview(listview)
        listview.header:SetText(' ')
        if next(listview.binding) then
            Guildbook:UpdateListviewSelectedTextures(listview.rows)
            for i = 1, 15 do
                listview.rows[i].selected = false
                listview.rows[i].data = nil
                listview.rows[i]:Hide()
            end
            wipe(listview.binding)
        end
    end


    function self.GuildFrame.ProfilesFrame.ProfessionsTab:RefreshListview(listview)
        if next(listview.binding) then
            Guildbook:UpdateListviewSelectedTextures(listview.rows)
            table.sort(listview.binding, function(a, b)
                if a.Rarity == b.Rarity then
                    return a.Name < b.Name
                else
                    return a.Rarity > b.Rarity
                end
            end)
            local c = #listview.binding
            if c <= 14 then
                listview.ScrollBar:SetMinMaxValues(1, 1)
            else
                listview.ScrollBar:SetMinMaxValues(1, (c - 14))
            end
            local scrollPos = math.floor(listview.ScrollBar:GetValue())
            if scrollPos == 0 then
                scrollPos = 1
            end
            for i = 1, 15 do
                if listview.binding[(i - 1) + scrollPos] then
                    listview.rows[i]:Hide()
                    listview.rows[i].data = listview.binding[(i - 1) + scrollPos]
                    listview.rows[i]:Show()
                end
            end
        end
    end
    
    function self.GuildFrame.ProfilesFrame.ProfessionsTab:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter, listview)
        local recipeItem = {
            ItemID = itemID,
            Link = link,
            Enchant = enchant,
            Rarity = tonumber(rarity),
            Reagents = {},
            Icon = tonumber(icon),
            Name = name,
            Selected = false,
        }
        for reagentID, count in pairs(reagents) do
            local reagentLink = select(2, GetItemInfo(reagentID))
            local reagentRarity = select(3, GetItemInfo(reagentID))
            table.insert(recipeItem.Reagents, {
                ItemID = reagentID,
                Count = tonumber(count),
            })
        end
        if filter == nil then
            --DEBUG('func', 'ProfilesFrame.ProfessionsTab:AddRecipe', string.format("added %s", name))
            table.insert(listview.binding, recipeItem)
        else
            if recipeItem.Name:lower():find(filter:lower(), 1, true) then
                --DEBUG('func', 'ProfilesFrame.ProfessionsTab:AddRecipe', string.format("found matching recipe: %s > %s", recipeItem.Name, filter))
                table.insert(listview.binding, recipeItem)
            end
        end
        self:RefreshListview(listview)
    end

    function self.GuildFrame.ProfilesFrame.ProfessionsTab:SetRecipesListviewData(profession, listview, data, filter)
        self:ClearRecipesListview(listview)
        --self:ClearReagentsListview()
        listview.header:SetText(profession..'   '..Guildbook.Data.Profession[profession].FontStringIconSMALL)
        if data and type(data) == 'table' and next(data) then
            local k = 1
            for itemID, reagents in pairs(data) do
                local link = false
                local rarity = false
                local icon = false
                local enchant = false
                if profession == 'Enchanting' then
                    link = select(1, GetSpellLink(itemID))
                    rarity = select(3, GetItemInfo(link)) or 1
                    name = select(1, GetSpellInfo(itemID)) or 'unknown'
                    icon = select(3, GetSpellInfo(itemID)) or 134400
                    enchant = true
                else
                    link = select(2, GetItemInfo(itemID))
                    rarity = select(3, GetItemInfo(itemID))
                    name = select(1, GetItemInfo(itemID))
                    icon = select(10, GetItemInfo(itemID))
                end
                if link and rarity and icon and name then
                    Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter, listview)
                    --DEBUG('func', 'ProfilesFrame.ProfessionsTab:SetRecipesListviewData', string.format('added recipe %s with rarity %s and icon %s, enchant=%s', link, rarity, icon, tostring(enchant)))
                else
                    if profession == 'Enchanting' then                    
                        local spell = Spell:CreateFromSpellID(spellID)
                        spell:ContinueOnSpellLoad(function()
                            link = select(1, GetSpellLink(itemID))
                            rarity =  1
                            name = select(1, GetSpellInfo(itemID)) or 'unknown'
                            icon = select(3, GetSpellInfo(itemID)) or 134400
                            enchant = true
                            Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter, listview)
                        end)
                    else
                        local item = Item:CreateFromItemID(itemID)
                        item:ContinueOnItemLoad(function()
                            icon = item:GetItemIcon()
                            name = item:GetItemName()
                            link = item:GetItemLink()
                            rarity = item:GetItemQuality()
                            enchant = false
                            Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter, listview)
                        end)
                    end
                end
            end
        end
    end

    -- reagents
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewRows = {}
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameReagentsListviewParent', self.GuildFrame.ProfilesFrame.ProfessionsTab)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.Profession2Container, 'BOTTOMRIGHT', 28, 0)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent:SetSize(264, 300)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.background = self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.background:SetAllPoints(Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)

    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem = CreateFrame('FRAME', 'GuildbookGuildFrameReagentsListviewParentRecipeItem', self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:SetPoint('TOPLEFT', 4, -4)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:SetSize(200, 25)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:EnableMouse(true)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.link = nil
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:SetScript('OnEnter', function(self)
        if self.link then
            GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:SetScript('OnMouseDown', function(self)
        if self.link then
            if IsShiftKeyDown() then
                if selectedProfession == 'Enchanting' and self.spellID then
                    HandleModifiedItemClick(GetSpellLink(self.spellID))
                else
                    HandleModifiedItemClick(self.link)
                end
            end
            if IsControlKeyDown() then
                DressUpItemLink(self.link)
            end
        end
    end)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemIcon = self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:CreateTexture('$parentRecipeItemIcon', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemIcon:SetPoint('LEFT', 4, 0)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemIcon:SetSize(25, 25)
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemName = self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem:CreateFontString('$parentRecipeItemName', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemName:SetPoint('TOPLEFT', self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemIcon, 'TOPRIGHT', 4, -4)

    for i = 1, 10 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameRecipesListviewRow'..i), self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent, 'TOPLEFT', 4, ((i - 1) * -22) - 35)
        f:SetSize(self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent:GetWidth(), 20)
        f:EnableMouse(true)

        f.icon = f:CreateTexture('$parentIcon', 'ARTWORK')
        f.icon:SetPoint('LEFT', 4, 0)
        f.icon:SetSize(20, 20)

        f.text = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.text:SetPoint('LEFT', f.icon, 'RIGHT', 4, 0)
        f.text:SetTextColor(1,1,1,1)

        f.link = nil
        f:SetScript('OnEnter', function(self)
            if self.link then
                GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
                GameTooltip:SetHyperlink(self.link)
                GameTooltip:Show()
            end
        end)
        f:SetScript('OnLeave', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)
        f:SetScript('OnMouseDown', function(self)
            if self.link then
                print('got link')
                if IsShiftKeyDown() then
                    HandleModifiedItemClick(self.link)
                end
                if IsControlKeyDown() then
                    print('ctrl')
                    DressUpItemLink(self.link)
                end
            end
        end)

        self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewRows[i] = f
    end

    function self.GuildFrame.ProfilesFrame.ProfessionsTab:ClearReagentsListview()
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItem.link = nil
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemIcon:SetTexture(nil)
        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent.recipeItemName:SetText(' ')
        for k, v in ipairs(self.ReagentsListviewRows) do
            v.icon:SetTexture(nil)
            v.text:SetText(' ')
            v.link = nil
        end
    end

    function self.GuildFrame.ProfilesFrame.ProfessionsTab:UpdateReagents(recipe)
        self:ClearReagentsListview()
        if recipe and recipe.Reagents then
            for k, v in ipairs(recipe.Reagents) do
                local link = select(2, GetItemInfo(v.ItemID))
                local icon = select(10, GetItemInfo(v.ItemID))
                if link and icon then
                    self.ReagentsListviewRows[k].icon:SetTexture(icon)
                    self.ReagentsListviewRows[k].text:SetText(string.format('[%s] %s', v.Count, link))
                    self.ReagentsListviewRows[k].link = link
                else
                    local item = Item:CreateFromItemID(v.ItemID)
                    item:ContinueOnItemLoad(function()
                        icon = item:GetItemIcon()
                        link = item:GetItemLink()
                        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewRows[k].icon:SetTexture(icon)
                        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewRows[k].text:SetText(string.format('[%s] %s', v.Count, link))
                        Guildbook.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewRows[k].link = link
                    end)
                end
            end
        end
    end

    self.GuildFrame.ProfilesFrame.ShowAllRecipesButton = CreateFrame("CheckButton", 'GuildbookGuildFrameProfilesFrameShowAllRecipesButton', self.GuildFrame.ProfilesFrame.ProfessionsTab.ReagentsListviewParent, "UIPanelButtonTemplate")
    self.GuildFrame.ProfilesFrame.ShowAllRecipesButton:SetPoint('TOPRIGHT', -20, 32)
    self.GuildFrame.ProfilesFrame.ShowAllRecipesButton:SetSize(125, 22)
    self.GuildFrame.ProfilesFrame.ShowAllRecipesButton:SetText('Show all recipes')
    self.GuildFrame.ProfilesFrame.ShowAllRecipesButton:SetScript('OnClick', function(self)
        Guildbook.GuildFrame.ProfilesFrame:LoadCharacterDetails(Guildbook.GuildFrame.ProfilesFrame.selectedGUID, nil)
    end)



    PanelTemplates_SetNumTabs(Guildbook.GuildFrame.ProfilesFrame, 4)
    PanelTemplates_SetTab(Guildbook.GuildFrame.ProfilesFrame, 1)
end
