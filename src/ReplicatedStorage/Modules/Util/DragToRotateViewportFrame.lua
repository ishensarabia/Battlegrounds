local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunS = game:GetService("RunService")

local CLASS_NAME = "DragToRotateViewportFrame"
local MAX_ANGLE_STEP = math.rad(10)
local _lastMousePosition
--------------------------------------------------------------------------------
--Helper functions
--------------------------------------------------------------------------------

local function printf(pattern, ...)
	return print(string.format(pattern, ...))
end

local function assertf(condition, pattern, ...)
	assert(condition, string.format(pattern, ...))
end

local function warnf(pattern, ...)
	warn(string.format(pattern, ...))
end

local function typeofIs(value, typeName)
	return typeof(value) == typeName
end

local function isInstance(value)
	return typeofIs(value, "Instance")
end

local function isValueOfClass(value, className)
	return isInstance(value) and value.ClassName == className
end

local function getModelCornerDist(model)
	local _, size = model:GetBoundingBox()
	return Vector3.new(size.X / 2 + size.Y / 2 + size.Z / 2).Magnitude
end

local function rotateCFrameAroundWorldAxis(cframe, worldAxis, amount)
	--Rotates a CFrame around a world-space axis by 'amount' radians
	local objectAxis = cframe:VectorToObjectSpace(worldAxis)
	return cframe * CFrame.fromAxisAngle(objectAxis, amount)
end

local function rotateCFrameCameralike(cFrame, dPitch, dYaw)
	--Rotates a CFrame "like the default camera rotates",
	--	i.e. around the world-space Y axis andd the camera-space X axis
	local rightVector = cFrame.RightVector
	cFrame = rotateCFrameAroundWorldAxis(cFrame, Vector3.new(0, 1, 0), dYaw)
	cFrame = cFrame * CFrame.Angles(dPitch, 0, 0)
	return cFrame
end

local function getCFramePitch(cFrame)
	--Returns the angle from the LookVector of the cFrame to the horizontal/XZ plane,
	--	i.e. the pitch relative to the world.
	--TODO: Make work with upside-down camera
	local lv = cFrame.LookVector
	local py = lv.Y
	local px = Vector3.new(lv.X, 0, lv.Z).Magnitude
	return math.atan2(py, px)
end

local function getCFrameYaw(cFrame)
	--Returns the angle from the LookVector of the cFrame to the XY plane,
	--	i.e. the yaw relative to the world.
	local lv = (cFrame.LookVector * Vector3.new(1, 0, 1))
	return math.atan2(lv.x, lv.z)
end

local function cFrameToAngles(cFrame)
	--Returns the angles component of a CFrame
	return cFrame - cFrame.p
end

local function constrainAngles(angles, pitchLimits, yawLimits)
	--Given a rotation as a CFrame, constrain the pitch and yaw to be inside some limits.

	--Rotate back to make the new rotation within the limits
	local unlimitedCFrame = angles
	local limitedCFrame = unlimitedCFrame

	--Limit pitch
	if pitchLimits then
		local newPitch = getCFramePitch(unlimitedCFrame)

		if newPitch > pitchLimits.Max then
			local extraPitch = newPitch - pitchLimits.Max
			limitedCFrame = rotateCFrameCameralike(limitedCFrame, -extraPitch, 0)
		elseif newPitch < pitchLimits.Min then
			local missingPitch = pitchLimits.Min - newPitch
			limitedCFrame = rotateCFrameCameralike(limitedCFrame, missingPitch, 0)
		end
	end

	--Limit yaw
	if yawLimits then
		local newYaw = getCFrameYaw(limitedCFrame)

		if newYaw > yawLimits.Max then
			local extraYaw = newYaw - yawLimits.Max
			limitedCFrame = rotateCFrameCameralike(limitedCFrame, 0, -extraYaw)
		elseif newYaw < yawLimits.Min then
			local missingYaw = yawLimits.Min - newYaw
			limitedCFrame = rotateCFrameCameralike(limitedCFrame, 0, missingYaw)
		end
	end

	return limitedCFrame
end

