

GuildbookSearchResultMixin = {}

function GuildbookSearchResultMixin:OnMouseDown()
    if self.func then
        C_Timer.After(0, self.func)
    end
end

function GuildbookSearchResultMixin:OnEnter()
    if self.link and self.link:find("|Hitem") then
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
        GameTooltip:SetHyperlink(self.link)
        GameTooltip:Show()
    else
        GameTooltip:SetOwner(self, 'ANCHOR_TOP')
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
    if self.func then
        self:func()
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

function GuildbookDropdownFlyoutMixin:OnLeave()
    self.delay = C_Timer.NewTicker(DROPDOWN_CLOSE_DELAY, function()
        if not self:IsMouseOver() then
            self:Hide()
        end
    end)
end

function GuildbookDropdownFlyoutMixin:OnShow()

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