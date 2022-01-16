--[==[

Copyright ©2022 Samuel Thomas Pain

The contents of this addon, excluding third-party resources, are
copyrighted to their authors with all rights reserved.

This addon is free to use and the authors hereby grants you the following rights:

1. 	You may make modifications to this addon for private use only, you
    may not publicize any portion of this addon.

2. 	Do not modify the name of this addon, including the addon folders.

3. 	This copyright notice shall be included in all copies or substantial
    portions of the Software.

All rights not explicitly addressed in this license are reserved by
the copyright holders.

]==]--


local _, gb = ...
local L = gb.Locales


--- basic button mixin
GuildbookSmallHighlightButtonMixin = {}

function GuildbookSmallHighlightButtonMixin:OnLoad()
    --self.anchor = AnchorUtil.CreateAnchor(self:GetPoint());

    self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs = self:GetPoint()
end

function GuildbookSmallHighlightButtonMixin:OnShow()
    --self.anchor:SetPoint(self);
    if self.point and self.relativeTo and self.relativePoint and self.xOfs and self.yOfs then
        self:SetPoint(self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs)
    end
end

function GuildbookSmallHighlightButtonMixin:OnMouseDown()
    if self.disabled then
        return;
    end
    self:AdjustPointsOffset(-1,-1)
end

function GuildbookSmallHighlightButtonMixin:OnMouseUp()
    if self.disabled then
        return;
    end
    self:AdjustPointsOffset(1,1)
    if self.func then
        C_Timer.After(0, self.func)
    end
end

function GuildbookSmallHighlightButtonMixin:OnEnter()

    if self.tooltipText and L[self.tooltipText] then
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        GameTooltip:AddLine("|cffffffff"..L[self.tooltipText])
        --GameTooltip:Show()

    elseif self.tooltipText and not L[self.tooltipText] then
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        GameTooltip:AddLine(self.tooltipText)
        --GameTooltip:Show()

    elseif self.link then
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        GameTooltip:SetHyperlink(self.link)
        --GameTooltip:Show()
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end

    -- if type(self.tooltipStatusBar) == "table" then
    --     if type(self.tooltipStatusBar.min) == "number" and type(self.tooltipStatusBar.max) =="number" and type(self.tooltipStatusBar.val) == "number" then
    --         GameTooltip_ShowStatusBar(GameTooltip, self.tooltipStatusBar.min, self.tooltipStatusBar.max, self.tooltipStatusBar.val)
    --     end
    -- end

    GameTooltip:Show()
end

function GuildbookSmallHighlightButtonMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end


function GuildbookSmallHighlightButtonMixin:SetTradeskillAtlas(tradeskill)

    if type(tradeskill) == "string" and gb.Tradeskills.TradeskillNames[tradeskill] then
        if tradeskill == "Engineering" then
            self.icon:SetAtlas("Mobile-Enginnering")
        else
            self.icon:SetAtlas(string.format("Mobile-%s", tradeskill))
        end
    end
end


function GuildbookSmallHighlightButtonMixin:ClearAtlas()
    self.icon:SetAtlas(nil)
end







--- basic button with an icon and text area
GuildbookListviewItemMixin = {}

function GuildbookListviewItemMixin:OnLoad()
    -- local _, size, flags = self.Text:GetFont()
    -- self.Text:SetFont([[Interface\Addons\Guildbook\Media\Fonts\Acme-Regular.ttf]], size+4, flags)
end

function GuildbookListviewItemMixin:SetItem(info)
    self.Icon:SetAtlas(info.Atlas)
    self.Text:SetText(gb.Tradeskills.TradeskillIDsToLocaleName[GetLocale()][info.id])
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

function GuildbookItemIconFrameMixin:OnMouseDown()
    if self.link and IsShiftKeyDown() then
        HandleModifiedItemClick(self.link)
    end
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



GuildbookSearchResultMixin = {}

function GuildbookSearchResultMixin:OnMouseDown()
    if self.func then
        C_Timer.After(0, self.func)
    end
end

function GuildbookSearchResultMixin:OnEnter()
    if self.link and self.link:find("|Hitem") then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetHyperlink(self.link)
        GameTooltip:Show()
    else
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:AddLine(self.link)
        GameTooltip:Show()
    end
end

function GuildbookSearchResultMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookSearchResultMixin:ClearRow()
    self.icon:SetTexture(nil)
    self.text:SetText(nil)
    self.info:SetText(nil)
    self.link = nil;
    self.func = nil;
end

function GuildbookSearchResultMixin:SetResult(info)
    self.text:SetText("")
    self.info:SetText("")
    self.link = nil
    self.func = nil
    if not info then
        return;
    end
    if info.iconType == "fileID" then
        self.icon:SetTexture(info.icon)
    else
        self.icon:SetAtlas(info.icon)
    end
    self.text:SetText(info.title)
    self.info:SetText(info.info)
    self.link = info.title;
    self.func = info.func;
end


--- custom dropdown widget supporting a single menu layer
GuildbookDropDownFrameMixin = {}
local DROPDOWN_CLOSE_DELAY = 2.0


-- this is the dropdown button mixin, all that needs to happen is set the text and call any func if passed
GuildbookDropDownFlyoutButtonMixin = {}

function GuildbookDropDownFlyoutButtonMixin:OnEnter()

end

function GuildbookDropDownFlyoutButtonMixin:OnLeave()

end

function GuildbookDropDownFlyoutButtonMixin:SetText(text)
    self.Text:SetText(text)
end

function GuildbookDropDownFlyoutButtonMixin:GetText(text)
    return self.Text:GetText()
end

function GuildbookDropDownFlyoutButtonMixin:OnMouseDown()
    local text = self.Text:GetText()
    if self.func then
        self:func()
        if self:GetParent():GetParent().MenuText then
            self:GetParent():GetParent().MenuText:SetTextColor(1,1,1,1)
            self:GetParent():GetParent().MenuText:SetText(text)
        end
    end
    if self:GetParent().delay then
        self:GetParent().delay:Cancel()
    end
    self:GetParent():Hide()
end





GuildbookTradeSkillItemsListviewMixin = {}
function GuildbookTradeSkillItemsListviewMixin:OnLoad()
    self.DataProvider = CreateDataProvider();
    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(24); -- item height
    self.ScrollView:SetElementInitializer("Button", "GuildbookRecipeListviewItem", function(frame, elementData)
        frame:Init(elementData)
    end);
    self.ScrollView:SetPadding(5, 5, 5, 5, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, "BOTTOMLEFT", 0, 4),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithBar, anchorsWithoutBar);
end





GuildbookTradeSkillItemsCharacterListviewMixin = {}
function GuildbookTradeSkillItemsCharacterListviewMixin:OnLoad()
    self.DataProvider = CreateDataProvider();
    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(45); -- item height
    self.ScrollView:SetElementInitializer("Button", "GuildbookTradeskillCharacterListviewItem", function(frame, elementData)
        frame:SetCharacter(elementData)
    end);
    self.ScrollView:SetPadding(5, 5, 5, 5, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, "BOTTOMLEFT", 0, 4),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithBar, anchorsWithoutBar);
end




GuildbookCalendarAttendingListviewMixin = {}
function GuildbookCalendarAttendingListviewMixin:OnLoad()
    self.DataProvider = CreateDataProvider();
    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(14); -- item height
    self.ScrollView:SetElementInitializer("FRAME", "GuildbookCalendarAttendingListviewItemTemplate", function(frame, elementData)
        frame.name:SetText(elementData.name)
        frame.status:SetText(elementData.status)
    end);
    self.ScrollView:SetPadding(5, 5, 5, 5, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, "BOTTOMLEFT", 0, 4),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithBar, anchorsWithoutBar);
end



-- if we need to get the flyout although its a child so can be accessed via dropdown.Flyout
GuildbookDropdownMixin = {}

function GuildbookDropdownMixin:GetFlyout()
    return self.Flyout
end

function GuildbookDropdownMixin:OnLoad()
    self:SetSize(self:GetWidth(), self:GetHeight())
    if self.Background then
        self.Background:SetSize(self:GetWidth(), self:GetHeight())
    end
    self.Button:SetHeight(self:GetHeight())

    if not gb.dropdownWidgets then
        gb.dropdownWidgets = {}
    end
    table.insert(gb.dropdownWidgets, self)
end

function GuildbookDropdownMixin:OnShow()
    --local width = self:GetWidth()
end




GuildbookDropdownButtonMixin = {}

function GuildbookDropdownButtonMixin:OnEnter()
    self.ButtonHighlight:Show()
