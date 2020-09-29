--[==[

Copyright ©2020 Samuel Thomas Pain

The contents of this addon, excluding third-party resources, are
copyrighted to their authors with all rights reserved.

This addon is free to use and the authors hereby grants you the following rights:

1. 	You may make modifications to this addon for private use only, you
    may not publicize any portion of this addon.

2. 	Do not modify the name of this addon, including the addon folders.

3. 	This copyright notice shall be included in all copies or substantial
    portions of the Software.

All rights not explicitly addressed in this license are reserved by
the copyright holders.

]==]--

local addonName, Guildbook = ...

local build = 2
local locale = GetLocale()

local AceComm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")

function Guildbook.DEBUG(msg)
    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['Debug'] then
        print(tostring('|cffC41F3BGUILDBOOK: '..msg))
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--slash commands
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_GUILDHELPERCLASSIC1 = '/guildbook'
SLASH_GUILDHELPERCLASSIC2 = '/g-k'
SlashCmdList['GUILDHELPERCLASSIC'] = function(msg)
    if msg == '-help' then
        Guildbook:ScanPlayerProfession()
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--local variables
---------------------------------------------------------------------------------------------------------------------------------------------------------------
local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG

Guildbook.FONT_COLOUR = ''
Guildbook.PlayerMixin = nil
Guildbook.GuildBankCommit = {
    Commit = nil,
    Character = nil,
}

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--init
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:Init()
    DEBUG('running init')
    
    local version = GetAddOnMetadata('Guildbook', "Version")

    self.ContextMenu_DropDown = CreateFrame("Frame", "GuildbookContextMenu", UIParent, "UIDropDownMenuTemplate")
    self.ContextMenu = {}

    AceComm:Embed(self)
    self:RegisterComm(addonName, 'ON_COMMS_RECEIVED')

    --create stored variable tables
    if GUILDBOOK_GLOBAL == nil or GUILDBOOK_GLOBAL == {} then
        GUILDBOOK_GLOBAL = self.Data.DefaultGlobalSettings
        DEBUG('created global saved variable table')
    else
        DEBUG('global variables exists')
    end
    if GUILDBOOK_CHARACTER == nil or GUILDBOOK_CHARACTER == {} then
        GUILDBOOK_CHARACTER = self.Data.DefaultCharacterSettings
        DEBUG('created character saved variable table')
    else
        DEBUG('character variables exists')
    end
    --added later
    if not GUILDBOOK_GLOBAL['GuildRosterCache'] then
        GUILDBOOK_GLOBAL['GuildRosterCache'] = {}
    end
    if GUILDBOOK_GLOBAL['Build'] == nil then
        GUILDBOOK_GLOBAL['Build'] = 0
    end
    if tonumber(GUILDBOOK_GLOBAL['Build']) < build then
        GUILDBOOK_GLOBAL['Build'] = build
        StaticPopup_Show('GuildbookUpdates', version, Guildbook.News[build])
    end

    local ldb = LibStub("LibDataBroker-1.1")
    self.MinimapButton = ldb:NewDataObject('GuildbookMinimapIcon', {
        type = "data source",
        icon = 134939,
        OnClick = function(self, button)
            if button == "LeftButton" then
                if InterfaceOptionsFrame:IsVisible() then
                    InterfaceOptionsFrame:Hide()
                else
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                end
            elseif button == 'RightButton' then
                ToggleFriendsFrame(3)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(tostring('|cff0070DE'..addonName))
            tooltip:AddDoubleLine('|cffffffffLeft Click|r Options')
            tooltip:AddDoubleLine('|cffffffffRight Click|r Guild')
        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    self.MinimapIcon:Register('GuildbookMinimapIcon', self.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])
    -- used a timer here for some reason to force hiding
    C_Timer.After(1, function()
        if GUILDBOOK_GLOBAL['ShowMinimapButton'] == false then
            self.MinimapIcon:Hide('GuildbookMinimapIcon')
            DEBUG('minimap icon saved var setting: false, hiding minimap button')
        end
    end)

    self:ModBlizzUI()
    self:SetupStatsFrame()
    self:SetupTradeSkillFrame()
    self:SetupGuildBankFrame()
    self:SetupGuildCalendarFrame()
    self:SetupGuildMemberDetailframe()

    GuildbookOptionsMainSpecDD_Init()
    GuildbookOptionsOffSpecDD_Init()

    --the OnShow event doesnt fire for the first time the options frame is shown? set the values here
    UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, GUILDBOOK_CHARACTER['MainSpec'])
    UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, GUILDBOOK_CHARACTER['OffSpec'])
    GuildbookOptionsMainCharacterNameInputBox:SetText(GUILDBOOK_CHARACTER['MainCharacter'])
    GuildbookOptionsMainSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['MainSpecIsPvP'])
    GuildbookOptionsOffSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['OffSpecIsPvP'])
    GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
    GuildbookOptionsShowMinimapButton:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])

    -- allow time for loading and whats nots, then send character data
    C_Timer.After(3, function()
        --Guildbook:SendCharacterStats()
        Guildbook:CharacterStats_OnChanged()
    end)

    -- experiment
    -- for i = 1,30 do
    --     if _G['AtlasLoot_Button_'..i] then
    --         local button = _G['AtlasLoot_Button_'..i]
    --         button:HookScript('OnClick', function(self, mb)
    --             if mb == 'MiddleButton' and IsAltKeyDown() then
    --                 print(self.ItemID)
    --             end
    --         end)
    --     end
    -- end

