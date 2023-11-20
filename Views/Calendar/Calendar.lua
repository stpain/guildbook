local name , addon = ...;

local L = addon.Locales;
local Database = addon.Database;
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local Event = {}
function Event:New(title, desc, type, starts)
    if addon.thisCharacter then
        local event = {
            title = title,
            icon = 134149,
            desc = desc,
            type = type,
            starts = starts,
            attendees = {},
            owner = addon.thisCharacter,
        }
        return Mixin(event, self)
    end
end

function Event:CreateFromString(str)

        -- local serialized = LibSerialize:Serialize(census)
        -- local compressed = LibDeflate:CompressDeflate(serialized)
        -- local encoded = LibDeflate:EncodeForPrint(compressed)

    local decoded = LibDeflate:DecodeForPrint(str)
    if not decoded then
        return;
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then
        return;
    end
    local success, data = LibSerialize:Deserialize(decompressed);
    if not success or type(data) ~= "table" then
        return;
    end

    self:CreateFromData(data)

end

function Event:CreateFromData(data)
    if data.title and data.icon and data.desc and data.type and data.starts and data.attendees and data.owner then
        return Mixin({data = data}, self)
    end
end

function Event:GetOwner()
    return self.data.owner;
end

function Event:UpdateTitle(title)
    self.data.title = title;
end

function Event:UpdateDescription(desc)
    self.data.desc = desc;
end

function Event:UpdateStartTime(starts)
    self.data.starts = starts;
end

function Event:UpdateType(type)
    self.data.type = type;
end

function Event:UpdateAttendee(character, status)
    self.data.group[character] = status;
end




