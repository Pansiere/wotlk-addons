local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)

local LibQT  = LibStub("LibQTip-1.0")

local buffitemclickopened = false
addon.sortRaidType = "playerName"
addon.sortRaidDesc = false
addon.sortDatabaseType = "playerName"
addon.sortDatabaseDesc = false

local LIGHTGRAY_COLOR_CODE = "|cff999999"


-- Called when the main GUI window is closed
function addon:Frame_OnClose(widget)
    -- Release the tooltips
    addon:ReleaseTooltips()
end

-- This function takes a message supplied by GetBuffReport() and outputs it to an appropriate channel
function addon:DisplayReport(message)
    local chatType = "SAY"
    
    if addon:InRaid() then
        chatType = "RAID"
    elseif addon:InParty() then
        chatType = "PARTY"
    end
    
    for _, line in ipairs(message) do
        -- Chat messages can't be longer than 255 chars
        if strlen(line) > 255 then
            line = strsub(line, 1, 255)
        end
        
        SendChatMessage(line, chatType)
    end
end

-- =================================
-- Spells
-- =================================

-- Called when the mouse is moved over a spell in a buff tooltip
local function Spell_OnEnter(cell, arg, button)
    if not arg then return end
    
    local itemName, spellId = strsplit(":", arg)
    spellId = tonumber(spellId)
    
    if not addon.SPELLCLASS[itemName][spellId] then return end
    
    -- Create a GameTooltip using the spellId
    GameTooltip:SetOwner(addon.wtItemLabels[itemName].frame, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", addon.buffitemtooltip, "TOPLEFT")
    GameTooltip:SetHyperlink("spell:"..spellId)
    
    local engClass = addon.SPELLCLASS[itemName][spellId]
    local c = RAID_CLASS_COLORS[engClass]
    
    -- Add a blank line to the bottom of the tooltip
    GameTooltip:AddLine(" ")
    
    -- Add the class that can cast this spell to the tooltip.  If the spell is a talent, add (Talent) to the end of the line
    -- Note that we don't list the talent tree because it may not correspond to the same spec
    -- e.g. Improved Shadow Bolt is a Destruction talent, but is never taken by Destruction Warlocks
    local classtext = nil
    if addon.TALENTLOC[engClass][spellId] then
        classtext = format( L["format_providedbytalent"], L[engClass] )
    else
        classtext = format( L["format_providedby"], L[engClass] )
    end
    GameTooltip:AddLine(classtext, c.r, c.g, c.b)
    
    -- Add the names of players who can cast this spell to the tooltip
    local playertext = addon:GetSpellProviders(spellId, true)
    if playertext then
        GameTooltip:AddLine(playertext, c.r, c.g, c.b, 1)
    end
    
    -- Add the names of players who can cast this spell on their alt spec to the tooltip in grey
    playertext = addon:GetSpellProviders(spellId, false)
    if playertext then
        GameTooltip:AddLine(playertext, 0.5, 0.5, 0.5, 1)
    end
    
    -- Resize and show the tooltip
    GameTooltip:Show()
end

-- Called when the mouse is moved away from a spell in a buff tooltip
local function Spell_OnLeave(cell, arg, button)
    GameTooltip:Hide()
end

-- Called when a spell is clicked in a buff tooltip (not currently used)
local function Spell_OnClick(cell, arg, button)
--    addon:ReleaseTooltip_BuffItem()

--    GameTooltip:Hide()
end


-- =================================
-- Buff Item
-- =================================

-- Called when the mouse is moved over a buff in the main GUI
function addon:BuffItem_OnEnter(widget)
    if addon.buffitemtooltip and addon.buffitemtooltip:IsVisible() then return end

    addon:ReleaseTooltip_BuffItem( addon:Tooltip_AnyClickableVisible() )
    
    buffitemclickopened = false
    
    local tooltip = addon:Tooltip_BuffItem(widget)
    
    addon:MyAnchorTo(tooltip, widget.frame, -2, 4)
    tooltip:Show()
end

-- Called when the mouse is moved away from a buff in the main GUI
function addon:BuffItem_OnLeave(widget)
    if buffitemclickopened then return end
    
    addon:ReleaseTooltip_BuffItem(true)
end

-- Called when a buff is clicked in the main GUI
function addon:BuffItem_OnClick(widget, button)
    if button == "LeftButton" then
        local same = widget == addon.buffitemwidget
        
        -- Release any open tooltips
        addon:ReleaseTooltips()

        -- If the buff that was clicked was the one that was already open then we're done
        if buffitemclickopened then
            buffitemclickopened = false
            if same then return end
        end

        -- Otherwise, create a new tooltip for the buff that's been clicked and show it
        local tooltip = addon:Tooltip_BuffItem(widget)
        
        addon:Tooltip_AddCloseX(tooltip)
        addon:MyAnchorTo(tooltip, widget.frame, -2, 4)
        tooltip:Show()
        
        buffitemclickopened = true
    elseif button == "RightButton" then
        addon:DisplayReport( addon:GetBuffReport(widget) )
    end
end

-- This function returns a message that details the providers of a particular buff
function addon:GetBuffReport(widget)
    local itemName = widget:GetUserData("itemName")
    local itemType = widget:GetUserData("itemType")
    if not addon.SPELLIDS[itemName] then return end
    
    local outputLines = { }
    
    -- Create a header line with the name of the buff
    local newline = format( L["format_report_sourcesof"], itemName )
    
    local count = addon:GetSumItems(itemName)
    
    -- If this is a COUNT type add the count at the end of the line
    if itemType == addon.ITEMTYPE_COUNT then
        count = count/addon.FULL
        newline = newline .. " (" .. count .. ")"
    end
    
    tinsert( outputLines, newline )
    
    -- If this buff isn't being provided then return just the header and a line saying "None"
    if count == 0 then
        tinsert( outputLines, L["report_none"] )
        return outputLines
    end
    
    -- For each potential source of the buff
    for spellIndex, spellId in ipairs(addon.SPELLIDS[itemName]) do
        -- Find out if anyone can provide this spell
        local playertext = addon:GetSpellProviders(spellId, true)

        if playertext then
            -- Add a line for the spell which causes it
            local engClass = addon.SPELLCLASS[itemName][spellId]
            local spellName, spellRank, spellIcon = GetSpellInfo(spellId)
           
            local newline

            if addon.ISPETABILITY[spellId] then
                newline = format( L["format_report_petability"], spellName, L[engClass], playertext )
            else
                newline = format( L["format_report_spell"], spellName, L[engClass], playertext )
            end
            
            -- If this is a COUNT type add the count at the end of the line
            if itemType == addon.ITEMTYPE_COUNT then
                local count = addon:GetSimpleCount(spellId)
                newline = newline .. " (" .. count/addon.FULL .. ")"
            end
            
            tinsert( outputLines, newline..":" )
            
            -- Find out of the spell can be improved by talents
            local spellImprove = addon.IMPROVEDBY[spellId]
            local exception = false
            
            if addon.IMPROVEDBY_EXCEPTION[itemName] and addon.IMPROVEDBY_EXCEPTION[itemName][spellId] then
                exception = true
            end
            
            -- If it can be improved, add an extra line for the improved version of the spell
            if spellImprove and not exception then
                local playertext = addon:GetSpellProviders(spellImprove, true)
                
                if playertext then 
                    local spellName, spellRank, spellIcon = GetSpellInfo(spellImprove)

                    local newline = "   " .. format( L["format_report_spell"], spellName, L[engClass], playertext )

                    if itemType == addon.ITEMTYPE_COUNT then
                        local count = addon:GetSimpleCount(spellImprove)
                        newline = newline .. " (" .. count/addon.FULL .. ")"
                    end
                    
                    tinsert( outputLines, newline )
                end
            end
        end
    end
    
    return outputLines
end

-- Create the tooltip for a buff, listing all possible sources
function addon:Tooltip_BuffItem(widget)
    local itemName = widget:GetUserData("itemName")
    local itemType = widget:GetUserData("itemType")
    if not addon.SPELLIDS[itemName] then return end

    local tooltip = LibQT:Acquire("RCTooltip_BuffItem", 3, "LEFT", "LEFT", "RIGHT")
    addon.buffitemtooltip = tooltip 
    addon.buffitemwidget = widget
    addon:Tooltip_SetColor(tooltip)
    
    -- Create a header naming the buff, along with an icon or count
    local headerIcon = addon:ItemType2Texture(addon.ITEMTYPE[itemName])
    local thirdcol = ""
    if itemType ~= addon.ITEMTYPE_COUNT then
        local presenceIcon = addon:SumItems2PresenceIcon(itemName)
        thirdcol = addon:EmbedTex(presenceIcon, 12)
    else
        local count = addon:GetSumItems(itemName)
        thirdcol = addon:ColorCodeCount(count/addon.FULL)
    end
        
    tooltip:AddHeader(addon:EmbedTex(headerIcon, 24), addon:ColorCode(NORMAL_FONT_COLOR_CODE, itemName), "  "..thirdcol)
    tooltip:AddLine( " " )
    
    -- For each potential source of the buff
    for spellIndex, spellId in ipairs(addon.SPELLIDS[itemName]) do
        -- Add a line for the spell which causes it
        local engClass = addon.SPELLCLASS[itemName][spellId]
        local spellName, spellRank, spellIcon = GetSpellInfo(spellId)
       
        local secondcol = addon:EncapsColor(spellName, engClass)
        if addon.ISPETABILITY[spellId] then
            secondcol = secondcol .. " " .. L["tooltip_petability"]
        end
        
        local thirdcol = ""
        
        -- If this is a COUNT type third col should be the count, otherwise it should be a presence icon
        if itemType ~= addon.ITEMTYPE_COUNT then
            local presenceIcon = addon:SimpleCount2PresenceIcon(itemName, spellId)
            thirdcol = addon:EmbedTex(presenceIcon, 12)
        else       
            local count = addon:GetSimpleCount(spellId)
            thirdcol = addon:ColorCodeCount(count/addon.FULL)
        end

        local y, x = tooltip:AddLine()
        y, x = tooltip:SetCell(y, 1, addon:EmbedTex(spellIcon, 24))
        y, x = tooltip:SetCell(y, 2, secondcol)
        y, x = tooltip:SetCell(y, 3, thirdcol)
    
        -- Assign the callback to the tooltip
        tooltip:SetLineScript(y, "OnEnter", Spell_OnEnter, itemName..":"..spellId)
        tooltip:SetLineScript(y, "OnLeave", Spell_OnLeave, itemName..":"..spellId)
        --tooltip:SetCallback(y, "OnMouseDown", Spell_OnClick, itemName..":"..spellId)

        -- Find out of the spell can be improved by talents
        local spellImprove = addon.IMPROVEDBY[spellId]
        local exception = false
        
        if addon.IMPROVEDBY_EXCEPTION[itemName] and addon.IMPROVEDBY_EXCEPTION[itemName][spellId] then
            exception = true
        end
        
        -- If it can be improved, add an extra line for the improved version of the spell
        if spellImprove and not exception then
            local spellName, spellRank, spellIcon = GetSpellInfo(spellImprove)

            local thirdcol = ""
            if itemType ~= addon.ITEMTYPE_COUNT then
                local presenceIcon = addon:SimpleCount2PresenceIcon(itemName, spellImprove)
                thirdcol = addon:EmbedTex(presenceIcon, 12)
            end

            local y, x = tooltip:AddLine()
            y, x = tooltip:SetCell(y, 1, "  "..addon:EmbedTex(spellIcon, 24))
            y, x = tooltip:SetCell(y, 2, "  "..addon:ColorCode(LIGHTGRAY_COLOR_CODE, "( ")..addon:EncapsColor(spellName, engClass)..addon:ColorCode(LIGHTGRAY_COLOR_CODE, " )"))
            y, x = tooltip:SetCell(y, 3, thirdcol)

            -- Assign the callback to the tooltip
            tooltip:SetLineScript(y, "OnEnter", Spell_OnEnter, itemName..":"..spellImprove)
            tooltip:SetLineScript(y, "OnLeave", Spell_OnLeave, itemName..":"..spellImprove)
            --tooltip:SetCallback(y, "OnMouseDown", Spell_OnClick, itemName..":"..spellImprove)
        end
    end
    
    return tooltip
end

-- =================================
-- Spec Item
-- =================================

-- Called when the mouse is moved over a spec in the main GUI
function addon:SpecItem_OnEnter(widget)
    if addon.buffitemtooltip and addon.buffitemtooltip:IsVisible() then return end

    addon:ReleaseTooltip_BuffItem( addon:Tooltip_AnyClickableVisible() )
    
    buffitemclickopened = false
    
    local tooltip = addon:Tooltip_SpecItem(widget)
    
    addon:MyAnchorTo(tooltip, widget.frame, -2, 4)
    tooltip:Show()
end

-- Called when the mouse is moved away from a spec in the main GUI
function addon:SpecItem_OnLeave(widget)
    if buffitemclickopened then return end
    
    addon:ReleaseTooltip_BuffItem(true)
end

-- Called when a spec is clicked in the main GUI
function addon:SpecItem_OnClick(widget, button)
    if button == "LeftButton" then
        local same = widget == addon.buffitemwidget
        
        -- Release any open tooltips
        addon:ReleaseTooltips()

        -- If the spec that was clicked was the one that was already open then we're done
        if buffitemclickopened then
            buffitemclickopened = false
            if same then return end
        end

        -- Otherwise, create a new tooltip for the spec that's been clicked and show it
        local tooltip = addon:Tooltip_SpecItem(widget)
        
        addon:Tooltip_AddCloseX(tooltip)
        addon:MyAnchorTo(tooltip, widget.frame, -2, 4)
        tooltip:Show()
        
        buffitemclickopened = true
    elseif button == "RightButton" then
        addon:DisplayReport( addon:GetSpecReport(widget) )
    end
end

-- This function returns a message that details the group members of a particular spec type
function addon:GetSpecReport(widget)
    local itemName = widget:GetUserData("itemName")
    local itemType = widget:GetUserData("itemType")
    if not addon.SPELLIDS[itemName] then return end
    
    local outputLines = { }
    
    -- Create a header line with the name of the spec
    local newline = format( L["format_report_specs"], itemName )
    
    -- Add the count at the end of the line
    local count = addon:GetSumItems(itemName)
    count = count/addon.FULL
    newline = newline .. " (" .. count .. ")"
    
    tinsert( outputLines, newline..":" )
    
    -- If this spec isn't present then return just the header and a line saying "None"
    if count == 0 then
        tinsert( outputLines, L["report_none"] )
        return outputLines
    end
    
    -- For each potential class of that spec
    for spellIndex, spellId in ipairs(addon.SPELLIDS[itemName]) do
        -- Find out if anyone of that class has this spec
        local playertext = addon:GetSpellProviders(spellId, true)

        if playertext then
            -- Add a line for the spell which causes it
            local engClass = addon.SPELLCLASS[itemName][spellId]
           
            newline = format( L["format_report_spec"], L[engClass], playertext )
            
            -- Add the count at the end of the line
            local count = addon:GetSimpleCount(spellId)
            newline = newline .. " (" .. count/addon.FULL .. ")"
            
            tinsert( outputLines, newline )
        end
    end
    
    return outputLines
end

-- Create the tooltip for a spec, listing all possible classes
function addon:Tooltip_SpecItem(widget)
    local itemName = widget:GetUserData("itemName")
    local itemType = widget:GetUserData("itemType")
    if not addon.SPELLIDS[itemName] then return end

    local tooltip = LibQT:Acquire("RCTooltip_BuffItem", 3, "LEFT", "LEFT", "RIGHT")
    addon.buffitemtooltip = tooltip 
    addon.buffitemwidget = widget
    addon:Tooltip_SetColor(tooltip)
    
    -- Create a header naming the spec, along with the count
    local headerIcon = addon:ItemType2Texture(addon.ITEMTYPE[itemName])
    local thirdcol = ""
    local count = addon:GetSumItems(itemName)
    thirdcol = addon:ColorCodeCount(count/addon.FULL)
        
    tooltip:AddHeader(addon:EmbedTex(headerIcon, 24), addon:ColorCode(NORMAL_FONT_COLOR_CODE, itemName), "  "..thirdcol)
    tooltip:AddLine( " " )
    
    -- For each potential class of that spec
    for spellIndex, spellId in ipairs(addon.SPELLIDS[itemName]) do
        -- Add a line for the class with the icon, class name and count
        local engClass = addon.SPELLCLASS[itemName][spellId]
        
        local spellIcon = addon.SPECICONS[engClass]
        
        local secondcol = addon:EncapsColor(L[engClass], engClass)
        
        local thirdcol = ""
        local count = addon:GetSimpleCount(spellId)
        thirdcol = addon:ColorCodeCount(count/addon.FULL)

        local y, x = tooltip:AddLine()
        y, x = tooltip:SetCell(y, 1, addon:EmbedTex(spellIcon, 24))
        y, x = tooltip:SetCell(y, 2, secondcol)
        y, x = tooltip:SetCell(y, 3, thirdcol)
        
        -- Add the names of the players of this spec to the tooltip
        local playertext = addon:GetSpellProviders(spellId, true)
        if playertext then
            y, x = tooltip:AddLine()
            -- Make this line span columns 2 and 3 and let it wrap text
            y, x = tooltip:SetCell(y, 2, addon:EncapsColor(playertext, engClass), nil, nil, 2, nil, nil, nil, 175, 125)
        end
        
        -- Add the names of players with this spec as their alt spec to the tooltip in grey
        playertext = addon:GetSpellProviders(spellId, false)
        if playertext then
            y, x = tooltip:AddLine()
            -- Make this line span columns 2 and 3 and let it wrap text
            y, x = tooltip:SetCell(y, 2, addon:ColorCode(GRAY_FONT_COLOR_CODE, playertext), nil, nil, 2, nil, nil, nil, 175, 125)
        end
    end
    
    return tooltip
end


-- =================================
-- Player
-- =================================

-- Called when the mouse is moved over a player in the main GUI
function addon:Player_OnEnter(widget)
    if addon.customdatatooltip and addon.customdatatooltip:IsShown() then return end
    
    local playerName = widget:GetUserData("playerName")
    local engClass = widget:GetUserData("engClass")
    
    local record = addon:GetRecord(playerName, engClass)
    local altrecord = addon:GetAltRecord(playerName, engClass)
    
    local fake,ignore,override,ok,stored,temp,missing = addon:GetPlayerBools(playerName)
    
    -- Release any current player tooltips and get a new one
    addon:ReleaseTooltip_Player()
    
    local tooltip = LibQT:Acquire("RCTooltip_Player", 2, "RIGHT", "LEFT")
    addon.playertooltip = tooltip 
    addon:Tooltip_SetColor(tooltip)
    
    -- Add line showing the playername and the status of their talent scan data
    local y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, addon:EncapsColor( playerName, record.engClass ), nil, "LEFT" )
    tooltip:SetCell( y, 2, addon:GetPlayerCode(playerName, true) )
    
    -- If we're viewing a calendar event, add a line showing the status of their invite
    if addon.mode == "CALENDAR" and addon.raidSubGroup[playerName] then
        local y, x = tooltip:AddLine()
        tooltip:SetCell( y, 2, addon:GetInviteCode(addon.raidSubGroup[playerName], true) )
    end
    
    -- Add line showing their spec and alt spec (if they have one)
    tooltip:AddLine( addon:GetSpecName(record.engClass, record.specId), record.specPoints )
    if altrecord and (not override) then
        tooltip:AddLine( addon:ColorCode(LIGHTGRAY_COLOR_CODE, addon:GetSpecName(altrecord.engClass, altrecord.specId)), addon:ColorCode(LIGHTGRAY_COLOR_CODE, altrecord.specPoints) )
    end
    
    -- Add line showing time of last talent scan
    y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, addon:ColorCode(LIGHTGRAY_COLOR_CODE, format( L["format_timetooltip"], addon:TimeDifference(record.updateTime) )) , nil, "CENTER", 2 )
    
    -- Add lines to show available options for this player
    local keycolor, actioncolor = GRAY_FONT_COLOR_CODE, LIGHTGRAY_COLOR_CODE
    
    if fake then
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_removefake"]) )
    
    elseif ignore then
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_unignore"]) )
    
    elseif override then
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_ignore"]) )
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_ctrl+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_clearoverride"]) )
    
    elseif ok or stored then
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_ignore"]) )
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_ctrl+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_override"]) )
        if altrecord then
            tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_alt+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_altoverride"]) )
        end
    
    elseif temp then
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_ignore"]) )
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_ctrl+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_cleartemporary"]) )
    
    elseif missing then
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_ignore"]) )
        tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_ctrl+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_temporary"]) )
    end
    
    -- Anchor and display the tooltip to the left of the player name
    addon:MyAnchorTo(tooltip, widget.frame, 2, 4, "LEFT")
    tooltip:Show()
    
    -- Dim those categories that are not provided by the player
    for itemName,itemRow in pairs(addon.wtItemRows) do
        if not addon:IsItemProvider(itemName, playerName) then
            itemRow.frame:SetAlpha(0.5)
        end
    end