end

function GuildbookDropdownButtonMixin:OnLeave()
    self.ButtonHighlight:Hide()
end

function GuildbookDropdownButtonMixin:OnMouseDown()

    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

    self.ButtonUp:Hide()
    self.ButtonDown:Show()

    if gb.dropdownWidgets and #gb.dropdownWidgets > 0 then -- quick fix, need to make sure all dropdowns/flyouts are in table
        for k, dd in ipairs(gb.dropdownWidgets) do
            dd.Flyout:Hide()
        end
    end

    local flyout = self:GetParent().Flyout
    if flyout:IsVisible() then
        flyout:Hide()
    else
        flyout:Show()
    end
end

function GuildbookDropdownButtonMixin:OnMouseUp()
    self.ButtonDown:Hide()
    self.ButtonUp:Show()
end



local frameBackdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 }
}
GuildbookDropdownFlyoutMixin = {}

function GuildbookDropdownFlyoutMixin:OnLoad()
    if not gb.dropdownFlyouts then
        gb.dropdownFlyouts = {}
    end
    table.insert(gb.dropdownFlyouts, self)
    --self:SetBackdrop(frameBackdrop)
end

function GuildbookDropdownFlyoutMixin:OnLeave()
    self.delay = C_Timer.NewTicker(DROPDOWN_CLOSE_DELAY, function()
        if not self:IsMouseOver() then
            self:Hide()
        end
    end)
end

