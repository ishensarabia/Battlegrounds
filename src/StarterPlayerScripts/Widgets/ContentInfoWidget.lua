local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Widgets
local ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.Widgets.ButtonWidget)
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
--Controllers
local WidgetController = Knit.GetController("WidgetController")
--Screen guis
local ContentInfoGui
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
local RARITIES_DISPLAY_ORDER = {
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
local FORMAT_RARITIES_COLORS = {
	[RARITIES.Common] = "rgb(39, 180, 126)",
	[RARITIES.Rare] = "rgb(0, 132, 255)",
	[RARITIES.Epic] = "rgb(223, 226, 37)",
	[RARITIES.Legendary] = "rgb(174, 56, 204)",
	[RARITIES.Mythic] = "rgb(184, 17, 17)"
}
local ContentInfoWidget = {}
ContentInfoWidget.viewportConnections = {}

function ContentInfoWidget:initialize()
	--Initialize the screen guis
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("ContentInfoGui") then
		ContentInfoGui = Assets.GuiObjects.ScreenGuis.ContentInfoGui
			or game.Players.LocalPlayer.PlayerGui.ContentInfoGui
		ContentInfoGui.Parent = game.Players.LocalPlayer.PlayerGui
	else
		ContentInfoGui = game.Players.LocalPlayer.PlayerGui.ContentInfoGui
	end
	--Initialize the gui objects
	ItemContentsFrame = ContentInfoGui.ItemContentsFrame
	ItemsDisplayFrame = ContentInfoGui.ItemsDisplayFrame
	viewportFrame = ContentInfoGui.ViewportFrame
	closeButton = ContentInfoGui.CloseButton
	--Hide the contents with position and transparency for animation purposes
	ContentInfoGui.BackgroundFrame.BackgroundTransparency = 1
	ItemContentsFrame.Position = UDim2.fromScale(ItemContentsFrame.Position.X.Scale, 1.5)
	ItemsDisplayFrame.Position = UDim2.fromScale(ItemsDisplayFrame.Position.X.Scale, 1.5)
	viewportFrame.Position = UDim2.fromScale(viewportFrame.Position.X.Scale, 1.5)
	closeButton.Position = UDim2.fromScale(closeButton.Position.X.Scale, 1.5)
	--Create the close button
	local closeButton = ButtonWidget.new(ContentInfoGui.CloseButton, function()
		ContentInfoWidget:CloseHover()
	end)
	ContentInfoGui.Enabled = false
	return ContentInfoWidget
end

--[[ 
    The constructor for creating a new ContentInfoWidget.
    It takes a GUI instance as an argument and stores its initial size and hover size.
]]
function ContentInfoWidget.new(guiObject, params)
	local self = setmetatable({}, ContentInfoWidget)
	-- Instance properties
	self.instance = guiObject
	--Create the button widget
	ButtonWidget.new(self.instance, function()
		ContentInfoWidget:OpenContentInfo(params.model, params)
	end)

	return self
end

local function PlayCloseAnimations()
	--Tween the position of the contents to animate it
	local backgroundFrameTween = TweenService:Create(
		ContentInfoGui.BackgroundFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ BackgroundTransparency = 1 }
	)
	local viewportFrameTween = TweenService:Create(
		viewportFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ Position = UDim2.fromScale(viewportFrame.Position.X.Scale, 1.5) }
	)
	local itemContentsFrameTween = TweenService:Create(
		ContentInfoGui.ItemContentsFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ Position = UDim2.fromScale(ItemContentsFrame.Position.X.Scale, 1.5) }
	)
	local itemsDisplayFrameTween = TweenService:Create(
		ContentInfoGui.ItemsDisplayFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
		{ Position = UDim2.fromScale(ItemsDisplayFrame.Position.X.Scale, 1.5) }
	)
	local closeButtonTween = TweenService:Create(
		ContentInfoGui.CloseButton,
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

function ContentInfoWidget:CloseHover()
	PlayCloseAnimations()
	--Disconnect the render step
	for index, connection in ContentInfoWidget.viewportConnections do
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
	ContentInfoGui.Enabled = false
	--Enable core guis
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
end

function ContentInfoWidget:OpenCrateInfo(params: table)
    --Hide player list gui so that the widget buttons don't overlap
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	--Reset canvas position
	ItemsDisplayFrame.CanvasPosition = Vector2.new(0, 0)
    --Get the description text label
    local contentsTextLabel = ItemContentsFrame.ContentsTextLabel
    local text = ""

    -- Create a table with the rarities in the correct order
    local orderedRarities = {}
    for rarity, _ in pairs(RARITIES) do
        table.insert(orderedRarities, {rarity = rarity, order = RARITIES_DISPLAY_ORDER[rarity]})
    end
    table.sort(orderedRarities, function(a, b) return a.order < b.order end)

    -- Iterate over the ordered rarities to create the text
    for _, rarityInfo in ipairs(orderedRarities) do
        local rarity = rarityInfo.rarity
        if params._raritiesPercentages[rarity] then
            text = text .. [[<font color="]] .. FORMAT_RARITIES_COLORS[rarity] ..[[">]] .. rarity .. [[</font>]] .. ": " .. params._raritiesPercentages[rarity] .. "%\n"
        end
    end

    contentsTextLabel.Text = text 
	-- contentsTextLabel.Text = table.unpack(params._raritiesPercentages)
	--Get the content item template frame
	for index, contentInfo: table in params.contents do
		if params._type == "Skin" then
			WidgetController:CreateSkinFrame(contentInfo, ItemsDisplayFrame, RARITIES_DISPLAY_ORDER[contentInfo.rarity])
				:andThen(function(skinFrame)
					--Assign chance percentage
					skinFrame.RarityPercentageTextLabel.Visible = true
					skinFrame.RarityPercentageTextLabel.Text = string.format(
						"<b>%i%%</b> <br /> chance",
						params._raritiesPercentages[contentInfo.rarity],
						params._raritiesPercentages[contentInfo.rarity]
					)
				end)
		end
		
		if params._type == "Emote" then
			local emoteFrame = WidgetController:CreateEmoteFrame(
				contentInfo,
				ItemsDisplayFrame,
				RARITIES_DISPLAY_ORDER[contentInfo.rarity]
			)
			--Assign chance percentage
			emoteFrame.RarityPercentageTextLabel.Visible = true
			emoteFrame.RarityPercentageTextLabel.Text =
				string.format("<b>%i%%</b> <br /> chance", params._raritiesPercentages[contentInfo.rarity])
		end
	end
end

function ContentInfoWidget:OpenContentInfo(model: Model, params: table)
	--Clone the model
	model = model:Clone()
	ContentInfoGui.Enabled = true
	--Tween the transparency of the backgroundFrame to animate it
	local backgroundFrameTween = TweenService:Create(
		ContentInfoGui.BackgroundFrame,
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
			ContentInfoGui.ItemContentsFrame,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Position = ItemContentsFrame:GetAttribute("TargetPosition") }
		)
		local itemsDisplayFrameTween = TweenService:Create(
			ContentInfoGui.ItemsDisplayFrame,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0),
			{ Position = ItemsDisplayFrame:GetAttribute("TargetPosition") }
		)
		local closeButtonTween = TweenService:Create(
			ContentInfoGui.CloseButton,
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
		ContentInfoWidget:OpenCrateInfo(params)
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
			ContentInfoWidget.viewportConnections,
			game:GetService("RunService").RenderStepped:Connect(function(dt)
				theta = theta + math.rad(20 * dt)
				orientation = CFrame.fromEulerAnglesYXZ(math.rad(-6), theta, 0)
				viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
			end)
		)
		--Assign the viewport camera
		viewportFrame.CurrentCamera = viewportCamera
	end
end

return ContentInfoWidget:initialize()
