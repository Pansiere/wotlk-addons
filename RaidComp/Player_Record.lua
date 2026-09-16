local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)


-- This functions retrieves the active record for the specified player
-- If the player's data is being overridden it will return the override data instead
function addon:GetRecord(playerName, engClass)
    local record
    
    -- Override
    if addon.db.factionrealm.overrideDB[playerName] and addon.db.factionrealm.customDB[playerName] then
        record = addon.db.factionrealm.customDB[playerName]
        
    -- Cross-realm OK/Stored
    elseif addon.xrealmRaidDB[playerName] then
        record = addon.xrealmRaidDB[playerName]
        
    -- OK/Stored
    elseif addon.db.factionrealm.raidDB[playerName] then
        record = addon.db.factionrealm.raidDB[playerName]
        
    -- Temp
    elseif addon.db.factionrealm.customDB[playerName] then
        record = addon.db.factionrealm.customDB[playerName]
        
    -- Fake
    elseif addon.db.factionrealm.fakeDB[playerName] then
        record = addon.db.factionrealm.fakeDB[playerName]
        
    -- Missing
    else
        record = {
            playerName = playerName,
            engClass = engClass,
            specId = addon.IDUNKNOWN,
            specPoints = addon.POINTSUNKNOWN,
            keyTalents = { },
            updateTime = time(),
        }
    end
    
    return record
end

-- This function retrieves the player's alt spec record, returns nil if it doesn't exist
function addon:GetAltRecord(playerName, engClass)
    local record
    
    -- Cross-realm OK/Stored
    if addon.xrealmAltDB[playerName] then
        record = addon.xrealmAltDB[playerName]
        
    -- OK/Stored
    elseif addon.db.factionrealm.altDB[playerName] then
        record = addon.db.factionrealm.altDB[playerName]   
    end
    
    return record
end

function addon:PrintRecord(record)
    addon:Print(record.playerName)
    addon:Print(record.engClass)
    addon:Print("specId: "..record.specId)
    addon:Print("specPoint: "..record.specPoints)
end

-- This function returns the the long or short code for the status of the player's record
function addon:GetPlayerCode(playerName, long)
    local fake,ignore,override,ok,stored,temp,missing = addon:GetPlayerBools(playerName)

    if fake then
        return (long and L["longF"]) or L["shortF"]
    elseif ignore then
        return (long and L["longI"]) or L["shortI"]
    elseif override then
        return (long and L["longO"]) or L["shortO"]
    elseif ok then 
        return (long and L["longK"]) or L["shortK"]
    elseif stored then
        return (long and L["longS"]) or L["shortS"]
    elseif temp then
        return (long and L["longT"]) or L["shortT"]
    else
        return (long and L["longM"]) or L["shortM"]
    end    
end

-- This function returns a number which identifies the status of the player's record
-- It is used by RefreshGUI to sort the player list
function addon:GetPlayerCodeForSort(playerName)
    local fake, ignore, override, ok, stored, temp, missing = addon:GetPlayerBools(playerName)
    
    if fake then
        return 7
    elseif ignore then
        return 1
    elseif override then
        return 2
    elseif ok then 
        return 3
    elseif stored then
        return 4
    elseif temp then
        return 5
    else
        return 6
    end    
end

-- This function returns boolean values indicating the status of the player's record
function addon:GetPlayerBools(playerName)
    local fake,ignore,override,ok,stored,temp,missing = false, false, false, false, false, false, false
    
    if addon.db.factionrealm.fakeDB[playerName] then
        fake = true
    end
    
    if addon.db.factionrealm.ignoreDB[playerName] then
        ignore = true
    end
    
    if addon.db.factionrealm.customDB[playerName] then
        temp = true
        
        if addon.db.factionrealm.overrideDB[playerName] then
            override = true
        end
    end
    
    local record = addon.db.factionrealm.raidDB[playerName] or addon.xrealmRaidDB[playerName]
    if record then       
        stored = true
       
        if time() - record.updateTime < (15 * 60) then
            ok = true
        end

        if record.specId == addon.IDUNKNOWN then
            stored = false
            missing = true
        end
    else
        missing = true
    end

    return fake, ignore, override, ok, stored, temp, missing
end


