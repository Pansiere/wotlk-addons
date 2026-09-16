local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)

local LibQT = LibStub("LibQTip-1.0")


-- This function changes a counter and rank to the path of the appropriate presence icon
-- The count must be more than addon.FULL to count as being fully present and get a tick
local function CountRank2PresenceIcon(count, rank)
    if not count then count = 0 end
    if not rank then rank = 1000 end

    local presenceIcon = addon.IMAGEPATH.."maybe"
    if count >= addon.FULL then
        if rank == 1 then
            presenceIcon = addon.IMAGEPATH.."check"
        else
            presenceIcon = addon.IMAGEPATH.."nonoptimal"
        end
    elseif count <= 0 then
        presenceIcon = addon.IMAGEPATH.."cross"
    end

    return presenceIcon
end

-- This function retrieves the count and rank for the specified buff type and uses them to get the presence icon
function addon:SumItems2PresenceIcon(itemName)
    local count = addon.sumItems[itemName]
    local rank = addon.itemRank[itemName]
    
    return CountRank2PresenceIcon(count, rank)
end

-- This function retrieves the count and rank for the specified spellId and uses them to get the presence icon
function addon:SimpleCount2PresenceIcon(itemName, spellId)
    local count = addon.simpleCount[spellId]
    local rank = addon.SPELLRANK[itemName][spellId]
    
    return CountRank2PresenceIcon(count, rank)
end

-- This function retrieves the simpleCount value for the specified spellId
-- This is used by the BuffItem tooltip to show the total number of people who can cast that spell
function addon:GetSimpleCount(spellId)
    local count = addon.simpleCount[spellId]
    if not count then count = 0 end
    
    return count
end

-- This function retrieves the sumItems value for the specified spellId
-- This is used by the BuffItem tooltip to show the total number of people who can provide that buff
function addon:GetSumItems(itemName)
    local count = addon.sumItems[itemName]
    if not count then count = 0 end
    
    return count
end

-- This function encloses the specified string in colour code tags
-- It is used to colour the text on tooltips
function addon:ColorCode(color, str)
    return color..str..FONT_COLOR_CODE_CLOSE
end

-- This function encloses the specified value in green colour tags if it's greater than zero, or red if it's not
-- It is used to colour the count values on the main GUI
function addon:ColorCodeCount(count)
    if count <= 0 then
        return addon:ColorCode(RED_FONT_COLOR_CODE, count)
    else
        return addon:ColorCode(GREEN_FONT_COLOR_CODE, count)
    end
end


local backdrop = { bgFile = "Interface/AchievementFrame/UI-Achievement-AchievementBackground.blp", 
                   edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                   tile = true, tileSize = 16, edgeSize = 16, 
                   insets = { left = 4, right = 4, top = 4, bottom = 4 }
                 }

-- This function sets the tooltip background and alpha to common values
function addon:Tooltip_SetColor(tooltip, extracolor)
    -- Color tooltip
    tooltip:SetBackdrop(backdrop);
    tooltip:SetBackdropColor(0,0,0,0.9)
    if extracolor then
        tooltip:SetBackdropBorderColor(0, 0.5, 1, 1)
    end
    tooltip:SetAlpha(1)
end

-- When a tooltip window is closed, remove the X from the corner
local function Tooltip_OnHide()
    addon:Tooltip_RemoveCloseX()
end

-- Detaches the close X from the corner of a tooltip and hides it
function addon:Tooltip_RemoveCloseX()
    if addon.tooltipclosex then
        addon.tooltipclosex:ClearAllPoints()
        addon.tooltipclosex:SetParent(nil)
        addon.tooltipclosex:Hide()
    end
end

-- Add a close X to the top right corner of a tooltip
function addon:Tooltip_AddCloseX(tooltip, onHideFunction)
    local x = tooltip:AddColumn("RIGHT")
    tooltip:SetCell(1, x, "   ")
    
--    tooltip:SetScript("OnHide", Tooltip_OnHide)

    addon.tooltipclosex:SetParent(tooltip)
    addon.tooltipclosex:ClearAllPoints()
    addon.tooltipclosex:SetPoint("TOPRIGHT", tooltip, "TOPRIGHT", 2, 2)
    addon.tooltipclosex:Show()
end

