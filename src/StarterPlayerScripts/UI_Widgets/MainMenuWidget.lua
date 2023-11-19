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
local MainMenuWidget = {}
local MainMenuGui
--Variables
local characterCanvas
local playerPreviewViewportFrame
local inventoryButtonsFrame
local battlepassButtonFrame
local challengesButtonFrame
local storeButtonFrame
local levelText
local mainFrame
local playButton
local cameraTransitionConn
--Constants
local DEFAULT_CATEGORY = "Firearms"

function MainMenuWidget:HideMenu()
	self.active = false
	local inventoryButtonsFrameTween =
		TweenService:Create(inventoryButtonsFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(2, 0.3) })

	local playerPreviewTween =
		TweenService:Create(characterCanvas, TweenInfo.new(0.325), { Position = UDim2.fromScale(2, 0.071) })

	local battlepassButtonTween =
		TweenService:Create(battlepassButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(2, 0.64) })

	local challengesButtonTween =
		TweenService:Create(challengesButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(2, 0.41) })

	local storeButtonTween =
		TweenService:Create(storeButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(2, 0.312) })

	storeButtonTween:Play()
	challengesButtonTween:Play()
	inventoryButtonsFrameTween:Play()
	self:HidePlayButton()
	playerPreviewTween:Play()
	battlepassButtonTween:Play()
end

function MainMenuWidget:CloseMenu()
	self.active = false

	local inventoryButtonsFrameTween =
		TweenService:Create(inventoryButtonsFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.3) })

	local playerPreviewTween =
		TweenService:Create(characterCanvas, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0) })

	local mainFrameTween = TweenService:Create(mainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0) })

	local battlepassButtonTween =
		TweenService:Create(battlepassButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.781) })

	local challengesButtonTween =
		TweenService:Create(challengesButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.41) })

	local storeButtonTween =
		TweenService:Create(storeButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.312) })

	storeButtonTween:Play()
	challengesButtonTween:Play()
	mainFrameTween:Play()
	inventoryButtonsFrameTween:Play()
	self:ShowPlayButton()
	playerPreviewTween:Play()
	battlepassButtonTween:Play()
	battlepassButtonTween.Completed:Connect(function(playbackState)
		MainMenuGui.Enabled = false
	end)
end

function MainMenuWidget:HidePlayButton()
	--Change the play the button group transparency
	local playButtonTween =
		--Get the parent as it is the canvas group
		TweenService:Create(playButton.Parent, TweenInfo.new(0.325), { GroupTransparency = 1 })
	playButtonTween:Play()
	playButton.Active = false
end

function MainMenuWidget:ShowPlayButton()
	if self.active then
		local playButtonTween =
			--Get the parent as it is the canvas group
			TweenService:Create(playButton.Parent, TweenInfo.new(0.325), { GroupTransparency = 0 })
		playButtonTween:Play()
		playButton.Active = true
	end
end

local function ShowMenu()
	if not MainMenuGui.Enabled then
		MainMenuGui.Enabled = true
	end
	local inventoryButtonsFrameTween =
		TweenService:Create(inventoryButtonsFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0.87, 0.3) })

	local playerPreviewTween =
		TweenService:Create(characterCanvas, TweenInfo.new(0.325), { Position = UDim2.fromScale(0.175, 0.071) })

	local mainFrameTween = TweenService:Create(mainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0, 0) })

	mainFrameTween:Play()
	local battlepassButtonTween = TweenService:Create(
		battlepassButtonFrame,
		TweenInfo.new(0.325),
		{ Position = battlepassButtonFrame:GetAttribute("TargetPosition") }
	)

	local challengesButtonTween = TweenService:Create(
		challengesButtonFrame,
		TweenInfo.new(0.325),
		{ Position = challengesButtonFrame:GetAttribute("TargetPosition") }
	)

	local StoreButtonTween = TweenService:Create(
		storeButtonFrame,
		TweenInfo.new(0.325),
		{ Position = storeButtonFrame:GetAttribute("TargetPosition") }
	)

	StoreButtonTween:Play()
	challengesButtonTween:Play()
	inventoryButtonsFrameTween:Play()
	if Knit.GetController("GameModeController")._canRespawn then
		MainMenuWidget:ShowPlayButton()
	else
		MainMenuWidget:HidePlayButton()
	end
	playerPreviewTween:Play()
	battlepassButtonTween:Play()
	game.Lighting.Blur.Enabled = true
end

function MainMenuWidget:ShowMenu()
	self.active = true
	ShowMenu()
end

