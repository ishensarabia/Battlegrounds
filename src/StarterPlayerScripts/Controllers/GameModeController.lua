local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--Widgets 
local GameModeElectionWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.GameModeElectionWidget)

local GameModeController = Knit.CreateController { Name = "GameModeController" }


function GameModeController:KnitStart()
    self._gameModeService = Knit.GetService("GameModeService")
    warn(self._gameModeService)
    self._gameModeService.InitializeElectionSignal:Connect(function(timeToVote)
        self:InitializeElection(timeToVote)
    end)
    self._gameModeService.UpdateVoteCountSignal:Connect(function(votes : table)
        GameModeElectionWidget:UpdateVotes(votes)
    end)
end

function GameModeController:InitializeElection(timeToVote)
    GameModeElectionWidget:OpenElectionFrame(timeToVote)
end

function GameModeController:KnitInit()
    
end


return GameModeController
