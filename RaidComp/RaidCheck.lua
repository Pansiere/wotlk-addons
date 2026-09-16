local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)

local LibGT = LibStub("LibGroupTalents-1.0")

addon.raidIds = { }
addon.raidClass = { }
addon.raidSubGroup = { }
addon.raidPets = { }
addon.xrealmRaidDB = { }
addon.xrealmAltDB = { }

local SPECTHRESHOLD = 36
local callbackRegistered = false
local petTypes = nil


-- This function takes a unitId, retrieves their talents from LibGroupTalents and adds the information into the database
function addon:HandleTalents(unit)
    local playerName = GetUnitName(unit, true)
    local playerRealm = select(2, UnitName(unit))
    if playerRealm == "" then playerRealm = nil end
    local engClass = select(2, UnitClass(unit))
    
    -- Exit if LibGroupTalents doesn't have the talents yet
    if not LibGT:GetUnitTalents(unit) then
        return
    end
    
    -- For each talent spec
    for group = 1, LibGT:GetNumTalentGroups(unit) do
        local specId, specPoints = addon.IDHYBRID, ""
        
        -- Get the number of points spent in each talent tree
        local pointsSpent = { LibGT:GetUnitTalentSpec(unit, group) }
        
        -- Exit if we don't have the data for this spec yet
        if pointsSpent == {} then
            addon:PrDebug("Unable to get pointsSpent for "..playerName)
            return
        end

        -- Remove the first element of the array (Dominant tree name)
        tremove(pointsSpent, 1)
        
        -- Find the tab id of the dominant tree, if there is one
        for tab = 1, 3 do
            if not pointsSpent[tab] or pointsSpent[tab] == "" then
                pointsSpent[tab] = 0
            elseif pointsSpent[tab] >= SPECTHRESHOLD then
                specId = tab
            end
        end

        -- Build the specPoints variable (i.e. 0/56/15 for a Demo Warlock)
        specPoints = pointsSpent[1].."/"..pointsSpent[2].."/"..pointsSpent[3]
        
        -- For each potential key talent for this class
        local keyTalents = { }
        for spellId, talentLoc in pairs(addon.TALENTLOC[engClass]) do
            local tabIndex, talentIndex = strsplit(":", talentLoc)
            tabIndex = tonumber(tabIndex)
            talentIndex = tonumber(talentIndex)

            local talentName, _, _, _, currentRank, maxRank = LibGT:GetTalentInfo(unit, tabIndex, talentIndex, group)
            
            -- Exit if we can't find the maxRank for this talent
            if not maxRank then
                addon:PrDebug("Unable to get maxRank for "..playerName..", "..talentLoc..", "..group)
                local missingNames = LibGT:GetTalentMissingNames()
                if missingNames then
                    addon:PrDebug("Missing talents for "..missingNames)
                else
                    addon:PrDebug("Missing talents for no players")
                end
                
                return
            end
            
            if currentRank then
                local acceptRank = addon.RANKFORACCEPT[engClass][spellId]
                if not acceptRank then acceptRank = maxRank end

                if currentRank >= acceptRank then
                    -- Player has this talent, put it in some table
                    keyTalents[spellId] = true
                end
            end
        end
        
        -- If this is the active talent group set it as the player's talent record, otherwise set it as their alt record
        -- Note that the code currently only handles a maximum of 2 talent specs
        if group == LibGT:GetActiveTalentGroup(unit) then
            addon:InsertTalentInfo(playerName, engClass, specId, specPoints, keyTalents, playerRealm)
        else
            addon:InsertAltTalentInfo(playerName, engClass, specId, specPoints, keyTalents, playerRealm)
        end
    end
end

-- Returns the number of completed talent scans from LibGroupTalents
function addon:GetTalentCount()
    return LibGT:GetTalentCount()
end

-- LibGT has updated talent data for a known player, so update their record and then recalculate the RaidComp
function addon:LibGroupTalents_Update(e, guid, unit, newSpec, n1, n2, n3, oldSpec, o1, o2, o3)
    addon:HandleTalents(unit)
    addon:Recalculate()
end

