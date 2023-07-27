

local addonName, addon = ...;

local LOCALE = GetLocale()

local Tradeskills = {}
Tradeskills.TradeskillNames = {
    ["Alchemy"] = 171,
    ["Blacksmithing"] = 164,
    ["Enchanting"] = 333,
    ["Engineering"] = 202,
    ["Inscription"] = 773,
    ["Jewelcrafting"] = 755,
    ["Leatherworking"] = 165,
    ["Tailoring"] = 197,
    ["Mining"] = 186,
    ["Herbalism"] = 182,
    ["Skinning"] = 393,
    ["Cooking"] = 185,
	["FirstAid"] = 129,
	["First Aid"] = 129,
	["Fishing"] = 356,
}
Tradeskills.SpecializationSpellsIDs = {
    --Alchemy:
    [28672] = 171,
    [28677] = 171,
    [28675] = 171,
    --Engineering:
    [20222] = 202,
    [20219] = 202,
    --Tailoring:
    [26798] = 197,
    [26797] = 197,
    [26801] = 197,
    --Blacksmithing:
    [9788] = 164,
    [17039] = 164,
    [17040] = 164,
    [17041] = 164,
    [9787] = 164,
    --Leatherworking:
    [10656] = 165,
    [10658] = 165,
    [10660] = 165,
}
function Tradeskills:TradeskillIDToAtlas(id)

	if id == 202 then
		return "Mobile-Enginnering";
	elseif id == 129 then
		return "Mobile-FirstAid";
	else
		return string.format("Mobile-%s", self.TradeskillIDsToLocaleName.enUS[id])
	end
end

Tradeskills.TradeskillIDsToLocaleName = {
	enUS = {
		[164] = "Blacksmithing",
		[165] = "Leatherworking",
		[171] = "Alchemy",
		[182] = "Herbalism",
		[185] = "Cooking",
		[186] = "Mining",
		[197] = "Tailoring",
		[202] = "Engineering",
		[333] = "Enchanting",
		[356] = "Fishing",
		[393] = "Skinning",
		[755] = "Jewelcrafting",
		[773] = "Inscription",
		[129] = "First Aid"
	},
	deDE = {
		[164] = "Schmiedekunst",
		[165] = "Lederverarbeitung",
		[171] = "Alchemie",
		--[171] = "Alchimie",
		[182] = "Kräuterkunde",
		[185] = "Kochkunst",
		[186] = "Bergbau",
		[197] = "Schneiderei",
		[202] = "Ingenieurskunst",
		[333] = "Verzauberkunst",
		[356] = "Angeln",
		[393] = "Kürschnerei",
		[755] = "Juwelenschleifen",
		[773] = "Inschriftenkunde",
		[129] = "Erste Hilfe",
	},
	frFR = {
		[164] = "Forge",
		[165] = "Travail du cuir",
		[171] = "Alchimie",
		[182] = "Herboristerie",
		[185] = "Cuisine",
		[186] = "Minage",
		[197] = "Couture",
		[202] = "Ingénierie",
		[333] = "Enchantement",
		[356] = "Pêche",
		[393] = "Dépeçage",
		[755] = "Joaillerie",
		[773] = "Calligraphie",
		[129] = "Secourisme",
	},
	esMX = {
		[164] = "Herrería",
		[165] = "Peletería",
		[171] = "Alquimia",
		[182] = "Herboristería",
		[185] = "Cocina",
		[186] = "Minería",
		[197] = "Sastrería",
		[202] = "Ingeniería",
		[333] = "Encantamiento",
		[356] = "Pesca",
		[393] = "Desuello",
		[755] = "Joyería",
		[773] = "Inscripción",
		[129] = "Primeros auxilios",
	},
	-- discovered this locale exists also maybe esAL ?
	esES = {
        [164] = "Herrería",
        [165] = "Peletería",
        [171] = "Alquimia",
        [182] = "Herboristería",
        [185] = "Cocina",
        [186] = "Minería",
        [197] = "Sastrería",
        [202] = "Ingeniería",
        [333] = "Encantamiento",
        [356] = "Pesca",
        [393] = "Desuello",
        [755] = "Joyería",
        [773] = "Inscripción",
		[129] = "Primeros auxilios",
    },
	ptBR = {
		[164] = "Ferraria",
		[165] = "Couraria",
		[171] = "Alquimia",
		[182] = "Herborismo",
		[185] = "Culinária",
		[186] = "Mineração",
		[197] = "Alfaiataria",
		[202] = "Engenharia",
		[333] = "Encantamento",
		[356] = "Pesca",
		[393] = "Esfolamento",
		[755] = "Joalheria",
		[773] = "Escrivania",
		[129] = "Primeiros Socorros",
	},
	ruRU = {
		[164] = "Кузнечное дело",
		[165] = "Кожевничество",
		[171] = "Алхимия",
		[182] = "Травничество",
		[185] = "Кулинария",
		[186] = "Горное дело",
		[197] = "Портняжное дело",
		[202] = "Инженерное дело",
		[333] = "Наложение чар",
		[356] = "Рыбная ловля",
		[393] = "Снятие шкур",
		[755] = "Ювелирное дело",
		[773] = "Начертание",
		[129] = "Первая помощь",
	},
	zhCN = {
		[164] = "锻造",
		[165] = "制皮",
		[171] = "炼金术",
		[182] = "草药学",
		[185] = "烹饪",
		[186] = "采矿",
		[197] = "裁缝",
		[202] = "工程学",
		[333] = "附魔",
		[356] = "钓鱼",
		[393] = "剥皮",
		[755] = "珠宝加工",
		[773] = "铭文",
		[129] = "急救",
	},
	zhTW = {
		[164] = "鍛造",
		[165] = "製皮",
		[171] = "鍊金術",
		[182] = "草藥學",
		[185] = "烹飪",
		[186] = "採礦",
		[197] = "裁縫",
		[202] = "工程學",
		[333] = "附魔",
		[356] = "釣魚",
		[393] = "剝皮",
		[755] = "珠寶設計",
		[773] = "銘文學",
		[129] = "急救", --Worked on PTR -Belrand
	},
	koKR = {
		[164] = "대장기술",
		[165] = "가죽세공",
		[171] = "연금술",
		[182] = "약초채집",
		[185] = "요리",
		[186] = "채광",
		[197] = "재봉술",
		[202] = "기계공학",
		[333] = "마법부여",
		[356] = "낚시",
		[393] = "무두질",
		[755] = "보석세공",
		[773] = "주문각인",
		[129] = "응급치료",
	},
}
Tradeskills.TradeskillLocaleNameToID = tInvert(Tradeskills.TradeskillIDsToLocaleName[LOCALE])
if LOCALE == "deDE" then
	Tradeskills.TradeskillLocaleNameToID["Alchimie"] = 171
