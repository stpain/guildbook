local _, addon = ...
local L = addon.Locales
local Database = addon.Database;
local Talents = addon.Talents;

--- basic button mixin
GuildbookButtonMixin = {}

function GuildbookButtonMixin:OnLoad()
    --self.anchor = AnchorUtil.CreateAnchor(self:GetPoint());

    --self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs = self:GetPoint()
end

function GuildbookButtonMixin:OnShow()
    --self.anchor:SetPoint(self);
    -- if self.point and self.relativeTo and self.relativePoint and self.xOfs and self.yOfs then
    --     self:SetPoint(self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs)
    -- end
end

function GuildbookButtonMixin:OnMouseDown()
    if self.disabled then
        return;
    end
    --self:AdjustPointsOffset(-1,-1)
end

function GuildbookButtonMixin:OnMouseUp()
    if self.disabled then
        return;
    end
    --self:AdjustPointsOffset(1,1)
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

function GuildbookListviewItemMixin:ResetDataBinding()

end

function GuildbookListviewItemMixin:SetDataBinding(info, height)

    self:SetHeight(height)
    self.icon:SetSize(height-2, height-2)

    if info.atlas then
        self.icon:SetAtlas(info.atlas)
    elseif info.icon then
        self.icon:SetTexture(info.icon)
    end
    self.text:SetText(info.label)

    if info.showMask then
        self.mask:Show()
        -- local x, y = self.icon:GetSize()
        -- self.icon:SetSize(x + 2, y + 2)

    end

    if self.selected then
        if info.showSelected then
            self.selected:Show()
        else
            self.selected:Hide()
        end
    end

    self:SetScript("OnMouseDown", function()
        self:AdjustPointsOffset(-1,-1)
        if info.func then
            info.func()
        end
    end)
end

function GuildbookListviewItemMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
end




GuildbookSearchListviewItemMixin = {}
function GuildbookSearchListviewItemMixin:OnLoad()

end

function GuildbookSearchListviewItemMixin:ResetDataBinding()

end

function GuildbookSearchListviewItemMixin:UpdateInfo(info)

end

function GuildbookSearchListviewItemMixin:SetDataBinding(binding)

    -- self.icon:SetAtlas(info.atlas)
    -- self.text:SetText(Ambiguate(info.label, "short"))

    -- if info.showMask then
    --     self.mask:Show()
    --     local x, y = self.icon:GetSize()
    --     self.icon:SetSize(x + 2, y + 2)
    -- end

    if binding.type == "tradeskillItem" then
        
        self.text:SetText(binding.data.itemLink)

    elseif binding.type == "character" then

        self.text:SetText(binding.data.data.name)

    elseif binding.type == "bankItem" then

        self.text:SetText(binding.data:GetItemLink())

    elseif binding.type == "inventory" then

        self.text:SetText(binding.data:GetItemLink())
        
    end

    self:SetScript("OnMouseDown", function()

    end)
end







GuildbookChatCharacterListviewItemMixin = {}
function GuildbookChatCharacterListviewItemMixin:OnLoad()
    addon:RegisterCallback("Chat_OnMessageReceived", self.UpdateInfo, self)

    self.delete:SetScript("OnMouseDown", function()
        if self.characterName then
            addon:TriggerEvent("Chat_OnHistoryDeleted", self.characterName)
        end
    end)
end

function GuildbookChatCharacterListviewItemMixin:ResetDataBinding()
    self.info:SetText("")
    self.characterName = ""
end

function GuildbookChatCharacterListviewItemMixin:UpdateInfo(msg)
    --the chat view will run its update script which causes the listview to be repopulated making the self.characterName field == ""
    --wait to check the values
    C_Timer.After(0.5, function()
        if (msg.sender == self.characterName) and (msg.channel == "whisper") then
            self.info:SetText("new message")
        end
    end)
end

function GuildbookChatCharacterListviewItemMixin:SetDataBinding(info, height)

    if info.label == "Guild" then
        self.delete:Hide()
    end

    self.characterName = info.label
    self.icon:SetAtlas(info.atlas)
    self.text:SetText(Ambiguate(info.label, "short"))
    self.icon:SetSize(height-2, height-2)
    if info.showMask then
        self.mask:Show()
    end

    self:SetScript("OnMouseDown", function()
        self:AdjustPointsOffset(-1,-1)
        if info.func then
            info.func()
            self.info:SetText("")
        end
    end)
end

function GuildbookChatCharacterListviewItemMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
end







