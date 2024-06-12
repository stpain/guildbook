

local name, addon = ...;

local Database = addon.Database;

local agendaNineSliceLayout =
{
    TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", },
    TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", },
    BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", },
    BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", },
    TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
    BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
    LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
    RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
    Center = { layer = "BACKGROUND", atlas = "ClassHall_InfoBoxMission-BackgroundTile", x = -20, y = 20, x1 = 20, y1 = -20 },
}
local gmotdNineSliceLayout =
{
    TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", x = -20, y = 20 },
    TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", x = 20, y = 20 },
    BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", x = -20, y = -20 },
    BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", x = 20, y = -20 },
    TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
    BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
    LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
    RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
    Center = { layer = "BACKGROUND", atlas = "Tooltip-Glues-NineSlice-Center", x = -20, y = 20, x1 = 20, y1 = -20 },
}

GuildbookHomeMixin = {
    name = "Home",
    censusShowOffline = false,
    censusShowMaxLevelOnly = false,
}

function GuildbookHomeMixin:OnLoad()

    self.gmotd:GetFontString():SetFontObject("GameFontWhite")
    self.gmotd:GetFontString():SetJustifyH("CENTER")
    self.gmotd:GetFontString():SetJustifyV("MIDDLE")

    self.census.bars = {}

    self.census.toggleOffline:SetChecked(self.censusShowOffline)
    self.census.toggleOffline.label:SetText("Include offline.")
    self.census.toggleOffline:SetScript("OnClick", function(cb)
        self.censusShowOffline = not self.censusShowOffline;
        cb:SetChecked(self.censusShowOffline)
        self:UpdateCensus()
    end)

    self.census.maxLevel:SetChecked(self.censusShowOffline)
    self.census.maxLevel.label:SetText("Max level only.")
    self.census.maxLevel:SetScript("OnClick", function(cb)
        self.censusShowMaxLevelOnly = not self.censusShowMaxLevelOnly;
        cb:SetChecked(self.censusShowMaxLevelOnly)
        self:UpdateCensus()
    end)

    NineSliceUtil.ApplyLayout(self.challenges, agendaNineSliceLayout)
    NineSliceUtil.ApplyLayout(self.agenda, agendaNineSliceLayout)
    NineSliceUtil.ApplyLayout(self.census, agendaNineSliceLayout)
    NineSliceUtil.ApplyLayout(self.gmotd, gmotdNineSliceLayout)

    addon:RegisterCallback("Blizzard_OnInitialGuildRosterScan", self.LoadData, self)
    addon:RegisterCallback("Database_OnDailyQuestCompleted", self.LoadData, self)
    addon:RegisterCallback("Character_OnDataChanged", self.LoadData, self)
    addon:RegisterCallback("Database_OnCalendarDataChanged", self.LoadData, self)
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
    addon:RegisterCallback("Blizzard_OnGuildRosterUpdate", self.UpdateCensus, self)
    addon:RegisterCallback("Character_OnNewsEvent", self.Character_OnNewsEvent, self)

    addon.AddView(self)
end

function GuildbookHomeMixin:OnShow()
    self:LoadData()

    self.agenda:ClearAllPoints()
    self.agenda:SetPoint("TOPLEFT", self.gmotd, "BOTTOMLEFT", -20, -40)
    self.agenda:SetPoint("BOTTOMLEFT", 20, 20)

    self:UpdateLayout()
end

function GuildbookHomeMixin:UpdateLayout()

    local x, y = self:GetSize()

    --self.census:SetHeight(y - 130)
    local maxCensusWidth = 380
    local newCensusWidth = (x - 360)
    self.census:SetWidth((newCensusWidth > maxCensusWidth) and maxCensusWidth or newCensusWidth) --agenda + 3x20 for padding

    self:UpdateCensus()
end

