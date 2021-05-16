

local _, gb = ...

local L = gb.Locales

local GUILD_NAME;

GuildbookButtonMixin = {}

function GuildbookButtonMixin:OnMouseDown()
    self:AdjustPointsOffset(-1,-1)
end

function GuildbookButtonMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
    if self.func then
        C_Timer.After(0, self.func)
    end
end


GuildbookListviewItemMixin = {}

function GuildbookListviewItemMixin:OnLoad()
    local _, size, flags = self.Text:GetFont()
    self.Text:SetFont([[Interface\Addons\Guildbook\Media\Fonts\Acme-Regular.ttf]], size+4, flags)
end

function GuildbookListviewItemMixin:SetItem(info)
    self.Icon:SetAtlas(info.Atlas)
    --self.Icon:SetTexture(1396618)
    self.Text:SetText(info.Name)

    -- self.Icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES");
    -- local coords = CLASS_ICON_TCOORDS["PALADIN"];
    -- self.Icon:SetTexCoord(unpack(coords));
end

function GuildbookListviewItemMixin:OnMouseDown()
    self:AdjustPointsOffset(-1,-1)
end

function GuildbookListviewItemMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
    if self.func then
        C_Timer.After(0, self.func)
    end
end


--- this is the mixin for the slide out menu items
GuildbookMenuFlyoutItemMixin = {}

function GuildbookMenuFlyoutItemMixin:OnMouseDown()
    self:AdjustPointsOffset(-1,-1)
end

function GuildbookMenuFlyoutItemMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
    if self.func then
        C_Timer.After(0, self.func)
    end
end

function GuildbookMenuFlyoutItemMixin:OnEnter()
    if self.tooltipText then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:AddLine(self.tooltipText)
        GameTooltip:Show()
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end
end

function GuildbookMenuFlyoutItemMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end


--- this is the mixin for the icons shown on the recipe listview items
GuildbookItemIconFrameMixin = {}

function GuildbookItemIconFrameMixin:OnEnter()
    if self.link then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetHyperlink(self.link)
        GameTooltip:Show()
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end
end

function GuildbookItemIconFrameMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookItemIconFrameMixin:SetItem(itemID)
    local item = Item:CreateFromItemID(itemID)
    local link = item:GetItemLink()
    local icon = item:GetItemIcon()
    if not link and not icon then
        item:ContinueOnItemLoad(function()
            self.link = item:GetItemLink()
            self.icon:SetTexture(item:GetItemIcon())
        end)
    else
        self.link = link
        self.icon:SetTexture(icon)
    end
end


--- character listview mixin
GuildbookCharacterListviewItemMixin = {}

function GuildbookCharacterListviewItemMixin:OnLoad()
    local _, size, flags = self.Name:GetFont()
    self.Name:SetFont([[Interface\Addons\Guildbook\Media\Fonts\Acme-Regular.ttf]], size, flags)
    self.Zone:SetFont([[Interface\Addons\Guildbook\Media\Fonts\Acme-Regular.ttf]], size, flags)

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

function GuildbookCharacterListviewItemMixin:SetCharacter(character, link)
    self.Icon:SetAtlas(string.format("raceicon-%s-%s", character.race:lower(), character.gender:lower()))
    self.Name:SetText(character.name)
    if character.online == true then
        self.Name:SetTextColor(1,1,1,1)
        self.Zone:SetTextColor(1,1,1,1)
        self.Zone:SetText("["..character.zone.."]")
        self.sendMessage:Show()
    else
        self.Name:SetTextColor(0.5,0.5,0.5,0.7)
        self.sendMessage:Hide()
        self.Zone:SetText("[offline]")
        self.Zone:SetTextColor(0.5,0.5,0.5,0.7)
    end
    self.itemLink = link;
    self.character = character;
end

function GuildbookCharacterListviewItemMixin:ClearCharacter()
    self.Icon:SetTexture(nil)
    self.Name:SetText("")
    self.Zone:SetText("")
    self.sendMessage:Hide()
    self.itemLink = nil;
    self.character = nil;
end

function GuildbookCharacterListviewItemMixin:SendMessage_OnEnter()
    if self.itemLink then
        GameTooltip:SetOwner(self.sendMessage, 'ANCHOR_RIGHT')
        GameTooltip:AddLine("|cffffffffSend trade enquiry|r")
        GameTooltip:Show()
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end
end

function GuildbookCharacterListviewItemMixin:SendMessage_OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookCharacterListviewItemMixin:SendMessage_OnMouseDown()
    local point, relativeTo, relativePoint, xOfs, yOfs = self.sendMessage:GetPoint()
	self.sendMessage:ClearAllPoints()
	self.sendMessage:SetPoint(point, relativeTo, relativePoint, xOfs - 1, yOfs - 1)
    local msg = string.format("[Guildbook] are you able to craft %s", self.itemLink)
    SendChatMessage(msg, "WHISPER", nil, self.character.name)
