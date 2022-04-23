--Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
-- Knit Services


function Knit.OnComponentsLoaded()
    if (Knit.ComponentsLoaded) then
        return Promise.resolve()
    end
    return Promise.new(function(resolve, _reject, onCancel)
        local heartbeat 
        heartbeat = game:GetService('RunService').Heartbeat:Connect(function()
            if (Knit.ComponentsLoaded) then
                heartbeat:Disconnect()
                resolve()
            end
        end)
        onCancel(function()
            if (heartbeat) then
                heartbeat:Disconnect()
            end
        end)
    end)
end

Knit.ComponentsLoaded = false
Knit.AddServicesDeep(ServerStorage.Source.Services)
--Initialize
Knit.Start():andThen(function()
    require(ServerStorage.Source.Components.Arena)
    require(ServerStorage.Source.Components.Goal)
    Knit.ComponentsLoaded = true
end):catch(warn)    