local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)

local AceGUI = LibStub("AceGUI-3.0")
local LibQT  = LibStub("LibQTip-1.0")

local TEX_LABELHIGHLIGHT = "Interface\\Buttons\\UI-Listbox-Highlight.blp"

local TEX_CROSS = addon.IMAGEPATH.."cross"
local TEX_MAYBE = addon.IMAGEPATH.."maybe"
local TEX_NONOPTIMAL = addon.IMAGEPATH.."nonoptimal"
local TEX_CHECK = addon.IMAGEPATH.."check"

local guiready = false

local frame

-- This variables are mostly pointers to the widgets in the GUI which need to be updated
addon.frame = nil
addon.wtRaidGroup = nil
addon.wtRaidList = nil
addon.wtAddFakeButton = nil
addon.wtPetsButton = nil
addon.wtModeRadios = { }
addon.wtGroupCheckboxes = { }
addon.wtItemRows = { }
addon.wtItemLabels = { }
addon.wtItemIcons = { }
addon.wtCalcLabel = nil
addon.wtScanLabel = nil
addon.wtDatabaseLabel = nil
addon.CalcLabelTimer = nil

addon.dbframe = nil
addon.wtDatabaseGroup = nil
addon.wtDatabaseList = nil

addon.mode = "RAID"
addon.eventInfo = nil

-- This function opens the GUI, building it if it doesn't already exist and running a RaidCheck
function addon:OpenGUI()
--    addon:PrDebug("RaidComp:OpenGUI()")

    if not guiready then
        addon:BuildGUI()
    end

    addon:RaidCheck()
    addon:SetStatus()
    
    frame:Show()
end

-- This function destroys the GUI, wiping all internal pointers
function addon:DestroyGUI()
    addon:PrDebug("RaidComp:DestroyGUI()")
    
    addon:ReleaseTooltips()

    if guiready == true then
        frame:Hide()
        addon.tooltipclosex = nil
        frame.helpbutton = nil
        frame.clearignorebutton = nil
        frame.clearoverridebutton = nil
        frame.clearfakebutton = nil

        AceGUI:Release(frame)
        addon.frame = nil
        AceGUI:Release(dbframe)
        addon.dbframe = nil
    end
     
    addon.wtRaidGroup = nil
    addon.wtRaidList = nil
    addon.wtAddFakeButton = nil
    addon.wtPetsButton = nil
    addon.wtModeRadios = wipe(addon.wtModeRadios)
    addon.wtGroupCheckboxes = wipe(addon.wtGroupCheckboxes)
    addon.wtItemRows = wipe(addon.wtItemRows)
    addon.wtItemLabels = wipe(addon.wtItemLabels)
    addon.wtItemIcons = wipe(addon.wtItemIcons)
    addon.wtCalcLabel = nil
    addon.wtScanLabel = nil
    addon.wtDatabaseLabel = nil
    
    addon.wtDatabaseGroup = nil
    addon.wtDatabaseList = nil
    
    addon.mode = "RAID"
    addon.eventInfo = nil

    -- Stop Timers
    addon:CancelTimer(addon.CalcLabelTimer)
    addon.CalcLabelTimer = nil

    guiready = false
end

-- This function orders two player names based on the specified sort criteria
-- It is used to sort the raid list, criteria can be by "playerName", "class", "subgroup" or "code"
local function sortRaidList(playerA, playerB)
    if addon.sortRaidType == "playerName" then
    
        if addon.sortRaidDesc then
            return playerA > playerB
        else
            return playerA < playerB
        end
    
    elseif addon.sortRaidType == "class" then
    
        local engClassA = addon:GetRecord(playerA, addon.raidClass[playerA]).engClass
        local engClassB = addon:GetRecord(playerB, addon.raidClass[playerB]).engClass
        if engClassA == engClassB then
            return playerA < playerB
        elseif addon.sortRaidDesc then
            return engClassA > engClassB
        else
            return engClassA < engClassB
        end
    
    elseif addon.sortRaidType == "subgroup" then
    
        local subgroupA = addon.raidSubGroup[playerA]
        if not subgroupA then subgroupA = 0 end
        local subgroupB = addon.raidSubGroup[playerB]
        if not subgroupB then subgroupB = 0 end
        
        if addon.mode == "CALENDAR" then
            subgroupA = addon:GetInviteCodeForSort(subgroupA)
            subgroupB = addon:GetInviteCodeForSort(subgroupB)
        end
        
        if subgroupA == subgroupB then
            return playerA < playerB
        elseif addon.sortRaidDesc then
            return subgroupA > subgroupB
        else
            return subgroupA < subgroupB
        end
    
    elseif addon.sortRaidType == "code" then
        
        local codeA = addon:GetPlayerCodeForSort(playerA)
        local codeB = addon:GetPlayerCodeForSort(playerB)
        
        if codeA == codeB then
            return playerA < playerB
        elseif addon.sortRaidDesc then
            return codeA > codeB
        else
            return codeA < codeB
        end
    end
end

