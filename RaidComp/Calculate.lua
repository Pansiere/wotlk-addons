local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)

-- Arrays that store calculated data
addon.simpleCount = {}
addon.sumItems = {}
addon.itemRank = {}
addon.spellProviders = {}
addon.altSpellProviders = {}


-- This function is called whenever something changes that may alter the RaidComp
-- For example players joining and leaving the raid, switching to their alt spec, etc
function addon:Recalculate()
    addon:PrDebug("RaidComp:Recalculate()")
    
    addon:CalculateAll()
    
    addon.db.factionrealm.lastCalc = time()
    addon:CalcLabel_Refresh()

    addon:RefreshGUI()
end

function addon:CalculateAll()
    -- Wipe calculated data
    addon.simpleCount = wipe(addon.simpleCount)
    addon.sumItems = wipe(addon.sumItems)
    addon.itemRank = wipe(addon.itemRank)
    addon.spellProviders = wipe(addon.spellProviders)
    addon.altSpellProviders = wipe(addon.altSpellProviders)
    
    -- For each player/fake/pet, checks what spells/talents they 'cause', and count those
    addon:CountSpellOccurences()
    
    -- For each buff-item-category, sum the spells in that category
    addon:SumItems()
    
    -- For each buff-item-category, determine the highest 'rank' of available spells
    -- 'rank' implies, for example, that Totem of Wrath is a better buff than Flametongue Totem (in the +Spellpower buff-item)
    addon:CalcItemRank()
end

-- This function populates the table addon.itemRank
-- The table is used to determine the highest rank of spell available for each buff type
function addon:CalcItemRank()
    local count = 0
    local rank = 1000
    
    -- For each buff type
    for itemName,spells in pairs(addon.SPELLRANK) do
        rank = 1000
        
        -- Find the highest rank of spell available
        for spellId,spellRank in pairs(spells) do
            count = addon.simpleCount[spellId]
            
            if not count then count = 0 end
            if (count >= addon.FULL) and (spellRank < rank) then
                rank = spellRank
            end
        end
        
        addon.itemRank[itemName] = rank 
    end
end

-- This function populates the table addon.sumItems
-- The table is used to determine whether a buff is "present" or "maybe"
function addon:SumItems()
    local total
    
    -- For each buff type
    for itemName,itemSpells in pairs(addon.SPELLIDS) do
        total = 0
        
        -- Sum together values indicating whether those spells are available
        for spellIndex,spellId in ipairs( itemSpells ) do
            if addon.simpleCount[spellId] then
                total = total + addon.simpleCount[spellId]
            end
        end

        addon.sumItems[itemName] = total
    end
end

-- This function checks to see if a unit exists and is the player we're expecting it to be
function addon:UnitOK(unitId, playerName)
    if addon.mode == "CALENDAR" then
        return true
    end
    
    if unitId == 'player' then
        return true
    end
    
    if UnitExists(unitId) and (GetUnitName(unitId, true) == playerName) then
        if addon:InRaid() and UnitInRaid( select(1, UnitName(unitId)) ) then
            return true
        end
        
        if (not addon:InRaid()) and (addon:InParty()) then
            return true
        end
    end
    
    addon:PrDebug("UnitOK false for "..unitId.." ("..playerName..")")
    return false
end

-- This function checks each player and calls HandleCauses for their main spec and alt spec (if they have one)
-- It does the same for all fake player records and pets
function addon:CountSpellOccurences()
    local record, altrecord, override
    
    for unitId, playerName in pairs(addon.raidIds) do
        if addon:UnitOK(unitId, playerName) then
            if not addon:IsIgnored(playerName) then
                record = addon:GetRecord(playerName, addon.raidClass[playerName])
                altrecord = addon:GetAltRecord(playerName, addon.raidClass[playerName])
                _,_,override,_,_,_,_ = addon:GetPlayerBools(playerName)
                
                addon:HandleCauses(record, true)
                
                if altrecord and (not override) then
                    addon:HandleCauses(altrecord, false)
                end
            end
        end
    end

    -- Fakes
    for playerName,_ in pairs(addon.db.factionrealm.fakeDB) do
        record = addon.db.factionrealm.fakeDB[playerName]

        addon:HandleCauses(record, true)
    end
    
    -- Pets
    for petIndex,petObject in ipairs(addon.PETABILITIES) do
        local petOwners = addon:GetPetOwners(petObject.petType)
        
        for _,playerName in ipairs(petOwners) do
            addon:IncreaseSimpleCount(petObject.spellId, addon.FULL, true)
            addon:AddSpellProvider(petObject.spellId, playerName, true)
        end
        
        if addon:IsFakePetActive(petObject.petType) then
            addon:IncreaseSimpleCount(petObject.spellId, addon.FULL, true)
            addon:AddSpellProvider(petObject.spellId, format( L["format_fakename"], L[petObject.petType] ), true)
        end
    end
end

