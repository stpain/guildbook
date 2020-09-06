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

function GuildbookOptionsShowItemInfoTooltipCB_OnClick(self)
    GUILDBOOK_CHARACTER['TooltipItemData'] = self:GetChecked()
    self:GetChecked(GUILDBOOK_CHARACTER['TooltipItemData'])
end

function GuildbookOptionsShowBankBagsInfoCB_OnClick(self)
    GUILDBOOK_CHARACTER['TooltipBankData'] = self:GetChecked()
    self:GetChecked(GUILDBOOK_CHARACTER['TooltipBankData'])
end

function GuildbookOptionsAttunementKeysCB_OnClick(self, instance)
    if not GUILDBOOK_CHARACTER['AttunementsKeys'] then
        GUILDBOOK_CHARACTER['AttunementsKeys'] = Guildbook.Data.DefaultCharacterSettings.AttunementsKeys
    end
    GUILDBOOK_CHARACTER['AttunementsKeys'][instance] = self:GetChecked()
    self:SetChecked(GUILDBOOK_CHARACTER['AttunementsKeys'][instance])
    DEBUG('set instance: '..instance..' attunement key as: '..tostring(self:GetChecked()))
end

function GuildbookOptionsMinimapIconSizeSlider_OnShow(self)
    if Guildbook.LOADED then
        if not GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] then
            GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] = 8.0
        end
        self:SetValue(tonumber(GUILDBOOK_CHARACTER['MinimapGatheringIconSize']))
    end
end

function GuildbookOptionsMinimapIconSizeSlider_OnValueChanged(self)
    if Guildbook.LOADED then
        if not GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] then
            GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] = 8.0
        end
        GUILDBOOK_CHARACTER['MinimapGatheringIconSize'] = self:GetValue()
        _G[self:GetName()..'Text']:SetText(string.format("%.0f", tostring(GUILDBOOK_CHARACTER['MinimapGatheringIconSize'])))
        _G[self:GetName()..'Low']:SetText('2');
        _G[self:GetName()..'High']:SetText('20')
    end
    Guildbook.Gathering.UpdateMapGatheringIcons()
end

function GuildbookOptionsWorldmapIconSizeSlider_OnShow(self)
    if Guildbook.LOADED then
        if not GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] then
            GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] = 8.0
        end
        self:SetValue(tonumber(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize']))
    end
end

function GuildbookOptionsWorldmapIconSizeSlider_OnValueChanged(self)
    if Guildbook.LOADED then
        if not GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] then
            GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] = 8.0
        end
        GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'] = self:GetValue()
        _G[self:GetName()..'Text']:SetText(string.format("%.0f", tostring(GUILDBOOK_CHARACTER['WorldmapGatheringIconSize'])))
        _G[self:GetName()..'Low']:SetText('2');
        _G[self:GetName()..'High']:SetText('20')
    end
    Guildbook.Gathering.UpdateMapGatheringIcons()
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
    GuildbookOptionsGatheringDatabase.name = 'Gathering Database'
    GuildbookOptionsGatheringDatabase.parent = 'Guildbook'
    InterfaceOptions_AddCategory(GuildbookOptionsGatheringDatabase)
    local r, g, b = unpack(Guildbook.RgbToPercent(Guildbook.OptionsInterface.GatheringDatabase.ListViewBackground))
    GuildbookOptionsGatheringDatabaseGameObjectsListViewTexture:SetColorTexture(r, g, b, 0.9)

    Guildbook.OptionsInterface.DrawGatheringFrame()
    GuildbookOptionGatheringDatabaseListViewRowContextMenu_Init() --this is the right click context menu for he listview items
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

        --GuildbookOptionsGatheringDatabaseSendSelectedItemsRecipient:SetText(L['CharacterName'])
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
            for i, spec in pairs(Guildbook.Data.Class[Guildbook.PLAYER_CLASS].Specializations) do
                info.text = tostring(Guildbook.Data.SpecFontStringIconSMALL[Guildbook.PLAYER_CLASS][spec]..'  '..L[spec])
                info.hasArrow = false
                info.keepShownOnClick = false
                info.func = function() 
                    UIDropDownMenu_SetText(GuildbookOptionsMainSpecDD, L[spec]) 
                    GUILDBOOK_CHARACTER['MainSpec'] = tostring(spec)
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
            for i, spec in pairs(Guildbook.Data.Class[Guildbook.PLAYER_CLASS].Specializations) do
                info.text = tostring(Guildbook.Data.SpecFontStringIconSMALL[Guildbook.PLAYER_CLASS][spec]..'  '..L[spec])
                info.hasArrow = false
                info.keepShownOnClick = false
                info.func = function() 
                    UIDropDownMenu_SetText(GuildbookOptionsOffSpecDD, L[spec]) 
                    GUILDBOOK_CHARACTER['OffSpec'] = tostring(spec)
                    DEBUG('set players off spec as: '..spec)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
