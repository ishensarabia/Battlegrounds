local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MovementService = Knit.CreateService({
	Name = "MovementService",
	Client = {},
})

local ACTION_DASH = "DASH"

function MovementService:KnitStart() end

function MovementService:KnitInit()

end

function MovementService:Dash(player)
	--warn(Let them now)
end

return MovementService