function GuildbookDropdownFlyoutMixin:OnShow()

    for k, flyout in ipairs(gb.dropdownFlyouts) do
        flyout:Hide()
    end
    self:Show()

    self:SetFrameStrata("DIALOG")

    if self.delay then
        self.delay:Cancel()
    end

    self.delay = C_Timer.NewTicker(self.delayTimer or DROPDOWN_CLOSE_DELAY, function()
        if not self:IsMouseOver() then
            self:Hide()
        end
    end)

    -- the .menu needs to a table that mimics the blizz dropdown
    -- t = {
    --     text = buttonText,
    --     func = functionToRun,
    -- }
    local maxWidth = 100;
    if self:GetParent().menu then
        if not self.buttons then
            self.buttons = {}
        end
        for i = 1, #self.buttons do
            self.buttons[i]:SetText("")
            self.buttons[i].func = nil
            self.buttons[i].updateText = nil;
            self.buttons[i]:Hide()
        end
        for buttonIndex, info in ipairs(self:GetParent().menu) do
            if not self.buttons[buttonIndex] then
                self.buttons[buttonIndex] = CreateFrame("FRAME", nil, self, "GuildbookDropDownButton")
                self.buttons[buttonIndex]:SetPoint("TOP", 0, (buttonIndex * -22) + 22)
            end
            self.buttons[buttonIndex]:SetText(info.text)

            local w = self.buttons[buttonIndex].Text:GetWidth()
            if w > maxWidth then
                self:SetWidth(w + 4)
                maxWidth = w;
            end

            self.buttons[buttonIndex].updateText = info.updateText;
            self.buttons[buttonIndex].func = info.func;
            self.buttons[buttonIndex]:Show()

            buttonIndex = buttonIndex + 1
        end
        for i = 1, #self.buttons do
            self.buttons[i]:SetWidth(self:GetWidth() - 2)
        end
        self:SetHeight((#self.buttons * 22))
    end
end




GuildbookProfileSummaryRowAvatarTemplateMixin = {}

function GuildbookProfileSummaryRowAvatarTemplateMixin:SetCharacter(guid)
    if not guid then
        return
    end
    self.character = gb:GetCharacterFromCache(guid)
    if not self.character then
        return
    end
    if self.character.profile and self.character.profile.avatar then
        self.avatar:SetTexture(self.character.profile.avatar)
    else
        self.avatar:SetAtlas(string.format("raceicon-%s-%s", self.character.Race, self.character.Gender))
    end
    self.name:SetText(gb.Data.Class[self.character.Class:upper()].FontColour..self.character.Name)
    local rgb = gb.Data.Class[self.character.Class].RGB
    self.border:SetVertexColor(rgb[1], rgb[2], rgb[3])
end

function GuildbookProfileSummaryRowAvatarTemplateMixin:OnEnter()
    if self.playAnim then
        if self:IsVisible() then
            self.whirl:Show()
            self.anim:Play()
        end
    else
        self.whirl:Hide()
    end
    if self.showTooltip then
        
    end
end

function GuildbookProfileSummaryRowAvatarTemplateMixin:OnLeave()
    self.anim:Stop()
end

function GuildbookProfileSummaryRowAvatarTemplateMixin:OnMouseUp()
    if self.character then
        GuildbookUI.profiles.character = self.character
        if GuildbookUI.profiles.character then
            GuildbookUI.profiles:LoadCharacter()
        end
    end
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









GuildbookAvatarMixin = {}

function GuildbookAvatarMixin:OnLoad()

end

function GuildbookAvatarMixin:OnMouseDown()
    if self.func then
        self.func()
    end
end












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














---this is the listview template mixin
GuildbookListviewMixin = CreateFromMixins(CallbackRegistryMixin);
GuildbookListviewMixin:GenerateCallbackEvents(
    {
        "OnSelectionChanged",
    }
);

function GuildbookListviewMixin:OnLoad()

    ---these values are set in the xml frames KeyValues, it allows us to reuse code by setting listview item values in xml
    if type(self.itemTemplate) ~= "string" then
        error("self.itemTemplate name not set or not of type string")
        return;
    end
    if type(self.frameType) ~= "string" then
        error("self.frameType not set or not of type string")
        return;
    end
    if type(self.elementHeight) ~= "number" then
        error("self.elementHeight not set or not of type number")
        return;
    end

    CallbackRegistryMixin.OnLoad(self)

    self.DataProvider = CreateDataProvider();
    self.scrollView = CreateScrollBoxListLinearView();
    self.scrollView:SetDataProvider(self.DataProvider);

    ---height is defined in the xml keyValues
    local height = self.elementHeight;
    self.scrollView:SetElementExtent(height);

    self.scrollView:SetElementInitializer(self.frameType, self.itemTemplate, GenerateClosure(self.OnElementInitialize, self));
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollView);
    self.selectionBehavior:RegisterCallback("OnSelectionChanged", self.OnElementSelectionChanged, self);

    self.scrollView:SetPadding(5, 5, 5, 5, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", 0, 4),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.scrollBox, self.scrollBar, anchorsWithBar, anchorsWithoutBar);
end

function GuildbookListviewMixin:OnElementInitialize(element, elementData, isNew)
    if isNew then
        --Mixin(element, GuildbookBasicListviewTemplateMixin); -- i think this will reduce reusability of the listview
        element:OnLoad();
    end

    -- if self.scrollToEnd == true then
    --     self.scrollBox:ScrollToEnd(ScrollBoxConstants.NoScrollInterpolation);
    -- end

    local height = self.elementHeight;

    element:SetDataBinding(elementData, height);
    element:RegisterCallback("OnMouseDown", self.OnElementClicked, self);

end

function GuildbookListviewMixin:OnElementReset(element)
    element:UnregisterCallback("OnMouseDown", self);

    element:ResetDataBinding()
end

function GuildbookListviewMixin:OnElementClicked(element)
    self.selectionBehavior:Select(element);
end

function GuildbookListviewMixin:OnDataTableChanged(newTable)
    for k, elementData in ipairs(newTable) do

    end
end

function GuildbookListviewMixin:OnElementSelectionChanged(elementData, selected)
    --DevTools_Dump({ self.selectionBehavior:GetSelectedElementData() })

    local element = self.scrollView:FindFrame(elementData);

    if element then
        element:SetSelected(selected);
    end

    if selected then
        self:TriggerEvent("OnSelectionChanged", elementData, selected);
    end
end









GuildbookNewsFeedItemTemplateMixin = CreateFromMixins(CallbackRegistryMixin);
GuildbookNewsFeedItemTemplateMixin:GenerateCallbackEvents(
    {
        "OnMouseDown",
    }
);

function GuildbookNewsFeedItemTemplateMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self);
    self:SetScript("OnMouseDown", self.OnMouseDown);
end

function GuildbookNewsFeedItemTemplateMixin:OnMouseDown()
    self:TriggerEvent("OnMouseDown", self);

    print(self.text:GetText())
end

function GuildbookNewsFeedItemTemplateMixin:OnMouseUp()

end

function GuildbookNewsFeedItemTemplateMixin:SetSelected(selected)
    if self.selected then
        self.selected:SetShown(selected)
    end
end

function GuildbookNewsFeedItemTemplateMixin:SetDataBinding(binding, height)

    if type(height) == "number" then
        self:SetHeight(height)
    end

    if binding.newsType == "lfg" then
        self.icon:SetAtlas("socialqueuing-icon-eye")
        self.icon:SetSize(height-2, height-1)

    elseif binding.newsType == "calendarEventCreated" then
        self.icon:SetAtlas("questdaily")
        self.icon:SetSize(height-2, height-1)

    elseif binding.newsType == "login" then
        self.icon:SetAtlas("poi-door-right")
        self.icon:SetSize(height-2, height-1)

    elseif binding.newsType == "logout" then
        self.icon:SetAtlas("poi-door-left")
        self.icon:SetSize(height-2, height-1)

    elseif binding.newsType == "playerJoinedGuild" then
        --self.icon:SetAtlas("glueannouncementpopup-icon-info")
        self.icon:SetAtlas("communities-icon-addchannelplus")
        self.icon:SetSize(height-2, height-1)

    elseif binding.newsType == "guildChat" then
        self.icon:SetAtlas(nil)
        self.icon:SetSize(1, height)

    end

    if binding.text then
        self.text:SetText(binding.text)
    end
end


function GuildbookNewsFeedItemTemplateMixin:ResetDataBinding()

end


















---this is the mixin for the character list on the home tab
GuildbookHomeMembersListviewItemTemplateMixin = CreateFromMixins(CallbackRegistryMixin);
GuildbookHomeMembersListviewItemTemplateMixin:GenerateCallbackEvents(
    {
        "OnMouseDown", -- this is so we can notify the listview that an element was clicked
        "OnTradeskillClicked",
        "OnMemberStatusChanged",
    }
);
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon = CreateFrame("FRAME", "GuildbookRosterListviewItemTooltipIcon")
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon:SetSize(24, 24)
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.icon = GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon:CreateTexture(nil, "BACKGROUND")
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.icon:SetPoint("CENTER", 0, 0)
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.icon:SetSize(56, 56)
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.mask = GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon:CreateMaskTexture()
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.mask:SetSize(50,50)
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.mask:SetPoint("CENTER", 0, 0)
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.icon:AddMaskTexture(GuildbookHomeMembersListviewItemTemplateMixin.tooltipIcon.mask)

function GuildbookHomeMembersListviewItemTemplateMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self);

    self:RegisterCallback("OnTradeskillClicked", gb.Tradeskills.LoadGuildMemberTradeskills, gb.Tradeskills)

    gb.Roster:RegisterCallback("OnMemberStatusChanged", self.UpdateStatus, self)
    gb.Database:RegisterCallback("OnCharacterTableChanged", self.UpdateCharacter, self)
