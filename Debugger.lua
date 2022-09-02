--[==[

Copyright ©2022 Samuel Thomas Pain

The contents of this addon, excluding third-party resources, are
copyrighted to their authors with all rights reserved.

This addon is free to use and the authors hereby grants you the following rights:

1. 	You may make modifications to this addon for private use only, you
    may not publicize any portion of this addon.

2. 	Do not modify the name of this addon, including the addon folders.

3. 	This copyright notice shall be included in all copies or substantial
    portions of the Software.

All rights not explicitly addressed in this license are reserved by
the copyright holders.

]==]--

local _, Guildbook = ...

local Colours = Guildbook.Colours;

local debugTypeToClassColour = {
    ['error'] = CreateColor(0.77, 0.12, 0.23),
    ['func'] = Colours['HUNTER'],
    ['event'] = Colours['ROGUE'],
    ['comms_out'] = Colours['PALADIN'],
    ['comms_in'] = Colours['PALADIN'],
    ['db_func'] = Colours['PALADIN'],
    ['tsdb'] = Colours['PALADIN'],

    ["commsMixin"] = Colours['SHAMAN'],
    ["databaseMixin"] = Colours['DRUID'],
    ["characterMixin"] = Colours['WARLOCK'],
    ["rosterMixin"] = Colours['ROGUE'],
    ["calendarMixin"] = CreateColor({0, 255, 152}), --monk
    ["guildBankMixin"] = CreateColor({209,140,3}), --monk
}
GuildbookDebuggerListviewItemTemplateMixin = {}
function GuildbookDebuggerListviewItemTemplateMixin:Init(elementData)
    local r, g, b = debugTypeToClassColour[elementData.debugType]:GetRGB()

    self.background:SetColorTexture(r,g,b,0.2)
    self.timestamp:SetText(elementData.timestamp)
    self.blockName:SetText(string.format("[%s]", elementData.blockName))
    self.message:SetText(elementData.message)
    -- self:SetScript("OnEnter", function()
    --     GameTooltip:SetOwner(self, 'ANCHOR_LEFT', -20, 0)
    --     if elementData.tooltipTable and type(elementData.tooltipTable) == "table" then
    --         for k, v in pairs(elementData.tooltipTable) do
    --             if type(v) ~= "table" then
    --                 GameTooltip:AddDoubleLine("> "..k, v)
    --             else
    --                 for a, b in pairs(v) do
    --                     GameTooltip:AddDoubleLine("> "..a, b)
    --                     if type(b) == "table" then
    --                         for c, d in pairs(b) do
    --                             if d then
    --                                 GameTooltip:AddDoubleLine(">> "..c, d)
    --                             end                            end
    --                         for c, d in ipairs(b) do
    --                             if d then
    --                                 --GameTooltip:AddDoubleLine(">> "..c, d)
    --                             end  
    --                         end
    --                     end
    --                 end
    --                 -- for a, b in ipairs(v) do
    --                 --     GameTooltip:AddDoubleLine("> "..a, b)
    --                 --     if type(b) == "table" then
    --                 --         for c, d in pairs(b) do
    --                 --             if d then
    --                 --                 GameTooltip:AddDoubleLine(">> "..c, d)
    --                 --             end                            end
    --                 --         for c, d in ipairs(b) do
    --                 --             if d then
    --                 --                 GameTooltip:AddDoubleLine(">> "..c, d)
    --                 --             end                           
    --                 --         end
    --                 --     end
    --                 -- end
    --             end
    --         end
    --     else
    --         GameTooltip:AddDoubleLine("-", elementData.tooltipTable)
    --     end
    --     GameTooltip:Show()
    -- end)
    -- self:SetScript("OnLeave", function()
    --     GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    -- end)
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

Guildbook.DebugEventSelected = nil;

