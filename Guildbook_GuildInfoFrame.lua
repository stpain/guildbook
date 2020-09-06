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

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG
local PRINT = Guildbook.PRINT
--might be used in future updates
--local tinsert, tsort = table.insert, table.sort
--local ceil, floor = math.ceil, math.floor 

--set constants
local FRIENDS_FRAME_WIDTH = FriendsFrame:GetWidth()
local GUILD_FRAME_WIDTH = GuildFrame:GetWidth()
local GUILD_INFO_FRAME_WIDTH = GuildInfoFrame:GetWidth()

Guildbook.GuildInfoFrame = {}

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--create addition frames and tab buttons
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook.GuildInfoFrame.Init()
    Guildbook.GuildInfoFrame.InfoTab = CreateFrame('BUTTON', 'GuildInfoFrameTab1', GuildInfoFrame, "CharacterFrameTabButtonTemplate")
    Guildbook.GuildInfoFrame.InfoTab:SetID(1)
    Guildbook.GuildInfoFrame.InfoTab:SetPoint("TOPLEFT", "GuildInfoFrame", "BOTTOMLEFT", 2, 7)
    Guildbook.GuildInfoFrame.InfoTab:SetText(L['Info'])
    Guildbook.GuildInfoFrame.InfoTab:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(GuildInfoFrame, 1);
        GuildInfoFrame:SetWidth(GUILD_INFO_FRAME_WIDTH)
        GuildInfoTextBackground:Show()
        GuildInfoTitle:SetText(L['Guild Information'])
        Guildbook.GuildInfoFrame.SummaryFrame:Hide()
        Guildbook.GuildInfoFrame.RaidRosterFrame:Hide()
        Guildbook.GuildInfoFrame.ProfessionsFrame:Hide()
    end)

    Guildbook.GuildInfoFrame.SummaryTab = CreateFrame('BUTTON', 'GuildInfoFrameTab2', GuildInfoFrame, "CharacterFrameTabButtonTemplate")
    Guildbook.GuildInfoFrame.SummaryTab:SetID(2)
    Guildbook.GuildInfoFrame.SummaryTab:SetPoint('LEFT', Guildbook.GuildInfoFrame.InfoTab, 'RIGHT', -18, 0)
    Guildbook.GuildInfoFrame.SummaryTab:SetText(L['ClassRoles'])
    Guildbook.GuildInfoFrame.SummaryTab:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(GuildInfoFrame, 2);
        GuildInfoFrame:SetWidth(GUILD_INFO_FRAME_WIDTH)
        GuildInfoTextBackground:Hide()
        GuildInfoTitle:SetText(L['ClassRolesSummary'])
        Guildbook.GuildInfoFrame.SummaryFrame:Show()
        Guildbook.GuildInfoFrame.RaidRosterFrame:Hide()
        Guildbook.GuildInfoFrame.ProfessionsFrame:Hide()
    end)

    Guildbook.GuildInfoFrame.RaidRosterTab = CreateFrame('BUTTON', 'GuildInfoFrameTab3', GuildInfoFrame, "CharacterFrameTabButtonTemplate")
    Guildbook.GuildInfoFrame.RaidRosterTab:SetID(3)
    Guildbook.GuildInfoFrame.RaidRosterTab:SetPoint('LEFT', Guildbook.GuildInfoFrame.SummaryTab, 'RIGHT', -18, 0)
    Guildbook.GuildInfoFrame.RaidRosterTab:SetText(L['Raids'])
    Guildbook.GuildInfoFrame.RaidRosterTab:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(GuildInfoFrame, 3);
        GuildInfoFrame:SetWidth(1150)
        GuildInfoTextBackground:Hide()
        GuildInfoTitle:SetText(L['RaidRoster'])
        Guildbook.GuildInfoFrame.SummaryFrame:Hide()
        Guildbook.GuildInfoFrame.RaidRosterFrame:Show()
        Guildbook.GuildInfoFrame.ProfessionsFrame:Hide()
    end)

    Guildbook.GuildInfoFrame.ProfessionsTab = CreateFrame('BUTTON', 'GuildInfoFrameTab4', GuildInfoFrame, "CharacterFrameTabButtonTemplate")
    Guildbook.GuildInfoFrame.ProfessionsTab:SetID(4)
    Guildbook.GuildInfoFrame.ProfessionsTab:SetPoint('LEFT', Guildbook.GuildInfoFrame.RaidRosterTab, 'RIGHT', -18, 0)
    Guildbook.GuildInfoFrame.ProfessionsTab:SetText(L['Professions'])
    Guildbook.GuildInfoFrame.ProfessionsTab:SetScript('OnClick', function(self)
        PanelTemplates_SetTab(GuildInfoFrame, 4);
        GuildInfoFrame:SetWidth(400)
        GuildInfoTextBackground:Hide()
        GuildInfoTitle:SetText(L['Professions'])
        Guildbook.GuildInfoFrame.SummaryFrame:Hide()
        Guildbook.GuildInfoFrame.RaidRosterFrame:Hide()
        Guildbook.GuildInfoFrame.ProfessionsFrame:Show()
    end)

    --set tab info
    PanelTemplates_SetNumTabs(GuildInfoFrame, 4);
    PanelTemplates_SetTab(GuildInfoFrame, 1) 

    Guildbook.GuildInfoFrame.SummaryFrame = CreateFrame('FRAME', 'GuildbookGuildInfoFrameSummaryFrame', GuildInfoFrame)
    Guildbook.GuildInfoFrame.SummaryFrame:SetPoint('TOPLEFT', GuildInfoFrame, 'TOPLEFT', 0, -24)
    Guildbook.GuildInfoFrame.SummaryFrame:SetPoint('BOTTOMRIGHT', GuildInfoFrame, 'BOTTOMRIGHT', 0, 0)
    Guildbook.GuildInfoFrame.SummaryFrame:Hide()
    Guildbook.GuildInfoFrame.SummaryFrame:SetScript('OnShow', function(self)
        Guildbook.SummaryFrame:UpdateClassBars()
        Guildbook.SummaryFrame:ResetRoleCounts()
        Guildbook.SummaryFrame:FetchRoleData()
    end)

    Guildbook.GuildInfoFrame.SummaryFrame.RoleHeader = Guildbook.GuildInfoFrame.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameRoleHeader', 'OVERLAY', 'GameFontNormal')
    Guildbook.GuildInfoFrame.SummaryFrame.RoleHeader:SetPoint('TOPLEFT', 20, -22)
    Guildbook.GuildInfoFrame.SummaryFrame.RoleHeader:SetText(L['RoleChart'])
    Guildbook.GuildInfoFrame.SummaryFrame.RoleHeader:SetTextColor(1,1,1,1)
    Guildbook.GuildInfoFrame.SummaryFrame.RoleHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    Guildbook.GuildInfoFrame.SummaryFrame.ClassHeader = Guildbook.GuildInfoFrame.SummaryFrame:CreateFontString('GuildbookGuildInfoFrameSummaryFrameClassHeader', 'OVERLAY', 'GameFontNormal')
    Guildbook.GuildInfoFrame.SummaryFrame.ClassHeader:SetPoint('TOPLEFT', 16, -155)
    Guildbook.GuildInfoFrame.SummaryFrame.ClassHeader:SetText(L['ClassChart'])
    Guildbook.GuildInfoFrame.SummaryFrame.ClassHeader:SetTextColor(1,1,1,1)
    Guildbook.GuildInfoFrame.SummaryFrame.ClassHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)

    Guildbook.GuildInfoFrame.RaidRosterFrame = CreateFrame('FRAME', 'GuildbookGuildInfoFrameRaidRosterFrame', GuildInfoFrame)
    Guildbook.GuildInfoFrame.RaidRosterFrame:SetPoint('TOPLEFT', GuildInfoFrame, 'TOPLEFT', 0, -24)
    Guildbook.GuildInfoFrame.RaidRosterFrame:SetPoint('BOTTOMRIGHT', GuildInfoFrame, 'BOTTOMRIGHT', 0, 0)
    Guildbook.GuildInfoFrame.RaidRosterFrame:Hide()

    Guildbook.GuildInfoFrameRaidRosterFrameRowContextMenu = CreateFrame("Frame", "GuildbookGuildInfoFrameRaidRosterContextMenu", UIParent, "UIDropDownMenuTemplate")

    Guildbook.GuildInfoFrame.RaidRosterFrame:SetScript('OnShow', function(self)
    end)

    Guildbook.GuildInfoFrame.ProfessionsFrame = CreateFrame('FRAME', 'GuildbookGuildInfoFrameProfessionsFrame', GuildInfoFrame)
    Guildbook.GuildInfoFrame.ProfessionsFrame:SetPoint('TOPLEFT', GuildInfoFrame, 'TOPLEFT', 0, -24)
    Guildbook.GuildInfoFrame.ProfessionsFrame:SetPoint('BOTTOMRIGHT', GuildInfoFrame, 'BOTTOMRIGHT', 0, 0)
    Guildbook.GuildInfoFrame.ProfessionsFrame:Hide()
    Guildbook.GuildInfoFrame.ProfessionsFrame:SetScript('OnShow', function(self)

    end)

