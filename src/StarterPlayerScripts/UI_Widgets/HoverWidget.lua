local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
--Controllers
local WeaponCustomizationController = Knit.GetController("WeaponCustomizationController")
local EmoteController = Knit.GetController("EmoteController")
--Screen guis
local HoverGui
--Gui objects
local ItemContentsFrame
local ItemsDisplayFrame
local viewportFrame
local closeButton
local _viewportModel
--Variables
local worldModel
--Constants
local BACKGROUND_TRANSPARENCY = 0.33
local RARITIES = {
	Common = "Common",
	Rare = "Rare",
	Epic = "Epic",
	Legendary = "Legendary",
	Mythic = "Mythic",
}
local RARITIES_DISPLAY_ORDER ={
	[RARITIES.Common] = 4,
	[RARITIES.Rare] = 3,
	[RARITIES.Epic] = 2,
	[RARITIES.Legendary] = 1,
	[RARITIES.Mythic] = 0,
}
local RARITIES_COLORS = {
	[RARITIES.Common] = Color3.fromRGB(39, 180, 126),
	[RARITIES.Rare] = Color3.fromRGB(0, 132, 255),
	[RARITIES.Epic] = Color3.fromRGB(223, 226, 37),
	[RARITIES.Legendary] = Color3.fromRGB(174, 56, 204),
	[RARITIES.Mythic] = Color3.fromRGB(184, 17, 17),
}
local HoverWidget = {}
HoverWidget.viewportConnections = {}

function HoverWidget:initialize()
	--Initialize the screen guis
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("HoverGui") then
		HoverGui = Assets.GuiObjects.ScreenGuis.HoverGui or game.Players.LocalPlayer.PlayerGui.HoverGui
		HoverGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		HoverGui = game.Players.LocalPlayer.PlayerGui.HoverGui
	end
	--Initialize the gui objects
	ItemContentsFrame = HoverGui.ItemContentsFrame
	ItemsDisplayFrame = HoverGui.ItemsDisplayFrame
	viewportFrame = HoverGui.ViewportFrame
	closeButton = HoverGui.CloseButton
	--Hide the contents with position and transparency for animation purposes
	HoverGui.BackgroundFrame.BackgroundTransparency = 1
	ItemContentsFrame.Position = UDim2.fromScale(ItemContentsFrame.Position.X.Scale, 1.5)
	ItemsDisplayFrame.Position = UDim2.fromScale(ItemsDisplayFrame.Position.X.Scale, 1.5)
	viewportFrame.Position = UDim2.fromScale(viewportFrame.Position.X.Scale, 1.5)
	closeButton.Position = UDim2.fromScale(closeButton.Position.X.Scale, 1.5)

	HoverGui.Enabled = false
	return HoverWidget
end

function HoverWidget.new(guiObject: GuiObject, params: table)
	guiObject.MouseEnter:Connect(function()
		--Tween the guiObject size to animate it
		local sizeUpTween = TweenService:Create(
			guiObject,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Size = guiObject.Size + UDim2.fromScale(0.055, 0.033) }
		)
		sizeUpTween:Play()
	end)
	guiObject.MouseLeave:Connect(function()
		--Tween the guiObject size to animate it
		local sizeDownTween = TweenService:Create(
			guiObject,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Size = guiObject.Size - UDim2.fromScale(0.055, 0.033) }
		)
		sizeDownTween:Play()
	end)
	guiObject.Activated:Connect(function()
		ButtonWidget:OnActivation(guiObject, function()
			HoverWidget:OpenHover(params.model, params)
		end)
	end)
end

local function PlayCloseAnimations()
	--Tween the position of the contents to animate it
	local backgroundFrameTween = TweenService:Create(
		HoverGui.BackgroundFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ BackgroundTransparency = 1 }
	)
	local viewportFrameTween = TweenService:Create(
		viewportFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ Position = UDim2.fromScale(viewportFrame.Position.X.Scale, 1.5) }
	)
	local itemContentsFrameTween = TweenService:Create(
		HoverGui.ItemContentsFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ Position = UDim2.fromScale(ItemContentsFrame.Position.X.Scale, 1.5) }
	)
	local itemsDisplayFrameTween = TweenService:Create(
		HoverGui.ItemsDisplayFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ Position = UDim2.fromScale(ItemsDisplayFrame.Position.X.Scale, 1.5) }
	)
	local closeButtonTween = TweenService:Create(
		HoverGui.CloseButton,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ Position = UDim2.fromScale(closeButton.Position.X.Scale, 1.5) }
	)
	closeButtonTween:Play()
	itemsDisplayFrameTween:Play()
	viewportFrameTween:Play()
	closeButtonTween.Completed:Wait()
	viewportFrameTween:Play()
	viewportFrameTween.Completed:Wait()
	itemContentsFrameTween:Play()
	itemContentsFrameTween.Completed:Wait()
	backgroundFrameTween:Play()
	backgroundFrameTween.Completed:Wait()
	worldModel = nil
end

function HoverWidget:CloseHover()
	PlayCloseAnimations()
	--Disconnect the render step
	for index, connection in HoverWidget.viewportConnections do
		connection:Disconnect()
	end
	--Clean up the items display frame
	for index, child in ItemsDisplayFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	--Clean the viewport frame
	viewportFrame:ClearAllChildren()
	--Disable the screen gui
	HoverGui.Enabled = false
end

