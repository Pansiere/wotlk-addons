-- Addon Declaration
-- =================
local ADDONNAME = "RaidComp"
RaidComp = LibStub("AceAddon-3.0"):NewAddon(ADDONNAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local addon = RaidComp
addon.ADDONNAME = ADDONNAME
addon.VERSION = "beta4.10"

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

-- Addon constants
local ADDONTITLE = "RaidComp"
addon.ADDONTITLE = ADDONTITLE
addon.IMAGEPATH = "Interface\\AddOns\\RaidComp\\images\\"

-- Locale
local L = LibStub("AceLocale-3.0"):GetLocale(ADDONNAME, true)


-- Addon OnInitialize, OnEnable, OnDisable
-- =======================================

-- Code that you want to run when the addon is first loaded goes here.
function addon:OnInitialize()
    -- AceDB
    self.db = LibStub("AceDB-3.0"):New("RaidCompDB", addon.dbDefaults)
    addon.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    -- AceConfig/AceConsole
    LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDONNAME, addon.options, {"raidcomp", "rc"})
    
    -- Add to Blizzard Options
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDONNAME, ADDONTITLE)
    
    -- DataBroker
    ldb:NewDataObject(ADDONNAME, {
        type = "launcher",
        label = addon.ADDONTITLE,
        icon = addon.IMAGEPATH.."icon",
        OnClick = function(clickedframe, button)
            addon:OpenGUI()
        end,
    })
    
    addon.playerfaction = "Alliance"
    
--    addon:PrDebug("OnInitialize")
end

-- Called when the addon is enabled
function addon:OnEnable()
    addon.playerfaction = UnitFactionGroup('player')

--    addon:PrDebug("OnEnable")
end

-- Called when the addon is disabled
function addon:OnDisable()
    -- Destroy GUI
    addon:DestroyGUI()

--    addon:PrDebug("OnDisable")
end
