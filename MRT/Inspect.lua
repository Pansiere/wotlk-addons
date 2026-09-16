local GlobalAddonName, ExRT = ...
local function dprint(...) if _G.MRT_CD_DEBUG then print(...) end end

local UnitName, GetTime = UnitName, GetTime
local pairs, type, tonumber, abs = pairs, type, tonumber, abs
local UnitCombatlogname, RaidInCombat, ScheduleTimer, DelUnitNameServer = ExRT.F.UnitCombatlogname, ExRT.F.RaidInCombat, ExRT.F.ScheduleTimer, ExRT.F.delUnitNameServer
local CheckInteractDistance, CanInspect, TooltipUtil, C_TooltipInfo = CheckInteractDistance, CanInspect, TooltipUtil, C_TooltipInfo

local GetSpellInfo = ExRT.F.GetSpellInfo or GetSpellInfo
local GetInspectSpecialization, GetTalentInfo = GetInspectSpecialization, GetTalentInfo or ExRT.F.GetTalentInfoMoP
local GetInventoryItemQuality, GetInventoryItemID = GetInventoryItemQuality, GetInventoryItemID
local GetTalentInfoClassic = GetTalentInfo
local C_SpecializationInfo_GetInspectSelectedPvpTalent
local GetItemInfo, GetItemInfoInstant  = C_Item and C_Item.GetItemInfo or GetItemInfo,  C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local GetNumSpecializationsForClassID = C_SpecializationInfo and C_SpecializationInfo.GetNumSpecializationsForClassID or GetNumSpecializationsForClassID
GetInspectSpecialization = function () return 0 end
GetNumSpecializationsForClassID = GetInspectSpecialization
GetTalentInfo = ExRT.NULLfunc
C_SpecializationInfo_GetInspectSelectedPvpTalent = ExRT.NULLfunc

local VMRT = nil

local module = ExRT:New("Inspect",nil,true)
local ELib,L = ExRT.lib,ExRT.L

local cooldownsModule = ExRT.A and ExRT.A.ExCD2

local LibDeflate = LibStub:GetLibrary("LibDeflate")

module.db.inspectDB = {}
module.db.inspectDBAch = {}
module.db.inspectQuery = {}
module.db.inspectItemsOnly = {}
module.db.inspectNotItemsOnly = {}
module.db.inspectID = nil
module.db.inspectCleared = nil

module.db.inspectTrees = {}

if cooldownsModule and cooldownsModule.db then
	cooldownsModule.db.inspectDB = module.db.inspectDB
end

if ExRT.isClassic and not SetAchievementComparisonUnit then
	SetAchievementComparisonUnit = ExRT.NULLfunc
end

local inspectForce = false
function module:Force() inspectForce = true end
function module:Slowly() inspectForce = false end

local function IsRaidMember(name)
	if not name or name == "" then return false end
	local short = name:match("^([^%-]+)") or name
	if UnitName("player") == short then return true end
	local nRaid = (GetNumRaidMembers and GetNumRaidMembers()) or 0
	if nRaid == 0 and GetNumGroupMembers and (IsInRaid and IsInRaid()) then
		nRaid = GetNumGroupMembers() or 0
	end
	if nRaid > 0 then
		for j = 1, nRaid do
			local rname = GetRaidRosterInfo(j)
			if rname == short then return true end
			if UnitName("raid"..j) == short then return true end
		end
		return false
	end
	local nParty = (GetNumPartyMembers and GetNumPartyMembers()) or 0
	for j = 1, nParty do
		if UnitName("party"..j) == short then return true end
	end
	return false
end
module.IsRaidMember = IsRaidMember

local function PruneNonRaidMembers()
	local roster = {}
	if UnitName("player") then roster[UnitName("player")] = true end
	if IsInRaid and IsInRaid() then
		local n = (GetNumRaidMembers and GetNumRaidMembers()) or (GetNumGroupMembers and GetNumGroupMembers()) or 0
		for j = 1, n do
			local rname = GetRaidRosterInfo(j)
			if rname then roster[rname] = true end
		end
	else
		local n = (GetNumPartyMembers and GetNumPartyMembers()) or 0
		for j = 1, n do
			local pname = UnitName("party"..j)
			if pname then roster[pname] = true end
		end
	end
	local function isInRoster(fullName)
		if not fullName then return false end
		local short = fullName:match("^([^%-]+)") or fullName
		return roster[short] == true
	end
	for tblName, _ in pairs({inspectDB=true,inspectQuery=true,inspectItemsOnly=true,inspectNotItemsOnly=true,inspectDBAch=true}) do
		local t = module.db[tblName]
		if type(t) == "table" then
			for k in pairs(t) do
				if not isInRoster(k) then
					t[k] = nil
				end
			end
		end
	end
end
module.PruneNonRaidMembers = PruneNonRaidMembers

module.db.statsNames = {
	haste = {L.cd2InspectHaste,L.cd2InspectHasteGem},
	mastery = {L.cd2InspectMastery,L.cd2InspectMasteryGem},
	crit = {L.cd2InspectCrit,L.cd2InspectCritGem,L.cd2InspectCritGemLegendary},
	spirit = {L.cd2InspectSpirit,L.cd2InspectAll},

	intellect = {L.cd2InspectInt,L.cd2InspectIntGem,L.cd2InspectAll},
	agility = {L.cd2InspectAgi,L.cd2InspectAll},
	strength = {L.cd2InspectStr,L.cd2InspectStrGem,L.cd2InspectAll},
	spellpower = {L.cd2InspectSpd},

	versatility = {L.cd2InspectVersatility,L.cd2InspectVersatilityGem},
	leech = {L.cd2InspectLeech},
	armor = {L.cd2InspectBonusArmor},
	avoidance = {L.cd2InspectAvoidance},
	speed = {L.cd2InspectSpeed},

	corruption = {"%+(%d+) ?"..(ITEM_MOD_CORRUPTION or "Corruption").."$"},
	corruption_res = {"%+(%d+) ?"..(ITEM_MOD_CORRUPTION_RESISTANCE or "Corruption resistance").."$"},
}
if ExRT.locale == "koKR" then
	module.db.statsNames.corruption = {"^"..(ITEM_MOD_CORRUPTION or "Corruption").." ?%+(%d+)".."$"}
	module.db.statsNames.corruption_res = {"^"..(ITEM_MOD_CORRUPTION_RESISTANCE or "Corruption resistance").." ?%+(%d+)".."$"}
end

