

local name, addon = ...;

local Database = addon.Database;
local Character = addon.Character;

GuildbookAltsMixin = {
    name = "Alts",
    alts = {},
}

function GuildbookAltsMixin:OnLoad()
    addon.AddView(self)

    addon:RegisterCallback("Database_OnInitialised", self.LoadAlts, self)
    addon:RegisterCallback("Database_OnCharacterRemoved", self.LoadAlts, self)
end

function GuildbookAltsMixin:OnShow()
    self:LoadAlts()
end

function GuildbookAltsMixin:LoadAlts()

    self.alts = {}

    for name, isMain in pairs(Database.db.myCharacters) do

        if Database.db.characterDirectory[name] then
        
            local alt = Character:CreateFromData(Database.db.characterDirectory[name])

            table.insert(self.alts, alt)

        end
    end

    table.sort(self.alts, function(a, b)
        if a.data.level == b.data.level then
            if a.data.class == b.data.class then
                return a.data.name < b.data.name
            else
                return a.data.class < b.data.class
            end
        else
            return a.data.level > b.data.level;
        end
    end)

    self.listview.scrollView:SetDataProvider(CreateDataProvider(self.alts))

    collectgarbage()
end