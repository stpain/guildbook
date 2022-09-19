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
local L = gb.Locales or {};
local Tradeskills = gb.Tradeskills;
local Colours = gb.Colours;

local LOCALE = GetLocale();

GuildbookHelpTipMixin = {};
function GuildbookHelpTipMixin:SetText(text)
    self.text:SetText(text)
end
function GuildbookHelpTipMixin:OnShow()
    
end


GuildbookGuildMenuButtonTemplateMixin = {};
function GuildbookGuildMenuButtonTemplateMixin:OnLoad()

end

function GuildbookGuildMenuButtonTemplateMixin:OnMouseDown(button)

    if button == "RightButton" then
        StaticPopup_Show("GuildbookRemoveGuildData", nil, nil, {
            callback = function()
                gb:TriggerEvent("OnGuildRemoved", self.guild)
            end,
        })
        return;
    end

    gb:TriggerEvent("OnGuildChanged", self.guild)

end

function GuildbookGuildMenuButtonTemplateMixin:SetDataBinding(binding, height)

    self:SetHeight(height)

    self.name:SetText(binding.name)

    self.guild = binding.guild;

end

function GuildbookGuildMenuButtonTemplateMixin:ResetDataBinding()

end















GuildbookHomeCalendarEventListviewItemMixin = {}
function GuildbookHomeCalendarEventListviewItemMixin:OnLoad()

end

function GuildbookHomeCalendarEventListviewItemMixin:OnEnter()

end

function GuildbookHomeCalendarEventListviewItemMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookHomeCalendarEventListviewItemMixin:OnMouseDown()

end

function GuildbookHomeCalendarEventListviewItemMixin:SetDataBinding(binding, height)

    self:SetHeight(height)

    self.icon:SetWidth(height-2)

    self.icon:SetTexture(binding.iconTexture)
    self.text:SetText(binding.title)
    self.info:SetText(string.format("%s %s %s  >  %s", binding.startTime.year, binding.startTime.month, binding.startTime.monthDay, date("%H:%M:%S", time(binding.startTime))))

end

function GuildbookHomeCalendarEventListviewItemMixin:ResetDataBinding()

    self.icon:SetTexture(nil)
    self.text:SetText(nil)

end





--[[
    This is the template for the main tradeskill recipes list
]]
GuildbookTradeskillListviewItemTemplateMixin = {};
function GuildbookTradeskillListviewItemTemplateMixin:SetDataBinding(binding, height)

    self.item = binding;
    self:SetHeight(height)

    local localeData = Tradeskills:GetLocaleData(binding)
    if self.item.tradeskill == 333 then
        self.link:SetText(localeData.name)
    else
        if localeData.link:find("spell:") then
            self.link:SetText(localeData.name)
        else
            self.link:SetText(localeData.link)
        end
    end

    self.addToWorkOrder:SetSize(height-8, height-8)
    self.addToWorkOrder:SetScript("OnMouseDown", function()
        gb:TriggerEvent("TradeskillListviewItem_OnAddToWorkOrder", { item = binding })
    end)
end

function GuildbookTradeskillListviewItemTemplateMixin:OnMouseDown(button)
    if self.item then



        if IsControlKeyDown() then
            if self.item.tradeskill ~= 333 then
                local localeData = Tradeskills:GetLocaleData(self.item)
                DressUpItemLink(localeData.link)
            end

        elseif IsShiftKeyDown() then
            local localeData = Tradeskills:GetLocaleData(self.item)
            HandleModifiedItemClick(localeData.link)

        else
            gb:TriggerEvent("TradeskillListviewItem_OnMouseDown", self.item)
        end
    end
end

function GuildbookTradeskillListviewItemTemplateMixin:OnEnter()
    if self.item then
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetHyperlink(self.item.link)
    end
end

function GuildbookTradeskillListviewItemTemplateMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookTradeskillListviewItemTemplateMixin:OnLoad()
    self.addToWorkOrder.icon:SetAtlas("communities-icon-addgroupplus")
    self.addToWorkOrder:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["TRADESKILL_WORK_ORDER_ADD_TOOLTIP"])
        GameTooltip:Show()
    end)
    self.addToWorkOrder:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

end

function GuildbookTradeskillListviewItemTemplateMixin:ResetDataBinding()
    self.item = nil;
    self.link:SetText("-")
end





--[[
    This is the template for the work orders listview
]]
GuildbookTradeskillWorkOrderListviewItemTemplateMixin = {};
function GuildbookTradeskillWorkOrderListviewItemTemplateMixin:SetDataBinding(binding, height)

    self.item = binding;
    self:SetHeight(height)
    local localeData = Tradeskills:GetLocaleData(binding)
    if self.item.tradeskill == 333 then
        self.link:SetText(localeData.name)
    else
        if localeData.link:find("spell:") then
            self.link:SetText(localeData.name)
        else
            self.link:SetText(localeData.link)
        end
    end

    self.removeFromWorkOrder:SetSize(height-8, height-8)
    self.removeFromWorkOrder:SetScript("OnMouseDown", function()
        gb:TriggerEvent("TradeskillListviewItem_RemoveFromWorkOrder", binding)
    end)

end

function GuildbookTradeskillWorkOrderListviewItemTemplateMixin:OnMouseDown()

end

function GuildbookTradeskillWorkOrderListviewItemTemplateMixin:OnEnter()
    if self.item then
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        local link = self.item.link
        GameTooltip:SetHyperlink(link)

        if self.item.character then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Work order info:")

            --this character object might get saved and will lose its methods so just access the data here
            if self.item.character and self.item.guild then
                GameTooltip:AddDoubleLine("Requested by:", Colours[self.item.character.data.class]:WrapTextInColorCode(self.item.character.data.name).." |cffffffff["..self.item.guild.."]")
                GameTooltip:AddDoubleLine("Requested amount:", self.item.quantity)
            end
            --GameTooltip:AddLine(L["TRADESKILL_WORK_ORDER_CLICK_CAST"])
        end
        GameTooltip:Show()
    end
end

function GuildbookTradeskillWorkOrderListviewItemTemplateMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookTradeskillWorkOrderListviewItemTemplateMixin:OnLoad()
    self.removeFromWorkOrder.icon:SetAtlas("transmog-icon-remove")
    self.removeFromWorkOrder:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Remove from work orders")
        GameTooltip:Show()
    end)
    self.removeFromWorkOrder:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end

function GuildbookTradeskillWorkOrderListviewItemTemplateMixin:ResetDataBinding()
    self.link:SetText("-")
    self.item = nil;
end







--[[
    This is the template for the Guild crafters listview
]]
GuildbookTradeskillCrafterItemTemplateMixin = {}
function GuildbookTradeskillCrafterItemTemplateMixin:SetDataBinding(binding, height)

    self:SetHeight(height)

    self.name:SetText(Colours[binding.character:GetClass():upper()]:WrapTextInColorCode(binding.character:GetName()))

    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(binding.guild)
        GameTooltip:Show()
    end)

    self.sendWorkOrder:SetSize(height-1, height-1)
    self.sendWorkOrder:SetScript("OnMouseDown", function()
        gb:TriggerEvent("TradeskillCrafter_SendWorkOrder", binding.character, self.workOrderQuantity)
    end)

    self.workOrderQuantity = 1;

    self.quantityDown:SetSize(height-6, height-6)
    self.quantityDown:SetScript("OnClick", function()
        if self.workOrderQuantity > 1 then
            self.workOrderQuantity = self.workOrderQuantity - 1;
        end
        self.quantity:SetText(self.workOrderQuantity)
    end)
    self.quantityUp:SetSize(height-6, height-6)
    self.quantityUp:SetScript("OnClick", function()
        self.workOrderQuantity = self.workOrderQuantity + 1;
        self.quantity:SetText(self.workOrderQuantity)
    end)
