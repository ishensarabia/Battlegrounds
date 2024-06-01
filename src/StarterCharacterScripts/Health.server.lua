-- Gradually regenerates the Humanoid's Health over time.

local REGEN_RATE = 1/1_000 -- Regenerate this fraction of MaxHealth per second.
local REGEN_STEP = 1 -- Wait this long between each regeneration step.
--------------------------------------------------------------------------------

local Character = script.Parent
local Humanoid = Character:WaitForChild'Humanoid'

--------------------------------------------------------------------------------

Humanoid.Died:Connect(function()
	script:Destroy()
end)

while true do
	while Humanoid.Health < Humanoid.MaxHealth do
		local dt = task.wait(REGEN_STEP)
		local dh = dt*REGEN_RATE*Humanoid.MaxHealth
		Humanoid.Health = math.min(Humanoid.Health + dh, Humanoid.MaxHealth)
	end
	Humanoid.HealthChanged:Wait()
end