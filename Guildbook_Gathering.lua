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

--guild frame member detail frame extension
--adds spec and prof data to the detail frame

local addonName, Guildbook = ...

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG
local PRINT = Guildbook.PRINT
--might be used in future updates
--local tinsert, tsort = table.insert, table.sort
--local ceil, floor = math.ceil, math.floor 

local HBD = LibStub("HereBeDragons-2.0")
local Pins = LibStub("HereBeDragons-Pins-2.0")

Guildbook.Gathering = {
    GatheringObjectKeys = { 'ItemID', 'ItemName', 'SourceName', 'SourceGUID', 'MapID', 'MapZoneName', 'MapZonePosX', 'MapZonePosY' },
    WorldMapSourceGUIDsCache = {},
    WMinimapSourceGUIDsCache = {},
    MinimapIconsCache = {},
    WorldMapIconsCache = {},
}

--scans the loot window, adds item data to saved table and sends chat message to guild members
function Guildbook.Gathering.ScanLoot()
    DEBUG('scanning loot window')
    local mapID = C_Map.GetBestMapForUnit('player')
    if mapID ~= nil then
        local currentMapPosition = C_Map.GetPlayerMapPosition(mapID, 'player')
        local currentMapName = C_Map.GetMapInfo(mapID).name
        if currentMapPosition.x and currentMapPosition.y then
            for i = 1, GetNumLootItems() do
                if (LootSlotHasItem(i)) and (GetLootSlotType(i) == 1) then
                    local link = GetLootSlotLink(i)
                    local sourceGUID, _ = GetLootSourceInfo(i)
                    local name = select(1, GetItemInfo(link))
                    if string.find(name, ':') then
                        name = string.gsub(name, ':', '') --remove any : 
                    end
                    local sourceName = 'Unknown'
                    local ignoreLoot = false            
                    if string.find(sourceGUID, 'GameObject') then
                        DEBUG('loot is game object')
                        sourceName = Guildbook.LastTarget --can cause issues where player gathers but then changes target ?
                        if IsFishingLoot() then
                            sourceName = 'Fishing'
                        end          
                        if string.find(sourceName, ':') then
                            sourceName = string.gsub(sourceName, ':', '') --remove any : 
                        end              
                        if not next(GUILDBOOK_GAMEOBJECTS) then
                            DEBUG('first table object')
                            tinsert(GUILDBOOK_GAMEOBJECTS, { 
                                ItemID = Guildbook.GetItemIdFromLink(link), 
                                ItemName = name, 
                                ItemLink = link, 
                                SourceName = sourceName, 
                                SourceGUID = sourceGUID, 
                                MapID = mapID, 
                                MapZoneName = currentMapName, 
                                MapZonePosX = currentMapPosition.x, 
                                MapZonePosY = currentMapPosition.y 
                            })
                        else
                            DEBUG('not first table object')
                            for k, obj in ipairs(GUILDBOOK_GAMEOBJECTS) do
                                if (obj.MapZoneName == currentMapName) and (obj.SourceName == sourceName) then
                                    local inRange, distance = Guildbook.IsNodeInRange(currentMapPosition.x, currentMapPosition.y, obj.MapZonePosX, obj.MapZonePosY, 0.25)
                                    if distance then
                                        DEBUG('in range '..tostring(inRange)..' - distance '..distance)
                                    end
                                    if inRange == true then
                                        ignoreLoot = true
                                        DEBUG('in range')
                                    end
                                end
                            end
                            if ignoreLoot == false then
                                DEBUG('adding new object')
                                tinsert(GUILDBOOK_GAMEOBJECTS, { 
                                    ItemID = Guildbook.GetItemIdFromLink(link), 
                                    ItemName = name, 
                                    ItemLink = link, 
                                    SourceName = sourceName, 
                                    SourceGUID = sourceGUID, 
                                    MapID = mapID, 
                                    MapZoneName = currentMapName, 
                                    MapZonePosX = currentMapPosition.x, 
                                    MapZonePosY = currentMapPosition.y 
                                })
                            end
                        end
                        local data = tostring(Guildbook.GetItemIdFromLink(link)..':'..name..':'..sourceName..':'..sourceGUID..':'..mapID..':'..currentMapName..':'..currentMapPosition.x..':'..currentMapPosition.y)
                        local requestSent = C_ChatInfo.SendAddonMessage('gb-gat-data', data, 'GUILD')
                    end
                end
            end
            Guildbook.Gathering.UpdateMapGatheringIcons()
            Guildbook.Gathering.UpdateWorldMapGatheringIcons()
        end
    end