function HoverWidget:OpenCrateInfo(params: table)
	warn(params)
	--Get the description text label
	local contentsTextLabel = ItemContentsFrame.ContentsTextLabel
	--Get the content item template frame
	for index, contentInfo: table in params.contents do
		warn(contentInfo)
		local contentItemTemplate = Assets.GuiObjects.Frames.ContentItemTemplate:Clone()
		--Assign the correct info to the content item template
		contentItemTemplate.Name = contentInfo.Name
		contentItemTemplate.ContentNameTextLabel.Text = contentInfo.Name
		--Assign the correct rarity color
		contentItemTemplate.ItemFrame.ImageColor3 = RARITIES_COLORS[contentInfo.Rarity]
		--Assign the correct rarity text
		contentItemTemplate.RarityTextLabel.Text = contentInfo.Rarity
		--Assign the color to the rarity text
		contentItemTemplate.RarityTextLabel.TextColor3 = RARITIES_COLORS[contentInfo.Rarity]
		--Assign the parent
		contentItemTemplate.Parent = ItemsDisplayFrame
		--Assign the display order
		contentItemTemplate.LayoutOrder = RARITIES_DISPLAY_ORDER[contentInfo.Rarity]
		

		if contentInfo.Image then
			contentItemTemplate.ContentIcon = contentInfo.Image
		end
		if params._type == "Skin" then
			contentItemTemplate.SkinBackground.Image = contentInfo.Skin
			--Get the weapon equipped
			local DataService = Knit.GetService("DataService")
			DataService:GetKeyValue("Loadout"):andThen(function(loadout)
				local weaponModel =
					ReplicatedStorage.Weapons[loadout.WeaponEquipped]:FindFirstChildWhichIsA("Model"):Clone()
				
				WeaponCustomizationController:ApplySkinForPreview(weaponModel, contentInfo.Skin)
				--get the viewport from the content item template
				local viewportFrame = contentItemTemplate.ViewportFrame
				--Create the viewport camera
				local viewportCamera = Instance.new("Camera")
				viewportCamera.Name = "ViewportCamera"
				viewportCamera.Parent = weaponModel


				--create the viewport model
				local _viewportModel = ViewportModel.new(viewportFrame, viewportCamera)

				--set the model
				_viewportModel:SetModel(weaponModel)
				local theta = 45
				local orientation = CFrame.fromEulerAnglesYXZ(math.rad(-6), theta, 0)
				local cf, size = weaponModel:GetBoundingBox()
				local distance = _viewportModel:GetFitDistance(cf.Position)
				--Create the world model
				local worldModel = Instance.new("WorldModel")
				worldModel.Parent = viewportFrame
				--set the model parent
				weaponModel.Parent = worldModel
				--Assign the viewport camera CFrame
				viewportCamera.CFrame =  CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
				--Assign the viewport camera
				viewportFrame.CurrentCamera = viewportCamera
			end)
		end
		if params._type == "Emote" then
			EmoteController:DisplayEmotePreview(contentInfo.Name, contentItemTemplate.ViewportFrame, true)
		end
	end
end

function HoverWidget:OpenHover(model: Model, params: table)
	--Clone the model
	model = model:Clone()
	HoverGui.Enabled = true
	--Tween the transparency of the backgroundFrame to animate it
	local backgroundFrameTween = TweenService:Create(
		HoverGui.BackgroundFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ BackgroundTransparency = BACKGROUND_TRANSPARENCY }
	)
	backgroundFrameTween:Play()
	backgroundFrameTween.Completed:Connect(function()
		--Tween the position of the contents to animate it
		local viewportFrameTween = TweenService:Create(
			viewportFrame,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Position = viewportFrame:GetAttribute("TargetPosition") }
		)
		local itemContentsFrameTween = TweenService:Create(
			HoverGui.ItemContentsFrame,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Position = ItemContentsFrame:GetAttribute("TargetPosition") }
		)
		local itemsDisplayFrameTween = TweenService:Create(
			HoverGui.ItemsDisplayFrame,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Position = ItemsDisplayFrame:GetAttribute("TargetPosition") }
		)
		local closeButtonTween = TweenService:Create(
			HoverGui.CloseButton,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Position = closeButton:GetAttribute("TargetPosition") }
		)
		itemsDisplayFrameTween:Play()
		viewportFrameTween:Play()
		itemContentsFrameTween:Play()
		closeButtonTween:Play()
	end)

	--Display the item contents according to the category
	if params.category == "Crates" then
		HoverWidget:OpenCrateInfo(params)
	end

	if model then
		--Create the viewport camera
		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = model

		--create the viewport model
		if not _viewportModel then
			_viewportModel = ViewportModel.new(viewportFrame, viewportCamera)
		end
		--set the model
		_viewportModel:SetModel(model)
		local theta = 0
		local orientation
		local cf, size = model:GetBoundingBox()
		local distance = _viewportModel:GetFitDistance(cf.Position)
		--Create the world model
		if not worldModel then
			worldModel = Instance.new("WorldModel")
		end
		worldModel.Parent = viewportFrame
		--set the model parent
		model.Parent = worldModel
		--Connect the render step to rotate the model
		table.insert(
			HoverWidget.viewportConnections,
			game:GetService("RunService").RenderStepped:Connect(function(dt)
				theta = theta + math.rad(20 * dt)
				orientation = CFrame.fromEulerAnglesYXZ(math.rad(-6), theta, 0)
				viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
			end)
		)
		--Assign the viewport camera
		viewportFrame.CurrentCamera = viewportCamera
	end
	--Connect the close button
	HoverGui.CloseButton.Activated:Connect(function()
		ButtonWidget:OnActivation(HoverGui.CloseButton, function()
			HoverWidget:CloseHover()
		end)
	end)
end

return HoverWidget:initialize()