end

function Guildbook.GetProfessionData()
    local myCharacter = { Fishing = 0, Cooking = 0, FirstAid = 0, Prof1 = '-', Prof1Level = 0, Prof2 = '-', Prof2Level = 0 }
    for s = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)
        if Guildbook.GetEnglish[locale][skill] == 'Fishing' then 
            myCharacter.Fishing = level
            DEBUG(string.format('Found %s skill, level: %s', skill, level))
        elseif Guildbook.GetEnglish[locale][skill] == 'Cooking' then
            myCharacter.Cooking = level
            DEBUG(string.format('Found %s skill, level: %s', skill, level))
        elseif Guildbook.GetEnglish[locale][skill] == 'First Aid' then
            myCharacter.FirstAid = level
            DEBUG(string.format('Found %s skill, level: %s', skill, level))
        else
            for k, prof in pairs(Guildbook.Data.Profession) do
                DEBUG(string.format('Prof %s - skill %s', prof.Name, skill))
                if prof.Name == Guildbook.GetEnglish[locale][skill] then
                    if myCharacter.Prof1 == '-' then
                        myCharacter.Prof1 = Guildbook.GetEnglish[locale][skill]
                        myCharacter.Prof1Level = level
                        DEBUG(string.format('Prof %s matches skill %s, level: %s', prof.Name, skill, level))
                    elseif myCharacter.Prof2 == '-' then
                        myCharacter.Prof2 = Guildbook.GetEnglish[locale][skill]
                        myCharacter.Prof2Level = level
                        DEBUG(string.format('Prof %s matches skill %s, level: %s', prof.Name, skill, level))
                    end
                end
            end
        end
    end
    if GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER['Profession1'] = myCharacter.Prof1
        GUILDBOOK_CHARACTER['Profession1Level'] = myCharacter.Prof1Level
        DEBUG('Set player Profession1 as: '..myCharacter.Prof1)
        GUILDBOOK_CHARACTER['Profession2'] = myCharacter.Prof2
        GUILDBOOK_CHARACTER['Profession2Level'] = myCharacter.Prof2Level
        DEBUG('Set player Profession2 as: '..myCharacter.Prof2)
    end
end

function Guildbook.GetInstanceInfo()
    local t = {}
    if GetNumSavedInstances() > 0 then
        for i = 1, GetNumSavedInstances() do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
            tinsert(t, { Name = name, ID = id, Resets = date('*t', tonumber(GetTime() + reset)) })
        end
    end
    return t
