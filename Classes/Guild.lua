local addonName, addon = ...;

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

    if Database and Database.db and Database.db.guilds[name] and Database.db.guilds[name].members and Database.db.characterDirectory then
        for nameRealm, _ in pairs(Database.db.guilds[name].members) do
            if Database.db.characterDirectory[nameRealm] then
                guild.members[nameRealm] = Character:New(Database.db.characterDirectory[nameRealm])
            end
        end
    end



    return Mixin(guild, self)
end

function Guild:LogRecruitment(msg)
    
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



addon.Guild = Guild;