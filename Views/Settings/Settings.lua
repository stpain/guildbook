local name, addon = ...;
local L = addon.Locales
local Database = addon.Database;
local Tradeskills = addon.Tradeskills;

GuildbookSettingsMixin = {
    name = "Settings",
    panelsLoaded = {
        character = false,
        guild = false,
        guildBank = false,
        tradeskills = false,
        chat = false,
    }
}

function GuildbookSettingsMixin:OnLoad()

    local categories = {
        {
            label = "Character",
            atlas = "GarrMission_MissionIcon-Recruit",
            func = function ()
                self:SelectCategory("character")
            end,
        },
        {
            label = "Guild",
            atlas = "GarrMission_MissionIcon-Logistics",
            func = function ()
                self:SelectCategory("guild")
            end,
        },
        {
            label = "Tradeskills",
            atlas = "GarrMission_MissionIcon-Blacksmithing",
            func = function ()
                self:SelectCategory("tradeskills")
            end,
        },
        {
            label = "Chat",
            atlas = "socialqueuing-icon-group",
            func = function ()
                self:SelectCategory("chat")
            end,
        },
        {
            label = "Guild Bank",
            atlas = "ShipMissionIcon-Treasure-Mission",
            func = function ()
                self:SelectCategory("guildBank")
            end,
        },
        {
            label = "Addon",
            atlas = "GarrMission_MissionIcon-Engineering",
            func = function ()
                self:SelectCategory("addon")
            end,
        },
    }

    self.content.character.header:SetText(L.CHARACTER)
    self.content.character.general:SetText(L.SETTINGS_CHARACTER_GENERAL)
    self.content.chat.header:SetText(L.CHAT)
    self.content.chat.general:SetText(L.SETTINGS_CHAT_GENERAL)
    self.content.addon.header:SetText(L.ADDON)
    self.content.addon.general:SetText(L.SETTINGS_ADDON_GENERAL)
    self.content.guildBank.header:SetText(L.GUILDBANK)
    self.content.guildBank.general:SetText(L.SETTINGS_GUILDBANK_GENERAL)
    self.content.tradeskills.header:SetText(L.TRADESKILLS)
    self.content.tradeskills.general:SetText(L.SETTINGS_TRADESKILLS_GENERAL)

    

    self.content.character:SetScript("OnShow", function()
        self:CharacterPanel_OnShow()
    end)
    self.content.guild:SetScript("OnShow", function()
        self:GuildPanel_OnShow()
    end)
    self.content.tradeskills:SetScript("OnShow", function()
        self:TradeskillPanel_OnShow()
    end)
    self.content.guildBank:SetScript("OnShow", function()
        self:GuildBankPanel_OnShow()
    end)
    self.content.chat:SetScript("OnShow", function()
        self:ChatPanel_OnShow()
    end)

    self.categoryListview.DataProvider:InsertTable(categories)

    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
    addon:RegisterCallback("Database_OnInitialised", self.Database_OnInitialised, self)
    addon:RegisterCallback("Blizzard_OnInitialGuildRosterScan", self.Blizzard_OnInitialGuildRosterScan, self)


    --quickly added for testing
    self.content.addon.factoryReset:SetScript("OnClick", function()
        Database:Reset()
    end)
    self.content.addon.debug.label:SetText(L.SETTINGS_ADDON_DEBUG_LABEL)
    self.content.addon.debug:SetScript("OnClick", function(cb)
        Database.db.debug = cb:GetChecked()
    end)

    addon.AddView(self)
end


function GuildbookSettingsMixin:UpdateLayout()
    local x, y = self.content:GetSize()

    local characterScroll = self.content.character.scrollFrame.scrollChild;
    local tradeskillsScroll = self.content.tradeskills.scrollFrame.scrollChild;

    if x < 680 then
        
        characterScroll.myCharacters:ClearAllPoints()
        characterScroll.myCharacters:SetPoint("TOP", characterScroll.specializations, "BOTTOM", 0, -10)
        
        tradeskillsScroll.reagentItems:ClearAllPoints()
        tradeskillsScroll.reagentItems:SetPoint("TOP", tradeskillsScroll.tradeskillItems, "BOTTOM", 0, -10)


    else

        characterScroll.myCharacters:ClearAllPoints()
        characterScroll.myCharacters:SetPoint("TOPLEFT", characterScroll.specializations, "TOPRIGHT", 20, 0)

        tradeskillsScroll.reagentItems:ClearAllPoints()
        tradeskillsScroll.reagentItems:SetPoint("TOPLEFT", tradeskillsScroll.tradeskillItems, "TOPRIGHT", 20, 0)
    end

