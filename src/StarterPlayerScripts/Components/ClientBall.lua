--****************************************************
-- File: Ball.lua
--
-- Purpose: Ball object containing all the necessary functions for the game.
--
-- Written By: Ishen
--
-- Compiler: Visual Studio Code
--****************************************************

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(Knit.Util.Promise)
local Option = require(ReplicatedStorage.Packages.Option)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
--Force
local THROW_FORCE_MIN = 1
local THROW_FORCE_MAX = 100
local THROW_FORCE_TIME = 1

local ClientBall = Component.new({
    Tag = 'Ball',
})
--****************************************************
-- Function: BallComponent:Construct
--
-- Purpose: Constructs the object with all the neccessary variables to assign.
--****************************************************

function ClientBall:Construct()
    self._janitor = Janitor.new()
    self._playerJanitor = Janitor.new()
    self._janitor:Add(self._playerJanitor)
    self.playerID = 0
    self.startClick = 0
end

function ClientBall:_setupForLocalPlayer()

    local ballGui = Knit.Player.PlayerGui:WaitForChild('BallGui')
    local throwForceFrame = ballGui.ThrowForce
    local throwForceHandle 

    local function ShowThrowForce()
        ballGui.Enabled = true
        throwForceFrame.Bar.Size = UDim2.fromScale(0, 1)
        throwForceFrame.Visible = true
        throwForceHandle = RunService.RenderStepped:Connect(function(deltaTime)
            local clickDuration = (time() - self.startClick)
            local throwForceAlpha = math.min(THROW_FORCE_TIME,clickDuration) / THROW_FORCE_TIME
            throwForceFrame.Bar.Size = UDim2.fromScale(throwForceAlpha, 1)
        end)
    end

    local function HideThrowForce()
        throwForceFrame.Visible = false
        if (throwForceHandle) then
            throwForceHandle:Disconnect()
            throwForceHandle = nil
        end
    end



    self._playerJanitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if (gameProcessedEvent) then return end
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
            self.startClick = time()
            ShowThrowForce()
        end
    end))

    self._playerJanitor:Add(UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
           local clickDuration = (time() - self.startClick)
           HideThrowForce()
           Knit.GetService("ArenaService"):ThrowBall(clickDuration)
        end
    end))

    self._playerJanitor:Add(function()
        ballGui.Enabled = false
        throwForceFrame.Visible = false
        HideThrowForce()
    end)
end

function ClientBall:_cleanupForLocalPlayer()
    
end

function ClientBall:Start()
    self:_setupForLocalPlayer()
end

function ClientBall:Stop()
    self._janitor:Cleanup()
end

return ClientBall