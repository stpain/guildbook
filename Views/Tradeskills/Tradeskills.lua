local addonName, addon = ...;
local L = addon.Locales;
local Tradeskills = addon.Tradeskills;
local Character = addon.Character;
local Database = addon.Database;

local artworkFilePath = [[Interface\AddOns\Guildbook\Media\Tradeskills\ProfessionBackgroundArt]]


local tradeskillIDs = {
    ["Alchemy"] = 171,
    ["Blacksmithing"] = 164,
    ["Enchanting"] = 333,
    ["Engineering"] = 202,
    ["Inscription"] = 773,
    ["Jewelcrafting"] = 755,
    ["Leatherworking"] = 165,
    ["Tailoring"] = 197,
    ["Mining"] = 186,
    ["Cooking"] = 185,
}

GuildbookTradskillsMixin = {
    name = "Tradeskills",
    helptips = {},
    selectedExpansion = 0,
    selectedTradeskillID = 171,
}

function GuildbookTradskillsMixin:OnLoad()

    --NineSliceUtil.ApplyLayout(self.details.crafters, NineSliceLayouts.ChatBubble)

    local menu = {}
    for name, id in pairs(tradeskillIDs) do
        table.insert(menu, {
            text = Tradeskills:GetLocaleNameFromID(id),
            func = function()
                self:LoadTradeskill(name, id, (artworkFilePath..name..".png"))
            end,
        })
    end
    table.sort(menu, function(a, b)
        return a.text < b.text
    end)
    self.tradeskillDropdown:SetMenu(menu)


    local x, y, z = 100, 60, 50
    self.details.itemButton.border:SetSize(x*1.2, x*1.2)
    self.details.itemButton.icon:SetSize(y*1.2, y*1.2)
    self.details.itemButton.mask:SetSize(z*1.2, z*1.2)

    self.details.reagents.divider:SetTexCoord(0,1, 1,1, 0,0, 1,0)
    self.details.crafters.scrollView:SetPadding(14, 14, 1, 1, 1);
    self.details.reagentForRecipes.scrollView:SetPadding(14, 14, 1, 1, 1); --t,b,l,r

    self:InitAddToListButton()

    addon.AddView(self)

end

function GuildbookTradskillsMixin:OnShow()
    self.details:ClearAllPoints()
    self.details:SetPoint("TOPLEFT", 270, -40)
    self.details:SetPoint("BOTTOMRIGHT", -4, 4)

    self:UpdateLayout()
end

function GuildbookTradskillsMixin:UpdateLayout()

    if self.details.reagentForRecipes:GetWidth() < 200 then
        self.details.reagentForRecipes:Hide()
        self.details.crafters:SetWidth(240)
    else
        self.details.reagentForRecipes:Show()
        self.details.crafters:SetWidth(200)
    end

    -- self.details:ClearAllPoints()
    -- self.details:SetPoint("TOPLEFT", 270, -40)
    -- self.details:SetPoint("BOTTOMRIGHT", -4, 4)
    
    -- local x, y = self.details:GetSize()

    -- local craftersBoxWidth = ((x - 240 - (3 * 28)) * 0.4)

    -- if craftersBoxWidth < 150 then
    --     self.details.crafters:SetWidth(craftersBoxWidth)
    --     self.details.reagentForRecipes:Hide()
    --     self.details.crafters:SetWidth(150)
    -- else

    --     self.details.crafters:SetWidth(craftersBoxWidth)
    --     self.details.reagentForRecipes:Show()
    -- end


end

function GuildbookTradskillsMixin:FindRecipeIndex(tradeskill, name)
    CastSpellByName(tradeskill)
    for i = 1, GetNumTradeSkills() do
        local _name = GetTradeSkillInfo(i)
        if _name == name then
            HideUIPanel(TradeSkillFrame)
            return i;
        end
    end
    HideUIPanel(TradeSkillFrame)
end


local wowheadCataSpellURL = "https://www.wowhead.com/cata/spell=%d"
local wowheadCataItemURL = "https://www.wowhead.com/cata/item=%d"

