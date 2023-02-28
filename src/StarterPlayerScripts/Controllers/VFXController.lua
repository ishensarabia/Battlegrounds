local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local VFXController = Knit.CreateController { Name = "VFXController" }

local VFXAssets = ReplicatedStorage.Assets.VFX

function VFXController:KnitStart()
    
end

function VFXController:PlayVFX(VFXName, VFXData : table)
    local dashRaycastParams = RaycastParams.new()
    dashRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    dashRaycastParams.FilterDescendantsInstances = {VFXData.HRP.Parent}
    for i = 1,10 do
        -- for i = 1, math.random(1,3) do
        --     local sphere
        -- end
    
        local ray = workspace:Raycast(VFXData.HRP.Position, Vector3.new(0,-4,0), dashRaycastParams)
        if ray then
            local dustVFX = VFXAssets.Dust:Clone()
            dustVFX.Parent = VFXData.HRP
            dustVFX.CFrame = VFXData.HRP.CFrame
            dustVFX.Position = ray.Position
            dustVFX.Attachment.Dust.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ray.Instance.Color), ColorSequenceKeypoint.new(1, ray.Instance.Color)}
            dustVFX.Attachment.Dust:Emit(10)
            Debris:AddItem(dustVFX, 2)
            
        end
        task.wait()
    end
end

function VFXController:KnitInit()
    local VFXService = Knit.GetService("VFXService")
    VFXService.SpawnVFX:Connect(function(VFXName, VFXData)
        self:PlayVFX(VFXName, VFXData)
    end)
end


return VFXController