end

function GuildbookHomeMembersListviewItemTemplateMixin:OnMouseDown()

    self:TriggerEvent("OnMouseDown", self);

    gb.Comms:RequestCharacterInfo(self.characterGUID)

    if self.characterGUID and self.character then
        GuildbookUI.profiles.character = self.character;

        GuildbookUI.profiles:LoadCharacter(self.characterGUID)
    end

end

function GuildbookHomeMembersListviewItemTemplateMixin:OnMouseUp()

end

function GuildbookHomeMembersListviewItemTemplateMixin:OnEnter()

    --InviteToGroup

    --maybe only show the info with shift? maybe add a setting ?
    if IsShiftKeyDown() == false then
        return;
    end

    if not self.character then
        return;
    end
    GameTooltip:SetOwner(GuildbookUI, "ANCHOR_NONE")
    GameTooltip:SetPoint("RIGHT", GuildbookUI, "LEFT", -4, 0)

    -- this was to change the tooltip background
    --self.tooltipBackground:SetAtlas(string.format("UI-Character-Info-%s-BG", self.character.Class:sub(1,1):upper()..self.character.Class:sub(2)))

    local rPerc, gPerc, bPerc, argbHex = GetClassColor(self.character.Class:upper())
    GameTooltip_SetTitle(GameTooltip, self.character.Name.."\n\n|cffffffff"..L['level'].." "..self.character.Level, CreateColor(rPerc, gPerc, bPerc), nil)
    if self.tooltipIcon then
        if self.character.profile and self.character.profile.avatar then
            self.tooltipIcon.icon:SetTexture(self.character.profile.avatar)
        elseif self.character.Race and self.character.Gender then
            local race;
            if self.character.Race:lower() == "scourge" then
                race = "undead";
            else
                race = self.character.Race:lower()
            end
            self.tooltipIcon.icon:SetAtlas(string.format("raceicon-%s-%s", race, self.character.Gender:lower()))
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
        if spec and GetSpellInfo(spec) then
            return string.format("%s [%s]", prof, gb.Colours.Blue:WrapTextInColorCode((GetSpellInfo(spec))));
        elseif prof then
            return prof;
        else
            return "-";
        end
    end

    GameTooltip:AddLine(L["TRADESKILLS"])
    GameTooltip:AddDoubleLine(formatTradeskill(self.character.Profession1, self.character.Profession1Spec), self.character.Profession1Level or 0, 1,1,1,1, 1,1,1,1)
    -- GameTooltip_ShowStatusBar(GameTooltip, 0, 300, 245)
    -- GameTooltip_ShowProgressBar(GameTooltip, 0, 300, 245)
    GameTooltip:AddDoubleLine(formatTradeskill(self.character.Profession2, self.character.Profession2Spec), self.character.Profession2Level or 0, 1,1,1,1, 1,1,1,1)
    if self.character.PublicNote then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L['publicNote'], "|cffffffff"..self.character.PublicNote)
    end

    if self.character.MainCharacter then
        local mainCharacter = gb.Database:FetchCharacterTableByGUID(self.character.MainCharacter)
        if type(mainCharacter) == "string" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L['MAIN_CHARACTER'])
            local s = string.format("%s %s %s",
            gb.Data.Class[mainCharacter.Class].FontStringIconMEDIUM,
            gb.Data.Class[mainCharacter.Class].FontColour,
            mainCharacter.Name
            )
            GameTooltip:AddLine(s)
        end
    end
    if self.character.Alts then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L['ALTS'])
        local alts = gb.Database:FindCharacterAlts(self.characterGUID)
        for _, alt in ipairs(alts)do
            if alt ~= self.character then
                local s = string.format("%s %s %s",
                gb.Data.Class[alt.Class].FontStringIconMEDIUM,
                gb.Data.Class[alt.Class].FontColour,
                alt.Name
                )
                GameTooltip:AddLine(s)
            end
        end
        -- for _, guid in pairs(self.character.Alts) do
        --     if guid ~= self.character.MainCharacter and GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid] then
        --         local s = string.format("%s %s %s",
        --         gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Class].FontStringIconMEDIUM,
        --         gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Class].FontColour,
        --         GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Name
        --         )
        --         GameTooltip:AddLine(s)
        --     end
        --     --GameTooltip:AddTexture(gb.Data.Class[GUILDBOOK_GLOBAL.GuildRosterCache[GUILD_NAME][guid].Class].Icon)
        -- end
    end
    --GameTooltip:AddLine(" ")

    -- i contacted the author of attune to check it was ok to add their addon data 
    if Attune_DB and Attune_DB.toons[self.character.Name.."-"..GetRealmName()] then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["attunements"])

        local db = Attune_DB.toons[self.character.Name.."-"..GetRealmName()]

        for _, instance in ipairs(Attune_Data.attunes) do
            if db.attuned[instance.ID] and (instance.FACTION == "Both" or instance.FACTION == self.character.Faction) then
                local formatPercent = db.attuned[instance.ID] < 100 and "|cffff0000"..db.attuned[instance.ID].."%" or "|cff00ff00"..db.attuned[instance.ID].."%"
                GameTooltip:AddDoubleLine("|cffffffff"..instance.NAME, formatPercent)
            end
        end
    end

    GameTooltip:Show()
