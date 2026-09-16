local L = LibStub("AceLocale-3.0"):NewLocale("RaidComp", "zhCN")

if L then

-- Core.lua
-- =================================
-- No translations


-- Support.lua
-- =================================
L["FAKE"] = "虚拟"
L["HYBRID"] = "混合"
L["UNKNOWN"] = "未知"

L["time_weeks"] = "星期"
L["time_days"] = "天"
L["time_hours"] = "小时"
L["time_minutes"] = "分"
L["time_seconds"] = "秒"

-- Classes, not used in Support.lua direct, but seemed like a good place
L["DEATHKNIGHT"] = "死骑"
L["DRUID"] = "小德"
L["HUNTER"] = "猎人"
L["MAGE"] = "法师"
L["PALADIN"] = "骑士"
L["PRIEST"] = "牧师"
L["ROGUE"] = "盗贼"
L["SHAMAN"] = "萨满"
L["WARLOCK"] = "术士"
L["WARRIOR"] = "战士"

-- Talent Trees, used in addon:GetSpecName(engClass, specId)
L["DEATHKNIGHT1"] = "鲜血"
L["DEATHKNIGHT2"] = "冰霜"
L["DEATHKNIGHT3"] = "堕落"
L["DRUID1"] = "平衡"
L["DRUID2"] = "野性"
L["DRUID3"] = "恢复"
L["HUNTER1"] = "兽王"
L["HUNTER2"] = "射击"
L["HUNTER3"] = "生存"
L["MAGE1"] = "奥法"
L["MAGE2"] = "火法"
L["MAGE3"] = "冰法"
L["PALADIN1"] = "奶骑"
L["PALADIN2"] = "防骑"
L["PALADIN3"] = "惩戒"
L["PRIEST1"] = "戒牧"
L["PRIEST2"] = "神牧"
L["PRIEST3"] = "暗牧"
L["ROGUE1"] = "刺杀"
L["ROGUE2"] = "战斗"
L["ROGUE3"] = "敏锐"
L["SHAMAN1"] = "元素"
L["SHAMAN2"] = "增强"
L["SHAMAN3"] = "奶萨"
L["WARLOCK1"] = "痛苦"
L["WARLOCK2"] = "恶魔"
L["WARLOCK3"] = "毁灭"
L["WARRIOR1"] = "武器"
L["WARRIOR2"] = "狂暴"
L["WARRIOR3"] = "防战"


-- Options.lua
-- =================================
L["menu_version_name"] = "版本 %s"
L["menu_options_name"] = "设置"
L["menu_options_desc"] = "RaidComp设置."
L["menu_gui_name"] = "开启界面"
L["menu_gui_desc"] = "开启图形界面."
L["menu_purgeobsolete_name"] = "清除过期数据"
L["menu_purgeobsolete_desc"] = "从内部数据库中清除90天以上未更新的数据."
L["menu_purgeobsolete_confirm"] = "您确定要清除90天以上未更新的数据么?"
L["menu_purgerescan_name"] = "清理数据库并重新扫描"
L["menu_purgerescan_desc"] = "清理数据并预定扫描."
L["menu_purgerescan_confirm"] = "您确定要清除数据并对当前团队进行重新扫描么?"
L["menu_debug_name"] = "调试模式"
L["menu_debug_desc"] = "启动后，将显示调试信息."


-- RaidCheck.lua
-- ==============================
L["format_purgeobsolete"] = "RaidComp 数据清理完成: %s 条记录被移除."
L["purge_and_rescan"] = "RaidComp 数据清理完成: 所有记录已被清除，开始重新扫描."


-- Const_Categories.lua
-- =================================
L["Physical"] = "物理"
L["+Attack Power"] = "+攻强"
L["+10% AP"] = "+10% 攻强"
L["+Agi & Str"] = "+力量，敏捷"
L["+5% Melee Crit"] = "+5% 物暴"
L["+20% Melee Haste"] = "+20% 极速"
L["-20% Armor"] = "-20% 护甲"
L["-5% Armor"] = "-5% 护甲"
L["+4% Phys. Dam."] = "+4% 物伤"
L["+Bleed Damage"] = "+流血"

