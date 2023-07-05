local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Widgets
local WeaponCustomWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponCustomWidget)

local PlayerPreviewController = Knit.CreateController({ Name = "PlayerPreviewController" })

local playerCharacter
local weaponEquipped


function PlayerPreviewController:SpawnWeaponInCharacterMenu()
	if weaponEquipped then
		weaponEquipped:Destroy()
	end
	local DataService = Knit.GetService("DataService")
	playerCharacter = Players.LocalPlayer.PlayerGui
		:WaitForChild("MainMenuGui").CharacterCanvas.ViewportFrame.WorldModel
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
	--Get equipped weapon
	DataService:GetKeyValue("Loadout"):andThen(function(loadout : table)
		if loadout.WeaponEquipped then
			weaponEquipped = ReplicatedStorage.Weapons[loadout.WeaponEquipped]:Clone()
			WeaponCustomWidget:ApplySavedCustomization(loadout.WeaponEquipped, weaponEquipped:FindFirstChildOfClass("Model"))
			weaponEquipped.Parent = playerCharacter.Parent
			weaponEquipped:FindFirstChildWhichIsA("Model", true).PrimaryPart.CFrame = playerCharacter.PrimaryPart.CFrame
			--Weld
			local weld = Instance.new("Weld")
			weld.Parent = weaponEquipped.Handle
			weld.C0 = playerCharacter.RightHand.RightGripAttachment.CFrame
			weld.C1 = CFrame.new(
				weaponEquipped.GripPos.x,
				weaponEquipped.GripPos.y,
				weaponEquipped.GripPos.z,
				weaponEquipped.GripRight.x,
				weaponEquipped.GripUp.x,
				-weaponEquipped.GripForward.x,
				weaponEquipped.GripRight.y,
				weaponEquipped.GripUp.y,
				-weaponEquipped.GripForward.y,
				weaponEquipped.GripRight.z,
				weaponEquipped.GripUp.z,
				-weaponEquipped.GripForward.z
			)
			weld.Part0 = playerCharacter.RightHand
			weld.Part1 = weaponEquipped.Handle
		
		
			--Animate the selected weapon
			local IKController = Instance.new("IKControl")
			IKController.Parent = playerCharacter.Humanoid
			IKController.ChainRoot = playerCharacter.LeftUpperArm
			IKController.EndEffector = playerCharacter.LeftHand
			IKController.Target = weaponEquipped.Handle.SecondHandleAttachment
		end
	end)
end


function PlayerPreviewController:KnitStart() end

function PlayerPreviewController:KnitInit() end

return PlayerPreviewController
