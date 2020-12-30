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

-- Legacy: old code for previous guildbook UI

local addonName, Guildbook = ...

local L = Guildbook.Locales
local DEBUG = Guildbook.DEBUG


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- tradeskill frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupTradeSkillFrame()

    local helpText = [[
|cffffd100Profession sharing|r
|cffffffffGuildbook allows guild members to share their 
profession recipes.
To do this players must first open their professions 
which will trigger a scan of available recipes and save 
this data.

To view another members profession, select the profession 
to see a list of members who have that profession.
When you select a guild member Guildbook will either use 
data saved on file or request data from the member.|r

|cff06B200If recipes do not show correctly right click the 
character and select|r |cffffffff'Request data'.|r
]]

    self.GuildFrame.TradeSkillFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.TradeSkillFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPRIGHT', -2, 2, helpText)

    -- hmmm? char not used but prof is - consider better
    local selectedCharacter = nil
    local selectedProfession = nil

    -- table to hold recipe listview data
    self.GuildFrame.TradeSkillFrame.RecipesTable = {}

    function self.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(listview)
        for k, button in ipairs(listview) do
            if button.data and button.data.Selected == true then
                button:GetHighlightTexture():SetVertexColor(1, 1, 0);
                button:LockHighlight()
            else
                button:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8);
                button:UnlockHighlight();
            end
        end
    end

    self.GuildFrame.TradeSkillFrame.Header = self.GuildFrame.TradeSkillFrame:CreateFontString('GuildbookGuildInfoFrameTradeSkillFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.TradeSkillFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.TradeSkillFrame, 'TOP', 0, 4)
    self.GuildFrame.TradeSkillFrame.Header:SetText('Trade Skills')
    self.GuildFrame.TradeSkillFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.TradeSkillFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.TradeSkillFrame.ProfessionIcon = self.GuildFrame.TradeSkillFrame:CreateTexture('$parentProfIcon', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.ProfessionIcon:SetPoint('TOPLEFT', 8, -8)
    self.GuildFrame.TradeSkillFrame.ProfessionIcon:SetSize(40, 40)

    self.GuildFrame.TradeSkillFrame.ProfessionDescription = self.GuildFrame.TradeSkillFrame:CreateFontString('GuildbookGuildInfoFrameTradeSkillFrameProfessionDescription', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetPoint('TOPLEFT', self.GuildFrame.TradeSkillFrame.ProfessionIcon, 'TOPRIGHT', 4, 6)
    self.GuildFrame.TradeSkillFrame.ProfessionDescription:SetSize(730, 60)

    self.GuildFrame.TradeSkillFrame.TopBorder = self.GuildFrame.TradeSkillFrame:CreateTexture('GuildbookGuildInfoFrameTradeSkillFrameTopBorder', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.TopBorder:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPLEFT', 4, -125)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetPoint('TOPRIGHT', Guildbook.GuildFrame.TradeSkillFrame, 'TOPRIGHT', -4, -125)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetHeight(10)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetTexture(130968)
    self.GuildFrame.TradeSkillFrame.TopBorder:SetTexCoord(0.1, 1.0, 0.0, 0.3)

    self.GuildFrame.TradeSkillFrame.HeaderInfoText = self.GuildFrame.TradeSkillFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.HeaderInfoText:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.TopBorder, 'TOPLEFT', 3, 0)
    self.GuildFrame.TradeSkillFrame.HeaderInfoText:SetText('Select Profession & Character |cffffffff'..Guildbook.Data.StatusIconStringsSMALL['Offline']..'offline, '..Guildbook.Data.StatusIconStringsSMALL['Online']..'online|r')

    self.GuildFrame.TradeSkillFrame.ProfessionButtons = {}
    local profButtonPosY = 0
    local x = 1
    for i = 9, 1, -1 do
        local prof = Guildbook.Data.Professions[i]
        if prof.TradeSkill == true then
            local f = CreateFrame('BUTTON', 'GuildbookTradeSkillFrameProfessionButton'..prof.Name, self.GuildFrame.TradeSkillFrame) --, "UIPanelButtonTemplate")
            f:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'BOTTOMLEFT', 6, profButtonPosY + 4)
            f:SetSize(120, 24.2)
            f:SetText(prof.Name)
            f:SetNormalFontObject(GameFontNormalSmall)
            f:SetHighlightFontObject(GameFontNormalSmall)
            f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
            f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
            f:GetFontString():SetPoint('LEFT', 4, 0)
            f:GetFontString():SetTextColor(1,1,1,1)
            f.icon = f:CreateTexture(nil, 'ARTWORK')
            f.icon:SetPoint('RIGHT', 0, 0)
            f.icon:SetSize(20, 20)
            f.icon:SetTexture(Guildbook.Data.Profession[prof.Name].IconID)
            f.data = { Selected = false }
            f:SetScript('OnClick', function(self)
                for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.ProfessionButtons) do
                    if v.data then
                        v.data.Selected = false
                    end
                end
                self.data.Selected = not self.data.Selected
                Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.ProfessionButtons)
                Guildbook.GuildFrame.TradeSkillFrame:HideCharacterListviewButtons()
                selectedProfession = prof.Name
                Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValue(1)
                Guildbook.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof.Name)
                C_Timer.After(1, function()
                    Guildbook.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
                end)                
                Guildbook.GuildFrame.TradeSkillFrame:ClearRecipesListview()
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionIcon:SetTexture(Guildbook.Data.Profession[prof.Name].Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('|cffffffff'..Guildbook.Data.ProfessionDescriptions[prof.Name]..'|r')
                Guildbook.GuildFrame.TradeSkillFrame.RecipesTable = {}
                DEBUG('SetupTradeSkillFrame', 'selected '..prof.Name)
            end)
            profButtonPosY = profButtonPosY + 23.1
            self.GuildFrame.TradeSkillFrame.ProfessionButtons[x] = f
            x = x + 1
        end
    end

    self.GuildFrame.TradeSkillFrame.CharactersWithProf = {'test'}
    self.GuildFrame.TradeSkillFrame.CharactersListviewRows = {}
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameCharactersListviewParent', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame, 'BOTTOMLEFT', 125, 4)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent:SetSize(136, 210)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.background = self.GuildFrame.TradeSkillFrame.CharactersListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.background:SetAllPoints(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent:EnableMouse(true)

    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop = self.GuildFrame.TradeSkillFrame.CharactersListviewParent:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'TOPRIGHT', -1, 2)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetSize(30, 180)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.7)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom = self.GuildFrame.TradeSkillFrame.CharactersListviewParent:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'BOTTOMRIGHT', -2, 0)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.TradeSkillFrame.CharactersListviewParent.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.4)

    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameCharactersListviewScrollBar', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, "UIPanelScrollBarTemplate")
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'TOPRIGHT', 28, -17)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'BOTTOMRIGHT', 0, 16)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValueStep(1)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetValue(1)
    self.GuildFrame.TradeSkillFrame.CharactersListviewScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
    end)

    -- create characters with prof listview
    for i = 1, 10 do
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameCharactersListviewRow'..i), self.GuildFrame.TradeSkillFrame.CharactersListviewParent )--, "OptionsListButtonTemplate")
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'TOPLEFT', 0, (i - 1) * -21)
        f:SetSize(self.GuildFrame.TradeSkillFrame.CharactersListviewParent:GetWidth(), 20)
        --f:EnableMouse(true)
        f:SetEnabled(true)
        f:RegisterForClicks('AnyDown')
        f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
        f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.id = i
        f.selected = false
        f.data = nil
        f:SetScript('OnClick', function(self, button)
            for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows) do
                if v.data then
                    v.data.Selected = false
                end
            end
            if self.data then
                self.data.Selected = not self.data.Selected
            end
            Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewRows)
            if self.data then
                -- offer context menu with request update
                if button == 'RightButton' then
                    Guildbook.ContextMenu = {
                        { 
                            text = 'Options', 
                            isTitle = true, 
                            notCheckable = true, },
                        { 
                            text = 'Request data', 
                            notCheckable = true, 
                            func = function()
                            
                                Guildbook.GuildFrame.TradeSkillFrame:RequestProfessionData(self.data.Name, selectedProfession)
                            end, 
                        },
                        { 
                            text = 'Cancel', 
                            notCheckable = true, 
                            func = function()
                                CloseDropDownMenus()
                            end, 
                        },
                    }
                    EasyMenu(Guildbook.ContextMenu, Guildbook.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
                else
                    local guildName = Guildbook:GetGuildName()
                    -- if we have any recipes already on file, load these, this avoids sending additional chat messages, updates can be requested
                    if guildName and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession] and type(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession]) == 'table' then
                        DEBUG('SetupTradeSkillFrame', 'recipe database found on file, loading data for: '..selectedProfession)
                        Guildbook.GuildFrame.TradeSkillFrame.RecipesTable = GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession]
                        Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName][self.data.GUID][selectedProfession], nil)
                    else
                        -- send request and show cooldown UI so player is aware something is happening
                        DEBUG('SetupTradeSkillFrame', 'no data on file, sending request to: '..self.data.Name..' for data: '..selectedProfession)
                        Guildbook.GuildFrame.TradeSkillFrame:RequestProfessionData(self.data.Name, selectedProfession)
                    end
                end
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                if Guildbook:IsGuildMemberOnline(self.data.GUID) then
                    self.Text:SetText(Guildbook.Data.StatusIconStringsSMALL['Online']..' '..self.data.Name)
                else
                    self.Text:SetText(Guildbook.Data.StatusIconStringsSMALL['Offline']..' '..self.data.Name)
                end
            end
        end)
        f:SetScript('OnHide', function(self)
            self.data = nil
            self.Text:SetText(' ')
        end)
        self.GuildFrame.TradeSkillFrame.CharactersListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:RequestProfessionData(character, prof)
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        self.RecipesTable = {}
        Guildbook:SendTradeSkillsRequest(character, prof)
        self.RecipesListviewParent.ProgressCooldown:Show()
        self.RecipesListviewParent.ProgressCooldown.cooldown:SetCooldown(GetTime(), 4.0)
        for i = 1, 10 do
            self.CharactersListviewRows[i]:Disable()
        end
        C_Timer.After(4.5, function()
            for i = 1, 10 do
                self.CharactersListviewRows[i]:Enable()
            end
            Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:Hide()
            Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(self.RecipesTable, nil)
        end)
    end

    function self.GuildFrame.TradeSkillFrame:GetPlayersWithProf(prof)
        DEBUG('TradeSkillFrame:GetPlayersWithProf', 'getting players with prof '..prof)
        local guildName = Guildbook:GetGuildName()
        if guildName and GUILDBOOK_GLOBAL and GUILDBOOK_GLOBAL['GuildRosterCache'][guildName] then
            wipe(self.CharactersWithProf)
            for guid, character in pairs(GUILDBOOK_GLOBAL['GuildRosterCache'][guildName]) do
                if (character.Profession1 == prof) or (character.Profession2 == prof) then
                    DEBUG('TradeSkillFrame:GetPlayersWithProf', 'found matching profession with '..character.Name)
                    table.insert(self.CharactersWithProf, {
                        Name = character.Name,
                        GUID = guid,
                        Selected = false,
                    })
                    DEBUG('TradeSkillFrame:GetPlayersWithProf', 'added '..character.Name..' to list')
                end
                if prof == 'Cooking' and character.CookingLevel and tonumber(character.CookingLevel) > 0.0 then
                    table.insert(self.CharactersWithProf, {
                        Name = character.Name,
                        GUID = guid,
                        Selected = false,
                    })
                    DEBUG('TradeSkillFrame:GetPlayersWithProf', 'added '..character.Name..' to list')
                end
            end
            local c = #self.CharactersWithProf
            if c <= 10 then
                -- self.CharactersListviewScrollBar:SetMinMaxValues(1, 2)
                -- self.CharactersListviewScrollBar:SetValue(2)
                -- self.CharactersListviewScrollBar:SetValue(1)
                self.CharactersListviewScrollBar:SetMinMaxValues(1, 1)
                DEBUG('TradeSkillFrame:GetPlayersWithProf', 'set minmax to 1,1')
            else
                self.CharactersListviewScrollBar:SetMinMaxValues(1, (c - 9))
                -- self.CharactersListviewScrollBar:SetValue(2)
                -- self.CharactersListviewScrollBar:SetValue(1)
                DEBUG('TradeSkillFrame:GetPlayersWithProf', 'set minmax to 1,'..(c-9))
            end
        end
    end

    function self.GuildFrame.TradeSkillFrame:HideCharacterListviewButtons()
        for i = 1, 10 do
            self.CharactersListviewRows[i]:Hide()
        end
        self.UpdateListviewSelectedTextures(self.CharactersListviewRows)
    end

    function self.GuildFrame.TradeSkillFrame:RefreshCharactersListview()
        self:HideCharacterListviewButtons()
        if next(self.CharactersWithProf) then
            local scrollPos = math.floor(self.CharactersListviewScrollBar:GetValue())
            if scrollPos == 0 then
                scrollPos = 1
            end
            for i = 1, 10 do
                if self.CharactersWithProf[(i - 1) + scrollPos] then
                    self.CharactersListviewRows[i]:Hide()
                    self.CharactersListviewRows[i].data = self.CharactersWithProf[(i - 1) + scrollPos]
                    self.CharactersListviewRows[i]:Show()
                end
            end
        end
    end

    -- recipes
    self.GuildFrame.TradeSkillFrame.Recipes = {'test'}
    self.GuildFrame.TradeSkillFrame.RecipesListviewRows = {}
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameRecipesListviewParent', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.CharactersListviewParent, 'BOTTOMRIGHT', 28, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:SetSize(235, 210)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.background = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.background:SetAllPoints(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent:SetScript('OnMouseWheel', function(self, delta)
        local s = self.ScrollBar:GetValue()
        self.ScrollBar:SetValue(s - delta)
    end)

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPLEFT', 0, 4)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText:SetText('Search recipes')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText:SetSize(80, 22)

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox = CreateFrame('EDITBOX', 'GuildbookGuildFrameRecipesListviewParentSearchBox', self.GuildFrame.TradeSkillFrame.RecipesListviewParent, "InputBoxTemplate")
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetPoint('LEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBoxText, 'RIGHT', 6, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetSize(150, 22)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:ClearFocus()
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetAutoFocus(false)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.SearchBox:SetScript('OnTextChanged', function(self)
        if self:GetText():len() > 2 then
            --print('settign recipes with filter')
            local filter = self:GetText()
            Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(Guildbook.GuildFrame.TradeSkillFrame.RecipesTable, filter)
        else
            --print('settign recipes without filter')
            Guildbook.GuildFrame.TradeSkillFrame:SetRecipesListviewData(Guildbook.GuildFrame.TradeSkillFrame.RecipesTable, nil)
        end

    end)
   
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown = CreateFrame('FRAME', 'GuildbookGuildFrameRecipesListviewParentCooldown', self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:SetPoint('CENTER', 0, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:SetSize(40, 40)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.texture = self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:CreateTexture('$parentTexture', 'BACKGROUND')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.texture:SetAllPoints(self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.texture:SetTexture(132996)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.cooldown = CreateFrame("Cooldown", "$parentCooldown", Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown, "CooldownFrameTemplate")
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown.cooldown:SetAllPoints(self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ProgressCooldown:Hide()

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPRIGHT', -1, 2)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetSize(30, 180)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.7)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom = self.GuildFrame.TradeSkillFrame.RecipesListviewParent:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', -2, 0)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.4)

    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameRecipesListviewScrollBar', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, "UIPanelScrollBarTemplate")
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPRIGHT', 28, -17)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', 0, 16)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetValueStep(1)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetValue(1)
    self.GuildFrame.TradeSkillFrame.RecipesListviewParent.ScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.TradeSkillFrame:RefreshListview()
        Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
    end)

    -- create recipes with prof listview
    for i = 1, 10 do
        local f = CreateFrame('BUTTON', tostring('GuildbookGuildFrameRecipesListviewRow'..i), self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'TOPLEFT', 0, (i - 1) * -21)
        f:SetSize(self.GuildFrame.TradeSkillFrame.RecipesListviewParent:GetWidth(), 20)
        f:SetEnabled(true)
        f:RegisterForClicks('AnyDown')
        f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
        f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
        f.Text = f:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormalSmall')
        f.Text:SetPoint('LEFT', 4, 0)
        f.Text:SetTextColor(1,1,1,1)
        f.id = i
        f.selected = false
        f.data = nil
        f:SetScript('OnClick', function(self)
            for k, v in ipairs(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows) do
                if v.data then
                    v.data.Selected = false
                end
            end
            if self.data then
                self.data.Selected = not self.data.Selected
            end
            Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
            if self.data then
                Guildbook.GuildFrame.TradeSkillFrame:ClearReagentsListview()
                Guildbook.GuildFrame.TradeSkillFrame:UpdateReagents(f.data)
                if self.data.Enchant then
                    Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = 'spell:'..self.data.ItemID
                    Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.spellID = self.data.ItemID
                else
                    Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = self.data.Link
                end
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetTexture(self.data.Icon)
                Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetText(self.data.Link)
            end
        end)
        f:SetScript('OnShow', function(self)
            if self.data then
                self.Text:SetText(self.data.Link)
            else
                self:Hide()
            end
            Guildbook.GuildFrame.TradeSkillFrame.UpdateListviewSelectedTextures(Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewRows)
        end)
        f:SetScript('OnHide', function(self)
            self.data = nil
            self.Text:SetText(' ')
        end)
        self.GuildFrame.TradeSkillFrame.RecipesListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:ClearRecipesListview()
        self.UpdateListviewSelectedTextures(self.RecipesListviewRows)
        for i = 1, 10 do
            self.RecipesListviewRows[i].selected = false
            self.RecipesListviewRows[i].data = nil
            self.RecipesListviewRows[i]:Hide()
        end
        wipe(self.Recipes)
    end


    function self.GuildFrame.TradeSkillFrame:RefreshListview()
        if next(self.Recipes) then
            table.sort(self.Recipes, function(a, b)
                if a.Rarity == b.Rarity then
                    return a.Name < b.Name
                else
                    return a.Rarity > b.Rarity
                end
            end)
            local c = #self.Recipes
            if c <= 10 then
                self.RecipesListviewParent.ScrollBar:SetMinMaxValues(1, 1)
            else
                self.RecipesListviewParent.ScrollBar:SetMinMaxValues(1, (c - 9))
            end
            local scrollPos = math.floor(self.RecipesListviewParent.ScrollBar:GetValue())
            if scrollPos == 0 then
                scrollPos = 1
            end
            for i = 1, 10 do
                if self.Recipes[(i - 1) + scrollPos] then
                    self.RecipesListviewRows[i]:Hide()
                    self.RecipesListviewRows[i].data = self.Recipes[(i - 1) + scrollPos]
                    self.RecipesListviewRows[i]:Show()
                end
            end
        end
    end
    
    function self.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
        local recipeItem = {
            ItemID = itemID,
            Link = link,
            Enchant = enchant,
            Rarity = tonumber(rarity),
            Reagents = {},
            Icon = tonumber(icon),
            Name = name,
            Selected = false,
        }
        for reagentID, count in pairs(reagents) do
            local reagentLink = select(2, GetItemInfo(reagentID))
            local reagentRarity = select(3, GetItemInfo(reagentID))
            table.insert(recipeItem.Reagents, {
                ItemID = reagentID,
                Count = tonumber(count),
            })
            --DEBUG('TradeSkillFrame:AddRecipe', string.format('add %s to reagents list', reagentID))
        end
        if filter == nil then
            table.insert(self.Recipes, recipeItem)
        else
            if recipeItem.Name:lower():find(filter:lower()) then
                table.insert(self.Recipes, recipeItem)
            end
        end
        self:RefreshListview()
    end

    function self.GuildFrame.TradeSkillFrame:SetRecipesListviewData(data, filter)
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        if data and type(data) == 'table' and next(data) then
            local k = 1
            for itemID, reagents in pairs(data) do
                local link = false
                local rarity = false
                local icon = false
                local enchant = false
                if selectedProfession == 'Enchanting' then
                    link = select(1, GetSpellLink(itemID))
                    rarity = select(3, GetItemInfo(link)) or 1
                    name = select(1, GetSpellInfo(itemID)) or 'unknown'
                    icon = select(3, GetSpellInfo(itemID)) or 134400
                    enchant = true
                    DEBUG('TradeSkillFrame:SetRecipesListviewData', string.format('added enchant %s with rarity %s and icon %s', link, rarity, icon))
                else
                    link = select(2, GetItemInfo(itemID))
                    rarity = select(3, GetItemInfo(itemID))
                    name = select(1, GetItemInfo(itemID))
                    icon = select(10, GetItemInfo(itemID))
                end
                if link and rarity and icon and name then
                    Guildbook.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
                else
                    if selectedProfession == 'Enchanting' then                    
                        local spell = Spell:CreateFromSpellID(spellID)
                        spell:ContinueOnSpellLoad(function()
                            link = select(1, GetSpellLink(itemID))
                            rarity =  1
                            name = select(1, GetSpellInfo(itemID)) or 'unknown'
                            icon = select(3, GetSpellInfo(itemID)) or 134400
                            enchant = true
                            Guildbook.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
                        end)
                    else
                        local item = Item:CreateFromItemID(itemID)
                        item:ContinueOnItemLoad(function()
                            icon = item:GetItemIcon()
                            name = item:GetItemName()
                            link = item:GetItemLink()
                            rarity = item:GetItemQuality()
                            enchant = false
                            Guildbook.GuildFrame.TradeSkillFrame:AddRecipe(itemID, link, enchant, rarity, icon, name, reagents, filter)
                        end)
                    end
                end
            end
        end
    end

    -- reagents
    self.GuildFrame.TradeSkillFrame.Reagents = {'test'}
    self.GuildFrame.TradeSkillFrame.ReagentsListviewRows = {}
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent = CreateFrame('FRAME', 'GuildbookGuildFrameReagentsListviewParent', self.GuildFrame.TradeSkillFrame)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:SetPoint('BOTTOMLEFT', Guildbook.GuildFrame.TradeSkillFrame.RecipesListviewParent, 'BOTTOMRIGHT', 28, 0)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:SetSize(250, 210)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background = self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:CreateTexture('$parentBackground', 'BACKGROND')
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background:SetAllPoints(Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.background:SetColorTexture(0.2,0.2,0.2,0.2)

    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem = CreateFrame('FRAME', 'GuildbookGuildFrameReagentsListviewParentRecipeItem', self.GuildFrame.TradeSkillFrame.ReagentsListviewParent)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetPoint('TOPLEFT', 4, -4)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetSize(200, 25)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:EnableMouse(true)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = nil
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnEnter', function(self)
        if self.link then
            GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:SetScript('OnMouseDown', function(self)
        if self.link then
            if IsShiftKeyDown() then
                if selectedProfession == 'Enchanting' and self.spellID then
                    HandleModifiedItemClick(GetSpellLink(self.spellID))
                else
                    HandleModifiedItemClick(self.link)
                end
            end
            if IsControlKeyDown() then
                DressUpItemLink(self.link)
            end
        end
    end)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon = self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:CreateTexture('$parentRecipeItemIcon', 'ARTWORK')
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetPoint('LEFT', 4, 0)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetSize(25, 25)
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName = self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem:CreateFontString('$parentRecipeItemName', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetPoint('TOPLEFT', self.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon, 'TOPRIGHT', 4, -4)

    for i = 1, 8 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameRecipesListviewRow'..i), self.GuildFrame.TradeSkillFrame.RecipesListviewParent)
        f:SetPoint('TOPLEFT', Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent, 'TOPLEFT', 4, ((i - 1) * -22) - 35)
        f:SetSize(self.GuildFrame.TradeSkillFrame.ReagentsListviewParent:GetWidth(), 20)
        f:EnableMouse(true)

        f.icon = f:CreateTexture('$parentIcon', 'ARTWORK')
        f.icon:SetPoint('LEFT', 4, 0)
        f.icon:SetSize(20, 20)

        f.text = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.text:SetPoint('LEFT', f.icon, 'RIGHT', 4, 0)
        f.text:SetTextColor(1,1,1,1)

        f.link = nil
        f:SetScript('OnEnter', function(self)
            if self.link then
                GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
                GameTooltip:SetHyperlink(self.link)
                GameTooltip:Show()
            end
        end)
        f:SetScript('OnLeave', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)
        f:SetScript('OnMouseDown', function(self)
            if self.link then
                print('got link')
                if IsShiftKeyDown() then
                    HandleModifiedItemClick(self.link)
                end
                if IsControlKeyDown() then
                    print('ctrl')
                    DressUpItemLink(self.link)
                end
            end
        end)

        self.GuildFrame.TradeSkillFrame.ReagentsListviewRows[i] = f
    end

    function self.GuildFrame.TradeSkillFrame:ClearReagentsListview()
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItem.link = nil
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemIcon:SetTexture(nil)
        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewParent.recipeItemName:SetText(' ')
        for k, v in ipairs(self.ReagentsListviewRows) do
            v.icon:SetTexture(nil)
            v.text:SetText(' ')
            v.link = nil
        end
    end

    function self.GuildFrame.TradeSkillFrame:UpdateReagents(recipe)
        self:ClearReagentsListview()
        if recipe and recipe.Reagents then
            for k, v in ipairs(recipe.Reagents) do
                local link = select(2, GetItemInfo(v.ItemID))
                local icon = select(10, GetItemInfo(v.ItemID))
                if link and icon then
                    self.ReagentsListviewRows[k].icon:SetTexture(icon)
                    self.ReagentsListviewRows[k].text:SetText(string.format('[%s] %s', v.Count, link))
                    self.ReagentsListviewRows[k].link = link
                else
                    local item = Item:CreateFromItemID(v.ItemID)
                    item:ContinueOnItemLoad(function()
                        icon = item:GetItemIcon()
                        link = item:GetItemLink()
                        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewRows[k].icon:SetTexture(icon)
                        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewRows[k].text:SetText(string.format('[%s] %s', v.Count, link))
                        Guildbook.GuildFrame.TradeSkillFrame.ReagentsListviewRows[k].link = link
                    end)
                end
            end
        end
    end

    self.GuildFrame.TradeSkillFrame:SetScript('OnShow', function(self)
        DEBUG('TradeSkillFrame OnShow','showing tradeskill frame')
        self:HideCharacterListviewButtons()
        self:ClearRecipesListview()
        self:ClearReagentsListview()
        Guildbook.GuildFrame.TradeSkillFrame.ProfessionIcon:SetTexture(nil)
        Guildbook.GuildFrame.TradeSkillFrame.ProfessionDescription:SetText('|cffffffffSelect a profession to see members of your guild who are trained in that profession.|r|cff0070DE Right click player for more options.|r \nThis feature can result in bulk comms, DO NOT spam click character names, there may be a need to click twice but twice only!')
    end)

end































-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- soft res
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Guildbook:SetupSoftReserveFrame()

    local helpText = [[
|cffffd100Soft Reserve|r
|cffffffffGuildbook soft reserve system is kept simple, you can select 1 
item per raid as your soft reserve.
To do this use the 'Select Reserve' drop down menu to search 
raids and bosses, click the item you wish to reserve.
To view current reserves for a raid use the 'Set Raid' drop down
to select a raid.
Only current raid members soft reserves will be shown, players 
not yet in the group will not be queried.
|r

|cff06B200Soft reserves can only be set outside an instance, this 
is to prevent players changing a reserve if they win an item early 
during a raid.|r
    ]]
        
    self.GuildFrame.SoftReserveFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.SoftReserveFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.SoftReserveFrame, 'TOPRIGHT', -2, 2, helptext)

    self.GuildFrame.SoftReserveFrame.SelectedRaid = nil

    if not GUILDBOOK_CHARACTER['SoftReserve'] then
        GUILDBOOK_CHARACTER['SoftReserve'] = {}
    end

    -- sort our data into alphabetical lists to help the player when navigating, items will be sorted by rarity later
    local raidSorted, raidBosses = {}, {}
    for raid, bosses in pairs(Guildbook.RaidItems) do
        table.insert(raidSorted, raid)
        raidBosses[raid] = {}
        for boss, _ in pairs(bosses) do
            table.insert(raidBosses[raid], boss)
        end
        table.sort(raidBosses[raid])
    end
    table.sort(raidSorted)

    self.RaidLoot = {}

    for k, raid in pairs(raidSorted) do
        local bossList = {}
        for j, boss in ipairs(raidBosses[raid]) do
            local lootList = {}
            for _, itemID in ipairs(Guildbook.RaidItems[raid][boss]) do
                -- local itemLink = select(2, GetItemInfo(itemID))
                -- local itemRarity = select(3, GetItemInfo(itemID))
                -- table.insert(lootList, {
                --     text = itemLink,
                --     arg1 = itemRarity,
                --     notCheckable = true,
                --     func = function()
                --         GUILDBOOK_CHARACTER['SoftReserve'][raid] = itemID
                --         print(string.format('You have set %s as your soft reserve for %s', link, raid))
                --     end,
                -- })
                -- table.sort(lootList, function(a, b)
                --     return a.arg1 > b.arg1
                -- end)

                -- using the mixin to ensure we get data on first load
                local item = Item:CreateFromItemID(itemID)
                item:ContinueOnItemLoad(function()
                    local link = item:GetItemLink()
                    local quality = item:GetItemQuality()
                    table.insert(lootList, {
                        text = link,
                        arg1 = quality,
                        notCheckable = true,
                        func = function()
                            GUILDBOOK_CHARACTER['SoftReserve'][raid] = itemID
                            print(string.format('You have set %s as your soft reserve for %s', link, raid))
                        end,
                    })
                end)
            end
            table.insert(lootList, {
                text = 'None',
                arg1 = 10000,
                notCheckable = true,
                func = function()
                    GUILDBOOK_CHARACTER['SoftReserve'][raid] = -1
                    --print(string.format('You have set %s as your soft reserve for %s', link, raid))
                end,
            })
            -- this there a better way than relying on data being ready after 5 seconds and assuming the player wont access the dropdown before 5 seconds ?
            C_Timer.After(5, function()
                table.sort(lootList, function(a, b)
                    return a.arg1 > b.arg1
                end)
            end)
            table.insert(bossList, {
                text = boss,
                hasArrow = true,
                notCheckable = true,
                menuList = lootList
            })
        end
        table.insert(self.RaidLoot, {
            text = raid,
            hasArrow = true,
            notCheckable = true,
            menuList = bossList
        })
    end

    self.GuildFrame.SoftReserveFrame.Header = self.GuildFrame.SoftReserveFrame:CreateFontString('GuildbookGuildInfoFrameSoftReserveFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.SoftReserveFrame.Header:SetPoint('TOPLEFT', Guildbook.GuildFrame.SoftReserveFrame, 'TOPLEFT', 10, -5)
    self.GuildFrame.SoftReserveFrame.Header:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.SoftReserveFrame, 'TOPRIGHT', -180, -30)
    self.GuildFrame.SoftReserveFrame.Header:SetText('Select your reserve and set raid to see other members reserves')
    self.GuildFrame.SoftReserveFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.SoftReserveFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 11)
    self.GuildFrame.SoftReserveFrame.Header:SetJustifyH('LEFT')
    self.GuildFrame.SoftReserveFrame.Header:SetJustifyV('CENTER')

    self.GuildFrame.SoftReserveFrame.ItemDropdown = CreateFrame('FRAME', "GuildbookGuildFrameSoftReserveFrameItemDropdown", self.GuildFrame.SoftReserveFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.SoftReserveFrame.ItemDropdown:SetPoint('TOPRIGHT', 0, -10)
    UIDropDownMenu_SetWidth(self.GuildFrame.SoftReserveFrame.ItemDropdown, 140)
    UIDropDownMenu_SetText(self.GuildFrame.SoftReserveFrame.ItemDropdown, 'Select Reserve')
    _G['GuildbookGuildFrameSoftReserveFrameItemDropdownButton']:SetScript('OnClick', function(self)
        EasyMenu(Guildbook.RaidLoot, Guildbook.GuildFrame.SoftReserveFrame.ItemDropdown, Guildbook.GuildFrame.SoftReserveFrame.ItemDropdown, 10, 10, 'NONE')
    end)

    self.GuildFrame.SoftReserveFrame.RaidDropdown = CreateFrame('FRAME', "GuildbookGuildFrameSoftReserveFrameItemDropdown", self.GuildFrame.SoftReserveFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.SoftReserveFrame.RaidDropdown:SetPoint('RIGHT', Guildbook.GuildFrame.SoftReserveFrame.ItemDropdown, 'LEFT', 0, 0)
    UIDropDownMenu_SetWidth(self.GuildFrame.SoftReserveFrame.RaidDropdown, 140)
    UIDropDownMenu_SetText(self.GuildFrame.SoftReserveFrame.RaidDropdown, 'Set Raid')
    function self.GuildFrame.SoftReserveFrame:RaidDropdown_Init()
        UIDropDownMenu_Initialize(self.RaidDropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            for raid, bosses in pairs(Guildbook.RaidItems) do
                info.text = raid
                info.notCheckable = true
                info.func = function()
                    Guildbook.GuildFrame.SoftReserveFrame.SelectedRaid = raid
                    UIDropDownMenu_SetText(Guildbook.GuildFrame.SoftReserveFrame.RaidDropdown, raid)
                    Guildbook.GuildFrame.SoftReserveFrame:ClearRaidCharacters()
                    Guildbook:RequestRaidSoftReserves()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
    self.GuildFrame.SoftReserveFrame:RaidDropdown_Init() -- ?

    local offsetY = 38.0
    self.GuildFrame.SoftReserveFrame.RaidRosterList = {}
    for i = 1, 20 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameSoftReserveFrameRaidRosterList'..i), self.GuildFrame.SoftReserveFrame)
        f:SetPoint('TOPLEFT', 16, ((i - 1) * -15) - offsetY)
        f:SetSize(200, 14)
        f.player = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.player:SetPoint('LEFT', 0, 0)
        f.player:SetText('player name '..i)
        f.softReserve = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.softReserve:SetPoint('LEFT', 90, 0)
        f.softReserve:SetText('soft reserve '..i)
        f.data= nil
        f.id = i

        f:SetScript('OnShow', function(self)
            if self.data and self.data.Character then
                self.player:SetText(self.id..' '..Guildbook.Data.Class[self.data.Class].FontColour..self.data.Character)
                local link = 'None'
                if self.data.ItemID > 0 then
                    link = select(2, GetItemInfo(self.data.ItemID))
                end
                self.softReserve:SetText(link)
            end
        end)

        self.GuildFrame.SoftReserveFrame.RaidRosterList[i] = f
    end
    for i = 21, 40 do
        local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameSoftReserveFrameRaidRosterList'..i), self.GuildFrame.SoftReserveFrame)
        f:SetPoint('TOPLEFT', 346, ((i - 21) * -15) - offsetY)
        f:SetSize(200, 14)
        f.player = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.player:SetPoint('LEFT', 0, 0)
        f.player:SetText('player name '..i)
        f.softReserve = f:CreateFontString('$parentName', 'OVERLAY', 'GameFontNormalSmall')
        f.softReserve:SetPoint('LEFT', 90, 0)
        f.softReserve:SetText('soft reserve '..i)
        f.data = nil
        f.id = i

        f:SetScript('OnShow', function(self)
            if self.data and self.data.Character then
                self.player:SetText(self.id..' '..Guildbook.Data.Class[self.data.Class].FontColour..self.data.Character)
                local link = 'None'
                if self.data.ItemID > 0 then
                    link = select(2, GetItemInfo(self.data.ItemID))
                end
                self.softReserve:SetText(link)
            end
        end)

        self.GuildFrame.SoftReserveFrame.RaidRosterList[i] = f
    end

    function self.GuildFrame.SoftReserveFrame:LockItemDropdown()
        UIDropDownMenu_DisableDropDown(self.ItemDropdown)
    end
    function self.GuildFrame.SoftReserveFrame:UnLockItemDropdown()
        UIDropDownMenu_EnableDropDown(self.ItemDropdown)
    end

    function self.GuildFrame.SoftReserveFrame:ClearRaidCharacters()
        for i = 1, 40 do
            self.RaidRosterList[i].data = nil
            self.RaidRosterList[i]:Hide()
        end
    end

    self.GuildFrame.SoftReserveFrame:SetScript('OnShow', function(self)
        self:ClearRaidCharacters()
        --Guildbook:RequestRaidSoftReserves()
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
        --print(name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID)
        if instanceType == 'none' then            
            local isDead = UnitIsDead('player')
            if isDead then
                self:LockItemDropdown()
            else
                self:UnLockItemDropdown()
            end
        else
            self:LockItemDropdown()
        end
    end)

end































-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupGuildBankFrame()

    --self.GuildFrame.GuildBankFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -2, 2, 'Bank')

    self.GuildFrame.GuildBankFrame.bankCharacter = nil

    self.GuildFrame.GuildBankFrame:SetScript('OnShow', function(self)
        self:BankCharacterSelectDropDown_Init()
    end)

    self.GuildFrame.GuildBankFrame.Header = self.GuildFrame.GuildBankFrame:CreateFontString('GuildbookGuildInfoFrameGuildBankFrameHeader', 'OVERLAY', 'GameFontNormal')
    self.GuildFrame.GuildBankFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildBankFrame, 'TOP', 0, 4)
    self.GuildFrame.GuildBankFrame.Header:SetText('Guild Bank')
    self.GuildFrame.GuildBankFrame.Header:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildBankFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

    self.GuildFrame.GuildBankFrame.ProgressCooldown = CreateFrame('FRAME', 'GuildbookGuildFrameRecipesListviewParentCooldown', self.GuildFrame.GuildBankFrame)
    self.GuildFrame.GuildBankFrame.ProgressCooldown:SetPoint('LEFT', 80, 0)
    self.GuildFrame.GuildBankFrame.ProgressCooldown:SetSize(40, 40)
    self.GuildFrame.GuildBankFrame.ProgressCooldown.texture = self.GuildFrame.GuildBankFrame.ProgressCooldown:CreateTexture('$parentTexture', 'BACKGROUND')
    self.GuildFrame.GuildBankFrame.ProgressCooldown.texture:SetAllPoints(self.GuildFrame.GuildBankFrame.ProgressCooldown)
    self.GuildFrame.GuildBankFrame.ProgressCooldown.texture:SetTexture(132996)
    self.GuildFrame.GuildBankFrame.ProgressCooldown.cooldown = CreateFrame("Cooldown", "$parentCooldown", Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown, "CooldownFrameTemplate")
    self.GuildFrame.GuildBankFrame.ProgressCooldown.cooldown:SetAllPoints(self.GuildFrame.GuildBankFrame.ProgressCooldown)
    self.GuildFrame.GuildBankFrame.ProgressCooldown:Hide()

    self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown = CreateFrame('FRAME', 'GuildbookGuildFrameGuildBankFrameBankCharacterSelectDropDown', self.GuildFrame.GuildBankFrame, "UIDropDownMenuTemplate")
    self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown:SetPoint('TOPLEFT', self.GuildFrame.GuildBankFrame, 'TOPLEFT', 0, -48)
    UIDropDownMenu_SetWidth(self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown, 150)
    UIDropDownMenu_SetText(self.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown, 'Select Bank Character')
    function self.GuildFrame.GuildBankFrame:BankCharacterSelectDropDown_Init()
        UIDropDownMenu_Initialize(self.BankCharacterSelectDropDown, function(self, level, menuList)
            GuildRoster()
            local gbc = {}
            local totalMembers, onlineMembers, _ = GetNumGuildMembers()
            for i = 1, totalMembers do
                local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
                if publicNote:lower():find('guildbank') then
                    table.insert(gbc, name:match("^(.-)%-"))
                end
            end
            local info = UIDropDownMenu_CreateInfo()
            for k, p in pairs(gbc) do
                info.text = p
                info.hasArrow = false
                info.keepShownOnClick = false
                info.func = function()
                    Guildbook.GuildBankCommit = {
                        Commit = nil,
                        Character = nil,
                    }
                    Guildbook.GuildFrame.GuildBankFrame.bankCharacter = p
                    Guildbook.GuildFrame.GuildBankFrame.ResetSlots()
                    Guildbook:SendGuildBankCommitRequest(p)
                    Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown:Show()
                    Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown.cooldown:SetCooldown(GetTime(), 3.5)
                    -- for now delay the data request to allow commit checks first, could look to improve this or at the very least just reduce the delay
                    C_Timer.After(4, function()
                        Guildbook.GuildFrame.GuildBankFrame.ProgressCooldown:Hide()
                        if Guildbook.GuildBankCommit.Character and Guildbook.GuildBankCommit.Commit and Guildbook.GuildBankCommit.BankCharacter then
                            Guildbook:SendGuildBankDataRequest()
                            DEBUG('GuildBankFrame:BankCharacterSelectDropDown_Init', string.format('using %s as has newest commit, sending request for guild bank data - delayed', Guildbook.GuildBankCommit['BankCharacter']))
                            local ts = date('*t', Guildbook.GuildBankCommit.Commit)
                            ts.min = string.format('%02d', ts.min)
                            Guildbook.GuildFrame.GuildBankFrame.CommitInfo:SetText(string.format('Commit: %s:%s:%s  %s-%s-%s', ts.hour, ts.min, ts.sec, ts.day, ts.month, ts.year))
                            Guildbook.GuildFrame.GuildBankFrame.CommitSource:SetText(string.format('Commit Source: %s', Guildbook.GuildBankCommit.Character))
                            Guildbook.GuildFrame.GuildBankFrame.CommitBankCharacter:SetText(string.format('Bank Character: %s', Guildbook.GuildBankCommit.BankCharacter))
                        end
                    end)
                    DEBUG('GuildBankFrame:BankCharacterSelectDropDown_Init', 'requesting guild bank data from: '..p)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end

    self.GuildFrame.GuildBankFrame.CommitInfo = self.GuildFrame.GuildBankFrame:CreateFontString('$parentCommitInfo', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildBankFrame.CommitInfo:SetPoint('TOP', Guildbook.GuildFrame.GuildBankFrame.BankCharacterSelectDropDown, 'BOTTOM', 0, -2)
    self.GuildFrame.GuildBankFrame.CommitInfo:SetSize(220, 20)
    self.GuildFrame.GuildBankFrame.CommitInfo:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildBankFrame.CommitSource = self.GuildFrame.GuildBankFrame:CreateFontString('$parentCommitSource', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildBankFrame.CommitSource:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame.CommitInfo, 'BOTTOMLEFT', 0, -2)
    self.GuildFrame.GuildBankFrame.CommitSource:SetSize(220, 20)
    self.GuildFrame.GuildBankFrame.CommitSource:SetTextColor(1,1,1,1)
    self.GuildFrame.GuildBankFrame.CommitBankCharacter = self.GuildFrame.GuildBankFrame:CreateFontString('$parentCommitBankCharacter', 'OVERLAY', 'GameFontNormalSmall')
    self.GuildFrame.GuildBankFrame.CommitBankCharacter:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame.CommitSource, 'BOTTOMLEFT', 0, -2)
    self.GuildFrame.GuildBankFrame.CommitBankCharacter:SetSize(220, 20)
    self.GuildFrame.GuildBankFrame.CommitBankCharacter:SetTextColor(1,1,1,1)

    self.GuildFrame.GuildBankFrame.BankSlots = {}
    local slotIdx, slotWidth = 1, 40
    for column = 1, 14 do
        local x = ((column - 1) * slotWidth) + 205
        for row = 1, 7 do            
            local y = ((row -1) * -slotWidth) - 30
            local f = CreateFrame('FRAME', tostring('GuildbookGuildFrameGuildBankFrameCol'..column..'Row'..row), self.GuildFrame.GuildBankFrame)
            f:SetSize(slotWidth, slotWidth)
            f:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame, 'TOPLEFT', x, y)
            f:SetBackdrop({
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 16,
                --bgFile = "interface/framegeneral/ui-background-marble",
                tile = true,
                tileEdge = false,
                tileSize = 200,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            f.background = f:CreateTexture('$parentBackground', 'BACKGROUND')
            f.background:SetPoint('TOPLEFT', -11, 11)
            f.background:SetPoint('BOTTOMRIGHT', 11, -11)
            f.background:SetTexture(130766)
            f.icon = f:CreateTexture('$parentBackground', 'ARTWORK')
            f.icon:SetPoint('TOPLEFT', 2, -2)
            f.icon:SetPoint('BOTTOMRIGHT', -2, 2)
            f.count = f:CreateFontString('$parentCount', 'OVERLAY', 'GameFontNormal') --Small')
            f.count:SetPoint('BOTTOMRIGHT', -4, 3)
            f.count:SetTextColor(1,1,1,1)
            f.itemID = nil

            f:SetScript('OnEnter', function(self)
                if self.itemID then
                    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                    GameTooltip:SetItemByID(self.itemID)
                    GameTooltip:Show()
                else
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end
            end)
            f:SetScript('OnLeave', function(self)
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            end)

            self.GuildFrame.GuildBankFrame.BankSlots[slotIdx] = f
            slotIdx = slotIdx + 1
        end
    end

    function self.GuildFrame.GuildBankFrame:ResetSlots()
        for k, slot in pairs(Guildbook.GuildFrame.GuildBankFrame.BankSlots) do
            slot.background:SetTexture(130766)
            slot.icon:SetTexture(nil)
            slot.count:SetText(' ')
            slot.itemID = nil
        end
    end

    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop = self.GuildFrame.GuildBankFrame:CreateTexture('$parentBackgroundTop', 'ARTWORK')
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetTexture(136569)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetPoint('TOPRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -3, -4)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetSize(30, 280)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundTop:SetTexCoord(0, 0.5, 0, 0.9)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom = self.GuildFrame.GuildBankFrame:CreateTexture('$parentBackgroundBottom', 'ARTWORK')
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetTexture(136569)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', -4, 4)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetSize(30, 60)
    self.GuildFrame.GuildBankFrame.scrollBarBackgroundBottom:SetTexCoord(0.5, 1.0, 0.2, 0.41)

    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar = CreateFrame('SLIDER', 'GuildbookGuildFrameBankSlotsScrollBar', Guildbook.GuildFrame.GuildBankFrame, "UIPanelScrollBarTemplate")
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetPoint('TOPLEFT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -26, -26)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', -10, 22)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:EnableMouse(true)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetValueStep(1)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetValue(1)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetMinMaxValues(1,3)
    self.GuildFrame.GuildBankFrame.BankSlotsScrollBar:SetScript('OnValueChanged', function(self)
        Guildbook.GuildFrame.GuildBankFrame:RefreshSlots()
    end)

    self.GuildFrame.GuildBankFrame.BankData = {}
    function self.GuildFrame.GuildBankFrame:ProcessBankData(data)
        wipe(self.BankData)
        local c = 0
        for id, count in pairs(data) do
            local itemClass = select(6, GetItemInfoInstant(id))
            table.insert(Guildbook.GuildFrame.GuildBankFrame.BankData, {
                ItemID = id,
                Count = count,
                Class = itemClass,
            })
            c = c + 1
        end
        -- sort table by item class  https://wow.gamepedia.com/ItemType
        table.sort(Guildbook.GuildFrame.GuildBankFrame.BankData, function(a, b)
            return a.Class < b.Class
        end)
        DEBUG('GuildBankFrame:ProcessBankData', string.format('processed %s bank items from data', c))
        self.BankSlotsScrollBar:SetValue(1)
    end

    -- function self.GuildFrame.GuildBankFrame:RefreshSlots()
    --     if bankCharacter and GUILDBOOK_CHARACTER['GuildBank'] and GUILDBOOK_CHARACTER['GuildBank'][bankCharacter] then
    --         local slot, c = 1, 1
    --         for id, count in pairs(GUILDBOOK_CHARACTER['GuildBank'][bankCharacter].Data) do
    --             self.BankSlots[slot].icon:SetTexture(C_Item.GetItemIconByID(id))
    --             self.BankSlots[slot].count:SetText(count)
    --             self.BankSlots[slot].itemID = id

    --             -- NOTE: leaving this here in case its required in future updates etc
    --             -- local item = Item:CreateFromItemID(id)
    --             -- item:ContinueOnItemLoad(function()
    --             --     self.BankSlots[slot].icon:SetTexture(item:GetItemIcon())
    --             --     self.BankSlots[slot].data = { ItemID = id, Count = count }
    --             -- end)
    --             slot = slot + 1
    --         end
    --     end
    -- end

    function self.GuildFrame.GuildBankFrame:RefreshSlots()
        if self.bankCharacter and GUILDBOOK_CHARACTER['GuildBank'] and GUILDBOOK_CHARACTER['GuildBank'][self.bankCharacter] then
            local scrollPos = math.floor(self.BankSlotsScrollBar:GetValue())
            for i = 1, 98 do                
                if Guildbook.GuildFrame.GuildBankFrame.BankData[i + ((scrollPos - 1) * 98)] then
                    local item = Guildbook.GuildFrame.GuildBankFrame.BankData[i + ((scrollPos - 1) * 98)]
                    self.BankSlots[i].icon:SetTexture(C_Item.GetItemIconByID(item.ItemID))
                    self.BankSlots[i].count:SetText(item.Count)
                    self.BankSlots[i].itemID = item.ItemID
                    --DEBUG('GuildBankFrame:RefreshSlots', string.format('updating slot %s with item id %s', i, item.ItemID))
                else
                    self.BankSlots[i].icon:SetTexture(nil)
                    self.BankSlots[i].count:SetText(' ')
                    self.BankSlots[i].itemID = nil
                end

            end
        end
    end

end