end


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--raid roster frame
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.RaidRosterFrame = {
    ListViewBackground = {12,18,23},
    ListViewBackground = {5,5,5},
    ListViewRowHighlight = {90,100,111},
    ListViewRowFontColor = {210,211,211},
    RoleColours = {
        Tank = {3,34,71,0.4},
        Healer = {6,88,16,0.4},
        Ranged = {88,6,6,0.4},
        Melee = {88,6,6,0.4},
        ['-'] = {0,0,0,0},
    },
    ListViewColumns = {
        Classic = { 'Character', 'Class', 'Spec', 'UBRS', 'MC', 'ONY', 'BWL', 'NAXX' } --, 'PublicNote' },
    },
    CharacterData = { 'Spec', 'UBRS', 'MC', 'ONY', 'BWL', 'NAXX' },
    ListViewRows = {},
    Groups = {
        [1] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 610, PosY = -60 },
        [2] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 740, PosY = -60 },
        [3] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 870, PosY = -60 },
        [4] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 1000, PosY = -60 },
        [5] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 610, PosY = -240 },
        [6] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 740, PosY = -240 },
        [7] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 870, PosY = -240 },
        [8] = { Rows = {}, Name = '-', Members = {}, Buffs = {}, PosX = 1000, PosY = -240 },
    },
    RaidRoster = {},
    DrawListView = function(self)
        self.RosterListView = CreateFrame('FRAME', 'GuildbookGuildInfoFrameRaidRosterFrameRosterListView', Guildbook.GuildInfoFrame.RaidRosterFrame)
        self.RosterListView:SetPoint('TOPLEFT', Guildbook.GuildInfoFrame.RaidRosterFrame, 'TOPLEFT', 15, -44)
        self.RosterListView:SetPoint('BOTTOMRIGHT', Guildbook.GuildInfoFrame.RaidRosterFrame, 'BOTTOMLEFT', 550, 35)
        self.RosterListView:SetScript('OnMouseWheel', function(self, delta)
            local v = self.Scrollbar:GetValue()
            if delta == 1 then
                self.Scrollbar:SetValue(v - 0.1)
            else
                self.Scrollbar:SetValue(v + 0.1)
            end
        end)
        self.RosterListView.texture = self.RosterListView:CreateTexture("$parentTexture", 'ARTWORK')
        self.RosterListView.texture:SetAllPoints(self.RosterListView)
        local r, g, b = unpack(Guildbook.RgbToPercent(self.ListViewBackground))
        self.RosterListView.texture:SetColorTexture(r, g, b, 0.8)
        self.RosterListView.Scrollbar = CreateFrame("Slider", "GuildbookGuildInfoFrameRaidRosterFrameRosterListViewScrollbar", self.RosterListView, "UIPanelScrollBarTemplate")
        self.RosterListView.Scrollbar:SetPoint("TOPRIGHT", self.RosterListView, "TOPRIGHT", 0,-16) 
        self.RosterListView.Scrollbar:SetPoint("BOTTOMRIGHT", self.RosterListView, "BOTTOMRIGHT", 0, 16)
        self.RosterListView.Scrollbar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
        --self.RosterListView.Scrollbar.ThumbTexture:SetSize(18, 18)
        self.RosterListView.Scrollbar:SetScript('OnShow', function(self) -- ? on load bugged ?
            self:SetMinMaxValues(1, 20)
            self:SetValueStep(0.1)
            self:SetValue(1)
            self.scrollStep = 1
        end)
        self.RosterListView.Scrollbar:SetScript('OnValueChanged', function(self, value)
            Guildbook.RaidRosterFrame:RosterClearRows()
            Guildbook.RaidRosterFrame:RefreshRoster(value)

        end)
        for i = 1, 20 do
            local rowPosY = ((i-1) * -16)
            local f = CreateFrame('FRAME', tostring('GuildbookGuildInfoFrameRaidRosterFrameRosterListView_Row'..i), self.RosterListView)
            f:EnableMouse(true)
            f:SetHeight(16)
            f:SetPoint('TOPLEFT', self.RosterListView, 'TOPLEFT', 0, rowPosY)
            f:SetPoint('TOPRIGHT', self.RosterListView, 'TOPRIGHT', 0, rowPosY)
            f.t = f:CreateTexture('$parentBackground', 'ARTWORK')
            f.t:SetAllPoints(f)
            f.data = nil
            for k, v in ipairs(self.ListViewColumns['Classic']) do
                f[v] = f:CreateFontString(tostring('$parent'..v), 'OVERLAY', 'GameFontNormal')
                if k == 1 then
                    f[v]:SetPoint('LEFT', 0, 0) --, f.ClassRole, 'RIGHT', 8, 0)
                else
                    f[v]:SetPoint('LEFT', f[self.ListViewColumns['Classic'][k-1]], 'RIGHT', 8, 0)
                end
                f[v]:SetFont("Fonts\\FRIZQT__.TTF", 12)
                f[v]:SetText(v)
                f[v]:SetTextColor(1,1,1,1)
                f[v]:SetJustifyH('LEFT')
                f[v]:SetSize(40, 16)
            end
            f.Character:SetWidth(80)
            f.Class:SetWidth(90)
            f.Spec:SetWidth(90)
            --f.PublicNote:SetWidth(200)
            --f.OfficerNote:SetWidth(110)
            f:SetScript('OnShow', function(self)
                if self.data then
                    for k, v in pairs(self.data) do
                        if self[k] then
                            self[k]:SetText(v)
                        end
                    end
                    local role = Guildbook.Data.SpecToRole[self.data['Class']][self.data['Spec']]
                    if role then
                        local r, g, b, a = unpack(Guildbook.RgbToPercent(Guildbook.RaidRosterFrame.RoleColours[role]))
                        self.t:SetColorTexture(r, g, b, 0.6)
                    end
                end
            end)
            f:SetScript('OnEnter', function(self)
                if self:IsVisible() then
                    if self.data then
                        local role = Guildbook.Data.SpecToRole[self.data['Class']][self.data['Spec']]
                        if role then
                            local r, g, b, a = unpack(Guildbook.RgbToPercent(Guildbook.RaidRosterFrame.RoleColours[role]))
                            self.t:SetColorTexture(r, g, b, 0.8)
                        end
                        if role == '-' then
                            self.t:SetColorTexture(0.3,0.3,0.3,0.3)
                        end
                    end
                end
            end)
            f:SetScript('OnLeave', function(self)
                if self.data then
                    local role = Guildbook.Data.SpecToRole[self.data['Class']][self.data['Spec']]
                    if role then
                        local r, g, b, a = unpack(Guildbook.RgbToPercent(Guildbook.RaidRosterFrame.RoleColours[role]))
                        self.t:SetColorTexture(r, g, b, 0.6)
                    end
                    if role == '-' then
                        --self.t:SetColorTexture(0.3,0.3,0.3,0.0)
                    end
                end
            end)
            f:SetScript('OnMouseDown', function(self, button)
                local menu = {
                    { text = tostring(Guildbook.Data.Class[self.data.Class].FontColour..self.data.Character), isTitle = true, notCheckable = true },
                    { text = 'Set Group', hasArrow = true, notCheckable = true,
                        menuList = {
                            { text = '1', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(1, self.data) end },
                            { text = '2', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(2, self.data) end },
                            { text = '3', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(3, self.data) end },
                            { text = '4', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(4, self.data) end },
                            { text = '5', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(5, self.data) end },
                            { text = '6', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(6, self.data) end },
                            { text = '7', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(7, self.data) end },
                            { text = '8', func = function() Guildbook.RaidRosterFrame.SetMemberGroup(8, self.data) end },
                        }
                    }
                }
                if button == 'RightButton' then
                    --ToggleDropDownMenu(1, nil, Guildbook.GuildInfoFrameRaidRosterFrameRowContextMenu, "cursor", 3, -3, menuList, nil, 5)
                    EasyMenu(menu, Guildbook.GuildInfoFrameRaidRosterFrameRowContextMenu, "cursor", 0 , 0, "MENU")
                end
            end)
    
            self.ListViewRows[i] = f
        end
        --create header buttons
        for k, v in ipairs(self.ListViewColumns['Classic']) do
            local b = CreateFrame('BUTTON', tostring('$parentColumnHeaderButton'..v), Guildbook.GuildInfoFrame.RaidRosterFrame, "UIPanelButtonTemplate")
            b:SetSize(30, 20)
            b:SetPoint('BOTTOMLEFT', self.ListViewRows[1][v], 'TOPLEFT', -4, 0)
            b:SetPoint('BOTTOMRIGHT', self.ListViewRows[1][v], 'TOPRIGHT', 6, 0)
            b:SetText(v)
        end

        self.RosterListView:SetScript('OnShow', function(self)
            Guildbook.RaidRosterFrame:ScanGuildMembers()
        end)
    end,
    RosterClearRows = function(self)
        for k, v in ipairs(self.ListViewRows) do
            v:Hide()
        end
    end,
    DrawGroups = function(self)
        for g = 1, 8 do
            self.Groups[g].ListView = CreateFrame("FRAME", tostring('GuildbookGuildInfoFrameRaidRosterFrameGroup'..g), Guildbook.GuildInfoFrame.RaidRosterFrame)
            self.Groups[g].ListView:SetSize(125, 150)
            self.Groups[g].ListView:SetPoint('TOPLEFT', Guildbook.GuildInfoFrame.RaidRosterFrame, 'TOPLEFT', self.Groups[g].PosX, self.Groups[g].PosY)
            for r = 0, 5 do
                local f = CreateFrame("FRAME", tostring('$parentRow'..r), self.Groups[g].ListView)
                f:SetSize(125, 24)
                f:SetPoint('TOPLEFT', 0, r * -25)
                f.border = f:CreateTexture(nil, 'BACKGROUND', nil, -5)
                f.border:SetAllPoints(f)
                f.border:SetColorTexture(1,1,1,1)
                f.background = f:CreateTexture(nil, 'BACKGROUND', nil, 6)
                f.background:SetPoint('TOPLEFT', 1, -1)
                f.background:SetPoint('BOTTOMRIGHT', -1, 1)
                f.background:SetColorTexture(0,0,0,1)
                f.data = nil
                if r == 0 then
                    f.GroupName = f:CreateFontString('$parentGroupName', 'OVERLAY', 'GameFontNormal')
                    f.GroupName:SetPoint('CENTER', 0, 0)
                    f.GroupName:SetText('Group '..g)
                else
                    f.Name = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormal_NoShadow')
                    f.Name:SetPoint('LEFT', 3, 0)
                    f.Name:SetTextColor(0,0,0,1)
                    f.Name:SetFont("Fonts\\FRIZQT__.TTF", 12) --, 'OUTLINE')
                end
                f:SetScript('OnEnter', function(self)
                    --GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                    --GameTooltip:AddLine()
                    --GameTooltip:Show()
                end)
                f:SetScript('OnLeave', function(self)
                    --GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                f:SetScript('OnShow', function(self)
                    if r > 0 then
                        self.data = Guildbook.RaidRosterFrame.Groups[g].Members[r]
                        if self.data then
                            self.Name:SetText(self.data.Character)
                            local r, _g, b = unpack(Guildbook.Data.Class[self.data.Class].RGB)
                            self.background:SetColorTexture(r, _g, b, 1)
                        end
                    end
                end)
                f:SetScript('OnHide', function(self)
                    if r > 0 then
                        self.background:SetColorTexture(0,0,0,1)
                        self.data = nil
                        self.Name:SetText('')
                    end
                end)
                f:SetScript('OnMouseDown', function(self, button)
                    if IsShiftKeyDown() and button == 'RightButton' then
                        local d = nil
                        for k, v in ipairs(Guildbook.RaidRosterFrame.Groups[g].Members) do
                            if v == self.data then
                                d = k
                            end
                        end
                        table.remove(Guildbook.RaidRosterFrame.Groups[g].Members, d)
                        for k, v in ipairs(Guildbook.RaidRosterFrame.Groups[g].Rows) do
                            v:Hide()
                            v:Show()
                        end
                    end
                end)
                self.Groups[g].Rows[r] = f
            end
            local groupHeader = Guildbook.GuildInfoFrame.RaidRosterFrame:CreateFontString('$parentGroupHeaderText', 'OVERLAY', 'GameFontNormal') --_NoShadow')
            groupHeader:SetPoint('TOPLEFT', 610, -40)
            groupHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)
            --groupHeader:SetTextColor(1,1,1,1)
            groupHeader:SetText('Shift + Right click to remove players')
        end
    end,
    ScanGuildMembers = function(self)
        GuildRoster()
        local offline = select(1, GetCVarInfo('guildShowOffline'))
        if tonumber(offline) == 1 then
            offline = true
        else
            offline = false
        end
        self:RosterClearRows()
        self.RaidRoster = {}
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            if (isOnline == true) and (level == 60) then
                self:FetchRaidData(name)
                local t = {}
                for k, v in ipairs(self.CharacterData) do
                    t[v] = '-'
                end
                --over write with available data, get the rest from chat msg
                t['Character'] = string.sub(name, 1, tonumber(string.find(name, '-') - 1))
                t['Class'] = class:upper()
                --append note data?
                t['PublicNote'] = publicNote
                --t['OfficerNote'] = officerNote
                table.insert(self.RaidRoster, t)
            elseif (isOnline == true) and (string.sub(name, 1, tonumber(string.find(name, '-') - 1)) == 'Copperbolts') then
                self:FetchRaidData(name)
                local t = {}
                for k, v in ipairs(self.CharacterData) do
                    t[v] = '-'
                end
                --over write with available data, get the rest from chat msg
                t['Character'] = string.sub(name, 1, tonumber(string.find(name, '-') - 1))
                t['Class'] = class:upper()
                --append note data?
                t['PublicNote'] = publicNote
                --t['OfficerNote'] = officerNote
                table.insert(self.RaidRoster, t)
            end
        end
        for k, member in ipairs(self.RaidRoster) do
        --for k = 1, 20 do
            if self.ListViewRows[k] then
                self.ListViewRows[k].data = member
                self.ListViewRows[k]:Show()
            end
        end
    end,
    RefreshRoster = function(self, value)
        local c = 20
        if #self.RaidRoster > 0 then
            c = #self.RaidRoster
        end
        self.RosterListView.Scrollbar:SetMinMaxValues(1, math.ceil(c/20))
        local i, lower, upper = 1, (value - 1) * 20, (value * 20)
        for k, member in ipairs(self.RaidRoster) do
            if k > lower and k <= upper then
                if self.ListViewRows[i] then
                    self.ListViewRows[i]:Hide()
                    self.ListViewRows[i].data = member
                    self.ListViewRows[i]:Show()
                    i = i + 1
                end
            end
        end
    end,
    DrawClassBuffs = function(self)
        self.ClassBuffsListView = CreateFrame('FRAME', '$parentClassBuffsListView', Guildbook.GuildInfoFrame.RaidRosterFrame)
        
    end,
    FetchRaidData = function(self, member)
        DEBUG('fetching raid data')
        GuildRoster()
        local requestSent = C_ChatInfo.SendAddonMessage('gb-raid-req', 'requestdata', 'WHISPER', member)
        if requestSent then
            DEBUG('requesting raid data from: '..member)
        else
            DEBUG('raid data request failed: '..member)
        end
    end,
    HandleAddonMessage = function(self, ...)
        local prefix = select(1, ...)
        local msg = select(2, ...)
        local sender = select(5, ...)
        if prefix == 'gb-raid-req' then
            local dataSent = C_ChatInfo.SendAddonMessage('gb-raid-data', tostring(GUILDBOOK_CHARACTER['MainSpec']..':'..tostring(GUILDBOOK_CHARACTER['AttunementsKeys']['UBRS'])..':'..tostring(GUILDBOOK_CHARACTER['AttunementsKeys']['MC'])..':'..tostring(GUILDBOOK_CHARACTER['AttunementsKeys']['ONY'])..':'..tostring(GUILDBOOK_CHARACTER['AttunementsKeys']['BWL'])..':'..tostring(GUILDBOOK_CHARACTER['AttunementsKeys']['NAXX'])), 'WHISPER', sender) --add data message
            if dataSent then
                DEBUG('sent raid data to: '..sender)
            else
                DEBUG('failed to send raid data to: '..sender)
            end
        elseif prefix == 'gb-raid-data' then
            DEBUG('raid data reply from '..sender)
            --local name = string.sub(sender, 1, tonumber(string.find(sender, '-') - 1))
            for k, member in ipairs(self.RaidRoster) do
                --if (member['Name']:lower()) == (sender:lower()) then
                if member['Character']:lower() == sender:lower() then
                    local i = 1
                    for d in string.gmatch(msg, '[^:]+') do
                        member[self.CharacterData[i]] = d
                        i = i + 1
                    end
                end
            end
        end
        self:RefreshRoster(Guildbook.RaidRosterFrame.RosterListView.Scrollbar:GetValue())
    end,    
}

