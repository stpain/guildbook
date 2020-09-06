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
local PRINT = Guildbook.PRINT
--might be used in future updates
--local tinsert, tsort = table.insert, table.sort
--local ceil, floor = math.ceil, math.floor 

Guildbook.GuildMemberDetailFrame = {
    MemberDataMsgKeys = { 'MainSpec', 'OffSpec', 'Fishing', 'Cooking', 'FirstAid', 'Prof1', 'Prof1Level', 'Prof2', 'Prof2Level', 'MainCharacter', 'ilvl', 'MainSpecIsPvP', 'OffSpecIsPvP' }, --data returned will be in this order
    CurrentMember = {
        MainSpec = nil,
        OffSpec = nil,
        Fishing = nil,
        Cooking = nil,
        FirstAid = nil,
        Prof1 = nil,
        Prof1Level = nil,
        Prof2 = nil,
        Prof2Level = nil,
        MainCharacter = nil,
        ilvl = nil,
        MainSpecIsPvP = 'false',
        OffSpecIsPvP = 'false',
    },
    ClearCurrentMember = function(self)
        for k, v in pairs(self.CurrentMember) do
            v = nil
        end
        self.CurrentMember.MainSpecIsPvP = 'false'
        self.CurrentMember.OffSpecIsPvP = 'false'
    end,
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
    UpdateLabels = function(self)
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
            for k, label in pairs(self.Labels) do
                label:SetTextColor(unpack(Guildbook.Data.Class[class].RGB))
            end
        end
    end,
    ClearText = function(self)
        for k, v in pairs(self.Text) do
            v:SetText('')
        end
    end,
    UpdateText = function(self)
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(GetGuildRosterSelection())
        --self.Text.MainSpec:SetText(tostring(self.CurrentMember.MainSpec..' '..Guildbook.Data.SpecFontStringIconSMALL[class][self.CurrentMember.MainSpec]..' '..Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[class][self.CurrentMember.MainSpec]].FontStringIcon))
        --self.Text.OffSpec:SetText(tostring(self.CurrentMember.OffSpec..' '..Guildbook.Data.SpecFontStringIconSMALL[class][self.CurrentMember.OffSpec]..' '..Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[class][self.CurrentMember.OffSpec]].FontStringIcon))
        if self.CurrentMember.MainSpecIsPvP == 'true' then
            self.Text.MainSpec:SetText(tostring(self.CurrentMember.MainSpec..' '..Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[class][self.CurrentMember.MainSpec]].FontStringIcon..' '..Guildbook.Data.StatusIconStringsSMALL.PVP))
        else
            self.Text.MainSpec:SetText(tostring(self.CurrentMember.MainSpec..' '..Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[class][self.CurrentMember.MainSpec]].FontStringIcon))
        end
        if self.CurrentMember.OffSpecIsPvP == 'true' then
            self.Text.OffSpec:SetText(tostring(self.CurrentMember.OffSpec..' '..Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[class][self.CurrentMember.OffSpec]].FontStringIcon..' '..Guildbook.Data.StatusIconStringsSMALL.PVP))
        else
            self.Text.OffSpec:SetText(tostring(self.CurrentMember.OffSpec..' '..Guildbook.Data.RoleIcons[Guildbook.Data.SpecToRole[class][self.CurrentMember.OffSpec]].FontStringIcon))
        end
        self.Text.Profession1:SetText(tostring(Guildbook.Data.Profession[self.CurrentMember.Prof1].FontStringIconSMALL..' '..self.CurrentMember.Prof1..' '..self.CurrentMember.Prof1Level))
        self.Text.Profession2:SetText(tostring(Guildbook.Data.Profession[self.CurrentMember.Prof2].FontStringIconSMALL..' '..self.CurrentMember.Prof2..' '..self.CurrentMember.Prof2Level))
        self.Text.Main:SetText(self.CurrentMember.MainCharacter)
        self.Text.ilvl:SetText(self.CurrentMember.ilvl)
    end,    
    DrawLabels = function(self)
        for k, label in pairs(self.Labels) do
            label:SetText(L[k])
            label:SetFont("Fonts\\FRIZQT__.TTF", 10)
        end
        self.Labels.ilvl:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -50)
        self.Labels.MainSpec:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -70)
        self.Labels.OffSpec:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -90)
        self.Labels.Professions:SetPoint('TOPLEFT', GuildMemberDetailOfficerNoteLabel, 'BOTTOMLEFT', 0, -110)
        self.Labels.Main:SetPoint('BOTTOMLEFT', GuildMemberRemoveButton, 'TOPLEFT', 8, 5)
    end,
    DrawText = function(self)
        for k, text in pairs(self.Text) do
            text:SetText(L[k])
            text:SetFont("Fonts\\FRIZQT__.TTF", 12)
            text:SetTextColor(1,1,1,1)
        end
        self.Text.Main:SetPoint('LEFT', self.Labels.Main, 'RIGHT', 3, 0)
        self.Text.MainSpec:SetPoint('LEFT', self.Labels.MainSpec, 'RIGHT', 3, 0)
        self.Text.OffSpec:SetPoint('LEFT', self.Labels.OffSpec, 'RIGHT', 3, 0)
        self.Text.Profession1:SetPoint('TOPLEFT', self.Labels.Professions, 'BOTTOMLEFT', 0, -5)
        self.Text.Profession2:SetPoint('TOPLEFT', self.Text.Profession1, 'BOTTOMLEFT', 0, -5)
        self.Text.ilvl:SetPoint('BOTTOMLEFT', self.Labels.ilvl, 'BOTTOMRIGHT', 3, 0)
    end,
    HandleRosterUpdate = function(self, ...)
        if GetGuildRosterSelection() > 0 then
            self:UpdateLabels()
        end
    end,
    HandleAddonMessage = function(self, ...)
        local prefix = select(1, ...)
        local msg = select(2, ...)
        local sender = select(5, ...)
        if prefix == 'gb-mdf-req' then --guildbook-memberDetailFrame-request
            local dataSent = C_ChatInfo.SendAddonMessage('gb-mdf-data', tostring(GUILDBOOK_CHARACTER['MainSpec']..':'..GUILDBOOK_CHARACTER['OffSpec']..':'..Guildbook.GetProfessionData()..':'..Guildbook.GetMainCharacter()..':'..Guildbook.GetItemLevel()..':'..tostring(GUILDBOOK_CHARACTER['MainSpecIsPvP'])..':'..tostring(GUILDBOOK_CHARACTER['OffSpecIsPvP'])), 'WHISPER', sender)
            if dataSent then
                DEBUG('data sent to '..sender)
            end
        elseif prefix == 'gb-mdf-data' then --guildbook-memberDetailFrame-data
            DEBUG('data reply from '..sender)
            if GuildMemberDetailFrame:IsVisible() and GetGuildRosterSelection() then
                self:ClearCurrentMember()
                --local keys = { 'MainSpec', 'OffSpec', 'Fishing', 'Cooking', 'FirstAid', 'Prof1', 'Prof1Level', 'Prof2', 'Prof2Level', 'MainCharacter', 'ilvl', 'MainSpecIsPvp', 'OffSpecIsPvp' } --data returned will be in this order
                local i = 1
                for d in string.gmatch(msg, '[^:]+') do
                    --self.CurrentMember[keys[i]] = d
                    self.CurrentMember[self.MemberDataMsgKeys[i]] = d
                    i = i + 1
                end
                --GuildRoster()
                self:UpdateText()
            end
        end
    end,
}
