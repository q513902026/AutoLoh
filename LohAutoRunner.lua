local ns = select(2, ...);
local F = ns.Funcs
ns.LohAutoRunner = {};
ns.LohAutoRunner.__index = ns.LohAutoRunner;


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
    local parent,poss = F:GetOverrideActionBarAndPos()
    self.nextButton = CreateFrame("Button", "AutoLohNextButton", _G[parent], "SecureActionButtonTemplate, UIPanelButtonTemplate") do
        self.nextButton:SetSize(80, 22);
        F.RePoint(self.nextButton,parent,poss)
        self.nextButton:SetText("Next");
        
        self.nextButton:RegisterEvent("UNIT_AURA");
        self.nextButton:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self.nextButton:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
            if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == self.unit and self.spells[arg3] then
                self:PrepareNextStep();
            elseif event == "UNIT_AURA" and arg1 == self.unit then
                if self:IsNextEnabled() then
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
    
    self.nextButton:SetAttribute("type1", "macro");
    self.nextButton:SetAttribute("macrotext", "/click OverrideActionBarButton" .. self:NextStep());
end

function ns.LohAutoRunner:NextStep()
    return self.steps[self.nextStepIndex];
end

function ns.LohAutoRunner:IsNextEnabled()
    -- Loh can only move if the player does not have the Processing debuff (https://www.wowhead.com/spell=271809/processing)
    return self:IsLohProcessing() == false and self.nextStepIndex <= table.getn(self.steps);
end

function ns.LohAutoRunner:IsEnd()
    return self.nextStepIndex > table.getn(self.steps);
end

function ns.LohAutoRunner:IsLohProcessing()
    for i = 1, 40 do
        local debuffID = select(10, UnitDebuff(self.unit, i));
        if debuffID == 271809 then
            return true;
        end
    end
    
    return false;
end
