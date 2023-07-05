--Services
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Knit controller
local EmoteController = Knit.GetController("EmoteController")
--Main
local EmoteWheelWidget = {}
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)

local buttonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

--Gui variables
local emoteWheelGui
local wheelFrame
local playerEmotesScrollingFrame
local emotesFrame

--Variables
local isOpen = false

function EmoteWheelWidget:Initialize()
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("EmoteWheelGui") then
		emoteWheelGui = Assets.GuiObjects.ScreenGuis.EmoteWheelGui or game.Players.LocalPlayer.PlayerGui.EmoteWheelGui
		emoteWheelGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		emoteWheelGui = game.Players.LocalPlayer.PlayerGui.EmoteWheelGui
	end
	--Get the gui objects
	wheelFrame = emoteWheelGui.WheelFrame
	emotesFrame = emoteWheelGui.EmotesFrame
	playerEmotesScrollingFrame = emoteWheelGui.PlayerEmotesScrollingFrame

	--Disable the gui
	emoteWheelGui.Enabled = false
	--Hide the emotes and wheel frame initially by setting their size to 0
	wheelFrame.Size = UDim2.fromScale(0, 0)
	emotesFrame.Size = UDim2.fromScale(0, 0)
	playerEmotesScrollingFrame.Size = UDim2.fromScale(0, 0)
	
	--Set up the emote wheel
	for index, emoteFrame in emotesFrame:GetChildren() do
		--Set up the emote frame
		emoteFrame.DiscardButton.Visible = false
		emoteFrame.EmoteIconFrame.Visible = false
		emoteFrame.EmoteNameTextLabel.Visible = false
		--Set up the add button
		emoteFrame.AddButton.Activated:Connect(function()
			ButtonWidget:OnActivation(emoteFrame.AddButton, function()
				--Add the emote to the player's emotes
				self:ConfigureEmotes()
			end)
		end)
		--Set up the configure emote button
		wheelFrame.ConfigureButtonFrame.button.Activated:Connect(function()
			ButtonWidget:OnActivation(wheelFrame.ConfigureButtonFrame, function()
				--Add the emote to the player's emotes
				self:ConfigureEmotes()
			end)
		end)
		--Set up hover events
		emoteFrame.MouseEnter:Connect(function()
			TweenService
				:Create(
					emoteFrame.SelectionHoverImage,
					buttonTweenInfo,
					{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0}
				)
				:Play()
		end)
		emoteFrame.MouseLeave:Connect(function()
			TweenService
				:Create(emoteFrame.SelectionHoverImage, buttonTweenInfo, { ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.37 })
				:Play()
		end)
	end
	--Get the player's emotes
	-- local playerEmotes = EmoteController:GetPlayerEquippedEmotes()
	-- if playerEmotes then
	-- 	self:AssignSavedEmotes(playerEmotes)
	-- end

	ContextActionService:BindAction("OpenEmoteWheel", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			if not isOpen then
				self:Open()
			else
				self:Close()
			end
		end
	end, true, Enum.KeyCode.T)
return EmoteWheelWidget
end

function EmoteWheelWidget:Open()
	isOpen = true
	--Enable the gui
	emoteWheelGui.Enabled = true
	--Tween the wheel frame to its original size
	TweenService:Create(wheelFrame, buttonTweenInfo, { Size = wheelFrame:GetAttribute("TargetSize") }):Play()
	--Tween the wheel frame to its original size
	TweenService:Create(emotesFrame, buttonTweenInfo, { Size = emotesFrame:GetAttribute("TargetSize") }):Play()
end

function EmoteWheelWidget:Close()
	isOpen = false
	--Tween the wheel frame to size 0
	TweenService:Create(wheelFrame, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) }):Play()
	--Tween the emotes frame to size 0
	local emotesFrameTween = TweenService:Create(emotesFrame, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) })
	emotesFrameTween:Play()
	emotesFrameTween.Completed:Connect(function()
		--Hide the emote wheel gui
		emoteWheelGui.Enabled = false
	end)
end

--Enter emote configuration mode
function EmoteWheelWidget:ConfigureEmotes()
	for _, emoteFrame: Frame in pairs(emotesFrame:GetChildren()) do
		if emoteFrame:GetAttribute("Emote") then
			emoteFrame.EmoteNameTextLabel.Visible = true
			emoteFrame.EmoteNameTextLabel.Text = emoteFrame:GetAttribute("Emote")
			emoteFrame.DiscardButton.Visible = true
			if emoteFrame:GetAttribute("EmoteIcon") then
				emoteFrame.EmoteIconFrame.Visible = true
			end
		end
	end
	--Display the player emotes
	TweenService:Create(playerEmotesScrollingFrame, buttonTweenInfo, { Size = playerEmotesScrollingFrame:GetAttribute("TargetSize") }):Play()
	--Get the player's emotes
	EmoteController:GetPlayerEmotes():andThen(function(playerEmotes)
		warn(playerEmotes)
		if playerEmotes then
			for index, emoteName in playerEmotes do
				local emote : table = Emotes[emoteName]
				local emoteFrame = Assets.GuiObjects.Frames.EmoteTemplateFrame:Clone()
				emoteFrame.Parent = playerEmotesScrollingFrame
				emoteFrame.NameTextLabel.Text = emote.name
				emoteFrame.RarityTextLabel.Text = emote.rarity
				EmoteController:DisplayEmotePreview(emoteName, emoteFrame.ViewportFrame)
			end
		end
	end)
	
end

function EmoteWheelWidget:AssignSavedEmotes(emotes: table)
	--Assign the player emotes to the emotes frame
	for _, emoteData: table in pairs(emotes) do
		warn(emoteData)
		local emoteFrame = wheelFrame[emoteData.order]
		--Hide the add button
		emoteFrame.AddButton.Visible = false
		--If the emote has an icon, display the EmoteIconFrame otherwise hide it
		if emoteData.icon then
			emoteFrame.EmoteIconFrame.Visible = true
			emoteFrame.EmoteIconFrame.EmoteIcon.Image = emoteData.icon
		else
			emoteFrame.EmoteIconFrame.Visible = false
		end
		emoteFrame.EmoteNameTextLabel.Visible = false
		emoteFrame.EmoteNameTextLabel = emoteData.name
		emoteFrame.MouseButton1Click:Connect(function()
			--Play the emote
			EmoteController:PlayEmote(emoteData)
			--Close the emote wheel
			-- self:Close()
		end)
	end
end

return EmoteWheelWidget:Initialize()
