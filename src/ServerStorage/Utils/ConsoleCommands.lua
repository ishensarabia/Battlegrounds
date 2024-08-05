local module = {}
local CollectionService = game:GetService("CollectionService")

function module.SetupDestructibleObjectParts(model : Model)
    CollectionService:AddTag(model,'DestructibleObject')
    for index, child in pairs(model:GetDescendants()) do
        if (child:IsA('BasePart')) then
            child:SetAttribute('PartIndex',index)
        end
    end
end

function module.SetupWeaponParts(model : Model)
    CollectionService:AddTag(model,'Weapon')
    for index, child in pairs(model:GetChildren()) do
        if (child:IsA('BasePart') and child.Name ~= "Lenses") then
            child:SetAttribute('CustomPart',child.Name)
        end
    end
end

return module