-- Someone has joined the raid, so do a complete recheck including rebuilding the roster
function addon:LibGroupTalents_Add(e, guid, unit, name, realm)
    if addon.mode == "RAID" then
        addon:RaidCheck()
    elseif addon.mode == "CALENDAR" then
        addon:HandleTalents(unit)
        addon:Recalculate()
    end
end

-- Someone has left the raid, so do a complete recheck including rebuilding the roster
function addon:LibGroupTalents_Remove(e, guid, name, realm)
    if addon.mode == "RAID" then
        addon:RaidCheck()
    end
end

-- This is called when the RAID_ROSTER_UPDATE or UNIT_PET events are triggered
-- It checks to see if any player has moved to a different raid subgroup and calls a RaidCheck if it finds one
-- It also checks to see if any player pets have changed and calls a RaidCheck if they have
-- If someone has joined or left the raid it does nothing, as these events are handled by LibGT
function addon:EventHandler(widget, event, arg)
    addon:PrDebug("RaidComp:EventHandler() - "..event)
    
    if addon.mode == "RAID" then
        local changed
        
        if event == "RAID_ROSTER_UPDATE" then
            if addon:InRaid() then
                local i = 1
                local playerName, _, subgroup, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
                
                while playerName and subgroup and addon.raidSubGroup[playerName] and not changed do
                    if addon.raidSubGroup[playerName] ~= subgroup then
                        changed = playerName
                        addon:PrDebug("EventHandler: "..changed.." changed subgroup")
                    end

                    i = i + 1
                    playerName, _, subgroup, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
                end
            end
            
        elseif event == "UNIT_PET" and arg ~= "target" and arg ~= "focus" and arg ~= "mouseover" then
            -- When in a raid we can ignore "player" pet events as there will be a duplicate "raidX" pet event for the player
            if addon:InRaid() and arg ~= "player" and  UnitInRaid(arg) then
                changed = arg
                addon:PrDebug("EventHandler: "..changed.." changed pet")
            elseif UnitInParty(arg) then
                changed = arg
                addon:PrDebug("EventHandler: "..changed.." changed pet")
            end
        end
        
        if changed then
            addon:RaidCheck()
        else
            addon:PrDebug("EventHandler: Event triggered but no change detected")
        end
    end
end

-- This function is called to rebuild the roster and recalculate the RaidComp
-- It will register the talent update callbacks with LibGroupTalents if that hasn't already been done
-- It's called when the GUI is opened, when the roster changes, or when the user purges the database
function addon:RaidCheck()
    addon:PrDebug("RaidComp:RaidCheck()")
    
    if not callbackRegistered then
        LibGT.RegisterCallback(self, "LibGroupTalents_Update")
        LibGT.RegisterCallback(self, "LibGroupTalents_Add")
        LibGT.RegisterCallback(self, "LibGroupTalents_Remove")
        callbackRegistered = true
    end
   
    addon:BuildRoster()
    addon:UpdateIgnores()
    
    if addon.mode == "RAID" then
        for unit, _ in pairs(addon.raidIds) do
            addon:HandleTalents(unit)
        end
    end
    
    addon:Recalculate()
end

-- This function purges records that are more than 90 days old from the database
function addon:PurgeObsolete()
    local cutoff = time() - (90 * 24 * 60 * 60)
    local count = 0
    
    for playerName,record in pairs(addon.db.factionrealm.raidDB) do
        if record and record.updateTime < cutoff then
            addon:PrDebug("Purging "..playerName.." from database")
            addon.db.factionrealm.raidDB[playerName] = nil
            
            if addon.db.factionrealm.altDB[playerName] then
                addon.db.factionrealm.altDB[playerName] = nil
            end
            
            count = count + 1
        end
    end
    
    addon:Print( format(L["format_purgeobsolete"], count) )
end

-- This function purges the internal talent databases and orders LibGroupTalents to do the same
-- It then calls RaidCheck to rescan player talents
function addon:PurgeAndRescan()
    addon.db.factionrealm.raidDB = wipe(addon.db.factionrealm.raidDB)
    addon.db.factionrealm.altDB = wipe(addon.db.factionrealm.altDB)
    addon.xrealmRaidDB = wipe(addon.xrealmRaidDB)
    addon.xrealmAltDB = wipe(addon.xrealmAltDB)
    
    LibGT:PurgeAndRescanTalents()

    addon:Print( L["purge_and_rescan"] )

    addon:RaidCheck()
