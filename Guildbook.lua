
-- grab the addon table
local _, gb = ...

local L = gb.Locales

local LCI = LibStub:GetLibrary("LibCraftInfo-1.0")
local LibGraph = LibStub("LibGraph-2.0");

local GUILD_NAME;

---set value to stagger comms when loading a character profile, if issues occur with comm spam increase this to ease load on comms channel
local transmitStagger = 0.5;


---the tradeskill import/export interface
GuildbookDataShareMixin = {}

---setup the import/export ui
function GuildbookDataShareMixin:OnLoad()
    self:RegisterForDrag("LeftButton")
    self:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, 
        tileSize = 32, 
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    self.close:SetSize(24, 22)
    self.close:SetNormalTexture(130832)
    self.close:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.85)
    self.close:SetHighlightTexture(130831)
    self.close:GetHighlightTexture(130831):SetTexCoord(0.1, 0.9, 0.1, 0.85)

    self.close:SetScript("OnClick", function()
        self:Hide()
    end)

    ---when a user clicks in the text area we highlight all the text so its easier to copy/paste out of the game
    self.dataString.EditBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    self.dataString.CharCount:ClearAllPoints()
    self.dataString.CharCount:SetPoint("TOPRIGHT", self.dataString, "BOTTOMRIGHT", 0, -25)

    self.header:SetText(L["GUILDBOOK_DATA_SHARE_HEADER"])

    self.import:SetText(L["IMPORT"])

    ---if there is a valid string then call the import script
    self.import:SetScript("OnClick", function()
        local data = self.dataString.EditBox:GetText()
        if not data then
            return
        end
        gb:ImportGuildTradeskillRecipes(data)
    end)

    self.export:SetText(L["EXPORT"])

    ---call the script to serialize all tradeskill data then set the textbox text for users to copy/paste
    self.export:SetScript("OnClick", function()
        local s = gb:SerializeGuildTradeskillRecipes()
        GuildbookDataShare.dataString.EditBox:SetText("")
        GuildbookDataShare.dataString.EditBox:SetText(s)
    end)
end

function GuildbookDataShareMixin:OnShow()
    self.dataString.EditBox:SetText("")
end


---this function is called from the roster listview when clicking a characters profession icon
---@param guid string the character guid
---@param prof string the profession name to use
local function loadGuildMemberTradeskills(guid, prof)
    --hide the selected texture and flush the listviews
    for _, button in ipairs(GuildbookTradeskillProfessionListview.profButtons) do
        button.selected:Hide()
    end
    GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Flush()
    GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:Flush()
    if next(gb.tradeskillRecipesKeys) == nil then
        GuildbookUI.statusText:SetText("tradeskill recipes not processed yet, key mapping not ready")
        return
    end
    if next(gb.tradeskillEnchantRecipesKeys) == nil then
        GuildbookUI.statusText:SetText("tradeskill enchant recipes not processed yet, key mapping not ready")
        return
    end
    local character = gb:GetCharacterFromCache(guid)
    if not character then
        return
    end
    GuildbookUI.tradeskills.awaitingCharacterRecipes = true;
    if prof == "Enginnering" then prof = "Engineering" end -- fix it back due to blizz spelling error
    gb:DB_RequestCharacterData(guid, prof, "WHISPER", character.Name, "NORMAL")
    -- local recipes = {}
    -- if prof ~= "allRecipes" and character[prof] then
    --     for itemID, _ in pairs(character[prof]) do
    --         if prof == "Enchanting" then
    --             local key = gb.tradeskillEnchantRecipesKeys[itemID]
    --             table.insert(recipes, gb.tradeskillRecipes[key])
    --         else
    --             local key = gb.tradeskillRecipesKeys[itemID]
    --             table.insert(recipes, gb.tradeskillRecipes[key])
    --         end
    --     end

    -- ---if no prof is given then load all the characters recipes
    -- elseif prof == "allRecipes" then
    --     local prof1 = character.Profession1
    --     if prof1 and character[prof1] then
    --         for itemID, _ in pairs(character[prof1]) do
    --             if prof1 == "Enchanting" then
    --                 local key = gb.tradeskillEnchantRecipesKeys[itemID]
    --                 table.insert(recipes, gb.tradeskillRecipes[key])
    --             else
    --                 local key = gb.tradeskillRecipesKeys[itemID]
    --                 table.insert(recipes, gb.tradeskillRecipes[key])
    --             end
    --         end
    --     end
    --     local prof2 = character.Profession2
    --     if prof2 and character[prof2] then
    --         for itemID, _ in pairs(character[prof2]) do
    --             if prof2 == "Enchanting" then
    --                 local key = gb.tradeskillEnchantRecipesKeys[itemID]
    --                 table.insert(recipes, gb.tradeskillRecipes[key])
    --             else
    --                 local key = gb.tradeskillRecipesKeys[itemID]
    --                 table.insert(recipes, gb.tradeskillRecipes[key])
    --             end
    --         end
    --     end
    -- end
    -- if recipes and next(recipes) ~= nil then
    --     GuildbookUI.statusText:SetText(string.format("found %s recipes for %s [%s]", #recipes, prof, character.Name))
    --     table.sort(recipes, function(a,b)
    --         if a.expansion == b.expansion then
    --             if a.rarity == b.rarity then
    --                 return a.name < b.name
    --             else
    --                 return a.rarity > b.rarity
    --             end
    --         else
    --             return a.expansion > b.expansion
    --         end
    --     end)
    --     GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(recipes)
    -- end
    -- GuildbookUI:OpenTo("tradeskills")
end


---returns a list of player GUIDs that have a match for the given prof
---@param prof string the profession to search for
---@return table 
local function getAllPlayersWithTradeskill(prof)
    local characters = {}
    if GUILD_NAME then
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME] then
            for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME]) do
                if character.Profession1 and (character.Profession1:lower() == prof:lower()) then
                    table.insert(characters, guid)
                elseif character.Profession2 and (character.Profession2:lower() == prof:lower()) then
                    table.insert(characters, guid)
                end
            end
            return characters
        end
    end
    return false;
end


---load characters into the characters with recipe listview sorted by online status
---@param recipe table the recipe table or at least a table with a .itemID field
local function loadCharactersWithRecipe(recipe)
    GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:Flush()
    local charactersWithRecipe = {}
    local sorting = {}
    if recipe.enchant == true then
        for k, guid in ipairs(gb.charactersWithEnchantRecipe[recipe.itemID]) do
            table.insert(sorting, {
                guid = guid,
                online = gb.onlineZoneInfo[guid].online and 1 or 0,
            })
        end
    else
        for k, guid in ipairs(gb.charactersWithRecipe[recipe.itemID]) do
            table.insert(sorting, {
                guid = guid,
                online = gb.onlineZoneInfo[guid].online and 1 or 0,
            })
        end
    end
    table.sort(sorting, function(a,b)
        return a.online > b.online
    end)
    for k, character in ipairs(sorting) do
        table.insert(charactersWithRecipe, character.guid)
    end
    GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:InsertTable(charactersWithRecipe)
end






















--[[

    this is the character listview for the tradeskill ui

    its purpose is to show which characters have a certain tradeskill
    it can then be filtered by tradeskill recipes by clicking the recipe

    selecting a character will show that characters recipes for the currently selected tradeskill

]]--
GuildbookTradeskillCharacterListviewItemMixin = {}

---add the circluar mask to the portrait, this was doen in lua however can be moved into the xml template
function GuildbookTradeskillCharacterListviewItemMixin:OnLoad()
    self.mask = self:CreateMaskTexture()
    self.mask:SetSize(31,31)
    self.mask:SetPoint("LEFT", 10, 0)
    self.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    self.Icon:AddMaskTexture(self.mask)
end

function GuildbookTradeskillCharacterListviewItemMixin:OnMouseDown()
    self:AdjustPointsOffset(-1,-1)
end

---call the items .func in the OnMouseUp event
function GuildbookTradeskillCharacterListviewItemMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
    if self.func then
        C_Timer.After(0, self.func)
    end
end

---sets the character info, this displays character avatar, name and location - formats grey for offline characters
---@param guid string the characters guid
function GuildbookTradeskillCharacterListviewItemMixin:SetCharacter(guid)
    -- this will become the new system using a guid
    if guid:find("Player") then
        local character = gb:GetCharacterFromCache(guid)
        if not character then
            return;
        end
        local race;
        if character.Race:lower() == "scourge" then
            race = "undead";
        else
            race = character.Race:lower()
        end
        self.Icon:SetAtlas(string.format("raceicon-%s-%s", race, character.Gender:lower()))
        self.Name:SetText(character.Name)
        if gb.onlineZoneInfo[guid].online == true then
            self.Name:SetTextColor(1,1,1,1)
            self.Zone:SetTextColor(1,1,1,1)
            self.Zone:SetText("["..gb.onlineZoneInfo[guid].zone.."]")
        else
            self.Name:SetTextColor(0.5,0.5,0.5,0.7)
            self.Zone:SetText("[offline]")
            self.Zone:SetTextColor(0.5,0.5,0.5,0.7)
        end
        self.func = function()
            loadGuildMemberTradeskills(guid, GuildbookMixin.selectedProfession and GuildbookMixin.selectedProfession or "allRecipes")
        end
    end
end















--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- chats character listview
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookCharacterListviewItemMixin = {}

function GuildbookCharacterListviewItemMixin:OnLoad()
    self.mask = self:CreateMaskTexture()
    self.mask:SetSize(31,31)
    self.mask:SetPoint("LEFT", 10, 0)
    self.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    self.Icon:AddMaskTexture(self.mask)
end

function GuildbookCharacterListviewItemMixin:OnMouseDown()
    self:AdjustPointsOffset(-1,-1)
end

function GuildbookCharacterListviewItemMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
    if self.func then
        C_Timer.After(0, self.func)
    end
end

function GuildbookCharacterListviewItemMixin:SetCharacter(guid)

    -- this will become the new system using a guid
    if guid:find("Player") then
        local character = gb:GetCharacterFromCache(guid)
        if not character then
            return;
        end
        local race;
        if character.Race:lower() == "scourge" then
            race = "undead";
        else
            race = character.Race:lower()
        end
        self.Icon:SetAtlas(string.format("raceicon-%s-%s", race, character.Gender:lower()))
        self.Name:SetText(character.Name)

    -- this is kept for some compatability
    else
        local race;
        if guid.race:lower() == "scourge" then
            race = "undead";
        else
            race = guid.race:lower()
        end
        self.Icon:SetAtlas(string.format("raceicon-%s-%s", race, guid.gender:lower()))
        self.Name:SetText(guid.name)
        if guid.online == true then
            self.Name:SetTextColor(1,1,1,1)
            self.Zone:SetTextColor(1,1,1,1)
            self.Zone:SetText("["..guid.zone.."]")
            self.sendMessage:Show()
        else
            self.Name:SetTextColor(0.5,0.5,0.5,0.7)
            self.sendMessage:Hide()
            self.Zone:SetText("[offline]")
            self.Zone:SetTextColor(0.5,0.5,0.5,0.7)
        end
        self.itemLink = guid.link;
        self.guid = guid;
    end
end






































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- tradeskill recipe listview
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookRecipeListviewItemMixin = {}

-- item has the following fields
-- itemID
-- reagents
-- rarity
-- link
-- icon
-- enchant
-- expansion
-- name
-- profession
-- equipLocation
function GuildbookRecipeListviewItemMixin:Init(item)
    self.item = item;
    for _, reagent in pairs(self.reagentIcons) do
        reagent:SetFrameStrata("TOOLTIP")
        reagent.icon:SetTexture(nil)
        reagent.greenBorder:Hide()
        reagent.orangeBorder:Hide()
        reagent.purpleBorder:Hide()
        reagent.count:SetText("")
        reagent.link = nil
    end
    local reagentNum = 1
    for reagentID, count in pairs(item.reagents) do
        if self.reagentIcons[reagentNum] then
            if GuildbookUI.playerContainerItems[reagentID] then
                if GuildbookUI.playerContainerItems[reagentID] >= count then
                    self.reagentIcons[reagentNum].greenBorder:Show()
                elseif GuildbookUI.playerContainerItems[reagentID] < count then
                    self.reagentIcons[reagentNum].purpleBorder:Show()
                end
            else
                self.reagentIcons[reagentNum].orangeBorder:Show()
            end
            self.reagentIcons[reagentNum]:SetItem(reagentID)
            self.reagentIcons[reagentNum].count:SetText(count)
            reagentNum = reagentNum + 1;
        end
    end
    self.Text:SetText(item.link)
end

function GuildbookRecipeListviewItemMixin:OnLoad()

end

function GuildbookRecipeListviewItemMixin:OnEnter()
    if self.item.link then
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        if self.item.enchant then
            GameTooltip:SetSpellByID(self.item.itemID)
        else
            GameTooltip:SetHyperlink(self.item.link)
        end
        -- GameTooltip:AddLine(" ")
        -- GameTooltip:AddLine(gb.Colours.Blue:WrapTextInColorCode(L["REMOVE_RECIPE_FROM_PROF"]))

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(gb.Colours.BlizzBlue:WrapTextInColorCode(L["TRADESKILLS_REAGENTS"]))
        if self.item.reagents then
            for reagentID, count in pairs(self.item.reagents) do
                local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(reagentID)
                if not name then
                    local item = Item:CreateFromItemID(reagentID)
                    item:ContinueOnItemLoad(function()
                        local name = item:GetItemName()
                        GameTooltip:AddDoubleLine(name, count, 1,1,1, 1,1,1)
                    end)
                else
                    GameTooltip:AddDoubleLine(name, count, 1,1,1, 1,1,1)
                end
            end
        end

        -- this adds the item table to the tooltip for debugging reasons
        if GUILDBOOK_GLOBAL.Debug then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Guildbook debug:")
            for k, v in pairs(self.item) do
                if k ~= "reagents" and k ~= "charactersWithRecipe" then
                    GameTooltip:AddDoubleLine(k,v)
                elseif k == "enchant" then
                    GameTooltip:AddDoubleLine(k, v == true and "true" or "false")
                end
            end
        end

        GameTooltip:Show()
        -- fade the character listview to make the tooltip easier to view/read
        GuildbookUI.tradeskills.tradeskillItemsCharacterListview:SetAlpha(0.3)
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end
end

function GuildbookRecipeListviewItemMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    GuildbookUI.tradeskills.tradeskillItemsCharacterListview:SetAlpha(1)
end

function GuildbookRecipeListviewItemMixin:OnMouseDown(button)

    --local index = self:GetOrderIndex();

    -- this is an option for users to remove an item from a tradeskill if its somehow been mixed up
    -- its not the best option to use however
    -- if button == "RightButton" then
    --     local characters = getAllPlayersWithTradeskill(self.item.profession)
    --     StaticPopup_Show('GuildbookDeleteRecipeFromCharacters', string.format(L["REMOVE_RECIPE_FROM_PROF_SS"], self.item.link, self.item.profession), nil, {
    --         itemLink = self.item.link,
    --         characters = characters,
    --         prof = self.item.profession,
    --         listviewIndex = index,
    --         listview = GuildbookUI.tradeskills.tradeskillItemsListview,
    --     })
    --     return;
    -- end

    -- enable the ctrl click to view item
    if IsControlKeyDown() then
        DressUpItemLink(self.item.link)

    -- enable the shift click to link item
    elseif IsShiftKeyDown() then
        HandleModifiedItemClick(self.item.link)

    -- load the characters who can craft the item
    else
        loadCharactersWithRecipe(self.item)
    end

end

function GuildbookRecipeListviewItemMixin:OnMouseUp()

end


































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- roster
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookRosterListviewItemMixin = {}
GuildbookRosterListviewItemMixin.tooltipIcon = CreateFrame("FRAME", "GuildbookRosterListviewItemTooltipIcon")
GuildbookRosterListviewItemMixin.tooltipIcon:SetSize(24, 24)
GuildbookRosterListviewItemMixin.tooltipIcon.icon = GuildbookRosterListviewItemMixin.tooltipIcon:CreateTexture(nil, "BACKGROUND")
GuildbookRosterListviewItemMixin.tooltipIcon.icon:SetPoint("CENTER", 0, 0)
GuildbookRosterListviewItemMixin.tooltipIcon.icon:SetSize(56, 56)
GuildbookRosterListviewItemMixin.tooltipIcon.mask = GuildbookRosterListviewItemMixin.tooltipIcon:CreateMaskTexture()
GuildbookRosterListviewItemMixin.tooltipIcon.mask:SetSize(50,50)
GuildbookRosterListviewItemMixin.tooltipIcon.mask:SetPoint("CENTER", 0, 0)
GuildbookRosterListviewItemMixin.tooltipIcon.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
GuildbookRosterListviewItemMixin.tooltipIcon.icon:AddMaskTexture(GuildbookRosterListviewItemMixin.tooltipIcon.mask)


