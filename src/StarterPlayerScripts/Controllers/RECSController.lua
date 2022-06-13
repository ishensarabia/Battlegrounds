local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = game:GetService("ReplicatedFirst").Configurations
local Knit = require(ReplicatedStorage.Packages.Knit)

local RECS = require(ReplicatedStorage.Source.Systems.Core.RECS)
local RECSController = Knit.CreateController { Name = "RECSController" }

local recsCore = RECS.Core.new({})

function RECSController:KnitStart()
    recsCore:registerSystemsInInstance(ReplicatedStorage.Source.Systems.RECS)
    recsCore:registerSteppers(require(Config.Steppers))
    recsCore:start()
end


function RECSController:KnitInit()
    
end


return RECSController
