local name, addon = ...;

local L = addon.Locales
local Talents = addon.Talents;
local Database = addon.Database;
local Tradeskills = addon.Tradeskills;
local Character = addon.Character;
local Comms = addon.Comms;


local statsSchema = {
    {
        header = "attributes",
        stats = {
            { key = "Strength", displayName = L["STRENGTH"], },
            { key = "Agility", displayName = L["AGILITY"], },
            { key = "Stamina", displayName = L["STAMINA"], },
            { key = "Intellect", displayName = L["INTELLECT"], },
            { key = "Spirit", displayName = L["SPIRIT"], },
        },
    },
    {
        header = "defence",
        stats = {
            { key = "Armor", displayName = L["ARMOR"], },
            { key = "Defence", displayName = L["DEFENSE"], },
            { key = "Dodge", displayName = L["DODGE"], },
            { key = "Parry", displayName = L["PARRY"], },
            { key = "Block", displayName = L["BLOCK"], },
        },
    },
    {
        header = "melee",
        stats = {
            { key = "Expertise", displayName = L["EXPERTISE"], },
            { key = "MeleeHit", displayName = L["HIT_CHANCE"], },
            { key = "MeleeCrit", displayName = L["MELEE_CRIT"], },
            { key = "MeleeDmgMH", displayName = L["MH_DMG"], },
            { key = "MeleeDpsMH", displayName = L["MH_DPS"], },
            { key = "MeleeDmgOH", displayName = L["OH_DMG"], },
            { key = "MeleeDpsOH", displayName = L["OH_DPS"], },
        },
    },
    {
        header = "ranged",
        stats = {
            { key = "RangedHit", displayName = L["RANGED_HIT"], },
            { key = "RangedCrit", displayName = L["RANGED_CRIT"], },
            { key = "RangedDmg", displayName = L["RANGED_DMG"], },
            { key = "RangedDps", displayName = L["RANGED_DPS"], },
        },
    },
    {
        header = "spell",
        stats = {
            { key = "Haste", displayName = L["SPELL_HASTE"], },
            { key = "ManaRegen", displayName = L["MANA_REGEN"], },
            { key = "ManaRegenCasting", displayName = L["MANA_REGEN_CASTING"], },
            { key = "SpellHit", displayName = L["SPELL_HIT"], },
            { key = "SpellCrit", displayName = L["SPELL_CRIT"], },
            { key = "HealingBonus", displayName = L["HEALING_BONUS"], },
            { key = "SpellDmgHoly", displayName = L["SPELL_DMG_HOLY"], },
            { key = "SpellDmgFrost", displayName = L["SPELL_DMG_FROST"], },
            { key = "SpellDmgShadow", displayName = L["SPELL_DMG_SHADOW"], },
            { key = "SpellDmgArcane", displayName = L["SPELL_DMG_ARCANE"], },
            { key = "SpellDmgFire", displayName = L["SPELL_DMG_FIRE"], },
            { key = "SpellDmgNature", displayName = L["SPELL_DMG_NATURE"], },
        },
    },
}

local magicResistances = {
    {
        icon = 136222, --136116
        name = "arcane",
        id = 6,
    },
    {
        icon = 135813,
        name = "fire",
        id = 3,
    },
    {
        icon = 136074,
        name = "nature",
        id = 3,
    },
    {
        icon = 135849,
        name = "frost",
        id = 4,
    },
    {
        icon = 135945,
        name = "shadow",
        id = 5,
    },
}

GuildbookProfileMixin = {
    name = "Profile",
	helptips = {},
	selectedTalentSpec = 1;
}