function GuildbookRosterListviewItemMixin:OnEnter()
    if not self.character then
        return;
    end
    local character = gb:GetCharacterFromCache(self.guid)
    if not character then
        return;
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    -- this was to change the tooltip background
    --self.tooltipBackground:SetAtlas(string.format("UI-Character-Info-%s-BG", character.Class:sub(1,1):upper()..character.Class:sub(2)))

    local rPerc, gPerc, bPerc, argbHex = GetClassColor(character.Class:upper())
    GameTooltip_SetTitle(GameTooltip, character.Name.."\n\n|cffffffff"..L['level'].." "..character.Level, CreateColor(rPerc, gPerc, bPerc), nil)
    if self.tooltipIcon then
        if character.profile and character.profile.avatar then
            self.tooltipIcon.icon:SetTexture(character.profile.avatar)
        elseif character.Race and character.Gender then
            local race;
            if character.Race:lower() == "scourge" then
                race = "undead";
            else
                race = character.Race:lower()
            end
            self.tooltipIcon.icon:SetAtlas(string.format("raceicon-%s-%s", race, character.Gender:lower()))
        end
        GameTooltip_InsertFrame(GameTooltip, self.tooltipIcon)
        for k, frame in pairs(GameTooltip.insertedFrames) do
            if frame:GetName() == "GuildbookRosterListviewItemTooltipIcon" then
                frame:ClearAllPoints()
                frame:SetPoint("TOPRIGHT", -20, -20)
            end
        end
    end

    local colour = CreateColor(0.1, 0.58, 0.92, 1)
    local function formatTradeskill(prof, spec)
        if spec then
            return string.format("%s [%s]", prof, gb.Colours.Blue:WrapTextInColorCode((GetSpellInfo(spec))));
        elseif prof then
            return prof;
        else
            return "-";
        end
    end

    GameTooltip:AddLine(L["TRADESKILLS"])
    GameTooltip:AddDoubleLine(formatTradeskill(character.Profession1, character.Profession1Spec), character.Profession1Level or 0, 1,1,1,1, 1,1,1,1)
    -- GameTooltip_ShowStatusBar(GameTooltip, 0, 300, 245)
    -- GameTooltip_ShowProgressBar(GameTooltip, 0, 300, 245)
    GameTooltip:AddDoubleLine(formatTradeskill(character.Profession2, character.Profession2Spec), character.Profession2Level or 0, 1,1,1,1, 1,1,1,1)
    if character.PublicNote then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L['publicNote'], "|cffffffff"..character.PublicNote)
    end

    if character.MainCharacter and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][character.MainCharacter] then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L['MAIN_CHARACTER'])
        local s = string.format("%s %s %s",
        gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][character.MainCharacter].Class].FontStringIconMEDIUM,
        gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][character.MainCharacter].Class].FontColour,
        GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][character.MainCharacter].Name
        )
        GameTooltip:AddLine(s)
    end
    if character.Alts then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L['ALTS'])
        for _, guid in pairs(character.Alts) do
            if guid ~= character.MainCharacter then
                local s = string.format("%s %s %s",
                gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Class].FontStringIconMEDIUM,
                gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Class].FontColour,
                GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Name
                )
                GameTooltip:AddLine(s)
            end
            --GameTooltip:AddTexture(gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Class].Icon)
        end
    end
    --GameTooltip:AddLine(" ")

    -- i contacted the author of attune to check it was ok to add their addon data 
    if Attune_DB and Attune_DB.toons[character.Name.."-"..GetRealmName()] then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["attunements"])

        local db = Attune_DB.toons[character.Name.."-"..GetRealmName()]

        for _, instance in ipairs(Attune_Data.attunes) do
            if db.attuned[instance.ID] and (instance.FACTION == "Both" or instance.FACTION == character.Faction) then
                local formatPercent = db.attuned[instance.ID] < 100 and "|cffff0000"..db.attuned[instance.ID].."%" or "|cff00ff00"..db.attuned[instance.ID].."%"
                GameTooltip:AddDoubleLine("|cffffffff"..instance.NAME, formatPercent)
            end
        end
    end

    GameTooltip:Show()
end


function GuildbookRosterListviewItemMixin:OnLeave()
    if GameTooltip.insertedFrames and next(GameTooltip.insertedFrames) ~= nil then
        for k, frame in pairs(GameTooltip.insertedFrames) do
            if frame:GetName() == "GuildbookRosterListviewItemTooltipIcon" then
                frame:Hide()
            end
        end
    end
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookRosterListviewItemMixin:OnLoad()

end

function GuildbookRosterListviewItemMixin:SetOffline(online)
    if online then
        self.Name:SetTextColor(1,1,1,1)
        self.Level:SetTextColor(1,1,1,1)
        self.MainSpec:SetTextColor(1,1,1,1)
        self.Location:SetTextColor(1,1,1,1)
        self.PublicNote:SetTextColor(1,1,1,1)
        self.Rank:SetTextColor(1,1,1,1)
    else
        self.Name:SetTextColor(0.5,0.5,0.5,0.5)
        self.Level:SetTextColor(0.5,0.5,0.5,0.5)
        self.MainSpec:SetTextColor(0.5,0.5,0.5,0.5)
        self.Location:SetTextColor(0.5,0.5,0.5,0.5)
        self.PublicNote:SetTextColor(0.5,0.5,0.5,0.5)
        self.Rank:SetTextColor(0.5,0.5,0.5,0.5)
    end
end


-- this function needs to be cleaned up, its using a nasty set of variables
function GuildbookRosterListviewItemMixin:SetCharacter(member)
    self.guid = member.guid
    self.character = gb:GetCharacterFromCache(member.guid)

    self.ClassIcon:SetAtlas(string.format("GarrMission_ClassIcon-%s", self.character.Class))
    self.ClassIcon:Show()
    --self.Name:SetText(character.isOnline and self.character.Name or "|cffB1B3AB"..self.character.Name)
    self.Name:SetText(self.character.Name)
    self.Level:SetText(self.character.Level)
    local mainSpec = false;
    if self.character.MainSpec == "Bear" then
        mainSpec = "Guardian"
    elseif self.character.MainSpec == "Cat" then
        mainSpec = "Feral"
    elseif self.character.MainSpec == "Beast Master" or self.character.MainSpec == "BeastMaster" then
        mainSpec = "BeastMastery"
    elseif self.character.MainSpec == "Combat" then
        mainSpec = "Outlaw"
    end
    if self.character.MainSpec and self.character.MainSpec ~= "-" then
        --print(mainSpec, self.character.MainSpec, self.character.Name)
        local icon = gb:GetClassSpecAtlasName(self.character.Class, self.character.MainSpec)
        self.MainSpecIcon:SetAtlas(icon)
        self.MainSpecIcon:Show()
        self.MainSpec:SetText(L[self.character.MainSpec])
    else
        self.MainSpecIcon:Hide()
    end
    if self.character.Profession1 ~= "-" then
        local prof1 = self.character.Profession1
        if prof1 then
            if prof1 == "Engineering" then
                self.Prof1.icon:SetAtlas("Mobile-Enginnering")
            else
                self.Prof1.icon:SetAtlas(string.format("Mobile-%s", prof1))
            end
            if self.character.Profession1Spec then
                --local profSpec = GetSpellDescription(self.character.Profession1Spec)
                local profSpec = GetSpellInfo(self.character.Profession1Spec)
                self.Prof1.tooltipText = gb:GetLocaleProf(prof1).." |cffffffff"..profSpec.."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
            else
                self.Prof1.tooltipText = gb:GetLocaleProf(prof1).."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
            end
            self.Prof1.func = function()
                loadGuildMemberTradeskills(self.guid, prof1)
            end
            self.Prof1:Show()
        end
    else
        self.Prof1:Hide()
    end
    if self.character.Profession2 ~= "-" then
        local prof2 = self.character.Profession2
        if prof2 then
            if prof2 == "Engineering" then
                self.Prof2.icon:SetAtlas("Mobile-Enginnering")
            else
                self.Prof2.icon:SetAtlas(string.format("Mobile-%s", prof2))
            end
            if self.character.Profession2Spec then
                --local profSpec = GetSpellDescription(self.character.Profession2Spec)
                local profSpec = GetSpellInfo(self.character.Profession2Spec)
                self.Prof2.tooltipText = gb:GetLocaleProf(prof2).." |cffffffff"..profSpec.."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
            else
                self.Prof2.tooltipText = gb:GetLocaleProf(prof2).."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
            end
            self.Prof2.func = function()
                loadGuildMemberTradeskills(self.guid, prof2)
            end
            self.Prof2:Show()
        end
    else
        self.Prof2:Hide()
    end
    self.Location:SetText(member.location)
    self.Rank:SetText(member.rankName)
    self.PublicNote:SetText(member.publicNote)

    if self.character and self.character.profile and self.character.profile.avatar then
        self.openProfile.background:SetTexture(self.character.profile.avatar)
    elseif self.character.Race and self.character.Gender then
        self.openProfile.background:SetAtlas(string.format("raceicon-%s-%s", self.character.Race:lower(), self.character.Gender:lower()))
    else
        self.openProfile.background:SetAtlas("services-icon-warning")
    end

end

function GuildbookRosterListviewItemMixin:OnMouseDown(button)
    if button == "RightButton" and self.character then
    StaticPopup_Show("GuildbookResetCacheCharacter", self.character.Name, nil, {guid = self.guid})
    end
end

function GuildbookRosterListviewItemMixin:OnMouseUp()
    
end
























GuildbookAvatarMixin = {}

function GuildbookAvatarMixin:OnLoad()

end

function GuildbookAvatarMixin:OnMouseDown()
    if self.func then
        self.func()
    end
end




































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- main
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookMixin = {}
GuildbookMixin.selectedProfession = nil;
GuildbookMixin.charactersWithProfession = {}
GuildbookMixin.playerContainerItems = {}

local function navigateTo(frame)
    for _, f in pairs(GuildbookUI.frames) do
        f:Hide()
    end
    GuildbookUI.backgroundModel:Hide()
    frame:Show()
end

function GuildbookMixin:OpenTo(frame)
    navigateTo(self[frame])
    self:Show()
end

function GuildbookMixin:OnHide()

end

function GuildbookMixin:OnShow()
    GUILD_NAME = gb:GetGuildName()

    if GUILDBOOK_CHARACTER.profile and GUILDBOOK_CHARACTER.profile.avatar then
        self.ribbon.myProfile.background:SetTexture(GUILDBOOK_CHARACTER.profile.avatar) 
    else
        SetPortraitTexture(self.ribbon.myProfile.background, "player")
    end

end

function GuildbookMixin:OnLoad()
    self:RegisterForDrag("LeftButton")
    SetPortraitToTexture(GuildbookUIPortrait,134068)
    --GuildbookUITitleText:SetText("v0.0.1")

    GuildbookDataShare:SetParent(GuildbookUI.tradeskills)
    GuildbookDataShare:SetPoint("LEFT", GuildbookUI.tradeskills, "RIGHT", 20, 0)

    self.backgroundModel = CreateFrame('PlayerModel', "GuildbookBackgroundModel", self, BackdropTemplateMixin and "BackdropTemplate")
    self.backgroundModel:SetPoint('TOPLEFT', 0, -55)
    self.backgroundModel:SetPoint('BOTTOMRIGHT', 0, 0)
    self.backgroundModel:SetModel("creature/illidan/illidan.m2")
    self.backgroundModel:SetPosition(0,0,-0.2)
    self.backgroundModel:SetKeepModelOnHide(true)
    self.backgroundModel:Hide()
    for _, f in pairs(GuildbookUI.frames) do
        f:Hide()
    end
    tinsert(UISpecialFrames, self:GetName());


    self.ribbon:SetFrameLevel(self:GetFrameLevel() - 1)
    self.ribbon.profiles.func = function()
        self.profiles:ShowSummary(true)
        navigateTo(self.profiles)
    end
    self.ribbon.tradeskills.func = function()
        navigateTo(self.tradeskills)
    end
    self.ribbon.chat.func = function()
        navigateTo(self.chat)
    end
    self.ribbon.roster.func = function()
        navigateTo(self.roster)
    end
    self.ribbon.privacy.func = function()
        navigateTo(self.privacy)
    end
    self.ribbon.calendar.func = function()
        navigateTo(self.calendar)
        gb.GuildFrame.GuildCalendarFrame:ClearAllPoints()
        gb.GuildFrame.GuildCalendarFrame:SetParent(self.calendar)
        gb.GuildFrame.GuildCalendarFrame:SetPoint("TOPLEFT", 0, -26) --this has button above the frame so lower it a bit
        gb.GuildFrame.GuildCalendarFrame:SetPoint("BOTTOMRIGHT", -2, 0)
        gb.GuildFrame.GuildCalendarFrame:Show()

        gb.GuildFrame.GuildCalendarFrame.EventFrame:ClearAllPoints()
        gb.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('TOPLEFT', self.calendar, 'TOPRIGHT', 4, 50)
        gb.GuildFrame.GuildCalendarFrame.EventFrame:SetPoint('BOTTOMRIGHT', self.calendar, 'BOTTOMRIGHT', 254, 0)
    end
    self.ribbon.guildbank.func = function()
        navigateTo(self.guildbank)
    end
    self.ribbon.search.func = function()
        navigateTo(self.search)
    end
    self.ribbon.stats.func = function()
        navigateTo(self.stats)
    end
    self.ribbon.helpAbout.func = function()
        navigateTo(self.helpAbout)
    end

    self.profiles.contentPane.scrollChild:SetSize(650, 480)

    self.tradeskills.ribbon.exportTradeskills.func = function()
        GuildbookDataShare:Show()
    end

    --self.portraitButton

end


function GuildbookMixin:OnUpdate()
    if self.statusBar.active then
        local complete = 1 - ((self.statusBar.endTime - GetTime()) / self.statusBar.duration)
        self.statusBar:SetValue(complete)
        if complete > 1.0 then
            self.statusBar.active = false;
            self.statusBar:SetValue(0)
            self.statusText:SetText(" ")
        end
    end
end


function GuildbookMixin:SetupCacheCallback(cache)
    cache:RegisterCallback("OnCharacterTableChanged", self.OnCharacterTableChanged, self)
    --cache:RegisterCallback("OnPlayerCharacterTableChanged", self.OnCharacterTableChanged, self)
end

---use this to update the ui
function GuildbookMixin:OnCharacterTableChanged(_, characterTable)

    --DevTools_Dump({characterTable})


    ---thsi is just for testing as the ui code will need to be restructured due to the new callback update
    GuildbookUI.profiles.character = characterTable
    GuildbookUI.profiles:LoadTalents("primary")
    GuildbookUI.profiles:LoadInventory()

end


















GuildbookAvatarPickerMixin = {}