end

--parse the gathering chat messages
function Guildbook.Gathering.ParseGatheringData(showMessage, ...)
    local msg = select(2, ...)
    local sender = select(5, ...)
    DEBUG('receieved loot data: '..msg..' from '..sender)
    local i, t = 1, {} 
    for d in string.gmatch(msg, '[^:]+') do
        t[Guildbook.Gathering.GatheringObjectKeys[i]] = d
        i = i + 1
    end
    local ignoreLoot = false
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        for k, obj in ipairs(GUILDBOOK_GAMEOBJECTS) do
            if (tonumber(obj.MapID) == tonumber(t['MapID'])) and (obj.SourceName == t['SourceName']) then                
                local inRange, distance = Guildbook.IsNodeInRange(tonumber(t['MapZonePosX']), tonumber(t['MapZonePosY']), obj.MapZonePosX, obj.MapZonePosY, 0.25)
                if inRange == true then
                    if tonumber(obj.ItemID) == tonumber(t['ItemID']) then
                        ignoreLoot = true
                        DEBUG('game object already known - itemID match: '..t['ItemName'])
                    else
                        DEBUG('game object already known - new item detected: '..t['ItemName'])
                    end
                end
            end
        end
    end
    if ignoreLoot == false then
        DEBUG('new gathering item to add to table')
        local item = Item:CreateFromItemID(tonumber(t['ItemID']))
        item:ContinueOnItemLoad(function()
            DEBUG('server data reply for item query: '..t['ItemName'])
            local link = item:GetItemLink()
            DEBUG('adding loot: '..t['ItemName']..' to game object table'..' from '..sender)
            tinsert(GUILDBOOK_GAMEOBJECTS, { ItemID = tonumber(t['ItemID']), ItemName = t['ItemName'], ItemLink = link, SourceName = t['SourceName'], SourceGUID = t['SourceGUID'], MapID = tonumber(t['MapID']), MapZoneName = t['MapZoneName'], MapZonePosX = tonumber(t['MapZonePosX']), MapZonePosY = tonumber(t['MapZonePosY']) })
            if showMessage == true then
                PRINT(Guildbook.FONT_COLOUR, tostring('recieved gathering data of '..link..' from '..sender))
            end
            Guildbook.OptionsInterface.GatheringDatabase.RefreshListView()
        end)
    end
end


--loop gathering table to create a dict of game object sources using first letters to sort
function Guildbook.Gathering.CreateGatheringDict()
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        local dict, keys, i = {}, {}, 1
        for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
            local l = string.sub(gameObject.SourceName, 1, 1)
            if not dict[l] then --table for this letter does not exist
                dict[l] = {} --create table for letter
                tinsert(dict[l], gameObject) --add object to table
                keys[i] = l --add letter to keys table, used to sort alphabetically
                i = i + 1
            else --if letter exists in dict then check for dupes
                local exists = false
                for j, object in ipairs(dict[l]) do --loop the letter dict
                    if object.SourceName == gameObject.SourceName then
                        exists = true
                    end
                end
                if exists == false then
                    tinsert(dict[l], gameObject)
                end
            end
        end
        table.sort(keys) --sort the key table to produce alphabetical menu order
        return keys, dict
    end
end

