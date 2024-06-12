local addonName, addon = ...;

local Database = addon.Database;
local Character = addon.Character;
local Talents = addon.Talents;
local Tradeskills = addon.Tradeskills;

addon.characterDefaults = {
    guid = "",
    name = "",
    class = 3,
    gender = 1,
    level = 1,
    race = false,
    rank = 1,
    onlineStatus = {
        isOnline = false,
        zone = "",
    },
    alts = {},
    mainCharacter = false,
    publicNote = "",
    mainSpec = false,
    offSpec = false,
    mainSpecIsPvP = false,
    offSpecIsPvP = false,
    profile = {},
    profession1 = "-",
    profession1Level = 0,
    profession1Spec = false,
    profession1Recipes = {},
    profession2 = "-",
    profession2Level = 0,
    profession2Spec = false,
    profession2Recipes = {},
    cookingLevel = 0,
    cookingRecipes = {},
    fishingLevel = 0,
    firstAidLevel = 0,
    firstAidRecipes = {},
    talents = {},
    glyphs = {},
    inventory = {
        current = {},
    },
    paperDollStats = {
        current = {},
    },
    resistances = {
        current = {},
    },
    auras = {
        current = {},
    },
    containers = {},
    lockouts = {},
}

addon.contextMenuSeparator = {
    hasArrow = false;
    dist = 0;
    text = "",
    isTitle = true;
    isUninteractable = true;
    notCheckable = true;
    iconOnly = true;
    icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
    tCoordLeft = 0;
    tCoordRight = 1;
    tCoordTop = 0;
    tCoordBottom = 1;
    tSizeX = 0;
    tSizeY = 8;
    tFitDropDownSizeX = true;
    iconInfo = {
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
        tSizeX = 0,
        tSizeY = 8,
        tFitDropDownSizeX = true
    }}

--create these at addon level
addon.thisCharacter = "";
addon.thisGuild = false;
addon.guilds = {}
addon.characters = {}
addon.contextMenu = CreateFrame("Frame", "GuildbookContextMenu", UIParent, "UIDropDownMenuTemplate")

addon.recruitment = {
    statusIDs = {
        [0] = "Imported",
        [1] = "Invite sent",
        [2] = "Invite responded",
        [3] = "",
        [4] = "",
    }
}

addon.api = {
    classic = {},
    wrath = {},
    cata = {},
}

local debugTypeIcons = {
    warning = "services-icon-warning",
    info = "glueannouncementpopup-icon-info",
    comms = "chatframe-button-icon-voicechat",
    comms_in = "voicechat-channellist-icon-headphone-on",
    comms_out = "voicechat-icon-textchat-silenced",
    bank = "ShipMissionIcon-Treasure-Mission",
    tradeskills = "Mobile-Alchemy",
}

local debugTypeIDs = {
    warning = 1,
    info = 2,
    comms = 3,
    comms_in = 4,
    comms_out = 5,
    bank = 6,
    tradeskills = 7,
    character = 8,
}

addon.paperDollSlotNames = {    
    ["CharacterHeadSlot"] = { allignment = "right", slotID = 1, },
    ["CharacterNeckSlot"] = { allignment = "right", slotID = 2, },
    ["CharacterShoulderSlot"] = { allignment = "right", slotID = 3, },
    ["CharacterBackSlot"] = { allignment = "right", slotID = 15, },
    ["CharacterChestSlot"] = { allignment = "right", slotID = 5, },
    ["CharacterShirtSlot"] = { allignment = "right", slotID = 4, },
    ["CharacterTabardSlot"] = { allignment = "right", slotID = 19, },
    ["CharacterWristSlot"] = { allignment = "right", slotID = 9, },

    ["CharacterHandsSlot"] = { allignment = "left", slotID = 10, },
    ["CharacterWaistSlot"] = { allignment = "left", slotID = 6, },
    ["CharacterLegsSlot"] = { allignment = "left", slotID = 7, },
    ["CharacterFeetSlot"] = { allignment = "left", slotID = 8, },
    ["CharacterFinger0Slot"] = { allignment = "left", slotID = 11, },
    ["CharacterFinger1Slot"] = { allignment = "left", slotID = 12, },
    ["CharacterTrinket0Slot"] = { allignment = "left", slotID = 13, },
    ["CharacterTrinket1Slot"] = { allignment = "left", slotID = 14, },

    ["CharacterMainHandSlot"] = { allignment = "top", slotID = 16, },
    ["CharacterSecondaryHandSlot"] = { allignment = "top", slotID = 17, },
    ["CharacterRangedSlot"] = { allignment = "top", slotID = 18, },
}

addon.itemQualityAtlas = {
    [2] = "bags-glow-green",
    [3] = "bags-glow-blue",
    [4] = "bags-glow-purple",
    [5] = "bags-glow-orange",

    -- [2] = "loottab-set-itemborder-green",
    -- [3] = "loottab-set-itemborder-blue",
    -- [4] = "loottab-set-itemborder-purple",
    -- [5] = "loottab-set-itemborder-orange",
}