L["Magical"] = "法术"
L["+Spell Power"] = "+法强"
L["+5% Crit (buff)"] = "+5% 暴击"
L["+5% Spell Haste"] = "+5% 极速"
L["+Intellect"] = "+智力"
L["+Spirit"] = "+精神"
L["+Mana Regen"] = "+回蓝"
L["+13% Spell Dam."] = "+13% 法伤"
L["+5% Crit (debuff)"] = "+5% 暴击"
L["+3% Spell Hit"] = "+3% 命中"
L["+30% Disease Dam."] = "+30% 疾病伤害"

L["Survival"] = "生存"
L["+Health"] = "+生命"
L["+Stamina"] = "+耐力"
L["+6% Healing"] = "+6% 治疗"
L["+Armor Aura"] = "+护甲 光环"
L["+Armor Totem"] = "+护甲 图腾"
L["+25% Armor Proc"] = "+25% 护甲"
L["-3% Dam. Taken"] = "-3% 承受伤害"
L["Healthstone"] = "治疗石"
L["-3% Hit Taken"] = "-3% 被命中"
L["-Attack Power"] = "-攻强"
L["-Attack Speed"] = "-攻速"

L["Multi Purpose"] = "多功能"
L["Heroism/Bloodlust"] = "嗜血/英勇"
L["Heroism/BloodlustAlliance"] = "英勇"
L["Heroism/BloodlustHorde"] = "嗜血"
L["+All Stats"] = "+全属性"
L["+10% All Stats"] = "+10% 全属性"
L["+3% Damage"] = "+3% 伤害"
L["+3% Haste"] = "+3% 极速"
L["+3% Crit"] = "+3% 暴击"

L["Situational"] = "特殊状况"
L["Shadow Res."] = "暗抗"
L["Fire Res."] = "火抗"
L["Frost Res."] = "冰抗"
L["Nature Res."] = "自然抗"
L["-Healing Received"] = "-治疗"
L["-Cast Speed"] = "-施法速度"

L["Count"] = "其他"
L["Replenishment"] = "回蓝"
L["Remove Magic"] = "解魔法"
L["Remove Poison"] = "解毒"
L["Remove Curse"] = "解诅咒"
L["Remove Disease"] = "解疾病"
L["Reduce Damage"] = "免伤"
L["Power Restore"] = "能量回复"
L["Interrupt"] = "打断"
L["Purge"] = "进攻驱散"
L["Remove Enrage"] = "宁神"
L["Remove Protection"] = "破无敌"

L["Crowd Control"] = "控制"
L["CC - Humanoid"] = "人形"
L["CC - Beast"] = "野兽"
L["CC - Dragonkin"] = "龙类"
L["CC - Giant"] = "巨人"
L["CC - Elemental"] = "元素"
L["CC - Demon"] = "恶魔"
L["CC - Undead"] = "亡灵"


-- Const_Presets.lua
-- =================================
-- Death Knight
L["Blood DPS"] = "鲜血输出"
L["Blood Tank"] = "鲜血坦克"
L["Frost DPS"] = "冰霜输出"
L["Frost Tank"] = "冰霜坦克"
L["Unholy DPS"] = "堕落输出"
L["Unholy Tank"] = "堕落坦克"
-- Druid
L["Balance"] = "鸟德"
L["Feral DPS"] = "野德输出"
L["Feral Tank"] = "野德坦克"
L["Restoration"] = "奶德"
-- Hunter
L["Beast Mastery"] = "兽王"
L["Marksmanship"] = "射击"
L["Survival"] = "生存"
-- Mage
L["Arcane"] = "奥法"
L["Fire"] = "火法"
L["Frost"] = "冰法"
-- Paladin
L["Holy"] = "奶骑"
L["Protection"] = "防骑"
L["Retribution"] = "惩戒"
-- Priest
L["Discipline"] = "戒牧"
L["Holy"] = "神牧"
L["Shadow"] = "暗牧"
-- Rogue
L["Assassination"] = "刺杀"
L["Combat"] = "战斗"
L["Subtlety"] = "敏锐"
-- Shaman
L["Elemental"] = "元素"
L["Enhancement"] = "增强"
L["Restoration"] = "奶萨"
-- Warlock
L["Affliction"] = "痛苦"
L["Demonology"] = "恶魔"
L["Demo-Destro"] = "恶毁"
L["Destruction"] = "毁灭"
-- Warrior
L["Arms"] = "武器"
L["Fury"] = "狂暴"
L["Protection"] = "防战"


