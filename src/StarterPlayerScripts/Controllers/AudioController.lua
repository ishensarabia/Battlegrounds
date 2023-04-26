local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AudioController = Knit.CreateController({
	Name = "AudioController",
})

function AudioController:KnitStart() end

function AudioController:PlaySound(sound: string)
	local soundToPlay = SoundService.FX.UI[sound]
	SoundService:PlayLocalSound(soundToPlay)
end

function AudioController:KnitInit() end

return AudioController
