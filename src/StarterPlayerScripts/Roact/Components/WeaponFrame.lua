local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local WeaponsIcons = require(ReplicatedStorage.Source.Assets.Icons.WeaponsIcons)
local WeaponFrame = Roact.Component:extend("WeaponFrame")
--Assets
local ButtonIcons = {
	["SCI-FI"] = "rbxassetid://9964658404",
	MEDIEVAL = "rbxassetid://9964596201",
	FIREARMS = "rbxassetid://9964075868",
}
--Components

function WeaponFrame:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function WeaponFrame:render()
	local weaponName = string.gsub(self.props.weaponID, "_", " ")
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.122, 0.171),
		Size = UDim2.fromScale(0.187, 0.0926),
	}, {
		WeaponFrame = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0),
			Size = self.binding:map(function(value)
				return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(0.8, 0.8), value)
			end),
		}, {
			itemIcon = Roact.createElement("ImageButton", {
				Image = WeaponsIcons[self.props.category][self.props.weaponID],
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.17, 0.139),
				Size = UDim2.fromScale(0.716, 0.728),
				ZIndex = 2,
				--Events
				[Roact.Event.MouseButton1Down] = function()
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
						--select the item
						task.delay(0.163, function()
							self.props.selectWeapon(self.props)
						end)
					end)
				end,
			}),

			itemName = Roact.createElement("TextLabel", {
				Text = weaponName,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0.3,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.17, 0.033),
				Size = UDim2.fromScale(0.761, 0.11),
				ZIndex = 2,
			}),

			inventoryLabel = Roact.createElement("ImageButton", {
				Image = "rbxassetid://11564583911",
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),
		}),
	})
end

return WeaponFrame
