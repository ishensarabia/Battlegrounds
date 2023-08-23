local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local EmoteService = Knit.CreateService({
	Name = "EmoteService",
	Client = {},
})

function EmoteService:KnitStart()
	--Initialize the data service
	self._dataService = Knit.GetService("DataService")
end

function EmoteService:GetPlayerEmotes(player)
	return self._dataService:GetKeyValue(player, "Emotes")
end

--Get equipped emotes from player
function EmoteService:GetPlayerEquippedEmotes(player)
	local emotes = self:GetPlayerEmotes(player)
	if emotes then
		return emotes.EmotesEquipped
	end
end

--Save emote
function EmoteService:SaveEmote(player, emoteIndex, emoteName)
	self._dataService:SaveEmote(player, emoteIndex, emoteName)
end

--Save emote client
function EmoteService.Client:SaveEmote(player, emoteIndex, emoteName)
	return self.Server:SaveEmote(player, emoteIndex, emoteName)
end

--Remove emote
function EmoteService:RemoveEmote(player, emoteIndex)
	self._dataService:RemoveEmote(player, emoteIndex)
end

--Remove emote client
function EmoteService.Client:RemoveEmote(player, emoteIndex)
	return self.Server:RemoveEmote(player, emoteIndex)
end

function EmoteService:KnitInit() end

return EmoteService