end

-- Called when the mouse is moved away from a player in the main GUI
function addon:Player_OnLeave(widget)
    addon:ReleaseTooltip_Player()
    
    -- Restore the categories to their normal colours
    for itemName,itemRow in pairs(addon.wtItemRows) do
        itemRow.frame:SetAlpha(1)
    end
end

-- Called when a player is clicked in the main GUI
-- This is mainly used to set or remove custom data for that player
function addon:Player_OnClick(widget)
    local playerName = widget:GetUserData("playerName")
    local engClass = widget:GetUserData("engClass")
    
    local changed = false
    
    local shiftDown = IsShiftKeyDown()
    local ctrlDown  = IsControlKeyDown()
    local altDown   = IsAltKeyDown()
    
    local fake,ignore,override,ok,stored,temp,missing = addon:GetPlayerBools(playerName)

    if fake then
        if shiftDown then
            addon:RemoveFake(playerName)
            changed = true
        end
    
    elseif ignore then
        if shiftDown then
            addon:RemoveIgnore(playerName)
            addon:UpdateCheckbox(playerName)
            changed = true
        end
    
    elseif override then
        if shiftDown then
            addon:AddIgnore(playerName)
            addon:UpdateCheckbox(playerName)
            changed = true
        elseif ctrlDown or altDown then
            addon:RemoveOverride(playerName)
            changed = true
        end
    
    elseif ok or stored then
        if shiftDown then
            addon:AddIgnore(playerName)
            addon:UpdateCheckbox(playerName)
            changed = true
        elseif ctrlDown then
            addon:CustomData_Start(widget, engClass, true)
        elseif altDown then
            addon:AddOverride(playerName, nil, addon:GetAltRecord(playerName, addon.raidClass[playerName]))
            changed = true
        end
        
    elseif temp then
        if shiftDown then
            addon:AddIgnore(playerName)
            addon:UpdateCheckbox(playerName)
            changed = true
        elseif ctrlDown then
            addon:RemoveTemporary(playerName)
            changed = true
        end

    elseif missing then
        if shiftDown then
            addon:AddIgnore(playerName)
            addon:UpdateCheckbox(playerName)
            changed = true
        elseif ctrlDown then
            addon:CustomData_Start(widget, engClass, false)
        end
    end

    if changed then    
        addon:Recalculate()
    end