-- Releases the AddFake tooltip
function addon:ReleaseTooltip_AddFake()
    if addon.addfaketooltip then
        LibQT:Release(addon.addfaketooltip)
        addon.addfaketooltip = nil
        addon:Tooltip_RemoveCloseX()
    end
end

-- Releases the CustomData tooltip
function addon:ReleaseTooltip_CustomData()
    if addon.customdatatooltip then
        LibQT:Release(addon.customdatatooltip)
        addon.customdatatooltip = nil
        addon.customdatawidget = nil
        addon:Tooltip_RemoveCloseX()
    end
end

-- Releases the Pet selection tooltip
function addon:ReleaseTooltip_Pets()
    if addon.petstooltip then
        LibQT:Release(addon.petstooltip)
        addon.petstooltip = nil
        addon:Tooltip_RemoveCloseX()
    end
end

-- Releases the BuffItem tooltip
function addon:ReleaseTooltip_BuffItem(keepclosex)
    if addon.buffitemtooltip then
        LibQT:Release(addon.buffitemtooltip)
        addon.buffitemtooltip = nil
        addon.buffitemwidget = nil
        if not keepclosex then addon:Tooltip_RemoveCloseX() end
        GameTooltip:Hide()
    end
end

-- Releases the Player information tooltip
function addon:ReleaseTooltip_Player()
    if addon.playertooltip then
        LibQT:Release(addon.playertooltip)
        addon.playertooltip = nil
    end
end

-- Releases the Status Bar tooltip
function addon:ReleaseTooltip_Status()
    if addon.statustooltip then
        LibQT:Release(addon.statustooltip)
        addon.statustooltip = nil
    end
end

-- Releases the Help tooltip
function addon:ReleaseTooltip_Help()
    if addon.helptooltip then
        LibQT:Release(addon.helptooltip)
        addon.helptooltip = nil
        addon:Tooltip_RemoveCloseX()
    end
end

-- Releases all tooltips, usually to prevent two tooltips from being displayed at the same time
function addon:ReleaseTooltips()
    addon:ReleaseTooltip_AddFake()
    addon:ReleaseTooltip_BuffItem()
    addon:ReleaseTooltip_Pets()
    addon:ReleaseTooltip_CustomData()
    addon:ReleaseTooltip_Player()
    addon:ReleaseTooltip_Status()
    addon:ReleaseTooltip_Help()
end

-- This function determines if any of the GUI tooltips are currently being shown
function addon:Tooltip_AnyClickableVisible()
    result = false
    if addon.addfaketooltip and addon.addfaketooltip:IsVisible() then result = true end
    if addon.customdatatooltip and addon.customdatatooltip:IsVisible() then result = true end
    if addon.petstooltip and addon.petstooltip:IsVisible() then result = true end
    if addon.buffitemtooltip and addon.buffitemtooltip:IsVisible() then result = true end
    if addon.helptooltip and addon.helptooltip:IsVisible() then result = true end
end

-- This function anchors the tooltip to the frame
function addon:MyAnchorTo(tooltip, widgetframe, xOffset, yOffset, alignment)
    if not tooltip then return end
    if not widgetframe then return end
    if not xOffset then xOffset = 0 end
    if not yOffset then yOffset = 0 end
    
    tooltip:ClearAllPoints()
    tooltip:SetClampedToScreen(true)
    
    if alignment == "LEFT" then
        tooltip:SetPoint("TOPRIGHT", widgetframe, "TOPLEFT", xOffset, yOffset)
    elseif alignment == "ABOVE" then
        tooltip:SetPoint("BOTTOMLEFT", widgetframe, "TOPLEFT", xOffset, yOffset)
    else
        tooltip:SetPoint("TOPLEFT", widgetframe, "TOPRIGHT", xOffset, yOffset)
    end
end

-- This function counts how many of the players in the list are not also on the ignore list
function addon:CountUnignored(playerlist)
    local count = 0
    
    for index,playerName in ipairs(playerlist) do
        if not addon:IsIgnored(playerName) then
            count = count + 1
        end
    end
    
    return count
end

