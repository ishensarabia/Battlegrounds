local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local WeaponsIcons = require(ReplicatedStorage.Source.Assets.Icons.WeaponsIcons)
local WeaponFrame = Roact.Component:extend("WeaponFrame")
--Assets
local ButtonIcons = {
	["SCI-FI"] = "rbxassetid://9964658404",
	MEDIEVAL = "rbxassetid://9964596201",
	FIREARMS = "rbxassetid://9964075868",
}
--Components

function WeaponFrame:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function WeaponFrame:render()
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
      })
end

return WeaponFrame