end

function Guildbook.GetItemLevel()
    local character, itemlevel, itemCount = {}, 0, 0
	for k, slot in ipairs(Guildbook.Data.InventorySlots) do
		character[slot.Name] = GetInventoryItemID('player', slot.Id)
		if character[slot.Name] ~= nil then
			local iName, iLink, iRarety, ilvl = GetItemInfo(character[slot.Name])
			itemlevel = itemlevel + ilvl
			itemCount = itemCount + 1
		end
	end	
	return math.floor(itemlevel/itemCount)
end

function Guildbook:IsGuildMemberOnline(member)
    local guildName = Guildbook:GetGuildName()
    if guildName then
        local totalMembers, onlineMembers, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            if member == name then
                return true
            end
        end
    end
end

function Guildbook:Transmit(data, channel, target, priority)
    local serialized = LibSerialize:Serialize(data);
    local compressed = LibDeflate:CompressDeflate(serialized);
    local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed);
    self:SendCommMessage(addonName, encoded, channel, target, priority);
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- tradeskills comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendTradeSkillsRequest(target, profession)
    local request = {
        type = "TRADESKILLS_REQUEST",
        payload = profession,
    }
    self:Transmit(request, "WHISPER", target, "NORMAL")
    DEBUG(string.format('sent request for %s from %s', profession, target))
end

function Guildbook:OnTradeSkillsRequested(request, distribution, sender)
    if distribution ~= "WHISPER" then
        return
    end
    if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER[request.payload] then
        local response = {
            type    = "TRADESKILLS_RESPONSE",
            payload = {
                profession = request.payload,
                recipes = GUILDBOOK_CHARACTER[request.payload],
            }
        }
        self:Transmit(response, distribution, sender, "BULK")
        DEBUG(string.format('sending %s data to %s', request.payload, sender))
    end
end

function Guildbook:OnTradeSkillsReceived(data, distribution, sender)
    if data.payload.profession and type(data.payload.recipes) == 'table' then
        C_Timer.After(4.0, function()
            local guildName = Guildbook:GetGuildName()
            if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
                for guid, character in pairs(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName]) do
                    if character.Name == sender then                
                        character[data.payload.profession] = data.payload.recipes
                        DEBUG('set: '..character.Name..' prof: '..data.payload.profession)
                    end
                end
            end
            self.GuildFrame.TradeSkillFrame.RecipesTable = data.payload.recipes
        end)
    else
        -- this is due to older data format, if we get this we wont save as the prof name isnt sent
        -- will remove this support after 1 update
        C_Timer.After(4.0, function()
            self.GuildFrame.TradeSkillFrame.RecipesTable = data.payload
        end)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- character data comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:CharacterDataRequest(target)
    local request = {
        type = 'CHARACTER_DATA_REQUEST'
    }
    self:Transmit(request, 'WHISPER', target, 'NORMAL')
end


function Guildbook:CharacterStats_OnChanged()
    local d = self:GetCharacterDataPayload()
    if type(d) == 'table' and d.payload.GUID then
        self:Transmit(d, 'GUILD', sender, 'NORMAL')
        DEBUG('Sending character data OnChanged')
    end
end

function Guildbook:GetCharacterDataPayload()
    local guid = UnitGUID('player')
    local level = UnitLevel('player')
    local ilvl = self:GetItemLevel()
    self.GetProfessionData()
    if not self.PlayerMixin then
        self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        self.PlayerMixin:SetGUID(guid)
    end
    if self.PlayerMixin:IsValid() then
        local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
        local name = C_PlayerInfo.GetName(self.PlayerMixin)
        local response = {
            type = 'CHARACTER_DATA_RESPONSE',
            payload = {
                GUID = guid,
                Level = level,
                ItemLevel = ilvl,
                Class = class,
                Name = name,
                Profession1Level = GUILDBOOK_CHARACTER["Profession1Level"],
                OffSpec = GUILDBOOK_CHARACTER["OffSpec"],
                Profession1 = GUILDBOOK_CHARACTER["Profession1"],
                MainCharacter = GUILDBOOK_CHARACTER["MainCharacter"],
                MainSpec = GUILDBOOK_CHARACTER["MainSpec"],
                MainSpecIsPvP = GUILDBOOK_CHARACTER["MainSpecIsPvP"],
                Profession2Level = GUILDBOOK_CHARACTER["Profession2Level"],
                Profession2 = GUILDBOOK_CHARACTER["Profession2"],
                AttunementsKeys = GUILDBOOK_CHARACTER["AttunementsKeys"],
                Availability = GUILDBOOK_CHARACTER["Availability"],
                OffSpecIsPvP = GUILDBOOK_CHARACTER["OffSpecIsPvP"],
            }
        }
        return response
    end
