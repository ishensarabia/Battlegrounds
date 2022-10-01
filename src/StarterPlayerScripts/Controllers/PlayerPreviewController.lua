local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerPreviewController = Knit.CreateController({ Name = "PlayerPreviewController" })

function PlayerPreviewController:spawnCharacterMenu()
	local playerCharacter = Players.LocalPlayer.PlayerGui
		:WaitForChild("MainMenu").playerPreview.viewportFrame.WorldModel
		:WaitForChild("Dummy")
	local idleAnimation = Instance.new("Animation")
	idleAnimation.AnimationId = "rbxassetid://782841498"
	idleAnimation.Name = "Idle"
	local idleAnimationTrack = playerCharacter.Humanoid.Animator:LoadAnimation(idleAnimation)
	idleAnimationTrack:Play()
    local clonedRocketLauncher = workspace.RocketLauncher:Clone()
    -- clonedRocketLauncher.Parent = playerCharacter.Parent
    playerCharacter.Humanoid:EquipTool(clonedRocketLauncher)
end

function PlayerPreviewController:KnitStart() end

function PlayerPreviewController:KnitInit() end

return PlayerPreviewController
