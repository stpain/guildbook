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
        Guildbook.DEBUG("error", "ResetCharacterData", "set character saved var table to default values")
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
}

StaticPopupDialogs['GuildbookResetCacheCharacter'] = {
    text = 'Reset data for %s?',
    button1 = 'Reset',
    button2 = 'Cancel',
    OnAccept = function(self, t)
        wipe(GUILDBOOK_CHARACTER)
        local guildName = Guildbook:GetGuildName()
        if GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'] and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][t.guid] = nil
        end
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
}

StaticPopupDialogs['GuildbookResetGlobalSettings'] = {
    text = 'Reset global settings to default values? \n\nThis will delete all data about all guilds you are a member of.',
    button1 = 'Reset',
    button2 = 'Cancel',
    OnAccept = function(self)
        if GUILDBOOK_GLOBAL then
            wipe(GUILDBOOK_GLOBAL)
            GUILDBOOK_GLOBAL = Guildbook.Data.DefaultGlobalSettings
            GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
        end
        ReloadUI()
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
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
}

StaticPopupDialogs['MainCharacterAddAltCharacter'] = {
    text = L["DIALOG_MAIN_CHAR_ADD"],
    button1 = 'Update',
    button2 = 'Cancel',
    hasEditBox = true,
    OnShow = function(self)
        self.button1:Disable()
    end,
    EditBoxOnTextChanged = function(self)
        if self:GetText() ~= '' then
            local guid = Guildbook:GetGuildMemberGUID(self:GetText())
            local dialogText = _G[self:GetParent():GetName().."Text"]
            if guid then
                local character = Guildbook:GetCharacterFromCache(guid)
                dialogText:SetText(string.format(L["DIALOG_MAIN_CHAR_ADD_FOUND"], character.Name, character.Level, L[character.Class]))
                self:GetParent().button1:Enable()
            else
                dialogText:SetText(L["DIALOG_MAIN_CHAR_ADD"])
                self:GetParent().button1:Disable()
            end
        end
    end,

    -- will look at having this just set the alt/main stuff when my brain is working, for now it just adds the guid to the alt characters table where it can then be set
    OnAccept = function(self)
        local guid = Guildbook:GetGuildMemberGUID(self.editBox:GetText())
        if guid then
            if not GUILDBOOK_GLOBAL.myCharacters[guid] then
                GUILDBOOK_GLOBAL.myCharacters[guid] = true
            end
        end
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
}

StaticPopupDialogs['MainCharacterRemoveAltCharacter'] = {
    text = L["DIALOG_MAIN_CHAR_REMOVE"],
    button1 = 'Update',
    button2 = 'Cancel',
    hasEditBox = true,
    OnShow = function(self)
        self.button1:Disable()
    end,
    EditBoxOnTextChanged = function(self)
        if self:GetText() ~= '' then
            local guid = Guildbook:GetGuildMemberGUID(self:GetText())
            local dialogText = _G[self:GetParent():GetName().."Text"]
            if guid then
                local character = Guildbook:GetCharacterFromCache(guid)
                dialogText:SetText(string.format(L["DIALOG_MAIN_CHAR_ADD_FOUND"], character.Name, character.Level, L[character.Class]))
                self:GetParent().button1:Enable()
            else
                dialogText:SetText(L["DIALOG_MAIN_CHAR_REMOVE"])
                self:GetParent().button1:Disable()
            end
        end
    end,
    OnAccept = function(self)
        local guid = Guildbook:GetGuildMemberGUID(self.editBox:GetText())
        if guid then
            GUILDBOOK_GLOBAL.myCharacters[guid] = nil
        end
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
}

StaticPopupDialogs['GuildbookUpdateAvailable'] = {
    text = 'Guildbook: %s',
    button1 = 'OK',
    hasEditBox = true,
    OnShow = function(self)
        --self.icon:SetTexture(132049)
        self.icon:SetTexture(nil)
        self.editBox:SetMaxLetters(50)
        --self.editBox:SetWidth(300)
        self.editBox:SetText('https://www.curseforge.com/wow/addons/guildbook')
        self.editBox:HighlightText()
    end,
    OnAccept = function(self)

    end,
}

StaticPopupDialogs['GuildbookUpdates'] = {
    text = 'Guildbook Version: %s\n\n'..L["UPDATE_NEWS"],
    button1 = L["DIALOG_SHOW_UPDATES"],
    button2 = L["DIALOG_DONT_SHOW_UPDATES"],
    OnAccept = function(self)
        GUILDBOOK_GLOBAL.showUpdateNews = true;
    end,
    OnCancel = function(self)
        GUILDBOOK_GLOBAL.showUpdateNews = false;
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = true,
}

---this popup was an attempt at having the addon auto scan a players professions
---its not used at the moment as there is a slight 'clunk' during log in and i wasnt happy with it
StaticPopupDialogs['GuildbookFirstLoad'] = {
    text = L["DIALOG_CHARACTER_FIRST_LOAD"],
    button1 = "",
    OnShow = function(self, t)
        local button1 = _G[self:GetName().."Button1"]
        button1:Click()
    end,
    OnAccept = function(self, t)
        local engProf = Guildbook:GetEnglishProf(GUILDBOOK_CHARACTER.Profession1)
        if engProf == "Skinning" or engProf == "Herbalism" then
            
        else
            CastSpellByName(engProf)
            C_Timer.After(0.01, function()
                if TradeSkillFrame and TradeSkillFrame:IsVisible() then
                    TradeSkillFrameCloseButton:Click()
                end
                if CraftFrame and CraftFrame:IsVisible() then
                    CraftFrameCloseButton:Click()
                end
                if GUILDBOOK_CHARACTER and GUILDBOOK_CHARACTER.Profession2 then
                    local engProf = Guildbook:GetEnglishProf(GUILDBOOK_CHARACTER.Profession2)
                    if engProf == "Skinning" or engProf == "Herbalism" then
            
                    else
                        CastSpellByName(engProf)
                        C_Timer.After(0.01, function()
                            if TradeSkillFrame and TradeSkillFrame:IsVisible() then
                                TradeSkillFrameCloseButton:Click()
                            end
                            if CraftFrame and CraftFrame:IsVisible() then
                                CraftFrameCloseButton:Click()
                            end
                        end)
                    end
                end
            end)
        end
    end,
}


---this popup is used to confirm the user wants to remove a tradeskill recipe item from the loaded profession
---its a plaster to fix an issue of items loading into the wrong professions
StaticPopupDialogs['GuildbookDeleteRecipeFromCharacters'] = {
    text = "%s",
    button1 = "OK",
    button2 = "Cancel",
    OnAccept = function(self, t)
        if t.itemLink and t.characters then
            for _, guid in ipairs(t.characters) do
                local character = Guildbook:GetCharacterFromCache(guid)
                if character and character[t.prof] then
                    --character[t.prof][t.recipeID] = nil;
                    print(string.format("removed %s from %s for %s, with index %s", t.itemLink, character.Name, t.prof, t.listviewIndex))
                end
            end
            --t.listview.DataProvider:Removeindex(t.listviewIndex)
        end
    end,
}