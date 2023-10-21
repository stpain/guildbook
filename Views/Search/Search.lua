local name, addon = ...;

GuildbookSearchMixin = {
    name = "Search",
    results = {},
}

function GuildbookSearchMixin:OnLoad()

    --as the search box is always shown and not tied to this view use a callback to perform the search and display this view
    addon:RegisterCallback("Guildbook_OnSearch", self.RunQuery, self)

    addon.AddView(self)
end


function GuildbookSearchMixin:UpdateResults()

    local dupes = {}
    local out = {}
    local counts = {}


    --lets combine container items to remove multiple results
    for k, v in ipairs(self.results) do
        if v.type == "bankItem" then
            if not counts[v.itemName] then
                counts[v.itemName] = {}
            end

            if not counts[v.itemName][v.location] then
                counts[v.itemName][v.location] = 0;
            end
            counts[v.itemName][v.location] = counts[v.itemName][v.location] + v.count
        end
    end

    for k, v in ipairs(self.results) do
        
        if v.type == "bankItem" then
            if not dupes[v.itemName] then
                dupes[v.itemName] = true
                table.insert(out, {
                    type = "bankItem",
                    data = v.data,
                    location = counts[v.itemName]
                })
            end
        end

        if v.type == "tradeskillItem" then
            if not dupes[v.data.itemLink] then
                table.insert(out, v)
                dupes[v.data.itemLink] = true
            end
        end

        if v.type == "character" then
            v.onMouseDown = function()
                addon:TriggerEvent("Character_OnProfileSelected", addon.characters[v.data.data.name])
            end
            table.insert(out, v)
        end

        if v.type == "inventory" then
            table.insert(out, v)
        end
    end

    self.resultsListview.scrollView:SetDataProvider(CreateDataProvider(out))

    self.headerLeft:SetText(string.format("%d results found for '%s'", #out, self.serachTerm))
end


--this needs some work, ideally only return 1 result per item and avoid extra api calls/mixins
function GuildbookSearchMixin:RunQuery(term)

    self.serachTerm = term;
    term = term:lower()

    self.results = nil;
    self.results = {};

    for k, item in ipairs(addon.itemData) do
        if item.itemLink and item.itemLink:lower():find(term) then

            table.insert(self.results, {
                type = "tradeskillItem",
                data = item,
                location = "tradeskill-item",
                count = 1,
            })
        end
    end

    for k, v in pairs(addon.characters) do
        if v.data.name:lower():find(term) then

            table.insert(self.results, {
                type = "character",
                data = v,
                location = "character-directory",
                count = 1,
            })
        end
        if v.data.containers and v.data.containers.bags and v.data.containers.bags.items then
            for a, b in ipairs(v.data.containers.bags.items) do
                local item = Item:CreateFromItemID(b.id)
                if not item:IsItemEmpty() then
                    item:ContinueOnItemLoad(function()
                        if item:GetItemName():lower():find(term) then

                            table.insert(self.results, {
                                type = "bankItem", --also containers
                                data = item,
                                itemName = item:GetItemName(),
                                location = v.data.name,
                                count = b.count,
                            })
                            self:UpdateResults()
                        end
                    end)
                end
            end
        end
        if v.data.inventory then
            for set, links in pairs(v.data.inventory) do
                for slot, link in pairs(links) do
                    if type(link) == "string" then
                        local item = Item:CreateFromItemLink(link)
                        if item and not item:IsItemEmpty() then
                            item:ContinueOnItemLoad(function()
                                if item:GetItemName():lower():find(term) then
    
                                    table.insert(self.results, {
                                        type = "inventory",
                                        data = item,
                                        location = string.format("character-inventory %s", v.data.name),
                                        count = 1,
                                    })
                                    self:UpdateResults()
                                end
                            end)
                        end
                    end
                end
                for k, itemID in ipairs(links) do
                    if type(itemID) == "number" then
                        local item = Item:CreateFromItemID(itemID)
                        if item and not item:IsItemEmpty() then
                            item:ContinueOnItemLoad(function()
                                if item:GetItemName():lower():find(term) then
    
                                    table.insert(self.results, {
                                        type = "inventory",
                                        data = item,
                                        location = string.format("character-inventory %s", v.data.name),
                                        count = 1,
                                    })
                                    self:UpdateResults()
                                end
                            end)
                        end
                    end
                end
            end
        end
    end


    self:UpdateResults()
end