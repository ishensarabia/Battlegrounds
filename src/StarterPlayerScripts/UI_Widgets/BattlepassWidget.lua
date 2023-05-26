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
--variables
local battlepassConfig
local currentRewardFrameInPreview

--Screen guis
local BattlepassGui
local BattlepassPreviewGui
local BattlepassGiftGui
--Gui objects
local currentLevelFrame
local rewardsFrame
local buyButtonFrame
local giftButtonFrame
local battlepassLabelFrame

function BattlepassWidget:Initialize()
	--Initialize the screen guis
	--Battlepass gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassGui") then
		BattlepassGui = Assets.GuiObjects.ScreenGuis.BattlepassGui or game.Players.LocalPlayer.PlayerGui.BattlepassGui
		BattlepassGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassGui = game.Players.LocalPlayer.PlayerGui.BattlepassGui
	end
	--Battlepass preview gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassPreviewGui") then
		BattlepassPreviewGui = Assets.GuiObjects.ScreenGuis.BattlepassPreviewGui
			or game.Players.LocalPlayer.PlayerGui.BattlepassPreviewGui
		BattlepassPreviewGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassPreviewGui = game.Players.LocalPlayer.PlayerGui.BattlepassPreviewGui
	end
	--Battlepass gift gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassGiftGui") then
		BattlepassGiftGui = Assets.GuiObjects.ScreenGuis.BattlepassGiftGui
			or game.Players.LocalPlayer.PlayerGui.BattlepassGiftGui
		BattlepassGiftGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassGiftGui = game.Players.LocalPlayer.PlayerGui.BattlepassGiftGui
	end
	--Initialize the battlepass gui variables
	currentLevelFrame = BattlepassGui.MainFrame.CurrentLevelFrame
	battlepassLabelFrame = BattlepassGui.MainFrame.BattlepassLabelFrame
	rewardsFrame = BattlepassGui.MainFrame.RewardsFrame
	buyButtonFrame = BattlepassGui.MainFrame.BuyButtonFrame
	giftButtonFrame = BattlepassGui.MainFrame.GiftButtonFrame
	--Disable the screen guis
	BattlepassPreviewGui.Enabled = false
	BattlepassGui.Enabled = false
	BattlepassGiftGui.Enabled = false

	--Set up the back button
	local backButtonFrame = BattlepassGui.BackButtonFrame
	backButtonFrame.Button.Activated:Connect(function()
		ButtonWidget:OnActivation(backButtonFrame)
		BattlepassWidget:CloseBattlepass()
	end)
	BattlepassWidget.MainFrame = game.Players.LocalPlayer.PlayerGui.BattlepassGui.MainFrame
	--Hide the main frame with position
	BattlepassWidget.MainFrame.Position = UDim2.fromScale(1, 0)
	--Connect any events
	BattlepassService.LevelUp:Connect(function(newLevel)
		--Assign the current level
		currentLevelFrame.BarFrame.currentLevelText.Text = newLevel
		--Assign the next level
		currentLevelFrame.BarFrame.nextLevelText.Text = newLevel + 1
	end)

	buyButtonFrame.button.Activated:Connect(function()
		ButtonWidget:OnActivation(buyButtonFrame)
		BattlepassService:BuyBattlepass()
	end)

	--Gift battlepass gui connections
	giftButtonFrame.button.Activated:Connect(function()
		ButtonWidget:OnActivation(giftButtonFrame)
		BattlepassWidget:OpenGiftBattlepass()
	end)

	--Close button
	BattlepassGiftGui.MainFrame.CloseButtonFrame.Button.Activated:Connect(function()
		ButtonWidget:OnActivation(BattlepassGiftGui.MainFrame.CloseButtonFrame)
		BattlepassWidget:CloseGiftBattlepass()
	end)

	--Hide the battlepass gift frame for animation
	BattlepassGiftGui.MainFrame.Position = UDim2.fromScale(BattlepassGiftGui.MainFrame.Position.X.Scale, -1)

	return BattlepassWidget
end

