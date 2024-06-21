

local addonName, addon = ...;
local L = addon.Locales;
local Database = addon.Database;

--[[
    this started as an instance item viewer but then it grew to more
]]

GuildbookInstancesMixin = {
    name = "Instances",
    helptips = {},
    treeviewNodes = {},
    itemSetsLoaded = false,
}

--https://warcraft.wiki.gg/wiki/API_EJ_GetEncounterInfo

local instances = {
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    184,
    185,
    186,
    187,
}

function GuildbookInstancesMixin:OnLoad()

    self.lists.newList.ok:SetScript("OnClick", function(b)
        local text = self.lists.newList:GetText()
        if text ~= " " then
            if Database.db and Database.db.itemLists then
                local id = time()
                table.insert(Database.db.itemLists, {
                    name = text,
                    items = {},
                    id = id,
                    character = addon.thisCharacter,
                })
                self.lists.listDropdown:SetText(text)
                self:LoadListDropdown()
                self:LoadListItems(Database.db.itemLists[#Database.db.itemLists])
                self.lists.newList:SetText("")
                self.lists.newList:ClearFocus()
            end
        end
    end)

    --addon:RegisterCallback("Database_OnItemListChanged", self.Database_OnItemListChanged, self)
    addon:RegisterCallback("Database_OnInitialised", self.Database_OnInitialised, self)
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
    addon:RegisterCallback("Tradeskill_OnItemAddedToList", self.Tradeskill_OnItemAddedToList, self)
    addon:RegisterCallback("Database_OnItemListItemRemoved", self.Database_OnItemListItemRemoved, self)
    addon:RegisterCallback("Loot_OnItemAvailable", self.Loot_OnItemAvailable, self)


    self.lists:ClearAllPoints()
    self.lists:SetPoint("TOPLEFT", self.listview, "TOPRIGHT", 6, 0)
    self.lists:SetPoint("BOTTOMRIGHT", -4, 6)

    self.lists.listItemsGridview:InitFramePool("FRAME", "GuildbookWrathEraItemIconFrame")
    self.lists.listItemsGridview:SetMinMaxSize(50,70)
    self.lists.listItemsGridview.ScrollBar:Hide()

    self.lists.listItemsGridview.scrollChild:EnableMouse()
    self.lists.listItemsGridview.scrollChild:HookScript("OnEnter", function(f)

        local info, itemID = GetCursorInfo()
        ClearCursor()
        if info == "item" and type(self.selectedList) == "table" then
            self:AddItemToList(itemID, self.selectedList)
            self.lists.listItemsGridview:Insert(itemID)
        end
    end)


    --ITEM_LISTS_SOURCE_HELPTIP    
    self.helptipItemsSource:SetText(L.ITEM_LISTS_SOURCE_HELPTIP)
    self.helptipItemsLists:SetText(L.ITEM_LISTS_LISTS_HELPTIP)

    table.insert(self.helptips, self.helptipItemsSource)
    table.insert(self.helptips, self.helptipItemsLists)


    self.lists.deleteList:SetScript("OnClick", function()
        if self.selectedList then
            local keyToRemove;
            for k, v in ipairs(Database.db.itemLists) do
                if v.id == self.selectedList.id then
                    keyToRemove = k
                end
            end
            if keyToRemove then
                table.remove(Database.db.itemLists, keyToRemove)
                self.lists.listItemsGridview:Flush()
                self:LoadListDropdown()
            end
        end
    end)

    self.lists.addItem.ok:SetScript("OnClick", function()
        if self.selectedList then
            local text = self.lists.addItem:GetText()
            if type(tonumber(text)) == "number" then
                self:AddItemToList(tonumber(text), self.selectedList)
                self:LoadListItems(self.selectedList)
                self.lists.addItem:SetText("")
            else
                if text:find("|Hitem:", nil, true) then
                    local itemID = GetItemInfoInstant(text)
                    if itemID then
                        self:AddItemToList(itemID, self.selectedList)
                        self:LoadListItems(self.selectedList)
                        self.lists.addItem:SetText("")
                    end
                else
                    self.lists.addItem:SetText("Error")
                end
            end
        end
    end)

        
    self.itemTypeFilterID = nil;
    self.itemSubTypeFilterID = nil;

    local function setItemTypesMenu()
        local itemTypeMenu = {}
        for name, id in pairs(Enum.ItemClass) do
            local label = GetItemClassInfo(id)
            if label and #label > 0 then
                itemTypeMenu[id] = {
                    text = label,
                    func = function()
                        self.itemTypeFilterID = id;
    
                        local instanceData, numItems = self:GetFilteredInstanceData()
                        self:BuildInstanceTreeview(instanceData, numItems)
    
                        local maxnumSubTypes = 20;
                        local t = {}
                        for i = 1, maxnumSubTypes do
                            local label = GetItemSubClassInfo(id, i)
                            if label and #label > 0 then
                                table.insert(t, {
                                    text = label,
                                    func = function()
                                        self.itemTypeFilterID = id;
                                        self.itemSubTypeFilterID = i;
    
                                        local instanceData, numItems = self:GetFilteredInstanceData()
                                        self:BuildInstanceTreeview(instanceData, numItems)
                                    end,
                                })
                            end
                        end
    
                        self.itemSubTypeFilterDropdown:SetMenu(t)
                    end,
                }
            end
        end
        self.itemTypeFilterDropdown:SetMenu(itemTypeMenu)
        self.resetFilterDropdown:SetScript("OnClick", function()
            self.itemTypeFilterID = nil;
            self.itemSubTypeFilterID = nil;
    
            local instanceData, numItems = self:GetFilteredInstanceData()
            self:BuildInstanceTreeview(instanceData, numItems)
        end)

        self.itemTypeFilterDropdown:SetText("Item Type")
        self.itemSubTypeFilterDropdown:SetText("Sub Type")
    end

    
    local function setItemSetClassMenu()
        local classesAdded = {}
        local t = {}
        for i = 1, 11 do
            local class, classString, classID = GetClassInfo(i)
            if class and classID and not classesAdded[class] then
                table.insert(t, {
                    text = RAID_CLASS_COLORS[classString]:WrapTextInColorCode(class),
                    func = function()
                        self:LoadItemSetsData(classID)
                    end
                })
                classesAdded[class] = true
            end
        end
        self.itemTypeFilterDropdown:SetMenu(t)
        classesAdded = nil
    end
    

    self.sourceSelectionDropdown:SetMenu({
        {
            text = "Item sets",
            func = function()
                self.itemTypeFilterDropdown:Show()
                self.itemTypeFilterDropdown:SetText(CLASS)
                self.itemTypeFilterDropdown:EnableMouse(true)
                self.itemSubTypeFilterDropdown:Hide()
                setItemSetClassMenu()
            end,
        },
        {
            text = "Instances",
            func = function()
                self.itemTypeFilterDropdown:Show()
                self.itemSubTypeFilterDropdown:Show()

                self.itemTypeFilterID = nil;
                self.itemSubTypeFilterID = nil;

                setItemTypesMenu()
        
                local instanceData, numItems = self:GetFilteredInstanceData()
                self:BuildInstanceTreeview(instanceData, numItems)
            end,
        },
        {
            text = "Factions",
            func = function()
                self:LoadFactionItems()
                self.itemTypeFilterDropdown:Hide()
                self.itemSubTypeFilterDropdown:Hide()
            end,
        },
    })

    self.sourceSelectionDropdown:SetText(SOURCE)


    addon.AddView(self)
end

function GuildbookInstancesMixin:OnShow()

end

function GuildbookInstancesMixin:Database_OnItemListItemRemoved(f)
    if self.selectedList then
        local keyToRemove
        for k, v in ipairs(self.selectedList.items) do
            if v == f.itemID then
                keyToRemove = k
            end
        end
        if keyToRemove then
            table.remove(self.selectedList.items, keyToRemove)
            self.lists.listItemsGridview:RemoveFrame(f)
        end
    end
end

function GuildbookInstancesMixin:Tradeskill_OnItemAddedToList(itemID, list)
    self:AddItemToList(itemID, list)
    if self.selectedList and (list.id == self.selectedList.id) then
        self.lists.listItemsGridview:Insert(itemID)
    end
end

function GuildbookInstancesMixin:UpdateLayout()
    self.lists.listItemsGridview:UpdateLayout()
end

function GuildbookInstancesMixin:Database_OnInitialised()
    self:LoadListDropdown()
end

function GuildbookInstancesMixin:LoadListDropdown()
    local t = {}
    if Database.db and Database.db.itemLists then
        for k, list in ipairs(Database.db.itemLists) do
            table.insert(t, {
                text = list.name,
                func = function()
                    self:LoadListItems(list)
                end,
            })
        end
    end
    self.lists.listDropdown:SetMenu(t)
end

function GuildbookInstancesMixin:AddItemToList(itemID, list)
    if (type(itemID) == "number") and type(list) == "table" then
        table.insert(list.items, itemID)
    end
end

local scaler = 0.6;
local infoWarningIcon = CreateAtlasMarkup("QuestPortraitIcon-SandboxQuest", 33 * scaler, 55 * scaler)
local lootItems = {}
function GuildbookInstancesMixin:Loot_OnItemAvailable()

    local numItems = C_LootHistory.GetNumItems()

    if numItems > 0 then
        local lastItem = {C_LootHistory.GetItem(1)}
        local itemID = GetItemInfoInstant(lastItem[2])

        if type(itemID) == "number" then
            for k, list in ipairs(Database.db.itemLists) do
                if list.character == addon.thisCharacter then
                    for k, id in ipairs(list.items) do
                        if id == itemID then

                            if not lootItems[itemID] then
                                UIErrorsFrame:AddMessage(string.format("%s %s is on your list [%s] %s", infoWarningIcon, lastItem[2], list.name, infoWarningIcon))

                                lootItems[itemID] = true
                            end
                            

                            --make this show a frame or something
                        end
                    end
                end
            end
        end
    end


    --[[
    
    if Database.db and Database.db.itemLists then

        -- Template string
        local template = "|HlootHistory:%d|h[Loot]|h: %s"

        -- Actual formatted string
        local formattedString = msg;

        -- Define the pattern to capture the part that corresponds to %s
        -- We use %d for the number, then escape the fixed parts of the string
        -- and capture everything after the ": " which represents the %s part
        local pattern = "|HlootHistory:%d+|h%[Loot%]|h: (.+)"

        -- Use string.match to find the part of the string that matches the pattern
        local extractedLink = formattedString:match(pattern)

        if extractedLink and extractedLink:find("item:", nil, true) then
            local itemID = GetItemInfoInstant(extractedLink)
            if type(itemID) == "number" then
                for k, list in ipairs(Database.db.itemLists) do
                    if list.character == addon.thisCharacter then
                        for k, id in ipairs(list.items) do
                            if id == itemID then

                                if not lootItems[itemID] then
                                    UIErrorsFrame:AddMessage(string.format("%s %s is on your list [%s] %s", infoWarningIcon, extractedLink, list.name, infoWarningIcon))

                                    lootItems[itemID] = true
                                end
                                

                                --make this show a frame or something
                            end
                        end
                    end
                end
            end
        end

    end

    C_Timer.After(5, function()
        lootItems = {}
    end)

    -- Print the extracted part
    --print(extractedPart)  -- Output: Epic Sword

    ]]



    -- print(msg)

    -- local lootStarted = LOOT_ROLL_STARTED:gsub("%%d", "(.+)"):gsub("%%s", "(.+)");
    -- local lootStarted2 = LOOT_ROLL_STARTED:gsub("%%s", "(.+)");

    -- print(lootStarted)
    -- print(lootStarted2)

    -- local x, link = string.match(msg, lootStarted)
    -- local x2, link2 = string.match(msg, lootStarted2)

    -- print("found link", x, link)
    -- print("found link", x2, link2)


    -- local ret = false;
    -- local ticker
    -- if Database.db and Database.db.itemLists then
    --     for k, list in ipairs(Database.db.itemLists) do
    --         --print(list.name)
    --         local index = 1;
    --         ticker = C_Timer.NewTicker(0.01, function()
    --             if ret == true then
    --                 ticker:Cancel()
    --             end
    --             local item = Item:CreateFromItemID(list.items[index])
    --             if item and item:GetItemID() and not item:IsItemEmpty() then
    --                 item:ContinueOnItemLoad(function()
    --                     --print(item:GetItemName())
    --                     if itemName == item:GetItemName() then
    --                         ret = true;
    --                         return true, list.name
    --                     end
    --                 end)
    --             end
    --             index = index + 1;
    --         end, #list.items)
    --     end
    -- end
end

function GuildbookInstancesMixin:LoadListItems(list)

    self.lists.helptip:Hide()

    self.lists.listItemsGridview:Flush()

    self.selectedList = list;

    for k, v in ipairs(list.items) do
        self.lists.listItemsGridview:Insert(v)
    end

end

function GuildbookInstancesMixin:GetFilteredInstanceData()

    --create an addon wide lookup table
    if not addon.itemIDtoSource then
        addon.itemIDtoSource = {}
    end

    local t = {}
    local order = {}
    local numItems = 0;

    for k, instanceID in ipairs(instances) do
        
        local i_name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(instanceID)
        order[i_name] = instanceID
        t[i_name] = {}

        local encounters = self:GetEncountersForInstance(instanceID)
        for _, encounterID in ipairs(encounters) do
            local e_name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, _ = EJ_GetEncounterInfo(encounterID)

            t[i_name][e_name] = {}

            local items = self:GetItemsForEncounter(encounterID)

            for k, v in ipairs(items) do
                local itemID = v[3]
                --local difficulty = items[index][6]
                if type(itemID) == "number" then
                    local _, itemType, itemSubType, equipLoc, icon, classID, subClassID = GetItemInfoInstant(itemID)

                    if not addon.itemIDtoSource[itemID] then
                        addon.itemIDtoSource[itemID] = {
                            instance = i_name,
                            encounter = e_name,
                        }
                    end

                    if not self.itemTypeFilterID or (self.itemTypeFilterID == classID) then
                        if not self.itemSubTypeFilterID or (self.itemSubTypeFilterID == subClassID) then

                            table.insert(t[i_name][e_name], v)
                            numItems = numItems + 1;
                        end
                    end
                end
            end

        end
    end

    for iName, encounters in pairs(t) do
        for eName, items in pairs(encounters) do
            if #items == 0 then
                t[iName][eName] = nil
            end
        end
    end

    for iName, encounters in pairs(t) do
        if next(encounters) == nil then
            t[iName] = nil
        end
    end

    return t, numItems;
end

function GuildbookInstancesMixin:BuildInstanceTreeview(instanceData, numItems)

    --:ToggleCollapsed()
    --self.infoText:SetText("loading items")

    local function sortFunc(a, b)
        if a:GetData().difficulty and b:GetData().difficulty and a:GetData().equipLoc and a:GetData().classID and b:GetData().equipLoc and b:GetData().classID and a:GetData().subClassID and b:GetData().subClassID then
            if a:GetData().difficulty == b:GetData().difficulty then
                if a:GetData().subClassID == b:GetData().subClassID then
                    if a:GetData().classID == b:GetData().classID then
                        return a:GetData().equipLoc < b:GetData().equipLoc;
                    else
                        return a:GetData().classID > b:GetData().classID;
                    end
                else
                    return a:GetData().subClassID > b:GetData().subClassID;
                end
            else
                return a:GetData().difficulty > b:GetData().difficulty;
            end
        end
    end

    -- if self.instanceDataProvider then
    --     self.listview.scrollView:SetDataProvider(self.instanceDataProvider)
    --     return
    -- else
    --     self.instanceDataProvider = CreateTreeDataProvider()
    --     self.listview.scrollView:SetDataProvider(self.instanceDataProvider)
    -- end

    self.instanceDataProvider = CreateTreeDataProvider()
    self.listview.scrollView:SetDataProvider(self.instanceDataProvider)

    self:SetDropdownEnabled(false)

    local treeviewNodes = {}

    local itemsProcess = 1;

    for instanceName, encounters in pairs(instanceData) do
        
        --local i_name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(instanceID)

        treeviewNodes[instanceName] = self.instanceDataProvider:Insert({
            label = instanceName,
            atlas = "common-icon-forwardarrow",
            backgroundAtlas = "OBJBonusBar-Top",
            fontObject = GameFontNormal,
            isParent = true,

        })
        treeviewNodes[instanceName]:ToggleCollapsed()

        for encounterName, items in pairs(encounters) do
            --local e_name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, _ = EJ_GetEncounterInfo(encounterID)

            treeviewNodes[instanceName][encounterName] = treeviewNodes[instanceName]:Insert({
                label = encounterName,
                isParent = true,
            })
            treeviewNodes[instanceName][encounterName]:SetSortComparator(sortFunc, true, false)
            treeviewNodes[instanceName][encounterName]:ToggleCollapsed()

            --local items = self:GetItemsForEncounter(encounterName)

            if #items > 0 then
                local index = 1
                local ticker = C_Timer.NewTicker(0.01, function()
                    local itemID = items[index][3]

                    self.statusBar:SetValue(itemsProcess/numItems)
                    self.statusBar.label:SetText(string.format("%.1f %%",(itemsProcess/numItems) * 100))

                    local difficulty = items[index][6]
                    if type(itemID) == "number" then
                        local item = Item:CreateFromItemID(itemID)
                        if item and not item:IsItemEmpty() and item:GetItemID() then
                            item:ContinueOnItemLoad(function()

                                local _, itemType, itemSubType, equipLoc, icon, classID, subClassID = GetItemInfoInstant(itemID)

                                local hcPrefix = GREEN_FONT_COLOR:WrapTextInColorCode(difficulty)
                                local rightLabel = ""
                                if classID == 4 and subClassID == 0 then
                                    rightLabel = _G[equipLoc]
                                else
                                    rightLabel = _G[equipLoc] and string.format("%s\n%s", _G[equipLoc], WHITE_FONT_COLOR:WrapTextInColorCode(itemSubType)) or itemSubType
                                end

                                treeviewNodes[instanceName][encounterName]:Insert({
                                    label = hcPrefix..item:GetItemLink(),
                                    labelRight = rightLabel,
                                    link = item:GetItemLink(),

                                    init = function(f)
                                        f.labelRight:SetFontObject(GameFontNormalSmall)
                                        f:HookScript("OnMouseDown", function(_, but)
                                            if IsShiftKeyDown() then
                                                HandleModifiedItemClick(item:GetItemLink())
                                            elseif IsControlKeyDown() then
                                                DressUpItemLink(item:GetItemLink())
                                            else
                                                C_Item.PickupItem(itemID)
                                            end
                                        end)
                                    end,

                                    --sort
                                    equipLoc = _G[equipLoc],
                                    classID = classID,
                                    subClassID = subClassID,
                                    difficulty = difficulty,
                                })

                                itemsProcess = itemsProcess + 1;
                            end)
                        end
                    end

                    index = index + 1;

                    if index >= #items then
                        treeviewNodes[instanceName][encounterName]:Sort()
                        self:SetDropdownEnabled(true)
                    end

                end
                , #items)
            end

        end

    end

end

function GuildbookInstancesMixin:GetEncountersForInstance(instanceID)
    
    local t = {}

    for k, v in ipairs(addon.instanceToEncounter) do
        if v[2] == instanceID then
            table.insert(t, v[1])
        end
    end

    return t;
end

function GuildbookInstancesMixin:GetItemsForEncounter(encounterID)
    
    --id, journalEncounterID, itemID, factionMask, flgas, difficulty

    --can add flag faction checks here as well
    local t = {}
    for k, v in ipairs(addon.instanceItems) do
        if v[2] == encounterID then
            table.insert(t, v)
        end
    end

    return t;
end


local binaryToClassID = {
    [1] = 1, --                 0000000000 0000000001  
    [2] = 2, --                 0000000000 0000000010
    [4] = 3, --                 0000000000 0000000100
    [8] = 4, --                 0000000000 0000001000
    [16] = 5, --                0000000000 0000010000
    [32] = 6, --                0000000000 0000100000
    [64] = 7, --                0000000000 0001000000
    [128] = 8, --               0000000000 0010000000
    [256] = 9, --               0000000000 0100000000
    [1024] = 11, --             0000000000 1000000000
}

function GuildbookInstancesMixin:LoadItemSetsData(classID)

    self:SetDropdownEnabled(false)

    if not self.itemSetsDataProvider then
        self.itemSetsDataProvider = {}
    end

    if self.itemSetsDataProvider[classID] then
        self.listview.scrollView:SetDataProvider(self.itemSetsDataProvider[classID])
        self:SetDropdownEnabled(true)
        return
    else

        self.itemSetsDataProvider[classID] = CreateTreeDataProvider()
        self.listview.scrollView:SetDataProvider(self.itemSetsDataProvider[classID])

    end

    local function sortFuncItemLevels(a, b)
        if a:GetData().ilvl and b:GetData().ilvl then
            return a:GetData().ilvl > b:GetData().ilvl;
        end
    end

    local function sortFuncClassId(a, b)
        if a:GetData().classID and b:GetData().classID then
            return a:GetData().classID > b:GetData().classID;
        end
    end

    --self.infoText:SetText("loading items")

    -- self.listview.DataProvider = CreateTreeDataProvider()
    -- self.listview.scrollView:SetDataProvider(self.listview.DataProvider)
    
    local treeviewNodes = {}

    --itemID, setID, ilvl, class, invType, quality


    local setIndex = 1;
    local ticker = C_Timer.NewTicker(0.005, function()
        local info = addon.itemSetsData[setIndex]

        if info then

            self.statusBar:SetValue(setIndex/#addon.itemSetsData)
            self.statusBar.label:SetText(string.format("%.1f %%", (setIndex/#addon.itemSetsData) * 100))

            if not classID or (classID and (classID == binaryToClassID[info[4]])) then

                local class, classString = "All Classes", nil
                if info[4] > 0 then
                    class, classString = GetClassInfo(binaryToClassID[info[4]])
                    if RAID_CLASS_COLORS[classString] then
                        class = RAID_CLASS_COLORS[classString]:WrapTextInColorCode(class)
                    end
                end
                
                if not treeviewNodes[class] then
                    treeviewNodes[class] = self.itemSetsDataProvider[classID]:Insert({

                        --sort
                        classID = binaryToClassID[info[4]],

                        label = class,
                        atlas = "common-icon-forwardarrow",
                        backgroundAtlas = "OBJBonusBar-Top",
                        fontObject = GameFontNormal,
                        isParent = true,
                    })
                    treeviewNodes[class]:ToggleCollapsed()
                    treeviewNodes[class]:SetSortComparator(sortFuncItemLevels, true, false)
                end

                local ilvl = ITEM_LEVEL:format(info[3]);

                if not treeviewNodes[class][ilvl] then
                    treeviewNodes[class][ilvl] = treeviewNodes[class]:Insert({

                        --sort
                        ilvl = info[3],

                        label = ilvl,
                        atlas = "common-icon-forwardarrow",
                        backgroundAtlas = "OBJBonusBar-Top",
                        fontObject = GameFontNormal,
                        isParent = true,
                    })
                    treeviewNodes[class][ilvl]:ToggleCollapsed()
                    treeviewNodes[class][ilvl]:SetSortComparator(sortFuncItemLevels, true, false)
                end

                local setName = C_Item.GetItemSetInfo(info[2])

                if not treeviewNodes[class][ilvl][setName] then
                    treeviewNodes[class][ilvl][setName] = treeviewNodes[class][ilvl]:Insert({

                        --sort
                        classID = binaryToClassID[info[4]],

                        label = setName,
                        atlas = "common-icon-forwardarrow",
                        backgroundAtlas = "OBJBonusBar-Top",
                        fontObject = GameFontNormal,
                        isParent = true,
                    })
                    treeviewNodes[class][ilvl][setName]:ToggleCollapsed()
                    treeviewNodes[class][ilvl][setName]:SetSortComparator(sortFuncClassId, true, false)
                end



                local itemID = info[1]
                
                if type(itemID) == "number" then
                    local item = Item:CreateFromItemID(itemID)
                    if item and item:GetItemID() and not item:IsItemEmpty() then
                        item:ContinueOnItemLoad(function()

                            local _, itemType, itemSubType, equipLoc, icon, classID, subClassID = GetItemInfoInstant(itemID)

                            local rightLabel = ""
                            if classID == 4 and subClassID == 0 then
                                rightLabel = _G[equipLoc]
                            else
                                rightLabel = _G[equipLoc] and string.format("%s\n%s", _G[equipLoc], WHITE_FONT_COLOR:WrapTextInColorCode(itemSubType)) or itemSubType
                            end

                            treeviewNodes[class][ilvl][setName]:Insert({
                                label = item:GetItemLink(),
                                link = item:GetItemLink(),
                                labelRight = rightLabel,

                                init = function(f)
                                    f.labelRight:SetFontObject(GameFontNormalSmall)
                                    f:HookScript("OnMouseDown", function(_, but)
                                        if IsShiftKeyDown() then
                                            HandleModifiedItemClick(item:GetItemLink())
                                        elseif IsControlKeyDown() then
                                            DressUpItemLink(item:GetItemLink())
                                        else
                                            C_Item.PickupItem(itemID)
                                        end
                                    end)
                                end,
                            })

                        end)
                    end
                end

            end

        end

        setIndex = setIndex + 1

        if setIndex >= #addon.itemSetsData then
            self:SetDropdownEnabled(true)
        end

    end, #addon.itemSetsData)

end

function GuildbookInstancesMixin:SetDropdownEnabled(enable)
    self.sourceSelectionDropdown:EnableMouse(enable)
    self.itemTypeFilterDropdown:EnableMouse(enable)
    self.itemSubTypeFilterDropdown:EnableMouse(enable)
end

function GuildbookInstancesMixin:LoadFactionItems()

    self:SetDropdownEnabled(false)

    if self.factionItemDataProvider then
        self.listview.scrollView:SetDataProvider(self.factionItemDataProvider)
        self:SetDropdownEnabled(true)
        return
    else

        self.factionItemDataProvider = CreateTreeDataProvider()
        self.listview.scrollView:SetDataProvider(self.factionItemDataProvider)

    end
    

    local treeviewNodes = {}

    
--itemID, rep, faction
    local index = 1;
    local ticker = C_Timer.NewTicker(0.01, function()
        local info = addon.factionData[index]

        self.statusBar:SetValue(index/#addon.factionData)
        self.statusBar.label:SetText(string.format("%.1f %%", (index/#addon.factionData) * 100))

        if type(info) == "table" then
        
            if (not treeviewNodes[info[3]]) then

                local factionName = GetFactionInfoByID(info[3])

                if factionName then

                    treeviewNodes[info[3]] = self.factionItemDataProvider:Insert({
                        label = factionName,
                        atlas = "common-icon-forwardarrow",
                        backgroundAtlas = "OBJBonusBar-Top",
                        fontObject = GameFontNormal,
                        isParent = true,

                        -- init = function(f)
                        --     f.label:SetText(GetFactionInfoByID(info[3]) or "-")
                        -- end,

                        --sort
                        factionID = info[3] or -1,
            
                    }) 
                    treeviewNodes[info[3]]:ToggleCollapsed()
                    treeviewNodes[info[3]]:SetSortComparator(function(a, b)
                        if a:GetData().rep and b:GetData().rep then
                            return a:GetData().rep > b:GetData().rep;
                        end
                    end, true, true)
                end
            end

            if treeviewNodes[info[3]] and not treeviewNodes[info[3]][info[2]] then
                
                treeviewNodes[info[3]][info[2]] = treeviewNodes[info[3]]:Insert({
                    label = _G["FACTION_STANDING_LABEL"..info[2]+1],
                    atlas = "common-icon-forwardarrow",
                    backgroundAtlas = "OBJBonusBar-Top",
                    fontObject = GameFontNormal,
                    isParent = true,

                    --sort
                    rep = info[2],
        
                })

                treeviewNodes[info[3]][info[2]]:ToggleCollapsed()
            end

            if treeviewNodes[info[3]] and treeviewNodes[info[3]][info[2]] then

                local item = Item:CreateFromItemID(info[1])
                if item and item:GetItemID() and not item:IsItemEmpty() then
                    item:ContinueOnItemLoad(function()

                        local itemID, itemType, itemSubType, equipLoc, icon, classID, subClassID = GetItemInfoInstant(info[1])

                        local rightLabel = ""
                        if classID == 4 and subClassID == 0 then
                            rightLabel = _G[equipLoc]
                        else
                            rightLabel = _G[equipLoc] and string.format("%s\n%s", _G[equipLoc], WHITE_FONT_COLOR:WrapTextInColorCode(itemSubType)) or itemSubType
                        end

                       
                        treeviewNodes[info[3]][info[2]]:Insert({
                            label = item:GetItemLink(),
                            link = item:GetItemLink(),
                            labelRight = rightLabel,

                            init = function(f)
                                f.labelRight:SetFontObject(GameFontNormalSmall)
                                f:HookScript("OnMouseDown", function(_, but)
                                    if IsShiftKeyDown() then
                                        HandleModifiedItemClick(item:GetItemLink())
                                    elseif IsControlKeyDown() then
                                        DressUpItemLink(item:GetItemLink())
                                    else
                                        C_Item.PickupItem(itemID)
                                    end
                                end)
                            end,
                        })
                    end)
                end
            end



            index = index + 1;

            if index >= #addon.factionData then
                self:SetDropdownEnabled(true)
            end

        end


    end, #addon.factionData)



end