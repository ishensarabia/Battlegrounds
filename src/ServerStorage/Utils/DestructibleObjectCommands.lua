local module = {}
local CollectionService = game:GetService("CollectionService")

function module.SetUpParts(model : Model)
    CollectionService:AddTag(model,'DestructibleObject')
    for index, child in pairs(model:GetDescendants()) do
        if (child:IsA('BasePart')) then
            child:SetAttribute('PartIndex',index)
        end
    end
end

return module