local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NPCService = Knit.CreateService {
    Name = "NPCService",
    Client = {},
}

local playerCount = 0

--Constants
local NPCS_TO_SPAWN = 5
local PLAYERS_REQUIRED_TO_DEACTIVATE = 2
local npcsSpawned = false

local function CheckNPCs()
    if playerCount < PLAYERS_REQUIRED_TO_DEACTIVATE and not npcsSpawned then
        for i = 1, NPCS_TO_SPAWN do
            local npc = ServerStorage.NPCs.Marine:Clone()
            npc.Parent = workspace.Map.NPCs
            local randomIndex = math.random(1, #workspace.Map.NPCs.Spawns:GetChildren())
            npc:PivotTo(workspace.Map.NPCs.Spawns:GetChildren()[randomIndex].CFrame)
            npcsSpawned = true
        end
    else
        for index, npc in (workspace.Map.NPCs:GetChildren()) do
            if npc:IsA("Model") then
                npc:Destroy()
            end
        end
    end
end

function NPCService:KnitStart()
    -- Players.PlayerAdded:Connect(function()
    --     playerCount = playerCount + 1
    --     CheckNPCs()
    -- end)

    -- Players.PlayerRemoving:Connect(function()
    --     playerCount = playerCount - 1
    --     CheckNPCs()
    -- end)
end

function NPCService:KnitInit()
    
end

return NPCService