function GuildbookHomeMixin:UpdateCensus()
    if addon.characters and addon.thisGuild then
        local classes = {
            [1] = 0,
            [2] = 0,
            [3] = 0,
            [4] = 0,
            [5] = 0,
            [6] = 0,
            [7] = 0,
            [8] = 0,
            [9] = 0,
            --[10] = 0,
            [11] = 0,
            --[12] = 0,
        }
        local classMeta = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {},
            [7] = {},
            [8] = {},
            [9] = {},
            --[10] = {},
            [11] = {},
            --[12] = {},
        }
        local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
--        self.census.info:SetText(string.format("%d total (%d online)", numTotalGuildMembers, numOnlineGuildMembers))
        local numFiltered = 0
        for nameRealm, info in pairs(addon.characters) do
            if addon.guilds[addon.thisGuild] and addon.guilds[addon.thisGuild].members[nameRealm] then
                local useCharacter = true
                if self.censusShowMaxLevelOnly then
                    if (info.data.level == 85) then
                        useCharacter = true
                    else
                        useCharacter = false
                    end
                end
                if useCharacter then
                    if self.censusShowOffline then
                        if not classes[info.data.class] then
                            classes[info.data.class] = 1
                            table.insert(classMeta[info.data.class], info.data.name)
                        else
                            classes[info.data.class] = classes[info.data.class] + 1
                            table.insert(classMeta[info.data.class], info.data.name)
                        end
                        numFiltered = numFiltered + 1
                    else
                        if info.data.onlineStatus.isOnline then
                            if not classes[info.data.class] then
                                classes[info.data.class] = 1
                                table.insert(classMeta[info.data.class], info.data.name)
                            else
                                classes[info.data.class] = classes[info.data.class] + 1
                                table.insert(classMeta[info.data.class], info.data.name)
                            end
                            numFiltered = numFiltered + 1
                        end
                    end
                end
            end
        end

        local classesSort = {}
        local maxCount = 0;
        for classID, count in pairs(classes) do
            if count > maxCount then
                maxCount = count;
            end
            table.insert(classesSort, {
                classID = classID,
                count = count,
            })
        end
        table.sort(classesSort, function(a, b)
            --return a.classID < b.classID
            return a.count > b.count
        end)

        local censusWidth, censusHeight = self.census:GetWidth(), self.census:GetHeight()
        --local barHeight = (censusHeight - 22) / #classesSort;

        local barWidth = (censusWidth - 22) / #classesSort;

        if type(self.census.bars) == "table" then
            for k, bar in ipairs(self.census.bars) do
                bar:Hide()
            end
        end

        for k, class in ipairs(classesSort) do
            local _, engClass = GetClassInfo(class.classID)
            if engClass then
                if not self.census.bars[k] then
                    local bar = CreateFrame("StatusBar", nil, self.census)
                    bar:SetOrientation("VERTICAL")
                    bar:SetStatusBarTexture(137012)
                    bar:SetFrameLevel(8000)

                    bar.icon = bar:CreateTexture(nil, "ARTWORK")
                    bar.icon:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
                    bar.icon:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
                    bar.icon:SetAtlas(string.format("classicon-%s", engClass):lower())
                    bar.icon:SetAlpha(0.9)

                    bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontWhite")
                    bar.label:SetPoint("BOTTOM", 0, 4)

                    self.census.bars[k] = bar;

                end
                local r, g, b = RAID_CLASS_COLORS[engClass]:GetRGB()
                self.census.bars[k]:SetStatusBarColor(r, g, b, 0.9)
                self.census.bars[k]:SetMinMaxValues(0, maxCount)
                self.census.bars[k]:SetValue(class.count)
                --self.census.bars[k]:SetSize((censusWidth - 22) - barHeight, barHeight - 1)
                self.census.bars[k]:SetSize(barWidth - 1, censusHeight - barWidth - 69)
                --self.census.bars[k]:SetPoint("BOTTOMLEFT", self.census, "BOTTOMLEFT", 11 + barHeight, ((k-1) * barHeight) + 11)
                self.census.bars[k]:SetPoint("BOTTOMLEFT", self.census, "BOTTOMLEFT", ((k-1) * barWidth) + 11, 58 + barWidth)
                --self.census.bars[k].icon:SetWidth(barHeight)
                self.census.bars[k].icon:SetHeight(barWidth)
                self.census.bars[k].icon:SetAtlas(string.format("classicon-%s", engClass):lower())
                self.census.bars[k].label:SetText(class.count)

                self.census.bars[k]:SetScript("OnMouseDown", function()
                    addon:TriggerEvent("Roster_OnSelectionChanged", class.classID)
                    GuildbookUI:SelectView("GuildRoster")
                end)

                self.census.bars[k]:SetScript("OnLeave", function(sb)
                    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                end)
                self.census.bars[k]:SetScript("OnEnter", function(sb)
                    GameTooltip:SetOwner(sb, "ANCHOR_TOPRIGHT")
                    GameTooltip:AddLine("Players")
                    for k, v in ipairs(classMeta[class.classID]) do
                        GameTooltip:AddLine(Ambiguate(v, "short"), 1,1,1)
                    end
                    GameTooltip:Show()
                end)
                self.census.bars[k]:Show()
            end

        end

        self.census.info:SetText(string.format("%d total (%d selected)", numTotalGuildMembers, numFiltered))
    end
