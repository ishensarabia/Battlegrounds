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
--Notifiaction tween info
local notificationTweenInfo = TweenInfo.new(1.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0)
--Constants
local DELAY_TIME_BEFORE_NOTIFICATION = 0.66

function NotificationWidget:Initialize()
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("NotificationGui") then
		NotificationWidget.NotificationGui = Assets.GuiObjects.ScreenGuis.NotificationGui
			or game.Players.LocalPlayer.PlayerGui.NotificationGui
		NotificationWidget.NotificationGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		NotificationWidget.NotificationGui = game.Players.LocalPlayer.PlayerGui.NotificationGui
	end
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

--Function to create a notification
function NotificationWidget:DisplayNotification(notificationType: string, params: table)
	if not isInitialized then
		NotificationWidget:Initialize()
	end
	NotificationWidget.NotificationGui.Enabled = true

	if notificationType == NotificationWidget.NotificationController.Notifications.KO then
		local wipeoutNotificationFrame = NotificationWidget.NotificationGui.WipeoutNotificationFrame
		--Generate the required frames for the notification and set the size to 0
		local userWipedFrame = Assets.GuiObjects.Frames.UserWipedFrame:Clone()
		userWipedFrame.UsernameTextLabel.Size = UDim2.new(0, 0, 0, 0)
		userWipedFrame.WipedOutTextLabel.Size = UDim2.new(0, 0, 0, 0)
		--Set the parent
		userWipedFrame.Parent = wipeoutNotificationFrame
		userWipedFrame.UsernameTextLabel.Text = params.playerKnockedOut.Name
		--Check if there isn't a damage dealt frame already
		local damageDealtFrame
		local isDisplayingDamageDealtFrame = false
		if not wipeoutNotificationFrame:FindFirstChild("DamageDealtFrame") then
			damageDealtFrame = Assets.GuiObjects.Frames.DamageDealtFrame:Clone()
		else
			damageDealtFrame = wipeoutNotificationFrame.DamageDealtFrame
		end
		--Set the current damage attribute
		if damageDealtFrame:GetAttribute("CurrentDamage") then
			damageDealtFrame:SetAttribute(
				"CurrentDamage",
				params.damageDealt + damageDealtFrame:GetAttribute("CurrentDamage")
			)
			isDisplayingDamageDealtFrame = true
			task.delay(1.33, function()
				isDisplayingDamageDealtFrame = false
			end)
		else
			damageDealtFrame:SetAttribute("CurrentDamage", params.damageDealt)
		end
		--Set the parent
		damageDealtFrame.Parent = wipeoutNotificationFrame
		--Set the size of the text labels to 0
		damageDealtFrame.DamageAmountTextLabel.Size = UDim2.new(0, 0, 0, 0)
		damageDealtFrame.DamageDealtTextLabel.Size = UDim2.new(0, 0, 0, 0)
		damageDealtFrame.DamageAmountTextLabel.Text = damageDealtFrame:GetAttribute("CurrentDamage")
		--Hide the gradient of the frames
		userWipedFrame.Transparency = 1
		damageDealtFrame.Transparency = 1
		--play the sound
		NotificationWidget.AudioController:PlaySound("knockout")
		--Assing layout order for the frames
		userWipedFrame.LayoutOrder = 2
		damageDealtFrame.LayoutOrder = 1
		--Animate the shine for the frames
		AnimateShineForFrame(userWipedFrame, true)
		AnimateShineForFrame(damageDealtFrame, true)
		--Create UserWipedFrame tweens
		--Wiped out text label tween
		local userWipedOutTextLabelTween = TweenService:Create(
			userWipedFrame.WipedOutTextLabel,
			notificationTweenInfo,
			{ Size = userWipedFrame.UsernameTextLabel:GetAttribute("TargetSize") }
		)
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
		if not isDisplayingDamageDealtFrame then			
			local damageDealtTextTween = TweenService:Create(
				damageDealtFrame.DamageDealtTextLabel,
				notificationTweenInfo,
				{ Size = damageDealtFrame.DamageDealtTextLabel:GetAttribute("TargetSize") }
			)
			damageDealtTextTween:Play()
		end
		task.delay(DELAY_TIME_BEFORE_NOTIFICATION, function()
			if not isDisplayingDamageDealtFrame then				
				local damageDealtAmountTextTween = TweenService:Create(
					damageDealtFrame.DamageAmountTextLabel,
					notificationTweenInfo,
					{ Size = damageDealtFrame.DamageAmountTextLabel:GetAttribute("TargetSize") }
				)
				damageDealtAmountTextTween:Play()
				damageDealtAmountTextTween.Completed:Connect(function()
					damageDealtFrame:Destroy()
				end)
			end
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
end

return NotificationWidget
