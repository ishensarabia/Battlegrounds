local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local BackButton = Roact.Component:extend("BackButton")
--Springs
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
function BackButton:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function BackButton:render()
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = self.props.position,
		Size = self.binding:map(function(value)
			return self.props.size:Lerp(UDim2.fromScale(0.053, 0.096), value)
		end),
	}, {
		labelIcon = Roact.createElement("ImageButton", {
			Image = "rbxassetid://9963227346",
			ImageColor3 = Color3.fromRGB(102, 102, 102),
			ScaleType = Enum.ScaleType.Tile,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),

			[Roact.Event.MouseButton1Down] = function()
				--Play the sound
				Knit.GetController("AudioController"):PlaySound("click")
				self.motor:setGoal(Flipper.Spring.new(1, {
					frequency = 5,
					dampingRatio = 1,
				}))
				task.delay(0.163, function()
					warn("Retract")
					self.motor:setGoal(Flipper.Spring.new(0,{
						frequency = 5,
						dampingRatio = 1
					}))
					self.props.callback(self.props.retractCallback)
				end)
			end,
		}),

		title = Roact.createElement("TextLabel", {
			Text = "<",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextStrokeTransparency = 0.3,
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.327, 0.0116),
			Size = UDim2.fromScale(0.268, 0.947),
			ZIndex = 2
		}),
	})
end

return BackButton