end

function GuildbookCharacterListviewItemMixin:SendMessage_OnMouseUp()
    local point, relativeTo, relativePoint, xOfs, yOfs = self.sendMessage:GetPoint()
	self.sendMessage:ClearAllPoints()
	self.sendMessage:SetPoint(point, relativeTo, relativePoint, xOfs + 1, yOfs + 1)
end


--- recipe listview mixin
GuildbookRecipeListviewItemMixin = {}

function GuildbookRecipeListviewItemMixin:OnLoad()
    local _, size, flags = self.Text:GetFont()
    self.Text:SetFont([[Interface\Addons\Guildbook\Media\Fonts\Acme-Regular.ttf]], size+2, flags)
end

function GuildbookRecipeListviewItemMixin:OnEnter()
    if self.link then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        if self.enchant then
            GameTooltip:SetSpellByID(self.recipeID)
        else
            GameTooltip:SetHyperlink(self.link)
        end
        GameTooltip:Show()
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end
end

function GuildbookRecipeListviewItemMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookRecipeListviewItemMixin:OnMouseDown()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	self:ClearAllPoints()
	self:SetPoint(point, relativeTo, relativePoint, xOfs - 1, yOfs - 1)

    if self.func then
        self.func()
    end
end

function GuildbookRecipeListviewItemMixin:OnMouseUp()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	self:ClearAllPoints()
	self:SetPoint(point, relativeTo, relativePoint, xOfs + 1, yOfs + 1)
end

function GuildbookRecipeListviewItemMixin:ClearReagents()
    for _, reagent in pairs(self.reagentIcons) do
        reagent.icon:SetTexture(nil)
        reagent.greenBorder:Hide()
        reagent.orangeBorder:Hide()
        reagent.purpleBorder:Hide()
        reagent.count:SetText("")
        reagent.link = nil
    end
end

function GuildbookRecipeListviewItemMixin:SetItem(itemID)
    local item = Item:CreateFromItemID(itemID)
    local link = item:GetItemLink()
    --local icon = item:GetItemIcon()
    if not link then
        item:ContinueOnItemLoad(function()
            self.link = item:GetItemLink()
            self.Text:SetText(link)
            --self.icon:SetTexture(item:GetItemIcon())
        end)
    else
        self.link = link
        self.Text:SetText(link)
        --self.icon:SetTexture(icon)
    end
end


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
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local rPerc, gPerc, bPerc, argbHex = GetClassColor(self.character.class:upper())
    GameTooltip_SetTitle(GameTooltip, self.Name:GetText().."\n\n|cffffffff"..L['level'].." "..self.Level:GetText(), CreateColor(rPerc, gPerc, bPerc), nil)
    if self.tooltipIcon then
        if self.character.race and self.character.gender then
            self.tooltipIcon.icon:SetAtlas(string.format("raceicon-%s-%s", self.character.race:lower(), self.character.gender:lower()))
            GameTooltip_InsertFrame(GameTooltip, self.tooltipIcon)
            for k, frame in pairs(GameTooltip.insertedFrames) do
                if frame:GetName() == "GuildbookRosterListviewItemTooltipIcon" then
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPRIGHT", -20, -20)
                end
            end
        end
    end

   -- GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L['rankName'], "|cffffffff"..self.Rank:GetText())
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L['location'], "|cffffffff"..self.Location:GetText())
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L['Professions'], "|cffffffff"..self.character.prof1)
    --GameTooltip_ShowStatusBar(GameTooltip, 0, 300, 245)
    --GameTooltip_ShowProgressBar(GameTooltip, 0, 300, 245)
    GameTooltip:AddDoubleLine(" ", "|cffffffff"..self.character.prof2)
    GameTooltip:Show()
end


function GuildbookRosterListviewItemMixin:OnLeave()
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

