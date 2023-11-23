local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local EmoteIcons = require(ReplicatedStorage.Source.Assets.Icons.EmoteIcons)

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

--Play emote icon
function EmoteService:PlayEmoteIcon(player, emoteName: string)
	warn(player, emoteName)
	--Check if the player actually has equipped the emote
	local emotes = self:GetPlayerEquippedEmotes(player)
	local ownsEmote = false
	--format the emote name to be the same as the emote name in the emotes table
	emoteName = emoteName:gsub(" ", "_")
	emoteName = emoteName:gsub("'", "")
	for index, emoteTable in emotes do
		warn(emoteTable)
		if emoteTable.iconEmote == emoteName then
			ownsEmote = true
		end
	end
	if ownsEmote then
		local emoteIcon = EmoteIcons[emoteName]
		--Create a billboard gui to tween and display the emote icon
		local emoteIconBillboardGui = Instance.new("BillboardGui")
		emoteIconBillboardGui.Parent = player.Character.Head
		emoteIconBillboardGui.Size = UDim2.fromScale(1, 1)
		emoteIconBillboardGui.AlwaysOnTop = true
		emoteIconBillboardGui.Adornee = player.Character.Head
		local emoteIconImageLabel = Instance.new("ImageLabel")
		emoteIconImageLabel.Parent = emoteIconBillboardGui
		--Remove background transparency
		emoteIconImageLabel.BackgroundTransparency = 1
		emoteIconImageLabel.Size = UDim2.fromScale(0.5, 0.5)
		emoteIconImageLabel.Image = emoteIcon.imageID
		emoteIconImageLabel.ImageTransparency = 1
		emoteIconImageLabel.Rotation = 99
		emoteIconImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		emoteIconImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		emoteIconImageLabel.Position = UDim2.fromScale(0.5, 0.5)
		--Tween the emote icon
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local billboardTween = TweenService:Create(emoteIconBillboardGui, tweenInfo, { Size = UDim2.fromScale(2, 2) })
		billboardTween:Play()
		local emoteTween = TweenService:Create(
			emoteIconImageLabel,
			tweenInfo,
			{ ImageTransparency = 0, Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, -0.33), Rotation = 0 }
		)
		emoteTween:Play()
		emoteTween.Completed:Connect(function()
			task.delay(3, function()
				local emoteTween = TweenService:Create(
					emoteIconImageLabel,
					tweenInfo,
					{
						ImageTransparency = 1,
						Size = UDim2.fromScale(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Rotation = 99,
					}
				)
				emoteTween:Play()
				emoteTween.Completed:Connect(function()
					emoteIconBillboardGui:Destroy()
				end)
			end)
		end)
	end
end

--Play emote client
function EmoteService.Client:PlayEmoteIcon(player, emoteName: string)
	return self.Server:PlayEmoteIcon(player, emoteName)
end

--Save emote
function EmoteService:SaveEmote(player, emoteIndex, emoteName, emoteType: string)
	--Check if the emote is owned by the player
	local emote = self:GetPlayerEmotes(player).EmotesOwned[emoteName]
	if emote then
		warn("Emote owned")
		self._dataService:SaveEmote(player, emoteIndex, emoteName, emoteType)
	end
end

--Save emote client
function EmoteService.Client:SaveEmote(player, emoteIndex, emoteName, emoteType: string)
	return self.Server:SaveEmote(player, emoteIndex, emoteName, emoteType)
end

--Remove emote
function EmoteService:RemoveEmote(player, emoteIndex, emoteType: string)
	self._dataService:RemoveEmote(player, emoteIndex, emoteType)
end

--Remove emote client
function EmoteService.Client:RemoveEmote(player, emoteIndex, emoteType: string)
	return self.Server:RemoveEmote(player, emoteIndex, emoteType)
end

function EmoteService:KnitInit() end

return EmoteService
