--Services
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
--Knit controller
local EmoteController = Knit.GetController("EmoteController")
local WidgetController

--Knit Service
local EmoteService
--Main
local EmoteWheelWidget = {}
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)
local EmoteIcons = require(ReplicatedStorage.Source.Assets.EmoteIcons)

local buttonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

--Gui variables
local emoteWheelGui
local wheelFrame
local closeConfigureButton
local playerEmotesScrollingFrame
local emoteAnimationsButton
local emoteIconsButton
local emotesFrame

--Variables
EmoteWheelWidget.isOpen = false
EmoteWheelWidget.isInitialized = false
EmoteWheelWidget.currentEmotesDisplaying = "Animations"

local function ClearPlayerEmotes()
	--Clear player emotes
	for _, emoteFrame: Frame in pairs(playerEmotesScrollingFrame:GetChildren()) do
		if emoteFrame:IsA("Frame") then
			emoteFrame:Destroy()
		end
	end
end

function EmoteWheelWidget:Initialize()
	--Initialize the knit controllers
	EmoteService = Knit.GetService("EmoteService")
	WidgetController = Knit.GetController("WidgetController")

	self.emoteFramesConnections = {}
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
	closeConfigureButton = emoteWheelGui.CloseConfigureButton
	emoteAnimationsButton = emoteWheelGui.EmoteAnimationsButton
	emoteIconsButton = emoteWheelGui.EmoteIconsButton

	--Create the emote animations button
	ButtonWidget.new(emoteWheelGui.EmoteAnimationsButton, function()
		EmoteWheelWidget.currentEmotesDisplaying = "Animations"
		ClearPlayerEmotes()
		self:UpdatePlayerEmotes()
	end)
	--Create the emote icons button
	ButtonWidget.new(emoteWheelGui.EmoteIconsButton, function()
		EmoteWheelWidget.currentEmotesDisplaying = "Icons"
		ClearPlayerEmotes()
		self:UpdatePlayerEmotes()
	end)
	--Create the close configure button
	ButtonWidget.new(closeConfigureButton, function()
		--Close the emote wheel
		self:CloseConfiguration()
	end)
	--Disable the gui
	emoteWheelGui.Enabled = false
	--Hide the emotes and wheel frame initially by setting their size to 0
	wheelFrame.Size = UDim2.fromScale(0, 0)
	emotesFrame.Size = UDim2.fromScale(0, 0)
	emoteAnimationsButton.Size = UDim2.fromScale(0, 0)
	emoteIconsButton.Size = UDim2.fromScale(0, 0)
	playerEmotesScrollingFrame.Size = UDim2.fromScale(0, 0)
	closeConfigureButton.Size = UDim2.fromScale(0, 0)
	--Set up the configure emote button
	--Create the configure button
	ButtonWidget.new(wheelFrame.ConfigureButtonFrame.button, function()
		--Open the emote wheel
		self:ConfigureEmotes()
	end)

	--Set up the emote wheel
	for index, emoteFrame in emotesFrame:GetChildren() do
		--Set up the emote frame
		emoteFrame.DiscardButton.Visible = false
		emoteFrame.EmoteIconFrame.DiscardButton.Visible = false
		emoteFrame.EmoteIconFrame.Visible = false
		emoteFrame.EmoteNameTextLabel.Visible = false
		--Create the add button
		ButtonWidget.new(emoteFrame.AddButton, function()
			--Add the emote to the player's emotes
			self:ConfigureEmotes(emoteFrame)
		end)
		--Connect the attribute changed to update the emote frame
		emoteFrame:GetAttributeChangedSignal("Emote"):Connect(function()
			if emoteFrame:GetAttribute("Emote") then
				--Clear the viewport frame before displaying the emote
				emoteFrame.ViewportFrame:ClearAllChildren()
				emoteFrame.EmoteNameTextLabel.Visible = true
				emoteFrame.EmoteNameTextLabel.Text = emoteFrame:GetAttribute("Emote")
				emoteFrame.AddButton.Visible = false
				EmoteController:DisplayEmotePreview(emoteFrame:GetAttribute("Emote"), emoteFrame.ViewportFrame, true)
			else
				emoteFrame.EmoteNameTextLabel.Visible = false
				emoteFrame.DiscardButton.Visible = false
			end
		end)
		--Connect the attribute changed to update emote frame icon
		emoteFrame:GetAttributeChangedSignal("EmoteIcon"):Connect(function()
			if emoteFrame:GetAttribute("EmoteIcon") then
				emoteFrame.EmoteIconFrame.Visible = true
				local emoteName = emoteFrame:GetAttribute("EmoteIcon")
				--format the emote name to be the same as the emote name in the emotes table
				emoteName = emoteName:gsub(" ", "_")
				emoteName = emoteName:gsub("'", "")
				emoteFrame.EmoteIconFrame.EmoteIcon.Image = EmoteIcons[emoteName].imageID
			end
		end)
		--Create the emote play button
		ButtonWidget.new(emoteFrame.SelectionHoverImage, function()
			if self.isConfiguringEmotes then
				self:SelectEmoteToConfigure(emoteFrame)
				return
			end

			-- Play the emote
			-- Format the emote name to be the same as the emote name in the emotes table
			local animationEmote = emoteFrame:GetAttribute("Emote")
			local iconEmote = emoteFrame:GetAttribute("EmoteIcon")

			if animationEmote then
				animationEmote = animationEmote:gsub("'", "")
				animationEmote = animationEmote:gsub(" ", "_")
				EmoteController:PlayEmote(animationEmote)
			end

			if iconEmote then
				EmoteController:PlayEmoteIcon(iconEmote)
			end

			if not animationEmote and not iconEmote then
				self:ConfigureEmotes(emoteFrame)
			end
		end)
		--Connect the mouse enter and leave events from the emote frame
		self.emoteFramesConnections[emoteFrame.Name] = {}
		self.emoteFramesConnections[emoteFrame.Name].mouseEnter = emoteFrame.MouseEnter:Connect(function()
			TweenService:Create(
				emoteFrame.SelectionHoverImage,
				buttonTweenInfo,
				{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0 }
			):Play()
		end)
		self.emoteFramesConnections[emoteFrame.Name].mouseLeave = emoteFrame.MouseLeave:Connect(function()
			warn("Mouse left")
			TweenService:Create(
				emoteFrame.SelectionHoverImage,
				buttonTweenInfo,
				{ ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.37 }
			):Play()
		end)
	end

	--Get the player's emotes
	EmoteController:GetPlayerEmotes():andThen(function(emotes)
		warn(emotes)
		if emotes then
			self:AssignSavedEmotes(emotes.EmotesEquipped)
		end
	end)
	self.isInitialized = true