end

function GuildbookTradeskillCrafterItemTemplateMixin:OnMouseDown()

end

function GuildbookTradeskillCrafterItemTemplateMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookTradeskillCrafterItemTemplateMixin:OnLoad()
    self.sendWorkOrder.icon:SetAtlas("mailbox")
    self.sendWorkOrder:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["TRADESKILL_WORK_ORDER_SEND_TOOLTIP"])
        GameTooltip:Show()
    end)
    self.sendWorkOrder:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end

function GuildbookTradeskillCrafterItemTemplateMixin:ResetDataBinding()
    self.character = nil;
    self.name:SetText(nil)

    self.quantity:SetText(1)
end




--[[
    This is the template for the Recipe reagents listview (also the work orders reagents listview)
]]
GuildbookTradeskillRecipeInfoItemTemplateMixin = {}
function GuildbookTradeskillRecipeInfoItemTemplateMixin:SetDataBinding(binding, height)

    self.item = binding;
    self:SetHeight(height)
    self.trackingBorder:SetSize(height-4, height-4)

    self.link:SetHeight(height-2)

    if binding.haveReagent then
        self.trackingTick:Show()
    else
        self.trackingTick:Hide()
    end
    self.trackingTick:SetSize(height-9, height-9)

    self.link:SetText(self.item.link)
    self.count:SetText(self.item.count)
end

function GuildbookTradeskillRecipeInfoItemTemplateMixin:OnMouseDown()
    --HandleModifiedItemClick(self.link)
    if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then
        BrowseName:SetText(self.item.name)
        BrowseSearchButton:Click()
    end
end

function GuildbookTradeskillRecipeInfoItemTemplateMixin:OnEnter()
    if self.item then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.item.link)
    end
end

function GuildbookTradeskillRecipeInfoItemTemplateMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookTradeskillRecipeInfoItemTemplateMixin:OnLoad()

end

function GuildbookTradeskillRecipeInfoItemTemplateMixin:ResetDataBinding()
    self.item = nil;
    self.link:SetText(nil)
    self.count:SetText(nil)
end








--[[
    This is the template for the players equipment in the profile view
]]
GuildbookProfileEquipmentIconMixin = {}
GuildbookProfileEquipmentIconMixin.ringColours = {
    [0] = "auctionhouse-itemicon-border-grey",
    [1] = "auctionhouse-itemicon-border-white",
    [2] = "auctionhouse-itemicon-border-green",
    [3] = "auctionhouse-itemicon-border-blue",
    [4] = "auctionhouse-itemicon-border-purple",
    [5] = "auctionhouse-itemicon-border-orange",
    [6] = "auctionhouse-itemicon-border-artifact",
}
function GuildbookProfileEquipmentIconMixin:OnLoad()
    local w, h = self:GetSize()
    self.icon:SetSize(h, h)
    self.mask:SetSize(h-2, h-2)
    self.ring:SetSize(h+16, h+16)
    self.link:SetSize(w-h, h)
end

function GuildbookProfileEquipmentIconMixin:OnEnter()
    if self.itemlink then
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetHyperlink(self.itemlink)
    end
end

function GuildbookProfileEquipmentIconMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookProfileEquipmentIconMixin:ClearItem()
    self.link:SetText("")
    self.icon:SetTexture(nil)
    self:Hide()
end

function GuildbookProfileEquipmentIconMixin:SetItem(info)

    local item;
    if type(info) == "number" then
        item = Item:CreateFromItemID(info)
    elseif type(info) == "string" then
        item = Item:CreateFromItemLink(info)
    end

    if item and not item:IsItemEmpty() then
        item:ContinueOnItemLoad(function()
            self.link:SetText(item:GetItemLink())
            self.icon:SetTexture(item:GetItemIcon())
            self.ring:SetAtlas(self.ringColours[item:GetItemQuality()])

            self.itemlink = item:GetItemLink()

            self:Show()
        end)
    end
