local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NotificationController = Knit.CreateController({ Name = "NotificationController" })

--Widgets
local NotificationWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.NotificationWidget)

function NotificationController:KnitStart() end

NotificationController.Notifications = {
	Wipeout = "Wipeout",
	Death = "Death",
	Assist = "Assist",
}

function NotificationController:KnitInit()
	--Get the ScoreService
	local ScoreService = Knit.GetService("ScoreService")
	--Connect to notification signals
	ScoreService.Wipeout_Notification:Connect(function(damageDealt: number, player: Player)
		local params = {
			damageDealt = damageDealt,
			playerWipedOut = player,
		}
		NotificationWidget:DisplayNotification(self.Notifications.Wipeout, params)
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
