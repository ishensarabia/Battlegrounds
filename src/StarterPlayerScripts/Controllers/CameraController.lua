--Core services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
--Module dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)
--Class
local CameraController = Knit.CreateController { Name = "CameraController" }
--Variables
local camera = workspace.CurrentCamera

function CameraController:KnitStart()
    
end

function CameraController:TransitionBetweenPoints(points : Folder)
    warn("Camera transition between points")
    local cameraPoints = points:GetChildren()
    while self.isInMenu do
        for i = 1, #cameraPoints do
            if (points[i]:IsA("BasePart")) then                
                camera.CameraType = Enum.CameraType.Scriptable
                local cameraTween = TweenService:Create(camera, TweenInfo.new(33), {CFrame = points[i].CFrame})
                cameraTween:Play()
                cameraTween.Completed:Wait()
                camera.CFrame = points[i].CFrame
                warn("Camera tween completed")
            end
        end
    end
    -- camera.CameraType = Enum.CameraType.Custom
end

function CameraController:KnitInit()
    
end


return CameraController
