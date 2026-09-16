local L = LibStub("AceLocale-3.0"):NewLocale("RaidComp", "zhTW")

if L then

-- Core.lua
-- =================================
-- No translations


-- Support.lua
-- =================================
L["FAKE"] = "虛擬"
L["HYBRID"] = "複合"
L["UNKNOWN"] = "未知"

L["time_weeks"] = "周"
L["time_days"] = "日"
L["time_hours"] = "時"
L["time_minutes"] = "分"
L["time_seconds"] = "秒"

-- Classes, not used in Support.lua direct, but seemed like a good place
L["DEATHKNIGHT"] = "死亡騎士"
L["DRUID"] = "德魯伊"
L["HUNTER"] = "獵人"
L["MAGE"] = "法師"
L["PALADIN"] = "聖騎士"
L["PRIEST"] = "牧師"
L["ROGUE"] = "盜賊"
L["SHAMAN"] = "薩滿"
L["WARLOCK"] = "術士"
L["WARRIOR"] = "戰士"

-- Talent Trees, used in addon:GetSpecName(engClass, specId)
L["DEATHKNIGHT1"] = "血魄"
L["DEATHKNIGHT2"] = "冰霜"
L["DEATHKNIGHT3"] = "穢邪"
L["DRUID1"] = "平衡"
L["DRUID2"] = "野性戰鬥"
L["DRUID3"] = "恢復"
L["HUNTER1"] = "野獸控制"
L["HUNTER2"] = "射擊"
L["HUNTER3"] = "生存"
L["MAGE1"] = "秘法"
L["MAGE2"] = "火焰"
L["MAGE3"] = "冰霜"
L["PALADIN1"] = "神聖"
L["PALADIN2"] = "防護"
L["PALADIN3"] = "懲戒"
L["PRIEST1"] = "戒律"
L["PRIEST2"] = "神聖"
L["PRIEST3"] = "暗影"
L["ROGUE1"] = "刺殺"
L["ROGUE2"] = "戰鬥"
L["ROGUE3"] = "敏銳"
L["SHAMAN1"] = "元素"
L["SHAMAN2"] = "增強"
L["SHAMAN3"] = "恢復"
L["WARLOCK1"] = "痛苦"
L["WARLOCK2"] = "惡魔學識"
L["WARLOCK3"] = "毀滅"
L["WARRIOR1"] = "武器"
L["WARRIOR2"] = "狂怒"
L["WARRIOR3"] = "防護"


-- Options.lua
-- =================================
L["menu_version_name"] = "版本 %s"
L["menu_options_name"] = "選項"
L["menu_options_desc"] = "設定 RaidComp."
L["menu_gui_name"] = "開啟 GUI"
L["menu_gui_desc"] = "開啟圖形介面."
L["menu_purgeobsolete_name"] = "清除過期紀錄"
L["menu_purgeobsolete_desc"] = "清除超過九十天的紀錄."
L["menu_purgeobsolete_confirm"] = "你確定要清除掉超過九十天沒有更新的紀錄嗎?"
L["menu_purgerescan_name"] = "清除資料庫並重掃描"
L["menu_purgerescan_desc"] = "清除所有的天賦紀錄並且重新掃描."
L["menu_purgerescan_confirm"] = "你確定要清除所有紀錄並重新掃描目前的團隊嗎?"
L["menu_debug_name"] = "除錯模式"
L["menu_debug_desc"] = "如果開啟, 將會列印除錯訊息以幫助除錯."


-- RaidCheck.lua
-- ==============================
L["format_purgeobsolete"] = "RaidComp 資料庫清理完畢: %s 筆紀錄已被移除."
L["purge_and_rescan"] = "RaidComp 資料庫清理完畢: 所有紀錄已被移除, 開始重掃描."


-- Const_Categories.lua
-- =================================
L["Physical"] = "物理"
L["+Attack Power"] = "+攻擊強度"
L["+10% AP"] = "+10% AP"
L["+Agi & Str"] = "+敏捷與耐力"
L["+5% Melee Crit"] = "+5% 近戰致命"
L["+20% Melee Haste"] = "+20% 近戰加速"
L["-20% Armor"] = "-20% 護甲"
L["-5% Armor"] = "-5% 護甲"
L["+4% Phys. Dam."] = "+4% 物理傷害"
L["+Bleed Damage"] = "+流血傷害"

