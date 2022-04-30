local module = {}

function module.SetUpParts(model : Model)
    for index, child in pairs(model:GetChildren()) do
        if (child:IsA('BasePart')) then
            child:SetAttribute('PartIndex',index)
        end
    end
end

return module