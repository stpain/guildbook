

local addonName, addon = ...;

local Database = addon.Database;
local Character = addon.Character;
local Tradeskills = addon.Tradeskills;

--abusing Lua, this is a major local variable which will be used to determine column spacing
local CURRENCY_ID_INDEXES = {}
local REPUTATION_ID_INDEXES = {}
local CURRENCY_HEADER_SELECTED;
local REPUTATION_HEADER_SELECTED;

local function setupRow(f, binding, height)
    f:SetHeight(height)

    if binding.backgroundAlpha then
        f.background:SetAlpha(binding.backgroundAlpha)
    else
        f.background:SetAlpha(0)
    end
    if binding.highlightAtlas then
        f.highlight:SetAtlas(binding.highlightAtlas)
    end
    if binding.backgroundAtlas then
        f.background:SetAtlas(binding.backgroundAtlas)
        if binding.backgroundAlpha then
            f.background:SetAlpha(binding.backgroundAlpha)
        else
            f.background:SetAlpha(1)
        end
    else
        if binding.backgroundRGB then
            f.background:SetColorTexture(binding.backgroundRGB.r, binding.backgroundRGB.g, binding.backgroundRGB.b)
        else
            f.background:SetColorTexture(0,0,0)
        end
    end

    if binding.atlas then
        f.icon:SetAtlas(binding.atlas)
    elseif binding.icon then
        f.icon:SetTexture(binding.icon)
    end
    if not binding.icon and not binding.atlas then
        f.icon:SetSize(1, height-4)
    else
        f.icon:SetSize(height-4, height-4)
    end
    if binding.name then
        f.name:SetText(binding.name)
    end
end


GuildbookAltsTreeviewItemBasicMixin = {}
function GuildbookAltsTreeviewItemBasicMixin:OnLoad()
    
end
function GuildbookAltsTreeviewItemBasicMixin:SetDataBinding(binding, height)

end
function GuildbookAltsTreeviewItemBasicMixin:ResetDataBinding()
    
end


GuildbookAltsTreeviewItemMixin = {}
function GuildbookAltsTreeviewItemMixin:OnLoad()
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
end
function GuildbookAltsTreeviewItemMixin:UpdateLayout()
    
    --set the tradeskill labels
    local width = self:GetWidth() - 220;

    local labels = {
        prof1 = 0.3,
        prof2 = 0.3,
        cooking = 0.13,
        fishing = 0.13,
        firstAid = 0.13,
    }

    for k, v in pairs(labels) do
        self[k]:SetWidth(width * v)
    end
end
function GuildbookAltsTreeviewItemMixin:SetDataBinding(binding, height)

    setupRow(self, binding, height)

    if binding.showCheckbox and binding.checkbox_OnClick then
        self.checkbox:Show()
        self.checkbox:SetChecked(binding.isChecked)
        self.checkbox:SetScript("OnClick", binding.checkbox_OnClick)
    else
        self.checkbox:Hide()
    end

    if binding.labels then
        for k, v in pairs(binding.labels) do
            if self[k] then
                self[k]:SetText(v)
                self[k]:Show()
            end
        end
    end

    if binding.onMouseDown then
        self:SetScript("OnMouseDown", binding.onMouseDown)
    end

    self:UpdateLayout()
end
function GuildbookAltsTreeviewItemMixin:ResetDataBinding()
    self.checkbox:Hide()
    self.checkbox:SetChecked(false)
    self.checkbox:SetScript("OnClick", nil)

    for k, fs in ipairs(self.labels) do
        fs:SetText("")
        fs:Hide()
    end
end


GuildbookAltsTreeviewItemEquipmentMixin = {}
function GuildbookAltsTreeviewItemEquipmentMixin:OnLoad()
    self.invSlotIcons = {}
end
function GuildbookAltsTreeviewItemEquipmentMixin:ClearInvSlotIcons()
    for k, frame in pairs(self.invSlotIcons) do
        frame.link = nil
        frame.icon:SetTexture(nil)
        frame.border:SetTexture(nil)
        frame:Hide()
    end
