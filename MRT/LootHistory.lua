local GlobalAddonName, ExRT = ...


local GetItemInfo, GetItemInfoInstant  = C_Item and C_Item.GetItemInfo or GetItemInfo,  C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant

local module = ExRT:New("LootHistory",ExRT.L.LootHistory)
local ELib,L = ExRT.lib,ExRT.L

local ITEM_QUALITY_COLOR_RARITY = {
	["9d9d9d"] = 0,
	["ffffff"] = 1,
	["1eff00"] = 2,
	["0070dd"] = 3,
	["a335ee"] = 4,
	["ff8000"] = 5,
	["e6cc80"] = 6,
}
local function GetLootRarity(itemLink, itemLinkShort)
	local _, _, rarity = GetItemInfo(itemLinkShort or itemLink)
	if rarity then return rarity end
	if type(itemLink) == "string" then
		local hex = itemLink:match("|c%x%x(%x%x%x%x%x%x)")
		if hex then return ITEM_QUALITY_COLOR_RARITY[hex:lower()] end
	end
	return nil
end

module.db.allowedDiff = {
	[14] = true,
	[15] = true,
	[16] = true,
	[23] = true,
	[8] = true,
}

local VMRT = nil

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.LootHistory = VMRT.LootHistory or {}
	VMRT.LootHistory.list = VMRT.LootHistory.list or {}
	VMRT.LootHistory.bossNames = VMRT.LootHistory.bossNames or {}
	VMRT.LootHistory.instanceNames = VMRT.LootHistory.instanceNames or {}

	if ExRT and ExRT.L and ExRT.L.bossName then
		for encID, name in pairs(VMRT.LootHistory.bossNames) do
			local canonical = ExRT.L.bossName[encID]
			if type(canonical) == "string" and canonical ~= "" and canonical ~= tostring(encID) and canonical ~= name then
				VMRT.LootHistory.bossNames[encID] = canonical
			end
		end
	end

	if not VMRT.LootHistory.encMigrCreature then
		local resolve = ExRT.Compat and ExRT.Compat.Encounter and ExRT.Compat.Encounter.GetEncounterIDByCreature
		if resolve and ExRT.L and ExRT.L.bossName then
			for i = 1, #VMRT.LootHistory.list do
				local rec = VMRT.LootHistory.list[i]
				local pre, encStr, rest = rec:match("^([^#]*)#([^#]*)#(.*)$")
				local encID = tonumber(encStr)
				if pre and encID and encID ~= 0 then
					local newEnc = resolve(encID)
					if not newEnc then
						if ExRT.L.bossName[encID] then
							newEnc = encID
						else
							newEnc = 0
						end
					end
					if newEnc ~= encID then
						VMRT.LootHistory.list[i] = pre .. "#" .. newEnc .. "#" .. rest
					end
				end
			end
			VMRT.LootHistory.encMigrCreature = true
		end
	end

	if not VMRT.LootHistory.disable then
		module:Enable()
	end
end

function module:Enable()
	if ExRT.isClassic then
		module:RegisterEvents("CHAT_MSG_LOOT","ENCOUNTER_START","ENCOUNTER_END")
		return
	end
  	module:RegisterEvents('ENCOUNTER_LOOT_RECEIVED','BOSS_KILL',"ENCOUNTER_END")
	if ExRT.clientVersion > 100007 then
		module:RegisterEvents('LOOT_HISTORY_UPDATE_ENCOUNTER','LOOT_HISTORY_UPDATE_DROP')
	else
		module:RegisterEvents("LOOT_HISTORY_AUTO_SHOW","LOOT_HISTORY_FULL_UPDATE","LOOT_HISTORY_ROLL_COMPLETE")
	end
end

function module:Disable()
	if ExRT.isClassic then
		module:UnregisterEvents("CHAT_MSG_LOOT","ENCOUNTER_START","ENCOUNTER_END")
		return
	end
  	module:UnregisterEvents('ENCOUNTER_LOOT_RECEIVED','BOSS_KILL',"ENCOUNTER_END")
	if ExRT.clientVersion > 100007 then
		module:UnregisterEvents('LOOT_HISTORY_UPDATE_ENCOUNTER','LOOT_HISTORY_UPDATE_DROP')
	else
		module:UnregisterEvents("LOOT_HISTORY_AUTO_SHOW","LOOT_HISTORY_FULL_UPDATE","LOOT_HISTORY_ROLL_COMPLETE")
	end
