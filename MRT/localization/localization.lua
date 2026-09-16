local GlobalAddonName, ExRT = ...

local localization = ExRT.L
ExRT.Ldef = localization

ExRT.L = setmetatable({}, {__index=function (t, k)
	return localization[k] or k
end})


local L = localization

local GetClassInfo,GetSpecializationInfoByID,EJ_GetEncounterInfo,EJ_GetInstanceInfo = GetClassInfo,GetSpecializationInfoByID,EJ_GetEncounterInfo,EJ_GetInstanceInfo

if ExRT.isClassic then
	GetClassInfo = ExRT.Classic.GetClassInfo
	EJ_GetEncounterInfo = ExRT.NULLfunc
	EJ_GetInstanceInfo = ExRT.NULLfunc
	GetSpecializationInfoByID = GetSpecializationInfoForSpecID or ExRT.Classic.GetSpecializationInfoByID

	if not EXPANSION_NAME7 then EXPANSION_NAME7 = "BFA" end
	if not EXPANSION_NAME8 then EXPANSION_NAME8 = "Shadowlands" end
	if not EXPANSION_NAME9 then EXPANSION_NAME9 = "DF" end
	if not EXPANSION_NAME10 then EXPANSION_NAME10 = "TWW" end
	if not TOOLTIP_AZERITE_UNLOCK_LEVELS then TOOLTIP_AZERITE_UNLOCK_LEVELS = "" end
end


local classLocalizate = {
	["WARRIOR"] = GetClassInfo(1),
	["PALADIN"] = GetClassInfo(2),
	["HUNTER"] = GetClassInfo(3),
	["ROGUE"] = GetClassInfo(4),
	["PRIEST"] = GetClassInfo(5),
	["DEATHKNIGHT"] = GetClassInfo(6),
	["SHAMAN"] = GetClassInfo(7),
	["MAGE"] = GetClassInfo(8),
	["WARLOCK"] = GetClassInfo(9),
	["DRUID"] = GetClassInfo(11),
	["PET"] = PETS,
	["NO"] = SPECIAL,
	["ALL"] = ALL_CLASSES,
}
L.classLocalizate = setmetatable({}, {__index=function (t, k)
	return classLocalizate[k] or k
end})


local specCodeToID = {
	["MAGEDPS1"] = 62,
	["MAGEDPS2"] = 63,
	["MAGEDPS3"] = 64,
	["PALADINHEAL"] = 65,
	["PALADINTANK"] = 66,
	["PALADINDPS"] = 70,
	["WARRIORDPS1"] = 71,
	["WARRIORDPS2"] = 72,
	["WARRIORTANK"] = 73,
	["DRUIDDPS1"] = 102,
	["DRUIDDPS2"] = 103,
	["DRUIDHEAL"] = 105,
	["DEATHKNIGHTTANK"] = 250,
	["DEATHKNIGHTDPS1"] = 251,
	["DEATHKNIGHTDPS2"] = 252,
	["HUNTERDPS1"] = 253,
	["HUNTERDPS2"] = 254,
	["HUNTERDPS3"] = 255,
	["PRIESTHEAL1"] = 256,
	["PRIESTHEAL2"] = 257,
	["PRIESTDPS"] = 258,
	["ROGUEDPS1"] = 259,
	["ROGUEDPS2"] = 260,
	["ROGUEDPS3"] = 261,
	["SHAMANDPS1"] = 262,
	["SHAMANDPS2"] = 263,
	["SHAMANHEAL"] = 264,
	["WARLOCKDPS1"] = 265,
	["WARLOCKDPS2"] = 266,
	["WARLOCKDPS3"] = 267,
}

local specLocalizate = {
	["NO"] = ALL_SPECS or ALL or "All",
}
for specCode,specID in pairs(specCodeToID) do
	if GetSpecializationInfoByID then
		local _,specName = GetSpecializationInfoByID(specID)
		specLocalizate[specCode] = specName
	end
end

L.specLocalizate = setmetatable({}, {__index=function (t, k)
	return specLocalizate[k] or k
end})


