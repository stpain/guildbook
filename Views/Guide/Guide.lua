local name, addon = ...;
local L = addon.Locales;
local Database = addon.Database;


GuildbookGuideMixin = {
    name = "Guide",
    selectedInstance = false,
    selectedInstanceMapID = 1,
    helptips = {},
}

function GuildbookGuideMixin:OnLoad()

    --self.lore.loot.gridview:InitFramePool("FRAME", "GuildbookCircleLootItemTemplate")
    --self.lore.loot.gridview:SetFixedColumnCount(5)
    --self.lore.loot.gridview:SetMinMaxSize(80, 110)

    self.homeGridview:InitFramePool("FRAME", "GuildbookGuideHomeGridviewItemTemplate")
    self.homeGridview:SetMinMaxSize(160, 220)

    self.instanceView.background:SetTexture(521750)
    self.instanceView.lore.text:GetFontString():SetTextColor(CreateColor(0.002, 0.002, 0.001))
    self.instanceView.mapsButton:SetScript("OnMouseDown", function()
        self.instanceView.lore:Hide()
        self.instanceView.encounters:Hide()
        self.instanceView.background:Hide()
        self.instanceView.maps:Show()
    end)
    self.instanceView.encountersButton:SetScript("OnMouseDown", function()
        self.instanceView.lore:Hide()
        self.instanceView.maps:Hide()
        self.instanceView.background:Show()
        self.instanceView.encounters:Show()
    end)
    self.instanceView.infoButton:SetScript("OnMouseDown", function()
        self.instanceView.encounters:Hide()
        self.instanceView.maps:Hide()
        self.instanceView.background:Show()
        self.instanceView.lore:Show()
    end)
    self.instanceView.maps.previous:SetNormalTexture(130869)
    self.instanceView.maps.previous:SetPushedTexture(130868)
    self.instanceView.maps.previous:SetScript("OnClick", function()
        if self.selectedInstance then
            self.selectedInstanceMapID = self.selectedInstanceMapID - 1;
            if self.selectedInstanceMapID < 1 then
                self.selectedInstanceMapID = 1;
            end
            self.instanceView.maps.background:SetTexture(self.selectedInstance.maps[self.selectedInstanceMapID])
        end
    end)
    self.instanceView.maps.next:SetNormalTexture(130866)
    self.instanceView.maps.next:SetPushedTexture(130865)
    self.instanceView.maps.next:SetScript("OnClick", function()
        if self.selectedInstance then
            self.selectedInstanceMapID = self.selectedInstanceMapID + 1;
            if self.selectedInstanceMapID > #self.selectedInstance.maps then
                self.selectedInstanceMapID = #self.selectedInstance.maps;
            end
            self.instanceView.maps.background:SetTexture(self.selectedInstance.maps[self.selectedInstanceMapID])
        end
    end)

    self.home:SetScript("OnClick", function()
        self.instanceView:Hide()

        self.homeGridview:Show()
    end)
    self:SetScript("OnShow", function()
        self:UpdateLayout()
    end)

    addon:RegisterCallback("Database_OnInitialised", self.Database_OnInitialised, self)
    addon:RegisterCallback("Guide_OnInstanceSelected", self.Guide_OnInstanceSelected, self)
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
    addon.AddView(self)
end

function GuildbookGuideMixin:Database_OnInitialised()
    
    for k, v in ipairs(addon.dungeons) do
        self.homeGridview:Insert(v)
    end
    self.homeGridview:UpdateLayout()

end

function GuildbookGuideMixin:UpdateLayout()

    local x, y = self:GetSize()

    self.instanceView.lore.icon:SetSize((x / 2) - 20, (y / 2))

    if self.selectedInstance then
        self.instanceView.lore.text:SetText(self.selectedInstance.history or "")

    end

    self.homeGridview:UpdateLayout()
end

function GuildbookGuideMixin:Guide_OnInstanceSelected(instance)
    
    self.homeGridview:Hide()
    self.instanceView:Show()
    self:LoadInstance(instance)
end

function GuildbookGuideMixin:LoadInstance(instance)

    self.selectedInstance = instance
    self.selectedInstanceMapID = 1;

    self.instanceView.lore.icon:SetTexture(instance.loreFileID)
    self.instanceView.lore.text:SetText(instance.history)

    self.instanceView.maps.background:SetTexture(instance.maps[self.selectedInstanceMapID])
end

function GuildbookGuideMixin:LoadData(data)

    self.selectedInstance = data;

    local loot = {}

    --this means only using ItemMixin once
    local updateLoot = function()
        table.sort(loot, function(a, b)
            return a.subClass < b.subClass;
        end)
        self.lore.loot.gridview:Flush() --doesn't use DataProvider
        for k, v in ipairs(loot) do
            self.lore.loot.gridview:Insert({
                icon = v.icon,
                link = v.link,
                colour = v.colour,
                subClass = v.subClass,
            })
            self.lore.loot.gridview:UpdateLayout()
        end


    end

    for boss, items in pairs(data.bosses) do
        for k, id in ipairs(items) do
            local item = Item:CreateFromItemID(id)
            if not item:IsItemEmpty() then
                item:ContinueOnItemLoad(function()
                    local _, _, subClass = GetItemInfoInstant(id)
                    table.insert(loot, {
                        icon = item:GetItemIcon(),
                        link = item:GetItemLink(),
                        colour = item:GetItemQualityColor(),
                        boss = boss,
                        subClass = subClass,
                    })
                    updateLoot()
                end)
            end
        end
    end

    self.lore.info.loreArtwork:SetTexture(data.loreFileID)
    self.lore.info.meta:SetText(string.format("%s\n%s\n%s-%s", data.name, data.meta.zone, data.meta.minLevel, data.meta.maxLevel))

    --self.lore.history.text:SetFontObject(GameFontNormal_NoShadow)
    self.lore.history.text:GetFontString():SetTextColor(CreateColor(0.002, 0.002, 0.001))
    self.lore.history.text:SetText(data.history)

    local t1 = {}
    for k, boss in ipairs(data.bosses) do
        table.insert(t1, {
            label = boss,
            func = function()
                self.loot.lootListview.DataProvider:Flush()
                local t2 ={}
                for k, v in ipairs(loot) do
                    if v.boss == boss then
                        table.insert(t2, {
                            label = v.link,
                            texture = v.icon,
                        })
                    end
                end
                self.loot.lootListview.DataProvider:InsertTable(t2)
            end,
        })
    end
    local dp = CreateDataProvider(t1)
    self.loot.encounterListview.scrollView:SetDataProvider(dp)

    self.maps.background:SetTexture(data.maps[self.selectedInstanceMapID])
    if #data.maps > 1 then
        
    else

    end

end