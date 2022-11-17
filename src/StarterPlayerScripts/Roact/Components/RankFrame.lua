local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local RankFrame = Roact.Component:extend("RankFrame")
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

function RankFrame:init()
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

function RankFrame:render()
  repeat
    task.wait()
  until self.rankValue 
  return Roact.createElement("Frame", {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Position = self.props.position,
    Size = self.props.size,
    ZIndex = self.props.ZIndex
  }, {
    rankValue = Roact.createElement("TextLabel", {
      Text = self.rankValue,
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      TextSize = 14,
      TextStrokeTransparency = 0.3,
      TextWrapped = true,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.31, 0.144),
      Size = UDim2.fromScale(0.381, 0.743),
      ZIndex = 2,
    }),
  
    rankIcon = Roact.createElement("ImageLabel", {
      Image = "rbxassetid://11530445688",
      ScaleType = Enum.ScaleType.Fit,
      BackgroundColor3 = Color3.fromRGB(102, 102, 102),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(-0.00427, 0.0554),
      Size = UDim2.fromScale(1, 1.02),
    }),
  })
end

function RankFrame:didMount()
	local statsService = Knit.GetService("StatsService")
	--Update bindings
	statsService.StatChanged:Connect(function(newValue)
		self.updateStatValue(newValue)
	end)
end

return RankFrame
