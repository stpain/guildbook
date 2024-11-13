local addonName, addon = ...;
local L = addon.Locales;
local Tradeskills = addon.Tradeskills;
local Character = addon.Character;
local Database = addon.Database;

local artworkFilePath = [[Interface\AddOns\Guildbook\Media\Tradeskills\ProfessionBackgroundArt]]
local MILLING_SPELL_NAME = ""

MillingMacroButtonMixin = {}
function MillingMacroButtonMixin:OnLoad()
    
end
function MillingMacroButtonMixin:SetDataBinding(binding)   
    if binding.itemIcon then
        self.icon:SetTexture(binding.itemIcon)
    end
    if binding.itemID then
        
    end
    if binding.stackCount then
        self.text:SetText(binding.stackCount)
    end
    if binding.itemName then
        local macro = 
([[
/cast %s
/use %s
]]):format(MILLING_SPELL_NAME, binding.itemName)

    self:SetAttribute("macrotext1", macro)
    end
end
function MillingMacroButtonMixin:ResetDataBinding()
    self:SetAttribute("macrotext1", "")
    self.text:SetText("")
end

-- local tradeskillIDs = {
--     ["Alchemy"] = 171,
--     ["Blacksmithing"] = 164,
--     ["Enchanting"] = 333,
--     ["Engineering"] = 202,
--     ["Inscription"] = 773,
--     ["Jewelcrafting"] = 755,
--     ["Leatherworking"] = 165,
--     ["Tailoring"] = 197,
--     ["Mining"] = 186,
--     ["Cooking"] = 185,
-- }

GuildbookTradskillsMixin = {
    name = "Tradeskills",
    helptips = {},
    selectedExpansion = 0,
    selectedTradeskillID = 171,
}

local function getArtworkForTradeskillID(id)
    for name, _id in pairs(Tradeskills.PrimaryTradeskills) do
        if _id == id then
            return artworkFilePath..name..".png"
        end
    end
end

function GuildbookTradskillsMixin:OnLoad()

    --NineSliceUtil.ApplyLayout(self.details.crafters, NineSliceLayouts.ChatBubble)

    self.tradeskillMenu = {}
    for name, id in pairs(Tradeskills.PrimaryTradeskills) do
        table.insert(self.tradeskillMenu, {
            text = Tradeskills:GetLocaleNameFromID(id),
            func = function()
                local recipes = Tradeskills:BuildTradeskillData(id)
                self.selectedTradeskillID = id
                local dataProvider = self:SetOrCreateDataProvider(id)
                if dataProvider then
                    self:LoadTradeskillRecipes(id, recipes, dataProvider)
                end
            end,
        })
    end
    table.sort(self.tradeskillMenu, function(a, b)
        return a.text < b.text
    end)

    self.tradeskillDropdown:SetMenu(self.tradeskillMenu)

    self.statusBar:SetScript("OnValueChanged", function(bar)
        if bar:GetValue() == 1 then
            bar.fadeOut:Play()
        end
    end)

    local x, y, z = 100, 60, 50
    self.details.itemButton.border:SetSize(x*1.2, x*1.2)
    self.details.itemButton.icon:SetSize(y*1.2, y*1.2)
    self.details.itemButton.mask:SetSize(z*1.2, z*1.2)

    self.milling.itemButton.border:SetSize(x*1.2, x*1.2)
    self.milling.itemButton.icon:SetSize(y*1.2, y*1.2)
    self.milling.itemButton.mask:SetSize(z*1.2, z*1.2)

    self.details.reagents.divider:SetTexCoord(0,1, 1,1, 0,0, 1,0)
    self.milling.sources.divider:SetTexCoord(0,1, 1,1, 0,0, 1,0)
    self.details.crafters.scrollView:SetPadding(14, 14, 1, 1, 1);
    self.details.reagentForRecipes.scrollView:SetPadding(14, 14, 1, 1, 1); --t,b,l,r

    self.prof1.border:SetSize(50,50)
    self.prof1.icon:SetSize(30,30)
    self.prof1.mask:SetSize(25,25)
    self.prof2.border:SetSize(50,50)
    self.prof2.icon:SetSize(30,30)
    self.prof2.mask:SetSize(25,25)

    

    self.details.craftingOptions.quantityToCraft:SetMinMaxValues(1,100)

    self:InitAddToListButton()

    addon:RegisterCallback("Character_OnTradeskillSelected", self.OnCharacterTradeskillSelected, self)
    addon:RegisterCallback("Character_Bags_Updated", self.OnCharacterBagsUpdated, self)

    if Auctionator then
        Auctionator.API.v1.RegisterForDBUpdate(addonName, function()
            if self.selectedRecipe then
                self:UpdateAuctionatorPanel(self.selectedRecipe)
            end
        end)
    end

    addon.AddView(self)

