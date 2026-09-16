local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)


-- This function adds a new fake player of the specified class and spec to the raid and returns the name generated
-- The talents for fake players are based on presets configured in Const_Presets.lua
function addon:AddFake(engClass_presetName)
    local engClass, presetName = strsplit(":", engClass_presetName)
    
    -- Find the preset
    local specId = addon.IDUNKNOWN
    local keyTalents = { }
    for index,presetObject in ipairs(addon.PRESETS[engClass]) do
        if presetObject.presetName == presetName then
            specId = presetObject.specId
            keyTalents = presetObject.keyTalents
        end
    end

    -- Generate a new playerName
    local playerName = format( L["format_fakename"], addon:GetNewFakeID() )
    
    -- Build the record
    addon.db.factionrealm.fakeDB[playerName] = {
        playerName = playerName,
        engClass = engClass,
        specId = specId,
        specPoints = addon.POINTSFAKE,
        keyTalents = keyTalents,
        updateTime = time(),
      }
      
    return playerName
end

-- This function adds a new fake player based on a record from the database
function addon:AddAsFake(playerName, isMainSpec)
    local fakeName = format( L["format_fakename"], playerName )
    
    if addon.db.factionrealm.fakeDB[fakeName] then return end
    
    local record
    if isMainSpec then
        record = addon:GetRecord(playerName)
    else
        record = addon:GetAltRecord(playerName)
    end
    
    if not record then return end
    
    -- Build the record
    addon.db.factionrealm.fakeDB[fakeName] = {
        playerName = fakeName,
        engClass = record.engClass,
        specId = record.specId,
        specPoints = record.specPoints,
        keyTalents = record.keyTalents,
        updateTime = record.updateTime,
      }
end

function addon:IsFake(playerName)
    return addon.db.factionrealm.fakeDB[playerName]
end

-- This generates a new fake ID number
function addon:GetNewFakeID()
    local fakeNextID = addon.db.factionrealm.fakeNextID
    
    if (not fakeNextID) then fakeNextID = 0 end
    
    addon.db.factionrealm.fakeNextID = fakeNextID + 1
    
    return fakeNextID
end

-- This removes the specified fake player from the database
-- If there are no fake players left in the DB then call RemoveAllFakes to wipe it clean and reset the fake ID
function addon:RemoveFake(playerName)
    addon.db.factionrealm.fakeDB[playerName] = nil
    
    if addon:CountFakes() == 0 then
        addon:RemoveAllFakes()
    end
end

-- This function returns the number of fake players in the database
function addon:CountFakes()
    local count = 0
    
    for _ in pairs(addon.db.factionrealm.fakeDB) do
        count = count + 1
    end
    
    return count
end

-- This removes all fake players from the database and resets the next fake ID to 1
function addon:RemoveAllFakes()
    addon.db.factionrealm.fakeDB = wipe(addon.db.factionrealm.fakeDB)
    addon.db.factionrealm.fakeNextID = 1
end


-- =================================
-- Fake Pet functions
-- =================================
function addon:IsFakePetActive(petType)
    return addon.db.factionrealm.petDB[petType]
end

function addon:ToggleFakePet(petType) 
    if addon.db.factionrealm.petDB[petType] then
        addon.db.factionrealm.petDB[petType] = nil
    else
        addon.db.factionrealm.petDB[petType] = true
    end
end