end
function GuildbookAltsTreeviewItemEquipmentMixin:SetDataBinding(binding, height)
   
    setupRow(self, binding, height)

    local function updateSlots(equipment)

        self:ClearInvSlotIcons()

        local height = 24
        local lastFrame
        for k, slotInfo in ipairs(addon.data.inventorySlots) do
            if not self.invSlotIcons[slotInfo.slot] then
                local f = CreateFrame("Frame", nil, self, "GuildbookWrathEraSmallHighlightButton")
                f:SetSize(height, height)
                
                if k == 1 then
                    f:SetPoint("LEFT", 276, 0)
                    lastFrame = f
                else
                    f:SetPoint("LEFT", lastFrame, "RIGHT", 4, 0)
                    lastFrame = f
                end
    
                f.border = f:CreateTexture(nil, "BORDER")
                f.border:SetAllPoints()
                -- f.border:SetPoint("TOPLEFT", -3, 3)
                -- f.border:SetPoint("BOTTOMRIGHT", 2, -2)
    
                f.icon = f:CreateTexture(nil, "BACKGROUND")
                f.icon:SetAllPoints()
                -- f.icon:SetPoint("TOPLEFT", 0.5, -0.5)
                -- f.icon:SetPoint("BOTTOMRIGHT", -1, 1)

                self.invSlotIcons[slotInfo.slot] = f
            end
        end


        for k, slotInfo in ipairs(addon.data.inventorySlots) do
            if equipment.items[slotInfo.slot] then
                self.invSlotIcons[slotInfo.slot].link = equipment.items[slotInfo.slot]
                local _, hex = strsplit("|", equipment.items[slotInfo.slot])
                if hex and (#hex == 9) then
                    -- local r, g, b = CreateColorFromHexString(hex:sub(2,9)):GetRGB()
                    -- self.invSlotIcons[slotInfo.slot].border:SetColorTexture(r, g, b)

                    local atlas = addon.itemQualityAtlas_Borders[hex:sub(2,9)]
                    self.invSlotIcons[slotInfo.slot].border:SetAtlas(atlas)

                    self.invSlotIcons[slotInfo.slot].border:Show()
                end
                self.invSlotIcons[slotInfo.slot].icon:SetTexture(select(5, GetItemInfoInstant(equipment.items[slotInfo.slot])))
                self.invSlotIcons[slotInfo.slot]:Show()
            end
        end
        self.ilvl:SetText(string.format("%.2f", equipment.ilvl))
    end

    if binding.getAltInventory then

        local itemSets = binding.getAltInventory()

        local menu = {
            {
                text = "Equipment",
                isTitle = true,
                notCheckable = true,
            },
        }
        for name, items in pairs(itemSets) do
            table.insert(menu, {
                text = name,
                notCheckable = true,
                func = function()
                    local setinfo = binding.getAltInventory(name)
                    updateSlots(setinfo)
                end,
            })
        end
        self.dropdown:Show()
        self.dropdown:SetScript("OnMouseDown", function(f, b)
            EasyMenu(menu, addon.contextMenu, self.dropdown, 4, 18, "MENU", 0.2)
        end)

        if itemSets.current then
            local setinfo = binding.getAltInventory("current")
            updateSlots(setinfo)
        end

    else
        self.dropdown:Hide()
    end

    if binding.name then
        self.name:SetText(binding.name)
    end

end
function GuildbookAltsTreeviewItemEquipmentMixin:ResetDataBinding()
    self:ClearInvSlotIcons()
end



GuildbookAltsTreeviewCurrencyMixin = {}
function GuildbookAltsTreeviewCurrencyMixin:OnLoad()
    self.currencyIcons = {}
end
function GuildbookAltsTreeviewCurrencyMixin:SetDataBinding(binding, height)

    setupRow(self, binding, height)

    if binding.getCurrencies then
        self.updateCurrencies = function(header)

            for k, v in ipairs(self.currencyIcons) do
                v.icon:SetTexture(nil)
                v.label:SetText(nil)
            end

            --pairs [id] = count
            local selectedCurencies = binding.getCurrencies(header)

            --use this CURRENCY_ID_INDEXES

            table.sort(selectedCurencies, function(a, b)
                if a.currencyID == b.currencyID then
                    return a.count > b.count;
                else
                    return a.currencyID > b.currencyID;
                end
            end)

            local currenciesForHeader = CURRENCY_ID_INDEXES[header]
 
            local height = 24
            local lastFrame
            for k, currencyID in ipairs(currenciesForHeader) do
                if not self.currencyIcons[k] then
                    local f = CreateFrame("Frame", nil, self, "GuildbookWrathEraSmallHighlightButton")
                    f:SetSize(height, height)
                    
                    if k == 1 then
                        f:SetPoint("LEFT", 150, 0)
                        lastFrame = f
                    else
                        f:SetPoint("LEFT", lastFrame, "RIGHT", 50, 0)
                        lastFrame = f
                    end
        
                    f.icon = f:CreateTexture(nil, "ARTWORK")
                    f.icon:SetAllPoints()

                    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontWhite")
                    f.label:SetPoint("LEFT", f, "RIGHT", 4, 0)

                    self.currencyIcons[k] = f
                end

                lastFrame = self.currencyIcons[k]

                self.currencyIcons[k].icon:SetTexture(nil)
                self.currencyIcons[k].label:SetText(" ")
                self.currencyIcons[k]:SetScript("OnEnter", nil)
                self.currencyIcons[k]:SetScript("OnLeave", function()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)

                if selectedCurencies[currencyID] and (currencyID > 0) then
                    local name, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered, rarity = GetCurrencyInfo(currencyID)

                    self.currencyIcons[k].icon:SetTexture(texture)
                    self.currencyIcons[k].label:SetText(selectedCurencies[currencyID])
                    self.currencyIcons[k]:SetScript("OnEnter", function(f)
                        GameTooltip:SetOwner(f, "ANCHOR_TOP")
                        GameTooltip:AddLine(name)
                        --GameTooltip:SetHyperlink(string.format("|Hcurrency:%d:%d", currency.currencyID, currency.count))
                        GameTooltip:Show()
                    end)

                end


            end

        end
    end

end
function GuildbookAltsTreeviewCurrencyMixin:ResetDataBinding()
    self.updateCurrencies = nil;
    for k, v in ipairs(self.currencyIcons) do
        if v.icon and v.label then
            v.icon:SetTexture(nil)
            v.label:SetText(nil)
        end
    end
end


local standingColours = {
    [1] = CreateColorFromHexString("ffcc0000"),
    [2] = CreateColorFromHexString("ffff0000"),
    [3] = CreateColorFromHexString("fff26000"),
    [4] = CreateColorFromHexString("ffe4e400"),
    [5] = CreateColorFromHexString("ff33ff33"),
    [6] = CreateColorFromHexString("ff5fe65d"),
    [7] = CreateColorFromHexString("ff53e9bc"),
    [8] = CreateColorFromHexString("ff2ee6e6"),
}



GuildbookAltsTreeviewReputationMixin = {}
function GuildbookAltsTreeviewReputationMixin:OnLoad()
    self.repFrames = {}
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
end
function GuildbookAltsTreeviewReputationMixin:SetDataBinding(binding, height)

    setupRow(self, binding, height)

    --DevTools_Dump(binding)
    
    if binding.getReputations then
        self.updateReputations = function(header, uiOnly)

            if not header then
                return
            end

            REPUTATION_HEADER_SELECTED = header

            local altReps = binding.getReputations(header)

            local repsForHeader = REPUTATION_ID_INDEXES[header]

            local width = self:GetWidth() - 150 - (#repsForHeader * 4);

            local repFrameWidth = math.floor(width / #repsForHeader)

            local lastFrame;

            for k, frame in ipairs(self.repFrames) do
                frame.label:SetText("")
            end

            for k, repID in ipairs(repsForHeader) do
                
                if not self.repFrames[k] then
                    
                    --local f = CreateFrame("Frame", nil, self)
                    local f = CreateFrame("StatusBar", nil, self)
                    f:SetStatusBarTexture(137012)
                    f:SetSize(repFrameWidth, height-6)

                    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
                    f.label:SetPoint("TOPLEFT")
                    f.label:SetPoint("BOTTOMRIGHT")
                    f.label:SetTextColor(1,1,1)
                    
                    f.background = f:CreateTexture(nil, "BACKGROUND")
                    f.background:SetAllPoints()
                    f.background:SetColorTexture(0.12313, 0.132745, 0.14803, 0.85)

                    if k == 1 then
                        f:SetPoint("LEFT", 150, 0)
                        lastFrame = f;
                    else
                        f:SetPoint("LEFT", lastFrame, "RIGHT", 4, 0)
                        lastFrame = f;
                    end

                    f:SetScript("OnLeave", function()
                        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                    end)

                    self.repFrames[k] = f

                else

                    lastFrame = self.repFrames[k]
                end

                local name = GetFactionInfoByID(repID)

                self.repFrames[k].label:SetText(name)

            end

            if uiOnly then
                for k, frame in ipairs(self.repFrames) do
                    frame:SetWidth(repFrameWidth)
                end
                return;
            else
                for k, frame in ipairs(self.repFrames) do
                    local repID = repsForHeader[k]
                    if altReps[repID] and altReps[repID].topValue and altReps[repID].currentValue then
                        frame:SetMinMaxValues(0, altReps[repID].topValue)
                        frame:SetValue(altReps[repID].currentValue)
                        local r, g, b = standingColours[altReps[repID].standingID]:GetRGB()
                        frame:SetStatusBarColor(r, g, b)

                        frame:SetScript("OnEnter", function()
                            local name, desc = GetFactionInfoByID(repID)
                            GameTooltip:SetOwner(frame, "ANCHOR_TOP")
                            GameTooltip:AddLine(name)
                            GameTooltip:AddLine(desc, 1,1,1,true)
                            GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1);
                            GameTooltip:AddDoubleLine(
                                standingColours[altReps[repID].standingID]:WrapTextInColorCode(_G["FACTION_STANDING_LABEL"..altReps[repID].standingID]),
                                string.format("%d|cffffffff/|r%d", altReps[repID].currentValue, altReps[repID].topValue)
                            )
                            --GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1);
                            --GameTooltip_ShowStatusBar(GameTooltip, 0, altReps[repID].topValue, altReps[repID].currentValue, "")

                            GameTooltip_ShowProgressBar(GameTooltip, 0, altReps[repID].topValue, altReps[repID].currentValue, string.format("%.1f%%", (altReps[repID].currentValue / altReps[repID].topValue) * 100))
                            GameTooltip:Show()
                        end)
                        frame:Show()
                    else
                        frame:Hide()
                    end
                end
            end
            self:UpdateLayout()
        end
    end
end
function GuildbookAltsTreeviewReputationMixin:ResetDataBinding()
    self.updateReputations = nil;
    for k, frame in ipairs(self.repFrames) do
        frame.label:SetText("")
        frame:Hide()
    end
end
function GuildbookAltsTreeviewReputationMixin:UpdateLayout()
    if self.updateReputations then
        self.updateReputations(REPUTATION_HEADER_SELECTED, true)
    end
end





GuildbookAltsMixin = {
    name = "Alts",
    alts = {},

    --these are passed/called by the treeview elements(items) and function to setup the row UI/data
    elementFuncs = {
        summary = {
            level = function(alt)
                return alt.data.level;
            end,
            mainSpec = function(alt)
                return alt:GetSpec("primary")
            end,
            zone = function(alt)
                return alt.data.onlineStatus.zone or "-";
            end,
            copper = function(alt)
                return GetCoinTextureString(alt.data.containers.copper or 0)
            end,
        },

        tradeskills = {
            prof1 = function(alt)
                return string.format("%s [%d] %s", CreateAtlasMarkup(alt:GetTradeskillIcon(1), 20, 20), alt:GetTradeskillLevel(1), alt:GetTradeskillName(1))
            end,
            prof2 = function(alt)
                --return string.format("[%d] %s", alt:GetTradeskillLevel(2), alt:GetTradeskillName(2))
                return string.format("%s [%d] %s", CreateAtlasMarkup(alt:GetTradeskillIcon(2), 20, 20), alt:GetTradeskillLevel(2), alt:GetTradeskillName(2))
            end,
            cooking = function(alt)
                --return string.format("%s [%d]", Tradeskills:GetLocaleNameFromID(185), alt:GetCookingLevel())
                return alt:GetCookingLevel()
            end,
            fishing = function(alt)
                --return string.format("%s [%d]", Tradeskills:GetLocaleNameFromID(356), alt:GetFishingLevel())
                return alt:GetFishingLevel()
            end,
            firstAid = function(alt)
                --return string.format("%s [%d]", Tradeskills:GetLocaleNameFromID(129), alt:GetFirstAidLevel())
                return alt:GetFirstAidLevel()
            end,
        },

        equipment = function(alt)
            -- local t = {}
            -- for name, items in pairs(alt.data.inventory) do
            --     t[name] = {
            --         ilvl = alt:GetItemLevel(name),
            --         items = items,
            --     }
            -- end
            -- return t;

            return function(setName)
                if not setName then
                    local t = {}
                    for name, items in pairs(alt.data.inventory) do
                        t[name] = {
                            ilvl = alt:GetItemLevel(name),
                            items = items,
                        }
                    end
                    return t;
                else
                    if alt.data.inventory[setName] then
                        local t = {}
                        t.ilvl = alt:GetItemLevel(setName)
                        t.items = alt.data.inventory[setName]
                        return t;
                    end
                end
            end
        end,

        currency = function(alt)
            return function(header)
                local t = {}
                if Database.db.myCharacters and Database.db.myCharacters[alt.data.name] and Database.db.myCharacters[alt.data.name].currencies and Database.db.myCharacters[alt.data.name].currencies[header] then
                    for k, dataString in ipairs(Database.db.myCharacters[alt.data.name].currencies[header]) do
                        local id, count = strsplit(":", dataString)

                        t[tonumber(id)] = tonumber(count);
                    end
                end
                return t;
            end
        end,

        reputation = function(alt)
            return function(header)
                local t = {}
                if Database.db.myCharacters and Database.db.myCharacters[alt.data.name] and Database.db.myCharacters[alt.data.name].reputations and Database.db.myCharacters[alt.data.name].reputations[header] then
                    for k, dataString in ipairs(Database.db.myCharacters[alt.data.name].reputations[header]) do
                        local factionID, standingId, currentValue, topValue = strsplit(":", dataString)

                        t[tonumber(factionID)] = {
                            standingID = tonumber(standingId),
                            currentValue = tonumber(currentValue),
                            topValue = tonumber(topValue),
                        }
                    end
                end
                return t;
            end
        end,
    }
}

--[[
"1037:7:26844" alliance vanguard for starglows
5844 through revered
	local colorIndex = standingID;
	local barColor = FACTION_BAR_COLORS[colorIndex];
]]

local repTotals = {
    [0] = -21000,
    [1] = -12000,
    [2] = -6000,
    [3] = -3000,
    [4] = 0,
    [5] = 3000,
    [6] = 6000,
    [7] = 12000,
    [8] = 21000,
}

local tabFrameNames = {
    "summary",
    "tradeskills",
    "equipment",
    "currency",
    "reputation",
}

function GuildbookAltsMixin:OnLoad()

    addon:RegisterCallback("Database_OnCharacterRemoved", self.OnCharacterDeleted, self)

    local tabs = {
        {
            label = "Summary",
            width = 100,
            panel = self.tabContainer.summary,
        },
        {
            label = "Professions",
            width = 100,
            panel = self.tabContainer.tradeskills,
        },
        {
            label = "Equipment",
            width = 100,
            panel = self.tabContainer.equipment,
        },
        {
            label = "Currency",
            width = 100,
            panel = self.tabContainer.currency,
        },
        {
            label = "Reputations",
            width = 100,
            panel = self.tabContainer.reputation,
        },
    }
    self.tabContainer:CreateTabButtons(tabs)

    self.tabContainer:SetPoint("TOPLEFT", 0, -30)
    self.tabContainer:SetPoint("BOTTOMRIGHT", -0, 0)

    for _, name in ipairs(tabFrameNames) do
        self.tabContainer[name]:SetAllPoints()
        self.tabContainer[name]:Hide()
        self.tabContainer[name]:SetScript("OnShow", function()
            self:LoadAlts(name, self.tabContainer[name].listview, self.elementFuncs[name], (name == "summary"))
        end)
    end

    self.tabContainer.summary:Show()

    self.tabContainer.currency.currencyHeaderDropdown:SetText("Select Category")

    self.tabContainer.currency.currencyHeaderDropdown:SetScript("OnShow", function()
        
        local currencyMenu = {}
        local added = {}
        CURRENCY_ID_INDEXES = {}
        local currencyIDsAdded = {}
        if Database.db.myCharacters then
            for name, info in pairs(Database.db.myCharacters) do
                if info.currencies and (next(info.currencies) ~= nil) then
                    for header, dataStrings in pairs(info.currencies) do
                        if not added[header] then
                            table.insert(currencyMenu, {
                                text = header,
                                func = function()
                                    self.tabContainer.currency.listview.scrollView:ForEachFrame(function(f)
                                        if f.updateCurrencies then
                                            f.updateCurrencies(header)
                                        end
                                    end)

                                    CURRENCY_HEADER_SELECTED = header
                                end,
                            })
                            CURRENCY_ID_INDEXES[header] = {}
                            currencyIDsAdded[header] = {}
                            added[header] = true
                        end

                        for k, v in ipairs(dataStrings) do
                            local id, count = strsplit(":", v)
                            if not currencyIDsAdded[header][id] then
                                table.insert(CURRENCY_ID_INDEXES[header], tonumber(id))
                                currencyIDsAdded[header][id] = true
                            end
                        end
                    end

                    for header, ids in pairs(CURRENCY_ID_INDEXES) do
                        table.sort(CURRENCY_ID_INDEXES[header], function(a, b)
                            return a > b;
                        end)
                    end
                end
            end
        end

        self.tabContainer.currency.currencyHeaderDropdown:SetMenu(currencyMenu)
    end)

    self.tabContainer.reputation.reputationHeaderDropdown:SetText("Select Category")

    self.tabContainer.reputation.reputationHeaderDropdown:SetScript("OnShow", function()

        local reputationMenu = {}
        local added = {}
        REPUTATION_ID_INDEXES = {}
        local repIDsAdded = {}

        if Database.db.myCharacters then
            for name, info in pairs(Database.db.myCharacters) do
                if info.reputations and (next(info.reputations) ~= nil) then
                    for header, dataStrings in pairs(info.reputations) do
                        if not added[header] then
                            table.insert(reputationMenu, {
                                text = header,
                                func = function()
                                    self.tabContainer.reputation.listview.scrollView:ForEachFrame(function(f)
                                        if f.updateReputations then
                                            f.updateReputations(header)
                                        end
                                    end)

                                    REPUTATION_HEADER_SELECTED = header
                                end,
                            })
                            REPUTATION_ID_INDEXES[header] = {}
                            repIDsAdded[header] = {}
                            added[header] = true
                        end

                        for k, v in ipairs(dataStrings) do
                            local id, count = strsplit(":", v)
                            if not repIDsAdded[header][id] then
                                table.insert(REPUTATION_ID_INDEXES[header], tonumber(id))
                                repIDsAdded[header][id] = true
                            end
                        end
                    end

                    for header, ids in pairs(REPUTATION_ID_INDEXES) do
                        table.sort(REPUTATION_ID_INDEXES[header], function(a, b)
                            return a > b;
                        end)
                    end
                end
            end
        end
        self.tabContainer.reputation.reputationHeaderDropdown:SetMenu(reputationMenu)
    end)

    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)

    addon.AddView(self)