function Guildbook.RaidRosterFrame.SetMemberGroup(group, member)
    if not next(Guildbook.RaidRosterFrame.Groups[group].Members) then 
        table.insert(Guildbook.RaidRosterFrame.Groups[group].Members, member)
        --print('empty group - added', member.Character, 'to group', group)
    elseif #Guildbook.RaidRosterFrame.Groups[group].Members < 5 then
        local exists = false
        for k, v in ipairs(Guildbook.RaidRosterFrame.Groups[group].Members) do
            if v.Character == member.Character then
                exists = true
                --print('found member', member.Character, 'in group', group)
            end
        end
        if exists == false then
            table.insert(Guildbook.RaidRosterFrame.Groups[group].Members, member) -- member)
            --print('member', member.Character, 'not found in group', group, 'adding to group')
        end
    else
        PRINT(Guildbook.FONT_COLOUR, 'Group limit reached, unable to add new players!')
    end
    for i = 1, 8 do
        local del, key = false, nil
        if i ~= group then
            for j, m in ipairs(Guildbook.RaidRosterFrame.Groups[i].Members) do
                if m.Character == member.Character then
                    del = true
                    key = j
                    --print('member exists in group:', i, j, m.Character)
                end
            end
            if del == true then
                table.remove(Guildbook.RaidRosterFrame.Groups[i].Members, key)
                for _, row in ipairs(Guildbook.RaidRosterFrame.Groups[i].Rows) do
                    row:Hide()
                    row:Show()
                end                                        
            end
        end
    end
    Guildbook.RaidRosterFrame.Groups[group].ListView:Hide()
    Guildbook.RaidRosterFrame.Groups[group].ListView:Show()
    CloseDropDownMenus()
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--summary frame
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.SummaryFrame = {
    ClassBars = {},
    ClassCount = {
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
    },
    ResetClassCount = function(self)
        for k, v in ipairs(self.ClassCount) do
            v.Count = 0
        end
    end,
    DrawClassChart = function(self)
        for k, class in pairs(self.ClassCount) do
            local f = CreateFrame('FRAME', 'GuildbookGuildInfoFrameClassSummary'..k, Guildbook.GuildInfoFrame.SummaryFrame)
            f:SetHeight(18)
            f:SetPoint('BOTTOMLEFT', GuildbookGuildInfoFrameSummaryFrame, 'BOTTOMLEFT', 16, ((k * 18) + 24))
            f:SetPoint('BOTTOMRIGHT', GuildbookGuildInfoFrameSummaryFrame, 'BOTTOMRIGHT', -16, ((k * 18) + 24))

            f.Data = nil

            f.Background = f:CreateTexture('GuildbookGuildInfoFrameClassSummaryBarBackground'..k, 'BACKGROUND')
            f.Background:SetPoint('TOPLEFT', f, 'TOPLEFT', 21, -2)
            f.Background:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -2, 2)

            f.Icon = f:CreateTexture('GuildbookGuildInfoFrameClassSummaryIcon'..k, 'ARTWORK')
            f.Icon:SetPoint('LEFT', 0, 0)
            f.Icon:SetSize(18, 18)
            f.Icon:SetTexture(Guildbook.Data.Class[class.Class].Icon)

            f.Bar = CreateFrame('STATUSBAR', 'GuildbookGuildInfoFrameClassSummaryBar'..k, GuildbookGuildInfoFrameSummaryFrame)
            f.Bar:SetPoint('LEFT', f.Icon, 'RIGHT', 3, 0)
            f.Bar:SetPoint('RIGHT', f, 'RIGHT', -3, 0)
            f.Bar:SetOrientation('HORIZONTAL')
            f.Bar:SetMinMaxValues(1, 100)
            f.Bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            f.Bar:SetHeight(14)
            f.Bar:SetValue(100 * (k / 10))
            f.Bar:SetStatusBarColor(unpack(Guildbook.Data.Class[class.Class].RGB))

            f.Text = f:CreateFontString('GuildbookGuildInfoFrameClassSummaryText'..k, 'OVERLAY', 'GameFontNormal')
            f.Text:SetPoint('RIGHT', f, 'RIGHT', -3, 0)
            f.Text:SetTextColor(1,1,1,1)
            f.Text:SetText('text')
            f.Text:SetFont("Fonts\\FRIZQT__.TTF", 12)

            tinsert(self.ClassBars, f)
        end
    end,
    UpdateClassBars = function(self)
        DEBUG('getting guild class counts')
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
            self.ClassBars[k].Bar:SetValue(tonumber((v.Count / totalMembers) * 100))
            self.ClassBars[k].Bar:SetStatusBarColor(unpack(Guildbook.Data.Class[v.Class].RGB))
            self.ClassBars[k].Background:SetColorTexture(r, g, b, 0.15)
            self.ClassBars[k].Icon:SetTexture(Guildbook.Data.Class[v.Class].Icon)
            self.ClassBars[k].Text:SetText(v.Count)
        end
    end,
    RoleChart = {},
    DrawRoleChart = function(self)
        local order = { 'Tank', 'Melee', 'Healer', 'Ranged' }
        for i = 1, 4 do
            local role = order[i]
            local f = CreateFrame('FRAME', 'GuildbookGuildInfoFrameRoleSummary'..role, Guildbook.GuildInfoFrame.SummaryFrame)
            f:SetHeight(18)
            f:SetPoint('TOPLEFT', GuildbookGuildInfoFrameSummaryFrame, 'TOPLEFT', 16, ((i * -24) - 24))
            f:SetPoint('TOPRIGHT', GuildbookGuildInfoFrameSummaryFrame, 'TOPRIGHT', -16, ((i * -24) - 24))

            f.RoleIcon = f:CreateFontString('GuildbookGuildInfoFrameRoleSummaryIcon'..role, 'OVERLAY', 'GameFontNormal')
            f.RoleIcon:SetText(Guildbook.Data.RoleIcons[role].FontStringIconLARGE)
            f.RoleIcon:SetPoint('LEFT', 0, 0)

            f.Data = nil

            f:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:AddLine(role, 1, 1, 1, 1)
                -- for class, count in pairs(self.Data) do
                --     GameTooltip:AddDoubleLine(class, count, 1, 1, 1, 1, 1, 1)
                -- end
                GameTooltip:Show()
            end)
            f:SetScript('OnLeave', function(self)
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            end)

            local j = 1
            for class, count in pairs(self.Roles[order[i]]) do
                f[class] = f:CreateFontString('GuildbookGuildInfoFrameRoleSummaryIcon'..role..class, 'OVERLAY', 'GameFontNormal')
                f[class]:SetPoint('LEFT', ((40 * j) - 12), 0)
                f[class]:SetText(Guildbook.Data.Class[class].FontStringIconMEDIUM)
                j = j + 1
            end

            self.RoleChart[role] = f
        end
    end,
    Roles = {
		Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
		Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
		Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
        Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 },
    },
    --for some reason looping the table to set all values as 0 didnt work
    ResetRoleCounts = function(self)
        self.Roles = {
            Tank = { DEATHKNIGHT = 0, WARRIOR = 0, DRUID = 0, PALADIN = 0 },
            Healer = { DRUID = 0, SHAMAN = 0, PRIEST = 0, PALADIN = 0 },
            Ranged = { DRUID = 0, SHAMAN = 0, PRIEST = 0, MAGE = 0, WARLOCK = 0, HUNTER = 0 },
            Melee = { DRUID = 0, SHAMAN = 0, PALADIN = 0, WARRIOR = 0, ROGUE = 0, DEATHKNIGHT = 0 }
        }
    end,
    UpdateRoleCounts = function(self)
        for role, classes in pairs(self.Roles) do
            for class, count in pairs(classes) do
                local t = Guildbook.Data.Class[class].FontStringIconMEDIUM
                self.RoleChart[role][class]:SetText(t..'|cffffffff '..count)
                self.RoleChart[role].Data = classes
            end
        end
    end,
    FetchRoleData = function(self)
        DEBUG('fetching role data')
        GuildRoster()
        local requestSent = C_ChatInfo.SendAddonMessage('gb-sum-req', 'requestdata', 'GUILD')
        if requestSent then
            DEBUG('sent summary request to all guild members')
        end
    end,
    HandleAddonMessage = function(self, ...)
        local prefix = select(1, ...)
        local msg = select(2, ...)
        local sender = select(5, ...)
        if prefix == 'gb-sum-req' then
            local dataSent = C_ChatInfo.SendAddonMessage('gb-sum-data', tostring(Guildbook.PLAYER_CLASS..':'..GUILDBOOK_CHARACTER['MainSpec']..':'..GUILDBOOK_CHARACTER['OffSpec']), 'WHISPER', sender)
            if dataSent then
                DEBUG('sent summary data to guild to: '..sender)
            end
        elseif prefix == 'gb-sum-data' then
            DEBUG('data reply from '..sender)
            local t = {}
            local keys = { 'Class', 'MainSpec', 'OffSpec' } 
            local i = 1
            for d in string.gmatch(msg, '[^:]+') do
                t[keys[i]] = d
                i = i + 1
            end
            if t.MainSpec ~= '-' then
                self.Roles[Guildbook.Data.SpecToRole[t.Class][t.MainSpec]][t.Class] = self.Roles[Guildbook.Data.SpecToRole[t.Class][t.MainSpec]][t.Class] + 1
            end
            for role, classes in pairs(self.Roles) do
                for class, count in pairs(classes) do
                    DEBUG(role..' '..class..' '..count)
                end
            end
            self:UpdateRoleCounts()
        end
    end,
}




Guildbook.GuildInfoFrame.Init()