end

Guildbook.OptionsInterface.GatheringDatabase = {
    ListViewBackground = {12,18,23},
    ListViewRowHighlight = {90,100,111},
    ListViewRowFontColor = {210,211,211},
    ListViewRows = {},
    ContextMenuObjectKey = nil,
    CurrentSort = 'ItemName',
    ItemsSent = {},
}

Guildbook.GatheringDatabaseListViewRowContextMenu = CreateFrame("Frame", "GuildbookOptionGatheringDatabaseListViewRowContextMenu", UIParent, "UIDropDownMenuTemplate")

function GuildbookOptionGatheringDatabaseListViewRowContextMenu_Init()
    UIDropDownMenu_Initialize(Guildbook.GatheringDatabaseListViewRowContextMenu, function(self, level, gameObject)
        UIDropDownMenu_AddButton({
            text = 'Select field to edit',
            isTitle = true,
            notCheckable = true,
        })
        if gameObject then
            local info = UIDropDownMenu_CreateInfo()
            for k, v in pairs(gameObject) do
                if (k == 'ItemID') or (k == 'SourceName') or (k == 'ItemName') then
                    info.text = tostring('|cffFF7D0A'..k..'|r: '..v)
                    info.hasArrow = false
                    info.notCheckable = true
                    info.func = function()
                        local popup = StaticPopup_Show('GuildbookGatheringDatabaseEditObject', k, v)
                        if popup then
                            popup.data = gameObject
                            popup.data2 = k
                        end
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end
            UIDropDownMenu_AddButton({
                text = '|cffC41F3BDELETE',
                notCheckable = true,
                func = function(self, button)
                    --if IsShiftKeyDown() then
                        if GUILDBOOK_GAMEOBJECTS then
                            for k, v in ipairs(GUILDBOOK_GAMEOBJECTS) do
                                if v == gameObject then
                                    Guildbook.OptionsInterface.GatheringDatabase.ContextMenuObjectKey = k
                                end
                            end
                        end
                        local popup = StaticPopup_Show('GuildbookGatheringDatabaseDeleteObject', tostring(gameObject['ItemName']..' from '..gameObject['MapZoneName']))
                        if popup then
                            popup.data = gameObject
                        end  
                    --end                  
                end,
            })
        end
    end, 'MENU')
end

