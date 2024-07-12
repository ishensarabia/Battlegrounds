--Services
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
local UserInputTypeSystemModule = require(ReplicatedStorage.Source.Modules.Util.UserInputTypeSystemModule)
--Widgets
local LoadoutWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.LoadoutWidget)
local BattlepassWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.BattlepassWidget)
local ChallengesWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ChallengesWidget)
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
local RespawnWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.RespawnWidget)
local StoreWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.StoreWidget)
--Configurations
local LevelsConfig = require(ReplicatedStorage.Source.Configurations.LevelsConfig)

--Main
local MainMenuWidget = {}
local MainMenuGui
--Variables
local playerPreviewViewportFrame
local mainFrame
--UI Objects
local PlayButton
local CharacterCanvas
local LevelFrame

--Enums
local CurrenciesEnum = require(ReplicatedStorage.Source.Enums.CurrenciesEnum)

local leftSideButtonsFrame
local rightSideButtonsFrame
--Constants
local ACTION_PLAY = "Play"
--Controllers
local WidgetController = Knit.GetController("WidgetController")

local Prestiges = require(ReplicatedStorage.Source.Assets.Prestiges)

--Connections
local userInputConnection

--Assets
local InputIcons = require(ReplicatedStorage.Source.Assets.Icons.InputIcons)

local function Spawn()
	MainMenuWidget:CloseMenu()
	game.Lighting.Blur.Enabled = false
	Knit.GetController("MenuController"):Play()
end

local function PlayAction(actionName: string, inputState: InputObject, _inputObject: InputObject)
	if actionName == ACTION_PLAY and inputState == Enum.UserInputState.Begin then
		if MainMenuWidget.isActive and Knit.GetController("GameModeController")._canRespawn then
			PlayButton:OnActivation(Spawn)
		end
	end
end

local function ShowMenu()
	--Connect the context action service
	ContextActionService:BindAction(ACTION_PLAY, PlayAction, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonY)
	if not MainMenuGui.Enabled then
		MainMenuGui.Enabled = true
	end
	CharacterCanvas.Visible = true
	local leftSideButtonsFrameTween = TweenService:Create(
		leftSideButtonsFrame,
		TweenInfo.new(0.325),
		{ Position = leftSideButtonsFrame:GetAttribute("ShowPosition") }
	)
	local rightSideButtonsFrameTween = TweenService:Create(
		rightSideButtonsFrame,
		TweenInfo.new(0.325),
		{ Position = rightSideButtonsFrame:GetAttribute("ShowPosition") }
	)

	local playerPreviewTween = TweenService:Create(CharacterCanvas, TweenInfo.new(0.325), { GroupTransparency = 0 })

	local mainFrameTween = TweenService:Create(mainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0, 0) })

	mainFrameTween:Play()

	leftSideButtonsFrameTween:Play()
	rightSideButtonsFrameTween:Play()
	if Knit.GetController("GameModeController")._canRespawn then
		MainMenuWidget:ShowPlayButton()
	else
		MainMenuWidget:HidePlayButton()
	end
	mainFrameTween.Completed:Connect(function()
		playerPreviewTween:Play()
	end)
	game.Lighting.Blur.Enabled = true
end

function MainMenuWidget:HideMenu()
	self.isActive = false
	local leftSideButtonsFrameTween = TweenService:Create(
		MainMenuGui.LeftSideButtonsFrame,
		TweenInfo.new(0.325),
		{ Position = leftSideButtonsFrame:GetAttribute("HidePosition") }
	)
	local rightSideButtonsFrameTween = TweenService:Create(
		MainMenuGui.RightSideButtonsFrame,
		TweenInfo.new(0.325),
		{ Position = rightSideButtonsFrame:GetAttribute("HidePosition") }
	)
	local playerPreviewTween = TweenService:Create(CharacterCanvas, TweenInfo.new(0.325), { GroupTransparency = 1 })
	playerPreviewTween.Completed:Connect(function()
		CharacterCanvas.Visible = false
	end)
	playerPreviewTween:Play()
	rightSideButtonsFrameTween:Play()
	leftSideButtonsFrameTween:Play()
	self:HidePlayButton()
end

