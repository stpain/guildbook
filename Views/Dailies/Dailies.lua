local name, addon = ...;

local Database = addon.Database;
local Character = addon.Character;

local selectedCharacter = "";
local currentQuestLog = {}

GuildbookWrathDailiesMixin = {
    name = "Dailies",
    selectedCharacter = "",
    filterFavoriteQuests = false,
};

function GuildbookWrathDailiesMixin:OnLoad()

    addon:RegisterCallback("Blizzard_OnInitialGuildRosterScan", self.Blizzard_OnInitialGuildRosterScan, self) --changed some logic and now testing reacting to db init
    addon:RegisterCallback("Quest_OnTurnIn", self.Quest_OnTurnIn, self)
    addon:RegisterCallback("Quest_OnAccepted", self.Quest_OnAccepted, self)
    addon:RegisterCallback("Database_OnDailyQuestCompleted", self.UpdateHeaderInfo, self)

    self.filterFavorites:SetScript("OnClick", function()
        self.filterFavoriteQuests = not self.filterFavoriteQuests

        local atlas = self.filterFavoriteQuests == true and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off";

        self.filterFavorites:SetNormalAtlas(atlas)

        self:LoadQuests()

    end)

    addon.AddView(self)

end

function GuildbookWrathDailiesMixin:UpdateHeaderInfo()

    local quests, copper, xp = 0, 0, 0;

    if Database.db.dailies.characters[selectedCharacter] then

        for questID, info in pairs(Database.db.dailies.characters[selectedCharacter]) do

            if (time() < info.resets) then
                copper = copper + info.gold;
                xp = xp + info.xp;

                quests = quests + 1;
            end
        end

    end

    self.info:SetText(string.format("[%s] %s quests %s %s XP", selectedCharacter, quests, GetCoinTextureString(copper), xp))
end


function GuildbookWrathDailiesMixin:UpdateLayout()
    local x, y = self:GetSize()

    self.charactersListview:SetWidth(x * 0.18)
end


function GuildbookWrathDailiesMixin:Quest_OnTurnIn(questID, xpReward, moneyReward)

    if Database.db.dailies.quests[questID] then

        local now = time()
        local resetTime = now + C_DateAndTime.GetSecondsUntilDailyReset()
        local isFavorite = Database.db.dailies.characters[addon.thisCharacter][questID].isFavorite
        local info  = {
            turnedIn = now,
            resets = resetTime,
            gold = moneyReward,
            xp = xpReward,
            isFavorite = isFavorite,
        }

        Database.db.dailies.characters[addon.thisCharacter][questID] = info

        addon:TriggerEvent("Database_OnDailyQuestCompleted", questID)

    end
    self:ScanQuestLog()
end

function GuildbookWrathDailiesMixin:ScanQuestLog()

    currentQuestLog = {}

    ExpandQuestHeader(0)

    local header;
    for i = 1, GetNumQuestLogEntries() do

        local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questId = GetQuestLogTitle(i)

        if not isHeader then
            currentQuestLog[questId] = true;
        end

        -- if title:find("Die!") then
        --     print(frequency)
        -- end

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
end

function GuildbookWrathDailiesMixin:Quest_OnAccepted()
    self:ScanQuestLog()
    self:LoadQuests()
end

function GuildbookWrathDailiesMixin:Blizzard_OnInitialGuildRosterScan()
    self:LoadCharacters()
end

function GuildbookWrathDailiesMixin:LoadCharacters()

    if not Database.db.dailies.characters[addon.thisCharacter] then
        Database.db.dailies.characters[addon.thisCharacter] = {}
    end

    selectedCharacter = addon.thisCharacter;

    -- scan the log and load quests
    self:Quest_OnAccepted()

    local t = {}

    for name, isMain in pairs(Database.db.myCharacters) do

        if addon.characters[name] then
            table.insert(t, addon.characters[name])
        else
            local altData = Database:GetCharacter(name)
            if altData then
                local alt = Character:CreateFromData(altData)
                table.insert(t, alt)
            end

        end

    end

    table.sort(t, function(a, b)
        if a.data.level == b.data.level then
            return a.data.name < b.data.name
        else
            return a.data.level > b.data.level;
        end
    end)

    for k, character in ipairs(t) do
        
        self.charactersListview.DataProvider:Insert({
            label = Ambiguate(character:GetName(true), "short"),
            atlas = character:GetProfileAvatar(),
            showMask = true,
            backgroundAlpha = 0.15,
            onMouseDown = function(listviewItem)
                selectedCharacter = character.data.name;
                self:ScanQuestLog()
                self:LoadQuests()
            end,
        })
    end
end



