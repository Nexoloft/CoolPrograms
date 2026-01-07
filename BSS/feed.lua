-- Bee Swarm Simulator - Auto Feed All Bees 4 Million Treats Script
-- This script automatically feeds every bee in your hive 4 million treats

local TreatsPerBee = 400000  -- 4 million treats per bee

-- Function to feed all bees using the correct Events structure
local function feedAllBees()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    
    if not character then
        print("Error: Character not found")
        return false
    end
    
    local beeCount = 0
    local successCount = 0
    
    -- Get ReplicatedStorage Events
    local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
    
    -- Iterate through all hive coordinates (x: 1-5, y: 1-10)
    for x = 1, 5 do
        for y = 1, 10 do
            -- Args format: {x_coord, y_coord, item_type, amount, boolean_flag}
            local args = {
                x,
                y,
                "Treat",
                TreatsPerBee,
                false
            }
            
            -- Attempt to feed the bee at this coordinate
            local success, result = pcall(function()
                return Events:WaitForChild("ConstructHiveCellFromEgg"):InvokeServer(unpack(args))
            end)
            
            if success and result then
                beeCount = beeCount + 1
                successCount = successCount + 1
                print("Fed bee at (" .. x .. ", " .. y .. ") with " .. TreatsPerBee .. " treats")
            end
            
            -- Small delay to prevent server spam
            wait(1)
        end
    end
    
    print("\n=== Feeding Complete ===")
    print("Total slots checked: 50")
    print("Bees found: " .. beeCount)
    print("Successfully fed: " .. successCount)
    print("Treats used: " .. (successCount * TreatsPerBee))
    
    return true
end

-- Alternative simplified version (if the above doesn't work for your game version)
local function feedAllBeesSimple()
    local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
    
    -- Attempt to feed through the game's API
    local success, result = pcall(function()
        for x = 1, 5 do
            for y = 1, 10 do
                local args = {x, y, "Treat", TreatsPerBee, false}
                Events:WaitForChild("ConstructHiveCellFromEgg"):InvokeServer(unpack(args))
                wait(1)
            end
        end
    end)
    
    if success then
        print("Successfully fed all bees!")
    else
        print("Error: " .. tostring(result))
    end
end

-- Main execution
print("Starting auto-feed script...")
print("This will feed all bees 4,000,000 treats each")
wait(2)

feedAllBees()

-- Uncomment the line below if the first method doesn't work:
-- feedAllBeesSimple()
