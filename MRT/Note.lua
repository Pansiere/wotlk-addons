local GlobalAddonName, MRT = ...

local VMRT = nil

local module = MRT:New("Note",MRT.L.message)
local ELib,L = MRT.lib,MRT.L

local GetTime = GetTime
local string_gsub, strsplit, tonumber, format, string_match, floor, string_find, type, string_gmatch = string.gsub, strsplit, tonumber, format, string.match, floor, string.find, type, string.gmatch
local GetSpellInfo = MRT.F.GetSpellInfo or GetSpellInfo
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
local GetSpellName = C_Spell and C_Spell.GetSpellName or GetSpellInfo
local GetSpecializationInfo = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo
local GetSpecialization = GetSpecialization or C_SpecializationInfo and C_SpecializationInfo.GetSpecialization
local NewVMRTTableData
local SendChatMessage = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage

local BUILD_NUM = select(4, GetBuildInfo())
local IS_WOTLK_335 = (tonumber(select(4, GetBuildInfo()) or 0) == 30300)

local function MRT_SetSolidColor(tex, r, g, b, a)
	if not tex then return end
	if tex.SetColorTexture then
		tex:SetColorTexture(r, g, b, a)
	else
		tex:SetTexture("Interface\\Buttons\\WHITE8x8")
		tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
	end
end

GetSpecialization = MRT.NULLfunc

module.db.otherIconsList = {
	{"{"..L.classLocalizate["WARRIOR"] .."}","Interface\\Icons\\INV_Sword_27"},
	{"{"..L.classLocalizate["PALADIN"] .."}","Interface\\Icons\\Ability_ThunderBolt"},
	{"{"..L.classLocalizate["HUNTER"] .."}","Interface\\Icons\\inv_weapon_bow_07"},
	{"{"..L.classLocalizate["ROGUE"] .."}","Interface\\Icons\\inv_throwingknife_04"},
	{"{"..L.classLocalizate["PRIEST"] .."}","Interface\\Icons\\inv_staff_30"},
	{"{"..L.classLocalizate["DEATHKNIGHT"] .."}","Interface\\Icons\\Spell_Deathknight_ClassIcon"},
	{"{"..L.classLocalizate["SHAMAN"] .."}","Interface\\Icons\\Spell_Nature_BloodLust"},
	{"{"..L.classLocalizate["MAGE"] .."}","Interface\\Icons\\inv_staff_13"},
	{"{"..L.classLocalizate["WARLOCK"] .."}","Interface\\Icons\\Spell_Nature_Drowsy"},
	{"{"..L.classLocalizate["DRUID"] .."}","Interface\\Icons\\inv_misc_monsterclaw_04"},
	{"{tank}","Interface\\Icons\\Ability_Defend"},
	{"{healer}","Interface\\Icons\\Spell_Holy_Heal"},
	{"{dps}","Interface\\Icons\\Ability_DualWield"},
}


module.db.iconsLocalizatedNames = {
	L.raidtargeticon1,L.raidtargeticon2,L.raidtargeticon3,L.raidtargeticon4,L.raidtargeticon5,L.raidtargeticon6,L.raidtargeticon7,L.raidtargeticon8,
}
local iconsLangs = {"eng","de","it","fr","ru","es","pt"}
for _,lang in pairs(iconsLangs) do
	local new = {}
	module.db["icons"..lang.."Names"] = new
	for i=1,8 do
		new[i] = L["raidtargeticon"..i.."_"..lang]
	end
end

local frameStrataList = {"BACKGROUND","LOW","MEDIUM","HIGH","DIALOG","FULLSCREEN","FULLSCREEN_DIALOG","TOOLTIP"}

module.db.msgindex = -1
module.db.lasttext = ""

module.db.encounter_time_p = {}
module.db.encounter_time_c = {}
module.db.encounter_time_wa_uids = {}
module.db.encounter_id = {}

local encounter_time_p = module.db.encounter_time_p
local encounter_time_c = module.db.encounter_time_c
local encounter_time_wa_uids = module.db.encounter_time_wa_uids
local encounter_id = module.db.encounter_id

local predefSpellIcons = {}

local function GSUB_Icon(spellID,iconSize)
	spellID = tonumber(spellID)

	if not iconSize or iconSize == "" then
		iconSize = 16
	else
		iconSize = min(tonumber(iconSize),40)
	end

	local preicon = predefSpellIcons[spellID]
	if preicon then
		return "|T"..preicon..":"..iconSize.."|t"
	end

	local spellTexture = GetSpellTexture(spellID)
	if not spellTexture and MRT and MRT.F and MRT.F.GetSpellTextureSafe then
		spellTexture = MRT.F.GetSpellTextureSafe(spellID)
	end
	return "|T"..(spellTexture or "Interface\\Icons\\INV_MISC_QUESTIONMARK")..":"..iconSize.."|t"
end

local function GSUB_Player(anti,list,msg)
	list = {strsplit(",",list)}
	local found = false
	local myName = (MRT.SDB.charName):lower()
	for i=1,#list do
		list[i] = list[i]:gsub("|?|c........",""):gsub("|?|r",""):lower()
		if strsplit("-",list[i]) == myName then
			found = true
			break
		end
	end

	if (found and anti == "") or (not found and anti == "!") then
		return msg
	else
		return ""
	end
end

local function GSUB_Encounter(list,msg)
	list = {strsplit(",",list)}
	local found = false
	for i=1,#list do
		list[i] = list[i]:gsub("|?|c........",""):gsub("|?|r",""):lower()
		if encounter_id[ list[i] ] then
			found = true
			break
		end
	end

	if found then
		return msg
	else
		return ""
	end
end

local function GSUB_Zone(mlist,msg)
	local list = {strsplit(",",mlist)}

	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID = GetInstanceInfo()
	name = (name or "-"):lower()
	instanceID = tostring(instanceID or "-")

	local found = false
	for i=1,#list do
		list[i] = list[i]:gsub("|?|c........",""):gsub("|?|r",""):lower()
		if list[i] == name or list[i] == instanceID then
			found = true
			break
		end
	end
	if not found and mlist:lower() == name then
		found = true
	end

	if found then
		return msg
	else
		return ""
	end
end

