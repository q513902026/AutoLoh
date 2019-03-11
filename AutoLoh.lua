local ns = select(2, ...);
local LohAutoRunner = ns.LohAutoRunner;

local f = CreateFrame("frame");
f:RegisterEvent("QUEST_ACCEPTED");
f:RegisterEvent("QUEST_REMOVED");
f:RegisterEvent("PLAYER_ENTERING_WORLD");

local LohQuests = {
	[51632] = { 3, 2, 1, 2, 2, 1, 2, 3, 2, 2, 3, 2, 2, 3, 2, 2, 2, 1, 2, 3, 2, 1, 2, 1, 2, 2, 1, 2, 3, 2, 2, 3, 2 },
	[51633] = { 3, 2, 1, 2, 2, 1, 2, 3, 2, 2, 3, 2, 3, 2, 1, 2, 3, 2, 2, 2, 1, 2, 2, 1, 2, 2, 1, 2, 3, 2, 2, 3, 2 },
	[51635] = { 2, 2, 2, 2, 3, 2, 3, 2, 2, 2, 2, 1, 2, 1, 2, 3, 2, 1, 2, 1, 2, 3, 2, 2, 3, 2, 3, 2, 1, 2, 1, 2 },
	[51636] = { 2, 3, 2, 2, 2, 3, 2, 1, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 2 },
};


local currentLohAutoRunner = nil;


local function GetCurrentLohQuestId()
	for i = 1,GetNumQuestLogEntries() do
		local _, _, _, _, _, _, _, questId = GetQuestLogTitle(i);
		if questId and LohQuests[questId] ~= nil then
			return questId;
		end
	end

	return nil;
end

f:SetScript("OnEvent", function(self, event, arg1, arg2)
	if event == "QUEST_ACCEPTED" then
		local questId = arg2;

		if questId and LohQuests[questId] ~= nil then
			self:RegisterEvent("UNIT_ENTERED_VEHICLE");
			self:RegisterEvent("UNIT_EXITED_VEHICLE");
		end
	elseif event == "QUEST_REMOVED" then
		local questId = arg1;

		if questId and LohQuests[questId] ~= nil then
			self:UnregisterEvent("UNIT_ENTERED_VEHICLE");
			self:UnregisterEvent("UNIT_EXITED_VEHICLE");
		end
	elseif event == "UNIT_ENTERED_VEHICLE" then
		local unit = arg1;

		if unit ~= "player" then
			return;
		end

		local lohQuestId = GetCurrentLohQuestId();

		if lohQuestId ~= nil then
			currentLohAutoRunner = LohAutoRunner:New(LohQuests[lohQuestId]);
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		local unit = arg1;

		if unit ~= "player" or currentLohAutoRunner == nil then
			return;
		end

		currentLohAutoRunner:Dispose();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		local lohQuestId = GetCurrentLohQuestId();

		if lohQuestId ~= nil then
			return self:GetScript("OnEvent")(self, "QUEST_ACCEPTED", nil, lohQuestId);
		end
	end
end);
