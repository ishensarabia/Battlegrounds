--Services
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Knit Services
local UserInputService = game:GetService("UserInputService")
--Modules
local UserInputTypeSystemModule = require(ReplicatedStorage.Source.Modules.Util.UserInputTypeSystemModule)
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
--Main
local RespawnWidget = {}
local player = Players.LocalPlayer
local respawnButton
local respawnGui
--Assets
local InputIcons = require(ReplicatedStorage.Source.Assets.Icons.InputIcons)
--Constants
local ACTION_RESPAWN = "Respawn"
local RESPAWN_PC_KEYCODE = Enum.KeyCode.Space
local RESPAWN_GAMEPAD_KEYCODE = Enum.KeyCode.ButtonY
--Gui variables
local respawnBar
local mainFrame
--Variables
local respawnMultiplier = 0

--Connections
local userInputConnection

local function RespawnCompleted()
	ContextActionService:UnbindAction(ACTION_RESPAWN)
	respawnBar.Size = UDim2.fromScale(0, respawnBar.Size.Y.Scale)
	--Reset the main frame
	mainFrame.Position = UDim2.fromScale(-1, mainFrame.Position.Y.Scale)
	--disable the gui
	respawnGui.Enabled = false
	Knit.GetController("WidgetController").MainMenuWidget:ShowMenu()
	userInputConnection:Disconnect()
	respawnMultiplier = 0
end

function RespawnWidget:ShowWidget()
	--Check if the player can respawn
	if not Knit.GetController("GameModeController")._canRespawn then
		return
	end
	--Enable the gui
	respawnGui.Enabled = true
	--Animate the initial transition of main frame
	local mainFrameTween =
		TweenService:Create(mainFrame, TweenInfo.new(1.33), { Position = mainFrame:GetAttribute("StartingPosition") })
	mainFrameTween:Play()
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
		--Create tween to hide the main frame
		local hideMainFrameTween = TweenService:Create(
			mainFrame,
			TweenInfo.new(0.5),
			{ Position = UDim2.fromScale(1, mainFrame.Position.Y.Scale) }
		)
		hideMainFrameTween:Play()
		hideMainFrameTween.Completed:Connect(RespawnCompleted)
	end)

	--Bind action
	ContextActionService:BindAction(
		ACTION_RESPAWN,
		function(actionName: string, inputState: InputObject, _inputObject: InputObject)
			if actionName == ACTION_RESPAWN and inputState == Enum.UserInputState.Begin then
				respawnButton:OnActivation()
			end
		end,
		false,
		RESPAWN_PC_KEYCODE,
		RESPAWN_GAMEPAD_KEYCODE
	)

	userInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		respawnButton.instance.InputIcon.Visible = true
		if UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "KeyboardAndMouse" then
			respawnButton.instance.InputIcon.Image = InputIcons.PC.Space
		elseif UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Gamepad" then
			if UserInputTypeSystemModule.gamepadType == "PlayStation" then
				respawnButton.instance.InputIcon.Image = InputIcons.PS.TriangleButton
			elseif UserInputTypeSystemModule.gamepadType == "Xbox" then
				respawnButton.instance.InputIcon.Image = InputIcons.Xbox.YButton
			end
		elseif UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Touch" then
			respawnButton.instance.InputIcon.Visible = false
		end
	end)
end

function RespawnWidget:Initialize()
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("RespawnGui") then
		respawnGui = Assets.GuiObjects.ScreenGuis.RespawnGui or game.Players.LocalPlayer.PlayerGui.RespawnGui
		respawnGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		respawnGui = game.Players.LocalPlayer.PlayerGui.RespawnGui
	end
	--Set up the main frame
	mainFrame = respawnGui.Frame
	mainFrame.Position = UDim2.fromScale(-1, mainFrame.Position.Y.Scale)

	respawnBar = respawnGui.Frame.ProgressBarFrame

	--Create the respawn button
	if not respawnButton then
		respawnButton = ButtonWidget.new(respawnGui.Frame.RespawnButton, function()
			respawnMultiplier = respawnMultiplier + 0.0006
		end, "respawn")
	end

	return self
end

return RespawnWidget:Initialize()