local paperdollOverlays = {}
function addon.api.updatePaperdollOverlays()

    if Database:GetConfig("enhancedPaperDoll") == false then
        addon.api.hidePaperdollOverlays()
        return
    end

    local minItemLevel, maxItemLevel = 0, 0;

    for frame, info in pairs(addon.paperDollSlotNames) do
        if not paperdollOverlays[frame] then
            local border = _G[frame]:CreateTexture(nil, "BORDER", nil, 7)
            border:SetAllPoints()
            border:SetAlpha(0.7)

            local label = _G[frame]:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            if info.allignment == "right" then
                label:SetPoint("LEFT", _G[frame], "RIGHT", 10, 0)
            elseif info.allignment == "left" then
                label:SetPoint("RIGHT", _G[frame], "LEFT", -10, 0)
            else
                label:SetPoint("BOTTOM", _G[frame], "TOP", 0, 10)
            end

            paperdollOverlays[frame] = {
                border = border,
                label = label,
            }
        end

        local link = GetInventoryItemLink("player", info.slotID)
        if link then
            local _, _, quality, itemLevel = GetItemInfo(link)

            if minItemLevel == 0 then
                minItemLevel = itemLevel
            else
                if itemLevel < minItemLevel then
                    minItemLevel = itemLevel
                end
            end
            if maxItemLevel == 0 then
                maxItemLevel = itemLevel
            else
                if itemLevel > maxItemLevel then
                    maxItemLevel = itemLevel
                end
            end

            paperdollOverlays[frame].itemLevel = itemLevel;
            paperdollOverlays[frame].itemQuality = quality;

        else
            paperdollOverlays[frame].itemLevel = false;
            paperdollOverlays[frame].itemQuality = false;
        end
    end

    local itemLevelGap = maxItemLevel - minItemLevel;

    for f, info in pairs(paperdollOverlays) do

        info.label:Hide()
        info.border:Hide()

        if type(info.itemLevel) == "number" then
            local r, g, b = addon.api.getcolourGradientFromPercent(((info.itemLevel - minItemLevel) / itemLevelGap) * 100)
            info.label:SetText(info.itemLevel)
            info.label:SetTextColor(r,g,b,1)
            info.label:Show()
        end

        if type(info.itemQuality) == "number" and info.itemQuality > 1 then
            info.border:SetAtlas(addon.itemQualityAtlas[info.itemQuality])
            info.border:Show()
        end
    end

end

function addon.api.hidePaperdollOverlays()
    for f, info in pairs(paperdollOverlays) do
        info.label:Hide()
        info.border:Hide()
    end
end

function addon.api.getcolourGradientFromPercent(percent)
    local r = (percent > 50 and 1 - 2 * (percent - 50) / 100.0 or 1.0);
    local g = (percent > 50 and 1.0 or 2 * percent / 100.0);
    local b = 0.0;

    return r, g, b;
end

function addon.LogDebugMessage(debugType, debugMessage, debugTooltip)

    if not addon.debugMessages then
        addon.debugMessages = {}
    end

    if GuildbookUI and Database.db.debug then
        if debugTooltip then
            table.insert(addon.debugMessages, {
                debugTypeID = debugTypeIDs[debugType] or 1,
                label = string.format("[%s] %s", date("%T"), debugMessage),
                atlas = debugTypeIcons[debugType],
                onMouseEnter = function()
                    GameTooltip:SetOwner(GuildbookUI, "ANCHOR_TOPLEFT")
                    GameTooltip:AddDoubleLine("Version", debugTooltip.version)
                    -- for k, v in ipairs(debugTooltip.payload) do
                    --     GameTooltip:AddDoubleLine(k, v)
                    -- end
                    for k, v in pairs(debugTooltip.payload) do
                        GameTooltip:AddDoubleLine(k, v)
                    end
                    if type(debugTooltip.payload.data) == "table" then
                        -- for k, v in ipairs(debugTooltip.payload.data) do
                        --     GameTooltip:AddDoubleLine(k, v)
                        -- end
                        for k, v in pairs(debugTooltip.payload.data) do
                            GameTooltip:AddDoubleLine(k, v)
                        end
                    end
                    GameTooltip:Show()
                end,
                onMouseDown = function()
                    DevTools_Dump(debugTooltip)
                end,
            })
        else
            table.insert(addon.debugMessages, {
                debugTypeID = debugTypeIDs[debugType] or 1,
                label = string.format("[%s] %s", date("%T"), debugMessage),
                atlas = debugTypeIcons[debugType],
            })
        end

        addon:TriggerEvent("LogDebugMessage")
    end
end

function addon.api.getTradeskillItemDataFromID(itemID)
    for k, v in ipairs(addon.itemData) do
        if v.itemID == itemID then
            return v;
        end
    end
    return false;
end

function addon.api.getTradeskillItemsUsingReagentItemID(itemID, prof1, prof2)
    local t = {}
    for k, v in ipairs(addon.itemData) do
        for id, count in pairs(v.reagents) do
            if id == itemID then
                if prof1 == nil and prof2 == nil then
                    if not t[v.tradeskillID] then
                        t[v.tradeskillID] = {}
                    end
                    table.insert(t[v.tradeskillID], v)
                else
                    if prof1 and (v.tradeskillID == prof1) then
                        if not t[v.tradeskillID] then
                            t[v.tradeskillID] = {}
                        end
                        table.insert(t[v.tradeskillID], v)
                    end
                    if prof2 and (v.tradeskillID == prof2) then
                        if not t[v.tradeskillID] then
                            t[v.tradeskillID] = {}
                        end
                        table.insert(t[v.tradeskillID], v)
                    end
                end
            end
        end
    end
    return t;
end

--taken from blizz to use for classic
function addon.api.extractLink(text)
    -- linkType: |H([^:]*): matches everything that's not a colon, up to the first colon.
    -- linkOptions: ([^|]*)|h matches everything that's not a |, up to the first |h.
    -- displayText: (.*)|h matches everything up to the second |h.
    -- Ex: |cffffffff|Htype:a:b:c:d|htext|h|r becomes type, a:b:c:d, text
    return string.match(text, [[|H([^:]*):([^|]*)|h(.*)|h]]);
end

function addon.api.makeTableUnique(t)
    
    local temp, ret = {}, {}
    for k, v in ipairs(t) do
        temp[v] = true
    end
    for k, v in pairs(temp) do
        table.insert(ret, k)
    end
    return ret;
end

