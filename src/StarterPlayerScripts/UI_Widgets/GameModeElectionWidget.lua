local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local Assets = ReplicatedStorage.Assets

--Widget
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
local WeaponPreviewWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponPreviewWidget)
--Main
local GameModeElectionWidget = {}
local gameModeElectionGui
--Variables
local timeLeftTextLabel
local gamemodesFrame
local mapsFrame
local closeButton
local inventoryTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
local hideMinimizedFrameTween

function GameModeElectionWidget:Initialize()
	--Mount inventory widget
	local player = game.Players.LocalPlayer
	gameModeElectionGui = Assets.GuiObjects.ScreenGuis.GameModeElectionGui
	gamemodesFrame = gameModeElectionGui.MainFrame.GamemodesFrame
	mapsFrame = gameModeElectionGui.MainFrame.MapsFrame
	closeButton = gameModeElectionGui.MainFrame.CloseButton
	gameModeElectionGui.Enabled = false
	gameModeElectionGui.Parent = player.PlayerGui
	--Hide components by group transparency

	
	timeLeftTextLabel = gameModeElectionGui.MainFrame.TimeLeftTextLabel
	--Connect the close button
	hideMinimizedFrameTween =
		TweenService:Create(gameModeElectionGui.MinimizedFrame, TweenInfo.new(0.69), { GroupTransparency = 1 })
	closeButton.Activated:Connect(function()
		ButtonWidget:OnActivation(closeButton, function()
			self:MinimizeElectionFrame()
		end)
	end)
	gameModeElectionGui.MinimizedFrame.button.Activated:Connect(function()
		ButtonWidget:OnActivation(gameModeElectionGui.MinimizedFrame, function()
			self:ShowElectionFrame()
			hideMinimizedFrameTween:Play()
		end)
	end)
	return GameModeElectionWidget
end

function GameModeElectionWidget:hideMinimizedFrame()
	
end

function GameModeElectionWidget:ShowElectionFrame()
	TweenService:Create(gameModeElectionGui.MainFrame, TweenInfo.new(0.69), { GroupTransparency = 0 }):Play()
end

function GameModeElectionWidget:HideElectionFrame()
	TweenService:Create(gameModeElectionGui.MainFrame, TweenInfo.new(0.69), { GroupTransparency = 1 }):Play()
end

function GameModeElectionWidget:MinimizeElectionFrame()
	self:HideElectionFrame()
	TweenService:Create(gameModeElectionGui.MinimizedFrame, TweenInfo.new(0.69), { GroupTransparency = 0 }):Play()
end

function GameModeElectionWidget:OpenElectionFrame(timeToVote)
	--Enable gui
	gameModeElectionGui.Enabled = true
	if not self.GamemodeService then
		--Get services and controllers needed
		self.GamemodeService = Knit.GetService("GameModeService")
	end
	if not self.UIController then
		self.UIController = Knit.GetController("UIController")
	end
	if self.UIController.MainMenuWidget then
		if self.UIController.MainMenuWidget.active then
			self:ShowElectionFrame()
		else
			self:MinimizeElectionFrame()
		end
	else
		hideMinimizedFrameTween:Play()
		self:ShowElectionFrame()	
	end
	--Connect the buttons
	for index, child in gamemodesFrame:GetChildren() do
		if child:IsA("TextButton") then
			child.Activated:Connect(function()
				self.GamemodeService:VoteGameMode(child:GetAttribute("GameMode"))
			end)
		end
	end

	for index, child in mapsFrame:GetChildren() do
		if child:IsA("Frame") then
			child:FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("ImageButton").Activated:Connect(function()
				self.GamemodeService:VoteMap(child:GetAttribute("MapID"))
			end)
		end
	end
	--Update the time to vote
	for i = timeToVote - 2, 0, -1 do
		if i == 1 then
			timeLeftTextLabel.Text = string.format("VOTING GAME MODE: %s SECOND LEFT", tostring(i))
		elseif i == 0 then
			timeLeftTextLabel.Text = "Starting game..."
		else
			timeLeftTextLabel.Text = string.format("VOTING GAME MODE: %s SECONDS LEFT", tostring(i))
		end
		task.wait(1)
	end

	self:CloseElectionFrame()
end

local function splitTitleCaps(str)
	str = str:gsub("(%u)", " %1")
	return str:gsub("^%s", "")
end

local function resetGameModesButtons()
	for index, child in gamemodesFrame:GetChildren() do
		if child:IsA("TextButton") and child:GetAttribute("GameMode") then
			child.Text = splitTitleCaps(child:GetAttribute("GameMode"))
		end
	end
end

local function resetMapButtons()
	for index, child in mapsFrame:GetChildren() do
		if child:IsA("Frame") then
			child:FindFirstChildWhichIsA("Frame").VotesTextLabel.Text = "VOTES (0)"
		end
	end
end

function GameModeElectionWidget:UpdateVotes(votes: table, typeOfVotes: string)
	if typeOfVotes == "Map" then
		for mapName, voteCount in votes do
			self:UpdateMapVotes(mapName, voteCount)
		end
	end
	if typeOfVotes == "GameMode" then
		--Reset the vote count to make sure it's not showing the old votes
		resetGameModesButtons()
		for gameModeName, voteCount in votes do
			self:UpdateGameModeVoteCount(gameModeName, voteCount)
		end
	end
end

function GameModeElectionWidget:UpdateMapVotes(mapName: string, voteCount)
	local mapFrame = mapsFrame:FindFirstChild(mapName)
	if mapFrame then
		mapFrame:FindFirstChildWhichIsA("Frame").VotesTextLabel.Text = string.format("VOTES (%s)", voteCount)
	end
end

function GameModeElectionWidget:UpdateGameModeVoteCount(gameModeName: string, voteCount: number)
	local gameModeTextButton = gamemodesFrame:FindFirstChild(gameModeName .. "Button")
	if gameModeTextButton then
		gameModeTextButton.Text = splitTitleCaps(gameModeName) .. string.format(" (%s)", tostring(voteCount))
	end
end

function GameModeElectionWidget:CloseElectionFrame(timeToBVote)
	local minimizedTween =
		TweenService:Create(gameModeElectionGui.MinimizedFrame, TweenInfo.new(0.33), { GroupTransparency = 1 })
	minimizedTween:Play()
	self:HideElectionFrame()
	minimizedTween.Completed:Connect(function(playbackState)
		gameModeElectionGui.Enabled = false
		resetGameModesButtons()
		resetMapButtons()
	end)
end

return GameModeElectionWidget:Initialize()