-- This function orders two player names based on the specified sort criteria
-- It is used to sort the database list, criteria can be by "playerName", "class", "specId", "altSpecId" or "updateTime"
local function sortDatabaseList(playerA, playerB)
    local criteriaA, criteriaB
    
    if addon.sortDatabaseType == "playerName" then
        
        if addon.sortDatabaseDesc then
            return playerA > playerB
        else
            return playerA < playerB
        end
    
    elseif addon.sortDatabaseType == "class" then
        
        local recordA = addon:GetRecord(playerA)
        local recordB = addon:GetRecord(playerB)
        
        criteriaA = recordA.engClass
        criteriaB = recordB.engClass
    
    elseif addon.sortDatabaseType == "specId" then
        
        local recordA = addon:GetRecord(playerA)
        local recordB = addon:GetRecord(playerB)
        
        criteriaA = recordA.engClass..recordA.specId
        criteriaB = recordB.engClass..recordB.specId
        
    elseif addon.sortDatabaseType == "altSpecId" then
        
        local recordA = addon:GetRecord(playerA)
        local recordB = addon:GetRecord(playerB)
        local altrecordA = addon:GetAltRecord(playerA)
        local altrecordB = addon:GetAltRecord(playerB)
        
        if altrecordA then criteriaA = recordA.engClass..altrecordA.specId end
        if altrecordB then criteriaB = recordB.engClass..altrecordB.specId end
        
    elseif addon.sortDatabaseType == "updateTime" then
        
        local recordA = addon:GetRecord(playerA)
        local recordB = addon:GetRecord(playerB)
        
        criteriaA = time() - recordA.updateTime
        criteriaB = time() - recordB.updateTime
    end

    if not criteriaA then criteriaA = "" end
    if not criteriaB then criteriaB = "" end
    
    if criteriaA == criteriaB then
        return playerA < playerB
    elseif addon.sortDatabaseDesc then
        return criteriaA > criteriaB
    else
        return criteriaA < criteriaB
    end
end

