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
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Main
local UnboxingWidget = {}
--Gui objects
local UnboxingGui

local unboxingFrame
local backgroundFrame
local rewardFrame
--Variables
local rnd = Random.new()

local tweenInfo = TweenInfo.new(0.39, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0)

local function HideGuiObjects()
	--Hide the gui objects by size for animation purposes
	unboxingFrame.Size = UDim2.fromScale(0, 0)
	unboxingFrame.Visible = false

	rewardFrame.Size = UDim2.fromScale(0, 0)
	rewardFrame.Visible = false

	backgroundFrame.Transparency = 1
	backgroundFrame.Visible = false
end

local function ShowGuiObjects()
	if not UnboxingGui.Enabled then
		UnboxingGui.Enabled = true
	end
	unboxingFrame.Visible = true
	rewardFrame.Visible = true
	backgroundFrame.Visible = true
	--Tween the gui objects to their original size
	local unboxingFrameTween =
		TweenService:Create(unboxingFrame, tweenInfo, { Size = unboxingFrame:GetAttribute("TargetSize") })
	local backgroundFrameTween = TweenService:Create(backgroundFrame, tweenInfo, { Transparency = 0.36 })
	unboxingFrameTween:Play()
	backgroundFrameTween:Play()
	unboxingFrameTween.Completed:Wait()
end

--Show reward function
local function DisplayReward(chosenReward, rewardType)
	--Tween the reward frame to its original size
	local rewardFrameTween =
		TweenService:Create(rewardFrame, tweenInfo, { Size = rewardFrame:GetAttribute("TargetSize") })
	rewardFrameTween:Play()
	rewardFrameTween.Completed:Wait()
	--Show the reward depending on the type
	if rewardType == "Skin" then
		UIController:CreateSkinFrame(chosenReward.Skin, chosenReward.Name, chosenReward.Rarity)
			:andThen(function(skinFrame)
				skinFrame.Parent = rewardFrame.ItemFrame
				--Set the size and position of the skin frame
				skinFrame.Size = UDim2.fromScale(1, 1)
				skinFrame.Position = UDim2.fromScale(0, 0)
			end)
	end
	if rewardType == "Emote" then
		local emoteFrame = UIController:CreateEmoteFrame(chosenReward)
		--Set the size and position of the emote frame
		emoteFrame.Parent = rewardFrame.ItemFrame
		emoteFrame.Size = UDim2.fromScale(1, 1)
		emoteFrame.Position = UDim2.fromScale(0, 0)
	end
	--Connect the close button
	rewardFrame.CloseButtonFrame.BackgroundButton.Activated:Connect(function()
		ButtonWidget:OnActivation(rewardFrame.CloseButtonFrame.BackgroundButton, function()
			--Tween the reward frame to its original size
			local rewardFrameTween = TweenService:Create(rewardFrame, tweenInfo, { Size = UDim2.fromScale(0, 0) })
			rewardFrameTween:Play()
			rewardFrameTween.Completed:Wait()
			rewardFrame.ItemFrame:ClearAllChildren()
			--clear rewardFrame.ItemFrame of frames
			for index, child in unboxingFrame.ItemsFrame.ItemsContainer:GetChildren() do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end
			--Hide the gui objects by size for animation purposes
			HideGuiObjects()
		end)
	end)
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
	unboxingFrame = UnboxingGui.UnboxingFrame
	rewardFrame = UnboxingGui.RewardFrame

	--Disable the gui
	UnboxingGui.Enabled = false

	--Hide the gui objects by size for animation purposes
	HideGuiObjects()
	--Connect signal
	StoreService.OpenCrateSignal:Connect(function(crate: table, rewardChosen: table, cratesLeft: number, crateName: string, unboxingTime : number)
		warn(crate,rewardChosen,unboxingTime)
		UnboxingWidget:OpenCrate(crate, rewardChosen, unboxingTime)
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

function UnboxingWidget:OpenCrate(crate: table, chosenReward: table, unboxTime : number)
	ShowGuiObjects()
	local numItems = rnd:NextInteger(20, 33)
	local chosenPosition = rnd:NextInteger(15, numItems - 5)

	for i = 1, numItems do
		local rarityChosen = chosenReward.rarity
		local randomItemChosen = chosenReward

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
		if crate.Type == "Skin" then
			UIController:CreateSkinFrame(randomItemChosen.Skin, randomItemChosen.Name, randomItemChosen.Rarity)
				:andThen(function(_newItemFrame)
					_newItemFrame.Parent = unboxingFrame.ItemsFrame.ItemsContainer
				end)
		end
		if crate.Type == "Emote" then
			local emoteFrame = UIController:CreateEmoteFrame(randomItemChosen)
			emoteFrame.Parent = unboxingFrame.ItemsFrame.ItemsContainer
		end
	end

	unboxingFrame.ItemsFrame.ItemsContainer.Position = UDim2.new(0, 0, 0.5, 0)

	local cellSize = Assets.GuiObjects.Frames.SkinTemplateFrame.Size.X.Scale
	local padding = unboxingFrame.ItemsFrame.ItemsContainer.UIListLayout.Padding.Scale
	local pos1 = 0.5 - cellSize / 2
	local nextOffset = -cellSize - padding

	local posFinal = pos1 + (chosenPosition - 1) * nextOffset
	local rndOffset = rnd:NextNumber(-cellSize / 2, cellSize / 2)
	posFinal += rndOffset

	local timeOpened = tick()

	local pow = rnd:NextNumber(3, 10)
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
			--show the reward
			DisplayReward(chosenReward, crate.Type)
			unboxingFrame.Visible = false
		end
	end)
end

return UnboxingWidget:Initialize()
