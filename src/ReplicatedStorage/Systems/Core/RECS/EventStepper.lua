--[[

An event stepper is responsible for stepping systems in a deterministic order in response to some event.

]]

local Janitor = require(game.ReplicatedStorage.Packages.Janitor)

local EventStepper = {}
EventStepper.__index = EventStepper

function EventStepper.new(event, systems)
    local self = setmetatable({
        _cleaner = Janitor.new(),
        _event = event,
        _systems = systems,
    }, EventStepper)

    return self
end

function EventStepper:start()
    self._cleaner.stepConnection = self._event:Connect(function(...)
        for _, system in ipairs(self._systems) do
            system:step(...)
        end
    end)
end

return EventStepper