end

function GuildbookTradskillsMixin:LoadMillingUI()
    self:ClearPanels()

    self.milling:Show()

    local dataProvider = self:SetOrCreateDataProvider("milling")
    if dataProvider then
        for k, v in ipairs(addon.tradeskillData.inks) do
            local item = Item:CreateFromItemID(v.itemId)
            if not item:IsItemEmpty() then
                item:ContinueOnItemLoad(function()

                    local itemName = item:GetItemName()

                    if not dataProvider[itemName] then
                        dataProvider[itemName] = dataProvider:Insert({
                            label = item:GetItemLink(),
                            isParent = true,
                            atlas = "common-icon-forwardarrow",
                        })
                    end

                    for _, pigment in ipairs(v.pigments) do
                        for _, source in ipairs(addon.tradeskillData.pigments) do
                            if source.itemId == pigment.itemId then

                                local item2 = Item:CreateFromItemID(pigment.itemId)
                                if not item2:IsItemEmpty() then
                                    item2:ContinueOnItemLoad(function()
                                        dataProvider[itemName]:Insert({
                                            label = item2:GetItemLink(),

                                            onMouseDown = function()

                                                self.milling.sourceHerbItemIDs = {}
                                                for _, v2 in ipairs(source.sources) do
                                                    self.milling.sourceHerbItemIDs[v2.itemId] = true
                                                end

                                                self:UpdateMillingReagentsInbags()

                                                self.milling.itemButton:Show()
                                                self.milling.itemButton.link:SetText(item2:GetItemLink())
                                                self.milling.itemButton:Init({
                                                    icon = item2:GetItemIcon(),
                                                })
                                                local rgb = ITEM_QUALITY_COLORS[item2:GetItemQuality()]
                                                self.milling.itemButton.border:SetVertexColor(rgb.r, rgb.g, rgb.b)

                                                local auctionatorSerachTerms = {}
                                                local dp = CreateDataProvider({})
                                                self.milling.sources.scrollView:SetDataProvider(dp)
                                                for _, v2 in ipairs(source.sources) do
                                                    local item3 = Item:CreateFromItemID(v2.itemId)
                                                    if not item3:IsItemEmpty() then
                                                        item3:ContinueOnItemLoad(function()
                                                            local cost = Auctionator.API.v1.GetAuctionPriceByItemID(addonName, v2.itemId)
                                                            table.insert(auctionatorSerachTerms, item3:GetItemName())
                                                            dp:Insert({
                                                                label = string.format("%s\n%s", item3:GetItemLink(), NORMAL_FONT_COLOR:WrapTextInColorCode(string.format("chance: %s", v2.chance))),
                                                                icon = item3:GetItemIcon(),

                                                                labelRight = string.format("\n%s  ", GetCoinTextureString((cost or 0), 11)),

                                                                onMouseDown = function()
                                                                    if IsAltKeyDown() then
                                                                        --Auctiona
                                                                    end
                                                                end
                                                            })
                                                        end)
                                                    end
                                                end

                                                self.milling.searchAH:SetScript("OnClick", function()
                                                    if AuctionFrame:IsVisible() then
                                                        Auctionator.API.v1.MultiSearch(addonName, auctionatorSerachTerms)
                                                    end
                                                end)
                                            end,
                                        })
                                    end)
                                end

                            end
                        end
                    end

                    dataProvider[itemName]:ToggleCollapsed()
                end)
            end
        end
    end

