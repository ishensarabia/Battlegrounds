local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AnimationController = Knit.CreateController({ Name = "AnimationController" })

function AnimationController:KnitStart() end

function AnimationController:InitAnimation(character, animationName: string, animationID: string)
	local animationTrack = Instance.new("Animation")
	animationTrack.AnimationId = animationID
	animationTrack.Parent = character
	self._animationTracks[animationName] = character:WaitForChild("Humanoid").Animator:LoadAnimation(animationTrack)
end

function AnimationController:PlayAnimation(animationName: string, playbackSpeed: number)
	--Format the animation name
	animationName = animationName:gsub(" ", "_")
	self._animationTracks[animationName]:Play()
	if playbackSpeed then
		self._animationTracks[animationName]:AdjustSpeed(playbackSpeed)
	end
	return self._animationTracks[animationName]
end

--Stop animation function
function AnimationController:StopAnimation(animationName: string)
	--Format the animation name
	animationName = animationName:gsub(" ", "_")
	self._animationTracks[animationName]:Stop()
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
	self.Animations = require(ReplicatedStorage.Source.Assets.Animations)
	self._animationTrack = Instance.new("Animation")
	self._animationTracks = {}
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		for animationCategory, animationCategoryTable in self.Animations do
			for animationName, animationID in animationCategoryTable do
				self:InitAnimation(character, animationName, animationID)
			end
		end
		DisableHandOut(character)
	end)
end

return AnimationController
