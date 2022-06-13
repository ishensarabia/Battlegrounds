local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NPCService = Knit.CreateService {
    Name = "NPCService",
    Client = {},
}

local NPCS = {}

local function GetPosition(folder)
    local data = workspace.NPCs[folder]

    data = data[math.random(#data)]
    local offset = Vector3.new(math.random(-data.size.X / 2, data.size.X / 2), 0, math.random(-data.size.Z /2, data.size.Z / 2))
    return data._CFrame:PointToWorldSpace(offset)
end

function NPCService:KnitStart()
    
end


function NPCService:KnitInit()
    -- for index, folder in ipairs(workspace.NPCs:GetChildren()) do
    --     local data = {}
    --     for index, spawnPart in ipairs(folder:GetChildren()) do
    --         table.insert(data, {["_CFrame"] = spawnPart.CFrame, ['size'] = spawnPart.Size})
    --         spawnPart:Destroy()
    --     end
    --     table.insert(NPCS,{[folder] = data})
    --     folder:SetAttribute("Position", GetPosition(folder))
    -- end
end


return NPCService
