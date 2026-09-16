local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)


-- This function determines whether we are in a raid or not
function addon:InRaid()
    return GetNumRaidMembers() > 0
end

-- This function determines whether we are in a party or not
function addon:InParty()
    return GetNumPartyMembers() > 0
end

-- This function prints a debug message to the chat window
function addon:PrDebug(message)
    if addon.db.profile.debug then
        addon:Print(LIGHTYELLOW_FONT_COLOR_CODE..message)
    end
end

-- This function prints and error to the chat window
function addon:PrError(message)
    addon:Print(RED_FONT_COLOR_CODE..message)
end

-- This function takes a string and encloses it with colour codes based on a specified class
-- It is used for adding class, spell and players names to tooltips in the class colour
function addon:EncapsColor(str, englishClass)
    if not str then return nil end

    local color = GRAY_FONT_COLOR_CODE
    
    if englishClass == "DEATHKNIGHT" then
        color = "|cffc41f3b"
    elseif englishClass == "DRUID" then
        color = "|cffff7d0a"
    elseif englishClass == "HUNTER" then
        color = "|cffabd473"
    elseif englishClass == "MAGE" then
        color = "|cff69ccf0"
    elseif englishClass == "PALADIN" then
        color = "|cfff58cba"
    elseif englishClass == "PRIEST" then
        color = "|cffffffff"
    elseif englishClass == "ROGUE" then
        color = "|cfffff569"
    elseif englishClass == "SHAMAN" then
        color = "|cff2459ff"
    elseif englishClass == "WARLOCK" then
        color = "|cff9482c9"
    elseif englishClass == "WARRIOR" then
        color = "|cffc79c6e"
    end
    
    return addon:ColorCode(color, str)
end

-- This function takes a path to an icon and returns a string with the escape codes for an embedded texture
-- It is used for adding icons to tooltips
function addon:EmbedTex(path, width, height)
    if width then
        width = ":"..width
    else
        width = ""
    end
    if height then
        height = ":"..height
    else
        height = ""
    end
    
    return "\124T" .. path .. width .. height .. "\124t"
end

-- This function returns the localised spec name based on a particular class and talent tree id
-- For example, ("PALADIN", 1) returns "Holy Paladin", ("PALADIN", 2) returns "Protection Paladin"
function addon:GetSpecName(engClass, specId)
    if specId == addon.IDHYBRID then
        return L["HYBRID"]
    elseif specId == addon.IDFAKE then
        return L["FAKE"]
    elseif specId == addon.IDUNKNOWN then
        return L["UNKNOWN"]
    else
        return L[engClass..specId]
    end
end

-- This function returns an icon based on a particular class and talent tree id
-- Note:  This is currently unused, icons are defined in Const_Presets.lua for each class and spec
function addon:GetSpecIcon(engClass, specId)
    if specId == addon.IDHYBRID then
        return addon.TEXHYBRID
    elseif specId == addon.IDFAKE then
        return addon.TEXFAKE
    elseif specId == addon.IDUNKNOWN then
        return addon.TEXUNKNOWN
    else
        return addon.TALENTTREEICONS[engClass][specId]
    end
end

-- This function calculates the difference between the current time and the specified time
-- It returns it in a localised and readable way (i.e "30 mins ago")
function addon:TimeDifference(updateTime)
    local seconds = time() - updateTime
    
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    
    local hours = math.floor(minutes / 60)
    minutes = minutes % 60
    
    local days = math.floor(hours / 24)
    hours = hours % 24
    
    local weeks = math.floor(days / 7)
    days = days % 7

    if weeks >= 1 then
        return weeks.." "..L["time_weeks"]
    elseif days >= 1 then
        return days.." "..L["time_days"]
    elseif hours >= 1 then
        return hours.." "..L["time_hours"]
    elseif minutes >= 1 then
        return minutes.." "..L["time_minutes"]
    else
        return seconds.." "..L["time_seconds"]
    end    
end


--[[
function addon:PrintTable(table, indent)
    if not indent then indent = "" end
    for key,value in pairs(table) do
        if type(key) ~= "table" then
            if not value then
                addon:Print(indent..key .. ": nil")
            elseif type(value) == "table" then
                addon:Print(indent..key .. ": table:")
                addon:PrintTable(value, indent.."  ")
            elseif type(value) == "userdata" then
                addon:Print(indent..key .. ": userdata")
            elseif type(value) == "function" then
                addon:Print(indent..key .. ": function")
            else
                addon:Print(indent..key .. ": ".. value)
            end
        else
            addon:Print(indent.."key is table:")
        end
    end
end
--]]
