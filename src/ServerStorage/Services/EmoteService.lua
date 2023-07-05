local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local EmoteService = Knit.CreateService({
	Name = "EmoteService",
	Client = {},
})

function EmoteService:KnitStart()
	--Initialize the data service
	self._dataService = Knit.GetService("StoreService")
end

function EmoteService:GetPlayerEmotes(player)
	return self._dataService:GetKeyValue(player, "Emotes")
end



function EmoteService:KnitInit() end

return EmoteService