function addon.api.trimTable(tab, num, reverse)

    if type(tab) == "table" then
        
        local t = {}
        if reverse then
            for i = #tab, (#tab - num), -1 do
                table.insert(t, tab[i])
            end

        else
            for i = 1, num do
                table.insert(t, tab[i])
            end
        end

        tab = nil;
        return t;
    end
end

function addon.api.trimNumber(num)
    if type(num) == 'number' then
        local trimmed = string.format("%.1f", num)
        return tonumber(trimmed)
    else
        return 1
    end
end

function addon.api.characterIsMine(name)
    if Database.db.myCharacters[name] == true or Database.db.myCharacters[name] == false then
        return true;
    end
    return false;
end

function addon.api.scanForTradeskillSpec()
    local t = {}
    for i = 1, GetNumSpellTabs() do
        local offset, numSlots = select(3, GetSpellTabInfo(i))
        for j = offset+1, offset+numSlots do
            --local start, duration, enabled, modRate = GetSpellCooldown(j, BOOKTYPE_SPELL)
            --local spellLink, _ = GetSpellLink(j, BOOKTYPE_SPELL)
            local _, spellID = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
           
            if Tradeskills.SpecializationSpellsIDs[spellID] then
                table.insert(t, {
                    tradeskillID = Tradeskills.SpecializationSpellsIDs[spellID],
                    spellID = spellID,
                })
            end

        end
    end
    return t;
end


function addon.api.wrath.getPlayerEquipment()
    local sets = C_EquipmentSet.GetEquipmentSetIDs();

    local equipment = {
        sets = {},
        current = {},
    };

    for k, v in ipairs(sets) do
        
        local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(v)

        local setItemIDs = C_EquipmentSet.GetItemIDs(setID)

        equipment.sets[name] = setItemIDs;
    end


    --lets grab the current gear
    local t = {}
    for k, v in ipairs(addon.data.inventorySlots) do
        local link = GetInventoryItemLink('player', GetInventorySlotInfo(v.slot)) or false
        if link ~= nil then
            t[v.slot] = link;
        end
    end
    equipment.current = t;

    return equipment;
end

function addon.api.wrath.getPlayerEquipmentCurrent()
    local t = {}
    for k, v in ipairs(addon.data.inventorySlots) do
        local link = GetInventoryItemLink('player', GetInventorySlotInfo(v.slot)) or false
        if link ~= nil then
            t[v.slot] = link;
        end
    end

    return t;
end

function addon.api.getPlayerItemLevel()
    local itemLevel, itemCount = 0, 0
	for k, v in ipairs(addon.data.inventorySlots) do
		local link = GetInventoryItemLink('player', GetInventorySlotInfo(v.slot)) or false
		if link then
			local _, _, _, ilvl = GetItemInfo(link)
            if not ilvl then ilvl = 0 end
			itemLevel = itemLevel + ilvl
			itemCount = itemCount + 1
		end
    end
    -- due to an error with LibSerialize which is now fixed we make sure we return a number
    if math.floor(itemLevel/itemCount) > 0 then
        return addon.api.trimNumber(itemLevel/itemCount)
    else
        return 0
    end
end

function addon.api.getPlayerSkillLevels()
    local skills = {}
    for s = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(s)
        if skill and (type(level) == "number") then
            local tradeskillId = Tradeskills:GetTradeskillIDFromLocale(skill)
            if tradeskillId then
                skills[tradeskillId] = level
            end
        end
    end
    return skills;
end

function addon.api.cata.getProfessions()
    local t = {}
    for k, prof in pairs({GetProfessions()}) do
        if type(prof) == "number" then
            local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine = GetProfessionInfo(prof)
            if Tradeskills:IsTradeskill(nil, skillLine) then
                t[skillLine] = skillLevel;
            end
        end
    end
    --addon.LogDebugMessage("tradeskills", "function [addon.api.cata.getProfessions]", {version = -1, payload = t})
    return t;
end

function addon.api.getGuildRosterIndex(nameOrGUID)
    if IsInGuild() and GetGuildInfo("player") then
        GuildRoster()
        local totalMembers, onlineMember, _ = GetNumGuildMembers()
        for i = 1, totalMembers do
            local name, rankName, rankIndex, level, _, zone, publicNote, officerNote, isOnline, status, class, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            if nameOrGUID == name or nameOrGUID == guid then
                return i
            end
        end
    end
end

function addon.api.getPlayerAlts(main)
    if type(main) == "string" and main ~= "" then
        local alts = {}
        if addon.characters and addon.characters then
            for name, character in pairs(addon.characters) do
                if character.data.mainCharacter == main then
                    table.insert(alts, name)
                end
            end
        end
        return alts;
    end
    return {}
end

