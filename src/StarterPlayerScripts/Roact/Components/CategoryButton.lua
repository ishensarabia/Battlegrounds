local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)

local CategoryButton = Roact.Component:extend("CategoryButton")
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Assets
local ButtonIcons = require(game.ReplicatedStorage.Source.Assets.Icons.ButtonIcons)
--Components

function CategoryButton:init()
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

function CategoryButton:render()
  return Roact.createElement("Frame", {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0.122, 0.171),
    Size = UDim2.fromScale(0.187, 0.0926),
  }, {
    inventoryButton = Roact.createElement("ImageButton", {
      Image = "rbxassetid://9963227346",
      ImageColor3 = Color3.fromRGB(102, 102, 102),
      ScaleType = Enum.ScaleType.Tile,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Rotation = -5,
      Size = UDim2.fromScale(1, 1),
    }),
  
    title = Roact.createElement("TextLabel", {
      Font = Enum.Font.SourceSansBold,
      Text = self.props.buttonCategory,
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      TextSize = 14,
      TextStrokeTransparency = 0.3,
      TextWrapped = true,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.163, 0.0879),
      Rotation = -5,
      Size = UDim2.fromScale(0.721, 0.293),
    }),
  
    iconButton = Roact.createElement("ImageButton", {
      Image = ButtonIcons[self.props.buttonCategory],
      ScaleType = Enum.ScaleType.Fit,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.293, 0.373),
      Size = UDim2.fromScale(0.465, 0.815),
    }),
  })
end

return CategoryButton