end

function GuildbookAltsMixin:OnCharacterDeleted()
    self:LoadAlts("summary", self.tabContainer.summary.listview, self.elementFuncs.summary, true)
end

function GuildbookAltsMixin:UpdateLayout()
    
    --set the tradeskill labels
    local width = self.tabContainer.tradeskills:GetWidth() - 218;

    local labels = {
        prof1 = 0.3,
        prof2 = 0.3,
        cooking = 0.13,
        fishing = 0.13,
        firstAid = 0.13,
    }

    for k, v in pairs(labels) do
        self.tabContainer.tradeskills[k.."Header"]:SetWidth(width * v)
    end
end

function GuildbookAltsMixin:OnShow()
    self:UpdateLayout()
end

function GuildbookAltsMixin:CreateCharacterEntry(template, name, funcs, showCheckbox)

    local alt;
    if not addon.characters[name] then
        alt = Character:CreateFromData(Database.db.characterDirectory[name])
    else
        alt = addon.characters[name]
    end
    local r, g, b = RAID_CLASS_COLORS[select(2, GetClassInfo(alt.data.class))]:GetRGB()
    local isMain = (alt.data.name == alt.data.mainCharacter) and true or false;

    local onMouseDown;
    if showCheckbox then
        onMouseDown = function(f, b)
            if b == "RightButton" then
                local menu = {
                    {
                        text = OPTIONS,
                        isTitle = true,
                        notCheckable = true,
                    },
                    {
                        text = "View Profile",
                        notCheckable = true,
                        func = function()
                            addon:TriggerEvent("Character_OnProfileSelected", alt)
                        end
                    },
                    {
                        text = DELETE,
                        notCheckable = true,
                        func = function()
                            StaticPopup_Show("GuildbookDeleteCharacter", name, nil, name)
                            --self:LoadAlts("summary", self.tabContainer.summary.listview, self.elementFuncs.summary, true)
                        end
                    },
                }
                EasyMenu(menu, addon.contextMenu, "cursor", -2, 2, "MENU", 0.2)
            end
        end
    end

    local t = {
        atlas = alt:GetClassSpecAtlasName(),
        name = alt:GetName(true, "short"),

        labels = {},

        backgroundAlpha = (isMain == true) and 0.15 or 0.04,
        backgroundRGB = {r = r, g = g, b = b},

        --this only exists on the summary tab
        showCheckbox = showCheckbox,
        isChecked = (alt.data.name == alt.data.mainCharacter),
        checkbox_OnClick = function()

            alt:SetMainCharacter(alt.data.name, true)

            --fetch your characters for the guild
            local alts = Database:GetMyCharactersForGuild(addon.thisGuild)
            -- set the new main character
            --Database:SetMainCharacterForAlts(addon.thisGuild, alt.data.name, alts)

            --this will trigger a comms event from the alt object
            --other guild members will receive the comms and it'll use the alt name
            alt:UpdateAlts(alts, true)

            self:LoadAlts("summary", self.tabContainer.summary.listview, self.elementFuncs.summary, true)
        end,

        onMouseDown = onMouseDown,

        --sort
        sortLevel = alt.data.level
    }

    --these 2 are just elements with fonstrings for which we just set the t.labels data
    if template == "summary" or template == "tradeskills" then
        for k, v in pairs(funcs) do
            t.labels[k] = v(alt)
        end

        --this uses frames/icons
    elseif template == "equipment" then
        t.getAltInventory = funcs(alt)

        --this uses frames/icons
    elseif template == "currency" then
        t.getCurrencies = funcs(alt)

        --this uses frames/icons
    elseif template == "reputation" then
        t.getReputations = funcs(alt)


    end

    return t;