end

function GuildbookSettingsMixin:PrepareCharacterPanel()

    --=========================================
    --character panel
    --this setup requires the addon.characters table to be populated
    --so this gets called after the initial roster scan
    --=========================================

    local panel = self.content.character.scrollFrame.scrollChild;

    for i = 1, 4 do
        panel.specializations["mainSpec"..i]:Hide()
        panel.specializations["offSpec"..i]:Hide()
    end

    if addon.characters and addon.characters[addon.thisCharacter] then
        local character = addon.characters[addon.thisCharacter];

        local specs = character:GetSpecializations()
        local atlasNames = character:GetClassSpecAtlasInfo()
        for k, spec in ipairs(specs) do
            if spec then
                panel.specializations["mainSpec"..k].label:SetText(string.format("%s  %s", CreateAtlasMarkup(atlasNames[k], 22, 22), spec))
                panel.specializations["mainSpec"..k]:Show()
                panel.specializations["mainSpec"..k]:SetScript("OnClick", function(cb)
                    for i = 1, 4 do
                        panel.specializations["mainSpec"..i]:SetChecked(false)
                    end
                    cb:SetChecked(true)
                    character:SetSpec("primary", k, true)
                end)
                panel.specializations["offSpec"..k].label:SetText(string.format("%s  %s", CreateAtlasMarkup(atlasNames[k], 22, 22), spec))
                panel.specializations["offSpec"..k]:Show()
                panel.specializations["offSpec"..k]:SetScript("OnClick", function(cb)
                    for i = 1, 4 do
                        panel.specializations["offSpec"..i]:SetChecked(false)
                    end
                    cb:SetChecked(true)
                    character:SetSpec("secondary", k, true)
                end)
            end
        end
        if type(character.data.mainSpec) == "number" then
            panel.specializations["mainSpec"..character.data.mainSpec]:SetChecked(true)
        end
        if type(character.data.offSpec) == "number" then
            panel.specializations["offSpec"..character.data.offSpec]:SetChecked(true)
        end
    end

    panel.myCharacters.listview.DataProvider:Flush()
    local alts = {}
    if Database.db.myCharacters then
        for name, isMain in pairs(Database.db.myCharacters) do
            if addon.characters[name] then
                table.insert(alts, {
                    character = addon.characters[name],
                }) 
            end
        end
    end
    panel.myCharacters.listview.DataProvider:InsertTable(alts)

    panel.reset:SetScript("OnClick", function()
        if addon.characters and addon.characters[addon.thisCharacter] then
            addon.characters[addon.thisCharacter]:ResetData()
        end
    end)
end