end

function Guildbook:OnCharacterDataRequested(request, distribution, sender)
    if distribution ~= 'WHISPER' then
        return
    end
    local d = self:GetCharacterDataPayload()
    if type(d) == 'table' and d.payload.GUID then
        self:Transmit(d, 'WHISPER', sender, 'NORMAL')
        DEBUG('Sending character data OnCharacterDataRequested, sending to: '..sender)
    end
end

function Guildbook:OnCharacterDataReceived(data, distribution, sender)
    local guildName = self:GetGuildName()
    if guildName then
        if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
            GUILDBOOK_GLOBAL.GuildRosterCache[guildName] = {}
        end
        if not GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID] = {}
        end
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Level = tonumber(data.payload.Level)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].ItemLevel = tonumber(data.payload.ItemLevel)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Class = data.payload.Class
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Name = data.payload.Name
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession1Level = tonumber(data.payload.Profession1Level)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].OffSpec = data.payload.OffSpec
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession1 = data.payload.Profession1
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].MainCharacter = data.payload.MainCharacter
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].MainSpec = data.payload.MainSpec
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].MainSpecIsPvP = data.payload.MainSpecIsPvP
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession2Level = tonumber(data.payload.Profession2Level)
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Profession2 = data.payload.Profession2
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].AttunementsKeys = data.payload.AttunementsKeys
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].Availability = data.payload.Availability
        GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][data.payload.GUID].OffSpecIsPvP = data.payload.OffSpecIsPvP
        DEBUG(string.format('Received character data from: %s', data.payload.Name))
        Guildbook:UpdateGuildMemberDetailFrame(data.payload.GUID)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank comms
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SendGuildBankCommitRequest(bankCharacter)
    local request = {
        type = 'GUILD_BANK_COMMIT_REQUEST',
        payload = bankCharacter,
    }
    self:Transmit(request, 'GUILD', nil, 'NORMAL')
    DEBUG(string.format('Sent a request on GUILD channel for commit times on bank character %s', bankCharacter))
end

function Guildbook:OnGuildBankCommitRequested(data, distribution, sender)
    if distribution == 'GUILD' then
        if GUILDBOOK_CHARACTER['GuildBank'] and GUILDBOOK_CHARACTER['GuildBank'][data.payload] and GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit then
            local response = {
                type = 'GUILD_BANK_COMMIT_RESPONSE',
                payload = { 
                    Commit = GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit,
                    Character = data.payload
                }
            }
            self:Transmit(response, 'WHISPER', sender, 'NORMAL')
            DEBUG(string.format('Responding to a guild bank commit request for bank character: %s - commit time: %s', data.payload, GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit))
        end
    end
end

function Guildbook:OnGuildBankCommitReceived(data, distribution, sender)
    if distribution == 'WHISPER' then
        DEBUG(string.format('Received a commit for bank character %s from %s - commit time: %s', data.payload.Character, sender, data.payload.Commit))
        if Guildbook.GuildBankCommit['Commit'] == nil then
            Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
            Guildbook.GuildBankCommit['Character'] = sender
            Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
            DEBUG('First response added to temp table, %s->%s', sender, data.payload.Commit)
        else
            if tonumber(data.payload.Commit) > tonumber(Guildbook.GuildBankCommit['Commit']) then
                Guildbook.GuildBankCommit['Commit'] = data.payload.Commit
                Guildbook.GuildBankCommit['Character'] = sender
                Guildbook.GuildBankCommit['BankCharacter'] = data.payload.Character
                DEBUG('Response commit is newer than temp table commit, updating info - %s->%s', sender, data.payload.Commit)
            end
        end
    end
