local addonName, addon = ...;
local L = addon.Locales
local Database = addon.Database;
local Tradeskills = addon.Tradeskills;
local Talents = addon.Talents;

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
    182,
    393,
    --185,
    --129,
    --356,
}

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
            --atlas = "GarrMission_MissionIcon-Recruit",
            backgroundAlpha = 0.15,
            onMouseDown = function ()
                self:SelectCategory("character")
            end,
        },
        {
            label = "Guild",
            --atlas = "GarrMission_MissionIcon-Logistics",
            backgroundAlpha = 0.15,
            onMouseDown = function ()
                self:SelectCategory("guild")
            end,
        },
        {
            label = "Tradeskills",
            --atlas = "GarrMission_MissionIcon-Blacksmithing",
            backgroundAlpha = 0.15,
            onMouseDown = function ()
                self:SelectCategory("tradeskills")
            end,
        },
        {
            label = "Chat",
            --atlas = "socialqueuing-icon-group",
            backgroundAlpha = 0.15,
            onMouseDown = function ()
                self:SelectCategory("chat")
            end,
        },
        -- {
        --     label = "Guild Bank",
        --     --atlas = "ShipMissionIcon-Treasure-Mission",
        --     backgroundAlpha = 0.15,
        --     onMouseDown = function ()
        --         self:SelectCategory("guildBank")
        --     end,
        -- },
        {
            label = "Addon",
            --atlas = "GarrMission_MissionIcon-Engineering",
            backgroundAlpha = 0.15,
            onMouseDown = function ()
                self:SelectCategory("addon")
            end,
        },
        {
            label = "Help",
            --atlas = "GarrMission_MissionIcon-Engineering",
            backgroundAlpha = 0.15,
            onMouseDown = function ()
                self:SelectCategory("help")
            end,
        },
    }

    self.content.character.header:SetText(L.CHARACTER)
    self.content.character.general:SetText(L.SETTINGS_CHARACTER_GENERAL)
    self.content.character.tabContainer.tradeskills.header:SetText(L.SETTINGS_CHARACTER_TRADESKILLS_HEADER)
    self.content.chat.header:SetText(L.CHAT)
    self.content.chat.general:SetText(L.SETTINGS_CHAT_GENERAL)
    self.content.addon.header:SetText(L.ADDON)
    self.content.addon.general:SetText(L.SETTINGS_ADDON_GENERAL)
    self.content.addon.discord:SetText("https://discord.gg/st5uDAX5Cn")
    self.content.guildBank.header:SetText(L.GUILDBANK)
    self.content.guildBank.general:SetText(L.SETTINGS_GUILDBANK_GENERAL)
    self.content.tradeskills.header:SetText(L.TRADESKILLS)
    self.content.tradeskills.general:SetText(L.SETTINGS_TRADESKILLS_GENERAL)
    
    --character tab panels
    local tabs = {
        {
            label = SPECIALIZATION,
            width = 100,
            panel = self.content.character.tabContainer.specializations,
        },
        {
            label = "Professions",
            width = 100,
            panel = self.content.character.tabContainer.tradeskills,
        },
    }
    self.content.character.tabContainer:CreateTabButtons(tabs)

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
    addon:RegisterCallback("Character_OnDataChanged", self.Character_OnDataChanged, self)


    --quickly added for testing
    self.content.addon.factoryReset:SetScript("OnClick", function()
        Database:Reset()
    end)
    self.content.addon.debug.label:SetText(L.SETTINGS_ADDON_DEBUG_LABEL)
    self.content.addon.debug:SetScript("OnClick", function(cb)
        Database.db.debug = cb:GetChecked()
    end)

    self.content.addon.enhancedPaperDoll.label:SetText(L.SETTINGS_ADDON_ENHANCE_PAPERDOLL_LABEL)
    self.content.addon.enhancedPaperDoll:SetScript("OnClick", function(cb)
        local isChecked = cb:GetChecked()
        Database:SetConfig("enhancedPaperDoll", isChecked)
        addon.api.updatePaperdollOverlays()
    end)

    self.content.addon.wholeNineYards.label:SetSize(550, 80)
    self.content.addon.wholeNineYards.label:SetText(L.SETTINGS_ADDON_WNY_LABEL)
    self.content.addon.wholeNineYards:SetScript("OnClick", function(cb)
        Database:SetConfig("wholeNineYards", cb:GetChecked())
    end)


    self.content.help.text:SetText(string.format("%s\n\n\n\n%s\n\n\n\n%s\n\n\n\n%s",
        L.SETTINGS_HELP_TEXT_GENERAL,
        L.SETTINGS_HELP_TEXT_TALENTS,
        L.SETTINGS_HELP_TEXT_TRADESKILLS,
        L.SETTINGS_HELP_TEXT_DAILIES
    ))

    addon.AddView(self)
