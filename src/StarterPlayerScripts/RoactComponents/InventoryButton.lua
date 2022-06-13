local Packages = game.ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)

local InventoryButton = Roact.Component:extend("InventoryButton")

--Assets
local InventoryIcons = require(game.ReplicatedStorage.Source.Assets.Icons.InventoryIcons)

function InventoryButton:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function InventoryButton:render()
	return Roact.createElement("Frame", {
		ZIndex = 2,
		BackgroundTransparency = 1,
		Size = self.props.size,
		Position = self.props.position,
	}, {
		ButtonFrame = Roact.createElement("Frame", {
			ZIndex = 2,
			BackgroundTransparency = 1,
			Size = self.binding:map(function(value)
				return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(0.8, 0.8), value	)
			end),
		}, {

			Button = Roact.createElement("ImageButton", {
				ZIndex = 2,
				BackgroundTransparency = 1,
				Image = InventoryIcons[self.props.typeOfInventory],
				PressedImage = InventoryIcons.ItemInventory,
				Size = UDim2.fromScale(1, 1),

				--Events

				[Roact.Event.MouseButton1Down] = function()
					self.motor:setGoal(Flipper.Spring.new(1, {
                        frequency = 5,
						dampingRatio = 1,
					}))
				end,

				[Roact.Event.MouseButton1Up] = function()
					self.motor:setGoal(Flipper.Spring.new(0, {
                        frequency = 4,
						dampingRatio = 0.75,
					}))
                    self.props.callback()
				end,
			}),
		}),
	})
end

return InventoryButton
