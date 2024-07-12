--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Main
local NotificationWidget = {}
local isInitialized = false
--Controllers
local WidgetController
--Notifiaction tween info
local notificationTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, true, 0)
local transparencyTweenInfo = TweenInfo.new(1.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true)
--Constants
local DELAY_TIME_BEFORE_NOTIFICATION = 0.33

function NotificationWidget:Initialize()
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("NotificationGui") then
		NotificationWidget.NotificationGui = Assets.GuiObjects.ScreenGuis.NotificationGui
			or game.Players.LocalPlayer.PlayerGui.NotificationGui
		NotificationWidget.NotificationGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		NotificationWidget.NotificationGui = game.Players.LocalPlayer.PlayerGui.NotificationGui
	end
	WidgetController = Knit.GetController("WidgetController")
	--Enable the gui
	NotificationWidget.NotificationGui.Enabled = true
	--Hide the notification frames
	NotificationWidget.NotificationGui.DeathNotificationFrame.Position =
		UDim2.new(NotificationWidget.NotificationGui.DeathNotificationFrame.Position.X.Scale, 0, -1, 0)

	--Get notification and audio controller
	NotificationWidget.NotificationController = Knit.GetController("NotificationController")
	NotificationWidget.AudioController = Knit.GetController("AudioController")
end