function addon.api.scanPlayerContainers(includeBanks)

    local copper = GetMoney()

    local containers = {
        bags = {
            slotsUsed = 0,
            slotsFree = 0,
            items = {},
        },
        bank = {
            slotsUsed = 0,
            slotsFree = 0,
            items = {},
        },
        copper = copper,
    }

    -- player bags
    for bag = 0, 4 do
        local numSlots;
        if C_Container then
            numSlots = C_Container.GetContainerNumSlots(bag);
        else
            numSlots = GetContainerNumSlots(bag);
        end
        local slotsUsed = 0;
        for slot = 1, numSlots do
            local itemID, stackCount;

            --make this work for both version although 1.14.4 is only maybe a few weeks away
            if C_Container then
                local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
                if containerInfo then
                    itemID = containerInfo.itemID;
                    stackCount = containerInfo.stackCount;
                end
            else
                local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
                itemID = id;
                stackCount = count;
            end

            if (type(itemID) == "number") and (type(stackCount) == "number") then
                table.insert(containers.bags.items, {
                    id = itemID,
                    count = stackCount,
                })
                slotsUsed = slotsUsed + 1;
            end
        end

        containers.bags.slotsUsed = containers.bags.slotsUsed + slotsUsed;
        containers.bags.slotsFree = containers.bags.slotsFree + (numSlots - slotsUsed);
    end

    if includeBanks then
        -- main bank
        local bankBagId = -1
        local numSlots;
        if C_Container then
            numSlots = C_Container.GetContainerNumSlots(bankBagId);
        else
            numSlots = GetContainerNumSlots(bankBagId);
        end
        local slotsUsed = 0;
        for slot = 1, numSlots do
            local itemID, stackCount;
            if C_Container then
                local containerInfo = C_Container.GetContainerItemInfo(bankBagId, slot)
                if containerInfo then
                    itemID = containerInfo.itemID;
                    stackCount = containerInfo.stackCount;
                end
            else
                local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bankBagId, slot)
                itemID = id;
                stackCount = count;
            end

            if (type(itemID) == "number") and (type(stackCount) == "number") then
                table.insert(containers.bags.items, {
                    id = itemID,
                    count = stackCount,
                })
                slotsUsed = slotsUsed + 1;
            end
        end
        containers.bank.slotsUsed = containers.bank.slotsUsed + slotsUsed;
        containers.bank.slotsFree = containers.bank.slotsFree + (numSlots - slotsUsed);

        -- bank bags
        for bag = 5, 11 do
            local numSlots;
            if C_Container then
                numSlots = C_Container.GetContainerNumSlots(bag);
            else
                numSlots = GetContainerNumSlots(bag);
            end
            local slotsUsed = 0;
            for slot = 1, numSlots do
                local itemID, stackCount;
                if C_Container then
                    local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
                    if containerInfo then
                        itemID = containerInfo.itemID;
                        stackCount = containerInfo.stackCount;
                    end
                else
                    local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
                    itemID = id;
                    stackCount = count;
                end
    
                if (type(itemID) == "number") and (type(stackCount) == "number") then
                    table.insert(containers.bags.items, {
                        id = itemID,
                        count = stackCount,
                    })
                    slotsUsed = slotsUsed + 1;
                end
            end

            containers.bank.slotsUsed = containers.bank.slotsUsed + slotsUsed;
            containers.bank.slotsFree = containers.bank.slotsFree + (numSlots - slotsUsed);
        end
    end

    return containers;
end

function addon.api.classic.getPlayerTalents()
    local talents = {}
    local tabs = {}
    for tabIndex = 1, GetNumTalentTabs() do
        local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
        local engSpec = Talents.TalentBackgroundToSpec[fileName]
        table.insert(tabs, {
            fileName = fileName,
            pointsSpent = pointsSpent,
        })
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
            local spellId = Talents:GetTalentSpellId(fileName, row, column, rank)
            table.insert(talents, {
                tabID = tabIndex,
                row = row,
                col = column,
                rank = rank,
                maxRank = maxRank,
                spellId = spellId,
            })
        end
    end
    -- find the tab with most points and set spec if not already set, the user can always change this if wrong and this will probably cause them to actually update it.
    table.sort(tabs, function(a, b)
        return a.pointsSpent > b.pointsSpent;
    end)
    return {
        tabs = tabs,
        talents = talents,
    }
end

local glyphsPopped = {}
function addon.api.wrath.getPlayerTalents(...)
    local newSpec, previousSpec = ...;

	if type(newSpec) ~= "number" then
		newSpec = GetActiveTalentGroup()
	end
	if type(newSpec) ~= "number" then
		newSpec = 1
	end

    local tabs, talents = {}, {}
    for tabIndex = 1, GetNumTalentTabs() do
        local spec, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
        local engSpec = Talents.TalentBackgroundToSpec[fileName]
        table.insert(tabs, {
            fileName = fileName,
            pointsSpent = pointsSpent,
        })
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
            local spellId = Talents:GetTalentSpellId(fileName, row, column, rank)
            table.insert(talents, {
                tabID = tabIndex,
                row = row,
                col = column,
                rank = rank,
                maxRank = maxRank,
                spellId = spellId,
            })
        end
    end

    local inGroup = IsInGroup()
    local inInstance, instanceType = IsInInstance()

    local glyphs = {}
    for i = 1, 6 do
        local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(i);
        if enabled and glyphSpellID then
            local name = GetSpellInfo(glyphSpellID) --check its a valid spell ID

            if name then
                if addon.glyphData.spellIdToItemId[glyphSpellID] then
                    local itemID = addon.glyphData.spellIdToItemId[glyphSpellID].itemID
                    local found = false
                    for k, glyph in ipairs(addon.glyphData.wrath) do
                        if glyph.itemID == itemID then
                            table.insert(glyphs, {
                                socket = i,
                                itemID = itemID,
                                classID = glyph.classID,
                                glyphType = glyph.glyphType,
                                name = name,
                            })
                            found = true
                        end
                    end
                    if not found then
                        if not inGroup and not inInstance then
                            if not glyphsPopped[glyphSpellID] then
                                local s = string.format("[%s] unable to find glyph itemID for %s with GlyphSpellID of %d", addonName, name, glyphSpellID)
                                StaticPopup_Show("GuildbookReport", s)
                                glyphsPopped[glyphSpellID] = true
                            end
                        end
                    end
                else
                    if not inGroup and not inInstance then
                        if not glyphsPopped[glyphSpellID] then
                            local s = string.format("[%s] glyph data for %s with GlyphSpellID of %d missing from lookup table", addonName, name, glyphSpellID)
                            StaticPopup_Show("GuildbookReport", s)
                            glyphsPopped[glyphSpellID] = true
                        end
                    end
                end
            end
        end
    end

    return newSpec, tabs, talents, glyphs;

    -- if newSpec == 1 then
    --     self:TriggerEvent("OnPlayerTalentSpecChanged", "primary", talents, glyphs)
    -- elseif newSpec == 2 then
    --     self:TriggerEvent("OnPlayerTalentSpecChanged", "secondary", talents, glyphs)
    -- end

    --DevTools_Dump({glyphs})
    --DisplayTableInspectorWindow({glyphs = glyphs});

