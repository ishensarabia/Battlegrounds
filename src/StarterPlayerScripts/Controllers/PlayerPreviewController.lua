local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerPreviewController = Knit.CreateController({ Name = "PlayerPreviewController" })

local playerCharacter

function PlayerPreviewController:setHeadMouseBehavior(bool : boolean)
	if (bool) then
		local attachment = Instance.new("Attachment")
		attachment.Name = "Camera Follow"
		attachment.CFrame = playerCharacter.Head.CFrame 
		attachment.Parent = playerCharacter.Head 

		local IKController = Instance.new("IKControl")
		IKController.Parent = playerCharacter.Humanoid
		IKController.ChainRoot = playerCharacter.UpperTorso
		IKController.EndEffector = playerCharacter.Head
		IKController.Target = attachment
		IKController.Pole = nil
		RunService.RenderStepped:Connect(function(deltaTime)
			attachment.WorldPosition = CFrame.lookAt(playerCharacter.Head.CFrame.Position, Vector3.new(Mouse.Hit.Position.X, playerCharacter.HumanoidRootPart.CFrame.Position.Y, Mouse.Hit.Position.Z)).Position
		end)
	end
end


function PlayerPreviewController:spawnCharacterInMenu()
	playerCharacter = Players.LocalPlayer.PlayerGui
:WaitForChild("MainMenu").playerPreview.viewportFrame.WorldModel
:WaitForChild("Dummy")
	local idleAnimation = Instance.new("Animation")
	idleAnimation.AnimationId = "rbxassetid://782841498"
	idleAnimation.Name = "Idle"
	local idleAnimationTrack = playerCharacter.Humanoid.Animator:LoadAnimation(idleAnimation)
	idleAnimationTrack:Play()
	local longWeaponAnimation = Instance.new("Animation")
	longWeaponAnimation.AnimationId = "rbxassetid://11191090687"
	longWeaponAnimation.Name = "longWeapon"
	local longWeaponAnimationTrack = playerCharacter.Humanoid.Animator:LoadAnimation(longWeaponAnimation)
	longWeaponAnimationTrack:Play()
	--Spawn equipped weapon / power
	local clonedRocketLauncher = workspace.RocketLauncher:Clone()
	clonedRocketLauncher.Parent = playerCharacter.Parent
	clonedRocketLauncher.RocketLauncher:SetPrimaryPartCFrame(
		playerCharacter.PrimaryPart.CFrame + Vector3.new(-1.5, 0, 0)
	)
	--Weld
	local weld = Instance.new("Weld")
	weld.Parent = clonedRocketLauncher.Handle
	weld.C0 = playerCharacter.RightHand.RightGripAttachment.CFrame
	weld.C1 = CFrame.new(
		clonedRocketLauncher.GripPos.x,
		clonedRocketLauncher.GripPos.y,
		clonedRocketLauncher.GripPos.z,
		clonedRocketLauncher.GripRight.x,
		clonedRocketLauncher.GripUp.x,
		-clonedRocketLauncher.GripForward.x,
		clonedRocketLauncher.GripRight.y,
		clonedRocketLauncher.GripUp.y,
		-clonedRocketLauncher.GripForward.y,
		clonedRocketLauncher.GripRight.z,
		clonedRocketLauncher.GripUp.z,
		-clonedRocketLauncher.GripForward.z
	)
	weld.Part0 = playerCharacter.RightHand
	weld.Part1 = clonedRocketLauncher.Handle
	
	-- self:setHeadMouseBehavior( true)

	--Animate the selected weapon
	local IKController = Instance.new("IKControl")
	IKController.Parent = playerCharacter.Humanoid
	IKController.ChainRoot = playerCharacter.LeftUpperArm
	IKController.EndEffector = playerCharacter.LeftHand
	IKController.Target = clonedRocketLauncher.RocketLauncher.Model.SecondHandleAttachment

end

function PlayerPreviewController:KnitStart() end

function PlayerPreviewController:KnitInit() end

return PlayerPreviewController