L.raidtargeticon1_eng = "{star}"
L.raidtargeticon2_eng = "{circle}"
L.raidtargeticon3_eng = "{diamond}"
L.raidtargeticon4_eng = "{triangle}"
L.raidtargeticon5_eng = "{moon}"
L.raidtargeticon6_eng = "{square}"
L.raidtargeticon7_eng = "{cross}"
L.raidtargeticon8_eng = "{skull}"

for i=1,8 do
	L['raidtargeticon'..i] = "{"..(_G['RAID_TARGET_'..i]:lower()).."}"
end


L.raidtargeticon1_de = "{stern}"
L.raidtargeticon2_de = "{kreis}"
L.raidtargeticon3_de = "{diamant}"
L.raidtargeticon4_de = "{dreieck}"
L.raidtargeticon5_de = "{mond}"
L.raidtargeticon6_de = "{quadrat}"
L.raidtargeticon7_de = "{kreuz}"
L.raidtargeticon8_de = "{totenschädel}"


L.raidtargeticon1_fr = "{étoile}"
L.raidtargeticon2_fr = "{cercle}"
L.raidtargeticon3_fr = "{losange}"
L.raidtargeticon4_fr = "{triangle}"
L.raidtargeticon5_fr = "{lune}"
L.raidtargeticon6_fr = "{carré}"
L.raidtargeticon7_fr = "{croix}"
L.raidtargeticon8_fr = "{crâne}"


L.raidtargeticon1_it = "{stella}"
L.raidtargeticon2_it = "{cerchio}"
L.raidtargeticon3_it = "{rombo}"
L.raidtargeticon4_it = "{triangolo}"
L.raidtargeticon5_it = "{luna}"
L.raidtargeticon6_it = "{quadrato}"
L.raidtargeticon7_it = "{croce}"
L.raidtargeticon8_it = "{teschio}"


L.raidtargeticon1_ru = "{звезда}"
L.raidtargeticon2_ru = "{круг}"
L.raidtargeticon3_ru = "{ромб}"
L.raidtargeticon4_ru = "{треугольник}"
L.raidtargeticon5_ru = "{полумесяц}"
L.raidtargeticon6_ru = "{квадрат}"
L.raidtargeticon7_ru = "{крест}"
L.raidtargeticon8_ru = "{череп}"


L.raidtargeticon1_es = "{dorado}"
L.raidtargeticon2_es = "{naranja}"
L.raidtargeticon3_es = "{morado}"
L.raidtargeticon4_es = "{verde}"
L.raidtargeticon5_es = "{plateado}"
L.raidtargeticon6_es = "{azul}"
L.raidtargeticon7_es = "{rojo}"
L.raidtargeticon8_es = "{blanco}"


L.raidtargeticon1_pt = "{dourado}"
L.raidtargeticon2_pt = "{laranja}"
L.raidtargeticon3_pt = "{roxo}"
L.raidtargeticon4_pt = "{verde}"
L.raidtargeticon5_pt = "{prateado}"
L.raidtargeticon6_pt = "{azul}"
L.raidtargeticon7_pt = "{vermelho}"
L.raidtargeticon8_pt = "{branco}"


L.YesText = YES
L.NoText = NO


local zoneEJids = {
	S_ZoneT11_BH = 75,
	S_ZoneT11_ToB = 72,
	S_ZoneT11_TotFW = 74,
	S_ZoneT11_BD = 73,
	S_ZoneT12 = 78,
	S_ZoneT13 = 187,
	sooitemst15 = 362,
	sooitemst16 = 369,
}
for prefix,eID in pairs(zoneEJids) do
	L[prefix] = EJ_GetInstanceInfo(eID)
end

local encounterIDtoEJidData = {
}
if ExRT.GDB then
	ExRT.GDB.encounterIDtoEJ = encounterIDtoEJidData
end

local encounterIDtoEJidChache = {
}

local encounterIDtoNamePredef = {
}

