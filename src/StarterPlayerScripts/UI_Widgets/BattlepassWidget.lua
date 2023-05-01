--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Main
local BattlepassWidget = {}
local player = Players.LocalPlayer
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Services
local BattlepassService = Knit.GetService("BattlepassService")
--Constants

--Screen guis
local BattlepassGui
local BattlepassPreviewGui
--Gui objects
local currentLevelFrame
local battlepassLabelFrame

function BattlepassWidget:Initialize()
	--Initialize the screen guis
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassGui") then
		BattlepassGui = Assets.GuiObjects.ScreenGuis.BattlepassGui or game.Players.LocalPlayer.PlayerGui.BattlepassGui
		BattlepassGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassGui = game.Players.LocalPlayer.PlayerGui.BattlepassGui
	end
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassPreviewGui") then
		BattlepassPreviewGui = Assets.GuiObjects.ScreenGuis.BattlepassPreviewGui
			or game.Players.LocalPlayer.PlayerGui.BattlepassPreviewGui
		BattlepassPreviewGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassPreviewGui = game.Players.LocalPlayer.PlayerGui.BattlepassPreviewGui
	end
	--Initialize the battlepass gui variables
	currentLevelFrame = BattlepassGui.MainFrame.CurrentLevelFrame
	battlepassLabelFrame = BattlepassGui.MainFrame.BattlepassLabelFrame
	--Disable the screen guis
	BattlepassPreviewGui.Enabled = false
	BattlepassGui.Enabled = false

	--Set up the back button
	local backButtonFrame = BattlepassGui.BackButtonFrame
	backButtonFrame.Button.Activated:Connect(function()
		ButtonWidget:OnActivation(backButtonFrame.Button)
		BattlepassWidget:CloseBattlepass()
	end)
	BattlepassWidget.MainFrame = game.Players.LocalPlayer.PlayerGui.BattlepassGui.MainFrame
	--Hide the main frame with position
	BattlepassWidget.MainFrame.Position = UDim2.fromScale(1, 0)

	return BattlepassWidget
end

function BattlepassWidget:OpenBattlepass(callback: Function)
	BattlepassGui.Enabled = true
	--Set the callback
	BattlepassWidget.callback = callback
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0, 0) })
	mainFrameTween:Play()
	--Get the battlepass data
	BattlepassService:GetBattlepassData(player):andThen(function(battlepassData)
		--Get the current battlepass season
		local currentSeason = battlepassData.currentSeason
		--format the current season string to remove _ and replace with spaces
		local currentSeasonText = currentSeason:gsub("_", " ")
		BattlepassWidget.MainFrame.SeasonText.Text = currentSeasonText
		--Get the current season data
		local currentSeasonData = battlepassData[currentSeason]
		--Assign the current level
		currentLevelFrame.BarFrame.currentLevelText.Text = currentSeasonData.Level
		--Assign the next level
		currentLevelFrame.BarFrame.nextLevelText.Text = currentSeasonData.Level + 1
		--Assign the current xp
		currentLevelFrame.BarFrame.XPText.Text = currentSeasonData.Experience
		--Generate the rewards frame
		BattlepassService:GetSeasonRewards():andThen(function(seasonRewards)
			for rank, rankRewardsTable in seasonRewards do
				warn(rank, rankRewardsTable)
				local battlepassRewardFrame = Assets.GuiObjects.Frames.BattlepassRewardFrame:Clone()
				--Assign the rank text
				battlepassRewardFrame.RankText.Text = rank
				--Assign the current rank to the progress bar
				battlepassRewardFrame.ProgressBarFrame.BarFrame.currentRankText.Text = rank
				battlepassRewardFrame.Parent = BattlepassWidget.MainFrame.RewardsFrame
				--Generate the item rewards frames for each rank and separate them to premium rewards and free rewards
				for _, rewardInfo in rankRewardsTable.battlepass do
					local rewardFrame = Assets.GuiObjects.Frames.BattlepassRewardItemFrame:Clone()
					rewardFrame.Parent = battlepassRewardFrame.PremiumRewardsFrame
					--Assign the reward name
					rewardFrame.ItemName.Text = rewardInfo.rewardType
					--Assign the color to the itemframe according to the reward rarity
					rewardFrame.ItemFrame.ImageColor3 = rewardInfo.rarityColor
				end
				for _, rewardInfo in rankRewardsTable.freepass do
					local rewardFrame = Assets.GuiObjects.Frames.BattlepassRewardItemFrame:Clone()
					rewardFrame.Parent = battlepassRewardFrame.FreeRewardsFrame
					--Assign the reward name and type
					rewardFrame.ItemName.Text = rewardInfo.rewardType
					--Assign the color to the itemframe according to the reward rarity
					rewardFrame.ItemFrame.ImageColor3 = rewardInfo.rarityColor
				end
			end
		end)
	end)
end

function BattlepassWidget:CloseBattlepass()
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0) })
	mainFrameTween:Play()
	mainFrameTween.Completed:Connect(function()
		BattlepassGui.Enabled = false
		BattlepassWidget.callback()
		BattlepassService:AddExperience(10)
	end)
end

return BattlepassWidget:Initialize()