L["Magical"] = "魔法"
L["+Spell Power"] = "+法術能量"
L["+5% Crit (buff)"] = "+5% 致命 (buff)"
L["+5% Spell Haste"] = "+5% 法術加速"
L["+Intellect"] = "+智力"
L["+Spirit"] = "+精神"
L["+Mana Regen"] = "+法力恢復"
L["+13% Spell Dam."] = "+13% 法術傷害"
L["+5% Crit (debuff)"] = "+5% 致命 (debuff)"
L["+3% Spell Hit"] = "+3% 法術命中"
L["+30% Disease Dam."] = "+30% 疾病傷害"

L["Survival"] = "生存"
L["+Health"] = "+生命力"
L["+Stamina"] = "+耐力"
L["+6% Healing"] = "+6% 治療"
L["+Armor Aura"] = "+護甲光環"
L["+Armor Totem"] = "+護甲圖騰"
L["+25% Armor Proc"] = "+25% 護甲"
L["-3% Dam. Taken"] = "-3% 所受傷害"
L["Healthstone"] = "治療石"
L["-3% Hit Taken"] = "-3% 目標命中"
L["-Attack Power"] = "-攻擊強度"
L["-Attack Speed"] = "-攻擊速度"

L["Multi Purpose"] = "多用途"
L["Heroism/Bloodlust"] = "英勇氣概/嗜血術"
L["Heroism/BloodlustAlliance"] = "英勇氣概"
L["Heroism/BloodlustHorde"] = "嗜血術"
L["+All Stats"] = "+所有屬性"
L["+10% All Stats"] = "+10% 所有屬性"
L["+3% Damage"] = "+3% 傷害"
L["+3% Haste"] = "+3% 速度"
L["+3% Crit"] = "+3% 致命"

L["Situational"] = "環境相關"
L["Shadow Res."] = "暗影抗性"
L["Fire Res."] = "火焰抗性"
L["Frost Res."] = "冰霜抗性"
L["Nature Res."] = "自然抗性"
L["-Healing Received"] = "-治療"
L["-Cast Speed"] = "-施法速度"

L["Count"] = "數量"
L["Replenishment"] = "恢復法力"
L["Remove Magic"] = "移除魔法"
L["Remove Poison"] = "移除中毒"
L["Remove Curse"] = "移除詛咒"
L["Remove Disease"] = "移除疾病"
L["Reduce Damage"] = "減少傷害"
L["Power Restore"] = "恢復能量"
L["Interrupt"] = "中斷"
L["Purge"] = "清除"
L["Remove Enrage"] = "移除狂怒"
L["Remove Protection"] = "移除保護"

L["Crowd Control"] = "場面控制"
L["CC - Humanoid"] = "控場 - 人形"
L["CC - Beast"] = "控場 - 野獸"
L["CC - Dragonkin"] = "控場 - 龍類"
L["CC - Giant"] = "控場 - 巨人"
L["CC - Elemental"] = "控場 - 元素"
L["CC - Demon"] = "控場 - 惡魔"
L["CC - Undead"] = "控場 - 不死"


-- Const_Presets.lua
-- =================================
-- Death Knight
L["Blood DPS"] = "血魄 DPS"
L["Blood Tank"] = "血魄坦克"
L["Frost DPS"] = "冰霜 DPS"
L["Frost Tank"] = "冰霜坦克"
L["Unholy DPS"] = "穢邪 DPS"
L["Unholy Tank"] = "穢邪坦克"
-- Druid
L["Balance"] = "平衡"
L["Feral DPS"] = "野性戰鬥 DPS"
L["Feral Tank"] = "野性戰鬥坦克"
L["Restoration"] = "恢復"
-- Hunter
L["Beast Mastery"] = "野獸控制"
L["Marksmanship"] = "射擊"
L["Survival"] = "生存"
-- Mage
L["Arcane"] = "秘法"
L["Fire"] = "火焰"
L["Frost"] = "冰霜"
-- Paladin
L["Holy"] = "神聖"
L["Protection"] = "防"
L["Retribution"] = "懲戒"
-- Priest
L["Discipline"] = "戒律"
L["Holy"] = "神聖"
L["Shadow"] = "暗影"
-- Rogue
L["Assassination"] = "刺殺"
L["Combat"] = "戰鬥"
L["Subtlety"] = "敏銳"
-- Shaman
L["Elemental"] = "元素"
L["Enhancement"] = "增強"
L["Restoration"] = "恢復"
-- Warlock
L["Affliction"] = "痛苦"
L["Demonology"] = "惡魔學識"
L["Demo-Destro"] = "惡魔毀滅"
L["Destruction"] = "毀滅"
-- Warrior
L["Arms"] = "武器"
L["Fury"] = "狂怒"
L["Protection"] = "狂怒"


-- Player_Fakes.lua
-- =================================
L["format_fakename"] = "虛擬 %s"


