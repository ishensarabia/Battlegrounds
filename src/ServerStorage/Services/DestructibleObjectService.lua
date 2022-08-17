local Knit = require(game.ReplicatedStorage.Packages.Knit)
--Constants
local LOCAL_COMPONENTS_PATH = game.StarterPlayer.StarterPlayerScripts.Source.Components
local COMPONENTS_PATH = game.ServerStorage.Source.Components
--Class
local DestructibleObject = require(COMPONENTS_PATH['DestructibleObject'])
local DestructibleObjectService = Knit.CreateService {
    Name = "DestructibleObjectService",
    Client = {},
}


function DestructibleObjectService:KnitStart()
    
end

function DestructibleObjectService:SetBuildTime(destructibleObject : Model)
    local currentDestructibleObject = DestructibleObject:FromInstance(destructibleObject)
    currentDestructibleObject:_setBuildTime()
end


function DestructibleObjectService.Client:SetBuildTime(player, destructibleObject : Model)
    return self.Server:SetBuildTime(destructibleObject)
end



function DestructibleObjectService:KnitInit()
    
end


return DestructibleObjectService