end

function GuildbookProfileEquipmentIconMixin:SetAllign(allign)
    if allign == "left" then
        self.icon:ClearAllPoints()
        self.icon:SetPoint("LEFT", 0, 0)
        self.mask:ClearAllPoints()
        self.mask:SetPoint("LEFT", -1, 0)

        self.ring:ClearAllPoints()
        self.ring:SetPoint("LEFT", -9, 0)

        self.link:ClearAllPoints()
        self.link:SetPoint("LEFT", self.icon, "RIGHT", 2, 0)
        self.link:SetPoint("RIGHT", -2, 0)

    elseif allign == "right" then
        self.icon:ClearAllPoints()
        self.icon:SetPoint("RIGHT", 0, 0)
        self.mask:ClearAllPoints()
        self.mask:SetPoint("RIGHT", 1, 0)

        self.ring:ClearAllPoints()
        self.ring:SetPoint("RIGHT", 9, 0)

        self.link:ClearAllPoints()
        self.link:SetPoint("RIGHT", self.icon, "LEFT", -2, 0)
        self.link:SetPoint("LEFT", 2, 0)
    end
end




--[[
    unused
]]
GuildbookProfileGlyphIconMixin = {};
function GuildbookProfileGlyphIconMixin:OnLoad()
    local w, h = self:GetSize()
    self.link:SetPoint("BOTTOM", 0, 0)
    self.link:SetSize(w, 24)

    self.icon:SetPoint("TOP", 0, 0)
    self.icon:SetSize(h-24, h-24)

    self.mask:SetPoint("TOP", 0, 0)
    self.mask:SetSize(h-24, h-24)
end
function GuildbookProfileGlyphIconMixin:OnLeave()

end
function GuildbookProfileGlyphIconMixin:OnEnter()

end

function GuildbookProfileGlyphIconMixin:SetGlyph(glyph)
    
end







--[[
    This is the template for the character stats listview in the profile section
]]
GuildbookCharacterStatsListviewItemTemplateMixin = {}
function GuildbookCharacterStatsListviewItemTemplateMixin:OnLoad()
    
end

function GuildbookCharacterStatsListviewItemTemplateMixin:OnEnter()
    
end

function GuildbookCharacterStatsListviewItemTemplateMixin:OnLeave()
    
end

function GuildbookCharacterStatsListviewItemTemplateMixin:SetDataBinding(stat)
    if stat.value == nil then
        self.label:ClearAllPoints()
        self.label:SetPoint("CENTER", 0, 0)

        self.label:SetText(stat.name)
        self.background:SetAtlas("UI-Character-Info-Title")
    else
        self.label:SetText(stat.name)

        if type(stat.value) == "table" then
            self.value:SetText(stat.value.Base)
        else
            self.value:SetText(stat.value)
        end

        if stat.hasBounce then
            self.background:SetAtlas("UI-Character-Info-Line-Bounce")
        else
            self.background:SetTexture(nil)
        end
    end

end

function GuildbookCharacterStatsListviewItemTemplateMixin:ResetDataBinding()
    self.label:SetText(nil)
    self.value:SetText(nil)

    self.label:ClearAllPoints()
    self.label:SetPoint("LEFT", 0, 0)

    self.background:SetTexture(nil)
end







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

    -- if type(tradeskill) == "string" and gb.Tradeskills.TradeskillNames[tradeskill] then
    --     if tradeskill == "Engineering" then
    --         self.icon:SetAtlas("Mobile-Enginnering")
    --     else
    --         self.icon:SetAtlas(string.format("Mobile-%s", tradeskill))
    --     end
    -- end
end


function GuildbookSmallHighlightButtonMixin:ClearAtlas()
    self.icon:SetAtlas(nil)
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



--- custom dropdown widget supporting a single menu layer
GuildbookDropDownFrameMixin = {}
local DROPDOWN_CLOSE_DELAY = 3.0


