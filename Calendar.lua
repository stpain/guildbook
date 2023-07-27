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

-- Legacy: old code for previous guildbook UI

local addonName, Guildbook = ...
local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- calendar
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:SetupGuildCalendarFrame()

    if not self.GuildFrame.GuildCalendarFrame then
        self.GuildFrame.GuildCalendarFrame = CreateFrame('FRAME', 'GuildbookGuildFrameCalendarFrame', GuildFrame, BackdropTemplateMixin and "BackdropTemplate")
    end

    self.GuildFrame.GuildCalendarFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.GuildCalendarFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.GuildCalendarFrame, 'TOPRIGHT', -2, 2, L['calendarHelpText'])

    self.GuildFrame.GuildCalendarFrame.date = date('*t')

    local weekdays = {
        L["MONDAY"],
        L["TUESDAY"],
        L["WEDNESDAY"],
        L["THURSDAY"],
        L["FRIDAY"],
        L["SATURDAY"],
        L["SUNDAY"],
    }

    local monthNames = {
        L['JANUARY'],
        L['FEBRUARY'],
        L['MARCH'],
        L['APRIL'],
        L['MAY'],
        L['JUNE'],
        L['JULY'],
        L['AUGUST'],
        L['SEPTEMBER'],
        L['OCTOBER'],
        L['NOVEMBER'],
        L['DECEMBER']
    }

    local status = {
        [0] = L["DECLINE"],
        [1] = L["ATTENDING"],
        [2] = L["TENTATIVE"],
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


    local raids = {
        { name = L["MC"], textureKey = "moltencore", },
        { name = L["BWL"], textureKey = "blackwinglair", },
        { name = L["AQ20"], textureKey = "ruinsofahnqiraj", },
        { name = L["AQ40"], textureKey = "templeofahnqiraj", }, -- so anoying
        { name = L["Naxxramas"], textureKey = "naxxramas", },
        { name = L["ZG"], textureKey = "zulgurub", },
        { name = L["Onyxia"], textureKey = "onyxia", },
        { name = L["Magtheridon"], textureKey = "magtheridonslair", },
        { name = L["SSC"], textureKey = "coilfangreservoir", },
        { name = L["TK"], textureKey = "tempestkeep", },
        { name = L["Gruul"], textureKey = "gruulslair", },
        { name = L["Hyjal"], textureKey = "cavernsoftime", },
        { name = L["BT"], textureKey = "blacktemple", },
        { name = L["SWP"], textureKey = "sunwellplateau", },
        { name = L["Karazhan"], textureKey = "karazhan", },
    }

    local raidsMenu = {}
    for k, raid in ipairs(raids) do
        table.insert(raidsMenu, {
            text = raid.name,
            icon = string.format("interface/encounterjournal/ui-ej-dungeonbutton-%s", raid.textureKey),
            notCheckable = true,
            func = function()
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetText(raid.name)
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 1
                CloseDropDownMenus()
            end,
        })
    end

    -- this table is the dropdown menu for the event type dropdown widget in the event pop out frame
    local eventTypes = {
        { 
            text = L["DUNGEON"], 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 3
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, L["DUNGEON"])
            end, 
        },
        { 
            text = L["RAID"], 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 1
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, L["RAID"])
            end,
            hasArrow = true,
            menuList = raidsMenu,
        },
        { 
            text = L['PVP'], 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 2
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 'PVP')
            end, 
        },
        { 
            text = L["MEETING"], 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 4
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, L["MEETING"])
            end,  
        },
        { 
            text = L["OTHER"], 
            notCheckable = true, 
            func = function(self) 
                Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.eventType = 5
                UIDropDownMenu_SetText(Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, L["OTHER"])
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
    self.GuildFrame.GuildCalendarFrame.Header:SetText(L["GUILD_CALENDAR"])
    self.GuildFrame.GuildCalendarFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildCalendarFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.GuildCalendarFrame.NextMonthButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameNextMonthButton', self.GuildFrame.GuildCalendarFrame, BackdropTemplateMixin and "BackdropTemplate") --, "UIPanelButtonTemplate")
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

    self.GuildFrame.GuildCalendarFrame.PrevMonthButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFramePrevMonthButton', self.GuildFrame.GuildCalendarFrame, BackdropTemplateMixin and "BackdropTemplate") --, "UIPanelButtonTemplate")
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

    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameInstanceInfoFrame', Guildbook.GuildFrame.GuildCalendarFrame, BackdropTemplateMixin and "BackdropTemplate")
    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame:SetPoint('TOPRIGHT', -6, -6)
    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame:SetPoint('BOTTOMRIGHT', -6, 6)
    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame:SetWidth(285)
    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame.header = self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame.header:SetPoint('TOP', 0, -4)
    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame.header:SetText(L["INSTANCE_LOCKS"])
    self.GuildFrame.GuildCalendarFrame.InstanceInfoFrame.rows = {}


    self.GuildFrame.GuildCalendarFrame.CalendarParent = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameParent', Guildbook.GuildFrame.GuildCalendarFrame, BackdropTemplateMixin and "BackdropTemplate")
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetPoint('TOPLEFT', 6, -23)
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetPoint('BOTTOMLEFT', 6, 0)
    self.GuildFrame.GuildCalendarFrame.CalendarParent:SetWidth(490)

    -- draw days
    local CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH = 90 / 256 - 0.001
    local CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT = 90 / 256 - 0.001
    local dayW, dayH = 70, 53

    dayW = dayW * 1.26
    dayH = dayH * 1.26

    for i = 1, 7 do
        local f = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameDayHeaders'..i, Guildbook.GuildFrame.GuildCalendarFrame, BackdropTemplateMixin and "BackdropTemplate")
        f:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.GuildCalendarFrame.CalendarParent, 'TOPLEFT', (i - 1) * dayW, 1)
        f:SetSize(dayW, 18)
        f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
        f.background:SetAllPoints(f)
        f.background:SetTexture(235428)
        f.background:SetTexCoord(0.0, 0.35, 0.71, 0.81)
        f.text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormal')
        f.text:SetPoint('CENTER', 0, 0)
        f.text:SetTextColor(1,1,1,1)
        f.text:SetText(weekdays[i])
    end

    -- setup the calendar, each day is a frame added to this table
    self.GuildFrame.GuildCalendarFrame.MonthView = {}
    local i = 1
    for week = 1, 6 do
        for day = 1, 7 do
            local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameGuildCalendarFrameWeek'..week..'Day'..day), Guildbook.GuildFrame.GuildCalendarFrame.CalendarParent, BackdropTemplateMixin and "BackdropTemplate")
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

            -- add the dark shading for days not in month
            f.overlay = f:CreateTexture('$parentBackground', 'OVERLAY')
            f.overlay:SetPoint('TOPLEFT', 0, 0)
            f.overlay:SetPoint('BOTTOMRIGHT', 0, 0)
            f.overlay:SetColorTexture(0,0,0,0.6)
            f.overlay:Hide()

            -- add a texture to use for world events
            f.worldEventTexture = f:CreateTexture('$parentWorldEventBackground', 'BORDER')
            f.worldEventTexture:SetPoint('TOPLEFT', 0, 0)
            f.worldEventTexture:SetPoint('BOTTOMRIGHT', 0, 0)
            f.worldEventTexture:SetTexture(235448)
            f.worldEventTexture:SetTexCoord(0.0, 0.71, 0.0, 0.71)

            -- add a texture to use for guild events
            -- set this as top layer so its clear there is an event
            f.guildEventTexture = f:CreateTexture('$parentGuildEventBackground', 'ARTWORK')
            -- f.guildEventTexture:SetAllPoints(f)
            f.guildEventTexture:SetPoint('TOPLEFT', -2, 3)
            f.guildEventTexture:SetPoint('BOTTOMRIGHT', 0,0)
            f.guildEventTexture:SetAlpha(1)
            f.guildEventTexture:SetTexCoord(0.0, 0.64, 0.0, 0.7)

            -- add the current day border texture
            f.currentDayTexture = f:CreateTexture('$parentCurrentDayTexture', 'OVERLAY')
            f.currentDayTexture:SetPoint('TOPLEFT', -15, 15)
            f.currentDayTexture:SetPoint('BOTTOMRIGHT', 16, -10)
            f.currentDayTexture:SetTexture(235433)
            f.currentDayTexture:SetTexCoord(0.05, 0.55, 0.05, 0.55)
            f.currentDayTexture:SetAlpha(0.7)
            f.currentDayTexture:Hide()

            -- add 3 buttons to the day, 4 buttons would take over most of the day and 4 events scheduled for 1 day is less likely however it could be made into 4 if requested
            local eHeight = 14;
            for e = 1, 3 do
                f['eventButton'..e] = CreateFrame('BUTTON', tostring('GuildbookGuildFrameGuildCalendarFrameWeek'..week..'Day'..day..'Button'..e), f, BackdropTemplateMixin and "BackdropTemplate")
                f['eventButton'..e]:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 1, ((e - 1) * eHeight) + 3)
                f['eventButton'..e]:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -1, ((e - 1) * eHeight) + 3)
                f['eventButton'..e]:SetSize(dayW, eHeight)
                f['eventButton'..e].text = f["eventButton"..e]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                f['eventButton'..e].text:SetPoint("CENTER", 0, 0)
                f['eventButton'..e].text:SetSize(dayW, eHeight)
                --f['eventButton'..e].text:SetFont("Fonts\\FRIZQT__.TTF", 11) --, 'OUTLINE')
                f['eventButton'..e]:SetHighlightTexture(404984)
                f['eventButton'..e]:GetHighlightTexture():SetTexCoord(0.0, 0.6, 0.75, 0.85)
                f['eventButton'..e]:Hide()
                f['eventButton'..e].event = nil
                f['eventButton'..e]:SetScript('OnClick', function(self)
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:Disable()
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
            f.worldEvents = {}

            f.dateText = f:CreateFontString('$parentDateText', 'OVERLAY', 'GameFontNormalSmall')
            f.dateText:SetPoint('TOPLEFT', 3, -3)
            f.dateText:SetTextColor(1,1,1,1)

            f:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                --if self.worldEvents and next(self.worldEvents) then
                    GameTooltip:AddLine(L['Events'])
                --end
                if f.dmf ~= false then
                    GameTooltip:AddLine(L["DMF display"]..f.dmf)
                end
                if self.worldEvents then
                    for event, _ in pairs(self.worldEvents) do
                        GameTooltip:AddLine('|cffffffff'..event)
                    end
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
                f.guildEventTexture:SetTexture(nil)
                f.guildEventTexture:Hide()
                for i = 1, 3 do
                    f['eventButton'..i]:Hide()
                    f['eventButton'..i].text:SetText('')
                    f['eventButton'..i].event = nil
                end
                if self.events then
                    for k, event in ipairs(self.events) do
                        f['eventButton'..k]:Show()
                        f['eventButton'..k].text:SetText('|cffffffff'..event.title)
                        f['eventButton'..k].event = event

                        -- change this to just use the first texture in the event list
                        -- for now find a raid to add the texture
                        if event.type == 1 then

                            for k, raid in ipairs(raids) do
                                if raid.name == event.title then
                                    f.guildEventTexture:SetTexture(string.format("interface/encounterjournal/ui-ej-dungeonbutton-%s", raid.textureKey))
                                    f.guildEventTexture:Show()
                                end
                            end

                        end

                    end
                else
                    for i = 1, 3 do
                        f['eventButton'..i]:Hide()
                    end
                end
            end)
            
            f:SetScript('OnClick', function(self, button)
                if button == 'LeftButton' then
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:Hide()
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.date = self.date
                    Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.event = nil

                    -- disable the frame if 3 events exist already
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

    -- function self.GuildFrame.GuildCalendarFrame:GetWorldEventsForDay(day, month)
    --     local worldEvent = {}
    --     for worldEvent, info in pairs(Guildbook.CalendarWorldEvents) do
    --         if worldEvent ~= 'Darkmoon Faire' then
    --             if info.Start.day == day and info.Start.month == month then

    --             end
    --             if info.End.day == day and info.End.month == month then

    --             end
    --         end
    --     end
    -- end


    -- this function will update the calendar day frames and check for events
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
        local thisMonthDay, nextMonthDay = 1, 1
        for i, day in ipairs(Guildbook.GuildFrame.GuildCalendarFrame.MonthView) do
            for b = 1, 3 do
                day['eventButton'..b]:Hide()
            end
            wipe(day.events)
            wipe(day.worldEvents)
            day.dmf = false
            day:Disable()
            day.dateText:SetText(' ')
            day.worldEventTexture:SetTexture(nil)
            day.guildEventTexture:SetTexture(nil)
            local today = date("*t")
            if thisMonthDay == today.day and self.date.month == today.month then
                day.currentDayTexture:Show()
            else
                day.currentDayTexture:Hide()
            end

            -- setup days in previous month
            if i < monthStart then
                day.dateText:SetText((daysInLastMonth - monthStart + 2) + (i - 1))
                day.dateText:SetTextColor(0.5, 0.5, 0.5, 1)
                day.overlay:Show()
            end

            -- setup current months days
            if i >= monthStart and thisMonthDay <= daysInMonth then
                day.dateText:SetText(thisMonthDay)
                day.dateText:SetTextColor(1,1,1,1)
                day.overlay:Hide()
                day:Enable()
                day.date = {
                    day = thisMonthDay,
                    month = self.date.month,
                    year = self.date.year,
                }
                day:Hide()
                local dmf = 'Elwynn'
                if day.date.month % 2 == 0 then
                    dmf = 'Mulgore'
                end
                if i == 7 then
                    day.worldEventTexture:SetTexture(Guildbook.CalendarWorldEvents[L["DARKMOON_FAIRE"]][dmf]['Start'])
                    day.dmf = dmf
                end
                if i > 7 and i < 14 then
                    day.worldEventTexture:SetTexture(Guildbook.CalendarWorldEvents[L["DARKMOON_FAIRE"]][dmf]['OnGoing'])
                    day.dmf = dmf
                end
                if i == 14 then
                    day.worldEventTexture:SetTexture(Guildbook.CalendarWorldEvents[L["DARKMOON_FAIRE"]][dmf]['End'])
                    day.dmf = dmf
                end

                for eventName, event in pairs(Guildbook.CalendarWorldEvents) do
                    if eventName ~= L["DARKMOON_FAIRE"] then
                        if (event.Start.month == self.date.month) and (event.Start.day == thisMonthDay) then
                            day.worldEventTexture:SetTexture(event.Texture.Start)
                            if not day.worldEvents[eventName] then
                                day.worldEvents[eventName] = true
                            end
                        end
                        if (event.End.month == self.date.month) and (event.End.day == thisMonthDay) then
                            day.worldEventTexture:SetTexture(event.Texture.End)
                            if not day.worldEvents[eventName] then
                                day.worldEvents[eventName] = true
                            end
                        end

                        -- events in the same month
                        if (event.Start.month == self.date.month) and (event.Start.month == event.End.month) then
                            if thisMonthDay > event.Start.day and thisMonthDay < event.End.day then
                                day.worldEventTexture:SetTexture(event.Texture.OnGoing)
                                if not day.worldEvents[eventName] then
                                    day.worldEvents[eventName] = true
                                end
                            end
                        end

                        -- events that cover 2 months
                        if (event.Start.month == self.date.month) and (event.Start.month < event.End.month) then
                            if thisMonthDay > event.Start.day then
                                day.worldEventTexture:SetTexture(event.Texture.OnGoing)
                                if not day.worldEvents[eventName] then
                                    day.worldEvents[eventName] = true
                                end
                            end
                        end
                        if (event.End.month == self.date.month) and (event.Start.month < event.End.month) then
                            if thisMonthDay < event.End.day then
                                day.worldEventTexture:SetTexture(event.Texture.OnGoing)
                                if not day.worldEvents[eventName] then
                                    day.worldEvents[eventName] = true
                                end
                            end
                        end
                    end
                    -- special case for christmas as it covers 2 years
                    if eventName == L["FEAST_OF_WINTER_VEIL"] then
                        if self.date.month == 12 then
                            if thisMonthDay == event.Start.day then
                                day.worldEventTexture:SetTexture(event.Texture.Start)
                                if not day.worldEvents[eventName] then
                                    day.worldEvents[eventName] = true
                                end
                            end
                            if thisMonthDay > event.Start.day then
                                day.worldEventTexture:SetTexture(event.Texture.OnGoing)
                                if not day.worldEvents[eventName] then
                                    day.worldEvents[eventName] = true
                                end
                            end
                        end
                        if self.date.month == 1 then
                            if thisMonthDay == event.End.day then
                                day.worldEventTexture:SetTexture(event.Texture.End)
                                if not day.worldEvents[eventName] then
                                    day.worldEvents[eventName] = true
                                end
                            end
                            if thisMonthDay < event.End.day then
                                day.worldEventTexture:SetTexture(event.Texture.OnGoing)
                                if not day.worldEvents[eventName] then
                                    day.worldEvents[eventName] = true
                                end
                            end
                        end
                        day.worldEventTexture:SetTexCoord(0.0, 0.71, 0.0, 0.55)
                    end
                end

                day.events = self:GetEventsForDate(day.date)
                day:Show()
                thisMonthDay = thisMonthDay + 1
            end

            -- setup days in following month
            if i > (daysInMonth + (monthStart - 1)) then
                day.dateText:SetText(nextMonthDay)
                day.dateText:SetTextColor(0.5, 0.5, 0.5, 1)
                day.overlay:Show()
                nextMonthDay = nextMonthDay + 1
            end
        end
    end

    self.GuildFrame.GuildCalendarFrame.EventFrame = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameEventFrame', self.GuildFrame.GuildCalendarFrame, BackdropTemplateMixin and "BackdropTemplate") --, "UIPanelDialogTemplate")
    -- self.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('TOPLEFT', GuildFrame, 'TOPRIGHT', 4, 0)
    -- self.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('BOTTOMRIGHT', GuildFrame, 'BOTTOMRIGHT', 254, 0)
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

    self.GuildFrame.GuildCalendarFrame.EventFrame.OwnerText = self.GuildFrame.GuildCalendarFrame.EventFrame:CreateFontString('$parentOwner', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildCalendarFrame.EventFrame.OwnerText:SetPoint('TOP', 0, -36)

    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameCreateEventButton', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetPoint('BOTTOMLEFT', 10, 10)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetSize(115, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetText(L["CREATE_EVENT"])
    self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton:SetScript('OnClick', function()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:CreateEvent()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameCancelEventButton', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:SetPoint('LEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.CreateEventButton, 'RIGHT', 0, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:SetSize(115, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelEventButton:SetText(L["DELETE_EVENT"])
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
        self:GetParent().AttendEventButton_Decline:Disable()
        self:GetParent():ResetClassCounts()
        self:GetParent():ResetAttending()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameCancelButton', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetPoint('TOPRIGHT', -10, -10)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetSize(24, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetNormalTexture(130832)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.85)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetHighlightTexture(130831)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:GetHighlightTexture(130831):SetTexCoord(0.1, 0.9, 0.1, 0.85)
    self.GuildFrame.GuildCalendarFrame.EventFrame.CancelButton:SetScript('OnClick', function(self)
        self:GetParent():Hide()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox = CreateFrame('EDITBOX', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventTitleEditbox', self.GuildFrame.GuildCalendarFrame.EventFrame, "InputBoxTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetPoint('TOPLEFT', 25, -65)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetSize(200, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:ClearFocus()
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetAutoFocus(false)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:SetMaxLetters(50)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox.header = self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox:CreateFontString('$parentHeader', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox.header:SetPoint('BOTTOMLEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox, 'TOPLEFT', 0, 2)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTitleEditbox.header:SetText(L["TITLE"])

    local etdt = self.GuildFrame.GuildCalendarFrame.EventFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    etdt:SetPoint("TOPLEFT", 25, -96)
    etdt:SetText(L["EVENT_TYPE"])

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown = CreateFrame('FRAME', "GuildbookGuildFrameGuildCalendarFrameEventFrameEventTypeDropdown", self.GuildFrame.GuildCalendarFrame.EventFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown:SetPoint('TOPLEFT', etdt, 'BOTTOMLEFT', -20, -4)
    UIDropDownMenu_SetWidth(self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 75)
    UIDropDownMenu_SetText(self.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, L["EVENT"])
    _G['GuildbookGuildFrameGuildCalendarFrameEventFrameEventTypeDropdownButton']:SetScript('OnClick', function(self)
        EasyMenu(eventTypes, Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventTypeDropdown, 10, 10, 'NONE')
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventDescriptionEditboxParent', self.GuildFrame.GuildCalendarFrame.EventFrame, BackdropTemplateMixin and "BackdropTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent:SetPoint('TOPLEFT', 20, -160)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent:SetSize(206, 80)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox = CreateFrame('EDITBOX', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventDescriptionEditbox', self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent, BackdropTemplateMixin and "BackdropTemplate") --, "InputBoxTemplate")
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
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox.header:SetText(L["DESCRIPTION"])

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventDescriptionFrameUpdateButton', Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent, 'UIPanelButtonTemplate')
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent, 'TOPRIGHT', 0, 2)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton:SetSize(70, 20)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton:SetNormalFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton:SetHighlightFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton:SetDisabledFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton:SetText(L["UPDATE"])
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditboxParent.UpdateButton:SetScript('OnClick', function(self)
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame:UpdateEvent()
        Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventDescriptionEditbox:ClearFocus()
    end)

    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventAttendeesListviewParent', self.GuildFrame.GuildCalendarFrame.EventFrame, BackdropTemplateMixin and "BackdropTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:SetPoint('BOTTOMLEFT', 20, 45)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:SetSize(206, 180)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:EnableMouse(true)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendingListview = {}
    for i = 1, 15 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameGuildCalendarFrameEventFrameAttendListviewRow'..i), self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent)
        f:SetPoint('TOPLEFT', 0, ((i - 1) * -16) - 6)
        f:SetPoint('TOPRIGHT', -25, ((i - 1) * -16) - 6)
        f:SetHeight(11)
        f.character = f:CreateFontString('$parentCharacter', 'OVERLAY', 'GameFontNormalSmall')
        f.character:SetPoint('LEFT', 10, 0)
        f.character:SetText('')
        f.status = f:CreateFontString('$parentStatus', 'OVERLAY', 'GameFontNormalSmall')
        f.status:SetPoint('LEFT', 100, 0)
        f.status:SetText('Confirmed')
        self.GuildFrame.GuildCalendarFrame.EventFrame.AttendingListview[i] = f
    end
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventAttendeesListviewScrollBar', self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, "UIPanelScrollBarTemplate")
    --self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameGuildCalendarFrameEventFrameEventAttendeesListviewScrollBar', self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, "OptionsSliderTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetOrientation('VERTICAL')
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetPoint('TOPRIGHT', Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, 'TOPRIGHT', -8, -22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildCalendarFrame.EventFrame.EventAttendeesListviewParent, 'BOTTOMRIGHT', -8, 22)
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
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Confirm:SetText(L["ATTENDING"])
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
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetText(L["TENTATIVE"])
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative:SetScript('OnClick', function(self)
        local event = self:GetParent().event
        local guildName = Guildbook:GetGuildName()
        if guildName and event then
            Guildbook:SendGuildCalendarEventAttend(event, 2)
        end
    end)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline = CreateFrame('BUTTON', 'GuildbookGuildFrameGuildCalendarFrameEventFrameAttendEventButtonUnable', self.GuildFrame.GuildCalendarFrame.EventFrame, "UIPanelButtonTemplate")
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline:SetPoint('LEFT', self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Tentative, 'RIGHT', 0, 0)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline:SetSize(68, 22)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline:SetNormalFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline:SetHighlightFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline:SetDisabledFontObject(GameFontNormalSmall)
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline:SetText(L["DECLINE"])
    self.GuildFrame.GuildCalendarFrame.EventFrame.AttendEventButton_Decline:SetScript('OnClick', function(self)
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
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameGuildCalendarFrameEventFrameClassTab'..classes[i]), self.GuildFrame.GuildCalendarFrame.EventFrame, BackdropTemplateMixin and "BackdropTemplate")
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
        local attending = false;
        if self.event and next(self.event.attend) then   
            local i = 0
            for guid, info in pairs(self.event.attend) do
                if guid == UnitGUID("player") then
                    if info.Status == 1 then
                        attending = true
                    elseif info.Status == 2 then
                        attending = true
                    end
                end
                -- dont update if the player is declining
                if info.Status ~= 0 then
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
    end



    function self.GuildFrame.GuildCalendarFrame.EventFrame:UpdateEvent()
        if self.event then
            local event = self.event
            local title = self.EventTitleEditbox:GetText()
            if title:len() == 0 then
                title = '-'
            end
            local description = self.EventDescriptionEditbox:GetText()
            if description:len() == 0 then
                description = '-'
            end

            local owner = event.owner
            local created = event.created

            event.title = title
            event.desc = description

            Guildbook:PushEventUpdate(event)
        end
    end

    function self.GuildFrame.GuildCalendarFrame.EventFrame:UpdateAttending()
        local scroll = math.floor(self.EventAttendeesListviewScrollBar:GetValue())
        for k = 1, 15 do
            self.AttendingListview[k].character:SetText('')
            self.AttendingListview[k].status:SetText('')
        end
        if self.event and next(self.event.attend) then            
            local i = 0
            self.AttendEventButton_Confirm:Enable()
            self.AttendEventButton_Tentative:Enable()
            self.AttendEventButton_Decline:Enable()
            for guid, info in pairs(self.event.attend) do
                if guid == UnitGUID("player") then
                    if info.Status == 1 then
                        self.AttendEventButton_Confirm:Disable()
                    elseif info.Status == 2 then
                        self.AttendEventButton_Tentative:Disable()
                    else
                        self.AttendEventButton_Decline:Disable()
                    end
                end
                if info.Status ~= 0 then
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
                            if i > ((scroll * 15) - 15) and i <= (scroll * 15) then
                                self.AttendingListview[i].character:SetText(Guildbook.Data.Class[class].FontColour..name)
                                self.AttendingListview[i].status:SetText(status[info.Status])
                            end
                        end
                    end
                end
            end
        end
    end

    -- setup the event frame pop out
    -- if no event show an enabled frame with no data
    -- otherwise show event info
    self.GuildFrame.GuildCalendarFrame.EventFrame:SetScript('OnShow', function(self)
        self:ResetClassCounts()
        self:UpdateClassTabs()
        self:ResetAttending()
        if self.date then
            self.HeaderText:SetText(string.format('%s/%s/%s', self.date.day, self.date.month, self.date.year))
        end
        if self.event then
            if not Guildbook.PlayerMixin then
                Guildbook.PlayerMixin = PlayerLocation:CreateFromGUID(self.event.owner)
            else
                Guildbook.PlayerMixin:SetGUID(self.event.owner)
            end
            if Guildbook.PlayerMixin:IsValid() then
                local name = C_PlayerInfo.GetName(Guildbook.PlayerMixin)
                if not name then
                    self.OwnerText:SetText(' ')
                else
                    self.OwnerText:SetText(name)
                end
            end
            self.HeaderText:SetText(string.format('%s/%s/%s', self.event.date.day, self.event.date.month, self.event.date.year))
            self.EventTitleEditbox:SetText(self.event.title)
            self.EventTitleEditbox:Disable()
            self.EventDescriptionEditbox:SetText(self.event.desc)

            if self.event.owner == UnitGUID('player') then
                self.EventDescriptionEditbox:Enable()
                self.EventDescriptionEditboxParent.UpdateButton:Show()
            else
                self.EventDescriptionEditbox:Disable()
                self.EventDescriptionEditboxParent.UpdateButton:Hide()
            end

            self.CreateEventButton:Disable()
            self.AttendEventButton_Confirm:Enable()
            self.AttendEventButton_Tentative:Enable()
            self.AttendEventButton_Decline:Enable()
            UIDropDownMenu_SetText(self.EventTypeDropdown, eventTypesReversed[self.event.type])
            if self.event.owner == UnitGUID('player') then
                self.CancelEventButton:Enable()
            else
                self.CreateEventButton:Disable()
            end
        else
            self.OwnerText:SetText(' ')
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
            self.AttendEventButton_Decline:Disable()
        end
        self:UpdateAttending()
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
                --SendChatMessage(string.format("|cff0070DEGuildbook|r: Event created, check out %s in the calendar!", title), 'GUILD')
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


    function self.GuildFrame.GuildCalendarFrame:UpdateInstanceInfo()
        local info = Guildbook.GetInstanceInfo()
        if info and next(info) then
            if #info > 1 then
                table.sort(info, function(a, b) return a.Resets < b.Resets end)
            end
            for k, raid in ipairs(info) do
                --local dateObj = date('*t', tonumber(GetTime() + raid.Resets))
                if not self.InstanceInfoFrame.rows[k] then
                    local f = CreateFrame('FRAME', 'GuildbookGuildFrameGuildCalendarFrameinstanceInfoRow'..k, self.InstanceInfoFrame, BackdropTemplateMixin and "BackdropTemplate")
                    f:SetPoint('TOP', 0, ((k-1) * -20) - 20)
                    f:SetSize(285, 20)

                    f.progress = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                    f.progress:SetPoint('LEFT', 180, 0)                
                    f.progress:SetText(raid.Progress..'/'..raid.Encounters)

                    f.raid = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                    f.raid:SetPoint('LEFT', 10, 0)
                    f.raid:SetText(raid.Name)

                    f.unlocks = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                    f.unlocks:SetPoint('LEFT', 220, 0)                    
                    f.unlocks:SetText(SecondsToTime(raid.Resets))

                    self.InstanceInfoFrame.rows[k] = f
                else
                    self.InstanceInfoFrame.rows[k].progress:SetText(raid.Progress..'/'..raid.Encounters)
                    self.InstanceInfoFrame.rows[k].raid:SetText(raid.Name)
                    self.InstanceInfoFrame.rows[k].unlocks:SetText(SecondsToTime(raid.Resets))
                end
            end
        end
    end


    self.GuildFrame.GuildCalendarFrame:SetScript('OnShow', function(self)
        self:MonthChanged()
        --FriendsFrame:SetHeight(FRIENDS_FRAME_HEIGHT + 90)

        self:UpdateInstanceInfo()
    end)

    self.GuildFrame.GuildCalendarFrame:SetScript('OnHide', function(self)
        --FriendsFrame:SetHeight(FRIENDS_FRAME_HEIGHT)
    end)

end
