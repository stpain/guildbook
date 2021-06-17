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

local addonName, Guildbook = ...

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG
local PRINT = Guildbook.PRINT


StaticPopupDialogs['Error'] = {
    text = '|cffC41F3BError|r: %s',
    button1 = 'Yes',
    --button2 = 'Cancel',
    OnAccept = function(self, data)

    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['Reload'] = {
    text = 'Settings have changed and a UI reload is required!',
    button1 = 'Reload UI',
    --button2 = 'Cancel',
    OnAccept = function(self)
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookDeleteGuild'] = {
    text = 'Delete all data for %s',
    button1 = 'Yes',
    button2 = 'Cancel',
    OnAccept = function(self, data)
        GUILDBOOK_GLOBAL['GuildRosterCache'][data.Guild] = nil
        GUILDBOOK_GLOBAL['Calendar'][data.Guild] = nil
        GUILDBOOK_GLOBAL['CalendarDeleted'][data.Guild] = nil
        print('All data for '..data.Guild..' deleted')
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookResetCharacter'] = {
    text = 'Reset data for '..select(1, UnitName("player"))..' to default values?',
    button1 = 'Reset',
    button2 = 'Cancel',
    OnAccept = function(self)
        wipe(GUILDBOOK_CHARACTER)
        local guildName = Guildbook:GetGuildName()
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][UnitGUID('player')] = nil
        end
        GUILDBOOK_CHARACTER = Guildbook.Data.DefaultCharacterSettings
        ReloadUI()
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookResetGlobalSettings'] = {
    text = 'Reset global settings to default values? \n\nThis will delete all data about all guilds you are a member of.',
    button1 = 'Reset',
    button2 = 'Cancel',
    OnAccept = function(self)
        wipe(GUILDBOOK_GLOBAL)
        GUILDBOOK_GLOBAL = Guildbook.Data.DefaultGlobalSettings
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
        ReloadUI()
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookGatheringDatabaseEditObject'] = {
    text = '-',
    button1 = 'Update',
    button2 = 'Cancel',
    hasEditBox = true,
    OnShow = function(self)
        self.button1:Disable()
    end,
    EditBoxOnTextChanged = function(self)
        if self:GetText() ~= '' then
            if(self:GetText():match("%W")) then
                self:GetParent().button1:Disable()
            end
            self:GetParent().button1:Enable()
        end
    end,
    OnAccept = function(self, data, data2) --data is the gameObject and data2 is the key within the object
        if tostring(type(data[data2])) == 'number' then
            data[data2] = tonumber(self.editBox:GetText())
        else
            data[data2] = tostring(self.editBox:GetText())
        end
        PRINT(Guildbook.FONT_COLOUR, tostring('updated game object field: '..data2..' with new value: '..self.editBox:GetText()))
        Guildbook.OptionsInterface.GatheringDatabase.RefreshListView()
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookUpdates'] = {
    text = 'Version: %s\n\n%s',
    button1 = 'OK',
    hasEditBox = true,
    OnAccept = function(self)

    end,
    OnShow = function(self)
        --self.icon:SetTexture(132049)
        self.icon:SetTexture(nil)
        self.editBox:SetMaxLetters(50)
        self.editBox:SetWidth(300)
        self.editBox:SetText('https://www.curseforge.com/wow/addons/guildbook')
        self.editBox:HighlightText()
    end,
    OnHide = function(self)
        --self.icon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}


StaticPopupDialogs['SendProfessionData'] = {
    text = L["SEND_TRADESDKILL_DATA"],
    button1 = "No",
    button2 = "Yes",
    OnShow = function(self)
        self.button2:SetEnabled(false)
        local i = 7
        C_Timer.NewTicker(1, function()
            _G[self:GetName().."Text"]:SetText(L["SEND_TRADESDKILL_DATA"]..i)
            if i < 1 then
                self.button2:SetEnabled(true)
            end
            i = i - 1;
        end, 8)
    end,
    OnAccept = function()
        print("A wise choice!")
    end,
    OnCancel = function(self, args)
        Guildbook:SendTradeskillData(args.prof, "GUILD", nil)
        GuildbookProfScan.commsOut:SetText("sending tradeskill data")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}