end


--[[
    ---Create a talent data string using the wowhead hyphen format
function ModernTalentsMixin:SaveTalentPreviewLoadout()

    local trees = {
        [1] = "",
        [2] = "",
        [3] = "",
    }
    local treeIndex = 0
    self:IterTalentTreesOrdered(function(f)
        if f.rowId == 1 and f.colId == 1 then
            treeIndex = treeIndex + 1
        end
        if f.talentIndex then
            trees[treeIndex] = string.format("%s%s", trees[treeIndex], f.previewRank or 0)
        end
    end)
    local s = string.format("%s-%s-%s", trees[1], trees[2], trees[3])

    StaticPopup_Show("ModernTalentsSaveLoadoutDialog", "Name", nil, {
        callback = function(name)
            local _, _, class = UnitClass("player")
            table.insert(self.db.account.talentLoadouts, {
                name = name,
                class = class,
                loadout = s,
            })
            self:InitializeTalentTabDropdown()
        end
    })

end
]]

function addon.api.cata.getPlayerTalents(...)
    local newSpec, previousSpec = ...;

	if type(newSpec) ~= "number" then
		newSpec = GetActiveTalentGroup()
	end
	if type(newSpec) ~= "number" then
		newSpec = 1
	end

    local tabs, talents = {}, {}
    for tabIndex = 1, GetNumTalentTabs() do
        local id, name, description, icon, pointsSpent, fileName, previewPointsSpent, isUnlocked = GetTalentTabInfo(tabIndex)
        --print(id, name, fileName)
        local engSpec = Talents.TalentBackgroundToSpec[fileName]
        table.insert(tabs, {
            fileName = fileName,
            pointsSpent = pointsSpent,
        })
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local _name, iconTexture, row, column, rank, maxRank, isExceptional, available, unKnown, isActive, y, talentID = GetTalentInfo(tabIndex, talentIndex)
            local spellId = Talents:GetTalentSpellId(fileName, row, column, rank, id)
            table.insert(talents, {
                tabID = tabIndex,
                row = row,
                col = column,
                rank = rank,
                maxRank = maxRank,
                spellId = spellId,
            })
        end
    end

    local inGroup = IsInGroup()
    local inInstance, instanceType = IsInInstance()

    local glyphs = {}
    for i = 1, 9 do
        --DevTools_Dump({GetGlyphSocketInfo(i)})
        local enabled, glyphType, glyphIndex, glyphSpellID, icon = GetGlyphSocketInfo(i);
        if enabled and glyphSpellID then
            
            table.insert(glyphs, {
                spellID = glyphSpellID,
                glyphType = glyphType,
                glyphIndex = glyphIndex,
            })

            --[[
            local name = GetSpellInfo(glyphSpellID) --check its a valid spell ID
            if name then
                if addon.glyphData.spellIdToItemId[glyphSpellID] then
                    local itemID = addon.glyphData.spellIdToItemId[glyphSpellID].itemID
                    local found = false
                    for k, glyph in ipairs(addon.glyphData.wrath) do
                        if glyph.itemID == itemID then
                            table.insert(glyphs, {
                                socket = i,
                                itemID = itemID,
                                classID = glyph.classID,
                                glyphType = glyph.glyphType,
                                name = name,
                            })
                            found = true
                        end
                    end
                    if not found then
                        if not inGroup and not inInstance then
                            if not glyphsPopped[glyphSpellID] then
                                local s = string.format("[%s] unable to find glyph itemID for %s with GlyphSpellID of %d", addonName, name, glyphSpellID)
                                StaticPopup_Show("GuildbookReport", s)
                                glyphsPopped[glyphSpellID] = true
                            end
                        end
                    end
                else
                    if not inGroup and not inInstance then
                        if not glyphsPopped[glyphSpellID] then
                            local s = string.format("[%s] glyph data for %s with GlyphSpellID of %d missing from lookup table", addonName, name, glyphSpellID)
                            StaticPopup_Show("GuildbookReport", s)
                            glyphsPopped[glyphSpellID] = true
                        end
                    end
                end
            end
            ]]
        end
    end

    return newSpec, tabs, talents, glyphs;

    -- if newSpec == 1 then
    --     self:TriggerEvent("OnPlayerTalentSpecChanged", "primary", talents, glyphs)
    -- elseif newSpec == 2 then
    --     self:TriggerEvent("OnPlayerTalentSpecChanged", "secondary", talents, glyphs)
    -- end

    --DevTools_Dump({glyphs})
    --DisplayTableInspectorWindow({glyphs = glyphs});

end

function addon.api.getPlayerAuras()
    local buffs = {}
    for i = 1, 40 do
        local name, icon, count, dispellType, duration, expirationTime, source, isStealable, _, spellId = UnitAura("player", i)
        if name then
            table.insert(buffs, {
                spellId = spellId,
                expirationTime = expirationTime,
                count = count,
            })
        end
    end
    return buffs;
end

local resistanceIDs = {
    [0] = "physical",
    [1] = "holy",
    [2] = "fire",
    [3] = "nature",
    [4] = "frost",
    [5] = "shadow",
    [6] = "arcane",
}
function addon.api.getPlayerResistances(level)
    local res = {}
    -- res.physical = addon.api.trimNumber(ResistancePercent(0,level))
    -- res.holy = addon.api.trimNumber(ResistancePercent(1,level))
    -- res.fire = addon.api.trimNumber(ResistancePercent(2,level))
    -- res.nature = addon.api.trimNumber(ResistancePercent(3,level))
    -- res.frost = addon.api.trimNumber(ResistancePercent(4,level))
    -- res.shadow = addon.api.trimNumber(ResistancePercent(5,level))
    -- res.arcane = addon.api.trimNumber(ResistancePercent(6,level))

    for i = 0, 6 do
        local base, total, bonus, minus = UnitResistance("player", i)
        res[resistanceIDs[i]] = {
            base = base,
            total = total,
            bonus = bonus,
            minus = minus,
        }
    end

    return res;
