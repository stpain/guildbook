local name, addon = ...;

local Database = addon.Database;

GuildbookChatMixin = {
    name = "Chat",
    currentChat = "guild",
}

function GuildbookChatMixin:OnLoad()

    addon:RegisterCallback("Database_OnInitialised", self.Database_OnInitialised, self)
    addon:RegisterCallback("Chat_OnMessageReceived", self.Chat_OnMessageReceived, self)
    addon:RegisterCallback("Chat_OnMessageSent", self.Chat_OnMessageSent, self)
    addon:RegisterCallback("Chat_OnChatOpened", self.Chat_OnChatOpened, self)
    addon:RegisterCallback("Chat_OnHistoryDeleted", self.Chat_OnHistoryDeleted, self)

    self.messageInput.EditBox:SetScript("OnEnterPressed", function(eb)
        if eb:GetText() ~= "" then
            if self.currentChat == "guild" then
                SendChatMessage(eb:GetText(), "GUILD")
                eb:SetText("")

            elseif type(self.currentChat) == "string" then
                SendChatMessage(eb:GetText(), "WHISPER", nil, self.currentChat)
                eb:SetText("")

            end
        end
    end)

    addon.AddView(self)
end

function GuildbookChatMixin:OnShow()
    --self.messageInput.EditBox:SetFontObject("QuestFontNormalLarge")
    self.messageInput.EditBox:SetAllPoints()
    self:Update()
end

function GuildbookChatMixin:Database_OnInitialised()
    self.chats = Database.db.chats;

    self:Update()
end

function GuildbookChatMixin:Chat_OnHistoryDeleted(name)
    if name == "Guild" then
        return;
    end
    if self.chats and self.chats[name] then
        self.chats[name] = nil;
    end
    self:Update()
end

function GuildbookChatMixin:Chat_OnChatOpened(target)
    if type(target) == "string" then
        local now = time()

        if not self.chats[target] then
            self.chats[target] = {
                lastActive = now,
                history = {},
            }
        else
            self.chats[target].lastActive = now;
        end

        self.currentChat = target;
        self:Update()
    end

    GuildbookUI:SelectView(self.name)
end

function GuildbookChatMixin:Chat_OnMessageSent(data)
    if type(data) == "table" then
        local now = time()

        if data.target == "guild" then
            if not self.chats.guild[addon.thisGuild] then
                self.chats.guild[addon.thisGuild] = {
                    lastActive = now,
                    history = {},
                }
            end
            table.insert(self.chats.guild[addon.thisGuild].history, {
                sender = addon.thisCharacter,
                message = data.message,
                timestamp = now,
            })
        else
            if not self.chats[data.target] then
                self.chats[data.target] = {
                    lastActive = now,
                    history = {},
                }
            end
            table.insert(self.chats[data.target].history, {
                sender = addon.thisCharacter,
                message = data.message,
                timestamp = now,
            })
        end


        self.chats[data.target].lastActive = now;

    end

    self:Update()
end