GuildbookGuildbankCharacterListviewItemMixin = {}
function GuildbookGuildbankCharacterListviewItemMixin:OnLoad()
    addon:RegisterCallback("Guildbank_StatusInfo", self.UpdateInfo, self)
end

function GuildbookGuildbankCharacterListviewItemMixin:ResetDataBinding()
    self.info:SetText("")
    self.characterName = ""
end

function GuildbookGuildbankCharacterListviewItemMixin:UpdateInfo(info)
    if info.characterName == self.characterName then
        self.info:SetText(info.status)
    end
end

function GuildbookGuildbankCharacterListviewItemMixin:SetDataBinding(binding, height)
    self.characterName = binding.label
    self.icon:SetAtlas(binding.atlas)
    self.text:SetText(Ambiguate(binding.label, "short"))
    self.icon:SetSize(height-2, height-2)
    if binding.showMask then
        self.mask:Show()
    end

    if binding.status then
        self.info:SetText(binding.status)
    end

    self:SetScript("OnMouseDown", function()
        self:AdjustPointsOffset(-1,-1)
        if binding.func then
            binding.func()
        end
    end)
end

function GuildbookGuildbankCharacterListviewItemMixin:OnMouseUp()
    self:AdjustPointsOffset(1,1)
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

function GuildbookItemIconFrameMixin:SetItem(itemID, count)
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
    self.count:SetText(count)
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

    if not addon.dropdownWidgets then
       addon.dropdownWidgets = {}
    end
    table.insert(addon.dropdownWidgets, self)
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

    if addon.dropdownWidgets and (#addon.dropdownWidgets > 0) then -- quick fix, need to make sure all dropdowns/flyouts are in table
        for k, dd in ipairs(addon.dropdownWidgets) do
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
    if not addon.dropdownFlyouts then
       addon.dropdownFlyouts = {}
    end
    table.insert(addon.dropdownFlyouts, self)
end

function GuildbookDropdownFlyoutMixin:OnLeave()
    self.delay = C_Timer.NewTicker(DROPDOWN_CLOSE_DELAY, function()
        if not self:IsMouseOver() then
            self:Hide()
        end
    end)
end

function GuildbookDropdownFlyoutMixin:OnShow()

    for k, flyout in ipairs(addon.dropdownFlyouts) do
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



GuildbookCircleLootItemTemplateMixin = {}
function GuildbookCircleLootItemTemplateMixin:OnLoad()
    
end
function GuildbookCircleLootItemTemplateMixin:UpdateLayout()
    local x, y = self:GetSize()
    self.icon:SetSize(x * 0.65, x * 0.65)
    self.mask:SetSize(x * 0.52, x * 0.52)
    self.border:SetSize(x * 0.85, x * 0.85)
    self.label:SetSize(x, y*0.3)
end
function GuildbookCircleLootItemTemplateMixin:SetDataBinding(binding)
    self.label:SetText(binding.subClass)
    self.icon:SetTexture(binding.icon)
    self.border:SetVertexColor(binding.colour.color:GetRGB())
    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetHyperlink(binding.link)
        GameTooltip:Show()
    end)
end
function GuildbookCircleLootItemTemplateMixin:OnLeave(item)
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end



GuildbookProfileSummaryRowAvatarTemplateMixin = {}

function GuildbookProfileSummaryRowAvatarTemplateMixin:OnLoad()
    addon:RegisterCallback("Character_OnDataChanged", self.Character_OnDataChanged, self)
end
function GuildbookProfileSummaryRowAvatarTemplateMixin:Character_OnDataChanged(character)
    if self.character and (self.character.data.name == character.data.name) then
        self.avatar:SetAtlas(self.character:GetProfileAvatar())
    end
end

function GuildbookProfileSummaryRowAvatarTemplateMixin:SetCharacter(character)
    self.character = character;
    self.avatar:SetAtlas(self.character:GetProfileAvatar())
    self.name:SetText("|cffffffff"..Ambiguate(self.character.data.name, "short"))

    local _, class = GetClassInfo(self.character.data.class)
    local colour = RAID_CLASS_COLORS[class]
    self.border:SetVertexColor(colour:GetRGB())
end

function GuildbookProfileSummaryRowAvatarTemplateMixin:OnEnter()
    if self:IsVisible() then
        self.whirl:Show()
        self.anim:Play()
    else
        self.whirl:Hide()
        self.anim:Stop()
    end
    if self.showTooltip then
        
    end
end

function GuildbookProfileSummaryRowAvatarTemplateMixin:OnLeave()
    self.anim:Stop()
end