end


-- =================================
-- Database
-- =================================

-- Called when the mouse is moved over a player in the database GUI
function addon:DatabasePlayer_OnEnter(widget)
    local playerName = widget:GetUserData("playerName")
    local engClass = widget:GetUserData("engClass")
    
    local record = addon:GetRecord(playerName, engClass)
    local altrecord = addon:GetAltRecord(playerName, engClass)
    
    local fake,ignore,override,ok,stored,temp,missing = addon:GetPlayerBools(playerName)
    local fakeName = format( L["format_fakename"], playerName )
    
    -- Release any current player tooltips and get a new one
    addon:ReleaseTooltip_Player()
    
    local tooltip = LibQT:Acquire("RCTooltip_Player", 2, "RIGHT", "LEFT")
    addon.playertooltip = tooltip 
    addon:Tooltip_SetColor(tooltip)
    
    -- Add line showing the playername and the status of their talent scan data
    local y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, addon:EncapsColor( playerName, record.engClass ), nil, "LEFT" )
    tooltip:SetCell( y, 2, addon:GetPlayerCode(playerName, true) )
    
    -- Add line showing their spec and alt spec (if they have one)
    tooltip:AddLine( addon:GetSpecName(record.engClass, record.specId), record.specPoints )
    if altrecord then
        tooltip:AddLine( addon:ColorCode(LIGHTGRAY_COLOR_CODE, addon:GetSpecName(altrecord.engClass, altrecord.specId)), addon:ColorCode(LIGHTGRAY_COLOR_CODE, altrecord.specPoints) )
    end
    
    -- Add line showing time of last talent scan
    y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, addon:ColorCode(LIGHTGRAY_COLOR_CODE, format( L["format_timetooltip"], addon:TimeDifference(record.updateTime) )) , nil, "CENTER", 2 )
    
    -- Add lines to show available options for this player
    if not addon.raidSubGroup[playerName] then
        local keycolor, actioncolor = GRAY_FONT_COLOR_CODE, LIGHTGRAY_COLOR_CODE

        if addon:IsFake( fakeName ) then
            tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_removefake"]) )
        
        elseif ok or stored then
            tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_shift+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_addasfake"]) )
            if altrecord then
                tooltip:AddLine( addon:ColorCode(keycolor, L["tooltip_alt+click"]..":"), addon:ColorCode(actioncolor, L["tooltip_addaltasfake"]) )
            end
        end
    end
    
    -- Anchor and display the tooltip to the left of the player name
    addon:MyAnchorTo(tooltip, widget.frame, 2, 4, "LEFT")
    tooltip:Show()
