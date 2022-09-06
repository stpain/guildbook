

local addonName, addon = ...;

addon.playerContainers = {};

local LOCALE = GetLocale()
local Database = addon.Database;
local Colours = addon.Colours;
local L = addon.Locales;
local Comms = addon.Comms;
local Guild = addon.Guild;
local Tradeskills = addon.Tradeskills;
local UI_WIDTH, UI_HEIGHT;
local showHelptips = false;

local tradeskills = {
    "Alchemy",
    "Blacksmithing",
    "Enchanting",
    "Engineering",
    "Inscription",
    "Jewelcrafting",
    "Leatherworking",
    "Tailoring",
    "Mining",
    "Cooking",
}
local talentTabsToBackground = {
    DEATHKNIGHT = {
        [1] = "DeathKnightBlood", 
        [2] = "DeathKnightFrost", 
        [3] = "DeathKnightUnholy",
    },
	DRUID = {
        [1] = "DruidBalance", 
        [2] = "DruidFeralCombat", 
        [3] = "DruidRestoration",
    },
	HUNTER = {
        [1] = "HunterBeastMastery", 
        [2] = "HunterMarksmanship", 
        [3] = "HunterSurvival",
    },
--	"HunterPetCunning", "HunterPetFerocity", "HunterPetTenacity",},
	MAGE = {
        [1] = "MageArcane", 
        [2] = "MageFire", 
        [3] = "MageFrost",
    },
	PALADIN = {
        [1] = "PaladinHoly", 
        [2] = "PaladinProtection",
        [3] = "PaladinCombat",
    },
	PRIEST = {
        [1] = "PriestDiscipline", 
        [2] = "PriestHoly", 
        [3] = "PriestShadow",
    },
	ROGUE = {
        [1] = "RogueAssassination", 
        [2] = "RogueCombat", 
        [3] = "RogueSubtlety",
    },
	SHAMAN = {
        [1] = "ShamanElementalCombat", 
        [2] = "ShamanEnhancement", 
        [3] = "ShamanRestoration",
    },
	WARLOCK = {
        [1] = "WarlockCurses", 
        [2] = "WarlockSummoning", 
        [3] = "WarlockDestruction",
    },
	WARRIOR = {
        [1] = "WarriorArms", 
        [2] = "WarriorFury", 
        [3] = "WarriorProtection",
    },
}
local characterStats = {
    ["attributes"] = {
        { key = "Strength", displayName = L["STRENGTH"], },
        { key = "Agility", displayName = L["AGILITY"], },
        { key = "Stamina", displayName = L["STAMINA"], },
        { key = "Intellect", displayName = L["INTELLECT"], },
        { key = "Spirit", displayName = L["SPIRIT"], },
    },
    ["defence"] = {
        { key = "Armor", displayName = L["ARMOR"], },
        { key = "Defence", displayName = L["DEFENSE"], },
        { key = "Dodge", displayName = L["DODGE"], },
        { key = "Parry", displayName = L["PARRY"], },
        { key = "Block", displayName = L["BLOCK"], },
    },
    ["melee"] = {
        { key = "Expertise", displayName = L["EXPERTISE"], },
        { key = "MeleeHit", displayName = L["HIT_CHANCE"], },
        { key = "MeleeCrit", displayName = L["MELEE_CRIT"], },
        { key = "MeleeDmgMH", displayName = L["MH_DMG"], },
        { key = "MeleeDpsMH", displayName = L["MH_DPS"], },
        { key = "MeleeDmgOH", displayName = L["OH_DMG"], },
        { key = "MeleeDpsOH", displayName = L["OH_DPS"], },
    },
    ["ranged"] = {
        { key = "RangedHit", displayName = L["RANGED_HIT"], },
        { key = "RangedCrit", displayName = L["RANGED_CRIT"], },
        { key = "RangedDmg", displayName = L["RANGED_DMG"], },
        { key = "RangedDps", displayName = L["RANGED_DPS"], },
    },
    ["spells"] = {
        { key = "Haste", displayName = L["SPELL_HASTE"], },
        { key = "ManaRegen", displayName = L["MANA_REGEN"], },
        { key = "ManaRegenCasting", displayName = L["MANA_REGEN_CASTING"], },
        { key = "SpellHit", displayName = L["SPELL_HIT"], },
        { key = "SpellCrit", displayName = L["SPELL_CRIT"], },
        { key = "HealingBonus", displayName = L["HEALING_BONUS"], },
        { key = "SpellDmgHoly", displayName = L["SPELL_DMG_HOLY"], },
        { key = "SpellDmgFrost", displayName = L["SPELL_DMG_FROST"], },
        { key = "SpellDmgShadow", displayName = L["SPELL_DMG_SHADOW"], },
        { key = "SpellDmgArcane", displayName = L["SPELL_DMG_ARCANE"], },
        { key = "SpellDmgFire", displayName = L["SPELL_DMG_FIRE"], },
        { key = "SpellDmgNature", displayName = L["SPELL_DMG_NATURE"], },
    }
}



















GuildbookMixin = {};
GuildbookMixin.selectedGuild = nil;
GuildbookMixin.guilds = {};
GuildbookMixin.workOrders = {};


---set the view
---@param frame string the key for the new view
---@param showMenu boolean sets if the menu is kept open
function GuildbookMixin:OpenTo(frame, showMenu)

    self.guild:Hide()

    self.guild.home:Hide()
    self.guild.home.info:Hide()

    self.guild.home.character:Hide()

    self.guild.background:SetTexture(nil)

    self.guild.tradeskills:Hide()

    self.settings:Hide()
    self.profile:Hide()
    self.help:Hide()
    self.menu:Hide()

    if frame == "guild" then
        self.guild:Show()
        self.guild.home:Show()
        self.guild.home.info:Show()

    elseif frame == "tradeskills" then
        self.guild:Show()
        self.guild.tradeskills:Show()

    elseif frame == "character" then
        self.guild:Show()
        self.guild.home:Show()
        self.guild.home.character:Show()

    else
        if self[frame] then
            self[frame]:Show()
        end

    end

    if showMenu ~= nil then
        self.menu:SetShown(showMenu)
    end

    if showMenu == true then
        self.openMenu:GetNormalTexture():SetRotation(1.57)
        self.openMenu:Disable()
    else
        self.openMenu:GetNormalTexture():SetRotation(0)
        self.openMenu:Enable()
    end

end

---sets the text for the status text located in the top right 
---@param text string text to display
function GuildbookMixin:SetStatusText(text)

    self.statusText:SetText(text)

    C_Timer.After(5, function()
        self.statusText:SetText("-")
    end)
end


