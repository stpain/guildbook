local name, addon = ...;
local L = addon.Locales;

GuildbookGuildRosterMixin = {
    name = "GuildRoster",
    showOffline = false,
    showMyCharacters = false,
    selectedClass = false,
    selectedMinLevel = 1,
    selectedMaxLevel = 85,
    helptips = {},
}

function GuildbookGuildRosterMixin:OnLoad()

    addon:RegisterCallback("Blizzard_OnGuildRosterUpdate", self.Blizzard_OnGuildRosterUpdate, self)
    addon:RegisterCallback("Roster_OnSelectionChanged", self.Update, self)

    self.rosterHelptip:SetText(L.ROSTER_LISTVIEW_HT)
    table.insert(self.helptips, self.rosterHelptip)

    local classMenu = {}
    for i = 1, GetNumClasses() do
        --if i ~= 10 then
            local locale, eng, id = GetClassInfo(i)
            table.insert(classMenu, {
                text = RAID_CLASS_COLORS[eng]:WrapTextInColorCode(locale),
                sortID = locale,
                icon = nil,
                func = function()
                    self.selectedClass = id
                    self:Update()
                end,
            })
        --end
    end
    table.sort(classMenu, function (a, b)
        return a.sortID < b.sortID;
    end)
    table.insert(classMenu, 1, {
        text = ALL,
        icon = nil,
        func = function()
            self.selectedClass = false
            self:Update()
        end,
    })
    self.classFilter:SetMenu(classMenu);
    self.classFilter:SetText(ALL)

    local sliders = {
        ["Min level"] = "minLevel",
        ["Max level"] = "maxLevel",
    }

    for label, slider in pairs(sliders) do

        self[slider].label:SetText(label)

        _G[self[slider]:GetName().."Low"]:SetText(" ")
        _G[self[slider]:GetName().."High"]:SetText(" ")
        _G[self[slider]:GetName().."Text"]:SetText(" ")

        self[slider]:SetScript("OnMouseWheel", function(s, delta)
            s:SetValue(s:GetValue() + delta)
        end)
    end

    self.minLevel:SetMinMaxValues(self.selectedMinLevel, self.selectedMaxLevel)
    self.maxLevel:SetMinMaxValues(self.selectedMinLevel, self.selectedMaxLevel)

    self.minLevel:SetScript("OnValueChanged", function(s)
        s.value:SetText(math.ceil(s:GetValue()))
        self.selectedMinLevel = math.ceil(s:GetValue())
        self:Update()
    end)
    self.maxLevel:SetScript("OnValueChanged", function(s)
        s.value:SetText(math.ceil(s:GetValue()))
        self.selectedMaxLevel = math.ceil(s:GetValue())
        self:Update()
    end)


    self.showOfflineCheckbox.label:SetText("Show Offline")
    self.showOfflineCheckbox:SetScript("OnClick", function()
        self.showOffline = not self.showOffline;
        self:Update()
    end)

    self.showMyCharactersCheckbox.label:SetText("My Characters")
    self.showMyCharactersCheckbox:SetScript("OnClick", function()
        self.showMyCharacters = not self.showMyCharacters;
        self:Update()
    end)

    addon.AddView(self)
end

function GuildbookGuildRosterMixin:Update(classID, minLevel, maxLevel)

    -- local function filterRoster(key, val)
    --     return function(character)
    --         if character.data[key] then
    --             if character.data[key] == val then
    --                 return true;
    --             end
    --         end
    --     end
    -- end

    if classID then
        self.selectedClass = classID
    end
    if minLevel then
        self.selectedMinLevel = minLevel
    end
    if maxLevel then
        self.selectedMaxLevel = maxLevel
    end

    local t = {}
    for nameRealm, character in pairs(addon.characters) do

        --if Database.db.guilds[addon.thisGuild].members[nameRealm] then

        local match = false;
        -- for k, filter in ipairs(filters) do
        --     if not filter(character) then
        --         match = false;
        --     end
        -- end

        if self.showMyCharacters then
            if addon.api.characterIsMine(character.data.name) then
                match = true;
            end
        else
            if (character.data.level >= self.selectedMinLevel) and (character.data.level <= self.selectedMaxLevel) then
                if self.selectedClass and (character.data.class == self.selectedClass) then
                    if self.showOffline == false then
                        match = character.data.onlineStatus.isOnline
                    else
                        match = true
                    end
                elseif self.selectedClass == false then
                    if self.showOffline == false then
                        match = character.data.onlineStatus.isOnline
                    else
                        match = true
                    end
                end
            end
        end

        if match then
            table.insert(t, character)
        end
    end

    table.sort(t, function(a, b)
        if a.data.level == b.data.level then
            if a.data.onlineStatus.zone == b.data.onlineStatus.zone then
                return a.data.class < b.data.class
            else
                return a.data.onlineStatus.zone < b.data.onlineStatus.zone
            end
        else
            return a.data.level > b.data.level
        end
    end)

    local i = 0;
    for k, v in ipairs(t) do
        if (i % 2 == 0) then
            v.showBackground = true
        else
            v.showBackground = false
        end
        i = i + 1;
    end
    
    local dp = CreateDataProvider(t)
    self.rosterListview.scrollView:SetDataProvider(dp)

end

function GuildbookGuildRosterMixin:Blizzard_OnGuildRosterUpdate()
    self:Update()
end

function GuildbookGuildRosterMixin:OnShow()
    GuildRoster() --this will trigger a callback to self:Update
end