function Guildbook.OptionsInterface.DrawGatheringFrame()
    local fontSize = 10.5
    local r, g, b = unpack(Guildbook.RgbToPercent(Guildbook.OptionsInterface.GatheringDatabase.ListViewRowFontColor))
    for i = 1, 30 do
        local rowPosY = ((i-1) * -14)
        local f = CreateFrame('FRAME', tostring('GuildbookOptionsGatheringDatabaseGameObjectsListView_Row'..i), GuildbookOptionsGatheringDatabaseGameObjectsListView)
        f:SetHeight(14)
        f:SetPoint('TOPLEFT', GuildbookOptionsGatheringDatabaseGameObjectsListView, 'TOPLEFT', 0, rowPosY)
        f:SetPoint('TOPRIGHT', GuildbookOptionsGatheringDatabaseGameObjectsListView, 'TOPRIGHT', 0, rowPosY)

        f.t = f:CreateTexture('$parentTexture', 'ARTWORK')
        f.t:SetAllPoints(f)

        f.ItemName = f:CreateFontString('$parentItemName', 'OVERLAY', 'GameFontNormal')
        f.ItemName:SetPoint('LEFT', 0, 0)
        f.ItemName:SetText('ItemName '..i)
        f.ItemName:SetWidth(200)
        f.ItemName:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
        f.ItemName:SetJustifyH("LEFT")
        f.ItemName:SetTextColor(r, g, b, 1)

        f.SourceName = f:CreateFontString('$parentSourceName', 'OVERLAY', 'GameFontNormal')
        f.SourceName:SetPoint('LEFT', f.ItemName, 'RIGHT', 8, 0)
        f.SourceName:SetText('SourceName')
        f.SourceName:SetWidth(180)
        f.SourceName:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
        f.SourceName:SetJustifyH("LEFT")
        f.SourceName:SetTextColor(r, g, b, 1)

        f.MapZoneName = f:CreateFontString('$parentMapZoneName', 'OVERLAY', 'GameFontNormal')
        f.MapZoneName:SetPoint('LEFT', f.SourceName, 'RIGHT', 8, 0)
        f.MapZoneName:SetText('MapZoneName')
        f.MapZoneName:SetWidth(120)
        f.MapZoneName:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
        f.MapZoneName:SetJustifyH("LEFT")
        f.MapZoneName:SetTextColor(r, g, b, 1)

        --this became a complete x, y string
        f.MapZonePosX = f:CreateFontString('$parentMapZonePosX', 'OVERLAY', 'GameFontNormal')
        f.MapZonePosX:SetPoint('LEFT', f.MapZoneName, 'RIGHT', 8, 0)
        f.MapZonePosX:SetText('MapZonePosX')
        f.MapZonePosX:SetWidth(50)
        f.MapZonePosX:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
        f.MapZonePosX:SetJustifyH("LEFT")
        f.MapZonePosX:SetTextColor(r, g, b, 1)

        -- f.MapZonePosY = f:CreateFontString('$parentMapZonePosY', 'OVERLAY', 'GameFontNormal')
        -- f.MapZonePosY:SetPoint('LEFT', f.MapZonePosX, 'RIGHT', 5, 0)
        -- f.MapZonePosY:SetText('MapZonePosY')
        -- f.MapZonePosY:SetWidth(30)
        -- f.MapZonePosY:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
        -- f.MapZonePosY:SetJustifyH("LEFT")
        -- f.MapZonePosY:SetTextColor(r, g, b, 1)

        f.data = nil
        f.id = nil
        f:Hide()

        f:SetScript('OnMouseDown', function(self, button)
            if button == 'LeftButton' then
                if self.data then
                    if self.data['Selected'] == false then
                        local r, g, b = unpack(Guildbook.RgbToPercent(Guildbook.OptionsInterface.GatheringDatabase.ListViewRowHighlight))
                        self.t:SetColorTexture(r, g, b, 1)
                        self.data['Selected'] = true
                    else
                        self.t:SetColorTexture(0,0,0,0)
                        self.data['Selected'] = false
                    end
                end
            end
            if button == 'RightButton' and self.data then
                ToggleDropDownMenu(1, nil, Guildbook.GatheringDatabaseListViewRowContextMenu, "cursor", 3, -3, self.data, nil, 5)
            end
        end)

        f:SetScript('OnEnter', function(self)
            if self:IsVisible() then
                local r, g, b = unpack(Guildbook.RgbToPercent(Guildbook.OptionsInterface.GatheringDatabase.ListViewRowHighlight))
                self.t:SetColorTexture(r, g, b, 1)
            end
        end)

        f:SetScript('OnLeave', function(self)
            if self:IsVisible() then
                if self.data['Selected'] == false then
                    self.t:SetColorTexture(0,0,0,0)
                end
            end
        end)

        f:SetScript('OnHide', function(self)
            self.id = nil
        end)

        f:SetScript('OnShow', function(self)            
            if self.data then
                if self.data['Selected'] == true then
                    local r, g, b = unpack(Guildbook.RgbToPercent(Guildbook.OptionsInterface.GatheringDatabase.ListViewRowHighlight))
                    self.t:SetColorTexture(r, g, b, 1)
                else
                    self.t:SetColorTexture(0,0,0,0)
                end
                if self.id then
                    self.ItemName:SetText(tostring('|cffABD473'..string.format("%04d",self.id)..'|r '..self.data['ItemName']))
                else
                    self.ItemName:SetText(self.data['ItemName'])
                end
                self.SourceName:SetText(self.data['SourceName'])
                self.MapZoneName:SetText(self.data['MapZoneName'])
                --changed layout, mapzoneposx now contains a full [x, y] formatted coord
                self.MapZonePosX:SetText(tostring('['..string.format("%.0f", tonumber(self.data['MapZonePosX'] * 100))..', '..string.format("%.0f", tonumber(self.data['MapZonePosY'] * 100))..']'))
                --self.MapZonePosY:SetText(string.format("%.0f", tonumber(self.data['MapZonePosY'] * 100)))
            end
        end)

        
        Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i] = f
    end
