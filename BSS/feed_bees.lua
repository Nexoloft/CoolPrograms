-- Feed Bees 4 Million Treats
-- This script feeds each bee in your hive 4 million treats

pcall(function()
	local Pepsi = shared.PepsiSwarm
	if not Pepsi then
		warn("PepsiSwarm not loaded! Please load Pepsi Swarm first.")
		return
	end

	local me = Pepsi.Lp or Pepsi.Me()
	if not me then
		warn("Failed to get local player!")
		return
	end

	local c = me.Character or workspace:FindFirstChild(me.Name)
	if not c then
		warn("Failed to get character!")
		return
	end

	-- Get player hive data
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local PlayerHiveCommand = Pepsi.Obj(ReplicatedStorage, "Events", "PlayerHiveCommand")
	
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
	local hiveData = me:WaitForChild("Data"):WaitForChild("Hive")
	
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