if ExRT.isClassic then
	local names = {
		[663]="Lord Marrowgar",[664]="Lady Deathwhisper",[665]="Gunship Battle",[666]="Deathbringer Saurfang",
		[667]="Festergut",[668]="Rotface",[669]="Professor Putricide",[670]="Blood Prince Council",
		[671]="Blood-Queen Lana'thel",[672]="Valithria Dreamwalker",
		[1101]="Lord Marrowgar",[1100]="Lady Deathwhisper",[1099]="Gunship Battle",[1096]="Deathbringer Saurfang",
		[1097]="Festergut",[1104]="Rotface",[1102]="Professor Putricide",[1095]="Blood Prince Council",
		[1103]="Blood-Queen Lana'thel",[1098]="Valithria Dreamwalker",[1105]="Sindragosa",[1106]="The Lich King",
		[610]="Flame Leviathan",[611]="Ignis the Furnace Master",[612]="Razorscale",[613]="XT-002 Deconstructor",
		[614]="Assembly of Iron",[615]="Kologarn",[616]="Auriaya",[617]="Hodir",
		[1132]="Flame Leviathan",[1136]="Ignis the Furnace Master",[1139]="Razorscale",[1142]="XT-002 Deconstructor",
		[1140]="Assembly of Iron",[1137]="Kologarn",[1131]="Auriaya",[1135]="Hodir",
		[1141]="Thorim",[1133]="Freya",[1138]="Mimiron",[1134]="General Vezax",
		[1143]="Yogg-Saron",[1130]="Algalon the Observer",
		[709]="Northrend Beasts",[710]="Lord Jaraxxus",[711]="Faction Champions",[712]="Twin Val'kyr",
		[713]="Anub'arak",[714]="Gormok the Impaler",[715]="Acidmaw & Dreadscale",[716]="Icehowl",[717]="Anub'arak",
		[1088]="Northrend Beasts",[1087]="Lord Jaraxxus",[1086]="Faction Champions",
		[1089]="Twin Val'kyr",[1085]="Anub'arak",
		[1107]="Anub'Rekhan",[1110]="Grand Widow Faerlina",[1116]="Maexxna",
		[1117]="Noth the Plaguebringer",[1112]="Heigan the Unclean",[1115]="Loatheb",
		[1113]="Instructor Razuvious",[1109]="Gothik the Harvester",[1121]="The Four Horsemen",
		[1118]="Patchwerk",[1111]="Grobbulus",[1108]="Gluth",[1120]="Thaddius",
		[1119]="Sapphiron",[1114]="Kel'Thuzad",
		[1090]="Sartharion",
		[1094]="Malygos",
		[649]="Archavon the Stone Watcher",[650]="Emalon the Storm Watcher",
		[1084]="Archavon the Stone Watcher",
		[651]="Onyxia",
		[1150]="Halion",
		[652]="Attumen the Huntsman",[653]="Moroes",[654]="Maiden of Virtue",[655]="Opera Event",
		[656]="The Curator",[657]="Terestian Illhoof",[658]="Shade of Aran",[659]="Netherspite",
		[660]="Chess Event",[661]="Prince Malchezaar",[662]="Nightbane",
		[1035]="High King Maulgar",[1034]="Gruul the Dragonkiller",
		[1033]="Magtheridon",
		[623]="Hydross the Unstable",[624]="The Lurker Below",[625]="Leotheras the Blind",
		[626]="Fathom-Lord Karathress",[627]="Morogrim Tidewalker",[628]="Lady Vashj",
		[730]="Al'ar",[731]="Void Reaver",[732]="High Astromancer Solarian",[733]="Kael'thas Sunstrider",
		[618]="Rage Winterchill",[619]="Anetheron",[620]="Kaz'rogal",[621]="Azgalor",[622]="Archimonde",
		[601]="High Warlord Naj'entus",[602]="Supremus",[603]="Shade of Akama",[604]="Teron Gorefiend",
		[605]="Gurtogg Bloodboil",[606]="Reliquary of Souls",[607]="Mother Shahraz",
		[608]="The Illidari Council",[609]="Illidan Stormrage",
		[724]="Akil'zon",[725]="Nalorakk",[726]="Jan'alai",[727]="Halazzi",
		[728]="Hex Lord Malacrass",[729]="Zul'jin",
		[1027]="Kalecgos",[1024]="Brutallus",[1022]="Felmyst",[1023]="Eredar Twins",
		[1025]="M'uru",[1026]="Kil'jaeden",
	}
	for k, v in pairs(names) do
		encounterIDtoNamePredef[k] = v
	end
