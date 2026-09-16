local GlobalAddonName, ExRT = ...
if _G.MRT_CD_DEBUG == nil then _G.MRT_CD_DEBUG = false end
local function dprint(...) if _G.MRT_CD_DEBUG then print(...) end end
SLASH_MRTCDDEBUG1 = "/cddebug"
SlashCmdList["MRTCDDEBUG"] = function() _G.MRT_CD_DEBUG = not _G.MRT_CD_DEBUG; print("|cff33ff99[MRT]|r CD debug:", _G.MRT_CD_DEBUG and "ON" or "OFF") end

local GetTime, IsEncounterInProgress, RAID_CLASS_COLORS, GetInstanceInfo, GetSpellCharges, SecondsToTime, IsInJailersTower = GetTime, IsEncounterInProgress, RAID_CLASS_COLORS, GetInstanceInfo, GetSpellCharges, SecondsToTime, IsInJailersTower
local string_gsub, wipe, tonumber, pairs, ipairs, string_trim, format, floor, ceil, abs, type, sort, select, Enum = string.gsub, table.wipe, tonumber, pairs, ipairs, string.trim, format, floor, ceil, abs, type, sort, select, Enum
if not string_trim then
	local function _trim(s)
		if not s then return s end
		return (s:gsub('^%s+',''):gsub('%s+$',''))
	end
	string_trim = _trim
	string.trim = _trim
end
if not _G.fastrandom then
	local _rnd = _G.random or math.random
	_G.fastrandom = function(a, b)
		if a ~= nil and b ~= nil then
			return _rnd(a, b)
		elseif a ~= nil then
			return _rnd(a)
		else
			return _rnd()
		end
	end
end
local UnitIsDeadOrGhost, UnitIsConnected, UnitName, UnitCreatureFamily, UnitIsDead, UnitIsGhost, UnitGUID, UnitInRange, UnitPhaseReason, UnitAura = UnitIsDeadOrGhost, UnitIsConnected, UnitName, UnitCreatureFamily, UnitIsDead, UnitIsGhost, UnitGUID, UnitInRange, UnitPhaseReason, UnitAura
local RaidInCombat, ClassColorNum, GetDifficultyForCooldownReset, DelUnitNameServer, NumberInRange = ExRT.F.RaidInCombat, ExRT.F.classColorNum, ExRT.F.GetDifficultyForCooldownReset, ExRT.F.delUnitNameServer, ExRT.F.NumberInRange
local GetEncounterTime, UnitCombatlogname, GetUnitInfoByUnitFlag, ScheduleTimer, CancelTimer, GetRaidDiffMaxGroup, table_wipe2, dtime, utf8sub = ExRT.F.GetEncounterTime, ExRT.F.UnitCombatlogname, ExRT.F.GetUnitInfoByUnitFlag, ExRT.F.ScheduleTimer, ExRT.F.CancelTimer, ExRT.F.GetRaidDiffMaxGroup, ExRT.F.table_wipe, ExRT.F.dtime, ExRT.F.utf8sub
local C_PvP_IsWarModeDesired = (C_PvP and C_PvP.IsWarModeDesired) or function() return false end
local GetSpellLevelLearned = GetSpellLevelLearned
if ExRT.isClassic then
	GetSpellLevelLearned = function () return 1 end
	IsInJailersTower = function() end
end
local VMRT = nil
local module = ExRT:New("ExCD2",ExRT.L.cd2)
local ELib,L = ExRT.lib,ExRT.L
if not _G.TRACKER_HEADER_SCENARIO then
	_G.TRACKER_HEADER_SCENARIO = "Scenario"
end
if not _G.WORLD then
	_G.WORLD = "World"
end

local LibDeflate = LibStub:GetLibrary("LibDeflate")
module._C = {}
module.db.spellDB = {}
module.db.spell_isTalentCD = {[17116]=true,[50334]=true,[61336]=true,[33831]=true,[18562]=true,[50516]=true,[12975]=true,[12809]=true,[46924]=true,[12292]=true,[12328]=true,[60970]=true,[46968]=true,[11958]=true,[12472]=true,[31687]=true,[12042]=true,[12043]=true,[11129]=true,[31661]=true,[11426]=true,[44572]=true,[64205]=true,[31821]=true,[20066]=true,[31842]=true,[20216]=true,[31935]=true,[16190]=true,[51490]=true,[16166]=true,[30823]=true,[55198]=true,[16188]=true,[51533]=true,[30283]=true,[18708]=true,[47193]=true,[17877]=true,[19577]=true,[19574]=true,[23989]=true,[34490]=true,[19386]=true,[724]=true,[10060]=true,[47788]=true,[33206]=true,[47585]=true,[64044]=true,[15487]=true,[14751]=true,[47540]=true,[34861]=true,[13750]=true,[51690]=true,[14185]=true,[13877]=true,[36554]=true,[14177]=true,[51052]=true,[49028]=true,[49016]=true,[55233]=true,[49222]=true,[49206]=true,[49203]=true,[49039]=true,[51271]=true,[48982]=true,[49005]=true,[66233]=true,[31230]=true,[54428]=true,[48707]=true,[45529]=true,}
module.db.Cmirror = module._C
module.db.dbCountDef = #module.db.spellDB
module.db.findspecspells = {
	[30451] = 62, [5143] = 62,
	[11366] = 63, [133] = 63,
	[30455] = 64, [44614] = 64,

	[20473] = 65, [85222] = 65,
	[31935] = 66, [204019] = 66, [53595] = 66,
	[85256] = 70, [184575] = 70,

	[12294] = 71, [7384] = 71,
	[23881] = 72, [184367] = 72,
	[6572] = 73, [6343] = 73,

	[202770] = 102, [102560] = 102, [194223] = 102,
	[202028] = 103, [5217] = 103,
	[50334] = 104,
	[145205] = 105, [157982] = 105,

	[50842] = 250, [206930] = 250,
	[49020] = 251, [49143] = 251,
	[55090] = 252, [85948] = 252,

	[272790] = 253, [193455] = 253,
	[19434] = 254, [56641] = 254,
	[186270] = 255, [259491] = 255,

	[194509] = 256, [47540] = 256,
	[596] = 257, [204883] = 257,
	[335467] = 258, [34914] = 258,

	[1329] = 259, [32645] = 259,
	[193315] = 260, [2098] = 260,
	[185438] = 261, [53] = 261,

	[8042] = 262, [198067] = 262,
	[17364] = 263, [60103] = 263,
	[61295] = 264, [73920] = 264,

	[198590] = 265, [324536] = 265,
	[105174] = 266, [264178] = 266,
	[29722] = 267, [116858] = 267,

	[121253] = 268, [124506] = 268,
	[113656] = 269, [122470] = 269,
	[115151] = 270, [191837] = 270,

	[162243] = 577, [162794] = 577, [195072] = 577,
	[209795] = 581, [228478] = 581,
}
module.db.classNames = ExRT.GDB.ClassList

module.db.specByClass = {}
for class,classData in pairs(ExRT.GDB.ClassSpecializationList) do
	local newData = {0}
	for i=1,#classData do
		newData[#newData + 1] = classData[i]
	end
	module.db.specByClass[class] = newData
end
module.db.specIcons = ExRT.GDB.ClassSpecializationIcons
module.db.specInDBase = {
	[253] = 5,	[254] = 6,	[255] = 7,	-- Hunter
	[71] = 5,	[72] = 6,	[73] = 7,	-- Warrior
	[65] = 5,	[66] = 6,	[70] = 7,	-- Paladin
	[62] = 5,	[63] = 6,	[64] = 7,	-- Mage
	[256] = 5,	[257] = 6,	[258] = 7,	-- Priest
	[265] = 5,	[266] = 6,	[267] = 7,	-- Warlock
	[250] = 5,	[251] = 6,	[252] = 7,	-- Death Knight
	[259] = 5,	[260] = 6,	[261] = 7,	-- Rogue
	[102] = 5,	[103] = 6,	[104] = 7,	[105] = 8,	-- Druid (4 specs)
	[262] = 5,	[263] = 6,	[264] = 7,	-- Shaman
	[577] = 5,	[581] = 6,	-- Demon Hunter (2 specs, но это не 3.3.5a)
	[1467] = 5,	[1468] = 6,	-- Evoker (2 specs, но это не 3.3.5a)
	[0] = 4,
}

do
	local specList = {
		[62] = "MAGEDPS1",
		[63] = "MAGEDPS2",
		[64] = "MAGEDPS3",
		[65] = "PALADINHEAL",
		[66] = "PALADINTANK",
		[70] = "PALADINDPS",
		[71] = "WARRIORDPS1",
		[72] = "WARRIORDPS2",
		[73] = "WARRIORTANK",
		[102] = "DRUIDDPS1",
		[103] = "DRUIDDPS2",
		[104] = "DRUIDTANK",
		[105] = "DRUIDHEAL",
		[250] = "DEATHKNIGHTTANK",
		[251] = "DEATHKNIGHTDPS1",
		[252] = "DEATHKNIGHTDPS2",
		[253] = "HUNTERDPS1",
		[254] = "HUNTERDPS2",
		[255] = "HUNTERDPS3",
		[256] = "PRIESTHEAL1",
		[257] = "PRIESTHEAL2",
		[258] = "PRIESTDPS",
		[259] = "ROGUEDPS1",
		[260] = "ROGUEDPS2",
		[261] = "ROGUEDPS3",
		[262] = "SHAMANDPS1",
		[263] = "SHAMANDPS2",
		[264] = "SHAMANHEAL",
		[265] = "WARLOCKDPS1",
		[266] = "WARLOCKDPS2",
		[267] = "WARLOCKDPS3",
		[0] = "NO",
	}
	module.db.specInLocalizate = setmetatable({},{__index = function (t,k)
		if tonumber(k) then
			return specList[k]
		else
			for i,val in pairs(specList) do
				if val == k then
					return i
				end
			end
		end
	end})
end
module.db.historyUsage = {}
module.db.testMode = nil
module.db.isEncounter = nil
local cdsNav_wipe,cdsNav_set = nil
do
	local cdsNavData = {}
	local nilData = {}
	module.db.cdsNavData = cdsNavData
	module.db.cdsNav = setmetatable({}, {
		__index = function (t,k)
			return cdsNavData[k] or nilData
		end
	})
	function cdsNav_wipe()
		wipe(cdsNavData)
	end
	function cdsNav_set(playerName,spellID,pos)
		local e = cdsNavData[playerName]
		if not e then
			e = {}
			cdsNavData[playerName] = e
		end
		e[spellID] = pos
	end
	if ExRT.isClassic then
		function cdsNav_set(playerName,spellID,pos)
			local e = cdsNavData[playerName]
			if not e then
				e = {}
				cdsNavData[playerName] = e
			end

			e[spellID] = pos
			if pos.spellName then
				e[pos.spellName] = pos
			end
		end
	end
end

do
	local sessionData = {}
	local nilData = {}
	module.db.session_gGUIDs = setmetatable({}, {
		__index = function (t,k)
			return sessionData[k] or nilData
		end,
		__newindex = function (t,k,v)
			local e = sessionData[k]
			if not e then
				e = {}
				sessionData[k] = e
			end
			local reason = true
			if type(v) == 'table' then
				if v[3] then
					reason = {v[3],v[2]}
				else
					reason = v[2]
				end
				v = v[1]
			end
			if v > 0 then
				e[v] = reason
			else
				e[-v] = nil
			end
		end
	})
	module.db.session_gGUIDs_DEBUG = sessionData

	if ExRT.isClassic then
		module.db.session_gGUIDs = setmetatable({}, {
			__index = function (t,k)
				return sessionData[k] or nilData
			end,
			__newindex = function (t,k,v)
				local e = sessionData[k]
				if not e then
					e = setmetatable({},{
						__index = function (t1,k1)
							if type(k1) == "number" and k1 > 0 then
								local sname = GetSpellInfo(k1)
								if sname then return rawget(t1, sname) end
							end
						end,
					})
					sessionData[k] = e
				end
				local reason = true
				if type(v) == 'table' then
					if v[3] then
						reason = {v[3],v[2]}
					else
						reason = v[2]
					end
					v = v[1]
				end
				if type(v)=='string' or v > 0 then
					e[v] = reason
				else
					e[-v] = nil
				end
			end
		})
	end

	function module:ClearSessionDataReason(name,...)
		local e = sessionData[name]
		if not e then
			return
		end
		local reasons = {}
		for i=1,select("#",...) do
			reasons[ select(i,...) ] = true
		end
		for k,v in pairs(e) do
			if (type(v) == "table" and reasons[ v[2] ]) or (type(v) ~= "table" and reasons[v]) then
				e[k] = nil
			end
		end
	end

	function module:WipeSessionData(name)
		local e = sessionData[name]
		if not e then
			return
		end
		for k,v in pairs(e) do
			local reason = type(v) == "table" and v[2] or v
			if reason == "talent" or reason == "pvptalent" or reason == "autotalent" or reason == "aura" then
				e[k] = nil
			end
		end
	end

	function module:ClearFullSessionDataReason(...)
		local reasons = {}
		for i=1,select("#",...) do
			reasons[ select(i,...) ] = true
		end
		for _,e in pairs(sessionData) do
			for k,v in pairs(e) do
				if (type(v) == "table" and reasons[ v[2] ]) or (type(v) ~= "table" and reasons[v]) then
					e[k] = nil
				end
			end
		end
	end
end

module.db.session_Pets = {}
module.db.session_PetOwner = {}
module.db.session_TalentBroadcastReceived = {}

module.db.spell_isTalent = {
	[845]=true,	[315720]=true,	[206940]=true,	[194913]=true,	[343294]=true,	[117014]=true,	[265046]=true,	[117014]=true,	[265046]=true,
	[265046]=true,	[205022]=true,	[235870]=true,	[205030]=true,	[116847]=true,	[196725]=true,	[116847]=true,


	[311203]=true,	[311302]=true,	[311303]=true,	[312725]=true,	[313921]=true,	[313922]=true,	[310592]=true,	[310601]=true,	[310602]=true,	[310690]=true,	[311194]=true,	[311195]=true,	[295046]=true,	[299984]=true,	[299988]=true,	[303823]=true,	[304088]=true,	[304121]=true,		[299376]=true,	[299378]=true,		[299372]=true,	[299374]=true,		[299273]=true,	[299275]=true,	[297375]=true,	[298309]=true,	[298312]=true,		[298628]=true,	[299334]=true,		[299336]=true,	[299338]=true,		[299958]=true,	[299959]=true,		[299943]=true,	[299944]=true,		[300009]=true,	[300010]=true,		[298080]=true,	[298081]=true,		[299932]=true,	[299933]=true,		[299882]=true,	[299883]=true,		[300002]=true,	[300003]=true,		[299345]=true,	[299347]=true,		[299355]=true,	[299358]=true,		[302982]=true,	[302983]=true,	[296036]=true,	[310425]=true,	[310442]=true,		[299875]=true,	[299876]=true,		[300015]=true,	[300016]=true,		[299349]=true,	[299353]=true,	[296325]=true,	[299368]=true,	[299370]=true,		[298273]=true,	[298277]=true,
}

module.db.spell_autoTalent = {
	[273048]=104,
	[88]=104,
	[288826]=104
}

module.db.spell_talentProvideAnotherTalents = {
	[197492] = {102793},
	[197488] = {132469},
	[197632] = {132469},
	[197491] = {99,22842},
	[217615] = {99,22842},
	[31850]  = {66233},
}

module.db.spell_talentsList = {}
module.db.spell_isPvpTalent = {}

module.db.spell_isRaidCD = {}

do
	local nilData = {}
	local talentEntriesData = {}
	module.db.talent_entries_debug = talentEntriesData
	module.db.talent_entries = setmetatable({}, {
		__index = function(t,k)
			return talentEntriesData[k] or nilData
		end
	})
	function module:SetTalentEntries(player,entries)
		if not player then
			return
		end
		talentEntriesData[player] = entries
	end
end

do

	local nilData = {}
	local talentRankData = {}
	module.db.talent_classic_rank_debug = talentRankData
	module.db.talent_classic_rank = setmetatable({}, {
		__index = function (t,k)
			return talentRankData[k] or nilData
		end
	})
	function module:SetTalentClassicRank(player,spellID,rank)
		if not player then
			return
		end
		talentRankData[player] = talentRankData[player] or {}
		talentRankData[player][spellID] = rank
	end
	function module:WipeTalentClassicRank(player)
		if not player then
			return
		end
		if talentRankData[player] then
			for k in pairs(talentRankData[player]) do
				talentRankData[player][k] = nil
			end
		end
	end
end

module.db.spell_charge_fix = {
	[51505]=108283,
	[204019]=1,
	[53600]=1,
	[35395]=1,
	[205629]=1,
	[205234]=1,
	[61295]=108283,
	[19758]=1,
	[198304]=1,
	[193786]=1,
	[7384]=262150,
	[108839]=1,
	[115151]=1,
	[259495]=264332,
	[115308]=1,
	[108853]=205029,
	[275779]=204023,
	[210191]=1,
	[217200]=1,
	[259489]=269737,
	[212436]=1,
	[19434]=1,
}

module.db.spell_durationByTalent_fix = {
	[52174]={202163,3},
}

module.db.spell_cdByTalent_fix = {
	[30449]={198100,30},
	[77761]={288826,-60},
	[52174]={202163,-15},
	[77764]={288826,-60},
	[6343]={275336,{"*0.5",107574}},
	[187827]={296320,"*0.80"},
	[339]={202226,6},
}

module.db.spell_cdByTalent_scalable_data = {
	[296320] = {
		[1] = "*0.75",
	},
}

module.db.spell_cdByTalent_isScalable = {
	[296320] = true,
}

module.db.tierSetsSpells = {}
module.db.tierSetsList = {}

module.db.spell_talentReplaceOther = {
	[34428]=202168,
	[35395]=204019,
}

module.db.spell_aura_list = {
}
module.db.spell_speed_list = {
}
module.db.spell_afterCombatReset = {
}
module.db.spell_afterCombatNotReset = {
	[21169]=true,
	[199740]=true,
	[126393]=true,
	[160452]=true,
	[159956]=true,
	[159931]=true,
}
module.db.spell_reduceCdByHaste = {
	[12294]=true,
	[184575]=true,
	[24275]=true,
	[108853]=true,
	[204019]=true,
	[35395]=true,
	[121253]=true,
	[116847]=true,
	[6343]=true,
	[17364]=true,
	[275773]=true,
	[53500]=true,
	[115308]=true,
	[33917]=true,
	[20271]=true,
	[85222]=true,
	[845]=true,
	[193786]=true,
	[184092]=true,
	[213652]=true,
	[275779]=true,
	[23881]=true,
	[193796]=true,
	[6572]=true,
	[19434]=true,
	[187874]=true,
	[23922]=true,
}
module.db.spell_resetOtherSpells = {
	[204035]={53600},
	[217200]={{34026,336830}},
}
module.db.spell_sharingCD = {
}

module.db.spell_runningSameSpell = {}

do
	module.db.spell_runningSameSpell2 = {
		{187611,187614,187615},
		{202767,202771,202768},
		{330325,5308},
	}
	if ExRT.isBC then
		module.db.spell_runningSameSpell2[#module.db.spell_runningSameSpell2+1] = {2894,2062}
	end
	for i=1,#module.db.spell_runningSameSpell2 do
		local list = module.db.spell_runningSameSpell2[i]
		for j=1,#list do
			module.db.spell_runningSameSpell[ list[j] ] = list
		end
	end
end

module.db.spell_reduceCdCast = {
}
module.db.spell_increaseDurationCast = {
}
module.db.spell_dispellsFix = {}
module.db.spell_dispellsList = {
	[115450]=true,
	[360823]=true,
}

module.db.spell_startCDbyAuraFade = {
	[5215]=5215,
	[5384]=5384,
}
module.db.spell_startCDbyAuraFadeExt = {
}
module.db.spell_startCDbyAuraApplied = {
}
module.db.spell_startCDbySummon = {
}
module.db.spell_cancelDurOnCast = {
}
module.db.spell_aoe_no_target = {
	[31821]=true,
	[64205]=true,
	[740]=true,
	[32182]=true,
	[2825]=true,
	[51052]=true,
	[64843]=true,
	[64901]=true,
	[16190]=true,
}
if ExRT.isLK then
	module.db.spell_aura_list[35079] = 34477
	module.db.spell_aura_list_onTarget = {
		[20707] = 20765,
		[20727] = 20765,
		[20762] = 20765,
		[20763] = 20765,
		[20764] = 20765,
		[20765] = 20765,
		[27239] = 20765,
		[27240] = 20765,
		[47882] = 20765,
		[47883] = 20765,
	}
end
module.db.spell_startCDbyAuraApplied_fix = {}
for _,spellID in pairs(module.db.spell_startCDbyAuraApplied) do module.db.spell_startCDbyAuraApplied_fix[spellID] = true end

module.db.spell_startCDbyUnitAura = {
	[31821] = 31821,
	[64205] = 64205,
	[498]   = 498,
	[642]   = 642,
	[48792] = 48792,
	[55233] = 55233,
	[22812] = 22812,
	[61336] = 61336,
	[871]   = 871,
	[55694] = 55694,
	[47585] = 47585,
	[12472] = 12472,
	[12042] = 12042,
	[16166] = 16166,
	[30823] = 30823,
}


module.db.spell_reduceCdByAuraFade = {
}
module.db.spell_reduceCdByAuraFadeBefore = {
}
module.db.spell_reduceCdByAura = {
}
module.db.spell_ignoreUseWithAura = {
}

module.db.spell_battleRes = {
}
module.db.isResurectDisabled = nil

module.db.spell_isRacial = {
	[80483]="BloodElf",
	[69179]="BloodElf",
	[28880]="Draenei",
	[59542]="Draenei",
	[59544]="Draenei",
	[129597]="BloodElf",
	[59548]="Draenei",
	[202719]="BloodElf",
	[33697]="Orc",
	[50613]="BloodElf",
	[25046]="BloodElf",
	[155145]="BloodElf",
	[33702]="Orc",
	[59543]="Draenei",
	[59545]="Draenei",
	[59547]="Draenei",
	[69046]="Goblin",
}

module.db.aura_grant_talent = {
	[108293] = 273048,
}

module.db.def_col = {
}

module.db.petsAbilities = {
	[0] = 						{},
	[L.creatureNames["Basilisk"]] = 		{1,	{159733,45},	},
	[L.creatureNames["Bat"]] = 		{2,	},
	[L.creatureNames["Bear"]] = 		{1,	{50256,10},	},
	[L.creatureNames["Beetle"]] = 		{1,	{90339,60,12},	},
	[L.creatureNames["Bird of Prey"]] = 	{2,	},
	[L.creatureNames["Boar"]] = 		{1,	},
	[L.creatureNames["Carrion Bird"]] = 	{3,	{24423,6},	},
	[L.creatureNames["Cat"]] = 		{3,	{24450,10},	{93435,45},	},
	[L.creatureNames["Chimaera"]] = 		{2,	{54644,10},	},
	[L.creatureNames["Core Hound"]] = 		{3,	{90355,360,40},	},
	[L.creatureNames["Crab"]] = 		{1,	{159926,60,12},	},
	[L.creatureNames["Crane"]] = 		{2,	{159931,600},	},
	[L.creatureNames["Crocolisk"]] = 		{1,	{50433,10},	},
	[L.creatureNames["Devilsaur"]] = 		{3,	{159953,60},	{54680,8},	},
	[L.creatureNames["Direhorn"]] = 		{1,	{137798,30},	},
	[L.creatureNames["Dog"]] = 		{3,	},
	[L.creatureNames["Dragonhawk"]] = 		{2,	},
	[L.creatureNames["Fox"]] = 		{3,	{160011,120},	},
	[L.creatureNames["Goat"]] = 		{3,	},
	[L.creatureNames["Gorilla"]] = 		{1,	},
	[L.creatureNames["Hyena"]] = 		{3,	{128432,90},	},
	[L.creatureNames["Monkey"]] = 		{2,	{160044,120},	},
	[L.creatureNames["Moth"]] = 		{3,	{159956,600},	},

	[L.creatureNames["Nether Ray"]] = 		{2, 	{160452,360,40}, },
	[L.creatureNames["Porcupine"]] = 		{1,	},
	[L.creatureNames["Quilen"]] = 		{3,	{126393,600},	},
	[L.creatureNames["Raptor"]] = 		{3,	{160052,45},	},
	[L.creatureNames["Ravager"]] = 		{2,	},
	["Clefthoof"] = 				{1,	},
	[L.creatureNames["Scorpid"]] = 		{1,	{160060,6},	},
	[L.creatureNames["Serpent"]] = 		{2,	{128433,90},	},
	[L.creatureNames["Shale Spider"]] = 	{1,	{160063,60,12},	},
	[L.creatureNames["Silithid"]] = 		{2,	{160065,10},	},
	[L.creatureNames["Spider"]] = 		{2,	{160067,10},	},
	[L.creatureNames["Spirit Beast"]] = 	{3,	{90328,10},	{90361,30},	},
	[L.creatureNames["Sporebat"]] = 		{2,	},
	[L.creatureNames["Tallstrider"]] = 	{3,	{160073,45},	},
	[L.creatureNames["Turtle"]] = 		{1,	{26064,60,12},	},
	[L.creatureNames["Warp Stalker"]] = 	{1,	{35346,15},	},
	[L.creatureNames["Wasp"]] = 		{3,	},
	[L.creatureNames["Water Strider"]] = 	{2,	},
	[L.creatureNames["Wind Serpent"]] = 	{2,	},
	[L.creatureNames["Wolf"]] = 		{3,	{24604,45},	},
	[L.creatureNames["Worm"]] = 		{1,	{93433,14},	},
	[1] = 						{0,	{53478,360,20},	{61685,25},	{63900,10},	},
	[2] = 						{0,	{53490,180,12},	{61684,32,16},	},
	[3] = 						{0,	{61684,32,16},	{55709,480},	},
	[L.creatureNames["Ghoul"]] = 		{0,	{91837,45,10},	{91802,30},	{91797,60},	},
	[L.creatureNames["Felguard"]] = 		{0,	{89751,45,6},	{89766,30},	{30151,15},	},
	[L.creatureNames["Felhunter"]] = 		{0,	{19647,24},	{19505,15},	},
	[L.creatureNames["Fel Imp"]] = 		{0,	{115276,10},	},
	[L.creatureNames["Imp"]] = 		{0,	{89808,10},	{119899,30,12},	{89792,20},	},
	[L.creatureNames["Observer"]] = 		{0,	{19647,24},	{115284,15},	},
	[L.creatureNames["Shivarra"]] = 		{0,	{115770,25},	{115268,30},	},
	[L.creatureNames["Succubus"]] = 		{0,	{6360,25},	{6358,30},	},
	[L.creatureNames["Voidlord"]] = 		{0,	{115236,10}	},
	[L.creatureNames["Voidwalker"]] = 		{0,	{17735,10},	{17767,120,20},	{115232,10},	},
	[L.creatureNames["Wrathguard"]] = 		{0,	{115831,45,6},	},
	[L.creatureNames["Water Elemental"]] = 	{0,	{135029,25,4},	{33395,25},	},
}
module.db.spell_isPetAbility = {}
for petName,petData in pairs(module.db.petsAbilities) do
	for i=2,#petData do
		if module.db.spell_isPetAbility[petData[i][1]] then
			if type(module.db.spell_isPetAbility[petData[i][1]]) ~= "table" then
				module.db.spell_isPetAbility[petData[i][1]] = {module.db.spell_isPetAbility[petData[i][1]]}
			end
			module.db.spell_isPetAbility[petData[i][1]][ #module.db.spell_isPetAbility[petData[i][1]] + 1 ] = petName
		else
			module.db.spell_isPetAbility[petData[i][1]] = petName
		end
	end
end

module.db.differentIcons = {
	[176875]="Interface\\Icons\\Inv_misc_trinket6oOG_Isoceles1",
	[176873]="Interface\\Icons\\Inv_misc_trinket6oIH_orb4",
	[184270]="Interface\\Icons\\spell_nature_mirrorimage",
	[183929]="Interface\\Icons\\spell_mage_presenceofmind",
	[187614]="Interface\\Icons\\inv_60legendary_ring1c",
	[187613]="Interface\\Icons\\inv_60legendary_ring1b",
	[187612]="Interface\\Icons\\inv_60legendary_ring1a",
}

module.db.itemsToSpells = {
	[113931] = 176878,
	[113969] = 176874,
	[118876] = 177597,
	[118878] = 177594,
	[118880] = 177592,
	[118882] = 177189,
	[118884] = 176460,
	[113905] = 176873,
	[113834] = 176876,
	[113835] = 176875,
	[113842] = 176879,
	[110002] = 165531,
	[110003] = 165543,
	[110008] = 165535,
	[110012] = 165532,
	[110013] = 165543,
	[110017] = 165534,
	[110018] = 165535,
	[114488] = 176883,
	[114489] = 176882,
	[114490] = 176884,
	[114491] = 176881,
	[114492] = 176885,
	[109997] = 165485,
	[109998] = 165542,
	[110007] = 165532,
	[124224] = 184270,
	[124232] = 183929,

	[137105] = 206338,
	[137059] = 206380,
	[137017] = 207628,
	[137089] = 215176,
	[137054] = 215057,
	[137101] = 206332,
	[137033] = 206889,
	[137227] = 212278,
	[137100] = 208892,
	[137030] = 208895,
	[132436] = 214576,
	[132367] = 208706,
	[132376] = 210852,
	[137058] = 210604,
	[137097] = 209256,
	[137027] = 224489,
	[137096] = 206902,
	[137039] = 208199,
	[137061] = 215149,
	[137071] = 210867,
	[138949] = 210970,
	[144279] = 209354,

	[64399] = 90628,
	[64398] = 90626,
	[63359] = 89479,

	[133642] = 215956,
	[137541] = 215648,
	[137539] = 214962,
	[137538] = 215936,
	[137537] = 215658,
	[137486] = 214980,
	[137462] = 215206,
	[137440] = 214584,
	[137433] = 215467,
	[137369] = 214971,
	[137344] = 214423,
	[137338] = 214366,
	[137329] = 215670,
	[133647] = 214203,
	[133646] = 214198,
	[139322] = 221837,
	[139333] = 221992,
	[139327] = 221695,
	[139326] = 222046,
	[139320] = 221803,

	[144280] = 235556,
	[143728] = 208091,
	[144274] = 235273,
	[144293] = 235605,
	[144355] = 235940,
	[144242] = 235039,
}


for itemID,spellID in pairs(module.db.itemsToSpells) do
	module.db.spell_isTalent[spellID] = true
	if spellID > 330000 and not module.db.differentIcons[spellID] then
		local icon = select(5,GetItemInfoInstant(itemID))
		if icon ~= GetSpellTexture(spellID) then
			module.db.differentIcons[spellID] = icon
		end
	end
end

ExRT.F.table_add2(module.db.itemsToSpells,{
	[124634] = 187614,
	[124636] = 187615,
	[124635] = 187611,
	[124637] = 187613,
	[124638] = 187612,
})

module.db.itemsBonusToSpell = {
	[6972] = 336470,
	[6979] = 336133,
	[6977] = 336314,
	[6948] = 334724,
	[6943] = 334580,
	[6941] = 334525,
	[6946] = 334692,
	[6952] = 334949,
	[6951] = 334898,
	[7051] = 337685,
	[7109] = 340053,
	[7095] = 339062,
	[7003] = 336742,
	[7006] = 336747,
	[7009] = 336830,
	[7081] = 337296,
	[7070] = 337481,
	[7054] = 337594,
	[7053] = 337600,
	[7060] = 337831,
	[7114] = 340080,
	[6989] = 336734,
	[6995] = 335897,
	[7025] = 337020,
	[7118] = 340084,
	[6955] = 335214,
	[6965] = 335582,
	[6957] = 335239,
	[6956] = 335229,
	[7061] = 337838,
	[7011] = 336849,
	[7470] = 354131,
	[7730] = 357996,
	[7474] = 354109,
	[7571] = 354118,
	[7703] = 356391,
	[7728] = 356395,
	[7701] = 355447,
	[7573] = 354731,
	[7708] = 356218,
}
if UnitLevel'player' > 60 then
	for _,bonusID in pairs({6972,6979,6977,6948,6943,6941,6946,6952,6951,7051,7109,7095,7003,7006,7009,7081,7070,7054,7053,7060,7114,6989,6995,7025,7118,6955,6965,6957,6956,7061,7011,7470,7730,7474,7571,7703,7728,7701,7573,7708}) do
		module.db.itemsBonusToSpell[bonusID] = nil
	end
end

module.db.spellCDSync = {}
module.db.spellCDSyncToSpell = {}
do
	local c,scd,scsts = select(2,UnitClass'player'),module.db.spellCDSync,module.db.spellCDSyncToSpell
end


module.db.spellIgnoreAfterFirstUse = {}

local CLEU = {}
module.db.CLEU = CLEU


if ExRT.isClassic then
	module.db.findspecspells = {}
	module.db.spell_isTalent = {}
	module.db.spell_autoTalent = {}
	module.db.spell_charge_fix = {}
	module.db.spell_talentReplaceOther = {}
	module.db.spell_aura_list = {}
	module.db.spell_speed_list = {}
	module.db.spell_afterCombatReset = {}
	module.db.spell_afterCombatNotReset = {}
	module.db.spell_reduceCdByHaste = {}
	module.db.spell_resetOtherSpells = {}
	module.db.spell_reduceCdCast = {}
	module.db.itemsBonusToSpell = {}
	module.db.itemsToSpells = {}

	module.db.spell_cdByTalent_fix = {}
	module.db.spell_durationByTalent_fix = {}
end
if ExRT.isLK then
	local spellToLvl = {
		[31884] = 70,
		[642] = 34,
		[10310] = 10,
		[1022] = 10,
		[19752] = 30,
		[34477] = 70,
		[64901] = 80,
		[64843] = 80,
		[6346] = 20,
		[42650] = 80,
		[61999] = 72,
		[2825] = 70,
		[32182] = 70,
		[55694] = 75,
		[20765] = 18,
		[55342] = 80,
		[45438] = 30,
	}

	GetSpellLevelLearned = function (spell)
		if spellToLvl[spell] then
			return spellToLvl[spell]
		end
		return 1
	end
end


module.db.vars = {
	isWarlock = {},
	isRogue = {},
	isPaladin = {},
	isMage = {},
}

module.db.plugin = {}

module.db.rframes = {
	{text = L.cd2Autoselect},
	{name = "VuhDo", opts = {"^Vd1", "^Vd2", "^Vd3", "^Vd4", "^Vd5", "^Vd"}},
	{name = "HealBot", opts = {"^HealBot"}},
	{name = "Grid", opts = {"^GridLayout","^Grid2Layout"}},
	{name = "ElvUI", opts = {"^ElvUF_RaidGroup","^ElvUF_PartyGroup"}},
	{name = "SUF", opts = {"^SUFHeaderraid","^SUFHeaderparty"}},
	{name = "Blizzard", opts = {"^CompactRaid","^CompactParty"}},
}
module.db.rframes_def = {

	"^Vd1",
	"^Vd2",
	"^Vd3",
	"^Vd4",
	"^Vd5",
	"^Vd",
	"^HealBot",
	"^GridLayout",
	"^Grid2Layout",
	"^PlexusLayout",
	"^ElvUF_RaidGroup",
	"^oUF_bdGrid",
	"^oUF_.-Raid",
	"^LimeGroup",
	"^SUFHeaderraid",

	"^AleaUI_GroupHeader",
	"^SUFHeaderparty",
	"^ElvUF_PartyGroup",
	"^oUF_.-Party",
	"^PitBull4_Groups_Party",
	"^CompactRaid",
	"^CompactParty",

	"^SUFUnitplayer",
	"^PitBull4_Frames_Player",
	"^ElvUF_Player",
	"^oUF_.-Player",
	"^PlayerFrame",
}

module.db.notAClass = { r = 0.8, g = 0.8, b = 0.8, colorStr = "ffcccccc" }

local colorSetupFrameColorsNames = {"Default","Active","Cooldown"}
local colorSetupFrameColorsObjectsNames = {"Text","Background","TimeLine"}
local globalGUIDs = nil

local function FindAnyUserColumn(cdecol, spellID)
	for n=1,5 do
		local c = cdecol[spellID..";"..n]
		if c then return c end
	end
end

module.db.maxLinesInCol = 100
module.db.maxColumns = 10

module.db.colsDefaults = {
	iconSize = 16,
	iconHeight = 16,
	iconGray = true,
	iconPosition = 1,
	textureFile = ExRT.F.barImg,
	textureBorderSize = 0,
	fontSize = 12,
	fontName = ExRT.F.defFont,
	fontCDSize = 16,
	frameLines = 15,
	frameAlpha = 100,
	frameScale = 100,
	frameWidth = 130,
	frameColumns = 1,
	frameBetweenLines = 0,
	frameBlackBack = 0,
	frameStrata = "MEDIUM",
	methodsStyleAnimation = 1,
	methodsTimeLineAnimation = 1,
	methodsSortingRules = 1,
	methodsAlphaNotInRangeNum = 90,

	textureBorderColorR = 0,	textureBorderColorG = 0,	textureBorderColorB = 0,	textureBorderColorA = 1,

	textureColorTextDefaultR = 1,	textureColorTextDefaultG = 1,	textureColorTextDefaultB = 1,
	textureColorTextActiveR = 1,	textureColorTextActiveG = 1,	textureColorTextActiveB = 1,
	textureColorTextCooldownR = 1,	textureColorTextCooldownG = 1,	textureColorTextCooldownB = 1,

	textureColorBackgroundDefaultR = 0,	textureColorBackgroundDefaultG = 1,	textureColorBackgroundDefaultB = 0,
	textureColorBackgroundActiveR = 0,	textureColorBackgroundActiveG = 1,	textureColorBackgroundActiveB = 0,
	textureColorBackgroundCooldownR = 1,	textureColorBackgroundCooldownG = 0,	textureColorBackgroundCooldownB = 0,

	textureColorTimeLineDefaultR = 0,	textureColorTimeLineDefaultG = 1,	textureColorTimeLineDefaultB = 0,
	textureColorTimeLineActiveR = 0,	textureColorTimeLineActiveG = 1,	textureColorTimeLineActiveB = 0,
	textureColorTimeLineCooldownR = 1,	textureColorTimeLineCooldownG = 0,	textureColorTimeLineCooldownB = 0,

	textureAlphaBackground = 0.3,
	textureAlphaTimeLine = 0.8,
	textureAlphaCooldown = 1,

	textureSmoothAnimationDuration = 50,

	textTemplateLeft = "%name%",
	textTemplateRight = "%time%",
	textTemplateCenter = "",

	textIconNameChars = 50,
	textIconCDStyle = 7,

	iconFontMode = false,
	iconFontTopTemplate = "",
	iconFontTopAnchor = "TOP",
	iconFontTopX = 0,
	iconFontTopY = 0,
	iconFontTopPos = 2,
	iconFontTopGrowth = 0,
	iconFontCenterTemplate = "%time%",
	iconFontCenterAnchor = "CENTER",
	iconFontCenterX = 0,
	iconFontCenterY = 0,
	iconFontCenterPos = 5,
	iconFontCenterGrowth = 0,
	iconFontBottomTemplate = "%name%",
	iconFontBottomAnchor = "BOTTOM",
	iconFontBottomX = 0,
	iconFontBottomY = 0,
	iconFontBottomPos = 8,
	iconFontBottomGrowth = 0,

	fontIconTopName = nil,
	fontIconTopSize = nil,
	fontIconTopOutline = nil,
	fontIconTopShadow = nil,
	fontIconMidName = nil,
	fontIconMidSize = nil,
	fontIconMidOutline = nil,
	fontIconMidShadow = nil,
	fontIconBotName = nil,
	fontIconBotSize = nil,
	fontIconBotOutline = nil,
	fontIconBotShadow = nil,

	blacklistText = "",
	whitelistText = "",

	ATFCol = 6,
	ATFLines = 2,
	ATFOffsetX = 0,
	ATFOffsetY = 0,
	ATFGrowth = 1,
	iconGlowType = 4,
	iconGlowColorR = 0.95,
	iconGlowColorG = 0.95,
	iconGlowColorB = 0.32,
	iconGlowColorA = 1,
}

module.db.colsIconFontPos = {
	[1]  = {"TOPLEFT",     "TOPLEFT",     false, 1},
	[2]  = {"TOP",         "TOP",         true,  0},
	[3]  = {"TOPRIGHT",    "TOPRIGHT",    false, 2},
	[4]  = {"LEFT",        "LEFT",        false, 1},
	[5]  = {"CENTER",      "CENTER",      true,  0},
	[6]  = {"RIGHT",       "RIGHT",       false, 2},
	[7]  = {"BOTTOMLEFT",  "BOTTOMLEFT",  false, 1},
	[8]  = {"BOTTOM",      "BOTTOM",      true,  0},
	[9]  = {"BOTTOMRIGHT", "BOTTOMRIGHT", false, 2},
	[10] = {"BOTTOMRIGHT", "BOTTOMLEFT",  false, 2},
	[11] = {"TOPRIGHT",    "TOPLEFT",     false, 2},
	[12] = {"BOTTOMLEFT",  "TOPLEFT",     false, 1},
	[13] = {"BOTTOMRIGHT", "TOPRIGHT",    false, 2},
	[14] = {"TOPLEFT",     "TOPRIGHT",    false, 1},
	[15] = {"BOTTOMLEFT",  "BOTTOMRIGHT", false, 1},
	[16] = {"TOPRIGHT",    "BOTTOMRIGHT", false, 2},
	[17] = {"TOPLEFT",     "BOTTOMLEFT",  false, 1},
	[18] = {"BOTTOM",      "TOP",         true,  0},
	[19] = {"LEFT",        "RIGHT",       false, 1},
	[20] = {"TOP",         "BOTTOM",      true,  0},
	[21] = {"RIGHT",       "LEFT",        false, 2},
}

module.db.colsIconFontPosFromAnchor = {
	Top    = {TOPLEFT=1,  TOP=2,    TOPRIGHT=3 },
	Center = {LEFT=4,     CENTER=5, RIGHT=6   },
	Bottom = {BOTTOMLEFT=7, BOTTOM=8, BOTTOMRIGHT=9},
}

function module.db.ResolveIconFontPos(slot, savedPos, savedAnchor)
	local posTbl = module.db.colsIconFontPos
	if savedPos and posTbl[savedPos] then
		return savedPos, posTbl[savedPos]
	end
	local map = module.db.colsIconFontPosFromAnchor[slot]
	local fallback = map and savedAnchor and map[savedAnchor]
	if fallback and posTbl[fallback] then
		return fallback, posTbl[fallback]
	end
	local def = slot == "Top" and 2 or slot == "Center" and 5 or slot == "Bottom" and 8 or 5
	return def, posTbl[def]
end

module.db.colsInit = {
	iconGeneral = true,
	textureGeneral = true,
	methodsGeneral = true,
	frameGeneral = true,
	fontGeneral = true,
	textGeneral = true,
	blacklistGeneral = true,
	visibilityGeneral = true,

	iconGray = true,
	textureAnimation = true,

	fontOutline = true,
	fontShadow = false,


}

module.db.status_UnitsToCheck = {}
module.db.status_UnitIsDead = {}
module.db.status_UnitIsDisconnected = {}
module.db.status_UnitIsOutOfRange = {}


local UpdateAllData = nil
local SaveCDtoVar = nil
local CLEUstartCD = nil
local RecordHistoryUsage = nil

local L_Offline,L_Dead = L.cd2StatusOffline, L.cd2StatusDead
local _C, _db = module._C, module.db

local status_UnitsToCheck,status_UnitIsDead,status_UnitIsDisconnected,status_UnitIsOutOfRange = module.db.status_UnitsToCheck,module.db.status_UnitIsDead,module.db.status_UnitIsDisconnected,module.db.status_UnitIsOutOfRange

do
	local key_to_table = {
		["isTalent"]={module.db.spell_isTalent,0},
		["baseForSpec"]={module.db.spell_autoTalent,0},
		["hasCharges"]={module.db.spell_charge_fix,0},
		["durationDiff"]={module.db.spell_durationByTalent_fix,0},
		["cdDiff"]={module.db.spell_cdByTalent_fix,0},
		["isScalable"]={module.db.spell_cdByTalent_isScalable,0},
		["hideWithTalent"]={module.db.spell_talentReplaceOther,0},
		["changeDurWithHaste"]={module.db.spell_speed_list,0},
		["afterCombatReset"]={module.db.spell_afterCombatReset,0},
		["afterCombatNotReset"]={module.db.spell_afterCombatNotReset,0},
		["changeCdWithHaste"]={module.db.spell_reduceCdByHaste,0},
		["sameSpell"]={module.db.spell_runningSameSpell2,0},
		["isDispel"]={module.db.spell_dispellsList,0},
		["isBattleRes"]={module.db.spell_battleRes,0},
		["isRacial"]={module.db.spell_isRacial,0},
		["icon"]={module.db.differentIcons,0},
		["ignoreUseWithAura"]={module.db.spell_ignoreUseWithAura,0},

		["stopDurWithAuraFade"]={module.db.spell_aura_list,"S"},
		["resetBy"]={module.db.spell_resetOtherSpells,1},
		["startCdAfterUse"]={module.db.spell_sharingCD,"K"},
		["reduceCdAfterCast"]={module.db.spell_reduceCdCast,2},
		["increaseDurAfterCast"]={module.db.spell_increaseDurationCast,2},
		["startCdAfterAuraFade"]={module.db.spell_startCDbyAuraFade,"S"},
		["startCdAfterAuraFadeExt"]={module.db.spell_startCDbyAuraFadeExt,"S"},
		["startCdAfterAuraApply"]={module.db.spell_startCDbyAuraApplied,"S"},
		["changeCdAfterAuraFullDur"]={module.db.spell_reduceCdByAuraFade,2},
		["changeCdBeforeAuraFullDur"]={module.db.spell_reduceCdByAuraFadeBefore,2},
		["item"]={module.db.itemsToSpells,"S"},
		["changeCdWithAura"]={module.db.spell_reduceCdByAura,2},
	}
	local function cmp(a,b)
		if type(a) == "table" and type(b) == "table" then
			return ExRT.F.table_compare(a,b) == 1
		else
			return a == b
		end
	end
	function module:CreateSpellData(forceAll)
		CLEU:Reset()

		for i=1,#module.db.AllSpells do
			local spell = module.db.AllSpells[i]
			local on = VMRT.ExCD2.CDE[ spell[1] ]
			if on or forceAll then
				for k,v in pairs(spell) do
					local t = key_to_table[k]
					if t then
						local it = t[2]
						if t[2] == 0 then
							t[1][ spell[1] ] = v
						elseif t[2] == "K" then
							for i=1,#v do
								local st = t[1][ v[i][1] ]
								if not st then
									st = {}
									t[1][ v[i][1] ] = st
								end
								st[ spell[1] ] = v[i][2]
							end
						elseif t[2] == "S" then
							for i=1,(type(v)~="table" and 1 or #v) do
								t[1][ (type(v)~="table" and v or v[i]) ]=spell[1]
							end
						else
							for i=1,(type(v)~="table" and 1 or #v),it do
								local sk = type(v)~="table" and v or v[i]
								local st
								local vAdd
								if type(sk) == "table" then
									local n = ExRT.F.table_copy2(sk)
									st = t[1][ n[1] ]
									if not st then
										st = {}
										t[1][ n[1] ] = st
									end
									n[1] = spell[1]
									vAdd = n
								else
									st = t[1][sk]
									if not st then
										st = {}
										t[1][sk] = st
									end
									vAdd = spell[1]
								end
								for o=1,#st,it do
									if cmp(st[o],vAdd) then
										vAdd = nil
										break
									end
								end
								if vAdd then
									st[#st+1] = vAdd
									for l=2,it do
										st[#st+1] = v[i+l-1]
									end
								end
							end
						end
					elseif type(k)=="string" and k:find("^CLEU_") and on then
						CLEU:Add(k,v)
					elseif type(k)=="string" then

					end
				end
			end
		end


		for _,list in pairs(module.db.spell_runningSameSpell2) do
			for j=1,#list do
				module.db.spell_runningSameSpell[ list[j] ] = list
			end
		end

		for _,spellID in pairs(module.db.spell_startCDbyAuraApplied) do module.db.spell_startCDbyAuraApplied_fix[spellID] = true end

		for itemID,spellID in pairs(module.db.itemsToSpells) do
			module.db.spell_isTalent[spellID] = true
			if spellID > 330000 and not module.db.differentIcons[spellID] then
				local icon = select(5,GetItemInfoInstant(itemID))
				if icon ~= GetSpellTexture(spellID) then
					module.db.differentIcons[spellID] = icon
				end
			end
		end

		for k in pairs(module.db.spell_cdByTalent_isScalable) do
			if not module.db.spell_cdByTalent_scalable_data[k] then
				module.db.spell_cdByTalent_scalable_data[k]={[1]="*0.75"}
			end
		end

		if ExRT.isClassic then
			local n = {}
			for k in pairs(module.db.spell_isTalent) do
				if type(k) == "number" then
					n[#n+1] = GetSpellInfo(k) or "spell:"..k
				end
			end
			for _,v in pairs(n) do
				module.db.spell_isTalent[v] = true
			end
		end
		CLEU:Recreate()
	end
	function module:CreateSpellDB()
		local spellDB, AllSpells = module.db.spellDB, module.db.AllSpells
		local isTestMode = module.db.testMode
		local spellInMainDB = {}
		wipe(spellDB)

		local SCSSpells = module.db._SCSSpells
		if ExRT.isClassic and SCSSpells then
			wipe(SCSSpells)
		end

		local playerClass = ExRT.isClassic and select(2,UnitClass("player")) or nil
		local scd = module.db.spellCDSync
		local scdMap = module.db.spellCDSyncToSpell
		for i=1,#AllSpells do
			local data = AllSpells[i]
			if VMRT.ExCD2.CDE[ data[1] ] or isTestMode then
				spellDB[#spellDB+1] = data
				spellInMainDB[ data[1] ] = true
				if ExRT.isClassic and SCSSpells and type(data[1]) == "number" then
					SCSSpells[data[1]] = true
				end
				if ExRT.isClassic and scd and scdMap and playerClass and type(data[1]) == "number" and data[2] == playerClass and not scdMap[ data[1] ] then
					scd[#scd+1] = data[1]
					scdMap[ data[1] ] = data[1]
				end
			end
		end
		for i=1,#VMRT.ExCD2.userDB do
			local data = VMRT.ExCD2.userDB[i]
			if
				VMRT.ExCD2.CDE[ data[1] ] and
				not spellInMainDB[ data[1] ] and
				type(data[2]) == "string" and
				type(data[3]) == "number" and
				(data[4] or data[5] or data[6] or data[7] or data[8]) and
				((data[4] and data[4][1] and data[4][2] and data[4][3]) or not data[4]) and
				((data[5] and data[5][1] and data[5][2] and data[5][3]) or not data[5]) and
				((data[6] and data[6][1] and data[6][2] and data[6][3]) or not data[6]) and
				((data[7] and data[7][1] and data[7][2] and data[7][3]) or not data[7]) and
				((data[8] and data[8][1] and data[8][2] and data[8][3]) or not data[8])
			then
				spellDB[#spellDB+1] = data
				if ExRT.isClassic and SCSSpells and type(data[1]) == "number" then
					SCSSpells[data[1]] = true
				end
				if data.itemID and data[2] and strsplit(",",data[2]) == "ITEMS" then
					_db.itemsToSpells[data.itemID] = data[1]
					if data.isEquip then
						_db.spell_isTalent[ data[1] ] = true
					end
				end
			end
		end

		local _in49206, _in66233 = false, false
		for _i=1,#spellDB do
			local _id = spellDB[_i] and spellDB[_i][1]
			if _id == 49206 then _in49206 = true elseif _id == 66233 then _in66233 = true end
		end
		dprint("[CreateSpellDB] #spellDB=", #spellDB,
			"| CDE[49206]=", tostring(VMRT.ExCD2.CDE[49206]), "inDB=", tostring(_in49206),
			"| CDE[66233]=", tostring(VMRT.ExCD2.CDE[66233]), "inDB=", tostring(_in66233))

		module:CreateSpellData()

	end
end

function module:UpdateSpellDB(fullUpdate)
	if fullUpdate then
		module:CreateSpellDB()
		module:UpdateRoster()
	end
	UpdateAllData()
end

do
	local frame = CreateFrame("Frame",nil,UIParent)
	module.frame = frame
	frame:Hide()
	frame:SetPoint("CENTER",UIParent, "CENTER", 0, 0)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if self:IsMovable() then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		VMRT.ExCD2.Left = self:GetLeft()
		VMRT.ExCD2.Top = self:GetTop()
	end)
	frame.texture = frame:CreateTexture(nil, "BACKGROUND")
	frame.texture:SetColorTexture(0,0,0,0.3)
	frame.texture:SetAllPoints()
	module:RegisterHideOnPetBattle(frame)

	frame.colFrame = {}
end


local gsub_data = {}
local gsub_func = function(a)
	return gsub_data[a]
end
local classByName = {}
local function BarUpdateText(self)
	local barParent = self.parent

	local barData = self.data
	if not barData then


		return
	end


	local time = (self.curr_end or 0) - GetTime() + 1
	if barParent.methodsTextIgnoreActive then
		time = (self.curr_end_cd or 0) - GetTime() + 1
	end

	if barData.specialTimer then
		local newTime = barData.specialTimer()
		time = newTime and newTime+1 or time
	end

	local name = barData.name
	local spellName = barData.spellName

	local longtime,shorttime = nil

	if time > 3600 then
		longtime = "1+hour"
		shorttime = "1+hour"
	elseif time < 1 then
		longtime = ""
		shorttime = ""
	else
		longtime = format("%1.1d:%2.2d",time/60,time%60)
		if time < 11 then
			shorttime = format("%.01f",time - 1)
		elseif time < 60 then
			shorttime = format("%d",time)
		else
			shorttime = longtime
		end
	end

	local tClass = barData.targetClass or (barData.targetName and classByName[barData.targetName])
	if barParent.textShowTargetName and barData.targetName and time >= 1 then
		local tName = barData.targetName
		if tClass then
			tName = "|c" .. ExRT.F.classColor(tClass) .. tName .. "|r"
		end
		name = name .. " > " .. tName
	end
	if barData.specialAddText then
		name = name .. (barData.specialAddText() or "")
	end

	local name_time = time >= 1 and longtime or name
	local name_stime = time >= 1 and shorttime or name
	local offStatus = self.disStatus or ""
	local chargesCount = self.curr_charges and "("..self.curr_charges..")" or ""

	gsub_data.time = longtime
	gsub_data.stime = shorttime
	gsub_data.name = name
	gsub_data.name_time = name_time
	gsub_data.name_stime = name_stime
	gsub_data.spell = spellName
	gsub_data.status = offStatus
	gsub_data.charge = chargesCount
	local targetStr = (barData.targetName and time >= 1) and barData.targetName or ""
	if targetStr ~= "" and tClass and barParent.optionClassColorText then
		targetStr = "|c" .. ExRT.F.classColor(tClass) .. targetStr .. "|r"
	end
	gsub_data.target = targetStr

	if barParent.iconFontMode then
		if barParent.optionIconName then
			local n = barParent.textIconNameChars or 50
			gsub_data.name = utf8sub(gsub_data.name, 1, n)
			local rawTarget = (barData.targetName and time >= 1) and barData.targetName or ""
			rawTarget = utf8sub(rawTarget, 1, n)
			if rawTarget ~= "" and tClass and barParent.optionClassColorText then
				rawTarget = "|c" .. ExRT.F.classColor(tClass) .. rawTarget .. "|r"
			end
			gsub_data.target = rawTarget
			gsub_data.name_time = time >= 1 and longtime or gsub_data.name
			gsub_data.name_stime = time >= 1 and shorttime or gsub_data.name
		end

		local top = string_trim((barParent.iconFontTopTemplate or ""):gsub("%%([^%%]+)%%",gsub_func),nil)
		if self.textIconTop.text ~= top then
			self.textIconTop:SetText(top)
			self.textIconTop.text = top
		end
		local mid = string_trim((barParent.iconFontCenterTemplate or ""):gsub("%%([^%%]+)%%",gsub_func),nil)
		if self.textIconMid.text ~= mid then
			self.textIconMid:SetText(mid)
			self.textIconMid.text = mid
		end
		local bot = string_trim((barParent.iconFontBottomTemplate or ""):gsub("%%([^%%]+)%%",gsub_func),nil)
		if self.textIconBot.text ~= bot then
			self.textIconBot:SetText(bot)
			self.textIconBot.text = bot
		end

		if self.textLeft.text ~= "" then self.textLeft.text = ""; self.textLeft:SetText(" ") end
		if self.textRight.text ~= "" then self.textRight.text = ""; self.textRight:SetText(" ") end
		if self.textCenter.text ~= "" then self.textCenter.text = ""; self.textCenter:SetText("") end
		if self.textIcon.name ~= "" then
			self.textIcon:SetText("")
			self.textIcon.name = ""
		end
		if self.textIcon:IsShown() then
			self.textIcon:Hide()
		end
	else
		local left = string_trim(barParent.textTemplateLeft:gsub("%%([^%%]+)%%",gsub_func),nil)
		if self.textLeft.text ~= left then
			self.textLeft.text = left
			if left == "" then left = " " end
			self.textLeft:SetText(left)
		end

		local right = string_trim(barParent.textTemplateRight:gsub("%%([^%%]+)%%",gsub_func),nil)
		if self.textRight.text ~= right then
			self.textRight.text = right
			if right == "" then right = " " end
			self.textRight:SetText(right)
		end

		local center = string_trim(barParent.textTemplateCenter:gsub("%%([^%%]+)%%",gsub_func),nil)
		if self.textCenter.text ~= center then
			self.textCenter:SetText(center)
			self.textCenter.text = center
		end

		if barParent.optionIconName and (self.textIcon.name ~= barData.name or self.textIcon.numChars ~= barParent.textIconNameChars) then
			self.textIcon:SetText(utf8sub(barData.name,1,barParent.textIconNameChars))
			self.textIcon.name = barData.name
			self.textIcon.numChars = barParent.textIconNameChars
		end
		if not self.textIcon:IsShown() then
			self.textIcon:Show()
		end
	end

	local cdText
	if barParent.optionCooldownUseExRT then
		local style = barParent.textIconCDStyle
		time = time - 1
		if  time <= 0 then
			cdText = ""
		elseif time < 60 then
			if style == 1 or style == 2 or style == 5 or style == 7 or style == 8 or style == 11 then
				cdText = ceil(time)
			elseif style == 3 or style == 4 or style == 6 or style == 9 or style == 10 then
				cdText = format("%.1f",time)
			end
		elseif style == 1 or style == 3 then
			cdText = SecondsToTime(time, true)
		elseif style == 2 or style == 4 then
			cdText = SecondsToTime(time+60, true)
		elseif style == 5 or style == 6 then
			cdText = format("%d:%02d",time/60,time%60)
		elseif style == 7 or style == 9 then
			cdText = format("%dm",time/60)
		elseif style == 8 or style == 10 then
			cdText = format("%dm",time/60+1)
		elseif style == 11 then
			if time <= 99 then
				cdText = ceil(time)
			else
				cdText = format("%dm",time/60)
			end
		end
	end
	if self.textIconCD.text ~= cdText then
		self.textIconCD:SetText(cdText or "")
		self.textIconCD.text = cdText
	end
end

local function BarAnimation(self)
	local bar = self.bar
	local t = GetTime()

	if t > bar.curr_end then
		bar:Stop()
	else
		local width = (t - bar.curr_start) / bar.curr_dur
		if width > 1 then
			width = 1
		elseif width < 0 then
			width = 0
		end
		bar.timeline:SetShown(width ~= 0)
		bar.timeline:SetWidth(width * bar.timeline.width)

		bar.spark:SetPoint("CENTER",bar.statusbar,"LEFT", (t-bar.curr_start) / bar.curr_dur * bar.timeline.width,0)
	end
	self.c = self.c + 1
	if self.c > 2 then
		self.c = 0

		bar:UpdateText()
	end
end

local function BarAnimation_Reverse(self)
	local bar = self.bar
	local t = GetTime()

	if t > bar.curr_end then
		bar:Stop()
	else
		local width = (bar.curr_end - t) / bar.curr_dur
		if width > 1 then
			width = 1
		elseif width < 0 then
			width = 0
		end
		bar.timeline:SetShown(width ~= 0)
		bar.timeline:SetWidth(width * bar.timeline.width)

		bar.spark:SetPoint("CENTER",bar.statusbar,"LEFT", (bar.curr_dur - (t-bar.curr_start)) / bar.curr_dur * bar.timeline.width,0)
	end
	self.c = self.c + 1
	if self.c > 2 then
		self.c = 0

		bar:UpdateText()
	end
end

local function BarAnimation_NoAnimation(self)
	local bar = self.bar
	local t = GetTime()

	if t > bar.curr_end then
		bar:Stop()
	end
	self.c = self.c + 1
	if self.c > 2 then
		self.c = 0

		bar:UpdateText()
	end
end

local function StopBar(self)
	if self.curr_end == 0 then
		return
	end
  	self.anim:Stop()
  	self.spark:Hide()
 	self:UpdateStatus()
	if self:IsVisible() then
 		UpdateAllData()
	end
end

local function UpdateBar(self)
	local data = self.data
	if not data then
		self:Hide()
		return
	end
	if not self:IsShown() then
		self:Show()
	end

	self.iconTexture:SetTexture(data.icon)
	self:UpdateText()
end


local function BarStateAnimation(self)
	local bar = self.bar

	local progress = self:GetProgress()
	local b = bar.curr_anim_b
	if b then
		bar.background:SetVertexColor(b.r + bar.curr_anim_b_r*progress,b.g + bar.curr_anim_b_g*progress,b.b + bar.curr_anim_b_b*progress,bar.curr_anim_b_a)
	end
	local l = bar.curr_anim_l
	if l then
		bar.timeline:SetVertexColor(l.r + bar.curr_anim_l_r*progress,l.g + bar.curr_anim_l_g*progress,l.b + bar.curr_anim_l_b*progress,bar.curr_anim_l_af+bar.curr_anim_l_a*progress)
	end
	local t = bar.curr_anim_t
	if t then
		bar.textLeft:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
		bar.textRight:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
		bar.textCenter:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
		bar.textIcon:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
		bar.textIconCD:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
		bar.textIconTop:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
		bar.textIconMid:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
		bar.textIconBot:SetTextColor(t.r + bar.curr_anim_t_r*progress,t.g + bar.curr_anim_t_g*progress,t.b + bar.curr_anim_t_b*progress)
	end
end
local function BarStateAnimationFinished(self)
	self.bar.afterAnimFix = true
	self.bar:UpdateStatus()
end

local function UpdateBarStatus(self,isTitle)
	local data = self.data
	if not data then
		return
	end
	if self.isTitle then
		self:UpdateStyle()
		self.isTitle = nil
	end
	if data.specialUpdateData then
		data.specialUpdateData(data)
	end
	local parent = self.parent
	local currTime = GetTime()
	local lastUse = data.lastUse

	local active = lastUse + data.duration
	local cooldown = lastUse + data.cd

	if parent.methodsDisableActive then
		active = 0
	end

	local isActive = (active - currTime) > 0
	local isCooldown = (cooldown - currTime) > 0
	local t = (isActive and active) or (isCooldown and cooldown)
	local tOnlyCD = (isCooldown and cooldown)

	local isDisabled = data.disabled
	if isDisabled then
		isCooldown = true
	end
	if data.specialStatus then
		local var1,var2,var3,var4,var5 = data.specialStatus(data)
		if var5 then
			isCooldown = true
			isDisabled = true
		end
		if var2 then
			if var1 then
				isCooldown = true
				lastUse = var2
				t = var2 + var3
			else
				isCooldown = false
				t = nil
				if var4 then
					data.charge = var2
					data.cd = var3
				end
			end
		end
		data.isCharge = var4
	end

	self.curr_charges = nil

	local isCharge = nil
	if data.isCharge then
		if data.charge then
			if data.charge <= currTime and (data.charge+data.cd) > currTime then
				isCharge = true

				isCooldown = isCooldown and false

				self.curr_charges = 1
			elseif data.charge > currTime and not isActive then
				lastUse = data.charge - data.cd
				t = data.charge
				tOnlyCD = t

				isCooldown = true

				self.curr_charges = 0
			end
		else
			self.curr_charges = 2
		end
	end

	if isCharge and not isActive then
		self.curr_start = data.charge
		self.curr_end = data.charge+data.cd
		self.curr_dur = data.cd

		if parent.optionTimeLineAnimation == 1 then
			self.timeline:SetShown(false)
		else
			self.timeline:SetShown(true)
			self.timeline:SetWidth(self.timeline.width)
		end
		self.timeline.SetWidth = self.timeline.IsShown
		self.timeline.SetShown = self.timeline.IsShown
		self.spark:Show()
		self.anim:Play()
		if not self:IsVisible() then self.anim:Pause() end
	elseif t then
		self.curr_start = lastUse
		self.curr_end = t
		self.curr_dur = t - lastUse
		self.curr_end_cd = tOnlyCD

		self.timeline.SetWidth = self.timeline._SetWidth
		self.timeline.SetShown = self.timeline._SetShown

		self.spark:Show()
		self.anim:Play()
		if not self:IsVisible() then self.anim:Pause() end
	else
		self.curr_start = 0
		self.curr_end = 1
		self.curr_dur = 1
		self.curr_end_cd = 1

		self.timeline.SetWidth = self.timeline._SetWidth
		self.timeline.SetShown = self.timeline._SetShown

	  	self.spark:Hide()
		if self.anim:IsPlaying() then self.anim:Stop() end

	  	if isDisabled then
	  		self.timeline:Hide()
	  	else
	  		if parent.optionTimeLineAnimation == 1 then
	  			self.timeline:Hide()
	  		else
	 			self.timeline:SetWidth(self.timeline.width)
	 			self.timeline:Show()
	 		end
	 	end
	end

	local doStandartColors = true
	if parent.optionSmoothAnimation and not self.afterAnimFix then
		doStandartColors = false
		if not parent.optionClassColorBackground then
			local ctFrom, ctTo = nil
			if isActive then
				ctTo = parent.optionColorBackgroundActive
			elseif isCooldown then
				ctTo = parent.optionColorBackgroundCooldown
			else
				ctTo = parent.optionColorBackgroundDefault
			end

			if self.curr_anim_state == 1 then
				ctFrom = parent.optionColorBackgroundActive
			elseif self.curr_anim_state == 2 then
				ctFrom = parent.optionColorBackgroundCooldown
			else
				ctFrom = parent.optionColorBackgroundDefault
			end

			self.curr_anim_b = ctFrom
			self.curr_anim_b_r = ctTo.r - ctFrom.r
			self.curr_anim_b_g = ctTo.g - ctFrom.g
			self.curr_anim_b_b = ctTo.b - ctFrom.b
			self.curr_anim_b_a = parent.optionAlphaBackground
		else
			self.curr_anim_b = nil
			local colorTable = data.classColor
			self.background:SetVertexColor(colorTable.r,colorTable.g,colorTable.b,parent.optionAlphaBackground)
		end
		if not parent.optionClassColorTimeLine then
			local ctFrom, ctTo = nil
			if isActive then
				ctTo = parent.optionColorTimeLineActive
			elseif isCooldown then
				ctTo = parent.optionColorTimeLineCooldown
			else
				ctTo = parent.optionColorTimeLineDefault
			end

			if self.curr_anim_state == 1 then
				ctFrom = parent.optionColorTimeLineActive
				self.curr_anim_l_af = 1
				self.curr_anim_l_a = parent.optionAlphaTimeLine - 1
			elseif self.curr_anim_state == 2 then
				ctFrom = parent.optionColorTimeLineCooldown
				self.curr_anim_l_af = 1
				self.curr_anim_l_a = parent.optionAlphaTimeLine - 1
			else
				ctFrom = parent.optionColorTimeLineDefault
				self.curr_anim_l_af = 0
				self.curr_anim_l_a = parent.optionAlphaTimeLine
			end
			if not parent.optionAnimation then
				self.curr_anim_l_af = 0
				self.curr_anim_l_a = 0
			end

			self.curr_anim_l = ctFrom
			self.curr_anim_l_r = ctTo.r - ctFrom.r
			self.curr_anim_l_g = ctTo.g - ctFrom.g
			self.curr_anim_l_b = ctTo.b - ctFrom.b
		else
			self.curr_anim_l = data.classColor
			if self.curr_anim_state == 1 then
				self.curr_anim_l_af = 1
				self.curr_anim_l_a = parent.optionAlphaTimeLine - 1
			elseif self.curr_anim_state == 2 then
				self.curr_anim_l_af = 1
				self.curr_anim_l_a = parent.optionAlphaTimeLine - 1
			else
				self.curr_anim_l_af = 0
				self.curr_anim_l_a = parent.optionAlphaTimeLine
			end
			if not parent.optionAnimation then
				self.curr_anim_l_af = 0
				self.curr_anim_l_a = 0
			end
			self.curr_anim_l_r = 0
			self.curr_anim_l_g = 0
			self.curr_anim_l_b = 0
		end
		if not parent.optionClassColorText then
			local ctFrom, ctTo = nil
			if isActive then
				ctTo = parent.optionColorTextActive
			elseif isCooldown then
				ctTo = parent.optionColorTextCooldown
			else
				ctTo = parent.optionColorTextDefault
			end

			if self.curr_anim_state == 1 then
				ctFrom = parent.optionColorTextActive
			elseif self.curr_anim_state == 2 then
				ctFrom = parent.optionColorTextCooldown
			else
				ctFrom = parent.optionColorTextDefault
			end

			self.curr_anim_t = ctFrom
			self.curr_anim_t_r = ctTo.r - ctFrom.r
			self.curr_anim_t_g = ctTo.g - ctFrom.g
			self.curr_anim_t_b = ctTo.b - ctFrom.b
		else
			self.curr_anim_t = nil
			local colorTable = data.classColor
			self.textLeft:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
			self.textRight:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
			self.textCenter:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
			self.textIcon:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
			self.textIconCD:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
			self.textIconTop:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
			self.textIconMid:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
			self.textIconBot:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		end

		if isActive and self.curr_anim_state ~= 1 then
			self.curr_anim_state = 1
			if self.anim_state:IsPlaying() then self.anim_state:Stop() end
			self.anim_state:Play()
			if not self:IsVisible() then self.anim_state:Pause() end
		elseif isCooldown and self.curr_anim_state ~= 2 then
			self.curr_anim_state = 2
			if self.anim_state:IsPlaying() then self.anim_state:Stop() end
			self.anim_state:Play()
			if not self:IsVisible() then self.anim_state:Pause() end
		elseif not isCooldown and not isActive and self.curr_anim_state then
			self.curr_anim_state = nil
			if self.anim_state:IsPlaying() then self.anim_state:Stop() end
			self.anim_state:Play()
			if not self:IsVisible() then self.anim_state:Pause() end
		else
			doStandartColors = true
		end
	end
	if doStandartColors then
		local colorTable = nil
		if parent.optionClassColorBackground then
			colorTable = data.classColor
		else
			if isActive then
				colorTable = parent.optionColorBackgroundActive
			elseif isCooldown then
				colorTable = parent.optionColorBackgroundCooldown
			else
				colorTable = parent.optionColorBackgroundDefault
			end
		end
		self.background:SetVertexColor(colorTable.r,colorTable.g,colorTable.b,parent.optionAlphaBackground)

		if parent.optionClassColorTimeLine then
			colorTable = data.classColor
		else
			if isActive then
				colorTable = parent.optionColorTimeLineActive
			elseif isCooldown then
				colorTable = parent.optionColorTimeLineCooldown
			else
				colorTable = parent.optionColorTimeLineDefault
			end
		end
		self.timeline:SetVertexColor(colorTable.r,colorTable.g,colorTable.b,parent.optionAlphaTimeLine)

		if parent.optionClassColorText then
			colorTable = data.classColor
		else
			if isActive then
				colorTable = parent.optionColorTextActive
			elseif isCooldown then
				colorTable = parent.optionColorTextCooldown
			else
				colorTable = parent.optionColorTextDefault
			end
		end
		self.textLeft:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		self.textRight:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		self.textCenter:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		self.textIcon:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		self.textIconCD:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		self.textIconTop:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		self.textIconMid:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
		self.textIconBot:SetTextColor(colorTable.r,colorTable.g,colorTable.b)
	end
	self.afterAnimFix = nil

	if parent.optionGray then
		if isCooldown and not isActive then
			self.iconTexture:SetDesaturated(true)
		else
			self.iconTexture:SetDesaturated(nil)
		end
	end

	if parent.optionCooldown then

		if isActive then
			self.cooldown:Show()
			self.cooldown:SetReverse(true)
			self.cooldown:SetDrawSwipe(true)
			self.cooldown:SetCooldown(self.curr_start,self.curr_end-self.curr_start)
			self.glowStart(self.icon)
		elseif isCharge then
			self.cooldown:Show()
			self.cooldown:SetReverse(false)
			self.cooldown:SetDrawSwipe(false)
			self.cooldown:SetCooldown(self.curr_start,self.curr_end-self.curr_start)
			self.glowStop(self.icon)
		elseif isCooldown then
			self.cooldown:Show()
			self.cooldown:SetReverse(false)
			self.cooldown:SetDrawSwipe(true)
			if isDisabled then
				self.cooldown:SetCooldown(currTime,0)
			else
				self.cooldown:SetCooldown(self.curr_start,self.curr_dur)
			end
			self.glowStop(self.icon)
		else
			self.cooldown:Hide()
			self.glowStop(self.icon)
		end
	else
		self.glowStop(self.icon)
	end

	local alpha = 1
	if parent.methodsAlphaNotInRange then
		if data.outofrange then
			alpha = parent.methodsAlphaNotInRangeNum
			self:SetAlpha(alpha)
		else
			self:SetAlpha(1)
		end
	end

	if (parent.optionAlphaCooldown or 1) < 1 then
		if isCooldown and not isActive then
			self:SetAlpha(parent.optionAlphaCooldown)
		else
			self:SetAlpha(alpha)
		end
	end

	if isDisabled == 2 then
		self.disStatus = L_Offline
	elseif isDisabled == 1 then
		self.disStatus = L_Dead
	else
		self.disStatus = nil
	end

	self:UpdateText()
end

local function BarCreateTitle(self)
	local parent = self.parent

	local iconWidth = parent.iconSize or 24
	local iconHeight = parent.iconHeight or iconWidth

	self.statusbar:ClearAllPoints()	self.statusbar:SetHeight(iconHeight)
	self.icon:ClearAllPoints()	self.icon:SetSize(iconWidth,iconHeight)

	self.textLeft:SetText("")
	self.textLeft.text = nil
	self.textRight:SetText("")
	self.textRight.text = nil
	self.textCenter:SetText("")
	self.textCenter.text = nil
	self.textIcon:SetText("")
	self.textIcon.name = nil
	self.textIconCD:SetText("")
	self.textIconTop:SetText("")
	self.textIconTop.text = nil
	self.textIconMid:SetText("")
	self.textIconMid.text = nil
	self.textIconBot:SetText("")
	self.textIconBot.text = nil

	if parent.optionIconPosition == 2 then
		self.icon:Show()
		self.statusbar:SetPoint("LEFT",self,0,0)
		self.statusbar:SetPoint("RIGHT",self,-iconWidth,0)
		self.icon:SetPoint("RIGHT",self,0,0)

		self.textRight:SetPoint("LEFT",self,0,0)

		self.textRight:SetTextColor(1,1,1)
		self.textRight:SetText(self.data.spellName)
	elseif parent.optionIconPosition == 1 then
		self.icon:Show()
		self.statusbar:SetPoint("LEFT",self,iconWidth,0)
		self.statusbar:SetPoint("RIGHT",self,0,0)
		self.icon:SetPoint("LEFT",self,0,0)

		self.textLeft:SetTextColor(1,1,1)
		self.textLeft:SetText(self.data.spellName)
	end

	self.curr_start = 0
	self.curr_end = 1
	self.curr_dur = 1

  	self.spark:Hide()
  	self.anim:Stop()

 	self.timeline:Hide()

  	self.background:SetVertexColor(0,0,0,parent.optionAlphaTimeLine)

  	self.iconTexture:SetTexture(self.data.icon)
  	self.cooldown:Hide()

  	self:SetAlpha(1)
  	self:Show()

  	self.isTitle = true
end

local function LineIconOnHover(self)
	local parent = self:GetParent()
	if not parent.data then	return end
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink("spell:"..parent.data.db[1])
	GameTooltip:Show()
end

local function LineClickFrameOnHover_OnUpdate(self)
	if not self:IsMouseOver() then
		self:SetScript("OnUpdate",nil)
		if self.IconIsHovered then
			GameTooltip_Hide()
			self.IconIsHovered = nil
		end
		return
	end
	local isHover = self:GetParent().icon:IsMouseOver()
	if isHover and not self.IconIsHovered then
		LineIconOnHover(self)
		self.IconIsHovered = true
	elseif not isHover and self.IconIsHovered then
		GameTooltip_Hide()
		self.IconIsHovered = nil
	end
end

local function LineClickFrameOnHover(self)
	self.IconIsHovered = nil
	self:SetScript("OnUpdate",LineClickFrameOnHover_OnUpdate)
end

local function LineIconOnClick(self)
	local parent = self:GetParent()
	if not parent.data then	return end
	if parent.data.specialClick then
		parent.data.specialClick(parent.data)
		return
	end
	local time = parent.data.lastUse + parent.data.cd - GetTime()
	if time < 0 then return end
	local text = parent.data.name.." - "..parent.data.spellName..": "..format("%1.1d:%2.2d",time/60,time%60)
	local chat_type = ExRT.F.chatType(true)
	SendChatMessage(text,chat_type)
end
local function LineIconOnClickWhisper(self)
	local parent = self:GetParent()
	if not parent.data then	return end
	if parent.data.specialClick then
		parent.data.specialClick(parent.data)
		return
	end
	local time = parent.data.lastUse + parent.data.cd - GetTime()
	if time > 0 then return end
	local spellLink = GetSpellLink(parent.data.db[1])
	if not spellLink or spellLink == "" then
		spellLink = parent.data.spellName
	end
	local text = "Use "..spellLink
	local chat_type = ExRT.F.chatType(true)
	SendChatMessage(text,"WHISPER",nil,parent.data.fullName)
end
local function LineIconOnClickBoth(self)
	local parent = self:GetParent()
	if not parent.data then	return end
	local time = parent.data.lastUse + parent.data.cd - GetTime()
	if time > 0 then
		return LineIconOnClick(self)
	else
		return LineIconOnClickWhisper(self)
	end
end

local function UpdateBarStyle(self)
	local parent = self.parent

	local width = parent.barWidth or 100
	local iconWidth = parent.iconSize or 24
	local iconHeight = parent.iconHeight or iconWidth
	local height = iconHeight

	self:SetSize(width,height)

	self.textLeft:ClearAllPoints()	self.textLeft:SetSize(0,height)
	self.textRight:ClearAllPoints()	self.textRight:SetSize(0,height)
	self.textCenter:ClearAllPoints()self.textCenter:SetSize(0,height)
					self.textIcon:SetSize(iconWidth,iconHeight)
	self.icon:ClearAllPoints()	self.icon:SetSize(iconWidth,iconHeight)
	self.statusbar:ClearAllPoints()	self.statusbar:SetHeight(height)
					self.spark:SetSize(10,height+10)
					self.cooldown:SetSize(iconWidth,iconHeight)

	local iconOffset = iconWidth
	if parent.optionIconPosition == 3 or parent.optionIconTitles then
		self.icon:Hide()
		self.statusbar:SetPoint("LEFT",self,0,0)
		self.statusbar:SetPoint("RIGHT",self,0,0)
		iconOffset = 0
	elseif parent.optionIconPosition == 2 then
		self.icon:Show()
		self.statusbar:SetPoint("LEFT",self,0,0)
		self.statusbar:SetPoint("RIGHT",self,-iconWidth,0)
		self.icon:SetPoint("RIGHT",self,0,0)
	else
		self.icon:Show()
		self.statusbar:SetPoint("LEFT",self,iconWidth,0)
		self.statusbar:SetPoint("RIGHT",self,0,0)
		self.icon:SetPoint("LEFT",self,0,0)
	end

	self.timeline.width = width - iconOffset
	self.timeline:SetSize(width - iconOffset,height)

	if parent.optionIconHideBlizzardEdges then
		self.iconTexture:SetTexCoord(.1,.9,.1,.9)
	else
		self.iconTexture:SetTexCoord(0,1,0,1)
	end

	if parent.optionHideSpark then
		self.spark:SetTexture("")
	else
		self.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	end

	local fontOutlineFix = parent.fontOutline and 3 or 0
	local lx, ly = parent.fontLeftX or 0, parent.fontLeftY or 0
	local rx, ry = parent.fontRightX or 0, parent.fontRightY or 0
	local cx, cy = parent.fontCenterX or 0, parent.fontCenterY or 0
	if parent.textTemplateLeft:find("time%%") then
		self.textLeft:SetPoint("LEFT",self.statusbar,1+lx,ly)
		self.textRight:SetPoint("RIGHT",self.statusbar,-1+fontOutlineFix+rx,ry)
		self.textRight:SetPoint("LEFT",self.textLeft,"RIGHT",rx,ry)

		self.textCenter:SetPoint("LEFT",self.textLeft,"RIGHT",cx,cy)
		self.textCenter:SetPoint("RIGHT",self.statusbar,cx,cy)
	elseif parent.textTemplateCenter:find("time%%") then
		self.textLeft:SetPoint("LEFT",self.statusbar,1+lx,ly)
		self.textRight:SetPoint("RIGHT",self.statusbar,-1+fontOutlineFix+rx,ry)

		self.textCenter:SetPoint("LEFT",self.statusbar,cx,cy)
		self.textCenter:SetPoint("RIGHT",self.statusbar,cx,cy)
	else
		self.textRight:SetPoint("RIGHT",self.statusbar,-1+fontOutlineFix+rx,ry)
		self.textLeft:SetPoint("LEFT",self.statusbar,1+lx,ly)
		self.textLeft:SetPoint("RIGHT",self.textRight,"LEFT",lx,ly)

		self.textCenter:SetPoint("LEFT",self.statusbar,cx,cy)
		self.textCenter:SetPoint("RIGHT",self.textRight,"LEFT",cx,cy)
	end

	self.textIcon:ClearAllPoints()
	self.textIcon:SetPoint("TOPLEFT",self.icon,"TOPLEFT",parent.fontIconX or 0,parent.fontIconY or 0)

	self.textIconCD:ClearAllPoints()
	self.textIconCD:SetPoint("CENTER",self.cooldown,"CENTER",parent.fontIconCDX or 0,parent.fontIconCDY or 0)

	self.barWidth = width

	local textureFile = parent.textureFile or module.db.colsDefaults.textureFile
	local isValidTexture = self.background:SetTexture(textureFile)
	if not isValidTexture then
		textureFile = module.db.colsDefaults.textureFile
		self.background:SetTexture(textureFile)
	end
	self.timeline:SetTexture(textureFile)

	local isValidFont = nil

	self.textLeft:SetFont(parent.fontLeftName,parent.fontLeftSize,parent.fontLeftOutline and "OUTLINE" or "")
	self.textRight:SetFont(parent.fontRightName,parent.fontRightSize,parent.fontRightOutline and "OUTLINE" or "")
	self.textCenter:SetFont(parent.fontCenterName,parent.fontCenterSize,parent.fontCenterOutline and "OUTLINE" or "")
	self.textIcon:SetFont(parent.fontIconName,parent.fontIconSize,parent.fontIconOutline and "OUTLINE" or "")
	self.textIconCD:SetFont(parent.fontIconCDName,parent.fontIconCDSize,parent.fontIconCDOutline and "OUTLINE" or "")
	self.textIconTop:SetFont(parent.fontIconTopName,parent.fontIconTopSize,parent.fontIconTopOutline and "OUTLINE" or "")
	self.textIconMid:SetFont(parent.fontIconMidName,parent.fontIconMidSize,parent.fontIconMidOutline and "OUTLINE" or "")
	self.textIconBot:SetFont(parent.fontIconBotName,parent.fontIconBotSize,parent.fontIconBotOutline and "OUTLINE" or "")

	local fontOffset = 0
	fontOffset = parent.fontLeftShadow and 1 or 0	self.textLeft:SetShadowOffset(1*fontOffset,-1*fontOffset)
	fontOffset = parent.fontRightShadow and 1 or 0	self.textRight:SetShadowOffset(1*fontOffset,-1*fontOffset)
	fontOffset = parent.fontCenterShadow and 1 or 0	self.textCenter:SetShadowOffset(1*fontOffset,-1*fontOffset)
	fontOffset = parent.fontIconShadow and 1 or 0	self.textIcon:SetShadowOffset(1*fontOffset,-1*fontOffset)
	fontOffset = parent.fontIconCDShadow and 1 or 0	self.textIconCD:SetShadowOffset(1*fontOffset,-1*fontOffset)
	fontOffset = parent.fontIconTopShadow and 1 or 0	self.textIconTop:SetShadowOffset(1*fontOffset,-1*fontOffset)
	fontOffset = parent.fontIconMidShadow and 1 or 0	self.textIconMid:SetShadowOffset(1*fontOffset,-1*fontOffset)
	fontOffset = parent.fontIconBotShadow and 1 or 0	self.textIconBot:SetShadowOffset(1*fontOffset,-1*fontOffset)

	if parent.iconFontMode then
		local function applyIconFontText(fs, slot, savedPos, savedAnchor, savedGrowth, savedX, savedY)
			local _, info = module.db.ResolveIconFontPos(slot, savedPos, savedAnchor)
			fs:ClearAllPoints()
			fs:SetPoint(info[1], self.icon, info[2], savedX or 0, savedY or 0)
			local growth = (savedGrowth and savedGrowth ~= 0) and savedGrowth or info[4]
			if info[3] or growth == 0 then
				fs:SetJustifyH("CENTER")
			elseif growth == 2 then
				fs:SetJustifyH("RIGHT")
			else
				fs:SetJustifyH("LEFT")
			end
		end
		applyIconFontText(self.textIconTop, "Top",    parent.iconFontTopPos,    parent.iconFontTopAnchor,    parent.iconFontTopGrowth,    parent.iconFontTopX,    parent.iconFontTopY)
		applyIconFontText(self.textIconMid, "Center", parent.iconFontCenterPos, parent.iconFontCenterAnchor, parent.iconFontCenterGrowth, parent.iconFontCenterX, parent.iconFontCenterY)
		applyIconFontText(self.textIconBot, "Bottom", parent.iconFontBottomPos, parent.iconFontBottomAnchor, parent.iconFontBottomGrowth, parent.iconFontBottomX, parent.iconFontBottomY)
		self.textIconTop:Show()
		self.textIconMid:Show()
		self.textIconBot:Show()
		self.textIcon:Hide()
		self.textIcon:SetText("")
		self.textIcon.name = nil
	else
		self.textIconTop:Hide()
		self.textIconMid:Hide()
		self.textIconBot:Hide()
		self.textIcon:Show()
	end

	local cdFont = self.cooldown:GetRegions()
	cdFont:SetFont(cdFont:GetFont(),parent.fontCDSize or 16,"OUTLINE")

	self.iconTexture:SetDesaturated(nil)

	self:SetAlpha(1)

	self.cooldown:Hide()
	self.cooldown:SetHideCountdownNumbers(parent.optionCooldownHideNumbers and true or false)
	self.cooldown:SetDrawEdge(parent.optionCooldownShowSwipe and true or false)

	if parent.optionCooldownUseExRT or (not parent.optionCooldownHideNumbers and GetCVar("countdownForCooldowns") == "1") then
		self.cooldown.noCooldownCount = true
	else
		self.cooldown.noCooldownCount = nil
	end

	self.textIcon:SetText("")
	self.textIcon.name = nil

	if parent.optionCooldownUseExRT then
		self.textIconCD:Show()
	else
		self.textIconCD:Hide()
	end

	if parent.glowStop ~= self.glowStop then
		self.glowStop(self.icon)
	end
	self.glowStart = parent.glowStart or ExRT.NULLfunc
	self.glowStop = parent.glowStop or ExRT.NULLfunc

	if parent.optionAnimation then
		if parent.optionStyleAnimation == 1 then
			self.anim:SetScript("OnLoop",BarAnimation_Reverse)
		else
			self.anim:SetScript("OnLoop",BarAnimation)
		end
	else
		self.anim:SetScript("OnLoop",BarAnimation_NoAnimation)
		self.spark:SetTexture("")
		self.timeline:Hide()
	end

	if parent.methodsLineClick and parent.methodsLineClickWhisper then
		self.clickFrame:SetScript("OnClick",LineIconOnClickBoth)
		self.clickFrame:Show()
		self.clickFrame:SetFrameLevel(9000)
	elseif parent.methodsLineClick then
		self.clickFrame:SetScript("OnClick",LineIconOnClick)
		self.clickFrame:Show()
		self.clickFrame:SetFrameLevel(9000)
	elseif parent.methodsLineClickWhisper then
		self.clickFrame:SetScript("OnClick",LineIconOnClickWhisper)
		self.clickFrame:Show()
		self.clickFrame:SetFrameLevel(9000)
	else
		self.clickFrame:SetScript("OnClick",nil)
		self.clickFrame:Hide()
	end
	if parent.methodsIconTooltip then
		if not self.clickFrame:IsShown() then
			self.clickFrame:Show()
			self.clickFrame:SetFrameLevel(9000)
		end
		self.clickFrame:SetScript("OnEnter",LineClickFrameOnHover)
	else
		self.clickFrame:SetScript("OnEnter",nil)
		self.clickFrame:SetScript("OnUpdate",nil)
	end

	local borderSize = parent.textureBorderSize
	if borderSize == 0 then
		self.border.top:Hide()
		self.border.bottom:Hide()
		self.border.left:Hide()
		self.border.right:Hide()
	else
		self.border.top:ClearAllPoints()
		self.border.bottom:ClearAllPoints()
		self.border.left:ClearAllPoints()
		self.border.right:ClearAllPoints()

		self.border.top:SetPoint("TOPLEFT",self,"TOPLEFT",-borderSize,borderSize)
		self.border.top:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",borderSize,0)

		self.border.bottom:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",-borderSize,-borderSize)
		self.border.bottom:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",borderSize,0)

		self.border.left:SetPoint("TOPLEFT",self,"TOPLEFT",-borderSize,0)
		self.border.left:SetPoint("BOTTOMRIGHT",self,"BOTTOMLEFT",0,0)

		self.border.right:SetPoint("TOPLEFT",self,"TOPRIGHT",0,0)
		self.border.right:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",borderSize,0)

		self.border.top:SetColorTexture(parent.textureBorderColorR,parent.textureBorderColorG,parent.textureBorderColorB,parent.textureBorderColorA)
		self.border.bottom:SetColorTexture(parent.textureBorderColorR,parent.textureBorderColorG,parent.textureBorderColorB,parent.textureBorderColorA)
		self.border.left:SetColorTexture(parent.textureBorderColorR,parent.textureBorderColorG,parent.textureBorderColorB,parent.textureBorderColorA)
		self.border.right:SetColorTexture(parent.textureBorderColorR,parent.textureBorderColorG,parent.textureBorderColorB,parent.textureBorderColorA)

		self.border.top:Show()
		self.border.bottom:Show()
		self.border.left:Show()
		self.border.right:Show()
	end

	self.anim_state.timer:SetDuration(parent.optionSmoothAnimationDuration)

	self.atf = nil
	self.atf2 = nil

	self.textLeft.text = nil
	self.textRight.text = nil
	self.textCenter.text = nil
	self.textIcon.name = nil

	if parent.Masque_Group and self.Masque_Group ~= parent.Masque_Group then
		parent.Masque_Group:AddButton(self, {Icon = self.iconTexture, Cooldown = self.cooldown}, "MRT_CD_ICON", true)
		self.Masque_Group = parent.Masque_Group
	elseif not parent.Masque_Group and self.Masque_Group then
		self.Masque_Group = nil
	end

	if module.db.plugin and type(module.db.plugin.UpdateBarStyle)=="function" then
		module.db.plugin.UpdateBarStyle(self)
	end
end

local function AnimationControl_Hide(self)
	if self.anim:IsPlaying() then
		self.anim:Pause()
	end
	if self.anim_state:IsPlaying() then
		self.anim_state:Pause()
	end
end
local function AnimationControl_Show(self)
	if self.anim:IsPaused() then
		self.anim:Play()
	end
	if self.anim_state:IsPaused() then
		self.anim_state:Play()
	end
end
local function AnimationControl_Play(self)
	self:SetScript("OnUpdate",BarStateAnimation)
end
local function AnimationControl_Pause(self)
	self:SetScript("OnUpdate",nil)
end

local function CreateBar(parent)
	local self = CreateFrame("Frame",nil,parent)

	self.parent = parent

	local statusbar = CreateFrame("StatusBar", nil, self)
	statusbar:SetPoint("TOPRIGHT")
	statusbar:SetPoint("BOTTOMLEFT")
	self.statusbar = statusbar

	local timeline = statusbar:CreateTexture(nil, "BACKGROUND")
	timeline:SetPoint("LEFT")
	timeline._SetWidth = timeline.SetWidth
	timeline._SetShown = timeline.SetShown
	self.timeline = timeline

	local spark = statusbar:CreateTexture(nil, "BACKGROUND", nil, 3)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER",statusbar,"RIGHT", 0,0)
	spark:SetAlpha(0.5)
	spark:Hide()
	self.spark = spark

	local anim = self:CreateAnimationGroup()
	anim:SetLooping("REPEAT")
	anim.c = 0
	anim.timer = anim:CreateAnimation()
	anim.timer:SetDuration(0.05)
	anim:Stop()
	anim:SetScript("OnLoop",BarAnimation)
	anim.bar = self
	self.anim = anim

	local anim_state = self:CreateAnimationGroup()
	anim_state.timer = anim_state:CreateAnimation()
	anim_state.timer:SetDuration(0.5)
	anim_state:Stop()

	anim_state:SetScript("OnPlay",AnimationControl_Play)
	anim_state:SetScript("OnPause",AnimationControl_Pause)
	anim_state:SetScript("OnFinished",BarStateAnimationFinished)
	anim_state.bar = self
	self.anim_state = anim_state

	self:SetScript("OnHide",AnimationControl_Hide)
	self:SetScript("OnShow",AnimationControl_Show)

	local icon = CreateFrame("Frame",nil,self)
	icon:SetPoint("TOPLEFT", 0, 0)
	local iconTexture = icon:CreateTexture(nil, "BACKGROUND")
	iconTexture:SetAllPoints()
	self.icon = icon
	self.iconTexture = iconTexture

	local cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	cooldown:SetDrawEdge(false)

	cooldown:SetPoint("CENTER")
	cooldown:SetHideCountdownNumbers(false)
	cooldown:SetDrawEdge(false)
	cooldown:SetDrawSwipe(true)
	self.cooldown = cooldown

	local background = self:CreateTexture(nil, "BACKGROUND", nil, -7)
	background:SetAllPoints()
	self.background = background

	self.textLeft = ELib:Text(self.statusbar,nil,nil,"GameFontNormal"):Point(1,0):Color()
	self.textRight = ELib:Text(self.statusbar,nil,nil,"GameFontNormal"):Size(40,0):Point("TOPRIGHT",1,0):Right():Color()
	self.textCenter = ELib:Text(self.statusbar,nil,nil,"GameFontNormal"):Point(0,0):Center():Color()
	self.textIcon = ELib:Text(icon,nil,nil,"GameFontNormal"):Point(0,0):Center():Bottom():Color()
	self.textIconCD = ELib:Text(cooldown,nil,nil,"GameFontNormal"):Point("CENTER"):Center():Middle():Color()

	self.textIcon:SetDrawLayer("ARTWORK",3)
	self.textIconCD:SetDrawLayer("ARTWORK",3)

	local iconOverlay = CreateFrame("Frame",nil,icon)
	iconOverlay:SetAllPoints(icon)
	iconOverlay:SetFrameLevel((cooldown:GetFrameLevel() or 0) + 12)
	self.iconOverlay = iconOverlay

	self.textIconTop = ELib:Text(iconOverlay,nil,nil,"GameFontNormal"):Color()
	self.textIconMid = ELib:Text(iconOverlay,nil,nil,"GameFontNormal"):Color()
	self.textIconBot = ELib:Text(iconOverlay,nil,nil,"GameFontNormal"):Color()
	self.textIconTop:SetDrawLayer("OVERLAY",7)
	self.textIconMid:SetDrawLayer("OVERLAY",7)
	self.textIconBot:SetDrawLayer("OVERLAY",7)
	self.textIconTop:SetMaxLines(1)
	self.textIconMid:SetMaxLines(1)
	self.textIconBot:SetMaxLines(1)
	self.textIconTop:Hide()
	self.textIconMid:Hide()
	self.textIconBot:Hide()

	self.glowStart = ExRT.NULLfunc
	self.glowStop = ExRT.NULLfunc


	self.textLeft:SetMaxLines(1)
	self.textRight:SetMaxLines(1)
	self.textCenter:SetMaxLines(1)

	self.border = {}
	self.border.top = self:CreateTexture(nil, "BACKGROUND")
	self.border.bottom = self:CreateTexture(nil, "BACKGROUND")
	self.border.left = self:CreateTexture(nil, "BACKGROUND")
	self.border.right = self:CreateTexture(nil, "BACKGROUND")

	self.clickFrame = CreateFrame("Button",nil,self)
	self.clickFrame:SetAllPoints()
	self.clickFrame:Hide()

	self.Stop = StopBar
	self.Update = UpdateBar
	self.UpdateStyle = UpdateBarStyle
	self.UpdateText = BarUpdateText
	self.UpdateStatus = UpdateBarStatus
	self.CreateTitle = BarCreateTitle

	return self
end
module.db.debugBarFuncs = {
	Stop = StopBar,
	Update = UpdateBar,
	UpdateStyle = UpdateBarStyle,
	UpdateText = BarUpdateText,
	UpdateStatus = UpdateBarStatus,
	CreateTitle = BarCreateTitle,
	BarAnimation = BarAnimation,
	BarAnimation_Reverse = BarAnimation_Reverse,
	BarAnimation_NoAnimation = BarAnimation_NoAnimation,
	BarStateAnimation = BarStateAnimation,
	BarStateAnimationFinished = BarStateAnimationFinished,
}

local function FixFontsOnLoad(self)
	local defGameFont = GameFontWhite:GetFont()
	for i=1,#self.lines do
		local bar = self.lines[i]

		bar.textLeft:SetFont(defGameFont,self.fontLeftSize - 1,"")
		bar.textRight:SetFont(defGameFont,self.fontRightSize - 1,"")
		bar.textCenter:SetFont(defGameFont,self.fontCenterSize - 1,"")
		bar.textIcon:SetFont(defGameFont,self.fontIconSize - 1,"")
		bar.textIconCD:SetFont(defGameFont,self.fontIconSize - 1,"")

		bar:UpdateStyle()
	end
	return true
end

function module:CreateColumn(parent,frameName)
	local columnFrame = CreateFrame("Frame",frameName,parent)
	columnFrame:EnableMouse(false)
	columnFrame:SetMovable(false)

	columnFrame.texture = columnFrame:CreateTexture(nil, "BACKGROUND")
	columnFrame.texture:SetColorTexture(0,0,0,0)
	columnFrame.texture:SetAllPoints()

	columnFrame.lockTexture = columnFrame:CreateTexture(nil, "BACKGROUND")
	columnFrame.lockTexture:SetColorTexture(0,0,0,0)
	columnFrame.lockTexture:SetAllPoints()

	columnFrame.lines = {}

	columnFrame.BlackList = {}

	return columnFrame
end

for i=1,module.db.maxColumns do
	local columnFrame = module:CreateColumn(module.frame,"MRTRaidCooldownCol"..i)
	module.frame.colFrame[i] = columnFrame
	columnFrame:RegisterForDrag("LeftButton")
	columnFrame:SetScript("OnDragStart", function(self)
		if self:IsMovable() then
			self:StartMoving()
		end
	end)
	columnFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		if self.ATFenabled then
			return
		end
		VMRT.ExCD2.colSet[i].posX = self:GetLeft()
		VMRT.ExCD2.colSet[i].posY = self:GetTop()
	end)
	columnFrame.colNum = i

	module:RegisterHideOnPetBattle(columnFrame)

	ELib:FixPreloadFont(columnFrame,FixFontsOnLoad)
end

do
	local isInCombat = false
	local isInEncounter = false
	function module:updateCombatVisibility()
		local _, zoneType = GetInstanceInfo()
		local inRaid = IsInRaid()
		for i=1,module.db.maxColumns do
			local columnFrame = module.frame.colFrame[i]

			local state = columnFrame.optionIsEnabled

			if not columnFrame.methodsOnlyInCombat then

			elseif isInCombat and columnFrame.optionIsEnabled then
				state = state and true
			elseif not isInCombat then
				state = false
			end

			if zoneType == "arena" then
				if not columnFrame.visibilityArena then
					state = false
				end
			elseif zoneType == "party" then
				if not columnFrame.visibility5ppl then
					state = false
				end
			elseif zoneType == "pvp" then
				if not columnFrame.visibilityBG then
					state = false
				end
			elseif zoneType == "raid" then
				if not columnFrame.visibilityRaid then
					state = false
				end
			elseif zoneType == "scenario" then
				if not columnFrame.visibility3ppl then
					state = false
				end
			else
				if not columnFrame.visibilityWorld then
					state = false
				end
			end

			if (columnFrame.visibilityPartyType == 2 and not inRaid) or (columnFrame.visibilityPartyType == 1 and inRaid) then
				state = false
			end

			columnFrame:SetShown(state)
		end
		if not VMRT.ExCD2.SplitOpt then
			if VMRT.ExCD2.colSet[module.db.maxColumns+1].methodsOnlyInCombat then
				if isInCombat then
					module.frame:Show()
				else
					module.frame:Hide()
				end
			elseif module.frame.IsEnabled then
				module.frame:Show()
			end
		end
	end
	function module:toggleCombatVisibility(currState,callType)
		local isInstance, instanceType = IsInInstance()
		if instanceType == "arena" or instanceType == "pvp" then
			currState = true
		elseif instanceType == "raid" or instanceType == "party" then
			if callType == 1 then
				isInEncounter = currState
			elseif callType == 2 then
				currState = currState or isInEncounter
			end
		elseif callType == 1 then
			return
		end
		isInCombat = currState
		module:updateCombatVisibility()
	end
end

do
	local lastSaving = GetTime() - 15
	function SaveCDtoVar(overwrite)
		local currTime = GetTime()
		if ((currTime - lastSaving) < 20 and not overwrite) or module.db.testMode then
			return
		end
		if not VMRT or not VMRT.ExCD2 then
			return
		end
		local VMRT_ExCD2_Save = VMRT.ExCD2.Save
		wipe(VMRT_ExCD2_Save)
		for i=1,#_C do
			local unitSpellData = _C[i]
			if unitSpellData.lastUse + unitSpellData.cd - currTime > 0 then
				VMRT_ExCD2_Save[ (unitSpellData.fullName or "?")..(unitSpellData.db[1] or 0) ] = {unitSpellData.lastUse,unitSpellData.cd}
			else
				VMRT_ExCD2_Save[ (unitSpellData.fullName or "?")..(unitSpellData.db[1] or 0) ] = nil
			end
		end
		lastSaving = currTime
	end
end

local function AfterCombatResetFunction(isArena)
	if ExRT.isLK then
		for i=1,#_C do
			local unitSpellData = _C[i]
			local uSpecID = _db.specInDBase[globalGUIDs[unitSpellData.fullName] or 0]
			if not unitSpellData.db[uSpecID] then
				for sid = 4, 8 do
					if unitSpellData.db[sid] then uSpecID = sid; break end
				end
			end

			if (unitSpellData.cd > 0 and (_db.spell_afterCombatReset[unitSpellData.db[1]] or (unitSpellData.db[uSpecID] and unitSpellData.db[uSpecID][2] >= (isArena and 0 or 120) or unitSpellData.cd >= (isArena and 0 or 180)))) and (not _db.spell_afterCombatNotReset[unitSpellData.db[1]] or isArena) then
				unitSpellData.lastUse = 0
				unitSpellData.charge = nil

				if unitSpellData.specialAfterCombatReset then
					unitSpellData.specialAfterCombatReset(unitSpellData)
				end

				if unitSpellData.bar and unitSpellData.bar.data == unitSpellData then
					unitSpellData.bar:UpdateStatus()
				end
			end
		end
	end
	SaveCDtoVar(true)
end

local function TestMode(h)
	if not h then
		for i=1,#_C do
			local data = _C[i]
			local uSpecID = module.db.specInDBase[VMRT.ExCD2.gnGUIDs[data.fullName] or 0]
			if not data.db[uSpecID] then
				for sid = 4, 8 do
					if data.db[sid] then uSpecID = sid; break end
				end
			end
			if data.db[uSpecID] then
				if fastrandom(0,100) < 80 then
					data.cd = data.db[uSpecID][2]
					data.lastUse = GetTime() - fastrandom(0,data.db[uSpecID][2]) - fastrandom()
					data.duration = data.db[uSpecID][3]
				end
			end
		end
	else
		for i=1,#_C do
			local data = _C[i]
			data.lastUse = 0
			data.duration = 0
		end
	end
	UpdateAllData()
end

function module.IsPvpTalentsOn(unit)

	if ExRT.isLK or ExRT.isClassic or ExRT.isBC then
		return false
	end
	local _, zoneType = GetInstanceInfo()
	if zoneType == 'arena' or zoneType == 'pvp' then
		return true
	end
	if (zoneType == 'none' or not zoneType) and C_PvP_IsWarModeDesired and C_PvP_IsWarModeDesired() and UnitPhaseReason and Enum and Enum.PhaseReason and UnitPhaseReason(unit) ~= Enum.PhaseReason.WarMode then
		return true
	end
	return false
end

do
	local inColsCount = {}


	local maxColumns = _db.maxColumns
	local maxLinesInCol = _db.maxLinesInCol
	local specInDBase = _db.specInDBase
	local spell_isTalent = _db.spell_isTalent
	local spell_isPvpTalent = _db.spell_isPvpTalent
	local spell_isRaidCD = _db.spell_isRaidCD
	local session_gGUIDs = _db.session_gGUIDs
	local session_TalentBroadcastReceived = _db.session_TalentBroadcastReceived
	local spell_isPetAbility = _db.spell_isPetAbility
	local session_Pets = _db.session_Pets
	local petsAbilities = _db.petsAbilities
	local spell_talentReplaceOther = _db.spell_talentReplaceOther
	local spell_charge_fix = _db.spell_charge_fix
	local def_col = _db.def_col
	local columnsTable = module.frame.colFrame

	local LibGroupTalents = LibStub and LibStub("LibGroupTalents-1.0", true)
	local function LGT_NameToUnit(name)
		if not name then return nil end
		if UnitName("player") == name then return "player" end
		local nRaid = GetNumRaidMembers and GetNumRaidMembers() or 0
		if nRaid > 0 then
			for i = 1, nRaid do
				local u = "raid"..i
				if UnitName(u) == name then return u end
			end
		else
			local nParty = GetNumPartyMembers and GetNumPartyMembers() or 0
			for i = 1, nParty do
				local u = "party"..i
				if UnitName(u) == name then return u end
			end
		end
		return nil
	end
	local TALENT_SPELL_ALIASES = {
		[31230] = {31228, 31229, 31230},
		[14185] = {14185},
		[66233] = {31850, 31851, 31852, 66233},
		[31850] = {31850, 31851, 31852, 66233},
		[31851] = {31850, 31851, 31852, 66233},
		[31852] = {31850, 31851, 31852, 66233},
	}
	local function LGT_TryName(guid, unit, sname)
		if guid and LibGroupTalents.GUIDHasTalent then
			local r = LibGroupTalents:GUIDHasTalent(guid, sname)
			if r ~= nil then return r end
		end
		if unit and LibGroupTalents.UnitHasTalent then
			local r = LibGroupTalents:UnitHasTalent(unit, sname)
			if r ~= nil then return r end
		end
		return nil
	end
	local function LGT_UnitHasTalent(name, spellID)
		if not LibGroupTalents or not name or type(spellID) ~= "number" then return nil end
		local unit = LGT_NameToUnit(name)
		local guid = unit and UnitGUID(unit) or nil
		local primaryName = GetSpellInfo(spellID)
		if primaryName then
			local r = LGT_TryName(guid, unit, primaryName)
			if r then return r end
		end
		local aliases = TALENT_SPELL_ALIASES[spellID]
		if aliases then
			for i = 1, #aliases do
				local aliasID = aliases[i]
				if aliasID ~= spellID then
					local aname = GetSpellInfo(aliasID)
					if aname and aname ~= primaryName then
						local r = LGT_TryName(guid, unit, aname)
						if r then return r end
					end
				end
			end
		end
		if not unit and LibGroupTalents.roster then
			for rguid, r in pairs(LibGroupTalents.roster) do
				if r and r.name == name then
					if primaryName then
						local hit = LibGroupTalents:GUIDHasTalent(rguid, primaryName)
						if hit then return hit end
					end
					if aliases then
						for i = 1, #aliases do
							local aname = GetSpellInfo(aliases[i])
							if aname then
								local hit = LibGroupTalents:GUIDHasTalent(rguid, aname)
								if hit then return hit end
							end
						end
					end
				end
			end
		end
		return nil
	end
	local function LGT_HasTalentData(name)
		if not LibGroupTalents or not name or not LibGroupTalents.roster then return nil end
		local unit = LGT_NameToUnit(name)
		local guid = unit and UnitGUID(unit) or nil
		if guid then
			local r = LibGroupTalents.roster[guid]
			if r and r.active and r.talents and r.talents[r.active] then return true end
		end
		for _, r in pairs(LibGroupTalents.roster) do
			if r and r.name == name and r.active and r.talents and r.talents[r.active] then return true end
		end
		return nil
	end
	local playerTalentSet = nil
	local playerTalentSetClass = nil
	local function RebuildPlayerTalentSet()
		playerTalentSet = {}
		playerTalentSetClass = select(2, UnitClass("player"))
		if not ExRT.isLK or not GetTalentInfoClassic then return end
		local InspectModule = MRT.A and MRT.A.Inspect
		local treeData = InspectModule and InspectModule.TALENTDATA and InspectModule.TALENTDATA[playerTalentSetClass or ""]
		if not treeData then return end
		for spec = 1, 3 do
			local mrtTab = treeData[spec]
			if mrtTab then
				for talPos = 1, 31 do
					local _, _, tier, column, rank = GetTalentInfoClassic(spec, talPos)
					if tier and column and rank and rank > 0 then
						local tierData = mrtTab[tier]
						local talentSpellID = tierData and tierData[column]
						if type(talentSpellID) == "number" then
							playerTalentSet[talentSpellID] = rank
							local provides = module.db.spell_talentProvideAnotherTalents and module.db.spell_talentProvideAnotherTalents[talentSpellID]
							if provides then
								for _, v in pairs(provides) do
									if type(v) == "number" then playerTalentSet[v] = rank end
								end
							end
						end
					end
				end
			end
		end
	end
	module.RebuildPlayerTalentSet = RebuildPlayerTalentSet
	local function PlayerHasTalentDirect(spellID)
		if not ExRT.isLK or type(spellID) ~= "number" then return nil end
		if not playerTalentSet or playerTalentSetClass ~= select(2, UnitClass("player")) then
			RebuildPlayerTalentSet()
		end
		return playerTalentSet[spellID]
	end

	local _CV = {}
	local _CV_Len = 0
	module.db._CV = _CV

	local playerName = ExRT.SDB.charName

	function module:DumpTalentDebug()
		local pName = playerName
		print("|cff33ff99[MRT/CD debug]|r player="..tostring(pName).." class="..tostring(select(2,UnitClass("player"))))
		print("  VMRT.ExCD2.CDE[13750]="..tostring(VMRT.ExCD2.CDE[13750]))
		print("  VMRT.ExCD2.CDE[51690]="..tostring(VMRT.ExCD2.CDE[51690]))
		print("  spell_isTalent[13750]="..tostring(spell_isTalent[13750]))
		print("  spell_isTalent[51690]="..tostring(spell_isTalent[51690]))
		RebuildPlayerTalentSet()
		local cnt = 0
		for sid in pairs(playerTalentSet or {}) do cnt = cnt + 1 end
		print("  playerTalentSet entries: "..cnt)
		print("  playerTalentSet[13750]="..tostring(playerTalentSet[13750]))
		print("  playerTalentSet[51690]="..tostring(playerTalentSet[51690]))
		local sg = session_gGUIDs[pName]
		local sgcnt = 0
		if type(sg) == "table" then for _ in pairs(sg) do sgcnt = sgcnt + 1 end end
		print("  session_gGUIDs["..tostring(pName).."] entries: "..sgcnt)
		print("  session_gGUIDs["..tostring(pName).."][13750]="..tostring(sg and sg[13750]))
		print("  session_gGUIDs["..tostring(pName).."][51690]="..tostring(sg and sg[51690]))
		print("  specID="..tostring(globalGUIDs and globalGUIDs[pName]).." (raw gnGUIDs)")
		local specID = globalGUIDs and globalGUIDs[pName] or 0
		local unitSpecID = specInDBase[specID] or 4
		print("  unitSpecID="..tostring(unitSpecID).." (from specInDBase["..tostring(specID).."])")
		local shown, total = 0, 0
		for i=1,#_C do
			local data = _C[i]
			local db = data.db
			local name = data.fullName
			local spellID = db[1]
			if name == pName and spell_isTalent[spellID] then
				total = total + 1
				local sn = GetSpellInfo(spellID) or "?"
				local inSG = session_gGUIDs[name][spellID] and "Y" or "-"
				local inLGT = LGT_UnitHasTalent(name, spellID) and "Y" or "-"
				local inDirect = PlayerHasTalentDirect(spellID) and "Y" or "-"
				local specID = globalGUIDs[name] or 0
				local unitSpecID = specInDBase[specID] or 4
				local specOk = (db[unitSpecID] or db[4] or db[5] or db[6] or db[7] or db[8]) and "Y" or "-"
				local talentPass = (session_gGUIDs[name][spellID] or LGT_UnitHasTalent(name, spellID) or PlayerHasTalentDirect(spellID)) and "Y" or "-"
				if talentPass == "Y" then shown = shown + 1 end
				print(string.format("  %d %s | spec=%s talent=%s [sg=%s lgt=%s direct=%s]", spellID, sn, specOk, talentPass, inSG, inLGT, inDirect))
			end
		end
		print(string.format("  TOTAL talent-CD for self: %d, passing talent-gate: %d", total, shown))
	end

	function module:CDDump(spellID)
		spellID = tonumber(spellID)
		if not spellID then print("|cffff4444[CDDump]|r usage: /mrt cddump <spellID>"); return end
		local sn = GetSpellInfo(spellID) or "?"
		local now = GetTime()
		print("|cff33ff99[CDDump]|r "..spellID.." "..sn
			.." | isTalent="..tostring(spell_isTalent[spellID])
			.." CDE="..tostring(VMRT.ExCD2.CDE[spellID])
			.." auraList="..tostring(module.db.spell_aura_list[spellID])
			.." startByFade="..tostring(module.db.spell_startCDbyAuraFade[spellID])
			.." threatBuff="..tostring(module.db.spell_threatBuff and module.db.spell_threatBuff[spellID]))
		local start, dur = GetSpellCooldown(spellID)
		local realRemain = (start and dur and dur > 0) and (start + dur - now) or 0
		print(string.format("  self: known=%s realCD start=%s dur=%s remain=%.1f",
			tostring(IsSpellKnown and IsSpellKnown(spellID)), tostring(start), tostring(dur), realRemain))
		local found = 0
		for i = 1, #_C do
			local data = _C[i]
			if data.db and data.db[1] == spellID then
				found = found + 1
				local name = data.fullName
				local specID = globalGUIDs[name] or 0
				local uSpec = specInDBase[specID] or 4
				local cdRem = (data.lastUse and data.cd) and (data.lastUse + data.cd - now) or 0
				local durRem = (data.lastUse and data.duration) and (data.lastUse + data.duration - now) or 0
				print(string.format("  %s spec=%d/%d vis=%s | cd=%s dur=%s lastUse=%s | cdRem=%.1f durRem=%.1f",
					tostring(name), specID, uSpec, data.vis and "Y" or "N",
					tostring(data.cd), tostring(data.duration), tostring(data.lastUse), cdRem, durRem))
				print(string.format("     db4=%s sg=%s lgt=%s lgtData=%s target=%s",
					data.db[4] and "Y" or "N",
					session_gGUIDs[name][spellID] and "Y" or "N",
					LGT_UnitHasTalent(name, spellID) and "Y" or "N",
					(spell_isTalent[spellID] and LGT_HasTalentData(name)) and "Y" or "N",
					tostring(data.targetName)))
			end
		end
		if found == 0 then
			print("  NOT in _C (no tracked line). CDE="..tostring(VMRT.ExCD2.CDE[spellID])
				.." -> либо выключен, либо отфильтрован на сборке ростера")
		end
	end

	local IsPvpTalentsOn = module.IsPvpTalentsOn

	local saveDataTimer = 0
	local lastBattleResChargesStatus = nil

	local function sort_f(a,b)
		if a.column ~= b.column then
			return a.column < b.column
		elseif a.sorting ~= b.sorting then
			if a.rsort then
				return (a.sorting or 0) > (b.sorting or 0)
			else
				return (a.sorting or 0) < (b.sorting or 0)
			end
		elseif a.rsort then
			return (a.sort or 0) > (b.sort or 0)
		else
			return (a.sort or 0) < (b.sort or 0)
		end
	end

	local oneSpellPerCol = {} for i=1,maxColumns do oneSpellPerCol[i]={} end
	local prevLineForGUID,prevLineForGUID_wiped = {}
	local reviewID = 0

	local strataToStrata = {
		["BACKGROUND"]="LOW",
		["LOW"]="MEDIUM",
		["MEDIUM"]="HIGH",
		["HIGH"]="DIALOG",
		["DIALOG"]="FULLSCREEN",
		["FULLSCREEN"]="FULLSCREEN_DIALOG",
		["FULLSCREEN_DIALOG"]="TOOLTIP",
		["TOOLTIP"]="TOOLTIP",
	}

	local LGF = LibStub("LibGetFrame-1.0",true)
	local LGFNullOpt = {}

	local needReposAttached

	local HiddenOnCD = {}

	local function SortAllData()
		local currTime = GetTime()
	  	for i=1,_CV_Len do
	  		local data = _CV[i]
			local columnFrame = columnsTable[data.column] or columnsTable[1]
			if columnFrame and columnFrame.methodsSortByAvailability then
				local cd = data.lastUse + data.cd - currTime

				local charge = data.charge
				if data.isCharge and charge then
					if charge <= currTime and (charge+data.cd) > currTime then
						cd = -1
					elseif charge > currTime then
						cd = charge - currTime
					end
				end

				if data.disabled then
					cd = cd > 0 and cd or 49999
				elseif data.disable_oncd then
					cd = 49999
				end
				if cd > 0 then
					cd = cd + 50000
				end

				local dur = 0
				if columnFrame.methodsSortActiveToTop then
					dur = data.lastUse + data.duration - currTime
					if dur < 0 then
						dur = 0
					end
				end
				data.sorting = dur > 0 and dur or cd > 0 and cd or 0

				if columnFrame.methodsNewSpellNewLine then
					data.sorting = (data.sort2 or data.db[1]) * 100000 + data.sorting
				end
			else
				data.sorting = 0
			end
			data.rsort = columnFrame and columnFrame.methodsReverseSorting
	  	end
		sort(_CV,sort_f)
	end
	module.SortAllData = SortAllData

	local function TalentReplaceOtherCheck(spellID,name)
		local spellData = spell_talentReplaceOther[spellID]
		if type(spellData) == 'number' then
			if not spell_isPvpTalent[spellData] or module.IsPvpTalentsOn(name) then
				return session_gGUIDs[name][spellData]
			end
		else
			for i=1,#spellData do
				if session_gGUIDs[name][ spellData[i] ] then
					return true
				end
			end
		end
		return false
	end
	local function IsOnCD(data)
		local currTime = GetTime()

		local isOnCD = not data.isCharge and (data.lastUse + data.cd) > currTime
		if data.disable_oncd then
			isOnCD = true
		end

		return isOnCD or (data.isCharge and data.charge and data.charge > currTime)
	end

	function UpdateAllData()
		reviewID = reviewID + 1

		playerTalentSet = nil

		local isTestMode = _db.testMode
		local CDECol = VMRT.ExCD2.CDECol
		local VMRT_CDE = VMRT.ExCD2.CDE
		local currTime = GetTime()
		wipe(_CV)
		_CV_Len = 0
		for i=1,#_C do
			local data = _C[i]
			local db = data.db
			local name = data.fullName
			local spellID = db[1]

			local specID = globalGUIDs[name] or 0
			local unitSpecID = specInDBase[specID] or 4

			local lgtHasData = spell_isTalent[spellID] and LGT_HasTalentData(name)
			local ownsTalent
			if lgtHasData then
				ownsTalent = LGT_UnitHasTalent(name, spellID) or (name == playerName and PlayerHasTalentDirect(spellID))
			else
				ownsTalent = session_gGUIDs[name][spellID] or LGT_UnitHasTalent(name, spellID) or (name == playerName and (PlayerHasTalentDirect(spellID) or (not spell_isTalent[spellID] and IsSpellKnown and IsSpellKnown(spellID))))
			end
			if module.db.phaseDebug and (spellID == 31230 or spellID == 31821 or spellID == 64205) then
				print("|cffff4444[PH GATE]|r",spellID,name,"spec="..tostring(specID).."/"..tostring(unitSpecID),"db4="..(db[4] and "Y" or "N"),"sg="..(session_gGUIDs[name][spellID] and "Y" or "N"),"lgt="..(LGT_UnitHasTalent(name, spellID) and "Y" or "N"),"lgtData="..(lgtHasData and "Y" or "N"),"self="..(name==playerName and "Y" or "N"))
			end
			if isTestMode or ((VMRT_CDE[spellID]) and
			(db[unitSpecID] or db[4] or db[5] or db[6] or db[7] or db[8]) and
			(db[4] or ownsTalent) and
			(not spell_isPvpTalent[spellID] or (session_gGUIDs[name][spellID] and IsPvpTalentsOn(name))) and
			(not spell_isPetAbility[spellID] or session_Pets[name] == spell_isPetAbility[spellID] or (session_Pets[name] and petsAbilities[ session_Pets[name] ] and petsAbilities[ session_Pets[name] ][1] == spell_isPetAbility[spellID]) or (type(spell_isPetAbility[spellID]) == "table" and session_Pets[name] and ExRT.F.table_find(spell_isPetAbility[spellID],session_Pets[name]))) and
			(not spell_talentReplaceOther[spellID] or not TalentReplaceOtherCheck(spellID,name)) and
			(not data.specialCheck or data.specialCheck(data,currTime))
			) then
				data.vis = true

				local unitRole = data.checkRole and ExRT.F.GetUnitRaidRole and ExRT.F.GetUnitRaidRole(name)
				local col = (data.checkRole and unitRole and CDECol[spellID..";"..unitRole]) or CDECol[spellID..";"..(unitSpecID-3)] or CDECol[spellID..";1"] or FindAnyUserColumn(CDECol, spellID) or def_col[spellID..";"..(unitSpecID-3)] or def_col[spellID..";1"] or db[3] or 1
				if type(col) ~= "number" or col < 1 or col > module.db.maxColumns then col = 1 end
				data.column = col

				local forceUpdate

				local isCharge = spell_charge_fix[ spellID ]
				if isCharge and spell_isPvpTalent[isCharge] and not module.IsPvpTalentsOn(name) then
					isCharge = false
				end
				if isCharge then
					if session_gGUIDs[name][isCharge] then
						if not data.isCharge then
							forceUpdate = true
							data.charge = data.lastUse
						end
						data.isCharge = true
						isCharge = true
					else
						if data.isCharge then
							forceUpdate = true
						end
						data.isCharge = nil
						isCharge = nil
					end
				elseif data.isCharge then
					data.isCharge = nil
					forceUpdate = true
				end

				local columnFrame = columnsTable[col]
				if not columnFrame then
					col = 1
					data.column = 1
					columnFrame = columnsTable[1]
					if not columnFrame then
						return
					end
				end

				local isOnCD = not isCharge and (data.lastUse + data.cd) > currTime
				if data.disable_oncd then
					isOnCD = true
				end

				local isOnCDWithCharge = isOnCD or (isCharge and data.charge and data.charge > currTime)

				if columnFrame.optionShownOnCD and not isOnCDWithCharge then
					data.vis = nil
				end
				if columnFrame.methodsOnlyNotOnCD and isOnCDWithCharge then
					data.vis = nil
					HiddenOnCD[data] = true
				end
				if columnFrame.methodsHideOwnSpells and name == playerName then
					data.vis = nil
				end

				local whiteList = columnFrame.WhiteList
				if whiteList then
					if not whiteList[data.loweredName] then
						data.vis = nil
					end
				else
					local blackList = columnFrame.BlackList
					if blackList[data.loweredName] or (blackList[spellID] and blackList[spellID][data.loweredName]) then
						data.vis = nil
					end
				end

				local prevDisabledStatus = data.disabled
				local isDead = status_UnitIsDead[ name ]
				local isOffline = status_UnitIsDisconnected[ name ]
				if (isDead or isOffline) and not columnFrame.methodsCDOnlyTime and spellID ~= 20608 then
					data.disabled = isOffline and 2 or 1
				else
					data.disabled = nil
				end

				local prevOutOfRange = data.outofrange
				if status_UnitIsOutOfRange[ name ] then
					data.outofrange = true
				else
					data.outofrange = nil
				end

				if columnFrame.methodsOneSpellPerCol and data.vis then
					local oneSpellPerColCurr = oneSpellPerCol[col][spellID]
					if not oneSpellPerColCurr then
						oneSpellPerColCurr = {}
						oneSpellPerCol[col][spellID] = oneSpellPerColCurr
					end
					local isOnCD = isOnCD or data.disabled
					if oneSpellPerColCurr[1] ~= reviewID then
						oneSpellPerColCurr[1] = reviewID
						oneSpellPerColCurr[2] = data
						oneSpellPerColCurr[3] = isOnCD
					elseif oneSpellPerColCurr[3] and not isOnCD then
						oneSpellPerColCurr[2].vis = nil
						oneSpellPerColCurr[1] = reviewID
						oneSpellPerColCurr[2] = data
						oneSpellPerColCurr[3] = isOnCD
					elseif data.disabled then
						data.vis = nil
					elseif oneSpellPerColCurr[3] and isOnCD then
						local prevData = oneSpellPerColCurr[2]
						if (prevData.lastUse + prevData.cd) > (data.lastUse + data.cd) then
							prevData.vis = nil
							oneSpellPerColCurr[1] = reviewID
							oneSpellPerColCurr[2] = data
							oneSpellPerColCurr[3] = isOnCD
						else
							data.vis = nil
						end
					else
						data.vis = nil
					end
				end

				local bar = data.bar
				if bar and bar.data == data and (data.disabled ~= prevDisabledStatus or data.outofrange ~= prevOutOfRange or forceUpdate) then
					data.bar:UpdateStatus()
				end

				if columnFrame.ATFenabled then
					needReposAttached = true
				end

				_CV_Len = _CV_Len + 1
				_CV[_CV_Len] = data
			else
				data.vis = nil
			end
		end
		SortAllData()
	end
	module.UpdateAllData = UpdateAllData

	local statusTimer2 = 0
	local auraPollTimer = 0
	local timerATFRepos = 0
	local timerATFReset = 15
	local ATFFrames = {}

	function module:ATFFrameDataReset()
		timerATFReset = 100
	end

	function module:timer(elapsed)
		local forceUpdateAllData

		if not _db.isEncounter and IsEncounterInProgress() then
			_db.isEncounter = true
			local _,_,difficulty = GetInstanceInfo()
			if difficulty == 14 or difficulty == 15 or difficulty == 16 or difficulty == 17 or difficulty == 7 then
				_db.isResurectDisabled = true
			end
			module:toggleCombatVisibility(true,1)
		elseif _db.isEncounter and not IsEncounterInProgress() then
			_db.isEncounter = nil
			_db.isResurectDisabled = nil
			if GetDifficultyForCooldownReset() and not module.db.disableCDresetting then
				AfterCombatResetFunction()
				forceUpdateAllData = true
			end
			module:toggleCombatVisibility(false,1)
		end


		statusTimer2 = statusTimer2 + elapsed
		if statusTimer2 > 0.25 then
			statusTimer2 = 0
			for i,unit in pairs(status_UnitsToCheck) do
				local inRange,isRange = UnitInRange(unit)
				local outOfRange = isRange and not inRange
				if status_UnitIsOutOfRange[ unit ] ~= outOfRange then
					forceUpdateAllData = true
					status_UnitIsOutOfRange[ unit ] = outOfRange
				end

				local isDead = UnitIsDeadOrGhost(unit)
				if isDead ~= status_UnitIsDead[ unit ] then
					forceUpdateAllData = true
					status_UnitIsDead[ unit ] = isDead
				end

				local isOffline = not UnitIsConnected(unit)
				if isOffline ~= status_UnitIsDisconnected[ unit ] then
					forceUpdateAllData = true
					status_UnitIsDisconnected[ unit ] = isOffline
				end
			end


			local charges,_,started,duration
			if not ExRT.isWotLKOnly then
				charges,_,started,duration = GetSpellCharges(20484)
			end
			if charges ~= lastBattleResChargesStatus then
				local charge = nil
				if charges then
					if charges > 0 then
						charge = started
						started = 0
					end
				else
					started = 0
					duration = 0
					charge = nil
				end
				for i=1,_CV_Len do
					local data = _CV[i]
					if module.db.spell_battleRes[ data.db[1] ] then
						data.lastUse = started
						data.cd = duration
						data.charge = charge

						local bar = data.bar
						if bar and bar.data == data then
							bar:UpdateStatus()
						end
					end
				end
				forceUpdateAllData = true

				if charges and lastBattleResChargesStatus and charges < lastBattleResChargesStatus then
					module.db.historyUsage[#module.db.historyUsage + 1] = {time(),20484,"*",GetEncounterTime()}
				end
				lastBattleResChargesStatus = charges
			end

			for data in pairs(HiddenOnCD) do
				if not IsOnCD(data) then
					forceUpdateAllData = true
					HiddenOnCD[data] = nil
				end
			end
		end

		auraPollTimer = auraPollTimer + elapsed
		if auraPollTimer > 1 then
			auraPollTimer = 0
			local startMap = _db.spell_startCDbyUnitAura
			if startMap and (_db.isEncounter or RaidInCombat()) then
				local nowT = GetTime()
				for i=1,#status_UnitsToCheck do
					local unit = status_UnitsToCheck[i]
					local lines = _db.cdsNavData[unit]
					if lines then
						for idx=1,40 do
							local auraName,_,_,_,_,_,_,_,_,c10,c11 = UnitAura(unit,idx)
							if not auraName then break end
							local auraSpellID = c11 or c10
							local cdSpellID = auraSpellID and startMap[auraSpellID]
							if cdSpellID then
								local line = lines[cdSpellID]
								if line and (not line.lastUse or (line.lastUse + (line.cd or 0)) <= nowT) then
									CLEUstartCD(line)
								end
							end
						end
					end
				end
			end
		end

		if forceUpdateAllData then
			UpdateAllData()
		end

		for i=1,maxColumns do
			inColsCount[i] = 0
			columnsTable[i].lastSpell = nil
		end
		for i=1,_CV_Len do
			local data = _CV[i]
			if data.vis then
				local col = data.column
				local numberInCol = inColsCount[col] + 1

				local barParent = columnsTable[col]

				if numberInCol <= barParent.optionLinesMax then
					local spellID = data.db[1]

					if barParent.methodsNewSpellNewLine and barParent.lastSpell ~= spellID then
						local fix = 0
						for j=numberInCol,maxLinesInCol do
							local bar_now = barParent.lines[numberInCol + fix]
							if bar_now then
								if bar_now.IsNewLine then
									break
								else
									if bar_now.data then
										bar_now.data = nil
										bar_now:Update()
									end
									fix = fix + 1
								end
							end
						end
						numberInCol = numberInCol + fix
					end
					if barParent.optionIconTitles and barParent.lastSpell ~= spellID then
						local bar = barParent.lines[numberInCol]
						if bar and (bar.data ~= data or not bar.isTitle) then
							bar.data = data
							bar:CreateTitle()
						end
						numberInCol = numberInCol + 1
					end
					if barParent.methodsNewSpellNewLine and barParent.optionIconTitles and barParent.frameColumns > 1 and barParent.lastSpell == spellID then
						local bar_now = barParent.lines[numberInCol]
						if bar_now and bar_now.IsNewLine then
							if bar_now.data then
								bar_now.data = nil
								bar_now:Update()
							end
							numberInCol = numberInCol + 1
						end
					end

					barParent.lastSpell = spellID

					inColsCount[col] = numberInCol
					local bar = barParent.lines[numberInCol]
					if bar and bar.data ~= data then
						bar.data = data

						data.bar = bar

						bar:Update()
						bar:UpdateStatus()
					end
				end
			end
		end

		timerATFRepos = timerATFRepos + elapsed
		local ATFProcess
		if timerATFRepos > 1 or needReposAttached then
			timerATFRepos = 0
			needReposAttached = false
			if LGF then
				ATFProcess = true
			end
		end


		timerATFReset = timerATFReset + elapsed
		if timerATFReset > 20 then
			timerATFReset = 0

			for _,v in pairs(ATFFrames) do
				wipe(v)
			end
		end

		for i=1,maxColumns do
			local col = columnsTable[i]
			if col.IsColumnEnabled then
				local start = inColsCount[i]
				if start > col.optionLinesMax then
					start = col.optionLinesMax
				end
				for j=start+1,col.NumberLastLinesActive do
					local bar = col.lines[j]
					if bar and bar.data then
						bar.data = nil
						bar:Update()
					end
				end
				col.NumberLastLinesActive = start

				if ATFProcess and col.ATFenabled then
					prevLineForGUID_wiped = nil
					for j=1,start do
						local bar = col.lines[j]
						if bar.data then
							local guid = bar.data.guid or "unk"
							local optList = col.ATFFramePrior or LGFNullOpt
							if not ATFFrames[optList] then
								ATFFrames[optList] = {}
							end
							local frame = ATFFrames[optList][guid]
							if not frame then
								frame = LGF.GetFrame(guid, optList) or 0
								if frame ~= 0 and frame.GetParent and frame.GetName then
									local fname = frame:GetName()
									if (not fname or not fname:find("^ElvUF_") or fname:find("Health$")) then
										local p = frame:GetParent()
										if p and p.GetName then
											local pname = p:GetName()
											if pname and pname:find("^ElvUF_") and not pname:find("Health$") then
												frame = p
											end
										end
									end
								end
								ATFFrames[optList][guid] = frame
							end
							if frame ~= 0 then
								if not prevLineForGUID_wiped then
									prevLineForGUID_wiped = true
									wipe(prevLineForGUID)
								end

								local prevBar = prevLineForGUID[guid]
								if prevBar then
									bar.ATFcounter = prevBar.ATFcounter + 1
									if bar.ATFcounter > col.ATFMax then
										if bar.atf ~= 0 then
											bar:ClearAllPoints()
											bar:SetPoint("RIGHT",UIParent,"LEFT",-2000,0)
											bar.atf = 0
										end
									elseif (bar.ATFcounter - 1) % col.ATFCol == 0 then
										if bar.atf ~= 1 or bar.atf2 ~= prevBar.ATFPrevLine then
											bar:ClearAllPoints()
											bar:SetPoint(col.ATFPointLine1,prevBar.ATFPrevLine,col.ATFPointLine2,0,col.ATFBetweenLinesLine)
											bar.atf = 1
											bar.atf2 = prevBar.ATFPrevLine
										end
										bar.ATFPrevLine = bar
									else
										if bar.atf ~= 2 or bar.atf2 ~= prevBar then
											bar:ClearAllPoints()
											bar:SetPoint(col.ATFPointCol1,prevBar,col.ATFPointCol2,col.ATFBetweenLinesCol,0)
											bar.atf = 2
											bar.atf2 = prevBar
										end
										bar.ATFPrevLine = prevBar.ATFPrevLine
									end
								else
									bar.ATFcounter = 1
									if bar.atf ~= 3 or bar.atf2 ~= frame then
										bar:ClearAllPoints()
										bar:SetPoint(col.ATFPoint1,frame,col.ATFPoint2,col.ATFOffsetX,col.ATFOffsetY)
										bar.atf = 3
										bar.atf2 = frame
									end
									bar.ATFPrevLine = bar
								end
								prevLineForGUID[guid] = bar

								if col.autoStrata then
									local strata = frame:GetFrameStrata()
									if strata ~= col.FrameStrata then
										col:SetFrameStrata(strataToStrata[strata] or strata)
										col.FrameStrata = strata
									end
								end
							else
								if bar.atf ~= 0 then
									bar:ClearAllPoints()
									bar:SetPoint("RIGHT",UIParent,"LEFT",-2000,0)
									bar.atf = 0
								end
							end
						end
					end
				end
			end
		end

		saveDataTimer = saveDataTimer + elapsed
		if saveDataTimer > 2 then
			saveDataTimer = saveDataTimer % 2
			SaveCDtoVar()
		end
	end
end

local function GetNumGroupMembersFix()
	if module.db.testMode then
		return 20
	end
	local raidN = (GetNumRaidMembers and GetNumRaidMembers()) or 0
	if raidN > 0 then
		return raidN
	end
	local partyN = (GetNumPartyMembers and GetNumPartyMembers()) or 0
	if partyN > 0 then
		return partyN + 1
	end
	if VMRT.ExCD2.NoRaid then
		return 1
	end
	return 0
end

local function GetRaidRosterInfoFix(j)
	if not module.db.testMode then
		local raidN = (GetNumRaidMembers and GetNumRaidMembers()) or 0
		if raidN > 0 then
			local name, rank, subgroup, level, class, classFileName, zone, online, isDead = GetRaidRosterInfo(j)
			if not name then
				return nil
			end
			local _,race = UnitRace(name or "?")
			return name,subgroup,classFileName,level,race,online,isDead
		end
		local partyN = (GetNumPartyMembers and GetNumPartyMembers()) or 0
		if partyN > 0 then
			local unit = (j == 1) and "player" or ("party"..(j-1))
			local name = UnitName(unit)
			if not name then
				return nil
			end
			local _, classFileName = UnitClass(unit)
			local _, race = UnitRace(unit)
			local level = UnitLevel(unit) or 0
			local online = UnitIsConnected(unit)
			local isDead = UnitIsDeadOrGhost(unit)
			return name, 1, classFileName, level, race, online and true or false, isDead and true or false
		end
		if j == 1 and VMRT.ExCD2.NoRaid then
			local name = UnitName("player")
			local _, classFileName = UnitClass("player")
			local _, race = UnitRace("player")
			local level = UnitLevel("player")
			local isDead = UnitIsDeadOrGhost("player")
			return name, 1, classFileName, level, race, true, isDead and true or false
		end
		return nil
	end
	local name, rank, subgroup, level, class, classFileName, zone, online, isDead, role, isML = GetRaidRosterInfo(j)
	if module.db.testMode then
		if name then
			local _,race = UnitRace(name)
			return name,subgroup,classFileName,level,race,online,isDead
		end
		local classCount = (module.db.classNames and #module.db.classNames) or 0
		local i = (classCount > 0) and math.random(1, classCount) or 1

		local namesList = {}
		for unitName, specID in pairs(VMRT.ExCD2.gnGUIDs) do
			namesList[#namesList+1] = {unitName}
			for className, classSpecs in pairs(module.db.specByClass) do
				if ExRT.F.table_find(module.db.classNames,className) then
					for spec_i=1,#classSpecs do
						if classSpecs[spec_i] == specID then
							namesList[#namesList][2] = className
						end
					end
				end
			end
		end
		if #namesList == 0 or #namesList < 25 then
			classFileName = module.db.classNames and module.db.classNames[i] or "WARRIOR"
			local localized = (L.classLocalizate and L.classLocalizate[classFileName]) or classFileName or "Class"
			name = localized..tostring(j)
		else
			i = math.random(1,#namesList)
			name = namesList[i][1]
			classFileName = namesList[i][2]
		end

		return name,1,classFileName,100,nil,true,false
	end
end

local function RaidResurrectSpecialCheck()
	local _,_,difficulty = GetInstanceInfo()
	if difficulty == 14 or difficulty == 15 or difficulty == 16 or difficulty == 7 or difficulty == 17 or difficulty == 8 then
		return true
	end
end
local function RaidResurrectSpecialText()
	local charges, maxCharges, started, duration = GetSpellCharges(20484)
	if (charges or 0) > 1 then
		return " ("..charges..")"
	end
end
local function RaidResurrectSpecialStatus()
	local charges, maxCharges, started, duration = GetSpellCharges(20484)
	if charges then
		if charges > 0 then
			return false,started,duration,true
		else
			return true,started,duration,false
		end
	end
end

local function StartAfterCombat_SpecialStatus(data)
	if data.disable_oncd then
		return true,0,0,nil,true
	end
end
local function StartAfterCombat_SpecialStart(data)
	if data.disable_ticker then
		data.disable_ticker:Cancel()
		data.disable_ticker = nil
		data.disable_oncd = nil
	end

	if UnitAffectingCombat(data.fullName) then
		data.disable_oncd = true
		data.disable_ticker = C_Timer.NewTicker(1,function(self)
			if not UnitAffectingCombat(data.fullName) then
				self.count = (self.count or 0) + 1
			end
			if self.count and self.count >= 3 then
				self:Cancel()
				data.disable_ticker = nil
				data.disable_oncd = nil
				data.lastUse = GetTime()
				if data.bar and data.bar.data == data then
					data.bar:UpdateStatus()
				end
			end
		end)
	end
end
local function StartAfterCombat_SpecialAfterCombatReset(data)
	if data.disable_ticker then
		data.disable_ticker:Cancel()
		data.disable_ticker = nil
		data.disable_oncd = nil
	end
end

local lineFuncs = {
	ChangeCD = function(line,time,delayUpdate)
		line.cd = line.cd + time
		if line.cd < 0 then
			line.cd = 0
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
	ReduceCD = function(line,time,delayUpdate)
		line.lastUse = line.lastUse - time
		if line.charge then
			line.charge = line.charge - time
		end
		if time > 0 then
			line.duration = line.duration + time
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
	SetCD = function(line,time,delayUpdate)
		line.cd = time
		if line.cd < 0 then
			line.cd = 0
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
	SetCDSynq = function(line,time,delayUpdate,targetName)
		if time == 0 then
			return line:ResetCD(delayUpdate)
		end
		local new = GetTime() - line.cd + time
		if not line.lastUse or abs(line.lastUse - new) > 1 then
			line.lastUse = new
		end
		if ExRT.isLK and module.db.spell_aura_list and line.db then
			local sid = line.db[1]
			if sid and module.db.spell_aura_list[sid] then
				local fbDur = 0
				for s = 4, 8 do
					local seg = line.db[s]
					if type(seg) == "table" and tonumber(seg[3]) and seg[3] > 0 then
						fbDur = seg[3]
						break
					end
				end
				if fbDur > 0 then
					local nowT = GetTime()
					local endT = (line.lastUse or 0) + fbDur
					if endT > nowT then
						if (line.duration or 0) < fbDur then
							line.duration = fbDur
						end
					end
				end
			end
		end
		if targetName and targetName ~= "" then
			line.targetName = targetName
			line.targetSetTime = GetTime()
			local _,tc = UnitClass(targetName)
			line.targetClass = tc
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
	ModCD = function(line,modVal,delayUpdate)
		if type(modVal) == "number" then
			line.cd = line.cd + modVal
		elseif type(modVal) == "string" then
			line.cd = line.cd * tonumber( modVal:sub(2) )
		end
		if line.cd < 0 then
			line.cd = 0
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
	ResetCD = function(line,delayUpdate)
		line.lastUse = 0
		line.targetSetTime = nil
		if line.charge then
			line.charge = 0
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
	ChangeDur = function(line,time,delayUpdate)
		line.duration = line.duration + time
		if line.duration < 0 then
			line.duration = 0
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
	SetDur = function(line,time,delayUpdate)
		line.duration = time
		if line.duration < 0 then
			line.duration = 0
		end
		if line.bar and line.bar.data == line then
			line.bar:UpdateStatus()
		end
		if not delayUpdate then
			UpdateAllData()
		end
	end,
}

local function UpdateRoster()
	dprint("[UpdateRoster] Called")
	local playerName = ExRT.SDB.charName
	dprint("[UpdateRoster] playerName=", playerName)
	if playerName and _db.session_gGUIDs and _db.session_gGUIDs[playerName] then
		local count = 0
		for spellID in pairs(_db.session_gGUIDs[playerName]) do
			count = count + 1
		end
		dprint("[UpdateRoster] session_gGUIDs[", playerName, "] has", count, "talents")
		-- Check specific talents
		dprint("[UpdateRoster] Has 13877 (Blade Flurry)?", _db.session_gGUIDs[playerName][13877] and "YES" or "NO")
		dprint("[UpdateRoster] Has 13750 (Adrenaline Rush)?", _db.session_gGUIDs[playerName][13750] and "YES" or "NO")
		dprint("[UpdateRoster] Has 14185 (Preparation)?", _db.session_gGUIDs[playerName][14185] and "YES" or "NO")
	else
		dprint("[UpdateRoster] session_gGUIDs not available for", playerName)
	end
	wipe(status_UnitsToCheck)
	wipe(status_UnitIsDead)
	wipe(status_UnitIsDisconnected)
	wipe(status_UnitIsOutOfRange)
	wipe(classByName)

	wipe(_db.vars.isWarlock)
	wipe(_db.vars.isRogue)
	wipe(_db.vars.isPaladin)
	wipe(_db.vars.isMage)

	local n = GetNumGroupMembersFix()
	if n > 0 then
		local priorCounter = 0
		local priorNamesToNumber = {}
		local priorNameToIndex = {}
		if not _db.testMode then
			for j=1,n do
				local name = GetRaidRosterInfoFix(j)
				if name then
					priorNamesToNumber[#priorNamesToNumber + 1] = name
				end
			end
			sort(priorNamesToNumber)
			for idx=1,#priorNamesToNumber do
				priorNameToIndex[priorNamesToNumber[idx]] = idx
			end
		end

		local classColorsTable = type(CUSTOM_CLASS_COLORS)=="table" and CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
		local classNameToIndex = {}
		if _db.classNames then
			for ci=1,#_db.classNames do classNameToIndex[_db.classNames[ci]] = ci end
		end

		local liveCDSnapshot = {}
		for i=1,#_C do
			local d = _C[i]
			if d and d.fullName and d.db and d.db[1] then
				local hasRuntimeState = (d.lastUse and d.lastUse > 0) or (d.targetName ~= nil)
				if hasRuntimeState then
					liveCDSnapshot[ d.fullName.."#"..d.db[1] ] = {
						lastUse = d.lastUse, cd = d.cd, duration = d.duration,
						charge = d.charge,
						targetName = d.targetName, targetSetTime = d.targetSetTime, targetClass = d.targetClass,
					}
				end
			end
		end
		local prevRowsByName = {}
		for i=1,#_C do
			local d = _C[i]
			if d and d.fullName then
				local b = prevRowsByName[d.fullName]
				if not b then b = {} prevRowsByName[d.fullName] = b end
				b[#b + 1] = d
			end
		end
		local offlineNames = {}
		wipe(_C)
		cdsNav_wipe()
		for i=1,#_C do _C[i].sort = nil end
		local gMax = GetRaidDiffMaxGroup()
		local isInRaid = IsInRaid()
		local unitsToCheckSet = {}
		for j=1,n do
			local name,subgroup,class,level,race,online,isDead = GetRaidRosterInfoFix(j)
			if name then classByName[name] = class end
			if name and not online then offlineNames[name] = true end
			if name and subgroup <= gMax then
				for i,spellData in ipairs(_db.spellDB) do
					local SpellID = spellData[1]
					local AddThisSpell = true
					if level < 60 or ExRT.isLK then
						local spellLevel = GetSpellLevelLearned(SpellID)
						if level < (spellLevel or 0) then
							AddThisSpell = false
						end
					end
					if _db.spell_isRacial[ SpellID ] and race ~= _db.spell_isRacial[ SpellID ] then
						AddThisSpell = false
					end
						if ExRT.F.WarmUpSpell and not GetSpellInfo(SpellID) then
							ExRT.F.WarmUpSpell(SpellID)
						end
					local spellClass = strsplit(",",spellData[2])
					if not ExRT.GDB.ClassID[spellClass] and spellClass ~= "NO" then
						spellClass = "ALL"
					end

					if class == "ROGUE" and (SpellID==13750 or SpellID==13877 or SpellID==14185 or SpellID==51690 or SpellID==31230 or SpellID==14177) then
						dprint("[RosterGate]",SpellID,
							"|GSI=",GetSpellInfo(SpellID) and "Y" or "NIL",
							"|lvlLearned=",tostring(GetSpellLevelLearned(SpellID)),
							"|plvl=",tostring(level),
							"|spellClass=",tostring(spellClass),"vs",tostring(class),
							"|AddThisSpell=",tostring(AddThisSpell),
							"|specCheck=",spellData.specialCheck and "fn" or "none")
					end

					if SpellID == 49206 or SpellID == 66233 then
						dprint("[Gate]", SpellID, "name=", name, "AddThisSpell=", tostring(AddThisSpell),
							"spellClass=", tostring(spellClass), "class=", tostring(class),
							"specCheck=", spellData.specialCheck and (spellData.specialCheck(SpellID,name,class,race) and "pass" or "FAIL") or "none")
					end

					if AddThisSpell and (spellClass == class or spellClass == "ALL") and (not spellData.specialCheck or spellData.specialCheck(SpellID,name,class,race)) then
						if not unitsToCheckSet[name] then
							unitsToCheckSet[name] = true
							status_UnitsToCheck[#status_UnitsToCheck + 1] = name

							status_UnitIsDead[ name ] = isDead
							status_UnitIsDisconnected[ name ] = not online

							local inRange,isRange = UnitInRange(name)
							status_UnitIsOutOfRange[ name ] = isRange and not inRange
						end

						module:AddCLEUSpellDamage(SpellID)

						local alreadyInCds = nil
						priorCounter = priorCounter + 1

						local _specID = globalGUIDs[name] or 0
						local uSpecID = _db.specInDBase[_specID] or 4
						local checkRaidRole = (VMRT.ExCD2.CDECol[SpellID..";HEALER"] or VMRT.ExCD2.CDECol[SpellID..";TANK"] or VMRT.ExCD2.CDECol[SpellID..";DAMAGER"]) and true or false
						local unitRaidRole = checkRaidRole and ExRT.F.GetUnitRaidRole and ExRT.F.GetUnitRaidRole(name)
						local spellColumn = (checkRaidRole and unitRaidRole and VMRT.ExCD2.CDECol[SpellID..";"..unitRaidRole]) or VMRT.ExCD2.CDECol[SpellID..";"..(uSpecID-3)] or VMRT.ExCD2.CDECol[SpellID..";1"] or FindAnyUserColumn(VMRT.ExCD2.CDECol, SpellID) or _db.def_col[SpellID..";"..(uSpecID-3)] or _db.def_col[SpellID..";1"] or spellData[3] or 1

						local getSpellColumn = module.frame.colFrame[spellColumn]
						local prior = nil

						local nameIdx = priorNameToIndex[name] or 0
						local classIdx = classNameToIndex[class] or 0
						if not getSpellColumn or getSpellColumn.methodsSortingRules == 1 then
							prior = (VMRT.ExCD2.Priority[SpellID] or 50) * 1000000000000 + (SpellID or 0) * 1000000 + nameIdx * 10000 + priorCounter
						elseif getSpellColumn.methodsSortingRules == 2 then
							prior = (VMRT.ExCD2.Priority[SpellID] or 50) * 1000000000000 + nameIdx * 10000000000 + (SpellID or 0) * 10000 + priorCounter
						elseif getSpellColumn.methodsSortingRules == 3 then
							prior = (VMRT.ExCD2.Priority[SpellID] or 50) * 100000000000000 + classIdx * 1000000000000 + (SpellID or 0) * 1000000 + nameIdx * 10000 + priorCounter
						elseif getSpellColumn.methodsSortingRules == 4 then
							prior = (VMRT.ExCD2.Priority[SpellID] or 50) * 100000000000000 + classIdx * 1000000000000 + nameIdx * 10000000000 + (SpellID or 0) * 10000 + priorCounter
						elseif getSpellColumn.methodsSortingRules == 5 then
							prior = nameIdx * 1000000000000 + (VMRT.ExCD2.Priority[SpellID] or 50) * 10000000000 + (SpellID or 0) * 10000 + priorCounter
						elseif getSpellColumn.methodsSortingRules == 6 then
							prior = classIdx * 100000000000000 + (VMRT.ExCD2.Priority[SpellID] or 50) * 1000000000000 + nameIdx * 10000000000 + (SpellID or 0) * 10000 + priorCounter
						end
						local secondPrior = (VMRT.ExCD2.Priority[SpellID] or 50) * 1000000 + (SpellID or 0)

						if SpellID == 49206 or SpellID == 66233 then
							dprint("[Prior]", SpellID, "col=", spellColumn,
								"colFrame=", getSpellColumn and "Y" or "N",
								"msr=", tostring(getSpellColumn and getSpellColumn.methodsSortingRules),
								"prior=", tostring(prior))
						end

						local sName = format("%s%d",name or "?",SpellID or 0)
						local lastUse,nowCd = 0,0
						if VMRT.ExCD2.Save[sName] and NumberInRange(VMRT.ExCD2.Save[sName][1] + VMRT.ExCD2.Save[sName][2] - GetTime(),0,2000,false,true) then
							lastUse,nowCd = VMRT.ExCD2.Save[sName][1],VMRT.ExCD2.Save[sName][2]
						end
						local snap = liveCDSnapshot[ (name or "?").."#"..SpellID ]

						local spellName,_,spellTexture
						if ExRT.F.GetSpellInfoSafe then
							spellName,_,spellTexture = ExRT.F.GetSpellInfoSafe(SpellID)
						else
							spellName,_,spellTexture = GetSpellInfo(SpellID)
							if not spellTexture and ExRT.F.WarmUpSpell then
								ExRT.F.WarmUpSpell(SpellID)
								spellName,_,spellTexture = GetSpellInfo(SpellID)
							end
						end
						spellTexture = spellTexture or "Interface\\Icons\\INV_MISC_QUESTIONMARK"
						spellName = spellName or "unk"
						local shownName = DelUnitNameServer(name)

						if _db.differentIcons[SpellID] then
							spellTexture = _db.differentIcons[SpellID]
						end

						for l=4,8 do
							if spellData[l] then
								local h = ExRT.isClassic and _db.cdsNav[name][GetSpellInfo(spellData[l][1])] or _db.cdsNav[name][spellData[l][1]]
								if h then
									h.db = spellData
									if lastUse ~= 0 and nowCd ~= 0 and h.lastUse == 0 and h.cd == 0 then
										h.cd = nowCd
										h.lastUse = lastUse
									end
									if snap then
										if not h.lastUse or h.lastUse == 0 then
											h.lastUse = snap.lastUse
											h.cd = snap.cd
											h.charge = snap.charge
										end
										h.duration = snap.duration
										h.targetName = snap.targetName
										h.targetSetTime = snap.targetSetTime
										h.targetClass = snap.targetClass
									end
									h.sort = prior
									h.sort2 = secondPrior
									h.spellName = spellName
									h.icon = spellTexture
									h.column = spellColumn
									h.guid = h.guid or UnitGUID(name)
									h.checkRole = checkRaidRole

									alreadyInCds = true

									if spellClass == "WARLOCK" and h.guid then
										_db.vars.isWarlock[h.guid] = true
									elseif spellClass == "ROGUE" and h.guid then
										_db.vars.isRogue[h.guid] = true
									elseif spellClass == "PALADIN" and h.guid then
										_db.vars.isPaladin[h.guid] = true
									elseif spellClass == "MAGE" and h.guid then
										_db.vars.isMage[h.guid] = true
									end
								end
							end
						end

						if class == "ROGUE" and (SpellID==13750 or SpellID==13877 or SpellID==14185 or SpellID==51690 or SpellID==31230 or SpellID==14177) then
							dprint("[AddGate]",SpellID,"|alreadyInCds=",tostring(alreadyInCds),"|spellColumn=",tostring(spellColumn),"|prior=",tostring(prior))
						end

						if not alreadyInCds then
							local guid = UnitGUID(name)

							local new = {
								name = shownName,
								fullName = name,
								loweredName = shownName:lower(),
								icon = spellTexture,
								spellName = spellName,
								db = spellData,
								lastUse = lastUse,
								cd = nowCd,
								duration = 0,
								classColor = classColorsTable[class] or _db.notAClass,
								sort = prior,
								sort2 = secondPrior,
								column = spellColumn,
								guid = guid,
								checkRole = checkRaidRole,
							}
							if snap then
								if new.lastUse == 0 then
									new.lastUse = snap.lastUse
									new.cd = snap.cd
									new.charge = snap.charge
								end
								new.duration = snap.duration or 0
								new.targetName = snap.targetName
								new.targetSetTime = snap.targetSetTime
								new.targetClass = snap.targetClass
							end
							_C [#_C + 1] = new

							if
								SpellID == 323436 or
								SpellID == 6262
							then
								new.specialStatus = StartAfterCombat_SpecialStatus
								new.specialStart = StartAfterCombat_SpecialStart
								new.specialAfterCombatReset = StartAfterCombat_SpecialAfterCombatReset
							end

							if spellClass == "WARLOCK" and guid then
								_db.vars.isWarlock[guid] = true
							elseif spellClass == "ROGUE" and guid then
								_db.vars.isRogue[guid] = true
							elseif spellClass == "PALADIN" and guid then
								_db.vars.isPaladin[guid] = true
							elseif spellClass == "MAGE" and guid then
								_db.vars.isMage[guid] = true
							end
						end
					end
				end
				_db.session_gGUIDs[name] = 1
				if isInRaid then
					module.main:UNIT_PET("raid"..j)
				end
			end
		end

		if next(offlineNames) then
			local presentRowKeys = {}
			for i=1,#_C do
				local d = _C[i]
				if d and d.fullName and d.db then
					presentRowKeys[d.fullName.."#"..tostring(d.db[1])] = true
				end
			end
			for name in pairs(offlineNames) do
				local pr = prevRowsByName[name]
				if pr then
					local added = false
					for ri=1,#pr do
						local row = pr[ri]
						if row.db then
							local key = name.."#"..tostring(row.db[1])
							if not presentRowKeys[key] then
								_C[#_C + 1] = row
								presentRowKeys[key] = true
								added = true
							end
						end
					end
					if added and not unitsToCheckSet[name] then
						unitsToCheckSet[name] = true
						status_UnitsToCheck[#status_UnitsToCheck + 1] = name
						status_UnitIsDisconnected[name] = true
					end
				end
			end
		end

		cdsNav_wipe()

		local pluginFunc = module.db.plugin and type(module.db.plugin.UpdateRoster)=="function" and module.db.plugin.UpdateRoster

		local j = 0
		for i=1,#_C do
			j = j + 1
			local line = _C[j]
			if not line then
				break
			elseif not line.sort then
				dprint("[Removed-nilSort]", line.db and line.db[1], "col=", line.column, "name=", line.fullName)
				tremove(_C,j)
				j = j - 1
			else
				for k,v in pairs(lineFuncs) do
					line[k] = v
				end
				cdsNav_set(line.fullName,line.db[1],line)
				for l=4,8 do
					if line.db[l] then
						cdsNav_set(line.fullName,line.db[l][1],line)
					end
				end
				if pluginFunc then
					pluginFunc(line)
				end
			end
		end
	else
		wipe(_C)
		cdsNav_wipe()
	end
	if module.db.testMode then
		TestMode()

		for i=1,2 do
			local offline = status_UnitsToCheck[fastrandom(1,#status_UnitsToCheck)]
			status_UnitIsDisconnected[offline] = true

			local dead = status_UnitsToCheck[fastrandom(1,#status_UnitsToCheck)]
			status_UnitIsDead[dead] = true
		end

		for j=#status_UnitsToCheck,1,-1 do
			if not UnitName(status_UnitsToCheck[j]) then
				tremove(status_UnitsToCheck, j)
			end
		end

		for i=#_C,1,-1 do
			local col = _C[i].column
			if not (module.frame.colFrame[col] and module.frame.colFrame[col]:IsShown()) then
				tremove(_C, i)
			end
		end
		while #_C > 300 do
			tremove(_C, math.random(1,#_C))
		end
	end
	do
		local dump = {}
		for i=1,#_C do
			local d = _C[i]
			dump[#dump+1] = tostring(d.db and d.db[1]).."(c"..tostring(d.column)..",s"..(d.sort and "Y" or "NIL")..")"
		end
		dprint("[UpdateRoster] _C dump:", table.concat(dump, " "))
	end
	dprint("[UpdateRoster] Finished, _C has", #_C, "entries")
	UpdateAllData()
end
module.UpdateRoster = UpdateRoster

do
	local function DispellSchedule(data)
		if not _db.spell_dispellsFix[ data.fullName ] then
			data:SetCD(0)
		end
		_db.spell_dispellsFix[ data.fullName ] = nil
	end
	local function IsAuraActive(unit,spellID)
		for i=1,60 do
			local name,_,_,_,_,_,_,_,_,auraSpellID = UnitAura(unit,i)
			if spellID == auraSpellID then
				return true
			elseif not name then
				return
			end
		end
	end
	function RecordHistoryUsage(line, targetName)
		if not line or not line.db then
			return
		end
		local fullName = line.fullName
		local uSpecID = _db.specInDBase[globalGUIDs[fullName] or 0]
		if not line.db[uSpecID] then
			for sid = 4, 8 do
				if line.db[sid] then uSpecID = sid; break end
			end
		end
		if not line.db[uSpecID] then
			return
		end
		local spellID = line.db[uSpecID][1]
		local hist = _db.historyUsage
		local tnow = time()
		local from = #hist - 10
		if from < 1 then from = 1 end
		for k = #hist, from, -1 do
			local e = hist[k]
			if e and e[2] == spellID and e[3] == fullName and (tnow - e[1]) < 2 then
				return
			end
		end
		local _, hp_class = UnitClass(fullName)
		hist[#hist + 1] = {tnow, spellID, fullName, GetEncounterTime(), targetName, hp_class or line.db[2]}
	end
	module.RecordHistoryUsage = RecordHistoryUsage

	function CLEUstartCD(i,targetName)
		local currTime = GetTime()
		local data = nil
		if type(i) == "table" then
			data = i
		else
			data = _C[i]
		end
		local fullName = data.fullName

		local uSpecID = _db.specInDBase[globalGUIDs[fullName] or 0]
		if not data.db[uSpecID] then
			for sid = 4, 8 do
				if data.db[sid] then uSpecID = sid; break end
			end
		end
		if not data.db[uSpecID] then
			return
		end
		local spellID = data.db[uSpecID][1]

		if _db.spell_battleRes[spellID] and _db.isResurectDisabled then
			return
		end


		if _db.spellIgnoreAfterFirstUse[spellID] and data.lastUse then
			local t = _db.spellIgnoreAfterFirstUse[spellID]
			if currTime - data.lastUse <= t then
				return
			end
		end

		if data.lastUse and data.duration and data.duration > 0 and (currTime - data.lastUse) < data.duration then
			return
		end

		if targetName then
			data.targetName = targetName
			data.targetSetTime = currTime
			local _,tc = UnitClass(targetName)
			data.targetClass = tc
		else
			local preserveByCast = ExRT.isLK and _db.spell_target_byCast and data.spellName and _db.spell_target_byCast[data.spellName] and data.targetSetTime and (currTime - data.targetSetTime) < 3
			if not preserveByCast then
				data.targetName = nil
				data.targetSetTime = nil
				data.targetClass = nil
			end
		end

		data.cd = data.db[uSpecID][2]
		data.duration = data.db[uSpecID][3]


		local durationTable = _db.spell_durationByTalent_fix[spellID]
		if durationTable then
			for j=1,#durationTable,2 do
				local talentSpellID = durationTable[j]
				local session_gGUID = _db.session_gGUIDs[fullName][talentSpellID]
				if session_gGUID and (not _db.spell_isPvpTalent[talentSpellID] or module.IsPvpTalentsOn(fullName)) then
					local timeReduce = durationTable[j+1]
					if type(timeReduce) == 'table' and ExRT.isClassic then
						local talent_rank = _db.talent_classic_rank[fullName][talentSpellID] or #timeReduce
						timeReduce = timeReduce[talent_rank] or timeReduce[1]
					elseif type(timeReduce) == 'table' and #timeReduce <= 5 then
						local talent_rank = _db.talent_classic_rank[fullName][talentSpellID] or #timeReduce
						timeReduce = timeReduce[talent_rank] or timeReduce[#timeReduce]
					end
					local mod = (type(session_gGUID) == "table" and type(session_gGUID[1]) == "number") and session_gGUID[1] or 1
					if tonumber(timeReduce) then
						data.duration = data.duration + timeReduce * mod
					else
						local timeFix = tonumber( string.sub( timeReduce, 2 ) )
						data.duration = data.duration * timeFix * mod
					end
				end
			end
		end
		local cdTable = _db.spell_cdByTalent_fix[spellID]
		if cdTable then
			for j=1,#cdTable,2 do
				local talentSpellID = cdTable[j]
				local passSpecCheck = true
				if type(talentSpellID) == "table" then
					local specReduceCD = talentSpellID[2]
					if (not specReduceCD or (specReduceCD < 0 and globalGUIDs[fullName] ~= specReduceCD or globalGUIDs[fullName] == specReduceCD)) then
						passSpecCheck = true
					else
						passSpecCheck = false
					end
					talentSpellID = talentSpellID[1]
				end
				local session_gGUID = _db.session_gGUIDs[fullName][talentSpellID]
				if session_gGUID and passSpecCheck and (not _db.spell_isPvpTalent[talentSpellID] or module.IsPvpTalentsOn(fullName)) then
					local timeReduce
					if _db.spell_cdByTalent_isScalable[talentSpellID] then
						local scale_data = _db.spell_cdByTalent_scalable_data[talentSpellID]
						timeReduce = scale_data[fullName] or scale_data[1]
					else
						timeReduce = cdTable[j+1]
						if type(timeReduce) == 'table' and ExRT.isClassic then
							local talent_rank = _db.talent_classic_rank[fullName][talentSpellID] or #timeReduce
							timeReduce = timeReduce[talent_rank] or timeReduce[1]
						elseif type(timeReduce) == 'table' and #timeReduce <= 5 then
							if type(timeReduce[2]) == "number" and timeReduce[2] > 1000 then
								if IsAuraActive(fullName,timeReduce[2]) then
									timeReduce = timeReduce[1]
								else
									timeReduce = 0
								end
							else
								local talent_rank = _db.talent_classic_rank[fullName][talentSpellID] or #timeReduce
								timeReduce = timeReduce[talent_rank] or timeReduce[#timeReduce]
							end
						end
					end
					local mod = (type(session_gGUID) == "table" and type(session_gGUID[1]) == "number") and session_gGUID[1] or 1
					if tonumber(timeReduce) then
						data.cd = data.cd + timeReduce * mod
					else
						local timeFix = tonumber( string.sub( timeReduce, 2 ) )
						data.cd = data.cd * timeFix * mod
					end
				end
			end
		end
		local cdAura = _db.spell_reduceCdByAura[spellID]
		if cdAura then
			for j=1,#cdAura,2 do
				local auraID = cdAura[j]
				if type(auraID) == "table" then
					if _db.session_gGUIDs[fullName][ auraID[2] ] and (not _db.spell_isPvpTalent[ auraID[2] ] or module.IsPvpTalentsOn(fullName)) then
						auraID = auraID[1]
					else
						auraID = nil
					end
				end
				if auraID and IsAuraActive(fullName,auraID) then
					local timeReduce = cdAura[j+1]
					if tonumber(timeReduce) then
						data.cd = data.cd + timeReduce
					else
						local timeFix = tonumber( string.sub( timeReduce, 2 ) )
						data.cd = data.cd * timeFix
					end
				end
			end
		end

		local isCharge = _db.spell_charge_fix[ data.db[1] ]
		if isCharge and _db.spell_isPvpTalent[isCharge] and not module.IsPvpTalentsOn(fullName) then
			isCharge = false
		end
		if isCharge and (data.lastUse+data.cd) >= currTime then
			data.charge = (data.charge or data.lastUse) + data.cd
			data.lastUse = currTime
			_db.session_gGUIDs[fullName] = isCharge
		elseif isCharge and _db.session_gGUIDs[fullName][isCharge] then
			data.charge = currTime
			data.lastUse = currTime
		else
			data.lastUse = currTime
		end

		if _db.spell_speed_list[spellID] then
			data.duration = data.duration / (1 + (UnitSpellHaste(fullName) or 0) /100)
		end
		if _db.spell_reduceCdByHaste[spellID] then
			data.cd = data.cd / (1 + (UnitSpellHaste(fullName) or 0) /100)
		end

		if _db.spell_dispellsList[spellID] then
			ScheduleTimer(DispellSchedule, 0.5, data)
		end

		if data.cd > 45000 then data.cd = 45000 end
		if data.duration > 45000 then data.duration = 45000 end

		if data.specialStart then
			data.specialStart(data)
		end

		if data.bar and data.bar.data == data then
			data.bar:UpdateStatus()
		end

		if not module.db._updateAllPending then
			module.db._updateAllPending = true
			C_Timer.After(0.05, function()
				module.db._updateAllPending = nil
				UpdateAllData()
			end)
		end

		RecordHistoryUsage(data, targetName)
	end
	module.CLEUstartCD = CLEUstartCD
end

do
	local IGNORE_PROFILE_KEYS = {
		["Profiles"] = true,
	}
	function module:SaveCurrentProfiletoDB()
		local profileName = VMRT.ExCD2.Profiles.Now

		local saveDB = {}
		VMRT.ExCD2.Profiles.List[ profileName ] = saveDB

		for key,val in pairs(VMRT.ExCD2) do
			if not IGNORE_PROFILE_KEYS[key] then
				if type(val) == "table" then
					saveDB[key] = ExRT.F.table_copy2(val)
				else
					saveDB[key] = val
				end
			end
		end
	end
	function module:SelectProfile(name)
		if name == VMRT.ExCD2.Profiles.Now or not name then
			return
		end
		if not VMRT.ExCD2.Profiles.List[name] then
			return
		end
		module:SaveCurrentProfiletoDB()

		local savedKeys = {}
		for key in pairs(IGNORE_PROFILE_KEYS) do
			if VMRT.ExCD2[key] then
				savedKeys[key] = VMRT.ExCD2[key]
			end
		end
		ExRT.F.table_rewrite(VMRT.ExCD2,VMRT.ExCD2.Profiles.List[name])
		for key,val in pairs(savedKeys) do
			VMRT.ExCD2[key] = val
		end

		VMRT.ExCD2.Profiles.Now = name

		module:ReloadProfile()

		VMRT.ExCD2.Profiles.List[name] = nil

		return true
	end
	function module:ReloadProfile()
		module.main:ADDON_LOADED()
		if module.options.isLoaded then
			module.options.chkLock:SetChecked(VMRT.ExCD2.lock)
			module.options.chkEnable:SetChecked(VMRT.ExCD2.enabled)
			module.options.chkEnable:ColorState()
			module.options.chkSplit:SetChecked(VMRT.ExCD2.SplitOpt)
			module.options.chkNoRaid:SetChecked(VMRT.ExCD2.NoRaid)
			module.options.categories:Update()
			module.options:ClickPlayerClassCategoryOrFirst()
			module.options.optColTabs.tabs[module.db.maxColumns+3].currentName:UpdateText()
			module.options.optColTabs.tabs[module.db.maxColumns+3]:UpdateAutoTexts()
			if module.options.optColTabs.tabs[module.db.maxColumns+3].choseSelectDropDown and module.options.optColTabs.tabs[module.db.maxColumns+3].choseSelectDropDown.UpdateText then
				module.options.optColTabs.tabs[module.db.maxColumns+3].choseSelectDropDown:UpdateText()
			end
			if module.options.optColTabs.selected <= module.db.maxColumns + 1 then
				module.options:selectColumnTab()
			end
		end
	end

	function module:CheckZoneProfiles()
		local _, zoneType = GetInstanceInfo()

		if zoneType == "arena" then
			if VMRT.ExCD2.Profiles.Arena then
				module:SelectProfile(VMRT.ExCD2.Profiles.Arena)
			end
		elseif zoneType == "party" then
			if VMRT.ExCD2.Profiles.Dung then
				module:SelectProfile(VMRT.ExCD2.Profiles.Dung)
			end
		elseif zoneType == "raid" then
			if VMRT.ExCD2.Profiles.Raid then
				module:SelectProfile(VMRT.ExCD2.Profiles.Raid)
			end
		elseif zoneType == "pvp" then
			if VMRT.ExCD2.Profiles.BG then
				module:SelectProfile(VMRT.ExCD2.Profiles.BG)
			end
		else
			if VMRT.ExCD2.Profiles.Other then
				module:SelectProfile(VMRT.ExCD2.Profiles.Other)
			end
		end
	end
end

function module:Enable()
	VMRT.ExCD2.enabled = true
	module.frame.IsEnabled = true
	module:SplitExCD2Window()
	module:UpdateLockState()
	module:ReloadAllSplits()

	module:RegisterTimer()
	module:RegisterEvents('SCENARIO_UPDATE','GROUP_ROSTER_UPDATE','COMBAT_LOG_EVENT_UNFILTERED','UNIT_PET','PLAYER_LOGOUT','CHALLENGE_MODE_RESET','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','ENCOUNTER_START','ENCOUNTER_END')

	module:CreateSpellDB()

	module:ApplyHotfixes()

	UpdateRoster()

	module.main:ZONE_CHANGED_NEW_AREA()

	module:RegisterAddonMessage()
end

function module:Disable()
	VMRT.ExCD2.enabled = nil
	module.frame.IsEnabled = false
	if not VMRT.ExCD2.SplitOpt then
		module.frame:Hide()
	else
		for i=1,module.db.maxColumns do
			module.frame.colFrame[i]:Hide()
		end
	end

	module:UnregisterTimer()
	module:UnregisterEvents('SCENARIO_UPDATE','GROUP_ROSTER_UPDATE','COMBAT_LOG_EVENT_UNFILTERED','UNIT_PET','PLAYER_LOGOUT','CHALLENGE_MODE_RESET','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','ENCOUNTER_START','ENCOUNTER_END','ARENA_COOLDOWNS_UPDATE','UNIT_AURA')

	module:UnregisterAddonMessage()
end

function module:IsEnabled()
	if module.frame.IsEnabled then
		return true
	else
		return false
	end
end

local NewVMRTTableData = {
	NoRaid = true,
	upd4380 = true,
	upd4525 = true,
	enabled = true,
}

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.ExCD2 = VMRT.ExCD2 or ExRT.F.table_copy2(NewVMRTTableData)
	if ExRT.isClassic and VMRT.ExCD2.NoRaid == nil then
		VMRT.ExCD2.NoRaid = true
	end
	if ExRT.isClassic and not VMRT.ExCD2.upd4526 then
		VMRT.ExCD2.enabled = true
		VMRT.ExCD2.upd4526 = true
	end

	VMRT.ExCD2.Profiles = VMRT.ExCD2.Profiles or {}
	VMRT.ExCD2.Profiles.List = VMRT.ExCD2.Profiles.List or {}
	VMRT.ExCD2.Profiles.Now = VMRT.ExCD2.Profiles.Now or "default"

	if VMRT.Addon.Version < 4235 and not VMRT.ExCD2.MigratedV4235 then
		if VMRT.ExCD2.Priority then
			for k,v in pairs(VMRT.ExCD2.Priority) do
				if type(v) == 'number' then
					VMRT.ExCD2.Priority[k] = floor((v - 1) / 29 * 100)
				end
			end
		end
		VMRT.ExCD2.MigratedV4235 = true
	end
	if VMRT.Addon.Version < 4240 and not VMRT.ExCD2.MigratedV4240 then
		if VMRT.ExCD2.userDB then
			for i=#VMRT.ExCD2.userDB,1,-1 do
				for j=1,#module.db.AllSpells do
					if module.db.AllSpells[j][1] == VMRT.ExCD2.userDB[i][1] then
						tremove(VMRT.ExCD2.userDB,i)
						break
					end
				end
			end
			for i=1,#VMRT.ExCD2.userDB do
				if type(VMRT.ExCD2.userDB[i][3]) ~= "number" then
					for j=8,4,-1 do
						VMRT.ExCD2.userDB[i][j] = VMRT.ExCD2.userDB[i][j-1]
					end
					VMRT.ExCD2.userDB[i][3] = 1
				end
			end
		end
		VMRT.ExCD2.default_userCD = nil
		VMRT.ExCD2.default_userDuration = nil
		VMRT.ExCD2.MigratedV4240 = true
	end

	if VMRT.ExCD2.Left and VMRT.ExCD2.Top then
		module.frame:ClearAllPoints()
		module.frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",VMRT.ExCD2.Left,VMRT.ExCD2.Top)
	end

	VMRT.ExCD2.CDE = VMRT.ExCD2.CDE or {}
	VMRT.ExCD2.CDECol = VMRT.ExCD2.CDECol or {}

	if not VMRT.ExCD2.colSet then
		VMRT.ExCD2.colSet = {}
		for i=1,module.db.maxColumns+1 do
			VMRT.ExCD2.colSet[i] = {}
			for optName,optVal in pairs(module.db.colsInit) do
				VMRT.ExCD2.colSet[i][optName] = optVal
			end
			if i <= 3 then
				VMRT.ExCD2.colSet[i].enabled = true
			end
		end
	end
	for i=1,module.db.maxColumns+1 do
		VMRT.ExCD2.colSet[i] = VMRT.ExCD2.colSet[i] or {}
	end

	if not VMRT.ExCD2.upd4380 then
		for i=1,module.db.maxColumns+1 do
			local colSet = VMRT.ExCD2.colSet[i]
			colSet.methodsSortByAvailability = VMRT.ExCD2.SortByAvailability
			colSet.methodsSortActiveToTop = VMRT.ExCD2.SortByAvailabilityActiveToTop
			colSet.methodsReverseSorting = VMRT.ExCD2.ReverseSorting
		end
		VMRT.ExCD2.upd4380 = true
	end
	if not VMRT.ExCD2.upd4525 then
		for i=1,module.db.maxColumns do
			local colSet = VMRT.ExCD2.colSet[i]
			if colSet.ATF then
				colSet.frameStrata = nil
			end
		end
		VMRT.ExCD2.upd4525 = true
	end
	if ExRT.isLK then
		if not VMRT.ExCD2.upd_raidcds_default_v2 then
			for i=1,#module.db.AllSpells do
				local s = module.db.AllSpells[i]
				if s and s[2] and type(s[2]) == "string" and s[2]:find("RAID") then
					VMRT.ExCD2.CDE[s[1]] = true
				end
			end
			VMRT.ExCD2.upd_raidcds_default_v2 = true
			VMRT.ExCD2.upd_raidcds_default_v1 = true
		end
		VMRT.ExCD2.upd_raidcds_seen = VMRT.ExCD2.upd_raidcds_seen or {}
		for i=1,#module.db.AllSpells do
			local s = module.db.AllSpells[i]
			if s and s[2] and type(s[2]) == "string" and s[2]:find("RAID") then
				local id = s[1]
				if not VMRT.ExCD2.upd_raidcds_seen[id] then
					if VMRT.ExCD2.CDE[id] == nil then
						VMRT.ExCD2.CDE[id] = true
					end
					VMRT.ExCD2.upd_raidcds_seen[id] = true
				end
			end
		end

		if not VMRT.ExCD2.upd_raidcds_classic_v1 then
			for sid in pairs(module.db.spell_isRaidCD) do
				if VMRT.ExCD2.CDE[sid] == nil then
					VMRT.ExCD2.CDE[sid] = true
				end
			end
			VMRT.ExCD2.upd_raidcds_classic_v1 = true
		end
		VMRT.ExCD2.upd_raidcds_seen2 = VMRT.ExCD2.upd_raidcds_seen2 or {}
		for sid in pairs(module.db.spell_isRaidCD) do
			if not VMRT.ExCD2.upd_raidcds_seen2[sid] then
				if VMRT.ExCD2.CDE[sid] == nil then
					VMRT.ExCD2.CDE[sid] = true
				end
				VMRT.ExCD2.upd_raidcds_seen2[sid] = true
			end
		end
		if not VMRT.ExCD2.upd_v509_passives then
			VMRT.ExCD2.upd_v509_passives = true
			VMRT.ExCD2.CDE[31230] = true
			VMRT.ExCD2.CDE[14185] = true
			VMRT.ExCD2.CDE[66233] = true
		end
		if not VMRT.ExCD2.upd_talentcds_v1 then
			for sid in pairs(module.db.spell_isTalentCD) do
				if VMRT.ExCD2.CDE[sid] == nil then VMRT.ExCD2.CDE[sid] = true end
			end
			VMRT.ExCD2.upd_talentcds_v1 = true
		end
	end

	VMRT.ExCD2.userDB = VMRT.ExCD2.userDB or {}

	VMRT.ExCD2.Priority = VMRT.ExCD2.Priority or {}

	VMRT.ExCD2.gnGUIDs = VMRT.ExCD2.gnGUIDs or {}
	if VMRT.ExCD2.gnGUIDs and ExRT.F.table_len(VMRT.ExCD2.gnGUIDs) > 500 then
		wipe(VMRT.ExCD2.gnGUIDs)
	end
	globalGUIDs = VMRT.ExCD2.gnGUIDs

	VMRT.ExCD2.OptFav = VMRT.ExCD2.OptFav or {}

	VMRT.ExCD2.Save = VMRT.ExCD2.Save or {}

	module:RegisterEvents('ZONE_CHANGED_NEW_AREA')
	if ExRT.isClassic then
		module:RegisterEvents('LOADING_SCREEN_DISABLED')
	end
	if not VMRT.ExCD2.enabled then
		module:Disable()
		C_Timer.After(2,module.CheckZoneProfiles)
	else
		module:Enable()
		ScheduleTimer(UpdateRoster,10)
		ScheduleTimer(module.ReloadAllSplits,10)
		module:RegisterEvents('PLAYER_ENTERING_WORLD')
	end

	for _ in pairs(module.db.spellCDSync) do
		module:RegisterEvents('SPELL_UPDATE_COOLDOWN')
		break
	end

	module:RegisterSlash()
end

function module.main:PLAYER_ENTERING_WORLD()
	if (ExRT.isClassic or ExRT.isLK) and ExRT.F.WarmUpSpell and module.db.AllSpells and not module._warmupTicker then
		local list = module.db.AllSpells
		local total = #list
		local idx = 0
		local CHUNK = 50
		local ticker
		local function step()
			local stop = idx + CHUNK
			if stop > total then stop = total end
			for i=idx+1,stop do
				local id = list[i] and list[i][1]
				if type(id) == "number" then
					ExRT.F.WarmUpSpell(id)
				end
			end
			idx = stop
			if idx >= total then
				if ticker and ticker.Cancel then pcall(ticker.Cancel, ticker) end
				module._warmupTicker = nil
			end
		end
		if C_Timer and C_Timer.NewTicker then
			ticker = C_Timer.NewTicker(0, step)
			module._warmupTicker = ticker
		else
			while idx < total do step() end
		end
	end
	if ExRT.isClassic and MRT.CLEUFrame and MRT.CLEUFrame.CLEUModules then
		local cur = module.main.COMBAT_LOG_EVENT_UNFILTERED
		if type(cur) == "function" then
			MRT.CLEUFrame.CLEUModules[module] = cur
		end
	end
	if ExRT.isLK and module.db.spell_target_byCast and ExRT.F.WarmUpSpell then
		ExRT.F.WarmUpSpell(48477)
		local rebirthName = GetSpellInfo(48477) or GetSpellInfo(20484) or GetSpellInfo(20748)
		if rebirthName and not module.db.spell_target_byCast[rebirthName] then
			module.db.spell_target_byCast[rebirthName] = 20748
		end
	end

	UpdateRoster()

	module:UnregisterEvents('PLAYER_ENTERING_WORLD')
end

function module.main:PLAYER_LOGOUT()
	SaveCDtoVar(true)
end

function module.main:SCENARIO_UPDATE()
	AfterCombatResetFunction()
	UpdateAllData()
end
module.main.CHALLENGE_MODE_RESET = module.main.SCENARIO_UPDATE

function module.main:PLAYER_REGEN_DISABLED()
	module:toggleCombatVisibility(true,2)
end
function module.main:PLAYER_REGEN_ENABLED()
	module:toggleCombatVisibility(false,2)
end


do
	local scheduledUpdateRoster = nil
	local function funcScheduledUpdate()
		scheduledUpdateRoster = nil
		UpdateRoster()
		module:updateCombatVisibility()
		module:ATFFrameDataReset()
	end

	function module.main:GROUP_ROSTER_UPDATE()
		if not scheduledUpdateRoster then
			scheduledUpdateRoster = ScheduleTimer(funcScheduledUpdate,1)
		end
	end
end

do
	local scheduledUpdateRoster = nil
	local function funcScheduledUpdate()
		scheduledUpdateRoster = nil
		if not module:IsEnabled() then
			return
		end
		UpdateRoster()
	end

	local prevDiffID

	local scheduledVisibility = nil
	local function funcScheduledVisibility()
		scheduledVisibility = nil
		if not module:IsEnabled() then
			return
		end
		module:updateCombatVisibility()

		local _,_,diff = GetInstanceInfo()
		if diff ~= prevDiffID then
			if diff == 167 then
				module:ClearFullSessionDataReason("torghast")
				module:RegisterEvents('UNIT_AURA')
			elseif prevDiffID == 167 then
				module:UnregisterEvents('UNIT_AURA')
				module:ClearFullSessionDataReason("torghast")
			end
			prevDiffID = diff
		end
	end

	function module.main:ZONE_CHANGED_NEW_AREA()
		C_Timer.After(1,module.CheckZoneProfiles)

		if module:IsEnabled() then
			if select(2, IsInInstance()) == "arena" then
				AfterCombatResetFunction(true)
				UpdateAllData()
			end
			if not scheduledVisibility then
				scheduledVisibility = ScheduleTimer(funcScheduledVisibility,2)
			end
			if not scheduledUpdateRoster then
				scheduledUpdateRoster = ScheduleTimer(funcScheduledUpdate,10)
			end
		end
	end
	module.main.LOADING_SCREEN_DISABLED = module.main.ZONE_CHANGED_NEW_AREA
end

do
	local prevStart,prevDur = {},{}
	local str
	function module.main:SPELL_UPDATE_COOLDOWN()
		local CDList = _db.cdsNav
		local playerName = UnitName("player")
		for _,spellID in pairs(module.db.spellCDSync) do
			local start, duration
			if ExRT and ExRT.isClassic then
				local spellName = GetSpellInfo(spellID)
				if spellName then
					start, duration = GetSpellCooldown(spellName)
				else
					start, duration = 0, 0
				end
			else
				start, duration = GetSpellCooldown(spellID)
			end
			if type(start) ~= "number" then start = 0 end
			if type(duration) ~= "number" then duration = 0 end
			if (start ~= prevStart[spellID] or duration ~= prevDur[spellID]) and (duration == 0 or duration > 2) then
				prevStart[spellID] = start
				prevDur[spellID] = duration
				if duration > 2 then
					local target
					local line = playerName and CDList[playerName] and CDList[playerName][spellID]
					if line and line.targetName and line.targetName ~= "" then
						local refTime = line.lastUse or 0
						local tst = line.targetSetTime or 0
						if tst > refTime then refTime = tst end
						local sinceCast = GetTime() - refTime
						if sinceCast >= 0 and sinceCast <= 30 then
							target = line.targetName
						end
					end
					if target then
						str = (str or "") .. spellID .. ":" .. floor(start + duration - GetTime()) .. ":" .. target .. ";"
					else
						str = (str or "") .. spellID .. ":" .. floor(start + duration - GetTime()) .. ";"
					end
				elseif duration == 0 then
					str = (str or "") .. spellID .. ":0;"
				end
			end
		end
		if str then
			str = str:sub(1,-2)
			ExRT.F.SendExMsg("rcd","SQ\t"..str)
			str = nil
		end
	end

	local CDList = _db.cdsNav
	function module:addonMessage(sender, prefix, subPrefix, ...)
		if prefix == "rcd" then
			if subPrefix == "SQ" then

				local str = ...
				local senderFull = sender
				sender = strsplit("-",sender)

				local updateReq

				while str do
					local main,next = strsplit(";",str,2)
					str = next

					if main then
						local spellID,spellCD,spellTarget = strsplit(":",main,3)
						spellID = tonumber(spellID or "")
						spellCD = tonumber(spellCD or "")

						if spellID and spellCD then
							local line = CDList[sender][spellID]
							if line then
								if spellTarget == "" then spellTarget = nil end
								line:SetCDSynq(spellCD,true,spellTarget)

								updateReq = true
							end
						end
					end
				end

				if updateReq then
					UpdateAllData()
				end
			end
		end
	end
end

local FD_GUIDs = {}
local ScheduledUnitAura
function module.main:UNIT_AURA(unitID)
	local isInTorghast = IsInJailersTower()
	if isInTorghast then
		local name,realm = UnitName(unitID)
		if realm then
			name = name .. "-" .. realm
		end

		for i=1,60 do
			local _, _, count, _, _, _, _, _, _, spellId = UnitAura(unitID, i, "MAW")
			if not spellId then
				break
			else
				if count and count < 2 then
					count = nil
				end
				_db.session_gGUIDs[name] = {spellId,"torghast",count}
			end
		end
	end
	local guid = UnitGUID(unitID)
	if guid and FD_GUIDs[guid] then
		local FD_Found
		for i=1,60 do
			local _, _, _, _, _, _, _, _, _, spellId = UnitAura(unitID, i)
			if not spellId then
				break
			elseif spellId == 5384 then
				FD_Found = true
			end
		end
		if not FD_Found then
			local line = _db.cdsNav[UnitName(unitID)][5384]
			if ExRT.isClassic and not line then
				line = _db.cdsNav[UnitName(unitID)][GetSpellInfo(5384)]
			end
			if line then
				CLEUstartCD(line)
			end

			FD_GUIDs[guid] = nil
			if not isInTorghast then
				local anyFound
				for _ in pairs(FD_GUIDs) do
					anyFound = true
					break
				end
				if not anyFound then
					if ScheduledUnitAura then
						ScheduledUnitAura:Cancel()
						ScheduledUnitAura = nil
					end
					module:UnregisterEvents("UNIT_AURA")
				end
			end
		end
	end

end


function module.main:UNIT_PET(arg)
	local name = UnitCombatlogname(arg)
	if name then
		local forceUpdateAllData = nil
		local petNow = UnitCreatureFamily(arg.."pet")
		if petNow ~= _db.session_Pets[name] then
			_db.session_Pets[name] = UnitCreatureFamily(arg.."pet")
			forceUpdateAllData = true
		end
		if _db.session_Pets[name] then
			_db.session_PetOwner[UnitGUID(arg.."pet")] = name
		end
		if forceUpdateAllData then
			UpdateAllData()
		end
	end
end

local hotfixTableNameToType = {
	AllSpells = 1,
	spell_charge_fix = 2,
	spell_talentReplaceOther = 2,
	spell_aura_list = 2,
	spell_durationByTalent_fix = 3,
	spell_cdByTalent_fix = 3,
	spell_speed_list = 2,
	spell_afterCombatReset = 2,
	spell_afterCombatNotReset = 2,
	spell_reduceCdByHaste = 2,
	spell_resetOtherSpells = 3,
	spell_sharingCD = 4,
	spell_runningSameSpell = 3,
	spell_reduceCdCast = 3,
	spell_increaseDurationCast = 3,
	spell_dispellsList = 2,
	spell_startCDbyAuraFade = 2,
	spell_startCDbyAuraFadeExt = 2,
	spell_startCDbyAuraApplied = 2,
	spell_reduceCdByAuraFade = 3,
	spell_reduceCdByAuraFadeBefore = 3,
	spell_battleRes = 2,
	spell_isRacial = 2,
	differentIcons = 2,
	itemsToSpells = 2,
	spell_autoTalent = 2,
	spell_talentProvideAnotherTalents = 3,
	spell_isTalent = 2,
	spell_isPvpTalent = 2,
	findspecspells = 2,
	aura_grant_talent = 2,
}

function module:ApplyHotfixes()
	local text, line = VMRT.ExCD2.Hotfixes or ""
	line, text = strsplit("\n",text,2)
	while line do
		line = line:trim()
		local tableName = strsplit(":",line,2)
		if not tableName then

		elseif hotfixTableNameToType[tableName] == 1 or tonumber(tableName) then
			if tonumber(tableName) then line = ":"..line end
			local _,spellID,hotfixType,newData1,newData2 = strsplit(":",line)
			if newData1 then
				spellID = tonumber(spellID)
				if spellID then
					local data
					for i=1,#module.db.AllSpells do
						data = module.db.AllSpells[i]
						if data[1] == spellID then
							if hotfixType == "dur" then
								newData1 = tonumber(newData1)
								if newData1 then
									for j=4,8 do
										if data[j] then
											data[j][3] = newData1
										end
									end
								end
							elseif hotfixType == "cd" then
								newData1 = tonumber(newData1)
								if newData1 then
									for j=4,8 do
										if data[j] then
											data[j][2] = newData1
										end
									end
								end
							elseif hotfixType == "cleu" then
								newData1 = tonumber(newData1)
								if newData1 then
									for j=4,8 do
										if data[j] then
											data[j][1] = newData1
										end
									end
								end
							elseif tonumber(hotfixType) then
								if hotfixType < 4 then
									data[hotfixType] = tonumber(newData1) or newData1
								elseif data[hotfixType] then
									newData1 = tonumber(newData1)
									if newData1 and newData2 then
										data[hotfixType][newData1] = tonumber(newData2) or newData2
									end
								end
							end
							break
						end
					end
				end
			end
		elseif tableName == "AllSpells2" then
			local _,spellID,specNum,cleu,cd,dur = strsplit(":",line,4)
			if dur then
				specNum = tonumber(specNum)
				spellID = tonumber(spellID)
				cleu = tonumber(cleu)
				cd = tonumber(cd)
				dur = tonumber(dur)
				if spellID and specNum and cleu and cd and dur then
					local data
					for i=1,#module.db.AllSpells do
						data = module.db.AllSpells[i]
						if data[1] == spellID then
							data[specNum+4] = {cleu,cd,dur}
							break
						end
					end
				end
			end
		elseif hotfixTableNameToType[tableName] == 2 then
			local _,key,var = strsplit(":",line)
			key = tonumber(key or "")
			if var == "true" then
				var = true
			elseif var == "false" then
				var = false
			else
				var = tonumber(var or "") or var
			end
			if key and var then
				module.db[tableName][key] = var
			end
		elseif hotfixTableNameToType[tableName] == 3 then
			local _,key,var = strsplit(":",line,3)
			key = tonumber(key or "")
			if key and var then
				local new = {}
				local v1,v2 = strsplit(",",var,2)
				while v1 do
					if v1:find(";") then
						local new2 = {}
						local b1,b2 = strsplit(";",v1,2)
						while b1 do
							if b1 == "false" then b1 = false end
							if b1 == "true" then b1 = true end
							new2[#new2+1] = tonumber(b1) or b1
							if not b2 then break end
							b1,b2 = strsplit(";",b2,2)
						end
						v1 = new2
					end
					if v1 == "false" then v1 = false end
					if v1 == "true" then v1 = true end
					new[#new+1] = tonumber(v1) or v1
					if not v2 then break end
					v1,v2 = strsplit(",",v2,2)
				end
				module.db[tableName][key] = new
			end
		elseif hotfixTableNameToType[tableName] == 4 then
			local _,key,var = strsplit(":",line,3)
			key = tonumber(key or "")
			if key and var then
				local new = {}
				local v1,v2 = strsplit(",",var,2)
				while v1 do
					local b1,b2 = strsplit(":",v1,2)
					b1 = tonumber(b1) or b1
					b2 = tonumber(b2) or b2
					if b1 and b2 then
						new[b1] = b2
					end
					if not v2 then break end
					v1,v2 = strsplit(",",v2,2)
				end
				module.db[tableName][key] = new
			end
		end
		if not text then
			break
		end
		line, text = strsplit("\n",text,2)
	end
end


do
	local eventsView = {}

	local function IsAuraActive(unit,spellID)
		for i=1,60 do
			local name,_,_,_,_,_,_,_,_,auraSpellID = UnitAura(unit,i)
			if spellID == auraSpellID then
				return true
			elseif not name then
				return
			end
		end
	end

	local function GetUnitForAura(name, guid)
		if not name then return nil end
		if guid and UnitTokenFromGUID then
			local u = UnitTokenFromGUID(guid)
			if u then return u end
		end
		if UnitName("player") == name then return "player" end
		local nRaid = (GetNumRaidMembers and GetNumRaidMembers()) or 0
		if nRaid > 0 then
			for i = 1, nRaid do
				local u = "raid"..i
				if UnitName(u) == name then return u end
			end
		else
			local nParty = (GetNumPartyMembers and GetNumPartyMembers()) or 0
			for i = 1, nParty do
				local u = "party"..i
				if UnitName(u) == name then return u end
			end
		end
		return nil
	end

	local ScanSelfAuraAndApply
	ScanSelfAuraAndApply = function(sourceName, sourceGUID, spellID, line, retries)
		if not line then return false end
		local unit = GetUnitForAura(sourceName, sourceGUID)
		if unit then
			local foundDuration, foundExpiration
			for i = 1, 40 do
				local _,_,_,_,_,d,e,_,_,_,auraSpellID = UnitAura(unit, i, "HELPFUL")
				if not auraSpellID then break end
				if auraSpellID == spellID then
					foundDuration, foundExpiration = d, e
					break
				end
			end
			local nowT = GetTime()
			if foundDuration and foundDuration > 0 and foundExpiration and foundExpiration > nowT then
				line.lastUse = foundExpiration - foundDuration
				local dbDur = 0
				if line.db then
					for sid = 4, 8 do
						local seg = line.db[sid]
						if type(seg) == "table" and tonumber(seg[3]) then
							dbDur = seg[3]
							break
						end
					end
				end
				line.duration = (dbDur > 0 and foundDuration > dbDur) and dbDur or foundDuration
				if line.bar and line.bar.data == line then
					line.bar:UpdateStatus()
				end
				if module.db._updateAllPending == nil then
					module.db._updateAllPending = true
					if C_Timer and C_Timer.After then
						C_Timer.After(0.05, function()
							module.db._updateAllPending = nil
							UpdateAllData()
						end)
					else
						module.db._updateAllPending = nil
						UpdateAllData()
					end
				end
				return true
			end
		end
		if retries and retries > 0 and C_Timer and C_Timer.After then
			C_Timer.After(0.1, function()
				ScanSelfAuraAndApply(sourceName, sourceGUID, spellID, line, retries - 1)
			end)
		end
		return false
	end

	function module.main.COMBAT_LOG_EVENT_UNFILTERED(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,spellSchool,...)


		_G._MRT_CD_CALL_COUNT = (_G._MRT_CD_CALL_COUNT or 0) + 1
		_G._MRT_CD_LAST_EVENT = event
		_G._MRT_CD_LAST_SRC = sourceName
		_G._MRT_CD_LAST_SPELL = spellID
		if ExRT.isClassic and event == "SPELL_CAST_SUCCESS" and sourceName then
			_G._MRT_CD_DEBUG_SEEN = (_G._MRT_CD_DEBUG_SEEN or 0) + 1
		end
		if false and ExRT.isClassic and event == "SPELL_CAST_SUCCESS" and sourceName
		   and (_G._MRT_CD_DEBUG_SEEN or 0) <= 30 then
			local CDList = _db.cdsNav
			local bucket = CDList and CDList[sourceName]
			local line = bucket and (bucket[spellID] or bucket[spellName])
			local cNames = ""
			if CDList and _db.cdsNavData then
				local names = {}
				for k in pairs(_db.cdsNavData) do names[#names+1]=tostring(k) end
				cNames = table.concat(names,",")
			end
			local handled = eventsView[event] and "HANDLED" or "nohandler"
			print(string.format("|cff33ff99[MRT/CD]|r %s src=%s spell=%s(%s) line=%s bucket=%s roster=[%s]",
				handled, tostring(sourceName),tostring(spellName),tostring(spellID),
				line and "HIT" or "miss", bucket and "yes" or "no", cNames))
		end
		local func = eventsView[event]
		if not func then
			return
		end


		local needForceBroadcast = false
		if ExRT.isClassic and event == "SPELL_CAST_SUCCESS" then
			local pg = UnitGUID and UnitGUID("player")
			if pg and sourceGUID == pg and spellID then
				local scd = module.db.spellCDSync
				local map = module.db.spellCDSyncToSpell
				if map and not map[spellID] then
					scd[#scd+1] = spellID
					map[spellID] = spellID
					needForceBroadcast = true
				end
			end
		end
		local funcRet = func(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,spellSchool,...)
		if needForceBroadcast and module.main.SPELL_UPDATE_COOLDOWN then
			module.main.SPELL_UPDATE_COOLDOWN()
		end
		return funcRet
	end

	local env = {
		module = module,
		_db = _db,
		eventsView = eventsView,
		_C = _C,

		spell_startCDbyAuraApplied_fix = _db.spell_startCDbyAuraApplied_fix,
		spell_startCDbyAuraApplied = _db.spell_startCDbyAuraApplied,
		spell_aura_grant_talent = _db.aura_grant_talent,
		spell_startCDbySummon = _db.spell_startCDbySummon,
		spell_cancelDurOnCast = _db.spell_cancelDurOnCast,
		spell_isPetAbility = _db.spell_isPetAbility,
		spell_startCDbyAuraFade = _db.spell_startCDbyAuraFade,
		spell_startCDbyAuraFadeExt = _db.spell_startCDbyAuraFadeExt,
		spell_aoe_no_target = _db.spell_aoe_no_target,
		spell_isTalent = _db.spell_isTalent,
		spell_resetOtherSpells = _db.spell_resetOtherSpells,
		spell_isPvpTalent = _db.spell_isPvpTalent,
		spell_sharingCD = _db.spell_sharingCD,
		spell_reduceCdCast = _db.spell_reduceCdCast,
		spell_increaseDurationCast = _db.spell_increaseDurationCast,
		spell_runningSameSpell = _db.spell_runningSameSpell,
		spell_reduceCdByAuraFade = _db.spell_reduceCdByAuraFade,
		spell_reduceCdByAuraFadeBefore = _db.spell_reduceCdByAuraFadeBefore,
		spell_aura_list = _db.spell_aura_list,
		spell_aura_list_onTarget = _db.spell_aura_list_onTarget,
		spell_dispellsList = _db.spell_dispellsList,
		spell_threatBuff = _db.spell_threatBuff,
		spell_threatBuff_consumed = _db.spell_threatBuff_consumed,
		spell_threatBuff_consumed_lookup = _db.spell_threatBuff_consumed_lookup,
		spell_ReincarnationFix = _db.spell_ReincarnationFix,
		spell_ignoreUseWithAura = _db.spell_ignoreUseWithAura,
		talent_entries = _db.talent_entries,

		isWarlock = _db.vars.isWarlock,
		isRogue = _db.vars.isRogue,
		isPaladin = _db.vars.isPaladin,
		isMage = _db.vars.isMage,

		session_gGUIDs = _db.session_gGUIDs,
		session_PetOwner = _db.session_PetOwner,
		findspecspells = _db.findspecspells,
		globalGUIDs = {},
		CDList = _db.cdsNav,
		bit = bit,
		print = print,
		abs = abs,
		C_Timer = C_Timer,
		UnitAura = UnitAura,
		UnitSpellHaste = UnitSpellHaste,
		UnitHealthMax = UnitHealthMax,
		UnitHealth = UnitHealth,
		UnitName = UnitName,
		UnitGUID = UnitGUID,
		UnitIsUnit = UnitIsUnit,
		GetSpellInfo = GetSpellInfo,
		GetNumRaidMembers = GetNumRaidMembers,
		GetNumPartyMembers = GetNumPartyMembers,
		UnitTokenFromGUID = UnitTokenFromGUID,
		type = type,
		pairs = pairs,
		ipairs = ipairs,
		tonumber = tonumber,
		tostring = tostring,
		strsplit = strsplit,
		select = select,
		wipe = wipe,
		math = math,
		tinsert = tinsert,
		tremove = tremove,
		next = next,

		CLEUstartCD = CLEUstartCD,
		RecordHistoryUsage = RecordHistoryUsage,
		UpdateAllData = UpdateAllData,
		GetUnitInfoByUnitFlag = GetUnitInfoByUnitFlag,
		GetTime = GetTime,
		IsAuraActive = IsAuraActive,
		GetUnitForAura = GetUnitForAura,
		ScanSelfAuraAndApply = ScanSelfAuraAndApply,
		ExRT = ExRT,
		UnitClass = UnitClass,

		playerName = ExRT.SDB.charName,

		avengershield_var = {},
	}
	CLEU.Events = {
		SPELL_CAST_SUCCESS = {main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,spellSchool)
				if not sourceName then
					return
				end
				$$$2
				local forceUpdateAllData

				if spell_isPetAbility[spellID] then
					sourceName = session_PetOwner[sourceGUID] or sourceName
				end

				local findSpecSpell = findspecspells[spellID]
				if findSpecSpell and (GetUnitInfoByUnitFlag(sourceFlags,4) % 8) > 0 then
					if globalGUIDs[sourceName] ~= findSpecSpell then
						forceUpdateAllData = true
					end
					globalGUIDs[sourceName] = findSpecSpell
				end
				if spell_startCDbyAuraFade[spellID] then
					local lineForTarget = CDList[sourceName][spellID] or CDList[sourceName][spellName]
					if lineForTarget and destName and destName ~= "" and destName ~= sourceName and not spell_aoe_no_target[spellID] then
						lineForTarget.targetName = destName
						lineForTarget.targetSetTime = GetTime()
					end
					if forceUpdateAllData then UpdateAllData() end
					return
				end
				if spell_startCDbyAuraApplied_fix[spellID] then
					local lineForTarget = CDList[sourceName][spellID] or CDList[sourceName][spellName]
					if lineForTarget and destName and destName ~= "" and not spell_aoe_no_target[spellID] then
						lineForTarget.targetName = destName
						lineForTarget.targetSetTime = GetTime()
					end
					if forceUpdateAllData then UpdateAllData() end
					return
				end
				if spell_startCDbySummon[spellID] then
					if forceUpdateAllData then UpdateAllData() end
					return
				end
				if spell_ignoreUseWithAura[spellID] and IsAuraActive(sourceName,spell_ignoreUseWithAura[spellID]) then
					return
				end

				local line = CDList[sourceName][spellID] or CDList[sourceName][spellName]
				if line then
					local who = (destName ~= nil and destName ~= "" and not spell_aoe_no_target[spellID]) and destName or nil
					CLEUstartCD(line,who)
				end

				if spell_isTalent[spellID] and not isSpellDuplicateDisabled and not session_gGUIDs[sourceName][spellID] and not session_TalentBroadcastReceived[sourceName] then
					forceUpdateAllData = true
					session_gGUIDs[sourceName] = {spellID,"autotalent"}
				end

				local modifData = spell_resetOtherSpells[spellID]
				if modifData then
					for i=1,#modifData do
						local resetSpellID = modifData[i]
						if type(resetSpellID)~='table' or (session_gGUIDs[sourceName][ resetSpellID[2] ] and (not spell_isPvpTalent[ resetSpellID[2] ] or module.IsPvpTalentsOn(sourceName))) then
							resetSpellID = type(resetSpellID)=='table' and resetSpellID[1] or resetSpellID
							local line = CDList[sourceName][ resetSpellID ]
							if line then
								line:SetCD(0,true)

								forceUpdateAllData = true
							end
						end
					end
				end

				local cancelDurID = spell_cancelDurOnCast[spellID]
				if cancelDurID then
					local line = CDList[sourceName][cancelDurID]
					if line then
						line:SetDur(0,true)
						forceUpdateAllData = true
					end
				end

				local modifData = spell_sharingCD[spellID] or spell_sharingCD[spellName]
				if modifData then
					local nowTime = GetTime()
					for sharingSpellID,timeCD in pairs(modifData) do
						local line = CDList[sourceName][sharingSpellID]
						if line then
							local cd_timer_now = line.lastUse + line.cd - nowTime
							if (cd_timer_now > 0 and cd_timer_now < timeCD) or (nowTime - line.lastUse) > line.cd then
								line.cd = timeCD
								line.lastUse = nowTime
								line.duration = 0
								if line.bar and line.bar.data == line then
									line.bar:UpdateStatus()
								end
								forceUpdateAllData = true
							end
						end
					end
				end

				local modifData = spell_reduceCdCast[spellID]
				if modifData then
					local cdr_mod = 1
					for i=1,#modifData,2 do
						local reduceSpellID = modifData[i]
						if type(reduceSpellID) ~= "table" then
							local line = CDList[sourceName][reduceSpellID]
							local reduceTime = modifData[i+1]
							if line then
								line:ReduceCD(-reduceTime * cdr_mod,true)
								forceUpdateAllData = true
							end
						else
							local specReduceCD = reduceSpellID[3]
							local effectOnlyDuringBuffActive = reduceSpellID[4]
							if session_gGUIDs[sourceName][ reduceSpellID[2] ] and (not spell_isPvpTalent[ reduceSpellID[2] ] or module.IsPvpTalentsOn(sourceName)) and (not specReduceCD or (specReduceCD < 0 and globalGUIDs[sourceName] ~= specReduceCD or globalGUIDs[sourceName] == specReduceCD)) and (not effectOnlyDuringBuffActive or IsAuraActive(sourceName,effectOnlyDuringBuffActive)) then
								local line = CDList[sourceName][ reduceSpellID[1] ]

								local reduceTime = modifData[i+1]
								if type(reduceTime) == "table" and #reduceTime <= 5 then
									local talent_rank = _db.talent_classic_rank[sourceName][ reduceSpellID[2] ] or #reduceTime
									reduceTime = reduceTime[talent_rank] or reduceTime[#reduceTime]
								end

								if line then
									line:ReduceCD(-reduceTime * cdr_mod,true)
									forceUpdateAllData = true
								end
							end
						end
					end
				end

				local modifData = spell_increaseDurationCast[spellID]
				if modifData then
					for i=1,#modifData,2 do
						local increaseSpellID = modifData[i]
						if type(increaseSpellID) ~= "table" then
							local line = CDList[sourceName][increaseSpellID]
							if line and (GetTime() - line.lastUse) < line.duration  then
								line:ChangeDur(modifData[i+1],true)
								forceUpdateAllData = true
							end
						else
							if session_gGUIDs[sourceName][ increaseSpellID[2] ] then
								local line = CDList[sourceName][ increaseSpellID[1] ]

								local incTime = modifData[i+1]

								if line and (GetTime() - line.lastUse) < line.duration then
									line:ChangeDur(incTime,true)
									forceUpdateAllData = true
								end
							end
						end
					end
				end

				local modifData = spell_runningSameSpell[spellID]
				if modifData and not isSpellDuplicateDisabled then
					for i=1,#modifData do
						local sameSpellID = modifData[i]
						if sameSpellID ~= spellID then
							isSpellDuplicateDisabled = true
							eventsView.SPELL_CAST_SUCCESS(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,sameSpellID,spellName,spellSchool)
							isSpellDuplicateDisabled = false
						end
					end
				end

				if spellID == 1856 and (session_gGUIDs[sourceName][340080] or session_gGUIDs[sourceName][382523]) then
					local talent_rank = _db.talent_classic_rank[sourceName][382523] or 2
					local timeReduce = 10 * talent_rank
					for j=1,#_C do
						local line = _C[j]
						if line.fullName == sourceName and line.db[1] ~= 1856 then
							line:ReduceCD(timeReduce,true)
							forceUpdateAllData = true
						end
					end
				end
				$$$1

				if forceUpdateAllData then
					UpdateAllData()
				end
			end
		]],classic=[[
			if spellID == 25937 or spellID == 33667 then
				return
			end
			if ExRT.isLK and spell_threatBuff and spell_threatBuff[spellID] then
				local line = CDList[sourceName][spellID] or CDList[sourceName][spellName]
				if line then
					if destName and destName ~= "" and destName ~= sourceName then
						line.targetName = destName
						line.targetSetTime = GetTime()
						local _,tc = UnitClass(destName)
						line.targetClass = tc
					else
						line.targetName = nil
						line.targetSetTime = nil
						line.targetClass = nil
					end
					local nowT = GetTime()
					local activeAlive = line.lastUse and line.duration and line.duration > 0 and (nowT - line.lastUse) < line.duration
					if not activeAlive then
						line.lastUse = nowT
						line.duration = 0
					end
					line.cd = 30
					if line.bar and line.bar.data == line then
						line.bar:UpdateStatus()
					end
					UpdateAllData()
				end
				return
			end

			local who = (destName ~= nil and destName ~= "" and not spell_aoe_no_target[spellID]) and destName or nil
			local startsByAura = spell_startCDbyAuraFade[spellID] or spell_startCDbyAuraApplied_fix[spellID]
			local line = CDList[sourceName][spellID] or CDList[sourceName][spellName]
			if module.db.phaseDebug and (spell_aura_list[spellID] or spell_startCDbyAuraFade[spellID] or (spell_threatBuff and spell_threatBuff[spellID])) then
				print("|cff88ccff[PH CAST]|r",spellID,sourceName,"line="..(line and "Y" or "N"),"fade="..(startsByAura and "Y" or "N"),"lastUse="..tostring(line and line.lastUse),"dur="..tostring(line and line.duration),"cd="..tostring(line and line.cd))
			end
			if line and not startsByAura then
				CLEUstartCD(line,who)
			end

			if spell_isTalent[spellID] and not isSpellDuplicateDisabled and not session_gGUIDs[sourceName][spellID] and not session_TalentBroadcastReceived[sourceName] then
				session_gGUIDs[sourceName] = {spellID,"autotalent"}
				UpdateAllData()
				if not line and not startsByAura then
					local newLine = CDList[sourceName][spellID] or CDList[sourceName][spellName]
					if newLine then
						CLEUstartCD(newLine,who)
					end
				end
			end
		]],},
		SPELL_AURA_APPLIED = {main=[[
			blessingcdr = {}
			symbolofhope = {}
			symbolofhopeSpells = {
				[22812]=true,[198589]=true,[48792]=true,[204021]=true,[109304]=true,[55342]=true,
				[115203]=true,[19236]=true,[108271]=true,[104773]=true,[871]=true,[118038]=true,
				[184364]=true,[498]=true,[31850]=true,[184662]=true,
			}
			thundercharge = {}
			faerie = {}
			faerieCond = {}
			faerieSpells = {
				[740]=true,[1122]=true,[1719]=true,[12042]=true,[12472]=true,[13750]=true,
				[31884]=true,[47536]=true,[47568]=true,[50334]=true,[51533]=true,[55233]=true,
				[61336]=true,[64843]=true,[79140]=true,[102543]=true,[102560]=true,[106951]=true,
				[107574]=true,[108280]=true,[109964]=true,[115203]=true,[115310]=true,[121471]=true,
				[137639]=true,[152173]=true,[152277]=true,[187827]=true,[190319]=true,[191427]=true,
				[192249]=true,[193530]=true,[194223]=true,[194249]=true,[198067]=true,[198144]=true,
				[205180]=true,[216331]=true,[227847]=true,[228260]=true,[231895]=true,[265187]=true,
				[266779]=true,[275699]=true,[288613]=true,[297850]=true,[333957]=true,[335235]=true,
				[102558]=true,
			}
			shiftingpower = {}

			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,school,auraType)
				if not sourceName then
					return
				end
				$$$2
				local CDspellID = spell_startCDbyAuraApplied[spellID]
				if CDspellID then
					if spell_isTalent[CDspellID] and not session_gGUIDs[sourceName][CDspellID] then
						session_gGUIDs[sourceName] = {CDspellID,"autotalent"}
						UpdateAllData()
					end
					local line = CDList[sourceName][CDspellID]
					if line then
						local who = (destName ~= nil and destName ~= "" and not spell_aoe_no_target[spellID] and not spell_aoe_no_target[CDspellID]) and destName or nil
						if not who and line.targetName and line.targetSetTime and (GetTime() - line.targetSetTime) < 30 then
							who = line.targetName
						end
						CLEUstartCD(line,who)
					end
				end

				local talentFromAura = spell_aura_grant_talent[spellID]
				if talentFromAura then
					if type(talentFromAura) == "table" then
						if not talentFromAura[1] or talentFromAura[1]==0 or session_gGUIDs[sourceName][ talentFromAura[1] ] then
							for i=2,#talentFromAura do
								session_gGUIDs[sourceName] = {talentFromAura[i],"aura"}
							end
						end
					else
						session_gGUIDs[sourceName] = {talentFromAura,"aura"}
					end
					UpdateAllData()
				end

				if (spellID == 328622 or spellID == 388010) and destName then	--Blessing of Autumn
					if blessingcdr[sourceName] then
						blessingcdr[sourceName]:Cancel()
					end
					local power
					for i=1,60 do
						local _,_,_,_,_,_,_,_,_,auraSpellID,_,_,_,_,_,val = UnitAura(destName,i)
						if not auraSpellID then
							break
						elseif auraSpellID == 328622 or auraSpellID == 388010 then
							power = (val or 30)/100
							break
						end
					end
					blessingcdr[sourceName] = C_Timer.NewTicker(1,function()
						local line, updateReq
						for j=1,#_C do
							line = _C[j]
							if line.fullName == destName then
								line:ReduceCD(power or 0.3,true)
								updateReq = true
							end
						end
						if updateReq then
							UpdateAllData()
						end
					end, 30)
				elseif spellID == 64901 and destName and sourceName then	--Symbol of Hope
					local hymnDur = 5 / (1 + (UnitSpellHaste(sourceName) or 0) /100)
					local perSec = 60 / hymnDur

					symbolofhope[sourceName..":"..destName] = C_Timer.NewTicker(1,function(self)
						local line, updateReq
						for j=1,#_C do
							line = _C[j]
							if line.fullName == destName and line.db and symbolofhopeSpells[ line.db[1] ] then
								line:ReduceCD(perSec,true)
								updateReq = true
							end
						end
						self.last = GetTime()
						if updateReq then
							UpdateAllData()
						end
					end, hymnDur)
					symbolofhope[sourceName..":"..destName].OnCancel = function(self)
						local now = GetTime()
						if not self.last or ((now - self.last) < 0.2) then
							return
						end
						local updateReq
						for j=1,#_C do
							local line = _C[j]
							if line.fullName == destName and line.db and symbolofhopeSpells[ line.db[1] ] then
								line:ReduceCD((now - self.last)*perSec,true)
								updateReq = true
							end
						end
						if updateReq then
							UpdateAllData()
						end
					end
				elseif spellID == 204366 and destName then	--Thundercharge
					if thundercharge[destName] then
						thundercharge[destName]:Cancel()
					end
					local power
					for i=1,60 do
						local _,_,_,_,_,_,_,_,_,auraSpellID,_,_,_,_,_,val = UnitAura(destName,i)
						if not auraSpellID then
							break
						elseif auraSpellID == 204366 then
							power = (val or 30)/100
							break
						end
					end
					thundercharge[destName] = C_Timer.NewTicker(1,function()
						local line, updateReq
						for j=1,#_C do
							line = _C[j]
							if line.fullName == destName then
								line:ReduceCD(power or 0.3,true)
								updateReq = true
							end
						end
						if updateReq then
							UpdateAllData()
						end
					end, 10)
				elseif (spellID == 327710 or spellID == 345453) and destName and sourceName then	--Benevolent Faerie
					local db = spellID == 327710 and faerie or faerieCond
					local mod = spellID == 327710 and 1 or 0.8
					if session_gGUIDs[sourceName][356391] then
						mod = mod * 2
					end
					if db[sourceName..":"..destName] then
						db[sourceName..":"..destName]:Cancel()
					end
					db[sourceName..":"..destName] = C_Timer.NewTicker(1,function(self)
						local updateReq
						for j=1,#_C do
							local line = _C[j]
							if line.fullName == destName and line.db and faerieSpells[ line.db[1] ] then
								line:ReduceCD(1*mod,true)
								updateReq = true
							end
						end
						self.last = GetTime()
						if updateReq then
							UpdateAllData()
						end
					end, 30)
					db[sourceName..":"..destName].OnCancel = function(self)
						local now = GetTime()
						if not self.last or ((now - self.last) < 0.2) then
							return
						end
						local updateReq
						for j=1,#_C do
							local line = _C[j]
							if line.fullName == destName and line.db and faerieSpells[ line.db[1] ] then
								line:ReduceCD((now - self.last)*mod,true)
								updateReq = true
							end
						end
						if updateReq then
							UpdateAllData()
						end
					end
				elseif (spellID == 314791 or spellID == 382440) and sourceName then	--Shifting Power
					if shiftingpower[sourceName] then
						shiftingpower[sourceName]:Cancel()
					end
					local len = 4 / (1 + (UnitSpellHaste(sourceName) or 0) /100)
					local changePerTick = 3
					shiftingpower[sourceName] = C_Timer.NewTicker(len / 4,function()
						local line, updateReq
						for j=1,#_C do
							line = _C[j]
							if line.fullName == sourceName and line.db[1] ~= spellID then
								line:ReduceCD(changePerTick,true)
								updateReq = true
							end
						end
						if updateReq then
							UpdateAllData()
						end
					end, 4)
					shiftingpower[sourceName].t_end = GetTime() + len
				end

				$$$1
			end
		]],classic=[[
			if ExRT.isLK then
				if spell_aura_list[spellID] and sourceName and destName and sourceName == destName then
					local auraCDspellID = spell_aura_list[spellID]
					local line = CDList[sourceName][auraCDspellID]
					if line then
						local fb = 0
						if line.db then
							for sid = 4, 8 do
								local seg = line.db[sid]
								if type(seg) == "table" and tonumber(seg[3]) and seg[3] > 0 then
									fb = seg[3]
									break
								end
							end
						end
						local nowT = GetTime()
						if fb <= 0 then
							local unit = GetUnitForAura(destName, destGUID)
							if unit then
								for i = 1, 40 do
									local _,_,_,_,_,d,e,_,_,_,auraSpellID = UnitAura(unit, i, "HELPFUL")
									if not auraSpellID then break end
									if auraSpellID == spellID and d and d > 0 and e and e > nowT then
										fb = e - nowT
										break
									end
								end
							end
						end
						local prevDur = tonumber(line.duration) or 0
						local prevLast = tonumber(line.lastUse) or 0
						local activeAlive = prevDur > 0 and prevLast > 0 and (nowT - prevLast) < prevDur
						if module.db.phaseDebug then
							print("|cff66ff66[PH APPLIED]|r",spellID,"->",auraCDspellID,"fb="..tostring(fb),"activeAlive="..(activeAlive and "Y" or "N"),"prevDur="..tostring(prevDur))
						end
						if not activeAlive and fb > 0 then
							line.lastUse = nowT
							line.duration = fb
							RecordHistoryUsage(line, nil)
							if line.bar and line.bar.data == line then
								line.bar:UpdateStatus()
							end
						end
						ScanSelfAuraAndApply(sourceName, sourceGUID, spellID, line, 5)
						UpdateAllData()
					end
				end

				if spell_aura_list_onTarget and spell_aura_list_onTarget[spellID] and sourceName then
					local auraCDspellID = spell_aura_list_onTarget[spellID]
					local line = CDList[sourceName][auraCDspellID]
					if line then
						local nowT = GetTime()
						line.lastUse = nowT
						local cdVal = 0
						if line.db then
							for sid = 4, 8 do
								local seg = line.db[sid]
								if type(seg) == "table" and tonumber(seg[2]) then
									cdVal = seg[2]
									break
								end
							end
						end
						if cdVal > 0 then
							line.cd = cdVal
						end
						local foundExpiration
						local unit = GetUnitForAura(destName, destGUID)
						if unit then
							for i = 1, 40 do
								local _,_,_,_,_,_,e,_,_,_,auraSpellID = UnitAura(unit, i, "HELPFUL")
								if not auraSpellID then break end
								if auraSpellID == spellID then
									foundExpiration = e
									break
								end
							end
						end
						local durVal
						if foundExpiration and foundExpiration > nowT then
							durVal = foundExpiration - nowT
						else
							durVal = cdVal > 0 and cdVal or 900
						end
						if cdVal > 0 and durVal > cdVal then
							durVal = cdVal
						end
						line.duration = durVal
						line.targetName = destName
						line.targetSetTime = nowT
						RecordHistoryUsage(line, destName)
						if line.bar and line.bar.data == line then
							line.bar:UpdateStatus()
						end
						UpdateAllData()
					end
				end

				if spell_threatBuff and spell_threatBuff[spellID] and sourceName and destName and sourceName == destName then
					local line = CDList[sourceName][ spell_threatBuff[spellID] ]
					if line then
						if not ScanSelfAuraAndApply(sourceName, sourceGUID, spellID, line, 5) then
							if not line.lastUse or line.lastUse == 0 or (GetTime() - line.lastUse) > 30 then
								line.lastUse = GetTime()
							end
							if not line.duration or line.duration <= 0 then
								line.duration = 30
							end
							if line.bar and line.bar.data == line then
								line.bar:UpdateStatus()
							end
						end
						UpdateAllData()
					end
				end

				if spell_threatBuff_consumed and spell_threatBuff_consumed[spellID] and sourceName then
					local armedSpellID = spell_threatBuff_consumed[spellID]
					local line = CDList[sourceName][armedSpellID]
					if line and line.lastUse and line.lastUse > 0 then
						local function scanAndExtend(name, guid, retries)
							local unit = GetUnitForAura(name, guid)
							local foundDuration, foundExpiration
							if unit then
								for i = 1, 40 do
									local _,_,_,_,_,d,e,_,_,_,auraSpellID = UnitAura(unit, i, "HELPFUL")
									if not auraSpellID then break end
									if auraSpellID == spellID then
										foundDuration, foundExpiration = d, e
										break
									end
								end
							end
							local nowT = GetTime()
							if foundDuration and foundDuration > 0 and foundExpiration and foundExpiration > nowT then
								line.duration = foundExpiration - line.lastUse
								if line.bar and line.bar.data == line then
									line.bar:UpdateStatus()
								end
								UpdateAllData()
								return true
							end
							return false
						end
						local applied = false
						if destName and destName ~= "" and destName ~= sourceName then
							applied = scanAndExtend(destName, destGUID, 0)
						end
						if not applied then
							applied = scanAndExtend(sourceName, sourceGUID, 0)
						end
						if not applied and C_Timer and C_Timer.After then
							local sName, sGUID, dName, dGUID = sourceName, sourceGUID, destName, destGUID
							local lineRef, sid = line, spellID
							local retry
							local count = 0
							retry = function()
								count = count + 1
								local doneA = false
								if dName and dName ~= "" and dName ~= sName then
									local unit = GetUnitForAura(dName, dGUID)
									if unit then
										for i = 1, 40 do
											local _,_,_,_,_,d,e,_,_,_,asid = UnitAura(unit, i, "HELPFUL")
											if not asid then break end
											if asid == sid then
												local nowT = GetTime()
												if d and d > 0 and e and e > nowT and lineRef.lastUse then
													lineRef.duration = e - lineRef.lastUse
													if lineRef.bar and lineRef.bar.data == lineRef then
														lineRef.bar:UpdateStatus()
													end
													UpdateAllData()
													doneA = true
												end
												break
											end
										end
									end
								end
								if not doneA then
									local unit = GetUnitForAura(sName, sGUID)
									if unit then
										for i = 1, 40 do
											local _,_,_,_,_,d,e,_,_,_,asid = UnitAura(unit, i, "HELPFUL")
											if not asid then break end
											if asid == sid then
												local nowT = GetTime()
												if d and d > 0 and e and e > nowT and lineRef.lastUse then
													lineRef.duration = e - lineRef.lastUse
													if lineRef.bar and lineRef.bar.data == lineRef then
														lineRef.bar:UpdateStatus()
													end
													UpdateAllData()
													doneA = true
												end
												break
											end
										end
									end
								end
								if not doneA and count < 5 then
									C_Timer.After(0.1, retry)
								end
							end
							C_Timer.After(0.1, retry)
						end
					end
				end

			end
		]]},
		SPELL_AURA_REMOVED = {main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,school,auraType)
				if not sourceName then
					return
				end
				$$$2
				local forceUpdateAllData

				local modifData = spell_reduceCdByAuraFade[spellID]
				if modifData then
					local CDspellID = modifData[1]
					if type(CDspellID) ~= "table" then
						local line = CDList[sourceName][CDspellID]
						if line and abs(GetTime() - line.lastUse - line.duration) < 0.5 then
							line:ModCD(modifData[2],true)
							forceUpdateAllData = true
						end
					else
						if session_gGUIDs[sourceName][ CDspellID[2] ] then
							local line = CDList[sourceName][ CDspellID[1] ]
							if line and abs(GetTime() - line.lastUse - line.duration) < 0.5 then
								line:ModCD(modifData[2],true)
								forceUpdateAllData = true
							end
						end
					end
				end

				local modifData = spell_reduceCdByAuraFadeBefore[spellID]
				if modifData then
					local CDspellID = modifData[1]
					if type(CDspellID) ~= "table" then
						local line = CDList[sourceName][CDspellID]
						if line and abs(GetTime() - line.lastUse - line.duration) > 0.5 then
							line:ModCD(modifData[2],true)
							forceUpdateAllData = true
						end
					else
						if session_gGUIDs[sourceName][ CDspellID[2] ] then
							local line = CDList[sourceName][ CDspellID[1] ]
							if line and abs(GetTime() - line.lastUse - line.duration) > 0.5 then
								line:ModCD(modifData[2],true)
								forceUpdateAllData = true
							end
						end
					end
				end

				local CDspellID = spell_aura_list[spellID]
				if CDspellID then
					if CDspellID == 198839 then	--Earthen Wall
						sourceName = ExRT.F.Pets:getOwnerNameByGUID(destGUID)
					end
					local line = CDList[sourceName][ CDspellID ]
					if line then
						line:SetDur(0,true)
						forceUpdateAllData = true
					end
				end

				if spell_aura_list_onTarget and spell_aura_list_onTarget[spellID] and sourceName then
					local auraCDspellID = spell_aura_list_onTarget[spellID]
					local line = CDList[sourceName][auraCDspellID]
					if line and line.lastUse and line.lastUse > 0 then
						line:SetDur(0,true)
						forceUpdateAllData = true
					end
				end

				local CDspellID = spell_startCDbyAuraFade[spellID]
				if CDspellID then
					local line = CDList[sourceName][CDspellID]
					if module.db.phaseDebug then
						print("|cffff8866[PH FADE->CD]|r",spellID,"->",CDspellID,"line="..(line and "Y" or "N"))
					end
					if line then
						local who
						if line.targetName and line.targetSetTime and (GetTime() - line.targetSetTime) < 30 then
							who = line.targetName
						elseif destName and destName ~= "" and destName ~= sourceName and not spell_aoe_no_target[spellID] and not spell_aoe_no_target[CDspellID] then
							who = destName
						end
						line.duration = 0
						CLEUstartCD(line,who)
					end
				end

				local CDspellID = spell_startCDbyAuraFadeExt[spellID]
				if CDspellID then
					local line = CDList[sourceName][CDspellID]
					if line then
						local who
						if line.targetName and line.targetSetTime and (GetTime() - line.targetSetTime) < 30 then
							who = line.targetName
						elseif destName and destName ~= "" and destName ~= sourceName and not spell_aoe_no_target[spellID] and not spell_aoe_no_target[CDspellID] then
							who = destName
						end
						line.duration = 0
						CLEUstartCD(line,who)
					end
				end

				local talentFromAura = spell_aura_grant_talent[spellID]
				if talentFromAura then
					if type(talentFromAura) == "table" then
						if not talentFromAura[1] or talentFromAura[1]==0 or session_gGUIDs[sourceName][ talentFromAura[1] ] then
							for i=2,#talentFromAura do
								session_gGUIDs[sourceName] = -talentFromAura[i]
							end
						end
					else
						session_gGUIDs[sourceName] = -talentFromAura
					end
					forceUpdateAllData = true
				end

				if (spellID == 328622 or spellID == 388010) and destName then	--Blessing of Autumn
					C_Timer.After(.5,function()
						if blessingcdr[sourceName] then
							blessingcdr[sourceName]:Cancel()
						end
					end)
				elseif spellID == 64901 and destName then	--Symbol of Hope
					C_Timer.After(0.1,function()
						if symbolofhope[sourceName..":"..destName] then
							symbolofhope[sourceName..":"..destName]:OnCancel()
							symbolofhope[sourceName..":"..destName]:Cancel()
						end
					end)
				elseif spellID == 204366 and destName then	--Thundercharge
					C_Timer.After(.5,function()
						if thundercharge[destName] then
							thundercharge[destName]:Cancel()
						end
					end)
				elseif (spellID == 327710  or spellID == 345453) and destName then	--Benevolent Faerie
					local db = spellID == 327710 and faerie or faerieCond
					C_Timer.After(0.1,function()
						if db[sourceName..":"..destName] then
							db[sourceName..":"..destName]:OnCancel()
							db[sourceName..":"..destName]:Cancel()
						end
					end)
				elseif (spellID == 314791 or spellID == 382440) then	--Shifting Power
					if shiftingpower[sourceName] then
						local now = GetTime()
						if abs(now - shiftingpower[sourceName].t_end) > 0.2 then
							shiftingpower[sourceName]:Cancel()
						end
					end
				elseif spellID == 206005 then	--Xavius: Dream Simulacrum
					for i=1,#_C do
						local unitSpellData = _C[i]
						if unitSpellData.fullName == destName then
							unitSpellData:SetCD(0,true)
							unitSpellData:SetDur(0,true)

							forceUpdateAllData = true
						end
					end
				end
				$$$1

				if forceUpdateAllData then
					UpdateAllData()
				end
			end
		]],classic=[[
			if ExRT.isLK then
				local CDspellID = spell_threatBuff and spell_threatBuff[spellID]
				if CDspellID and sourceName == destName then
					local line = CDList[sourceName][CDspellID]
					if line and line.lastUse and line.duration then
						local elapsed = GetTime() - line.lastUse
						if elapsed >= 0 and elapsed < (line.duration - 1) then
							if not (spell_threatBuff_consumed_lookup and spell_threatBuff_consumed_lookup[spellID]) then
								line.duration = elapsed
								if line.bar and line.bar.data == line then
									line.bar:UpdateStatus()
								end
								UpdateAllData()
							else
								if C_Timer and C_Timer.After then
									local consumedSpellID = spell_threatBuff_consumed_lookup[spellID]
									local lineRef = line
									local sName, sGUID, dName, dGUID = sourceName, sourceGUID, destName, destGUID
									C_Timer.After(0.3, function()
										local hasConsumed = false
										if dName and dName ~= "" and dName ~= sName and consumedSpellID then
											local unit = GetUnitForAura(dName, dGUID)
											if unit then
												for i = 1, 40 do
													local _,_,_,_,_,d,e,_,_,_,asid = UnitAura(unit, i, "HELPFUL")
													if not asid then break end
													if asid == consumedSpellID then
														hasConsumed = true
														if d and d > 0 and e and e > GetTime() and lineRef.lastUse then
															lineRef.duration = e - lineRef.lastUse
															if lineRef.bar and lineRef.bar.data == lineRef then
																lineRef.bar:UpdateStatus()
															end
															UpdateAllData()
														end
														break
													end
												end
											end
										end
										if not hasConsumed and consumedSpellID then
											local unit = GetUnitForAura(sName, sGUID)
											if unit then
												for i = 1, 40 do
													local _,_,_,_,_,d,e,_,_,_,asid = UnitAura(unit, i, "HELPFUL")
													if not asid then break end
													if asid == consumedSpellID then
														hasConsumed = true
														if d and d > 0 and e and e > GetTime() and lineRef.lastUse then
															lineRef.duration = e - lineRef.lastUse
															if lineRef.bar and lineRef.bar.data == lineRef then
																lineRef.bar:UpdateStatus()
															end
															UpdateAllData()
														end
														break
													end
												end
											end
										end
										if not hasConsumed and lineRef.lastUse and lineRef.duration then
											local el = GetTime() - lineRef.lastUse
											if el >= 0 and el < (lineRef.duration - 1) then
												lineRef.duration = el
												if lineRef.bar and lineRef.bar.data == lineRef then
													lineRef.bar:UpdateStatus()
												end
												UpdateAllData()
											end
										end
									end)
								else
									line.duration = elapsed
									if line.bar and line.bar.data == line then
										line.bar:UpdateStatus()
									end
									UpdateAllData()
								end
							end
						end
					end
				end
			end
		]]},
		PREP = {main=[[
			return function ()
				$$$1
			end
		]]},
		SPELL_SUMMON = {main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName)
				$$$2
				if sourceName and spell_startCDbySummon[spellID] then
					local CDspellID = spell_startCDbySummon[spellID]
					local line = CDList[sourceName][CDspellID]
					if line then
						local who = (destName ~= nil and destName ~= "" and not spell_aoe_no_target[CDspellID]) and destName or nil
						CLEUstartCD(line,who)
					end
				end
				$$$1
			end
		]]},
		SPELL_AURA_APPLIED_DOSE = {isEmpty=true,main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,type,stack)
				$$$2
				$$$1
			end
		]]},
		SPELL_AURA_REMOVED_DOSE = {isEmpty=true,main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,type,stack)
				$$$2
				$$$1
			end
		]]},
		SPELL_DISPEL = {main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,destSpell)
				$$$2
				if spell_dispellsList[spellID] and sourceName then
					_db.spell_dispellsFix[ sourceName ] = true
				end
				$$$1
			end
		]]},
		SPELL_DAMAGE = {isEmpty=true,main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand)
				$$$2
				$$$1
			end
		]],subevents={RANGE_DAMAGE=true,SPELL_PERIODIC_DAMAGE=true,SWING_DAMAGE=[[
			local meleeStr = GetSpellInfo(6603)
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand)
				return eventsView.SPELL_DAMAGE(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,6603,meleeStr,1,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand)
			end
		]]}},
		SPELL_HEAL = {isEmpty=true,main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,amount,overhealing,absorbed,critical)
				$$$2
				$$$1
			end
		]],subevents={SPELL_PERIODIC_HEAL=true}},
		SPELL_ENERGIZE = {isEmpty=true,main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,amount,overEnergize,powerType,alternatePowerType)
				$$$2
				$$$1
			end
		]],subevents={SPELL_PERIODIC_ENERGIZE=true}},
		SPELL_MISSED = {isEmpty=true,main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,missType,isOffHand,amountMissed,critical)
				$$$2
				$$$1
			end
		]],subevents={RANGE_MISSED=true,SPELL_PERIODIC_MISSED=true,SWING_MISSED=[[
			local meleeStr = GetSpellInfo(6603)
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,missType,isOffHand,amountMissed,critical)
				if not eventsView.SPELL_MISSED then return end	--temp fix
				return eventsView.SPELL_MISSED(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,6603,meleeStr,1,missType,isOffHand,amountMissed,critical)
			end
		]]}},
		SPELL_INTERRUPT = {isEmpty=true,main=[[
			return function (timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,_,destSpell)
				$$$2
				$$$1
			end
		]]},
	}

	function CLEU:Recreate()
		env.globalGUIDs = globalGUIDs
		env.playerName = ExRT.SDB.charName

		env.spell_startCDbyAuraApplied_fix = _db.spell_startCDbyAuraApplied_fix
		env.spell_startCDbyAuraApplied = _db.spell_startCDbyAuraApplied
		env.spell_aura_grant_talent = _db.aura_grant_talent
		env.spell_startCDbySummon = _db.spell_startCDbySummon
		env.spell_cancelDurOnCast = _db.spell_cancelDurOnCast
		env.spell_isPetAbility = _db.spell_isPetAbility
		env.spell_startCDbyAuraFade = _db.spell_startCDbyAuraFade
		env.spell_startCDbyAuraFadeExt = _db.spell_startCDbyAuraFadeExt
		env.spell_aoe_no_target = _db.spell_aoe_no_target
		env.spell_isTalent = _db.spell_isTalent
		env.spell_resetOtherSpells = _db.spell_resetOtherSpells
		env.spell_isPvpTalent = _db.spell_isPvpTalent
		env.spell_sharingCD = _db.spell_sharingCD
		env.spell_reduceCdCast = _db.spell_reduceCdCast
		env.spell_increaseDurationCast = _db.spell_increaseDurationCast
		env.spell_runningSameSpell = _db.spell_runningSameSpell
		env.spell_reduceCdByAuraFade = _db.spell_reduceCdByAuraFade
		env.spell_reduceCdByAuraFadeBefore = _db.spell_reduceCdByAuraFadeBefore
		env.spell_aura_list = _db.spell_aura_list
		env.spell_aura_list_onTarget = _db.spell_aura_list_onTarget
		env.spell_dispellsList = _db.spell_dispellsList
		env.spell_threatBuff = _db.spell_threatBuff
		env.spell_threatBuff_consumed = _db.spell_threatBuff_consumed
		env.spell_threatBuff_consumed_lookup = _db.spell_threatBuff_consumed_lookup
		env.spell_ReincarnationFix = _db.spell_ReincarnationFix
		env.spell_ignoreUseWithAura = _db.spell_ignoreUseWithAura
		env.talent_entries = _db.talent_entries
		env.session_gGUIDs = _db.session_gGUIDs
		env.session_TalentBroadcastReceived = _db.session_TalentBroadcastReceived
		env.session_PetOwner = _db.session_PetOwner
		env.findspecspells = _db.findspecspells
		env.CDList = _db.cdsNav

		for event,db in pairs(CLEU.Events) do
			if db.isEmpty and #db == 0 then
				eventsView[event] = nil
			else
				local full = db.main
				for i=1,#db do
					full = full:gsub("%$%$%$1",db[i].."$$$1")
				end
				if ExRT.isClassic then
					if db.classic then
						full = full:gsub("%$%$%$2",db.classic.."$$$2")
					end


					full = full:gsub("%$%$%$2","")
				end

				full = full:gsub("%$%$%$%d","")
				local f = assert(loadstring(full,"ExCD2:"..event))
				setfenv(f,env)
				eventsView[event] = f()
				if db.subevents then
					for subevent,substr in pairs(db.subevents) do
						if type(substr) == "string" then
							local sf = assert(loadstring(substr,"ExCD2:"..subevent))
							setfenv(sf,env)
							eventsView[subevent] = sf()
						else
							eventsView[subevent] = eventsView[event]
						end
					end
				end

				db.devstr = full
			end
		end
		eventsView.PREP()
		eventsView.PREP = nil
	end
	function CLEU:Reset()
		for event,db in pairs(CLEU.Events) do
			if db.main then
				for i=1,#db do
					db[i] = nil
				end
			else
				CLEU.Events[event] = nil
			end
		end
	end
	function CLEU:Add(event,str)
		if event:find("^CLEU_") then
			event = event:gsub("^CLEU_","")
		end
		if not CLEU.Events[event] then
			return
		end
		tinsert(CLEU.Events[event],str)
	end

	local isPaladin = _db.vars.isPaladin
	function module.main:ARENA_COOLDOWNS_UPDATE(unitID)
		local guid = UnitGUID(unitID)
		if not guid then return end
		if isPaladin[guid] then
			local t = GetTime()
			if (t - 0.5) < (env.avengershield_var[guid] or 0) then
				local name,realm = UnitName(unitID)
				if name then
					if realm then
						name = name .. "-" .. realm
					end
					local line = _db.cdsNav[name][31935]
					if line then
						line:ResetCD()
					end
				end
			end
		end
	end


	local SCSSpells = module.db._SCSSpells or {}
	module.db._SCSSpells = SCSSpells

	local SCSByName = module.db._SCSByName or {}
	module.db._SCSByName = SCSByName
	for id,_ in pairs(SCSSpells) do
		local n = GetSpellInfo(id)
		if n and n ~= '' then SCSByName[n] = id end
	end

		local SCSBlack = {}
		function module.main:UNIT_SPELLCAST_SUCCEEDED(unitID, spellName, spellRank, lineID, spellID)


			if type(spellName) == 'number' and type(spellID) ~= 'number' then

				spellID = spellName
				spellName = GetSpellInfo(spellID)
				lineID = nil
			elseif type(spellID) ~= 'number' then
				if type(lineID) == 'number' then

					spellID = lineID
					lineID = nil
				elseif type(spellName) == 'string' then
					spellID = module.db._SCSByName and module.db._SCSByName[spellName] or nil
				end
			end
			if not spellID or not SCSSpells[spellID] then return end

			local guid = UnitGUID(unitID)
			local castKey = tostring(lineID or spellID) .. ":" .. tostring(guid or "")
			if SCSBlack[castKey] then return end
			SCSBlack[castKey] = true

			ScheduleTimer(function() SCSBlack[castKey] = nil end, 0.2)

		local name, realm = UnitName(unitID)
		if name and realm and realm ~= '' then name = name .. '-' .. realm end


		if spellID == 5384 then
			local line = _db.cdsNav[name] and _db.cdsNav[name][5384]
			if ExRT.isClassic and not line and _db.cdsNav[name] then
				line = _db.cdsNav[name][GetSpellInfo(5384)]
			end
			if line and not ExRT.isLK then line:SetCD(360) end
			FD_GUIDs[guid] = true
			if not IsInJailersTower() then
				module:RegisterEvents('UNIT_AURA')
				if ScheduledUnitAura then ScheduledUnitAura:Cancel() end
				ScheduledUnitAura = ScheduleTimer(function() ScheduledUnitAura=nil; module:UnregisterEvents('UNIT_AURA') end,361)
			end
		end
	end

	function module.main.UNIT_DIED(_,_,_,destGUID,destName,destFlags)
		if destName then
			local _,class = UnitClass(destName)
			if class == "SHAMAN" and _db.spell_ReincarnationFix then
				_db.spell_ReincarnationFix[destName] = true
			end

			-- Soulstone fix: when player dies with Soulstone buff, clear the duration
			-- Check all warlocks who might have cast Soulstone on this player
			for warlockName, spells in pairs(CDList) do
				local soulstoneCD = spells[20765]
				if soulstoneCD and soulstoneCD.duration and soulstoneCD.duration > 0 then
					-- Check if the Soulstone target matches the dead player
					if soulstoneCD.targetName == destName then
						soulstoneCD:SetDur(0, true)
					end
				end
			end
		end
	end
	local function StartResurrectCD(srcName, spellID, spellName, targetName)
		if not srcName then return end
		local nav = _db.cdsNav[srcName]
		if not nav then return end
		local line = nav[spellID] or (spellName and nav[spellName])
		if not line then return end
		local now = GetTime()
		if line._lastRezStart and (now - line._lastRezStart) < 2 then
			if targetName and line.targetName ~= targetName then
				line.targetName = targetName
				line.targetSetTime = now
				local _,tc = UnitClass(targetName)
				line.targetClass = tc
				if line.bar and line.bar.data == line then line.bar:UpdateStatus() end
			end
			return
		end
		line._lastRezStart = now
		module.CLEUstartCD(line, targetName)
	end
	module.main.StartResurrectCD = StartResurrectCD
	function module.main.SPELL_RESURRECT(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName)
		if sourceName and spellName and _db.spell_target_byCast and _db.spell_target_byCast[spellName] then
			local who = (destName and destName ~= "" and destName ~= sourceName) and destName or nil
			StartResurrectCD(sourceName, spellID, spellName, who)
		end
		if destName and _db.spell_ReincarnationFix and _db.spell_ReincarnationFix[destName] then
			_db.spell_ReincarnationFix[destName] = nil
		end
	end

	function module.main:UNIT_FLAGS(unitID)
		local name = UnitCombatlogname(unitID)
		if name and _db.spell_ReincarnationFix and _db.spell_ReincarnationFix[name] and not UnitIsDead(unitID) then
			if not UnitIsGhost(unitID) then
				local hp = UnitHealth(unitID) / max(UnitHealthMax(unitID),1)
				if hp < 0.45 then
					eventsView.SPELL_CAST_SUCCESS(0,"SPELL_CAST_SUCCESS",false,UnitGUID(unitID),name,0,0,"","",0,0,20608,GetSpellInfo(20608),1)
				end
			end
			_db.spell_ReincarnationFix[name] = nil
		end
	end

	local isACUAdded = nil
	local isSCSAdded = nil
	local isAnkhAdded
	local isTargetByCastAdded
	function module:AddCLEUSpellDamage(spellID)
		if spellID == 31935 and not isACUAdded then
			module:RegisterEvents('ARENA_COOLDOWNS_UPDATE')
			isACUAdded = true
		elseif spellID == 5384 and not isSCSAdded then
			module:RegisterEvents('UNIT_SPELLCAST_SUCCEEDED')
			isSCSAdded = true
			SCSSpells[5384] = true
		elseif ExRT.isClassic and spellID == 20608 and not isAnkhAdded then
			_db.spell_ReincarnationFix = {}
			module:RegisterEvents('UNIT_FLAGS')
			eventsView.UNIT_DIED = module.main.UNIT_DIED
			eventsView.SPELL_RESURRECT = module.main.SPELL_RESURRECT
			isAnkhAdded = true
		end

		if ExRT.isLK and not isTargetByCastAdded and _db.spell_target_byCast and spellID then
			local sname = GetSpellInfo(spellID)
			if sname and _db.spell_target_byCast[sname] then
				module:RegisterEvents('UNIT_SPELLCAST_SENT','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_SUCCEEDED')
				if not eventsView.SPELL_RESURRECT then
					eventsView.SPELL_RESURRECT = module.main.SPELL_RESURRECT
				end
				isTargetByCastAdded = true
			end
		end
	end

	if ExRT.isLK then
		local pendingTargets = {}
		_db._pendingCastTargets = pendingTargets

		local function applyCastTarget(unitID, spellName)
			if not unitID or not spellName then return end
			local mapped = _db.spell_target_byCast and _db.spell_target_byCast[spellName]
			if not mapped then return end
			local name = UnitCombatlogname(unitID)
			if not name then return end
			local target = pendingTargets[name] and pendingTargets[name][spellName]
			if not target then return end
			pendingTargets[name][spellName] = nil
			local nav = _db.cdsNav[name]
			if not nav then return end
			local line = nav[mapped] or nav[spellName]
			if not line then return end
			line.targetName = target
			line.targetSetTime = GetTime()
			local _, tc = UnitClass(target)
			line.targetClass = tc
			if line.bar and line.bar.data == line then
				line.bar:UpdateStatus()
			end
		end

		function module.main:UNIT_SPELLCAST_SENT(unitID, spellName, _, targetName)
			if not unitID or not spellName then return end
			if not _db.spell_target_byCast or not _db.spell_target_byCast[spellName] then return end
			if not targetName or targetName == "" then return end
			local name = UnitCombatlogname(unitID)
			if not name then return end
			local row = pendingTargets[name]
			if not row then
				row = {}
				pendingTargets[name] = row
			end
			row[spellName] = targetName
		end

		function module.main:UNIT_SPELLCAST_FAILED(unitID, spellName)
			if not unitID or not spellName then return end
			if not _db.spell_target_byCast or not _db.spell_target_byCast[spellName] then return end
			local name = UnitCombatlogname(unitID)
			if not name then return end
			if pendingTargets[name] then
				pendingTargets[name][spellName] = nil
			end
		end

		local origSCS = module.main.UNIT_SPELLCAST_SUCCEEDED
		function module.main:UNIT_SPELLCAST_SUCCEEDED(unitID, spellName, spellRank, lineID, spellID)
			if spellName and _db.spell_target_byCast and _db.spell_target_byCast[spellName] then
				applyCastTarget(unitID, spellName)
				local name = UnitCombatlogname(unitID)
				if name and module.main.StartResurrectCD then
					module.main.StartResurrectCD(name, _db.spell_target_byCast[spellName], spellName)
				end
			end
			if origSCS then
				return origSCS(self, unitID, spellName, spellRank, lineID, spellID)
			end
		end
	end
end

function module.options:Load()
	self:CreateTilte()


	if not self.WarmUpSpell then
		local tip = CreateFrame("GameTooltip","MRTExCD2SpellWarmupTip",UIParent,"GameTooltipTemplate")
		tip:SetOwner(UIParent,"ANCHOR_NONE")
		tip:Hide()
		self._warmTip = tip
		function self:WarmUpSpell(spellID)
			spellID = tonumber(spellID)
			if not spellID then return end
			if GetSpellInfo(spellID) then return end
			local t = self._warmTip
			if t then
				t:SetHyperlink("spell:"..spellID)
				t:Hide()
			end
		end
	end

	self.decorationLine = ELib:DecorationLine(self,true,"BACKGROUND",-5):Point("TOPLEFT",self,0,-25):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-45)

	self.chkEnable = ELib:Check(self,L.Enable,VMRT.ExCD2.enabled):Point(720,-26):Size(18,18):Tooltip("/rt cd"):AddColorState():OnClick(function(self)
		if self:GetChecked() then
			module:Enable()
		else
			module:Disable()
		end
	end)

	self.chkLock = ELib:Check(self,L.cd2fix,VMRT.ExCD2.lock):Point(590,-26):Size(18,18):OnClick(function(self)
		if self:GetChecked() then
			VMRT.ExCD2.lock = true
		else
			VMRT.ExCD2.lock = nil
		end
		module:UpdateLockState()
	end)

	self.tab = ELib:Tabs(self,0,L.cd2Spells,L.cd2Appearance,L.cd2History):Point(0,-45):Size(850,589):SetTo(1)
	self.tab:SetBackdropBorderColor(0,0,0,0)
	self.tab:SetBackdropColor(0,0,0,0)


	self.CATEGORIES_DEF = {
		"ALL",
		"ENABLED",
		"FAV",
	}

	self.CATEGORIES_VIS = {
		["ALL"]       = {name = L.cd2CatAll,                            icon = "Interface\\Icons\\INV_Misc_Book_01",       sort = 0},
		["ENABLED"]   = {name = L.cd2CatEnabled,                        icon = "Interface\\Buttons\\UI-CheckBox-Check",     sort = 5, ignoreSubcats = true},
		["FAV"]       = {name = L.cd2Favorite,                          icon = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\star2", iconTcoord = {0,.5,0,.5}, sort = 200, ignoreSubcats = true},


		["RAID"]      = {name = L.cd2CatMajor,                          icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",      sort = 10, ignoreSubcats = true},
		["DEFTAR"]    = {name = L.cd2CatSingleTar,                      icon = (GetSpellTexture and GetSpellTexture(10278)) or "Interface\\Icons\\Spell_Holy_SealOfProtection",  sort = 15, ignoreSubcats = true},
		["RES"]       = {name = L.cd2CatRes,                            icon = "Interface\\Icons\\Spell_Holy_Resurrection",         sort = 20, ignoreSubcats = true},
		["RAIDSPEED"] = {name = L.cd2CatRaidMove,                       icon = "Interface\\Icons\\Ability_Rogue_Sprint",            sort = 25, ignoreSubcats = true},
		["DPS"]       = {name = L.cd2CatDPS,                            icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance", sort = 40, ignoreSubcats = true},
		["HEAL"]      = {name = L.cd2CatHeal,                           icon = "Interface\\Icons\\Spell_Holy_FlashHeal",            sort = 45, ignoreSubcats = true},
		["HEALUTIL"]  = {name = L.cd2CatHealUtil,                       icon = "Interface\\Icons\\Spell_Holy_GreaterHeal",          sort = 50, ignoreSubcats = true},
		["DEF"]       = {name = L.cd2CatDef,                            icon = "Interface\\Icons\\Spell_Holy_DevotionAura",         sort = 55, ignoreSubcats = true},
		["DEFTANK"]   = {name = L.cd2CatDefTank,                        icon = "Interface\\Icons\\INV_Shield_06",                   sort = 58, ignoreSubcats = true},
		["IMMUNITY"]  = {name = L.cd2CatImmunity or "Immunity",         icon = (GetSpellTexture and GetSpellTexture(642)) or "Interface\\Icons\\Spell_Nature_TimeStop",         sort = 60, ignoreSubcats = true},
		["UTIL"]      = {name = L.cd2CatUtil,                           icon = "Interface\\Icons\\INV_Misc_Wrench_01",              sort = 70, ignoreSubcats = true},
		["CC"]        = {name = L.cd2CatCC,                             icon = "Interface\\Icons\\Spell_Frost_ChainsOfIce",         sort = 75, ignoreSubcats = true},
		["AOECC"]     = {name = L.cd2CatMassStun,                       icon = "Interface\\Icons\\Spell_Frost_Stun",                sort = 78, ignoreSubcats = true},
		["KICK"]      = {name = L.cd2CatKicks,                          icon = "Interface\\Icons\\Ability_Kick",                    sort = 80, ignoreSubcats = true},
		["DISPEL"]    = {name = L.cd2CatDispells,                       icon = "Interface\\Icons\\Spell_Holy_Dispelmagic",          sort = 82, ignoreSubcats = true},
		["TAUNT"]     = {name = L.cd2CatTaunts,                         icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",   sort = 85, ignoreSubcats = true},
		["MOVE"]      = {name = L.cd2CatMove,                           icon = "Interface\\Icons\\Ability_Rogue_Sprint",            sort = 88, ignoreSubcats = true},

		["WARRIOR"]     = {name = L.classLocalizate["WARRIOR"],     icon = ExRT.F.classSquareIcon["WARRIOR"],     sort = 101, isClassCategory = true},
		["PALADIN"]     = {name = L.classLocalizate["PALADIN"],     icon = ExRT.F.classSquareIcon["PALADIN"],     sort = 102, isClassCategory = true},
		["HUNTER"]      = {name = L.classLocalizate["HUNTER"],      icon = ExRT.F.classSquareIcon["HUNTER"],      sort = 103, isClassCategory = true},
		["ROGUE"]       = {name = L.classLocalizate["ROGUE"],       icon = ExRT.F.classSquareIcon["ROGUE"],       sort = 104, isClassCategory = true},
		["PRIEST"]      = {name = L.classLocalizate["PRIEST"],      icon = ExRT.F.classSquareIcon["PRIEST"],      sort = 105, isClassCategory = true},
		["DEATHKNIGHT"] = {name = L.classLocalizate["DEATHKNIGHT"], icon = ExRT.F.classSquareIcon["DEATHKNIGHT"], sort = 106, isClassCategory = true},
		["SHAMAN"]      = {name = L.classLocalizate["SHAMAN"],      icon = ExRT.F.classSquareIcon["SHAMAN"],      sort = 107, isClassCategory = true},
		["MAGE"]        = {name = L.classLocalizate["MAGE"],        icon = ExRT.F.classSquareIcon["MAGE"],        sort = 108, isClassCategory = true},
		["WARLOCK"]     = {name = L.classLocalizate["WARLOCK"],     icon = ExRT.F.classSquareIcon["WARLOCK"],     sort = 109, isClassCategory = true},
		["DRUID"]       = {name = L.classLocalizate["DRUID"],       icon = ExRT.F.classSquareIcon["DRUID"],       sort = 111, isClassCategory = true},

		["ITEMS"]     = {name = L.cd2CatItems,                          icon = "Interface\\Icons\\INV_Misc_Bag_07",                 sort = 140, ignoreSubcats = true},
		["ESSENCES"]  = {name = L.cd2CatEssences,                       icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",           sort = 150, ignoreSubcats = true, isHidden = true},
		["RACIAL"]    = {name = L.cd2CatRacial,                         icon = "Interface\\Icons\\INV_Misc_Head_Human_01",          sort = 160, ignoreSubcats = true},

		["PET"]       = {name = PET,                                    icon = "Interface\\Icons\\Ability_Hunter_BeastSoothe",      sort = 185, ignoreSubcats = true},

		["PVP"]       = {name = CALENDAR_TYPE_PVP,                      icon = "Interface\\Icons\\INV_Banner_03",                   sort = 190, ignoreSubcats = true},

		["NO"]        = {name = L.cd2CatOther,                          icon = "Interface\\Icons\\INV_Misc_QuestionMark",           sort = 195, ignoreSubcats = true, isHidden = true},
		["OTHER"]     = {name = L.cd2CatOther,                          icon = "Interface\\Icons\\INV_Misc_QuestionMark",           sort = 197, ignoreSubcats = true},
		["USER"]      = {name = L.cd2CatUser,                           icon = "Interface\\Icons\\INV_Misc_Note_01",                sort = 199, ignoreOwncat = true},
	}

	if ExRT.isClassic then
		local WOTLK_HIDE_CATEGORIES = {
			"RAID", "DEFTAR", "RES", "RAIDSPEED",

			"DPS", "HEAL", "HEALUTIL", "DEF", "DEFTANK", "IMMUNITY",
			"UTIL", "CC", "AOECC", "KICK", "DISPEL", "TAUNT", "MOVE",

			"USER", "ITEMS", "RACIAL", "PET", "PVP", "OTHER",
		}
		for i=1,#WOTLK_HIDE_CATEGORIES do
			local cat = self.CATEGORIES_VIS[ WOTLK_HIDE_CATEGORIES[i] ]
			if cat then
				cat.isHidden = true
			end
		end
	end

	self.categories = ELib:ScrollFrame(self.tab.tabs[1]):Point("TOPLEFT",0,0):Size(100,589)
	ELib:Border(self.categories,0)
	self.categories.C:SetWidth(100)
	self.categories.mouseWheelRange = 200

	self.categories.ScrollBar:Size(8,0):Point("TOPRIGHT",0,0):Point("BOTTOMRIGHT",0,0)
	self.categories.ScrollBar.thumb:SetHeight(100)
	self.categories.ScrollBar.buttonUP:Hide()
	self.categories.ScrollBar.buttonDown:Hide()
	self.categories.ScrollBar.borderLeft:Hide()
	self.categories.ScrollBar.borderRight:Hide()
	self.categories.ScrollBar.bg:Hide()

	self.categories.buttons = {}

	self.categories.border_right = ELib:Texture(self.categories,.24,.25,.30,1,"BORDER"):Point("TOPLEFT",self.categories,"TOPRIGHT",0,0):Point("BOTTOMRIGHT",self.categories,"BOTTOMRIGHT",1,0)

	local function CategoriesButtonOnEnter(self)
		if not self.isActive then
			self.background:Show()
		end
	end
	local function CategoriesButtonOnLeave(self)
		self.background:Hide()
	end
	local function CategoriesButtonOnClick(self)
		for i=1,#module.options.categories.buttons do
			module.options.categories.buttons[i].isActive = false
		end
		self.background:Hide()
		self.isActive = true
		module.options.categories:Update()
		module.options.list:UpdateDB(self.category)
		module.options.list:Update()
		module.options.list.ScrollBar.slider:SetValue(0)
	end
	local CATEGORIES_INDEX_COUNTER = 200

	function self:GetAllSpells(addPvP)
		local new = {}
		for i=1,#module.db.AllSpells do
			if addPvP then
				new[i] = module.db.AllSpells[i]
			else
				local findPvP = false
				for cat in string.gmatch(module.db.AllSpells[i][2], "[^,]+") do
					if cat == "PVP" then
						findPvP = true
						break
					end
				end
				if (findPvP and addPvP) or (not findPvP and not addPvP) then
					new[#new+1] = module.db.AllSpells[i]
				end
			end
		end
		for i=1,#VMRT.ExCD2.userDB do
			local line = VMRT.ExCD2.userDB[i]
			if type(line[2]) == "string" and type(line[3]) == "number" then
				new[#new+1] = line

				local findUserCat = false
				for cat in string.gmatch(line[2], "[^,]+") do
					if cat == "USER" then
						findUserCat = true
						break
					end
				end
				if not findUserCat then
					line[2] = line[2] .. ",USER"
				end
			end
		end

		return new
	end

	local function SortCategoriesButtons(a,b)
		return (self.CATEGORIES_VIS[a] and self.CATEGORIES_VIS[a].sort or 200) < (self.CATEGORIES_VIS[b] and self.CATEGORIES_VIS[b].sort or 200)
	end

	function self.categories:Update()
		local cats = ExRT.F.table_copy2(module.options.CATEGORIES_DEF)
		local AllSpells = module.options:GetAllSpells(true)
		for _,data in pairs(AllSpells) do
			for cat in string.gmatch(data[2], "[^,]+") do
				if not ExRT.F.table_find(cats,cat) then
					cats[#cats+1] = cat
				end
			end
		end
		for i=#cats,1,-1 do
			if module.options.CATEGORIES_VIS[ cats[i] ] and module.options.CATEGORIES_VIS[ cats[i] ].isHidden then
				tremove(cats,i)
			end
		end
		if ExRT.isClassic then
			for i=#cats,1,-1 do
				local cat = cats[i]
				local catData = module.options.CATEGORIES_VIS[cat]
				local allowed = cat == "ALL" or cat == "ENABLED" or cat == "FAV"
					or (catData and catData.isClassCategory)
				if not allowed then
					tremove(cats,i)
				end
			end
		end
		sort(cats,SortCategoriesButtons)
		for i=1,#cats do
			local button = self.buttons[i]
			if not button then
				button = CreateFrame("Button",nil,self.C)
				self.buttons[i] = button
				if i == 1 then
					button:SetPoint("TOP",0,0)
				else
					button:SetPoint("TOP",self.buttons[i-1],"BOTTOM",0,-2)
				end
				button:SetSize(88,62)

				button.icon = button:CreateTexture(nil, "ARTWORK")
				button.icon:SetPoint("TOP",0,-3)
				button.icon:SetSize(30,30)

				button.text = button:CreateFontString(nil,"ARTWORK","ExRTFontNormal")
				local fontPath = select(1, button.text:GetFont()) or "Fonts\\FRIZQT__.TTF"
							button.text:SetFont(fontPath,11,"")
				button.text:SetPoint("TOP",button.icon,"BOTTOM",0,-3)
				button.text:SetPoint("BOTTOM",0,1)
				button.text:SetPoint("LEFT",2,0)
				button.text:SetPoint("RIGHT",-2,0)
				button.text:SetJustifyH("CENTER")
				button.text:SetJustifyV("TOP")

				button.class = button:CreateTexture(nil, "BACKGROUND")
				button.class:SetPoint("TOP")
				button.class:SetPoint("BOTTOM")
				button.class:SetPoint("LEFT",self,0,0)
				button.class:SetPoint("RIGHT",self,0,0)
				button.class:Hide()

				button.background = button:CreateTexture(nil, "BACKGROUND")
				button.background:SetPoint("TOP")
				button.background:SetPoint("BOTTOM")
				button.background:SetPoint("LEFT",self,0,0)
				button.background:SetPoint("RIGHT",self,0,0)
				button.background:SetColorTexture(1,1,1,.3)
				button.background:Hide()

				button.active = button:CreateTexture(nil, "BACKGROUND")
				button.active:SetPoint("TOP")
				button.active:SetPoint("BOTTOM")
				button.active:SetPoint("LEFT",self,0,0)
				button.active:SetPoint("RIGHT",self,0,0)
				button.active:SetColorTexture(.8,.6,0,1)
				button.active:Hide()

				button:SetScript("OnEnter",CategoriesButtonOnEnter)
				button:SetScript("OnLeave",CategoriesButtonOnLeave)
				button:SetScript("OnClick",CategoriesButtonOnClick)
			end
			local cat = cats[i]
			local catData = module.options.CATEGORIES_VIS[cat]
			button.icon:SetTexture(catData and catData.icon or "Interface\\Icons\\INV_MISC_QUESTIONMARK")
			if catData and catData.iconTcoord then
				button.icon:SetTexCoord(unpack(catData.iconTcoord))
			else
				button.icon:SetTexCoord(0,1,0,1)
			end
			button.text:SetText(catData and catData.name or cat)
			button.active:SetShown(button.isActive)
			button.category = cat
			if cat == "ALL" then
				button.category = nil
			end
			if ExRT.GDB.ClassID[cat] then
				local r,g,b = ExRT.F.classColorNum(cat)
				button.class:SetColorTexture(r,g,b,.3)
				button.class:Show()
			else
				button.class:Hide()
			end
			if not catData then
				module.options.CATEGORIES_VIS[cat] = {sort = CATEGORIES_INDEX_COUNTER,ignoreSubcats = true}
				CATEGORIES_INDEX_COUNTER = CATEGORIES_INDEX_COUNTER + 1
			end
			button:Show()
		end
		for i=#cats+1,#self.buttons do
			self.buttons[i]:Hide()
		end
		self:Height(64 * #cats - 2)
	end


	self.list = ELib:ScrollFrame(self.tab.tabs[1]):Point("TOPLEFT",101,0):Size(749,589)
	ELib:Border(self.list,0)
	self.list.mouseWheelRange = 50

	local SPELL_LINE_HEIGHT = 32

	local function SpellsListLineOnUpdate(self)
		if module.options.list.colBySpecFrame:IsShown() or module.options.list.colByRoleFrame:IsShown() then
			return
		end
		local alpha = 0.4
		if self:IsMouseOver() and not ExRT.lib.ScrollDropDown.IsOpen() then
			alpha = 0.8
		end
		if ExRT.is10 or ExRT.isLK1 then
			self.backClassColor:SetGradient("HORIZONTAL",CreateColor(self.backClassColorR, self.backClassColorG, self.backClassColorB, alpha), CreateColor(self.backClassColorR, self.backClassColorG, self.backClassColorB, 0))
		else
			self.backClassColor:SetGradientAlpha("HORIZONTAL", self.backClassColorR, self.backClassColorG, self.backClassColorB, alpha, self.backClassColorR, self.backClassColorG, self.backClassColorB, 0)
		end

		if self:IsMouseOver() and not self.colExpand:IsShown() and self.colBack:IsShown() and not self.colExpandHide then
			self.colExpand:Show()
		elseif (not self:IsMouseOver() or self.colExpandHide) and self.colExpand:IsShown() then
			self.colExpand:Hide()
		end

		if self:IsMouseOver() and not self.colExpand2:IsShown() and self.colBack:IsShown() then
			self.colExpand2:Show()
		elseif not self:IsMouseOver() and self.colExpand2:IsShown() then
			self.colExpand2:Hide()
		end
	end
	local function SpellsListTooltipFrameOnEnter(self)
		local parent = self:GetParent()
		if not parent.data then
			return
		end
		ELib.Tooltip.Link(self,self.link or "spell:"..parent.data[1])

		local additional = {}
		if parent.data[1] == 161642 then
			additional[#additional+1] = L.cd2ResurrectTooltip
		end
		if module.db.spell_isTalent[ parent.data[1] ] and not parent.isItem then
			additional[#additional+1] = "|cffffffff"..L.cd2AddSpellFrameTalent.."|r"..(ExRT.isClassic and " |cffff8888(*will be shown only after first usage)|r" or "")
		end
		if module.db.spell_dispellsList[ parent.data[1] ] then
			additional[#additional+1] = "|cffffffaa"..L.cd2AddSpellFrameDispel.."|r"
		end
		if module.db.spell_talentReplaceOther[ parent.data[1] ] then
			local spellID = module.db.spell_talentReplaceOther[ parent.data[1] ]
			if type(spellID)=='table' then
				for i=1,#spellID do
					local sname,_,sicon = GetSpellInfo(spellID[i])
					additional[#additional+1] = "|cffffaaaa"..L.cd2AddSpellFrameReplace .." "..(sicon and "|T"..sicon..":20|t" or "").. (sname or "???") .."|r"
				end
			else
				local sname,_,sicon = GetSpellInfo(spellID)
				additional[#additional+1] = "|cffffaaaa"..L.cd2AddSpellFrameReplace .." "..(sicon and "|T"..sicon..":20|t" or "").. (sname or "???") .."|r"
			end
		end
		if module.db.spell_isPetAbility[ parent.data[1] ] then
			additional[#additional+1] = "|cffffffff"..L.BossWatcherBuffsAndDebuffsFilterPets.."|r"
		end

		if #additional > 0 then
			ELib.Tooltip:Add(nil,additional)
		end
	end
	local function SpellsListTooltipFrameOnLeave(self)
		GameTooltip_Hide()
		ELib.Tooltip:HideAdd()
	end
	local function SpellsListLineColExpand(self)
		module.options.list.colBySpecFrame:Open(self:GetParent(),self)
	end
	local function SpellsListLineColExpandRole(self)
		module.options.list.colByRoleFrame:Open(self:GetParent(),self)
	end
	local function SpellsListChkOnClick(self)
		local _sid = self:GetParent().data[1]
		if self.disabled then
			VMRT.ExCD2.CDE[ _sid ] = nil
			if self:GetChecked() then
				self:SetChecked(false)
			end
		elseif self:GetChecked() then
			VMRT.ExCD2.CDE[ _sid ] = true
		else
			VMRT.ExCD2.CDE[ _sid ] = nil
		end
 		self:UpdateColors()

		module:UpdateSpellDB(true)

		module.options.list:Update()
	end
	local function SpellsListChkUpdateColors(self)
		local cR,cG,cB
		if self.disabled then
			cR,cG,cB = .5,.5,.5
		elseif self:GetChecked() then
			cR,cG,cB = .2,.8,.2
		else
			cR,cG,cB = .8,.2,.2
		end
		self.BorderTop:SetColorTexture(cR,cG,cB,1)
		self.BorderLeft:SetColorTexture(cR,cG,cB,1)
		self.BorderBottom:SetColorTexture(cR,cG,cB,1)
		self.BorderRight:SetColorTexture(cR,cG,cB,1)
	end
	local function SpellsListCDTooltipFrameOnEnter(self)
		local data = self:GetParent().data
		if not data then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")

		local className = self:GetParent().data_class
		if module.db.specByClass[className] then
			for i=1,#module.db.specByClass[className] do
				if data[3+i] then
					local icon = ""
					if module.db.specIcons[module.db.specByClass[className][i]] then
						icon = "|T".. module.db.specIcons[module.db.specByClass[className][i]] ..":20|t"
					else
						icon = ExRT.F.classIconInText(className,20) or ""
					end
					GameTooltip:AddLine(icon.." |c"..ExRT.F.classColor(className)..L.specLocalizate[module.db.specInLocalizate[module.db.specByClass[className][i]]].. ":|r|cffffffff "..L.cd2AddSpellFrameCDText.." "..format("%d:%02d",data[i+3][2]/60,data[i+3][2]%60).. (data[i+3][3] > 0 and ", "..L.cd2AddSpellFrameDurationText.." "..data[i+3][3] or ""))
				end
			end
		else
			GameTooltip:AddLine("|cffffffff"..L.cd2AddSpellFrameCDText.." "..data[4][2].. (data[4][3] > 0 and ", "..L.cd2AddSpellFrameDurationText.." "..data[4][3] or ""))
		end

		do
			local cdByTalent_fix = nil
			local readiness_lines = {}
			if module.db.spell_cdByTalent_fix[ data[1] ] then
				cdByTalent_fix = true
				for j=1,#module.db.spell_cdByTalent_fix[ data[1] ],2 do
					local spellID = module.db.spell_cdByTalent_fix[ data[1] ][j]
					local specInfo
					if type(spellID) == "table" then
						specInfo = L.specLocalizate[ module.db.specInLocalizate[ spellID[2] ] ]
						spellID = spellID[1]
					end

					local sname,_,sicon = GetSpellInfo(spellID)
					local cd = module.db.spell_cdByTalent_fix[ data[1] ][j+1]
					local isRank
					if type(cd) == 'table' and ExRT.isLK then
						cd = cd[#cd]
					elseif type(cd) == 'table' then
						isRank = #cd
						cd = cd[#cd]
					end
					if type(cd) == 'table' then
						local tal_sid = cd[2]
						if not tonumber(cd[1]) then
							cd = tonumber(string.sub(cd[1],2))
							if cd < 1 then
								cd = "-"..( (1-cd)*100 ).."%"
							else
								cd = "+"..( (cd-1)*100 ).."%"
							end
						else
							cd = "+"..cd
						end
						local spellname,_,spellicon = GetSpellInfo(tal_sid)
						cd = cd .. " during "..(spellicon and "|T"..spellicon..":20|t" or "")..(spellname or tal_sid)
					elseif not tonumber(cd) then
						cd = tonumber(string.sub(cd,2))
						if cd < 1 then
							cd = "-"..( (1-cd)*100 ).."%"
						else
							cd = "+"..( (cd-1)*100 ).."%"
						end
					end
					table.insert(readiness_lines,"|cffffffff - "..(sicon and "|T"..sicon..":20|t" or "")..(sname or "???") .." (".. (tonumber(cd) and cd > 0 and "+" or "").. cd .. (isRank and " [rank "..isRank.."]" or "") ..")"..(specInfo and " <"..specInfo..">" or "").."|r")

					ELib.Tooltip:Add("spell:"..spellID)
				end
			end
			if cdByTalent_fix then
				GameTooltip:AddLine("|cffffaaaa"..L.cd2AddSpellFrameCDChange..": |r")
				for j=1,#readiness_lines do
					GameTooltip:AddLine(readiness_lines[j])
				end
			end
		end
		if module.db.spell_charge_fix[ data[1] ] then
			if module.db.spell_charge_fix[ data[1] ] == 1 then
				GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameCharge.."|r")
			else
				GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameChargeChange..":|r")
				local sname = GetSpellInfo(module.db.spell_charge_fix[ data[1] ])
				GameTooltip:AddLine("|cffffffff - "..(sname or "???") .."|r")
			end
		end

		if module.db.spell_sharingCD[ data[1] ] then
			GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameSharing..": |r")
			for otherID,otherCD in pairs(module.db.spell_sharingCD[ data[1] ]) do
				local sname = GetSpellInfo(otherID)
				GameTooltip:AddLine("|cffffffff - "..(sname or "???") .." (".. otherCD ..")|r")
			end
		end

		if module.db.spell_reduceCdByHaste[ data[1] ] then
			GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameCDHaste..": |r")
		end

		for castSpellID,castData in pairs(module.db.spell_reduceCdCast) do
			for i=1,#castData,2 do
				local sID = castData[i]
				if type(sID) == 'table' then
					if sID[1] == data[1] then
						local spellname,_,spellicon = GetSpellInfo(castSpellID)
						if not sID[3] and not sID[4] then
							local spellnameT,_,spelliconT = GetSpellInfo(sID[2])
							GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameCasting1.." "..(spellicon and "|T"..spellicon..":20|t" or "")..(spellname or castSpellID).." "..L.cd2AddSpellFrameCasting3.." "..(spelliconT and "|T"..spelliconT..":20|t" or "")..(spellnameT or sID[2]).." "..L.cd2AddSpellFrameCasting2.." "..(type(castData[i+1])=="table" and castData[i+1][#castData[i+1]].." (rank "..#castData[i+1]..")" or castData[i+1]).." |r")
						elseif sID[4] then
							local spellnameT,_,spelliconT = GetSpellInfo(sID[4])
							GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameCasting1.." "..(spellicon and "|T"..spellicon..":20|t" or "")..(spellname or castSpellID).." "..L.cd2AddSpellFrameCasting4.." "..(spelliconT and "|T"..spelliconT..":20|t" or "")..(spellnameT or sID[2]).." "..L.cd2AddSpellFrameCasting2.." "..(type(castData[i+1])=="table" and castData[i+1][#castData[i+1]].." (rank "..#castData[i+1]..")" or castData[i+1]).." |r")
						elseif sID[3] then
							local spellnameT,_,spelliconT = GetSpellInfo(sID[2])
							GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameCasting1.." "..(spellicon and "|T"..spellicon..":20|t" or "")..(spellname or castSpellID).." "..L.cd2AddSpellFrameCasting3.." "..(spelliconT and "|T"..spelliconT..":20|t" or "")..(spellnameT or sID[2]).." "..L.cd2AddSpellFrameCasting5.." "..L.specLocalizate[ module.db.specInLocalizate[ sID[3] ] ].." "..L.cd2AddSpellFrameCasting2.." "..(type(castData[i+1])=="table" and castData[i+1][#castData[i+1]].." (rank "..#castData[i+1]..")" or castData[i+1]).." |r")
						end
					end
				elseif sID == data[1] then
					local spellname,_,spellicon = GetSpellInfo(castSpellID)
					GameTooltip:AddLine("|cffffffaa"..L.cd2AddSpellFrameCasting1.." "..(spellicon and "|T"..spellicon..":20|t" or "")..(spellname or castSpellID).." "..L.cd2AddSpellFrameCasting2.." "..(type(castData[i+1])=="table" and castData[i+1][5].." (soulbind rank 5)" or castData[i+1]).." |r")
				end
			end
		end

		GameTooltip:Show()
	end
	local function SpellsListCDTooltipFrameOnLeave(self)
	  	GameTooltip_Hide()
	  	ELib.Tooltip:HideAdd()
	end
	local function SpellsListDurTooltipFrameOnEnter(self)
		local data = self:GetParent().data
		if not data then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		local something

		if module.db.spell_durationByTalent_fix[ data[1] ] then
			GameTooltip:AddLine("|cffaaffaa"..L.cd2AddSpellFrameDuration..":|r")
			for j=1,#module.db.spell_durationByTalent_fix[data[1]],2 do
				local sname = GetSpellInfo(module.db.spell_durationByTalent_fix[ data[1] ][j]) or "???"
				local cd = module.db.spell_durationByTalent_fix[ data[1] ][j+1]
				local isRank
				if type(cd) == 'table' then
					isRank = #cd
					cd = cd[#cd]
				end
				if type(cd) == 'table' then
					cd = strjoin(",",unpack(cd))
				elseif not tonumber(cd) then
					cd = tonumber(string.sub(cd,2))
					if cd < 1 then
						cd = "-"..( (1-cd)*100 ).."%"
					else
						cd = "+"..( (cd-1)*100 ).."%"
					end
				end
				GameTooltip:AddLine("|cffffffff - "..sname .." (".. (tonumber(cd) and cd > 0 and "+" or "").. cd .. (isRank and " [rank "..isRank.."]" or "") ..")|r")

				ELib.Tooltip:Add("spell:"..module.db.spell_durationByTalent_fix[ data[1] ][j])
			end
			something = true
		end
		do
			for auraID,sID in pairs(module.db.spell_aura_list) do
				if sID == data[1] then
					local sname = GetSpellInfo(auraID) or "???"
					GameTooltip:AddLine("|cffaaffaa"..L.cd2AddSpellFrameDurationLost..":|r")
					GameTooltip:AddLine("|cffffffff - \""..sname.."\"|r")

					something = true
				end
			end
		end

		if something then
			GameTooltip:Show()
		end
	end
	local function SpellsListDurTooltipFrameOnLeave(self)
	  	GameTooltip_Hide()
	  	ELib.Tooltip:HideAdd()
	end
	local function SpellsListColSetValue(self,value)
		if self.zeroToNil and value == 0 then
			self.text:SetText(UNUSED or "-")
		else
			local isEnabled = VMRT.ExCD2.colSet[value] and VMRT.ExCD2.colSet[value].enabled
		  	self.text:SetText(L.cd2AddSpellFrameColumnText.." "..(not isEnabled and "|cffff0000" or "|cffffffff")..value)
		end
		if self.lock then return end
		local toStore = (self.zeroToNil and value == 0) and nil or value
		if type(self.keystr) == "table" then
			for i=1,#self.keystr do
				VMRT.ExCD2.CDECol[ self.keystr[i] ] = toStore
			end
		else
			VMRT.ExCD2.CDECol[self.keystr] = toStore
		end
		module.options.list:Update()
		module:UpdateSpellDB()
	end

	local priorChangeDelay
	local function SpellsListPrioritySetValue(self,value)
	  	self.text:SetText(L.cd2Priority.." |cffffffff"..(100-value).."%")
		if self.lock then return end
		VMRT.ExCD2.Priority[ self:GetParent().data[1] ] = value
		if not priorChangeDelay then
			priorChangeDelay = C_Timer.NewTimer(.5,function()
				priorChangeDelay = nil
				UpdateRoster()
				module:UpdateSpellDB()
			end)
		end
	end

	local function SpellsListButtonModifyOnClick(self)
		if module.options.addModSpellFrame:IsShown() then
			module.options.addModSpellFrame:Hide()
		end
		module.options.addModSpellFrame.data = self:GetParent().data
		module.options.addModSpellFrame:Show()
	end
	local function SpellsListButtonAddOnClick(self)
		if module.options.addModSpellFrame:IsShown() then
			module.options.addModSpellFrame:Hide()
		end
		module.options.addModSpellFrame.data = nil
		module.options.addModSpellFrame.new_class = self.new_class
		module.options.addModSpellFrame:Show()
	end

	local function SpellsListButtonStarButOnClick(self)
		local spellID = self:GetParent().data[1]
		VMRT.ExCD2.OptFav[spellID] = not VMRT.ExCD2.OptFav[spellID]
		self:Update(VMRT.ExCD2.OptFav[spellID] and 2 or 1)
	end
	local function SpellsListButtonStarButUpdate(self,type)
		if type == 1 or not type then
			self.NormalTexture:TexCoord(.5,1,.5,1):Color(.25,.25,.3,1)
			self.HighlightTexture:TexCoord(0,.5,.5,1):Color(.25,.25,.3,1)
			self.PushedTexture:TexCoord(0,.5,.5,1):Color(.5,.5,.3,1)
	  	elseif type == 2 then
			self.NormalTexture:TexCoord(0,.5,0,.5):Color(1,1,1,1)
			self.HighlightTexture:TexCoord(0,.5,0,.5):Color(.5,.5,1,1)
			self.PushedTexture:TexCoord(0,.5,0,.5):Color(.5,.5,1,1)
		end
	end
	local function SpellsListButtonSortByCol()
		module.options.list.sortByCol = true
		module.options.list:UpdateDB(module.options.list.current)
		module.options.list:Update()
	end
	local function SpellsListButtonSortByColOnEnter(self)
		self.text:Color()
	end
	local function SpellsListButtonSortByColOnLeave(self)
		self.text:Color(1,.82,0,1)
	end

	self.list.lines = {}
	for i=1,ceil(589/SPELL_LINE_HEIGHT)+2 do
		local line = CreateFrame("Frame",nil,self.list.C)
		self.list.lines[i] = line
		line:SetPoint("TOPLEFT",0,-(i-1)*SPELL_LINE_HEIGHT)
		line:SetPoint("RIGHT",0,0)
		line:SetHeight(SPELL_LINE_HEIGHT)

		line.chk = ELib:Check(line):Point("LEFT",10,0):OnClick(SpellsListChkOnClick)
		line.chk.UpdateColors = SpellsListChkUpdateColors

		line.chk.CheckedTexture:SetVertexColor(0.2,1,0.2,1)

		line.backClassColor = line:CreateTexture(nil, "BACKGROUND")
		line.backClassColor:SetPoint("LEFT",0,0)
		line.backClassColor:SetSize(350,SPELL_LINE_HEIGHT)
		line.backClassColor:SetColorTexture(1, 1, 1, 1)
		line.backClassColorR = 0
		line.backClassColorG = 0
		line.backClassColorB = 0

		line:SetScript("OnUpdate",SpellsListLineOnUpdate)

		line.icon = line:CreateTexture(nil, "ARTWORK")
		line.icon:SetSize(28,28)
		line.icon:SetPoint("LEFT", line.chk,"RIGHT", 10, 0)
		line.icon:SetTexCoord(.1,.9,.1,.9)
		ELib:Border(line.icon,1,.12,.13,.15,1)

		line.spellName = ELib:Text(line):Size(200,SPELL_LINE_HEIGHT):Point("LEFT",line.icon,"RIGHT",5,0):Font(ExRT.F.defFont,12):Shadow()

		line.tooltipFrame = CreateFrame("Frame",nil,line)
		line.tooltipFrame:SetAllPoints(line.spellName)
		line.tooltipFrame:EnableMouse(true)
		line.tooltipFrame:SetScript("OnEnter", SpellsListTooltipFrameOnEnter)
		line.tooltipFrame:SetScript("OnLeave", SpellsListTooltipFrameOnLeave)

		line.class = line:CreateTexture(nil, "ARTWORK")
		line.class:SetSize(22,22)
		line.class:SetPoint("LEFT", line.spellName, "RIGHT", 5, 0)
		line.class:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

		line.spec = line:CreateTexture(nil, "ARTWORK")
		line.spec:SetSize(22,22)
		line.spec:SetPoint("RIGHT", line.class, "LEFT", -2, 0)

		line.spec1 = line:CreateTexture(nil, "ARTWORK")
		line.spec1:SetSize(16,16)
		line.spec1:SetPoint("TOPRIGHT", line.class, "TOPLEFT", -2, 0)

		line.spec2 = line:CreateTexture(nil, "ARTWORK")
		line.spec2:SetSize(16,16)
		line.spec2:SetPoint("RIGHT", line.spec1, "LEFT", -1, 0)

		line.spec3 = line:CreateTexture(nil, "ARTWORK")
		line.spec3:SetSize(16,16)
		line.spec3:SetPoint("RIGHT", line.spec2, "LEFT", -1, 0)

		line.spec4 = line:CreateTexture(nil, "ARTWORK")
		line.spec4:SetSize(16,16)
		line.spec4:SetPoint("RIGHT", line.spec3, "LEFT", -1, 0)

		line.pet = line:CreateTexture(nil, "OVERLAY")
		line.pet:SetSize(14,14)
		line.pet:SetPoint("BOTTOMRIGHT", line.spec, "BOTTOMLEFT", -1, 0)
		line.pet:Hide()

		line.col = ELib:Slider(line,""):Size(120):Point("LEFT",line.class,"RIGHT",15,-1):Range(1,10):SetTo(11):OnChange(SpellsListColSetValue)
		if line.col and line.col.SetObeyStepOnDrag then line.col:SetObeyStepOnDrag(true) end
		line.col.Low:Hide()
		line.col.High:Hide()
		line.col:SetScript("OnEnter",nil)
		line.col:SetScript("OnLeave",nil)
		line.col:HideBorders()
		line.col.Thumb:SetSize(12,12)
		line.col.Thumb:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256")
		line.col.Thumb:SetVertexColor(0.44,0.45,0.50,1)
		line.col.backline = line.col:CreateTexture(nil,"BACKGROUND")
		line.col.backline:SetColorTexture(0.44,0.45,0.50,0.7)
		line.col.backline:SetPoint("LEFT")
		line.col.backline:SetPoint("RIGHT")
		line.col.backline:SetHeight(4)
		line.col.Text:SetFont(GameFontHighlight:GetFont(),10,"")
		line.col.Text:SetTextColor(0.84,0.85,0.90,1)
		line.col:SetScript("OnMouseWheel",nil)
		line.col.ThumbBySpec = {}
		for j=1,4 do
			local Thumb = line.col:CreateTexture(nil,"ARTWORK",nil,1-j)
			line.col.ThumbBySpec[j] = Thumb
			Thumb:SetSize(14,14)
			Thumb:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
			Thumb:Hide()
		end

		line.colBack = CreateFrame("Frame",nil,line)
		line.colBack:SetHeight(SPELL_LINE_HEIGHT)
		line.colBack:SetPoint("LEFT",line.col)
		line.colBack:SetPoint("RIGHT",line.col)

		-- by spec: left half of the column slider (right edge at slider center)
		line.colExpand = ELib:Button(line,L.cd2BySpec):Size(60,8):Point("TOPLEFT",line.col,"BOTTOMLEFT",0,-1):OnClick(SpellsListLineColExpand)
		if ExRT.is10 or ExRT.isLK1 then
			line.colExpand.Texture:SetGradient("VERTICAL",CreateColor(0.05,0.26,0.09,1), CreateColor(0.20,0.41,0.25,1))
		else
			line.colExpand.Texture:SetGradientAlpha("VERTICAL",0.05,0.26,0.09,1, 0.20,0.41,0.25,1)
		end
		local textObj = line.colExpand:GetTextObj()
		if textObj then
			textObj:SetFont(textObj:GetFont(),8,"")
			textObj:ClearAllPoints()
			textObj:SetPoint("CENTER",line.colExpand,"CENTER",0,0)
			textObj:SetJustifyH("CENTER")
			if textObj.SetJustifyV then textObj:SetJustifyV("MIDDLE") end
		end

		-- by role: right half of the column slider (left edge at slider center)
		line.colExpand2 = ELib:Button(line,L.cd2ByRole):Size(60,8):Point("TOPLEFT",line.col,"BOTTOMLEFT",60,-1):OnClick(SpellsListLineColExpandRole)
		if ExRT.is10 or ExRT.isLK1 then
			line.colExpand2.Texture:SetGradient("VERTICAL",CreateColor(0.26,0.05,0.09,1), CreateColor(0.41,0.20,0.25,1))
		else
			line.colExpand2.Texture:SetGradientAlpha("VERTICAL",0.26,0.05,0.09,1, 0.41,0.20,0.25,1)
		end
		local textObj2 = line.colExpand2:GetTextObj()
		if textObj2 then
			textObj2:SetFont(textObj2:GetFont(),8,"")
			textObj2:ClearAllPoints()
			textObj2:SetPoint("CENTER",line.colExpand2,"CENTER",0,0)
			textObj2:SetJustifyH("CENTER")
			if textObj2.SetJustifyV then textObj2:SetJustifyV("MIDDLE") end
		end


		line.prior = ELib:Slider(line,""):Size(120):Point("LEFT",line.col,"RIGHT",15,0):Range(0,100):SetTo(101):OnChange(SpellsListPrioritySetValue)
		if line.prior and line.prior.SetObeyStepOnDrag then line.prior:SetObeyStepOnDrag(true) end
		line.prior.Low:Hide()
		line.prior.High:Hide()
		line.prior:SetScript("OnEnter",nil)
		line.prior:SetScript("OnLeave",nil)
		line.prior:HideBorders()
		line.prior.Thumb:SetSize(4,12)
		line.prior.Thumb:SetColorTexture(0.44,0.45,0.50,1)
		line.prior.backline = line.prior:CreateTexture(nil,"BACKGROUND")
		line.prior.backline:SetColorTexture(0.44,0.45,0.50,0.7)
		line.prior.backline:SetPoint("LEFT")
		line.prior.backline:SetPoint("RIGHT")
		line.prior.backline:SetHeight(4)
		line.prior.Text:SetFont(GameFontHighlight:GetFont(),10,"")
		line.prior.Text:SetTextColor(0.84,0.85,0.90,1)
		line.prior:SetScript("OnMouseWheel",nil)

		line.cd = ELib:Text(line,""):Size(40,SPELL_LINE_HEIGHT):Point("LEFT",line.prior,"RIGHT",15,1):Font(ExRT.F.defFont,14):Shadow():Center():Color(1,.3,.3)
		line.cdTooltipFrame = CreateFrame("Frame",nil,line)
		line.cdTooltipFrame:SetAllPoints(line.cd)
		line.cdTooltipFrame:EnableMouse(true)
		line.cdTooltipFrame:SetScript("OnEnter", SpellsListCDTooltipFrameOnEnter)
		line.cdTooltipFrame:SetScript("OnLeave", SpellsListCDTooltipFrameOnLeave)

		line.dur = ELib:Text(line,""):Size(40,SPELL_LINE_HEIGHT):Point("LEFT",line.cd,"RIGHT",5,0):Font(ExRT.F.defFont,14):Shadow():Center():Color(.3,1,.3)
		line.durTooltipFrame = CreateFrame("Frame",nil,line)
		line.durTooltipFrame:SetAllPoints(line.dur)
		line.durTooltipFrame:EnableMouse(true)
		line.durTooltipFrame:SetScript("OnEnter", SpellsListDurTooltipFrameOnEnter)
		line.durTooltipFrame:SetScript("OnLeave", SpellsListDurTooltipFrameOnLeave)

		line.buttonModify = ELib:Button(line,">>"):Size(40,20):Point("LEFT",line.dur,"RIGHT",5,0):OnClick(SpellsListButtonModifyOnClick)

		line.buttonAddBig = ELib:Button(line,ADD):Size(0,20):Point("LEFT",10,0):Point("RIGHT",-10,0):OnClick(SpellsListButtonAddOnClick)

		line.starBut = ELib:Button(line,"",1):Size(20,20):Point("LEFT",line.dur,"RIGHT",10,0):OnClick(SpellsListButtonStarButOnClick):Tooltip(L.cd2Favorite)
		line.starBut.Update = SpellsListButtonStarButUpdate
		line.starBut.NormalTexture = ELib:Texture(line.starBut,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\star2"):Point('x')
		line.starBut.HighlightTexture = ELib:Texture(line.starBut,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\star2"):Point('x')
		line.starBut.PushedTexture = ELib:Texture(line.starBut,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\star2"):Point('x')

		line.starBut:SetNormalTexture(line.starBut.NormalTexture)
		line.starBut:SetHighlightTexture(line.starBut.HighlightTexture)
		line.starBut:SetPushedTexture(line.starBut.PushedTexture)

		line.buttonSortByCol = ELib:Button(line,"",1):Size(0,18):Point("LEFT",line.col,0,0):Point("RIGHT",line.col,0,0):OnClick(SpellsListButtonSortByCol):OnEnter(SpellsListButtonSortByColOnEnter):OnLeave(SpellsListButtonSortByColOnLeave)
		line.buttonSortByCol.text = ELib:Text(line.buttonSortByCol,L.cd2SortOpt,10):Point("CENTER",line.buttonSortByCol)
		line.buttonSortByCol.arrow = ELib:Texture(line.buttonSortByCol,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128"):Point("LEFT",line.buttonSortByCol.text,"RIGHT",2,0):Size(14,14):TexCoord(0.25,0.3125,0.5,0.625)

		line:Hide()
	end

	self.list.colBySpecFrame = CreateFrame("Frame",nil,self)
	self.list.colBySpecFrame:SetWidth(155)
	self.list.colBySpecFrame:SetFrameStrata("DIALOG")
	self.list.colBySpecFrame.background = self.list.colBySpecFrame:CreateTexture(nil,"BACKGROUND")
	self.list.colBySpecFrame.background:SetAllPoints()
	self.list.colBySpecFrame.background:SetColorTexture(0,0,0,.8)
	ELib:Border(self.list.colBySpecFrame,2,0.44,0.45,0.50,1)

	self.list.colBySpecFrame.close = ELib:Button(self.list.colBySpecFrame,"x"):Size(155-2,10):Point("BOTTOM",0,0):OnClick(function(self) self:GetParent():Hide() end)

	self.list.colBySpecFrame:Hide()
	self.list.colBySpecFrame.spec = {}
	function self.list.colBySpecFrame:Open(line,clickObj)
		if self:IsShown() and self.data == line.data[1] then
			self:Hide()
			return
		end

		self:ClearAllPoints()
		self:SetPoint("TOPRIGHT",clickObj,"BOTTOMRIGHT",5,-2)

		local class = line.data_class
		local spellID = line.data[1]

		local r,g,b = ExRT.F.classColorNum(class)
		self.background:SetColorTexture(r*0.5,g*0.5,b*0.5,1)

		local specs = line.colExpand.specs
		for i=1,#specs do
			local slider = self.spec[i]
			if not slider then
				slider = ELib:Slider(self,L.cd2AddSpellFrameColumnText.." 1"):Size(120):Point("RIGHT",self,"TOPRIGHT",-5,-3-SPELL_LINE_HEIGHT*(i-1)-SPELL_LINE_HEIGHT/2):Range(1,10):SetTo(1):OnChange(SpellsListColSetValue)
				self.spec[i] = slider
				if slider and slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
				slider.Low:Hide()
				slider.High:Hide()
				slider:SetScript("OnEnter",nil)
				slider:SetScript("OnLeave",nil)
				slider:HideBorders()
				slider.Thumb:SetSize(12,12)
				slider.Thumb:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256")
				slider.Thumb:SetVertexColor(0.44,0.45,0.50,1)
				slider.backline = slider:CreateTexture(nil,"BACKGROUND")
				slider.backline:SetColorTexture(0.44,0.45,0.50,0.7)
				slider.backline:SetPoint("LEFT")
				slider.backline:SetPoint("RIGHT")
				slider.backline:SetHeight(4)
				slider.Text:SetFont(GameFontHighlight:GetFont(),10,"")
				slider.Text:SetTextColor(0.44,0.45,0.50,1)
				slider:SetScript("OnMouseWheel",nil)

				slider.icon = slider:CreateTexture(nil,"ARTWORK")
				slider.icon:SetPoint("RIGHT",slider,"LEFT",-5,0)
				slider.icon:SetSize(20,20)
			end
			slider.icon:SetTexture(ExRT.GDB.ClassSpecializationIcons[ specs[i] ])

			local specPos = line.colExpand.specsPos[i]
			local colStr = line.data[1]..";"..(specPos or 1)
			local col = VMRT.ExCD2.CDECol[colStr] or module.db.def_col[colStr] or line.data[3]
			slider.keystr = colStr
			slider.lock = true
			slider:SetTo(col)
			slider.lock = false

			slider:Show()
		end
		for i=#specs+1,#self.spec do
			self.spec[i]:Hide()
		end
		self:SetHeight(SPELL_LINE_HEIGHT * #specs + 10)

		self.data = line.data[1]

		self:Show()
	end

	self.list.colByRoleFrame = CreateFrame("Frame",nil,self)
	self.list.colByRoleFrame:SetWidth(155)
	self.list.colByRoleFrame:SetFrameStrata("DIALOG")
	self.list.colByRoleFrame.background = self.list.colByRoleFrame:CreateTexture(nil,"BACKGROUND")
	self.list.colByRoleFrame.background:SetAllPoints()
	self.list.colByRoleFrame.background:SetColorTexture(0,0,0,.8)
	ELib:Border(self.list.colByRoleFrame,2,0.44,0.45,0.50,1)

	self.list.colByRoleFrame.close = ELib:Button(self.list.colByRoleFrame,"x"):Size(155-2,10):Point("BOTTOM",0,0):OnClick(function(self) self:GetParent():Hide() end):Tooltip(L.cd2ByRoleTip)

	self.list.colByRoleFrame:Hide()
	self.list.colByRoleFrame.role = {}
	function self.list.colByRoleFrame:Open(line,clickObj)
		if self:IsShown() and self.data == line.data[1] then
			self:Hide()
			return
		end

		self:ClearAllPoints()
		self:SetPoint("TOPRIGHT",clickObj,"BOTTOMRIGHT",5,-2)

		local class = line.data_class
		local spellID = line.data[1]

		local r,g,b = ExRT.F.classColorNum(class)
		self.background:SetColorTexture(r*0.5,g*0.5,b*0.5,1)

		for i=1,3 do
			local slider = self.role[i]
			if not slider then
				slider = ELib:Slider(self,UNUSED):Size(120):Point("RIGHT",self,"TOPRIGHT",-5,-3-SPELL_LINE_HEIGHT*(i-1)-SPELL_LINE_HEIGHT/2):Range(0,10):SetTo(0):OnChange(function(self,...)
					SpellsListColSetValue(self,...)
					local sid = self.keystr and tonumber(self.keystr:match("^(%d+)"))
					if sid then
						local hasRole = (VMRT.ExCD2.CDECol[ sid ..";HEALER"] or VMRT.ExCD2.CDECol[ sid ..";TANK"] or VMRT.ExCD2.CDECol[ sid ..";DAMAGER"]) and true or false
						for j=1,#_C do
							if _C[j].db and _C[j].db[1] == sid then
								_C[j].checkRole = hasRole
							end
						end
					end
				end)
				self.role[i] = slider
				slider.zeroToNil = true
				if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
				slider.Low:Hide()
				slider.High:Hide()
				slider:SetScript("OnEnter",nil)
				slider:SetScript("OnLeave",nil)
				slider:HideBorders()
				slider.Thumb:SetSize(12,12)
				slider.Thumb:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256")
				slider.Thumb:SetVertexColor(0.44,0.45,0.50,1)
				slider.backline = slider:CreateTexture(nil,"BACKGROUND")
				slider.backline:SetColorTexture(0.44,0.45,0.50,0.7)
				slider.backline:SetPoint("LEFT")
				slider.backline:SetPoint("RIGHT")
				slider.backline:SetHeight(4)
				slider.Text:SetFont(GameFontHighlight:GetFont(),10,"")
				slider.Text:SetTextColor(0.44,0.45,0.50,1)
				slider:SetScript("OnMouseWheel",nil)

				slider.icon = slider:CreateTexture(nil,"ARTWORK")
				slider.icon:SetPoint("RIGHT",slider,"LEFT",-5,0)
				slider.icon:SetSize(20,20)
			end
			slider.icon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
			if i == 1 then
				slider.icon:SetTexCoord(20/64,39/64,22/64,41/64)
			elseif i == 2 then
				slider.icon:SetTexCoord(20/64,39/64,1/64,20/64)
			else
				slider.icon:SetTexCoord(0/64,19/64,22/64,41/64)
			end

			local colStr = line.data[1]..";"..(i == 1 and "DAMAGER" or i == 2 and "HEALER" or "TANK")
			local col = VMRT.ExCD2.CDECol[colStr] or 0
			slider.keystr = colStr
			slider.lock = true
			slider:SetTo(col)
			slider.lock = false

			slider:Show()
		end
		self:SetHeight(SPELL_LINE_HEIGHT * 3 + 10)

		self.data = line.data[1]

		self:Show()
	end

	local function SortCategories(cats)
		local new = {}
		for k,v in pairs(cats) do
			new[#new+1] = k
		end
		sort(new,function(a,b) if a and b and self.CATEGORIES_VIS[a] and self.CATEGORIES_VIS[b] then return self.CATEGORIES_VIS[a].sort < self.CATEGORIES_VIS[b].sort end end)
		return new
	end

	function self.list:UpdateDB(categoryNow)
		self.current = categoryNow
		local list,cats = {},{}
		local extraData = {}
		local AllSpells = module.options:GetAllSpells(categoryNow == "PVP")
		for _,data in pairs(AllSpells) do
			if not categoryNow then
				list[#list+1] = data
				for cat in string.gmatch(data[2], "[^,]+") do
					cats[cat] = true
				end
			else
				for cat in string.gmatch(data[2], "[^,]+") do
					if cat == categoryNow then
						list[#list+1] = data
					end
					cats[cat] = true
				end
				if (categoryNow == "ENABLED" and data[1] and GetSpellInfo(data[1]) and VMRT.ExCD2.CDE[ data[1] ]) then
					list[#list+1] = data
				end
				if (categoryNow == "FAV" and data[1] and VMRT.ExCD2.OptFav[ data[1] ]) then
					list[#list+1] = data
				end
			end
		end
		if self.search then
			for i=#list,1,-1 do
				local name = GetSpellInfo(list[i][1])
				if name and not name:lower():find(self.search) then
					tremove(list,i)
				end
			end
		end
		if categoryNow ~= "PVP" then
			cats["PVP"] = nil
		end
		cats = SortCategories(cats)
		if categoryNow and module.options.CATEGORIES_VIS[categoryNow].isClassCategory then
			local class = categoryNow
			local specList = module.db.specByClass[class] or {0}

			local newList = {}
			local specsLen = #specList - 1
			for i=1,#specList do
				local specID = specList[i] or 0
				local icon
				if module.db.specIcons[specID] then
					icon = "|T".. module.db.specIcons[specID] ..":20|t"
				else
					icon = ExRT.F.classIconInText(class,20) or ""
				end
				newList[#newList+1] = {cat = (icon or "").." |c"..ExRT.F.classColor(class)..L.specLocalizate[module.db.specInLocalizate[specID]], specID = specID, specPos = i, sortBut = i==1}
				local count = 0
				for j=1,#list do
					local line = list[j]
					for cat in string.gmatch(line[2], "[^,]+") do
						if
							cat == categoryNow and
							(
								(i == 1 and line[4]) or
								(i == 1 and not line[4] and ((specsLen == 1 and line[5]) or (specsLen == 2 and line[5] and line[6]) or (specsLen == 3 and line[5] and line[6] and line[7]) or (specsLen == 4 and line[5] and line[6] and line[7] and line[8]))) or
								(i > 1 and line[4+i-1])
							)
						then
							newList[#newList+1] = line
							if i > 1 then
								extraData[#newList] = {specID = i, specPos = i}
							end
							count = count + 1
							break
						end
					end
				end
				if count == 0 and i == 1 then
					tremove(newList,#newList)
				end
			end
			if not self.search then
				newList[#newList+1] = {isAddButton = true, class = class}
			end
			list = newList
		elseif categoryNow and not module.options.CATEGORIES_VIS[categoryNow].ignoreSubcats then
			local newList = {}
			for i=1,#cats do
				if not module.options.CATEGORIES_VIS[categoryNow].ignoreOwncat or cats[i] ~= categoryNow then
					newList[#newList+1] = {cat = module.options.CATEGORIES_VIS[ cats[i] ] and module.options.CATEGORIES_VIS[ cats[i] ].name or cats[i]}
					local count = 0
					for j=1,#list do
						for cat in string.gmatch(list[j][2], "[^,]+") do
							if cat == cats[i] then
								newList[#newList+1] = list[j]
								count = count + 1
								break
							end
						end
					end
					if count == 0 then
						tremove(newList,#newList)
					end
				end
			end
			list = newList
		elseif categoryNow and module.options.CATEGORIES_VIS[categoryNow].ignoreSubcats then
			tinsert(list,1,{cat = module.options.CATEGORIES_VIS[categoryNow] and module.options.CATEGORIES_VIS[categoryNow].name or categoryNow,sortBut = true})
		elseif not categoryNow then
			local newList = {}
			for i=1,#cats do
				local catData = module.options.CATEGORIES_VIS[ cats[i] ]
				local catName = catData and catData.name or cats[i]
				if catData and catData.isClassCategory then
					local catIcon = ExRT.F.classIconInText(cats[i],20)
					if catIcon then
						catName = catIcon.." "..catName
					end
				end
				newList[#newList+1] = {cat = catName}
				local count = 0
				for j=1,#list do
					for cat in string.gmatch(list[j][2], "[^,]+") do
						if cat == cats[i] then
							newList[#newList+1] = list[j]
							count = count + 1
							break
						end
					end

				end
				if count == 0 then
					tremove(newList,#newList)
				end
			end
			if not self.search then
				newList[#newList+1] = {isAddButton = true}
			end
			list = newList
		end
		self.list = list
		self.extraData = extraData
		if self.sortByCol then
			self.sortByCol = nil
			local p = 0
			local colData = {}
			for i=1,#list do
				local data = list[i]
				if data[1] then
					local col = VMRT.ExCD2.CDECol[data[1]..";1"] or module.db.def_col[data[1]..";1"] or data[3]
					if extraData[i] and extraData[i].specPos then
						col = VMRT.ExCD2.CDECol[data[1]..";"..(extraData[i].specPos)] or col
					elseif not data[4] then
						for j=5,8 do
							if data[j] then
								local newcol = VMRT.ExCD2.CDECol[data[1]..";"..(j-3)]
								if newcol then
									col = newcol
									break
								end
							end
						end
					end
					colData[i] = {p + col,i}
				else
					p = p + 20
					colData[i] = {p,i}
				end
			end
			sort(colData,function(a,b) return a[1]<b[1] end)
			local newList = {}
			local newExtra = {}
			for i=1,#colData do
				newList[i] = list[ colData[i][2] ]
				newExtra[i] = extraData[ colData[i][2] ]
			end
			self.list = newList
			self.extraData = extraData
		elseif categoryNow == "ITEMS" and #list > 0 then
			local header = list[1]
			tremove(list, 1)
			local listLen = #list
			for i=1,#list/2 do
				list[i], list[listLen-i+1] = list[listLen-i+1], list[i]
				extraData[i], extraData[listLen-i+1] = extraData[listLen-i+1], extraData[i]
			end
			tinsert(list, 1, header)
		end
	end
	function self.list:Update()
		local scroll = self.ScrollBar:GetValue()
		self:SetVerticalScroll(scroll % SPELL_LINE_HEIGHT)
		local start = floor(scroll / SPELL_LINE_HEIGHT) + 1

		local list = self.list
		local lineCount = 1
		for i=start,#list do
			local data = list[i]
			local extraData = self.extraData[i]
			local line = self.lines[lineCount]
			lineCount = lineCount + 1
			if not line then
				break
			end
			local isHideMost = false

			line.spec:Hide()
			line.spec1:Hide()
			line.spec2:Hide()
			line.spec3:Hide()
			line.starBut:Hide()
			line.buttonSortByCol:Hide()

			if data.cat then
				line.spellName:SetText(data.cat)

				line.class:Hide()
				line.colBack:Hide()
				line.buttonModify:Hide()

				line.data = nil

				line.buttonAddBig:Hide()

				if data.sortBut then
					line.buttonSortByCol:Show()
				end

				isHideMost = true
			elseif data.isAddButton then
				line.spellName:SetText("")

				line.class:Hide()
				line.colBack:Hide()
				line.buttonModify:Hide()

				line.data = nil

				if data.class then
					line.buttonAddBig.new_class = data.class
				else
					line.buttonAddBig.new_class = nil
				end
				line.buttonAddBig:Show()

				isHideMost = true
			else
				local spellID = tonumber(data[1]) or data[1]
						local spellName,_,spellTexture = GetSpellInfo(spellID)
						if not spellName and self.WarmUpSpell then
							self:WarmUpSpell(spellID)
							spellName,_,spellTexture = GetSpellInfo(spellID)
						end
							if not spellTexture and ExRT.F.GetSpellTextureSafe then
							spellTexture = ExRT.F.GetSpellTextureSafe(spellID)
						end
				line.icon:SetTexture(spellTexture or "Interface\\Icons\\INV_MISC_QUESTIONMARK")
				line.spellName:SetText(spellName or "Removed spell #"..spellID)

				line.tooltipFrame.link = nil
				line.isItem = nil
				if strsplit(",",data[2]) == "ITEMS" then
					for itemID,itemSpellID in pairs(module.db.itemsToSpells) do
						if itemSpellID == spellID then
							local itemName,_,itemQuality = GetItemInfo(itemID)
							if itemName then
								line.spellName:SetText((itemQuality and ITEM_QUALITY_COLORS[itemQuality] and ITEM_QUALITY_COLORS[itemQuality].hex or "")..itemName)
							end
							local itemTexture = select(5,GetItemInfoInstant(itemID))
							line.icon:SetTexture(itemTexture)
							line.tooltipFrame.link = "item:"..itemID
							break
						end
					end
					line.isItem = true
				end

				local class,specPos = nil
				local dataSpecs = 0
				for cat in string.gmatch(data[2], "[^,]+") do
					if ExRT.GDB.ClassID[cat] then
						class = cat
						break
					end
				end
				local cR,cG,cB = ExRT.F.classColorNum(class)

				line.backClassColorR = cR
				line.backClassColorG = cG
				line.backClassColorB = cB

				if class then
					local _cp,_cl,_cr,_ct,_cb = ExRT.F.classIconRaw(class)
					if _cp then
						line.class:SetTexture(_cp)
						line.class:SetTexCoord(_cl,_cr,_ct,_cb)
					end
					line.class:Show()


					local specs = ExRT.GDB.ClassSpecializationList[class]
					local specID = nil
					for j=4,4+#specs do
						if data[j] then
							dataSpecs = dataSpecs + 1
							specID = specs[j-4]
						end
					end
					if data[4] and ExRT.isLK then
						dataSpecs = #specs
					end
					line.colExpand.specs = {}
					line.colExpand.specsPos = {}
					local specIcon = 1
					for j=5,4+#specs do
						if data[j] or data[4] then
							line.colExpand.specs[#line.colExpand.specs+1] = specs[j-4]
							line.colExpand.specsPos[#line.colExpand.specsPos+1] = j - 3

							if data[j] then
								local icon = line["spec"..specIcon]
								if icon then
									icon:SetTexture(ExRT.GDB.ClassSpecializationIcons[ specs[j-4] ])
									icon:Show()
									specIcon = specIcon + 1
								end
							end
						end
					end
					if dataSpecs > 1 then
						line.colBack:Show()
						line.colExpandHide = nil
					else
						-- single-spec (talent) cooldown: keep hover zone so "by role" still shows (like retail), but hide "by spec"
						line.colBack:Show()
						line.colExpandHide = true
						if specID then
							line.spec:SetTexture(ExRT.GDB.ClassSpecializationIcons[specID])
							line.spec:Show()
							line.spec1:Hide()
						else
							line.spec:Hide()
						end
					end
					for j=4,4+#specs do
						if data[j] then
							specPos = j - 3
							break
						end
					end
				else
					line.class:Hide()
					line.colBack:Hide()
				end
				line.data_class = class

				line.pet:Hide()
				if module.db.spell_isPetAbility[ data[1] ] then
					line.pet:SetTexture("Interface\\Icons\\Ability_Hunter_BeastTraining")
					line.pet:Show()
				end

				for j=1,4 do
					line.col.ThumbBySpec[j]:Hide()
				end
				local colDefStr = data[1]..";"..(specPos or 1)
				local col = VMRT.ExCD2.CDECol[colDefStr] or module.db.def_col[colDefStr] or data[3]
				if extraData and extraData.specPos then
					local specPos = extraData.specPos
					col = VMRT.ExCD2.CDECol[data[1]..";"..specPos] or col or data[3]
				end
				local defCol = col
				local universalKey = data[1]..";1"
				line.col.keystr = colDefStr
				if dataSpecs > 1 then
					line.col.keystr = {}
					local updateCol = data[4]
					if updateCol then
						line.col.keystr[#line.col.keystr+1] = colDefStr
					else
						line.col.keystr[#line.col.keystr+1] = universalKey
					end
					local miniIcon = {}
					for j=5,8 do
						if data[j] or (data[4] and ExRT.GDB.ClassSpecializationList[class][j-4]) then
							local str = data[1]..";"..(j-3)
							line.col.keystr[#line.col.keystr+1] = str
							if not updateCol and VMRT.ExCD2.CDECol[str] then
								updateCol = true
								col = VMRT.ExCD2.CDECol[str]
							end
							local specs = ExRT.GDB.ClassSpecializationList[class]
							if specs then
								local p = VMRT.ExCD2.CDECol[str] or VMRT.ExCD2.CDECol[universalKey] or module.db.def_col[str] or module.db.def_col[universalKey] or data[3]
								if p ~= defCol then
									local t = line.col.ThumbBySpec[j-4]
									t:SetPoint("CENTER",line.col,"LEFT",7 + (line.col:GetWidth() - 14) / 9 * (p-1),miniIcon[p] == 1 and -5 or miniIcon[p] == 2 and 5 or 0)
									t:SetTexture(ExRT.GDB.ClassSpecializationIcons[ specs[j-4] ])
									t:Show()
									miniIcon[p] = (miniIcon[p] or 0) + 1
								end
							end
						end
					end
				elseif specPos and specPos ~= 1 then
					line.col.keystr = {colDefStr, universalKey}
				end
				if extraData and extraData.specPos then
					local specPos = extraData.specPos
					col = VMRT.ExCD2.CDECol[data[1]..";"..specPos] or col or data[3]
					line.col.keystr = data[1]..";"..specPos
				end
				line.col.lock = true
				line.col:SetTo(col)
				line.col.lock = false


				line.prior.lock = true
				line.prior:SetTo(VMRT.ExCD2.Priority[ data[1] ] or 50)
				line.prior.lock = false

				local first = nil
				for j=4,4+4 do
					if data[j] then
						first = data[j]
						break
					end
				end
				if first then
					line.cd:SetFormattedText("%d:%02d",first[2]/60,first[2]%60)
					if first[3] > 0 then
						line.dur:SetFormattedText("%d:%02d",first[3]/60,first[3]%60)
					else
						line.dur:SetText("")
					end
				else
					line.cd:SetFormattedText("")
					line.dur:SetText("")
				end

				local findUserCat = false
				for cat in string.gmatch(data[2], "[^,]+") do
					if cat == "USER" then
						findUserCat = true
						break
					end
				end
				line.buttonModify:SetShown(findUserCat)

				line.buttonAddBig:Hide()

				if spellName then
					line.chk.disabled = false
				else
					line.chk.disabled = true
				end
				line.chk:SetChecked(VMRT.ExCD2.CDE[ data[1] ] or false)
				line.chk:UpdateColors()

				if spellName and VMRT.ExCD2.OptFav[ data[1] ] then
					line.starBut:Update(2)
				else
					line.starBut:Update(1)
				end
				line.starBut:SetShown(not findUserCat)

				line.data = data
			end
			line.icon:SetShown(not isHideMost)
			line.icon.border_top:SetShown(not isHideMost)
			line.icon.border_bottom:SetShown(not isHideMost)
			line.icon.border_left:SetShown(not isHideMost)
			line.icon.border_right:SetShown(not isHideMost)
			line.backClassColor:SetShown(not isHideMost)
			line.chk:SetShown(not isHideMost)
			line.col:SetShown(not isHideMost)
			line.prior:SetShown(not isHideMost)
			line.cd:SetShown(not isHideMost)
			line.dur:SetShown(not isHideMost)
			line.tooltipFrame:SetShown(not isHideMost)

			line:Show()
		end
		for i=lineCount,#self.lines do
			self.lines[i]:Hide()
		end
		self:Height(SPELL_LINE_HEIGHT * #list)
	end
	self.list.ScrollBar.slider:SetScript("OnValueChanged", function(self)
		self:GetParent():GetParent():Update()
		self:UpdateButtons()
	end)


	self.searchEditBox = ELib:Edit(self.tab.tabs[1]):Point("TOPLEFT",400,18):Size(140,16):AddSearchIcon():OnChange(function (self,isUser)
		if not isUser then
			return
		end
		local text = self:GetText():lower()
		if text == "" then
			text = nil
		end
		module.options.list.search = text

		if self.scheduledUpdate then
			return
		end
		self.scheduledUpdate = C_Timer.NewTimer(.3,function()
			self.scheduledUpdate = nil
			module.options.list:UpdateDB(module.options.list.current)
			module.options.list:Update()
		end)
	end):Tooltip(SEARCH)
	self.searchEditBox:SetTextColor(0,1,0,1)


	self.addModSpellFrame = ELib:Popup():Size(570,250)

	self.addModSpellFrame.Save = ELib:Button(self.addModSpellFrame,L.BossmodsKromogSetupsSave):Size(558,20):Point("BOTTOM",0,1):OnClick(function(self)
		local parent = self:GetParent()
		local data = parent.data
		if not data then
			return
		end
		for i=4,8 do
			if data[i] and data[i][1] == 0 then
				data[i] = nil
			end
		end
		if data[1] == 0 then
			return
		end
		if data[2] and strsplit(",",data[2]) == "ITEMS" and not data.itemID then
			return
		end
		if data[4] or data[5] or data[6] or data[7] or data[8] then
			local isNew = true
			local AllSpells = module.options:GetAllSpells(true)
			for _,line in pairs(AllSpells) do
				if line == data then
					isNew = false
					break
				end
			end
			if isNew then
				VMRT.ExCD2.userDB[#VMRT.ExCD2.userDB+1] = data
			end
			module.options.list:UpdateDB(module.options.list.current)
			module.options.list:Update()

			module:UpdateSpellDB(true)
		end

		parent:Hide()
	end)
	function self.addModSpellFrame.Save:Check()
		local parent = self:GetParent()
		local data = parent.data
		local spellID = data[1]
		if not GetSpellInfo(spellID) then
			self:Disable()
			parent.spellIDIcon:ColorBorder(true)
			return
		end
		if data[2] and strsplit(",",data[2]) == "ITEMS" and not data.itemID then
			self:Disable()
			parent.itemToSpell:ColorBorder(true)
			return
		end
		local AllSpells = module.options:GetAllSpells(true)
		for _,line in pairs(AllSpells) do
			if line[1] == spellID and line ~= parent.data then
				self:Disable()
				parent.spellIDIcon:ColorBorder(true)
				return
			end
		end
		parent.spellIDIcon:ColorBorder()
		parent.itemToSpell:ColorBorder()
		self:Enable()
	end
	self.addModSpellFrame:SetScript("OnHide",function(self)

	end)

	self.addModSpellFrame.spellIDIcon = ELib:Edit(self.addModSpellFrame):Size(100,20):Point("TOPLEFT",150,-50):LeftText("Spell ID (for icon):"):OnChange(function(self,isUser)
		local text = self:GetText() or ""
		if not tonumber(text) then
			text = "0"
		end
		local spellID = tonumber(text)
		local parent = self:GetParent()
		parent.data[1] = spellID
		parent.Save:Check()

		local spellName,_,spellIcon = GetSpellInfo(spellID)
		self.RightText:SetText((spellIcon and "|T"..spellIcon..":20|t " or "")..(spellName or ""))
	end)
	self.addModSpellFrame.spellIDIcon.leftText:Color():Shadow()
	self.addModSpellFrame.spellIDIcon.RightText = ELib:Text(self.addModSpellFrame.spellIDIcon,"",12):Point("LEFT",self.addModSpellFrame.spellIDIcon,"RIGHT",5,0):Color():Shadow()

	local function addModSpellFrameEditCLEU(self)
		local text = self:GetText() or ""
		self.data[1] = tonumber(text) or 0
	end
	local function addModSpellFrameEditCD(self)
		local text = self:GetText() or ""
		self.data[2] = tonumber(text) or 0
	end
	local function addModSpellFrameEditDur(self)
		local text = self:GetText() or ""
		self.data[3] = tonumber(text) or 0
	end

	for i=1,5 do
		self.addModSpellFrame["spellIDCLEU"..i] = ELib:Edit(self.addModSpellFrame):Size(180,20):Point("TOPLEFT",150,-100-(i-1)*25):OnChange(addModSpellFrameEditCLEU):Tooltip("Leave empty for ignoring"):LeftText("")
		self.addModSpellFrame["spellIDCLEU"..i].leftText:Color():Shadow()

		self.addModSpellFrame["cd"..i] = ELib:Edit(self.addModSpellFrame):Size(100,20):Point("LEFT",self.addModSpellFrame["spellIDCLEU"..i],"RIGHT",10,0):OnChange(addModSpellFrameEditCD)

		self.addModSpellFrame["dur"..i] = ELib:Edit(self.addModSpellFrame):Size(100,20):Point("LEFT",self.addModSpellFrame["cd"..i],"RIGHT",10,0):OnChange(addModSpellFrameEditDur)
	end
	self.addModSpellFrame.spellIDCLEUtext = ELib:Text(self.addModSpellFrame,"Spell ID (for combat log event)",12):Point("BOTTOM",self.addModSpellFrame.spellIDCLEU1,"TOP",0,2):Color():Shadow()
	self.addModSpellFrame.cdtext = ELib:Text(self.addModSpellFrame,L.cd2EditBoxCDTooltip,12):Point("BOTTOM",self.addModSpellFrame.cd1,"TOP",0,2):Color():Shadow()
	self.addModSpellFrame.durtext = ELib:Text(self.addModSpellFrame,L.cd2EditBoxDurationTooltip,12):Point("BOTTOM",self.addModSpellFrame.dur1,"TOP",0,2):Color():Shadow()

	self.addModSpellFrame.dropDown = ELib:DropDown(self.addModSpellFrame,200,10):Size(210):Point("TOPLEFT",150,-25)
	self.addModSpellFrame.dropDown.LeftText = ELib:Text(self.addModSpellFrame.dropDown,L.cd2Class..":",12):Point("RIGHT",self.addModSpellFrame.dropDown,"LEFT",-5,0):Color():Shadow()

	function self.addModSpellFrame.dropDown:SetValue(newValue)
		ELib:DropDownClose()

		module.options.addModSpellFrame.data[2] = newValue .. ",USER"

		module.options.addModSpellFrame:Update()
	end

	for i=1,#module.db.classNames do
		local class = module.db.classNames[i]
		self.addModSpellFrame.dropDown.List[#self.addModSpellFrame.dropDown.List + 1] = {
			text = "|c"..ExRT.F.classColor(class)..L.classLocalizate[class],
			justifyH = "CENTER",
			func = self.addModSpellFrame.dropDown.SetValue,
			arg1 = class,
		}
	end
	if ExRT.isClassic then
		tremove(self.addModSpellFrame.dropDown.List, 12)
		tremove(self.addModSpellFrame.dropDown.List, 10)
		if not ExRT.isLK then tremove(self.addModSpellFrame.dropDown.List, 6) end
	end

	self.addModSpellFrame.dropDown.List[#self.addModSpellFrame.dropDown.List + 1] = {
		text = L.cd2CatItems,
		justifyH = "CENTER",
		func = self.addModSpellFrame.dropDown.SetValue,
		arg1 = "ITEMS",
	}
	self.addModSpellFrame.dropDown.List[#self.addModSpellFrame.dropDown.List + 1] = {
		text = ALL,
		justifyH = "CENTER",
		func = self.addModSpellFrame.dropDown.SetValue,
		arg1 = "OTHER",
	}
	self.addModSpellFrame.dropDown.Lines = #self.addModSpellFrame.dropDown.List


	self.addModSpellFrame.Delete = ELib:Button(self.addModSpellFrame,DELETE):Size(100,20):Point("LEFT",self.addModSpellFrame.dropDown,"RIGHT",50,0):OnClick(function(self)
		local parent = self:GetParent()
		local data = parent.data
		for i=1,#VMRT.ExCD2.userDB do
			if data == VMRT.ExCD2.userDB[i] then
				tremove(VMRT.ExCD2.userDB, i)
				break
			end
		end
		parent.data = nil

		module.options.list:UpdateDB(module.options.list.current)
		module.options.list:Update()

		module:UpdateSpellDB(true)

		parent:Hide()
	end)

	self.addModSpellFrame.isEquip = ELib:Check(self.addModSpellFrame,"|cffffffffIs Equipment:"):Left():Point("LEFT",self.addModSpellFrame["spellIDCLEU3"],"LEFT",0,0):OnClick(function(self)
		local parent = self:GetParent()
		local data = parent.data

		if self:GetChecked() then
			data.isEquip = true
		else
			data.isEquip = nil
		end
	end)

	self.addModSpellFrame.itemToSpell = ELib:Edit(self.addModSpellFrame,nil,true):Size(180,20):Point("LEFT",self.addModSpellFrame["spellIDCLEU4"],"LEFT",0,0):OnChange(function(self,isUser)
		local parent = self:GetParent()
		local data = parent.data

		self.RightText:SetText("")
		local itemID = tonumber(self:GetText() or "")

		data.itemID = itemID
		parent.Save:Check()

		if itemID then
			local itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemID)
			local _, spellID = GetItemSpell(itemID)
			if itemName then
				if spellID then
					self.RightText:SetText("SpellID: "..spellID.." (for item "..(itemIcon and "|T"..itemIcon..":20|t" or "")..itemName..")")
					return
				end
				self.RightText:SetText("No spell found for item "..(itemIcon and "|T"..itemIcon..":20|t" or "")..itemName)
				return
			end
			self.RightText:SetText("No item found")
		end
	end):LeftText("Item ID:"):Run(function(self)
		self.leftText:Color()
		self.RightText = ELib:Text(self,"",12):Point("TOPLEFT",self,"BOTTOMLEFT",3,-3):Color():Shadow()
	end)


	self.addModSpellFrame.Update = function(self)
		local data = self.data
		self.spellIDIcon:SetText(data[1])

		local class = "OTHER"
		for i=1,#self.dropDown.List do
			if strsplit(",",data[2]) == self.dropDown.List[i].arg1 then
				self.dropDown:SetText(self.dropDown.List[i].text)
				class = self.dropDown.List[i].arg1
				break
			end
		end

		local specList = {0}
		for i=1,#specList do
			local specID = specList[i]
			local icon
			if module.db.specIcons[specID] then
				icon = "|T".. module.db.specIcons[specID] ..":20|t"
			else
				icon = ExRT.F.classIconInText(class,20) or ""
			end

			self["spellIDCLEU"..i]:LeftText((icon or "").." |c"..ExRT.F.classColor(class)..L.specLocalizate[module.db.specInLocalizate[specID]])

			local dataSpec = data[3+i] or {0,0,0}
			data[3+i] = dataSpec
			self["spellIDCLEU"..i]:SetText(dataSpec[1])
			self["cd"..i]:SetText(dataSpec[2])
			self["dur"..i]:SetText(dataSpec[3])

			self["spellIDCLEU"..i].data = dataSpec
			self["cd"..i].data = dataSpec
			self["dur"..i].data = dataSpec

			self["spellIDCLEU"..i]:Show()
			self["cd"..i]:Show()
			self["dur"..i]:Show()
		end
		for i=#specList+1,5 do
			self["spellIDCLEU"..i]:Hide()
			self["cd"..i]:Hide()
			self["dur"..i]:Hide()
		end

		self.itemToSpell:SetText(data.itemID or "")
		self.isEquip:SetChecked(data.isEquip)
		self.itemToSpell:SetShown(class == "ITEMS")
		self.isEquip:SetShown(class == "ITEMS")

		local isNew = true
		local AllSpells = module.options:GetAllSpells(true)
		for _,line in pairs(AllSpells) do
			if line == data then
				isNew = false
				break
			end
		end
		self.Delete:SetShown(not isNew)
	end

	self.addModSpellFrame.OnShow = function(self)
		local data = self.data
		if not data then
			data = {0,"OTHER,USER",1,{0,0,0}}
			if self.new_class then
				data[2] = self.new_class..",USER"
				self.new_class = nil
			end
			self.data = data
		end
		self:Update()
	end


	function self:ClickPlayerClassCategoryOrFirst()
		local _, playerClass = UnitClass and UnitClass("player")
		if playerClass and self.categories and self.categories.buttons then
			for i=1,#self.categories.buttons do
				local b = self.categories.buttons[i]
				if b and b:IsShown() and b.category == playerClass then
					b:Click()
					return
				end
			end
		end
		if self.categories and self.categories.buttons and self.categories.buttons[1] then
			self.categories.buttons[1]:Click()
		end
	end

	self.categories:Update()
	self:ClickPlayerClassCategoryOrFirst()


	self.optColHeader = ELib:Text(self.tab.tabs[2],L.cd2ColSet):Size(560,20):Point(15+80,-8)

	local currColOpt = {}

	function self:selectColumnTab()
		local i = self and self.colID or module.options.optColTabs.selected
		module.options.optColTabs.selected = i
		module.options.optColTabs:UpdateTabs()

		local isGeneralTab = i == (module.db.maxColumns + 1)

		local optColSet = module.options.optColSet
		local defOpt = module.db.colsDefaults
		local VColOpt = VMRT.ExCD2.colSet[i]

		optColSet.superTabFrame:Show()

		optColSet.LOCK = true
		currColOpt = {}

		if isGeneralTab then


			VColOpt.frameGeneral = nil
			VColOpt.iconGeneral = nil
			VColOpt.textureGeneral = nil
			VColOpt.fontGeneral = nil
			VColOpt.textGeneral = nil
			VColOpt.methodsGeneral = nil
			VColOpt.visibilityGeneral = nil
			VColOpt.blacklistGeneral = nil
		end
		optColSet.superTabFrame.list.LDisabled[10] = isGeneralTab
		optColSet.superTabFrame.list:Update()

		optColSet.chkEnable:SetChecked(VColOpt.enabled)
		optColSet.chkGeneral:SetChecked(VColOpt.frameGeneral)

		local genColOpt = VMRT.ExCD2.colSet[module.db.maxColumns + 1]
		local function _effOpt(flag)
			if not isGeneralTab and VColOpt[flag] and genColOpt then
				return genColOpt
			end
			return VColOpt
		end
		local frameOpt = _effOpt("frameGeneral")
		local iconOpt = _effOpt("iconGeneral")
		local textureOpt = _effOpt("textureGeneral")
		local fontOpt = _effOpt("fontGeneral")
		local textOpt = _effOpt("textGeneral")
		optColSet.sliderLinesNum:SetValue(frameOpt.frameLines or defOpt.frameLines)
		optColSet.sliderAlpha:SetValue(frameOpt.frameAlpha or defOpt.frameAlpha)
		optColSet.sliderScale:SetValue(frameOpt.frameScale or defOpt.frameScale)
		optColSet.sliderWidth:SetValue(frameOpt.frameWidth or defOpt.frameWidth)
		optColSet.sliderColsInCol:SetValue(frameOpt.frameColumns or defOpt.frameColumns)
		optColSet.sliderBetweenLines:SetValue(frameOpt.frameBetweenLines or defOpt.frameBetweenLines)
		optColSet.sliderBlackBack:SetValue(frameOpt.frameBlackBack or defOpt.frameBlackBack)
		optColSet.dropDownStrata:SetText(frameOpt.frameStrata or defOpt.frameStrata)
		if VColOpt.ATF and not VColOpt.frameStrata then
			optColSet.dropDownStrata:SetText("Auto")
		end

		optColSet.chkGeneral:doAlphas()

		optColSet.sliderHeight:SetValue(iconOpt.iconSize or defOpt.iconSize)
		optColSet.sliderIconRealHeight:SetValue(iconOpt.iconHeight or iconOpt.iconSize or defOpt.iconHeight or defOpt.iconSize)
		optColSet.chkSeparateIconHW:SetChecked(iconOpt.iconSeparateHW)
		optColSet.chkGray:SetChecked(iconOpt.iconGray)
		optColSet.chkCooldown:SetChecked(iconOpt.methodsCooldown)
		optColSet:applyIconHWLayout()
		optColSet:chkCooldownTextUpdate()
		optColSet.chkCooldownShowSwipe:SetChecked(iconOpt.iconCooldownShowSwipe)
		optColSet.chkShowTitles:SetChecked(iconOpt.iconTitles)
		optColSet.chkHideBlizzardEdges:SetChecked(iconOpt.iconHideBlizzardEdges)
		optColSet.chkMasque:SetChecked(iconOpt.iconMasque)
		optColSet.chkGeneralIcons:SetChecked(VColOpt.iconGeneral)
		do
			local defIconPos = iconOpt.iconPosition or defOpt.iconPosition
			optColSet.dropDownIconPos:SetText( optColSet.dropDownIconPos.PosNames[defIconPos])
		end
		if optColSet.dropDownCooldownGlowType.List[ iconOpt.iconGlowType or 1 ] then
			optColSet.dropDownCooldownGlowType:SetText(optColSet.dropDownCooldownGlowType.List[ iconOpt.iconGlowType or 1 ].text)
		end
		optColSet.colorPickerGlow.color:SetColorTexture(iconOpt.iconGlowColorR or defOpt.iconGlowColorR, iconOpt.iconGlowColorG or defOpt.iconGlowColorG, iconOpt.iconGlowColorB or defOpt.iconGlowColorB, iconOpt.iconGlowColorA or defOpt.iconGlowColorA)
		if optColSet.updateGlowColorEnabled then
			optColSet.updateGlowColorEnabled()
		end

		optColSet.chkGeneralIcons:doAlphas()

		do
			local target = textureOpt.textureFile or ExRT.F.barImg
			local texturePos = nil
			local mediaList = ExRT.F.GetSharedMediaList("statusbar", ExRT.F.textureList)
			for j = 1, #mediaList do
				if mediaList[j].path == target then
					texturePos = mediaList[j].name
					break
				end
			end
			if not texturePos and textureOpt.textureFile then
				texturePos = select(3,string.find(textureOpt.textureFile,"\\([^\\]*)$"))
			end
			texturePos = texturePos or "Standart"
			optColSet.dropDownTexture:SetText(L.cd2OtherSetTexture.." ["..texturePos.."]")
		end
		optColSet.colorPickerBorder.color:SetColorTexture(textureOpt.textureBorderColorR or defOpt.textureBorderColorR,textureOpt.textureBorderColorG or defOpt.textureBorderColorG,textureOpt.textureBorderColorB or defOpt.textureBorderColorB, textureOpt.textureBorderColorA or defOpt.textureBorderColorA)
		optColSet.sliderBorderSize:SetValue(textureOpt.textureBorderSize or defOpt.textureBorderSize)
		optColSet.chkAnimation:SetChecked(textureOpt.textureAnimation)
		optColSet.chkHideSpark:SetChecked(textureOpt.textureHideSpark)
		optColSet.chkSmoothAnimation:SetChecked(textureOpt.textureSmoothAnimation)
		optColSet.sliderSmoothAnimationDuration:SetValue(textureOpt.textureSmoothAnimationDuration or defOpt.textureSmoothAnimationDuration)
		optColSet.chkGeneralColorize:SetChecked(VColOpt.textureGeneral)

		optColSet.chkGeneralColorize:doAlphas()

		do
			local FontNameForDropDown = select(3,string.find(fontOpt.fontName or defOpt.fontName,"\\([^\\]*)$"))
			optColSet.dropDownFont:SetText( (FontNameForDropDown or fontOpt.fontName or defOpt.fontName or "?") )
		end
		optColSet.sliderFont:SetValue(fontOpt.fontSize or defOpt.fontSize)
		optColSet.chkFontOutline:SetChecked(fontOpt.fontOutline)
		optColSet.chkFontShadow:SetChecked(fontOpt.fontShadow)
		do
			optColSet.chkFontOtherAvailable:SetChecked(fontOpt.fontOtherAvailable)
			module.options.fontOtherAvailable(fontOpt.fontOtherAvailable)
			if fontOpt.fontOtherAvailable then
				optColSet.nowFont = "fontLeft"
			else
				optColSet.nowFont = "font"
			end
			optColSet.fontsTab.selectFunc(optColSet.fontsTab.tabs[1].button)
		end
		optColSet.chkGeneralFont:SetChecked(VColOpt.fontGeneral)

		optColSet.chkGeneralFont:doAlphas()

		optColSet.textLeftTemEdit:SetText(textOpt.textTemplateLeft or defOpt.textTemplateLeft)
		optColSet.textRightTemEdit:SetText(textOpt.textTemplateRight or defOpt.textTemplateRight)
		optColSet.textCenterTemEdit:SetText(textOpt.textTemplateCenter or defOpt.textTemplateCenter)
		optColSet.chkIconName:SetChecked(textOpt.textIconName)
		optColSet.sliderIconNameChars:SetValue(textOpt.textIconNameChars or defOpt.textIconNameChars)
		do
			local deftextIconCDStyle = textOpt.textIconCDStyle or defOpt.textIconCDStyle
			optColSet.dropDownIconCDStyle:SetText(optColSet.dropDownIconCDStyle.Styles[deftextIconCDStyle])
		end
		optColSet.chkShowTargetName:SetChecked(textOpt.textShowTargetName)

		optColSet.chkIconFontMode:SetChecked(textOpt.iconFontMode)
		optColSet.iconFontTopEdit:SetText(textOpt.iconFontTopTemplate or defOpt.iconFontTopTemplate)
		optColSet.iconFontTopXSlider:SetValue(textOpt.iconFontTopX or defOpt.iconFontTopX)
		optColSet.iconFontTopXSlider:refreshLabel()
		optColSet.iconFontTopYSlider:SetValue(textOpt.iconFontTopY or defOpt.iconFontTopY)
		optColSet.iconFontTopYSlider:refreshLabel()
		optColSet.iconFontCenterEdit:SetText(textOpt.iconFontCenterTemplate or defOpt.iconFontCenterTemplate)
		optColSet.iconFontCenterXSlider:SetValue(textOpt.iconFontCenterX or defOpt.iconFontCenterX)
		optColSet.iconFontCenterXSlider:refreshLabel()
		optColSet.iconFontCenterYSlider:SetValue(textOpt.iconFontCenterY or defOpt.iconFontCenterY)
		optColSet.iconFontCenterYSlider:refreshLabel()
		optColSet.iconFontBottomEdit:SetText(textOpt.iconFontBottomTemplate or defOpt.iconFontBottomTemplate)
		optColSet.iconFontBottomXSlider:SetValue(textOpt.iconFontBottomX or defOpt.iconFontBottomX)
		optColSet.iconFontBottomXSlider:refreshLabel()
		optColSet.iconFontBottomYSlider:SetValue(textOpt.iconFontBottomY or defOpt.iconFontBottomY)
		optColSet.iconFontBottomYSlider:refreshLabel()
		if optColSet.iconFontTopWidget    then optColSet.iconFontTopWidget:refreshChecks();    optColSet.iconFontTopWidget:refreshGrowthEnabled()    end
		if optColSet.iconFontCenterWidget then optColSet.iconFontCenterWidget:refreshChecks(); optColSet.iconFontCenterWidget:refreshGrowthEnabled() end
		if optColSet.iconFontBottomWidget then optColSet.iconFontBottomWidget:refreshChecks(); optColSet.iconFontBottomWidget:refreshGrowthEnabled() end

		optColSet.fontLeftXSlider:SetValue(fontOpt.fontLeftX or 0)
		optColSet.fontLeftXSlider:refreshLabel()
		optColSet.fontLeftYSlider:SetValue(fontOpt.fontLeftY or 0)
		optColSet.fontLeftYSlider:refreshLabel()
		optColSet.fontRightXSlider:SetValue(fontOpt.fontRightX or 0)
		optColSet.fontRightXSlider:refreshLabel()
		optColSet.fontRightYSlider:SetValue(fontOpt.fontRightY or 0)
		optColSet.fontRightYSlider:refreshLabel()
		optColSet.fontCenterXSlider:SetValue(fontOpt.fontCenterX or 0)
		optColSet.fontCenterXSlider:refreshLabel()
		optColSet.fontCenterYSlider:SetValue(fontOpt.fontCenterY or 0)
		optColSet.fontCenterYSlider:refreshLabel()
		optColSet.fontIconXSlider:SetValue(fontOpt.fontIconX or 0)
		optColSet.fontIconXSlider:refreshLabel()
		optColSet.fontIconYSlider:SetValue(fontOpt.fontIconY or 0)
		optColSet.fontIconYSlider:refreshLabel()
		optColSet.fontIconCDXSlider:SetValue(fontOpt.fontIconCDX or 0)
		optColSet.fontIconCDXSlider:refreshLabel()
		optColSet.fontIconCDYSlider:SetValue(fontOpt.fontIconCDY or 0)
		optColSet.fontIconCDYSlider:refreshLabel()

		optColSet.chkGeneralText:SetChecked(VColOpt.textGeneral)

		optColSet:applyIconFontModeLayout()
		optColSet:applyATFLockLayout()
		optColSet.chkGeneralText:doAlphas()

		optColSet.chkShowOnlyOnCD:SetChecked(VColOpt.methodsShownOnCD)
		optColSet.chkBotToTop:SetChecked(VColOpt.frameAnchorBottom)
		optColSet.chkRightToLeft:SetChecked(VColOpt.frameAnchorRightToLeft)
		optColSet.chkGeneralMethods:SetChecked(VColOpt.methodsGeneral)
		do
			local defStyleAnimation = VColOpt.methodsStyleAnimation or defOpt.methodsStyleAnimation
			optColSet.dropDownStyleAnimation:SetText( optColSet.dropDownStyleAnimation.Styles[defStyleAnimation])
			local defTimeLineAnimation = VColOpt.methodsTimeLineAnimation or defOpt.methodsTimeLineAnimation
			optColSet.dropDownTimeLineAnimation:SetText(optColSet.dropDownTimeLineAnimation.Styles[defTimeLineAnimation])

			local defSortingRules = VColOpt.methodsSortingRules or defOpt.methodsSortingRules
			optColSet.dropDownSortingRules:SetText(optColSet.dropDownSortingRules.Rules[defSortingRules])
		end
		optColSet.chkIconTooltip:SetChecked(VColOpt.methodsIconTooltip)
		optColSet.chkLineClick:SetChecked(VColOpt.methodsLineClick)
		optColSet.chkLineClickWhisper:SetChecked(VColOpt.methodsLineClickWhisper)
		optColSet.chkNewSpellNewLine:SetChecked(VColOpt.methodsNewSpellNewLine)
		optColSet.chkHideOwnSpells:SetChecked(VColOpt.methodsHideOwnSpells)
		optColSet.chkAlphaNotInRange:SetChecked(VColOpt.methodsAlphaNotInRange)
		optColSet.sliderAlphaNotInRange:SetValue(VColOpt.methodsAlphaNotInRangeNum or defOpt.methodsAlphaNotInRangeNum)
		optColSet.chkDisableActive:SetChecked(VColOpt.methodsDisableActive)
		optColSet.chkOneSpellPerCol:SetChecked(VColOpt.methodsOneSpellPerCol)
		optColSet.chkOnlyInCombat:SetChecked(VColOpt.methodsOnlyInCombat)
		optColSet.chkSortByAvailability:SetChecked(VColOpt.methodsSortByAvailability)
		optColSet.chkSortByAvailability_activeToTop:SetChecked(VColOpt.methodsSortActiveToTop)
		optColSet.chkReverseSorting:SetChecked(VColOpt.methodsReverseSorting)
		optColSet.chkCDOnlyTimer:SetChecked(VColOpt.methodsCDOnlyTime)
		optColSet.chkTextIgnoreActive:SetChecked(VColOpt.methodsTextIgnoreActive)
		optColSet.chkShowOnlyNotOnCD:SetChecked(VColOpt.methodsOnlyNotOnCD)

		optColSet.chkGeneralMethods:doAlphas()

		optColSet.blacklistEditBox.EditBox:SetText(VColOpt.blacklistText or defOpt.blacklistText)
		optColSet.whitelistEditBox.EditBox:SetText(VColOpt.whitelistText or defOpt.whitelistText)
		optColSet.chkGeneralBlackList:SetChecked(VColOpt.blacklistGeneral)

		optColSet.chkGeneralBlackList:doAlphas()

		optColSet.chkVisibilityPartyTypeAlways:SetChecked(not VColOpt.visibilityPartyType)
		optColSet.chkVisibilityPartyTypeParty:SetChecked(VColOpt.visibilityPartyType == 1)
		optColSet.chkVisibilityPartyTypeRaid:SetChecked(VColOpt.visibilityPartyType == 2)
		optColSet.chkVisibilityZoneArena:SetChecked(not VColOpt.visibilityDisableArena)
		optColSet.chkVisibilityZoneBG:SetChecked(not VColOpt.visibilityDisableBG)
		optColSet.chkVisibilityZoneScenario:SetChecked(not VColOpt.visibilityDisable3ppl)
		optColSet.chkVisibilityZone5ppl:SetChecked(not VColOpt.visibilityDisable5ppl)
		optColSet.chkVisibilityZoneRaid:SetChecked(not VColOpt.visibilityDisableRaid)
		optColSet.chkVisibilityZoneOutdoor:SetChecked(not VColOpt.visibilityDisableWorld)
		optColSet.chkGeneralVisibility:SetChecked(VColOpt.visibilityGeneral)

		optColSet.chkGeneralVisibility:doAlphas()

		if not isGeneralTab then
			optColSet.chkATF:SetChecked(VColOpt.ATF)
			optColSet.sliderATFHeight:SetValue(VColOpt.iconSize or defOpt.iconSize)
			optColSet.sliderATFFont:SetValue(VColOpt.fontCDSize or defOpt.fontCDSize)
			optColSet.sliderATFMaxCol:SetValue(VColOpt.ATFCol or defOpt.ATFCol)
			optColSet.sliderATFMaxLine:SetValue(VColOpt.ATFLines or defOpt.ATFLines)
			optColSet.sliderATFOffsetX:SetValue(VColOpt.ATFOffsetX or defOpt.ATFOffsetX)
			optColSet.sliderATFOffsetY:SetValue(VColOpt.ATFOffsetY or defOpt.ATFOffsetY)
			optColSet.ATFRadiosCheck()
			optColSet.ATFTypeGrowth1:SetChecked(VColOpt.ATFGrowth == 1 or not VColOpt.ATFGrowth)
			optColSet.ATFTypeGrowth2:SetChecked(VColOpt.ATFGrowth == 2)
			optColSet.dropDownATFFramePrior:Update(VColOpt.ATFFramePrior)
		end


		optColSet.chkEnable:SetShown(not isGeneralTab)
		optColSet.chkGeneral:SetShown(not isGeneralTab)

		optColSet.chkGeneralIcons:SetShown(not isGeneralTab)
		optColSet.chkGeneralColorize:SetShown(not isGeneralTab)
		optColSet.chkGeneralFont:SetShown(not isGeneralTab)
		optColSet.chkGeneralText:SetShown(not isGeneralTab)
		optColSet.chkGeneralMethods:SetShown(not isGeneralTab)
		optColSet.chkGeneralVisibility:SetShown(not isGeneralTab)
		optColSet.chkGeneralBlackList:SetShown(not isGeneralTab)

		module.options.showColorFrame(module.options.colorSetupFrame)

		if self then
			optColSet.templateRestore:Hide()
		end

		if isGeneralTab and optColSet.superTabFrame.list.selected == 10 then
			optColSet.superTabFrame.list:SetTo(1)
		end

		optColSet.LOCK = nil
		currColOpt = VMRT.ExCD2.colSet[module.options.optColTabs.selected]

		if VColOpt.enabled and not isGeneralTab and VMRT.ExCD2.enabled and not VColOpt.ATF then
			optColSet.NavLineF.f = module.frame.colFrame[i]
			optColSet.FindFrameBut:Show()
		else
			optColSet.NavLineF.f = nil
			optColSet.FindFrameBut:Hide()
		end
	end

	self.optColSet = {}
	do
		local _ADVANCED_LABEL = ADVANCED_LABEL or "Advanced"
		local _PROFILES_LABEL = L and L.Profiles or "Profiles"

		local tmpArr = {}
		for i=1,module.db.maxColumns do
			tmpArr[i] = tostring(i)
		end
		tmpArr[module.db.maxColumns+1] = L.cd2GeneralSet
		tmpArr[#tmpArr+1] = _ADVANCED_LABEL
		tmpArr[#tmpArr+1] = _PROFILES_LABEL
		self.optColTabs = ELib:Tabs(self.tab.tabs[2],0,unpack(tmpArr)):Size(660,417):Point("TOP",0,-48):SetTo(module.db.maxColumns+1)

		local profilesBut = self.optColTabs.tabs[module.db.maxColumns+3].button
		profilesBut.colID = module.db.maxColumns+3
		profilesBut:SetScript("OnClick", function(self)
			module.options.optColTabs.selected = self.colID
			module.options.optColTabs:UpdateTabs()
			module.options.optColSet.superTabFrame:Hide()
		end)
		profilesBut:ClearAllPoints()
		profilesBut:SetPoint("TOPRIGHT", -10, 24)

		local advColBut = self.optColTabs.tabs[module.db.maxColumns+2].button
		advColBut.colID = module.db.maxColumns+2
		advColBut:SetScript("OnClick", function(self)
			module.options.optColTabs.selected = self.colID
			module.options.optColTabs:UpdateTabs()
			module.options.optColSet.superTabFrame:Hide()
		end)
		advColBut:ClearAllPoints()
		advColBut:SetPoint("RIGHT", profilesBut, "LEFT", 0, 0)
	end
	for i=1,module.db.maxColumns+1 do
		self.optColTabs.tabs[i].button.colID = i
		self.optColTabs.tabs[i].button:SetScript("OnClick", self.selectColumnTab)
	end

	self.optColTabs:SetBackdropBorderColor(0,0,0,0)
	self.optColTabs:SetBackdropColor(0,0,0,0)

	self.tab.tabs[2].decorationLine = ELib:DecorationLine(self.tab.tabs[2],true,"BACKGROUND",-5):Point("TOPLEFT",self.tab.tabs[2],0,-28):Point("RIGHT",self,0,0):Size(0,20)

	self.optColSet.superTabFrame = ExRT.lib:ScrollTabsFrame(self.optColTabs,L.cd2OtherSetTabNameGeneral,L.cd2OtherSetTabNameIcons,L.cd2OtherSetTabNameColors,L.cd2OtherSetTabNameFont,L.cd2OtherSetTabNameText,L.cd2OtherSetTabNameOther,L.cd2OtherSetTabNameVisibility,L.cd2OtherSetTabNameBlackList,L.cd2OtherSetTabNameTemplate,L.cd2ATF):Size(660,450):Point("TOP",0,-10)
	self.optColSet.superTabFrame.list.LDisabled = {}
	self.optColSet.superTabFrame.list:SetScript("OnUpdate",function(self)
		for i=1,#self.List do
			local line = self.List[i]
			if line:IsMouseOver() and line.index and self.LDisabled[line.index] then
				if not self.DisabledTooltipShowed then
					self.DisabledTooltipShowed = true
					GameTooltip:SetOwner(line, "ANCHOR_TOP")
					GameTooltip:AddLine(L.cd2ATFTooltipDisabled, 1, .3, .3)
					GameTooltip:Show()
				end
				return
			end
		end
		if self.DisabledTooltipShowed then
			GameTooltip_Hide()
			self.DisabledTooltipShowed = nil
		end
	end)

	self.optColSet.NavLineF = ELib:Frame(UIParent):Point("TOPLEFT",UIParent,0,0):Size(1,1)
	self.optColSet.NavLineF:SetFrameStrata("HIGH")
	self.optColSet.NavLineF:Hide()

	self.optColSet.NavLineF.line = self.optColSet.NavLineF.CreateLine and self.optColSet.NavLineF:CreateLine(nil, "ARTWORK")
	if self.optColSet.NavLineF.line then
		self.optColSet.NavLineF.line:SetTexture("Interface/AddOns/"..GlobalAddonName.."/media/lineGapped")
		self.optColSet.NavLineF.line:SetVertexColor(.44,1,.50,1)
		self.optColSet.NavLineF.line:SetThickness(10)

		self.optColSet.NavLineF:SetScript("OnUpdate",function(self)
				if not self.line then return end
				if not self.f or not self.f2 then
					return
				end
				local cx1, cy1 = self.f2:GetCenter()
				local cx2, cy2 = self.f:GetCenter()
				if not cx1 or not cx2 then return end
				local s1 = self.f2:GetEffectiveScale() or 1
				local s2 = self.f:GetEffectiveScale() or 1
				local s3 = UIParent:GetEffectiveScale() or 1
				cx1, cy1 = cx1*s1/s3, cy1*s1/s3
				cx2, cy2 = cx2*s2/s3, cy2*s2/s3

				self.line:SetStartPoint("BOTTOMLEFT", UIParent, cx1, cy1)
				self.line:SetEndPoint("BOTTOMLEFT", UIParent, cx2, cy2)

				local t = GetTime() % 1
				local d = 40/1024
				self.line:SetTexCoord(d * t,(1 - d)+ t*d,0,1)
			end)

	else
		self.optColSet.NavLineF:Hide()
		self.optColSet.NavLineF:SetScript("OnUpdate", nil)
	end

	self.optColSet.FindFrameBut = ELib:Button(self.optColTabs,L.cd2FindFrame):Point("TOPRIGHT",self.optColSet.superTabFrame,"TOPLEFT",-5,-1):Size(83,50):OnEnter(function()
		local f = self.optColSet.NavLineF
		if f.f and f.f.ATFenabled then return end
		f:Show()
	end):OnLeave(function ()
		self.optColSet.NavLineF:Hide()
	end)
	self.optColSet.FindFrameBut:HookScript("OnHide", function()
		self.optColSet.NavLineF:Hide()
	end)

	self.optColSet.NavLineF.f2 = self.optColSet.FindFrameBut

	self.optColSet.chkEnable = ELib:Check(self.optColSet.superTabFrame.tab[1],">>>"..L.Enable.."<<<"):Point(10,-10):AddColorState():OnClick(function(self)
		if self:GetChecked() then
			currColOpt.enabled = true
		else
			currColOpt.enabled = nil
		end
		module:ReloadAllSplits()
	end):OnShow(function(self)
		C_Timer.After(.1,function()
			self:ColorState()
		end)
	end,true)

	local function applyUseGeneralAll(state)
		local optColSet = module.options.optColSet
		if optColSet.LOCK then return end
		local sel = module.options.optColTabs.selected
		local VColOpt = VMRT.ExCD2.colSet[sel]
		if not VColOpt then return end
		local v = state and true or nil
		VColOpt.frameGeneral = v
		VColOpt.iconGeneral = v
		VColOpt.textureGeneral = v
		VColOpt.fontGeneral = v
		VColOpt.textGeneral = v
		VColOpt.methodsGeneral = v
		VColOpt.visibilityGeneral = v
		VColOpt.blacklistGeneral = v
		if currColOpt then
			currColOpt.frameGeneral = v
			currColOpt.iconGeneral = v
			currColOpt.textureGeneral = v
			currColOpt.fontGeneral = v
			currColOpt.textGeneral = v
			currColOpt.methodsGeneral = v
			currColOpt.visibilityGeneral = v
			currColOpt.blacklistGeneral = v
		end
		optColSet.LOCK = true
		local checks = {
			optColSet.chkGeneral,
			optColSet.chkGeneralIcons,
			optColSet.chkGeneralColorize,
			optColSet.chkGeneralFont,
			optColSet.chkGeneralText,
			optColSet.chkGeneralMethods,
			optColSet.chkGeneralVisibility,
			optColSet.chkGeneralBlackList,
		}
		for i = 1, #checks do
			local c = checks[i]
			if c then
				c:SetChecked(v and true or false)
				if c.doAlphas then c:doAlphas() end
			end
		end
		optColSet.LOCK = nil
		if module.options.selectColumnTab then
			module.options:selectColumnTab()
		end
		module:ReloadAllSplits()
	end

	self.optColSet.chkGeneral = ELib:Check(self.optColSet.superTabFrame.tab[1],L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)
	function self.optColSet.chkGeneral:doAlphas()
		ExRT.lib.SetAlphas(VMRT.ExCD2.colSet[module.options.optColTabs.selected].frameGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1,module.options.optColSet.sliderLinesNum,module.options.optColSet.sliderAlpha,module.options.optColSet.sliderScale,module.options.optColSet.sliderWidth,module.options.optColSet.sliderColsInCol,module.options.optColSet.sliderBetweenLines,module.options.optColSet.sliderBlackBack,module.options.optColSet.butToCenter,module.options.optColSet.dropDownStrata,module.options.optColSet.textdropDownStrata)
	end

	local function getActiveFrameOpt()
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		if not sel then return nil, nil end
		local VColOpt = VMRT.ExCD2.colSet[sel]
		if not VColOpt then return nil, nil end
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		if not isGeneralTab and VColOpt.frameGeneral then
			local genOpt = VMRT.ExCD2.colSet[module.db.maxColumns + 1]
			return genOpt or VColOpt, VColOpt
		end
		return VColOpt, VColOpt
	end

	self.optColSet.sliderLinesNum = ELib:Slider(self.optColSet.superTabFrame.tab[1],L.cd2lines):Size(400):Point("TOP",0,-50):Range(1,module.db.maxLinesInCol):SetObey(true):OnChange(function(self,event)
		if module.options.optColSet.LOCK then return end
		event = event - event%1
		local target = getActiveFrameOpt()
		if not target then return end
		target.frameLines = event
		if currColOpt and currColOpt == target then currColOpt.frameLines = event end
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderWidth = ELib:Slider(self.optColSet.superTabFrame.tab[1],L.cd2width):Size(400):Point("TOP",0,-85):Range(1,400):SetObey(true):OnChange(function(self,event)
		if module.options.optColSet.LOCK then return end
		event = event - event%1
		local target = getActiveFrameOpt()
		if not target then return end
		target.frameWidth = event
		if currColOpt and currColOpt == target then currColOpt.frameWidth = event end
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderAlpha = ELib:Slider(self.optColSet.superTabFrame.tab[1],L.cd2alpha):Size(400):Point("TOP",0,-120):Range(0,100):SetObey(true):OnChange(function(self,event)
		if module.options.optColSet.LOCK then return end
		event = event - event%1
		local target = getActiveFrameOpt()
		if not target then return end
		target.frameAlpha = event
		if currColOpt and currColOpt == target then currColOpt.frameAlpha = event end
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderScale = ELib:Slider(self.optColSet.superTabFrame.tab[1],L.cd2scale):Size(400):Point("TOP",0,-155):Range(5,200):SetObey(true):OnChange(function(self,event)
		if module.options.optColSet.LOCK then return end
		event = event - event%1
		local target = getActiveFrameOpt()
		if not target then return end
		if target.frameScale == event then return end
		target.frameScale = event
		if currColOpt and currColOpt == target then currColOpt.frameScale = event end
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits("ScaleFix")
	end)

	self.optColSet.sliderColsInCol = ELib:Slider(self.optColSet.superTabFrame.tab[1],L.cd2ColSetColsInCol):Size(400):Point("TOP",0,-190):Range(1,module.db.maxLinesInCol):SetObey(true):OnChange(function(self,event)
		if module.options.optColSet.LOCK then return end
		event = event - event%1
		local target = getActiveFrameOpt()
		if not target then return end
		target.frameColumns = event
		if currColOpt and currColOpt == target then currColOpt.frameColumns = event end
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderBetweenLines = ELib:Slider(self.optColSet.superTabFrame.tab[1],L.cd2ColSetBetweenLines):Size(400):Point("TOP",0,-225):Range(0,20):SetObey(true):OnChange(function(self,event)
		if module.options.optColSet.LOCK then return end
		event = event - event%1
		local target = getActiveFrameOpt()
		if not target then return end
		target.frameBetweenLines = event
		if currColOpt and currColOpt == target then currColOpt.frameBetweenLines = event end
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderBlackBack = ELib:Slider(self.optColSet.superTabFrame.tab[1],L.cd2BlackBack):Size(400):Point("TOP",0,-260):Range(0,100):SetObey(true):OnChange(function(self,event)
		if module.options.optColSet.LOCK then return end
		event = event - event%1
		local target = getActiveFrameOpt()
		if not target then return end
		target.frameBlackBack = event
		if currColOpt and currColOpt == target then currColOpt.frameBlackBack = event end
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits()
	end)

	self.optColSet.dropDownStrata = ELib:DropDown(self.optColSet.superTabFrame.tab[1],230,-1):Point("TOPLEFT",198,-295):Size(230)
	self.optColSet.textdropDownStrata = ELib:Text(self.optColSet.superTabFrame.tab[1],L.cd2ColStrata..":",11):Size(200,20):Point("TOPLEFT",27,-295)
	for i,strataString in ipairs({"BACKGROUND","LOW","MEDIUM","HIGH","DIALOG","FULLSCREEN","FULLSCREEN_DIALOG","TOOLTIP","Auto"}) do
		self.optColSet.dropDownStrata.List[i] = {
			text = strataString,
			arg1 = strataString,
			func = function (self,arg)
				ELib:DropDownClose()
				currColOpt.frameStrata = arg
				if arg == "Auto" then
					currColOpt.frameStrata = nil
				end
				module:ReloadAllSplits()
				self:GetParent().parent:SetText(arg)
			end,
			tooltip = strataString == "Auto" and L.cd2ColStrataAutoTooltip,
		}
	end
	function self.optColSet.dropDownStrata:PreUpdate()
		for i=1,#self.List do
			local v = self.List[i]
			if v.arg1 == "Auto" then
				if currColOpt.ATF then
					v.isHidden = nil
				else
					v.isHidden = true
				end
				break
			end
		end
	end

	self.optColSet.butToCenter = ELib:Button(self.optColSet.superTabFrame.tab[1],L.cd2ColSetResetPos):Size(200,20):Point("TOP",0,-330):OnClick(function(self)
		if (module.db.maxColumns + 1) == module.options.optColTabs.selected then
			module.frame:ClearAllPoints()
			module.frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
		else
			module.frame.colFrame[module.options.optColTabs.selected]:ClearAllPoints()
			module.frame.colFrame[module.options.optColTabs.selected]:SetPoint("CENTER",UIParent,"CENTER",0,0)
		end
	end)


	self.optColSet.chkSeparateIconHW = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2ColSetSeparateIconHW):Point(10,-12):Tooltip(L.cd2ColSetSeparateIconHWTooltip):OnClick(function(self)
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		if saved and saved.ATF then
			self:SetChecked(false)
			return
		end
		if self:GetChecked() then
			currColOpt.iconSeparateHW = true
			if not currColOpt.iconHeight then
				currColOpt.iconHeight = currColOpt.iconSize or module.db.colsDefaults.iconSize
			end
		else
			currColOpt.iconSeparateHW = nil
		end
		module.options.optColSet:applyIconHWLayout()
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderHeight = ELib:Slider(self.optColSet.superTabFrame.tab[2],L.cd2OtherSetIconSize):Size(400):Point("TOP",0,-50):Range(6,128):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.iconSize = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.sliderIconRealHeight = ELib:Slider(self.optColSet.superTabFrame.tab[2],L.cd2ColSetIconHeight):Size(400):Point("TOP",0,-90):Range(6,128):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.iconHeight = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)
	self.optColSet.sliderIconRealHeight:Hide()

	self.optColSet.chkGray = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2graytooltip):Point(10,-110):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.iconGray = true
		else
			currColOpt.iconGray = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.textIconPos = ELib:Text(self.optColSet.superTabFrame.tab[2],L.cd2OtherSetIconPosition..":"):Size(200,20):Point(10,-85)
	self.optColSet.dropDownIconPos = ELib:DropDown(self.optColSet.superTabFrame.tab[2],190,3):Size(200):Point(180,-85)
	self.optColSet.dropDownIconPos.PosNames = {L.cd2OtherSetIconPositionLeft,L.cd2OtherSetIconPositionRight,L.cd2OtherSetIconPositionNo}
	for i=1,#self.optColSet.dropDownIconPos.PosNames do
		self.optColSet.dropDownIconPos.List[i] = {
			text = self.optColSet.dropDownIconPos.PosNames[i],
			arg1 = i,
			func = function (self,arg)
				ELib:DropDownClose()
				currColOpt.iconPosition = arg
				module:ReloadAllSplits()
				module.options.optColSet.dropDownIconPos:SetText(module.options.optColSet.dropDownIconPos.PosNames[arg])
			end,
		}
	end

	self.optColSet.chkCooldown = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2ColSetMethodCooldown):Point(10,-135):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsCooldown = true
		else
			currColOpt.methodsCooldown = nil
		end
		module.options.optColSet:applyIconHWLayout()
		module:ReloadAllSplits()
	end)

	function self.optColSet:applyIconHWLayout()
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local VColOpt = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		local genColOpt = VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[module.db.maxColumns + 1]
		local opt = (VColOpt and not isGeneralTab and VColOpt.iconGeneral and genColOpt) or VColOpt
		local atf = VColOpt and VColOpt.ATF
		local sep = opt and opt.iconSeparateHW and not atf
		local cd = opt and opt.methodsCooldown
		local active = sep and cd
		if active then
			self.sliderHeight.text:SetText(L.cd2ColSetIconWidth)
			self.sliderIconRealHeight:Show()
			self.textIconPos:ClearAllPoints()
			self.textIconPos:SetPoint("TOPLEFT",10,-125)
			self.dropDownIconPos:ClearAllPoints()
			self.dropDownIconPos:SetPoint("TOPLEFT",180,-125)
			self.chkGray:ClearAllPoints()
			self.chkGray:SetPoint("TOPLEFT",10,-150)
			self.chkCooldown:ClearAllPoints()
			self.chkCooldown:SetPoint("TOPLEFT",10,-175)
		else
			self.sliderHeight.text:SetText(L.cd2OtherSetIconSize)
			self.sliderIconRealHeight:Hide()
			self.textIconPos:ClearAllPoints()
			self.textIconPos:SetPoint("TOPLEFT",10,-85)
			self.dropDownIconPos:ClearAllPoints()
			self.dropDownIconPos:SetPoint("TOPLEFT",180,-85)
			self.chkGray:ClearAllPoints()
			self.chkGray:SetPoint("TOPLEFT",10,-110)
			self.chkCooldown:ClearAllPoints()
			self.chkCooldown:SetPoint("TOPLEFT",10,-135)
		end
		ExRT.lib.SetAlphas(cd and 1 or 0.5, self.chkSeparateIconHW)
		if self.applyATFLockLayout then
			self:applyATFLockLayout()
		end
	end

	function self.optColSet:applyATFLockLayout()
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local on = saved and saved.ATF or false
		if self.chkIconFontMode then
			if on then
				self.chkIconFontMode:SetChecked(false)
				self.chkIconFontMode.tooltipText = L.cd2ATFLockTooltip
			else
				self.chkIconFontMode.tooltipText = nil
			end
		end
		if self.chkSeparateIconHW then
			if on then
				self.chkSeparateIconHW:SetChecked(false)
				self.chkSeparateIconHW.tooltipText = L.cd2ATFLockTooltip
			else
				self.chkSeparateIconHW.tooltipText = L.cd2ColSetSeparateIconHWTooltip
			end
		end
		if ExRT and ExRT.lib and ExRT.lib.SetAlphas then
			ExRT.lib.SetAlphas(on and 0.5 or 1, self.chkIconFontMode, self.chkSeparateIconHW)
		end
	end

	self.optColSet.chkCooldownTextDef = ELib:Radio(self.optColSet.superTabFrame.tab[2],L.cd2ColSetCDTimeDef):Point("TOPLEFT",self.optColSet.chkCooldown,25,-25):Tooltip(L.cd2ColSetCDTimeDefTooltip):OnClick(function(self)
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		local genCol = VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[module.db.maxColumns + 1]
		local source = saved
		if not isGeneralTab and saved and saved.textGeneral and genCol then source = genCol end
		if source and source.iconFontMode then
			module.options.optColSet:chkCooldownTextUpdate()
			return
		end
		currColOpt.iconCooldownHideNumbers = nil
		currColOpt.iconCooldownExRTNumbers = nil
		module.options.optColSet:chkCooldownTextUpdate()
		module:ReloadAllSplits()
	end)

	self.optColSet.chkCooldownExRTNumbers = ELib:Radio(self.optColSet.superTabFrame.tab[2],L.cd2ColSetCDTimeExRT):Point("TOPLEFT",self.optColSet.chkCooldownTextDef,0,-25):Tooltip(L.cd2ColSetCDTimeExRTTooltip):OnClick(function(self)
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		local genCol = VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[module.db.maxColumns + 1]
		local source = saved
		if not isGeneralTab and saved and saved.textGeneral and genCol then source = genCol end
		if source and source.iconFontMode then
			module.options.optColSet:chkCooldownTextUpdate()
			return
		end
		currColOpt.iconCooldownHideNumbers = nil
		currColOpt.iconCooldownExRTNumbers = true
		module.options.optColSet:chkCooldownTextUpdate()
		module:ReloadAllSplits()
	end)

	self.optColSet.chkCooldownHideNumbers = ELib:Radio(self.optColSet.superTabFrame.tab[2],L.BattleResHideTime):Point("TOPLEFT",self.optColSet.chkCooldownExRTNumbers,0,-25):Tooltip(L.BattleResHideTimeTooltip):OnClick(function(self)
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		local genCol = VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[module.db.maxColumns + 1]
		local source = saved
		if not isGeneralTab and saved and saved.textGeneral and genCol then source = genCol end
		if source and source.iconFontMode then
			module.options.optColSet:chkCooldownTextUpdate()
			return
		end
		currColOpt.iconCooldownHideNumbers = true
		currColOpt.iconCooldownExRTNumbers = nil
		module.options.optColSet:chkCooldownTextUpdate()
		module:ReloadAllSplits()
	end)

	self.optColSet.chkCooldownTextUpdate = function(self)
		local v1,v2,v3
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local currColOpt = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		if not currColOpt then return end
		local genColOpt = VMRT.ExCD2.colSet[module.db.maxColumns + 1]
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		local effFont = (not isGeneralTab and currColOpt.textGeneral and genColOpt) or currColOpt
		if effFont and effFont.iconFontMode then
			v2 = true
		elseif currColOpt.iconCooldownExRTNumbers then
			v3 = true
		elseif currColOpt.iconCooldownHideNumbers then
			v2 = true
		else
			v1 = true
		end
		module.options.optColSet.chkCooldownTextDef:SetChecked(v1)
		module.options.optColSet.chkCooldownHideNumbers:SetChecked(v2)
		module.options.optColSet.chkCooldownExRTNumbers:SetChecked(v3)
	end

	self.optColSet.chkCooldownShowSwipe = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2ShowEgde):Point("TOPLEFT",self.optColSet.chkCooldownHideNumbers,0,-25):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.iconCooldownShowSwipe = true
		else
			currColOpt.iconCooldownShowSwipe = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.textGlowType = ELib:Text(self.optColSet.superTabFrame.tab[2],L.cd2GlowType):Point("TOPLEFT",self.optColSet.chkCooldownShowSwipe,0,-25):Size(0,25):Middle():Left()
	self.optColSet.dropDownCooldownGlowType = ELib:DropDown(self.optColSet.superTabFrame.tab[2],90,4):Size(70):Point("LEFT",self.optColSet.textGlowType,"RIGHT",5,0):Tooltip(L.cd2GlowTypeTooltip)
	for i=1,4 do
		self.optColSet.dropDownCooldownGlowType.List[i] = {
			text = i == 4 and L.NoText or i,
			arg1 = i,
			func = function (self,arg1)
				ELib:DropDownClose()
				currColOpt.iconGlowType = arg1
				module:ReloadAllSplits()
				module.options.optColSet.dropDownCooldownGlowType:SetText(module.options.optColSet.dropDownCooldownGlowType.List[arg1].text)
				if module.options.optColSet.updateGlowColorEnabled then
					module.options.optColSet.updateGlowColorEnabled()
				end
			end,
		}
	end

	self.optColSet.colorPickerGlow = ExRT.lib.CreateColorPickButton(self.optColSet.superTabFrame.tab[2],20,20,nil,0,0)
	self.optColSet.colorPickerGlow:ClearAllPoints()
	self.optColSet.colorPickerGlow:SetPoint("LEFT", self.optColSet.dropDownCooldownGlowType, "RIGHT", 6, 0)
	self.optColSet.colorPickerGlow:SetScript("OnEnter", function(self)
		ELib.Tooltip.Show(self, nil, L.cd2GlowColor, {L.cd2GlowColorTooltip,1,1,1})
	end)
	self.optColSet.colorPickerGlow:SetScript("OnLeave", function() GameTooltip_Hide() end)
	self.optColSet.colorPickerGlow:SetScript("OnClick",function (self)
		if self:GetAlpha() < 1 then return end
		local startR = currColOpt.iconGlowColorR or module.db.colsDefaults.iconGlowColorR
		local startG = currColOpt.iconGlowColorG or module.db.colsDefaults.iconGlowColorG
		local startB = currColOpt.iconGlowColorB or module.db.colsDefaults.iconGlowColorB
		local startA = currColOpt.iconGlowColorA or module.db.colsDefaults.iconGlowColorA
		ColorPickerFrame.previousValues = {startR, startG, startB, startA}
		ColorPickerFrame.hasOpacity = true
		local nilFunc = ExRT.NULLfunc
		local function changedCallback(restore)
			local newR, newG, newB, newA
			if restore then
				newR, newG, newB, newA = unpack(restore)
			else
				newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
			end
			currColOpt.iconGlowColorR = newR
			currColOpt.iconGlowColorG = newG
			currColOpt.iconGlowColorB = newB
			currColOpt.iconGlowColorA = newA
			module:ReloadAllSplits()
			self.color:SetColorTexture(newR,newG,newB,newA)
		end
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = nilFunc, nilFunc, nilFunc
		ColorPickerFrame.opacity = startA
		ColorPickerFrame:SetColorRGB(startR, startG, startB)
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback
		ColorPickerFrame:Show()
	end)
	function self.optColSet.updateGlowColorEnabled()
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local t = (saved and saved.iconGlowType) or module.db.colsDefaults.iconGlowType
		local enabled = t == 1 or t == 2 or t == 3
		module.options.optColSet.colorPickerGlow:SetAlpha(enabled and 1 or 0.3)
		module.options.optColSet.colorPickerGlow:EnableMouse(enabled)
	end

	self.optColSet.chkShowTitles = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2ColSetShowTitles):Point("TOPLEFT",self.optColSet.chkCooldown,0,-150):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.iconTitles = true
		else
			currColOpt.iconTitles = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkHideBlizzardEdges = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2ColSetIconHideBlizzardEdges):Point("TOPLEFT",self.optColSet.chkShowTitles,0,-25):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.iconHideBlizzardEdges = true
		else
			currColOpt.iconHideBlizzardEdges = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkMasque = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2ColSetIconMasque):Point("TOPLEFT",self.optColSet.chkHideBlizzardEdges,0,-25):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.iconMasque = true
		else
			currColOpt.iconMasque = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkGeneralIcons = ELib:Check(self.optColSet.superTabFrame.tab[2],L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)
	function self.optColSet.chkGeneralIcons:doAlphas()
		ExRT.lib.SetAlphas(VMRT.ExCD2.colSet[module.options.optColTabs.selected].iconGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1,module.options.optColSet.chkGray,module.options.optColSet.sliderHeight,module.options.optColSet.dropDownIconPos,module.options.optColSet.chkCooldown,module.options.optColSet.chkShowTitles,module.options.optColSet.chkHideBlizzardEdges,module.options.optColSet.chkCooldownShowSwipe,module.options.optColSet.chkCooldownHideNumbers,module.options.optColSet.textIconPos, module.options.optColSet.textGlowType, module.options.optColSet.dropDownCooldownGlowType,module.options.optColSet.colorPickerGlow,module.options.optColSet.chkCooldownTextDef,module.options.optColSet.chkCooldownExRTNumbers,module.options.optColSet.chkMasque,module.options.optColSet.chkSeparateIconHW,module.options.optColSet.sliderIconRealHeight)
		if module.options.optColSet.updateGlowColorEnabled then
			module.options.optColSet.updateGlowColorEnabled()
		end
	end


	local function dropDownTextureButtonClick(self,arg,name)
		ELib:DropDownClose()
		currColOpt.textureFile = arg
		module:ReloadAllSplits()
		module.options.optColSet.dropDownTexture:SetText(L.cd2OtherSetTexture.." ["..name.."]")
	end

	self.optColSet.textDDTexture = ELib:Text(self.optColSet.superTabFrame.tab[3],L.cd2OtherSetTexture..":"):Size(200,20):Point(10,-35)
	self.optColSet.dropDownTexture = ELib:DropDown(self.optColSet.superTabFrame.tab[3],200,15):Size(200):Point(180,-35)
	do
		local textureMedia = ExRT.F.GetSharedMediaList("statusbar", ExRT.F.textureList)
		for i = 1, #textureMedia do
			local entry = textureMedia[i]
			self.optColSet.dropDownTexture.List[i] = {
				text = entry.name,
				arg1 = entry.path,
				arg2 = entry.name,
				func = dropDownTextureButtonClick,
				texture = entry.path,
				justifyH = "CENTER",
			}
		end
	end

	self.optColSet.textDDBorder = ELib:Text(self.optColSet.superTabFrame.tab[3],L.cd2OtherSetBorder..":"):Size(200,20):Point(10,-65)
	self.optColSet.sliderBorderSize = ELib:Slider(self.optColSet.superTabFrame.tab[3],""):Size(170):Point(180,-68):Range(0,20):OnChange(function(self,event)
		event = event - event%1
		currColOpt.textureBorderSize = event
		self.tooltipText = event
		self:tooltipReload(self)
		module:ReloadAllSplits()
	end)
	self.optColSet.colorPickerBorder = ExRT.lib.CreateColorPickButton(self.optColSet.superTabFrame.tab[3],20,20,nil,361,-65)
	self.optColSet.colorPickerBorder:SetScript("OnClick",function (self)
		ColorPickerFrame.previousValues = {currColOpt.textureBorderColorR or module.db.colsDefaults.textureBorderColorR,currColOpt.textureBorderColorG or module.db.colsDefaults.textureBorderColorG,currColOpt.textureBorderColorB or module.db.colsDefaults.textureBorderColorB, currColOpt.textureBorderColorA or module.db.colsDefaults.textureBorderColorA}
		ColorPickerFrame.hasOpacity = true
		local nilFunc = ExRT.NULLfunc
		local function changedCallback(restore)
			local newR, newG, newB, newA
			if restore then
				newR, newG, newB, newA = unpack(restore)
			else
				newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
			end
			currColOpt.textureBorderColorR = newR
			currColOpt.textureBorderColorG = newG
			currColOpt.textureBorderColorB = newB
			currColOpt.textureBorderColorA = newA
			module:ReloadAllSplits()

			self.color:SetColorTexture(newR,newG,newB,newA)
		end
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = nilFunc, nilFunc, nilFunc
		ColorPickerFrame.opacity = currColOpt.textureBorderColorA or module.db.colsDefaults.textureBorderColorA
		ColorPickerFrame:SetColorRGB(currColOpt.textureBorderColorR or module.db.colsDefaults.textureBorderColorR,currColOpt.textureBorderColorG or module.db.colsDefaults.textureBorderColorG,currColOpt.textureBorderColorB or module.db.colsDefaults.textureBorderColorB)
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback
		ColorPickerFrame:Show()
	end)

	self.optColSet.chkAnimation = ELib:Check(self.optColSet.superTabFrame.tab[3],L.cd2OtherSetAnimation):Point(10,-97):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.textureAnimation = true
		else
			currColOpt.textureAnimation = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkHideSpark = ELib:Check(self.optColSet.superTabFrame.tab[3],L.cd2OtherSetHideSpark):Point(200,-97):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.textureHideSpark = true
		else
			currColOpt.textureHideSpark = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkSmoothAnimation = ELib:Check(self.optColSet.superTabFrame.tab[3],L.cd2TextureSmoothAnim):Point(10,-122):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.textureSmoothAnimation = true
		else
			currColOpt.textureSmoothAnimation = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderSmoothAnimationDuration = ELib:Slider(self.optColSet.superTabFrame.tab[3],""):Size(140):Point("TOP",self.optColSet.chkSmoothAnimation,0,-2):Point("LEFT",self.optColSet.chkSmoothAnimation.text,"RIGHT",20,0):Range(10,200):OnChange(function(self,event)
		event = event - event%1
		currColOpt.textureSmoothAnimationDuration = event
		module:ReloadAllSplits()
		self.tooltipText = event / 100
		self:tooltipReload(self)
	end)
	self.optColSet.sliderSmoothAnimationDuration.Low:SetText("0.1")
	self.optColSet.sliderSmoothAnimationDuration.High:SetText("2")


	self.colorSetupFrame = CreateFrame("Frame",nil,self.optColSet.superTabFrame.tab[3])
	self.colorSetupFrame:SetSize(420,290)
	self.colorSetupFrame:SetPoint("TOP",0,-135)

	self.colorSetupFrame.backAlpha = ELib:Slider(self.colorSetupFrame,L.cd2OtherSetColorFrameAlpha):Size(400):Point("TOP",0,-163):Range(0,100)
	self.colorSetupFrame.backCDAlpha = ELib:Slider(self.colorSetupFrame,L.cd2OtherSetColorFrameAlphaCD):Size(400):Point("TOP",0,-198):Range(0,100)
	self.colorSetupFrame.backCooldownAlpha = ELib:Slider(self.colorSetupFrame,L.cd2OtherSetColorFrameAlphaCooldown):Size(400):Point("TOP",0,-233):Range(0,100)
	self.colorSetupFrame.backAlpha.inOptName = "textureAlphaBackground"
	self.colorSetupFrame.backCDAlpha.inOptName = "textureAlphaTimeLine"
	self.colorSetupFrame.backCooldownAlpha.inOptName = "textureAlphaCooldown"

	local function colorPickerButtonClick(self)
		ColorPickerFrame.previousValues = {currColOpt[self.inOptName.."R"] or module.db.colsDefaults[self.inOptName.."R"],currColOpt[self.inOptName.."G"] or module.db.colsDefaults[self.inOptName.."G"],currColOpt[self.inOptName.."B"] or module.db.colsDefaults[self.inOptName.."B"], 1}
		local nilFunc = ExRT.NULLfunc
		local function changedCallback(restore)
			local newR, newG, newB, newA
			if restore then
				newR, newG, newB, newA = unpack(restore)
			else
				newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
			end
			currColOpt[self.inOptName.."R"] = newR
			currColOpt[self.inOptName.."G"] = newG
			currColOpt[self.inOptName.."B"] = newB
			module:ReloadAllSplits()

			self.color:SetColorTexture(newR,newG,newB,1)
		end
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = nilFunc, nilFunc, nilFunc
		ColorPickerFrame:SetColorRGB(currColOpt[self.inOptName.."R"] or module.db.colsDefaults[self.inOptName.."R"],currColOpt[self.inOptName.."G"] or module.db.colsDefaults[self.inOptName.."G"],currColOpt[self.inOptName.."B"] or module.db.colsDefaults[self.inOptName.."B"])
		ColorPickerFrame.func, ColorPickerFrame.cancelFunc = changedCallback, changedCallback
		ColorPickerFrame:Show()
	end

	local function colorPickerSliderValue(self,newval)
		currColOpt[self.inOptName] = newval / 100
		module:ReloadAllSplits()
		self.tooltipText = ExRT.F.Round(newval)
		self:tooltipReload(self)
	end

	local function colorPickerCheckBoxClick(self)
		if self:GetChecked() then
			currColOpt[self.inOptName] = true
		else
			currColOpt[self.inOptName] = nil
		end
		module:ReloadAllSplits()
	end

	local colorSetupFrameColorsNames_TopText = {L.cd2OtherSetColorFrameTopText,L.cd2OtherSetColorFrameTopBack,L.cd2OtherSetColorFrameTopTimeLine}
	for i=1,3 do
		self.colorSetupFrame["topText"..i] = ELib:Text(self.colorSetupFrame,colorSetupFrameColorsNames_TopText[i],12):Size(50,20):Point(225+(i-1)*40,-15):Center():Color():Shadow()
	end

	local colorSetupFrameColorsNames_Text = {L.cd2OtherSetColorFrameText..":",L.cd2OtherSetColorFrameActive..":",L.cd2OtherSetColorFrameCooldown..":"}
	for j=1,3 do
		for i=1,3 do
			local colorf = ExRT.lib.CreateColorPickButton(self.colorSetupFrame,20,20,nil,240+(i-1)*40,-35-(j-1)*20)
			self.colorSetupFrame[ "color"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j] ] = colorf
			colorf.inOptName = "textureColor"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j]
			colorf:SetScript("OnClick",colorPickerButtonClick)
		end
		self.colorSetupFrame[ "text"..colorSetupFrameColorsNames[j] ] = ELib:Text(self.colorSetupFrame,colorSetupFrameColorsNames_Text[j],12):Size(210,20):Point(10,-35-(j-1)*20):Right():Color():Shadow()
	end

	local checksInOptNames = {"textureClassText","textureClassBackground","textureClassTimeLine"}
	for i=1,3 do
		self.colorSetupFrame[ "colorClass"..colorSetupFrameColorsObjectsNames[i] ] = ELib:Check(self.colorSetupFrame,""):Point(241+(i-1)*40,-117):Size(18,18):OnClick(colorPickerCheckBoxClick)
		self.colorSetupFrame[ "colorClass"..colorSetupFrameColorsObjectsNames[i] ].inOptName = checksInOptNames[i]
	end
	self.colorSetupFrame["textClass"] = ELib:Text(self.colorSetupFrame,L.cd2OtherSetColorFrameClass..":",12):Size(210,20):Point(10,-115):Right():Color():Shadow()

	self.colorSetupFrame.backAlpha:SetScript("OnValueChanged",colorPickerSliderValue)
	self.colorSetupFrame.backCDAlpha:SetScript("OnValueChanged",colorPickerSliderValue)
	self.colorSetupFrame.backCooldownAlpha:SetScript("OnValueChanged",colorPickerSliderValue)

	self.colorSetupFrame.resetButton = ELib:Button(self.colorSetupFrame,L.cd2OtherSetColorFrameReset):Size(160,20):Point("TOP",-81,-265)
	self.colorSetupFrame.softenButton = ELib:Button(self.colorSetupFrame,L.cd2OtherSetColorFrameSoften):Size(160,20):Point("TOP",81,-265)

	self.colorSetupFrame.softenButton:SetScript("OnClick",function()
		local tmpColors = {"R","G","B"}
		for j=1,3 do
			for i=1,3 do
				local maxColor = 0
				for n=1,3 do
					local color = currColOpt[ "textureColor"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j]..tmpColors[n] ] or module.db.colsDefaults[ "textureColor"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j]..tmpColors[n] ]
					maxColor = max(maxColor,color)
				end
				for n=1,3 do
					local color = currColOpt[ "textureColor"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j]..tmpColors[n] ] or module.db.colsDefaults[ "textureColor"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j]..tmpColors[n] ]
					if color < maxColor then
						currColOpt[ "textureColor"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j]..tmpColors[n] ] = color + (maxColor - color) / 2
					end
				end
			end
		end
		module.options.showColorFrame(module.options.colorSetupFrame)
		module:ReloadAllSplits()
	end)

	self.colorSetupFrame.resetButton:SetScript("OnClick",function()
		local tmpColors = {"R","G","B"}
		for j=1,3 do
			for i=1,3 do
				for n=1,3 do
					currColOpt[ "textureColor"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j]..tmpColors[n] ] = nil
				end
			end
		end
		currColOpt.textureAlphaBackground = nil
		currColOpt.textureAlphaTimeLine = nil
		currColOpt.textureAlphaCooldown = nil
		for i=1,3 do
			currColOpt[ checksInOptNames[i] ] = nil
		end
		module.options.showColorFrame(module.options.colorSetupFrame)
		module:ReloadAllSplits()
	end)

	function self:showColorFrame()
		local currColOpt = VMRT.ExCD2.colSet[module.options.optColTabs.selected]
		for j=1,3 do
			for i=1,3 do
				local this = module.options.colorSetupFrame[ "color"..colorSetupFrameColorsObjectsNames[i]..colorSetupFrameColorsNames[j] ]
				this.color:SetColorTexture(currColOpt[this.inOptName.."R"] or module.db.colsDefaults[this.inOptName.."R"],currColOpt[this.inOptName.."G"] or module.db.colsDefaults[this.inOptName.."G"],currColOpt[this.inOptName.."B"] or module.db.colsDefaults[this.inOptName.."B"],1)
			end
		end
		for i=1,3 do
			module.options.colorSetupFrame["colorClass"..colorSetupFrameColorsObjectsNames[i]]:SetChecked( currColOpt[ checksInOptNames[i] ] )
		end

		self.backAlpha:SetValue((currColOpt[self.backAlpha.inOptName] or module.db.colsDefaults[self.backAlpha.inOptName])*100)
		self.backCDAlpha:SetValue((currColOpt[self.backCDAlpha.inOptName] or module.db.colsDefaults[self.backCDAlpha.inOptName])*100)
		self.backCooldownAlpha:SetValue((currColOpt[self.backCooldownAlpha.inOptName] or module.db.colsDefaults[self.backCooldownAlpha.inOptName])*100)
	end

	self.colorSetupFrame:SetScript("OnShow",self.showColorFrame)


	self.optColSet.chkGeneralColorize = ELib:Check(self.optColSet.superTabFrame.tab[3],L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)
	function self.optColSet.chkGeneralColorize:doAlphas()
		ExRT.lib.SetAlphas(VMRT.ExCD2.colSet[module.options.optColTabs.selected].textureGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1,module.options.optColSet.dropDownTexture,module.options.optColSet.chkAnimation,module.options.colorSetupFrame,module.options.optColSet.colorPickerBorder,module.options.optColSet.sliderBorderSize,module.options.optColSet.chkHideSpark,module.options.optColSet.textDDTexture, module.options.optColSet.textDDBorder, module.options.optColSet.chkSmoothAnimation, module.options.optColSet.sliderSmoothAnimationDuration)
	end


	self.optColSet.nowFont = "font"

	self.optColSet.superTabFrame.tab[4].decorationLine = ELib:DecorationLine(self.optColSet.superTabFrame.tab[4],true,"BACKGROUND"):Point("TOPLEFT",self.optColSet.superTabFrame.tab[4],0,-35):Point("BOTTOMRIGHT",self.optColSet.superTabFrame.tab[4],"TOPRIGHT",0,-55)

	self.optColSet.fontsTab = ELib:Tabs(self.optColSet.superTabFrame.tab[4],0,L.cd2ColSetFontPosGeneral,L.cd2ColSetFontPosRight,L.cd2ColSetFontPosCenter,L.cd2ColSetFontPosIcon,L.cd2ColSetFontPosIconCD,L.cd2ColSetTextIconFontTop,L.cd2ColSetTextIconFontCenter,L.cd2ColSetTextIconFontBottom):Size(455,160):Point(0,-55)
	self.optColSet.fontsTab:SetBackdropBorderColor(0,0,0,0)
	self.optColSet.fontsTab:SetBackdropColor(0,0,0,0)
	local function fontsTabButtonClick(self)
		local tabFrame = self.mainFrame
		tabFrame.selected = self.id
		tabFrame.UpdateTabs(tabFrame)

		module.options.optColSet.nowFont = self.fontMark

		local i = module.options.optColTabs.selected
		do
			local FontNameForDropDown = select(3,string.find(VMRT.ExCD2.colSet[i][self.fontMark.."Name"] or module.db.colsDefaults.fontName,"\\([^\\]*)$"))
			module.options.optColSet.dropDownFont:SetText(  (FontNameForDropDown or VMRT.ExCD2.colSet[i][self.fontMark.."Name"] or module.db.colsDefaults.fontName or "?") )
		end
		module.options.optColSet.sliderFont:SetValue(VMRT.ExCD2.colSet[i][self.fontMark.."Size"] or module.db.colsDefaults.fontSize)
		module.options.optColSet.chkFontOutline:SetChecked(VMRT.ExCD2.colSet[i][self.fontMark.."Outline"])
		module.options.optColSet.chkFontShadow:SetChecked(VMRT.ExCD2.colSet[i][self.fontMark.."Shadow"])
	end
	for i=1,8 do
		self.optColSet.fontsTab.tabs[i].button:SetScript("OnClick",fontsTabButtonClick)
	end
	local fontOtherAvailableTable = {"Left","Right","Center","Icon","IconCD","IconTop","IconMid","IconBot"}
	local function getIconFontModeOn()
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		if saved and saved.ATF then return false end
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		if not isGeneralTab and saved and saved.textGeneral then
			local genCol = VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[module.db.maxColumns + 1]
			return genCol and genCol.iconFontMode
		end
		return saved and saved.iconFontMode
	end
	function self.fontOtherAvailable(isAvailable)
		local iconFontOn = getIconFontModeOn()
		local visible
		if isAvailable then
			if iconFontOn then
				visible = {6,7,8}
			else
				visible = {1,2,3,4,5}
				self.optColSet.fontsTab.tabs[1].button:SetText(L.cd2ColSetFontPosLeft)
			end
			for i=1,8 do
				self.optColSet.fontsTab.tabs[i].button.fontMark = "font"..fontOtherAvailableTable[i]
			end
		else
			visible = {1}
			self.optColSet.fontsTab.tabs[1].button:SetText(L.cd2ColSetFontPosGeneral)
			self.optColSet.fontsTab.tabs[1].button.fontMark = "font"
		end
		local visibleSet = {}
		for j=1,#visible do visibleSet[visible[j]] = true end
		for i=1,8 do
			if visibleSet[i] then self.optColSet.fontsTab.tabs[i].button:Show() else self.optColSet.fontsTab.tabs[i].button:Hide() end
		end
		for j=1,#visible do
			local btn = self.optColSet.fontsTab.tabs[visible[j]].button
			btn:ClearAllPoints()
			if j == 1 then
				btn:SetPoint("TOPLEFT", self.optColSet.fontsTab, 10, 24)
			else
				btn:SetPoint("LEFT", self.optColSet.fontsTab.tabs[visible[j-1]].button, "RIGHT", 6, 0)
			end
			local fs = btn:GetFontString()
			local w = fs and fs:GetStringWidth() or 0
			self.optColSet.fontsTab.resizeFunc(btn, 0, nil, nil, w, w)
		end
		if self.optColSet.fontLeftXSlider then
			if isAvailable then
				self.optColSet.fontLeftXSlider:Show()
				self.optColSet.fontLeftYSlider:Show()
			else
				self.optColSet.fontLeftXSlider:Hide()
				self.optColSet.fontLeftYSlider:Hide()
			end
		end
		local firstBtn = self.optColSet.fontsTab.tabs[visible[1]].button
		if not visibleSet[self.optColSet.fontsTab.selected or 1] then
			fontsTabButtonClick(firstBtn)
		else
			fontsTabButtonClick(self.optColSet.fontsTab.tabs[self.optColSet.fontsTab.selected].button)
		end
	end

	self.optColSet.chkFontOtherAvailable = ELib:Check(self.optColSet.superTabFrame.tab[4],L.cd2ColSetFontOtherAvailable):Point(10,-260):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.fontOtherAvailable = true
		else
			currColOpt.fontOtherAvailable = nil
		end
		module:ReloadAllSplits()
		if module.options.optColSet and module.options.optColSet.applyIconFontModeLayout then
			module.options.optColSet:applyIconFontModeLayout()
		else
			module.options.fontOtherAvailable( self:GetChecked() )
		end
	end)

	self.optColSet.sliderFont = ELib:Slider(self.optColSet.fontsTab,L.cd2OtherSetFontSize):Size(400):Point("TOP",0,-60):Range(8,72):OnChange(function(self,event)
		event = event - event%1
		currColOpt[module.options.optColSet.nowFont.."Size"] = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.textDDFont = ELib:Text(self.optColSet.fontsTab,L.cd2OtherSetFont..":"):Size(200,20):Point(10,-15)

	local function dropDownFontButtonClick(self,arg1,arg2)
		ELib:DropDownClose()
		currColOpt[module.options.optColSet.nowFont.."Name"] = arg1
		module:ReloadAllSplits()
		module.options.optColSet.dropDownFont:SetText(arg2 or select(3,string.find(arg1,"\\([^\\]*)$")) or arg1)
	end

	self.optColSet.dropDownFont = ELib:DropDown(self.optColSet.fontsTab,350,10):Size(200):Point(180,-15)
	do
		local fontMedia = ExRT.F.GetSharedMediaList("font", ExRT.F.fontList)
		for i = 1, #fontMedia do
			local entry = fontMedia[i]
			self.optColSet.dropDownFont.List[i] = {
				text = entry.name,
				arg1 = entry.path,
				arg2 = entry.name,
				func = dropDownFontButtonClick,
				font = entry.path,
				justifyH = "CENTER",
			}
		end
	end

	self.optColSet.chkFontOutline = ELib:Check(self.optColSet.fontsTab,L.cd2OtherSetOutline):Point(10,-95):OnClick(function(self)
		if self:GetChecked() then
			currColOpt[module.options.optColSet.nowFont.."Outline"] = true
		else
			currColOpt[module.options.optColSet.nowFont.."Outline"] = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkFontShadow = ELib:Check(self.optColSet.fontsTab,L.cd2OtherSetFontShadow):Point(10,-120):OnClick(function(self)
		if self:GetChecked() then
			currColOpt[module.options.optColSet.nowFont.."Shadow"] = true
		else
			currColOpt[module.options.optColSet.nowFont.."Shadow"] = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkGeneralFont = ELib:Check(self.optColSet.superTabFrame.tab[4],L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)
	function self.optColSet.chkGeneralFont:doAlphas()
		local a = VMRT.ExCD2.colSet[module.options.optColTabs.selected].fontGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1
		ExRT.lib.SetAlphas(a,module.options.optColSet.dropDownFont,module.options.optColSet.sliderFont,module.options.optColSet.chkFontOutline,module.options.optColSet.chkFontShadow,module.options.optColSet.chkFontOtherAvailable,
			module.options.optColSet.fontLeftXSlider,module.options.optColSet.fontLeftYSlider,
			module.options.optColSet.fontRightXSlider,module.options.optColSet.fontRightYSlider,
			module.options.optColSet.fontCenterXSlider,module.options.optColSet.fontCenterYSlider,
			module.options.optColSet.fontIconXSlider,module.options.optColSet.fontIconYSlider,
			module.options.optColSet.fontIconCDXSlider,module.options.optColSet.fontIconCDYSlider)
	end


	self.optColSet.textLeftTemText = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextLeft..":"):Size(200,20):Point(10,-40)
	self.optColSet.textLeftTemEdit = ELib:Edit(self.optColSet.superTabFrame.tab[5]):Size(220,20):Point(180,-40):OnChange(function(self,isUser)
		if isUser then
			currColOpt.textTemplateLeft = self:GetText()
			module:ReloadAllSplits()
		end
	end)

	self.optColSet.textRightTemText = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextRight..":"):Size(200,20):Point(10,-65)
	self.optColSet.textRightTemEdit = ELib:Edit(self.optColSet.superTabFrame.tab[5]):Size(220,20):Point(180,-65):OnChange(function(self,isUser)
		if isUser then
			currColOpt.textTemplateRight = self:GetText()
			module:ReloadAllSplits()
		end
	end)

	self.optColSet.textCenterTemText = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextCenter..":"):Size(200,20):Point(10,-90)
	self.optColSet.textCenterTemEdit = ELib:Edit(self.optColSet.superTabFrame.tab[5]):Size(220,20):Point(180,-90):OnChange(function(self,isUser)
		if isUser then
			currColOpt.textTemplateCenter = self:GetText()
			module:ReloadAllSplits()
		end
	end)

	self.optColSet.textAllTemplates = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextTooltip,11):Size(450,200):Point(10,-115):Top():Color()

	self.optColSet.textResetButton = ELib:Button(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextReset):Size(340,20):Point("TOP",0,-225):OnClick(function(self)
		currColOpt.textTemplateLeft = nil
		currColOpt.textTemplateRight = nil
		currColOpt.textTemplateCenter = nil
		currColOpt.iconFontTopTemplate = nil
		currColOpt.iconFontTopAnchor = nil
		currColOpt.iconFontTopX = nil
		currColOpt.iconFontTopY = nil
		currColOpt.iconFontTopPos = nil
		currColOpt.iconFontTopGrowth = nil
		currColOpt.iconFontCenterTemplate = nil
		currColOpt.iconFontCenterAnchor = nil
		currColOpt.iconFontCenterX = nil
		currColOpt.iconFontCenterY = nil
		currColOpt.iconFontCenterPos = nil
		currColOpt.iconFontCenterGrowth = nil
		currColOpt.iconFontBottomTemplate = nil
		currColOpt.iconFontBottomAnchor = nil
		currColOpt.iconFontBottomX = nil
		currColOpt.iconFontBottomY = nil
		currColOpt.iconFontBottomPos = nil
		currColOpt.iconFontBottomGrowth = nil
		module:ReloadAllSplits()
		local d = module.db.colsDefaults
		module.options.optColSet.textLeftTemEdit:SetText(d.textTemplateLeft)
		module.options.optColSet.textRightTemEdit:SetText(d.textTemplateRight)
		module.options.optColSet.textCenterTemEdit:SetText(d.textTemplateCenter)
		module.options.optColSet.iconFontTopEdit:SetText(d.iconFontTopTemplate)
		module.options.optColSet.iconFontTopXSlider:SetValue(d.iconFontTopX)
		module.options.optColSet.iconFontTopXSlider:refreshLabel()
		module.options.optColSet.iconFontTopYSlider:SetValue(d.iconFontTopY)
		module.options.optColSet.iconFontTopYSlider:refreshLabel()
		module.options.optColSet.iconFontCenterEdit:SetText(d.iconFontCenterTemplate)
		module.options.optColSet.iconFontCenterXSlider:SetValue(d.iconFontCenterX)
		module.options.optColSet.iconFontCenterXSlider:refreshLabel()
		module.options.optColSet.iconFontCenterYSlider:SetValue(d.iconFontCenterY)
		module.options.optColSet.iconFontCenterYSlider:refreshLabel()
		module.options.optColSet.iconFontBottomEdit:SetText(d.iconFontBottomTemplate)
		module.options.optColSet.iconFontBottomXSlider:SetValue(d.iconFontBottomX)
		module.options.optColSet.iconFontBottomXSlider:refreshLabel()
		module.options.optColSet.iconFontBottomYSlider:SetValue(d.iconFontBottomY)
		module.options.optColSet.iconFontBottomYSlider:refreshLabel()
		if module.options.optColSet.iconFontTopWidget    then module.options.optColSet.iconFontTopWidget:refreshChecks();    module.options.optColSet.iconFontTopWidget:refreshGrowthEnabled()    end
		if module.options.optColSet.iconFontCenterWidget then module.options.optColSet.iconFontCenterWidget:refreshChecks(); module.options.optColSet.iconFontCenterWidget:refreshGrowthEnabled() end
		if module.options.optColSet.iconFontBottomWidget then module.options.optColSet.iconFontBottomWidget:refreshChecks(); module.options.optColSet.iconFontBottomWidget:refreshGrowthEnabled() end
		currColOpt.fontLeftX = nil
		currColOpt.fontLeftY = nil
		currColOpt.fontRightX = nil
		currColOpt.fontRightY = nil
		currColOpt.fontCenterX = nil
		currColOpt.fontCenterY = nil
		currColOpt.fontIconX = nil
		currColOpt.fontIconY = nil
		currColOpt.fontIconCDX = nil
		currColOpt.fontIconCDY = nil
		module.options.optColSet.fontLeftXSlider:SetValue(0)
		module.options.optColSet.fontLeftXSlider:refreshLabel()
		module.options.optColSet.fontLeftYSlider:SetValue(0)
		module.options.optColSet.fontLeftYSlider:refreshLabel()
		module.options.optColSet.fontRightXSlider:SetValue(0)
		module.options.optColSet.fontRightXSlider:refreshLabel()
		module.options.optColSet.fontRightYSlider:SetValue(0)
		module.options.optColSet.fontRightYSlider:refreshLabel()
		module.options.optColSet.fontCenterXSlider:SetValue(0)
		module.options.optColSet.fontCenterXSlider:refreshLabel()
		module.options.optColSet.fontCenterYSlider:SetValue(0)
		module.options.optColSet.fontCenterYSlider:refreshLabel()
		module.options.optColSet.fontIconXSlider:SetValue(0)
		module.options.optColSet.fontIconXSlider:refreshLabel()
		module.options.optColSet.fontIconYSlider:SetValue(0)
		module.options.optColSet.fontIconYSlider:refreshLabel()
		module.options.optColSet.fontIconCDXSlider:SetValue(0)
		module.options.optColSet.fontIconCDXSlider:refreshLabel()
		module.options.optColSet.fontIconCDYSlider:SetValue(0)
		module.options.optColSet.fontIconCDYSlider:refreshLabel()
	end)

	self.optColSet.chkIconName = ELib:Check(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextIconName):Point(10,-250):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.textIconName = true
		else
			currColOpt.textIconName = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderIconNameChars = ELib:Slider(self.optColSet.superTabFrame.tab[5],L.cd2ColSetMaxLength):Size(140):Point("TOP",self.optColSet.chkIconName,0,-8):Point("LEFT",self.optColSet.chkIconName.text,"RIGHT",20,0):Range(1,50):OnChange(function(self,event)
		event = event - event%1
		currColOpt.textIconNameChars = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)
	self.optColSet.sliderIconNameChars.Low:SetText("")
	self.optColSet.sliderIconNameChars.High:SetText("")


	self.optColSet.dropDownIconCDStyle = ELib:DropDown(self.optColSet.superTabFrame.tab[5],350):Size(230):Point("TOPLEFT",self.optColSet.chkIconName,170,-30)
	self.optColSet.textdropDownIconCDStyle = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetCDTimeStyle..":",11):Size(200,20):Point("TOPLEFT",self.optColSet.chkIconName,0,-30)
	self.optColSet.dropDownIconCDStyle.Styles = {
		"<10: |cff00ff009|r - <60: |cff00ff0046|r - 60+: |cff00ff00"..SecondsToTime(95,true).."|r - 120+:|cff00ff00"..SecondsToTime(125,true).."|r",
		"<10: |cff00ff009|r - <60: |cff00ff0046|r - 60+: |cff00ff00"..SecondsToTime(95+60,true).."|r - 120+:|cff00ff00"..SecondsToTime(125+60,true).."|r",
		"<10: |cff00ff008.5|r - <60: |cff00ff0046|r - 60+: |cff00ff00"..SecondsToTime(95,true).."|r - 120+:|cff00ff00"..SecondsToTime(125,true).."|r",
		"<10: |cff00ff008.5|r - <60: |cff00ff0046|r - 60+: |cff00ff00"..SecondsToTime(95+60,true).."|r - 120+:|cff00ff00"..SecondsToTime(125+60,true).."|r",
		"<10: |cff00ff009|r - <60: |cff00ff0046|r - 60+: |cff00ff001:35|r - 120+:|cff00ff002:05|r",
		"<10: |cff00ff008.5|r - <60: |cff00ff0046|r - 60+: |cff00ff001:35|r - 120+:|cff00ff002:05|r",
		"<10: |cff00ff009|r - <60: |cff00ff0046|r - 60+: |cff00ff001m|r - 120+:|cff00ff002m|r",
		"<10: |cff00ff009|r - <60: |cff00ff0046|r - 60+: |cff00ff002m|r - 120+:|cff00ff003m|r",
		"<10: |cff00ff008.5|r - <60: |cff00ff0046|r - 60+: |cff00ff001m|r - 120+:|cff00ff002m|r",
		"<10: |cff00ff008.5|r - <60: |cff00ff0046|r - 60+: |cff00ff002m|r - 120+:|cff00ff003m|r",
		"<10: |cff00ff008|r - <100: |cff00ff0046|r - 100+: |cff00ff001m|r - 120+:|cff00ff002m|r",
	}
	for i=1,#self.optColSet.dropDownIconCDStyle.Styles do
		self.optColSet.dropDownIconCDStyle.List[i] = {
			text = self.optColSet.dropDownIconCDStyle.Styles[i],
			arg1 = i,
			arg2 = self.optColSet.dropDownIconCDStyle.Styles[i],
			func = function (self,arg,arg2)
				ELib:DropDownClose()
				currColOpt.textIconCDStyle = arg
				module:ReloadAllSplits()
				self:GetParent().parent:SetText(arg2)
			end
		}
	end

	self.optColSet.chkShowTargetName = ELib:Check(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextShowTargetName):Point("TOPLEFT",self.optColSet.chkIconName,0,-60):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.textShowTargetName = true
		else
			currColOpt.textShowTargetName = nil
		end
		module:ReloadAllSplits()
	end)


	local function makeOffsetSlider(parent, savedKeyPrefix, axis)
		local baseLabel = (axis == "X") and L.cd2OffsetX or L.cd2OffsetY
		local s = ELib:Slider(parent,baseLabel):Size(180):Range(-50,50):OnChange(function(self,event)
			event = event - event%1
			currColOpt[savedKeyPrefix..axis] = event
			module:ReloadAllSplits()
			self.tooltipText = event
			self.text:SetText(baseLabel..": "..event)
			self:tooltipReload(self)
		end)
		s.Low:SetText("-50")
		s.High:SetText("50")
		s.baseLabel = baseLabel
		s.refreshLabel = function(self)
			local v = self:GetValue() or 0
			v = v - v%1
			self.text:SetText(self.baseLabel..": "..v)
		end
		return s
	end

	local rowY = {Top = -40, Center = -65, Bottom = -90}

	self.optColSet.iconFontTopText = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextIconFontTop..":"):Size(200,20):Point(10,rowY.Top)
	self.optColSet.iconFontTopEdit = ELib:Edit(self.optColSet.superTabFrame.tab[5]):Size(220,20):Point(180,rowY.Top):OnChange(function(self,isUser)
		if isUser then
			currColOpt.iconFontTopTemplate = self:GetText()
			module:ReloadAllSplits()
		end
	end)

	self.optColSet.iconFontCenterText = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextIconFontCenter..":"):Size(200,20):Point(10,rowY.Center)
	self.optColSet.iconFontCenterEdit = ELib:Edit(self.optColSet.superTabFrame.tab[5]):Size(220,20):Point(180,rowY.Center):OnChange(function(self,isUser)
		if isUser then
			currColOpt.iconFontCenterTemplate = self:GetText()
			module:ReloadAllSplits()
		end
	end)

	self.optColSet.iconFontBottomText = ELib:Text(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextIconFontBottom..":"):Size(200,20):Point(10,rowY.Bottom)
	self.optColSet.iconFontBottomEdit = ELib:Edit(self.optColSet.superTabFrame.tab[5]):Size(220,20):Point(180,rowY.Bottom):OnChange(function(self,isUser)
		if isUser then
			currColOpt.iconFontBottomTemplate = self:GetText()
			module:ReloadAllSplits()
		end
	end)

	local iconFontPosLayout = {
		[1]  = {"TOPLEFT",     "TOPLEFT",      4, -4 },
		[2]  = {"TOP",         "TOP",          0, -4 },
		[3]  = {"TOPRIGHT",    "TOPRIGHT",    -4, -4 },
		[4]  = {"LEFT",        "LEFT",         4,  0 },
		[5]  = {"CENTER",      "CENTER",       0,  0 },
		[6]  = {"RIGHT",       "RIGHT",       -4,  0 },
		[7]  = {"BOTTOMLEFT",  "BOTTOMLEFT",   4,  4 },
		[8]  = {"BOTTOM",      "BOTTOM",       0,  4 },
		[9]  = {"BOTTOMRIGHT", "BOTTOMRIGHT", -4,  4 },
		[10] = {"BOTTOMRIGHT", "BOTTOMLEFT",  -2,  2 },
		[11] = {"TOPRIGHT",    "TOPLEFT",     -2, -2 },
		[12] = {"BOTTOMLEFT",  "TOPLEFT",      2,  2 },
		[13] = {"BOTTOMRIGHT", "TOPRIGHT",    -2,  2 },
		[14] = {"TOPLEFT",     "TOPRIGHT",     2, -2 },
		[15] = {"BOTTOMLEFT",  "BOTTOMRIGHT",  2,  2 },
		[16] = {"TOPRIGHT",    "BOTTOMRIGHT", -2, -2 },
		[17] = {"TOPLEFT",     "BOTTOMLEFT",   2, -2 },
		[18] = {"BOTTOM",      "TOP",          0,  2 },
		[19] = {"LEFT",        "RIGHT",        2,  0 },
		[20] = {"TOP",         "BOTTOM",       0, -2 },
		[21] = {"RIGHT",       "LEFT",        -2,  0 },
	}

	local function makeIconFontPositionWidget(parent, slot)
		local widget = {}
		widget.label = ELib:Text(parent, L.cd2ColSetIconPosition..":"):Size(70,20):Point(10,-180)

		widget.preview = ELib:Frame(parent):Point("TOPLEFT",80,-185):Size(80,50)
		ELib:Texture(widget.preview,.8,.8,.8,.8,"BACKGROUND"):Point('x')

		widget.radios = {}
		for posID = 1, 21 do
			local lay = iconFontPosLayout[posID]
			local r = ELib:Radio(parent)
			r:SetSize(12, 12)
			if r.text then r.text:SetText("") end
			r:SetHitRectInsets(-1,-1,-1,-1)
			r:ClearAllPoints()
			r:SetPoint(lay[1], widget.preview, lay[2], lay[3], lay[4])
			r.posID = posID
			r:SetScript("OnClick", function(self)
				currColOpt["iconFont"..slot.."Pos"] = self.posID
				currColOpt["iconFont"..slot.."Anchor"] = nil
				local info = module.db.colsIconFontPos[self.posID]
				if info and info[3] then
					currColOpt["iconFont"..slot.."Growth"] = nil
				end
				widget:refreshChecks()
				widget:refreshGrowthEnabled()
				module:ReloadAllSplits()
			end)
			r.posLabel = posID
			widget.radios[posID] = r
		end

		widget.growthLabel = ELib:Text(parent, L.cd2ColSetIconGrowth..":"):Size(60,20):Point(220,-180)
		widget.growthRadios = {}
		local function makeGrowthRadio(growthValue, anchorY, drawText)
			local r = ELib:Radio(parent, drawText)
			r:SetSize(14, 14)
			r:ClearAllPoints()
			r:SetPoint("TOPLEFT", widget.growthLabel, "BOTTOMLEFT", 8, anchorY)
			r.growthValue = growthValue
			r:SetScript("OnClick", function(self)
				currColOpt["iconFont"..slot.."Growth"] = self.growthValue
				widget:refreshGrowthChecks()
				module:ReloadAllSplits()
			end)
			return r
		end
		widget.growthRadios[1] = makeGrowthRadio(1,  -4, "  --> ")
		widget.growthRadios[2] = makeGrowthRadio(2, -24, "  <-- ")

		widget.xSlider = makeOffsetSlider(parent, "iconFont"..slot, "X"):Point(10, -260)
		widget.ySlider = makeOffsetSlider(parent, "iconFont"..slot, "Y"):Point(220, -260)

		function widget:refreshChecks()
			local sel = module.options.optColTabs and module.options.optColTabs.selected
			local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
			local pos
			if saved then
				pos = module.db.ResolveIconFontPos(slot, saved["iconFont"..slot.."Pos"], saved["iconFont"..slot.."Anchor"])
			else
				pos = module.db.colsDefaults["iconFont"..slot.."Pos"]
			end
			for posID = 1, 21 do
				self.radios[posID]:SetChecked(posID == pos)
			end
		end
		function widget:refreshGrowthChecks()
			local sel = module.options.optColTabs and module.options.optColTabs.selected
			local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
			local pos = saved and saved["iconFont"..slot.."Pos"] or module.db.colsDefaults["iconFont"..slot.."Pos"]
			local info = module.db.colsIconFontPos[pos]
			local growth = saved and saved["iconFont"..slot.."Growth"]
			if not growth or growth == 0 then
				growth = info and info[4] or 0
			end
			self.growthRadios[1]:SetChecked(growth == 1)
			self.growthRadios[2]:SetChecked(growth == 2)
		end
		function widget:refreshGrowthEnabled()
			local sel = module.options.optColTabs and module.options.optColTabs.selected
			local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
			local pos = saved and saved["iconFont"..slot.."Pos"] or module.db.colsDefaults["iconFont"..slot.."Pos"]
			local info = module.db.colsIconFontPos[pos]
			local enabled = info and not info[3]
			self.growthRadios[1]:SetAlpha(enabled and 1 or 0.3)
			self.growthRadios[2]:SetAlpha(enabled and 1 or 0.3)
			self.growthRadios[1]:EnableMouse(enabled and true or false)
			self.growthRadios[2]:EnableMouse(enabled and true or false)
			self:refreshGrowthChecks()
		end

		return widget
	end

	local function makeOffsetRow(parent, savedKeyPrefix)
		local sx = makeOffsetSlider(parent, savedKeyPrefix, "X"):Point(10, -180)
		local sy = makeOffsetSlider(parent, savedKeyPrefix, "Y"):Point(220, -180)
		return sx, sy
	end

	self.optColSet.iconFontTopWidget = makeIconFontPositionWidget(self.optColSet.fontsTab.tabs[6], "Top")
	self.optColSet.iconFontCenterWidget = makeIconFontPositionWidget(self.optColSet.fontsTab.tabs[7], "Center")
	self.optColSet.iconFontBottomWidget = makeIconFontPositionWidget(self.optColSet.fontsTab.tabs[8], "Bottom")
	self.optColSet.iconFontTopXSlider = self.optColSet.iconFontTopWidget.xSlider
	self.optColSet.iconFontTopYSlider = self.optColSet.iconFontTopWidget.ySlider
	self.optColSet.iconFontCenterXSlider = self.optColSet.iconFontCenterWidget.xSlider
	self.optColSet.iconFontCenterYSlider = self.optColSet.iconFontCenterWidget.ySlider
	self.optColSet.iconFontBottomXSlider = self.optColSet.iconFontBottomWidget.xSlider
	self.optColSet.iconFontBottomYSlider = self.optColSet.iconFontBottomWidget.ySlider

	self.optColSet.fontLeftXSlider, self.optColSet.fontLeftYSlider = makeOffsetRow(self.optColSet.fontsTab.tabs[1], "fontLeft")
	self.optColSet.fontRightXSlider, self.optColSet.fontRightYSlider = makeOffsetRow(self.optColSet.fontsTab.tabs[2], "fontRight")
	self.optColSet.fontCenterXSlider, self.optColSet.fontCenterYSlider = makeOffsetRow(self.optColSet.fontsTab.tabs[3], "fontCenter")
	self.optColSet.fontIconXSlider, self.optColSet.fontIconYSlider = makeOffsetRow(self.optColSet.fontsTab.tabs[4], "fontIcon")
	self.optColSet.fontIconCDXSlider, self.optColSet.fontIconCDYSlider = makeOffsetRow(self.optColSet.fontsTab.tabs[5], "fontIconCD")

	self.optColSet.iconFontTopText:Hide()
	self.optColSet.iconFontTopEdit:Hide()
	self.optColSet.iconFontCenterText:Hide()
	self.optColSet.iconFontCenterEdit:Hide()
	self.optColSet.iconFontBottomText:Hide()
	self.optColSet.iconFontBottomEdit:Hide()

	self.optColSet.chkIconFontMode = ELib:Check(self.optColSet.superTabFrame.tab[5],L.cd2ColSetTextIconFontMode):Point("TOPLEFT",10,-12):OnClick(function(self)
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		if saved and saved.ATF then
			self:SetChecked(false)
			return
		end
		if not isGeneralTab and saved and saved.textGeneral then
			local genCol = VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[module.db.maxColumns + 1]
			self:SetChecked(genCol and genCol.iconFontMode or false)
			module.options.optColSet:applyIconFontModeLayout()
			return
		end
		if self:GetChecked() then
			currColOpt.iconFontMode = true
			if currColOpt.iconFontTopTemplate == nil then
				currColOpt.iconFontTopTemplate = ""
			end
			if currColOpt.iconFontCenterTemplate == nil then
				currColOpt.iconFontCenterTemplate = "%time%"
			end
			if currColOpt.iconFontBottomTemplate == nil then
				currColOpt.iconFontBottomTemplate = "%name%"
			end
			module.options.optColSet.iconFontTopEdit:SetText(currColOpt.iconFontTopTemplate)
			module.options.optColSet.iconFontCenterEdit:SetText(currColOpt.iconFontCenterTemplate)
			module.options.optColSet.iconFontBottomEdit:SetText(currColOpt.iconFontBottomTemplate)
		else
			currColOpt.iconFontMode = nil
		end
		module.options.optColSet:applyIconFontModeLayout()
		module:ReloadAllSplits()
	end)

	function self.optColSet:applyIconFontModeLayout()
		local sel = module.options.optColTabs and module.options.optColTabs.selected
		local saved = sel and VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[sel]
		local isGeneralTab = sel == (module.db.maxColumns + 1)
		local genCol = VMRT.ExCD2 and VMRT.ExCD2.colSet and VMRT.ExCD2.colSet[module.db.maxColumns + 1]
		local source = saved
		if not isGeneralTab and saved and saved.textGeneral and genCol then
			source = genCol
		end
		local atf = saved and saved.ATF
		local on = (source and source.iconFontMode or (not source and currColOpt and currColOpt.iconFontMode)) and not atf
		local barCtrls = {self.textLeftTemText,self.textLeftTemEdit,self.textRightTemText,self.textRightTemEdit,self.textCenterTemText,self.textCenterTemEdit}
		local iconCtrls = {
			self.iconFontTopText,self.iconFontTopEdit,
			self.iconFontCenterText,self.iconFontCenterEdit,
			self.iconFontBottomText,self.iconFontBottomEdit,
		}
		for i=1,#barCtrls do if on then barCtrls[i]:Hide() else barCtrls[i]:Show() end end
		for i=1,#iconCtrls do if on then iconCtrls[i]:Show() else iconCtrls[i]:Hide() end end
		if on then
			self.chkIconName.text:SetText(L.cd2ColSetTextIconCrop)
		else
			self.chkIconName.text:SetText(L.cd2ColSetTextIconName)
		end

		self.textAllTemplates:ClearAllPoints()
		self.textAllTemplates:SetPoint("TOPLEFT",self.superTabFrame.tab[5],"TOPLEFT",10,-115)
		self.textResetButton:ClearAllPoints()
		self.textResetButton:SetPoint("TOP",self.superTabFrame.tab[5],"TOP",0,-225)
		self.chkIconName:ClearAllPoints()
		self.chkIconName:SetPoint("TOPLEFT",self.superTabFrame.tab[5],"TOPLEFT",10,-250)

		if self.chkShowTargetName then
			if on then self.chkShowTargetName:Hide() else self.chkShowTargetName:Show() end
		end

		if ExRT and ExRT.lib and ExRT.lib.SetAlphas then
			ExRT.lib.SetAlphas(on and 0.5 or 1, self.chkCooldownTextDef, self.chkCooldownExRTNumbers, self.chkCooldownHideNumbers)
		end
		if on then
			self.chkCooldownTextDef.tooltipText = L.cd2ExtIconFontLockTooltip
			self.chkCooldownExRTNumbers.tooltipText = L.cd2ExtIconFontLockTooltip
			self.chkCooldownHideNumbers.tooltipText = L.cd2ExtIconFontLockTooltip
		else
			self.chkCooldownTextDef.tooltipText = L.cd2ColSetCDTimeDefTooltip
			self.chkCooldownExRTNumbers.tooltipText = L.cd2ColSetCDTimeExRTTooltip
			self.chkCooldownHideNumbers.tooltipText = L.BattleResHideTimeTooltip
		end
		if self.chkCooldownTextUpdate then
			self:chkCooldownTextUpdate()
		end

		local fontsTabBaseHeight = 215
		local fontsTabExtendedHeight = 295
		local chkFontOtherBaseY = -260
		local chkFontOtherExtendedY = -360
		local fOAvail = self.chkFontOtherAvailable and self.chkFontOtherAvailable:GetChecked()
		if on and fOAvail then
			if self.fontsTab and self.fontsTab.SetSize then self.fontsTab:SetSize(455, fontsTabExtendedHeight) end
			if self.chkFontOtherAvailable then
				self.chkFontOtherAvailable:ClearAllPoints()
				self.chkFontOtherAvailable:SetPoint("TOPLEFT", self.superTabFrame.tab[4], "TOPLEFT", 10, chkFontOtherExtendedY)
			end
		else
			if self.fontsTab and self.fontsTab.SetSize then self.fontsTab:SetSize(455, fontsTabBaseHeight) end
			if self.chkFontOtherAvailable then
				self.chkFontOtherAvailable:ClearAllPoints()
				self.chkFontOtherAvailable:SetPoint("TOPLEFT", self.superTabFrame.tab[4], "TOPLEFT", 10, chkFontOtherBaseY)
			end
		end

		if module.options.fontOtherAvailable and self.chkFontOtherAvailable then
			module.options.fontOtherAvailable( self.chkFontOtherAvailable:GetChecked() )
		end
	end

	self.optColSet.chkGeneralText = ELib:Check(self.optColSet.superTabFrame.tab[5],L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)
	function self.optColSet.chkGeneralText:doAlphas()
		ExRT.lib.SetAlphas(VMRT.ExCD2.colSet[module.options.optColTabs.selected].textGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1,module.options.optColSet.textLeftTemEdit,module.options.optColSet.textRightTemEdit,module.options.optColSet.textCenterTemEdit,module.options.optColSet.chkIconName,module.options.optColSet.textAllTemplates,module.options.optColSet.textLeftTemText,module.options.optColSet.textRightTemText,module.options.optColSet.textCenterTemText,module.options.optColSet.textResetButton,module.options.optColSet.sliderIconNameChars,module.options.optColSet.dropDownIconCDStyle,module.options.optColSet.textdropDownIconCDStyle,module.options.optColSet.chkShowTargetName,
			module.options.optColSet.chkIconFontMode,
			module.options.optColSet.iconFontTopText,module.options.optColSet.iconFontTopEdit,module.options.optColSet.iconFontTopXSlider,module.options.optColSet.iconFontTopYSlider,
			module.options.optColSet.iconFontCenterText,module.options.optColSet.iconFontCenterEdit,module.options.optColSet.iconFontCenterXSlider,module.options.optColSet.iconFontCenterYSlider,
			module.options.optColSet.iconFontBottomText,module.options.optColSet.iconFontBottomEdit,module.options.optColSet.iconFontBottomXSlider,module.options.optColSet.iconFontBottomYSlider)
	end


	self.optColSet.superTabFrame.tab[6].scroll = ELib:ScrollFrame(self.optColSet.superTabFrame.tab[6]):Point("TOP"):Size(456,444):Height(535)
	ELib:Border(self.optColSet.superTabFrame.tab[6].scroll,0)
	self.optColSet.col6scroll = self.optColSet.superTabFrame.tab[6].scroll.C
	self.optColSet.col6scroll:SetWidth(456 - 16)

	self.optColSet.chkShowOnlyOnCD = ELib:Check(self.optColSet.col6scroll,L.cd2OtherSetOnlyOnCD):Point(10,-30):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsShownOnCD = true
		else
			currColOpt.methodsShownOnCD = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkBotToTop = ELib:Check(self.optColSet.col6scroll,L.cd2ColSetBotToTop):Point(10,-55):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.frameAnchorBottom = true
		else
			currColOpt.frameAnchorBottom = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkRightToLeft = ELib:Check(self.optColSet.col6scroll,L.cd2ColSetRightToLeft):Point(10,-80):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.frameAnchorRightToLeft = true
		else
			currColOpt.frameAnchorRightToLeft = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.textStyleAnimation = ELib:Text(self.optColSet.col6scroll,L.cd2OtherSetStyleAnimation..":",11):Size(200,20):Point(10,-105)
	self.optColSet.dropDownStyleAnimation = ELib:DropDown(self.optColSet.col6scroll,205,2):Size(220):Point(180,-105)
	self.optColSet.dropDownStyleAnimation.Styles = {L.cd2OtherSetStyleAnimation1,L.cd2OtherSetStyleAnimation2}
	for i=1,#self.optColSet.dropDownStyleAnimation.Styles do
		self.optColSet.dropDownStyleAnimation.List[i] = {
			text = self.optColSet.dropDownStyleAnimation.Styles[i],
			arg1 = i,
			func = function (self,arg)
				ELib:DropDownClose()
				currColOpt.methodsStyleAnimation = arg
				module:ReloadAllSplits()
				self:GetParent().parent:SetText(module.options.optColSet.dropDownStyleAnimation.Styles[arg])
			end
		}
	end

	self.optColSet.textTimeLineAnimation = ELib:Text(self.optColSet.col6scroll,L.cd2OtherSetTimeLineAnimation..":",11):Size(200,20):Point(10,-130)
	self.optColSet.dropDownTimeLineAnimation = ELib:DropDown(self.optColSet.col6scroll,205,2):Size(220):Point(180,-130)
	self.optColSet.dropDownTimeLineAnimation.Styles = {L.cd2OtherSetTimeLineAnimation1,L.cd2OtherSetTimeLineAnimation2}
	for i=1,#self.optColSet.dropDownTimeLineAnimation.Styles do
		self.optColSet.dropDownTimeLineAnimation.List[i] = {
			text = self.optColSet.dropDownTimeLineAnimation.Styles[i],
			arg1 = i,
			func = function (self,arg)
				ELib:DropDownClose()
				currColOpt.methodsTimeLineAnimation = arg
				module:ReloadAllSplits()
				self:GetParent().parent:SetText(module.options.optColSet.dropDownTimeLineAnimation.Styles[arg])
			end
		}
	end

	self.optColSet.chkIconTooltip = ELib:Check(self.optColSet.col6scroll,L.cd2OtherSetIconToolip):Point(10,-155):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsIconTooltip = true
		else
			currColOpt.methodsIconTooltip = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkLineClick = ELib:Check(self.optColSet.col6scroll,L.cd2OtherSetLineClick):Point(10,-180):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsLineClick = true
		else
			currColOpt.methodsLineClick = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkLineClickWhisper = ELib:Check(self.optColSet.col6scroll,L.cd2OtherSetLineClickWhisper):Point(10,-205):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsLineClickWhisper = true
		else
			currColOpt.methodsLineClickWhisper = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkNewSpellNewLine = ELib:Check(self.optColSet.col6scroll,L.cd2NewSpellNewLine):Point(10,-230):Tooltip(L.cd2NewSpellNewLineTooltip):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsNewSpellNewLine = true
		else
			currColOpt.methodsNewSpellNewLine = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.textSortingRules= ELib:Text(self.optColSet.col6scroll,L.cd2MethodsSortingRules..":",11):Size(200,20):Point(10,-255)
	self.optColSet.dropDownSortingRules = ELib:DropDown(self.optColSet.col6scroll,405,6):Size(220):Point(180,-255)
	self.optColSet.dropDownSortingRules.Rules = {L.cd2MethodsSortingRules1,L.cd2MethodsSortingRules2,L.cd2MethodsSortingRules3,L.cd2MethodsSortingRules4,L.cd2MethodsSortingRules5,L.cd2MethodsSortingRules6}
	for i=1,#self.optColSet.dropDownSortingRules.Rules do
		self.optColSet.dropDownSortingRules.List[i] = {
			text = self.optColSet.dropDownSortingRules.Rules[i],
			arg1 = i,
			func = function (self,arg)
				ELib:DropDownClose()
				currColOpt.methodsSortingRules = arg
				module:ReloadAllSplits()
				module.main:GROUP_ROSTER_UPDATE()
				self:GetParent().parent:SetText(module.options.optColSet.dropDownSortingRules.Rules[arg])
			end
		}
	end

	self.optColSet.chkHideOwnSpells = ELib:Check(self.optColSet.col6scroll,L.cd2MethodsDisableOwn):Point(10,-280):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsHideOwnSpells = true
		else
			currColOpt.methodsHideOwnSpells = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkAlphaNotInRange = ELib:Check(self.optColSet.col6scroll,L.cd2MethodsAlphaNotInRange):Point(10,-305):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsAlphaNotInRange = true
		else
			currColOpt.methodsAlphaNotInRange = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderAlphaNotInRange = ELib:Slider(self.optColSet.col6scroll,""):Size(140):Point("TOPLEFT",self.optColSet.chkAlphaNotInRange,270,-3):Range(0,100):OnChange(function(self,event)
		event = event - event%1
		currColOpt.methodsAlphaNotInRangeNum = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.chkDisableActive = ELib:Check(self.optColSet.col6scroll,L.cd2ColSetDisableActive):Point(10,-330):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsDisableActive = true
		else
			currColOpt.methodsDisableActive = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkOneSpellPerCol = ELib:Check(self.optColSet.col6scroll,L.cd2ColSetOneSpellPerCol):Point(10,-355):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsOneSpellPerCol = true
		else
			currColOpt.methodsOneSpellPerCol = nil
		end
		module:ReloadAllSplits()
	end):Tooltip(L.cd2ColSetOneSpellPerColTooltip)

	self.optColSet.chkSortByAvailability = ELib:Check(self.optColSet.col6scroll,L.cd2SortByAvailability):Point(10,-380):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsSortByAvailability = true
		else
			currColOpt.methodsSortByAvailability = nil
		end
		module:ReloadAllSplits()
		module.main:GROUP_ROSTER_UPDATE()
	end)

	self.optColSet.chkSortByAvailability_activeToTop = ELib:Check(self.optColSet.col6scroll,L.cd2SortByAvailabilityActiveToTop):Point("TOPLEFT",self.optColSet.chkSortByAvailability,0,-25):Tooltip(L.cd2SortByAvailabilityActiveToTopTooltip):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsSortActiveToTop = true
		else
			currColOpt.methodsSortActiveToTop = nil
		end
		module:ReloadAllSplits()
		module.main:GROUP_ROSTER_UPDATE()
	end)

	self.optColSet.chkReverseSorting = ELib:Check(self.optColSet.col6scroll,L.cd2ReverseSorting):Point("TOPLEFT",self.optColSet.chkSortByAvailability_activeToTop,0,-25):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsReverseSorting = true
		else
			currColOpt.methodsReverseSorting = nil
		end
		module:ReloadAllSplits()
		module.main:GROUP_ROSTER_UPDATE()
	end)

	self.optColSet.chkCDOnlyTimer = ELib:Check(self.optColSet.col6scroll,L.cd2CDOnlyTimer):Point("TOPLEFT",self.optColSet.chkReverseSorting,0,-25):Tooltip(L.cd2CDOnlyTimerTooltip):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsCDOnlyTime = true
		else
			currColOpt.methodsCDOnlyTime = nil
		end
		module:ReloadAllSplits()
		module.main:GROUP_ROSTER_UPDATE()
	end)

	self.optColSet.chkTextIgnoreActive = ELib:Check(self.optColSet.col6scroll,L.cd2TextIgnoreActive):Point("TOPLEFT",self.optColSet.chkCDOnlyTimer,0,-25):Tooltip(L.cd2TextIgnoreActiveTooltip):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsTextIgnoreActive = true
		else
			currColOpt.methodsTextIgnoreActive = nil
		end
		module:ReloadAllSplits()
		module.main:GROUP_ROSTER_UPDATE()
	end)

	self.optColSet.chkShowOnlyNotOnCD = ELib:Check(self.optColSet.col6scroll,L.cd2OtherSetOnlyNotOnCD):Point("TOPLEFT",self.optColSet.chkTextIgnoreActive,0,-25):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsOnlyNotOnCD = true
		else
			currColOpt.methodsOnlyNotOnCD = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkGeneralMethods = ELib:Check(self.optColSet.col6scroll,L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)


	function self.optColSet.chkGeneralMethods:doAlphas()
		ExRT.lib.SetAlphas(VMRT.ExCD2.colSet[module.options.optColTabs.selected].methodsGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1,module.options.optColSet.chkShowOnlyOnCD,module.options.optColSet.chkBotToTop,module.options.optColSet.chkRightToLeft,module.options.optColSet.dropDownStyleAnimation,module.options.optColSet.dropDownTimeLineAnimation,module.options.optColSet.chkIconTooltip,module.options.optColSet.chkLineClick,module.options.optColSet.chkNewSpellNewLine,module.options.optColSet.dropDownSortingRules,module.options.optColSet.textSortingRules,module.options.optColSet.textStyleAnimation,module.options.optColSet.textTimeLineAnimation,module.options.optColSet.chkHideOwnSpells,module.options.optColSet.chkAlphaNotInRange,module.options.optColSet.sliderAlphaNotInRange,module.options.optColSet.chkDisableActive,module.options.optColSet.chkOneSpellPerCol,module.options.optColSet.chkLineClickWhisper,module.options.optColSet.chkSortByAvailability, module.options.optColSet.chkSortByAvailability_activeToTop, module.options.optColSet.chkReverseSorting, module.options.optColSet.chkCDOnlyTimer, module.options.optColSet.chkTextIgnoreActive, module.options.optColSet.chkShowOnlyNotOnCD)
	end


	self.optColSet.chkOnlyInCombat = ELib:Check(self.optColSet.superTabFrame.tab[7],L.TimerOnlyInCombat):Point(10,-30):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.methodsOnlyInCombat = true
		else
			currColOpt.methodsOnlyInCombat = nil
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.visibilityTextPartyType = ELib:Text(self.optColSet.superTabFrame.tab[7],L.cd2OtherVisibilityPartyType..":",10):Point(10,-60):Color()

	self.optColSet.chkVisibilityPartyTypeAlways = ELib:Radio(self.optColSet.superTabFrame.tab[7],ALWAYS):Point(10,-75):OnClick(function(self)
		module.options.optColSet.chkVisibilityPartyTypeAlways:SetChecked(true)
		module.options.optColSet.chkVisibilityPartyTypeParty:SetChecked(false)
		module.options.optColSet.chkVisibilityPartyTypeRaid:SetChecked(false)
		currColOpt.visibilityPartyType = nil
		module:ReloadAllSplits()
	end)
	self.optColSet.chkVisibilityPartyTypeParty = ELib:Radio(self.optColSet.superTabFrame.tab[7],AGGRO_WARNING_IN_PARTY.." / "..SOLO):Point(10,-95):OnClick(function(self)
		module.options.optColSet.chkVisibilityPartyTypeAlways:SetChecked(false)
		module.options.optColSet.chkVisibilityPartyTypeParty:SetChecked(true)
		module.options.optColSet.chkVisibilityPartyTypeRaid:SetChecked(false)
		currColOpt.visibilityPartyType = 1
		module:ReloadAllSplits()
	end)
	self.optColSet.chkVisibilityPartyTypeRaid = ELib:Radio(self.optColSet.superTabFrame.tab[7],L.cd2OtherVisibilityPartyTypeRaid):Point(10,-115):OnClick(function(self)
		module.options.optColSet.chkVisibilityPartyTypeAlways:SetChecked(false)
		module.options.optColSet.chkVisibilityPartyTypeParty:SetChecked(false)
		module.options.optColSet.chkVisibilityPartyTypeRaid:SetChecked(true)
		currColOpt.visibilityPartyType = 2
		module:ReloadAllSplits()
	end)

	self.optColSet.visibilityTextZoneType = ELib:Text(self.optColSet.superTabFrame.tab[7],L.cd2OtherVisibilityZoneType..":",10):Point(10,-140):Color()

	self.optColSet.chkVisibilityZoneArena = ELib:Check(self.optColSet.superTabFrame.tab[7],ARENA):Point(10,-155):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.visibilityDisableArena = nil
		else
			currColOpt.visibilityDisableArena = true
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkVisibilityZoneBG = ELib:Check(self.optColSet.superTabFrame.tab[7],BATTLEGROUND):Point(10,-180):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.visibilityDisableBG = nil
		else
			currColOpt.visibilityDisableBG = true
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkVisibilityZoneScenario = ELib:Check(self.optColSet.superTabFrame.tab[7],TRACKER_HEADER_SCENARIO):Point(10,-205):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.visibilityDisable3ppl = nil
		else
			currColOpt.visibilityDisable3ppl = true
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkVisibilityZone5ppl = ELib:Check(self.optColSet.superTabFrame.tab[7],CALENDAR_TYPE_DUNGEON):Point(10,-230):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.visibilityDisable5ppl = nil
		else
			currColOpt.visibilityDisable5ppl = true
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkVisibilityZoneRaid = ELib:Check(self.optColSet.superTabFrame.tab[7],RAID):Point(10,-255):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.visibilityDisableRaid = nil
		else
			currColOpt.visibilityDisableRaid = true
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkVisibilityZoneOutdoor = ELib:Check(self.optColSet.superTabFrame.tab[7],WORLD):Point(10,-280):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.visibilityDisableWorld = nil
		else
			currColOpt.visibilityDisableWorld = true
		end
		module:ReloadAllSplits()
	end)

	self.optColSet.chkGeneralVisibility = ELib:Check(self.optColSet.superTabFrame.tab[7],L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)
	function self.optColSet.chkGeneralVisibility:doAlphas()
		ExRT.lib.SetAlphas(VMRT.ExCD2.colSet[module.options.optColTabs.selected].visibilityGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1,module.options.optColSet.chkOnlyInCombat,module.options.optColSet.visibilityTextPartyType,module.options.optColSet.chkVisibilityPartyTypeAlways,module.options.optColSet.chkVisibilityPartyTypeParty,module.options.optColSet.chkVisibilityPartyTypeRaid,module.options.optColSet.visibilityTextZoneType,module.options.optColSet.chkVisibilityZoneArena,module.options.optColSet.chkVisibilityZoneBG,module.options.optColSet.chkVisibilityZoneScenario,module.options.optColSet.chkVisibilityZone5ppl,module.options.optColSet.chkVisibilityZoneRaid,module.options.optColSet.chkVisibilityZoneOutdoor)
	end


	self.optColSet.blacklistText = ELib:Text(self.optColSet.superTabFrame.tab[8],L.cd2ColSetBlacklistTooltip,11):Size(430,200):Point(10,-30):Top():Color()

	self.optColSet.blacklistEditBox = ELib:MultiEdit(self.optColSet.superTabFrame.tab[8]):Size(430,140):Point("TOP",0,-85)

	if self.optColSet.blacklistEditBox and self.optColSet.blacklistEditBox.EditBox then
		self.optColSet.blacklistEditBox.EditBox:SetTextColor(1,1,1,1)

		if self.optColSet.blacklistEditBox.EditBox.SetCursorColor then
			self.optColSet.blacklistEditBox.EditBox:SetCursorColor(1,1,1,1)
		end
		self.optColSet.blacklistEditBox.EditBox:SetShadowColor(0,0,0,1)
		self.optColSet.blacklistEditBox.EditBox:SetShadowOffset(1,-1)
	end
	do
		local scheluded = nil
		local function ScheludeFunc(self)
			scheluded = nil
			module:ReloadAllSplits()
		end
		function self.optColSet.blacklistEditBox:OnTextChanged(isUser)
			if not isUser then
				return
			end
			currColOpt.blacklistText = strtrim( self:GetText() )
			if not scheluded then
				scheluded = ExRT.F.ScheduleTimer(ScheludeFunc, 1)
			end
		end
	end

	self.optColSet.whitelistText = ELib:Text(self.optColSet.superTabFrame.tab[8],L.cd2ColSetWhitelistTooltip,11):Size(430,200):Point(10,-235):Top():Color()

	self.optColSet.whitelistEditBox = ELib:MultiEdit(self.optColSet.superTabFrame.tab[8]):Size(430,140):Point("TOP",0,-290)
	do
		local scheluded = nil
		local function ScheludeFunc(self)
			scheluded = nil
			module:ReloadAllSplits()
		end
		function self.optColSet.whitelistEditBox:OnTextChanged(isUser)
			if not isUser then
				return
			end
			currColOpt.whitelistText = strtrim( self:GetText() )
			if not scheluded then
				scheluded = ExRT.F.ScheduleTimer(ScheludeFunc, 1)
			end
		end
	end

	self.optColSet.chkGeneralBlackList = ELib:Check(self.optColSet.superTabFrame.tab[8],L.cd2ColSetGeneral):Point("TOPRIGHT",-10,-10):Left():OnClick(function(self)
		applyUseGeneralAll(self:GetChecked())
	end)
	function self.optColSet.chkGeneralBlackList:doAlphas()
		ExRT.lib.SetAlphas(VMRT.ExCD2.colSet[module.options.optColTabs.selected].blacklistGeneral and module.options.optColTabs.selected ~= (module.db.maxColumns + 1) and 0.5 or 1,module.options.optColSet.blacklistEditBox,module.options.optColSet.whitelistEditBox,module.options.optColSet.whitelistText,module.options.optColSet.blacklistText)
	end


	self.optColSet.templates = {}
	self.optColSet.templateData = {
		spells = {
			31821,
			64843,
			871,
			20484,
			32182,
		},
		spellsCD = {120,480,300,600,300},
		spellsDuration = {0,8,0,0,0},
		spellsDead = {nil,nil,nil,nil,nil},
		spellsCharge = {nil,nil,nil,nil,nil},
		spellsClass = {"PALADIN","PRIEST","WARRIOR","DRUID","SHAMAN"},
		[1] = {
			iconSize = 16,
			textureAnimation = true,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 1,
			iconPosition = 1,
			iconGray = true,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = true,
			fontShadow = false,
			textureFile = ExRT.F.barImg,
			colorsText = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsBack = {0,1,0, 0,1,0, 1,0,0, 1,1,0},
			colorsTL = {0,1,0, 0,1,0, 1,0,0, 1,1,0},
			textureAlphaBackground = 0.3,
			textureAlphaTimeLine = 0.8,
			textureAlphaCooldown = 1,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%time%",
			textTemplateCenter = "",
			textureAnimation = true,
			_heightType = 1,
		},
		[2] = {
			iconSize = 14,
			textureAnimation = false,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 1,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = true,
			fontShadow = false,
			textureFile = ExRT.F.barImg,
			colorsText = {1,1,1, 0.5,1,0.5, 1,0.5,0.5, 1,1,0.5,},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0.3,
			textureAlphaTimeLine = 0.8,
			textureAlphaCooldown = 1,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = false,
			textTemplateLeft = "%time% %name%",
			textTemplateRight = "",
			textTemplateCenter = "",
			_heightType = 1,
		},
		[3] = {
			iconSize = 24,
			frameWidth = 24,
			textureAnimation = false,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 1,
			iconPosition = 1,
			iconGray = true,
			fontSize = 10,
			fontName = ExRT.F.defFont,
			fontOutline = true,
			fontShadow = false,
			textureFile = ExRT.F.barImg,
			colorsText = {1,1,1, 0.5,1,0.5, 1,0.5,0.5, 1,1,0.5,},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0,
			textureAlphaTimeLine = 0,
			textureAlphaCooldown = 0.7,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = false,
			textTemplateLeft = "",
			textTemplateRight = "",
			textTemplateCenter = "",
			textIconName = false,
			methodsCooldown = true,
			iconCooldownShowSwipe = true,

			iconFontTopTemplate = "%target%",
			iconFontTopPos = 2,
			iconFontCenterTemplate = "%time%",
			iconFontCenterPos = 5,
			iconFontBottomTemplate = "%name%",
			iconFontBottomPos = 8,

			ATFLines = 2,
			ATFCol = 6,
			ATFGrowth = 2,
			ATF = true,
			fontCDSize = 10,
			iconGlowType = 3,

			func = function(parent,templateFrame)
				local f1 = ELib:Frame(parent):Point("BOTTOMRIGHT",parent,"RIGHT",-20,0):Size(80,48)
				ELib:Texture(f1,.8,.8,.8,.8,"BACKGROUND"):Point('x')
				ELib:Text(f1,UnitName"player",12):Point("CENTER",0,0):Color(0,0.44,0.866):Outline()
				local i1=templateFrame.lines[1] i1:ClearAllPoints() i1:SetPoint("BOTTOMRIGHT",f1,"BOTTOMLEFT",0,0)
				local i2=templateFrame.lines[2] i2:ClearAllPoints() i2:SetPoint("RIGHT",i1,"LEFT",0,0)
				local i3=templateFrame.lines[3] i3:ClearAllPoints() i3:SetPoint("BOTTOM",i1,"TOP",0,0)

				local f2 = ELib:Frame(parent):Point("TOPRIGHT",parent,"RIGHT",-20,-1):Size(80,48)
				ELib:Texture(f2,.8,.8,.8,.8,"BACKGROUND"):Point("TOPLEFT",f2,0,0):Point("BOTTOMRIGHT",f2,-54,0)
				ELib:Texture(f2,.2,.2,.2,.8,"BACKGROUND"):Point("TOPLEFT",f2,"TOPRIGHT",-54,0):Point("BOTTOMRIGHT",f2,0,0)
				ELib:Text(f2,UnitName"player",12):Point("CENTER",0,0):Color(0.77,0.12,0.23):Outline()
				local i1=templateFrame.lines[4] i1:ClearAllPoints() i1:SetPoint("BOTTOMRIGHT",f2,"BOTTOMLEFT",0,0)
				local i2=templateFrame.lines[5] i2:ClearAllPoints() i2:SetPoint("RIGHT",i1,"LEFT",0,0)
				local i3=templateFrame.lines[6] i3:ClearAllPoints() i3:SetPoint("RIGHT",i2,"LEFT",0,0)
				local i4=templateFrame.lines[7] i4:ClearAllPoints() i4:SetPoint("BOTTOM",i1,"TOP",0,0)
				local i5=templateFrame.lines[8] i5:ClearAllPoints() i5:SetPoint("RIGHT",i4,"LEFT",0,0)
			end,
			disableOnGeneral = true,
			DiffSpellData = {

				spells = 	{32182,	16190,	8143,	49576,	49222,	51052,	48707,	48792	},
				spellsCD = 	{300,	300,	0,	35,	60,	120,	45,	120	},
				spellsDuration ={0,	0,	10,	0,	0,	10,	5,	12	},
				spellsDead = 	{nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil	},
				spellsCharge = 	{nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil	},
				spellsClass = 	{"SHAMAN","SHAMAN","SHAMAN","DEATHKNIGHT","DEATHKNIGHT","DEATHKNIGHT","DEATHKNIGHT","DEATHKNIGHT"},
			},
		},
		[4] = {
			iconSize = 16,
			textureAnimation = true,
			methodsStyleAnimation = 2,
			methodsTimeLineAnimation = 2,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar19.tga",
			colorsText = {1,1,1, 0.5,1,0.5, 1,1,1, 1,1,0.5},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0.15,
			textureAlphaTimeLine = 1,
			textureAlphaCooldown = 0.85,
			textureClassBackground = true,
			textureClassTimeLine = true,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%time%",
			textTemplateCenter = "",

			frameBetweenLines = 1,
			_heightType = 1,
		},
		[5] = {
			iconSize = 40,
			textureAnimation = false,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 1,
			iconPosition = 1,
			iconGray = true,
			fontSize = 10,
			fontName = ExRT.F.defFont,
			fontOutline = true,
			fontShadow = false,
			textureFile = ExRT.F.barImg,
			colorsText = {1,1,1, 0.5,1,0.5, 1,0.5,0.5, 1,1,0.5,},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0,
			textureAlphaTimeLine = 0,
			textureAlphaCooldown = 0.7,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = false,
			textTemplateLeft = "",
			textTemplateRight = "",
			textTemplateCenter = "",
			textIconName = true,
			methodsCooldown = true,
			textIconNameChars = 6,

			iconFontTopTemplate = "%target%",
			iconFontTopPos = 2,
			iconFontCenterTemplate = "%time%",
			iconFontCenterPos = 5,
			iconFontBottomTemplate = "%name%",
			iconFontBottomPos = 8,

			frameWidth = 40,
			frameColumns = 4,
			_heightType = 1,
		},
		[6] = {
			iconSize = 12,
			textureAnimation = false,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 1,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = false,
			textureFile = ExRT.F.barImg,
			colorsText = {1,1,1, 0.5,1,0.5, 1,0.5,0.5, 1,1,0.5,},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0,
			textureAlphaTimeLine = 0,
			textureAlphaCooldown = 1,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = false,
			textTemplateLeft = "%time% %name%",
			textTemplateRight = "",
			textTemplateCenter = "",
			_heightType = 1,
		},
		[7] = {
			iconSize = 14,
			textureAnimation = true,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 1,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar29.tga",
			colorsText = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsBack = {0,1,0, 0,1,0, 0.8,0,0, 1,1,0},
			colorsTL = {0,1,0, 0,1,0, 0.8,0,0, 1,1,0},
			textureAlphaBackground = 0.3,
			textureAlphaTimeLine = 0.8,
			textureAlphaCooldown = 0.5,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%stime%",
			textTemplateCenter = "",
			_heightType = 1,
		},
		[8] = {
			iconSize = 16,
			textureAnimation = true,
			methodsStyleAnimation = 2,
			methodsTimeLineAnimation = 2,
			iconPosition = 2,
			iconGray = true,
			fontSize = 13,
			fontName = ExRT.F.defFont,
			fontOutline = true,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar6.tga",
			colorsText = {1,1,1, 0.5,1,0.5, 1,0.5,0.5, 1,1,0.5,},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0.3,
			textureAlphaTimeLine = 0.8,
			textureAlphaCooldown = 0.5,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = true,
			textTemplateLeft = "%name%",
			textTemplateRight = "",
			textTemplateCenter = "",
			_heightType = 1,
		},
		[9] = {
			iconSize = 18,
			textureAnimation = true,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 2,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar16.tga",
			colorsText = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsBack = {0,0,0, 0,0,0, 0,0,0, 0,0,0},
			colorsTL = {0.24,0.44,1, 1,0.37,1, 0.24,0.44,1, 1,0.46,0.10},
			textureAlphaBackground = 0.3,
			textureAlphaTimeLine = 0.9,
			textureAlphaCooldown = 1,
			textureClassBackground = false,
			textureClassTimeLine = false,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%stime%",
			textTemplateCenter = "",
			textureBorderSize = 1,
			frameBetweenLines = 3,
			textureBorderColorA = 1,
			_heightType = 1,
		},
		[10] = {
			iconSize = 18,
			textureAnimation = true,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 2,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar16.tga",
			colorsText = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsBack = {0,0,0, 0,0,0, 0,0,0, 0,0,0},
			colorsTL = {0.24,0.44,1, 1,0.37,1, 0.24,0.44,1, 1,0.46,0.10},
			textureAlphaBackground = 0.3,
			textureAlphaTimeLine = 0.9,
			textureAlphaCooldown = 1,
			textureClassBackground = false,
			textureClassTimeLine = true,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%stime%",
			textTemplateCenter = "",
			textureBorderSize = 1,
			frameBetweenLines = 3,
			textureBorderColorA = 1,
			_heightType = 1,
		},
		[11] = {
			_twoSized = true,
			_Scaled = .8,

			iconSize = 40,
			textureAnimation = true,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 2,
			iconPosition = 1,
			iconGray = true,
			fontSize = 14,
			fontName = ExRT.F.defFont,
			fontOutline = true,
			fontShadow = false,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar17.tga",
			colorsText = {1,1,1, 1,1,1, 1,.6,.6, 1,1,.5},
			colorsBack = {0,0,0, 0,0,0, 0,0,0, 0,0,0},
			colorsTL = {0,0,0, 0,0,0, 0,0,0, 0,0,0},
			textureAlphaBackground = 0.8,
			textureAlphaTimeLine = 1,
			textureAlphaCooldown = .5,
			textureClassBackground = false,
			textureClassTimeLine = true,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "",
			textTemplateCenter = "",
			methodsCooldown = true,
			methodsNewSpellNewLine = true,
			frameColumns = 5,
			iconHideBlizzardEdges = true,

			frameLines = 60,

			DiffSpellData = {
				spells = 	{31821,	31821,	0,	0,	0,	97462,	0,	0,	0,	0,	20484,	20484},
				spellsCD = 	{90,	0,	0,	0,	0,	0,	0,	0,	0,	0,	20,	0},
				spellsDuration = {0,	10,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0},
				spellsDead = 	{nil,	nil,	nil,	nil,	nil,	true,	nil,	nil,	nil,	nil,	nil,	nil},
				spellsCharge = 	{nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	true,	nil},
				spellsClass = 	{"PALADIN","PALADIN",nil,nil,nil,	"WARRIOR",nil,nil,nil,nil,		"DRUID","DRUID"},
			},
		},
		[12] = {},
		[13] = {
			iconSize = 13,
			textureAnimation = true,
			methodsStyleAnimation = 2,
			methodsTimeLineAnimation = 2,
			iconPosition = 2,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar19.tga",
			colorsText = {1,1,1, 0.5,1,0.5, 1,1,1, 1,1,0.5},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0.15,
			textureAlphaTimeLine = 1,
			textureAlphaCooldown = 0.85,
			textureClassBackground = true,
			textureClassTimeLine = true,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%time%",
			textTemplateCenter = "",
			iconTitles = true,

			frameBetweenLines = 0,

			DiffSpellData = {
				spells = 	{31821,	31821,	31821,	97462,	97462,	51052,	51052,	51052,	},
				spellsCD = 	{0,	90,	0,	0,	0,	0,	0,	20,	},
				spellsDuration ={0,	0,	10,	0,	0,	0,	0,	0,	},
				spellsDead = 	{nil,	nil,	nil,	nil,	true,	nil,	nil,	nil,	},
				spellsCharge = 	{nil,	nil,	nil,	nil,	nil,	nil,	nil,	true,	},
				spellsClass = 	{"title","PALADIN","PALADIN","title","WARRIOR","title","DEATHKNIGHT","DEATHKNIGHT"},
			},
			_heightType = 1,
		},
		[14] = {
			iconSize = 14,
			textureAnimation = true,
			methodsStyleAnimation = 2,
			methodsTimeLineAnimation = 2,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar19.tga",
			colorsText = {1,1,1, 0.5,1,0.5, 1,1,1, 1,1,0.5},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0.15,
			textureAlphaTimeLine = 1,
			textureAlphaCooldown = 0.85,
			textureClassBackground = true,
			textureClassTimeLine = true,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%time%",
			textTemplateCenter = "",

			frameBetweenLines = 0,
			_heightType = 1,
		},
		[15] = {
			_twoSized = true,
			_Scaled = .85,

			iconSize = 13,
			textureAnimation = true,
			methodsStyleAnimation = 2,
			methodsTimeLineAnimation = 2,
			iconPosition = 1,
			iconGray = false,
			fontSize = 12,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar19.tga",
			colorsText = {1,1,1, 0.5,1,0.5, 1,1,1, 1,1,0.5},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0.15,
			textureAlphaTimeLine = 1,
			textureAlphaCooldown = 0.85,
			textureClassBackground = true,
			textureClassTimeLine = true,
			textureClassText = false,
			textTemplateLeft = "%name%",
			textTemplateRight = "%time%",
			textTemplateCenter = "",
			iconTitles = true,
			methodsNewSpellNewLine = true,
			frameColumns = 5,
			frameLines = 60,
			frameBetweenLines = 0,

			DiffSpellData = {
				spells = 	{31821,	31821,	31821,	0,	0,	97462,	97462,	0,	0,	0,	740,	740,	740,	0,	0,	51052,	51052,	51052,	0,	0,	64843,	64843,	64843,},
				spellsCD = 	{0,	90,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	20,	0,	0,	0,	0,	70,},
				spellsDuration ={0,	0,	10,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,},
				spellsDead = 	{nil,	nil,	nil,	nil,	nil,	nil,	true,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,},
				spellsCharge = 	{nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	nil,	true,	nil,	nil,	nil,	nil,	nil,},
				spellsClass = 	{"title","PALADIN","PALADIN",nil,nil,"title","WARRIOR",nil,nil,nil,"title","DRUID","DRUID",nil,nil,"title","DEATHKNIGHT","DEATHKNIGHT",nil,nil,"title","PRIEST","PRIEST"},
			},
			_heightType = 1,
		},
		[16] = {},
		[17] = {
			iconSize = 14,
			textureAnimation = true,
			methodsStyleAnimation = 1,
			methodsTimeLineAnimation = 2,
			iconPosition = 1,
			iconGray = false,
			fontSize = 10,
			fontName = ExRT.F.defFont,
			fontOutline = false,
			fontShadow = true,
			textureFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bar26.tga",
			colorsText = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsBack = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			colorsTL = {1,1,1, 1,1,1, 1,1,1, 1,1,1},
			textureAlphaBackground = 0.15,
			textureAlphaTimeLine = 0.8,
			textureAlphaCooldown = 1,
			textureClassBackground = false,
			textureClassTimeLine = true,
			textureClassText = false,
			textTemplateLeft = "",
			textTemplateRight = "%time%",
			textTemplateCenter = "%name%: %spell%",
			_heightType = 1,
		},
		def = {
			enabled = true,
			iconGlowType = 4,
			textureSmoothAnimation = true,
		},
		toOptions = {
			iconSize = true,
			iconHeight = true,
			iconSeparateHW = true,
			textureAnimation = true,
			methodsStyleAnimation = true,
			methodsTimeLineAnimation = true,
			iconPosition = true,
			iconGray = true,
			fontSize = true,
			fontName = true,
			fontOutline = true,
			fontShadow = true,
			textureFile = true,
			textureAlphaBackground = true,
			textureAlphaTimeLine = true,
			textureAlphaCooldown = true,
			textureClassBackground = true,
			textureClassTimeLine = true,
			textureClassText = true,
			textTemplateLeft = true,
			textTemplateRight = true,
			textTemplateCenter = true,
			methodsCooldown = true,
			textIconName = true,
			fontOtherAvailable = true,
			frameBetweenLines = true,
			textureBorderSize = true,
			textureBorderColorR = true,
			textureBorderColorG = true,
			textureBorderColorB = true,
			textureBorderColorA = true,
			methodsNewSpellNewLine = true,
			methodsSortingRules = true,
			iconTitles = true,
			iconHideBlizzardEdges = true,
			iconCooldownShowSwipe = true,
			textIconNameChars = true,

			iconGeneral = true,
			textureGeneral = true,
			methodsGeneral = true,
			fontGeneral = true,
			textGeneral = true,
			frameGeneral = true,

			frameColumns = true,

			textureSmoothAnimation = true,
			textureSmoothAnimationDuration = true,
			iconCooldownHideNumbers = true,
			textureHideSpark = true,
			iconGlowType = true,
			methodsDisableActive = true,
			methodsOneSpellPerCol = true,

			fontCDSize = true,
			ATF = true,
			ATFLines = true,
			ATFCol = true,
			ATFGrowth = true,

			iconFontMode = true,
			iconFontTopTemplate = true,
			iconFontTopPos = true,
			iconFontCenterTemplate = true,
			iconFontCenterPos = true,
			iconFontBottomTemplate = true,
			iconFontBottomPos = true,

			_frameAlpha = "frameAlpha",
			_frameWidth = "frameWidth",
			_frameBlackBack = "frameBlackBack",
			_frameLines = "frameLines",
		},
	}
	self.optColSet.templateSaveData = nil

	for i=1,#self.optColSet.templateData do
		local t = self.optColSet.templateData[i]
		if t.colorsText then for j=1,3 do for k=1,3 do
			local key = "textureColorText"..(j == 1 and "Default" or j==2 and "Active" or "Cooldown")..(k==1 and "R" or k==2 and "G" or "B")
			t[key] = t.colorsText[(j-1)*3+k]
			self.optColSet.templateData.toOptions[key] = true
		end end end
		if t.colorsBack then for j=1,3 do for k=1,3 do
			local key = "textureColorBackground"..(j == 1 and "Default" or j==2 and "Active" or "Cooldown")..(k==1 and "R" or k==2 and "G" or "B")
			t[key] = t.colorsBack[(j-1)*3+k]
			self.optColSet.templateData.toOptions[key] = true
		end end end
		if t.colorsTL then for j=1,3 do for k=1,3 do
			local key = "textureColorTimeLine"..(j == 1 and "Default" or j==2 and "Active" or "Cooldown")..(k==1 and "R" or k==2 and "G" or "B")
			t[key] = t.colorsTL[(j-1)*3+k]
			self.optColSet.templateData.toOptions[key] = true
		end end end
		t.colorsText, t.colorsBack, t.colorsTL = nil
	end

	local function TemplateButtonOnEnter(self)
		if self.templateData.disableOnGeneral and module.options.optColTabs.selected == (module.db.maxColumns + 1) then
			self.backgTexture:SetColorTexture(1,0,0,0.3)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:AddLine(L.cd2ATFTooltipDisabled)
			GameTooltip:Show()
		else
			self.backgTexture:SetColorTexture(1,1,1,0.3)
		end
	end
	local function TemplateButtonOnLeave(self)
		self.backgTexture:SetColorTexture(0,0,0,0)
		GameTooltip_Hide()
	end
	local function TemplateButtonOnClick(self)
		local templateData = self.templateData
		if templateData.disableOnGeneral and module.options.optColTabs.selected == (module.db.maxColumns + 1) then
			return
		end
	  	module.options.optColSet.templateRestore:Show()
	  	module.options.optColSet.templateSaveData = {}
	  	ExRT.F.table_copy(currColOpt,module.options.optColSet.templateSaveData)
		local isGeneralTab = module.options.optColTabs.selected == (module.db.maxColumns + 1)
	  	for key,val in pairs(module.options.optColSet.templateData.toOptions) do
			if type(val) == "boolean" then
				val = key
			end
  			if key:sub(1,1)=="_" then
  				key = key:sub(2)
  				if templateData[key] then
  					currColOpt[val] = templateData[key]
  				elseif key == "frameWidth" then
  					currColOpt[val] = max(130,currColOpt[val] or 130)
  				end
  			elseif val:find("General") then
  				if isGeneralTab then
					local baseKey = val:gsub("General$","")
					currColOpt[baseKey] = templateData[key]
				else
					currColOpt[val] = nil
				end
  			else
  				currColOpt[val] = templateData[key]
  			end
	  	end
	  	module:ReloadAllSplits()
	  	module.options.selectColumnTab()
	end
	local TemplateMT = {__index = self.optColSet.templateData.def}

	self.optColSet.templatesScrollFrame = ELib:ScrollFrame(self.optColSet.superTabFrame.tab[9]):Size(430,380):Point("TOP",0,-50):Height( ceil(#self.optColSet.templateData/2) * 125 + 10 )
	for i=1,#self.optColSet.templateData do
		local templateData = self.optColSet.templateData[i]
		if ExRT.F.table_len(templateData) > 0 then
			local buttonFrame = CreateFrame("Button",nil,self.optColSet.templatesScrollFrame.C)
			if templateData._twoSized then
				buttonFrame:SetSize(370,120)
			else
				buttonFrame:SetSize(185,120)
			end
			buttonFrame:SetPoint(templateData._twoSized and "TOP" or (i-1)%2 == 0 and "TOPRIGHT" or "TOPLEFT",self.optColSet.templatesScrollFrame.C,"TOP",0,-floor((i-1)/2) * 125 - 5)
			buttonFrame.backgTexture = buttonFrame:CreateTexture(nil, "BACKGROUND")
			buttonFrame.backgTexture:SetAllPoints()
			buttonFrame.templateData = templateData

			buttonFrame:SetScript("OnEnter",TemplateButtonOnEnter)
			buttonFrame:SetScript("OnLeave",TemplateButtonOnLeave)
			buttonFrame:SetScript("OnClick",TemplateButtonOnClick)

			local templateFrame = module:CreateColumn(buttonFrame)
			self.optColSet.templates[i] = templateFrame
			setmetatable(templateData,TemplateMT)
			module:ColApplyStyle(templateFrame,templateData,{},module.db.colsDefaults)
			templateFrame:ClearAllPoints()
			templateFrame:Show()
			templateFrame:SetPoint("CENTER")
			if templateData._heightType == 1 then
				local l = #(templateData.DiffSpellData and templateData.DiffSpellData.spells or self.optColSet.templateData.spells)
				l = ceil(l / (templateData.frameColumns or 1))
				local height = templateData.iconSize * l + ((templateData.frameBetweenLines or 0) - 1) * l
				templateFrame:SetSize(min(templateFrame:GetWidth(),templateData._twoSized and 370 or 185),min(height,120))
			else
				templateFrame:SetSize(min(templateFrame:GetWidth(),templateData._twoSized and 370 or 185),min(templateFrame:GetHeight(),120))
			end

			if templateData._Scaled then
				templateFrame:SetScale(templateData._Scaled)
			end
			if templateData.func then
				templateData.func(buttonFrame,templateFrame)
			end

			local spellData = templateData.DiffSpellData or self.optColSet.templateData

			local classColorsTable = type(CUSTOM_CLASS_COLORS)=="table" and CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

			local lineC = 0
			for j=1,#spellData.spells do
				lineC = lineC + 1
				local bar = templateFrame.lines[lineC]

				local spellClass = spellData.spellsClass[j]
				if spellData.spells[j] ~= 0 then
					local spellID = spellData.spells[j]
					local spellName,_,spellTexture = GetSpellInfo(spellID or 0)
					if not spellTexture and ExRT.F.WarmUpSpell then
						ExRT.F.WarmUpSpell(spellID)
						spellName,_,spellTexture = GetSpellInfo(spellID or 0)
					end
					spellName = spellName or "unk"
					spellTexture = spellTexture or "Interface\\Icons\\INV_Misc_QuestionMark"


					bar.data = {
						name = ExRT.SDB.charName,
						fullName = ExRT.SDB.charName,
						icon = spellTexture,
						spellName = i == 3 and spellName:sub(1,spellName:find(' ')) or spellName,
						db = {spellID,spellClass},
						lastUse = GetTime(),
						charge = GetTime(),
						cd = spellData.spellsCD[j],
						duration = spellData.spellsDuration[j],
						classColor = classColorsTable[spellClass] or module.db.notAClass,

						disabled = spellData.spellsDead[j],
						isCharge = spellData.spellsCharge[j],

						specialUpdateData = function(data)
							local currTime = GetTime()
							if data.isCharge then
								if (data.charge + data.cd) < currTime then
									data.charge = currTime
									data.lastUse = currTime
								end
								return
							end
							if data.cd ~= 0 then
								if (data.lastUse + data.cd) < currTime then
									data.lastUse = currTime
								end
							elseif data.duration ~= 0 then
								if (data.lastUse + data.duration) < currTime then
									data.lastUse = currTime
								end
							end
						end,
					}
				end

				bar:UpdateStyle()
				bar:Update()
				bar:UpdateStatus()
				if spellClass == "title" then
					bar:CreateTitle()
				end
			end
		end
	end

	self.optColSet.templateRestore = CreateFrame("Button",nil,self.optColSet.superTabFrame.tab[9], BackdropTemplateMixin and "BackdropTemplate")
	self.optColSet.templateRestore:SetPoint("TOP",0,-10)
	self.optColSet.templateRestore:SetSize(430,30)
	self.optColSet.templateRestore:SetBackdrop({edgeFile = ExRT.F.defBorder, edgeSize = 8})
	self.optColSet.templateRestore:SetBackdropBorderColor(1,0.5,0.5,1)
	self.optColSet.templateRestore.text = ELib:Text(self.optColSet.templateRestore,L.cd2OtherSetTemplateRestore,12):Point('x'):Center():Color():Shadow()
	self.optColSet.templateRestore:SetScript("OnEnter",function (self)
	  	self.text:SetTextColor(1,1,0,1)
	end)
	self.optColSet.templateRestore:SetScript("OnLeave",function (self)
	  	self.text:SetTextColor(1,1,1,1)
	end)
	self.optColSet.templateRestore:SetScript("OnClick",function (self)
		wipe(currColOpt)
		ExRT.F.table_copy(module.options.optColSet.templateSaveData,currColOpt)
		module:ReloadAllSplits()
		module.options.selectColumnTab()
		self:Hide()
	end)
	self.optColSet.templateRestore:Hide()


	self.optColSet.chkATF = ELib:Check(self.optColSet.superTabFrame.tab[10],L.Enable):Point(10,-10):OnClick(function(self)
		if self:GetChecked() then
			currColOpt.ATF = true
			currColOpt.frameGeneral = false
			currColOpt.textureGeneral = false
			currColOpt.iconGeneral = false
			currColOpt.methodsGeneral = false
			currColOpt.textGeneral = false
			currColOpt.fontGeneral = false
			currColOpt.methodsCooldown = true
			currColOpt.frameStrata = nil
		else
			currColOpt.ATF = nil
			module.options.optColSet.chkIconFontMode:SetChecked(currColOpt.iconFontMode and true or false)
			module.options.optColSet.chkSeparateIconHW:SetChecked(currColOpt.iconSeparateHW and true or false)
		end
		module.options.optColSet:applyATFLockLayout()
		module.options.optColSet:applyIconFontModeLayout()
		module.options.optColSet:applyIconHWLayout()
		module:ReloadAllSplits()
	end)

	self.optColSet.sliderATFHeight = ELib:Slider(self.optColSet.superTabFrame.tab[10],L.cd2OtherSetIconSize):Size(400):Point("TOP",0,-50):Range(6,128):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.iconSize = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.sliderATFFont = ELib:Slider(self.optColSet.superTabFrame.tab[10],L.cd2OtherSetFontSize):Size(400):Point("TOP",0,-85):Range(8,72):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.fontCDSize = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.ATFframePreview = ELib:Frame(self.optColSet.superTabFrame.tab[10]):Point("TOPLEFT",140,-140):Size(80,45)
	ELib:Texture(self.optColSet.ATFframePreview,.8,.8,.8,.8,"BACKGROUND"):Point('x')

	ELib:Text(self.optColSet.superTabFrame.tab[10],L.cd2ATFPosition..":"):Point("RIGHT",self.optColSet.ATFframePreview,"LEFT",-30,0):Color()

	function self.optColSet.ATFRadiosCheck()
		for k,v in pairs(self.optColSet.ATFRadios) do
			v:SetChecked(false)
		end
		local pos = VMRT.ExCD2.colSet[module.options.optColTabs.selected].ATFPos or 1
		local k = pos == 1 and "LB" or
			pos == 2 and "LT" or
			pos == 3 and "TL" or
			pos == 4 and "TR" or
			pos == 5 and "RT" or
			pos == 6 and "RB" or
			pos == 7 and "BR" or
			pos == 8 and "BL" or
			"C"
		self.optColSet.ATFRadios[k]:SetChecked(true)
	end
	self.optColSet.ATFRadios = {}
	self.optColSet.ATFRadios.LB = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("BOTTOMRIGHT",self.optColSet.ATFframePreview,"BOTTOMLEFT",-2,2):OnClick(function(self)
		currColOpt.ATFPos = 1
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.LT = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("TOPRIGHT",self.optColSet.ATFframePreview,"TOPLEFT",-2,-2):OnClick(function(self)
		currColOpt.ATFPos = 2
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.TL = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("BOTTOMLEFT",self.optColSet.ATFframePreview,"TOPLEFT",2,2):OnClick(function(self)
		currColOpt.ATFPos = 3
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.TR = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("BOTTOMRIGHT",self.optColSet.ATFframePreview,"TOPRIGHT",-2,2):OnClick(function(self)
		currColOpt.ATFPos = 4
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.RT = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("TOPLEFT",self.optColSet.ATFframePreview,"TOPRIGHT",2,-2):OnClick(function(self)
		currColOpt.ATFPos = 5
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.RB = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("BOTTOMLEFT",self.optColSet.ATFframePreview,"BOTTOMRIGHT",2,2):OnClick(function(self)
		currColOpt.ATFPos = 6
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.BR = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("TOPRIGHT",self.optColSet.ATFframePreview,"BOTTOMRIGHT",-2,-2):OnClick(function(self)
		currColOpt.ATFPos = 7
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.BL = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("TOPLEFT",self.optColSet.ATFframePreview,"BOTTOMLEFT",2,-2):OnClick(function(self)
		currColOpt.ATFPos = 8
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)
	self.optColSet.ATFRadios.C = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("CENTER",self.optColSet.ATFframePreview,"CENTER",0,0):OnClick(function(self)
		currColOpt.ATFPos = 9
		module.options.optColSet.ATFRadiosCheck()
		module:ReloadAllSplits()
	end)

	ELib:Text(self.optColSet.superTabFrame.tab[10],L.cd2ATFGrowth..":"):Point("TOPLEFT",320,-115):Color()

	self.optColSet.ATFTypeGrowth1 = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("TOPLEFT",280,-140):OnClick(function(self)
		currColOpt.ATFGrowth = 1
		module.options.optColSet.ATFTypeGrowth2:SetChecked(false)
		module:ReloadAllSplits()
	end)

	do
		local p = self.optColSet.ATFTypeGrowth1
		local x,y = 20, 5
		for i=1,3 do
			p["l"..i] = p:CreateLine(nil, "BACKGROUND", nil, -5)
			p["l"..i]:SetTexture("Interface/AddOns/"..GlobalAddonName.."/media/line")
			p["l"..i]:SetVertexColor(1,0,0,1)
			p["l"..i]:SetThickness(8)

			x, y = (i % 2) == 1 and 20 or 120, i < 3 and 10 or -10
			p["l"..i]:SetStartPoint("CENTER",p, x, y)
			x, y = (i % 2) == 1 and 120 or 20, i < 2 and 10 or -10
			p["l"..i]:SetEndPoint("CENTER",p, x, y)
		end
	end

	self.optColSet.ATFTypeGrowth2 = ELib:Radio(self.optColSet.superTabFrame.tab[10]):Point("TOPLEFT",280,-180):OnClick(function(self)
		currColOpt.ATFGrowth = 2
		module.options.optColSet.ATFTypeGrowth1:SetChecked(false)
		module:ReloadAllSplits()
	end)

	do
		local p = self.optColSet.ATFTypeGrowth2
		local x,y = 20, 10
		for i=1,11 do
			p["l"..i] = p:CreateLine(nil, "BACKGROUND", nil, -5)
			p["l"..i]:SetTexture("Interface/AddOns/"..GlobalAddonName.."/media/line")
			p["l"..i]:SetVertexColor(1,0,0,1)
			p["l"..i]:SetThickness(8)

			p["l"..i]:SetStartPoint("CENTER",p, x, y)
			if (i % 2) == 0 then
				x = x + 20
				y = y + 20
			else
				y = y - 20
			end
			p["l"..i]:SetEndPoint("CENTER",p, x, y)
		end
	end

	self.optColSet.sliderATFMaxCol = ELib:Slider(self.optColSet.superTabFrame.tab[10],L.cd2ATFMaxCol):Size(400):Point("TOP",0,-230):Range(1,20):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.ATFCol = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.sliderATFMaxLine = ELib:Slider(self.optColSet.superTabFrame.tab[10],L.cd2ATFMaxLine):Size(400):Point("TOP",0,-265):Range(1,20):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.ATFLines = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.sliderATFOffsetX = ELib:Slider(self.optColSet.superTabFrame.tab[10],L.cd2ATFOffsetX):Size(400):Point("TOP",0,-300):Range(-300,300):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.ATFOffsetX = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.sliderATFOffsetY = ELib:Slider(self.optColSet.superTabFrame.tab[10],L.cd2ATFOffsetY):Size(400):Point("TOP",0,-335):Range(-300,300):SetObey(true):OnChange(function(self,event)
		event = event - event%1
		currColOpt.ATFOffsetY = event
		module:ReloadAllSplits()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.optColSet.dropDownATFFramePrior = ELib:DropDown(self.optColSet.superTabFrame.tab[10],350,-1):Size(230):Point("TOPLEFT",180,-370):Tooltip(L.cd2FramePriorTooltip)
	self.optColSet.textdropDownATFFramePrior = ELib:Text(self.optColSet.superTabFrame.tab[10],L.cd2FramePrior..":",11):Size(200,20):Point("LEFT",10,0):Point("TOP",self.optColSet.dropDownATFFramePrior,0,0)
	for i=1,#module.db.rframes do
		self.optColSet.dropDownATFFramePrior.List[i] = {
			text = module.db.rframes[i].text or module.db.rframes[i].name,
			arg1 = module.db.rframes[i].name,
			func = function (self,arg,arg2)
				ELib:DropDownClose()
				currColOpt.ATFFramePrior = arg
				module:ReloadAllSplits()
				self:GetParent().parent:Update()
			end
		}
	end
	function self.optColSet.dropDownATFFramePrior:Update(opt)
		opt = opt or currColOpt.ATFFramePrior
		local optData = ExRT.F.table_find3(module.db.rframes, opt, "name")
		if optData then
			self:SetText(optData.text or optData.name or "")
		else
			self:SetText("")
		end
	end


	do
		module.options.optColTabs.selected = module.db.maxColumns+1
		module.options.tab.tabs[2]:SetScript("OnShow",function ()
			module.options.selectColumnTab(self.optColTabs.tabs[module.db.maxColumns+1].button)
			module.options.tab.tabs[2]:SetScript("OnShow",nil)
		end)
	end


	local advTab = self.optColTabs.tabs[module.db.maxColumns+2]

	advTab.hotfixEdit = ELib:MultiEdit(advTab):Size(650,200):Point("TOPLEFT",0,-30):SetText(VMRT.ExCD2.Hotfixes or ""):OnChange(function(self,isUser)
		if not isUser then
			return
		end
		VMRT.ExCD2.Hotfixes = self:GetText()
		advTab.hotfixApplyBut:Show()
	end)

	if advTab.hotfixEdit and advTab.hotfixEdit.EditBox then
		advTab.hotfixEdit.EditBox:SetTextColor(1,1,1,1)

		if advTab.hotfixEdit.EditBox.SetCursorColor then
			advTab.hotfixEdit.EditBox:SetCursorColor(1,1,1,1)
		end
		advTab.hotfixEdit.EditBox:SetShadowColor(0,0,0,1)
		advTab.hotfixEdit.EditBox:SetShadowOffset(1,-1)
		advTab.hotfixEdit.EditBox:SetFontObject(GameFontHighlightSmall)
	end

	advTab.hotfixEditText = ELib:Text(advTab,"Hotfixes: [?]"):Point("BOTTOMLEFT",advTab.hotfixEdit,"TOPLEFT",10,3):Color():Run(function(self) self.TooltipOverwrite = "Functionality to change predefined addons data for spells.\nExample to change spells cooldown: \"62618:cd:120\". (Change cooldown of spell 62618 to 2 mins)\nExample to change spells duration: \"1044:dur:15\". (Change duration of spell 1044 to 15 sec)" end):Tooltip()
	advTab.hotfixApplyBut = ELib:Button(advTab,APPLY):Point("TOPLEFT",advTab.hotfixEdit,"TOPRIGHT",5,-2):Size(90,25):Shown(false):OnClick(function (self)
		self:Hide()
		module:ApplyHotfixes()
	end)


	local profilesTab = self.optColTabs.tabs[module.db.maxColumns+3]

	local function GetCurrentProfileName()
		return VMRT.ExCD2.Profiles.Now=="default" and L.ProfilesDefault or VMRT.ExCD2.Profiles.Now
	end

	profilesTab.currentText = ELib:Text(profilesTab,L.ProfilesCurrent,11):Size(650,200):Point(15,-20):Top():Color()
	profilesTab.currentName = ELib:Text(profilesTab,"",14):Size(650,200):Point(210,-20):Top():Color(1,1,0)

	profilesTab.currentName.UpdateText = function(self)
		self:SetText(GetCurrentProfileName())
	end
	profilesTab.currentName:UpdateText()

	profilesTab.choseText = ELib:Text(profilesTab,L.ProfilesChooseDesc,11):Size(650,200):Point(15,-60):Top():Color()

	profilesTab.choseNewText = ELib:Text(profilesTab,L.ProfilesNew,11):Size(650,200):Point(15,-88):Top()
	profilesTab.choseNew = ELib:Edit(profilesTab):Size(170,20):Point(10,-100)

	profilesTab.choseNewButton = ELib:Button(profilesTab,L.ProfilesAdd):Size(70,20):Point("LEFT",profilesTab.choseNew,"RIGHT",0,0):OnClick(function (self)
		local text = profilesTab.choseNew:GetText()
		profilesTab.choseNew:SetText("")
		if text == "" or text == "default" or VMRT.ExCD2.Profiles.List[text] or text == VMRT.ExCD2.Profiles.Now then
			return
		end
		VMRT.ExCD2.Profiles.List[text] = ExRT.F.table_copy2(NewVMRTTableData)

		StaticPopupDialogs["EXRT_EXCD_ACTIVATENEW"] = {
			text = L.ProfilesActivateAlert,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				module:SelectProfile(text)
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_EXCD_ACTIVATENEW")
	end)

	profilesTab.choseSelectText = ELib:Text(profilesTab,L.ProfilesSelect,11):Size(605,200):Point(335,-88):Top()
	profilesTab.choseSelectDropDown = ELib:DropDown(profilesTab,220,10):Point(330,-100):Size(235):SetText(GetCurrentProfileName())
	profilesTab.choseSelectDropDown.UpdateText = function(self)
		self:SetText(GetCurrentProfileName())
	end

	local function GetCurrentProfilesList(func)
		local list = {
			{ text = GetCurrentProfileName(), func = func, arg1 = VMRT.ExCD2.Profiles.Now, _sort = "0" },
		}
		for name,_ in pairs(VMRT.ExCD2.Profiles.List) do
			if name ~= VMRT.ExCD2.Profiles.Now then
				list[#list + 1] = { text = name == "default" and L.ProfilesDefault or name, func = func, arg1 = name, _sort = "1"..name }
			end
		end
		sort(list,function(a,b) return a._sort < b._sort end)
		return list
	end

	function profilesTab.choseSelectDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(function(_,arg1)
			ELib:DropDownClose()
			module:SelectProfile(arg1)
		end)
	end

	local function CopyProfile(name)
		local newdb = VMRT.ExCD2.Profiles.List[name]
		local currname = VMRT.ExCD2.Profiles.Now
		if module:SelectProfile(name) then
			VMRT.ExCD2.Profiles.List[name] = newdb
			VMRT.ExCD2.Profiles.Now = currname

			profilesTab.currentName:UpdateText()

			print(L.cd2ProfileCopySuccess:format(name))
		end
	end
	profilesTab.copyText = ELib:Text(profilesTab,L.ProfilesCopy,11):Size(605,200):Point(15,-138):Top()
	profilesTab.copyDropDown = ELib:DropDown(profilesTab,220,10):Point(10,-150):Size(235)
	function profilesTab.copyDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(function(_,arg1)
			ELib:DropDownClose()
			CopyProfile(arg1)
		end)
		for i=1,#self.List do
			if self.List[i].arg1 == VMRT.ExCD2.Profiles.Now then
				tremove(self.List, i)
				break
			end
		end
	end

	local function DeleteProfile(name)
		StaticPopupDialogs["EXRT_EXCD_PROFILES_REMOVE"] = {
			text = L.ProfilesDeleteAlert,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				VMRT.ExCD2.Profiles.List[name] = nil
				profilesTab:UpdateAutoTexts()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_EXCD_PROFILES_REMOVE")
	end
	profilesTab.deleteText = ELib:Text(profilesTab,L.ProfilesDelete,11):Size(605,200):Point(15,-188):Top()
	profilesTab.deleteDropDown = ELib:DropDown(profilesTab,220,10):Point(10,-200):Size(235)
	function profilesTab.deleteDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(function(_,arg1)
			ELib:DropDownClose()
			DeleteProfile(arg1)
		end)
		for i=#self.List,1,-1 do
			if self.List[i].arg1 == VMRT.ExCD2.Profiles.Now then
				tremove(self.List, i)
			elseif self.List[i].arg1 == "default" then
				tremove(self.List, i)
			end
		end
	end


	profilesTab.importWindow, profilesTab.exportWindow = ExRT.F.CreateImportExportWindows()

	function profilesTab.importWindow:ImportFunc(str)
		local headerLen = str:sub(1,4) == "EXRT" and 8 or 7

		local header = str:sub(1,headerLen)
		if (header:sub(1,headerLen-1) ~= "EXRTCDP" and header:sub(1,headerLen-1) ~= "MRTCDP") or (header:sub(headerLen,headerLen) ~= "0" and header:sub(headerLen,headerLen) ~= "1") then
			StaticPopupDialogs["EXRT_EXCD_IMPORT"] = {
				text = "|cffff0000"..ERROR_CAPS.."|r "..L.ProfilesFail3,
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("EXRT_EXCD_IMPORT")
			return
		end

		profilesTab:TextToProfile(str:sub(headerLen+1),header:sub(headerLen,headerLen)=="0")
	end

	profilesTab.exportButton = ELib:Button(profilesTab,L.ProfilesExport):Size(235,25):Point(10,-250):OnClick(function (self)
		profilesTab.exportWindow:NewPoint("CENTER",UIParent,0,0)
		profilesTab:ProfileToText()
	end)

	profilesTab.importButton = ELib:Button(profilesTab,L.ProfilesImport):Size(235,25):Point("LEFT",profilesTab.exportButton,"RIGHT",85,0):OnClick(function (self)
		profilesTab.importWindow:NewPoint("CENTER",UIParent,0,0)
		profilesTab.importWindow:Show()
	end)

	local IGNORE_PROFILE_KEYS = {
		["Profiles"] = true,
	}
	function profilesTab:ProfileToText()
		local new = {}
		for key,val in pairs(VMRT.ExCD2) do
			if not IGNORE_PROFILE_KEYS[key] then
				new[key] = val
			end
		end
		local strlist = ExRT.F.TableToText(new)
		strlist[1] = "0,"..strlist[1]
		local str = table.concat(strlist)

		local compressed
		if #str < 1000000 then
			compressed = LibDeflate:CompressDeflate(str,{level = 5})
		end
		local encoded = "MRTCDP"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or str)

		ExRT.F.dprint("Str len:",#str,"Encoded len:",#encoded)

		if ExRT.isDev then
			module.db.exportTable = new
		end
		profilesTab.exportWindow.Edit:SetText(encoded)
		profilesTab.exportWindow:Show()
	end

	function profilesTab:SaveDataFilter(res)
		local KeysToSave = {
			["Profiles"] = true,
		}
		local R = {
			data = {},
			Restore = function(self,t)
				for k,v in pairs(self.data) do
					t[k] = v
				end
			end
		}
		for k,v in pairs(KeysToSave) do
			R.data[k] = res[k]
		end
		return R
	end
	function profilesTab:LockedFilter(res)
		local KeysToErase = {
			["Profiles"] = true,
		}
		for k,v in pairs(KeysToErase) do
			res[k] = nil
		end
	end
	function profilesTab:OnlyVisualFilter(res)
		local KeysToErase = {
			["Hotfixes"] = true,
			["Priority"] = true,
			["CDE"] = true,
			["enabled"] = true,
			["gnGUIDs"] = true,
			["CDECol"] = true,
			["userDB"] = true,
			["OptFav"] = true,
		}
		for k,v in pairs(KeysToErase) do
			res[k] = VMRT.ExCD2[k]
		end
	end

	function profilesTab:TextToProfile(str,uncompressed)
		local decoded = LibDeflate:DecodeForPrint(str)
		local decompressed
		if uncompressed then
			decompressed = decoded
		else
			decompressed = LibDeflate:DecompressDeflate(decoded)
		end
		decoded = nil

		local _,tableData = strsplit(",",decompressed,2)
		decompressed = nil

		local successful, res = pcall(ExRT.F.TextToTable,tableData)
		if ExRT.isDev then
			module.db.lastImportDB = res
			if module.db.exportTable and type(res)=="table" then
				module.db.diffTable = {}
				print("Compare table",ExRT.F.table_compare(res,module.db.exportTable,module.db.diffTable))
			end
		end
		if successful and res then
			profilesTab:LockedFilter(res)
			ExRT.F.ImportChoicePopup(
				L.cd2ProfileRewriteAlert,
				{
					{text = APPLY, func = function()
						local saved = profilesTab:SaveDataFilter(VMRT.ExCD2)
						ExRT.F.table_rewrite(VMRT.ExCD2,res)
						saved:Restore(VMRT.ExCD2)
						module:ReloadProfile()
						res = nil
					end},
					{text = L.cd2ImportOnlyVisual, func = function()
						profilesTab:OnlyVisualFilter(res)
						local saved = profilesTab:SaveDataFilter(VMRT.ExCD2)
						ExRT.F.table_rewrite(VMRT.ExCD2,res)
						saved:Restore(VMRT.ExCD2)
						module:ReloadProfile()
						res = nil
					end},
					{text = L.ProfilesSaveAsNew, func = function()
						ExRT.F.ShowInput(L.ProfilesNewProfile,function(_,name)
							if name == "" or VMRT.ExCD2.Profiles.List[name] or name == "default" or name == VMRT.ExCD2.Profiles.Now then
								res = nil
								return
							end
							VMRT.ExCD2.Profiles.List[name] = res
							module:SelectProfile(name)
							res = nil
						end,nil,nil,nil,function(self)
							local name = self:GetText()
							if name == "" or VMRT.ExCD2.Profiles.List[name] or name == "default" or name == VMRT.ExCD2.Profiles.Now then
								self:GetParent().OK:Disable()
							else
								self:GetParent().OK:Enable()
							end
						end)
					end},
					{text = CANCEL, func = function()
						res = nil
					end},
				}
			)
			return
		else
			StaticPopupDialogs["EXRT_EXCD_IMPORT"] = {
				text = L.ProfilesFail1..(res and "\nError code: "..res or ""),
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
		end

		StaticPopup_Show("EXRT_EXCD_IMPORT")
	end


	profilesTab.autoText = ELib:Text(profilesTab,L.cd2AutoChangeTooltip,12):Size(605,200):Point(10,-300):Top():Color()

	local function GetTextProfileName(profileName)
		if not profileName then
			return
		end
		local prefix
		if profileName == VMRT.ExCD2.Profiles.Now then
			prefix = "|cff00ff00"
		elseif not VMRT.ExCD2.Profiles.List[profileName] then
			prefix = "|cffff0000"
		end
		if profileName == "default" then
			profileName = L.ProfilesDefault
		end
		return (prefix or "")..profileName
	end
	function profilesTab:UpdateAutoTexts()
		self.autoRaidDown:SetText(GetTextProfileName(VMRT.ExCD2.Profiles.Raid) or "|cff999999"..L.cd2DontChange)
		self.autoDungDown:SetText(GetTextProfileName(VMRT.ExCD2.Profiles.Dung) or "|cff999999"..L.cd2DontChange)
		self.autoArenaDown:SetText(GetTextProfileName(VMRT.ExCD2.Profiles.Arena) or "|cff999999"..L.cd2DontChange)
		self.autoBGDown:SetText(GetTextProfileName(VMRT.ExCD2.Profiles.BG) or "|cff999999"..L.cd2DontChange)
		self.autoOtherDown:SetText(GetTextProfileName(VMRT.ExCD2.Profiles.Other) or "|cff999999"..L.cd2DontChange)
	end

	local function AutoDropDown_ToggleUpadte(self)
		local func = function(_,arg1)
			ELib:DropDownClose()
			VMRT.ExCD2.Profiles[self.OptKey] = arg1
			profilesTab:UpdateAutoTexts()
		end
		self.List = GetCurrentProfilesList(func)
		tinsert(self.List,1,{text = L.cd2DontChange, func = func})
	end

	profilesTab.autoRaidDown = ELib:DropDown(profilesTab,220,10):Point(10,-335):Size(235):AddText(RAID,11,function(self)self:NewPoint("TOPLEFT",'x',5,12):Color(1,.82,0,1) end)
	profilesTab.autoRaidDown.OptKey = "Raid"
	profilesTab.autoRaidDown.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab.autoDungDown = ELib:DropDown(profilesTab,220,10):Point("TOPLEFT",profilesTab.autoRaidDown,0,-40):Size(235):AddText(CALENDAR_TYPE_DUNGEON,11,function(self)self:NewPoint("TOPLEFT",'x',5,12):Color(1,.82,0,1) end)
	profilesTab.autoDungDown.OptKey = "Dung"
	profilesTab.autoDungDown.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab.autoArenaDown = ELib:DropDown(profilesTab,220,10):Point("TOPLEFT",profilesTab.autoRaidDown,320,0):Size(235):AddText(ARENA,11,function(self)self:NewPoint("TOPLEFT",'x',5,12):Color(1,.82,0,1) end)
	profilesTab.autoArenaDown.OptKey = "Arena"
	profilesTab.autoArenaDown.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab.autoBGDown = ELib:DropDown(profilesTab,220,10):Point("TOPLEFT",profilesTab.autoArenaDown,0,-40):Size(235):AddText(BATTLEGROUND,11,function(self)self:NewPoint("TOPLEFT",'x',5,12):Color(1,.82,0,1) end)
	profilesTab.autoBGDown.OptKey = "BG"
	profilesTab.autoBGDown.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab.autoOtherDown = ELib:DropDown(profilesTab,220,10):Point("TOPLEFT",profilesTab.autoDungDown,0,-40):Size(235):AddText(OTHER,11,function(self)self:NewPoint("TOPLEFT",'x',5,12):Color(1,.82,0,1) end)
	profilesTab.autoOtherDown.OptKey = "Other"
	profilesTab.autoOtherDown.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab:UpdateAutoTexts()


	self.optSetTab = ELib:OneTab(self.tab.tabs[2],L.cd2OtherSet):Size(652,34):Point("TOP",0,-532)

	self.chkSplit = ELib:Check(self.optSetTab,L.cd2split,VMRT.ExCD2.SplitOpt):Point("LEFT",10,0):Tooltip(L.cd2splittooltip):OnClick(function(self,event)
		if self:GetChecked() then
			VMRT.ExCD2.SplitOpt = true
		else
			VMRT.ExCD2.SplitOpt = nil
		end


		module:SplitExCD2Window()
		module:UpdateLockState()
		module:ReloadAllSplits()
	end)

	self.chkNoRaid = ELib:Check(self.optSetTab,L.cd2noraid,VMRT.ExCD2.NoRaid):Point("LEFT",165,0):OnClick(function(self,event)
		if self:GetChecked() then
			VMRT.ExCD2.NoRaid = true
		else
			VMRT.ExCD2.NoRaid = nil
		end
		module:UpdateRoster()
	end)

	self.testMode = ELib:Check(self.optSetTab,L.cd2GeneralSetTestMode,module.db.testMode):Point("LEFT",325,0):Tooltip(L.cd2HelpTestButton):OnClick(function(self,event)
		if self:GetChecked() then
			module.db.testMode = true
		else
			module.db.testMode = nil
			TestMode(1)
		end
		module:UpdateSpellDB(true)
	end)

	self.butResetToDef = ELib:Button(self.optSetTab,L.cd2OtherSetReset):Size(160,20):Point("LEFT",480,0):Tooltip(L.cd2HelpButtonDefault):OnClick(function()
		local tabSelected = module.options.optColTabs.selected
		StaticPopupDialogs["EXRT_EXCD_DEFAULT"] = {
			text = L.cd2OtherSetReset,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				if not VMRT.ExCD2.colSet[tabSelected] then
					VMRT.ExCD2.colSet[tabSelected] = {}
				end
				table_wipe2(VMRT.ExCD2.colSet[tabSelected])
				for optName,optVal in pairs(module.db.colsInit) do
					VMRT.ExCD2.colSet[tabSelected][optName] = optVal
				end

				module.options.selectColumnTab(self.optColTabs.tabs[tabSelected].button)
				module:ReloadAllSplits()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_EXCD_DEFAULT")
	end)


	self.butHistoryClear = ELib:Button(self.tab.tabs[3],L.cd2HistoryClear):Size(180,20):Point("TOPRIGHT",-3,-6):OnClick(function()
		table_wipe2(module.db.historyUsage)
		module.options.historyBox.EditBox:SetText("")
	end)

	local historyBoxUpdateTable = {}
	local function historyBoxUpdate(v)
		table_wipe2(historyBoxUpdateTable)
		local count = 0
		for i=1,#module.db.historyUsage do
			if VMRT.ExCD2.CDE[module.db.historyUsage[i][2]] then
				count = count + 1
			end
			if count >= v and VMRT.ExCD2.CDE[module.db.historyUsage[i][2]] then
				local tm = date("%X",module.db.historyUsage[i][1])
				local bosshpstr = module.db.historyUsage[i][4] and format(" (%d:%.2d)",module.db.historyUsage[i][4]/60,module.db.historyUsage[i][4]%60) or ""
				local spellName,_,spellIcon = GetSpellInfo(module.db.historyUsage[i][2])
				local destName = module.db.historyUsage[i][5]
				local destStr = ""
				if destName and destName ~= "" and destName ~= "*" then
					local _, destClass = UnitClass(destName)
					destClass = destClass or module.db.historyUsage[i][7]
					if destClass and ExRT.F.classColor then
						destStr = " |cffaaaaaa→|r |c"..ExRT.F.classColor(destClass)..destName.."|r"
					else
						destStr = " |cffaaaaaa→|r "..destName
					end
				end
				local playerName = module.db.historyUsage[i][3] or "?"
				local playerClass = module.db.historyUsage[i][6]
				if not playerClass and module.db.historyUsage[i][3] then
					_, playerClass = UnitClass(module.db.historyUsage[i][3])
				end
				local playerStr = playerName
				if playerClass and ExRT.F.classColor then
					playerStr = "|c"..ExRT.F.classColor(playerClass)..playerName.."|r"
				end
				historyBoxUpdateTable [#historyBoxUpdateTable + 1] = format("|cffffff00[%s]%s|r %s |Hspell:%d|h|T%s:0|t%s|h%s",tm,bosshpstr,playerStr,module.db.historyUsage[i][2] or 0,spellIcon or "Interface\\Icons\\Trade_Engineering",spellName or "?",destStr)
			end
			if #historyBoxUpdateTable > 44 then
				break
			end
		end
		module.options.historyBox.EditBox:SetText(strjoin("\n",unpack(historyBoxUpdateTable)))
	end

	self.historyBox = ELib:MultiEdit2(self.tab.tabs[3]):Size(840,550):Point("TOP",0,-36):Hyperlinks()
	self.historyBox.EditBox:SetScript("OnShow",function(self)
		historyBoxUpdate(1)
		local count = 0
		for i=1,#module.db.historyUsage do
			if VMRT.ExCD2.CDE[module.db.historyUsage[i][2]] then
				count = count + 1
			end
		end
		module.options.historyBox.ScrollBar:SetMinMaxValues(1,max(count,1))
		module.options.historyBox.ScrollBar:UpdateButtons()
	end)
	self.historyBox.ScrollBar:SetScript("OnValueChanged",function (self,val)
		val = ExRT.F.Round(val)
		historyBoxUpdate(val)
		self:UpdateButtons()
	end)

	self.HelpPlate = {
		[1] = {},
		[2] = {
			FramePos = { x = 90, y = 25 },FrameSize = { width = 660, height = 615 },
			[1] = { ButtonPos = { x = 50,	y = -110 },  	HighLightBox = { x = 0, y = -50, width = 660, height = 480 },		ToolTipDir = "RIGHT",	ToolTipText = L.cd2HelpColSetup },
			[2] = { ButtonPos = { x = 320,	y = -550 },  	HighLightBox = { x = 315, y = -560, width = 140, height = 30 },		ToolTipDir = "LEFT",	ToolTipText = L.cd2HelpTestButton },
			[3] = { ButtonPos = { x = 500,	y = -550 },  	HighLightBox = { x = 490, y = -560, width = 160, height = 30 },		ToolTipDir = "LEFT",	ToolTipText = L.cd2HelpButtonDefault },
		},
	}


	self.isWide = true

	module:CreateSpellData(true)
end

local function CreateBlackList(text)
	local blacklist = {}
	local tmpList = {strsplit("\n", text)}
	for i=1,#tmpList do
		if tmpList[i]~="" then
			if tmpList[i]:find(":(%d+)") then
				local name,spellID = tmpList[i]:match("([^:]+):(%d+)")
				if name and spellID then
					spellID = tonumber(spellID)
					blacklist[ spellID ] = blacklist[ spellID ] or {}
					name = name:lower()
					blacklist[ spellID ][name] = true
				end
			else
				tmpList[i] = tmpList[i]:lower()
				blacklist[ tmpList[i] ] = true
			end
		end
	end
	return blacklist
end
local function CreateWhiteList(text)
	if text == "" then
		return
	end
	local whitelist = {}
	local tmpList = {strsplit("\n", text)}
	for i=1,#tmpList do
		if tmpList[i]~="" then
			tmpList[i] = tmpList[i]:lower()
			whitelist[ tmpList[i] ] = true
		end
	end
	return whitelist
end

local function IconGlowNoLibStart(self)
	local LCG = LibStub("LibCustomGlow-1.0-MRT",true) or LibStub("LibCustomGlow-1.0",true)
	if not LCG then
		return
	end
	local p = self:GetParent().parent
	local iconGlowType = p.optionGlowType
	local glowColor = p.optionGlowColor
	if (not iconGlowType or iconGlowType == 1) then
		return LCG.ButtonGlow_Start(self, glowColor)
	elseif iconGlowType == 2 then
		return LCG.AutoCastGlow_Start(self, glowColor)
	elseif iconGlowType == 3 then
		return LCG.PixelGlow_Start(self, glowColor)
	elseif iconGlowType == 4 then
		return ExRT.NULLfunc(self)
	end
end

local function IconGlowNoLibStop(self)
	local LCG = LibStub("LibCustomGlow-1.0-MRT",true) or LibStub("LibCustomGlow-1.0",true)
	if not LCG then
		return
	end
	local iconGlowType = self:GetParent().parent.optionGlowType
	if (not iconGlowType or iconGlowType == 1) then
		return LCG.ButtonGlow_Stop(self)
	elseif iconGlowType == 2 then
		return LCG.AutoCastGlow_Stop(self)
	elseif iconGlowType == 3 then
		return LCG.PixelGlow_Stop(self)
	elseif iconGlowType == 4 then
		return ExRT.NULLfunc(self)
	end
end

function module:ColApplyStyle(columnFrame,currColOpt,generalOpt,defOpt,mainWidth,argScaleFix)
	local LCG = LibStub("LibCustomGlow-1.0-MRT",true) or LibStub("LibCustomGlow-1.0",true)

	if not columnFrame.LOADEDs then
		columnFrame.LOADEDs = {}
	end

	columnFrame.iconSize = (not currColOpt.iconGeneral and currColOpt.iconSize) or (currColOpt.iconGeneral and generalOpt.iconSize) or defOpt.iconSize

	local effMethodsCooldown = (not currColOpt.iconGeneral and currColOpt.methodsCooldown) or (currColOpt.iconGeneral and generalOpt.methodsCooldown)
	local effIconSeparateHW = (not currColOpt.iconGeneral and currColOpt.iconSeparateHW) or (currColOpt.iconGeneral and generalOpt.iconSeparateHW)
	local effIconHeight = (not currColOpt.iconGeneral and currColOpt.iconHeight) or (currColOpt.iconGeneral and generalOpt.iconHeight) or columnFrame.iconSize
	if currColOpt.ATF then
		effIconSeparateHW = false
	end
	columnFrame.iconHeight = (effMethodsCooldown and effIconSeparateHW and effIconHeight) or columnFrame.iconSize

	local frameBetweenLines = (not currColOpt.frameGeneral and currColOpt.frameBetweenLines) or (currColOpt.frameGeneral and generalOpt.frameBetweenLines) or defOpt.frameBetweenLines
	columnFrame.frameBetweenLines = frameBetweenLines

	local frameColumns = (not currColOpt.frameGeneral and currColOpt.frameColumns) or (currColOpt.frameGeneral and generalOpt.frameColumns) or defOpt.frameColumns
	columnFrame.frameColumns = frameColumns
	local linesShown = (not currColOpt.frameGeneral and currColOpt.frameLines) or (currColOpt.frameGeneral and generalOpt.frameLines) or defOpt.frameLines
	linesShown = ceil(linesShown / frameColumns)
	columnFrame.GlinesShown = linesShown
	local linesTotal = min(linesShown * frameColumns,module.db.maxLinesInCol)
	if currColOpt.ATF then
		linesTotal = 150
	end
	if VMRT.ExCD2.SplitOpt then
		columnFrame.Gheight = columnFrame.iconHeight*linesShown+frameBetweenLines*(linesShown-1)
		columnFrame:SetHeight(columnFrame.iconHeight*linesShown+frameBetweenLines*(linesShown-1))
	elseif not currColOpt.ATF then
		columnFrame.Gheight = columnFrame.iconHeight*linesShown
		columnFrame:SetHeight(columnFrame.iconHeight*linesShown)
	end
	columnFrame.NumberLastLinesActive = max(linesTotal,module.db.maxLinesInCol,#columnFrame.lines)

	if currColOpt.enabled then
		for j=1,linesTotal do
			if not columnFrame.LOADEDs[j] then
				columnFrame.lines[j] = CreateBar(columnFrame)
				columnFrame.lines[j]:Hide()
				columnFrame.LOADEDs[j] = true
			end
		end
		columnFrame.IsColumnEnabled = true
	else
		columnFrame.IsColumnEnabled = false
	end

	local frameStrata = (not currColOpt.frameGeneral and currColOpt.frameStrata) or (currColOpt.frameGeneral and generalOpt.frameStrata) or defOpt.frameStrata
	if currColOpt.ATF then
		if not ( (not currColOpt.frameGeneral and currColOpt.frameStrata) or (currColOpt.frameGeneral and generalOpt.frameStrata) ) then
			columnFrame.autoStrata = true
		else
			columnFrame.autoStrata = false
		end
	else
		columnFrame.autoStrata = false
	end
	columnFrame:SetFrameStrata(frameStrata)
	columnFrame.FrameStrata = nil

	local frameAlpha = (not currColOpt.frameGeneral and currColOpt.frameAlpha) or (currColOpt.frameGeneral and generalOpt.frameAlpha) or defOpt.frameAlpha
	columnFrame:SetAlpha(frameAlpha/100)

	local frameScale = (not currColOpt.frameGeneral and currColOpt.frameScale) or (currColOpt.frameGeneral and generalOpt.frameScale) or defOpt.frameScale
	local colRelScale
	if VMRT.ExCD2.SplitOpt then
		colRelScale = frameScale/100
	else
		if currColOpt.frameGeneral then
			colRelScale = 1
		else
			local gScale = generalOpt.frameScale or defOpt.frameScale
			colRelScale = ((currColOpt.frameScale or defOpt.frameScale) / gScale)
		end
	end
	columnFrame.Gscale = colRelScale
	if argScaleFix == "ScaleFix" then
		ExRT.F.SetScaleFix(columnFrame,colRelScale)
	else
		columnFrame:SetScale(colRelScale)
	end

	local blackBack = (not currColOpt.frameGeneral and currColOpt.frameBlackBack) or (currColOpt.frameGeneral and generalOpt.frameBlackBack) or defOpt.frameBlackBack
	columnFrame.texture:SetColorTexture(0,0,0,blackBack / 100)


	columnFrame.optionClassColorBackground = (not currColOpt.textureGeneral and currColOpt.textureClassBackground) or (currColOpt.textureGeneral and generalOpt.textureClassBackground)
	columnFrame.optionClassColorTimeLine = (not currColOpt.textureGeneral and currColOpt.textureClassTimeLine) or (currColOpt.textureGeneral and generalOpt.textureClassTimeLine)
	columnFrame.optionClassColorText = (not currColOpt.textureGeneral and currColOpt.textureClassText) or (currColOpt.textureGeneral and generalOpt.textureClassText)

	columnFrame.optionAnimation = (not currColOpt.textureGeneral and currColOpt.textureAnimation) or (currColOpt.textureGeneral and generalOpt.textureAnimation)
	columnFrame.optionSmoothAnimation = (not currColOpt.textureGeneral and currColOpt.textureSmoothAnimation) or (currColOpt.textureGeneral and generalOpt.textureSmoothAnimation)
	columnFrame.optionSmoothAnimationDuration = (not currColOpt.textureGeneral and currColOpt.textureSmoothAnimationDuration) or (currColOpt.textureGeneral and generalOpt.textureSmoothAnimationDuration) or defOpt.textureSmoothAnimationDuration
		columnFrame.optionSmoothAnimationDuration = columnFrame.optionSmoothAnimationDuration / 200
	columnFrame.optionLinesMax = linesTotal
	columnFrame.optionShownOnCD = (not currColOpt.methodsGeneral and currColOpt.methodsShownOnCD) or (currColOpt.methodsGeneral and generalOpt.methodsShownOnCD)
	columnFrame.optionIconPosition = (not currColOpt.iconGeneral and currColOpt.iconPosition) or (currColOpt.iconGeneral and generalOpt.iconPosition) or defOpt.iconPosition
	columnFrame.optionStyleAnimation = (not currColOpt.methodsGeneral and currColOpt.methodsStyleAnimation) or (currColOpt.methodsGeneral and generalOpt.methodsStyleAnimation) or defOpt.methodsStyleAnimation
	columnFrame.optionTimeLineAnimation = (not currColOpt.methodsGeneral and currColOpt.methodsTimeLineAnimation) or (currColOpt.methodsGeneral and generalOpt.methodsTimeLineAnimation) or defOpt.methodsTimeLineAnimation
	columnFrame.optionCooldown = (not currColOpt.iconGeneral and currColOpt.methodsCooldown) or (currColOpt.iconGeneral and generalOpt.methodsCooldown)
	columnFrame.optionCooldownHideNumbers = (not currColOpt.iconGeneral and currColOpt.iconCooldownHideNumbers) or (currColOpt.iconGeneral and generalOpt.iconCooldownHideNumbers)
	columnFrame.optionCooldownUseExRT = (not currColOpt.iconGeneral and currColOpt.iconCooldownExRTNumbers) or (currColOpt.iconGeneral and generalOpt.iconCooldownExRTNumbers)
		if columnFrame.optionCooldownUseExRT then columnFrame.optionCooldownHideNumbers = true end
	columnFrame.optionCooldownShowSwipe = (not currColOpt.iconGeneral and currColOpt.iconCooldownShowSwipe) or (currColOpt.iconGeneral and generalOpt.iconCooldownShowSwipe)
	columnFrame.optionIconName = (not currColOpt.textGeneral and currColOpt.textIconName) or (currColOpt.textGeneral and generalOpt.textIconName)
	columnFrame.textShowTargetName = (not currColOpt.textGeneral and currColOpt.textShowTargetName) or (currColOpt.textGeneral and generalOpt.textShowTargetName)
	columnFrame.optionHideSpark = (not currColOpt.textureGeneral and currColOpt.textureHideSpark) or (currColOpt.textureGeneral and generalOpt.textureHideSpark)
	columnFrame.optionIconTitles = (not currColOpt.iconGeneral and currColOpt.iconTitles) or (currColOpt.iconGeneral and generalOpt.iconTitles)
		columnFrame.optionIconTitles = columnFrame.optionIconTitles and not (columnFrame.optionIconPosition == 3)
	columnFrame.optionIconHideBlizzardEdges = (not currColOpt.iconGeneral and currColOpt.iconHideBlizzardEdges) or (currColOpt.iconGeneral and generalOpt.iconHideBlizzardEdges)

	local iconGlowType = (not currColOpt.iconGeneral and currColOpt.iconGlowType) or (currColOpt.iconGeneral and generalOpt.iconGlowType) or defOpt.iconGlowType
	columnFrame.optionGlowType = iconGlowType
	local glowR = (not currColOpt.iconGeneral and currColOpt.iconGlowColorR) or (currColOpt.iconGeneral and generalOpt.iconGlowColorR) or defOpt.iconGlowColorR
	local glowG = (not currColOpt.iconGeneral and currColOpt.iconGlowColorG) or (currColOpt.iconGeneral and generalOpt.iconGlowColorG) or defOpt.iconGlowColorG
	local glowB = (not currColOpt.iconGeneral and currColOpt.iconGlowColorB) or (currColOpt.iconGeneral and generalOpt.iconGlowColorB) or defOpt.iconGlowColorB
	local glowA = (not currColOpt.iconGeneral and currColOpt.iconGlowColorA) or (currColOpt.iconGeneral and generalOpt.iconGlowColorA) or defOpt.iconGlowColorA
	local glowColor = {glowR, glowG, glowB, glowA}
	columnFrame.optionGlowColor = glowColor
	local glowStart, glowStop
	if LCG and (not iconGlowType or iconGlowType == 1) then
		glowStart, glowStop = LCG.ButtonGlow_Start, LCG.ButtonGlow_Stop
	elseif LCG and iconGlowType == 2 then
		glowStart, glowStop = LCG.AutoCastGlow_Start, LCG.AutoCastGlow_Stop
	elseif LCG and iconGlowType == 3 then
		glowStart, glowStop = LCG.PixelGlow_Start, LCG.PixelGlow_Stop
	elseif LCG and iconGlowType == 4 then
		glowStart, glowStop = ExRT.NULLfunc, ExRT.NULLfunc
	elseif not LCG then
		glowStart, glowStop = IconGlowNoLibStart, IconGlowNoLibStop
	end
	if glowStart and glowStart ~= ExRT.NULLfunc and iconGlowType ~= 4 then
		local origStart = glowStart
		columnFrame.glowStart = function(r) origStart(r, glowColor) end
	else
		columnFrame.glowStart = glowStart or ExRT.NULLfunc
	end
	columnFrame.glowStop = glowStop or ExRT.NULLfunc

	columnFrame.methodsIconTooltip = (not currColOpt.methodsGeneral and currColOpt.methodsIconTooltip) or (currColOpt.methodsGeneral and generalOpt.methodsIconTooltip)
	columnFrame.methodsLineClick = (not currColOpt.methodsGeneral and currColOpt.methodsLineClick) or (currColOpt.methodsGeneral and generalOpt.methodsLineClick)
	columnFrame.methodsLineClickWhisper = (not currColOpt.methodsGeneral and currColOpt.methodsLineClickWhisper) or (currColOpt.methodsGeneral and generalOpt.methodsLineClickWhisper)
	columnFrame.methodsNewSpellNewLine = (not currColOpt.methodsGeneral and currColOpt.methodsNewSpellNewLine) or (currColOpt.methodsGeneral and generalOpt.methodsNewSpellNewLine)
	columnFrame.methodsSortingRules = (not currColOpt.methodsGeneral and currColOpt.methodsSortingRules) or (currColOpt.methodsGeneral and generalOpt.methodsSortingRules) or defOpt.methodsSortingRules
	columnFrame.methodsHideOwnSpells = (not currColOpt.methodsGeneral and currColOpt.methodsHideOwnSpells) or (currColOpt.methodsGeneral and generalOpt.methodsHideOwnSpells)
	columnFrame.methodsAlphaNotInRange = (not currColOpt.methodsGeneral and currColOpt.methodsAlphaNotInRange) or (currColOpt.methodsGeneral and generalOpt.methodsAlphaNotInRange)
	columnFrame.methodsAlphaNotInRangeNum = (not currColOpt.methodsGeneral and currColOpt.methodsAlphaNotInRangeNum) or (currColOpt.methodsGeneral and generalOpt.methodsAlphaNotInRangeNum) or defOpt.methodsAlphaNotInRangeNum
		columnFrame.methodsAlphaNotInRangeNum = columnFrame.methodsAlphaNotInRangeNum / 100
	columnFrame.methodsDisableActive = (not currColOpt.methodsGeneral and currColOpt.methodsDisableActive) or (currColOpt.methodsGeneral and generalOpt.methodsDisableActive)
	columnFrame.methodsOneSpellPerCol = (not currColOpt.methodsGeneral and currColOpt.methodsOneSpellPerCol) or (currColOpt.methodsGeneral and generalOpt.methodsOneSpellPerCol)

	columnFrame.methodsSortByAvailability = (not currColOpt.methodsGeneral and currColOpt.methodsSortByAvailability) or (currColOpt.methodsGeneral and generalOpt.methodsSortByAvailability)
	columnFrame.methodsSortActiveToTop = (not currColOpt.methodsGeneral and currColOpt.methodsSortActiveToTop) or (currColOpt.methodsGeneral and generalOpt.methodsSortActiveToTop)
	columnFrame.methodsReverseSorting = (not currColOpt.methodsGeneral and currColOpt.methodsReverseSorting) or (currColOpt.methodsGeneral and generalOpt.methodsReverseSorting)
	columnFrame.methodsReverseSorting = (not currColOpt.methodsGeneral and currColOpt.methodsReverseSorting) or (currColOpt.methodsGeneral and generalOpt.methodsReverseSorting)
	columnFrame.methodsCDOnlyTime = (not currColOpt.methodsGeneral and currColOpt.methodsCDOnlyTime) or (currColOpt.methodsGeneral and generalOpt.methodsCDOnlyTime)
	columnFrame.methodsTextIgnoreActive = (not currColOpt.methodsGeneral and currColOpt.methodsTextIgnoreActive) or (currColOpt.methodsGeneral and generalOpt.methodsTextIgnoreActive)
	columnFrame.methodsOnlyNotOnCD = (not currColOpt.methodsGeneral and currColOpt.methodsOnlyNotOnCD) or (currColOpt.methodsGeneral and generalOpt.methodsOnlyNotOnCD)

	columnFrame.methodsOnlyInCombat = (not currColOpt.visibilityGeneral and currColOpt.methodsOnlyInCombat) or (currColOpt.visibilityGeneral and generalOpt.methodsOnlyInCombat)
	columnFrame.visibilityPartyType = (not currColOpt.visibilityGeneral and currColOpt.visibilityPartyType) or (currColOpt.visibilityGeneral and generalOpt.visibilityPartyType)
	columnFrame.visibilityArena = not ( (not currColOpt.visibilityGeneral and currColOpt.visibilityDisableArena) or (currColOpt.visibilityGeneral and generalOpt.visibilityDisableArena) )
	columnFrame.visibilityBG = not ( (not currColOpt.visibilityGeneral and currColOpt.visibilityDisableBG) or (currColOpt.visibilityGeneral and generalOpt.visibilityDisableBG) )
	columnFrame.visibility3ppl = not ( (not currColOpt.visibilityGeneral and currColOpt.visibilityDisable3ppl) or (currColOpt.visibilityGeneral and generalOpt.visibilityDisable3ppl) )
	columnFrame.visibility5ppl = not ( (not currColOpt.visibilityGeneral and currColOpt.visibilityDisable5ppl) or (currColOpt.visibilityGeneral and generalOpt.visibilityDisable5ppl) )
	columnFrame.visibilityRaid = not ( (not currColOpt.visibilityGeneral and currColOpt.visibilityDisableRaid) or (currColOpt.visibilityGeneral and generalOpt.visibilityDisableRaid) )
	columnFrame.visibilityWorld = not ( (not currColOpt.visibilityGeneral and currColOpt.visibilityDisableWorld) or (currColOpt.visibilityGeneral and generalOpt.visibilityDisableWorld) )

	columnFrame.textTemplateLeft = (not currColOpt.textGeneral and currColOpt.textTemplateLeft) or (currColOpt.textGeneral and generalOpt.textTemplateLeft) or defOpt.textTemplateLeft
	columnFrame.textTemplateRight = (not currColOpt.textGeneral and currColOpt.textTemplateRight) or (currColOpt.textGeneral and generalOpt.textTemplateRight) or defOpt.textTemplateRight
	columnFrame.textTemplateCenter = (not currColOpt.textGeneral and currColOpt.textTemplateCenter) or (currColOpt.textGeneral and generalOpt.textTemplateCenter) or defOpt.textTemplateCenter

	columnFrame.textIconNameChars = (not currColOpt.textGeneral and currColOpt.textIconNameChars) or (currColOpt.textGeneral and generalOpt.textIconNameChars) or defOpt.textIconNameChars
	columnFrame.textIconCDStyle = (not currColOpt.textGeneral and currColOpt.textIconCDStyle) or (currColOpt.textGeneral and generalOpt.textIconCDStyle) or defOpt.textIconCDStyle

	local function pickIconFont(field)
		if currColOpt.textGeneral then
			return generalOpt[field]
		end
		return currColOpt[field]
	end
	columnFrame.iconFontMode = (not currColOpt.textGeneral and currColOpt.iconFontMode)
		or (currColOpt.textGeneral and generalOpt.iconFontMode)
		or false
	if currColOpt.ATF then
		columnFrame.iconFontMode = false
	end
	if columnFrame.iconFontMode then
		columnFrame.optionCooldownHideNumbers = true
		columnFrame.optionCooldownUseExRT = false
	end
	columnFrame.iconFontTopTemplate = pickIconFont("iconFontTopTemplate") or defOpt.iconFontTopTemplate
	columnFrame.iconFontTopAnchor = pickIconFont("iconFontTopAnchor") or defOpt.iconFontTopAnchor
	columnFrame.iconFontTopX = pickIconFont("iconFontTopX") or defOpt.iconFontTopX
	columnFrame.iconFontTopY = pickIconFont("iconFontTopY") or defOpt.iconFontTopY
	columnFrame.iconFontTopPos = pickIconFont("iconFontTopPos") or defOpt.iconFontTopPos
	columnFrame.iconFontTopGrowth = pickIconFont("iconFontTopGrowth") or defOpt.iconFontTopGrowth
	columnFrame.iconFontCenterTemplate = pickIconFont("iconFontCenterTemplate") or defOpt.iconFontCenterTemplate
	columnFrame.iconFontCenterAnchor = pickIconFont("iconFontCenterAnchor") or defOpt.iconFontCenterAnchor
	columnFrame.iconFontCenterX = pickIconFont("iconFontCenterX") or defOpt.iconFontCenterX
	columnFrame.iconFontCenterY = pickIconFont("iconFontCenterY") or defOpt.iconFontCenterY
	columnFrame.iconFontCenterPos = pickIconFont("iconFontCenterPos") or defOpt.iconFontCenterPos
	columnFrame.iconFontCenterGrowth = pickIconFont("iconFontCenterGrowth") or defOpt.iconFontCenterGrowth
	columnFrame.iconFontBottomTemplate = pickIconFont("iconFontBottomTemplate") or defOpt.iconFontBottomTemplate
	columnFrame.iconFontBottomAnchor = pickIconFont("iconFontBottomAnchor") or defOpt.iconFontBottomAnchor
	columnFrame.iconFontBottomX = pickIconFont("iconFontBottomX") or defOpt.iconFontBottomX
	columnFrame.iconFontBottomY = pickIconFont("iconFontBottomY") or defOpt.iconFontBottomY
	columnFrame.iconFontBottomPos = pickIconFont("iconFontBottomPos") or defOpt.iconFontBottomPos
	columnFrame.iconFontBottomGrowth = pickIconFont("iconFontBottomGrowth") or defOpt.iconFontBottomGrowth

	local blacklistText = (not currColOpt.blacklistGeneral and currColOpt.blacklistText) or (currColOpt.blacklistGeneral and generalOpt.blacklistText) or defOpt.blacklistText
	columnFrame.BlackList = CreateBlackList(blacklistText)
	local whitelistText = (not currColOpt.blacklistGeneral and currColOpt.whitelistText) or (currColOpt.blacklistGeneral and generalOpt.whitelistText) or defOpt.whitelistText
	columnFrame.WhiteList = CreateWhiteList(whitelistText)

	local frameWidth = (not currColOpt.frameGeneral and currColOpt.frameWidth) or (currColOpt.frameGeneral and generalOpt.frameWidth) or defOpt.frameWidth
	columnFrame:SetWidth(frameWidth*frameColumns)
	columnFrame.barWidth = frameWidth

	columnFrame.optionGray = (not currColOpt.iconGeneral and currColOpt.iconGray) or (currColOpt.iconGeneral and generalOpt.iconGray)
	columnFrame.fontSize = (not currColOpt.fontGeneral and currColOpt.fontSize) or (currColOpt.fontGeneral and generalOpt.fontSize) or defOpt.fontSize
	columnFrame.fontName = (not currColOpt.fontGeneral and currColOpt.fontName) or (currColOpt.fontGeneral and generalOpt.fontName) or defOpt.fontName
	columnFrame.fontOutline = (not currColOpt.fontGeneral and currColOpt.fontOutline) or (currColOpt.fontGeneral and generalOpt.fontOutline)
	columnFrame.fontShadow = (not currColOpt.fontGeneral and currColOpt.fontShadow) or (currColOpt.fontGeneral and generalOpt.fontShadow)
	columnFrame.textureFile = (not currColOpt.textureGeneral and currColOpt.textureFile) or (currColOpt.textureGeneral and generalOpt.textureFile) or defOpt.textureFile
	columnFrame.textureBorderSize = (not currColOpt.textureGeneral and currColOpt.textureBorderSize) or (currColOpt.textureGeneral and generalOpt.textureBorderSize) or defOpt.textureBorderSize

	columnFrame.textureBorderColorR = (not currColOpt.textureGeneral and currColOpt.textureBorderColorR) or (currColOpt.textureGeneral and generalOpt.textureBorderColorR) or defOpt.textureBorderColorR
	columnFrame.textureBorderColorG = (not currColOpt.textureGeneral and currColOpt.textureBorderColorG) or (currColOpt.textureGeneral and generalOpt.textureBorderColorG) or defOpt.textureBorderColorG
	columnFrame.textureBorderColorB = (not currColOpt.textureGeneral and currColOpt.textureBorderColorB) or (currColOpt.textureGeneral and generalOpt.textureBorderColorB) or defOpt.textureBorderColorB
	columnFrame.textureBorderColorA = (not currColOpt.textureGeneral and currColOpt.textureBorderColorA) or (currColOpt.textureGeneral and generalOpt.textureBorderColorA) or defOpt.textureBorderColorA

	local fontOtherAvailable = (not currColOpt.fontGeneral and currColOpt.fontOtherAvailable) or (currColOpt.fontGeneral and generalOpt.fontOtherAvailable)

	local fontOpts = (not currColOpt.fontGeneral and currColOpt) or (currColOpt.fontGeneral and generalOpt)

	columnFrame.fontLeftSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontLeftSize) or defOpt.fontSize
	columnFrame.fontLeftName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontLeftName) or defOpt.fontName
	columnFrame.fontLeftOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontLeftOutline)
	columnFrame.fontLeftShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontLeftShadow)
	columnFrame.fontLeftX = (fontOtherAvailable and fontOpts.fontLeftX) or 0
	columnFrame.fontLeftY = (fontOtherAvailable and fontOpts.fontLeftY) or 0

	columnFrame.fontRightSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontRightSize) or defOpt.fontSize
	columnFrame.fontRightName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontRightName) or defOpt.fontName
	columnFrame.fontRightOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontRightOutline)
	columnFrame.fontRightShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontRightShadow)
	columnFrame.fontRightX = (fontOtherAvailable and fontOpts.fontRightX) or 0
	columnFrame.fontRightY = (fontOtherAvailable and fontOpts.fontRightY) or 0

	columnFrame.fontCenterSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontCenterSize) or defOpt.fontSize
	columnFrame.fontCenterName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontCenterName) or defOpt.fontName
	columnFrame.fontCenterOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontCenterOutline)
	columnFrame.fontCenterShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontCenterShadow)
	columnFrame.fontCenterX = (fontOtherAvailable and fontOpts.fontCenterX) or 0
	columnFrame.fontCenterY = (fontOtherAvailable and fontOpts.fontCenterY) or 0

	columnFrame.fontIconSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontIconSize) or defOpt.fontSize
	columnFrame.fontIconName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontIconName) or defOpt.fontName
	columnFrame.fontIconOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontIconOutline)
	columnFrame.fontIconShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontIconShadow)
	columnFrame.fontIconX = (fontOtherAvailable and fontOpts.fontIconX) or 0
	columnFrame.fontIconY = (fontOtherAvailable and fontOpts.fontIconY) or 0

	columnFrame.fontIconCDSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontIconCDSize) or defOpt.fontSize
	columnFrame.fontIconCDName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontIconCDName) or defOpt.fontName
	columnFrame.fontIconCDOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontIconCDOutline)
	columnFrame.fontIconCDShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontIconCDShadow)
	columnFrame.fontIconCDX = (fontOtherAvailable and fontOpts.fontIconCDX) or 0
	columnFrame.fontIconCDY = (fontOtherAvailable and fontOpts.fontIconCDY) or 0

	columnFrame.fontIconTopSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontIconTopSize) or defOpt.fontSize
	columnFrame.fontIconTopName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontIconTopName) or defOpt.fontName
	columnFrame.fontIconTopOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontIconTopOutline)
	columnFrame.fontIconTopShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontIconTopShadow)

	columnFrame.fontIconMidSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontIconMidSize) or defOpt.fontSize
	columnFrame.fontIconMidName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontIconMidName) or defOpt.fontName
	columnFrame.fontIconMidOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontIconMidOutline)
	columnFrame.fontIconMidShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontIconMidShadow)

	columnFrame.fontIconBotSize = (not fontOtherAvailable and fontOpts.fontSize) or (fontOtherAvailable and fontOpts.fontIconBotSize) or defOpt.fontSize
	columnFrame.fontIconBotName = (not fontOtherAvailable and fontOpts.fontName) or (fontOtherAvailable and fontOpts.fontIconBotName) or defOpt.fontName
	columnFrame.fontIconBotOutline = (not fontOtherAvailable and fontOpts.fontOutline) or (fontOtherAvailable and fontOpts.fontIconBotOutline)
	columnFrame.fontIconBotShadow = (not fontOtherAvailable and fontOpts.fontShadow) or (fontOtherAvailable and fontOpts.fontIconBotShadow)

	columnFrame.fontCDSize = (not currColOpt.fontGeneral and currColOpt.fontCDSize) or (currColOpt.fontGeneral and generalOpt.fontCDSize) or defOpt.fontCDSize

	for j=1,3 do
		for n=1,3 do
			local object = colorSetupFrameColorsObjectsNames[j]
			local state = colorSetupFrameColorsNames[n]
			if not columnFrame["optionColor"..object..state] then
				columnFrame["optionColor"..object..state] = {}
			end

			columnFrame["optionColor"..object..state].r = (not currColOpt.textureGeneral and currColOpt["textureColor"..object..state.."R"]) or (currColOpt.textureGeneral and generalOpt["textureColor"..object..state.."R"]) or defOpt["textureColor"..object..state.."R"]
			columnFrame["optionColor"..object..state].g = (not currColOpt.textureGeneral and currColOpt["textureColor"..object..state.."G"]) or (currColOpt.textureGeneral and generalOpt["textureColor"..object..state.."G"]) or defOpt["textureColor"..object..state.."G"]
			columnFrame["optionColor"..object..state].b = (not currColOpt.textureGeneral and currColOpt["textureColor"..object..state.."B"]) or (currColOpt.textureGeneral and generalOpt["textureColor"..object..state.."B"]) or defOpt["textureColor"..object..state.."B"]
		end
	end

	columnFrame.optionAlphaBackground = (not currColOpt.textureGeneral and currColOpt.textureAlphaBackground) or (currColOpt.textureGeneral and generalOpt.textureAlphaBackground) or defOpt.textureAlphaBackground
	columnFrame.optionAlphaTimeLine = (not currColOpt.textureGeneral and currColOpt.textureAlphaTimeLine) or (currColOpt.textureGeneral and generalOpt.textureAlphaTimeLine) or defOpt.textureAlphaTimeLine
	columnFrame.optionAlphaCooldown = (not currColOpt.textureGeneral and currColOpt.textureAlphaCooldown) or (currColOpt.textureGeneral and generalOpt.textureAlphaCooldown) or defOpt.textureAlphaCooldown

	columnFrame.ATFenabled = currColOpt.ATF

	if currColOpt.ATF then
		local ATFPos = currColOpt.ATFPos
		local ATFGrowth = currColOpt.ATFGrowth or defOpt.ATFGrowth
		local ATFPoint1,ATFPoint2 = "BOTTOMRIGHT", "BOTTOMLEFT"
		local ATFPointCol1,ATFPointCol2 = "LEFT", "RIGHT"
		local ATFPointLine1,ATFPointLine2 = "BOTTOM", "TOP"
		local ATFBetweenLinesCol, ATFBetweenLinesLine = -frameBetweenLines, frameBetweenLines
		if ATFPos == 1 then
			ATFPoint1,ATFPoint2 = "BOTTOMRIGHT", "BOTTOMLEFT"
			ATFPointCol1,ATFPointCol2 = "RIGHT", "LEFT"
			ATFPointLine1,ATFPointLine2 = "BOTTOM", "TOP"
			ATFBetweenLinesCol, ATFBetweenLinesLine = -frameBetweenLines, frameBetweenLines
		elseif ATFPos == 2 then
			ATFPoint1,ATFPoint2 = "TOPRIGHT", "TOPLEFT"
			ATFPointCol1,ATFPointCol2 = "RIGHT", "LEFT"
			ATFPointLine1,ATFPointLine2 = "TOP", "BOTTOM"
			ATFBetweenLinesCol, ATFBetweenLinesLine = -frameBetweenLines, -frameBetweenLines
		elseif ATFPos == 3 then
			ATFPoint1,ATFPoint2 = "BOTTOMLEFT", "TOPLEFT"
			ATFPointCol1,ATFPointCol2 = "LEFT", "RIGHT"
			ATFPointLine1,ATFPointLine2 = "BOTTOM", "TOP"
			ATFBetweenLinesCol, ATFBetweenLinesLine = frameBetweenLines, frameBetweenLines
		elseif ATFPos == 4 then
			ATFPoint1,ATFPoint2 = "BOTTOMRIGHT", "TOPRIGHT"
			ATFPointCol1,ATFPointCol2 = "RIGHT", "LEFT"
			ATFPointLine1,ATFPointLine2 = "BOTTOM", "TOP"
			ATFBetweenLinesCol, ATFBetweenLinesLine = -frameBetweenLines, frameBetweenLines
		elseif ATFPos == 5 then
			ATFPoint1,ATFPoint2 = "TOPLEFT", "TOPRIGHT"
			ATFPointCol1,ATFPointCol2 = "LEFT", "RIGHT"
			ATFPointLine1,ATFPointLine2 = "TOP", "BOTTOM"
			ATFBetweenLinesCol, ATFBetweenLinesLine = frameBetweenLines, -frameBetweenLines
		elseif ATFPos == 6 then
			ATFPoint1,ATFPoint2 = "BOTTOMLEFT", "BOTTOMRIGHT"
			ATFPointCol1,ATFPointCol2 = "LEFT", "RIGHT"
			ATFPointLine1,ATFPointLine2 = "TOP", "BOTTOM"
			ATFBetweenLinesCol, ATFBetweenLinesLine = frameBetweenLines, frameBetweenLines
		elseif ATFPos == 7 then
			ATFPoint1,ATFPoint2 = "TOPRIGHT", "BOTTOMRIGHT"
			ATFPointCol1,ATFPointCol2 = "RIGHT", "LEFT"
			ATFPointLine1,ATFPointLine2 = "TOP", "BOTTOM"
			ATFBetweenLinesCol, ATFBetweenLinesLine = -frameBetweenLines, -frameBetweenLines
		elseif ATFPos == 8 then
			ATFPoint1,ATFPoint2 = "TOPLEFT", "BOTTOMLEFT"
			ATFPointCol1,ATFPointCol2 = "LEFT", "RIGHT"
			ATFPointLine1,ATFPointLine2 = "TOP", "BOTTOM"
			ATFBetweenLinesCol, ATFBetweenLinesLine = frameBetweenLines, frameBetweenLines
		elseif ATFPos == 9 then
			ATFPoint1,ATFPoint2 = "CENTER", "CENTER"
			ATFPointCol1,ATFPointCol2 = "LEFT", "RIGHT"
			ATFPointLine1,ATFPointLine2 = "TOP", "BOTTOM"
			ATFBetweenLinesCol, ATFBetweenLinesLine = frameBetweenLines, -frameBetweenLines
		end
		if ATFGrowth == 2 then
			ATFPointCol1,ATFPointCol2,ATFPointLine1,ATFPointLine2 = ATFPointLine1,ATFPointLine2,ATFPointCol1,ATFPointCol2
		end
		columnFrame.ATFPoint1 = ATFPoint1
		columnFrame.ATFPoint2 = ATFPoint2
		columnFrame.ATFPointCol1 = ATFPointCol1
		columnFrame.ATFPointCol2 = ATFPointCol2
		columnFrame.ATFPointLine1 = ATFPointLine1
		columnFrame.ATFPointLine2 = ATFPointLine2
		columnFrame.ATFBetweenLinesCol = ATFBetweenLinesCol
		columnFrame.ATFBetweenLinesLine = ATFBetweenLinesLine

		columnFrame.ATFCol = ATFGrowth == 2 and (currColOpt.ATFLines or defOpt.ATFLines) or (currColOpt.ATFCol or defOpt.ATFCol)
		columnFrame.ATFMax = (currColOpt.ATFLines or defOpt.ATFLines) * (currColOpt.ATFCol or defOpt.ATFCol)

		columnFrame.ATFOffsetX = currColOpt.ATFOffsetX or defOpt.ATFOffsetX
		columnFrame.ATFOffsetY = currColOpt.ATFOffsetY or defOpt.ATFOffsetY

		columnFrame.ATFGrowth = ATFGrowth

		local framePriorOpt
		if currColOpt.ATFFramePrior then
			local new = ExRT.F.table_find3(module.db.rframes, currColOpt.ATFFramePrior, "name")
			if new then
				new = new.opts

				framePriorOpt = ExRT.F.table_copy2(module.db.rframes_def)

				for j=#new,1,-1 do
					tinsert(framePriorOpt,1,new[j])
				end

				framePriorOpt = {
					framePriorities = framePriorOpt,
				}
			end
		end
		columnFrame.ATFFramePrior = framePriorOpt


		columnFrame.optionCooldown = true
		columnFrame.optionHideSpark = true
		columnFrame.iconSize = currColOpt.iconSize or defOpt.iconSize
		columnFrame.iconHeight = columnFrame.iconSize
		columnFrame.barWidth = columnFrame.iconSize + 0.001

		columnFrame.textTemplateLeft = ""
		columnFrame.textTemplateRight = ""
		columnFrame.textTemplateCenter = ""

		columnFrame.optionIconTitles = false
		columnFrame.optionTimeLineAnimation = 1
		columnFrame.methodsNewSpellNewLine = false

		columnFrame.texture:SetColorTexture(0,0,0,0)
	end

	local isMasqueEnabled = (not currColOpt.iconGeneral and currColOpt.iconMasque) or (currColOpt.iconGeneral and generalOpt.iconMasque)
	if isMasqueEnabled and module.db.Masque then
		if not columnFrame.Masque_Group then
			columnFrame.Masque_Group = module.db.Masque:Group("MRT", "Raid cooldowns Col "..columnFrame.colNum)
		end
	elseif columnFrame.Masque_Group then
		columnFrame.Masque_Group:Delete()
		columnFrame.Masque_Group = nil
	end

	if currColOpt.enabled then
		for n=1,#columnFrame.lines do
			local line = columnFrame.lines[n]
			line:UpdateStyle()
			if line:IsShown() then
				line:UpdateStatus()
			end
		end

		local frameAnchorBottom = (not currColOpt.methodsGeneral and currColOpt.frameAnchorBottom) or (currColOpt.methodsGeneral and generalOpt.frameAnchorBottom)
		local frameAnchorRightToLeft = (not currColOpt.methodsGeneral and currColOpt.frameAnchorRightToLeft) or (currColOpt.methodsGeneral and generalOpt.frameAnchorRightToLeft)

		local lastLine = nil
		for n=1,linesTotal do
			local line
			local colLine = columnFrame.lines[n]
			if columnFrame.ATFenabled then
				line = 1
			elseif frameAnchorBottom then
				local inLine = (n-1) % frameColumns
				line = ((n-1) - inLine) / frameColumns
				colLine:ClearAllPoints()
				if frameAnchorRightToLeft then
					colLine:SetPoint("BOTTOMRIGHT", -inLine*frameWidth, line*columnFrame.iconHeight+line*frameBetweenLines)
				else
					colLine:SetPoint("BOTTOMLEFT", inLine*frameWidth, line*columnFrame.iconHeight+line*frameBetweenLines)
				end
				colLine.ATFanchored = nil
			else
				local inLine = (n-1) % frameColumns
				line = ExRT.F.Round( ((n-1) - inLine) / frameColumns )
				colLine:ClearAllPoints()
				if frameAnchorRightToLeft then
					colLine:SetPoint("TOPRIGHT", -inLine*frameWidth, -line*columnFrame.iconHeight-line*frameBetweenLines)
				else
					colLine:SetPoint("TOPLEFT", inLine*frameWidth, -line*columnFrame.iconHeight-line*frameBetweenLines)
				end
				colLine.ATFanchored = nil
			end

			if line ~= lastLine then
				colLine.IsNewLine = true
			else
				colLine.IsNewLine = nil
			end
			lastLine = line
		end

		if columnFrame.Masque_Group then
			columnFrame.Masque_Group:ReSkin(true)
		end
	end

	if currColOpt.enabled and VMRT.ExCD2.enabled then
		columnFrame.optionIsEnabled = true
		columnFrame:Show()
	else
		columnFrame.optionIsEnabled = nil
		columnFrame:Hide()
	end
	if currColOpt.ATF then
		columnFrame:ClearAllPoints()
		columnFrame:SetPoint("LEFT",UIParent,"RIGHT",-2000, 0)
	elseif not VMRT.ExCD2.SplitOpt and mainWidth then
		columnFrame:ClearAllPoints()
		columnFrame:SetPoint("TOPLEFT",module.frame,mainWidth, 0)
	else
		if currColOpt.posX and currColOpt.posY then
			columnFrame:ClearAllPoints()
			columnFrame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",currColOpt.posX,currColOpt.posY)
		else
			columnFrame:ClearAllPoints()
			columnFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
		end
	end

	columnFrame.Gwidth = frameWidth*frameColumns
end

do
	local Masque, MSQ_Version = LibStub("Masque", true)
	if Masque then
		module.db.Masque = Masque
	end
end

local lastSplitsReload = 0
local pendingSplitsReload = nil
local pendingSplitsReloadArg = nil
function module:ReloadAllSplits(argScaleFix)
	local _ctime = GetTime()
	if lastSplitsReload > _ctime then
		if argScaleFix then
			pendingSplitsReloadArg = argScaleFix
		end
		if not pendingSplitsReload and C_Timer and C_Timer.After then
			local delay = lastSplitsReload - _ctime + 0.01
			if delay < 0.01 then delay = 0.01 end
			pendingSplitsReload = true
			C_Timer.After(delay, function()
				pendingSplitsReload = nil
				local arg = pendingSplitsReloadArg
				pendingSplitsReloadArg = nil
				module:ReloadAllSplits(arg)
			end)
		end
		return
	end
	lastSplitsReload = _ctime + 0.05
	local Width = 0
	local maxHeight = 0

	local generalOpt = VMRT.ExCD2.colSet[module.db.maxColumns+1]
	local defOpt = module.db.colsDefaults
	for i=1,module.db.maxColumns do
		local columnFrame = module.frame.colFrame[i]
		local currColOpt = VMRT.ExCD2.colSet[i]

		module:ColApplyStyle(columnFrame,currColOpt,generalOpt,defOpt,Width,argScaleFix)

		if currColOpt.enabled and not currColOpt.ATF then
			local gScale = columnFrame.Gscale or 1
			local scaledH = (columnFrame.Gheight or 0) * gScale
			if scaledH > maxHeight then
				maxHeight = scaledH
			end
			Width = Width + (columnFrame.Gwidth or 0) * gScale
		end
	end
	module.frame:SetWidth(Width)
	module.frame:SetHeight(maxHeight)
	module.frame:SetAlpha((generalOpt.frameAlpha or defOpt.frameAlpha)/100)
	if argScaleFix == "ScaleFix" then
		ExRT.F.SetScaleFix(module.frame,(generalOpt.frameScale or defOpt.frameScale)/100)
	else
		module.frame:SetScale((generalOpt.frameScale or defOpt.frameScale)/100)
	end
	module.frame:SetFrameStrata(generalOpt.frameStrata or defOpt.frameStrata)

	module:updateCombatVisibility()

	module:ATFFrameDataReset()

 	UpdateAllData()
end

function module:SplitExCD2Window()
	if VMRT.ExCD2.SplitOpt then
		for i=1,module.db.maxColumns do
			local cf = module.frame.colFrame[i]
			if not (VMRT.ExCD2.colSet[i] and VMRT.ExCD2.colSet[i].posX and VMRT.ExCD2.colSet[i].posY) then
				local left, top = cf:GetLeft(), cf:GetTop()
				if left and top and VMRT.ExCD2.colSet[i] then
					VMRT.ExCD2.colSet[i].posX = left
					VMRT.ExCD2.colSet[i].posY = top
				end
			end
			cf:SetParent(UIParent)
			cf:EnableMouse(false)
		end
		module.frame:Hide()
	else
		for i=1,module.db.maxColumns do
			module.frame.colFrame[i]:SetParent(module.frame)
			ExRT.F.LockMove(module.frame.colFrame[i],nil,module.frame.colFrame[i].lockTexture)
				ExRT.lib.AddShadowComment(module.frame.colFrame[i],1)
		end
		module.frame:Show()
	end
end

function module:UpdateLockState()
	if VMRT.ExCD2.lock then
		ExRT.F.LockMove(module.frame,nil,module.frame.texture)
			ExRT.lib.AddShadowComment(module.frame,1)
		if VMRT.ExCD2.SplitOpt then
			for i=1,module.db.maxColumns do
				ExRT.F.LockMove(module.frame.colFrame[i],nil,module.frame.colFrame[i].lockTexture)
					ExRT.lib.AddShadowComment(module.frame.colFrame[i],1)
			end
		end
	else
		ExRT.F.LockMove(module.frame,true,module.frame.texture)
			ExRT.lib.AddShadowComment(module.frame,nil,L.cd2)
		if VMRT.ExCD2.SplitOpt then
			for i=1,module.db.maxColumns do
				ExRT.F.LockMove(module.frame.colFrame[i],true,module.frame.colFrame[i].lockTexture)
					ExRT.lib.AddShadowComment(module.frame.colFrame[i],nil,L.cd2,i,72,"OUTLINE")
			end
		end
	end
end

function module:slash(arg1,arg2)
	if string.find(arg1,"cddump") then
		local id = arg1:match("cddump%s+(%d+)")
		if module.CDDump then module:CDDump(id) end
		return
	end
	if string.find(arg1,"runcd ") then
		local sid,name = arg2:match("%a+ (%d+) (.+)")
		if sid and name then
			print("Run CD "..sid.." by "..name)
			sid = tonumber(sid)
			local line = module.db.cdsNav[name][sid]
			if line then
				CLEUstartCD(line)
			end
		end
	elseif string.find(arg1,"resetcd ") then
		local sid,name = arg2:match("%a+ (%d+) (.+)")
		if sid and name then
			print("Reset CD "..sid.." by "..name)
			sid = tonumber(sid)
			local j = module.db.cdsNav[name][sid]
			if j then
				j:SetCD(0)
			end
		end
	elseif arg1 == "cd" then
		if not VMRT.ExCD2.enabled then
			module:Enable()
		else
			module:Disable()
		end
		if module.options.chkEnable then
			module.options.chkEnable:SetChecked(VMRT.ExCD2.enabled)
		end
	elseif arg1 == "cddebug" then
		VMRT.ExCD2.CDDebug = not VMRT.ExCD2.CDDebug
		print("|cff33ff99[MRT/CD]|r cddebug = "..tostring(VMRT.ExCD2.CDDebug))
		if module.RebuildPlayerTalentSet then
			module:RebuildPlayerTalentSet()
		end
		if module.DumpTalentDebug then
			module:DumpTalentDebug()
		end
	end
end


if ExRT.isLK then


	module.db.AllSpells = {

		{29166,	"DRUID",	1,	{29166,	180,	20}},
		{20748,	"DRUID",	3,	{20748,	600,	0}},
		{6795,	"DRUID",	1,	{6795,	8,	0}},
		{740,	"DRUID",	3,	{740,	480,	8}},
		{5209,	"DRUID",	1,	{5209,	180,	6}},
		{17116,	"DRUID",	1,	nil, nil, nil, {17116,	180,	0}},
		{22812,	"DRUID",	1,	{22812,	60,	12}},
		{5229,	"DRUID",	1,	{5229,	60,	10}},
		{50334,	"DRUID",	3, nil,	nil, {50334,	180,	15}},
		{61336,	"DRUID",	3, nil,	nil, {61336,	180,	12}},
		{53201,	"DRUID",	3,	nil,	{53201,	90,	10},	nil,	nil,	nil},
		{33831,	"DRUID",	1, nil,	{33831,	180,	30}},
		{22842,	"DRUID",	1,	{22842,	180,	10}},
		{18562,	"DRUID",	1,	nil, nil, nil, {18562,	15,	0}},
		{1850,	"DRUID",	1,	{1850,	180,	15}},
		{16689,	"DRUID",	1,	nil,	nil,	nil,	nil,	{16689,	60,	45}},
		{16979,	"DRUID",	1,	nil,	nil,	{16979,	15,	0},	nil},
		{49376,	"DRUID",	1,	nil,	nil,	{49376,	30,	0},	nil},
		{22570,	"DRUID",	1,	{22570,	10,	5}},
		{5217,	"DRUID",	1,	{5217,	30,	6}},
		{50516,	"DRUID",	1, nil,	{50516,	20,	6}},
		{5211,	"DRUID",	1,	{5211,	60,	5}},


		{355,	"WARRIOR",	1,	{355,	8,	0}},
		{12975,	"WARRIOR",	1, nil,	nil, nil, {12975,	180,	20}},
		{871,	"WARRIOR",	3,	{871,	300,	12}},
		{1161,	"WARRIOR",	1,	{1161,	180,	6}},
		{12809,	"WARRIOR",	1, nil,	nil, nil, {12809,	30,	5}},
		{676,	"WARRIOR",	1,	{676,	60,	10}},
		{55694,	"WARRIOR",	1,	{55694,	180,	10}},
		{1719,	"WARRIOR",	3,	{1719,	300,	12}},
		{46924,	"WARRIOR",	3, nil,	{46924,	90,	6}},
		{20252,	"WARRIOR",	1,	{20252,	30,	0}},
		{3411,	"WARRIOR",	1,	{3411,	30,	0}},
		{23920,	"WARRIOR",	1,	{23920,	10,	5}},
		{2565,	"WARRIOR",	1,	{2565,	60,	10}},
		{5246,	"WARRIOR",	1,	{5246,	120,	8}},
		{18499,	"WARRIOR",	1,	{18499,	30,	10}},
		{6552,	"WARRIOR",	1,	{6552,	10,	0}},
		{72,	"WARRIOR",	1,	{72,	12,	0}},
		{64382,	"WARRIOR",	1,	{64382,	300,	0}},
		{12292,	"WARRIOR",	3, nil,	nil, {12292,	180,	30}},
		{12328,	"WARRIOR",	1, nil,	{12328,	30,	10}},
		{2687,	"WARRIOR",	1,	{2687,	60,	10}},
		{20230,	"WARRIOR",	3,	{20230,	300,	12}},
		{60970,	"WARRIOR",	1, nil,	nil, {60970,	45,	0}},
		{46968,	"WARRIOR",	3, nil,	nil, nil, {46968,	20,	4}},


		{11958,	"MAGE",	1, nil,	nil, nil, {11958,	480,	0}},
		{12472,	"MAGE",	3, nil,	nil, nil, {12472,	180,	20}},
		{45438,	"MAGE",	3,	{45438,	300,	10}},
		{55342,	"MAGE",	1,	{55342,	180,	30}},
		{12051,	"MAGE",	1,	{12051,	240,	8}},
		{2139,	"MAGE",	1,	{2139,	24,	8}},
		{1953,	"MAGE",	1,	{1953,	15,	0}},
		{66,	"MAGE",	1,	{66,	180,	18}},
		{31687,	"MAGE",	1, nil,	nil, nil, {31687,	180,	45}},
		{12042,	"MAGE",	3, nil,	{12042,	120,	15}},
		{12043,	"MAGE",	1, nil,	{12043,	120,	10}},
		{122,	"MAGE",	1,	{122,	25,	8}},
		{11129,	"MAGE",	3, nil,	nil, {11129,	120,	0}},
		{31661,	"MAGE",	1, nil,	nil, {31661,	20,	5}},
		{11426,	"MAGE",	1, nil,	nil, nil, {11426,	30,	60}},
		{44572,	"MAGE",	1, nil,	nil, nil, {44572,	30,	5}},


		{642,	"PALADIN",	3,	{642,	300,	12}},
		{10310,	"PALADIN",	3,	{10310,	1200,	0}},
		{19752,	"PALADIN",	3,	{19752,	600,	180}},
		{31884,	"PALADIN",	3,	{31884,	180,	20}},
		{10278,	"PALADIN",	1,	{10278,	300,	10}},
		{1044,	"PALADIN",	1,	{1044,	25,	6}},
		{1038,	"PALADIN",	1,	{1038,	120,	10}},
		{6940,	"PALADIN",	1,	{6940,	120,	12}},
		{62124,	"PALADIN",	1,	{62124,	8,	0}},
		{64205,	"PALADIN",	3, nil,	nil, {64205,	120,	10}},
		{31821,	"PALADIN",	1, nil,	{31821,	120,	6}},
		{20066,	"PALADIN",	1, nil,	nil, nil, {20066,	60,	60}},
		{10308,	"PALADIN",	1,	{10308,	60,	6}},
		{498,	"PALADIN",	1,	{498,	180,	12}},
		{31842,	"PALADIN",	1, nil,	{31842,	180,	15}},
		{54428,	"PALADIN",	1,	{54428,	60,	15}},
		{20216,	"PALADIN",	1, nil,	{20216,	120,	10}},
		{66233,	"PALADIN",	3,	nil,	nil,	{66233,	120,	10},	nil},
		{31789,	"PALADIN",	1,	{31789,	8,	0}},
		{31935,	"PALADIN",	1, nil,	nil, {31935,	30,	0}},
		{2812,	"PALADIN",	1,	{2812,	30,	0}},
		{24275,	"PALADIN",	1,	{24275,	6,	0}},


		{16190,	"SHAMAN",	3, nil,	nil, nil, {16190,	300,	12}},
		{32182,	"SHAMAN",	3,	{32182,	300,	40},	specialCheck=function() if UnitFactionGroup('player')=="Alliance" then return true end end},
		{2825,	"SHAMAN",	3,	{2825,	300,	40},	specialCheck=function() if UnitFactionGroup('player')=="Horde" then return true end end},
		{20608,	"SHAMAN",	1,	{21169,	1800,	0}},
		{2894,	"SHAMAN",	1,	{2894,	600,	120}},
		{2062,	"SHAMAN",	1,	{2062,	600,	120}},
		{8177,	"SHAMAN",	1,	{8177,	15,	15}},
		{51490,	"SHAMAN",	1, nil,	{51490,	45,	0}},
		{16166,	"SHAMAN",	3, nil,	{16166,	180,	15}},
		{30823,	"SHAMAN",	1, nil,	nil, {30823,	60,	15}},
		{55198,	"SHAMAN",	1, nil,	nil, nil, {55198,	180,	20}},
		{51514,	"SHAMAN",	1,	{51514,	45,	30}},
		{16188,	"SHAMAN",	1, nil,	nil, nil, {16188,	120,	0}},
		{57994,	"SHAMAN",	1,	{57994,	6,	0}},
		{8983,	"SHAMAN",	1,	{8983,	30,	15}},
		{51533,	"SHAMAN",	1, nil,	nil, {51533,	180,	30}},


		{20765,	"WARLOCK",	3,	{20765,	900,	0}},
		{17928,	"WARLOCK",	1,	{17928,	40,	8}},
		{30283,	"WARLOCK",	1, nil,	nil, nil, {30283,	20,	2}},
		{6229,	"WARLOCK",	1,	{6229,	30,	30}},
		{29858,	"WARLOCK",	1,	{29858,	180,	0}},
		{18708,	"WARLOCK",	1, nil,	nil, {18708,	180,	15}},
		{47241,	"WARLOCK",	3,	nil,	nil,	{47241,	180,	30},	nil},
		{47193,	"WARLOCK",	1, nil,	nil, {47193,	60,	0}},
		{18540,	"WARLOCK",	3,	{18540,	600,	45}},
		{19647,	"WARLOCK",	1,	{19647,	24,	0},	nil,	nil,	nil},
		{6789,	"WARLOCK",	1,	{6789,	120,	3}},
		{1122,	"WARLOCK",	3,	{1122,	600,	60}},
		{17877,	"WARLOCK",	1, nil,	nil, nil, {17877,	15,	0}},
		{6358,	"WARLOCK",	1,	{6358,	0,	15},	nil,	nil,	nil},


		{19801,	"HUNTER",	1,	{19801,	8,	0}},
		{34477,	"HUNTER",	1,	{34477,	30,	0}},
		{19577,	"HUNTER",	1, nil,	{19577,	60,	3}},
		{5384,	"HUNTER",	1,	{5384,	30,	0}},
		{19263,	"HUNTER",	3,	{19263,	90,	5}},
		{781,	"HUNTER",	1,	{781,	25,	0}},
		{3045,	"HUNTER",	3,	{3045,	300,	15}},
		{34026,	"HUNTER",	1,	{34026,	60,	0}},
		{60192,	"HUNTER",	1,	{60192,	30,	10}},
		{19574,	"HUNTER",	3, nil,	{19574,	120,	18}},
		{13809,	"HUNTER",	1,	{13809,	30,	0}},
		{34600,	"HUNTER",	1,	{34600,	30,	0}},
		{1499,	"HUNTER",	1,	{1499,	30,	0}},
		{53271,	"HUNTER",	1,	{53271,	60,	4}},
		{23989,	"HUNTER",	3, nil,	nil, {23989,	180,	0}},
		{13813,	"HUNTER",	1,	{13813,	30,	0}},
		{13795,	"HUNTER",	1,	{13795,	30,	0}},
		{1543,	"HUNTER",	1,	{1543,	20,	0}},
		{34490,	"HUNTER",	1, nil,	nil, {34490,	20,	3}},
		{19386,	"HUNTER",	1, nil,	nil, nil, {19386,	60,	30}},
		{53351,	"HUNTER",	1,	{53351,	15,	0}},
		{14327,	"HUNTER",	1,	{14327,	30,	20}},


		{64843,	"PRIEST",	3,	{64843,	480,	8}},
		{724,	"PRIEST",	1, nil,	nil,	{724,	180,	0},	nil,	nil},
		{6346,	"PRIEST",	1,	{6346,	180,	0}},
		{10060,	"PRIEST",	3, nil,	{10060,	120,	15}},
		{64901,	"PRIEST",	1,	{64901,	360,	0}},
		{47788,	"PRIEST",	3, nil,	nil, {47788,	180,	10}},
		{33206,	"PRIEST",	3, nil,	{33206,	180,	8}},
		{10890,	"PRIEST",	1,	{10890,	30,	8}},
		{586,	"PRIEST",	1,	{586,	30,	10}},
		{47585,	"PRIEST",	3, nil,	nil, nil, {47585,	120,	6}},
		{64044,	"PRIEST",	1, nil,	nil, nil, {64044,	120,	3}},
		{15487,	"PRIEST",	1, nil,	nil, nil, {15487,	45,	5}},
		{14751,	"PRIEST",	1, nil,	{14751,	180,	0}},
		{34433,	"PRIEST",	1,	{34433,	300,	15}},
		{47540,	"PRIEST",	1, nil,	{47540,	12,	2}},
		{33076,	"PRIEST",	1,	{33076,	10,	30}},
		{34861,	"PRIEST",	1, nil,	nil, {34861,	6,	0}},
		{32379,	"PRIEST",	1,	{32379,	12,	0}},
		{605,	"PRIEST",	1,	{605,	0,	60}},


		{5277,	"ROGUE",	1,	{5277,	180,	15}},
		{57934,	"ROGUE",	1,	{57934,	30,	6}},
		{1966,	"ROGUE",	1,	{1966,	10,	5}},
		{2983,	"ROGUE",	1,	{2983,	180,	8}},
		{13750,	"ROGUE",	3, nil,	nil, {13750,	180,	15}},		-- Adrenaline Rush (Combat)
		{31224,	"ROGUE",	3,	{31224,	90,	5}},				-- Cloak of Shadows (all specs)
		{26889,	"ROGUE",	1,	{26889,	180,	10}},
		{51690,	"ROGUE",	3, nil,	nil, {51690,	120,	3}},		-- Killing Spree (Combat)
		{14185,	"ROGUE",	3, nil,	nil, nil, {14185,	480,	0}},		-- Preparation (Subtlety)
		{51722,	"ROGUE",	1,	{51722,	60,	10}},
		{408,	"ROGUE",	1,	{408,	20,	6}},
		{2094,	"ROGUE",	1,	{2094,	180,	10}},
		{1776,	"ROGUE",	1,	{1776,	10,	4}},
		{1725,	"ROGUE",	1,	{1725,	30,	10}},
		{31230,	"ROGUE",	3,	nil,	nil,	nil,	{31230,	60,	3}},		-- Cheat Death (Subtlety)
		{13877,	"ROGUE",	3, nil,	nil, {13877,	120,	15}},		-- Blade Flurry (Combat)
		{36554,	"ROGUE",	1, nil,	nil, nil, {36554,	30,	10}},
		{14177,	"ROGUE",	3, nil,	{14177,	180,	0}},		-- Cold Blood (Assassination)


		{49576,	"DEATHKNIGHT",	1,	{49576,	35,	0}},
		{48707,	"DEATHKNIGHT",	1,	{48707,	45,	5}},
		{42650,	"DEATHKNIGHT",	3,	{42650,	600,	0}},
		{61999,	"DEATHKNIGHT",	3,	{61999,	600,	0}},
		{56222,	"DEATHKNIGHT",	1,	{56222,	8,	0}},
		{51052,	"DEATHKNIGHT",	3, nil,	nil, nil, {51052,	120,	10}},
		{49028,	"DEATHKNIGHT",	3, nil,	{49028,	90,	12}},
		{49016,	"DEATHKNIGHT",	1, nil,	{49016,	180,	30}},
		{48792,	"DEATHKNIGHT",	3,	{48792,	120,	12}},
		{55233,	"DEATHKNIGHT",	3, nil,	{55233,	60,	10}},
		{49222,	"DEATHKNIGHT",	1, nil,	nil, nil, {49222,	60,	300}},
		{49206,	"DEATHKNIGHT",	3, nil,	nil, nil, {49206,	180,	30}},
		{47568,	"DEATHKNIGHT",	3,	{47568,	300,	0}},
		{49203,	"DEATHKNIGHT",	1, nil,	nil, {49203,	60,	10}},
		{47476,	"DEATHKNIGHT",	1,	{47476,	120,	5}},
		{47528,	"DEATHKNIGHT",	1,	{47528,	10,	0}},
		{49039,	"DEATHKNIGHT",	1, nil,	nil, {49039,	120,	10}},
		{51271,	"DEATHKNIGHT",	3, nil,	nil, {51271,	60,	20}},
		{48982,	"DEATHKNIGHT",	1, nil,	{48982,	30,	0}},
		{45529,	"DEATHKNIGHT",	1,	{45529,	60,	0}},
		{46584,	"DEATHKNIGHT",	1,	{46584,	180,	60}},
		{49005,	"DEATHKNIGHT",	1, nil,	{49005,	180,	20}},
	
	}
	for _,_tid in ipairs({17116, 50334, 61336, 33831, 18562, 50516, 12975, 12809, 46924, 12292, 12328, 60970, 46968, 11958, 12472, 31687, 12042, 12043, 11129, 31661, 11426, 44572, 64205, 31821, 20066, 31842, 20216, 31935, 16190, 51490, 16166, 30823, 55198, 16188, 51533, 30283, 18708, 47193, 17877, 19577, 19574, 23989, 34490, 19386, 724, 10060, 47788, 33206, 47585, 64044, 15487, 14751, 47540, 34861, 13750, 51690, 14185, 13877, 36554, 14177, 51052, 49028, 49016, 55233, 49222, 49206, 49203, 49039, 51271, 48982, 49005}) do
		module.db.spell_isTalent[_tid] = true
		local _tn = GetSpellInfo(_tid)
		if _tn then module.db.spell_isTalent[_tn] = true end
	end
	module.db.spell_isTalent[GetSpellInfo(16190) or "spell:16190"] = true	module.db.spell_isTalent[16190] = true
	module.db.spell_isTalent[GetSpellInfo(10060) or "spell:10060"] = true	module.db.spell_isTalent[10060] = true
	module.db.spell_isTalent[GetSpellInfo(11958) or "spell:11958"] = true	module.db.spell_isTalent[11958] = true
	module.db.spell_isTalent[GetSpellInfo(51052) or "spell:51052"] = true	module.db.spell_isTalent[51052] = true
	module.db.spell_isTalent[GetSpellInfo(47788) or "spell:47788"] = true	module.db.spell_isTalent[47788] = true
	module.db.spell_isTalent[GetSpellInfo(33206) or "spell:33206"] = true	module.db.spell_isTalent[33206] = true
	module.db.spell_isTalent[GetSpellInfo(724) or "spell:724"] = true	module.db.spell_isTalent[724] = true
	module.db.spell_isTalent[GetSpellInfo(64205) or "spell:64205"] = true	module.db.spell_isTalent[64205] = true
	module.db.spell_isTalent[GetSpellInfo(49028) or "spell:49028"] = true	module.db.spell_isTalent[49028] = true
	module.db.spell_isTalent[GetSpellInfo(49016) or "spell:49016"] = true	module.db.spell_isTalent[49016] = true
	module.db.spell_isTalent[GetSpellInfo(31821) or "spell:31821"] = true	module.db.spell_isTalent[31821] = true
	module.db.spell_isTalent[GetSpellInfo(66233) or "spell:66233"] = true	module.db.spell_isTalent[66233] = true

	module.db.spell_autoTalent[64205] = 66
	module.db.spell_autoTalent[31821] = 65
	module.db.spell_autoTalent[16190] = 264
	module.db.spell_autoTalent[51052] = 252
	module.db.spell_autoTalent[33206] = 256
	module.db.spell_autoTalent[10060] = 256
	module.db.spell_autoTalent[47788] = 257
	module.db.spell_autoTalent[11958] = 64
	module.db.spell_autoTalent[49028] = 250
	module.db.spell_autoTalent[49016] = 250
	module.db.spell_autoTalent[724]   = 257
	module.db.spell_autoTalent[66233] = 66

	for _,sid in ipairs({
		740,
		31821,
		64205,
		16190,
		32182,
		2825,
		20608,
		20765,
		34477,
		64843,
		10060,
		47788,
		33206,
		57934,
		61999,
		51052,
		49028,
		49016,

		29166,
		22812,
		22842,
		61336,
		50334,
		17116,
		53201,
		33831,
		1850,
		5209,

		12292,
		871,
		12975,
		55694,
		1719,
		64382,

		11958,
		12472,
		45438,
		55342,
		12042,

		642,
		498,
		10278,
		1044,
		1038,
		6940,
		19752,
		31884,
		66233,

		16166,
		30823,

		47241,
		18540,
		47193,

		19263,
		3045,
		19574,
		23989,

		724,
		6346,
		47585,
		64901,

		1856,
		14177,
		14185,
		31224,
		31230,

		48707,
		48792,
		49222,
		49005,
		42650,
	}) do
		module.db.spell_isRaidCD[sid] = true
	end

	do
		local passiveTalentProcs = {
			[45182] = 31230,
			[45181] = 31230,
			[45180] = 31230,
			[66235] = 66233,
			[66233] = 66233,
		}
		for procSpellID, trackedSpellID in pairs(passiveTalentProcs) do
			module.db.spell_startCDbyAuraApplied[procSpellID] = trackedSpellID
		end
		for _, spellID in pairs(module.db.spell_startCDbyAuraApplied) do
			module.db.spell_startCDbyAuraApplied_fix[spellID] = true
		end
	end

	do
		local rankToTracked = {
			[31228] = {31230, 31229},
			[31229] = {31230},
			[31850] = {66233, 31851, 31852},
			[31851] = {66233, 31852},
			[31852] = {66233},
		}
		for rankSpellID, others in pairs(rankToTracked) do
			local existing = module.db.spell_talentProvideAnotherTalents[rankSpellID]
			if existing then
				for _, v in ipairs(others) do
					if not ExRT.F.table_find(existing, v) then
						existing[#existing+1] = v
					end
				end
			else
				module.db.spell_talentProvideAnotherTalents[rankSpellID] = others
			end
		end
	end

	module.db.spell_resetOtherSpells[11958] = {45438}

	for _,sid in ipairs({
		45438,
		47788,
		9863,
		29166,
		48792,
		48982,
		12975,
		12472,
		55342,
		31884,
		31821,
		64205,
		33206,
		10060,
		49016,
		5277,
		48707,
		51052,
		49028,
		16190,
		64843,
		1044,
		6940,
		1038,
		49005,
		22812,
		22842,
		50334,
		61336,
		53201,
		55233,
		49222,
		12042,
		11426,
		66,
		3045,
		19574,
		642,
		498,
		54428,
		31842,
		47585,
		14751,
		31224,
		13750,
		30823,
		871,
		55694,
		1719,
		12292,
		2565,
		18499,
		1850,
		16689,
		33831,
		47241,
		5384,
	}) do
		local n = GetSpellInfo(sid) or "spell:"..sid
		module.db.spell_aura_list[n] = sid
		module.db.spell_aura_list[sid] = sid
	end

	module.db.spell_startCDbySummon[GetSpellInfo(46584) or "spell:46584"] = 46584	module.db.spell_startCDbySummon[46584] = 46584

	module.db.spell_cancelDurOnCast[GetSpellInfo(48743) or "spell:48743"] = 46584	module.db.spell_cancelDurOnCast[48743] = 46584

	module.db.spell_afterCombatNotReset[GetSpellInfo(20608) or "spell:20608"] = true	module.db.spell_afterCombatNotReset[20608] = true

	module.db.spell_cdByTalent_fix[31884] = {53375,{-30,-60}}
	module.db.spell_cdByTalent_fix[871] = {12312,{-30,-60}}
	module.db.spell_cdByTalent_fix[10278] = {20174,{-60,-120}}
	module.db.spell_cdByTalent_fix[10310] = {20234,{-120,-240}}
	module.db.spell_cdByTalent_fix[11958] = {55091,{"*0.9","*0.8"}}
	module.db.spell_cdByTalent_fix[33206] = {47507,{"*0.9","*0.8"}}
	module.db.spell_cdByTalent_fix[10060] = {47507,{"*0.9","*0.8"}}
	module.db.spell_cdByTalent_fix[20608] = {16209,{"*0.75","*0.5"}}
	module.db.spell_cdByTalent_fix[9863] = {17123,{"*0.7","*0.4"}}
	module.db.spell_cdByTalent_fix[42650] = {55620,{-60,-120}}
	module.db.spell_cdByTalent_fix[49576] = {49588,{-5,-10}}
	module.db.spell_cdByTalent_fix[20230] = {12312,{-30,-60}}
	module.db.spell_cdByTalent_fix[1719] = {12312,{-30,-60}}
	module.db.spell_cdByTalent_fix[47540] = {47507,{"*0.9","*0.8"}}
	module.db.spell_cdByTalent_fix[10890] = {15392,{-2,-4}}

	module.db.spell_durationByTalent_fix[1044] = {20174,{2,4}}

	module.db.spellIgnoreAfterFirstUse[9863] = 10
	module.db.spellIgnoreAfterFirstUse[64843] = 10
	module.db.spellIgnoreAfterFirstUse[64901] = 10
	module.db.spellIgnoreAfterFirstUse[42650] = 10

	module.db.spell_startCDbyAuraFade[GetSpellInfo(14177) or "spell:14177"] = 14177		module.db.spell_startCDbyAuraFade[14177] = 14177
	module.db.spell_startCDbyAuraFade[GetSpellInfo(17116) or "spell:17116"] = 17116		module.db.spell_startCDbyAuraFade[17116] = 17116
	module.db.spell_startCDbyAuraFade[GetSpellInfo(16188) or "spell:16188"] = 16188		module.db.spell_startCDbyAuraFade[16188] = 16188
	module.db.spell_startCDbyAuraFade[GetSpellInfo(16166) or "spell:16166"] = 16166		module.db.spell_startCDbyAuraFade[16166] = 16166
	module.db.spell_startCDbyAuraFade[GetSpellInfo(11129) or "spell:11129"] = 11129		module.db.spell_startCDbyAuraFade[11129] = 11129
	module.db.spell_startCDbyAuraFade[GetSpellInfo(12043) or "spell:12043"] = 12043		module.db.spell_startCDbyAuraFade[12043] = 12043
	module.db.spell_startCDbyAuraFade[GetSpellInfo(14751) or "spell:14751"] = 14751		module.db.spell_startCDbyAuraFade[14751] = 14751
	module.db.spell_startCDbyAuraFade[GetSpellInfo(28682) or "spell:28682"] = 11129		module.db.spell_startCDbyAuraFade[28682] = 11129
	module.db.spell_aura_list[GetSpellInfo(28682) or "spell:28682"] = 11129		module.db.spell_aura_list[28682] = 11129
	module.db.spell_aura_list[GetSpellInfo(55166) or "spell:55166"] = 55198		module.db.spell_aura_list[55166] = 55198

	module.db.spell_threatBuff = module.db.spell_threatBuff or {}
	module.db.spell_threatBuff[GetSpellInfo(57934) or "spell:57934"] = 57934		module.db.spell_threatBuff[57934] = 57934
	module.db.spell_threatBuff[GetSpellInfo(34477) or "spell:34477"] = 34477		module.db.spell_threatBuff[34477] = 34477
	module.db.spell_threatBuff[35079] = 34477

	module.db.spell_threatBuff_consumed = module.db.spell_threatBuff_consumed or {}
	module.db.spell_threatBuff_consumed[GetSpellInfo(59628) or "spell:59628"] = 57934		module.db.spell_threatBuff_consumed[59628] = 57934

	module.db.spell_threatBuff_consumed_lookup = module.db.spell_threatBuff_consumed_lookup or {}
	module.db.spell_threatBuff_consumed_lookup[57934] = 59628

	module.db.spell_resetOtherSpells[11958] = {45438, 12472, 43039, 44572, 31687}
	module.db.spell_resetOtherSpells[23989] = {19577, 5384, 19263, 781, 3045, 34026, 60192, 19574, 13809, 34600, 1499, 53271, 13813, 13795, 1543, 34490, 19386, 53351, 14327}

	module.db.spell_sharingCD[GetSpellInfo(31884) or "spell:31884"] = {[GetSpellInfo(642) or "spell:642"]=30}
	module.db.spell_sharingCD[GetSpellInfo(13809) or "spell:13809"] = {[GetSpellInfo(60192) or "spell:60192"]=30, [GetSpellInfo(14311) or "spell:14311"]=30}
	module.db.spell_sharingCD[GetSpellInfo(60192) or "spell:60192"] = {[GetSpellInfo(13809) or "spell:13809"]=30, [GetSpellInfo(14311) or "spell:14311"]=30}
	module.db.spell_sharingCD[GetSpellInfo(14311) or "spell:14311"] = {[GetSpellInfo(13809) or "spell:13809"]=30, [GetSpellInfo(60192) or "spell:60192"]=30}
	module.db.spell_sharingCD[GetSpellInfo(49056) or "spell:49056"] = {[GetSpellInfo(49067) or "spell:49067"]=30}
	module.db.spell_sharingCD[GetSpellInfo(49067) or "spell:49067"] = {[GetSpellInfo(49056) or "spell:49056"]=30}

	module.db.spell_target_byCast = module.db.spell_target_byCast or {}
	do
		if ExRT.F.WarmUpSpell then ExRT.F.WarmUpSpell(48477) end
		local rebirthName = GetSpellInfo(48477) or GetSpellInfo(20484) or GetSpellInfo(20748)
		if rebirthName then
			module.db.spell_target_byCast[rebirthName] = 20748
		end
	end

elseif ExRT.isBC then
	module.db.AllSpells = {
		{29166,	"DRUID",	1,	{29166,	360,	20}},
		{20748,	"DRUID",	1,	{20748,	1200,	0}},
		{6795,	"DRUID",	1,	{6795,	10,	0}},
		{9863,	"DRUID",	1,	{9863,	600,	8}},
		{5209,	"DRUID",	1,	{5209,	600,	6}},

		{355,	"WARRIOR",	1,	{355,	10,	0}},
		{12975,	"WARRIOR",	1,	{12975,	480,	20}},
		{871,	"WARRIOR",	1,	{871,	1800,	10}},
		{1161,	"WARRIOR",	1,	{1161,	600,	6}},
		{12809,	"WARRIOR",	1,	{12809,	45,	5}},
		{676,	"WARRIOR",	1,	{676,	60,	10}},

		{11958,	"MAGE",		1,	{11958,	480,	0}},
		{12472,	"MAGE",		1,	{12472,	180,	20}},
		{45438,	"MAGE",		1,	{45438,	300,	10}},

		{1020,	"PALADIN",	1,	{1020,	300,	12}},
		{10310,	"PALADIN",	1,	{10310,	3600,	0}},
		{19752,	"PALADIN",	1,	{19752,	3600,	180}},
		{31884,	"PALADIN",	1,	{31884,	180,	20}},

		{16190,	"SHAMAN",	1,	{16190,	300,	12}},
		{32182,	"SHAMAN",	1,	{32182,	600,	40},	specialCheck=function() if UnitFactionGroup('player')=="Alliance" then return true end end},
		{2825,	"SHAMAN",	1,	{2825,	600,	40},	specialCheck=function() if UnitFactionGroup('player')=="Horde" then return true end end},
		{20608,	"SHAMAN",	1,	{21169,	3600,	0}},
		{2894, 	"SHAMAN",	1,	{2894,	1200,	120}},
		{2062, 	"SHAMAN",	1,	{2062, 	1200,	120}},

		{20765,	"WARLOCK",	1,	{20765,	1800,	0}},

		{19801, "HUNTER",	1,	{19801,	20,	0}},
		{34477, "HUNTER",	1,	{34477,	30,	0}},
		{19577, "HUNTER",	1,	{19577,	60,	3}},
		{5384, 	"HUNTER",	1,	{5384,	30,	0}},

		{28275, "PRIEST",	1,	{28275,	360,	180}},
		{6346, 	"PRIEST",	1,	{6346,	180,	0}},
		{32548, "PRIEST",	1,	{32548,	300,	15},	specialCheck=function(_,_,_,r) if r=="Draenei" then return true end end},
		{10060, "PRIEST",	1,	{10060,	180,	15}},

		{5277, 	"ROGUE",	1,	{5277,	300,	15}},
	}
	module.db.spell_isTalent[GetSpellInfo(16190) or "spell:16190"] = true	module.db.spell_isTalent[16190] = true
	module.db.spell_isTalent[GetSpellInfo(10060) or "spell:10060"] = true	module.db.spell_isTalent[10060] = true
	module.db.spell_isTalent[GetSpellInfo(11958) or "spell:11958"] = true	module.db.spell_isTalent[11958] = true

	module.db.spell_resetOtherSpells[GetSpellInfo(11958) or "spell:11958"] = {GetSpellInfo(45438)}
	module.db.spell_aura_list[GetSpellInfo(45438) or "spell:45438"] = GetSpellInfo(45438)

elseif ExRT.isClassic then
	module.db.AllSpells = {
		{29166,	"DRUID",	1,	{29166,	360,	20}},
		{20748,	"DRUID",	1,	{20748,	1800,	0}},
		{6795,	"DRUID",	1,	{6795,	10,	0}},
		{9863,	"DRUID",	1,	{9863,	300,	10}},
		{5209,	"DRUID",	1,	{5209,	600,	6}},

		{355,	"WARRIOR",	1,	{355,	10,	0}},
		{12975,	"WARRIOR",	1,	{12975,	600,	20}},
		{871,	"WARRIOR",	1,	{871,	1800,	10}},
		{1161,	"WARRIOR",	1,	{1161,	600,	6}},

		{11958,	"MAGE",		1,	{11958,	480,	40}},

		{1020,	"PALADIN",	1,	{1020,	300,	12}},
		{10310,	"PALADIN",	1,	{10310,	3600,	0}},
		{19752,	"PALADIN",	1,	{19752,	3600,	0}},

		{17359,	"SHAMAN",	1,	{17359,	300,	12}},

		{20765,	"WARLOCK",	1,	{20765,	1800,	0}},
	}
end


ExRT.A = ExRT.A or {}
ExRT.A.ExCD2 = module