function GuildbookProfileMixin:OnLoad()

    self.inventory.resistanceGridview:InitFramePool("FRAME", "GuildbookWrathEraResistanceFrame")
    self.inventory.resistanceGridview:SetFixedColumnCount(5)
    self.inventory.resistanceGridview.ScrollBar:Hide()

    for k, resistance in ipairs(magicResistances) do
        self.inventory.resistanceGridview:Insert({
            textureId = resistance.icon,
            resistanceId = resistance.id,
            resistanceName = resistance.name,
            type = "resistance",
        })
    end

    self.inventory.auraGridview:InitFramePool("FRAME", "GuildbookWrathEraResistanceFrame")
    self.inventory.auraGridview:SetFixedColumnCount(8)
    self.inventory.auraGridview.ScrollBar:Hide()

	self.talents.primarySpec:SetScript("OnClick", function()
		self.selectedTalentSpec = 1;
		self:LoadTalentsAndGlyphs()
	end)

	self.talents.secondarySpec:SetScript("OnClick", function()
		self.selectedTalentSpec = 2;
		self:LoadTalentsAndGlyphs()
	end)

    for i = 1, 3 do
        self.talents["tree"..i].talentsGridview:InitFramePool("FRAME", "GuildbookWrathEraTalentIconFrame")
        self.talents["tree"..i].talentsGridview:SetFixedColumnCount(4)

        C_Timer.After(0.1, function()
            for row = 1, 7 do
                for col = 1, 4 do
                    self.talents["tree"..i].talentsGridview:Insert({
                        rowId = row,
                        colId = col,
                    })
                end
            end
        end)
    end

    addon:RegisterCallback("Character_OnProfileSelected", self.LoadCharacter, self)
    addon:RegisterCallback("Character_OnDataChanged", self.Update, self)
    addon:RegisterCallback("UI_OnSizeChanged", self.UpdateLayout, self)
    addon:RegisterCallback("Profile_OnItemDataLoaded", self.UpdateItemLevel, self)

	self.sidePane.helptip:SetText(L.PROFILE_SIDEPANE_HT)
	self.inventory.equipmentHelptip:SetText(L.PROFILE_INVENTORY_HT)

	self.inventory.exportButton:SetScript("OnMouseDown", function()
		-- local spec;
		-- if self.selectedTalentSpec == 1 then
		-- 	spec = "primary"
		-- else
		-- 	spec = "secondary"
		-- end
		-- addon:TriggerEvent("Character_ExportEquipment", self.character, self.currentEquipmentSet, spec)

		local menu = addon.api.generateExportMenu(self.character)
		EasyMenu(menu, addon.contextMenu, "cursor", 0, 0, "MENU", 0.2)
	end)

	table.insert(self.helptips, self.sidePane.helptip)
	table.insert(self.helptips, self.inventory.equipmentHelptip)

	addon.AddView(self)

    self:UpdateLayout()
end

function GuildbookProfileMixin:Character_OnDataChanged(character)
    if self.character and (self.character.data.guid == character.data.guid) then
        self:Update()
    end
end

function GuildbookProfileMixin:LoadCharacter(character)
    self.character = character;
	self.currentEquipmentSet = "current"
    self.sidePane.background:SetAtlas(string.format("transmog-background-race-%s", self.character:GetRace().clientFileString:lower()))
	self.ignoreCharacterUpdates = false
    self:Update()
    GuildbookUI:SelectView(self.name)
    self.inventory:SetAlpha(0)
    self.inventory.anim:Play()
	self:LoadTalentsAndGlyphs()

	--request an update, this uses WHISPER channel comms and only if the player is online
	Comms:RequestCharacterData(character.data.name, "mainSpec")

	-- C_Timer.After(0.5, function()
	-- 	Comms:RequestCharacterData(character.data.name, "mainCharacter")
	-- end)
	C_Timer.After(1.0, function()
		Comms:RequestCharacterData(character.data.name, "inventory")
	end)
	C_Timer.After(2.0, function()
		Comms:RequestCharacterData(character.data.name, "talents")
	end)
	C_Timer.After(3.0, function()
		Comms:RequestCharacterData(character.data.name, "glyphs")
	end)
