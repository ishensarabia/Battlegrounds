local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    CameraController:CancelActiveTween()
    CameraController:SetCameraType("Custom")
end

function MenuController:KnitInit()
    
end


return MenuController
