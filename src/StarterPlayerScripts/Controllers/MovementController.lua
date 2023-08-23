local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local player = Players.LocalPlayer

local MovementController = Knit.CreateController({ Name = "MovementController" })

local ACTION_DASH = "DASH"
local ACTION_SLIDE = "SLIDE"
local ACTION_CROUCH = "CROUCH"

local CROUCH_KEYCODE = Enum.KeyCode.C
local DASH_KEYCODE = Enum.KeyCode.LeftAlt

local character
local DIRECTIONS = {
	FORWARD = "FORWARD",
	BACKWARDS = "BACKWARDS",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}
local ANIM_NAME_DICTIONARY = {
	DASH = {
		RIGHT = "Right_Dash",
		LEFT = "Left_Dash",
		FORWARD = "Forward_Dash",
		BACKWARDS = "Backwards_Dash",
	},
}
local ANIM_SPEED_DICTIONARY = {
	DASH = {
		Forward_Dash = 1.33,
	},
}

local DASH_FORCE = 23
local SLIDE_FORCE = 9.33
local DASH_STAMINA_COST = 10
local SLIDE_STAMINA_COST = 6
local isHolding = false
local SLIDE_SPEED_THRESHOLD = 16
-- Walk speeds
local zoomWalkSpeed = 8
local normalWalkSpeed = 13.33
local sprintingWalkSpeed = 19.99
local crouchWalkSpeed = 7
local dashingWalkSpeed = 0

function MovementController:KnitStart()
	self._WeaponsController = Knit.GetController("WeaponsController")
	self._VFXService = Knit.GetService("VFXService")
	self._AudioService = Knit.GetService("AudioService")
end

function MovementController:Dash(direction: string, vectorMultiplier: number)
	-- Check if the player has enough stamina to dash
	if character:GetAttribute("Stamina") >= DASH_STAMINA_COST then
		-- Check if the dash action is already debounced
		if not self.debounces.dash and character.Humanoid:GetState() == Enum.HumanoidStateType.Running then
			character.Humanoid.JumpPower = 0
			-- Mute the footsteps sound while dashing
			local footstepsSound = Players.LocalPlayer.Character.HumanoidRootPart.Running
			footstepsSound.Volume = 0
			-- Play the dash animation and trigger necessary actions
			local animationName = ANIM_NAME_DICTIONARY.DASH[direction]
			local animationTrack =
				self._AnimationController:PlayAnimation(animationName, ANIM_SPEED_DICTIONARY.DASH[animationName])
			--Notify weapon controller and VFX service that the player is dashing
			self._WeaponsController:Dash()
			self._VFXService:Dash()
			--Play the dash sound
			self._AudioService:PlaySound("Dash", true)

			-- Set the dash action to debounced state
			self.debounces.dash = true

			-- Create a body velocity object to move the character
			local linearVelocity = Instance.new("BodyVelocity")
			linearVelocity.Parent = character.HumanoidRootPart
			linearVelocity.MaxForce = Vector3.new(999999, 0, 999999)

			-- Set the direction and speed of the dash based on input
			if direction == DIRECTIONS.RIGHT or direction == DIRECTIONS.LEFT then
				linearVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * vectorMultiplier
			end
			if direction == DIRECTIONS.FORWARD or direction == DIRECTIONS.BACKWARDS then
				linearVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * vectorMultiplier
			end

			-- Delete the body velocity object after 0.3 seconds
			Debris:AddItem(linearVelocity, 0.8)

			self.StatsService:ExecuteAction("Dash")
			-- Reset debounced state, enable IK and footsteps sound at the end of the dash animation
			animationTrack.Ended:Connect(function()
				self.debounces.dash = false
				character.Humanoid.JumpPower = 31
				character.Humanoid.WalkSpeed = normalWalkSpeed
				footstepsSound.Volume = 1.0
			end)
		end
	end
end