function GuildbookRosterListviewItemMixin:SetCharacter(character)
    self.character = character;
    self.ClassIcon:SetAtlas(string.format("GarrMission_ClassIcon-%s", character.class))
    self.ClassIcon:Show()
    self.Name:SetText(character.isOnline and character.name or "|cffB1B3AB"..character.name)
    self.Name:SetText(character.name)
    self.Level:SetText(character.level)
    local mainSpec = false;
    if character.mainSpec == "Bear" then
        mainSpec = "Guardian"
    elseif character.mainSpec == "Cat" then
        mainSpec = "Feral"
    end
    if character.mainSpec ~= "-" then
        self.MainSpecIcon:SetAtlas(string.format("GarrMission_ClassIcon-%s-%s", character.class, mainSpec and mainSpec or character.mainSpec))
        self.MainSpecIcon:Show()
        self.MainSpec:SetText(character.mainSpec)
    else
        self.MainSpecIcon:Hide()
    end
    local prof1 = false;
    if character.prof1 == "Engineering" then -- blizz has a spelling error on this atlasname
        prof1 = "Enginnering";
    end
    if character.prof1 ~= "-" then
        self.Prof1:SetAtlas(string.format("Mobile-%s", prof1 and prof1 or character.prof1))
        self.Prof1:Show()
    else
        self.Prof1:Hide()
    end
    local prof2 = false;
    if character.prof2 == "Engineering" then -- blizz has a spelling error on this atlasname
        prof2 = "Enginnering";
    end
    if character.prof2 ~= "-" then
        self.Prof2:SetAtlas(string.format("Mobile-%s", prof2 and prof2 or character.prof2))
        self.Prof2:Show()
    else
        self.Prof2:Hide()
    end
    self.Location:SetText(character.location)
    self.Rank:SetText(character.rankName)
    self.PublicNote:SetText(character.publicNote)
end

function GuildbookRosterListviewItemMixin:OnMouseDown()
    
end

function GuildbookRosterListviewItemMixin:OnMouseUp()
    
end


--- addon main mixin
GuildbookMixin = {}
GuildbookMixin.selectedProfession = nil;
GuildbookMixin.characterWithProfession = {}
GuildbookMixin.containerItems = {}

local function scanPlayerBags()
    -- player bags
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = select(10, GetContainerItemInfo(bag, slot))
            local count = select(2, GetContainerItemInfo(bag, slot))
            if id and count then
                if not GuildbookUI.containerItems[id] then
                    GuildbookUI.containerItems[id] = count
                else
                    GuildbookUI.containerItems[id] = GuildbookUI.containerItems[id] + count
                end
            end
        end
    end
end

local function scanPlayerBanks(scanBags)
    -- clear all container data if its from the bank
    wipe(GuildbookMixin.containerItems)
    -- main bank
    for slot = 1, 28 do
        local id = select(10, GetContainerItemInfo(-1, slot))
        local count = select(2, GetContainerItemInfo(-1, slot))
        if id and count then
            if not GuildbookUI.containerItems[id] then
                GuildbookUI.containerItems[id] = count
            else
                GuildbookUI.containerItems[id] = GuildbookUI.containerItems[id] + count
            end
        end
    end

    -- bank bags
    for bag = 5, 11 do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = select(10, GetContainerItemInfo(bag, slot))
            local count = select(2, GetContainerItemInfo(bag, slot))
            if id and count then
                if not GuildbookUI.containerItems[id] then
                    GuildbookUI.containerItems[id] = count
                else
                    GuildbookUI.containerItems[id] = GuildbookUI.containerItems[id] + count
                end
            end
        end
    end

    if scanBags == true then
        scanPlayerBags()
    end
end

local function navigateTo(frame)
    for _, f in pairs(GuildbookUI.frames) do
        f:Hide()
    end
    frame:Show()
end

function GuildbookMixin:OnShow()
    GUILD_NAME = gb:GetGuildName()

    scanPlayerBags()
end

function GuildbookMixin:OnLoad()
    self:RegisterForDrag("LeftButton")
    SetPortraitToTexture(GuildbookUIPortrait,134068)
    GuildbookUITitleText:SetText("v0.0.1")

    --GuildbookUIPortrait:SetLevel(self:GetFrameLevel()+10)

    self.menu.isOut = false;

    local agMenuOut = self.menu:CreateAnimationGroup()
    local menuOut = agMenuOut:CreateAnimation("Translation")
    menuOut:SetOffset(-70, 0)
    menuOut:SetDuration(0.3)
    menuOut:SetScript("OnFinished", function()
        self.menu:SetPoint("TOPLEFT", self, "TOPLEFT", -70, -50)
        self.menu.isOut = true;
    end)
    local agMenuIn = self.menu:CreateAnimationGroup()
    local menuIn = agMenuIn:CreateAnimation("Translation")
    menuIn:SetOffset(70, 0)
    menuIn:SetDuration(0.3)
    menuIn:SetScript("OnFinished", function()
        self.menu:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -50)
        self.menu.isOut = false;
    end)

    self.portraitButton:SetScript("OnMouseDown", function()
        if self.menu.isOut == false then
            agMenuOut:Play()
        else
            agMenuIn:Play()
        end
    end)

    self.menu:SetFrameLevel(self:GetFrameLevel() - 1)
    self.menu.profiles.Background:SetTexture(1067386)
    self.menu.profiles.func = function()
        navigateTo(self.profiles)
        -- gb.GuildFrame.ProfilesFrame:ClearAllPoints()
        -- gb.GuildFrame.ProfilesFrame:SetParent(self.profiles)
        -- gb.GuildFrame.ProfilesFrame:SetPoint("BOTTOMLEFT", 0, 0)
        -- gb.GuildFrame.ProfilesFrame:SetPoint("BOTTOMRIGHT", 0, 0)
        -- gb.GuildFrame.ProfilesFrame:SetHeight(450)
        -- gb.GuildFrame.ProfilesFrame:Show()
    end
    self.menu.tradeskills.Background:SetAtlas("Mobile-Blacksmithing")
    self.menu.tradeskills.func = function()
        navigateTo(self.tradeskills)
    end
    self.menu.chat.Background:SetAtlas("socialqueuing-icon-group")
    self.menu.chat.func = function()
        navigateTo(self.chat)
    end
    self.menu.roster.Background:SetAtlas("poi-workorders")
    self.menu.roster.func = function()
        navigateTo(self.roster)
    end

