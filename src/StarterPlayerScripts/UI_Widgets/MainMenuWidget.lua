--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Widgets
local InventoryWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.InventoryWidget)
local BattlepassWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.BattlepassWidget)
local ChallengesWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ChallengesWidget)
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
local RespawnWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.RespawnWidget)
--Main
local MainMenuWidget = {}
local MainMenuGui
--Variables
local playerPreviewViewportFrame
local inventoryButtonsFrame
local battlepassButtonFrame
local challengesButtonFrame
local mainFrame
local playButton
local active = true
--Constants
local DEFAULT_CATEGORY = "Firearms"

function MainMenuWidget:HideMenu()
	local inventoryButtonsFrameTween =
		TweenService:Create(inventoryButtonsFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.3) })
	local playButtonTween =
		TweenService:Create(playButton, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.781) })
	local playerPreviewTween =
		TweenService:Create(playerPreviewViewportFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0) })
	local battlepassButtonTween =
		TweenService:Create(battlepassButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.64) })
	local challengesButtonTween =
		TweenService:Create(challengesButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.41) })
	challengesButtonTween:Play()
	inventoryButtonsFrameTween:Play()
	playButtonTween:Play()
	playerPreviewTween:Play()
	battlepassButtonTween:Play()
end

function MainMenuWidget:CloseMenu()
	local inventoryButtonsFrameTween =
		TweenService:Create(inventoryButtonsFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.3) })
	local playButtonTween =
		TweenService:Create(playButton, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.781) })
	local playerPreviewTween =
		TweenService:Create(playerPreviewViewportFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0) })
	local mainFrameTween = TweenService:Create(mainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0) })
	local battlepassButtonTween =
		TweenService:Create(battlepassButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.781) })
	local challengesButtonTween =
		TweenService:Create(challengesButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(1, 0.41) })
	challengesButtonTween:Play()
	mainFrameTween:Play()
	inventoryButtonsFrameTween:Play()
	playButtonTween:Play()
	playerPreviewTween:Play()
	battlepassButtonTween:Play()
end

local function ShowMenu()
	local inventoryButtonsFrameTween =
		TweenService:Create(inventoryButtonsFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0.87, 0.3) })
	local playButtonTween =
		TweenService:Create(playButton, TweenInfo.new(0.325), { Position = UDim2.fromScale(0.411, 0.781) })
	local playerPreviewTween =
		TweenService:Create(playerPreviewViewportFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0.026, 0) })
	local mainFrameTween = TweenService:Create(mainFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0, 0) })
	mainFrameTween:Play()
	local battlepassButtonTween =
		TweenService:Create(battlepassButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0.042, 0.64) })
	local challengesButtonTween =
		TweenService:Create(challengesButtonFrame, TweenInfo.new(0.325), { Position = UDim2.fromScale(0.042, 0.41) })
	challengesButtonTween:Play()
	inventoryButtonsFrameTween:Play()
	playButtonTween:Play()
	playerPreviewTween:Play()
	battlepassButtonTween:Play()
	active = true
	game.Lighting.Blur.Enabled = true
end

local function setupMainMenuButtons()
	local weaponsInventoryButtonFrame = MainMenuGui.InventoryButtonsFrame.WeaponsButtonFrame.ButtonFrame
	local abilitiesInventoryButtonFrame = MainMenuGui.InventoryButtonsFrame.AbilitiesButtonFrame.ButtonFrame
	--Init button variables
	inventoryButtonsFrame = MainMenuGui.InventoryButtonsFrame
	playButton = MainMenuGui.PlayButton
	battlepassButtonFrame = MainMenuGui.BattlepassButtonFrame
	challengesButtonFrame = MainMenuGui.ChallengesButtonFrame

	weaponsInventoryButtonFrame.button.Activated:Connect(function()
		local function callback()
			MainMenuWidget:HideMenu()
			InventoryWidget:OpenInventory("Weapons", ShowMenu, DEFAULT_CATEGORY)
		end
		ButtonWidget:OnActivation(weaponsInventoryButtonFrame, callback)
	end)
	abilitiesInventoryButtonFrame.button.Activated:Connect(function()
		local function callback()
			MainMenuWidget:HideMenu()
			InventoryWidget:OpenInventory("Abilities", ShowMenu)
		end
		ButtonWidget:OnActivation(abilitiesInventoryButtonFrame, callback)
	end)

	--Battlepass button
	battlepassButtonFrame.button.Activated:Connect(function()
		local function callback()
			MainMenuWidget:HideMenu()
			BattlepassWidget:OpenBattlepass(ShowMenu)
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

	playButton.Activated:Connect(function()
		local function callback()
			MainMenuWidget:CloseMenu()
			active = false
			game.Lighting.Blur.Enabled = false
			Knit.GetController("MenuController"):Play()
		end
		ButtonWidget:OnActivation(playButton, callback)
	end)
end
function MainMenuWidget:Initialize()
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
	local CameraController = Knit.GetController("CameraController")
	--Set up currencies
	local currencyService = Knit.GetService("CurrencyService")
	currencyService:GetCurrencyValue("BattleCoins"):andThen(function(currencyValue)
		battleCoinsFrame.AmountLabel.Text = currencyValue
	end)
	currencyService:GetCurrencyValue("BattleGems"):andThen(function(currencyValue)
		battleGemsFrame.AmountLabel.Text = currencyValue
	end)
	--Connect to currency updates
	currencyService.CurrencyChanged:Connect(function(currencyName, newCurrencyValue)
		if currencyName == "BattleCoins" then
			battleCoinsFrame.AmountLabel.Text = newCurrencyValue
		elseif currencyName == "BattleGems" then
			battleGemsFrame.AmountLabel.Text = newCurrencyValue
		end
	end)

	--Set up main menu cutscene
	local currentArenaInstance = workspace:WaitForChild("Arena")
	local cutscenePoints = currentArenaInstance.Cutscene
	workspace.CurrentCamera.CFrame = currentArenaInstance.StartingCamera.CFrame
	CameraController.isInMenu = true
	task.spawn(function()
		while active do
			CameraController:TransitionBetweenPoints(cutscenePoints)
		end
	end)

	--Set up respawn menu
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function() end)
	end)
	--Set up player preview
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = playerPreviewViewportFrame
	local dummy = ReplicatedStorage.Assets.Models.Dummy:Clone()
	dummy.Parent = workspace
	-- if not RunService:IsStudio() then
	local playerDesc
	local success, errorMessage = pcall(function()
		playerDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if playerDesc and success then
		dummy:WaitForChild("Humanoid"):ApplyDescription(playerDesc)
	end
	-- end
	dummy.Parent = worldModel
	local camera = Instance.new("Camera")
	camera.Parent = MainMenuGui
	camera.CFrame = (dummy.PrimaryPart.CFrame + Vector3.new(0, 0, 7.3)) * CFrame.Angles(0, math.rad(40), 0)
	--Align character to face camera
	dummy:SetPrimaryPartCFrame(dummy.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-180), 0))
	playerPreviewViewportFrame.CurrentCamera = camera
	--Activate controller
	local PlayerPreviewController = Knit.GetController("PlayerPreviewController")
	task.spawn(function()
		PlayerPreviewController:SpawnWeaponInCharacterMenu()
	end)

	setupMainMenuButtons()
	--Connect to death event
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			RespawnWidget:Initialize(ShowMenu)
		end)
	end)
	return true
end

return MainMenuWidget:Initialize()