local WorldEvent = {}
function WorldEvent:CreateFromData(data)

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

    self.flash:SetTexture(235438)
    self.flash:SetTexCoord(0.0, 0.35, 0.0, 0.7)

    self.otherMonthOverlay:SetColorTexture(0,0,0,0.6)
    self.currentDayTexture:SetTexture(235433)
    self.currentDayTexture:SetTexCoord(0.05, 0.55, 0.05, 0.55)
    self.currentDayTexture:SetAlpha(0.7)

    -- self.worldEventTexture:SetTexture(235448)
    -- self.worldEventTexture:SetTexCoord(0.0, 0.71, 0.0, 0.71)

    self.holidayTextures = {}

    self.eventTexture:Hide()

    self.worldEvents = {}
    self.guildEvents = {}
    self.events = {}

    -- for i = 1, 3 do
    --     self["event"..i]:Raise()
    --     self["event"..i]:SetHeight(16)
    -- end

    self:SetScript("OnEnter", function()
        if self.events and (#self.events > 0) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(date("%d %B %Y", time(self.date)))
            for k, v in ipairs(self.events) do
                GameTooltip:AddLine(v.name, 1,1,1)
            end
            GameTooltip:Show()
        end
    end)
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

end

function GuildbookCalendarDayTileMixin:ClearHolidayTextures()
    for k, v in ipairs(self.holidayTextures) do
        v:SetTexture(nil)
    end
end





GuildbookCalendarMixin = {
    name = "Calendar",
}

function GuildbookCalendarMixin:UpdateLayout()
    local x, y = self:GetSize();

    local sidePanelWidth = (x * 0.3);

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
    self:MonthChanged()
    self:UpdateLayout()
end

function GuildbookCalendarMixin:UpdateCalendarEvents()

    local t = {}

    local daysInMonth = self:GetDaysInMonth(self.date.month, self.date.year)

    local from = {
        day = 1,
        month = self.date.month,
        year = self.date.year,
    }

    local to = {
        day = daysInMonth,
        month = self.date.month,
        year = self.date.year,
    }

    local events = Database:GetCalendarEventsBetween(from, to)

    table.sort(events, function(a, b)
        return a.timestamp < b.timestamp
    end)

    --DevTools_Dump(events)

    for k, v in ipairs(events) do
        if type(v) == "table" then
            local label = string.format("|cffE5AC00%s|r\n%s", date("%Y-%m-%d %H:%M:%S", v.timestamp), v.text)
            local contextMenu = {
                {
                    text = DELETE,
                    notCheckable = true,
                    func = function ()
                        Database:DeleteCalendarEvent(v)
                    end
                },
        
            }
            -- table.insert(contextMenu, addon.contextMenuSeparator)

            table.insert(t, {
                label = label,
                onMouseDown = function(f, button)
                    if button == "RightButton" then
                        EasyMenu(contextMenu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                    end
                end
            })
        end
    end


    self.sidePanel.lockouts.scrollView:SetDataProvider(CreateDataProvider(t))
end


--local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
local lockoutKeys = {
    "Name",
    "ID",
    "Reset",
    "Difficulty",
    "Locked",
    "Extended",
    "instanceIDMostSig",
    "IsRaid",
    "MaxPlayers",
    "DifficultyName",
    "NumEncounters",
    "EncounterProgress",
}
function GuildbookCalendarMixin:UpdateLockouts()

    local instances = {};

    local t = {}
    local sortTable = {}

    if addon.characters then
        for nameRealm, character in pairs(addon.characters) do
            local lockouts = character:GetLockouts()
            for k, v in ipairs(lockouts) do
                local x = {}
                x.player = nameRealm
                for a, b in pairs(v) do
                    x[a] = b;
                end
                table.insert(sortTable, x)
            end
        end
    end

    table.sort(sortTable, function(a, b)
        if a.difficulty == b.difficulty then
            if a.name == b.name then
                return a.player < b.player
            else
                return a.name < b.name
            end
        else
            return a.difficulty > b.difficulty;
        end
    end)

    local inserted = {}
    for k, lockout in ipairs(sortTable) do
        if GetServerTime() < lockout.reset then

            local instanceName = lockout.name:lower():gsub("[%c%p%s]", "")
            local iconPath = "";
            local iconCoords = {0,1,0,1}

            local resetDate = date("*t", lockout.reset)

            --not ideal but dungeons and raids have different artwork
            if lockout.isRaid then
                iconPath = string.format("Interface/encounterjournal/ui-ej-dungeonbutton-%s", instanceName)
                iconCoords = {0.17578125, 0.49609375, 0.03125, 0.71875}         
            else
                iconPath = string.format("Interface/lfgframe/lfgicon-%s", instanceName)
            end

            local header = string.format("%s-%s", lockout.name, lockout.difficultyName)

            if not inserted[header] then

                table.insert(t, {
                    label = string.format("%s\n|cffE5AC00%s|r", lockout.name, lockout.difficultyName),
                    backgroundRGB = {r = 0.4, g = 0.4, b = 0.4,},
                    backgroundAlpha = 0.4,
                    icon = iconPath,
                    iconCoords = iconCoords,
                })
                inserted[header] = true;
            end

            table.insert(t, {
                label = string.format("%s\n|cffffffff%s|r", addon.characters[lockout.player]:GetName(true), date("%Y-%m-%d %H:%M:%S", lockout.reset)),
                -- atlas = addon.characters[player]:GetProfileAvatar(),
                -- showMask = true,
                onMouseEnter = function(f)
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(name)
                    for k, v in pairs(lockout) do
                        GameTooltip:AddDoubleLine("|cffffffff"..k.."|r", tostring(v))
                    end
                    GameTooltip:Show()

                    for i, day in ipairs(self.monthView.dayTiles) do
                        if day.date and (day.date.month == resetDate.month) and (day.date.day == resetDate.day) then
                            day.anim:Play()
                        end
                    end
                end,
                onMouseLeave = function()
                    for i, day in ipairs(self.monthView.dayTiles) do
                        day.anim:Stop()
                    end
                end
            })

        end
    end


    self.sidePanel.lockouts.scrollView:SetDataProvider(CreateDataProvider(t))
end

function GuildbookCalendarMixin:OnTabSelected(tab, index)

    if index == 1 then
        self:UpdateLockouts()
        
    elseif index == 2 then
        self:UpdateCalendarEvents()
    end
end

function GuildbookCalendarMixin:Blizzard_OnInitialGuildRosterScan()
    self.sidePanel.lockouts.background:SetAtlas("QuestLogBackground")
    --self.sidePanel.lockouts.background:SetAtlas(string.format("transmog-background-race-%s", addon.characters[addon.thisCharacter]:GetRace().clientFileString:lower()))
end

function GuildbookCalendarMixin:OnLoad()

    addon:RegisterCallback("Blizzard_OnInitialGuildRosterScan", self.Blizzard_OnInitialGuildRosterScan, self)
    addon:RegisterCallback("Database_OnCalendarDataChanged", self.MonthChanged, self)

    self.tabsGroup = CreateRadioButtonGroup();

	self.tabsGroup:AddButtons({self.sidePanel.tab1, self.sidePanel.tab2});
	self.tabsGroup:SelectAtIndex(1);
	self.tabsGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnTabSelected, self);

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
        f:SetJustifyH("CENTER")
        f:SetJustifyV("MIDDLE")
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

    --this appears to also update the default calendar, which is fine, the main thing is it means we can make use of calendar api using month offset
    C_Calendar.SetAbsMonth(self.date.month, self.date.year)

    self.sidePanel.monthName:SetText(date("%B %Y", time(self.date)))
    local monthStart = self:GetMonthStart(self.date.month, self.date.year)
    local daysInMonth = self:GetDaysInMonth(self.date.month, self.date.year)

    if self.sidePanel.tab1:IsSelected() then
        self:UpdateLockouts()
    else
        self:UpdateCalendarEvents()
    end

    local daysInLastMonth = 0
    if self.date.month == 1 then
        daysInLastMonth = self:GetDaysInMonth(12, self.date.year - 1)
    else
        daysInLastMonth = self:GetDaysInMonth(self.date.month - 1, self.date.year)
    end

    local thisMonthDay, nextMonthDay = 1, 1
    for i, day in ipairs(self.monthView.dayTiles) do
        day:SetScript("OnMouseDown", nil)
        day:ClearHolidayTextures()

        day.currentDayTexture:Hide()
        wipe(day.events)
        wipe(day.worldEvents)

        day:EnableMouse(false)
        day.dateLabel:SetText(' ')
        --day.worldEventTexture:SetTexture(nil)
        -- day.guildEventTexture:SetTexture(nil)
        local today = date("*t")
        if (thisMonthDay == today.day) and (self.date.month == today.month) then
            day.currentDayTexture:Show()
        end

        -- setup days in previous month
        if i < monthStart then
            day.dateLabel:SetText((daysInLastMonth - monthStart + 2) + (i - 1))
            day.dateLabel:SetTextColor(0.5, 0.5, 0.5, 1)
            day.otherMonthOverlay:Show()
            day.currentDayTexture:Hide()
        end

        -- setup current months days
        if i >= monthStart and thisMonthDay <= daysInMonth then
            day.dateLabel:SetText(thisMonthDay)
            day.dateLabel:SetTextColor(1,1,1,1)
            day.otherMonthOverlay:Hide()
            day:EnableMouse(true)
            day.date = {
                day = thisMonthDay,
                month = self.date.month,
                year = self.date.year,
            }


            --grab the events for the day and loop in reverse order, do this as it seems larger events (events spanning weeks not just a day) are indexed lower
            --so going reverse we add the small single day events first and use a low number for the subLayer
            for i = C_Calendar.GetNumDayEvents(0, thisMonthDay), 1, -1 do
                local event = C_Calendar.GetHolidayInfo(0, thisMonthDay, i)
                local subLayer = 1
                if event then
                    if not day.holidayTextures[i] then
                        day.holidayTextures[i] = day:CreateTexture(nil, "BORDER")
                        day.holidayTextures[i]:SetAllPoints()
                        day.holidayTextures[i]:SetTexCoord(0.0, 0.71, 0.0, 0.71)
                    end
                    day.holidayTextures[i]:SetDrawLayer("BORDER", subLayer)
                    day.holidayTextures[i]:SetTexture(event.texture)

                    table.insert(day.events, event)
                end
                subLayer = subLayer + 1;
            end
            
--[[
    calendar event types

    1 = birthday
    2 = note

]]
            local contextMenu = {
                {
                    text = date("%d %B %Y", time(day.date)),
                    isTitle = true,
                    notCheckable = true,
                    func = function()
        
                    end,
                },
                {
                    text = "Add Note",
                    notCheckable = true,
                    func = function()
                        StaticPopup_Show(
                            "GuildbookCalendarAddEvent", --popup name
                            string.format("Add note for %s", date("%d %B %Y", time(day.date))),
                            nil, --arg2 for %s
                            {
                                timestamp = time(day.date), --data
                                calendarTypeEnum = 2,
                            }
                        )
                    end,
                },
                {
                    text = "Add Birthday",
                    notCheckable = true,
                    func = function()
                        StaticPopup_Show(
                            "GuildbookCalendarAddEvent", --popup name
                            string.format("Add Birthday %s\n\nEnter players name:", date("%d %B %Y", time(day.date))),
                            nil, --arg2 for %s
                            {
                                timestamp = time(day.date), --data
                                calendarTypeEnum = 1,
                            }
                        )            
                    end,
                },
            }
            day:SetScript("OnMouseDown", function(f, b)
                if b == "RightButton" then
                    EasyMenu(contextMenu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                end
            end)

            thisMonthDay = thisMonthDay + 1
        end

        -- setup days in following month
        if i > (daysInMonth + (monthStart - 1)) then
            day.dateLabel:SetText(nextMonthDay)
            day.dateLabel:SetTextColor(0.5, 0.5, 0.5, 1)
            day.otherMonthOverlay:Show()
            day.currentDayTexture:Hide()

            for i = C_Calendar.GetNumDayEvents(1, nextMonthDay), 1, -1 do
                local event = C_Calendar.GetHolidayInfo(1, nextMonthDay, i)
                local subLayer = 1
                if event then
                    if not day.holidayTextures[i] then
                        day.holidayTextures[i] = day:CreateTexture(nil, "BORDER")
                        day.holidayTextures[i]:SetAllPoints()
                        day.holidayTextures[i]:SetTexCoord(0.0, 0.71, 0.0, 0.71)
                    end
                    day.holidayTextures[i]:SetDrawLayer("BORDER", subLayer)
                    day.holidayTextures[i]:SetTexture(event.texture)

                    table.insert(day.events, event)
                end
                subLayer = subLayer + 1;
            end

            nextMonthDay = nextMonthDay + 1
        end
    end
end
