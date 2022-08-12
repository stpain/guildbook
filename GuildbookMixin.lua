

local addonName, addon = ...;

addon.playerContainers = {};

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




















GuildbookMixin = {};
GuildbookMixin.selectedGuild = nil;
GuildbookMixin.guilds = {};
GuildbookMixin.workOrders = {};


---set the view
---@param frame string the key for the new view
---@param showMenu boolean sets if the menu is kept open
function GuildbookMixin:OpenTo(frame, showMenu)

    self.guild:Hide()
    self.guild.guildHome:Hide()
    self.guild.tradeskills:Hide()
    self.guild.character:Hide()
    self.guild.background:SetTexture(nil)
    self.settings:Hide()
    self.profile:Hide()
    self.help:Hide()
    self.menu:Hide()

    if frame == "guild" then
        self.guild:Show()
        self.guild.guildHome:Show()

    elseif frame == "tradeskills" then
        self.guild:Show()
        self.guild.tradeskills:Show()

    elseif frame == "character" then
        self.guild:Show()
        self.guild.character:Show()

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
    self.border:SetColorTexture(Colours.WARLOCK:GetRGB())  
    self.topBarBackground:SetColorTexture(Colours.DarkSlateGrey:GetRGB())
    self.menu.background:SetColorTexture(Colours.DarkSlateGreen:GetRGB())

    --grab size 
    UI_WIDTH, UI_HEIGHT = self:GetSize()


    --scale the helptips up for other languages
    for k, tip in ipairs(self.guild.tradeskills.helptips) do
        local w, h = tip:GetSize()
        tip:SetSize(w*1.2, h*1.2)
    end
    for k, tip in ipairs(self.guild.character.scrollChild.helptips) do
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
    addon:RegisterCallback("OnPlayerTradeskillRecipesScanned", self.OnPlayerTradeskillRecipesScanned, self)
    addon:RegisterCallback("OnPlayerEquipmentChanged", self.OnPlayerEquipmentChanged, self)
    addon:RegisterCallback("OnPlayerStatsChanged", self.OnPlayerStatsChanged, self)
    addon:RegisterCallback("OnPlayerTalentSpecChanged", self.OnPlayerTalentSpecChanged, self)
    addon:RegisterCallback("TradeskillListviewItem_OnMouseDown", self.TradeskillListviewItem_OnMouseDown, self)
    addon:RegisterCallback("TradeskillListviewItem_OnAddToWorkOrder", self.TradeskillListviewItem_OnAddToWorkOrder, self)
    addon:RegisterCallback("TradeskillListviewItem_RemoveFromWorkOrder", self.TradeskillListviewItem_RemoveFromWorkOrder, self)
    addon:RegisterCallback("TradeskillCrafter_SendWorkOrder", self.TradeskillCrafter_SendWorkOrder, self)
    addon:RegisterCallback("RosterListviewItem_OnMouseDown", self.RosterListviewItem_OnMouseDown, self)


    --set the size for the settings scroll frame
    self.settings.scrollChild:SetSize(UI_WIDTH-210, UI_HEIGHT-50);

    --set the size for character scroll view
    self.guild.character.scrollChild:SetSize(UI_WIDTH-210, UI_HEIGHT-50);
    self.guild.character.scrollChild.profileInfo:SetSize(UI_WIDTH-210, 260)

    --set up the character model frame
    local modelFrame = self.guild.character.scrollChild.model;
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

    self.guild.character.scrollChild.showStats:SetScript("OnClick", function()
        self.guild.character.scrollChild.model:Hide()
        self.guild.character.scrollChild.stats:Show()
    end)
    self.guild.character.scrollChild.showStats:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.guild.character.scrollChild.showStats, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(L["PROFILE_SHOW_STATS_TOOLTIP"])
        GameTooltip:Show()
    end)
    self.guild.character.scrollChild.showStats:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    self.guild.character.scrollChild.showModel:SetScript("OnClick", function()
        self.guild.character.scrollChild.model:Show()
        self.guild.character.scrollChild.stats:Hide()
    end)
    self.guild.character.scrollChild.showModel:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.guild.character.scrollChild.showModel, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(L["PROFILE_SHOW_MODEL_TOOLTIP"])
        GameTooltip:Show()
    end)
    self.guild.character.scrollChild.showModel:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    --these are the templates for the characters equipment slots
    self.guild.character.scrollChild.equipSlotHead:SetAllign("right")
    self.guild.character.scrollChild.equipSlotNeck:SetAllign("right")
    self.guild.character.scrollChild.equipSlotShoulder:SetAllign("right")
    self.guild.character.scrollChild.equipSlotBack:SetAllign("right")

    self.guild.character.scrollChild.equipSlotChest:SetAllign("right")
    self.guild.character.scrollChild.equipSlotTabard:SetAllign("right")
    self.guild.character.scrollChild.equipSlotShirt:SetAllign("right")
    self.guild.character.scrollChild.equipSlotWrist:SetAllign("right")

    self.guild.character.scrollChild.equipSlotHands:SetAllign("left")
    self.guild.character.scrollChild.equipSlotWaist:SetAllign("left")
    self.guild.character.scrollChild.equipSlotLegs:SetAllign("left")
    self.guild.character.scrollChild.equipSlotFeet:SetAllign("left")

    self.guild.character.scrollChild.equipSlotFinger0:SetAllign("left")
    self.guild.character.scrollChild.equipSlotFinger1:SetAllign("left")
    self.guild.character.scrollChild.equipSlotTrinket0:SetAllign("left")
    self.guild.character.scrollChild.equipSlotTrinket1:SetAllign("left")
    self.guild.character.scrollChild.equipSlotFinger0:SetAllign("left")

    self.guild.character.scrollChild.equipSlotMainhand:SetAllign("right")
    self.guild.character.scrollChild.equipSlotOffhand:SetAllign("left")
    self.guild.character.scrollChild.equipSlotRanged:SetAllign("left")

    --set up the talent trees
    self.guild.character.scrollChild.talents:SetSize(UI_WIDTH-210, 620)
    self.guild.character.scrollChild.talents.header:SetText("Talents")

    --set the text for the helptips
    self.guild.character.scrollChild.equipmentHelp:SetText(L["PROFILE_EQUIPMENT_DROPDOWN_HELPTIP"])
    self.guild.character.scrollChild.talentsHelp:SetText(L["PROFILE_TALENT_DROPDOWN_HELPTIP"])

    --create the talent tree grids
    self.guild.character.scrollChild.talents.talentTree = {}
    local colPos = { 19.0, 78.0, 137.0, 196.0 }
    local rowPos = { 19.0, 78.0, 137.0, 196.0, 255.0, 314.0, 373.0, 432.0, 491.0, 550.0, 609.0 } --257
    for spec = 1, 3 do
        self.guild.character.scrollChild.talents.talentTree[spec] = {}
        for row = 1, 11 do
            self.guild.character.scrollChild.talents.talentTree[spec][row] = {}
            for col = 1, 4 do
                local f = CreateFrame('BUTTON', tostring('GuildbookProfilesTalents'..spec..row..col), self.guild.character.scrollChild.talents, BackdropTemplateMixin and "BackdropTemplate")
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
                self.guild.character.scrollChild.talents.talentTree[spec][row][col] = f
            end
        end
    end


    --guild home
    self.guildName.label:SetText(L["GUILD_HOME_LABEL"] )
    self.guildTradeskills.label:SetText(L["GUILD_TRADESKILLS_LABEL"] )

    self.guild.guildHome.guildHomeMembersHelptip:SetText(L["GUILD_HOME_MEMBERS_HELPTIP"])
    self.guild.guildHome.guildMOTD:SetTextColor(Colours.Guild:GetRGB())

    self.guild.guildHome.guildClassInfo.header:SetText("Class Info")

    self.guild.guildHome.activityFeed:SetFontObject(GameFontNormal)
    self.guild.guildHome.activityFeed:SetMaxLines(100)
    self.guild.guildHome.activityFeed:SetFading(false)
    self.guild.guildHome.activityFeed:SetJustifyH("LEFT")
    self.guild.guildHome.activityFeed:SetTextColor(Colours.Guild:GetRGB())

    self.guild.guildHome.activityFeed:SetScript("OnMouseWheel", function(_, delta)
        self.guild.guildHome.activityFeed:ScrollByAmount(delta)
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
        for k, tip in ipairs(self.guild.character.scrollChild.helptips) do
            tip:SetShown(showHelptips)
        end
        for k, tip in ipairs(self.profile.helptips) do
            tip:SetShown(showHelptips)
        end
        for k, tip in ipairs(self.guild.guildHome.helptips) do
            tip:SetShown(showHelptips)
        end
    end)

    --set up the tradeskills view
    self.guild.tradeskills.tradeskillHelp.Arrow:ClearAllPoints()
    self.guild.tradeskills.tradeskillHelp.Arrow:SetPoint("BOTTOMRIGHT", -20, -60)
    self.guild.tradeskills.tradeskillHelp:SetText(L["TRADESKILL_SEARCH_HELPTIP"])
    self.guild.tradeskills.tradeskillRecipeInfoHelp:SetText(L["TRADESKILL_RECIPE_INFO_HELPTIP"])
    self.guild.tradeskills.tradeskillCraftersHelp:SetText(L["TRADESKILL_CRAFTERS_HELPTIP"])
    self.guild.tradeskills.workOrderHelp.Arrow:ClearAllPoints()
    self.guild.tradeskills.workOrderHelp.Arrow:SetPoint("BOTTOM", -60, -60)
    self.guild.tradeskills.workOrderHelp:SetText(L["TRADESKILL_WORK_ORDER_HELPTIP"])
    self.guild.tradeskills.workOrdersDeleteAll:SetScript("OnClick", function()
        wipe(self.workOrders)
        self.guild.tradeskills.workOrders.DataProvider:Flush()
        self.guild.tradeskills.workOrders.DataProvider:InsertTable({})
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

    local function filterByTradeskill(tradeskill)
        local t = {};

        if tradeskill == "none" then
            self.guild.tradeskills.listview.DataProvider:Flush()

            sortTradeskillResults(addon.tradeskillItems)

            self.guild.tradeskills.listview.DataProvider:InsertTable(addon.tradeskillItems)

        else

            local tradeskillID = Tradeskills:GetTradeskillIDFromEnglishName(tradeskill)

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
        if prof == "Engineering" then
            self.guild.tradeskills[prof:lower()].icon:SetAtlas(string.format("Mobile-%s", "Enginnering"))
        else
            self.guild.tradeskills[prof:lower()].icon:SetAtlas(string.format("Mobile-%s", prof))
        end
        self.guild.tradeskills[prof:lower()].tooltipText = prof;
        self.guild.tradeskills[prof:lower()]:SetScript("OnMouseDown", function()
            filterByTradeskill(prof)
        end)
    end

    self.guild.tradeskills.clear.icon:SetAtlas("transmog-icon-remove")
    self.guild.tradeskills.clear.tooltipText = "Clear"
    self.guild.tradeskills.clear:SetScript("OnMouseDown", function()
        filterByTradeskill("none")
        self.guild.tradeskills.search:SetText("")
    end)

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
                if item.name:lower():find(eb:GetText():lower()) then
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
    self.settings.scrollChild.resetCharacter:SetText(L["SETTINGS_RESET_CHARACTER_LABEL"])
    self.settings.scrollChild.resetGuild:SetText(L["SETTINGS_RESET_GUILD_LABEL"])

    self.settings.scrollChild.generateExportData:SetText("Export")
    self.settings.scrollChild.importData:SetText("Import")

    self.settings.scrollChild.importExportEditbox.EditBox:SetMaxLetters(999999999)
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
            self.selectedGuild:WipeAllCharacterData()
            self.selectedGuild:ScanGuildRoster()
            self:SetStatusText(string.format("reset guild data for %s", self.selectedGuild:GetName()))

            addon:TriggerEvent("Character_OnDataChanged")
        end
    end)

    self.settings.scrollChild.scanForLocaleData:SetScript("OnClick", function()
        addon:GetLocaleGlyphNames()
        addon:GetLocaleTradeskillInfo()
    end)

    self.settings.scrollChild.generateExportData:SetScript("OnClick", function()
        if self.selectedGuild then
            local dataString = Database:GenerateGuildExportString(self.selectedGuild:GetName())
            self.settings.scrollChild.importExportEditbox.EditBox:SetText(dataString)
        end
    end)

    self.settings.scrollChild.importData:SetScript("OnClick", function()
        print("import")
        if self.settings.scrollChild.importExportEditbox.EditBox:GetText() ~= "" then
            local dataString = self.settings.scrollChild.importExportEditbox.EditBox:GetText()
            Comms.pause = true;
            Database:ImportGuildData(dataString)
        end
    end)


    LoadAddOn("Blizzard_LookingForGroupUI")
    LFGBrowseFrame:HookScript("OnShow", function()
        local activities = C_LFGList.GetAvailableActivities();
        for k, activity in ipairs(activities) do
            local info = C_LFGList.GetActivityInfoTable(activity)
            print(info.fullName, info.displayType)
        end
    end)



    --profile locales
    self.profile.header:SetText(L["PROFILE_HEADER"])
    self.profile.realProfileHelptip:SetText(L["PROFILE_REAL_PROFILE_HELPTIP"])
    self.profile.realNameInput.label:SetText(L["PROFILE_REAL_NAME_LABEL"])
    self.profile.realBioInput.label:SetText(L["PROFILE_REAL_BIO_LABEL"])
    self.profile.realBioInput.EditBox:SetMaxLetters(200)
    self.profile.specializationHelptip:SetText(L["PROFILE_SPECIALIZATIONS_HELPTIP"])

    self.profile:SetScript("OnHide", function()
        for _, guild in ipairs(self.guilds) do
            local player = guild:GetPlayerCharacter()
            if type(player) == "table" then

                player:SetProfileName(self.profile.realNameInput:GetText())
                player:SetProfileBio(self.profile.realBioInput.EditBox:GetText())

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


    -- local function setProf(slot, name)
    --     for k, guild in ipairs(self.guilds) do
    --         local player = guild:GetPlayerCharacter()
    --         if type(player) == "table" then
    --             player:SetTradeskill(slot, name)
    --         end
    --     end
    -- end
    -- self.profile.prof1Dropdown.menu = {};
    -- self.profile.prof2Dropdown.menu = {};
    -- for k, prof in ipairs(tradeskills) do
    --     local localeProfName = Tradeskills:GetLocaleNameFromEnglish(prof);
    --     table.insert(self.profile.prof1Dropdown.menu, {
    --         text = localeProfName,
    --         func = function()
    --             print("selected", prof)
    --         end,
    --     })
    --     table.insert(self.profile.prof2Dropdown.menu, {
    --         text = localeProfName,
    --         func = function()
    --             print("selected", prof)
    --         end,
    --     })
    -- end

end



function GuildbookMixin:LoadHelp()

    self.help.scrollChild.header:SetText(L["HELP_HEADER"])
    self.help.scrollChild.about:SetText(L["HELP_ABOUT"])

    local numFaq = 5

    for i = 1, numFaq do
        local fs = self.help.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")

        fs:SetPoint("TOPLEFT", self.help.scrollChild.about, "BOTTOMLEFT", 0, ((i-1) * -60) -2)
        fs:SetPoint("TOPRIGHT", self.help.scrollChild.about, "BOTTOMRIGHT", 0, ((i-1) * -60) -2)
        
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
    if addonVersion < 5 then
        self.statusText:SetText(string.format("%s needs to update their addon, data ignored...", character:GetName()))
        return;
    end

    self.statusText:SetText(string.format("%s from %s", commType, character:GetName()))

    if commType == "TRADESKILL_WORK_ORDER_ADD" then
        self:TradeskillListviewItem_OnAddToWorkOrder(data.payload, character)
    end

    if commType == "CHARACTER_STATS" then
        character:SetPaperdollStats(data.payload.name, data.payload.stats)
    end

    if commType == "TRADESKILL_RECIPES" then
        self:HandleTradeskillUpdate(senderGUID, data.payload.tradeskill, data.payload.level, data.payload.recipes)
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
    end

    if self.guild.character.selectedCharacter and (self.guild.character.selectedCharacter:GetGuid() == character:GetGuid()) then
        self:InitCharacterEquipmentDropdown(character)
        self:InitCharacterTalentsDropdown(character)
        self:LoadGlyphs(character)
    end

    C_Timer.After(1.0, function()
        guild:UpdateSavedVariablesForCharacter(senderGUID)
    end)
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

        if type(self.selectedGuild) == "table" then

            for k, character in self.selectedGuild:GetCharacters("name") do

                self.guild.members.DataProvider:Insert(character)
            end

        end

    end

end

function GuildbookMixin:OnHide()

end

function GuildbookMixin:OnUpdate()

end


--once the database object has set up and verified the saved variables add some data to VDT and create the guild objects, minimap button
function GuildbookMixin:OnDatabaseInitialised()

    C_Timer.After(10, function()
        -- VirageDevTool then
            ViragDevTool:AddData(GUILDBOOK_GLOBAL, "GUILDBOOK_GLOBAL")
            ViragDevTool:AddData(GUILDBOOK_CONFIG, "GUILDBOOK_CONFIG")
            ViragDevTool:AddData(GUILDBOOK_PRIVACY, "GUILDBOOK_PRIVACY")
            ViragDevTool:AddData(self.workOrders, "Guildbook work orders")
        --end
    end)

    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache then
        
        local i = 0;
        for name, data in pairs(GUILDBOOK_GLOBAL.GuildRosterCache) do
            
            i = i + 1;

            local guild = Guild:NewGuild(name)
            guild:LoadCharactersFromSavedVars()

            C_Timer.After(5, function()
                ViragDevTool:AddData(guild, "Guildbook_Guild "..name)
            end)

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


    --update the settings panel
    self.settings.scrollChild.blockCommsDuringCombat:SetChecked(Database:GetConfigSetting("blockCommsDuringCombat"))
    self.settings.scrollChild.blockCommsDuringInstance:SetChecked(Database:GetConfigSetting("blockCommsDuringInstance"))
    self.settings.scrollChild.showTooltipMainCharacter:SetChecked(Database:GetConfigSetting("showTooltipMainCharacter"))

    self.settings.scrollChild.showTooltipMainSpec:SetChecked(Database:GetConfigSetting("showTooltipMainSpec"))
    self.settings.scrollChild.showTooltipCharacterProfile:SetChecked(Database:GetConfigSetting("showTooltipCharacterProfile"))
    self.settings.scrollChild.showTooltipTradeskills:SetChecked(Database:GetConfigSetting("showTooltipTradeskills"))


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
    
                C_Timer.After(5, function()
                    ViragDevTool:AddData(guild, "Guildbook_Guild "..guildName)
                end)
    
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
    self.profile.secondarySpecDropdown.menu = {}
    
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
            self.profile.realNameInput:SetText(profile.name)
            self.profile.realBioInput.EditBox:SetText(profile.bio)

            self.profile.primarySpecDropdown.MenuText:SetText(player:GetSpec("primary"))
            self.profile.secondarySpecDropdown.MenuText:SetText(player:GetSpec("secondary"))
        end
    end


    -- for tab = 2, GetNumSpellTabs() do
    --     local name, texture, offset, numSlots, isGuild, offspecID = GetSpellTabInfo(tab)

    --     table.insert(self.profile.primarySpecDropdown.menu, {
    --         text = name,
    --         func = function()
    --             setSpec("primary", tab-1)
    --         end,
    --     })
    --     table.insert(self.profile.secondarySpecDropdown.menu, {
    --         text = name,
    --         func = function()
    --             setSpec("secondary", tab-1)
    --         end,
    --     })
    -- end


    --as this requires libs to load, set this on PEW
    local showMinimapButton = Database:GetConfigSetting("showMinimapButton");
    self.settings.scrollChild.showMinimapButton:SetChecked(showMinimapButton)
    if showMinimapButton == true then
        self.MinimapIcon:Show("Guildbook")
    else
        self.MinimapIcon:Hide("Guildbook")
    end

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
    self.guild.members.DataProvider:Flush()
    for k, character in self.selectedGuild:GetCharacters("name") do
        self.guild.members.DataProvider:Insert(character)
    end

    self:OpenTo("guild")

    self.guildName:Show()
    self.guildTradeskills:Show()

    for k, bar in ipairs(self.guild.guildHome.guildClassInfo.bars) do
        bar:SetValue(0)
    end

    --if this is our current guild then lets show some info
    if self.selectedGuild:IsCurrentGuild() then
        
        self.guild.guildHome.guildMOTD:SetText(GetGuildRosterMOTD())


        local classCounts, total = self.selectedGuild:GetClassCounts()
        for k, info in ipairs(classCounts) do
            local sb = self.guild.guildHome.guildClassInfo["bar"..k];
            sb:SetStatusBarColor(Colours[info.class]:GetRGB())
            sb:SetValue(info.count/total)

            sb.icon:SetAtlas(string.format("GarrMission_ClassIcon-%s", info.class))
            sb.text:SetText(string.format("%s [%s%%]", info.count, (info.count/total) * 100))
        end


        self.guild.guildHome.guildCalendarEventsListview.DataProvider:Flush()
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
        self.guild.guildHome.guildCalendarEventsListview.DataProvider:InsertTable(t)

    else

        self.guild.guildHome.guildMOTD:SetText(L["GUILD_HOME_NO_MOTD"])

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
            self.guild.guildHome.activityFeed:AddMessage(string.format("|cffffffff[|r%s|cffffffff]|r %s", Colours[character:GetClass()]:WrapTextInColorCode(Ambiguate(sender, "none")), msg))
        else
            self.guild.guildHome.activityFeed:AddMessage(Colours.Guild:WrapTextInColorCode(string.format("|cffffffff[|r%s|cffffffff]|r %s", Ambiguate(sender, "none"), msg)))
        end
    end
end


function GuildbookMixin:TradeskillListviewItem_OnMouseDown(item)
    
    self.guild.tradeskills.recipeCrafters.selectedItem = nil;

    local recipeHeader;
    if item.tradeskill == 333 then
        recipeHeader = item.name
    else
        recipeHeader = item.link
    end


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

    self.guild.tradeskills.recipeCrafters.header:SetText(L["TRADESKILL_CRAFTERS_HEADER_S"]:format(recipeHeader))

    self.guild.tradeskills.recipeCrafters.DataProvider:Flush()
    if self.selectedGuild then
        local charactersWithRecipe = self.selectedGuild:FindCharactersWithRecipe(item)

        for k, character in ipairs(charactersWithRecipe) do
            self.guild.tradeskills.recipeCrafters.DataProvider:Insert(character)
        end

        self.guild.tradeskills.recipeCrafters.selectedItem = item;
    end

end




function GuildbookMixin:TradeskillListviewItem_OnAddToWorkOrder(order, character)

    if not self.workOrders then
        self.workOrders = {};
    end

    local item = order.item;

    table.insert(self.workOrders, {
        name = item.name,
        tradeskill = item.tradeskill,
        link = item.link,
        itemID = item.itemID,
        reagents = item.reagents,
        character = character or false,
        quantity = order.quantity or 1,
    })

    --DevTools_Dump({self.workOrders})

    self.guild.tradeskills.workOrders.DataProvider:Flush()
    self.guild.tradeskills.workOrders.DataProvider:InsertTable({})
    C_Timer.After(0.1, function()
        self.guild.tradeskills.workOrders.DataProvider:Flush()
        self.guild.tradeskills.workOrders.DataProvider:InsertTable(self.workOrders)
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
    for k, _item in ipairs(self.workOrders) do
        if _item.itemID == item.itemID then
            if _item.character == false and item.character == false then
                key = k; 
            else
                if type(_item.character) == "table" and type(item.character) == "table" and (_item.character:GetGuid() == item.character:GetGuid()) and (_item.quantity == item.quantity) then
                    key = k;
                end
            end
        end
    end

    if key then
        table.remove(self.workOrders, key)
        addon.DEBUG("func", "TradeskillListviewItem_OnRemoveFromWorkOrder", string.format("removed %s from work order", item.name), item)
    end

    --self.guild.tradeskills.workOrders.scrollView:FindFrame(item)

    --not the ideal solution
    C_Timer.After(0.01, function()
        self.guild.tradeskills.workOrders.DataProvider:Flush()
        self.guild.tradeskills.workOrders.DataProvider:InsertTable(self.workOrders)
        self:UpdateWorkOrderReagents()
    end)
end


function GuildbookMixin:UpdateWorkOrderReagents()
    self.guild.tradeskills.workOrderReagents.DataProvider:Flush()

    local reagents = {};
    local numReagents = 0;
    for k, item in ipairs(self.workOrders) do
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
        local msg = {
            type = "TRADESKILL_WORK_ORDER_ADD",
            payload = {
                item = self.guild.tradeskills.recipeCrafters.selectedItem,
                quantity = amount,
            },
        }
        local targetGuid = character:GetGuid()
        Comms:SendChatMessage(msg, "WHISPER", targetGuid, "NORMAL") --leave this as direct so the crafter is aware of request
        --Comms:QueueMessage(msg.type, msg, "WHISPER", targetGuid, "NORMAL")
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



function GuildbookMixin:HandleTradeskillUpdate(guid, tradeskill, level, recipes)

    addon.DEBUG("func", "HandleTradeskillUpdate", string.format("prof %s level %s", tradeskill, level))

    for k, guild in ipairs(self.guilds) do
        local character = guild:GetCharacter(guid)
        if type(character) == "table" then

            local prof = Tradeskills:GetLocaleNameFromID(tradeskill)

            self:SetStatusText(string.format("%s sent %s recipes", character:GetName(), prof))

            addon.DEBUG("func", "HandleTradeskillUpdate", string.format("found character %s seting %s", character:GetName(), tradeskill))

            --addon.DEBUG("func", "OnPlayerTradeskillRecipesScanned", "found character table")

            --DevTools_Dump({character})

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
            if character:GetTradeskill(1) == "-" then
                character:SetTradeskill(1, tradeskill)
                character:SetTradeskillLevel(1, level)
                character:SetTradeskillRecipes(1, recipes)

                addon.DEBUG("func", "OnPlayerTradeskillRecipesScanned", string.format("prof 1 is NEW > set prof 1 as %s at level %s", tradeskill, level))

            else
                if (character:GetTradeskill(1) ~= tradeskill) and character:GetTradeskill(2) == "-" then
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
                self.guild.character.scrollChild.talents.talentTree[tab][row][col]:Hide()
                self.guild.character.scrollChild.talents.talentTree[tab][row][col].TalentIndex = nil;
            end
        end
    end

    local talents = character:GetTalents(spec)
    if #talents ~= 0 then
        for k, info in ipairs(talents) do
            --print(info.Name, info.Rank, info.MaxRank, info.Icon, info.Tab, info.Row, info.Col)
            if self.guild.character.scrollChild.talents.talentTree[info.Tab] and self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row] then
                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col]:Show()
                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetTexture(info.Icon)
                --self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].talentIndex = info.TalentIndex
                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].rank = info.Rank
                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].maxRank = info.MxRnk
                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].link = info.Link
                --self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText(info.Rank) --string.format("%s / %s", info.Rank, info.MxRnk))
                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:Show()
                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].pointsBackground:Show()

                self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].TalentIndex = info.Index

                if info.Rank > 0 then
                    self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetDesaturated(false)
                    if info.Rank < info.MxRnk then
                        self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText('|cff40BF40'..info.Rank)
                        self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder-green")
                    else
                        self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText('|cffFFFF00'..info.Rank)
                        self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder-yellow")
                    end
                else
                    self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetDesaturated(true)
                    self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder")
                    self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:Hide()
                    self.guild.character.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].pointsBackground:Hide()
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
            if not self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i.."Icon"] then
                local f = CreateFrame("FRAME", nil, self.guild.character.scrollChild.profileInfo)
                f:SetSize(20, 20)
                f:SetPoint(point1, self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i], point2, ((k == 1) and -2 or 2), 0)
                f.icon = f:CreateTexture()
                f.icon:SetAllPoints()
                f:SetScript("OnLeave", function()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i.."Icon"] = f;
            else
                self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i.."Icon"].icon:SetTexture()
            end

            if not self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i.."Icon"] then
                local f = CreateFrame("FRAME", nil, self.guild.character.scrollChild.profileInfo)
                f:SetSize(20, 20)
                f:SetPoint(point1, self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i], point2, ((k == 1) and -2 or 2), 0)
                f.icon = f:CreateTexture()
                f.icon:SetAllPoints()
                f:SetScript("OnLeave", function()
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i.."Icon"] = f;
            else
                self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i.."Icon"].icon:SetTexture()
            end


            self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph"..i]:SetText("-")
            self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph"..i]:SetText("-")
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
                    self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph".._major]:SetText(item:GetItemLink())
                    self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph".._major.."Icon"].icon:SetTexture(item:GetItemIcon())
                    self.guild.character.scrollChild.profileInfo[mainOff.."SpecMajorGlyph".._major.."Icon"]:SetScript("OnEnter", function(f)
                        GameTooltip:SetOwner(f, "ANCHOR_TOP")
                        GameTooltip:SetHyperlink(item:GetItemLink())
                    end)
                end)

            elseif glyph.glyphType == "Minor" then


                minor = minor + 1;
                local _minor = minor;
                local item = Item:CreateFromItemID(glyph.itemID)
                item:ContinueOnItemLoad(function()
                    self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph".._minor]:SetText(item:GetItemLink())
                    self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph".._minor.."Icon"].icon:SetTexture(item:GetItemIcon())
                    self.guild.character.scrollChild.profileInfo[mainOff.."SpecMinorGlyph".._minor.."Icon"]:SetScript("OnEnter", function(f)
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

    self.guild.character.selectedCharacter = character;

    local class = character:GetClass()

    self.guild.character.scrollChild.model:Undress()

    self.guild.character.scrollChild.name:SetText(Colours[class]:WrapTextInColorCode(character:GetName()))
    self.guild.background:SetAtlas(string.format("legionmission-complete-background-%s", class:lower()))

    --profile strings
    self.guild.character.scrollChild.profileInfo.level:SetText(L["PROFILE_LEVEL_S"]:format(character:GetLevel()))

    self.guild.character.scrollChild.profileInfo.mainSpec:SetText(character:GetSpec("primary"))
    self.guild.character.scrollChild.profileInfo.mainSpecIcon:SetAtlas(character:GetClassSpecAtlasName("primary"))
    self.guild.character.scrollChild.profileInfo.mainSpecIsPvpTick:Hide()
    self.guild.character.scrollChild.profileInfo.mainSpecIsPvpTick:SetShown(character:GetSpecIsPvp("primary"))

    self.guild.character.scrollChild.profileInfo.offSpec:SetText(character:GetSpec("secondary"))
    self.guild.character.scrollChild.profileInfo.offSpecIcon:SetAtlas(character:GetClassSpecAtlasName("secondary"))
    self.guild.character.scrollChild.profileInfo.offSpecIsPvpTick:Hide()
    self.guild.character.scrollChild.profileInfo.offSpecIsPvpTick:SetShown(character:GetSpecIsPvp("secondary"))

    self.guild.character.scrollChild.profileInfo.realName:SetText(character:GetProfileName() or "-")
    self.guild.character.scrollChild.profileInfo.realBio:SetText(character:GetProfileBio() or "-")

    local prof1 = Tradeskills:GetLocaleNameFromID(character:GetTradeskill(1)) or "-"
    local atlas1 = prof1 ~= "-" and CreateAtlasMarkup("Mobile-"..prof1, 20, 20) or " "
    if character:GetTradeskill(1) == 202 then
        atlas1 = CreateAtlasMarkup("Mobile-Enginnering", 20, 20)
    end
    self.guild.character.scrollChild.profileInfo.prof1:SetText(string.format("%s %s %s", atlas1, prof1, character:GetTradeskillLevel(1)))
    
    local prof2 = Tradeskills:GetLocaleNameFromID(character:GetTradeskill(2)) or "-"
    local atlas2 = prof2 ~= "-" and CreateAtlasMarkup("Mobile-"..prof1, 20, 20) or " "
    if character:GetTradeskill(2) == 202 then
        atlas2 = CreateAtlasMarkup("Mobile-Enginnering", 20, 20)
    end
    self.guild.character.scrollChild.profileInfo.prof2:SetText(string.format("%s %s %s", atlas2, prof2, character:GetTradeskillLevel(2)))
    
    self.guild.character.scrollChild.profileInfo.cooking:SetText(string.format("%s %s %s", CreateAtlasMarkup("Mobile-Cooking", 20, 20), Tradeskills:GetLocaleNameFromID(185), character:GetCookingLevel() or "-"))
    self.guild.character.scrollChild.profileInfo.fishing:SetText(string.format("%s %s %s", CreateAtlasMarkup("Mobile-Fishing", 20, 20), Tradeskills:GetLocaleNameFromID(356), character:GetFishingLevel() or "-"))
    self.guild.character.scrollChild.profileInfo.firstAid:SetText(string.format("%s %s %s", CreateAtlasMarkup("Mobile-FirstAid", 20, 20), Tradeskills:GetLocaleNameFromID(129), character:GetFirstAidLevel() or "-"))
    

    for k, slot in ipairs(self.guild.character.scrollChild.equipSlots) do
        slot:ClearItem()
    end
    self:InitCharacterEquipmentDropdown(character)


    --talents
    for tab = 1, 3 do
        for col = 1, 4 do
            for row = 1, 11 do
                self.guild.character.scrollChild.talents.talentTree[tab][row][col]:Hide()
                self.guild.character.scrollChild.talents.talentTree[tab][row][col].TalentIndex = nil;
            end
        end
    end
    self.guild.character.scrollChild.talents.tree1:SetTexture(nil)
    self.guild.character.scrollChild.talents.tree1:SetAlpha(0.6)
    self.guild.character.scrollChild.talents.tree2:SetTexture(nil)
    self.guild.character.scrollChild.talents.tree2:SetAlpha(0.6)
    self.guild.character.scrollChild.talents.tree3:SetTexture(nil)
    self.guild.character.scrollChild.talents.tree3:SetAlpha(0.6)

    self:InitCharacterTalentsDropdown(character)
    self:LoadGlyphs(character)

    self.guild.character.scrollChild.talentsDropdown.MenuText:SetText(L["PROFILE_TALENT_DROPDOWN_LABEL"])

    local backgrounds = talentTabsToBackground[class]
    self.guild.character.scrollChild.talents.tree1:SetTexture(string.format("interface/talentframe/%s-topleft.blp", backgrounds[1]))
    --self.guild.character.scrollChild.talents.tree1:SetTexture(string.format("Interface/TalentFrame/%s%s-TopLeft", "Paladin", "Holy"))
    self.guild.character.scrollChild.talents.tree1:SetAlpha(0.6)
    self.guild.character.scrollChild.talents.tree2:SetTexture(string.format("interface/talentframe/%s-topleft.blp", backgrounds[2]))
    self.guild.character.scrollChild.talents.tree2:SetAlpha(0.6)
    self.guild.character.scrollChild.talents.tree3:SetTexture(string.format("interface/talentframe/%s-topleft.blp", backgrounds[3]))
    self.guild.character.scrollChild.talents.tree3:SetAlpha(0.6)

end


function GuildbookMixin:InitCharacterTalentsDropdown(character)
    local talentMenu = {};
    table.insert(talentMenu, {
        text = "Primary",
        func = function()
            self:LoadTalents(character, "primary")
        end,
    })
    table.insert(talentMenu, {
        text = "Secondary",
        func = function()
            self:LoadTalents(character, "secondary")
        end,
    })
    self.guild.character.scrollChild.talentsDropdown.menu = talentMenu;
end


function GuildbookMixin:InitCharacterEquipmentDropdown(character)
    local equipment = character:GetInventory()
    self.guild.character.scrollChild.equipsetDropdown.MenuText:SetText(L["PROFILE_EQUIPMENT_DROPDOWN_LABEL"])
    self.guild.character.scrollChild.equipsetDropdown.menu = {}
    for name, info in pairs(equipment) do
        table.insert(self.guild.character.scrollChild.equipsetDropdown.menu, {
            text = name,
            func = function()
                for k, slot in ipairs(self.guild.character.scrollChild.equipSlots) do
                    local itemID = equipment[name][k]
                    slot:ClearItem()
                    slot:SetItem(itemID)

                    self.guild.character.scrollChild.model:TryOn(string.format("item:%d",itemID))


                    self.guild.character.scrollChild.stats.DataProvider:Flush()
                    local stats = character:GetPaperdollStats(name)
                    if type(stats) == "table" then
                        local t = {}
                        for k, v in pairs(stats) do
                            table.insert(t, {
                                name = k,
                                value = v,
                            })
                        end
                        self.guild.character.scrollChild.stats.DataProvider:InsertTable(t)
                    end
                end
            end,
        })
    end
end