end

function GuildbookTradskillsMixin:UpdateMillingReagentsInbags()
    self.milling.playerReagentsGridview:Flush()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
            if containerInfo then
                if self.milling.sourceHerbItemIDs[containerInfo.itemID] then
                    self.milling.playerReagentsGridview:Insert({
                        bag = bag,
                        slot = slot,
                        stackCount = containerInfo.stackCount,
                        itemIcon = containerInfo.iconFileID,
                        itemName = containerInfo.itemName,
                        itemID = containerInfo.itemID,
                    })
                end
            end
        end
    end
end

function GuildbookTradskillsMixin:UpdatePlayerTradeskillButtons()
    if addon.characters and addon.characters[addon.thisCharacter] and addon.characters[addon.thisCharacter].data.profession1 then

        if not Tradeskills:IsGathering(addon.characters[addon.thisCharacter].data.profession1) then

            self.prof1:Init({
                atlas = Tradeskills:TradeskillIDToAtlas(addon.characters[addon.thisCharacter].data.profession1),
                onClick = function()
                    self:CacheRecipeIndexes(addon.characters[addon.thisCharacter].data.profession1)
                    addon:TriggerEvent("Character_OnTradeskillSelected", addon.characters[addon.thisCharacter].data.profession1, addon.characters[addon.thisCharacter].data.profession1Recipes)
                end,
            })
            self.prof1:Show()
        else

            self.prof1:Hide()
        end

    end

    if addon.characters and addon.characters[addon.thisCharacter] and addon.characters[addon.thisCharacter].data.profession2 then
        
        if not Tradeskills:IsGathering(addon.characters[addon.thisCharacter].data.profession2) then

            self.prof2:Init({
                atlas = Tradeskills:TradeskillIDToAtlas(addon.characters[addon.thisCharacter].data.profession2),
                onClick = function()
                    self:CacheRecipeIndexes(addon.characters[addon.thisCharacter].data.profession2)
                    addon:TriggerEvent("Character_OnTradeskillSelected", addon.characters[addon.thisCharacter].data.profession2, addon.characters[addon.thisCharacter].data.profession2Recipes)
                end,
            })
            self.prof2:Show()
        else

            self.prof2:Hide()
        end
    end
end

function GuildbookTradskillsMixin:OnShow()
    self.details:ClearAllPoints()
    self.details:SetPoint("TOPLEFT", 270, -40)
    self.details:SetPoint("BOTTOMRIGHT", -4, 4)

    --ocal currentVolume = tonumber(GetCVar("Sound_MasterVolume"));
    self:UpdatePlayerTradeskillButtons()
    self:UpdateLayout()

    if IsPlayerSpell(51005) and MILLING_SPELL_NAME == "" then

        self.milling.playerReagentsGridview:InitFramePool("BUTTON", "MillingMacroButton")
        self.milling.playerReagentsGridview:SetMinMaxSize(40,50)
        self.milling.playerReagentsGridview.ScrollBar:Hide()

        local spell, _, icon = GetSpellInfo(51005)
        MILLING_SPELL_NAME = spell
        table.insert(self.tradeskillMenu, {
            text = spell,
            func = function()
                self:LoadMillingUI()
            end,
        })
        self.tradeskillDropdown:SetMenu(self.tradeskillMenu)
    end
end

function GuildbookTradskillsMixin:UpdateLayout()

    if self.details.reagentForRecipes:GetWidth() < 190 then
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