function GuildbookProfileSummaryRowAvatarTemplateMixin:OnMouseUp()
    if self.character then
        addon:TriggerEvent("Character_OnProfileSelected", self.character)
    end
end




GuildbookRecipeListviewItemMixin = {}

function GuildbookRecipeListviewItemMixin:OnLoad()
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
    addon:RegisterCallback("Database_OnConfigChanged", self.Database_OnConfigChanged, self)
end

function GuildbookRecipeListviewItemMixin:UpdateLayout()

    local reagentWidth = self:GetWidth() - 200;

    if reagentWidth < 169 then
        for k, v in ipairs(self.reagentIcons) do
            v:Hide()
        end
    else
        for k, v in ipairs(self.reagentIcons) do
            v:Show()
        end
    end
end

function GuildbookRecipeListviewItemMixin:Database_OnConfigChanged()
    if self.item and not self.item:IsItemEmpty() then
        if Database:GetConfig("tradeskillsRecipesListviewShowItemID") then
            self.label:SetText(self.item:GetItemID().." "..self.item:GetItemLink())
        else
            self.label:SetText(self.item:GetItemLink())
        end
        self.anim:Play()
    end
end

function GuildbookRecipeListviewItemMixin:SetDataBinding(binding, height)
    self.icon:SetWidth(height - 2)
    self.icon:SetTexture(binding.icon)

    for k, v in ipairs(self.reagentIcons) do
        v:Hide()
    end

    self.item = nil;

    if binding.tradeskillID == 333 then

        self.spell = Spell:CreateFromSpellID(binding.spellID)
        if not self.spell:IsSpellEmpty() then
            self.spell:ContinueOnSpellLoad(function()
                self.label:SetText(self.spell:GetSpellName())
                self.anim:Play()

                self:SetScript("OnEnter", function()
                    if self.spell then
                        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                        GameTooltip:SetSpellByID(self.spell:GetSpellID())
                        GameTooltip:Show()
                    end
                end)
            end)
        end

    else
        self.item = Item:CreateFromItemID(binding.itemID)
        if not self.item:IsItemEmpty() then
            self.item:ContinueOnItemLoad(function()
                if Database:GetConfig("tradeskillsRecipesListviewShowItemID") then
                    self.label:SetText(binding.itemID.." "..self.item:GetItemLink())
                else
                    self.label:SetText(self.item:GetItemLink())
                end
                self.anim:Play()

                self:SetScript("OnEnter", function()
                    if self.item then
                        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                        GameTooltip:SetHyperlink(self.item:GetItemLink())
                        GameTooltip:Show()
                    end
                end)

            end)
        end
    end

    local i = 1;
    local reagents = {}
    for k, v in pairs(binding.reagents) do
        table.insert(reagents, {
            itemID = k,
            count = v
        })
    end
    table.sort(reagents, function(a, b)
        return a.count > b.count;
    end)
    for k, v in ipairs(reagents) do
        self.reagentIcons[k]:SetItem(v.itemID, v.count)
        self.reagentIcons[k]:Show()
    end

    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    self:SetScript("OnMouseDown", function()
        if IsLeftAltKeyDown() then
            if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then
                BrowseName:SetText(string.format('"%s"', self.item:GetItemName()))
                BrowseSearchButton:Click()
            end
        else
            if binding.func then
                binding.func()
            end
        end
    end)

end

function GuildbookRecipeListviewItemMixin:ResetDataBinding()
    for k, v in ipairs(self.reagentIcons) do
        v:Hide()
    end
    self.item = nil;
    self.label:SetText("")
    for i = 1, 8 do
        self.reagentIcons[i]:SetAlpha(0)
    end
    self:SetScript("OnEnter", nil)
end



GuildbookRosterListviewItemMixin = {}
function GuildbookRosterListviewItemMixin:OnLoad()

    self.prof1:SetScript("OnMouseDown", function()
        if self.character then
            addon:TriggerEvent("Character_OnTradeskillSelected", self.character.data.profession1, self.character.data.profession1Recipes)
        end
    end)
    self.prof2:SetScript("OnMouseDown", function()
        if self.character then
            addon:TriggerEvent("Character_OnTradeskillSelected", self.character.data.profession2, self.character.data.profession2Recipes)
        end
    end)

    self.inviteToGroup:SetScript("OnMouseDown", function()
        if self.character then
            InviteUnit(self.character.data.name)
        end
    end)
    self.openProfile:SetScript("OnMouseDown", function()
        if self.character then
            addon:TriggerEvent("Character_OnProfileSelected", self.character)
        end
    end)
    self.openChat:SetScript("OnMouseDown", function()
        if self.character then
            addon:TriggerEvent("Chat_OnChatOpened", self.character.data.name)
        end
    end)
    
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
    addon:RegisterCallback("Character_OnDataChanged", self.Character_OnDataChanged, self)
