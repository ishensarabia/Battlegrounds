local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local CloseButton = Roact.Component:extend("CloseButton")
--Springs
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
function CloseButton:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)
end

function CloseButton:render()
  return Roact.createElement("ImageButton", {
    Image = "rbxassetid://10621524124",
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Position = self.props.position,
    Size = self.binding:map(function(value)
        return self.props.size:Lerp(UDim2.fromScale(0.06, 0.145     ), value)
    end),
    ZIndex = self.props.zindex,
    [Roact.Event.MouseButton1Down] = function()
      --Play the sound
      Knit.GetController("AudioController"):PlaySound("click")
      self.motor:setGoal(Flipper.Spring.new(1, {
          frequency = 5,
          dampingRatio = 1,
      }))
      task.delay(0.163, function()
        self.props.callback(self.props.retractCallback)
      end)
    end,
  })
end

return CloseButton
