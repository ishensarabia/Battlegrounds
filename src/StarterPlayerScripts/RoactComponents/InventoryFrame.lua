local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Janitor = require(Packages.Janitor) 

local InventoryFrame = Roact.Component:extend("InventoryFrame")
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.RoactComponents
--Roact components
local ButtonsFrame = require(RoactComponents.ButtonsFrame)
--Assets
local InventoryIcons = require(game.ReplicatedStorage.Source.Assets.Icons.InventoryIcons)
--Components
local InventoryButton = require(RoactComponents.InventoryButton)
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
function InventoryFrame:init()
		--Flipper motors
		self.flipperGroupMotor = Flipper.GroupMotor.new(
			{
				positionAndSize = 0;
			})
		--Flipper bindings
		local positionAndSizeMotorBinding, setPositionAndSizeMotorBinding = Roact.createBinding(self.flipperGroupMotor:getValue().positionAndSize)
		--Flipper connections
		self.flipperMotorsBindings = 
		{
			positionAndSize = positionAndSizeMotorBinding;
		}
		self.flipperGroupMotor._motors.positionAndSize:onStep(setPositionAndSizeMotorBinding)
end

function InventoryFrame:render()
	self.flipperGroupMotor:setGoal({positionAndSize = FLIPPER_SPRING_EXPAND})
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = self.flipperMotorsBindings.positionAndSize:map(function(value)
			return UDim2.fromScale(0, 0):Lerp(self.props.position, value)
		end),
		Size = self.flipperMotorsBindings.positionAndSize:map(function(value)
			return UDim2.fromScale(0, 0):Lerp(self.props.size, value)
		end)
	  }, {
		inventoryImageLabel = Roact.createElement("ImageLabel", {
		  Image = InventoryIcons.YellowBlueLabel,
		  BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		  BackgroundTransparency = 1,
		  Size = UDim2.fromScale(1.01, 1),
		}),
	  
		titleLabel = Roact.createElement("TextLabel", {
		  Font = Enum.Font.SourceSansBold,
		  Text = self.props.inventoryType,
		  TextColor3 = Color3.fromRGB(255, 255, 255),
		  TextScaled = true,
		  TextSize = 14,
		  TextStrokeTransparency = 0.3,
		  TextWrapped = true,
		  BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		  BackgroundTransparency = 1,
		  Position = UDim2.fromScale(0.297, 0.0252),
		  Size = UDim2.fromScale(0.526, 0.0943),
		  ZIndex = 2
		}),
	  })
end

return InventoryFrame
