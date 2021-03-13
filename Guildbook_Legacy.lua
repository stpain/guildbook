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



























-- will likely re-purpose the guild bank ui into a simple alt bank system maybe?



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- guild bank frame
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Guildbook:SetupGuildBankFrame()

    local helpText = [[
Guild Bank

|cffffffff To use the Guild Bank, add the word 'Guildbank' to 
the character being used as the bank. Multiple bank characters
are supported.
|r

|cff00BFF3 |r
    ]]

    self.GuildFrame.GuildBankFrame.helpIcon = Guildbook:CreateHelperIcon(self.GuildFrame.GuildBankFrame, 'BOTTOMRIGHT', Guildbook.GuildFrame.GuildBankFrame, 'TOPRIGHT', -2, 2, 'Bank')

    self.GuildFrame.GuildBankFrame.bankCharacter = nil

    self.GuildFrame.GuildBankFrame:SetScript('OnShow', function(self)
        self:BankCharacterSelectDropDown_Init()
    end)

    -- self.GuildFrame.GuildBankFrame.Header = self.GuildFrame.GuildBankFrame:CreateFontString('GuildbookGuildInfoFrameGuildBankFrameHeader', 'OVERLAY', 'GameFontNormal')
    -- self.GuildFrame.GuildBankFrame.Header:SetPoint('BOTTOM', Guildbook.GuildFrame.GuildBankFrame, 'TOP', 0, 4)
    -- self.GuildFrame.GuildBankFrame.Header:SetText('Guild Bank')
    -- self.GuildFrame.GuildBankFrame.Header:SetTextColor(1,1,1,1)
    -- self.GuildFrame.GuildBankFrame.Header:SetFont("Fonts\\FRIZQT__.TTF", 12)

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
                local name, _, _, _, _, _, publicNote, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
                if publicNote:lower():find('guildbank') then
                    --table.insert(gbc, name:match("^(.-)%-"))
                    name = Ambiguate(name, 'none')
                    table.insert(gbc, name)
                end
            end
            local info = UIDropDownMenu_CreateInfo()
            for k, p in pairs(gbc) do
                info.text = p
                info.hasArrow = false
                info.keepShownOnClick = false
                info.func = function()
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
                            DEBUG('func', 'GuildBankFrame:BankCharacterSelectDropDown_Init', string.format('using %s as has newest commit, sending request for guild bank data - delayed', Guildbook.GuildBankCommit['BankCharacter']))
                            local ts = date('*t', Guildbook.GuildBankCommit.Commit)
                            ts.min = string.format('%02d', ts.min)
                            Guildbook.GuildFrame.GuildBankFrame.CommitInfo:SetText(string.format('Commit: %s:%s:%s  %s-%s-%s', ts.hour, ts.min, ts.sec, ts.day, ts.month, ts.year))
                            Guildbook.GuildFrame.GuildBankFrame.CommitSource:SetText(string.format('Commit Source: %s', Guildbook.GuildBankCommit.Character))
                            Guildbook.GuildFrame.GuildBankFrame.CommitBankCharacter:SetText(string.format('Bank Character: %s', Guildbook.GuildBankCommit.BankCharacter))
                        end
                    end)
                    DEBUG('func', 'GuildBankFrame:BankCharacterSelectDropDown_Init', 'requesting guild bank data from: '..p)
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
        DEBUG('func', 'GuildBankFrame:ProcessBankData', string.format('processed %s bank items from data', c))
        self.BankSlotsScrollBar:SetValue(1)
    end

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