function GuildbookTradskillsMixin:SetRecipe(recipe)

    self.welcomePanel:Hide()
    self.details:Show()

    local rgb = ITEM_QUALITY_COLORS[recipe.quality]
    
    self.details.itemButton:Init({
        icon = recipe.icon,
        onClick = function()
            HandleModifiedItemClick(recipe.link)
        end,
    })
    self.details.itemButton.border:SetVertexColor(rgb.r, rgb.g, rgb.b)
    self.details.itemButton.link:SetText(recipe.link)
    self.details.recipeURL:SetText(wowheadCataSpellURL:format(recipe.spellID))
    if recipe.itemID then
        self.details.itemURL:SetText(wowheadCataItemURL:format(recipe.itemID))
        self.details.itemURL:Show()
    else
        self.details.itemURL:Hide()
    end

    local crafters = {}
    for k, character in pairs(addon.characters) do
        -- DevTools_Dump({character:GetTradeskillRecipes(1)})
        -- DevTools_Dump({character:GetTradeskillRecipes(2)})
        if character:CanCraftItem({ tradeskillID = self.selectedTradeskillID, spellID = recipe.spellID, }) then
            table.insert(crafters, {
                label = character:GetName(true, "short"),
                -- atlas = character:GetProfileAvatar(),
                -- showMask = true,

                onMouseDown = function()
                    addon:TriggerEvent("Character_OnProfileSelected", character)
                end,
            })
        end
    end

    self.details.crafters.scrollView:SetDataProvider(CreateDataProvider(crafters))

    -- if IsPlayerSpell(recipe.spellID) then
    --     local recipeIndex = self:FindRecipeIndex(self.selectedTradeskill, recipe.name)
    -- end

    local reagentSortFunc = function(a, b)
        return a.count > b.count;
    end

    self.details.reagentForRecipes.DataProvider = CreateTreeDataProvider()
    self.details.reagentForRecipes.scrollView:SetDataProvider(self.details.reagentForRecipes.DataProvider)
    if recipe.itemID then

        --adding to lists
        self.details.addToList.itemID = recipe.itemID
        self.details.addToList:Show()

        local t = {}
        local nodes = {}
        local recipesUsingItem = Tradeskills.GetAllRecipesThatUseItem(recipe.itemID)
        if not next(recipesUsingItem) then
            self.details.reagentForRecipes:Hide()

        else
            self.details.reagentForRecipes:Show()

            for tradeskillID, recipes in pairs(recipesUsingItem) do
    
                if not nodes[tradeskillID] then
                    nodes[tradeskillID] = self.details.reagentForRecipes.DataProvider:Insert({
                        label = string.format("%s %s", CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(tradeskillID), 20, 20), Tradeskills:GetLocaleNameFromID(tradeskillID)),
                        isParent = true,
                        atlas = "common-icon-forwardarrow",
                        --backgroundAtlas = "OBJBonusBar-Top",
                    })
                end
                
                for k, v in ipairs(recipes) do
                    local spellName = GetSpellInfo(v)
                    nodes[tradeskillID]:Insert({
                        label = spellName,
                        onMouseEnter = function(f)
                            GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
                            GameTooltip:SetSpellByID(v)
                            GameTooltip:Show()
                        end
                    })
                end
    
            end

            for k, v in pairs(nodes) do
                v:ToggleCollapsed()
            end
        end

    else
        self.details.reagentForRecipes:Hide()

        self.details.addToList.itemID = nil
        self.details.addToList:Hide()

    end


    local reagents = {}
    local invoice = {
        items = {},
        baseCost = 0,
        currentCost = 0,
        quantity = 1,
    }


    for itemID, count in pairs(recipe.reagents) do

        local numOwned = GetItemCount(itemID)

        local item = Item:CreateFromItemID(itemID)
        if not item:IsItemEmpty() then
            item:ContinueOnItemLoad(function()

                table.insert(reagents, {
                    count = count,
                    link = item:GetItemLink(),
                    init = function(f)
                        f.icon:SetTexture(item:GetItemIcon())
                        f.icon:SetSize(32,32)
        
                        f.label:SetSize(160, 32)
        
                        f.label:SetText(string.format("%d/%d %s", numOwned, count, item:GetItemName()))
        
                        f:SetScript("OnMouseDown", function()
                            HandleModifiedItemClick(item:GetItemLink())
                        end)
        
        
                    end,

                    --for AH search
                    auctionHouseSearchTerm = item:GetItemName(),
                })

                --this should be doen after all items cached but with a max of 8 reagents its probably nto too bad
                self.details.reagents.scrollView:SetDataProvider(CreateDataProvider(reagents))
                self.details.reagents.scrollView:GetDataProvider():SetSortComparator(reagentSortFunc)
                self.details.reagents.scrollView:GetDataProvider():Sort()
            end)
        end
    end

