local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MovementController = Knit.CreateController { Name = "MovementController" }

local ACTION_DASH = "DASH"
local character
local DIRECTIONS =
{
    FORWARD = "FORWARD",
    BACKWARDS = "BACKWARDS",
    LEFT = "LEFT",
    RIGHT = "RIGHT"
}
local ANIM_NAME_DICTIONARY =
{
    DASH = {
        RIGHT = "Right_Dash",
        LEFT = "Left_Dash",
        FORWARD = "Forward_Dash",
        BACKWARDS = "Backwards_Dash"
    }
}

function MovementController:KnitStart()
    
end

function MovementController:Dash(direction : string, vectorMultiplier : number)
    warn("Dashing with " .. direction .. " direction")
    if not self.debounces.dash then
        self.debounces.dash = true
        local AnimationController = Knit.GetController("AnimationController")
        local linearVelocity = Instance.new("BodyVelocity")
        linearVelocity.Parent = character.HumanoidRootPart
        linearVelocity.MaxForce = Vector3.new(999999,0,999999)
        if direction == DIRECTIONS.RIGHT or direction == DIRECTIONS.LEFT then
            linearVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * vectorMultiplier
        end
        if direction == DIRECTIONS.FORWARD or direction == DIRECTIONS.BACKWARDS then        
            linearVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * vectorMultiplier
        end
        Debris:AddItem(linearVelocity, 0.3)
    
        local animationTrack = AnimationController:PlayAnimation(ANIM_NAME_DICTIONARY.DASH[direction])
        animationTrack.Ended:Connect(function()
            warn("Animation ended")
            self.debounces.dash = false
        end)
    end
end

function MovementController:KnitInit()
    --Bind the actions to the character
    self.debounces = {}
    self.debounces.dash = false
    Players.LocalPlayer.CharacterAdded:Connect(function(_character)
        character = _character 
        ContextActionService:BindAction(ACTION_DASH, function(actionName, inputState, _inputObject)
            if actionName == ACTION_DASH and inputState == Enum.UserInputState.Begin then
                local Cam = workspace.CurrentCamera
                if (_character.Humanoid.MoveDirection:Dot(Cam.CFrame.RightVector) > 0.75) then
                    self:Dash(DIRECTIONS.RIGHT, 50)
                end
                if (_character.Humanoid.MoveDirection:Dot(-Cam.CFrame.RightVector) > 0.75) then
                    self:Dash(DIRECTIONS.LEFT, -50)
                end
                if (_character.Humanoid.MoveDirection:Dot(Cam.CFrame.LookVector) > 0.75) then
                    self:Dash(DIRECTIONS.FORWARD, 50)
                end
                if (_character.Humanoid.MoveDirection:Dot(-Cam.CFrame.LookVector) > 0.75) then
                    self:Dash(DIRECTIONS.BACKWARDS, -50)
                end
                
            end
        end, true, Enum.KeyCode.LeftControl)
    end)
end


return MovementController