end

function Guildbook:SendGuildBankDataRequest()
    if Guildbook.GuildBankCommit['Character'] ~= nil then
        local request = {
            type = 'GUILD_BANK_DATA_REQUEST',
            payload = Guildbook.GuildBankCommit['BankCharacter']
        }
        self:Transmit(request, 'WHISPER', Guildbook.GuildBankCommit['Character'], 'NORMAL')
        DEBUG(string.format('Sending request for guild bank data to %s for bank character %s', Guildbook.GuildBankCommit['Character'], Guildbook.GuildBankCommit['BankCharacter']))
    end
end

function Guildbook:OnGuildBankDataRequested(data, distribution, sender)
    if distribution == 'WHISPER' then
        local response = {
            type = 'GUILD_BANK_DATA_RESPONSE',
            payload = {
                Data = GUILDBOOK_CHARACTER['GuildBank'][data.payload].Data,
                Commit = GUILDBOOK_CHARACTER['GuildBank'][data.payload].Commit,
                Bank = data.payload,
            }
        }
        self:Transmit(response, 'WHISPER', sender, 'BULK')
        DEBUG('Sending guild bank data to: '..sender..' as requested')
    end
end

function Guildbook:OnGuildBankDataReceived(data, distribution, sender)
    if distribution == 'WHISPER' or distribution == 'GUILD' then
        if not GUILDBOOK_CHARACTER['GuildBank'] then
            GUILDBOOK_CHARACTER['GuildBank'] = {
                [data.payload.Bank] = {
                    Commit = data.payload.Commit,
                    Data = data.payload.Data,
                }
            }
        else
            GUILDBOOK_CHARACTER['GuildBank'][data.payload.Bank] = {
                Commit = data.payload.Commit,
                Data = data.payload.Data,
            }
        end
    end
    self.GuildFrame.GuildBankFrame:ProcessBankData(data.payload.Data)
    self.GuildFrame.GuildBankFrame:RefreshSlots()
end

-- TODO: add script for when a player drops a prof
SkillDetailStatusBarUnlearnButton:HookScript('OnClick', function()

end)

function Guildbook:TRADE_SKILL_UPDATE()
    C_Timer.After(1, function()
        DEBUG('trade skill update, scanning skills')
        self:ScanTradeSkill()
    end)
end

function Guildbook:CRAFT_UPDATE()
    C_Timer.After(1, function()
        DEBUG('craft skill update, scanning skills')
        self:ScanCraftSkills_Enchanting()
    end)
end

function Guildbook:ScanCharacterContainers()
    if BankFrame:IsVisible() then
        local guid = UnitGUID('player')
        if not self.PlayerMixin then
            self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            self.PlayerMixin:SetGUID(guid)
        end
        if self.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(self.PlayerMixin)

            if not GUILDBOOK_CHARACTER['GuildBank'] then
                GUILDBOOK_CHARACTER['GuildBank'] = {
                    [name] = {
                        Data = {},
                        Commit = GetServerTime()
                    }
                }
            else
                GUILDBOOK_CHARACTER['GuildBank'][name].Commit = GetServerTime()
                GUILDBOOK_CHARACTER['GuildBank'][name].Data = {}
            end

            -- player bags
            for bag = 0, 4 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local id = select(10, GetContainerItemInfo(bag, slot))
                    local count = select(2, GetContainerItemInfo(bag, slot))
                    if id and count then
                        if not GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] then
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = count
                        else
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] + count
                        end
                    end
                end
            end

            -- main bank
            for slot = 1, 28 do
                local id = select(10, GetContainerItemInfo(-1, slot))
                local count = select(2, GetContainerItemInfo(-1, slot))
                if id and count then
                    if not GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] then
                        GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = count
                    else
                        GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] + count
                    end
                end
            end

            -- bank bags
            for bag = 5, 11 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local id = select(10, GetContainerItemInfo(bag, slot))
                    local count = select(2, GetContainerItemInfo(bag, slot))
                    if id and count then
                        if not GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] then
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = count
                        else
                            GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] = GUILDBOOK_CHARACTER['GuildBank'][name].Data[id] + count
                        end
                    end
                end
            end

            local bankUpdate = {
                type = 'GUILD_BANK_DATA_RESPONSE',
                payload = {
                    Data = GUILDBOOK_CHARACTER['GuildBank'][name].Data,
                    Commit = GUILDBOOK_CHARACTER['GuildBank'][name].Commit,
                    Bank = name,
                }
            }
            self:Transmit(bankUpdate, 'GUILD', sender, 'BULK')
            DEBUG('sending guild bank data due to new commit')
        end
    end
