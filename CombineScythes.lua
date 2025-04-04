local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local remote = ReplicatedStorage
    :WaitForChild('BridgeNet2')
    :WaitForChild('dataRemoteEvent')

---------------------------------
-- Utility Functions
---------------------------------

-- Buy scythes with 1s delay
local function buyReaperScythes(amount)
    for i = 1, amount do
        local args = {
            [1] = {
                [1] = {
                    ["Action"] = "Buy",
                    ["Shop"] = "WeaponShop7",
                    ["Item"] = "SlayerScythe2",
                    ["Event"] = "ItemShopAction"
                },
                [2] = "\n"
            }
        }
        
        remote:FireServer(unpack(args))
        wait(.3)  -- Adjust the delay as needed
    end 
end

-- Buy Rare Dust function
local function buyRareDust()
    local args = {
        [1] = {
            [1] = {
                ['Action'] = 'Buy',
                ['Shop'] = 'ExchangeShop',
                ['Item'] = 'EnchRare',
                ['Event'] = 'ItemShopAction',
            },
            [2] = '\n',
        },
    }

    remote:FireServer(unpack(args))
end

-- Returns an array of weapon names that have the required level.
local function getWeaponsAtLevel(levelCondition)
    local weaponFolder = player.leaderstats.Inventory.Weapons
    local matchingWeapons = {}

    for _, weapon in pairs(weaponFolder:GetChildren()) do
        if weapon:IsA('Instance') and weapon.Name:match('^SlayerScythe2') then
            local level = weapon:GetAttribute('Level')
            if level == levelCondition then
                table.insert(matchingWeapons, weapon.Name)
            end
        end
    end

    return matchingWeapons
end

-- Combines weapons (in groups of 3) from a given level and sends an upgrade request.
local function combineWeaponsForLevel(levelCondition, upgradeLevel)
    local weapons = getWeaponsAtLevel(levelCondition)

    while #weapons >= 3 do
        local selectedWeapons = {
            table.remove(weapons, 1),
            table.remove(weapons, 1),
            table.remove(weapons, 1),
        }
        local args = {
            {
                {
                    ['Type'] = 'SlayerScythe2',
                    ['BuyType'] = 'Gems',
                    ['Weapons'] = selectedWeapons,
                    ['Event'] = 'UpgradeWeapon',
                    ['Level'] = upgradeLevel,
                },
                '\n',
            },
        }

        print(
            'Upgrading from level',
            levelCondition,
            'to',
            upgradeLevel,
            'with weapons:',
            table.concat(selectedWeapons, ', ')
        )
        remote:FireServer(unpack(args))
        wait(0.5) -- Delay to prevent flooding
    end
end

---------------------------------
-- Junk Weapons Selling Functions
---------------------------------

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
    "TrollSlayer",
    "StellKopesh",
    "DualTrident",
    "SteelScythe",
    "WyvernSlayer",
}

-- Function to sell all junk weapons
local function sellAllJunkWeapons()
    local soldCount = 0
    
    -- Reference to the weapons folder
    local weaponsFolder = game:GetService("Players").LocalPlayer
        .leaderstats.Inventory.Weapons
    
    -- Sell each junk weapon found in inventory
    for _, weapon in ipairs(weaponsFolder:GetChildren()) do
        for _, baseName in ipairs(junkWeapons) do
            if string.match(weapon.Name, "^" .. baseName) then
                local args = {
                    {
                        {
                            ["Action"] = "Sell",
                            ["Event"] = "WeaponAction",
                            ["Name"] = weapon.Name
                        },
                        "\n"
                    }
                }
                game:GetService("ReplicatedStorage")
                    :WaitForChild("BridgeNet2")
                    :WaitForChild("dataRemoteEvent")
                    :FireServer(unpack(args))
                
                print("Selling: " .. weapon.Name)
                soldCount = soldCount + 1
                wait(0.3)
                break -- Stop checking other names once matched
            end
        end
    end
    
    print("Finished selling " .. soldCount .. " junk weapons")
    return soldCount
end

-- Load Material UI Library from ReplicatedStorage or ServerStorage
local MaterialUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

