

local name, addon = ...;

local Database = addon.Database;
local L = addon.Locales;
local Character = addon.Character;
local Talents = addon.Talents;
local json = LibStub('JsonLua-1.0');

GuildbookImportExportMixin = {
    name = "Export", --apparently "ImportExport" didn't work? name conflict maybe
}

function GuildbookImportExportMixin:OnLoad()

    self.importExportEditbox.EditBox:SetMaxLetters(1000000000)
    self.importExportEditbox.CharCount:SetShown(true);
    self.importExportEditbox.EditBox:ClearAllPoints()
    self.importExportEditbox.EditBox:SetPoint("TOPLEFT", self.importExportEditbox, "TOPLEFT", 0, 0)
    self.importExportEditbox.EditBox:SetPoint("BOTTOMRIGHT", self.importExportEditbox, "BOTTOMRIGHT", 0, 0)
    self.importExportEditbox.ScrollBar:ClearAllPoints()
    self.importExportEditbox.ScrollBar:SetPoint("TOPRIGHT", self.importExportEditbox, "TOPRIGHT", 4, 0)
    self.importExportEditbox.ScrollBar:SetPoint("BOTTOMRIGHT", self.importExportEditbox, "BOTTOMRIGHT", 0, -4)

    -- self.importExportEditbox:SetScript("OnMouseDown", function(eb)
    --     eb.EditBox:HighlightText()
    -- end)

    self.importExportEditbox.EditBox:SetScript("OnTextChanged", function(eb)

        -- local str = eb:GetText()
        -- local ok, ret = pcall(json.decode, str)
        -- if ok then
        --     self:ImportEightyUpgrades(ret)
        -- end
    end)
    
    self.importData:SetScript("OnClick", function()
        
        local text = self.importExportEditbox.EditBox:GetText()

        local success, import = pcall(json.decode, text)
      
        if success then
            self:ImportEightyUpgrades(import)

        else
            self:SetImportFailed()
        end

    end)

    addon:RegisterCallback("SetExportString", self.SetExportString, self)
    addon:RegisterCallback("Guildbook_OnExport", self.Guildbook_OnExport, self)
    addon:RegisterCallback("Character_ExportEquipment", self.Character_ExportEquipment, self)
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)

    addon.AddView(self)
end

function GuildbookImportExportMixin:SetExportString(string)
    self.importExportEditbox.EditBox:SetText(string)

    GuildbookUI:SelectView(self.name)
end

function GuildbookImportExportMixin:Guildbook_OnExport(data)

    if type(data) == "table" then
        local export = json.encode(data)
        self.importExportEditbox.EditBox:SetText(export)

        GuildbookUI:SelectView(self.name)
    end
end


function GuildbookImportExportMixin:OnShow()
    self:UpdateLayout()
    self.confirmImport:Hide()
end

function GuildbookImportExportMixin:UpdateLayout()
    local x, y = self:GetSize()
    self.importExportEditbox:ClearAllPoints()
    self.importExportEditbox:SetPoint("TOPRIGHT", self, "TOPRIGHT", -12, -12)
    self.importExportEditbox:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -12, 12)
    self.importExportEditbox:SetWidth(x - 300)
    self.importExportEditbox.EditBox:SetWidth(x - 300)
end


function GuildbookImportExportMixin:SetImportFailed()
    self.importExportEditbox.EditBox:SetText("")
    self.importInfo:SetText("No Data Found!")
end




local eightySlotMapping = {
    ["RANGEDSLOT"] = "RANGED",
    ["SHIRTSLOT"] = "SHIRT",
    ["MAINHANDSLOT"] = "MAIN_HAND",
    ["HANDSSLOT"] = "HANDS",
    ["TRINKET0SLOT"] = "TRINKET_1",
    ["WAISTSLOT"] = "WAIST",
    ["FEETSLOT"] = "FEET",
    ["TABARDSLOT"] = "TABARD",
    ["NECKSLOT"] = "NECK",
    ["WRISTSLOT"] = "WRISTS",
    ["LEGSSLOT"] = "LEGS",
    ["TRINKET1SLOT"] = "TRINKET_2",
    ["SECONDARYHANDSLOT"] = "OFF_HAND",
    ["BACKSLOT"] = "BACK",
    ["FINGER0SLOT"] = "FINGER_1",
    ["CHESTSLOT"] = "CHEST",
    ["FINGER1SLOT"] = "FINGER_2",
    ["HEADSLOT"] = "HEAD",
    ["SHOULDERSLOT"] = "SHOULDERS",
}