end

function Guildbook:ScanTradeSkill()
    local prof = GetTradeSkillLine()
    GUILDBOOK_CHARACTER[prof] = {}
    for i = 1, GetNumTradeSkills() do
        local name, type, _, _, _, _ = GetTradeSkillInfo(i)
        if (name and type ~= "header") then
            local itemLink = GetTradeSkillItemLink(i)
            local itemID = select(1, GetItemInfoInstant(itemLink))
            local itemName = select(1, GetItemInfo(itemID))
            DEBUG(string.format('|cff0070DETrade item|r: %s, with ID: %s', name, itemID))
            if itemName and itemID then
                GUILDBOOK_CHARACTER[prof][itemID] = {}
            end
            local numReagents = GetTradeSkillNumReagents(i);
            if numReagents > 0 then
                for j = 1, numReagents, 1 do
                    local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(i, j)
                    local reagentLink = GetTradeSkillReagentItemLink(i, j)
                    local reagentID = select(1, GetItemInfoInstant(reagentLink))
                    if reagentName and reagentID and reagentCount then
                        DEBUG(string.format('    Reagent name: %s, with ID: %s, Needed: %s', reagentName, reagentID, reagentCount))
                        GUILDBOOK_CHARACTER[prof][itemID][reagentID] = reagentCount
                    end
                end
            end
        end
    end
end

function Guildbook:ScanCraftSkills_Enchanting()
    local currentCraftingWindow = GetCraftSkillLine(1)
    if currentCraftingWindow == 'Enchanting' then
        GUILDBOOK_CHARACTER['Enchanting'] = {}
        for i = 1, GetNumCrafts() do
            local name, _, type, _, _, _, _ = GetCraftInfo(i)
            if (name and type ~= "header") then
                local itemID = select(7, GetSpellInfo(name))
                DEBUG(string.format('|cff0070DETrade item|r: %s, with ID: %s', name, itemID))
                if itemID then
                    GUILDBOOK_CHARACTER['Enchanting'][itemID] = {}
                end
                local numReagents = GetCraftNumReagents(i);
                DEBUG(string.format('this recipe has %s reagents', numReagents))
                if numReagents > 0 then
                    for j = 1, numReagents do
                        local reagentName, reagentTexture, reagentCount, playerReagentCount = GetCraftReagentInfo(i, j)
                        local reagentLink = GetCraftReagentItemLink(i, j)
                        if reagentName and reagentCount then
                            DEBUG(string.format('reagent number: %s with name %s and count %s', j, reagentName, reagentCount))
                            if reagentLink then
                                local reagentID = select(1, GetItemInfoInstant(reagentLink))
                                DEBUG('reagent id: '..reagentID)
                                if reagentID and reagentCount then
                                    GUILDBOOK_CHARACTER['Enchanting'][itemID][reagentID] = reagentCount
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Guildbook:GetGuildName()
    local guildName = false
    if IsInGuild() and GetGuildInfo("player") then
        local guildName, _, _, _ = GetGuildInfo('player')
        return guildName
    end