function GuildbookTradskillsMixin:CacheRecipeIndexes(tradeskill)

    if not self.recipeIndexes then
        self.recipeIndexes = {}
    end

    local prof = Tradeskills:GetLocaleNameFromID(tradeskill)
    if prof then
        CastSpellByName(prof)
        for i = 1, GetNumTradeSkills() do
            --local name, _type = GetTradeSkillInfo(i)
            local link = GetTradeSkillItemLink(i)
            -- if name and (_type == "optimal" or _type == "medium" or _type == "easy" or _type == "trivial") then
            --     self.recipeIndexes[tradeskill][name] = i
            -- end
            if link then
                local id = GetItemInfoFromHyperlink(link)
                local recipeSpellID = Tradeskills:GetRecipeSpellIDFromItemID(id)
                if recipeSpellID then
                    self.recipeIndexes[recipeSpellID] = i
                end
            end
        end
        HideUIPanel(TradeSkillFrame)
    end
end

function GuildbookTradskillsMixin:FindRecipeIndex(recipeSpellID)
    if self.recipeIndexes  then
        return self.recipeIndexes[recipeSpellID]
    end
end


local wowheadCataSpellURL = "https://www.wowhead.com/cata/spell=%d"
local wowheadCataItemURL = "https://www.wowhead.com/cata/item=%d"

function GuildbookTradskillsMixin:ClearPanels()
    self.welcomePanel:Hide()
    self.details:Hide()
    self.milling:Hide()
end

function GuildbookTradskillsMixin:OnCharacterBagsUpdated()
    if self.selectedRecipe then
        self:UpdateReagents(self.selectedRecipe)
    end

    if self.milling:IsVisible() then
        self:UpdateMillingReagentsInbags()
    end
end