--Slide function
function MovementController:Slide()
	-- Check if the player has enough stamina to slide
	if character:GetAttribute("Stamina") >= SLIDE_STAMINA_COST then
		-- Check if the slide action is already debounced
		if character.Humanoid:GetState() == Enum.HumanoidStateType.Running and not self.isSliding then
			self.isSliding = true
			character.Humanoid.JumpPower = 0
			-- Mute the footsteps sound while slideing
			local footstepsSound = Players.LocalPlayer.Character.HumanoidRootPart.Running
			footstepsSound.Volume = 0

			-- Get necessary controllers and services

			-- Play the slide animation and trigger necessary actions
			local animationTrack = self._AnimationController:PlayAnimation("Slide")
			--Notify weapon controller and VFX service that the player is slideing
			self._WeaponsController:Slide(animationTrack)
			self._VFXService:Slide()

			-- Set the slide action to debounced state
			self.isSliding = true

			-- Create a body velocity object to move the character
			local linearVelocity = Instance.new("BodyVelocity")
			linearVelocity.Parent = character.HumanoidRootPart
			linearVelocity.MaxForce = Vector3.new(999999, 0, 999999)

			-- Set the direction and speed of the slide based on input

			--Reduce the velocity of the character over time to simulate friction
			local slideLoop
			local slideForceLeft = SLIDE_FORCE + character.Humanoid.WalkSpeed
			slideLoop = RunService.Heartbeat:Connect(function()
				slideForceLeft -= 0.133
				if linearVelocity.Velocity.Magnitude > 0 and slideForceLeft > 9 then
					self.StatsService:ExecuteAction("Slide")
					self._AudioService:PlaySound(
						"Slide",
						true,
						{ RollOffMaxDistance = 100, RollOffMinDistance = 10, RollOffMode = Enum.RollOffMode.Linear }
					)
					linearVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * slideForceLeft
				else
					self._AnimationController:StopAnimation("Slide")
					slideLoop:Disconnect()
				end
				task.wait(1)
			end)

			-- Reset debounced state, enable IK and footsteps sound at the end of the dash animation
			animationTrack.Ended:Connect(function()
				self.StatsService:StopAction("Slide")
				self._VFXService:StopSlide()
				self.isSliding = false
				character.Humanoid.JumpPower = 31
				character.Humanoid.WalkSpeed = normalWalkSpeed
				footstepsSound.Volume = 1.0
				linearVelocity:Destroy()
				if slideLoop then
					slideLoop:Disconnect()
				end
			end)
		end
	end
end

function MovementController:Crouch()
	if character and character.Humanoid.Health > 0 then
		if not self.isCrouching then
			self.isCrouching = true
			local animationTrack = self._AnimationController:PlayAnimation("Crouch")
			animationTrack:AdjustSpeed(0)
			character.Humanoid.WalkSpeed = crouchWalkSpeed
			character.Humanoid.Running:Connect(function(speed)
				if speed == 0 then
					animationTrack:AdjustSpeed(0)
				else
					animationTrack:AdjustSpeed(1)
				end
			end)
			--Notify weapon controller
			self._WeaponsController:Crouch(animationTrack)
			character.Humanoid.CameraOffset = Vector3.new(0, -0.5, 0)
		else
			self.isCrouching = false
			self._AnimationController:StopAnimation("Crouch")
			character.Humanoid.WalkSpeed = normalWalkSpeed
			character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end
	end
end