-- Player_Fakes.lua
-- =================================
L["format_fakename"] = "虚拟 %s"


-- GUI_Support.lua
-- =================================
L["shortI"] = "|cffff8000".."I"..FONT_COLOR_CODE_CLOSE
L["shortO"] = "|cffffff00".."O"..FONT_COLOR_CODE_CLOSE
L["shortK"] = "|cff00ff00".."K"..FONT_COLOR_CODE_CLOSE
L["shortS"] = "|cff0080ff".."S"..FONT_COLOR_CODE_CLOSE
L["shortT"] = "|cffffff80".."T"..FONT_COLOR_CODE_CLOSE
L["shortM"] = "|cffff0000".."M"..FONT_COLOR_CODE_CLOSE
L["shortF"] = "|cffff00ff".."F"..FONT_COLOR_CODE_CLOSE

L["longI"] = "|cffff8000".."I "..FONT_COLOR_CODE_CLOSE.."忽略"
L["longO"] = "|cffffff00".."O "..FONT_COLOR_CODE_CLOSE.."指定"
L["longK"] = "|cff00ff00".."K "..FONT_COLOR_CODE_CLOSE.."正常"
L["longS"] = "|cff0080ff".."S "..FONT_COLOR_CODE_CLOSE.."储存"
L["longT"] = "|cffffff80".."T "..FONT_COLOR_CODE_CLOSE.."临时"
L["longM"] = "|cffff0000".."M "..FONT_COLOR_CODE_CLOSE.."缺失"
L["longF"] = "|cffff00ff".."F "..FONT_COLOR_CODE_CLOSE.."虚拟"


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

L["longInvited"] = "|cffffff00".."I "..FONT_COLOR_CODE_CLOSE.."已邀请"
L["longAccepted"] = "|cff00ff00".."A "..FONT_COLOR_CODE_CLOSE.."已接受"
L["longDeclined"] = "|cffff0000".."D "..FONT_COLOR_CODE_CLOSE.."已拒绝"
L["longConfirmed"] = "|cff00ff00".."C "..FONT_COLOR_CODE_CLOSE.."已确认"
L["longOut"] = "|cffff0000".."O "..FONT_COLOR_CODE_CLOSE.."外出"
L["longStandby"] = "|cffff8000".."B "..FONT_COLOR_CODE_CLOSE.."待命"
L["longSignedUp"] = "|cffffff00".."S "..FONT_COLOR_CODE_CLOSE.."已登记"
L["longNotSignedUp"] = "|cffff0000".."N "..FONT_COLOR_CODE_CLOSE.."未登记"
L["longTentative"] = "|cffff8000".."T"..FONT_COLOR_CODE_CLOSE.."试用"

L["status_viewingraid"] = "查看现有RAID"
L["format_status_event"] = "查看日历事件于 %s (%s) 在 %s"
L["format_status_announcement"] = "公会公告 (%s) 已选定"
L["format_status_system"] = "日历事件 (%s) 已选定"
L["status_noevent"] = "没有日历事件被选定"

L["format_createdby"] = "由 %s 添加"


-- GUI_Events.lua
-- =================================
L["tooltip_shift+click"] = "shift+点击"
L["tooltip_ctrl+click"] = "ctrl+点击"
L["tooltip_alt+click"] = "alt+点击"
L["tooltip_removefake"] = "移除虚拟"
L["tooltip_unignore"] = "取消忽略"
L["tooltip_ignore"] = "忽略"
L["tooltip_override"] = "手动指定"
L["tooltip_altoverride"] = "第二天赋指定"
L["tooltip_clearoverride"] = "取消指定"
L["tooltip_temporary"] = "设定临时数据"
L["tooltip_cleartemporary"] = "删除临时数据"

L["format_timetooltip"] = "(%s 前更新)"

L["format_providedby"] = "由 %s 提供"
L["format_providedbytalent"] = "由 %s (天赋)提供"

