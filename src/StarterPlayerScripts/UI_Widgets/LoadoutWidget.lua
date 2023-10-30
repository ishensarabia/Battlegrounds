local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
--Utils
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)

--Assets
local Assets = ReplicatedStorage.Assets
local Weapons = ReplicatedStorage.Weapons
--Widget
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
local WeaponPreviewWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponPreviewWidget)
--Main
local LoadoutWidget = {}
local loadoutGui
local inventoryMainFrame
--Variables
local categoryButtonsFrame
local loadoutButtonsFrame
local backButtonFrame
local showMainMenuCallback
local itemsFrame
local inventoryTitle
local backgroundImage
local player = Players.LocalPlayer

local inventoryTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

LoadoutWidget.slot = "Primary"

local function ClearItemsFrame()
	for index, value in itemsFrame:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end
end

local function SetupCategoryButtons()
	local function openCategory(categoryButtonFrame)
		LoadoutWidget:SetInventoryItemsVis(false)
		ClearItemsFrame()
		LoadoutWidget:OpenLoadout(showMainMenuCallback)
	end
	for index, categoryButtonFrame in categoryButtonsFrame:GetChildren() do
		if categoryButtonFrame:IsA("Frame") then
			categoryButtonFrame.Frame.BackgroundButton.Activated:Connect(function()
				ButtonWidget:OnActivation(categoryButtonFrame.Frame, function()
					openCategory(categoryButtonFrame)
				end)
			end)
			categoryButtonFrame.Frame.IconButton.Activated:Connect(function()
				ButtonWidget:OnActivation(categoryButtonFrame.Frame, function()
					openCategory(categoryButtonFrame)
				end)
			end)
		end
	end
end

