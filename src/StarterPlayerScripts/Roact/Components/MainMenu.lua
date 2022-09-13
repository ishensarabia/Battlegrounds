local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(Packages.Janitor)
--Assets
local InventoryIcons = require(game.ReplicatedStorage.Source.Assets.Icons.InventoryIcons)
--Components
local RoactCoreComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Core
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
local CurrencyFrameComponent = require(RoactComponents.CurrencyFrame)
local InventoryComponent = require(RoactCoreComponents.Inventory)
local PlayButtonComponent = require(RoactComponents.PlayButton)
--Constants
local FLIPPER_SPRING_RETRACT = Flipper.Spring.new(0, {
	frequency = 4,
	dampingRatio = 0.75,
})
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
--Main!

local MainMenu = Roact.Component:extend("MainMenuHandler")

function MainMenu:init()
	--Flipper motors
	self.flipperPositionGroupMotor = Flipper.GroupMotor.new({
		position = 0,
		inventory_pos = 0,
	})
	--Flipper bindings
	local positionMotorBinding, setPositionMotorBinding = Roact.createBinding(self.flipperPositionGroupMotor:getValue().position)
	local inventoryPosMotorBinding, setInvPosMotorBinding = Roact.createBinding(self.flipperPositionGroupMotor:getValue().position)
	
	--Flipper connections
	self.flipperPositionMotorsBindings = {
		position = positionMotorBinding,
		inventory_pos = inventoryPosMotorBinding
	}
	self.flipperPositionGroupMotor._motors.inventory_pos:onStep(setPositionMotorBinding)
	self.flipperPositionGroupMotor._motors.position:onStep(setInvPosMotorBinding)
	--Roact connections
	self.janitor = Janitor.new()
	--Set states
	self:setState({
		currentScreen = "HOME",
		inventoryType = "",
	})
	self.active = true
end

function MainMenu:render()
	warn(self.flipperPositionMotorsBindings)
	return Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, {
		bottomBar = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			Position = self.flipperPositionMotorsBindings.position:map(function(value)
				return self.props.bottomBar.position:Lerp(
					self.props.bottomBar.position - UDim2.fromScale(1.33),
					value
				)
			end),
			Size = UDim2.fromOffset(1409, 28),
		}),

		topBar = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			Position = self.flipperPositionMotorsBindings.position:map(function(value)
				return self.props.topBar.position:Lerp(
					self.props.topBar.position - UDim2.fromScale(1.33),
					value
				)
			end),
			Size = UDim2.fromScale(1.17, 0.0867),
		}),

		battleCoinsFrame = Roact.createElement(CurrencyFrameComponent, {
			position = self.flipperPositionMotorsBindings.position:map(function(value)
				return self.props.battleCoinsFrame.position:Lerp(
					self.props.battleCoinsFrame.position - UDim2.fromScale(1.33),
					value
				)
			end),
			size = UDim2.fromScale(0.139, 0.0816),
			currency = "battleCoins",
			zIndex = 1,
		}),
		battleGemsFrame = Roact.createElement(CurrencyFrameComponent, {
			position = self.flipperPositionMotorsBindings.position:map(function(value)
				return self.props.battleGemsFrame.position:Lerp(
					self.props.battleGemsFrame.position - UDim2.fromScale(1.33),
					value
				)
			end),
			size = UDim2.fromScale(0.139, 0.0816),
			currency = "battleGems",
			zIndex = 2,
		}),
		--Init inventory component
		inventory = Roact.createElement(InventoryComponent, {
			size = UDim2.fromScale(1, 1),
			buttonsFrameSize = UDim2.fromScale(0.347, 0.504),
			buttonsFramePosition = self.flipperPositionMotorsBindings.inventory_pos:map(function(value)
				return self.props.playButton.position:Lerp(
					self.props.playButton.position - UDim2.fromScale(1.33),
					value
				)
			end),
		}),
		--Play button
		playButton = Roact.createElement(PlayButtonComponent, {
			position = self.flipperPositionMotorsBindings.position:map(function(value)
				return self.props.playButton.position:Lerp(
					self.props.playButton.position - UDim2.fromScale(1.33),
					value
				)
			end),
			size = UDim2.fromScale(0.22, 0.18),
			callback = function()
				self:setState({
					active = false,
				})
				self.flipperPositionGroupMotor:setGoal({ inventory_pos = FLIPPER_SPRING_EXPAND })
			end,
		}),
	})
end

function MainMenu:didMount()
	self.active = true
	local CameraController = Knit.GetController("CameraController")
	local currentArenaInstance = workspace:WaitForChild("Arena")
	local cutscenePoints = currentArenaInstance.Cutscene
	--Set up main menu cutscene
	workspace.CurrentCamera.CFrame = currentArenaInstance.StartingCamera.CFrame
	task.spawn(function()
		while self.active do
			CameraController:TransitionBetweenPoints(cutscenePoints)
		end
	end)
end

return MainMenu
