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
-- tradeskill frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupTradeSkillFrame()

    local helpText = [[
|cffffd100Profession sharing|r
|cffffffffGuildbook allows guild members to share their 
profession recipes.
To do this players must first open their professions 
which will trigger a scan of available recipes and save 
this data.

To view another members profession, select the profession 
to see a list of members who have that profession.
When you select a guild member Guildbook will either use 
data saved on file or request data from the member.|r

|cff06B200If recipes do not show correctly selecting the 
player again will usually fix the UI.|r
]]

    self.GuildFrame.TradeSkillFrame.HelperIcon = CreateFrame('FRAME', 'GuildbookGuildInfoFrameTradeSkillFrameHelperIcon', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.HelperIcon:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPRIGHT', -2, 2)
    self.GuildFrame.TradeSkillFrame.HelperIcon:SetSize(20, 20)
    self.GuildFrame.TradeSkillFrame.HelperIcon.texture = self.GuildFrame.TradeSkillFrame.HelperIcon:CreateTexture('$parentTexture', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.HelperIcon.texture:SetAllPoints(self.GuildFrame.TradeSkillFrame.HelperIcon)
    self.GuildFrame.TradeSkillFrame.HelperIcon.texture:SetTexture(374216)
    self.GuildFrame.TradeSkillFrame.HelperIcon:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
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
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetSize(730, 60)

    self.GuildFrame.TradeSkillFrame.TopBorder = self.GuildFrame.TradeSkillFrame:CreateTexture('GuildbookGuildInfoFrameTradeSkillFrameTopBorder', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.TopBorder:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPLEFT', 4, -125)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetPoint('TOPRIGHT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPRIGHT', -4, -125)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetHeight(10)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetTexture(130968)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetTexCoord(0.1, 1.0, 0.0, 0.3)

    self.GuildFrame.TradeSkillFrame.HeaderInfoText = self.GuildFrame.TradeSkillFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.HeaderInfoText:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.TopBorder, 'TOPLEFT', 3, 0)
    self.GuildFrame.TradeSkillFrame.HeaderInfoText:SetText('Select Profession & Character |cffffffff'..Guildbook.Data.StatusIconStringsSMALL['Offline']..'offline, '..Guildbook.Data.StatusIconStringsSMALL['Online']..'online|r')

    self.GuildFrame.TradeSkillFrame.ProfessionButtons = {}
    local profButtonPosY = 0
    local x = 1
    for i = 9, 1, -1 do
        local prof = Guildbook.Data.Professions[i]
        if prof.TradeSkill == true then
            local f = CreateFrame('BUTTON', 'GuildbookTradeSkillFrameProfessionButton'..prof.Name, self.GuildFrame.TradeSkillFrame) --, "UIPanelButtonTemplate")
            f:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'BOTTOMLEFT', 6, profButtonPosY + 4)
            f:SetSize(120, 24.2)
            f:SetText(prof.Name)
            f:SetNormalFontObject(GameFontNormalSmall)
            f:SetHighlightFontObject(GameFontNormalSmall)
            f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
            f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
            f:GetFontString():SetPoint('LEFT', 4, 0)
            f:GetFontString():SetTextColor(1,1,1,1)
            f.icon = f:CreateTexture(nil, 'ARTWORK')
            f.icon:SetPoint('RIGHT', 0, 0)
            f.icon:SetSize(20, 20)
            f.icon:SetTexture(Guildbook.Data.Profession[prof.Name].IconID)
            f.data = { Selected = false }
            f:SetScript('OnClick', function(self)
                for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.ProfessionButtons) do
                    if v.data then
                        v.data.Selected = false
                    end
                end
                self.data.Selected = not self.data.Selected
                Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.ProfessionButtons)
                Guildbook.GuildFrame.TradeSkillFrame:HideCharacterListviewButtons()
                selectedProfession = prof.Name
                Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValue(1)
                Guildbook.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof.Name)
                C_Timer.After(1, function()
                    Guildbook.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
                end)                
                Guildbook.GuildFrame.TradeSkillFrame:ClearRecipesListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionIcon:SetTexture(Guildbook.Data.Profession[prof.Name].Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('|cffffffff'..Guildbook.Data.ProfessionDescriptions[prof.Name]..'|r')
                Guildbook.GuildFrame.TradeSkillFrame.RecipesTable = {}
                DEBUG('selected '..prof.Name)
            end)
            profButtonPosY = profButtonPosY + 23.1
            self.GuildFrame.TradeSkillFrame.ProfessionButtons[x] = f
            x = x + 1
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
                        { 
                            text = 'Options', 
                            isTitle = true, 
                            notCheckable = true, },
                        { 
                            text = 'Request data', 
                            notCheckable = true, 
                            func = function()
                            
                                Guildbook.GuildFrame.TradeSkillFrame:RequestProfessionData(self.data.Name, selectedProfession)
                            end, 
                        },
                        { 
                            text = 'Cancel', 
                            notCheckable = true, 
                            func = function()
                                CloseDropDownMenus()
                            end, 
                        },
                    }
                    EasyMenu(Guildbook.ContextMenu, Guildbook.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
                else
                    local guildName = Guildbook:GetGuildName()
                    -- if we have any recipes already on file, load these, this avoids sending additional chat messages, updates can be requested
                    if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession] and type(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession]) == 'table' then
                        DEBUG('recipe database found on file, loading data for: '..selectedProfession)
                        Guildbook.GuildFrame.TradeSkillFrame.RecipesTable = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession]
                        Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession], nil)
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
                if Guildbook:IsGuildMemberOnline(self.data.GUID) then
                    self.Text:SetText(Guildbook.Data.StatusIconStringsSMALL['Online']..' '..self.data.Name)
                else
                    self.Text:SetText(Guildbook.Data.StatusIconStringsSMALL['Offline']..' '..self.data.Name)
                end
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
            Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(self.RecipesTable, nil)
        end)
    end

    function self.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof)
        DEBUG('getting players with prof '..prof)
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
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
                -- self.CharactersListviewScrollBar:SetMinMaxValues(1, 2)
                -- self.CharactersListviewScrollBar:SetValue(2)
                -- self.CharactersListviewScrollBar:SetValue(1)
                self.CharactersListviewScrollBar:SetMinMaxValues(1, 1)
                DEBUG('set minmax to 1,1')
            else
                self.CharactersListviewScrollBar:SetMinMaxValues(1, (c - 9))
                -- self.CharactersListviewScrollBar:SetValue(2)
                -- self.CharactersListviewScrollBar:SetValue(1)
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
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:SetScript('OnMouseWheel', function(self, delta)
        local s = self.ScrollBar:GetValue()
        self.ScrollBar:SetValue(s - delta)
    end)

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPLEFT', 0, 4)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText:SetText('Search recipes')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText:SetSize(80, 22)

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox = CreateFrame('EDITBOX', 'GuildbookGuildFrameRecipesListviewParentSearchBox', self.GuildFrame.TradeSkillFrame.RecipesListviewParent, "InputBoxTemplate")
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetPoint('LEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText, 'RIGHT', 6, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetSize(150, 22)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:ClearFocus()
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetAutoFocus(false)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetScript('OnTextChanged', function(self)
        if self:GetText():len() > 2 then
            --print('settign recipes with filter')
            local filter = self:GetText()
            Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(Guildbook.GuildFrame.TradeSkillFrame.RecipesTable, filter)
        else
            --print('settign recipes without filter')
            Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(Guildbook.GuildFrame.TradeSkillFrame.RecipesTable, nil)
        end

    end)
   
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

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameRecipesListviewScrollBar', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, "UIPanelScrollBarTemplate")
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPRIGHT', 28, -17)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', 0, 16)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetValueStep(1)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetValue(1)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.TradeSkillFrame:RefreshListview()
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
                    Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = 'enchant:'..self.data.ItemID
                else
                    Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = self.data.Link
                end
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetTexture(self.data.Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetText(self.data.Link)
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                self.Text:SetText(self.data.Link)
            else
                self:Hide()
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

    -- function self.GuildFrame.TradeSkillFrame:ShowRecipesListviewRows()
    --     for i = 1, 10 do
    --         self.RecipesListviewRows[i]:Show()
    --     end
    -- end

    function self.GuildFrame.TradeSkillFrame:RefreshListview()
        if next(self.Recipes) then
            table.sort(self.Recipes, function(a, b)
                if a.Rarity == b.Rarity then
                    return a.Name < b.Name
                else
                    return a.Rarity > b.Rarity
                end
            end)
            local c = #self.Recipes
            if c <= 10 then
                self.RecipesListviewParent.ScrollBar:SetMinMaxValues(1, 1)
            else
                self.RecipesListviewParent.ScrollBar:SetMinMaxValues(1, (c - 9))
            end
            local scrollPos = math.floor(self.RecipesListviewParent.ScrollBar:GetValue())
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
    end
    
    function self.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
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
            DEBUG(string.format('add %s to reagents list', reagentID))
        end
        if filter == nil then
            table.insert(self.Recipes, recipeItem)
        else
            if recipeItem.Name:lower():find(filter:lower()) then
                table.insert(self.Recipes, recipeItem)
            end
        end
        self:RefreshListview()
    end

    function self.GuildFrame.TradeSkillFrame:SetRecipesListviewData(data, filter)
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        if data and type(data) == 'table' and next(data) then
            local k = 1
            for itemID, reagents in pairs(data) do
                local link = false
                local rarity = false
                local icon = false
                local enchant = false
                if selectedProfession == 'Enchanting' then
                    link = select(1, GetSpellLink(itemID))
                    rarity = select(3, GetItemInfo(link)) or 1
                    name = select(1, GetSpellInfo(itemID)) or 'unknown'
                    icon = select(3, GetSpellInfo(itemID)) or 134400
                    enchant = true
                    DEBUG(string.format('added enchant %s with rarity %s and icon %s', link, rarity, icon))
                else
                    link = select(2, GetItemInfo(itemID))
                    rarity = select(3, GetItemInfo(itemID))
                    name = select(1, GetItemInfo(itemID))
                    icon = select(10, GetItemInfo(itemID))
                end
                if link and rarity and icon and name then
                    Guildbook.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
                else
                    if selectedProfession == 'Enchanting' then                    
                        local spell = Spell:CreateFromSpellID(spellID)
                        spell:ContinueOnSpellLoad(function()
                            link = select(1, GetSpellLink(itemID))
                            rarity =  1
                            name = select(1, GetSpellInfo(itemID)) or 'unknown'
                            icon = select(3, GetSpellInfo(itemID)) or 134400
                            enchant = true
                            Guildbook.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
                        end)
                    else
                        local item = Item:CreateFromItemID(itemID)
                        item:ContinueOnItemLoad(function()
                            icon = item:GetItemIcon()
                            name = item:GetItemName()
                            link = item:GetItemLink()
                            rarity = item:GetItemQuality()
                            enchant = false
                            Guildbook.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
                        end)
                    end
                end
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
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = nil
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnEnter', function(self)
        if self.link then
            GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnMouseDown', function(self)
        if self.link then
            if IsShiftKeyDown() then
                HandleModifiedItemClick(self.link)
            end
            if IsControlKeyDown() then
                DressUpItemLink(self.link)
            end
        end
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

        self.GuildFrame.TradeSkillFrame.ReagentsListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:ClearReagentsListview()
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = nil
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetTexture(nil)
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetText(' ')
        for k, v in ipairs(self.ReagentsListviewRows) do
            v.icon:SetTexture(nil)
            v.text:SetText(' ')
            v.link = nil
        end
    end

    function self.GuildFrame.TradeSkillFrame:UpdateReagents(recipe)
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
                        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewRows[k].icon:SetTexture(icon)
                        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewRows[k].text:SetText(string.format('[%s] %s', v.Count, link))
                        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewRows[k].link = link
                    end)
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
                    Guildbook.GuildBankCommit = {
                        Commit = nil,
                        Character = nil,
                    }
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
            local itemClass = select(6, GetItemInfoInstant(id))
            table.insert(Guildbook.GuildFrame.GuildBankFrame.BankData, {
                ItemID = id,
                Count = count,
                Class = itemClass,
            })
            c = c + 1
        end
        -- sort table by item class  https://wow.gamepedia.com/ItemType
        table.sort(Guildbook.GuildFrame.GuildBankFrame.BankData, function(a, b)
            return a.Class < b.Class
        end)
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
                        DEBUG('found: '..event.title)
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
-- soft res
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:SetupSoftReserveFrame()

    local helpText = [[
|cffffd100Soft Reserve|r
|cffffffffGuildbook soft reserve system is kept simple, you can select 1 
item per raid as your soft reserve.
To do this use the 'Select Reserve' drop down menu to search 
raids and bosses, click the item you wish to reserve.
To view current reserves for a raid use the 'Set Raid' drop down
to select a raid.
Only current raid members soft reserves will be shown, players 
not yet in the group will not be queried.
|r

|cff06B200Soft reserves can only be set outside an instance, this 
is to prevent players changing a reserve if they win an item early 
during a raid.|r
    ]]
        
    self.GuildFrame.SoftReserveFrame.HelperIcon = CreateFrame('FRAME', 'GuildbookGuildInfoFrameTradeSkillFrameHelperIcon', self.GuildFrame.SoftReserveFrame)
    self.GuildFrame.SoftReserveFrame.HelperIcon:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.SoftReserveFrame, 'TOPRIGHT', -2, 2)
    self.GuildFrame.SoftReserveFrame.HelperIcon:SetSize(20, 20)
    self.GuildFrame.SoftReserveFrame.HelperIcon.texture = self.GuildFrame.SoftReserveFrame.HelperIcon:CreateTexture('$parentTexture', 'ARTWORK')
    self.GuildFrame.SoftReserveFrame.HelperIcon.texture:SetAllPoints(self.GuildFrame.SoftReserveFrame.HelperIcon)
    self.GuildFrame.SoftReserveFrame.HelperIcon.texture:SetTexture(374216)
    self.GuildFrame.SoftReserveFrame.HelperIcon:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
        GameTooltip:AddLine(helpText)
        GameTooltip:Show()
    end)
    self.GuildFrame.SoftReserveFrame.HelperIcon:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    self.GuildFrame.SoftReserveFrame.SelectedRaid = nil

    if not GUILDBOOK_CHARACTER['SoftReserve'] then
        GUILDBOOK_CHARACTER['SoftReserve'] = {}
    end

    -- sort our data into alphabetical lists to help the player when navigating, items will be sorted by rarity later
    local raidSorted, raidBosses = {}, {}
    for raid, bosses in pairs(Guildbook.RaidItems) do
        table.insert(raidSorted, raid)
        raidBosses[raid] = {}
        for boss, _ in pairs(bosses) do
            table.insert(raidBosses[raid], boss)
        end
        table.sort(raidBosses[raid])
    end
    table.sort(raidSorted)

    self.RaidLoot = {}

    for k, raid in pairs(raidSorted) do
        local bossList = {}
        for j, boss in ipairs(raidBosses[raid]) do
            local lootList = {}
            for _, itemID in ipairs(Guildbook.RaidItems[raid][boss]) do
                -- local itemLink = select(2, GetItemInfo(itemID))
                -- local itemRarity = select(3, GetItemInfo(itemID))
                -- table.insert(lootList, {
                --     text = itemLink,
                --     arg1 = itemRarity,
                --     notCheckable = true,
                --     func = function()
                --         GUILDBOOK_CHARACTER['SoftReserve'][raid] = itemID
                --         print(string.format('You have set %s as your soft reserve for %s', link, raid))
                --     end,
                -- })
                -- table.sort(lootList, function(a, b)
                --     return a.arg1 > b.arg1
                -- end)

                -- using the mixin to ensure we get data on first load
                local item = Item:CreateFromItemID(itemID)
                item:ContinueOnItemLoad(function()
                    local link = item:GetItemLink()
                    local quality = item:GetItemQuality()
                    table.insert(lootList, {
                        text = link,
                        arg1 = quality,
                        notCheckable = true,
                        func = function()
                            GUILDBOOK_CHARACTER['SoftReserve'][raid] = itemID
                            print(string.format('You have set %s as your soft reserve for %s', link, raid))
                        end,
                    })
                end)
            end
            table.insert(lootList, {
                text = 'None',
                arg1 = 10000,
                notCheckable = true,
                func = function()
                    GUILDBOOK_CHARACTER['SoftReserve'][raid] = -1
                    --print(string.format('You have set %s as your soft reserve for %s', link, raid))
                end,
            })
            -- this there a better way than relying on data being ready after 5 seconds and assuming the player wont access the dropdown before 5 seconds ?
            C_Timer.After(5, function()
                table.sort(lootList, function(a, b)
                    return a.arg1 > b.arg1
                end)
            end)
            table.insert(bossList, {
                text = boss,
                hasArrow = true,
                notCheckable = true,
                menuList = lootList
            })
        end
        table.insert(self.RaidLoot, {
            text = raid,
            hasArrow = true,
            notCheckable = true,
            menuList = bossList
        })
    end

    self.GuildFrame.SoftReserveFrame.Header = self.GuildFrame.SoftReserveFrame:CreateFontString('GuildbookGuildInfoFrameGuildBankFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.SoftReserveFrame.Header:SetPoint('TOPLEFT', Guildbook.GuildFrame.SoftReserveFrame, 'TOPLEFT', 10, -5)
    self.GuildFrame.SoftReserveFrame.Header:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.SoftReserveFrame, 'TOPRIGHT', -180, -30)
    self.GuildFrame.SoftReserveFrame.Header:SetText('Select your reserve and set raid to see other members reserves')
    self.GuildFrame.SoftReserveFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.SoftReserveFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 11)
    self.GuildFrame.SoftReserveFrame.Header:SetJustifyH('LEFT')
    self.GuildFrame.SoftReserveFrame.Header:SetJustifyV('CENTER')

    self.GuildFrame.SoftReserveFrame.ItemDropdown = CreateFrame('FRAME', "GuildbookGuildFrameSoftReserveFrameItemDropdown", self.GuildFrame.SoftReserveFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.SoftReserveFrame.ItemDropdown:SetPoint('TOPRIGHT', 0, -10)
    UIDropDownMenu_SetWidth(self.GuildFrame.SoftReserveFrame.ItemDropdown, 140)
    UIDropDownMenu_SetText(self.GuildFrame.SoftReserveFrame.ItemDropdown, 'Select Reserve')
    _G['GuildbookGuildFrameSoftReserveFrameItemDropdownButton']:SetScript('OnClick', function(self)
        EasyMenu(Guildbook.RaidLoot, Guildbook.GuildFrame.SoftReserveFrame.ItemDropdown, Guildbook.GuildFrame.SoftReserveFrame.ItemDropdown, 10, 10, 'NONE')
    end)

    self.GuildFrame.SoftReserveFrame.RaidDropdown = CreateFrame('FRAME', "GuildbookGuildFrameSoftReserveFrameItemDropdown", self.GuildFrame.SoftReserveFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.SoftReserveFrame.RaidDropdown:SetPoint('RIGHT', Guildbook.GuildFrame.SoftReserveFrame.ItemDropdown, 'LEFT', 0, 0)
    UIDropDownMenu_SetWidth(self.GuildFrame.SoftReserveFrame.RaidDropdown, 140)
    UIDropDownMenu_SetText(self.GuildFrame.SoftReserveFrame.RaidDropdown, 'Set Raid')
    function self.GuildFrame.SoftReserveFrame:RaidDropdown_Init()
        UIDropDownMenu_Initialize(self.RaidDropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            for raid, bosses in pairs(Guildbook.RaidItems) do
                info.text = raid
                info.notCheckable = true
                info.func = function()
                    Guildbook.GuildFrame.SoftReserveFrame.SelectedRaid = raid
                    UIDropDownMenu_SetText(Guildbook.GuildFrame.SoftReserveFrame.RaidDropdown, raid)
                    Guildbook.GuildFrame.SoftReserveFrame:ClearRaidCharacters()
                    Guildbook:RequestRaidSoftReserves()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
    self.GuildFrame.SoftReserveFrame:RaidDropdown_Init() -- ?

    local offsetY = 38.0
    self.GuildFrame.SoftReserveFrame.RaidRosterList = {}
    for i = 1, 20 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameSoftReserveFrameRaidRosterList'..i), self.GuildFrame.SoftReserveFrame)
        f:SetPoint('TOPLEFT', 16, ((i - 1) * -15) - offsetY)
        f:SetSize(200, 14)
        f.player = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.player:SetPoint('LEFT', 0, 0)
        f.player:SetText('player name '..i)
        f.softReserve = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.softReserve:SetPoint('LEFT', 90, 0)
        f.softReserve:SetText('soft reserve '..i)
        f.data= nil
        f.id = i

        f:SetScript('OnShow', function(self)
            if self.data and self.data.Character then
                self.player:SetText(self.id..' '..Guildbook.Data.Class[self.data.Class].FontColour..self.data.Character)
                local link = 'None'
                if self.data.ItemID > 0 then
                    link = select(2, GetItemInfo(self.data.ItemID))
                end
                self.softReserve:SetText(link)
            end
        end)

        self.GuildFrame.SoftReserveFrame.RaidRosterList[i] = f
    end
    for i = 21, 40 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameSoftReserveFrameRaidRosterList'..i), self.GuildFrame.SoftReserveFrame)
        f:SetPoint('TOPLEFT', 346, ((i - 21) * -15) - offsetY)
        f:SetSize(200, 14)
        f.player = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.player:SetPoint('LEFT', 0, 0)
        f.player:SetText('player name '..i)
        f.softReserve = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.softReserve:SetPoint('LEFT', 90, 0)
        f.softReserve:SetText('soft reserve '..i)
        f.data = nil
        f.id = i

        f:SetScript('OnShow', function(self)
            if self.data and self.data.Character then
                self.player:SetText(self.id..' '..Guildbook.Data.Class[self.data.Class].FontColour..self.data.Character)
                local link = 'None'
                if self.data.ItemID > 0 then
                    link = select(2, GetItemInfo(self.data.ItemID))
                end
                self.softReserve:SetText(link)
            end
        end)

        self.GuildFrame.SoftReserveFrame.RaidRosterList[i] = f
    end

    function self.GuildFrame.SoftReserveFrame:LockItemDropdown()
        UIDropDownMenu_DisableDropDown(self.ItemDropdown)
    end
    function self.GuildFrame.SoftReserveFrame:UnLockItemDropdown()
        UIDropDownMenu_EnableDropDown(self.ItemDropdown)
    end

    function self.GuildFrame.SoftReserveFrame:ClearRaidCharacters()
        for i = 1, 40 do
            self.RaidRosterList[i].data = nil
            self.RaidRosterList[i]:Hide()
        end
    end

    self.GuildFrame.SoftReserveFrame:SetScript('OnShow', function(self)
        self:ClearRaidCharacters()
        Guildbook:RequestRaidSoftReserves()
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
        --print(name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID)
        if instanceType == 'none' then            
            local isDead = UnitIsDead('player')
            if isDead then
                self:LockItemDropdown()
            else
                self:UnLockItemDropdown()
            end
        else
            self:LockItemDropdown()
        end
    end)

end





-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- profiles
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
function Guildbook:SetupProfilesFrame()

    self.GuildFrame.ProfilesFrame:SetScript('OnShow', function(self)
        local guid = UnitGUID('player')
        if not Guildbook.PlayerMixin then
            Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            Guildbook.PlayerMixin:SetGUID(guid)
        end
        if Guildbook.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
            local _, class, _ = C_PlayerInfo.GetClass(Guildbook.PlayerMixin)
            local sex = C_PlayerInfo.GetSex(Guildbook.PlayerMixin)
            local race = C_CreatureInfo.GetRaceInfo(C_PlayerInfo.GetRace(Guildbook.PlayerMixin)).clientFileString:upper()
            local tex = Guildbook.Data.RaceIcons[C_PlayerInfo.GetSex(Guildbook.PlayerMixin)][race]

            self.ProfileContainer.portrait:SetTexture(tex)
            self.ProfileContainer.class:SetTexture(Guildbook.Data.Class[class].IconID)
            self.ProfileContainer.name:SetText(name)
            local r, g, b = unpack(Guildbook.Data.Class[class].RGB)
            self.ProfileContainer.name:SetTextColor(r, g, b, 1)
        end
    end)

    self.GuildFrame.ProfilesFrame.SearchBox = CreateFrame('EDITBOX', 'GuildbookGuildFrameProfilesFramesearchBox', self.GuildFrame.ProfilesFrame, "InputBoxTemplate")
    self.GuildFrame.ProfilesFrame.SearchBox:SetPoint('TOP', 0, -30)
    self.GuildFrame.ProfilesFrame.SearchBox:SetSize(200, 22)
    self.GuildFrame.ProfilesFrame.SearchBox:ClearFocus()
    self.GuildFrame.ProfilesFrame.SearchBox:SetAutoFocus(false)
    self.GuildFrame.ProfilesFrame.SearchBox:SetMaxLetters(15)
    self.GuildFrame.ProfilesFrame.SearchBox.header = self.GuildFrame.ProfilesFrame.SearchBox:CreateFontString('$parentHeader', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.ProfilesFrame.SearchBox.header:SetPoint('BOTTOMLEFT', self.GuildFrame.ProfilesFrame.SearchBox, 'TOPLEFT', 0, 2)
    self.GuildFrame.ProfilesFrame.SearchBox.header:SetText('Search for')

    self.GuildFrame.ProfilesFrame.ProfileContainer = CreateFrame('FRAME', 'GuildbookGuildFrameProfilesFrameProfileContainer', self.GuildFrame.ProfilesFrame)
    self.GuildFrame.ProfilesFrame.ProfileContainer:SetPoint('TOPLEFT', self.GuildFrame.ProfilesFrame, 'TOPLEFT', 100, -50)
    self.GuildFrame.ProfilesFrame.ProfileContainer:SetPoint('BOTTOMRIGHT', self.GuildFrame.ProfilesFrame, 'BOTTOMRIGHT', -100, 10)

    self.GuildFrame.ProfilesFrame.ProfileContainer.portrait = self.GuildFrame.ProfilesFrame.ProfileContainer:CreateTexture('$parentPortrait', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfileContainer.portrait:SetPoint('TOPLEFT', 5, -5)
    self.GuildFrame.ProfilesFrame.ProfileContainer.portrait:SetSize(50, 50)

    self.GuildFrame.ProfilesFrame.ProfileContainer.class = self.GuildFrame.ProfilesFrame.ProfileContainer:CreateTexture('$parentClass', 'ARTWORK')
    self.GuildFrame.ProfilesFrame.ProfileContainer.class:SetPoint('TOPRIGHT', -5, -5)
    self.GuildFrame.ProfilesFrame.ProfileContainer.class:SetSize(50, 50)

    self.GuildFrame.ProfilesFrame.ProfileContainer.name = self.GuildFrame.ProfilesFrame.ProfileContainer:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.ProfilesFrame.ProfileContainer.name:SetPoint('TOP', 0, -10)



end
]]--