function GuildbookAvatarPickerMixin:OnLoad()
    -- 1066622 blank icon

    -- there are lots of duplicates in these textures
    -- TODO: remove duplicates at some point
    self.avatars = {}
    for i = 1066003, 1066533 do
        table.insert(self.avatars, {
            fileID = i
        })
    end
    for i = 1067178, 1067332 do
        table.insert(self.avatars, {
            fileID = i
        })
    end
    for i = 1067334, 1067476 do
        table.insert(self.avatars, {
            fileID = i
        })
    end
    for i = 1396616, 1396708 do
        table.insert(self.avatars, {
            fileID = i
        })
    end
    for i = 1401832, 1401894 do
        table.insert(self.avatars, {
            fileID = i
        })
    end
    for i = 1416162, 1416410 do
        table.insert(self.avatars, {
            fileID = i
        })
    end
    for i = 1416417, 1416429 do
        table.insert(self.avatars, {
            fileID = i
        })
    end

    self.gridview = {}
    local i = 1;
    for col = 0, 2 do
        for row = 0, 5 do
            local f = CreateFrame("FRAME", nil, self, "GuildbookAvatarFrame")
            f:SetPoint("TOPLEFT", (col * 85) + 5, ((row * 80) * -1) - 25)
            f:SetSize(70,70)
            f:EnableMouse(true)
            f.Background:SetTexture(self.avatars[i].fileID)
            f.avatar = self.avatars[i]

            f.func = function()
                if not GUILDBOOK_CHARACTER then
                    GUILDBOOK_CHARACTER = {}
                end
                if not GUILDBOOK_CHARACTER.profile then
                    GUILDBOOK_CHARACTER.profile = {}
                end
                GUILDBOOK_CHARACTER.profile.avatar = f.avatar.fileID
                GuildbookUI.profiles.contentPane.scrollChild.profile.avatar.avatar:SetTexture(f.avatar.fileID)
                GuildbookUI.ribbon.myProfile.background:SetTexture(f.avatar.fileID)
                gb:SetCharacterInfo(UnitGUID("player"), "profile", GUILDBOOK_CHARACTER.profile)
            end

            self.gridview[i] = f;
            i = i + 1;
        end
    end

    self.resetAvatar:SetText(L["RESET_AVATAR"])
    self.resetAvatar:SetScript("OnClick", function()
        if not GUILDBOOK_CHARACTER then
            GUILDBOOK_CHARACTER = {}
        end
        if not GUILDBOOK_CHARACTER.profile then
            GUILDBOOK_CHARACTER.profile = {}
        end
        GUILDBOOK_CHARACTER.profile.avatar = nil
        SetPortraitTexture(GuildbookUI.profiles.contentPane.scrollChild.profile.avatar.avatar, "player")
        SetPortraitTexture(GuildbookUI.ribbon.myProfile.background, "player")
        gb:SetCharacterInfo(UnitGUID("player"), "profile", GUILDBOOK_CHARACTER.profile)
    end)

    self.scrollBar:SetMinMaxValues(1, #self.avatars-17)
end

function GuildbookAvatarPickerMixin:OnMouseWheel(delta)
    local x = self.scrollBar:GetValue()
    self.scrollBar:SetValue(x - delta)
end

function GuildbookAvatarPickerMixin:ScrollBar_OnValueChanged()
    local scrollPos = math.floor(self.scrollBar:GetValue()) - 1;
    for i, f in ipairs(self.gridview) do
        f.avatar = self.avatars[i + scrollPos]
        f.Background:SetTexture(self.avatars[i + scrollPos].fileID)
    end
end












--[[
    the tradeskill interface has been updated to use the new listbox widgets from blizz
    the addon will now use the main recipe table it processes on load rather than loading/processing each search
    will start to remove the older code once a release is pushed and no bugs reported

    any tradeskill stuff will now use Guildbook.tradeskillRecipes and then create a table for filtered results

    NEVER EVER PERFORM A SORT ON THE Guildbook.tradeskillRecipes - THE ADDON SETS UP A KEY TABLE TO ACCESS ITEMS QUICKER
]]

GuildbookTradeskillsMixin = {}

---filter button data/info table
local invSlots = {
    { atlas = "transmog-nav-slot-head", tooltip = L["HEAD"], globals = "INVTYPE_HEAD", },
    { atlas = "transmog-nav-slot-shoulder", tooltip = L["SHOULDER"], globals = "INVTYPE_SHOULDER", },
    { atlas = "transmog-nav-slot-back", tooltip = L["BACK"], globals = "INVTYPE_CLOAK", },
    { atlas = "transmog-nav-slot-chest", tooltip = L["CHEST"], globals = { "INVTYPE_CHEST", "INTYPE_ROBE", }, },
    { atlas = "transmog-nav-slot-wrist", tooltip = L["WRIST"], globals = "INVTYPE_WRIST", },
    { atlas = "transmog-nav-slot-hands", tooltip = L["HANDS"], globals = "INVTYPE_HAND", },
    { atlas = "transmog-nav-slot-waist", tooltip = L["WAIST"], globals = "INVTYPE_WAIST", },
    { atlas = "transmog-nav-slot-legs", tooltip = L["LEGS"], globals = "INVTYPE_LEGS", },
    { atlas = "transmog-nav-slot-feet", tooltip = L["FEET"], globals = "INVTYPE_FEET", },
    { atlas = "transmog-nav-slot-mainhand", tooltip = L["WEAPONS"], globals = { "INVTYPE_WEAPON", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT", "INVTYPE_THROWN", }, },
    { atlas = "transmog-nav-slot-secondaryhand", tooltip = L["OFF_HAND"], globals = { "INVTYPE_WEAPONOFFHAND", "INVTYPE_SHIELD", "INVTYPE_HOLDABLE", }, },
    { atlas = "transmog-nav-slot-enchant", tooltip = L["MISC"], globals = { "INVTYPE_FINGER", "INVTYPE_NECK", "INVTYPE_TRINKET", "INVTYPE_BAG", "INVTYPE_QUIVER", }, },
	{ atlas = "bags-icon-consumables", tooltip = L["CONSUMABLES"], globals = "CONSUMABLES" },
    { atlas = "transmog-icon-remove", tooltip = "clear", globals = nil },
}

local function filterConsumables(subType)
    if gb.tradeskillRecipes then
        GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Flush()
        GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:Flush()
        GuildbookUI.tradeskills.filteredItems = nil
        GuildbookUI.tradeskills.filteredItems = {}
        for k, item in ipairs(gb.tradeskillRecipes) do
            if tonumber(item.class) == 0 and tonumber(item.subClass) == subType then
                table.insert(GuildbookUI.tradeskills.filteredItems, item)
            end
        end
        if GuildbookUI.tradeskills.filteredItems then
            GuildbookUI.statusText:SetText(string.format("found %s recipes for %s", #GuildbookUI.tradeskills.filteredItems, "consumables"))
            table.sort(GuildbookUI.tradeskills.filteredItems, function(a,b)
                if a.rarity == b.rarity then
                    return a.name < b.name
                else
                    return a.rarity > b.rarity
                end
            end)
            GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(GuildbookUI.tradeskills.filteredItems)
        end
    end
end

function GuildbookTradeskillsMixin:OnLoad()
    for _, fs in ipairs(self.ribbon.headers) do
        fs:SetText(L[fs.locale])
    end

    local offset = 215
    for k, slot in ipairs(invSlots) do

        local b = CreateFrame("FRAME", nil, self.ribbon, "GuildbookSmallHighlightButton")
        b:SetPoint("LEFT", offset + (30*k), 0)
        b:SetSize(28,28)
        b.t = b:CreateTexture(nil, "BACKGROUND")
        ---some atlas textures are slightly different size/layout so this is just to get them about the same
        if slot.atlas:find("enchant") then
            b.t:SetPoint("TOPLEFT", -1, 0)
            b.t:SetPoint("TOPRIGHT", 1, 0)
            b.t:SetPoint("BOTTOMRIGHT", 0, -2)
        elseif slot.atlas:find("remove") then
            b.t:SetPoint("TOPLEFT", 1, 0)
            b.t:SetPoint("TOPRIGHT", -1, 0)
            b.t:SetPoint("BOTTOMRIGHT", 0, 2)
        elseif slot.atlas:find("consumables") then
            b.t:SetPoint("TOPLEFT", -1, 1)
            b.t:SetPoint("BOTTOMRIGHT", 1, -1)
        else
            b.t:SetAllPoints()
        end
        b.t:SetAtlas(slot.atlas)

        if slot.globals == "CLEAR_ALL_FILTERS" then
            b.tooltipText = L["TRADESKILL_SLOT_REMOVE"];
            b.func = function()
                GuildbookMixin.selectedProfession = nil;
                GuildbookUI.tradeskills.filteredItems = {}
                GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:Flush()
                for _, button in ipairs(GuildbookTradeskillProfessionListview.profButtons) do
                    button.selected:Hide()
                end
                if gb.tradeskillRecipes then
                    GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Flush()
                    local i = 1;
                    GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(gb.tradeskillRecipes)
                end
            end
        elseif slot.globals == "CONSUMABLES" then
            b.tooltipText = string.format(L["TRADESKILL_SLOT_FILTER_S"], slot.tooltip)
            b.flyout = GuildbookTradeskillConsumablesDropdown
            b.flyout:SetParent(b)
            b.flyout:ClearAllPoints()
            b.flyout:SetPoint("TOPRIGHT", -5, -5)
            b.menu = {}
            for i = 0, 8 do
                local subClassName = GetItemSubClassInfo(0, i)
                table.insert(b.menu, {
                    text = subClassName,
                    func = function()
                        filterConsumables(i)
                    end,
                })
            end
            b.func = function()
                if b.flyout and b.flyout:IsVisible() then
                    b.flyout:Hide()
                end
                if b.flyout then
                    b.flyout.delayTimer = 2.0;
                    b.flyout:Show()
                end
            end
        else
            b.tooltipText = string.format(L["TRADESKILL_SLOT_FILTER_S"], slot.tooltip)

            b.func = function()
                if gb.tradeskillRecipes then
                    GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Flush()
                    GuildbookUI.tradeskills.filteredItems = nil
                    GuildbookUI.tradeskills.filteredItems = {}
                    if GuildbookMixin.selectedProfession then
                        for k, item in ipairs(gb.tradeskillRecipes) do
                            if item.profession:lower() == GuildbookMixin.selectedProfession:lower() then
                                if type(slot.globals) == "table" then
                                    for _, global in ipairs(slot.globals) do
                                        if item.equipLocation == global then
                                            table.insert(GuildbookUI.tradeskills.filteredItems, item)
                                        end
                                    end
                                else
                                    if item.equipLocation == slot.globals then
                                        table.insert(GuildbookUI.tradeskills.filteredItems, item)
                                    end
                                end
                            end
                        end
                    else
                        for k, item in ipairs(gb.tradeskillRecipes) do
                            if type(slot.globals) == "table" then
                                for _, global in ipairs(slot.globals) do
                                    if item.equipLocation == global then
                                        table.insert(GuildbookUI.tradeskills.filteredItems, item)
                                    end
                                end
                            else
                                if item.equipLocation == slot.globals then
                                    table.insert(GuildbookUI.tradeskills.filteredItems, item)
                                end
                            end
                        end
                    end
                    if GuildbookUI.tradeskills.filteredItems then
                        GuildbookUI.statusText:SetText(string.format("found %s recipes for %s", #GuildbookUI.tradeskills.filteredItems, slot.tooltip))
                        table.sort(GuildbookUI.tradeskills.filteredItems, function(a,b)
                            if a.expansion == b.expansion then
                                if a.rarity == b.rarity then
                                    return a.name < b.name
                                else
                                    return a.rarity > b.rarity
                                end
                            else
                                return a.expansion > b.expansion
                            end
                        end)
                        GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(GuildbookUI.tradeskills.filteredItems)
                    end
                end
            end
        end

    end

end





--[[

    this is the listview (although not really as it doesnt scroll) that has the profession buttons (Alchemy, Blacksmith, etc)

]]--

GuildbookTradeskillProfessionListview = {}
GuildbookTradeskillProfessionListview.profButtons = {}

---button data/info table
local professions = {
    { id = 171, Name = 'Alchemy', Atlas = "Mobile-Alchemy", },
    { id = 164, Name = 'Blacksmithing', Atlas = "Mobile-Blacksmithing", },
    { id = 333, Name = 'Enchanting', Atlas = "Mobile-Enchanting", },
    { id = 202, Name = 'Engineering', Atlas = "Mobile-Enginnering", },
    { id = 773, Name = 'Inscription', Atlas = "Mobile-Inscription", },
    { id = 755, Name = 'Jewelcrafting', Atlas = "Mobile-Jewelcrafting", },
    { id = 165, Name = 'Leatherworking', Atlas = "Mobile-Leatherworking", },
    { id = 197, Name = 'Tailoring', Atlas = "Mobile-Tailoring", },
    { id = 186, Name = 'Mining', Atlas = "Mobile-Mining", },
    { id = 185, Name = 'Cooking', Atlas = "Mobile-Cooking", },
}

function GuildbookTradeskillProfessionListview:LoadCharacterTradeskillRecipes(guid, prof)
    local character = gb:GetCharacterFromCache(guid)
    if not character then
        return;
    end
    local recipes = {}
    if prof ~= "allRecipes" and character[prof] then
        for itemID, _ in pairs(character[prof]) do
            if prof == "Enchanting" then
                local key = gb.tradeskillEnchantRecipesKeys[itemID]
                table.insert(recipes, gb.tradeskillRecipes[key])
            else
                local key = gb.tradeskillRecipesKeys[itemID]
                table.insert(recipes, gb.tradeskillRecipes[key])
            end
        end

    ---if no prof is given then load all the characters recipes
    elseif prof == "allRecipes" then
        local prof1 = character.Profession1
        if prof1 and character[prof1] then
            for itemID, _ in pairs(character[prof1]) do
                if prof1 == "Enchanting" then
                    local key = gb.tradeskillEnchantRecipesKeys[itemID]
                    table.insert(recipes, gb.tradeskillRecipes[key])
                else
                    local key = gb.tradeskillRecipesKeys[itemID]
                    table.insert(recipes, gb.tradeskillRecipes[key])
                end
            end
        end
        local prof2 = character.Profession2
        if prof2 and character[prof2] then
            for itemID, _ in pairs(character[prof2]) do
                if prof2 == "Enchanting" then
                    local key = gb.tradeskillEnchantRecipesKeys[itemID]
                    table.insert(recipes, gb.tradeskillRecipes[key])
                else
                    local key = gb.tradeskillRecipesKeys[itemID]
                    table.insert(recipes, gb.tradeskillRecipes[key])
                end
            end
        end
    end
    if recipes and next(recipes) ~= nil then
        GuildbookUI.statusText:SetText(string.format("found %s recipes for %s [%s]", #recipes, prof, character.Name))
        table.sort(recipes, function(a,b)
            if a.expansion == b.expansion then
                if a.rarity == b.rarity then
                    return a.name < b.name
                else
                    return a.rarity > b.rarity
                end
            else
                return a.expansion > b.expansion
            end
        end)
        GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(recipes)
    end
    GuildbookUI:OpenTo("tradeskills")
end

function GuildbookTradeskillProfessionListview:OnLoad()
    for i, prof in ipairs(professions) do
        local f = CreateFrame("FRAME", "GuildbookUiProfessionListview"..i, self, "GuildbookListviewItem")
        f:SetSize(175, 40)
        f:SetPoint("TOP", 0, ((i-1)*-40.5)-2)
        f:SetItem(prof)
        f.tradeskill = prof.Name

        f.func = function()
            for _, button in ipairs(self.profButtons) do
                button.selected:Hide()
            end
            f.selected:Show()
            GuildbookMixin.selectedProfession = prof.Name
            if gb.tradeskillRecipes then
                GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Flush()
                GuildbookUI.tradeskills.filteredItems = nil
                GuildbookUI.tradeskills.filteredItems = {}
                for k, item in ipairs(gb.tradeskillRecipes) do
                    if item.profession:lower() == prof.Name:lower() then
                        table.insert(GuildbookUI.tradeskills.filteredItems, item)
                    end
                end
                if GuildbookUI.tradeskills.filteredItems then
                    GuildbookUI.statusText:SetText(string.format("found %s recipes for %s", #GuildbookUI.tradeskills.filteredItems, prof.Name))
                    if prof.Name == "Jewelcrafting" then
                        table.sort(GuildbookUI.tradeskills.filteredItems, function(a,b)
                            if a.expansion == b.expansion then
                                if a.rarity == b.rarity then
                                    return a.subClass < b.subClass
                                else
                                    return a.rarity > b.rarity
                                end
                            else
                                return a.expansion > b.expansion
                            end
                        end)
                        GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(GuildbookUI.tradeskills.filteredItems)
                    else
                        table.sort(GuildbookUI.tradeskills.filteredItems, function(a,b)
                            if a.expansion == b.expansion then
                                if a.rarity == b.rarity then
                                    return a.name < b.name
                                else
                                    return a.rarity > b.rarity
                                end
                            else
                                return a.expansion > b.expansion
                            end
                        end)
                        GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:InsertTable(GuildbookUI.tradeskills.filteredItems)
                    end
                end
            end

            -- get characters with prof then sort by online status
            local charactersWithProf = getAllPlayersWithTradeskill(prof.Name)
            local sorting = {}
            for k, guid in ipairs(charactersWithProf) do
                table.insert(sorting, {
                    guid = guid,
                    name = gb:GetCharacterFromCache(guid).Name,
                    online = gb.onlineZoneInfo[guid].online and 1 or 0,
                })
            end
            table.sort(sorting, function(a,b)
                if a.online == b.online then
                    return a.name < b.name;
                else
                    return a.online > b.online;
                end
            end)
            wipe(charactersWithProf)
            for k, character in ipairs(sorting) do
                table.insert(charactersWithProf, character.guid)
            end
            GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:Flush()
            GuildbookUI.tradeskills.tradeskillItemsCharacterListview.DataProvider:InsertTable(charactersWithProf)
        end
        self.profButtons[i] = f
    end
end

























--TODO: consider updated this to the new listbox widget ?


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- roster
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookRosterMixin = {}
GuildbookRosterMixin.rows = {}
GuildbookRosterMixin.roster = {}
local NUM_ROSTER_ROWS = 14;

function GuildbookRosterMixin:OnLoad()
    local animDur = 0.5
    for i = 1, 14 do
        local f = CreateFrame("FRAME", "GuildbookUiCharactersListview"..i, self.memberListview, "GuildbookRosterListviewItem")
        f:SetPoint("TOPLEFT", 5, ((i-1)*-30)-2)
        f:SetSize(880, 30)
        --f:SetAlpha(0)
        local x = ((i-14) *-1) * 0.025
        f.anim.fadeIn:SetStartDelay((x^x)) -- - 0.68)
        --f.anim.fadeIn:SetSmoothing("OUT")

        GuildbookRosterMixin.rows[i] = f;
    end

    self.buttonDropdownMenus = {
        class = {},
        rankName = {},
    }
    table.insert(self.buttonDropdownMenus.class, {
        text = L["ROSTER_MY_CHARACTERS"],
        func = function()
            self.rosterFilterKey = "myAlts";
            self.rosterFilterValue = nil;
            self:ParseGuildRoster()
        end,
    })
    table.insert(self.buttonDropdownMenus.class, {
        text = L["ROSTER_ALL_CLASSES"],
        func = function()
            self.rosterFilterKey = nil;
            self.rosterFilterValue = nil;
            self:ParseGuildRoster()
        end,
        updateText = false,
    })
    for i = GetNumClasses(), 1, -1 do
        local className, classFile, classID = GetClassInfo(i)
        if className then
            table.insert(self.buttonDropdownMenus.class, {
                text = className, -- string.format("%s %s", gb.Data.Class[classFile].FontStringIconSMALL, className),
                func = function()
                    self.rosterFilterKey = "Class";
                    self.rosterFilterValue = classFile;
                    self:ParseGuildRoster()
                end,
            })
        end
    end
    local mixin = self;
    for _, button in pairs(self.sortButtons) do
        button:RegisterForClicks("AnyDown")
        local font, size, flags = button.Text:GetFont()
        button.Text:SetFont(font, 10, flags)
        button:SetText("|cffffffff"..L[button.sort])
        button.order = true
        button.menu = self.buttonDropdownMenus[button.sort]
        button:SetScript("OnClick", function(self, b)
            if b == "RightButton" then
                if self.flyout and self.flyout:IsVisible() then
                    self.flyout:Hide()
                end
                if self.flyout and mixin.roster then
                    self.flyout.delayTimer = 5.0;
                    self.flyout:Show()
                end
            else
                mixin.rosterSort = self.sort
                mixin.rosterSortOrder = self.order
                mixin:SortRoster()
                self.order = not self.order;
            end
        end)
    end
end

function GuildbookRosterMixin:OnHide()
    for i, row in ipairs(self.rows) do
        --row:SetAlpha(0)
    end
end

function GuildbookRosterMixin:OnShow()
    GUILD_NAME = gb:GetGuildName()
    GuildRoster()
    -- C_Timer.After(0.25, function()
    --     self:ParseGuildRoster()
    -- end)
end

function GuildbookRosterMixin:ParseGuildRoster()
    self:ClearRosterRows()
    self.characterStatus = {}
    local totalMembers, _, _ = GetNumGuildMembers()
    local ranks = {}
    wipe(self.buttonDropdownMenus.rankName)
    table.insert(self.buttonDropdownMenus.rankName, {
        text = L["ROSTER_ALL_RANKS"],
        func = function()
            self.rosterFilterKey = nil;
            self.rosterFilterValue = nil;
            self:ParseGuildRoster()
        end,
    })
    for i = 1, totalMembers do
        local _, _rankName, _, _, _, _zone, _, _, _isOnline, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if GUID then
            self.characterStatus[GUID] = {
                isOnline = _isOnline  and _isOnline or false,
                zone = _zone,
            }
            if not ranks[_rankName] then
                table.insert(self.buttonDropdownMenus.rankName, {
                    text = _rankName,
                    func = function()
                        self.rosterFilterKey = "RankName";
                        self.rosterFilterValue = _rankName;
                        self:ParseGuildRoster()
                    end,
                })
                ranks[_rankName] = true;
            end
            if i == totalMembers then
                self:LoadCharacters()
            end
        end
    end
end

function GuildbookRosterMixin:ClearRosterRows()
    for _, row in ipairs(self.rows) do
        row.character = nil;
        row.ClassIcon:Hide()
        row.Name:SetText("")
        row.Level:SetText("")
        row.Rank:SetText("")
        row.Location:SetText("")
        row.MainSpec:SetText("")
        row.PublicNote:SetText("")
        row.Prof1:Hide()
        row.Prof2:Hide()
        row.MainSpecIcon:Hide()
        row:Hide()
    end
end


function GuildbookRosterMixin:LoadCharacters()
    if not GUILD_NAME then
        return;
    end
    if not GUILDBOOK_GLOBAL then
        return;
    end
    if not GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME] then
        return;
    end
    local numChars = 0;
    for k, v in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME]) do
        numChars = numChars + 1;
    end
    wipe(self.roster)
    local i = 1;
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME]) do
        local _class = string.sub(character.Class, 1, 1):upper()..string.sub(character.Class, 2)
        if self.rosterFilterKey then
            if character[self.rosterFilterKey] and character[self.rosterFilterKey] == self.rosterFilterValue then
                if self.characterStatus and self.characterStatus[guid] then
                    table.insert(self.roster, {
                        guid = guid,
                        -- add the rest of these for sorting purposes
                        class = _class,
                        name = character.Name,
                        level = character.Level,
                        mainSpec = character.MainSpec or "-",
                        prof1 = character.Profession1 or "-",
                        prof2 = character.Profession2 or "-",
                        selected = false,
                        isOnline = self.characterStatus[guid].isOnline,
                        location = self.characterStatus[guid].zone or "-",
                        rankName = character.RankName or "-",
                        publicNote = character.PublicNote or "-",
                    })
                end
            else
                if self.rosterFilterKey == "myAlts" then
                    if GUILDBOOK_GLOBAL.myCharacters and next(GUILDBOOK_GLOBAL.myCharacters) ~= nil then
                        for _guid, _ in pairs(GUILDBOOK_GLOBAL.myCharacters) do
                            if guid == _guid then
                                table.insert(self.roster, {
                                    guid = guid,
                                    -- add the rest of these for sorting purposes
                                    class = _class,
                                    name = character.Name,
                                    level = character.Level,
                                    mainSpec = character.MainSpec or "-",
                                    prof1 = character.Profession1 or "-",
                                    prof2 = character.Profession2 or "-",
                                    selected = false,
                                    isOnline = self.characterStatus[guid].isOnline,
                                    location = self.characterStatus[guid].zone or "-",
                                    rankName = character.RankName or "-",
                                    publicNote = character.PublicNote or "-",
                                })
                            end
                        end
                    end
                end
            end
        else
            if self.characterStatus and self.characterStatus[guid] then
                table.insert(self.roster, {
                    guid = guid,
                    -- add the rest of these for sorting purposes
                    class = _class,
                    name = character.Name,
                    level = character.Level,
                    mainSpec = character.MainSpec or "-",
                    prof1 = character.Profession1 or "-",
                    prof2 = character.Profession2 or "-",
                    selected = false,
                    isOnline = self.characterStatus[guid].isOnline,
                    location = self.characterStatus[guid].zone or "-",
                    rankName = character.RankName or "-",
                    publicNote = character.PublicNote or "-",
                })
            end
        end
        if i == numChars then
            self.memberListview.scrollBar:GetValue()
            self:ForceRosterListviewRefresh()
        else
            i = i + 1;
        end
    end
end

function GuildbookRosterMixin:ForceRosterListviewRefresh()
    if self.roster and next(self.roster) then
        if self.rosterSort and self.rosterSortOrder then
            self:SortRoster()
        else
            table.sort(self.roster, function(a,b)
                if a.isOnline == b.isOnline then
                    if a.level == b.level then
                        return a.name < b.name
                    else
                        return a.level > b.level;
                    end
                else
                    return a.isOnline and not b.isOnline
                end
            end)
        end
        self:ClearRosterRows()
        local scrollPos = math.floor(self.memberListview.scrollBar:GetValue()) - 1;
        for row = 1, NUM_ROSTER_ROWS do
            if self.roster[scrollPos + row] then
                self.rows[row]:SetCharacter(self.roster[scrollPos+row])
                self.rows[row]:SetOffline(self.roster[scrollPos+row].isOnline)
                self.rows[row]:Show()
            end
        end
        self.memberListview.scrollBar:SetMinMaxValues(1,(#self.roster>NUM_ROSTER_ROWS) and #self.roster-(NUM_ROSTER_ROWS-1) or 1)
        self.memberListview.scrollBar:SetValue(scrollPos)
    end
end

function GuildbookRosterMixin:RosterListviewScrollBar_OnValueChanged()
    if #self.roster > 0 then
        self:ClearRosterRows()
        local scrollPos = math.floor(self.memberListview.scrollBar:GetValue()) - 1;
        for row = 1, NUM_ROSTER_ROWS do
            if self.roster[scrollPos + row] then
                if self.roster[scrollPos + row].selected == true then
                    --self.rows[row].Selected:Show()
                else
                    --self.rows[row].Selected:Hide()
                end
                self.rows[row]:SetCharacter(self.roster[scrollPos+row])
                self.rows[row]:SetOffline(self.roster[scrollPos+row].isOnline)
                self.rows[row]:Show()
            end
        end
    end
end

function GuildbookRosterMixin:OnMouseWheel(delta)
    local x = self.memberListview.scrollBar:GetValue()
    self.memberListview.scrollBar:SetValue(x - delta)
end

function GuildbookRosterMixin:SortRoster()
    if self.roster and next(self.roster) then
        local order = self.rosterSortOrder
        local sort = self.rosterSort
        --this is to trigger a refresh by calling the scroll value changed func
        self.memberListview.scrollBar:SetMinMaxValues(1,2)
        -- self.memberListview.scrollBar:SetValue(2)
        -- self.memberListview.scrollBar:SetValue(1)
        C_Timer.After(0, function()
            self.memberListview.scrollBar:SetValue(2)
            self.memberListview.scrollBar:SetValue(1)
        end)
        table.sort(self.roster, function(a,b)
            if order == true then
                if a.isOnline == b.isOnline then
                    if a[sort] == b[sort] then
                        return a.name < b.name
                    else
                        return a[sort] > b[sort];
                    end
                else
                    return a.isOnline and not b.isOnline
                end
            else
                if a.isOnline == b.isOnline then
                    if a[sort] == b[sort] then
                        return a.name < b.name
                    else
                        return a[sort] < b[sort];
                    end
                else
                    return a.isOnline and not b.isOnline
                end
            end
        end)
        self.memberListview.scrollBar:SetMinMaxValues(1,(#self.roster>NUM_ROSTER_ROWS) and #self.roster-(NUM_ROSTER_ROWS-1) or 1)
        self.memberListview.scrollBar:SetValue(1)
    end
end

function GuildbookRosterMixin:RowInviteToGroup_OnMouseDown(row)
    InviteToGroup(row.character.Name)
end

function GuildbookRosterMixin:RowOpenToChat_OnMouseDown(row)
    navigateTo(self:GetParent().chat)
    local target = Ambiguate(row.character.Name, "none");
    self:GetParent().chat.target = target;
    self:GetParent().chat.channel = "WHISPER"
    self:GetParent().chat.chatID = row.guid
    self:GetParent().chat.currentChat:SetText(target)

    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookRosterMixin:RowOpenProfile_OnMouseDown(row)
    if GUILD_NAME then
        self:GetParent().profiles.character = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][row.guid];
        if row.guid == UnitGUID("player") then
            self:GetParent().profiles:LoadCharacter("player")
        else
            self:GetParent().profiles:LoadCharacter(row.guid)
        end
    end

    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookRosterMixin:RowOpenProfile_OnMouseUp(row)
    self:GetParent().profiles:ShowSummary(false)
    navigateTo(self:GetParent().profiles)
end




































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- chat
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookChatsMixin = {}
GuildbookChatsMixin.chat = "guild"; -- use as default
GuildbookChatsMixin.target = nil; -- use as default
GuildbookChatsMixin.channel = "GUILD"; -- use as default
GuildbookChatsMixin.chats = {
    guild = {
        name = "Guild",
        messages = {},
    },
}
GuildbookChatsMixin.chatsKeys = {}
GuildbookChatsMixin.chatsRows = {}
GuildbookChatsMixin.chatContentsRows = {}
-- GuildbookChatsMixin.chatFrame1EditBoxMessage = "";

-- if ChatFrame1EditBox then
--     ChatFrame1EditBox:HookScript("OnTextChanged", function(self)
--         GuildbookChatsMixin.chatFrame1EditBoxMessage = self:GetText()
--     end)
--     ChatFrame1EditBox:HookScript("OnEnterPressed", function(self)
--         if #GuildbookChatsMixin.chatFrame1EditBoxMessage > 0 then
--             local sender = Ambiguate(UnitName("player"), "none")
--             local _, class = UnitClass("player")
--             local _target = self.target
--             --print(_target)
--             SendChatMessage(GuildbookChatsMixin.chatFrame1EditBoxMessage, self.channel, nil, _target)

--             if self.channel == "GUILD" then
--                 return;
--             end

--             self:AddChatMessage({
--                 formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), gb.Data.Class[class].FontColour, sender, msg),
--                 sender = sender,
--                 target = _target,
--                 senderGUID = UnitGUID("player"),
--                 message = msg,
--                 chatID = self.chatID, -- self.chatID is the guid of the person you are /w with
--             })
--         end
--     end)
-- end

local NUM_MESSAGES_ROWS = 9

function GuildbookChatsMixin:OnLoad()
    for i = 1, 9 do
        local f = CreateFrame("FRAME", "GuildbookUiChatsListview"..i, self.chatsListview, "GuildbookCharacterListviewItem")
        f:SetPoint("TOP", 0, ((i-1)*-45)-2)
        f:SetSize(195, 44)
        f.Zone:SetSize(140, 16)
        f.Zone:SetJustifyV("CENTER")
        f.Zone:SetJustifyH("LEFT")
        self.chatsRows[i] = f
    end

    self.chatsRows[1].Name:SetText(L["Guild"])
    self.chatsRows[1].Name:SetTextColor(0.25098040699959,1,0.25098040699959,1)
    self.chatsRows[1].func = function()
        self:SetChatContent("guild", "Guild")
        self.channel = "GUILD";
        self.target = nil;
    end

    for i = 1, NUM_MESSAGES_ROWS do
        local f = CreateFrame("FRAME", "GuildbookUiChatsListview"..i, self.chatContent, "GuildbookChatBubble")
        f:SetPoint("TOP", 0, ((i-1)*-45)-2)
        f:SetSize(150, 44)
        f:Hide()
        f.Message:SetSize(400, 44)
        f.Message:SetNonSpaceWrap(true)

        f.mask = f:CreateMaskTexture()
        f.mask:SetSize(40,40)
        f.mask:SetPoint("RIGHT", -2, 0)
        f.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        f.Icon:AddMaskTexture(f.mask)

        f.rowAnimFadeIn = f:CreateAnimationGroup()
        f.rowAnimFadeIn:SetToFinalAlpha(true)
        local fadeIn = f.rowAnimFadeIn:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.3)
        fadeIn:SetStartDelay(0)
        fadeIn:SetSmoothing("OUT")

        f.rowAnimFadeOut = f:CreateAnimationGroup()
        f.rowAnimFadeOut:SetToFinalAlpha(true)
        local fadeOut = f.rowAnimFadeOut:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.1)
        fadeOut:SetStartDelay(0)
        fadeOut:SetSmoothing("OUT")

        self.chatContent.rows[i] = f
    end


    self.chatContent.scrollBar:SetMinMaxValues(1,9)
end


function GuildbookChatsMixin:OnShow()
    if not GUILDBOOK_CHARACTER.Chats then
        GUILDBOOK_CHARACTER.Chats = {}
    end

end

function GuildbookChatsMixin:AddGuildChatMessage(msg)

    table.insert(self.chats.guild.messages, msg)

    self.chatsRows[1].Zone:SetText(msg.message)
    --self:SetChatContent("guild", "Guild")
    self.chatContent:ForceChatContentUpdate()
end

function GuildbookChatsMixin:AddChatMessage(msg)


    local chatExists = false
    for k, chat in ipairs(self.chats) do
        if chat.id == msg.chatID then
            chatExists = true;
            table.insert(chat.messages, msg)
            chat.lastMessage = GetTime()
        end
    end
    if chatExists == false then
        table.insert(self.chats, {
            id = msg.chatID,
            sender = msg.sender,
            target = msg.target,
            messages = {
                msg,
            },
            lastMessage = GetTime()
        })
    end
    table.sort(self.chats, function(a,b)
        return a.lastMessage > b.lastMessage
    end)

    for k, chat in ipairs(self.chats) do
        if k < 9 then
            local target = Ambiguate(chat.sender, "none") == Ambiguate(UnitName("player"), "none") and chat.target or chat.sender
            self.chatsRows[k+1].Name:SetText("")
            self.chatsRows[k+1].Zone:SetText("")
            self.chatsRows[k+1].Name:SetText(target)
            self.chatsRows[k+1].Zone:SetText(chat.messages[#chat.messages].message)
            if chat.id then
                local character = gb:GetCharacterFromCache(chat.id)
                if character and character.profile and character.profile.avatar then
                    self.chatsRows[k+1].Icon:SetTexture(character.profile.avatar)
                elseif character and character.Race and character.Gender then
                    self.chatsRows[k+1].Icon:SetAtlas(string.format("raceicon-%s-%s", character.Race:lower(), character.Gender:lower()))
                end
            end
            self.chatsRows[k+1].func = function()
                self.channel = "WHISPER";
                self.target = target
                self.chatID = chat.id;

                --print(self.chatID, self.target, self.channel, self.chat)

                self:SetChatContent(self.chatID, self.target)
            end
        end
    end
    self.chatContent:ForceChatContentUpdate()
end


function GuildbookChatsMixin:ChatInput_OnEnterPressed(inputBox)
    if inputBox:GetText():len() > 0 then
        local msg = inputBox:GetText()
        inputBox:SetText("")
        local sender = Ambiguate(UnitName("player"), "none")
        local _, class = UnitClass("player")
        local _target = self.target
        --print(_target)
        SendChatMessage(msg, self.channel, nil, _target)

        if self.channel == "GUILD" then
            return;
        end

        self:AddChatMessage({
            formattedMessage = string.format("%s [%s%s|r]: %s", date("%T"), gb.Data.Class[class].FontColour, sender, msg),
            sender = sender,
            target = _target,
            senderGUID = UnitGUID("player"),
            message = msg,
            chatID = self.chatID, -- self.chatID is the guid of the person you are /w with
        })

    end
end

function GuildbookChatsMixin:UpdateChatContent()

end

function GuildbookChatsMixin:SetChatContent(id, chatName)
    if id == "guild" then
        self.chatContent.messages = self.chats[id].messages
        self.currentChat:SetText(chatName)
        self.chatContent:ClearRows()
        self.chatContent:ForceChatContentUpdate()
    else
        for k, chat in ipairs(self.chats) do
            if chat.id == id then
                self.chatContent.messages = chat.messages
                self.currentChat:SetText(chatName)
                self.chatContent:ClearRows()
                self.chatContent:ForceChatContentUpdate()
            end
        end
    end
end








GuildbookChatsListviewMixin = {}

function GuildbookChatsListviewMixin:LoadChat()
    
end

function GuildbookChatsListviewMixin:ChatsListviewScrollBar_OnValueChanged(scrollBar)
    if not self:GetParent().chats then
        return;
    end
    local scrollPos = math.floor(scrollBar:GetValue())
    for i = 2, 9 do
        if self:GetParent().chatsKeys[i + scrollPos] then
            local chatID = self:GetParent().chatsKeys[i + scrollPos]
            local chat = self:GetParent().chats[chatID]
            if chat then
                self:GetParent().chatsRows[i].Name:SetText("")
                self:GetParent().chatsRows[i].Zone:SetText("")
                self:GetParent().chatsRows[i].Name:SetText(Ambiguate(chat.name, "none"))
                self:GetParent().chatsRows[i].Zone:SetText(chat.messages[#chat.messages].message) -- this is god awful var naming
                self:GetParent().chatsRows[i].func = function()
                    self:GetParent().channel = "WHISPER";
                    self:GetParent().target = Ambiguate(chat.name, "none");
                    self:GetParent().chatID = chatID;
                    self:GetParent():SetChatContent(chatID, self.target)
                end
            else
                --print(i, chatID, "no chat")
            end
        end
    end
end







GuildbookChatContentMixin = {}
GuildbookChatContentMixin.rows = {}
GuildbookChatContentMixin.messages = {}

function GuildbookChatContentMixin:ClearRows()
    for i = 1, 9 do
        --self.rows[i]:Hide()
        self.rows[i].Message:SetText("")
        self.rows[i].Icon:SetTexture(nil)
    end
end

function GuildbookChatContentMixin:ChatBubble_OnMouseDown(bubble)
    local target = Ambiguate(bubble.sender, "none")
    self:GetParent().channel = "WHISPER";
    self:GetParent().target = target
    self:GetParent().currentChat:SetText(target)
    self:GetParent().chatInput:SetFocus()
end

function GuildbookChatContentMixin:ForceChatContentUpdate()
    if not self.messages then
        return;
    end
    if not next(self.messages) then
        return;
    end
    self.scrollBar:SetMinMaxValues(1,2)
    self.scrollBar:SetValue(2)
    local maxPos = (#self.messages>NUM_MESSAGES_ROWS) and #self.messages-(NUM_MESSAGES_ROWS-1) or 1
    self.scrollBar:SetMinMaxValues(1,(#self.messages>NUM_MESSAGES_ROWS) and #self.messages-(NUM_MESSAGES_ROWS-1) or 1)
    C_Timer.After(0, function()
        self.scrollBar:SetValue(maxPos)
    end)
end

function GuildbookChatContentMixin:OnMouseWheel(delta)
    local x = self.scrollBar:GetValue()
    self.scrollBar:SetValue(x - delta)
end

function GuildbookChatContentMixin:ChatContentScrollBar_OnValueChanged()
    if not self.messages then
        return;
    end
    if not next(self.messages) then
        return;
    end
    local scrollPos = math.floor(self.scrollBar:GetValue())
    for i = 1, 9 do
        self.rows[i].Message:SetText("")
        self.rows[i].Icon:SetTexture(nil)
        if self.messages[i+scrollPos-1] then
            local msg = self.messages[i+scrollPos-1]
            self.rows[i]:Show()
            if #self.messages > 9 and next(self.messages, i+scrollPos-1) == nil then
                self.rows[i]:SetAlpha(0)
                self.rows[i].rowAnimFadeIn:Play()
            end
            self.rows[i].Message:SetText(msg.formattedMessage)

            self.rows[i].sender = msg.sender

            --print(i, msg.sender, msg.chatID)

            local race;
            if GUILD_NAME and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][msg.senderGUID] then
                local character = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][msg.senderGUID]
                if character.profile and character.profile.avatar then
                    self.rows[i].Icon:SetTexture(character.profile.avatar)
                elseif character.Race and character.Gender then
                    if character.Race:lower() == "scourge" then
                        race = "undead";
                    else
                        race = character.Race:lower()
                    end
                    self.rows[i].Icon:SetAtlas(string.format("raceicon-%s-%s", race, character.Gender:lower()))
                else
                    self.rows[i].Icon:SetTexture(1067180)
                end
            else
                if not gb.PlayerMixin then
                    gb.PlayerMixin = PlayerLocation:CreateFromGUID(msg.senderGUID)
                else
                    gb.PlayerMixin:SetGUID(msg.senderGUID)
                end
                if gb.PlayerMixin:IsValid() then
                    --local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
                    local raceID = C_PlayerInfo.GetRace(gb.PlayerMixin)
                    local _race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:upper()
                    if _race:lower() == "scourge" then
                        race = "undead";
                    else
                        race = _race:lower()
                    end
                    local gender = (C_PlayerInfo.GetSex(gb.PlayerMixin) == 1 and "FEMALE" or "MALE")
                    self.rows[i].Icon:SetAtlas(string.format("raceicon-%s-%s", race, gender:lower()))
                end
            end

            self.rows[i]:SetWidth(300)
            self.rows[i].Message:SetWidth(250)

            if Ambiguate(msg.sender, "none") == Ambiguate(UnitName("player"), "none") then
                --print("we have a message from ourself", msg.sender, msg.message)
                self.rows[i]:ClearAllPoints()
                self.rows[i]:SetPoint("TOPRIGHT", 0, (i-1) * -45)
                self.rows[i].Icon:ClearAllPoints()
                self.rows[i].Icon:SetPoint("RIGHT", 0, 0)
                self.rows[i].Message:ClearAllPoints()
                self.rows[i].Message:SetPoint("LEFT", 0, 0)
                --self.rows[i].Message:SetJustifyH("RIGHT")
                self.rows[i].mask:ClearAllPoints()
                self.rows[i].mask:SetPoint("RIGHT", -2, 0)
            else
                --print("we have a message NOT from ourself", msg.sender, msg.message)
                self.rows[i]:ClearAllPoints()
                self.rows[i]:SetPoint("TOPLEFT", 0, (i-1) * -45)
                self.rows[i].Icon:ClearAllPoints()
                self.rows[i].Icon:SetPoint("LEFT", 0, 0)
                self.rows[i].Message:ClearAllPoints()
                self.rows[i].Message:SetPoint("LEFT", 50, 0)
                --self.rows[i].Message:SetJustifyH("LEFT")
                self.rows[i].mask:ClearAllPoints()
                self.rows[i].mask:SetPoint("LEFT", 2, 0)
            end

            C_Timer.After(0.1, function()
                for x = 1, 10 do
                    if self.rows[i].Message:IsTruncated() then
                        self.rows[i]:SetWidth(self.rows[i]:GetWidth() * 1.05)
                        self.rows[i].Message:SetWidth(self.rows[i].Message:GetWidth()*1.05)
                    end
                end
            end)
        end
    end
end




































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- profiles
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookProfilesMixin = {}
GuildbookProfilesMixin.character = nil;
GuildbookProfilesMixin.characterModels = {}
GuildbookProfilesMixin.NUM_TALENT_ROWS = 9.0
GuildbookProfilesMixin.summaryRows = {}
GuildbookProfilesMixin.characterStats = {
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


function GuildbookProfilesMixin:OnLoad()

    self:CreateTalentUI()
    self:CreateStatsUI()
    self:CreateSummaryUI()

    self.defaultModel = CreateFrame('PlayerModel', "GuildbookProfilesdefaultModel", self.sidePane, BackdropTemplateMixin and "BackdropTemplate")
    self.defaultModel:SetPoint('TOP', 0, 0)
    self.defaultModel:SetSize(240, 300)
    self.defaultModel:SetModel("interface/buttons/talktomequestion_white.m2")
    self.defaultModel:SetPosition(0,0,0)
    self.defaultModel:SetKeepModelOnHide(true)

    -- set the delay on animations
    for k, slot in ipairs(gb.Data.InventorySlotNames) do
        local x = ((k-#gb.Data.InventorySlotNames) *-1) * 0.025
        self.contentPane.scrollChild.inventory[slot.Name].anim.fadeIn:SetStartDelay((x^x)) -- - 0.6)
    end

    for _, fs in ipairs(self.contentPane.scrollChild.profile.localStrings) do
        fs:SetText(L[fs.locale])
    end
    self.contentPane.scrollChild.profile.useMainProfile.label:SetText(L["USE_MAIN_PROFILE"])

    --self.contentPane.scrollChild.profile.realBioInput.EditBox:SetMaxLetters(200)
    self.contentPane.scrollChild.profile.realBioInput.EditBox:SetScript("OnTextChanged", function(self)
        GuildbookUI.profiles:MyProfile_OnEditChanged("realBio", self:GetText())
    end)

    local scaler = 0.85 -- size 100, border 80, whirl 90, avatar 60, mask 50
    for k, avatar in ipairs(self.contentPane.scrollChild.profile.altCharactersContainer.avatars) do
        local w, h = avatar:GetSize()
        avatar:SetSize(w * scaler, h * scaler)
        avatar:SetScale(scaler)
        avatar.name:SetPoint("BOTTOM", 0, -8)
        avatar.playAnim = true; --set the whirl to play
    end

    self.contentPane.scrollChild.profile.avatar:SetScale(1.8)
    self.contentPane.scrollChild.profile.avatar:SetSize(60,60)
    -- self.contentPane.scrollChild.profile.avatar:ClearAllPoints()
    -- self.contentPane.scrollChild.profile.avatar:SetPoint("CENTER")

    local smartGuessSpecOptions = {
        {
            text = "Detect spec",
            updateText = true,
            func = function()
                GUILDBOOK_CHARACTER.smartGuessMainSpec = true;
            end,
        },
        {
            text = "Manual update",
            updateText = true,
            func = function()
                GUILDBOOK_CHARACTER.smartGuessMainSpec = false;
            end,
        }
    }
    self.contentPane.scrollChild.profile.mainSpecSmartGuessDropDown.menu = smartGuessSpecOptions

end

local profileSummaryAvatarPositions = {
    [1] = {0},
    [2] = {-55, 55},
    [3] = {-110, 0, 110,},
    [4] = {-110, -55, 0, 55, 110},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
}

function GuildbookProfilesMixin:SummaryScrollBar_OnValueChanged()
    self:RefreshProfileSummary()
end

function GuildbookProfilesMixin:CreateSummaryUI()
    local rowHeight = 114
    for i = 1, 4 do
        local f = CreateFrame("FRAME", "GuildbookProfilesSummaryRow"..i, self.summaryPane, "GuildbookProfilesRowTemplate")
        f:SetHeight(rowHeight)
        f:SetPoint("TOPLEFT", 0, (i-1) * -rowHeight)
        f:SetPoint("TOPRIGHT", 0, (i-1) * -rowHeight)

        for _, avatar in ipairs(f.avatars) do
            avatar.playAnim = true
            avatar.showTooltip = false
        end

        self.summaryRows[i] = f
    end
end

function GuildbookProfilesMixin:ShowSummary(show)
    if show == true then
        self.sidePane:Hide()
        self.contentPane:Hide()
        self.background:SetTexture(nil)
        self.summaryPane:Show()

        self:LoadSummary()
    else
        self.sidePane:Show()
        self.contentPane:Show()
        self.summaryPane:Hide()
    end
end

function GuildbookProfilesMixin:RefreshProfileSummary()
    if gb.addonLoaded == false then
        return
    end
    if not GUILD_NAME then
        return
    end
    if not self.members then
        return
    end
    local scrollPos = math.floor(self.summaryPane.scrollBar:GetValue()) -1
    local rowRankHandled = false;
    for r = 1, 4 do
        local row = self.summaryRows[r]
        row.header:SetText(" ")
        row.header:Hide()
        row.headerBackground:Hide()
    end
    for r = 1, 4 do
        rowRankHandled = false;
        local row = self.summaryRows[r]
        for _, avatar in ipairs(row.avatars) do
            avatar:ClearAllPoints()
            avatar:Hide()
        end
        local x = 1;
        for k, char in ipairs(self.members) do
            if char.rowIndex == r+scrollPos then
                local character = gb:GetCharacterFromCache(char.guid)
                if rowRankHandled == false then
                    if char.isNewRank == true then
                        rowRankHandled = true
                        row.header:SetText(character.RankName)
                        row.header:Show()
                        row.headerBackground:Show()
                    end
                end
                if k == 1 then
                    row.header:SetText(character.RankName)
                    row.header:Show()
                    row.headerBackground:Show()
                end
                if row.avatars[x] then
                    row.avatars[x]:SetCharacter(char.guid)
                    row.avatars[x]:Show()
                    if x == 1 then
                        row.avatars[x]:SetPoint("CENTER", 0, 0)
                    else
                        row.avatars[1]:SetPoint("CENTER", ((x-1)*-50), 0)
                        row.avatars[x]:SetPoint("LEFT", row.avatars[x-1], "RIGHT", 0, 0)
                    end
                    x = x + 1;
                end
            end
        end
    end
end

function GuildbookProfilesMixin:LoadSummary()
    if gb.addonLoaded == false then
        return
    end
    if not GUILD_NAME then
        return
    end
    -- local rankCounts = {}
    -- local ranks = {}

    -- for i = 1, GuildControlGetNumRanks() do
    --     local rank = GuildControlGetRankName(i)
    --     ranks[i] = rank;
    -- end


    if gb.player.faction then
        local faction = gb.player.faction:sub(1,1):upper()..gb.player.faction:sub(2)
        self.summaryPane.background:SetAtlas(string.format("_GarrMissionLocation-Town%s-Back", faction))
    else
        self.summaryPane.background:SetAtlas("_GarrMissionLocation-Stormheim-Mid")
    end
    self.members = {}
    local totalMembers, onlineMembers, _ = GetNumGuildMembers()
    for i = 1, totalMembers do
        --local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
        local name, rankName, rankIndex, level, class, zone, publicNote, officerNote, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
        table.insert(self.members, {
            rank = rankIndex,
            guid = guid,
            name = name,
        })
    end
    table.sort(self.members, function(a,b)
        if a.rank == b.rank then
            return a.name < b.name
        else
            return a.rank < b.rank
        end
    end)

    local rowIndex = 1
    local i = 1;
    for k, character in ipairs(self.members) do
        if k > 1 then
            if character.rank ~= self.members[k-1].rank then -- if this characters rankIndex doesnt match the previous then we need to start a new row and add the header
                rowIndex = rowIndex + 1;
                character.rowIndex = rowIndex
                character.isNewRank = true
                i = 1; -- reset the row avatar count
            else
                -- this character has the same rankIndex so we add to the row and increment the avatar count
                if i > 7 then -- this is a check for when to start a new row, using >7 here but could swap the increment of i in the else block, basically we end up with i=1 twice
                    rowIndex = rowIndex + 1;
                    character.rowIndex = rowIndex
                    i = 1; -- reset the row avatar count
                else
                    character.rowIndex = rowIndex
                    i = i + 1;
                end
            end
        else
            character.rowIndex = 1;
            character.hasRankHeader = true
        end
    end
    self.summaryPane.scrollBar:SetMinMaxValues(1, (rowIndex > 4) and rowIndex-3 or 1)
    self.summaryPane.scrollBar:SetValue(1)
    self:RefreshProfileSummary()
end


function GuildbookProfilesMixin:OnHide()
    if not self.character then
        self:HideInventoryIcons()
        self:HideTalentIcons()
        self.background:SetTexture(nil)
        self.sidePane.background:SetTexture(nil)
        --self.fadeOut:Play()
        self.contentPane.scrollChild.profile.edit:Hide()
        for _, f in ipairs(self.contentPane.scrollChild.profile.displayEdit) do
            f:SetShown(false)
        end
        for _, fs in ipairs(self.contentPane.scrollChild.profile.displayStrings) do
            fs:SetShown(true)
        end
    end
end

function GuildbookProfilesMixin:HideInventoryIcons()
    for _, slot in ipairs(gb.Data.InventorySlotNames) do
        self.contentPane.scrollChild.inventory[slot.Name].Icon:SetAtlas("transmog-icon-remove")
        self.contentPane.scrollChild.inventory[slot.Name].Link:SetText("")
        self.contentPane.scrollChild.inventory[slot.Name].link = nil;
        self.contentPane.scrollChild.inventory[slot.Name]:SetAlpha(0)
    end
end


function GuildbookProfilesMixin:OnShow()
    if gb.addonLoaded == false then
        return;
    end
    GUILD_NAME = gb:GetGuildName()
    if not GUILD_NAME then
        return
    end
    for k, f in ipairs(self.contentPane.scrollChild.frames) do
        f:ClearAllPoints()
        if k == 1 then
            f:SetPoint("TOPLEFT", 0, 0)
            f:SetPoint("TOPRIGHT", 0, 0)
        else
            f:SetPoint("TOPLEFT", self.contentPane.scrollChild.frames[k-1], "BOTTOMLEFT", 0, 0)
            f:SetPoint("TOPRIGHT", self.contentPane.scrollChild.frames[k-1], "BOTTOMRIGHT", 0, 0)
        end
    end
    local myCharacters = {}
    if GUILDBOOK_GLOBAL.myCharacters then
        for guid, isMain in pairs(GUILDBOOK_GLOBAL.myCharacters) do
            if GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid] then
                local character = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid]
                table.insert(myCharacters, {
                    text = character.Name,
                    func = function()
                        for _, main in pairs(GUILDBOOK_GLOBAL.myCharacters) do
                            main = false;
                        end
                        GUILDBOOK_GLOBAL.myCharacters[guid] = true;
                        for _guid, _ in pairs(GUILDBOOK_GLOBAL.myCharacters) do
                            if GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][_guid] then
                                local alt = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][_guid]
                                --print("current value:",alt.MainCharacter)
                                alt.MainCharacter = guid;
                                GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][_guid].MainCharacter = guid;
                                --print("new value:",alt.MainCharacter)
                                GUILDBOOK_CHARACTER.MainCharacter = guid;
                                --print(string.format("set %s as main character for %s", character.Name, alt.Name))
                            end
                        end
                        self.contentPane.scrollChild.profile.mainCharacterDropDown.Text:SetText(character.Name)
                        self.contentPane.scrollChild.profile.mainCharacter:SetText(character.Name)
                    end
                })
            end
        end
        self.contentPane.scrollChild.profile.mainCharacterDropDown.menu = myCharacters;
    end
end

function GuildbookProfilesMixin:MyProfile_OnEditChanged(edit, text)
    if not GUILDBOOK_CHARACTER then
        return;
    end
    if not GUILDBOOK_CHARACTER.profile then
        GUILDBOOK_CHARACTER.profile = {}
    end
    GUILDBOOK_CHARACTER.profile[edit] = text;

    if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME] and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][UnitGUID("player")] then
        local character = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][UnitGUID("player")]
        if not character.profile then
            character.profile = {}
        end
        character.profile[edit] = text;
    end
end

function GuildbookProfilesMixin:LoadCharacter(player)
    if not GUILD_NAME then
        return;
    end
    self:ShowSummary(false) -- hide the profile summary frame and show side/content
    navigateTo(self)
    if player and player == "player" then
        self.character = gb:GetCharacterFromCache(UnitGUID("player"))
        if not self.character then
            return;
        end
        local mainSpec, offSpec = {}, {}
        for _, spec in ipairs(gb.Data.Class[self.character.Class].Specializations) do
            table.insert(mainSpec, {
                text = L[spec],
                func = function()
                    self.character.MainSpec = spec
                    GUILDBOOK_CHARACTER.MainSpec = spec
                    self.contentPane.scrollChild.profile.mainSpec:SetText(L[spec])
                    self.contentPane.scrollChild.profile.mainSpecDropDown.Text:SetText(L[spec])

                    gb:DB_SendCharacterData(UnitGUID("player"), "MainSpec", spec, "GUILD", nil, "NORMAL")
                end
            })
            table.insert(offSpec, {
                text = L[spec],
                func = function()
                    self.character.OffSpec = spec
                    GUILDBOOK_CHARACTER.OffSpec = spec
                    self.contentPane.scrollChild.profile.offSpec:SetText(L[spec])
                    self.contentPane.scrollChild.profile.offSpecDropDown.Text:SetText(L[spec])

                    gb:DB_SendCharacterData(UnitGUID("player"), "OffSpec", spec, "GUILD", nil, "NORMAL")
                end
            })
        end
        self.contentPane.scrollChild.profile.mainSpecDropDown.menu = mainSpec
        local smartGuessMainSpec = GUILDBOOK_CHARACTER.smartGuessMainSpec == true and "Detect spec" or "Manual update"
        self.contentPane.scrollChild.profile.mainSpecSmartGuessDropDown.Text:SetText(smartGuessMainSpec)
        self.contentPane.scrollChild.profile.offSpecDropDown.menu = offSpec
    end
    self:HideCharacterModels()
    self:HideInventoryIcons()
    self:HideTalentIcons()
    self:HideProfile()
    if self.character then
        if player and player:find("Player-") then
            self:GetParent().statusBar:SetValue(0)
            self:GetParent().statusBar.duration = gb.COMMS_DELAY + (transmitStagger * 5)
            self:GetParent().statusBar.endTime = GetTime() + self:GetParent().statusBar.duration
            self:GetParent().statusBar.active = true

            self:GetParent().statusText:SetText("requesting profile")
            gb:SendProfileRequest(player)
            C_Timer.After(transmitStagger * 1, function()
                self:GetParent().statusText:SetText("requesting character data")
                gb:CharacterDataRequest(player)
            end)
            C_Timer.After(transmitStagger * 2, function()
                self:GetParent().statusText:SetText("requesting inventory")
                gb:SendInventoryRequest(player)
            end)
            C_Timer.After(transmitStagger * 3, function()
                self:GetParent().statusText:SetText("requesting talents")
                gb:SendTalentInfoRequest(player, 'primary')
            end)
            -- C_Timer.After(transmitStagger * 4, function()
            --     if self.character.Profession1 then
            --         self:GetParent().statusText:SetText("requesting profession 1")
            --         gb:SendTradeSkillsRequest(self.character.Name, self.character.Profession1)
            --     end
            -- end)
            -- C_Timer.After(transmitStagger * 5, function()
            --     if self.character.Profession2 then
            --         self:GetParent().statusText:SetText("requesting profession 2")
            --         gb:SendTradeSkillsRequest(self.character.Name, self.character.Profession2)
            --     end
            -- end)
        else
            gb:GetCharacterInventory()
            gb:GetCharacterTalentInfo('primary')
        end

        local delay = (player and player == "player") and 0 or transmitStagger * 1;
        C_Timer.After(gb.COMMS_DELAY + delay, function()
            if player and player == "player" then
                self.contentPane.scrollChild.profile.edit:Show()
            else
                self.contentPane.scrollChild.profile.edit:Hide()
                for _, f in ipairs(self.contentPane.scrollChild.profile.displayEdit) do
                    f:SetShown(false)
                end
                for _, fs in ipairs(self.contentPane.scrollChild.profile.displayStrings) do
                    fs:SetShown(true)
                end
            end
            self:LoadProfile()
            self:LoadTalents("primary")
            self:LoadInventory()
            self:LoadStats()
            if self.character.Inventory and self.character.Inventory.Current and next(self.character.Inventory.Current) and self.character.Race and self.character.Gender and self.characterModels[self.character.Race:upper()] and self.characterModels[self.character.Race:upper()][self.character.Gender:upper()] then
                self.defaultModel:Hide()
                self.characterModels[self.character.Race:upper()][self.character.Gender:upper()]:Show()
            else
                self.defaultModel:Show()
            end
            --self.fadeIn:Play()
            if self.character.Class then
                self.background:SetAtlas("legionmission-complete-background-"..(self.character.Class:lower()))
            end
            if self.character.Race then
                self.sidePane.background:SetAtlas("transmog-background-race-"..(self.character.Race:lower()))
            end
            self.sidePane.name:SetText(string.format("%s  Lvl %s", self.character.Name, self.character.Level))
            if self.character.MainSpec then
                self.sidePane.spec:SetText(string.format("%s %s", self.character.MainSpec, self.character.Class:sub(1,1):upper()..self.character.Class:sub(2):lower()))
            else
                self.sidePane.spec:SetText("-")
            end
            if self.character.Profession1 then
                self.sidePane.prof1:SetText(string.format("%s [%s]", self.character.Profession1, self.character.Profession1Level))
            else
                self.sidePane.prof1:SetText("-")
            end
            if self.character.Profession2 then
                self.sidePane.prof2:SetText(string.format("%s [%s]", self.character.Profession2, self.character.Profession2Level))
            else
                self.sidePane.prof2:SetText("-")
            end
        end)
    else
        self.defaultModel:Show()
    end    
end

function GuildbookProfilesMixin:Edit_OnMouseDown(self)
    if not GUILDBOOK_CHARACTER.profile then
        GUILDBOOK_CHARACTER.profile = {}
    end
    self.editOpen = not self.editOpen

    self:GetParent().realNameInput:SetText(GUILDBOOK_CHARACTER.profile.realName or "")
    self:GetParent().realDobInput:SetText(GUILDBOOK_CHARACTER.profile.realDob or "")
    self:GetParent().realBioInput.EditBox:SetText(GUILDBOOK_CHARACTER.profile.realBio or "")

    self:GetParent().realName:SetText(GUILDBOOK_CHARACTER.profile.realName or "")
    self:GetParent().realDob:SetText(GUILDBOOK_CHARACTER.profile.realDob or "")
    self:GetParent().realBio:SetText(GUILDBOOK_CHARACTER.profile.realBio or "")

    self:GetParent().mainSpecDropDown.Text:SetText(GUILDBOOK_CHARACTER.MainSpec or "")
    self:GetParent().offSpecDropDown.Text:SetText(GUILDBOOK_CHARACTER.OffSpec or "")

    if GUILDBOOK_CHARACTER.MainCharacter and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][GUILDBOOK_CHARACTER.MainCharacter] then
        self:GetParent().mainCharacterDropDown.Text:SetText(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][GUILDBOOK_CHARACTER.MainCharacter].Name)
    end

    if GUILDBOOK_CHARACTER.profile.avatar then
        GuildbookUI.ribbon.myProfile.background:SetTexture(GUILDBOOK_CHARACTER.profile.avatar) 
    else
        SetPortraitTexture(GuildbookUI.ribbon.myProfile.background, "player")
    end

    if self.editOpen == true then
        GuildbookUI.profiles.avatarPicker:Show()
    else
        GuildbookUI.profiles.avatarPicker:Hide()
        if GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][UnitGUID("player")] then
            GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][UnitGUID("player")].profile = GUILDBOOK_CHARACTER.profile
        end
    end

    GuildbookButtonMixin.OnMouseDown(self)
    for _, f in ipairs(self:GetParent().displayEdit) do
        f:SetShown(not f:IsVisible())
    end
    for _, fs in ipairs(self:GetParent().displayStrings) do
        fs:SetShown(not fs:IsVisible())
    end
