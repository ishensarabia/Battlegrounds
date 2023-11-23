local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
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

--Variables
local ledgePart
local canVault = true
local vaultConnection

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

--check if part is above when tryin to vault or move
local function partCheck(ledge)
	local character = player.Character
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local vaultPartCheck = workspace:Raycast(
		ledge.Position + Vector3.new(0, -1, 0) + ledge.LookVector * 1,
		ledge.UpVector * 3,
		raycastParams
	)
	if vaultPartCheck == nil then
		return true
	else
		return false, vaultPartCheck
	end
end

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
				self.StatsService:StopAction("Dash")
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
				Debris:AddItem(linearVelocity, 0.33)
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
			character.Humanoid.FreeFalling:Connect(function(active)
				self.isCrouching = false
				self._AnimationController:StopAnimation("Crouch")
				character.Humanoid.WalkSpeed = normalWalkSpeed
				character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
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
		humanoid.AutoRotate = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		bodyVelocity.MaxForce = Vector3.new(999999, 999999, 999999)
		bodyVelocity.Velocity = rootPart.CFrame.LookVector * 5 + Vector3.new(0, 16, 0)
		isHolding = false
		Debris:AddItem(bodyVelocity, 0.5)
		self._AnimationController:StopAnimation("Climb")
		self._AnimationController:PlayAnimation("Climb_Up")
		self.StatsService:ExecuteAction("Climb_Up")
		if ledgePart then
			ledgePart:Destroy()
		end
	end
	local function AttachToLedge(ledgeOffset)
		if ledgePart then
			ledgePart:Destroy()
		end
		canVault = false
		-- 	--Unequip the tools from the humanoid
		player.Character.Humanoid:UnequipTools()
		isHolding = true

		--player follows this part(you dont exactly need it but it makes tweening the player when they move easier unless there is a better way to do this but idk)
		ledgePart = Instance.new("Part")
		ledgePart.Parent = workspace
		ledgePart.Anchored = true
		ledgePart.Size = Vector3.one
		ledgePart.CFrame = ledgeOffset + Vector3.new(0, -2, 0) + ledgeOffset.LookVector * -1
		ledgePart.CanQuery = false
		ledgePart.CanCollide = false
		ledgePart.CanTouch = false
		ledgePart.Transparency = 1

		--play anim and sound
		self._AnimationController:PlayAnimation("Climb")

		--connection while player is on a ledge
		rootPart.Anchored = true
		vaultConnection = RunService.RenderStepped:Connect(function(dt)
			humanoid.AutoRotate = false -- so shift lock doesnt't rotate character
			rootPart.CFrame = rootPart.CFrame:Lerp(
				CFrame.lookAt(ledgePart.Position, (ledgePart.CFrame * CFrame.new(0, 0, -1)).Position),
				0.25
			)
			if character:GetAttribute("Stamina") < 1 then
				rootPart.Anchored = false
				humanoid.AutoRotate = true
				isHolding = false
				canVault = true
				self._AnimationController:StopAnimation("Climb")
				if ledgePart then
					ledgePart:Destroy()
				end
				vaultConnection:Disconnect()
			end
			if isHolding then
				self.StatsService:ExecuteAction("Climb")
			else
				self.StatsService:StopAction("Climb")
				vaultConnection:Disconnect()
			end
			humanoid:ChangeState(Enum.HumanoidStateType.Seated)
		end)
	end
	if
		canVault
		and (
			humanoid:GetState() == Enum.HumanoidStateType.Jumping
			or humanoid:GetState() == Enum.HumanoidStateType.Freefall
		)
	then
		local head = character:WaitForChild("Head")

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		local vaultCheck = workspace:Raycast(rootPart.CFrame.Position, rootPart.CFrame.LookVector * 5, raycastParams)
		if vaultCheck and vaultCheck.Instance then
			local localPos = vaultCheck.Instance.CFrame:PointToObjectSpace(vaultCheck.Position)
			local localLedgePos = Vector3.new(localPos.X, vaultCheck.Instance.Size.Y / 2, localPos.Z)
			local ledgePos = vaultCheck.Instance.CFrame:PointToWorldSpace(localLedgePos)
			local ledgeOffset = CFrame.lookAt(ledgePos, ledgePos - vaultCheck.Normal)

			local magnitude = (ledgePos - head.Position).Magnitude
			if magnitude < 4 then
				if partCheck(ledgeOffset) then
					AttachToLedge(ledgeOffset)
				else
					local newVaultCheck = workspace:Raycast(
						rootPart.CFrame.Position + Vector3.new(0, 4.33, 0),
						rootPart.CFrame.LookVector * 5,
						raycastParams
					)
					if newVaultCheck and newVaultCheck.Instance then
						local localPos = newVaultCheck.Instance.CFrame:PointToObjectSpace(newVaultCheck.Position)
						local localLedgePos = Vector3.new(localPos.X, newVaultCheck.Instance.Size.Y / 2, localPos.Z)
						local ledgePos = newVaultCheck.Instance.CFrame:PointToWorldSpace(localLedgePos)
						local ledgeOffset = CFrame.lookAt(ledgePos, ledgePos - newVaultCheck.Normal)
						warn(newVaultCheck.Instance.BrickColor)
						if partCheck(ledgeOffset) then
							AttachToLedge(ledgeOffset)
						end
					end
				end
			end
		end
	elseif not canVault then
		canVault = true
		Climb()
		if vaultConnection then
			vaultConnection:Disconnect()
		end
		if ledgePart then
			ledgePart:Destroy()
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
		--Connect died event to reset values
		canVault = true
		if ledgePart then
			ledgePart:Destroy()
		end
		-- Disable the ragdoll state for the character's humanoid when it is created
		_character:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		_character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		character = _character
	end)
	--Bind actions to the context action service
	ContextActionService:BindAction(ACTION_DASH, function(actionName, inputState, _inputObject)
		if actionName == ACTION_DASH and inputState == Enum.UserInputState.Begin then
			local Cam = workspace.CurrentCamera
			if character.Humanoid.MoveDirection:Dot(Cam.CFrame.RightVector) > 0.75 then
				self:Dash(DIRECTIONS.RIGHT, DASH_FORCE)
			end
			if character.Humanoid.MoveDirection:Dot(-Cam.CFrame.RightVector) > 0.75 then
				self:Dash(DIRECTIONS.LEFT, -DASH_FORCE)
			end
			if character.Humanoid.MoveDirection:Dot(Cam.CFrame.LookVector) > 0.75 then
				self:Dash(DIRECTIONS.FORWARD, DASH_FORCE)
			end
			if character.Humanoid.MoveDirection:Dot(-Cam.CFrame.LookVector) > 0.75 then
				self:Dash(DIRECTIONS.BACKWARDS, -DASH_FORCE)
			end
		end
	end, true, DASH_KEYCODE, Enum.KeyCode.ButtonB)

	--Set the position and description of the dash action
	ContextActionService:SetPosition(ACTION_DASH, UDim2.new({ 0.936, 0 }, { 0.439, 0 }))
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
	end, true, CROUCH_KEYCODE, Enum.KeyCode.ButtonR3)

	ContextActionService:SetPosition(ACTION_CROUCH, UDim2.fromScale(0.33, 0.439))
	ContextActionService:SetTitle(ACTION_CROUCH, ACTION_CROUCH)
	--Hook the user input service to the jump action
	--pc and console support
	UserInputService.InputBegan:Connect(function(input, gp)
		if input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.Space then
			self:OnJumpRequest()
		end
	end)

	--mobile support
	if
		UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.MouseEnabled
		and not UserInputService.GamepadEnabled
		and not GuiService:IsTenFootInterface()
	then
		local jumpButton =
			player.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
		jumpButton.Activated:Connect(function()
			self:OnJumpRequest()
			if self.isCrouching then
				self._AnimationController:StopAnimation("Crouch")
			end
		end)
	end
end

return MovementController