end

function GuildbookRosterListviewItemMixin:SetDataBinding(binding, height)

    self.character = binding;

    self.classIcon:SetAtlas(self.character:GetClassSpecAtlasName())
    self.name:SetText(Ambiguate(self.character.data.name, "short"))

    self:Update()
end

function GuildbookRosterListviewItemMixin:UpdateLayout()
    local x, y = self:GetSize()

    if x > 850 then
        --self.name:SetWidth(160)
        self.rank:SetWidth(110)
        self.rank:Show()
        self.zone:SetWidth(110)
        self.zone:Show()
        self.publicNote:SetWidth(250)
        self.publicNote:Show()

    elseif x < 850 and x > 740 then
        --self.name:SetWidth(140)
        self.rank:SetWidth(1)
        self.rank:Hide()
        self.zone:SetWidth(110)
        self.zone:Show()
        self.publicNote:SetWidth(150)
        self.publicNote:Show()

    elseif x < 741 and x > 630 then
        --self.name:SetWidth(120)
        self.rank:SetWidth(1)
        self.rank:Hide()
        self.zone:SetWidth(1)
        self.zone:Hide()
        self.publicNote:SetWidth(150)
        self.publicNote:Show()

    elseif x < 631 then
        --self.name:SetWidth(110)
        self.publicNote:SetWidth(1)
        self.publicNote:Hide()
        self.rank:SetWidth(1)
        self.rank:Hide()
        self.zone:SetWidth(1)
        self.zone:Hide()
    end
end

function GuildbookRosterListviewItemMixin:Update()
    self.level:SetText(self.character.data.level)
    self.zone:SetText(self.character.data.onlineStatus.zone)
    self.rank:SetText(GuildControlGetRankName(self.character.data.rank + 1))
    self.prof1.icon:SetAtlas(self.character:GetTradeskillIcon(1))
    self.prof2.icon:SetAtlas(self.character:GetTradeskillIcon(2))
    if self.character.data.mainSpec == false then
        --self.mainSpecIcon:SetAtlas(self.character:GetClassSpecAtlasName())
        self.mainSpecIcon:Hide()
        self.mainSpec:SetText("|cff7f7f7f".."No Spec")
    else
        self.mainSpecIcon:SetAtlas(self.character:GetClassSpecAtlasName("primary"))
        self.mainSpecIcon:Show()
        local localeName, engName, Id = self.character:GetSpec("primary")
        self.mainSpec:SetText(engName)
    end
    self.publicNote:SetText(self.character.data.publicNote)
    self.openProfile.background:SetAtlas(self.character:GetProfileAvatar())

    if self.character.data.onlineStatus.isOnline == true then
        self.name:SetTextColor(1,1,1)
        self.publicNote:SetTextColor(1,1,1)
        self.level:SetTextColor(1,1,1)
        self.mainSpec:SetTextColor(1,1,1)
        self.zone:SetTextColor(1,1,1)
        self.rank:SetTextColor(1,1,1)
    else
        self.name:SetTextColor(0.5,0.5,0.5)
        self.publicNote:SetTextColor(0.5,0.5,0.5)
        self.level:SetTextColor(0.5,0.5,0.5)
        self.mainSpec:SetTextColor(0.5,0.5,0.5)
        self.zone:SetTextColor(0.5,0.5,0.5)
        self.rank:SetTextColor(0.5,0.5,0.5)
    end
end

function GuildbookRosterListviewItemMixin:Character_OnDataChanged(character)
    if self.character.data.guid == character.data.guid then
        self:Update()
    end
end

function GuildbookRosterListviewItemMixin:ResetDataBinding()
    
end


function GuildbookRosterListviewItemMixin:OnEnter()

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    -- i contacted the author of attune to check it was ok to add their addon data 
    if Attune_DB and Attune_DB.toons[self.character.data.name] then
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
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end





-- this function needs to be cleaned up, its using a nasty set of variables
-- function GuildbookRosterListviewItemMixin:SetCharacter(member)
--     self.guid = member.guid
--     self.character = gb:GetCharacterFromCache(member.guid)