end

function EmoteWheelWidget:Open()
	EmoteWheelWidget.isOpen = true
	--Enable the gui
	emoteWheelGui.Enabled = true
	--Tween the wheel frame to its original size
	TweenService:Create(wheelFrame, buttonTweenInfo, { Size = wheelFrame:GetAttribute("TargetSize") }):Play()
	--Tween the wheel frame to its original size
	TweenService:Create(emotesFrame, buttonTweenInfo, { Size = emotesFrame:GetAttribute("TargetSize") }):Play()
end

function EmoteWheelWidget:Close()
	EmoteWheelWidget.isOpen = false
	--Tween the wheel frame to size 0
	TweenService:Create(wheelFrame, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) }):Play()
	--Tween the emotes frame to size 0
	local emotesFrameTween = TweenService:Create(emotesFrame, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) })
	emotesFrameTween:Play()
	emotesFrameTween.Completed:Connect(function()
		--Hide the emote wheel gui
		emoteWheelGui.Enabled = false
	end)
	--Deselct any emote that could be hovered
	for index, child in emotesFrame:GetChildren() do
		if child:IsA("Frame") then
			child.SelectionHoverImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
			child.SelectionHoverImage.ImageTransparency = 0.37
		end
	end
	--Disconnect the mouse enter and leave events from the emote frames
	for _, connection in self.emoteFramesConnections do
		connection.mouseEnter:Disconnect()
		connection.mouseLeave:Disconnect()
	end
	--Check if configuration mode is open
	if playerEmotesScrollingFrame.Size ~= UDim2.fromScale(0, 0) then
		self:CloseConfiguration()
	end
end

