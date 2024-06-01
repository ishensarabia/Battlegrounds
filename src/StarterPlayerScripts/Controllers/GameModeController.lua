local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--Widgets
local GameModeElectionWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.GameModeElectionWidget)
local EndGameWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.EndGameWidget)

local GameModeController = Knit.CreateController({ Name = "GameModeController" })

function GameModeController:KnitStart()
	self._gameModeService = Knit.GetService("GameModeService")
	self._cameraController = Knit.GetController("CameraController")
	self._menuController = Knit.GetController("MenuController")
	self._canRespawn = false

	self._gameModeService.InitializeElectionSignal:Connect(function(timeToVote)
		self:InitializeElection(timeToVote)
	end)

	self._gameModeService.UpdateVoteCountSignal:Connect(function(votes: table, typeOfVotes: string)
		GameModeElectionWidget:UpdateVotes(votes, typeOfVotes)
	end)

	--On end game mode
	self._gameModeService.EndGameSignal:Connect(function(topPlayers: table)
		if self._menuController.isInMenu then
			self._menuController:HidePlayButton()
		end
		self._canRespawn = false
		-- self._cameraController:TransitionBetweenCurves(workspace.Map:FindFirstChildWhichIsA("Folder").EndCutscene.CameraPoints)
		EndGameWidget:ShowEndGameResults(topPlayers)

		if self._menuController.isInMenu then
			self._menuController:HidePlayButton()
		else
			self._menuController:ShowMenu()
		end
	end)

	self._gameModeService.InitializeGameModeSignal:Connect(function()
		self._canRespawn = true
		if not self._menuController.isInMenu then
			self._menuController:ShowMenu()
		elseif self._menuController then
			self._menuController:ShowPlayButton()
		end
	end)
end

function GameModeController:InitializeElection(timeToVote)
	GameModeElectionWidget:OpenElectionFrame(timeToVote)
end

function GameModeController:KnitInit() end

return GameModeController
