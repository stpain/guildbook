

local addonName, addon = ...;

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

local Comms = {};
Comms.prefix = "Guildbook";
Comms.version = 0;
Comms.processDelay = 2.0; --delay before processing incoming message data
Comms.queueWaitingTime = 20.0; --delay from first outgoing message queued to actual dispatch time
Comms.dispatcherElapsedDelay = 1.0; --stagger effect for the onUpdate func on dispatcher
Comms.queue = {};
Comms.queueExtendTime = 5.0; --the extension given to each message waiting in the queue, this limits how oftena  message can be dispatched
Comms.dispatcher = CreateFrame("FRAME");
Comms.dispatcherElapsed = 0;
Comms.pause = false;

function Comms:Init()

    AceComm:Embed(self)
    self:RegisterComm(self.prefix)

    self.version = tonumber(GetAddOnMetadata('Guildbook', "Version"));

    addon.DEBUG("func", "Comms:Init", "comms init")


    self.dispatcher:SetScript("OnUpdate", Comms.DispatcherOnUpdate)
end


function Comms.DispatcherOnUpdate(self, elapsed)

    Comms.dispatcherElapsed = Comms.dispatcherElapsed + elapsed;

    if Comms.dispatcherElapsed < Comms.dispatcherElapsedDelay then
        return;
    else
        Comms.dispatcherElapsed = 0;
    end

    if #Comms.queue == 0 then
        self:SetScript("OnUpdate", nil)
        addon.DEBUG("commsMixin", "Comms:DispatcherOnUpdate", string.format("queue is empty removed the onUpdate func"))
    else

        local now = time();
        local event = Comms.queue[1];
        if event.dispatchTime < now then
            Comms:SendChatMessage(event.message, event.channel, event.target, event.priority)
            for i = 2, #Comms.queue do
                Comms.queue[i].dispatchTime = now + ((i - 1) * Comms.queueExtendTime)
                addon.DEBUG("commsMixin", "Comms:DispatcherOnUpdate", string.format("extended dispatch time for %s", Comms.queue[i].event))
            end
            table.remove(Comms.queue, 1)
            if #Comms.queue == 0 then
                self:SetScript("OnUpdate", nil)
                addon.DEBUG("commsMixin", "Comms:DispatcherOnUpdate", string.format("queue is empty removed the onUpdate func"))
            end
        end
    end
end

function Comms:SendPlainTextMessage(msg, target)
    C_ChatInfo.SendAddonMessageLogged(self.prefix, msg, target)
end


---the purpose of this queue function is to provide some relief to the addon comms channel
---if a message with the same type is queued more than once within a 'stagger' period of time
---the data of the message is kept and then sent after a timer.
---the timer delay is determined by the previous timer to keep messages spaced out
function Comms:QueueMessage(event, message, channel, target, priority)

    addon.DEBUG("commsMixin", "Comms:QueueMessage", string.format("adding %s to the queue", event))

    local exists = false;
    for k, info in ipairs(self.queue) do
        if info.event == event then
            exists = true;
            info = {
                event = event,
                message = message,
                channel = channel,
                target = target,
                priority = priority,
            }
            addon.DEBUG("commsMixin", "Comms:QueueMessage", string.format("updated package data for %s", event))
        end
    end

    if exists == false then
        table.insert(self.queue, {
            event = event,
            message = message,
            channel = channel,
            target = target,
            priority = priority,
            dispatchTime = time() + self.queueWaitingTime;
        })
        self.dispatcher:SetScript("OnUpdate", self.DispatcherOnUpdate)
    end
end