end

function GuildbookOptionsGatheringDatabaseSelectAllGameObjectCB_OnClick(self)
    if self:GetChecked() == true then
        for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
            gameObject['Selected'] = true
        end
        DEBUG('all game objects selected')
    else
        for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
            gameObject['Selected'] = false
        end
        DEBUG('all game objects un-selected')
    end
    Guildbook.OptionsInterface.GatheringDatabase.RefreshListView()
end

function GuildbookOptionsGatheringDatabaseListViewSendSelectedItemsToGuild_OnEnter(self)
    GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
    GameTooltip:AddLine('Send selected game objects')
    GameTooltip:Show()
end
function GuildbookOptionsGatheringDatabaseListViewSendSelectedItemsToGuild_OnLeave(self)
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function Guildbook.OptionsInterface.GatheringDatabase.IterDatabaseSendSelected()
    local dataSent = false
    for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
        if gameObject['Selected'] and gameObject['Selected'] == true then
            if not Guildbook.OptionsInterface.GatheringDatabase.ItemsSent[k] then
                print('sending item: '..k)
                local data = tostring(gameObject['ItemID']..':'..gameObject['ItemName']..':'..gameObject['SourceName']..':'..gameObject['SourceGUID']..':'..gameObject['MapID']..':'..gameObject['MapZoneName']..':'..gameObject['MapZonePosX']..':'..gameObject['MapZonePosY'])
                local recipient = GuildbookOptionsGatheringDatabaseSendSelectedItemsRecipient:GetText()
                if recipient then
                    print(recipient)
                    dataSent = C_ChatInfo.SendAddonMessage('gb-gat-db', data, 'WHISPER', recipient)
                else
                    --dataSent = C_ChatInfo.SendAddonMessage('gb-gat-db', data, 'GUILD')
                end
                Guildbook.OptionsInterface.GatheringDatabase.ItemsSent[k] = true
                if dataSent == true then --only print once
                    DEBUG('sent data')                
                else
                    PRINT(Guildbook.FONT_COLOUR, 'failed to send database items')
                end
                local v = GuildbookOptionsGatheringDatabaseSendingDataSB:GetValue()
                GuildbookOptionsGatheringDatabaseSendingDataSB:SetValue(v + 1)
                return
            end
        end
    end
end

function GuildbookOptionsGatheringDatabaseListViewSendSelectedItemsToGuild_OnClick(self)
    DEBUG('sending selected game objects to guild')
    local selectedCount = 0
    for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
        if gameObject['Selected'] and gameObject['Selected'] == true then
            selectedCount = selectedCount + 1
        end
    end
    Guildbook.OptionsInterface.GatheringDatabase.ItemsSent = {}
    if selectedCount > 0 then
        GuildbookOptionsGatheringDatabaseSendingDataSB:Show()
        GuildbookOptionsGatheringDatabaseSendingDataSB:SetStatusBarColor(unpack(Guildbook.Data.Class['HUNTER'].RGB))
        GuildbookOptionsGatheringDatabaseSendingDataSB:SetMinMaxValues(0, selectedCount)
        GuildbookOptionsGatheringDatabaseSendingDataSB:SetValue(0)
        C_Timer.NewTicker(0.5, Guildbook.OptionsInterface.GatheringDatabase.IterDatabaseSendSelected, selectedCount)

        GuildbookOptionsGatheringDatabaseSendSelectedItemsRecipient:ClearFocus()
        self:SetEnabled(false)
        --limit chat spam
        C_Timer.After(tonumber(selectedCount / 2), function() 
            GuildbookOptionsGatheringDatabaseListViewSendSelectedItemsToGuild:SetEnabled(true)
            GuildbookOptionsGatheringDatabaseSendingDataSB:Hide()
            if GuildbookOptionsGatheringDatabaseSendSelectedItemsRecipient:GetText() == '' then
                PRINT(Guildbook.FONT_COLOUR, tostring('sent '..selectedCount..' items to all guild members'))
            else
                PRINT(Guildbook.FONT_COLOUR, tostring('sent '..selectedCount..' items to '..GuildbookOptionsGatheringDatabaseSendSelectedItemsRecipient:GetText()))
            end
        end)
    end
