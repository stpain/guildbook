

local _, Guildbook = ...


local debugTypeToClassColour = {
    ['error'] = CreateColor(Guildbook.Data.Class.DEATHKNIGHT.RGB),
    ['func'] = CreateColor(Guildbook.Data.Class.HUNTER.RGB),
    ['event'] = CreateColor(Guildbook.Data.Class.ROGUE.RGB),
    ['comms_out'] = CreateColor(Guildbook.Data.Class.SHAMAN.RGB),
    ['comms_in'] = CreateColor(Guildbook.Data.Class.MAGE.RGB),
    ['db_func'] = CreateColor(Guildbook.Data.Class.DRUID.RGB),
}
GuildbookDebuggerListviewItemTemplateMixin = {}
function GuildbookDebuggerListviewItemTemplateMixin:Init(elementData)
    local rgb = debugTypeToClassColour[elementData.debugType]:GetRGBA()
    self.background:SetColorTexture(rgb[1], rgb[2], rgb[3], 0.3)
    self.timestamp:SetText(elementData.timestamp)
    self.blockName:SetText(string.format("[%s]", elementData.blockName))
    self.message:SetText(elementData.message)
    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT', -20, 0)
        if elementData.tooltipTable then
            for k, v in pairs(elementData.tooltipTable) do
                if type(v) == "table" then
                    for a, b in pairs(v) do
                        GameTooltip:AddDoubleLine("> "..a, b)
                        if type(b) == "table" then
                            for c, d in pairs(b) do
                                if d then
                                    GameTooltip:AddDoubleLine(">> "..c, d)
                                end                            end
                            for c, d in ipairs(b) do
                                if d then
                                    GameTooltip:AddDoubleLine(">> "..c, d)
                                end  
                            end
                        end
                    end
                    for a, b in ipairs(v) do
                        GameTooltip:AddDoubleLine("> "..a, b)
                        if type(b) == "table" then
                            for c, d in pairs(b) do
                                if d then
                                    GameTooltip:AddDoubleLine(">> "..c, d)
                                end                            end
                            for c, d in ipairs(b) do
                                if d then
                                    GameTooltip:AddDoubleLine(">> "..c, d)
                                end                           
                            end
                        end
                    end
                end
            end
        end
        GameTooltip:Show()
    end)
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end


GuildbookDebuggerListviewMixin = {}
function GuildbookDebuggerListviewMixin:OnLoad()
    self.DataProvider = CreateDataProvider();
    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(24);
    self.ScrollView:SetElementInitializer("FRAME", "GuildbookDebuggerListviewItemTemplate", function(frame, elementData)
        frame:Init(elementData)
    end);
    self.ScrollView:SetPadding(5, 5, 5, 5, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, "BOTTOMLEFT", 0, 4),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithBar, anchorsWithoutBar);
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--debug printers
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Guildbook.DebugColours = {
    ['error'] = '|cffC41E3A', --dk
    ['func'] = '|cffAAD372', --hunter
    ['event'] = '|cff00FF98', --monk
    ['comms_out'] = '|cff8787ED', --warlock
    ['comms_in'] = '|cff0070DD', --shaman
    ['db_func'] = "|cffFF7D0A", --druid
}

-- table to hold debug messages
Guildbook.DebugLog = {}

---add new debug message
---@param id string the type of debug, this also sets the colour used (func, comms_in, error, comms_out)
---@param func string the function name
---@param msg string the debug message to display
function Guildbook.DEBUG(id, func, msg, data)
    -- for i = 1, 40 do
    --     Guildbook.DebuggerWindow.Listview[i]:Hide()
    -- end
    -- if func and msg then
    --     table.insert(Guildbook.DebugLog, {
    --         msg = string.format("%s [%s%s|r], %s", date("%T"), Guildbook.DebugColours[id], func, msg),
    --         data = data,
    --     })
    -- end
    -- if Guildbook.DebugLog and next(Guildbook.DebugLog) then
    --     local i = #Guildbook.DebugLog - 39
    --     if i < 1 then
    --         i = 1
    --     end
    --     Guildbook.DebuggerWindow.ScrollBar:SetMinMaxValues(1, i)
    --     if Guildbook.DebuggerWindow.ScrollBar:GetValue() == (i - 1) then
    --         Guildbook.DebuggerWindow.ScrollBar:SetValue(i)
    --     end
    --     C_Timer.After(0, function()
    --         for i = 1, 40 do
    --             Guildbook.DebuggerWindow.Listview[i]:Show()
    --         end
    --     end)
    -- end

    local ts = date("%T")
    Guildbook.DebuggerWindow.listview.DataProvider:Insert({
        debugType = id,
        blockName = func,
        timestamp = ts,
        message = msg,
        tooltipTable = data,
    })
end


-- create the debugging window
Guildbook.DebuggerWindow = CreateFrame('FRAME', 'GuildbookDebugFrame', UIParent, "UIPanelDialogTemplate")
Guildbook.DebuggerWindow:SetPoint('CENTER', 0, 0)
Guildbook.DebuggerWindow:SetFrameStrata('DIALOG')
Guildbook.DebuggerWindow:SetSize(800, 560)
Guildbook.DebuggerWindow:SetMovable(true)
Guildbook.DebuggerWindow:EnableMouse(true)
Guildbook.DebuggerWindow:RegisterForDrag("LeftButton")
Guildbook.DebuggerWindow:SetScript("OnDragStart", Guildbook.DebuggerWindow.StartMoving)
Guildbook.DebuggerWindow:SetScript("OnDragStop", Guildbook.DebuggerWindow.StopMovingOrSizing)
_G['GuildbookDebugFrameClose']:SetScript('OnClick', function()
    if GUILDBOOK_CHARACTER and GUILDBOOK_GLOBAL then
        GUILDBOOK_GLOBAL['Debug'] = false
        GuildbookOptionsDebugCB:SetChecked(GUILDBOOK_GLOBAL['Debug'])
    end
    if GuildbookOptionsDebugCB:GetChecked() == true then
        Guildbook.DebuggerWindow:Show()
    else
        Guildbook.DebuggerWindow:Hide()
    end
end)

