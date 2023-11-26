--[=[
	@class SpringAnimate
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Spring = Fusion.Spring

return function(computed)
	return Spring(computed, 15)
end
