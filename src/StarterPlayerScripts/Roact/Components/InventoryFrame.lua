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
		positionAndSize = 0,
	})
	--Flipper bindings
	local positionAndSizeMotorBinding, setPositionAndSizeMotorBinding =
		Roact.createBinding(self.flipperGroupMotor:getValue().positionAndSize)
	--Flipper connections
	self.flipperMotorsBindings = {
		positionAndSize = positionAndSizeMotorBinding,
	}
	self.flipperGroupMotor._motors.positionAndSize:onStep(setPositionAndSizeMotorBinding)
end

function InventoryFrame:_loadInventoryItems() end

function InventoryFrame:_loadCategories() end

function InventoryFrame:render()
	--Retract animation
	local function retractCallback()
		self.flipperGroupMotor:setGoal({ positionAndSize = FLIPPER_SPRING_RETRACT })
	end
	--Create category elements
	local categoriesButtons = {}
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
	warn(self.props.inventoryItems)
	for itemName, itemProps in self.props.inventoryItems do
		--TODO generate weapon frames from the data
		Roact.createElement(WeaponFrame, { weaponID = itemName })
	end

	--Initial motor expansion to animate the inventory coming on
	self.flipperGroupMotor:setGoal({ positionAndSize = FLIPPER_SPRING_EXPAND })
	--Render inventory
	if self.state.enabled == true then
		return Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		  }, {
			title = Roact.createElement("TextLabel", {
			  Text = "<InventoryTypeTitle>",
			  TextColor3 = Color3.fromRGB(255, 255, 255),
			  TextScaled = true,
			  TextSize = 14,
			  TextStrokeTransparency = 0.3,
			  TextWrapped = true,
			  BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			  BackgroundTransparency = 1,
			  Position = UDim2.fromScale(0.511, 0.00407),
			  Size = UDim2.fromScale(0.142, 0.0759),
			}),
		  
			itemsFrame = Roact.createElement("Frame", {
			  BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			  BackgroundTransparency = 1,
			  Position = UDim2.fromScale(0.027, 0.123),
			  Size = UDim2.fromOffset(1306, 321),
			}, {
			  uIGridLayout = Roact.createElement("UIGridLayout", {
				CellPadding = UDim2.new(),
				CellSize = UDim2.fromScale(0.12, 0.6),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			  }),
			}),
		  
			backButton = Roact.createElement("Frame", {
			  BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			  BackgroundTransparency = 1,
			  Position = UDim2.fromScale(0.00564, 0.0194),
			  Size = UDim2.fromScale(0.075, 0.115),
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
			  uIGridLayout1 = Roact.createElement("UIGridLayout", {
				CellPadding = UDim2.fromScale(0, 0.05),
				CellSize = UDim2.fromScale(0.3, 1),
				SortOrder = Enum.SortOrder.LayoutOrder,
			  }),
			}),
		  })
	else
		return Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = self.flipperMotorsBindings.positionAndSize:map(function(value)
				return UDim2.fromScale(0, 0):Lerp(self.props.position, value)
			end),
			Size = self.flipperMotorsBindings.positionAndSize:map(function(value)
				return UDim2.fromScale(0, 0):Lerp(self.props.size, value)
			end),
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
				ZIndex = 2,
			}),

			closeButton = Roact.createElement(CloseButton, {
				position = UDim2.fromScale(0.934, -0.0023),
				size = UDim2.fromScale(0.06, 0.19),
				zindex = 2,
				callback = self.props.closeButtonCallback,
				retractCallback = retractCallback,
			}),

			categoryButtons = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.0287, 0.12),
				Rotation = 10,
				Size = UDim2.fromScale(0.119, 0.805),
				ZIndex = 2,
			}, {
				categories = Roact.createFragment(categoriesButtons),
			}),
		})
	end
end

return InventoryFrame
