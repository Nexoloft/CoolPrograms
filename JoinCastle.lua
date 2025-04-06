-- Script to join a castle in Roblox game

-- Initialize Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Function to join castle
local function joinCastle()
    -- Prepare arguments for the remote event
    local args = {
        [1] = {
            [1] = {
                ["Event"] = "JoinCastle",
            },
            [2] = "\n"
        }
    }
    
    -- Fire the server event to join castle
    ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
    
    -- Add a wait to check if we're successfully joining
    task.wait(1)
    
    -- Monitor castle joining status
    local checkJoinStatus = coroutine.create(function()
        local startTime = os.time()
        while os.time() - startTime < 10 do -- Wait up to 10 seconds for confirmation
            if ReplicatedStorage:GetAttribute("IsCastle") == true then
                print("Successfully joined castle!")
                return
            end
            task.wait(0.5)
        end
        print("Castle join may have failed or is still processing...")
    end)
    
    coroutine.resume(checkJoinStatus)
    
    print("Castle join request sent!")
end

-- Execute the join function
joinCastle()
