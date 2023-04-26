--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
--Main
local StaminaWidget = {}
local player = Players.LocalPlayer
--Constants
local MAX_STAMINA = 100

function StaminaWidget:Initialize()
	local StaminaBarGui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("StaminaBarGui") then
		StaminaBarGui = Assets.GuiObjects.ScreenGuis.StaminaBarGui or game.Players.LocalPlayer.PlayerGui.StaminaBarGui
		StaminaBarGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		StaminaBarGui = game.Players.LocalPlayer.PlayerGui.StaminaBarGui
	end
	StaminaBarGui.Enabled = false
	local staminaBar = StaminaBarGui.CanvasGroup.ProgressBarFrame

	--Wait for the player to spawn
	player.CharacterAdded:Connect(function(character)
		--Connect to the stamina attribute
		local transparencyDebounce = false
		character:GetAttributeChangedSignal("Stamina"):Connect(function()
			if not transparencyDebounce then
				--Enable the gui
				StaminaBarGui.Enabled = true
				--Set the canvas group transparency to 0
				StaminaBarGui.CanvasGroup.GroupTransparency = 1
				--Tween the canvas group transparency to 0
				TweenService:Create(StaminaBarGui.CanvasGroup, TweenInfo.new(0.5), { GroupTransparency = 0 }):Play()
				transparencyDebounce = true
				task.delay(6.33, function()
					--Tween the canvas group transparency to 1
					local transparencyTween =
						TweenService:Create(StaminaBarGui.CanvasGroup, TweenInfo.new(0.5), { GroupTransparency = 1 })
					transparencyTween:Play()
					transparencyTween.Completed:Connect(function()
						--Disable the gui
						StaminaBarGui.Enabled = false
						transparencyDebounce = false
					end)
				end)
			end
			--Update the bar
			staminaBar.Size = UDim2.fromScale(
				(character:GetAttribute("Stamina") / MAX_STAMINA) * staminaBar:GetAttribute("X_Goal"),
				staminaBar.Size.Y.Scale
			)
		end)
	end)

	return true
end

return StaminaWidget:Initialize()
