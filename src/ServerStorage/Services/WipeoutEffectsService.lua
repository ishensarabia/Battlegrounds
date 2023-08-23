local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local WipeoutEffectsService = Knit.CreateService({
	Name = "WipeoutEffectsService",
	Client = {},
})

function WipeoutEffectsService:KnitStart() end

function WipeoutEffectsService:KnitInit()
	
end

return WipeoutEffectsService