--     self.ClassIcon:SetAtlas(string.format("GarrMission_ClassIcon-%s", self.character.Class))
--     self.ClassIcon:Show()
--     --self.Name:SetText(character.isOnline and self.character.Name or "|cffB1B3AB"..self.character.Name)
--     self.Name:SetText(self.character.Name)
--     self.Level:SetText(self.character.Level)
--     local mainSpec = false;
--     if self.character.MainSpec == "Bear" then
--         mainSpec = "Guardian"
--     elseif self.character.MainSpec == "Cat" then
--         mainSpec = "Feral"
--     elseif self.character.MainSpec == "Beast Master" or self.character.MainSpec == "BeastMaster" then
--         mainSpec = "BeastMastery"
--     elseif self.character.MainSpec == "Combat" then
--         mainSpec = "Outlaw"
--     end
--     if self.character.MainSpec and self.character.MainSpec ~= "-" then
--         --print(mainSpec, self.character.MainSpec, self.character.Name)
--         self.MainSpecIcon:SetAtlas(string.format("GarrMission_ClassIcon-%s-%s", self.character.Class, mainSpec and mainSpec or self.character.MainSpec))
--         self.MainSpecIcon:Show()
--         self.MainSpec:SetText(L[self.character.MainSpec])
--     else
--         self.MainSpecIcon:Hide()
--     end
--     local prof1 = false;
--     if self.character.Profession1 == "Engineering" then -- blizz has a spelling error on this atlasname
--         prof1 = "Enginnering";
--     end
--     if self.character.Profession1 ~= "-" then
--         local prof = prof1 and prof1 or self.character.Profession1
--         self.Prof1.icon:SetAtlas(string.format("Mobile-%s", prof))
--         if self.character.Profession1Spec then
--             --local profSpec = GetSpellDescription(self.character.Profession1Spec)
--             local profSpec = GetSpellInfo(self.character.Profession1Spec)
--             self.Prof1.tooltipText = gb:GetLocaleProf(prof).." |cffffffff"..profSpec
--         else
--             self.Prof1.tooltipText = gb:GetLocaleProf(prof)
--         end
--         self.Prof1.func = function()
--             loadGuildMemberTradeskills(self.guid, prof)
--         end
--         self.Prof1:Show()
--     else
--         self.Prof1:Hide()
--     end
--     local prof2 = false;
--     if self.character.Profession2 == "Engineering" then -- blizz has a spelling error on this atlasname
--         prof2 = "Enginnering";
--     end
--     if self.character.Profession2 ~= "-" then
--         local prof = prof2 and prof2 or self.character.Profession2
--         self.Prof2.icon:SetAtlas(string.format("Mobile-%s", prof))
--         if self.character.Profession2Spec then
--             --local profSpec = GetSpellDescription(self.character.Profession2Spec)
--             local profSpec = GetSpellInfo(self.character.Profession2Spec)
--             self.Prof2.tooltipText = gb:GetLocaleProf(prof).." |cffffffff"..profSpec
--         else
--             self.Prof2.tooltipText = gb:GetLocaleProf(prof)
--         end
--         self.Prof2.func = function()
--             loadGuildMemberTradeskills(self.guid, prof)
--         end
--         self.Prof2:Show()
--     else
--         self.Prof2:Hide()
--     end
--     self.Location:SetText(member.location)
--     self.Rank:SetText(member.rankName)
--     self.PublicNote:SetText(member.publicNote)

--     if self.character and self.character.profile and self.character.profile.avatar then
--         self.openProfile.background:SetTexture(self.character.profile.avatar)
--     else
--         self.openProfile.background:SetAtlas(string.format("raceicon-%s-%s", self.character.Race:lower(), self.character.Gender:lower()))
--     end

-- end



GuildbookSimpleIconLabelMixin = {}
function GuildbookSimpleIconLabelMixin:OnLoad()