function BattlepassWidget:OpenGiftBattlepass()
	BattlepassGiftGui.Enabled = true
	BattlepassGiftGui.MainFrame.TextBox.Text = ""
	BattlepassGiftGui.MainFrame.PlayerThumbnail.Image = ""
	--Set the text to the gift battlepass label
	BattlepassGiftGui.MainFrame.GiftBattlepassLabel.Text =
		string.format("GIFT %s BATTLEPASS", string.upper(player:GetAttribute("CurrentSeason"):gsub("_", " ")))
	--Tween the frame in
	TweenService:Create(
		BattlepassGiftGui.MainFrame,
		TweenInfo.new(0.5),
		{ Position = UDim2.fromScale(BattlepassGiftGui.MainFrame.Position.X.Scale, 0.215) }
	):Play()
	--Connect the focus gained event
	BattlepassGiftGui.MainFrame.TextBox.Focused:Connect(function()
		BattlepassGiftGui.MainFrame.PlayerThumbnail.Image = ""
	end)

	--Connect the focus lost event
	BattlepassGiftGui.MainFrame.TextBox.FocusLost:Connect(function()
		local success, userToGiftID = pcall(function()
			return Players:GetUserIdFromNameAsync(BattlepassGiftGui.MainFrame.TextBox.Text)
		end)
		if success then
			if userToGiftID then
				--Check if the user is not the player
				if userToGiftID == player.UserId then
					BattlepassGiftGui.MainFrame.ErrorLabel.Text = "You cannot gift yourself the battlepass."
					BattlepassGiftGui.MainFrame.ErrorLabel.Visible = true
					task.delay(2.3, function()
						BattlepassGiftGui.MainFrame.ErrorLabel.Visible = false
					end)
					return
				end
				local success2, result = pcall(function()
					return Players:GetUserThumbnailAsync(
						userToGiftID,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size420x420
					)
				end)
				if success2 then
					BattlepassGiftGui.MainFrame.PlayerThumbnail.Image = result
				else
					-- Handle error for Get User Thumbnail
					BattlepassGiftGui.MainFrame.ErrorLabel.Text = "Failed to load user's thumbnail."
					BattlepassGiftGui.MainFrame.ErrorLabel.Visible = true
					task.delay(2.3, function()
						BattlepassGiftGui.MainFrame.ErrorLabel.Visible = false
					end)
				end
			end
		else
			-- Handle error for Get User Id
			BattlepassGiftGui.MainFrame.ErrorLabel.Text = "Invalid username."
			BattlepassGiftGui.MainFrame.ErrorLabel.Visible = true
			task.delay(2.3, function()
				BattlepassGiftGui.MainFrame.ErrorLabel.Visible = false
			end)
		end
	end)
end

function BattlepassWidget:CloseGiftBattlepass()
	--Tween the frame out
	local frameOutTween = TweenService:Create(
		BattlepassGiftGui.MainFrame,
		TweenInfo.new(0.5),
		{ Position = UDim2.fromScale(BattlepassGiftGui.MainFrame.Position.X.Scale, -1) }
	)
	frameOutTween:Play()
	frameOutTween.Completed:Connect(function()
		BattlepassGiftGui.Enabled = false
		BattlepassGiftGui.MainFrame.PlayerThumbnail.Image = ""
	end)
end

function BattlepassWidget:DisplayPreview(rewardInfo: table, level)
	BattlepassWidget.CurrentRewardItem = nil
	--Assign the reward type to the preview frame
	BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
	--Assign the correct reward name
	BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.rewardType:gsub("_", " ")
	--Assign the correct reward description
	BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardDescription.Text =
		battlepassConfig.RewardDescriptions[rewardInfo.rewardType]
	--Assign the rarity text and color
	BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
	BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
	--Set the background color of the item frame to the rarity color
	BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
	--Assign the reward required level
	BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level
	--Detect the type of reward and display the correct preview (display on viewportframe or display on image label)
	if
		rewardInfo.rewardType == battlepassConfig.RewardTypes.BattleCoins
		or rewardInfo.rewardType == battlepassConfig.RewardTypes.BattleGems
		or rewardInfo.rewardType == battlepassConfig.RewardTypes.Experience_Boost
	then
		BattlepassPreviewGui.MainFrame.RewardImage.Image = battlepassConfig.RewardIcons[rewardInfo.rewardType]
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
	end
end

local function CreateItemRewardFrame(battlepassConfig: table, rewardInfo: table, rewardTypeFrame: Frame, level: number)
	local rewardFrame = Assets.GuiObjects.Frames.BattlepassRewardItemFrame:Clone()
	rewardFrame.Parent = rewardTypeFrame
	--Assign the reward name, filtering the _ and replacing with spaces
	local rewardName = rewardInfo.rewardType:gsub("_", " ")
	rewardFrame.ItemName.Text = rewardName
	--Assign the color to the itemframe according to the reward rarity
	rewardFrame.ItemFrame.ImageColor3 = rewardInfo.rarityColor
	--Assign the correct image to the itemframe
	rewardFrame.ItemIcon.Image = battlepassConfig.RewardIcons[rewardInfo.rewardType]

	if rewardInfo.rewardAmount then
		rewardFrame.ItemAmount.Visible = true
		rewardFrame.ItemAmount.Text = rewardInfo.rewardAmount
	end

	--Connect the mouse enter and leave events
	rewardFrame.ItemIcon.MouseEnter:Connect(function()
		if not BattlepassPreviewGui.Enabled then
			BattlepassPreviewGui.Enabled = true
		end
		if currentRewardFrameInPreview then
			currentRewardFrameInPreview.SelectionFrame.Visible = false
		end
		currentRewardFrameInPreview = rewardFrame
		rewardFrame.SelectionFrame.Visible = true
		BattlepassWidget:DisplayPreview(rewardInfo, level)
	end)
end