-- this is the dropdown button mixin, all that needs to happen is set the text and call any func if passed
GuildbookDropDownFlyoutButtonMixin = {}

function GuildbookDropDownFlyoutButtonMixin:OnEnter()

end

function GuildbookDropDownFlyoutButtonMixin:OnLeave()

end

function GuildbookDropDownFlyoutButtonMixin:SetText(text)
    self.Text:SetText(text)
end

function GuildbookDropDownFlyoutButtonMixin:SetIcon(icon)
    local w, h = self:GetSize()
    self.icon:SetSize(h-1, h-1)
    if type(icon) == "number" then
        self.icon:SetTexture(icon)

    elseif type(icon) == "string" then
        self.icon:SetAtlas(icon)

    else
        self.icon:SetTexture(nil)
        self.icon:SetSize(1, h-1)
    end
end

function GuildbookDropDownFlyoutButtonMixin:GetText()
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
        if self.selectedValue then
            self:GetParent():GetParent().selectedValue = self.selectedValue;
            --print("set selected value")
        end
    end
    if self:GetParent().delay then
        self:GetParent().delay:Cancel()
    end
    self:GetParent():Hide()
end





-- if we need to get the flyout although its a child so can be accessed via dropdown.Flyout
GuildbookDropdownMixin = {}

function GuildbookDropdownMixin:GetFlyout()
    return self.flyout
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



--this is the arrow down button to open the menu
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
            dd.flyout:Hide()
        end
    end

    local flyout = self:GetParent():GetFlyout()
    flyout:ClearAllPoints()
    flyout:SetPoint("TOPRIGHT", -5, -26)
    flyout:SetShown(not flyout:IsVisible())
end

function GuildbookDropdownButtonMixin:OnMouseUp()
    self.ButtonDown:Hide()
    self.ButtonUp:Show()
end




GuildbookDropdownFlyoutMixin = {}

function GuildbookDropdownFlyoutMixin:OnLoad()
    if not gb.dropdownFlyouts then
        gb.dropdownFlyouts = {}
    end
    table.insert(gb.dropdownFlyouts, self)
end

function GuildbookDropdownFlyoutMixin:OnLeave()
    self.delay = C_Timer.NewTicker(DROPDOWN_CLOSE_DELAY, function()
        if not self:IsMouseOver() then
            self:Hide()
        end
    end)
end

function GuildbookDropdownFlyoutMixin:SetFlyoutBackgroundColour(colour)
    if type(colour) == "table" then
        self.background:SetColorTexture(colour:GetRGB())

    elseif 1 == 0 then

    end
end

function GuildbookDropdownFlyoutMixin:OnHide()
    if self.delay then
        self.delay:Cancel()
    end
end

function GuildbookDropdownFlyoutMixin:OnShow()

    if gb.dropdownFlyouts then
        for k, flyout in ipairs(gb.dropdownFlyouts) do
            flyout:Hide()
        end
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

    local borderSize = 2;
    if self.borderSize then
        borderSize = self.borderSize;
    end

    self:SetHeight(1)

    -- the .menu needs to a table that mimics the blizz dropdown
    -- t = {
    --     text = buttonText,
    --     func = functionToRun,
    -- }
    local maxWidth = 1;
    local buttonsUsed = 0;
    if self:GetParent().menu then
        if not self.buttons then
            self.buttons = {}
        end
        for i = 1, #self.buttons do
            self.buttons[i]:SetText("")
            self.buttons[i]:SetIcon(nil)
            self.buttons[i].func = nil
            self.buttons[i].updateText = nil;
            self.buttons[i]:Hide()
        end
        for buttonIndex, info in ipairs(self:GetParent().menu) do
            if not self.buttons[buttonIndex] then
                self.buttons[buttonIndex] = CreateFrame("FRAME", nil, self, "GuildbookDropDownFlyoutButton")
                self.buttons[buttonIndex]:SetPoint("TOP", 0, ((buttonIndex * -22) - borderSize) + 22)
            end
            self.buttons[buttonIndex]:SetText(info.text)
            self.buttons[buttonIndex]:SetIcon(info.icon)

            local w = self.buttons[buttonIndex].Text:GetWidth()
            if w > maxWidth then
                maxWidth = w;
            end

            if info.selectedValue then
                self.buttons[buttonIndex].selectedValue = info.selectedValue
            else
                self.buttons[buttonIndex].selectedValue = nil
            end

            self.buttons[buttonIndex].updateText = info.updateText;
            self.buttons[buttonIndex].func = info.func;
            self.buttons[buttonIndex]:Show()

            buttonsUsed = buttonsUsed + 1
        end
        for i = 1, #self.buttons do
            self.buttons[i]:SetWidth(maxWidth * 1.4)
        end
        self:SetHeight((buttonsUsed * 22) + (borderSize * 2))
    end

    self:SetWidth((maxWidth * 1.4) + (borderSize * 2))