function GuildbookChatMixin:Update()

    if not addon.thisGuild then
        return
    end

    local chatList = {
        {
            label = GUILD,
            atlas = "GarrMission_MissionIcon-Logistics",
            showMask = false,

            func = function()
                self:SetChatHistory(self.chats.guild[addon.thisGuild].history, GUILD)
            end,
        },
    }

    --[[
        using table.remove here to limit chat history table length, the tables are small so the issue of t.remove shouldn't cause many problems?

        this likely isn't ideal but for now it'll help keep the SV under some form of control
    ]]
    
    local t = {}
    for name, chat in pairs(self.chats) do
        if name == "guild" then
            if addon.thisGuild and self.chats.guild[addon.thisGuild] and (#self.chats.guild[addon.thisGuild].history > Database.db.config.chatGuildHistoryLimit) then

                addon.LogDebugMessage("warning", string.format("chat history to long removing %d messages", (#self.chats.guild[addon.thisGuild].history - Database.db.config.chatWhisperHistoryLimit)))


                --normal operation, the limit was exceeded by 1 so remove
                if #self.chats.guild[addon.thisGuild].history - Database.db.config.chatGuildHistoryLimit == 1 then
                    table.remove(self.chats.guild[addon.thisGuild].history, 1)
                else

                    --likely the config was changed so we need to remove more than 1 entry
                    local history = addon.api.trimTable(self.chats.guild[addon.thisGuild].history, Database.db.config.chatGuildHistoryLimit, true)
                    self.chats.guild[addon.thisGuild].history = history
                end
            end
        else
            table.insert(t, {
                name = name,
                lastActive = chat.lastActive
            })
            if self.chats[name] and (#self.chats[name].history > Database.db.config.chatWhisperHistoryLimit) then

                addon.LogDebugMessage("warning", string.format("chat history to long removing %d messages", (#self.chats[name].history - Database.db.config.chatWhisperHistoryLimit)))
                
                --normal operation, the limit was exceeded by 1 so remove
                if #self.chats[name].history - Database.db.config.chatWhisperHistoryLimit == 1 then
                    table.remove(self.chats[name].history, 1)
                else

                    --likely the config was changed so we need to remove more than 1 entry
                    local history = addon.api.trimTable(self.chats[name].history, Database.db.config.chatWhisperHistoryLimit, true)
                    self.chats[name].history = history
                end
            end
        end
    end

    if #t > 0 then
        table.sort(t, function(a, b)
            return a.lastActive > b.lastActive
        end)
        for k, v in ipairs(t) do
            local x = self.chats[v.name]
            local atlas, name;
            if addon.characters[v.name] then
                atlas = addon.characters[v.name]:GetProfileAvatar()
                name = addon.characters[v.name]:GetName(true)
            else
                atlas = "GarrMission_MissionIcon-Recruit"
                name = v.name
            end
            table.insert(chatList, {
                label = name,
                characterName = v.name,
                atlas = atlas,
                showMask = true,

                func = function()
                    self:SetChatHistory(x.history, v.name)
                end,
            })
        end
    end

    local cdp = CreateDataProvider(chatList)
    self.charactersListview.scrollView:SetDataProvider(cdp)

    if self.currentChat then
        C_Timer.After(0.1, function()
            --DevTools_Dump(self.chats.guild)
            local dp
            if self.currentChat == "guild" then
                if self.chats.guild[addon.thisGuild] and self.chats.guild[addon.thisGuild].history then
                    dp = CreateDataProvider(self.chats.guild[addon.thisGuild].history)
                end
            else
                if self.chats[self.currentChat] and self.chats[self.currentChat].history then
                    dp = CreateDataProvider(self.chats[self.currentChat].history)
                end
            end
            if dp then
                self.chatHistory.scrollView:SetDataProvider(dp)
                self.chatHistory.scrollBox:ScrollToEnd()
            else
                self.chatHistory.DataProvider:Flush()
            end
        end)
    end
end

function GuildbookChatMixin:SetChatHistory(history, player)
    local dp = CreateDataProvider(history)
    self.chatHistory.scrollView:SetDataProvider(dp)
    self.chatHistory.scrollBox:ScrollToEnd()
    self.currentChat = (player == GUILD) and "guild" or player;
    self.chatInfo:SetText(player)
end

function GuildbookChatMixin:Chat_OnMessageReceived(data)

    if not self.chats then --db not sorted yet
        return;
    end

    if type(data) == "table" then

        local now = time();

        if data.channel == "guild" then
            if not self.chats.guild[addon.thisGuild] then
                self.chats.guild[addon.thisGuild] = {
                    lastActive = now,
                    history = {},
                }
            end
            table.insert(self.chats.guild[addon.thisGuild].history, {
                sender = data.sender,
                message = data.message,
                timestamp = now,
            })
        else
            if not self.chats[data.sender] then
                self.chats[data.sender] = {
                    lastActive = now,
                    history = {},
                }
            end

            self.chats[data.sender].lastActive = now;
            table.insert(self.chats[data.sender].history, {
                sender = data.sender,
                message = data.message,
                timestamp = now,
            })
        end
    end

    self:Update()
end