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
local ItemPreviewFrame = require(RoactComponents.ItemPreviewFrame)

local screens = { WEAPON_PREVIEW = "WEAPON_PREVIEW", HOME = "HOME", INVENTORY = "INVENTORY", MENU = "MENU" }
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
	if self.state.currentScreen == screens.HOME then
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
					typeOfInventory = "Weapons",
					callback = function()
						Knit.GetService("DataService"):GetKeyValue("Weapons"):andThen(function(weapons: table)
							self:setState({
								currentScreen = "INVENTORY",
								inventoryType = "WEAPONS",
								items = weapons,
							})
							self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_EXPAND })
							self.props.changeMenuStateCallback(screens.INVENTORY)
						end)
					end,
				}),
				AbilitiesInventoryButton = Roact.createElement(InventoryButton, {
					position = UDim2.fromScale(1.7, 0.64),
					size = UDim2.fromScale(0.234, 0.279),
					typeOfInventory = "Abilities",
					callback = function()
						Knit.GetService("DataService"):GetKeyValue("Abilities"):andThen(function(abilites: table)
							self:setState({
								currentScreen = "INVENTORY",
								inventoryType = "ABILITES",
								items = abilites,
							})
							self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_EXPAND })
							self.props.changeMenuStateCallback(screens.INVENTORY)
						end)
					end,
				}),
			}),
		})
	elseif self.state.currentScreen == screens.INVENTORY then
		return Roact.createElement("Frame", {
			ZIndex = 2,
			BackgroundTransparency = 1,
			Size = self.props.size,
		}, {
			--Inventory Frames
			CurrentInventoryFrame = Roact.createElement(InventoryFrame, {
				position = self.props.inventoryFramePosition,
				size = UDim2.fromScale(0.793, 0.837),
				inventoryType = self.state.inventoryType,
				inventoryItems = self.state.items,
				category = "Firearms",
				closeButtonCallback = function(_callback)
					--Checks for private callback (this is more regarrding to the Flipper's spring)
					if _callback then
						_callback()
					end
					task.delay(0.33, function()
						self:setState({ currentScreen = "HOME" })
						self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_RETRACT })
						self.props.changeMenuStateCallback(screens.MENU)
					end)
				end,
				weaponSelectedCallback = function(_weaponProps : table)
					warn(_weaponProps)
					self:setState({ currentScreen = "WEAPON_PREVIEW" , weaponProps = _weaponProps})
					self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_RETRACT })
				end,
			}),
		})
	elseif self.state.currentScreen == screens.WEAPON_PREVIEW then
		warn("Current screen: weapon preview")
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
			}, {}),
			weaponPreview = Roact.createElement(ItemPreviewFrame, self.state.weaponProps),
			--Inventory Frames
			CurrentInventoryFrame = Roact.createElement(InventoryFrame, {
				position = UDim2.fromScale(0.126, 0.0763),
				size = UDim2.fromScale(0.793, 0.837),
				inventoryType = self.state.inventoryType,
				inventoryItems = self.state.items,
				category = "Firearms",
				closeButtonCallback = function(_callback)
					--Checks for private callback (this is more regarrding to the Flipper's spring)
					if _callback then
						_callback()
					end
					task.delay(0.33, function()
						self:setState({ currentScreen = "INVENTORY" })
						self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_RETRACT })
					end)
				end,
				weaponSelectedCallback = function()
					self:setState({ currentScreen = "WEAPON_PREVIEW" })
					self.flipperPositionGroupMotor:setGoal({ buttonsFrame = FLIPPER_SPRING_RETRACT })
				end,
			}),
		})
	end
end

function Inventory:didMount() end

return Inventory