end

function GuildbookProfileMixin:UpdateLayout()
    local x, y = self:GetSize()

    local sidePaneWidth = x * 0.25

    self.sidePane:Show()
    self.sidePane:SetWidth(sidePaneWidth)
    self.inventory:SetWidth(x-sidePaneWidth)

    local statsWidth = ((x-sidePaneWidth) * 0.35)

    self.inventory.resistanceGridview:SetWidth(statsWidth)
    self.inventory.resistanceGridview:SetHeight(statsWidth / 5)

    local auraCount = 0
	if self.currentEquipmentSet then
		if self.character and self.character.data.auras[self.currentEquipmentSet] then
			auraCount = #self.character.data.auras[self.currentEquipmentSet] or 0;
		end
	else
		if self.character and self.character.data.auras.current then
			auraCount = #self.character.data.auras.current or 0;
		end
	end

    if auraCount == 0 then
        self.inventory.auraGridview:SetHeight(1)
    else
        local auraIconWidth = statsWidth / 8;
        local numRows = math.ceil(auraCount / 8)
        self.inventory.auraGridview:SetHeight(auraIconWidth * numRows)
    end


    self.talents:SetWidth(x-sidePaneWidth)

    for i = 1, 3 do
        self.talents["tree"..i]:SetWidth((x-sidePaneWidth) / 3)
        self.talents["tree"..i].talentsGridview:SetSize((x-sidePaneWidth) / 3, y)

		self.glyphs["prime"..i]:SetWidth((x-sidePaneWidth) / 3)
		self.glyphs["major"..i]:SetWidth((x-sidePaneWidth) / 3)
		self.glyphs["minor"..i]:SetWidth((x-sidePaneWidth) / 3)
    end


    if x < 600 then

        statsWidth = ((x-1) * 0.35);

        self.sidePane:SetWidth(1)
        self.sidePane:Hide()
        self.inventory:SetWidth(x-1)

        self.inventory.resistanceGridview:SetWidth(statsWidth)
        self.inventory.resistanceGridview:SetHeight(statsWidth / 5)

        if auraCount == 0 then
            self.inventory.auraGridview:SetHeight(1)
        else
            local auraIconWidth = statsWidth / 8;
            local numRows = math.ceil(auraCount / 8)
            self.inventory.auraGridview:SetHeight(auraIconWidth * numRows)
        end

        self.talents:SetWidth(x-1)
        for i = 1, 3 do
            self.talents["tree"..i]:SetWidth((x-1) / 3)
            self.talents["tree"..i].talentsGridview:SetSize((x-1) / 3, y)

			self.glyphs["prime"..i]:SetWidth((x-1) / 3)
			self.glyphs["major"..i]:SetWidth((x-1) / 3)
			self.glyphs["minor"..i]:SetWidth((x-1) / 3)
        end
    end

    self.inventory.resistanceGridview:UpdateLayout()
    self.inventory.auraGridview:UpdateLayout()

    self.talents.tree1.talentsGridview:UpdateLayout()
    self.talents.tree2.talentsGridview:UpdateLayout()
    self.talents.tree3.talentsGridview:UpdateLayout()
end


