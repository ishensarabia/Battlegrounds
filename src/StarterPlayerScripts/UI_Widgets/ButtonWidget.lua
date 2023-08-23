--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Main
local ButtonWidget = {}

local buttonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0)
local debounce = false
function ButtonWidget:OnActivation(button: GuiButton, callback, customSoundName: string, params: table)
	debounce = true
	Knit.GetController("AudioController"):PlaySound(customSoundName or "click")
	local buttonTween
	if button.Size.X.Scale < 0.2 then
		buttonTween = TweenService:Create(
			button,
			buttonTweenInfo,
			{ Size = UDim2.fromScale(button.Size.X.Scale - 0.003, button.Size.Y.Scale - 0.003) }
		)
	else
		buttonTween = TweenService:Create(
			button,
			buttonTweenInfo,
			{ Size = UDim2.fromScale(button.Size.X.Scale - 0.009, button.Size.Y.Scale - 0.15) }
		)
	end
	buttonTween:Play()
	if callback then
		buttonTween.Completed:Connect(function()
			callback()
			debounce = false
		end)
	end
	return buttonTween
end

return ButtonWidget
