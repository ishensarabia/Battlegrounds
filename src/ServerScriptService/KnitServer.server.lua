--Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)
-- Knit Services
Knit.ComponentsLoaded = false
Knit.AddServicesDeep(ServerStorage.Source.Services)
--Initialize
Knit.Start():andThen(function()
    for key, child in pairs(ServerStorage.Source.Components:GetDescendants()) do
        if (child:IsA('ModuleScript')) then
            require(ServerStorage.Source.Components[child.Name])
        end
    end
    --Components loaded
    Knit.ComponentsLoaded = true
end):catch(warn)    