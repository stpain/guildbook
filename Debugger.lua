

_, Guildbook = ...


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
    for i = 1, 40 do
        Guildbook.DebuggerWindow.Listview[i]:Hide()
    end
    if func and msg then
        table.insert(Guildbook.DebugLog, {
            msg = string.format("%s [%s%s|r], %s", date("%T"), Guildbook.DebugColours[id], func, msg),
            data = data,
        })
    end
    if Guildbook.DebugLog and next(Guildbook.DebugLog) then
        local i = #Guildbook.DebugLog - 39
        if i < 1 then
            i = 1
        end
        Guildbook.DebuggerWindow.ScrollBar:SetMinMaxValues(1, i)
        Guildbook.DebuggerWindow.ScrollBar:SetValue(i)
        C_Timer.After(0, function()
            for i = 1, 40 do
                Guildbook.DebuggerWindow.Listview[i]:Show()
            end
        end)
    end
end


-- create the debugging window
Guildbook.DebuggerWindow = CreateFrame('FRAME', 'GuildbookDebugFrame', UIParent, "UIPanelDialogTemplate")
Guildbook.DebuggerWindow:SetPoint('CENTER', 0, 0)
Guildbook.DebuggerWindow:SetFrameStrata('HIGH')
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

Guildbook.DebuggerWindow.Listview = {}
for i = 1, 40 do
    local f = CreateFrame('BUTTON', tostring('SRBLP_LogsListview'..i), Guildbook.DebuggerWindow)
    f:SetPoint('TOPLEFT', Guildbook.DebuggerWindow, 'TOPLEFT', 8, (i * -12) -18)
    f:SetPoint('TOPRIGHT', Guildbook.DebuggerWindow, 'TOPRIGHT', -8, (i * -12) -18)
    f:SetHeight(12)
    f:SetHighlightTexture("Interface/QuestFrame/UI-QuestLogTitleHighlight","ADD")
    f:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
    f.Message = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    f.Message:SetPoint('LEFT', 8, 0)
    f.Message:SetSize(780, 20)
    f.Message:SetJustifyH('LEFT')
    f.Message:SetTextColor(1,1,1,1)
    f.info = nil
    f:SetScript('OnShow', function(self)
        if self.info and self.info.msg then
            self.Message:SetText(self.info.msg)
        else
            self:Hide()
        end
    end)
    f:SetScript('OnEnter', function(self)
        if self.info and self.info.data and type(self.info.data) == "table" then
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            for k, v in ipairs(self.info.data) do
                GameTooltip:AddDoubleLine(k, v)
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
                                end                            end
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
                                end                            end
                        end
                    end
                end
            end
            for k, v in pairs(self.info.data) do
                GameTooltip:AddDoubleLine(k, v)
                if type(v) == "table" then
                    for a, b in pairs(v) do
                        GameTooltip:AddDoubleLine("> "..a, b)
                        if type(b) == "table" then
                            for c, d in pairs(b) do
                                if d then
                                    GameTooltip:AddDoubleLine(">> "..c, d)
                                end
                            end
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
                                end
                            end
                            for c, d in ipairs(b) do
                                if d then
                                    GameTooltip:AddDoubleLine(">> "..c, d)
                                end
                            end
                        end
                    end
                end
            end
            GameTooltip:Show()
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end
    end)
    f:SetScript('OnLeave', function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    f:SetScript('OnHide', function(self)
        self.Message:SetText(' ')
    end)
    f:SetScript('OnMouseWheel', function(self, delta)
        local s = Guildbook.DebuggerWindow.ScrollBar:GetValue()
        Guildbook.DebuggerWindow.ScrollBar:SetValue(s - delta)
    end)
    Guildbook.DebuggerWindow.Listview[i] = f
end

Guildbook.DebuggerWindow.ScrollBar = CreateFrame('SLIDER', 'GuildbookDebugFrameScrollBar', Guildbook.DebuggerWindow, "UIPanelScrollBarTemplate")
Guildbook.DebuggerWindow.ScrollBar:SetPoint('TOPLEFT', Guildbook.DebuggerWindow, 'TOPRIGHT', -24, -44)
Guildbook.DebuggerWindow.ScrollBar:SetPoint('BOTTOMRIGHT', Guildbook.DebuggerWindow, 'BOTTOMRIGHT', -8, 26)
Guildbook.DebuggerWindow.ScrollBar:EnableMouse(true)
Guildbook.DebuggerWindow.ScrollBar:SetValueStep(1)
Guildbook.DebuggerWindow.ScrollBar:SetValue(1)
Guildbook.DebuggerWindow.ScrollBar:SetMinMaxValues(1, 1)
Guildbook.DebuggerWindow.ScrollBar:SetScript('OnValueChanged', function(self)
    if Guildbook.DebugLog then
        local scrollPos = math.floor(self:GetValue())
        if scrollPos == 0 then
            scrollPos = 1
        end
        for i = 1, 40 do
            if Guildbook.DebugLog[(i - 1) + scrollPos] then
                Guildbook.DebuggerWindow.Listview[i]:Hide()
                Guildbook.DebuggerWindow.Listview[i].info = Guildbook.DebugLog[(i - 1) + scrollPos]
                Guildbook.DebuggerWindow.Listview[i]:Show()
            end
        end
    end
end)