end



GuildbookProfessionListviewMixin = {}
GuildbookProfessionListviewMixin.recipesProcessed = 0;

local professions = {
    { Name = 'Alchemy', Atlas = "Mobile-Alchemy", },
    { Name = 'Blacksmithing', Atlas = "Mobile-Blacksmithing", },
    { Name = 'Enchanting', Atlas = "Mobile-Enchanting", },
    { Name = 'Engineering', Atlas = "Mobile-Enginnering", },
    { Name = 'Inscription', Atlas = "Mobile-Inscription", },
    { Name = 'Jewelcrafting', Atlas = "Mobile-Jewelcrafting", },
    { Name = 'Leatherworking', Atlas = "Mobile-Leatherworking", },
    { Name = 'Tailoring', Atlas = "Mobile-Tailoring", },
    { Name = 'Mining', Atlas = "Mobile-Mining", },
}

local function addRecipe(prof, recipeID, reagents)
    local _link = false;
    local _rarity = false;
    local _enchant = false;
    local _name = false;
    if prof == 'Enchanting' then
        _link = select(1, GetSpellLink(recipeID))
        _rarity = select(3, GetItemInfo(_link)) or 1
        _name = select(1, GetSpellInfo(recipeID)) or 'unknown'
        _enchant = true
        --print(_link, _name)
    else
        _link = select(2, GetItemInfo(recipeID))
        _rarity = select(3, GetItemInfo(recipeID))
        _name = select(1, GetItemInfo(recipeID))
    end
    if not _link and not _rarity and not _name then
        --print('no link')
        GuildbookProfessionListviewMixin.recipesProcessed = GuildbookProfessionListviewMixin.recipesProcessed + 1;
        if prof == 'Enchanting' then                    
            local spell = Spell:CreateFromSpellID(recipeID)
            spell:ContinueOnSpellLoad(function()
                _link = select(1, GetSpellLink(recipeID))
                _name = select(1, GetSpellInfo(recipeID)) or 'unknown'
                _rarity =  1
                _enchant = true
                table.insert(GuildbookUI.tradeskills.recipesListview.recipes, {
                    itemID = recipeID,
                    reagents = reagents,
                    rarity = _rarity,
                    link = _link,
                    enchant = _enchant,
                    name = _name,
                    selected = false,
                })
                GuildbookProfessionListviewMixin.recipesProcessed = GuildbookProfessionListviewMixin.recipesProcessed - 1;
                if GuildbookProfessionListviewMixin.recipesProcessed == 0 then
                    GuildbookUI.tradeskills.recipesListview:LoadRecipes()
                end
            end)
        else
            local item = Item:CreateFromItemID(recipeID)
            item:ContinueOnItemLoad(function()
                _link = item:GetItemLink()
                _rarity = item:GetItemQuality()
                _name = item:GetItemName()
                _enchant = false
                table.insert(GuildbookUI.tradeskills.recipesListview.recipes, {
                    itemID = recipeID,
                    reagents = reagents,
                    rarity = _rarity,
                    link = _link,
                    enchant = _enchant,
                    name = _name,
                    selected = false,
                })
                GuildbookProfessionListviewMixin.recipesProcessed = GuildbookProfessionListviewMixin.recipesProcessed - 1;
                if GuildbookProfessionListviewMixin.recipesProcessed == 0 then
                    GuildbookUI.tradeskills.recipesListview:LoadRecipes()
                end
            end)
        end
    else
        --print('got link')
        table.insert(GuildbookUI.tradeskills.recipesListview.recipes, {
            itemID = recipeID,
            reagents = reagents,
            rarity = _rarity,
            link = _link,
            enchant = _enchant,
            name = _name,
            selected = false,
        })
        --GuildbookProfessionListviewMixin.recipesProcessed = GuildbookProfessionListviewMixin.recipesProcessed - 1;
        if GuildbookProfessionListviewMixin.recipesProcessed == 0 then
            GuildbookUI.tradeskills.recipesListview:LoadRecipes()
        end
    end