end

local spellSchools = {
    [2] = 'Holy',
    [3] = 'Fire',
    [4] = 'Nature',
    [5] = 'Frost',
    [6] = 'Shadow',
    [7] = 'Arcane',
}
local statIDs = {
    [1] = 'Strength',
    [2] = 'Agility',
    [3] = 'Stamina',
    [4] = 'Intellect',
    [5] = 'Spirit',
}
function addon.api.classic.getPaperDollStats()

    local stats = {
        attributes = {},
        defence = {},
        melee = {},
        ranged = {},
        spell = {},
    }

    local numSkills = GetNumSkillLines();
    local skillIndex = 0;
    local currentHeader = nil;

    for i = 1, numSkills do
        local skillName = select(1, GetSkillLineInfo(i));
        local isHeader = select(2, GetSkillLineInfo(i));

        if isHeader ~= nil and isHeader then
            currentHeader = skillName;
        else
            if (currentHeader == "Weapon Skills" and skillName == 'Defense') then
                skillIndex = i;
                break;
            end
        end
    end

    local baseDef, modDef;
    if (skillIndex > 0) then
        baseDef = select(4, GetSkillLineInfo(skillIndex));
        modDef = select(6, GetSkillLineInfo(skillIndex));
    else
        baseDef, modDef = UnitDefense('player')
    end

    local posBuff = 0;
    local negBuff = 0;
    if ( modDef > 0 ) then
        posBuff = modDef;
    elseif ( modDef < 0 ) then
        negBuff = modDef;
    end
    stats.defence.Defence = {
        Base = addon.api.trimNumber(baseDef),
        Mod = addon.api.trimNumber(modDef),
    }

    local baseArmor, effectiveArmor, armr, posBuff, negBuff = UnitArmor('player');
    stats.defence.Armor = addon.api.trimNumber(baseArmor)
    stats.defence.Block = addon.api.trimNumber(GetBlockChance());
    stats.defence.Parry = addon.api.trimNumber(GetParryChance());
    stats.defence.ShieldBlock = addon.api.trimNumber(GetShieldBlock());
    stats.defence.Dodge = addon.api.trimNumber(GetDodgeChance());

    --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
    --local base, casting = GetManaRegen();
    stats.spell.SpellHit = 0 -- addon.api.trimNumber(GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier());
    stats.melee.MeleeHit = 0 --addon.api.trimNumber(GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier());
    stats.ranged.RangedHit = 0 -- addon.api.trimNumber(GetCombatRatingBonus(CR_HIT_RANGED));

    stats.ranged.RangedCrit = addon.api.trimNumber(GetRangedCritChance());
    stats.melee.MeleeCrit = addon.api.trimNumber(GetCritChance());

    stats.spell.Haste = addon.api.trimNumber(GetHaste());
    stats.melee.Haste = addon.api.trimNumber(GetMeleeHaste());
    stats.ranged.Haste = addon.api.trimNumber(GetRangedHaste());

    local base, casting = GetManaRegen()
    stats.spell.ManaRegen = base and addon.api.trimNumber(base) or 0;
    stats.spell.ManaRegenCasting = casting and addon.api.trimNumber(casting) or 0;

    local minCrit = 100
    for id, school in pairs(spellSchools) do
        if GetSpellCritChance(id) < minCrit then
            minCrit = GetSpellCritChance(id)
        end
        stats.spell['SpellDmg'..school] = addon.api.trimNumber(GetSpellBonusDamage(id));
        stats.spell['SpellCrit'..school] = addon.api.trimNumber(GetSpellCritChance(id));
    end
    stats.spell.SpellCrit = addon.api.trimNumber(minCrit)

    stats.spell.HealingBonus = addon.api.trimNumber(GetSpellBonusHealing());

    local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
    local mainSpeed, offSpeed = UnitAttackSpeed("player");
    local mlow = (lowDmg + posBuff + negBuff) * percentmod
    local mhigh = (hiDmg + posBuff + negBuff) * percentmod
    local olow = (offlowDmg + posBuff + negBuff) * percentmod
    local ohigh = (offhiDmg + posBuff + negBuff) * percentmod
    if mainSpeed < 1 then mainSpeed = 1 end
    if mlow < 1 then mlow = 1 end
    if mhigh < 1 then mhigh = 1 end
    if olow < 1 then olow = 1 end
    if ohigh < 1 then ohigh = 1 end

    if offSpeed then
        if offSpeed < 1 then 
            offSpeed = 1
        end
        stats.melee.MeleeDmgOH = addon.api.trimNumber((olow + ohigh) / 2.0)
        stats.melee.MeleeDpsOH = addon.api.trimNumber(((olow + ohigh) / 2.0) / offSpeed)
    else
        --offSpeed = 1
        stats.melee.MeleeDmgOH = addon.api.trimNumber(0)
        stats.melee.MeleeDpsOH = addon.api.trimNumber(0)
    end
    stats.melee.MeleeDmgMH = addon.api.trimNumber((mlow + mhigh) / 2.0)
    stats.melee.MeleeDpsMH = addon.api.trimNumber(((mlow + mhigh) / 2.0) / mainSpeed)

    local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
    local low = (lowDmg + posBuff + negBuff) * percent
    local high = (hiDmg + posBuff + negBuff) * percent
    if speed < 1 then speed = 1 end
    if low < 1 then low = 1 end
    if high < 1 then high = 1 end
    local dmg = (low + high) / 2.0
    stats.ranged.RangedDmg = addon.api.trimNumber(dmg)
    stats.ranged.RangedDps = addon.api.trimNumber(dmg/speed)

    local base, posBuff, negBuff = UnitAttackPower('player')
    stats.melee.AttackPower = addon.api.trimNumber(base + posBuff + negBuff)

    for k, stat in pairs(statIDs) do
        local a, b, c, d = UnitStat("player", k);
        stats.attributes[stat] = addon.api.trimNumber(b)
    end

    return stats;
