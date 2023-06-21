local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local UIController = Knit.CreateController({ Name = "UIController" })
local UIModules = script.Parent.Parent.UI_Widgets
local Assets = ReplicatedStorage.Assets
--Modules
local ViewportModel = require(ReplicatedStorage.Source.Modules.Util.ViewportModel)
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
			require(child)
		end
	end
end

function UIController:CreateSkinFrame(skinID: string, skinName: string, skinRarity: string)
	local skinItemFrame = Assets.GuiObjects.Frames.SkinTemplate:Clone()
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

		--Get weapon parts to apply the skin
		for index, value in weaponModel:GetDescendants() do
			if value:GetAttribute("CustomPart") then
				local textures = {}
				--It's a texture
				for i = 1, 6, 1 do
					local texture = Instance.new("Texture")
					texture.Name = "SkinTexture"
					texture.Texture = skinID
					table.insert(textures, texture)
					texture.Parent = value
				end
				textures[1].Face = Enum.NormalId.Back
				textures[2].Face = Enum.NormalId.Bottom
				textures[3].Face = Enum.NormalId.Front
				textures[4].Face = Enum.NormalId.Left
				textures[5].Face = Enum.NormalId.Right
				textures[6].Face = Enum.NormalId.Top
			end
		end
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

function UIController:KnitInit() end

return UIController
