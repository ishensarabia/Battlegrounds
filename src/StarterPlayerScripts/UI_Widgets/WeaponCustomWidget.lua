--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Knit Services
local DataService
local CustomizationItemsFrame
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
--Config
local RARITIES_CONSTANTS = require(script.Parent.Configuration.RaritiesConstants)
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Main
local WeaponCustomizationWidget = {}
--Gui objects
local weaponCustomizationGui
local customizationItemsFrame
local partsFrame
local removeSkinButtonFrame
--Variables
local backButtonCallback
local RARITIES_COLORS = {
	Common = Color3.fromRGB(39, 180, 126),
	Rare = Color3.fromRGB(0, 132, 255),
	Epic = Color3.fromRGB(223, 226, 37),
	Legendary = Color3.fromRGB(174, 56, 204),
	Mythic = Color3.fromRGB(184, 17, 17),
}

WeaponCustomizationWidget.weaponPartsFrames = {}
WeaponCustomizationWidget.customParts = {}

local function SetupCustomizationButtons()
	weaponCustomizationGui.BackButtonFrame.Button.Activated:Connect(function()
		ButtonWidget:OnActivation(weaponCustomizationGui.BackButtonFrame, backButtonCallback)
		WeaponCustomizationWidget:CloseCustomization(WeaponCustomizationWidget.customizationCategory)
	end)
	weaponCustomizationGui.ConfirmButtonFrame.IconButton.Activated:Connect(function()
		ButtonWidget:OnActivation(weaponCustomizationGui.ConfirmButtonFrame, function()
			backButtonCallback()
			WeaponCustomizationWidget:CloseCustomization(WeaponCustomizationWidget.customizationCategory)
			--Save the customization
			for index, customPart in WeaponCustomizationWidget.customParts do
				warn(customPart:GetAttribute("CustomizationValue"))
				DataService:SaveWeaponCustomization(
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
	weaponCustomizationGui.CancelButtonFrame.IconButton.Activated:Connect(function()
		ButtonWidget:OnActivation(weaponCustomizationGui.CancelButtonFrame, function()
			backButtonCallback()
			WeaponCustomizationWidget:CloseCustomization(WeaponCustomizationWidget.customizationCategory)
		end)
	end)
end
local function ClearPartsFrame()
	for index, value in WeaponCustomizationWidget.weaponPartsFrames do
		value:Destroy()
	end
	table.clear(WeaponCustomizationWidget.weaponPartsFrames)
end

local function setTransparencyForWeaponParts(model, value: number)
	for index, child in model:GetChildren() do
		for index, child in child:GetChildren() do
			if child:IsA("Texture") then
				child.Transparency = value
			end
		end
		child.Transparency = value
	end
end

-- local function SelectWeaponPart(weaponPartName: string, customPartFrame)
-- 	WeaponCustomizationWidget.weaponPartName = weaponPartName

-- 	--Check if the part has a texture to show the remove skin button
-- 	if WeaponCustomizationWidget.currentEditingPart:FindFirstChild("Skin") then
-- 		weaponCustomizationGui.RemoveSkinButtonFrame.Visible = true
-- 		--Connect the remove skin button
-- 		weaponCustomizationGui.RemoveSkinButtonFrame.BackgroundButton.Activated:Connect(function()
-- 			ButtonWidget:OnActivation(weaponCustomizationGui.RemoveSkinButtonFrame, function()
-- 				WeaponCustomizationWidget:RemoveSkin(weaponPartName)
-- 				weaponCustomizationGui.RemoveSkinButtonFrame.Visible = false
-- 			end)
-- 		end)
-- 	else
-- 		weaponCustomizationGui.RemoveSkinButtonFrame.Visible = false
-- 	end
-- end

function WeaponCustomizationWidget:SelectWeaponPart(weaponPartName: string)
	WeaponCustomizationWidget.weaponPartName = weaponPartName
	WeaponCustomizationWidget.currentEditingPart = WeaponCustomizationWidget.customParts[weaponPartName]
end

function WeaponCustomizationWidget:GenerateWeaponParts(weaponModel)
	if #WeaponCustomizationWidget.customParts > 0 then
		table.clear(WeaponCustomizationWidget.customParts)
	end
	for index, value in weaponModel:GetDescendants() do
		if value:GetAttribute("CustomPart") then
			WeaponCustomizationWidget.customParts[value:GetAttribute("CustomPart")] = value
		end
	end
end
local function splitTitleCaps(str)
	str = str:gsub("(%u)", " %1")
	return str:gsub("^%s", "")
end

function WeaponCustomizationWidget:Initialize()
	weaponCustomizationGui = Assets.GuiObjects.ScreenGuis.WeaponCustomizationGui
	customizationItemsFrame = weaponCustomizationGui:WaitForChild("CustomizationItemsFrame")
	partsFrame = weaponCustomizationGui:WaitForChild("ItemPartsFrame")
	--set the initial position for the frames
	customizationItemsFrame.Position = UDim2.fromScale(1, customizationItemsFrame.Position.Y.Scale)
	partsFrame.Position = UDim2.fromScale(1, partsFrame.Position.Y.Scale)
	weaponCustomizationGui.Parent = game.Players.LocalPlayer.PlayerGui
	weaponCustomizationGui.Enabled = false

	return WeaponCustomizationWidget
end

function WeaponCustomizationWidget:SetModification(customizationValue, customPartName: string)
	if customPartName then
		WeaponCustomizationWidget.currentEditingPart = WeaponCustomizationWidget.customParts[customPartName]
	end
	if customizationValue and WeaponCustomizationWidget.currentEditingPart then
		if typeof(customizationValue) == "Color3" then
			WeaponCustomizationWidget.currentEditingPart.Color = customizationValue
		end
		if typeof(customizationValue) == "string" then
			--check if the textures haven't been created
			if
				WeaponCustomizationWidget.currentEditingPart
				and WeaponCustomizationWidget.currentEditingPart:FindFirstChild("Skin")
			then
				--loop to apply the texture to all the faces
				for index, child in WeaponCustomizationWidget.currentEditingPart:GetChildren() do
					if child:IsA("Texture") then
						child.Texture = customizationValue
					end
				end
			else
				local textures = {}
				for i = 1, 6, 1 do
					local texture = Instance.new("Texture")
					texture.Name = "Skin"
					texture.StudsPerTileU = 0.2
					texture.StudsPerTileV = 0.3
					texture.Texture = customizationValue
					table.insert(textures, texture)
					texture.Parent = WeaponCustomizationWidget.currentEditingPart
				end
				textures[1].Face = Enum.NormalId.Back
				textures[2].Face = Enum.NormalId.Bottom
				textures[3].Face = Enum.NormalId.Front
				textures[4].Face = Enum.NormalId.Left
				textures[5].Face = Enum.NormalId.Right
				textures[6].Face = Enum.NormalId.Top
			end
		end
		--Assign the customization selected
		WeaponCustomizationWidget.currentEditingPart:SetAttribute("CustomizationValue", customizationValue)
	end
end

--Remove skin from the part function
function WeaponCustomizationWidget:RemoveSkin(customPartName: string)
	if customPartName then
		WeaponCustomizationWidget.currentEditingPart = WeaponCustomizationWidget.customParts[customPartName]
	end
	if WeaponCustomizationWidget.currentEditingPart then
		--loop to apply the texture to all the faces
		for index, child in WeaponCustomizationWidget.currentEditingPart:GetChildren() do
			if child:IsA("Texture") then
				child:Destroy()
			end
		end
	end
	--Mark the customization value attribute to remove the skin
	WeaponCustomizationWidget.currentEditingPart:SetAttribute("CustomizationValue", "RemoveSkin")
end

function WeaponCustomizationWidget:CloseCustomization(category: string)
	WeaponCustomizationWidget.isActive = false
	local closePartselectorTween = TweenService:Create(
		partsFrame,
		TweenInfo.new(0.363),
		{ Position = UDim2.fromScale(1, partsFrame.Position.Y.Scale) }
	)
	closePartselectorTween:Play()
	closePartselectorTween.Completed:Wait()
	ClearPartsFrame()
	local closeCustomizationTween = TweenService:Create(
		customizationItemsFrame,
		TweenInfo.new(0.363),
		{ Position = UDim2.fromScale(1, customizationItemsFrame:GetAttribute("TargetPosition").Y) }
	)
	closeCustomizationTween:Play()
	closeCustomizationTween.Completed:Wait()
	setTransparencyForWeaponParts(WeaponCustomizationWidget.model, 0)
	weaponCustomizationGui.Enabled = false
	weaponCustomizationGui.RemoveSkinButtonFrame.Visible = false
	--Clean the customizationItemsFrame buttons frames
	for index, child in customizationItemsFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function GenerateSkinsButtons()
	local Skins = require(ReplicatedStorage.Source.Assets.Skins)
	if not DataService then
		DataService = Knit.GetService("DataService")
	end
	DataService:GetKeyValue("Skins"):andThen(function(skins: table)
		for skinName, skinAmount in skins do
			local skinName = string.gsub(skinName, "-", "")
			skinName = string.gsub(skinName, " ", "")
			skinName = string.gsub(skinName, "_", "")
			skinName = string.gsub(skinName, "&", "")
			warn(skinName)

			local customizationButtonFrame = Assets.GuiObjects.Frames.CustomizationButtonFrame:Clone()
			customizationButtonFrame.Name = skinName
			customizationButtonFrame.Parent = customizationItemsFrame
			customizationButtonFrame.Frame.IconButton.Image = Skins[skinName].skinID
			customizationButtonFrame.Frame.Title.Text = splitTitleCaps(skinName)
			-- customizationButtonFrame.Frame.BackgroundButton.ImageColor3 = RARITIES_COLORS[skinAmount.Rarity]

			--Connect the button
			customizationButtonFrame.Frame.IconButton.Activated:Connect(function()
				ButtonWidget:OnActivation(customizationButtonFrame.Frame, function()
					WeaponCustomizationWidget:SetModification(Skins[skinName].skinID)
					--Assign the current selection but check if there's a previous one
					if not WeaponCustomizationWidget.currentSkinSelected then
						WeaponCustomizationWidget.currentSkinSelected = customizationButtonFrame
					else
						WeaponCustomizationWidget.currentSkinSelected.Frame.SelectionButton.Visible = false
						WeaponCustomizationWidget.currentSkinSelected = customizationButtonFrame
					end
					customizationButtonFrame.Frame.SelectionButton.Visible = true
				end)
			end)
		end
	end)
end

local function GenerateColorButtons()
	if not DataService then
		DataService = Knit.GetService("DataService")
	end
	local colors = DataService:GetKeyValue(game.Players.LocalPlayer, "Colors")
end

local partNumberDictionary = {
	[1] = "Primary Part",
	[2] = "Secondary Part",
	[3] = "Tertiary Part",
	[4] = "Quaternary Part",
}

local function GenerateWeaponPartsFrames()
	for index, child in WeaponCustomizationWidget.model:GetDescendants() do
		if child:GetAttribute("CustomPart") then
			--Store the custom part
			WeaponCustomizationWidget.customParts[child:GetAttribute("CustomPart")] = child
			local customPartFrame = Assets.GuiObjects.Frames.PartTemplateFrame:Clone()
			customPartFrame.Parent = partsFrame
			customPartFrame.LayoutOrder = child:GetAttribute("CustomPart")
			customPartFrame.Frame.Number.Text = index
			customPartFrame.Frame.Word.Text = child:GetAttribute("CustomPart")
			WeaponCustomizationWidget.weaponPartsFrames[child:GetAttribute("CustomPart")] = customPartFrame
			customPartFrame.LayoutOrder = index
			customPartFrame.Frame.Number.Text = index
			customPartFrame.Frame.Word.Text = child:GetAttribute("CustomPart")
			WeaponCustomizationWidget.weaponPartsFrames[child:GetAttribute("CustomPart")] = customPartFrame
			customPartFrame.Frame.BackgroundButton.Activated:Connect(function()
				ButtonWidget:OnActivation(customPartFrame.Frame, function()
					WeaponCustomizationWidget:SelectWeaponPart(child:GetAttribute("CustomPart"))
				end)
			end)
		end
	end
end

function WeaponCustomizationWidget:OpenCustomization(
	itemID: string,
	itemModel: Model,
	category: string,
	isWeaponOwned: boolean,
	callback: any
)
	WeaponCustomizationWidget.isActive = true
	WeaponCustomizationWidget.model = itemModel
	WeaponCustomizationWidget.isWeaponOwned = isWeaponOwned
	WeaponCustomizationWidget.itemID = itemID
	GenerateWeaponPartsFrames()
	WeaponCustomizationWidget.customizationCategory = category
	backButtonCallback = callback
	weaponCustomizationGui.Enabled = true
	if category == "Skins" then
		GenerateSkinsButtons()
	end
	--Open part selector
	local openItemPartsSelectorTween =
		TweenService:Create(partsFrame, TweenInfo.new(0.363), { Position = partsFrame:GetAttribute("TargetPosition") })
	openItemPartsSelectorTween:Play()
	openItemPartsSelectorTween.Completed:Wait()
	--Set initial custom part number
	-- SelectWeaponPart(1, WeaponCustomizationWidget.weaponPartsFrames[1])
	--Open customization frame selected
	customizationItemsFrame.Visible = true
	local openCustomizationTween = TweenService:Create(
		customizationItemsFrame,
		TweenInfo.new(0.363),
		{ Position = customizationItemsFrame:GetAttribute("TargetPosition") }
	)
	SetupCustomizationButtons()
	openCustomizationTween:Play()
end

function WeaponCustomizationWidget:ApplySavedCustomization(weaponID, weaponModel)
	if not DataService then
		DataService = Knit.GetService("DataService")
	end
	--Apply saved customization
	DataService:GetWeaponCustomization(weaponID):andThen(function(weaponCustom)
		if weaponCustom then
			WeaponCustomizationWidget:GenerateWeaponParts(weaponModel)
			WeaponCustomizationWidget:ApplyCustomization(weaponCustom)
		end
	end)
end

function WeaponCustomizationWidget:ApplyCustomization(weaponCustomization: table)
	for partNumber, customizationValueTable in weaponCustomization do
		--Check if the part has a color
		if customizationValueTable.Color then
			WeaponCustomizationWidget:SetModification(customizationValueTable.Color, partNumber)
		end
		--Check if the part has a skin
		if customizationValueTable.Skin then
			WeaponCustomizationWidget:SetModification(customizationValueTable.Skin, partNumber)
		end
	end
end

return WeaponCustomizationWidget:Initialize()
