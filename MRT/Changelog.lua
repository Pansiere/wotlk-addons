local GlobalAddonName, ExRT = ...

ExRT.Options.Changelog = [=[
v5.1.4-WotLK335a
* Fixes
* Note: added Help info
* Reminder: added Help info
* Raid Cooldowns: changed cooldowns for some spells

v5.1.3-WotLK335a
* Fixes
* Note: added other icons

 v5.1.2-WotLK335a
 * Fixes

v5.1.1-WotLK335a
* Fixes

v5.1.0-WotLK335a
* Fixes
* Timers: Dynamic timers enabled for only left click on Marks Bar (right click will show static timers as before)

v5.0.9-WotLK335a
* Fixes

v5.0.8-WotLK335a
* Fixes
* Raid Cooldowns: fixes talent detection
* Reminder: update to 71 version
* Visual note: add checkbox Fix Area

v5.0.7-WotLK335a
* Fixes
* Reminde: Update timeline 
* Performance improved

v5.0.6-WotLK335a
* Fixes
* Note: Improved Autoloaded before Boss
* Raid Cooldowns: Fixed spell detection (talent)

v5.0.5-WotLK335a
* Fixes
* Raid Cooldown - Icon style new futures

v5.0.4-WotLK335a
* Fixes
* Visual Note: Transition from local .tga map to global .blp map for WotLK zones

v5.0.3-WotLK335a
* Fixes
* UPM bridge inlined

v5.0.2-WotLK335a
* Interface Options click reopens /mrt
* UnifiedProfileManager profile bridge

v5.0.1-WotLK335a
* CallbackHandler conflict fix
* NumPad input fix

v5.0.0-WotLK335a
* All modules have been backported
* Timers from DBM have been added to Reminder
* Caps for collecting Fight Log have been updated

v.5230
* Added Midnight beta support
* Fixes

v.5220
* Note: option "Hide lines with timers but without my name" now also hides names of other players in shown line (for Name {spell:X} formatting)
* Raid check: added Soulgorged Augment Rune support
* Fixes

v.5220-MoP
* Fixes for autochange loot distribution

v.5215
* Added Ethereal Augment Rune support
* Data updates
* Fixes

v.5210
* Data updates

v.5210-MoP
* Fixes

v.5205
* Data updates

v.5205-MoP
* Fixes

v.5200
* 11.2 update

v.5200-MoP
* Readded "Bonus Loot" module

v.5195
* Minor updates

v.5195-MoP
* Raid Check: updated MoP raid buffs

v.5190
* Fixes

v.5190-MoP
* Fixes
* MoP updates

v.5181
* Pull timer fix

v.5180
* Fixes
* 11.1.7 update

v.5180-MoP
* 5.5.0 Update

v.5160
* 11.1.5 update

v.5150
* Reminder: added timelines for Liberation of Undermine mythic bosses
* Raid check: added custom ilvl column
* Raid check: added sort by name

v.5140
* Note: added autoload support for Liberation of Undermine
* Reminder: updated timelines for Liberation of Undermine HC bosses

v.5120
* 11.1 update
* Raid groups: added "split raid" option
* Note: added "text align" option
* Reminder: added option to send timeline history after boss fight

v.5100
* Reminder: you can directly select only boss from recorded m+ run
* Reminder: added players from custom roster to advanced settings window if it opened via shift-click on assignments page with "custom roster" selected
* Raid Cooldowns: added custom icon option for spells that was added by users
* Loot History: added icon for roll type (need/greed/transmog/pass)
* Added profiling
* Fixes

v.5080
* Reminder: changed load conditions logic for reminders with both boss+zone load
* Reminder: "assignments"/"timeline": added dungeon bosses to list
* Raid groups: server name in not required
* Raid Inspect: added option to set custom minimum ilvl for highlight
* Interrupts: added option to autoreset based on maximum assigned number for each mark (be sure that your assigned kickers have v5080+ before using this option)
* Note: added custom roster
* Note: added role icons for tanks and healers for list with names
* Fixes

v.5060
* Reminder: "assignments": added "live session" option (multiple people can add/remove/change reminders at same time with immediate progress visualisation)
* Reminder: "assignments": added option for filtering existed reminders with same filter as enabled spell groups (enabled by default)
* Reminder: "assignments": added charges support (right click on spell from right menu to setup number of chargers for spell)
* Reminder: "assignments": added option to add custom spells to class list
* Reminder: overhauled load conditions for names/class/roles/note pattern (now all need to met (if any) instead of any)
* Reminder: rework for sharing method. Now shared profile and selected personal profile can be active together. Current reminders from shared profile moved to profile#6
* Reminder: added option for custom icon size in text
* Reminder: added option for custom text size on raidframe/nameplate
* WeakAuras checks: quickshare button will send selected wa to players with no wa/different version of wa
* Fixes

v.5040
* Reminder: added "assignments" page for quick raid cooldowns organization for your roster
* Reminder: queen ansurek p3 start was moved (only for timeline, reminders are unaffected)
* WeakAuras checks: now able to check if aura is same
* Note: added option for using autoload for personal note
* Fixes

v.5020
* Reminder: added "sound delay" option
* Raid groups: added option "Keep changes" for autosave any editing for selected preset
* Fixes

v.5005
* Raid Inspect: added "cheap" option for minimum rank for gems/enchants
* Major fixes

v.5000
* Raid Inspect: added option for minimum rank for gems/enchants
* Fixes

v.4990
* Reminder: added option to grow upwards
* Raid Check: add option for using only unlimited rune (old one for now)
* Raid Check: add option for using custom oil itemid
* Fixes

v.4990-Cata
* Reminder: added option to grow upwards
* Fixes

v.4980
* Reminder: timeline updates
* Reminder: added m+ support
* Note: added option to autoload note before boss
* Fixes

v.4980-Cata
* Note: added option to autoload note before boss
* Reminder: added "boss timeline" feature with simplified setup and quick exchange to/from notes
* Raid Cooldowns: added option to grow by columns
* Raid Cooldowns: added option for animation style "Starts Full for active and empty for cd"
* Fixes

v.4960
* Reminder: added option to show message before timer ends instead of after. This option is enabled by default for new reminders from "boss timeline"
* Reminder: updates
* Raid Cooldowns: added option to grow by columns

v.4950
* Reminder: added "boss timeline" feature with simplified setup and quick exchange to/from notes
* Raid Cooldowns: added option for animation style "Starts Full for active and empty for cd"

v.4930
* Reminder: added triggers test tab
* Saving log: fixed Grim Batol logging
* Raid Check: added support for more weapon buffs
* Fixes

v.4920
* Raid Check: TWW updates

v.4910
* Fixes

v.4900
* Raid cooldowns: added "column for raid/party role" option
* Fixes

v.4900-Cata
* Raid cooldowns: added "column for raid/party role" option

v.4890
* TWW updates

v.4880
* Fixes for 11.0 beta
* Added Italian translation (by Grifo92)
* Reminder: added load condition: always
* Minor fixes

v.4870
* Note: added profiles
* Reminder: all bosses are grouped in instance folders
* Minor fixes

v.4870-Cata
* Note: added profiles
* Minor fixes

v.4870-Classic
* Note: added profiles
* Minor fixes

v.4860
* toc update
* Raid cooldowns: added "Add spell" for class categories
* Raid Groups: added role icons

v.4860-Cata
* fixes
* Raid Groups: added role icons

v.4850
* Minor fixes

v.4850-Cata
* Cataclysm update
* Raid cooldowns: added new spells
* Marks Bar: added world marks
* Note: added support for spec role
* Inspect viewer: added specs

v.4850-Classic
* Minor fixes
* toc update

v.4840
* New module: Reminder
* Minor fixes

v.4840-LK
* New module: Reminder
* Minor fixes
]=]
