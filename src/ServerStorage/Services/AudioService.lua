--Service
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Sounds = {
	buttonClick = "rbxassetid://4499400560",
	Dash = "rbxassetid://8653395088",
	Slide = "rbxassetid://9117933230",
}
local AudioService = Knit.CreateService({
	Name = "AudioService",
	Client = {},
})

function AudioService:KnitStart()
	--Init the service
end

function AudioService:PlaySound(player, sound: string, soundProperties : table)
	if not soundProperties then
		soundProperties = {}
		soundProperties.RollOffMode = Enum.RollOffMode.Linear
		soundProperties.RollOffMaxDistance = 50
		soundProperties.RollOffMinDistance = 10
	end
	if Sounds[sound] and not player.Character.HumanoidRootPart:FindFirstChild(sound) then
		local soundToPlay = Instance.new("Sound")
		soundToPlay.SoundId = Sounds[sound]
		soundToPlay.Name = sound
		soundToPlay.RollOffMode = soundProperties.RollOffMode
		soundToPlay.RollOffMaxDistance = soundProperties.RollOffMaxDistance or 50
		soundToPlay.RollOffMinDistance = soundProperties.RollfOffMinDistance or 10
		soundToPlay.Parent = player.Character.HumanoidRootPart
		soundToPlay:Play()
		soundToPlay.Ended:Wait()
		soundToPlay:Destroy()
	end
end

function AudioService.Client:PlaySound(player: Player, sound: string, isServer: boolean, soundProperties : table)
	if isServer then
		return self.Server:PlaySound(player, sound, soundProperties)
	end
	if Sounds[sound] then
		local soundToPlay = Instance.new("Sound")
		soundToPlay.SoundId = Sounds[sound]
		soundToPlay.Parent = player
		soundToPlay:Play()
		soundToPlay.Ended:Wait()
		soundToPlay:Destroy()
	end
end

function AudioService:KnitInit()
	--Start the service
end

return AudioService
