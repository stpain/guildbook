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


function Guildbook.PrintPlayerXP()
	local xp = UnitXP('player')
	local xpmx = UnitXPMax('player')
	local xpr = GetXPExhaustion()
	if xpr == nil then xpr = 0 end
	return ('This Level: '..string.format("%.2f", (xp/xpmx) * 100)..'%'..' XP To Ding: '..tonumber(xpmx-xp)..' Rested XP: '..tonumber(xpr))
end
