local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local StatFrame = Roact.Component:extend("StatFrame")
local statsIcons = {
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

function StatFrame:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding
  
	self.motor:onStep(setBinding)
	--Roact binding
	local statsService = Knit.GetService("StatsService")
  --Get value and then assing to the binding initial value
  -- warn(self.props.stat)
	statsService:GetStatValue(self.props.stat):andThen(function(statValue)
    warn(statValue)
		self.statValue, self.updateStatValue = Roact.createBinding(statValue)
	end)
end

function StatFrame:render()
  repeat
    task.wait()
  until self.statValue 
  return Roact.createElement("Frame", {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Position = self.props.position,
    Size = self.props.size,
    ZIndex = self.props.ZIndex
  }, {
    statAmount = Roact.createElement("TextLabel", {
      Text = self.statValue,
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      TextSize = 14,
      TextStrokeTransparency = 0.3,
      TextWrapped = true,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.208, 0.2),
      Size = UDim2.fromScale(0.798, 0.743),
      ZIndex = 2,
    }),
  
    statIcon = Roact.createElement("ImageLabel", {
      Image = statsIcons[self.props.stat],
      ScaleType = Enum.ScaleType.Fit,
      BackgroundColor3 = Color3.fromRGB(102, 102, 102),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(-0.0384, 0.0367),
      Rotation = 10,
      Size = UDim2.fromScale(0.351, 1.06),
      ZIndex = 2,
    }),
  
    statLabel = Roact.createElement("ImageLabel", {
      Image = "rbxassetid://9963227346",
      ImageColor3 = Color3.fromRGB(102, 102, 102),
      BackgroundColor3 = Color3.fromRGB(102, 102, 102),
      BackgroundTransparency = 1,
      Size = UDim2.fromScale(1.01, 1),
    }),
  
    statTitle = Roact.createElement("TextLabel", {
      Text = statTextDictionary[self.props.stat],
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      TextSize = 14,
      TextStrokeTransparency = 0.3,
      TextWrapped = true,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.688, -0.324),
      Rotation = 10,
      Size = UDim2.fromScale(0.554, 0.524),
      ZIndex = 2,
    }),
  })
end

function StatFrame:didMount()
	local statsService = Knit.GetService("StatsService")
	--Update bindings
	statsService.StatChanged:Connect(function(newValue)
		self.updateStatValue(newValue)
	end)
end

return StatFrame