end

function GuildbookHomeMembersListviewItemTemplateMixin:OnLeave()
    if GameTooltip.insertedFrames and next(GameTooltip.insertedFrames) ~= nil then
        for k, frame in pairs(GameTooltip.insertedFrames) do
            if frame:GetName() == "GuildbookRosterListviewItemTooltipIcon" then
                frame:Hide()
            end
        end
    end
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookHomeMembersListviewItemTemplateMixin:SetSelected(selected)
    if self.selected then
        self.selected:SetShown(selected)
    end
end


---load in the character info
---@param binding table contains a character guid and a character table
---@param height number the height of the element, used to set template child objects
function GuildbookHomeMembersListviewItemTemplateMixin:SetDataBinding(binding, height)

    if type(binding) ~= "table" then
        return;
    end
    if type(height) ~= "number" then
        return;
    end

    self.height = height;
    self:SetHeight(height)

    self.background:SetAlpha(0.7)

    self.characterGUID = binding.characterGUID;
    self.character = binding.characterTable;

    self.portrait:SetSize(height+2, height+2)

    self:UpdateCharacter(self.characterGUID, self.character)

end


---this only really effects the items in view since the init func will rebind the data
---@param guid any
---@param status any
function GuildbookHomeMembersListviewItemTemplateMixin:UpdateStatus(guid, status)

    if guid ~= self.characterGUID then
        return;
    end

    if self.character.Class == "" then
        return;
    end

    if status.isOnline == false then
        self.name:SetText(gb.Colours.Grey:WrapTextInColorCode(self.character.Name))
    else
        self.name:SetText(gb.Colours[self.character.Class]:WrapTextInColorCode(self.character.Name))
    end