local classList = {
	[L.classLocalizate.WARRIOR:lower()] = 1,
	[L.classLocalizate.PALADIN:lower()] = 2,
	[L.classLocalizate.HUNTER:lower()] = 3,
	[L.classLocalizate.ROGUE:lower()] = 4,
	[L.classLocalizate.PRIEST:lower()] = 5,
	[L.classLocalizate.DEATHKNIGHT:lower()] = 6,
	[L.classLocalizate.SHAMAN:lower()] = 7,
	[L.classLocalizate.MAGE:lower()] = 8,
	[L.classLocalizate.WARLOCK:lower()] = 9,
	[L.classLocalizate.DRUID:lower()] = 11,
	["warrior"] = 1,
	["paladin"] = 2,
	["hunter"] = 3,
	["rogue"] = 4,
	["priest"] = 5,
	["deathknight"] = 6,
	["shaman"] = 7,
	["mage"] = 8,
	["warlock"] = 9,
	["druid"] = 11,
	["war"] = 1,
	["pal"] = 2,
	["hun"] = 3,
	["rog"] = 4,
	["pri"] = 5,
	["dk"] = 6,
	["sham"] = 7,
	["lock"] = 9,
	["dru"] = 11,
	["1"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["8"] = 7,
	["9"] = 9,
	["10"] = 10,
	["11"] = 11,
	["12"] = 12,
	["13"] = 13,
}

local function GSUB_Class(anti,list,msg)
	list = {strsplit(",",list)}
	local myClassIndex = select(3,UnitClass("player"))
	local found = false
	for i=1,#list do
		list[i] = list[i]:gsub("|?|c........",""):gsub("|?|r",""):lower()
		if classList[ list[i] ] == myClassIndex then
			found = true
			break
		end
	end

	if (found and anti == "") or (not found and anti == "!") then
		return msg
	else
		return ""
	end
end

local function GSUB_ClassUnique(list,msg)
	list = {strsplit(",",list)}
	local classInParty = {}
	for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in MRT.F.IterateRoster, MRT.F.GetRaidDiffMaxGroup() do
		if class then
			classInParty[ classList[class:lower()] or 0 ] = true
		end
	end

	local found = nil

	for i=1,#list do
		list[i] = list[i]:gsub("|?|c........",""):gsub("|?|r",""):lower()
		local classID = classList[ list[i] ]
		if classID and classInParty[classID] then
			found = classID
			break
		end
	end

	local myClassIndex = select(3,UnitClass("player"))
	if found == myClassIndex then
		found = true
	else
		found = false
	end

	if found then
		return msg
	else
		return ""
	end
end

local function GSUB_Race(anti,list,msg)
	list = {strsplit(",",list)}
	local myRace = select(2,UnitRace("player")):lower()
	local found = false
	for i=1,#list do
		list[i] = list[i]:gsub("|?|c........",""):gsub("|?|r",""):lower()
		if list[i] == myRace then
			found = true
			break
		end
	end

	if (found and anti == "") or (not found and anti == "!") then
		return msg
	else
		return ""
	end
end

local function GSUB_Group(anti,groups,msg)
	local myGroup = 1
	if IsInRaid() then
		for i=1,GetNumGroupMembers() do
			local name, _, subgroup = GetRaidRosterInfo(i)
			if name == MRT.SDB.charName then
				myGroup = subgroup
				break
			end
		end
	end
	myGroup = tostring(myGroup)
	local found = groups:find(myGroup)

	if (found and anti == "") or (not found and anti == "!") then
		return msg
	else
		return ""
	end
end


local mynamelowered = MRT.SDB.charName:lower()
local function GSUB_Time_hideOtherNames(name)
	local namefound = name:gsub("|c........",""):gsub("|r",""):lower()
	if namefound ~= mynamelowered and strsplit("@",namefound) ~= mynamelowered then
		return ""
	end
end

local function GSUB_Time(preText,t,msg,newlinesym)
	local timeText, opts = strsplit(",", t, 2)

	local time = tonumber(timeText)
	if not time then
		local min, sec = strsplit(":", timeText)
		if min and sec then
			time = (tonumber(min) or 0) * 60 + (tonumber(sec) or 0)
		else
			time = -1
		end
	end
	local prefixText

	local anyType
	local now = GetTime()
	local waEventID
	local addGlow
	local isAllParam

	local optNow
	while opts do
		optNow, opts = strsplit(",", opts, 2)

		if optNow == "e" then
			if opts then
				optNow, opts = strsplit(",", opts, 2)
			else
				optNow = nil
			end
			if optNow then
				local customEventStart = encounter_time_c[optNow]
				if customEventStart then
					time = customEventStart + time - now

					anyType = 1
				else
					anyType = 2
				end
			end
		elseif optNow:sub(1,1) == "p" then
			local isGlobalPhase,phase = optNow:match("^p(g?):?(.-)$")
			if phase and phase ~= "" then
				local prefixText = "P"..phase.." "

				local phaseStart = encounter_time_p[(isGlobalPhase == "g" and "g" or "")..phase]

				if phaseStart then
					time = phaseStart + time - now
					anyType = 1
				else
					anyType = 2
				end
			end
		elseif optNow == "glow" then
			addGlow = 1
		elseif optNow == "glowall" then
			addGlow = 2
			isAllParam = true
		elseif optNow == "all" then
			isAllParam = true
		else
			local prefix, arg1 = strsplit(":", optNow, 2)
			if prefix == "wa" then
				waEventID = (waEventID and waEventID.."," or "")..arg1
			elseif prefix == "SCC" or prefix == "SCS" or prefix == "SAA" or prefix == "SAR" then
				local eventStart = module.db.encounter_counters_time[optNow]
				if eventStart then
					time = eventStart + time - now

					anyType = 1
				else
					anyType = 2
				end
			end
		end
	end

	if not anyType and module.db.encounter_time then
		time = module.db.encounter_time + time - now
	end

	if waEventID and time <= 20 and type(WeakAuras)=="table" and ((module.db.encounter_time and not anyType) or anyType == 1) then
		local timeleft = time < 0 and 0 or ceil(time)
		if timeleft <= 5 or timeleft % 5 == 0 then
			for waEventIDnow in string_gmatch(waEventID, "[^,]+") do
				local wa_event_uid_cache = waEventIDnow..":"..timeleft..":"..preText..t..msg..newlinesym
				if not encounter_time_wa_uids[wa_event_uid_cache] then
					encounter_time_wa_uids[wa_event_uid_cache] = true
					if WeakAuras.ScanEvents and type(WeakAuras.ScanEvents)=="function" then
						WeakAuras.ScanEvents("EXRT_NOTE_TIME_EVENT",waEventIDnow,timeleft,msg)
						WeakAuras.ScanEvents("MRT_NOTE_TIME_EVENT",waEventIDnow,timeleft,msg)
					end
				end
			end
		end
	end

	if VMRT.Note.TimerOnlyMy and not isAllParam and not msg:find(MRT.SDB.charName) and not msg:find("{everyone}") then
		return ""
	end


	if VMRT.Note.TimerOnlyMy and not VMRT.Note.TimerOnlyMyEnableAllNames and msg:find("^%d+:%d+.-%- ") then
		msg = msg:gsub("([^ %-]+) |T.-|t *",GSUB_Time_hideOtherNames)
	end

	if time > 10 or not module.db.encounter_time or anyType == 2 then
		return preText.."|cffffed88"..(prefixText or "")..format("%d:%02d|r ",floor(time/60),time % 60)..msg..newlinesym
	elseif time < 0 then
		if VMRT.Note.TimerPassedHide then
			return ""
		else
			return preText.."|cff555555"..(prefixText or "")..msg:gsub("|c........",""):gsub("|r","").."|r"..newlinesym
		end
	else
		if time <= 5 and ((msg:find(MRT.SDB.charName) and (VMRT.Note.TimerGlow or addGlow == 1)) or (addGlow == 2)) then
			module.db.glowStatus = true
		end
		return preText.."|cff00ff00"..(prefixText or "")..format("%d:%02d ",floor(time/60),time % 60)..msg:gsub("|c........",""):gsub("|r",""):gsub(MRT.SDB.charName,"|r|cffff0000>%1<|r|cff00ff00").."|r"..newlinesym
	end
end

local function GSUB_Phase(anti,phase,msg)
	if not module.db.encounter_time then
		return msg
	else
		local isPhase
		local phaseNum = tonumber(phase)
		if phaseNum then
			isPhase = encounter_time_p[phase]
		elseif phase:sub(1,1) == "," then
			local cond1,cond2 = strsplit(",",phase:sub(2),nil)
			isPhase = cond1 and module.db.encounter_counters_time[cond1] and (not cond2 or not module.db.encounter_counters_time[cond2])
		else
			isPhase = encounter_time_p[phase]
		end
		if (isPhase and anti == "") or (not isPhase and anti == "!") then
			return msg
		else
			return ""
		end
	end
end

local allIcons = {
	["everyone"] = "",
}
for i=1,8 do
	local icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..i..":0|t"
	allIcons[ module.db.iconsLocalizatedNames[i] ] = icon
	allIcons[ "{rt"..i.."}" ] = icon

	for _,lang in pairs(iconsLangs) do
		allIcons[ module.db["icons"..lang.."Names"][i] ] = icon
	end
end
for i=1,#module.db.otherIconsList do
	local iconData = module.db.otherIconsList[i]
	allIcons[ iconData[1] ] = "|T"..(iconData.path or iconData[2])..(iconData.crop or ":16").."|t"
end

local function GSUB_RaidIcon(text)
	return allIcons[text]
end

local GSUB_AutoColor_Data = {}
local function GSUB_AutoColorCreate()
	if canaccessvalue and ((IsInRaid() and not canaccessvalue("raid1")) or (not IsInRaid() and not canaccessvalue("party1"))) then
		return
	end
	wipe(GSUB_AutoColor_Data)
	for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in MRT.F.IterateRoster, MRT.F.GetRaidDiffMaxGroup() do
		if class and name then
			class = MRT.F.classColor(class)
			GSUB_AutoColor_Data[ name ] = "|c"..class..name.."|r"
			name = strsplit("-",name)
			GSUB_AutoColor_Data[ name ] = "|c"..class..name.."|r"
		end
	end
end
local function GSUB_AutoColor(text)
	return GSUB_AutoColor_Data[text]
end

local function applyIconAlpha(text, alpha)
	if not alpha or alpha >= 100 or not text or text == "" then
		return text
	end
	local mul = alpha / 100
	local v = math.floor(255 * mul + 0.5)
	if v < 0 then v = 0 elseif v > 255 then v = 255 end
	return (text:gsub("|T([^|]-)|t", function(args)
		local parts = { strsplit(":", args) }
		local n = #parts
		if n >= 14 then
			parts[12] = math.floor((tonumber(parts[12]) or 255) * mul + 0.5)
			parts[13] = math.floor((tonumber(parts[13]) or 255) * mul + 0.5)
			parts[14] = math.floor((tonumber(parts[14]) or 255) * mul + 0.5)
			return "|T" .. table.concat(parts, ":") .. "|t"
		elseif n == 11 then
			return "|T" .. args .. ":" .. v .. ":" .. v .. ":" .. v .. "|t"
		elseif n == 5 then
			local path = parts[1]
			local h = parts[2] or "16"
			local w = parts[3] or h
			local x = parts[4] or "0"
			local y = parts[5] or "0"
			return "|T" .. path .. ":" .. h .. ":" .. w .. ":" .. x .. ":" .. y
				.. ":64:64:0:64:0:64:" .. v .. ":" .. v .. ":" .. v .. "|t"
		elseif n >= 1 and n <= 3 then
			local path = parts[1]
			local h = parts[2] or "16"
			local w = parts[3] or h
			return "|T" .. path .. ":" .. h .. ":" .. w
				.. ":0:0:64:64:0:64:0:64:" .. v .. ":" .. v .. ":" .. v .. "|t"
		else
			return "|T" .. args .. "|t"
		end
	end))
end

local function resizeAutoIcons(text, fontSize)
	if not text or text == "" or not fontSize or fontSize <= 0 then return text end
	local size = fontSize + 6
	if size < 18 then size = 18 end
	local yOff = math.floor(0.4 * fontSize - size / 2)
	return (text:gsub("|T([^|]-)|t", function(args)
		local parts = { strsplit(":", args) }
		local n = #parts
		local path = parts[1]
		if not path or path == "" then
			return "|T" .. args .. "|t"
		end
		if n >= 1 and n <= 3 then
			local h = parts[2] and tonumber(parts[2])
			local w = parts[3] and tonumber(parts[3])
			if h and h ~= 0 and h ~= 16 then
				return "|T" .. args .. "|t"
			end
			if w and w ~= 0 and w ~= 16 then
				return "|T" .. args .. "|t"
			end
			return "|T" .. path .. ":" .. size .. ":" .. size .. ":0:" .. yOff .. ":64:64:0:64:0:64|t"
		elseif n == 5 then
			local h = tonumber(parts[2])
			local w = tonumber(parts[3])
			if h and h ~= 0 and h ~= 16 then
				return "|T" .. args .. "|t"
			end
			if w and w ~= 0 and w ~= 16 then
				return "|T" .. args .. "|t"
			end
			return "|T" .. path .. ":" .. size .. ":" .. size .. ":0:" .. yOff .. ":64:64:0:64:0:64|t"
		elseif n == 11 then
			local h = tonumber(parts[2])
			local w = tonumber(parts[3])
			local texW = tonumber(parts[6]) or 64
			local texH = tonumber(parts[7]) or 64
			local crL = tonumber(parts[8]) or 0
			local crR = tonumber(parts[9]) or texW
			local crT = tonumber(parts[10]) or 0
			local crB = tonumber(parts[11]) or texH
			if h and h ~= 0 and h ~= 16 then
				return "|T" .. args .. "|t"
			end
			if w and w ~= 0 and w ~= 16 then
				return "|T" .. args .. "|t"
			end
			return "|T" .. path .. ":" .. size .. ":" .. size .. ":0:" .. yOff
				.. ":" .. texW .. ":" .. texH
				.. ":" .. crL .. ":" .. crR .. ":" .. crT .. ":" .. crB .. "|t"
		else
			return "|T" .. args .. "|t"
		end
	end))
end

-- Resolve the player's combat role for {D}/{H}/{T} note tags.
-- Retail uses GetSpecialization; 3.3.5a has no spec API, so derive the role from the
-- player's primary talent tree. Ambiguous trees (Druid Feral, all Death Knight trees)
-- default to DAMAGER since bear-tank / DK-tank can't be told apart from DPS by talents.
local NOTE_ROLE_BY_CLASS = {
	WARRIOR     = {"DAMAGER","DAMAGER","TANK"},
	PALADIN     = {"HEALER","TANK","DAMAGER"},
	HUNTER      = {"DAMAGER","DAMAGER","DAMAGER"},
	ROGUE       = {"DAMAGER","DAMAGER","DAMAGER"},
	PRIEST      = {"HEALER","HEALER","DAMAGER"},
	DEATHKNIGHT = {"DAMAGER","DAMAGER","DAMAGER"},
	SHAMAN      = {"DAMAGER","DAMAGER","HEALER"},
	MAGE        = {"DAMAGER","DAMAGER","DAMAGER"},
	WARLOCK     = {"DAMAGER","DAMAGER","DAMAGER"},
	DRUID       = {"DAMAGER","DAMAGER","HEALER"},
}
local function GetNoteRole()
	if GetSpecialization and GetSpecializationInfo then
		local spec = GetSpecialization()
		if spec then return select(5, GetSpecializationInfo(spec)) end
		return nil
	end
	if not GetTalentTabInfo then return nil end
	local _, class = UnitClass("player")
	local map = class and NOTE_ROLE_BY_CLASS[class]
	if not map then return nil end
	local numTabs = (GetNumTalentTabs and GetNumTalentTabs()) or 3
	local maxPoints, primary = -1, 1
	for i = 1, numTabs do
		local pts = select(5, GetTalentTabInfo(i))
		if pts and pts > maxPoints then maxPoints = pts; primary = i end
	end
	return map[primary] or "DAMAGER"
end

local txtWithIcons
do
	txtWithIcons = function(self, t, onlyTimerUpdate)
		if not onlyTimerUpdate or not self.preTimerText then
			GSUB_AutoColorCreate()
			t = t or ""

			if t:find("{self}") then
				t = string_gsub(t,"{self}",VMRT.Note.SelfText or "")
			end

			local role = GetNoteRole and GetNoteRole()
			if role then
				if role ~= "HEALER" then t = string_gsub(t,"{[Hh]}.-{/[Hh]}","") end
				if role ~= "TANK" then t = string_gsub(t,"{[Tt]}.-{/[Tt]}","") end
				if role ~= "DAMAGER" then t = string_gsub(t,"{[Dd]}.-{/[Dd]}","") end
			end
			-- Strip the surviving role markers so the kept text shows without {D}/{H}/{T}.
			t = string_gsub(t,"{/?[DdHhTt]}","")

			t =    t:gsub("{0}.-{/0}","")
				:gsub("(\n{!?[CcPpGg]:?[^}]+})\n","%1")
				:gsub("\n({/[CcPpGg]}\n)","%1")
				:gsub("{(!?)[Pp]:([^}]+)}(.-){/[Pp]}",GSUB_Player)
				:gsub("{(!?)[Cc]:([^}]+)}(.-){/[Cc]}",GSUB_Class)
				:gsub("{[Cc][Ll][Aa][Ss][Ss][Uu][Nn][Ii][Qq][Uu][Ee]:([^}]+)}(.-){/[Cc][Ll][Aa][Ss][Ss][Uu][Nn][Ii][Qq][Uu][Ee]}",GSUB_ClassUnique)
				:gsub("{(!?)[Gg](%d+)}(.-){/[Gg]}",GSUB_Group)
				:gsub("{(!?)[Rr][Aa][Cc][Ee]:([^}]+)}(.-){/[Rr][Aa][Cc][Ee]}",GSUB_Race)
				:gsub("{[Ee]:([^}]+)}(.-){/[Ee]}",GSUB_Encounter)
				:gsub("{[Zz]:([^}]+)}(.-){/[Zz]}",GSUB_Zone)
				:gsub("{(!?)[Pp]([^}:][^}]*)}(.-){/[Pp]}",GSUB_Phase)
				:gsub("{icon:([^}]+)}","|T%1:16|t")
				:gsub("{spell:(%d+):?(%d*)}",GSUB_Icon)

				:gsub("%b{}",allIcons)
				:gsub("||([cr])","|%1")

				:gsub("[^ \n,%(%)%[%]_%$#@!&]+",GSUB_AutoColor_Data)
				:gsub("\n+$", "")

			self.preTimerText = t
		else
			t = self.preTimerText
		end

		return t:gsub("([^\n]*){time:([0-9:%.]+[^{}]*)}([^\n]*)(\n?)",GSUB_Time)
			:gsub("%b{}",""), nil
	end
end

function module.options:Load()
	self:CreateTilte()

	module.db.otherIconsAdditionalList = {}
	if IS_WOTLK_335 then
		module.db.otherIconsAdditionalList = {
			-- ===================== CLASS COOLDOWNS (Raid Cooldown) =====================
			-- Paladin
			642, 10310, 19752, 31884, 10278, 1044, 1038, 6940, 62124, 64205, 31821, 20066, 10308, 498, 31842, 54428, 20216, 66233, 31789, 31935, 2812, 24275, 0,
			-- Warrior
			355, 12975, 871, 1161, 12809, 676, 55694, 1719, 46924, 20252, 3411, 23920, 2565, 5246, 18499, 6552, 72, 64382, 12292, 12328, 2687, 20230, 60970, 46968, 0,
			-- Death Knight
			49576, 48707, 42650, 61999, 56222, 51052, 49028, 49016, 48792, 55233, 49222, 49206, 47568, 49203, 47476, 47528, 49039, 51271, 48982, 45529, 46584, 49005, 0,
			-- Druid
			29166, 20748, 6795, 740, 5209, 17116, 22812, 5229, 50334, 61336, 53201, 33831, 22842, 18562, 1850, 16689, 16979, 49376, 22570, 5217, 50516, 5211, 0,
			-- Shaman
			16190, 32182, 2825, 20608, 2894, 2062, 8177, 51490, 16166, 30823, 55198, 51514, 16188, 57994, 8983, 51533, 0,
			-- Priest
			64843, 724, 6346, 10060, 64901, 47788, 33206, 10890, 586, 47585, 64044, 15487, 14751, 34433, 47540, 33076, 34861, 32379, 605, 0,
			-- Mage
			11958, 12472, 45438, 55342, 12051, 2139, 1953, 66, 31687, 12042, 12043, 122, 11129, 31661, 11426, 44572, 0,
			-- Warlock
			20765, 17928, 30283, 6229, 29858, 18708, 47241, 47193, 18540, 19647, 6789, 1122, 17877, 6358, 0,
			-- Rogue
			5277, 57934, 1966, 2983, 13750, 31224, 26889, 51690, 14185, 51722, 408, 2094, 1776, 1725, 31230, 13877, 36554, 14177, 0,
			-- Hunter
			19801, 34477, 19577, 5384, 19263, 781, 3045, 34026, 60192, 19574, 13809, 34600, 1499, 53271, 23989, 13813, 13795, 1543, 34490, 19386, 53351, 14327, 0,
			-- ===================== BOSSES: ULDUAR =====================
			-- Flame Leviathan
			62297, 62374, 62475, 62396, 62907, 0,
			-- Ignis the Furnace Master
			63477, 62488, 63472, 62382, 63473, 0,
			-- Razorscale
			48642, 63236, 64733, 64771, 64021, 0,
			-- XT-002 Deconstructor
			65121, 64234, 62776, 63849, 64206, 0,
			-- Assembly of Iron
			64215, 63486, 63481, 63483, 64320, 63490, 62274, 62273, 61973, 61903, 61888, 63494, 61920, 0,
			-- Kologarn
			63346, 64002, 63355, 64003, 64292, 62166, 63982, 0,
			-- Auriaya
			64396, 64386, 64455, 64389, 64675, 64688, 64447, 0,
			-- Hodir
			65123, 61968, 62188, 63512, 0,
			-- Thorim
			62042, 62526, 62017, 62466, 62130, 64390, 62507, 62605, 62604, 0,
			-- Freya
			63571, 62869, 62678, 62947, 62584, 64604, 64587, 34539, 62865, 62438, 62859, 0,
			-- Freya - Elders
			62928, 62344, 62932, 0,
			-- Mimiron
			63666, 64529, 63631, 63027, 63274, 64402, 63414, 64444, 63811, 64383, 64566, 64582, 64570, 64623, 65333, 65192, 64616, 0,
			-- General Vezax
			62660, 63276, 63322, 62662, 62661, 63145, 0,
			-- Yogg-Saron
			63138, 62979, 63050, 63802, 63830, 64139, 64125, 57687, 64027, 64059, 64163, 64486, 64189, 0,
			-- Algalon
			64584, 65108, 64412, 64596, 0,
			-- ===================== BOSSES: TRIAL OF THE CRUSADER =====================
			-- Northrend Beasts
			66331, 66317, 66636, 66330, 66883, 66823, 66869, 68335, 66948, 66947, 66794, 66819, 66820, 66901, 66902, 66824, 66879, 66689, 66759, 52311, 66758, 66683, 0,
			-- Lord Jaraxxus
			66269, 66258, 66197, 66237, 67031, 66877, 66334, 67009, 66496, 66532, 0,
			-- Faction Champions
			66020, 66017, 66115, 66009, 66613, 66008, 66010, 66011, 65802, 65801, 65793, 65790, 65816, 65809, 65820, 65947, 65927, 65932, 65931, 65983, 65980, 66063, 66054, 65544, 65543, 65545, 65542, 65860, 66086, 65857, 65859, 66178, 65960, 65961, 65871, 66207, 65878, 65880, 65869, 0,
			-- Val'kyr Twins
			65916, 65875, 65724, 65748, 65950, 66001, 43827, 0,
			-- Anub'arak
			65982, 45419, 66332, 66134, 66012, 66013, 65981, 67574, 66118, 0,
			-- ===================== BOSSES: ICECROWN CITADEL =====================
			-- Lord Marrowgar
			69076, 69057, 72669, 69146, 0,
			-- Lady Deathwhisper
			61131, 34018, 70900, 70901, 70674, 71236, 71289, 71001, 71426, 71204, 71237, 72007, 72905, 0,
			-- Gunship Battle
			69705, 71188, 71193, 71195, 69638, 69652, 69651, 0,
			-- Deathbringer Saurfang
			72737, 72378, 72293, 28836, 72385, 72410, 72444, 72173, 72769, 0,
			-- Festergut
			69166, 72219, 69279, 69240, 69195, 72297, 0,
			-- Rotface
			69508, 69674, 69760, 69774, 69558, 72272, 69839, 69789, 0,
			-- Prof. Putricide
			70542, 70539, 70341, 70351, 70447, 70672, 70911, 72833, 71255, 72295, 71279, 72451, 71617, 72843, 70352, 70353, 71621, 0,
			-- Blood Prince Council
			70952, 72999, 72053, 72037, 72039, 71718, 72040, 71807, 71943, 0,
			-- Blood-Queen Lana'thel
			71340, 71510, 71266, 73070, 70946, 70877, 70867, 71772, 70923, 71818, 0,
			-- Valithria Dreamwalker
			70751, 70633, 71179, 70588, 72483, 69325, 70935, 70873, 70933, 17204, 70922, 0,
			-- Sindragosa
			43810, 69766, 70106, 70126, 69649, 69762, 70123, 71077, 70128, 0,
			-- The Lich King
			70372, 70358, 72143, 70337, 70541, 73539, 28747, 71844, 69037, 72762, 69409, 70498, 68980, 73650, 73654, 72350, 68981, 72262, 69200, 69103, 69712, 69090, 68983, 69242, 0,
		}
	elseif MRT.isBC then
		module.db.otherIconsAdditionalList = {
			26983,2825,32182,16190,0,0,
			38219,38215,36459,38246,37478,37138,37675,37640,37641,38441,38445,37764,38316,38310,38509,38280,0,
			34172,25778,34162,39329,42783,11829,36834,36815,34480,30225,37027,36723,35879,"135188","135507","135379","132455","133528","135682","134976",0,
		}
	end

	if IS_WOTLK_335 and module.db.otherIconsAdditionalList and #module.db.otherIconsAdditionalList > 0 then
		for i=1,#module.db.otherIconsAdditionalList do
			local v = module.db.otherIconsAdditionalList[i]
			if type(v) == 'string' and v:match('^%d+$') then
				module.db.otherIconsAdditionalList[i] = tonumber(v)
			end
		end
	end

	function self:DebugGetIcons(notUseJJBox,onlyTextures)
		local L,U,F,C,P
		local RES = nil
		function F(eID)
			local f=select(4,EJ_GetEncounterInfoByIndex(eID))
			repeat
				local I=C_EncounterJournal.GetSectionInfo(f)
				local O=I and (I.headerType == 3)
				if O then
					f=I.siblingSectionID
				end
			until not O
			return f
		end
		function C(f)
			local I=C_EncounterJournal.GetSectionInfo(f)
			if I.firstChildSectionID then
				C(I.firstChildSectionID)
			end
			if onlyTextures then
				if I.abilityIcon and I.abilityIcon~=0 then
					L[I.abilityIcon]=true
				end
			else
				if I.spellID and I.spellID~=0 and P(I.spellID) then
					L[I.spellID]=true
				end
			end
			if I.siblingSectionID then
				C(I.siblingSectionID)
			end
		end
		function P(s)
			local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
			local i=GetSpellTexture(s)
			if not U[i] then
				U[i]=1
				return true
			end
		end
		local i = 1
		while EJ_GetEncounterInfoByIndex(i) do
			L,U={},{}
			local f=F(i)
			C(f)
			local s=""
			for q,w in pairs(L)do
				s=s..(onlyTextures and '"' or "")..q..(onlyTextures and '"' or "")..","
			end
			print(s..'0,')
			if not notUseJJBox then
				JJBox(s..'0,')
			else
				RES = (RES or "")..s.."0,\n"
			end
			i = i + 1
		end
		if notUseJJBox then
			GMRT.F:Export2(RES)
		end
	end


	module.db.encountersList = {
		{"Icecrown Citadel",
			"Lord Marrowgar","Lady Deathwhisper","Gunship Battle","Deathbringer Saurfang",
			"Festergut","Rotface","Professor Putricide","Blood Prince Council","Blood-Queen Lana'thel",
			"Valithria Dreamwalker","Sindragosa","The Lich King"},
		{"Trial of the Crusader",
			"Northrend Beasts","Lord Jaraxxus","Faction Champions","Twin Val'kyr","Anub'arak"},
		{"Ulduar",
			"Flame Leviathan","Ignis the Furnace Master","Razorscale","XT-002 Deconstructor","Assembly of Iron",
			"Kologarn","Auriaya","Hodir","Thorim","Freya","Mimiron","General Vezax","Yogg-Saron","Algalon the Observer"},
		{"Naxxramas",
			"Anub'Rekhan","Grand Widow Faerlina","Maexxna",
			"Noth the Plaguebringer","Heigan the Unclean","Loatheb",
			"Instructor Razuvious","Gothik the Harvester","The Four Horsemen",
			"Patchwerk","Grobbulus","Gluth","Thaddius",
			"Sapphiron","Kel'Thuzad"},
		{"The Ruby Sanctum","Halion"},
		{"Vault of Archavon","Archavon the Stone Watcher","Emalon the Storm Watcher","Koralon the Flame Watcher","Toravon the Ice Watcher"},
		{"The Obsidian Sanctum","Sartharion"},
		{"The Eye of Eternity","Malygos"},
		{"Onyxia's Lair","Onyxia"},
		{"The Nexus: Oculus","Ley-Guardian Eregos"},
		{"Karazhan",
			"Attumen the Huntsman","Moroes","Maiden of Virtue","Opera Event","The Curator",
			"Terestian Illhoof","Shade of Aran","Netherspite","Chess Event","Prince Malchezaar","Nightbane"},
		{"Gruul's Lair","High King Maulgar","Gruul the Dragonkiller"},
		{"Magtheridon's Lair","Magtheridon"},
		{"Serpentshrine Cavern",
			"Hydross the Unstable","The Lurker Below","Leotheras the Blind","Fathom-Lord Karathress",
			"Morogrim Tidewalker","Lady Vashj"},
		{"Tempest Keep: The Eye",
			"Al'ar","Void Reaver","High Astromancer Solarian","Kael'thas Sunstrider"},
		{"Hyjal Summit",
			"Rage Winterchill","Anetheron","Kaz'rogal","Azgalor","Archimonde"},
		{"Black Temple",
			"High Warlord Naj'entus","Supremus","Shade of Akama","Teron Gorefiend","Gurtogg Bloodboil",
			"Reliquary of Souls","Mother Shahraz","The Illidari Council","Illidan Stormrage"},
		{"Zul'Aman",
			"Akil'zon","Nalorakk","Jan'alai","Halazzi","Hex Lord Malacrass","Zul'jin"},
		{"Sunwell Plateau",
			"Kalecgos","Brutallus","Felmyst","Eredar Twins","M'uru","Kil'jaeden"},
	}

	module.db.mapToEncounter = {

		[1358] = {2265,2263,2266},
		[1352] = {2276,2280},
		[1353] = 2271,
		[1354] = 2268,
		[1357] = 2272,
		[1364] = 2281,


		[1148] = 2144,
		[1149] = 2141,
		[1151] = 2136,
		[1153] = 2128,
		[1152] = 2134,
		[1154] = {2145,2135},
		[1155] = 2122,


		[1010] = -1012,
		[934] = -968,	[935] = -968,
		[1004] = -1041,
		[1041] = -1022,	[1042] = -1022,
		[1038] = -1030,	[1043] = -1030,

		[1162] = -1023,
		[974] = -1002,	[975] = -1002,	[974] = -1002,	[975] = -1002,	[976] = -1002,	[977] = -1002,	[978] = -1002,	[979] = -1002,	[980] = -1002,
		[936] = -1001,
		[1039] = -1036,	[1040] = -1036,
		[1015] = -1021,	[1016] = -1021,	[1017] = -1021,	[1018] = -1021,	[1029] = -1021,


		[1581] = {2329,2327,2334},
		[1592] = 2328,
		[1593] = 2336,
		[1590] = 2333,
		[1591] = 2331,
		[1594] = 2335,
		[1595] = 2343,
		[1596] = 2345,
		[1597] = {2337,2344},


		[1666] = -1182,	[1667] = -1182,	[1668] = -1182,
		[1674] = -1183,	[1697] = -1183,
		[1669] = -1184,
		[1663] = -1185,	[1664] = -1185,	[1665] = -1185,
		[1693] = -1186,	[1694] = -1186,	[1695] = -1186,
		[1683] = -1187,	[1684] = -1187,	[1685] = -1187,	[1687] = -1187,
		[1677] = -1188,	[1678] = -1188,	[1679] = -1188,	[1680] = -1188,
		[1675] = -1189,	[1676] = -1189,


		[1735] = {2398,2418,2383,2399},
		[1744] = 2406,
		[1745] = 2405,
		[1746] = 2402,
		[1747] = {2417,2407},
		[1748] = 2407,
		[1750] = 2412,


		[1998] = 2423,
		[1999] = {2433,2429},
		[2000] = {2432,2434,2430},
		[2001] = {2436,2431,2422},
		[2002] = 2435,


		[2047] = 2512,
		[2048] = 2540,
		[2049] = {2544,2539},
		[2061] = {2542,2553,2529},
		[2050] = 2546,
		[2052] = {2543,2549},
		[2051] = 2537,


		[2166] = {2688,2693,2680,2689,2683},
		[2167] = 2687,
		[2168] = 2682,
		[2169] = 2684,
		[2170] = 2685,

		[2232] = 2820,
		[2244] = {2731,2737},
		[2240] = {2708,2728},
		[2233] = 2824,
		[2237] = 2786,
		[2238] = 2677,

		[2292] = {2902,2918},
		[2291] = 2917,
		[2293] = 2898,
		[2294] = {2919,2920,2921},
		[2295] = 2922,
		[2296] = 2922,

		[2406] = {3009,3010,3011,3012,3013},
		[2408] = 3014,
		[2411] = 3015,
		[2409] = 3016,
	}


	function self:GetBossName(bossID)
		if type(bossID) == 'string' then
			return bossID
		end
		if not bossID then return nil end
		if bossID < 0 then
			return (L.EJInstanceName and L.EJInstanceName[-bossID]) or (L.instanceName and L.instanceName[-bossID]) or ("Instance "..(-bossID))
		end
		return (L.bossName and L.bossName[bossID]) or ("Boss "..bossID)
	end
		local function SanitizeBossIconName(name)
			name = tostring(name or "")
			name = name:lower()
			name = name:gsub("[’'`]","" )
			name = name:gsub("[^a-z0-9]+","_")
			name = name:gsub("_+","_")
			name = name:gsub("^_",""):gsub("_$","")
			return name
		end

		function self:GetBossIconPath(bossID)
			local bossName = self:GetBossName(bossID)
			if not bossName or bossName == "" then
				return nil
			end
			local safe = SanitizeBossIconName(bossName)
			if safe == "" then
				return nil
			end
			local base = MRT.BossIconFileByKey and MRT.BossIconFileByKey[safe]
			if not base then
				return nil
			end
			return "Interface\\AddOns\\"..GlobalAddonName.."\\media\\bossicons\\"..base..".tga"
		end

		function self:GetBossIcon(bossID)
			if type(bossID) ~= 'number' then
				local p = self:GetBossIconPath(bossID)
				return p and ("|T"..p..":12:24|t") or ""
			end
			local p = self:GetBossIconPath(bossID)
			if p then
				return "|T"..p..":12:24|t"
			end
			if bossID and bossID > 0 and MRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
				local bossImg = select(5, EJ_GetCreatureInfo(1, MRT.GDB.encounterIDtoEJ[bossID]))
				if type(bossImg) == "string" and bossImg ~= "" then
					return "|T"..bossImg..":12:24|t"
				end
			end
			return ""
		end

	local BlackNoteNow = nil
	local NoteIsSelfNow = nil
	self.IsMainNoteNow = true

	self.decorationLine = ELib:DecorationLine(self,true,"BACKGROUND",-5):Point("TOPLEFT",self,0,-16):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-36)

	self.tab = ELib:Tabs(self,0,L.message,L.minimapmenuset,L.Profiles,HELP_LABEL):Point(0,-36):Size(850,598):SetTo(1)
	self.tab:SetBackdropBorderColor(0,0,0,0)
	self.tab:SetBackdropColor(0,0,0,0)

	self.tab.tabs[1]:SetPoint("TOPLEFT",0,20)

	ELib:DecorationLine(self.tab.tabs[1]):Point("TOPLEFT",0,-129):Point("BOTTOMRIGHT",'x',"TOPRIGHT",0,-130)

	self.NotesList = ELib:ScrollList(self.tab.tabs[1]):Size(230,467+20):Point(0,-131):AddDrag():HideBorders()
	self.NotesList.selected = 1
	self.NotesList.LINE_PADDING_LEFT = 2
	self.NotesList.SCROLL_WIDTH = 12

	self.NotesList.Frame.ScrollBar:Size(10,0):Point("TOPRIGHT",0,0):Point("BOTTOMRIGHT",0,0)
	self.NotesList.Frame.ScrollBar.buttonUP:HideBorders()
	self.NotesList.Frame.ScrollBar.buttonDown:HideBorders()

	ELib:DecorationLine(self.NotesList.Frame.ScrollBar):Point("TOPLEFT",-1,1):Point("BOTTOMRIGHT",'x',"BOTTOMLEFT",0,0)
	ELib:DecorationLine(self.tab.tabs[1]):Point("TOPLEFT",self.NotesList,"TOPRIGHT",0,1):Point("BOTTOMLEFT",self,"BOTTOM",0,0):Size(1,0)

	local function SwapBlackNotes(noteFrom,noteTo)
		if noteTo < 1 or noteFrom < 1 or noteTo > #VMRT.Note.Black or noteFrom > #VMRT.Note.Black or not VMRT.Note.Black[noteTo] or not VMRT.Note.Black[noteFrom] then
			return
		end
		local text = VMRT.Note.Black[noteTo]
		local title = VMRT.Note.BlackNames[noteTo]
		local boss = VMRT.Note.AutoLoad[noteTo]
		local lastUpdateName = VMRT.Note.BlackLastUpdateName[noteTo]
		local lastUpdateTime = VMRT.Note.BlackLastUpdateTime[noteTo]

		VMRT.Note.Black[noteTo] = VMRT.Note.Black[noteFrom]
		VMRT.Note.BlackNames[noteTo] = VMRT.Note.BlackNames[noteFrom]
		VMRT.Note.AutoLoad[noteTo] = VMRT.Note.AutoLoad[noteFrom]
		VMRT.Note.BlackLastUpdateName[noteTo] = VMRT.Note.BlackLastUpdateName[noteFrom]
		VMRT.Note.BlackLastUpdateTime[noteTo] = VMRT.Note.BlackLastUpdateTime[noteFrom]

		VMRT.Note.Black[noteFrom] = text
		VMRT.Note.BlackNames[noteFrom] = title
		VMRT.Note.AutoLoad[noteFrom] = boss
		VMRT.Note.BlackLastUpdateName[noteFrom] = lastUpdateName
		VMRT.Note.BlackLastUpdateTime[noteFrom] = lastUpdateTime

		module.options:NotesListUpdateNames()
		module.options.NotesList.selected = noteTo + 2
		module.options.NotesList:Update()
	end

	self.NotesList.ButtonMoveUp = CreateFrame("Button",nil,self.NotesList)
	self.NotesList.ButtonMoveUp:Hide()
	self.NotesList.ButtonMoveUp:SetSize(8,8)
	self.NotesList.ButtonMoveUp:SetScript("OnClick",function(self)
		SwapBlackNotes(self.index,self.index - 1)
	end)
	self.NotesList.ButtonMoveUp.i = self.NotesList.ButtonMoveUp:CreateTexture()
	self.NotesList.ButtonMoveUp.i:SetPoint("CENTER")
	self.NotesList.ButtonMoveUp.i:SetSize(16,16)
	self.NotesList.ButtonMoveUp.i:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
	self.NotesList.ButtonMoveUp.i:SetTexCoord(0.25,0.3125,0.625,0.5)

	self.NotesList.ButtonMoveDown = CreateFrame("Button",nil,self.NotesList)
	self.NotesList.ButtonMoveDown:Hide()
	self.NotesList.ButtonMoveDown:SetSize(8,8)
	self.NotesList.ButtonMoveDown:SetScript("OnClick",function(self)
		SwapBlackNotes(self.index,self.index + 1)
	end)
	self.NotesList.ButtonMoveDown.i = self.NotesList.ButtonMoveDown:CreateTexture()
	self.NotesList.ButtonMoveDown.i:SetPoint("CENTER")
	self.NotesList.ButtonMoveDown.i:SetSize(16,16)
	self.NotesList.ButtonMoveDown.i:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
	self.NotesList.ButtonMoveDown.i:SetTexCoord(0.25,0.3125,0.5,0.625)

	self.NotesList.UpdateAdditional = function(self,val)
		self.ButtonMoveUp:Hide()
		self.ButtonMoveDown:Hide()
		for i=1,#self.List do
			local line = self.List[i]
			if line.index == 1 or line.index == 2 or line.index == #self.L or line.index == self.selected then
				line.ignoreDrag = true
			else
				line.ignoreDrag = false
			end
		end
		for i=1,#self.List-1 do
			if self.selected == self.List[i].index then
				self.ButtonMoveUp:SetPoint("BOTTOMRIGHT",self.List[i],"RIGHT",-2,0)
				self.ButtonMoveDown:SetPoint("TOPRIGHT",self.List[i],"RIGHT",-2,0)
				self.ButtonMoveUp:SetParent(self.List[i])
				self.ButtonMoveDown:SetParent(self.List[i])
				self.ButtonMoveUp.index = self.List[i].index - 2
				self.ButtonMoveDown.index = self.List[i].index - 2
				if i > 3 then
					self.ButtonMoveUp:Show()
				end
				if i >= 3 and i <= #self.List-2 then
					self.ButtonMoveDown:Show()
				end
				return
			end
		end
	end

	local function NotesListUpdateNames()
		local bossesToGreen = {}
		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID and module.db.mapToEncounter[mapID] then
			local encounters = module.db.mapToEncounter[mapID]
			if type(encounters) == 'table' then
				for i=1,#encounters do
					bossesToGreen[ encounters[i] ] = true
				end
			else
				bossesToGreen[encounters] = true
			end
		end
		self.NotesList.L = {}

		self.NotesList.L[1] = "|cff55ee55"..L.messageTab1
		self.NotesList.L[2] = L.NoteSelf
		for i=1,#VMRT.Note.Black do
			self.NotesList.L[i+2] = (VMRT.Note.AutoLoad[i] and (bossesToGreen[ VMRT.Note.AutoLoad[i] ] and "|cff00ff00" or "|cffffff00")..module.options:GetBossIcon(VMRT.Note.AutoLoad[i]).."["..module.options:GetBossName(VMRT.Note.AutoLoad[i]).."]|r" or "")..(VMRT.Note.BlackNames[i] or i)
		end
		self.NotesList.L[#self.NotesList.L + 1] = "|cff00aaff"..L.NoteAdd
		self.NotesList:Update()
	end
	NotesListUpdateNames()
	self.NotesListUpdateNames = NotesListUpdateNames

	local function UpdatePageAfterGettingNote()
		if NoteIsSelfNow then
			self.NotesList:SetListValue(2)
		elseif BlackNoteNow then
			self.NotesList:SetListValue(BlackNoteNow + 2)
		else
			self.NotesList:SetListValue(1)
		end
	end
	self.UpdatePageAfterGettingNote = UpdatePageAfterGettingNote

	module.options.LastIndex = 1
	function self.NotesList:SetListValue(index)
		module.options.LastIndex = index

		module.options.buttonsend:SetShown(index == 1)
		module.options.buttonundo:SetShown(index == 1)
		module.options.buttoncopy:SetShown(index > 2)
		module.options.buttonwindow:SetShown(index > 2)
		module.options.buttoncopyPersonal:SetShown(index > 2)

		BlackNoteNow = nil
		NoteIsSelfNow = nil
		module.options.IsMainNoteNow = nil

		if index == 1 then
			module.options.DraftName:Enable()
			module.options.RemoveDraft:Disable()
			module.options.autoLoadDropdown:Enable()
		elseif index > 2 then
			module.options.DraftName:Enable()
			module.options.RemoveDraft:Enable()
			module.options.autoLoadDropdown:Enable()
		else
			module.options.DraftName:Disable()
			module.options.RemoveDraft:Disable()
			module.options.autoLoadDropdown:Disable()
		end

		if index == 1 then
			module.options.NoteEditBox.EditBox:SetText(VMRT.Note.Text1 or "")


			module.options.IsMainNoteNow = true

			module.options.DraftName:SetText( VMRT.Note.DefName or "" )

			module.options.autoLoadDropdown:UpdateText(VMRT.Note.AutoLoad[0])
		elseif index == 2 then
			module.options.NoteEditBox.EditBox:SetText(VMRT.Note.SelfText or "")
			module.options.DraftName:SetText( L.NoteSelf )

			module.options.autoLoadDropdown:UpdateText()

			NoteIsSelfNow = true
		elseif index == #self.L then
			VMRT.Note.Black[#VMRT.Note.Black + 1] = ""
			tinsert(self.L,#self.L - 1,#VMRT.Note.Black)
			module.options.NoteEditBox.EditBox:SetText("")
			self:Update()

			BlackNoteNow = #VMRT.Note.Black
			module.options.DraftName:SetText( "" )

			NotesListUpdateNames()

			module.options.autoLoadDropdown:UpdateText()
		else
			index = index - 2
			if IsShiftKeyDown() then

			end
			module.options.NoteEditBox.EditBox:SetText(VMRT.Note.Black[index] or "")

			BlackNoteNow = index
			module.options.DraftName:SetText( VMRT.Note.BlackNames[index] or "" )

			module.options.autoLoadDropdown:UpdateText(VMRT.Note.AutoLoad[index])
		end
	end

	self.NotesList:SetScript("OnShow",function(self)
		NotesListUpdateNames()
	end)

	function self.NotesList:HoverListValue(isHover,index)
		if not isHover then
			GameTooltip_Hide()
		else
			GameTooltip:SetOwner(self,"ANCHOR_CURSOR")
			GameTooltip:AddLine(self.L[index])
			if index == 2 then
				GameTooltip:AddLine(L.NoteSelfTooltip)
			elseif index ~= #self.L and index > 2 then
				local i = index - 2
				if VMRT.Note.BlackLastUpdateName[i] then
					GameTooltip:AddLine(L.NoteLastUpdate..": "..VMRT.Note.BlackLastUpdateName[i].." ("..date("%d.%m.%Y %H:%M",VMRT.Note.BlackLastUpdateTime[i] or 0)..")")
				end

			end
			GameTooltip:Show()
		end
	end

	function self.NotesList:OnDragFunction(obj1,obj2)
		local index1,index2 = obj1.index,obj2.index

		if index2 < 3 or index2 >= #self.L then
			return
		end
		index1,index2 = index1 - 2,index2 - 2

		local tmpBlack = VMRT.Note.Black[index1]
		local tmpBlackNames = VMRT.Note.BlackNames[index1]
		local tmpAutoLoad = VMRT.Note.AutoLoad[index1]
		local tmpBlackLastUpdateName = VMRT.Note.BlackLastUpdateName[index1]
		local tmpBlackLastUpdateTime = VMRT.Note.BlackLastUpdateTime[index1]
		if index1 < index2 then
			for i=index1,index2-1 do
				VMRT.Note.Black[i] = VMRT.Note.Black[i + 1]
				VMRT.Note.BlackNames[i] = VMRT.Note.BlackNames[i + 1]
				VMRT.Note.AutoLoad[i] = VMRT.Note.AutoLoad[i + 1]
				VMRT.Note.BlackLastUpdateName[i] = VMRT.Note.BlackLastUpdateName[i + 1]
				VMRT.Note.BlackLastUpdateTime[i] = VMRT.Note.BlackLastUpdateTime[i + 1]
			end
		else
			for i=index1,index2+1,-1 do
				VMRT.Note.Black[i] = VMRT.Note.Black[i - 1]
				VMRT.Note.BlackNames[i] = VMRT.Note.BlackNames[i - 1]
				VMRT.Note.AutoLoad[i] = VMRT.Note.AutoLoad[i - 1]
				VMRT.Note.BlackLastUpdateName[i] = VMRT.Note.BlackLastUpdateName[i - 1]
				VMRT.Note.BlackLastUpdateTime[i] = VMRT.Note.BlackLastUpdateTime[i - 1]
			end
		end
		VMRT.Note.Black[index2] = tmpBlack
		VMRT.Note.BlackNames[index2] = tmpBlackNames
		VMRT.Note.AutoLoad[index2] = tmpAutoLoad
		VMRT.Note.BlackLastUpdateName[index2] = tmpBlackLastUpdateName
		VMRT.Note.BlackLastUpdateTime[index2] = tmpBlackLastUpdateTime

		NotesListUpdateNames()
	end

	self.DuplicateDraft = ELib:Button(self.tab.tabs[1],L.NoteDuplicate):Size(120,19):Point("RIGHT",0,0):Point("TOP",self.NotesList,0,1):OnClick(function (self)
		local pos = #VMRT.Note.Black + 1

		local text = module.options.LastIndex == 1 and (VMRT.Note.Text1 or "") or
				module.options.LastIndex == 2 and (VMRT.Note.SelfText or "") or
				(VMRT.Note.Black[module.options.LastIndex - 2] or "")
		local title = (module.options.LastIndex > 2 and VMRT.Note.BlackNames[module.options.LastIndex - 2]) or
				(module.options.LastIndex == 1 and VMRT.Note.DefName)
		if not title then title = nil end

		local boss = module.options.LastIndex == 1 and VMRT.Note.AutoLoad[0] or
				module.options.LastIndex > 2 and VMRT.Note.AutoLoad[module.options.LastIndex - 2]
		if not boss then boss = nil end

		local lastUpdateName = module.options.LastIndex > 2 and VMRT.Note.BlackLastUpdateName[module.options.LastIndex - 2]
		if not lastUpdateName then lastUpdateName = nil end

		local lastUpdateTime = module.options.LastIndex > 2 and VMRT.Note.BlackLastUpdateTime[module.options.LastIndex - 2]
		if not lastUpdateTime then lastUpdateTime = nil end

		VMRT.Note.Black[pos] = text
		VMRT.Note.BlackNames[pos] = title
		VMRT.Note.AutoLoad[pos] = boss
		VMRT.Note.BlackLastUpdateName[pos] = lastUpdateName
		VMRT.Note.BlackLastUpdateTime[pos] = lastUpdateTime

		NotesListUpdateNames()
		module.options.NotesList:SetListValue(pos+2)
		module.options.NotesList.selected = pos+2
		module.options.NotesList:Update()
	end)
	self.DuplicateDraft:HideBorders()

	self.RemoveDraft = ELib:Button(self.tab.tabs[1],L.NoteRemove):Size(120,19):Point("RIGHT",self.DuplicateDraft,"LEFT",-5,0):Point("TOP",self.NotesList,0,1):Disable():OnClick(function (self)
		if not BlackNoteNow then
			return
		end
		local size = #VMRT.Note.Black
		for i=BlackNoteNow,size do
			if i < size then
				VMRT.Note.Black[i] = VMRT.Note.Black[i + 1]
				VMRT.Note.BlackNames[i] = VMRT.Note.BlackNames[i + 1]
				VMRT.Note.AutoLoad[i] = VMRT.Note.AutoLoad[i + 1]
				VMRT.Note.BlackLastUpdateName[i] = VMRT.Note.BlackLastUpdateName[i + 1]
				VMRT.Note.BlackLastUpdateTime[i] = VMRT.Note.BlackLastUpdateTime[i + 1]
			else
				VMRT.Note.Black[i] = nil
				VMRT.Note.BlackNames[i] = nil
				VMRT.Note.AutoLoad[i] = nil
				VMRT.Note.BlackLastUpdateName[i] = nil
				VMRT.Note.BlackLastUpdateTime[i] = nil
			end
		end
		NotesListUpdateNames()
		if BlackNoteNow == (#module.options.NotesList.L - 2) then
			BlackNoteNow = BlackNoteNow - 1
		end
		module.options.NotesList:SetListValue(2+BlackNoteNow)
		module.options.NotesList.selected = 2+(BlackNoteNow or 0)
		module.options.NotesList:Update()
	end)
	self.RemoveDraft:HideBorders()

	self.DraftName = ELib:Edit(self.tab.tabs[1]):Size(0,18):Tooltip(L.NoteDraftName):Text(VMRT.Note.DefName or L.messageTab1):Point("TOPLEFT",self.NotesList,"TOPRIGHT",8,0):Point("RIGHT",self.RemoveDraft,"LEFT",-5,0):BackgroundText(L.NoteDraftName):OnChange(function(self,isUser)
		self:BackgroundTextCheck()
		if not isUser then return end
		if BlackNoteNow then
			VMRT.Note.BlackNames[ BlackNoteNow ] = self:GetText()
			NotesListUpdateNames()
		elseif not BlackNoteNow and not NoteIsSelfNow then
			VMRT.Note.DefName = self:GetText()

			module:ModHistory(-1, {name = VMRT.Note.DefName})
		end
	end)
	self.DraftName:SetBackdropColor(0, 0, 0, 0)
	self.DraftName:SetBackdropBorderColor(0, 0, 0, 0)
	self.DraftName:HideBorders()

	ELib:DecorationLine(self.tab.tabs[1]):Point("TOP",0,-129-20):Point("LEFT",self.NotesList,"RIGHT",0,0):Point("RIGHT",'x',0,0):Size(0,1)

	local function autoLoadDropdown_SetValue(self,encounterID)
		local index = BlackNoteNow or 0

		VMRT.Note.AutoLoad[index] = encounterID

		module.options.autoLoadDropdown:UpdateText(encounterID)
		NotesListUpdateNames()
		ELib:DropDownClose()

		if index == 0 then
			module:ModHistory(-1, {bossID = VMRT.Note.AutoLoad[0]})
		end
	end

	local _encLabel = ENCOUNTER_JOURNAL_ENCOUNTER or "Encounter"
	self.autoLoadDropdown = ELib:DropDown(self.tab.tabs[1],550,25):AddText(_encLabel..":"):Point("TOPRIGHT",self.DuplicateDraft,"BOTTOMRIGHT",-2,-1):Size(550)
	function self.autoLoadDropdown:UpdateText(encounterID)
		self:SetText(encounterID and (module.options:GetBossIcon(encounterID)..module.options:GetBossName(encounterID)) or "-")
	end
	self.autoLoadDropdown:UpdateText(VMRT.Note.AutoLoad[0])
	do
		local List = self.autoLoadDropdown.List
		List[#List+1] = {
			text = NO,
			func = autoLoadDropdown_SetValue,
		}
		for i=1,#module.db.encountersList do
			local instance = module.db.encountersList[i]
			List[#List+1] = {
				text = type(instance[1])=='string' and instance[1] or (C_Map and C_Map.GetMapInfo and (C_Map.GetMapInfo(instance[1] or 0) or {}).name) or ("Instance "..tostring(instance[1] or "???")) or "???",
				isTitle = true,
			}
			for j=2,#instance do
				local bossID, bossImg = instance[j]
				if type(bossID) == 'string' then
					List[#List+1] = {
							text = bossID,
						arg1 = bossID,
						func = autoLoadDropdown_SetValue,
							icon = module.options:GetBossIconPath(bossID),
							iconsize = 32,
					}
				else
					local localPath = module.options:GetBossIconPath(bossID)
					if not localPath and bossID and MRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
						local ejImg = select(5, EJ_GetCreatureInfo(1, MRT.GDB.encounterIDtoEJ[bossID]))
						if type(ejImg) == "string" and ejImg ~= "" then
							bossImg = ejImg
						end
					end
					List[#List+1] = {
						text = module.options:GetBossName(bossID),
						arg1 = bossID,
						func = autoLoadDropdown_SetValue,
						icon = localPath or bossImg,
						iconsize = 16,
					}
				end
			end
		end
	end
	if not IS_WOTLK_335 then
		self.autoLoadDropdown:HideBorders()
		self.autoLoadDropdown.Background:Hide()
		self.autoLoadDropdown.Background:SetPoint("BOTTOMRIGHT",0,1)
		self.autoLoadDropdown.Background:EnableMouse(false)
		MRT_SetSolidColor(self.autoLoadDropdown.Background,1,1,1,.3)
	else
		if self.autoLoadDropdown.Button then
			self.autoLoadDropdown.Button:Show()
			self.autoLoadDropdown.Button:SetAlpha(1)
		end
	end
	self.autoLoadDropdown.Text:SetJustifyH("LEFT")
	self.autoLoadDropdown:SetScript("OnMouseDown",function(self) if self.Button and self.Button.Click then self.Button:Click() end end)
	self.autoLoadDropdown:SetScript("OnEnter",function(self)
		if self.Background and self.Background.Show then
			self.Background:Show()
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:AddLine(L.NoteEnableBossAutoLoad)
		if VMRT.Note.EnableBossAutoLoad then
			GameTooltip:AddLine(VIDEO_OPTIONS_ENABLED or "Enabled",0,1,0)
		else
			GameTooltip:AddLine(VIDEO_OPTIONS_DISABLED or "Disabled",1,0,0)
		end
		GameTooltip:Show()
	end)
	self.autoLoadDropdown:SetScript("OnLeave",function(self)
		if self.Background and self.Background.Hide then
			self.Background:Hide()
		end

		GameTooltip_Hide()
	end)

	ELib:DecorationLine(self.tab.tabs[1]):Point("TOP",0,-129-40):Point("LEFT",self.NotesList,"RIGHT",0,0):Point("RIGHT",'x',0,0):Size(0,1)

	local IsFormattingOn = VMRT.Note.OptionsFormatting
	local IconsFormattingList = {}
	self.optFormatting = ELib:Check(self.tab.tabs[1],FORMATTING,VMRT.Note.OptionsFormatting):Point("TOPLEFT",self.NotesList,"TOPRIGHT",15,-41):Size(15,15):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.OptionsFormatting = true
		else
			VMRT.Note.OptionsFormatting = nil
		end
		IsFormattingOn = VMRT.Note.OptionsFormatting
		module.options.NotesList:SetListValue(module.options.LastIndex or 1)
	end)

	ELib:DecorationLine(self.tab.tabs[1]):Point("TOP",0,-129-60):Point("LEFT",self.NotesList,"RIGHT",0,0):Point("RIGHT",'x',0,0):Size(0,1)

	self.NoteEditBox = ELib:MultiEdit(self.tab.tabs[1]):Point("TOPLEFT",self.NotesList,"TOPRIGHT",2,-61):Size(616,395)
	ELib:Border(self.NoteEditBox,0)

	if self.NoteEditBox and self.NoteEditBox.EditBox then
		local eb = self.NoteEditBox.EditBox
		if eb.SetBackdropColor then
			pcall(eb.SetBackdropColor, eb, 0, 0, 0, 0.35)
		end
		if eb.SetBackdropBorderColor then
			pcall(eb.SetBackdropBorderColor, eb, 0.3, 0.3, 0.3, 1)
		end
		if eb.SetTextColor then
			pcall(eb.SetTextColor, eb, 1, 1, 1, 1)
		end
		if eb.SetShadowOffset then
			pcall(eb.SetShadowOffset, eb, 1, -1)
		end
		if eb.SetShadowColor then
			pcall(eb.SetShadowColor, eb, 0, 0, 0, 1)
		end
		local fs = eb.GetFontString and eb:GetFontString()
		if fs then
			pcall(fs.SetTextColor, fs, 1,1,1,1)
			pcall(fs.SetShadowOffset, fs, 1,-1)
			pcall(fs.SetShadowColor, fs, 0,0,0,1)
			pcall(fs.SetAlpha, fs, 1)
			if fs.SetFontObject then pcall(fs.SetFontObject, fs, ChatFontNormal) end
		end
		pcall(eb.SetAlpha, eb, 1)
		if eb.SetFontObject then pcall(eb.SetFontObject, eb, ChatFontNormal) end

	end


	local function GSUB_Icon_Options(unformatted,spellID,iconSize)
		local iconText
		spellID = tonumber(spellID)

		if not iconSize or iconSize == "" then
			iconSize = 0
		else
			iconSize = min(tonumber(iconSize),40)
		end

		local preicon = predefSpellIcons[spellID]
		if preicon then
			iconText = "|T"..preicon..":"..iconSize.."|t"
		else
			local spellTexture = GetSpellTexture(spellID)
			if not spellTexture and MRT and MRT.F and MRT.F.GetSpellTextureSafe then
				spellTexture = MRT.F.GetSpellTextureSafe(spellID)
			end
			iconText = "|T"..(spellTexture or "Interface\\Icons\\INV_MISC_QUESTIONMARK")..":"..iconSize..":"..iconSize..":-6:0|t"
		end

		IconsFormattingList[iconText] = unformatted

		return iconText
	end

	self.NoteEditBox.EditBox._SetText = self.NoteEditBox.EditBox.SetText
	function self.NoteEditBox.EditBox:SetText(text)
		if IsFormattingOn then

			text = text:gsub("||([cr])","|%1")

		end
		return self:_SetText(text)
	end

	function self.NoteEditBox.EditBox:OnTextChanged(isUser)
		if not isUser and (not module.options.InsertFix or GetTime() - module.options.InsertFix > 0.1) then
			return
		end
		local text = self:GetText()
		if IsFormattingOn then
			text = text:gsub("|([cr])","||%1")

		end
		if NoteIsSelfNow then
			VMRT.Note.SelfText = text
			module.allframes:UpdateText()
		elseif BlackNoteNow then
			VMRT.Note.Black[ BlackNoteNow ] = text

			VMRT.Note.BlackLastUpdateName[BlackNoteNow] = MRT.SDB.charKey
			VMRT.Note.BlackLastUpdateTime[BlackNoteNow] = time()
		else
			module:SaveText(text,-1)
			if module.frame.text:GetText() ~= txtWithIcons(module.frame, VMRT.Note.Text1) then
				module.options.buttonsend:Anim(true)
			else
				module.options.buttonsend:Anim(false)
			end
			module.allframes:UpdateText()
		end
	end
	local last_highlight_start,last_highlight_end,last_cursor_pos = 0,0,0
	local IsFormattingOn_Saved
	self.NoteEditBox.EditBox:SetScript("OnKeyDown",function(self,key)
		if IsFormattingOn and key == "LCTRL" then
			module.options.InsertFix = nil
			IsFormattingOn_Saved = true
			IsFormattingOn = nil
			local h_start,h_end = module.options.NoteEditBox:GetTextHighlight()
			local h_cursor = self:GetCursorPosition()
			local text = module.options.NoteEditBox.EditBox:GetText()

			last_highlight_start,last_highlight_end,last_cursor_pos = h_start,h_end,h_cursor

			local c_start,c_end,c_cursor = 0,0,0
			text:sub(1,h_start):gsub("|([cr])",function() c_start = c_start + 1 end)
			text:sub(1,h_end):gsub("|([cr])",function() c_end = c_end + 1 end)
			text:sub(1,h_cursor):gsub("|([cr])",function() c_cursor = c_cursor + 1 end)

			text = text:gsub("|([cr])","||%1")
			module.options.NoteEditBox.EditBox:_SetText(text)

			module.options.NoteEditBox.EditBox:HighlightText( h_start+c_start, h_end+c_end )
			module.options.NoteEditBox.EditBox:SetCursorPosition( h_cursor+c_cursor )
		end
	end)
	self.NoteEditBox.EditBox:SetScript("OnKeyUp",function(self,key)
		if IsFormattingOn_Saved and key == "LCTRL" then
			MRT.F:AddCoroutine(function()
				coroutine.yield("await")
				local text = module.options.NoteEditBox.EditBox:GetText()
				local h_start,h_end = module.options.NoteEditBox:GetTextHighlight()
				local h_cursor = self:GetCursorPosition()
				local c_start,c_end,c_cursor = 0,0,0
				text:sub(1,h_start):gsub("||([cr])",function() c_start = c_start + 1 end)
				text:sub(1,h_end):gsub("||([cr])",function() c_end = c_end + 1 end)
				text:sub(1,h_cursor):gsub("||([cr])",function() c_cursor = c_cursor + 1 end)

				IsFormattingOn = true
				IsFormattingOn_Saved = nil
				module.options.InsertFix = nil
				module.options.NotesList:SetListValue(module.options.LastIndex or 1)
				module.options.NoteEditBox.EditBox:HighlightText( h_start-c_start,h_end-c_end )
				module.options.NoteEditBox.EditBox:SetCursorPosition( h_cursor-c_cursor )
			end)
		end
	end)

	self.buttonundo = ELib:Button(self.tab.tabs[1],L.NoteUndo):Size(80,30):Point("LEFT",self.NotesList,"TOPRIGHT",4,0):Point("BOTTOM",self,"BOTTOM",0,2):Tooltip(L.NoteUndoTip):OnClick(function (self)
		local menu = {}
		for i=1,#module.db.History do
			menu[#menu+1] = {text = date("%X",module.db.History[i].time), func = function()
				ELib.ScrollDropDown.Close()
				module.db.HistoryLock = true
				local history = module.db.History[i]
				module:SaveText(history.text, -2)
				module.frame:SetTo()
				if VMRT.Note.AutoLoad[0] ~= history.bossID then
					VMRT.Note.AutoLoad[0] = history.bossID
				end
				module.options.autoLoadDropdown:UpdateText(VMRT.Note.AutoLoad[0])
				if VMRT.Note.DefName ~= history.name then
					VMRT.Note.DefName = history.name
				end
				module.options.DraftName:SetText( VMRT.Note.DefName or "" )
				module.db.HistoryLock = nil
			end, tooltip = (module.db.History[i].text or ""):sub(1,800)..(#(module.db.History[i].text or "") > 800 and "..." or "")}
		end
		menu[#menu+1] = { text = CLOSE, func = function() ELib.ScrollDropDown.Close() end, notCheckable = true }

		ELib.ScrollDropDown.EasyMenu(self,menu,200)
	end)
	self.buttonsend = ELib:Button(self.tab.tabs[1],L.messagebutsend):Size(0,30):Point("LEFT",self.buttonundo,"RIGHT",2,0):Point("BOTTOM",self,"BOTTOM",0,2):Point("RIGHT",self,"RIGHT",-2,0):Tooltip(L.messagebutsendtooltip):OnClick(function (self)
		module.frame:Save()

		if IsShiftKeyDown() then
			local text = VMRT.Note.Text1 or ""
			text = text:gsub("||c........","")
			text = text:gsub("||r","")
			text = text:gsub("||T.-:0||t ","")
			for i=1,8 do
				text = text:gsub(module.db.iconsLocalizatedNames[i],"{rt"..i.."}")
				for _,lang in pairs(iconsLangs) do
					text = text:gsub(module.db["icons"..lang.."Names"][i],"{rt"..i.."}")
				end
			end
			text = text:gsub("%b{}",function(p)
				if p and p:match("^{rt%d}$") then
					return p
				else
					return ""
				end
			end)
			if MRT.isBC and MRT.locale == "ruRU" then
				text = text:gsub("%b{}",function(p)
					if p and p:match("^{rt%d}$") then
						return module.db.iconsLocalizatedNames[tonumber(p:match("%d+") or "") or 0]
					end
				end)
			end

			local lines = {strsplit("\n", text)}
			for i=1,#lines do
				if lines[i] ~= "" then
					SendChatMessage(lines[i],(IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY")
				end
			end
		end

		module.options.buttonsend:Anim(false)
	end)

	function self.buttonsend:Anim(on)
		if on then
			self.t = self.t or 0
			self:SetScript("OnUpdate",function(self,elapsed)
				self.t = (self.t + elapsed) % 4

				local c = 0.05 * (self.t > 2 and (4-self.t) or self.t)

				self.Texture:SetGradient("VERTICAL",CreateColor(0.0+c,0.06+c,0.0+c,1), CreateColor(0.05+c,0.21+c,0.05+c,1))
			end)
		else
			self:SetScript("OnUpdate",nil)
			self.Texture:SetGradient("VERTICAL",CreateColor(0.05,0.06,0.09,1), CreateColor(0.20,0.21,0.25,1))
		end
	end

	self.buttoncopyPersonal = ELib:Button(self.tab.tabs[1],L.NoteMoveToPersonal):Size(180,30):Point("BOTTOM",self,"BOTTOM",0,2):Point("RIGHT",self,"RIGHT",-2,0):OnClick(function (self)
		if not BlackNoteNow then
			return
		end
		VMRT.Note.SelfText = VMRT.Note.Black[BlackNoteNow]

		module.options.NotesList:SetListValue(2)

		module.options.NotesList.selected = 2
		module.options.NotesList:Update()

		module.allframes:UpdateText()
	end)
	self.buttoncopyPersonal:Hide()

	self.buttonwindow = ELib:Button(self.tab.tabs[1],L.NoteShowInNewWindow):Size(180,30):Point("LEFT",self.NotesList,"TOPRIGHT",4,0):Point("BOTTOM",self,"BOTTOM",0,2):Tooltip(L.NoteShowInNewWindowTooltip):OnClick(function (self)
		if not BlackNoteNow then
			return
		end
		if IsControlKeyDown() then
			local window = module:IsWindowOpenedForDraft(BlackNoteNow)
			if window then
				window:ClearAllPoints()
				window:SetPoint("CENTER")

				window:SetSize(200,100)
				return
			end
		elseif IsShiftKeyDown() then
			local window = module:IsWindowOpenedForDraft(BlackNoteNow)
			if window then
				window:Disable()
				return
			end
		end
		module:AddWindow(BlackNoteNow)
	end)
	self.buttonwindow:Hide()

	self.buttoncopy = ELib:Button(self.tab.tabs[1],L.messageButCopy):Size(0,30):Point("LEFT",self.buttonwindow,"RIGHT",5,0):Point("BOTTOM",self,"BOTTOM",0,2):Point("RIGHT",self.buttoncopyPersonal,"LEFT",-5,0):OnClick(function (self)
		if not BlackNoteNow then
			return
		end
		module.frame:Save(BlackNoteNow)

		module.options.NotesList:SetListValue(1)

		module.options.NotesList.selected = 1
		module.options.NotesList:Update()
	end)
	self.buttoncopy:Hide()

	local function AddTextToEditBox(self,text,mypos,noremove)
		local addedText = nil
		if not self then
			addedText = text
		else
			addedText = self.iconText
			if IsShiftKeyDown() then
				addedText = self.iconTextShift
			end
		end
		if not noremove then
			module.options.NoteEditBox.EditBox:Insert("")
		end
		local txt = module.options.NoteEditBox.EditBox:GetText()
		local pos = module.options.NoteEditBox.EditBox:GetCursorPosition()
		if not self and type(mypos)=='number' then
			pos = mypos
		end
		txt = string.sub (txt, 1 , pos) .. addedText .. string.sub (txt, pos+1)
		module.options.InsertFix = GetTime()
		module.options.NoteEditBox.EditBox:SetText(txt)
		local adjust = 0
		if IsFormattingOn then
			addedText:gsub("||",function() adjust = adjust + 1 end)
		end
		module.options.NoteEditBox.EditBox:SetCursorPosition(pos+addedText:len()-adjust)
	end

	self.buttonicons = {}
	for i=1,8 do
		local button = CreateFrame("Button", nil,self.tab.tabs[1])
		self.buttonicons[i] = button
		button:SetSize(18,18)
		button:SetPoint("TOPLEFT", 10+(i-1)*20,-30)
		button.back = button:CreateTexture(nil, "BACKGROUND")
		button.back:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..i)
		button.back:ClearAllPoints()
		button.back:SetPoint("TOPLEFT",1,-1)
		button.back:SetPoint("BOTTOMRIGHT",-1,1)
		button:RegisterForClicks("LeftButtonDown")
		button.iconText = module.db.iconsLocalizatedNames[i]
		button:SetScript("OnClick", AddTextToEditBox)
	end
		local function _TexCoordFromCrop(crop)
			if type(crop) ~= 'string' then return end
			local texW, texH, l, r, t, b = crop:match('^:.-:.-:.-:.-:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)$')
			texW, texH, l, r, t, b = tonumber(texW), tonumber(texH), tonumber(l), tonumber(r), tonumber(t), tonumber(b)
			if not texW or not texH or not l or not r or not t or not b or texW == 0 or texH == 0 then return end
			return l/texW, r/texW, t/texH, b/texH
		end
		for i=1,#module.db.otherIconsList do
		local button = CreateFrame("Button", nil,self.tab.tabs[1])
		local idx = 8 + i
		self.buttonicons[idx] = button
		button:SetSize(18,18)
		button:SetPoint("TOPLEFT", 170+(i-1)*20,-30)
		button.back = button:CreateTexture(nil, "ARTWORK")
		local iconData = module.db.otherIconsList[i]
			button.back:SetTexture(iconData[2])
			if type(iconData[3]) == 'number' then
				button.back:SetTexCoord(unpack(iconData,3,6))
			else
				button.back:SetTexCoord(0,1,0,1)
			end
		button.back:ClearAllPoints()
		button.back:SetPoint("TOPLEFT",1,-1)
		button.back:SetPoint("BOTTOMRIGHT",-1,1)
		button:RegisterForClicks("LeftButtonDown")
		button.iconText = iconData[1]
		button:SetScript("OnClick", AddTextToEditBox)
	end

	self.OtherIconsButton = ELib:Button(self.tab.tabs[1],L.NoteOtherIcons):Size(120,20):Point("TOPLEFT",self.buttonicons[#self.buttonicons],"TOPRIGHT",5,1):OnClick(function()
		module.options.OtherIconsFrame:ShowClick("TOPRIGHT")
	end)

	self.OtherIconsFrame = ELib:Popup(L.NoteOtherIcons):Size(300,300)
	if ExRT and ExRT.F and ExRT.F.AddonScaleApply then
		ExRT.F.AddonScaleApply(self.OtherIconsFrame)
	end
	self.OtherIconsFrame.ScrollFrame = ELib:ScrollFrame(self.OtherIconsFrame):Size(self.OtherIconsFrame:GetWidth()-10,self.OtherIconsFrame:GetHeight()-25):Point("TOP",0,-20):Height(500):HideScrollOnNoScroll()
	self.OtherIconsFrame.ScrollFrame.C:SetWidth(self.OtherIconsFrame:GetWidth()-30)

	local function CreateOtherIcon(parent,pointX,pointY,texture,iconText)
		local btn = CreateFrame("Button", nil, parent)
		btn:SetSize(18,18)
		btn:SetPoint("TOPLEFT",pointX,pointY)
		btn.back = btn:CreateTexture(nil, "ARTWORK")
		btn.back:SetTexture(texture)
		btn.back:SetPoint("TOPLEFT",1,-1)
		btn.back:SetPoint("BOTTOMRIGHT",-1,1)
		btn:RegisterForClicks("LeftButtonDown")
		btn.iconText = iconText
		btn:SetScript("OnClick", AddTextToEditBox)
		return btn
	end
	self.OtherIconsFrame.CreateOtherIcon = CreateOtherIcon

	local function NormalizeTexturePath(tex)
		if not tex or tex == '' then return nil end
		if type(tex) ~= 'string' then return nil end
		if not tex:find('\\') then
			tex = 'Interface\\Icons\\'..tex
		end
		if tex:find('FriendsFrame\\Battlenet') or tex:find('Battlenet%-') or tex:find('Overwatch') or tex:find('HotS') then
			return nil
		end
		return tex
	end

	self.OtherIconsFrame._iconButtons = {}
	do
		local parent = self.OtherIconsFrame.ScrollFrame.C
		local list = module.db.otherIconsAdditionalList or {}
		local line, inLine = 1, 0
		local function AddBtn(tex, txt)
			if not tex or tex == '' then return end
			local b = CreateOtherIcon(parent,5+inLine*20,-2-(line-1)*20,tex,txt)
			self.OtherIconsFrame._iconButtons[#self.OtherIconsFrame._iconButtons+1] = b
			inLine = inLine + 1
			if inLine > 12 then
				line = line + 1
				inLine = 0
			end
		end
		for i=1,#list do
			local v = list[i]
			if v == 0 then
				if inLine > 0 then
					line = line + 1
					inLine = 0
				end
			else
				local tex
				if type(v) == 'number' then
					tex = (GetSpellTexture and GetSpellTexture(v))
						or select(3, GetSpellInfo(v))
					if not tex and MRT.F.GetSpellTextureSafe then
						tex = MRT.F.GetSpellTextureSafe(v)
					end
					tex = NormalizeTexturePath(tex)
					if tex and not tex:lower():find("inv_misc_questionmark") then
						AddBtn(tex, '{spell:'..v..'}')
					end
				else
					tex = NormalizeTexturePath(v)
					if tex then
						AddBtn(tex, '{icon:'..tex..'}')
					end
				end
			end
		end
		if inLine > 0 then line = line + 1 end
		self.OtherIconsFrame.ScrollFrame:SetNewHeight( max(self.OtherIconsFrame:GetHeight()-40 , line * 20 + 4) )
	end


	self:SetScript("OnHide",function (self)
		self.OtherIconsFrame:Hide()
	end)

	self.dropDownColor = ELib:DropDown(self.tab.tabs[1],170,10):Point(558,-30):Size(100):SetText(L.NoteColor)
	self.dropDownColor.list = {
		{L.NoteColorRed,"|cffff0000"},
		{L.NoteColorGreen,"|cff00ff00"},
		{L.NoteColorBlue,"|cff0000ff"},
		{L.NoteColorYellow,"|cffffff00"},
		{L.NoteColorPurple,"|cffff00ff"},
		{L.NoteColorAzure,"|cff00ffff"},
		{L.NoteColorBlack,"|cff000000"},
		{L.NoteColorGrey,"|cff808080"},
		{L.NoteColorRedSoft,"|cffee5555"},
		{L.NoteColorGreenSoft,"|cff55ee55"},
		{L.NoteColorBlueSoft,"|cff5555ee"},
	}
	local classNames = MRT.GDB.ClassList
	for i,class in ipairs(classNames) do
		local colorTable = RAID_CLASS_COLORS[class]
		if colorTable and type(colorTable)=="table" then
			self.dropDownColor.list[#self.dropDownColor.list + 1] = {L.classLocalizate[class] or class,"|c"..(colorTable.colorStr or "ffaaaaaa")}
		end
	end
	self.dropDownColor:SetScript("OnEnter",function (self)
		ELib.Tooltip.Show(self,"ANCHOR_LEFT",L.NoteColor,{L.NoteColorTooltip1,1,1,1,true},{L.NoteColorTooltip2,1,1,1,true})
	end)
	self.dropDownColor:SetScript("OnLeave",function ()
		ELib.Tooltip:Hide()
	end)
	function self.dropDownColor:SetValue(colorCode)
		ELib:DropDownClose()

		local selectedStart,selectedEnd = module.options.NoteEditBox.EditBox:GetTextHighlight()
		colorCode = string.gsub(colorCode,"|","||")
		if selectedStart == selectedEnd then
			AddTextToEditBox(nil,colorCode.."||r",nil,true)
		else
			AddTextToEditBox(nil,"||r",selectedEnd,true)
			AddTextToEditBox(nil,colorCode,selectedStart,true)
		end
	end
	for i=1,#self.dropDownColor.list do
		local colorData = self.dropDownColor.list[i]
		self.dropDownColor.List[i] = {
			text = colorData[2]..colorData[1],
			func = self.dropDownColor.SetValue,
			justifyH = "CENTER",
			arg1 = colorData[2],
		}
	end
	self.dropDownColor.Lines = #self.dropDownColor.List


	self.rosterpickdd = ELib:DropDown(self.tab.tabs[1],170,-1):Point("LEFT",self.dropDownColor,"RIGHT",5,0):Size(150):SetText("Select roster")
	function self.rosterpickdd:SetValue(arg1)
		ELib:DropDownClose()
		module.options.rosterType = arg1
		module.options:UpdateRoster()
		module.options.rosterpickdd:AutoText(arg1)
	end
	function self.rosterpickdd:SetValue2(arg1)
		ELib:DropDownClose()
		module.options.rosteredit:Show()
	end
	self.rosterpickdd.List = {
		{
			text = "Current roster",
			arg1 = nil,
			func = self.rosterpickdd.SetValue,
		},
		{
			text = "Custom roster",
			arg1 = 2,
			func = self.rosterpickdd.SetValue,
			subMenu = {
				{
					text = "Edit",
					func = self.rosterpickdd.SetValue2,
				}
			},
		}
	}

	local rolesList = {
		{"TANK",TANK or "Tank","roleicon-tiny-tank"},
		{"HEALER",HEALER or "Healer","roleicon-tiny-healer"},
		{"DAMAGER",DAMAGER or "Damager","roleicon-tiny-dps"},
	}
	local roleToIcon = {
		TANK = "|A:roleicon-tiny-tank:0:0|a",
		HEALER = "|A:roleicon-tiny-healer:0:0|a",

	}
	if MRT.isClassic then wipe(roleToIcon) end

	module.options.rosteredit = ELib:Popup("Edit custom roster"):Size(600,600):OnShow(function(self) self:Update() end,true)
	ELib:Border(module.options.rosteredit,1,.4,.4,.4,.9)

	module.options.rosteredit.frame = ELib:ScrollFrame(module.options.rosteredit):Size(600,585):Height(585):AddHorizontal(true):Width(600):Point("TOP",0,-15)
	ELib:Border(module.options.rosteredit.frame,0)
	module.options.rosteredit.frame.lines = {}

	module.options.rosteredit.groupsedit = {}

	module.options.rosteredit:SetScript("OnHide",function()
		module.options:UpdateRoster()
	end)

	module.options.rosteredit.frame:SetScript("OnMouseDown",function(self)
		local x,y = MRT.F.GetCursorPos(self)
		self.saved_x = x
		self.saved_y = y
		self.saved_scroll_h = self.ScrollBarHorizontal:GetValue()
		self.saved_scroll_v = self.ScrollBar:GetValue()
		self.moveSpotted = nil

	end)

	module.options.rosteredit.frame:SetScript("OnMouseUp",function(self, button)
		self.saved_x = nil
		self.saved_y = nil
		self.moveSpotted = nil
	end)

	module.options.rosteredit.ExportButton = ELib:Button(module.options.rosteredit.frame.C,L.Export):Point("TOPLEFT",600-250,-0):Size(200,20):OnClick(function()
		local str = ""
		for i=1,#VMRT.Note.CustomRoster do
			if VMRT.Note.CustomRoster[i][1] then
				str = str .. VMRT.Note.CustomRoster[i][1]  .."\t".. (VMRT.Note.CustomRoster[i][2] or "").."\t" ..(VMRT.Note.CustomRoster[i][3] or "").. "\n"
			end
		end
		MRT.F:Export2(str)
	end)

	module.options.rosteredit.importWindow = ELib:Popup(" "):Size(600,400)
	ELib:Border(module.options.rosteredit.importWindow,1,.4,.4,.4,.9)

	function module.options.rosteredit.importWindow:DoImport(isErase)
		local text = module.options.rosteredit.importWindow.Edit:GetText()
	  	if isErase then
			wipe(VMRT.Note.CustomRoster)
		end

		local lines = {strsplit("\n",text)}
		for i=1,#lines do
			local l = {}
			for k in lines[i]:gmatch("[^\n\t ]+") do
				l[#l+1] = k
			end
			local name,class,role = unpack(l)

			if name and name:trim() == ""  then name = nil end

			if name then
				if class and class:trim() == ""  then class = nil end
				if role and role:trim() == ""  then role = nil end

				if class then
					local mclass
					for i=1,#MRT.GDB.ClassList do
						if MRT.GDB.ClassList[i]:lower() == class:lower() or (GetClassInfo(MRT.GDB.ClassID[ MRT.GDB.ClassList[i] ]) or "") == class:lower() then
							mclass = MRT.GDB.ClassList[i]
							break
						end
					end
					class = mclass
				end

				if role then
					local mrole
					for i=1,#rolesList do
						if rolesList[i][1]:lower() == role:lower() or rolesList[i][2]:lower() == role:lower() then
							mrole = rolesList[i][1]
							break
						end
					end
					role = mrole
				end

				VMRT.Note.CustomRoster[#VMRT.Note.CustomRoster+1] = {
					name,
					class,
					role,
				}
			end
		end
		module.options.rosteredit.importWindow:Hide()
		module.options.rosteredit:Update()
	end

	module.options.rosteredit.importWindow.Tip = ELib:Text(module.options.rosteredit.importWindow,"1 line - 1 player, format: |cff00ff00name   class   role|r",12):Point("TOPLEFT",10,-5)
	module.options.rosteredit.importWindow.Edit = ELib:MultiEdit(module.options.rosteredit.importWindow):Point("TOP",0,-25):Size(590,400-50-30)
	module.options.rosteredit.importWindow.Import = ELib:Button(module.options.rosteredit.importWindow,"Add"):Point("BOTTOM",0,5):Size(590,20):OnClick(function()
		module.options.rosteredit.importWindow:DoImport(false)
	end)
	module.options.rosteredit.importWindow.Import2 = ELib:Button(module.options.rosteredit.importWindow,"Add (rewrite current roster)"):Point("BOTTOM",module.options.rosteredit.importWindow.Import,"TOP",0,5):Size(590,20):OnClick(function()
		module.options.rosteredit.importWindow:DoImport(true)
	end)

	module.options.rosteredit.ImportButton = ELib:Button(module.options.rosteredit.frame.C,L.Import):Point("TOP",module.options.rosteredit.ExportButton,"BOTTOM",0,-5):Size(200,20):OnClick(function()
		module.options.rosteredit.importWindow:NewPoint("CENTER",UIParent,0,0)
		module.options.rosteredit.importWindow.Edit:SetText("")
		module.options.rosteredit.importWindow:Show()
	end)

	module.options.rosteredit.CurrRoster = ELib:Button(module.options.rosteredit.frame.C,"Add from current raid/group"):Point("RIGHT",module.options.rosteredit.ExportButton,"LEFT",-5,0):Size(200,20):OnClick(function()
		for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in MRT.F.IterateRoster, MRT.F.GetRaidDiffMaxGroup() do
			name = MRT.F.delUnitNameServer(name)

			if combatRole == "NONE" then combatRole = nil end

			VMRT.Note.CustomRoster[#VMRT.Note.CustomRoster+1] = {
				name,
				class,
				combatRole,
			}
		end
		module.options.rosteredit:Update()
	end)

	module.options.rosteredit.ClearList = ELib:Button(module.options.rosteredit.frame.C,"Clear list"):Point("TOP",module.options.rosteredit.CurrRoster,"BOTTOM",0,-5):Size(200,20):OnClick(function()
		StaticPopupDialogs["EXRT_REMINDER_RESET"] = {
			text = "Clear list?",
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				wipe(VMRT.Note.CustomRoster)
				module.options.rosteredit:Update()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_RESET")
	end)

	module.options.rosteredit.addButton = ELib:Button(module.options.rosteredit.frame.C,"Add"):Size(100,20):OnClick(function(self)
		local pos = #VMRT.Note.CustomRoster+1
		VMRT.Note.CustomRoster[pos] = {self.gtext}

		self:Hide()
		module.options.rosteredit:Update()
	end)

	function module.options.rosteredit:removeButton_click()
		local i = self:GetParent().data_i
		tremove(VMRT.Note.CustomRoster, i)

		module.options.rosteredit:Update()
	end

	function module.options.rosteredit:class_click(class)
		ELib:DropDownClose()

		local data = self:GetParent().parent:GetParent().data
		data[2] = class

		module.options.rosteredit:Update()
	end
	module.options.rosteredit.ClassDD_List = {
		{
			text = "-",
			func = module.options.rosteredit.class_click,
		},
	}
	for i=1,#MRT.GDB.ClassList do
		local class = MRT.GDB.ClassList[i]
		module.options.rosteredit.ClassDD_List[#module.options.rosteredit.ClassDD_List+1] = {
			text = (RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or "")..L.classLocalizate[class],
			func = module.options.rosteredit.class_click,
			arg1 = class,
		}
	end

	function module.options.rosteredit:role_click(role)
		ELib:DropDownClose()

		local data = self:GetParent().parent:GetParent().data
		data[3] = role

		module.options.rosteredit:Update()
	end
	module.options.rosteredit.RoleDD_List = {
		{
			text = "-",
			func = module.options.rosteredit.role_click,
		},
	}
	for i=1,#rolesList do
		local roledata = rolesList[i]
		module.options.rosteredit.RoleDD_List[#module.options.rosteredit.RoleDD_List+1] = {
			text = roledata[2],
			func = module.options.rosteredit.role_click,
			arg1 = roledata[1],
			atlas = roledata[3],
		}
	end

	function module.options.rosteredit:UpdateView()
		local pos = self.frame:GetVerticalScroll()

		local spellsList = self.pList

		local c = 0
		for i=1,#spellsList do
			local data = spellsList[i]
			if data.pos + 25 >= pos and data.pos <= pos+self.frame:GetHeight() then
				c = c + 1

				local line = self.frame.lines[c]
				if not line then
					line = CreateFrame("Frame",nil,self.frame.C)
					self.frame.lines[c] = line
					line:SetSize(500,24)

					line.edit = ELib:Edit(line):Size(200,20):Point("LEFT",5,0):OnChange(function(self,isUser)
						local text = self:GetText() or ""
						module.options.rosteredit.addButton:NewPoint("LEFT",self,"RIGHT",5,0):SetShown(text:trim() ~= "" and not self:GetParent().data)
						if not isUser then return end
						local data = self:GetParent().data
						if data then
							data[1] = text
						else
							module.options.rosteredit.addButton.gtext = text
						end
					end)

					line.remove = ELib:Button(line,""):Size(12,20):Point("LEFT",line.edit,"RIGHT",3,0):OnClick(self.removeButton_click)
					ELib:Text(line.remove,"x"):Point("CENTER",0,0)
					line.remove.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))
					line.remove._i = i

					line.bg = line:CreateTexture(nil,"BACKGROUND")
					line.bg:SetAllPoints()

					line.class = ELib:DropDown(line,220,-1):Size(150):Point("LEFT",line.edit,"RIGHT",25,0)
					line.class.List = module.options.rosteredit.ClassDD_List

					line.role = ELib:DropDown(line,220,-1):Size(150):Point("LEFT",line.class,"RIGHT",10,0)
					line.role.List = module.options.rosteredit.RoleDD_List
				end

				if data.data then
					line.edit:SetScript("OnEditFocusGained",self.editgname_OnEditFocusGained)
					line.edit:SetScript("OnEditFocusLost",self.editgname_OnEditFocusLost)

					line.remove:Show()
					line.class:Show()
					line.role:Show()
				else
					line.edit:SetScript("OnEditFocusGained",nil)
					line.edit:SetScript("OnEditFocusLost",nil)

					line.remove:Hide()
					line.class:Hide()
					line.role:Hide()
				end

				line.data = data.data
				line:SetPoint("TOPLEFT",10,-data.pos)
				line.edit:SetText(data.data and data.data[1] or "")
				line.class:AutoText(data.data and data.data[2])
				line.role:AutoText(data.data and data.data[3])
				line.data_i = data._i

				local classColor = data.data and data.data[2] and RAID_CLASS_COLORS[ data.data[2] ]
				MRT_SetSolidColor(line.bg,1,1,1,1)
				if classColor then
					line.bg:SetGradient("HORIZONTAL",CreateColor(classColor.r,classColor.g,classColor.b, .5), CreateColor(classColor.r,classColor.g,classColor.b, 0))
				else
					line.bg:SetGradient("HORIZONTAL",CreateColor(1,1,1, 0), CreateColor(1,1,1, 0))
				end

				line:SetWidth(max(200,self:GetWidth()))

				line:Show()
			end
		end
		for i=c+1,#self.frame.lines do
			self.frame.lines[i]:Hide()
		end
	end

	function module.options.rosteredit:editgname_OnEditFocusGained()
		self.prefocustext = self:GetText()
	end
	function module.options.rosteredit:editgname_OnEditFocusLost()
		if self.prefocustext ~= self:GetText() then
			module.options.rosteredit:Update()
		end
	end

	function module.options.rosteredit:Update()
		local names_len = #VMRT.Note.CustomRoster

		self.pList = {}
		for i=1,names_len do
			self.pList[#self.pList + 1] = {
				data = VMRT.Note.CustomRoster[i],
				_i = i,
			}
		end
		self.pList[#self.pList + 1] = {}

		for i=1,#self.pList do
			self.pList[i].pos = 50 + 25 * (i-1)
		end

		local maxheight = 50 + #self.pList * 25 + 15
		local maxwidth = max(200, self:GetWidth())

		self.frame:Height(maxheight)
		self.frame:Width(maxwidth)

		self:UpdateView()
	end

	module.options.rosteredit.frame:SetScript("OnVerticalScroll", function(self)
		self:GetParent():UpdateView()
	end)


	local function RaidNamesOnEnter(self)
		self.html:SetShadowColor(0.2, 0.2, 0.2, 1)
	end
	local function RaidNamesOnLeave(self)
		self.html:SetShadowColor(0, 0, 0, 1)
	end
	self.raidnames = {}
	for i=1,40 do
		local button = CreateFrame("Button", nil,self.tab.tabs[1])
		self.raidnames[i] = button
		button:SetSize(93,14)
		button:SetPoint("TOPLEFT", 15+math.floor((i-1)/5)*95,-55-14*((i-1)%5))

		button.html = ELib:Text(button,"",11):Color()
		button.html:SetAllPoints()
		button.txt = ""
		button:RegisterForClicks("LeftButtonDown")
		button.iconText = ""
		button:SetScript("OnClick", AddTextToEditBox)

		button:SetScript("OnEnter", RaidNamesOnEnter)
		button:SetScript("OnLeave", RaidNamesOnLeave)
	end

	function self:UpdateRoster_MovePage(page,doNotUpdate)
		local pageNow = (self.rosterpage or 1) + page
		if pageNow < 1 then pageNow = 1 end
		local pageMax = ceil(#VMRT.Note.CustomRoster / 40)
		if pageNow > pageMax then pageNow = pageMax end
		self.rosterpage = pageNow
		self.rosterPage:SetText(pageNow.."/"..pageMax)
		if not doNotUpdate then
			self:UpdateRoster()
		end
	end

	self.rosterPage = ELib:Text(self.tab.tabs[1],"1/2",10):Point("TOPLEFT", 15+8*95+20,-60)
	self.rosterPagePrev = ELib:Button(self.tab.tabs[1],"<"):Point("RIGHT", self.rosterPage,"LEFT",-2,0):Size(20,15):OnClick(function() module.options:UpdateRoster_MovePage(-1) end)
	self.rosterPageNext = ELib:Button(self.tab.tabs[1],">"):Point("LEFT", self.rosterPage,"RIGHT",2,0):Size(20,15):OnClick(function() module.options:UpdateRoster_MovePage(1) end)

	local gruevent = {}
	function self:UpdateRoster()
		local rosterType = module.options.rosterType or 1
		for i=1,8 do gruevent[i] = 0 end
		if rosterType == 1 then
			for _,name, subgroup, class, guid, rank, level, online, isDead, combatRole in MRT.F.IterateRoster do
				gruevent[subgroup] = gruevent[subgroup] + 1

				local POS = gruevent[subgroup] + (subgroup - 1) * 5
				local obj = module.options.raidnames[POS]

				if obj then
					local cR,cG,cB = MRT.F.classColorNum(class)
					name = MRT.F.delUnitNameServer(name)
					local colorCode = MRT.F.classColor(class)
					obj.iconText = "||c"..colorCode..name.."||r "
					obj.iconTextShift = name
					local roleicon = combatRole and roleToIcon[combatRole]
					obj.html:SetText((roleicon or "")..name)
					obj.html:SetTextColor(cR, cG, cB, 1)
				end
			end
			module.options.rosterPage:Hide()
			module.options.rosterPagePrev:Hide()
			module.options.rosterPageNext:Hide()
		elseif rosterType == 2 then
			local start = ((self.rosterpage or 1) - 1) * 40 + 1
			if start > #VMRT.Note.CustomRoster then
				start = 1
				self.rosterpage = 1
			end
			self:UpdateRoster_MovePage(0,true)
			local c = 0
			for i=start,#VMRT.Note.CustomRoster do
				c = c + 1
				if c > 40 then break end
				subgroup = floor((c - 1) / 5) + 1
				gruevent[subgroup] = gruevent[subgroup] + 1

				local POS = gruevent[subgroup] + (subgroup - 1) * 5
				local obj = module.options.raidnames[POS]

				if obj then
					local cR,cG,cB = MRT.F.classColorNum(VMRT.Note.CustomRoster[i][2] or "")
					name = VMRT.Note.CustomRoster[i][1]
					local colorCode = MRT.F.classColor(VMRT.Note.CustomRoster[i][2] or "")
					obj.iconText = "||c"..colorCode..name.."||r "
					obj.iconTextShift = name
					local roleicon = VMRT.Note.CustomRoster[i][3] and roleToIcon[ VMRT.Note.CustomRoster[i][3] ]
					obj.html:SetText((roleicon or "")..name)
					obj.html:SetTextColor(cR, cG, cB, 1)
				end
			end
			module.options.rosterPage:SetShown(#VMRT.Note.CustomRoster > 40)
			module.options.rosterPagePrev:SetShown(#VMRT.Note.CustomRoster > 40)
			module.options.rosterPageNext:SetShown(#VMRT.Note.CustomRoster > 40)
		end
		for i=1,8 do
			for j=(gruevent[i]+1),5 do
				local frame = module.options.raidnames[(i-1)*5+j]
				frame.iconText = ""
				frame.iconTextShift = ""
				frame.html:SetText("")
			end
		end
	end

	self.lastUpdate = ELib:Text(self.tab.tabs[1],"",11):Size(600,20):Point("TOPLEFT",self.NotesList,"BOTTOMLEFT",3,-6):Top():Color()
	if VMRT.Note.LastUpdateName and VMRT.Note.LastUpdateTime then
		self.lastUpdate:SetText( L.NoteLastUpdate..": "..VMRT.Note.LastUpdateName.." ("..date("%H:%M:%S %d.%m.%Y",VMRT.Note.LastUpdateTime)..")" )
	end
	self.lastUpdate:Hide()

	self.chkEnable = ELib:Check(self,L.Enable,VMRT.Note.enabled):Point(720,-17):Tooltip("/rt note|n/rt n"):Size(18,18):AddColorState():TextButton():OnClick(function(self)
		if self:GetChecked() then
			module:Enable()
		else
			module:Disable()
		end
	end)

	self.chkFix = ELib:Check(self,L.messagebutfix,VMRT.Note.Fix):Point(590,-17):Tooltip(L.messagebutfixtooltip):Size(18,18):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.Fix = true
			module.allframes:SetMovable(false)
			module.allframes:EnableMouse(false)
			module.allframes.buttonResize:Hide()
			module.allframes:SetShadowComment(false)
		else
			VMRT.Note.Fix = nil
			module.allframes:SetMovable(true)
			module.allframes:EnableMouse(true)
			module.allframes.buttonResize:Show()
			module.allframes:SetShadowComment(true)
		end
	end)

	self.chkOnlyPromoted = ELib:Check(self.tab.tabs[2],L.NoteOnlyPromoted,VMRT.Note.OnlyPromoted):Point(15,-15):Tooltip(L.NoteOnlyPromotedTooltip):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.OnlyPromoted = true
		else
			VMRT.Note.OnlyPromoted = nil
		end
	end)


	self.chkOnlyInRaid = ELib:Check(self.tab.tabs[2],L.MarksBarDisableInRaid,VMRT.Note.HideOutsideRaid):Point("TOPLEFT",self.chkOnlyPromoted,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.HideOutsideRaid = true
		else
			VMRT.Note.HideOutsideRaid = nil
		end
		module:Visibility()
	end)

	self.chkOnlyInRaidKInstance = ELib:Check(self.tab.tabs[2],L.NoteShowOnlyInRaid,VMRT.Note.ShowOnlyInRaid):Point("TOPLEFT",self.chkOnlyInRaid,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.ShowOnlyInRaid = true
			module:RegisterEvents('ZONE_CHANGED_NEW_AREA')
		else
			VMRT.Note.ShowOnlyInRaid = nil
			module:UnregisterEvents('ZONE_CHANGED_NEW_AREA')
		end
		module:Visibility()
	end)

	self.chkOnlySelf = ELib:Check(self.tab.tabs[2],L.NoteShowOnlyPersonal,VMRT.Note.ShowOnlyPersonal):Point("TOPLEFT",self.chkOnlyInRaidKInstance,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.ShowOnlyPersonal = true
		else
			VMRT.Note.ShowOnlyPersonal = nil
		end
		module.allframes:UpdateText()
	end)

	self.chkSelfWindow = ELib:Check(self.tab.tabs[2],L.NotePersonalWindow,VMRT.Note.PersonalWindow):Point("TOPLEFT",self.chkOnlySelf,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.PersonalWindow = true
			module.frame_personal:Enable()
		else
			VMRT.Note.PersonalWindow = nil
			module.frame_personal:Disable()
		end
		module.allframes:UpdateText()
	end)


	self.chkHideInCombat = ELib:Check(self.tab.tabs[2],L.NoteHideInCombat,VMRT.Note.HideInCombat):Point("TOPLEFT",self.chkSelfWindow,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.HideInCombat = true
			module:RegisterEvents('PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED')
		else
			VMRT.Note.HideInCombat = nil
			module:UnregisterEvents('PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED')
		end
		module:Visibility()
	end)

	self.chkSaveAllNew = ELib:Check(self.tab.tabs[2],L.NoteSaveAllNew,VMRT.Note.SaveAllNew):Point("TOPLEFT",self.chkHideInCombat,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.SaveAllNew = true
		else
			VMRT.Note.SaveAllNew = nil
		end
	end)

	self.chkEnableWhenReceive = ELib:Check(self.tab.tabs[2],L.NoteEnableWhenReceive,VMRT.Note.EnableWhenReceive):Point("TOPLEFT",self.chkSaveAllNew,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.EnableWhenReceive = true
		else
			VMRT.Note.EnableWhenReceive = nil
		end
	end)

	self.chkEnableBossAutoLoad = ELib:Check(self.tab.tabs[2],L.NoteEnableBossAutoLoad,VMRT.Note.EnableBossAutoLoad):Tooltip(L.NoteEnableBossAutoLoadTip):Point("TOPLEFT",self.chkEnableWhenReceive,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.EnableBossAutoLoad = true
			module:RegisterEvents('ZONE_CHANGED','ZONE_CHANGED_INDOORS')
		else
			VMRT.Note.EnableBossAutoLoad = nil
		end
	end)

	self.dropDownBossAutoLoadType = ELib:DropDown(self.tab.tabs[2],350,3):Point("LEFT",self.chkEnableBossAutoLoad,315,-0):Size(300):SetText(L["NoteEnableBossAutoLoadType"..(VMRT.Note.BossAutoLoadType or 3)])
	function self.dropDownBossAutoLoadType:SetValue(arg1)
		ELib:DropDownClose()
		VMRT.Note.BossAutoLoadType = arg1
		module.options.dropDownBossAutoLoadType:SetText(L["NoteEnableBossAutoLoadType"..arg1])
	end
	for i=1,3 do
		self.dropDownBossAutoLoadType.List[i] = {
			text = L["NoteEnableBossAutoLoadType"..i],
			arg1 = i,
			func = self.dropDownBossAutoLoadType.SetValue,
		}
	end

	self.chkBossAutoLoadSend = ELib:Check(self.tab.tabs[2],L.NoteBossAutoLoadSendAsRL,VMRT.Note.BossAutoLoadSendAsRL):Tooltip(L.NoteEnableBossAutoLoadTip):Point("TOPLEFT",self.chkEnableBossAutoLoad,"BOTTOMLEFT",25,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.BossAutoLoadSendAsRL = true
		else
			VMRT.Note.BossAutoLoadSendAsRL = nil
		end
	end)

	self.chkBossAutoLoadPersonal = ELib:Check(self.tab.tabs[2],L.NoteBossAutoLoadPersonal,VMRT.Note.BossAutoLoadPersonal):Point("TOPLEFT",self.chkBossAutoLoadSend,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.BossAutoLoadPersonal = true
		else
			VMRT.Note.BossAutoLoadPersonal = nil
		end
	end)


	if MRT.isClassic and not MRT.isLK then
		self.dropDownBossAutoLoadType:Hide()
		self.chkEnableBossAutoLoad:Hide()
		self.chkBossAutoLoadSend:Hide()
		self.chkBossAutoLoadPersonal:Hide()
	end

	self.sliderFontSize = ELib:Slider(self.tab.tabs[2],L.NoteFontSize):Size(300):Point("TOPLEFT",self.chkEnableBossAutoLoad,"BOTTOMLEFT",0,-20-45):Range(6,72):SetTo(VMRT.Note.FontSize or 12):OnChange(function(self,event)
		event = event - event%1
		VMRT.Note.FontSize = event
		module.allframes:UpdateFont()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	local function DropDownTextAlign_Click(_,arg)
		VMRT.Note.TextAlign = arg
		ELib:DropDownClose()
		module.allframes:UpdateFont()
		self.dropDownTextAlign:AutoText(VMRT.Note.TextAlign)
	end

	self.dropDownTextAlign = ELib:DropDown(self.tab.tabs[2],350,3):Point("LEFT",self.sliderFontSize,"LEFT",450,0):Size(300):AddText(L.NoteFontTextAlign..":")
	self.dropDownTextAlign.List = {
		{text = L.cd2ColSetFontPosLeft, arg1 = nil, func = DropDownTextAlign_Click},
		{text = L.cd2ColSetFontPosRight, arg1 = 2, func = DropDownTextAlign_Click},
		{text = L.cd2ColSetFontPosCenter, arg1 = 3, func = DropDownTextAlign_Click},
	}
	self.dropDownTextAlign:AutoText(VMRT.Note.TextAlign)

	local function DropDownFont_Click(_,arg)
		VMRT.Note.FontName = arg
		local FontNameForDropDown = arg:match("\\([^\\]*)$")
		module.options.dropDownFont:SetText(FontNameForDropDown or arg)
		ELib:DropDownClose()
		module.allframes:UpdateFont()
	end

	self.dropDownFont = ELib:DropDown(self.tab.tabs[2],350,10):Point("TOPLEFT",self.sliderFontSize,"TOPLEFT",0,-30):Size(300)
	do
		local fontMedia = MRT.F.GetSharedMediaList("font", MRT.F.fontList)
		for i = 1, #fontMedia do
			local entry = fontMedia[i]
			self.dropDownFont.List[i] = {
				text = entry.name,
				arg1 = entry.path,
				func = DropDownFont_Click,
				font = entry.path,
				justifyH = "CENTER",
			}
		end
	end
	do
		local arg = VMRT.Note.FontName or MRT.F.defFont
		local FontNameForDropDown = arg:match("\\([^\\]*)$")
		self.dropDownFont:SetText(FontNameForDropDown or arg)
	end

	self.chkOutline = ELib:Check(self.tab.tabs[2],L.messageOutline,VMRT.Note.Outline):Point("LEFT",self.dropDownFont,"RIGHT",15,0):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.Outline = true
		else
			VMRT.Note.Outline = nil
		end
		module.allframes:UpdateFont()
	end)

	self.slideralpha = ELib:Slider(self.tab.tabs[2],L.messagebutalpha):Size(300):Point("TOPLEFT",self.dropDownFont,"BOTTOMLEFT",0,-20):Range(0,100):SetTo(VMRT.Note.Alpha or 100):OnChange(function(self,event)
		event = event - event%1
		VMRT.Note.Alpha = event
		module.allframes:SetAlpha(event/100)
		module.allframes:UpdateText()
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.slideralphaback = ELib:Slider(self.tab.tabs[2],L.messageBackAlpha):Size(300):Point("TOPLEFT",self.slideralpha,"BOTTOMLEFT",0,-20):Range(0,100):SetTo(VMRT.Note.ScaleBack or 100):OnChange(function(self,event)
		event = event - event%1
		VMRT.Note.ScaleBack = event
		MRT_SetSolidColor(module.allframes.background,0,0,0,event/100)
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.sliderscale = ELib:Slider(self.tab.tabs[2],L.messagebutscale):Size(300):Point("TOP",self.slideralpha,"TOP",0,0):Point("LEFT",self.slideralpha,"RIGHT",50,0):Range(5,200):SetTo(VMRT.Note.Scale or 100):OnChange(function(self,event)
		event = event - event%1
		VMRT.Note.Scale = event
		module.allframes:ScaleFix(event/100)
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.moreOptionsDropDown = ELib:DropDown(self.tab.tabs[2],275,#frameStrataList+1):Point("TOPLEFT",self.slideralphaback,"BOTTOMLEFT",0,-15):Size(300):SetText(L.NoteFrameStrata)

	local function moreOptionsDropDown_SetVaule(_,arg)
		VMRT.Note.Strata = arg
		ELib:DropDownClose()
		for i=1,#self.moreOptionsDropDown.List-1 do
			self.moreOptionsDropDown.List[i].checkState = VMRT.Note.Strata == self.moreOptionsDropDown.List[i].arg1
		end
		module.allframes:SetFrameStrata(arg)
	end

	for i=1,#frameStrataList do
		self.moreOptionsDropDown.List[i] = {
			text = frameStrataList[i],
			checkState = VMRT.Note.Strata == frameStrataList[i],
			radio = true,
			arg1 = frameStrataList[i],
			func = moreOptionsDropDown_SetVaule,
		}
	end
	tinsert(self.moreOptionsDropDown.List,{text = L.minimapmenuclose, func = function()
		ELib:DropDownClose()
	end})

	self.ButtonToCenter = ELib:Button(self.tab.tabs[2],L.MarksBarResetPos):Size(300,20):Point("TOPLEFT",self.moreOptionsDropDown,"BOTTOMLEFT",0,-5):Tooltip(L.MarksBarResetPosTooltip):OnClick(function()
		VMRT.Note.Left = nil
		VMRT.Note.Top = nil

		module.allframes:ClearAllPoints()
		module.allframes:SetPoint("CENTER",UIParent, "CENTER", 0, 0)
	end)

	ELib:DecorationLine(self.tab.tabs[2]):Point("LEFT",0,0):Point("RIGHT",0,0):Size(0,1):Point("TOP",self.ButtonToCenter,"BOTTOM",0,-5)
	ELib:Text(self.tab.tabs[2],L.NoteTimers,14):Point("TOP",self.ButtonToCenter,"BOTTOM",0,-9):Point("LEFT",20,0):Color()

	self.chkTimersHidePassed = ELib:Check(self.tab.tabs[2],L.NoteTimersHidePassed,VMRT.Note.TimerPassedHide):Point("TOPLEFT",self.ButtonToCenter,"BOTTOMLEFT",0,-25):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.TimerPassedHide = true
		else
			VMRT.Note.TimerPassedHide = nil
		end
	end)

	self.chkTimersGlow = ELib:Check(self.tab.tabs[2],L.NoteTimersGlow,VMRT.Note.TimerGlow):Point("TOPLEFT",self.chkTimersHidePassed,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.TimerGlow = true
		else
			VMRT.Note.TimerGlow = nil
		end
	end)

	self.chkTimersOnlyMy = ELib:Check(self.tab.tabs[2],L.NoteTimersOnlyMy,VMRT.Note.TimerOnlyMy):Point("TOPLEFT",self.chkTimersGlow,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.TimerOnlyMy = true
		else
			VMRT.Note.TimerOnlyMy = nil
		end
		module.allframes:UpdateText()
	end)

	self.chkTimersOnlyMyEnableAllNames = ELib:Check(self.tab.tabs[2],L.NoteTimersOnlyMyEnableAllNames,not VMRT.Note.TimerOnlyMyEnableAllNames):Point("TOPLEFT",self.chkTimersOnlyMy,"BOTTOMLEFT",25,-5):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.TimerOnlyMyEnableAllNames = nil
		else
			VMRT.Note.TimerOnlyMyEnableAllNames = true
		end
		module.allframes:UpdateText()
	end)

	local testGlowDelay
	local function TestGlow()
		module.allframes:HideGlow()
		module.allframes:ShowGlow()
		if testGlowDelay then
			testGlowDelay:Cancel()
		end
		testGlowDelay = C_Timer.NewTimer(3,function()
			module.allframes:HideGlow()
		end)
	end

	self.frameTypeGlow1 = ELib:Radio(self.tab.tabs[2],""):Point("LEFT",self.chkTimersGlow,530,0):OnClick(function()
		self.frameTypeGlow1:SetChecked(true)
		self.frameTypeGlow2:SetChecked(false)
		self.frameTypeGlow3:SetChecked(false)
		VMRT.Note.TimerGlowType = 1

		TestGlow()
	end)
	self.frameTypeGlow1.f = CreateFrame("Frame",nil,self.frameTypeGlow1)
	self.frameTypeGlow1.f:SetPoint("LEFT",self.frameTypeGlow1,"RIGHT",5,0)
	self.frameTypeGlow1.f:SetSize(40,15)

	self.frameTypeGlow2 = ELib:Radio(self.tab.tabs[2],""):Point("LEFT",self.frameTypeGlow1,100,0):OnClick(function()
		self.frameTypeGlow1:SetChecked(false)
		self.frameTypeGlow2:SetChecked(true)
		self.frameTypeGlow3:SetChecked(false)
		VMRT.Note.TimerGlowType = 2

		TestGlow()
	end)
	self.frameTypeGlow2.f = CreateFrame("Frame",nil,self.frameTypeGlow2)
	self.frameTypeGlow2.f:SetPoint("LEFT",self.frameTypeGlow2,"RIGHT",5,0)
	self.frameTypeGlow2.f:SetSize(40,15)

	self.frameTypeGlow3 = ELib:Radio(self.tab.tabs[2],""):Point("LEFT",self.frameTypeGlow2,100,0):OnClick(function()
		self.frameTypeGlow1:SetChecked(false)
		self.frameTypeGlow2:SetChecked(false)
		self.frameTypeGlow3:SetChecked(true)
		VMRT.Note.TimerGlowType = 3

		TestGlow()
	end)
	self.frameTypeGlow3.f = CreateFrame("Frame",nil,self.frameTypeGlow3)
	self.frameTypeGlow3.f:SetPoint("LEFT",self.frameTypeGlow3,"RIGHT",5,0)
	self.frameTypeGlow3.f:SetSize(40,15)

		local LCG = LibStub("LibCustomGlow-1.0-MRT",true)
		if LCG then
			LCG.PixelGlow_Start(self.frameTypeGlow1.f,{1,1,0,1},nil,nil,nil,2,1,1)
			LCG.ButtonGlow_Start(self.frameTypeGlow2.f)
			LCG.AutoCastGlow_Start(self.frameTypeGlow3.f,{1,1,1,0.85},16,nil,2)
		end

	if VMRT.Note.TimerGlowType == 2 then
		self.frameTypeGlow2:SetChecked(true)
	elseif VMRT.Note.TimerGlowType == 3 then
		self.frameTypeGlow3:SetChecked(true)
	else
		self.frameTypeGlow1:SetChecked(true)
	end

	if VMRT.Note.Text1 then
		self.NoteEditBox.EditBox:SetText(VMRT.Note.Text1)
	end


	local profilesTab = self.tab.tabs[3]

	local function GetCurrentProfileName()
		return VMRT.Note.Profiles.Now=="default" and L.ProfilesDefault or VMRT.Note.Profiles.Now
	end

	profilesTab.currentText = ELib:Text(profilesTab,L.ProfilesCurrent,11):Size(650,200):Point(15,-15):Top():Color()
	profilesTab.currentName = ELib:Text(profilesTab,"",14):Size(650,200):Point(210,-15):Top():Color(1,1,0)

	profilesTab.currentName.UpdateText = function(self)
		self:SetText(GetCurrentProfileName())
	end
	profilesTab.currentName:UpdateText()

	profilesTab.choseText = ELib:Text(profilesTab,L.ProfilesChooseDesc,11):Size(650,200):Point(15,-40):Top():Color()

	profilesTab.choseNewText = ELib:Text(profilesTab,L.ProfilesNew,11):Size(650,200):Point(15,-75+12):Top()
	profilesTab.choseNew = ELib:Edit(profilesTab):Size(170,20):Point(10,-75)

	profilesTab.choseNewButton = ELib:Button(profilesTab,L.ProfilesAdd):Size(70,20):Point("LEFT",profilesTab.choseNew,"RIGHT",0,0):OnClick(function (self)
		local text = profilesTab.choseNew:GetText()
		profilesTab.choseNew:SetText("")
		if text == "" or text == "default" or VMRT.Note.Profiles.List[text] or text == VMRT.Note.Profiles.Now then
			return
		end
		VMRT.Note.Profiles.List[text] = MRT.F.table_copy2(NewVMRTTableData)

		StaticPopupDialogs["EXRT_NOTE_ACTIVATENEW"] = {
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
		StaticPopup_Show("EXRT_NOTE_ACTIVATENEW")
	end)

	profilesTab.choseSelectText = ELib:Text(profilesTab,L.ProfilesSelect,11):Size(605,200):Point(335,-75+12):Top()
	profilesTab.choseSelectDropDown = ELib:DropDown(profilesTab,220,10):Point(330,-75):Size(235):SetText(GetCurrentProfileName())
	profilesTab.choseSelectDropDown.UpdateText = function(self)
		self:SetText(GetCurrentProfileName())
	end

	local function GetCurrentProfilesList(func)
		local list = {
			{ text = GetCurrentProfileName(), func = func, arg1 = VMRT.Note.Profiles.Now, _sort = "0" },
		}
		for name,_ in pairs(VMRT.Note.Profiles.List) do
			if name ~= VMRT.Note.Profiles.Now then
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
		local newdb = VMRT.Note.Profiles.List[name]
		local currname = VMRT.Note.Profiles.Now
		if module:SelectProfile(name) then
			VMRT.Note.Profiles.List[name] = newdb
			VMRT.Note.Profiles.Now = currname

			profilesTab.currentName:UpdateText()

			print(L.cd2ProfileCopySuccess:format(name))
		end
	end
	profilesTab.copyText = ELib:Text(profilesTab,L.ProfilesCopy,11):Size(605,200):Point(15,-120+12):Top()
	profilesTab.copyDropDown = ELib:DropDown(profilesTab,220,10):Point(10,-120):Size(235)
	function profilesTab.copyDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(function(_,arg1)
			ELib:DropDownClose()
			CopyProfile(arg1)
		end)
		for i=1,#self.List do
			if self.List[i].arg1 == VMRT.Note.Profiles.Now then
				tremove(self.List, i)
				break
			end
		end
	end

	local function DeleteProfile(name)
		StaticPopupDialogs["EXRT_NOTE_PROFILES_REMOVE"] = {
			text = L.ProfilesDeleteAlert,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				VMRT.Note.Profiles.List[name] = nil
				profilesTab:UpdateAutoTexts()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_NOTE_PROFILES_REMOVE")
	end
	profilesTab.deleteText = ELib:Text(profilesTab,L.ProfilesDelete,11):Size(605,200):Point(15,-160+12):Top()
	profilesTab.deleteDropDown = ELib:DropDown(profilesTab,220,10):Point(10,-160):Size(235)
	function profilesTab.deleteDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(function(_,arg1)
			ELib:DropDownClose()
			DeleteProfile(arg1)
		end)
		for i=#self.List,1,-1 do
			if self.List[i].arg1 == VMRT.Note.Profiles.Now then
				tremove(self.List, i)
			elseif self.List[i].arg1 == "default" then
				tremove(self.List, i)
			end
		end
	end


	profilesTab.importWindow, profilesTab.exportWindow = MRT.F.CreateImportExportWindows()

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

	profilesTab.exportButton = ELib:Button(profilesTab,L.ProfilesExport):Size(235,25):Point(10,-200):OnClick(function (self)
		profilesTab.exportWindow:NewPoint("CENTER",UIParent,0,0)
		profilesTab:ProfileToText()
	end)

	profilesTab.importButton = ELib:Button(profilesTab,L.ProfilesImport):Size(235,25):Point("LEFT",profilesTab.exportButton,"RIGHT",85,0):OnClick(function (self)
		profilesTab.importWindow:NewPoint("CENTER",UIParent,0,0)
		profilesTab.importWindow:Show()
	end)

	local IGNORE_PROFILE_KEYS = {
		["Profiles"] = true,
		["Black"] = true,
		["BlackNames"] = true,
		["BlackLastUpdateName"] = true,
		["BlackLastUpdateTime"] = true,
		["AutoLoad"] = true,

		["SelfText"] = true,
		["Text1"] = true,
	}
	function profilesTab:ProfileToText()
		local new = {}
		for key,val in pairs(VMRT.Note) do
			if not IGNORE_PROFILE_KEYS[key] then
				new[key] = val
			end
		end
		local strlist = MRT.F.TableToText(new)
		strlist[1] = "0,"..strlist[1]
		local str = table.concat(strlist)

		local compressed
		if #str < 1000000 then
			compressed = LibDeflate:CompressDeflate(str,{level = 5})
		end
		local encoded = "MRTCDP"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or str)

		MRT.F.dprint("Str len:",#str,"Encoded len:",#encoded)

		if MRT.isDev then
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

			["Black"] = true,
			["BlackNames"] = true,
			["BlackLastUpdateName"] = true,
			["BlackLastUpdateTime"] = true,
			["AutoLoad"] = true,

			["SelfText"] = true,
			["Text1"] = true,
		}
		for k,v in pairs(KeysToErase) do
			res[k] = nil
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

		local successful, res = pcall(MRT.F.TextToTable,tableData)
		if MRT.isDev then
			module.db.lastImportDB = res
			if module.db.exportTable and type(res)=="table" then
				module.db.diffTable = {}
				print("Compare table",MRT.F.table_compare(res,module.db.exportTable,module.db.diffTable))
			end
		end
		if successful and res then
			profilesTab:LockedFilter(res)
			MRT.F.ImportChoicePopup(
				L.cd2ProfileRewriteAlert,
				{
					{text = APPLY, func = function()
						local saved = profilesTab:SaveDataFilter(VMRT.Note)
						MRT.F.table_rewrite(VMRT.Note,res)
						saved:Restore(VMRT.Note)
						module:ReloadProfile()
						res = nil
					end},
					{text = L.ProfilesSaveAsNew, func = function()
						MRT.F.ShowInput(L.ProfilesNewProfile,function(_,name)
							if name == "" or VMRT.Note.Profiles.List[name] or name == "default" or name == VMRT.Note.Profiles.Now then
								res = nil
								return
							end
							VMRT.Note.Profiles.List[name] = res
							module:SelectProfile(name)
							res = nil
						end,nil,nil,nil,function(self)
							local name = self:GetText()
							if name == "" or VMRT.Note.Profiles.List[name] or name == "default" or name == VMRT.Note.Profiles.Now then
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
			StaticPopupDialogs["EXRT_NOTE_IMPORT"] = {
				text = L.ProfilesFail1..(res and "\nError code: "..res or ""),
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
		end

		StaticPopup_Show("EXRT_NOTE_IMPORT")
	end


	profilesTab.autoText = ELib:Text(profilesTab,L.cd2AutoChangeTooltip,12):Size(605,200):Point(10,-240):Top():Color()

	local function GetTextProfileName(profileName)
		if not profileName then
			return
		end
		local prefix
		if profileName == VMRT.Note.Profiles.Now then
			prefix = "|cff00ff00"
		elseif not VMRT.Note.Profiles.List[profileName] then
			prefix = "|cffff0000"
		end
		if profileName == "default" then
			profileName = L.ProfilesDefault
		end
		return (prefix or "")..profileName
	end
	function profilesTab:UpdateAutoTexts()
		self.autoRaidDown:SetText(GetTextProfileName(VMRT.Note.Profiles.Raid) or "|cff999999"..L.cd2DontChange)
		self.autoDungDown:SetText(GetTextProfileName(VMRT.Note.Profiles.Dung) or "|cff999999"..L.cd2DontChange)
		self.autoArenaDown:SetText(GetTextProfileName(VMRT.Note.Profiles.Arena) or "|cff999999"..L.cd2DontChange)
		self.autoBGDown:SetText(GetTextProfileName(VMRT.Note.Profiles.BG) or "|cff999999"..L.cd2DontChange)
		self.autoOtherDown:SetText(GetTextProfileName(VMRT.Note.Profiles.Other) or "|cff999999"..L.cd2DontChange)

		for _,dd in pairs({self.autoSpec1Down,self.autoSpec2Down,self.autoSpec3Down,self.autoSpec4Down}) do
			dd:SetText(GetTextProfileName(VMRT.Note.Profiles[dd.OptKey]) or "|cff999999"..L.cd2DontChange)
		end
	end

	local function AutoDropDown_ToggleUpadte(self)
		local func = function(_,arg1)
			ELib:DropDownClose()
			VMRT.Note.Profiles[self.OptKey] = arg1
			profilesTab:UpdateAutoTexts()
			C_Timer.After(2,module.CheckZoneProfiles)
		end
		self.List = GetCurrentProfilesList(func)
		tinsert(self.List,1,{text = L.cd2DontChange, func = func})
	end

	profilesTab.autoRaidDown = ELib:DropDown(profilesTab,220,10):Point(10,-270):Size(235):AddText(RAID,11,function(self)self:NewPoint("TOPLEFT",'x',5,12):Color(1,.82,0,1) end)
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

	local class = (select(2,UnitClass'player')) or ""

	profilesTab.autoTextSpec = ELib:Text(profilesTab,L.cd2AutoChangeSpecTooltip,12):Size(605,200):Point(10,-380):Top():Color()

	profilesTab.autoSpec1Down = ELib:DropDown(profilesTab,220,10):Point(10,-410):Size(235)
	profilesTab.autoSpec1Down.OptKey = "Spec1" .. class
	profilesTab.autoSpec1Down.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab.autoSpec2Down = ELib:DropDown(profilesTab,220,10):Point("TOPLEFT",profilesTab.autoSpec1Down,0,-40):Size(235)
	profilesTab.autoSpec2Down.OptKey = "Spec2" .. class
	profilesTab.autoSpec2Down.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab.autoSpec3Down = ELib:DropDown(profilesTab,220,10):Point("TOPLEFT",profilesTab.autoSpec1Down,320,0):Size(235)
	profilesTab.autoSpec3Down.OptKey = "Spec3" .. class
	profilesTab.autoSpec3Down.ToggleUpadte = AutoDropDown_ToggleUpadte

	profilesTab.autoSpec4Down = ELib:DropDown(profilesTab,220,10):Point("TOPLEFT",profilesTab.autoSpec2Down,320,0):Size(235)
	profilesTab.autoSpec4Down.OptKey = "Spec4" .. class
	profilesTab.autoSpec4Down.ToggleUpadte = AutoDropDown_ToggleUpadte

	if not GetSpecializationInfo then
		profilesTab.autoTextSpec:Hide()
		profilesTab.autoSpec1Down:Hide()
		profilesTab.autoSpec2Down:Hide()
		profilesTab.autoSpec3Down:Hide()
		profilesTab.autoSpec4Down:Hide()
	else
		for i=1,4 do
			local _, name = GetSpecializationInfo(i)
			if name then
				profilesTab["autoSpec"..i.."Down"]:AddText(name,11,function(self)self:NewPoint("TOPLEFT",'x',5,12):Color(1,.82,0,1) end)
			else
				profilesTab["autoSpec"..i.."Down"]:Hide()
			end
		end
	end

	profilesTab:UpdateAutoTexts()

	profilesTab.chkKeepText = ELib:Check(profilesTab,L.NoteProfilesKeepText,VMRT.Note.Profiles.KeepText):Point("TOPLEFT",profilesTab.autoSpec2Down,"BOTTOMLEFT",0,-25):OnClick(function(self)
		if self:GetChecked() then
			VMRT.Note.Profiles.KeepText = true
		else
			VMRT.Note.Profiles.KeepText = nil
		end
	end)


	-- Help tab: ONE scroll frame for the WHOLE page (basic lines + Advanced button +
	-- advanced lines). Each help line is its own FontString with explicit width +
	-- measured height, because on 3.3.5a a FontString truncates text taller than its
	-- height (GroupBulletinBoard recipe: SetWidth -> SetHeight(0) -> GetStringHeight ->
	-- SetHeight). Advanced lines stay hidden until "Advanced Help" is toggled; the single
	-- right-side scrollbar then covers the entire note so you can scroll to the very bottom.
	local HELP_SPACING = 4

	local function BuildHelpLines(parent, lines, store, opts)
		local prev
		for i = 1, #lines do
			local fs = ELib:Text(parent, lines[i]):Color()
			if prev then
				fs:Point("TOPLEFT", prev, "BOTTOMLEFT", 0, -HELP_SPACING)
			elseif opts and opts.anchorFrame then
				fs:Point("TOP", opts.anchorFrame, "BOTTOM", 0, opts.y or -8)
				fs:Point("LEFT", parent, "LEFT", opts.x or 10, 0)
			else
				fs:Point("TOPLEFT", (opts and opts.x) or 10, (opts and opts.y) or -10)
			end
			store[#store + 1] = fs
			prev = fs
		end
		return prev
	end

	local function LayoutHelpLines(store, width)
		local total = 0
		for i = 1, #store do
			local fs = store[i]
			fs:SetWidth(width)
			fs:SetHeight(0)
			local h = fs:GetStringHeight()
			if not h or h < 1 then h = 12 end
			fs:SetHeight(h)
			total = total + h + HELP_SPACING
		end
		return total
	end

	-- One scroll frame filling the whole Help sub-tab
	self.helpScroll = ELib:ScrollFrame(self.tab.tabs[4]):Point("TOPLEFT",0,0):Point("BOTTOMRIGHT",0,0)
	ELib:Border(self.helpScroll,0)
	self.helpScroll:HideScrollOnNoScroll()
	self.helpScroll.C:SetWidth(820)
	local helpC = self.helpScroll.C

	-- Basic help lines (descriptions from localization; tag tokens keep original colors)
	local basicLines = {}
	local function addB(s) basicLines[#basicLines + 1] = s end
	addB("|cffffff00||cffRRGGBB|r...|cffffff00||r|r - "..L.NoteHelp1)
	-- Role tags {D}/{H}/{T}: NoteHelp2 takes the role name (DAMAGER/HEALER/TANK globals)
	addB("|cffffff00{D}|r...|cffffff00{/D}|r - "..L.NoteHelp2:format(DAMAGER or "Damager"))
	addB("|cffffff00{H}|r...|cffffff00{/H}|r - "..L.NoteHelp2:format(HEALER or "Healer"))
	addB("|cffffff00{T}|r...|cffffff00{/T}|r - "..L.NoteHelp2:format(TANK or "Tank"))
	-- NoteHelp3 embeds |T135940:0|t (a retail FileDataID); 3.3.5a only renders texture
	-- PATHS, so swap in the real spell-17 icon path so the inline icon shows.
	local help3 = L.NoteHelp3
	local spell17Icon = (GetSpellTexture and GetSpellTexture(17)) or "Interface\\Icons\\Spell_Holy_PowerWordShield"
	help3 = help3:gsub("|T%d+:", "|T"..spell17Icon..":")
	addB("|cffffff00{spell:|r|cff00ff0017|r|cffffff00}|r - "..help3)
	addB("|cffffff00{self}|r - "..L.NoteHelp4)
	addB("|cffffff00{p:|r|cff00ff00JaneD|r|cffffff00,|r|cff00ff00JennyB-HowlingFjord|r|cffffff00}|r...|cffffff00{/p}|r - "..L.NoteHelp5)
	addB("|cffffff00{!p:|r|cff00ff00Leeroy|r|cffffff00,|r|cff00ff00Juron|r|cffffff00}|r...|cffffff00{/p}|r - "..L.NoteHelp5b)
	addB("|cffffff00{icon:|r|cff00ff00Interface/Icons/inv_hammer_unique_sulfuras|r|cffffff00}|r - "..L.NoteHelp6)
	addB("|cffffff00{c:|r|cff00ff00Paladin,Priest|r|cffffff00}|r...|cffffff00{/c}|r - "..L.NoteHelp8)
	addB("|cffffff00{!c:|r|cff00ff00Mage,Hunter|r|cffffff00}|r...|cffffff00{/c}|r - "..L.NoteHelp8b)
	addB("|cffffff00{g|r|cff00ff002|r|cffffff00}|r...|cffffff00{/g}|r - "..L.NoteHelp10)
	addB("|cffffff00{!g|r|cff00ff0034|r|cffffff00}|r...|cffffff00{/g}|r - "..L.NoteHelp10b)
	if MRT.isClassic then
		addB("|cffffff00{race:|r|cff00ff00troll,orc|r|cffffff00}|r...|cffffff00{/race}|r - "..L.NoteHelp11)
		addB("|cffffff00{!race:|r|cff00ff00dwarf|r|cffffff00}|r...|cffffff00{/race}|r - "..L.NoteHelp11b)
	end
	addB("|cffffff00{time:|r|cff00ff002:45|r|cffffff00}|r - "..L.NoteHelp7)
	if not MRT.isClassic then
		addB("|cffffff00{p|r|cff00ff002|r|cffffff00}|r...|cffffff00{/p}|r - "..L.NoteHelp9)
	end
	addB("|cffffff00{0}|r...|cffffff00{/0}|r - "..L.NoteHelp12)

	self.helpBasicFS = {}
	local lastBasic = BuildHelpLines(helpC, basicLines, self.helpBasicFS, {x = 10, y = -15})
	self.textHelp = self.helpBasicFS[1]

	self.advancedHelp = ELib:Button(helpC,L.NoteHelpAdvanced):Size(400,20):Point("TOP",lastBasic,"BOTTOM",0,-20):OnClick(function()
		local o = module.options
		o.advancedShown = not o.advancedShown
		for i = 1, #o.helpAdvFS do o.helpAdvFS[i]:SetShown(o.advancedShown) end
		if o.LayoutHelp then o:LayoutHelp() end
		if not o.advancedShown and o.helpScroll and o.helpScroll.ScrollBar then o.helpScroll.ScrollBar:SetTo(0) end
	end)

	-- Advanced help lines (multi-line code/example blocks split into separate FontStrings)
	local advLines = {}
	local function addA(s) advLines[#advLines + 1] = s end
	addA("|cffffff00{time:|r|cff00ff001:06,p2|r|cffffff00}|r - "..L.NoteHelpAdv1)
	addA("|cffffff00{time:|r|cff00ff000:30,SCC:17:2|r|cffffff00}|r - "..L.NoteHelpAdv2)
	addA("   "..(HUD_EDIT_MODE_ENABLE_ADVANCED_OPTIONS or "Advanced Options")..": |cffffff00{time:|cff00ff00TIME|r,|cff00ff00SCC/SCS/SAA/SAR|r:|cff00ff00SPELL_ID|r:|cff00ff00SPELL_COUNT|r:|cff00ffffSOURCE_NAME|r:|cff00ffffPHASE|r}|r")
	addA("|cffffff00{time:|r|cff00ff002:00,e,customevent|r|cffffff00}|r - "..L.NoteHelpAdv3)
	addA("|cffffff00{time:|r|cff00ff003:40,glowall|r|cffffff00}|r - "..L.NoteHelpAdv6)
	addA("|cffffff00{time:|r|cff00ff004:15,glow|r|cffffff00}|r - "..L.NoteHelpAdv7)
	addA("|cffffff00{time:|r|cff00ff000:45,wa:nzoth_hs1|r|cffffff00}|r - "..L.NoteHelpAdv4)
	addA("   WA Function example:")
	addA("   Events: |cffffff00MRT_NOTE_TIME_EVENT|r")
	addA("   |cffff8bf3function(event,...)|r")
	addA("|cffff8bf3     if event == \"MRT_NOTE_TIME_EVENT\" then|r")
	addA("|cffff8bf3       local timerName, timeLeft, noteText = ...|r")
	addA("|cffff8bf3       if timerName == \"nzoth_hs1\" and timeLeft == 3 then|r")
	addA("|cffff8bf3         return true|r")
	addA("|cffff8bf3       end|r")
	addA("|cffff8bf3     end|r")
	addA("|cffff8bf3   end|r")
	addA(L.NoteHelpAdv5)
	addA(" |cffe6ff15{time:0:30,SCC:17:2,wa:eventName1,wa:eventName2}|r")
	addA(" |cffff9f05{time:1:40,p1.5}First intermission|r")
	addA(" |cffe6ff15{p,SCC:17:2}Until end of the fight{/p}|r")
	addA(" |cffff9f05{p,SCC:17:2,SCC:17:3}Until second condition{/p}|r")
	addA(" |cffe6ff15{time:0:20,p2,wa:use_hs,glowall}|r")
	addA(" |cffff9f05{time:65,SCC:17:2:"..UnitName'player'.."} Count casts only for player "..UnitName'player'.." |r")
	addA(" |cffe6ff15{time:1:05,SCC:17:2::p3} Count casts only on phase 3 |r")

	self.helpAdvFS = {}
	BuildHelpLines(helpC, advLines, self.helpAdvFS, {anchorFrame = self.advancedHelp, x = 10, y = -20})
	self.advancedShown = false
	for i = 1, #self.helpAdvFS do self.helpAdvFS[i]:Hide() end

	function self:LayoutHelp()
		local vw = self.helpScroll:GetWidth()
		if not vw or vw < 100 then vw = 850 end
		self.helpScroll.C:SetWidth(vw - 4)
		local w = vw - 30
		if w < 100 then w = 800 end
		local basicH = LayoutHelpLines(self.helpBasicFS, w)
		local total = 15 + basicH + 20 + 20         -- topPad + basic + gap + button
		if self.advancedShown then
			local advH = LayoutHelpLines(self.helpAdvFS, w)
			total = total + 20 + advH                -- gap + advanced
		end
		total = total + 20                           -- bottom padding
		self.helpScroll:Height(total)
	end
	self:LayoutHelp()

	module:RegisterEvents("GROUP_ROSTER_UPDATE")

	function self:OnShow()
		module.main:GROUP_ROSTER_UPDATE()
		if self.LayoutHelp then self:LayoutHelp() end
	end

	function self:UpdateOptions()
		self.chkEnable:SetChecked(VMRT.Note.enabled)
		self.chkEnable:ColorState()
		self.chkFix:SetChecked(VMRT.Note.Fix)
		self.chkOnlyPromoted:SetChecked(VMRT.Note.OnlyPromoted)
		self.chkOnlyInRaid:SetChecked(VMRT.Note.HideOutsideRaid)
		self.chkOnlyInRaidKInstance:SetChecked(VMRT.Note.ShowOnlyInRaid)
		self.chkOnlySelf:SetChecked(VMRT.Note.ShowOnlyPersonal)
		self.chkSelfWindow:SetChecked(VMRT.Note.PersonalWindow)
		self.chkHideInCombat:SetChecked(VMRT.Note.HideInCombat)
		self.chkSaveAllNew:SetChecked(VMRT.Note.SaveAllNew)
		self.chkEnableWhenReceive:SetChecked(VMRT.Note.EnableWhenReceive)
		self.sliderFontSize:SetTo(VMRT.Note.FontSize or 12)
		do
			local arg = VMRT.Note.FontName or MRT.F.defFont
			local FontNameForDropDown = arg:match("\\([^\\]*)$")
			self.dropDownFont:SetText(FontNameForDropDown or arg)
		end
		self.dropDownTextAlign:AutoText(VMRT.Note.TextAlign)
		self.chkOutline:SetChecked(VMRT.Note.Outline)
		self.slideralpha:SetTo(VMRT.Note.Alpha or 100)
		self.sliderscale:SetTo(VMRT.Note.Scale or 100)
		self.slideralphaback:SetTo(VMRT.Note.ScaleBack or 100)
		self.chkTimersHidePassed:SetChecked(VMRT.Note.TimerPassedHide)
		self.chkTimersGlow:SetChecked(VMRT.Note.TimerGlow)
		self.chkTimersOnlyMy:SetChecked(VMRT.Note.TimerOnlyMy)

		self.chkEnableBossAutoLoad:SetChecked(VMRT.Note.EnableBossAutoLoad)
		self.dropDownBossAutoLoadType:SetText(L["NoteEnableBossAutoLoadType"..(VMRT.Note.BossAutoLoadType or 3)])
		self.chkBossAutoLoadSend:SetChecked(VMRT.Note.BossAutoLoadSendAsRL)
		self.chkBossAutoLoadPersonal:SetChecked(VMRT.Note.BossAutoLoadPersonal)

		self.frameTypeGlow1:SetChecked(false)
		self.frameTypeGlow1:SetChecked(false)
		self.frameTypeGlow1:SetChecked(false)
		if VMRT.Note.TimerGlowType == 2 then
			self.frameTypeGlow2:SetChecked(true)
		elseif VMRT.Note.TimerGlowType == 3 then
			self.frameTypeGlow3:SetChecked(true)
		else
			self.frameTypeGlow1:SetChecked(true)
		end

		UpdatePageAfterGettingNote()

		self.tab.tabs[3].currentName:UpdateText()
		self.tab.tabs[3]:UpdateAutoTexts()
		if self.tab.tabs[3].choseSelectDropDown and self.tab.tabs[3].choseSelectDropDown.UpdateText then
			self.tab.tabs[3].choseSelectDropDown:UpdateText()
		end
	end

	self.isWide = true
end

local function NoteWindow_OnDragStart(self)
	if self:IsMovable() then
		self:StartMoving()
	end
end

local function NoteWindow_OnDragStop(self)
	self:StopMovingOrSizing()
	VMRT.Note[self.Name.."Left"] = self:GetLeft()
	VMRT.Note[self.Name.."Top"] = self:GetTop()
end

local function NoteWindow_UpdateMaxSymbolsLimit(self)
	local width_, height_ = self:GetSize()

	local fontSize = VMRT and VMRT.Note and VMRT.Note.FontSize or 12

	local maxPerLine = ceil(width_ / (fontSize / 4))
	local maxLines = ceil(height_ / (fontSize / 4))

	self.maxSymbols = (maxLines + 1) * (maxPerLine + 5)
end

local function NoteWindow_OnSizeChanged(self, width, height)
	local width_, height_ = self:GetSize()
	self:UpdateMaxSymbolsLimit()
	if VMRT and VMRT.Note then
		VMRT.Note[self.Name.."Width"] = width
		VMRT.Note[self.Name.."Height"] = height

		self:UpdateText()
	end

	self.sf.C:SetWidth( width_ )
end

local function NoteWindow_UpdateFont(self)
	local font = VMRT and VMRT.Note and VMRT.Note.FontName or MRT.F.defFont
	local size = VMRT and VMRT.Note and VMRT.Note.FontSize or 12
	local outline = VMRT and VMRT.Note and VMRT.Note.Outline and "OUTLINE" or ""
	local align = VMRT and VMRT.Note and ((VMRT.Note.TextAlign == 2 and "RIGHT") or (VMRT.Note.TextAlign == 3 and "CENTER")) or "LEFT"
	local isValidFont = self.text:SetFont(font,size,outline)
	self.text:SetJustifyH(align)
	if self.text.SetSpacing then self.text:SetSpacing(2) end

	local c = 2
	while self["text"..c] do
		self["text"..c]:SetFont(font,size,outline)
		self["text"..c]:SetJustifyH(align)
		if self["text"..c].SetSpacing then self["text"..c]:SetSpacing(2) end
		c = c + 1
	end

	if not isValidFont then
		self.text:SetFont(GameFontNormal:GetFont(),size,outline)

		local c = 2
		while self["text"..c] do
			self["text"..c]:SetFont(GameFontNormal:GetFont(),size,outline)
			c = c + 1
		end
	end

	self:UpdateMaxSymbolsLimit()
end

local function NoteWindow_UpdateText(self,onlyTimerUpdate)
	module.db.glowStatus = nil

	local text = txtWithIcons(self, self:GetRawText(), onlyTimerUpdate)
	local fontSize = VMRT and VMRT.Note and VMRT.Note.FontSize or 12
	text = resizeAutoIcons(text, fontSize)
	text = applyIconAlpha(text, VMRT and VMRT.Note and VMRT.Note.Alpha)

	local c = 2
	while self["text"..c] do
		self["text"..c]:SetText(" ")
		c = c + 1
	end

	if self.maxSymbols and #text > self.maxSymbols then
		text = text:sub(1,self.maxSymbols)
	end

	if #text > 8192 then
		local lennow = 0
		local texts = {""}
		local c = 1
		for w in string.gmatch(text,"[^\n]+\n*") do
			lennow = lennow + #w
			if lennow > 8192 then
				c = c + 1
				texts[c] = ""
				lennow = #w
			end
			texts[c] = texts[c] .. w
		end

		self.text:SetText(texts[1])

		local anyNew = false
		for i=2,c do
			anyNew = self.text:Add(i) or anyNew
			self["text"..i]:SetText(texts[i])
		end
		if anyNew then
			self:UpdateFont()
		end
	else
		self.text:SetText(text)
	end

	if module.db.glowStatus and not self.GlowShowed then
		self:ShowGlow()
		self.GlowShowed = true
	elseif not module.db.glowStatus and self.GlowShowed then
		self:HideGlow()
		self.GlowShowed = false
	end

	MRT.F:FireCallback("Note_UpdateText",self)
end

local glowColor1 = {1,1,0,1}
local glowColor3 = {1,1,1,0.85}
local function NoteWindow_ShowGlow(self)
	local LCG = LibStub("LibCustomGlow-1.0-MRT",true)
	if not LCG then
		return
	end

	if VMRT.Note.TimerGlowType == 2 then
		LCG.ButtonGlow_Start(self)
	elseif VMRT.Note.TimerGlowType == 3 then
		LCG.AutoCastGlow_Start(self,glowColor3,16,nil,2)
	else
		LCG.PixelGlow_Start(self,glowColor1,nil,nil,nil,3,1,1)
	end
end
local function NoteWindow_HideGlow(self)
	local LCG = LibStub("LibCustomGlow-1.0-MRT",true)
	if LCG then
		LCG.ButtonGlow_Stop(self)
		LCG.AutoCastGlow_Stop(self)
		LCG.PixelGlow_Stop(self)
	end
end

local function NoteWindow_TextFixLag(self)
	self:SetParent(self:GetParent().sf.C)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT",5,-5)
	self:SetPoint("TOPRIGHT",-5,-5)
end

local function NoteWindow_TextAdd(self,c)
	local parent = self.mf
	if parent["text"..c] then
		return
	end
	local text = parent:CreateFontString(nil,"ARTWORK")
	parent["text"..c] = text
	text:SetParent(parent.sf.C)
	text:SetFont(MRT.F.defFont, 12, "")
	local prev = c == 2 and parent.text or parent["text"..(c-1)]
	text:SetPoint("TOPLEFT",prev,"BOTTOMLEFT",0,0)
	text:SetPoint("TOPRIGHT",prev,"BOTTOMRIGHT",0,0)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetText(" ")
	text:SetNonSpaceWrap(true)

	return true
end

local function NoteWindow_SetShadowComment(self,val)
	if val then
		MRT.lib.AddShadowComment(self,nil,L.message)
	else
		MRT.lib.AddShadowComment(self,1)
	end
end

local function NoteWindow_UpdateVisual(self)
	self:ClearAllPoints()
	if VMRT.Note[self.Name.."Left"] and VMRT.Note[self.Name.."Top"] then
		self:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",VMRT.Note[self.Name.."Left"],VMRT.Note[self.Name.."Top"])
	else
		self:SetPoint("TOPLEFT",UIParent,"CENTER",-150,250)
	end

	self:SetSize(VMRT.Note[self.Name.."Width"] or 300,VMRT.Note[self.Name.."Height"] or 200)

	if VMRT.Note.Alpha then
		self:SetAlpha(VMRT.Note.Alpha/100)
	else
		self:SetAlpha(1)
	end
	if VMRT.Note.Scale then
		self:SetScale(VMRT.Note.Scale/100)
	else
		self:SetScale(1)
	end
	if VMRT.Note.ScaleBack then
		MRT_SetSolidColor(self.background,0,0,0,VMRT.Note.ScaleBack/100)
	else
		MRT_SetSolidColor(self.background,0,0,0,1)
	end
	if VMRT.Note.Fix then
		self:SetMovable(false)
		self:EnableMouse(false)
		self.buttonResize:Hide()
	else
		self:SetMovable(true)
		self:EnableMouse(true)
		self.buttonResize:Show()
		self:SetShadowComment(true)
	end

	if VMRT.Note.Strata and MRT.F.table_find(frameStrataList,VMRT.Note.Strata) then
		self:SetFrameStrata(VMRT.Note.Strata)
	end
end

local function NoteWindow_Enable(self)
	self.Show = self._Show
	self:Show()
end
local function NoteWindow_Disable(self)
	self.Show = self.Hide
	self:Hide()
end

local function NoteWindow_ScaleFix(self,val)
	MRT.F.SetScaleFix(self,val)
end

local function NoteWindow_Custom_OnEvent(self,event,...)
	if event == "MODIFIER_STATE_CHANGED" and self:IsShown() and not InCombatLockdown() then
		local key,state = ...
		if key == "LSHIFT" then
			if state == 1 then
				self:EnableMouse(true)
				self:SetPassThroughButtons("LeftButton")
				self.mouseOn = true
			else
				if VMRT.Note.Fix then
					self:EnableMouse(false)
				end
				self:SetPassThroughButtons()
				self.mouseOn = false
			end
		end
	end
end

local function NoteWindow_Custom_OnMouseDown(self,button)
	if self.mouseOn and IsShiftKeyDown() and button == "RightButton" then
		self:Disable()
		if VMRT.Note.Fix then
			self:EnableMouse(false)
		end
		self.mouseOn = false
	end
end

local function NoteWindow_RawNull()
	return ""
end


local allWindows = {}

function module:CreateNoteWindow(windowName,isCustomWindow)
	windowName = windowName or ""

	local frame = CreateFrame("Frame","MRTNote"..windowName,UIParent)
	frame.Name = windowName
	frame:SetSize(200,100)
	frame:SetPoint("CENTER",UIParent, "CENTER", 0, 0)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", NoteWindow_OnDragStart)
	frame:SetScript("OnDragStop", NoteWindow_OnDragStop)
	frame:SetFrameStrata("HIGH")
	frame:SetResizable(true)
	frame:SetResizeBounds(30, 30, 2000, 2000)
	frame:SetScript("OnSizeChanged", NoteWindow_OnSizeChanged)
	frame:Hide()
	frame._Show = frame.Show

	if isCustomWindow then
		frame:RegisterEvent"MODIFIER_STATE_CHANGED"
		frame:SetScript("OnEvent",NoteWindow_Custom_OnEvent)
		frame:SetScript("OnMouseDown",NoteWindow_Custom_OnMouseDown)
	end


	frame.SetShadowComment = NoteWindow_SetShadowComment
	frame.UpdateVisual = NoteWindow_UpdateVisual
	frame.Enable = NoteWindow_Enable
	frame.Disable = NoteWindow_Disable
	frame.ScaleFix = NoteWindow_ScaleFix
	frame.UpdateMaxSymbolsLimit = NoteWindow_UpdateMaxSymbolsLimit

	frame.GetRawText = NoteWindow_RawNull

	frame.sf = CreateFrame("ScrollFrame", nil, frame)
	frame.sf:SetPoint("TOPLEFT",0,0)
	frame.sf:SetAllPoints()
	frame.sf.C = CreateFrame("Frame", nil, frame.sf)
	frame.sf:SetScrollChild(frame.sf.C)
	frame.sf.C:SetSize(200,20000)
	frame.sf:Hide()

	ELib:FixPreloadFont(frame,function()
		if VMRT then
			frame.text:SetFont(GameFontWhite:GetFont(),11,"")
			frame:UpdateFont()
			return true
		end
	end)

	frame.UpdateFont = NoteWindow_UpdateFont

	MRT.F:RegisterCallback("CallbackRegistered", function(_,eventName)
		if eventName == "Note_UpdateText" then
			frame:UpdateText()
		end
	end)
	MRT.F:RegisterCallback("CallbackUnregistered", function(_,eventName,_,callbacks)
		if callbacks ~= 0 then
			return
		elseif eventName == "Note_UpdateText" then
			frame:UpdateText()
		end
	end)

	frame.UpdateText = NoteWindow_UpdateText
	frame.ShowGlow = NoteWindow_ShowGlow
	frame.HideGlow = NoteWindow_HideGlow


	frame.background = frame:CreateTexture(nil, "BACKGROUND")
	MRT_SetSolidColor(frame.background,0,0,0,1)
	frame.background:SetAllPoints()

	frame.text = frame:CreateFontString(nil,"ARTWORK")
	frame.text.mf = frame
	frame.text:SetFont(MRT.F.defFont, 12, "")
	frame.text:SetPoint("TOPLEFT",5,-5)
	frame.text:SetPoint("TOPRIGHT",-5,-5)
	frame.text:SetJustifyH("LEFT")
	frame.text:SetJustifyV("TOP")
	frame.text:SetText(" ")

	frame.text.FixLag = NoteWindow_TextFixLag

	frame.sf:Show()
	frame.text:FixLag()

	frame.text:SetNonSpaceWrap(true)

	frame.text.Add = NoteWindow_TextAdd

	frame.buttonResize = CreateFrame("Frame",nil,frame)
	frame.buttonResize:SetSize(15,15)
	frame.buttonResize:SetPoint("BOTTOMRIGHT", 0, 0)
	frame.buttonResize:EnableMouse(true)
	frame.buttonResize:SetFrameStrata("DIALOG")
	frame.buttonResize:SetFrameLevel((frame:GetFrameLevel() or 1) + 50)
	frame.buttonResize.back = frame.buttonResize:CreateTexture(nil, "BACKGROUND")
	frame.buttonResize.back:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\Resize.tga")
	frame.buttonResize.back:SetAllPoints()
	frame.buttonResize:SetScript("OnMouseDown", function(self)
		if frame.SetResizable then frame:SetResizable(true) end
		if frame.StartSizing then
			frame:StartSizing("BOTTOMRIGHT")
		end
	end)
	frame.buttonResize:SetScript("OnMouseUp", function(self)
		frame:StopMovingOrSizing()
	end)

	frame.red_back = CreateFrame("Frame",nil,frame)
	frame.red_back:SetPoint("TOPLEFT",0,0)
	frame.red_back:SetPoint("BOTTOMRIGHT",0,0)
	frame.red_back.b = frame.red_back:CreateTexture(nil, "BACKGROUND", nil, 1)
	MRT_SetSolidColor(frame.red_back.b,1,0,0,.2)
	frame.red_back.b:SetAllPoints()
	frame.red_back.s = ELib:Shadow(frame.red_back,20)
	frame.red_back.s:SetBackdropBorderColor(1, 0, 0, .2)
	frame.red_back:Hide()
	local red_back_t = 1
	frame.red_back:SetScript("OnShow",function()
		red_back_t = 3
	end)
	frame.red_back:SetScript("OnUpdate",function(self,tmr)
		red_back_t = red_back_t - tmr
		if red_back_t <= 0 then
			self:Hide()
			return
		end
		self.s:SetBackdropBorderColor(1, 0, 0, max(0, .4 * min(2,red_back_t)/2))
		MRT_SetSolidColor(self.b,1,0,0,max(0, .4 * min(2,red_back_t)/2))
	end)

	allWindows[#allWindows+1] = frame

	return frame
end

module.frame = module:CreateNoteWindow()
module.frame.GetRawText = function()
	if VMRT.Note.ShowOnlyPersonal then
		return "{self}"
	elseif VMRT.Note.PersonalWindow then
		return VMRT.Note.Text1 or ""
	elseif type(VMRT.Note.Text1)=="string" and not VMRT.Note.Text1:find("{self}") then
		return (VMRT.Note.Text1) .. (VMRT.Note.Text1~="" and VMRT.Note.Text1~=" " and "\n" or "") .. "{self}"
	else
		return VMRT.Note.Text1 or ""
	end
end

module.frame_personal = module:CreateNoteWindow("Personal")
module.frame_personal.GetRawText = function()
	return "{self}"
end

local window_count = 0
function module:AddWindow(blackNoteID,forceWindowID)
	if not blackNoteID then
		return
	end
	if forceWindowID and (type(forceWindowID) ~= "number" or forceWindowID > 20) then
		forceWindowID = nil
	end
	local w
	for i=1,#allWindows do
		local window = allWindows[i]
		if forceWindowID and window.Name == tostring(forceWindowID) then
			w = window
			break
		elseif not forceWindowID and window.bID == blackNoteID and window:IsShown() then
			w = window
			break
		elseif not forceWindowID and tonumber(window.Name) and not window:IsShown() and not w then
			w = window
		end
	end
	if not w then
		if forceWindowID then
			repeat
				window_count = window_count + 1
				w = module:CreateNoteWindow(tostring(window_count),true)
				w:UpdateVisual()
			until (window_count - 1) == forceWindowID
		end
		window_count = window_count + 1
		w = module:CreateNoteWindow(tostring(window_count),true)
		w:UpdateVisual()
	end
	w.bID = blackNoteID
	w.GetRawText = function()
		return VMRT.Note.Black[blackNoteID] or ""
	end
	w:UpdateText()
	w:Enable()
	w.red_back:Show()
end

function module:IsWindowOpenedForDraft(blackNoteID)
	for i=1,#allWindows do
		local window = allWindows[i]
		if window.bID == blackNoteID then
			return window
		end
	end
end

module.allframes = {}
setmetatable(module.allframes, {__index = function(table, key)
	if not allWindows[1][key] then
		return
	end
	if type(allWindows[1][key]) == "function" then
		return function(_, ...)
			for i=1,#allWindows do
				allWindows[i][key](allWindows[i],...)
			end
		end
	else
		local nt = {}
		setmetatable(nt,{__index = function(_, key2)
			return function(_, ...)
				for i=1,#allWindows do
					allWindows[i][key][key2](allWindows[i][key],...)
				end
			end
		end})
		return nt
	end
end})

module.db.History = {}
function module:AddHistory(text, index)
	if not text or index == -2 or not index or text:trim() == "" or module.db.HistoryLock then
		return
	end
	if not (module.db.History[1] and module.db.History[1].index == index) then
		tinsert(module.db.History, 1, {text = text, index = index, time = GetTime(), bossID = VMRT.Note.AutoLoad[0], name = VMRT.Note.DefName})
	end
	module.db.History[1].text = text

	for i=11,#module.db.History do
		module.db.History[i] = nil
	end
end
function module:ModHistory(index, data)
	if not module.db.History[1] or module.db.History[1].index ~= index or module.db.HistoryLock then
		return
	end
	for k,val in pairs(data) do
		if val == -1 then
			module.db.History[1][k] = nil
		else
			module.db.History[1][k] = val
		end
	end
end
function module:SaveText(text, index)
  	VMRT.Note.Text1 = text

	module:AddHistory(text, index)
end

function module.frame:SetTo(blackNoteID)
	module:SaveText(blackNoteID and VMRT.Note.Black[blackNoteID] or VMRT.Note.Text1 or "")

	if blackNoteID then
		VMRT.Note.AutoLoad[0] = VMRT.Note.AutoLoad[blackNoteID]
		VMRT.Note.DefName = VMRT.Note.BlackNames[blackNoteID]
		if VMRT.Note.DefName then
			VMRT.Note.DefName = VMRT.Note.DefName:gsub("%*$","")
		end

		module:ModHistory(nil, {bossID = VMRT.Note.AutoLoad[0], name = VMRT.Note.DefName})
	end

	module.allframes:UpdateText()
	module.frame:UpdateOptionsText()
end

function module.frame:Save(blackNoteID)
	module.frame:SetTo(blackNoteID)

	MRT.F:FireCallback("Note_SendText",VMRT.Note.Text1)

	if #VMRT.Note.Text1 == 0 then
		VMRT.Note.Text1 = " "
	end
	local txttosand = VMRT.Note.Text1
	local arrtosand = {}
	local j = 1
	local indextosnd = tostring(GetTime())..tostring(math.random(1000,9999))
	for i=1,#txttosand do
		if i%220 == 0 then
			arrtosand[j]=string.sub (txttosand, (j-1)*220+1, j*220)
			j = j + 1
		elseif i == #txttosand then
			arrtosand[j]=string.sub (txttosand, (j-1)*220+1)
			j = j + 1
		end
	end
	local encounterID = VMRT.Note.AutoLoad[blackNoteID or 0] or "-"
	local noteName = (blackNoteID and VMRT.Note.BlackNames[blackNoteID]) or (not blackNoteID and VMRT.Note.DefName) or ""

	-- 3.3.5a: addon messages MUST be spaced out. Sending all chunks in one frame
	-- trips the server-side anti-flood, which silently drops one (or more) chunks.
	-- The receiver just concatenates whatever arrived (no per-chunk index/integrity
	-- check), so a whole ~220-char chunk goes missing mid-note. Pace the sends.
	local SEND_DELAY = 0.15
	local total = #arrtosand
	if total >= 10 and module.options.buttonsend then
		module.options.buttonsend:Disable()
		C_Timer.After((total+1)*SEND_DELAY,function()
			if module.options.buttonsend then module.options.buttonsend:Enable() end
		end)
	end
	for i=1,total do
		local idx = i
		C_Timer.After((idx-1)*SEND_DELAY,function()
			MRT.F.SendExMsg("multiline",indextosnd.."\t"..arrtosand[idx])
		end)
	end
	C_Timer.After(total*SEND_DELAY,function()
		MRT.F.SendExMsg("multiline_add",MRT.F.CreateAddonMsg(indextosnd,encounterID,noteName))
	end)
end

function module.frame:Clear()
	module.options.NoteEditBox.EditBox:SetText("")
end

function module.frame:UpdateOptionsText(onlyPage)
	if module.options.NoteEditBox then
		if module.options.IsMainNoteNow and not onlyPage then
			module.options.NoteEditBox.EditBox:SetText(VMRT.Note.Text1)
		end

		if VMRT.Note.LastUpdateName then
			module.options.lastUpdate:SetText( L.NoteLastUpdate..": "..VMRT.Note.LastUpdateName.." ("..date("%H:%M:%S %d.%m.%Y",VMRT.Note.LastUpdateTime or 0)..")" )
		else
			module.options.lastUpdate:SetText( "" )
		end

		module.options.UpdatePageAfterGettingNote()
	end
end

-- Single, full repaint of a received note. Heavy (re-parses text, repositions
-- all markers), so we run it once per transfer instead of once per chunk.
function module:DoReceivedRender()
	MRT.F:FireCallback("Note_ReceivedText",VMRT.Note.Text1)
	module.allframes:UpdateText()
	module.frame:UpdateOptionsText()
	if type(WeakAuras)=="table" and WeakAuras.ScanEvents and type(WeakAuras.ScanEvents)=="function" then
		WeakAuras.ScanEvents("EXRT_NOTE_UPDATE")
		WeakAuras.ScanEvents("MRT_NOTE_UPDATE")
	end
end

-- Debounced repaint: each arriving chunk reschedules, so the note is painted
-- once the transfer settles. Keeps loading smooth instead of "jumpy".
function module:ScheduleReceivedRender()
	module._renderToken = (module._renderToken or 0) + 1
	local token = module._renderToken
	C_Timer.After(0.25,function()
		if module._renderToken ~= token then return end
		module:DoReceivedRender()
	end)
end

-- Immediate repaint (finalizer arrived) + cancel any pending debounced one.
function module:ForceReceivedRender()
	module._renderToken = (module._renderToken or 0) + 1
	module:DoReceivedRender()
end

function module:addonMessage(sender, prefix, ...)
	if prefix == "multiline" then
		if VMRT.Note.OnlyPromoted and IsInRaid() and MRT.F.IsPlayerRLorOfficer(sender) == false then
			return
		end

		VMRT.Note.LastUpdateName = sender
		VMRT.Note.LastUpdateTime = time()

		local msgnowindex,lastnowtext = ...
		if tostring(msgnowindex) == tostring(module.db.msgindex) then
			module.db.lasttext = module.db.lasttext .. lastnowtext
		else
			module.db.lasttext = lastnowtext
		end
		module.db.msgindex = msgnowindex
		module:SaveText(module.db.lasttext, module.db.msgindex)
		module:ModHistory(module.db.msgindex, {bossID = -1, name = -1})
		VMRT.Note.AutoLoad[0] = nil
		VMRT.Note.DefName = nil
		if VMRT.Note.EnableWhenReceive and not VMRT.Note.enabled then
			module:Enable()
		end
		module.allframes.red_back:Show()
		-- 3.3.5a: chunks now arrive spaced out (anti-flood). Painting on every
		-- chunk made loading look jumpy - debounce a single repaint once the
		-- transfer settles. The multiline_add finalizer forces it immediately.
		module:ScheduleReceivedRender()
	elseif prefix == "multiline_add" then
		if VMRT.Note.OnlyPromoted and IsInRaid() and MRT.F.IsPlayerRLorOfficer(sender) == false then
			return
		end
		local msgIndex,encounterID,noteName = ...
		if tostring(msgIndex) ~= tostring(module.db.msgindex) then
			return
		end
		encounterID = tonumber(encounterID)
		if noteName == "" then noteName = nil end
		VMRT.Note.AutoLoad[0] = encounterID
		VMRT.Note.DefName = noteName
		module.frame:UpdateOptionsText(true)
		module:ModHistory(module.db.msgindex, {bossID = VMRT.Note.AutoLoad[0] or -1, name = VMRT.Note.DefName or -1})
		if sender == MRT.SDB.charKey then
			return
		end
		module:ForceReceivedRender()
		if VMRT.Note.SaveAllNew then
			local finded = false
			if noteName then
				noteName = noteName:gsub("%*+$","").."*"
				for i=1,#VMRT.Note.Black do
					if VMRT.Note.BlackNames[i] == noteName and VMRT.Note.AutoLoad[i] == encounterID then
						VMRT.Note.Black[i] = VMRT.Note.Text1
						VMRT.Note.AutoLoad[i] = encounterID
						VMRT.Note.BlackLastUpdateName[i] = sender
						VMRT.Note.BlackLastUpdateTime[i] = time()
						finded = true
						if module:IsWindowOpenedForDraft(i) then
							module.allframes:UpdateText()
						end
						break
					end
				end
			elseif encounterID then
				for i=1,#VMRT.Note.Black do
					if VMRT.Note.AutoLoad[i] == encounterID and (not VMRT.Note.BlackNames[i] or VMRT.Note.BlackNames[i] == "") then
						VMRT.Note.Black[i] = VMRT.Note.Text1
						VMRT.Note.BlackLastUpdateName[i] = sender
						VMRT.Note.BlackLastUpdateTime[i] = time()
						finded = true
						if module:IsWindowOpenedForDraft(i) then
							module.allframes:UpdateText()
						end
						break
					end
				end

			end
			if not finded then
				local newIndex = #VMRT.Note.Black + 1
				VMRT.Note.Black[newIndex] = VMRT.Note.Text1
				VMRT.Note.AutoLoad[newIndex] = encounterID
				VMRT.Note.BlackNames[newIndex] = noteName
				VMRT.Note.BlackLastUpdateName[newIndex] = sender
				VMRT.Note.BlackLastUpdateTime[newIndex] = time()
				if module.options.NotesListUpdateNames then
					module.options.NotesListUpdateNames()
				end
			end
		end
		if module.options.UpdatePageAfterGettingNote then
			module.options.UpdatePageAfterGettingNote()
		end
	elseif prefix == "multiline_timer_sync" then
		local name = ...
		MRT.F.Note_Timer(name)
	end
end

NewVMRTTableData = {
	OnlyPromoted = true,
	OptionsFormatting = true,
	Strata = "HIGH",
}

local isFirstLoad

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.Note = VMRT.Note or MRT.F.table_copy2(NewVMRTTableData)

	VMRT.Note.Profiles = VMRT.Note.Profiles or {}
	VMRT.Note.Profiles.List = VMRT.Note.Profiles.List or {}
	VMRT.Note.Profiles.Now = VMRT.Note.Profiles.Now or "default"

	VMRT.Note.Black = VMRT.Note.Black or {}
	VMRT.Note.AutoLoad = VMRT.Note.AutoLoad or {}

	VMRT.Note.FontSize = VMRT.Note.FontSize or 12

	VMRT.Note.Strata = VMRT.Note.Strata or "HIGH"

	VMRT.Note.BlackNames = VMRT.Note.BlackNames or {}

	for i=1,3 do
		VMRT.Note.Black[i] = VMRT.Note.Black[i] or ""
	end

	VMRT.Note.BlackLastUpdateName = VMRT.Note.BlackLastUpdateName or {}
	VMRT.Note.BlackLastUpdateTime = VMRT.Note.BlackLastUpdateTime or {}

	if not VMRT.Note.CustomRoster then
		VMRT.Note.CustomRoster = {}
	end

	if VMRT.Note.enabled then
		module:Enable()
	else
		module:Disable()
	end
	C_Timer.After(5,function()
		module.allframes:UpdateFont()
	end)

	if VMRT.Note.Text1 then
		module.allframes:UpdateText()
	end
	module:SaveText(VMRT.Note.Text1, -1)

	module:RegisterAddonMessage()
	module:RegisterSlash()

	module.allframes:UpdateVisual()

	module:RegisterEvents('ZONE_CHANGED_NEW_AREA','PLAYER_SPECIALIZATION_CHANGED')
	if not isFirstLoad then
		isFirstLoad = true
		C_Timer.After(2,module.CheckZoneProfiles)
		C_Timer.After(2,function() module.main:PLAYER_TALENT_UPDATE() end)
	end
end

function module.main:PLAYER_LOGIN()
	if VMRT.Note.enabled then
		module.allframes:UpdateText()
	end
end


function module:Enable()
	VMRT.Note.enabled = true
	if module.options.chkEnable then
		module.options.chkEnable:SetChecked(true)
	end
	module:RegisterEvents("PLAYER_LOGIN","ENCOUNTER_END","ENCOUNTER_START","GROUP_ROSTER_UPDATE")
	if VMRT.Note.HideInCombat then
		module:RegisterEvents('PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED')
	end
	if VMRT.Note.PersonalWindow then
		module.frame_personal:Enable()
	else
		module.frame_personal:Disable()
	end
	if VMRT.Note.EnableBossAutoLoad then
		module:RegisterEvents('ZONE_CHANGED','ZONE_CHANGED_INDOORS')
	end
	module:Visibility()
	GSUB_AutoColorCreate()
end

function module:Disable()
	VMRT.Note.enabled = nil
	if module.options.chkEnable then
		module.options.chkEnable:SetChecked(false)
	end
	module:UnregisterEvents('PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED',"PLAYER_LOGIN","ENCOUNTER_END","ENCOUNTER_START",'ZONE_CHANGED')
	module:Visibility()
end

local Note_CombatState = false

function module:Visibility()
	local bool = true
	if not VMRT.Note.enabled then
		bool = bool and false
	end
	if bool and VMRT.Note.HideOutsideRaid then
		if GetNumGroupMembers() > 0 then
			bool = bool and true
		else
			bool = bool and false
		end
	end
	if bool and VMRT.Note.HideInCombat then
		if Note_CombatState then
			bool = bool and false
		else
			bool = bool and true
		end
	end
	if bool and VMRT.Note.ShowOnlyInRaid then
		local _,zoneType = IsInInstance()
		if zoneType == "raid" then
			bool = bool and true
		else
			bool = bool and false
		end
	end

	if bool then
		module.allframes:Show()
	else
		module.allframes:Hide()
	end
end

local party_uids = {'player','party1','party2','party3','party4'}
function module.main:GROUP_ROSTER_UPDATE()
	C_Timer.After(1, module.Visibility)
	GSUB_AutoColorCreate()
	if VMRT.Note.enabled and module.frame:IsShown() then
		module.allframes:UpdateText()
	end
	if not module.options.raidnames or not module.options:IsVisible() then
		return
	end
	module.options:UpdateRoster()
end
function module.main:PLAYER_REGEN_DISABLED()
	Note_CombatState = true
	module:Visibility()
end
function module.main:PLAYER_REGEN_ENABLED()
	Note_CombatState = false
	module:Visibility()
end

function module.main:ZONE_CHANGED_NEW_AREA()
	C_Timer.After(1,module.CheckZoneProfiles)

	module.main:ZONE_CHANGED()

	if VMRT.Note.enabled and VMRT.Note.ShowOnlyInRaid then
		C_Timer.After(5, module.Visibility)
	end
end

function module.main:PLAYER_SPECIALIZATION_CHANGED(unit)
	if VMRT.Note.enabled and unit == "player" then
		module.allframes:UpdateText()
	end

	if unit ~= "player" or not GetSpecialization then
		return
	end

	local spec = GetSpecialization()
	if not spec then
		return
	end

	local class = (select(2,UnitClass'player')) or ""

	local key = "Spec" .. spec .. class
	if VMRT.Note.Profiles[key] then
		module:SelectProfile(VMRT.Note.Profiles[key])
	end
end

function module.main:PLAYER_TALENT_UPDATE(unit)
	module.main:PLAYER_SPECIALIZATION_CHANGED("player")
end


local SubzoneTextToBossID = MRT.Data.SubzoneTextToBossID or {}
local locale = GetLocale()
SubzoneTextToBossID = SubzoneTextToBossID[locale or "enUS"] or SubzoneTextToBossID.enUS or {}


local SubzoneBossIDInctanceReq = MRT.Data.SubzoneBossIDInctanceReq or {}

local function LoadNoteForBossID(bossID)
	if not bossID then return end
	if SubzoneBossIDInctanceReq[bossID] and select(8,GetInstanceInfo()) ~= SubzoneBossIDInctanceReq[bossID] then
		return
	end

	if not VMRT.Note.BossAutoLoadPersonal and VMRT.Note.AutoLoad[0] == bossID then
		return
	end
	local noteID

	if VMRT.Note.BossAutoLoadType == 1 then
		for i=1,#VMRT.Note.Black do
			if VMRT.Note.AutoLoad[i] == bossID then
				noteID = i
				break
			end
		end
	elseif VMRT.Note.BossAutoLoadType == 2 then
		for i=#VMRT.Note.Black,1,-1 do
			if VMRT.Note.AutoLoad[i] == bossID then
				noteID = i
				break
			end
		end
	elseif (VMRT.Note.BossAutoLoadType or 3) == 3 then
		local lastupd, nid = 0
		for i=1,#VMRT.Note.Black do
			if VMRT.Note.AutoLoad[i] == bossID and (VMRT.Note.BlackLastUpdateTime[i] or 0)>lastupd then
				lastupd = VMRT.Note.BlackLastUpdateTime[i]
				nid = i
			end
		end
		if nid then
			noteID = nid
		end
	end

	if noteID then
		if VMRT.Note.BossAutoLoadPersonal then
			VMRT.Note.SelfText = VMRT.Note.Black[noteID]

			module.allframes:UpdateText()
			module.frame:UpdateOptionsText()
		elseif VMRT.Note.BossAutoLoadSendAsRL and ((UnitIsGroupLeader and UnitIsGroupLeader("player")) or MRT.F.IsPlayerRLorOfficer(UnitName("player")) == 2) then
			module.frame:Save(noteID)
		else
			module.frame:SetTo(noteID)
		end
	end
end

local function CheckSubZone()
	if module.db.isEncounter then
		return
	end
	local zoneText = GetSubZoneText()

	if zoneText then
		local bossID = SubzoneTextToBossID[zoneText]
		LoadNoteForBossID(bossID)
	end
end

local function CheckBossName(name)
	if not VMRT.Note.EnableBossAutoLoad then return end
	if not name or name == "" then return end
	LoadNoteForBossID(name)
end
module.CheckBossName = CheckBossName

function module.main:ZONE_CHANGED()
	if not VMRT.Note.EnableBossAutoLoad then return end

	C_Timer.After(1,CheckSubZone)
end
module.main.ZONE_CHANGED_INDOORS = module.main.ZONE_CHANGED


do
	local ResetCLEUData
	local currPhase = 1
	local currGlobalPhase = 1

	module.db.encounter_global_stage = 1

	function module.main:SetPhase(stage, globalStage)
		wipe(encounter_time_p)
		local t = GetTime()
		encounter_time_p[stage] = t
		encounter_time_p[tostring(stage)] = t
		currPhase = stage
		ResetCLEUData(true)
		if globalStage then
			encounter_time_p["g"..tostring(globalStage)] = t
			currGlobalPhase = globalStage
		else
			currGlobalPhase = currGlobalPhase + 1
			encounter_time_p["g"..tostring(currGlobalPhase)] = t
		end
		if module.frame:IsShown() then
			module.allframes:UpdateText()
		end
	end

	local BossPhasesBossmodAdded
	local function BossPhasesBossmod()
		if BossPhasesBossmodAdded then
			return
		end
		if type(BigWigsLoader)=='table' and BigWigsLoader.RegisterMessage then
			BigWigsLoader.RegisterMessage({}, "BigWigs_SetStage", function(event, addon, stage)
				if stage then
					if module.db.encounter_time and GetTime() - module.db.encounter_time < 2 then return end

					module.main:SetPhase(stage)
				end
			end)

			BossPhasesBossmodAdded = true
		elseif type(DBM)=='table' and DBM.RegisterCallback then
			DBM:RegisterCallback("DBM_SetStage", function(event, addon, modId, stage, encounterId, globalStage)
				if stage then
					module.main:SetPhase(stage, globalStage)
				end
			end)

			BossPhasesBossmodAdded = true
		end
	end

	local phaseCombatEvents = {}
	function module.main:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
		module.db.isEncounter = encounterID
		if encounterName and encounterName ~= "" then
			CheckBossName(encounterName)
		end
		local noteText = (VMRT.Note.Text1 or "")..(VMRT.Note.SelfText or "")
		if encounterID and encounterName then
			encounter_id[tostring(encounterID)] = true
			encounter_id[encounterName] = true
		end
		local timeInText = noteText:find("{time:([0-9:]+[^{}]*)}")
		local phaseInText = noteText:find("{[Pp]([^}:][^}]*)}(.-){/[Pp]}")
		if timeInText or (phaseInText and ((type(BigWigsLoader)=='table') or (type(DBM)=='table'))) then
			wipe(encounter_time_c)
			wipe(encounter_time_wa_uids)
			module.db.encounter_time = GetTime()
			-- Manual simulation (no real encounterID, e.g. /mrt note timer): auto-stop
			-- once the last note event has elapsed, instead of requiring a 2nd command.
			-- Real boss fights (encounterID set) are untouched - they end on ENCOUNTER_END.
			if not encounterID then
				local maxT = 0
				for m,s,opts in noteText:gmatch("{time:(%d+):(%d+)([^}]*)}") do
					if not opts:find(",[epS]") then  -- skip event/phase/counter-relative lines
						local t = (tonumber(m) or 0)*60 + (tonumber(s) or 0)
						if t > maxT then maxT = t end
					end
				end
				module.db.simTimer = true
				module.db.simTimerEnd = maxT > 0 and (module.db.encounter_time + maxT + 3) or nil
			else
				module.db.simTimer = nil
				module.db.simTimerEnd = nil
			end
			encounter_time_p[1] = module.db.encounter_time
			encounter_time_p["1"] = module.db.encounter_time
			currPhase = 1
			currGlobalPhase = 1
			BossPhasesBossmod()

			ResetCLEUData()

			if timeInText then
				module:RegisterTimer()
			end

			local anyEvent
			string_gsub(noteText,"{time:[0-9:]+[^}]*,(S[^{},]+)[,}]",function(str)
				local event,spellID,count,name,phase = strsplit(":",str)
				if tonumber(count or "") and tonumber(spellID or "") and event and module.db.encounter_counters[event] then
					anyEvent = true
					module.db.encounter_counters[event][tonumber(spellID)] = 0
					if name and name ~= "" then
						if not module.db.encounter_counters[event].name[name] then
							module.db.encounter_counters[event].name[name] = {}
						end
						module.db.encounter_counters[event].name[name][tonumber(spellID)] = 0
					end
				end
			end)
			wipe(phaseCombatEvents)
			string_gsub(noteText,"{[Pp],(S[^{},]+),?(S?[^{},]*)[,}]",function(str1,str2)
				for _,str in pairs({str1,str2}) do
					if str ~= "" then
						local event,spellID,count = strsplit(":",str)
						if tonumber(count or "") and tonumber(spellID or "") and event and module.db.encounter_counters[event] then
							anyEvent = true
							module.db.encounter_counters[event][tonumber(spellID)] = 0
							phaseCombatEvents[str] = true
						end
					end
				end
			end)
			if anyEvent then
				wipe(module.db.encounter_counters_time)
				module:RegisterEvents("COMBAT_LOG_EVENT_UNFILTERED")
			end
		end
		module.allframes:UpdateText()
	end
	function module.main:ENCOUNTER_END()
		module.db.isEncounter = nil
		wipe(encounter_id)

		module:UnregisterTimer()
		module.db.encounter_time = nil
		module.db.simTimer = nil
		module.db.simTimerEnd = nil
		wipe(encounter_time_p)
		wipe(encounter_time_c)
		wipe(encounter_time_wa_uids)

		module:UnregisterEvents("COMBAT_LOG_EVENT_UNFILTERED")

		ResetCLEUData()
		module.allframes:UpdateText()
	end
	local tmr = 0
	function module:timer(elapsed)
		tmr = tmr + elapsed
		if tmr > 1 then
			tmr = 0
			-- auto-stop the manual simulation once the last note event has passed
			if module.db.simTimer and module.db.simTimerEnd and GetTime() >= module.db.simTimerEnd then
				module.main:ENCOUNTER_END()
				return
			end
			if module.frame:IsShown() then
				module.allframes:UpdateText(true)
			end
		end
	end

	module.db.encounter_counters_time = {}
	module.db.encounter_counters = {
		SCC = {},
		SCS = {},
		SAA = {},
		SAR = {},
	}
	function ResetCLEUData(only_phase_data)
		if not only_phase_data then
			wipe(module.db.encounter_counters.SCC)
			wipe(module.db.encounter_counters.SCS)
			wipe(module.db.encounter_counters.SAA)
			wipe(module.db.encounter_counters.SAR)
			wipe(module.db.encounter_counters_time)

			module.db.encounter_counters.SCC.name = {}
			module.db.encounter_counters.SCS.name = {}
			module.db.encounter_counters.SAA.name = {}
			module.db.encounter_counters.SAR.name = {}
		end

		module.db.encounter_counters.SCC.phase = {}
		module.db.encounter_counters.SCS.phase = {}
		module.db.encounter_counters.SAA.phase = {}
		module.db.encounter_counters.SAR.phase = {}
	end
	ResetCLEUData()
	local ECT = module.db.encounter_counters_time
	local SCC = module.db.encounter_counters.SCC
	local SCS = module.db.encounter_counters.SCS
	local SAA = module.db.encounter_counters.SAA
	local SAR = module.db.encounter_counters.SAR
	local function AddCounter(table,tableName,spellID,spellTarget)
		table[spellID] = table[spellID] + 1
		if spellTarget and table.name[spellTarget] then table.name[spellTarget][spellID] = table.name[spellTarget][spellID] + 1 end
		table.phase[spellID] = (table.phase[spellID] or 0) + 1

		local key_w_counter = tableName..":"..spellID..":"..table[spellID]
		local key_wo_counter = tableName..":"..spellID..":"..0
		local key_w_phase = tableName..":"..spellID..":"..(table.phase[spellID] or 0).."::p"..(currPhase or 1)
		local key_w_gphase = tableName..":"..spellID..":"..(table.phase[spellID] or 0).."::pg"..(currGlobalPhase or 1)
		local key_w_name
		if spellTarget then
			key_w_name = tableName..":"..spellID..":"..(table.name[spellTarget] and table.name[spellTarget][spellID] or 0)..":"..(spellTarget or "")
		end
		local t = GetTime()
		ECT[ key_w_counter ] = t
		ECT[ key_wo_counter ] = t
		ECT[ key_w_phase ] = t
		ECT[ key_w_gphase ] = t
		if key_w_name then ECT[ key_w_name ] = t end
		if phaseCombatEvents[key_w_counter] or phaseCombatEvents[key_wo_counter] then
			if module.frame:IsShown() then
				module.allframes:UpdateText()
			end
		end
	end

	function module.main.COMBAT_LOG_EVENT_UNFILTERED(_,event,_,_,sourceName,_,_,_,destName,_,_,spellID)
		if event == "SPELL_CAST_SUCCESS" then
			if SCC[spellID] then
				return AddCounter(SCC,"SCC",spellID,sourceName)
			end
		elseif event == "SPELL_CAST_START" then
			if SCS[spellID] then
				return AddCounter(SCS,"SCS",spellID,sourceName)
			end
		elseif event == "SPELL_AURA_APPLIED" then
			if SAA[spellID] then
				return AddCounter(SAA,"SAA",spellID,destName)
			end
		elseif event == "SPELL_AURA_REMOVED" then
			if SAR[spellID] then
				return AddCounter(SAR,"SAR",spellID,destName)
			end
		end
	end


	function MRT.F.Note_Timer(name)
		if not name then
			return
		end
		if not module.db.encounter_time then
			module.main:ENCOUNTER_START()
		end
		encounter_time_c[name] = GetTime()
	end
	function MRT.F.Note_SyncTimer(name)
		if not name then
			return
		end
		MRT.F.SendExMsg("multiline_timer_sync",name)
	end
end

do
	local IGNORE_PROFILE_KEYS = {
		["Profiles"] = true,
		["Black"] = true,
		["BlackNames"] = true,
		["BlackLastUpdateName"] = true,
		["BlackLastUpdateTime"] = true,
		["AutoLoad"] = true,
	}
	function module:SaveCurrentProfiletoDB()
		local profileName = VMRT.Note.Profiles.Now

		local saveDB = {}
		VMRT.Note.Profiles.List[ profileName ] = saveDB

		for key,val in pairs(VMRT.Note) do
			if not IGNORE_PROFILE_KEYS[key] then
				if type(val) == "table" then
					saveDB[key] = MRT.F.table_copy2(val)
				else
					saveDB[key] = val
				end
			end
		end
	end
	function module:SelectProfile(name)
		if name == VMRT.Note.Profiles.Now or not name then
			return
		end
		if not VMRT.Note.Profiles.List[name] then
			return
		end
		module:SaveCurrentProfiletoDB()

		local savedText
		if VMRT.Note.Profiles.KeepText then
			savedText = {
				Text1 = VMRT.Note.Text1,
				SelfText = VMRT.Note.SelfText,
			}
		end

		local savedKeys = {}
		for key in pairs(IGNORE_PROFILE_KEYS) do
			if VMRT.Note[key] then
				savedKeys[key] = VMRT.Note[key]
			end
		end
		MRT.F.table_rewrite(VMRT.Note,VMRT.Note.Profiles.List[name])
		for key,val in pairs(savedKeys) do
			VMRT.Note[key] = val
		end

		VMRT.Note.Profiles.Now = name

		if savedText then
			for k,v in pairs(savedText) do
				VMRT.Note[k] = v
			end
		end

		module:ReloadProfile()

		VMRT.Note.Profiles.List[name] = nil

		return true
	end
	function module:ReloadProfile()
		module.main:ADDON_LOADED()
		if module.options.UpdateOptions then
			module.options:UpdateOptions()
		end
	end

	function module:CheckZoneProfiles()
		local _, zoneType = GetInstanceInfo()

		if zoneType == "arena" then
			if VMRT.Note.Profiles.Arena then
				module:SelectProfile(VMRT.Note.Profiles.Arena)
			end
		elseif zoneType == "party" then
			if VMRT.Note.Profiles.Dung then
				module:SelectProfile(VMRT.Note.Profiles.Dung)
			end
		elseif zoneType == "raid" then
			if VMRT.Note.Profiles.Raid then
				module:SelectProfile(VMRT.Note.Profiles.Raid)
			end
		elseif zoneType == "pvp" then
			if VMRT.Note.Profiles.BG then
				module:SelectProfile(VMRT.Note.Profiles.BG)
			end
		else
			if VMRT.Note.Profiles.Other then
				module:SelectProfile(VMRT.Note.Profiles.Other)
			end
		end
	end
end


function module:slash(arg)
	if arg == "note" or arg == "n" then
		if VMRT.Note.enabled then
			module:Disable()
		else
			module:Enable()
		end
	elseif arg == "editnote" or arg == "edit note" then
		MRT.Options:Open(module.options)
	elseif arg == "note timer" then
		if module.db.encounter_time then
			module.main:ENCOUNTER_END()
			print('timer ended')
		else
			module.main:ENCOUNTER_START()
			print('timer started')
		end
	elseif arg and arg:find("^note starttimer ") then
		local timer = arg:match("^note starttimer (.-)$")
		if timer then
			MRT.F.Note_Timer(timer)
		end
	elseif arg and arg:find("^note synctimer ") then
		local timer = arg:match("^note synctimer (.-)$")
		if timer then
			MRT.F.Note_SyncTimer(timer)
		end
	elseif arg and arg:find("^note set ") then
		local name = arg:match("^note set (.-)$")
		if name then
			local nameNumber = tonumber(name)
			for i=1,#VMRT.Note.Black do
				local blackName = VMRT.Note.BlackNames[i]
				if (blackName and blackName:lower() == name) or (nameNumber == i) then
					module.frame:Save(i)
					return
				end
			end
		end
	elseif arg and arg:find("^note phase ") then
		local phase = arg:match("^note phase (.-)$")
		if phase then
			module.main:SetPhase(phase)
			print("Set phase",phase)
		end
	elseif arg and arg:find("^note show ") then
		local name = arg:match("^note show (.-)$")
		if name then
			local nameNumber = tonumber(name)
			for i=1,#VMRT.Note.Black do
				local blackName = VMRT.Note.BlackNames[i]
				if (blackName and blackName:lower() == name) or (nameNumber == i) then
					module:AddWindow(i)
				end
			end
		end
	elseif arg == "help" then
		print("|cff00ff00/rt note|r - hide/show note")
		print("|cff00ff00/rt editnote|r - open notes tab")
		print("|cff00ff00/rt note set |cffffff00NOTENAME|r|r - set & send note with NOTENAME name")
		print("|cff00ff00/rt note timer|r - simulate boss encounter start [for timers feature]")
		print("|cff00ff00/rt note starttimer |cffffff00TIMERNAME|r|r - start custom timer")
	end
end

function module:GetText(removeColors,removeExtraSpaces)
	local text = VMRT.Note.Text1 or ""
	if removeColors then
		text = text:gsub("|c........",""):gsub("|r","")
	end
	if removeExtraSpaces then
		text = text:gsub(" *\n","\n"):gsub(" *$",""):gsub(" +"," ")
	end
	return text
end
MRT.F.GetNote = module.GetText
