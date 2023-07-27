GuildbookWrathEraWidgetsListviewMixin = {}

function GuildbookWrathEraWidgetsListviewMixin:OnLoad()

    self.DataProvider = CreateDataProvider();
    self.scrollView = CreateScrollBoxListLinearView();
    self.scrollView:SetDataProvider(self.DataProvider);

    ---height is defined in the xml keyValues
    local height = self.elementHeight;
    self.scrollView:SetElementExtent(height);

    local version, build, _date, tocversion, localizedVersion, buildType = GetBuildInfo()
    if tocversion == 11403 then
        self.scrollView:SetElementInitializer(self.frameType, self.itemTemplate, GenerateClosure(self.OnElementInitialize, self));
    elseif tocversion > 11403 then
        self.scrollView:SetElementInitializer(self.itemTemplate, GenerateClosure(self.OnElementInitialize, self));
    end

    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollView);

    self.scrollView:SetPadding(1, 1, 1, 1, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -1, 1),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.scrollBox, self.scrollBar, anchorsWithBar, anchorsWithoutBar);
end

function GuildbookWrathEraWidgetsListviewMixin:OnElementInitialize(element, elementData, isNew)
    if isNew then
        element:OnLoad();
    end
    local height = self.elementHeight;
    element:SetDataBinding(elementData, height);
    element:Show()
end

function GuildbookWrathEraWidgetsListviewMixin:OnElementReset(element)
    element:ResetDataBinding()
end