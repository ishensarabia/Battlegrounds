local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AnimationController = Knit.CreateController { Name = "AnimationController" }


function AnimationController:KnitStart()
    
end



function AnimationController:InitAnimation(character, animationName : string, animationID : string)
    self._animationTrack.AnimationId = animationID
    self._animationTrack.Parent = character
    self._animationTracks[animationName] = character:WaitForChild("Humanoid").Animator:LoadAnimation(self._animationTrack)
end

function AnimationController:PlayAnimation(animationName : string)
    self._animationTracks[animationName]:Play()
    return self._animationTracks[animationName]
end

function AnimationController:KnitInit()
    self.Animations = require(ReplicatedStorage.Source.Assets.Animations)
    self._animationTrack = Instance.new("Animation")
    self._animationTracks = {}
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        for animationCategory, animationCategoryTable in self.Animations do
            for animationName, animationID in animationCategoryTable do
                warn(animationName, animationID)
                self:InitAnimation(character, animationName, animationID)
            end
        end
    end)
end


return AnimationController
