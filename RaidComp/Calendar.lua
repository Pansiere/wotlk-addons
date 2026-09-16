local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)


-- This function returns a table of the invitees to the currently selected calendar event
function addon:GetEventInvitees()
    local players = { }
    
    for invitee = 1, CalendarEventGetNumInvites() do
        local name, level, className, classFilename, inviteStatus, modStatus = CalendarEventGetInvite(invitee)
        
        players["invitee"..invitee] = {
            playerName = name,
            engClass = classFilename,
            inviteStatus = inviteStatus,
          }
    end
    
    return players
end

-- This function returns the long or short description for an invite status code
function addon:GetInviteCode(inviteStatus, long)
    if inviteStatus == CALENDAR_INVITESTATUS_INVITED then
        return (long and L["longInvited"]) or L["shortInvited"]
    elseif inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED then
        return (long and L["longAccepted"]) or L["shortAccepted"]
    elseif inviteStatus == CALENDAR_INVITESTATUS_DECLINED then
        return (long and L["longDeclined"]) or L["shortDeclined"]
    elseif inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED then
        return (long and L["longConfirmed"]) or L["shortConfirmed"]
    elseif inviteStatus == CALENDAR_INVITESTATUS_OUT then
        return (long and L["longOut"]) or L["shortOut"]
    elseif inviteStatus == CALENDAR_INVITESTATUS_STANDBY then
        return (long and L["longStandby"]) or L["shortStandby"]
    elseif inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP then
        return (long and L["longSignedUp"]) or L["shortSignedUp"]
    elseif inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE then
        return (long and L["longTentative"]) or L["shortTentative"]
    else
        return (long and L["longNotSignedUp"]) or L["shortNotSignedUp"]
    end
end

-- This function returns a number which identifies the status of the player's invite
-- It is used by RefreshGUI to sort the player list, and ties invite statuses to the selection checkboxes
function addon:GetInviteCodeForSort(inviteStatus)
    if inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED then
        return 1
    elseif inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED then
        return 2
    elseif inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP then
        return 3
    elseif inviteStatus == CALENDAR_INVITESTATUS_INVITED then
        return 4
    elseif inviteStatus == CALENDAR_INVITESTATUS_STANDBY then
        return 5
    elseif inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE then
        return 6
    elseif inviteStatus == CALENDAR_INVITESTATUS_OUT then 
        return 7
    elseif inviteStatus == CALENDAR_INVITESTATUS_DECLINED then
        return 8
    else
        return 9
    end    
end

-- This function returns a description of the currently selected calendar event
-- It is used for the status bar text when a calendar event is selected
function addon:GetEventDesc()
    local title, description, creator, eventType, _, _, textureIndex, weekday, month, day, year, hour, minute, _, _, _, _, _, _, _, _, _, _, _, calendarType = CalendarGetEventInfo()
    
    if calendarType == "GUILD_EVENT" or calendarType == "PLAYER" then
        -- Get a localised list of all weekday names and find the one we want
        local weekdayNames = { CalendarGetWeekdayNames() }
        local dayString = weekdayNames[weekday]
        -- Get the date of the event in DD/MM/YY format
        local dateString = format("%02d/%02d", day, month).."/"..string.sub(year,-2)
        -- Get the time of the event in HH:MM format
        local timeString = format("%02d:%02d", hour, minute)
        
        return format( L["format_status_event"], dayString, dateString, timeString )
    elseif calendarType == "GUILD_ANNOUNCEMENT" then
        return format( L["format_status_announcement"], title )
    elseif calendarType == "SYSTEM" then
        return format( L["format_status_system"], title )
    else
        return L["status_noevent"]
    end
end

-- This function returns a list of information lines about the currently selected calendar event
-- This information will be shown as a tooltip for the status bar
function addon:GetEventInfo()
    local title, description, creator, eventType, _, _, textureIndex, weekday, month, day, year, hour, minute, _, _, _, _, _, _, _, _, _, _, _, calendarType = CalendarGetEventInfo()
    
    if calendarType == "GUILD_EVENT" or calendarType == "PLAYER" then
        -- Get a localised list of all possible event types (Raid, Dungeon, PvP, etc) and find the one for this event
        local eventTypes = { CalendarEventGetTypes() }
        local eventName = eventTypes[eventType]
        -- If event is a raid or dungeon
        if eventType < 3 then
            -- Get a localised list of all possible raids and dungeons (Ulduar, Onyxia's Lair, The Nexus, etc) and add it to the string
            local eventTextures = { CalendarEventGetTextures(eventType) }
            eventName = eventName.." - "..eventTextures[(textureIndex * 3) - 2]
        end
        
        local createdBy = format( L["format_createdby"], creator )
        
        -- Get localised lists of all weekdays and months
        local weekdayNames = { CalendarGetWeekdayNames() }
        local monthNames = { CalendarGetMonthNames() }
        -- Get the date of the event in "Day, Month DD YYYY" format
        local dateString = weekdayNames[weekday]..", "..monthNames[month].." "..day.." "..year
        
        -- Get the time of the event in HH:MM format
        local timeString = format("%02d:%02d", hour, minute)
        
        return { title,
            eventName,
            createdBy,
            dateString,
            timeString,
            description,
          }
    elseif calendarType == "GUILD_ANNOUNCEMENT" then
        return nil
    elseif calendarType == "SYSTEM" then
        return nil
    else
        return nil
    end
end