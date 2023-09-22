--Services
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
--Widgets
local WeaponCustomWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponCustomWidget)
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)

--Main
local WeaponPreviewWidget = {}
--Variables
local weaponPreviewGui
local itemPreviewFrame
local customizationButtonsFrame
local itemInfoFrame
local equipButtonFrame
local viewportFrame
local itemViewportModel
local dtrViewportFrame
--Connections
local viewportConnection

local customizationButtonsTweenInfo =
	TweenInfo.new(0.363, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, 0, false)

local function HideCustomizationAndEquipButtons()
	TweenService:Create(
		customizationButtonsFrame,
		customizationButtonsTweenInfo,
		{ Position = UDim2.fromScale(1, customizationButtonsFrame.Position.Y.Scale) }
	):Play()
	--Hide equip button
	TweenService:Create(
		equipButtonFrame,
		TweenInfo.new(0.363),
		{ Position = UDim2.fromScale(1, equipButtonFrame:GetAttribute("TargetPosition").Height.Scale) }
	):Play()
	--Hide item info
	TweenService:Create(itemInfoFrame, TweenInfo.new(0.363), { Position = UDim2.fromScale(-1, 0.112) }):Play()
end

local function ShowCustomizationAndEquipButtons()
	TweenService:Create(
		customizationButtonsFrame,
		customizationButtonsTweenInfo,
		{ Position = customizationButtonsFrame:GetAttribute("TargetPosition") }
	):Play()
	--Show equip button
	TweenService
		:Create(equipButtonFrame, TweenInfo.new(0.363), { Position = equipButtonFrame:GetAttribute("TargetPosition") })
		:Play()
	--Show item info
	TweenService
		:Create(itemInfoFrame, TweenInfo.new(0.363), { Position = itemInfoFrame:GetAttribute("TargetPosition") })
		:Play()
end

local function OpenCustomizationWidget(category: string)
	HideCustomizationAndEquipButtons()
	WeaponCustomWidget:OpenCustomization(
		WeaponPreviewWidget.weaponID,
		WeaponPreviewWidget.itemModel,
		category,
		ShowCustomizationAndEquipButtons
	)
end

local function SetupWeaponPreviewButtons()
	--Customization buttons
	itemPreviewFrame.ItemButtons.SkinsButton.Frame.BackgroundButton.Activated:Connect(function()
		ButtonWidget:OnActivation(itemPreviewFrame.ItemButtons.SkinsButton.Frame, function()
			OpenCustomizationWidget("Skins")
		end)
	end)
	itemPreviewFrame.ItemButtons.SkinsButton.Frame.IconButton.Activated:Connect(function()
		ButtonWidget:OnActivation(itemPreviewFrame.ItemButtons.SkinsButton.Frame, function()
			OpenCustomizationWidget("Skins")
		end)
	end)
	itemPreviewFrame.ItemButtons.ColorButton.Frame.BackgroundButton.Activated:Connect(function()
		ButtonWidget:OnActivation(itemPreviewFrame.ItemButtons.ColorButton.Frame, function()
			OpenCustomizationWidget("Color")
		end)
	end)
	itemPreviewFrame.ItemButtons.ColorButton.Frame.IconButton.Activated:Connect(function()
		ButtonWidget:OnActivation(itemPreviewFrame.ItemButtons.ColorButton.Frame, function()
			OpenCustomizationWidget("Color")
		end)
	end)
	--Preview equip buttons
	equipButtonFrame.BackgroundButton.Activated:Connect(function()
		ButtonWidget:OnActivation(equipButtonFrame, function()
			Knit.GetService("DataService"):SetWeaponEquipped(WeaponPreviewWidget.weaponID)
			local PlayerPreviewController = Knit.GetController("PlayerPreviewController")
			PlayerPreviewController:SpawnWeaponInCharacterMenu()
		end, "equip")
	end)
end

function WeaponPreviewWidget:Initialize()
	weaponPreviewGui = Assets.GuiObjects.ScreenGuis.WeaponPreviewGui
	itemPreviewFrame = weaponPreviewGui.ItemPreviewFrame
	itemInfoFrame = weaponPreviewGui.ItemInfoFrame
	customizationButtonsFrame = itemPreviewFrame.ItemButtons
	equipButtonFrame = itemPreviewFrame.EquipButtonFrame
	viewportFrame = itemPreviewFrame.ViewportFrame
	itemPreviewFrame.Position = UDim2.fromScale(1, 0.104)
	itemInfoFrame.Position = UDim2.fromScale(-1, 0.112)
	weaponPreviewGui.Parent = game.Players.LocalPlayer.PlayerGui
	weaponPreviewGui.Enabled = false

	SetupWeaponPreviewButtons()
	return WeaponPreviewWidget
end

