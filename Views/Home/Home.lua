

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
}

function GuildbookHomeMixin:OnLoad()

    self.gmotd:GetFontString():SetFontObject("GameFontWhite")
    self.gmotd:GetFontString():SetJustifyH("CENTER")
    self.gmotd:GetFontString():SetJustifyV("MIDDLE")

    NineSliceUtil.ApplyLayout(self.agenda, agendaNineSliceLayout)
    NineSliceUtil.ApplyLayout(self.gmotd, gmotdNineSliceLayout)

    addon:RegisterCallback("Blizzard_OnInitialGuildRosterScan", self.LoadData, self)
    addon:RegisterCallback("Database_OnDailyQuestCompleted", self.LoadData, self)
    addon:RegisterCallback("Character_OnDataChanged", self.LoadData, self)
    addon:RegisterCallback("Database_OnCalendarDataChanged", self.LoadData, self)

    addon.AddView(self)
end

function GuildbookHomeMixin:OnShow()
    self:LoadData()

    self.agenda:ClearAllPoints()
    self.agenda:SetPoint("TOPLEFT", self.gmotd, "BOTTOMLEFT", -20, -40)
    self.agenda:SetPoint("BOTTOMLEFT", 20, 20)
end

function GuildbookHomeMixin:LoadData()

    if not self:IsVisible() then
        return;
    end

    self.agenda.listview.DataProvider:Flush()

    local agenda = {}
    
    self.gmotd:SetText(GetGuildRosterMOTD())

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

    local today = date("*t", time())
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
--GarrLanding-MinimapAlertBG

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
            })
        end
    end

end