function MovementController:OnJumpRequest()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local function Climb()
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Parent = character.HumanoidRootPart
		rootPart.Anchored = false
		bodyVelocity.MaxForce = Vector3.new(999999, 999999, 999999)
		bodyVelocity.Velocity = rootPart.CFrame.LookVector * 5 + Vector3.new(0, 16, 0)
		isHolding = false
		Debris:AddItem(bodyVelocity, 0.5)
		self._AnimationController:StopAnimation("Climb")
		self._AnimationController:PlayAnimation("Climb_Up")
		self.StatsService:ExecuteAction("Climb_Up")
	end

	if isHolding then
		Climb()
		return
	end

	if
		humanoid:GetState() == Enum.HumanoidStateType.Jumping
		or humanoid:GetState() == Enum.HumanoidStateType.Freefall
	then
		local head = character:WaitForChild("Head")
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

		local raycast =
			workspace:Raycast(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 2, raycastParams)
		local other_raycast =
			workspace:Raycast(head.Position + Vector3.new(0, 1, 0), head.CFrame.LookVector * 2, raycastParams)
		if raycast and not other_raycast then
			--Unequip the tools from the humanoid
			player.Character.Humanoid:UnequipTools()
			rootPart.Anchored = true
			isHolding = true
			self._AnimationController:PlayAnimation("Climb")
			--Generate a loop to drain stamina while holding the jump button
			local staminaDrainLoop
			staminaDrainLoop = RunService.Heartbeat:Connect(function()
				if character:GetAttribute("Stamina") < 1 then
					rootPart.Anchored = false
					isHolding = false
					self._AnimationController:StopAnimation("Climb")
					staminaDrainLoop:Disconnect()
				end
				if isHolding then
					self.StatsService:ExecuteAction("Climb")
				else
					staminaDrainLoop:Disconnect()
				end
			end)
		end
	end
end

function MovementController:KnitInit()
	--Bind the actions to the character
	self.debounces = {}
	self.debounces.dash = false
	self.isCrouching = false
	self.isSliding = false
	--Get the necessary controllers and services
	self._AnimationController = Knit.GetController("AnimationController")
	self.StatsService = Knit.GetService("StatsService")
	Players.LocalPlayer.CharacterAdded:Connect(function(_character)
		-- Disable the ragdoll state for the character's humanoid when it is created
		_character:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		_character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		character = _character
		--Bind actions to the context action service
		ContextActionService:BindAction(ACTION_DASH, function(actionName, inputState, _inputObject)
			if actionName == ACTION_DASH and inputState == Enum.UserInputState.Begin then
				local Cam = workspace.CurrentCamera
				if _character.Humanoid.MoveDirection:Dot(Cam.CFrame.RightVector) > 0.75 then
					self:Dash(DIRECTIONS.RIGHT, DASH_FORCE)
				end
				if _character.Humanoid.MoveDirection:Dot(-Cam.CFrame.RightVector) > 0.75 then
					self:Dash(DIRECTIONS.LEFT, -DASH_FORCE)
				end
				if _character.Humanoid.MoveDirection:Dot(Cam.CFrame.LookVector) > 0.75 then
					self:Dash(DIRECTIONS.FORWARD, DASH_FORCE)
				end
				if _character.Humanoid.MoveDirection:Dot(-Cam.CFrame.LookVector) > 0.75 then
					self:Dash(DIRECTIONS.BACKWARDS, -DASH_FORCE)
				end
			end
		end, true, DASH_KEYCODE)

		--Set the position and description of the dash action
		ContextActionService:SetPosition(ACTION_DASH, UDim2.new({ 0.916, 0 }, { 0.439, 0 }))
		ContextActionService:SetDescription(ACTION_DASH, "Dash movement")
		ContextActionService:SetTitle(ACTION_DASH, ACTION_DASH)

		ContextActionService:BindAction(ACTION_CROUCH, function(actionName, inputState, _inputObject)
			if actionName == ACTION_CROUCH and inputState == Enum.UserInputState.Begin then
				local humanoid = character:WaitForChild("Humanoid")
				if humanoid:GetState() == Enum.HumanoidStateType.Running then
					local currentSpeed = humanoid.WalkSpeed
					if currentSpeed >= SLIDE_SPEED_THRESHOLD then
						-- Slide to crouch conversion
						self:Slide()
					else
						-- Normal crouching action
						self:Crouch()
					end
				end
			end
			if actionName == ACTION_CROUCH and inputState == Enum.UserInputState.End and self.isSliding then
				self._AnimationController:StopAnimation("Slide")
			end
		end, true, CROUCH_KEYCODE)

		--Hook the user input service to the jump action
		UserInputService.JumpRequest:Connect(function()
			self:OnJumpRequest()
			if self.isCrouching then
				self._AnimationController:StopAnimation("Crouch")
			end
		end)
	end)
end

return MovementController
