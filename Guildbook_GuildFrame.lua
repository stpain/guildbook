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
local PRINT = Guildbook.PRINT

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- statistics frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupStatsFrame()

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
                    PRINT(Guildbook.FONT_COLOUR, 'local guild cache data not available, db created please wait for other players to send data')
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
-- tradeskill frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupTradeSkillFrame()

    local helpText = [[
|cffffd100Profession sharing|r
|cffffffffGuildbook allows guild members to share their profession recipes.
To do this players must first open their professions which will trigger a scan of available recipes and save this data.

To view another members profession, select the profession to see a list of members who have that profession.
When you select a guild member Guildbook will either use data saved on file or request data from the member.|r

|cff06B200If recipes do not show correctly selecting the player again will usually fix the UI.|r
]]

    self.GuildFrame.TradeSkillFrame.HelperIcon = CreateFrame('FRAME', 'GuildbookGuildInfoFrameTradeSkillFrameHelperIcon', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.HelperIcon:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPLEFT', 100, 2)
    self.GuildFrame.TradeSkillFrame.HelperIcon:SetSize(20, 20)
    self.GuildFrame.TradeSkillFrame.HelperIcon.texture = self.GuildFrame.TradeSkillFrame.HelperIcon:CreateTexture('$parentTexture', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.HelperIcon.texture:SetAllPoints(self.GuildFrame.TradeSkillFrame.HelperIcon)
    self.GuildFrame.TradeSkillFrame.HelperIcon.texture:SetTexture(374216)
    self.GuildFrame.TradeSkillFrame.HelperIcon:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
        GameTooltip:AddLine(helpText)
        GameTooltip:Show()
    end)
    self.GuildFrame.TradeSkillFrame.HelperIcon:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    -- hmmm? char not used but prof is - consider better
    local selectedCharacter = nil
    local selectedProfession = nil

    -- table to hold recipe listview data
    self.GuildFrame.TradeSkillFrame.RecipesTable = {}

    function self.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(listview)
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
                Guildbook.GuildFrame.TradeSkillFrame:HideCharacterListviewButtons()
                selectedProfession = prof.Name
                Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValue(1)
                Guildbook.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof.Name)
                Guildbook.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearRecipesListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionIcon:SetTexture(Guildbook.Data.Profession[prof.Name].Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('|cffffffff'..Guildbook.Data.ProfessionDescriptions[prof.Name]..'|r')
                Guildbook.GuildFrame.TradeSkillFrame.RecipesTable = {}
                DEBUG('selected '..prof.Name)
            end)
            profButtonPosY = profButtonPosY + 21
        end
    end

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
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameCharactersListviewRow'..i), self.GuildFrame.TradeSkillFrame.CharactersListviewParent )--, "OptionsListButtonTemplate")
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'TOPLEFT', 0, (i - 1) * -21)
        f:SetSize(self.GuildFrame.TradeSkillFrame.CharactersListviewParent:GetWidth(), 20)
        --f:EnableMouse(true)
        f:SetEnabled(true)
        f:RegisterForClicks('AnyDown')
        f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
        f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.id = i
        f.selected = false
        f.data = nil
        f:SetScript('OnClick', function(self, button)
            for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows) do
                if v.data then
                    v.data.Selected = false
                end
            end
            if self.data then
                self.data.Selected = not self.data.Selected
            end
            Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows)
            if self.data then
                -- offer context menu with request update
                if button == 'RightButton' then
                    Guildbook.ContextMenu = {
                        { text = 'Options', isTitle = true, notCheckable = true, },
                        { text = 'Request data', notCheckable = true, func = function()
                            Guildbook.GuildFrame.TradeSkillFrame:RequestProfessionData(self.data.Name, selectedProfession)
                        end, },
                        { text = 'Cancel', notCheckable = true, func = function()
                            CloseDropDownMenus()
                        end, },
                    }
                    EasyMenu(Guildbook.ContextMenu, Guildbook.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
                else
                    local guildName = Guildbook:GetGuildName()
                    -- if we have any recipes already on file, load these, this avoids sending additional chat messages, updates can be requested
                    if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession] and type(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession]) == 'table' then
                        DEBUG('recipe database found on file, loading data for: '..selectedProfession)
                        Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession])
                    else
                        -- send request and show cooldown UI so player is aware something is happening
                        DEBUG('no data on file, sending request to: '..self.data.Name..' for data: '..selectedProfession)
                        Guildbook.GuildFrame.TradeSkillFrame:RequestProfessionData(self.data.Name, selectedProfession)
                    end
                end
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
        self.GuildFrame.TradeSkillFrame.CharactersListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:RequestProfessionData(character, prof)
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        self.RecipesTable = {}
        Guildbook:SendTradeSkillsRequest(character, prof)
        self.RecipesListviewParent.ProgressCooldown:Show()
        self.RecipesListviewParent.ProgressCooldown.cooldown:SetCooldown(GetTime(), 4.0)
        for i = 1, 10 do
            self.CharactersListviewRows[i]:Disable()
        end
        C_Timer.After(4.5, function()
            for i = 1, 10 do
                self.CharactersListviewRows[i]:Enable()
            end
            Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:Hide()
            Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(self.RecipesTable)
        end)
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
                        GUID = guid,
                        Selected = false,
                    })
                    DEBUG('added '..character.Name..' to list')
                end
                if prof == 'Cooking' and character.CookingLevel and tonumber(character.CookingLevel) > 0.0 then
                    table.insert(self.CharactersWithProf, {
                        Name = character.Name,
                        GUID = guid,
                        Selected = false,
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

    function self.GuildFrame.TradeSkillFrame:HideCharacterListviewButtons()
        for i = 1, 10 do
            self.CharactersListviewRows[i]:Hide()
        end
        self.UpdateListviewSelectedTextures(self.CharactersListviewRows)
    end

    function self.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
        self:HideCharacterListviewButtons()
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

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown = CreateFrame('FRAME', 'GuildbookGuildFrameRecipesListviewParentCooldown', self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:SetPoint('CENTER', 0, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:SetSize(40, 40)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.texture = self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:CreateTexture('$parentTexture', 'BACKGROUND')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.texture:SetAllPoints(self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.texture:SetTexture(132996)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.cooldown = CreateFrame("Cooldown", "$parentCooldown", Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown, "CooldownFrameTemplate")
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.cooldown:SetAllPoints(self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:Hide()

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
        Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
    end)

    -- create recipes with prof listview
    for i = 1, 10 do
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameRecipesListviewRow'..i), self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPLEFT', 0, (i - 1) * -21)
        f:SetSize(self.GuildFrame.TradeSkillFrame.RecipesListviewParent:GetWidth(), 20)
        f:SetEnabled(true)
        f:RegisterForClicks('AnyDown')
        f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
        f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.id = i
        f.selected = false
        f.data = nil
        f:SetScript('OnClick', function(self)
            for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows) do
                if v.data then
                    v.data.Selected = false
                end
            end
            if self.data then
                self.data.Selected = not self.data.Selected
            end
            Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
            if self.data then
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook.GuildFrame.TradeSkillFrame:UpdateReagents(f.data)
                if self.data.Enchant then
                    Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.Link = 'enchant:'..self.data.ItemID
                else
                    Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.Link = self.data.Link
                end
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetTexture(self.data.Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetText(self.data.Link)
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                self.Text:SetText(self.data.Link)
            end
            Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
        end)
        f:SetScript('OnHide', function(self)
            self.data = nil
            self.Text:SetText(' ')
        end)
        self.GuildFrame.TradeSkillFrame.RecipesListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:ClearRecipesListview()
        self.UpdateListviewSelectedTextures(self.RecipesListviewRows)
        for i = 1, 10 do
            self.RecipesListviewRows[i].selected = false
            self.RecipesListviewRows[i].data = nil
            self.RecipesListviewRows[i]:Hide()
        end
        wipe(self.Recipes)
    end

    function self.GuildFrame.TradeSkillFrame:SetRecipesListviewData(data)
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        if data then
            print(type(data))
            if type(data) == 'table' then
                for k, v in pairs(data) do
                    print(k, v)
                    if type(v) == 'table' then
                        for x, y in pairs(v) do
                            print('    ', x, y)
                        end
                    end
                end
            end
        end
        if data and type(data) == 'table' and next(data) then
            --wipe(self.Recipes)
            for itemID, reagents in pairs(data) do
                local link = false
                local rarity = false
                local icon = false
                local enchant = false
                if selectedProfession == 'Enchanting' then
                    link = select(1, GetSpellLink(itemID))
                    rarity = select(3, GetItemInfo(link)) or 1
                    icon = select(3, GetSpellInfo(itemID)) or 134400
                    enchant = true
                    DEBUG(string.format('added enchant %s with rarity %s and icon %s', link, rarity, icon))
                else
                    link = select(2, GetItemInfo(itemID))
                    rarity = select(3, GetItemInfo(itemID))
                    icon = select(10, GetItemInfo(itemID))
                end
                if link and rarity and icon then
                    local recipeItem = {
                        ItemID = itemID,
                        Link = link,
                        Enchant = enchant,
                        Rarity = tonumber(rarity),
                        Reagents = {},
                        Icon = tonumber(icon),
                        Selected = false,
                    }
                    DEBUG(string.format('add %s to recipe list', link))
                    for reagentID, count in pairs(reagents) do
                        local reagentLink = select(2, GetItemInfo(reagentID))
                        local reagentRarity = select(3, GetItemInfo(reagentID))
                        table.insert(recipeItem.Reagents, {
                            Link = reagentLink,
                            Rarity = tonumber(reagentRarity),
                            Count = tonumber(count),
                        })
                        DEBUG(string.format('add %s to reagents list', reagentID))
                    end
                    table.insert(self.Recipes, recipeItem)
                end
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
            for i = 1, 10 do
                Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows[i]:Hide()
                Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows[i].data = self.Recipes[i]
                Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows[i]:Show()
            end

        end

    end

    -- reagents
    self.GuildFrame.TradeSkillFrame.Reagents = {'test'}
    self.GuildFrame.TradeSkillFrame.ReagentsListviewRows = {}
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameReagentsListviewParent', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', 28, 0)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:SetSize(250, 210)
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
        --wipe(self.Reagents)

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

    self.GuildFrame.TradeSkillFrame:SetScript('OnShow', function(self)
        DEBUG('showing tradeskill frame')
        self:HideCharacterListviewButtons()
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        Guildbook.GuildFrame.TradeSkillFrame.ProfessionIcon:SetTexture(nil)
        Guildbook.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('|cffffffffSelect a profession to see members of your guild who are trained in that profession.|r|cff0070DE Right click player for more options.|r \nThis feature can result in bulk comms, DO NOT spam click character names, there may be a need to click twice but twice only!')
    end)

end





-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupGuildBankFrame()

    self.GuildFrame.GuildBankFrame.bankCharacter = nil

    self.GuildFrame.GuildBankFrame:SetScript('OnShow', function(self)
        self:BankCharacterSelectDropDown_Init()
    end)

    self.GuildFrame.GuildBankFrame.Header = self.GuildFrame.GuildBankFrame:CreateFontString('GuildbookGuildInfoFrameGuildBankFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildBankFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildBankFrame, 'TOP', 0, 4)
    self.GuildFrame.GuildBankFrame.Header:SetText('Guild Bank')
    self.GuildFrame.GuildBankFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildBankFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.GuildBankFrame.ProgressCooldown = CreateFrame('FRAME', 'GuildbookGuildFrameRecipesListviewParentCooldown', self.GuildFrame.GuildBankFrame)
    self.GuildFrame.GuildBankFrame.ProgressCooldown:SetPoint('LEFT', 80, 0)
    self.GuildFrame.GuildBankFrame.ProgressCooldown:SetSize(40, 40)
    self.GuildFrame.GuildBankFrame.ProgressCooldown.texture = self.GuildFrame.GuildBankFrame.ProgressCooldown:CreateTexture('$parentTexture', 'BACKGROUND')
    self.GuildFrame.GuildBankFrame.ProgressCooldown.texture:SetAllPoints(self.GuildFrame.GuildBankFrame.ProgressCooldown)
    self.GuildFrame.GuildBankFrame.ProgressCooldown.texture:SetTexture(132996)
    self.GuildFrame.GuildBankFrame.ProgressCooldown.cooldown = CreateFrame("Cooldown", "$parentCooldown", Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown, "CooldownFrameTemplate")
    self.GuildFrame.GuildBankFrame.ProgressCooldown.cooldown:SetAllPoints(self.GuildFrame.GuildBankFrame.ProgressCooldown)
    self.GuildFrame.GuildBankFrame.ProgressCooldown:Hide()

    self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown = CreateFrame('FRAME', 'GuildbookGuildFrameGuildBankFrameBankCharacterSelectDropDown', self.GuildFrame.GuildBankFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown:SetPoint('TOPLEFT', self.GuildFrame.GuildBankFrame, 'TOPLEFT', 0, -48)
    UIDropDownMenu_SetWidth(self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown, 150)
    UIDropDownMenu_SetText(self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown, 'Select Bank Character')
    function self.GuildFrame.GuildBankFrame:BankCharacterSelectDropDown_Init()
        UIDropDownMenu_Initialize(self.BankCharacterSelectDropDown, function(self, level, menuList)
            GuildRoster()
            local gbc = {}
            local totalMembers, onlineMembers, _ = GetNumGuildMembers()
            for i = 1, totalMembers do
                local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
                if publicNote:lower():find('guildbank') then
                    table.insert(gbc, name:match("^(.-)%-"))
                end
            end
            local info = UIDropDownMenu_CreateInfo()
            for k, p in pairs(gbc) do
                info.text = p
                info.hasArrow = false
                info.keepShownOnClick = false
                info.func = function()
                    Guildbook.GuildFrame.GuildBankFrame.bankCharacter = p
                    Guildbook.GuildFrame.GuildBankFrame.ResetSlots()
                    Guildbook:SendGuildBankCommitRequest(p)
                    Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown:Show()
                    Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown.cooldown:SetCooldown(GetTime(), 3.5)
                    -- for now delay the data request to allow commit checks first, could look to improve this or at the very least just reduce the delay
                    C_Timer.After(4, function()
                        Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown:Hide()
                        if Guildbook.GuildBankCommit.Character and Guildbook.GuildBankCommit.Commit and Guildbook.GuildBankCommit.BankCharacter then
                            Guildbook:SendGuildBankDataRequest()
                            DEBUG(string.format('using %s as has newest commit, sending request for guild bank data - delayed', Guildbook.GuildBankCommit['BankCharacter']))
                            local ts = date('*t', Guildbook.GuildBankCommit.Commit)
                            ts.min = string.format('%02d', ts.min)
                            Guildbook.GuildFrame.GuildBankFrame.CommitInfo:SetText(string.format('Commit: %s:%s:%s  %s-%s-%s', ts.hour, ts.min, ts.sec, ts.day, ts.month, ts.year))
                            Guildbook.GuildFrame.GuildBankFrame.CommitSource:SetText(string.format('Commit Source: %s', Guildbook.GuildBankCommit.Character))
                            Guildbook.GuildFrame.GuildBankFrame.CommitBankCharacter:SetText(string.format('Bank Character: %s', Guildbook.GuildBankCommit.BankCharacter))
                        end
                    end)
                    DEBUG('requesting guild bank data from: '..p)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end

    self.GuildFrame.GuildBankFrame.CommitInfo = self.GuildFrame.GuildBankFrame:CreateFontString('$parentCommitInfo', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildBankFrame.CommitInfo:SetPoint('TOP', Guildbook.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown, 'BOTTOM', 0, -2)
    self.GuildFrame.GuildBankFrame.CommitInfo:SetSize(220, 20)
    self.GuildFrame.GuildBankFrame.CommitInfo:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildBankFrame.CommitSource = self.GuildFrame.GuildBankFrame:CreateFontString('$parentCommitSource', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildBankFrame.CommitSource:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame.CommitInfo, 'BOTTOMLEFT', 0, -2)
    self.GuildFrame.GuildBankFrame.CommitSource:SetSize(220, 20)
    self.GuildFrame.GuildBankFrame.CommitSource:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildBankFrame.CommitBankCharacter = self.GuildFrame.GuildBankFrame:CreateFontString('$parentCommitBankCharacter', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildBankFrame.CommitBankCharacter:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame.CommitSource, 'BOTTOMLEFT', 0, -2)
    self.GuildFrame.GuildBankFrame.CommitBankCharacter:SetSize(220, 20)
    self.GuildFrame.GuildBankFrame.CommitBankCharacter:SetTextColor(1,1,1,1)

    self.GuildFrame.GuildBankFrame.BankSlots = {}
    local slotIdx, slotWidth = 1, 40
    for column = 1, 14 do
        local x = ((column - 1) * slotWidth) + 205
        for row = 1, 7 do            
            local y = ((row -1) * -slotWidth) - 30
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
            f.background:SetPoint('TOPLEFT', -11, 11)
            f.background:SetPoint('BOTTOMRIGHT', 11, -11)
            f.background:SetTexture(130766)
            f.icon = f:CreateTexture('$parentBackground', 'ARTWORK')
            f.icon:SetPoint('TOPLEFT', 2, -2)
            f.icon:SetPoint('BOTTOMRIGHT', -2, 2)
            f.count = f:CreateFontString('$parentCount', 'OVERLAY', 'GameFontNormal') --Small')
            f.count:SetPoint('BOTTOMRIGHT', -4, 3)
            f.count:SetTextColor(1,1,1,1)
            f.itemID = nil

            f:SetScript('OnEnter', function(self)
                if self.itemID then
                    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                    GameTooltip:SetItemByID(self.itemID)
                    GameTooltip:Show()
                else
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end
            end)
            f:SetScript('OnLeave', function(self)
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            end)

            self.GuildFrame.GuildBankFrame.BankSlots[slotIdx] = f
            slotIdx = slotIdx + 1
        end
    end

    function self.GuildFrame.GuildBankFrame:ResetSlots()
        for k, slot in pairs(Guildbook.GuildFrame.GuildBankFrame.BankSlots) do
            slot.background:SetTexture(130766)
            slot.icon:SetTexture(nil)
            slot.count:SetText(' ')
            slot.itemID = nil
        end
    end

    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop = self.GuildFrame.GuildBankFrame:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetPoint('TOPRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -3, -4)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetSize(30, 280)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.9)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom = self.GuildFrame.GuildBankFrame:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', -4, 4)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.41)

    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameBankSlotsScrollBar', Guildbook.GuildFrame.GuildBankFrame, "UIPanelScrollBarTemplate")
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -26, -26)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', -10, 22)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:EnableMouse(true)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetValueStep(1)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetValue(1)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetMinMaxValues(1,3)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.GuildBankFrame:RefreshSlots()
    end)

    self.GuildFrame.GuildBankFrame.BankData = {}
    function self.GuildFrame.GuildBankFrame:ProcessBankData(data)
        wipe(self.BankData)
        local c = 0
        for id, count in pairs(data) do
            table.insert(Guildbook.GuildFrame.GuildBankFrame.BankData, {
                ItemID = id,
                Count = count,
            })
            c = c + 1
        end
        DEBUG(string.format('processed %s bank items from data', c))
        self.BankSlotsScrollBar:SetValue(1)
    end

    -- function self.GuildFrame.GuildBankFrame:RefreshSlots()
    --     if bankCharacter and GUILDBOOK_CHARACTER['GuildBank'] and GUILDBOOK_CHARACTER['GuildBank'][bankCharacter] then
    --         local slot, c = 1, 1
    --         for id, count in pairs(GUILDBOOK_CHARACTER['GuildBank'][bankCharacter].Data) do
    --             self.BankSlots[slot].icon:SetTexture(C_Item.GetItemIconByID(id))
    --             self.BankSlots[slot].count:SetText(count)
    --             self.BankSlots[slot].itemID = id

    --             -- NOTE: leaving this here in case its required in future updates etc
    --             -- local item = Item:CreateFromItemID(id)
    --             -- item:ContinueOnItemLoad(function()
    --             --     self.BankSlots[slot].icon:SetTexture(item:GetItemIcon())
    --             --     self.BankSlots[slot].data = { ItemID = id, Count = count }
    --             -- end)
    --             slot = slot + 1
    --         end
    --     end
    -- end

    function self.GuildFrame.GuildBankFrame:RefreshSlots()
        if self.bankCharacter and GUILDBOOK_CHARACTER['GuildBank'] and GUILDBOOK_CHARACTER['GuildBank'][self.bankCharacter] then
            local scrollPos = math.floor(self.BankSlotsScrollBar:GetValue())
            for i = 1, 98 do                
                if Guildbook.GuildFrame.GuildBankFrame.BankData[i + ((scrollPos - 1) * 98)] then
                    local item = Guildbook.GuildFrame.GuildBankFrame.BankData[i + ((scrollPos - 1) * 98)]
                    self.BankSlots[i].icon:SetTexture(C_Item.GetItemIconByID(item.ItemID))
                    self.BankSlots[i].count:SetText(item.Count)
                    self.BankSlots[i].itemID = item.ItemID
                    --DEBUG(string.format('updating slot %s with item id %s', i, item.ItemID))
                else
                    self.BankSlots[i].icon:SetTexture(nil)
                    self.BankSlots[i].count:SetText(' ')
                    self.BankSlots[i].itemID = nil
                end

            end
        end
    end

end





-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- calendar
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:SetupGuildCalendarFrame()

    local today = date('*t')

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

    self.GuildFrame.GuildCalendarFrame.Header = self.GuildFrame.GuildCalendarFrame:CreateFontString('GuildbookGuildInfoFrameGuildCalendarFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildCalendarFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildCalendarFrame, 'TOP', 0, 4)
    self.GuildFrame.GuildCalendarFrame.Header:SetText('Guild Calendar')
    self.GuildFrame.GuildCalendarFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildCalendarFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.GuildCalendarFrame.CalendarParent = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameParent', Guildbook.GuildFrame.GuildCalendarFrame)
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetPoint('TOPLEFT', 150, -9)
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetSize(210, 240)
    -- draw days
    local CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH = 90 / 256 - 0.001
    local CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT = 90 / 256 - 0.001
    local dayW, dayH = 70, 55

    self.GuildFrame.GuildCalendarFrame.MonthView = {}
    local i, d = 1, 1
    for week = 1, 6 do
        for day = 1, 7 do
            local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameGuildCalendarFrameWeek'..week..'Day'..day), Guildbook.GuildFrame.GuildCalendarFrame.CalendarParent)
            f:SetPoint('TOPLEFT', ((day - 1) * dayW), ((week - 1) * dayH) * -1)
            f:SetSize(dayW, dayH)
            f:SetHighlightTexture(235438)
            f:GetHighlightTexture():SetTexCoord(0.0, 0.35, 0.0, 0.7)
            local texLeft = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
            local texRight = texLeft + CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
            local texTop = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
            local texBottom = texTop + CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
            f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
            f.background:SetPoint('TOPLEFT', 0, 0)
            f.background:SetPoint('BOTTOMRIGHT', 0, 0)
            f.background:SetTexture(235428)
            f.background:SetTexCoord(texLeft, texRight, texTop, texBottom)

            f.date = {}

            f.dateText = f:CreateFontString('$parentDateText', 'OVERLAY', 'GameFontNormalSmall')
            f.dateText:SetPoint('TOPLEFT', 3, -3)
            f.dateText:SetTextColor(1,1,1,1)

            Guildbook.GuildFrame.GuildCalendarFrame.MonthView[i] = f
            i = i + 1
        end
    end

    -- decided to limit calendar to current month only in order to reduce chat traffic
    -- larger scale calendar functions can be handled via discord/web
    -- this is more a simple view of raid days, resets etc
    function self.GuildFrame.GuildCalendarFrame:MonthChanged()
        local today = date("*t")
        local month = today.month
        local todayButton = (math.floor(today.day / 7) * 7) + today.wday
        local monthStart = todayButton - today.day
        local d, nm = 1, 1
        for i, day in ipairs(Guildbook.GuildFrame.GuildCalendarFrame.MonthView) do
            day:Disable()
            day.dateText:SetText(' ')
            if i < monthStart then
                day.dateText:SetText(daysInMonth[month - 1] - monthStart + 2)
                day.dateText:SetTextColor(0.5, 0.5, 0.5, 1)
                day.date = {
                    day = (daysInMonth[month - 1] - monthStart + 2),
                    month = month - 1,
                    year = 0,
                }
            end
            if i >= monthStart and d <= daysInMonth[month] then
                day.dateText:SetText(d)
                day.dateText:SetTextColor(1,1,1,1)
                day:Enable()
                d = d + 1
            end
            if i > (daysInMonth[month] + (monthStart - 1)) then
                day.dateText:SetText(nm)
                day.dateText:SetTextColor(0.5, 0.5, 0.5, 1)
                nm = nm + 1
            end
        end
    end
    -- left as this in case month restriction gets lifted
    self.GuildFrame.GuildCalendarFrame:MonthChanged()






    self.GuildFrame.GuildCalendarFrame:SetScript('OnShow', function(self)
        self:MonthChanged()
    end)

end