--searchAH

    if Auctionator then

        self.details.auctionatorInfo.searchAH:SetScript("OnClick", function()
            local t = {}
            for k, item in ipairs(reagents) do
                table.insert(t, item.auctionHouseSearchTerm)
            end

            Auctionator.API.v1.MultiSearch(addonName, t)
        end)

        local baseCost = 0;
        local currentCost = 0;
        
        self.details.auctionatorInfo:Show()
        
        for itemID, count in pairs(recipe.reagents) do

            local numOwned = GetItemCount(itemID)
            local numRequired = (count - numOwned)
            if numRequired < 0 then
                numRequired = 0;
            end

            local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(addonName, itemID)
            if not vendorPrice then
                local ahPrice = Auctionator.API.v1.GetAuctionPriceByItemID(addonName, itemID) or 0;

                baseCost = baseCost + (count * ahPrice)
                currentCost = currentCost + (numRequired * ahPrice)

            else

                baseCost = baseCost + (count * vendorPrice)
                currentCost = currentCost + (numRequired * vendorPrice)


            end
        end

        if recipe.itemID then
            local saleValue = Auctionator.API.v1.GetAuctionPriceByItemID(addonName, recipe.itemID) or 0;
            self.details.auctionatorInfo.saleValue:SetText(string.format("Auction house value: %s", GetCoinTextureString(saleValue)))
            self.details.auctionatorInfo.saleValue:Show()

        else
            self.details.auctionatorInfo.saleValue:Hide()
        end


        self.details.auctionatorInfo.baseCost:SetText(string.format("Base crafting cost: %s", GetCoinTextureString(baseCost)))
        self.details.auctionatorInfo.craftCost:SetText(string.format("With current reagents: %s", GetCoinTextureString(currentCost)))

    end



    --[[


    middle = 0.69921875 0.826171875 0.03515625 0.0361328125
    top = 0.14599609375 0.27294921875 0.734375 0.83203125
    bottom = 0.14599609375 0.27294921875 0.5087890625 0.60546875



    local sortFunc = function(a, b)
        if a.sort == b.sort then
            return a.cost > b.cost
        else
            return a.sort < b.sort
        end
    end

            if Auctionator then
            local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(addonName, itemID)
            if not vendorPrice then
                local ahPrice = Auctionator.API.v1.GetAuctionPriceByItemID(addonName, itemID) or 0;

                local cost = (ahPrice * count) or 0
                
                table.insert(invoice.items, {
                    sort = 1,
                    cost = cost,
                    itemID = itemID,
                    label = string.format("x%d %s", count, itemName),
                    labelRight = GetCoinTextureString(cost),
                })

                invoice.baseCost = invoice.baseCost + (ahPrice * count)

                local numRequired = invoice.quantity * count;
                if (numOwned >= numRequired) then
                    invoice.currentCost = invoice.currentCost + 0
                else
                    invoice.currentCost = invoice.currentCost + (ahPrice * (numRequired - numOwned))
                end

            else

                local cost = (vendorPrice * count) or 0
                
                table.insert(invoice.items, {
                    sort = 2,
                    cost = cost,
                    itemID = itemID,
                    label = string.format("x%d %s", count, itemName),
                    labelRight = GetCoinTextureString(cost),
                })

                invoice.baseCost = invoice.baseCost + (vendorPrice * count)

                local numRequired = invoice.quantity * count;
                if (numOwned >= numRequired) then
                    invoice.currentCost = invoice.currentCost + 0
                else
                    invoice.currentCost = invoice.currentCost + (vendorPrice * (numRequired - numOwned))
                end
            end
        end





                                if i == numReagents then
                            table.insert(invoice.items, {
                                label = "-------",
                                labelRight = "",
                                sort = 3,
                            })
                            table.insert(invoice.items, {
                                sort = 4,
                                label = "Base Cost",
                                labelRight = GetCoinTextureString(invoice.baseCost),
                            })
                            table.insert(invoice.items, {
                                sort = 5,
                                label = "Current Cost",
                                labelRight = GetCoinTextureString(invoice.currentCost),
                            })
        
                            self.details.mixer.invoice.scrollView:SetDataProvider(CreateDataProvider(invoice.items))
                            self.details.mixer.invoice.scrollView:GetDataProvider():SetSortComparator(sortFunc)
                            self.details.mixer.invoice.scrollView:GetDataProvider():Sort()
        
        
                            self.details.reagents.baseCost:SetText(GetCoinTextureString(invoice.baseCost))
        
                            self.details.itemButton.meta:SetText(string.format(""))
                        end
    ]]