end




GuildbookProfileSummaryRowAvatarTemplateMixin = {}

function GuildbookProfileSummaryRowAvatarTemplateMixin:SetCharacter(alt)


    self.avatar:SetAtlas(string.format("raceicon-%s-%s", alt:GetRace(), alt:GetGender()))

    self.name:SetText(gb.Colours[alt:GetClass():upper()]:WrapTextInColorCode(alt:GetName()))
    self.border:SetVertexColor(gb.Colours[alt:GetClass():upper()]:GetRGB())

    self:SetScript("OnMouseDown", function()
        gb:TriggerEvent("RosterListviewItem_OnMouseDown", alt)
    end)
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


















GuildbookAvatarMixin = {}

function GuildbookAvatarMixin:OnLoad()

end

function GuildbookAvatarMixin:OnMouseDown()
    if self.func then
        self.func()
    end
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
    --element:RegisterCallback("OnMouseDown", self.OnElementClicked, self);

end

function GuildbookListviewMixin:OnElementReset(element)
    --element:UnregisterCallback("OnMouseDown", self);

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





















---this is the mixin for the character list on the home tab
GuildbookHomeMembersListviewItemTemplateMixin = {};
function GuildbookHomeMembersListviewItemTemplateMixin:OnLoad()
    self.background:SetAlpha(0.9)

    gb:RegisterCallback("OnCharacterChanged", self.OnCharacterChanged, self)
    gb:RegisterCallback("OnGuildRosterScanned", self.OnRosterScanned, self)
end

function GuildbookHomeMembersListviewItemTemplateMixin:OnMouseDown()
    if type(self.character) == "table" then
        gb:TriggerEvent("RosterListviewItem_OnMouseDown", self.character)
    end
end

function GuildbookHomeMembersListviewItemTemplateMixin:OnMouseUp()

end

function GuildbookHomeMembersListviewItemTemplateMixin:OnEnter()

end

function GuildbookHomeMembersListviewItemTemplateMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookHomeMembersListviewItemTemplateMixin:SetSelected(selected)

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

    self:SetHeight(height)

    self.guid = binding.data.guid;
    self.character = binding;

    self.portrait:SetSize(height+2, height+2)

    self:UpdateCharacter(self.guid, self.character)

end

function GuildbookHomeMembersListviewItemTemplateMixin:OnRosterScanned(guild)
    local character = guild:GetCharacter(self.guid)
    if type(character) == "table" then
        self:UpdateCharacter(self.guid, character)
    end
end

function GuildbookHomeMembersListviewItemTemplateMixin:OnCharacterChanged(character)

    if character:GetGuid() == self.guid then
        self:UpdateCharacter(self.guid, character)
    end
end