end



---this could be combined into a single set data/update func?
---@param guid any
---@param character any
function GuildbookHomeMembersListviewItemTemplateMixin:UpdateCharacter(guid, character)

    if type(self.characterGUID) ~= "string" then
        return;
    end

    if guid ~= self.characterGUID then
        return;
    end

    self.character = character;

    if self.character.Class and self.character.Class == "" then
        return;
    end

    if type(self.character.Class) == "string" then
        self.portrait:SetAtlas(string.format("groupfinder-icon-class-%s", self.character.Class:lower()))

    else
        self.portrait:SetAtlas("questartifactturnin")
    end

    local status = gb.Roster.onlineStatus[self.characterGUID]

    if type(self.character.MainSpec) == "string" and self.character.MainSpec ~= "-" then
        local specAtlas = gb:GetClassSpecAtlasName(self.character.Class, self.character.MainSpec)

        if status and status.isOnline == false then
            self.name:SetText(gb.Colours.Grey:WrapTextInColorCode(self.character.Name).." "..CreateAtlasMarkup(specAtlas, 14,14))
        else
            self.name:SetText(gb.Colours[self.character.Class]:WrapTextInColorCode(self.character.Name).." "..CreateAtlasMarkup(specAtlas, 14,14))
        end

    else        
        if status and status.isOnline == false then
            self.name:SetText(gb.Colours.Grey:WrapTextInColorCode(self.character.Name))
        else
            self.name:SetText(gb.Colours[self.character.Class]:WrapTextInColorCode(self.character.Name))
        end
    end

    if type(self.character.Profession1) == "string" and self.character.Profession1 ~= "-" then
        self.prof1:SetTradeskillAtlas(self.character.Profession1)

        if type(self.character.Profession1Spec) == "number" and self.character.Profession1Spec > 0 then
            local profSpec = GetSpellInfo(self.character.Profession1Spec)
            if profSpec then
                self.prof1.tooltipText = gb:GetLocaleProf(self.character.Profession1).." |cffffffff"..profSpec.."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
            end
        else
            self.prof1.tooltipText = gb:GetLocaleProf(self.character.Profession1).."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
        end

        self.prof1:SetSize(self.height-2, self.height-2)
        self.prof1:EnableMouse(true)
        self.prof1:Show()

        self.prof1.func = function()
            self:TriggerEvent("OnTradeskillClicked", self.character.Profession1, self.character)
        end
    end

    if type(self.character.Profession2) == "string" and self.character.Profession2 ~= "-" then
        self.prof2:SetTradeskillAtlas(self.character.Profession2)

        if type(self.character.Profession2Spec) == "number" and self.character.Profession2Spec > 0 then
            local profSpec = GetSpellInfo(self.character.Profession2Spec)
            if profSpec then
                self.prof2.tooltipText = gb:GetLocaleProf(self.character.Profession2).." |cffffffff"..profSpec.."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
            end
        else
            self.prof2.tooltipText = gb:GetLocaleProf(self.character.Profession2).."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
        end

        self.prof2:SetSize(self.height-2, self.height-2)
        self.prof2:EnableMouse(true)
        self.prof2:Show()

        self.prof2.func = function()
            self:TriggerEvent("OnTradeskillClicked", self.character.Profession2, self.character)
        end
    end