---send an addon message through the aceComm lib
---@param data table the data to send including a comm type
---@param channel string the addon channel to use for the comm
---@param targetGUID string the targets GUID, this is used to make comms work on conneted realms - only required for WHISPER comms
---@param priority string the prio to use
function Comms:SendChatMessage(data, channel, targetGUID, priority)

    if self.pause == true then
        return;
    end

    if targetGUID == UnitGUID("player") then
        addon.DEBUG('commsMixin', 'Comms:Transmit', "cancel transmit as target is player", data)
        --return;
    end

    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        local blockCommsDuringInstance = Database:GetConfigSetting("blockCommsDuringInstance");
        if blockCommsDuringInstance == true then
            addon:TriggerEvent("OnCommsBlocked", "blocked comms during instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        local blockCommsDuringCombat = Database:GetConfigSetting("blockCommsDuringCombat");
        if blockCommsDuringCombat == true then
            addon:TriggerEvent("OnCommsBlocked", "blocked comms during combat")
            return;
        end
    end
    if IsInGuild() and GetGuildInfo("player") then
        -- we just want to make sure we are in a guild here to stop spam
    else
        return;
    end
    
    -- add the version and sender guid to the message
    data["version"] = self.version;
    data["senderGUID"] = UnitGUID("player")

    -- clean up the target name when using a whisper
    if channel == 'WHISPER' then

        local foundTargetInCurrentGuild = false;

        -- i dont like this approach but if i get reports of spam messages this might have to exist as the solution, on a positive it frees up the ui to show online list better
        local totalMembers = GetNumGuildMembers()
        for i = 1, totalMembers do
            local nameRealm, _, _, _, _, _, _, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            if guid == targetGUID and isOnline == true then
                
                addon.DEBUG('commsMixin', 'SendCommMessage_TargetOnline', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, (target or 'nil'), priority), data)
                
                local target = Ambiguate(nameRealm, "none")

                local serialized = LibSerialize:Serialize(data);
                local compressed = LibDeflate:CompressDeflate(serialized);
                local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
            
                if encoded and channel and priority and target then
                
                    self:SendCommMessage(Comms.prefix, encoded, channel, target, priority)
                    foundTargetInCurrentGuild = true
                    return; -- stop looping the roster

                end
            end
        end

        if foundTargetInCurrentGuild == false then
            
            if data.type == "TRADESKILL_WORK_ORDER_ADD" then
                
                --this could be a way to send work orders cross guilds - BUT - if the target is offline the chat window will probs get spammed

                local _, _, _, _, _, target = GetPlayerInfoByGUID(targetGUID) --this can be replaced with a guild search if the function ever goes away

                if type(target) == "string" then
                    local serialized = LibSerialize:Serialize(data);
                    local compressed = LibDeflate:CompressDeflate(serialized);
                    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
                
                    if encoded and channel and priority and target then
                    
                        self:SendCommMessage(Comms.prefix, encoded, channel, target, priority)
                        return;
    
                    end 
                end
            end

        end

    elseif channel == "GUILD" then
        local serialized = LibSerialize:Serialize(data);
        local compressed = LibDeflate:CompressDeflate(serialized);
        local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);

        if encoded and channel and priority then
            addon.DEBUG('commsMixin', 'SendCommMessage_NoTarget', string.format("type: %s, channel: %s target: %s, prio: %s", data.type or 'nil', channel, 'nil', priority), data)
            self:SendCommMessage(Comms.prefix, encoded, channel, nil, priority)
        end
    end
end


function Comms:OnCommReceived(prefix, message, distribution, sender)

    if self.pause == true then
        return;
    end

    ---check if we want to process comms data
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "none" then
        local blockCommsDuringInstance = Database:GetConfigSetting("blockCommsDuringInstance");
        if blockCommsDuringInstance == true then
            addon:TriggerEvent("OnCommsBlocked", "blocked comms during instance")
            return;
        end
    end
    local inLockdown = InCombatLockdown()
    if inLockdown then
        local blockCommsDuringCombat = Database:GetConfigSetting("blockCommsDuringCombat");
        if blockCommsDuringCombat == true then
            addon:TriggerEvent("OnCommsBlocked", "blocked comms during combat")
            return;
        end
    end

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

    addon.DEBUG('commsMixin', string.format("Comms:OnCommsReceived <%s>", distribution), string.format("%s from %s", data.type, sender), data)
    
    ---before we process the data pause to allow all messages to be put together again
    C_Timer.After(self.processDelay, function()
        self:ProcessIncomingData(data, sender)
    end)
end


function Comms:ProcessIncomingData(data, sender)
    addon:TriggerEvent("OnCommsMessage", sender, data)
    addon.DEBUG('commsMixin', "Comms:ProcessIncomingData", string.format("Handler %s does exist", data.type), data)
end


addon.Comms = Comms;