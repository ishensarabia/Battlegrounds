local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local SkinsButton = Roact.Component:extend("SkinsButton")
--Springs
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
function SkinsButton:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function SkinsButton:render()
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = self.props.position,
		Size = self.props.size,
	}, {
		ButtonFrame = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0),
			Size = self.binding:map(function(value)
				return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(0.8, 0.8), value)
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
						--Retract the spring to animate the bounce back
						self.motor:setGoal(Flipper.Spring.new(0, {
							frequency = 4,
							dampingRatio = 0.75,
						}))
						-- self.props.callback(self.props.retractCallback)
					end)
				end,
			}),

			title = Roact.createElement("TextLabel", {
				Text = "SKINS",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0.3,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.143, 0.138),
				Size = UDim2.fromScale(0.721, 0.293),
				ZIndex = 2,
			}),

			icon = Roact.createElement("ImageButton", {
				Image = "rbxassetid://9977687470",
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.274, 0.422),
				Size = UDim2.fromScale(0.432, 0.758),
				ZIndex = 2,
				[Roact.Event.MouseButton1Down] = function()
					--Play the sound
					Knit.GetController("AudioController"):PlaySound("click")
					self.motor:setGoal(Flipper.Spring.new(1, {
						frequency = 5,
						dampingRatio = 1,
					}))
					task.delay(0.163, function()
						--Retract the spring to animate the bounce back
						self.motor:setGoal(Flipper.Spring.new(0, {
							frequency = 4,
							dampingRatio = 0.75,
						}))
						-- self.props.callback(self.props.retractCallback)
					end)
				end,
			}),
		}),
	})
end

return SkinsButton
