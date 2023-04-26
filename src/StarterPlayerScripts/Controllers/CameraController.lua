--Core services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
--Module dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local TweenObject = require(ReplicatedStorage.Source.Modules.Util.TweenObject)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

--Class
local CameraController = Knit.CreateController({ Name = "CameraController" })
--Variables
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

function CameraController:KnitStart() end

function CameraController:TransitionBetweenPoints(points: Folder)
	local cameraPoints = points:GetChildren()
	for i = 1, #cameraPoints do
		if points[i]:IsA("BasePart") and self.isInMenu then
			task.wait()
			camera.CameraType = Enum.CameraType.Scriptable
			local cameraTweenPromise = TweenService:Create(camera, TweenInfo.new(33), { CFrame = points[i].CFrame })
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

function CameraController:SetCameraType(type: string)
	camera.CameraType = Enum.CameraType[type]
end

function CameraController:ChangeMode(mode: string, params: table)
	if mode == "Respawn" then
		--Bind to render step to update the camera's position
		RunService:BindToRenderStep("RespawnCamera", 1, function()
			--If the player character got obliberated
			if not player.Character then
				camera.CFrame = CFrame.lookAt(camera.CFrame.Position, params.killerHRP.Position)
			else
				--Add a slight offset to the players's position so the camera doesn't look directly at the player
				camera.CFrame = CFrame.lookAt(
					player.Character.HumanoidRootPart.Position + Vector3.new(0, 9, 0),
					params.killerHRP.Position
				)
			end
		end)
	end

	if mode == "Play" then
		RunService:UnbindFromRenderStep("RespawnCamera")
		self:SetCameraType("Custom")
	end
end

function CameraController:TweenCamera(camera: Camera, tweenInfo: TweenInfo, properties: table)
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
	self._janitor = Janitor.new()
end

return CameraController
