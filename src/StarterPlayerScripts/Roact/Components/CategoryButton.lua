local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local CategoryButton = Roact.Component:extend("CategoryButton")
--Assets
local ButtonIcons = {
	["SCI-FI"] = "rbxassetid://9964658404",
	MEDIEVAL = "rbxassetid://9964596201",
	FIREARMS = "rbxassetid://9964075868",
}
--Components

function CategoryButton:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function CategoryButton:render()
	--Create two frames so tweening worksd
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.122, 0.171),
		Size = UDim2.fromScale(0.187, 0.0926),
	}, {
		ButtonFrame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = self.binding:map(function(value)
				return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(0.8, 0.8), value)
			end),
			ZIndex = 2,
		}, {

			inventoryButton = Roact.createElement("ImageButton", {
				Image = "rbxassetid://9963227346",
				ImageColor3 = Color3.fromRGB(102, 102, 102),
				ScaleType = Enum.ScaleType.Tile,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Rotation = -5,
				Size = UDim2.fromScale(1, 1),
			}),

			title = Roact.createElement("TextLabel", {
				Font = Enum.Font.GothamBold,
				Text = self.props.buttonCategory,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0.3,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.163, 0.0879),
				Rotation = -5,
				Size = UDim2.fromScale(0.721, 0.293),
				ZIndex = 2,
			}),

			iconButton = Roact.createElement("ImageButton", {
				Image = ButtonIcons[self.props.buttonCategory],
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.293, 0.373),
				Size = UDim2.fromScale(0.465, 0.815),
				ZIndex = 2,

				--Events
				[Roact.Event.MouseButton1Down] = function()
					warn("Category button called")
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
						--set the current category in the corresponding context
						self.props.callback()
					end)
				end,
			}),
		}),
	})
end

return CategoryButton