end

function GuildbookOptionsGatheringDatabaseGameObjectsListViewHeaderButton_OnClick(sort)
    Guildbook.OptionsInterface.GatheringDatabase.CurrentSort = sort
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        Guildbook.OptionsInterface.GatheringDatabase.ClearListView()
        table.sort(GUILDBOOK_GAMEOBJECTS, function(a, b)
            if sort == 'MapZoneName' then
                if a[sort] == b[sort] then
                    return a['ItemName'] < b['ItemName']
                else
                    return a[sort] < b[sort]
                end
            elseif sort == 'ItemName' then
                if a[sort] == b[sort] then
                    return a['MapZoneName'] < b['MapZoneName']
                else
                    return a[sort] < b[sort]
                end
            else
                return a[sort] < b[sort]
            end
        end)
    end
    GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar:SetValue(1)
    Guildbook.OptionsInterface.GatheringDatabase.RefreshListView()
end

function Guildbook.OptionsInterface.GatheringDatabase.ClearListView()
    for i = 1, 30 do
        Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i]:Hide()
    end
end

function Guildbook.OptionsInterface.GatheringDatabase.ClearListViewSelectedData()
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
            gameObject['Selected'] = nil
        end
    end
end

function Guildbook.OptionsInterface.GatheringDatabase.AddListViewSelectedData()
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
            gameObject['Selected'] = false
        end
    end
end

function GuildbookOptionsGatheringDatabaseGameObjectsListView_OnMouseWheel(self, delta)
    local f = GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar:GetValue()
    if delta == 1 then
        GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar:SetValue(f - 0.1)
    else
        GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar:SetValue(f + 0.1)
    end
end

function GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar_OnValueChanged(self)
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        local i = 1
        Guildbook.OptionsInterface.GatheringDatabase.ClearListView()
        for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
            if k > tonumber((self:GetValue() - 1) * 30) and k <= tonumber(self:GetValue() * 30) then
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i].data = GUILDBOOK_GAMEOBJECTS[k]
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i].id = k
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i]:Show()
                i = i + 1
            end
        end
    end
end

function Guildbook.OptionsInterface.GatheringDatabase.RefreshListView()
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        local scrollPos = GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar:GetValue()
        local i = 1
        Guildbook.OptionsInterface.GatheringDatabase.ClearListView()
        for k, gameObject in ipairs(GUILDBOOK_GAMEOBJECTS) do
            if k > tonumber((scrollPos - 1) * 30) and k <= tonumber(scrollPos * 30) then
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i].data = GUILDBOOK_GAMEOBJECTS[k]
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i].id = k
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i]:Show()
                i = i + 1
            end
        end
    end
end

--this may be the only time for the function so maybe just bring the script into this function rather than call another????
function GuildbookOptionsGatheringDatabase_OnHide(self)
    Guildbook.OptionsInterface.GatheringDatabase.ClearListViewSelectedData()
    DEBUG('removed object field \'selected\' from game object')
end

function GuildbookOptionsGatheringDatabase_OnShow(self)

    GuildbookOptionsGatheringDatabaseHeader:SetText(L['GatheringDatabaseHeader'])

    Guildbook.OptionsInterface.GatheringDatabase.AddListViewSelectedData()
    if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
        Guildbook.OptionsInterface.GatheringDatabase.ClearListView()
        GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar:SetValue(1)
        GuildbookOptionsGatheringDatabaseGameObjectsListViewScrollBar:SetMinMaxValues(1, tonumber(math.ceil(#GUILDBOOK_GAMEOBJECTS / 30)))
        if GUILDBOOK_GAMEOBJECTS and next(GUILDBOOK_GAMEOBJECTS) then
            for i = 1, 30 do
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i].data = GUILDBOOK_GAMEOBJECTS[i]
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i].id = i
                Guildbook.OptionsInterface.GatheringDatabase.ListViewRows[i]:Show()
            end
        end
    end
end