local function SelectLoadoutSlot(frame)
	for index, child in loadoutButtonsFrame:GetChildren() do
		if child:IsA("Frame") then
			child.SelectionFrame.Visible = true
			TweenService:Create(child.SelectionFrame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		end
	end
	TweenService:Create(frame.SelectionFrame, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
	LoadoutWidget.slot = frame:GetAttribute("LoadoutSlot")
	-- LoadoutWidget:OpenLoadout(showMainMenuCallback)
end

local function SetupLoadoutButtons()
	for index, child in loadoutButtonsFrame:GetChildren() do
		if child:IsA("Frame") then
			child.Frame.BackgroundButton.Activated:Connect(function()
				ButtonWidget:OnActivation(child.Frame, function()
					SelectLoadoutSlot(child)
					LoadoutWidget:OpenLoadout(showMainMenuCallback)
				end)
			end)
		end
	end
end

function LoadoutWidget:CloseInventory()
	local inventoryMainFrameTween =
		TweenService:Create(inventoryMainFrame, inventoryTweenInfo, { Position = UDim2.fromScale(-1, 0) })
	local backButtonFrameTween = TweenService:Create(
		backButtonFrame,
		inventoryTweenInfo,
		{ Position = UDim2.fromScale(-1, backButtonFrame.Position.Y.Scale), Transparency = 1 }
	)
	local backgroundImageTween = TweenService:Create(backgroundImage, inventoryTweenInfo, { ImageTransparency = 1 })
	ClearItemsFrame()
	inventoryMainFrameTween:Play()
	backButtonFrameTween:Play()
	backgroundImageTween:Play()
end

function LoadoutWidget:SetInventoryItemsVis(condition)
	if condition then
		TweenService:Create(inventoryMainFrame, TweenInfo.new(0.33), { Position = UDim2.fromScale(0.027, 0) }):Play()
	else
		TweenService:Create(inventoryMainFrame, TweenInfo.new(0.9), { Position = UDim2.fromScale(1, 0) }):Play()
	end
end

local function SetupInventoryButtons()
	backButtonFrame.Button.Activated:Connect(function()
		if LoadoutWidget.state == "Items" then
			local tween = ButtonWidget:OnActivation(backButtonFrame, function()
				LoadoutWidget:CloseInventory()
			end)
			--Return to main menu
			tween.Completed:Connect(showMainMenuCallback)
		elseif LoadoutWidget.state == "WeaponPreview" then
			ButtonWidget:OnActivation(backButtonFrame, function()
				WeaponPreviewWidget:ClosePreview()
				LoadoutWidget:SetInventoryItemsVis(true)
				LoadoutWidget.state = "Items"
			end)
		end
	end)
end

function LoadoutWidget:Initialize()
	--Mount inventory widget
	local player = game.Players.LocalPlayer
	loadoutGui = Assets.GuiObjects.ScreenGuis.LoadoutGui
	inventoryMainFrame = loadoutGui.MainFrame
	categoryButtonsFrame = inventoryMainFrame.CategoryButtonsFrame
	loadoutButtonsFrame = inventoryMainFrame.LoadoutButtons
	backButtonFrame = loadoutGui.BackButtonFrame
	itemsFrame = inventoryMainFrame.ItemsFrame
	inventoryTitle = inventoryMainFrame.Title
	backgroundImage = loadoutGui.BackgroundImage
	backgroundImage.ImageTransparency = 1
	inventoryMainFrame.Position = UDim2.fromScale(-1, 0)
	backButtonFrame.Position = UDim2.fromScale(1, backButtonFrame.Position.Y.Scale)
	loadoutGui.Enabled = false
	loadoutGui.Parent = player.PlayerGui
	SetupInventoryButtons()
	SetupCategoryButtons()
	SetupLoadoutButtons()

	return LoadoutWidget
end

function LoadoutWidget:OpenLoadout(callback)
	if not self.active then
		SelectLoadoutSlot(loadoutButtonsFrame.PrimaryFrame)
	end
	LoadoutWidget.active = true
	LoadoutWidget.state = "Items"
	warn(callback)
	--Clean
	for index, child in itemsFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	loadoutGui.Enabled = true
	inventoryTitle.Text = string.upper("Loadout")
	local OpenLoadoutTween =
		TweenService:Create(inventoryMainFrame, inventoryTweenInfo, { Position = UDim2.fromScale(0, 0) })
	local backButtonFrameTween = TweenService:Create(
		backButtonFrame,
		inventoryTweenInfo,
		{ Position = backButtonFrame:GetAttribute("TargetPosition") }
	)
	local backgroundImageTween = TweenService:Create(backgroundImage, inventoryTweenInfo, { ImageTransparency = 0 })
	backgroundImageTween:Play()
	backButtonFrameTween:Play()
	OpenLoadoutTween:Play()
	
	showMainMenuCallback = callback
	--Generate items frame
	Knit.GetService("DataService"):GetKeyValue("Weapons"):andThen(function(loadoutItems: table)
		for itemID, itemTable in loadoutItems do
			warn(itemTable)
			--Filter the category
			--Get the tool to identify if it has texture
			local weapon: Tool = Weapons[itemID]
			if weapon.TextureId and weapon:GetAttribute("Slot") == self.slot then
				local itemFrame = Assets.GuiObjects.Frames.ItemFrame:Clone()
				itemFrame.Parent = itemsFrame
				local formattedItemName = string.gsub(itemID, "_", " ")
				itemFrame.Frame:WaitForChild("ItemName").Text = formattedItemName
				itemFrame.Frame:WaitForChild("ItemIcon").Image = weapon.TextureId
				if not  itemTable.Owned then
					itemFrame.Frame.LockIcon.Visible = true
					itemFrame.Frame.RequiredLevelText.Visible = true
					itemFrame.Frame.RequiredLevelText.Text = "Level " .. weapon:GetAttribute("RequiredLevel") .. " required"
					itemFrame.Frame.BuyEarlyButton.PriceText.Text = FormatText.To_comma_value(weapon:GetAttribute("EarlyPrice")) or 0
					if  player.leaderstats.Level.Value >= weapon:GetAttribute("RequiredLevel") then
						itemFrame.Frame.BuyButton.Visible = true
						itemFrame.Frame.BuyEarlyButton.Visible = false
					else
						itemFrame.Frame.BuyEarlyButton.Visible = true
						itemFrame.Frame.BuyButton.Visible = false
					end
					itemFrame.Frame.BuyButton.PriceText.Text = FormatText.To_comma_value(weapon:GetAttribute("Price"))
				else
					itemFrame.Frame.BuyEarlyButton.Visible = false
					itemFrame.Frame.BuyButton.Visible = false
					itemFrame.Frame.LockIcon.Visible = false
					itemFrame.Frame.RequiredLevelText.Visible = false
				end
				itemFrame.Frame.ItemIcon.Activated:Connect(function()
					ButtonWidget:OnActivation(itemFrame.Frame, function()
						LoadoutWidget.state = "WeaponPreview"
						LoadoutWidget:SetInventoryItemsVis(false)
						WeaponPreviewWidget:OpenPreview(itemID, self.slot)
					end)
				end)
			end
		end
	end)
end

return LoadoutWidget:Initialize()