end

-- This function inserts a player's record into the database, or updates it if it already exists
function addon:InsertTalentInfo(playerName, engClass, specId, specPoints, keyTalents, playerRealm)
    if playerRealm then
        --addon:PrDebug( format("xrealmRaidDB: Storing %s (%s) - %s (%s), realm is '%s'.", playerName, engClass, addon:GetSpecName(engClass, specId), specPoints, playerRealm) )
        -- Player is from another realm so store this data temporarily
        if addon.xrealmRaidDB[playerName] then
            -- Alter existing record
            addon.xrealmRaidDB[playerName].engClass = engClass
            addon.xrealmRaidDB[playerName].specId = specId
            addon.xrealmRaidDB[playerName].specPoints = specPoints
            addon.xrealmRaidDB[playerName].keyTalents = keyTalents
            addon.xrealmRaidDB[playerName].updateTime = time()
        else
            -- Build new record
            addon.xrealmRaidDB[playerName] = {
                playerName = playerName,
                engClass = engClass,
                specId = specId,
                specPoints = specPoints,
                keyTalents = keyTalents,
                updateTime = time(),
              }
        end
    else
        --addon:PrDebug( format("raidDB: Storing %s (%s) - %s (%s).", playerName, engClass, addon:GetSpecName(engClass, specId), specPoints) )
        -- Player is from our realm so store this data in the database
        if addon.db.factionrealm.raidDB[playerName] then
            -- Alter existing record
            addon.db.factionrealm.raidDB[playerName].engClass = engClass
            addon.db.factionrealm.raidDB[playerName].specId = specId
            addon.db.factionrealm.raidDB[playerName].specPoints = specPoints
            addon.db.factionrealm.raidDB[playerName].keyTalents = keyTalents
            addon.db.factionrealm.raidDB[playerName].updateTime = time()
        else
            -- Build new record
            addon.db.factionrealm.raidDB[playerName] = {
                playerName = playerName,
                engClass = engClass,
                specId = specId,
                specPoints = specPoints,
                keyTalents = keyTalents,
                updateTime = time(),
              }
        end
    end
end

-- This function inserts a player's alt spec record into the database, or updates it if it already exists
function addon:InsertAltTalentInfo(playerName, engClass, specId, specPoints, keyTalents, playerRealm)
    if playerRealm then
        --addon:PrDebug( format("xrealmAltDB: Storing %s (%s) - %s (%s), realm is '%s'.", playerName, engClass, addon:GetSpecName(engClass, specId), specPoints, playerRealm) )
        -- Player is from another realm so store this data temporarily
        if addon.xrealmAltDB[playerName] then
            -- Alter existing record
            addon.xrealmAltDB[playerName].engClass = engClass
            addon.xrealmAltDB[playerName].specId = specId
            addon.xrealmAltDB[playerName].specPoints = specPoints
            addon.xrealmAltDB[playerName].keyTalents = keyTalents
            addon.xrealmAltDB[playerName].updateTime = time()
        else
            -- Build new record
            addon.xrealmAltDB[playerName] = {
                playerName = playerName,
                engClass = engClass,
                specId = specId,
                specPoints = specPoints,
                keyTalents = keyTalents,
                updateTime = time(),
              }
        end
    else
        --addon:PrDebug( format("altDB: Storing %s (%s) - %s (%s).", playerName, engClass, addon:GetSpecName(engClass, specId), specPoints) )
        -- Player is from our realm so store this data in the database
        if addon.db.factionrealm.altDB[playerName] then
            -- Alter existing record
            addon.db.factionrealm.altDB[playerName].engClass = engClass
            addon.db.factionrealm.altDB[playerName].specId = specId
            addon.db.factionrealm.altDB[playerName].specPoints = specPoints
            addon.db.factionrealm.altDB[playerName].keyTalents = keyTalents
            addon.db.factionrealm.altDB[playerName].updateTime = time()
        else
            -- Build new record
            addon.db.factionrealm.altDB[playerName] = {
                playerName = playerName,
                engClass = engClass,
                specId = specId,
                specPoints = specPoints,
                keyTalents = keyTalents,
                updateTime = time(),
              }
        end
    end