Guildbook.DebuggerWindow.header = Guildbook.DebuggerWindow:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
Guildbook.DebuggerWindow.header:SetPoint('TOP', 0, -9)
Guildbook.DebuggerWindow.header:SetText('Guildbook Debug')

Guildbook.DebuggerWindow.listview = CreateFrame("FRAME", nil, Guildbook.DebuggerWindow, "GuildbookDebuggerListviewTemplate")
Guildbook.DebuggerWindow.listview:SetPoint("BOTTOMLEFT", 10, 10)
Guildbook.DebuggerWindow.listview:SetPoint("TOPRIGHT", -10, -40)

Guildbook.DebuggerWindow.Listview = {}
-- for i = 1, 40 do
--     local f = CreateFrame('BUTTON', tostring('SRBLP_LogsListview'..i), Guildbook.DebuggerWindow)
--     f:SetPoint('TOPLEFT', Guildbook.DebuggerWindow, 'TOPLEFT', 8, (i * -12) -18)
--     f:SetPoint('TOPRIGHT', Guildbook.DebuggerWindow, 'TOPRIGHT', -8, (i * -12) -18)
--     f:SetHeight(12)
--     f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
--     f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
--     f.Message = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
--     f.Message:SetPoint('LEFT', 8, 0)
--     f.Message:SetSize(780, 20)
--     f.Message:SetJustifyH('LEFT')
--     f.Message:SetTextColor(1,1,1,1)
--     f.info = nil
--     f:SetScript('OnShow', function(self)
--         if self.info and self.info.msg then
--             self.Message:SetText(self.info.msg)
--         else
--             self:Hide()
--         end
--     end)
--     f:SetScript('OnEnter', function(self)
--         if self.info and self.info.data and type(self.info.data) == "table" then
--             GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
--             for k, v in ipairs(self.info.data) do
--                 if type(v) == "table" then
--                     for a, b in pairs(v) do
--                         GameTooltip:AddDoubleLine("> "..a, b)
--                         if type(b) == "table" then
--                             for c, d in pairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end                            end
--                             for c, d in ipairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end  
--                             end
--                         end
--                     end
--                     for a, b in ipairs(v) do
--                         GameTooltip:AddDoubleLine("> "..a, b)
--                         if type(b) == "table" then
--                             for c, d in pairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end                            end
--                             for c, d in ipairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end                           
--                             end
--                         end
--                     end
--                 end
--             end
--             for k, v in pairs(self.info.data) do
--                 GameTooltip:AddDoubleLine(k, v)
--                 if type(v) == "table" then
--                     for a, b in pairs(v) do
--                         GameTooltip:AddDoubleLine("> "..a, b)
--                         if type(b) == "table" then
--                             for c, d in pairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end
--                             end
--                             for c, d in ipairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end
--                             end
--                         end
--                     end
--                     for a, b in ipairs(v) do
--                         GameTooltip:AddDoubleLine("> "..a, b)
--                         if type(b) == "table" then
--                             for c, d in pairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end
--                             end
--                             for c, d in ipairs(b) do
--                                 if d then
--                                     GameTooltip:AddDoubleLine(">> "..c, d)
--                                 end
--                             end
--                         end
--                     end
--                 end
--             end
--             GameTooltip:Show()
--         else
--             GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
--         end
--     end)
--     f:SetScript('OnLeave', function(self)
--         GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
--     end)
--     f:SetScript('OnHide', function(self)
--         self.Message:SetText(' ')
--     end)
--     f:SetScript('OnMouseWheel', function(self, delta)
--         local s = Guildbook.DebuggerWindow.ScrollBar:GetValue()
--         Guildbook.DebuggerWindow.ScrollBar:SetValue(s - delta)
--     end)
--     Guildbook.DebuggerWindow.Listview[i] = f
-- end

-- Guildbook.DebuggerWindow.ScrollBar = CreateFrame('SLIDER', 'GuildbookDebugFrameScrollBar', Guildbook.DebuggerWindow, "UIPanelScrollBarTemplate")
-- Guildbook.DebuggerWindow.ScrollBar:SetPoint('TOPLEFT', Guildbook.DebuggerWindow, 'TOPRIGHT', -24, -44)
-- Guildbook.DebuggerWindow.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.DebuggerWindow, 'BOTTOMRIGHT', -8, 26)
-- Guildbook.DebuggerWindow.ScrollBar:EnableMouse(true)
-- Guildbook.DebuggerWindow.ScrollBar:SetValueStep(1)
-- Guildbook.DebuggerWindow.ScrollBar:SetValue(1)
-- Guildbook.DebuggerWindow.ScrollBar:SetMinMaxValues(1, 1)
-- Guildbook.DebuggerWindow.ScrollBar:SetScript('OnValueChanged', function(self)
--     if Guildbook.DebugLog then
--         local scrollPos = math.floor(self:GetValue())
--         if scrollPos == 0 then
--             scrollPos = 1
--         end
--         for i = 1, 40 do
--             if Guildbook.DebugLog[(i - 1) + scrollPos] then
--                 Guildbook.DebuggerWindow.Listview[i]:Hide()
--                 Guildbook.DebuggerWindow.Listview[i].info = Guildbook.DebugLog[(i - 1) + scrollPos]
--                 Guildbook.DebuggerWindow.Listview[i]:Show()
--             end
--         end
--     end
-- end)