end
function addon.api.wrath.getPaperDollStats()

    local stats = {
        attributes = {},
        defence = {},
        melee = {},
        ranged = {},
        spell = {},
    }

    ---go through getting each stat value
    local numSkills = GetNumSkillLines();
    local skillIndex = 0;
    local currentHeader = nil;

    for i = 1, numSkills do
        local skillName = select(1, GetSkillLineInfo(i));
        local isHeader = select(2, GetSkillLineInfo(i));

        if isHeader ~= nil and isHeader then
            currentHeader = skillName;
        else
            if (currentHeader == "Weapon Skills" and skillName == 'Defense') then
                skillIndex = i;
                break;
            end
        end
    end

    local baseDef, modDef;
    if (skillIndex > 0) then
        baseDef = select(4, GetSkillLineInfo(skillIndex));
        modDef = select(6, GetSkillLineInfo(skillIndex));
    else
        baseDef, modDef = UnitDefense('player')
    end

    local posBuff = 0;
    local negBuff = 0;
    if ( modDef > 0 ) then
        posBuff = modDef;
    elseif ( modDef < 0 ) then
        negBuff = modDef;
    end
    stats.defence.Defence = {
        Base = addon.api.trimNumber(baseDef),
        Mod = addon.api.trimNumber(modDef),
    }

    local baseArmor, effectiveArmor, armr, posBuff, negBuff = UnitArmor('player');
    stats.defence.Armor = addon.api.trimNumber(baseArmor)
    stats.defence.Block = addon.api.trimNumber(GetBlockChance());
    stats.defence.Parry = addon.api.trimNumber(GetParryChance());
    stats.defence.ShieldBlock = addon.api.trimNumber(GetShieldBlock());
    stats.defence.Dodge = addon.api.trimNumber(GetDodgeChance());

    --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
    --stats.Expertise = addon.api.trimNumber(GetExpertise()); --will display mainhand expertise but it stores offhand expertise as well, need to find a way to access it
    --local base, casting = GetManaRegen();

    stats.spell.SpellHit = addon.api.trimNumber(GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier());
    stats.melee.MeleeHit = addon.api.trimNumber(GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier());
    stats.ranged.RangedHit = addon.api.trimNumber(GetCombatRatingBonus(CR_HIT_RANGED));

    stats.ranged.RangedCrit = addon.api.trimNumber(GetRangedCritChance());
    stats.melee.MeleeCrit = addon.api.trimNumber(GetCritChance());

    stats.spell.Haste = addon.api.trimNumber(GetCombatRatingBonus(20));
    local base, casting = GetManaRegen()
    base = base*5;
    casting = casting*5;
    stats.spell.ManaRegen = base and addon.api.trimNumber(base) or 0;
    stats.spell.ManaRegenCasting = casting and addon.api.trimNumber(casting) or 0;

    local minCrit = 100
    for id, school in pairs(spellSchools) do
        if GetSpellCritChance(id) < minCrit then
            minCrit = GetSpellCritChance(id)
        end
        stats.spell['SpellDmg'..school] = addon.api.trimNumber(GetSpellBonusDamage(id));
        stats.spell['SpellCrit'..school] = addon.api.trimNumber(GetSpellCritChance(id));
    end
    stats.spell.SpellCrit = addon.api.trimNumber(minCrit)

    stats.spell.HealingBonus = addon.api.trimNumber(GetSpellBonusHealing());

    local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
    local mainSpeed, offSpeed = UnitAttackSpeed("player");
    local mlow = (lowDmg + posBuff + negBuff) * percentmod
    local mhigh = (hiDmg + posBuff + negBuff) * percentmod
    local olow = (offlowDmg + posBuff + negBuff) * percentmod
    local ohigh = (offhiDmg + posBuff + negBuff) * percentmod
    if mainSpeed < 1 then mainSpeed = 1 end
    if mlow < 1 then mlow = 1 end
    if mhigh < 1 then mhigh = 1 end
    if olow < 1 then olow = 1 end
    if ohigh < 1 then ohigh = 1 end

    if offSpeed then
        if offSpeed < 1 then 
            offSpeed = 1
        end
        stats.melee.MeleeDmgOH = addon.api.trimNumber((olow + ohigh) / 2.0)
        stats.melee.MeleeDpsOH = addon.api.trimNumber(((olow + ohigh) / 2.0) / offSpeed)
    else
        --offSpeed = 1
        stats.melee.MeleeDmgOH = addon.api.trimNumber(0)
        stats.melee.MeleeDpsOH = addon.api.trimNumber(0)
    end
    stats.melee.MeleeDmgMH = addon.api.trimNumber((mlow + mhigh) / 2.0)
    stats.melee.MeleeDpsMH = addon.api.trimNumber(((mlow + mhigh) / 2.0) / mainSpeed)

    local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
    local low = (lowDmg + posBuff + negBuff) * percent
    local high = (hiDmg + posBuff + negBuff) * percent
    if speed < 1 then speed = 1 end
    if low < 1 then low = 1 end
    if high < 1 then high = 1 end
    local dmg = (low + high) / 2.0
    stats.ranged.RangedDmg = addon.api.trimNumber(dmg)
    stats.ranged.RangedDps = addon.api.trimNumber(dmg/speed)

    local base, posBuff, negBuff = UnitAttackPower('player')
    stats.melee.AttackPower = addon.api.trimNumber(base + posBuff + negBuff)

    for k, stat in pairs(statIDs) do
        local a, b, c, d = UnitStat("player", k);
        stats.attributes[stat] = addon.api.trimNumber(b)
    end

	--ViragDevTool:AddData(stats, "Guildbook_CharStats_"..equipmentSetName)

	--addon:TriggerEvent("OnPlayerStatsChanged", equipmentSetName, stats)

    return stats;
