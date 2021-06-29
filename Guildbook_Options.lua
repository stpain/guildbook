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
        Guildbook.DebuggerWindow:Show()
    else
        Guildbook.DebuggerWindow:Hide()
    end
end

-- function GuildbookOptionsAttunementKeysCB_OnClick(self, instance)
--     if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
--         if not GUILDBOOK_CHARACTER['AttunementsKeys'] then
--             GUILDBOOK_CHARACTER['AttunementsKeys'] = Guildbook.Data.DefaultCharacterSettings.AttunementsKeys
--         end
--         GUILDBOOK_CHARACTER['AttunementsKeys'][instance] = self:GetChecked()
--         self:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys'][instance])
--         DEBUG(' ', 'set instance: '..instance..' attunement key as: '..tostring(self:GetChecked()))
--     end
-- end

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

function GuildbookOptionsShowMinimapCalendarButton_OnClick(self)
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL['ShowMinimapCalendarButton'] = self:GetChecked()
        self:SetChecked(GUILDBOOK_GLOBAL['ShowMinimapCalendarButton'])
        if GUILDBOOK_GLOBAL['ShowMinimapCalendarButton'] == false then
            Guildbook:HideCalendarButton()
        else
            Guildbook:ForceCalendarButton(Minimap, 40, 'TOPRIGHT', 20, -2)
        end
    end
end

local function setWarningText(txt)
    GuildbookOptionsGeneralOptionsWarningText:SetText('|cffC41F3B'..txt)
    StaticPopup_Show('Reload')
end

function GuildbookOptionsModifyDefaultGuildRoster_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.config then
        GUILDBOOK_GLOBAL.config = {}
    end
    GUILDBOOK_GLOBAL.config.modifyDefaultGuildRoster = self:GetChecked()
    setWarningText('changes made require a UI reload')
end

function GuildbookOptionsUseDefaultBlizzardFont_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.config then
        GUILDBOOK_GLOBAL.config = {}
    end
    GUILDBOOK_GLOBAL.config.useBlizzardFont = self:GetChecked()
    
    Guildbook:UpdateFonts()
end

function GuildbookOptionsTooltipTradeskill_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.config then
        GUILDBOOK_GLOBAL.config = {}
    end
    if self:GetChecked() == false then
        GuildbookOptionsTooltipTradeskillRecipes:Disable()
    else
        GuildbookOptionsTooltipTradeskillRecipes:Enable()
    end
    GUILDBOOK_GLOBAL.config.showTooltipTradeskills = self:GetChecked()
end

function GuildbookOptionsTooltipTradeskillRecipes_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.config then
        GUILDBOOK_GLOBAL.config = {}
    end
    GUILDBOOK_GLOBAL.config.showTooltipTradeskillsRecipes = self:GetChecked()
end

function GuildbookOptionsLoadChatModule_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.Modules then
        GUILDBOOK_GLOBAL.Modules = {}
    end
    GUILDBOOK_GLOBAL.Modules["ChatFrame"] = self:GetChecked()
    setWarningText('changes made require a UI reload')
end

function GuildbookOptionsLoadStatsModule_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.Modules then
        GUILDBOOK_GLOBAL.Modules = {}
    end
    GUILDBOOK_GLOBAL.Modules["StatsFrame"] = self:GetChecked()
    setWarningText('changes made require a UI reload')
end

function GuildbookOptionsLoadCalendarModule_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.Modules then
        GUILDBOOK_GLOBAL.Modules = {}
    end
    GUILDBOOK_GLOBAL.Modules["GuildCalendarFrame"] = self:GetChecked()
    setWarningText('changes made require a UI reload')
end

function GuildbookOptionsLoadGuildBankModule_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.Modules then
        GUILDBOOK_GLOBAL.Modules = {}
    end
    GUILDBOOK_GLOBAL.Modules["GuildBankFrame"] = self:GetChecked()
    setWarningText('changes made require a UI reload')
end