end


function GuildbookHomeMembersListviewItemTemplateMixin:ResetDataBinding()
    
    self.name:SetText(nil)
    self.portrait:SetAtlas(nil)

    self.prof1:SetSize(0,1)
    self.prof1:Hide()
    self.prof1.icon:SetAtlas(nil)
    self.prof1.func = nil
    self.prof1:EnableMouse(false)

    self.prof2:SetSize(0,1)
    self.prof2:Hide()
    self.prof2.icon:SetAtlas(nil)
    self.prof2.func = nil
    self.prof2:EnableMouse(false)
end








GuildbookGuildViewerCharacterListviewItemTemplateMixin = CreateFromMixins(CallbackRegistryMixin);
GuildbookGuildViewerCharacterListviewItemTemplateMixin:GenerateCallbackEvents({
    "OnTradeskillClicked",
});

function GuildbookGuildViewerCharacterListviewItemTemplateMixin:OnLoad()

    CallbackRegistryMixin.OnLoad(self);

    self:RegisterCallback("OnTradeskillClicked", gb.Tradeskills.LoadGuildMemberTradeskills, gb.Tradeskills)

    self.mask = self:CreateMaskTexture()
    --self.mask:SetSize(31,31)
    self.mask:SetPoint("LEFT", 2, 0)
    self.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    self.icon:AddMaskTexture(self.mask)
end

function GuildbookGuildViewerCharacterListviewItemTemplateMixin:SetDataBinding(binding, height)
    if type(binding) ~= "table" then
        return;
    end
    if type(height) ~= "number" then
        return;
    end

    self.height = height;
    self:SetHeight(height)

    self.mask:SetSize(height*0.8, height*0.8)
    self.icon:SetSize(height, height)

    local colour = gb.Colours.Grey;
    if type(binding.Class) == "string" and binding.Class ~= "" then
        colour = gb.Colours[binding.Class];
    end

    if type(binding.Gender) == "string" and type(binding.Race) == "string" then
        self.icon:SetAtlas(string.format("raceicon-%s-%s", binding.Race, binding.Gender))
    end

    for k, v in pairs(binding) do
        if self[k] and type(v) == "string" then
            self[k]:SetText(colour:WrapTextInColorCode(v))
        end
    end

    --overwrite the main character as it'll just show a guid
    local mainCharacter = gb.Roster:FindMainCharacterFromGUID(binding.MainCharacter, true, false)
    if type(mainCharacter) == "string" then
        self.MainCharacter:SetText(mainCharacter)
    end


    if type(binding.Profession1) == "string" then
        self.prof1:SetTradeskillAtlas(binding.Profession1)
    end
    if type(binding.Profession1Spec) == "number" and binding.Profession1Spec > 0 then
        local profSpec = GetSpellInfo(binding.Profession1Spec)
        if profSpec then
            self.prof1.tooltipText = gb:GetLocaleProf(binding.Profession1).." |cffffffff"..profSpec.."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
        end
    else
        self.prof1.tooltipText = gb:GetLocaleProf(binding.Profession1).."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
    end

    self.prof1.func = function()
        self:TriggerEvent("OnTradeskillClicked", binding.Profession1, binding)
    end


    if type(binding.Profession2) == "string" then
        self.prof2:SetTradeskillAtlas(binding.Profession2)
    end
    if type(binding.Profession2Spec) == "number" and binding.Profession2Spec > 0 then
        local profSpec = GetSpellInfo(binding.Profession2Spec)
        if profSpec then
            self.prof2.tooltipText = gb:GetLocaleProf(binding.Profession2).." |cffffffff"..profSpec.."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
        end
    else
        self.prof2.tooltipText = gb:GetLocaleProf(binding.Profession2).."\n\n"..gb.Colours.BlizzBlue:WrapTextInColorCode(L["ROSTER_VIEW_RECIPES"])
    end

    self.prof2.func = function()
        self:TriggerEvent("OnTradeskillClicked", binding.Profession2, binding)
    end
end


function GuildbookGuildViewerCharacterListviewItemTemplateMixin:ResetDataBinding()

    self.prof1:ClearAtlas()
    self.prof2:ClearAtlas()
end


function GuildbookGuildViewerCharacterListviewItemTemplateMixin:OnMouseDown()

end