-- This function refreshes the information in the GUI
-- It fills in the player list and sets the icons and values in the RaidComp
function addon:RefreshGUI()
    addon:PrDebug("RaidComp:RefreshGUI()")
    
    if not guiready then
        addon:BuildGUI()
    end
    
    -- Clear tooltips
    addon:ReleaseTooltips()
    
    -- Wipe the playerlist structure and recreate it
    local playerlist = { }
    for playerId, playerName in pairs(addon.raidIds) do
        tinsert(playerlist, playerName)
    end
    
    -- Add the Fakes to the playerlist
    for fakeName,_ in pairs(addon.db.factionrealm.fakeDB) do
        tinsert(playerlist, fakeName)
    end
    
    -- Set the title of the player frame in the GUI with the number of players in the raid
    addon.wtRaidGroup:SetTitle( format( L["format_raidmembers"], addon:CountUnignored(playerlist), #playerlist ) )

    -- Sort the playerlist
    table.sort(playerlist, sortRaidList)
    
    -- Wipe the player frame in the GUI so we can recreate it
    addon.wtRaidList:ReleaseChildren()
    
    -- For each player 
    for index,playerName in ipairs(playerlist) do
        local record = addon:GetRecord(playerName, addon.raidClass[playerName])
        local subgroup = addon.raidSubGroup[playerName]
        
        if not subgroup then  -- Player is a Fake
            subgroup = 0
        end
        
        -- Create a new row
        local row = AceGUI:Create("SimpleGroup")
        row:SetLayout('Flow')
        
        -- Add the player's name to the row, coloured by class
        local name = AceGUI:Create("InteractiveLabel")
        name:SetText( addon:EncapsColor(playerName, record.engClass) )
        name:SetWidth(100)
        name:SetHighlight(TEX_LABELHIGHLIGHT)
        name:SetUserData("playerName", playerName)
        name:SetUserData("engClass", record.engClass)
        name:SetCallback("OnEnter", function(widget, event) addon:Player_OnEnter( widget ) end )
        name:SetCallback("OnLeave", function(widget, event) addon:Player_OnLeave( widget ) end )
        name:SetCallback("OnClick", function(widget, event) addon:Player_OnClick( widget ) end )
        row:AddChild(name)
        
        -- Add the raid group number or invite status code to the row
        local grnr = AceGUI:Create("InteractiveLabel")
        if addon.mode == "RAID" then
            grnr:SetText("  "..subgroup)
        elseif addon.mode == "CALENDAR" then
            grnr:SetText("  "..addon:GetInviteCode(subgroup))
        end
        grnr:SetWidth(25)
        row:AddChild(grnr)
        
        -- Add in indicator to show whether or not we have up to date talents
        local icon = AceGUI:Create("InteractiveLabel")
        icon:SetText( addon:GetPlayerCode(playerName) )
        icon:SetWidth(16)
        row:AddChild(icon)
        
        -- Add the row to the frame
        addon.wtRaidList:AddChild(row)
    end
    
    -- Update the Clear Ignores/Overrides/Fakes buttons
    local count = addon:CountIgnores()
    frame.clearignorebutton:SetText( format( L["format_clearignores"], count ) )
    if count == 0 then
        frame.clearignorebutton:SetDisabled(true)
    else
        frame.clearignorebutton:SetDisabled(false)
    end
    
    count = addon:CountOverrides()
    frame.clearoverridebutton:SetText( format( L["format_clearoverrides"], count ) )
    if count == 0 then
        frame.clearoverridebutton:SetDisabled(true)
    else
        frame.clearoverridebutton:SetDisabled(false)
    end
    
    count = addon:CountFakes()
    frame.clearfakebutton:SetText( format( L["format_clearfakes"], count ) )
    if count == 0 then
        frame.clearfakebutton:SetDisabled(true)
    else
        frame.clearfakebutton:SetDisabled(false)
    end
    
    -- For each buff/debuff label
    for itemName,itemLabel in pairs(addon.wtItemLabels) do
        local count, rank = addon.sumItems[itemName], addon.itemRank[itemName]
        local tex, r, g, b
        
        if not count then count = 0 end
        if not rank then rank = 1000 end
             
        if addon.wtItemIcons[itemName]:GetUserData("itemType") == addon.ITEMTYPE_COUNT then
            -- For "count" type buffs we determine the correct counter colour and text colour
            addon.wtItemIcons[itemName]:SetText(count/addon.FULL)
            if count <= 0 then
                addon.wtItemIcons[itemName]:SetColor(1,0,0)  -- Red counter with grey text
                r,g,b = 0.5,0.5,0.5
            else
                addon.wtItemIcons[itemName]:SetColor(0,1,0)  -- Green counter with white text
                r,g,b = 1,1,1
            end

            itemLabel:SetColor(r,g,b)
        else        
            -- For normal buffs/debuffs we determine the correct icon and text colour
            if count >= addon.FULL then
                tex,r,g,b = TEX_NONOPTIMAL,0,1,0  -- Blue tick with green text
                if rank == 1 then  -- If we have the highest rank then use a green tick
                    tex = TEX_CHECK
                end
            elseif count <= 0 then
                tex,r,g,b = TEX_CROSS,0.5,0.5,0.5  -- Red cross with grey text
            else
                tex,r,g,b = TEX_MAYBE,1,1,0  -- Yellow squiggle with yellow text
            end
            
            itemLabel:SetColor(r,g,b)
            addon.wtItemIcons[itemName]:SetImage(tex)
        end
    end
end

-- This function refreshes the player list in the Database frame
function addon:RefreshDB()
    addon:PrDebug("RaidComp:RefreshDB()")
    
    if not guiready then
        addon:BuildGUI()
    end
    
    -- Clear tooltips
    addon:ReleaseTooltips()
    
    -- Wipe the playerlist structure and recreate it
    local playerlist = { }
    local count = 0
    for playerName,_ in pairs(addon.db.factionrealm.raidDB) do
        tinsert(playerlist, playerName)
        count = count + 1
    end
    
    addon.dbframe:SetStatusText( addon:ColorCode(GRAY_FONT_COLOR_CODE, format( L["format_status_database"], count ) ) )
    
    -- Sort the playerlist
    table.sort(playerlist, sortDatabaseList)
    
    -- Wipe the player frame in the GUI so we can recreate it
    addon.wtDatabaseList:ReleaseChildren()
    
    -- For each player 
    for _,playerName in ipairs(playerlist) do
        local record = addon:GetRecord(playerName)
        local altrecord = addon:GetAltRecord(playerName)
        
        -- Create a new row
        local row = AceGUI:Create("SimpleGroup")
        row:SetLayout('Flow')
        row:SetWidth(350)
        
        -- Add the player's name to the row, coloured by class
        local name = AceGUI:Create("InteractiveLabel")
        name:SetText( addon:EncapsColor(playerName, record.engClass) )
        name:SetWidth(100)
        name:SetHighlight(TEX_LABELHIGHLIGHT)
        name:SetUserData("playerName", playerName)
        name:SetUserData("engClass", record.engClass)
        name:SetCallback("OnEnter", function(widget, event) addon:DatabasePlayer_OnEnter( widget ) end )
        name:SetCallback("OnLeave", function(widget, event) addon:DatabasePlayer_OnLeave( widget ) end )
        name:SetCallback("OnClick", function(widget, event) addon:DatabasePlayer_OnClick( widget ) end )
        row:AddChild(name)
        
        -- Add the mainspec id to the row
        local mainspec = AceGUI:Create("InteractiveLabel")
        mainspec:SetText( addon:GetSpecName(record.engClass, record.specId) )
        mainspec:SetWidth(80)
        row:AddChild(mainspec)
        
        -- Add the altspec id to the row
        local altspec = AceGUI:Create("InteractiveLabel")
        if altrecord then
            altspec:SetText( addon:GetSpecName(altrecord.engClass, altrecord.specId) )
        end
        altspec:SetWidth(80)
        row:AddChild(altspec)
        
        -- Add the time since the last update
        local update = AceGUI:Create("InteractiveLabel")
        update:SetText( format( L["format_timeold"], addon:TimeDifference(record.updateTime) ) )
        update:SetWidth(80)
        row:AddChild(update)
        
        -- Add the row to the frame
        addon.wtDatabaseList:AddChild(row)
    end
end

-- This function sets the status bar and the status bar tooltip text
-- It is called when the GUI is opened and when the GUI mode is changed
function addon:SetStatus()
    if addon.mode == "RAID" then
        frame:SetStatusText( addon:ColorCode(GRAY_FONT_COLOR_CODE, L["status_viewingraid"] ) )
        addon.eventInfo = nil
    elseif addon.mode == "CALENDAR" then
        frame:SetStatusText( addon:ColorCode(GRAY_FONT_COLOR_CODE, addon:GetEventDesc() ) )
        addon.eventInfo = addon:GetEventInfo()
    end
end

-- This function constructs the main GUI, which consists of two main frames
-- The left frame contains the playerlist and the right frame contains the RaidComp data
function addon:BuildGUI()
    addon:PrDebug("RaidComp:BuildGUI()")
    
    addon.wtItemRows = wipe(addon.wtItemRows)
    addon.wtItemLabels = wipe(addon.wtItemLabels)
    addon.wtItemIcons = wipe(addon.wtItemIcons)
    addon.wtGroupCheckboxes = wipe(addon.wtGroupCheckboxes)

    -- Create main frame
    frame = AceGUI:Create("Frame")
    addon.frame = frame
    frame:SetTitle(addon.ADDONTITLE)
    frame:SetCallback("OnClose", function(widget, event) addon:Frame_OnClose( widget ) end )
    frame:SetLayout('Flow')

    -- Subframes
    local leftframe = addon:BuildGUI_LeftFrame()
    frame:AddChild( leftframe )
    local rightframe = addon:BuildGUI_RightFrame()
    frame:AddChild( rightframe )

    -- Adjust default minimum frame size based on size of child frames
    frame:SetWidth( leftframe.frame:GetWidth() + rightframe.frame:GetWidth() + 34 )
    frame:SetHeight( rightframe.frame:GetHeight() + 68 )
    frame.frame:SetMinResize(frame.frame:GetWidth(), frame.frame:GetHeight())
--    addon.wtRaidList.frame:SetHeight( rightframe.frame:GetHeight() - 164 )
--    addon.wtRaidGroup.frame:SetHeight( rightframe.frame:GetHeight() - 140 )
    
    -- Close X button for tooltips
    addon.tooltipclosex = CreateFrame("Button", "RC_GUI_TooltipCloseX", frame.frame, "UIPanelCloseButton")
    
    -- Help button
    local helpbutton = CreateFrame("Button", "RC_GUI_Help", frame.frame, "UIPanelButtonTemplate")
    helpbutton:SetHeight(20)
    helpbutton:SetWidth(100)
    helpbutton:SetText( L["button_help"] )
    helpbutton:ClearAllPoints()
    helpbutton:SetPoint("TOPRIGHT", frame.frame, "TOPRIGHT", -15, -15)
    helpbutton:SetScript("OnClick", function() addon:Tooltip_ShowHelp() end)
    frame.helpbutton = helpbutton
    
    -- Realign status bar
    frame:SetStatusText( addon:ColorCode( GRAY_FONT_COLOR_CODE, L["status_viewingraid"] ) )
    --[[
    frame.statusbg:EnableMouse()
    frame.statusbg:SetScript("OnEnter", function() addon:Status_OnEnter(frame.statusbg) end)
    frame.statusbg:SetScript("OnLeave", function() addon:Status_OnLeave(frame.statusbg) end)
    ]]--
    
    -- Hide the frame (creating it made it show)
    frame:Hide()
    
    addon:BuildGUI_DBFrame()
    
    guiready = true
    
    -- Start timers
    addon.CalcLabelTimer = self:ScheduleRepeatingTimer("CalcLabel_Refresh", 60)
    
    -- Register the frame to receive RAID_ROSTER_UPDATE and UNIT_PET events and send them to EventHandler
    frame.frame:RegisterEvent("RAID_ROSTER_UPDATE")
    --frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    frame.frame:RegisterEvent("UNIT_PET")
    frame.frame:SetScript("OnEvent", function(widget, event, arg) addon:EventHandler(widget, event, arg) end )
end

-- This function creates the left hand frame in the main GUI
-- It contains the list of players and the Add Fake and Add Pet buttons
function addon:BuildGUI_LeftFrame()
    -- Create the frame with list of players
    local playerframe = AceGUI:Create("InlineGroup")
    playerframe:SetTitle( format( L["format_raidmembers"], 1, 1 ) )
    addon.wtRaidGroup = playerframe
    playerframe:SetWidth(184)
    
    -- Create a header 'row'
    local row = AceGUI:Create("SimpleGroup")
    row:SetLayout('Flow')
    
    -- Create 4 'columns', playername, class, groupnumber, playerdata
    local player = AceGUI:Create("InteractiveLabel")
    player:SetHighlight(TEX_LABELHIGHLIGHT)
    player:SetWidth(45)
    player:SetText( L["caption_playername"] )
    player:SetCallback("OnClick", function(widget, event) addon:SortRaid_OnClick( widget, "playerName" ) end )
    player:SetColor(1,0.82,0)
    
    local class = AceGUI:Create("InteractiveLabel")
    class:SetHighlight(TEX_LABELHIGHLIGHT)
    class:SetWidth(55)
    class:SetText( L["caption_class"] )
    class:SetCallback("OnClick", function(widget, event) addon:SortRaid_OnClick( widget, "class" ) end )
    class:SetColor(1,0.82,0)
    
    local grnr = AceGUI:Create("InteractiveLabel")
    grnr:SetHighlight(TEX_LABELHIGHLIGHT)
    grnr:SetWidth(25)
    grnr:SetText( L["caption_subgroup"] )
    grnr:SetCallback("OnClick", function(widget, event) addon:SortRaid_OnClick( widget, "subgroup" ) end )
    grnr:SetColor(1,0.82,0)
    
    local playerdata = AceGUI:Create("InteractiveLabel")
    playerdata:SetHighlight(TEX_LABELHIGHLIGHT)
    playerdata:SetWidth(16)
    playerdata:SetText( L["caption_status"] )
    playerdata:SetCallback("OnClick", function(widget, event) addon:SortRaid_OnClick( widget, "code" ) end )
    playerdata:SetColor(1,0.82,0)
    
    row:AddChild(player)
    row:AddChild(class)
    row:AddChild(grnr)
    row:AddChild(playerdata)
    
    playerframe:AddChild(row)
    
    -- Make a group to add players to
    local playerlist = AceGUI:Create("ScrollFrame")
    addon.wtRaidList = playerlist
    playerlist:SetLayout('List')
    playerlist:SetWidth(160)
    playerlist:SetHeight(370)
    --playerlist:SetFullHeight(true)
    playerframe:AddChild(playerlist)
    
    -- Make a small gap and add the buttons 'Fake' and 'Pets'
    local gap = AceGUI:Create("Label")
    gap:SetText(" ")
    gap:SetWidth(50)
    playerframe:AddChild(gap)
    
    local buttonrow = AceGUI:Create("SimpleGroup")
    buttonrow:SetLayout('Flow')
    buttonrow:SetWidth(170)
    
    local addfakebutton = AceGUI:Create("Button")
    addfakebutton:SetText( L["button_addfake"] )
    addfakebutton:SetWidth(79)
    addfakebutton:SetCallback("OnClick", function(widget, event) addon:AddFake_OnClick( widget ) end )
    addon.wtAddFakeButton = addfakebutton
    buttonrow:AddChild(addfakebutton)
    
    local petsbutton = AceGUI:Create("Button")
    petsbutton:SetText( L["button_pets"] )
    petsbutton:SetWidth(78)
    petsbutton:SetCallback("OnClick", function(widget, event) addon:Pets_OnClick( widget ) end )
    addon.wtPetsButton = petsbutton
    buttonrow:AddChild(petsbutton)
    
    local databasebutton = AceGUI:Create("Button")
    databasebutton:SetText( L["button_database"] )
    databasebutton:SetWidth(157)
    databasebutton:SetCallback("OnClick", function(widget, event) addon:Database_OnClick( widget ) end )
    addon.wtDatabaseButton = databasebutton
    buttonrow:AddChild(databasebutton)
    
    playerframe:AddChild(buttonrow)
    
    return playerframe
end

-- This function creates the database window, which contains a list of all players in the RaidComp database
-- From here the user can add "fake" players from the database directly into the comp
function addon:BuildGUI_DBFrame()
    -- Create main database frame
    local dbframe = AceGUI:Create("Frame")
    addon.dbframe = dbframe
    dbframe:SetTitle( L["caption_database"] )
    dbframe:SetLayout('Fill')
    dbframe:SetWidth(424)
    dbframe:SetHeight(580)
    dbframe.frame:SetMinResize(dbframe.frame:GetWidth(), dbframe.frame:GetHeight())
    
    -- Create the frame with list of players
    local playerframe = AceGUI:Create("InlineGroup")
    addon.wtDatabaseGroup = playerframe
    playerframe:SetLayout('List')
    
    -- Create a header 'row'
    local row = AceGUI:Create("SimpleGroup")
    row:SetLayout('Flow')
    --row:SetWidth(350)
    row:SetFullWidth(true)
    
    -- Create 5 'columns', playername, class, mainspec, altspec, last update
    local player = AceGUI:Create("InteractiveLabel")
    player:SetHighlight(TEX_LABELHIGHLIGHT)
    player:SetWidth(45)
    player:SetText( L["caption_playername"] )
    player:SetCallback("OnClick", function(widget, event) addon:SortDatabase_OnClick( widget, "playerName" ) end )
    player:SetColor(1,0.82,0)
    
    local class = AceGUI:Create("InteractiveLabel")
    class:SetHighlight(TEX_LABELHIGHLIGHT)
    class:SetWidth(55)
    class:SetText( L["caption_class"] )
    class:SetCallback("OnClick", function(widget, event) addon:SortDatabase_OnClick( widget, "class" ) end )
    class:SetColor(1,0.82,0)
    
    local mainspec = AceGUI:Create("InteractiveLabel")
    mainspec:SetHighlight(TEX_LABELHIGHLIGHT)
    mainspec:SetWidth(80)
    mainspec:SetText( L["caption_mainspec"] )
    mainspec:SetCallback("OnClick", function(widget, event) addon:SortDatabase_OnClick( widget, "specId" ) end )
    mainspec:SetColor(1,0.82,0)
    
    local altspec = AceGUI:Create("InteractiveLabel")
    altspec:SetHighlight(TEX_LABELHIGHLIGHT)
    altspec:SetWidth(80)
    altspec:SetText( L["caption_altspec"] )
    altspec:SetCallback("OnClick", function(widget, event) addon:SortDatabase_OnClick( widget, "altSpecId" ) end )
    altspec:SetColor(1,0.82,0)
    
    local update = AceGUI:Create("InteractiveLabel")
    update:SetHighlight(TEX_LABELHIGHLIGHT)
    update:SetWidth(80)
    update:SetText( L["caption_update"] )
    update:SetCallback("OnClick", function(widget, event) addon:SortDatabase_OnClick( widget, "updateTime" ) end )
    update:SetColor(1,0.82,0)
    
    row:AddChild(player)
    row:AddChild(class)
    row:AddChild(mainspec)
    row:AddChild(altspec)
    row:AddChild(update)
    
    playerframe:AddChild(row)
    
    -- Make a group to add players to
    local playerlist = AceGUI:Create("ScrollFrame")
    addon.wtDatabaseList = playerlist
    playerlist:SetLayout('List')
    --playerlist:SetWidth(364)
    playerlist:SetFullWidth(true)
    playerlist:SetHeight(460)
    playerframe:AddChild(playerlist)
    
    dbframe:AddChild(playerframe)
    
    -- Hide the frame (creating it made it show)
    dbframe:Hide()
end

-- This function creates the right hand frame in the main GUI
-- It contains the selection options frame at the top and the main RaidComp frame at the bottom
function addon:BuildGUI_RightFrame()
    local rightframe = AceGUI:Create("SimpleGroup")
    rightframe:SetLayout('List')
    rightframe:SetWidth(628)
    
    -- Subframes
    local topframe = addon:BuildGUI_TopFrame()
    rightframe:AddChild( topframe )
    local bottomframe = addon:BuildGUI_BottomFrame()
    rightframe:AddChild( bottomframe )
    
    return rightframe
end

-- This function creates the top right hand frame in the main GUI
-- It contains buttons and checkboxes that allow the user to view a RaidComp based on specific subgroups of players
function addon:BuildGUI_TopFrame()
    local selectframe = AceGUI:Create("InlineGroup")
    selectframe:SetLayout('Flow')
    selectframe:SetWidth(628)
    selectframe:SetTitle( L["caption_selection"] )
    
    -- Mode frame, contains radio buttons to switch between raid and calendar view
    local modeframe = AceGUI:Create("SimpleGroup")
    modeframe:SetLayout('List')
    modeframe:SetWidth(145)
    
    -- Raid radio button, switches to viewing the current raid
    local raidradio = AceGUI:Create("CheckBox")
    raidradio:SetValue(true)
    raidradio:SetType("radio")
    raidradio:SetWidth(145)
    raidradio:SetLabel( L["button_raidmode"] )
    raidradio:SetUserData("mode", "RAID")
    raidradio:SetCallback("OnValueChanged", function(widget, event, value) addon:ModeToggle(widget, value) end )
    modeframe:AddChild(raidradio)
    addon.wtModeRadios[ 1 ] = raidradio
    
    -- Add a small gap
    local gap = AceGUI:Create("Label")
    gap:SetText(" ")
    gap:SetWidth(145)
    modeframe:AddChild(gap)
    
    -- Calendar radio button, switches to viewing the currently selected calendar event
    local calendarradio = AceGUI:Create("CheckBox")
    calendarradio:SetValue(false)
    calendarradio:SetType("radio")
    calendarradio:SetWidth(145)
    calendarradio:SetLabel( L["button_calendarmode"] )
    calendarradio:SetUserData("mode", "CALENDAR")
    calendarradio:SetCallback("OnValueChanged", function(widget, event, value) addon:ModeToggle(widget, value) end )
    modeframe:AddChild(calendarradio)
    addon.wtModeRadios[ 2 ] = calendarradio
    
    selectframe:AddChild(modeframe)
    
    -- Button frame, contains buttons to clear ignores, overrides and fakes
    local buttonframe = AceGUI:Create("SimpleGroup")
    buttonframe:SetLayout('List')
    buttonframe:SetWidth(213)
    
    -- Clear Ignores button, clears the RaidComp ignore list
    local clearignorebutton = AceGUI:Create("Button")
    clearignorebutton:SetHeight(20)
    clearignorebutton:SetWidth(185)
    clearignorebutton:SetText( format( L["format_clearignores"], addon:CountIgnores() ) )
    clearignorebutton:SetCallback("OnClick", function() addon:ClearIgnores() end )
    buttonframe:AddChild(clearignorebutton)
    frame.clearignorebutton = clearignorebutton
    
    -- Add a small gap
    local gap = AceGUI:Create("Label")
    gap:SetText(" ")
    gap:SetWidth(185)
    buttonframe:AddChild(gap)

    -- Clear Overrides button, clears the RaidComp overrides list
    local clearoverridebutton = AceGUI:Create("Button")
    clearoverridebutton:SetHeight(20)
    clearoverridebutton:SetWidth(185)
    clearoverridebutton:SetText( format( L["format_clearoverrides"], addon:CountOverrides() ) )
    clearoverridebutton:SetCallback("OnClick", function() addon:ClearOverrides() end )
    buttonframe:AddChild(clearoverridebutton)
    frame.clearoverridebutton = clearoverridebutton

    -- Add a small gap
    local gap = AceGUI:Create("Label")
    gap:SetText(" ")
    gap:SetWidth(185)
    buttonframe:AddChild(gap)

    -- Clear Fakes button, clears the RaidComp fakes list
    local clearfakebutton = AceGUI:Create("Button")
    clearfakebutton:SetHeight(20)
    clearfakebutton:SetWidth(185)
    clearfakebutton:SetText( format( L["format_clearfakes"], addon:CountFakes() ) )
    clearfakebutton:SetCallback("OnClick", function() addon:ClearFakes() end )
    buttonframe:AddChild(clearfakebutton)
    frame.clearfakebutton = clearfakebutton

    selectframe:AddChild(buttonframe)
    
    -- Group frame, contains checkboxes which allow specific groups or invite statuses to be ignored
    local groupframe = AceGUI:Create("SimpleGroup")
    groupframe:SetLayout('Flow')
    groupframe:SetWidth(250)
    
    -- Create 8 checkboxes and label them
    for i = 1, 8 do
        local checkbox = AceGUI:Create("CheckBox")
        checkbox:SetType("checkbox")
        checkbox:SetTriState(true)
        checkbox:SetValue(nil)
        checkbox:SetWidth(124)
        checkbox:SetLabel(addon:GetCheckboxLabel(i))
        checkbox:SetUserData("index", i)
        checkbox:SetCallback("OnValueChanged", function(widget, event, value) addon:CheckboxToggle(widget, value) end )
        groupframe:AddChild(checkbox)
        addon.wtGroupCheckboxes[ i ] = checkbox
    end
    
    selectframe:AddChild(groupframe)
    
    return selectframe
end

-- This function creates the bottom right hand frame in the main GUI
-- It contains the RaidComp data and is built based on the structure defined in Const_Categories.lua
function addon:BuildGUI_BottomFrame()
    local buffframe = AceGUI:Create("SimpleGroup")
    local role
    buffframe:SetLayout('Flow')
    buffframe:SetWidth(628)
    
    -- For all buff/debuff categories
    for catIndex,catObject in ipairs(addon.CATEGORIES) do
        -- Make a smaller frame
        role = AceGUI:Create("InlineGroup")
        role:SetLayout('List')
        role:SetWidth(157)
        role:SetTitle( L[catObject.catName] )
        
        -- For all items in that category
        for itemIndex,itemName in ipairs(catObject.items) do
            -- Create a 'row'
            local itemrow = AceGUI:Create("SimpleGroup")
            itemrow:SetLayout('Flow')
            itemrow:SetWidth(145)

            if itemName == " " then
                -- Empty line
                local emptyline = AceGUI:Create("Label")
                emptyline:SetText(" ")
                emptyline:SetWidth(135)
                itemrow:AddChild(emptyline)
                
            else
                local itemType = addon.ITEMTYPE[itemName]
                local itemTex = addon:ItemType2Texture( itemType )
            
                -- Buff/debuff icon
                local icon1 = AceGUI:Create("Label")
                icon1:SetImage( addon:ItemType2Texture( itemType ) )
                icon1:SetImageSize(8, 8)
                icon1:SetWidth(15)
                itemrow:AddChild(icon1)
                
                -- Buff/debuff name
                local item = AceGUI:Create("InteractiveLabel")
                if itemName == "Heroism/Bloodlust" then
                    item:SetText( L[itemName..addon.playerfaction] )
                else
                    item:SetText( L[itemName] )
                end
                item:SetColor(0.5, 0.5, 0.5)
                item:SetHighlight(TEX_LABELHIGHLIGHT)
                item:SetWidth(105)
                item:SetUserData("itemName", itemName)
                item:SetUserData("itemType", itemType)
                item:SetCallback("OnClick", function(widget, event, button) addon:BuffItem_OnClick( widget, button ) end )
                item:SetCallback("OnEnter", function(widget, event) addon:BuffItem_OnEnter( widget ) end )
                item:SetCallback("OnLeave", function(widget, event) addon:BuffItem_OnLeave( widget ) end )
                itemrow:AddChild(item)
                addon.wtItemLabels[ itemName ] = item
                
                -- Buff/debuff presence icon
                local icon2 = AceGUI:Create("Label")
                icon2:SetUserData("itemName", itemName)
                icon2:SetUserData("itemType", itemType)
                if itemType == addon.ITEMTYPE_COUNT then
                    icon2:SetText("0")
                    icon2:SetColor(1, 0, 0)
                else
                    icon2:SetImage( TEX_CROSS )
                    icon2:SetImageSize(8, 8)
                end
                icon2:SetWidth(15)
                itemrow:AddChild(icon2)
                addon.wtItemIcons[ itemName ] = icon2
                
                addon.wtItemRows[ itemName ] = itemrow
            end
            
            role:AddChild(itemrow)
        end
        
        buffframe:AddChild(role)
    end
    
    -- Add the CalcFrame at the end, making it the same height as the last role frame
    local calcframe = addon:BuildGUI_CalcFrame()
    calcframe:SetHeight( role.frame:GetHeight() )
    buffframe:AddChild(calcframe)
    
    return buffframe
end

-- This function builds the Talent Scans subframe
-- It is the final subframe in the main GUI and is treated differently to the other subframes
-- It contains the spec breakdown (tanks, melee, etc) and information on the status of talent scans
function addon:BuildGUI_CalcFrame()
    local calcframe = AceGUI:Create("InlineGroup")
    calcframe:SetLayout('List')
    calcframe:SetTitle( L["caption_talentscans"] )
    calcframe:SetWidth(157)
    
    -- For each spec type
    for itemIndex,itemName in ipairs(addon.SPECCATEGORIES) do
        -- Create a 'row'
        local itemrow = AceGUI:Create("SimpleGroup")
        itemrow:SetLayout('Flow')
        itemrow:SetWidth(145)

        if itemName == " " then
            -- Empty line
            local emptyline = AceGUI:Create("Label")
            emptyline:SetText(" ")
            emptyline:SetWidth(135)
            itemrow:AddChild(emptyline)

        else
            local itemType = addon.ITEMTYPE[itemName]
            local itemTex = addon:ItemType2Texture( itemType )
        
            -- Buff/debuff icon
            local icon1 = AceGUI:Create("Label")
            icon1:SetImage( addon:ItemType2Texture( itemType ) )
            icon1:SetImageSize(8, 8)
            icon1:SetWidth(15)
            itemrow:AddChild(icon1)
            
            -- Buff/debuff name
            local item = AceGUI:Create("InteractiveLabel")
            item:SetText( L[itemName] )
            item:SetColor(0.5, 0.5, 0.5)
            item:SetHighlight(TEX_LABELHIGHLIGHT)
            item:SetWidth(105)
            item:SetUserData("itemName", itemName)
            item:SetUserData("itemType", itemType)
            item:SetCallback("OnClick", function(widget, event, button) addon:SpecItem_OnClick( widget, button ) end )
            item:SetCallback("OnEnter", function(widget, event) addon:SpecItem_OnEnter( widget ) end )
            item:SetCallback("OnLeave", function(widget, event) addon:SpecItem_OnLeave( widget ) end )
            itemrow:AddChild(item)
            addon.wtItemLabels[ itemName ] = item
            
            -- Buff/debuff presence icon
            local icon2 = AceGUI:Create("Label")
            icon2:SetUserData("itemName", itemName)
            icon2:SetUserData("itemType", itemType)
            icon2:SetText("0")
            icon2:SetColor(1, 0, 0)
            icon2:SetWidth(15)
            itemrow:AddChild(icon2)
            addon.wtItemIcons[ itemName ] = icon2
            
            addon.wtItemRows[ itemName ] = itemrow
            
        end
        
        calcframe:AddChild(itemrow)
    end

    -- Empty line
    local emptyline = AceGUI:Create("Label")
    emptyline:SetText(" ")
    emptyline:SetWidth(135)
    calcframe:AddChild(emptyline)
    
    -- Create wtCalcLabel, which will show the time since the last update
    local calclabel = AceGUI:Create("Label")
    calclabel:SetWidth(135)
    calclabel:SetText(" ")
    calclabel:SetColor(0.75, 0.75, 0.75)
    calcframe:AddChild( calclabel )
    addon.wtCalcLabel = calclabel
    
    -- Create wtScanLabel, which will show the number of talent scans outstanding
    local scanlabel = AceGUI:Create("Label")
    scanlabel:SetWidth(135)
    scanlabel:SetText(" ")
    scanlabel:SetColor(0.75, 0.75, 0.75)
    calcframe:AddChild( scanlabel )
    addon.wtScanLabel = scanlabel

    -- Create wtDatabaseLabel, which will show the number of talent scans stored in the database
    local databaselabel = AceGUI:Create("Label")
    databaselabel:SetWidth(135)
    databaselabel:SetText(" ")
    databaselabel:SetColor(0.75, 0.75, 0.75)
    calcframe:AddChild( databaselabel )
    addon.wtDatabaseLabel = databaselabel
    
    -- Refresh the labels immediately so that they have some text
    addon:CalcLabel_Refresh()
    
    return calcframe
end