L["tooltip_petability"] = "(宠物技能)"

L["format_report_sourcesof"] = "RaidComp 报告 - 来源报告 %s"
L["format_report_specs"] = "RaidComp 报告 - %s"
L["format_report_spell"] = "* %s (%s) - %s"
L["format_report_petability"] = "* %s (%s (宠物)) - %s"
L["format_report_spec"] = "* %s - %s"
L["report_none"] = "无"

L["pet_worm"] = "蠕虫"
L["pet_wasp"] = "黄蜂"
L["pet_corehound"] = "熔岩犬"
L["pet_carrionbird"] = "鸟类"
L["pet_rhino"] = "犀牛"
L["pet_imp"] = "小鬼"
L["pet_felhunter"] = "地狱犬"

L["tooltip_addasfake"] = "作为虚拟添加"
L["tooltip_addaltasfake"] = "以附天赋作为虚拟添加"


-- GUI.lua
-- =================================
L["button_close"] = "关闭"
L["button_help"] = "帮助"

L["caption_selection"] = "玩家选择"
L["button_raidmode"] = "查看团队"
L["button_calendarmode"] = "查看日历"
L["format_clearignores"] = "清除忽略 (%s)"
L["format_clearoverrides"] = "清除覆盖 (%s)"
L["format_clearfakes"] = "清除虚拟 (%s)"
L["format_checkboxgroup"] = "Raid 分组 %s"

L["format_raidmembers"] = "团队成员 (%s/%s)"
L["caption_playername"] = "名称"
L["caption_class"] = "(职业)"
L["caption_subgroup"] = "  #"
L["caption_status"] = "@"
L["caption_mainspec"] = "主天赋"
L["caption_altspec"] = "附天赋"
L["caption_update"] = "最后更新"
L["button_addfake"] = "虚拟"
L["button_pets"] = "宠物"
L["button_database"] = "数据库"

L["caption_buffs"] = "增益/减益"

L["caption_talentscans"] = "扫描天赋"
L["Tanks"] = "坦克"
L["Melee DPS"] = "近战输出"
L["Ranged DPS"] = "远程输出"
L["Healers"] = "治疗"
L["format_timedifference"] = " %s前更新"
L["format_scanspending"] = "待扫描: %s/%s"
L["format_dbentries"] = "在库: %s"

L["caption_database"] = "RaidComp 数据库"
L["caption_databaserecords"] = "数据库记录"
L["format_timeold"] = "%s 以前"
L["format_status_database"] = "%s 玩家数据在库"


-- GUI_Support.lua   HELP TOOLTIP
-- ==============================
L["help1"] = "该页面包含了一些帮助信息."
L["help2"] = "详细信息请浏览 'wow.curseforge.com/addons/arc/'"

L["help3"] = "分类标识:"
L["help_buff"] = "增益类."
L["help_debuff"] = "减益类."
L["help_dot"] = "其他类."

L["help4"] = "增益/减益指示图标:"
L["help_check"] = "增益/减益存在于团队中."
L["help_nonoptimal"] = "增益/减益存在于团队中，但并非本类别的最佳增益/减益."
L["help_nonoptimal_ex1"] = "例如: 寒风号角带来的力量与敏捷加成较少"
L["help_nonoptimal_ex2"] = "    而强化的大地之力图腾加成较多."
L["help_maybe"] = "增益/减益可能存在于团队中，但可能无法与某些增益/减益共存."
L["help_maybe_ex1"] = "例如: 一个萨满无法同时使用风怒图腾"
L["help_maybe_ex2"] = "    和空气之怒图腾."
L["help_cross"] = "该增益/减益不存在于团队中."

L["help5"] = "玩家状态标记:"
L["help_ignore"] = "玩家将被忽略."
L["help_override"] = "由手动指定的天赋数据覆盖储存的."
L["help_ok"] = "玩家天赋在15分钟内被扫描过."
L["help_stored"] = "玩家天赋数据是15分钟或更久以前的."
L["help_temporary"] = "扫描前使用临时数据."
L["help_missing"] = "无该玩家天赋数据."
L["help_fake"] = "该玩家为虚拟玩家."

end
