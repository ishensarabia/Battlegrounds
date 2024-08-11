--Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
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
GadgetSystem.aimRayCallback = nil

function GadgetSystem.setup()
	if RunService:IsServer() then
		GadgetSystem._connections.gadgetAdded = CollectionService:GetInstanceAddedSignal(GADGET_TAG)
			:Connect(function(gadgetInstance)
				GadgetSystem.createGadgetForInstance(gadgetInstance)
			end)
		GadgetSystem._connections.gadgetRemoved = CollectionService:GetInstanceRemovedSignal(GADGET_TAG)
			:Connect(function(gadgetInstance)
				local gadget = GadgetSystem._registeredGadgets[gadgetInstance]
				if gadget then
					GadgetSystem._registeredGadgets[gadgetInstance] = nil
					gadgetInstance:Destroy()
				end
			end)

		for _, gadgetInstance in (CollectionService:GetTagged(GADGET_TAG)) do
			warn("GadgetSystem.setup: ", gadgetInstance)
			GadgetSystem.createGadgetForInstance(gadgetInstance)
		end
	elseif RunService:IsClient() then
		GadgetSystem.camera = Knit.GetController("WeaponsController"):GetCamera()
		GadgetSystem._connections.gadgetAdded = CollectionService:GetInstanceAddedSignal(GADGET_TAG)
			:Connect(function(gadgetInstance)
				GadgetSystem.onGadgetAdded(gadgetInstance)
			end)
		GadgetSystem._connections.gadgetRemoved = CollectionService:GetInstanceRemovedSignal(GADGET_TAG)
			:Connect(function(gadgetInstance)
				local gadget = GadgetSystem._registeredGadgets[gadgetInstance]
				if gadget then
					GadgetSystem._registeredGadgets[gadgetInstance] = nil
					gadgetInstance:Destroy()
				end
			end)

		for _, gadgetInstance in (CollectionService:GetTagged(GADGET_TAG)) do
			GadgetSystem.onGadgetAdded(gadgetInstance)
		end
	end
end

function GadgetSystem.setGadgetEquipped(gadget: table, isEquipped: boolean)
	if GadgetSystem.camera then
		if isEquipped then
			warn("Enabling camera")
			GadgetSystem.camera:setEnabled(true)
			GadgetSystem.camera:setZoomFactor(gadget.instance:GetAttribute("ZoomFactor") or 1.1)
			GadgetSystem.camera:setHasScope(gadget.instance:GetAttribute("HasScope") or false)
		else
			warn("Disabling camera")
			GadgetSystem.camera:setEnabled(false)
		end
	end
end

function GadgetSystem.createGadgetForInstance(gadgetInstance: Instance)
	coroutine.wrap(function()
		local success, err = pcall(function()
			local gadgetTypeName: string = gadgetInstance:GetAttribute("GadgetType")
			if not gadgetTypeName then
				error("Gadget type not found: " .. tostring(gadgetTypeName))
			end

			local gadgetType = GADGET_TYPES_DICTIONARY[gadgetTypeName]
			if not gadgetType then
				error(
					string.format(
						"Gadget type %s not found for the instance %s",
						gadgetTypeName,
						gadgetInstance:GetFullName()
					)
				)
			end

			local gadget = gadgetType.new(GadgetSystem, gadgetInstance)
			GadgetSystem._registeredGadgets[gadgetInstance] = gadget
		end)

		if not success then
			warn("Error in createGadgetForInstance: " .. tostring(err))
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