function GuildbookMixin:OnLoad()

    self:RegisterForDrag("LeftButton")

    self.welcomeMessage.text:SetText(L["WELCOME_MESSAGE"])

    self.title:SetText(string.format("%s v%s", addonName, GetAddOnMetadata(addonName, "Version")))

    --set some colours
    self.border:SetColorTexture(Colours.StoneGold:GetRGB())
    self.topBarBackground:SetColorTexture(Colours.BrownGrey:GetRGB())
    self.menu.background:SetColorTexture(Colours.MudBrown:GetRGB())

    local function setColours(style)
        self.background:SetAtlas(style.background)
        self.border:SetColorTexture(style.border:GetRGB())
        self.topBarBackground:SetColorTexture(style.topBar:GetRGB())
        self.menu.background:SetColorTexture(style.menuBackground:GetRGB())
    end

    local stylesMenu = {}
    for k, v in pairs(addon.styles) do
        table.insert(stylesMenu, {
            text = k,
            func = function()
                setColours(v)
            end,
        })
    end
    self.settings.scrollChild.selectStyle.menu = stylesMenu

    self.menu.header:SetText(L["GUILDS_LIST_HEADER"])

    --grab size 
    UI_WIDTH, UI_HEIGHT = self:GetSize()


    --scale the helptips up for other languages
    for k, tip in ipairs(self.guild.tradeskills.helptips) do
        local w, h = tip:GetSize()
        tip:SetSize(w*1.2, h*1.2)
    end
    for k, tip in ipairs(self.guild.home.character.scrollChild.helptips) do
        local w, h = tip:GetSize()
        tip:SetSize(w*1.2, h*1.2)
    end
    for k, tip in ipairs(self.profile.helptips) do
        local w, h = tip:GetSize()
        tip:SetSize(w*1.2, h*1.2)
    end

    --register the callbacks
    addon:RegisterCallback("OnDatabaseInitialised", self.OnDatabaseInitialised, self)
    addon:RegisterCallback("OnCommsMessage", self.OnCommsMessage, self)
    addon:RegisterCallback("OnCommsBlocked", self.SetStatusText, self)
    addon:RegisterCallback("OnAddonLoaded", self.OnAddonLoaded, self)
    addon:RegisterCallback("OnPlayerEnteringWorld", self.OnPlayerEnteringWorld, self)
    addon:RegisterCallback("OnChatMessageGuild", self.OnChatMessageGuild, self)
    addon:RegisterCallback("OnGuildChanged", self.OnGuildChanged, self)
    addon:RegisterCallback("OnGuildRosterUpdate", self.OnGuildRosterUpdate, self)
    addon:RegisterCallback("OnGuildDataImported", self.OnGuildDataImported, self)
    addon:RegisterCallback("OnPlayerBagsUpdated", self.OnPlayerBagsUpdated, self)
    addon:RegisterCallback("OnPlayerSecondarySkillsScanned", self.OnPlayerSecondarySkillsScanned, self)
    addon:RegisterCallback("OnPlayerTradeskillRecipesScanned", self.OnPlayerTradeskillRecipesScanned, self)
    addon:RegisterCallback("OnPlayerTradeskillRecipesLinked", self.OnPlayerTradeskillRecipesLinked, self)
    addon:RegisterCallback("OnPlayerEquipmentChanged", self.OnPlayerEquipmentChanged, self)
    addon:RegisterCallback("OnPlayerStatsChanged", self.OnPlayerStatsChanged, self)
    addon:RegisterCallback("OnPlayerTalentSpecChanged", self.OnPlayerTalentSpecChanged, self)
    addon:RegisterCallback("AltManagerListviewItem_OnCheckButtonClicked", self.AltManagerListviewItem_OnCheckButtonClicked, self)
    addon:RegisterCallback("TradeskillListviewItem_OnMouseDown", self.TradeskillListviewItem_OnMouseDown, self)
    addon:RegisterCallback("TradeskillListviewItem_OnAddToWorkOrder", self.TradeskillListviewItem_OnAddToWorkOrder, self)
    addon:RegisterCallback("TradeskillListviewItem_RemoveFromWorkOrder", self.TradeskillListviewItem_RemoveFromWorkOrder, self)
    addon:RegisterCallback("TradeskillCrafter_SendWorkOrder", self.TradeskillCrafter_SendWorkOrder, self)
    addon:RegisterCallback("RosterListviewItem_OnMouseDown", self.RosterListviewItem_OnMouseDown, self)


    --set the size for the settings scroll frame
    self.settings.scrollChild:SetSize(UI_WIDTH-210, UI_HEIGHT-50);

    --set the size for character scroll view
    self.guild.home.character.scrollChild:SetSize(UI_WIDTH - 210, UI_HEIGHT-50);
    self.guild.home.character.scrollChild.profileInfo:SetSize(UI_WIDTH-210, 290)

    self.guild.home.character.scrollChild.profileInfo.mainSpecIsPvpLabel:SetText(L["CHAR_PROFILE_IS_PVP_SPEC"])
    self.guild.home.character.scrollChild.profileInfo.offSpecIsPvpLabel:SetText(L["CHAR_PROFILE_IS_PVP_SPEC"])

    --set up the character model frame
    local modelFrame = self.guild.home.character.scrollChild.model;
    modelFrame:SetSize(((UI_WIDTH-210) / 3) + 60, UI_HEIGHT-60)
    modelFrame:SetUnit("player")
    modelFrame.portraitZoom = 0.1
    modelFrame:SetPortraitZoom(modelFrame.portraitZoom)
    modelFrame:SetRotation(0.0)
    modelFrame.rotation = 0.61
    modelFrame.rotationCursorStart = 0.0
    modelFrame:SetScript('OnMouseDown', function(self, button)
        if ( not button or button == "LeftButton" ) then
            self.mouseDown = true;
            self.rotationCursorStart = GetCursorPosition();
        end
    end)
    modelFrame:SetScript('OnMouseUp', function(self, button)
        if ( not button or button == "LeftButton" ) then
            self.mouseDown = false;
        end
    end)
    modelFrame:SetScript('OnMouseWheel', function(self, delta)
        self.portraitZoom = self.portraitZoom + (delta/10)
        self:SetPortraitZoom(self.portraitZoom)
    end)
    modelFrame:SetScript('OnUpdate', function(self)
        if (self.mouseDown) then
            if ( self.rotationCursorStart ) then
                local x = GetCursorPosition();
                local diff = (x - self.rotationCursorStart) * 0.05;
                self.rotationCursorStart = GetCursorPosition();
                self.rotation = self.rotation + diff;
                if ( self.rotation < 0 ) then
                    self.rotation = self.rotation + (2 * PI);
                end
                if ( self.rotation > (2 * PI) ) then
                    self.rotation = self.rotation - (2 * PI);
                end
                self:SetRotation(self.rotation, false);
            end
        end
    end)

    local characterProfile = self.guild.home.character.scrollChild;

    characterProfile.showStats:SetScript("OnClick", function()
        characterProfile.model:Hide()
        characterProfile.stats:Show()
    end)
    characterProfile.showStats:SetScript("OnEnter", function()
        GameTooltip:SetOwner(characterProfile.showStats, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(L["CHAR_PROFILE_SHOW_STATS_TOOLTIP"])
        GameTooltip:Show()
    end)
    characterProfile.showStats:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    characterProfile.showModel:SetScript("OnClick", function()
        characterProfile.model:Show()
        characterProfile.stats:Hide()
    end)
    characterProfile.showModel:SetScript("OnEnter", function()
        GameTooltip:SetOwner(characterProfile.showModel, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(L["CHAR_PROFILE_SHOW_MODEL_TOOLTIP"])
        GameTooltip:Show()
    end)
    characterProfile.showModel:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    --these are the templates for the characters equipment slots
    characterProfile.equipSlotHead:SetAllign("right")
    characterProfile.equipSlotNeck:SetAllign("right")
    characterProfile.equipSlotShoulder:SetAllign("right")
    characterProfile.equipSlotBack:SetAllign("right")

    characterProfile.equipSlotChest:SetAllign("right")
    characterProfile.equipSlotTabard:SetAllign("right")
    characterProfile.equipSlotShirt:SetAllign("right")
    characterProfile.equipSlotWrist:SetAllign("right")

    characterProfile.equipSlotHands:SetAllign("left")
    characterProfile.equipSlotWaist:SetAllign("left")
    characterProfile.equipSlotLegs:SetAllign("left")
    characterProfile.equipSlotFeet:SetAllign("left")

    characterProfile.equipSlotFinger0:SetAllign("left")
    characterProfile.equipSlotFinger1:SetAllign("left")
    characterProfile.equipSlotTrinket0:SetAllign("left")
    characterProfile.equipSlotTrinket1:SetAllign("left")
    characterProfile.equipSlotFinger0:SetAllign("left")

    characterProfile.equipSlotMainhand:SetAllign("right")
    characterProfile.equipSlotOffhand:SetAllign("left")
    characterProfile.equipSlotRanged:SetAllign("left")

    characterProfile.profileInfo.equipmentHeader:SetText(L["CHAR_PROFILE_EQUIPMENT_HEADER"])

    --set up the talent trees
    characterProfile.talents:SetSize(UI_WIDTH-210, 620)
    characterProfile.talents.header:SetText(L["CHAR_PROFILE_TALENTS_HEADER"])

    --set the text for the helptips
    characterProfile.equipmentHelp:SetText(L["CHAR_PROFILE_EQUIPMENT_DROPDOWN_HELPTIP"])
    characterProfile.talentsHelp:SetText(L["CHAR_PROFILE_TALENT_DROPDOWN_HELPTIP"])

    --create the talent tree grids
    characterProfile.talents.talentTree = {}
    local colPos = { 19.0, 78.0, 137.0, 196.0 }
    local rowPos = { 19.0, 78.0, 137.0, 196.0, 255.0, 314.0, 373.0, 432.0, 491.0, 550.0, 609.0 } --257
    for spec = 1, 3 do
        characterProfile.talents.talentTree[spec] = {}
        for row = 1, 11 do
            characterProfile.talents.talentTree[spec][row] = {}
            for col = 1, 4 do
                local f = CreateFrame('BUTTON', tostring('GuildbookProfilesTalents'..spec..row..col), characterProfile.talents, BackdropTemplateMixin and "BackdropTemplate")
                f:SetSize(28, 28)
                f:SetPoint('TOPLEFT', 10+((colPos[col] * 0.85) + ((spec - 1) * 237)), ((rowPos[row] * 0.85) * -1) - 60)

                -- background texture inc border
                f.border = f:CreateTexture('$parentBorder', 'BORDER')
                f.border:SetPoint('TOPLEFT', -7, 7)
                f.border:SetPoint('BOTTOMRIGHT', 7, -7)
                f.border:SetAtlas("orderhalltalents-spellborder")
                -- talent icon texture
                f.Icon = f:CreateTexture('$parentIcon', 'BACKGROUND')
                f.Icon:SetPoint('TOPLEFT', -2,2)
                f.Icon:SetPoint('BOTTOMRIGHT', 2,-2)
                -- talent points texture
                f.pointsBackground = f:CreateTexture('$parentPointsBackground', 'ARTWORK')
                f.pointsBackground:SetTexture(136960)
                f.pointsBackground:SetPoint('BOTTOMRIGHT', 16, -16)
                -- talents points font string
                f.Points = f:CreateFontString('$parentPointsText', 'OVERLAY', 'GameFontNormalSmall')
                f.Points:SetPoint('CENTER', f.pointsBackground, 'CENTER', 1, 0)

                f:SetScript('OnEnter', function(self)
                    if self.link then
                        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                        GameTooltip:SetHyperlink(self.link)
                        --GameTooltip:SetTalent(spec, 3)
                        GameTooltip:Show()
                    else
                        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                    end
                end)
                f:SetScript('OnLeave', function(self)
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                f:SetScript('OnClick', function(self, mouseButton)
                    if ( mouseButton == "LeftButton" ) and ( IsModifiedClick("CHATLINK") ) and ( self.link ) then
                        ChatEdit_InsertLink(self.link)
                    end
                end)
                characterProfile.talents.talentTree[spec][row][col] = f
            end
        end
    end


    --guild home
    self.guildName.label:SetText(L["GUILD_HOME_LABEL"] )
    self.guildTradeskills.label:SetText(L["GUILD_TRADESKILLS_LABEL"] )

    self.guild.home.guildHomeMembersHelptip:SetText(L["GUILD_HOME_MEMBERS_HELPTIP"])
    self.guild.home.info.guildHomeCalendarHelptip:SetText(L["GUILD_HOME_CALENDAR_HELPTIP"])
    self.guild.home.info.guildMOTD:SetTextColor(Colours.Guild:GetRGB())

    self.guild.home.info.classInfo.header:SetText(L["GUILD_HOME_CLASS_INFO_HEADER"])

    self.guild.home.info.activityFeed:SetFontObject(GameFontNormal)
    self.guild.home.info.activityFeed:SetMaxLines(100)
    self.guild.home.info.activityFeed:SetFading(false)
    self.guild.home.info.activityFeed:SetJustifyH("LEFT")
    self.guild.home.info.activityFeed:SetTextColor(Colours.Guild:GetRGB())

    self.guild.home.info.activityFeed:SetScript("OnMouseWheel", function(_, delta)
        self.guild.home.info.activityFeed:ScrollByAmount(delta)
    end)

    self.menu:SetFrameLevel(self:GetFrameLevel()+10)

    self.openMenu:SetScript("OnClick", function()
        if self.welcomeMessage:IsVisible() then
            self.welcomeMessage:Hide()

        end
        self.menu:SetShown(not self.menu:IsVisible())
    end)

    self.guildName:SetScript("OnClick", function()
        self:OpenTo("guild")
    end)

    self.guildTradeskills:SetScript("OnClick", function()
        self:OpenTo("tradeskills")
    end)

    self.menu.openSettings.label:SetText(L["SETTINGS_HEADER"])
    self.menu.openSettings:SetScript("OnClick", function()
        self:OpenTo("settings", true)
    end)

    self.menu.openProfile.label:SetText(L["PROFILE_HEADER"])
    self.menu.openProfile:SetScript("OnClick", function()
        self:OpenTo("profile", true)
    end)

    self.menu.openHelp.label:SetText(L["HELP_HEADER"])
    self.menu.openHelp:SetScript("OnClick", function()
        self:OpenTo("help", true)
    end)
    self.help.scrollChild:SetSize(UI_WIDTH-210, UI_HEIGHT)
    self:LoadHelp()

    self.helpIcon:SetScript("OnMouseDown", function()
        showHelptips = not showHelptips;
        for k, tip in ipairs(self.guild.tradeskills.helptips) do
            tip:SetShown(showHelptips)
        end
        for k, tip in ipairs(characterProfile.helptips) do
            tip:SetShown(showHelptips)
        end
        for k, tip in ipairs(self.profile.helptips) do
            tip:SetShown(showHelptips)
        end
        for k, tip in ipairs(self.guild.home.helptips) do
            tip:SetShown(showHelptips)
        end
        for k, tip in ipairs(self.guild.home.info.helptips) do
            tip:SetShown(showHelptips)
        end
    end)

    self.guild.home.showOfflineMembers:SetScript("OnClick", function()
        self:UpdateMembersList()
    end)

    --set up the tradeskills view
    self.guild.tradeskills.tradeskillHelp.Arrow:ClearAllPoints()
    self.guild.tradeskills.tradeskillHelp.Arrow:SetPoint("BOTTOMRIGHT", -20, -60)
    self.guild.tradeskills.tradeskillHelp:SetText(L["TRADESKILL_SEARCH_HELPTIP"])
    self.guild.tradeskills.recipeInfo.header:SetText(L["TRADESKILL_RECIPE_INFO_HEADER"])
    self.guild.tradeskills.tradeskillRecipeInfoHelp:SetText(L["TRADESKILL_RECIPE_INFO_HELPTIP"])
    self.guild.tradeskills.recipeCrafters.header:SetText(L["TRADESKILL_CRAFTERS_HEADER"])
    self.guild.tradeskills.tradeskillCraftersHelp:SetText(L["TRADESKILL_CRAFTERS_HELPTIP"])
    self.guild.tradeskills.workOrderHelp.Arrow:ClearAllPoints()
    self.guild.tradeskills.workOrderHelp.Arrow:SetPoint("BOTTOM", -60, -60)
    self.guild.tradeskills.workOrderHelp:SetText(L["TRADESKILL_WORK_ORDER_HELPTIP"])
    self.guild.tradeskills.workOrders.header:SetText(L["TRADESKILL_WORK_ORDER_HEADER"])
    self.guild.tradeskills.workOrderReagents.header:SetText(L["TRADESKILL_WORK_ORDER_RECIPE_INFO_HEADER"])
    self.guild.tradeskills.workOrdersDeleteAll:SetScript("OnClick", function()
        wipe(GUILDBOOK_GLOBAL.WorkOrders)
        self.guild.tradeskills.workOrders.DataProvider:Flush()
        self.guild.tradeskills.workOrderReagents.DataProvider:Flush()
        --self.guild.tradeskills.workOrders.DataProvider:InsertTable({})
    end)

    ---sort the tradeskill items table
    ---@param t table the table to sort
    local function sortTradeskillResults(t)
        table.sort(t, function(a, b)
            if a.expansion == b.expansion then
                if a.tradeskill == b.tradeskill then
                    if a.quality == b.quality then
                        return a.name < b.name
                    else
                        return a.quality > b.quality
                    end
                else
                    return a.tradeskill < b.tradeskill
                end

            else
                return a.expansion > b.expansion
            end
        end)
    end
    
    local function filterByClass(classID, subClassID)

        local t = {};

        if not subClassID then
            for k, item in ipairs(addon.tradeskillItems) do
                if item.class == classID then
                    table.insert(t, item)
                end
            end

        else
            for k, item in ipairs(addon.tradeskillItems) do
                if item.class == classID and item.subClass == subClassID then
                    table.insert(t, item)
                end
            end

        end

        self.guild.tradeskills.listview.DataProvider:Flush()
        sortTradeskillResults(t)
        self.guild.tradeskills.listview.DataProvider:InsertTable(t)

    end

    local function filterBySlot(slot)
        local t = {}
        for k, item in ipairs(addon.tradeskillItems) do

            if slot == "WEAPONS" then
                slot = "weapon"

            elseif slot == "SHIELDS" then
                slot = "shield"

            elseif slot == "HANDS" then
                slot = "hand"

            else
                if item.equipLocation and item.equipLocation:lower():find(slot:lower()) then
                    table.insert(t, item)
                end
            end

        end
        self.guild.tradeskills.listview.DataProvider:Flush()
        sortTradeskillResults(t)
        self.guild.tradeskills.listview.DataProvider:InsertTable(t)
    end

    local function filterGlyphsbyClass(class)
        local t = {}
        for k, item in ipairs(addon.tradeskillItems) do
            if item.tradeskill == 773 then
                if item.glyphClass == class then
                    table.insert(t, item)
                end
            end
        end
        self.guild.tradeskills.listview.DataProvider:Flush()
        sortTradeskillResults(t)
        self.guild.tradeskills.listview.DataProvider:InsertTable(t)    
    end

    local flyoutMenu = {}
    for i = 1, 3 do
        local subClassName = GetItemSubClassInfo(0, i)
        table.insert(flyoutMenu, {
            text = subClassName,
            func = function()
                filterByClass(0, i)
            end,
        })
    end

    table.insert(flyoutMenu, {
        text = L["GEMS"],
        func = function()
            filterByClass(3)
        end,
    })

    local slots = {
        "HEAD",
        "SHOULDER",
        "CHEST",
        "ROBE",
        "BACK",
        "WRIST",
        "HANDS",
        "WAIST",
        "LEGS",
        "FEET",
        "FINGER",
        "TRINKET",
        "NECK",
        "WEAPONS",
        "RANGED",
        "SHIELDS",
        "HOLDABLE",
    }
    for k, slot in ipairs(slots) do
        table.insert(flyoutMenu, {
            text = L[slot],
            func = function()
                filterBySlot(slot)
            end,
        })
    end

    local glyphFlyoutmenu = {}
    for i = 1, GetNumClasses() do
        local className, classFile, classID = GetClassInfo(i)

        if className then

            table.insert(glyphFlyoutmenu, {
                text = className,
                func = function()
                    filterGlyphsbyClass(classFile)
                end,
            })
        end
    end


    self.guild.tradeskills.searchMenu.menu = flyoutMenu;
    self.guild.tradeskills.searchMenu.flyout:SetFlyoutBackgroundColour(Colours.StoneGold)
    self.guild.tradeskills.searchMenu:SetScript("OnClick", function()

        local flyout = self.guild.tradeskills.searchMenu.flyout;
        flyout:ClearAllPoints()
        flyout:SetPoint("TOPRIGHT", -5, -26)
        flyout.borderSize = 2;

        flyout:SetShown(not flyout:IsVisible())

    end)


    local function filterByTradeskill(tradeskillID)

        if tradeskillID == 773 then
            self.guild.tradeskills.searchMenu.menu = glyphFlyoutmenu;
        else
            self.guild.tradeskills.searchMenu.menu = flyoutMenu;
        end


        local t = {};

        if tradeskillID == "none" then
            self.guild.tradeskills.listview.DataProvider:Flush()

            sortTradeskillResults(addon.tradeskillItems)

            self.guild.tradeskills.listview.DataProvider:InsertTable(addon.tradeskillItems)

        else

            for k, item in ipairs(addon.tradeskillItems) do
                if item.tradeskill == tradeskillID then
                    table.insert(t, item)
                end
            end

            self.guild.tradeskills.listview.DataProvider:Flush()

            sortTradeskillResults(t)

            self.guild.tradeskills.listview.DataProvider:InsertTable(t)
        end

    end

    for k, prof in ipairs(tradeskills) do
        prof = prof:sub(1,1):upper()..prof:sub(2)
        local atlas = string.format("Mobile-%s", prof)
        if prof == "Engineering" then
            atlas = string.format("Mobile-%s", "Enginnering")
        end
        local tradeskillID = Tradeskills:GetTradeskillIDFromEnglishName(prof)

        self.guild.tradeskills.tradeskillsList.DataProvider:Insert({
            tradeskillID = tradeskillID,
            atlas = atlas,
            onMouseDown = filterByTradeskill,
        })
    end

    -- self.guild.tradeskills.clear.icon:SetAtlas("transmog-icon-remove")
    -- self.guild.tradeskills.clear.tooltipText = "Clear"
    -- self.guild.tradeskills.clear:SetScript("OnMouseDown", function()
    --     filterByTradeskill("none")
    --     self.guild.tradeskills.search:SetText("")
    -- end)

    self.guild.tradeskills.search.label:SetText(L["TRADESKILL_SEARCH_HEADER"])

    self.guild.tradeskills.search:SetScript("OnTextChanged", function(eb)

        if eb:GetText() == "" then
            eb.label:Show()
        else
            eb.label:Hide()
        end

        if eb:GetText():sub(1,5) == "slot:" then
            
            local t = {};

            if eb:GetText():len() > 5 then
                for k, item in ipairs(addon.tradeskillItems) do
                    if item.equipLocation:lower():find(eb:GetText():lower():sub(6)) then
                        table.insert(t, item)
                    end
                end

            elseif eb:GetText():len() == 5 then
                for k, item in ipairs(addon.tradeskillItems) do
                    if item.equipLocation == "" then
                        table.insert(t, item)
                    end
                end
            end

            self.guild.tradeskills.listview.DataProvider:Flush()
            sortTradeskillResults(t)
            self.guild.tradeskills.listview.DataProvider:InsertTable(t)

        elseif eb:GetText():sub(1,4) == "gem:" then

            local t = {};

            if eb:GetText():len() == 4 then
                for k, item in ipairs(addon.tradeskillItems) do
                    if item.class == 3 then
                        table.insert(t, item)
                    end
                end
            end

            self.guild.tradeskills.listview.DataProvider:Flush()
            sortTradeskillResults(t)
            self.guild.tradeskills.listview.DataProvider:InsertTable(t)


        elseif eb:GetText():len() > 2 then

            local t = {};

            for k, item in ipairs(addon.tradeskillItems) do

                local localeData = Tradeskills:GetLocaleData(item)

                if localeData.name:lower():find(eb:GetText():lower()) then
                    table.insert(t, item)
                end
            end

            self.guild.tradeskills.listview.DataProvider:Flush()
            sortTradeskillResults(t)
            self.guild.tradeskills.listview.DataProvider:InsertTable(t)

        else
            self.guild.tradeskills.listview.DataProvider:Flush()
            sortTradeskillResults(addon.tradeskillItems)
            self.guild.tradeskills.listview.DataProvider:InsertTable(addon.tradeskillItems)
        end
    end)


    self.guild.tradeskills.listview.DataProvider:InsertTable(addon.tradeskillItems)



    --settings locales
    self.settings.scrollChild.header:SetText(L["SETTINGS_HEADER"])
    self.settings.scrollChild.exportImportLabel:SetText(L["SETTINGS_EXPORT_IMPORT_LABEL"])
    self.settings.scrollChild.showMinimapButton.label:SetText(L["SETTINGS_SHOW_MINIMAP_BUTTON_LABEL"])
    self.settings.scrollChild.showMinimapButton.tooltip = L["SETTINGS_SHOW_MINIMAP_BUTTON_TOOLTIP"]
    self.settings.scrollChild.blockCommsDuringCombat.label:SetText(L["SETTINGS_BLOCK_COMMS_COMBAT_LABEL"])
    self.settings.scrollChild.blockCommsDuringCombat.tooltip = L["SETTINGS_BLOCK_COMMS_COMBAT_TOOLTIP"]
    self.settings.scrollChild.blockCommsDuringInstance.label:SetText(L["SETTINGS_BLOCK_COMMS_INSTANCE_LABEL"])
    self.settings.scrollChild.blockCommsDuringInstance.tooltip = L["SETTINGS_BLOCK_COMMS_INSTANCE_TOOLTIP"]
    self.settings.scrollChild.showTooltipMainCharacter.label:SetText(L["SETTINGS_SHOW_TOOLTIP_MAIN_CHAR"])
    self.settings.scrollChild.showTooltipMainSpec.label:SetText(L["SETTINGS_SHOW_TOOLTIP_MAIN_SPEC"])
    self.settings.scrollChild.showTooltipCharacterProfile.label:SetText(L["SETTINGS_SHOW_TOOLTIP_CHAR_PROFILE"])
    self.settings.scrollChild.showTooltipTradeskills.label:SetText(L["SETTINGS_SHOW_TOOLTIP_TRADESKILLS"])
    self.settings.scrollChild.resetCharacter:SetText(L["SETTINGS_RESET_CHARACTER_LABEL"])
    self.settings.scrollChild.resetGuild:SetText(L["SETTINGS_RESET_GUILD_LABEL"])

    self.settings.scrollChild.modifyDefaultGuildRoster.label:SetText(L["SETTINGS_MOD_BLIZZ_ROSTER_LABEL"])
    self.settings.scrollChild.modifyDefaultGuildRoster.tooltip = L["SETTINGS_MOD_BLIZZ_ROSTER_TOOLTIP"]

    self.settings.scrollChild.generateExportData:SetText(L["SETTINGS_EXPORT_GUILD_LABEL"])
    self.settings.scrollChild.importData:SetText(L["SETTINGS_IMPORT_GUILD_LABEL"])

    self.settings.scrollChild.importExportEditbox.EditBox:SetMaxLetters(1000000000)
    self.settings.scrollChild.importExportEditbox.EditBox:HookScript("OnTextChanged", function()
        self.settings.scrollChild.importExportEditbox.CharCount:ClearAllPoints()
        self.settings.scrollChild.importExportEditbox.CharCount:SetPoint("BOTTOMRIGHT", 0, -28)
    end)


    --settings functions
    self.settings.scrollChild.showMinimapButton:SetScript("OnClick", function()
        Database:SetConfigSetting("showMinimapButton", self.settings.scrollChild.showMinimapButton:GetChecked())
        if self.settings.scrollChild.showMinimapButton:GetChecked() == false then
            self.MinimapIcon:Hide("Guildbook")
        else
            self.MinimapIcon:Show("Guildbook")
        end
    end)
    self.settings.scrollChild.blockCommsDuringCombat:SetScript("OnClick", function()
        Database:SetConfigSetting("blockCommsDuringCombat", self.settings.scrollChild.blockCommsDuringCombat:GetChecked())
    end)
    self.settings.scrollChild.blockCommsDuringInstance:SetScript("OnClick", function()
        Database:SetConfigSetting("blockCommsDuringInstance", self.settings.scrollChild.blockCommsDuringInstance:GetChecked())
    end)
    self.settings.scrollChild.showTooltipMainCharacter:SetScript("OnClick", function()
        Database:SetConfigSetting("showTooltipMainCharacter", self.settings.scrollChild.showTooltipMainCharacter:GetChecked())
    end)
    self.settings.scrollChild.showTooltipMainSpec:SetScript("OnClick", function()
        Database:SetConfigSetting("showTooltipMainSpec", self.settings.scrollChild.showTooltipMainSpec:GetChecked())
    end)
    self.settings.scrollChild.showTooltipCharacterProfile:SetScript("OnClick", function()
        Database:SetConfigSetting("showTooltipCharacterProfile", self.settings.scrollChild.showTooltipCharacterProfile:GetChecked())
    end)
    self.settings.scrollChild.showTooltipTradeskills:SetScript("OnClick", function()
        Database:SetConfigSetting("showTooltipTradeskills", self.settings.scrollChild.showTooltipTradeskills:GetChecked())
    end)
    self.settings.scrollChild.modifyDefaultGuildRoster:SetScript("OnClick", function()

        local checked = self.settings.scrollChild.modifyDefaultGuildRoster:GetChecked()
        Database:SetConfigSetting("modifyDefaultGuildRoster", checked)

        if checked then
            addon:ModBlizzUI()
        else
            ReloadUI()
        end
    end)

    self.settings.scrollChild.resetCharacter:SetScript("OnClick", function()
        for k, guild in ipairs(self.guilds) do
            local player = guild:GetPlayerCharacter()
            if type(player) == "table" then
                local guid = player:GetGuid()
                player:ResetData()
                guild:ScanGuildRoster() --this will also call the database to update saved vars
            end
        end
    end)
    self.settings.scrollChild.resetGuild:SetScript("OnClick", function()

        if type(self.selectedGuild) == "table" then

            StaticPopup_Show("GuildbookResetGuildData", nil, nil, {
                callback = function()
                    self.selectedGuild:WipeAllCharacterData()
                    self.selectedGuild:ScanGuildRoster()
                    self:SetStatusText(string.format("reset guild data for %s", self.selectedGuild:GetName()))
        
                    addon:TriggerEvent("Character_OnDataChanged")
                end,
            })
        end
    end)
    self.settings.scrollChild.debug:SetScript("OnClick", function()
        addon.DebuggerWindow:SetShown(not addon.DebuggerWindow:IsVisible())
        --self.settings.scrollChild.scanForLocaleData:SetShown(not self.settings.scrollChild.scanForLocaleData:IsVisible())
    end)

    -- self.settings.scrollChild.scanForLocaleData:SetScript("OnClick", function()
    --     addon:GetLocaleTradeskillInfo()
    -- end)

    self.settings.scrollChild.generateExportData:SetScript("OnClick", function()
        if self.selectedGuild then
            local dataString = Database:GenerateGuildExportString(self.selectedGuild:GetName())
            self.settings.scrollChild.importExportEditbox.EditBox:SetText(dataString)
        end
    end)

    self.settings.scrollChild.importData:SetScript("OnClick", function()
        if self.settings.scrollChild.importExportEditbox.EditBox:GetText() ~= "" then
            local dataString = self.settings.scrollChild.importExportEditbox.EditBox:GetText()
            Comms.pause = true;
            Database:ImportGuildData(dataString)
        end
    end)



    --profile locales
    self.profile.header:SetText(L["PROFILE_HEADER"])
    self.profile.realProfileHelptip:SetText(L["PROFILE_REAL_PROFILE_HELPTIP"])
    self.profile.realNameInput.label:SetText(L["PROFILE_REAL_NAME_LABEL"])
    self.profile.realBioInput.label:SetText(L["PROFILE_REAL_BIO_LABEL"])
    self.profile.realBioInput.EditBox:SetMaxLetters(200)
    self.profile.specializationHelptip:SetText(L["PROFILE_SPECIALIZATIONS_HELPTIP"])
    self.profile.altsHelptip:SetText(L["PROFILE_ALTS_HELPTIP"])
    self.profile.altManager.label:SetText(L["PROFILE_ALT_MANAGER_LABEL"])
    self.profile.altManager.labelRight:SetText(L["PROFILE_ALT_MANAGER_LABEL_RIGHT"])

    self.profile.primarySpecIsPvp.label:SetText(L["PVP"])
    self.profile.primarySpecIsPvp:SetScript("OnClick", function()
        for _, guild in ipairs(self.guilds) do
            local player = guild:GetPlayerCharacter()
            if type(player) == "table" then
                player:SetSpecIsPvp("primary", self.profile.primarySpecIsPvp:GetChecked())
            end
        end
    end)

    self.profile.secondarySpecIsPvp.label:SetText(L["PVP"])
    self.profile.secondarySpecIsPvp:SetScript("OnClick", function()
        for _, guild in ipairs(self.guilds) do
            local player = guild:GetPlayerCharacter()
            if type(player) == "table" then
                player:SetSpecIsPvp("secondary", self.profile.secondarySpecIsPvp:GetChecked())
            end
        end
    end)

    self.profile:SetScript("OnHide", function()
        for _, guild in ipairs(self.guilds) do
            local player = guild:GetPlayerCharacter()
            if type(player) == "table" then

                player:SetProfileName(self.profile.realNameInput:GetText())
                player:SetProfileBio(self.profile.realBioInput.EditBox:GetText())

                --this is a special method 
                local profile = player:GetProfile();
                local msg = {
                    type = "CHARACTER_PROFILE",
                    payload = profile,
                }
                Comms:QueueMessage("CHARACTER_PROFILE", msg, "GUILD", nil, "NORMAL")
                return;
            end
        end
    end)


end



function GuildbookMixin:LoadHelp()

    self.help.header:SetText(L["HELP_HEADER"])
    self.help.about:SetText(L["HELP_ABOUT"])
    self.help.discordLink:SetText("https://discord.gg/c7Y5Kp3cHG")

    local numFaq = 7

    for i = 0, numFaq do
        local fs = self.help.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")

        fs:SetPoint("TOPLEFT", 0, (i * -60) -2)
        fs:SetPoint("TOPRIGHT", -24, (i * -60) -2)
        
        fs:SetHeight(60)
        fs:SetJustifyH("LEFT")
        
        fs:SetText(string.format("%s\n|cffffffff%s|r", L["HELP_FAQ_Q"..i], L["HELP_FAQ_A"..i]))

    end
end



function GuildbookMixin:OnCommsMessage(sender, data)

    -- print(sender)
    -- DevTools_Dump({data})

    local addonVersion = data.version;
    local senderGUID = data.senderGUID;
    local commType = data.type;

    local character;
    local guild;
    for k, _guild in ipairs(self.guilds) do
        if _guild:GetCharacter(senderGUID) then
            character = _guild:GetCharacter(senderGUID)
            guild = _guild;
            addon.DEBUG("func", "OnCommsMessage", string.format("found character"))
        end
    end
    if type(character) ~= "table" then
        return;
    end

    --lets just save hassle and only accept data from same
    if type(addonVersion) == "number" and (addonVersion < 5) then
        self:SetStatusText(string.format("%s needs to update their addon, data ignored...", character:GetName()))
        return;
    end

    if not addonVersion then
        return
    end
    if type(addonVersion) ~= "number" then
        return
    end

    self:SetStatusText(string.format("%s from %s", commType, character:GetName()))

    if commType == "TRADESKILL_WORK_ORDER_ADD" then
        self:TradeskillListviewItem_OnAddToWorkOrder(data.payload, character, guild:GetName())
    end

    if commType == "CHARACTER_STATS" then
        character:SetPaperdollStats(data.payload.name, data.payload.stats)
    end

    if commType == "TRADESKILL_RECIPES" then
        self:HandleTradeskillUpdate(senderGUID, data.payload.tradeskill, data.payload.level, data.payload.recipes)
    end

    if commType == "SECONDARY_SKILLS" then
        self:HandleSecondarySkillsUpdate(senderGUID, data.payload)
    end

    if commType == "CHARACTER_EQUIPMENT" then
        character:SetInventory(data.payload)
    end

    if commType == "CHARACTER_SPEC" then
        character:SetTalents(data.payload.spec, data.payload.talents)
        character:SetGlyphs(data.payload.spec, data.payload.glyphs)
    end

    if commType == "CHARACTER_PROFILE" then
        local profile = data.payload;

        character:SetSpec("primary", profile.mainSpec)
        character:SetSpec("secondary", profile.offSpec)

        character:SetSpecIsPvp("primary", profile.mainSpecIsPvP)
        character:SetSpecIsPvp("secondary", profile.offSpecIsPvP)

        character:SetProfileName(profile.name)
        character:SetProfileBio(profile.bio)

        character:SetMainCharacter(profile.mainCharacter)

        --DevTools_Dump({profile})
        character:SetAlts(profile.alts)
    end

    if self.guild.home.character.selectedCharacter and (self.guild.home.character.selectedCharacter:GetGuid() == character:GetGuid()) then
        self:InitCharacterEquipmentDropdown(character)
        self:InitCharacterTalentsDropdown(character)
        self:LoadGlyphs(character)
    end

    C_Timer.After(1.0, function()
        guild:UpdateSavedVariablesForCharacter(senderGUID)
    end)
end


function GuildbookMixin:UpdateMembersList()
    
    self.guild.home.members.DataProvider:Flush()

    if type(self.selectedGuild) == "table" then

        for k, character in self.selectedGuild:GetCharacters("name") do

            local onlineInfo = character:GetOnlineStatus()

            if self.guild.home.showOfflineMembers:GetChecked() == true then
                self.guild.home.members.DataProvider:Insert(character) 
            else
                if onlineInfo.isOnline == true then
                    self.guild.home.members.DataProvider:Insert(character)
                end
            end
        end

    end

end


--when the player opens the addon and no guild is currently selected, see if they are in a guild
function GuildbookMixin:OnShow()

    if not self.selectedGuild then

        if IsInGuild() and GetGuildInfo("player") then
            local guildName, _, _, _ = GetGuildInfo('player');

            for k, guild in ipairs(self.guilds) do
                if guild:GetName() == guildName then
                    self.selectedGuild = guild;
                end
            end
        end
    end

    self:UpdateMembersList()
end

function GuildbookMixin:OnHide()

end

function GuildbookMixin:OnUpdate()

end


--once the database object has set up and verified the saved variables add some data to VDT and create the guild objects, minimap button
function GuildbookMixin:OnDatabaseInitialised()

    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache then
        
        local i = 0;
        for name, data in pairs(GUILDBOOK_GLOBAL.GuildRosterCache) do
            
            i = i + 1;

            local guild = Guild:NewGuild(name)
            guild:LoadCharactersFromSavedVars()

            table.insert(self.guilds, guild)

            self.menu.guilds.DataProvider:Insert({
                name = name,
                guild = guild,
            })
        end
    end

    local ldb = LibStub("LibDataBroker-1.1")
    self.MinimapButton = ldb:NewDataObject('Guildbook', {
        type = "launcher",
        icon = 134068,
        OnClick = function(self, button)
            if button == "RightButton" then
                if InterfaceOptionsFrame:IsVisible() then
                    InterfaceOptionsFrame:Hide()
                else
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                    InterfaceOptionsFrame_OpenToCategory(addonName)
                end
            elseif button == 'MiddleButton' then
                ToggleFriendsFrame(3)
            elseif button == "LeftButton" then
                if GuildbookInterface then
                    GuildbookInterface:SetShown(not GuildbookInterface:IsVisible())
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end

        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not GUILDBOOK_GLOBAL['MinimapButton'] then GUILDBOOK_GLOBAL['MinimapButton'] = {} end
    self.MinimapIcon:Register('Guildbook', self.MinimapButton, GUILDBOOK_GLOBAL['MinimapButton'])

    --as this requires libs to load, set this on PEW
    local showMinimapButton = Database:GetConfigSetting("showMinimapButton");
    self.settings.scrollChild.showMinimapButton:SetChecked(showMinimapButton)
    if showMinimapButton == true then
        self.MinimapIcon:Show("Guildbook")
    else
        self.MinimapIcon:Hide("Guildbook")
    end


    --update the settings panel
    self.settings.scrollChild.blockCommsDuringCombat:SetChecked(Database:GetConfigSetting("blockCommsDuringCombat"))
    self.settings.scrollChild.blockCommsDuringInstance:SetChecked(Database:GetConfigSetting("blockCommsDuringInstance"))
    self.settings.scrollChild.showTooltipMainCharacter:SetChecked(Database:GetConfigSetting("showTooltipMainCharacter"))

    self.settings.scrollChild.showTooltipMainSpec:SetChecked(Database:GetConfigSetting("showTooltipMainSpec"))
    self.settings.scrollChild.showTooltipCharacterProfile:SetChecked(Database:GetConfigSetting("showTooltipCharacterProfile"))
    self.settings.scrollChild.showTooltipTradeskills:SetChecked(Database:GetConfigSetting("showTooltipTradeskills"))

    self.settings.scrollChild.modifyDefaultGuildRoster:SetChecked(Database:GetConfigSetting("modifyDefaultGuildRoster"))

    local isGuildUiModded = false;
    FriendsFrameTab3:HookScript("OnShow", function()
        local modBlizzGuildUI = Database:GetConfigSetting("modifyDefaultGuildRoster")
        if modBlizzGuildUI == true and isGuildUiModded == false then
            addon:ModBlizzUI()
            isGuildUiModded = true;
        end
    end)

    C_Timer.After(0.1, function()
        self.guild.tradeskills.workOrders.DataProvider:Flush()
        self.guild.tradeskills.workOrders.DataProvider:InsertTable(GUILDBOOK_GLOBAL.WorkOrders)
    end)


end

function GuildbookMixin:OnAddonLoaded()


end


--use a ticker to check if the player is in a guild and create a new guild object if required
function GuildbookMixin:OnPlayerEnteringWorld()
    
    self.version = tonumber(GetAddOnMetadata('Guildbook', "Version"))

    local guildChecker;
    guildChecker = C_Timer.NewTicker(10, function()
    
        if IsInGuild() and GetGuildInfo("player") then
            local guildName, _, _, _ = GetGuildInfo('player')
    
            local currentGuildLoaded = false;
            for k, guild in ipairs(self.guilds) do
                if guild and (guild:GetName() == guildName) then
                    currentGuildLoaded = true;
                    --addon:TriggerEvent("OnGuildChanged", guild)
                    guildChecker:Cancel()
                end
            end
    
            --this should be a new guild so setup and load
            if currentGuildLoaded == false then
                local guild = Guild:NewGuild(guildName)
                guild:ScanGuildRoster() --this will add new players and also update saved vars
                --guild:LoadCharactersFromSavedVars()
    
                -- C_Timer.After(5, function()
                --     ViragDevTool:AddData(guild, "Guildbook_Guild "..guildName)
                -- end)
    
                table.insert(self.guilds, guild)
    
                self.menu.guilds.DataProvider:Insert({
                    name = guildName,
                    guild = guild,
                })
                guildChecker:Cancel()
            end
    
        end

    end, 30)

    --might as well scan bags now
    self:OnPlayerBagsUpdated()

    --set the specs for profile dropdown
    self.profile.primarySpecDropdown.menu = {}
    self.profile.primarySpecDropdown.flyout:SetFlyoutBackgroundColour(Colours.StoneGold)
    self.profile.secondarySpecDropdown.menu = {}
    self.profile.secondarySpecDropdown.flyout:SetFlyoutBackgroundColour(Colours.StoneGold)
    
    local function setSpec(spec, specID)
        for k, guild in ipairs(self.guilds) do
            local player = guild:GetPlayerCharacter()
            if type(player) == "table" then
                player:SetSpec(spec, specID)
            end
        end
    end


    for k, guild in ipairs(self.guilds) do
        local player = guild:GetPlayerCharacter()
        if type(player) == "table" then

            --set the spec dropdowns
            local specs = player:GetSpecializations()
            if type(specs) == "table" then
                for k, spec in ipairs(specs) do
                    table.insert(self.profile.primarySpecDropdown.menu, {
                        text = spec,
                        func = function()
                            setSpec("primary", k)
                        end,
                    })
                    table.insert(self.profile.secondarySpecDropdown.menu, {
                        text = spec,
                        func = function()
                            setSpec("secondary", k)
                        end,
                    })
                end
            end


            local profile = player:GetProfile()
            self.profile.realNameInput:SetText(profile.name or "-")
            self.profile.realBioInput.EditBox:SetText(profile.bio or "-")

            self.profile.primarySpecDropdown.MenuText:SetText(player:GetSpec("primary"))
            self.profile.secondarySpecDropdown.MenuText:SetText(player:GetSpec("secondary"))
        end
    end

    --alts
    local alts = {}
    for guid, info in pairs(Database:GetMyCharacters()) do
    
        for k, guild in ipairs(self.guilds) do

            local alt = guild:GetCharacter(guid)

            if type(alt) == "table" then
                table.insert(alts, {
                    alt = alt,
                    guild = guild,
                })
            end

        end
    end
    table.sort(alts, function(a,b)
        if a.guild == b.guild then
            return a.alt.data.name < b.alt.data.name;
        else
            return a.guild:GetName() < b.guild:GetName();
        end
    end)
    --self.profile.altManager.DataProvider:Flush()
    self.profile.altManager.DataProvider:InsertTable(alts)

end


function GuildbookMixin:OnGuildChanged(guild)

    --first save any data for the current guild
    if type(self.selectedGuild) == "table" then
        self.selectedGuild:UpdateSavedVariables()
    end

    --update the selected guild to the new guild
    self.selectedGuild = guild;

    --if the guild was imported then the import goes into the saved vars so reload them
    --self.selectedGuild:LoadCharactersFromSavedVars()
    self.selectedGuild:ScanGuildRoster()
    --self.title:SetText(self.selectedGuild:GetName())
    self:UpdateMembersList()

    self:OpenTo("guild")

    self.guildName:Show()
    self.guildName.label:SetText(self.selectedGuild.data.name)
    self.guildTradeskills:Show()

    for k, bar in ipairs(self.guild.home.info.classInfo.bars) do
        bar:SetValue(0)
    end

    --if this is our current guild then lets show some info
    if self.selectedGuild:IsCurrentGuild() then
        
        self.guild.home.info.guildMOTD:SetText(GetGuildRosterMOTD())


        local classCounts, total = self.selectedGuild:GetClassCounts()
        for k, info in ipairs(classCounts) do
            local sb = self.guild.home.info.classInfo["bar"..k];
            sb:SetStatusBarColor(Colours[info.class]:GetRGB())
            sb:SetValue(info.count/total)

            sb.icon:SetAtlas(string.format("GarrMission_ClassIcon-%s", info.class))
            sb.text:SetText(string.format("%s [%s%%]", info.count, math.floor((info.count/total) * 100)))
        end


        self.guild.home.info.guildCalendarEventsListview.DataProvider:Flush()
        local t = {};
        for day = 1, 31 do
            local numDayEvents = C_Calendar.GetNumDayEvents(0, day)
            for e = 1, numDayEvents do
                local event = C_Calendar.GetDayEvent(0, day, e)
                --if event.calendarType == "GUILD_EVENT" then
                    table.insert(t, event)
                --end
                --DevTools_Dump({event})
            end

        end
        table.sort(t, function(a, b)
            return C_DateAndTime.CompareCalendarTime(a.startTime, b.startTime) > 0;
        end)
        self.guild.home.info.guildCalendarEventsListview.DataProvider:InsertTable(t)

    else

        self.guild.home.info.guildMOTD:SetText(L["GUILD_HOME_NO_MOTD"])

    end
end



function GuildbookMixin:OnGuildRosterUpdate()
    C_Timer.After(5.0, function()
        for k, guild in ipairs(self.guilds) do
            if guild:IsCurrentGuild() then
                guild:ScanGuildRoster()
            end
        end
    end)
end


function GuildbookMixin:OnGuildDataImported(guildName)
    for k, guild in ipairs(self.guilds) do
        if guild:GetName() == guildName then
            guild:LoadCharactersFromSavedVars()
            Comms.pause = false;
        end
    end
end


function GuildbookMixin:OnChatMessageGuild(...)
    if self.selectedGuild and self.selectedGuild:IsCurrentGuild() then
        local msg, sender, _, _, _, _, _, _, _, _, _, guid = ...;
        local character = self.selectedGuild.data.members[guid];
        if character then
            self.guild.home.info.activityFeed:AddMessage(string.format("|cffffffff[|r%s|cffffffff]|r %s", Colours[character:GetClass()]:WrapTextInColorCode(Ambiguate(sender, "none")), msg))
        else
            self.guild.home.info.activityFeed:AddMessage(Colours.Guild:WrapTextInColorCode(string.format("|cffffffff[|r%s|cffffffff]|r %s", Ambiguate(sender, "none"), msg)))
        end
    end
end


function GuildbookMixin:AltManagerListviewItem_OnCheckButtonClicked(binding, isChecked)

    self.profile.altManager.DataProvider:Flush()


    if isChecked == false then
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.myCharacters then
            GUILDBOOK_GLOBAL.myCharacters[binding.alt:GetGuid()] = false;
        end

        binding.guild:RemoveMainCharacter(binding.alt:GetGuid())

    else
        local myCharacters = Database:GetMyCharacters()

        local altsPerGuild = {};
        for k, guild in ipairs(self.guilds) do
            
            if not altsPerGuild[guild:GetName()] then
                altsPerGuild[guild:GetName()] = {};
            end
    
            for guid, isMain in pairs(myCharacters) do
                local alt = guild:GetCharacter(guid)
                if alt then
                    table.insert(altsPerGuild[guild:GetName()], guid)
                end
            end
        end
    
        --set this characters alts in guild to false
        for k, guid in ipairs(altsPerGuild[binding.guild:GetName()]) do
            GUILDBOOK_GLOBAL.myCharacters[guid] = false;
        end
    
        --get the selected alts guid
        local altGUID = binding.alt:GetGuid()
    
        --set the roster cache data
        binding.guild:SetMainCharacterForAlts(altGUID)
    
        --set the global db
        GUILDBOOK_GLOBAL.myCharacters[altGUID] = isChecked;

    end


    --update the listview

    --THIS IS DUPLICATED CODE, MAKE AS A PROPER ALT FUNCTION ?
    local alts = {}
    for guid, info in pairs(Database:GetMyCharacters()) do
    
        for k, guild in ipairs(self.guilds) do

            local alt = guild:GetCharacter(guid)

            if type(alt) == "table" then
                table.insert(alts, {
                    alt = alt,
                    guild = guild,
                })
            end

        end
    end
    table.sort(alts, function(a,b)
        if a.guild == b.guild then
            return a.alt.data.name < b.alt.data.name;
        else
            return a.guild:GetName() < b.guild:GetName();
        end
    end)
    self.profile.altManager.DataProvider:InsertTable(alts)


end


function GuildbookMixin:TradeskillListviewItem_OnMouseDown(item)


    
    self.guild.tradeskills.recipeCrafters.selectedItem = nil;

    local localeData = Tradeskills:GetLocaleData(item)

    if item.tradeskill == 333 then
        self.guild.tradeskills.recipeLink:SetText(localeData.name)
    else
        self.guild.tradeskills.recipeLink:SetText(localeData.link)
    end
    self.guild.tradeskills.recipeIcon:SetTexture(item.icon)


    if item.reagents then
        self.guild.tradeskills.recipeInfo.DataProvider:Flush()
        local t = {};
        local numReagents = 0;
        local craftPrice = 0;
        for _, _ in pairs(item.reagents) do
            numReagents = numReagents + 1;
        end
        for reagentID, reagentCount in pairs(item.reagents) do
            local item = Item:CreateFromItemID(reagentID)
            item:ContinueOnItemLoad(function()
                local link = item:GetItemLink()
                local name = item:GetItemName()
                local itemID = item:GetItemID()
                local haveReagent = false;
                if self.playerContainers[itemID] then
                    if self.playerContainers[itemID] >= reagentCount then
                        haveReagent = true;
                    end
                end
                if haveReagent == false then
                    local numRequired = reagentCount - (self.playerContainers[itemID] or 0)
                    if Auctionator and Auctionator.API then
                        local copperPrice = Auctionator.API.v1.GetAuctionPriceByItemLink("Guildbook", link)
                        if type(copperPrice) == "number" then
                            craftPrice = craftPrice + (numRequired * copperPrice)
                        end
                    end
                end
                table.insert(t, {
                    name = name,
                    itemID = itemID,
                    link = link,
                    count = reagentCount,
                    haveReagent = haveReagent,
                })
                if #t == numReagents then
                    table.sort(t, function(a,b)
                        return a.count > b.count;
                    end)
                    self.guild.tradeskills.recipeInfo.DataProvider:InsertTable(t)
                    self.guild.tradeskills.recipeInfo.header:SetText(string.format("%s %s", L["TRADESKILL_RECIPE_INFO_HEADER"], GetCoinTextureString(craftPrice)))
                end
            end)
        end
    end

    self.guild.tradeskills.recipeCrafters.DataProvider:Flush()

    for k, guild in ipairs(self.guilds) do
        local charactersWithRecipe = guild:FindCharactersWithRecipe(item)

        for k, character in ipairs(charactersWithRecipe) do
            self.guild.tradeskills.recipeCrafters.DataProvider:Insert({
                character = character,
                guild = guild:GetName(),
            })
        end
    end

    self.guild.tradeskills.recipeCrafters.selectedItem = item;

end




function GuildbookMixin:TradeskillListviewItem_OnAddToWorkOrder(order, character, guild)

    if not GUILDBOOK_GLOBAL.WorkOrders then
        GUILDBOOK_GLOBAL.WorkOrders = {};
    end

    local item = order.item;

    table.insert(GUILDBOOK_GLOBAL.WorkOrders, {
        name = item.name,
        tradeskill = item.tradeskill,
        link = item.link,
        itemID = item.itemID,
        reagents = item.reagents,
        character = character or false,
        guild = guild,
        quantity = order.quantity or 1,
    })

    --DevTools_Dump({GUILDBOOK_GLOBAL.WorkOrders})

    self.guild.tradeskills.workOrders.DataProvider:Flush()
    self.guild.tradeskills.workOrders.DataProvider:InsertTable({})
    C_Timer.After(0.1, function()
        self.guild.tradeskills.workOrders.DataProvider:Flush()
        self.guild.tradeskills.workOrders.DataProvider:InsertTable(GUILDBOOK_GLOBAL.WorkOrders)
    end)
    -- self.guild.tradeskills.workOrders.DataProvider:Insert({
    --     name = item.name,
    --     tradeskill = item.tradeskill,
    --     link = item.link,
    --     itemID = item.itemID,
    --     character = character or false,
    -- })

    addon.DEBUG("func", "TradeskillListviewItem_OnAddToWorkOrder", string.format("added %s to work order", item.name), item)

    self:UpdateWorkOrderReagents()
end



function GuildbookMixin:TradeskillListviewItem_RemoveFromWorkOrder(item)

    self.guild.tradeskills.workOrders.DataProvider:Flush()
    self.guild.tradeskills.workOrders.DataProvider:InsertTable({})

    if item.character == false then
        addon.DEBUG("func", "", string.format("removing item without character data > %s", item.name))

    else
        addon.DEBUG("func", "", string.format("removing item with character data > %s", item.name))
    end

    --although for duplicated items it'll find each and return the last, as they're duplicates its not much of an issue
    --will probs add another if check when i add character data which will make it a unique item
    local key = nil;
    for k, _item in ipairs(GUILDBOOK_GLOBAL.WorkOrders) do
        if _item.itemID == item.itemID then
            if _item.character == false and item.character == false then
                key = k; 
            else
                if type(_item.character) == "table" and type(item.character) == "table" and (_item.character.data.guid == item.character.data.guid) and (_item.quantity == item.quantity) then
                    key = k;
                end
            end
        end
    end

    if key then
        table.remove(GUILDBOOK_GLOBAL.WorkOrders, key)
        addon.DEBUG("func", "TradeskillListviewItem_OnRemoveFromWorkOrder", string.format("removed %s from work order", item.name), item)
    end

    --self.guild.tradeskills.workOrders.scrollView:FindFrame(item)

    --not the ideal solution
    C_Timer.After(0.01, function()
        self.guild.tradeskills.workOrders.DataProvider:Flush()
        self.guild.tradeskills.workOrders.DataProvider:InsertTable(GUILDBOOK_GLOBAL.WorkOrders)
        self:UpdateWorkOrderReagents()
    end)
end


function GuildbookMixin:UpdateWorkOrderReagents()
    self.guild.tradeskills.workOrderReagents.DataProvider:Flush()

    local reagents = {};
    local numReagents = 0;
    for k, item in ipairs(GUILDBOOK_GLOBAL.WorkOrders) do
        local quantityOrdered = item.quantity or 1;
        if item.reagents then
            for i = 1, quantityOrdered do
                for reagentID, reagentCount in pairs(item.reagents) do
                    if not reagents[reagentID] then
                        reagents[reagentID] = reagentCount;
                        numReagents = numReagents + 1;
                    else
                        reagents[reagentID] = reagents[reagentID] + reagentCount;
                    end
                end
            end
        end
    end

    local t = {};
    for reagentID, reagentCount in pairs(reagents) do
        local item = Item:CreateFromItemID(reagentID)
        item:ContinueOnItemLoad(function()
            local link = item:GetItemLink()
            local name = item:GetItemName()
            local itemID = item:GetItemID()
            local haveReagent = false;
            if self.playerContainers[itemID] then
                if self.playerContainers[itemID] >= reagentCount then
                    haveReagent = true;
                end
            end
            if haveReagent == false then
                local numRequired = reagentCount - (self.playerContainers[itemID] or 0)
                -- if Auctionator and Auctionator.API then
                --     local copperPrice = Auctionator.API.v1.GetAuctionPriceByItemLink("Guildbook", link)
                --     if type(copperPrice) == "number" then
                --         craftPrice = craftPrice + (numRequired * copperPrice)
                --     end
                -- end
            end
            table.insert(t, {
                name = name,
                itemID = itemID,
                link = link,
                count = reagentCount,
                haveReagent = haveReagent,
            })
            if #t == numReagents then
                table.sort(t, function(a,b)
                    return a.count > b.count;
                end)
                self.guild.tradeskills.workOrderReagents.DataProvider:InsertTable(t)
            end
        end)
    end

end



function GuildbookMixin:TradeskillCrafter_SendWorkOrder(character, amount)
    
    if self.guild.tradeskills.recipeCrafters.selectedItem then

        local targetGuid = character:GetGuid()

        local msg = {
            type = "TRADESKILL_WORK_ORDER_ADD",
            payload = {
                item = self.guild.tradeskills.recipeCrafters.selectedItem,
                quantity = amount,
            },
        }
        Comms:SendChatMessage(msg, "WHISPER", targetGuid, "NORMAL") --leave this as direct so the crafter is aware of request
    end
end




function GuildbookMixin:OnPlayerBagsUpdated()
    self.playerContainers = {};
    for bag = 0, 4 do
        for slot = 0, GetContainerNumSlots(bag) do
            local itemID = GetContainerItemID(bag, slot)
            if itemID then
                local icon, count = GetContainerItemInfo(bag, slot)
                if not self.playerContainers[itemID] then
                    self.playerContainers[itemID] = count;
                else
                    self.playerContainers[itemID] = self.playerContainers[itemID] + count;
                end
            end
        end
    end
end



function GuildbookMixin:OnPlayerSecondarySkillsScanned(secondarySkills)
    
    local msg = {
        type = "SECONDARY_SKILLS",
        payload = secondarySkills,
    }
    Comms:QueueMessage(msg.type, msg, "GUILD", nil, "NORMAL")
end



function GuildbookMixin:OnPlayerTradeskillRecipesScanned(tradeskill, level, recipes)

    local msg = {
        type = "TRADESKILL_RECIPES",
        payload = {
            tradeskill = tradeskill,
            level = level,
            recipes = recipes,
        }
    }
    --Comms:SendChatMessage(msg, "GUILD", nil, "NORMAL")
    Comms:QueueMessage(msg.type, msg, "GUILD", nil, "NORMAL")
end


function GuildbookMixin:OnPlayerTradeskillRecipesLinked(characterName, tradeskill, level, recipes)

    for k, guild in ipairs(self.guilds) do

        for k, character in guild:GetCharacters("name") do

            if character:GetName() == characterName then
                local guid = character:GetGuid()
                self:HandleTradeskillUpdate(guid, tradeskill, level, recipes)
            end
        end
    end

end



function GuildbookMixin:HandleSecondarySkillsUpdate(guid, secondarySkills)
    
    for k, guild in ipairs(self.guilds) do
        local character = guild:GetCharacter(guid)
        if type(character) == "table" then

            character:SetCookingLevel(secondarySkills[185])
            character:SetFirstAidLevel(secondarySkills[129])
            character:SetFishingLevel(secondarySkills[356])

        end
    end
end


function GuildbookMixin:HandleTradeskillUpdate(guid, tradeskill, level, recipes)

    --addon.DEBUG("func", "HandleTradeskillUpdate", string.format("prof %s level %s", tradeskill, level))

    for k, guild in ipairs(self.guilds) do
        local character = guild:GetCharacter(guid)
        if type(character) == "table" then

            local prof = Tradeskills:GetLocaleNameFromID(tradeskill)

            if prof then

                self:SetStatusText(string.format("%s sent %s recipes", character:GetName(), prof))

                addon.DEBUG("func", "HandleTradeskillUpdate", string.format("found character %s seting %s", character:GetName(), tradeskill))

                --addon.DEBUG("func", "OnPlayerTradeskillRecipesScanned", "found character table")

                --DevTools_Dump({character})

                -- add in here to cover secondary skills
                if tradeskill == 185 then --cooking
                    character:SetCookingLevel(level)
                    character:SetCookingRecipes(recipes)
                    return;
                end
                if tradeskill == 129 then --FA
                    character:SetFirstAidLevel(level)
                    return;
                end
                if tradeskill == 356 then --fishing
                    character:SetFishingLevel(level)
                    return;
                end

                --check if the character has this tradeksill and update
                if character:GetTradeskill(1) == tradeskill then
                    character:SetTradeskillLevel(1, level)
                    character:SetTradeskillRecipes(1, recipes)

                    addon.DEBUG("func", "OnPlayerTradeskillRecipesScanned", string.format("prof 1 is known > set prof 1 at level %s", level))

                else
                    if character:GetTradeskill(2) == tradeskill then
                        character:SetTradeskillLevel(2, level)
                        character:SetTradeskillRecipes(2, recipes)

                        addon.DEBUG("func", "OnPlayerTradeskillRecipesScanned", string.format("prof 2 is known > set prof 2 at level %s", level))
                    end
                end

                --if the character has no tradeskills set then update
                if type(character:GetTradeskill(1)) ~= "number" then
                    character:SetTradeskill(1, tradeskill)
                    character:SetTradeskillLevel(1, level)
                    character:SetTradeskillRecipes(1, recipes)

                    addon.DEBUG("func", "OnPlayerTradeskillRecipesScanned", string.format("prof 1 is NEW > set prof 1 as %s at level %s", tradeskill, level))

                else
                    if (character:GetTradeskill(1) ~= tradeskill) and type(character:GetTradeskill(2)) ~= "number" then
                        character:SetTradeskill(2, tradeskill)
                        character:SetTradeskillLevel(2, level)
                        character:SetTradeskillRecipes(2, recipes)

                        addon.DEBUG("func", "OnPlayerTradeskillRecipesScanned", string.format("prof 2 is NEW > set prof 2 as %s at level %s", tradeskill, level))
                    end
                end

                guild:UpdateSavedVariablesForCharacter(guid)

            end
    
        end
    end

end



function GuildbookMixin:OnPlayerEquipmentChanged(equipment)

    self:SetStatusText("scanned player equipment sets")

    local msg = {
        type = "CHARACTER_EQUIPMENT",
        payload = equipment,
    }

    --Comms:SendChatMessage(msg, "GUILD", nil, "NORMAL")
    Comms:QueueMessage(msg.type, msg, "GUILD", nil, "NORMAL")
end





function GuildbookMixin:OnPlayerStatsChanged(name, stats)

    self:SetStatusText("scanned player stats")
    
    local msg = {
        type = "CHARACTER_STATS",
        payload = {
            name = name,
            stats = stats,
        }
    }
    
    --Comms:SendChatMessage(msg, "GUILD", nil, "NORMAL")
    Comms:QueueMessage(msg.type, msg, "GUILD", nil, "NORMAL")
end


function GuildbookMixin:OnPlayerTalentSpecChanged(spec, talents, glyphs)

    self:SetStatusText(string.format("scanned player talents and glyphs for %s spec", spec))

    local msg = {
        type = "CHARACTER_SPEC",
        payload = {
            spec = spec,
            talents = talents,
            glyphs = glyphs,
        },
    }
    --Comms:SendChatMessage(msg, "GUILD", nil, "NORMAL")
    Comms:QueueMessage(msg.type, msg, "GUILD", nil, "NORMAL")
end


function GuildbookMixin:LoadTalents(character, spec)

    for tab = 1, 3 do
        for col = 1, 4 do
            for row = 1, 11 do
                self.guild.home.character.scrollChild.talents.talentTree[tab][row][col]:Hide()
                self.guild.home.character.scrollChild.talents.talentTree[tab][row][col].TalentIndex = nil;
            end
        end
    end

    local talents = character:GetTalents(spec)
    if type(talents) == "table" and #talents ~= 0 then
        for k, info in ipairs(talents) do
            --print(info.Name, info.Rank, info.MaxRank, info.Icon, info.Tab, info.Row, info.Col)
            if self.guild.home.character.scrollChild.talents.talentTree[info.Tab] and self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row] then
                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col]:Show()
                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetTexture(info.Icon)
                --self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].talentIndex = info.TalentIndex
                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].rank = info.Rank
                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].maxRank = info.MxRnk
                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].link = info.Link
                --self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText(info.Rank) --string.format("%s / %s", info.Rank, info.MxRnk))
                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:Show()
                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].pointsBackground:Show()

                self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].TalentIndex = info.Index

                if info.Rank > 0 then
                    self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetDesaturated(false)
                    if info.Rank < info.MxRnk then
                        self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText('|cff40BF40'..info.Rank)
                        self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder-green")
                    else
                        self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText('|cffFFFF00'..info.Rank)
                        self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder-yellow")
                    end
                else
                    self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetDesaturated(true)
                    self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder")
                    self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:Hide()
                    self.guild.home.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].pointsBackground:Hide()
                end
            else

            end
        end
    end