function GuildbookSettingsMixin:PreparePanels()

    --=========================================
    --chat panel
    --=========================================
    local chatSliders = {
        ["Guild history limit"] = "chatGuildHistoryLimit",
        ["Whisper history limit"] = "chatWhisperHistoryLimit",
    }

    for label, slider in pairs(chatSliders) do

        self.content.chat[slider].label:SetText(label)
        self.content.chat[slider].value:SetText(Database.db.config[slider])
        self.content.chat[slider]:SetMinMaxValues(10, 80)
        self.content.chat[slider]:SetValue(Database.db.config[slider])

        _G[self.content.chat[slider]:GetName().."Low"]:SetText(" ")
        _G[self.content.chat[slider]:GetName().."High"]:SetText(" ")
        _G[self.content.chat[slider]:GetName().."Text"]:SetText(" ")

        self.content.chat[slider]:SetScript("OnMouseWheel", function(s, delta)
            s:SetValue(s:GetValue() + delta)
        end)

        self.content.chat[slider]:SetScript("OnValueChanged", function(s)
            local val = math.ceil(s:GetValue())
            s.value:SetText(val)
            Database:SetConfig(slider, val)

            --as chat messages get received the chat view update func will handle any table trimming
            --here we just need to set the db values            
        end)
    end

    self.content.chat.deleteAllChats:SetScript("OnClick", function()
        Database:ResetKey("chats", {
            guild = {},
        })
    end)



    --=========================================
    --addon panel
    --=========================================
    self.content.addon.debug:SetChecked(Database.db.debug)
    


    --=========================================
    --guild panel
    --=========================================
    self.content.guild.scrollFrame.scrollChild.modBlizzRoster.label:SetText(L.SETTINGS_GUILD_MOD_BLIZZ_ROSTER)
    self.content.guild.scrollFrame.scrollChild.modBlizzRoster:SetScript("OnClick", function(cb)
        Database.db.config["modBlizzRoster"] = cb:GetChecked()

        if Database.db.config["modBlizzRoster"] == false then
            ReloadUI()

        else
            addon:ModBlizzUI()
        end
    end)

    self.content.guild.scrollFrame.scrollChild.modBlizzRoster:SetChecked(Database.db.config["modBlizzRoster"])

    if Database.db.config["modBlizzRoster"] then
        addon:ModBlizzUI()
    end


    --=========================================
    --Tradeskills panel
    --=========================================

    local recipeCheckboxes = {
        "tradeskillsShowAllRecipeInfoTooltip",
        "tradeskillsShowMyRecipeInfoTooltip",    
    }
    for k, v in ipairs(recipeCheckboxes) do
        self.content.tradeskills.scrollFrame.scrollChild.tradeskillItems[v]:SetChecked(Database.db.config[v])
        self.content.tradeskills.scrollFrame.scrollChild.tradeskillItems[v]:SetScript("OnClick", function(cb)
            -- for k, v in ipairs(recipeCheckboxes) do
            --     self.content.tradeskills.scrollFrame.scrollChild.tradeskillItems[v]:SetChecked(false)
            --     Database.db.config[v] = false
            -- end
            -- cb:SetChecked(true)
            Database.db.config[v] = cb:GetChecked()
        end)
    end

    local reagentCheckboxes = {  
        "tradeskillsShowAllRecipesUsingTooltip",
        "tradeskillsShowMyRecipesUsingTooltip",
    }
    for k, v in ipairs(reagentCheckboxes) do
        self.content.tradeskills.scrollFrame.scrollChild.reagentItems[v]:SetChecked(Database.db.config[v])
        self.content.tradeskills.scrollFrame.scrollChild.reagentItems[v]:SetScript("OnClick", function(cb)
            -- for k, v in ipairs(reagentCheckboxes) do
            --     self.content.tradeskills.scrollFrame.scrollChild.reagentItems[v]:SetChecked(false)
            --     Database.db.config[v] = false
            -- end
            -- cb:SetChecked(true)
            Database.db.config[v] = cb:GetChecked()
        end)
    end

    self.content.tradeskills.scrollFrame.scrollChild.tradeskillItems.tradeskillsShowAllRecipeInfoTooltip.label:SetText(L.SETTINGS_TRADESKILLS_TT_RECIPE_INFO_ALL)
    self.content.tradeskills.scrollFrame.scrollChild.tradeskillItems.tradeskillsShowMyRecipeInfoTooltip.label:SetText(L.SETTINGS_TRADESKILLS_TT_RECIPE_INFO_MY)

    self.content.tradeskills.scrollFrame.scrollChild.reagentItems.tradeskillsShowAllRecipesUsingTooltip.label:SetText(L.SETTINGS_TRADESKILLS_TT_REAGENT_FOR_ALL)
    self.content.tradeskills.scrollFrame.scrollChild.reagentItems.tradeskillsShowMyRecipesUsingTooltip.label:SetText(L.SETTINGS_TRADESKILLS_TT_REAGENT_FOR_MY)

    GameTooltip:HookScript("OnTooltipSetItem", function(tt)

        local name, link = tt:GetItem()
        if link then
            local itemID = GetItemInfoInstant(link)
            if itemID then
                local itemInfo = addon.api.getTradeskillItemDataFromID(itemID)
                if Database.db.config.tradeskillsShowAllRecipeInfoTooltip == true then
                    if itemInfo then
                        tt:AddLine(" ")
                        tt:AddLine(string.format("%s |cffffffff%s", CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(itemInfo.tradeskillID), 20, 20), Tradeskills:GetLocaleNameFromID(itemInfo.tradeskillID)))
                        tt:AddDoubleLine(L.REAGENT, L.COUNT)
                        for id, count in pairs(itemInfo.reagents) do
                            local item = Item:CreateFromItemID(id)
                            if not item:IsItemEmpty() then
                                item:ContinueOnItemLoad(function()
                                    tt:AddDoubleLine(item:GetItemLink(), "|cffffffff"..count)
                                end)
                            end
                        end
                    end
                else
                    if Database.db.config.tradeskillsShowMyRecipeInfoTooltip == true then
                        if itemInfo and addon.characters[addon.thisCharacter] then
                            if (itemInfo.tradeskillID == addon.characters[addon.thisCharacter].data.profession1) or (itemInfo.tradeskillID == addon.characters[addon.thisCharacter].data.profession2) then
                                tt:AddLine(" ")
                                tt:AddLine(string.format("%s |cffffffff%s", CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(itemInfo.tradeskillID), 20, 20), Tradeskills:GetLocaleNameFromID(itemInfo.tradeskillID)))
                                tt:AddDoubleLine(L.REAGENT, L.COUNT)
                                for id, count in pairs(itemInfo.reagents) do
                                    local item = Item:CreateFromItemID(id)
                                    if not item:IsItemEmpty() then
                                        item:ContinueOnItemLoad(function()
                                            tt:AddDoubleLine(item:GetItemLink(), "|cffffffff"..count)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end

                if Database.db.config.tradeskillsShowAllRecipesUsingTooltip == true then
                    local recipesUsingItem = addon.api.getTradeskillItemsUsingReagentItemID(itemID)
                    if next(recipesUsingItem) then
                        tt:AddLine(" ")
                        tt:AddLine(L.SETTINGS_TRADESKILLS_TT_REAGENT_FOR_HEADER)
                    end
                    for tradeskillID, recipes in pairs(recipesUsingItem) do
                        tt:AddLine(" ")
                        tt:AddLine(string.format("%s %s", CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(tradeskillID), 20, 20), Tradeskills:GetLocaleNameFromID(tradeskillID)))
                        for k, v in ipairs(recipes) do
                            tt:AddLine(v.itemLink)
                        end
                    end
                else
                    if Database.db.config.tradeskillsShowMyRecipesUsingTooltip == true and addon.characters[addon.thisCharacter] then
                        local recipesUsingItem = addon.api.getTradeskillItemsUsingReagentItemID(itemID, addon.characters[addon.thisCharacter].data.profession1, addon.characters[addon.thisCharacter].data.profession2)
                        if next(recipesUsingItem) then
                            tt:AddLine(" ")
                            tt:AddLine(L.SETTINGS_TRADESKILLS_TT_REAGENT_FOR_HEADER)
                        end                        for tradeskillID, recipes in pairs(recipesUsingItem) do
                            tt:AddLine(" ")
                            tt:AddLine(string.format("%s %s", CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(tradeskillID), 20, 20), Tradeskills:GetLocaleNameFromID(tradeskillID)))
                            for k, v in ipairs(recipes) do
                                tt:AddLine(v.itemLink)
                            end
                        end
                    end
                end

            end
        end

    end)