---add new debug message
---@param id string the type of debug, this also sets the colour used (func, comms_in, error, comms_out)
---@param func string the function name
---@param msg string the debug message to display
function Guildbook.DEBUG(id, func, msg, data)
    
    -- local ts = date("%T")
    -- if Guildbook.DebugEventSelected == nil then
    --     Guildbook.DebuggerWindow.listview.DataProvider:Insert({
    --         debugType = id,
    --         blockName = func,
    --         timestamp = ts,
    --         message = msg,
    --         tooltipTable = data,
    --     })
    -- else
    --     if Guildbook.DebugEventSelected == id then
    --         Guildbook.DebuggerWindow.listview.DataProvider:Insert({
    --             debugType = id,
    --             blockName = func,
    --             timestamp = ts,
    --             message = msg,
    --             tooltipTable = data,
    --         })
    --     end
    -- end
end


-- create the debugging window
Guildbook.DebuggerWindow = CreateFrame('FRAME', 'GuildbookDebugFrame', UIParent, "UIPanelDialogTemplate")
Guildbook.DebuggerWindow:SetPoint('CENTER', 0, 0)
Guildbook.DebuggerWindow:SetFrameStrata('DIALOG')
Guildbook.DebuggerWindow:SetSize(1000, 500)
Guildbook.DebuggerWindow:SetMovable(true)
Guildbook.DebuggerWindow:EnableMouse(true)
Guildbook.DebuggerWindow:RegisterForDrag("LeftButton")
Guildbook.DebuggerWindow:SetScript("OnDragStart", Guildbook.DebuggerWindow.StartMoving)
Guildbook.DebuggerWindow:SetScript("OnDragStop", Guildbook.DebuggerWindow.StopMovingOrSizing)
Guildbook.DebuggerWindow:SetScript("OnHide", function()

end)
-- _G['GuildbookDebugFrameClose']:SetScript('OnClick', function()

-- end)

Guildbook.DebuggerWindow.header = Guildbook.DebuggerWindow:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
Guildbook.DebuggerWindow.header:SetPoint('TOP', 0, -9)
Guildbook.DebuggerWindow.header:SetText('Guildbook Debug')

Guildbook.DebuggerWindow:SetScript("OnUpdate", function()
    Guildbook.DebuggerWindow.header:SetText(string.format("Guildbook Debug %s", date("%H:%M:%S", time())))
end)

Guildbook.DebuggerWindow.EventSelectionDropdown = CreateFrame("FRAME", "GuildbookDebugEventSelectionDropdown", Guildbook.DebuggerWindow, "GuildbookDropdown")
Guildbook.DebuggerWindow.EventSelectionDropdown:SetPoint("TOPLEFT", 16, -30)
Guildbook.DebuggerWindow.EventSelectionDropdown.menu = {
    {
        text = "Comms",
        func = function()
            Guildbook.DebugEventSelected = "commsMixin";
        end,
    },
    {
        text = "Database",
        func = function()
            Guildbook.DebugEventSelected = "databaseMixin";
        end,
    },
    {
        text = "Calendar",
        func = function()
            Guildbook.DebugEventSelected = "calendarMixin";
        end,
    },
    {
        text = "Roster",
        func = function()
            Guildbook.DebugEventSelected = "rosterMixin";
        end,
    },
    {
        text = "Character",
        func = function()
            Guildbook.DebugEventSelected = "characterMixin";
        end,
    },
    {
        text = "Guild bank",
        func = function()
            Guildbook.DebugEventSelected = "guildBankMixin";
        end,
    },
    {
        text = "All events",
        func = function()
            Guildbook.DebugEventSelected = nil;
        end,
    },
}

Guildbook.DebuggerWindow.listview = CreateFrame("FRAME", nil, Guildbook.DebuggerWindow, "GuildbookDebuggerListviewTemplate")
Guildbook.DebuggerWindow.listview:SetPoint("BOTTOMLEFT", 10, 10)
Guildbook.DebuggerWindow.listview:SetPoint("TOPRIGHT", -10, -60)

Guildbook.DebuggerWindow:Hide()




