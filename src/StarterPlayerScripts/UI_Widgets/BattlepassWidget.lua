--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Main
local BattlepassWidget = {}
local player = Players.LocalPlayer
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Services
local BattlepassService = Knit.GetService("BattlepassService")
--Constants

function BattlepassWidget:Initialize()
	local BattlepassGui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("BattlepassGui") then
		BattlepassGui = Assets.GuiObjects.ScreenGuis.BattlepassGui or game.Players.LocalPlayer.PlayerGui.BattlepassGui
		BattlepassGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		BattlepassGui = game.Players.LocalPlayer.PlayerGui.BattlepassGui
	end
	BattlepassGui.Enabled = false

	BattlepassGui.BattlepassFrame.CloseButton.MouseButton1Click:Connect(function()
		BattlepassGui.Enabled = false
	end)

	--Set up the back button
	local backButtonFrame = BattlepassGui.BackButtonFrame
	backButtonFrame.Button.Activated:Connect(function()
		ButtonWidget:OnActivation(backButtonFrame.Button)
	end)
	BattlepassWidget.MainFrame = game.Players.LocalPlayer.PlayerGui.BattlepassGui.BattlepassFrame
	--Hide the main frame with position
	BattlepassWidget.MainFrame.Position = UDim2.fromScale(1, 0)
	
	return true
end

function BattlepassWidget:OpenBattlepass()
	--Tween the main frame position
	local mainFrameTween =
		TweenService:Create(BattlepassWidget.MainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0, 0) })
	mainFrameTween:Play()

	
end

return BattlepassWidget:Initialize()
