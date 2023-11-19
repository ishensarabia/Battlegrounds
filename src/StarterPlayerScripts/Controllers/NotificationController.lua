local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NotificationController = Knit.CreateController({ Name = "NotificationController" })

--Widgets
local NotificationWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.NotificationWidget)

function NotificationController:KnitStart() end

NotificationController.Notifications = {
	Wipeout_Streak = "Wipeout_Streak";
	Wipeout = "Wipeout",
	Death = "Death",
	Assist = "Assist",
	Feed = "Feed",
}

function NotificationController:KnitInit()
	--Get the ScoreService
	local ScoreService = Knit.GetService("ScoreService")
	--Connect to notification signals
	ScoreService.Wipeout_Notification:Connect(function(damageDealt: number, playerWipedOut: Player, weaponName : string, wiperName)
		local params = {
			damageDealt = damageDealt,
			playerWipedOut = playerWipedOut,
			wiperName = wiperName,
			weaponName = weaponName
		}
		if Players.LocalPlayer.Name == wiperName then			
			NotificationWidget:DisplayNotification(self.Notifications.Wipeout, params)
		end
		NotificationWidget:DisplayNotification(self.Notifications.Feed, params)
	end)
	ScoreService.Wipeout_Streak_Notification:Connect(function(playerName : string, streakName : string)
		if playerName and streakName then			
			local params = {
				playerName = playerName,
				streakName = streakName
			}
			NotificationWidget:DisplayNotification(self.Notifications.Wipeout_Streak, params)
		end
	end)
	ScoreService.Death_Notification:Connect(function(killer: Player)
		local params = {
			killer = killer,
		}
		NotificationWidget:DisplayNotification(self.Notifications.Death, params)
	end)
    ScoreService.Assist_Notification:Connect(function(playerWipedOutAssist : Player, damageDealt : number)
        local params = {
			damageDealt = damageDealt,
			playerWipedOutAssist = playerWipedOutAssist.Name
        }
        NotificationWidget:DisplayNotification(self.Notifications.Assist, params)
    end)
        
end

return NotificationController