local function getMouseMovement(dragToRotateViewportFrame)
	--Returns the amount that the mouse moved since last frame
	local movement

	if dragToRotateViewportFrame.MouseMode == "LockPosition" then
		movement = UserInputService:GetMouseDelta()
	elseif dragToRotateViewportFrame.MouseMode == "Default" then
		local mousePosition = UserInputService:GetMouseLocation()
		movement = ((_lastMousePosition or mousePosition) - mousePosition)
		_lastMousePosition = mousePosition
	else
		error("")
	end

	return movement
end

local function getTouchMovement(inputObject)
	--Returns the amount that the mouse moved since last frame
	local movement

	local touchPosition = inputObject.Position
	movement = ((_lastMousePosition or touchPosition) - touchPosition)
	_lastMousePosition = touchPosition

	return movement
end

--------------------------------------------------------------------------------
-- DragToRotateViewportFrame class
----------------------------------------

local DragToRotateViewportFrame = {}
local DragToRotateViewportFrameMT = {
	__index = DragToRotateViewportFrame,
}

function DragToRotateViewportFrame.New(...)
	local self = setmetatable({}, DragToRotateViewportFrameMT)
	self:Initialize(...)
	return self
end

function DragToRotateViewportFrame:Initialize(viewportFrame, camera)
	assertf(
		viewportFrame == nil or isValueOfClass(viewportFrame, "ViewportFrame"),
		'Tried to initialize %s with argument #1 %s "%s", expected ViewportFrame.',
		CLASS_NAME,
		typeof(viewportFrame),
		tostring(viewportFrame)
	)
	assertf(
		camera == nil or isValueOfClass(camera, "Camera"),
		'Tried to initialize %s with argument #2 %s "%s", expected Camera.',
		CLASS_NAME,
		typeof(camera),
		tostring(camera)
	)

	self.ViewportFrame = viewportFrame or Instance.new("ViewportFrame")
	self.Camera = camera or Instance.new("Camera")

	self.ViewportFrame.CurrentCamera = self.Camera
	self.Camera.CameraType = Enum.CameraType.Scriptable
	self.Camera.Parent = self.ViewportFrame

	self.PitchLimits = NumberRange.new(math.rad(-60), math.rad(60))
	self.YawLimits = nil
	self.RotateMode = "CameraRotates"
	self.MouseMode = "LockPosition"
end

function DragToRotateViewportFrame:SetModel(model)
	-- assertf(
	-- 	isValueOfClass(model, "Model"),
	-- 	'Called %s:SetModel with argument #1 %s "%s", expected Model.',
	-- 	CLASS_NAME,
	-- 	typeof(model),
	-- 	tostring(model)
	-- )
	assertf(model.PrimaryPart ~= nil, "Called %s:SetModel with a model without a PrimaryPart.", CLASS_NAME)

	self.Model = model

	model.Parent = self.ViewportFrame
	model:SetPrimaryPartCFrame(CFrame.new())

	self:SetAngles(CFrame.Angles(0, math.pi, 0))
	self:Rotate(0, 0)
	self.InitalCameraCFrame = self.Camera.CFrame
	self.InitialFOV = self.Camera.FieldOfView
end

function DragToRotateViewportFrame:SetAngles(angles)
	assertf(
		typeofIs(angles, "CFrame"),
		'Called %s:SetAngles argument #1 with a %s "%s", expected CFrame.',
		CLASS_NAME,
		typeof(angles),
		tostring(angles)
	)
	local angles = cFrameToAngles(angles)

	if self.RotateMode == "CameraRotates" then
		local minCamDist = getModelCornerDist(self.Model)
		local camDist = minCamDist * 1
		local camCenter, _ = self.Model:GetBoundingBox()

		self.Camera.CFrame = (camCenter * angles) * CFrame.new(0, 0, camDist)
	elseif self.RotateMode == "ModelRotates" then
		self.Model:SetPrimaryPartCFrame(CFrame.new() * angles:Inverse())
	else
		warnf("Invalid RotateMode %s, expected %s or %s", tostring(self.RotateMode), "CameraRotates", "ModelRotates")
	end