end

function GuildbookHomeMixin:LoadData()

    if not self:IsVisible() then
        return;
    end

    self.gmotd:SetText(GetGuildRosterMOTD())

    self:UpdateCensus()

    self:LoadAgenda()

    self:LoadChallenges()

end

function GuildbookHomeMixin:LoadAgenda()

    self.agenda.listview.DataProvider:Flush()

    local agenda = {}

    if addon.characters and addon.characters[addon.thisCharacter] then

        local character = addon.characters[addon.thisCharacter]

        local _, class = GetClassInfo(character.data.class)

        self.background:SetAtlas(string.format("legionmission-complete-background-%s", class:lower()))

        --dailies data isn't on the character objects
        local favouriteDailies = Database:GetDailyQuestInfoForCharacter(addon.thisCharacter, true)

        if favouriteDailies then
            local dailiesCompleted = 0;
            for k, v in ipairs(favouriteDailies) do
                local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(v.questID)
                if questCompleted then
                    dailiesCompleted = dailiesCompleted + 1;
                end
            end
            self.agenda.listview.DataProvider:Insert({
                label = string.format("%s%s Dailies completed: %d/%d", CreateAtlasMarkup("QuestRepeatableTurnin", 20, 20), CreateAtlasMarkup("auctionhouse-icon-favorite", 20, 20), dailiesCompleted, #favouriteDailies),
                onMouseDown = function()
                    GuildbookUI:SelectView("Dailies")
                end,
            })
        end

    end

    --local today = date("*t", time())
    local events = Database:GetCalendarEventsForPeriod(time(), 7)

     for k, event in ipairs(events) do
        if event.timestamp < (time() + 3600) then
            table.insert(agenda, {
                timestamp = event.timestamp,
                displayText = string.format("%s|cff98DD1F%s\n|cffffffff%s", CreateAtlasMarkup("auctionhouse-icon-clock", 12, 12), date("%Y-%m-%d %H:%M:%S", event.timestamp), event.text),
                --fontObject = GameFontNormalSmall,
                onMouseDown = function()
                    GuildbookUI:SelectView("Calendar")
                end,
            })
        else
            table.insert(agenda, {
                timestamp = event.timestamp,
                displayText = string.format("|cffFFC000%s\n|cffffffff%s", date("%Y-%m-%d %H:%M:%S", event.timestamp), event.text),
                --fontObject = GameFontNormalSmall,
                onMouseDown = function()
                    GuildbookUI:SelectView("Calendar")
                end,
            })
        end
     end

    if addon.characters then

        --tradeskill cooldowns
        for nameRealm, character in pairs(addon.characters) do
            local cooldowns = character:GetTradeskillCooldowns()
            for name, info in pairs(cooldowns) do
                if info.finishes < (time() + 3600) then
                    table.insert(agenda, {
                        timestamp = info.finishes,
                        displayText = string.format("%s|cff98DD1F%s\n|cffffffff%s\n%s", CreateAtlasMarkup("auctionhouse-icon-clock", 12, 12), date("%Y-%m-%d %H:%M:%S", info.finishes), info.name, character:GetName(true)),
                        --fontObject = GameFontNormalSmall,
                        onUpdate = function(f)
                            local remaining = SecondsToClock(info.finishes - time())
                            --print(remaining)
                            local displayText = string.format("%s|cff98DD1F%s |cffffffff- %s\n%s\n%s", CreateAtlasMarkup("auctionhouse-icon-clock", 12, 12), date("%Y-%m-%d %H:%M:%S", info.finishes), remaining, info.name, character:GetName(true))
                            --print(displayText)
                            f.label:SetText(displayText)
                        end,
                    })
                else
                    table.insert(agenda, {
                        timestamp = info.finishes,
                        displayText = string.format("|cffFFC000%s\n|cffffffff%s\n%s", date("%Y-%m-%d %H:%M:%S", info.finishes), info.name, character:GetName(true)),
                        --fontObject = GameFontNormalSmall,
                    })
                end

            end
        end

        --instance lockouts
        for nameRealm, character in pairs(addon.characters) do
            local lockouts = character:GetLockouts()
            for k, lockout in ipairs(lockouts) do
                if lockout.reset < (time() + 3600) then
                    table.insert(agenda, {
                        timestamp = lockout.reset,
                        displayText = string.format("%s|cff98DD1F%s\n|cffffffff%s %s\n%s", CreateAtlasMarkup("auctionhouse-icon-clock", 12, 12), date("%Y-%m-%d %H:%M:%S", lockout.reset), lockout.name, lockout.difficultyName, character:GetName(true)),
                        --fontObject = GameFontNormalSmall,
                        onMouseDown = function()
                            GuildbookUI:SelectView("Calendar")
                        end,
                    })
                else
                    table.insert(agenda, {
                        timestamp = lockout.reset,
                        displayText = string.format("|cffFFC000%s\n|cffffffff%s %s\n%s", date("%Y-%m-%d %H:%M:%S", lockout.reset), lockout.name, lockout.difficultyName, character:GetName(true)),
                        --fontObject = GameFontNormalSmall,
                        onMouseDown = function()
                            GuildbookUI:SelectView("Calendar")
                        end,
                    })
                end
            end
        end


    end

    table.sort(agenda, function(a, b)
        return a.timestamp < b.timestamp
    end)

    for k, item in ipairs(agenda) do
        if item.timestamp > time() then
            self.agenda.listview.DataProvider:Insert({
                label = item.displayText,
                fontObject = item.fontObject or GameFontWhite,
                onMouseDown = item.onMouseDown,
                backgroundRGB ={r = 0.25, g = 0.25, b = 0.25}, --"transmog-set-iconrow-background", --Options_List_Hover
                backgroundAlpha = 0.15,
                onUpdate = item.onUpdate,
            })
        end
    end
end

function GuildbookHomeMixin:Character_OnNewsEvent(news)
    --DevTools_Dump(news)
    --Database:InsertNewsEevnt(news)
end

function GuildbookHomeMixin:LoadChallenges()
    
    RequestGuildChallengeInfo()

    local dp = CreateDataProvider()

    for i = 1, GetNumGuildChallenges() do
        
        local index, numComplete, totalComplete, x, gold = GetGuildChallengeInfo(i)
        local text = _G["GUILD_CHALLENGE_TYPE"..i]

        dp:Insert({
            label = text,
            labelRight = string.format("%d / %d  ", numComplete, totalComplete)
        })
    end

    self.challenges.listview.scrollView:SetDataProvider(dp)
end