end

-- Called when the mouse is moved away from a player in the database GUI
function addon:DatabasePlayer_OnLeave(widget)
    addon:ReleaseTooltip_Player()
end

-- Called when a player is clicked in the database GUI
-- This is mainly used to add or remove a fake record for that player
function addon:DatabasePlayer_OnClick(widget)
    local playerName = widget:GetUserData("playerName")
    local engClass = widget:GetUserData("engClass")
    
    -- Player is really in the raid, so don't do anything
    if addon.raidSubGroup[playerName] then return end
    
    local changed = false
    
    local shiftDown = IsShiftKeyDown()
    local ctrlDown  = IsControlKeyDown()
    local altDown   = IsAltKeyDown()
    
    local fake,ignore,override,ok,stored,temp,missing = addon:GetPlayerBools(playerName)
    local fakeName = format( L["format_fakename"], playerName )
    
    if addon:IsFake( fakeName ) then
        if shiftDown or altDown then
            addon:RemoveFake(fakeName)
            changed = true
        end
    
    elseif ok or stored then
        if shiftDown then
            addon:AddAsFake(playerName, true)
            changed = true
        elseif altDown then
            addon:AddAsFake(playerName, false)
            changed = true
        end
    end

    if changed then    
        addon:Recalculate()
    end
end


