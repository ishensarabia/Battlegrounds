--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Main
local WeaponCustomizationWidget = {}
--Variables
local weaponCustomizationGui
local colorFrame
local skinsFrame
local partsFrame
local backButtonCallback

WeaponCustomizationWidget.weaponPartsFrames = {}
WeaponCustomizationWidget.customParts = {}

local partNumberDictionary = {
	[1] = "Primary Part",
	[2] = "Secondary Part",
	[3] = "Tertiary Part",
	[4] = "Quaternary Part"
}

local function SetupCustomizationButtons()
	weaponCustomizationGui.BackButtonFrame.Button.Activated:Connect(function()
		ButtonWidget:OnActivation(weaponCustomizationGui.BackButtonFrame, backButtonCallback)
		WeaponCustomizationWidget:CloseCustomization(WeaponCustomizationWidget.customizationCategory)
	end)
	weaponCustomizationGui.ConfirmButtonFrame.BackgroundButton.Activated:Connect(function()
		ButtonWidget:OnActivation(weaponCustomizationGui.ConfirmButtonFrame, function()
			backButtonCallback()
			WeaponCustomizationWidget:CloseCustomization(WeaponCustomizationWidget.customizationCategory)
			--Save the customization
			for index, customPart in WeaponCustomizationWidget.customParts do
				Knit.GetService("DataService"):ApplyWeaponCustomization(
					WeaponCustomizationWidget.itemID,
					customPart:GetAttribute("CustomPart"),
					customPart:GetAttribute("CustomizationValue"),
					WeaponCustomizationWidget.customizationCategory
				)
			end
			--Reload character
			local PlayerPreviewController = Knit.GetController("PlayerPreviewController")
			PlayerPreviewController:SpawnWeaponInCharacterMenu()
		end)
	end)
	weaponCustomizationGui.CancelButtonFrame.BackgroundButton.Activated:Connect(function()
		ButtonWidget:OnActivation(weaponCustomizationGui.CancelButtonFrame, function()
			backButtonCallback()
			WeaponCustomizationWidget:CloseCustomization(WeaponCustomizationWidget.customizationCategory)
		end)
	end)
end

local function SetupCustomizationFrameButtons()
	for index, colorButtonFrame in colorFrame:GetChildren() do
		if colorButtonFrame:IsA("Frame") then
			colorButtonFrame.Frame.IconButton.Activated:Connect(function()
				ButtonWidget:OnActivation(colorButtonFrame.Frame, function()
					WeaponCustomizationWidget:SetModification(colorButtonFrame.Frame.IconButton.BackgroundColor3)
				end)
			end)
			colorButtonFrame.Frame.BackgroundButton.Activated:Connect(function()
				ButtonWidget:OnActivation(colorButtonFrame.Frame, function()
					WeaponCustomizationWidget:SetModification(colorButtonFrame.Frame.IconButton.BackgroundColor3)
				end)
			end)
		end
	end
end

local function ClearPartsFrame()
	for index, value in WeaponCustomizationWidget.weaponPartsFrames do
		value:Destroy()
	end
end

local function SelectWeaponPart(weaponPartNumber: number, customPartFrame)
	WeaponCustomizationWidget.weaponPartNumber = weaponPartNumber
	if WeaponCustomizationWidget.currentEditingPart then
		--Toggle other parts
		for index, partFrame in WeaponCustomizationWidget.weaponPartsFrames do
			TweenService:Create(partFrame.Frame.SelectionBackground, TweenInfo.new(0.339), { ImageTransparency = 1 })
				:Play()
		end
		--Toggle the new part
		WeaponCustomizationWidget.currentEditingPart = WeaponCustomizationWidget.customParts[weaponPartNumber]
		TweenService:Create(customPartFrame.Frame.SelectionBackground, TweenInfo.new(0.339), { ImageTransparency = 0 })
			:Play()
	else
		WeaponCustomizationWidget.currentEditingPart = WeaponCustomizationWidget.customParts[weaponPartNumber]
		TweenService:Create(customPartFrame.Frame.SelectionBackground, TweenInfo.new(0.339), { ImageTransparency = 0 })
			:Play()
	end
end

function WeaponCustomizationWidget:GenerateWeaponParts(weaponModel)
	for index, value in weaponModel:GetDescendants() do
		if value:GetAttribute("CustomPart") then
			WeaponCustomizationWidget.customParts[value:GetAttribute("CustomPart")] = value
		end
	end
end

local function GenerateWeaponPartsFrames()
	for index, value in WeaponCustomizationWidget.model:GetDescendants() do
		if value:GetAttribute("CustomPart") then
			--Store the custom part
			WeaponCustomizationWidget.customParts[value:GetAttribute("CustomPart")] = value
			local customPartFrame = Assets.GuiObjects.Frames.PartTemplateFrame:Clone()
			customPartFrame.Parent = partsFrame
			customPartFrame.LayoutOrder = value:GetAttribute("CustomPart")
			customPartFrame.Frame.Number.Text = value:GetAttribute("CustomPart")
			customPartFrame.Frame.Word.Text = partNumberDictionary[value:GetAttribute("CustomPart")]
			WeaponCustomizationWidget.weaponPartsFrames[value:GetAttribute("CustomPart")] = customPartFrame
			customPartFrame.Frame.BackgroundButton.Activated:Connect(function()
				ButtonWidget:OnActivation(customPartFrame.Frame, function()
					SelectWeaponPart(value:GetAttribute("CustomPart"), customPartFrame)
				end)
			end)
		end
	end