end

function GuildbookProfilesMixin:UseMainProfile_OnMouseDown(cb)
    if not self.character then
        return;
    end

    if cb:GetChecked() then
        GUILDBOOK_CHARACTER.UseMainProfile = true;
        if not self.character.profile then
            self.character.profile = {}
        end
        if self.character.MainCharacter and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][self.character.MainCharacter] then
            local mainCharacter = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][self.character.MainCharacter]
            if mainCharacter.profile and next(mainCharacter.profile) then
                for k, v in pairs(mainCharacter.profile) do
                    if k == "avatar" then
                        
                    else
                        self.character.profile[k] = v
                    end
                end
                self.contentPane.scrollChild.profile.realNameInput:SetText(mainCharacter.profile.realName)
                self.contentPane.scrollChild.profile.realDobInput:SetText(mainCharacter.profile.realDob)
                self.contentPane.scrollChild.profile.realBioInput.EditBox:SetText(mainCharacter.profile.realBio)
            end
        end
    else
        GUILDBOOK_CHARACTER.UseMainProfile = false;
        self.contentPane.scrollChild.profile.realNameInput:SetText(GUILDBOOK_CHARACTER.profile.realName or "-")
        self.contentPane.scrollChild.profile.realDobInput:SetText(GUILDBOOK_CHARACTER.profile.realDob or "-")
        self.contentPane.scrollChild.profile.realBioInput.EditBox:SetText(GUILDBOOK_CHARACTER.profile.realBio or "-")

        self.contentPane.scrollChild.profile.realName:SetText(GUILDBOOK_CHARACTER.profile.realName or "-")
        self.contentPane.scrollChild.profile.realDob:SetText(GUILDBOOK_CHARACTER.profile.realDob or "-")
        self.contentPane.scrollChild.profile.realBio:SetText(GUILDBOOK_CHARACTER.profile.realBio or "-")
    end
    GuildbookUI.profiles:LoadProfile()