-- =================================
-- Talent Scan frame
-- =================================

-- Purge the database of stored talents and rescan when the Purge button is clicked
function addon:PurgeButton_OnClick(widget)
    addon:PurgeAndRescan()
end

-- Refresh the text of the labels in the Talent Scan frame
function addon:CalcLabel_Refresh()
    local text

    -- Set wtCalcLabel to show the time since the last update
    if addon.wtCalcLabel then
        if addon.db.factionrealm.lastCalc == -1 then
            text = "Talents not yet scanned"
        else
            text = format( L["format_timedifference"], addon:TimeDifference(addon.db.factionrealm.lastCalc) )
        end
        
        addon.wtCalcLabel:SetText( text )
    end
    
    -- Set wtScanLabel to show the number of talent scans outstanding
    if addon.wtScanLabel then
        local talentsgot, talentsmissing = addon:GetTalentCount()
        
        if talentsgot and talentsmissing then
            text = format( L["format_scanspending"], tostring(talentsmissing), tostring(talentsgot + talentsmissing) )
        else
            text = format( L["format_scanspending"], "?", "?" )
        end
        
        addon.wtScanLabel:SetText( text )
    end
    
    -- Set wtDBLabel to show the number of talent scans stored in the database
    if addon.wtDatabaseLabel then
        local playercount = 0

        for _ in pairs(addon.db.factionrealm.raidDB) do
            playercount = playercount + 1
        end
        
        text = format( L["format_dbentries"], tostring(playercount) )

        addon.wtDatabaseLabel:SetText( text )
    end