end

function DragToRotateViewportFrame:GetAngles()
	local angles

	if self.RotateMode == "CameraRotates" then
		angles = self.Camera.CFrame
	elseif self.RotateMode == "ModelRotates" then
		angles = self.Model.PrimaryPart.CFrame:Inverse()
	else
		warnf("Invalid RotateMode %s, expected %s or %s", tostring(self.RotateMode), "CameraRotates", "ModelRotates")
	end

	return cFrameToAngles(angles)
end

function DragToRotateViewportFrame:Rotate(dPitch, dYaw)
	--Perform the rotation in small steps, to prevent large changes in rotation "overwhelming" the angle limiting
	while math.abs(dPitch) > MAX_ANGLE_STEP do
		self:Rotate(MAX_ANGLE_STEP * math.sign(dPitch), 0)
		dPitch -= MAX_ANGLE_STEP * math.sign(dPitch)
	end

	while math.abs(dYaw) > MAX_ANGLE_STEP do
		self:Rotate(0, MAX_ANGLE_STEP * math.sign(dYaw))
		dYaw -= MAX_ANGLE_STEP * math.sign(dYaw)
	end

	--Rotate the rest of the way (still a small step since dPitch and dYaw were decremented earlier)
	local rotatedCFrame = rotateCFrameCameralike(self:GetAngles(), dPitch, dYaw)

	--Constrain the rotation according to PitchLimit and YawLimit, if present.
	local fixedPitchLimits
	if self.PitchLimits then
		--Flip sign of min and max if RotateMdoe is CameraROtates
		fixedPitchLimits = self.RotateMode == "CameraRotates" and self.PitchLimits
			or NumberRange.new(-self.PitchLimits.Max, -self.PitchLimits.Min)
	end

	local fixedYawLimits
	if self.YawLimits then
		--Flip sign of min and max if RotateMdoe is CameraROtates
		fixedYawLimits = self.RotateMode == "CameraRotates" and self.YawLimits
			or NumberRange.new(-self.YawLimits.Max, -self.YawLimits.Min)
	end

	--Actually do the limiting
	local limitedCFrame
	if self.RotateMode == "CameraRotates" then
		limitedCFrame = constrainAngles(rotatedCFrame, fixedPitchLimits, fixedYawLimits)
	else
		limitedCFrame = constrainAngles(rotatedCFrame * CFrame.Angles(0, math.pi, 0), fixedPitchLimits, fixedYawLimits)
			* CFrame.Angles(0, math.pi, 0)
	end

	self:SetAngles(limitedCFrame)
end

function DragToRotateViewportFrame:BeginDragging()
	_lastMousePosition = nil

	self.renderSteppedC = RunS.RenderStepped:Connect(function()
		if self.MouseMode == "LockCenter" then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end)

	self.inputChangedC = UserInputService.InputChanged:Connect(function(inputObject)
		local delta
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			delta = getMouseMovement(self)
		end
		if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
			delta = getTouchMovement(inputObject)
		end
		--Flip pitch direction
		if self.RotateMode == "ModelRotates" then
			delta = delta * Vector2.new(1, -1)
		end

		if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
			self.Camera.FieldOfView = self.Camera.FieldOfView - inputObject.Position.Z * 10
			return
		end
		self:Rotate(-delta.Y / 100, -delta.X / 100)
	end)
end

function DragToRotateViewportFrame:StopDragging()
	if self.inputChangedC then
		self.inputChangedC:Disconnect()
		self.inputChangedC = nil
	end

	if self.renderSteppedC then
		self.renderSteppedC:Disconnect()
		self.renderSteppedC = nil
	end

	--if after a certain time there's no more dragging return to the initial camera position
	task.delay(1.6, function()
		if self.Camera.CFrame ~= self.InitalCameraCFrame and not self.renderSteppedC and not self.inputChangedC then
			TweenService:Create(
				self.Camera,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = self.InitalCameraCFrame, FieldOfView = self.InitialFOV }
			):Play()
		end
	end)
end

return DragToRotateViewportFrame
