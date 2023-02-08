--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Widgets
--Main
local ButtonWidget = {}
local MainMenuGui
--Variables
local playerPreviewViewportFrame
local inventoryButtonsFrame
local playButton

local buttonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0)

function ButtonWidget:OnActivation(button: GuiButton, callback, customSoundName : string)
	Knit.GetController("AudioController"):PlaySound(customSoundName or "click")
    local buttonTween
    if button.Size.X.Scale < 0.2 then
        buttonTween = TweenService:Create(
            button,
            buttonTweenInfo,
            { Size = UDim2.fromScale(button.Size.X.Scale - 0.03, button.Size.Y.Scale - 0.03) }
        )
    else
        buttonTween = TweenService:Create(
            button,
            buttonTweenInfo,
            { Size = UDim2.fromScale(button.Size.X.Scale - 0.2, button.Size.Y.Scale - 0.2) }
        )
    end
	buttonTween:Play()
    buttonTween.Completed:Connect(callback)
    return buttonTween
end

return ButtonWidget
