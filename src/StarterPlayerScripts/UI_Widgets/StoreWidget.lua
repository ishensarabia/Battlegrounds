--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Packages = game.ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
--Services
local StoreService = Knit.GetService("StoreService")
--Widgets
local HoverWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.HoverWidget)
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
--Main
local StoreWidget = {}
StoreWidget.viewportConnections = {}
--Constants
local STORE_CATEGORIES = {
	DailyItems = "DailyItems",
	Crates = "Crates",
	BattleGems = "BattleGems",
	BattleCoins = "BattleCoins",
}
local BUNDLE_CATEGORIES = {
	BattleCoins = "BattleCoins_Bundles",
	BattleGems = "BattleGems_Bundles",
}
local CURRENCY_ICONS = {
	BattleCoins_Bundles = "rbxassetid://10835882861",
	BattleGems_Bundles = "rbxassetid://10835980573",
}
local DISTANCE_PER_BUNDLE = {
	Small = 1.6,
	Medium = 1.4,
	Large = 1,
	Huge = 0.9,
	Gigantic = 0.8,
	Astronomic = 0.69,
}
--Screen guis
local StoreGui
--Gui objects
local FeaturedItemsFrame
local DailyItemsMainFrame
local CategoriesFrame
local ItemsScrollingFrame

local buttonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0)

local function HideStoreContents(shouldTween: boolean)
	for index, child in StoreGui:GetChildren() do
		if child:IsA("GuiObject") then
			if shouldTween then
				local tween = TweenService:Create(child, TweenInfo.new(0.09), { Size = UDim2.new(0, 0, 0, 0) })
				tween:Play()
				tween.Completed:Wait()
			else
				child.Size = UDim2.new(0, 0, 0, 0)
			end
		end
	end
end

local function ShowDailyItems()
	--Show the daily items main frame
	DailyItemsMainFrame.Size = UDim2.new(0, 0, 0, 0)
	DailyItemsMainFrame.Visible = true
	local tween = TweenService:Create(DailyItemsMainFrame, TweenInfo.new(0.09), { Size = UDim2.new(1, 0, 1, 0) })
	tween:Play()
	tween.Completed:Wait()
end

local function HideDailyItems()
	--Hide the items scrolling frame by tweening the size
	local tween = TweenService:Create(DailyItemsMainFrame, TweenInfo.new(0.09), { Size = UDim2.new(0, 0, 0, 0) })
	tween:Play()
	tween.Completed:Wait()
end

local function HideItemsScrollingFrame()
	--Hide the items scrolling frame by tweening the size
	local tween = TweenService:Create(ItemsScrollingFrame, TweenInfo.new(0.09), { Size = UDim2.new(0, 0, 0, 0) })
	tween:Play()
	tween.Completed:Wait()
end

--Show ItemsScrollingFrame
local function ShowItemsScrollingFrame()
	--Show the items scrolling frame by tweening the size
	local tween = TweenService:Create(
		ItemsScrollingFrame,
		TweenInfo.new(0.09),
		{ Size = ItemsScrollingFrame:GetAttribute("TargetSize") }
	)
	tween:Play()
	tween.Completed:Wait()
end

function StoreWidget:Initialize()
	--Initialize the screen guis
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("StoreGui") then
		StoreGui = Assets.GuiObjects.ScreenGuis.StoreGui or game.Players.LocalPlayer.PlayerGui.StoreGui
		StoreGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		StoreGui = game.Players.LocalPlayer.PlayerGui.StoreGui
	end

	--Initialize the gui objects
	FeaturedItemsFrame = StoreGui.DailyItemsMainFrame.FeaturedItemsFrame
	DailyItemsMainFrame = StoreGui.DailyItemsMainFrame
	CategoriesFrame = StoreGui.CategoriesFrame
	ItemsScrollingFrame = StoreGui.ItemsScrollingFrame
	StoreGui.Enabled = false
	--Hide the gui objects by size for animation purposes
	HideStoreContents()
	--Connect the categories buttons
	for index, child in CategoriesFrame:GetChildren() do
		if child:IsA("Frame") then
			child.button.Activated:Connect(function()
				ButtonWidget:OnActivation(child, function()
					StoreWidget:OpenStore(child:GetAttribute("Category"))
				end)
			end)
		end
	end
	--Connect store signals
	StoreService.CratePurchaseSignal:Connect(function(crateName: string, totalAmountOfCrates: number)
		ItemsScrollingFrame[crateName].OpenButton.Visible = true
		--Add the crate amount to the open button text
		ItemsScrollingFrame[crateName].OpenButton.Text.Text = "Open (" .. tostring(totalAmountOfCrates) .. ")"
	end)
	StoreService.OpenCrateSignal:Connect(function(crate: table, rewardChosen: table, cratesLeft: number, crateName : string)
		ItemsScrollingFrame[crateName].OpenButton.Text.Text = "Open (" .. tostring(cratesLeft) .. ")"
		if cratesLeft == 0 then
			ItemsScrollingFrame[crateName].OpenButton.Visible = false
		end
	end)

	--Return the widget
	return StoreWidget