---this could be combined into a single set data/update func?
---@param guid any
---@param character any
function GuildbookHomeMembersListviewItemTemplateMixin:UpdateCharacter(guid, character)

    if type(self.guid) ~= "string" then
        return;
    end

    if guid ~= self.guid then
        return;
    end

    self.character = character;

    local class = self.character:GetClass();

    self.portrait:SetAtlas(string.format("groupfinder-icon-class-%s", class:lower()))
    --self.name:SetText(Colours[class:upper()]:WrapTextInColorCode(self.character:GetName()))

    if self.character:GetOnlineStatus().isOnline then
        self.name:SetText(Colours[class:upper()]:WrapTextInColorCode(self.character:GetName()))
    else
        self.name:SetText(Colours.Grey:WrapTextInColorCode(self.character:GetName()))
    end

end


function GuildbookHomeMembersListviewItemTemplateMixin:ResetDataBinding()

    self.character = nil;
    self.guid = nil;
    
    self.name:SetText(nil)
    self.portrait:SetAtlas(nil)

end





















---this is the mixin for the character list on the home tab
GuildbookTradeskillsListviewItemTemplateMixin = {};
function GuildbookTradeskillsListviewItemTemplateMixin:OnLoad()

end

function GuildbookTradeskillsListviewItemTemplateMixin:OnEnter()

end

function GuildbookTradeskillsListviewItemTemplateMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function GuildbookTradeskillsListviewItemTemplateMixin:SetDataBinding(binding, height)

    self:SetHeight(height)

    self.icon:SetSize(height * 0.8, height * 0.8)

    if binding.atlas then
        self.icon:SetAtlas(binding.atlas)

    elseif binding.fileID then
        self.icon:SetTexture(binding.fileID)

    end

    if binding.text then
        self.name:SetText(binding.text)
        
    else
        self.name:SetText(Tradeskills:GetLocaleNameFromID(binding.tradeskillID))

    end

    self:SetScript("OnMouseDown", function()

        if binding.tradeskillID then
            binding.onMouseDown(binding.tradeskillID)

        elseif binding.classID then
            binding.onMouseDown(binding.classID, binding.subClassID or nil)

        end
    end)

end

function GuildbookTradeskillsListviewItemTemplateMixin:ResetDataBinding()



end















GuildbookAltManagerListviewItemtemplateMixin = {}
function GuildbookAltManagerListviewItemtemplateMixin:OnLoad()

end
function GuildbookAltManagerListviewItemtemplateMixin:SetDataBinding(binding, height)

    self:SetHeight(height)

    self.classIcon:SetSize(height-2, height-2)

    self.classIcon:SetAtlas(string.format("GarrMission_ClassIcon-%s", binding.alt:GetClass():lower()))

    self.name:SetText(string.format("%s [%s]", binding.alt:GetName(), binding.guild:GetName()))

    if binding.alt:GetGuid() == binding.alt:GetMainCharacter() then
        self.checkbutton:SetChecked(true)
    end


    self.checkbutton:SetScript("OnClick", function()
        local isChecked = self.checkbutton:GetChecked()
        gb:TriggerEvent("AltManagerListviewItem_OnCheckButtonClicked", binding, isChecked)

    end)
end
function GuildbookAltManagerListviewItemtemplateMixin:ResetDataBinding()
    self.checkbutton:SetChecked(false)
end






GuildbookTooltipExtensionMixin = {}
function GuildbookTooltipExtensionMixin:OnLoad()

