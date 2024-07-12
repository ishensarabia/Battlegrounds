local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

local WidgetController = Knit.CreateController({ Name = "WidgetController" })
local Widgets = script.Parent.Parent.Widgets
local Assets = ReplicatedStorage.Assets
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)

local RARITIES_COLORS = {
	Common = Color3.fromRGB(39, 180, 126),
	Rare = Color3.fromRGB(0, 132, 255),
	Epic = Color3.fromRGB(223, 226, 37),
	Legendary = Color3.fromRGB(174, 56, 204),
	Mythic = Color3.fromRGB(184, 17, 17),
}
function WidgetController:KnitStart()
	for key, child in (Widgets:GetChildren()) do
		if child:IsA("ModuleScript") then
			self[child.Name] = require(child)
		end
	end
	self._WeaponCustomizationController = Knit.GetController("WeaponCustomizationController")
	self._ShineLoops = {}
end

function WidgetController:CreateSkinFrame(skinData: table, parent: GuiObject?, layoutOrder: number?)
	local skinItemFrame = Assets.GuiObjects.Frames.SkinTemplateFrame:Clone()
	--Assign the name
	skinItemFrame.Name = skinData.name
	--Assign the skin name
	skinItemFrame.ContentNameTextLabel.Text = skinData.name
	--Assign the skin rarity
	skinItemFrame.RarityTextLabel.Text = skinData.rarity
	--Assign the color of the rarity
	skinItemFrame.RarityTextLabel.TextColor3 = RARITIES_COLORS[skinData.rarity]
	skinItemFrame.ItemFrame.ImageColor3 = RARITIES_COLORS[skinData.rarity]
	--Assing the skin to the image
	skinItemFrame.SkinBackground.Image = skinData.skinID
	--Get the weapon equipped
	local DataService = Knit.GetService("DataService")
	return DataService:GetKeyValue("Loadout"):andThen(function(loadout)
		local weaponModel = ReplicatedStorage.Weapons[loadout.WeaponEquipped]:FindFirstChildWhichIsA("Model"):Clone()

		--apply the skin
		WidgetController._WeaponCustomizationController:ApplySkinForPreview(weaponModel, skinData.skinID)
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

		if parent then
			skinItemFrame.Parent = parent
		end

		if layoutOrder then
			skinItemFrame.LayoutOrder = layoutOrder
		end
		return skinItemFrame
	end)
end

function WidgetController:CreateCrateFrame(crateName: string, parent: GuiObject, rarityColor: Color3)
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
	crateFrame.ViewportFrame.CurrentCamera = viewportCamera
	return crateFrame
end

--create emote frame
function WidgetController:CreateEmoteFrame(emoteData: table, parent: GuiObject?, layoutOrder: number?)
	local emoteFrame = Assets.GuiObjects.Frames.EmoteTemplateFrame:Clone()
	emoteFrame.NameTextLabel.Text = emoteData.name
	emoteFrame.RarityTextLabel.Text = emoteData.rarity
	--set rarity color
	emoteFrame.RarityTextLabel.TextColor3 = RARITIES_COLORS[emoteData.rarity]
	emoteFrame.ItemFrame.ImageColor3 = RARITIES_COLORS[emoteData.rarity]
	task.spawn(function()
		Knit.GetController("EmoteController")
			:DisplayEmotePreview(emoteData.Name or emoteData.name, emoteFrame.ViewportFrame, true)
	end)
	if parent then
		emoteFrame.Parent = parent
	end
	if layoutOrder then
		emoteFrame.LayoutOrder = layoutOrder
	end
	return emoteFrame
end

