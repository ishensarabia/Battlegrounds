local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local player = game.Players.LocalPlayer
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
--Main
local EmoteController = Knit.CreateController({ Name = "EmoteController" })
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)

function EmoteController:KnitStart()
	--Services
end

function EmoteController:GetPlayerEmotes()
	self._dataService = Knit.GetService("DataService")
	return self._dataService:GetEmotes(player):andThen(function(emotes)
		return emotes.EmotesOwned
	end)
end

function EmoteController:GetPlayerEquippedEmotes()
	self._dataService = Knit.GetService("DataService")
	return self._dataService:GetEmotes(player):andThen(function(emotes)
		if emotes then
			return emotes.EmotesEquipped
		end
	end)
end

function EmoteController:DisplayEmotePreview(emoteName: string, viewportFrame: ViewportFrame)
	--Set up player preview
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local playerCharacter = ReplicatedStorage.Assets.Models.Dummy:Clone()
	playerCharacter.Parent = workspace
	local playerDesc
	local success, errorMessage = pcall(function()
		playerDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if playerDesc and success then
		playerCharacter:WaitForChild("Humanoid"):ApplyDescription(playerDesc)
	end
	playerCharacter.Parent = worldModel
	worldModel.PrimaryPart = playerCharacter.HumanoidRootPart
	local viewportCamera = Instance.new("Camera")
	viewportCamera.Parent = viewportFrame
    local emoteViewportModel = ViewportModel.new(viewportFrame, viewportCamera)
    emoteViewportModel:SetModel(worldModel)
    
    local orientation = CFrame.fromEulerAnglesYXZ(math.rad(0), 85, 0)
    local cf, size = worldModel:GetBoundingBox()
    local distance = emoteViewportModel:GetFitDistance(cf.Position)
    viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
    viewportFrame.CurrentCamera = viewportCamera

    --Play emote
    local idleAnimation = Instance.new("Animation")
	idleAnimation.AnimationId = Emotes[emoteName].animation
	idleAnimation.Name = Emotes[emoteName].name
	local idleAnimationTrack = playerCharacter.Humanoid.Animator:LoadAnimation(idleAnimation)
	idleAnimationTrack:Play()
end

function EmoteController:KnitInit() end

return EmoteController
