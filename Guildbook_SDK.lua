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

--THIS IS THE FIRST FILE READ AFTER LOCALES, NOT ALL SETTINGS ARE AVAILABLE UNTIL MAIN FILE IS READ AND INIT CALLED

local addonName, Guildbook = ...
Guildbook.LOADED = false --stops functions and errors

function Guildbook.PRINT(color, msg)
    print(tostring(color..'Guildbook:|r '..msg))
end

function Guildbook.DEBUG(msg, override)
    if override then
        print(tostring('|cffC41F3BGUILDBOOK DEBUG: '..msg))
    else
        if Guildbook.LOADED and GUILDBOOK_GLOBAL['Debug'] then
            print(tostring('|cffC41F3BGUILDBOOK DEBUG: '..msg))
        end
    end
end

function Guildbook.GetArgs(...)
    if Guildbook.LOADED and GUILDBOOK_GLOBAL['Debug'] then
        for i=1, select("#", ...) do
            arg = select(i, ...)
            print(i.." "..tostring(arg))
        end
    end
end

function Guildbook.RgbToPercent(t)
    if type(t) == 'table' then
        if type(t[1]) == 'number' and type(t[2]) == 'number' and type(t[3]) == 'number' then
            local r = tonumber(t[1] / 256.0)
            local g = tonumber(t[2] / 256.0)
            local b = tonumber(t[3] / 256.0)
            return {r, g, b}
        end
    end
end

function Guildbook.GetGender(unit)
    local genders = { 'Unknown', 'MALE', 'FEMALE' }
    return tostring(genders[UnitSex(unit)])
end

function Guildbook.GetProfessionData()
    local myCharacter = { Fishing = 0, Cooking = 0, FirstAid = 0, Prof1 = '-', Prof1Level = 0, Prof2 = '-', Prof2Level = 0 }
    for s = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)
        if skill == 'Fishing' then 
            myCharacter.Fishing = level
        elseif skill == 'Cooking' then
            myCharacter.Cooking = level
        elseif skill == 'First Aid' then
            myCharacter.FirstAid = level
        else
            for k, prof in pairs(Guildbook.Data.Profession) do
                if skill == prof.Name then
                    if myCharacter.Prof1 == '-' then
                        myCharacter.Prof1 = skill
                        myCharacter.Prof1Level = level
                    elseif myCharacter.Prof2 == '-' then
                        myCharacter.Prof2 = skill
                        myCharacter.Prof2Level = level
                    end
                end
            end
        end
    end
    if GUILDBOOK_CHARACTER then
        GUILDBOOK_CHARACTER['Profession1'] = myCharacter.Prof1
        GUILDBOOK_CHARACTER['Profession1Level'] = myCharacter.Prof1Level
        GUILDBOOK_CHARACTER['Profession2'] = myCharacter.Prof2
        GUILDBOOK_CHARACTER['Profession2Level'] = myCharacter.Prof2Level
    end
    return tostring(myCharacter.Fishing..':'..myCharacter.Cooking..':'..myCharacter.FirstAid..':'..myCharacter.Prof1..':'..myCharacter.Prof1Level..':'..myCharacter.Prof2..':'..myCharacter.Prof2Level)
end

function Guildbook.GetMainCharacter()
    return tostring(GUILDBOOK_CHARACTER['MainCharacter'])
end

function Guildbook.GetMainSpecIsPvp()
    if GUILDBOOK_CHARACTER['MainSpecIsPvP'] == true then
        return 1
    else
        return 0
    end
end

function Guildbook.GetOffSpecIsPvp()
    if GUILDBOOK_CHARACTER['OffSpecIsPvP'] == true then
        return 1
    else
        return 0
    end
end

function Guildbook.GetAttunements()
    local d = ''
    if GUILDBOOK_CHARACTER['Attunements'] then
        for instance, v in pairs(GUILDBOOK_CHARACTER['Attunements']) do
            if d ~= '' then
                d = tostring(d..':')
            end
            if v == true then
                d = tostring(instance..':1')
            else
                d = tostring(instance..':0')
            end
        end
    end
    return d