--generate the context menu for the minimap button to select game objects to show in map
function GuildbookGameObjectDropDown_Init()
    UIDropDownMenu_Initialize(Guildbook.MinimapGatheringMenu, function(self, level, menuList)
        local keys, dict = Guildbook.Gathering.CreateGatheringDict()
        if keys then
            local info = UIDropDownMenu_CreateInfo()
            if (level or 1) == 1 then
                UIDropDownMenu_AddButton({
                    isTitle = true,
                    notCheckable = true,
                    text = '|cffFF7D0AGuildbook|r'
                })
                UIDropDownMenu_AddButton({
                    isTitle = true,
                    notCheckable = true,
                    text = '|cffffffffGathering Menu'
                })
                for k, l in pairs(keys) do
                    info.text = l
                    info.hasArrow = true
                    info.notCheckable = true
                    info.menuList = dict[l]
                    UIDropDownMenu_AddButton(info)
                end
            else
                for k, object in ipairs(menuList) do
                    info.text = object.SourceName --using the source name reduces clutter, for example stone and ore both drop from veins but we only need to get the vein location
                    info.isNotRadio = true
                    info.keepShownOnClick = true
                    info.checked = GUILDBOOK_CHARACTER['GatheringToDisplay'][object.SourceName]
                    --info.icon = nil
                    info.func = function()
                        if not GUILDBOOK_CHARACTER['GatheringToDisplay'] then
                            GUILDBOOK_CHARACTER['GatheringToDisplay'] = {}
                        end
                        GUILDBOOK_CHARACTER['GatheringToDisplay'][object.SourceName] = not GUILDBOOK_CHARACTER['GatheringToDisplay'][object.SourceName]
                        if GUILDBOOK_CHARACTER['GatheringToDisplay'][object.SourceName] == true then
                            PRINT(Guildbook.FONT_COLOUR, tostring('now displaying data for '..object.SourceName..' map locations'))
                        else
                            PRINT(Guildbook.FONT_COLOUR, tostring('stopped displaying data for '..object.SourceName..' map locations'))
                        end
                        Guildbook.Gathering.UpdateMapGatheringIcons()
                        Guildbook.Gathering.UpdateWorldMapGatheringIcons()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
	end, "MENU")
end

Guildbook.Gathering.MinimapGatheringIconsCache = {}
Guildbook.Gathering.WorldmapGatheringIconsCache = {}

function Guildbook.Gathering.ClearGatheringIcons()
    if next(Guildbook.Gathering.MinimapGatheringIconsCache) then
        for k, v in ipairs(Guildbook.Gathering.MinimapGatheringIconsCache) do
            v:Hide()
        end
    end
    if next(Guildbook.Gathering.WorldmapGatheringIconsCache) then
        for k, v in ipairs(Guildbook.Gathering.WorldmapGatheringIconsCache) do
            v:Hide()
        end
    end
end


function Guildbook.Gathering.GetGameObjectDrops(obj)
	local drops = {}
	for k, loot in ipairs(GUILDBOOK_GAMEOBJECTS) do
		local inRange, distance = Guildbook.IsNodeInRange(obj.MapZonePosX, obj.MapZonePosY, loot.MapZonePosX, loot.MapZonePosY, 0.25)
		if (inRange == true) and (string.find(loot.SourceGUID, 'GameObject')) then
			table.insert(drops, loot)
		end
    end
    table.sort(drops, function(a, b) return a.ItemName < b.ItemName end)
	return drops
end

