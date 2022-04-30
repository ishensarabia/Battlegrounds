local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)
--Constants
local COMPONENTS_PATH = game.StarterPlayer.StarterPlayerScripts.Source.Components
Knit.AddControllers(game.StarterPlayer.StarterPlayerScripts.Source.Controllers)
-- Components 
Knit.ComponentsLoaded = false
--Initialize
Knit.Start():andThen(function()
    for key, child in pairs(COMPONENTS_PATH:GetDescendants()) do
        if (child:IsA('ModuleScript')) then
            require(COMPONENTS_PATH[child.Name])
        end
    end
    --Components loaded
    Knit.ComponentsLoaded = true
end):catch(warn)    
