local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Component = require(game.ReplicatedStorage.Packages.Component)

local assets = game.ReplicatedStorage.Assets
--Constants
local TEXTURE_SPEED = 1_000
local TWEEN_INFO = TweenInfo.new(TEXTURE_SPEED, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0)

local AnimatedWeaponSkin = Component.new({
	Tag = "AnimatedWeaponSkin",
})

function AnimatedWeaponSkin:Construct()
	self._janitor = Janitor.new()
	self.constructPrompts = {}
end

function AnimatedWeaponSkin:AnimateWeaponSkin(weaponModel)
    warn("Animating weapon skin")
    --Get weapon parts to apply the skin
    for index, value in weaponModel:GetDescendants() do
        if value:IsA("Texture") then
            local textureTween = TweenService:Create(value, TWEEN_INFO, {
                OffsetStudsU = 30,
                OffsetStudsV = 30,

            })

            self._janitor:Add(textureTween)
            textureTween:Play()
        end
    end
end

function AnimatedWeaponSkin:Start()
    --Clean up the tweens when the tool is unequipped
    self.Instance.Unequipped:Connect(function()
        self._janitor:Cleanup()
    end)
    --Start the animation when the tool is equipped
    self.Instance.Equipped:Connect(function()
        self:AnimateWeaponSkin(self.Instance)
    end)
end

function AnimatedWeaponSkin:Stop()
	warn("AnimatedWeaponSkin stopped")
	self._janitor:Cleanup()
end

return AnimatedWeaponSkin
