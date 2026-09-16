local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)

local LibQT  = LibStub("LibQTip-1.0")

local CLASSES = { "DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR" }


-- =================================
-- Add Fake (Preset)
-- =================================

-- This function closes the Fake Class tooltip and calls AddFake_SelectPreset to show the Fake Spec tooltip
local function AddFake_OnSelectClass(cell, arg, button)
    LibQT:Release(addon.addfaketooltip)
    addon.addfaketooltip = nil
    -- Don't clear addon.addfakewidget, AddFake_SelectPreset needs it
    addon:Tooltip_RemoveCloseX()

    addon:AddFake_SelectPreset(arg)
end

-- This function opens the Fake Class tooltip when the Add Fake button has been clicked
function addon:AddFake_OnClick(widget)
    -- If the fakes tooltip is already being shown then close it
    if addon.addfaketooltip then
        addon:ReleaseTooltip_CustomData()
        addon:ReleaseTooltip_AddFake()
        return
    end
    
    -- Release any open tooltips and create a new one
    addon:ReleaseTooltips()
    local tooltip = LibQT:Acquire("RCTooltip", 2, "LEFT", "LEFT")
    addon.addfaketooltip = tooltip
    addon:Tooltip_SetColor(tooltip)

    addon:Tooltip_PopulateClasses(tooltip)
    
    -- Anchor the tooltip and show it
    tooltip:SmartAnchorTo(widget.frame)
    tooltip:Show()
end

-- This function calls AddFake to add the selected fake class/spec to the database, then recalculates the RaidComp
local function AddFake_OnSelectPreset(cell, arg, button)
    addon:AddFake(arg)

    addon:Recalculate()
end

-- This function opens the Fake Spec tooltip showing the available specs for the selected class after one has been clicked
function addon:AddFake_SelectPreset(engClass)
    tooltip = LibQT:Acquire("RCTooltip", 3, "LEFT", "LEFT", "LEFT")
    addon.addfaketooltip = tooltip
    addon:Tooltip_SetColor(tooltip)

    addon:Tooltip_PopulatePresets(tooltip, engClass, AddFake_OnSelectPreset)

    tooltip:SmartAnchorTo(addon.wtAddFakeButton.frame)
    tooltip:Show()
end


-- =================================
-- Custom Data (Preset)
-- =================================

-- This function sets the chosen preset as an override or temporary data set for the selected player
local nextIsOverride = false
local function CustomData_OnSelectPreset(cell, arg, button)
    local playerName = addon.customdatawidget:GetUserData("playerName")
    
    if nextIsOverride then
        addon:AddOverride(playerName, arg, nil)
    else
        addon:AddTemporary(playerName, arg)
    end

    addon:Recalculate()
end

-- This function creates a tooltip and populates it with the presets for the specified class
-- It is called when the user ctrl-clicks on a player in the GUI
function addon:CustomData_Start(widget, engClass, override)
    addon:ReleaseTooltips()

    tooltip = LibQT:Acquire("RCTooltip", 3, "LEFT", "LEFT", "LEFT")
    addon.customdatatooltip = tooltip
    addon.customdatawidget = widget
    addon:Tooltip_SetColor(tooltip)
    
    addon:Tooltip_PopulatePresets(tooltip, engClass, CustomData_OnSelectPreset)
    
    nextIsOverride = override
    
    addon:Tooltip_AddCloseX(tooltip)
    addon:MyAnchorTo(tooltip, widget.frame, 0, 4)
    tooltip:Show()
end

-- This function populates a tooltip with the preset class/specs defined in Const_Presets.lua
-- It is used when a class is picked from the Add Fake button or when overriding a player's record
function addon:Tooltip_PopulatePresets(tooltip, engClass, func)
    for presetIndex,presetObject in ipairs(addon.PRESETS[engClass]) do

        local icon1,icon2 = "", ""
        
        if presetObject.icon1 and (presetObject.icon1 ~= "") then
            icon1 = addon:EmbedTex(presetObject.icon1, 24)
        end
        if presetObject.icon2 and (presetObject.icon2 ~= "") then
            icon2 = addon:EmbedTex(presetObject.icon2, 24)
        end
        
        local y, x = tooltip:AddLine()
        if icon2 and icon2 ~= "" then
            y, x = tooltip:SetCell(y, 1, icon2)
        end
        if icon1 and icon1 ~= "" then
            y, x = tooltip:SetCell(y, 2, icon1)
        end
        y, x = tooltip:SetCell(y, 3, L[presetObject.presetName])
    
        -- Assign the callback to the tooltip
        tooltip:SetLineScript(y, "OnMouseDown", func, engClass..":"..presetObject.presetName)
    end
end

-- This function populates a tooltip with the classes defined in the CLASSES table
-- It is used when the Add Fake button is clicked
function addon:Tooltip_PopulateClasses(tooltip)
    for index,engClass in ipairs(CLASSES) do
        local icon = addon.SPECICONS[engClass]
        
        local y, x = tooltip:AddLine()
        y, x = tooltip:SetCell(y, 1, addon:EmbedTex(icon, 24))
        y, x = tooltip:SetCell(y, 2, addon:EncapsColor(L[engClass], engClass))

        -- Assign the callback to the tooltip
        tooltip:SetLineScript(y, "OnMouseDown", AddFake_OnSelectClass, engClass)
    end
end
