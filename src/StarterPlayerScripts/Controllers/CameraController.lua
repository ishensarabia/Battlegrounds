--Core services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
--Module dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local TweenObject = require(ReplicatedStorage.Source.Modules.Util.TweenObject)
--Class
local CameraController = Knit.CreateController { Name = "CameraController" }
--Variables
local camera = workspace.CurrentCamera

function CameraController:KnitStart()
end

function CameraController:TransitionBetweenPoints(points : Folder)
    local cameraPoints = points:GetChildren()
    for i = 1, #cameraPoints do
        if (points[i]:IsA("BasePart") and self.isInMenu) then
            task.wait()       
            camera.CameraType = Enum.CameraType.Scriptable
            local cameraTweenPromise = TweenService:Create(camera, TweenInfo.new(33), {CFrame = points[i].CFrame})
            self.activeTween = cameraTweenPromise
            cameraTweenPromise:Play()
            cameraTweenPromise.Completed:Wait()
            camera.CFrame = points[i].CFrame
        end
    end
end

function CameraController:CancelActiveTween()
    if self.activeTween then
        self.activeTween:Cancel()
    end
end

function CameraController:SetCameraType(type : string)
    camera.CameraType = Enum.CameraType[type]
end

function CameraController:TweenCamera(camera : Camera, tweenInfo : TweenInfo, properties : table)
    return Promise.new(function(resolve, reject, onCancel)
        local tween = TweenService:Create(camera, tweenInfo, properties)
        tween:Play()

        onCancel(function()
            tween:Cancel()
        end)

        tween.Completed:Connect(resolve)
    end)
end

function CameraController:KnitInit()
    
end


return CameraController