--Enter emote configuration mode
function EmoteWheelWidget:ConfigureEmotes(emoteFrame: Frame)
	if self.isConfiguringEmotes then
		self:CloseConfiguration()
		return
	end
	self.isConfiguringEmotes = true
	--if there's an initial emote frame, make it the current emote editing frame
	if emoteFrame then
		self:SelectEmoteToConfigure(emoteFrame)
	end
	for _, emoteFrame: Frame in (emotesFrame:GetChildren()) do
		if emoteFrame:GetAttribute("Emote") then
			emoteFrame.EmoteNameTextLabel.Visible = true
			emoteFrame.EmoteNameTextLabel.Text = emoteFrame:GetAttribute("Emote")
			if emoteFrame:GetAttribute("EmoteIcon") then
				emoteFrame.EmoteIconFrame.Visible = true
			end
			--connect discard button
			emoteFrame.DiscardButton.Visible = true
			--Create discard button
			ButtonWidget.new(emoteFrame.DiscardButton, function()
				--Remove the emote from the emote frame
				emoteFrame:SetAttribute("Emote", nil)
				--Hide the emote icon frame
				emoteFrame.EmoteIconFrame.Visible = false
				--Hide the emote name text label
				emoteFrame.EmoteNameTextLabel.Visible = false
				--Show the add button
				emoteFrame.AddButton.Visible = true
				emoteFrame.ViewportFrame:ClearAllChildren()
				--Update the player's emotes
				EmoteService:RemoveEmote(emoteFrame.Name, "animationEmote")
				self:SelectEmoteToConfigure(emoteFrame)
			end)
		end

		if emoteFrame:GetAttribute("EmoteIcon") then
			--connect discard button
			emoteFrame.EmoteIconFrame.DiscardButton.Visible = true
			--Create discard button
			ButtonWidget.new(emoteFrame.EmoteIconFrame.DiscardButton, function()
				--Remove the emote from the emote frame
				emoteFrame:SetAttribute("EmoteIcon", nil)
				--Hide the emote icon frame
				emoteFrame.EmoteIconFrame.Visible = false
				--Update the player's emotes
				EmoteService:RemoveEmote(emoteFrame.Name, "iconEmote")
				self:SelectEmoteToConfigure(emoteFrame)
			end)
		end
	end

	--Display the player emotes tweens
	TweenService:Create(
		playerEmotesScrollingFrame,
		buttonTweenInfo,
		{ Size = playerEmotesScrollingFrame:GetAttribute("TargetSize") }
	):Play()
	TweenService
		:Create(closeConfigureButton, buttonTweenInfo, { Size = closeConfigureButton:GetAttribute("TargetSize") })
		:Play()
	TweenService
		:Create(emoteAnimationsButton, buttonTweenInfo, { Size = emoteAnimationsButton:GetAttribute("TargetSize") })
		:Play()
	TweenService:Create(emoteIconsButton, buttonTweenInfo, { Size = emoteIconsButton:GetAttribute("TargetSize") })
		:Play()
	--Get the player's emotes according to the current emotes displaying
	--Check if the player emotes scroll frame has any children (Note that the first child is grid layoutt)
	if #playerEmotesScrollingFrame:GetChildren() < 2 then
		self:UpdatePlayerEmotes()
	end
end

function EmoteWheelWidget:UpdatePlayerEmotes()
	--Get the player's emotes according to the current emotes displaying
	--Check if the player emotes scroll frame has any children (Note that the first child is grid layoutt)
	if #playerEmotesScrollingFrame:GetChildren() < 2 then
		EmoteController:GetPlayerEmotes():andThen(function(emotes)
			local emotesOwned = emotes.EmotesOwned
			if emotesOwned then
				for emoteName, emoteInfo: table in emotesOwned do
					--format the emote name to be the same as the emote name in the emotes table
					emoteName = emoteName:gsub(" ", "_")
					emoteName = emoteName:gsub("'", "")
					local emoteFrame

					if EmoteWheelWidget.currentEmotesDisplaying == "Animations" then
						if emoteInfo.Type == "Animation" then
							local emote: table = Emotes[emoteName]
							emoteFrame = WidgetController:CreateEmoteFrame(emote)
							--Create the emote frame
							ButtonWidget.new(emoteFrame, function()
								--Assign the emote to the emote frame slot
								self:AssignEmote(emote.name, "Animation")
								--Close the emote wheel
								-- self:Close()
							end)
						end
					end

					if EmoteWheelWidget.currentEmotesDisplaying == "Icons" then
						if emoteInfo.Type == "Icon" then
							local emoteIcon = EmoteIcons[emoteName]
							emoteFrame = WidgetController:CreateEmoteIconFrame(emoteIcon)
							--Create the emote icon frame
							ButtonWidget.new(emoteFrame, function()
								--Assign the emote to the emote frame slot
								warn("Assigning emote")
								self:AssignEmote(emoteIcon.name, "Icon")
								--Close the emote wheel
								-- self:Close()
							end)
						end
					end

					if emoteFrame then
						emoteFrame.Parent = playerEmotesScrollingFrame
					end
				end
			end
		end)
	end