end

function GuildbookProfessionListviewMixin:OnLoad()
    for i, prof in ipairs(professions) do
        local f = CreateFrame("FRAME", "GuildbookUiProfessionListview"..i, self, "GuildbookListviewItem")
        f:SetSize(175, 45)
        f:SetPoint("TOP", 0, ((i-1)*-45)-2)
        f:SetItem(prof)
        f.func = function()
            wipe(GuildbookMixin.characterWithProfession)
            GuildbookProfessionListviewMixin.recipesProcessed = 0;
            GuildbookMixin.selectedProfession = prof.Name;
            for guid, character in pairs(GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME]) do
                if character.Profession1 and character.Profession1 == prof.Name then
                    table.insert(GuildbookMixin.characterWithProfession, guid)
                elseif character.Profession2 and character.Profession2 == prof.Name then
                    table.insert(GuildbookMixin.characterWithProfession, guid)
                end
            end
            scanPlayerBags()
            if #GuildbookMixin.characterWithProfession > 0 then
                wipe(GuildbookUI.tradeskills.recipesListview.recipes)
                local recipes = {}
                for k, guid in ipairs(GuildbookMixin.characterWithProfession) do
                    local character = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid]
                    if character[prof.Name] and next(character[prof.Name]) then
                        for itemID, reagents in pairs(character[prof.Name]) do
                            if not recipes[itemID] then
                                recipes[itemID] = true;
                                addRecipe(prof.Name, itemID, reagents)
                            end
                        end
                    end
                end
            end
        end
    end
end

function GuildbookProfessionListviewMixin:OnShow()

end




GuildbookRecipesListviewMixin = {}
GuildbookRecipesListviewMixin.rows = {}
GuildbookRecipesListviewMixin.recipes = {}

local function getPlayersWithRecipe(recipeID)
    if not recipeID then
        return
    end
    local characters = {}
    for k, guid in ipairs(GuildbookMixin.characterWithProfession) do
        local character = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid]
        if character[GuildbookMixin.selectedProfession] then
            if character[GuildbookMixin.selectedProfession][recipeID] then
                local _online, _zone = gb:IsGuildMemberOnline(character.Name)
                table.insert(characters, {
                    name = character.Name,
                    guid = guid,
                    online = _online,
                    zone = _zone,
                    race = character.Race,
                    gender = character.Gender,
                })
            end
        end
    end
    table.sort(characters, function(a,b)
        return a.online and not b.online;
    end)
    return characters;
end

local NUM_RECIPE_ROWS = 17

function GuildbookRecipesListviewMixin:OnLoad()
    for row = 1, NUM_RECIPE_ROWS do
        local f = CreateFrame("FRAME", "GuildbookUiRecipesListview"..row, self, "GuildbookRecipeListviewItem")
        f:SetSize(480, 24)
        f:SetPoint("TOPLEFT", 5, ((row - 1) * -24) - 2)
        for _, reagent in ipairs(f.reagentIcons) do
            local _, size, flags = reagent.count:GetFont()
            reagent.count:SetFont([[Interface\Addons\Guildbook\Media\Fonts\Acme-Regular.ttf]], 14, flags)
        end
        f.func = function()
            if f.model then
                local s = f.model.selected;
                self:ClearSelected()
                f.model.selected = not s;
                if f.model.selected == true then
                    f.Selected:Show()
                end
            end
            local characters = getPlayersWithRecipe(f.recipeID)
            GuildbookCharactersListviewMixin:ClearRows()
            for k, character in ipairs(characters) do
                GuildbookCharactersListviewMixin.rows[k]:SetCharacter(character, f.link)
            end
        end
        self.rows[row] = f
    end
    self.scrollBar:SetValueStep(1)
    self.scrollBar:SetMinMaxValues(1,1)
end

function GuildbookRecipesListviewMixin:ClearSelected()
    if self.recipes and next(self.recipes) then
        for _, recipe in ipairs(self.recipes) do
            recipe.selected = false;
        end
    end
    for _, row in ipairs(self.rows) do
        row.Selected:Hide()
    end
end

function GuildbookRecipesListviewMixin:ClearRows()
    for _, row in ipairs(self.rows) do
        row.Text:SetText("")
        row.link = nil;
        row.enchant = nil;
        row.recipeID = nil;
        row:ClearReagents()
    end
end