-- GUI_Support.lua
-- =================================
L["shortI"] = "|cffff8000".."I"..FONT_COLOR_CODE_CLOSE
L["shortO"] = "|cffffff00".."O"..FONT_COLOR_CODE_CLOSE
L["shortK"] = "|cff00ff00".."K"..FONT_COLOR_CODE_CLOSE
L["shortS"] = "|cff0080ff".."S"..FONT_COLOR_CODE_CLOSE
L["shortT"] = "|cffffff80".."T"..FONT_COLOR_CODE_CLOSE
L["shortM"] = "|cffff0000".."M"..FONT_COLOR_CODE_CLOSE
L["shortF"] = "|cffff00ff".."F"..FONT_COLOR_CODE_CLOSE

L["longI"] = "|cffff8000".."I"..FONT_COLOR_CODE_CLOSE.."忽略"
L["longO"] = "|cffffff00".."O"..FONT_COLOR_CODE_CLOSE.."複寫"
L["longK"] = "O".."|cff00ff00".."K"..FONT_COLOR_CODE_CLOSE
L["longS"] = "|cff0080ff".."S"..FONT_COLOR_CODE_CLOSE.."排序"
L["longT"] = "|cffffff80".."T"..FONT_COLOR_CODE_CLOSE.."暫存"
L["longM"] = "|cffff0000".."M"..FONT_COLOR_CODE_CLOSE.."找不到"
L["longF"] = "|cffff00ff".."F"..FONT_COLOR_CODE_CLOSE.."偽玩家"


-- Calendar.lua
-- =================================
L["shortInvited"] = "|cffffff00".."I"..FONT_COLOR_CODE_CLOSE
L["shortAccepted"] = "|cff00ff00".."A"..FONT_COLOR_CODE_CLOSE
L["shortDeclined"] = "|cffff0000".."D"..FONT_COLOR_CODE_CLOSE
L["shortConfirmed"] = "|cff00ff00".."C"..FONT_COLOR_CODE_CLOSE
L["shortOut"] = "|cffff0000".."O"..FONT_COLOR_CODE_CLOSE
L["shortStandby"] = "|cffff8000".."B"..FONT_COLOR_CODE_CLOSE
L["shortSignedUp"] = "|cffffff00".."S"..FONT_COLOR_CODE_CLOSE
L["shortNotSignedUp"] = "|cffff0000".."N"..FONT_COLOR_CODE_CLOSE
L["shortTentative"] = "|cffff8000".."T"..FONT_COLOR_CODE_CLOSE

L["longInvited"] = "|cffffff00".."I"..FONT_COLOR_CODE_CLOSE.."已邀請"
L["longAccepted"] = "|cff00ff00".."A"..FONT_COLOR_CODE_CLOSE.."已接受"
L["longDeclined"] = "|cffff0000".."D"..FONT_COLOR_CODE_CLOSE.."已拒絕"
L["longConfirmed"] = "|cff00ff00".."C"..FONT_COLOR_CODE_CLOSE.."已確認"
L["longOut"] = "|cffff0000".."O"..FONT_COLOR_CODE_CLOSE.."外出"
L["longStandby"] = "|cffff8000".."B"..FONT_COLOR_CODE_CLOSE.."待命"
L["longSignedUp"] = "|cffffff00".."S"..FONT_COLOR_CODE_CLOSE.."已報名"
L["longNotSignedUp"] = "|cffff0000".."N"..FONT_COLOR_CODE_CLOSE.."未報名"
L["longTentative"] = "|cffff8000".."T"..FONT_COLOR_CODE_CLOSE.."考慮中"

L["status_viewingraid"] = "檢視目前團隊"
L["format_status_event"] = "正在檢視 %s (%s) %s 的行事曆事件"
L["format_status_announcement"] = "已選擇公會佈告 (%s)"
L["format_status_system"] = "已選取行事曆事件 (%s)"
L["status_noevent"] = "尚未選取行事曆中的事件"

L["format_createdby"] = "由 %s 建立"


-- GUI_Events.lua
-- =================================
L["tooltip_shift+click"] = "shift+點擊"
L["tooltip_ctrl+click"] = "ctrl+點擊"
L["tooltip_alt+click"] = "alt+點擊"
L["tooltip_removefake"] = "移除虛擬"
L["tooltip_unignore"] = "不忽略"
L["tooltip_ignore"] = "忽略"
L["tooltip_override"] = "複寫"
L["tooltip_altoverride"] = "第二天賦複寫"
L["tooltip_clearoverride"] = "清除複寫"
L["tooltip_temporary"] = "設定臨時資料"
L["tooltip_cleartemporary"] = "清除臨時資料"

