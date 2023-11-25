local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
--Widgets

--Module dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)

local MenuController = Knit.CreateController { Name = "MenuController" }
local Cutscenes = {
    MainMenu = function()
        
    end
}


function MenuController:KnitStart()
end

function MenuController:startCutscene(cutscene : string)
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
    if self.isInMenu then
        return
    end
    Knit.GetController("UIController").MainMenuWidget:ShowMenu()
    self.isInMenu = true
    self._cameraController:ChangeMode("Menu")
    -- Knit.GetController("UIController").MainMenuWidget:InitializeCameraTransition()
    
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