function MainMenuWidget:CloseMenu()
	ContextActionService:UnbindAction(ACTION_PLAY)
	self.isActive = false

	local mainFrameTween =
		TweenService:Create(mainFrame, TweenInfo.new(0.325), { Position = mainFrame:GetAttribute("HidePosition") })

	local leftSideButtonsFrameTween = TweenService:Create(
		MainMenuGui.LeftSideButtonsFrame,
		TweenInfo.new(0.325),
		{ Position = leftSideButtonsFrame:GetAttribute("HidePosition") }
	)

	local rightSideButtonsFrameTween = TweenService:Create(
		MainMenuGui.RightSideButtonsFrame,
		TweenInfo.new(0.325),
		{ Position = rightSideButtonsFrame:GetAttribute("HidePosition") }
	)

	local playerPreviewTween = TweenService:Create(CharacterCanvas, TweenInfo.new(0.325), { GroupTransparency = 1 })

	mainFrameTween:Play()
	playerPreviewTween:Play()
	rightSideButtonsFrameTween:Play()
	leftSideButtonsFrameTween:Play()
	self:ShowPlayButton()

	MainMenuGui.Enabled = false
end

function MainMenuWidget:HidePlayButton()
	--Change the play the button group transparency
	local playButtonTween =
		--Get the parent as it is the canvas group
		TweenService:Create(PlayButton.instance.Parent, TweenInfo.new(0.325), { GroupTransparency = 1 })
	playButtonTween:Play()


	playButtonTween.Completed:Connect(function()
		PlayButton.instance.Active = false
	end)
end

function MainMenuWidget:ShowPlayButton()
	if self.isActive then
		PlayButton.instance.Active = true
		local playButtonTween =
			--Get the parent as it is the canvas group
			TweenService:Create(PlayButton.instance.Parent, TweenInfo.new(0.325), { GroupTransparency = 0 })
		playButtonTween:Play()
	end
end

function MainMenuWidget:ShowMenu()
	self.isActive = true
	ShowMenu()
end

local function setupMainMenuButtons()
	ButtonWidget.new(MainMenuGui.RightSideButtonsFrame.LoadoutButtonFrame, function()
		MainMenuWidget:HideMenu()
		LoadoutWidget:OpenLoadout(function()
			MainMenuWidget:ShowMenu()
		end)
	end)
	ButtonWidget.new(MainMenuGui.RightSideButtonsFrame.StoreButtonFrame, function()
		MainMenuWidget:HideMenu()
		StoreWidget:OpenStore("DailyItems", function()
			MainMenuWidget:ShowMenu()
		end)
	end)
	ButtonWidget.new(MainMenuGui.LeftSideButtonsFrame.BattlepassButtonFrame, function()
		MainMenuWidget:HideMenu()
		BattlepassWidget:OpenBattlepass(function()
			MainMenuWidget:ShowMenu()
		end)
	end)
	ButtonWidget.new(MainMenuGui.LeftSideButtonsFrame.ChallengesButtonFrame, function()
		ChallengesWidget:OpenChallenges()
	end)

	PlayButton = ButtonWidget.new(MainMenuGui.SpawnButtonCanvas.SpawnButton, Spawn)
end

function MainMenuWidget:InitializeCameraTransition()
	local CameraController = Knit.GetController("CameraController")
	CameraController.isInMenu = true

	-- Get the cutscene points from the server
	Knit.GetService("MenuService"):GetCutscenePoints():andThen(function(cutscenePoints)
		workspace.CurrentCamera.CFrame = cutscenePoints.StartingCamera
		task.spawn(function()
			CameraController:TransitionBetweenPoints(cutscenePoints)
		end)
		return cutscenePoints
	end)
end

function MainMenuWidget:UpdateCurrencyValue(currencyName, currencyValue)
	if currencyName == CurrenciesEnum.BattleCoinsthen then
		WidgetController:AnimateDigitsForTextLabel(mainFrame.BattleCoinsFrame.AmountLabel, currencyValue, 0.5)
	elseif currencyName == CurrenciesEnum.BattleGems then
		WidgetController:AnimateDigitsForTextLabel(mainFrame.BattleGemsFrame.AmountLabel, currencyValue, 0.5)
	end
end