end

function EmoteWheelWidget:SelectEmoteToConfigure(emoteFrame: Frame)
	--if there's a current emote editing frame, deselect it
	if self.currentEmoteEditingFrame then
		self:DeselectEmoteToConfigure(self.currentEmoteEditingFrame)
	end
	self.currentEmoteEditingFrame = emoteFrame
	--Disconnect the mouse enter and leave events from the emote frames to avoid the hover effect
	self.emoteFramesConnections[emoteFrame.Name].mouseEnter:Disconnect()
	self.emoteFramesConnections[emoteFrame.Name].mouseLeave:Disconnect()
	TweenService:Create(
		emoteFrame.SelectionHoverImage,
		buttonTweenInfo,
		{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0 }
	):Play()
end

--Assign emote to the emote frame slot
function EmoteWheelWidget:AssignEmote(emoteName: string, emoteType: string)
	warn(emoteName, emoteType)
	local emoteFrame = self.currentEmoteEditingFrame
	--Assign the emote to the emote frame
	if emoteFrame then
		if emoteType == "Icon" then
			emoteFrame:SetAttribute("EmoteIcon", emoteName)
		elseif emoteType == "Animation" then
			emoteFrame:SetAttribute("Emote", emoteName)
		end
		local emoteIndex = emoteFrame.Name

		Knit.GetService("EmoteService"):SaveEmote(emoteIndex, emoteName, emoteType)
	end
end

function EmoteWheelWidget:DeselectEmoteToConfigure(emoteFrame: Frame)
	TweenService:Create(
		emoteFrame.SelectionHoverImage,
		buttonTweenInfo,
		{ ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.37 }
	):Play()
	--Connect the mouse enter and leave events for the emote frame again
	self.emoteFramesConnections[emoteFrame.Name].mouseEnter = self.currentEmoteEditingFrame.MouseEnter:Connect(
		function()
			TweenService:Create(
				emoteFrame.SelectionHoverImage,
				buttonTweenInfo,
				{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0 }
			):Play()
		end
	)
	self.emoteFramesConnections[emoteFrame.Name].mouseLeave = self.currentEmoteEditingFrame.MouseLeave:Connect(
		function()
			TweenService:Create(
				emoteFrame.SelectionHoverImage,
				buttonTweenInfo,
				{ ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.37 }
			):Play()
		end
	)
	self.currentEmoteEditingFrame = nil
end

function EmoteWheelWidget:CloseConfiguration()
	self.isConfiguringEmotes = false
	--If there's a current emote editing frame, deselect it
	if self.currentEmoteEditingFrame then
		self:DeselectEmoteToConfigure(self.currentEmoteEditingFrame)
	end
	--Hide the discard buttons from the emotes frames
	for _, emoteFrame: Frame in (emotesFrame:GetChildren()) do
		emoteFrame.DiscardButton.Visible = false
		emoteFrame.EmoteIconFrame.DiscardButton.Visible = false
	end
	--Hide the player emotes
	TweenService:Create(playerEmotesScrollingFrame, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) }):Play()
	TweenService:Create(closeConfigureButton, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) }):Play()
	TweenService:Create(emoteAnimationsButton, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) }):Play()
	TweenService:Create(emoteIconsButton, buttonTweenInfo, { Size = UDim2.fromScale(0, 0) }):Play()
	ClearPlayerEmotes()
end

function EmoteWheelWidget:AssignSavedEmotes(emotes: table)
	--Assign the player emotes to the emotes frame
	for emoteIndex, emoteInfo: table in emotes do
		if emoteInfo.animationEmote then
			local emote = Emotes[emoteInfo.animationEmote]
			emotesFrame[emoteIndex]:SetAttribute("Emote", emote.name)
		end
		if emoteInfo.iconEmote then
			local emoteIcon = EmoteIcons[emoteInfo.iconEmote]
			emotesFrame[emoteIndex]:SetAttribute("EmoteIcon", emoteIcon.name)
		end
	end
end

return EmoteWheelWidget