end

function module.main:BOSS_KILL(encounterID, name)
	if encounterID == 0 or not encounterID then
		return
	end
	local canonical
	if ExRT and ExRT.L and ExRT.L.bossName then
		local resolved = ExRT.L.bossName[encounterID]
		if type(resolved) == "string" and resolved ~= "" and resolved ~= tostring(encounterID) then
			canonical = resolved
		end
	end
	VMRT.LootHistory.bossNames[encounterID] = canonical or name
end

function module.main:ENCOUNTER_LOOT_RECEIVED(encounterID, itemID, itemLink, quantity, playerName, className)
	local instanceName,_,difficulty,_,_,_,_,instanceID = GetInstanceInfo()

	if not difficulty or not module.db.allowedDiff[difficulty] then

	end

	VMRT.LootHistory.instanceNames[instanceID or 0] = instanceName

	local currTime = time()

	local classID = ExRT.GDB.ClassID[className] or 0

	local itemLinkShort = itemLink:match("(item:.-)|h")

	if not itemLinkShort then
		return
	end

	local _, _, itemRarity = GetItemInfo(itemLinkShort)
	if itemRarity and itemRarity < 4 then
		return
	end

	local record = currTime.."#"..(encounterID or 0).."#"..(instanceID or 0).."#"..(difficulty or 0).."#"..playerName.."#"..classID.."#"..quantity.."#"..itemLinkShort

	VMRT.LootHistory.list[#VMRT.LootHistory.list+1] = record
end

local rollIDtoRecord = {}
function module.main:LOOT_HISTORY_FULL_UPDATE()
	local instanceName,instance_type,difficulty,_,_,_,_,instanceID = GetInstanceInfo()

	if not difficulty or not module.db.allowedDiff[difficulty] then

	end
	if instance_type ~= "raid" then
		return
	end

	local numItems = C_LootHistory.GetNumItems()
	for i=1, numItems do
		local rollID, itemLink, numPlayers, isDone, winnerIdx, isMasterLoot = C_LootHistory.GetItem(i)
		if rollID and itemLink then
			local currTime, encounterID, playerName, classID, quantity, itemLinkShort, rollType, _
			local recordID
			if rollIDtoRecord[rollID] then
				recordID = rollIDtoRecord[rollID]
				currTime, encounterID, _, _, playerName, classID, quantity, itemLinkShort = strsplit("#",VMRT.LootHistory.list[recordID])
				if itemLinkShort ~= itemLink:match("(item:.-)|h") then
					currTime, encounterID, playerName, classID, quantity, itemLinkShort = nil
					recordID = nil
				end
			end
			if isDone and winnerIdx then
				local name, class, ProllType, roll, isWinner = C_LootHistory.GetPlayerInfo(i, winnerIdx)
				if name then
					playerName = name
					classID = ExRT.GDB.ClassID[class or ""] or 0
					rollType = ProllType
				end
			end
			if not currTime then
				currTime = time()

				itemLinkShort = itemLink:match("(item:.-)|h")

				local _, _, itemRarity = GetItemInfo(itemLink)
				if itemRarity and itemRarity < 4 then
					currTime = nil
				end
				encounterID = module.db.prevEncounterID
			end
			if currTime then
				local record = currTime.."#"..(encounterID or 0).."#"..(instanceID or 0).."#"..(difficulty or 0).."#"..(playerName or "").."#"..(classID or "0").."#"..(quantity or "1").."#"..itemLinkShort..(rollType and "#"..rollType or "")

				VMRT.LootHistory.instanceNames[instanceID or 0] = instanceName

				recordID = recordID or #VMRT.LootHistory.list+1
				VMRT.LootHistory.list[recordID] = record
				rollIDtoRecord[rollID] = recordID
			end
		end
	end
end
module.main.LOOT_HISTORY_AUTO_SHOW = module.main.LOOT_HISTORY_FULL_UPDATE
module.main.LOOT_HISTORY_ROLL_COMPLETE = module.main.LOOT_HISTORY_FULL_UPDATE

local rollStateToRollType = {
	[0]=1,
	[1]=1,
	[2]=3,
	[3]=2,
	[4]=0,
	[5]=0,
}

local function FindInValue(t,val)
	for k,v in pairs(t) do
		if v == val then
			return k
		end
	end
end

function module.main:LOOT_HISTORY_UPDATE_ENCOUNTER(encounterID)
	local instanceName,instance_type,difficulty,_,_,_,_,instanceID = GetInstanceInfo()
	local drops = C_LootHistory.GetSortedDropsForEncounter(encounterID)
	if not drops then return end
	for _, dropInfo in ipairs(drops) do
		local lootListID = dropInfo.lootListID


		local itemLink = dropInfo and dropInfo.itemHyperlink
		if itemLink then
			local rollID = (encounterID or "").."-"..(difficulty or 0).."-"..(lootListID or "0")

			local currTime, playerName, classID, quantity, itemLinkShort, rollType, _
			local recordID
			if not rollIDtoRecord[rollID] then
				for i=#VMRT.LootHistory.list,1,-1 do
					local t, eID, iID, dID, _, _, _, il = strsplit("#",VMRT.LootHistory.list[i])
					if eID and iID and dID and tostring(instanceID) == iID and encounterID and tostring(encounterID) == eID and dID == tostring(difficulty or "") and t and tonumber(t) and time()-tonumber(t) <= 420 then
						if type(il) == "string" and il:match("item:%d+") == itemLink:match("item:%d+") and not FindInValue(rollIDtoRecord, i) then
							rollIDtoRecord[rollID] = i
							break
						end
					else
						break
					end
				end
			end
			if rollIDtoRecord[rollID] then
				recordID = rollIDtoRecord[rollID]
				currTime, _, _, _, playerName, classID, quantity, itemLinkShort, rollType = strsplit("#",VMRT.LootHistory.list[recordID])
				if type(itemLinkShort)~='string' or itemLinkShort:match("item:%d+")~=itemLink:match("item:%d+") then
					currTime, playerName, classID, quantity, itemLinkShort = nil
					recordID = nil
				end
			end
			if dropInfo.winner then
				playerName = dropInfo.winner.playerName
				classID = ExRT.GDB.ClassID[dropInfo.winner.playerClass or ""] or 0
				if dropInfo.playerRollState then
					rollType = rollStateToRollType[ dropInfo.playerRollState ]
				end
			end
			if not currTime then
				currTime = time()

				itemLinkShort = itemLink:match("(item:.-)|h")

				local _, _, itemRarity = GetItemInfo(itemLink)
				if itemRarity and itemRarity < 4 then
					currTime = nil
				end
			end
			if currTime then
				local record = currTime.."#"..(encounterID or 0).."#"..(instanceID or 0).."#"..(difficulty or 0).."#"..(playerName or "").."#"..(classID or "0").."#"..(quantity or "1").."#"..itemLinkShort..(rollType and "#"..rollType or "")

				VMRT.LootHistory.instanceNames[instanceID or 0] = instanceName

				recordID = recordID or #VMRT.LootHistory.list+1
				VMRT.LootHistory.list[recordID] = record
				rollIDtoRecord[rollID] = recordID
			end
		end
	end
end

function module.main:LOOT_HISTORY_UPDATE_DROP(encounterID,lootListID)
	module.main:LOOT_HISTORY_UPDATE_ENCOUNTER(encounterID)
end

local function CanonicalEncounterName(encounterID, fallback)
	if encounterID and ExRT and ExRT.L and ExRT.L.bossName then
		local name = ExRT.L.bossName[encounterID]
		if type(name) == "string" and name ~= "" and name ~= tostring(encounterID) then
			return name
		end
	end
	return fallback
end

local bossNameToID
local subzoneMap
local function BuildSubzoneLookups()
	local D = ExRT.Data
	if not D or not D.SubzoneTextToBossID then return false end
	bossNameToID = {}
	if ExRT.L and ExRT.L.bossName then
		for id, name in pairs(ExRT.L.bossName) do
			if type(name) == "string" then
				bossNameToID[name] = id
			end
		end
	end
	subzoneMap = {}
	for _, localeTable in pairs(D.SubzoneTextToBossID) do
		if type(localeTable) == "table" then
			for roomText, boss in pairs(localeTable) do
				if subzoneMap[roomText] == nil then
					subzoneMap[roomText] = boss
				end
			end
		end
	end
	return true
end

local function EncounterIDFromSubzone(zoneText)
	if not subzoneMap and not BuildSubzoneLookups() then return nil end
	if not zoneText or zoneText == "" then return nil end
	local boss = subzoneMap[zoneText]
	if not boss then return nil end
	return type(boss) == "number" and boss or bossNameToID[boss]
end

local FUNCTIONAL_BOSS_NAMES
local function BuildFunctionalBossNames()
	if FUNCTIONAL_BOSS_NAMES then return FUNCTIONAL_BOSS_NAMES end
	FUNCTIONAL_BOSS_NAMES = {}
	if ExRT.L and ExRT.L.bossName then
		for id, name in pairs(ExRT.L.bossName) do
			if type(id) == "number" and type(name) == "string" and name ~= "" and name ~= tostring(id) then
				FUNCTIONAL_BOSS_NAMES[name] = id
			end
		end
	end
	return FUNCTIONAL_BOSS_NAMES
end

local function FindEncounterIDByName(name)
	if not name or type(name) ~= "string" then return nil end
	BuildFunctionalBossNames()
	return FUNCTIONAL_BOSS_NAMES[name]
end

local SHARED_SUBZONE_INSTANCES = {
	[649] = true,
	[631] = true,
	[533] = true,
	[548] = true,
	[550] = true,
	[534] = true,
	[564] = true,
	[568] = true,
	[580] = true,
	[532] = true,
	[409] = true,
	[469] = true,
	[531] = true,
	[509] = true,
	[309] = true,
}

local function CorrectEncounterIDBySubzone(prevID)
	local zoneText = GetSubZoneText and GetSubZoneText()
	local curID = EncounterIDFromSubzone(zoneText)
	if not curID or curID == prevID then return prevID end
	if not prevID or prevID == 0 then
		return curID
	end
	if module.db.prevEncounterSubzone and module.db.prevEncounterSubzone ~= zoneText then
		return curID
	end
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	if SHARED_SUBZONE_INSTANCES[instanceID] then
		return prevID
	end
	return curID
end

local function CorrectEncounterIDByName(encounterID, encounterName)
	if not encounterID or encounterID == 0 then return encounterID end
	if not encounterName or type(encounterName) ~= "string" then return encounterID end
	local nameFromID = ExRT.L.bossName[encounterID]
	if type(nameFromID) ~= "string" or nameFromID == tostring(encounterID) then return encounterID end
	if nameFromID == encounterName then return encounterID end
	local idFromName = FindEncounterIDByName(encounterName)
	if idFromName and idFromName ~= encounterID then
		return idFromName
	end
	return encounterID
end

function module.main:ENCOUNTER_END(encounterID, encounterName)
	encounterID = CorrectEncounterIDByName(encounterID, encounterName)
	module.db.prevEncounterID = encounterID
	module.db.prevEncounterSubzone = GetSubZoneText and GetSubZoneText()
	if ExRT.isClassic and encounterID and encounterID ~= 0 then
		local canonical = CanonicalEncounterName(encounterID, encounterName)
		if canonical and canonical ~= "" then
			VMRT.LootHistory.bossNames = VMRT.LootHistory.bossNames or {}
			VMRT.LootHistory.bossNames[encounterID] = canonical
		end
	end
end

function module.main:ENCOUNTER_START(encounterID, encounterName)
	encounterID = CorrectEncounterIDByName(encounterID, encounterName)
	module.db.prevEncounterID = encounterID
	module.db.prevEncounterSubzone = GetSubZoneText and GetSubZoneText()
	if encounterID and encounterID ~= 0 then
		local canonical = CanonicalEncounterName(encounterID, encounterName)
		if canonical and canonical ~= "" then
			VMRT.LootHistory.bossNames = VMRT.LootHistory.bossNames or {}
			VMRT.LootHistory.bossNames[encounterID] = canonical
		end
	end
end

local LOOT_PATTERNS_CLASSIC
local function BuildLootPatternsClassic()
	if LOOT_PATTERNS_CLASSIC then return LOOT_PATTERNS_CLASSIC end
	LOOT_PATTERNS_CLASSIC = {}
	local function addPattern(template, extractor)
		if type(template) ~= "string" or template == "" then return end
		local pattern = template:gsub("([%%%(%)%.%+%-%*%?%[%]%^%$])", "%%%1")
		pattern = pattern:gsub("%%%%s", "(.+)"):gsub("%%%%d", "(%%d+)")
		LOOT_PATTERNS_CLASSIC[#LOOT_PATTERNS_CLASSIC+1] = {pattern, extractor}
	end
	addPattern(LOOT_ITEM_MULTIPLE, function(name, link, qty) return name, link, tonumber(qty) or 1 end)
	addPattern(LOOT_ITEM_SELF_MULTIPLE, function(link, qty) return UnitName("player"), link, tonumber(qty) or 1 end)
	addPattern(LOOT_ITEM, function(name, link) return name, link, 1 end)
	addPattern(LOOT_ITEM_SELF, function(link) return UnitName("player"), link, 1 end)
	addPattern(LOOT_ITEM_PUSHED_MULTIPLE, function(name, link, qty) return name, link, tonumber(qty) or 1 end)
	addPattern(LOOT_ITEM_PUSHED_SELF_MULTIPLE, function(link, qty) return UnitName("player"), link, tonumber(qty) or 1 end)
	addPattern(LOOT_ITEM_PUSHED, function(name, link) return name, link, 1 end)
	addPattern(LOOT_ITEM_PUSHED_SELF, function(link) return UnitName("player"), link, 1 end)
	addPattern(LOOT_ROLL_WON, function(name, link) return name, link, 1 end)
	addPattern(LOOT_ROLL_YOU_WON, function(link) return UnitName("player"), link, 1 end)
	return LOOT_PATTERNS_CLASSIC
end

-- Items that are not real raid loot and shouldn't appear in the history.
-- Includes epic-quality currency tokens (emblems, seals, trophies, shards)
-- and epic enchanting reagents that drop from disenchant rolls.
local EMBLEM_ITEM_IDS = {
	-- WotLK emblems
	[40752] = true, [40753] = true, [45624] = true,
	[47241] = true, [49426] = true,
	-- Other WotLK currency / token rewards
	[43228] = true, -- Stone Keeper's Shard
	[44990] = true, -- Champion's Seal
	[47242] = true, -- Trophy of the Crusade
	[52027] = true, -- Sidereal Essence (legacy currency)
	-- Epic enchanting reagents (other reagents are <4 rarity and already filtered)
	[20725] = true, -- Nexus Crystal
	[22450] = true, -- Void Crystal
	[34057] = true, -- Abyss Crystal
	-- Epic crafting reagents
	[49908] = true, -- Primordial Saronite
}

local lastLoot = {}
local function ShouldDedupe(playerName, itemId)
	if not playerName or not itemId then return false end
	local key = playerName .. ":" .. itemId
	local now = GetTime()
	local prev = lastLoot[key]
	if prev and (now - prev) < 0.5 then return true end
	lastLoot[key] = now
	if (lastLoot.__n or 0) > 50 then
		for k, v in pairs(lastLoot) do
			if k ~= "__n" and (now - v) > 30 then lastLoot[k] = nil end
		end
		lastLoot.__n = 0
	end
	lastLoot.__n = (lastLoot.__n or 0) + 1
	return false
end

function module.main:CHAT_MSG_LOOT(msg)
	if type(msg) ~= "string" or msg == "" then
		return
	end

	local instanceName, instance_type, difficulty, _, _, _, _, instanceID = GetInstanceInfo()
	if instance_type ~= "raid" then
		return
	end
	if difficulty and not module.db.allowedDiff[difficulty] then
	end

	local patterns = BuildLootPatternsClassic()
	local playerName, itemLink, quantity
	for i=1,#patterns do
		local a, b, c = msg:match(patterns[i][1])
		if a then
			playerName, itemLink, quantity = patterns[i][2](a, b, c)
			break
		end
	end
	if not playerName or not itemLink then
		return
	end

	local itemLinkShort = itemLink:match("(item:.-)|h")
	if not itemLinkShort then
		return
	end

	local _, _, itemRarity = GetItemInfo(itemLinkShort)
	itemRarity = itemRarity or GetLootRarity(itemLink, itemLinkShort)
	if itemRarity and itemRarity < 4 then
		return
	end

	local itemId = tonumber(itemLinkShort:match("item:(%d+)"))
	if itemId and EMBLEM_ITEM_IDS[itemId] then
		return
	end

	if ShouldDedupe(playerName, itemId) then
		return
	end

	local className
	local shortName = ExRT.F.delUnitNameServer and ExRT.F.delUnitNameServer(playerName) or playerName
	if shortName == UnitName("player") then
		_, className = UnitClass("player")
	elseif IsInRaid and IsInRaid() then
		for i=1,GetNumGroupMembers() do
			local rosterName, _, _, _, _, fileName = GetRaidRosterInfo(i)
			if rosterName == shortName or rosterName == playerName then
				className = fileName
				break
			end
		end
	elseif IsInGroup and IsInGroup() then
		for i=1,4 do
			local unit = "party"..i
			if UnitExists(unit) and UnitName(unit) == shortName then
				_, className = UnitClass(unit)
				break
			end
		end
	end
	local classID = ExRT.GDB.ClassID[className or ""] or 0

	local encounterID = module.db.prevEncounterID or 0

	local subzoneID = CorrectEncounterIDBySubzone(encounterID)
	if subzoneID and subzoneID ~= encounterID then
		encounterID = subzoneID
	end

	if encounterID == 0 and _G.VMRT and VMRT.BossWatcher and VMRT.BossWatcher.currentFight then
		local fight = VMRT.BossWatcher.currentFight
		if type(fight) == "table" and fight.encounterID then
			encounterID = fight.encounterID
			if fight.encounterName then
				VMRT.LootHistory.bossNames[encounterID] = fight.encounterName
			end
		end
	end

	VMRT.LootHistory.instanceNames[instanceID or 0] = instanceName

	local record = time().."#"..(encounterID or 0).."#"..(instanceID or 0).."#"..(difficulty or 0).."#"..playerName.."#"..classID.."#"..(quantity or 1).."#"..itemLinkShort
	VMRT.LootHistory.list[#VMRT.LootHistory.list+1] = record
end

function module.options:Load()
	self:CreateTilte()

	self.decorationLine = ELib:DecorationLine(self,true,"BACKGROUND",-5):Point("TOPLEFT",self,0,-40):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-59)

	self.list = ELib:ScrollTableList(self,135,140,5,170,100,100,25,0):Size(890,575):Point("TOP",0,-60):FontSize(11):HideBorders()

	self.headertext1 = ELib:Text(self,L.LootHistoryDate):Point("LEFT",self.list,2,0):Point("TOP",self.decorationLine,0,0):Size(135,20):Left():Middle():Color():Shadow()
	self.headertext2 = ELib:Text(self,L.LootHistoryDungeonName):Point("LEFT",self.headertext1,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(145,20):Left():Middle():Color():Shadow()
	self.headertext3 = ELib:Text(self,L.LootHistoryBossName):Point("LEFT",self.headertext2,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(170,20):Left():Middle():Color():Shadow()
	self.headertext4 = ELib:Text(self,L.LootHistoryDifficulty):Point("LEFT",self.headertext3,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(100,20):Left():Middle():Color():Shadow()
	self.headertext5 = ELib:Text(self,L.LootHistoryPlayer):Point("LEFT",self.headertext4,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(125,20):Left():Middle():Color():Shadow()
	self.headertext6 = ELib:Text(self,L.LootHistoryItem):Point("LEFT",self.headertext5,"RIGHT",0,0):Point("TOP",self.decorationLine,0,0):Size(0,20):Left():Middle():Color():Shadow()

	function self.list:UpdateAdditional(val,isExtraUpdate)
		local extraUpdate = false
		for i=1,#self.List do
			local line = self.List[i]
			if line:IsShown() then
				local data = line.table
				if data and data.itemLink then
					local itemName, itemLinkQ, itemRarity, _, _, _, _, _, _, itemIcon = GetItemInfo(data.itemLink)

					if itemLinkQ then
						itemLinkQ = itemLinkQ:gsub("[%[%]]","")
					else
						itemLinkQ = "..."
						extraUpdate = true
					end

					local itemStr = (data.quantity > 1 and data.quantity.."x" or "")..itemLinkQ

					if not itemIcon and GetItemInfoInstant then
						itemIcon = select(5,GetItemInfoInstant(data.itemLink))
					end
					if not itemIcon then
						-- 3.3.5a: GetItemIcon(itemID) works without item cache
						local iid = tonumber(data.itemLink:match("item:(%d+)"))
						if iid then itemIcon = GetItemIcon(iid) end
					end
					if not itemIcon then
						itemIcon = "Interface\\Icons\\INV_Misc_QuestionMark"
						extraUpdate = true
					end
					itemIcon = "|T"..itemIcon..":20|t"

					line.text7:SetText(itemIcon)
					line.text8:SetText(itemStr)
				end
			end
		end
		if extraUpdate and not self.extraUpdateTimer then
			-- Retry with growing back-off; client may need a few seconds to
			-- stream item data from the server when it's cold-cached.
			self._extraTries = (self._extraTries or 0) + 1
			if self._extraTries <= 6 then
				local delay = 0.5 * self._extraTries
				self.extraUpdateTimer = C_Timer.NewTimer(delay,function()
					self.extraUpdateTimer = nil
					self:UpdateAdditional(val,true)
				end)
			end
		elseif not extraUpdate then
			self._extraTries = nil
		end
	end

	self.list.additionalLineFunctions = true
	function self.list:HoverMultitableListValue(isEnter,index,obj)
		if not isEnter then
			local line = obj.parent:GetParent()

			GameTooltip_Hide()
		else
			local line = obj.parent:GetParent()

			local data = line.table
			if index == 8 then
				GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
				GameTooltip:SetHyperlink(data.itemLink)
				GameTooltip:Show()
			elseif index == 7 then
				GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
				local img = obj.parent:GetText():gsub(":20|",":50|")
				GameTooltip:AddLine(img)
				GameTooltip:Show()
			else
				if obj.parent:IsTruncated() then
					GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
					GameTooltip:AddLine(obj.parent:GetText() )
					GameTooltip:Show()
				end
			end
		end
	end
	function self.list:ClickMultitableListValue(index,obj)
		if index == 8 then
			local data = obj:GetParent().table
			if data then
				local _, itemLink = GetItemInfo(data.itemLink)
				if itemLink then
					ExRT.F.LinkItem(nil,itemLink)
				end
			end
		elseif IsControlKeyDown() then
			local data = obj:GetParent().table
			if not data then
				return
			end
			local posI = data.posI
			if not module.options.list.ENABLE_DEL then
				StaticPopupDialogs["EXRT_LOOTHISTORY_REMOVEONE"] = {
					text = L.LootHistoryDelOne,
					button1 = L.YesText,
					button2 = L.NoText,
					OnAccept = function()
						module.options.list.ENABLE_DEL = true
						tremove(VMRT.LootHistory.list,posI)
						module.options:UpdatePage()
					end,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
				StaticPopup_Show("EXRT_LOOTHISTORY_REMOVEONE")
			else
				tremove(VMRT.LootHistory.list,posI)
				module.options:UpdatePage()
			end
		end
	end


	local RollTypeToText = ExRT.isClassic and {
		["0"] = "|r [pass]",
		["1"] = "|r [need]",
		["2"] = "|r [greed]",
		["3"] = "|r [disenchant]",
	} or {
		["0"] = "|A:lootroll-icon-pass:20:20|a",
		["1"] = "|A:lootroll-rollicon-yourolled-need:20:20|a",
		["2"] = "|A:lootroll-rollicon-yourolled-greed:20:20|a",
		["3"] = "|A:lootroll-rollicon-yourolled-transmog:20:20|a",
	}
	function self:UpdatePage()
		local result = {}

		for i=#VMRT.LootHistory.list,1,-1 do
			local timeRec,encounterID,instanceID,difficulty,playerName,classID,quantity,itemLink,rollType = strsplit("#",VMRT.LootHistory.list[i])

			local instanceName = VMRT.LootHistory.instanceNames[tonumber(instanceID)] or ""

			local dateRec = date("%d.%m.%Y %H:%M:%S",tonumber(timeRec))

			encounterID = tonumber(encounterID)
			local encounterName =  VMRT.LootHistory.bossNames[encounterID] or L.bossName[encounterID]
			if encounterID == 0 then
				encounterName = ""
			end

			-- Reverse lookup ClassID -> token (handles ClassID[DRUID]=11 vs ClassList[10]="DRUID")
			local cid = tonumber(classID)
			local class = ExRT.GDB.ClassList[cid]
			if not class and cid and cid > 0 then
				for token, id in pairs(ExRT.GDB.ClassID or {}) do
					if id == cid then class = token break end
				end
			end
			local playerNameStyle = (class and "|c"..ExRT.F.classColor(class) or "")..playerName..(rollType and RollTypeToText[rollType] or "")

			quantity = tonumber(quantity)
			difficulty = tonumber(difficulty)

			local diffName = GetDifficultyInfo and GetDifficultyInfo(difficulty)
			if not diffName and ExRT.isClassic and difficulty and difficulty > 0 then
				if difficulty == 1 then diffName = RAID_DIFFICULTY1 or "10 Player"
				elseif difficulty == 2 then diffName = RAID_DIFFICULTY2 or "25 Player"
				elseif difficulty == 3 then diffName = RAID_DIFFICULTY3 or "10 Player (Heroic)"
				elseif difficulty == 4 then diffName = RAID_DIFFICULTY4 or "25 Player (Heroic)"
				end
			end

			local toAdd = true
			if module.options.search then
				for i=1,#module.options.search do
					local toAddNow = false

					local searchText = module.options.search[i]

					if instanceName:lower():find(searchText) then
						toAddNow = true
					elseif dateRec:gsub(" .-$",""):find(searchText) then
						toAddNow = true
					elseif encounterName:lower():find(searchText) then
						toAddNow = true
					elseif playerName:lower():find(searchText) then
						toAddNow = true
					elseif diffName and diffName:lower():find(searchText) then
						toAddNow = true
					elseif tonumber(searchText) and searchText == itemLink:match("item:(%d+)") then
						toAddNow = true
					elseif (searchText == "pass" and rollType == "0") or (searchText == "need" and rollType == "1") or (searchText == "greed" and rollType == "2") then
						toAddNow = true
					else
						local itemName = GetItemInfo(itemLink)
						if itemName and itemName:lower():find(searchText) then
							toAddNow = true
						end
					end

					toAdd = toAdd and toAddNow
					if not toAdd then
						break
					end
				end

			end

			if toAdd then
				result[#result+1] = {dateRec,instanceName,"",encounterName,diffName or "",playerNameStyle,"","",itemLink = itemLink,quantity = quantity,posI = i}
			end
		end

		module.options.list.L = result
		module.options.list:Update()
	end


	self.searchEditBox = ELib:Edit(self):Point("BOTTOM",self.decorationLine,"TOP",0,5):Point("LEFT",self,10,0):Size(250,18):AddSearchIcon():OnChange(function (self,isUser)
		if not isUser then
			return
		end
		local text = self:GetText():lower()
		if text == "" then
			text = nil
		end

		if text then
			module.options.search = {strsplit(",",text)}
			for i=#module.options.search,1,-1 do
				if module.options.search[i] == "" then
					tremove(module.options.search,i)
				end
			end
		else
			module.options.search = nil
		end

		if self.scheduledUpdate then
			return
		end
		self.scheduledUpdate = C_Timer.NewTimer(.3,function()
			self.scheduledUpdate = nil
			module.options:UpdatePage()
		end)
	end):Tooltip(SEARCH)

	self.clearButton = ELib:Button(self,L.MarksClear):Size(100,20):Point("BOTTOM",self.decorationLine,"TOP",0,5):Point("RIGHT",self,-10,0):Tooltip(L.EncounterClear):OnClick(function()
		StaticPopupDialogs["EXRT_LOOTHISTORY_CLEAR"] = {
			text = L.EncounterClearPopUp,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				table.wipe(VMRT.LootHistory.list)
				table.wipe(VMRT.LootHistory.bossNames)
				table.wipe(VMRT.LootHistory.instanceNames)
				module.options:UpdatePage()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_LOOTHISTORY_CLEAR")
	end)

	self.chkEnable = ELib:Check(self,L.Enable,not VMRT.LootHistory.disable):Point("LEFT",self.clearButton,"LEFT",-100,0):Size(18,18):AddColorState():OnClick(function(self)
		if self:GetChecked() then
			VMRT.LootHistory.disable = false
			module:Enable()
		else
			VMRT.LootHistory.disable = true
			module:Disable()
		end
	end)

	self.isWide = 900
	function self:OnShow()
		self:UpdatePage()
	end
end
