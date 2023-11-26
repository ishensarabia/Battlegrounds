--[[
	```lua
	local ViewportModel = Import("ViewportModel")

	ViewportModel({
		Parent = target,
		Instance = model,
		Distance = number?,
		Orientation = CFrame?,
	})
	```
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")


local Fusion = require(ReplicatedStorage.Packages.Fusion)
-- local ViewportModel = Import("ViewportModel")

local New = Fusion.New
local Children = Fusion.Children
local Cleanup = Fusion.Cleanup
local OnEvent = Fusion.OnEvent

return function(props)
	local cleanupTable = {}

	local viewportFrame = New("ViewportFrame")({
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(114, 114, 114),
		Parent = props.Parent,
		[Cleanup] = cleanupTable,
		[Children] = {
			props[Children],
		},
	})

	local camera = Instance.new("Camera")
	camera.FieldOfView = 70
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	local model = Instance.new("WorldModel")
	model.Parent = viewportFrame

	local instance: Model = props.Instance

	if not props.DontClone then
		instance = props.Instance:Clone()
		instance.Parent = model
	else
		instance.Parent = model
	end

	local vpfModel = ViewportModel.new(viewportFrame, camera)
	local cf = model:GetBoundingBox()

	vpfModel:SetModel(model)

	local orientation = props.Orientation or CFrame.fromEulerAnglesYXZ(0, 0, 0)
	local distance = props.Distance or vpfModel:GetFitDistance(cf.Position)

	camera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)

	if not props.Draggable then
		return viewportFrame
	end

	local startPivot = instance:GetPivot()
	local yaw, pitch = 0, 0
	local lastMousePosition = Vector3.new()
	local holding = false

	New("TextButton")({
		Parent = viewportFrame,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		[OnEvent("InputBegan")] = function(inputObject)
			if
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
				holding = true
				lastMousePosition = inputObject.Position
			end
		end,
		[OnEvent("InputEnded")] = function(inputObject)
			if
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
				holding = false
			end
		end,
	})

	local function updateRotation()
		instance:PivotTo(startPivot * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0))
	end

	table.insert(
		cleanupTable,
		RunService.RenderStepped:Connect(function()
			local currentInputType = UserInputService:GetLastInputType()

			local isGamepad = currentInputType == Enum.UserInputType.Gamepad1

			if not isGamepad then
				return
			end

			local gamepad = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
			local statesByKeyCode = {}

			for _, state in gamepad do
				statesByKeyCode[state.KeyCode] = state
			end

			local rightThumbstickPosition = statesByKeyCode[Enum.KeyCode.Thumbstick2].Position

			yaw += rightThumbstickPosition.X * 2
			pitch -= rightThumbstickPosition.Y * 2

			updateRotation()
		end)
	)

	table.insert(
		cleanupTable,
		UserInputService.InputChanged:Connect(function(inputObject)
			local isGamepad = inputObject.KeyCode == Enum.KeyCode.Thumbstick2

			if not holding or isGamepad then
				return
			end

			if
				inputObject.UserInputType == Enum.UserInputType.MouseMovement
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
				local position = inputObject.Position
				local delta = position - lastMousePosition

				if isGamepad then
					delta = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
				end

				yaw += delta.X
				pitch -= delta.Y

				lastMousePosition = position

				updateRotation()
			end
		end)
	)

	return viewportFrame
end
