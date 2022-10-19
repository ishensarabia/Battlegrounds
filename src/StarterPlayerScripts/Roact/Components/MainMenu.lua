local Players = game:GetService("Players")
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
local PlayerPreview = require(RoactComponents.PlayerPreview)
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
		play_button_pos = 0,
		player_preview = 0,
	})
	--Flipper bindings
	local positionMotorBinding, setPositionMotorBinding =
		Roact.createBinding(self.flipperPositionGroupMotor:getValue().position)
	local inventoryPosMotorBinding, setInvPosMotorBinding =
		Roact.createBinding(self.flipperPositionGroupMotor:getValue().position)
	local playPosMotorBinding, setPlayPosMotorBinding =
		Roact.createBinding(self.flipperPositionGroupMotor:getValue().position)
	local player_previewPosMotorBinding, setPlayer_PreviewPosMotorBinding =
		Roact.createBinding(self.flipperPositionGroupMotor:getValue().position)

	--Flipper connections
	self.flipperPositionMotorsBindings = {
		position = positionMotorBinding,
		inventory_pos = inventoryPosMotorBinding,
		play_button_pos = playPosMotorBinding,
		player_preview = player_previewPosMotorBinding,
	}
	self.flipperPositionGroupMotor._motors.position:onStep(setInvPosMotorBinding)
	self.flipperPositionGroupMotor._motors.inventory_pos:onStep(setPositionMotorBinding)
	self.flipperPositionGroupMotor._motors.play_button_pos:onStep(setPlayPosMotorBinding)
	self.flipperPositionGroupMotor._motors.player_preview:onStep(setPlayer_PreviewPosMotorBinding)
	--Roact connections
	self.janitor = Janitor.new()
	--Set states
	self:setState({
		currentScreen = "Menu",
		active = true,
	})
	--Refs
	self.cameraRef = Roact.createRef()
	self.viewportRef = Roact.createRef()
end

function MainMenu:render()
	if self.state.currentScreen == "Menu" then
		return Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
		}, {
			bottomBar = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				Position = self.flipperPositionMotorsBindings.position:map(function(value)
					return self.props.bottomBar.position:Lerp(
						self.props.bottomBar.position - UDim2.fromScale(1.33),
						value
					)
				end),
				Size = UDim2.fromScale(1.19, 1.0384),
			}),

			topBar = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				Position = self.flipperPositionMotorsBindings.position:map(function(value)
					return self.props.topBar.position:Lerp(self.props.topBar.position - UDim2.fromScale(1.33), value)
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
				currency = "BattleCoins",
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
					return self.props.inventory.position:Lerp(
						self.props.inventory.position - UDim2.fromScale(1.33),
						value
					)
				end),
				changeMenuStateCallback = function(_currentScreen)
					self:setState({ currentScreen = _currentScreen })
					self.flipperPositionGroupMotor:setGoal({ play_button_pos = FLIPPER_SPRING_EXPAND, player_preview = FLIPPER_SPRING_EXPAND })
				end,
			}),
			--Play button
			playButton = Roact.createElement(PlayButtonComponent, {
				position = self.flipperPositionMotorsBindings.play_button_pos:map(function(value)
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
					self.flipperPositionGroupMotor:setGoal({
						inventory_pos = FLIPPER_SPRING_EXPAND,
						play_button_pos = FLIPPER_SPRING_EXPAND,
						position = FLIPPER_SPRING_EXPAND,
						player_preview = FLIPPER_SPRING_EXPAND
					})
					Knit.GetController("MenuController"):Play()
				end,
			}),
			--Player preview
			playerPreview = Roact.createElement(PlayerPreview, {
				position = self.flipperPositionMotorsBindings.player_preview:map(function(value)
					return self.props.playerPreview.position:Lerp(
						self.props.playerPreview.position - UDim2.fromScale(1.33),
						value
					)
				end),
				playerHumanoidDescription = self.props.playerPreview.humanoidDescription,
			}),
		})
	end

	if self.state.currentScreen == "Inventory" then
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
				Size = UDim2.fromScale(1.19, 1.0384),
			}),

			topBar = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				Position = self.flipperPositionMotorsBindings.position:map(function(value)
					return self.props.topBar.position:Lerp(self.props.topBar.position - UDim2.fromScale(1.33), value)
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
				currency = "BattleCoins",
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
					return self.props.inventory.position:Lerp(
						self.props.inventory.position - UDim2.fromScale(1.33),
						value
					)
				end),
				changeMenuStateCallback = function(_currentScreen)
					self:setState({ currentScreen = _currentScreen })
					self.flipperPositionGroupMotor:setGoal({ play_button_pos = FLIPPER_SPRING_RETRACT, player_preview = FLIPPER_SPRING_RETRACT})
				end,
			}),
			--Play button
			playButton = Roact.createElement(PlayButtonComponent, {
				position = self.flipperPositionMotorsBindings.play_button_pos:map(function(value)
					return self.props.playButton.position:Lerp(
						self.props.playButton.position - UDim2.fromScale(1.33),
						value
					)
				end),
				size = UDim2.fromScale(0.22, 0.18),
				callback = function() end,
			}),
			--Player preview
			playerPreview = Roact.createElement(PlayerPreview, {
				position = self.flipperPositionMotorsBindings.player_preview:map(function(value)
					return self.props.playerPreview.position:Lerp(
						self.props.playerPreview.position - UDim2.fromScale(1.33),
						value
					)
				end),
				playerHumanoidDescription = self.props.playerPreview.humanoidDescription,
			}),
		})
	end
end

function MainMenu:didMount()
	local CameraController = Knit.GetController("CameraController")
	local currencyService = Knit.GetService("CurrencyService")
	local currentArenaInstance = workspace:WaitForChild("Arena")
	local cutscenePoints = currentArenaInstance.Cutscene
	--Set up main menu cutscene
	workspace.CurrentCamera.CFrame = currentArenaInstance.StartingCamera.CFrame
	CameraController.isInMenu = true
	task.spawn(function()
		while self.state.active do
			CameraController:TransitionBetweenPoints(cutscenePoints)
		end
		warn("Main menu component state active : " .. tostring(self.state.active))
	end)
	--Set up respawn respawn
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			self.flipperPositionGroupMotor:setGoal({
				inventory_pos = FLIPPER_SPRING_RETRACT,
				play_button_pos = FLIPPER_SPRING_RETRACT,
				player_preview = FLIPPER_SPRING_RETRACT,
				position = FLIPPER_SPRING_RETRACT,
			})
		end)
	end)
end

return MainMenu
