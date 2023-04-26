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

--Function to create a notification
function NotificationWidget:DisplayNotification(notificationType: string, params: table)
	if not isInitialized then
		NotificationWidget:Initialize()
	end
	NotificationWidget.NotificationGui.Enabled = true

	if notificationType == NotificationWidget.NotificationController.Notifications.KO then
		local wipeoutNotificationFrame = NotificationWidget.NotificationGui.WipeoutNotificationFrame
		--Generate the required frames for the notification and set the size to 0
		local userKilledFrame = Assets.GuiObjects.Frames.UserKilledFrame:Clone()
		userKilledFrame.Frame.Size = UDim2.new(0, 0, 0, 0)
		userKilledFrame.Parent = wipeoutNotificationFrame
		userKilledFrame.Frame.UsernameTextLabel.Text = params.playerKnockedOut.Name
		local damageDealtFrame = Assets.GuiObjects.Frames.DamageDealtFrame:Clone()
		damageDealtFrame.Frame.Size = UDim2.new(0, 0, 0, 0)
		damageDealtFrame.Parent = wipeoutNotificationFrame
		damageDealtFrame.Frame.DamageAmountTextLabel.Text = params.damageDealt
		--play the sound
		NotificationWidget.AudioController:PlaySound("knockout")
		--Assing layout order for the frames
		userKilledFrame.LayoutOrder = 3
		damageDealtFrame.LayoutOrder = 1
		--Create UserKilledFrame tween
		local userKilledFrameTween = TweenService:Create(
			userKilledFrame.Frame,
			notificationTweenInfo,
			{ Size = UDim2.fromScale(1, 1) }
		)
		userKilledFrameTween:Play()
		userKilledFrameTween.Completed:Connect(function()
			userKilledFrame:Destroy()
		end)
		--Create DamageDealtFrame tween
		local damageDealtFrameTween = TweenService:Create(
			damageDealtFrame.Frame,
			notificationTweenInfo,
			{ Size = UDim2.fromScale(1, 1) }
		)
		damageDealtFrameTween:Play()
		damageDealtFrameTween.Completed:Connect(function()
			damageDealtFrame:Destroy()
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
