local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local Assets = ReplicatedStorage.Assets
local Weapons = ReplicatedStorage.Weapons
--Widget
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
local WeaponPreviewWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponPreviewWidget)
--Main
local InventoryWidget = {}
local inventoryGui
local inventoryMainFrame
--Variables
local categoryButtonsFrame
local backButtonFrame
local showMainMenuCallback
local itemsFrame
local inventoryTitle

local inventoryTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

InventoryWidget.state = "Items"

local function ClearItemsFrame()
	for index, value in itemsFrame:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end
end

local function SetupCategoryButtons()
	local function openCategory(categoryButtonFrame)
		InventoryWidget:SetInventoryItemsVis(false)
		ClearItemsFrame()
		InventoryWidget:OpenInventory(
			InventoryWidget.inventoryType,
			showMainMenuCallback,
			categoryButtonFrame:GetAttribute("Category")
		)
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

function InventoryWidget:CloseInventory()
	local inventoryMainFrameTween =
		TweenService:Create(inventoryMainFrame, inventoryTweenInfo, { Position = UDim2.fromScale(-1, 0) })
	local backButtonFrameTween = TweenService:Create(
		backButtonFrame,
		inventoryTweenInfo,
		{ Position = UDim2.fromScale(-1, backButtonFrame.Position.Y.Scale) }
	)
	ClearItemsFrame()
	inventoryMainFrameTween:Play()
	backButtonFrameTween:Play()
end

function InventoryWidget:SetInventoryItemsVis(condition)
	if condition then
		TweenService:Create(inventoryMainFrame, TweenInfo.new(0.33), { Position = UDim2.fromScale(0.027, 0) }):Play()
	else
		TweenService:Create(inventoryMainFrame, TweenInfo.new(0.9), { Position = UDim2.fromScale(1, 0) }):Play()
	end
end

local function SetupInventoryButtons()
	backButtonFrame.Button.Activated:Connect(function()
		if InventoryWidget.state == "Items" then
			local tween = ButtonWidget:OnActivation(backButtonFrame, function()
				InventoryWidget:CloseInventory()
			end)
			--Return to main menu
			tween.Completed:Connect(showMainMenuCallback)
		elseif InventoryWidget.state == "WeaponPreview" then
			ButtonWidget:OnActivation(backButtonFrame, function()
				WeaponPreviewWidget:ClosePreview()
				InventoryWidget:SetInventoryItemsVis(true)
				InventoryWidget.state = "Items"
			end)
		end
	end)
end

function InventoryWidget:Initialize()
	--Mount inventory widget
	local player = game.Players.LocalPlayer
	inventoryGui = Assets.GuiObjects.ScreenGuis.InventoryGui
	inventoryMainFrame = inventoryGui.MainFrame
	categoryButtonsFrame = inventoryMainFrame.CategoryButtonsFrame
	backButtonFrame = inventoryGui.BackButtonFrame
	itemsFrame = inventoryMainFrame.ItemsFrame
	inventoryTitle = inventoryMainFrame.Title
	inventoryMainFrame.Position = UDim2.fromScale(-1, 0)
	backButtonFrame.Position = UDim2.fromScale(1, backButtonFrame.Position.Y.Scale)
	inventoryGui.Enabled = false
	inventoryGui.Parent = player.PlayerGui
	SetupInventoryButtons()
	SetupCategoryButtons()

	return InventoryWidget
end

function InventoryWidget:OpenInventory(inventoryType: string, callback, category: string)
	inventoryGui.Enabled = true
	inventoryTitle.Text = string.upper(inventoryType)
	local openInventoryTween =
		TweenService:Create(inventoryMainFrame, inventoryTweenInfo, { Position = UDim2.fromScale(0, 0) })
	local backButtonFrameTween = TweenService:Create(
		backButtonFrame,
		inventoryTweenInfo,
		{ Position = backButtonFrame:GetAttribute("TargetPosition") }
	)
	backButtonFrameTween:Play()
	openInventoryTween:Play()

	--Register category selected
	InventoryWidget.inventoryType = inventoryType
	InventoryWidget.category = category
	showMainMenuCallback = callback
	--Generate items frame

	Knit.GetService("DataService"):GetKeyValue(InventoryWidget.inventoryType):andThen(function(inventoryItems: table)
		for itemID, itemTable in inventoryItems do
			--Filter the category
			--Get the tool to identify if it has texture
			local weapon : Tool = Weapons[itemID]
			if weapon.TextureId then
				local itemFrame = Assets.GuiObjects.Frames.ItemFrame:Clone()
				itemFrame.Parent = itemsFrame
				local formattedItemName = string.gsub(itemID, "_", " ")
				itemFrame.Frame:WaitForChild("ItemName").Text = formattedItemName
				itemFrame.Frame:WaitForChild("ItemIcon").Image = weapon.TextureId
				itemFrame.Frame.ItemIcon.Activated:Connect(function()
					ButtonWidget:OnActivation(itemFrame.Frame, function()
						InventoryWidget.state = "WeaponPreview"
						InventoryWidget:SetInventoryItemsVis(false)
						WeaponPreviewWidget:OpenPreview(itemID)
					end)
				end)
			end
		end
	end)
end

return InventoryWidget:Initialize()
