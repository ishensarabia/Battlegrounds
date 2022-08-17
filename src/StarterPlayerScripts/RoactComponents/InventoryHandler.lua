local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Janitor = require(Packages.Janitor) 

local InventoryHandler = Roact.Component:extend("InventoryHandler")
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.RoactComponents
--Assets
local InventoryIcons = require(game.ReplicatedStorage.Source.Assets.Icons.InventoryIcons)
--Components
local InventoryButton = require(RoactComponents.InventoryButton)
local InventoryFrame = require(RoactComponents.InventoryFrame)
--Constants
local FLIPPER_SPRING_RETRACT = Flipper.Spring.new(0, {
	frequency = 4,
	dampingRatio = 0.75,
})
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})



function InventoryHandler:init()
		--Flipper motors
		self.flipperPositionGroupMotor = Flipper.GroupMotor.new(
			{
				positionAndSize = 0;
				buttonsFrame = 0;
			})
		--Flipper bindings
		local positionAndSizeMotorBinding, setPositionAndSizeMotorBinding = Roact.createBinding(self.flipperPositionGroupMotor:getValue().positionAndSize)
		local buttonsFrameMotorBinding, setButtonsFramePositionMotorBinding = Roact.createBinding(self.flipperPositionGroupMotor:getValue().positionAndSize)

		--Flipper connections
		self.flipperPositionMotorsBindings = 
		{
			positionAndSize = positionAndSizeMotorBinding;
			buttonsFrame = buttonsFrameMotorBinding
		}
		self.flipperPositionGroupMotor._motors.positionAndSize:onStep(setPositionAndSizeMotorBinding)
		self.flipperPositionGroupMotor._motors.buttonsFrame:onStep(setButtonsFramePositionMotorBinding)
		--Roact connections
		self.janitor = Janitor.new()
		--Set states
		self:setState({
			currentScreen = "HOME";
			inventoryType = "";
		})
end

function InventoryHandler:render()
	if (self.state.currentScreen == "HOME") then
		return Roact.createElement("Frame", {
			ZIndex = 2,
			BackgroundTransparency = 1,
			Size = self.props.size,
		}, {
			--Buttons
			ButtonsFrame = Roact.createElement(
				"Frame",
				{
					Position = self.flipperPositionMotorsBindings.buttonsFrame:map(function(value)
						return self.props.buttonsFramePosition:Lerp(UDim2.fromScale(1,0), value)
					end),
					
					Size = self.props.buttonsFrameSize,
					BackgroundTransparency = 1,
				},
				{
					ItemsInventoryButton = Roact.createElement(InventoryButton, {
						position = UDim2.fromScale(0.191, 0.685),
						size = UDim2.fromScale(0.234, 0.279),
						typeOfInventory = "ItemsInventory",
						callback = function() 
							self:setState({
								currentScreen = "INVENTORY",
								inventoryType = "ITEMS"
							})
							self.flipperPositionGroupMotor:setGoal({buttonsFrame = FLIPPER_SPRING_EXPAND})
						end,
					}),
					SuperPowersInventoryButton = Roact.createElement(InventoryButton, {
						position = UDim2.fromScale(0.7, 0.34),
						size = UDim2.fromScale(0.234, 0.279),
						typeOfInventory = "SuperPowersInventory",
						callback = function() 
							self:setState({
								currentScreen = "INVENTORY",
								inventoryType = "SUPER-POWERS"
							})
							self.flipperPositionGroupMotor:setGoal({buttonsFrame = FLIPPER_SPRING_EXPAND})
						end,
					}),
				}
			),
		})	
	elseif (self.state.currentScreen == "INVENTORY") then
		return Roact.createElement("Frame", {
			ZIndex = 2,
			BackgroundTransparency = 1,
			Size = self.props.size,
		}, {
			--Buttons
			ButtonsFrame = Roact.createElement(
				"Frame",
				{
					Position = self.flipperPositionMotorsBindings.buttonsFrame:map(function(value)
						return self.props.buttonsFramePosition:Lerp(UDim2.fromScale(1,0), value)
					end),
					
					Size = self.props.buttonsFrameSize,
					BackgroundTransparency = 1,
				},
				{
					ItemsInventoryButton = Roact.createElement(InventoryButton, {
						position = UDim2.fromScale(0.191, 0.685),
						size = UDim2.fromScale(0.234, 0.279),
						typeOfInventory = "ItemsInventory",
						callback = function() 
							self.state:setState({
								currentScreen = "INVENTORY",
								inventoryType = "ITEMS"
							})
							self.flipperPositionGroupMotor:setGoal({buttonsFrame = FLIPPER_SPRING_EXPAND})
						end,
					}),
					SuperPowersInventoryButton = Roact.createElement(InventoryButton, {
						position = UDim2.fromScale(0.7, 0.34),
						size = UDim2.fromScale(0.234, 0.279),
						typeOfInventory = "SuperPowersInventory",
						callback = function()
							self.state:setState({
								currentScreen = "INVENTORY",
								inventoryType = "SUPER-POWERS"
							})
							self.flipperPositionGroupMotor:setGoal({buttonsFrame = FLIPPER_SPRING_EXPAND})
						end,
					}),
				}
			),
			--Frames
			InventoryFrame = Roact.createElement(
				InventoryFrame,
				{
					position =  UDim2.fromScale(0.126, 0.0637),
					size = UDim2.fromScale(0.793, 0.837),
					inventoryType = self.state.inventoryType
					
				}
			)
		})		
	end
end

return InventoryHandler
