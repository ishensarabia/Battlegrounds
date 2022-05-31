local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local ToggleMapEvent = ReplicatedStorage.Events.ToggleMapEvent
local EnableToggleMapButtonEvent = ReplicatedStorage.Events.EnableToggleMapButtonEvent

local Roact = require(ReplicatedStorage.Packages.Roact)
local Conf = require(ReplicatedFirst.Configurations.MainConfiguration)
local MinimapGui = require(ReplicatedStorage.Libraries.Guis.MinimapGui)

local ToggleMapButton = Roact.PureComponent:extend("ToggleMapButton")

function ToggleMapButton:init()
	self:setState({
		enabled = false,
		Size = UDim2.new(Conf.minimap_width, 0, Conf.minimap_height, 0),
		Position = UDim2.new(1, 0, 0, 36),
		AnchorPoint = Vector2.new(1, 0),
	})
	self.prevInputType = nil
end

function ToggleMapButton:render()
	if self.state.enabled then
		return Roact.createElement("Frame", {
			AnchorPoint = self.state.AnchorPoint,
			Position = self.state.Position,
			Size = self.state.Size,
			BackgroundTransparency = 1,
		}, {
			ToggleMapButton = Roact.createElement("TextButton", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				[Roact.Event.Activated] = function()
					self:updateButton(self.state.enabled, ToggleMapEvent:Invoke())
				end
			}),
			UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
			}),
		})
	end
end

function ToggleMapButton:didMount()
	self.prevInputType = UserInputService:GetLastInputType()
	if UserInputService.TouchEnabled then
		self:updateButton(MinimapGui.isEnabled(), MinimapGui.isCurrentlyMinimap())
	end

	self.lastInputTypeChangedConn = UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
		if lastInputType == Enum.UserInputType.Touch or self.prevInputType == Enum.UserInputType.Touch then
			self:updateButton((lastInputType == Enum.UserInputType.Touch and MinimapGui.isEnabled()), MinimapGui.isCurrentlyMinimap)
			self.prevInputType = lastInputType
		end
	end)

	EnableToggleMapButtonEvent.Event:Connect(function(enable, isCurrentlyMinimap)
		self:updateButton(enable and UserInputService.TouchEnabled, isCurrentlyMinimap)
	end)
end

function ToggleMapButton:updateButton(enable, isCurrentlyMinimap)
	if isCurrentlyMinimap then
		self:setState({
			enabled = enable,
			Size = UDim2.new(Conf.minimap_width, 0, Conf.minimap_height, 0),
			Position = UDim2.new(1, 0, 0, 36),
			AnchorPoint = Vector2.new(1, 0),
		})
	else
		self:setState({
			enabled = enable,
			Size = UDim2.new(Conf.worldmap_width, 0, Conf.worldmap_height, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
		})
	end
end

function ToggleMapButton:willUnmount()
	self.lastInputTypeChangedConn:Disconnect()
end

return ToggleMapButton