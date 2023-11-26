--[=[
	@class ChallengesWidget.story
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChallengesWidget = require(script.Parent)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

return function(target)
	local visible = Fusion.Value(false)

	local ui = ChallengesWidget({
		Parent = target,
		Visible = visible,
	})

	task.defer(function()
		visible:set(true)
	end)

	return function()
		ui:Destroy()
	end
end
