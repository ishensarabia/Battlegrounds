local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Janitor = require(Packages.Janitor)

--The available categories for inventory
local categories = {
	"SCI-FI",
	"MEDIEVAL",
	"FIREARMS",
}
local InventoryFrame = Roact.Component:extend("InventoryFrame")
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Roact components
local ButtonsFrame = require(RoactComponents.ButtonsFrame)
local CloseButton = require(RoactComponents.CloseButton)
local BackButton = require(RoactComponents.BackButton)
local CategoryButton = require(RoactComponents.CategoryButton)
local WeaponFrame = require(RoactComponents.WeaponFrame)
--Assets
local InventoryIcons = require(game.ReplicatedStorage.Source.Assets.Icons.InventoryIcons)
--Components
local InventoryButton = require(RoactComponents.InventoryButton)
--Flipper springs
local FLIPPER_SPRING_RETRACT = Flipper.Spring.new(0, {
	frequency = 4,
	dampingRatio = 0.75,
})
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
function InventoryFrame:init()
	--Flipper motors
	self.flipperGroupMotor = Flipper.GroupMotor.new({
		position = 0,
	})
	--Flipper bindings
	local positionMotorBinding, setPositionMotorBinding =
		Roact.createBinding(self.flipperGroupMotor:getValue().position)
	--Flipper connections
	self.flipperMotorsBindings = {
		position = positionMotorBinding,
	}
	self.flipperGroupMotor._motors.position:onStep(setPositionMotorBinding)
end

function InventoryFrame:_loadInventoryItems() end

function InventoryFrame:_loadCategories() end

function InventoryFrame:render()
	--Retract animation of the inventory back to the menu
	local function retractCallback()
		self.flipperGroupMotor:setGoal({ position = FLIPPER_SPRING_RETRACT })
	end
	--Create category elements
	local categoriesButtons = {}
	--Create layout for the category buttons
	categoriesButtons["Layout"] = Roact.createElement("UIGridLayout", {
		CellPadding = UDim2.fromScale(0, 0.05),
		CellSize = UDim2.fromScale(0.3, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	for index, value in categories do
		categoriesButtons[index] = Roact.createElement(CategoryButton, {
			layoutOrder = index,
			buttonCategory = value,
			callback = function()
				self:setState({
					currentCategory = value,
				})
				warn(self.state.currentCategory)
			end,
		})
	end
	--Create inventory items
	local inventoryItems = {}
	--Create layout for the items frames
	inventoryItems["Layout"] = Roact.createElement("UIGridLayout", {
		CellPadding = UDim2.new(),
		CellSize = UDim2.fromScale(0.12, 0.6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for itemName, itemProps in self.props.inventoryItems do
		inventoryItems[itemName] = Roact.createElement(WeaponFrame, {
			itemName = itemName,
			itemType = self.props.inventoryType,
			itemCategory = self.props.category,
			selectWeapon = self.props.weaponSelectedCallback
		})
	end

	--Initial motor expansion to animate the inventory coming on
	self.flipperGroupMotor:setGoal({ position = FLIPPER_SPRING_EXPAND })
	--Render inventory
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		title = Roact.createElement("TextLabel", {
			RichText = true,
			Font = Enum.Font.GothamBold,
			Text = self.props.inventoryType,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextStrokeTransparency = 0.3,
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.46, 0.00407),
			Size = UDim2.fromScale(0.142, 0.0759),
		}),

		itemsFrame = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.027, 0.123),
			Size = UDim2.fromScale(0.969, 0.653),
		}, {
			Roact.createFragment(inventoryItems),
		}),

		backButton = Roact.createElement(BackButton, {
			position = UDim2.fromScale(0.0938, 0.0174),
			size = UDim2.fromScale(0.075, 0.115),
			callback = self.props.closeButtonCallback,
			retractCallback = retractCallback,
		}, {
			inventoryButton = Roact.createElement("ImageButton", {
				Image = "rbxassetid://9963227346",
				ImageColor3 = Color3.fromRGB(102, 102, 102),
				ScaleType = Enum.ScaleType.Tile,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),

			title = Roact.createElement("TextLabel", {
				Text = "<",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0.3,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.327, 0.0116),
				Size = UDim2.fromScale(0.268, 0.947),
			}),
		}),

		categoryButtonsFrame = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.0562, 0.9),
			Size = UDim2.fromScale(0.333, 0.0809),
		}, {
			Roact.createFragment(categoriesButtons),
		}),
	})
end

return InventoryFrame
