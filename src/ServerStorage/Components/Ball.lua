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
--Assets
local BALL_PREFAB =  game:GetService('ServerStorage').Assets.Ball
------------------------------Constants
local RESPAWN_BALL_TIME = 3
--Force
local THROW_FORCE_MIN = 1
local THROW_FORCE_MAX = 100
local THROW_FORCE_TIME = 1

local Ball = Component.new({
    Tag = 'Ball',
})

local function Lerp(min, max, alpha)
    return(min + ((max - min) * alpha))
end
--****************************************************
-- Function: BallComponent:Construct
--
-- Purpose: Constructs the object with all the neccessary variables to assign.
--****************************************************

function Ball:Construct()
    self._janitor = Janitor.new()
    self._playerJanitor = Janitor.new()
    self._janitor:Add(self._playerJanitor)
    self._respawnSignal = Signal.new(self._janitor)
    self.playerID = 0
end

function Ball:Throw(player, clickDuration : number)
    if (player.UserId == self.playerID and player.Character) then        
        self._playerJanitor:Cleanup()
        local direction = player.Character.PrimaryPart.CFrame.LookVector
        local throwForceAlpha = math.min(THROW_FORCE_TIME,clickDuration) / THROW_FORCE_TIME
        local throwForce = Lerp(THROW_FORCE_MIN, THROW_FORCE_MAX, throwForceAlpha)
        self.Instance:ApplyImpulse(direction * self.Instance.AssemblyMass * throwForce)
    end
end

function Ball:_listenForTouches()
    
    local function GetPlayerFromPart(part)
        return Option.Wrap(game.Players:GetPlayerFromCharacter(part.Parent))
    end


    local function CreatePhysicsConstraintHold(player)
        --Attachments
        local attachment1 = Instance.new('Attachment')
        attachment1.Position = Vector3.new(0, 0, -2)
        attachment1.Parent = player.Character.PrimaryPart
        self._playerJanitor:Add(attachment1)

        local attachment2 = Instance.new('Attachment')
        attachment2.Parent = self.Instance
        self._playerJanitor:Add(attachment2)
        
        local alignPos = Instance.new('AlignPosition')
        alignPos.Parent = self.Instance
        alignPos.RigidityEnabled = true
        alignPos.Attachment0 = attachment2
        alignPos.Attachment1 = attachment1
        self._playerJanitor:Add(alignPos)

        local alignOrientation = Instance.new('AlignOrientation')
        alignOrientation.Parent = self.Instance
        alignOrientation.RigidityEnabled = true
        alignOrientation.Attachment0 = attachment2
        alignOrientation.Attachment1 = attachment1
        self._playerJanitor:Add(alignOrientation)
    end

    local function AttachToPlayer(player, humanoid)

        self.playerID = player.UserId
        CreatePhysicsConstraintHold(player)
        self.Instance.CanCollide = false
        humanoid.WalkSpeed = Knit.GetService('ArenaService').BALL_RUN_SPEED
        --Janitor methods calling when DetachFromPlayer
        --Cleanup functions for player 
        self._playerJanitor:Add(function(player)
            self.playerID = 0
            self.Instance.CanCollide = true
            humanoid.WalkSpeed = Knit.GetService('ArenaService').NORMAL_RUN_SPEED
        end)
        self._playerJanitor:Add(humanoid.Died:Connect(function()
            self:DetachFromPlayer()
        end))
        self._playerJanitor:Add(Players.PlayerRemoving:Connect(function(player)
            if (player.UserId == self.playerID) then
                self:DetachFromPlayer()
            end
        end))
    end

    local function GetHumanoid(player : Player)
        if (player.Character) then
            local humanoid = player.Character:FindFirstChildWhichIsA('Humanoid')
            return Option.Wrap(humanoid)
        end
        return Option.None
    end

    --Touched event
    self._janitor:Add(self.Instance.Touched:Connect(function(part)
        --Make sure there's not a player currently holding the ball
        if (self.playerID ~= 0) then return end
        GetPlayerFromPart(part):Match{
            Some = function(player)
               GetHumanoid(player):Match{
                   Some = function(humanoid)
                       if (humanoid.Health > 0) then                       
                            AttachToPlayer(player, humanoid)
                       end
                   end;

                   None = function()
                       
                   end
               }
            end;

            None = function()
                
            end
        }
        
        
    end))
end

function Ball:DetachFromPlayer()
    self._playerJanitor:Cleanup()
end

function Ball:Start()
    self:_listenForTouches()
end

function Ball:Stop()
    self._janitor:Cleanup()
end

return Ball