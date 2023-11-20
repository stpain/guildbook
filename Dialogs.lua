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

local addonName, addon = ...
local Database = addon.Database;
local L = addon.Locales



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

StaticPopupDialogs['GuildbookReport'] = {
    text = 'Oops, something went wrong, is it Tuesday?\n\n%s',
    button1 = "OK",
    --button2 = 'Cancel',
    OnAccept = function(self)

    end,
    OnShow = function(self)
        self.editBox:SetText("https://discord.gg/st5uDAX5Cn")
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookDeleteGeneric'] = {
    text = 'Delete %s',
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        if data.callback then
            data.callback()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookDeleteCharacter'] = {
    text = 'Delete %s',
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        Database:DeleteCharacter(data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookReminder'] = {
    text = '%s',
    button1 = "OK",
    button2 = "Ignore",
    OnAccept = function()
        GuildbookUI:SelectView("Settings")
    end,
    OnCancel = function()

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['GuildbookUpdated'] = {
    text = "WARNING !!!\n\n|cffC41F3BGuildbook has changed and if you proceed with this update you will lose all current data|r.\n\nGuildbook 6.0 is a rework of an older version that was updated for classic era, it is NOT compatabile with the current wrath version\n\nBUT\n\nit does include missing recipes and will have th best chance of getting any updates.\n\nDo you want to continue...",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        --GUILDBOOK_GLOBAL = nil
        print('Well thats it, all data has been exterminated! Fingers crossed this thing boots up.....')
        C_Timer.After(math.random(3,9), function()
            Database:Init(true)
        end)
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}


StaticPopupDialogs['GuildbookCalendarAddEvent'] = {
    text = "%s.",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        local str = self.editBox:GetText()
        if str and (#str > 0) and (str ~= " ") then
            local event = {
                calendarTypeEnum = data.calendarTypeEnum,
                text = str,
                timestamp = data.timestamp
            }
            Database:InsertCalendarEvent(event)
        end
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}
