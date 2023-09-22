--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Knit Services
local DataService = Knit.GetService("StoreService")
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Main
local RespawnWidget = {}
local player = Players.LocalPlayer

function RespawnWidget:Initialize(callback)
	if not Knit.GetController("GameModeController")._canRespawn then
		return
	end
	local respawnGui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("RespawnGui") then
		respawnGui = Assets.GuiObjects.ScreenGuis.RespawnGui or game.Players.LocalPlayer.PlayerGui.RespawnGui
		respawnGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		respawnGui = game.Players.LocalPlayer.PlayerGui.RespawnGui
	end
	--Enable the gui
	respawnGui.Enabled = true
	--Set up the main frame
	local mainFrame = respawnGui.Frame
	mainFrame.Position = UDim2.fromScale(-1, mainFrame.Position.Y.Scale)
	--Animate the initial transition of main frame
	local mainFrameTween =
		TweenService:Create(mainFrame, TweenInfo.new(1.33), { Position = mainFrame:GetAttribute("StartingPosition") })
	local respawnButton = respawnGui.Frame.RespawnButton
	local respawnMultiplier = 0
	--Set up the bar for the respawn timer
	local respawnBar = respawnGui.Frame.ProgressBarFrame
	mainFrameTween:Play()
	--Communicate to camera controller to change mode
	--Get the killer's HRP
	--Check if the killer is a player
	if player:GetAttribute("KillerID") then
		local killerPlayer = Players:GetPlayerByUserId(player:GetAttribute("KillerID"))
		if killerPlayer then
			--Get the killer's HRP
			local killerHRP = killerPlayer.Character.HumanoidRootPart
			Knit.GetController("CameraController"):ChangeMode("Respawn", { killerHRP = killerHRP })
		else
			Knit.GetController("CameraController"):ChangeMode("Respawn", { killerHRP = workspace.Arena.SpawnLocation })
		end
		--clean up the killer id
		player:SetAttribute("KillerID", nil)
	end
	mainFrameTween.Completed:Connect(function()
		while respawnBar.Size.X.Scale < respawnBar:GetAttribute("X_Goal") do
			respawnBar.Size =
				UDim2.fromScale(respawnBar.Size.X.Scale + 0.0006 + respawnMultiplier, respawnBar.Size.Y.Scale)
			task.wait(0.01)
		end
		--Create tween for main frame
		local mainFrameTween = TweenService:Create(
			mainFrame,
			TweenInfo.new(0.5),
			{ Position = UDim2.fromScale(1, mainFrame.Position.Y.Scale) }
		)
		mainFrameTween:Play()
		mainFrameTween.Completed:Connect(function()
			respawnBar.Size = UDim2.fromScale(0, respawnBar.Size.Y.Scale)
			--Reset the main frame
			mainFrame.Position = UDim2.fromScale(-1, mainFrame.Position.Y.Scale)
			--disable the gui
			respawnGui.Enabled = false
			callback()
		end)
	end)
	respawnButton.Activated:Connect(function()
		ButtonWidget:OnActivation(respawnButton, function()
			respawnMultiplier = respawnMultiplier + 0.0006
		end, "respawn")
	end)
end

return RespawnWidget
