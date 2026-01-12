-- Constant WalkSpeed Script
-- Sets and maintains walkspeed at 90

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Set initial walkspeed
humanoid.WalkSpeed = 90

-- Continuously maintain walkspeed at 90
RunService.Heartbeat:Connect(function()
    if humanoid and humanoid.WalkSpeed ~= 90 then
        humanoid.WalkSpeed = 90
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = 90
    
    -- Reconnect the heartbeat for new character
    RunService.Heartbeat:Connect(function()
        if humanoid and humanoid.WalkSpeed ~= 90 then
            humanoid.WalkSpeed = 90
        end
    end)
end)

print("WalkSpeed locked at 90")