function GuildbookProfileMixin:UpdateItemLevel()

	self.inventory.gearScore:SetText("-")
	
	if self.currentEquipmentSet and self.character.data.inventory[self.currentEquipmentSet] and (type(self.character.data.inventory[self.currentEquipmentSet]) == "table") then

		-- local set = self.character.data.inventory[self.currentEquipmentSet]
		-- if set then
		-- 	local numItems, totalItemlevel = 0, 0;
		-- 	for i = 1, 19 do
		-- 		if (i ~= 4) and (i ~= 19) and type(set[i]) == "number" then
		-- 			local n, l, q, ilvl = GetItemInfo(set[i])

		-- 			if ilvl then
		-- 				numItems = numItems + 1;
		-- 				totalItemlevel = totalItemlevel + ilvl;

		-- 			end
		-- 		end
		-- 	end
		-- 	---print(numItems, totalItemlevel, (totalItemlevel / numItems))

		-- 	self.inventory.gearScore:SetText(string.format("Item Level: %0.2f", (totalItemlevel / numItems)))
		-- end
		local numItems, totalItemlevel = 0, 0;
		for slot, link in pairs(self.character.data.inventory[self.currentEquipmentSet]) do
			if slot ~= "TABARDSLOT" then
				if type(link) == "string" then
					local n, l, q, ilvl = GetItemInfo(link)

					if ilvl then
						numItems = numItems + 1;
						totalItemlevel = totalItemlevel + ilvl;

					end
				end

				self.inventory.gearScore:SetText(string.format("ilvl: %0.2f (set: %s)", (totalItemlevel / numItems), self.currentEquipmentSet))
			end
		end
		--print(numItems, totalItemlevel, (totalItemlevel / numItems))
	else
		if self.character and self.character.data.inventory.current then
			local numItems, totalItemlevel = 0, 0;
			for slot, link in pairs(self.character.data.inventory.current) do
				if slot ~= "TABARDSLOT" then
					if type(link) == "string" then
						local n, l, q, ilvl = GetItemInfo(link)
	
						if ilvl then
							numItems = numItems + 1;
							totalItemlevel = totalItemlevel + ilvl;
	
						end
					end
		
					self.inventory.gearScore:SetText(string.format("ilvl: %0.2f (set: current)", (totalItemlevel / numItems)))
				end
			end
			--print(numItems, totalItemlevel, (totalItemlevel / numItems))
		end
	end

	self.inventory.gearScore:SetAlpha(1)
end