end
function GuildbookSimpleIconLabelMixin:SetDataBinding(binding, height)

    self:SetScript("OnMouseDown", nil)

    if binding.backgroundAlpha then
        self.background:SetAlpha(binding.backgroundAlpha)
    else
        self.background:SetAlpha(0)
    end

    self.label:SetText(binding.label)
    if binding.atlas then
        self.icon:SetAtlas(binding.atlas)
    elseif binding.icon then
        self.icon:SetTexture(binding.icon)
    end
    self.icon:SetSize(height-4, height-4)

    if binding.showMask then
        self.mask:Show()
        local x, y = self.icon:GetSize()
        self.icon:SetSize(x + 6, y + 6)
        self.icon:ClearAllPoints()
        self.icon:SetPoint("LEFT", 3, 0)
    else
        self.mask:Hide()
        -- local x, y = self.icon:GetSize()
        -- self.icon:SetSize(x - 2, y - 2)
    end

    if binding.onMouseDown then
        self:SetScript("OnMouseDown", binding.onMouseDown)
        self:EnableMouse(true)
    end

    if binding.link then
        self:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetHyperlink(binding.link)
            GameTooltip:Show()
        end)
        self:SetScript("OnLeave", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)
    end

    if binding.getItemInfoFromID then
        if binding.itemID then
            local item = Item:CreateFromItemID(binding.itemID)
            if not item:IsItemEmpty() then
                item:ContinueOnItemLoad(function()
                    local link = item:GetItemLink()
                    self.label:SetText(link)
                    self:EnableMouse(true)
                    self:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                        GameTooltip:SetHyperlink(link)
                        GameTooltip:Show()
                    end)
                    self:SetScript("OnLeave", function()
                        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                    end)
                    self:SetScript("OnMouseDown", function()
                        if IsControlKeyDown() then
							DressUpItemLink(link)
						elseif IsShiftKeyDown() then
							HandleModifiedItemClick(link)
						end
                        if binding.onMouseDown then
                            binding.onMouseDown()
                        end
                    end)

                    addon:TriggerEvent("Profile_OnItemDataLoaded")
                end)
            end
        end
    end

    --self.anim:Play()
end
function GuildbookSimpleIconLabelMixin:ResetDataBinding()
    self:SetScript("OnMouseDown", nil)
    self:SetScript("OnEnter", nil)
    self:SetScript("OnLeave", nil)
    self:EnableMouse(false)
end


GuildbookStatsGroupMixin = {}
function GuildbookStatsGroupMixin:OnLoad()

end
function GuildbookStatsGroupMixin:SetDataBinding(binding, height)

    self:SetHeight(height)

    self.label:SetText(binding.label)
    self.background:SetTexture(nil)

    if binding.isHeader then
        self.background:SetAtlas("UI-Character-Info-Title")
        self.background:SetAlpha(1)
        self.background:SetHeight(height * 1.4)
        --self:EnableMouse(false)
    else
        if binding.showBounce then
            self.background:SetAtlas("UI-Character-Info-Line-Bounce")
            self.background:SetAlpha(0.6)
            self.background:SetHeight(height * 1.1)
            --self:EnableMouse(false)
        end
    end

end
function GuildbookStatsGroupMixin:ResetDataBinding()

end


GuildbookResistanceFrameMixin = {}
function GuildbookResistanceFrameMixin:OnLoad()
    --addon:RegisterCallback("Character_OnDataChanged", self.Character_OnDataChanged, self)
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end
-- function GuildbookResistanceFrameMixin:Character_OnDataChanged()
    
-- end
function GuildbookResistanceFrameMixin:SetDataBinding(binding)
    if binding.textureId then
        self.icon:SetTexture(binding.textureId)
    else

    end
    self.label:SetText(binding.label)

    --reusing this for auras so check if this is a res binding
    if binding.type == "resistance" then
        self.resistanceId = binding.resistanceId;
        self.resistanceName = binding.resistanceName;
    end

    if binding.onEnter then
        self:SetScript("OnEnter", binding.onEnter)
    end
end
function GuildbookResistanceFrameMixin:ResetDataBinding()
    
end




GuildbookTalentIconFrameMixin = {}
function GuildbookTalentIconFrameMixin:OnLoad()
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    self.pointsBackground:SetTexture(136960)
    self.pointsLabel:SetText(1)
end
function GuildbookTalentIconFrameMixin:SetDataBinding(binding)

    --this func is only called once and is used to set some frame attribute and scripts
    if binding.rowId then
        self.rowId = binding.rowId
    end
    if binding.colId then
        self.colId = binding.colId
    end

    self:SetScript("OnEnter", function()
        if self.talent then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.talent.spellId)
            GameTooltip:Show()
        end
    end)

end
function GuildbookTalentIconFrameMixin:UpdateLayout()
    local x, y = self:GetSize()
    self.pointsBackground:SetSize(x*0.3, x*0.3)
    self.pointsLabel:SetSize(x*0.3, x*0.3)
end
function GuildbookTalentIconFrameMixin:ResetDataBinding()
    
