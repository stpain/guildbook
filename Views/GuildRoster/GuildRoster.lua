local name, addon = ...;
local L = addon.Locales;

GuildbookGuildRosterMixin = {
    name = "GuildRoster",
    showOffline = false,
    selectedClass = false,
    selectedMinLevel = 1,
    selectedMaxLevel = 80,
    helptips = {},
}

function GuildbookGuildRosterMixin:OnLoad()

    addon:RegisterCallback("Blizzard_OnGuildRosterUpdate", self.Blizzard_OnGuildRosterUpdate, self)

    self.rosterHelptip:SetText(L.ROSTER_LISTVIEW_HT)
    table.insert(self.helptips, self.rosterHelptip)

    local classMenu = {}
    for i = 1, GetNumClasses() do
        if i ~= 10 then
            local locale, eng, id = GetClassInfo(i)
            table.insert(classMenu, {
                text = locale,
                icon = nil,
                func = function()
                    self.selectedClass = id
                    self:Update()
                end,
            })
        end
    end
    table.insert(classMenu, {
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

    addon.AddView(self)
end

function GuildbookGuildRosterMixin:Update()

    --these filters seemed to cause lag on the UI so just checking data directly instead

    -- local function generateClassFilter()
    --     return function(character)
    --         if self.selectedClass then
    --             if character.data.class == self.selectedClass then
    --                 return true
    --             end
    --         else
    --             return true
    --         end
    --     end
    -- end
    -- local function generateLevelFilter()
    --     return function(character)
    --         if (character.data.level >= self.selectedMinLevel) and (character.data.level <= self.selectedMaxLevel) then
    --             return true
    --         end
    --     end
    -- end

    -- local filters = {
    --     generateClassFilter(),
    --     generateLevelFilter(),
    -- }

    local t = {}
    for nameRealm, character in pairs(addon.characters) do

        --if Database.db.guilds[addon.thisGuild].members[nameRealm] then

        local match = false;
        -- for k, filter in ipairs(filters) do
        --     if not filter(character) then
        --         match = false;
        --     end
        -- end
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

        if match then
            table.insert(t, character)
        end
    end

    table.sort(t, function(a, b)
        if a.data.level == b.data.level then
            if a.data.class == b.data.class then
                return a.data.name < b.data.name
            else
                return a.data.class < b.data.class
            end
        else
            return a.data.level > b.data.level
        end
    end)

    
    local dp = CreateDataProvider(t)
    self.rosterListview.scrollView:SetDataProvider(dp)
end

function GuildbookGuildRosterMixin:Blizzard_OnGuildRosterUpdate()
    self:Update()
end

function GuildbookGuildRosterMixin:OnShow()
    GuildRoster() --this will trigger a callback to self:Update

    --self:Update()
end