function WeaponPreviewWidget:ClosePreview()
	local closePreviewTween =
		TweenService:Create(itemPreviewFrame, TweenInfo.new(0.363), { Position = UDim2.fromScale(1, 0) })
	local closeItemInfoTween =
		TweenService:Create(itemInfoFrame, TweenInfo.new(0.363), { Position = UDim2.fromScale(-1, 0.112) })
	closeItemInfoTween:Play()
	closePreviewTween:Play()
	closePreviewTween.Completed:Connect(function()
		itemViewportModel = nil
		viewportFrame:ClearAllChildren()
		viewportConnection:Disconnect()
		weaponPreviewGui.Enabled = false
		WeaponCustomWidget:CloseCustomization("Skins")
		WeaponCustomWidget:CloseCustomization("Color")
	end)
end

local function visualizeRay(pos, vector)
	local distance = vector.Magnitude
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Size = Vector3.new(0.5, 0.5, distance)
	p.BrickColor = BrickColor.Random()
	p.CanQuery = false
	p.CFrame = CFrame.lookAt(pos, pos+vector)*CFrame.new(0, 0, -distance/2-5)
	game.Debris:AddItem(p,1)
	return p
end

local function RaycastInViewportFrame(viewportFrame, raycastDistance, raycastParams)
	raycastDistance = raycastDistance or 1000
	local camera = viewportFrame.CurrentCamera
	local worldModel = viewportFrame:FindFirstChildWhichIsA("WorldModel")
	local mousePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset() - viewportFrame.AbsolutePosition -- account for viewportframe offset
	local relativePosition = ((mousePosition - (viewportFrame.AbsoluteSize/2)) * Vector2.new(1, -1))/(viewportFrame.AbsoluteSize/2) -- get the relative position of the click with center of viewportFrame as origin: -1 is left/bottom and 1 is right/top for X and Y respectively
	local projectedY = math.tan(math.rad(camera.FieldOfView)/2)*raycastDistance -- the projected height of a 2D frame raycastDistance studs from the camera with same aspect ratio
	local projectedX = projectedY * (viewportFrame.AbsoluteSize.X/viewportFrame.AbsoluteSize.Y) -- projected width from aspect ratio
	local projectedPosition = Vector2.new(projectedX, projectedY) * relativePosition -- the projected position of the input on the similar frame
	local worldPosition = (camera.CFrame * CFrame.new(projectedPosition.X, projectedPosition.Y, -raycastDistance)).Position -- the 3d position of said projected position
	
	-- local part = visualizeRay(camera.CFrame.Position, (worldPosition - camera.CFrame.Position).Unit * raycastDistance)
	-- part.Parent = workspace
	-- local part = visualizeRay(camera.CFrame.Position, (worldPosition - camera.CFrame.Position).Unit * raycastDistance)
	-- part.Parent = worldModel
	-- local part = visualizeRay(camera.CFrame.Position, (worldPosition - camera.CFrame.Position).Unit * raycastDistance)
	-- part.Parent = viewportFrame

	return worldModel:Raycast(camera.CFrame.Position, (worldPosition - camera.CFrame.Position).Unit * raycastDistance, raycastParams)
end

function WeaponPreviewWidget:OpenPreview(weaponID: string, callback)
	weaponPreviewGui.Enabled = true
	local camera = Instance.new("Camera")
	camera.Parent = weaponPreviewGui
	dtrViewportFrame = DragToRotateViewportFrame.New(viewportFrame, camera)
	TweenService:Create(itemPreviewFrame, TweenInfo.new(0.363), { Position = UDim2.fromScale(0, 0) }):Play()
	ShowCustomizationAndEquipButtons()
	--Set up item frame properties
	local formattedWeaponName = string.gsub(weaponID, "_", " ")
	itemInfoFrame.ItemTitleFrame.Title.Text = string.upper(formattedWeaponName)
	itemInfoFrame.Description.Text = ReplicatedStorage.Weapons[weaponID]:GetAttribute("Description") or ""
	--Generate world models
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local weaponModel = ReplicatedStorage.Weapons[weaponID]:Clone()
	--Check if the item is a tool get the model
	if weaponModel:IsA("Tool") then
		weaponModel = weaponModel:FindFirstChildOfClass("Model"):Clone()
	elseif weaponModel:IsA("Model") then
		weaponModel = weaponModel:Clone()
	end
	--Load up saved up customization
	WeaponCustomWidget:ApplySavedCustomization(weaponID, weaponModel)
	--Set up customization
	WeaponPreviewWidget.itemModel = weaponModel
	WeaponPreviewWidget.weaponID = weaponID
	--Set up the primary part
	worldModel.PrimaryPart = weaponModel.PrimaryPart
	weaponModel.Parent = worldModel

	dtrViewportFrame:SetModel(worldModel)
	dtrViewportFrame.MouseMode = "Default"

	viewportConnection = viewportFrame.InputBegan:Connect(function(inputObject)
		if
			inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch
			
		then			
			-- perform raycast
			local result = RaycastInViewportFrame(viewportFrame, 100)
			if result then
				print("Clicked part:", result.Instance.Name)
			end
			
			dtrViewportFrame:BeginDragging()

			inputObject.Changed:Connect(function()
				if inputObject.UserInputState == Enum.UserInputState.End then
					dtrViewportFrame:StopDragging()
				end
			end)
		end
	end)
end

return WeaponPreviewWidget:Initialize()