function GuildbookWrathDailiesMixin:LoadQuests()
    local t = {}

    for questId, info in pairs(Database.db.dailies.quests) do
        if not Database.db.dailies.characters[selectedCharacter] then
            Database.db.dailies.characters[selectedCharacter] = {}
        end
        if not Database.db.dailies.characters[selectedCharacter][questId] then
            Database.db.dailies.characters[selectedCharacter][questId] = {
                isFavorite = false,
                gold = 0,
                resets = 0,
                xp = 0,
                turnedIn = 0,
            }
        end
        if self.filterFavoriteQuests then
            if Database.db.dailies.characters[selectedCharacter][questId].isFavorite then
                table.insert(t, {
                    quest = info,
                    characterQuestInfo = Database.db.dailies.characters[selectedCharacter][questId],
                })
            end
        else
            table.insert(t, {
                quest = info,
                characterQuestInfo = Database.db.dailies.characters[selectedCharacter][questId],
            })
        end
    end
    table.sort(t, function(a, b)
        return a.quest.header < b.quest.header;
    end)

    self.questsListview.DataProvider:Flush()

    local headers = {}
    for k, v in ipairs(t) do
        if not headers[v.quest.header] then
            self.questsListview.DataProvider:Insert({
                isHeader = true,
                header = v.quest.header,
            })
            headers[v.quest.header] = true
        end
        self.questsListview.DataProvider:Insert(v)
    end

    self:UpdateHeaderInfo()
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

    self.daily = binding;

    self.completed.label:SetText("")
    self.info:Hide()
    self.completed:SetChecked(false)

    self:SetHeight(height)

    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    --if this is a header line just set text
    if self.daily.isHeader then
        self:EnableMouse(false)
        self.completed:Hide()
        self.header:Show()
        self.header:SetText(self.daily.header)
        self.background:Show()
        self.favorite:Hide()

    --if this is a quest do fancy stuff
    else

        if type(self.daily.characterQuestInfo) == "table" then
            local atlas = self.daily.characterQuestInfo.isFavorite == true and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off";
            self.favorite:SetNormalAtlas(atlas)
        
            self.favorite:SetScript("OnClick", function()
                self.daily.characterQuestInfo.isFavorite = not self.daily.characterQuestInfo.isFavorite;
                local atlas = self.daily.characterQuestInfo.isFavorite == true and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off";
                self.favorite:SetNormalAtlas(atlas)

                --addon:TriggerCallback("Quest_OnDailyFavouriteChanged")
            end)
        end

        local hex = (currentQuestLog[self.daily.quest.questId] == true and addon.thisCharacter == selectedCharacter) and "|cff6bb324" or "|cffffffff";
        self.favorite:Show()
        self:EnableMouse(true)
        self.completed:Show()
        self.header:Hide()
        self.background:Hide()
        self.completed.label:SetText(string.format("%s[%s]", hex, self.daily.quest.title))
        if type(self.daily.characterQuestInfo) == "table" then
            if self.daily.characterQuestInfo.turnedIn == 0 then
                self.info:SetText("-")
                self.info:Show()
            else
                if time() < self.daily.characterQuestInfo.resets then
                    self.info:SetText(string.format("[%s] %s %s XP", date('%Y-%m-%d %H:%M:%S', self.daily.characterQuestInfo.turnedIn), GetCoinTextureString(self.daily.characterQuestInfo.gold), (self.daily.characterQuestInfo.xp or 0)))
                    self.info:Show()
                    self.completed:SetChecked(true)
                else
                    self.info:SetText(string.format("|cff7F7F7F[%s] %s %s XP", date('%Y-%m-%d %H:%M:%S', self.daily.characterQuestInfo.turnedIn), GetCoinTextureString(self.daily.characterQuestInfo.gold), (self.daily.characterQuestInfo.xp or 0)))
                    self.info:Show()
                end
            end
        end
    end

end

function GuildbookWrathDailiesListviewItemMixin:Database_OnDailyQuestCompleted(questId)

    if Database.db.dailies.characters[selectedCharacter] and Database.db.dailies.characters[selectedCharacter][questId] then

        local characterQuestInfo = Database.db.dailies.characters[selectedCharacter][questId]

        if self.daily and self.daily.quest and (self.daily.quest.questId == questId) and (time() < characterQuestInfo.resets) then
            self.completed:SetChecked(true)
            self.info:SetText(string.format("[%s] %s %s XP", date('%Y-%m-%d %H:%M:%S', characterQuestInfo.turnedIn), GetCoinTextureString(characterQuestInfo.gold), (characterQuestInfo.xp or 0)))
            self.info:Show()
        end

    end
end

function GuildbookWrathDailiesListviewItemMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetHyperlink(self.daily.quest.link)
    GameTooltip:Show()
end

function GuildbookWrathDailiesListviewItemMixin:ResetDataBinding()
    self.info:SetText("-")
    self.daily = nil;
    self.favorite:SetScript("OnClick", nil)
    self.favorite:SetNormalAtlas("auctionhouse-icon-favorite-off")
end