end

L.bossName = setmetatable({}, {__index=function (t, k)
	if not encounterIDtoEJidChache[k] then
		encounterIDtoEJidChache[k] = EJ_GetEncounterInfo(encounterIDtoEJidData[k] or 0) or encounterIDtoNamePredef[k] or ""
	end
	return encounterIDtoEJidChache[k]
end})

function L:bossName2(k)
	if not encounterIDtoEJidChache[k] then
		encounterIDtoEJidChache[k] = EJ_GetEncounterInfo(encounterIDtoEJidData[k] or 0) or encounterIDtoNamePredef[k] or ""
	end
	return encounterIDtoEJidChache[k]
end


local instanceIDtoEJidChache = {
}
L.EJInstanceName = setmetatable({}, {__index=function (t, k)
	if not instanceIDtoEJidChache[k] then
		instanceIDtoEJidChache[k] = EJ_GetInstanceInfo(k) or ""
	end
	return instanceIDtoEJidChache[k]
end})


L.BossWatcherEnergyType0 = MANA
L.BossWatcherEnergyType1 = POWER_TYPE_FURY
L.BossWatcherEnergyType2 = POWER_TYPE_FOCUS
L.BossWatcherEnergyType3 = POWER_TYPE_ENERGY
L.BossWatcherEnergyType4 = COMBO_POINTS
L.BossWatcherEnergyType5 = RUNES
L.BossWatcherEnergyType6 = RUNIC_POWER
L.BossWatcherEnergyType7 = SOUL_SHARDS_POWER
L.BossWatcherEnergyType8 = POWER_TYPE_LUNAR_POWER
L.BossWatcherEnergyType9 = HOLY_POWER
L.BossWatcherEnergyType10 = ALTERNATE_RESOURCE_TEXT
L.BossWatcherEnergyType11 = POWER_TYPE_MAELSTROM
L.BossWatcherEnergyType12 = CHI
L.BossWatcherEnergyType13 = POWER_TYPE_INSANITY
L.BossWatcherEnergyType14 = BURNING_EMBERS
L.BossWatcherEnergyType15 = POWER_TYPE_DEMONIC_FURY
L.BossWatcherEnergyType16 = POWER_TYPE_ARCANE_CHARGES
L.BossWatcherEnergyType17 = POWER_TYPE_FURY_DEMONHUNTER
L.BossWatcherEnergyType18 = POWER_TYPE_PAIN
L.BossWatcherEnergyType19 = POWER_TYPE_ESSENCE


L.BossWatcherSchoolPhysical = STRING_SCHOOL_PHYSICAL
L.BossWatcherSchoolHoly = STRING_SCHOOL_HOLY
L.BossWatcherSchoolFire = STRING_SCHOOL_FIRE
L.BossWatcherSchoolNature = STRING_SCHOOL_NATURE
L.BossWatcherSchoolFrost = STRING_SCHOOL_FROST
L.BossWatcherSchoolShadow = STRING_SCHOOL_SHADOW
L.BossWatcherSchoolArcane = STRING_SCHOOL_ARCANE
L.BossWatcherSchoolElemental = STRING_SCHOOL_ELEMENTAL
L.BossWatcherSchoolChromatic = STRING_SCHOOL_CHROMATIC
L.BossWatcherSchoolMagic = STRING_SCHOOL_MAGIC
L.BossWatcherSchoolChaos = STRING_SCHOOL_CHAOS
L.BossWatcherSchoolUnknown = STRING_SCHOOL_UNKNOWN

L.InspectViewerTalents = TALENTS