end
function GuildbookTalentIconFrameMixin:SetTalent(talent)
    self.talent = talent;
    local name, _, icon = GetSpellInfo(self.talent.spellId)
    self.icon:SetTexture(icon)
    self.icon:Show()
    self.border:Show()
    self.pointsBackground:Show()
    self.pointsLabel:Show()
    self.pointsLabel:SetText(self.talent.rank)

    if self.talent.rank == self.talent.maxRank then
        self.border:SetAtlas("orderhalltalents-spellborder-yellow")
    elseif self.talent.rank == 0 then
        self.border:SetAtlas("orderhalltalents-spellborder")
    else
        self.border:SetAtlas("orderhalltalents-spellborder-green")
    end
end
function GuildbookTalentIconFrameMixin:ClearTalent()
    self.spellId = nil
    self.border:Hide()
    self.pointsBackground:Hide()
    self.pointsLabel:Hide()
    self.icon:Hide()
end






GuildbookGuildBankListviewItemMixin = {}
function GuildbookGuildBankListviewItemMixin:OnLoad()
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end
function GuildbookGuildBankListviewItemMixin:SetDataBinding(binding, height)
    
    self:SetHeight(height)

    local item = Item:CreateFromItemID(binding.id)
    if not item:IsItemEmpty() then
        item:ContinueOnItemLoad(function()
            self.icon:SetTexture(item:GetItemIcon())
            self.link:SetText(item:GetItemLink())
        end)
    end

    local y = self:GetHeight()
    self.icon:SetSize(y-2, y-2)

    self.info:SetText(string.format("[%d]", binding.count))
end
function GuildbookGuildBankListviewItemMixin:ResetDataBinding()
    self.icon:SetTexture(nil)
    self.link:SetText(nil)
end


local avatarOffsets = {
    [1] = 0,
    [2] = -50,
    [3] = -100,
    [4] = -150,
    [5] = -200,
    [6] = -250,
    [7] = -300,
    [8] = -350,
    [9] = -400,
    [10] = -450,
}
GuildbookProfilesRowMixin = {}
function GuildbookProfilesRowMixin:OnLoad()

end

function GuildbookProfilesRowMixin:SetDataBinding(binding)
    if binding.showHeader then
        self.header:Show()
        self.headerBackground:Show()
        self.header:SetText(binding.header)
    else
        self.header:Hide()
        self.headerBackground:Hide()
    end

    local numCharacters = #binding.characters;
    self.avatar1:ClearAllPoints()
    self.avatar1:SetPoint("BOTTOM", avatarOffsets[numCharacters], 10)

    for i = 1, 10 do
        self["avatar"..i]:Hide()
        if binding.characters[i] then
            self["avatar"..i]:Show()
            self["avatar"..i]:SetCharacter(binding.characters[i])
        end
    end
end
function GuildbookProfilesRowMixin:ResetDataBinding()

end







GuildbookMyCharactersListviewItemMixin = {}
function GuildbookMyCharactersListviewItemMixin:OnLoad()
    addon:RegisterCallback("Character_OnDataChanged", self.Update, self)
    -- self:SetScript("OnMouseDown", function()
    --     if self.character then
    --         addon:TriggerEvent("Character_OnProfileSelected", self.character)
    --     end
    -- end)
end
function GuildbookMyCharactersListviewItemMixin:SetDataBinding(binding, height)
    self.character = binding.character
    self:Update(self.character)
    self.isMain:SetScript("OnClick", function()
        self.character:SetMainCharacter(self.character.data.name)
    end)
end
function GuildbookMyCharactersListviewItemMixin:ResetDataBinding()
    
end
function GuildbookMyCharactersListviewItemMixin:Update(character)
    if self.character.data.guid == character.data.guid then
        self.text:SetText(self.character.data.name)
        self.icon:SetAtlas(self.character:GetProfileAvatar())
    end

    if self.character.data.mainCharacter == self.character.data.name then
        self.isMain:SetChecked(true)
    else
        self.isMain:SetChecked(false)
    end
end




GuildbookBankCharactersListviewItemMixin = {}
function GuildbookBankCharactersListviewItemMixin:OnLoad()
    addon:RegisterCallback("Character_OnDataChanged", self.Update, self)

    self.shareBank.label:SetText("Banks")
    self.shareBank:SetScript("OnClick", function(cb)
        if self.character then
            if addon.guilds and addon.guilds[addon.thisGuild] and addon.guilds[addon.thisGuild].bankRules[self.character.data.name] then
                addon.guilds[addon.thisGuild].bankRules[self.character.data.name].shareBank = cb:GetChecked()
            end
        end
    end)

    self.shareBags.label:SetText("Bags")
    self.shareBags:SetScript("OnClick", function(cb)
        if self.character then
            if addon.guilds and addon.guilds[addon.thisGuild] and addon.guilds[addon.thisGuild].bankRules[self.character.data.name] then
                addon.guilds[addon.thisGuild].bankRules[self.character.data.name].shareBags = cb:GetChecked()
            end
        end
    end)

    self.shareCopper.label:SetText("Gold")
    self.shareCopper:SetScript("OnClick", function(cb)
        if self.character then
            if addon.guilds and addon.guilds[addon.thisGuild] and addon.guilds[addon.thisGuild].bankRules[self.character.data.name] then
                addon.guilds[addon.thisGuild].bankRules[self.character.data.name].shareCopper = cb:GetChecked()
            end
        end
    end)