-- This function retrieves the localised text for the specified checkbox
function addon:GetCheckboxLabel(checkbox)
    local label = ""
    
    if addon.mode == "RAID" then
        label = format( L["format_checkboxgroup"], checkbox )
    elseif addon.mode == "CALENDAR" then
        if checkbox == 1 then
            label = L["longConfirmed"]
        elseif checkbox == 2 then
            label = L["longAccepted"]
        elseif checkbox == 3 then
            label = L["longSignedUp"]
        elseif checkbox == 4 then
            label = L["longInvited"]
        elseif checkbox == 5 then
            label = L["longStandby"]
        elseif checkbox == 6 then
            label = L["longTentative"]
        elseif checkbox == 7 then
            label = L["longOut"]
        elseif checkbox == 8 then
            label = L["longDeclined"]
        end
    end
    
    return label
end

-- This function displays the Help tooltip when the user clicks the Help button
function addon:Tooltip_ShowHelp()
    addon:ReleaseTooltips()

    local tooltip = LibQT:Acquire( "RCTooltip", 2, "RIGHT", "LEFT" )
    addon.helptooltip = tooltip 
    addon:Tooltip_SetColor(tooltip)

    local y, x
    
    -- Help 1 & 2
    y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, L["help1"], nil, "LEFT", 2 )
    y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, L["help2"], nil, "LEFT", 2 )
    
    tooltip:AddLine( " " )
    
    -- Help 3
    y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, addon:ColorCode(NORMAL_FONT_COLOR_CODE, L["help3"]), nil, "LEFT", 2 )
    
    -- Buff
    tooltip:AddLine( addon:EmbedTex(addon.IMAGEPATH.."buff", 12), L["help_buff"] )
    -- Debuff
    tooltip:AddLine( addon:EmbedTex(addon.IMAGEPATH.."debuff", 12), L["help_debuff"] )
    -- Dot
    tooltip:AddLine( addon:EmbedTex(addon.IMAGEPATH.."dot", 12), L["help_dot"] )
    tooltip:AddLine( " " )

    -- Help 4
    y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, addon:ColorCode(NORMAL_FONT_COLOR_CODE, L["help4"]), nil, "LEFT", 2 )
    -- Check
    tooltip:AddLine( addon:EmbedTex(addon.IMAGEPATH.."check", 12) , L["help_check"] )
    -- Nonoptimal
    tooltip:AddLine( addon:EmbedTex(addon.IMAGEPATH.."nonoptimal", 12), L["help_nonoptimal"] )
    tooltip:AddLine( "", addon:ColorCode(GRAY_FONT_COLOR_CODE, L["help_nonoptimal_ex1"]) )
    tooltip:AddLine( "", addon:ColorCode(GRAY_FONT_COLOR_CODE, L["help_nonoptimal_ex2"]) )
    -- Maybe
    tooltip:AddLine( addon:EmbedTex(addon.IMAGEPATH.."maybe", 12), L["help_maybe"] )
    tooltip:AddLine( "", addon:ColorCode(GRAY_FONT_COLOR_CODE, L["help_maybe_ex1"]) )
    tooltip:AddLine( "", addon:ColorCode(GRAY_FONT_COLOR_CODE, L["help_maybe_ex2"]) )
    -- Cross
    tooltip:AddLine( addon:EmbedTex(addon.IMAGEPATH.."cross", 12), L["help_cross"] )
    tooltip:AddLine( " " )
                           
    -- Help 5
    y, x = tooltip:AddLine()
    tooltip:SetCell( y, 1, addon:ColorCode(NORMAL_FONT_COLOR_CODE, L["help5"]), nil, "LEFT", 2 )
    tooltip:AddLine( L["longI"], L["help_ignore"] )
    tooltip:AddLine( L["longO"], L["help_override"] )
    tooltip:AddLine( L["longK"], L["help_ok"] )
    tooltip:AddLine( L["longS"], L["help_stored"] )
    tooltip:AddLine( L["longT"], L["help_temporary"] )
    tooltip:AddLine( L["longM"], L["help_missing"] )
    tooltip:AddLine( L["longF"], L["help_fake"] )

    addon:Tooltip_AddCloseX(tooltip)
    tooltip:ClearAllPoints()
    tooltip:SetClampedToScreen(true)
    tooltip:SetPoint("TOPRIGHT", addon.frame.helpbutton, "BOTTOMRIGHT")
    tooltip:Show()
end
