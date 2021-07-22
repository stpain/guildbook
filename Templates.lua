local _, gb = ...
local L = gb.Locales


--- basic button mixin
GuildbookButtonMixin = {}

function GuildbookButtonMixin:OnLoad()
    --self.anchor = AnchorUtil.CreateAnchor(self:GetPoint());

    self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs = self:GetPoint()
end

function GuildbookButtonMixin:OnShow()
    --self.anchor:SetPoint(self);
    if self.point and self.relativeTo and self.relativePoint and self.xOfs and self.yOfs then
        self:SetPoint(self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs)
    end
end

function GuildbookButtonMixin:OnMouseDown()
    if self.disabled then
        return;
    end
    self:AdjustPointsOffset(-1,-1)
end

function GuildbookButtonMixin:OnMouseUp()
    if self.disabled then
        return;
    end
    self:AdjustPointsOffset(1,1)
    if self.func then
        C_Timer.After(0, self.func)
    end
end

function GuildbookButtonMixin:OnEnter()
    if self.tooltipText and L[self.tooltipText] then
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        GameTooltip:AddLine("|cffffffff"..L[self.tooltipText])
        GameTooltip:Show()
    elseif self.tooltipText and not L[self.tooltipText] then
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        GameTooltip:AddLine(self.tooltipText)
        GameTooltip:Show()
    elseif self.link then
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        GameTooltip:SetHyperlink(self.link)
        GameTooltip:Show()
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end
end

function GuildbookButtonMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end


--- basic button with an icon and text area
GuildbookListviewItemMixin = {}

function GuildbookListviewItemMixin:OnLoad()
    -- local _, size, flags = self.Text:GetFont()
    -- self.Text:SetFont([[Interface\Addons\Guildbook\Media\Fonts\Acme-Regular.ttf]], size+4, flags)
end

function GuildbookListviewItemMixin:SetItem(info)
    self.Icon:SetAtlas(info.Atlas)
    self.Text:SetText(gb.ProfessionNames[GetLocale()][info.id])
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
        self:GetParent():GetParent().Text:SetTextColor(1,1,1,1)
        self:GetParent():GetParent().Text:SetText(text)
    end
    if self:GetParent().delay then
        self:GetParent().delay:Cancel()
    end
    self:GetParent():Hide()
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
    if self:GetParent().menu then
        if not self.buttons then
            self.buttons = {}
        end
        for i = 1, #self.buttons do
            self.buttons[i]:SetText("")
            self.buttons[i].func = nil
            self.buttons[i]:Hide()
        end
        for buttonIndex, info in ipairs(self:GetParent().menu) do
            if not self.buttons[buttonIndex] then
                self.buttons[buttonIndex] = CreateFrame("FRAME", nil, self, "GuildbookDropDownButton")
                self.buttons[buttonIndex]:SetPoint("TOP", 0, (buttonIndex * -22) + 22)
            end
            self.buttons[buttonIndex]:SetText(info.text)

            while self.buttons[buttonIndex].Text:IsTruncated() do
                self:SetWidth(self:GetWidth() + 2)
            end
            --self.buttons[buttonIndex].arg1 = info.arg1
            self.buttons[buttonIndex].func = info.func
            self.buttons[buttonIndex]:Show()

            self:SetHeight(buttonIndex * 22)
            buttonIndex = buttonIndex + 1
        end
        for i = 1, #self.buttons do
            self.buttons[i]:SetWidth(self:GetWidth() - 2)
        end
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