end


function GuildbookSettingsMixin:UpdateLayout()
    local x, y = self.content:GetSize()

    --local characterScroll = self.content.character.scrollFrame.scrollChild;
    local tradeskillsScroll = self.content.tradeskills.scrollFrame.scrollChild;

    if x < 680 then
        tradeskillsScroll.reagentItems:ClearAllPoints()
        tradeskillsScroll.reagentItems:SetPoint("TOP", tradeskillsScroll.tradeskillItems, "BOTTOM", 0, -10)

    else
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

    local panel = self.content.character.tabContainer;

    for i = 1, 4 do
        panel.specializations["mainSpec"..i]:Hide()
        panel.specializations["offSpec"..i]:Hide()
    end


    if addon.characters and addon.characters[addon.thisCharacter] then
        local character = addon.characters[addon.thisCharacter];

        local _, class = GetClassInfo(character.data.class);
        self.content.character.tabContainer.specializations.background:SetAtlas(string.format("legionmission-complete-background-%s", class:lower()))

        --specializations
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

                    local info = Talents:GetSpecInfoFromClassTabIndex(character.data.class, k-1)
                    if info then
                        panel.specializations.infoMainSpec:SetText(info.description)
                    end
                end)
                panel.specializations["offSpec"..k].label:SetText(string.format("%s  %s", CreateAtlasMarkup(atlasNames[k], 22, 22), spec))
                panel.specializations["offSpec"..k]:Show()
                panel.specializations["offSpec"..k]:SetScript("OnClick", function(cb)
                    for i = 1, 4 do
                        panel.specializations["offSpec"..i]:SetChecked(false)
                    end
                    cb:SetChecked(true)
                    character:SetSpec("secondary", k, true)

                    local info = Talents:GetSpecInfoFromClassTabIndex(character.data.class, k-1)
                    if info then
                        panel.specializations.infoOffSpec:SetText(info.description)
                    end
                end)
            end
        end
        if type(character.data.mainSpec) == "number" then
            panel.specializations["mainSpec"..character.data.mainSpec]:SetChecked(true)
            local info = Talents:GetSpecInfoFromClassTabIndex(character.data.class, character.data.mainSpec-1)
            if info then
                panel.specializations.infoMainSpec:SetText(info.description)
            end
        end
        if type(character.data.offSpec) == "number" then
            panel.specializations["offSpec"..character.data.offSpec]:SetChecked(true)
            local info = Talents:GetSpecInfoFromClassTabIndex(character.data.class, character.data.offSpec-1)
            if info then
                panel.specializations.infoOffSpec:SetText(info.description)
            end
        end
    
        --tradeskills
        if type(character.data.profession1) == "number" then
            local profName = Tradeskills:GetLocaleNameFromID(character.data.profession1)
            panel.tradeskills.prof1:SetDataBinding({
                atlas = Tradeskills:TradeskillIDToAtlas(character.data.profession1),
                label = profName,
                labelRight = date("%Y-%m-%d %H:%M:%S", Database:GetCharacterSyncData("profession1")),
                onMouseDown = function(f, button)
                    if button == "RightButton" then
                        local menu = {
                            {
                                text = profName,
                                isTitle = true,
                                notCheckable = true,
                            }
                        }
                        table.insert(menu, addon.contextMenuSeparator)
                        table.insert(menu, {
                            text = "Send data",
                            notCheckable = true,
                            func = function()
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskill", "profession1")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillRecipes", "profession1Recipes")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillLevel", "profession1Level")
                            end,
                        })
                        table.insert(menu, {
                            text = DELETE,
                            notCheckable = true,
                            func = function()
                                character.data.profession1 = "-";
                                character.data.profession1Level = 0;
                                character.data.profession1Recipes = {};
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskill", "profession1")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillRecipes", "profession1Recipes")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillLevel", "profession1Level")
                            end,
                        })

                        EasyMenu(menu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                    end

                end,
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof1, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS:format(profName, #character.data.profession1Recipes or 0), 1,1,1, true)
                end,
                backgroundAtlas = "transmog-set-iconrow-background"
            }, 40)
        else
            panel.tradeskills.prof1:SetDataBinding({
                atlas = "QuestTurnin",
                label = "-",
                onMouseDown = function(f, button)
                    if button == "RightButton" then
                        local menu = {
                            {
                                text = "Set profession",
                                notCheckable = true,
                                isTitle = true,
                            }
                        }
                        table.insert(menu, addon.contextMenuSeparator)

                        for k, tradeskillID in ipairs(tradeskills) do
                            table.insert(menu, {
                                text = Tradeskills:GetLocaleNameFromID(tradeskillID),
                                notCheckable = true,
                                func = function()
                                    character:SetTradeskill(1, tradeskillID, true)
                                end,
                            })
                        end

                        EasyMenu(menu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                    end
                end,
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof1, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS_MISSING_DATA, 1,1,1, true)
                end,
                labelRight = "No Data"
            }, 40)
        end

        if type(character.data.profession2) == "number" then
            local profName = Tradeskills:GetLocaleNameFromID(character.data.profession2)
            panel.tradeskills.prof2:SetDataBinding({
                atlas = Tradeskills:TradeskillIDToAtlas(character.data.profession2),
                label = profName,
                labelRight =  date("%Y-%m-%d %H:%M:%S", Database:GetCharacterSyncData("profession2")),
                onMouseDown = function(f, button)
                    if button == "RightButton" then
                        local menu = {
                            {
                                text = profName,
                                isTitle = true,
                                notCheckable = true,
                            }
                        }
                        table.insert(menu, addon.contextMenuSeparator)
                        table.insert(menu, {
                            text = "Send data",
                            notCheckable = true,
                            func = function()
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskill", "profession2")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillRecipes", "profession2Recipes")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillLevel", "profession2Level")
                            end,
                        })
                        table.insert(menu, {
                            text = DELETE,
                            notCheckable = true,
                            func = function()
                                character.data.profession2 = "-";
                                character.data.profession2Level = 0;
                                character.data.profession2Recipes = {};
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskill", "profession2")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillRecipes", "profession2Recipes")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillLevel", "profession2Level")
                            end,
                        })

                        EasyMenu(menu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                    end
                end,
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof2, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS:format(profName, #character.data.profession2Recipes or 0), 1,1,1, true)
                end,
                backgroundAtlas = "transmog-set-iconrow-background"
            }, 40)
        else
            panel.tradeskills.prof2:SetDataBinding({
                atlas = "QuestTurnin",
                label = "-",
                onMouseDown = function(f, button)
                    if button == "RightButton" then
                        local menu = {
                            {
                                text = "Set profession",
                                notCheckable = true,
                                isTitle = true,
                            }
                        }
                        table.insert(menu, addon.contextMenuSeparator)

                        for k, tradeskillID in ipairs(tradeskills) do
                            table.insert(menu, {
                                text = Tradeskills:GetLocaleNameFromID(tradeskillID),
                                notCheckable = true,
                                func = function()
                                    character:SetTradeskill(2, tradeskillID, true)
                                end,
                            })
                        end

                        EasyMenu(menu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                    end
                end,
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof2, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS_MISSING_DATA, 1,1,1, true)
                end,
                labelRight = "No Data"
            }, 40)
        end

        if #character.data.cookingRecipes > 0 then
            panel.tradeskills.cooking:SetDataBinding({
                atlas = "Mobile-Cooking",
                label = PROFESSIONS_COOKING,
                labelRight =  date("%Y-%m-%d %H:%M:%S", Database:GetCharacterSyncData("cookingRecipes")),
                onMouseDown = function(f, button)
                    if button == "RightButton" then
                        local menu = {
                            {
                                text = PROFESSIONS_COOKING,
                                isTitle = true,
                                notCheckable = true,
                            }
                        }
                        table.insert(menu, addon.contextMenuSeparator)
                        table.insert(menu, {
                            text = "Send data",
                            notCheckable = true,
                            func = function()
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskill", "cooking")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillRecipes", "cookingRecipes")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillLevel", "cookingLevel")
                            end,
                        })

                        EasyMenu(menu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                    end
                end,
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof2, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS:format(PROFESSIONS_COOKING, #character.data.cookingRecipes or 0), 1,1,1, true)
                end,
                backgroundAtlas = "transmog-set-iconrow-background"
            }, 40)
        else
            panel.tradeskills.cooking:SetDataBinding({
                atlas = "Mobile-Cooking",
                labelRight = "No Data",
                label = PROFESSIONS_COOKING,
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof1, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS_MISSING_DATA, 1,1,1, true)
                end,
                backgroundAtlas = "transmog-set-iconrow-background"
            }, 40)
        end
        if #character.data.firstAidRecipes > 0 then
            panel.tradeskills.firstAid:SetDataBinding({
                atlas = "Mobile-FirstAid",
                label = PROFESSIONS_FIRST_AID,
                labelRight =  date("%Y-%m-%d %H:%M:%S", Database:GetCharacterSyncData("firstAidRecipes")),
                onMouseDown = function(f, button)
                    if button == "RightButton" then
                        local menu = {
                            {
                                text = PROFESSIONS_FIRST_AID,
                                isTitle = true,
                                notCheckable = true,
                            }
                        }
                        table.insert(menu, addon.contextMenuSeparator)
                        table.insert(menu, {
                            text = "Send data",
                            notCheckable = true,
                            func = function()
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskill", "firstAid")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillRecipes", "firstAidRecipes")
                                addon:TriggerEvent("Character_BroadcastChange", character, "SetTradeskillLevel", "firstAidLevel")
                            end,
                        })

                        EasyMenu(menu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
                    end
                end,
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof2, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS:format(PROFESSIONS_FIRST_AID, #character.data.firstAidRecipes or 0), 1,1,1, true)
                end,
                backgroundAtlas = "transmog-set-iconrow-background"
            }, 40)
        else
            panel.tradeskills.firstAid:SetDataBinding({
                atlas = "Mobile-FirstAid",
                label = PROFESSIONS_FIRST_AID,
                labelRight = "No Data",
                onMouseEnter = function()
                    GameTooltip:SetOwner(panel.tradeskills.prof1, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L.SETTINGS_CHARACTER_TRADESKILLS_MISSING_DATA, 1,1,1, true)
                end,
                backgroundAtlas = "transmog-set-iconrow-background"
            }, 40)
        end

        panel.tradeskills.fishing:SetDataBinding({
            atlas = "Mobile-Fishing",
            label = PROFESSIONS_FISHING,
            onMouseDown = function(f, button)
    
            end,
            backgroundAtlas = "transmog-set-iconrow-background"
        }, 40)

    end
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


    local function myChatFilter(_, event, msg, author, ...)
        if addon.thisCharacter and (addon.thisCharacter ~= author) and addon.characters and addon.characters[author] then
            local mainCharacter = addon.characters[author]:GetMainCharacter()
            if mainCharacter then

                if addon.characters[mainCharacter] then

                    local _, class = GetClassInfo(addon.characters[mainCharacter].data.class)
                    if class then
                        local specAtlas = ""
                        if Database:GetConfig("showMainCharacterSpecInChat") then
                            if addon.characters[mainCharacter].data.mainSpec ~= false then
                                specAtlas = CreateAtlasMarkup(addon.characters[mainCharacter]:GetClassSpecAtlasName("primary"))
                            end
                        end
                        return false, string.format("[%s%s] %s", specAtlas, RAID_CLASS_COLORS[class]:WrapTextInColorCode(Ambiguate(mainCharacter, "short")), msg), author, ...
                    else
                        return false, string.format("[%s] %s", Ambiguate(mainCharacter, "short"), msg), author, ...
                    end
                end
            end
        else
            return false, msg, author, ...
        end
    end

    --could probably just accept the boolean val from the db here but this is maybe more readable
    local showMain = Database:GetConfig("showMainCharacterInChat")
    if showMain then
        self.content.chat.showMainCharacterInChat:SetChecked(true)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", myChatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", myChatFilter)
    else
        self.content.chat.showMainCharacterInChat:SetChecked(false)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_GUILD", myChatFilter)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", myChatFilter)
    end

    self.content.chat.showMainCharacterInChat.label:SetText(L.SETTINGS_CHAT_SHOW_MAIN)
    self.content.chat.showMainCharacterInChat:SetScript("OnClick", function(cb)
        
        local showMain = cb:GetChecked()
        if showMain then
            self.content.chat.showMainCharacterInChat:SetChecked(true)
            Database:SetConfig("showMainCharacterInChat", true)
            ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", myChatFilter)
        else
            self.content.chat.showMainCharacterInChat:SetChecked(false)
            Database:SetConfig("showMainCharacterInChat", false)
            ChatFrame_RemoveMessageEventFilter("CHAT_MSG_GUILD", myChatFilter)
        end
    end)


    self.content.chat.showMainCharacterSpecInChat.label:SetText(L.SETTINGS_CHAT_SHOW_MAIN_SPEC)
    self.content.chat.showMainCharacterSpecInChat:SetChecked(Database:GetConfig("showMainCharacterSpecInChat"))
    self.content.chat.showMainCharacterSpecInChat:SetScript("OnClick", function(cb)
        
        local showMainSpec = cb:GetChecked()
        if showMainSpec then
            self.content.chat.showMainCharacterSpecInChat:SetChecked(true)
            Database:SetConfig("showMainCharacterSpecInChat", true)
        else
            self.content.chat.showMainCharacterSpecInChat:SetChecked(false)
            Database:SetConfig("showMainCharacterSpecInChat", false)
        end
    end)


    --=========================================
    --addon panel
    --=========================================
    self.content.addon.debug:SetChecked(Database.db.debug)
    
    self.content.addon.enhancedPaperDoll:SetChecked(Database:GetConfig("enhancedPaperDoll"))

    --=========================================
    --guild panel
    --=========================================
    self.content.guild.modBlizzRoster.label:SetText(L.SETTINGS_GUILD_MOD_BLIZZ_ROSTER)
    self.content.guild.modBlizzRoster:SetScript("OnClick", function(cb)
        Database.db.config["modBlizzRoster"] = cb:GetChecked()

        if Database.db.config["modBlizzRoster"] == false then
            ReloadUI()

        else
            addon:ModBlizzUI()
        end
    end)

    self.content.guild.modBlizzRoster:SetChecked(Database.db.config["modBlizzRoster"])

    if Database.db.config["modBlizzRoster"] then
        addon:ModBlizzUI()
    end


    --[[
        guild tab container
    ]]
    self.content.guild.tabContainer:CreateTabButtons({
        {
            label = "Invites",
            width = 100,
            panel = self.content.guild.tabContainer.invites,
        },
        {
            label = "CSV Input",
            width = 100,
            panel = self.content.guild.tabContainer.csvInput,
        },
    })

    self.content.guild.tabContainer.csvInput.pasteBin.EditBox:SetMaxLetters(100000000)
    self.content.guild.tabContainer.csvInput.pasteBin.CharCount:SetShown(true);
    self.content.guild.tabContainer.csvInput.pasteBin.EditBox:ClearAllPoints()
    self.content.guild.tabContainer.csvInput.pasteBin.EditBox:SetPoint("TOPLEFT", self.content.guild.tabContainer.csvInput.pasteBin, "TOPLEFT", 0, 0)
    self.content.guild.tabContainer.csvInput.pasteBin.EditBox:SetPoint("BOTTOMRIGHT", self.content.guild.tabContainer.csvInput.pasteBin, "BOTTOMRIGHT", 0, 0)
    self.content.guild.tabContainer.csvInput.pasteBin.ScrollBar:ClearAllPoints()
    self.content.guild.tabContainer.csvInput.pasteBin.ScrollBar:SetPoint("TOPRIGHT", self.content.guild.tabContainer.csvInput.pasteBin, "TOPRIGHT", 4, 0)
    self.content.guild.tabContainer.csvInput.pasteBin.ScrollBar:SetPoint("BOTTOMRIGHT", self.content.guild.tabContainer.csvInput.pasteBin, "BOTTOMRIGHT", 0, -4)

    local slider = self.content.guild.tabContainer.csvInput.csvColumnCount;

    slider.label:SetText("Column count")
    slider.value:SetText(1)
    slider:SetMinMaxValues(1, 5)
    slider:SetValue(1)

    -- _G[slider:GetName().."Low"]:SetText(" ")
    -- _G[slider:GetName().."High"]:SetText(" ")
    -- _G[slider:GetName().."Text"]:SetText(" ")

    --GuildbookClassicEraWidgetsDropDownTemplate

    local function csvSplit(inputstr, sep)
        if sep == nil then
            return
        end
        local t = {}

        inputstr = string.gsub(inputstr, "\n", sep)

        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
        return t
    end

    local function preparePreview()
        local columns = math.ceil(slider:GetValue())
        local csv = csvSplit(self.content.guild.tabContainer.csvInput.pasteBin.EditBox:GetText(), ",")

        local ret = ""
        for i = 1, (8 * columns), columns do
            for j = i, (i + columns - 1) do
                if csv[j] then
                    ret = string.format("%s%s,", ret, csv[j])
                end
            end
            ret = string.format("%s\n", ret)
        end

        self.content.guild.tabContainer.csvInput.preview:SetText(ret)
    end

    self.content.guild.tabContainer.csvInput.pasteBin.EditBox:SetScript("OnTextChanged", preparePreview)

    slider:SetScript("OnMouseWheel", function(s, delta)
        s:SetValue(s:GetValue() + delta)
    end)

    slider:SetScript("OnValueChanged", function(s)
        local val = math.ceil(s:GetValue())
        s.value:SetText(val)
         
        preparePreview()
    end)

    local colKeys = {
        "Name",
        "Class",
        "Race",
        "Spec",
        "Level",
        "IGNORE"
    }

    self.content.guild.tabContainer.csvInput.columnDataContainer.colKeys = {
        name = 1,
        class = false,
        race = false,
        spec = false,
        level = false,
    }
    for i = 1, 5 do
        local x = (i - 1) * 55
        local y = -12
        local b = CreateFrame("Button", nil, self.content.guild.tabContainer.csvInput.columnDataContainer, "TBDDropDownTemplate")
        b:SetSize(55, 22)
        b:SetPoint("TOPLEFT", x + 2, y)

        local menu = {}
        for k, v in ipairs(colKeys) do
            if v == "IGNORE" then
                table.insert(menu, {
                    text = v,
                    func = function()
                        for k, v in pairs(self.content.guild.tabContainer.csvInput.columnDataContainer.colKeys) do
                            if v == i then
                                self.content.guild.tabContainer.csvInput.columnDataContainer.colKeys[k] = false
                                --print(string.format("set %s as false", k))
                            end
                        end
                    end,
                })
            else
                table.insert(menu, {
                    text = v,
                    func = function()
                        self.content.guild.tabContainer.csvInput.columnDataContainer.colKeys[v:lower()] = i;
                    end,
                })
            end
        end
        

        b:SetMenu(menu)

        local fs = self.content.guild.tabContainer.csvInput.columnDataContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", x, 0)
        fs:SetSize(55, 12)
        fs:SetText(i)
    end

    local classDataLookup = {}
    for i = 1, 12 do
        local lClass, gClass, id = GetClassInfo(i)
        if lClass then
            classDataLookup[lClass:lower()]  = i
            classDataLookup[gClass:lower()]  = i
        end
    end

    self.content.guild.tabContainer.csvInput.import:SetScript("OnClick", function()
        
        local data = {}

        local columns = math.ceil(slider:GetValue())
        local csv = csvSplit(self.content.guild.tabContainer.csvInput.pasteBin.EditBox:GetText(), ",")

        local colKeys = {}
        for k, v in pairs(self.content.guild.tabContainer.csvInput.columnDataContainer.colKeys) do
            if type(v) == "number" then
                colKeys[v] = k
            end
        end

        for i = 1, #csv, columns do
            local entry = {}
            local k = 1;
            for j = i, (i + columns - 1) do
                if csv[j] and (csv[j] ~= " ") then
                    if colKeys[k] then

                        if colKeys[k] == "class" then
                            
                            if classDataLookup[csv[j]:lower()] then
                                entry[colKeys[k]] = classDataLookup[csv[j]:lower()]
                            end
                        else
                            entry[colKeys[k]] = csv[j];
                        end

                    end
                end
                k = k + 1;
            end

            entry.notes = {
                {
                    user = addon.thisCharacter,
                    note = "Imported",
                    timestamp = time(),
                },
            }
            entry.status = 0

            table.insert(data, entry)
        end

        --DevTools_Dump(data)


        --Database:InsertRecruitmentCSV(data)

    end)

    local classFilterID;
    local statusFilter;

    local function filterClass()
        return function(character)
            if not classFilterID then
                return true
            end
            if character.class then
                local class, classString, classID = GetClassInfo(classFilterID)
                if character.class == classID then
                    return true
                end
            end
            return false;
        end
    end
    local function filterStatus()
        return function(character)
            if not statusFilter then
                return true
            end
            if character.status then
                if character.status == statusFilter then
                    return true
                end
            end
            return false;
        end
    end

    local function updateRecruitmentList()
        local entries = Database:GetAllRecruitment() or {}
        local t = {}

        local filters = {
            filterClass(),
            filterStatus(),
        }


        for k, v in ipairs(entries) do
            local match = true
            for k, filter in ipairs(filters) do
                if not filter(v) then
                    match = false
                end
            end
            if match then
                table.insert(t, {
                    character = v,
                    backgroundRGB = (k % 2 == 0) and {r=1, g=1, b=1} or {r=0, b=0, g=0},
                    backgroundAlpha = 0.08,
                })
            end
        end
        self.content.guild.tabContainer.invites.listview.scrollView:SetDataProvider(CreateDataProvider(t))
    end

    local classSelectMenu = {}
    table.insert(classSelectMenu, {
        text = "All",
        func = function()
            classFilterID = false;
            updateRecruitmentList()
        end,
    })
    for i = 1, 12 do
        local class, classString, classID = GetClassInfo(i)
        if class then
            table.insert(classSelectMenu, {
                text = class,
                func = function()

                    classFilterID = classID;
                    updateRecruitmentList()
                end,
            })
        end
    end
    self.content.guild.tabContainer.invites.classSelectDropdown:SetMenu(classSelectMenu)

    local statusSelectMenu = {}
    table.insert(statusSelectMenu, {
        text = "None",
        func = function()
            statusFilter = false;
            updateRecruitmentList()
        end,
    })
    for i = 0, #addon.recruitment.statusIDs do
        table.insert(statusSelectMenu, {
            text = addon.recruitment.statusIDs[i],
            func = function()
                statusFilter = i;
                updateRecruitmentList()
            end,
        })
    end
    self.content.guild.tabContainer.invites.statusSelectDropdown:SetMenu(statusSelectMenu)

    self.content.guild.tabContainer.invites.deleteAll:SetScript("OnClick", function()
        --Database:DeleteAllRecruit()
        updateRecruitmentList()
    end)

    self.content.guild.tabContainer.invites:SetScript("OnShow", function()
        updateRecruitmentList()
    end)




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

        local itemName, link = tt:GetItem()
        --print(link)
        if link then
            local itemID = GetItemInfoInstant(link)
            if itemID then

                --print(itemID)

                if addon.itemIDtoSource and addon.itemIDtoSource[itemID] then
                    tt:AddLine(" ")
                    GameTooltip_AddColoredLine(tt, addonName, BLUE_FONT_COLOR)
                    tt:AddDoubleLine(addon.itemIDtoSource[itemID].instance, addon.itemIDtoSource[itemID].encounter)
                end


                if Database.db.config.tradeskillsShowAllRecipeInfoTooltip == true then
                    local itemInfo = Tradeskills:GetItemRecipeInfo(itemID, itemName)
                    if type(itemInfo) == "table" and itemInfo.tradeskillID and itemInfo.reagents then
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
                    end
                else
                    if Database.db.config.tradeskillsShowMyRecipeInfoTooltip == true then
                        local itemInfo = Tradeskills:GetItemRecipeInfo(itemID, itemName)
                        if type(itemInfo) == "table" and itemInfo.tradeskillID and itemInfo.reagents then
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
                end

                if Database.db.config.tradeskillsShowAllRecipesUsingTooltip == true then
                    --local recipesUsingItem = addon.api.getTradeskillItemsUsingReagentItemID(itemID)
                    --print("Looking for recipes for itemID", itemID)
                    local recipesUsingItem = Tradeskills.GetAllRecipesThatUseItem(itemID)
                    --DevTools_Dump(recipesUsingItem)
                    if next(recipesUsingItem) ~= nil then
                        tt:AddLine(" ")
                        tt:AddLine(L.SETTINGS_TRADESKILLS_TT_REAGENT_FOR_HEADER)
                        for tradeskillID, recipes in pairs(recipesUsingItem) do
                            if Tradeskills:IsTradeskill(nil, tradeskillID) then
                                tt:AddLine(" ")
                                tt:AddLine(string.format("%s %s", CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(tradeskillID), 20, 20), Tradeskills:GetLocaleNameFromID(tradeskillID)))
                                for k, spellID in ipairs(recipes) do
                                    local spellName = GetSpellInfo(spellID)
                                    GameTooltip_AddColoredLine(tt, spellName, BLUE_FONT_COLOR)
                                end
                            end
                        end
                    end
                else
                    if Database.db.config.tradeskillsShowMyRecipesUsingTooltip == true and addon.characters[addon.thisCharacter] then
                        local recipesUsingItem = Tradeskills.GetAllRecipesThatUseItem(itemID, addon.characters[addon.thisCharacter].data.profession1, addon.characters[addon.thisCharacter].data.profession2)
                        if next(recipesUsingItem) ~= nil then
                            tt:AddLine(" ")
                            tt:AddLine(L.SETTINGS_TRADESKILLS_TT_REAGENT_FOR_HEADER)
                            for tradeskillID, recipes in pairs(recipesUsingItem) do
                                if Tradeskills:IsTradeskill(nil, tradeskillID) then
                                    tt:AddLine(" ")
                                    tt:AddLine(string.format("%s %s", CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(tradeskillID), 20, 20), Tradeskills:GetLocaleNameFromID(tradeskillID)))
                                    for k, spellID in ipairs(recipes) do
                                        local spellName = GetSpellInfo(spellID)
                                        GameTooltip_AddColoredLine(tt, spellName, BLUE_FONT_COLOR)
                                    end
                                end
                            end
                        end                        
                    end
                end

            end
        end

    end)
end

function GuildbookSettingsMixin:CharacterPanel_OnShow()
    self:PrepareCharacterPanel()
end

function GuildbookSettingsMixin:TradeskillPanel_OnShow()

    local x, y = self.content:GetSize()
    self.content.tradeskills.scrollFrame.scrollChild:SetSize(x-24, y)

end

function GuildbookSettingsMixin:GuildPanel_OnShow()

    local x, y = self.content:GetSize()
    self.content.guild:SetSize(x-24, y)

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

    self.content:SetAlpha(0)
    for k, v in ipairs(self.content.panels) do
        v:Hide()
    end
    if self.content[category] then
        self.content[category]:Show()
    end
    self.content.fadeIn:Play()
end


function GuildbookSettingsMixin:ChatPanel_OnShow()

end

function GuildbookSettingsMixin:Database_OnInitialised()
    self:PreparePanels()
end

function GuildbookSettingsMixin:Blizzard_OnInitialGuildRosterScan()
    self:PrepareCharacterPanel()
end

function GuildbookSettingsMixin:Character_OnDataChanged()
    self:PrepareCharacterPanel()
end