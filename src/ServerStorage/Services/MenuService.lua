-- Server-side code in MenuService.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MenuService = Knit.CreateService {
    Name = "MenuService",
    Client = {},
}

-- CFrame data for the cutscene points
local cutscenePoints = {
    StartingCamera = CFrame.new(...), -- replace with the actual CFrame value
    -- add other points here
}

function MenuService.Client:GetCutscenePoints(player)
	--Get the current's map cutscene points
	local cutscenePoints = workspace.Map.Cutscene:GetChildren()
	--Store the cutscene points in a table
	local _cutscenePoints = {}
	for index, cutscenePoint in cutscenePoints do
		_cutscenePoints[cutscenePoint.Name] = cutscenePoint.CFrame
	end

    return _cutscenePoints
end

function MenuService:KnitStart()
end

function MenuService:KnitInit()
end

return MenuService