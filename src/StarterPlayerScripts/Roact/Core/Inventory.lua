local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Janitor = require(Packages.Janitor)
local Knit = require(ReplicatedStorage.Packages.Knit)
--Main
local Inventory = Roact.Component:extend("Inventory")
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
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

function Inventory:init()
	--Flipper motors
	self.flipperPositionGroupMotor = Flipper.GroupMotor.new({
		positionAndSize = 0,
		buttonsFrame = 0,
	})
	--Flipper bindings
	local positionAndSizeMotorBinding, setPositionAndSizeMotorBinding =
		Roact.createBinding(self.flipperPositionGroupMotor:getValue().positionAndSize)
	local buttonsFrameMotorBinding, setButtonsFramePositionMotorBinding =
		Roact.createBinding(self.flipperPositionGroupMotor:getValue().positionAndSize)

	--Flipper connections
	self.flipperPositionMotorsBindings = {
		positionAndSize = positionAndSizeMotorBinding,
		buttonsFrame = buttonsFrameMotorBinding,
	}
	self.flipperPositionGroupMotor._motors.positionAndSize:onStep(setPositionAndSizeMotorBinding)
	self.flipperPositionGroupMotor._motors.buttonsFrame:onStep(setButtonsFramePositionMotorBinding)
	--Roact connections
	self.janitor = Janitor.new()
	--Set states
	self:setState({
		currentScreen = "HOME",
		inventoryType = "",
	})
end

function Inventory:render()
	if self.state.currentScreen == "HOME" then
		return Roact.createElement("Frame", {
			ZIndex = 2,
			BackgroundTransparency = 1,
			Size = self.props.size,
		}, {
			--Buttons
			ButtonsFrame = Roact.createElement("Frame", {
				Position = self.flipperPositionMotorsBindings.buttonsFrame:map(function(value)
					warn("Changing buttons frame position")
					return self.props.buttonsFramePosition:getValue():Lerp(UDim2.fromScale(1, 0), value)
				end),

				Size = self.props.buttonsFrameSize,
				BackgroundTransparency = 1,
			}, {
				ItemsInventoryButton = Roact.createElement(InventoryButton, {
					position = UDim2.fromScale(1.7, 0.185),
					size = UDim2.fromScale(0.234, 0.279),
					typeOfInventory = "Items",
					callback = function()
						Knit.GetService("DataService"):GetKeyValue("Weapons"):andThen(function(weapons: table)
							self:setState({
								currentScreen = "INVENTORY",
								inventoryType = "ITEMS",
								items = weapons,
							})
							warn("Weapons fetched: ", self.state.items)
						end)
						self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_EXPAND })
						self.props.changeMenuStateCallback("Inventory")
					end,
				}),
				SuperPowersInventoryButton = Roact.createElement(InventoryButton, {
					position = UDim2.fromScale(1.7, 0.34),
					size = UDim2.fromScale(0.234, 0.279),
					typeOfInventory = "SuperPowersInventory",
					callback = function()
						self:setState({
							currentScreen = "INVENTORY",
							inventoryType = "SUPER-POWERS",
						})
						self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_EXPAND })
					end,
				}),
			}),
		})
	elseif self.state.currentScreen == "INVENTORY" then
		return Roact.createElement("Frame", {
			ZIndex = 2,
			BackgroundTransparency = 1,
			Size = self.props.size,
		}, {
			--Buttons
			ButtonsFrame = Roact.createElement("Frame", {
				Position = self.props.buttonsFramePosition,

				Size = self.props.buttonsFrameSize,
				BackgroundTransparency = 1,
			}, {
				ItemsInventoryButton = Roact.createElement(InventoryButton, {
					position = UDim2.fromScale(1.7, 0.185),
					size = UDim2.fromScale(0.234, 0.279),
					typeOfInventory = "Items",
					callback = function()
						self:setState({
							currentScreen = "INVENTORY",
							inventoryType = "ITEMS",
							items = Knit.GetService("DataService"):GetProfileData(Players.LocalPlayer),
						})
						self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_EXPAND })
					end,
				}),
				SuperPowersInventoryButton = Roact.createElement(InventoryButton, {
					position = UDim2.fromScale(1.7, 0.34),
					size = UDim2.fromScale(0.234, 0.279),
					typeOfInventory = "SuperPowersInventory",
					callback = function()
						self:setState({
							currentScreen = "INVENTORY",
							inventoryType = "SUPER-POWERS",
							items = Knit.GetService("DataService"):GetProfileData(Players.LocalPlayer),
						})
						warn(self.state.items)
						self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_EXPAND })
					end,
				}),
			}),
			--Inventory Frames
			Frame = Roact.createElement(InventoryFrame, {
				position = UDim2.fromScale(0.126, 0.0637),
				size = UDim2.fromScale(0.793, 0.837),
				inventoryType = self.state.inventoryType,
				closeButtonCallback = function(_callback)
					if _callback then
						_callback()
					end
					task.delay(0.33, function()
						self:setState({ currentScreen = "HOME" })
						self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_RETRACT })
						self.props.changeMenuStateCallback("Menu")
					end)
				end,
			}),
		})
	end
end

function Inventory:didMount() end

return Inventory