end

-- Function not currently implemented
function addon:AddToRoster(name)
end

-- Function not currently implemented
function addon:RemoveFromRoster(name)
end

-- This function wipes the current list of players and pets and rebuilds it
-- It is called when a RaidCheck is run, which happens when people join and leave the raid/party
function addon:BuildRoster()
    addon.raidIds = wipe(addon.raidIds)
    addon.raidClass = wipe(addon.raidClass)
    addon.raidSubGroup = wipe(addon.raidSubGroup)
    addon.raidPets = wipe(addon.raidPets)
    
    local addself = false
    
    if addon.mode == "RAID" then
        if addon:InRaid() then
            local i = 1
            local playerName, _, subgroup, level, _, engClass, _, _, _, _, _ = GetRaidRosterInfo(i)
            
            while playerName do
                if UnitInRaid(playerName) then
                    addon.raidIds["raid"..i] = playerName
                    addon.raidClass[playerName] = engClass
                    addon.raidSubGroup[playerName] = subgroup
                end
                
                if UnitExists("raidpet"..i) then
                    addon:AddPet("raidpet"..i, UnitName("raid"..i), UnitName("raidpet"..i), addon:UnitPetType("raidpet"..i))
                end
                
                i = i + 1
                playerName, _, subgroup, level, _, engClass, _, _, _, _, _ = GetRaidRosterInfo(i)
            end
        
        elseif addon:InParty() then 
            local i = 1
            
            while UnitExists("party"..i) do
                local playerName, engClass = GetUnitName("party"..i, true), select(2, UnitClass("party"..i))

                addon.raidIds["party"..i] = playerName
                addon.raidClass[playerName] = engClass
                addon.raidSubGroup[playerName] = 1
				
				if UnitExists("partypet"..i) then
                    addon:AddPet("partypet"..i, UnitName("party"..i), UnitName("partypet"..i), addon:UnitPetType("partypet"..i))
				end
                
                i = i + 1
            end
        
            addself = true
        
        else -- solo
            addself = true
        end
        
        if addself then
            local playerName, engClass = select(1, UnitName("player")), select(2, UnitClass("player"))
            addon.raidIds["player"] = playerName
            addon.raidClass[playerName] = engClass
            addon.raidSubGroup[playerName] = 1
			
			if UnitExists("pet") then
                addon:AddPet("pet", UnitName("player"), UnitName("pet"), addon:UnitPetType("pet"))
			end
        end
        
    elseif addon.mode == "CALENDAR" then
        for inviteeId,record in pairs( addon:GetEventInvitees() ) do
            addon.raidIds[inviteeId] = record.playerName
            addon.raidClass[record.playerName] = record.engClass
            addon.raidSubGroup[record.playerName] = record.inviteStatus
        end
    end
end


-- =================================
-- Pet functions
-- =================================

function addon:AddPet(petId, playerName, petName, petType)
    addon.raidPets[petId] = {
        playerName = playerName,
        petName = petName,
        petType = petType,
      }
end

function addon:RemovePet(petId)
    addon.raidPets[petId] = nil
end

-- This function returns the record for the pet with the specified UnitId
-- Note that petName is unreliable as it will often be "Unknown" when the pet record is added
function addon:GetPetRecord(petId)
    return addon.raidPets[petId]
end

-- This function returns a list containing the name of every player that currently has a pet of the specified type
function addon:GetPetOwners(petType)
    local petOwners = { }
    
    for petId,petRecord in pairs(addon.raidPets) do
        if petRecord.petType == petType then
            tinsert(petOwners, petRecord.playerName)
        end
    end
    
    return petOwners
end

-- This function marks a specific Hunter or Warlock pet as being present in the raid
-- As UnitCreatureFamily() returns a localised family name this needs to be de-localised first
function addon:UnitPetType(petId)
    if not petTypes then
        petTypes = { }
        for petIndex,petObject in ipairs(addon.PETABILITIES) do
            petTypes[ L[petObject.petType] ] = petObject.petType
        end
    end
    
    local locFamily = UnitCreatureFamily(petId)
    
    if locFamily then
        return petTypes[locFamily]
    else
        return nil
    end
end
