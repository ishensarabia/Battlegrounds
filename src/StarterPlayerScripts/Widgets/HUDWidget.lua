--Services
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
local HUDWidget = {}
local player = Players.LocalPlayer
local respawnButton
local HUDGui
--Assets
local InputIcons = require(ReplicatedStorage.Source.Assets.Icons.InputIcons)
--Constants
local TWEEN_INFO = TweenInfo.new(0.33)
local GREEN_COLOR = Color3.fromRGB(152, 255, 178)
local RED_COLOR = Color3.fromRGB(255, 90, 90)
--Gui Variables
local mainFrame
local currentWeaponFrame
local healthFrame

function HUDWidget:Initialize()
	warn("HUD widget initialized")
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("HUDGui") then
		HUDGui = Assets.GuiObjects.ScreenGuis.HUDGui or game.Players.LocalPlayer.PlayerGui.HUDGui
		HUDGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		HUDGui = game.Players.LocalPlayer.PlayerGui.HUDGui
	end
	--Disable the gui
	HUDGui.Enabled = false
	--Set up the main frame
	mainFrame = HUDGui.MainFrame
	currentWeaponFrame = mainFrame.CurrentWeaponFrame
	healthFrame = mainFrame.HealthFrame
	--Hide the gui elements
	mainFrame.Position = UDim2.fromScale(-1, mainFrame.Position.Y.Scale)
	currentWeaponFrame.Position = UDim2.fromScale(currentWeaponFrame.Position.X.Scale, 1.5)

	self:InitializeHealth()

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "KeyboardAndMouse" then
			-- respawnButton.instance.InputIcon.Image = InputIcons.PC.Space
		elseif UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Gamepad" then
			if UserInputTypeSystemModule.gamepadType == "PlayStation" then
				-- respawnButton.instance.InputIcon.Image = InputIcons.PS.TriangleButton
			elseif UserInputTypeSystemModule.gamepadType == "Xbox" then
				-- respawnButton.instance.InputIcon.Image = InputIcons.Xbox.YButton
			end
		elseif UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Touch" then
			-- respawnButton.instance.InputIcon.Visible = false
		end
	end)
	warn(GREEN_COLOR)
	return self
end

function HUDWidget:ShowHUD()
	--Enable the gui
	HUDGui.Enabled = true
	--Animate the initial transition of main frame
	local mainFrameTween = TweenService:Create(mainFrame, TWEEN_INFO, { Position = UDim2.fromScale(0, 0) })
	mainFrameTween:Play()
end

function HUDWidget:ResetHealth()
	TweenService:Create(healthFrame.HealthIconTextLabel, TweenInfo.new(0.5), { Size = self.initialHealthIconSize })
		:Play()
	healthFrame.HealthIconTextLabel.Position = self.initialHealthIconPostion
	if self.healthPulseTween then
		self.healthPulseTween:Cancel()
		self.healthPulseTween = nil
	end
end
function HUDWidget:InitializeHealth()
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		healthFrame.HealthStackFrame.CurrentHealthTextLabel.Text = math.floor(humanoid.Health)
		healthFrame.HealthStackFrame.TotalHealthTextLabel.Text = math.floor(humanoid.MaxHealth)
		healthFrame.HealthIconTextLabel.TextColor3 = GREEN_COLOR

		self.initialHealthIconSize = healthFrame.HealthIconTextLabel.Size
		self.initialHealthIconPostion = healthFrame.HealthIconTextLabel.Position
		
		humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			healthFrame.HealthStackFrame.CurrentHealthTextLabel.Text = math.floor(humanoid.Health)
			-- Calculate the health percentage
			local healthPercentage = humanoid.Health / humanoid.MaxHealth
			-- Lerp between custom green and red based on the health percentage
			local color = GREEN_COLOR:Lerp(RED_COLOR, 1 - healthPercentage)
			-- Create a tween to animate the color change
			local colorTween =
				TweenService:Create(healthFrame.HealthIconTextLabel, TweenInfo.new(0.5), { TextColor3 = color })
			colorTween:Play()
			-- If health is less than a quarter, animate the size to give a pulse effect
			if healthPercentage < 0.25 then
				if not self.healthPulseTween then
					local newScale = UDim2.fromScale(
						self.initialHealthIconSize.X.Scale * 0.85,
						self.initialHealthIconSize.Y.Scale * 0.85
					)
					self.healthPulseTween = TweenService:Create(
						healthFrame.HealthIconTextLabel,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
						{ Size = newScale }
					)
					warn("Pulse tween created")
					self.healthPulseTween:Play()
					healthFrame.HealthIconTextLabel.Position =
						healthFrame.HealthIconTextLabel:GetAttribute("PulsePosition")
				end
			else
				if self.healthPulseTween then
					self:ResetHealth()
				end
			end
		end)

		humanoid.Died:Connect(function()
			self:ResetHealth()
		end)
	end)
end

function HUDWidget:HideHUD()
	local mainFrameTween =
		TweenService:Create(mainFrame, TWEEN_INFO, { Position = UDim2.fromScale(-1, mainFrame.Position.Y.Scale) })
	mainFrameTween:Play()
	mainFrameTween.Completed:Connect(function()
		HUDGui.Enabled = false
	end)
end

function HUDWidget:ShowWeaponInfo(weapon: Instance)
	--Tween according to the input type the player is using
	if
		UserInputTypeSystemModule.inputTypeThePlayerIsUsing == UserInputTypeSystemModule.inputTypes.KeyboardAndMouse
		or UserInputTypeSystemModule.inputTypes.Gamepad
	then
		TweenService
			:Create(currentWeaponFrame, TWEEN_INFO, { Position = currentWeaponFrame:GetAttribute("TargetPosition") })
			:Play()
	end

	if UserInputTypeSystemModule.inputTypeThePlayerIsUsing == UserInputTypeSystemModule.inputTypes.Touch then
		TweenService
			:Create(
				currentWeaponFrame,
				TWEEN_INFO,
				{ Position = currentWeaponFrame:GetAttribute("MobileTargetPosition") }
			)
			:Play()
	end

	--Assign the weapon to the frame elements
	currentWeaponFrame.Icon.Image = weapon.TextureId
	currentWeaponFrame.AmmoStackFrame.CurrentAmmoTextLabel.Text = weapon:GetAttribute("CurrentAmmo")
	currentWeaponFrame.AmmoStackFrame.TotalAmmoTextLabel.Text = weapon:GetAttribute("TotalAmmo")
	--Connect to the weapon's attribute changed event
	weapon:GetAttributeChangedSignal("CurrentAmmo"):Connect(function()
		currentWeaponFrame.AmmoStackFrame.CurrentAmmoTextLabel.Text = weapon:GetAttribute("CurrentAmmo")
	end)
	weapon:GetAttributeChangedSignal("TotalAmmo"):Connect(function()
		currentWeaponFrame.AmmoStackFrame.TotalAmmoTextLabel.Text = weapon:GetAttribute("TotalAmmo")
	end)
end

function HUDWidget:HideWeaponInfo()
	local currentWeaponFrameTween = TweenService:Create(
		currentWeaponFrame,
		TWEEN_INFO,
		{ Position = UDim2.fromScale(currentWeaponFrame.Position.X.Scale, 1.5) }
	)
	currentWeaponFrameTween:Play()
end

return HUDWidget:Initialize()
