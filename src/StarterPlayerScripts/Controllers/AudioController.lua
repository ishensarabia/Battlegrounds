local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AudioController =
	Knit.CreateController({ Name = "AudioController", Sounds = { click = "rbxassetid://4499400560", equip = "rbxassetid://1334782302" } })

function AudioController:KnitStart() end

function AudioController:PlaySound(sound : string)
	local soundToPlay = Instance.new("Sound")
	soundToPlay.SoundId = self.Sounds[sound]
    SoundService:PlayLocalSound(soundToPlay)
	soundToPlay.Ended:Connect(function(soundId)        
        soundToPlay:Destroy()
    end)
end

function AudioController:KnitInit() end

return AudioController