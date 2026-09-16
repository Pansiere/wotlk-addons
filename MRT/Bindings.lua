local GlobalAddonName, ExRT = ...

BINDING_HEADER_ExRT = "Method Raid Tools"
BINDING_NAME_EXRT_FIGHTLOG_OPEN = ExRT.L.BossWatcher
BINDING_NAME_EXRT_OPEN = ExRT.L.minimapmenu

local function make(name, command, description)
	_G["BINDING_NAME_CLICK "..name..":LeftButton"] = description
	local btn = CreateFrame("Button", name, nil, "SecureActionButtonTemplate")
	btn:SetAttribute("type", "macro")
	btn:SetAttribute("macrotext", command)
	btn:RegisterForClicks("AnyUp", "AnyDown")
end

make("EXRTTOGGLENOTE", "/rt note", ExRT.L.message)

local swm = _G["SLASH_WORLD_MARKER1"]
local scwm = _G["SLASH_CLEAR_WORLD_MARKER1"]
if swm and scwm then
	for i=1,8 do
		make("EXRTWM"..i, scwm.." "..i.."\n"..swm.." "..i, _G["WORLD_MARKER"..i] or ("Marker "..i))
	end
	make("EXRTCWM", scwm.." 0", REMOVE_WORLD_MARKERS or "Clear markers")
	for i=1,8 do
		make("EXRTWM"..i.."CURSOR", swm.." [@cursor] "..i, (_G["WORLD_MARKER"..i] or ("Marker "..i)).." @ "..(_G["MOUSE_LABEL"] or "Mouse"))
	end
end
