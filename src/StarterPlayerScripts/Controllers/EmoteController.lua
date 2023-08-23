local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local player = game.Players.LocalPlayer
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
--Main
local EmoteController = Knit.CreateController({ Name = "EmoteController" })
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)
--Widgets
local EmoteWheelWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.EmoteWheelWidget)
--Variables
local emoteAnimationTrack

function EmoteController:KnitStart()
	--Services

	ContextActionService:BindAction("OpenEmoteWheel", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			if not EmoteWheelWidget.isOpen then
				if not EmoteWheelWidget.isInitialized then
					EmoteWheelWidget:Initialize()
				end
				EmoteWheelWidget:Open()
			else
				EmoteWheelWidget:Close()
			end
		end
	end, true, Enum.KeyCode.T)
end

function EmoteController:GetPlayerEmotes()
	self._dataService = Knit.GetService("DataService")
	return self._dataService:GetEmotes(player):andThen(function(emotes)
		return emotes
	end)
end

function EmoteController:DisplayEmotePreview(emoteName: string, viewportFrame: ViewportFrame, useViewport: boolean)
	--Set up player preview
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local playerCharacter = ReplicatedStorage.Assets.Models.Dummy:Clone()
	playerCharacter.Parent = workspace
	local emoteAnimation = Instance.new("Animation")
	--Play emote
	--format the emote name to be the same as the emote name in the emotes table
	emoteName = emoteName:gsub(" ", "_")
	emoteAnimation.AnimationId = Emotes[emoteName].animation
	emoteAnimation.Name = Emotes[emoteName].name
	local emoteAnimationTrack = playerCharacter.Humanoid.Animator:LoadAnimation(emoteAnimation)
	local playerDesc
	local success, errorMessage = pcall(function()
		playerDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if playerDesc and success then
		playerCharacter:WaitForChild("Humanoid"):ApplyDescription(playerDesc)
	end
	playerCharacter.Parent = worldModel
	worldModel.PrimaryPart = playerCharacter.HumanoidRootPart
	if useViewport then
		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = viewportFrame
		local emoteViewportModel = ViewportModel.new(viewportFrame, viewportCamera)
		emoteViewportModel:SetModel(worldModel)
	
		local orientation = CFrame.fromEulerAnglesYXZ(math.rad(0), 85, 0)
		local cf, size = worldModel:GetBoundingBox()
		local distance = emoteViewportModel:GetFitDistance(cf.Position)
		viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
		viewportFrame.CurrentCamera = viewportCamera
	end

	emoteAnimationTrack:Play()

	return worldModel
end

--Play emote
function EmoteController:PlayEmote(emoteName: string)
	local playerCharacter = player.Character
	--Check if the player character exists and is alive if not play it in the preview
	if playerCharacter and playerCharacter.Humanoid.Health > 0 then
		--Make sure the emote isn't playing already
		if playerCharacter:GetAttribute("PlayingEmote") == emoteName then
			return
		elseif playerCharacter:GetAttribute("PlayingEmote") then
			self:StopEmote(playerCharacter:GetAttribute("PlayingEmote"))
		end
		local emote = Knit.GetController("AnimationController"):PlayAnimation(emoteName)
		--Check if the player moves while playing the emote and stop it
		local playerPosition = playerCharacter.HumanoidRootPart.Position
		local connection
		--set attribute
		playerCharacter:SetAttribute("PlayingEmote", emoteName)
		connection = RunService.Stepped:Connect(function(time, deltaTime)
			if (playerCharacter.HumanoidRootPart.Position - playerPosition).Magnitude > 2 then
				emote:Stop()
				connection:Disconnect()
				playerCharacter:SetAttribute("PlayingEmote", nil)
			end
		end)
	else --Play it in the preview character
		local playerPreviewCharacter =
			player.PlayerGui.MainMenuGui.CharacterCanvas.ViewportFrame.WorldModel:FindFirstChild("Dummy")
		--Make sure the emote isn't playing already
		if playerPreviewCharacter:GetAttribute("PlayingEmote") == emoteName then
			return
		elseif playerPreviewCharacter:GetAttribute("PlayingEmote") then
			emoteAnimationTrack:Stop()
		end
		local emoteAnimation = Instance.new("Animation")
		emoteAnimation.AnimationId = Emotes[emoteName].animation
		emoteAnimationTrack = playerPreviewCharacter.Humanoid.Animator:LoadAnimation(emoteAnimation)
		emoteAnimationTrack:Play()
		task.delay(emoteAnimationTrack.Length * 2, function()
			emoteAnimationTrack:Stop()
		end)
		playerPreviewCharacter:SetAttribute("PlayingEmote", emoteName)
		emoteAnimationTrack.Stopped:Connect(function()
			emoteAnimationTrack:Destroy()
			playerPreviewCharacter:SetAttribute("PlayingEmote", nil)
		end)
	end
end

--Stop emote
function EmoteController:StopEmote(emoteName: string)
	local playerCharacter = player.Character
	if playerCharacter then
		Knit.GetController("AnimationController"):StopAnimation(emoteName)
	end
end

--TODO: add play emote funciton

function EmoteController:KnitInit() end

return EmoteController
