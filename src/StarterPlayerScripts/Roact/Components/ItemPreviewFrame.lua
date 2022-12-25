local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local ItemPreviewFrame = Roact.Component:extend("ItemPreviewFrame")
local rankIcons = {
	Knockouts = "rbxassetid://11388696098",
	Defeats = "rbxassetid://11388651427",
}
local statTextDictionary = {
  Knockouts = "K.Os!",
  Defeats = "Defeats"
}
--Springs
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})

function ItemPreviewFrame:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding
  
	self.motor:onStep(setBinding)
	--Roact binding
	local statsService = Knit.GetService("StatsService")
  --Get value and then assing to the binding initial value
  -- warn(self.props.stat)
	statsService:GetStatValue("Rank"):andThen(function(rankValue)
		self.rankValue, self.updateRankValue = Roact.createBinding(rankValue)
	end)
end

function ItemPreviewFrame:render()
  return Roact.createElement("Frame", {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0.335, 0.104),
    Size = UDim2.fromScale(0.433, 0.636),
  }, {
    imageLabel = Roact.createElement("ImageLabel", {
      Image = "rbxassetid://11571256920",
      ImageTransparency = 0.3,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(-5.15e-08, 0),
      Size = UDim2.fromScale(1.02, 1),
    }),
  
    title = Roact.createElement("TextLabel", {
      Text = self.props.weaponID,
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      TextSize = 14,
      TextStrokeTransparency = 0.3,
      TextWrapped = true,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.28, 0.0428),
      Size = UDim2.fromScale(0.526, 0.0943),
    }),
  
    viewportFrame = Roact.createElement("ViewportFrame", {
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.215, 0.199),
      Size = UDim2.fromOffset(342, 172),
    }),
  })end

function ItemPreviewFrame:didMount()
	local statsService = Knit.GetService("StatsService")
	--Update bindings
	statsService.StatChanged:Connect(function(newValue)
		self.updateStatValue(newValue)
	end)
end

return ItemPreviewFrame