end

function WeaponCustomizationWidget:Initialize()
	weaponCustomizationGui = Assets.GuiObjects.ScreenGuis.WeaponCustomizationGui
	colorFrame = weaponCustomizationGui:WaitForChild("ColorFrame")
	skinsFrame = weaponCustomizationGui:WaitForChild("SkinsFrame")
	partsFrame = weaponCustomizationGui:WaitForChild("ItemPartsFrame")
	--set the initial position for the frames
	colorFrame.Position = UDim2.fromScale(1, colorFrame.Position.Y.Scale)
	skinsFrame.Position = UDim2.fromScale(-1, skinsFrame.Position.Y.Scale)
	partsFrame.Position = UDim2.fromScale(1, partsFrame.Position.Y.Scale)
	weaponCustomizationGui.Parent = game.Players.LocalPlayer.PlayerGui
	weaponCustomizationGui.Enabled = false

	SetupCustomizationButtons()
	return WeaponCustomizationWidget
end

function WeaponCustomizationWidget:SetModification(customizationValue, customNumberPart: number)
	if typeof(customizationValue) == "Color3" then
		if customNumberPart then
			-- warn("Customization value: " .. tostring(customizationValue) .. "Custom part number: " .. customNumberPart)
			WeaponCustomizationWidget.currentEditingPart = WeaponCustomizationWidget.customParts[customNumberPart]
		end
		WeaponCustomizationWidget.currentEditingPart.Color = customizationValue
		--Assign the customization selected
		WeaponCustomizationWidget.currentEditingPart:SetAttribute("CustomizationValue", customizationValue)
	end
end

function WeaponCustomizationWidget:CloseCustomization(category: string)
	local customCategoryFrame = weaponCustomizationGui[category .. "Frame"]
	local closePartselectorTween = TweenService:Create(
		partsFrame,
		TweenInfo.new(0.363),
		{ Position = UDim2.fromScale(1, partsFrame.Position.Y.Scale) }
	)
	closePartselectorTween:Play()
	closePartselectorTween.Completed:Wait()
	ClearPartsFrame()
	local closeCustomizationTween = TweenService:Create(
		customCategoryFrame,
		TweenInfo.new(0.363),
		{ Position = UDim2.fromScale(1, customCategoryFrame:GetAttribute("TargetPosition").Y) }
	)
	closeCustomizationTween:Play()
	closeCustomizationTween.Completed:Connect(function(playbackState)
		weaponCustomizationGui.Enabled = false
	end)
end

function WeaponCustomizationWidget:OpenCustomization(itemID: string, itemModel: Model, category: string, callback)
	WeaponCustomizationWidget.model = itemModel
	WeaponCustomizationWidget.itemID = itemID
	GenerateWeaponPartsFrames()
	WeaponCustomizationWidget.customizationCategory = category
	backButtonCallback = callback
	weaponCustomizationGui.Enabled = true
	local customCategoryFrame = weaponCustomizationGui[category .. "Frame"]
	--Open part selector
	local openItemPartsSelectorTween =
		TweenService:Create(partsFrame, TweenInfo.new(0.363), { Position = partsFrame:GetAttribute("TargetPosition") })
	openItemPartsSelectorTween:Play()
	openItemPartsSelectorTween.Completed:Wait()
	--Set initial custom part number
	SelectWeaponPart(1, WeaponCustomizationWidget.weaponPartsFrames[1])
	--Open customization frame selected
	local openCustomizationTween = TweenService:Create(
		customCategoryFrame,
		TweenInfo.new(0.363),
		{ Position = customCategoryFrame:GetAttribute("TargetPosition") }
	)
	openCustomizationTween:Play()
end

function WeaponCustomizationWidget:ApplySavedCustomization(weaponID, weaponModel)
	--Apply saved customization
	Knit.GetService("DataService"):GetWeaponCustomization(weaponID):andThen(function(weaponCustom)
		SetupCustomizationFrameButtons()
		if weaponCustom then
			WeaponCustomizationWidget:GenerateWeaponParts(weaponModel)
			WeaponCustomizationWidget:ApplyCustomization(weaponCustom)
		end
	end)
end

function WeaponCustomizationWidget:ApplyCustomization(weaponCustomization: table)
	for partNumber, customizationValueTable in weaponCustomization do
		if customizationValueTable.Color then
			WeaponCustomizationWidget:SetModification(customizationValueTable.Color, partNumber)
		end
	end
end

return WeaponCustomizationWidget:Initialize()
