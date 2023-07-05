local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MovementController = Knit.CreateController({ Name = "MovementController" })

local ACTION_DASH = "DASH"
local ACTION_SLIDE = "SLIDE"

local SLIDE_KEYCODE = Enum.KeyCode.C

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
local SLIDE_FORCE = 3.33 	
local DASH_STAMINA_COST = 10
local SLIDE_STAMINA_COST = 6
local isHolding = false

function MovementController:KnitStart() end

function MovementController:Dash(direction: string, vectorMultiplier: number)
	-- Check if the player has enough stamina to dash
	if character:GetAttribute("Stamina") >= DASH_STAMINA_COST then
		-- Check if the dash action is already debounced
		if not self.debounces.dash and character.Humanoid:GetState() == Enum.HumanoidStateType.Running then
			character.Humanoid.JumpPower = 0
			-- Mute the footsteps sound while dashing
			local footstepsSound = Players.LocalPlayer.Character.HumanoidRootPart.Running
			footstepsSound.Volume = 0

			-- Get necessary controllers and services
			local WeaponsController = Knit.GetController("WeaponsController")
			local VFXService = Knit.GetService("VFXService")
			local AudioService = Knit.GetService("AudioService")
			-- Play the dash animation and trigger necessary actions
			local animationName = ANIM_NAME_DICTIONARY.DASH[direction]
			local animationTrack =
				self.AnimationController:PlayAnimation(animationName, ANIM_SPEED_DICTIONARY.DASH[animationName])
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

			self.StatsService:ExecuteAction("Dash")
			-- Reset debounced state, enable IK and footsteps sound at the end of the dash animation
			animationTrack.Ended:Connect(function()
				self.debounces.dash = false
				character.Humanoid.JumpPower = 31
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
		if not self.debounces.slide and character.Humanoid:GetState() == Enum.HumanoidStateType.Running then
			character.Humanoid.JumpPower = 0
			-- Mute the footsteps sound while slideing
			local footstepsSound = Players.LocalPlayer.Character.HumanoidRootPart.Running
			footstepsSound.Volume = 0

			-- Get necessary controllers and services
			local WeaponsController = Knit.GetController("WeaponsController")
			local VFXService = Knit.GetService("VFXService")
			local AudioService = Knit.GetService("AudioService")
			-- Play the slide animation and trigger necessary actions
			local animationTrack = self.AnimationController:PlayAnimation("Slide")
			-- WeaponsController:Slide()
			VFXService:Slide()

			-- Set the slide action to debounced state
			self.debounces.slide = true

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
					AudioService:PlaySound("Slide", true, { RollOffMaxDistance = 100, RollOffMinDistance = 10, RollOffMode = Enum.RollOffMode.Linear })
					linearVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * slideForceLeft
				else
					self.AnimationController:StopAnimation("Slide")
					slideLoop:Disconnect()
				end
				task.wait(1)
			end)

			-- Reset debounced state, enable IK and footsteps sound at the end of the dash animation
			animationTrack.Ended:Connect(function()
				self.StatsService:StopAction("Slide")
				VFXService:StopSlide()
				self.debounces.slide = false
				character.Humanoid.JumpPower = 31
				footstepsSound.Volume = 1.0
				linearVelocity:Destroy()
				if slideLoop then
					slideLoop:Disconnect()
				end
			end)
		end
	end
end

function MovementController:OnJumpRequest()
	local player = Players.LocalPlayer
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
		self.AnimationController:StopAnimation("Climb")
		self.AnimationController:PlayAnimation("Climb_Up")
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

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

		local raycast = workspace:Raycast(head.CFrame.p, head.CFrame.LookVector * 3.33, raycastParams)
		if raycast then
			if
				head.Position.Y >= (raycast.Instance.Position.Y + (raycast.Instance.Size.Y / 2)) - 1.9
				and head.Position.Y <= raycast.Instance.Position.Y + (raycast.Instance.Size.Y / 2)
			then
				--Unequip the tools from the humanoid
				player.Character.Humanoid:UnequipTools()
				rootPart.Anchored = true
			isHolding = true
				self.AnimationController:PlayAnimation("Climb")
				--Generate a loop to drain stamina while holding the jump button
				local staminaDrainLoop
				staminaDrainLoop = RunService.Heartbeat:Connect(function()
					if character:GetAttribute("Stamina") < 1 then
						rootPart.Anchored = false
						isHolding = false
						self.AnimationController:StopAnimation("Climb")
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
end

function MovementController:KnitInit()
	--Bind the actions to the character
	self.debounces = {}
	self.debounces.dash = false
	--Get the necessary controllers and services
	self.AnimationController = Knit.GetController("AnimationController")
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
		end, true, Enum.KeyCode.LeftControl)

		--Set the position and description of the dash action
		ContextActionService:SetPosition(ACTION_DASH, UDim2.new({ 0.916, 0 }, { 0.439, 0 }))
		ContextActionService:SetDescription(ACTION_DASH, "Dash movement")
		ContextActionService:SetTitle(ACTION_DASH, ACTION_DASH)
		local isPressingSlide

		ContextActionService:BindAction(ACTION_SLIDE, function(actionName, inputState, _inputObject)
			if actionName == ACTION_SLIDE and inputState == Enum.UserInputState.Begin then
				self:Slide()
			end
			if actionName == ACTION_SLIDE and inputState == Enum.UserInputState.End then
				self.AnimationController:StopAnimation("Slide")
			end
		end, true, SLIDE_KEYCODE)

		--Hook the user input service to the jump action
		UserInputService.JumpRequest:Connect(function()
			self:OnJumpRequest()
		end)
	end)
end

return MovementController
