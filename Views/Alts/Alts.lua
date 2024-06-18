

local addonName, addon = ...;

local Database = addon.Database;
local Character = addon.Character;
local Tradeskills = addon.Tradeskills;








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
    self:SetHeight(height)

    if binding.backgroundAlpha then
        self.background:SetAlpha(binding.backgroundAlpha)
    else
        self.background:SetAlpha(0)
    end
    if binding.highlightAtlas then
        self.highlight:SetAtlas(binding.highlightAtlas)
    end
    if binding.backgroundAtlas then
        self.background:SetAtlas(binding.backgroundAtlas)
        if binding.backgroundAlpha then
            self.background:SetAlpha(binding.backgroundAlpha)
        else
            self.background:SetAlpha(1)
        end
    else
        if binding.backgroundRGB then
            self.background:SetColorTexture(binding.backgroundRGB.r, binding.backgroundRGB.g, binding.backgroundRGB.b)
        else
            self.background:SetColorTexture(0,0,0)
        end
    end

    if binding.atlas then
        self.icon:SetAtlas(binding.atlas)
    elseif binding.icon then
        self.icon:SetTexture(binding.icon)
    end
    if not binding.icon and not binding.atlas then
        self.icon:SetSize(1, height-4)
    else
        self.icon:SetSize(height-4, height-4)
    end

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

    if binding.equipment then
        for slot, link in pairs(binding.equipment) do

        end
    end



    if binding.name then
        self.name:SetText(binding.name)
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
    local height = 22
    local lastFrame
    for k, slotInfo in ipairs(addon.data.inventorySlots) do
        if not self[slotInfo.slot] then
            local f = CreateFrame("Frame", nil, self, "GuildbookWrathEraSmallHighlightButton")
            f:SetSize(height, height)
            
            if k == 1 then
                f:SetPoint("LEFT", 276, 0)
                lastFrame = f
            else
                f:SetPoint("LEFT", lastFrame, "RIGHT", 4, 0)
                lastFrame = f
            end

            f.icon = f:CreateTexture(nil, "ARTWORK")
            f.icon:SetAllPoints()
            self[slotInfo.slot] = f
        end
    end
end
function GuildbookAltsTreeviewItemEquipmentMixin:SetDataBinding(binding, height)
    self:SetHeight(height)

    if binding.backgroundAlpha then
        self.background:SetAlpha(binding.backgroundAlpha)
    else
        self.background:SetAlpha(0)
    end
    if binding.highlightAtlas then
        self.highlight:SetAtlas(binding.highlightAtlas)
    end
    if binding.backgroundAtlas then
        self.background:SetAtlas(binding.backgroundAtlas)
        if binding.backgroundAlpha then
            self.background:SetAlpha(binding.backgroundAlpha)
        else
            self.background:SetAlpha(1)
        end
    else
        if binding.backgroundRGB then
            self.background:SetColorTexture(binding.backgroundRGB.r, binding.backgroundRGB.g, binding.backgroundRGB.b)
        else
            self.background:SetColorTexture(0,0,0)
        end
    end

    if binding.atlas then
        self.icon:SetAtlas(binding.atlas)
    elseif binding.icon then
        self.icon:SetTexture(binding.icon)
    end
    if not binding.icon and not binding.atlas then
        self.icon:SetSize(1, height-4)
    else
        self.icon:SetSize(height-4, height-4)
    end

    local function updateSlots(equipment)
        for k, slotInfo in ipairs(addon.data.inventorySlots) do
            self[slotInfo.slot].link = nil
            self[slotInfo.slot].icon:SetTexture(nil)
            if equipment.items[slotInfo.slot] then
                self[slotInfo.slot].link = equipment.items[slotInfo.slot]
                self[slotInfo.slot].icon:SetTexture(select(5, GetItemInfoInstant(equipment.items[slotInfo.slot])))
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
    
end
















GuildbookAltsMixin = {
    name = "Alts",
    alts = {},

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
                return string.format("%s [%d]", alt:GetTradeskillName(1), alt:GetTradeskillLevel(1))
            end,
            prof2 = function(alt)
                return string.format("%s [%d]", alt:GetTradeskillName(2), alt:GetTradeskillLevel(2))
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
    }
}

function GuildbookAltsMixin:OnLoad()

    self.tabContainer:SetPoint("TOPLEFT", 4, -100)
    self.tabContainer:SetPoint("BOTTOMRIGHT", -4, 4)

    self.tabContainer.summary:SetAllPoints()
    self.tabContainer.tradeskills:SetAllPoints()
    self.tabContainer.equipment:SetAllPoints()
    self.tabContainer.tradeskills:Hide()
    self.tabContainer.equipment:Hide()

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
    }
    self.tabContainer:CreateTabButtons(tabs)

    self.tabContainer.summary:SetScript("OnShow", function()
        self:LoadAlts("summary", self.tabContainer.summary.listview, self.elementFuncs.summary, true)
    end)
    self.tabContainer.tradeskills:SetScript("OnShow", function()
        self:LoadAlts("tradeskills", self.tabContainer.tradeskills.listview, self.elementFuncs.tradeskills, false)
    end)
    self.tabContainer.equipment:SetScript("OnShow", function()
        self:LoadAlts("equipment", self.tabContainer.equipment.listview, self.elementFuncs.equipment, false)
    end)

    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)

    addon.AddView(self)
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
    --self:LoadAlts()
    self:UpdateLayout()
end

function GuildbookAltsMixin:CreateCharacterEntry(template, name, funcs, showCheckbox)

    local alt = Character:CreateFromData(Database.db.characterDirectory[name])
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
                        text = DELETE,
                        notCheckable = true,
                        func = function()
                            Database.db.myCharacters[name] = nil;
                            self:LoadAlts("summary", self.tabContainer.summary.listview, self.elementFuncs.summary, true)
                        end
                    }
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

    for guildname, info in pairs(Database.db.guilds) do

        if template == "summary" then
            copper = 0;
        end

        local t = {}
        for name, isMain in pairs(Database.db.myCharacters) do

            if info.members[name] and Database.db.characterDirectory[name] then

                copper = copper + (Database.db.characterDirectory[name].containers.copper or 0);

                local entry = self:CreateCharacterEntry(template, name, funcs, showCheckbox)
    
                table.insert(t, entry)

                added[name] = true
    
            end

        end

        --GetCoinTextureString(copper)

        if template == "summary" then
            guilds[guildname] = dataProvider:Insert({
                name = guildname,
                atlas = "common-icon-forwardarrow",
                backgroundAtlas = "Talent-Background",
                fontObject = GameFontNormal,
                isParent = true,
                labels = { copper = GetCoinTextureString(copper) },
            })

        else
            guilds[guildname] = dataProvider:Insert({
                name = guildname,
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

    for name, isMain in pairs(Database.db.myCharacters) do

        if not added[name] and Database.db.characterDirectory[name] then
        
            local entry = self:CreateCharacterEntry(template, name, funcs, showCheckbox)
    
            guilds["other"]:Insert(entry)

            added[name] = true

        end
    end


    --DevTools_Dump(alts)

    --collectgarbage()
end