end

function GuildbookProfilesMixin:LoadProfile()
    if not self.character then
        return
    end
    if GUILDBOOK_CHARACTER.UseMainProfile ~= nil then
        self.contentPane.scrollChild.profile.useMainProfile:SetChecked(GUILDBOOK_CHARACTER.UseMainProfile == true and true or false)
    end
    if self.character.profile then
        for k, v in pairs(self.character.profile) do
            if k == "avatar" then
                self.contentPane.scrollChild.profile[k].avatar:SetTexture(v)
                self.contentPane.scrollChild.profile[k]:Show()
            else
                if self.contentPane.scrollChild.profile[k] then
                    self.contentPane.scrollChild.profile[k]:SetText(v)
                else
                    self.contentPane.scrollChild.profile[k]:SetText("")
                end
            end
        end
    else
        for _, fs in ipairs(self.contentPane.scrollChild.profile.displayStrings) do
            fs:SetText("-")
        end
    end
    --print("load profile",self.character.MainCharacter)
    if self.character.MainCharacter and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][self.character.MainCharacter] then
        self.contentPane.scrollChild.profile.mainCharacter:SetText(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][self.character.MainCharacter].Name or "-")
    end

    self.contentPane.scrollChild.profile.mainSpec:SetText(L[self.character.MainSpec] or "")
    self.contentPane.scrollChild.profile.offSpec:SetText(L[self.character.OffSpec] or "")

    for _, avatar in ipairs(self.contentPane.scrollChild.profile.altCharactersContainer.avatars) do
        avatar:Hide()
    end

    if self.character.Alts and #self.character.Alts > 0 then
        local i = 1; -- ?
        for _, guid in ipairs(self.character.Alts) do
            local avatar = self.contentPane.scrollChild.profile.altCharactersContainer.avatars[i]
            if gb:GetCharacterInfo(guid, "Name") ~= self.character.Name then
                avatar:SetCharacter(guid)
                avatar:Show()
                i = i + 1;
            end
        end
    end

