local ns = select(2, ...);
ns.Funcs = {}
local F = ns.Funcs
local currentAddon = "Blizzard"

local supportAddonActionbars = {
    ["NDui"] = {
        [1] = "NDui_ActionBar1", -- parent
        [2] = {"BOTTOM", _G["NDui_ActionBar1"], "TOP", 0, 0}, -- pos
    },
    ["ElvUI"] = {
        [1] = "ElvUI_Bar1",
        [2] = {"BOTTOM", _G["ElvUI_Bar1"], "TOP", 0, 0},
    },
}
local skinAddonsStyle={
    ["NDui"] = {
        restyle = function(frame)
            local B = unpack(NDui)
            B.Reskin(frame)
        end
    },
    ["ElvUI"] = {
        restyle = function(frame)
            local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
            local S = E:GetModule('Skins')
            S:HandleButton(frame)
        end

    }
}
function F:GetOverrideActionBarAndPos()
    local aload = IsAddOnLoaded
    for k, v in pairs(supportAddonActionbars) do
        if aload(k) then
            currentAddon = k
            return unpack(v)
        end
    end
    return "OverrideActionBar",{"BOTTOM", _G["OverrideActionBar"], "TOP", 0, 0}
end

function F:RestyleButton(button)
    if skinAddonsStyle[currentAddon] then
        skinAddonsStyle[currentAddon].restyle(button)
    end
end


function F:GetCurrentActionBarSupport()
    return currentAddon
end

function F.RePoint(frame, parentName, poss)
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
