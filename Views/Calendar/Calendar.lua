local name , addon = ...;

local L = addon.Locales;


local Calendar = {}

Calendar.Event = {}
function Calendar.Event:New(title, desc, type, starts)
    if addon.thisCharacter then
        local event = {
            title = title,
            desc = desc,
            type = type,
            starts = starts,
            group = {},
            owner = addon.thisCharacter,
            id = string.format("%s-%d", addon.thisCharacter, starts)
        }
        return Mixin(event, self)
    end
end

function Calendar.Event:CreateFromData(data)
    if data.title and data.desc and data.type and data.starts and data.group and data.owner and data.id then
        local event = {
            data = data,
        }
        return Mixin(event, self)
    end
end

function Calendar.Event:GetID()
    return self.id;
end

function Calendar.Event:UpdateTitle(title)
    self.title = title;
end

function Calendar.Event:UpdateDescription(desc)
    self.desc = desc;
end

function Calendar.Event:UpdateStartTime(starts)
    self.starts = starts;
end

function Calendar.Event:UpdateType(type)
    self.type = type;
end

function Calendar.Event:UpdateGroup(character, status)
    self.group[character] = status;
end







GuildbookCalendarDayTileMixin = {
    CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH = 90 / 256 - 0.001,
    CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT = 90 / 256 - 0.001,
}

function GuildbookCalendarDayTileMixin:OnLoad()
    
    local texLeft = random(0,1) * self.CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
    local texRight = texLeft + self.CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
    local texTop = random(0,1) * self.CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
    local texBottom = texTop + self.CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;

    self.background:SetTexture(235428)
    self.background:SetTexCoord(texLeft, texRight, texTop, texBottom)

    self.highlight:SetTexture(235438)
    self.highlight:SetTexCoord(0.0, 0.35, 0.0, 0.7)

    self.overlay:SetColorTexture(0,0,0,0.6)
    self.currentDayTexture:SetTexture(235433)
    self.currentDayTexture:SetTexCoord(0.05, 0.55, 0.05, 0.55)
    self.currentDayTexture:SetAlpha(0.7)

    self.worldEventTexture:SetTexture(235448)
    self.worldEventTexture:SetTexCoord(0.0, 0.71, 0.0, 0.71)

    self.worldEvents = {}
    self.guildEvents = {}

end





GuildbookCalendarMixin = {
    name = "Calendar",
}

function GuildbookCalendarMixin:UpdateLayout()
    local x, y = self:GetSize();

    local sidePanelWidth = (x * 0.27);

    local monthViewWidth = x - sidePanelWidth;

    self.dayTileWidth = monthViewWidth / 7;
    self.dayTileHeight = (y - 18) / 6;

    for k, v in ipairs(self.monthView.dayHeaders) do
        v.background:ClearAllPoints()
        v.background:SetWidth(self.dayTileWidth)
        v.background:SetPoint("TOPLEFT", (k-1) * self.dayTileWidth, 0)
        v.label:SetWidth(self.dayTileWidth)
        v.label:SetWidth(self.dayTileWidth)
        v.label:SetPoint("TOPLEFT", (k-1) * self.dayTileWidth, 0)
    end


    local i = 1;
    for week = 1, 6 do
        for day = 1, 7 do
            local tile = self.monthView.dayTiles[i]
            tile:ClearAllPoints()
            tile:SetSize(self.dayTileWidth, self.dayTileHeight)
            tile:SetPoint("TOPLEFT",  ((day - 1) * self.dayTileWidth), (((week - 1) * self.dayTileHeight) * -1) -18 )
            i = i + 1;
        end
    end

    self.monthView:SetSize(monthViewWidth, y)
end

function GuildbookCalendarMixin:OnShow()
    self:UpdateLayout()
end

function GuildbookCalendarMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    self.date = date("*t")

    self.weekdays = {
        L["MONDAY"],
        L["TUESDAY"],
        L["WEDNESDAY"],
        L["THURSDAY"],
        L["FRIDAY"],
        L["SATURDAY"],
        L["SUNDAY"],
    }
    self.monthNames = {
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

    self.dayTileWidth = 88;
    self.dayTileHeight = 64;

    self.monthView:SetWidth(self.dayTileWidth * 7)

    self.monthView.dayHeaders = {}
    for i = 0, 6 do
        local t = self.monthView:CreateTexture(nil, "ARTWORK")
        t:SetTexture(235428)
        t:SetTexCoord(0.0, 0.35, 0.71, 0.81)
        t:SetSize(self.dayTileWidth, 18)
        t:SetPoint("TOPLEFT", i * self.dayTileWidth, 0)

        local f = self.monthView:CreateFontString(nil, "OVERLAY", "GameFontWhite")
        f:SetSize(self.dayTileWidth, 18)
        f:SetPoint("TOPLEFT", i * self.dayTileWidth, 0)
        f:SetText(self.weekdays[i+1])

        self.monthView.dayHeaders[i+1] = {
            background = t,
            label = f,
        }
    end

    self.monthView.dayTiles = {}
    local i = 1;
    for week = 1, 6 do
        for day = 1, 7 do
            local tile = CreateFrame("FRAME", nil, self.monthView, "GuildbookCalendarDayTile")
            tile:SetPoint("TOPLEFT",  ((day - 1) * self.dayTileWidth), (((week - 1) * self.dayTileHeight) * -1) -18 )
            tile:SetSize(self.dayTileWidth, self.dayTileHeight)

            self.monthView.dayTiles[i] = tile;
            i = i + 1;
        end
    end


    self.sidePanel.previousMonth:SetNormalTexture(130869)
    self.sidePanel.previousMonth:SetPushedTexture(130868)
    self.sidePanel.previousMonth:SetScript("OnClick", function()
        if self.date.month == 1 then
            self.date.month = 12
            self.date.year = self.date.year - 1
        else
            self.date.month = self.date.month - 1
        end
        self:MonthChanged()
    end)
    self.sidePanel.nextMonth:SetNormalTexture(130866)
    self.sidePanel.nextMonth:SetPushedTexture(130865)
    self.sidePanel.nextMonth:SetScript("OnClick", function()
        if self.date.month == 12 then
            self.date.month = 1
            self.date.year = self.date.year + 1
        else
            self.date.month = self.date.month + 1
        end
        self:MonthChanged()
    end)


    self:MonthChanged()

    addon.AddView(self)
end

function GuildbookCalendarMixin:GetDaysInMonth(month, year)
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

function GuildbookCalendarMixin:GetMonthStart(month, year)
    local today = date('*t')
    today.day = 0
    today.month = month
    today.year = year
    local monthStart = date('*t', time(today))
    return monthStart.wday
end

function GuildbookCalendarMixin:MonthChanged()
    self.sidePanel.monthName:SetText(self.monthNames[self.date.month]..' '..self.date.year)
    local monthStart = self:GetMonthStart(self.date.month, self.date.year)
    local daysInMonth = self:GetDaysInMonth(self.date.month, self.date.year)
    local daysInLastMonth = 0
    if self.date.month == 1 then
        daysInLastMonth = self:GetDaysInMonth(12, self.date.year - 1)
    else
        daysInLastMonth = self:GetDaysInMonth(self.date.month - 1, self.date.year)
    end
    local thisMonthDay, nextMonthDay = 1, 1
    for i, day in ipairs(self.monthView.dayTiles) do
        for b = 1, 3 do
            day['event'..b]:Hide()
        end
        day.currentDayTexture:Hide()
        -- wipe(day.events)
        -- wipe(day.worldEvents)
        day.dmf = false
        day:EnableMouse(false)
        day.dateLabel:SetText(' ')
        day.worldEventTexture:SetTexture(nil)
        -- day.guildEventTexture:SetTexture(nil)
        local today = date("*t")
        if thisMonthDay == today.day and self.date.month == today.month then
            day.currentDayTexture:Show()
        end

        -- setup days in previous month
        if i < monthStart then
            day.dateLabel:SetText((daysInLastMonth - monthStart + 2) + (i - 1))
            day.dateLabel:SetTextColor(0.5, 0.5, 0.5, 1)
            day.overlay:Show()
        end

        -- setup current months days
        if i >= monthStart and thisMonthDay <= daysInMonth then
            day.dateLabel:SetText(thisMonthDay)
            day.dateLabel:SetTextColor(1,1,1,1)
            day.overlay:Hide()
            day:EnableMouse(true)
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
                day.worldEventTexture:SetTexture(addon.CalendarWorldEvents[L["DARKMOON_FAIRE"]][dmf]['Start'])
                day.dmf = dmf
            end
            if i > 7 and i < 14 then
                day.worldEventTexture:SetTexture(addon.CalendarWorldEvents[L["DARKMOON_FAIRE"]][dmf]['OnGoing'])
                day.dmf = dmf
            end
            if i == 14 then
                day.worldEventTexture:SetTexture(addon.CalendarWorldEvents[L["DARKMOON_FAIRE"]][dmf]['End'])
                day.dmf = dmf
            end

            for eventName, event in pairs(addon.CalendarWorldEvents) do
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

            --day.events = self:GetEventsForDate(day.date)
            day:Show()
            thisMonthDay = thisMonthDay + 1
        end

        -- setup days in following month
        if i > (daysInMonth + (monthStart - 1)) then
            day.dateLabel:SetText(nextMonthDay)
            day.dateLabel:SetTextColor(0.5, 0.5, 0.5, 1)
            day.overlay:Show()
            nextMonthDay = nextMonthDay + 1
        end
    end
end