function MainMenuWidget:Initialize()
	--Connect the context action service
	ContextActionService:BindAction(ACTION_PLAY, PlayAction, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonY)
	--Set up environment for main menu
	game.Lighting.Blur.Enabled = true
	self.isActive = true
	--Mount main menu widget
	local player = game.Players.LocalPlayer
	local PlayerGui = player.PlayerGui
	MainMenuGui = Assets.GuiObjects.ScreenGuis.MainMenuGui
	mainFrame = MainMenuGui.MainFrame
	MainMenuGui.Parent = player.PlayerGui
	--Get references to gui objects
	leftSideButtonsFrame = MainMenuGui.LeftSideButtonsFrame
	rightSideButtonsFrame = MainMenuGui.RightSideButtonsFrame
	CharacterCanvas = PlayerGui.MainMenuGui.CharacterCanvas
	LevelFrame = CharacterCanvas.LevelFrame
	--Set up level frame
	LevelFrame.ProgressCircleFrame.LevelTextLabel.Text = player:GetAttribute("Level") or "Loading..."
	--Connect attribute change
	player:GetAttributeChangedSignal("Level"):Connect(function()
		LevelFrame.ProgressCircleFrame.LevelTextLabel.Text = player:GetAttribute("Level")
		if player:GetAttribute("Level") == LevelsConfig.LEVEL_TO_PRESTIGE then
			CharacterCanvas.PrestigeFrame.Visible = true
			--Create the presige buttton
			ButtonWidget.new(CharacterCanvas.PrestigeFrame, function()
				self:HideMenu()
				WidgetController.PrestigeWidget:OpenPrestige()
			end)
		else
			CharacterCanvas.PrestigeFrame.Visible = false
		end
	end)
	player:GetAttributeChangedSignal("Prestige"):Connect(function()
		if player:GetAttribute("Prestige") > 0 then
			LevelFrame.ProgressCircleFrame.PrestigeIcon.Visible = true
			LevelFrame.ProgressCircleFrame.PrestigeIcon.Image = Prestiges[player:GetAttribute("Prestige")].icon
		else
			LevelFrame.ProgressCircleFrame.PrestigeIcon.Visible = false
		end		
	end)
	player:GetAttributeChangedSignal("Experience"):Connect(function()
		if self.isActive then
			local experience = player:GetAttribute("Experience")
			local experienceToNextLevel = player:GetAttribute("ExperienceToLevelUp")
			local progress
			--If the player has no experience to next level, set the progress to 1
			if not experienceToNextLevel then
				progress = 1
			else
				progress = experience / experienceToNextLevel
			end
			local rotation = math.floor(math.clamp(progress, 0, 1) * 360)
			local ProgressCircleFrame = LevelFrame.ProgressCircleFrame
			local leftCircle = ProgressCircleFrame.Left.Frame.UIGradient
			local rightCircle = ProgressCircleFrame.Right.Frame.UIGradient
			local justLeveledUp = false

			-- Check if the player has just leveled up
			if experienceToNextLevel and experience >= experienceToNextLevel then
				-- Calculate the remaining experience and the progress for the next level
				local remainingExperience = experience - experienceToNextLevel
				local nextLevelExperience = player:GetAttribute("ExperienceToNextLevel")
				--if there's no experience to next level, means the player is max level, so set the progress to 1
				if not nextLevelExperience then
					progress = 1
				else
					progress = remainingExperience / nextLevelExperience
				end

				rotation = math.floor(math.clamp(progress, 0, 1) * 360)
				justLeveledUp = true
			end

			WidgetController:TweenProgressCircle(leftCircle, rightCircle, rotation, justLeveledUp)
		end
	end)

	--Setup buttons
	setupMainMenuButtons()
	self:HidePlayButton()

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
		if currencyName == CurrenciesEnum.BattleCoins then
			WidgetController:AnimateDigitsForTextLabel(battleCoinsFrame.AmountLabel, newCurrencyValue, 100)
		elseif currencyName == CurrenciesEnum.BattleGems then
			WidgetController:AnimateDigitsForTextLabel(battleGemsFrame.AmountLabel, newCurrencyValue, 100)
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

	if not Knit.GetController("GameModeController")._canRespawn then
		self:HidePlayButton()
	end
	--Connect to death event
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			if not self.isActive and not Knit.GetController("MenuController").isInMenu then
				RespawnWidget:ShowWidget()
			end
		end)
	end)

	userInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		PlayButton.instance.InputIcon.Visible = true
		if UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "KeyboardAndMouse" then
			PlayButton.instance.InputIcon.Image = InputIcons.PC.Space
		elseif UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Gamepad" then
			if UserInputTypeSystemModule.gamepadType == "PlayStation" then
				PlayButton.instance.InputIcon.Image = InputIcons.PS.TriangleButton
			elseif UserInputTypeSystemModule.gamepadType == "Xbox" then
				PlayButton.instance.InputIcon.Image = InputIcons.Xbox.YButton
			end
		elseif UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Touch" then
			PlayButton.instance.InputIcon.Visible = false
		end
	end)

	return self
end

return MainMenuWidget:Initialize()
