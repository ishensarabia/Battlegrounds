--Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local AudioService = Knit.CreateService({
	Name = "AudioService",
	Client = {
		Sounds = {
			buttonClick = "rbxassetid://4499400560",
		},
	},
})

function AudioService:KnitStart()
	--Init the service
end

function AudioService.Client:PlaySound(player : Player,sound: string)
	local soundToPlay = Instance.new("Sound")
	soundToPlay.SoundId = self.Sounds[sound]
	soundToPlay.Parent = player
	soundToPlay:Play()
	soundToPlay.Ended:Wait()
	soundToPlay:Destroy()
end

function AudioService:KnitInit()
	--Start the service
end

return AudioService