function GuildbookProfileMixin:Update()

    if not self.character then
        return
    end

	local name, realm = strsplit("-", self.character.data.name)
    self.sidePane.name:SetText(string.format("%s\n[%s]", name, realm))

	if self.character.data.mainCharacter then
		self.sidePane.mainCharacter:SetText(string.format("(%s)", self.character.data.mainCharacter))
		self.sidePane.mainCharacter:SetHeight(16)
	else
		self.sidePane.mainCharacter:SetText("")
		self.sidePane.mainCharacter:SetHeight(1)
	end

	if self.character.data.achievementPoints then
		self.sidePane.achievementPoints:SetHeight(16)
		self.sidePane.achievementPoints:SetText(self.character.data.achievementPoints)
	else
		self.sidePane.achievementPoints:SetHeight(1)
		self.sidePane.achievementPoints:SetText("")
	end


	local localeSpec, engSpec, id = self.character:GetSpec("primary")
	local atlas = self.character:GetClassSpecAtlasName("primary")
	if engSpec then
    	self.sidePane.mainSpec:SetText(string.format("%s %s", CreateAtlasMarkup(atlas, 24, 24), engSpec))
	else
		self.sidePane.mainSpec:SetText(CreateAtlasMarkup(atlas, 24, 24))
	end

    self.sidePane.listview.DataProvider:Flush()
    
    if type(self.character.data.profession1) == "number" then
        self.sidePane.listview.DataProvider:Insert({
            atlas = Tradeskills:TradeskillIDToAtlas(self.character.data.profession1),
            label = string.format("%s [%d]", 
                Tradeskills:GetLocaleNameFromID(self.character.data.profession1), 
                self.character.data.profession1Level
            ),
            onMouseDown = function()
                addon:TriggerEvent("Character_OnTradeskillSelected", self.character.data.profession1, self.character.data.profession1Recipes)
            end,
        })
    end

    if type(self.character.data.profession2) == "number" then
        self.sidePane.listview.DataProvider:Insert({
            atlas = Tradeskills:TradeskillIDToAtlas(self.character.data.profession2),
            label = string.format("%s [%d]", 
                Tradeskills:GetLocaleNameFromID(self.character.data.profession2), 
                self.character.data.profession2Level
            ),
            onMouseDown = function()
                addon:TriggerEvent("Character_OnTradeskillSelected", self.character.data.profession2, self.character.data.profession2Recipes)
            end,
        })
    end

    self.sidePane.listview.DataProvider:Insert({
        atlas = Tradeskills:TradeskillIDToAtlas(185),
        label = string.format("%s [%d]", 
            Tradeskills:GetLocaleNameFromID(185), 
            self.character.data.cookingLevel
        ),
        onMouseDown = function()
            addon:TriggerEvent("Character_OnTradeskillSelected", 185, self.character.data.cookingRecipes)
        end,
    })

    self.sidePane.listview.DataProvider:Insert({
        atlas = Tradeskills:TradeskillIDToAtlas(129),
        label = string.format("%s [%d]", 
            Tradeskills:GetLocaleNameFromID(129), 
            self.character.data.firstAidLevel
        ),
        onMouseDown = function()
            addon:TriggerEvent("Character_OnTradeskillSelected", 129, self.character.data.firstAidRecipes)
        end,
    })

    self.sidePane.listview.DataProvider:Insert({
        atlas = Tradeskills:TradeskillIDToAtlas(356),
        label = string.format("%s [%d]", 
            Tradeskills:GetLocaleNameFromID(356), 
            self.character.data.fishingLevel
        ),
        onMouseDown = nil,
    })

    --inventory select button
    self.sidePane.listview.DataProvider:Insert({
        atlas = "Mobile-CombatIcon",
        label = L["EQUIPMENT"],
        onMouseDown = function()
            self.talents:Hide()
            self.glyphs:Hide()
            self.inventory:Show()
        end,
    })

    self.sidePane.listview.DataProvider:Insert({
        atlas = "Mobile-QuestIcon",
        label = L["TALENTS"], 
        onMouseDown = function()
            self.inventory:Hide()
            self.talents:Show()
            self.glyphs:Show()
        end,
    })

	local alts = Database:GetCharacterAlts(self.character.data.mainCharacter)
	--DevTools_Dump(alts)
	if alts and #alts > 0 then
		for k, name in ipairs(alts) do
			--print("adding alt to profile", name)
			if addon.characters[name] then
				self.sidePane.listview.DataProvider:Insert({
					atlas = addon.characters[name]:GetProfileAvatar(),
					label = Ambiguate(addon.characters[name]:GetName(true), "short"), 
					onMouseDown = function()
						self:LoadCharacter(addon.characters[name])
					end,
					showMask = true
				})
			end
		end
	end


    local _, class = GetClassInfo(self.character.data.class);
    
    self.inventory.equipmentListview.background:SetAtlas(string.format("dressingroom-background-%s", class:lower()))
    self.inventory.statsListview.background:SetAtlas(string.format("UI-Character-Info-%s-BG", class:lower()))

	if not self.ignoreCharacterUpdates then
		self.inventory.equipmentListview.DataProvider:Flush()

		local t = {}
		for k, v in ipairs(addon.data.inventorySlots) do
			if self.character.data.inventory.current and self.character.data.inventory.current[v.slot] then
				self.inventory.equipmentListview.DataProvider:Insert({
					label = self.character.data.inventory.current[v.slot],
					icon = v.icon,
					link = self.character.data.inventory.current[v.slot],

					labelRight = C_Item.GetDetailedItemLevelInfo(self.character.data.inventory.current[v.slot]),

					onMouseDown = function()
						if IsControlKeyDown() then
							DressUpItemLink(self.character.data.inventory.current[v.slot])
						elseif IsShiftKeyDown() then
							HandleModifiedItemClick(self.character.data.inventory.current[v.slot])
						end
					end,
				})
			else
				self.inventory.equipmentListview.DataProvider:Insert({
					label = "-",
					icon = v.icon,
				})
			end
		end
	end

	self:LoadEquipmentSetInfo("current")
	self:UpdateItemLevel()
	self:LoadTalentsAndGlyphs()

	self.currentEquipmentSet = "current"
	--equipment sets
	if self.character.data.inventory then
		local equipmentSetNames = {}
		for name, itemIDs in pairs(self.character.data.inventory) do
			--if name ~= "current" then
				table.insert(equipmentSetNames, {
					text = name,
					func = function()

						self.ignoreCharacterUpdates = true;
						self.currentEquipmentSet = name;

						self:UpdateItemLevel()

						self:LoadEquipmentSetInfo(name)

						self.inventory.equipmentListview.DataProvider:Flush() --getItemInfoFromID

						for k, v in ipairs(addon.data.inventorySlots) do
							if self.character.data.inventory[name] and self.character.data.inventory[name][v.slot] then
								self.inventory.equipmentListview.DataProvider:Insert({
									label = self.character.data.inventory[name][v.slot],
									icon = v.icon,
									link = self.character.data.inventory[name][v.slot],
									labelRight = C_Item.GetDetailedItemLevelInfo(self.character.data.inventory[name][v.slot]),
									--backgroundAlpha = 0.6,
									onMouseDown = function()
										if IsControlKeyDown() then
											DressUpItemLink(self.character.data.inventory[name][v.slot])
										elseif IsShiftKeyDown() then
											HandleModifiedItemClick(self.character.data.inventory[name][v.slot])
										end
									end,
								})
							else
								self.inventory.equipmentListview.DataProvider:Insert({
									label = "-",
									icon = v.icon,
								})
							end
						end

						--[[
							with a change to wrath including the gear manager the initial method here was to just grab itemIDs via Bliz api
							however this does not allow for item links so enchant data is missing

							a change was made to the equipment scan that means the addon now grabs item links just after an equipment set was changed/swapped
						]]

						--[[
						if name == "current" then
							for k, v in ipairs(addon.data.inventorySlots) do
								if self.character.data.inventory.current[v.slot] then
									self.inventory.equipmentListview.DataProvider:Insert({
										label = self.character.data.inventory.current[v.slot],
										icon = v.icon,
										link = self.character.data.inventory.current[v.slot],
										--backgroundAlpha = 0.6,
										onMouseDown = function()
											if IsControlKeyDown() then
												DressUpItemLink(self.character.data.inventory.current[v.slot])
											elseif IsShiftKeyDown() then
												HandleModifiedItemClick(self.character.data.inventory.current[v.slot])
											end
										end,
									})
								else
									self.inventory.equipmentListview.DataProvider:Insert({
										label = "-",
										icon = v.icon,
									})
								end
							end

						else

							for i = 1, 19 do

								local icon, atlas = nil, "QuestArtifactTurnin"
								if addon.data.inventorySlots[i] then
									icon = addon.data.inventorySlots[i].icon
									atlas = nil
								end
								
								if type(itemIDs[i]) == "number" then

									self.inventory.equipmentListview.DataProvider:Insert({
										label = "-",
										--backgroundAlpha = 0.6,
										getItemInfoFromID = true,
										itemID = itemIDs[i],
										icon = icon,
										atlas = atlas
									})
								-- elseif type(itemIDs[i]) == "string" and itemIDs[i]:find("|Hitem") then
								-- 	self.inventory.equipmentListview.DataProvider:insert({
								-- 		label = itemIDs[i],
								-- 		icon = icon,
								-- 		atlas = atlas,
								-- 		link = itemIDs[i],
						
								-- 		onMouseDown = function()
								-- 			if IsControlKeyDown() then
								-- 				DressUpItemLink(itemIDs[i])
								-- 			elseif IsShiftKeyDown() then
								-- 				HandleModifiedItemClick(itemIDs[i])
								-- 			end
								-- 		end,
								-- 	})
								else
									self.inventory.equipmentListview.DataProvider:Insert({
										label = "-",
										icon = icon,
										atlas = atlas
									})
								end
							end

						end
						]]

					end,
				})
			--end
		end

		self.inventory.equipmentMenu:SetMenu(equipmentSetNames)
	end

	self:UpdateLayout()
