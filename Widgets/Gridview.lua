

local name, addon = ...;

--[[

GridView

create a gridview widget that will scale with a resizable UI,
frames added to the grid can make use of the following methods

:SetDataBinding, this method is called when adding items

:ResetDataBinding, this method is called before SetDataBinding if you want to tidy up any frame elements

:UpdateLayout, this method is called last and can be used to update the size and layout of elements within the frame

specifically of note is that :UpdateLayout will be called on each frame when calling :UpdateLayout on the gridview itself

]]
GuildbookWrathEraWidgetsGridviewMixin = {}
function GuildbookWrathEraWidgetsGridviewMixin:OnLoad()
    self.data = {}
    self.frames = {}
    self.itemMinWidth = 0
    self.itemMaxWidth = 0
    self.itemSize = 0
    self.colIndex = 0
    self.rowIndex = 0
    self.numItemsPerRow = 1
    self.fixedColumnCount = false;
    self.anchorOffsetX = 0
    self.anchorOffsetY = 0
end

function GuildbookWrathEraWidgetsGridviewMixin:InitFramePool(type, template)
    self.framePool = CreateFramePool(type, self.scrollChild, template);
end

function GuildbookWrathEraWidgetsGridviewMixin:SetMinMaxSize(min, max)
    self.itemMinWidth = min;
    self.itemMaxWidth = max;
end

function GuildbookWrathEraWidgetsGridviewMixin:SetFixedColumnCount(count)
    self.fixedColumnCount = count;
end

function GuildbookWrathEraWidgetsGridviewMixin:SetAnchorOffsets(x, y)
    if type(x) == "number" then
        self.anchorOffsetX = x;
    end
    if type(y) == "number" then
        self.anchorOffsetY = y;
    end
end

function GuildbookWrathEraWidgetsGridviewMixin:InsertCustomFrame(frame)
    if self.frames then
        local id = #self.frames
        frame:SetID(id + 1);
        frame:SetParent(self.scrollChild)
        table.insert(self.frames, frame)
        frame:Show()
        frame:SetSize(100,100)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", 0, 0)
    end
    --self:UpdateLayout()
end

function GuildbookWrathEraWidgetsGridviewMixin:Insert(info)
    table.insert(self.data, info)

    local f = self.framePool:Acquire()
    f:SetID(#self.data)

    if f.SetDataBinding then
        f:SetDataBinding(self.data[#self.data])
    end

    f:Show()
    table.insert(self.frames, f)

    self:UpdateLayout()
end

function GuildbookWrathEraWidgetsGridviewMixin:RemoveFrame(frame)
    local key;
    for k, f in ipairs(self.frames) do
        if f:GetID() == frame:GetID() then
            if f.ResetDataBinding then
                f:ResetDataBinding()
            end
            key = k;
            self.framePool:Release(f)
        end
    end
    if type(key) == "number" then
        table.remove(self.frames, key)
    end
    self:UpdateLayout()
end

function GuildbookWrathEraWidgetsGridviewMixin:InsertTable(tbl)

end

function GuildbookWrathEraWidgetsGridviewMixin:Flush()
    self.data = {}
    for k, f in ipairs(self.frames) do
        if f.ResetDataBinding then
            f:ResetDataBinding()
        end
        f:Hide()
    end
    self.frames = {}
    self.framePool:ReleaseAll()
end

function GuildbookWrathEraWidgetsGridviewMixin:GetItemSize()
    local width = self:GetWidth() - (self.anchorOffsetX * 2);

    if type(self.fixedColumnCount) == "number" then
        self.itemSize = (width / self.fixedColumnCount)
        self.numItemsPerRow = self.fixedColumnCount;

    else

        local numItemsPerRowMinWidth = width / self.itemMinWidth;
        local numItemsPerRowMaxWidth = width / self.itemMaxWidth;
    
        self.numItemsPerRow =  math.ceil(((numItemsPerRowMinWidth + numItemsPerRowMaxWidth) / 2))

        self.itemSize = (width / self.numItemsPerRow)
    end

    --[[
        this next bit was a first attempt to fix the min/max sizes
        however having a fixed size means the items wont always 
        adjust to fill each row, so leaving the older math in place
    ]]

    --self.numItemsPerRow =  math.ceil(width / self.itemMinWidth)

    -- if self.itemSize < self.itemMinWidth then
    --     self.itemSize = (width / (self.numItemsPerRow - 1))
    -- end
    -- if self.itemSize > self.itemMaxWidth then
    --     self.itemSize = self.itemMaxWidth
    --     self.numItemsPerRow =  math.floor(width / self.itemMaxWidth)
    -- end
end

function GuildbookWrathEraWidgetsGridviewMixin:UpdateLayout()
    self:GetItemSize()

    self.colIndex = 0;
    self.rowIndex = 0;

    self.scrollChild:SetHeight(self:GetHeight())
    self.scrollChild:SetWidth(self:GetWidth())
    self.ScrollBar:Hide()

    for k, f in ipairs(self.frames) do
        f:ClearAllPoints()
        f:SetSize(self.itemSize, self.itemSize)
        f:SetPoint("TOPLEFT", (self.itemSize * self.colIndex) + self.anchorOffsetX, -((self.itemSize * self.rowIndex) + self.anchorOffsetY))
        if k < (self.numItemsPerRow * (self.rowIndex + 1)) then
            self.colIndex = self.colIndex + 1
        else
            self.colIndex = 0
            self.rowIndex = self.rowIndex + 1
        end
        if f.UpdateLayout then
            f:UpdateLayout()
        end
        f:Show()
    end
end

function GuildbookWrathEraWidgetsGridviewMixin:GetFrames()
    return self.frames;
end