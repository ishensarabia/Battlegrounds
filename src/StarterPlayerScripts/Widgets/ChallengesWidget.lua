--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
--Services
local ChallengesService = Knit.GetService("ChallengesService")
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
--Main
local ChallengesWidget = {}
--Constants
local REWARD_TYPE_ICONS = {
	BattleCoins = "rbxassetid://10835882861",
	BattleGems = "rbxassetid://10835980573",
	BattlepassExp = "rbxassetid://13474525765",
	Exp = "rbxassetid://15229974173",
}
--Screen guis
local ChallengesGui
--Gui objects
local challengesFrame

local buttonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0)

local function CreateChallengeFrame(challenge: table, challengeType: string, index: number)
	local challengeFrame = Assets.GuiObjects.Frames.ChallengeFrame:Clone()
	challengeFrame.Name = challenge.name
	challengeFrame.ChallengeTitle.Text = challenge.name
	challengeFrame.ChallengeDescription.Text = challenge.description
	challengeFrame.LayoutOrder = index
	--Generate the rewards
	for i, reward: table in challenge.rewards do
		local rewardFrame = Assets.GuiObjects.Frames.ChallengeRewardFrame:Clone()
		rewardFrame.RewardImage.Image = REWARD_TYPE_ICONS[reward.rewardType]
		rewardFrame.RewardAmount.Text = FormatText.To_comma_value(reward.rewardAmount)
		rewardFrame.LayoutOrder = i
		rewardFrame.Parent = challengeFrame.RewardsFrame
	end
	if not challenge.progression then
		challenge.progression = 0
	end
	--Adjust the progress bar
	challengeFrame.BarFrame.ProgressText.Text = challenge.progression .. "/" .. challenge.goal
	challengeFrame.BarFrame.ProgressBar.Size = UDim2.fromScale((challenge.progression / challenge.goal) * 1, 0.9)

	--Create the claim button
	local claimButton = ButtonWidget.new(challengeFrame.ClaimFrame.ClaimButton, function()
		local success = ChallengesService:ClaimChallenge(challenge, challengeType)
		if success then
			challengeFrame.ClaimFrame.Visible = false
		end
	end)

	--Create the discard button
	local discardButton = ButtonWidget.new(challengeFrame.DiscardButton, function()
		ChallengesService:ReplaceChallenge(challenge, challengeType)
	end)
	return challengeFrame
end


function ChallengesWidget:Initialize()
	--Initialize the screen guis
	--Battlepass gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("ChallengesGui") then
		ChallengesGui = Assets.GuiObjects.ScreenGuis.ChallengesGui or game.Players.LocalPlayer.PlayerGui.ChallengesGui
		ChallengesGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		ChallengesGui = game.Players.LocalPlayer.PlayerGui.ChallengesGui
	end
	--Initialize the gui objects
	challengesFrame = ChallengesGui.ChallengesFrame
	--Hide the challenges frame with position
	challengesFrame.Position = UDim2.fromScale(challengesFrame.Position.X.Scale, 1)

	ChallengesGui.Enabled = false

	--Connect button events
	local closeButton = ButtonWidget.new(challengesFrame.CloseButton, function()
		ChallengesWidget:CloseChallenges()
	end)
	--Listen to challenges signals
	ChallengesService.ChallengesInitialized:Connect(function(challengesData)
		self._challengeDataCache = challengesData
	end)
	ChallengesService.ChallengeReplaced:Connect(function(challengeChangedName, newChallenge, typeOfChallenge)
		ChallengesWidget:ReplaceChallengeFrame(challengeChangedName, newChallenge, typeOfChallenge)
	end)
	ChallengesService.ChallengeProgressionUpdated:Connect(function(challengeData, typeOfChallenge)
		ChallengesWidget:UpdateChallengeFrame(challengeData, typeOfChallenge)
	end)
	ChallengesService.ChallengeCompleted:Connect(function(challengeData, typOfChallenge)
		ChallengesWidget:ChallengeCompleted(challengeData, typOfChallenge)
	end)
	ChallengesService.ChallengeClaimed:Connect(function(challengeData, typeOfChallenge)
		ChallengesWidget:ChallengeClaimed(challengeData, typeOfChallenge)
	end)
	--Return the widget
	return ChallengesWidget
