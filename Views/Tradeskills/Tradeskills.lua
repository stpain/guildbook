local name, addon = ...;
local L = addon.Locales;
local Tradeskills = addon.Tradeskills;
local Character = addon.Character;
local Database = addon.Database;

GuildbookTradskillsMixin = {
    name = "Tradeskills",
    helptips = {},
    selectedExpansion = 0,
    selectedTradeskillID = 171,
}

function GuildbookTradskillsMixin:OnLoad()

    local tradeskills = {
        171,
        164,
        333,
        202,
        773,
        755,
        165,
        197,
        186,
        --182,
        --393,
        185,
        129,
        --356,
    }
    for k, id in ipairs(tradeskills) do
        local name = Tradeskills:GetLocaleNameFromID(id)
        local atlas = Tradeskills:TradeskillIDToAtlas(id)

        self.tradeskillsListview.DataProvider:Insert({
            atlas = atlas,
            label = name,
            backgroundAlpha = 0.15,
            onMouseDown = function()
                self:LoadtradeskillRecipes(id)
            end,
        })
    end

    self.spellIdToTradeskillItemIndex = {}
    for k, v in ipairs(addon.itemData) do
        self.spellIdToTradeskillItemIndex[v.spellID] = k;
    end

    local expansions = {
        {
            text = "All",
            func = function()
                self.selectedExpansion = 0;
                self:LoadtradeskillRecipes();
            end,
        },
        {
            text = "Classic",
            func = function()
                self.selectedExpansion = 1;
                self:LoadtradeskillRecipes();
            end,
        },
        {
            text = "TBC",
            func = function()
                self.selectedExpansion = 2;
                self:LoadtradeskillRecipes();
            end,
        },
        {
            text = "WRATH",
            func = function()
                self.selectedExpansion = 3;
                self:LoadtradeskillRecipes();
            end,
        },
    }
    self.expansionFilter:SetMenu(expansions)

    self.glpyhFilterMenu = {}
    for i = 1, 12 do
        local name, _, id = GetClassInfo(i)
        if name and id then
            table.insert(self.glpyhFilterMenu, {
                text = name,
                func = function()

                    local glyphItemIDs = {}
                    for k, glyph in ipairs(addon.glyphData.wrath) do
                        if glyph.classID == id then
                            table.insert(glyphItemIDs, glyph.itemID)
                        end
                    end
                    self:LoadRecipesFromItemIds(glyphItemIDs)
                end,
            })
        end
    end

    self.inventorySlotFilterMenu = {}
    for k, v in ipairs(addon.data.inventorySlots) do
        local slotID = GetInventorySlotInfo(v.slot)
        if slotID then
            table.insert(self.inventorySlotFilterMenu, {
                text = _G[v.slot],
                func = function()

                    local itemIDs = {}
                    if self.selectedTradeskillID then
                        for k, v in ipairs(addon.itemData) do
                            if (v.tradeskillID == self.selectedTradeskillID) and (v.inventorySlot == slotID) then
                                if v.itemID then
                                    table.insert(itemIDs, v.itemID)
                                end
                            end
                        end
                    else
                        for k, v in ipairs(addon.itemData) do
                            if (v.inventorySlot == slotID) then
                                if v.itemID then
                                    table.insert(itemIDs, v.itemID)
                                end
                            end
                        end
                    end

                    print(string.format("number of itemIDs: %d", #itemIDs))
                    addon.api.makeTableUnique(itemIDs)
                    print(string.format("number of itemIDs: %d", #itemIDs))

                    self:LoadRecipesFromItemIds(itemIDs)
                end,
            })
        end
    end

    addon:RegisterCallback("Character_OnTradeskillSelected", self.OnCharacterTradeskillSelected, self)

    self.tradeskillsHelptip:SetText(L.TRADESKILLS_LISTVIEW_HT)
    self.recipesHelptip:SetText(L.TRADESKILLS_RECIPES_LISTVIEW_HT)
    self.craftersHelptip:SetText(L.TRADESKILLS_CRAFTERS_LISTVIEW_HT)

    self.showItemID.label:SetText(L.TRADESKILLS_RECIPES_SHOW_ITEMID_CB)
    self.showItemID:SetScript("OnClick", function(cb)
        Database:SetConfig("tradeskillsRecipesListviewShowItemID", cb:GetChecked())
    end)

    table.insert(self.helptips, self.tradeskillsHelptip)
    table.insert(self.helptips, self.recipesHelptip)
    table.insert(self.helptips, self.craftersHelptip)

    addon.AddView(self)

end

function GuildbookTradskillsMixin:LoadRecipesFromItemIds(itemIDs)

    local items = {}
    for k, id in ipairs(itemIDs) do
        if addon.itemIdToDataIndex[id] then
            table.insert(items, addon.itemData[addon.itemIdToDataIndex[id]])
        end
    end

    self.charactersListview.DataProvider:Flush()

    if self.selectedTradeskillID == 333 then
        table.sort(items, function(a, b)
            if a.quality == b.quality then
                return a.itemName < b.itemName;
            else
                return a.quality > b.quality;
            end
        end)
    else
        table.sort(items, function(a, b)
            if a.quality == b.quality then
                if a.itemLevel == b.itemLevel then
                    return a.itemLink < b.itemLink
                else
                    return a.itemLevel > b.itemLevel;
                end
            else
                return a.quality > b.quality;
            end
        end)
    end

    local dp = CreateDataProvider(items)
    self.recipesListview.scrollView:SetDataProvider(dp)

    if addon.characters then
        for k, character in pairs(addon.characters) do
            if (character.data.profession1 == self.selectedTradeskillID) or (character.data.profession2 == self.selectedTradeskillID) then
                self.charactersListview.DataProvider:Insert({
                    label = character.data.name,
                    atlas = character:GetProfileAvatar(),
                    showMask = true,
    
                    func = function()
                        addon:TriggerEvent("Character_OnProfileSelected", character)
                    end,
                })
            end
        end
    end

end

function GuildbookTradskillsMixin:LoadtradeskillRecipes(tradeskillID)

    if tradeskillID then
        self.selectedTradeskillID = tradeskillID
    end

    self.itemFilter:SetMenu({})
    self.itemFilter:SetText("")
    self.itemFilter:Hide()

    if self.selectedTradeskillID == 773 then
        self.itemFilter:SetMenu(self.glpyhFilterMenu)
        self.itemFilter:SetText(CLASS)
        self.itemFilter:Show()
    end
    -- if self.selectedTradeskillID == 164 or self.selectedTradeskillID == 202 or self.selectedTradeskillID == 755 or self.selectedTradeskillID == 165 or self.selectedTradeskillID == 197 then
    --     self.itemFilter:SetMenu(self.inventorySlotFilterMenu)
    -- end

    self.recipesListview.DataProvider:Flush()
    self.charactersListview.DataProvider:Flush()

    local items = {}

    for k, v in ipairs(addon.itemData) do

        if (self.selectedExpansion == 0) or (self.selectedExpansion == v.expansionID) then

            if v.tradeskillID == self.selectedTradeskillID then

                if self.selectedTradeskillID == 333 then
                    
                    local name = GetSpellInfo(v.spellID)
                    --local desc = GetSpellDescription(v.spellID)
                    table.insert(items, {
                        itemName = name,
                        itemLink = v.itemLink,
                        spellID = v.spellID,
                        icon = v.icon,
                        itemID = v.itemID,
                        reagents = v.reagents,
                        inventorySlot = v.inventorySlot,
                        quality = v.quality,
                        tradeskillID = v.tradeskillID,

                        func = function()
                            self:LoadCharactersWithRecipe(v)
                        end
                    })
                else
                    table.insert(items, {
                        itemName = string.match(v.itemLink, "h%[(.*)%]|h"),
                        itemLink = v.itemLink,
                        spellID = v.spellID,
                        icon = v.icon,
                        itemID = v.itemID,
                        reagents = v.reagents,
                        inventorySlot = v.inventorySlot,
                        quality = v.quality,
                        tradeskillID = v.tradeskillID,
                        itemLevel = v.itemLevel,

                        func = function()
                            self:LoadCharactersWithRecipe(v)
                        end
                    })
                end
            end

        end
    end

    if self.selectedTradeskillID == 333 then
        table.sort(items, function(a, b)
            if a.quality == b.quality then
                return a.itemName < b.itemName;
            else
                return a.quality > b.quality;
            end
        end)
    else
        table.sort(items, function(a, b)
            if a.quality == b.quality then
                if a.itemLevel == b.itemLevel then
                    return a.itemLink < b.itemLink
                else
                    return a.itemLevel > b.itemLevel;
                end
            else
                return a.quality > b.quality;
            end
        end)
    end

    local dp = CreateDataProvider(items)
    self.recipesListview.scrollView:SetDataProvider(dp)


    if addon.characters then
        for k, character in pairs(addon.characters) do
            if (character.data.profession1 == self.selectedTradeskillID) or (character.data.profession2 == self.selectedTradeskillID) then
                self.charactersListview.DataProvider:Insert({
                    label = character.data.name,
                    atlas = character:GetProfileAvatar(),
                    showMask = true,
    
                    func = function()
                        addon:TriggerEvent("Character_OnProfileSelected", character)
                    end,
                })
            end
        end
    end
end

function GuildbookTradskillsMixin:LoadCharactersWithRecipe(item)

    self.charactersListview.DataProvider:Flush()
    
    for k, character in pairs(addon.characters) do
        -- DevTools_Dump({character:GetTradeskillRecipes(1)})
        -- DevTools_Dump({character:GetTradeskillRecipes(2)})
        if character:CanCraftItem(item) then
            self.charactersListview.DataProvider:Insert({
                label = character.data.name,
                atlas = character:GetProfileAvatar(),
                showMask = true,

                func = function()
                    addon:TriggerEvent("Character_OnProfileSelected", character)
                end,
            })
        end
    end
end

---callback when user clicks a tradeskill listed in the character profile side panel
---@param tradeskillID any
---@param recipes any
function GuildbookTradskillsMixin:OnCharacterTradeskillSelected(tradeskillID, recipes)
    self.recipesListview.DataProvider:Flush()
    self.charactersListview.DataProvider:Flush()
    if type(tradeskillID) == "number" and type(recipes) == "table" then
        local items = {}
        for k, spellId in ipairs(recipes) do
            local item = addon.itemData[self.spellIdToTradeskillItemIndex[spellId]];
            if tradeskillID == 333 then
                local name = GetSpellInfo(spellId)
                --local desc = GetSpellDescription(v.spellID)
                table.insert(items, {
                    -- itemName = name,
                    -- itemLink = item.itemLink,
                    spellID = item.spellID,
                    icon = item.icon,
                    itemID = item.itemID,
                    reagents = item.reagents,
                    -- inventorySlot = item.inventorySlot,
                    -- quality = item.quality,
                    tradeskillID = item.tradeskillID,
                })
            else
                table.insert(items, {
                    -- itemName = string.match(item.itemLink, "h%[(.*)%]|h"),
                    -- itemLink = item.itemLink,
                    -- spellID = item.spellID,
                    icon = item.icon,
                    itemID = item.itemID,
                    reagents = item.reagents,
                    -- inventorySlot = item.inventorySlot,
                    -- quality = item.quality,
                    tradeskillID = item.tradeskillID,
                })
            end
        end
        local dp = CreateDataProvider(items)
        self.recipesListview.scrollView:SetDataProvider(dp)
        GuildbookUI:SelectView(self.name)
    end
end