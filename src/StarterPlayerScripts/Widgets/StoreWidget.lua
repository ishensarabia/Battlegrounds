--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage.Assets
local Knit = require(ReplicatedStorage.Packages.Knit)
--Config
local StoreConfig = require(ReplicatedStorage.Source.Configurations.StoreConfig)
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)
local TableUtil = require(ReplicatedStorage.Source.Modules.Util.TableUtil)
--Services
local StoreService = Knit.GetService("StoreService")
local DataService = Knit.GetService("DataService")
local WidgetController = Knit.GetController("WidgetController")
--Widgets
local ContentInfoWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ContentInfoWidget)
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
--Main
local StoreWidget = {}
StoreWidget.viewportConnections = {}
--Constants
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
local MainFrame: Frame
local FeaturedItemsFrame: Frame
local FeaturedItemsTimer

local DailyStoreMainFrame: Frame

local DailyitemsFrame
local DailyItemsTimer

local CategoriesFrame
local ItemsScrollingFrame: Frame
local CategoryTextLabel
local SubcategoriesFrame: Frame
-- Variables
local isOpeningCrate = false
local isShowingDailyItems = false
local backButtonCallback
local player = game.Players.LocalPlayer
--Enums
local CurrenciesEnum = require(ReplicatedStorage.Source.Enums.CurrenciesEnum)
local ItemTypesEnum = require(ReplicatedStorage.Source.Enums.ItemTypesEnum)

--Assets
local Assets = ReplicatedStorage.Assets
local BuyButton = Assets.GuiObjects.Buttons.BuyButton
local Prestiges = require(ReplicatedStorage.Source.Assets.Prestiges)
local Weapons = ReplicatedStorage.Weapons

local buttonTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0)

local function getTimeUntilTextUpdate(itemTypes: string)
	local now = os.time() + StoreConfig.RESET_TIME_OFFSET
	local timeUntilNextUpdate
	if itemTypes == "Featured" then
		timeUntilNextUpdate = StoreConfig.FEATURED_ITEMS_UPDATE_RATE - (now % StoreConfig.FEATURED_ITEMS_UPDATE_RATE)
	elseif itemTypes == "daily" then
		timeUntilNextUpdate = StoreConfig.DAILY_ITEMS_UPDATE_RATE - (now % StoreConfig.DAILY_ITEMS_UPDATE_RATE)
	end

	local hours = math.floor(timeUntilNextUpdate / 60 / 60)
	local minutes = math.floor(timeUntilNextUpdate / 60) % 60
	local seconds = timeUntilNextUpdate % 60

	if minutes < 10 then
		minutes = "0" .. minutes
	end

	if seconds < 10 then
		seconds = "0" .. seconds
	end

	return hours, minutes, seconds
end

local function ShowDailyItems()
	--Show the daily items main frame
	DailyStoreMainFrame.Size = UDim2.new(0, 0, 0, 0)
	DailyStoreMainFrame.Visible = true
	local tween = TweenService:Create(DailyStoreMainFrame, TweenInfo.new(0.09), { Size = UDim2.new(1, 0, 1, 0) })
	tween:Play()
	tween.Completed:Wait()

	isShowingDailyItems = true

	task.spawn(function()
		while isShowingDailyItems do
			task.wait(1)

			local hours, minutes, seconds = getTimeUntilTextUpdate("Featured")

			FeaturedItemsTimer.Text = "Refreshes in: " .. hours .. ":" .. minutes .. ":" .. seconds

			local hours, minutes, seconds = getTimeUntilTextUpdate("daily")

			DailyItemsTimer.Text = "Refreshes in: " .. hours .. ":" .. minutes .. ":" .. seconds
		end
	end)
end

local function HideDailyItems()
	--Hide the items scrolling frame by tweening the size
	local tween = TweenService:Create(DailyStoreMainFrame, TweenInfo.new(0.09), { Size = UDim2.new(0, 0, 0, 0) })
	tween:Play()
	tween.Completed:Wait()
	isShowingDailyItems = false
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

local function HideSubcategoriesFrame()
	--Hide the subcategories frame by tweening the size
	SubcategoriesFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.09, true)
end

