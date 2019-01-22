local ns = select(2, ...);

ns.LohAutoRunner = {};
ns.LohAutoRunner.__index = ns.LohAutoRunner;

-- GLOBALS: OverrideActionBar

function ns.LohAutoRunner:New(steps)
    local self = {};
    setmetatable(self, ns.LohAutoRunner);

    self.nextStepIndex = 0;
    self.steps = steps;

    self.autoButton1 = self:CreateButton(1);
    self.autoButton2 = self:CreateButton(2);
    self.autoButton3 = self:CreateButton(3);

    self.nextButton = CreateFrame("Button", "AutoLohNextButton", OverrideActionBar, "UIPanelButtonTemplate") do
		self.nextButton:SetSize(80, 22);
		self.nextButton:SetPoint("CENTER");
        self.nextButton:SetText("Next");
        self.nextButton:SetScript("OnClick", function()
            self:Next();
        end);
        self.nextButton:Hide();
        
        self.nextButton:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
        self.nextButton:SetScript("OnEvent", function(_, event, arg1)
            if event == "ACTIONBAR_UPDATE_COOLDOWN" then
                ClearOverrideBindings(self.autoButton1);
                ClearOverrideBindings(self.autoButton2);
                ClearOverrideBindings(self.autoButton3);
                SetOverrideBindingClick(self.nextButton, true, "A", self.nextButton:GetName());

                self.nextButton:Show();
                self.autoButton1:Hide();
                self.autoButton2:Hide();
                self.autoButton3:Hide();
            end
        end);
        self.nextButton.HotKey = self.nextButton:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray");
        self.nextButton.HotKey:SetPoint("TOPRIGHT", -1, -2);
        self.nextButton.HotKey:SetText("A");
    end

    return self;
end

function ns.LohAutoRunner:Dispose()
    self.nextButton:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
    ClearOverrideBindings(self.nextButton);
    ClearOverrideBindings(self.autoButton1);
    ClearOverrideBindings(self.autoButton2);
    ClearOverrideBindings(self.autoButton3);
end

function ns.LohAutoRunner:Next()
    if self:IsNextEnabled() == false then
        return;
    end

    self.nextStepIndex = self.nextStepIndex + 1;
    self.nextButton:Hide();
    ClearOverrideBindings(self.nextButton);

    self:ShowRelevantAutoButton();
end

function ns.LohAutoRunner:ShowRelevantAutoButton()
    local nextStep = self:NextStep();

    if nextStep == 1 then
        SetOverrideBindingClick(self.autoButton1, true, "A", self.autoButton1:GetName());
        ClearOverrideBindings(self.autoButton2);
        ClearOverrideBindings(self.autoButton3);

        self.autoButton1:Show();
        self.autoButton2:Hide();
        self.autoButton3:Hide();
    elseif nextStep == 2 then
        ClearOverrideBindings(self.autoButton1);
        SetOverrideBindingClick(self.autoButton2, true, "A", self.autoButton2:GetName());
        ClearOverrideBindings(self.autoButton3);

        self.autoButton1:Hide();
        self.autoButton2:Show();
        self.autoButton3:Hide();
    elseif nextStep == 3 then
        ClearOverrideBindings(self.autoButton1);
        ClearOverrideBindings(self.autoButton2);
        SetOverrideBindingClick(self.autoButton3, true, "A", self.autoButton3:GetName());

        self.autoButton1:Hide();
        self.autoButton2:Hide();
        self.autoButton3:Show();
    end
end

function ns.LohAutoRunner:CreateButton(stepForButton)
    local autoButton = CreateFrame("Button", "AutoLohAutoButton"..stepForButton, OverrideActionBar, "SecureActionButtonTemplate, UIPanelButtonTemplate") do
		autoButton:SetSize(80, 22);
		autoButton:SetPoint("CENTER");
		autoButton:SetText("Auto");
		autoButton:SetAttribute("type1", "macro");
        autoButton:SetAttribute("macrotext", "/click OverrideActionBarButton"..stepForButton);
        autoButton.HotKey = autoButton:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray");
        autoButton.HotKey:SetPoint("TOPRIGHT", -1, -2);
        autoButton.HotKey:SetText("A");
        autoButton:Hide();
	end
	return autoButton;
end

function ns.LohAutoRunner:NextStep()
    return self.steps[self.nextStepIndex];
end

function ns.LohAutoRunner:IsNextEnabled()
    -- Loh can only move if the player does not have the Processing debuff (https://www.wowhead.com/spell=271809/processing)
    return self:IsLohProcessing() == false and self.nextStepIndex < table.getn(self.steps);
end

function ns.LohAutoRunner:IsLohProcessing()
    for i = 1,40 do
		local debuffName = UnitDebuff("player", i);
		if debuffName == "Processing" then
			return true;
		end
    end
    
    return false;
end