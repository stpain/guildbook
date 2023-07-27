local name, addon = ...;

local Database = addon.Database;
local Character = addon.Character;
local Guild = {}

function Guild:New(name)
    local guild = {
        name = name,
        members = {},
        calendar = {
            activeEvents = {},
            deletedEvents ={},
        },
        banks = {},
    }
    return Mixin(guild, self)
end

function Guild:GetMembers()
    return self.members;
end

function Guild:GetCalendar()
    return self.calendar;
end

function Guild:GetBanks()
    return self.banks;
end

function Guild:AddBank(bank)
    self.banks[bank.name] = 0;
end

function Guild:SetCalendar(cal)
    self.calendar = cal;
end

function Guild:SetMembers(members)
    self.members = members;
end

function Guild:LoadCharactersFromDirectory()

    if self.members then
        for nameRealm, bool in pairs(self.members) do
            
        end
    end

end

addon.Guild = Guild;