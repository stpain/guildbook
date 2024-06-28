

local addonName, addon = ...;

local Database = addon.Database;
local Character = addon.Character;
local Tradeskills = addon.Tradeskills;
local L = addon.Locales;

local gmotdNineSliceLayout =
{
    ["TopRightCorner"] = { atlas = "Tooltip-NineSlice-CornerTopRight" },
    ["TopLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerTopLeft" },
    ["BottomLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomLeft" },
    ["BottomRightCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomRight" },
    ["TopEdge"] = { atlas = "_Tooltip-NineSlice-EdgeTop" },
    ["BottomEdge"] = { atlas = "_Tooltip-NineSlice-EdgeBottom" },
    ["LeftEdge"] = { atlas = "!Tooltip-NineSlice-EdgeLeft" },
    ["RightEdge"] = { atlas = "!Tooltip-NineSlice-EdgeRight" },
    ["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-Glues-NineSlice-Center", x = -4, y = 4, x1 = 4, y1 = -4 },
}


local GUILD_MEMBERS = {}

GuildbookGuildManagementMixin = {
    name = "GuildManagement"
}

function GuildbookGuildManagementMixin:OnLoad()

    local tabs = {
        {
            label = "Edit Character",
            width = 120,
            panel = self.tabContainer.editCharacter,
        },
        {
            label = "Ranks",
            width = 120,
            panel = self.tabContainer.ranks,
        },
        {
            label = "Log",
            width = 120,
            panel = self.tabContainer.log,
        },
    }
    self.tabContainer:CreateTabButtons(tabs)
    
    self:SetupEditCharacterTab()

    self.tabContainer.editCharacter.header:SetText(L.EDIT_CHARACTER_HEADER)

    --addon:RegisterCallback("Blizzard_OnGuildRankUpdate", self.LoadLog, self)
    addon:RegisterCallback("Blizzard_OnGuildRosterUpdate", self.LoadLog, self)

    self.tabContainer.log.filterTypeValue = false
    self.tabContainer.log.searchBox:SetScript("OnTextChanged", function()
        self:LoadLog()
    end)
    self.tabContainer.log.filterType:SetMenu({
        {
            text = "All",
            func = function()
                self.tabContainer.log.filterTypeValue = false
                self:LoadLog()
            end
        },
        {
            text = "Invite",
            func = function()
                self.tabContainer.log.filterTypeValue = "invite"
                self:LoadLog()
            end
        },
        {
            text = "Joined",
            func = function()
                self.tabContainer.log.filterTypeValue = "join"
                self:LoadLog()
            end
        },
        {
            text = "Promte",
            func = function()
                self.tabContainer.log.filterTypeValue = "promote"
                self:LoadLog()
            end
        },
        {
            text = "Demote",
            func = function()
                self.tabContainer.log.filterTypeValue = "demote"
                self:LoadLog()
            end
        },
        {
            text = "Removed",
            func = function()
                self.tabContainer.log.filterTypeValue = "remove"
                self:LoadLog()
            end
        },
        {
            text = "Quit",
            func = function()
                self.tabContainer.log.filterTypeValue = "quit"
                self:LoadLog()
            end
        },
    })

    self.tabContainer.log.export:SetScript("OnClick", function()
        local csv = "";
        self.tabContainer.log.listview.scrollView:ForEachFrame(function(f)
            local csvType = f:GetElementData().csvType
            local csvPlayer1 = f:GetElementData().csvPlayer1
            local csvPlayer2 = f:GetElementData().csvPlayer2
            local csvTimestamp = f:GetElementData().csvTimestamp

            csv = string.format("%s%s,%s,%s,%d\n", csv, csvType, csvPlayer1, csvPlayer2, csvTimestamp)
        end)

        addon:TriggerEvent("SetExportString", csv)
    end)

    addon.AddView(self)
end

