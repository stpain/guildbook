--[==[

Copyright ©2020 Samuel Thomas Pain

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

--guild frame member detail frame extension
--adds spec and prof data to the detail frame

local addonName, Guildbook = ...

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG

-- PortraitMixin = {}

-- function PortraitMixin:SetPortraitIcon(iconFileID)
-- 	if (iconFileID == nil or iconFileID == 0) then
-- 		-- unknown icon file ID; use the default silhouette portrait
-- 		self.Portrait:SetTexture("Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait");
-- 	else
-- 		self.Portrait:SetTexture(iconFileID);
-- 	end
-- end

-- function Guildbook:CreatePortrait(name, parent, anchor, x, y)
--     local f = CreateFrame('FRAME', name, parent, "PortraitTemplate")
--     f:SetPoint(anchor, x, y)
--     return f
-- end


Guildbook.GuildMemberDetailFrame = {}

function Guildbook:UpdateGuildMemberDetailFrameLabels()
    local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(GetGuildRosterSelection())
    if class then
        if GuildMemberDetailName:GetText() then
            GuildMemberDetailName:SetText(GuildMemberDetailName:GetText()..' '..Guildbook.Data.Class[class].FontStringIconSMALL)
        end
        GuildMemberDetailName:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
        GuildMemberDetailZoneLabel:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
        GuildMemberDetailRankLabel:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
        GuildMemberDetailOnlineLabel:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
        GuildMemberDetailNoteLabel:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
        GuildMemberDetailOfficerNoteLabel:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))        
        -- for k, label in pairs(self.GuildMemberDetailFrame.Labels) do
        --     label:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
        -- end
        self.GuildMemberDetailFrame.AttunementsFrame.header:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
    end
end

function Guildbook:ClearGuildMemberDetailFrame()
    -- for k, v in pairs(self.GuildMemberDetailFrame.Text) do
    --     v:SetText('')
    -- end
    for k, v in pairs(self.GuildMemberDetailFrame.Attunements) do
        v.Checked:SetTexCoord(0.5, 1, 0, 0.5)
    end
end

function Guildbook:UpdateGuildMemberDetailFrame(guid)
    self:ClearGuildMemberDetailFrame()
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
        if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
            local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
            -- self.GuildMemberDetailFrame.Text.Profession1:SetText(string.format('%s %s [%s]', Guildbook.Data.Profession[character.Profession1].FontStringIconSMALL, character.Profession1, character.Profession1Level))
            -- self.GuildMemberDetailFrame.Text.Profession2:SetText(string.format('%s %s [%s]', Guildbook.Data.Profession[character.Profession2].FontStringIconSMALL, character.Profession2, character.Profession2Level))
            -- self.GuildMemberDetailFrame.Text.Main:SetText(character.MainCharacter)
            -- self.GuildMemberDetailFrame.Text.ilvl:SetText(character.ItemLevel)

            -- -- the string formatting seems to sometimes mess up, for now just update as plain text TODO: look into formatting
            -- if character.MainSpecIsPvP == 'true' then
            --     self.GuildMemberDetailFrame.Text.MainSpec:SetText(character.MainSpec) --string.format('%s %s %s', character.MainSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]].FontStringIcon, Guildbook.Data.StatusIconStringsSMALL.PVP))
            -- else
            --     self.GuildMemberDetailFrame.Text.MainSpec:SetText(character.MainSpec) --string.format('%s %s', character.MainSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]].FontStringIcon))
            -- end
            -- if character.OffSpecIsPvP == 'true' then
            --     self.GuildMemberDetailFrame.Text.OffSpec:SetText(character.OffSpec) --string.format('%s %s %s', character.OffSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.OffSpec]].FontStringIcon, Guildbook.Data.StatusIconStringsSMALL.PVP))
            -- else
            --     self.GuildMemberDetailFrame.Text.OffSpec:SetText(character.OffSpec) --string.format('%s %s', character.OffSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.OffSpec]].FontStringIcon))
            -- end

            if character.AttunementsKeys and next(character.AttunementsKeys) then
                for raid, val in pairs(character.AttunementsKeys) do
                    if self.GuildMemberDetailFrame.Attunements[raid] then
                        if val == true then
                            self.GuildMemberDetailFrame.Attunements[raid].Checked:SetTexCoord(0, 0.5, 0, 0.5)
                        end
                    end
                end
            end        
        end
    end