end

function Tradeskills:IsTradeskill(tradeskillName, tradeskillID)
    if type(tradeskillName) == "string" then
        for id, name in pairs(self.TradeskillIDsToLocaleName[LOCALE]) do
            if name == tradeskillName then
                return true;
            end
        end
    else
        if type(tradeskillID) == "number" then
            for id, name in pairs(self.TradeskillIDsToLocaleName[LOCALE]) do
                if id == tradeskillID then
                    return true;
                end
            end
        end
    end
end

function Tradeskills:GetTradeskillIDFromEnglishName(tradeskill)
	return self.TradeskillNames[tradeskill]
end

function Tradeskills:GetTradeskillIDFromLocale(tradeskill)
	local englishName = self:GetEnglishNameFromTradeskillName(tradeskill)
	return self.TradeskillNames[englishName]
end

function Tradeskills:GetLocaleNameFromEnglish(tradeskill)
    local id = self.TradeskillNames[tradeskill]
    return self.TradeskillIDsToLocaleName[LOCALE][id];
end

function Tradeskills:GetLocaleNameFromID(id)
	if self.TradeskillIDsToLocaleName[LOCALE] then
		if self.TradeskillIDsToLocaleName[LOCALE][id] then
			return self.TradeskillIDsToLocaleName[LOCALE][id]
		end
	end
end

function Tradeskills:GetEnglishNameFromID(tradeskillID)
    if self.TradeskillIDsToLocaleName.enUS[tradeskillID] then
        return self.TradeskillIDsToLocaleName.enUS[tradeskillID];
    end
end

function Tradeskills:GetEnglishNameFromTradeskillName(tradeskillName)
    local tradeskillID = self.TradeskillLocaleNameToID[tradeskillName]
    if tradeskillID then
        local tradeskill = self:GetEnglishNameFromID(tradeskillID)
        return tostring(tradeskill);
    end
    return false;
end


addon.Tradeskills = Tradeskills;