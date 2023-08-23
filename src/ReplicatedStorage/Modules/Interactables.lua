
local CollectionService = game:GetService("CollectionService")

local Interactables = {}
Interactables.TAG_NAME = "Interactable"

--Get the workspace

Interactables.interactableObjects = {}

local function onInteractableAdded(interactableObject)
	if interactableObject:IsA("BasePart") then
		-- Create a new interactable object and save it
		-- The interactable class will take over from here!
		Interactables.interactableObjects[interactableObject] = Interactables.new(interactableObject)
	end
end

local function onInteractableRemoved(interactable)
	if Interactables.interactableObjects[interactable] then
		Interactables.interactableObjects[interactable]:Cleanup()
		Interactables.interactableObjects[interactable] = nil
	end
end

function Interactables.new(interactableObject)
	-- Create a table which will act as our new interactable object.
	local self = {}
	-- Setting the metatable allows the table to access
	-- the SetOpen, OnTouch and Cleanup methods even if we did not
	-- add all of the functions ourself - this is because the
	-- __index metamethod is set in the interactable metatable.
	setmetatable(self, Interactables)

	-- Keep track of some interactable properties of our own
	self.interactable = interactableObject
	self.debounce = false

	-- Initialize a Touched event to call a method of the interactable
	self.touchConn = interactableObject.Touched:Connect(function(...)
		self:OnTouch(...)
	end)

	print("Initialized interactable object: " .. interactableObject:GetFullName())

	return self
end


function Interactables:OnTouch(part)
	if self.debounce then
		return
	end
	local human = part.Parent:FindFirstChild("Humanoid")
	if not human then
		return
	end
end

function Interactables:Initialize()
    local interactableAddedSignal = CollectionService:GetInstanceAddedSignal(Interactables.TAG_NAME)
    local interactableRemovedSignal = CollectionService:GetInstanceRemovedSignal(Interactables.TAG_NAME)

    interactableAddedSignal:Connect(onInteractableAdded)
    interactableRemovedSignal:Connect(onInteractableRemoved)
end

return Interactables