end

function GuildbookMixin:LoadGlyphs(character)

    for k, spec in ipairs({ "primary", "secondary"}) do

        -- i should maybe write this into the xml.......
        local mainOff = (k == 1) and "main" or "off"
        local point1 = (k == 1) and "RIGHT" or "LEFT"
        local point2 = (k == 1) and "LEFT" or "RIGHT"

        --using lua to create the glyph icons
        for i = 1, 3 do
            if not self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i.."Icon"] then
                local f = CreateFrame("FRAME", nil, self.guild.home.character.scrollChild.profileInfo)
                f:SetSize(20, 20)
                f:SetPoint(point1, self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i], point2, ((k == 1) and -2 or 2), 0)
                f.icon = f:CreateTexture()
                f.icon:SetAllPoints()
                f:SetScript("OnLeave", function()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i.."Icon"] = f;
            else
                self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i.."Icon"].icon:SetTexture()
            end

            if not self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i.."Icon"] then
                local f = CreateFrame("FRAME", nil, self.guild.home.character.scrollChild.profileInfo)
                f:SetSize(20, 20)
                f:SetPoint(point1, self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i], point2, ((k == 1) and -2 or 2), 0)
                f.icon = f:CreateTexture()
                f.icon:SetAllPoints()
                f:SetScript("OnLeave", function()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i.."Icon"] = f;
            else
                self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i.."Icon"].icon:SetTexture()
            end


            self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i]:SetText("-")
            self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i]:SetText("-")
        end

        --load the glyphs
        local glyphs = character:GetGlyphs(spec) or {};
        local minor, major = 0, 0;
        for k, glyph in ipairs(glyphs) do
            
            if glyph.glyphType == "Major" then
                
                major = major + 1;
                local _major = major;
                local item = Item:CreateFromItemID(glyph.itemID)
                item:ContinueOnItemLoad(function()
                    self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph".._major]:SetText(item:GetItemLink())
                    self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph".._major.."Icon"].icon:SetTexture(item:GetItemIcon())
                    self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph".._major.."Icon"]:SetScript("OnEnter", function(f)
                        GameTooltip:SetOwner(f, "ANCHOR_TOP")
                        GameTooltip:SetHyperlink(item:GetItemLink())
                    end)
                end)

            elseif glyph.glyphType == "Minor" then


                minor = minor + 1;
                local _minor = minor;
                local item = Item:CreateFromItemID(glyph.itemID)
                item:ContinueOnItemLoad(function()
                    self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph".._minor]:SetText(item:GetItemLink())
                    self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph".._minor.."Icon"].icon:SetTexture(item:GetItemIcon())
                    self.guild.home.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph".._minor.."Icon"]:SetScript("OnEnter", function(f)
                        GameTooltip:SetOwner(f, "ANCHOR_TOP")
                        GameTooltip:SetHyperlink(item:GetItemLink())
                    end)
                end)

            end
        end
    end
