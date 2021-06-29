
local fileID = 521743;

local itemsPerPage = 25;

local viewer = CreateFrame("Frame", "hslTextureViewer", UIParent, "BasicFrameTemplateWithInset")
viewer:SetSize(810, 550)
viewer:SetPoint("CENTER", 0, 0)
viewer:SetMovable(true)
viewer:EnableMouse(true)
viewer:RegisterForDrag("LeftButton")
viewer:SetScript("OnDragStart", viewer.StartMoving)
viewer:SetScript("OnDragStop", viewer.StopMovingOrSizing)
viewer:Hide()

viewer.editbox = CreateFrame("EDITBOX", nil, viewer, "InputBoxTemplate")
viewer.editbox:SetPoint("TOP", 0, 0)
viewer.editbox:SetSize(100, 20)
viewer.editbox:SetAutoFocus(false)
viewer.editbox:SetScript("OnTextChanged", function(self)
    if tonumber(self:GetText()) then
        fileID = self:GetText()
        for i = 1, itemsPerPage do
            viewer.textures[i].texture:SetTexture(fileID + i)
            viewer.textures[i].text:SetText(fileID + i)
        end
    end
end)

viewer.prev = CreateFrame("BUTTON", nil, viewer, "UIPanelButtonTemplate")
viewer.prev:SetPoint("RIGHT", viewer.editbox, "LEFT", -20, 0)
viewer.prev:SetSize(80, 20)
viewer.prev:SetText("Prev")
viewer.prev:SetScript("OnClick", function(self)
    fileID = fileID - itemsPerPage
    for i = 1, itemsPerPage do
        viewer.textures[i].texture:SetTexture(fileID + i)
        viewer.textures[i].text:SetText(fileID + i)
    end
    viewer.editbox:ClearFocus()
end)

viewer.next = CreateFrame("BUTTON", nil, viewer, "UIPanelButtonTemplate")
viewer.next:SetPoint("LEFT", viewer.editbox, "RIGHT", 20, 0)
viewer.next:SetSize(80, 20)
viewer.next:SetText("Next")
viewer.next:SetScript("OnClick", function(self)
    fileID = fileID + itemsPerPage
    for i = 1, itemsPerPage do
        viewer.textures[i].texture:SetTexture(fileID + i)
        viewer.textures[i].text:SetText(fileID + i)
    end
    viewer.editbox:ClearFocus()
end)

viewer.textures = {}
local i = 1;
for row = 0, 4 do
    for col = 0, 4 do
        local t = viewer:CreateTexture(nil, "ARTWORK")
        t:SetSize(155, 82.5)
        t:SetPoint("TOPLEFT", (col * 155) + 20, (row * -100) - 30)
        local f = viewer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f:SetPoint("BOTTOM", t, "BOTTOM", 0, -14)
        viewer.textures[i] = {
            texture = t,
            text = f,
        }
        i = i + 1
    end
end