end

function ChallengesWidget:OpenChallenges()
	if not ChallengesGui.Enabled then
		ChallengesGui.Enabled = true
	end
	--Open the challenges frame
	challengesFrame:TweenPosition(
		challengesFrame:GetAttribute("TargetPosition"),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.13
	)
	self:GenerateChallengesFrames(self._challengeDataCache)
end

function ChallengesWidget:CloseChallenges()
	--Close the challenges frame
	challengesFrame:TweenPosition(
		UDim2.fromScale(challengesFrame.Position.X.Scale, 1),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.13,
		false,
		function()
			ChallengesGui.Enabled = false
		end
	)
	--Clear challenges frame
	for index, value in challengesFrame.DailyChallengesFrame:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end
	for index, value in challengesFrame.WeeklyChallengesFrame:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end
end

function ChallengesWidget:UpdateChallengeFrame(challengeData, typeOfChallenge)
	if self.isActive then		
		local challengeFrame = challengesFrame[typeOfChallenge .. "ChallengesFrame"][challengeData.name]
		challengeFrame.BarFrame.ProgressText.Text = challengeData.progression .. "/" .. challengeData.goal
		--Update the bar
		challengeFrame.BarFrame.ProgressBar.Size =
			UDim2.fromScale((challengeData.progression / challengeData.goal) * 1, 0.9)
	end
end

function ChallengesWidget:ChallengeCompleted(challengeData, typeOfChallenge)
	local challengeFrame = challengesFrame[typeOfChallenge .. "ChallengesFrame"][challengeData.name]
	local WidgetController = Knit.GetController("WidgetController")
	local shineTween = WidgetController:AnimateShineForFrame(challengeFrame.ClaimFrame, true, true )
	challengeFrame.ClaimFrame.Visible = true
end

function ChallengesWidget:ChallengeClaimed(challengeData, typeOfChallenge)
	local challengeFrame = challengesFrame[typeOfChallenge .. "ChallengesFrame"][challengeData.name]
	challengeFrame:Destroy()
end

function ChallengesWidget:ReplaceChallengeFrame(
	challengeToReplaceName: string,
	newChallenge: table,
	challengeType: string
)
	local layoutOrder = challengesFrame[challengeType .. "ChallengesFrame"][challengeToReplaceName].LayoutOrder
	challengesFrame[challengeType .. "ChallengesFrame"][challengeToReplaceName]:Destroy()
	local challengeFrame = CreateChallengeFrame(newChallenge, challengeType)
	challengeFrame.LayoutOrder = layoutOrder
	challengeFrame.Parent = challengesFrame[challengeType .. "ChallengesFrame"]
end

function ChallengesWidget:GenerateChallengesFrames(challengesData)
	--Generate the daily challenges
	for index, challenge: table in challengesData.Daily do
		local challengeFrame = CreateChallengeFrame(challenge, "Daily", index)
		challengeFrame.Parent = challengesFrame.DailyChallengesFrame
		--if the challenge is completed display the completed frame
		if challenge.isCompleted then
			ChallengesWidget:ChallengeCompleted(challengeFrame, "Daily")
		end
	end
	for index, challenge: table in challengesData.Weekly do
		local challengeFrame = CreateChallengeFrame(challenge, "Weekly", index)
		challengeFrame.Parent = challengesFrame.WeeklyChallengesFrame
		--if the challenge is completed display the completed frame
		if challenge.isCompleted then
			ChallengesWidget:ChallengeCompleted(challengeFrame, "Weekly")
		end
	end
end

return ChallengesWidget:Initialize()