end

function GuildbookTradskillsMixin:InitAddToListButton()
    self.details.addToList:SetScript("OnClick", function(f)

        if f.itemID then
            local t = {
                {
                    text = "Add to list",
                    isTitle = true,
                    notCheckable = true,
                }
            }
            if Database.db and Database.db.itemLists then
                for k, list in ipairs(Database.db.itemLists) do
                    table.insert(t, {
                        text = list.name,
                        notCheckable = true,
                        func = function()
                            addon:TriggerEvent("Tradeskill_OnItemAddedToList", f.itemID, list)
                        end,
                    })
                end
            end
            EasyMenu(t, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
        else

        end
    end)
end

function GuildbookTradskillsMixin:LoadTradeskill(tadeskillName, tradeskillID, art)

    self.selectedTradeskill = tadeskillName;
    self.selectedTradeskillID = tradeskillID

    self.details.background:SetTexture(art)

    if not self.tradeskillDataProvider then
        self.tradeskillDataProvider = {}
    end

    if self.tradeskillDataProvider[tradeskillID] then
        self.listview.scrollView:SetDataProvider(self.tradeskillDataProvider[tradeskillID])
        return
    else
        self.tradeskillDataProvider[tradeskillID] = CreateTreeDataProvider()
        self.listview.scrollView:SetDataProvider(self.tradeskillDataProvider[tradeskillID])
    end

    
    local tradeskillData = Tradeskills.BuildTradeskillData(tradeskillID)

    local function sortFunc(a, b)
        if a:GetData().name and a:GetData().quality and b:GetData().name and b:GetData().quality and b:GetData().level and b:GetData().level then
            if a:GetData().level == b:GetData().level then
                if a:GetData().quality == b:GetData().quality then
                    return a:GetData().name < b:GetData().name;
                else
                    return a:GetData().quality > b:GetData().quality;
                end
            else
                return a:GetData().level > b:GetData().level;
            end
        end
    end

    self.tradeskillDropdown:EnableMouse(false)

    local itemsAdded, spellsAdded = {}, {}
    local numItems = #tradeskillData
    local index = 1;
    self.recipeTicker = C_Timer.NewTicker(0.001, function()

        self.statusBar:SetValue(index/#tradeskillData)
        self.statusBar.label:SetText(string.format("%.1f %%", (index/#tradeskillData) * 100))
    
        if tradeskillData[index] then
            local itemID = tradeskillData[index].itemID
            local spellID = tradeskillData[index].spellID
            local reagentData = tradeskillData[index].reagents or {}

            local showCraftDobutton = IsPlayerSpell(spellID) == true and true or false;

            if itemID then
                local item = Item:CreateFromItemID(itemID)
                if not item:IsItemEmpty() then
                    item:ContinueOnItemLoad(function()
                        local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent = GetItemInfo(itemID)

                        if not self.tradeskillDataProvider[tradeskillID][itemType] then
                            self.tradeskillDataProvider[tradeskillID][itemType] = self.tradeskillDataProvider[tradeskillID]:Insert({
                                label = itemType,
                                atlas = "common-icon-forwardarrow",
                                backgroundAtlas = "OBJBonusBar-Top",
                                fontObject = GameFontNormal,
                                isParent = true,
                                init = function(f)
                                    f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                    
                                    if f:GetElementData():IsCollapsed() then
                                        f.icon:SetTexCoord(0,1,0,1)
                                    else
                                        f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                    end
                                end,
                            })
                        end

                        if not self.tradeskillDataProvider[tradeskillID][itemType][itemSubType] then
                            self.tradeskillDataProvider[tradeskillID][itemType][itemSubType] = self.tradeskillDataProvider[tradeskillID][itemType]:Insert({
                                label = itemSubType,
                                atlas = "common-icon-forwardarrow",
                                backgroundAtlas = "OBJBonusBar-Top",
                                fontObject = GameFontNormal,
                                isParent = true,
                                init = function(f)
                                    --f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                    
                                    if f:GetElementData():IsCollapsed() then
                                        f.icon:SetTexCoord(0,1,0,1)
                                    else
                                        f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                    end
                                end,
                            })
                        
                            self.tradeskillDataProvider[tradeskillID][itemType][itemSubType]:SetSortComparator(sortFunc, true, false)
                            self.tradeskillDataProvider[tradeskillID][itemType][itemSubType]:ToggleCollapsed()
                        end

                        if (_G[itemEquipLoc]) then

                            if not self.tradeskillDataProvider[tradeskillID][itemType][itemSubType][itemEquipLoc] then
                                self.tradeskillDataProvider[tradeskillID][itemType][itemSubType][itemEquipLoc] = self.tradeskillDataProvider[tradeskillID][itemType][itemSubType]:Insert({
                                    label = _G[itemEquipLoc],
                                    atlas = "common-icon-forwardarrow",
                                    backgroundAtlas = "OBJBonusBar-Top",
                                    fontObject = GameFontNormal,
                                    isParent = true,
                                    init = function(f)
                                        --f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                        
                                        if f:GetElementData():IsCollapsed() then
                                            f.icon:SetTexCoord(0,1,0,1)
                                        else
                                            f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                        end
                                    end,
                                })
                            
                                self.tradeskillDataProvider[tradeskillID][itemType][itemSubType][itemEquipLoc]:SetSortComparator(sortFunc, true, false)
                                self.tradeskillDataProvider[tradeskillID][itemType][itemSubType][itemEquipLoc]:ToggleCollapsed()
                            end

                            if not itemsAdded[itemName] then
                                self.tradeskillDataProvider[tradeskillID][itemType][itemSubType][itemEquipLoc]:Insert({

                                    --sort data
                                    name = itemName,
                                    quality = itemQuality,
                                    level = itemLevel,

                                    --template keyValues
                                    label = itemLink,
                                    link = itemLink,
                                    fontObject = GameFontNormalSmall,

                                    onMouseDown = function()
                                        self:SetRecipe({
                                            itemID = itemID,
                                            icon = itemTexture,
                                            quality = itemQuality,
                                            link = itemLink,
                                            reagents = reagentData,
                                            spellID = spellID,
                                            name = itemName,
                                        })
                                    end,
                                })

                                itemsAdded[itemName] = true

                                self.tradeskillDataProvider[tradeskillID][itemType][itemSubType][itemEquipLoc]:Sort()

                            end

                        else

                            if not itemsAdded[itemName] then
                                self.tradeskillDataProvider[tradeskillID][itemType][itemSubType]:Insert({

                                    --sort data
                                    name = itemName,
                                    quality = itemQuality,
                                    level = itemLevel,

                                    --template keyValues
                                    label = itemLink,
                                    link = itemLink,
                                    fontObject = GameFontNormalSmall,

                                    onMouseDown = function()
                                        self:SetRecipe({
                                            itemID = itemID,
                                            icon = itemTexture,
                                            quality = itemQuality,
                                            link = itemLink,
                                            reagents = reagentData,
                                            spellID = spellID,
                                            name = itemName,
                                        })
                                    end,
                                })

                                itemsAdded[itemName] = true

                                self.tradeskillDataProvider[tradeskillID][itemType][itemSubType]:Sort()
                            end
                        end
                    end)
                end

            else

                if spellID then

                    local spell = Spell:CreateFromSpellID(spellID)
                    if not spell:IsSpellEmpty() then
                        spell:ContinueOnSpellLoad(function()
                        
                            local spellName = spell:GetSpellName()
                            local spellDesc = spell:GetSpellDescription()
                            --local spellSubtext = spell:GetSpellSubtext()
                            local _, _, icon = GetSpellInfo(spellID)
                            local spellLink = GetSpellLink(spellID)


                            if tradeskillID == 333 then
                                
                                local prefix, enchantLocation, hyphenOrType, hyphenOrType2, enchantType = strsplit(" ", spellName)

                                if hyphenOrType == "-" then
                                    
                                    --normal enchant

                                elseif (hyphenOrType2 == "-") or (hyphenOrType2 and (#hyphenOrType2 == 1)) then

                                    --2H enchant
                                    enchantLocation = string.format("%s %s", enchantLocation, hyphenOrType)
                                end

    
                                if not self.tradeskillDataProvider[tradeskillID][prefix] then
                                    self.tradeskillDataProvider[tradeskillID][prefix] = self.tradeskillDataProvider[tradeskillID]:Insert({
                                        label = prefix,
                                        atlas = "common-icon-forwardarrow",
                                        backgroundAtlas = "OBJBonusBar-Top",
                                        fontObject = GameFontNormal,
                                        isParent = true,
                                        init = function(f)
                                            f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                            
                                            if f:GetElementData():IsCollapsed() then
                                                f.icon:SetTexCoord(0,1,0,1)
                                            else
                                                f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                            end
                                        end,
                                    })
    
                                    --self.tradeskillDataProvider[tradeskillID][prefix]:SetSortComparator(sortFunc, true, false)
                                end
                                if not self.tradeskillDataProvider[tradeskillID][prefix][enchantLocation] then
                                    self.tradeskillDataProvider[tradeskillID][prefix][enchantLocation] = self.tradeskillDataProvider[tradeskillID][prefix]:Insert({
                                        label = enchantLocation,
                                        atlas = "common-icon-forwardarrow",
                                        backgroundAtlas = "OBJBonusBar-Top",
                                        fontObject = GameFontNormal,
                                        isParent = true,
                                        init = function(f)
                                            --f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                            
                                            if f:GetElementData():IsCollapsed() then
                                                f.icon:SetTexCoord(0,1,0,1)
                                            else
                                                f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                            end
                                        end,
                                    })
    
                                    self.tradeskillDataProvider[tradeskillID][prefix][enchantLocation]:SetSortComparator(sortFunc, true, false)
                                    self.tradeskillDataProvider[tradeskillID][prefix][enchantLocation]:ToggleCollapsed()
                                end
    
                                if not spellsAdded[spellID] then
    
                                    local label = spellName;
                                    if spellName:find("-", nil, true) then
                                        local _, _label, bonus = strsplit("-", spellName)
                                        if type(bonus) == "string" then
                                            label = bonus:sub(2, #bonus)
                                        else
                                            label = _label:sub(2, #_label)
                                        end
                                    end
    
                                    self.tradeskillDataProvider[tradeskillID][prefix][enchantLocation]:Insert({
                                        --sort data
                                        name = spellName,
                                        quality = 1,
                                        level = 1,
    
                                        --template keyValues
                                        label = "|cffffffff"..label,
                                        link = spellLink,
                                        fontObject = GameFontNormalSmall,
    
                                        onMouseDown = function()
                                            self:SetRecipe({
                                                --itemID = itemID,
                                                icon = icon,
                                                quality = 1,
                                                link = spellLink,
                                                reagents = reagentData,
                                                spellID = spellID,
                                                name = spellName,
                                                spellDesc = spellDesc,
                                            })
                                        end,
                                    })
    
                                    self.tradeskillDataProvider[tradeskillID][prefix][enchantLocation]:Sort()
    
                                    spellsAdded[spellID] = true;
                            
                                end

                            else


                                if not self.tradeskillDataProvider[tradeskillID][tadeskillName] then
                                    self.tradeskillDataProvider[tradeskillID][tadeskillName] = self.listview.DataProvider:Insert({
                                        label = tadeskillName,
                                        atlas = "common-icon-forwardarrow",
                                        backgroundAtlas = "OBJBonusBar-Top",
                                        fontObject = GameFontNormal,
                                        isParent = true,
                                        init = function(f)
                                            f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                            
                                            if f:GetElementData():IsCollapsed() then
                                                f.icon:SetTexCoord(0,1,0,1)
                                            else
                                                f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                            end
                                        end,
                                    })

                                    self.tradeskillDataProvider[tradeskillID][tadeskillName]:SetSortComparator(sortFunc, true, false)
    
                                end

                                if not spellsAdded[spellID] then
                                        
                                    self.tradeskillDataProvider[tradeskillID][tadeskillName]:Insert({
                                        --sort data
                                        name = spellName,
                                        quality = 1,
                                        level = 1,
    
                                        --template keyValues
                                        label = "|cffffffff"..spellName,
                                        link = spellLink,
                                        fontObject = GameFontNormalSmall,
    
                                        onMouseDown = function()
                                            self:SetRecipe({
                                                --itemID = itemID,
                                                icon = icon,
                                                quality = 1,
                                                link = spellLink,
                                                reagents = reagentData,
                                                spellID = spellID,
                                                name = spellName,
                                                spellDesc = spellDesc,
                                            })
                                        end,
                                    })

                                    self.tradeskillDataProvider[tradeskillID][tadeskillName]:Sort()

                                    spellsAdded[spellID] = true;
                                end

                            end


                            
                        end)
                    end
                end

            end

            index = index + 1;

            if index >= numItems then
                self.tradeskillDropdown:EnableMouse(true)
            end

        end

    end, numItems)

end