local function AnimateShineForFrame(frame: Frame, transitionTransparency: boolean)
	local gradient = frame:FindFirstChildOfClass("UIGradient")
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	local transparencyTweenInfo = TweenInfo.new(0.66, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	if transitionTransparency then
		local transparencyTween = TweenService:Create(frame, transparencyTweenInfo, { Transparency = 0.6 })
		transparencyTween:Play()
	end
	local tweenGoals = { Offset = Vector2.new(1, 0) }
	local shineTween = TweenService:Create(gradient, tweenInfo, tweenGoals)
	local startingPos = Vector2.new(-1, 0) --start on the right, tween to the left so it looks like the shine went from left to right
	local addWait = 2.5 --the amount of seconds between each couplet of shines

	shineTween:Play()
	shineTween.Completed:Connect(function()
		gradient.Offset = startingPos --reset offset
	end)
	shineTween:Play() --play again (I did this only 2 times per "couplet", you can do it more times if you want)
	shineTween.Completed:Connect(function()
		gradient.Offset = startingPos --reset offset
	end)
end

--Set the size of the text labels to 0 function
local function hideTextLabelsBySize(object: Frame?)
	for index, child in object:GetChildren() do
		if child:IsA("TextLabel") then
			child.Size = UDim2.fromScale(0, 0)
		end
	end
end

local function createTween(object, attributeName, targetSize)
	local tween = TweenService:Create(object, notificationTweenInfo, { [attributeName] = targetSize })
	tween:Play()
	return tween
end

--Function to create a notification
function NotificationWidget:DisplayNotification(notificationType: string, params: table)
	-- warn(params)
	if not isInitialized then
		NotificationWidget:Initialize()
	end
	NotificationWidget.NotificationGui.Enabled = true

	if notificationType == NotificationWidget.NotificationController.Notifications.Feed then
		local wipeoutFeedFrame = NotificationWidget.NotificationGui.WipeoutFeedFrame
		local wipeoutFeedCanvas = Assets.GuiObjects.Frames.WipeoutFeedCanvas:Clone()
		wipeoutFeedCanvas.Parent = wipeoutFeedFrame
		wipeoutFeedCanvas.UsernameTextLabel.Text = params.wiperName
		wipeoutFeedCanvas.UsernameWipedTextLabel.Text = params.playerWipedOut.Name
		wipeoutFeedCanvas.WeaponImage.Image = ReplicatedStorage.Weapons[params.weaponName].TextureId
		local transparencyTween = TweenService:Create(wipeoutFeedCanvas, TweenInfo.new(1.66), { GroupTransparency = 1 })
		task.delay(3.33, function()
			transparencyTween:Play()
			transparencyTween.Completed:Connect(function(playbackState)
				wipeoutFeedCanvas:Destroy()
			end)
		end)
	end

	if notificationType == NotificationWidget.NotificationController.Notifications.Wipeout_Streak then
		local wipeoutFeedFrame = NotificationWidget.NotificationGui.WipeoutFeedFrame
		local wipeoutStreakFeedCanvas = Assets.GuiObjects.Frames.WipeoutStreakFeedCanvas:Clone()
		wipeoutStreakFeedCanvas.Parent = wipeoutFeedFrame
		wipeoutStreakFeedCanvas.UsernameTextLabel.Text = params.playerName
		wipeoutStreakFeedCanvas.WipeoutStreakTextLabel.Text = params.streakName
		local transparencyTween =
			TweenService:Create(wipeoutStreakFeedCanvas, TweenInfo.new(1.66), { GroupTransparency = 1 })
		task.delay(3.33, function()
			transparencyTween:Play()
			transparencyTween.Completed:Connect(function()
				wipeoutStreakFeedCanvas:Destroy()
			end)
		end)
	end

	if notificationType == NotificationWidget.NotificationController.Notifications.Wipeout then
		local wipeoutNotificationFrame = NotificationWidget.NotificationGui.WipeoutNotificationFrame
		--Generate the required frames for the notification and set the size to 0
		local userWipedFrame = Assets.GuiObjects.Frames.UserWipedFrame:Clone()
		userWipedFrame.UsernameTextLabel.Size = UDim2.new(0, 0, 0, 0)
		userWipedFrame.WipedOutTextLabel.Size = UDim2.new(0, 0, 0, 0)
		--Set the parent
		userWipedFrame.Parent = wipeoutNotificationFrame
		userWipedFrame.UsernameTextLabel.Text = params.playerWipedOut.Name
		--Check if there isn't a damage dealt frame already
		local damageDealtFrame
		local isDisplayingDamageDealtFrame = false
		if not wipeoutNotificationFrame:FindFirstChild("DamageDealtFrame") then
			damageDealtFrame = Assets.GuiObjects.Frames.DamageDealtFrame:Clone()
		else
			damageDealtFrame = wipeoutNotificationFrame.DamageDealtFrame
		end
		--Check if there isn't a WipeoutRewardsFrame already
		local wipeoutRewardsFrame
		local isDisplayingWipeoutRewardsFrame = false
		if not wipeoutNotificationFrame:FindFirstChild("WipeoutRewardsFrame") then
			wipeoutRewardsFrame = Assets.GuiObjects.Frames.WipeoutRewardsFrame:Clone()
		else
			wipeoutRewardsFrame = wipeoutNotificationFrame.WipeoutRewardsFrame
		end
		local function updateRewardAttribute(attributeName, paramsKey)
			local currentValue = wipeoutRewardsFrame:GetAttribute(attributeName) or 0
			local paramsValue = params[paramsKey] or 0
			currentValue = paramsValue + currentValue
			wipeoutRewardsFrame:SetAttribute(attributeName, currentValue)
		end
		--Set the current damage attribute
		if damageDealtFrame:GetAttribute("CurrentDamage") then
			damageDealtFrame:SetAttribute(
				"CurrentDamage",
				params.damageDealt + damageDealtFrame:GetAttribute("CurrentDamage")
			)
			isDisplayingDamageDealtFrame = true
			task.delay(1, function()
				isDisplayingDamageDealtFrame = false
			end)
		else	
			damageDealtFrame:SetAttribute("CurrentDamage", params.damageDealt)
		end
		--Set the parent
		damageDealtFrame.Parent = wipeoutNotificationFrame
		wipeoutRewardsFrame.Parent = wipeoutNotificationFrame
		--Set the size of the text labels to 0
		hideTextLabelsBySize(damageDealtFrame)
		hideTextLabelsBySize(wipeoutRewardsFrame)
		--Animate the digits for the text label
		WidgetController:AnimateDigitsForTextLabel(damageDealtFrame.DamageAmountTextLabel, params.damageDealt, 1)
		--Set the reward attributes to the wipeoutRewardsFrame
		updateRewardAttribute("BattlecoinsGained", "battlecoinsGained")
		updateRewardAttribute("ExperienceGained", "experienceGained")
		updateRewardAttribute("BattlepassExperienceGained", "battlepassExperienceGained")

		--Hide the gradient of the frames
		userWipedFrame.Transparency = 1
		damageDealtFrame.Transparency = 1
		wipeoutRewardsFrame.Transparency = 1
		--Trasnparency
		userWipedFrame.UsernameTextLabel.TextTransparency = 1
		userWipedFrame.WipedOutTextLabel.TextTransparency = 1
		damageDealtFrame.DamageAmountTextLabel.TextTransparency = 1
		damageDealtFrame.DamageDealtTextLabel.TextTransparency = 1
		wipeoutRewardsFrame.BattleCoinsTextLabel.TextTransparency = 1
		wipeoutRewardsFrame.BattleCoinsTextLabel.ImageLabel.ImageTransparency = 1
		wipeoutRewardsFrame.BattlepassExperienceTextLabel.TextTransparency = 1
		wipeoutRewardsFrame.BattlepassExperienceTextLabel.ImageLabel.ImageTransparency = 1
		wipeoutRewardsFrame.ExperienceGained.TextTransparency = 1
		--play the sound
		NotificationWidget.AudioController:PlaySound("knockout")
		--Assing layout order for the frames
		wipeoutRewardsFrame.LayoutOrder = 3
		userWipedFrame.LayoutOrder = 2
		damageDealtFrame.LayoutOrder = 1
		--Animate the shine for the frames
		AnimateShineForFrame(wipeoutRewardsFrame, true)
		AnimateShineForFrame(userWipedFrame, true)
		AnimateShineForFrame(damageDealtFrame, true)

		--Create UserWipedFrame tweens--
		--Wiped out text label tween
		local userWipedOutTextLabelTween = TweenService:Create(
			userWipedFrame.WipedOutTextLabel,
			notificationTweenInfo,
			{ Size = userWipedFrame.UsernameTextLabel:GetAttribute("TargetSize") }
		)
		local userWipedOutTransparencyTween =
			TweenService:Create(userWipedFrame.WipedOutTextLabel, transparencyTweenInfo, { TextTransparency = 0 })
		local userWipedUsernameTransparencyTween =
			TweenService:Create(userWipedFrame.UsernameTextLabel, transparencyTweenInfo, { TextTransparency = 0 })
		userWipedUsernameTransparencyTween:Play()
		userWipedOutTransparencyTween:Play()
		userWipedOutTextLabelTween:Play()
		task.delay(DELAY_TIME_BEFORE_NOTIFICATION, function()
			--Username text label tween
			local userWipedUsernameTextLabelTween = TweenService:Create(
				userWipedFrame.UsernameTextLabel,
				notificationTweenInfo,
				{ Size = userWipedFrame.UsernameTextLabel:GetAttribute("TargetSize") }
			)

			userWipedUsernameTextLabelTween:Play()
			userWipedUsernameTextLabelTween.Completed:Connect(function()
				userWipedOutTextLabelTween:Destroy()
				userWipedUsernameTextLabelTween:Destroy()
				userWipedFrame:Destroy()
			end)
		end)

		--Create DamageDealtFrame tween
		local damageDealtTextTween = TweenService:Create(
			damageDealtFrame.DamageDealtTextLabel,
			notificationTweenInfo,
			{ Size = damageDealtFrame.DamageDealtTextLabel:GetAttribute("TargetSize") }
		)
		local damageDealtTransparencyTween =
			TweenService:Create(damageDealtFrame.DamageDealtTextLabel, transparencyTweenInfo, { TextTransparency = 0 })
		local damaDealtAmountTransparencyTween =
			TweenService:Create(damageDealtFrame.DamageAmountTextLabel, transparencyTweenInfo, { TextTransparency = 0 })
		damaDealtAmountTransparencyTween:Play()
		damageDealtTransparencyTween:Play()
		damageDealtTextTween:Play()
		task.delay(DELAY_TIME_BEFORE_NOTIFICATION, function()
			local damageDealtAmountTextTween =
				TweenService:Create(damageDealtFrame.DamageAmountTextLabel, notificationTweenInfo, {
					Size = damageDealtFrame.DamageAmountTextLabel:GetAttribute("TargetSize"),
				})

			damageDealtAmountTextTween:Play()
			damageDealtAmountTextTween.Completed:Connect(function()
				damageDealtFrame:Destroy()
			end)
		end)

		--Create WipeoutRewardsFrame
		local battlepassExperienceGainedTween =
			TweenService:Create(wipeoutRewardsFrame.BattlepassExperienceTextLabel, notificationTweenInfo, {
				Size = wipeoutRewardsFrame.BattlepassExperienceTextLabel:GetAttribute("TargetSize"),
			})
		local battlepassExperienceGainedTransparencyTween = TweenService:Create(
			wipeoutRewardsFrame.BattlepassExperienceTextLabel,
			transparencyTweenInfo,
			{ TextTransparency = 0 }
		)
		local battleCoinsGainedTween = TweenService:Create(
			wipeoutRewardsFrame.BattleCoinsTextLabel,
			notificationTweenInfo,
			{ Size = wipeoutRewardsFrame.BattleCoinsTextLabel:GetAttribute("TargetSize") }
		)
		local battleCoinsGainedTransparencyTween = TweenService:Create(
			wipeoutRewardsFrame.BattleCoinsTextLabel,
			transparencyTweenInfo,
			{ TextTransparency = 0 }
		)
		local experienceGainedTween = TweenService:Create(
			wipeoutRewardsFrame.ExperienceGained,
			notificationTweenInfo,
			{ Size = wipeoutRewardsFrame.ExperienceGained:GetAttribute("TargetSize") }
		)
		local experienceGainedTransparencyTween =
			TweenService:Create(wipeoutRewardsFrame.ExperienceGained, transparencyTweenInfo, { TextTransparency = 0 })
		--Icon tweens
		local battleCoinsIconTransparencyTween = TweenService:Create(
			wipeoutRewardsFrame.BattleCoinsTextLabel.ImageLabel,
			transparencyTweenInfo,
			{ ImageTransparency = 0 }
		)
		local battlepassExperienceIconTransparencyTween = TweenService:Create(
			wipeoutRewardsFrame.BattlepassExperienceTextLabel.ImageLabel,
			transparencyTweenInfo,
			{ ImageTransparency = 0 }
		)
		battleCoinsIconTransparencyTween:Play()
		battlepassExperienceIconTransparencyTween:Play()
		battleCoinsGainedTransparencyTween:Play()
		battleCoinsGainedTween:Play()
		task.delay(DELAY_TIME_BEFORE_NOTIFICATION - 0.66, function()
			experienceGainedTween:Play()
			experienceGainedTransparencyTween:Play()
			task.delay(DELAY_TIME_BEFORE_NOTIFICATION - 0.66, function()
				if not isDisplayingWipeoutRewardsFrame then
					battlepassExperienceGainedTransparencyTween:Play()
					battlepassExperienceGainedTween:Play()
					battlepassExperienceGainedTween.Completed:Connect(function()
						wipeoutRewardsFrame:Destroy()
					end)
				end
			end)
		end)

		--Check if the player accomplished a badge streak
		if params.badgeStreak then
			local badgeStreakFrame = Assets.GuiObjects.Frames.BadgeStreakFrame:Clone()
			badgeStreakFrame.LayoutOrder = 2
			badgeStreakFrame.Parent = wipeoutNotificationFrame
			badgeStreakFrame.Frame.BadgeStreakTextLabel.Text = params.badgeStreak
			local badgeStreakFrameTween = TweenService:Create(
				wipeoutNotificationFrame.BadgeStreakFrame,
				notificationTweenInfo,
				{ Position = wipeoutNotificationFrame.BadgeStreakFrame:GetAttribute("") }
			)
			badgeStreakFrameTween:Play()
			badgeStreakFrameTween.Completed:Connect(function()
				badgeStreakFrame:Destroy()
			end)
		end
	end

	if notificationType == NotificationWidget.NotificationController.Notifications.Death then
		--get the frame
		local deathNotificationFrame = NotificationWidget.NotificationGui.DeathNotificationFrame
		deathNotificationFrame.UsernameTextLabel.Text = params.killer.Name
		--play the sound
		NotificationWidget.AudioController:PlaySound("death")
		--Create tween
		local deathNotificationTween = TweenService:Create(
			deathNotificationFrame,
			notificationTweenInfo,
			{ Position = deathNotificationFrame:GetAttribute("EndPosition") }
		)
		deathNotificationTween:Play()
	end

	if notificationType == NotificationWidget.NotificationController.Notifications.Assist then
		-- get the frame
		local assistNoticationFrame = NotificationWidget.NotificationGui.AssistNotificationFrame
		-- Get the assist frame
		local assistFrame = Assets.GuiObjects.Frames.AssistFrame:Clone()
		-- Set the parent
		assistFrame.Parent = assistNoticationFrame
		-- Set the params
		assistFrame.UsernameTextLabel.Text = params.playerWipedOutAssist
		assistFrame.DamageDealtTextLabel.Text = "0"
		--Set the size of the text labels to 0
		hideTextLabelsBySize(assistFrame)
		--Hide the gradient of the frames
		assistFrame.Transparency = 1
		--play the sound
		NotificationWidget.AudioController:PlaySound("knockout")
		--Animate shine for the frame
		AnimateShineForFrame(assistFrame, true)
		WidgetController:AnimateDigitsForTextLabel(assistFrame.DamageDealtTextLabel, params.damageDealt, 1)
		--Create the tweens for the text labels
		local damageDealtTween = TweenService:Create(
			assistFrame.DamageDealtTextLabel,
			notificationTweenInfo,
			{ Size = assistFrame.DamageDealtTextLabel:GetAttribute("TargetSize") }
		)
		local usernameTween = TweenService:Create(
			assistFrame.UsernameTextLabel,
			notificationTweenInfo,
			{ Size = assistFrame.UsernameTextLabel:GetAttribute("TargetSize") }
		)
		local assistTextTween = TweenService:Create(
			assistFrame.AssistTextLabel,
			notificationTweenInfo,
			{ Size = assistFrame.AssistTextLabel:GetAttribute("TargetSize") }
		)

		damageDealtTween:Play()
		task.delay(DELAY_TIME_BEFORE_NOTIFICATION - 0.66, function()
			usernameTween:Play()
			assistTextTween:Play()
			assistTextTween.Completed:Connect(function()
				assistFrame:Destroy()
			end)
		end)
	end
end

return NotificationWidget