local function PlayOpenStoreAnimation(category: string)
	if not StoreGui.Enabled then
		StoreGui.Enabled = true
		MainFrame:TweenPosition(UDim2.fromScale(0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.13)
	end
	if category == StoreConfig.Categories.DailyItems then
		HideItemsScrollingFrame()
		ShowDailyItems()
		HideSubcategoriesFrame()
	else
		HideDailyItems()
		ShowItemsScrollingFrame()
	end
end

local function CreateOwnedText(parentFrame: Frame)
	local ownedText = Instance.new("TextLabel")
	ownedText.Text = "Owned"
	ownedText.Size = UDim2.new(0.5, 0, 0.2, 0)
	ownedText.Position = UDim2.new(0.25, 0, 0.5, 0)
	ownedText.BackgroundTransparency = 1
	ownedText.TextColor3 = Color3.fromRGB(255, 255, 255)
	ownedText.TextStrokeTransparency = 0
	ownedText.TextScaled = true
	ownedText.Font = Enum.Font.GothamBold
	ownedText.ZIndex = 6
	ownedText.Parent = parentFrame
end

local function CreatePurchasableSkinFrame(skin: table, prestigeNeeded: number?)
	WidgetController:CreateSkinFrame(skin.data, ItemsScrollingFrame):andThen(function(skinFrame)
		--Check if the player owns the skin
		DataService:GetKeyValue("skins"):andThen(function(skins: table)
			if skins[skin.data.name] then
				CreateOwnedText(skinFrame)
				return
			else
				if prestigeNeeded then
					--Get the prestige needed frame
					local prestigeNeededFrame = Assets.GuiObjects.Frames.PrestigeNeededFrame:Clone()
					prestigeNeededFrame.Parent = skinFrame
					--Assign the prestige needed text
					prestigeNeededFrame.PrestigeTextLabel.Text = prestigeNeeded
					--Assign the icon for the prestige needed
					prestigeNeededFrame.PrestigeIcon.Image = Prestiges[prestigeNeeded].icon
					--Check if the player has the required prestige
					if player:GetAttribute("Prestige") >= prestigeNeeded then
						--Create the buy button frame
						local buyButton = BuyButton:Clone()
						buyButton.Parent = skinFrame
						--Assign the price text
						buyButton.LabelImageButton.PriceText.Text = FormatText.To_comma_value(skin.data.price)
						--Assign the currency icon
						warn(skin.data.currency, CurrenciesEnum.Icons, CurrenciesEnum.Icons[skin.data.currency])
						buyButton.LabelImageButton.CurrencyIcon.Image = CurrenciesEnum.Icons[skin.data.currency]
						--Create the buy button
						ButtonWidget.new(skinFrame.BuyButton, function()
							StoreService:PurchaseSkin(skin.data.name):andThen(function(result)
								if result then
									CreateOwnedText(skinFrame)
									skinFrame.BuyButton:Destroy()
								end
							end)
						end)
					end
				else
				end
			end
		end)
	end)
end

local function CreatePrestigePurchasableWeaponFrame(weapon: table, prestigeNeeded: number?)
	local weaponFrame: Frame = WidgetController:CreateWeaponFrame(weapon.data.name, ItemsScrollingFrame)
	--Check if the player owns the weapon
	DataService:GetKeyValue("weapons"):andThen(function(weapons: table)
		if weapons[weapon.data.name] then
			CreateOwnedText(weaponFrame)
			return
		else
			if prestigeNeeded then
				--Get the prestige needed frame
				local prestigeNeededFrame = Assets.GuiObjects.Frames.PrestigeNeededFrame:Clone()
				prestigeNeededFrame.Parent = weaponFrame
				--Assign the prestige needed text
				prestigeNeededFrame.PrestigeTextLabel.Text = prestigeNeeded
				--Assign the icon for the prestige needed
				prestigeNeededFrame.PrestigeIcon.Image = Prestiges[prestigeNeeded].icon
				--Check if the player has the required prestige
				if player:GetAttribute("Prestige") >= prestigeNeeded then
					--Create the buy button frame
					local buyButton = BuyButton:Clone()
					buyButton.Parent = weaponFrame
					--Assign the price text
					buyButton.LabelImageButton.PriceText.Text = FormatText.To_comma_value(weapon.data.price)
					--Assign the currency icon
					buyButton.LabelImageButton.CurrencyIcon.Image = CurrenciesEnum.Icons[weapon.data.currency]
					--Create the buy button
					ButtonWidget.new(weaponFrame.BuyButton, function()
						Knit.GetService("LoadoutService"):PurchasePrestigeWeapon(weapon.data.name):andThen(function(result)
							if result then
								CreateOwnedText(weaponFrame)
								weaponFrame.BuyButton:Destroy()
							end
						end)
					end)
				end
			end
		end
	end)
end

local function CreatePurchaseableEmoteFrame(emote: table, prestigeNeeded: number?)
	local emoteFrame = WidgetController:CreateEmoteFrame(emote.data, ItemsScrollingFrame)
	--Check if the player owns the emote
	DataService:GetKeyValue("emotes"):andThen(function(emotes: table)
		if emotes.emotesOwned[emote.data.name] then
			CreateOwnedText(emoteFrame)
			return
		else
			if prestigeNeeded then
				--Get the prestige needed frame
				local prestigeNeededFrame = Assets.GuiObjects.Frames.PrestigeNeededFrame:Clone()
				prestigeNeededFrame.Parent = emoteFrame
				--Assign the prestige needed text
				prestigeNeededFrame.PrestigeTextLabel.Text = prestigeNeeded
				--Assign the icon for the prestige needed
				prestigeNeededFrame.PrestigeIcon.Image = Prestiges[prestigeNeeded].icon
				--Check if the player has the required prestige
				if player:GetAttribute("Prestige") >= prestigeNeeded then
					--Create the buy button frame
					local buyButton = BuyButton:Clone()
					buyButton.Parent = emoteFrame
					--Assign the price text
					buyButton.LabelImageButton.PriceText.Text = FormatText.To_comma_value(emote.data.price)
					--Assign the currency icon
					buyButton.LabelImageButton.CurrencyIcon.Image = CurrenciesEnum.Icons[emote.data.currency]
					--Create the buy button
					ButtonWidget.new(emoteFrame.BuyButton, function()
						StoreService:PurchaseEmote(emote.data.name, "Animation"):andThen(function(result)
							if result then
								CreateOwnedText(emoteFrame)
								emoteFrame.BuyButton:Destroy()
							end
						end)
					end)
				end
			else
				--Create the buy button frame
				local buyButton = BuyButton:Clone()
				buyButton.Parent = emoteFrame
				--Assign the price text
				buyButton.LabelImageButton.PriceText.Text = FormatText.To_comma_value(emote.data.price)
				--Assign the currency icon
				buyButton.LabelImageButton.CurrencyIcon.Image = CurrenciesEnum.Icons[emote.data.currency]
				--Create the buy button
				ButtonWidget.new(emoteFrame.BuyButton, function()
					StoreService:PurchaseEmote(emote.data.name, "Animation"):andThen(function(result)
						if result then
							CreateOwnedText(emoteFrame)
							emoteFrame.BuyButton:Destroy()
						end
					end)
				end)
			end
		end
	end)
end

local function CreateItemFramesForItems(items: table, parentFrame: Frame, aspectRatio: number?)
	for index, itemData in items do
		if itemData._type == ItemTypesEnum.Emote then
			local emoteFrame = WidgetController:CreateEmoteFrame(itemData.data, parentFrame)
			emoteFrame.UIAspectRatioConstraint.AspectRatio = aspectRatio or 1
			--Check if the player owns the emote
			DataService:GetKeyValue("emotes"):andThen(function(emotes: table)
				--Change spaces to underscores (for the emote ID)
				local emoteID = itemData.data.name:gsub(" ", "_")
				if emotes.emotesOwned[emoteID] then
					CreateOwnedText(emoteFrame)
					return
				else
					--Create the buy button frame
					local buyButton = BuyButton:Clone()
					buyButton.Parent = emoteFrame
					--Assign the price text
					buyButton.LabelImageButton.PriceText.Text = FormatText.To_comma_value(itemData.data.price)
					--Assign the currency icon
					buyButton.LabelImageButton.CurrencyIcon.Image = CurrenciesEnum.Icons[itemData.data.currency]
					--Create the buy button
					ButtonWidget.new(emoteFrame.BuyButton, function()
						StoreService:PurchaseEmote(itemData.data.name, "Animation"):andThen(function(result)
							if result then
								CreateOwnedText(emoteFrame)
								emoteFrame.BuyButton:Destroy()
							end
						end)
					end)
				end
			end)
		elseif itemData._type == ItemTypesEnum.Skin then
			WidgetController:CreateSkinFrame(itemData.data, parentFrame):andThen(function(skinFrame: Frame)
				skinFrame.UIAspectRatioConstraint.AspectRatio = aspectRatio or 1
				--Check if the player owns the skin
				DataService:GetKeyValue("skins"):andThen(function(skins: table)
					if skins[itemData.data.name] then
						CreateOwnedText(skinFrame)
						return
					else
						--Create the buy button frame
						local buyButton = BuyButton:Clone()
						buyButton.Parent = skinFrame
						--Assign the price text
						buyButton.LabelImageButton.PriceText.Text = FormatText.To_comma_value(itemData.data.price)
						--Assign the currency icon
						buyButton.LabelImageButton.CurrencyIcon.Image = CurrenciesEnum.Icons[itemData.data.currency]
						--Create the buy button
						ButtonWidget.new(skinFrame.BuyButton, function()
							StoreService:PurchaseSkin(itemData.data.name):andThen(function(result)
								if result then
									CreateOwnedText(skinFrame)
									skinFrame.BuyButton:Destroy()
								end
							end)
						end)
					end
				end)
			end)
		elseif itemData._type == ItemTypesEnum.EmoteIcon then
			local emoteIconFrame = WidgetController:CreateEmoteIconFrame(itemData.data, parentFrame)
			emoteIconFrame.UIAspectRatioConstraint.AspectRatio = aspectRatio or 1
			--Check if the player owns the emote icon
			DataService:GetKeyValue("emotes"):andThen(function(emotes: table)
				if emotes.emotesOwned[itemData.data.name] then
					CreateOwnedText(emoteIconFrame)
					return
				else
					--Create the buy button frame
					local buyButton = BuyButton:Clone()
					buyButton.Parent = emoteIconFrame
					--Assign the price text
					buyButton.LabelImageButton.PriceText.Text = FormatText.To_comma_value(itemData.data.price)
					--Assign the currency icon
					buyButton.LabelImageButton.CurrencyIcon.Image = CurrenciesEnum.Icons[itemData.data.currency]
					--Create the buy button
					ButtonWidget.new(emoteIconFrame.BuyButton, function()
						StoreService:PurchaseEmote(itemData.data.name, "Icon"):andThen(function(result)
							if result then
								CreateOwnedText(emoteIconFrame)
								emoteIconFrame.BuyButton:Destroy()
							end
						end)
					end)
				end
			end)
		end
	end
end

function StoreWidget:UpdateFeaturedItems()
	-- Clear the featured items frame
	for index, value in pairs(FeaturedItemsFrame:GetChildren()) do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end

	CreateItemFramesForItems(self._featuredItemsCache, FeaturedItemsFrame, 0.8)
end

function StoreWidget:UpdateDailyItems()
	--Clear the daily items frame
	for index, value in DailyitemsFrame:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end

	CreateItemFramesForItems(self._dailyItemsCache, DailyitemsFrame, 0.8)
end

function StoreWidget:Initialize()
	--Initialize the screen guis
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("StoreGui") then
		StoreGui = Assets.GuiObjects.ScreenGuis.StoreGui or game.Players.LocalPlayer.PlayerGui.StoreGui
		StoreGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		StoreGui = game.Players.LocalPlayer.PlayerGui.StoreGui
	end

	--Initialize featured items
	if not self._featuredItemsCache then
		StoreService:GetFeaturedItems():andThen(function(featuredItems)
			self._featuredItemsCache = featuredItems
		end)
	end

	--Initialize daily items
	if not self._dailyItemsCache then
		StoreService:GetDailyItems():andThen(function(dailyItems)
			self._dailyItemsCache = dailyItems
			-- warn("daily items cache: ", self._dailyItemsCache)
		end)
	end

	--Set the back button callback
	ButtonWidget.new(StoreGui.MainFrame.BackButtonFrame, function()
		--Close the store
		StoreWidget:CloseStore()
		backButtonCallback()
	end)

	--Initialize the gui objects
	MainFrame = StoreGui.MainFrame
	CategoryTextLabel = MainFrame.CategoryTextLabel

	DailyStoreMainFrame = MainFrame.DailyStoreMainFrame

	FeaturedItemsFrame = MainFrame.DailyStoreMainFrame.FeaturedItemsFrame
	FeaturedItemsTimer = MainFrame.DailyStoreMainFrame.FeaturedItemsTimer

	DailyItemsTimer = MainFrame.DailyStoreMainFrame.DailyItemsTimer
	DailyitemsFrame = MainFrame.DailyStoreMainFrame.DailyItemsFrame

	CategoriesFrame = MainFrame.CategoriesFrame
	SubcategoriesFrame = MainFrame.SubcategoriesFrame

	ItemsScrollingFrame = MainFrame.ItemsScrollingFrame

	StoreGui.Enabled = false

	--Create the category buttons
	for index, child in CategoriesFrame:GetChildren() do
		if child:IsA("Frame") then
			ButtonWidget.new(child.Frame, function()
				StoreWidget:OpenStore(child:GetAttribute("Category"))
			end)
		end
	end
	--Create subcategory buttons
	for index, child in SubcategoriesFrame:GetChildren() do
		if child:IsA("Frame") then
			ButtonWidget.new(child.Frame, function()
				--For now use default category as prestige is the only categoy using subcategories **TODO**: Expand the store to other categories
				StoreWidget:ChangeSubcategory(child:GetAttribute("Subcategory"))
			end)
		end
	end
	--Connect store signals
	StoreService.CrateAddedSignal:Connect(function(crateName: string, totalAmountOfCrates: number)
		--if the frame exists, update the open button text
		if ItemsScrollingFrame:FindFirstChild(crateName) then
			ItemsScrollingFrame[crateName].OpenButton.Visible = true
			--Add the crate amount to the open button text
			ItemsScrollingFrame[crateName].OpenButton.Text.Text = "Open (" .. tostring(totalAmountOfCrates) .. ")"
		end
	end)

	StoreService.OpenCrateSignal:Connect(
		function(crate: table, rewardChosen: table, cratesLeft: number, crateName: string)
			ItemsScrollingFrame[crateName].OpenButton.Text.Text = "Open (" .. tostring(cratesLeft) .. ")"
			if cratesLeft == 0 then
				ItemsScrollingFrame[crateName].OpenButton.Visible = false
			end
		end
	)

	StoreService.InsufficientFundsSignal:Connect(function(currencyNeeded: number, currencyType: string)
		warn(currencyNeeded, currencyType)
	end)

	StoreService.UpdateFeaturedItemsSignal:Connect(function(featuredItems: table)
		--Check if there's new featured items and update
		if not TableUtil.tablesAreEqual(self._featuredItemsCache, featuredItems) then
			self._featuredItemsCache = featuredItems --Update the featured items cache
			self:UpdateFeaturedItems()
		end
	end)

	StoreService.UpdateDailyItemsSignal:Connect(function(dailyItems: table)
		if not TableUtil.tablesAreEqual(self._dailyItemsCache, dailyItems) then
			self._dailyItemsCache = dailyItems --Update the daily items cache
			self:UpdateDailyItems()
		end
	end)

	--Return the widget
	return StoreWidget
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
		--Create the buy button
		ButtonWidget.new(bundleFrame.BuyButton, function()
			StoreService:PurchaseBundle(category, bundleName)
		end)
	end
end

function StoreWidget:GenerateCratesFrames(crates: table)
	--Create the crate frames
	--Loop through the crates and create the crate frames
	for crateName: string, crateData: table in crates do
		--clone the crate template frame
		local crateFrame = Assets.GuiObjects.Frames.CrateFrame:Clone()
		Knit.GetService("DataService"):GetKeyValue("crates"):andThen(function(crates)
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
		if crateData.Currency == CurrenciesEnum.BattleCoins then
			crateFrame.Price.CurrencyIcon.Image = "rbxassetid://10835882861"
		end
		if crateData.Currency == CurrenciesEnum.BattleGems then
			crateFrame.Price.CurrencyIcon.Image = "rbxassetid://10835980573"
		end
		if crateData.Currency == CurrenciesEnum.Robux then
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
		local theta = 55
		local orientation = CFrame.fromEulerAnglesYXZ(math.rad(-6), theta, 0)
		local cf, size = crateModel:GetBoundingBox()
		local distance = crateViewportModel:GetFitDistance(cf.Position)
		viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
		crateFrame.ViewportFrame.CurrentCamera = viewportCamera
		--Create the content info widget
		ContentInfoWidget.new(crateFrame.HoverInfoButton, {
			model = crateModel:Clone(),
			contents = crateData.Contents,
			category = "Crates",
			_type = crateData.Type,
			_raritiesPercentages = crateData.RaritiesPercentages,
		})
		--Tween the GlowEffect rotation
		local glowEffectTween = TweenService:Create(
			crateFrame.GlowEffect,
			TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0),
			{ Rotation = crateFrame.GlowEffect.Rotation + 360 }
		)
		glowEffectTween:Play()
		--Create the buy button
		local buyButton = ButtonWidget.new(crateFrame.BuyButton, function()
			StoreService:PurchaseCrate(crateName)
		end)
		--Create the open button
		local openButton = ButtonWidget.new(crateFrame.OpenButton, function()
			StoreService:OpenCrate(crateName, crateData.Type)
		end)
	end
end

function StoreWidget:OpenStore(category: string, _backButtonCallback: Function?)
	warn(category, StoreConfig.Categories)
	--Disable the chat gui so that it doesn't overlap with other buttons
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	--Clean the store contents and set up the scrolling frame for new category
	for index, child in ItemsScrollingFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	ItemsScrollingFrame.CanvasPosition = Vector2.new(0, 0)
	--Set the category text
	CategoryTextLabel.Text = category:gsub("(%u)", " %1")
	if _backButtonCallback then
		backButtonCallback = _backButtonCallback
	end

	HideSubcategoriesFrame()

	PlayOpenStoreAnimation(category)

	if category == StoreConfig.Categories.DailyItems then
		self:UpdateDailyItems()
		self:UpdateFeaturedItems()
	end

	if category == StoreConfig.Categories.Crates then
		--Get the crates
		ItemsScrollingFrame.UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		StoreService:GetCrates():andThen(function(crates: table)
			--Create the crate frames
			StoreWidget:GenerateCratesFrames(crates)
		end)
	end

	if category == StoreConfig.Categories.BattleCoins then
		warn("BattleCoins category")
		ItemsScrollingFrame.UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		StoreService:GetBundles(BUNDLE_CATEGORIES.BattleCoins):andThen(function(battleCoinBundles: table)
			--Create the crate frames
			StoreWidget:CreateBundlesFrames(battleCoinBundles, BUNDLE_CATEGORIES.BattleCoins)
		end)
	end

	if category == StoreConfig.Categories.BattleGems then
		ItemsScrollingFrame.UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		StoreService:GetBundles(BUNDLE_CATEGORIES.BattleGems):andThen(function(battleGemBundles: table)
			--Create the crate frames
			StoreWidget:CreateBundlesFrames(battleGemBundles, BUNDLE_CATEGORIES.BattleGems)
		end)
	end

	if category == StoreConfig.Categories.Prestige then
		ItemsScrollingFrame.UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		SubcategoriesFrame:TweenSize(
			SubcategoriesFrame:GetAttribute("TargetSize"),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Linear,
			0.13
		)
		--Get the prestige items
		StoreService:GetPrestigeItems():andThen(function(prestigeItems: table)
			for index, skin: table in prestigeItems.Skins do
				CreatePurchasableSkinFrame(skin, skin.prestigeNeeded)
			end
		end)
	end
end

function StoreWidget:ChangeSubcategory(subcategory: string)
	--Clean the store contents and set up the scrolling frame for new subcategory
	for index, child in ItemsScrollingFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	ItemsScrollingFrame.CanvasPosition = Vector2.new(0, 0)
	--Get the prestige items
	StoreService:GetPrestigeItems():andThen(function(prestigeItems: table)
		if subcategory == StoreConfig.Subcategoires.Prestige.Skins then
			for index, skin: table in prestigeItems.Skins do
				CreatePurchasableSkinFrame(skin, skin.prestigeNeeded)
			end
		end

		if subcategory == StoreConfig.Subcategoires.Prestige.Emotes then
			for index, emote: table in prestigeItems.Emotes do
				CreatePurchaseableEmoteFrame(emote, emote.prestigeNeeded)
			end
		end

		if subcategory == StoreConfig.Subcategoires.Prestige.Weapons then
			for index, weapon: table in prestigeItems.Weapons do
				CreatePrestigePurchasableWeaponFrame(weapon, weapon.prestigeNeeded)
			end
		end
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
	MainFrame:TweenPosition(
		UDim2.fromScale(1, MainFrame.Position.Y.Scale),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.13
	)
	--Disable the store gui
	task.delay(0.13, function()
		StoreGui.Enabled = false
	end)
	--Reenable the chat gui
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
end

return StoreWidget:Initialize()
