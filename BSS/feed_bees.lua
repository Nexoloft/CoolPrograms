-- Feed Bees 4 Million Treats
-- Standalone script - feeds each bee in your hive 4 million treats

pcall(function()
	-- Get essential services
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	
	-- Get local player
	local me = Players.LocalPlayer
	if not me then
		warn("Failed to get local player!")
		return
	end
	
	-- Wait for character
	local c = me.Character or me:WaitForChild("Character", 5)
	if not c then
		warn("Failed to get character!")
		return
	end
	
	-- Find PlayerHiveCommand event
	local PlayerHiveCommand = nil
	local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
	if EventsFolder then
		PlayerHiveCommand = EventsFolder:FindFirstChild("PlayerHiveCommand")
	end
	
	if not PlayerHiveCommand then
		warn("PlayerHiveCommand not found!")
		return
	end
	
	-- Function to feed a single bee
	local function feedBee(beeId, treatAmount)
		local args = {
			"Set",
			{
				["Id"] = beeId,
				["Treats"] = treatAmount
			}
		}
		pcall(function()
			PlayerHiveCommand:FireServer(unpack(args))
		end)
	end
	
	-- Get hive data from player
	local dataFolder = me:WaitForChild("Data", 5)
	if not dataFolder then
		warn("Data folder not found!")
		return
	end
	
	local hiveData = dataFolder:WaitForChild("Hive", 5)
	if not hiveData then
		warn("Hive data not found!")
		return
	end
	
	-- Feed each bee
	local beeCount = 0
	for _, bee in pairs(hiveData:GetChildren()) do
		if bee:FindFirstChild("Id") then
			local beeId = bee.Id.Value
			feedBee(beeId, 4000000) -- 4 million treats
			beeCount = beeCount + 1
			wait(0.5) -- Small delay to avoid server spam
		end
	end
	
	print("Fed " .. beeCount .. " bees with 4 million treats each!")
end)