end

function GuildbookProfilesMixin:HideProfile()
    self.contentPane.scrollChild.profile.avatar.avatar:SetTexture(nil)
    for _, fs in ipairs(self.contentPane.scrollChild.profile.displayStrings) do
        fs:SetText("")
    end
end

function GuildbookProfilesMixin:HideCharacterModels()
    for a, g in pairs(self.characterModels) do
        for b, m in pairs(g) do
            m:Hide()
        end
    end
end

--creature/flameleviathan/flameleviathan.m2

function GuildbookProfilesMixin:AddCharacterModelFrame(target, race, gender)
    local shown = self:GetParent():IsVisible()
    self:GetParent():SetAlpha(0)
    self:GetParent():Show()
    if not self.characterModels[race] then
        self.characterModels[race] = {}
    end
    if not self.characterModels[race][gender] then
        local f = CreateFrame('DressUpModel', "GuildbookProfilesCharacterModel"..race..gender, self.sidePane, BackdropTemplateMixin and "BackdropTemplate")
        f:SetFrameLevel(6)
        f:SetPoint('TOP', 0, 0)
        f:SetSize(240, 240)
        if race == 'GNOME' or race == 'DWARF' then
            f:SetPosition(0.0, 0.0, 0.15)
        else
            f:SetPosition(0.0, 0.0, 0.1)
        end
        f.portraitZoom = 0.15
        f:SetPortraitZoom(f.portraitZoom)
        f:SetRotation(0.0)
        f:SetUnit(target)
        f.rotation = 0.61
        f.rotationCursorStart = 0.0
        f:Undress()
        f:SetKeepModelOnHide(true)



        f.anim = f:CreateAnimationGroup()
        f.anim:SetToFinalAlpha(true)
        local fade = f.anim:CreateAnimation("Alpha")
        fade:SetFromAlpha(0)
        fade:SetToAlpha(1)
        fade:SetDuration(0.75)
        fade:SetStartDelay(0.25)
        fade:SetSmoothing("OUT")

        C_Timer.After(0.05, function()
            f:Undress()
            f:SetRotation(0.2)
        end)
        f:EnableMouse(true)

        f:SetScript('OnShow', function(self)
            --print("SHOWING MODEL", race, gender)
            self.anim:Play()
            gb.DEBUG('func', 'CharacterModel_OnShow', 'showing model '..race..' '..gender)
            C_Timer.After(0.1, function()
                self:SetRotation(0.1)
                self:SetPosition(0.0, 0.0, -0.04)
            end)
        end)

        f:SetScript('OnHide', function(self)
            self:SetAlpha(0)
        end)

        -- borrow straight from blizz but is buggy
        f:SetScript('OnMouseDown', function(self, button)
            if ( not button or button == "LeftButton" ) then
                self.mouseDown = true;
                self.rotationCursorStart = GetCursorPosition();
            end
        end)
        f:SetScript('OnMouseUp', function(self, button)
            if ( not button or button == "LeftButton" ) then
                self.mouseDown = false;
            end
        end)
        f:SetScript('OnMouseWheel', function(self, delta)
            self.portraitZoom = self.portraitZoom + (delta/10)
            self:SetPortraitZoom(self.portraitZoom)
            --f:SetPosition(0.0, 0.0, (-0.1 + (delta/10)))
        end)

        f:SetScript('OnUpdate', function(self)
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

        f:Hide()

        self.characterModels[race][gender] = f
    else
        --gb.DEBUG('func', 'CreateCharacterModel', race..' '..gender..' exists')
        if not self.sidePane:IsVisible() then
            self:LoadCharacterModelItems()
        end
    end
    self:GetParent():SetAlpha(1)
    if not shown then
        self:GetParent():Hide()
    end
end


function GuildbookProfilesMixin:LoadCharacterModelItems()
    if self.character then
        if self.characterModels[self.character.Race:upper()] and self.characterModels[self.character.Race:upper()][self.character.Gender:upper()] then
            self.characterModels[self.character.Race:upper()][self.character.Gender:upper()]:Undress()
            C_Timer.After(0.0, function()
                self.characterModels[self.character.Race:upper()][self.character.Gender:upper()]:Show()
            end)
            if self.character.Inventory and self.character.Inventory.Current then
                C_Timer.After(0.1, function()
                    for slot, link in pairs(self.character.Inventory.Current) do
                        if link ~= false and slot ~= 'TABARDSLOT' then
                            self.characterModels[self.character.Race:upper()][self.character.Gender:upper()]:TryOn(link)
                        end
                    end
                end)
            end
        end
    else

    end
end


function GuildbookProfilesMixin:CreateStatsUI()
    for k, group in pairs(self.characterStats) do
        for i, stat in ipairs(group) do
            if self.contentPane.scrollChild.stats[k] then
                local f = self.contentPane.scrollChild.stats[k]
                f.header:SetText(k:sub(1,1):upper()..k:sub(2))
                f[stat.key.."Label"] = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                f[stat.key.."Label"]:SetPoint("TOPLEFT", 0, (i * -22) - 12)
                f[stat.key.."Label"]:SetText(stat.displayName)
                f[stat.key.."Label"]:SetTextColor(1,1,1,1)

                f[stat.key] = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                f[stat.key]:SetPoint("TOPRIGHT", 0, (i * -22) - 12)
                f[stat.key]:SetTextColor(1,1,1,1)
            end
        end
    end
end


function GuildbookProfilesMixin:LoadStats()
    if not self.character then
        return;
    end
    if self.character.PaperDollStats then
        for k, group in pairs(self.characterStats) do
            for i, stat in ipairs(group) do
                if self.contentPane.scrollChild.stats[k] then
                    local f = self.contentPane.scrollChild.stats[k]
                    f[stat.key]:SetText("")
                    if self.character.PaperDollStats[stat.key] then
                        if stat.key == "Defence" and self.character.PaperDollStats[stat.key].Base and self.character.PaperDollStats[stat.key].Mod then
                            local def = self.character.PaperDollStats[stat.key].Base + self.character.PaperDollStats[stat.key].Mod
                            f[stat.key]:SetText(def)
                        elseif (stat.key):find("ManaRegen") then
                            f[stat.key]:SetText(gb:FormatNumberForCharacterStats(self.character.PaperDollStats[stat.key] * 5))
                        else
                            f[stat.key]:SetText(self.character.PaperDollStats[stat.key])
                        end
                    end
                end
            end
        end
    end
end


function GuildbookProfilesMixin:CreateTalentUI()
    -- create talent grid
    self.contentPane.scrollChild.talents.talentTree = {}
    local colPoints = { 19.0, 78.0, 137.0, 196.0 }
    local rowPoints = { 19.0, 78.0, 137.0, 196.0, 255.0, 314.0, 373.0, 432.0, 491.0, 550.0, 609.0 } --257
    for spec = 1, 3 do
        self.contentPane.scrollChild.talents.talentTree[spec] = {}
        for row = 1, self.NUM_TALENT_ROWS do
            self.contentPane.scrollChild.talents.talentTree[spec][row] = {}
            for col = 1, 4 do
                local f = CreateFrame('BUTTON', tostring('GuildbookProfilesTalents'..spec..row..col), self.contentPane.scrollChild.talents, BackdropTemplateMixin and "BackdropTemplate")
                f:SetSize(28, 28)
                f:SetPoint('TOPLEFT', 3+((colPoints[col] * 0.83) + ((spec - 1) * 217)), ((rowPoints[row] * 0.83) * -1) - 34)

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
                    elseif self.name then
                        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                        --GameTooltip:SetSpellByID(self.spellID)
                        GameTooltip:AddLine(self.name)
                        GameTooltip:AddLine(string.format("|cffffffff%s / %s|r", self.rank, self.maxRank))
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


                self.contentPane.scrollChild.talents.talentTree[spec][row][col] = f
            end
        end
    end
end


function GuildbookProfilesMixin:HideTalentIcons()
    for tab = 1, 3 do
        for col = 1, 4 do
            for row = 1, self.NUM_TALENT_ROWS do
                self.contentPane.scrollChild.talents.talentTree[tab][row][col]:Hide()
                self.contentPane.scrollChild.talents.talentTree[tab][row][col].TalentIndex = nil;
            end
        end
    end
    self.contentPane.scrollChild.talents.tree1:SetTexture(nil)
    self.contentPane.scrollChild.talents.tree1:SetAlpha(0.6)
    self.contentPane.scrollChild.talents.tree2:SetTexture(nil)
    self.contentPane.scrollChild.talents.tree2:SetAlpha(0.6)
    self.contentPane.scrollChild.talents.tree3:SetTexture(nil)
    self.contentPane.scrollChild.talents.tree3:SetAlpha(0.6)
end

function GuildbookProfilesMixin:LoadTalents(spec)
    self:HideTalentIcons()
    if self.character and self.character.Talents then
        if self.character.Talents[spec] then
            gb.DEBUG('func', 'ProfilesFrame:Load Talents', 'loading character talents')
            for k, info in ipairs(self.character.Talents[spec]) do
                --print(info.Name, info.Rank, info.MaxRank, info.Icon, info.Tab, info.Row, info.Col)
                if self.contentPane.scrollChild.talents.talentTree[info.Tab] and self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row] then
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col]:Show()
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetTexture(info.Icon)
                    --self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].talentIndex = info.TalentIndex
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].name = info.Name
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].rank = info.Rank
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].maxRank = info.MxRnk
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].link = info.Link
                    --self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText(info.Rank) --string.format("%s / %s", info.Rank, info.MxRnk))
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:Show()
                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].pointsBackground:Show()

                    self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].TalentIndex = info.Index

                    if info.Rank > 0 then
                        self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetDesaturated(false)
                        if info.Rank < info.MxRnk then
                            self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText('|cff40BF40'..info.Rank)
                            self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder-green")
                        else
                            self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:SetText('|cffFFFF00'..info.Rank)
                            self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder-yellow")
                        end
                    else
                        self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Icon:SetDesaturated(true)
                        self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].border:SetAtlas("orderhalltalents-spellborder")
                        self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].Points:Hide()
                        self.contentPane.scrollChild.talents.talentTree[info.Tab][info.Row][info.Col].pointsBackground:Hide()
                    end
                else

                end
            end
            self.contentPane.scrollChild.talents.tree1:SetTexture(gb.Data.TalentBackgrounds[gb.Data.Talents[self.character.Class:upper()][1]])
            --self.contentPane.scrollChild.talents.tree1:SetTexture(string.format("Interface/TalentFrame/%s%s-TopLeft", "Paladin", "Holy"))
            self.contentPane.scrollChild.talents.tree1:SetAlpha(0.6)
            self.contentPane.scrollChild.talents.tree2:SetTexture(gb.Data.TalentBackgrounds[gb.Data.Talents[self.character.Class:upper()][2]])
            self.contentPane.scrollChild.talents.tree2:SetAlpha(0.6)
            self.contentPane.scrollChild.talents.tree3:SetTexture(gb.Data.TalentBackgrounds[gb.Data.Talents[self.character.Class:upper()][3]])
            self.contentPane.scrollChild.talents.tree3:SetAlpha(0.6)

        end

        -- local classId;
        -- for i = 1, GetNumClasses() do
        --     local className, classFile, classID = GetClassInfo(i)
        --     if className and (classFile:lower() == self.character.Class:lower()) then
        --         classId = classID;
        --     end
        -- end

        -- for spec = 1, 3 do
        --     for row = 1, self.NUM_TALENT_ROWS do
        --         for col = 1, 4 do
        --             local talent = self.contentPane.scrollChild.talents.talentTree[spec][row][col]
        --             if talent.TalentIndex then
        --                 talent:SetScript("OnEnter", function(self, classId)
        --                     GameTooltip:SetOwner(talent, 'ANCHOR_RIGHT')
        --                     GameTooltip:SetTalent(spec, talent.TalentIndex, true, classId)
        --                     GameTooltip:Show()
        --                 end)
        --             end
        --         end
        --     end
        -- end
    end