function GuildbookGuildManagementMixin:OnShow()

    -- self.characters:SetPoint("TOPLEFT", 0, -30)
    -- self.characters:SetPoint("BOTTOMLEFT", 0, 0)

    self.tabContainer:ClearAllPoints()
    self.tabContainer:SetPoint("TOPLEFT", 0, -60)
    self.tabContainer:SetPoint("BOTTOMRIGHT", 0, 0)

    self.tabContainer.editCharacter.characters:ClearAllPoints()
    self.tabContainer.editCharacter.characters:SetPoint("TOPLEFT", 0, 0)
    self.tabContainer.editCharacter.characters:SetPoint("BOTTOMLEFT", 0, 0)

    self.tabContainer.log.listview:ClearAllPoints()
    self.tabContainer.log.listview:SetPoint("TOPLEFT", 0, -30)
    self.tabContainer.log.listview:SetPoint("BOTTOMRIGHT", 0, 0)

    self:LoadCharacters(addon.thisGuild)

    self:LoadLog()
end

function GuildbookGuildManagementMixin:SetEditCharacterWidgetsLocked(locked)
    for k, widget in pairs(self.editCharacterControls) do
        if locked then
            widget:Disable()
        else
            widget:Enable()
        end
    end
end

function GuildbookGuildManagementMixin:SetupEditCharacterTab()

    local function setupTradeskillDowndown(widget, character, slot)
        
        widget:SetText("")

        widget:SetText(character:GetTradeskillName(slot))

        if character:GetTradeskill(slot) ~= "-" then
            widget:Disable()
        end

        local menu = {}
        for name, id in pairs(Tradeskills.PrimaryTradeskills) do
            table.insert(menu, {
                text = Tradeskills:GetLocaleNameFromID(id),
                func = function()
                    if character:GetTradeskill(slot) == "-" then
                        character:SetTradeskill(slot, id, true)
                    end
                end,
            })
        end
        table.sort(menu, function(a, b)
            return a.text < b.text
        end)
        widget:SetMenu(menu)
    end

    local function setupSpecializationDropdown(widget, character, slot)

        widget:SetText("")

        if slot == "primary" and (type(character.data.mainSpec) == "number") then
            local localeSpec, spec, id = character:GetSpec(slot)
            widget:SetText(localeSpec)
        end
        if slot == "secondary" and (type(character.data.offSpec) == "number") then
            widget:SetText(character:GetSpec(slot))
        end

        local menu = {}
        local classSpec = character:GetSpecializations()
        for k, spec in ipairs(classSpec) do
            table.insert(menu, {
                text = spec,
                func = function()
                    --Character:SetSpec(spec, specID, broadcast)
                    character:SetSpec(slot, k, true)
                end,
            })
        end
        table.sort(menu, function(a, b)
            return a.text < b.text
        end)
        widget:SetMenu(menu)
    end
    
    local fields = {
        {
            label = "Name",
            control = "InputBoxTemplate",
            field = "name",
            init = function(widget, character)
                widget:SetText(character.data.name)
                widget:Disable()
            end,
        },
        {
            label = "Class",
            control = "TbdDropdownTemplate",
            field = "class",
            init = function(widget, character)
                local classMenu = {}
                for i = 1, 12 do
                    local name, global, id = GetClassInfo(i)
                    if name then
                        table.insert(classMenu, {
                            text = name,
                            func = function()
                                widget:SetText(name)
                            end
                        })
                    end
                end
                widget:SetMenu(classMenu)
            end,
        },
        {
            label = "Race",
            control = "TbdDropdownTemplate",
            field = "race"
        },
        {
            label = "Gender",
            control = "TbdDropdownTemplate",
            field = "gender",
        },
        {
            label = "Level",
            control = "InputBoxTemplate",
            field = "level",
            init = function(widget, character)
                widget:SetText(character.data.level)
            end,
        },
        {
            label = "Main Character",
            control = "TbdDropdownTemplate",
            field = "mainCharacter",
            init = function(widget, character)
                local main = (type(character.data.mainCharacter) == "string") and character.data.mainCharacter or "None"
                widget:SetText(main)

                local menu = {}
                for _, name in ipairs(GUILD_MEMBERS) do
                    table.insert(menu, {
                        text = name,
                        func = function()
                            character:SetMainCharacter(name, true)
                        end,
                    })
                end
                table.sort(menu, function(a, b)
                    return a.text < b.text;
                end)
                table.insert(menu, 1, {
                    text = "None",
                    func = function()
                        character:SetMainCharacter(false, true)
                    end,
                })
                widget:SetMenu(menu)
            end,
        },
        {
            label = "Main Spec",
            control = "TbdDropdownTemplate",
            field = "mainSpec",
            init = function(widget, character)
                setupSpecializationDropdown(widget, character, "primary")
            end,
        },
        {
            label = "Off Spec",
            control = "TbdDropdownTemplate",
            field = "offSpec",
            init = function(widget, character)
                setupSpecializationDropdown(widget, character, "secondary")
            end,
        },
        {
            label = "Profession 1",
            control = "TbdDropdownTemplate",
            field = "profession1",
            init = function(widget, character)
                setupTradeskillDowndown(widget, character, 1)
            end,
        },
        {
            label = "Profession 2",
            control = "TbdDropdownTemplate",
            field = "profession2",
            init = function(widget, character)
                setupTradeskillDowndown(widget, character, 2)
            end,
        },
        {
            label = "Date Joined",
            control = "UIPanelButtonTemplate",
            field = "dateJoined",
            init = function(widget, character)

                local function updateTime(datetime)
                    widget:SetText(date("%Y-%m-%d", datetime))
                    character:SetDateJoined(datetime)
                end

                widget:SetScript("OnClick", function()
                    GuildbookDatePicker:ClearAllPoints()
                    GuildbookDatePicker:SetParent(widget)
                    GuildbookDatePicker:SetPoint("TOPLEFT", widget, "BOTTOMLEFT")
                    GuildbookDatePicker:SetCallback(updateTime)
                    GuildbookDatePicker:Show()
                end)
            end,
        },
        -- {
        --     label = "Rank",
        --     control = "TbdDropdownTemplate",
        --     field = "rank",
        --     init = function(widget, character)
        --         widget:SetText("")
        --         widget:SetText(GuildControlGetRankName(character.data.rank+1))

        --         local ranks = addon.api.getGuildRanks()

        --         local menu = {}
        --         for k, info in ipairs(ranks) do
        --             table.insert(menu, {
        --                 text = string.format("[%d] %s", info.rankIndex, info.rankName)
        --             })
        --         end

        --         widget:SetMenu(menu)
        --     end,
        -- }
    }

