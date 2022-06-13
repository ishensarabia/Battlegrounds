local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RECS = require(ReplicatedStorage.Source.Systems.Core.RECS)
-- local Runner = require(ReplicatedStorage.SharedSystems.Runner)
-- local Pathing = require(ReplicatedStorage.SharedSystems.Pathing)
-- local DataflowSystem = require(ReplicatedStorage.SharedSystems.DataflowSystem)
local MinimapGui = require(ReplicatedStorage.Source.Systems.RECS.Guis.Minimap)
-- local DayNightClient = require(ReplicatedStorage.Systems.DayNightClient)

local steppers = {
	RECS.event(RunService.Heartbeat, {
		MinimapGui,
	}),
	
	-- RECS.event(RunService.Stepped, {
	-- 	Runner,
	-- 	DataflowSystem,
	-- }),
	
	-- RECS.event(RunService.RenderStepped, {
	-- 	DayNightClient,
	-- }),
	
}

return steppers