end

function GuildbookProfileMixin:LoadTalentsAndGlyphs()

	-- local mainSpec = self.character:GetClassSpecAtlasName("primary")
	-- if mainSpec then
	-- 	self.talents.primarySpec.icon:SetAtlas(mainSpec)
	-- end
	-- local offSpec = self.character:GetClassSpecAtlasName("secondary")
	-- if offSpec then
	-- 	self.talents.secondarySpec.icon:SetAtlas(offSpec)
	-- end


	--sometimes the player might have leveled with a dps spec and set secondary as a tank/healer role btu intend to use that as a main
	--this can result in the spec being reversed
	--this should resolve the issue by using talent points spent to calculate spec (for wrath anyways)
	if self.character then
		local specInfo = self.character:GetSpecInfo()

		if specInfo then

			local primarySpec, secondarySpec = specInfo.primary[1].id, specInfo.secondary[1].id

			if primarySpec then
				self.talents.primarySpec.icon:SetAtlas(self.character:GetClassSpecAtlasName(primarySpec))
			end

			if secondarySpec then
				self.talents.secondarySpec.icon:SetAtlas(self.character:GetClassSpecAtlasName(secondarySpec))
			end

		end

	end

	local spec;
	if self.selectedTalentSpec == 1 then
		spec = "primary"
	else
		spec = "secondary"
	end


	--talents
	local artwork = Talents:GetClassTalentTreeArtwork(self.character.data.class)
	self.talents.tree1.background:SetTexture(artwork[1])
	self.talents.tree2.background:SetTexture(artwork[2])
	self.talents.tree3.background:SetTexture(artwork[3])

	local talentTress = {
		[1] = {},
		[2] = {},
		[3] = {},
	}

	for i = 1, 3 do
		self.talents["tree"..i].talentsGridview.ScrollBar:Hide()
		for k, frame in ipairs(self.talents["tree"..i].talentsGridview:GetFrames()) do
			frame:ClearTalent()
		end
		self.glyphs["prime"..i]:SetText("-")
		self.glyphs["major"..i]:SetText("-")
		self.glyphs["minor"..i]:SetText("-")
	end

	if self.character.data.talents[spec] then
		if type(self.character.data.talents[spec]) == "table" then
			for k, v in ipairs(self.character.data.talents[spec]) do

				for i = 1, 3 do
					if v.tabID == i then
						if not talentTress[i][v.row] then
							talentTress[i][v.row] = {}
						end
						talentTress[i][v.row][v.col] = v
					end
				end
			end

			for i = 1, 3 do
				for k, frame in ipairs(self.talents["tree"..i].talentsGridview:GetFrames()) do
					if talentTress[i][frame.rowId][frame.colId] then
						frame:SetTalent(talentTress[i][frame.rowId][frame.colId])
					else
						frame:ClearTalent()
					end
				end
			end


			--new cata talents strings
		elseif type(self.character.data.talents[spec]) == "string" then

			local tabs = {strsplit("-", self.character.data.talents[spec])}

			local pointsSpent = {
				{ id = 1, points = 0 },
				{ id = 2, points = 0 },
				{ id = 3, points = 0 },
			}
		
			--loop the data and add the points spent per tree
			--then apply a simple sort allowing us to access the tree in the correct order
			for k, tab in ipairs(tabs) do
				if tab and (#tab > 0) then
					local tbl = {string.byte(tab, 1, #tab)}
					for i = 1, #tbl do
						local c = tonumber(string.char(tbl[i]))
						if c then
							pointsSpent[k].points = pointsSpent[k].points + c
						end
					end
				end
			end
		
			

		end
	end

	if self.character.data.glyphs and (type(self.character.data.glyphs[spec]) == "table") then
		
		--local major, minor, prime = 1, 1, 1;
		for k, v in ipairs(self.character.data.glyphs[spec]) do

			if v.spellID and v.glyphIndex and v.glyphType then
				local glyph = GetSpellInfo(v.spellID)

				if v.glyphType == 3 then
					self.glyphs["prime"..v.glyphIndex+1]:SetText(glyph)
					--prime = prime + 1;
	
				elseif v.glyphType == 2 then
					self.glyphs["major"..v.glyphIndex+1]:SetText(glyph)
					--major = major + 1;
	
				elseif v.glyphType == 1 then
					self.glyphs["minor"..v.glyphIndex+1]:SetText(glyph)
					--minor = minor + 1;
	
				end
			end
		end
	end

end

function GuildbookProfileMixin:LoadEquipmentSetInfo(setName)

	self.ignoreCharacterUpdates = true

	-- print("+=+=+=+=")
	-- print("loading set", setName)

	--resistances
	for k, frame in ipairs(self.inventory.resistanceGridview:GetFrames()) do
		--DevTools_Dump(frame)
		frame.label:SetText("?")
		if self.character.data.resistances[setName] and self.character.data.resistances[setName][frame.resistanceName] then
			--print("got res data")
			local res = self.character.data.resistances[setName][frame.resistanceName]
			if res and res.total and res.base and res.bonus then
				frame.label:SetText(res.total)
				frame:SetScript("OnEnter", function()
					GameTooltip:SetOwner(self.inventory.resistanceGridview, "ANCHOR_TOPRIGHT")
					GameTooltip:AddLine(string.format("%s Resistance: |cffffffff%d (%d |cff009900+ %d|r)", frame.resistanceName:gsub("^%l", string.upper), res.total, res.base, res.bonus))
					GameTooltip:Show()
				end)
				frame:SetScript("OnLeave", function()
					GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
				end)
			else

			end
		end
	end


	--auras
	self.inventory.auraGridview:Flush()
	local auras = self.character.data.auras[setName];
	--DevTools_Dump(auras)
	if auras and (#auras > 0) then
		--print("got aura data")
		for k, aura in ipairs(auras) do
			local name, rank, icon = GetSpellInfo(aura.spellId)
			--print(name, icon)
			self.inventory.auraGridview:Insert({
				textureId = icon,
				label = "",
				onEnter = function()
					GameTooltip:SetOwner(self.inventory.auraGridview, "ANCHOR_TOPRIGHT")
					GameTooltip:SetSpellByID(aura.spellId)
					GameTooltip:Show()
				end
			})
		end
	end


	self.inventory.statsListview.DataProvider:Flush()
	if self.character.data.paperDollStats[setName] and self.character.data.paperDollStats[setName].attributes then
		local stats = {}

		--print("got stats data")

		for k, statGroup in ipairs(statsSchema) do
			table.insert(stats, {
				isHeader = true,
				label = L[statGroup.header],
			})
			for i, v in ipairs(statGroup.stats) do
				local statValue = self.character.data.paperDollStats[setName][statGroup.header][v.key]
				if type(statValue) == "table" then
					if statValue and statValue.Base and statValue.Mod then
						table.insert(stats, {
							isHeader = false,
							label = string.format("%s %s", v.displayName, statValue.Base + statValue.Mod),
							showBounce = ((i % 2) == 0) and true or false,
						})
					end
				else
					table.insert(stats, {
						isHeader = false,
						label = string.format("%s %s", v.displayName, statValue or "-"),
						showBounce = ((i % 2) == 0) and true or false,
					})
				end
			end
		end
		self.inventory.statsListview.DataProvider:InsertTable(stats)
	end

	self:UpdateLayout()
end