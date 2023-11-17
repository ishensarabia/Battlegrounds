--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
--Main
local BattlepassWidget = {}
local player = Players.LocalPlayer
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Services
local BattlepassService = Knit.GetService("BattlepassService")
local DataService = Knit.GetService("DataService")
--Controllers
local UIController = Knit.GetController("UIController")
local EmoteController = Knit.GetController("EmoteController")
local WeaponCustomizationController = Knit.GetController("WeaponCustomizationController")
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
local viewportFrame
--Connections
local viewportConnection
--Variables
local seasonData
local battlepassTweenInfo = TweenInfo.new(0.69, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

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
	viewportFrame = BattlepassPreviewGui.MainFrame.PreviewViewportFrame
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
	--Hide the main frame with group transparency
	BattlepassWidget.MainFrame.GroupTransparency = 1
	--Connect any events
	BattlepassService.LevelUp:Connect(function(newLevel)
		player:SetAttribute("CurrentLevel", newLevel)
		--Make sure the reward frame exists
		if not rewardsFrame[newLevel] then
			return
		end
		--Assign the current level
		currentLevelFrame.BarFrame.currentLevelText.Text = newLevel
		--Assign the next level
		currentLevelFrame.BarFrame.nextLevelText.Text = newLevel + 1
		rewardsFrame[newLevel].FreeClaimFrame.Visible = true
		local shineTween = UIController:AnimateShineForFrame(rewardsFrame[newLevel].FreeClaimFrame, false, true)
		--Connect the claim button
		rewardsFrame[newLevel].FreeClaimFrame.ClaimButton.Activated:Connect(function()
			rewardsFrame[newLevel].FreeClaimFrame.ClaimedText.Visible = true
			ButtonWidget:OnActivation(rewardsFrame[newLevel].FreeClaimFrame.ClaimButton, function()
				BattlepassService:ClaimBattlepassReward(newLevel)
				rewardsFrame[newLevel].FreeClaimFrame.ClaimButton:Destroy()
				UIController:StopAnimationForTween(shineTween)
			end)
		end)
	end)

	BattlepassService.BattlepassExperienceAdded:Connect(function(currentSeasonData)
		--Update the progress bars
		BattlepassService:GetExperienceNeededForNextLevel():andThen(function(experienceNeeded)
			--Fill the progress bar of previous levels
			for i = 1, currentSeasonData.Level do
				local progressBar = rewardsFrame[i].ProgressBarFrame.BarFrame.ProgressBar
				local x, y = ScaleToOffset(1, 0.9, rewardsFrame[i].ProgressBarFrame.BarFrame)
				progressBar.Size = UDim2.fromOffset(x, y)
			end
			local currentLevelExperienceBar =
				rewardsFrame[currentSeasonData.Level].ProgressBarFrame.BarFrame.ProgressBar
			local x, y = ScaleToOffset(
				(currentSeasonData.Experience / experienceNeeded) * 1,
				currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale,
				rewardsFrame[currentSeasonData.Level].ProgressBarFrame.BarFrame
			)
			currentLevelExperienceBar.Size = UDim2.fromOffset(x, y)
			currentLevelFrame.BarFrame.LevelBar.Size = UDim2.fromScale(
				(currentSeasonData.Experience / experienceNeeded) * 1,
				currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale
			)
			--Assign the current xp
			currentLevelFrame.BarFrame.XPText.Text = currentSeasonData.Experience .. "/" .. experienceNeeded
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
						UIController:AnimateShineForFrame(battlepassRewardFrame.BattlepassClaimFrame, false, true)
					--Connect the claim button
					battlepassRewardFrame.BattlepassClaimFrame.ClaimButton.Activated:Connect(function()
						ButtonWidget:OnActivation(battlepassRewardFrame.BattlepassClaimFrame.ClaimButton, function()
							BattlepassService:ClaimBattlepassReward(i, "Battlepass")
							battlepassRewardFrame.BattlepassClaimFrame.ClaimButton:Destroy()
							UIController:StopAnimationForTween(shineTween)
							battlepassRewardFrame.BattlepassClaimFrame.ClaimedText.Visible = true
							--Claiming the battlepass reward will also claim the free reward if the player hasn't claimed it yet
							if seasonData and not table.find(seasonData.ClaimedLevels.Freepass, i) then
								battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
								battlepassRewardFrame.FreeClaimFrame.Visible = true
								battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
							end
						end)
					end)
				end
			end)
		end
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
	--Clean up viewport connection after displaying a new preview
	if viewportConnection then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame:ClearAllChildren()
		viewportConnection:Disconnect()
	end
	if rewardInfo.rewardType == battlepassConfig.RewardTypes.Skin then
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
			battlepassConfig.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level
		--Generate the weapon model preview with the skin and parent it to the viewportFrame
		DataService:GetLoadout():andThen(function(loadout: table)
			local weaponModel = WeaponCustomizationController:CreateWeaponPreviewWithSkin(
				loadout.WeaponEquipped,
				rewardInfo.rewardSkin.skinID
			)
			--create the camera
			local camera = Instance.new("Camera")
			camera.Parent = BattlepassGui
			local dtrViewportFrame = DragToRotateViewportFrame.New(viewportFrame, camera)

			dtrViewportFrame:SetModel(weaponModel)
			dtrViewportFrame.MouseMode = "Default"

			viewportConnection = viewportFrame.InputBegan:Connect(function(inputObject)
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
	elseif rewardInfo.rewardType == battlepassConfig.RewardTypes.Crate then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = true
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = false
		BattlepassWidget.CurrentRewardItem = nil
		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.crateName:gsub("_", " ")
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
		--Get the crate model
		local crateModel = Assets.Models.Crates[rewardInfo.crateName]:Clone()
		--create the camera
		local camera = Instance.new("Camera")
		camera.Parent = BattlepassGui
		local dtrViewportFrame = DragToRotateViewportFrame.New(viewportFrame, camera)

		dtrViewportFrame:SetModel(crateModel)
		dtrViewportFrame.MouseMode = "Default"

		viewportConnection = viewportFrame.InputBegan:Connect(function(inputObject)
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
	elseif rewardInfo.rewardType == battlepassConfig.RewardTypes.Emote then
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = true
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = false
		BattlepassWidget.CurrentRewardItem = nil
		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.emoteName:gsub("_", " ")
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
		local emoteAnimation = Instance.new("Animation")
		--Play emote
		emoteAnimation.AnimationId = rewardInfo.rewardEmote.animation
		emoteAnimation.Name = rewardInfo.rewardEmote.name
		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = viewportFrame

		local worldModel = EmoteController:DisplayEmotePreview(rewardInfo.rewardEmote.name, viewportCamera)
		local dtrViewportFrame = DragToRotateViewportFrame.New(viewportFrame, viewportCamera)

		dtrViewportFrame:SetModel(worldModel)
		dtrViewportFrame.MouseMode = "Default"

		viewportConnection = viewportFrame.InputBegan:Connect(function(inputObject)
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
	elseif rewardInfo.rewardType == battlepassConfig.RewardTypes.Emote_Icon then
		warn(rewardInfo)
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
		BattlepassPreviewGui.MainFrame.PreviewViewportFrame.Visible = false

		BattlepassWidget.CurrentRewardItem = nil

		--Assign the reward type to the preview frame
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardType.Text = rewardInfo.rewardType:gsub("_", " ")
		--Assign the correct reward name
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardName.Text = rewardInfo.rewardEmoteIcon.name
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

		BattlepassPreviewGui.MainFrame.RewardImage.Image = rewardInfo.rewardEmoteIcon.imageID
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
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
			battlepassConfig.RewardDescriptions[rewardInfo.rewardType]
		--Assign the rarity text and color
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.Text = rewardInfo.rarity
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRarity.TextColor3 = rewardInfo.rarityColor
		--Set the background color of the item frame to the rarity color
		BattlepassPreviewGui.MainFrame.BackgroundColor3 = rewardInfo.rarityColor
		--Assign the reward required level
		BattlepassPreviewGui.MainFrame.PreviewDescriptionFrame.RewardRequirement.Text = "Required level " .. level

		BattlepassPreviewGui.MainFrame.RewardImage.Image = battlepassConfig.RewardIcons[rewardInfo.rewardType]
		BattlepassPreviewGui.MainFrame.RewardImage.Visible = true
	end
end

local function CreateItemRewardFrame(battlepassConfig: table, rewardInfo: table, rewardTypeFrame: Frame, level: number)
	--Create the item frame according to the reward type
	local rewardTypes = battlepassConfig.RewardTypes
	if rewardInfo.rewardType == rewardTypes.Emote then
		--ToDo: Code for emote
		local emote: table = rewardInfo.rewardEmote
		local emoteFrame = UIController:CreateEmoteFrame(rewardInfo.rewardEmote)
		emoteFrame.Parent = rewardTypeFrame
		--Connect the mouse enter events to the viewport
		emoteFrame.ViewportFrame.MouseEnter:Connect(function()
			if not BattlepassPreviewGui.Enabled then
				BattlepassPreviewGui.Enabled = true
			end
			-- if currentRewardFrameInPreview then
			-- 	currentRewardFrameInPreview.SelectionFrame.Visible = false
			-- end
			currentRewardFrameInPreview = emoteFrame
			--format the data to pass to the display preview
			local rewardInfo = {
				rewardType = rewardTypes.Emote,
				rarity = emote.rarity,
				emoteName = emote.name,
				rarityColor = battlepassConfig.RarityColors[emote.rarity],
				rewardEmote = emote,
			}
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	elseif rewardInfo.rewardType == rewardTypes.Emote_Icon then
		local emoteIconFrame = UIController:CreateEmoteIconFrame(rewardInfo.rewardEmoteIcon)
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
				rarityColor = battlepassConfig.RarityColors[rewardInfo.rewardEmoteIcon.rarity],
				rewardEmoteIcon = rewardInfo.rewardEmoteIcon,
			}
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	elseif rewardInfo.rewardType == rewardTypes.Skin then
		--Create the skin frame
		local skinData = rewardInfo.rewardSkin
		UIController:CreateSkinFrame(skinData.skinID, skinData.name, skinData.rarity):andThen(function(skinFrame)
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
					rarityColor = battlepassConfig.RarityColors[skinData.rarity],
					rewardSkin = skinData,
				}
				BattlepassWidget:DisplayPreview(rewardInfo, level)
			end)
		end)
	elseif rewardInfo.rewardType == rewardTypes.Crate then
		local crateFrame = UIController:CreateCrateFrame(
			rewardInfo.crateName,
			rewardTypeFrame,
			battlepassConfig.RarityColors["Mythic"]
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
				rarity = "Mythic",
				rarityColor = battlepassConfig.RarityColors["Mythic"],
				crateName = rewardInfo.crateName,
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
			rewardFrame.ItemAmount.Text = rewardInfo.rewardAmount
		end
		--Connect the mouse enter and leave events
		rewardFrame.ItemIcon.MouseEnter:Connect(function()
			if not BattlepassPreviewGui.Enabled then
				BattlepassPreviewGui.Enabled = true
			end
			if currentRewardFrameInPreview and currentRewardFrameInPreview:FindFirstChild("SelectionFrame") then
				currentRewardFrameInPreview.SelectionFrame.Visible = false
			end
			currentRewardFrameInPreview = rewardFrame
			rewardFrame.SelectionFrame.Visible = true
			BattlepassWidget:DisplayPreview(rewardInfo, level)
		end)
	end
end

function BattlepassWidget:GenerateRewards(battlepassData)
	warn(battlepassData)
	BattlepassService:GetBattlepassConfig():andThen(function(_battlepassConfig)
		battlepassConfig = _battlepassConfig
		local seasonRewards = _battlepassConfig.rewards[battlepassData.currentSeason]
		for level, rankRewardsTable in seasonRewards do
			local battlepassRewardFrame = Assets.GuiObjects.Frames.BattlepassRewardFrame:Clone()
			--Name the frame with the rank
			battlepassRewardFrame.Name = level
			--Assign the rank text
			battlepassRewardFrame.RankText.Text = level
			--Assign the level as an attribute to the frame
			battlepassRewardFrame:SetAttribute("Level", level)
			--Assign the current rank to the progress bar
			battlepassRewardFrame.ProgressBarFrame.BarFrame.currentRankText.Text = level
			--Set the bar size to 0
			battlepassRewardFrame.ProgressBarFrame.BarFrame.ProgressBar.Size = UDim2.fromScale(0, 0.9)
			battlepassRewardFrame.Parent = BattlepassWidget.MainFrame.RewardsFrame
			--Check if the player has claimed this rank and whether has claimed free or premium rewards
			seasonData = battlepassData[battlepassData.currentSeason]

			--Free levels
			if not table.find(seasonData.ClaimedLevels.Freepass, level) and seasonData.Level >= level then
				battlepassRewardFrame.FreePadlockIcon.Visible = false
				battlepassRewardFrame.FreeClaimFrame.Visible = true
				local shineTween = UIController:AnimateShineForFrame(battlepassRewardFrame.FreeClaimFrame, false, true)
				--If the reward is claimed in the battlepass reward frame, also claim it in the free reward and stop the tween
				battlepassRewardFrame.FreeClaimFrame.ClaimButton.Destroying:Connect(function()
					UIController:StopAnimationForTween(shineTween)
					task.wait()
				end)
				--Connect the claim button
				battlepassRewardFrame.FreeClaimFrame.ClaimButton.Activated:Connect(function()
					ButtonWidget:OnActivation(battlepassRewardFrame.FreeClaimFrame.ClaimButton, function()
						BattlepassService:ClaimBattlepassReward(level, "Freepass")
						battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
						UIController:StopAnimationForTween(shineTween)
						battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
					end)
				end)
			elseif table.find(seasonData.ClaimedLevels.Freepass, level) then
				--If the player has already claimed the reward
				battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
				battlepassRewardFrame.FreeClaimFrame.Visible = true
				battlepassRewardFrame.FreePadlockIcon.Visible = false
				battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
			end

			--Battlepass levels
			if
				not table.find(seasonData.ClaimedLevels.Battlepass, level)
				and seasonData.Level >= level
				and seasonData.Owned
			then
				battlepassRewardFrame.BattlepassPadlockIcon.Visible = false
				battlepassRewardFrame.BattlepassClaimFrame.Visible = true
				local shineTween =
					UIController:AnimateShineForFrame(battlepassRewardFrame.BattlepassClaimFrame, false, true)
				--Connect the claim button
				battlepassRewardFrame.BattlepassClaimFrame.ClaimButton.Activated:Connect(function()
					ButtonWidget:OnActivation(battlepassRewardFrame.BattlepassClaimFrame.ClaimButton, function()
						BattlepassService:ClaimBattlepassReward(level, "Battlepass")
						battlepassRewardFrame.BattlepassClaimFrame.ClaimButton:Destroy()
						UIController:StopAnimationForTween(shineTween)
						battlepassRewardFrame.BattlepassClaimFrame.ClaimedText.Visible = true
						--Claiming the battlepass reward will also claim the free reward if the player hasn't claimed it yet
						if not table.find(seasonData.ClaimedLevels.Freepass, level) then
							battlepassRewardFrame.FreeClaimFrame.ClaimButton:Destroy()
							battlepassRewardFrame.FreeClaimFrame.Visible = true
							battlepassRewardFrame.FreeClaimFrame.ClaimedText.Visible = true
						end
					end)
				end)
			elseif table.find(seasonData.ClaimedLevels.Battlepass, level) then
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
			if #battlepassRewardFrame.PremiumRewardsFrame:GetChildren() <= 7 then
				battlepassRewardFrame.PremiumRewardsFrame.UIGridLayout.CellSize = UDim2.fromScale(0.49, 1)
			end

			if #battlepassRewardFrame.PremiumRewardsFrame:GetChildren() > 7 then
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
		currentLevelFrame.BarFrame.currentLevelText.Text = currentSeasonData.Level
		--Assign the next level
		currentLevelFrame.BarFrame.nextLevelText.Text = currentSeasonData.Level + 1
		--Add as attributes the current level and current season to the player
		player:SetAttribute("CurrentLevel", currentSeasonData.Level)
		player:SetAttribute("CurrentSeason", currentSeason)
		--Generate the rewards frame if they don't exist
		if #BattlepassWidget.MainFrame.RewardsFrame:GetChildren() <= 1 then
			BattlepassWidget:GenerateRewards(battlepassData)
			--Fill the progress bar of previous levels
			for i = 1, currentSeasonData.Level do
				local progressBar = rewardsFrame:WaitForChild(i).ProgressBarFrame.BarFrame.ProgressBar
				local x, y = ScaleToOffset(1, 0.9, rewardsFrame[i].ProgressBarFrame.BarFrame)
				progressBar.Size = UDim2.fromOffset(x, y)
			end
		end

		--Update the progress bars
		BattlepassService:GetExperienceNeededForNextLevel():andThen(function(experienceNeeded)
			currentLevelFrame.BarFrame.LevelBar.Size = UDim2.fromScale(
				(currentSeasonData.Experience / experienceNeeded) * 1,
				currentLevelFrame.BarFrame.LevelBar.Size.Y.Scale
			)
			--Assign the current xp
			currentLevelFrame.BarFrame.XPText.Text = currentSeasonData.Experience .. "/" .. experienceNeeded

			--Get the current level to update the progress bar of the item reward rank
			local currentRank = currentSeasonData.Level
			local x, y = ScaleToOffset(
				(currentSeasonData.Experience / experienceNeeded) * 1,
				0.9,
				rewardsFrame[currentRank].ProgressBarFrame.BarFrame
			)
			rewardsFrame[currentRank].ProgressBarFrame.BarFrame.ProgressBar.Size = UDim2.fromOffset(x,y)

		end)
	end)
end

function BattlepassWidget:CloseBattlepass()
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, battlepassTweenInfo, { GroupTransparency = 1  })
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
		BattlepassWidget.callback()
	end)
end

return BattlepassWidget:Initialize()
