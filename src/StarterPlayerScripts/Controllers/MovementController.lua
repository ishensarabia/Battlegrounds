local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MovementController = Knit.CreateController({ Name = "MovementController" })

local ACTION_DASH = "DASH"
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

function MovementController:KnitStart() end

function MovementController:Dash(direction: string, vectorMultiplier: number)
	-- Check if the dash action is already debounced
	if not self.debounces.dash and character.Humanoid:GetState() == Enum.HumanoidStateType.Running then
		character.Humanoid.JumpPower = 0
		-- Mute the footsteps sound while dashing
		local footstepsSound = Players.LocalPlayer.Character.HumanoidRootPart.Running
		footstepsSound.Volume = 0

		-- Get necessary controllers and services
		local AnimationController = Knit.GetController("AnimationController")
		local WeaponsController = Knit.GetController("WeaponsController")
		local VFXService = Knit.GetService("VFXService")
		local AudioService = Knit.GetService("AudioService")
		-- Play the dash animation and trigger necessary actions
		local animationName = ANIM_NAME_DICTIONARY.DASH[direction]
		local animationTrack =
			AnimationController:PlayAnimation(animationName, ANIM_SPEED_DICTIONARY.DASH[animationName])
		WeaponsController:Dash()
		VFXService:Dash()
		AudioService:PlaySound("Dash", true)

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

		-- Reset debounced state, enable IK and footsteps sound at the end of the dash animation
		animationTrack.Ended:Connect(function()
			self.debounces.dash = false
			character.Humanoid.JumpPower = 31
			footstepsSound.Volume = 1.0
		end)
	end
end

function MovementController:KnitInit()
	--Bind the actions to the character
	self.debounces = {}
	self.debounces.dash = false
	Players.LocalPlayer.CharacterAdded:Connect(function(_character)
		-- Disable the ragdoll state for the character's humanoid when it is created
		_character:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		_character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		character = _character
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
		end, true, Enum.KeyCode.LeftControl)
		ContextActionService:SetPosition(ACTION_DASH, UDim2.new({ 0.916, 0 }, { 0.439, 0 }))
		ContextActionService:SetDescription(ACTION_DASH, "Dash movement")
		ContextActionService:SetTitle(ACTION_DASH, ACTION_DASH)
	end)
end

return MovementController
