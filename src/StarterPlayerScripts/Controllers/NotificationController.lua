local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NotificationController = Knit.CreateController({ Name = "NotificationController" })

--Widgets
local NotificationWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.NotificationWidget)

function NotificationController:KnitStart() end

NotificationController.Notifications = {
    KO = "KO",
    Death = "Death"
}

function NotificationController:KnitInit()
    --Get the ScoreService
	local ScoreService = Knit.GetService("ScoreService")
    --Connect to notification signals
    ScoreService.KO_Notification:Connect(function(damageDealt : number, player : Player)
        local params = {
            damageDealt = damageDealt,
            playerKnockedOut = player
        }
        NotificationWidget:DisplayNotification(self.Notifications.KO, params)
    end)
    ScoreService.Death_Notification:Connect(function(killer : Player)
        local params = {
            killer = killer,
        }
        NotificationWidget:DisplayNotification(self.Notifications.Death, params)
    end)
end

return NotificationController
