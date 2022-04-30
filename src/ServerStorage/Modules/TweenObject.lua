local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

local TweenService = game:GetService("TweenService")
local module = {}

function module.TweenBasePart(basePart : BasePart, tweenInfo : TweenInfo, properties : table)
    return Promise.new(function(resolve, reject, onCancel)
        local tween = TweenService:Create(basePart, tweenInfo, properties)

        onCancel(function()
            tween:Cancel()
        end)

        tween.Completed:Connect(resolve)
        tween:Play()
    end)
end

return module