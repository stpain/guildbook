

local _, Guildbook = ...


local debugTypeToClassColour = {
    ['error'] = CreateColor(Guildbook.Data.Class.DEATHKNIGHT.RGB),
    ['func'] = CreateColor(Guildbook.Data.Class.HUNTER.RGB),
    ['event'] = CreateColor(Guildbook.Data.Class.ROGUE.RGB),
    ['comms_out'] = CreateColor(Guildbook.Data.Class.PALADIN.RGB),
    ['comms_in'] = CreateColor(Guildbook.Data.Class.PALADIN.RGB),
    ['db_func'] = CreateColor(Guildbook.Data.Class.PALADIN.RGB),
    ['tsdb'] = CreateColor(Guildbook.Data.Class.PALADIN.RGB),

    ["commsMixin"] = CreateColor(Guildbook.Data.Class.SHAMAN.RGB),
    ["rosterCacheMixin"] = CreateColor(Guildbook.Data.Class.WARLOCK.RGB),
    ["characterMixin"] = CreateColor(Guildbook.Data.Class.DRUID.RGB),
}
GuildbookDebuggerListviewItemTemplateMixin = {}
function GuildbookDebuggerListviewItemTemplateMixin:Init(elementData)
    local rgb = debugTypeToClassColour[elementData.debugType]:GetRGBA()
    self.background:SetColorTexture(rgb[1], rgb[2], rgb[3], 0.2)
    self.timestamp:SetText(elementData.timestamp)
    self.blockName:SetText(string.format("[%s]", elementData.blockName))
    self.message:SetText(elementData.message)
    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT', -20, 0)
        if elementData.tooltipTable and type(elementData.tooltipTable) == "table" then
            for k, v in pairs(elementData.tooltipTable) do
                if type(v) ~= "table" then
                    GameTooltip:AddDoubleLine("> "..k, v)
                else
                    for a, b in pairs(v) do
                        GameTooltip:AddDoubleLine("> "..a, b)
                        if type(b) == "table" then
                            for c, d in pairs(b) do
                                if d then
                                    --GameTooltip:AddDoubleLine(">> "..c, d)
                                end                            end
                            for c, d in ipairs(b) do
                                if d then
                                    --GameTooltip:AddDoubleLine(">> "..c, d)
                                end  
                            end
                        end
                    end
                    -- for a, b in ipairs(v) do
                    --     GameTooltip:AddDoubleLine("> "..a, b)
                    --     if type(b) == "table" then
                    --         for c, d in pairs(b) do
                    --             if d then
                    --                 GameTooltip:AddDoubleLine(">> "..c, d)
                    --             end                            end
                    --         for c, d in ipairs(b) do
                    --             if d then
                    --                 GameTooltip:AddDoubleLine(">> "..c, d)
                    --             end                           
                    --         end
                    --     end
                    -- end
                end
            end
        else
            GameTooltip:AddDoubleLine("-", elementData.tooltipTable)
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
    ['tsdb'] = "|cffF58CBA", --paladin
}

-- table to hold debug messages
Guildbook.DebugLog = {}

---add new debug message
---@param id string the type of debug, this also sets the colour used (func, comms_in, error, comms_out)
---@param func string the function name
---@param msg string the debug message to display
function Guildbook.DEBUG(id, func, msg, data)
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