local function setupMainMenuButtons()
	local weaponsInventoryButtonFrame = MainMenuGui.InventoryButtonsFrame.WeaponsButtonFrame.ButtonFrame
	local abilitiesInventoryButtonFrame = MainMenuGui.InventoryButtonsFrame.AbilitiesButtonFrame.ButtonFrame
	--Init button variables
	inventoryButtonsFrame = MainMenuGui.InventoryButtonsFrame
	playButton = MainMenuGui.PlayButtonCanvas.PlayButton
	battlepassButtonFrame = MainMenuGui.BattlepassButtonFrame
	challengesButtonFrame = MainMenuGui.ChallengesButtonFrame
	levelText = MainMenuGui.CharacterCanvas.LevelFrame.LevelIcon:FindFirstChildWhichIsA("TextLabel")
	levelText.Text = game.Players.LocalPlayer:GetAttribute("Level") or 0
	storeButtonFrame = MainMenuGui.StoreButtonFrame
	characterCanvas = MainMenuGui.CharacterCanvas

	weaponsInventoryButtonFrame.button.Activated:Connect(function()
		local function callback()
			MainMenuWidget:HideMenu()
			LoadoutWidget:OpenLoadout(function()
				MainMenuWidget:ShowMenu()
			end)
		end
		ButtonWidget:OnActivation(weaponsInventoryButtonFrame, callback)
	end)
	abilitiesInventoryButtonFrame.button.Activated:Connect(function()
		local function callback()
			MainMenuWidget:HideMenu()
			LoadoutWidget:OpenLoadout(function()
				MainMenuWidget:ShowMenu()
			end)
		end
		ButtonWidget:OnActivation(abilitiesInventoryButtonFrame, callback)
	end)

	--Battlepass button
	battlepassButtonFrame.button.Activated:Connect(function()
		local function callback()
			MainMenuWidget:HideMenu()
			BattlepassWidget:OpenBattlepass(function()
				MainMenuWidget:ShowMenu()
			end)
		end
		ButtonWidget:OnActivation(battlepassButtonFrame, callback)
	end)

	--Challenges button
	challengesButtonFrame.button.Activated:Connect(function()
		local function callback()
			ChallengesWidget:OpenChallenges()
		end
		ButtonWidget:OnActivation(challengesButtonFrame, callback)
	end)
	--Store button
	storeButtonFrame.button.Activated:Connect(function()
		local function callback()
			MainMenuWidget:HideMenu()
			StoreWidget:OpenStore("Crates", function()
				MainMenuWidget:ShowMenu()
			end)
		end
		ButtonWidget:OnActivation(storeButtonFrame, callback)
	end)

	playButton.Activated:Connect(function()
		local function callback()
			MainMenuWidget:CloseMenu(ShowMenu)
			game.Lighting.Blur.Enabled = false
			Knit.GetController("MenuController"):Play()
		end
		ButtonWidget:OnActivation(playButton.Parent, callback)
	end)
end

function MainMenuWidget:InitializeCameraTransition()
	local CameraController = Knit.GetController("CameraController")
	CameraController.isInMenu = true
	--Set up main menu cutscene
	local currentMap = workspace:WaitForChild("Map")
	local cutscenePoints = currentMap.Cutscene
	workspace.CurrentCamera.CFrame = cutscenePoints.StartingCamera.CFrame
	task.spawn(function()
		CameraController:TransitionBetweenPoints(cutscenePoints)
	end)
end

function MainMenuWidget:Initialize()
	self.active = true
	--Set up environment for main menu
	game.Lighting.Blur.Enabled = true
	--Mount main menu widget
	local player = game.Players.LocalPlayer
	local PlayerGui = player.PlayerGui
	MainMenuGui = Assets.GuiObjects.ScreenGuis.MainMenuGui
	mainFrame = MainMenuGui.MainFrame
	MainMenuGui.Parent = player.PlayerGui

	local battleCoinsFrame = mainFrame.BattleCoinsFrame
	local battleGemsFrame = mainFrame.BattleGemsFrame
	playerPreviewViewportFrame = PlayerGui.MainMenuGui.CharacterCanvas.ViewportFrame
	--Set up currencies
	local currencyService = Knit.GetService("CurrencyService")
	currencyService:GetCurrencyValue("BattleCoins"):andThen(function(currencyValue)
		--format currency value
		currencyValue = FormatText.To_comma_value(currencyValue)
		battleCoinsFrame.AmountLabel.Text = currencyValue
	end)
	currencyService:GetCurrencyValue("BattleGems"):andThen(function(currencyValue)
		--format currency value
		currencyValue = FormatText.To_comma_value(currencyValue)
		battleGemsFrame.AmountLabel.Text = currencyValue
	end)
	--Connect to currency updates
	currencyService.CurrencyChanged:Connect(function(currencyName, newCurrencyValue)
		--format currency value
		newCurrencyValue = FormatText.To_comma_value(newCurrencyValue)
		if currencyName == "BattleCoins" then
			battleCoinsFrame.AmountLabel.Text = newCurrencyValue
		elseif currencyName == "BattleGems" then
			battleGemsFrame.AmountLabel.Text = newCurrencyValue
		end
	end)
	self:InitializeCameraTransition()
	--Set up player preview
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = playerPreviewViewportFrame
	local playerCharacter = ReplicatedStorage.Assets.Models.Dummy:Clone()
	playerCharacter.Parent = workspace
	local playerDesc
	local success, errorMessage = pcall(function()
		playerDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if playerDesc and success then
		playerCharacter:WaitForChild("Humanoid"):ApplyDescription(playerDesc)
	end
	playerCharacter.Parent = worldModel
	worldModel.PrimaryPart = playerCharacter.HumanoidRootPart
	local camera = Instance.new("Camera")
	camera.Parent = MainMenuGui
	local dtrViewportFrame = DragToRotateViewportFrame.New(playerPreviewViewportFrame, camera)
	dtrViewportFrame:SetModel(worldModel)
	dtrViewportFrame.MouseMode = "Default"

	local viewportConnection = playerPreviewViewportFrame.InputBegan:Connect(function(inputObject)
		if
			inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch
		then
			dtrViewportFrame:BeginDragging()

			inputObject.Changed:Connect(function()
				if inputObject.UserInputState == Enum.UserInputState.End then
					dtrViewportFrame:StopDragging()
				end
			end)
		end
	end)
	playerPreviewViewportFrame.CurrentCamera = camera
	--Activate controller
	local PlayerPreviewController = Knit.GetController("PlayerPreviewController")
	task.spawn(function()
		PlayerPreviewController:SpawnWeaponInCharacterMenu()
	end)

	setupMainMenuButtons()
	if not Knit.GetController("GameModeController")._canRespawn then
		self:HidePlayButton()
	end
	--Connect to death event
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			if not self.active and not Knit.GetController("MenuController").isInMenu then
				RespawnWidget:Initialize(ShowMenu)
			end
		end)
	end)
	return self
end



return MainMenuWidget:Initialize()