end

function Guildbook.RemoveTableDuplicates(t)
    local uid, uids = '', {}
    for k, v in ipairs(t) do
        table.insert(uids, tostring(v['ItemID']..v['MapZoneName']..v['SourceName']..v['MapZonePosX']..v['MapZonePosY']))
    end
    local hash = {} --why hash? google this
    for i = 1, #uids do
        if not hash[uids[i]] then
            hash[uids[i]] = true
        end
    end

end

function Guildbook.CompareTables(t1, t2)
    local uid = ''
    if type(t1) ~= 'table' then
        DEBUG('table compare 1st table type error')
        return
    elseif type(t2) ~= 'table' then
        DEBUG('table compare 2nd table type error')
        return
    elseif type(t1) == 'table' and type(t2) == 'table' then
        for k, v in ipairs(t1) do
            if not t2[k] then 
                DEBUG('table 1 key: '..k..' doesn\'t exist in table 2')
                return false
            elseif v ~= t2[k] then
                DEBUG('non matching table value found')
                return false
            else
                uid = tostring(uid..v)
            end
        end
    end
    DEBUG('tables match')
    return true
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

function Guildbook.ParseGuildRoster()
	GuildRoster()
	local t = {}
	local totalMembers, onlineMembers, _ = GetNumGuildMembers()
	for i = 1, totalMembers do
		local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
		if isOnline == 1 then
			DEBUG('added: '..name..' to ')
			table.insert(t, { Name = name, Level = tonumber(level), Zone = zone, RankName = rankName, RankIndex = tonumber(rankIndex), Class = class:upper(), PublicNote = publicNote, OfficerNote = officerNote, Online = isOnline })
		end
    end
    return t
end

function Guildbook.IsNodeInRange(myPosX, myPosY, nodePosX, nodePosY, range)
	if type(nodePosX) == 'number' and type(nodePosY) == 'number' and type(myPosY) == 'number' and type(myPosX) == 'number' then
		local distance = (((myPosX - nodePosX)^2.0) + ((myPosY - nodePosY)^2.0)) ^ 0.5
		distance = distance * 100
		if distance < range then -- query this value ?
			return true, distance
		else
			return false
		end
	end
end

function Guildbook.GetItemIdFromLink(link)
    local l = string.sub(tostring(link), (string.find(link, '|Hitem')), (string.find(link, '|h')))
    local t, i = {}, 1
    for d in string.gmatch(l, '[^:]+') do
        t[i] = d
        i = i + 1
    end
    return tonumber(t[2])
end

function Guildbook.PrintPlayerXP()
	local xp = UnitXP('player')
	local xpmx = UnitXPMax('player')
	local xpr = GetXPExhaustion()
	if xpr == nil then xpr = 0 end
	return ('This Level: '..string.format("%.2f", (xp/xpmx) * 100)..'%'..' XP To Ding: '..tonumber(xpmx-xp)..' Rested XP: '..tonumber(xpr))
end

function Guildbook.ScanKeys()
    Guildbook.Bags.PlayerKeys = {}
    for i = 1, GetContainerNumSlots(-2) do
        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(-2, i)
        tinsert(Guildbook.Bags.PlayerKeys, { ItemID = itemID })
    end
end



function Guildbook.GetDateFormatted(dateObj)
	if not dateObj then
		if IsWindowsClient() then
			return date("%d %B %Y")
		elseif IsLinuxClient() then
			return date("%a %b %d")
		end
	else
		if IsWindowsClient() then
			return date("%d %B %Y", time(dateObj))
		elseif IsLinuxClient() then
			return date("%a %b %d", time(dateObj))
		end
	end
end

function Guildbook.GetTimeFormatted(dateObj)
	if not dateObj then
		if IsWindowsClient() then
			return date('%H:%M:%S')
		elseif IsLinuxClient() then
			return date('%H:%M:%S')
		end
	else
		if IsWindowsClient() then
			return date('%H:%M:%S', time(dateObj))
		elseif IsLinuxClient() then
			return date('%H:%M:%S', time(dateObj))
		end
	end
