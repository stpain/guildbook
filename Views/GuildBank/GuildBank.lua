local name, addon = ...;
local L = addon.Locales;
local Database = addon.Database;

GuildbookGuildBankMixin = {
    name = "GuildBank",
    selectedCharacter = "",
    banks = {},
    helptips = {},
}

function GuildbookGuildBankMixin:OnLoad()

    addon:RegisterCallback("Character_OnDataChanged", self.Character_OnDataChanged, self)
    addon:RegisterCallback("Guildbank_OnTimestampsReceived", self.Guildbank_OnTimestampsReceived, self)
    addon:RegisterCallback("Guildbank_OnDataReceived", self.Guildbank_OnDataReceived, self)

    self.refresh:SetScript("OnMouseDown", function()
        self:RequestTimestamps()
    end)

    self.bankCharactersHelptip:SetText(L.BANK_CHARACTER_LISTVIEW_HT)
    self.refreshHelptip:SetText(L.BANK_CHARACTER_REFRESH_HT)

    table.insert(self.helptips, self.bankCharactersHelptip)
    table.insert(self.helptips, self.refreshHelptip)

    addon.AddView(self)
end

function GuildbookGuildBankMixin:RequestTimestamps()
    --[[
        so the idea here is to find the latest guild bank data

        step 1: loop through the current known bank charcters and request timestamps from guild members who have that character listed
                this is done using a stagger or 'delay' effect between requests per character

        step 2: when the time stamp table is returned check for a bank characters name and then if the timestamp is newer update the source (sender name)

        step 3: after all bank characters have had timestamp requests sent send a request to the source for their data
    ]]

    --step 1:
    local requestDelay = 1.25
    for k, v in ipairs(self.banks) do
        C_Timer.After((k - 1) * requestDelay, function()
            addon:TriggerEvent("Guildbank_TimeStampRequest", v.characterName)
            addon.LogDebugMessage("bank", string.format("requesting timestamps for bank [%s]", v.characterName))
            addon:TriggerEvent("Guildbank_StatusInfo", {
                characterName = v.characterName,
                status = "requesting timestamps"
            })
        end)
    end

    --step 3:
    C_Timer.After((#self.banks * requestDelay) + 1, function()
        for k, v in ipairs(self.banks) do
            if v.lastUpdateTime > 0 and v.source then
                addon:TriggerEvent("Guildbank_DataRequest", v.source, v.characterName)
                addon.LogDebugMessage("bank", string.format("requesting data for bank [%s]", v.characterName))
                addon:TriggerEvent("Guildbank_StatusInfo", {
                    characterName = v.characterName,
                    status = string.format("requesting data from %s", v.source)
                })
            else
                addon:TriggerEvent("Guildbank_StatusInfo", {
                    characterName = v.characterName,
                    status = "unable to locate data"
                }) 
            end
        end
    end)
end

function GuildbookGuildBankMixin:Guildbank_OnTimestampsReceived(sender, message)

    addon.LogDebugMessage("bank", string.format("received bank timestamps from [%s]", sender))

    --step 2:
    for k, v in ipairs(self.banks) do
        if message.payload[v.characterName] then
            if message.payload[v.characterName] and (message.payload[v.characterName] ~= 0) and (message.payload[v.characterName] >= v.lastUpdateTime) then
                v.lastUpdateTime = message.payload[v.characterName]
                v.source = sender

                --set this banks update time
                if addon.guilds[addon.thisGuild] then
                    if not addon.guilds[addon.thisGuild].banks[v.characterName] then
                        addon.guilds[addon.thisGuild].banks[v.characterName] = 0;
                    end
                    addon.guilds[addon.thisGuild].banks[v.characterName] = message.payload[v.characterName];
                end

                addon:TriggerEvent("Guildbank_StatusInfo", {
                    characterName = v.characterName,
                    status = string.format("timestamp from %s", sender)
                })
            end
        end
    end
end

function GuildbookGuildBankMixin:OnShow()

    self.charactersListview.DataProvider:Flush()

    self.banks = {}

    if addon.characters then
        for name, character in pairs(addon.characters) do
            if character.data.publicNote:lower():find("guildbank") then

                if addon.guilds[addon.thisGuild] then

                    --set a default timestamp
                    if not addon.guilds[addon.thisGuild].banks[character.data.name] then
                        addon.guilds[addon.thisGuild].banks[character.data.name] = 0;
                    end

                    table.insert(self.banks, {
                        characterName = character.data.name,
                        lastUpdateTime = addon.guilds[addon.thisGuild].banks[character.data.name],
                    })
    
                    self.charactersListview.DataProvider:Insert({
                        label = character.data.name,
                        atlas = character:GetProfileAvatar(),
                        showMask = true,
        
                        func = function()
                            self.selectedCharacter = character.data.name;
                            self:LoadCharacterContainers(character.data.name, character.data.containers)
                        end,
                    })

                    if character.data.containers then
                        local hasData = false;
                        if character.data.containers.bags and character.data.containers.bags.items and (#character.data.containers.bags.items > 0) then
                            hasData = true;
                        end
                        if character.data.containers.bank and character.data.containers.bank.items and (#character.data.containers.bank.items > 0) then
                            hasData = true;
                        end
                        if hasData then
                            addon:TriggerEvent("Guildbank_StatusInfo", {
                                characterName = character.data.name,
                                status = string.format("found existing data")
                            })
                        end
                    end
                end

            else
                if addon.api.characterIsMine(name) then
                    self.charactersListview.DataProvider:Insert({
                        label = character.data.name,
                        status = "[Alt Character]",
                        atlas = character:GetProfileAvatar(),
                        showMask = true,
        
                        func = function()
                            self.selectedCharacter = character.data.name;
                            self:LoadCharacterContainers(character.data.name, character.data.containers)
                        end,
                    })
                end
            end
        end
    end

    local guildbanks = self:GetAllBanksInfo()
    self.guildBankInfo:SetText(string.format("%d Bank character(s), %d slots (%d used %d free) Gold: %s", 
        guildbanks.numBanks,
        (guildbanks.totalSlotsUsed + guildbanks.totalSlotsFree),
        guildbanks.totalSlotsUsed,
        guildbanks.totalSlotsFree,
        GetCoinTextureString(guildbanks.copper)
    ))
end


function GuildbookGuildBankMixin:Guildbank_OnDataReceived(sender, message)
    addon.LogDebugMessage("bank", string.format("received bank data from [%s]", sender))
    addon:TriggerEvent("Guildbank_StatusInfo", {
        characterName = message.payload.bank,
        status = string.format("received data from %s", sender)
    })

    --DevTools_Dump(message.payload)

    --set this to the character for future requests, this will also trigger a Character_OnDataChanged event which will update the bank UI if this character is selected
    if addon.characters[message.payload.bank] then
        addon.characters[message.payload.bank]:SetContainers(message.payload.containers)
    end

    local guildbanks = self:GetAllBanksInfo()
    self.guildBankInfo:SetText(string.format("%d Bank character(s), %d slots (%d used %d free) Gold: %s", 
        guildbanks.numBanks,
        (guildbanks.totalSlotsUsed + guildbanks.totalSlotsFree),
        guildbanks.totalSlotsUsed,
        guildbanks.totalSlotsFree,
        GetCoinTextureString(guildbanks.copper)
    ))
end

function GuildbookGuildBankMixin:GetAllBanksInfo()
    local info = {
        numBanks = 0,
        totalSlotsUsed = 0,
        totalSlotsFree = 0,
        copper = 0,
    }
    if self.banks then
        for k, v in ipairs(self.banks) do
            if addon.characters and addon.characters[v.characterName] then
                local bags = addon.characters[v.characterName].data.containers.bags
                if bags then
                    info.totalSlotsFree = info.totalSlotsFree + (bags.slotsFree or 0);
                    info.totalSlotsUsed = info.totalSlotsUsed + (bags.slotsUsed or 0);
                end
                local bank = addon.characters[v.characterName].data.containers.bank
                if bank then
                    info.totalSlotsFree = info.totalSlotsFree + (bank.slotsFree or 0);
                    info.totalSlotsUsed = info.totalSlotsUsed + (bank.slotsUsed or 0);
                end
                if bags or bank then
                    info.numBanks = info.numBanks + 1;
                end
                info.copper = info.copper + (addon.characters[v.characterName].data.containers.copper or 0);
            end
        end
    end
    return info;
end

function GuildbookGuildBankMixin:Character_OnDataChanged(character)
    if self.selectedCharacter == character.data.name then
        self:LoadCharacterContainers(self.selectedCharacter, character.data.containers)
    end
end

function GuildbookGuildBankMixin:LoadCharacterContainers_Old(name, containers)

    self.containerInfo.itemsListview.DataProvider:Flush()

    local bankInfo = {
        totalSlotsUsed = 0,
        totalSlotsFree = 0,
        copper = 0,
    }
    bankInfo.copper = containers.copper or 0;
    if containers.bags then
        bankInfo.totalSlotsFree = bankInfo.totalSlotsFree + (containers.bags.slotsFree or 0);
        bankInfo.totalSlotsUsed = bankInfo.totalSlotsUsed + (containers.bags.slotsUsed or 0);
    end
    if containers.bank then
        bankInfo.totalSlotsFree = bankInfo.totalSlotsFree + (containers.bank.slotsFree or 0);
        bankInfo.totalSlotsUsed = bankInfo.totalSlotsUsed + (containers.bank.slotsUsed or 0);
    end

    local t, info = {}, "";
    if containers.bags and containers.bags.items then
        for k, v in ipairs(containers.bags.items) do
            table.insert(t, v)
        end
    else
        info = string.format("%s no bags data", info)
    end
    if containers.bank and containers.bank.items then
        for k, v in ipairs(containers.bank.items) do
            table.insert(t, v)
        end    
    else
        info = string.format("%s no bank data", info)
    end

    if #t > 0 then
        table.sort(t, function(a, b)
            return a.id < b.id
        end)
        self.containerInfo.itemsListview.DataProvider:InsertTable(t)
    end

    if (not containers.bags) and (not containers.bank) then
        self.containerInfo.characterInfo:SetText(info)
    else
        self.containerInfo.characterInfo:SetText(string.format("[%s] %d slots (%d used %d free) Gold: |cffffffff%s|r",
            name,
            bankInfo.totalSlotsUsed + bankInfo.totalSlotsFree,
            bankInfo.totalSlotsUsed,
            bankInfo.totalSlotsFree,
            GetCoinTextureString(bankInfo.copper)
        ))
    end
end

function GuildbookGuildBankMixin:LoadCharacterContainers(name, containers)

    self.bankContainerItems = {}

    local bankInfo = {
        totalSlotsUsed = 0,
        totalSlotsFree = 0,
        copper = 0,
    }
    bankInfo.copper = containers.copper or 0;
    if containers.bags then
        bankInfo.totalSlotsFree = bankInfo.totalSlotsFree + (containers.bags.slotsFree or 0);
        bankInfo.totalSlotsUsed = bankInfo.totalSlotsUsed + (containers.bags.slotsUsed or 0);
    end
    if containers.bank then
        bankInfo.totalSlotsFree = bankInfo.totalSlotsFree + (containers.bank.slotsFree or 0);
        bankInfo.totalSlotsUsed = bankInfo.totalSlotsUsed + (containers.bank.slotsUsed or 0);
    end

    local t, info = {}, "";
    if containers.bags and containers.bags.items then
        for k, v in ipairs(containers.bags.items) do
            table.insert(t, v)
        end
    else
        info = string.format("%s no bags data", info)
    end
    if containers.bank and containers.bank.items then
        for k, v in ipairs(containers.bank.items) do
            table.insert(t, v)
        end    
    else
        info = string.format("%s no bank data", info)
    end

    local i = 1;
    if #t > 0 then
        for k, v in ipairs(t) do
            local item = Item:CreateFromItemID(v.id)
            if not item:IsItemEmpty() then
                item:ContinueOnItemLoad(function()
                    local name = item:GetItemName()
                    local link = item:GetItemLink()
                    local _, _, _, _, icon, classID, subClassID = GetItemInfoInstant(link)

                    table.insert(self.bankContainerItems, {
                        name = name,
                        link = link,
                        count = v.count,
                        icon = icon,
                        classID = classID,
                        subClassID = subClassID,
                    })

                    i = i + 1;
                    if i > #t then
                        self:UpdateConatinerUI()
                    end
                end)
            end
        end
    end

    if (not containers.bags) and (not containers.bank) then
        self.containerInfo.characterInfo:SetText(info)
    else
        self.containerInfo.characterInfo:SetText(string.format("[%s] %d slots (%d used %d free) Gold: |cffffffff%s|r",
            name,
            bankInfo.totalSlotsUsed + bankInfo.totalSlotsFree,
            bankInfo.totalSlotsUsed,
            bankInfo.totalSlotsFree,
            GetCoinTextureString(bankInfo.copper)
        ))
    end
end

--this is a new function to take over the UI update from the above, this allows the UI to do sorting etc
function GuildbookGuildBankMixin:UpdateConatinerUI()

    self.containerInfo.itemsListview.DataProvider:Flush()
    
    local t = {}
    local headersAdded = {}

    table.sort(self.bankContainerItems, function(a, b)
        if a.classID == b.classID then
            if a.subClassID == b.subClassID then
                if a.count == b.count then
                    return a.name < b.name
                else
                    return a.count > b.count
                end
            else
                return a.subClassID < b.subClassID
            end
        else
            return a.classID > b.classID
        end
    end)
    
    for k, v in ipairs(self.bankContainerItems) do
        
        local classType = GetItemClassInfo(v.classID)
        if not headersAdded[classType] then
            headersAdded[classType] = true
            self.containerInfo.itemsListview.DataProvider:Insert({
                label = classType,
                backgroundAlpha = 0.4,
                backgroundRGB = { r = 0.1, g = 0.4, b = 0.4 }
            })
        end
        self.containerInfo.itemsListview.DataProvider:Insert({
            label = v.link,
            labelRight = v.count,
            icon = v.icon,
            backgroundAlpha = 0.05,
            backgroundRGB = { r = 0.4, g = 0.4, b = 0.4 }
        })
    end
end