function GuildbookTradskillsMixin:UpdateReagents(recipe)
    local reagents = {}

    local reagentSortFunc = function(a, b)
        return a.count > b.count;
    end

    for itemID, count in pairs(recipe.reagents) do

        local numOwned = GetItemCount(itemID)
        local numRequired = count * math.floor(self.details.craftingOptions.quantityToCraft:GetValue())

        local item = Item:CreateFromItemID(itemID)
        if not item:IsItemEmpty() then
            item:ContinueOnItemLoad(function()

                table.insert(reagents, {
                    count = numRequired,
                    link = item:GetItemLink(),
                    init = function(f)
                        f.icon:SetTexture(item:GetItemIcon())
                        f.icon:SetSize(32,32)
        
                        f.label:SetSize(160, 32)

                        if numOwned < numRequired then
                            f.label:SetText(DULL_RED_FONT_COLOR:WrapTextInColorCode(string.format("%d/%d %s", numOwned, numRequired, item:GetItemName())))
                        else
                            f.label:SetText(string.format("%d/%d %s", numOwned, numRequired, item:GetItemName()))
                        end
        
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

    if Auctionator then

        self.details.auctionatorInfo.searchAH:SetScript("OnClick", function()
            if AuctionFrame:IsVisible() then
                local t = {}
                for k, item in ipairs(reagents) do
                    table.insert(t, item.auctionHouseSearchTerm)
                end
        
                Auctionator.API.v1.MultiSearch(addonName, t)
            end
        end)

        self:UpdateAuctionatorPanel(recipe)
    end

end

function GuildbookTradskillsMixin:UpdateAuctionatorPanel(recipe)

    local baseCost = 0;
    local currentCost = 0;
    
    self.details.auctionatorInfo:Show()
    
    for itemID, count in pairs(recipe.reagents) do

        local numOwned = GetItemCount(itemID)
        local numRequired = (count * math.floor(self.details.craftingOptions.quantityToCraft:GetValue())) - numOwned
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

local goldAtlas = "auctionhouse-icon-coin-gold"
local silverAtlas = "auctionhouse-icon-coin-silver"
local copperAtlas = "auctionhouse-icon-coin-copper"

local function makeCoinAtlas(money, textonly)

    local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);

    if textonly then
        return string.format("%dg,%ds,%dc", gold, silver, copper)
    end

    return string.format("%d%s%d%s%d%s",
        gold, CreateAtlasMarkup(goldAtlas, 12, 12),
        silver, CreateAtlasMarkup(silverAtlas, 12, 12),
        copper, CreateAtlasMarkup(copperAtlas, 12, 12)
    )
    
end


function GuildbookTradskillsMixin:SetRecipe(recipe)

    self.selectedRecipe = recipe;

    self:ClearPanels()

    self.details:Show()

    local rgb = ITEM_QUALITY_COLORS[recipe.quality]
    
    self.details.itemButton:Show()
    self.details.itemButton:Init({
        icon = recipe.icon,
        -- onClick = function(f, button)
        --     print(f, button)
        --     HandleModifiedItemClick(recipe.link)
        -- end,
    })
    self.details.itemButton:RegisterForClicks("anyDown")
    self.details.itemButton:SetScript("OnClick", function(f, button)
        if button == "LeftButton" then
            HandleModifiedItemClick(recipe.link)
        else
            local channel = "GUILD"
            local totalCost = 0;
            SendChatMessage(string.format("[Guildbook] Reagents for %s", recipe.link), channel)
            C_Timer.After(0.1, function()
                self.details.reagents.scrollView:ForEachFrame(function(frame)
                    --local icon = select(5, GetItemInfoInstant(frame:GetElementData().link))
                    --local t = CreateSimpleTextureMarkup(icon, 12, 12, 0, 0)
    
                    local itemID = GetItemInfoInstant(frame:GetElementData().link)
                    local cost = Auctionator.API.v1.GetAuctionPriceByItemID(addonName, itemID)
                    cost = cost * frame:GetElementData().count;
                    totalCost = totalCost + cost;
                    SendChatMessage(string.format("%s x%d", frame:GetElementData().link, frame:GetElementData().count), channel)
                end)
            end)
            SendChatMessage(string.format("Estimated cost (based on last AH scan): %s", makeCoinAtlas(totalCost, true)), channel)
        end
    end)
    self.details.itemButton:SetScript("OnEnter", function(f)
        GameTooltip:SetOwner(f, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine(recipe.name)
        GameTooltip:AddLine("Left click to paste link\nRight click to send reagents to guild chat.",1,1,1,true)
        GameTooltip:Show()
    end)
    self.details.itemButton:SetScript("OnLeave", function()
    
    end)
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

                atlasRight = (character:GetOnlineStatus().isOnline == true) and "MonsterFriend" or "MonsterEnemy",
                iconSizeRight = {20, 20},

                onMouseDown = function()
                    addon:TriggerEvent("Character_OnProfileSelected", character)
                end,
            })
        end
    end

    table.sort(crafters, function(a, b)
        return a.atlasRight > b.atlasRight;
    end)

    self.details.crafters.scrollView:SetDataProvider(CreateDataProvider(crafters))
    self.details.crafters:Show()


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



    self.details.craftingOptions.quantityToCraft:SetValueStep(1)
    self.details.craftingOptions.quantityToCraft:SetValue(1)
    self.details.craftingOptions.quantityToCraft:SetScript("OnMouseWheel", function(slider, delta)
        slider:SetValue(math.floor(slider:GetValue() + delta))
    end)
    self.details.craftingOptions.quantityToCraft:SetScript("OnValueChanged", function(slider)
        slider.label:SetText(string.format("%.0f", slider:GetValue()))
        self:UpdateReagents(recipe)
    end)

    self:UpdateReagents(recipe)

    self.details.craftingOptions:Hide()
    if IsPlayerSpell(recipe.spellID) then
        local recipeIndex = self:FindRecipeIndex(recipe.spellID)
        --print(recipeIndex, type(recipeIndex))
        if type(recipeIndex) == "number" then
            --print("inside the if")
            self.details.craftingOptions:Show()
            self.details.craftingOptions.doTradeSkill:SetScript("OnClick", function()
                DoTradeSkill(recipeIndex, math.floor(self.details.craftingOptions.quantityToCraft:GetValue()))
            end)
        end
    end

    self:UpdateLayout()

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

function GuildbookTradskillsMixin:SetOrCreateDataProvider(tradeskillID, onDemand)

    if onDemand then
        local dataProvider = CreateTreeDataProvider()
        self.listview.scrollView:SetDataProvider(dataProvider)
        return dataProvider;

    else

        if not self.tradeskillDataProvider then
            self.tradeskillDataProvider = {}
        end

        if not self.tradeskillDataProvider[tradeskillID] then
            self.tradeskillDataProvider[tradeskillID] = CreateTreeDataProvider()
            self.listview.scrollView:SetDataProvider(self.tradeskillDataProvider[tradeskillID])
            return self.tradeskillDataProvider[tradeskillID]
        else
            self.listview.scrollView:SetDataProvider(self.tradeskillDataProvider[tradeskillID])
        end

    end
    
end

function GuildbookTradskillsMixin:OnCharacterTradeskillSelected(tradeskillID, recipes)

    self.tradeskillDropdown:SetText(Tradeskills:GetLocaleNameFromID(tradeskillID))

    local tradeskillData = Tradeskills:BuildTradeskillDataFromRecipes(recipes)

    --DevTools_Dump(tradeskillData)

    if type(tradeskillData) == "table" and #tradeskillData > 0 then
    
        local dataProvider = self:SetOrCreateDataProvider(nil, true)
        self:LoadTradeskillRecipes(tradeskillID, tradeskillData, dataProvider)
        
        
        --this will cause the recipe index cache to be updated
        GuildbookUI:SelectView(self.name)

    else

    end
end

function GuildbookTradskillsMixin:LoadTradeskillRecipes(tradeskillID, tradeskillData, dataProvider)

    self.details.background:SetTexture(getArtworkForTradeskillID(tradeskillID))

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
    self.statusBar.fadeIn:Play()
    --local headers = {}
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

                        if not dataProvider[itemType] then
                            dataProvider[itemType] = dataProvider:Insert({
                                label = itemType,
                                atlas = "common-icon-forwardarrow",
                                backgroundAtlas = "OBJBonusBar-Top",
                                fontObject = GameFontNormal,
                                isParent = true,
                                init = function(f)
                    
                                    if f:GetElementData():IsCollapsed() then
                                        f.icon:SetTexCoord(0,1,0,1)
                                    else
                                        f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                    end

                                    C_Timer.After(0.001, function()
                                        f.icon:SetTexCoord(0,1,0,1)
                                    end)
                                end,
                            })
                            dataProvider[itemType]:ToggleCollapsed()
                        end

                        if not dataProvider[itemType][itemSubType] then
                            dataProvider[itemType][itemSubType] = dataProvider[itemType]:Insert({
                                label = itemSubType,
                                atlas = "common-icon-forwardarrow",
                                backgroundAtlas = "OBJBonusBar-Top",
                                fontObject = GameFontNormal,
                                isParent = true,
                                init = function(f)
                                    f.icon:SetTexCoord(0,1,0,1)
                    
                                    if f:GetElementData():IsCollapsed() then
                                        f.icon:SetTexCoord(0,1,0,1)
                                    else
                                        f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                    end
                                end,
                            })
                        
                            dataProvider[itemType][itemSubType]:SetSortComparator(sortFunc, true, false)
                            dataProvider[itemType][itemSubType]:ToggleCollapsed()
                        end

                        if (_G[itemEquipLoc]) then

                            if not dataProvider[itemType][itemSubType][itemEquipLoc] then
                                dataProvider[itemType][itemSubType][itemEquipLoc] = dataProvider[itemType][itemSubType]:Insert({
                                    label = _G[itemEquipLoc],
                                    atlas = "common-icon-forwardarrow",
                                    backgroundAtlas = "OBJBonusBar-Top",
                                    fontObject = GameFontNormal,
                                    isParent = true,
                                    init = function(f)
                                        f.icon:SetTexCoord(0,1,0,1)
                        
                                        if f:GetElementData():IsCollapsed() then
                                            f.icon:SetTexCoord(0,1,0,1)
                                        else
                                            f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                        end
                                    end,
                                })
                            
                                dataProvider[itemType][itemSubType][itemEquipLoc]:SetSortComparator(sortFunc, true, false)
                                dataProvider[itemType][itemSubType][itemEquipLoc]:ToggleCollapsed()
                            end

                            if not itemsAdded[itemName] then
                                dataProvider[itemType][itemSubType][itemEquipLoc]:Insert({

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

                                dataProvider[itemType][itemSubType][itemEquipLoc]:Sort()

                            end

                        else

                            if not itemsAdded[itemName] then
                                dataProvider[itemType][itemSubType]:Insert({

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

                                dataProvider[itemType][itemSubType]:Sort()
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

    
                                if not dataProvider[prefix] then
                                    dataProvider[prefix] = dataProvider:Insert({
                                        label = prefix,
                                        atlas = "common-icon-forwardarrow",
                                        backgroundAtlas = "OBJBonusBar-Top",
                                        fontObject = GameFontNormal,
                                        isParent = true,
                                        init = function(f)
                                            f.icon:SetTexCoord(0,1,0,1)
                            
                                            if f:GetElementData():IsCollapsed() then
                                                f.icon:SetTexCoord(0,1,0,1)
                                            else
                                                f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                            end

                                            C_Timer.After(0.001, function()
                                                f.icon:SetTexCoord(0,1,0,1)
                                            end)
                                        end,
                                    })
    
                                    --dataProvider[prefix]:SetSortComparator(sortFunc, true, false)
                                end
                                if not dataProvider[prefix][enchantLocation] then
                                    dataProvider[prefix][enchantLocation] = dataProvider[prefix]:Insert({
                                        label = enchantLocation,
                                        atlas = "common-icon-forwardarrow",
                                        backgroundAtlas = "OBJBonusBar-Top",
                                        fontObject = GameFontNormal,
                                        isParent = true,
                                        init = function(f)
                                            f.icon:SetTexCoord(0,1,0,1)
                            
                                            if f:GetElementData():IsCollapsed() then
                                                f.icon:SetTexCoord(0,1,0,1)
                                            else
                                                f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                            end
                                        end,
                                    })
    
                                    dataProvider[prefix][enchantLocation]:SetSortComparator(sortFunc, true, false)
                                    dataProvider[prefix][enchantLocation]:ToggleCollapsed()
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
    
                                    dataProvider[prefix][enchantLocation]:Insert({
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
    
                                    dataProvider[prefix][enchantLocation]:Sort()
    
                                    spellsAdded[spellID] = true;
                            
                                end

                            else

                                --[[
                                    prof perks
                                ]]

                                local profName = Tradeskills:GetLocaleNameFromID(tradeskillID)

                                if not dataProvider[profName] then
                                    dataProvider[profName] = dataProvider:Insert({
                                        label = profName,
                                        atlas = "common-icon-forwardarrow",
                                        backgroundAtlas = "OBJBonusBar-Top",
                                        fontObject = GameFontNormal,
                                        isParent = true,
                                        init = function(f)
                                            f.icon:SetTexCoord(0,1,0,1)
                            
                                            if f:GetElementData():IsCollapsed() then
                                                f.icon:SetTexCoord(0,1,0,1)
                                            else
                                                f.icon:SetTexCoord(0,1, 1,1, 0,0, 1,0)
                                            end

                                            C_Timer.After(0.001, function()
                                                f.icon:SetTexCoord(0,1,0,1)
                                            end)
                                        end,
                                    })

                                    dataProvider[profName]:SetSortComparator(sortFunc, true, false)
    
                                end

                                if not spellsAdded[spellID] then
                                        
                                    dataProvider[profName]:Insert({
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

                                    dataProvider[profName]:Sort()

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