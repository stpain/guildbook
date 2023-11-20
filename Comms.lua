--[[
    Comms:
        The Comms class is used to send and receive data on the GUILD channel and WHISPER channel

        There is a queue system to prevent the addon spamming chat channels and disrupting other addon communications.
        The queue is simple, messages get added to the queue and are held for n number of seconds, during this time
        and new data of the same message type will cause the currently queued message to be updated rather than a new
        message added to the queue.
        Once a message dispatch time arrives the message will be sent and the remaining queued messages will have their
        dispatch time increased by n seconds. This means the addon will only send a message once every n seconds, and 
        where cases exists that a message might be spammed, it'll be caught by the initial delay.

        The guild bank messages ignore the queue and mostly use the WHISPER channel.
]]

local name, addon = ...;

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")
local Database = addon.Database;
local Character = addon.Character;

local Comms = {
    prefix = "Guildbook", --name var was to long
    version = 1,

    --delay from transmit request to first dispatch attempt, this prevents spamming if a player opens/closes a panel that triggers a transmit
    queueWaitingTime = 2.0,
    --the time added to each message waiting in the queue, this limits how often a message can be dispatched
    queueExtendTime = 2.0,

     --limiter effect for the dispatcher onUpdate func, limits the onUpdate to once per second
    dispatcherElapsedDelay = 1.0,
    
    queue = {},
    dispatcher = CreateFrame("FRAME"),
    dispatcherElapsed = 0,
    paused = false,
};


--this table should contain only the character.data[key] keys which we want to send
--[[
    for example, when the characters mainSpec changes, the character obj will notify to broadcast
    then this table will be checked for the key 'mainSpec' and its value passed on as an EVENT flag for the data payload
]]
Comms.characterKeyToEventName = {
    --containers = "CONTAINERS_TRANSMIT", --for guild banks -REMOVED THIS SYSTEM
    inventory = "INVENTORY_TRANSMIT",
    paperDollStats = "PAPERDOLL_STATS_TRANSMIT",
    talents = "TALENT_TRANSMIT",
    glyphs = "GLYPH_TRANSMIT",
    resistances = "RESISTANCE_TRANSMIT",
    auras = "AURA_TRANSMIT",
    -- alts = self.data.alts,
    -- mainCharacter = self.data.mainCharacter,
    -- publicNote = self.data.publicNote,
    mainSpec = "SPEC_TRANSMIT",
    -- offSpec = self.data.offSpec,
    -- mainSpecIsPvP = self.data.mainSpecIsPvP,
    -- offSpecIsPvP = self.data.offSpecIsPvP,
    profession1 = "TRADESKILL_TRANSMIT_PROF1",
    profession1Level = "TRADESKILL_TRANSMIT_PROF1_LEVEL",
    profession1Spec = "TRADESKILL_TRANSMIT_PROF1_SPEC",
    profession1Recipes = "TRADESKILL_TRANSMIT_PROF1_RECIPES",
    profession2 = "TRADESKILL_TRANSMIT_PROF2",
    profession2Level = "TRADESKILL_TRANSMIT_PROF2_LEVEL",
    profession2Spec = "TRADESKILL_TRANSMIT_PROF2_SPEC",
    profession2Recipes = "TRADESKILL_TRANSMIT_PROF2_RECIPES",
    cookingLevel = "TRADESKILL_TRANSMIT_COOKING_LEVEL",
    cookingRecipes = "TRADESKILL_TRANSMIT_COOKING_RECIPES",
    fishingLevel = "TRADESKILL_TRANSMIT_FISHING_LEVEL",
    firstAidLevel = "TRADESKILL_TRANSMIT_FIRSTAID_LEVEL",
    firstAidRecipes = "TRADESKILL_TRANSMIT_FIRSTAID_RECIPES",

    --CurrentInventory = self.data.currentInventory,
    --CurrentPaperdollStats = self.data.currentPaperdollStats or {},

}
Comms.messageEventToCharacterKey = {}
for k, v in pairs(Comms.characterKeyToEventName) do
    Comms.messageEventToCharacterKey[v] = k
