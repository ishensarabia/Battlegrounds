--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
--Main
local BattlepassWidget = {}
local player = Players.LocalPlayer
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
--Services
local BattlepassService = Knit.GetService("BattlepassService")
local DataService = Knit.GetService("DataService")
--Controllers
local WidgetController = Knit.GetController("WidgetController")
local EmoteController = Knit.GetController("EmoteController")
local WeaponCustomizationController = Knit.GetController("WeaponCustomizationController")
--Configurations
local BattlepassConfig = require(ReplicatedStorage.Source.Configurations.BattlepassConfig)
--variables
local currentRewardFrameInPreview
--Enums
local RaritiesEnum = require(ReplicatedStorage.Source.Enums.RaritiesEnum)
local RewardsEnum = require(ReplicatedStorage.Source.Enums.RewardsEnum)
--Screen guis
local BattlepassGui
local BattlepassPreviewGui
local BattlepassGiftGui
--Gui objects
local currentLevelFrame
local rewardsFrame
local previewViewportFrame
local timerTextLabel
local rewardsDescriptionFrame
--Connections
local viewportConnection
--Variables
local seasonData
local battlepassTweenInfo = TweenInfo.new(0.69, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
--Constants
local EMOTE_FRAME_ASPECT_RATIO = 0.8
--Assets
local weapons = ReplicatedStorage.Weapons

export type RewardInfo = {
	MainFrame: Frame,
	CurrentRewardItem: Frame,
	IsActive: boolean,
}

local function ScaleToOffset(x, y, parentFrame)
	if parentFrame then
		x *= parentFrame.AbsoluteSize.X
		y *= parentFrame.AbsoluteSize.Y
		-- else
		-- 	x *= viewportSize.X
		-- 	y *= viewportSize.Y
	end
	return math.round(x), math.round(y)
end

local function getTimeUntilTextUpdate()
	local now = os.time() + BattlepassConfig.RESET_TIME_OFFSET
	local timeUntilNextUpdate = BattlepassConfig.SEASON_REFRESH_RATE - (now % BattlepassConfig.SEASON_REFRESH_RATE)

	local days = math.floor(timeUntilNextUpdate / 60 / 60 / 24)
	local hours = math.floor(timeUntilNextUpdate / 60 / 60) % 24
	local minutes = math.floor(timeUntilNextUpdate / 60) % 60
	local seconds = timeUntilNextUpdate % 60

	if minutes < 10 then
		minutes = "0" .. minutes
	end

	if seconds < 10 then
		seconds = "0" .. seconds
	end

	return days, hours, minutes, seconds
end

function BattlepassWidget:Initialize()
	self.isActive = false
	--Initialize the screen guis
	--battlepass gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassGui") then
		BattlepassGui = Assets.GuiObjects.ScreenGuis.BattlepassGui or game.Players.LocalPlayer.PlayerGui.BattlepassGui
		BattlepassGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassGui = game.Players.LocalPlayer.PlayerGui.BattlepassGui
	end
	--battlepass preview gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassPreviewGui") then
		BattlepassPreviewGui = Assets.GuiObjects.ScreenGuis.BattlepassPreviewGui
			or game.Players.LocalPlayer.PlayerGui.BattlepassPreviewGui
		BattlepassPreviewGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassPreviewGui = game.Players.LocalPlayer.PlayerGui.BattlepassPreviewGui
	end
	--battlepass gift gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassGiftGui") then
		BattlepassGiftGui = Assets.GuiObjects.ScreenGuis.BattlepassGiftGui
			or game.Players.LocalPlayer.PlayerGui.BattlepassGiftGui
		BattlepassGiftGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassGiftGui = game.Players.LocalPlayer.PlayerGui.BattlepassGiftGui
	end
	--Initialize the battlepass gui variables
	currentLevelFrame = BattlepassGui.MainFrame.CurrentLevelFrame
	rewardsFrame = BattlepassGui.MainFrame.RewardsFrame
	previewViewportFrame = BattlepassPreviewGui.MainFrame.PreviewViewportFrame
	timerTextLabel = BattlepassGui.MainFrame.TimerTextLabel
	rewardsDescriptionFrame = BattlepassGui.MainFrame.RewardsDescriptionFrame

	--Disable the screen guis
	BattlepassPreviewGui.Enabled = false
	BattlepassGui.Enabled = false
	BattlepassGiftGui.Enabled = false

	--Set up the back button
	local backButtonFrame = BattlepassGui.BackButtonFrame

	BattlepassWidget.MainFrame = game.Players.LocalPlayer.PlayerGui.BattlepassGui.MainFrame
	--Hide the main frame with group transparency
	BattlepassWidget.MainFrame.GroupTransparency = 1
	--Connect any events
	BattlepassService.LevelUp:Connect(function(newLevel)
		--Check if the battlepass is active
		if not self.isActive then
			return
		end
		player:SetAttribute("CurrentLevel", newLevel)
		--Make sure the reward frame exists
		if not rewardsFrame[newLevel] then
			return
		end
		--Assign the current level
		currentLevelFrame.BarFrame.currentLevelText.Text = newLevel
		--Assign the next level
		if newLevel == BattlepassConfig.seasons[seasonData.currentSeason].maxLevel then
			currentLevelFrame.BarFrame.nextLevelText.Text = "MAX"
		else
			currentLevelFrame.BarFrame.nextLevelText.Text = newLevel + 1
		end

		rewardsFrame[newLevel].FreeClaimFrame.Visible = true
		local shineTween = WidgetController:AnimateShineForFrame(rewardsFrame[newLevel].FreeClaimFrame, false, true)
		--Connect the claim button
		rewardsFrame[newLevel].FreeClaimFrame.ClaimButton.Activated:Connect(function()
			rewardsFrame[newLevel].FreeClaimFrame.ClaimedText.Visible = true
			--Create the Claim button
			ButtonWidget.new(rewardsFrame[newLevel].FreeClaimFrame.ClaimButton, function()
				BattlepassService:ClaimBattlepassReward(newLevel, "freepass")
				rewardsFrame[newLevel].FreeClaimFrame.ClaimButton:Destroy()
				WidgetController:StopAnimationForTween(shineTween)
			end)
		end)
	end)

	BattlepassService.BattlepassExperienceAdded:Connect(function(currentSeasonData)
		--Check if the battlepass is active
		if not self.isActive then
			return
		end
		--Update the progress bars
		BattlepassService:GetExperienceNeededForNextLevel():andThen(function(experienceNeeded)
			--Fill the progress bar of previous levels
			for i = 1, currentSeasonData.level do
				local progressBar = rewardsFrame[i].ProgressBarFrame.BarFrame.ProgressBar
				local x, y = ScaleToOffset(1, 0.9, rewardsFrame[i].ProgressBarFrame.BarFrame)
				progressBar.Size = UDim2.fromOffset(x, y)
			end
			local currentLevelExperienceBar =
				rewardsFrame[currentSeasonData.level].ProgressBarFrame.BarFrame.ProgressBar
			local x, y = ScaleToOffset(
				(currentSeasonData.experience / experienceNeeded) * 1,
				currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale,
				rewardsFrame[currentSeasonData.level].ProgressBarFrame.BarFrame
			)
			currentLevelExperienceBar.Size = UDim2.fromOffset(x, y)
			currentLevelFrame.BarFrame.LevelBar.Size = UDim2.fromScale(
				(currentSeasonData.experience / experienceNeeded) * 1,
				currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale
			)
			--Assign the current xp
			currentLevelFrame.BarFrame.XPText.Text = currentSeasonData.experience .. "/" .. experienceNeeded
		end)
	end)

	BattlepassService.BattlepassObtained:Connect(function()
		if BattlepassGui.Enabled then
			task.delay(2, function()
				for i = 1, player:GetAttribute("CurrentLevel") do
					local battlepassRewardFrame = rewardsFrame[i]
					local padlockIcon = battlepassRewardFrame.BattlepassPadlockIcon
					local padlockRotationTween = TweenService:Create(
						padlockIcon,
						TweenInfo.new(1.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
						{ Rotation = 125 }
					)
					padlockRotationTween:Play()
					padlockRotationTween.Completed:Connect(function()
						local padlockPositionTween = TweenService:Create(
							padlockIcon,
							TweenInfo.new(1),
							{ Position = UDim2.fromScale(padlockIcon.Position.X.Scale, 0.99), ImageTransparency = 1 }
						)
						padlockPositionTween:Play()
					end)
					battlepassRewardFrame.BattlepassClaimFrame.Visible = true
					local shineTween =
						WidgetController:AnimateShineForFrame(battlepassRewardFrame.BattlepassClaimFrame, false, true)
					--Create the claim button
					ButtonWidget.new(battlepassRewardFrame.BattlepassClaimFrame.ClaimButton, function()
						BattlepassService:ClaimBattlepassReward(i, "battlepass")
						battlepassRewardFrame.BattlepassClaimFrame.ClaimButton:Destroy()
						WidgetController:StopAnimationForTween(shineTween)
						battlepassRewardFrame.BattlepassClaimFrame.ClaimedText.Visible = true
						--Claiming the battlepass reward will also claim the free reward if the player hasn't claimed it yet
						if seasonData and not table.find(seasonData.claimedLevels.freepass, i) then
							battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
							battlepassRewardFrame.FreeClaimFrame.Visible = true
							battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
						end
					end)
				end
			end)
		end
	end)
	--Buttons
	ButtonWidget.new(backButtonFrame, function()
		BattlepassWidget:CloseBattlepass()
	end)
	--Create the buy button
	ButtonWidget.new(BattlepassGui.MainFrame.BuyButtonFrame, function()
		BattlepassService:BuyBattlepass()
	end)

	--Create gift battlepass button
	ButtonWidget.new(BattlepassGui.MainFrame.GiftButtonFrame, function()
		BattlepassWidget:OpenGiftBattlepass()
	end)

	--Close button battlepass gift
	ButtonWidget.new(BattlepassGiftGui.MainFrame.CloseButtonFrame, function()
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

	--Create the gift confirmation button
	ButtonWidget.new(BattlepassGiftGui.MainFrame.GiftButtonFrame, function()
		local userToGiftID = Players:GetUserIdFromNameAsync(BattlepassGiftGui.MainFrame.TextBox.Text)
		if userToGiftID then
			BattlepassService:GiftBattlepass(userToGiftID)
			BattlepassGiftGui.MainFrame.GiftButtonFrame.button.Text = "GIFTED"
			BattlepassGiftGui.MainFrame.GiftButtonFrame.button.ImageColor3 = Color3.fromRGB(0, 255, 0)
			BattlepassGiftGui.MainFrame.GiftButtonFrame.button.ImageTransparency = 0
			BattlepassGiftGui.MainFrame.GiftButtonFrame.button.Active = false
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
	--Clean up viewport connection after displaying a new preview
	if viewportConnection then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame:ClearAllChildren()
		viewportConnection:Disconnect()
	end
	if rewardInfo.rewardType == RewardsEnum.RewardTypes.Skin then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = true
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = false
		BattlepassWidget.CurrentRewardItem = nil
		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text =
			rewardInfo.rewardSkin.name:gsub("_", " ")
		--Assign the correct reward description
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardDescription.Text =
			RewardsEnum.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level
		--Generate the weapon model preview with the skin and parent it to the viewportFrame
		DataService:GetLoadout():andThen(function(loadout: table)
			local weaponModel =
				WeaponCustomizationController:CreateWeaponPreviewWithSkin(loadout.weaponEquipped, rewardInfo.rewardSkin)
			--create the camera
			local camera = Instance.new("Camera")
			camera.Parent = BattlepassGui
			local dtrViewportFrame = DragToRotateViewportFrame.New(previewViewportFrame, camera)

			dtrViewportFrame:SetModel(weaponModel)
			dtrViewportFrame.MouseMode = "Default"

			viewportConnection = previewViewportFrame.InputBegan:Connect(function(inputObject)
				if
					inputObject.UserInputType == Enum.UserInputType.MouseButton1
					or inputObject.UserInputType == Enum.UserInputType.Touch
				then
					dtrViewportFrame:BeginDragging()

					inputObject.Changed:Connect(function()
						if inputObject.UserInputState == Enum.UserInputState.End then
							dtrViewportFrame:StopDragging()
						end
					end)
				end
			end)
		end)
	elseif rewardInfo.rewardType == RewardsEnum.RewardTypes.Crate then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = true
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = false
		BattlepassWidget.CurrentRewardItem = nil
		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.crateName:gsub("_", " ")
		--Assign the correct reward description
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardDescription.Text =
			RewardsEnum.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level
		--Get the crate model
		local crateModel = Assets.Models.Crates[rewardInfo.crateName]:Clone()
		--create the camera
		local camera = Instance.new("Camera")
		camera.Parent = BattlepassGui
		local dtrViewportFrame = DragToRotateViewportFrame.New(previewViewportFrame, camera)

		dtrViewportFrame:SetModel(crateModel)
		dtrViewportFrame.MouseMode = "Default"

		viewportConnection = previewViewportFrame.InputBegan:Connect(function(inputObject)
			if
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
				dtrViewportFrame:BeginDragging()

				inputObject.Changed:Connect(function()
					if inputObject.UserInputState == Enum.UserInputState.End then
						dtrViewportFrame:StopDragging()
					end
				end)
			end
		end)
	elseif rewardInfo.rewardType == RewardsEnum.RewardTypes.Emote then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = true
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = false
		BattlepassWidget.CurrentRewardItem = nil
		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.emoteName:gsub("_", " ")
		--Assign the correct reward description
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardDescription.Text =
			RewardsEnum.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level
		local emoteAnimation = Instance.new("Animation")
		--Play emote
		emoteAnimation.AnimationId = rewardInfo.rewardEmote.animation
		emoteAnimation.Name = rewardInfo.rewardEmote.name
		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = previewViewportFrame

		local worldModel = EmoteController:DisplayEmotePreview(rewardInfo.rewardEmote.name, viewportCamera)
		local dtrViewportFrame = DragToRotateViewportFrame.New(previewViewportFrame, viewportCamera)

		dtrViewportFrame:SetModel(worldModel)
		dtrViewportFrame.MouseMode = "Default"

		viewportConnection = previewViewportFrame.InputBegan:Connect(function(inputObject)
			if
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
				dtrViewportFrame:BeginDragging()

				inputObject.Changed:Connect(function()
					if inputObject.UserInputState == Enum.UserInputState.End then
						dtrViewportFrame:StopDragging()
					end
				end)
			end
		end)
	elseif rewardInfo.rewardType == RewardsEnum.RewardTypes.Emote_Icon then
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = false

		BattlepassWidget.CurrentRewardItem = nil

		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.rewardEmoteIcon.name
		--Assign the correct reward description
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardDescription.Text =
			RewardsEnum.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level

		BattlepassPreviewGui.MainFrame.RewardImage.Image = rewardInfo.rewardEmoteIcon.imageID
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
	elseif rewardInfo.rewardType == RewardsEnum.RewardTypes.Weapon then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = true
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = false
		BattlepassWidget.CurrentRewardItem = nil
		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.weaponName:gsub("_", " ")
		--Assign the correct reward description
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardDescription.Text =
			RewardsEnum.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level
		--Generate the weapon model preview with the skin and parent it to the viewportFrame
		local weaponModel: Model = weapons:FindFirstChild(rewardInfo.weaponName):FindFirstChildWhichIsA("Model"):Clone()
		--create the camera
		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = previewViewportFrame
		local dtrViewportFrame = DragToRotateViewportFrame.New(previewViewportFrame, viewportCamera)

		dtrViewportFrame:SetModel(weaponModel)
		dtrViewportFrame.MouseMode = "Default"

		viewportConnection = previewViewportFrame.InputBegan:Connect(function(inputObject)
			if
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
				dtrViewportFrame:BeginDragging()

				inputObject.Changed:Connect(function()
					if inputObject.UserInputState == Enum.UserInputState.End then
						dtrViewportFrame:StopDragging()
					end
				end)
			end
		end)
	else
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = true

		BattlepassWidget.CurrentRewardItem = nil
		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward description
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardDescription.Text =
			RewardsEnum.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level

		BattlepassPreviewGui.MainFrame.RewardImage.Image = BattlepassConfig.RewardIcons[rewardInfo.rewardType]
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
	end
end

local function CreateItemRewardFrame(battlepassConfig: table, rewardInfo: table, rewardTypeFrame: Frame, level: number)
	--Create the item frame according to the reward type
	local rewardTypes = RewardsEnum.RewardTypes
	if rewardInfo.rewardType == rewardTypes.Emote then
		--ToDo: Code for emote
		local emote: table = rewardInfo.rewardEmote
		local emoteFrame = WidgetController:CreateEmoteFrame(rewardInfo.rewardEmote)
		emoteFrame.UIAspectRatioConstraint.AspectRatio = EMOTE_FRAME_ASPECT_RATIO
		emoteFrame.Parent = rewardTypeFrame
		--Connect the mouse enter events to the viewport
		emoteFrame.ViewportFrame.MouseEnter:Connect(function()
			if not BattlepassPreviewGui.Enabled then
				BattlepassPreviewGui.Enabled = true
			end
			if currentRewardFrameInPreview then
				-- currentRewardFrameInPreview:WaitForChild("SelectionFrame").Visible = false
				currentRewardFrameInPreview = nil
			end
			currentRewardFrameInPreview = emoteFrame
			--format the data to pass to the display preview
			local rewardInfo = {
				rewardType = rewardTypes.Emote,
				rarity = emote.rarity,
				emoteName = emote.name,
				rarityColor = RaritiesEnum.Colors[emote.rarity],
				rewardEmote = emote,
			}
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	elseif rewardInfo.rewardType == rewardTypes.Emote_Icon then
		local emoteIconFrame = WidgetController:CreateEmoteIconFrame(rewardInfo.rewardEmoteIcon)
		emoteIconFrame.Parent = rewardTypeFrame
		--Connect the mouse enter events to the viewport
		emoteIconFrame.EmoteIcon.MouseEnter:Connect(function()
			if not BattlepassPreviewGui.Enabled then
				BattlepassPreviewGui.Enabled = true
			end
			-- if currentRewardFrameInPreview then
			-- 	currentRewardFrameInPreview.SelectionFrame.Visible = false
			-- end
			currentRewardFrameInPreview = emoteIconFrame
			--format the data to pass to the display preview
			local rewardInfo = {
				rewardType = rewardTypes.Emote_Icon,
				rarity = rewardInfo.rewardEmoteIcon.rarity,
				rarityColor = RaritiesEnum.Colors[rewardInfo.rewardEmoteIcon.rarity],
				rewardEmoteIcon = rewardInfo.rewardEmoteIcon,
			}
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	elseif rewardInfo.rewardType == rewardTypes.Skin then
		--Create the skin frame
		local skinData = rewardInfo.rewardSkin
		WidgetController:CreateSkinFrame(skinData):andThen(function(skinFrame)
			skinFrame.Parent = rewardTypeFrame

			--Connect the mouse enter events to the viewport
			skinFrame.ViewportFrame.MouseEnter:Connect(function()
				if not BattlepassPreviewGui.Enabled then
					BattlepassPreviewGui.Enabled = true
				end
				-- if currentRewardFrameInPreview then
				-- 	currentRewardFrameInPreview.SelectionFrame.Visible = false
				-- end
				currentRewardFrameInPreview = skinFrame
				--format the data to pass to the display preview
				local rewardInfo = {
					rewardType = rewardTypes.Skin,
					rarity = skinData.rarity,
					rarityColor = RaritiesEnum.Colors[skinData.rarity],
					rewardSkin = skinData,
				}
				BattlepassWidget:DisplayPreview(rewardInfo, level)
			end)
		end)
	elseif rewardInfo.rewardType == rewardTypes.Crate then
		local crateFrame = WidgetController:CreateCrateFrame(
			rewardInfo.crateName,
			rewardTypeFrame,
			RaritiesEnum.Colors[RaritiesEnum.Mythic]
		)
		crateFrame.Parent = rewardTypeFrame
		--Connect the mouse enter events to the viewport
		crateFrame.ViewportFrame.MouseEnter:Connect(function()
			if not BattlepassPreviewGui.Enabled then
				BattlepassPreviewGui.Enabled = true
			end
			-- if currentRewardFrameInPreview then
			-- 	currentRewardFrameInPreview.SelectionFrame.Visible = false
			-- end
			currentRewardFrameInPreview = crateFrame
			--format the data to pass to the display preview
			local rewardInfo = {
				rewardType = rewardTypes.Crate,
				rarity = RaritiesEnum.Mythic,
				rarityColor = RaritiesEnum.Colors[RaritiesEnum.Mythic],
				crateName = rewardInfo.crateName,
			}
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	elseif rewardInfo.rewardType == rewardTypes.Weapon then
		local weaponFrame = WidgetController:CreateWeaponFrame(rewardInfo.weaponName, rewardTypeFrame)
		weaponFrame.Frame.BackgroundLabel.MouseEnter:Connect(function()
			if not BattlepassPreviewGui.Enabled then
				BattlepassPreviewGui.Enabled = true
			end
			-- if currentRewardFrameInPreview then
			-- 	currentRewardFrameInPreview.SelectionFrame.Visible = false
			-- end
			currentRewardFrameInPreview = weaponFrame.Frame
			--format the data to pass to the display preview
			local weapon = weapons:FindFirstChild(rewardInfo.weaponName)
			local rewardInfo = {
				rewardType = rewardTypes.Weapon,
				rarity = RaritiesEnum[weapon:GetAttribute("Rarity")],
				rarityColor = RaritiesEnum.Colors[weapon:GetAttribute("Rarity")],
				weaponName = rewardInfo.weaponName,
			}
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	else
		local rewardFrame
		rewardFrame = Assets.GuiObjects.Frames.BattlepassRewardItemFrame:Clone()
		rewardFrame.Parent = rewardTypeFrame
		--Assign the reward name, filtering the _ and replacing with spaces
		local rewardName = rewardInfo.rewardType:gsub("_", " ")
		rewardFrame.ItemName.Text = rewardName
		--Assign the color to the itemframe according to the reward rarity
		rewardFrame.ItemFrame.ImageColor3 = rewardInfo.rarityColor
		rewardFrame.ItemIcon.Image = battlepassConfig.RewardIcons[rewardInfo.rewardType]

		if rewardInfo.rewardAmount then
			rewardFrame.ItemAmount.Visible = true
			rewardFrame.ItemAmount.Text = FormatText.To_comma_value(rewardInfo.rewardAmount)
		end
		--Connect the mouse enter and leave events
		rewardFrame.ItemIcon.MouseEnter:Connect(function()
			if not BattlepassPreviewGui.Enabled then
				BattlepassPreviewGui.Enabled = true
			end
			-- if currentRewardFrameInPreview and currentRewardFrameInPreview:FindFirstChild("SelectionFrame") then
			-- 	currentRewardFrameInPreview.SelectionFrame.Visible = false
			-- end
			currentRewardFrameInPreview = rewardFrame
			-- rewardFrame.SelectionFrame.Visible = true
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	end
end

function BattlepassWidget:GenerateRewards(battlepassData)
	BattlepassService:GetBattlepassConfig():andThen(function(_battlepassConfig)
		BattlepassConfig = _battlepassConfig
		local seasonRewards = _battlepassConfig.rewards[battlepassData.currentSeason]
		for level, rankRewardsTable in seasonRewards do
			local battlepassRewardFrame = Assets.GuiObjects.Frames.BattlepassRewardFrame:Clone()
			--Name the frame with the rank
			battlepassRewardFrame.Name = level
			--Assign the rank text
			battlepassRewardFrame.RankText.Text = level
			--Assign the level as an attribute to the frame
			battlepassRewardFrame:SetAttribute("level", level)
			--Assign the current rank to the progress bar
			battlepassRewardFrame.ProgressBarFrame.BarFrame.currentRankText.Text = level
			--Set the bar size to 0
			battlepassRewardFrame.ProgressBarFrame.BarFrame.ProgressBar.Size = UDim2.fromScale(0, 0.9)
			battlepassRewardFrame.Parent = BattlepassWidget.MainFrame.RewardsFrame
			--Check if the player has claimed this rank and whether has claimed free or premium rewards
			seasonData = battlepassData[battlepassData.currentSeason]

			--Free levels
			if not table.find(seasonData.claimedLevels.freepass, level) and seasonData.level >= level then
				battlepassRewardFrame.FreePadlockIcon.Visible = false
				battlepassRewardFrame.FreeClaimFrame.Visible = true
				local shineTween =
					WidgetController:AnimateShineForFrame(battlepassRewardFrame.FreeClaimFrame, false, true)
				--If the reward is claimed in the battlepass reward frame, also claim it in the free reward and stop the tween
				battlepassRewardFrame.FreeClaimFrame.ClaimButton.Destroying:Connect(function()
					WidgetController:StopAnimationForTween(shineTween)
					task.wait()
				end)
				--Create the claim button
				ButtonWidget.new(battlepassRewardFrame.FreeClaimFrame.ClaimButton, function()
					BattlepassService:ClaimBattlepassReward(level, "freepass")
					battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
					WidgetController:StopAnimationForTween(shineTween)
					battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
				end)
			elseif table.find(seasonData.claimedLevels.freepass, level) then
				--If the player has already claimed the reward
				battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
				battlepassRewardFrame.FreeClaimFrame.Visible = true
				battlepassRewardFrame.FreePadlockIcon.Visible = false
				battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
			end

			--battlepass levels
			if
				not table.find(seasonData.claimedLevels.battlepass, level)
				and seasonData.level >= level
				and seasonData.owned
			then
				battlepassRewardFrame.BattlepassPadlockIcon.Visible = false
				battlepassRewardFrame.BattlepassClaimFrame.Visible = true
				local shineTween =
					WidgetController:AnimateShineForFrame(battlepassRewardFrame.BattlepassClaimFrame, false, true)
				--Create the claim button
				ButtonWidget.new(battlepassRewardFrame.BattlepassClaimFrame, function()
					BattlepassService:ClaimBattlepassReward(level, "battlepass")
					battlepassRewardFrame.BattlepassClaimFrame.ClaimButton:Destroy()
					WidgetController:StopAnimationForTween(shineTween)
					battlepassRewardFrame.BattlepassClaimFrame.ClaimedText.Visible = true
					--Claiming the battlepass reward will also claim the free reward if the player hasn't claimed it yet
					if not table.find(seasonData.claimedLevels.freepass, level) then
						battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
						battlepassRewardFrame.FreeClaimFrame.Visible = true
						battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
					end
				end)
			elseif table.find(seasonData.claimedLevels.battlepass, level) then
				--If the player has already claimed the reward
				battlepassRewardFrame.BattlepassClaimFrame.ClaimButton:Destroy()
				battlepassRewardFrame.BattlepassClaimFrame.Visible = true
				battlepassRewardFrame.BattlepassPadlockIcon.Visible = false
				battlepassRewardFrame.BattlepassClaimFrame.ClaimedText.Visible = true
			end

			--Generate the item rewards frames for each rank and separate them to premium rewards and free rewards
			for _, rewardInfo in rankRewardsTable.battlepass do
				CreateItemRewardFrame(_battlepassConfig, rewardInfo, battlepassRewardFrame.PremiumRewardsFrame, level)
			end
			for _, rewardInfo in rankRewardsTable.freepass do
				CreateItemRewardFrame(_battlepassConfig, rewardInfo, battlepassRewardFrame.FreeRewardsFrame, level)
			end

			--Assign the correct UIGridLayout cell size for the premium rewards according to the amount of rewards
			if #battlepassRewardFrame.PremiumRewardsFrame:GetChildren() <= 5 then
				battlepassRewardFrame.PremiumRewardsFrame.UIGridLayout.CellSize = UDim2.fromScale(0.49, 1)
			else
				battlepassRewardFrame.PremiumRewardsFrame.UIGridLayout.CellSize = UDim2.fromScale(0.33, 1)
			end
		end
	end)
end

function BattlepassWidget:AssignBattlepassRewardsDescription(currentSeason: string)
	local skins = 0
	local emotes = 0
	local crates = 0
	local emoteIcons = 0
	local battleGems = 0
	local battleCoins = 0
	local weapons = 0
	for index, value: table in BattlepassConfig.rewards[currentSeason] do
		for index, value: table in value.battlepass do
			if value.rewardType == RewardsEnum.RewardTypes.Skin then
				skins += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.Emote then
				emotes += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.Crate then
				crates += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.Emote_Icon then
				emoteIcons += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.BattleGems then
				battleGems += value.rewardAmount
			end
			if value.rewardType == RewardsEnum.RewardTypes.BattleCoins then
				battleCoins += value.rewardAmount
			end
			if value.rewardType == RewardsEnum.RewardTypes.Weapon then
				weapons += 1
			end
		end
		for index, value: table in value.freepass do
			if value.rewardType == RewardsEnum.RewardTypes.Skin then
				skins += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.Emote then
				emotes += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.Crate then
				crates += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.Emote_Icon then
				emoteIcons += 1
			end
			if value.rewardType == RewardsEnum.RewardTypes.BattleGems then
				battleGems += value.rewardAmount
			end
			if value.rewardType == RewardsEnum.RewardTypes.BattleCoins then
				battleCoins += value.rewardAmount
			end
			if value.rewardType == RewardsEnum.RewardTypes.Weapon then
				weapons += 1
			end
		end
	end
	--Format the results to display in the rewards description
	battleGems = FormatText.To_comma_value(battleGems)
	battleCoins = FormatText.To_comma_value(battleCoins)
	local rewardsDescription: string = string.format(
		"● %d Weapons<br/>● %d Skins<br/>● %d Emotes<br/>● %d Crates<br/>● %d Emote icons<br/>● %s BattleGems<br/>● %s BattleCoins",
		weapons,
		skins,
		emotes,
		crates,
		emoteIcons,
		battleGems,
		battleCoins
	)
	rewardsDescriptionFrame.RewardsTextLabel.Text = rewardsDescription
end

function BattlepassWidget:OpenBattlepass(callback: Function)
	self.isActive = true
	--Initialize timer for the battlepass
	task.spawn(function()
		while self.isActive do
			task.wait(1)
			local days, hours, minutes, seconds = getTimeUntilTextUpdate()
			timerTextLabel.Text = string.format(
				"Time left : <u>%02d days, %02d hours, %02d minutes and %02d seconds</u>",
				days,
				hours,
				minutes,
				seconds
			)
		end
	end)
	--Enable the screen gui and disable the chat gui
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

	BattlepassGui.Enabled = true
	--Set the callback
	BattlepassWidget.callback = callback
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, battlepassTweenInfo, { GroupTransparency = 0 })
	mainFrameTween:Play()
	--Tween battlepass preview gui position
	local previewGuiTween = TweenService:Create(
		BattlepassPreviewGui.MainFrame,
		battlepassTweenInfo,
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
		currentLevelFrame.BarFrame.currentLevelText.Text = currentSeasonData.level
		--Assign the next level
		if currentSeasonData.level == BattlepassConfig.seasons[currentSeason].maxLevel then
			currentLevelFrame.BarFrame.nextLevelText.Text = "MAX"
		else
			currentLevelFrame.BarFrame.nextLevelText.Text = currentSeasonData.level + 1
		end
		--Add as attributes the current level and current season to the player
		player:SetAttribute("CurrentLevel", currentSeasonData.level)
		player:SetAttribute("CurrentSeason", currentSeason)
		--Generate the rewards frame if they don't exist
		if #BattlepassWidget.MainFrame.RewardsFrame:GetChildren() <= 1 then
			BattlepassWidget:GenerateRewards(battlepassData)
			--Fill the progress bar of previous levels
			-- Assuming there's a variable `maxLevel` that holds the maximum level of the battlepass
			for i = 1, currentSeasonData.level do
				local progressBar = rewardsFrame:WaitForChild(tostring(i)).ProgressBarFrame.BarFrame.ProgressBar
				local x, y = ScaleToOffset(1, 0.9, rewardsFrame:WaitForChild(tostring(i)).ProgressBarFrame.BarFrame)
				progressBar.Size = UDim2.fromOffset(x, y)
			end
		end

		--Assign the battlepass rewards text to rewards text
		self:AssignBattlepassRewardsDescription(currentSeason)

		--Update the progress bars
		BattlepassService:GetExperienceNeededForNextLevel():andThen(function(experienceNeeded)
			if currentSeasonData.level == BattlepassConfig.seasons[currentSeason].maxLevel then
				currentLevelFrame.BarFrame.LevelBar.Size =
					UDim2.fromScale(1, currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale)
				currentLevelFrame.BarFrame.XPText.Text = "MAX LEVEL"
			else
				currentLevelFrame.BarFrame.LevelBar.Size = UDim2.fromScale(
					(currentSeasonData.experience / experienceNeeded) * 1,
					currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale
				)
				--Assign the current xp
				currentLevelFrame.BarFrame.XPText.Text = currentSeasonData.experience .. "/" .. experienceNeeded
			end

			--Get the current level to update the progress bar of the item reward rank
			local currentRank = currentSeasonData.level
			local x, y
			if currentRank == BattlepassConfig.seasons[currentSeason].maxLevel then
				x, y = ScaleToOffset(1, 0.9, rewardsFrame[currentRank].ProgressBarFrame.BarFrame)
			else
				x, y = ScaleToOffset(
					(currentSeasonData.experience / experienceNeeded) * 1,
					0.9,
					rewardsFrame[currentRank].ProgressBarFrame.BarFrame
				)
			end
			rewardsFrame[currentRank].ProgressBarFrame.BarFrame.ProgressBar.Size = UDim2.fromOffset(x, y)
		end)
	end)
end

function BattlepassWidget:CloseBattlepass()
	self.isActive = false
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, battlepassTweenInfo, { GroupTransparency = 1 })
	mainFrameTween:Play()
	--Tween battlepass preview gui position
	local previewGuiTween = TweenService:Create(
		BattlepassPreviewGui.MainFrame,
		battlepassTweenInfo,
		{ Position = UDim2.fromScale(1, BattlepassPreviewGui.MainFrame.Position.Y.Scale) }
	)
	--Destroy the rewards frames
	for _, rewardFrame in pairs(BattlepassWidget.MainFrame.RewardsFrame:GetChildren()) do
		if rewardFrame:IsA("Frame") then
			rewardFrame:Destroy()
		end
	end
	previewGuiTween:Play()
	mainFrameTween.Completed:Connect(function()
		BattlepassGui.Enabled = false
		BattlepassPreviewGui.Enabled = false
		--Reenable the core guis
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		BattlepassWidget.callback()
	end)
end

return BattlepassWidget:Initialize()
