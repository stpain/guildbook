--[==[

Copyright ©2022 Samuel Thomas Pain

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

local L = addon.Locales;

--leaving this dialogue here so i remember how they work if i need to add 1

-- StaticPopupDialogs['MainCharacterAddAltCharacter'] = {
--     text = L["DIALOG_MAIN_CHAR_ADD"],
--     button1 = L["UPDATE"],
--     button2 = L["CANCEL"],
--     hasEditBox = true,
--     OnShow = function(self)
--         self.button1:Disable()
--     end,
--     EditBoxOnTextChanged = function(self)
--         if self:GetText() ~= '' then
--             local guid = Roster:GetGuildMemberGUID(self:GetText())
--             local dialogText = _G[self:GetParent():GetName().."Text"]
--             if guid then
--                 local character = Guildbook:GetCharacterFromCache(guid)
--                 dialogText:SetText(string.format(L["DIALOG_MAIN_CHAR_ADD_FOUND"], character.Name, character.Level, L[character.Class]))
--                 self:GetParent().button1:Enable()
--             else
--                 dialogText:SetText(L["DIALOG_MAIN_CHAR_ADD"])
--                 self:GetParent().button1:Disable()
--             end
--         end
--     end,

--     -- will look at having this just set the alt/main stuff when my brain is working, for now it just adds the guid to the alt characters table where it can then be set
--     OnAccept = function(self)
--         local guid = Roster:GetGuildMemberGUID(self.editBox:GetText())
--         if guid then
--             if not GUILDBOOK_GLOBAL.myCharacters[guid] then
--                 GUILDBOOK_GLOBAL.myCharacters[guid] = true
--             end
--         end
--     end,
--     OnCancel = function(self)

--     end,
--     timeout = 0,
--     whileDead = true,
--     hideOnEscape = false,
-- }

StaticPopupDialogs['GuildbookResetGuildData'] = {
    text = L["RESET_GUILD_DATA"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self, t)
        t.callback()
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
}

