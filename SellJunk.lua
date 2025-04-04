-- Script to automatically sell junk weapons from inventory

-- List of weapons to sell
local junkWeapons = {
    "BoneMace",
    "DualDivineAxe",
    "DualGemStaffs",
    "DualKando",
    "DualSteelNaginata",
    "GreatSaber",
    "MixedBattleAxe",
    "MonsterSlayer",
    "ObsidianDualAxe",
    "RuneSword",
    "SteelKando",
    "SteelSaber",
    "TrollSlayer"
    'StellKophesh',
}

-- Function to get all weapons from inventory that match our junk list
local function getJunkWeaponsFromInventory()
    local player = game:GetService("Players").LocalPlayer
    local weapons = player.leaderstats.Inventory.Weapons
    local junkToSell = {}
    
    -- Loop through all items in weapons inventory
    for _, weapon in pairs(weapons:GetChildren()) do
        -- Extract base weapon name (remove the unique ID part)
        local weaponBaseName = weapon.Name:match("^([%a]+)")
        
        -- Check if this weapon is in our junk list
        for _, junkName in ipairs(junkWeapons) do
            if weaponBaseName == junkName then
                table.insert(junkToSell, weapon.Name)
                break
            end
        end
    end
    
    return junkToSell
end

-- Function to sell a weapon
local function sellWeapon(weaponName)
    local args = {
        [1] = {
            [1] = {
                ["Action"] = "Sell",
                ["Event"] = "WeaponAction",
                ["Name"] = weaponName
            },
            [2] = "\n"
        }
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
    print("Selling: " .. weaponName)
    wait(0.5) -- Small delay between sells to avoid rate limiting
end

-- Main function
local function sellAllJunkWeapons()
    local junkToSell = getJunkWeaponsFromInventory()
    
    print("Found " .. #junkToSell .. " junk weapons to sell")
    
    for _, weaponName in ipairs(junkToSell) do
        sellWeapon(weaponName)
    end
    
    print("Finished selling all junk weapons")
end

-- Execute the selling process
sellAllJunkWeapons()
