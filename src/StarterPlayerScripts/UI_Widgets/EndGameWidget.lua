--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
--Widgets
local LoadoutWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.LoadoutWidget)
local BattlepassWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.BattlepassWidget)
local ChallengesWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ChallengesWidget)
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
local RespawnWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.RespawnWidget)
local StoreWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.StoreWidget)
--Main
local EndGameWidget = {}
local EndGameGui
--Variables
local mainFrame
local active = true
--Constants
local DEFAULT_CATEGORY = "Firearms"
local transparencyTweenInfo = TweenInfo.new(3.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true)

function EndGameWidget:HideMenu() end

function EndGameWidget:Initialize()
	--Mount main menu widget
	local player = game.Players.LocalPlayer
	EndGameGui = Assets.GuiObjects.ScreenGuis.EndGameGui
	mainFrame = EndGameGui.MainFrame
	EndGameGui.Parent = player.PlayerGui
	EndGameGui.Enabled = false
	--Hide members to animate
	mainFrame.Position = UDim2.fromScale(2, 0)
	mainFrame.EndGameTextLabel.TextTransparency = 1


	return self
end

function EndGameWidget:ShowEndGameResults(leaderboard: table)
	if not EndGameGui.Enabled then
		EndGameGui.Enabled = true
	end
	local mainFramePositionTween =
		TweenService:Create(mainFrame, TweenInfo.new(0.69), { Position = UDim2.fromScale(0, 0) })
	mainFramePositionTween:Play()
	local endGameTextTransparencyTween =
		TweenService:Create(mainFrame.EndGameTextLabel, transparencyTweenInfo, { TextTransparency = 0 })
	endGameTextTransparencyTween:Play()
	local backgroundTransprencyTween =
		TweenService:Create(mainFrame.BackgroundFrame, transparencyTweenInfo, { BackgroundTransparency = 0.69 })
	backgroundTransprencyTween:Play()
	endGameTextTransparencyTween.Completed:Connect(function(playbackState)
		backgroundTransprencyTween:Play()
		local mainFramePositionTween =
			TweenService:Create(mainFrame, TweenInfo.new(0.69), { Position = UDim2.fromScale(2, 0) })
		mainFramePositionTween:Play()
        mainFramePositionTween.Completed:Connect(function()
            EndGameGui.Enabled = false
        end)
	end)
end

return EndGameWidget:Initialize()