end
local function playOpenStoreAnimation(category: string)
	if not StoreGui.Enabled then
		StoreGui.Enabled = true
		for index, child in StoreGui:GetChildren() do
			if child:IsA("GuiObject") then
				TweenService:Create(child, TweenInfo.new(0.39), { Size = child:GetAttribute("TargetSize") }):Play()
			end
		end
	end
	if category == "DailyItems" then
		HideItemsScrollingFrame()
		ShowDailyItems()
	end
	if category == "Crates" or category == "BattleGems" or category == "BattleCoins" then
		HideDailyItems()
		ShowItemsScrollingFrame()
	end
end

function StoreWidget:CreateBundlesFrames(bundles: table, category: string)
	for bundleName, bundleData in bundles do
		--clone the bundle template frame
		local bundleFrame = Assets.GuiObjects.Frames.BundleFrame:Clone()
		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = bundleFrame.ViewportFrame
		--Set the bundle name
		bundleFrame.Name = bundleName
		--Set the layout order
		bundleFrame.LayoutOrder = bundleData.layoutOrder
		--Set the bundle name text
		--Format the bundle name
		bundleName = bundleName:gsub("_", " ")
		bundleFrame.BundleName.Text = bundleName
		--Set the bundle price text
		--Format the bundle price
		local bundlePriceFormatted = FormatText.To_comma_value(bundleData.price)
		bundleFrame.Price.Text = bundlePriceFormatted
		--Set the bundle icon image
		bundleFrame.BundleIcon.Image = CURRENCY_ICONS[category]
		--Set the bundle amount text
		if bundleData.BattleCoins then
			--format the battle coins
			local battleCoinsFromatted = FormatText.To_comma_value(bundleData.BattleCoins)
			bundleFrame.Amount.Text = battleCoinsFromatted
		end
		if bundleData.BattleGems then
			--format the battle gems
			local battleGemsFromatted = FormatText.To_comma_value(bundleData.BattleGems)
			bundleFrame.Amount.Text = battleGemsFromatted
		end
		--set the bundle frame parent
		bundleFrame.Parent = ItemsScrollingFrame
		--Create the viewport instance module
		local bundleViewportModel = ViewportModel.new(bundleFrame.ViewportFrame, viewportCamera)
		--Create the world model
		local worldModel = Instance.new("WorldModel")
		worldModel.Parent = bundleFrame.ViewportFrame
		--Get the bundle model from assets
		local bundleModel = Assets.Models.Bundles[category][bundleName]:Clone()
		bundleModel.Parent = worldModel
		bundleViewportModel:SetModel(bundleModel)
		local theta = 0
		local orientation = CFrame.fromEulerAnglesYXZ(math.rad(-6), -90, 0)
		local cf, size = bundleModel:GetBoundingBox()
		local distance = bundleViewportModel:GetFitDistance(cf.Position)

		--Assign the distance per bundle
		distance = distance * DISTANCE_PER_BUNDLE[bundleName]
		viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)

		bundleFrame.ViewportFrame.CurrentCamera = viewportCamera
		--Tween the GlowEffect rotation
		local glowEffectTween = TweenService:Create(
			bundleFrame.GlowEffect,
			TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0),
			{ Rotation = bundleFrame.GlowEffect.Rotation + 360 }
		)
		glowEffectTween:Play()
		--Connect the buy button
		bundleFrame.BuyButton.Activated:Connect(function()
			ButtonWidget:OnActivation(bundleFrame.BuyButton, function()
				StoreService:BuyBundle(category, bundleName)
			end)
		end)
	end
end

