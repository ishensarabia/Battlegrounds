local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

local TweenService = game:GetService("TweenService")
local module = {}

function module.TweenBasePart(basePart : BasePart, tweenInfo : TweenInfo, properties : table, shouldCollide : boolean)
    return Promise.new(function(resolve, reject, onCancel)
        basePart.CanCollide = shouldCollide
        local tween = TweenService:Create(basePart, tweenInfo, properties)
        tween:Play()

        onCancel(function()
            basePart.CanCollide = not shouldCollide
            tween:Cancel()
        end)

        tween.Completed:Connect(resolve)
    end)
end

function module.TweenCamera(camera : Camera, tweenInfo : TweenInfo, properties : table)
    return Promise.new(function(resolve, reject, onCancel)
        local tween = TweenService:Create(camera, tweenInfo, properties)
        tween:Play()

        onCancel(function()
            tween:Cancel()
        end)

        tween.Completed:Connect(resolve)
    end)
end

return module