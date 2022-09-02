

local name, addon = ...;

local Database = addon.Database;
local Character = addon.Character;

local Guild = {};


function Guild:IsCurrentGuild()
    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player');
        if self.data.name == guildName then
            return true, self.data.name;
        end
    end
    return false;
end


function Guild:FetchOnlineStatus()

    -- self.data.onlineStatus = {};

    -- if self:IsCurrentGuild() then
    --     local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
    --     for i = 1, numTotalGuildMembers do
    --         local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
    --         if guid then
    --             self.data.onlineStatus[guid] = {
    --                 isOnline = isOnline,
    --                 zone = zone,
    --             }
    --             self.data.members[guid]:SetOnlineStatus({
    --                 isOnline = isOnline,
    --                 zone = zone,
    --             })
    --         end
    --     end
    -- end
end


function Guild:IsMemberOnline(guid)

    if self.data.onlineStatus[guid] then
        return self.data.onlineStatus[guid].isOnline;
    end
end

function Guild:NewGuild(name)

    if Database:GuildExists() == false then
        Database:CreateNewGuildRosterCache(name)
    end

    return Mixin({
        data = {
            name = name,
            members = {},
            onlineStatus = {},
        }
    }, self)

end


function Guild:GetName()
    return self.data.name;
end


function Guild:WipeAllCharacterData()

    if not self.data.name then
        return;
    end

    self.data.members = {}
    self.data.onlineStatus = {}

end

--scan the guild roster to get member data
function Guild:ScanGuildRoster()

    addon.DEBUG("func", "Guild:ScanGuildRoster", "scanning current guild roster")

    --lets make sure we only update the current guild data
    if self:IsCurrentGuild() then
        local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
        for i = 1, numTotalGuildMembers do
            local nameRealm, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            if guid and guid:find("Player-") then

                local name = Ambiguate(nameRealm, "none")
                local _, _, _, race, gender, _, _ = GetPlayerInfoByGUID(guid)
                gender = (gender == 3) and "FEMALE" or "MALE"

                --if this member exists then lets just update the basic data
                --this covers us if the player uses the gender change feature, levels up, uses a race change (might get added)
                --if the public note is changed and also updates the oline status
                if self.data.members[guid] then
                    
                    local character = self:GetCharacter(guid);
                    character:SetGuid(guid) --if the character was reset we need to have this added back
                    character:SetName(name);
                    character:SetLevel(level);
                    character:SetClass(class);
                    character:SetRace(race);
                    character:SetGender(gender);
                    character:SetPublicNote(publicNote);
                    character:SetOnlineStatus({
                        isOnline = isOnline,
                        zone = zone,
                    });

                    --addon.DEBUG("func", "Guild:ScanGuildRoster", string.format("updated character object for %s", nameRealm), character:GetData())
                    
                --if this is a new character then create a new character object and set the basic data
                else
                    local character = Character:New();
                    character:SetGuid(guid);
                    character:SetName(name);
                    character:SetClass(class);
                    character:SetLevel(level);
                    character:SetRace(race);
                    character:SetGender(gender);
                    character:SetPublicNote(publicNote);
                    character:SetOnlineStatus({
                        isOnline = isOnline,
                        zone = zone,
                    });

                    self.data.members[guid] = character;

                    --addon.DEBUG("func", "Guild:ScanGuildRoster", string.format("added new character object for %s", nameRealm), character:GetData())
                end

                --update the saved variables
                --self:UpdateSavedVariablesForCharacter(guid);
            end
        end
        --might be better to update all at this point as we scanned the whole roster
        self:UpdateSavedVariables()
    end

    addon:TriggerEvent("OnGuildRosterScanned", self)
end

function Guild:LoadCharactersFromSavedVars()

    if not self.data.name then
        return;
    end

    addon.DEBUG("func", "Guild:LoadCharactersFromSavedVars", string.format("loading character data from saved vars for %s", self.data.name))

    local cache = Database:GetGuildRosterCache(self.data.name)
    for guid, info in pairs(cache) do
        if not self.data.members[guid] then
            self.data.members[guid] = Character:CreateFromData(guid, info)

        else
            self.data.members[guid]:SetData(info)
        end
    end

end

function Guild:UpdateSavedVariables()

    if not self.data.name then
        return;
    end

    local t = {};

    addon.DEBUG("func", "Guild:UpdateSavedVariables", string.format("updating saved variables for %s", self.data.name))
    for guid, character in pairs(self.data.members) do
        t[guid] = character:GetData();
    end

    Database:SetGuildRosterCache(self.data.name, t)
end

function Guild:UpdateSavedVariablesForCharacter(guid)

    if not self.data.name then
        return;
    end

    for _guid, character in pairs(self.data.members) do
        if _guid == guid then
            Database:SetGuildMemberData(self.data.name, guid, character:GetData())
        end
    end

end


function Guild:GetPlayerCharacter()

    if self.data.members[UnitGUID("player")] then
        return self.data.members[UnitGUID("player")];
    end
    return false;

end



function Guild:GetCharacter(guid)
    if self.data.members[guid] then
        return self.data.members[guid];
    end
    return false;
end


function Guild:GetClassCounts()
    
    if not self.data.name then
        return;
    end

    local t = {};
    local total = 0;
    for guid, character in pairs(self.data.members) do
        if not t[character:GetClass()] then
            t[character:GetClass()] = 1;

        else
            t[character:GetClass()] = t[character:GetClass()] + 1;
        end
        total = total + 1;
    end

    local classInfo = {};
    for class, count in pairs(t) do
        table.insert(classInfo, {
            class = class,
            count = count,
        })
    end

    table.sort(classInfo, function(a, b)
        return a.count > b.count;
    end)

    return classInfo, total;
end


function Guild:GetCharacters(sort, desc)

    if not self.data.name then
        return;
    end

    local t = {};

    if type(sort) == "string" then

        local sortASC = function(a, b)
            if a[sort] == b[sort] then
                return a.data.name < b.data.name;

            else
                return a.data[sort] < b.data[sort];

            end
        end

        local sortDESC = function(a, b)
            if a[sort] == b[sort] then
                return a.data.name > b.data.name;

            else
                return a.data[sort] > b.data[sort];

            end
        end

        for guid, character in pairs(self.data.members) do
            table.insert(t, character)
        end
        
        if desc then
            table.sort(t, sortDESC)
        else
            table.sort(t, sortASC)
        end

    end

    local k = 0;
    return function()
        k = k + 1;
        if k <= #t then
            return k, t[k];
        end
    end

end

function Guild:FindCharactersWithRecipe(item)

    if not self.data.name then
        return;
    end

    local t = {};
    for guid, character in pairs(self.data.members) do
        if character:CanCraftItem(item) then
            table.insert(t, character)
        end
    end

    return t;

end

addon.Guild = Guild;