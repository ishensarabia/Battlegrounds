local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local player = Players.LocalPlayer
--Widgets

--Module dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIVisibilityWrapper = require(StarterPlayer.StarterPlayerScripts.Source.FusionUI.UIVisibilityWrapper)
local UIStateManager = require(StarterPlayer.StarterPlayerScripts.Source.FusionUI.UIStateManager)
local MainMenuWidget = require(StarterPlayer.StarterPlayerScripts.Source.FusionUI.Components.MainMenuWidget)
local Value = Fusion.Value
local New = Fusion.New
local Children = Fusion.Children
local Observer = Fusion.Observer

local MenuController = Knit.CreateController({ Name = "MenuController" })

local visible = Value(false)

function MenuController:KnitStart()
	UIVisibilityWrapper(visible, "MainMenu")
	New("ScreenGui")({
		Parent = player.PlayerGui,
		Name = "MainMenuWidget",
		Enabled = visible:get(),
		DisplayOrder = 1,
		ResetOnSpawn = false,
		[Children] = {
			MainMenuWidget({
				Visible = visible,
				ChallengesButtonCallback = function()
					Knit.GetController("ChallengesController"):OpenChallenges()
				end,
			}),
		},
	})
end

function MenuController:startCutscene(cutscene: string)
	local cutsceneHandler = cutscene
	if cutsceneHandler then
		cutsceneHandler()
	end
end

function MenuController:Play()
	self._cameraController.isInMenu = false
	self.isInMenu = false
	self._cameraController:CancelActiveTween()
	self._cameraController:SetCameraType("Custom")
	self._cameraController:ChangeMode("Play")
	Knit.GetService("PlayerService"):SpawnCharacter()
end

function MenuController:ShowMenu()
	warn("Showing menu")
	UIStateManager:Dispatch(UIStateManager.Actions.SetUIVisibility({ uiName = "MainMenu", visible = true }))
	if self.isInMenu then
		return
	end
	self.isInMenu = true
	self._cameraController:ChangeMode("Menu")
	Knit.GetController("UIController").MainMenuWidget:InitializeCameraTransition()
end

function MenuController:ShowPlayButton()
	if self.isInMenu then
		Knit.GetController("UIController").MainMenuWidget:ShowPlayButton()
	end
end

function MenuController:HidePlayButton()
	Knit.GetController("UIController").MainMenuWidget:HidePlayButton()
end

function MenuController:KnitInit()
	self._cameraController = Knit.GetController("CameraController")
	self.isInMenu = true
end

return MenuController