function Guildbook.Gathering.UpdateWorldMapGatheringIcons(mapID)
    if 1 == 1 then
        if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
            --Pins:RemoveAllWorldMapIcons("GuildbookGatheringWorldmapIcons")
            if not GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] then
                GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] = 8.0
            end
            local cacheIndex = 1
            --local sourceGUIDs = {}
            Guildbook.Gathering.WorldMapSourceGUIDsCache = {}
            for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
                if not mapID then
                    mapID = WorldMapFrame:GetMapID()
                end
                if (gameObject.MapID == mapID) and (GUILDBOOK_CHARACTER['GatheringToDisplay'][gameObject.SourceName] == true) then
                    if not Guildbook.Gathering.WorldMapSourceGUIDsCache[gameObject.SourceGUID] then
                        local icon = select(10, GetItemInfo(tonumber(gameObject['ItemID'])))
                        local gameObjectPosX, gameObjectPosY, mapInstance = HBD:GetWorldCoordinatesFromZone(gameObject.MapZonePosX, gameObject.MapZonePosY, gameObject.MapID)
                        if Guildbook.Gathering.WorldmapGatheringIconsCache[cacheIndex] == nil then
                            DEBUG('creating new icon - index = '..cacheIndex)
                            local worldmapIcon = CreateFrame('FRAME', tostring('GuildbookGatheringWorldmapIcon'..cacheIndex), UIParent)
                            worldmapIcon:SetSize(tonumber(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize']), tonumber(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize']))
                            worldmapIcon.t = worldmapIcon:CreateTexture(nil, 'ARTWORK')
                            worldmapIcon.t:SetAllPoints(worldmapIcon)
                            worldmapIcon.t:SetTexture(icon)
                            worldmapIcon.data = gameObject
                            worldmapIcon:SetScript('OnEnter', function(self)
                                if self.data then
                                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR") 
                                    GameTooltip:AddDoubleLine(Guildbook.FONT_COLOUR.."Guildbook:|r", tostring('|cffffffff'..self.data.SourceName))
                                    local dropTable, dropAdded = Guildbook.Gathering.GetGameObjectDrops(self.data), {}
                                    for k, drop in ipairs(dropTable) do                                            
                                        if not dropAdded[drop['ItemName']] then
                                            GameTooltip:AddLine(tostring('|cffffffff'..drop['ItemName']))
                                            local icon = select(10, GetItemInfo(tonumber(drop['ItemID'])))
                                            GameTooltip:AddTexture(Guildbook.FileIDToFileName[icon], {width = 16, height = 16})
                                            dropAdded[drop['ItemName']] = true
                                        end
                                    end
                                    GameTooltip:Show()
                                end
                            end)
                            worldmapIcon:SetScript('OnLeave', function(self)
                                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                            end)
                            Pins:AddWorldMapIconWorld("GuildbookGatheringWorldmapIcons", worldmapIcon, mapInstance, gameObjectPosX, gameObjectPosY)
                            Guildbook.Gathering.WorldmapGatheringIconsCache[cacheIndex] = worldmapIcon                            
                        else
                            DEBUG('re-using worldmap icon index '..cacheIndex)
                            Guildbook.Gathering.WorldmapGatheringIconsCache[cacheIndex]:SetSize(tonumber(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize']), tonumber(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize']))
                            Guildbook.Gathering.WorldmapGatheringIconsCache[cacheIndex]:Show()
                            Guildbook.Gathering.WorldmapGatheringIconsCache[cacheIndex].t:SetTexture(icon)
                            Guildbook.Gathering.WorldmapGatheringIconsCache[cacheIndex].data = gameObject
                            Pins:AddWorldMapIconWorld("GuildbookGatheringWorldmapIcons", Guildbook.Gathering.WorldmapGatheringIconsCache[cacheIndex], mapInstance, gameObjectPosX, gameObjectPosY)
                        end
                        cacheIndex = cacheIndex + 1
                    end
                    Guildbook.Gathering.WorldMapSourceGUIDsCache[gameObject.SourceGUID] = true
                end
            end
        end
    end
end