end
function GuildbookTooltipExtensionMixin:SetCharacter(character, showMain, showMainSpec, showTradeskills, showProfile)
    if not character then
        return
    end

    self.name:SetText(gb.Colours[character:GetClass()]:WrapTextInColorCode(character:GetName()))
    self.classIcon:SetAtlas(string.format("GarrMission_ClassIcon-%s", character:GetClass():lower()))

    self:SetHeight(60)

    if showMain then

        local mainGUID = character:GetMainCharacter()
        for k, guild in ipairs(GuildbookInterface.guilds) do
            local main = guild:GetCharacter(mainGUID)
            if type(main) == "table" then
                self.mainCharacter:SetText("|cffffffff["..gb.Colours[main:GetClass()]:WrapTextInColorCode(main:GetName()).."|cffffffff]")
            end
        end
        
    else
        
    end

    if showMainSpec then
        if character:GetSpec("primary") then
            self.specPanel.mainSpec:SetText(string.format("%s %s", CreateAtlasMarkup(character:GetClassSpecAtlasName("primary"), 20, 20), character:GetSpec("primary")))
        end
        if character:GetSpec("secondary") then
            self.specPanel.offSpec:SetText(string.format("%s %s", character:GetSpec("secondary"), CreateAtlasMarkup(character:GetClassSpecAtlasName("secondary"), 20, 20)))
        end
        self.specPanel:Show()
        self.specPanel:SetHeight(50)
    else
        self.specPanel:Hide()
        self.specPanel:SetHeight(1)
    end

    if showTradeskills then
        local prof1 = character:GetTradeskill(1)
        local prof1Level = character:GetTradeskillLevel(1)
        local prof1Spec = character:GetTradeskillSpec(1)
        local prof2 = character:GetTradeskill(2)
        local prof2Level = character:GetTradeskillLevel(2)
        local prof2Spec = character:GetTradeskillSpec(2)

        local prof1String = ""
        if type(prof1) == "number" then
            prof1String = CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(prof1), 20, 20)
            prof1 = Tradeskills:GetLocaleNameFromID(prof1)
        end
        if type(prof1) == "string" then
            prof1String = prof1String.." "..prof1
        end
        if type(prof1Level) == "number" then
            prof1String = prof1String.." ["..prof1Level.."]"
        end
        if type(prof1Spec) == "number" then
            prof1Spec = GetSpellInfo(prof1Spec)
            prof1String = prof1String.." "..(prof1Spec and prof1Spec or "")
        end
        self.tradeskillsPanel.prof1:SetText(prof1String)

        local prof2String = ""
        if type(prof2) == "number" then
            prof2String = CreateAtlasMarkup(Tradeskills:TradeskillIDToAtlas(prof2), 20, 20)
            prof2 = Tradeskills:GetLocaleNameFromID(prof2)
        end
        if type(prof2) == "string" then
            prof2String = prof2String.." "..prof2
        end
        if type(prof2Level) == "number" then
            prof2String = prof2String.." ["..prof2Level.."]"
        end
        if type(prof2Spec) == "number" then
            prof2Spec = GetSpellInfo(prof2Spec)
            prof2String = prof2String.." "..(prof2Spec and prof2Spec or "")
        end
        self.tradeskillsPanel.prof2:SetText(prof2String)
        
        self.tradeskillsPanel:Show()
        self.tradeskillsPanel:SetHeight(70)
    else
        self.tradeskillsPanel:Hide()
        self.tradeskillsPanel:SetHeight(1)
    end

    if showProfile then

        local profile = character:GetProfile()
        if profile then

            self.profilePanel.profileName:SetText(profile.name)
            self.profilePanel.profileBio:SetText(profile.bio)

            self.profilePanel:Show()
            self.profilePanel:SetHeight(110)

        end
    else
        self.profilePanel:Hide()
        self.profilePanel:SetHeight(1)
    end

    self:SetHeight(60 + self.specPanel:GetHeight() + self.tradeskillsPanel:GetHeight() + self.profilePanel:GetHeight())


end
function GuildbookTooltipExtensionMixin:Clear()

    self.specPanel:SetHeight(1)
    self.tradeskillsPanel:SetHeight(1)
    self.profilePanel:SetHeight(1)

    self.specPanel:Hide()
    self.tradeskillsPanel:Hide()
    self.profilePanel:Hide()

    self.mainCharacter:SetText("")

    self.specPanel.mainSpec:SetText("")
    self.specPanel.offSpec:SetText("")

    self.tradeskillsPanel.prof1:SetText("")
    self.tradeskillsPanel.prof2:SetText("")

    self.profilePanel.profileName:SetText("")
    self.profilePanel.profileBio:SetText("")
end