L["format_timetooltip"] = "(%s 之前更新)"

L["format_providedby"] = "由 %s 提供"
L["format_providedbytalent"] = "由 %s 提供(天賦)"

L["tooltip_petability"] = "(寵物能力)"

L["format_report_sourcesof"] = "RaidComp 報告 - %s 的來源"
L["format_report_specs"] = "RaidComp 報告 - %s"
L["format_report_spell"] = "* %s (%s) - %s"
L["format_report_petability"] = "* %s (%s (Pet)) - %s"
L["format_report_spec"] = "* %s - %s"
L["report_none"] = "無"

L["pet_worm"] = "蟲類型"
L["pet_wasp"] = "蜂類型"
L["pet_corehound"] = "熔核犬類型"
L["pet_carrionbird"] = "鳥類型"
L["pet_rhino"] = "犀牛類型"
L["pet_imp"] = "小鬼"
L["pet_felhunter"] = "惡魔獵犬"

L["tooltip_addasfake"] = "新增為虛擬"
L["tooltip_addaltasfake"] = "新增第二天賦為虛擬"


-- GUI.lua
-- =================================
L["button_close"] = "關閉"
L["button_help"] = "幫助"

L["caption_selection"] = "選擇玩家"
L["button_raidmode"] = "檢視團隊"
L["button_calendarmode"] = "檢視行事曆"
L["format_clearignores"] = "清除忽略 (%s)"
L["format_clearoverrides"] = "清除複寫 (%s)"
L["format_clearfakes"] = "清除虛擬 (%s)"
L["format_checkboxgroup"] = "小隊 %s"

L["format_raidmembers"] = "團隊成員 (%s/%s)"
L["caption_playername"] = "名稱"
L["caption_class"] = "(職業)"
L["caption_subgroup"] = "  #"
L["caption_status"] = "@"
L["caption_mainspec"] = "目前天賦"
L["caption_altspec"] = "第二天賦"
L["caption_update"] = "上次更新"
L["button_addfake"] = "虛擬"
L["button_pets"] = "寵物"
L["button_database"] = "資料庫"

L["caption_buffs"] = "Buffs / Debuffs"

L["caption_talentscans"] = "天賦掃描"
L["Tanks"] = "坦克"
L["Melee DPS"] = "近戰 DPS"
L["Ranged DPS"] = "遠程 DPS"
L["Healers"] = "治療"
L["format_timedifference"] = "更新: %s 之前"
L["format_scanspending"] = "待掃描: %s / %s"
L["format_dbentries"] = "資料庫: %s"

L["caption_database"] = "RaidComp 資料庫"
L["caption_databaserecords"] = "資料庫紀錄"
L["format_timeold"] = "%s 之前"
L["format_status_database"] = "%s 筆玩家紀錄在資料庫"


-- GUI_Support.lua   HELP TOOLTIP
-- ==============================
L["help1"] = "這個對話框裡包含簡短的概要說明使用的圖示與縮寫."
L["help2"] = "需要更詳盡的幫助請參閱 'wow.curseforge.com/addons/arc/'"

L["help3"] = "圖示的種類:"
L["help_buff"] = "在這個類別中的法術是 Buff."
L["help_debuff"] = "在這個類別中的法術是 Debuff."
L["help_dot"] = "在這個類別中的是 '數量'."

L["help4"] = "代表該種類 buff/debuff 存在的圖示:"
L["help_check"] = "buff/debuff 存在於這個團隊."
L["help_nonoptimal"] = "buff/debuff 存在, 但不是該類別中最好的."
L["help_nonoptimal_ex1"] = "範例: 凜冬號角給團隊的敏捷與力量"
L["help_nonoptimal_ex2"] = "    比有天賦加持的大地之力圖騰少."
L["help_maybe"] = "Buff 可以存在, 但是會排斥另一個."
L["help_maybe_ex1"] = "範例: 薩滿無法同時間使用風怒圖騰"
L["help_maybe_ex2"] = "    與風懲圖騰."
L["help_cross"] = "Buff/Debuff 不存在這個團隊."

L["help5"] = "用來標記玩家狀態的代碼:"
L["help_ignore"] = "該玩家將會被忽略不做計算."
L["help_override"] = "你所指定的資料將會複寫已儲存的資料."
L["help_ok"] = "該玩家的天賦在最近15分鐘內被掃描過."
L["help_stored"] = "該玩家的天賦資料超過15分鐘前."
L["help_temporary"] = "使用自訂資料直到該玩家被掃描."
L["help_missing"] = "沒有該玩家的天賦資料."
L["help_fake"] = "該玩家並不實際存在."

end