function GuildbookRecipesListviewMixin:LoadRecipes()
    self:ClearRows()
    if self.recipes and next(self.recipes) then
        --this is to trigger a refresh by calling the scroll value changed func
        self.scrollBar:SetMinMaxValues(1,2)
        self.scrollBar:SetValue(2)
        self.scrollBar:SetValue(1)
        C_Timer.After(0, function()
            self.scrollBar:SetValue(2)
            self.scrollBar:SetValue(1)
        end)
        table.sort(self.recipes, function(a,b)
            if a.rarity == b.rarity then
                return a.name < b.name
            else
                return a.rarity > b.rarity;
            end
        end)
        self.scrollBar:SetMinMaxValues(1,(#self.recipes>NUM_RECIPE_ROWS) and #self.recipes-(NUM_RECIPE_ROWS-1) or 1)
        self.scrollBar:SetValue(1)
    end
end

function GuildbookRecipesListviewMixin:ScrollBar_OnValueChanged()
    if #self.recipes > 0 then
        local scrollPos = math.floor(self.scrollBar:GetValue()) - 1;
        for row = 1, NUM_RECIPE_ROWS do
            if self.recipes[scrollPos + row] then
                self.rows[row].model = self.recipes[scrollPos + row]
                if self.recipes[scrollPos + row].selected == true then
                    self.rows[row].Selected:Show()
                else
                    self.rows[row].Selected:Hide()
                end
                self.rows[row].Text:SetText(self.recipes[scrollPos + row].link)
                self.rows[row].enchant = self.recipes[scrollPos + row].enchant;
                self.rows[row].recipeID = self.recipes[scrollPos + row].itemID;
                self.rows[row].link = self.recipes[scrollPos + row].link;
                self.rows[row]:ClearReagents()
                local i = 1;
                for reagentID, count in pairs(self.recipes[scrollPos + row].reagents) do
                    if self.rows[row].reagentIcons[i] then
                        if GuildbookUI.containerItems[reagentID] then
                            if GuildbookUI.containerItems[reagentID] >= count then
                                self.rows[row].reagentIcons[i].greenBorder:Show()
                            elseif GuildbookUI.containerItems[reagentID] < count then
                                self.rows[row].reagentIcons[i].purpleBorder:Show()
                            end
                        else
                            self.rows[row].reagentIcons[i].orangeBorder:Show()
                        end
                        self.rows[row].reagentIcons[i]:SetItem(reagentID)
                        self.rows[row].reagentIcons[i].count:SetText(count)
                        i = i + 1;
                    end
                end
            end
        end
    end
end

function GuildbookRecipesListviewMixin:OnMouseWheel(delta)
    local x = self.scrollBar:GetValue()
    self.scrollBar:SetValue(x - delta)
end


GuildbookCharactersListviewMixin = {}
GuildbookCharactersListviewMixin.rows = {}

function GuildbookCharactersListviewMixin:OnLoad()
    for i = 1, 9 do
        local f = CreateFrame("FRAME", "GuildbookUiCharactersListview"..i, self, "GuildbookCharacterListviewItem")
        f:SetPoint("TOP", 0, ((i-1)*-45)-2)
        f:SetSize(195, 45)

        GuildbookCharactersListviewMixin.rows[i] = f;
    end
end


function GuildbookCharactersListviewMixin:ClearRows()
    for _, row in ipairs(self.rows) do
        row:ClearCharacter()
    end
end


function GuildbookCharactersListviewMixin:ScrollBar_OnValueChanged()

end



GuildbookRosterMixin = {}
GuildbookRosterMixin.rows = {}
GuildbookRosterMixin.roster = {}
local NUM_ROSTER_ROWS = 14;

function GuildbookRosterMixin:OnLoad()
    local animDur, animDelay = 0.75, 0.01
    for i = 1, 14 do
        local f = CreateFrame("FRAME", "GuildbookUiCharactersListview"..i, self.memberListview, "GuildbookRosterListviewItem")
        --f:SetPoint("TOPLEFT", 5, ((i-2)*-29)-2)
        --f:SetPoint("TOPLEFT", 5, 0)
        f:SetSize(880, 29)
        --f:SetAlpha(1)
        f:Hide()

        f.rowAnim = f:CreateAnimationGroup()
        f.rowAnim:SetToFinalAlpha(true)
        local trans = f.rowAnim:CreateAnimation("Translation")
        trans:SetOffset(0, ((i-1)*-29))
        trans:SetDuration(animDur)
        trans:SetStartDelay(animDelay*0.5)
        trans:SetSmoothing("OUT")
        trans:SetScript("OnFinished", function()
            f:SetPoint("TOPLEFT", f:GetParent(), "TOPLEFT", 5, ((i-1)*-29)-2)
        end)
        --trans:SetOrder(1)

        -- local scaler = f.rowAnim:CreateAnimation("Scale")
        -- scaler:SetOrigin("TOPLEFT", 5, ((i-1)*-29)-2)
        -- scaler:SetFromScale(1,0)
        -- scaler:SetToScale(1,1)
        -- scaler:SetDuration(animDur)
        -- scaler:SetStartDelay(animDelay/i)
        -- scaler:SetSmoothing("OUT")
        -- local function smoothScale(self)
        --     local x = self:GetSmoothProgress()
        --     local k = (x^(x* 0.05))
        --     self:SetSmoothProgress(k)
        --  end
        -- scaler:SetScript("OnUpdate", smoothScale)
        --scaler:SetOrder(2)

        local fade = f.rowAnim:CreateAnimation("Alpha")
        fade:SetFromAlpha(0)
        fade:SetToAlpha(1)
        fade:SetDuration(animDur)
        fade:SetStartDelay(animDelay*0.5)
        fade:SetSmoothing("OUT")
        --fade:SetOrder(3)

        GuildbookRosterMixin.rows[i] = f;
    end

    for _, button in pairs(self.sortButtons) do
        button:SetText(L[button.sort])
        button.order = true
        button:SetScript("OnClick", function()            
            self:SortRoster(button.sort, button.order)
            button.order = not button.order;
        end)
    end
end

function GuildbookRosterMixin:OnShow()
    GUILD_NAME = gb:GetGuildName()
    if not self.roster[1] then
        self:ParseGuildRoster()
    end
end

function GuildbookRosterMixin:ParseGuildRoster()
    self.characterStatus = {}
    local totalMembers, _, _ = GetNumGuildMembers()
    for i = 1, totalMembers do
        local name, _rankName, _, _, _, _zone, _publicNote, _officerNote, _isOnline, _, _, achievementPoints, _, _, _, _, GUID = GetGuildRosterInfo(i)
        name = Ambiguate(name, 'none')
        self.characterStatus[GUID] = {
            isOnline = _isOnline,
            zone = _zone,
            publicNote = _publicNote,
            officerNote = _officerNote,
            rankName = _rankName,
        }
        if i == totalMembers then
            self:LoadCharacters()
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
    end
end

function GuildbookRosterMixin:PlayRowAnim()
    for i, row in ipairs(self.rows) do
        row:Hide()
        row:SetPoint("TOPLEFT", 5, -2)
        row:SetAlpha(0)
        row:Show()
        row.rowAnim:Play()
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
        table.insert(self.roster, {
            guid = guid,
            class = _class,
            race = character.Race,
            gender = character.Gender,
            name = character.Name,
            level = character.Level,
            mainSpec = character.MainSpec or "-",
            prof1 = character.Profession1 or "-",
            prof2 = character.Profession2 or "-",
            selected = false,
            isOnline = self.characterStatus[guid].isOnline,
            location = self.characterStatus[guid].zone or "-",
            rankName = self.characterStatus[guid].rankName,
            publicNote = self.characterStatus[guid].publicNote,
            officernote = self.characterStatus[guid].officerNote,
        })
        if i == numChars then
            self:ForceRosterListviewRefresh()
        else
            i = i + 1;
        end
    end
end

function GuildbookRosterMixin:ForceRosterListviewRefresh()
    self:PlayRowAnim()
    if self.roster and next(self.roster) then
        --this is to trigger a refresh by calling the scroll value changed func
        self.memberListview.scrollBar:SetMinMaxValues(1,2)
        self.memberListview.scrollBar:SetValue(2)
        self.memberListview.scrollBar:SetValue(1)
        C_Timer.After(0, function()
            self.memberListview.scrollBar:SetValue(2)
            self.memberListview.scrollBar:SetValue(1)
        end)
        table.sort(self.roster, function(a,b)
            if a.level == b.level then
                return a.name < b.name
            else
                return a.level > b.level;
            end
        end)
        self.memberListview.scrollBar:SetMinMaxValues(1,(#self.roster>NUM_ROSTER_ROWS) and #self.roster-(NUM_ROSTER_ROWS-1) or 1)
        self.memberListview.scrollBar:SetValue(1)
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
                local i = 1;
            end
        end
    end
end

function GuildbookRosterMixin:OnMouseWheel(delta)
    local x = self.memberListview.scrollBar:GetValue()
    self.memberListview.scrollBar:SetValue(x - delta)
end

function GuildbookRosterMixin:SortRoster(sort, order)
    if self.roster and next(self.roster) then
        --this is to trigger a refresh by calling the scroll value changed func
        self.memberListview.scrollBar:SetMinMaxValues(1,2)
        self.memberListview.scrollBar:SetValue(2)
        self.memberListview.scrollBar:SetValue(1)
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
    InviteToGroup(row.character.name)
end

function GuildbookRosterMixin:RowOpenToChat_OnMouseDown(row)
    navigateTo(self:GetParent().chat)
    local target = Ambiguate(row.character.name, "none");
    self:GetParent().chat.target = target;
    self:GetParent().chat.channel = "WHISPER"
    self:GetParent().chat.chatID = row.character.guid
    self:GetParent().chat.currentChat:SetText(target)

    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end


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
        f:SetSize(450, 44)
        f:Hide()
        f.Message:SetSize(400, 44)
        f.Message:SetNonSpaceWrap(true)

        f.mask = f:CreateMaskTexture()
        f.mask:SetSize(40,40)
        f.mask:SetPoint("RIGHT", -2, 0)
        f.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        f.Icon:AddMaskTexture(f.mask)

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
                print(i, chatID, "no chat")
            end
        end
    end
end


GuildbookChatContentMixin = {}
GuildbookChatContentMixin.rows = {}
GuildbookChatContentMixin.messages = {}

function GuildbookChatContentMixin:ClearRows()
    for i = 1, 9 do
        self.rows[i]:Hide()
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

function GuildbookChatContentMixin:ChatContentScrollBar_OnValueChanged()
    if not self.messages then
        return;
    end
    if not next(self.messages) then
        return;
    end
    local scrollPos = math.floor(self.scrollBar:GetValue())
    for i = 1, 9 do
        self.rows[i]:Hide()
        self.rows[i].Message:SetText("")
        self.rows[i].Icon:SetTexture(nil)
        if self.messages[i+scrollPos-1] then
            local msg = self.messages[i+scrollPos-1]
            self.rows[i]:Show()
            self.rows[i].Message:SetText(msg.formattedMessage)

            self.rows[i].sender = msg.sender

            --print(i, msg.sender, msg.chatID)

            if GUILD_NAME and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][msg.senderGUID] then
                local character = GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][msg.senderGUID]
                self.rows[i].Icon:SetAtlas(string.format("raceicon-%s-%s", character.Race:lower(), character.Gender:lower()))
            else
                self.rows[i].Icon:SetTexture(1067180)
            end

            if Ambiguate(msg.sender, "none") == Ambiguate(UnitName("player"), "none") then
                --print("we have a message from ourself", msg.sender, msg.message)
                self.rows[i].Icon:ClearAllPoints()
                self.rows[i].Icon:SetPoint("RIGHT", 0, 0)
                self.rows[i].Message:ClearAllPoints()
                self.rows[i].Message:SetPoint("LEFT", 0, 0)
                self.rows[i].Message:SetJustifyH("RIGHT")
                self.rows[i].mask:ClearAllPoints()
                self.rows[i].mask:SetPoint("RIGHT", -2, 0)
                self.rows[i]:ClearAllPoints()
                self.rows[i]:SetPoint("TOPRIGHT", 0, (i-1) * -45)
            else
                --print("we have a message NOT from ourself", msg.sender, msg.message)
                self.rows[i].Icon:ClearAllPoints()
                self.rows[i].Icon:SetPoint("LEFT", 0, 0)
                self.rows[i].Message:ClearAllPoints()
                self.rows[i].Message:SetPoint("LEFT", 50, 0)
                self.rows[i].Message:SetJustifyH("LEFT")
                self.rows[i].mask:ClearAllPoints()
                self.rows[i].mask:SetPoint("LEFT", 2, 0)
                self.rows[i]:ClearAllPoints()
                self.rows[i]:SetPoint("TOPLEFT", 0, (i-1) * -45)
            end
            C_Timer.After(0.1, function()
                for x = 1, 10 do
                    if self.rows[i].Message:IsTruncated() then
                        self.rows[i]:SetWidth(self.rows[i]:GetWidth() * 1.01)
                        self.rows[i].Message:SetWidth(self.rows[i].Message:GetWidth()*1.01)
                    end
                end
                -- while self.rows[i].Message:IsTruncated() do
                --     local w = self.rows[i].Message:GetWidth()
                --     self.rows[i].Message:SetWidth(w)
                --     self.rows[i]:SetWidth(w + 50)
                --     -- local w, h = self.rows[i].Message:GetWidth(), 45 -- self.rows[i].Message:GetHeight()
                --     -- if w > 600 then
                --     --     self.rows[i].Message:SetSize(w, h) -- * 1.1)
                --     --     self.rows[i]:SetSize(w + 50, h) -- + 10)
                --     -- else
                --     --     self.rows[i].Message:SetSize(w * 1.1, h)
                --     --     self.rows[i]:SetSize(w + 50, h) -- + 10)
                --     -- end
                -- end
            end)
        end
    end
end