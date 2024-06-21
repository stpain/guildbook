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


    self.resultsListview.scrollView:SetDataProvider(CreateDataProvider(out))

    self.headerLeft:SetText(string.format("%d results found for '%s'", #out, self.serachTerm))
end


--this needs some work, ideally only return 1 result per item and avoid extra api calls/mixins
function GuildbookSearchMixin:RunQuery(term)

    self.serachTerm = term;
    term = term:lower()

    self.results = nil;
    self.results = {};



    self:UpdateResults()
end