local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local GadgetSystem = {}
local Libraries = ReplicatedStorage.Source.Systems:WaitForChild("Libraries")
local SpringService = require(Libraries:WaitForChild("SpringService"))
local ShoulderCamera = require(Libraries.ShoulderCamera)
ShoulderCamera.SpringService = SpringService


return GadgetSystem