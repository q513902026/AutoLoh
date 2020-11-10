local ns = select(2, ...);
local F = ns.Funcs
ns.LohAutoRunner = {};
ns.LohAutoRunner.__index = ns.LohAutoRunner;

local frames = {}
-- nextButton must singleton 
local function GetActionButtonFrame(name, parent)
    if frames[name] then return frames[name] end
    local button = CreateFrame("Button", name, parent, "SecureActionButtonTemplate, UIPanelButtonTemplate")
    F:RestyleButton(button)
    frames[name] = button
    button:Show()
    return button
end

function ns.LohAutoRunner:New(steps)
    local self = {};
    setmetatable(self, ns.LohAutoRunner);
    
    self.unit = "pet";
    self.spells = {
        [271600] = true,
        [271601] = true,
        [271602] = true
    };
    self.nextStepIndex = 0;
    self.steps = steps;
    local parent, poss = F:GetOverrideActionBarAndPos()
    self.nextButton = GetActionButtonFrame("AutoLohNextButton", _G[parent])
    do
        self.nextButton:SetSize(80, 22);
        F.RePoint(self.nextButton, parent, poss)
        self.nextButton:SetText("Next");
        
        self.nextButton:RegisterEvent("UNIT_AURA");
        self.nextButton:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self.nextButton:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
            if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == self.unit and self.spells[arg3] then
                self:PrepareNextStep();
            elseif event == "UNIT_AURA" and arg1 == self.unit then
                if	 self:IsNextEnabled() then
                    self.nextButton:Enable();
                else
                    self.nextButton:Disable();
                end
            end
        end);
        self.nextButton.HotKey = self.nextButton:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray");
        self.nextButton.HotKey:SetPoint("TOPRIGHT", -1, -2);
        self.nextButton.HotKey:SetText("A");
        SetOverrideBindingClick(self.nextButton, true, "A", self.nextButton:GetName());
        self:PrepareNextStep();
    end
    
    return self;
end

function ns.LohAutoRunner:Dispose()
    self.nextButton:UnregisterEvent("UNIT_AURA");
    self.nextButton:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    self.nextButton:Hide()
    ClearOverrideBindings(self.nextButton);

end

function ns.LohAutoRunner:PrepareNextStep()
    if self:IsNextEnabled() == false then
        self.nextButton:Disable();
    end
    
    self.nextStepIndex = self.nextStepIndex + 1;
    
    if self:IsEnd() then
        self:Dispose();
        return;
    end
    -- ELVUI fix because OverrideActionBarButton1 is unregisterEvents
    self.nextButton:SetAttribute("type1", "pet");
    self.nextButton:SetAttribute("action", self:NextStep());
end

function ns.LohAutoRunner:NextStep()
    return self.steps[self.nextStepIndex];
end

function ns.LohAutoRunner:IsNextEnabled()
    -- Loh can only move if the player does not have the Processing debuff (https://www.wowhead.com/spell=271809/processing)
    return self:IsStart() and self:IsLohProcessing() == false and self.nextStepIndex <= table.getn(self.steps);
end

function ns.LohAutoRunner:IsEnd()
    return self.nextStepIndex > table.getn(self.steps);
end

local function findAura(unit,debuff)
	for i = 1, 40 do
        local debuffID = select(10, UnitDebuff(unit, i));
        if debuffID and debuffID == debuff then
            return true;
        end
    end
	return false
end

function ns.LohAutoRunner:IsStart()
	return findAura(self.unit,276705)
end

function ns.LohAutoRunner:IsLohProcessing()
	return findAura(self.unit,271809)
end
