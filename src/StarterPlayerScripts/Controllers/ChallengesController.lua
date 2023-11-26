local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local player = Players.LocalPlayer
local Knit = require(ReplicatedStorage.Packages.Knit)
--Module dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIVisibilityWrapper = require(StarterPlayer.StarterPlayerScripts.Source.FusionUI.UIVisibilityWrapper)
local UIStateManager = require(StarterPlayer.StarterPlayerScripts.Source.FusionUI.UIStateManager)
local ChallengesWidget = require(StarterPlayer.StarterPlayerScripts.Source.FusionUI.Components.ChallengesWidget)
local Value = Fusion.Value
local New = Fusion.New
local Children = Fusion.Children
local Observer = Fusion.Observer
local ChallengesController = Knit.CreateController { Name = "ChallengesController" }



function ChallengesController:KnitStart()
	local visible = Value(false)
	UIVisibilityWrapper(visible, "ChallengesMenu")
	New("ScreenGui")({
		Parent = player.PlayerGui,
		Name = "ChallengesWidget",
		Enabled = visible,
		DisplayOrder = 1,
		ResetOnSpawn = false,
		[Children] = {
			ChallengesWidget({
				Visible = visible,
			}),
		},
	})
end

function ChallengesController:OpenChallenges()
	UIStateManager:Dispatch(
		UIStateManager.Actions.SetUIVisibility({ uiName = "ChallengesMenu", visible = true })
	)
end


function ChallengesController:KnitInit()
	
end


return ChallengesController
