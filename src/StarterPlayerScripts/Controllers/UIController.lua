local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

local UIController = Knit.CreateController({ Name = "UIController" })
local UIModules = script.Parent.Parent.UI_Widgets
local Assets = ReplicatedStorage.Assets
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
--Widgets
local HoverWidget
local ButtonWidget

local RARITIES_COLORS = {
	Common = Color3.fromRGB(39, 180, 126),
	Rare = Color3.fromRGB(0, 132, 255),
	Epic = Color3.fromRGB(223, 226, 37),
	Legendary = Color3.fromRGB(174, 56, 204),
	Mythic = Color3.fromRGB(184, 17, 17),
}
function UIController:KnitStart()
	for key, child in (UIModules:GetChildren()) do
		if child:IsA("ModuleScript") then
			self[child.Name] = require(child)
		end
	end
	self._WeaponCustomizationController = Knit.GetController("WeaponCustomizationController")
	self._ShineLoops = {}
	HoverWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.HoverWidget)
	ButtonWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.ButtonWidget)
end

function UIController:CreateSkinFrame(skinID: string, skinName: string, skinRarity: string)
	local skinItemFrame = Assets.GuiObjects.Frames.SkinTemplateFrame:Clone()
	--Assign the name
	skinItemFrame.Name = skinName
	--Assign the skin name
	skinItemFrame.ContentNameTextLabel.Text = skinName
	--Assign the skin rarity
	skinItemFrame.RarityTextLabel.Text = skinRarity
	--Assign the color of the rarity
	skinItemFrame.RarityTextLabel.TextColor3 = RARITIES_COLORS[skinRarity]
	skinItemFrame.ItemFrame.ImageColor3 = RARITIES_COLORS[skinRarity]
	--Assing the skin to the image
	skinItemFrame.SkinBackground.Image = skinID
	--Get the weapon equipped
	local DataService = Knit.GetService("DataService")
	return DataService:GetKeyValue("Loadout"):andThen(function(loadout)
		local weaponModel = ReplicatedStorage.Weapons[loadout.WeaponEquipped]:FindFirstChildWhichIsA("Model"):Clone()

		--apply the skin
		UIController._WeaponCustomizationController:ApplySkinForPreview(weaponModel, skinID)
		--get the viewport from the skin item template frame
		local viewportFrame = skinItemFrame.ViewportFrame
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
		viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
		--Assign the viewport camera
		viewportFrame.CurrentCamera = viewportCamera
		return skinItemFrame
	end)
end

function UIController:CreateCrateFrame(crateName: string, parent: GuiObject, rarityColor: Color3)
	--clone the crate template frame
	local crateFrame = Assets.GuiObjects.Frames.CrateFrame:Clone()
	crateFrame.BuyButton:Destroy()
	crateFrame.OpenButton:Destroy()
	crateFrame.HoverInfoButton:Destroy()
	crateFrame.Price:Destroy()
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
	--Assign custom color if any
	crateFrame.BackgroundFrame.ImageColor3 = rarityColor or Color3.fromRGB(255, 255, 255)
	--set the crate frame parent
	crateFrame.Parent = parent
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
	-- table.insert(
	-- 	StoreWidget.viewportConnections,
	-- 	RunService.RenderStepped:Connect(function(dt)
	-- 		theta = theta + math.rad(20 * dt)
	-- 		orientation = CFrame.fromEulerAnglesYXZ(math.rad(-6), theta, 0)
	-- 		viewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
	-- 	end)
	-- )
	crateFrame.ViewportFrame.CurrentCamera = viewportCamera
	return crateFrame
end

--create emote frame
function UIController:CreateEmoteFrame(emote)
	local emoteFrame = Assets.GuiObjects.Frames.EmoteTemplateFrame:Clone()
	emoteFrame.NameTextLabel.Text = emote.Name or emote.name
	emoteFrame.RarityTextLabel.Text = emote.Rarity or emote.rarity
	--set rarity color
	emoteFrame.RarityTextLabel.TextColor3 = RARITIES_COLORS[emote.Rarity or emote.rarity]
	emoteFrame.ItemFrame.ImageColor3 = RARITIES_COLORS[emote.Rarity or emote.rarity]
	task.spawn(function()
		Knit.GetController("EmoteController"):DisplayEmotePreview(emote.Name or emote.name, emoteFrame.ViewportFrame, true)
	end)
	return emoteFrame
end

--create emote icon frame
function UIController:CreateEmoteIconFrame(emoteIcon)
	local emoteIconFrame = Assets.GuiObjects.Frames.EmoteIconTemplateFrame:Clone()
	emoteIconFrame.NameTextLabel.Text = emoteIcon.name
	emoteIconFrame.RarityTextLabel.Text = emoteIcon.rarity
	--set rarity color
	emoteIconFrame.RarityTextLabel.TextColor3 = RARITIES_COLORS[emoteIcon.rarity]
	emoteIconFrame.ItemFrame.ImageColor3 = RARITIES_COLORS[emoteIcon.rarity]
	emoteIconFrame.EmoteIcon.Image = emoteIcon.imageID
	return emoteIconFrame
end

function UIController:AnimateShineForFrame(frame: Frame, transitionTransparency: boolean, shouldLoop: boolean)
	local gradient = frame:FindFirstChildOfClass("UIGradient")
	local tweenInfo = TweenInfo.new(0.99, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	local transparencyTweenInfo = TweenInfo.new(0.66, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 0)
	if transitionTransparency then
		local transparencyTween = TweenService:Create(frame, transparencyTweenInfo, { Transparency = 0.6 })
		transparencyTween:Play()
	end
	local tweenGoals = { Offset = Vector2.new(2, 0) }
	local shineTween = TweenService:Create(gradient, tweenInfo, tweenGoals)
	local startingPos = Vector2.new(-1, 0) --start on the right, tween to the left so it looks like the shine went from left to right
	local addWait = 2.5 --the amount of seconds between each couplet of shines
	if shouldLoop then
		self._ShineLoops[shineTween] = Promise.new(function(resolve, reject, onCancel)
			local canceled = false
			while not canceled do
				warn("Spawn function running")
				shineTween:Play()
				shineTween.Completed:Connect(function()
					gradient.Offset = startingPos --reset offset
				end)
				task.wait(addWait)
			end
			onCancel(function()
				shineTween:Cancel()
				canceled = true
				resolve()
			end)
		end)
	end
	return shineTween
end

function UIController:StopAnimationForTween(animationToStop: Tween)
	if self._ShineLoops[animationToStop] then
		self._ShineLoops[animationToStop]:cancel()
		self._ShineLoops[animationToStop] = nil
	end
end

function UIController:KnitInit() end

return UIController
