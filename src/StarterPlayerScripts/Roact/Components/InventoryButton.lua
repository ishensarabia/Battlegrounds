local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

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
		--Create a sub layer frame to be able to tween the frame contents and animate them
		ButtonFrame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = self.binding:map(function(value)
				return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(0.8, 0.8), value)
			end),
			ZIndex = 2,
		}, {
			button = Roact.createElement("ImageButton", {
				Image = InventoryIcons[self.props.typeOfInventory],
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.236, -0.144),
				Size = UDim2.fromScale(0.533, 0.748),
				ZIndex = 2,
				--Events

				[Roact.Event.MouseButton1Down] = function()
					--Play sound
					Knit.GetController("AudioController"):PlaySound("click")
					self.motor:setGoal(Flipper.Spring.new(1, {
						frequency = 5,
						dampingRatio = 1,
					}))
					task.delay(0.163, function()
						self.props.callback(self.props.retractCallback)
						self.motor:setGoal(Flipper.Spring.new(0, {
							frequency = 4,
							dampingRatio = 0.75,
						}))
						self.props.callback()
					end)
				end,
			}),

			buttonImageLabel = Roact.createElement("ImageLabel", {
				Image = "rbxassetid://9963227346",
				ImageColor3 = Color3.fromRGB(102, 102, 102),
				BackgroundColor3 = Color3.fromRGB(102, 102, 102),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(-0.029, 0.302),
				Size = UDim2.fromScale(1.09, 0.698),
			}),

			buttonTitle = Roact.createElement("TextLabel", {
				Text = string.upper(self.props.typeOfInventory),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0.3,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.17, 0.604),
				Size = UDim2.fromScale(0.649, 0.321),
				ZIndex = 2,
			}),
		}),
	})
end

return InventoryButton
