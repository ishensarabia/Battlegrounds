local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local PlayButton = Roact.Component:extend("PlayButton")
--Springs
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
function PlayButton:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function PlayButton:render()
  return Roact.createElement("ImageButton", {
    Image = "rbxassetid://9963227346",
    ImageColor3 = Color3.fromRGB(255, 184, 60),
    ScaleType = Enum.ScaleType.Fit,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Position = self.props.position,
    Size = self.binding:map(function(value)
        return self.props.size:Lerp(self.props.size - UDim2.fromScale(0.03, 0.05), value)
    end),
    [Roact.Event.MouseButton1Down] = function()
      self.motor:setGoal(Flipper.Spring.new(1, {
          frequency = 5,
          dampingRatio = 1,
      }))
      task.delay(0.163, function()
          Knit.GetService("PlayerService"):SpawnCharacter()
          self.props.callback(self.props.retractCallback)
      end)
  end,
  }, {
    title = Roact.createElement("TextLabel", {
      Font = Enum.Font.SourceSansBold,
      Text = "PLAY",
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      TextSize = 14,
      TextStrokeTransparency = 0.3,
      TextWrapped = true,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 1,
      Position = UDim2.fromScale(0.123, 0.203),
      Size = UDim2.fromScale(0.753, 0.581),
    }),

  })
end

return PlayButton
