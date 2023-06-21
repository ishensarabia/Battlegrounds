--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Services
local StoreService = Knit.GetService("StoreService")
local UIController = Knit.GetController("UIController")
--Main
local UnboxingWidget = {}
--Gui objects
local UnboxingGui
local unboxingFrame
local backgroundFrame
--Variables
local rnd = Random.new()

local tweenInfo = TweenInfo.new(0.69, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0)

local function HideGuiObjects()
	--Hide the gui objects by size for animation purposes
	unboxingFrame.Size = UDim2.fromScale(0, 0)
	backgroundFrame.Transparency = 1
end

local function ShowGuiObjects()
	if not UnboxingGui.Enabled then
		UnboxingGui.Enabled = true
	end
	--Tween the gui objects to their original size
	local unboxingFrameTween =
		TweenService:Create(unboxingFrame, tweenInfo, { Size = unboxingFrame:GetAttribute("TargetSize") })
	local backgroundFrameTween = TweenService:Create(backgroundFrame, tweenInfo, { Transparency = 0.36 })
	unboxingFrameTween:Play()
	backgroundFrameTween:Play()
	unboxingFrameTween.Completed:Wait()
end

function UnboxingWidget:Initialize(button: GuiButton, callback, customSoundName: string, params: table)
	--Initialize the screen guis
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("UnboxingGui") then
		UnboxingGui = Assets.GuiObjects.ScreenGuis.UnboxingGui or game.Players.LocalPlayer.PlayerGui.UnboxingGui
		UnboxingGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		UnboxingGui = game.Players.LocalPlayer.PlayerGui.UnboxingGui
	end

	--Initialize the gui objects
	backgroundFrame = UnboxingGui.BackgroundFrame
	UnboxingGui.Enabled = false
	unboxingFrame = UnboxingGui.UnboxingFrame

	--Hide the gui objects by size for animation purposes
	HideGuiObjects()
	--Connect signal
	StoreService.OpenCrateSignal:Connect(function(crate: table, rewardChosen: table)
		UnboxingWidget:OpenCrate(crate, rewardChosen)
	end)
	return UnboxingWidget
end

--Unboxing crates
local function tweenGraph(x, pow)
	x = math.clamp(x, 0, 1)
	return 1 - (1 - x) ^ pow
end
local function lerp(a, b, t)
	return a + (b - a) * t
end

function UnboxingWidget:OpenCrate(crate: table, rewardChosen: table)
	warn(crate, rewardChosen)
	ShowGuiObjects()
	local numItems = rnd:NextInteger(20, 100)
	local chosenPosition = rnd:NextInteger(15, numItems - 5)
	local unboxTime = rnd:NextInteger(3, 6)

	for i = 1, numItems do
		local rarityChosen = rewardChosen.Rarity
		local randomItemChosen = rewardChosen

		if i ~= chosenPosition then
			local rndChance = rnd:NextNumber() * 100
			local n = 0

			for rarity: string, chance: number in pairs(crate.RaritiesPercentages) do
				n += chance
				if rndChance <= n then
					rarityChosen = rarity
					break
				end
			end

			local unboxableItems = crate.Contents

			for i = #unboxableItems, 2, -1 do
				local j = rnd:NextInteger(1, i)
				unboxableItems[i], unboxableItems[j] = unboxableItems[j], unboxableItems[i]
			end

			for index, itemData: table in unboxableItems do
				if itemData.Rarity == rarityChosen then
					randomItemChosen = itemData
					break
				end
			end
		end

		UIController:CreateSkinFrame(randomItemChosen.Skin, randomItemChosen.Name, randomItemChosen.Rarity)
			:andThen(function(_newItemFrame)
				_newItemFrame.Parent = unboxingFrame.ItemsFrame.ItemsContainer
			end)
	end

	unboxingFrame.ItemsFrame.ItemsContainer.Position = UDim2.new(0, 0, 0.5, 0)

	local cellSize = Assets.GuiObjects.Frames.SkinTemplate.Size.X.Scale
	local padding = unboxingFrame.ItemsFrame.ItemsContainer.UIListLayout.Padding.Scale
	local pos1 = 0.5 - cellSize / 2
	local nextOffset = -cellSize - padding

	local posFinal = pos1 + (chosenPosition - 1) * nextOffset
	local rndOffset = rnd:NextNumber(-cellSize / 2, cellSize / 2)
	posFinal += rndOffset

	local timeOpened = tick()

	local pow = rnd:NextNumber(2, 10)
	local lastSlot = 0
	local heartbeatConnection

	heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		local timeSinceOpened = tick() - timeOpened
		local x = timeSinceOpened / unboxTime

		local t = tweenGraph(x, pow)
		local newXPos = lerp(0, posFinal, t)

		local currentSlot = math.abs(math.floor((newXPos + rndOffset) / cellSize)) + 1
		if currentSlot ~= lastSlot then
			Knit.GetController("AudioController"):PlaySound("tick")
			lastSlot = currentSlot
		end

		unboxingFrame.ItemsFrame.ItemsContainer.Position = UDim2.new(newXPos, 0, 0.5, 0)

		if x >= 1 then
			heartbeatConnection:Disconnect()
			unboxingFrame.ContinueButton.Visible = true
		end
	end)

	--Connect the close button
	unboxingFrame.ContinueButton.Activated:Connect(function()
		UnboxingGui.Enabled = false
		unboxingFrame.ContinueButton.Visible = false
		HideGuiObjects()
		for index, child in unboxingFrame.ItemsFrame.ItemsContainer:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
	end)
end

return UnboxingWidget:Initialize()
