local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
--Components
local PlayerPreview = Roact.Component:extend("PlayerPreview")
--Springs
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
function PlayerPreview:init()
	self.motor = Flipper.SingleMotor.new(0)

	local binding, setBinding = Roact.createBinding(self.motor:getValue())
	self.binding = binding

	self.motor:onStep(setBinding)

	--Ref
	self.viewportRef = Roact.createRef()
	self.cameraRef = Roact.createRef()
end

function PlayerPreview:render()
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = self.props.position,
		Size = UDim2.fromScale(0.574, 0.605),
	}, {
		imageLabel = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9971149099",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1.01, 1),
		}),

		playerName = Roact.createElement("TextLabel", {
			Font = Enum.Font.SourceSansBold,
			Text = "Sci_Punk",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextStrokeTransparency = 0.3,
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.288, 0.0268),
			Size = UDim2.fromScale(0.526, 0.0943),
		}),

		viewportFrame = Roact.createElement("ViewportFrame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0.0268),
			Size = UDim2.fromScale(0.95, 0.937),
			ZIndex = 2,
			[Roact.Ref] = self.viewportRef,
		}),

		--Camera for preview
		camera = Roact.createElement("Camera", {
			-- CFrame = CFrame.new(Vector3.new(2, 1, 2.5), Vector3.new(0, 0, 0));
			[Roact.Ref] = self.cameraRef,
		}),
	})
end

function PlayerPreview:didMount()
	if not (self.viewportRef:getValue():FindFirstChildOfClass("WorldModel")) then
		local worldModel = Instance.new("WorldModel")
		worldModel.Parent = self.viewportRef:getValue()
		local dummy = ReplicatedStorage.Assets.Models.Dummy:Clone()
		dummy.Parent = workspace
		dummy:WaitForChild("Humanoid"):ApplyDescription(self.props.playerHumanoidDescription)
		dummy.Parent = worldModel
		self.cameraRef:getValue().CFrame = (dummy.PrimaryPart.CFrame + Vector3.new(0, 0, 6.6))
			* CFrame.Angles(0, math.rad(40), 0)
		--Align character to face camera
		dummy:SetPrimaryPartCFrame(dummy.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-180), 0))
		self.viewportRef:getValue().CurrentCamera = self.cameraRef:getValue()
		--Activate controller
		task.spawn(function()
			Knit.GetController("PlayerPreviewController"):spawnCharacterMenu()
		end)
	end
end

return PlayerPreview