end

-- events
function Guildbook:ADDON_LOADED(...)
    if tostring(...):lower() == addonName:lower() then
        self:Init()
    end
end

function Guildbook:GUILD_ROSTER_UPDATE(...)
    if GuildMemberDetailFrame:IsVisible() then     
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(GetGuildRosterSelection())
        if isOnline then
            Guildbook:UpdateGuildMemberDetailFrameLabels()
            Guildbook:ClearGuildMemberDetailFrame()
            Guildbook:CharacterDataRequest(name)
        end
    end
end

function Guildbook:PLAYER_LEVEL_UP()
    C_Timer.After(3, function()
        Guildbook:CharacterStats_OnChanged()
    end)
end

function Guildbook:SKILL_LINES_CHANGED()
    C_Timer.After(3, function()
        Guildbook:CharacterStats_OnChanged()
    end)
end

--- handle comms
-- create a 10 sec period between request responses to reduce chat spam
local tradeDelay, bankDelay = 10, 10
local lastTradeSkillRequest = {}
local lastGuildBankRequest = {}
function Guildbook:ON_COMMS_RECEIVED(prefix, message, distribution, sender)
    if prefix ~= addonName then 
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

    if data.type == "TRADESKILLS_REQUEST" then
        if not lastTradeSkillRequest[sender] then
            lastTradeSkillRequest[sender] = -math.huge
        end
        if lastTradeSkillRequest[sender] + tradeDelay < GetTime() then
            self:OnTradeSkillsRequested(data, distribution, sender)
            lastTradeSkillRequest[sender] = GetTime()
        else
            local remaining = string.format("%.1d", (lastTradeSkillRequest[sender] + tradeDelay - GetTime()))
            DEBUG(string.format('please allow 10 secs between requests, %d seconds remaining', remaining))
        end

    elseif data.type == "TRADESKILLS_RESPONSE" then
        self:OnTradeSkillsReceived(data, distribution, sender);

    elseif data.type == 'CHARACTER_DATA_REQUEST' then
        self:OnCharacterDataRequested(data, distribution, sender)

    elseif data.type == 'CHARACTER_DATA_RESPONSE' then
        self:OnCharacterDataReceived(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_COMMIT_REQUEST' then
        self:OnGuildBankCommitRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_COMMIT_RESPONSE' then
        self:OnGuildBankCommitReceived(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_REQUEST' then
        if not lastGuildBankRequest[sender] then
            lastGuildBankRequest[sender] = -math.huge
        end
        if lastGuildBankRequest[sender] + tradeDelay < GetTime() then
            self:OnTradeSkillsRequested(data, distribution, sender)
            lastGuildBankRequest[sender] = GetTime()
        else
            local remaining = string.format("%.1d", (lastGuildBankRequest[sender] + tradeDelay - GetTime()))
            DEBUG(string.format('please allow 10 secs between requests, %d seconds remaining', remaining))
        end
        self:OnGuildBankDataRequested(data, distribution, sender)

    elseif data.type == 'GUILD_BANK_DATA_RESPONSE' then
        self:OnGuildBankDataReceived(data, distribution, sender)
    end
end

--set up event listener
Guildbook.EventFrame = CreateFrame('FRAME', 'GuildbookEventFrame', UIParent)
Guildbook.EventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
Guildbook.EventFrame:RegisterEvent('ADDON_LOADED')
Guildbook.EventFrame:RegisterEvent('PLAYER_LEVEL_UP')
Guildbook.EventFrame:RegisterEvent('SKILL_LINES_CHANGED')
Guildbook.EventFrame:RegisterEvent('TRADE_SKILL_UPDATE')
Guildbook.EventFrame:RegisterEvent('CRAFT_UPDATE')
Guildbook.EventFrame:SetScript('OnEvent', function(self, event, ...)
    --DEBUG('EVENT='..tostring(event))
    Guildbook[event](Guildbook, ...)
end)