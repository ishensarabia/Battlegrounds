local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local Assets = ReplicatedStorage.Assets
local WeaponsIcons = require(ReplicatedStorage.Source.Assets.Icons.WeaponsIcons)
--Widget
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
local WeaponPreviewWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponPreviewWidget)
--Main
local GameModeElectionWidget = {}
local gameModeElectionGui
--Variables
local timeLeftTextLabel
local gamemodesFrame

local inventoryTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

function GameModeElectionWidget:Initialize()
	--Mount inventory widget
	local player = game.Players.LocalPlayer
	gameModeElectionGui = Assets.GuiObjects.ScreenGuis.GameModeElectionGui
	gamemodesFrame = gameModeElectionGui.GamemodesFrame
	gameModeElectionGui.Enabled = false
	gameModeElectionGui.Parent = player.PlayerGui

	timeLeftTextLabel = gameModeElectionGui.TimeLeftTextLabel

	return GameModeElectionWidget
end

function GameModeElectionWidget:OpenElectionFrame(timeToVote)
	gameModeElectionGui.Enabled = true
	--Connect the buttons
	for index, child in gamemodesFrame:GetChildren() do
		if child:IsA("TextButton") then			
			child.Activated:Connect(function()
				Knit.GetService("GameModeService"):VoteGameMode(child:GetAttribute("GameMode"))
			end)
		end
	end
	--Update the time to vote
	for i = timeToVote, 0, -1 do
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


function GameModeElectionWidget:UpdateVotes(votes : table)
	--Reset the vote count to make sure it's not showing the old votes
	resetGameModesButtons()
	for gameModeName, voteCount in (votes) do
		self:UpdateVoteCount(gameModeName, voteCount)
	end
end

function GameModeElectionWidget:UpdateVoteCount(gameModeName: string, voteCount: number)
	local gameModeTextButton = gamemodesFrame:FindFirstChild(gameModeName .. "Button")
	if gameModeTextButton then
		gameModeTextButton.Text = splitTitleCaps(gameModeName) .. string.format(" (%s)", tostring(voteCount))
	end
end


function GameModeElectionWidget:CloseElectionFrame(timeToBVote)
	gameModeElectionGui.Enabled = false
	resetGameModesButtons()
end

return GameModeElectionWidget:Initialize()
