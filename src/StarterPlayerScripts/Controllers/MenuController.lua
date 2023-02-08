local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
--Widgets
local WeaponCustomWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponCustomWidget)

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
    local CameraController = Knit.GetController("CameraController")
    CameraController.isInMenu = false
    CameraController:CancelActiveTween()
    CameraController:SetCameraType("Custom")
    Knit.GetService("PlayerService"):SpawnCharacter()
end

function MenuController:KnitInit()
    
end


return MenuController
