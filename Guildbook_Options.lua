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

Guildbook.OptionsInterface = {}

function GuildbookOptionsDebugCB_OnClick(self)
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL['Debug'] = not GUILDBOOK_GLOBAL['Debug']
        self:SetChecked(GUILDBOOK_GLOBAL['Debug'])
    end
    if self:GetChecked() == true then
        Guildbook.DebugFrame:Show()
    else
        Guildbook.DebugFrame:Hide()
    end
end

function GuildbookOptionsAttunementKeysCB_OnClick(self, instance)
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        if not GUILDBOOK_CHARACTER['AttunementsKeys'] then
            GUILDBOOK_CHARACTER['AttunementsKeys'] = Guildbook.Data.DefaultCharacterSettings.AttunementsKeys
        end
        GUILDBOOK_CHARACTER['AttunementsKeys'][instance] = self:GetChecked()
        self:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys'][instance])
        DEBUG(' ', 'set instance: '..instance..' attunement key as: '..tostring(self:GetChecked()))
    end
end

function GuildbookOptionsShowMinimapButton_OnClick(self)
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL['ShowMinimapButton'] = self:GetChecked()
        self:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapButton'])
        if GUILDBOOK_GLOBAL['ShowMinimapButton'] == false then
            Guildbook.MinimapIcon:Hide('GuildbookMinimapIcon')
        else
            Guildbook.MinimapIcon:Show('GuildbookMinimapIcon')
        end
    end
end

function GuildbookOptionsRosterHealthCheck_OnClick()
    local guildName = Guildbook:GetGuildName()
    if guildName then
        Guildbook:CleanUpGuildRosterData(guildName, 'scanning '..guildName..' for errors')
    end
end

function GuildbookOptions_OnLoad(self)
    GuildbookOptionsHeader:SetText(L['OptionsHeader'])
    GuildbookOptionsCharacterMainSpec:SetText(L['MainSpec'])
    GuildbookOptionsCharacterOffSpec:SetText(L['OffSpec'])
    GuildbookOptionsMainCharacterNameInputDesc:SetText(L['MainCharacterNameInputDesc'])

    local deleteGuildDropdown = CreateFrame('FRAME', 'GuildbookDeleteGuildDropDown', GuildbookOptions, "UIDropDownMenuTemplate")
    deleteGuildDropdown:SetPoint('BOTTOMRIGHT', _G['GuildbookOptionsRosterHealthCheck'], 'BOTTOMRIGHT', 10, 40.0)
    UIDropDownMenu_SetWidth(deleteGuildDropdown, 180)
    UIDropDownMenu_SetText(deleteGuildDropdown, 'Delete Guild')
    _G['GuildbookDeleteGuildDropDownButton']:SetScript('OnClick', function()
        if GUILDBOOK_GLOBAL and next(GUILDBOOK_GLOBAL['GuildRosterCache']) then
            local t = {}
            for guild, _ in pairs(GUILDBOOK_GLOBAL['GuildRosterCache']) do
                table.insert(t, {
                    text = guild,
                    notCheckable = true,
                    func = function() 
                        StaticPopup_Show('GuildbookDeleteGuild', guild, nil, {Guild = guild})
                    end
                })
            end
            EasyMenu(t, deleteGuildDropdown, deleteGuildDropdown, 10, 10, 'NONE')
        end
    end)

    Guildbook.CommsDelaySlider = CreateFrame('SLIDER', 'CommsDelay', self, "OptionsSliderTemplate")
    Guildbook.CommsDelaySlider:SetOrientation('HORIZONTAL')
    Guildbook.CommsDelaySlider:SetPoint('BOTTOM', -50, 20)
    Guildbook.CommsDelaySlider:SetSize(140, 16)
    Guildbook.CommsDelaySlider:EnableMouse(true)
    Guildbook.CommsDelaySlider:SetValueStep(0.1)
    Guildbook.CommsDelaySlider:SetValue(1)
    Guildbook.CommsDelaySlider:SetMinMaxValues(0.1,3.0)
    _G[Guildbook.CommsDelaySlider:GetName()..'Low']:SetText('0.1')
    _G[Guildbook.CommsDelaySlider:GetName()..'High']:SetText('3.0')
    Guildbook.CommsDelaySlider:SetScript('OnValueChanged', function(self)
        Guildbook.COMMS_DELAY = self:GetValue()
        _G[Guildbook.CommsDelaySlider:GetName()..'Text']:SetText(string.format("%.2f", self:GetValue()))
        if GUILDBOOK_GLOBAL then
            GUILDBOOK_GLOBAL['CommsDelay'] = self:GetValue()
        end
    end)
    Guildbook.CommsDelaySlider.tooltipText = 'Adjust the delay between the comms traffic and the UI refreshing'
    --dirty hack to avoid loading order
    Guildbook.CommsDelaySlider:SetScript('OnShow', function(self)
        if GUILDBOOK_GLOBAL then
            self:SetValue(GUILDBOOK_GLOBAL['CommsDelay'])
        else
            self:SetValue(1)
        end
    end)
end

function GuildbookOptionsMainSpecIsPvpSpecCB_OnClick(self)
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        GUILDBOOK_CHARACTER['MainSpecIsPvP'] = self:GetChecked()
    end
end

function GuildbookOptionsOffSpecIsPvpSpecCB_OnClick(self)
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        GUILDBOOK_CHARACTER['OffSpecIsPvP'] = self:GetChecked()
    end
end

function GuildbookOptionsMainCharacterNameInputBox_OnTextChanged(self)
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        if string.len(self:GetText()) > 0 then
            GUILDBOOK_CHARACTER['MainCharacter'] = tostring(self:GetText())
        else
            GUILDBOOK_CHARACTER['MainCharacter'] = '-'
        end
    end
end

function GuildbookOptionsMainCharacterNameInputBox_OnEnterPressed(self)
    self:ClearFocus()
end

function GuildbookOptionsMainSpecDD_Init()
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
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
                    local guildName = Guildbook:GetGuildName()
                    if guildName and GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
                        if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
                            GUILDBOOK_GLOBAL.GuildRosterCache[guildName] = {
                                [UnitGUID('player')] = {}
                            }
                        end
                        if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName][UnitGUID('player')] then
                            GUILDBOOK_GLOBAL.GuildRosterCache[guildName][UnitGUID('player')] = {}
                        end
                        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][UnitGUID('player')].MainSpec = tostring(spec)
                    end
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
end
function GuildbookOptionsOffSpecDD_Init()
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
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
                    local guildName = Guildbook:GetGuildName()
                    if guildName then
                        if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName] then
                            GUILDBOOK_GLOBAL.GuildRosterCache[guildName] = {
                                [UnitGUID('player')] = {}
                            }
                        end
                        if not GUILDBOOK_GLOBAL.GuildRosterCache[guildName][UnitGUID('player')] then
                            GUILDBOOK_GLOBAL.GuildRosterCache[guildName][UnitGUID('player')] = {}
                        end
                        GUILDBOOK_GLOBAL.GuildRosterCache[guildName][UnitGUID('player')].OffSpec = tostring(spec)
                    end
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
end