-- Create a new Material UI window
local UI = MaterialUI.Load({
    Title = "Weapon Manager",
    Style = 3,
    SizeX = 500,
    SizeY = 550,
    Theme = "Dark"
})

-- Create a single comprehensive tab
local mainTab = UI.New({
    Title = "Weapons"
})

-- Add section titles for better organization
mainTab.Label({
    Text = "--- SCYTHE UPGRADING ---",
    TextSize = 16,
    TextColor = Color3.fromRGB(255, 255, 255)
})

-- Upgrade inputs
local startLevelInput = mainTab.TextField({
    Text = "Start Level",
    Placeholder = "e.g. 1",
    Callback = function(value) end
})

local nextLevelInput = mainTab.TextField({
    Text = "Next Level",
    Placeholder = "e.g. 2",
    Callback = function(value) end
})

local maxLevelInput = mainTab.TextField({
    Text = "Max Level",
    Placeholder = "e.g. 4",
    Callback = function(value) end
})

-- Upgrade buttons
mainTab.Button({
    Text = "Upgrade Single Level",
    Callback = function()
        local levelCondition = tonumber(startLevelInput.Text)
        local upgradeLevel = tonumber(nextLevelInput.Text)
        
        if not levelCondition or not upgradeLevel then
            return mainTab.Banner({
                Text = "Invalid input for level or upgrade level."
            })
        end
        
        combineWeaponsForLevel(levelCondition, upgradeLevel)
        mainTab.Banner({
            Text = "Completed single level upgrade"
        })
    end
})

mainTab.Button({
    Text = "Upgrade All Levels",
    Callback = function()
        local startLevel = tonumber(startLevelInput.Text)
        local nextLevel = tonumber(nextLevelInput.Text)
        local maxLevel = tonumber(maxLevelInput.Text)
        
        if not startLevel or not nextLevel or not maxLevel then
            return mainTab.Banner({
                Text = "Invalid input for levels."
            })
        end
        
        -- Loop from the starting level until one less than the maximum.
        for currentLevel = startLevel, maxLevel - 1 do
            local upgradeLevel = currentLevel + 1
            print('Upgrading weapons from level', currentLevel, 'to', upgradeLevel)
            combineWeaponsForLevel(currentLevel, upgradeLevel)
            wait(1) -- Delay between level upgrades
        end
        
        mainTab.Banner({
            Text = "Completed all level upgrades"
        })
    end
})

-- Add purchasing section
mainTab.Label({
    Text = "--- WEAPON PURCHASING ---",
    TextSize = 16,
    TextColor = Color3.fromRGB(255, 255, 255)
})

local buyAmountInput = mainTab.TextField({
    Text = "Amount to Buy",
    Placeholder = "e.g. 10",
    Callback = function(value) end
})

mainTab.Button({
    Text = "Buy Reaper Scythes",
    Callback = function()
        local amount = tonumber(buyAmountInput.Text)
        if not amount then
            return mainTab.Banner({
                Text = "Invalid number entered."
            })
        end
        buyReaperScythes(amount)
        mainTab.Banner({
            Text = "Purchased " .. amount .. " Reaper Scythes"
        })
    end
})

-- Add button to buy Rare Dust
mainTab.Button({
    Text = "Buy Rare Dust",
    Callback = function()
        buyRareDust()
        mainTab.Banner({
            Text = "Purchased Rare Dust"
        })
    end
})

-- Add junk selling section
mainTab.Label({
    Text = "--- JUNK SELLING ---",
    TextSize = 16,
    TextColor = Color3.fromRGB(255, 255, 255)
})

mainTab.Button({
    Text = "Sell All Junk Weapons",
    Callback = function()
        local count = sellAllJunkWeapons()
        mainTab.Banner({
            Text = "Sold " .. count .. " junk weapons"
        })
    end
})

-- Set initial values
startLevelInput.Text = "1"
nextLevelInput.Text = "2"
maxLevelInput.Text = "4"
buyAmountInput.Text = "10"

-- Use UserInputService to detect when the LeftControl key is pressed to toggle GUI
local UserInputService = game:GetService("UserInputService")
local guiVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    
    if input.KeyCode == Enum.KeyCode.LeftControl then
        guiVisible = not guiVisible
        UI.Toggle(guiVisible)
    end
end)

