local GlobalAddonName, ExRT = ...

ExRT.F.FUNC_FILE_LOADED = true

do
	local listeners = {}
	function ExRT.F.registerEvent(name, fn)
		if type(name) ~= "string" or type(fn) ~= "function" then return end
		listeners[name] = listeners[name] or {}
		listeners[name][#listeners[name] + 1] = fn
	end
	function ExRT.F.fireEvent(name, ...)
		local list = listeners[name]
		if not list then return end
		for i = 1, #list do
			local ok, err = pcall(list[i], ...)
			if not ok and geterrorhandler then geterrorhandler()(err) end
		end
	end
end

local UnitName, GetTime, GetCursorPosition, UnitIsUnit = UnitName, GetTime, GetCursorPosition, UnitIsUnit
local select, floor, abs, tonumber, tostring, string_sub, string_find, string_len, bit_band, type, unpack, pairs, format, strsplit = select, floor, abs, tonumber, tostring, string.sub, string.find, string.len, bit.band, type, unpack, pairs, format, strsplit
local string_gsub, string_match = string.gsub, string.match
local RAID_CLASS_COLORS, COMBATLOG_OBJECT_TYPE_MASK, COMBATLOG_OBJECT_CONTROL_MASK, COMBATLOG_OBJECT_REACTION_MASK, COMBATLOG_OBJECT_AFFILIATION_MASK, COMBATLOG_OBJECT_SPECIAL_MASK = RAID_CLASS_COLORS, COMBATLOG_OBJECT_TYPE_MASK, COMBATLOG_OBJECT_CONTROL_MASK, COMBATLOG_OBJECT_REACTION_MASK, COMBATLOG_OBJECT_AFFILIATION_MASK, COMBATLOG_OBJECT_SPECIAL_MASK
local UnitGroupRolesAssigned = UnitGroupRolesAssigned or ExRT.NULLfunc
local GetRaidRosterInfo = GetRaidRosterInfo
local GetItemInfo, GetItemInfoInstant  = C_Item and C_Item.GetItemInfo or GetItemInfo,  C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo
local SendChatMessage = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage

if not GetSpecialization and ExRT.isClassic then
	GetSpecialization = function()
		local n,m = 1,1
		for spec=1,3 do
			local selectedNum = 0
			for talPos=1,22 do
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = (GetTalentInfoClassic or GetTalentInfo)(spec, talPos)
				if name and maxRank > 0 and rank > 0 then
					selectedNum = selectedNum + 1
				end
			end
			if selectedNum > m then
				n = spec
				m = selectedNum
			end
		end
		return n
	end
end

do
	local antiSpamArr = {}
	function ExRT.F.AntiSpam(numantispam,addtime)
		local t = GetTime()
		if not antiSpamArr[numantispam] or antiSpamArr[numantispam] < t then
			antiSpamArr[numantispam] = t + addtime
			return true
		else
			return false
		end
	end
	function ExRT.F.ResetAntiSpam(numantispam)
		antiSpamArr[numantispam] = nil
	end
end

do


	local classColorArray = nil
	function ExRT.F.classColor(class)
		classColorArray = type(CUSTOM_CLASS_COLORS)=="table" and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		if classColorArray and classColorArray.colorStr then
			return classColorArray.colorStr
		else
			return "ffbbbbbb"
		end
	end

	function ExRT.F.classColorNum(class)
		classColorArray = type(CUSTOM_CLASS_COLORS)=="table" and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		if classColorArray then
			return classColorArray.r,classColorArray.g,classColorArray.b
		else
			return 0.8,0.8,0.8
		end
	end

	function ExRT.F.GetPlayerInfoByGUIDSafe(guid)
		if type(guid) ~= "string" or guid == "" or guid:match("^0x?0+$") then
			return nil
		end
		local ok, a, b, c, d, e, f, g = pcall(GetPlayerInfoByGUID, guid)
		if not ok then return nil end
		return a, b, c, d, e, f, g
	end

	function ExRT.F.classColorByGUID(guid)
		local class = ""
		local _, c = ExRT.F.GetPlayerInfoByGUIDSafe(guid)
		class = c or ""
		return ExRT.F.classColor(class)
	end
end

function ExRT.F.clearTextTag(text,SpellLinksEnabled)
	if text then
		text = string_gsub(text,"|c........","")
		text = string_gsub(text,"|r","")
		text = string_gsub(text,"|T.-:0|t ","")
		text = string_gsub(text,"|HExRT:.-|h(.-)|h","%1")
		if SpellLinksEnabled then
			text = string_gsub(text,"|H(spell:.-)|h(.-)|h","|cff71d5ff|H%1|h[%2]|h|r")
		else
			text = string_gsub(text,"|H(spell:.-)|h(.-)|h","%2")
		end
		return text
	end
end

function ExRT.F.splitLongLine(text,maxLetters,SpellLinksEnabled)
	maxLetters = maxLetters or 250
	local result = {}
	repeat
		local lettersNow = maxLetters
		if SpellLinksEnabled then
			local lastC = 0
			local lastR = 0
			for i=1,(maxLetters-1) do
				local word = string.sub(text,i,i+1)
				if word == "|c" then
					lastC = i
				elseif word == "|r" then
					lastR = i
				end
			end
			if lastC > 0 and lastC > lastR then
				lettersNow = lastC - 1
			end
		end

		local utf8pos = 1
		local textLen = string.len(text)
		while true do
			local char = string.sub(text,utf8pos,utf8pos)
			local c = char:byte()

			local lastPos = utf8pos

			if c > 0 and c <= 127 then
				utf8pos = utf8pos + 1
			elseif c >= 194 and c <= 223 then
				utf8pos = utf8pos + 2
			elseif c >= 224 and c <= 239 then
				utf8pos = utf8pos + 3
			elseif c >= 240 and c <= 244 then
				utf8pos = utf8pos + 4
			else
				utf8pos = utf8pos + 1
			end

			if utf8pos > lettersNow then
				lettersNow = lastPos - 1
				break
			elseif utf8pos >= textLen then
				break
			end
		end
		result[#result + 1] = string.sub(text,1,lettersNow)
		text = string.sub(text,lettersNow+1)
	until string.len(text) < maxLetters
	if string.len(text) > 0 then
		result[#result + 1] = text
	end
	return unpack(result)
end

function ExRT.F:SetScaleFix(scale)
	local l = self:GetLeft()
	local t = self:GetTop()
	local s = self:GetScale()
	if not l or not t or not s then return end

	s = scale / s

	self:SetScale(scale)
	local f = self:GetScript("OnDragStop")

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",l / s,t / s)

	if f then f(self) end
end

ExRT.F._addonScaleFrames = ExRT.F._addonScaleFrames or {}
function ExRT.F.AddonScaleApply(frame)
	if not frame then return end
	local s = (VMRT and VMRT.Addon and tonumber(VMRT.Addon.Scale)) or 1
	if s < 0.5 then s = 0.5 elseif s > 2 then s = 2 end
	if frame.SetScale then frame:SetScale(s) end
	for i=1,#ExRT.F._addonScaleFrames do
		if ExRT.F._addonScaleFrames[i] == frame then return end
	end
	tinsert(ExRT.F._addonScaleFrames, frame)
end
function ExRT.F.AddonScaleBroadcast(scale)
	scale = tonumber(scale) or 1
	if scale < 0.5 then scale = 0.5 elseif scale > 2 then scale = 2 end
	for i=1,#ExRT.F._addonScaleFrames do
		local f = ExRT.F._addonScaleFrames[i]
		if f and f.SetScale then
			pcall(f.SetScale, f, scale)
		end
	end
end

function ExRT.F:SetScaleFixTR(scale)
	local l = self:GetRight()
	local t = self:GetTop()
	local s = self:GetScale()
	if not l or not t or not s then return end

	s = scale / s

	self:SetScale(scale)
	local f = self:GetScript("OnDragStop")

	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT",UIParent,"BOTTOMLEFT",l / s,t / s)

	if f then f(self) end
end

function ExRT.F:GetCursorPos()
	local x_f,y_f = GetCursorPosition()
	local s = self.GetEffectiveScale and self:GetEffectiveScale() or self:GetParent():GetEffectiveScale()
	x_f, y_f = x_f/s, y_f/s
	local x,y = self:GetLeft(),self:GetTop()
	x = x_f-x
	y = (y_f-y)*(-1)
	return x,y
end

do
	local function FindAllParents(self,obj)
		while obj do
			if obj == self then
				return true
			end
			obj = obj:GetParent()
		end
	end
	function ExRT.F:IsInFocus(x,y,childs)
		if not x then
			x,y = ExRT.F.GetCursorPos(self)
		end
		local obj
		if GetMouseFoci then
			obj = GetMouseFoci()[1]
		else
			obj = GetMouseFocus()
		end
		if x > 0 and y > 0 and x < self:GetWidth() and y < self:GetHeight() and (obj == self or (childs and FindAllParents(self,obj))) then
			return true
		end
	end
end

function ExRT.F:LockMove(isLocked,touchTexture,dontTouchMouse)
	if isLocked then
		if touchTexture then touchTexture:SetColorTexture(0,0,0,0.3) end
		self:SetMovable(true)
		if not dontTouchMouse then self:EnableMouse(true) end
	else
		if touchTexture then touchTexture:SetColorTexture(0,0,0,0) end
		self:SetMovable(false)
		if not dontTouchMouse then self:EnableMouse(false) end
	end
end

local MAX_RAID_GROUP = 5
if ExRT.isClassic and not ExRT.isBC then
	MAX_RAID_GROUP = 8
end
local DIFF_TO_MAX_GROUP = {
	[8] = 1,
	[1] = 1,
	[2] = 1,
	[14] = 6,
	[15] = 6,
	[16] = 4,
	[3] = 2,
	[5] = 2,
	[9] = 8,
	[186] = 8,
	[148] = 4,
	[185] = 4,
	[175] = 2,
	[176] = 5,
	[151] = 6,
	[17] = 6,
	[7] = 5,
	[33] = 6,
	[18] = 8,
	[193] = 2,
	[194] = 5,
}
function ExRT.F.GetRaidDiffMaxGroup()
	local _,instance_type,difficulty = GetInstanceInfo()
	if (instance_type == "party" or instance_type == "scenario") and not IsInRaid() then
		return 1
	elseif instance_type ~= "raid" then
		return 8
	elseif ExRT.isLK then
		return MAX_RAID_GROUP
	elseif difficulty and DIFF_TO_MAX_GROUP[difficulty] then
		return DIFF_TO_MAX_GROUP[difficulty]
	else
		return MAX_RAID_GROUP
	end
end

function ExRT.F.GetDifficultyForCooldownReset()
	local _,_,difficulty = GetInstanceInfo()
	if difficulty == 3 or difficulty == 4 or difficulty == 5 or difficulty == 6 or difficulty == 7 or difficulty == 14 or difficulty == 15 or difficulty == 16 or difficulty == 17 or (ExRT.isLK and (difficulty == 175 or difficulty == 176 or difficulty == 193 or difficulty == 194)) then
		return true
	end
	return false
end

function ExRT.F.Round(i)
	return floor(i+0.5)
end

function ExRT.F.NumberInRange(i,mi,mx,incMi,incMx)
	if i and ((incMi and i >= mi) or (not incMi and i > mi)) and ((incMx and i <= mx) or (not incMx and i < mx)) then
		return true
	end
end

function ExRT.F.delUnitNameServer(unitName)
	unitName = strsplit("-",unitName)
	return unitName
end

function ExRT.F.UnitCombatlogname(unit)
	local name,server = UnitName(unit or "?")
	if name and server and server~="" then
		name = name .. "-" .. server
	end
	return name
end

do
	local old_types = {
		Player = 0,
		Creature = 3,
		Pet = 4,
		Vehicle = 5,
		GameObject = 6,
		Vignette = 7,
		Item = 8,
		Uniq = 9,
	}
	function ExRT.F.GetUnitTypeByGUID(guid)
		if not guid or guid == "" then
			return nil
		end
		local _type = string_match(guid,"^([A-z]+)%-")
		if _type then
			return old_types[_type]
		end
		local hex = string_match(guid,"^0x(%x+)$")
		if hex then
			if #hex < 16 then hex = string.rep("0",16-#hex)..hex end
			if hex:sub(1,4) == "0000" then
				return 0
			end
			local typeTriplet = hex:sub(1,3):upper()
			if typeTriplet == "F13" then
				return 3
			elseif typeTriplet == "F14" then
				return 4
			elseif typeTriplet == "F15" then
				return 5
			elseif typeTriplet == "F11" then
				return 6
			elseif typeTriplet == "F17" then
				return 7
			end
			if hex:sub(1,1):upper() ~= "F" then
				return 0
			end
		end
		return nil
	end
end

function ExRT.F.UnitIsPlayerOrPet(guid)
	local id = ExRT.F.GetUnitTypeByGUID(guid)
	if id == 0 or id == 4 then
		return true
	end
end

function ExRT.F.GetUnitInfoByUnitFlag(unitFlag,infoType)

	if infoType == 1 then
		return bit_band(unitFlag,COMBATLOG_OBJECT_TYPE_MASK)


	elseif infoType == 2 then
		return bit_band(unitFlag,COMBATLOG_OBJECT_CONTROL_MASK)


	elseif infoType == 3 then
		return bit_band(unitFlag,COMBATLOG_OBJECT_REACTION_MASK)


	elseif infoType == 4 then
		return bit_band(unitFlag,COMBATLOG_OBJECT_AFFILIATION_MASK)


	elseif infoType == 5 then
		return bit_band(unitFlag,COMBATLOG_OBJECT_SPECIAL_MASK)

	end
end

function ExRT.F.UnitIsFriendlyByUnitFlag(unitFlag)
	if ExRT.F.GetUnitInfoByUnitFlag(unitFlag,2) == 256 then
		return true
	end
end

function ExRT.F.UnitIsFriendlyByUnitFlag2(unitFlag)
	local reaction = ExRT.F.GetUnitInfoByUnitFlag(unitFlag or 0,3)
	if reaction == 16 then
		return true
	elseif reaction == 32 then
		if ExRT.F.GetUnitInfoByUnitFlag(unitFlag,2) == 256 then
			return true
		end
	end
end

function ExRT.F.dprint(...)
	return nil
end
function ExRT.F.dtime(...)
	return nil
end
if ExRT.isDev then
	ExRT.F.dprint = function(...)
		print(...)
	end
	local debugprofilestop = debugprofilestop
	local lastTime = nil
	ExRT.F.dtime = function(arg,...)
		if arg and lastTime then
			arg[#arg+1] = {debugprofilestop() - lastTime,...}
		else
			lastTime = debugprofilestop()
		end
	end
end

local GetSpellLink = C_Spell and C_Spell.GetSpellLink or GetSpellLink
function ExRT.F.LinkSpell(SpellID,SpellLink)
	if not SpellLink then
		SpellLink = (ExRT.F.GetSpellLinkSafe and ExRT.F.GetSpellLinkSafe(SpellID)) or GetSpellLink(SpellID)
	end
	if SpellLink then
		if ChatEdit_GetActiveWindow() then
			ChatEdit_InsertLink(SpellLink)
		else
			ChatFrame_OpenChat(SpellLink)
		end
	end
end

function ExRT.F.LinkItem(itemID, itemLink)
	if not itemLink then
		if not itemID then
			return
		end
		itemLink = select(2,GetItemInfo(itemID))
	end
	if not itemLink then
		return
	end
	if IsModifiedClick("DRESSUP") then
		return DressUpItemLink(itemLink)
	else
		if ChatEdit_GetActiveWindow() then
			ChatEdit_InsertLink(itemLink)
		else
			ChatFrame_OpenChat(itemLink)
		end
	end
end

function ExRT.F.shortNumber(num)
	if num < 1000 then
		return tostring(num)
	elseif num < 1000000 then
		return format("%.1fk",num/1000)
	elseif num < 1000000000 then
		return format("%.2fm",num/1000000)
	else
		return format("%.3fM",num/1000000000)
	end
end

ExRT.F.classSquareIcon = ExRT.F.classSquareIcon or {
	["WARRIOR"]     = "Interface\\Icons\\INV_Sword_27",
	["PALADIN"]     = "Interface\\Icons\\Ability_ThunderBolt",
	["HUNTER"]      = "Interface\\Icons\\inv_weapon_bow_07",
	["ROGUE"]       = "Interface\\Icons\\inv_throwingknife_04",
	["PRIEST"]      = "Interface\\Icons\\inv_staff_30",
	["SHAMAN"]      = "Interface\\Icons\\Spell_Nature_BloodLust",
	["MAGE"]        = "Interface\\Icons\\inv_staff_13",
	["WARLOCK"]     = "Interface\\Icons\\Spell_Nature_Drowsy",
	["DRUID"]       = "Interface\\Icons\\inv_misc_monsterclaw_04",
	["DEATHKNIGHT"] = "Interface\\Icons\\Spell_Deathknight_ClassIcon",
}

function ExRT.F.classIconInText(class,size)
	if class and ExRT.F.classSquareIcon[class] then
		size = size or 0
		return "|T"..ExRT.F.classSquareIcon[class]..":"..size..":"..size..":0:0:64:64:0:64:0:64|t"
	elseif CLASS_ICON_TCOORDS[class] then
		size = size or 0
		return "|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:"..size..":"..size..":0:0:256:256:".. floor(CLASS_ICON_TCOORDS[class][1]*256) ..":"..floor(CLASS_ICON_TCOORDS[class][2]*256) ..":"..floor(CLASS_ICON_TCOORDS[class][3]*256) ..":"..floor(CLASS_ICON_TCOORDS[class][4]*256) .."|t"
	end
end

function ExRT.F.classIconRaw(class)
	if class and ExRT.F.classSquareIcon[class] then
		return ExRT.F.classSquareIcon[class], 0, 1, 0, 1
	elseif class and CLASS_ICON_TCOORDS[class] then
		local c = CLASS_ICON_TCOORDS[class]
		return "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES", c[1], c[2], c[3], c[4]
	end
end

function ExRT.F.GUIDtoID(guid)
	local type,_,serverID,instanceID,zoneUID,id,spawnID = strsplit("-", guid or "")
	return tonumber(id or 0)
end

function ExRT.F.table_copy(table1,table2)
	table.wipe(table2)
	for key,val in pairs(table1) do
		table2[key] = val
	end
end

function ExRT.F.table_copy2(table1)
	local table2 = {}
	for key,val in pairs(table1) do
		if type(val) == 'table' then
			table2[key] = ExRT.F.table_copy2(val)
		else
			table2[key] = val
		end
	end
	return table2
end

function ExRT.F.table_wipe(arr)
	if not arr or type(arr) ~= "table" then
		return
	end
	for key,val in pairs(arr) do
		if type(val) == "table" then
			ExRT.F.table_wipe(val)
		end
		arr[key] = nil
	end
end

function ExRT.F.table_find(arr,subj,pos)
	if pos then
		for j=1,#arr do
			if arr[j][pos] == subj then
				return j
			end
		end
	else
		for j=1,#arr do
			if arr[j] == subj then
				return j
			end
		end
	end
end

function ExRT.F.table_find2(arr,subj)
	for key,val in pairs(arr) do
		if val == subj then
			return key
		end
	end
end

function ExRT.F.table_find3(arr,subj,pos)
	for j=1,#arr do
		if arr[j][pos] == subj then
			return arr[j]
		end
	end
end

function ExRT.F.table_len(arr)
	local len = 0
	for _ in pairs(arr) do
		len = len + 1
	end
	return len
end

function ExRT.F.table_add(arr,add)
	for i=1,#add do
		arr[#arr+1] = add[i]
	end
end

function ExRT.F.table_add2(arr,add)
	for key,val in pairs(add) do
		arr[key] = val
	end
end

function ExRT.F.table_keys(arr)
	local r = {}
	for key,val in pairs(arr) do
		r[#r+1] = key
	end
	return r
end

do
	local function swap(array, index1, index2)
		array[index1], array[index2] = array[index2], array[index1]
	end
	local math_random = math.random
	function ExRT.F.table_shuffle(array)
		local counter = #array
		while counter > 1 do
			local index = math_random(counter)
			swap(array, index, counter)
			counter = counter - 1
		end
	end
end

do
	local printDiff = false
	local printTable = nil
	local function cmp(t1,t2,r,p)
		local c,t = 0,0
		if type(t1) ~= "table" or type(t2) ~= "table" then
			return c, t
		end
		p = p or "."
		for k,v in pairs(t1) do
			if type(v) == "table" then
				if type(t2[k]) == "table" then
					local c2,t2 = cmp(v,t2[k],false,p..k..".")
					c = c + c2
					t = t + t2
				else
					t = t + 1
					if printTable then
						printTable[p..k] = true
					elseif printDiff then
						print(p..k)
					end
				end
			else
				t = t + 1
				if t1[k] == t2[k] then
					c = c + 1
				elseif type(v) == "number" and type(t2[k]) == "number" and tostring(v) == tostring(t2[k]) then
					c = c + 1
				elseif printTable then
					printTable[p..k] = true
				elseif printDiff then
					print(p..k)
				end
			end
		end
		if not r then
			local c2,t2 = cmp(t2,t1,true,p)
			c = c + c2
			t = t + t2
		end
		return c, t
	end
	function ExRT.F.table_compare(t1,t2,showDiff)
		printDiff = showDiff
		if type(printDiff) == "table" then
			printTable = printDiff
			printDiff = nil
		else
			printTable = nil
		end
		local c, t = cmp(t1,t2)

		return c / max(1,t), c, t
	end
end

function ExRT.F.table_rewrite(t1,t2)
	local toRemove = {}
	for k,v in pairs(t1) do
		if not t2[k] then
			toRemove[k] = true
		elseif type(v) == "table" and type(t2[k]) == "table" then
			ExRT.F.table_rewrite(v,t2[k])
		else
			t1[k] = t2[k]
		end
	end
	for k,v in pairs(toRemove) do
		t1[k] = nil
	end
	for k,v in pairs(t2) do
		if not t1[k] then
			t1[k] = v
		end
	end
end

function ExRT.F.table_random(t)
	local keys_num = 0
	for k,v in pairs(t) do
		keys_num = keys_num + 1
	end
	if keys_num == 0 then return end
	local key_need = math.random(1,keys_num)
	keys_num = 0
	for k,v in pairs(t) do
		keys_num = keys_num + 1
		if keys_num == key_need then
			return v
		end
	end
end

local sort_f = function(a,b) return a[1]<b[1] end
function ExRT.F.table_to_string(t)
	if type(t)~="table" then return end
	local keys = {}
	local res = {}
	for q,w in pairs(t) do
		if type(q)~="function" and type(q)~="table" and not (w=="") then
			keys[#keys+1]={tostring(q),w}
		end
	end
	sort(keys,sort_f)
	for i=1,#keys do
		local v = keys[i][2]
		res[#res+1] = keys[i][1] .. "=" .. (type(v)=="table" and ExRT.F.table_to_string(v) or type(v)=="function" and "<f>" or tostring(v))
	end
	local str = "{"..table.concat(res,",").."}"
	return str
end

function ExRT.F.table_keys_to_string(t,sep)
	local str = ""
	for k in pairs(t) do
		str = str .. (str ~= "" and (sep or " ") or "") .. k
	end
	return str
end

function ExRT.F.tohex(num,size)
	local n = num
	if type(n) == "string" then
		local s = n
		n = tonumber(s)
		if not n then
			s = s:gsub("^#","")
			if s:match("^0x") then
				n = tonumber(s)
			else
				local hex = s:match("^([0-9a-fA-F]+)$")
				if hex then
					n = tonumber("0x"..hex)
				end
			end
		end
	end
	if type(n) ~= "number" then
		return tostring(num)
	end
	return format("%0"..(size or "1").."X",n)
end

function ExRT.F.UnitInGuild(unit)
	if type(unit) ~= "string" or unit == "" then return false end
	local sunit = ExRT.F.delUnitNameServer(unit) or unit
	local lcUnit = unit:lower()
	local lcSUnit = sunit:lower()
	local gplayers = GetNumGuildMembers() or 0
	if gplayers == 0 and GuildRoster then
		pcall(GuildRoster)
	end
	gplayers = GetNumGuildMembers() or 0
	for i=1,gplayers do
		local name = GetGuildRosterInfo(i)
		if name then
			local sname = ExRT.F.delUnitNameServer(name) or name
			if name == unit or name == sunit or sname == unit or sname == sunit
				or name:lower() == lcUnit or name:lower() == lcSUnit
				or sname:lower() == lcUnit or sname:lower() == lcSUnit then
				return true
			end
		end
	end
	if UnitIsInMyGuild then
		local ok1, r1 = pcall(UnitIsInMyGuild, unit)
		if ok1 and r1 then return true end
		local ok2, r2 = pcall(UnitIsInMyGuild, sunit)
		if ok2 and r2 then return true end
	end
	return false
end

function ExRT.F.chatType(toSay)
	local isInInstance = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
	local isInParty = IsInGroup()
	local isInRaid = IsInRaid()
	local playerName = nil
	local chat_type = (isInInstance and "INSTANCE_CHAT") or (isInRaid and "RAID") or (isInParty and "PARTY")
	if not chat_type and not toSay then
		chat_type = "WHISPER"
		playerName = UnitName("player")
	elseif not chat_type then
		chat_type = "SAY"
	end
	return chat_type, playerName
end

function ExRT.F.IsBonusOnItem(link,bonus)
	if link then
		local _,itemID,enchant,gem1,gem2,gem3,gem4,suffixID,uniqueID,level,specializationID,upgradeType,instanceDifficultyID,numBonusIDs,restLink = strsplit(":",link,15)
		if restLink then
			local bonuses = {strsplit(":",strsplit("|h",restLink),nil)}
			numBonusIDs = tonumber(numBonusIDs) or 0
			local isTable = type(bonus) == "table"
			for i = 1, numBonusIDs do
				local bonusID = tonumber(bonuses[i]) or -999
				if (isTable and bonus[bonusID]) or (not isTable and bonusID == bonus) then
					return true
				end
			end
		end
	end
end

function ExRT.F.GetItemBonuses(link)
	if link then
		local _,itemID,enchant,gem1,gem2,gem3,gem4,suffixID,uniqueID,level,specializationID,upgradeType,instanceDifficultyID,numBonusIDs,restLink = strsplit(":",link:match("|H.-|h") or link,15)
		numBonusIDs = tonumber(numBonusIDs or "?") or 0
		local bonusStr = ""
		for i=1,numBonusIDs do
			local bonus = select(i,strsplit(":",restLink))
			if bonus then
				bonusStr = bonusStr .. bonus .. ":"
			end
		end
		bonusStr = strtrim(bonusStr,":")
		return bonusStr,numBonusIDs
	end
	return "",0
end


function ExRT.F.IsPlayerRLorOfficer(unitName)
	if type(unitName) ~= "string" or unitName == "" then return end
	local shortName = ExRT.F.delUnitNameServer(unitName) or unitName
	local lcUnitName = unitName:lower()
	local lcShortName = shortName:lower()
	local nGroup = (GetNumGroupMembers and GetNumGroupMembers() or 0)
	for i=1,nGroup do
		local name,rank = GetRaidRosterInfo(i)
		if name then
			local nameShort = ExRT.F.delUnitNameServer(name) or name
			local lcName = name:lower()
			local lcNameShort = nameShort:lower()
			if name == unitName or name == shortName
				or nameShort == unitName or nameShort == shortName
				or lcName == lcUnitName or lcName == lcShortName
				or lcNameShort == lcUnitName or lcNameShort == lcShortName
				or UnitIsUnit(unitName,"raid"..i) or UnitIsUnit(shortName,"raid"..i) then
				if rank and rank > 0 then
					return rank
				else
					return false
				end
			end
		end
	end
	if unitName == (UnitName and UnitName("player") or "") or shortName == (UnitName and UnitName("player") or "") then
		if (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0 then
			if UnitIsGroupLeader and UnitIsGroupLeader("player") then return 2 end
			if UnitIsGroupAssistant and UnitIsGroupAssistant("player") then return 1 end
			return false
		end
	end
end

function ExRT.F.GetPlayerParty(unitName)
	for i=1,GetNumGroupMembers() do
		local name,_,subgroup = GetRaidRosterInfo(i)
		if (not canaccessvalue or canaccessvalue(name)) and name and UnitIsUnit(name,unitName) then
			return subgroup
		end
	end
	return 0
end

function ExRT.F.GetOwnPartyNum()
	for i=1,GetNumGroupMembers() do
		local name,_,subgroup = GetRaidRosterInfo(i)
		if (not canaccessvalue or canaccessvalue(name)) and name and UnitIsUnit(name,'player') then
			return subgroup
		end
	end
	return 1
end

function ExRT.F.CreateAddonMsg(...)
	local result = ""
	for i=1,select('#',...) do
		local a = select(i,...)
		result = result..(result ~= "" and "\t" or "")..tostring(a)
	end
	return result
end

function ExRT.F.GetPlayerRole()
	local role = UnitGroupRolesAssigned('player')
	if role == "HEALER" then
		local _,class = UnitClass('player')
		return role, (class == "PALADIN") and "MHEALER" or "RHEALER"
	elseif role ~= "DAMAGER" then

		return role
	else
		local _,class = UnitClass('player')
		local isMelee = (class == "WARRIOR" or class == "PALADIN" or class == "ROGUE" or class == "DEATHKNIGHT")
		if class == "DRUID" then
			isMelee = GetSpecialization() ~= 1
		elseif class == "SHAMAN" then
			isMelee = GetSpecialization() == 2
		elseif class == "HUNTER" then
			isMelee = false
		end
		if isMelee then
			return role, "MDD"
		else
			return role, "RDD"
		end
	end
end

function ExRT.F.GetUnitRole(unit)
	local role = UnitGroupRolesAssigned(unit)
	if role == "HEALER" then
		local _,class = UnitClass(unit)
		return role, (class == "PALADIN") and "MHEALER" or "RHEALER"
	elseif role ~= "DAMAGER" then

		return role
	else
		local _,class = UnitClass(unit)
		local isMelee = (class == "WARRIOR" or class == "PALADIN" or class == "ROGUE" or class == "DEATHKNIGHT")
		if class == "DRUID" then
			isMelee = not (UnitPowerType(unit) == 8)
		elseif class == "SHAMAN" then
			isMelee = UnitPowerMax(unit) >= 150
		elseif class == "HUNTER" then
			isMelee = false
		end
		if isMelee then
			return role, "MDD"
		else
			return role, "RDD"
		end
	end
end

function ExRT.F.GetUnitRaidRole(name)
	local unit = ExRT.F.findunitbyname and ExRT.F.findunitbyname(name) or name
	-- 1) LFD-assigned role. On 3.3.5a UnitGroupRolesAssigned returns three booleans
	-- (isTank,isHealer,isDamage), on later clients a single string.
	if UnitGroupRolesAssigned then
		local r1,r2,r3 = UnitGroupRolesAssigned(unit)
		if r1 == "TANK" or r1 == "HEALER" or r1 == "DAMAGER" then
			return r1
		elseif type(r1) == "boolean" then
			if r1 then
				return "TANK"
			elseif r2 then
				return "HEALER"
			elseif r3 then
				return "DAMAGER"
			end
		end
	end
	-- 2) Raid main tank assignment
	if GetPartyAssignment and UnitExists and UnitExists(unit) and GetPartyAssignment("MAINTANK", unit) then
		return "TANK"
	end
	-- 3) Spec detected from talents (MRT inspect data, same source as cd list)
	local specID = VMRT and VMRT.ExCD2 and VMRT.ExCD2.gnGUIDs and VMRT.ExCD2.gnGUIDs[name]
	local specRole = specID and ExRT.GDB.ClassSpecializationRole and ExRT.GDB.ClassSpecializationRole[specID]
	if specRole == "TANK" then
		return "TANK"
	elseif specRole == "HEAL" then
		return "HEALER"
	elseif specRole == "MELEE" or specRole == "RANGE" then
		return "DAMAGER"
	end
	-- 4) Class/aura heuristic fallback
	local _, class = UnitClass(unit)
	if not class then return nil end
	if class == "PRIEST" then
		local shadowform = GetSpellInfo and GetSpellInfo(15473)
		if shadowform and UnitBuff and UnitBuff(unit, shadowform) then
			return "DAMAGER"
		end
		return "HEALER"
	elseif class == "DRUID" then
		-- bear form uses rage
		if UnitPowerType and UnitPowerType(unit) == 1 then
			return "TANK"
		end
		return "DAMAGER"
	end
	return "DAMAGER"
end

function ExRT.F.TextureToText(textureName,widthInText,heightInText,textureWidth,textureHeight,leftTexCoord,rightTexCoord,topTexCoord,bottomTexCoord)
	return "|T"..textureName..":"..(widthInText or 0)..":"..(heightInText or 0)..":0:0:"..textureWidth..":"..textureHeight..":"..
		format("%d",leftTexCoord*textureWidth)..":"..format("%d",rightTexCoord*textureWidth)..":"..format("%d",topTexCoord*textureHeight)..":"..format("%d",bottomTexCoord*textureHeight).."|t"
end
function ExRT.F.GetRaidTargetText(icon,size)
	size = size or 0
	return ExRT.F.TextureToText([[Interface\TargetingFrame\UI-RaidTargetingIcons]],size,size,256,256,((icon-1)%4)/4,((icon-1)%4+1)/4,floor((icon-1)/4)/4,(floor((icon-1)/4)+1)/4)
end

function ExRT.F.IterateMediaData(mediaType)
	local list
	if LibStub then
		local loaded,media = pcall(LibStub,"LibSharedMedia-3.0")
		if loaded and media then
			list = media:HashTable(mediaType)
		end
	end
	return next, list or {}
end

function ExRT.F.GetSharedMediaList(mediaType, builtinList)
	local list = {}
	local seen = {}
	local nameByPath = {}
	if LibStub then
		local loaded, media = pcall(LibStub, "LibSharedMedia-3.0")
		if loaded and media then
			local hash = media:HashTable(mediaType)
			if hash then
				for name, path in pairs(hash) do
					nameByPath[path] = name
					if not seen[path] then
						list[#list+1] = {name = name, path = path}
						seen[path] = true
					end
				end
			end
		end
	end
	if builtinList then
		for i = 1, #builtinList do
			local path = builtinList[i]
			if not seen[path] then
				local name = nameByPath[path] or path:match("([^\\/]+)%.[^%.\\/]+$") or path:match("([^\\/]+)$") or path
				list[#list+1] = {name = name, path = path}
				seen[path] = true
			end
		end
	end
	sort(list, function(a, b) return a.name:lower() < b.name:lower() end)
	return list
end


function ExRT.F.IterateRoster(maxGroup,index)
	index = (index or 0) + 1
	maxGroup = maxGroup or 8

	if IsInRaid() then
		if index > GetNumGroupMembers() then
			return
		end
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(index)
		if subgroup > maxGroup then
			return ExRT.F.IterateRoster(maxGroup,index)
		end
		local guid = UnitGUID(name or "raid"..index)
		name = name or ""
		return index, name, subgroup, fileName, guid, rank, level, online, isDead, combatRole
	else
		local name, rank, subgroup, level, class, fileName, online, isDead, combatRole, _

		local unit = index == 1 and "player" or "party"..(index-1)

		local guid = UnitGUID(unit)
		if not guid then
			return
		end

		subgroup = 1
		name, _ = UnitName(unit)
		name = name or ""
		if _ and _ ~= "" then
			name = name .. "-" .. _
		end
		class, fileName = UnitClass(unit)

		if UnitIsGroupLeader(unit) then
			rank = 2
		else
			rank = 1
		end

		level = UnitLevel(unit)

		if UnitIsConnected(unit) then
			online = true
		end

		if UnitIsDeadOrGhost(unit) then
			isDead = true
		end

		combatRole = UnitGroupRolesAssigned(unit)

		return index, name, subgroup, fileName, guid, rank, level, online, isDead, combatRole
	end
end

function ExRT.F.vpairs(t)
	local prev
	local function it()
		local k,v = next(t,prev)
		prev = k
		return v
	end
	return it
end

function ExRT.F:SafeCall(func, ...)
	local res, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = xpcall(func, geterrorhandler(), ...)
	if res then
		return arg1, arg2, arg3, arg4, arg5, arg6, arg7
	end
end

do


	local function utf8charbytes(s, i)

		i = i or 1


		if type(s) ~= "string" then
			error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
		end
		if type(i) ~= "number" then
			error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
		end

		local c = strbyte(s, i)


		if c > 0 and c <= 127 then

			return 1

		elseif c >= 194 and c <= 223 then

			local c2 = strbyte(s, i + 1)

			if not c2 then
				error("UTF-8 string terminated early")
			end


			if c2 < 128 or c2 > 191 then
				error("Invalid UTF-8 character")
			end

			return 2

		elseif c >= 224 and c <= 239 then

			local c2 = strbyte(s, i + 1)
			local c3 = strbyte(s, i + 2)

			if not c2 or not c3 then
				error("UTF-8 string terminated early")
			end


			if c == 224 and (c2 < 160 or c2 > 191) then
				error("Invalid UTF-8 character")
			elseif c == 237 and (c2 < 128 or c2 > 159) then
				error("Invalid UTF-8 character")
			elseif c2 < 128 or c2 > 191 then
				error("Invalid UTF-8 character")
			end


			if c3 < 128 or c3 > 191 then
				error("Invalid UTF-8 character")
			end

			return 3

		elseif c >= 240 and c <= 244 then

			local c2 = strbyte(s, i + 1)
			local c3 = strbyte(s, i + 2)
			local c4 = strbyte(s, i + 3)

			if not c2 or not c3 or not c4 then
				error("UTF-8 string terminated early")
			end


			if c == 240 and (c2 < 144 or c2 > 191) then
				error("Invalid UTF-8 character")
			elseif c == 244 and (c2 < 128 or c2 > 143) then
				error("Invalid UTF-8 character")
			elseif c2 < 128 or c2 > 191 then
				error("Invalid UTF-8 character")
			end


			if c3 < 128 or c3 > 191 then
				error("Invalid UTF-8 character")
			end


			if c4 < 128 or c4 > 191 then
				error("Invalid UTF-8 character")
			end

			return 4

		else
			error("Invalid UTF-8 character")
		end
	end

	function ExRT.F.utf8len(s)
		local pos = 1
		local bytes = strlen(s)
		local len = 0

		while pos <= bytes do
			len = len + 1
			pos = pos + utf8charbytes(s, pos)
		end

		return len
	end


	function ExRT.F.utf8sub(s, i, j)

		j = j or -1

		local pos = 1
		local bytes = strlen(s)
		local len = 0


		local l = (i >= 0 and j >= 0) or ExRT.F.utf8len(s)
		local startChar = (i >= 0) and i or l + i + 1
		local endChar   = (j >= 0) and j or l + j + 1


		if startChar > endChar then
			return ""
		end


		local startByte, endByte = 1, bytes

		while pos <= bytes do
			len = len + 1

			if len == startChar then
				startByte = pos
			end

			pos = pos + utf8charbytes(s, pos)

			if len == endChar then
				endByte = pos - 1
				break
			end
		end

		return strsub(s, startByte, endByte)
	end
end

function ExRT.F.GetFirstTableInText(str)
	local strlen = str:len()
	local i = 1
	local deep = 0
	local start
	local inStr
	local inWideStr
	local wideStrEqCount = 0
	while i <= strlen do
		local b = str:byte(i)
		if not start and not inStr and b == 123 then
			start = i
		elseif start and not inStr and b == 123 then
			deep = deep + 1
		elseif start and not inStr and b == 125 then
			if deep <= 0 then
				return str:sub(start,i)
			else
				deep = deep - 1
			end
		elseif not inStr and b == 34 then
			inStr = i
		elseif inStr and not inWideStr and b == 92 then
			i = i + 1
		elseif inStr and not inWideStr and b == 34 then
			inStr = false
		elseif not inStr and b == 91 then
			local k = i + 1
			local eqc = 0
			while k <= strlen do
				local c1 = str:byte(k)
				if c1 == 61 then
					eqc = eqc + 1
				elseif c1 == b then
					inStr = i
					inWideStr = i
					wideStrEqCount = eqc
					break
				else
					break
				end
				k = k + 1
			end
		elseif inStr and inWideStr and b == 93 then
			local k = i + 1
			local eqc = 0
			while k <= strlen do
				local c1 = str:byte(k)
				if c1 == 61 then
					eqc = eqc + 1
				elseif c1 == b then
					if eqc == wideStrEqCount then
						i = k
						inStr = false
						inWideStr = false
					end
					break
				else
					break
				end
				k = k + 1
			end
		end
		i = i + 1
	end
end

do
	local chatWindow = nil
	local activeChat = "RAID"
	local activeName = ""
	local UpdateLines = nil
	local function CreateChatWindow()
		chatWindow = ELib:Template("ExRTDialogModernTemplate",UIParent)
		_G["MRTToChatWindow"] = chatWindow
		chatWindow:SetSize(400,300)
		chatWindow:SetPoint("CENTER")
		chatWindow:SetFrameStrata("DIALOG")
		chatWindow:SetClampedToScreen(true)
		chatWindow:EnableMouse(true)
		chatWindow:SetMovable(true)
		chatWindow:RegisterForDrag("LeftButton")
		chatWindow:SetDontSavePosition(true)
		chatWindow:SetScript("OnDragStart", function(self)
			self:StartMoving()
		end)
		chatWindow:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
		end)

		chatWindow.border = ExRT.lib:Shadow(chatWindow,20)

		chatWindow.title:SetText(ExRT.L.ChatwindowName)

		chatWindow.box = ExRT.lib:MultiEdit(chatWindow):Size(230,265):Point(10,-23):Font('x',11)

		local chats = {
			{"ME",ExRT.L.ChatwindowChatSelf},
			{"SAY",ExRT.L.ChatwindowChatSay},
			{"PARTY",ExRT.L.ChatwindowChatParty},
			{"INSTANCE_CHAT",ExRT.L.ChatwindowChatInstance},
			{"RAID",ExRT.L.ChatwindowChatRaid},
			{"WHISPER",ExRT.L.ChatwindowChatWhisper},
			{"TARGET",ExRT.L.ChatwindowChatWhisperTarget},
			{"GUILD",ExRT.L.ChatwindowChatGuild},
			{"OFFICER",ExRT.L.ChatwindowChatOfficer},
		}

		chatWindow.dropDown = ExRT.lib:DropDown(chatWindow,130,#chats):Size(130):Point(255,-60):SetText(ExRT.L.ChatwindowChatRaid)
		chatWindow.dropDownText = ExRT.lib:Text(chatWindow,ExRT.L.ChatwindowChannel,10):Size(350,14):Point("BOTTOMLEFT",chatWindow.dropDown,"TOPLEFT",5,2):Color():Shadow()
		for i=1,#chats do
			local chatData = chats[i]
			chatWindow.dropDown.List[i] = {
				text = chatData[2],
				notCheckable = true,
				justifyH = "CENTER",
				arg1 = chatData[1],
				arg2 = chatData[2],
				func = function (this,arg1,arg2)
					chatWindow.dropDown:SetText(arg2)
					ExRT.lib:DropDownClose()
					activeChat = arg1
				end
			}
		end

		chatWindow.target = ExRT.lib:Edit(chatWindow):Size(130,20):Point(255,-115):OnChange(function (self)
			activeName = self:GetText()
		end)
		chatWindow.targetText = ExRT.lib:Text(chatWindow,ExRT.L.ChatwindowNameEB,10):Size(350,14):Point("BOTTOMLEFT",chatWindow.target,"TOPLEFT",5,2):Bottom():Color():Shadow()

		chatWindow.button = ExRT.lib:Button(chatWindow,ExRT.L.ChatwindowSend):Size(130,22):Point(255,-150):OnClick(function (self)
			local lines = {strsplit("\n", chatWindow.box.EditBox:GetText())}
			local channel = activeChat
			local whisper = activeName
			if channel == "TARGET" then
				channel = "WHISPER"
				whisper = ExRT.F.UnitCombatlogname("target")
				if not whisper then
					return
				end
			end
			if channel == "ME" then
				for i=1,#lines do
					if lines[i] ~= "" then
						print(lines[i])
					end
				end
				chatWindow:Hide()
				return
			end
			if whisper == "" then
				whisper = nil
			end
			for i=1,#lines do
				if lines[i] ~= "" then
					SendChatMessage(lines[i],channel,nil,whisper)
				end
			end
			chatWindow:Hide()
		end)

		chatWindow.helpText = ExRT.lib:Text(chatWindow,ExRT.L.ChatwindowHelp,10):Size(130,100):Point("TOP",chatWindow.button,"BOTTOM",0,-10):Top():Color():Shadow()

		chatWindow.chk1 = ExRT.lib:Check(chatWindow,"Option 1"):Point(255,-260):OnClick(function()
			UpdateLines()
		end)
	end
	function UpdateLines()
		local lines = chatWindow.lines
		if not lines or type(lines)~="table" then
			return
		end
		local editData = ""
		local linesCount = #lines
		local clearTags = chatWindow.clearTags
		local option1 = chatWindow.option1enabled and chatWindow.chk1:GetChecked() and "%1" or ""
		for i=1,linesCount do
			local thisLine = lines[i]
			if thisLine ~= "" then
				thisLine = thisLine:gsub("@1@(.-)@1#",option1)
				if clearTags then
					thisLine = ExRT.F.clearTextTag(thisLine)
				end
				if strlen(thisLine) > 254 then
					thisLine = strjoin("\n",ExRT.F.splitLongLine(thisLine,254))
				end
				editData = editData .. thisLine
				if i ~= linesCount then
					editData = editData .. "\n"
				end
			end
		end
		chatWindow.box.EditBox:SetText(editData)
	end
	function ExRT.F:ToChatWindow(lines,clearTags,option1Name)
		if not lines or type(lines)~="table" then
			return
		end
		if not chatWindow then
			CreateChatWindow()
		end
		chatWindow.lines = lines
		chatWindow.clearTags = clearTags
		chatWindow.option1enabled = option1Name
		if option1Name then
			chatWindow.chk1.text:SetText(option1Name)
			chatWindow.chk1:SetChecked(false)
			chatWindow.chk1:Show()
		else
			chatWindow.chk1:Hide()
		end
		UpdateLines()
		chatWindow:Show()
	end
end

do
	local alertWindow = nil
	local alertFunc = nil
	local alertArg1 = nil
	local function CreateWindow()
		alertWindow = ExRT.lib:Popup():Size(500,65)
		alertWindow:SetFrameStrata("FULLSCREEN_DIALOG")

		alertWindow.EditBox = ExRT.lib:Edit(alertWindow):Size(480,16):Point("TOP",0,-20)

		alertWindow.OK = ExRT.lib:Button(alertWindow,ACCEPT):Size(130,20):Point("TOP",0,-40):OnClick(function (self)
			alertWindow:Hide()
			local input = alertWindow.EditBox:GetText()
			alertFunc(alertArg1,input)
		end)

		alertWindow.EditBox:SetScript("OnEnterPressed",function (self)
			self:GetParent().OK:Click("LeftButton")
		end)
	end
	function ExRT.F.ShowInput(text,func,arg1,onlyNum,defText,funcOnEdit)
		if not alertWindow then
			CreateWindow()
		end
		alertWindow.OK:Enable()
		alertWindow.title:SetText(text)
		alertWindow.EditBox:SetScript("OnTextChanged",funcOnEdit)
		alertWindow.EditBox:SetText(defText or "")
		alertWindow:ClearAllPoints()
		alertWindow:SetPoint("CENTER",UIParent,0,0)
		alertFunc = func
		alertArg1 = arg1
		if onlyNum then
			alertWindow.EditBox:SetNumeric(true)
		else
			alertWindow.EditBox:SetNumeric(false)
		end
		alertWindow:Show()
		alertWindow.EditBox:SetFocus()
	end
	function ExRT.F.ShowText(text)
		if not alertWindow then
			CreateWindow()
		end
		alertWindow.title:SetText("")
		alertWindow:ClearAllPoints()
		alertWindow:SetPoint("CENTER",UIParent,0,0)
		alertWindow.EditBox:SetNumeric(false)
		alertWindow.EditBox:SetText(text)
		alertWindow:Show()
		alertWindow.EditBox:SetFocus()
		alertFunc = ExRT.NULLfunc
	end
end

function ExRT.F.LinkText(parent,displayText,url,size)
	local f = CreateFrame("Button",nil,parent)
	local fs = ExRT.lib:Text(f,displayText,size or 12):Point("LEFT",0,0):Shadow()
	fs:SetTextColor(0.40,0.70,1)
	f:SetSize(math.max(fs:GetStringWidth()+4,10),(size or 12)+10)
	f:SetScript("OnClick",function() ExRT.F.ShowText(url) end)
	f:SetScript("OnEnter",function() fs:SetTextColor(0.65,0.85,1) end)
	f:SetScript("OnLeave",function() fs:SetTextColor(0.40,0.70,1) end)
	f.text = fs
	f.SetLinkURL = function(self,u) url = u end
	f.SetLinkText = function(self,t) self.text:SetText(t) self:SetWidth(math.max(self.text:GetStringWidth()+4,10)) end
	return f
end

do
	local choiceWindow
	local BTN_W, BTN_H, GAP, PAD = 120, 22, 8, 24
	function ExRT.F.ImportChoicePopup(text,buttons)
		if not choiceWindow then
			choiceWindow = ELib:Popup(""):Size(500,150)
			choiceWindow:SetFrameStrata("FULLSCREEN_DIALOG")
			choiceWindow.text = ELib:Text(choiceWindow,"",12):Size(460,90):Point("TOP",0,-30):Center()
			choiceWindow.buttons = {}
			for i=1,4 do
				choiceWindow.buttons[i] = ELib:Button(choiceWindow,""):Size(BTN_W,BTN_H)
			end
		end
		choiceWindow.text:SetText(text or "")
		local n = 0
		for i=1,4 do if buttons[i] then n = i end end
		local totalW = n*BTN_W + (n-1)*GAP
		for i=1,4 do
			local b = choiceWindow.buttons[i]
			local info = buttons[i]
			b:ClearAllPoints()
			if info then
				b:SetText(info.text or "")
				b:SetScript("OnClick",function()
					choiceWindow:Hide()
					if info.func then info.func() end
				end)
				b:SetPoint("BOTTOMLEFT",choiceWindow,"BOTTOM",-totalW/2 + (i-1)*(BTN_W+GAP),12)
				b:Show()
			else
				b:SetScript("OnClick",nil)
				b:Hide()
			end
		end
		choiceWindow:Size(math.max(totalW + PAD*2, 360),150)
		choiceWindow:ClearAllPoints()
		choiceWindow:SetPoint("CENTER",UIParent,0,0)
		choiceWindow:Show()
	end
end

do
	local alertWindow = nil
	local alertFunc = nil
	local alertArg1 = nil
	local ce = 0
	local function CreateEdit()
		ce = ce + 1
		local e = alertWindow.EditBox[ce]
		if not e then
			e = ELib:Edit(alertWindow):Size(400,16):Point("TOPLEFT",90,-20-(ce-1)*20)
			alertWindow.EditBox[ce] = e

			e:SetScript("OnEnterPressed",function (self)
				self:GetParent().OK:Click("LeftButton")
			end)
		end
		e:Show()

		return alertWindow.EditBox[ce]
	end
	local function CreateWindow()
		alertWindow = ExRT.lib:Popup():Size(500,65)
		alertWindow:SetFrameStrata("FULLSCREEN_DIALOG")

		alertWindow.EditBox = {}

		alertWindow.OK = ExRT.lib:Button(alertWindow,ACCEPT):Size(130,20):Point("BOTTOM",0,3):OnClick(function (self)
			alertWindow:Hide()
			local r = {}
			for i=1,#alertWindow.EditBox do
				local e = alertWindow.EditBox[i]
				local input = e:GetText()
				r[i] = input
			end
			alertFunc(r)
		end)
	end
	function ExRT.F.ShowInput2(text,func,...)
		if not alertWindow then
			CreateWindow()
		end
		ce = 0
		alertWindow.title:SetText(text)
		for i=1,select("#",...) do
			local opt = select(i,...)

			local e = CreateEdit()
			e:LeftText(type(opt) == "table" and opt.text or opt)
			e:SetScript("OnTextChanged",type(opt) == "table" and opt.funcOnEdit or nil)
			e:Tooltip(type(opt) == "table" and opt.tip or nil)
			e:SetText(type(opt) == "table" and opt.defText or "")
			if type(opt) == "table" and opt.onlyNum then
				e:SetNumeric(true)
			else
				e:SetNumeric(false)
			end
		end
		alertFunc = func

		alertWindow:ClearAllPoints()
		alertWindow:SetPoint("CENTER",UIParent,0,0)
		alertWindow:SetHeight(45+20*ce)
		alertWindow:Show()
		alertWindow.EditBox[1]:SetFocus()
	end
end


do
	local chatLinkFormat = "|HMRT:%s:0|h|cffffff00[MRT: %s]|r|h"
	local funcTable = {}
	local function createChatHook()
		local SetHyperlink = ItemRefTooltip.SetHyperlink
		function ItemRefTooltip:SetHyperlink(link, ...)
			local funcName = link:match("^MRT:([^:]+):")
			if funcName then
				local func = funcTable[funcName]
				if not func then
					return
				end
				func()
			else
				SetHyperlink(self, link, ...)
			end
		end
	end

	function ExRT.F.CreateChatLink(funcName,func,stringName)
		if createChatHook then createChatHook() createChatHook = nil end
		if not funcName or not stringName or type(func) ~= "function" then
			return ""
		end
		funcTable[funcName] = func
		return chatLinkFormat:format(funcName,stringName)
	end
end

local function FormatTabbedTextForDisplay(text)
	if type(text) ~= "string" or text == "" or not text:find("\t", 1, true) then
		return text
	end
	local lines = {}
	local startIdx = 1
	while true do
		local nl = text:find("\n", startIdx, true)
		if not nl then
			lines[#lines+1] = text:sub(startIdx)
			break
		end
		lines[#lines+1] = text:sub(startIdx, nl-1)
		startIdx = nl + 1
	end
	local rows = {}
	local maxLen = {}
	for i = 1, #lines do
		local row = {}
		local cellStart = 1
		local s = lines[i]
		local col = 0
		while true do
			local tab = s:find("\t", cellStart, true)
			col = col + 1
			local cell
			if not tab then
				cell = s:sub(cellStart)
				row[col] = cell
				if (#cell) > (maxLen[col] or 0) then maxLen[col] = #cell end
				break
			end
			cell = s:sub(cellStart, tab - 1)
			row[col] = cell
			if (#cell) > (maxLen[col] or 0) then maxLen[col] = #cell end
			cellStart = tab + 1
		end
		rows[i] = row
	end
	local out = {}
	for i = 1, #rows do
		local row = rows[i]
		local n = #row
		local parts = {}
		for c = 1, n do
			local cell = row[c]
			if c < n then
				local need = (maxLen[c] or 0) + 2 - #cell
				if need < 1 then need = 1 end
				parts[#parts+1] = cell .. string.rep(" ", need)
			else
				parts[#parts+1] = cell
			end
		end
		out[#out+1] = table.concat(parts)
	end
	return table.concat(out, "\n")
end

do
	local exportWindow
	function ExRT.F:Export(stringData,hideTextInfo,windowName,onChangeFunc)
		if ExRT and ExRT.isClassic and type(stringData) == "string" then
			stringData = FormatTabbedTextForDisplay(stringData)
		end
		if not exportWindow then
			exportWindow = ELib:Popup(ExRT.L.Export):Size(650,615)
			exportWindow.Edit = ELib:MultiEdit(exportWindow):Point("TOP",0,-20):Size(640,575)
			exportWindow.TextInfo = ELib:Text(exportWindow,ExRT.L.ExportInfo,11):Color():Point("BOTTOM",0,3):Size(640,15):Bottom():Left()
			exportWindow:SetScript("OnHide",function(self)
				self.Edit:SetText("")
			end)
			exportWindow.Next = ExRT.lib:Button(exportWindow,">>>"):Size(100,16):Point("BOTTOMRIGHT",0,0):OnClick(function (self)
				self.now = self.now + 1
				self:SetText(">>> "..self.now.."/"..#exportWindow.hugeText)
				exportWindow.Edit:SetText(exportWindow.hugeText[self.now])
				exportWindow.Edit.EditBox:HighlightText()
				exportWindow.Edit.EditBox:SetFocus()
				if self.now == #exportWindow.hugeText then
					self:Hide()
				end
			end)
		end
		exportWindow.title:SetText(windowName or ExRT.L.Export)
		exportWindow.Edit.OnTextChanged = onChangeFunc
		exportWindow:NewPoint("CENTER",UIParent,0,0)
		exportWindow.TextInfo:SetShown(not hideTextInfo)
		exportWindow:Show()
		if #stringData > 200000 then
			exportWindow.hugeText = {}
			while stringData and stringData ~= "" do
				local newText = stringData:sub(1,200000)..strsplit("\n",stringData:sub(200001))
				exportWindow.hugeText[#exportWindow.hugeText+1] = newText
				stringData = select(2,strsplit("\n",stringData:sub(200001),2))
			end
			exportWindow.Next.now = 0
			exportWindow.Next:Show()
			exportWindow.Next:Click()
		else
			exportWindow.hugeText = nil
			exportWindow.Next:Hide()
			exportWindow.Edit:SetText(stringData)
			exportWindow.Edit.EditBox:HighlightText()
			exportWindow.Edit.EditBox:SetFocus()
		end
	end

end

do
	local exportWindow
	local pendingToShow
	function ExRT.F:Export2(stringData)
		if not exportWindow then
			exportWindow = ExRT.lib:Popup("Export"):Size(650,50)
			exportWindow.Edit = ExRT.lib:Edit(exportWindow):Point("TOP",0,-20):Size(640,25)
			exportWindow:SetScript("OnHide",function(self)
				self.Edit:SetText("")
				self.onEnterFunc = nil
				if pendingToShow then
					stringData = select(2,next(pendingToShow))
					if not stringData then
						pendingToShow = nil
						return
					end
					tremove(pendingToShow, 1)
					C_Timer.After(0,function()
						exportWindow.Edit:SetText(stringData)
						exportWindow:Show()
					end)
				end
			end)
			exportWindow.Edit:SetScript("OnEditFocusGained", function(self)
				self:HighlightText()
			end)
			exportWindow.Edit:SetScript("OnMouseUp", function(self, button)
				self:HighlightText()
				if button == "RightButton" then
					self:GetParent():Hide()
				end
			end)
			exportWindow.Edit:SetScript("OnKeyUp", function(self, c)
				if (c == "c" or c == "C") and IsControlKeyDown() then
					self:GetParent():Hide()
				end
			end)
			exportWindow.Edit:SetScript("OnEnterPressed",function(self)
				if self:GetParent().onEnterFunc then
					self:GetParent().onEnterFunc(self:GetText())
					self:GetParent():Hide()
				end
			end)
			function exportWindow:OnShow()
				self.Edit:SetFocus()
			end
		elseif exportWindow:IsShown() then
			if not pendingToShow then
				pendingToShow = {}
			end
			pendingToShow[#pendingToShow+1] = stringData
			return

		end

		if type(stringData) == "function" then
			exportWindow.onEnterFunc = stringData
			stringData = ""
		else
			exportWindow.onEnterFunc = nil
		end

		if type(stringData) == "table" then
			stringData = table.concat(ExRT.F.TableToText(stringData))
		elseif type(stringData) ~= "string" then
			stringData = tostring(stringData)
		end

		exportWindow:NewPoint("CENTER",UIParent,0,0)
		exportWindow.Edit:SetText(stringData)
		exportWindow:Show()
	end
end

do
	local profilingWindow
	function ExRT.F:ProfilingWindow()
		if not profilingWindow then
			profilingWindow = ExRT.lib:Popup("Profiling"):Size(700,300)
			local self = profilingWindow

			profilingWindow.decorationLine = ELib:DecorationLine(self,true,"BACKGROUND",-5):Point("TOPLEFT",self,0,-15):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-35)

			profilingWindow.list = ELib:ScrollTableList(self,300,80,80,80,80,0):Size(700,300-35-25):Point("TOP",0,-35):FontSize(11):HideBorders()

			profilingWindow.headertext1 = ELib:Text(self,"  Event"):Point("LEFT",self.list,2,0):Point("TOP",self.decorationLine,0,0):Size(300,20):Left():Middle():Color():Shadow()
			profilingWindow.headertext2 = ELib:Text(self,"Total, ms"):Point("LEFT",self.headertext1,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(80,20):Left():Middle():Color():Shadow()
			profilingWindow.headertext3 = ELib:Text(self,"Count"):Point("LEFT",self.headertext2,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(80,20):Left():Middle():Color():Shadow()
			profilingWindow.headertext4 = ELib:Text(self,"Peak"):Point("LEFT",self.headertext3,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(80,20):Left():Middle():Color():Shadow()
			profilingWindow.headertext5 = ELib:Text(self,"Per 1, ms"):Point("LEFT",self.headertext4,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(80,20):Left():Middle():Color():Shadow()
			profilingWindow.headertext6 = ELib:Text(self,"Per sec, ms"):Point("LEFT",self.headertext5,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(80,20):Left():Middle():Color():Shadow()

			local t = 0
			profilingWindow:SetScript("OnUpdate",function(self,elapsed)
				t = t + elapsed
				if t < 0.5 then
					return
				end
				t = t % 0.5

				profilingWindow.nextBoss:SetEnabled(not ExRT.F:IsProfilingBoss())

				if not ExRT.Profiling.Start then
					return
				end

				local r,total = {},{"Total",0,"","","",0}
				local now = (ExRT.Profiling.End or debugprofilestop()) - ExRT.Profiling.Start
				for event in pairs(ExRT.Profiling.T) do
					local t = ExRT.Profiling.T[event]
					local c = ExRT.Profiling.C[event]
					local m = ExRT.Profiling.M[event]

					r[#r+1] = {event,format("%.1f",t),c,format("%.1f",m),format("%.1f",t/c),format("%.1f",t/now*1000),sort=t}

					total[2] = total[2] + t
				end
				sort(r,function(a,b) return a.sort>b.sort end)
				total[6] = format("%.1f",total[2] / now*1000)
				total[2] = format("%.1f",total[2])
				tinsert(r,1,total)

				if ExRT.F:IsProfilingBoss() and not ExRT.Profiling.BossStarted then
					wipe(r)
				end

				profilingWindow.list.L = r
				profilingWindow.list:Update()

				profilingWindow.startBut:SetText(ExRT.Profiling.Enabled and "Stop profiling" or "Start profiling")
			end)

			profilingWindow.startBut = ELib:Button(profilingWindow,"Start profiling"):Size(200,20):Point("BOTTOMLEFT",2,2):OnClick(function()
				ExRT.F:StartStopProfiling()
				t = 0.5
			end)
			profilingWindow.exportBut = ELib:Button(profilingWindow,"Export to string"):Size(200,20):Point("LEFT",profilingWindow.startBut,"RIGHT",2,0):OnClick(function()
				ExRT.F:GetProfiling()
			end)
			profilingWindow.nextBoss = ELib:Button(profilingWindow,"Next boss encounter"):Size(200,20):Point("LEFT",profilingWindow.exportBut,"RIGHT",2,0):OnClick(function()
				ExRT.F:StartProfilingBoss()
			end)
		end

		profilingWindow:NewPoint("TOPLEFT",UIParent,5,-5)
		profilingWindow:Show()
	end
end


do
	local function StringToText(str)
		if str:find("\n") then
			local n = 0
			if str:find("%]$") then
				n = n + 1
			end
			while str:find("%["..string.rep("=",n).."%[") or str:find("%]"..string.rep("=",n).."%]") do
				n = n + 1
			end
			return "["..string.rep("=",n).."["..str.."]"..string.rep("=",n).."]", true
		else
			return "\""..str:gsub("\\","\\\\"):gsub("\"","\\\"").."\""
		end
	end

	local function IterateTable(t)
		local prev
		local index = 1
		local indexMax
		local isIndexDone
		local function it()
			if not indexMax then
				local v = t[index]
				if v then
					index = index + 1
					return index-1, v, true
				else
					indexMax = index - 1
				end
			end
			local k,v = next(t,prev)
			prev = k
			while k and type(k)=="number" and k >= 1 and k <= indexMax do
				k,v = next(t,prev)
				prev = k
			end
			return k, v, false
		end
		return it
	end

	function ExRT.F.TableToText(t,e,b)
		b = b or {}
		b[t] = true
		e = e or {"{"}
		local ignoreIndex = false
		for k,v,isIndex in IterateTable(t) do
			local newline = ""
			local ignore = true
			if type(v) == "boolean" or type(v) == "number" or type(v) == "string" or type(v) == "table" then
				ignore = false
			end
			if type(v) == "table" and b[v] then
				ignore = true
			end
			if ignore then
				ignoreIndex = true
			elseif isIndex and not ignoreIndex then
			elseif type(k)=="number" then
				newline = newline .. "["..k.."]="
			elseif type(k)=="string" then
				if k:match("[A-Za-z_][A-Za-z_0-9]*") == k then
					newline = newline .. k .. "="
				else
					local kstr, ismultiline = StringToText(k)
					newline = newline .. "["..(ismultiline and " " or "")..kstr..(ismultiline and " " or "").."]="
				end
			elseif type(k)=="boolean" then
				newline = newline .. "["..(k and "true" or "false").."]="
			else
				ignore = true
			end
			if not ignore then
				local tableToExplore
				if type(v)=="number" then
					newline = newline .. v .. ","
				elseif type(v)=="string" then
					newline = newline .. StringToText(v)..","
				elseif type(v)=="boolean" then
					newline = newline ..(v and "true" or "false")..","
				elseif type(v)=="table" then
					newline = newline .."{"
					tableToExplore = v
				end
				e[#e+1] = newline
				if tableToExplore then
					ExRT.F.TableToText(tableToExplore,e,b)
					e[#e] = e[#e] .. ","
				end
			end
		end
		e[#e] = e[#e]:gsub(",$","")
		e[#e+1] = "}"
		return e
	end

	local string_byte = string.byte
	function ExRT.F.TextToTable(str,map,offset)
		if not map and string_byte(str, 1) == 123 then
			str = str:sub(2,-2)
		end
		local strlen = str:len()
		local i = 1
		local prev = 1
		map = map or {}
		offset = offset or 0

		local inTable, inString, inWideString
		local startTable, wideStringEqCount = 1, 0

		while i <= strlen do
			local b1 = string_byte(str, i)
			if not inString and not inTable and b1 == 123 then
				inTable = 0
				startTable = i
			elseif not inString and inTable and b1 == 123 then
				inTable = inTable + 1
			elseif not inString and inTable and b1 == 125 then
				if inTable == 0 then
					map[startTable+offset] = i + offset
					map[startTable+0.5+offset] = 1
					inTable = false
				else
					inTable = inTable - 1
				end
			elseif not inString and b1 == 34 then
				if map[i+offset+0.5] == 2 then
					i = map[i+offset] - offset
				else
					inString = i
				end
			elseif inString and not inWideString and b1 == 92 then
				i = i + 1
			elseif inString and not inWideString and b1 == 34 then
				map[inString+offset] = i + offset
				map[inString+0.5+offset] = 2
				inString = false
			elseif not inString and b1 == 91 then
				if map[i+offset+0.5] == 3 then
					i = map[i+offset] - offset
				else
					local k = i + 1
					local eqc = 0
					while k <= strlen do
						local c1 = string_byte(str, k)
						if c1 == 61 then
							eqc = eqc + 1
						elseif c1 == b1 then
							inString = i
							inWideString = i
							i = k
							wideStringEqCount = eqc
							break
						else
							break
						end
						k = k + 1
					end
				end
			elseif inString and inWideString and b1 == 93 then
				local k = i + 1
				local eqc = 0
				while k <= strlen do
					local c1 = string_byte(str, k)
					if c1 == 61 then
						eqc = eqc + 1
					elseif c1 == b1 then
						if eqc == wideStringEqCount then
							i = k
							map[inWideString+offset] = i + offset
							map[inWideString+0.5+offset] = 3
							inString = false
							inWideString = false
						end
						break
					else
						break
					end
					k = k + 1
				end
			end
			if not inString and not inTable and (b1 == 44 or i == strlen) then
				map[-prev-offset] = i - (b1 == 44 and 1 or 0) + offset
				prev = i + 1
			end
			i = i + 1
		end

		local res = {}
		local numKey = 1
		i = 1
		while i <= strlen do
			if map[-i-offset] then
				local s, e = i, map[-i-offset] - offset
				local k = s
				local key, value
				local isError
				prev = k
				while k <= e do
					if map[k+offset] then
						if map[k+0.5+offset] == 1 then
							value = ExRT.F.TextToTable( str:sub(k+1,map[k+offset]-offset-1) ,map,k+offset)
						elseif map[k+0.5+offset] == 2 then
							value = str:sub(k + 1,map[k+offset]-offset-1):gsub("\\\"","\""):gsub("\\\\","\\")
						elseif map[k+0.5+offset] == 3 then
							value = str:sub(k,map[k+offset]-offset):gsub("^%[=*%[",""):gsub("%]=*%]$","")
						end
						k = map[k+offset] + 1 - offset
					else
						local b1 = string_byte(str, k)
						if b1 == 61 then
							if value then
								key = value
								value = nil
							else
								key = str:sub(prev, k-1):trim()
								if key:find("^%[") and key:find("%]$") then
									key = key:gsub("^%[",""):gsub("%]$","")
									if tonumber(key) then
										key = tonumber(key)
									end
								elseif key == "true" then
									key = true
								elseif key == "false" then
									key = false
								elseif tonumber(key) then
									key = tonumber(key)
								else
									key = key:match("[A-Za-z_][A-Za-z_0-9]*")
								end
								if not key then
									isError = true
									break
								end
							end
							prev = k + 1
						elseif k == e and not value then
							value = str:sub(prev, k):trim()
							if value == "true" then
								value = true
							elseif value == "false" then
								value = false
							else
								value = tonumber(value)
							end
						end
						k = k + 1
					end
				end
				if not isError then
					if not key then
						key = numKey
						numKey = numKey + 1
					end
					res[key] = value
				end
				i = map[-i-offset] - offset
			end
			i = i + 1
		end
		return res
	end

	function ExRT.F.CreateImportExportWindows()
		local function ImportOnUpdate(self, elapsed)
			self.tmr = self.tmr + elapsed
			if self.tmr >= 0.1 then
				self.tmr = 0
				self:SetScript("OnUpdate",nil)
				local str = table.concat(self.buff):trim()
				self.parent:Hide()

				self.buff = {}
				self.buffPos = 0

				if self.parent.ImportFunc then
					self.parent:ImportFunc(str)
				end
			end
		end

		local importWindow = ELib:Popup(ExRT.L.Import.." "..ExRT.L.ImportHelp):Size(650,100)
		importWindow.Edit = ELib:MultiEdit(importWindow):Point("TOP",0,-20):Size(640,75)
		importWindow:SetScript("OnHide",function(self)
			self.Edit:SetText("")
		end)
		importWindow:SetScript("OnShow",function(self)
			self.Edit.EditBox.buffPos = 0
			self.Edit.EditBox.tmr = 0
			self.Edit.EditBox.buff = {}
			self.Edit.EditBox:SetFocus()
		end)
		importWindow.Edit.EditBox:SetMaxBytes(1)
		importWindow.Edit.EditBox:SetScript("OnChar", function(self, c)
			self.buffPos = self.buffPos + 1
			self.buff[self.buffPos] = c
			self:SetScript("OnUpdate",ImportOnUpdate)
		end)
		importWindow.Edit.EditBox.parent = importWindow


		local exportWindow = ELib:Popup(ExRT.L.Export):Size(650,50)
		exportWindow.Edit = ELib:Edit(exportWindow):Point("TOP",0,-20):Size(640,25)
		exportWindow:SetScript("OnHide",function(self)
			self.Edit:SetText("")
		end)
		exportWindow.Edit:SetScript("OnEditFocusGained", function(self)
			self:HighlightText()
		end)
		exportWindow.Edit:SetScript("OnMouseUp", function(self, button)
			self:HighlightText()
			if button == "RightButton" then
				self:GetParent():Hide()
			end
		end)
		exportWindow.Edit:SetScript("OnKeyUp", function(self, c)
			if (c == "c" or c == "C") and IsControlKeyDown() then
				self:GetParent():Hide()
			end
		end)
		function exportWindow:OnShow()
			self.Edit:SetFocus()
		end

		return importWindow, exportWindow
	end
end


ExRT.GDB.ClassSpecializationIcons = {
	[62] = "Interface\\Icons\\Spell_Holy_MagicalSentry",
	[63] = "Interface\\Icons\\Spell_Fire_FireBolt02",
	[64] = "Interface\\Icons\\Spell_Frost_FrostBolt02",
	[65] = "Interface\\Icons\\Spell_Holy_HolyBolt",
	[66] = "Interface\\Icons\\Ability_Paladin_ShieldoftheTemplar",
	[70] = "Interface\\Icons\\Spell_Holy_AuraOfLight",
	[71] = "Interface\\Icons\\Ability_Warrior_SavageBlow",
	[72] = "Interface\\Icons\\Ability_Warrior_InnerRage",
	[73] = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
	[102] = "Interface\\Icons\\Spell_Nature_StarFall",
	[103] = "Interface\\Icons\\Ability_Druid_CatForm",
	[104] = "Interface\\Icons\\Ability_Racial_BearForm",
	[105] = "Interface\\Icons\\Spell_Nature_HealingTouch",
	[250] = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
	[251] = "Interface\\Icons\\Spell_Deathknight_FrostPresence",
	[252] = "Interface\\Icons\\Spell_Deathknight_UnholyPresence",
	[253] = "Interface\\Icons\\Ability_Hunter_BeastTaming",
	[254] = "Interface\\Icons\\Ability_Marksmanship",
	[255] = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
	[256] = "Interface\\Icons\\Spell_Holy_PowerWordShield",
	[257] = "Interface\\Icons\\Spell_Holy_GuardianSpirit",
	[258] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
	[259] = "Interface\\Icons\\Ability_Rogue_DeadlyBrew",
	[260] = "Interface\\Icons\\Ability_BackStab",
	[261] = "Interface\\Icons\\Ability_Stealth",
	[262] = "Interface\\Icons\\Spell_Nature_Lightning",
	[263] = "Interface\\Icons\\Spell_Shaman_ImprovedStormstrike",
	[264] = "Interface\\Icons\\Spell_Nature_MagicImmunity",
	[265] = "Interface\\Icons\\Spell_Shadow_DeathCoil",
	[266] = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
	[267] = "Interface\\Icons\\Spell_Shadow_RainOfFire",
}

ExRT.GDB.ClassList = {
	"WARRIOR",
	"PALADIN",
	"HUNTER",
	"ROGUE",
	"PRIEST",
	"DEATHKNIGHT",
	"SHAMAN",
	"MAGE",
	"WARLOCK",
	"DRUID",
}

ExRT.GDB.ClassSpecializationList = {
	["WARRIOR"] = {71, 72, 73},
	["PALADIN"] = {65, 66, 70},
	["HUNTER"] = {253, 254, 255},
	["ROGUE"] = {259, 260, 261},
	["PRIEST"] = {256, 257, 258},
	["DEATHKNIGHT"] = {250, 251, 252},
	["SHAMAN"] = {262, 263, 264},
	["MAGE"] = {62, 63, 64},
	["WARLOCK"] = {265, 266, 267},
	["DRUID"] = {102, 103, 105},
}

ExRT.GDB.ClassArmorType = {
	WARRIOR="PLATE",
	PALADIN="PLATE",
	HUNTER="MAIL",
	ROGUE="LEATHER",
	PRIEST="CLOTH",
	DEATHKNIGHT="PLATE",
	SHAMAN="MAIL",
	MAGE="CLOTH",
	WARLOCK="CLOTH",
	DRUID="LEATHER",
}

ExRT.GDB.ClassSpecializationRole = {
	[62] = 'RANGE',
	[63] = 'RANGE',
	[64] = 'RANGE',
	[65] = 'HEAL',
	[66] = 'TANK',
	[70] = 'MELEE',
	[71] = 'MELEE',
	[72] = 'MELEE',
	[73] = 'TANK',
	[102] = 'RANGE',
	[103] = 'MELEE',
	[105] = 'HEAL',
	[250] = 'TANK',
	[251] = 'MELEE',
	[252] = 'MELEE',
	[253] = 'RANGE',
	[254] = 'RANGE',
	[255] = 'MELEE',
	[256] = 'HEAL',
	[257] = 'HEAL',
	[258] = 'RANGE',
	[259] = 'MELEE',
	[260] = 'MELEE',
	[261] = 'MELEE',
	[262] = 'RANGE',
	[263] = 'MELEE',
	[264] = 'HEAL',
	[265] = 'RANGE',
	[266] = 'RANGE',
	[267] = 'RANGE',
}

ExRT.GDB.ClassID = {
	WARRIOR=1,
	PALADIN=2,
	HUNTER=3,
	ROGUE=4,
	PRIEST=5,
	DEATHKNIGHT=6,
	SHAMAN=7,
	MAGE=8,
	WARLOCK=9,
	DRUID=11,
}

if ExRT.isClassic then

	local classLocalizateEngine = {}
	if LocalizedClassList then
		local classList = LocalizedClassList()
		MergeTable(classLocalizateEngine, classList)
	elseif FillLocalizedClassList then
		FillLocalizedClassList(classLocalizateEngine)
	end

	local classIDToToken = {}
	for token, cid in pairs(ExRT.GDB.ClassID or {}) do
		classIDToToken[cid] = token
	end
	ExRT.Classic.GetClassInfo = function(id)
		local token = classIDToToken[id] or (ExRT.GDB.ClassList and ExRT.GDB.ClassList[id])
		return token and classLocalizateEngine[token] or "unk"
	end


	local specializationData = {
		[62] = {name="Arcane",class=8,role="DAMAGER",desc="Manipulates raw Arcane magic, destroying enemies with overwhelming power.|n|nPreferred Weapon: Staff, Wand, Dagger, Sword",icon=135932},
		[63] = {name="Fire",class=8,role="DAMAGER",desc="Focuses the pure essence of Fire magic, assaulting enemies with combustive flames.|n|nPreferred Weapon: Staff, Wand, Dagger, Sword",icon=135810},
		[64] = {name="Frost",class=8,role="DAMAGER",desc="Freezes enemies in their tracks and shatters them with Frost magic.|n|nPreferred Weapon: Staff, Wand, Dagger, Sword",icon=135846},
		[65] = {name="Holy",class=2,role="HEALER",desc="Invokes the power of the Light to heal and protect allies and vanquish evil from the darkest corners of the world.|n|nPreferred Weapon: Sword, Mace, and Shield",icon=135920},
		[66] = {name="Protection",class=2,role="TANK",desc="Uses Holy magic to shield $Ghimself:herself; and defend allies from attackers.|n|nPreferred Weapon: Sword, Mace, Axe, and Shield",icon=236264},
		[70] = {name="Retribution",class=2,role="DAMAGER",desc="A righteous crusader who judges and punishes opponents with weapons and Holy magic.|n|nPreferred Weapon: Two-Handed Sword, Mace, Axe",icon=135873},
		[71] = {name="Arms",class=1,role="DAMAGER",desc="A battle-hardened master of weapons, using mobility and overpowering attacks to strike $Ghis:her; opponents down.|n|nPreferred Weapon: Two-Handed Axe, Mace, Sword",icon=132355},
		[72] = {name="Fury",class=1,role="DAMAGER",desc="A furious berserker unleashing a flurry of attacks to carve $Ghis:her; opponents to pieces.|n|nPreferred Weapons: Dual Two-Handed Axes, Maces, Swords",icon=132347},
		[73] = {name="Protection",class=1,role="TANK",desc="A stalwart protector who uses a shield to safeguard $Ghimself:herself; and $Ghis:her; allies.|n|nPreferred Weapon: Axe, Mace, Sword, and Shield",icon=132341},
		[74] = {name="Ferocity",class=0,role="DAMAGER",desc="Driven by a frenzied persistence to pursue prey, these beasts stop at nothing to achieve victory; even death is temporary for these predators.",icon=236159},
		[79] = {name="Cunning",class=0,role="DAMAGER",desc="",icon=132150},
		[81] = {name="Tenacity",class=0,role="TANK",desc="",icon=132121},
		[102] = {name="Balance",class=11,role="DAMAGER",desc="Can shapeshift into a powerful Moonkin, balancing the power of Arcane and Nature magic to destroy enemies.|n|nPreferred Weapon: Staff, Dagger, Mace",icon=136096},
		[103] = {name="Feral",class=11,role="DAMAGER",desc="Takes on the form of a great cat to deal damage with bleeds and bites.|n|nPreferred Weapon: Staff, Polearm",icon=132115},
		[105] = {name="Restoration",class=11,role="HEALER",desc="Channels powerful Nature magic to regenerate and revitalize allies.|n|nPreferred Weapon: Staff, Dagger, Mace",icon=136041},
		[250] = {name="Blood",class=6,role="TANK",desc="A dark guardian who manipulates and corrupts life energy to sustain $Ghimself:herself; in the face of an enemy onslaught.|n|nPreferred Weapon: Two-Handed Axe, Mace, Sword",icon=135770},
		[251] = {name="Frost",class=6,role="DAMAGER",desc="An icy harbinger of doom, channeling runic power and delivering vicious weapon strikes.|n|nPreferred Weapons: Dual Axes, Maces, Swords",icon=135773},
		[252] = {name="Unholy",class=6,role="DAMAGER",desc="A master of death and decay, spreading infection and controlling undead minions to do $Ghis:her; bidding.|n|nPreferred Weapon: Two-Handed Axe, Mace, Sword",icon=135775},
		[253] = {name="Beast Mastery",class=3,role="DAMAGER",desc="A master of the wild who can tame a wide variety of beasts to assist $Ghim:her; in combat.|n|nPreferred Weapon: Bow, Crossbow, Gun",icon="Interface\\Icons\\Ability_Hunter_BeastTaming"},
		[254] = {name="Marksmanship",class=3,role="DAMAGER",desc="A master sharpshooter who excels in bringing down enemies from afar.|n|nPreferred Weapon: Bow, Crossbow, Gun",icon="Interface\\Icons\\Ability_Marksmanship"},
		[255] = {name="Survival",class=3,role="DAMAGER",desc="An adaptive ranger who favors using explosives, animal venom, and coordinated attacks with their bonded beast.|n|nPreferred Weapon: Polearm, Staff",icon="Interface\\Icons\\Ability_Hunter_SwiftStrike"},
		[256] = {name="Discipline",class=5,role="HEALER",desc="Uses magic to shield allies from taking damage as well as heal their wounds.|n|nPreferred Weapon: Staff, Wand, Dagger, Mace",icon=135940},
		[257] = {name="Holy",class=5,role="HEALER",desc="A versatile healer who can reverse damage on individuals or groups and even heal from beyond the grave.|n|nPreferred Weapon: Staff, Wand, Dagger, Mace",icon=237542},
		[258] = {name="Shadow",class=5,role="DAMAGER",desc="Uses sinister Shadow magic and terrifying Void magic to eradicate enemies.|n|nPreferred Weapon: Staff, Wand, Dagger, Mace",icon=136207},
		[259] = {name="Assassination",class=4,role="DAMAGER",desc="A deadly master of poisons who dispatches victims with vicious dagger strikes.|n|nPreferred Weapons: Daggers",icon=236270},
		[260] = {name="Combat",class=4,role="DAMAGER",desc="A swashbuckler who uses agility and guile to stand toe-to-toe with enemies.|n|nPreferred Weapons: Axes, Maces, Swords, Fist Weapons",icon="Interface\\Icons\\Ability_BackStab"},
		[261] = {name="Subtlety",class=4,role="DAMAGER",desc="A dark stalker who leaps from the shadows to ambush $Ghis:her; unsuspecting prey.|n|nPreferred Weapons: Daggers",icon=132320},
		[262] = {name="Elemental",class=7,role="DAMAGER",desc="A spellcaster who harnesses the destructive forces of nature and the elements.|n|nPreferred Weapon: Mace, Dagger, and Shield",icon=136048},
		[263] = {name="Enhancement",class=7,role="DAMAGER",desc="A totemic warrior who strikes foes with weapons imbued with elemental power.|n|nPreferred Weapons: Dual Axes, Maces, Fist Weapons",icon=237581},
		[264] = {name="Restoration",class=7,role="HEALER",desc="A healer who calls upon ancestral spirits and the cleansing power of water to mend allies' wounds.|n|nPreferred Weapon: Mace, Dagger, and Shield",icon=136052},
		[265] = {name="Affliction",class=9,role="DAMAGER",desc="A master of shadow magic who specializes in drains and damage-over-time spells.|n|nPreferred Weapon: Staff, Wand, Dagger, Sword",icon=136145},
		[266] = {name="Demonology",class=9,role="DAMAGER",desc="A commander of demons who twists the souls of $Ghis:her; army into devastating power.|n|nPreferred Weapon: Staff, Wand, Dagger, Sword",icon=136172},
		[267] = {name="Destruction",class=9,role="DAMAGER",desc="A master of chaos who calls down fire to burn and demolish enemies.|n|nPreferred Weapon: Staff, Wand, Dagger, Sword",icon=136186},
	}

	ExRT.Classic.GetSpecializationInfoByID = function(id)
		local data = specializationData[id] or ExRT.NULL
		return id, data.name, data.desc, data.icon, data.role, ExRT.GDB.ClassList[data.class]
	end
end

ExRT.GDB.JournalInstance = {
{0,64,238,63,240,234,227,239,231,237,233,241,229,228,236,232,226,230,311,316,246,0,741,742,743,744},
{1,255,259,256,248,261,262,260,254,257,258,253,252,250,247,251,249,0,745,750,747,748,749,751,746,752},
{2,285,286,281,282,279,277,273,272,275,274,283,271,280,284,278,276,0,760,754,759,755,756,753,758,757,761},
{3,64,63,77,65,70,66,68,71,67,69,76,184,185,186,0,73,72,78,74,75,187},
{4,312,313,302,303,321,311,316,246,324,0,322,320,317,330,362,369},
{5,385,537,547,558,536,476,556,559,0,457,477,557,669},
{6,716,767,762,721,727,707,740,726,777,800,860,900,945,0,768,822,959,786,861,875,946},
{7,1012,1001,1041,968,1002,1023,1022,1021,1036,1030,1178,0,1028,1031,1176,1177,1179,1180},
{8,1189,1186,1182,1185,1183,1184,1188,1187,1194,0,1190,1193,1195,1192},
{9,1197,1203,1198,1199,1196,1202,1201,1204,1209,0,1200,1207,1208,1205},
{-1,65,68,313,537,556,767,762,721,740,800,1001,968,1022,1021,1197,1203,1198,1199,1196,1202,1201,1204,1209,0,1200,1207,1208,1205,n=EXPANSION_NAME9,s=4},
{-1,1270,1271,1274,1269,1182,1184,1023,71,n=EXPANSION_NAME10,s=1},
{10,1268,1267,1210,1269,1271,1272,1270,1274,1298,1303,0,1273,1296,1278,1302},
}


ExRT.GDB.MapIDToJournalInstance = {
[2830]=1303,[2810]=1302,[2792]=1301,[2774]=1278,[2773]=1298,[2769]=1296,[2669]=1274,[2662]=1270,[2661]=1272,[2660]=1271,[2657]=1273,[2652]=1269,[2651]=1210,[2649]=1267,[2648]=1268,[2579]=1209,[2574]=1205,
[2569]=1208,[2559]=1192,[2549]=1207,[2527]=1204,[2526]=1201,[2522]=1200,[2521]=1202,[2520]=1196,[2519]=1199,[2516]=1198,[2515]=1203,[2481]=1195,[2451]=1197,[2450]=1193,[2441]=1194,[2296]=1190,[2293]=1187,
[2291]=1188,[2290]=1184,[2289]=1183,[2287]=1185,[2286]=1182,[2285]=1186,[2284]=1189,[2217]=1180,[2164]=1179,[2097]=1178,[2096]=1177,[2070]=1176,[1877]=1030,[1864]=1036,[1862]=1021,[1861]=1031,[1861]=1031,
[1841]=1022,[1822]=1023,[1771]=1002,[1763]=968,[1762]=1041,[1754]=1001,[1753]=945,[1712]=946,[1677]=900,[1676]=875,[1651]=860,[1648]=861,[1594]=1012,[1571]=800,[1544]=777,[1530]=786,[1520]=959,[1520]=959,
[1520]=959,[1516]=726,[1501]=740,[1493]=707,[1492]=727,[1477]=721,[1466]=762,[1458]=767,[1456]=716,[1448]=669,[1358]=559,[1279]=556,[1228]=557,[1228]=557,[1209]=476,[1208]=536,[1205]=457,[1195]=558,[1182]=547,
[1176]=537,[1175]=385,[1136]=369,[1098]=362,[1011]=324,[1009]=330,[1008]=317,[1007]=246,[1004]=316,[1001]=311,[996]=322,[996]=322,[994]=321,[967]=187,[962]=303,[961]=302,[960]=313,[959]=312,[940]=186,[939]=185,
[938]=184,[859]=76,[757]=75,[755]=69,[754]=74,[725]=67,[724]=761,[720]=78,[671]=72,[670]=71,[669]=73,[668]=276,[658]=278,[657]=68,[650]=284,[649]=757,[645]=66,[644]=70,[643]=65,[632]=280,[631]=758,[624]=753,
[619]=271,[616]=756,[615]=755,[608]=283,[604]=274,[603]=759,[602]=275,[601]=272,[600]=273,[599]=277,[595]=279,[585]=249,[580]=752,[578]=282,[576]=281,[575]=286,[574]=285,[568]=77,[565]=746,[564]=751,[560]=251,
[558]=247,[557]=250,[556]=252,[555]=253,[554]=258,[553]=257,[552]=254,[550]=749,[548]=748,[547]=260,[546]=262,[545]=261,[544]=747,[543]=248,[542]=256,[540]=259,[534]=750,[533]=754,[532]=745,[531]=744,[509]=743,
[469]=742,[429]=1277,[429]=1277,[429]=1277,[409]=741,[389]=226,[349]=232,[329]=1292,[329]=1292,[269]=255,[249]=760,[230]=228,[229]=229,[209]=241,[129]=233,[109]=237,[90]=231,[70]=239,[48]=227,[47]=234,
[43]=240,[36]=63,[34]=238,[33]=64,
}

ExRT.GDB.RaidIconByMapID = {
	[724] = "Interface\\Icons\\Spell_shadow_twilight",
	[631] = "Interface\\Icons\\Achievement_dungeon_icecrown_icecrownentrance",
	[649] = "Interface\\Icons\\Achievement_reputation_argentchampion",
	[249] = "Interface\\Icons\\Achievement_boss_generaldrakkisath",
	[248] = "Interface\\Icons\\Achievement_boss_generaldrakkisath",
	[603] = "Interface\\Icons\\Spell_shadow_shadesofdarkness",
	[616] = "Interface\\Icons\\Achievement_dungeon_nexusraid_25man",
	[615] = "Interface\\Icons\\Achievement_dungeon_coablackdragonflight_10man",
	[533] = "Interface\\Icons\\Inv_trinket_naxxramas06",
	[99533] = "Interface\\Icons\\Inv_trinket_naxxramas06",
	[580] = "Interface\\Icons\\Achievement_boss_kiljaedan",
	[568] = "Interface\\Icons\\Achievement_boss_zuljin",
	[564] = "Interface\\Icons\\Achievement_boss_illidan",
	[534] = "Interface\\Icons\\Achievement_boss_archimonde ",
	[550] = "Interface\\Icons\\Achievement_character_bloodelf_male",
	[548] = "Interface\\Icons\\Achievement_boss_ladyvashj",
	[544] = "Interface\\Icons\\Achievement_boss_magtheridon",
	[565] = "Interface\\Icons\\Achievement_boss_gruulthedragonkiller",
	[532] = "Interface\\Icons\\Achievement_boss_princemalchezaar_02",
	[531] = "Interface\\Icons\\Achievement_boss_cthun",
	[509] = "Interface\\Icons\\Achievement_boss_ossiriantheunscarred",
	[309] = "Interface\\Icons\\Achievement_boss_hakkar",
	[469] = "Interface\\Icons\\Achievement_boss_nefarion",
	[409] = "Interface\\Icons\\Achievement_boss_ragnaros",
}

ExRT.GDB.RaidGroupByMapID = {
	[724] = "wotlk", [631] = "wotlk", [649] = "wotlk", [249] = "wotlk",
	[603] = "wotlk", [616] = "wotlk", [615] = "wotlk", [533] = "wotlk",
	[580] = "tbc",  [568] = "tbc",  [564] = "tbc",  [534] = "tbc",
	[550] = "tbc",  [548] = "tbc",  [544] = "tbc",  [565] = "tbc",
	[532] = "tbc",
	[99533] = "classic", [531] = "classic", [509] = "classic",
	[309] = "classic", [248] = "classic", [469] = "classic", [409] = "classic",
}

ExRT.GDB.RaidSortInGroup = {
	[724] = 1, [631] = 2, [649] = 3, [249] = 4, [603] = 5, [616] = 6, [615] = 7, [533] = 8,
	[580] = 1, [568] = 2, [564] = 3, [534] = 4, [550] = 5, [548] = 6, [544] = 7, [565] = 8, [532] = 9,
	[99533] = 1, [531] = 2, [509] = 3, [309] = 4, [248] = 5, [469] = 6, [409] = 7,
}

ExRT.GDB.EncountersList = {
	{350,652,653,654,655,656,657,658,659,660,661,662},
	{129,519,520,2009,522,521,2010,2011,524,523,525,526,2012,527},
	{130,2002,2003,2004,2005},
	{132,1969,1966,1967,1989,1968},
	{133,2026,2024,2025},
	{136,2030,2027,2029,2028},
	{138,1987,1985,1984,1986},
	{140,1994,1996,1995,1998},
	{142,528,2013,530,529,2014,2015,532,531,533,534,2016,535},
	{153,1978,1983,1980,1988,1981},
	{156,1126,1127,1128,1129},
	{157,1971,1972,1973},
	{160,1974,1976,1977,1975},
	{168,2018,2019,2020},
	{171,2022,2023,2021},
	{183,2006,2007},
	{184,1999,2001,2000},
	{185,1992,1993,1990},
	{213,1443,1444,1445,1446},
	{219,593,594,595,596,597,598,599,600},
	{220,492,488,486,487,490,491,493},
	{221,1667,1668,1669,1675,1676,1670,1671,1672},
	{225,1144,1145,1146},
	{226,379,378,380,381,382},
	{230,547,548,549,551,552,553,554,1887},
	{233,785,784,786,787,788,789,790,791,792,793},
	{234,343,344,345,346,350,347,348,349,361,362,363,364,365,366,367,368},
	{242,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245},
	{246,1935,1936,1937,1938},
	{247,718,719,720,721,722,723},
	{250,267,268,269,270,271,272,274,273,275},
	{256,1889,1890},
	{258,1902,1903,1904},
	{260,1908,1909,1910,1911},
	{261,1922,1923,1924},
	{262,1945,1946,1947,1948},
	{263,1942,1943,1944},
	{265,1939,1940,1941},
	{266,1925,1926,1927,1928,1929},
	{267,1930,1931,1932,1933,1934},
	{269,1913,1914,1915,1916},
	{272,1899,1900,250,1901},
	{273,1919,1920,1921},
	{274,1905,1906,1907},
	{277,1052,1053,1054,1055},
	{279,585,586,587,588,589,590,591,592},
	{280,422,423,427,424,425,426,428,429},
	{282,1033,1250,1332},
	{283,1040,1038,1039,1037,1036},
	{291,1064,1065,1063,1062,1060,1081},
	{293,1051,1050,1048,1049},
	{297,1080,1076,1075,1077,1074,1079,1078},
	{300,1662,1663,1664,1665,1666},
	{301,1656,438,1659,1660,1661},
	{302,444,446,447,448,449,450},
	{306,451,452,453,454,455,456,457,458,459,460,461,462,463},
	{310,1069,1070,1071,1073,1072},
	{317,473,474,476,475,477,478,472,479,480,481,482,483,484,1885},
	{322,1045,1044,1046,1047},
	{324,1056,1059,1058,1057},
	{325,1043,1041,1042},
	{333,1189,1190,1191,1192,1193,1194},
	{337,1178,1179,1188,1180,1181,1182},
	{347,1891,1892,1893},
	{348,1894,1895,1897,1898},
	{398,1272,1273,1274},
	{399,1337,1340,1339},
	{401,1881,1882,1883,1884,1271},
	{429,1418,1417,1416,1439},
	{431,1422,1421,1420},
	{435,1423,1424,1425},
	{437,1397,1405,1406,1419},
	{439,1412,1413,1414},
	{443,1303,1304,1305,1306},
	{453,1442,1509,1510,1441},
	{457,1465,1502,1447,1464},
	{476,1426,1427,1428,1429,1430},
	{554,1563,1564,1571,1587},
	{573,1655,1653,1652,1654},
	{574,1677,1688,1679,1682},
	{593,1686,1685,1678,1714},
	{595,1749,1748,1750,1754},
	{601,1698,1699,1700,1701},
	{606,1715,1732,1736},

	{616,1761,1758,1759,1760,1762},
	{620,1746,1757,1751,1752,1756},
	{624,1755,1770,1801},

	{703,1805,1806,1807,1808,1809},
	{708,1822,1823,1824},
	{710,1815,1850,1816,1817,1818},
	{713,1810,1811,1812,1813,1814},
	{731,1790,1791,1792,1793},
	{732,1845,1846,1847,1848,1851,1852,1855,1856},
	{733,1836,1837,1838,1839},
	{749,1825,1826,1827,1828,1829},
	{751,1832,1833,1834,1835},
	{761,1868,1869,1870},


	{232,663,664,665,666,667,668,669,670,671,672},
	{287,610,611,612,613,614,615,616,617},
	{319,709,710,711,712,713,714,715,716,717},
	{331,651},
	{330,649,650},
	{332,623,624,625,626,627,628},
	{334,730,731,732,733},
	{329,618,619,620,621,622},
	{339,601,602,603,604,605,606,607,608,609},
	{335,724,725,726,727,728,729},
	{162,1107,1110,1116,1117,1112,1115,1113,1109,1121,1118,1111,1108,1120,1119,1114},
	{155,1090},
	{141,1094},
	{147,1132,1136,1139,1142,1140,1137,1131,1135,1141,1133,1138,1134,1143,1130},
	{172,1088,1087,1086,1089,1085},
	{248,1084},
	{186,1101,1100,1099,1096,1104,1097,1102,1095,1103,1098,1105,1106},
	{200,1150},
	{285,1027,1024,1022,1023,1025,1026},
	{294,1030,1032,1028,1029,1082},
	{328,1035,1034},
	{367,1197,1204,1205,1206,1200,1185,1203},
	{409,1292,1294,1295,1296,1297,1298,1291,1299},
	{471,1395,1390,1434,1436,1500,1407},
	{474,1507,1504,1463,1498,1499,1501},
	{456,1409,1505,1506,1431},
	{508,1577,1575,1570,1565,1578,1573,1572,1574,1576,1559,1560,1579,1580},
	{556,1602,1598,1624,1604,1622,1600,1606,1603,1595,1594,1599,1601,1593,1623},

}

function ExRT.F.EJ_AutoScan()
	local TIER_MIN = 11

	local NEW_DATA = {
		encounterIDtoEJ = {},
		EncountersList_dung = {},
		EncountersList_raid = {},
		MapIDToJournalInstance = {},
		JournalInstance = {-2},
	}

	local encounterMap = {}
	local dungeonPosInsert = 1
	for i=1,#ExRT.GDB.EncountersList do
		local dung = ExRT.GDB.EncountersList[i]
		if dung[1] == 232 then
			dungeonPosInsert = i
		end
		for j=2,#dung do
			encounterMap[ dung[j] ] = true
		end
	end
	local instanceMap = {}
	for i=1,#ExRT.GDB.JournalInstance do
		local tier = ExRT.GDB.JournalInstance[i]
		for j=2,#tier do
			instanceMap[ tier[j] ] = true
		end
	end

	for i=TIER_MIN,EJ_GetNumTiers() do
		EJ_SelectTier(i)

		for j=1,2 do
			local isRaid = j == 1 and true or false

			local instanceIndex = 1
			while EJ_GetInstanceByIndex(instanceIndex,isRaid) do
				local instanceID, iname, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(instanceIndex,isRaid)

				EJ_SelectInstance(instanceID)

				local isNewInstance = true

				local EncountersList_new = {dungeonAreaMapID}
				if dungeonAreaMapID == 0 then
					isNewInstance = false
				end

				local encounterIndex = 1
				while EJ_GetEncounterInfoByIndex(encounterIndex, instanceID) do
					local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(encounterIndex, instanceID)

					EncountersList_new[#EncountersList_new+1] = dungeonEncounterID
					if dungeonEncounterID and encounterMap[dungeonEncounterID] then
						isNewInstance = false
					end

					if dungeonEncounterID and not ExRT.GDB.encounterIDtoEJ[dungeonEncounterID] then
						NEW_DATA.encounterIDtoEJ[dungeonEncounterID] = journalEncounterID
					end

					encounterIndex = encounterIndex + 1
				end

				if isNewInstance then
					if isRaid then
						tinsert(NEW_DATA.EncountersList_raid, EncountersList_new)
					elseif isNewInstance then
						tinsert(NEW_DATA.EncountersList_dung, EncountersList_new)
					end

					for k=2,#EncountersList_new do
						encounterMap[ EncountersList_new[k] ] = true
					end


				end

				if mapID and not ExRT.GDB.MapIDToJournalInstance[mapID] then
					NEW_DATA.MapIDToJournalInstance[mapID] = instanceID


				end

				if not instanceMap[instanceID] then
					instanceMap[instanceID] = true

					tinsert(NEW_DATA.JournalInstance, 2, instanceID)


				end

				instanceIndex = instanceIndex + 1
			end
		end
	end

	VMRT.Addon.EJ_CHECK_VER = ExRT.clientUIinterface
	VMRT.Addon.EJ_DATA = NEW_DATA
	VMRT.Addon.EJ_CHECK_VER_PTR = ExRT.clientBuildVersion

	ExRT.F.EJ_LoadData()
end
function ExRT.F.EJ_LoadData()
	if not VMRT.Addon.EJ_DATA then
		return
	end
	local NEW_DATA = VMRT.Addon.EJ_DATA

	local encounterMap = {}
	local dungeonPosInsert = 1
	for i=1,#ExRT.GDB.EncountersList do
		local dung = ExRT.GDB.EncountersList[i]
		if dung[1] == 232 then
			dungeonPosInsert = i
		end
		for j=2,#dung do
			encounterMap[ dung[j] ] = true
		end
	end

	for i=1,#NEW_DATA.EncountersList_raid do
		local new_dung = NEW_DATA.EncountersList_raid[i]
		if new_dung[2] and not encounterMap[ new_dung[2] ] then
			tinsert(ExRT.GDB.EncountersList, new_dung)
		end
	end
	for i=1,#NEW_DATA.EncountersList_dung do
		local new_dung = NEW_DATA.EncountersList_dung[i]
		if new_dung[2] and not encounterMap[ new_dung[2] ] then
			tinsert(ExRT.GDB.EncountersList, dungeonPosInsert, new_dung)
			dungeonPosInsert = dungeonPosInsert + 1
		end
	end

	for k,v in pairs(NEW_DATA.MapIDToJournalInstance) do
		if not ExRT.GDB.MapIDToJournalInstance[k] then
			ExRT.GDB.MapIDToJournalInstance[k] = v
		end
	end
	for k,v in pairs(NEW_DATA.encounterIDtoEJ) do
		if not ExRT.GDB.encounterIDtoEJ[k] then
			ExRT.GDB.encounterIDtoEJ[k] = v
		end
	end
	if #NEW_DATA.JournalInstance > 1 then
		tinsert(ExRT.GDB.JournalInstance,NEW_DATA.JournalInstance)
	end
end


local ACTUAL_RAID = 1735
local ACTUAL_DUNG = 1666
if UnitLevel'player' > 70 then
	ACTUAL_DUNG = 2316
	ACTUAL_RAID = 2292
elseif UnitLevel'player' > 60 then
	ACTUAL_DUNG = 2096
	ACTUAL_RAID = 2119
end

do
	local function StringVerToNumber(ver)
		local i = 0
		local r = 0
		for n in ver:gmatch("%d+") do
			r = r + tonumber(n) * (10 ^ i)
			i = i - 2
		end
		return r
	end
	local ver_now = StringVerToNumber(GetBuildInfo())
	for i=#ExRT.GDB.EncountersList,1,-1 do
		local t = ExRT.GDB.EncountersList[i]
		if type(t[1]) == "string" then
			if StringVerToNumber(t[1]) > ver_now then
				tremove(ExRT.GDB.EncountersList, i)
			else
				tremove(t, 1)
			end
		elseif t[1] == 2096 then

			break
		end
	end
	for i=#ExRT.GDB.JournalInstance,1,-1 do
		local t = ExRT.GDB.JournalInstance[i]
		if type(t[1]) == "string" then
			if StringVerToNumber(t[1]) > ver_now then
				tremove(ExRT.GDB.JournalInstance, i)
			else
				tremove(t, 1)
			end
		else
			for j=#t,2,-1 do
				if type(t[j]) == "string" then
					if StringVerToNumber(t[j]) > ver_now then
						tremove(t, j)
					end
					tremove(t, j)
				end
			end
		end
	end
end

local POST_WOTLK_THRESHOLD = 99999

local WOTLK_RAID_ORDER = {
	724, 631, 649, 249, 603, 616, 615, 533,
	580, 568, 564, 534, 550, 548, 544, 565, 532,
	99533, 531, 509, 309, 248, 469, 409,
}
local WOTLK_RAID_RANK = {}
for i, mapID in ipairs(WOTLK_RAID_ORDER) do
	WOTLK_RAID_RANK[mapID] = i
end
ExRT.GDB.WOTLK_RAID_ORDER = WOTLK_RAID_ORDER
ExRT.GDB.WOTLK_RAID_RANK = WOTLK_RAID_RANK

function ExRT.F.GetEncountersList(onlyRaid,onlyActual,reverse,onlyDung)
	local new = {}

	if ExRT.isWotLKOnly and onlyRaid and not onlyDung then
		local picked = {}
		for _,v in ipairs(ExRT.GDB.EncountersList) do
			if type(v[1]) == "number" and WOTLK_RAID_RANK[v[1]] and not picked[v[1]] then
				picked[v[1]] = true
				new[#new+1] = v
			end
		end
		sort(new, function(a,b) return WOTLK_RAID_RANK[a[1]] < WOTLK_RAID_RANK[b[1]] end)
		if reverse then
			local len = #new
			for i=1,floor(len/2) do
				new[i], new[len+1-i] = new[len+1-i], new[i]
			end
		end
		return new
	end

	local isActual,isRaid
	for _,v in ipairs(ExRT.GDB.EncountersList) do
		if v[1] == 232 then
			isRaid = true
			isActual = false
			if onlyDung then break end
		elseif v[1] == ACTUAL_DUNG then
			isActual = true
		elseif v[1] == ACTUAL_RAID then
			isActual = true
		end
		local allowed = true
		if ExRT.isWotLKOnly and type(v[1]) == "number" and v[1] > POST_WOTLK_THRESHOLD and v[1] ~= 232 then
			allowed = false
		end
		if allowed and ExRT.isWotLKOnly and onlyDung and type(v[1]) == "number" then
			if not (C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(v[1])) then
				allowed = false
			elseif WOTLK_RAID_RANK[v[1]] then
				allowed = false
			end
		end
		if allowed and (not onlyActual or isActual) and (not onlyRaid or isRaid) then
			new[#new+1] = v
		end
	end
	if reverse then
		local len = #new
		for i=1,floor(len/2) do
			new[i], new[len+1-i] = new[len+1-i], new[i]
		end
	end
	return new
end

do
	local cacheName, cacheTex, cacheUnknown = {}, {}, {}
	local scantip, scantipName = nil, "MRTSpellScanTooltip"
	local function ensureScan()
		if scantip then return scantip end
		scantip = CreateFrame("GameTooltip", scantipName, nil, "GameTooltipTemplate")
		scantip:SetOwner(UIParent, "ANCHOR_NONE")
		return scantip
	end

	-- Persist spell name/texture cache between sessions (VMRT.SpellCache):
	-- tooltip scans for spells missing from the 3.3.5a client are expensive,
	-- without persistence every relog repeats all of them (= UI freezes).
	local persistBound = false
	local function bindPersist()
		if persistBound then return end
		if type(VMRT) ~= "table" then return end
		VMRT.SpellCache = VMRT.SpellCache or {}
		local s = VMRT.SpellCache
		s.name = s.name or {}
		s.tex = s.tex or {}
		s.unk = s.unk or {}
		for k,v in pairs(cacheName) do s.name[k] = v end
		for k,v in pairs(cacheTex) do s.tex[k] = v end
		for k,v in pairs(cacheUnknown) do s.unk[k] = v end
		cacheName, cacheTex, cacheUnknown = s.name, s.tex, s.unk
		persistBound = true
	end

	-- Budget for synchronous tooltip scans: at most SCAN_BUDGET per frame,
	-- the rest are warmed up in the background via ticker (no freeze).
	local SCAN_BUDGET = 15
	local scanFrameTime, scanFrameCount = -1, 0
	local pendingScan, pendingTicker = {}, nil
	local function queueWarmUp(spellID)
		for i=1,#pendingScan do
			if pendingScan[i] == spellID then return end
		end
		pendingScan[#pendingScan+1] = spellID
		if pendingTicker then return end
		if not (C_Timer and C_Timer.NewTicker) then return end
		pendingTicker = C_Timer.NewTicker(0.05, function()
			local n = 0
			while n < 5 and #pendingScan > 0 do
				local id = table.remove(pendingScan)
				ExRT.F.WarmUpSpell(id, true)
				n = n + 1
			end
			if #pendingScan == 0 and pendingTicker then
				pendingTicker:Cancel()
				pendingTicker = nil
			end
		end)
	end

	function ExRT.F.WarmUpSpell(spellID, force)
		spellID = tonumber(spellID)
		if not spellID then return end
		bindPersist()
		if cacheName[spellID] and cacheTex[spellID] then return end
		if cacheUnknown[spellID] then return end
		if not force then
			local now = GetTime()
			if now ~= scanFrameTime then
				scanFrameTime, scanFrameCount = now, 0
			end
			if scanFrameCount >= SCAN_BUDGET then
				queueWarmUp(spellID)
				return
			end
			scanFrameCount = scanFrameCount + 1
		end
		local n0, _, tex0 = GetSpellInfo(spellID)
		if n0 and n0 ~= "" then cacheName[spellID] = n0 end
		if tex0 then cacheTex[spellID] = tex0 end
		if cacheName[spellID] and cacheTex[spellID] then return end
		local t = ensureScan()
		t:ClearLines()
		if GetSpellLink then pcall(GetSpellLink, spellID) end
		if GetSpellTexture then
			local tex1 = GetSpellTexture(spellID)
			if tex1 then cacheTex[spellID] = tex1 end
		end
		local ok = pcall(t.SetHyperlink, t, "spell:"..spellID)
		if not ok then
			if not cacheName[spellID] and not cacheTex[spellID] then
				cacheUnknown[spellID] = true
			end
			return
		end
		local line = _G[scantipName.."TextLeft1"]
		local name = line and line:GetText()
		if name and name ~= "" then
			cacheName[spellID] = name
		end
		local tex = GetSpellTexture and GetSpellTexture(spellID)
		if not tex then
			local _, _, t2 = GetSpellInfo(spellID)
			tex = t2
		end
		if tex then cacheTex[spellID] = tex end
		if not cacheName[spellID] and not cacheTex[spellID] then
			cacheUnknown[spellID] = true
		end
	end

	-- 3.3.5a: icon files load at draw time and can be evicted when no widget
	-- references them anymore (timeline rebuilds recreate widgets). Pin every
	-- icon we ever return on a rendered 2x2 px frame so the client keeps them
	-- in memory -> no repeated disk-load freezes on each timeline update.
	local pinFrame, pinned, pinnedCount = nil, {}, 0
	local function pin(tex)
		if type(tex) ~= "string" or pinned[tex] or pinnedCount >= 1000 then return tex end
		if not pinFrame then
			pinFrame = CreateFrame("Frame", nil, UIParent)
			pinFrame:SetSize(2, 2)
			pinFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
			pinFrame:SetAlpha(0.02)
			pinFrame:SetFrameStrata("BACKGROUND")
			pinFrame:Show()
		end
		local t = pinFrame:CreateTexture(nil, "BACKGROUND")
		t:SetAllPoints(pinFrame)
		t:SetTexture(tex)
		pinned[tex] = t
		pinnedCount = pinnedCount + 1
		-- a texture needs ~1 rendered frame to load; after that the kept object
		-- reference prevents unload, so hide it to avoid stacking draw calls
		pinFrame.toHide = pinFrame.toHide or {}
		pinFrame.toHide[#pinFrame.toHide+1] = t
		if not pinFrame.sweep and C_Timer and C_Timer.NewTicker then
			pinFrame.sweep = C_Timer.NewTicker(2, function()
				local list = pinFrame.toHide
				local keep = list[#list] -- newest may not have rendered yet
				for i=1,#list do
					if list[i] ~= keep then list[i]:Hide() end
					list[i] = nil
				end
				list[1] = keep
			end)
		end
		return tex
	end
	ExRT.F.PinTexture = pin

	function ExRT.F.GetSpellTextureSafe(spellID)
		if not spellID then return "Interface\\Icons\\INV_Misc_QuestionMark" end
		bindPersist()
		local id = tonumber(spellID)
		local tex = GetSpellTexture and GetSpellTexture(spellID)
		if tex then return pin(tex) end
		if id and cacheTex[id] then return pin(cacheTex[id]) end
		local _, _, infoTex = GetSpellInfo(spellID)
		if infoTex then if id then cacheTex[id] = infoTex end return pin(infoTex) end
		ExRT.F.WarmUpSpell(spellID)
		tex = (GetSpellTexture and GetSpellTexture(spellID)) or (id and cacheTex[id])
		if tex then return pin(tex) end
		_, _, tex = GetSpellInfo(spellID)
		return pin(tex or "Interface\\Icons\\INV_Misc_QuestionMark")
	end

	function ExRT.F.GetSpellInfoSafe(spellID)
		if not spellID then return nil end
		bindPersist()
		local id = tonumber(spellID)
		local name, rank, tex = GetSpellInfo(spellID)
		if id then
			if name and name ~= "" then cacheName[id] = name end
			if tex then cacheTex[id] = tex end
		end
		name = name or (id and cacheName[id]) or nil
		tex  = tex  or (id and cacheTex[id]) or nil
		if name and tex then return name, rank, tex end
		ExRT.F.WarmUpSpell(spellID)
		local n2, r2, t2 = GetSpellInfo(spellID)
		if id then
			if n2 and n2 ~= "" then cacheName[id] = n2 end
			if t2 then cacheTex[id] = t2 end
		end
		name = name or n2 or (id and cacheName[id])
		rank = rank or r2
		tex  = tex  or t2 or (id and cacheTex[id])
		if not tex then
			tex = (GetSpellTexture and GetSpellTexture(spellID)) or (id and cacheTex[id]) or nil
			if tex and id then cacheTex[id] = tex end
		end
		if name and tex then return name, rank, tex end
		if name then return name, rank, "Interface\\Icons\\INV_Misc_QuestionMark" end
		local cn = id and cacheName[id] or nil
		local ct = (id and cacheTex[id]) or "Interface\\Icons\\INV_Misc_QuestionMark"
		return cn, nil, ct
	end

	function ExRT.F.GetSpellLinkSafe(spellID)
		if not spellID then return nil end
		local link = GetSpellLink and GetSpellLink(spellID)
		if link then return link end
		local name = ExRT.F.GetSpellInfoSafe(spellID)
		if not name or name == "" then return nil end
		return "|cff71d5ff|Hspell:"..spellID.."|h["..name.."]|h|r"
	end
end

do
	local function nameWithoutRealm(n)
		if not n then return nil end
		local s = strsplit("-", n)
		return s
	end

	local function NameToUnit(name)
		if not name then return nil end
		local pname = UnitName("player")
		if pname == name then return "player" end
		local nRaid = GetNumRaidMembers and GetNumRaidMembers() or 0
		if nRaid > 0 then
			for i = 1, nRaid do
				local u = "raid"..i
				if UnitName(u) == name then return u end
			end
		end
		local nParty = GetNumPartyMembers and GetNumPartyMembers() or 0
		for i = 1, nParty do
			local u = "party"..i
			if UnitName(u) == name then return u end
		end
		return nil
	end

	local function getExCD2()
		return MRT and MRT.A and MRT.A.ExCD2 or nil
	end

	function ExRT.F.UnitHasTalent(name, spellID)
		if not name or type(spellID) ~= "number" then return nil end
		name = nameWithoutRealm(name)

		if name == UnitName("player") and IsSpellKnown and IsSpellKnown(spellID) then
			return true
		end

		local mod = getExCD2()
		if mod and mod.db then
			local sg = mod.db.session_gGUIDs
			if sg then
				local row = sg[name]
				if row and row[spellID] then
					return true
				end
			end
			local provides = mod.db.spell_talentProvideAnotherTalents
			if provides and sg then
				local row = sg[name]
				if row then
					for src, list in pairs(provides) do
						if row[src] and type(list) == "table" then
							for _, v in pairs(list) do
								if v == spellID then return true end
							end
						end
					end
				end
			end
		end

		local TALENT_SPELL_ALIASES = {
			[31230] = {31228, 31229, 31230},
			[14185] = {14185},
			[66233] = {31850, 31851, 31852, 66233},
			[31850] = {31850, 31851, 31852, 66233},
			[31851] = {31850, 31851, 31852, 66233},
			[31852] = {31850, 31851, 31852, 66233},
		}
		local LGT = LibStub and LibStub("LibGroupTalents-1.0", true)
		if LGT then
			local unit = NameToUnit(name)
			local guid = unit and UnitGUID(unit) or nil
			local function tryName(sname)
				if not sname then return nil end
				if guid and LGT.GUIDHasTalent then
					local r = LGT:GUIDHasTalent(guid, sname)
					if r ~= nil then return r and true or false end
				end
				if unit and LGT.UnitHasTalent then
					local r = LGT:UnitHasTalent(unit, sname)
					if r ~= nil then return r and true or false end
				end
				if not unit and LGT.roster then
					for rguid, r in pairs(LGT.roster) do
						if r and r.name == name and LGT.GUIDHasTalent then
							local hit = LGT:GUIDHasTalent(rguid, sname)
							if hit ~= nil then return hit and true or false end
						end
					end
				end
				return nil
			end
			local primary = GetSpellInfo(spellID)
			local r = tryName(primary)
			if r ~= nil then return r end
			local aliases = TALENT_SPELL_ALIASES[spellID]
			if aliases then
				for i = 1, #aliases do
					if aliases[i] ~= spellID then
						local aname = GetSpellInfo(aliases[i])
						if aname and aname ~= primary then
							local r2 = tryName(aname)
							if r2 ~= nil then return r2 end
						end
					end
				end
			end
		end

		return nil
	end

	function ExRT.F.GetUnitTalents(name)
		if not name then return nil end
		name = nameWithoutRealm(name)
		local mod = getExCD2()
		if not mod or not mod.db or not mod.db.session_gGUIDs then return nil end
		local sg = mod.db.session_gGUIDs
		local row = sg[name]
		if not row then return nil end
		local copy = {}
		for k, v in pairs(row) do copy[k] = v end
		return copy
	end
end