function GuildbookImportExportMixin:Character_ExportEquipment(character, setName, spec)
    
    if character.data and character.data.inventory[setName] then
        
        if type(character.data.inventory[setName][1]) == "number" then

            self.importExportEditbox.EditBox:SetText(string.format("Unable to export [%s] as this set only contains itemID info not item links", setName))

            
        else

            local export = {
                name = setName,
                character = {
                    name = character.data.name,
                    level = character.data.level,
                    gameClass = select(2, GetClassInfo(character.data.class)),
                    race = character:GetRace().raceName:upper(),
                },
                items = {},
                talents = {},
                glyphs = {},
            }

            local breakLink = function(link)
                return string.match(link, [[|H([^:]*):([^|]*)|h(.*)|h]])
            end

            for slotName, itemLink in pairs(character.data.inventory[setName]) do

                if itemLink then
                    local gems = {}
                    local x, payload = breakLink(itemLink)

                    local itemID, enchantID, gem1, gem2, gem3 = strsplit(":", payload)
                    gems[1] = gem1
                    gems[2] = gem2
                    gems[3] = gem3

--                    print(itemID, enchantID, gem1, gem2, gem3)

                    if x == "item" then
                        
                        local item = {
                            id = itemID,
                            slot = eightySlotMapping[slotName],
                        }

                        if enchantID and (enchantID ~= "") then
                            item.enchant = {
                                id = enchantID,
                            }
                        end

                        for i = 1, 3 do
                            if gems[i] and (gems[i] ~= "") then
                                if not item.gems then
                                    item.gems = {}
                                end
                                table.insert(item.gems, {
                                    id = gems[i],
                                })
                            end
                        end

                        table.insert(export.items, item)

                    end

                end
                
            end

            if not spec then
                spec = "primary";
                print("Using primary spec as none provided")
            end

            if character.data.talents[spec] then
                for k, talent in ipairs(character.data.talents[spec]) do                    
                    if talent.rank > 0 then
                        local talentID = Talents:GetTalentID(talent.spellId)
                        if type(talentID) == "number" then
                            table.insert(export.talents, {
                                id = talentID,
                                rank = talent.rank,
                            })
                        end
                    end
                end
            end

            if character.data.glyphs[spec] then
                for k, glyph in ipairs(character.data.glyphs[spec]) do
                    if glyph.itemID and glyph.glyphType then
                        table.insert(export.glyphs, {
                            id = glyph.itemID,
                            type = (glyph.glyphType == 1) and "MINOR" or "MAJOR";
                        })
                    end
                end
            end

            --local normalYellowHex = "|cffFFD100"
            local specInfo = character:GetSpecInfo()
            local specName = ""
            if specInfo[spec] then
                local tabIndex = specInfo[spec][1].id;
                if tabIndex then
                    specName = Talents:GetSpecInfoFromClassTabIndex(character.data.class, tabIndex-1).name
                end
            end

            self.importInfo:SetText(string.format("|cffFFD10080 Upgrades Export Data:\n\nCharacter:|r %s|r\n\n|cffFFD100Class:|r %s\n\n|cffFFD100Talents:|r %s [%s]\n\n|cffFFD100Equipment set:|r %s", character:GetName(true), export.character.gameClass, specName, spec, setName))

            export = json.encode(export)
            self.importExportEditbox.EditBox:SetText(export)
        end
    end

    GuildbookUI:SelectView(self.name)
end







function GuildbookImportExportMixin:ImportEightyUpgrades(import)
    if import.character and import.items then
        -- if import.links.set:find("https://eightyupgrades.com/set") then
        --     self.importInfo:SetText(string.format("EightUpgrades\n\n%s\n%s\n%s", import.name, import.phase, import.character.name))
        -- end

        local outString = string.format("|cffFFD100Eighty Upgrades\n\nCharacter:|r %s\n\n|cffFFD100Set Name:|r %s\n\n|cffFFD100Items:|r", import.character.name, import.name)

        for k, v in ipairs(import.items) do
            
            local itemString = "%s|Hitem:%d:%s:%s:%s:%s:::::::::::::::|h[%s]|h|r"

            local enchantID = ""
            local gems = {"", "", ""}
            
            if v.enchant then
                enchantID = v.enchant.id;
            end

            if v.gems then
                for a, b in ipairs(v.gems) do
                    gems[a] = b.id
                end
            end

            if type(v.id) == "number" then
                local item = Item:CreateFromItemID(v.id)
                if not item:IsItemEmpty() then
                    item:ContinueOnItemLoad(function()
                        
                        local quality = item:GetItemQualityColor().hex;

                        local link = string.format(itemString, quality, v.id, enchantID, gems[1], gems[2], gems[3], v.name)

                        outString = string.format("%s\n%s", outString, link)

                        self.importInfo:SetText(outString)

                    end)
                end
            end

        end

        --self.confirmImport:Show()
    end
end

