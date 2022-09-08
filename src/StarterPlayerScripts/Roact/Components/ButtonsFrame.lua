local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)

local InventoryFrame = Roact.Component:extend("InventoryFrame")
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Assets
local InventoryIcons = require(game.ReplicatedStorage.Source.Assets.Icons.InventoryIcons)
--Components

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
    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Position = self.props.position,
        Rotation = self.props.rotation,
        Size = self.props.size,
      }, {
        UIGridLayout = Roact.createElement("UIGridLayout", {
          CellPadding = self.props.cellPadding,
          CellSize = self.props.cellSize,
          SortOrder = Enum.SortOrder.LayoutOrder,
        }),

      })
end

return InventoryFrame