module.db.itemsSlotTable = {
	1,
	2,
	3,
	15,
	5,
	9,
	10,
	6,
	7,
	8,
	11,
	12,
	13,
	14,
	16,
	17,
}
module.db.itemsSlotTable[#module.db.itemsSlotTable+1] = 18

local inspectScantip
if ExRT.isClassic then
	inspectScantip = CreateFrame("GameTooltip", "ExRTInspectScanningTooltip", nil, "GameTooltipTemplate")
	inspectScantip:SetOwner(WorldFrame, "ANCHOR_NONE")
end


local function CheckForSuccesInspect(name)
	if not module.db.inspectDB[name] then
		module.db.inspectQuery[name] = true
	end
end


local function forbidden()end
local exec_env = setmetatable({}, { __index = function(t, k)
	if k == "_G" then
		return t
	elseif k == "ShowUIPanel" then
		return forbidden
	else
		return _G[k]
	end
end})

local rereg_auto = nil
local rereg_auto2 = nil

local lastCheckNext = {}
local inspectLastTime = 0
local function InspectNext()
	if RaidInCombat() or (InspectFrame and InspectFrame:IsShown()) then
		return
	end
	if canaccessvalue and not canaccessvalue(UnitName'target') then
		return
	end
	local nowTime = GetTime()
	for name,timeAdded in pairs(module.db.inspectQuery) do
		if name and UnitName(name) and not InCombatLockdown() and CheckInteractDistance(name,1) and CanInspect(name,false) and (not lastCheckNext[name] or nowTime - lastCheckNext[name] > 30) then
			lastCheckNext[name] = nowTime
			if ExRT.isLK then
				MuteSoundFile(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
				C_Timer.After(2,function()
					UnmuteSoundFile(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
				end)
			end
			NotifyInspect(name)


			if InspectPVPFrame and not INSPECTED_UNIT then
				InspectPVPFrame:UnregisterEvent("INSPECT_HONOR_UPDATE")
				module.db.blizzinterfaceunloaded2 = true
				if rereg_auto2 then
					rereg_auto2:Cancel()
				end
				rereg_auto2 = C_Timer.NewTimer(10,function()
					if module.db.blizzinterfaceunloaded2 then
						InspectPVPFrame:RegisterEvent("INSPECT_HONOR_UPDATE")
					end
					rereg_auto2 = nil
				end)
			end

			module.db.inspectQuery[name] = nil
			ExRT.F.Timer(CheckForSuccesInspect,10,name)
			return
		elseif not UnitName(name) then
			module.db.inspectQuery[name] = nil
		end
	end
end

local function InspectQueue()
	if RaidInCombat() or (ExRT.isClassic and not ExRT.isLK) then
		return
	end
	local timeAdded = GetTime()
	if IsInRaid and IsInRaid() then
		local n = (GetNumRaidMembers and GetNumRaidMembers()) or (GetNumGroupMembers and GetNumGroupMembers()) or 0
		for j=1,n do
			local name,_,subgroup,_,_,_,_,online = GetRaidRosterInfo(j)
			if name and not module.db.inspectDB[name] and online then
				module.db.inspectQuery[name] = timeAdded
				module.db.inspectNotItemsOnly[name] = true
			end
		end
	else
		local n = (GetNumPartyMembers and GetNumPartyMembers()) or 0
		if n > 0 then
			for j=0,n do
				local unit = (j == 0) and "player" or ("party"..j)
				local name = UnitName(unit)
				local online = j == 0 or UnitIsConnected(unit)
				if name and not module.db.inspectDB[name] and online then
					module.db.inspectQuery[name] = timeAdded
					module.db.inspectNotItemsOnly[name] = true
				end
			end
		end
	end
end

function module:AddToQueue(name)
	if not module.db.inspectQuery[name] then
		lastCheckNext[name] = nil
		module.db.inspectQuery[name] = GetTime()
		module.db.inspectNotItemsOnly[name] = true
	end
end


local InspectItems = nil
do
	local ITEM_LEVEL = (ITEM_LEVEL or "NO DATA FOR ITEM_LEVEL"):gsub("%%d","(%%d+)")
	local dataNames = {'tiersets','items','items_ilvl','azerite','essence'}
	function InspectItems(name,inspectedName,inspectSavedID,onlyPrepCall)
		if module.db.inspectCleared or module.db.inspectID ~= inspectSavedID then
			return
		end
		module.db.inspectDB[name] = module.db.inspectDB[name] or {}
		local inspectData = module.db.inspectDB[name]
		inspectData['ilvl'] = 0
		for _,dataName in pairs(dataNames) do
			if inspectData[dataName] then
				for q,w in pairs(inspectData[dataName]) do inspectData[dataName][q] = nil end
			else
				inspectData[dataName] = {}
			end
		end
		for stateName,stateData in pairs(module.db.statsNames) do
			inspectData[stateName] = 0
		end

		cooldownsModule:ClearSessionDataReason(name,"azerite","essence","tier","item","legendary")

		local ilvl_count = 0

		local isArtifactEqipped = 0
		local ArtifactIlvlSlot1,ArtifactIlvlSlot2 = 0,0
		local mainHandSlot, offHandSlot = 0,0
		for i=1,#module.db.itemsSlotTable do
			local itemSlotID = module.db.itemsSlotTable[i]
			local itemLink, tooltipData
			inspectScantip:SetInventoryItem(inspectedName, itemSlotID)
			itemLink = select(2,inspectScantip:GetItem())
			if itemLink and (itemSlotID == 16 or itemSlotID == 17) and itemLink:find("item::") then
				itemLink = GetInventoryItemLink(inspectedName, itemSlotID)
			end

			if itemLink then
				inspectData['items'][itemSlotID] = itemLink
				local itemID = itemLink:match("item:(%d+):")

				if itemSlotID == 16 or itemSlotID == 17 then
					local _,_,quality = GetItemInfo(itemLink)
					if quality == 6 then
						isArtifactEqipped = isArtifactEqipped + 1
					end
				end

				local linesNum = inspectScantip:NumLines()
				for j=2, linesNum do
					local tooltipLine, text
					tooltipLine = _G["ExRTInspectScanningTooltipTextLeft"..j]
					text = tooltipLine:GetText()
					if text and text ~= "" then
						for stateName,stateData in pairs(module.db.statsNames) do
							inspectData[stateName] = inspectData[stateName] or 0
							local findText = text:gsub("[,]",""):gsub("(%d+)[ ]+(%d+)","%1%2")
							for k=1,#stateData do
								local findData = findText:match(stateData[k])
								if findData then
									local cR,cG,cB = tooltipLine:GetTextColor()
									cR = abs(cR - 0.5)
									cG = abs(cG - 0.5)
									cB = abs(cB - 0.5)
									if cR < 0.01 and cG < 0.01 and cB < 0.01 then
										findData = 0
									end
									inspectData[stateName] = inspectData[stateName] + tonumber(findData)
								end
							end
						end

						local ilvl = text:match(ITEM_LEVEL)
						if ilvl then
							ilvl = tonumber(ilvl)
							inspectData['ilvl'] = inspectData['ilvl'] + ilvl
							ilvl_count = ilvl_count + 1

							inspectData['items_ilvl'][itemSlotID] = ilvl

							if itemSlotID == 16 then
								mainHandSlot = ilvl
								ArtifactIlvlSlot1 = ilvl
							elseif itemSlotID == 17 then
								offHandSlot = ilvl
								ArtifactIlvlSlot2 = ilvl
							elseif itemSlotID == 2 and select(3,GetItemInfo(itemLink)) == 6 and itemLink:match("item:(%d+)") == "158075" then
								cooldownsModule.db.spell_cdByTalent_scalable_data[296320][name] = "*"..(1 - max(min((ilvl - 120) * 0.3 + 19.8, 25),10) / 100)

							end
						end

					end
				end

				if not inspectData['items_ilvl'][itemSlotID] then
					local ilvl = select(4,GetItemInfo(itemLink))
					if ilvl then
						inspectData['ilvl'] = inspectData['ilvl'] + ilvl
						ilvl_count = ilvl_count + 1

						inspectData['items_ilvl'][itemSlotID] = ilvl
					end
				end

				itemID = tonumber(itemID or 0)


				local tierSetID = cooldownsModule.db.tierSetsList[itemID]
				if tierSetID then
					inspectData['tiersets'][tierSetID] = inspectData['tiersets'][tierSetID] and inspectData['tiersets'][tierSetID] + 1 or 1
				end
				local isTrinket = cooldownsModule.db.itemsToSpells[itemID]
				if isTrinket then
					cooldownsModule.db.session_gGUIDs[name] = {isTrinket,"item"}
				end


				if GetInventoryItemQuality(inspectedName, itemSlotID) == 5 then
					local _,itemID,enchant,gem1,gem2,gem3,gem4,suffixID,uniqueID,level,specializationID,upgradeType,instanceDifficultyID,numBonusIDs,restLink = strsplit(":",itemLink,15)

					if numBonusIDs and numBonusIDs ~= "" and restLink then
						for j=1,tonumber(numBonusIDs) do
							local bonusID = select(j,strsplit(":",restLink))
							if bonusID then
								bonusID = tonumber(bonusID) or 0
								local spellID = cooldownsModule.db.itemsBonusToSpell[bonusID]
								if spellID then
									cooldownsModule.db.session_gGUIDs[name] = {spellID,"legendary"}
								end
							end
						end
					end
				end


				if (itemSlotID == 16 or itemSlotID == 17) and isArtifactEqipped > 0 then


					local _,itemID,enchant,gem1,gem2,gem3,gem4,suffixID,uniqueID,level,specializationID,upgradeType,instanceDifficultyID,numBonusIDs,restLink = strsplit(":",itemLink:match("|H.-|h") or itemLink,15)

					if ((gem1 and gem1 ~= "") or (gem2 and gem2 ~= "") or (gem1 and gem3 ~= "")) and (numBonusIDs and numBonusIDs ~= "") then
						numBonusIDs = tonumber(numBonusIDs)
						for j=1,numBonusIDs do
							if not restLink then
								break
							end
							local _,newRestLink = strsplit(":",restLink,2)
							restLink = newRestLink
						end
						if restLink then
							restLink = restLink:gsub("|h.-$","")

							if upgradeType and (tonumber(upgradeType) or 0) < 1000 then
								local _,newRestLink = strsplit(":",restLink,2)
								restLink = newRestLink
							else
								local _,_,newRestLink = strsplit(":",restLink,3)
								restLink = newRestLink
							end

							for relic=1,3 do
								if not restLink then
									break
								end
								local numBonusRelic,newRestLink = strsplit(":",restLink,2)
								numBonusRelic = tonumber(numBonusRelic or "?") or 0
								restLink = newRestLink

								if numBonusRelic > 10 then
									break
								end

								local relicBonus = numBonusRelic
								for j=1,numBonusRelic do
									if not restLink then
										break
									end
									local bonusID,newRestLink = strsplit(":",restLink,2)
									restLink = newRestLink
									relicBonus = relicBonus .. ":" .. bonusID
								end

								local relicItemID = select(3+relic, strsplit(":",itemLink) )
								if relicItemID and relicItemID ~= "" then
									inspectData['items']['relic'..relic] = "item:"..relicItemID.."::::::::110:0::0:"..relicBonus..":::"
								end
							end
						end
					end
				end
			end

			if ExRT.isClassic then
				inspectScantip:ClearLines()
			end
		end
		if isArtifactEqipped > 0 then
			inspectData['ilvl'] = inspectData['ilvl'] - ArtifactIlvlSlot1 - ArtifactIlvlSlot2 + max(ArtifactIlvlSlot1,ArtifactIlvlSlot2) * 2
		end
		inspectData['ilvl'] = inspectData['ilvl'] / (ilvl_count > 0 and ilvl_count or 16)


		for tierUID,count in pairs(inspectData['tiersets']) do
			local p2 = cooldownsModule.db.tierSetsSpells[tierUID][1]
			local p4 = cooldownsModule.db.tierSetsSpells[tierUID][2]
			if p2 and count >= 2 then
				if type(p2) ~= "table" then
					cooldownsModule.db.session_gGUIDs[name] = {p2,"tier"}
				else
					local sID = p2[ inspectData.specIndex or 0 ]
					if sID then
						cooldownsModule.db.session_gGUIDs[name] = {sID,"tier"}
					end
				end
			end
			if p4 and count >= 4 then
				if type(p4) ~= "table" then
					cooldownsModule.db.session_gGUIDs[name] = {p4,"tier"}
				else
					local sID = p4[ inspectData.specIndex or 0 ]
					if sID then
						cooldownsModule.db.session_gGUIDs[name] = {sID,"tier"}
					end
				end
			end
		end
		cooldownsModule:UpdateAllData()

		if not onlyPrepCall then
			ExRT.F:FireCallback("InspectItems", name, inspectData)
		end
	end
	module.InspectItems = InspectItems
end

hooksecurefunc("NotifyInspect", function() module.db.inspectID = GetTime() module.db.inspectCleared = nil end)
hooksecurefunc("ClearInspectPlayer", function() module.db.inspectCleared = true end)


do
	local tmr = -5
	local queueTimer = 0
	function module:timer(elapsed)
		tmr = tmr + elapsed
		if tmr > (inspectForce and 1 or 2) then
			queueTimer = queueTimer + tmr
			tmr = 0
			if queueTimer > 60 then
				queueTimer = 0
				InspectQueue()
			end
			InspectNext()
		end
	end
	function module:ResetTimer() tmr = 0 end
end

function module:Enable()
	module:RegisterTimer()
	module:RegisterEvents('PLAYER_SPECIALIZATION_CHANGED','INSPECT_READY','UNIT_INVENTORY_CHANGED','PLAYER_EQUIPMENT_CHANGED','GROUP_ROSTER_UPDATE','ZONE_CHANGED_NEW_AREA','INSPECT_ACHIEVEMENT_READY','CHALLENGE_MODE_START','ENCOUNTER_START','ENCOUNTER_END','UNIT_SPELLCAST_SUCCEEDED')
	module:RegisterAddonMessage()
end
function module:Disable()
	module:UnregisterTimer()
	module:UnregisterEvents('PLAYER_SPECIALIZATION_CHANGED','INSPECT_READY','UNIT_INVENTORY_CHANGED','PLAYER_EQUIPMENT_CHANGED','GROUP_ROSTER_UPDATE','ZONE_CHANGED_NEW_AREA','INSPECT_ACHIEVEMENT_READY','CHALLENGE_MODE_START','ENCOUNTER_START','ENCOUNTER_END','UNIT_SPELLCAST_SUCCEEDED')
	module:UnregisterAddonMessage()
end

local sessionTalentsCheckLimit = false

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	if ExRT.SDB.charName then
		module.db.inspectQuery[ExRT.SDB.charName] = GetTime()
		module.db.inspectNotItemsOnly[ExRT.SDB.charName] = true
	end

	VMRT.Inspect = VMRT.Inspect or {}
	VMRT.Inspect.Soulbinds = nil

	module:Enable()
end

function module.main:PLAYER_SPECIALIZATION_CHANGED(arg)
	local unit = arg
	if not unit or not UnitName(unit) then
		unit = "player"
	end
	if unit and UnitName(unit) then
		local name = UnitCombatlogname(unit)
		module.db.inspectDB[name] = nil


		VMRT.ExCD2.gnGUIDs[name] = nil

		local _,class = UnitClass(name)
		if cooldownsModule.db.spell_talentsList[class] then
			for specID,specTalents in pairs(cooldownsModule.db.spell_talentsList[class]) do
				for _,spellID in pairs(specTalents) do
					if type(spellID) == "number" then
						cooldownsModule.db.session_gGUIDs[name] = -spellID
					end
				end
			end
		end

		if cooldownsModule.db.talent_classic_rank and cooldownsModule.db.talent_classic_rank[name] then
			wipe(cooldownsModule.db.talent_classic_rank[name])
		end

		cooldownsModule:ClearSessionDataReason(name,"talent","pvptalent","autotalent")

		if UnitIsUnit(unit,"player") then
			if module.ApplySelfClassicTalents then
				module.ApplySelfClassicTalents()
			end
			if module.PrepTalentsClassicData and ExRT.F.SendExMsg and IsInGroup and IsInGroup() then
				local talents = module:PrepTalentsClassicData()
				if talents then
					ExRT.F.SendExMsg("inspect","R\tt:"..talents)
				end
			end
		end

		cooldownsModule:UpdateAllData()


		module.db.inspectQuery[name] = GetTime()
		module.db.inspectNotItemsOnly[name] = true
	end
end

function module.main:UNIT_SPELLCAST_SUCCEEDED(unitID,castGUID,spellID)
	if unitID and (not canaccessvalue or canaccessvalue(spellID)) and (spellID == 384255 or spellID == 200749) and UnitName(unitID) then
		local name = UnitCombatlogname(unitID)

		module:AddToQueue(name)


		if spellID == 200749 then

			VMRT.ExCD2.gnGUIDs[name] = nil

			local _,class = UnitClass(name)
			if cooldownsModule.db.spell_talentsList[class] then
				for specID,specTalents in pairs(cooldownsModule.db.spell_talentsList[class]) do
					for _,spellID in pairs(specTalents) do
						if type(spellID) == "number" then
							cooldownsModule.db.session_gGUIDs[name] = -spellID
						end
					end
				end
			end

			cooldownsModule:ClearSessionDataReason(name,"talent","pvptalent","autotalent")

			cooldownsModule:UpdateAllData()

		end
	end
end

do
	local scheludedQueue = nil
	local function funcScheduledUpdate()
		scheludedQueue = nil
		InspectQueue()
	end
	function module.main:GROUP_ROSTER_UPDATE()
		PruneNonRaidMembers()
		if not scheludedQueue then
			scheludedQueue = ScheduleTimer(funcScheduledUpdate,2)
		end
	end


	local prevDiff = nil
	local function ZoneCheck()
		local _,_,difficulty = GetInstanceInfo()
		if difficulty == 8 or prevDiff == 8 then
			local n = GetNumGroupMembers() or 0
			if IsInRaid() then
				n = min(n,5)
				for j=1,n do
					local name,_,subgroup = GetRaidRosterInfo(j)
					if name and subgroup == 1 then
						module.db.inspectNotItemsOnly[name] = true
						module.db.inspectQuery[name] = GetTime()
					end
				end
			else
				for j=1,5 do
					local uid = "party"..j
					if j==5 then
						uid = "player"
					end
					local name = UnitCombatlogname(uid)
					if name then
						module.db.inspectNotItemsOnly[name] = true
						module.db.inspectQuery[name] = GetTime()
					end
				end
			end
		end
		prevDiff = difficulty
	end
	function module.main:ZONE_CHANGED_NEW_AREA()
		ExRT.F.Timer(ZoneCheck,2)

		if not scheludedQueue then
			scheludedQueue = ScheduleTimer(funcScheduledUpdate,4)
		end
	end
	function module.main:CHALLENGE_MODE_START()
		ExRT.F.Timer(ZoneCheck,2)

		if not scheludedQueue then
			scheludedQueue = ScheduleTimer(funcScheduledUpdate,4)
		end

		module.main:ENCOUNTER_START()
	end
end

do
	local GetAndCacheSubTreeInfo_Data = {}
	local function GetAndCacheSubTreeInfo(subTreeID,activeConfig)
		if not GetAndCacheSubTreeInfo_Data[subTreeID] then
			GetAndCacheSubTreeInfo_Data[subTreeID] = C_Traits.GetSubTreeInfo(activeConfig, subTreeID)
		end

		return GetAndCacheSubTreeInfo_Data[subTreeID]
	end
	local function GetAndCacheSubTreeInfo_Reset()
		wipe(GetAndCacheSubTreeInfo_Data)
	end

	local lastInspectTime = {}
	function module.main:INSPECT_READY(arg)
		if module.db.inspectCleared or RaidInCombat() or (canaccessvalue and not canaccessvalue(UnitName("target"))) then
			return
		end
		ExRT.F.dprint('INSPECT_READY',arg)
		if not arg then
			return
		end
		local currTime = GetTime()
		if lastInspectTime[arg] and (currTime - lastInspectTime[arg]) < 0.2 then
			return
		end
		lastInspectTime[arg] = currTime
		local _,_,_,race,_,name,realm = GetPlayerInfoByGUID(arg)
		if name then
			if realm and realm ~= "" then name = name.."-"..realm end
			if not IsRaidMember(name) then
				return
			end
			local inspectedName = name
			if UnitName("player") == DelUnitNameServer(name) then
				inspectedName = "player"
			elseif UnitName("target") == DelUnitNameServer(name) then
				inspectedName = "target"
			elseif not UnitName(name) then
				return
			end
			module:ResetTimer()
			local _,class,classID = UnitClass(inspectedName)

			for i,slotID in pairs(module.db.itemsSlotTable) do
				local link = GetInventoryItemLink(inspectedName, slotID)
			end
			ScheduleTimer(InspectItems, inspectForce and 0.65 or 1.3, name, inspectedName, module.db.inspectID)
			if not inspectForce then

			end

			lastCheckNext[name] = nil
			if module.db.inspectDB[name] and module.db.inspectItemsOnly[name] and not module.db.inspectNotItemsOnly[name] then
				module.db.inspectItemsOnly[name] = nil
				return
			end
			module.db.inspectItemsOnly[name] = nil
			module.db.inspectNotItemsOnly[name] = nil

			if module.db.inspectDB[name] then
				wipe(module.db.inspectDB[name])
			else
				module.db.inspectDB[name] = {}
			end
			local data = module.db.inspectDB[name]

			data.spec = floor( GetInspectSpecialization(inspectedName) + 0.5 )
			if data.spec < 10000 then
				VMRT.ExCD2.gnGUIDs[name] = data.spec
			end
			data.class = class
			data.classID = classID
			data.level = UnitLevel(inspectedName)
			data.race = race
			data.time = time()
			data.GUID = UnitGUID(inspectedName)
			data.lastUpdate = currTime
			data.lastUpdateTime = time()

			local specIndex = 1
			for i=1,GetNumSpecializationsForClassID(classID) do
				if GetSpecializationInfoForClassID(classID,i) == data.spec then
					specIndex = i
					break
				end
			end
			data.specIndex = specIndex

			for i=1,7 do
				data[i] = 0
			end
			data.talentsIDs = {}

			cooldownsModule:ClearSessionDataReason(name,"talent","pvptalent","autotalent")

			if not ExRT.isLK then
				for spellID,specID in pairs(cooldownsModule.db.spell_autoTalent) do
					if specID == data.spec then
						cooldownsModule.db.session_gGUIDs[name] = {spellID,"autotalent"}
					end
				end
			end

			if ExRT.isLK then
				local talentsStr, specIndex = module:GetInspectTalentsClassicData(class)

				data.talentsStr = talentsStr and time()..":"..talentsStr or nil

				if ExRT.isLK then
					data.specIndex = specIndex
					data.spec = ExRT.GDB.ClassSpecializationList[class] and ExRT.GDB.ClassSpecializationList[class][specIndex] or data.spec
				end


				local c = 0
				while talentsStr do
					local spellID,spellRanks,on = strsplit(":",talentsStr,3)
					talentsStr = on

					spellID = tonumber(spellID)
					if spellID and spellID ~= 0 then
						local rankSelected = spellRanks:sub(1,1)
						local rankMax = spellRanks:sub(2,2)

						local list = cooldownsModule.db.spell_talentsList[class]
						if not list then
							list = {}
							cooldownsModule.db.spell_talentsList[class] = list
						end

						list[0] = list[0] or {}

						if not ExRT.F.table_find(list[0],spellID) then
							list[0][ #list[0]+1 ] = spellID
						end
						if rankSelected and (tonumber(rankSelected) or 0) > 0 then
							cooldownsModule.db.session_gGUIDs[name][spellID] = {"talent"}

							if cooldownsModule.db.spell_talentProvideAnotherTalents[spellID] then
								for k,v in pairs(cooldownsModule.db.spell_talentProvideAnotherTalents[spellID]) do
									cooldownsModule.db.session_gGUIDs[name][v] = {"talent"}
								end
							end

							cooldownsModule:SetTalentClassicRank(name,spellID,tonumber(rankSelected))
						end

						cooldownsModule.db.spell_isTalent[GetSpellInfo(spellID) or "spell:"..spellID] = true
						cooldownsModule.db.spell_isTalent[spellID] = true
					end
				end

			end

			InspectItems(name, inspectedName, module.db.inspectID, true)

			if PlayerGetTimerunningSeasonID and PlayerGetTimerunningSeasonID() == 2 then
				for i=1,255 do
					local auraData = C_UnitAuras.GetAuraDataByIndex(inspectedName, i)
					if not auraData then
						break
					elseif auraData.spellId == 1232454 then
						data.lemix_vers = auraData.points and auraData.points[5] or 0
						break
					end
				end
			end

			cooldownsModule:UpdateAllData()
		end
	end
end

do
	local lastInspectTime,lastInspectGUID = 0
	module.db.acivementsIDs = {}
	function module.main:INSPECT_ACHIEVEMENT_READY(guid)
		if module.db.blizzinterfaceunloaded and AchievementFrameComparison then
			AchievementFrameComparison:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
			module.db.blizzinterfaceunloaded = nil
		end
		if module.db.blizzinterfaceunloaded2 and InspectPVPFrame then
			InspectPVPFrame:UnregisterEvent("INSPECT_HONOR_UPDATE")
			module.db.blizzinterfaceunloaded2 = nil
		end
		if RaidInCombat() then
			return
		end
		ExRT.F.dprint('INSPECT_ACHIEVEMENT_READY',guid)
		if module.db.achievementCleared then
			C_Timer.NewTimer(.3,function() ClearAchievementComparisonUnit() end)
			return
		end
		local currTime = GetTime()
		if not guid or (lastInspectGUID == guid and (currTime - lastInspectTime) < 0.2) then
			C_Timer.NewTimer(.3,function() ClearAchievementComparisonUnit() end)
			return
		end
		lastInspectGUID = guid
		lastInspectTime = currTime
		local _,_,_,_,_,name,realm = GetPlayerInfoByGUID(guid)
		if name then
			if realm and realm ~= "" then name = name.."-"..realm end

			if module.db.inspectDBAch[name] then
				wipe(module.db.inspectDBAch[name])
			else
				module.db.inspectDBAch[name] = {}
			end
			local data = module.db.inspectDBAch[name]
			data.guid = guid
			data.points = GetComparisonAchievementPoints()
			for _,id in pairs(module.db.acivementsIDs) do
				if id > 0 then
					local completed, month, day, year, unk1 = GetAchievementComparisonInfo(id)
					if completed then
						data[id] = month..":"..day..":"..year
					end
				else
					id = -id
					local info = GetComparisonStatistic(id)
					info = tonumber(info or "-")
					if info then
						data[id] = info
					end
				end
			end
		end
		if not AchievementFrame or not AchievementFrame:IsShown() then
			C_Timer.NewTimer(.3,function() ClearAchievementComparisonUnit() end)
		end
	end
end

function module.main:UNIT_INVENTORY_CHANGED(arg)
	if ExRT.isClassic and not ExRT.isLK then
		return
	end
	if arg=='player' then return end
	local name = UnitCombatlogname(arg or "?")
	if name and name ~= ExRT.SDB.charName then
		C_Timer.After(0, function()
			module.db.inspectItemsOnly[name] = true
			module.db.inspectQuery[name] = GetTime()
		end)
	end
end

function module.main:PLAYER_EQUIPMENT_CHANGED(arg)
	C_Timer.After(0, function()
		local name = UnitCombatlogname("player")
		module.db.inspectItemsOnly[name] = true
		module.db.inspectQuery[name] = GetTime()
	end)
end


if ExRT.isLK then
	module.TALENTDATA = {
		DEATHKNIGHT = {
			{[1]={48979,48997,49182},[2]={48978,49004,55107},[3]={48982,48987,49467},[4]={48985,[3]=49145,[4]=49015},[5]={48977,[3]=49006,[4]=49005},[6]={[2]=48988,[3]=53137},[7]={49027,49016,50365},[8]={62905,49018,55233},[9]={49189,55050,49023},[10]={[2]=61154},[11]={[2]=49028}},
			{[1]={49175,49455,49042},[2]={[2]=55061,[3]=49140,[4]=49226},[3]={50880,49039,51468},[4]={[2]=51123,[3]=49149,[4]=49137},[5]={[2]=49186,[3]=49471,[4]=49796},[6]={55610,49024,49188},[7]={50040,49203,50384},[8]={65661,54639,51271},[9]={49200,49143,50187},[10]={[2]=49202},[11]={[2]=49184}},
			{[1]={51745,48962,55129},[2]={49036,48963,49588,48965},[3]={49013,51459,49158},[4]={[2]=49146,[3]=49219,[4]=55620},[5]={49194,49220,49223},[6]={55666,49224,49208,52143},[7]={66799,51052,50391,63560},[8]={[2]=49032,[3]=49222},[9]={49217,51099,55090},[10]={[2]=50117},[11]={[2]=49206}},
		},
		DRUID = {
			{[1]={[2]=16814,[3]=57810},[2]={16845,35363,[4]=16821},[3]={16836,16880,57865,16819},[4]={[2]=16909,[3]=16850},[5]={33589,5570,57849},[6]={33597,16896,33592},[7]={[2]=24858,[3]=48384,[4]=33600},[8]={48389,[3]=33603},[9]={48516,50516,33831,48488},[10]={[2]=48506},[11]={[2]=48505}},
			{[1]={[2]=16934,[3]=16858},[2]={16947,16998,16929},[3]={17002,61336,16942},[4]={16966,16972,37116,48409},[5]={16940,[3]=49377,[4]=33872},[6]={57878,17003,33853},[7]={[2]=17007,[3]=34297,[4]=33851},[8]={57873,[3]=33859,[4]=48483},[9]={48492,33917,48532},[10]={[2]=48432,[3]=63503},[11]={[2]=50334}},
			{[1]={17050,17063,17056},[2]={17069,17118,16833},[3]={17106,16864,48411},[4]={[2]=24968,[3]=17111},[5]={17116,17104,[4]=17123},[6]={33879,[3]=17074},[7]={34151,18562,33881},[8]={[2]=33886,[3]=48496},[9]={48539,65139,48535},[10]={63410,[3]=51179},[11]={[2]=48438}},
		},
		HUNTER = {
			{[1]={[2]=19552,[3]=19583},[2]={35029,19549,19609,24443},[3]={19559,53265,19616},[4]={[2]=19572,[3]=19598},[5]={19578,19577,[4]=19590},[6]={34453,[3]=19621},[7]={34455,19574,34462},[8]={53252,[3]=34466},[9]={53262,34692,53256},[10]={[2]=56314},[11]={[2]=53270}},
			{[1]={19407,53620,19426},[2]={34482,19421,19485},[3]={34950,19454,19434,34948},[4]={[2]=19464,[3]=19416},[5]={35100,23989,19461},[6]={34475,[4]=19507},[7]={53234,19506,35104},[8]={[2]=34485,[3]=53228},[9]={53215,34490,53221},[10]={[2]=53241},[11]={[2]=53209}},
			{[1]={52783,19498,19159},[2]={19290,19184,19376,34494},[3]={19255,19503,19295,19286},[4]={[2]=56333,[4]=56342},[5]={56339,19370,19306},[6]={19168,[3]=34491},[7]={34500,19386,34497},[8]={34506,53295},[9]={53298,3674,[4]=53302},[10]={[3]=53290},[11]={[2]=53301}},
		},
		MAGE = {
			{[1]={11210,11222,11237},[2]={28574,29441,11213},[3]={11247,11242,44397,54646},[4]={11252,11255,18462,29447},[5]={31569,12043,[4]=11232},[6]={31574,15058,31571},[7]={31579,12042,44394},[8]={[2]=44378,[3]=31584},[9]={[2]=31589,[3]=44404},[10]={[2]=44400,[3]=35578},[11]={[2]=44425}},
			{[1]={11078,18459,11069},[2]={11119,54747,11108},[3]={11100,11103,11366,11083},[4]={11095,11094,[4]=29074},[5]={31638,11115,11113},[6]={31641,[3]=11124},[7]={34293,11129,31679},[8]={64353,[3]=31656},[9]={44442,31661,44445},[10]={[2]=44449},[11]={[2]=44457}},
			{[1]={11071,11070,31670},[2]={11207,11189,29438,11175},[3]={11151,12472,11185},[4]={16757,11160,11170},[5]={[2]=11958,[3]=11190,[4]=31667},[6]={55091,[3]=11180},[7]={44745,11426,31674},[8]={[2]=31682,[3]=44543},[9]={44546,31687,44557},[10]={[2]=44566},[11]={[2]=44572}},
		},
		PALADIN = {
			{[1]={[2]=20205,[3]=20224},[2]={20237,20257,9453},[3]={31821,20210,20234},[4]={20254,[3]=20244,[4]=53660},[5]={31822,20216,20359},[6]={31825,[3]=5923},[7]={31833,20473,31828},[8]={53551,[3]=31837},[9]={31842,[3]=53671},[10]={[2]=53569,[3]=53556},[11]={[2]=53563}},
			{[1]={[2]=63646,[3]=20262},[2]={31844,20174,20096},[3]={64205,20468,20143},[4]={53527,20487,20138},[5]={[2]=20911,[3]=20177},[6]={31848,[3]=20196},[7]={31785,20925,31850},[8]={20127,[3]=31858},[9]={53590,31935,53583},[10]={[2]=53709,[3]=53695},[11]={[2]=53595}},
			{[1]={[2]=20060,[3]=20101},[2]={25956,20335,20042},[3]={9452,20117,20375,26022},[4]={9799,[3]=32043,[4]=31866},[5]={20111,[3]=31869},[6]={[2]=20049,[3]=31871},[7]={53486,20066,31876},[8]={[2]=31879,[3]=53375},[9]={53379,35395,53501},[10]={[2]=53380},[11]={[2]=53385}},
		},
		PRIEST = {
			{[1]={[2]=14522,[3]=47586},[2]={14523,14747,14749,14531},[3]={14521,14751,14748},[4]={33167,14520,[4]=14750},[5]={33201,18551,63574},[6]={33186,[3]=34908},[7]={45234,10060,63504},[8]={57470,47535,47507},[9]={47509,33206,47516},[10]={[2]=52795},[11]={[2]=47540}},
			{[1]={14913,14908,14889},[2]={[2]=27900,[3]=18530},[3]={19236,27811,[4]=14892},[4]={27789,14912,14909},[5]={14911,20711,14901},[6]={33150,[3]=14898},[7]={34753,724,33142},[8]={64127,33158,63730},[9]={63534,34861,47558},[10]={[2]=47562},[11]={[2]=47788}},
			{[1]={15270,15337,15259},[2]={15318,15275,15260},[3]={15392,15273,15407},[4]={[2]=15274,[3]=17322,[4]=15257},[5]={15487,15286,27839,33213},[6]={14910,[3]=63625},[7]={[2]=15473,[3]=33221},[8]={47569,[3]=33191},[9]={64044,34914,47580},[10]={[3]=47573},[11]={[2]=47585}},
		},
		ROGUE = {
			{[1]={14162,14144,14138},[2]={14156,51632,[4]=13733},[3]={14983,14168,14128},[4]={[2]=16513,[3]=14113},[5]={31208,14177,14174,31244},[6]={[2]=14186,[3]=14158},[7]={51625,58426,31380},[8]={51634,[3]=31234},[9]={31226,1329,51627},[10]={[2]=51664},[11]={[2]=51662}},
			{[1]={13741,13732,13715},[2]={14165,13713,[4]=13705},[3]={13742,14251,13706},[4]={13754,13743,13712,18427},[5]={13709,13877,13960},[6]={[2]=30919,[3]=31124},[7]={31122,13750,31130},[8]={5952,[3]=35541},[9]={51672,32601,51682},[10]={[2]=51685},[11]={[2]=51690}},
			{[1]={14179,13958,14057},[2]={30892,14076,13975},[3]={13981,14278,14171},[4]={13983,13976,14079},[5]={30894,14185,14082,16511},[6]={31221,[3]=30902},[7]={31211,14183,31228},[8]={[2]=31216,[3]=51692},[9]={51698,36554,58414},[10]={[2]=51708},[11]={[2]=51713}},
		},
		SHAMAN = {
			{[1]={[2]=16039,[3]=16035},[2]={16038,28996,30160},[3]={16040,16164,16089},[4]={16086,[4]=29062},[5]={28999,16041,[4]=30664},[6]={30672,[3]=16578},[7]={[2]=16166,[3]=51483},[8]={63370,51466,30675},[9]={51474,30706,51480},[10]={[2]=62097},[11]={[2]=51490}},
			{[1]={16259,16043,17485},[2]={16258,16255,16262,16261},[3]={16266,[3]=43338,[4]=16254},[4]={[2]=16256,[3]=16252},[5]={29192,16268,51883},[6]={30802,[3]=29082,[4]=63373},[7]={30816,30798,17364},[8]={51525,60103,51521},[9]={30812,30823,51523},[10]={[2]=51528},[11]={[2]=51533}},
			{[1]={[2]=16182,[3]=16173},[2]={16184,29187,16179},[3]={16180,16181,55198,16176},[4]={[2]=16187,[3]=16194},[5]={29206,[3]=16188,[4]=30864},[6]={[3]=16178},[7]={30881,16190,51886},[8]={51554,30872,30867},[9]={51556,974,51560},[10]={[2]=51562},[11]={[2]=61295}},
		},
		WARLOCK = {
			{[1]={18827,18174,17810},[2]={18179,18213,18182,17804},[3]={53754,17783,18288},[4]={18218,18094,[4]=32381},[5]={32385,63108,18223},[6]={54037,18271},[7]={47195,30060,18220},[8]={30054,[3]=32477},[9]={47198,30108,58435},[10]={[2]=47201},[11]={[2]=48181}},
			{[1]={18692,18694,18697,47230},[2]={18703,18705,18731},[3]={18754,19028,18708,30143},[4]={[2]=18769,[3]=18709},[5]={30326,[3]=18767},[6]={[2]=23785,[3]=47245},[7]={30319,47193,35691},[8]={[2]=30242,[3]=63156},[9]={54347,30146,63117},[10]={[2]=47236},[11]={[2]=59672}},
			{[1]={[2]=17793,[3]=17788},[2]={18119,63349,17778},[3]={18126,17877,17959},[4]={18135,17917,[4]=17927},[5]={34935,17815,18130},[6]={30299,[3]=17954},[7]={[2]=17962,[3]=30293,[4]=18096},[8]={[2]=30288,[3]=54117},[9]={47258,30283,47220},[10]={[2]=47266},[11]={[2]=50796}},
		},
		WARRIOR = {
			{[1]={12282,16462,12286},[2]={12285,12300,12295},[3]={12290,12296,16493,12834},[4]={[2]=12163,[3]=56636},[5]={12700,12328,12284,12281},[6]={20504,[3]=12289,[4]=46854},[7]={29834,12294,46865,12862},[8]={64976,35446,46859},[9]={29723,29623,29836},[10]={[2]=46867},[11]={[2]=46924}},
			{[1]={61216,12321,12320},[2]={[2]=12324,[3]=12322},[3]={12329,12323,16487,12318},[4]={23584,20502,12317},[5]={29590,12292,29888},[6]={20500,[3]=12319},[7]={46908,23881,[4]=29721},[8]={46910,[4]=29759},[9]={60970,29801,46913},[10]={[2]=56927},[11]={[2]=46917}},
			{[1]={12301,12298,12287},[2]={[2]=50685,[3]=12297},[3]={12975,12797,29598,12299},[4]={59088,12313,12308},[5]={12312,12809,12311},[6]={[3]=16538},[7]={29593,50720,29787},[8]={[2]=29140,[3]=46945},[9]={57499,20243,47294},[10]={[2]=46951,[3]=58872},[11]={[2]=46968}},
		},
	}
end

if ExRT.isLK then
	function module:PrepTalentsClassicData()
		local class = select(2,UnitClass("player"))
		local talents
		for spec=1,3 do
			for talPos=1,31 do
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfoClassic(spec, talPos)
				if name and maxRank > 0 and rank > 0 then
					talents = (talents and talents..":" or "") .. (module.TALENTDATA and module.TALENTDATA[class] and module.TALENTDATA[class][spec] and module.TALENTDATA[class][spec][tier] and module.TALENTDATA[class][spec][tier][column] or 0) .. ":" .. rank .. maxRank
				end
			end
		end
		return talents
	end
else
	function module:PrepTalentsClassicData()
		local class = select(2,UnitClass("player"))
		local talents
		for spec=1,3 do
			for talPos=1,31 do
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfoClassic(spec, talPos, 1)
				if name and maxRank > 0 and rank > 0 then
					talents = (talents and talents..":" or "") .. (module.TALENTDATA and module.TALENTDATA[class] and module.TALENTDATA[class][spec] and module.TALENTDATA[class][spec][talPos] or 0) .. ":" .. rank .. maxRank
				end
			end
		end
		return talents
	end
end


function module:GetInspectTalentsClassicData(class)
	if not ExRT.isLK then
		return
	end
	if not module.TALENTDATA or not module.TALENTDATA[class or ""] then
		return
	end
	local talents
	local specMax,specMaxNum = 1,1
	for spec=1,3 do
		local selectedNum = 0
		for talPos=1,31 do
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfoClassic(spec, talPos, true)
			if name and maxRank > 0 and rank > 0 then
				talents = (talents and talents..":" or "") .. ((module.TALENTDATA[class][spec][tier] and module.TALENTDATA[class][spec][tier][column]) or 0) .. ":" .. rank .. maxRank
				selectedNum = selectedNum + 1
			end
		end
		if selectedNum > specMaxNum then
			specMax = spec
			specMaxNum = selectedNum
		end
	end
	return talents, specMax
end

function module:TalentClassicReq(unit)
	ExRT.F.SendExMsg("inspect","REQ\tTC\t"..unit)
	module.db.TalentNoAddon = module.db.TalentNoAddon or {}
	module.db.TalentNoAddon[unit] = GetTime()
end

local EQUIPPED_FIRST = 1
local EQUIPPED_LAST = 19

function module.main:ENCOUNTER_END()
	if C_ChallengeMode and not C_ChallengeMode.IsChallengeModeActive() then
		return
	end
	local _, zoneType, difficulty, _, maxPlayers, _, _, mapID = GetInstanceInfo()
	if difficulty == 7 or difficulty == 17 then
		return
	end
	for _, name in ExRT.F.IterateRoster do
		module:AddToQueue(name)
	end
end

function module.main:ENCOUNTER_START()
end

function module.main:ENCOUNTER_START_SIM()
	local f = ExRT.F.SendExMsg
	local y
	local function o(...)y=select(2,...):sub(3) print(...) end
	ExRT.F.SendExMsg = o
	module.main:ENCOUNTER_START()
	ExRT.F.SendExMsg = f
	module:addonMessage(UnitName'player', "inspect", "R", y)
end


function module:addonMessage(sender, prefix, subPrefix, ...)
	if prefix == "inspect" then
		if subPrefix == "R" then
			local str = ...
			local senderFull = sender
			if select(2,strsplit("-",sender)) == ExRT.SDB.realmKey then
				sender = strsplit("-",sender)
			end
			while str do
				local main,next = strsplit("^",str,2)
				str = next

				local key = main:sub(1,1)
				if key == "T" then
					if ExRT.isClassic then
						if cooldownsModule:IsEnabled() then
							if cooldownsModule.WipeSessionData then
								cooldownsModule:WipeSessionData(sender)
							else
								cooldownsModule:ClearSessionDataReason(sender,"talent")
							end
						end

						local inspectData = module.db.inspectDB[sender]
						local row = 0

						local _,list = strsplit(":",main,2)
						while list do
							local spellID,on = strsplit(":",list,2)
							list = on

							spellID = tonumber(spellID or "?")
							if spellID then
								if spellID ~= 0 and cooldownsModule:IsEnabled() then
									cooldownsModule.db.session_gGUIDs[sender] = {spellID,"talent"}
									cooldownsModule.db.spell_isTalent[spellID] = true

									if cooldownsModule.db.spell_talentProvideAnotherTalents and cooldownsModule.db.spell_talentProvideAnotherTalents[spellID] then
										for _, v in pairs(cooldownsModule.db.spell_talentProvideAnotherTalents[spellID]) do
											cooldownsModule.db.session_gGUIDs[sender] = {v,"talent"}
											cooldownsModule.db.spell_isTalent[v] = true
										end
									end
								end
								row = row + 1
								if inspectData then
									if spellID == 0 then
										spellID = nil
									end
									inspectData[row] = spellID
								end
							end
						end
					end
				elseif key == "Y" then
					if ExRT.isClassic then
						return
					end
					local str2 = main:sub(2):gsub("##","^")

					local decoded = LibDeflate:DecodeForWoWAddonChannel(str2)
					if not decoded then return end
					local decompressed = LibDeflate:DecompressDeflate(decoded)
					if not decompressed then return end

					if cooldownsModule:IsEnabled() then
						if cooldownsModule.WipeSessionData then
							cooldownsModule:WipeSessionData(sender)
						else
							cooldownsModule:ClearSessionDataReason(sender,"talent")
						end
					end

					local inspectData = module.db.inspectDB[sender]

					local list = decompressed
					local c = 0
					while list do
						local spellID,on = strsplit(":",list,2)
						list = on
						local rank

						spellID,rank = strsplit("-",spellID)
						spellID = tonumber(spellID or "?")
						if spellID then
							if spellID ~= 0 then
								rank = tonumber(rank or "")
								if cooldownsModule:IsEnabled() then
									cooldownsModule.db.session_gGUIDs[sender] = {spellID,"talent"}
									cooldownsModule.db.spell_isTalent[spellID] = true

									if cooldownsModule.db.spell_talentProvideAnotherTalents and cooldownsModule.db.spell_talentProvideAnotherTalents[spellID] then
										for _, v in pairs(cooldownsModule.db.spell_talentProvideAnotherTalents[spellID]) do
											cooldownsModule.db.session_gGUIDs[sender] = {v,"talent"}
											cooldownsModule.db.spell_isTalent[v] = true
										end
									end

									if rank then
										cooldownsModule:SetTalentClassicRank(sender,spellID,rank)
									end
								end
								if inspectData then
									c = c + 1
									inspectData[c] = spellID
									if rank then
										inspectData[-c] = rank
									else
										inspectData[-c] = nil
									end
								end
							end
						end
					end
					if inspectData then
						for i=c+1,1000 do
							if not inspectData[i] then
								break
							end
							inspectData[i] = nil
							inspectData[-i] = nil
						end
					end

				elseif key == "t" and ExRT.isClassic then
					local enabled = cooldownsModule:IsEnabled()
					if enabled then
						if cooldownsModule.WipeSessionData then
							cooldownsModule:WipeSessionData(sender)
						else
							local classTalents = cooldownsModule.db.spell_talentsList
							if classTalents then
								for _, byClass in pairs(classTalents) do
									for _, list in pairs(byClass) do
										for _, spellID in pairs(list) do
											if type(spellID) == "number" then
												cooldownsModule.db.session_gGUIDs[sender] = -spellID
											end
										end
									end
								end
							end
							cooldownsModule:ClearSessionDataReason(sender,"talent","pvptalent","autotalent")
						end
						if cooldownsModule.WipeTalentClassicRank then
							cooldownsModule:WipeTalentClassicRank(sender)
						end
					end

					local talentRanks = {}
					local _,list = strsplit(":",main,2)
					while list do
						local spellID,ranks,on = strsplit(":",list,3)
						list = on

						spellID = tonumber(spellID or "?")
						local rankSelected = type(ranks) == "string" and tonumber(ranks:sub(1,1)) or nil
						if spellID and spellID ~= 0 and enabled and rankSelected and rankSelected > 0 then
							talentRanks[spellID] = rankSelected
							cooldownsModule.db.session_gGUIDs[sender] = {spellID,"talent"}


							cooldownsModule.db.spell_isTalent[GetSpellInfo(spellID) or "spell:"..spellID] = true
							cooldownsModule.db.spell_isTalent[spellID] = true

							if cooldownsModule.db.spell_talentProvideAnotherTalents and cooldownsModule.db.spell_talentProvideAnotherTalents[spellID] then
								for _, v in pairs(cooldownsModule.db.spell_talentProvideAnotherTalents[spellID]) do
									cooldownsModule.db.session_gGUIDs[sender] = {v,"talent"}
									cooldownsModule.db.spell_isTalent[GetSpellInfo(v) or "spell:"..v] = true
									cooldownsModule.db.spell_isTalent[v] = true
								end
							end

							if cooldownsModule.SetTalentClassicRank then
								cooldownsModule:SetTalentClassicRank(sender, spellID, rankSelected)
							end
						end
					end

					local senderClass = select(2, UnitClass(sender))
					local derivedSpec = senderClass and module.DeriveSpecFromTalentRanks and module.DeriveSpecFromTalentRanks(senderClass, talentRanks)
					if derivedSpec and derivedSpec < 10000 and VMRT and VMRT.ExCD2 and VMRT.ExCD2.gnGUIDs then
						VMRT.ExCD2.gnGUIDs[sender] = derivedSpec
					end

					if enabled then
						if cooldownsModule.db.session_TalentBroadcastReceived then
							cooldownsModule.db.session_TalentBroadcastReceived[sender] = "broadcast"
						end
						if cooldownsModule.UpdateAllData then
							cooldownsModule:UpdateAllData()
						end
					end

					VMRT.Inspect.TalentsClassic = VMRT.Inspect.TalentsClassic or {}
					if not sessionTalentsCheckLimit then
						sessionTalentsCheckLimit = true
						local count = 0
						for _ in pairs(VMRT.Inspect.TalentsClassic) do count = count + 1 end
						if count > 1500 then
							wipe(VMRT.Inspect.TalentsClassic)
						end
					end

					VMRT.Inspect.TalentsClassic[senderFull] = time()..main:sub(2)
				end
			end
		elseif subPrefix == "REQ" then
			local arg1, unit = ...
			if unit and (unit == UnitName'player' or strsplit("-",unit) == UnitName'player') then
				local currTime = GetTime()
				if module.db.reqantispam and (currTime - module.db.reqantispam < 5) then
					return
				end
				module.db.reqantispam = currTime

				if arg1 == "TC" and ExRT.isClassic then
					local talents = module:PrepTalentsClassicData()
					local str = ""

					if talents then
						str = str .. (str ~= "" and "^" or "") .. talents
					end

					if str ~= "" then
						ExRT.F.SendExMsg("inspect","R\tt:"..str)
					end
				end
			end
		end
	end
end


if ExRT.isLK and LibStub then
	local LibGroupTalents = LibStub("LibGroupTalents-1.0", true)
	if LibGroupTalents then
		local lastAppliedRankSet = {}
		local function ApplyLibTalents(guid, unit)
			if not cooldownsModule or not cooldownsModule.IsEnabled or not cooldownsModule:IsEnabled() then
				return
			end
			if not unit or not UnitExists(unit) then
				return
			end
			local name = UnitCombatlogname(unit)
			if not name then
				return
			end
			local _, class = UnitClass(unit)
			if not class then
				return
			end
			local treeData = module.TALENTDATA and module.TALENTDATA[class]
			if not treeData then
				return
			end
			local libCtd = LibGroupTalents.classTalentData and LibGroupTalents.classTalentData[class]
			if not libCtd or not libCtd[1] or not libCtd[2] or not libCtd[3] then
				return
			end
			local rankSet = LibGroupTalents:GetUnitTalents(unit)
			if type(rankSet) ~= "table" or #rankSet < 3 then
				return
			end
			local totalPoints = 0
			for _tab = 1, 3 do
				local _rs = rankSet[_tab]
				if type(_rs) == "string" then
					for _ci = 1, #_rs do
						totalPoints = totalPoints + (tonumber(_rs:sub(_ci, _ci)) or 0)
					end
				end
			end
			if totalPoints == 0 then
				return
			end
			local rsHash = tostring(rankSet[1] or "").."|"..tostring(rankSet[2] or "").."|"..tostring(rankSet[3] or "")
			if lastAppliedRankSet[name] == rsHash then
				return
			end
			lastAppliedRankSet[name] = rsHash

			local anyTab = false
			for tab = 1, 3 do
				local rankStr = rankSet[tab]
				local tabList = libCtd[tab] and libCtd[tab].list
				if type(rankStr) == "string" and tabList and #tabList > 0 then
					anyTab = true
					break
				end
			end
			if not anyTab then
				return
			end

			local classTalents = cooldownsModule.db.spell_talentsList[class]
			if cooldownsModule.WipeSessionData then
				cooldownsModule:WipeSessionData(name)
			else
				if classTalents then
					for _, list in pairs(classTalents) do
						for _, spellID in pairs(list) do
							if type(spellID) == "number" then
								cooldownsModule.db.session_gGUIDs[name] = -spellID
							end
						end
					end
				end
				cooldownsModule:ClearSessionDataReason(name, "talent", "pvptalent", "autotalent")
			end
			if cooldownsModule.WipeTalentClassicRank then
				cooldownsModule:WipeTalentClassicRank(name)
			end

			local list0 = cooldownsModule.db.spell_talentsList[class]
			if not list0 then
				list0 = {}
				cooldownsModule.db.spell_talentsList[class] = list0
			end
			list0[0] = list0[0] or {}

			local maxSpec, maxSpecPoints = 1, -1
			for tab = 1, 3 do
				local rankStr = rankSet[tab]
				local tabList = libCtd[tab] and libCtd[tab].list
				local mrtTab = treeData[tab]
				if type(rankStr) == "string" and tabList and mrtTab then
					local pointsInTab = 0
					for i = 1, #tabList do
						local entry = tabList[i]
						local rank = tonumber(rankStr:sub(i, i)) or 0
						if entry then
							local tier, column = entry.tier, entry.column
							local tierData = mrtTab[tier]
							local spellID = tierData and tierData[column]
							if type(spellID) == "number" then
								if not ExRT.F.table_find(list0[0], spellID) then
									list0[0][#list0[0] + 1] = spellID
								end

								if rank > 0 then
									pointsInTab = pointsInTab + rank
									cooldownsModule.db.spell_isTalent[GetSpellInfo(spellID) or "spell:"..spellID] = true
									cooldownsModule.db.spell_isTalent[spellID] = true
									cooldownsModule.db.session_gGUIDs[name][spellID] = {"talent"}

									if cooldownsModule.db.spell_talentProvideAnotherTalents and cooldownsModule.db.spell_talentProvideAnotherTalents[spellID] then
										for _, v in pairs(cooldownsModule.db.spell_talentProvideAnotherTalents[spellID]) do
											cooldownsModule.db.session_gGUIDs[name][v] = {"talent"}
										end
									end

									if cooldownsModule.SetTalentClassicRank then
										cooldownsModule:SetTalentClassicRank(name, spellID, rank)
									end
								end
							end
						end
					end
					if pointsInTab > maxSpecPoints then
						maxSpec, maxSpecPoints = tab, pointsInTab
					end
				end
			end

			local data = module.db.inspectDB[name]
			if data then
				data.specIndex = maxSpec
				data.spec = ExRT.GDB.ClassSpecializationList and ExRT.GDB.ClassSpecializationList[class] and ExRT.GDB.ClassSpecializationList[class][maxSpec] or data.spec
				if VMRT and VMRT.ExCD2 and VMRT.ExCD2.gnGUIDs and data.spec and data.spec < 10000 then
					VMRT.ExCD2.gnGUIDs[name] = data.spec
				end
			end

			if cooldownsModule.db.session_TalentBroadcastReceived then
				cooldownsModule.db.session_TalentBroadcastReceived[name] = "lgt"
			end

			if cooldownsModule.UpdateAllData then
				cooldownsModule:UpdateAllData()
			end
		end

		module.ApplyLibTalents = ApplyLibTalents

		LibGroupTalents.RegisterCallback(module, "LibGroupTalents_Update", function(_, guid, unit)
			if not unit then return end
			ApplyLibTalents(guid, unit)
		end)
		LibGroupTalents.RegisterCallback(module, "LibGroupTalents_RoleChange", function(_, guid, unit)
			if not unit then return end
			ApplyLibTalents(guid, unit)
		end)
		LibGroupTalents.RegisterCallback(module, "LibGroupTalents_UpdateComplete", function(_, ...)
			for i = 1, select("#", ...) do
				local guid = select(i, ...)
				local r = guid and LibGroupTalents.roster and LibGroupTalents.roster[guid]
				if r and r.unit then
					ApplyLibTalents(guid, r.unit)
				end
			end
		end)
	end
end

if ExRT.isLK then
	local function MarkAllTalentsAsTalent()
		local cooldownsModule = ExRT.A and ExRT.A.ExCD2
		if not cooldownsModule or not cooldownsModule.db or not cooldownsModule.db.spell_isTalent then
			return
		end
		if not module.TALENTDATA then
			return
		end
		for _, treeData in pairs(module.TALENTDATA) do
			for _, tabData in pairs(treeData) do
				for _, tierData in pairs(tabData) do
					if type(tierData) == "table" then
						for _, spellID in pairs(tierData) do
							if type(spellID) == "number" then
								cooldownsModule.db.spell_isTalent[GetSpellInfo(spellID) or "spell:"..spellID] = true
								cooldownsModule.db.spell_isTalent[spellID] = true
							end
						end
					end
				end
			end
		end
	end
	module.MarkAllTalentsAsTalent = MarkAllTalentsAsTalent

	local function DeriveSpecFromTalentRanks(class, talentRanks)
		local treeData = module.TALENTDATA and module.TALENTDATA[class]
		if not treeData then return nil end
		local maxSpec, maxSpecPoints = 1, -1
		for spec=1,3 do
			local mrtTab = treeData[spec]
			local pointsInTab = 0
			if mrtTab then
				for _, tierData in pairs(mrtTab) do
					if type(tierData) == "table" then
						for _, sid in pairs(tierData) do
							if type(sid) == "number" and talentRanks[sid] then
								pointsInTab = pointsInTab + talentRanks[sid]
							end
						end
					end
				end
			end
			if pointsInTab > maxSpecPoints then
				maxSpec, maxSpecPoints = spec, pointsInTab
			end
		end
		return ExRT.GDB.ClassSpecializationList and ExRT.GDB.ClassSpecializationList[class] and ExRT.GDB.ClassSpecializationList[class][maxSpec]
	end
	module.DeriveSpecFromTalentRanks = DeriveSpecFromTalentRanks

	local lastApplySelfTalentsTime = 0
	local function ApplySelfClassicTalents()
		-- Debounce: prevent multiple calls within 2 seconds
		local now = GetTime()
		if now - lastApplySelfTalentsTime < 2 then
			if true then dprint("[ApplySelfClassicTalents] Skipping (called "..string.format("%.1f", now - lastApplySelfTalentsTime).."s ago)") end
			return
		end

		local cooldownsModule = ExRT.A and ExRT.A.ExCD2
		if not cooldownsModule or not cooldownsModule.db or not cooldownsModule.db.session_gGUIDs then
			if true then dprint("[ApplySelfClassicTalents] Early return: cooldownsModule not ready") end
			return
		end
		if not GetTalentInfoClassic then
			if true then dprint("[ApplySelfClassicTalents] Early return: GetTalentInfoClassic not found") end
			return
		end
		local class = select(2, UnitClass("player"))
		if not class then
			if true then dprint("[ApplySelfClassicTalents] Early return: no class") end
			return
		end
		local treeData = module.TALENTDATA and module.TALENTDATA[class]
		if not treeData then
			if true then dprint("[ApplySelfClassicTalents] Early return: no treeData for "..tostring(class)) end
			return
		end
		local name = UnitCombatlogname("player")
		if not name then
			if true then dprint("[ApplySelfClassicTalents] Early return: no name") end
			return
		end

		if true then dprint("[ApplySelfClassicTalents] Starting for "..name.." class="..class) end

		-- Check if talent API is ready by testing first talent
		local testName, testIcon, testTier = GetTalentInfoClassic(1, 1)
		if not testName then
			if true then dprint("[ApplySelfClassicTalents] Talent API not ready yet (GetTalentInfo returned nil), scheduling retry in 0.5s") end
			C_Timer.After(0.5, function()
				ApplySelfClassicTalents()
			end)
			return
		end
		if true then dprint("[ApplySelfClassicTalents] Talent API ready (test: "..tostring(testName)..")") end

		local list0 = cooldownsModule.db.spell_talentsList[class]
		if not list0 then
			list0 = {}
			cooldownsModule.db.spell_talentsList[class] = list0
		end
		list0[0] = list0[0] or {}

		-- Initialize session_gGUIDs[name] as empty table
		if not cooldownsModule.db.session_gGUIDs[name] then
			cooldownsModule.db.session_gGUIDs[name] = {}
		end

		if cooldownsModule.WipeSessionData then
			cooldownsModule:WipeSessionData(name)
		else
			cooldownsModule:ClearSessionDataReason(name, "talent", "pvptalent", "autotalent")
		end
		if cooldownsModule.WipeTalentClassicRank then
			cooldownsModule:WipeTalentClassicRank(name)
		end

		local maxSpec, maxSpecPoints = 1, -1
		for spec = 1, 3 do
			local pointsInTab = 0
			local mrtTab = treeData[spec]
			if mrtTab then
				for talPos = 1, 31 do
					local _, _, tier, column, rank, maxRank = GetTalentInfoClassic(spec, talPos)
					if true and rank and rank > 0 then
						dprint("[ApplySelfClassicTalents] Spec "..spec.." pos "..talPos..": tier="..tostring(tier).." col="..tostring(column).." rank="..rank.."/"..maxRank)
					end
					if tier and column then
						local tierData = mrtTab[tier]
						local spellID = tierData and tierData[column]
						if type(spellID) == "number" then
							if not ExRT.F.table_find(list0[0], spellID) then
								list0[0][#list0[0] + 1] = spellID
							end
							if rank and rank > 0 then
								pointsInTab = pointsInTab + rank
								cooldownsModule.db.spell_isTalent[GetSpellInfo(spellID) or "spell:"..spellID] = true
								cooldownsModule.db.spell_isTalent[spellID] = true
								cooldownsModule.db.session_gGUIDs[name][spellID] = {"talent"}
								if true then dprint("[ApplySelfClassicTalents] Recorded talent: spellID="..spellID.." rank="..rank) end

								if cooldownsModule.db.spell_talentProvideAnotherTalents and cooldownsModule.db.spell_talentProvideAnotherTalents[spellID] then
									for _, v in pairs(cooldownsModule.db.spell_talentProvideAnotherTalents[spellID]) do
										cooldownsModule.db.session_gGUIDs[name][v] = {"talent"}
									end
								end

								if cooldownsModule.SetTalentClassicRank then
									cooldownsModule:SetTalentClassicRank(name, spellID, rank)
								end
							end
						end
					end
				end
			end
			if pointsInTab > maxSpecPoints then
				maxSpec, maxSpecPoints = spec, pointsInTab
			end
		end

		-- Set spec for own character
		local specID = ExRT.GDB.ClassSpecializationList and ExRT.GDB.ClassSpecializationList[class] and ExRT.GDB.ClassSpecializationList[class][maxSpec]
		if specID and VMRT and VMRT.ExCD2 and VMRT.ExCD2.gnGUIDs then
			VMRT.ExCD2.gnGUIDs[name] = specID
			if true then dprint("[ApplySelfClassicTalents] Set gnGUIDs["..name.."]="..specID.." (maxSpec="..maxSpec..", points="..maxSpecPoints..")") end
		end

		if cooldownsModule.db.session_TalentBroadcastReceived then
			cooldownsModule.db.session_TalentBroadcastReceived[name] = "self"
		end

		if true then
			local cnt = 0
			local sg = cooldownsModule.db.session_gGUIDs[name]
			if type(sg) == "table" then for _ in pairs(sg) do cnt = cnt + 1 end end
			dprint("[ApplySelfClassicTalents] Finished. session_gGUIDs["..name.."] has "..cnt.." entries")
		end

		lastApplySelfTalentsTime = GetTime()

		dprint("[ApplySelfClassicTalents] About to call UpdateRoster, cooldownsModule=", cooldownsModule and "exists" or "nil")
		if cooldownsModule and cooldownsModule.UpdateRoster then
			dprint("[ApplySelfClassicTalents] Calling UpdateRoster")
			cooldownsModule:UpdateRoster()
			dprint("[ApplySelfClassicTalents] UpdateRoster finished")
		else
			dprint("[ApplySelfClassicTalents] UpdateRoster not available")
		end

		if cooldownsModule and cooldownsModule.UpdateAllData then
			cooldownsModule:UpdateAllData()
		end
	end
	module.ApplySelfClassicTalents = ApplySelfClassicTalents

	function module:DumpTalentRead(unit)
		unit = unit or "player"
		local cd = ExRT.A and ExRT.A.ExCD2
		if not cd or not cd.db or not cd.db.session_gGUIDs then print("|cffff5555[TalentRead]|r ExCD2 not ready"); return end
		local class = select(2, UnitClass(unit))
		local name = ExRT.F.UnitCombatlogname(unit)
		local treeData = module.TALENTDATA and module.TALENTDATA[class]
		print("|cff33ff99[TalentRead]|r "..tostring(name).." ("..tostring(class)..") unit="..unit)
		if not treeData then print("  no TALENTDATA for class"); return end
		local isOther = not UnitIsUnit(unit, "player")
		local mismatch, recorded, missing = 0, 0, 0
		for spec = 1, 3 do
			local mrtTab = treeData[spec]
			local n = (GetNumTalents and GetNumTalents(spec, isOther)) or 31
			for talPos = 1, n do
				local tName, _, tier, column, rank, maxRank = GetTalentInfoClassic(spec, talPos, isOther)
				if tName and rank and rank > 0 then
					local mappedID = (mrtTab and tier and column and mrtTab[tier]) and mrtTab[tier][column] or nil
					if type(mappedID) == "number" then
						local mappedName = (ExRT.F.GetSpellInfoSafe and ExRT.F.GetSpellInfoSafe(mappedID)) or GetSpellInfo(mappedID)
						local inSG = cd.db.session_gGUIDs[name][mappedID] and "Y" or "-"
						local flag
						if not mappedName then
							flag = "NAME?"
						elseif mappedName == tName then
							flag = "OK"
						else
							flag = "MISMATCH"; mismatch = mismatch + 1
						end
						if inSG == "Y" then recorded = recorded + 1 else missing = missing + 1 end
						print(string.format("  s%d t%d c%d |%s| r%d/%d -> %d |%s| [%s] sg=%s",
							spec, tier, column, tName, rank, maxRank or 0,
							mappedID, tostring(mappedName), flag, inSG))
					end
				end
			end
		end
		local sg = cd.db.session_gGUIDs[name]
		local cnt = 0; if type(sg) == "table" then for _ in pairs(sg) do cnt = cnt + 1 end end
		local prov = cd.db.spell_talentProvideAnotherTalents
		if type(prov) == "table" then
			for talID, list in pairs(prov) do
				if sg and sg[talID] and type(list) == "table" then
					for _, procID in ipairs(list) do
						print(string.format("  bridge: have %d (%s) -> proc %d (%s) sg=%s",
							talID, tostring(GetSpellInfo(talID)), procID, tostring(GetSpellInfo(procID)),
							sg[procID] and "Y" or "-"))
					end
				end
			end
		end
		print(string.format("  -- CD-talents: recorded=%d missing=%d MISMATCH=%d | session_gGUIDs total=%d", recorded, missing, mismatch, cnt))
	end
	SLASH_MRTCDTALREAD1 = "/cdtalread"
	SlashCmdList["MRTCDTALREAD"] = function(msg)
		local u = (msg and msg ~= "" and msg) or "player"
		module:DumpTalentRead(u)
	end

	local lastSelfTalentBroadcast = 0
	local pendingBroadcast = nil
	local function BroadcastSelfTalents()
		if not module.PrepTalentsClassicData or not ExRT.F.SendExMsg then return end
		if not IsInGroup or not IsInGroup() then return end
		local now = GetTime()
		if now - lastSelfTalentBroadcast < 5 then
			if not pendingBroadcast then
				pendingBroadcast = true
				C_Timer.After(5 - (now - lastSelfTalentBroadcast) + 0.1, function()
					pendingBroadcast = nil
					BroadcastSelfTalents()
				end)
			end
			return
		end
		local talents = module:PrepTalentsClassicData()
		if talents then
			lastSelfTalentBroadcast = now
			ExRT.F.SendExMsg("inspect","R\tt:"..talents)
		end
	end
	module.BroadcastSelfTalents = BroadcastSelfTalents

	local talentBootstrap = CreateFrame("Frame")
	talentBootstrap:RegisterEvent("PLAYER_LOGIN")
	talentBootstrap:RegisterEvent("PLAYER_ENTERING_WORLD")
	talentBootstrap:RegisterEvent("PLAYER_TALENT_UPDATE")
	talentBootstrap:RegisterEvent("CHARACTER_POINTS_CHANGED")
	talentBootstrap:RegisterEvent("SPELLS_CHANGED")
	talentBootstrap:RegisterEvent("GROUP_ROSTER_UPDATE")
	talentBootstrap:RegisterEvent("RAID_ROSTER_UPDATE")
	talentBootstrap:RegisterEvent("PARTY_MEMBERS_CHANGED")
	talentBootstrap:SetScript("OnEvent", function(self, event)
		if event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
			BroadcastSelfTalents()
			return
		end
		MarkAllTalentsAsTalent()
		ApplySelfClassicTalents()
		if event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED" or event == "SPELLS_CHANGED" then
			BroadcastSelfTalents()
		end
	end)
end
