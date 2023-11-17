--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
--Main
local TimerWidget = {}
--Screen guis
local TimerGui

function TimerWidget:Initialize()
	--Initialize the screen guis
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
		TimerGui = Assets.GuiObjects.ScreenGuis.TimerGui or game.Players.LocalPlayer.PlayerGui.TimerGui
		TimerGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		TimerGui = game.Players.LocalPlayer.PlayerGui.TimerGui
	end
	TimerGui.Enabled = false

	Knit.GetService("GameModeService").InitializeGameModeSignal:Connect(function(timeToVote)
		self:StartTimer(timeToVote)
	end)
	return TimerWidget
end

function TimerWidget:StartTimer(time: number)
	if not TimerGui.Enabled then
		TimerGui.Enabled = true
	end
	--Update the time to vote
	for i = time, 0, -1 do
		--format the time to string
		local minutes = math.floor(i / 60)
		local seconds = i % 60
		local timeString = string.format("%02d:%02d", minutes, seconds)
		TimerGui.Timer.Text = timeString
		task.wait(1)
	end
    TimerGui.Enabled = false
end

return TimerWidget:Initialize()