function BattlepassWidget:GenerateRewards(currentSeason)
	BattlepassService:GetBattlepassConfig():andThen(function(_battlepassConfig)
		battlepassConfig = _battlepassConfig
		local seasonRewards = _battlepassConfig.rewards[currentSeason]
		for level, rankRewardsTable in seasonRewards do
			local battlepassRewardFrame = Assets.GuiObjects.Frames.BattlepassRewardFrame:Clone()
			--Name the frame with the rank
			battlepassRewardFrame.Name = level
			--Assign the rank text
			battlepassRewardFrame.RankText.Text = level
			--Assign the current rank to the progress bar
			battlepassRewardFrame.ProgressBarFrame.BarFrame.currentRankText.Text = level
			--Set the bar size to 0
			battlepassRewardFrame.ProgressBarFrame.BarFrame.ProgressBar.Size = UDim2.fromScale(0, 0.9)
			battlepassRewardFrame.Parent = BattlepassWidget.MainFrame.RewardsFrame
			--Generate the item rewards frames for each rank and separate them to premium rewards and free rewards
			warn(level)
			for _, rewardInfo in rankRewardsTable.battlepass do
				CreateItemRewardFrame(_battlepassConfig, rewardInfo, battlepassRewardFrame.PremiumRewardsFrame, level)
			end
			for _, rewardInfo in rankRewardsTable.freepass do
				CreateItemRewardFrame(_battlepassConfig, rewardInfo, battlepassRewardFrame.FreeRewardsFrame, level)
			end
			--Assign the correct UIGridLayout cell size for the premium rewards according to the amount of rewards
			if #battlepassRewardFrame.PremiumRewardsFrame:GetChildren() <= 6 then
				battlepassRewardFrame.PremiumRewardsFrame.UIGridLayout.CellSize = UDim2.fromScale(0.3, 1)
			end

			if #battlepassRewardFrame.PremiumRewardsFrame:GetChildren() > 6 then
				battlepassRewardFrame.PremiumRewardsFrame.UIGridLayout.CellSize = UDim2.fromScale(0.24, 1)
			end
		end
	end)
end

---@diagnostic disable-next-line: undefined-type
function BattlepassWidget:OpenBattlepass(callback: Function)
	BattlepassGui.Enabled = true
	--Set the callback
	BattlepassWidget.callback = callback
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0, 0) })
	mainFrameTween:Play()
	--Tween battlepass preview gui position
	local previewGuiTween = TweenService:Create(
		BattlepassPreviewGui.MainFrame,
		TweenInfo.new(0.325),
		{ Position = BattlepassPreviewGui.MainFrame:GetAttribute("TargetPosition") }
	)
	previewGuiTween:Play()
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
		--Add as attributes the current level and current season to the player
		player:SetAttribute("CurrentLevel", currentSeasonData.Level)
		player:SetAttribute("CurrentSeason", currentSeason)
		--Generate the rewards frame if they don't exist
		if #BattlepassWidget.MainFrame.RewardsFrame:GetChildren() <= 1 then
			BattlepassWidget:GenerateRewards(battlepassData.currentSeason)
		end
		--Update the progress bars
		BattlepassService:GetExperienceNeededForNextLevel():andThen(function(experienceNeeded)
			currentLevelFrame.BarFrame.LevelBar.Size = UDim2.fromScale(
				(currentSeasonData.Experience / experienceNeeded) * 1,
				currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale
			)
			--Assign the current xp
			currentLevelFrame.BarFrame.XPText.Text = currentSeasonData.Experience .. "/" .. experienceNeeded
			--Fill the progress bar of previous levels
			for i = 1, currentSeasonData.Level do
				rewardsFrame[i].ProgressBarFrame.BarFrame.ProgressBar.Size = UDim2.fromScale(1, 0.9)
			end
			--Get the current level to update the progress bar of the item reward rank
			local currentRank = currentSeasonData.Level
			rewardsFrame[currentRank].ProgressBarFrame.BarFrame.ProgressBar.Size = UDim2.fromScale(
				(currentSeasonData.Experience / experienceNeeded) * 1,
				rewardsFrame[currentRank].ProgressBarFrame.BarFrame.ProgressBar.Size.Y.Scale
			)
		end)
	end)
end

function BattlepassWidget:CloseBattlepass()
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0) })
	mainFrameTween:Play()
	--Tween battlepass preview gui position
	local previewGuiTween = TweenService:Create(
		BattlepassPreviewGui.MainFrame,
		TweenInfo.new(0.325),
		{ Position = UDim2.fromScale(1, BattlepassPreviewGui.MainFrame.Position.Y.Scale) }
	)
	previewGuiTween:Play()
	mainFrameTween.Completed:Connect(function()
		BattlepassGui.Enabled = false
		BattlepassPreviewGui.Enabled = false
		BattlepassWidget.callback()
		BattlepassService:AddExperience(100)
	end)
end

return BattlepassWidget:Initialize()
