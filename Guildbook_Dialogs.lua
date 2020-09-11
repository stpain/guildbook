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

Guildbook.Dialogs = {
    DeleteGameObjectTimeDelay = function(self)
        return 1.0
    end,
}

StaticPopupDialogs['GuildbookReset'] = {
    text = 'Guildbook has had major changes made, do you wish to reset all data for a fresh install?',
    button1 = 'Yes',
    button2 = 'No',
    OnAccept = function(self)
        wipe(GUILDBOOK_CHARACTER)
        wipe(GUILDBOOK_GLOBAL)
        if GUILDBOOK_GAMEOBJECTS then
            GUILDBOOK_GAMEOBJECTS = nil
        end
        GUILDBOOK_CHARACTER = Guildbook.Data.DefaultCharacterSettings
        GUILDBOOK_GLOBAL = Guildbook.Data.DefaultGlobalSettings
        ReloadUI()
    end,
    OnCancel = function(self)
        PRINT('|cffC41F3B', 'GUILDBOOK hasn\'t been reset, you will most likely experience errors as a result!')
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
        GUILDBOOK_CHARACTER = Guildbook.Data.DefaultCharacterSettings
        UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, '')
        UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, '')      
        PRINT(Guildbook.FONT_COLOUR, 'reset this character to default values.')
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
    text = 'Reset global settings to default values?',
    button1 = 'Reset',
    button2 = 'Cancel',
    OnAccept = function(self)
        wipe(GUILDBOOK_GLOBAL)
        GUILDBOOK_GLOBAL = Guildbook.Data.DefaultGlobalSettings
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
        PRINT(Guildbook.FONT_COLOUR, 'reset global settings to default values.')
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
    text = '|cffC41F3BUPDATING THESE VALUES MAY CORRUPT THE GATHERING DATABASE!\n\nTHEY SHOULD ONLY BE CHANGED IF THE ADDON HAS COLLECTED DATA IN ERROR AND YOU KNOW THE CORRECT VALUE|r\n\nUpdate gathering object\'s field %s with current value %s',
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

StaticPopupDialogs['GuildbookGatheringDatabaseDeleteObject'] = {
    text = '|cffC41F3B Delete game object:|r %s',  
    button1 = 'Delete',
    button2 = 'Cancel',
    StartDelay = Guildbook.Dialogs.DeleteGameObjectTimeDelay,
    --delayText = 't',
    OnAccept = function(self, data, data2) --data is the gameObject and data2 is the key within the object
        if GUILDBOOK_GAMEOBJECTS and Guildbook.OptionsInterface.GatheringDatabase.ContextMenuObjectKey then
            PRINT(Guildbook.FONT_COLOUR, tostring('removed game object: '..data['ItemName']))
            table.remove(GUILDBOOK_GAMEOBJECTS, Guildbook.OptionsInterface.GatheringDatabase.ContextMenuObjectKey)
            Guildbook.OptionsInterface.GatheringDatabase.ContextMenuObjectKey = nil
            Guildbook.OptionsInterface.GatheringDatabase.RefreshListView()
        end
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,    
}