end

function Guildbook:SetupGuildMemberDetailframe()

    local classicAttunements = {
        UBRS = false,
        MC = false,
        ONY = false,
        BWL = false,
        NAXX = false,
    }

    --self.GuildMemberDetailFrame.Portrait = Guildbook:CreatePortrait('Portrait', GuildMemberDetailFrame, 'TOPRIGHT', -50, -50, 90, 90)

    -- for k, label in pairs(self.GuildMemberDetailFrame.Labels) do
    --     label:SetText(L[k])
    --     label:SetFont("Fonts\\FRIZQT__.TTF", 10)
    -- end
    -- self.GuildMemberDetailFrame.Labels.ilvl:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -50)
    -- self.GuildMemberDetailFrame.Labels.MainSpec:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -70)
    -- self.GuildMemberDetailFrame.Labels.OffSpec:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -90)
    -- self.GuildMemberDetailFrame.Labels.Professions:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -110)
    -- self.GuildMemberDetailFrame.Labels.Main:SetPoint('BOTTOMLEFT', GuildMemberRemoveButton, 'TOPLEFT', 8, 5)

    -- for k, text in pairs(self.GuildMemberDetailFrame.Text) do
    --     text:SetText(L[k])
    --     text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    --     text:SetTextColor(1,1,1,1)
    -- end
    -- self.GuildMemberDetailFrame.Text.Main:SetPoint('LEFT', self.GuildMemberDetailFrame.Labels.Main, 'RIGHT', 3, 0)
    -- self.GuildMemberDetailFrame.Text.MainSpec:SetPoint('LEFT', self.GuildMemberDetailFrame.Labels.MainSpec, 'RIGHT', 3, 0)
    -- self.GuildMemberDetailFrame.Text.OffSpec:SetPoint('LEFT', self.GuildMemberDetailFrame.Labels.OffSpec, 'RIGHT', 3, 0)
    -- self.GuildMemberDetailFrame.Text.Profession1:SetPoint('TOPLEFT', self.GuildMemberDetailFrame.Labels.Professions, 'BOTTOMLEFT', 0, -5)
    -- self.GuildMemberDetailFrame.Text.Profession2:SetPoint('TOPLEFT', self.GuildMemberDetailFrame.Text.Profession1, 'BOTTOMLEFT', 0, -5)
    -- self.GuildMemberDetailFrame.Text.ilvl:SetPoint('BOTTOMLEFT', self.GuildMemberDetailFrame.Labels.ilvl, 'BOTTOMRIGHT', 3, 0)

    --375502
    self.GuildMemberDetailFrame.AttunementsFrame = self:CreateTooltipPanel('GuildbookGuildMemberDetailFrameAttunementFrame', GuildMemberDetailFrame, 'BOTTOMLEFT', 16, 33, 120, 110, L['Attunements'])
    self.GuildMemberDetailFrame.AttunementsFrame:SetBackdropColor(0.5, 0.5, 0.5, 0)
    self.GuildMemberDetailFrame.AttunementsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)
    self.GuildMemberDetailFrame.AttunementsFrame.header:ClearAllPoints()
    self.GuildMemberDetailFrame.AttunementsFrame.header:SetFont("Fonts\\FRIZQT__.TTF", 10)
    self.GuildMemberDetailFrame.AttunementsFrame.header:SetPoint('BOTTOMLEFT', 'GuildbookGuildMemberDetailFrameAttunementFrame', 'TOPLEFT', 3, 2)
    
    self.GuildMemberDetailFrame.AttunementsFrame.ScrollFrame = CreateFrame("ScrollFrame", "GuildbookGuildMemberDetailFrameAttunementFrameScrollFrame", self.GuildMemberDetailFrame.AttunementsFrame, "UIPanelScrollFrameTemplate")
    self.GuildMemberDetailFrame.AttunementsFrame.ScrollFrame:SetPoint("TOPLEFT", 2, -12)
    self.GuildMemberDetailFrame.AttunementsFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -32, 6)
    self.GuildMemberDetailFrame.AttunementsFrame.ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local newValue = self:GetVerticalScroll() - (delta * 20)
        if (newValue < 0) then
            newValue = 0;
        elseif (newValue > self:GetVerticalScrollRange()) then
            newValue = self:GetVerticalScrollRange()
        end
        self:SetVerticalScroll(newValue)
    end)
    local attunementsScrollChild = CreateFrame("Frame", nil, self.GuildMemberDetailFrame.AttunementsFrame.ScrollFrame)
    attunementsScrollChild:SetPoint("TOPLEFT", 0, 3)
    attunementsScrollChild:SetSize(100, 120)
    self.GuildMemberDetailFrame.AttunementsFrame.ScrollFrame:SetScrollChild(attunementsScrollChild)

    self.GuildMemberDetailFrame.Attunements = {}
    local i = 0
    for raid, val in pairs(classicAttunements) do
        local f = CreateFrame('FRAME', 'GuildbookGuildMemberDetailFrameAttunementFrame'..raid, attunementsScrollChild)
        f:SetPoint('TOPLEFT', 2, (i * -16) - 2)
        f:SetPoint('TOPRIGHT', -2, (i * -16) - 2)
        f:SetHeight(16)

        f.Raid = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        f.Raid:SetPoint('LEFT', 4, 0)
        f.Raid:SetText(raid)
        f.Raid:SetTextColor(1,1,1,1)

        f.Checked = f:CreateTexture(nil, 'OVERALY')
        f.Checked:SetPoint('RIGHT', -10, 0)
        f.Checked:SetSize(16, 16)
        f.Checked:SetTexture(375502)
        f.Checked:SetTexCoord(0, 0.5, 0, 0.5)

        i = i + 1
        self.GuildMemberDetailFrame.Attunements[raid] = f
    end


    -- self.GuildMemberDetailFrame.AttunementDropdown = CreateFrame('FRAME', 'GuildbookGuildMemberDetailFrameAttunementDropDown', GuildMemberDetailFrame, "UIDropDownMenuTemplate")
    -- self.GuildMemberDetailFrame.AttunementDropdown:SetPoint('TOPRIGHT', OfficerNoteText, 'BOTTOMRIGHT', 30, -5.0)
    -- UIDropDownMenu_SetWidth(self.GuildMemberDetailFrame.AttunementDropdown, 100)
    -- UIDropDownMenu_SetText(self.GuildMemberDetailFrame.AttunementDropdown, 'Attunements')
    -- _G['GuildbookGuildMemberDetailFrameAttunementDropDownButton']:SetScript('OnClick', function()
    --     if DropDownList1:IsVisible() then
    --         CloseDropDownMenus()
    --     else
    --         local t = {}
    --         local guildName = Guildbook:GetGuildName()
    --         if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
    --             if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][Guildbook.GuildMemberDetailFrame.CurrentMemberGUID] then
    --                 local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][Guildbook.GuildMemberDetailFrame.CurrentMemberGUID]
    --                 for k, v in pairs(character["AttunementsKeys"]) do
    --                     table.insert(t, {
    --                         text = k,
    --                         checked = v,
    --                         isNotRadio = true,
    --                     })
    --                 end
    --                 table.insert(t, {
    --                     text = 'Cancel',
    --                     notCheckable = true,
    --                     func = CloseDropDownMenus()
    --                 })
    --             end
    --         end
    --         EasyMenu(t, Guildbook.GuildMemberDetailFrame.AttunementDropdown, Guildbook.GuildMemberDetailFrame.AttunementDropdown, 10, 10, 'NONE')
    --     end
    -- end)
end


