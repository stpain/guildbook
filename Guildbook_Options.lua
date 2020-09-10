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

Guildbook.OptionsInterface = {}

function GuildbookOptionsDebugCB_OnClick(self)
    GUILDBOOK_GLOBAL['Debug'] = not GUILDBOOK_GLOBAL['Debug']
    self:SetChecked(GUILDBOOK_GLOBAL['Debug'])
end

function GuildbookOptionsAttunementKeysCB_OnClick(self, instance)
    if not GUILDBOOK_CHARACTER['AttunementsKeys'] then
        GUILDBOOK_CHARACTER['AttunementsKeys'] = Guildbook.Data.DefaultCharacterSettings.AttunementsKeys
    end
    GUILDBOOK_CHARACTER['AttunementsKeys'][instance] = self:GetChecked()
    self:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys'][instance])
    DEBUG('set instance: '..instance..' attunement key as: '..tostring(self:GetChecked()))
end

function GuildbookOptionsShowMinimapButton_OnClick(self)
    GUILDBOOK_GLOBAL['ShowMinimapButton'] = self:GetChecked()
    self:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])
    if GUILDBOOK_GLOBAL['ShowMinimapButton'] == false then
        Guildbook.MinimapIcon:Hide('GuildbookMinimapIcon')
    else
        Guildbook.MinimapIcon:Show('GuildbookMinimapIcon')
    end
end

function GuildbookOptions_OnLoad(self)
    GuildbookOptionsHeader:SetText(L['OptionsHeader'])
    GuildbookOptionsCharacterMainSpec:SetText(L['MainSpec'])
    GuildbookOptionsCharacterOffSpec:SetText(L['OffSpec'])
    GuildbookOptionsMainCharacterNameInputDesc:SetText(L['MainCharacterNameInputDesc'])

    --add gathering database child frame
    -- GuildbookOptionsGatheringDatabase.name = 'Gathering Database'
    -- GuildbookOptionsGatheringDatabase.parent = 'Guildbook'
    -- InterfaceOptions_AddCategory(GuildbookOptionsGatheringDatabase)
    -- local r, g, b = unpack(Guildbook.RgbToPercent(Guildbook.OptionsInterface.GatheringDatabase.ListViewBackground))
    -- GuildbookOptionsGatheringDatabaseGameObjectsListViewTexture:SetColorTexture(r, g, b, 0.9)


end

function GuildbookOptions_OnShow(self)
    if Guildbook.LOADED == true then
        UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, GUILDBOOK_CHARACTER['MainSpec'])
        UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, GUILDBOOK_CHARACTER['OffSpec'])
        GuildbookOptionsMainCharacterNameInputBox:SetText(GUILDBOOK_CHARACTER['MainCharacter'])
        GuildbookOptionsMainSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['MainSpecIsPvP'])
        GuildbookOptionsOffSpecIsPvpSpecCB:SetChecked(GUILDBOOK_CHARACTER['OffSpecIsPvP'])
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
        GuildbookOptionsShowMinimapButton:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])

        if GUILDBOOK_CHARACTER['AttunementsKeys'] then
            GuildbookOptionsAttunementKeysUBRS:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['UBRS'])
            GuildbookOptionsAttunementKeysMC:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['MC'])
            GuildbookOptionsAttunementKeysONY:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['ONY'])
            GuildbookOptionsAttunementKeysBWL:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['BWL'])
            GuildbookOptionsAttunementKeysNAXX:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys']['NAXX'])
        end
    end
end

function GuildbookOptionsMainSpecIsPvpSpecCB_OnClick(self)
    GUILDBOOK_CHARACTER['MainSpecIsPvP'] = self:GetChecked()
end

function GuildbookOptionsOffSpecIsPvpSpecCB_OnClick(self)
    GUILDBOOK_CHARACTER['OffSpecIsPvP'] = self:GetChecked()
end

function GuildbookOptionsMainCharacterNameInputBox_OnTextChanged(self)
    if string.len(self:GetText()) > 0 then
        GUILDBOOK_CHARACTER['MainCharacter'] = tostring(self:GetText())
    else
        GUILDBOOK_CHARACTER['MainCharacter'] = '-'
    end
    DEBUG('set main character as: '..GUILDBOOK_CHARACTER['MainCharacter'])
end

function GuildbookOptionsMainCharacterNameInputBox_OnEnterPressed(self)
    self:ClearFocus()
end

function GuildbookOptionsMainSpecDD_Init()
    if Guildbook.LOADED == true then
        UIDropDownMenu_Initialize(GuildbookOptionsMainSpecDD, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            local _, class, _ = UnitClass('player')
            for i, spec in pairs(Guildbook.Data.Class[class].Specializations) do
                info.text = tostring(Guildbook.Data.SpecFontStringIconSMALL[class][spec]..'  '..L[spec])
                info.hasArrow = false
                info.keepShownOnClick = false
                info.func = function() 
                    UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, L[spec]) 
                    GUILDBOOK_CHARACTER['MainSpec'] = tostring(spec)
                    GUILDBOOK_GLOBAL.GuildRosterCache[UnitGUID('player')].MainSpec = tostring(spec)
                    DEBUG('set players main spec as: '..spec)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
end
function GuildbookOptionsOffSpecDD_Init()
    if Guildbook.LOADED == true then
        UIDropDownMenu_Initialize(GuildbookOptionsOffSpecDD, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            local _, class, _ = UnitClass('player')
            for i, spec in pairs(Guildbook.Data.Class[class].Specializations) do
                info.text = tostring(Guildbook.Data.SpecFontStringIconSMALL[class][spec]..'  '..L[spec])
                info.hasArrow = false
                info.keepShownOnClick = false
                info.func = function() 
                    UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, L[spec]) 
                    GUILDBOOK_CHARACTER['OffSpec'] = tostring(spec)
                    GUILDBOOK_GLOBAL.GuildRosterCache[UnitGUID('player')].OffSpec = tostring(spec)
                    DEBUG('set players off spec as: '..spec)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
end