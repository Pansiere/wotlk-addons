local addon = RaidComp
local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)

addon.DEFAULTCOORDS = {0, 1, 0, 1}

-- Addon options table
-- ===================
addon.options = {
    name = addon.ADDONTITLE,
    handler = addon,
    type = 'group',
    args = {
        gui = {
            -- Button to open the GUI
            type = 'execute',
            name = L["menu_gui_name"],
            desc = L["menu_gui_desc"],
            func = function(info) addon:OpenGUI() end,
            order = 1,
        },
        sep1 = {
            -- Separator
            type = 'description',
            name = " ",
            order = 2,
        },
        version = {
            type = 'description',
            name = format( L["menu_version_name"], addon.VERSION),
            order = 1,
        },
        sep2 = {
            type = 'description',
            name = " ",
            order = 2,
        },
        options = {
            type = 'group',
            name = L["menu_options_name"],
            desc = L["menu_options_desc"],
            cmdHidden = true,
            order = 3,
            args = {
                purgeobsolete = {
                    -- Button to purge obsolete records from the database
                    type = 'execute',
                    name = L["menu_purgeobsolete_name"],
                    desc = L["menu_purgeobsolete_desc"],
                    width = "full",
                    confirm = true,
                    confirmText = L["menu_purgeobsolete_confirm"],
                    func = function(info) addon:PurgeObsolete() end,
                    order = 3,
                },
                sep2 = {
                    -- Separator
                    type = 'description',
                    name = " ",
                    order = 4,
                },
                purgerescan = {
                    -- Button to purge and rescan the database
                    type = 'execute',
                    name = L["menu_purgerescan_name"],
                    desc = L["menu_purgerescan_desc"],
                    width = "full",
                    confirm = true,
                    confirmText = L["menu_purgerescan_confirm"],
                    func = function(info) addon:PurgeAndRescan() end,
                    order = 5,
                },
                sep3 = {
                    -- Separator
                    type = 'description',
                    name = " ",
                    order = 6,
                },
                debug = {
                    -- Checkbox to toggle debug mode on and off
                    type = 'toggle',
                    name = L["menu_debug_name"],
                    desc = L["menu_debug_desc"],
                    get = function(info) return addon.db.profile.debug end,
                    set = function(info, v) addon.db.profile.debug = v end,
                    order = 7,
                },
                sep4 = {
                    -- Separator
                    type = 'description',
                    name = " ",
                    order = 8,
                },
                test = {
                    -- Hidden button to run Test function - unhide if needed
                    type = 'execute',
                    name = "test",
                    desc = "test",
                    func = function(info) addon:Test() end,
                    order = 9,
                    hidden = true,
                },
            },
        },
    },
}

addon.dbDefaults = {
    profile = {
        debug = false,
    },
    factionrealm = {
        lastCalc = -1,
        raidDB = { },
        altDB = { },
        fakeDB = { },
        fakeNextID = 0,
        ignoreDB = { },
        customDB = { },
        petDB = { },
        overrideDB = { },
    },
}

function addon:Test()
    addon:Print("Test")
end