--Animate digits for text label
function WidgetController:AnimateDigitsForTextLabel(textLabel: TextLabel, targetValue: number, incrementValue: number)
	local textLabelInitalScaleSize = textLabel.Size
	local currentValue = textLabel.Text
	if type(currentValue) == "string" then
		currentValue = currentValue:gsub(",", "")
		currentValue = tonumber(currentValue)
	end

	if type(targetValue) == "string" then
		targetValue = targetValue:gsub(",", "")
		targetValue = tonumber(targetValue)
	end

	local connection
	connection = game:GetService("RunService").RenderStepped:Connect(function()
		if currentValue < targetValue then
			currentValue = currentValue + incrementValue
			textLabel.Text = FormatText.To_comma_value(currentValue)
			textLabel.Size = textLabelInitalScaleSize + UDim2.new(0.05, 0, 0.1, 0)
		elseif currentValue > targetValue then
			currentValue = currentValue - incrementValue
			textLabel.Text = FormatText.To_comma_value(currentValue)
			textLabel.Size = textLabelInitalScaleSize - UDim2.new(0.05, 0, 0.1, 0)
		else
			textLabel.Text = FormatText.To_comma_value(targetValue) -- Ensure the final value is set correctly
			textLabel.Size = textLabelInitalScaleSize
			connection:Disconnect() -- Disconnect the RenderStepped event when the animation is done
		end
	end)
end

function WidgetController:TweenProgressCircle(
	leftCircle: UIGradient,
	rightCircle: UIGradient,
	rotation: number,
	justLeveledUp: boolean?,
	newColor: ColorSequence?
)
	-- Divide rotation in two parts so it can be animated between the two parts
	local leftProgress = math.clamp(rotation, 180, 360)
	local rightProgress = math.clamp(rotation, 0, 180)

	if newColor then
		leftCircle.Color = newColor
		rightCircle.Color = newColor
	end

	local leftTween = TweenService:Create(leftCircle, TweenInfo.new(0.5), { Rotation = leftProgress })
	local rightTween = TweenService:Create(rightCircle, TweenInfo.new(0.5), { Rotation = rightProgress })

	-- Play the tweens in the correct order
	if justLeveledUp then
		leftTween:Play()
		leftTween.Completed:Wait()
		rightTween:Play()
	else
		if rotation >= 180 then
			rightTween:Play()
			rightTween.Completed:Wait()
			leftTween:Play()
		else
			leftTween:Play()
			leftTween.Completed:Wait()
			rightTween:Play()
		end
	end

	return leftTween, rightTween
end

--create emote icon frame
function WidgetController:CreateEmoteIconFrame(emoteIcon: table, parent: GuiObject?, layoutOrder: number?)
	local emoteIconFrame = Assets.GuiObjects.Frames.EmoteIconTemplateFrame:Clone()
	emoteIconFrame.NameTextLabel.Text = emoteIcon.name
	emoteIconFrame.RarityTextLabel.Text = emoteIcon.rarity
	--set rarity color
	emoteIconFrame.RarityTextLabel.TextColor3 = RARITIES_COLORS[emoteIcon.rarity]
	emoteIconFrame.ItemFrame.ImageColor3 = RARITIES_COLORS[emoteIcon.rarity]
	emoteIconFrame.EmoteIcon.Image = emoteIcon.imageID
	if parent then
		emoteIconFrame.Parent = parent
	end
	return emoteIconFrame
end

function WidgetController:AnimateShineForFrame(frame: Frame, transitionTransparency: boolean, shouldLoop: boolean)
	local gradient = frame:FindFirstChild("UIGradient")
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

	--Listen to the frame visibility changing or the frame being destroyed
	local connection
	connection = frame:GetPropertyChangedSignal("Visible"):Connect(function()
		if not frame.Visible then
			connection:Disconnect()
			self:StopAnimationForTween(shineTween)
		end
	end)
	--Listen to the frame being destroyed
	frame.Destroying:Connect(function()
		connection:Disconnect()
		self:StopAnimationForTween(shineTween)
	end)

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

function WidgetController:StopAnimationForTween(animationToStop: Tween)
	if self._ShineLoops[animationToStop] then
		self._ShineLoops[animationToStop]:cancel()
		self._ShineLoops[animationToStop] = nil
	end
end

function WidgetController:KnitInit() end

return WidgetController