function StoreWidget:GenerateCratesFrames(crates: table)
	--Create the crate frames
	--Loop through the crates and create the crate frames
	for crateName: string, crateData: table in crates do
		--clone the crate template frame
		local crateFrame = Assets.GuiObjects.Frames.CrateFrame:Clone()
		Knit.GetService("DataService"):GetKeyValue("Crates"):andThen(function(crates)
			if crates[crateName] and crates[crateName] > 0 then
				crateFrame.OpenButton.Visible = true
				--set the openButton text to add the amount of crates
				crateFrame.OpenButton.Text.Text = "Open (" .. crates[crateName] .. ")"
			else
				crateFrame.OpenButton.Visible = false
			end
		end)
		--Create the world model
		local worldModel = Instance.new("WorldModel")
		worldModel.Parent = crateFrame.ViewportFrame
		--Get the crate model from assets
		local crateModel = Assets.Models.Crates[crateName]:Clone()
		crateModel.Parent = worldModel
		--Set the crate name
		crateFrame.Name = crateName
		--Set the crate name text
		--Format the crate name
		local formattedCrateName = crateName:gsub("_", " ")
		crateFrame.CrateName.Text = formattedCrateName
		--Set the crate price text
		--Format the crate price
		local cratePriceFormatted = FormatText.To_comma_value(crateData.Price)
		crateFrame.Price.Text = cratePriceFormatted
		--Assign the crate cost currency icon
		if crateData.Currency == "BattleCoins" then
			crateFrame.Price.CurrencyIcon.Image = "rbxassetid://10835882861"
		end
		if crateData.Currency == "BattleGems" then
			crateFrame.Price.CurrencyIcon.Image = "rbxassetid://10835980573"
		end
		if crateData.Currency == "Robux" then
			crateFrame.Price.CurrencyIcon.Image = "rbxassetid://13259812339"
		end
		--Assign custom color if any
		if crateData.Color then
			crateFrame.BackgroundFrame.ImageColor3 = crateData.Color
		end
		--set the crate frame parent
		crateFrame.Parent = ItemsScrollingFrame
		--Create the camera and parent it
		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = crateFrame.ViewportFrame
		--Create the viewport instance module
		local crateViewportModel = ViewportModel.new(crateFrame.ViewportFrame, viewportCamera)
		crateViewportModel:SetModel(crateModel)
		local theta = 0
		local orientation
		local cf, size = crateModel:GetBoundingBox()
		local distance = crateViewportModel:GetFitDistance(cf.Position)
		table.insert(
			StoreWidget.viewportConnections,
			RunService.RenderStepped:Connect(function(dt)
				theta = theta + math.rad(20 * dt)
				orientation = CFrame.fromEulerAnglesYXZ(math.rad(-6), theta, 0)
				viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
			end)
		)
		crateFrame.ViewportFrame.CurrentCamera = viewportCamera
		local hoverInfoWidget = HoverWidget.new(
			crateFrame.HoverInfoButton,
			{ model = crateModel:Clone(), contents = crateData.Contents, category = "Crates" }
		)
		--Tween the GlowEffect rotation
		local glowEffectTween = TweenService:Create(
			crateFrame.GlowEffect,
			TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0),
			{ Rotation = crateFrame.GlowEffect.Rotation + 360 }
		)
		glowEffectTween:Play()
		--Connect the buy event
		crateFrame.BuyButton.Activated:Connect(function()
			ButtonWidget:OnActivation(crateFrame.BuyButton, function()
				StoreService:BuyCrate(crateName)
			end)
		end)
		--Connect the open event
		crateFrame.OpenButton.Activated:Connect(function()
			ButtonWidget:OnActivation(crateFrame.OpenButton, function()
				StoreService:OpenCrate(crateName)
			end)
		end)
	end
end

function StoreWidget:OpenStore(category: string, backButtonCallback: Function)
	--Clean the store contents and set up the scrolling frame for new category
	ItemsScrollingFrame.CanvasPosition = Vector2.new(0, 0)
	for index, child in ItemsScrollingFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	playOpenStoreAnimation(category)
	if category == STORE_CATEGORIES.DailyItems then
		--Get the daily items
		StoreService:GetDailyItems():andThen(function(dailyItems: table) end)
	end
	if category == STORE_CATEGORIES.Crates then
		--Get the crates
		StoreService:GetCrates():andThen(function(crates: table)
			--Create the crate frames
			StoreWidget:GenerateCratesFrames(crates)
		end)
	end
	if category == STORE_CATEGORIES.BattleCoins then
		StoreService:GetBundles(BUNDLE_CATEGORIES.BattleCoins):andThen(function(battleCoinBundles: table)
			--Create the crate frames
			StoreWidget:CreateBundlesFrames(battleCoinBundles, BUNDLE_CATEGORIES.BattleCoins)
		end)
	end
	if category == STORE_CATEGORIES.BattleGems then
		StoreService:GetBundles(BUNDLE_CATEGORIES.BattleGems):andThen(function(battleGemBundles: table)
			--Create the crate frames
			StoreWidget:CreateBundlesFrames(battleGemBundles, BUNDLE_CATEGORIES.BattleGems)
		end)
	end
	--Set the back button callback
	StoreGui.BackButtonFrame.Button.Activated:Connect(function()
		ButtonWidget:OnActivation(StoreGui.BackButtonFrame.Button, function()
			--Close the store
			StoreWidget:CloseStore()
			--Call the back button callback
			if backButtonCallback then
				backButtonCallback()
			end
		end)
	end)
end

function StoreWidget:CloseStore()
	--clean all viewport connections
	if StoreWidget.viewportConnections then
		for index, connection in StoreWidget.viewportConnections do
			connection:Disconnect()
		end
	end
	for index, child in ItemsScrollingFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	--Hide the store contents
	HideStoreContents(true)
	--Disable the store gui
	StoreGui.Enabled = false
end
return StoreWidget:Initialize()