end

function GuildbookAltsMixin:LoadAlts(template, treeview, funcs, showCheckbox)

    local added = {}
    local guilds = {}

    local copper = 0;

    local sortFunc = function(a, b)
        if a:GetData().sortLevel and b:GetData().sortLevel then
            return a:GetData().sortLevel > b:GetData().sortLevel;
        end
    end

    local dataProvider = CreateTreeDataProvider()
    treeview.scrollView:SetDataProvider(dataProvider)

    if Database and Database.db then

        for guildname, info in pairs(Database.db.guilds) do

            if template == "summary" then
                copper = 0;
            end

            local t = {}
            for name, characterData in pairs(Database.db.myCharacters) do

                if info.members[name] and Database.db.characterDirectory[name] then

                    copper = copper + (Database.db.characterDirectory[name].containers.copper or 0);

                    local entry = self:CreateCharacterEntry(template, name, funcs, showCheckbox)
        
                    table.insert(t, entry)

                    added[name] = true
        
                end

            end

            --GetCoinTextureString(copper)

            local guildNameLabel = string.format("[%d] %s", #t or 0, guildname)

            if template == "summary" then
                guilds[guildname] = dataProvider:Insert({
                    name = guildNameLabel,
                    atlas = "common-icon-forwardarrow",
                    backgroundAtlas = "Talent-Background",
                    fontObject = GameFontNormal,
                    isParent = true,
                    labels = { copper = GetCoinTextureString(copper) },
                })

            else
                guilds[guildname] = dataProvider:Insert({
                    name = guildNameLabel,
                    atlas = "common-icon-forwardarrow",
                    backgroundAtlas = "Talent-Background",
                    fontObject = GameFontNormal,
                    isParent = true,
                })
            end

            -- guilds[guildname] = dataProvider:Insert({
            --     name = guildname,
            --     atlas = "common-icon-forwardarrow",
            --     backgroundAtlas = "Talent-Background",
            --     fontObject = GameFontNormal,
            --     isParent = true,
            -- })


            guilds[guildname]:SetSortComparator(sortFunc, true, true)

            for k, alt in ipairs(t) do
                guilds[guildname]:Insert(alt)
            end


            guilds[guildname]:Sort()

            -- if template == "summary" then
            --     guilds[guildname]:Insert({
            --         name = " ",
            --         atlas = "ShipMissionIcon-Treasure-Map",
            --         labels = { copper = GetCoinTextureString(copper), },

            --         sortLevel = -1,
            --     })
            -- end

        end


        guilds["other"] = dataProvider:Insert({
            name = OTHER,
            atlas = "common-icon-forwardarrow",
            backgroundAtlas = "Talent-Background",
            fontObject = GameFontNormal,
            isParent = true,
        })

        guilds["other"]:SetSortComparator(sortFunc, true, true)

        for name, info in pairs(Database.db.myCharacters) do

            if not added[name] and Database.db.characterDirectory[name] then
            
                local entry = self:CreateCharacterEntry(template, name, funcs, showCheckbox)
        
                guilds["other"]:Insert(entry)

                added[name] = true

            end
        end

        guilds["other"]:Sort()

        --apply any selected info
        if template == "currency" then
            if type(CURRENCY_HEADER_SELECTED) == "string" then
                self.tabContainer.currency.listview.scrollView:ForEachFrame(function(f)
                    if f.updateCurrencies then
                        f.updateCurrencies(CURRENCY_HEADER_SELECTED)
                    end
                end)
            end
        end

        if template == "reputation" then
            if type(REPUTATION_HEADER_SELECTED) == "string" then
                self.tabContainer.reputation.listview.scrollView:ForEachFrame(function(f)
                    if f.updateReputations then
                        f.updateReputations(REPUTATION_HEADER_SELECTED)
                    end
                end)
            end
        end

    end

end
