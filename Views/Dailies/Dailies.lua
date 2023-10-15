local name, addon = ...;

local Database = addon.Database;

GuildbookWrathDailiesMixin = {
    name = "Dailies",
    selectedCharacter = "",
};

function GuildbookWrathDailiesMixin:OnLoad()

    addon:RegisterCallback("Blizzard_OnInitialGuildRosterScan", self.Blizzard_OnInitialGuildRosterScan, self)
    addon:RegisterCallback("Quest_OnTurnIn", self.Quest_OnTurnIn, self)
    addon:RegisterCallback("Quest_OnAccepted", self.Quest_OnAccepted, self)

    addon.AddView(self)

end

function GuildbookWrathDailiesMixin:UpdateLayout()
    local x, y = self:GetSize()

    self.charactersListview:SetWidth(x * 0.25)
end

function GuildbookWrathDailiesMixin:Database_OnInitialised()

    if not Database.db.dailies.characters[addon.thisCharacter] then
        Database.db.dailies.characters[addon.thisCharacter] = {}
    end

    self.selectedCharacter = addon.thisCharacter;

    self:LoadQuests()
    self:LoadCharacters()

end

function GuildbookWrathDailiesMixin:Quest_OnTurnIn(questID, xpReward, moneyReward)

    local now = time()
    local resetTime = now + C_DateAndTime.GetSecondsUntilDailyReset()

    local info  = {
        turnedIn = now,
        resets = resetTime,
        gold = moneyReward,
        xp = xpReward,
    }

    Database.db.dailies.characters[addon.thisCharacter][questID] = info

    addon:TriggerEvent("Database_OnDailyQuestCompleted", questID)

end

function GuildbookWrathDailiesMixin:Quest_OnAccepted(_questLogIndex, _questId)

    ExpandQuestHeader(0)

    local header;
    for i = 1, GetNumQuestLogEntries() do

        local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questId = GetQuestLogTitle(i)

        if title:find("Die!") then
            print(frequency)
        end

        if isHeader then
            header = title;
        end
        if frequency == 2 or frequency == 3 then
            --local questDescription, questObjectives = GetQuestLogQuestText(i)
            local questLink = GetQuestLink(questId)
            local questData = {
                link = questLink,
                title = title,
                header = header,
                questId = questId,
                -- description = questDescription,
                -- objectives = questObjectives,
                level = level,
                frequency = frequency,
            }

            Database.db.dailies.quests[questId] = questData
        end
    end

    CollapseQuestHeader(0)

    self:LoadQuests()
end

function GuildbookWrathDailiesMixin:Blizzard_OnInitialGuildRosterScan()

    local t = {}

    for name, isMain in pairs(Database.db.myCharacters) do

        if addon.characters[name] then

            table.insert(t, { name = name, level = addon.characters[name].data.level})
            table.sort(t, function(a, b)
                if a.level == b.level then
                    return a.name < b.name
                else
                    return a.level > b.level;
                end
            end)

        end

    end

    for k, v in ipairs(t) do
        
        self.charactersListview.DataProvider:Insert({
            label = Ambiguate(addon.characters[v.name]:GetName(true), "short"),
            atlas = addon.characters[v.name]:GetProfileAvatar(),
            showMask = true,
            backgroundAlpha = 0.15,
            onMouseDown = function(listviewItem)
                self.selectedCharacter = v.name;

                self.charactersListview.scrollView:ForEachFrame(function(f, d)
                    f.background:SetColorTexture(0,0,0)
                end)

                listviewItem.background:SetColorTexture(0.6, 0.6, 0.6)

                self:LoadQuests()
            end,
        })
    end
end



function GuildbookWrathDailiesMixin:LoadQuests()
    local t = {}

    for questId, info in pairs(Database.db.dailies.quests) do
        if Database.db.dailies.characters[self.selectedCharacter] and Database.db.dailies.characters[self.selectedCharacter][questId] then
            table.insert(t, {
                info = info,
                turnIn = Database.db.dailies.characters[self.selectedCharacter][questId],
            })
        else
            table.insert(t, {
                info = info,
                turnIn = false,
            })
        end
    end
    table.sort(t, function(a, b)
        return a.info.header < b.info.header;
    end)

    self.questsListview.DataProvider:Flush()

    local headers = {}
    for k, quest in ipairs(t) do
        if not headers[quest.info.header] then
            self.questsListview.DataProvider:Insert({
                isHeader = true,
                header = quest.info.header,
            })
            headers[quest.info.header] = true
        end
        self.questsListview.DataProvider:Insert(quest)
    end

end


function GuildbookWrathDailiesMixin:CheckQuestsCompleted()
    for questId, info in pairs(self.db.quests) do
        local isComplete = C_QuestLog.IsQuestFlaggedCompleted(questId)
    end
end






--[[
    template stuff
]]
GuildbookWrathDailiesListviewItemMixin = {}
function GuildbookWrathDailiesListviewItemMixin:OnLoad()
    self.completed:EnableMouse(false)
    self.completed.label:SetWidth(340)
    addon:RegisterCallback("Database_OnDailyQuestCompleted", self.Database_OnDailyQuestCompleted, self)
end

function GuildbookWrathDailiesListviewItemMixin:SetDataBinding(binding, height)

    self.completed.label:SetText("")
    self.info:Hide()
    self.completed:SetChecked(false)

    self:SetHeight(height)

    self.daily = binding;

    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    --if this is a header line just set text
    if binding.isHeader then
        self:EnableMouse(false)
        self.completed:Hide()
        self.header:Show()
        self.header:SetText(binding.header)
        self.background:Show()

    --if this is a quest do fancy stuff
    else
        self:EnableMouse(true)
        self.completed:Show()
        self.completed.label:SetText(string.format("[%s]", binding.info.title))
        self.header:Hide()
        self.background:Hide()

        if type(binding.turnIn) == "table" then
            if time() < binding.turnIn.resets then
                self.info:SetText(string.format("[%s] %s %s XP", date('%Y-%m-%d %H:%M:%S', binding.turnIn.turnedIn), GetCoinTextureString(binding.turnIn.gold), (binding.turnIn.xp or 0)))
                self.info:Show()
                self.completed:SetChecked(true)
            end
        end
    end

end

function GuildbookWrathDailiesListviewItemMixin:Database_OnDailyQuestCompleted(questId)

    local turnIn = Database.db.dailies.characters[self.selectedCharacter][questId]

    if self.daily and self.daily.info and (self.daily.info.questId == questId) and (time() < turnIn.resets) then
        self.completed:SetChecked(true)
        self.info:SetText(string.format("[%s] %s %s XP", date('%Y-%m-%d %H:%M:%S', turnIn.turnedIn), GetCoinTextureString(turnIn.gold), (turnIn.xp or 0)))
        self.info:Show()
    end
end

function GuildbookWrathDailiesListviewItemMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetHyperlink(self.daily.info.link)
    GameTooltip:Show()
end

function GuildbookWrathDailiesListviewItemMixin:ResetDataBinding()
    self.info:SetText("-")
end