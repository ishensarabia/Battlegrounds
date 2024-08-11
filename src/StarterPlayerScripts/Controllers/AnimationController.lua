local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Variables
local player: Player = Players.LocalPlayer

local AnimationController = Knit.CreateController({ Name = "AnimationController" })

--Assets
local emotes = require(ReplicatedStorage.Source.Assets.Emotes)

function AnimationController:KnitStart() end

function AnimationController:InitAnimation(character: Model, animationName: string, animationID: string)
	local animationTrack = Instance.new("Animation")
	animationTrack.Name = animationName
	animationTrack.AnimationId = animationID
	animationTrack.Parent = character.Humanoid
	self._animationTracks[animationName] = animationTrack
end

function AnimationController:PlayAnimation(animationName: string, playbackSpeed: number)
	--Format the animation name
	animationName = animationName:gsub(" ", "_")
	animationName = animationName:gsub("-", "_")
	animationName = animationName:gsub("'", "")
	local animationTrack: AnimationTrack = player.Character.Humanoid.Animator:LoadAnimation(self._animationTracks[animationName])
	animationTrack:Play()
	if playbackSpeed then
		animationTrack:AdjustSpeed(playbackSpeed)
	end
	self._loadedAnimationTracks[animationName] = animationTrack
	animationTrack.Ended:Connect(function()
		animationTrack:Destroy()
		self._loadedAnimationTracks[animationName] = nil
	end)
	return animationTrack
end

--Stop animation function -0.165, 0.3, -0.3
function AnimationController:StopAnimation(animationName: string)
	if not self._loadedAnimationTracks[animationName] then
		warn(string.format("Animation %s not found in loaded animations", animationName))
		return
	end
	--Format the animation name
	animationName = animationName:gsub(" ", "_")
	animationName = animationName:gsub("-", "_")
	animationName = animationName:gsub("'", "")
	self._loadedAnimationTracks[animationName]:Stop()
	self._loadedAnimationTracks[animationName]:Destroy()
	self._loadedAnimationTracks[animationName] = nil
end

--Disable tool animation
local NOHANDOUT_ID = 04484494845

local function DisableHandOut(character)
	local Animator = character.Humanoid.Animator
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "http://www.roblox.com/asset/?id=" .. NOHANDOUT_ID

	local ToolNone = Animator:FindFirstChild("toolnone")
	if ToolNone then
		local NewTool = Instance.new("StringValue")
		NewTool.Name = "toolnone"
		Animation.Name = "ToolNoneAnim"
		Animation.Parent = NewTool
		ToolNone:Destroy()
		NewTool.Parent = Animator
	end
end

function AnimationController:KnitInit()
	self._animations = require(ReplicatedStorage.Source.Assets.Animations)
	self._animationTracks = {}
	self._loadedAnimationTracks = {}
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		for animationCategory, animationCategoryTable in self._animations do
			for animationName, animationID in animationCategoryTable do
				self:InitAnimation(character, animationName, animationID)
			end
		end
		for emoteName, emoteTable in emotes do
			self:InitAnimation(character, emoteName, emoteTable.animation)
		end
		DisableHandOut(character)
	end)
end

return AnimationController