end

function addon.api.classic.getPlayerEquipment()
    local equipment = {}
    for k, v in ipairs(addon.data.inventorySlots) do
        local link = GetInventoryItemLink('player', GetInventorySlotInfo(v.slot)) or false
        equipment[v.slot] = link
    end
    return equipment;
end

function addon.api.getDaysInMonth(month, year)
    local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    local d = days_in_month[month]
    -- check for leap year
    if (month == 2) then
        if year % 4 == 0 then
            if year % 100 == 0 then
                if year % 400 == 0 then
                    d = 29
                end
            else
                d = 29
            end
        end
    end
    return d
end


function addon.api.getLockouts()
    local t = {}
    local numSavedInstances = GetNumSavedInstances()
    if numSavedInstances > 0 then
        for i = 1, numSavedInstances do
            --t[i] = {GetSavedInstanceInfo(i)}
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)

            reset = (GetServerTime() + reset);

            table.insert(t, {
                name = name,
                id = id,
                reset = reset,
                difficulty = difficulty,
                locked = locked,
                extended = extended,
                instanceIDMostSig = instanceIDMostSig,
                isRaid = isRaid,
                maxPlayers = maxPlayers,
                difficultyName = difficultyName,
                numEncounters = numEncounters,
                encounterProgress = encounterProgress,
            })
            --local msg = string.format("name=%s, id=%s, reset=%s, difficulty=%s, locked=%s, numEncounters=%s", tostring(name), tostring(id), tostring(reset), tostring(difficulty), tostring(locked), tostring(numEncounters))
            --print(msg)
        end
    end
    return t
end


function addon.api.generateExportMenu(character)

    local menu = {
        {
            text = character:GetName(true),
            isTitle = true,
            notCheckable = true,
        }
    }
    table.insert(menu, addon.contextMenuSeparator)
    table.insert(menu, {
        text = "Export",
        isTitle = true,
        notCheckable = true,
    })

    local specInfo = character:GetSpecInfo()

    if specInfo then

        local primarySpec, secondarySpec = specInfo.primary[1].id, specInfo.secondary[1].id

        local exportEquipMenu1 = {{
            text = "Select Gear",
            isTitle = true,
            notCheckable = true,
        },}
        local exportEquipMenu2 = {{
            text = "Select Gear",
            isTitle = true,
            notCheckable = true,
        },}
        for setname, info in pairs(character.data.inventory) do
            table.insert(exportEquipMenu1, {
                text = setname,
                notCheckable = true,
                func = function()
                    addon:TriggerEvent("Character_ExportEquipment", character, setname, "primary")
                end,
            })
            table.insert(exportEquipMenu2, {
                text = setname,
                notCheckable = true,
                func = function()
                    addon:TriggerEvent("Character_ExportEquipment", character, setname, "secondary")
                end,
            })
        end
    
        if primarySpec then
            local atlas, spec = character:GetClassSpecAtlasName(primarySpec)
            table.insert(menu, {
                text = string.format("%s %s", CreateAtlasMarkup(atlas, 16, 16), spec),
                notCheckable = true,
                hasArrow = true,
                menuList = exportEquipMenu1,
    
            })
        end
        if secondarySpec then
            local atlas, spec = character:GetClassSpecAtlasName(secondarySpec)
            table.insert(menu, {
                text = string.format("%s %s", CreateAtlasMarkup(atlas, 16, 16), spec),
                notCheckable = true,
                hasArrow = true,
                menuList = exportEquipMenu2,
    
            })
        end

    end
    return menu;
end





addon.data = {}
addon.data.inventorySlots = {
    {
        slot = "HEADSLOT",
        icon = 136516,
    },
    {
        slot = "NECKSLOT",
        icon = 136519,
    },
    {
        slot = "SHOULDERSLOT",
        icon = 136526,
    },
    {
        slot = "SHIRTSLOT",
        icon = 136525,
    },
    {
        slot = "CHESTSLOT",
        icon = 136512,
    },
    {
        slot = "WAISTSLOT",
        icon = 136529,
    },
    {
        slot = "LEGSSLOT",
        icon = 136517,
    },
    {
        slot = "FEETSLOT",
        icon = 136513,
    },
    {
        slot = "WRISTSLOT",
        icon = 136530,
    },
    {
        slot = "HANDSSLOT",
        icon = 136515,
    },
    {
        slot = "FINGER0SLOT",
        icon = 136514,
    },
    {
        slot = "FINGER1SLOT",
        icon = 136523,
    },
    {
        slot = "TRINKET0SLOT",
        icon = 136528,
    },
    {
        slot = "TRINKET1SLOT",
        icon = 136528,
    },
    {
        slot = "BACKSLOT",
        icon = 136521,
    },
    {
        slot = "MAINHANDSLOT",
        icon = 136518,
    },
    {
        slot = "SECONDARYHANDSLOT",
        icon = 136524,
    },
    {
        slot = "RANGEDSLOT",
        icon = 136520,
    },
    {
        slot = "TABARDSLOT",
        icon = 136527,
    },
    -- {
    --     slot = "RELICSLOT",
    --     icon = 136522,
    -- },
}







-- Guildbook = {
--     enabled = false,
-- }

-- addon:RegisterCallback("Database_OnInitialised", Guildbook.SetEnabled, Guildbook)

