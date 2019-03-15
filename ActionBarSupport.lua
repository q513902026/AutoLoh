local ns = select(2, ...);
ns.Funcs = {}
local F = ns.Funcs
local currentAddon = "Blizzard"

local supportAddonActionbars = {
    ["NDui"] = {
        [1] = "NDui_LeaveVehicleBar",   -- parent
        [2] = {"TOP", _G["NDui_LeaveVehicleBar"], "BOTTOM", 0, 0}, -- pos
    },
    ["ElvUI"] = {
        [1]  = "LeaveVehicleButton",
        [2]  = {"TOP", _G["LeaveVehicleButton"], "BOTTOM", 0, 0},
    },
}
function F:GetOverrideActionBarAndPos()
    local aload = IsAddOnLoaded
    for k,v in pairs(supportAddonActionbars) do
        if aload(k) then
            currentAddon = k
            return unpack(v)
        end
    end
    return "OverrideActionBar"
end

function F:GetCurrentActionBarSupport()
    return currentAddon
end

function F.RePoint(frame,parentName,poss)
    local parent = _G[parentName]
    if poss then
        if #poss == 3 or #poss == 5 then
            
            frame:SetPoint(poss[1], parent, poss[3], poss[4] or 0, poss[5] or 0);
        else
            frame:SetPoint(unpack(poss));
        end
    else
        frame:SetPoint("CENTER");
    end
end
