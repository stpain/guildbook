local name, addon = ...;

GuildbookGuildTreeMixin = {
    name = "GuildTree",
}

function GuildbookGuildTreeMixin:OnLoad()

    addon:RegisterCallback("UI_OnSizeChanged", self.Update, self)
    addon:RegisterCallback("Blizzard_OnGuildRosterUpdate", self.Blizzard_OnGuildRosterUpdate, self)

    addon.AddView(self)
end

function GuildbookGuildTreeMixin:Blizzard_OnGuildRosterUpdate()
    self:Update()
end

function GuildbookGuildTreeMixin:OnShow()
    self:Update()
end

function GuildbookGuildTreeMixin:Update()

    self.listview.DataProvider:Flush()

    local ranks = {}
    local totalMembers, onlineMembers, _ = GetNumGuildMembers()
    for i = 1, totalMembers do
        local name, rankName, rankIndex = GetGuildRosterInfo(i)
        if not ranks[rankIndex] then
            ranks[rankIndex] = {
                name = rankName,
                members = {},
            }
        end
        if addon.characters[name] then
            table.insert(ranks[rankIndex].members, addon.characters[name])
        end
        --print("LENGTH OF RANK TABLE IS NOW", rankIndex, ranks[rankIndex].name, #ranks[rankIndex].members)
    end

    local numPerRow = math.floor(self:GetWidth() / 100)
    --print("NUMBER PER ROW", numPerRow)
    local rankHeadersAdded = {}
    for i = 0, 20 do
        if ranks[i] then
            local rank = ranks[i]
            if not rankHeadersAdded[i] then

                --print("NUM MEMBER PER RANK", rank.name, #rank.members)

                if #rank.members <= numPerRow then
                    self.listview.DataProvider:Insert({
                        showHeader = true,
                        header = rank.name,
                        characters = rank.members,
                    })
                    rankHeadersAdded[rank.name] = true
                else
                    local numRows = math.ceil(#rank.members / numPerRow)
                    for i = 1, numRows do
                        local charactersThisRow = {}
                        for j = ((i * numPerRow) - (numPerRow - 1)), (i * numPerRow) do
                            if rank.members[j] then
                                table.insert(charactersThisRow, rank.members[j])
                            end
                        end
                        if not rankHeadersAdded[rank.name] then
                            self.listview.DataProvider:Insert({
                                showHeader = true,
                                header = rank.name,
                                characters = charactersThisRow,
                            })
                            rankHeadersAdded[rank.name] = true
                        else
                            self.listview.DataProvider:Insert({
                                showHeader = false,
                                header = "",
                                characters = charactersThisRow,
                            })
                        end
                    end
                end
            end
        end
    end

end