end

function GuildbookMixin:RosterListviewItem_OnMouseDown(character)

    if type(character) ~= "table" then
        addon.DEBUG("func", "RosterListviewItem_OnMouseDown", "character object not a table", character)
        return
    else
        addon.DEBUG("func", "RosterListviewItem_OnMouseDown", "character object is a table", character)
    end

    self:OpenTo("character")

    self.guild.home.character.selectedCharacter = character;

    local class = character:GetClass()

    self.guild.home.character.scrollChild.model:Undress()

    self.guild.home.character.scrollChild.name:SetText(Colours[class]:WrapTextInColorCode(character:GetName()))
    self.guild.background:SetAtlas(string.format("legionmission-complete-background-%s", class:lower()))

    --profile strings
    self.guild.home.character.scrollChild.profileInfo.level:SetText(L["PROFILE_LEVEL_S"]:format(character:GetLevel()))

    self.guild.home.character.scrollChild.profileInfo.mainSpec:SetText(character:GetSpec("primary"))
    self.guild.home.character.scrollChild.profileInfo.mainSpecIcon:SetAtlas(character:GetClassSpecAtlasName("primary"))
    self.guild.home.character.scrollChild.profileInfo.mainSpecIsPvpTick:Hide()
    self.guild.home.character.scrollChild.profileInfo.mainSpecIsPvpTick:SetShown(character:GetSpecIsPvp("primary"))

    self.guild.home.character.scrollChild.profileInfo.offSpec:SetText(character:GetSpec("secondary"))
    self.guild.home.character.scrollChild.profileInfo.offSpecIcon:SetAtlas(character:GetClassSpecAtlasName("secondary"))
    self.guild.home.character.scrollChild.profileInfo.offSpecIsPvpTick:Hide()
    self.guild.home.character.scrollChild.profileInfo.offSpecIsPvpTick:SetShown(character:GetSpecIsPvp("secondary"))

    self.guild.home.character.scrollChild.profileInfo.realName:SetText(character:GetProfileName() or "-")
    self.guild.home.character.scrollChild.profileInfo.realBio:SetText(character:GetProfileBio() or "-")

    local prof1 = Tradeskills:GetLocaleNameFromID(character:GetTradeskill(1)) or "-"
    local atlas1 = prof1 ~= "-" and CreateAtlasMarkup("Mobile-"..Tradeskills:GetEnglishNameFromID(character:GetTradeskill(1)), 20, 20) or " "
    if character:GetTradeskill(1) == 202 then
        atlas1 = CreateAtlasMarkup("Mobile-Enginnering", 20, 20)
    end
    self.guild.home.character.scrollChild.profileInfo.prof1:SetText(string.format("%s %s %s", atlas1, prof1, character:GetTradeskillLevel(1)))
    
    local prof2 = Tradeskills:GetLocaleNameFromID(character:GetTradeskill(2)) or "-"
    local atlas2 = prof2 ~= "-" and CreateAtlasMarkup("Mobile-"..Tradeskills:GetEnglishNameFromID(character:GetTradeskill(2)), 20, 20) or " "
    if character:GetTradeskill(2) == 202 then
        atlas2 = CreateAtlasMarkup("Mobile-Enginnering", 20, 20)
    end
    self.guild.home.character.scrollChild.profileInfo.prof2:SetText(string.format("%s %s %s", atlas2, prof2, character:GetTradeskillLevel(2)))
    
    self.guild.home.character.scrollChild.profileInfo.cooking:SetText(string.format("%s %s %s", CreateAtlasMarkup("Mobile-Cooking", 20, 20), Tradeskills:GetLocaleNameFromID(185), character:GetCookingLevel() or "-"))
    self.guild.home.character.scrollChild.profileInfo.fishing:SetText(string.format("%s %s %s", CreateAtlasMarkup("Mobile-Fishing", 20, 20), Tradeskills:GetLocaleNameFromID(356), character:GetFishingLevel() or "-"))
    self.guild.home.character.scrollChild.profileInfo.firstAid:SetText(string.format("%s %s %s", CreateAtlasMarkup("Mobile-FirstAid", 20, 20), Tradeskills:GetLocaleNameFromID(129), character:GetFirstAidLevel() or "-"))
    

    --alts
    local alts = character:GetAlts()
    if type(alts) == "table" then

        if not self.guild.home.character.scrollChild.altContainer.portraits then
            self.guild.home.character.scrollChild.altContainer.portraits = {}
        end

        for k, frame in ipairs(self.guild.home.character.scrollChild.altContainer.portraits) do
            frame:Hide()
        end

        for k, alt in ipairs(alts) do

            local character = self.selectedGuild:GetCharacter(alt)
            if type(character) == "table" then

                if not self.guild.home.character.scrollChild.altContainer.portraits[k] then
                    
                    local f = CreateFrame("FRAME", nil, self.guild.home.character.scrollChild.altContainer, "GuildbookProfileSummaryRowAvatarTemplate")
                    f:SetPoint("TOPLEFT", ((k-1) * 100), 0)
                    f:SetScale(0.9)
                    f:SetCharacter(character)

                    self.guild.home.character.scrollChild.altContainer.portraits[k] = f;

                    f:Show()
                else
                    local f = self.guild.home.character.scrollChild.altContainer.portraits[k]
                    f:SetCharacter(character)
                    f:Show()
                end
            end
        end

        self.guild.home.character.scrollChild.altContainer:SetWidth(#alts * 90)
    end

    if #alts == 0 then
        self.guild.home.character.scrollChild.profileInfo:SetSize(UI_WIDTH-210, 300)
    else
        self.guild.home.character.scrollChild.profileInfo:SetSize(UI_WIDTH-210, 400)
    end



    for k, slot in ipairs(self.guild.home.character.scrollChild.equipSlots) do
        slot:ClearItem()
    end
    self:InitCharacterEquipmentDropdown(character)


    --talents
    for tab = 1, 3 do
        for col = 1, 4 do
            for row = 1, 11 do
                self.guild.home.character.scrollChild.talents.talentTree[tab][row][col]:Hide()
                self.guild.home.character.scrollChild.talents.talentTree[tab][row][col].TalentIndex = nil;
            end
        end
    end
    self.guild.home.character.scrollChild.talents.tree1:SetTexture(nil)
    self.guild.home.character.scrollChild.talents.tree1:SetAlpha(0.6)
    self.guild.home.character.scrollChild.talents.tree2:SetTexture(nil)
    self.guild.home.character.scrollChild.talents.tree2:SetAlpha(0.6)
    self.guild.home.character.scrollChild.talents.tree3:SetTexture(nil)
    self.guild.home.character.scrollChild.talents.tree3:SetAlpha(0.6)

    self:InitCharacterTalentsDropdown(character)
    self:LoadGlyphs(character)

    self.guild.home.character.scrollChild.talentsDropdown.MenuText:SetText(L["CHAR_PROFILE_TALENT_DROPDOWN_LABEL"])

    local backgrounds = talentTabsToBackground[class]
    self.guild.home.character.scrollChild.talents.tree1:SetTexture(string.format("interface/talentframe/%s-topleft.blp", backgrounds[1]))
    --self.guild.home.character.scrollChild.talents.tree1:SetTexture(string.format("Interface/TalentFrame/%s%s-TopLeft", "Paladin", "Holy"))
    self.guild.home.character.scrollChild.talents.tree1:SetAlpha(0.6)
    self.guild.home.character.scrollChild.talents.tree2:SetTexture(string.format("interface/talentframe/%s-topleft.blp", backgrounds[2]))
    self.guild.home.character.scrollChild.talents.tree2:SetAlpha(0.6)
    self.guild.home.character.scrollChild.talents.tree3:SetTexture(string.format("interface/talentframe/%s-topleft.blp", backgrounds[3]))
    self.guild.home.character.scrollChild.talents.tree3:SetAlpha(0.6)

end


function GuildbookMixin:InitCharacterTalentsDropdown(character)
    local talentMenu = {};
    table.insert(talentMenu, {
        text = L["CHAR_PROFILE_TALENTS_DROPDOWN_SPEC1"],
        func = function()
            self:LoadTalents(character, "primary")
        end,
    })
    table.insert(talentMenu, {
        text = L["CHAR_PROFILE_TALENTS_DROPDOWN_SPEC2"],
        func = function()
            self:LoadTalents(character, "secondary")
        end,
    })
    self.guild.home.character.scrollChild.talentsDropdown.menu = talentMenu;
    self.guild.home.character.scrollChild.talentsDropdown.flyout:SetFlyoutBackgroundColour(Colours.StoneGold)
end


function GuildbookMixin:InitCharacterEquipmentDropdown(character)
    local equipment = character:GetInventory()
    self.guild.home.character.scrollChild.equipsetDropdown.MenuText:SetText(L["CHAR_PROFILE_EQUIPMENT_DROPDOWN_LABEL"])
    self.guild.home.character.scrollChild.equipsetDropdown.menu = {}
    self.guild.home.character.scrollChild.equipsetDropdown.flyout:SetFlyoutBackgroundColour(Colours.StoneGold)
    for name, info in pairs(equipment) do
        table.insert(self.guild.home.character.scrollChild.equipsetDropdown.menu, {
            text = name,
            func = function()
                for k, slot in ipairs(self.guild.home.character.scrollChild.equipSlots) do
                    local itemID = equipment[name][k]
                    slot:ClearItem()
                    slot:SetItem(itemID)

                    self.guild.home.character.scrollChild.model:TryOn(string.format("item:%d",itemID))


                    self.guild.home.character.scrollChild.stats.DataProvider:Flush()
                    local stats = character:GetPaperdollStats(name)
                    if type(stats) == "table" then
                        local t = {}
                        for k, v in pairs(stats) do
                            table.insert(t, {
                                name = k,
                                value = v,
                            })
                        end
                        self.guild.home.character.scrollChild.stats.DataProvider:InsertTable(t)
                    end
                end
            end,
        })
    end
end