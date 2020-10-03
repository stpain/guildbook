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

Guildbook.GuildMemberDetailFrame = {
    Labels = {
        MainSpec = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailMainSpecLabel', 'OVERLAY', 'GameFontNormal'),
        OffSpec = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailOffSpecLabel', 'OVERLAY', 'GameFontNormal'),     
        Professions = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailProfessionsLabel', 'OVERLAY', 'GameFontNormal'),     
        Main = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailMainLabel', 'OVERLAY', 'GameFontNormal'),   
        ilvl = GuildMemberDetailFrame:CreateFontString('GuildMemberDetaililvlLabel', 'OVERLAY', 'GameFontNormal'),   
    },
    Text = {
        MainSpec = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailMainSpecText', 'OVERLAY', 'GameFontNormal'),
        OffSpec = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailOffSpecText', 'OVERLAY', 'GameFontNormal'),
        Profession1 = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailProfession1Text', 'OVERLAY', 'GameFontNormal'),
        Profession2 = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailProfession2Text', 'OVERLAY', 'GameFontNormal'),
        Main = GuildMemberDetailFrame:CreateFontString('GuildMemberDetailMainText', 'OVERLAY', 'GameFontNormal'),
        ilvl = GuildMemberDetailFrame:CreateFontString('GuildMemberDetaililvlText', 'OVERLAY', 'GameFontNormal'),
    },
}

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
        for k, label in pairs(self.GuildMemberDetailFrame.Labels) do
            label:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
        end
    end
end

function Guildbook:ClearGuildMemberDetailFrame()
    for k, v in pairs(self.GuildMemberDetailFrame.Text) do
        v:SetText('')
    end
end

function Guildbook:UpdateGuildMemberDetailFrame(guid)
    for k, v in pairs(self.GuildMemberDetailFrame.Text) do
        v:SetText('')
    end
    local guildName = Guildbook:GetGuildName()
    if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
        if GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid] then
            local character = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][guid]
            self.GuildMemberDetailFrame.Text.Profession1:SetText(string.format('%s %s [%s]', Guildbook.Data.Profession[character.Profession1].FontStringIconSMALL, character.Profession1, character.Profession1Level))
            self.GuildMemberDetailFrame.Text.Profession2:SetText(string.format('%s %s [%s]', Guildbook.Data.Profession[character.Profession2].FontStringIconSMALL, character.Profession2, character.Profession2Level))
            self.GuildMemberDetailFrame.Text.Main:SetText(character.MainCharacter)
            self.GuildMemberDetailFrame.Text.ilvl:SetText(character.ItemLevel)

            -- the string formatting seems to sometimes mess up, for now just update as plain text TODO: look into formatting
            if character.MainSpecIsPvP == 'true' then
                self.GuildMemberDetailFrame.Text.MainSpec:SetText(character.MainSpec) --string.format('%s %s %s', character.MainSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]].FontStringIcon, Guildbook.Data.StatusIconStringsSMALL.PVP))
            else
                self.GuildMemberDetailFrame.Text.MainSpec:SetText(character.MainSpec) --string.format('%s %s', character.MainSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.MainSpec]].FontStringIcon))
            end
            if character.OffSpecIsPvP == 'true' then
                self.GuildMemberDetailFrame.Text.OffSpec:SetText(character.OffSpec) --string.format('%s %s %s', character.OffSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.OffSpec]].FontStringIcon, Guildbook.Data.StatusIconStringsSMALL.PVP))
            else
                self.GuildMemberDetailFrame.Text.OffSpec:SetText(character.OffSpec) --string.format('%s %s', character.OffSpec, Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[character.Class][character.OffSpec]].FontStringIcon))
            end
        end
    end
end

function Guildbook:SetupGuildMemberDetailframe()
    for k, label in pairs(self.GuildMemberDetailFrame.Labels) do
        label:SetText(L[k])
        label:SetFont("Fonts\\FRIZQT__.TTF", 10)
    end
    self.GuildMemberDetailFrame.Labels.ilvl:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -50)
    self.GuildMemberDetailFrame.Labels.MainSpec:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -70)
    self.GuildMemberDetailFrame.Labels.OffSpec:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -90)
    self.GuildMemberDetailFrame.Labels.Professions:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -110)
    self.GuildMemberDetailFrame.Labels.Main:SetPoint('BOTTOMLEFT', GuildMemberRemoveButton, 'TOPLEFT', 8, 5)

    for k, text in pairs(self.GuildMemberDetailFrame.Text) do
        text:SetText(L[k])
        text:SetFont("Fonts\\FRIZQT__.TTF", 12)
        text:SetTextColor(1,1,1,1)
    end
    self.GuildMemberDetailFrame.Text.Main:SetPoint('LEFT', self.GuildMemberDetailFrame.Labels.Main, 'RIGHT', 3, 0)
    self.GuildMemberDetailFrame.Text.MainSpec:SetPoint('LEFT', self.GuildMemberDetailFrame.Labels.MainSpec, 'RIGHT', 3, 0)
    self.GuildMemberDetailFrame.Text.OffSpec:SetPoint('LEFT', self.GuildMemberDetailFrame.Labels.OffSpec, 'RIGHT', 3, 0)
    self.GuildMemberDetailFrame.Text.Profession1:SetPoint('TOPLEFT', self.GuildMemberDetailFrame.Labels.Professions, 'BOTTOMLEFT', 0, -5)
    self.GuildMemberDetailFrame.Text.Profession2:SetPoint('TOPLEFT', self.GuildMemberDetailFrame.Text.Profession1, 'BOTTOMLEFT', 0, -5)
    self.GuildMemberDetailFrame.Text.ilvl:SetPoint('BOTTOMLEFT', self.GuildMemberDetailFrame.Labels.ilvl, 'BOTTOMRIGHT', 3, 0)
end