end


function GuildbookProfilesMixin:LoadInventory()
    --print("loading inventory")
    if self.character and self.character.Inventory and self.character.Inventory.Current then
        --print("got current items")
        for slot, link in pairs(self.character.Inventory.Current) do
            if link ~= false then
                local _, _, _, _, icon, _, _ = GetItemInfoInstant(link)
                self.contentPane.scrollChild.inventory[slot]:SetAlpha(0)
                self.contentPane.scrollChild.inventory[slot].Icon:SetTexture(icon)
                self.contentPane.scrollChild.inventory[slot].Link:SetText(link)
                self.contentPane.scrollChild.inventory[slot].link = link;
            else
                self.contentPane.scrollChild.inventory[slot].Icon:SetAtlas("transmog-icon-remove")
                self.contentPane.scrollChild.inventory[slot].Link:SetText("")
                self.contentPane.scrollChild.inventory[slot].link = nil;
            end
            self.contentPane.scrollChild.inventory[slot].anim:Play()
        end
        self:LoadCharacterModelItems()
    end
end




































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- search
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookSearchMixin = {}
GuildbookSearchMixin.rows = {}

function GuildbookSearchMixin:OnLoad()
    for i = 1, 10 do
        local f = CreateFrame("FRAME", "GuildbookSearchRow"..i, self.listview, "GuildbookSearchResult")
        f:SetPoint("TOPLEFT", 5, ((i-1)*-45)-2)
        f:SetSize(880, 45)

        self.rows[i] = f;
    end
end

function GuildbookSearchMixin:OnMouseWheel(delta)
    local x = self.listview.scrollBar:GetValue()
    self.listview.scrollBar:SetValue(x - delta)
end

function GuildbookSearchMixin:ScrollBar_OnValueChanged()
    if self.results and #self.results > 0 then
        local scrollPos = math.floor(self.listview.scrollBar:GetValue()) - 1;
        for row = 1, 10 do
            self.rows[row]:ClearRow()
            if self.results[row+scrollPos] then
                self.rows[row]:SetResult(self.results[row+scrollPos])
            end
        end
    end
end

