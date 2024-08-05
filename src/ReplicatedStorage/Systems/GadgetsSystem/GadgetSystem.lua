--Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--Dependencies
local Libraries: Folder = ReplicatedStorage.Source.Systems:WaitForChild("Libraries")
local GadgetTypesFolder: Folder = ReplicatedStorage.Source.Systems.GadgetsSystem.GadgetTypes
local SpringService: ModuleScript = require(Libraries:WaitForChild("SpringService"))
local ShoulderCamera: ModuleScript = require(Libraries.ShoulderCamera)
ShoulderCamera.SpringService = SpringService

local GADGET_TYPES_DICTIONARY: table = {}

--Constants
local GADGET_TAG = "Gadget"

do
	local function onNewGadgetType(gadgetType: ModuleScript)
		if not gadgetType:IsA("ModuleScript") then
			warn("Gadget type not found: ", gadgetType)
			return
		end

		local gadgetName: string = gadgetType.Name
		xpcall(function()
			coroutine.wrap(function()
				local gadgetTypeModule: ModuleScript = require(gadgetType)
				assert(
					typeof(gadgetTypeModule) == "table",
					string.format("Gadget type %s must return a table", gadgetType:GetFullName())
				)
				GADGET_TYPES_DICTIONARY[gadgetName] = gadgetTypeModule
			end)()
		end, function(err)
			warn("Error loading gadget type: ", gadgetName, err)
			warn(debug.traceback())
		end)
	end

	for _, gadgetType in (GadgetTypesFolder:GetChildren()) do
		onNewGadgetType(gadgetType)
	end
	GadgetTypesFolder.ChildAdded:Connect(onNewGadgetType)
end

local GadgetSystem = {}

GadgetSystem._registeredGadgets = {}
GadgetSystem._connections = {}

function GadgetSystem.setup()
	GadgetSystem._connections.gadgetAdded = CollectionService:GetInstanceAddedSignal(GADGET_TAG)
		:Connect(function(gadgetInstance)
			GadgetSystem.createGadgetForInstance(gadgetInstance)
		end)
	GadgetSystem._connections.gadgetRemoved = CollectionService:GetInstanceRemovedSignal(GADGET_TAG)
		:Connect(function(gadgetInstance)
			local gadget = GadgetSystem._registeredGadgets[gadgetInstance]
			if gadget then
				GadgetSystem._janitor:Remove(gadget)
				GadgetSystem._registeredGadgets[gadgetInstance] = nil
			end
		end)

	for _, gadgetInstance in (CollectionService:GetTagged(GADGET_TAG)) do
        warn("GadgetSystem.setup: ", gadgetInstance)
		GadgetSystem.createGadgetForInstance(gadgetInstance)
	end
end

function GadgetSystem.setGadgetEquipped(gadgetInstance: Instance, isEquipped: boolean)
    -- local gadget = GadgetSystem.getGadgetFromInstance(gadgetInstance)
    -- if not gadget then
    --     warn("GadgetSystem.setGadgetEquipped: Gadget not found for instance ", gadgetInstance:GetFullName())
    --     return
    -- end

    -- gadget:setEquipped(isEquipped)
end

function GadgetSystem.createGadgetForInstance(gadgetInstance: Instance)
    coroutine.wrap(function()
        local success, err = pcall(function()
            local gadgetTypeName: string = gadgetInstance:GetAttribute("GadgetType")
            if not gadgetTypeName then
                warn("Gadget type not found: ", gadgetTypeName)
                return
            end
            local gadgetType = GADGET_TYPES_DICTIONARY[gadgetTypeName]
            if not gadgetType then
                warn(string.format("Gadget type %s not found for the instance %s", gadgetTypeName, gadgetInstance:GetFullName()))
                return
            end
            local gadget = gadgetType.new(GadgetSystem, gadgetInstance)

            GadgetSystem._registeredGadgets[gadgetInstance] = gadget
        end)
    
        if not success then
            error("Error in coroutine: ", err)
        end
    end)()
end

function GadgetSystem.getGadgetFromInstance(gadgetInstance: Instance)
	if not typeof(gadgetInstance) == "Instance" then
		warn("GadgetSystem.getGadgetFromInstance: Expected Instance, got ", typeof(gadgetInstance))
		return nil
	end

	return GadgetSystem._registeredGadgets[gadgetInstance]
end

function GadgetSystem.onGadgetAdded(gadgetInstance: Instance)
	--Check if gadget already exists
	local gadget = GadgetSystem.getGadgetFromInstance(gadgetInstance)
	if not gadget then
		GadgetSystem.createGadgetForInstance(gadgetInstance)
	end
end



return GadgetSystem