-- This function updates the simpleCount and spellProviders tables based on the player record passed to it
function addon:HandleCauses(record, isMainSpec)
    if not record then return end
    if not record.engClass then return end
    
    --[[
    if isMainSpec then
        addon:PrDebug("HandleCauses: "..record.playerName.." - "..record.engClass.."/"..record.specId)
    else
        addon:PrDebug("HandleCauses: "..record.playerName.." - "..record.engClass.."/"..record.specId.." (alt)")
    end
    ]]--

    local istank
    
    -- Cause because of Class
    for spellId, amount in pairs(addon.CAUSECLASS[record.engClass]) do
        addon:IncreaseSimpleCount(spellId, amount, isMainSpec)
        addon:AddSpellProvider(spellId, record.playerName, isMainSpec)
    end

    -- Cause because of Spec
    if addon.CAUSESPEC[record.engClass..record.specId] then
        for spellId, amount in pairs(addon.CAUSESPEC[record.engClass..record.specId]) do
            if spellId == record.engClass.." TANK" then istank = true end
            
            addon:IncreaseSimpleCount(spellId, amount, isMainSpec)
            addon:AddSpellProvider(spellId, record.playerName, isMainSpec)
        end
    end
    
    -- Cause because of Talents
    for spellId, _ in pairs(record.keyTalents) do
        if spellId == record.engClass.." TANK" then istank = true end
    
        local amount = addon.CAUSETALENT[record.engClass][spellId]
        addon:IncreaseSimpleCount(spellId, amount, isMainSpec)
        addon:AddSpellProvider(spellId, record.playerName, isMainSpec)
    end
    
    -- If the player is a Tank then remove them from the Melee DPS table
    if istank then
        addon:IncreaseSimpleCount(record.engClass.." MELEE", -addon.FULL, isMainSpec)
        addon:RemoveSpellProvider(record.engClass.." MELEE", record.playerName, isMainSpec)
    end
end

-- This function increases the simpleCount table
-- Note that the isMainSpec flag is currently unused, as the addon doesn't maintain a count for alt specs
function addon:IncreaseSimpleCount(spellId, amount, isMainSpec)
    if isMainSpec then
        if not addon.simpleCount[spellId] then
            addon.simpleCount[spellId] = amount
        else
            addon.simpleCount[spellId] = addon.simpleCount[spellId] + amount
        end
    end
end

-- This function adds a player to the list of spell providers
function addon:AddSpellProvider(spellId, playerName, isMainSpec)
    if isMainSpec then
        if not addon.spellProviders[spellId] then addon.spellProviders[spellId] = {} end

        addon.spellProviders[spellId][playerName] = true
    else
        -- If the player has this spell on their main spec then don't add it to the alt spec list as well
        -- Otherwise base spells like Mage's Remove Curse will have every Mage's name listed twice
        if addon.spellProviders[spellId] and addon.spellProviders[spellId][playerName] then return end
        
        if not addon.altSpellProviders[spellId] then addon.altSpellProviders[spellId] = {} end
        
        addon.altSpellProviders[spellId][playerName] = true
    end
end

-- This function removes a player from the list of spell providers
function addon:RemoveSpellProvider(spellId, playerName, isMainSpec)
    if isMainSpec then
        if addon.spellProviders[spellId] and addon.spellProviders[spellId][playerName] then
            addon.spellProviders[spellId][playerName] = false
        end
    else
        if addon.altSpellProviders[spellId] and addon.altSpellProviders[spellId][playerName] then
            addon.altSpellProviders[spellId][playerName] = false
        end
    end
end

-- This function returns a comma and space separated list of all providers of the specified spellId
-- It is used to add player names to spell tooltips
function addon:GetSpellProviders(spellId, isMainSpec)
    local playertext = nil

    if isMainSpec then
        if addon.spellProviders[spellId] then
            for playerName, isprovider in pairs(addon.spellProviders[spellId]) do
                if isprovider then
                    if not playertext then
                        playertext = playerName
                    else
                        playertext = playertext..", "..playerName
                    end
                end
            end
        end
    else
        if addon.altSpellProviders[spellId] then
            for playerName, isprovider in pairs(addon.altSpellProviders[spellId]) do
                if isprovider then
                    if not playertext then
                        playertext = playerName
                    else
                        playertext = playertext..", "..playerName
                    end
                end
            end
        end
    end
    
    return playertext
end

-- This function returns true if the specified spell is provided by the specified player
function addon:IsSpellProvider(spellId, playerName)
    if addon.spellProviders[spellId] and addon.spellProviders[spellId][playerName] then
        return true
    end
    
    return false
end

-- This function returns true if the specified buff category is provided by the specified player
function addon:IsItemProvider(itemName, playerName)
    for spellIndex, spellId in ipairs(addon.SPELLIDS[itemName]) do
        if addon:IsSpellProvider(spellId, playerName) then
            return true
        end
    end
    
    return false
end