--update minimap gathering icons
function Guildbook.Gathering.UpdateMapGatheringIcons()
    if 1 == 1 then --toggle display minimap icons setting to be made
        if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then --make sure table has entries
            --Pins:RemoveAllMinimapIcons("GuildbookGatheringMinimapIcons")
            if not GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] then
                GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] = 8.0
            end
            local mapID = C_Map.GetBestMapForUnit('player')
            if mapID then
                local mapName = C_Map.GetMapInfo(mapID).name
                local minimapIconCacheIndex = 1
                --local sourceGUIDs = {}
                Guildbook.Gathering.MinimapSourceGUIDsCache = {}
                for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
                    if not Guildbook.Gathering.MinimapSourceGUIDsCache[gameObject.SourceGUID] then --check this game object guid hasn't been created already
                        local icon = select(10, GetItemInfo(tonumber(gameObject['ItemID'])))
                        local gameObjectPosX, gameObjectPosY, mapInstance = HBD:GetWorldCoordinatesFromZone(gameObject.MapZonePosX, gameObject.MapZonePosY, gameObject.MapID)
                        if (gameObject.MapZoneName == C_Map.GetMapInfo(mapID).name) and GUILDBOOK_CHARACTER['GatheringToDisplay'][gameObject.SourceName] == true then
                            if not Guildbook.Gathering.MinimapGatheringIconsCache[minimapIconCacheIndex] then
                                DEBUG('creating minimap icons for '..gameObject.SourceName)
                                DEBUG('creating new icon - index = '..minimapIconCacheIndex)
                                local minimapIcon = CreateFrame('FRAME', tostring('GuildbookGatheringMinimapIcon'..minimapIconCacheIndex), UIParent)
                                minimapIcon:SetSize(tonumber(GUILDBOOK_CHARACTER['MinimapGatheringIconSize']), tonumber(GUILDBOOK_CHARACTER['MinimapGatheringIconSize']))
                                minimapIcon.t = minimapIcon:CreateTexture(nil, 'ARTWORK')
                                minimapIcon.t:SetAllPoints(minimapIcon)
                                minimapIcon.t:SetTexture(icon)
                                minimapIcon.data = gameObject
                                minimapIcon:SetScript('OnEnter', function(self)
                                    if self.data then
                                        GameTooltip:SetOwner(self, "ANCHOR_CURSOR") 
                                        GameTooltip:AddDoubleLine(Guildbook.FONT_COLOUR.."Guildbook:|r", tostring('|cffffffff'..self.data.SourceName))
                                        local dropTable, dropAdded = Guildbook.Gathering.GetGameObjectDrops(self.data), {}
                                        for k, drop in ipairs(dropTable) do                                            
                                            if not dropAdded[drop['ItemName']] then
                                                GameTooltip:AddLine(tostring('|cffffffff'..drop['ItemName']))
                                                local icon = select(10, GetItemInfo(tonumber(drop['ItemID'])))
                                                GameTooltip:AddTexture(Guildbook.FileIDToFileName[icon], {width = 16, height = 16})
                                                dropAdded[drop['ItemName']] = true
                                            end
                                        end
                                        GameTooltip:Show()
                                    end
                                end)
                                minimapIcon:SetScript('OnLeave', function(self)
                                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                                end)
                                Pins:AddMinimapIconWorld("GuildbookGatheringMinimapIcons", minimapIcon, mapInstance, gameObjectPosX, gameObjectPosY, false)
                                Guildbook.Gathering.MinimapGatheringIconsCache[minimapIconCacheIndex] = minimapIcon                                
                                minimapIconCacheIndex = minimapIconCacheIndex + 1
                            else
                                DEBUG('re-using minimap icon index '..minimapIconCacheIndex)
                                Guildbook.Gathering.MinimapGatheringIconsCache[minimapIconCacheIndex]:SetSize(tonumber(GUILDBOOK_CHARACTER['MinimapGatheringIconSize']), tonumber(GUILDBOOK_CHARACTER['MinimapGatheringIconSize']))
                                Guildbook.Gathering.MinimapGatheringIconsCache[minimapIconCacheIndex]:Show()
                                Guildbook.Gathering.MinimapGatheringIconsCache[minimapIconCacheIndex].t:SetTexture(icon)
                                Guildbook.Gathering.MinimapGatheringIconsCache[minimapIconCacheIndex].data = gameObject
                                Pins:AddMinimapIconWorld("GuildbookGatheringMinimapIcons", Guildbook.Gathering.MinimapGatheringIconsCache[minimapIconCacheIndex], mapInstance, gameObjectPosX, gameObjectPosY, false)
                                minimapIconCacheIndex = minimapIconCacheIndex + 1
                            end
                        end
                        Guildbook.Gathering.MinimapSourceGUIDsCache[gameObject.SourceGUID] = true
                    end
                end
            end
        end
    end
end