function GuildbookOptionsLoadProfilesModule_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    if not GUILDBOOK_GLOBAL.Modules then
        GUILDBOOK_GLOBAL.Modules = {}
    end
    GUILDBOOK_GLOBAL.Modules["ProfilesFrame"] = self:GetChecked()
    setWarningText('changes made require a UI reload')
end

function GuildbookOptionsTooltipInfo_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    GUILDBOOK_GLOBAL['TooltipInfo'] = self:GetChecked()
    if GUILDBOOK_GLOBAL['TooltipInfo'] == false then
        GuildbookOptionsTooltipInfoMainSpec:Disable()
        GuildbookOptionsTooltipInfoMainSpecText:SetTextColor(0.5, 0.5, 0.5, 0.5)
        GuildbookOptionsTooltipInfoProfessions:Disable()
        GuildbookOptionsTooltipInfoMainCharacter:Disable()
    else
        GuildbookOptionsTooltipInfoMainSpec:Enable()
        GuildbookOptionsTooltipInfoProfessions:Enable()
        GuildbookOptionsTooltipInfoMainCharacter:Enable()
    end
end

function GuildbookOptionsTooltipInfoMainSpec_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    GUILDBOOK_GLOBAL['TooltipInfoMainSpec'] = self:GetChecked()
end

function GuildbookOptionsTooltipInfoProfessions_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    GUILDBOOK_GLOBAL['TooltipInfoProfessions'] = self:GetChecked()
end

function GuildbookOptionsTooltipInfoMainCharacter_OnClick(self)
    if not GUILDBOOK_GLOBAL then
        return
    end
    GUILDBOOK_GLOBAL['TooltipInfoMainCharacter'] = self:GetChecked()
end

function GuildbookOptions_OnLoad(self)

    local version = GetAddOnMetadata('Guildbook', "Version")

    GuildbookOptionsTitle:SetText('Guildbook')
    GuildbookOptionsAbout:SetText(L['OptionsAbout'])
    GuildbookOptionsVersion:SetText(L['Version']..' '..version)
    GuildbookOptionsAuthor:SetText(L['Author'])

    local deleteGuildDropdown = CreateFrame('FRAME', 'GuildbookDeleteGuildDropDown', GuildbookOptions, "UIDropDownMenuTemplate")
    deleteGuildDropdown:SetPoint("BOTTOMLEFT", 0, 160)
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
            EasyMenu(t, deleteGuildDropdown, deleteGuildDropdown, 10, 10, 'NONE', 3)
        end
    end)

    Guildbook.CommsDelaySlider = CreateFrame('SLIDER', 'CommsDelay', self, "OptionsSliderTemplate")
    Guildbook.CommsDelaySlider:SetOrientation('HORIZONTAL')
    Guildbook.CommsDelaySlider:SetPoint('LEFT', _G['GuildbookOptionsDebugCB'], 'RIGHT', 180, 0)
    Guildbook.CommsDelaySlider:SetSize(140, 16)
    Guildbook.CommsDelaySlider:EnableMouse(true)
    Guildbook.CommsDelaySlider:SetValueStep(0.1)
    Guildbook.CommsDelaySlider:SetValue(1)
    Guildbook.CommsDelaySlider:SetMinMaxValues(0.1,4.6)
    _G[Guildbook.CommsDelaySlider:GetName()..'Low']:SetText('0.5')
    _G[Guildbook.CommsDelaySlider:GetName()..'High']:SetText('5.0')
    Guildbook.CommsDelaySlider:SetScript('OnValueChanged', function(self)
        Guildbook.COMMS_DELAY = self:GetValue()
        _G[Guildbook.CommsDelaySlider:GetName()..'Text']:SetText(string.format("%.2f", self:GetValue() + 0.4))
        if GUILDBOOK_GLOBAL then
            GUILDBOOK_GLOBAL['CommsDelay'] = self:GetValue() -- there is a hidden delay in the loading process of character data so this is a slight lie
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