--GuildbookDatePicker

    local controlFrameTypes = {
        ["TbdDropdownTemplate"] = "Button",
        ["InputBoxTemplate"] = "EditBox",
        ["UIPanelButtonTemplate"] = "Button",
    }
    local controlframeSizes = {
        ["TbdDropdownTemplate"] = {220, 36, 0},
        ["InputBoxTemplate"] = {200, 24, 12},
        ["UIPanelButtonTemplate"] = {100, 22, 8},
    }

    local parent = self.tabContainer.editCharacter;
    local offsetX, offsetY = 212, -42;
    local rowHeight, labelWidth = 30, 120;

    self.editCharacterControls = {}

    for k, field in ipairs(fields) do
        
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", offsetX, ((k - 1) * -rowHeight) + offsetY)
        label:SetSize(labelWidth, rowHeight)
        label:SetText(field.label)
        label:SetJustifyH("LEFT")

        local control = CreateFrame(controlFrameTypes[field.control], nil, parent, field.control)
        control:SetPoint("LEFT", label, "RIGHT", controlframeSizes[field.control][3], 0)
        control:SetSize(controlframeSizes[field.control][1],controlframeSizes[field.control][2])
        control.init = field.init;


        if field.control == "InputBoxTemplate" then
            control:SetAutoFocus(false)
            control:ClearFocus()
        end

        self.editCharacterControls[field.field] = control;
    end

    -- local altsList = CreateFrame("Frame", nil, parent, "TBDListviewTemplate")
    -- altsList:SetPoint("TOPRIGHT", -12, -12)
    -- altsList.itemTemplate = "TBDSimpleIconLabelFrame";
    -- altsList.elementHeight = 24;

    NineSliceUtil.ApplyLayout(self.tabContainer.editCharacter.alts, gmotdNineSliceLayout)

    self.editCharacterControls["alts"] = self.tabContainer.editCharacter.alts;
    self.editCharacterControls["alts"].init = function(widget, character)

        local alts = {}
        for k, nameRealm in ipairs(character:GetAlts()) do

            if Database.db.characterDirectory[nameRealm] then
                if not addon.characters[nameRealm] then
                    addon.characters[nameRealm] = Character:CreateFromData(Database.db.characterDirectory[nameRealm])
                end

                table.insert(alts, {
                    label = addon.characters[nameRealm]:GetName(true, "short"),
                })

            end
        end
        widget.scrollView:SetDataProvider(CreateDataProvider(alts))
    end