end


-- =================================
-- Status Bar
-- =================================
function addon:Status_OnEnter(widget)
    if addon.mode == "CALENDAR" then
        if addon.eventInfo then
            -- Create a GameTooltip using the event info
            GameTooltip:SetOwner(widget, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("BOTTOMLEFT", widget, "TOPLEFT")
            
            GameTooltip:SetText( addon.eventInfo[1] )
            GameTooltip:AddLine( addon.eventInfo[2] )
            GameTooltip:AddLine( addon.eventInfo[3] )
            GameTooltip:AddLine( addon.eventInfo[4], 1, 1, 1 )
            GameTooltip:AddLine( addon.eventInfo[5], 1, 1, 1 )
            if strlen(addon.eventInfo[6]) > 0 then
                GameTooltip:AddLine( " " )
                GameTooltip:AddLine( addon.eventInfo[6], _, _, _, 1 )
            end
            
            GameTooltip:SetMinimumWidth(310)
            GameTooltip:Show()
        end
    end
end

-- Called when the mouse is moved away from the status bar
function addon:Status_OnLeave(widget)
--    addon:ReleaseTooltip_Status()
    GameTooltip:Hide()
end


-- =================================
-- Sorting
-- =================================
function addon:SortRaid_OnClick(widget, sortType)
    if addon.sortRaidType == sortType then
        addon.sortRaidDesc = not addon.sortRaidDesc
    else
        addon.sortRaidType = sortType
        addon.sortRaidDesc = false
    end
    
    addon:RefreshGUI()
end

function addon:SortDatabase_OnClick(widget, sortType)
    if addon.sortDatabaseType == sortType then
        addon.sortDatabaseDesc = not addon.sortDatabaseDesc
    else
        addon.sortDatabaseType = sortType
        addon.sortDatabaseDesc = false
    end
    
    addon:RefreshDB()
end


-- =================================
-- Pets
-- =================================

-- Toggle the selected pet's ability on or off when it's selected from the pet tooltip window
local function Pets_OnSelect(cell, arg, button)
    local petType, y = strsplit(":", arg)
    y = tonumber(y)

    addon:ToggleFakePet(petType)
    addon:Recalculate()
end

-- Create the pet tooltip window when the Pets button is clicked
function addon:Pets_OnClick(widget)
    -- If the pet tooltip is already being shown then close it
    if addon.petstooltip then
        addon:ReleaseTooltip_Pets()
        return
    end
    
    -- Release any open tooltips and create a new one
    addon:ReleaseTooltips()
    local tooltip = LibQT:Acquire("RCTooltip", 4, "LEFT", "LEFT", "LEFT", "LEFT")
    addon.petstooltip = tooltip
    addon:Tooltip_SetColor(tooltip)
    
    -- Add a line to the tooltip for each potential pet ability
    for petIndex,petObject in ipairs(addon.PETABILITIES) do
        local y, x = tooltip:AddLine()
        local checktex = ""
        
        if addon:IsFakePetActive(petObject.petType) then
            -- UI-CheckBox-Check-Disabled.blp
            checktex = "Interface\\Buttons\\UI-CheckBox-Check.blp"
        end
        
        y, x = tooltip:SetCell(y, 1, addon:EmbedTex(checktex, 20))
        y, x = tooltip:SetCell(y, 2, addon:EncapsColor(L[petObject.petType], petObject.engClass))
        local spellName, spellRank, spellIcon = GetSpellInfo(petObject.spellId)
        y, x = tooltip:SetCell(y, 3, addon:EmbedTex(spellIcon, 24))
        y, x = tooltip:SetCell(y, 4, addon:EncapsColor(spellName, petObject.engClass))

        -- Assign the callback to the tooltip
        tooltip:SetLineScript(y, "OnMouseDown", Pets_OnSelect, petObject.petType..":"..y)
    end
    
    -- Anchor the tooltip and show it
    tooltip:SmartAnchorTo(widget.frame)
    tooltip:Show()
end


-- =================================
-- Selection
-- =================================

-- This function is called when one of the View Raid/View Calendar radio buttons is clicked
-- It toggles the GUI mode, then calls a raid check and updates the status bar
function addon:ModeToggle(widget, value)
    if not value then return end
    
    addon.mode = widget:GetUserData("mode")

    for index,radio in ipairs(addon.wtModeRadios) do
        if radio:GetUserData("mode") ~= addon.mode then
            radio:SetValue(false)
        end
    end
    
    for index,checkbox in ipairs(addon.wtGroupCheckboxes) do
        checkbox:SetLabel(addon:GetCheckboxLabel(index))
        checkbox:SetValue(nil)
    end

    addon:RaidCheck()
    addon:SetStatus()
end

-- Clear the list of ignored players and retick all the group selection checkboxes when the Clear Ignores button is clicked
function addon:ClearIgnores()
    for index,checkBox in ipairs(addon.wtGroupCheckboxes) do
        checkBox:SetValue(nil)
    end
    
    addon:RemoveAllIgnores()
    addon:Recalculate()
end

-- Clear the list of talent spec overrides when the Clear Overrides button is clicked
function addon:ClearOverrides()
    addon:RemoveAllOverrides()
    addon:Recalculate()
end

-- Clear the list of fake players when the Clear Fakes button is clicked
function addon:ClearFakes()
    addon:RemoveAllFakes()
    addon:Recalculate()
end

-- This function is called when a checkbox value changes
-- It ignores or unignores all players of the specified raid subgroup or invite status
function addon:CheckboxToggle(widget, value)
    if value == nil then return end
    
    local index = widget:GetUserData("index")
    
    if addon.mode == "RAID" then
        for unit, playerName in pairs(addon.raidIds) do
            if addon.raidSubGroup[playerName] == index then
                if value then
                    addon:RemoveIgnore(playerName)
                else
                    addon:AddIgnore(playerName)
                end
            end
        end
    elseif addon.mode == "CALENDAR" then
        for unit, playerName in pairs(addon.raidIds) do
            if addon:GetInviteCodeForSort(addon.raidSubGroup[playerName]) == index then
                if value then
                    addon:RemoveIgnore(playerName)
                else
                    addon:AddIgnore(playerName)
                end
            end
        end
    end
    
    addon:Recalculate()
end

-- This function takes a player name, looks up their subgroup or invite status and sets the associated checkbox to nil
-- It is called when a player is manually ignored or unignored
function addon:UpdateCheckbox(playerName)
    local checkbox
    
    if addon.mode == "RAID" then
        checkbox = addon.wtGroupCheckboxes[ addon.raidSubGroup[playerName] ]
    elseif addon.mode == "CALENDAR" then
        checkbox = addon.wtGroupCheckboxes[ addon:GetInviteCodeForSort(addon.raidSubGroup[playerName]) ]
    end

    checkbox:SetValue(nil)
end


-- =================================
-- Database
-- =================================

function addon:Database_OnClick(widget)
    addon:RefreshDB()
    
    addon.dbframe:Show()
end