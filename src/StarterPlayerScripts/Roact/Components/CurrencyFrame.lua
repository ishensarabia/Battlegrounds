local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local CurrencyFrame = Roact.Component:extend("CurrencyFrame")
local currencyIcons = {
	BattleCoins = "rbxassetid://10835882861",
	BattleGems = "rbxassetid://10835980573",
}
--Springs
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})

function CurrencyFrame:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
	--Roact binding
	local currencyService = Knit.GetService("CurrencyService")
	warn(self.props.currency)
	currencyService:GetCurrencyValue(self.props.currency):andThen(function(currencyValue)
		self.currencyValue, self.updateCurrencyValue = Roact.createBinding(currencyValue)
	end)
end

function CurrencyFrame:render()
  repeat
    task.wait()
  until self.currencyValue
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = self.props.position,
		Size = self.props.size,
		ZIndex = self.props.zIndex,
	}, {
		icon = Roact.createElement("ImageLabel", {
			Image = currencyIcons[self.props.currency],
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.0888, 0.0581),
			Size = UDim2.fromScale(0.236, 0.859),
		}),

		amountLabel = Roact.createElement("TextLabel", {
			Font = Enum.Font.SourceSansBold,
			Text = self.currencyValue,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextStrokeTransparency = 0.3,
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.328, 0.0756),
			Size = UDim2.fromScale(0.582, 0.834),
		}),

		label = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9963227346",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, -0.0141),
			Size = UDim2.fromScale(1.02, 1.01),
			ZIndex = 0,
		}),
	})
end

function CurrencyFrame:didMount()
	local currencyService = Knit.GetService("CurrencyService")
	--Update bindings
	currencyService.BattleCoinsChanged:Connect(function(newValue)
		self.updateCurrencyValue(newValue)
	end)
end

return CurrencyFrame
