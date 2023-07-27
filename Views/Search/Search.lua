local name, addon = ...;

GuildbookSearchMixin = {
    name = "Search",
}

function GuildbookSearchMixin:OnLoad()

    addon:RegisterCallback("Guildbook_OnSearch", self.Search, self)

    addon.AddView(self)
end


--this needs some work, ideally only return 1 result per item and avoid extra api calls/mixins
function GuildbookSearchMixin:Search(term)

    self.resultsListview.DataProvider:Flush()

    for k, item in ipairs(addon.itemData) do
        if item.itemLink and item.itemLink:find(term) then
            self.resultsListview.DataProvider:Insert({
                type = "tradeskillItem",
                data = item,
            })
        end
    end

    for k, v in pairs(addon.characters) do
        if v.data.name:find(term) then
            self.resultsListview.DataProvider:Insert({
                type = "character",
                data = v,
            })
        end
        if v.data.containers and v.data.containers.bags then
            for a, b in ipairs(v.data.containers.bags) do
                local item = Item:CreateFromItemID(b.id)
                if not item:IsItemEmpty() then
                    item:ContinueOnItemLoad(function()
                        if item:GetItemName():find(term) then
                            self.resultsListview.DataProvider:Insert({
                                type = "bankItem",
                                data = item,
                            })
                        end
                    end)
                end
            end
        end
        if v.data.inventory then
            for set, links in pairs(v.data.inventory) do
                for slot, link in pairs(links) do
                    if link and (link:find(term)) then
                        local item = Item:CreateFromItemLink(link)
                        if not item:IsItemEmpty() then
                            item:ContinueOnItemLoad(function()
                                if item:GetItemName():find(term) then
                                    self.resultsListview.DataProvider:Insert({
                                        type = "inventory",
                                        data = item,
                                    })
                                end
                            end)
                        end
                    end
                end
            end
        end
    end



end