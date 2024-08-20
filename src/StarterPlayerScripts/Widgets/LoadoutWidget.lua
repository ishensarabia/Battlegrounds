local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Utils
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
--Enums
local CurrenciesEnum = require(ReplicatedStorage.Source.Enums.CurrenciesEnum)
local LoadoutEnum = require(ReplicatedStorage.Source.Enums.LoadoutEnum)
--Controllers
local WidgetController = Knit.GetController("WidgetController")
--Assets
local Assets: Folder = ReplicatedStorage.Assets
local WeaponsFolder: Folder = ReplicatedStorage.Weapons
local GadgetsFolder: Folder = ReplicatedStorage.Gadgets
--Widget
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
local ObjectPreviewWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ObjectPreviewWidget)
--Main
local LoadoutWidget = {}
local loadoutGui
local inventoryMainFrame
--Variables
local categoryButtonsFrame
local loadoutButtonsFrame
local backButtonFrame
local BackButton
local showMainMenuCallback
local itemsFrame
local inventoryTitle
local backgroundImage
local player = Players.LocalPlayer

--Constants
local LOADOUT_TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

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
		LoadoutWidget.category = categoryButtonFrame:GetAttribute("Category")
		LoadoutWidget:SetInventoryItemsVis(false)
		ClearItemsFrame()
		LoadoutWidget:OpenLoadout(showMainMenuCallback)
	end
	for index, categoryButtonFrame in categoryButtonsFrame:GetChildren() do
		if categoryButtonFrame:IsA("Frame") then
			--Create the button
			ButtonWidget.new(categoryButtonFrame.Frame, function()
				openCategory(categoryButtonFrame)
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
end

local function SetupLoadoutButtons()
	for index, child in loadoutButtonsFrame:GetChildren() do
		if child:IsA("Frame") then
			--Create the button
			local ButtonWidget = ButtonWidget.new(child.Frame, function()
				SelectLoadoutSlot(child)
				LoadoutWidget:OpenLoadout(showMainMenuCallback)
			end)
		end
	end
end

function LoadoutWidget:CloseLoadout()
	local inventoryMainFrameTween =
		TweenService:Create(inventoryMainFrame, LOADOUT_TWEEN_INFO, { Position = UDim2.fromScale(-1, 0) })
	local backButtonFrameTween = TweenService:Create(
		backButtonFrame,
		LOADOUT_TWEEN_INFO,
		{ Position = UDim2.fromScale(-1, backButtonFrame.Position.Y.Scale), Transparency = 1 }
	)
	local backgroundImageTween = TweenService:Create(backgroundImage, LOADOUT_TWEEN_INFO, { ImageTransparency = 1 })
	ClearItemsFrame()
	inventoryMainFrameTween:Play()
	backButtonFrameTween:Play()
	backgroundImageTween:Play()
	self._isOpen = false
	--Reenable the core guis
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
end

function LoadoutWidget:SetInventoryItemsVis(condition)
	if condition then
		TweenService:Create(inventoryMainFrame, LOADOUT_TWEEN_INFO, { Position = UDim2.fromScale(0, 0) }):Play()
	else
		TweenService:Create(inventoryMainFrame, LOADOUT_TWEEN_INFO, { Position = UDim2.fromScale(1, 0) }):Play()
	end
end

local function SetupInventoryButtons()
	BackButton = ButtonWidget.new(loadoutGui.BackButtonFrame, function()
		if LoadoutWidget.state == "Items" then
			LoadoutWidget:CloseLoadout()
			showMainMenuCallback()
			ObjectPreviewWidget:ClosePreview()
		elseif LoadoutWidget.state == "WeaponPreview" then
			ObjectPreviewWidget:ClosePreview()
			LoadoutWidget:SetInventoryItemsVis(true)
			LoadoutWidget.state = "Items"
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
	--Connect buy weapon
	self._loadoutService = Knit.GetService("LoadoutService")
	self._loadoutService.WeaponBoughtSignal:Connect(function(weaponName)
		warn(weaponName)
		self:UnlockLoadoutItem(weaponName)
	end)

	player.AttributeChanged:Connect(function(attributeName)
		if attributeName == "Level" and self._isOpen then
			self:UpdateLoadout()
		end
	end)

	return LoadoutWidget
end

function LoadoutWidget:UpdateLoadout()
	-- Clear the items frame
	ClearItemsFrame()

	-- Open the loadout
	self:OpenLoadout(showMainMenuCallback)
end

function LoadoutWidget:UnlockLoadoutItem(weaponName)
	for _, itemFrame in (itemsFrame:GetChildren()) do
		if itemFrame:GetAttribute("Weapon") == weaponName then
			local padlockIcon = itemFrame.Frame.LockIcon
			local padlockRotationTween = TweenService:Create(
				padlockIcon,
				TweenInfo.new(1.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
				{ Rotation = 125 }
			)
			padlockRotationTween:Play()
			padlockRotationTween.Completed:Connect(function()
				local padlockPositionTween = TweenService:Create(
					padlockIcon,
					TweenInfo.new(1),
					{ Position = UDim2.fromScale(padlockIcon.Position.X.Scale, 0.99), ImageTransparency = 1 }
				)
				padlockPositionTween:Play()
				padlockPositionTween.Completed:Connect(function()
					padlockIcon.Visible = false
					--Create the equip button
					local equipButtonFrame = Assets.GuiObjects.Buttons.EquipButtonFrame:Clone()
					equipButtonFrame.Parent = itemFrame.Frame
					ButtonWidget.new(equipButtonFrame, function()
						self._loadoutService:SetWeaponEquipped(weaponName, self.slot)
						Knit.GetController("PlayerPreviewController"):SpawnWeaponInCharacterMenu()
					end)
					itemFrame.Frame.RequiredLevelTextLabel:Destroy()
				end)
			end)
			break
		end
	end
end

function LoadoutWidget:OpenLoadout(callback)
	--Hide the chat button so that it doesn't overlap with other buttons
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	--Reset the canvas position
	itemsFrame.CanvasPosition = Vector2.new(0, 0)

	if not self._isOpen then
		SelectLoadoutSlot(loadoutButtonsFrame.PrimaryFrame)
	end
	LoadoutWidget._isOpen = true
	LoadoutWidget.state = "Items"
	--Clean
	for index, child in itemsFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	loadoutGui.Enabled = true
	inventoryTitle.Text = string.upper("Loadout")
	local OpenLoadoutTween =
		TweenService:Create(inventoryMainFrame, LOADOUT_TWEEN_INFO, { Position = UDim2.fromScale(0, 0) })
	local backButtonFrameTween = TweenService:Create(
		backButtonFrame,
		LOADOUT_TWEEN_INFO,
		{ Position = backButtonFrame:GetAttribute("TargetPosition") }
	)
	local backgroundImageTween = TweenService:Create(backgroundImage, LOADOUT_TWEEN_INFO, { ImageTransparency = 0 })
	backgroundImageTween:Play()
	backButtonFrameTween:Play()
	OpenLoadoutTween:Play()

	showMainMenuCallback = callback
	--Generate items frame
	warn(self.category)
	warn(self.slot)

	if self.slot == LoadoutEnum.Slots.Gadget then
		Knit.GetService("DataService"):GetKeyValue("gadgets"):andThen(function(gadgets: table)
			warn(gadgets)
			for gadgetID, gadgetData: table in gadgets do
				local gadget: Tool = GadgetsFolder[gadgetID]
				if gadget.TextureId and gadget:GetAttribute("Slot"):lower() == self.slot then
					local gadgetFrame = WidgetController:CreateGadgetFrame(gadgetID, itemsFrame)
					--Assign the gadget attribute
					gadgetFrame:SetAttribute("Gadget", gadgetID)
					if not gadgetData.owned then
						Assets.GuiObjects.TextLabels.RequiredLevelTextLabel:Clone().Parent = gadgetFrame.Frame
						Assets.GuiObjects.Icons.LockIcon:Clone().Parent = gadgetFrame.Frame
						if player:GetAttribute("Level") >= gadget:GetAttribute("RequiredLevel") then
							local buyButtonFrame = Assets.GuiObjects.Buttons.BuyButtonFrame:Clone()
							buyButtonFrame.Parent = gadgetFrame.Frame

							gadgetFrame.Frame.BuyButtonFrame.BuyButton.PriceText.Text =
								FormatText.To_comma_value(gadget:GetAttribute("Price"))
							gadgetFrame.Frame.BuyButtonFrame.BuyButton.CurrencyIcon.Image =
								CurrenciesEnum.Icons[gadget:GetAttribute("Currency")]

							--Create buy button
							ButtonWidget.new(gadgetFrame.Frame.BuyButtonFrame, function()
								Knit.GetService("LoadoutService"):PurchaseGadget(gadgetID, false)
							end)
							gadgetFrame.Frame.RequiredLevelTextLabel.Text = string.format(
								"Level <font color='rgb(74, 188, 127)'><b>%s</b></font> required",
								gadget:GetAttribute("RequiredLevel")
							)
						else
							--Set up early buy button
							local earlyButtonFrame = Assets.GuiObjects.Buttons.BuyEarlyButtonFrame:Clone()
							earlyButtonFrame.Parent = gadgetFrame.Frame

							earlyButtonFrame.BuyEarlyButton.PriceText.Text =
								FormatText.To_comma_value(gadget:GetAttribute("EarlyPrice"))
							earlyButtonFrame.BuyEarlyButton.CurrencyIcon.Image =
								CurrenciesEnum.Icons[gadget:GetAttribute("EarlyCurrency")]

							--Create early buy button
							ButtonWidget.new(gadgetFrame.Frame.BuyEarlyButtonFrame, function()
								Knit.GetService("LoadoutService"):PurchaseGadget(gadgetID, true):andThen(function(result)
									if result then
										earlyButtonFrame:Destroy()
									end
								end)
							end)

							gadgetFrame.Frame.RequiredLevelTextLabel.Text = string.format(
								"Level <font color='rgb(255, 125, 0)'><b>%s</b></font> required",
								gadget:GetAttribute("RequiredLevel"))
							
						end
					else
						Assets.GuiObjects.Buttons.EquipButtonFrame:Clone().Parent = gadgetFrame.Frame
						--Create equip button
						ButtonWidget.new(gadgetFrame.Frame.EquipButtonFrame, function()
							self._loadoutService:SetGadgetEquipped(gadgetID, self.slot)
							Knit.GetController("PlayerPreviewController"):SpawnGadgetInCharacterMenu()
						end)
					end

					ButtonWidget.new(gadgetFrame.Frame, function()
						LoadoutWidget.state = "WeaponPreview"
						LoadoutWidget:SetInventoryItemsVis(false)
						ObjectPreviewWidget:OpenPreview(gadgetID, self.slot)
					end)
				end
			end
		end)
	end

	if self.slot == LoadoutEnum.Slots.Primary or self.slot == LoadoutEnum.Slots.Secondary then
		Knit.GetService("DataService"):GetKeyValue("weapons"):andThen(function(weapons: table)
			for weaponID, weaponData: table in weapons do
				--Filter the category
				--Get the tool to identify if it has texture
				local weapon: Tool = WeaponsFolder[weaponID]
				if weapon.TextureId and weapon:GetAttribute("Slot"):lower() == self.slot then
					local weaponFrame = WidgetController:CreateWeaponFrame(weaponID, itemsFrame)
					--Assign the weaon attribute
					weaponFrame:SetAttribute("Weapon", weaponID)
	
					if not weaponData.owned then
						Assets.GuiObjects.TextLabels.RequiredLevelTextLabel:Clone().Parent = weaponFrame.Frame
						Assets.GuiObjects.Icons.LockIcon:Clone().Parent = weaponFrame.Frame
						if player:GetAttribute("Level") >= weapon:GetAttribute("RequiredLevel") then
							local buyButtonFrame = Assets.GuiObjects.Buttons.BuyButtonFrame:Clone()
							buyButtonFrame.Parent = weaponFrame.Frame
	
							weaponFrame.Frame.BuyButtonFrame.BuyButton.PriceText.Text =
								FormatText.To_comma_value(weapon:GetAttribute("Price"))
							weaponFrame.Frame.BuyButtonFrame.BuyButton.CurrencyIcon.Image =
								CurrenciesEnum.Icons[weapon:GetAttribute("Currency")]
	
							--Create buy button
							ButtonWidget.new(weaponFrame.Frame.BuyButtonFrame, function()
								Knit.GetService("LoadoutService"):PurchaseWeapon(weaponID, false)
							end)
							weaponFrame.Frame.RequiredLevelTextLabel.Text = string.format(
								"Level <font color='rgb(74, 188, 127)'><b>%s</b></font> required",
								weapon:GetAttribute("RequiredLevel")
							)
						else
							--Set up early buy button
							local earlyButtonFrame = Assets.GuiObjects.Buttons.BuyEarlyButtonFrame:Clone()
							earlyButtonFrame.Parent = weaponFrame.Frame
	
							earlyButtonFrame.BuyEarlyButton.PriceText.Text =
								FormatText.To_comma_value(weapon:GetAttribute("EarlyPrice"))
							earlyButtonFrame.BuyEarlyButton.CurrencyIcon.Image =
								CurrenciesEnum.Icons[weapon:GetAttribute("EarlyCurrency")]
	
							--Create early buy button
							ButtonWidget.new(weaponFrame.Frame.BuyEarlyButtonFrame, function()
								Knit.GetService("LoadoutService"):PurchaseWeapon(weaponID, true):andThen(function(result)
									if result then
										earlyButtonFrame:Destroy()
									end
								end)
							end)
	
							weaponFrame.Frame.RequiredLevelTextLabel.Text = string.format(
								"Level <font color='rgb(255, 125, 0)'><b>%s</b></font> required",
								weapon:GetAttribute("RequiredLevel")
							)
						end
					else
						Assets.GuiObjects.Buttons.EquipButtonFrame:Clone().Parent = weaponFrame.Frame
						--Create equip button
						ButtonWidget.new(weaponFrame.Frame.EquipButtonFrame, function()
							self._loadoutService:SetWeaponEquipped(weaponID, self.slot)
							Knit.GetController("PlayerPreviewController"):SpawnWeaponInCharacterMenu()
						end)
					end
	
					ButtonWidget.new(weaponFrame.Frame, function()
						LoadoutWidget.state = "WeaponPreview"
						LoadoutWidget:SetInventoryItemsVis(false)
						ObjectPreviewWidget:OpenPreview(weaponID, self.slot)
					end)
				end
			end
		end)
	end

	

end

return LoadoutWidget:Initialize()