-- =================================
-- Custom Data
-- =================================
function addon:AddOverride(playerName, engClass_presetName, record)
    addon:AddCustom(playerName, engClass_presetName, record)
    addon.db.factionrealm.overrideDB[playerName] = true
end

function addon:RemoveOverride(playerName)
    addon:RemoveCustom(playerName)
    addon.db.factionrealm.overrideDB[playerName] = nil
end

function addon:CountOverrides()
    local count = 0
    
    for _ in pairs(addon.db.factionrealm.overrideDB) do
        count = count + 1
    end
    
    return count
end

function addon:RemoveAllOverrides()
    for playerName,flag in pairs(addon.db.factionrealm.overrideDB) do
        if flag then
            addon:RemoveCustom(playerName)
        end
    end
    
    addon.db.factionrealm.overrideDB = wipe(addon.db.factionrealm.overrideDB)
end

function addon:AddTemporary(playerName, engClass_presetName)
    addon:AddCustom(playerName, engClass_presetName, nil)
end

function addon:RemoveTemporary(playerName)
    addon:RemoveCustom(playerName)
end

-- This function adds a custom record for the specified player to the database
-- This will either be a custom override based on a class/spec preset, or the player's alt spec record
function addon:AddCustom(playerName, engClass_presetName, record)
    local engClass, presetName, specId, specPoints
    local keyTalents = { }

    if engClass_presetName then
        -- Setting the Override as a preset, so find the preset data
        engClass, presetName = strsplit(":", engClass_presetName)
        specId = addon.IDUNKNOWN
        specPoints = addon.POINTSFAKE

        for index, presetObject in ipairs(addon.PRESETS[engClass]) do
            if presetObject.presetName == presetName then
                specId = presetObject.specId
                keyTalents = presetObject.keyTalents
            end
        end
    elseif record then
        -- Setting the Override as the player's alt spec, so retrieve the record
        engClass = record.engClass
        specId = record.specId
        specPoints = record.specPoints
        keyTalents = record.keyTalents
    else
        return
    end

    if addon.db.factionrealm.customDB[playerName] then
        -- Alter the existing record
        addon.db.factionrealm.customDB[playerName].engClass = engClass
        addon.db.factionrealm.customDB[playerName].specId = specId
        addon.db.factionrealm.customDB[playerName].specPoints = specPoints
        addon.db.factionrealm.customDB[playerName].keyTalents = keyTalents
        addon.db.factionrealm.customDB[playerName].updateTime = time()
    else
        -- Build the record
        addon.db.factionrealm.customDB[playerName] = {
            playerName = playerName,
            engClass = engClass,
            specId = specId,
            specPoints = specPoints,
            keyTalents = keyTalents,
            updateTime = time(),
          }
    end
end

function addon:RemoveCustom(playerName)
    addon.db.factionrealm.customDB[playerName] = nil
end


-- =================================
-- Ignore
-- =================================
function addon:AddIgnore(playerName)
    addon.db.factionrealm.ignoreDB[playerName] = true
end

function addon:RemoveIgnore(playerName)
    addon.db.factionrealm.ignoreDB[playerName] = nil
end

function addon:IsIgnored(playerName)
    return addon.db.factionrealm.ignoreDB[playerName]
end

function addon:CountIgnores()
    local count = 0
    
    for _ in pairs(addon.db.factionrealm.ignoreDB) do
        count = count + 1
    end
    
    return count
end

-- This function updates the ignore list based on the state of the selection checkboxes
-- It is called after BuildRoster() during a raid check
function addon:UpdateIgnores()
    for playerName,subgroup in pairs(addon.raidSubGroup) do
        if addon.mode == "RAID" then
            flag = addon.wtGroupCheckboxes[ subgroup ]:GetValue()
        elseif addon.mode == "CALENDAR" then
            flag = addon.wtGroupCheckboxes[ addon:GetInviteCodeForSort(subgroup) ]:GetValue()
        end
        
        if flag == true then
            if addon:IsIgnored(playerName) then addon:RemoveIgnore(playerName) end
        elseif flag == false then
            if not addon:IsIgnored(playerName) then addon:AddIgnore(playerName) end
        end
    end
end

function addon:RemoveAllIgnores()
    addon.db.factionrealm.ignoreDB = wipe(addon.db.factionrealm.ignoreDB)
end
