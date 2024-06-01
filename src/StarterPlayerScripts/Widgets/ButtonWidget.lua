-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Constants
local BUTTON_TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0)
local HOVER_TWEEN_INFO = TweenInfo.new(0.33, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

-- Main
local ButtonWidget = {}
ButtonWidget.__index = ButtonWidget

function ButtonWidget.new(instance, callback, customSoundName)
	local self = setmetatable({}, ButtonWidget)

	-- Instance properties
	self.instance = instance
	self.callback = callback
	self.customSoundName = customSoundName or "click"
	self.debounce = false

	-- Identify the type of instance and adjust accordingly
	if instance:IsA("Frame") or instance:IsA("CanvasGroup") then
		self.button = instance:FindFirstChildWhichIsA("ImageButton") or instance:FindFirstChildWhichIsA("TextButton")
		if not self.button then
			error("Frame does not contain an ImageButton or TextButton: " .. instance:GetFullName())
		end
		self.frame = instance
		self._defaultSize = self.instance.Size
		self._hoverSize = instance.Size + UDim2.new(0.01, 0, 0.01, 0)
	elseif instance:IsA("ImageButton") or instance:IsA("TextButton") then
		self.button = instance
		self._defaultSize = instance.Size
		self._hoverSize = instance.Size + UDim2.new(0.01, 0, 0.01, 0)
	else
		error("Invalid instance type for ButtonWidget: " .. instance.ClassName)
	end

	-- Connect events
	self.instance.MouseEnter:Connect(function()
		self:OnHover(instance)
	end)
	self.instance.MouseLeave:Connect(function()
		self:OnHoverEnded(instance)
	end)
	self.button.Activated:Connect(function() self:OnActivation() end)

	return self
end

function ButtonWidget:OnHover()
	local goal = { Size = self._hoverSize } -- New size

	local tween = TweenService:Create(self.instance, HOVER_TWEEN_INFO, goal)
	tween:Play()
end

function ButtonWidget:OnHoverEnded(instance)
	local goal = { Size = self._defaultSize } -- New size

	local tween = TweenService:Create(self.instance, HOVER_TWEEN_INFO, goal)
	tween:Play()
end

function ButtonWidget:OnActivation(callback : Function?)
	if self.debounce then
		return
	end
	self.debounce = true
	Knit.GetController("AudioController"):PlaySound(self.customSoundName)
	local buttonTween
	if self.instance.Size.X.Scale < 0.2 then
		buttonTween = TweenService:Create(
			self.instance,
			BUTTON_TWEEN_INFO,
			{ Size = UDim2.fromScale(self._defaultSize.X.Scale - 0.003, self._defaultSize.Y.Scale - 0.003) }
		)
	else
		buttonTween = TweenService:Create(
			self.instance,
			BUTTON_TWEEN_INFO,
			{ Size = UDim2.fromScale(self._defaultSize.X.Scale - 0.006, self._defaultSize.Y.Scale - 0.006) }
		)
	end
	buttonTween:Play()
	
	if self.callback and not callback then
		buttonTween.Completed:Connect(function()
			self.callback()
			self.debounce = false
		end)
	elseif callback then
		buttonTween.Completed:Connect(function()
			callback()
			self.debounce = false
		end)
	end
	return buttonTween
end

return ButtonWidget