end
function GuildbookBankCharactersListviewItemMixin:SetDataBinding(binding, height)
    self.character = binding.character
    self:Update(self.character)
    self:SetHeight(height)

end
function GuildbookBankCharactersListviewItemMixin:ResetDataBinding()
    self.shareBank:SetChecked(false)
    self.shareBags:SetChecked(false)
    self.shareCopper:SetChecked(false)
end
function GuildbookBankCharactersListviewItemMixin:Update(character)
    if self.character.data.guid == character.data.guid then
        self.text:SetText(self.character.data.name)
        self.icon:SetAtlas(self.character:GetProfileAvatar())

        if addon.guilds and addon.guilds[addon.thisGuild] and addon.guilds[addon.thisGuild].bankRules[self.character.data.name] then
            local rules = addon.guilds[addon.thisGuild].bankRules[self.character.data.name];
            self.shareBank:SetChecked(rules.shareBank)
            self.shareBags:SetChecked(rules.shareBags)
            self.shareCopper:SetChecked(rules.shareCopper)
            self.ranks:SetText((rules.shareRank and GuildControlGetRankName(rules.shareRank + 1)) or "-")
        end

        --1 and GuildControlGetNumRanks() GuildControlGetRankName(index)
        --use this here as ranks can change
        local ranks = {}
        for i = 1, GuildControlGetNumRanks() do
            local rankName = GuildControlGetRankName(i)
            table.insert(ranks, {
                text = string.format("[%d] %s", (i-1), rankName),
                func = function ()
                    if self.character then
                        if addon.guilds and addon.guilds[addon.thisGuild] and addon.guilds[addon.thisGuild].bankRules[self.character.data.name] then
                            addon.guilds[addon.thisGuild].bankRules[self.character.data.name].shareRank = (i-1)
                        end
                    end
                end,
            })
        end
        self.ranks:SetMenu(ranks)
    end

    if addon.api.characterIsMine(self.character.data.name) then
        self.shareBank:Enable()
        self.shareBags:Enable()
        self.shareCopper:Enable()
        self.ranks:EnableMouse(true)
    else
        self.shareBank:Disable()
        self.shareBags:Disable()
        self.shareCopper:Disable()
        self.ranks:EnableMouse(false)
    end

end



GuildbookChatBubbleMixin = {}
function GuildbookChatBubbleMixin:OnLoad()
    
end
function GuildbookChatBubbleMixin:SetDataBinding(binding)

    if binding.sender == addon.thisCharacter then
        self.message:SetJustifyH("RIGHT")

        if Database.db.characterDirectory[binding.sender] then
            local _, class = GetClassInfo(Database.db.characterDirectory[binding.sender].class)
            if class then
                local r, g, b, hex = GetClassColor(class)
                self.message:SetText(string.format("|c%s%s|r [%s]\n%s", hex, binding.sender, date("%T", binding.timestamp), binding.message))
            else
                self.message:SetText(string.format("%s [%s]\n%s", binding.sender, date("%T", binding.timestamp), binding.message))
            end
        else
            self.message:SetText(string.format("%s [%s]\n%s", binding.sender, date("%T", binding.timestamp), binding.message))
        end

    else
        self.message:SetJustifyH("LEFT")

        if Database.db.characterDirectory[binding.sender] then
            local _, class = GetClassInfo(Database.db.characterDirectory[binding.sender].class)
            if class then
                local r, g, b, hex = GetClassColor(class)
                self.message:SetText(string.format("[%s] |c%s%s|r\n%s", date("%T", binding.timestamp), hex, binding.sender, binding.message))
            else
                self.message:SetText(string.format("[%s] %s\n%s", date("%T", binding.timestamp), binding.sender, binding.message))
            end
        else
            self.message:SetText(string.format("[%s] %s\n%s", date("%T", binding.timestamp), binding.sender, binding.message))
        end
    end
end
function GuildbookChatBubbleMixin:ResetDataBinding()
    
end