end

function GuildbookGuildManagementMixin:SetCharacterToEdit(character)

    --some widgets control their enabled state from their init calls
    --safer to just check the rank here

    local ranks = addon.api.getGuildRanks()

    --guild ranks star with GM=0
    --the length of ranks will be correct for the numRanks
    --ranks[#ranks].rankIndex will be 1 lower as tables start from index 1 ranks start index 0

    --get the last rank from the table and test against its .rankIndex value

    local canEdit = false;
    if addon.thisCharacter and addon.characters[addon.thisCharacter] then
        if addon.characters[addon.thisCharacter].data.rank < ranks[#ranks-1].rankIndex then
            canEdit = true;
        end
    end


    for field, control in pairs(self.editCharacterControls) do
        if control.init then
            control.init(control, character)
        end
    end
end

function GuildbookGuildManagementMixin:LoadCharacters(guildName)

    local t = {}
    GUILD_MEMBERS = {}

    if addon.characters and Database.db and Database.db.guilds and Database.db.guilds[guildName] and Database.db.guilds[guildName].members then
        
        for nameRealm, _ in pairs(Database.db.guilds[guildName].members) do
            
            if not addon.characters[nameRealm] then
                if Database.db.characterDirectory[nameRealm] then
                    addon.characters[nameRealm] = Character:CreateFromData(Database.db.characterDirectory[nameRealm])
                end
            end

            if addon.characters[nameRealm] then
                table.insert(t, {
                    label = addon.characters[nameRealm]:GetName(true, "short"),

                    onMouseDown = function()
                        self:SetCharacterToEdit(addon.characters[nameRealm])
                    end,



                    --sort
                    sortName = nameRealm,
                })

                table.insert(GUILD_MEMBERS, nameRealm)
            end
        end
    end


    --this may grow into a proper listview sort compar func if we need to start removing characters etc
    table.sort(t, function(a, b)
        return a.sortName < b.sortName;
    end)

    self.tabContainer.editCharacter.characters.scrollView:SetDataProvider(CreateDataProvider(t))
end




local msgColours = {
    invite = CreateColor(88/255, 110/255, 139/255),
    join = CreateColor(44/255, 168/255, 61/255),
    promote = CreateColor(241/255,194/255,50/255),
    demote = CreateColor(241/255,98/255,50/255),
    remove = CreateColor(242/255,71/255,71/255),
    quit = CreateColor(17/255,199/255,199/255),
}

local os_time = time
local os_date = date
local os_difftime = difftime

-- Function to calculate the past date and time
local function calculate_past_time(years, months, days, hours)
    -- Get the current date and time
    local current_time = os_time()
    local current_date = os_date("*t", current_time)
    
    -- Subtract the given time intervals
    local past_date = {
        year = current_date.year - years,
        month = current_date.month - months,
        day = current_date.day - days,
        hour = current_date.hour - hours,
        min = current_date.min,
        sec = current_date.sec
    }

    -- Normalize the past date
    local past_time = os_time(past_date)

    -- Calculate the difference in seconds
    local difference_in_seconds = os_difftime(current_time, past_time)
    
    -- Convert seconds to hours
    
    return difference_in_seconds, past_time
end

-- local total_hours, past_time_string = calculate_past_time(years, months, days, hours)
-- print("Total hours:", total_hours) -- Output the total hours
-- print("Past time:", past_time_string) -- Output the past time as a formatted string

function GuildbookGuildManagementMixin:LoadLog()

    QueryGuildEventLog()

    local realm = GetNormalizedRealmName()

    local t = {}

    local searchTerm = self.tabContainer.log.searchBox:GetText():lower()
    
    for eventIndex = GetNumGuildEvents(), 1, -1 do

        --local now = date("*t")

        local isMatch = false;       
        local _type, player1, player2, rank, year, month, day, hour = GetGuildEventInfo(eventIndex);

        local difference_in_seconds, past_time = calculate_past_time(year, month, day, hour)

        if type(self.tabContainer.log.filterTypeValue) == "string" then
            if (_type == self.tabContainer.log.filterTypeValue) then
                isMatch = true
            end
        else
            isMatch = true
        end

        local player1match, player2match = false, false
        if (#searchTerm > 0) then

            if (type(player1) == "string") and player1:lower():find(searchTerm, nil, true) then
                player1match = true
            end
            if (type(player2) == "string") and player2:lower():find(searchTerm, nil, true) then
                player2match = true
            end
        end

        local addEvent = false

        if (#searchTerm > 0) then
            if (player1match or player2match) then
                if isMatch then
                    addEvent = true
                end
            end
        else
            if isMatch then
                addEvent = true
            end
        end

        if addEvent then
            --local now = date("*t")

            --[[
            local newDay, newMonth, newYear, msg

            if (now.month - month) < 1 then
                newMonth = (12 + (now.month - month))
            else
                newMonth = now.month - month;
            end
    
            newYear = now.year - year;
    
            if (now.day - day) < 1 then
                local daysInPreviousMonth = addon.api.getDaysInMonth(newMonth, newYear)
    
                newDay = (daysInPreviousMonth + (now.day - day))
                newMonth = (newMonth - 1)
            else
                newDay = now.day - day
            end
    
            if (now.hour - hour) < 1 then
                now.hour = (24 + (now.hour - hour))
    
                --if this causes us to go before midnight then check if the day was the first, if so fallback a month
                if now.day == 1 then
                    now.month = now.month - 1
                    local daysInPreviousMonth = addon.api.getDaysInMonth(now.month, newYear)
                    now.day = daysInPreviousMonth
    
                else
                    now.day = now.day - 1
                end
    
            else
                now.hour = now.hour - hour
            end
    
    
            now.year = newYear
            now.month = newMonth
            now.day = newDay

            ]]

            -- local main = "";

            -- if player1:find("-", nil, true) then
            --     if addon.characters[player1] then
            --         main = addon.characters[player1]:GetMainCharacter()
            --     end    
            -- else
            --     if addon.characters[string.format("%s-%s", player1, realm)] then
            --         main = addon.characters[string.format("%s-%s", player1, realm)]:GetMainCharacter()
            --     end  
            -- end

            -- if main then
            --     player1 = string.format("%s [%s]", player1, main)
            -- end
    
            --taken from blizz
            if ( not player1 ) then
                player1 = UNKNOWN;
            end
            if ( not player2 ) then
                player2 = UNKNOWN;
            end
            if ( _type == "invite" ) then
                msg = format(GUILDEVENT_TYPE_INVITE, player1, player2);
            elseif ( _type == "join" ) then
                msg = format(GUILDEVENT_TYPE_JOIN, player1);
            elseif ( _type == "promote" ) then
                msg = format(GUILDEVENT_TYPE_PROMOTE, player1, player2, rank);
            elseif ( _type == "demote" ) then
                msg = format(GUILDEVENT_TYPE_DEMOTE, player1, player2, rank);
            elseif ( _type == "remove" ) then
                msg = format(GUILDEVENT_TYPE_REMOVE, player1, player2);
            elseif ( _type == "quit" ) then
                msg = format(GUILDEVENT_TYPE_QUIT, player1);
            end
    
            --DevTools_Dump({index = i, date = now})
            local msg = string.format("[%s] %s", date("%c", past_time), msg)
    
            msg = msg:gsub(":%d%d ", " ")
    
            table.insert(t, {
                label = msgColours[_type]:WrapTextInColorCode(msg),

                csvType = _type,
                csvPlayer1 = player1,
                csvPlayer2 = player2,
                csvTimestamp = past_time,
            })
        end

    end

    self.tabContainer.log.listview.scrollView:SetDataProvider(CreateDataProvider(t))
end