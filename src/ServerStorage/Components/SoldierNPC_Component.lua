local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Component = require(game.ReplicatedStorage.Packages.Component)
local TweenObject = require(ReplicatedStorage.Source.Modules.Util.TweenObject)
local Players = game:GetService("Players")
--Services
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local movementThreshold = 6.33
--Module dependencies
--Class
local SoldierNPC_Component = Component.new({
	Tag = "SoldierNPC_Component",
})

function SoldierNPC_Component:Construct()
	
end

function SoldierNPC_Component:DestroyObject(player) end

function SoldierNPC_Component:Start() end

return SoldierNPC_Component
