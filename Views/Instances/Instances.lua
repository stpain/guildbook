

local name, addon = ...;
local L = addon.Locales;
local Database = addon.Database;

GuildbookInstancesMixin = {
    name = "Instances",
    helptips = {},
    treeviewNodes = {},
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

    self.dragIcon = CreateFrame("Frame", nil, self.listview)
    self.dragIcon:SetSize(30,30)
    self.dragIcon:SetMovable(true)
    self.dragIcon:RegisterForDrag("LeftButton")
    self.dragIcon.icon = self.dragIcon:CreateTexture(nil, "ARTWORK")
    self.dragIcon.icon:SetAllPoints()
    self.dragIcon:Hide()

    -- self.dragIcon:SetScript("OnDragStop", function()
    --     print("boo", self.lists.listItemsGridview.scrollChild:IsMouseOver())
    --     if self.lists.listItemsGridview.scrollChild:IsMouseOver() and (type(self.dragIcon.itemID) == "number") and self.selectedList then
    --         table.insert(self.selectedList.items, self.dragIcon.itemID)
    --         self.dragIcon.itemID = nil;
    --         self.dragIcon:Hide()
    --         addon:TriggerEvent("Database_OnItemListChanged", self.selectedList)
    --     end
    -- end)

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

    local instanceData = self:GetFilteredInstanceData()
    self:BuildInstanceTreeview(instanceData)

    self.lists:ClearAllPoints()
    self.lists:SetPoint("TOPLEFT", self.listview, "TOPRIGHT", 6, 0)
    self.lists:SetPoint("BOTTOMRIGHT", -4, 6)

    self.lists.listItemsGridview:InitFramePool("FRAME", "GuildbookWrathEraItemIconFrame")
    --self.lists.listItemsGridview:SetFixedColumnCount(5)
    self.lists.listItemsGridview:SetMinMaxSize(50,70)
    self.lists.listItemsGridview.ScrollBar:Hide()
    -- self.lists.listItemsGridview.scrollChild:HookScript("OnLeave", function(f)
    --     self.dragIcon.itemID = nil;
    -- end)
    self.lists.listItemsGridview.scrollChild:EnableMouse()
    self.lists.listItemsGridview.scrollChild:HookScript("OnEnter", function(f)
        -- if f:IsMouseOver() and (type(self.dragIcon.itemID) == "number") and self.selectedList then
        --     if not previousInsert or ((previousInsert + 1) < time()) then
        --         table.insert(self.selectedList.items, self.dragIcon.itemID)
        --         self.dragIcon.itemID = nil;
        --         self.dragIcon:Hide()
        --         addon:TriggerEvent("Database_OnItemListChanged", self.selectedList)
        --         previousInsert = time()
        --     end
        -- end

        --print(time(), GetServerTime(), GetTime())

        local info, itemID = GetCursorInfo()
        ClearCursor()
        if info == "item" and type(self.selectedList) == "table" then
            self:AddItemToList(itemID, self.selectedList)
            self.lists.listItemsGridview:Insert(itemID)
        end
    end)

    --GroupLootFrame1

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


    self.sourceSelectionDropdown:SetMenu({
        {
            text = "Item sets",
            func = function()
                self.itemTypeFilterDropdown:Hide()
                self.itemSubTypeFilterDropdown:Hide()

                self:LoadItemSetsData()
            end,
        },
        {
            text = "Instances",
            func = function()
                self.itemTypeFilterDropdown:Show()
                self.itemSubTypeFilterDropdown:Show()

                self.itemTypeFilterID = nil;
                self.itemSubTypeFilterID = nil;
        
                self:BuildInstanceTreeview(self:GetFilteredInstanceData())
            end,
        },
    })

    self.sourceSelectionDropdown:SetText(SOURCE)
    self.itemSubTypeFilterDropdown:SetText("Sub Type")
    self.itemSubTypeFilterDropdown:SetText("Sub Type")

    local itemTypeMenu = {}
    for name, id in pairs(Enum.ItemClass) do
        local label = GetItemClassInfo(id)
        if label and #label > 0 then
            itemTypeMenu[id] = {
                text = label,
                func = function()
                    self.itemTypeFilterID = id;

                    self:BuildInstanceTreeview(self:GetFilteredInstanceData())

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

                                    self:BuildInstanceTreeview(self:GetFilteredInstanceData())
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

        self:BuildInstanceTreeview(self:GetFilteredInstanceData())
    end)

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
            --self:LoadListItems(self.selectedList)
            self.lists.listItemsGridview:RemoveFrame(f)
        end
    end
end

function GuildbookInstancesMixin:Tradeskill_OnItemAddedToList(itemID, list)
    self:AddItemToList(itemID, list)
    if list.id == self.selectedList.id then
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
                    self.selectedList = list;
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

function GuildbookInstancesMixin:LoadListItems(list)

    --[[
        make it a gridview
    ]]
    self.lists.listItemsGridview:Flush()
    --DevTools_Dump(self.selectedList.items)

    for k, v in ipairs(list.items) do
        self.lists.listItemsGridview:Insert(v)
    end

    -- C_Timer.After(0.1, function()
    --     if type(list) == "table" then

    --         local i = 1;
    --         local ticker = C_Timer.NewTicker(0.05, function()
                            
    --             if list.items[i] then
    --                 local itemID = list.items[i]
    --                 self.lists.listItemsGridview:Insert(itemID)
    --                 i = i + 1;
    --             end
    --         end, #list.items)
    
    --     end
    -- end)


    --[[
    self.lists.itemLists.DataProvider = CreateTreeDataProvider()
    self.lists.itemLists.scrollView:SetDataProvider(self.lists.itemLists.DataProvider)
    
    local lists = {}
    if Database.db and Database.db.itemLists then
        for k, list in ipairs(Database.db.itemLists) do
            lists[k] = self.lists.itemLists.DataProvider:Insert({
                label = list.name,
                isParent = true,
                atlas = "common-icon-forwardarrow",
                backgroundAtlas = "OBJBonusBar-Top",
                fontObject = GameFontNormal,

                init = function(f)

                    local i = 1;
                    local ticker = C_Timer.NewTicker(0.1, function()
                    
                        if list.items[i] then
                            local itemID = list.items[i]
                            local item = Item:CreateFromItemID(itemID)
                            if item and not item:IsItemEmpty() and item:GetItemID() then
                                item:ContinueOnItemLoad(function()
                                    lists[k]:Insert({
                                        label = item:GetItemLink()
                                    })
                                end)
                            end
                            i = i + 1;
                        end
                    end, #list.items)

                    f:HookScript("OnEnter", function()
                        if f:IsMouseOver() and type(self.dragIcon.itemID) == "number" then
                            table.insert(list.items, self.dragIcon.itemID)
                            self.dragIcon.itemID = nil;
                            self.dragIcon:Hide()
                            addon:TriggerEvent("Database_OnItemListChanged")
                            --DevTools_Dump(list)
                        end
                    end)
                end,
            })
        end
    end
    ]]
end

function GuildbookInstancesMixin:GetFilteredInstanceData()

    --create an addon wide lookup table
    if not addon.itemIDtoSource then
        addon.itemIDtoSource = {}
    end

    local t = {}
    local order = {}

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

                        end
                    end
                end
            end


            -- if #items > 0 then
            --     local index = 1
            --     local ticker = C_Timer.NewTicker(0.5, function()

            --         if items[index] then
            --             local itemID = items[index][3]
            --             --local difficulty = items[index][6]
            --             if type(itemID) == "number" then
            --                 local _, itemType, itemSubType, equipLoc, icon, classID, subClassID = GetItemInfoInstant(itemID)
    
            --                 if not self.itemTypeFilterID or (self.itemTypeFilterID == classID) then
            --                     if not self.itemSubTypeFilterID or (self.itemSubTypeFilterID == subClassID) then
    
            --                         table.insert(t[i_name][e_name], items[index])
    
            --                     end
            --                 end
            --             end
            --         else
            --             --print("no item at index", index)
            --         end
                

            --         index = index + 1;

            --     end)
            -- end
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

    return t;
end

function GuildbookInstancesMixin:BuildInstanceTreeview(instanceData)

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

    self.listview.DataProvider = CreateTreeDataProvider()
    self.listview.scrollView:SetDataProvider(self.listview.DataProvider)

    local treeviewNodes = {}

    for instanceName, encounters in pairs(instanceData) do
        
        --local i_name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(instanceID)

        treeviewNodes[instanceName] = self.listview.DataProvider:Insert({
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
                local ticker = C_Timer.NewTicker(0.5, function()
                    local itemID = items[index][3]
                    --self.statusBar:SetValue(index/#items)
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
                                        f:HookScript("OnMouseUp", function()
                                            self.dragIcon:Hide()
                                            --self.dragIcon.itemID = nil;
                                        end)
                                        f:HookScript("OnMouseDown", function()
                                            -- self.dragIcon.icon:SetTexture(icon)
                                            -- self.dragIcon.itemID = itemID;
                                            -- local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
                                            -- self.dragIcon:ClearAllPoints()
                                            -- self.dragIcon:SetPoint("CENTER", nil, "BOTTOMLEFT", (x / uiScale) - 16, (y / uiScale - 16))
                                            -- self.dragIcon:Show()
                                            -- self.dragIcon:StartMoving(true)

                                            C_Item.PickupItem(itemID)
                                        end)
                                    end,

                                    --sort
                                    equipLoc = _G[equipLoc],
                                    classID = classID,
                                    subClassID = subClassID,
                                    difficulty = difficulty,
                                })
                            end)
                        end
                    end

                    index = index + 1;

                    if index == #items then
                        treeviewNodes[instanceName][encounterName]:Sort()
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




function GuildbookInstancesMixin:LoadItemSetsData()

    --self.infoText:SetText("loading items")

    self.listview.DataProvider = CreateTreeDataProvider()
    self.listview.scrollView:SetDataProvider(self.listview.DataProvider)
    
    local treeviewNodes = {}

    local setIndex = #addon.itemSetsData;
    local ticker = C_Timer.NewTicker(0.01, function()
        local setData = addon.itemSetsData[setIndex]

        if setData then

            local setName = C_Item.GetItemSetInfo(setData[1])

            treeviewNodes[setName] = self.listview.DataProvider:Insert({
                label = setName,
                atlas = "common-icon-forwardarrow",
                backgroundAtlas = "OBJBonusBar-Top",
                fontObject = GameFontNormal,
                isParent = true,
            })

            local items = {}

            for i = 5, 21 do
                if setData[i] ~= 0 then
                    table.insert(items, setData[i])
                end
            end

            local index = 1;
            local ticker = C_Timer.NewTicker(0.1, function()
                local itemID = items[index]
                --self.statusBar:SetValue(index/#items)
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

                            treeviewNodes[setName]:Insert({
                                label = item:GetItemLink(),
                                link = item:GetItemLink(),
                                rightLabel = rightLabel,

                                init = function(f)
                                    f:HookScript("OnMouseDown", function()
                                        C_Item.PickupItem(itemID)
                                    end)
                                end,
                            })
                        end)
                    end
                end
                index = index + 1
            end, #items)

            setIndex = setIndex - 1;

            treeviewNodes[setName]:ToggleCollapsed()

        end
    end)

end