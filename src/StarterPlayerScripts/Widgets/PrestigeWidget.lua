--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
local Prestiges = require(ReplicatedStorage.Source.Assets.Prestiges)
--Services
local LevelService = Knit.GetService("LevelService")
--Controllers
local WidgetController = Knit.GetController("WidgetController")
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
--Main
local PrestigeWidget = {}
--Constants
--Screen guis
local PrestigeGui
--Gui objects
local mainFrame
local prestigeIcon
local prestigeTextLabel
local benefitsTextLabel

function PrestigeWidget:Initialize()
	--Initialize the screen guis
	--Battlepass gui
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("PrestigeGui") then
		PrestigeGui = Assets.GuiObjects.ScreenGuis.PrestigeGui or game.Players.LocalPlayer.PlayerGui.PrestigeGui
		PrestigeGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		PrestigeGui = game.Players.LocalPlayer.PlayerGui.PrestigeGui
	end
	--Initialize the gui objects
	mainFrame = PrestigeGui.MainFrame
	prestigeIcon = PrestigeGui.MainFrame.PrestigeIcon
	prestigeTextLabel = PrestigeGui.MainFrame.PrestigeTextLabel
	benefitsTextLabel = PrestigeGui.MainFrame.BenefitsTextLabel
	--Hide the challenges frame with position
	mainFrame.Position = UDim2.fromScale(mainFrame.Position.X.Scale, 1)

	PrestigeGui.Enabled = false

	--Connect button events
	ButtonWidget.new(mainFrame.ButtonsStackFrame.CancelFrame, function()
		self:ClosePrestige()
	end)

	ButtonWidget.new(mainFrame.ButtonsStackFrame.PrestigeFrame, function()
		self:ClosePrestige()
		LevelService:Prestige()
	end)

	return PrestigeWidget
end

function PrestigeWidget:OpenPrestige()
	if not PrestigeGui.Enabled then
		PrestigeGui.Enabled = true
	end

	--Assign the next prestige icon
	prestigeIcon.Image = Prestiges[Players.LocalPlayer:GetAttribute("Prestige") + 1].icon
	prestigeTextLabel.Text = string.format("PRESTIGE %d", Players.LocalPlayer:GetAttribute("Prestige") + 1)
    benefitsTextLabel.Text = string.format(
        "● Prestige %d weapons <br/>● Prestige %d skins <br/>● Prestige %d emotes <br/>",
		Players.LocalPlayer:GetAttribute("Prestige") + 1,
        Players.LocalPlayer:GetAttribute("Prestige") + 1,
        Players.LocalPlayer:GetAttribute("Prestige") + 1
    )

	--Open the challenges frame
	mainFrame:TweenPosition(
		mainFrame:GetAttribute("VisiblePosition"),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.13
	)
end

function PrestigeWidget:ClosePrestige()
	mainFrame:TweenPosition(
		UDim2.fromScale(mainFrame.Position.X.Scale, 1),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.13
	)
	task.delay(0.13, function()
		PrestigeGui.Enabled = false
		WidgetController.MainMenuWidget:ShowMenu()
	end)
end

function PrestigeWidget:Prestige() end

return PrestigeWidget:Initialize()