end

function GuildbookSettingsMixin:CharacterPanel_OnShow()

    local x, y = self.content:GetSize()
    self.content.character.scrollFrame.scrollChild:SetSize(x-24, y)

end

function GuildbookSettingsMixin:TradeskillPanel_OnShow()

    local x, y = self.content:GetSize()
    self.content.tradeskills.scrollFrame.scrollChild:SetSize(x-24, y)

end

function GuildbookSettingsMixin:GuildPanel_OnShow()

    local x, y = self.content:GetSize()
    self.content.guild.scrollFrame.scrollChild:SetSize(x-24, y)

end

function GuildbookSettingsMixin:GuildBankPanel_OnShow()

    --this remains in OnShow as bank characters can eb added/removed during gameplay
    self.content.guildBank.listview.DataProvider:Flush()
    local t = {}
    if addon.characters then
        for k, character in pairs(addon.characters) do
            if character.data.publicNote:lower() == "guildbank" then
                table.insert(t, {
                    character = character,
                })
            end
        end
    end

    self.content.guildBank.listview.DataProvider:InsertTable(t)
end



function GuildbookSettingsMixin:SelectCategory(category)

    for k, v in ipairs(self.content.panels) do
        v:Hide()
    end
    if self.content[category] then
        self.content[category]:Show()
    end
end


function GuildbookSettingsMixin:ChatPanel_OnShow()

end

function GuildbookSettingsMixin:Database_OnInitialised()
    self:PreparePanels()
end

function GuildbookSettingsMixin:Blizzard_OnInitialGuildRosterScan()
    self:PrepareCharacterPanel()
end