function GuildbookSearchMixin:Search(term)
    navigateTo(self)

    if term == "iamprepared" then
        for _, f in ipairs(GuildbookUI.frames) do
            f:Hide()
            self:GetParent().backgroundModel:Show()
            self:GetParent().ribbon.searchBox:SetText("")
            PlaySoundFile(552503, "Master")
        end
        return;
    end

    local resultKeys = {
        ["character"] = 7,
        ["inventory"] = 8,
        ["tradeskill"] = 5,
        ["tradeskill_spec"] = 4,
        ["guildbank"] = 6,
    }

    self.processed = {}
    self.results = {}

    local guids = {}
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME]) do
        table.insert(guids, guid)
        if character.Name:lower():find(term:lower()) then
            table.insert(self.results, {
                resultKey = resultKeys["character"],
                title = character.Name,
                icon = string.format("raceicon-%s-%s", character.Race:lower(), character.Gender:lower()),
                iconType = "atlas",
                info = string.format("%s %s", character.MainSpec or "", character.Class:sub(1,1):upper()..character.Class:sub(2):lower()),
                func = function()
                    GuildbookUI.profiles.character = character;
                    --navigateTo(GuildbookUI.profiles)
                    GuildbookUI.profiles:LoadCharacter(guid)
                end,
            })
        end

        -- search items
        if character.Inventory and character.Inventory.Current then
            for slot, link in pairs(character.Inventory.Current) do
                if link and link:lower():find(term:lower()) and not self.processed[link] then
                    local itemID, itemType, itemSubType, itemEquipLoc, icon, _, _ = GetItemInfoInstant(link)
                    table.insert(self.results, {
                        resultKey = resultKeys["inventory"],
                        title = link,
                        icon = icon,
                        iconType = "fileID",
                        info = string.format("%s %s [%s %s; %s %s]", itemType, itemSubType, "ItemID:", itemID, "Source:", character.Name)
                    })
                    self.processed[link] = true
                end
            end
        end

        -- search prof specs
        if character.Profession1Spec then
            local profSpec = GetSpellInfo(character.Profession1Spec)
            if profSpec and profSpec:lower():find(term:lower()) then
                table.insert(self.results, {
                    resultKey = resultKeys["tradeskill_spec"],
                    title = character.Name,
                    icon = string.format("raceicon-%s-%s", character.Race:lower(), character.Gender:lower()),
                    iconType = "atlas",
                    info = string.format("%s %s %s", character.Name, character.Profession1, profSpec),
                    func = function()
                        navigateTo(GuildbookUI.tradeskills)
                        loadGuildMemberTradeskills(guid, character.Profession1)
                    end,
                })
            end
        end
        if character.Profession2Spec then
            local profSpec = GetSpellInfo(character.Profession2Spec)
            if profSpec and profSpec:lower():find(term:lower()) then
                table.insert(self.results, {
                    resultKey = resultKeys["tradeskill_spec"],
                    title = character.Name,
                    icon = string.format("raceicon-%s-%s", character.Race:lower(), character.Gender:lower()),
                    iconType = "atlas",
                    info = string.format("%s %s %s", character.Name, character.Profession2, profSpec),
                    func = function()
                        navigateTo(GuildbookUI.tradeskills)
                        loadGuildMemberTradeskills(guid, character.Profession2)
                    end,
                })
            end
        end


    end
    -- search professions
    if gb.tradeskillRecipes and #gb.tradeskillRecipes > 0 then
        --gb.DEBUG("func", "Search", "tradeskillRecipes exists > 0")
        for k, recipe in ipairs(gb.tradeskillRecipes) do
            --gb.DEBUG("func", "Search", string.format("recipe name: %s, search term: %s", recipe.name, term))
            if recipe.name:lower():find(term:lower()) and not self.processed[recipe.link] then
                --gb.DEBUG("func", "Search", "match found")
                local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(recipe.itemID)
                table.insert(self.results, {
                    resultKey = resultKeys["tradeskill"],
                    title = recipe.link,
                    icon = recipe.icon,
                    iconType = "fileID",
                    info = string.format("%s %s %s %s; %s %s", (itemType and itemType or ""), (itemSubType and itemSubType or ""), "ItemID:", recipe.itemID, "Source:", recipe.profession),
                    func = function()
                        if gb.tradeskillRecipes then
                            GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Flush()
                            GuildbookUI.tradeskills.tradeskillItemsListview.DataProvider:Insert(recipe)
                            loadCharactersWithRecipe(recipe)
                            navigateTo(GuildbookUI.tradeskills)
                        end
                    end,
                })
                self.processed[recipe.link] = true
            end
        end
    else
        gb.DEBUG("func", "Search", "tradeskillRecipes NOT exists > 0")
    end


    local bankItemsSeen = {}
    if self:GetParent().guildbank.items and #self:GetParent().guildbank.items > 0 then
        local items = self:GetParent().guildbank.items
        for k, item in ipairs(items) do
            if item.Link and item.Link:lower():find(term:lower()) and not bankItemsSeen[item.ItemID] then
                table.insert(self.results, {
                    resultKey = resultKeys["guildbank"],
                    title = item.Link,
                    icon = item.Icon,
                    iconType = "fileID",
                    info = string.format("%s x%s [%s]", L['GUILDBANK'], item.Count, item.Bank),
                    func = function()

                    end,
                })
                bankItemsSeen[item.ItemID] = true;
            end
        end
    end



    self.listview.scrollBar:SetValue(1)
    if self.results and #self.results > 0 then
        table.sort(self.results, function(a,b)
            return a.resultKey < b.resultKey
        end)
        for row = 1, 10 do
            self.rows[row]:ClearRow()
            if self.results[row] then
                self.rows[row]:SetResult(self.results[row])
            end
        end
    end
    self.listview.scrollBar:SetMinMaxValues(1, (#self.results-9 >= 1 and #self.results-9 or 1))
end







































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- stats
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookStatsMixin = {}
GuildbookStatsMixin.charts = {
    class = {},
}

function GuildbookStatsMixin:OnLoad()

    local height = 24;
    local segColOffset = 0.66
    local classColourOffsets = {0.5, 0.8, 1.1, 1.4}
    --local classColourOffsets = {1.4, 1.1, 0.8, 0.5}
    self.classSegments = {}

    self.classChartsHeader = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.classChartsHeader:SetPoint("BOTTOM", 0, 270)
    self.classChartsHeader:SetText("Class summary, this uses data from members where a main spec is set")

    self.classPie = LibGraph:CreateGraphPieChart("GuildbookUIStatsClassPie", self, 'BOTTOMRIGHT', 'BOTTOMRIGHT', -55, 35, 235,235)
    for class, info in pairs(gb.Data.Class) do
        local r, g, b = info.RGB[1], info.RGB[2], info.RGB[3]
        self.classPie:AddPie(10, {r*segColOffset, g*segColOffset, b*segColOffset})
        local function classPie_SelectionFunc(_, segment)
            if type(segment) == 'number' and segment > 0 and segment < 11 then
                if self.classSegments[segment] then
                    local class = self.classSegments[segment].class
                    local count = self.classSegments[segment].count
                    for _, bar in ipairs(self.charts.class) do
                        if bar.className == class then
                            local r, g, b = unpack(gb.Data.Class[class].RGB)
                            bar.background:SetColorTexture(r,g,b,0.4)
                        else
                            local r, g, b = unpack(gb.Data.Class[bar.className].RGB)
                            bar.background:SetColorTexture(r,g,b,0.1)
                        end
                    end
                    GameTooltip:SetOwner(self.classPie, 'ANCHOR_BOTTOM', 0, 0)
                    GameTooltip:AddDoubleLine(class, count, 1,1,1)
                    GameTooltip:Show()
                end
            else
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            end
        end
        self.classPie:SetSelectionFunc(classPie_SelectionFunc)

        local f = CreateFrame("FRAME", "GuildbookStatsClassBar"..class, self)
        f:SetSize(530,height)
        f.icon = f:CreateTexture(nil, "ARTWORK")
        f.icon:SetSize(height, height)
        f.icon:SetPoint("LEFT")
        f.icon:SetAtlas(string.format("GarrMission_ClassIcon-%s", string.sub(class, 1, 1):upper()..string.sub(class, 2)))
        f.background = f:CreateTexture(nil, "BACKGROUND")
        f.background:SetSize(height, height)
        f.background:SetAllPoints()
        f.background:SetColorTexture(r,g,b,0.1)
        f.className = class
        f.classCount = 0;
        f.specCountTotal = 0;
        f.specCounts = {}

        f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.text:SetTextColor(1,1,1)
        f.text:SetPoint("LEFT", height + 2, 0)
        f.specInfoText = {}
        -- f.specPie = 
        -- f.specPie:Hide()
        for k, spec in ipairs(info.Specializations) do
            table.insert(f.specCounts, {
                spec = spec,
                count = 0,
            })
            -- f.specPie:AddPie((100 / #info.Specializations), {r*segColOffset, g*segColOffset, b*segColOffset})

            local t = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            t:SetPoint("LEFT", height + 2 + ((k-1)*125), 0)
            t:SetTextColor(1,1,1)
            f.specInfoText[spec] = t

            -- local st = f:CreateTexture(nil, "ARTWORK")
            -- st:SetColorTexture(r*classColourOffsets[k], g*classColourOffsets[k], b*classColourOffsets[k])
            -- st:SetPoint("LEFT")
            -- st:SetHeight(16)

            -- f.statsusBars[spec] = st

            -- local sb =  CreateFrame("StatusBar", nil, f)
            -- sb:SetFrameLevel(100-(k*10))
            -- sb:SendMessage_OnMouseDown
            -- sb:SetStatusBarAtlas("nameplates-bar-background-white")
            -- sb:GetStatusBarTexture():SetHorizTile(false)
            -- sb:SetMinMaxValues(0, 1)
            -- sb:SetValue(0.2 * k)
            -- sb:SetPoint('TOPLEFT', 30, 0)
            -- sb:SetPoint('BOTTOMRIGHT', 0, 0)
            -- sb:SetStatusBarColor(r*classColourOffsets[k], g*classColourOffsets[k], b*classColourOffsets[k])

            -- sb:SetScript("OnEnter", function(self)
            --     GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            --     GameTooltip:AddLine(spec.." "..self:GetValue()*100)
            --     GameTooltip:Show()
            -- end)
            -- sb:SetScript("OnLeave", function()
            --     GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            -- end)
            -- f.statsusBars[spec] = sb;

        end
        -- f:SetScript("OnEnter", function(self)
        --     GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        --     for k, s in ipairs(f.specCounts) do
        --         GameTooltip:AddLine(s.spec.." "..s.count)
        --     end
        --     GameTooltip:Show()
        -- end)
        -- f:SetScript("OnLeave", function()
        --     GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        -- end)
        table.insert(self.charts.class, f)
    end
    table.sort(self.charts.class, function(a,b)
        return a.className > b.className
    end)
    for i, bar in ipairs(self.charts.class) do
        bar:SetPoint("BOTTOMLEFT", 24, (height*i) -6)
    end
    self.classPie:SetScript("OnLeave", function()
        for _, bar in ipairs(self.charts.class) do
            local r, g, b = unpack(gb.Data.Class[bar.className].RGB)
            bar.background:SetColorTexture(r,g,b,0.1)
        end
    end)
end

function GuildbookStatsMixin:OnShow()
    if 1 == 1 then
        --return;
    end
    if not GUILD_NAME then
        return;
    end
    for _, bar in ipairs(self.charts.class) do
        bar.classCount = 0;
        for k, s in ipairs(bar.specCounts) do
            s.count = 0;
        end
    end
    -- for i = 1, self.classPie.TotalSections do
    --     local section = self.classPie.Sections[i]
    --     for _, t in ipairs(section.Textures) do
    --         t:SetAlpha(0.5)
    --     end
    -- end
    self.classPie:ResetPie()
    local totalMembers = 0;
    for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME]) do
        if character.Class and character.MainSpec and character.MainSpec ~= "-" then
            for _, bar in ipairs(self.charts.class) do
                if bar.className == character.Class then
                    bar.classCount = bar.classCount + 1;
                    totalMembers = totalMembers + 1;
                    for k, s in ipairs(bar.specCounts) do
                        if s.spec == character.MainSpec then
                            s.count = s.count + 1;
                            bar.specCountTotal = bar.specCountTotal + 1;
                        end
                    end
                end
            end
        end
    end
    for k, f in ipairs(self.charts.class) do
        local r, g, b = unpack(gb.Data.Class[f.className].RGB)
        local classPercent = (f.classCount / totalMembers) * 100;
        local segColOffset = 0.75;
        self.classPie:AddPie(classPercent, {r*segColOffset, g*segColOffset, b*segColOffset})
        self.classSegments[k] = {
            class = f.className,
            count = f.classCount,
        }
        --if f.specCountTotal > 0 then
            table.sort(f.specCounts, function(a,b)
                return a.count > b.count
            end)
            local scaler = 8;
            local offset = 16;
            local specString = "";
            for k, s in ipairs(f.specCounts) do
                -- local percent = (s.count / f.specCountTotal) * 100;
                -- f.statsusBars[s.spec]:ClearAllPoints()
                -- f.statsusBars[s.spec]:SetWidth(percent * scaler)
                -- f.statsusBars[s.spec]:SetPoint("LEFT", offset, 0)
                -- offset = offset + (percent * scaler);
                local spec = gb:GetClassSpecAtlasName(f.className, s.spec)
                local icon = CreateAtlasMarkup(spec, 16,16)

                specString = specString..icon.." "..s.spec..": "..s.count.."  "

                f.specInfoText[s.spec]:SetText(icon.." "..s.spec..": "..s.count)
            end
            --f.text:SetText(specString)
        --end
    end

end




































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- privacy
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookPrivacyMixin = {}

function GuildbookPrivacyMixin:OnLoad()
    self.header:SetText(L["PRIVACY"] )
    self.about:SetText(L["PRIVACY_ABOUT"] )
    self.shareProfile.Text:SetText(L["PROFILE_TITLE"])
    self.shareInventory.Text:SetText(L["INVENTORY"])
    self.shareTalents.Text:SetText(L["TALENTS"])
end

function GuildbookPrivacyMixin:OnShow()
    self.ranks = {}
    for i = 1, GuildControlGetNumRanks() do
        self.ranks[i] = GuildControlGetRankName(i)
    end
    if not GUILDBOOK_GLOBAL.config then
        GUILDBOOK_GLOBAL.config = {}
    end
    if not GUILDBOOK_GLOBAL.config.privacy then
        GUILDBOOK_GLOBAL.config.privacy = {}
    end

    local function updateInfo(fs, k)
        if type(k) == "function" then
            k = k()
        end
        if k == "none" then
            fs:SetText(L["SHARING_NOBODY"])
            return;
        end
        if type(k) ~= "number" then
            fs:SetText("an error has occured, setting as lowest rank available")
            k = GuildControlGetNumRanks()
        end
        local t = L["SHARING_WITH"]
        for i, r in ipairs(self.ranks) do
            if i <= k then
                t = t..", "..r
            end
        end
        fs:SetText(t)
    end
    updateInfo(self.profileSharingInfo, function()
        if not GUILDBOOK_GLOBAL.config.privacy.shareProfileMinRank then
            GUILDBOOK_GLOBAL.config.privacy.shareProfileMinRank = self.ranks[#self.ranks]
            return #self.ranks
        end
        if GUILDBOOK_GLOBAL.config.privacy.shareProfileMinRank == "none" then
            return "none";
        end
        if GUILDBOOK_GLOBAL.config.privacy.shareProfileMinRank then
            for k, r in ipairs(self.ranks) do
                if r == GUILDBOOK_GLOBAL.config.privacy.shareProfileMinRank then
                    return k
                end
            end
        end
    end)
    updateInfo(self.inventorySharingInfo, function()
        if not GUILDBOOK_GLOBAL.config.privacy.shareInventoryMinRank then
            GUILDBOOK_GLOBAL.config.privacy.shareInventoryMinRank = self.ranks[#self.ranks]
            return #self.ranks
        end
        if GUILDBOOK_GLOBAL.config.privacy.shareInventoryMinRank == "none" then
            return "none";
        end
        if GUILDBOOK_GLOBAL.config.privacy.shareInventoryMinRank then
            for k, r in ipairs(self.ranks) do
                if r == GUILDBOOK_GLOBAL.config.privacy.shareInventoryMinRank then
                    return k
                end
            end
        end
    end)
    updateInfo(self.talentsSharingInfo, function()
        if not GUILDBOOK_GLOBAL.config.privacy.shareTalentsMinRank then
            GUILDBOOK_GLOBAL.config.privacy.shareTalentsMinRank = self.ranks[#self.ranks]
            return #self.ranks
        end
        if GUILDBOOK_GLOBAL.config.privacy.shareTalentsMinRank == "none" then
            return "none";
        end
        if GUILDBOOK_GLOBAL.config.privacy.shareTalentsMinRank then
            for k, r in ipairs(self.ranks) do
                if r == GUILDBOOK_GLOBAL.config.privacy.shareTalentsMinRank then
                    return k
                end
            end
        end
    end)

    self.shareProfile.menu = {}
    self.shareInventory.menu = {}
    self.shareTalents.menu = {}
    for k, rank in ipairs(self.ranks) do
        table.insert(self.shareProfile.menu, {
            text = rank,
            func = function()
                GUILDBOOK_GLOBAL.config.privacy.shareProfileMinRank = rank;
                updateInfo(self.profileSharingInfo, k)
                gb:SendPrivacyInfo(nil, "GUILD")
            end,
        })
        table.insert(self.shareInventory.menu, {
            text = rank,
            func = function()
                GUILDBOOK_GLOBAL.config.privacy.shareInventoryMinRank = rank;
                updateInfo(self.inventorySharingInfo, k)
                gb:SendPrivacyInfo(nil, "GUILD")
            end,
        })
        table.insert(self.shareTalents.menu, {
            text = rank,
            func = function()
                GUILDBOOK_GLOBAL.config.privacy.shareTalentsMinRank = rank;
                updateInfo(self.talentsSharingInfo, k)
                gb:SendPrivacyInfo(nil, "GUILD")
            end,
        })
    end
    table.insert(self.shareProfile.menu, {
        text = L["NONE"],
        func = function()
            GUILDBOOK_GLOBAL.config.privacy.shareProfileMinRank = "none";
            updateInfo(self.profileSharingInfo, "none")
            gb:SendPrivacyInfo(nil, "GUILD")
        end,
    })
    table.insert(self.shareInventory.menu, {
        text = L["NONE"],
        func = function()
            GUILDBOOK_GLOBAL.config.privacy.shareInventoryMinRank = "none";
            updateInfo(self.inventorySharingInfo, "none")
            gb:SendPrivacyInfo(nil, "GUILD")
        end,
    })
    table.insert(self.shareTalents.menu, {
        text =  L["NONE"],
        func = function()
            gb.DEBUG("func", "PrivacySelection_Changed", "set talent privacy setting to none")
            GUILDBOOK_GLOBAL.config.privacy.shareTalentsMinRank = "none";
            updateInfo(self.talentsSharingInfo, "none")
            gb:SendPrivacyInfo(nil, "GUILD")
        end,
    })
end




































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookGuildBankMixin = {}
GuildbookGuildBankMixin.rows = {}
GuildbookGuildBankMixin.items = {}
GuildbookGuildBankMixin.listviewItems = {}
GuildbookGuildBankMixin.sortOrder = true;
GuildbookGuildBankMixin.sort = "Class";
GuildbookGuildBankMixin.filter = nil;

function GuildbookGuildBankMixin:OnLoad()
    
    for i = 1, 14 do
        local f = CreateFrame("FRAME", nil, self.listview, "GuildbookGuildBankListviewItem")
        f:SetPoint("TOPLEFT", 5, ((i-1)*-30)-2)
        f:SetSize(880, 30)

        f:SetScript("OnMouseDown", function(self)
            if IsShiftKeyDown() and self.link then
                HandleModifiedItemClick(self.link)
            end
        end)

        self.rows[i] = f
    end

    self.item:SetText(L["GUILDBANK_HEADER_ITEM"])
    self.count:SetText(L["GUILDBANK_HEADER_COUNT"])
    self.subType:SetText(L["GUILDBANK_HEADER_SUBTYPE"])

    self.buttonDropdownMenus = {
        Bank = {},
        Type = {},
    }

    self.sortType.menu = self.buttonDropdownMenus.Type
    self.sortBank.menu = self.buttonDropdownMenus.Bank

    self.refresh:SetText("|cffffffff"..L["GUILDBANK_REFRESH"])
    self.refresh:SetScript("OnClick", function()
        self.refresh:Disable()
        C_Timer.After(20, function()
            self.refresh:Enable()
        end)
        self:RequestBankData()
    end)

end

function GuildbookGuildBankMixin:OnShow()
    -- dont always spam chat comms when showing
    if #self.items == 0 then
        self:RequestBankData()
    end
end

function GuildbookGuildBankMixin:RequestBankData()
    self:ClearRows()
    wipe(self.buttonDropdownMenus.Type)
    wipe(self.buttonDropdownMenus.Bank)
    self.listview.spinner:Show()
    self.listview.commits:Show()
    self.listview.data:Show()
    self.listview.anim:Play()
    --GuildRoster()
    local guildBankCharacters = {}
    local totalMembers, onlineMembers, _ = GetNumGuildMembers()
    table.insert(self.buttonDropdownMenus.Bank, {
        text = L["GUILDBANK_ALL_BANKS"],
        func = function()
            self.filter = nil;
            self.sort = "Bank";
            self:SortListview()
            
        end,
    })
    for i = 1, totalMembers do
        local name, _, _, _, _, _, publicNote, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
        if publicNote:lower():find('guildbank') then
            table.insert(guildBankCharacters, {
                name = name,
                guid = guid,
            })
            table.insert(self.buttonDropdownMenus.Bank, {
                text = name,
                func = function()
                    self.filter = name
                    self.sort = "Bank";
                    self:SortListview()
                end,
            })
        end
    end

    local commitsText, dataText = "", ""
    self.listview.commits:SetText(commitsText)
    self.listview.data:SetText(dataText)
    local delay = 2.0
    local idx = 2
    if guildBankCharacters and #guildBankCharacters > 0 then

        --remove old banks
        if GUILDBOOK_GLOBAL.GuildBank then
            for bank, info in pairs(GUILDBOOK_GLOBAL.GuildBank) do --bank should be a guid but some older name keys may still exist
                local exists = false
                for _, b in ipairs(guildBankCharacters) do
                    if (b.name == bank) or (Ambiguate(b.name, "none") == bank) or (b.guid == bank) then
                        exists = true
                    end
                end
                if exists == false then
                    GUILDBOOK_GLOBAL.GuildBank[bank] = nil
                end
            end
        end

        -- fire off the first request
        local bank = guildBankCharacters[1]
        gb:RequestGuildBankCommits(bank.guid)
        commitsText = commitsText..L["GUILDBANK_REQUEST_COMMITS"]..bank.name.."\n"
        self.listview.commits:SetText(commitsText)

        C_Timer.After(1.25, function()
            if gb.BankCharacters[bank.guid].Source then
                gb:RequestGuildBankItems(gb.BankCharacters[bank.guid].Source, bank.guid)
                dataText = dataText..L["GUILDBANK_REQUEST_INFO"]..gb.BankCharacters[bank.guid].Source.." ["..bank.name.."]\n"
                self.listview.data:SetText(dataText)
            end
        end)

        -- stagger any extra requests
        if #guildBankCharacters > 1 then
            C_Timer.NewTicker(delay, function()
                if guildBankCharacters[idx]then
                    local bank = guildBankCharacters[idx]

                    gb.BankRequests = {}
                    gb:RequestGuildBankCommits(bank.guid)
                    commitsText = commitsText..L["GUILDBANK_REQUEST_COMMITS"]..bank.name.."\n"
                    self.listview.commits:SetText(commitsText)

                    C_Timer.After(1.25, function()
                        if gb.BankCharacters[bank.guid].Source then
                            gb:RequestGuildBankItems(gb.BankCharacters[bank.guid].Source, bank.guid)
                            dataText = dataText..L["GUILDBANK_REQUEST_INFO"]..gb.BankCharacters[bank.guid].Source.." ["..bank.name.."]\n"
                            self.listview.data:SetText(dataText)
                        end
                    end)
                    idx = idx + 1;
                end
            end, #guildBankCharacters - 1)
        end

        C_Timer.After((delay * #guildBankCharacters) + 1.0, function()
            self:RequestBankItemInfo()
        end)
    end
end

function GuildbookGuildBankMixin:RequestBankItemInfo()
    local itemCount = 0;
    if GUILDBOOK_GLOBAL.GuildBank then
        for bank, info in pairs(GUILDBOOK_GLOBAL.GuildBank) do
            for itemID, count in pairs(info.Data) do
                itemCount = itemCount + 1;
            end
            itemCount = itemCount + 1;
        end
    end
    self.items = {}
    local itemTypes = {}
    local i = 0;
    if GUILDBOOK_GLOBAL.GuildBank then
        table.insert(self.buttonDropdownMenus.Type, {
            text = L["GUILDBANK_ALL_TYPES"],
            func = function()
                self.filter = nil;
                self.sort = "Type";
                self:SortListview()
            end,
        })
        for bank, info in pairs(GUILDBOOK_GLOBAL.GuildBank) do
            i = i + 1;
            table.insert(self.items, {
                ItemID = -1,
                Count = 1,
                Type = GetCoinTextureString(info.Money),
                SubType = "",
                Class = -1,
                SubClass = info.Money,
                Icon = 133784,
                Link = nil,
                Bank = bank,
            })
            for itemID, count in pairs(info.Data) do
                i = i + 1;
                local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(itemID)
                if not itemTypes[itemType] then
                    table.insert(self.buttonDropdownMenus.Type, {
                        text = itemType,
                        func = function()
                            self.filter = itemType
                            self.sort = "Type";
                            self:SortListview()
                        end,
                    })
                    itemTypes[itemType] = true
                end
                local _, link = GetItemInfo(itemID)
                if not link then
                    local item = Item:CreateFromItemID(itemID)
                    item:ContinueOnItemLoad(function()
                        link = item:GetItemLink()
                        table.insert(self.items, {
                            ItemID = itemID,
                            Count = count,
                            Type = itemType,
                            SubType = itemSubType,
                            Class = itemClassID,
                            SubClass = itemSubClassID,
                            Icon = icon,
                            Link = link,
                            Bank = bank,
                        })
                        if i == itemCount then
                            self:LoadBankItems(itemCount)
                        end
                    end)
                else
                    table.insert(self.items, {
                        ItemID = itemID,
                        Count = count,
                        Type = itemType,
                        SubType = itemSubType,
                        Class = itemClassID,
                        SubClass = itemSubClassID,
                        Icon = icon,
                        Link = link,
                        Bank = bank,
                    })
                    if i == itemCount then
                        self:LoadBankItems(itemCount)
                    end
                end
            end
        end
    end
end

function GuildbookGuildBankMixin:ClearRows()
    for i = 1, 14 do
        self.rows[i].link = nil
        self.rows[i].Icon:SetTexture(nil)
        self.rows[i].Link:SetText(" ")
        self.rows[i].Count:SetText(" ")
        self.rows[i].Type:SetText(" ")
        self.rows[i].SubType:SetText(" ")
        self.rows[i].Bank:SetText(" ")
        self.rows[i].Index:SetText(" ")
        self.rows[i]:SetAlpha(0)
    end
end

function GuildbookGuildBankMixin:LoadBankItems(itemCount)
    self.listview.scrollBar:SetMinMaxValues(1, (itemCount < 14) and 1 or itemCount-13)
    self.listview.scrollBar:SetValue(1)
    -- for now
    table.sort(self.items, function(a, b)
        if a.Class == b.Class then
            return a.SubClass < b.SubClass;
        else
            return a.Class < b.Class;
        end
    end)

    self:SortListview()
    self.listview.spinner:Hide()
    self.listview.commits:Hide()
    self.listview.data:Hide()
    self.listview.anim:Stop()
end


function GuildbookGuildBankMixin:SortListview()

    wipe(self.listviewItems)

    if self.filter and self.sort then
        for k, item in ipairs(self.items) do
            if item[self.sort] == self.filter then
                table.insert(self.listviewItems, item)
            end
        end
    else
        for k, item in ipairs(self.items) do
            table.insert(self.listviewItems, item)
        end
    end

    table.sort(self.listviewItems, function(a,b)
        if a.Class == b.Class then
            if a.SubClass == b.SubClass then
                return a.Link < b.Link
            else
                return a.SubClass < b.SubClass;
            end
        else
            return a.Class < b.Class;
        end
    end)

    self:ClearRows()

    if self.listviewItems then
        for i = 1, 14 do
            local scrollPos = math.floor(self.listview.scrollBar:GetValue()) - 1;
            if self.listviewItems[i + scrollPos] then
                local item = self.listviewItems[i + scrollPos]
                self.rows[i].link = item.Link
                self.rows[i].Icon:SetTexture(item.Icon)
                self.rows[i].Link:SetText(item.Link and item.Link or L["GUILDBANK_FUNDS"])
                self.rows[i].Count:SetText(item.Link and "x"..item.Count or "")
                self.rows[i].Type:SetText(item.Type)
                self.rows[i].SubType:SetText(item.Link and item.SubType or L["GUILDBANK_CURRENCY"])
                self.rows[i].Bank:SetText(item.Bank)
    
                self.rows[i].Index:SetText(i + scrollPos)

                self.rows[i].anim:Play()
            end
        end
    end

    self.listview.scrollBar:SetMinMaxValues(1, (#self.listviewItems < 14) and 1 or #self.listviewItems-13)
    self.listview.scrollBar:SetValue(1)

end


function GuildbookGuildBankMixin:OnMouseWheel(delta)
    local x = self.listview.scrollBar:GetValue()
    self.listview.scrollBar:SetValue(x - delta)
end


function GuildbookGuildBankMixin:ScrollBar_OnValueChanged()
    if self.listviewItems then
        for i = 1, 14 do
            local scrollPos = math.floor(self.listview.scrollBar:GetValue()) - 1;
            if self.listviewItems[i + scrollPos] then
                local item = self.listviewItems[i + scrollPos]
                self.rows[i].link = item.Link
                self.rows[i].Icon:SetTexture(item.Icon)
                self.rows[i].Link:SetText(item.Link and item.Link or L["GUILDBANK_FUNDS"])
                self.rows[i].Count:SetText(item.Link and "x"..item.Count or "")
                self.rows[i].Type:SetText(item.Type)
                self.rows[i].SubType:SetText(item.Link and item.SubType or L["GUILDBANK_CURRENCY"])
                self.rows[i].Bank:SetText(item.Bank)
    
                self.rows[i].Index:SetText(i + scrollPos)
            end
        end
    end
end




































--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- help and about
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuildbookHelpAboutMixin = {}

function GuildbookHelpAboutMixin:OnLoad()
    local w = self:GetWidth()
    self.scrollFrame.scrollChild:SetSize(w-70, 800)
    self.scrollFrame.scrollChild.credits:SetSize(w-70, 800)

    self.scrollFrame.scrollChild.credits:SetText(L["HELP_ABOUT_CREDITS"])
end

function GuildbookHelpAboutMixin:OnShow()
    
end