end


function Comms:Init()
    
    AceComm:Embed(self);
    self:RegisterComm(self.prefix);

    self.version = tonumber(GetAddOnMetadata(name, "Version"));

    self.dispatcher:SetScript("OnUpdate", Comms.DispatcherOnUpdate)

    addon:TriggerEvent("StatusText_OnChanged", "[Comms:Init]")
    addon:RegisterCallback("Player_Regen_Enabled", self.Player_Regen_Enabled, self)
    addon:RegisterCallback("Player_Regen_Disabled", self.Player_Regen_Disabled, self)
end

--pause comms during combat
--this setup doesn't affect guild bank and non queue comms, however checking the banks wouuld likely be done in a city or rested area
function Comms:Player_Regen_Enabled()
    self.paused = false;
end

function Comms:Player_Regen_Disabled()
    self.paused = true;
end

---the purpose of this function is to check the queued mesages once per second and take action
---if there is a message and its dispatch time has been reached then push the message, then update remaining messages to dispatch at n secon intervals
---if the queue is empty remove the onUpdate script
---@param self frame the dispatch frame
---@param elapsed number elapsed since last OnUpdate
function Comms.DispatcherOnUpdate(self, elapsed)

    if Comms.paused then
        return;
    end

    Comms.dispatcherElapsed = Comms.dispatcherElapsed + elapsed;

    if Comms.dispatcherElapsed < Comms.dispatcherElapsedDelay then
        return;
    else
        Comms.dispatcherElapsed = 0;
    end

    if #Comms.queue == 0 then
        self:SetScript("OnUpdate", nil)
    else

        local now = time();

        --grab the message from the queue
        local message = Comms.queue[1];

        --if the message is due to go push it
        if message.dispatchTime < now then

            if not message.payload.version then
                message.payload.version = Comms.version;
            end

            local serialized = LibSerialize:Serialize(message.payload);
            local compressed = LibDeflate:CompressDeflate(serialized);
            local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);

            Comms:SendCommMessage(Comms.prefix, encoded, message.channel, message.target, "NORMAL")
            addon.LogDebugMessage("comms_out", string.format("sending message [|cffE7B007%s|r] on channel [%s]", message.event, message.channel))

            --set remaining messages to dispatch in 'n' second intervals
            for i = 2, #Comms.queue do
                Comms.queue[i].dispatchTime = now + ((i - 1) * Comms.queueExtendTime)
                addon.LogDebugMessage("comms", string.format("updated dispatch time for [|cffE7B007%s|r] will dispatch at %s", Comms.queue[i].event, date("%T", Comms.queue[i].dispatchTime)))
            end

            --remove the message
            table.remove(Comms.queue, 1)
            if #Comms.queue == 0 then
                self:SetScript("OnUpdate", nil)
                addon.LogDebugMessage("comms", "Queue is empty, removed OnUpdate script")
            else
                addon.LogDebugMessage("comms", string.format("%d messages left in queue", #Comms.queue))
            end
        end
    end

end


-- local inInstance, instanceType = IsInInstance()
-- if instanceType ~= "none" then
--     local blockCommsDuringInstance = Database:GetConfigSetting("blockCommsDuringInstance");
--     if blockCommsDuringInstance == true then
--         addon:TriggerEvent("OnCommsBlocked", "blocked comms during instance")
--         return;
--     end
-- end
-- local inLockdown = InCombatLockdown()
-- if inLockdown then
--     local blockCommsDuringCombat = Database:GetConfigSetting("blockCommsDuringCombat");
--     if blockCommsDuringCombat == true then
--         addon:TriggerEvent("OnCommsBlocked", "blocked comms during combat")
--         return;
--     end
-- end

---the purpose of this queue function is to provide some relief to the addon comms channel
---if a message with the same type is queued more than once within a period of time (a waiting room if you like)
---the data of the message is kept and then sent after a timer.
---the timer delay is determined by the previous timer to keep messages spaced out
function Comms:QueueMessage(event, message, channel, target)

    local exists = false;
    for k, v in ipairs(self.queue) do
        --if (v.event == event) and (v.payload.method == message.payload.method) and (v.payload.subKey == message.payload.subKey) then
        if (v.event == event) then
            exists = true;
            v.payload = message
            addon.LogDebugMessage("comms", string.format("updated message payload for [|cffE7B007%s|r]", event))
        end
    end

    local dispatchTime = time() + self.queueWaitingTime
    if exists == false then
        table.insert(self.queue, {
            event = event,
            payload = message,
            channel = channel,
            target = target,
            dispatchTime = dispatchTime;
        })

        addon.LogDebugMessage("comms", string.format("queued [|cffE7B007%s|r] dispatch time %s", event, date("%T", dispatchTime)))
    end

    if self.dispatcher:GetScript("OnUpdate") == nil then
        self.dispatcher:SetScript("OnUpdate", self.DispatcherOnUpdate)
    end
end


function Comms:TransmitToTarget(event, data, method, subKey, target)
    local msg = {
        event = event,
        version = Comms.version,
        payload = {
            method = method, --the character:method
            subKey = subKey, --a subkey if used
            data = data, --the value being sent
        },
    }
    Comms:QueueMessage(msg.event, msg, "WHISPER", target)
end

function Comms:TransmitToGuild(event, data, method, subKey, nameRealm)
    local msg = {
        event = event,
        version = Comms.version,
        payload = {
            method = method,
            subKey = subKey,
            data = data,
            nameRealm = nameRealm,
        },
    }
    Comms:QueueMessage(msg.event, msg, "GUILD", nil)
end
function Comms:TransmitToGuild_New(nameRealm, method, key, subKey, data)
    local msg = {
        event = self.characterKeyToEventName[key],
        version = Comms.version,
        payload = {
            method = method,
            key = key,
            subKey = subKey,
            data = data,
            nameRealm = nameRealm,
        },
    }
    Comms:QueueMessage(msg.event, msg, "GUILD", nil)
end

function Comms:Transmit_NoQueue(msg, channel, target)
    local serialized = LibSerialize:Serialize(msg);
    local compressed = LibDeflate:CompressDeflate(serialized);
    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    self:SendCommMessage(self.prefix, encoded, channel, target, "NORMAL")
    addon.LogDebugMessage("comms_out", string.format("No queue message [%s] to %s", (msg.event or "-"), (target or "-")))
end

function Comms:OnCommReceived(prefix, message, distribution, sender)

    if prefix ~= self.prefix then 
        return 
    end
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message);
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

    --print(sender, data.version)

    if data.version and (data.version >= self.version) then
        if Comms.events[data.event] then
            addon:TriggerEvent("StatusText_OnChanged", string.format("received [|cffE7B007%s|r] from %s", data.event, sender))
            Comms.events[data.event](Comms, sender, data)
            addon.LogDebugMessage("comms_in", string.format("[|cffE7B007%s|r] data incoming from %s", data.event, sender), data)
        end
    else
        --DevTools_Dump(data)
    end
end


function Comms:Character_OnDataReceived(sender, message)

    local nameRealm;
    if message.payload.nameRealm and message.payload.nameRealm:find("Player-") then
        nameRealm = message.payload.nameRealm
    else
        if not sender:find("-") then
            local realm = GetNormalizedRealmName()
            sender = string.format("%s-%s", sender, realm)
        end
        nameRealm = sender;
    end


    if not addon.characters[nameRealm] then
        if Database.db.characterDirectory[nameRealm] then
            addon.characters[nameRealm] = Character:CreateFromData(Database.db.characterDirectory[nameRealm])
        end
    end
    local character = addon.characters[nameRealm]


    -- if message.event == "TRADESKILL_TRANSMIT_PROF1" then
    --     print("Dumping payload")
    --     DevTools_Dump({message.payload})
    -- end

    --the version check should prevent issues but worth checking for this
    if message.payload.key then
        if character and character[message.payload.method] then
            --print("calling method", message.payload.method)
            if message.payload.subKey then
                -- print("using subKey value", message.payload.key, message.payload.subKey)
                -- DevTools_Dump({message.payload.data})
                character.data[message.payload.key][message.payload.subKey] = message.payload.data
            else
                -- print("using key value", message.payload.key)
                -- DevTools_Dump({message.payload.data})
                character.data[message.payload.key] = message.payload.data
            end
            addon:TriggerEvent("Character_OnDataChanged", character)
        end
    end
end


--Comms will be notified when character data changes
--check its the clients character and proceed with sending data
function Comms:Character_BroadcastChange(character, ...)

    --DevTools_Dump({...})

    if addon.thisCharacter and (character.data.name == addon.thisCharacter) then

        --[[
            the character object comms is a little like an extension of the callback system btu works across the chat channels
            example use:

                -the character object will fire this event with the following args (string method, string key, var subKey)
                    addon:TriggerEvent("Character_BroadcastChange", self, "SetAuras", "auras", info)

                -comms will use those args on the receiving end with the correct character object
                    Character[method](subKey, key, info)
                    Character[method](key, info)

                in this example 
                SetAuras is a method of the character class/object
                auras is the key (this is the object.data.auras)
                info is the actual aura info
        ]]

        --doing things this way adds addition text to the message but greatly simplifies the addon code required
        --the addon will take the method sent if it exists rather than having to hard code message.event > character.method (although this could be better as time goes on)
        local method, key, subKey = ...;

        if self.characterKeyToEventName[key] then

            local data;
            if subKey then
                data = character.data[key][subKey]
            else
                data = character.data[key]
            end

            if data then
                if method == "SetTradeskill" then
                    --print("setting tradeskill", key, data)
                end
                --self:TransmitToGuild(self.characterKeyToEventName[key], data, method, subKey, character.data.name)
                self:TransmitToGuild_New(character.data.name, method, key, subKey, data)
                Database:SetCharacterSyncData(key, time())
                --print("setting sync time for", key)
                addon.LogDebugMessage("comms", string.format("Character_OnDataChanged > %s has changed, sending to comms queue", key))
            else
                addon.LogDebugMessage("comms", string.format("no data found in character.data[%s]", key))
            end

        end

    end
    
end


function Comms:Guildbank_TimeStampRequest(bank)
    local msg = {
        event = "GUILDBANK_TIMESTAMPS_REQUEST",
        version = self.version,
        payload = {
            bank = bank,
        }
    }
    self:Transmit_NoQueue(msg, "GUILD", nil) --this goes out to everyone, data replies use whisper channel
end

function Comms:Guildbank_OnTimestampsRequested(sender, message)

    local transmit = false;

    if not sender:find("-") then
        local realm = GetNormalizedRealmName()
        sender = string.format("%s-%s", sender, realm)
    end

    --see if this sender has access to any banks
    if addon.guilds and addon.guilds[addon.thisGuild] and addon.guilds[addon.thisGuild].banks[message.payload.bank] and addon.guilds[addon.thisGuild].bankRules[message.payload.bank] then
        if addon.guilds[addon.thisGuild].bankRules[message.payload.bank].shareBags or addon.guilds[addon.thisGuild].bankRules[message.payload.bank].shareBank then
            --DevTools_Dump(addon.characters[sender])
            if addon.characters[sender] and addon.characters[sender].data.rank then
                if addon.characters[sender].data.rank <= addon.guilds[addon.thisGuild].bankRules[message.payload.bank].shareRank then
                    transmit = true;
                end
            end
        end
    end

    --
    if transmit == true then
        local msg = {
            event = "GUILDBANK_TIMESTAMPS_TRANSMIT",
            version = self.version,
            payload = addon.guilds[addon.thisGuild].banks,
        }
        self:Transmit_NoQueue(msg, "WHISPER", sender)
    end
end

function Comms:Guildbank_OnTimestampsReceived(sender, message)
    addon:TriggerEvent("Guildbank_OnTimestampsReceived", sender, message)
end

function Comms:Guildbank_DataRequest(target, bank)
    local msg = {
        event = "GUILDBANK_DATA_REQUEST",
        version = self.version,
        payload = {
            bank = bank,
        }
    }
    self:Transmit_NoQueue(msg, "WHISPER", target)
end

function Comms:Guildbank_OnDataRequested(sender, message)

    if not sender:find("-") then
        local realm = GetNormalizedRealmName()
        sender = string.format("%s-%s", sender, realm)
    end

    if addon.characters and addon.characters[message.payload.bank] then

        local containers = {
            copper = 0,
            bags = {},
            bank = {},
        }

        --check if sharing gold as this could be different from items
        if addon.guilds[addon.thisGuild].bankRules[message.payload.bank].shareCopper then
            containers.copper = addon.characters[message.payload.bank].data.containers.copper
        end
        if addon.guilds[addon.thisGuild].bankRules[message.payload.bank].shareBags then
            containers.bags = addon.characters[message.payload.bank].data.containers.bags
        end
        if addon.guilds[addon.thisGuild].bankRules[message.payload.bank].shareBank then
            containers.bank = addon.characters[message.payload.bank].data.containers.bank
        end

        local msg = {
            event = "GUILDBANK_DATA_TRANSMIT",
            version = self.version,
            payload = {
                bank = message.payload.bank,
                containers = containers
            }
        }
        self:Transmit_NoQueue(msg, "WHISPER", sender)
    end
end

function Comms:Guildbank_OnDataReceived(sender, message)
    addon:TriggerEvent("Guildbank_OnDataReceived", sender, message)
end




function Comms:RequestCharacterData(nameRealm, data)
    
    if addon.characters[nameRealm] then
        if addon.characters[nameRealm].data.onlineStatus.isOnline then
            local msg = {
                event = "CHARACTER_DATA_REQUEST",
                version = self.version,
                payload = {
                    requestData = data,
                    target = nameRealm,
                }
            }
            local name = Ambiguate(nameRealm, "full")
            self:Transmit_NoQueue(msg, "WHISPER", name)
            addon.LogDebugMessage("comms", string.format("Sent data request to %s", name))
            addon:TriggerEvent("StatusText_OnChanged", string.format("Sent data request to %s", name))
        end
    end
end

function Comms:Character_OnDataRequest(sender, message)

    addon.LogDebugMessage("comms", string.format("Data request from %s", sender))
    addon:TriggerEvent("StatusText_OnChanged", string.format("Data request from %s", sender))

    if message and message.payload then

        if message.payload.requestData and message.payload.requestData:find(".") then
            
            local key, subKey = strsplit(".", message.payload.requestData)
            if type(key) == "string" and type(subKey) == "string" then
                if addon.characters[addon.thisCharacter] and addon.characters[addon.thisCharacter].data[key] and addon.characters[addon.thisCharacter].data[key][subKey] then
                    
                    local msg = {
                        event = "CHARACTER_DATA_RESPONSE",
                        version = self.version,
                        payload = {
                            target = message.payload.target,
                            request = message.payload.requestData,
                            data = addon.characters[addon.thisCharacter].data[key][subKey];
                        }
                    }
                    self:Transmit_NoQueue(msg, "WHISPER", sender)
                    addon.LogDebugMessage("comms", string.format("Sent data response to %s", sender))
                    addon:TriggerEvent("StatusText_OnChanged", string.format("Sent data response to %s", sender))

                end
            else
                addon.LogDebugMessage("comms", string.format("Invalid keys from string split [%s]", sender))
            end
        else
            if addon.characters[addon.thisCharacter] and addon.characters[addon.thisCharacter].data[message.payload.requestData] then

                local msg = {
                    event = "CHARACTER_DATA_RESPONSE",
                    version = self.version,
                    payload = {
                        target = message.payload.target,
                        request = message.payload.requestData,
                        data = addon.characters[addon.thisCharacter].data[message.payload.requestData];
                    }
                }
                self:Transmit_NoQueue(msg, "WHISPER", sender)
                addon.LogDebugMessage("comms", string.format("Sent data response to %s", sender))
                addon:TriggerEvent("StatusText_OnChanged", string.format("Sent data response to %s", sender))
            end
        end

    end
end

function Comms:Character_OnDataResponse(sender, message)

    addon.LogDebugMessage("comms", string.format("Data response from %s", sender))
    addon:TriggerEvent("StatusText_OnChanged", string.format("Data response from %s", sender))

    if message.payload.request and message.payload.request:find(".") then
        
        local key, subKey = strsplit(".", message.payload.request)
        if type(key) == "string" and type(subKey) == "string" then
            if message.payload.target and message.payload.data then
                if addon.characters and addon.characters[message.payload.target] then
                    addon.characters[message.payload.target].data[key][subKey] = message.payload.data;
                    addon:TriggerEvent("Character_OnDataChanged", addon.characters[message.payload.target])
                end
            end
        end
        
    else
        if message.payload.target and message.payload.request and message.payload.data then
            if addon.characters and addon.characters[message.payload.target] then
                addon.characters[message.payload.target].data[message.payload.request] = message.payload.data;
                addon:TriggerEvent("Character_OnDataChanged", addon.characters[message.payload.target])
            end
        end
    end

end

--when a comms is received check the event type and pass to the relavent function
Comms.events = {

    CHARACTER_DATA_REQUEST = Comms.Character_OnDataRequest,
    CHARACTER_DATA_RESPONSE = Comms.Character_OnDataResponse,

    --character events
    --CONTAINERS_TRANSMIT = Comms.Character_OnDataReceived,
    INVENTORY_TRANSMIT = Comms.Character_OnDataReceived,
    PAPERDOLL_STATS_TRANSMIT = Comms.Character_OnDataReceived,
    RESISTANCE_TRANSMIT = Comms.Character_OnDataReceived,
    AURA_TRANSMIT = Comms.Character_OnDataReceived,
    TALENT_TRANSMIT = Comms.Character_OnDataReceived,
    GLYPH_TRANSMIT = Comms.Character_OnDataReceived,
    SPEC_TRANSMIT = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF1 = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF1_LEVEL = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF1_SPEC = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF1_RECIPES = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF2 = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF2_LEVEL = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF2_SPEC = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_PROF2_RECIPES = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_COOKING_LEVEL = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_COOKING_RECIPES = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_FISHING_LEVEL = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_FIRSTAID_LEVEL = Comms.Character_OnDataReceived,
    TRADESKILL_TRANSMIT_FIRSTAID_RECIPES = Comms.Character_OnDataReceived,

    --calendar events
    CALENDAR_EVENT_TRANSMIT = "",

    --guild bank events
    GUILDBANK_TIMESTAMPS_REQUEST = Comms.Guildbank_OnTimestampsRequested,
    GUILDBANK_DATA_REQUEST = Comms.Guildbank_OnDataRequested,
    GUILDBANK_TIMESTAMPS_TRANSMIT = Comms.Guildbank_OnTimestampsReceived,
    GUILDBANK_DATA_TRANSMIT = Comms.Guildbank_OnDataReceived,
}

addon:RegisterCallback("Guildbank_DataRequest", Comms.Guildbank_DataRequest, Comms)
addon:RegisterCallback("Guildbank_TimeStampRequest", Comms.Guildbank_TimeStampRequest, Comms)
addon:RegisterCallback("Character_BroadcastChange", Comms.Character_BroadcastChange, Comms)
addon:RegisterCallback("Database_OnInitialised", Comms.Init, Comms)

addon.Comms = Comms;