end
--[==[

OLD ADDON CODE FROM FIRST CLASSIC GUILD ADDON

function GHC.Functions.GuildBankStart(money)
    if IsInGuild('player') and GetGuildInfo('player') then
        local guildName, rankName, rankIndex, _ = GetGuildInfo('player')
        GhcDb[guildName].GuildBank = {} -- wipe old bank data GetCoinTextureString
        GHC.UI.GuildBankParentFrame.Header:SetText('Guild Bank - '..GetCoinTextureString(money))
    end
end

function GHC.Functions.ScanGuildBank()
    if IsInGuild('player') and GetGuildInfo('player') then
        local guildName, rankName, rankIndex, _ = GetGuildInfo('player')
        if rankIndex == 0 or rankIndex == 1 then
            local gbMoney = GetMoney()
            local sent = C_ChatInfo.SendAddonMessage('ghc-gbdata-s', tostring(gbMoney), "GUILD")
            local gb = {}
            local c = 0
            local ds = nil
            --scan basic bank slots in 2 sections (1-14) (15-28)
            for i = 1, 14 do                
                local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(-1, i)
                if itemLink then
                    if ds == nil then
                        ds = tostring(itemID..':'..itemCount)
                    else
                        ds = tostring(ds..':'..itemID..':'..itemCount)
                    end
                    c = c + 1
                end
            end
            if ds ~= nil then
                local sent = C_ChatInfo.SendAddonMessage('ghc-gbdata', ds, "GUILD")
            end
            ds = nil
            for i = 15, 28 do
                local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(-1, i)
                if itemLink then
                    if ds == nil then
                        ds = tostring(itemID..':'..itemCount)
                    else
                        ds = tostring(ds..':'..itemID..':'..itemCount)
                    end
                    c = c + 1
                end
            end
            if ds ~= nil then
                local sent = C_ChatInfo.SendAddonMessage('ghc-gbdata', ds, "GUILD")
            end
            ds = nil

            --scan additional bags in bank slots
            for b = 5, 11 do
                for s = 1, GetContainerNumSlots(b) do
                    local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(b, s)
                    if itemLink then
                        if ds == nil then
                            ds = tostring(itemID..':'..itemCount)
                        else
                            ds = tostring(ds..':'..itemID..':'..itemCount)
                        end
                        c = c + 1
                    end
                end
                if ds ~= nil then
                    local sent = C_ChatInfo.SendAddonMessage('ghc-gbdata', ds, "GUILD")
                end
                ds = nil
            end

            --scan character bags
            for bag = 0, 4 do
                for s = 1, GetContainerNumSlots(bag) do
                    local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, s)
                    if itemLink then
                        if ds == nil then
                            ds = tostring(itemID..':'..itemCount)
                        else
                            ds = tostring(ds..':'..itemID..':'..itemCount)
                        end
                        c = c + 1
                    end
                end
                --print(ds)
                if ds ~= nil then
                    local sent = C_ChatInfo.SendAddonMessage('ghc-gbdata', ds, "GUILD")
                end
                ds = nil
            end
        end
    end
end

function GHC.Functions.ParseGuildBankData(dataString)
    if dataString then
        if IsInGuild('player') and GetGuildInfo('player') then
            local guildName, rankName, rankIndex, _ = GetGuildInfo('player')
            local i = 1
            --local dataSent = {}
            if GhcDb[guildName].GuildBank == nil then
                GhcDb[guildName].GuildBank = {}
            end
            local t = {} -- reuse local table
            for d in string.gmatch(dataString, '[^:]+') do            
                if not (tonumber(i) % 2 == 0) then
                    t = {} -- wipe old table for new data
                    t.ID = d
                    --print('odd number, creating table adding item id')
                else
                    t.Count = d
                    t.Type = select(6, GetItemInfo(t.ID))
                    table.insert(GhcDb[guildName].GuildBank, t)
                    --print('even number, adding count')
                end
                i = i + 1
                --table.insert(GhcDb[guildName].GuildBank, t)
            end
        GHC.Functions.UpdateGuildBankGridView(1)
        end
    end

end
]==]--
