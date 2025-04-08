local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local remote = ReplicatedStorage
    :WaitForChild('BridgeNet2')
    :WaitForChild('dataRemoteEvent')

---------------------------------
-- Toggle State Variables
---------------------------------
local isBuyingScythes = false
local isCombiningScythes = false
local isUpgradingAllLevels = false

---------------------------------
-- Utility Functions
---------------------------------

-- Buy scythes continuously until toggled off
local function buyReaperScythesToggle()
    if isBuyingScythes then
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
        
        wait(.3)  -- Delay between purchases
        
        -- Recursively call function if still toggled on
        if isBuyingScythes then
            buyReaperScythesToggle()
        end
    end
end

-- Buy specific number of scythes (non-toggle function)
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

-- Combines weapons continuously until toggled off
local function combineWeaponsForLevelToggle(levelCondition, upgradeLevel)
    if isCombiningScythes then
        local weapons = getWeaponsAtLevel(levelCondition)
        
        if #weapons >= 3 then
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
            wait(0.2) -- Delay to prevent flooding
            
            -- Recursively call function if still toggled on
            if isCombiningScythes then
                wait(0.3) -- Additional delay between combine operations
                combineWeaponsForLevelToggle(levelCondition, upgradeLevel)
            end
        else
            print("Not enough weapons at level " .. levelCondition .. " to combine")
            isCombiningScythes = false
        end
    end
end

-- Original combineWeaponsForLevel function (non-toggle version)
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
        wait(0.2) -- Delay to prevent flooding
    end
end

-- Function to continuously run all level upgrades
local function upgradeAllLevelsToggle(startLevel, maxLevel)
    if isUpgradingAllLevels then
        for currentLevel = startLevel, maxLevel - 1 do
            if not isUpgradingAllLevels then
                break
            end
            
            local upgradeLevel = currentLevel + 1
            print('Upgrading weapons from level', currentLevel, 'to', upgradeLevel)
            
            local weapons = getWeaponsAtLevel(currentLevel)
            while #weapons >= 3 and isUpgradingAllLevels do
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
                
                remote:FireServer(unpack(args))
                print('Upgraded group to level', upgradeLevel)
                wait(0.2) -- Delay to prevent flooding
                
                -- Refresh weapons list
                weapons = getWeaponsAtLevel(currentLevel)
            end
            
            wait(0.5) -- Delay between level upgrades
        end
        
        isUpgradingAllLevels = false
        print("Finished all level upgrades or toggle turned off")
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
                    [1] = {
                        [1] = {
                            ["Weapons"] = {
                                [1] = weapon.Name
                            },
                            ["Event"] = "WeaponAction",
                            ["Action"] = "Sell"
                        },
                        [2] = "\n"
                    }
                }
                
                remote:FireServer(unpack(args))
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
    SizeY = 600,  -- Increased height for additional elements
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

-- Toggle button for single level combining
local combineToggleButton = mainTab.Button({
    Text = "🔄 Toggle Continuous Combine (OFF)",
    Callback = function()
        local levelCondition = tonumber(startLevelInput.Text)
        local upgradeLevel = tonumber(nextLevelInput.Text)
        
        if not levelCondition or not upgradeLevel then
            return mainTab.Banner({
                Text = "Invalid input for level or upgrade level."
            })
        end
        
        isCombiningScythes = not isCombiningScythes
        
        if isCombiningScythes then
            combineToggleButton:SetText("🔄 Toggle Continuous Combine (ON)")
            mainTab.Banner({
                Text = "Started continuous combining from level " .. levelCondition .. " to " .. upgradeLevel
            })
            combineWeaponsForLevelToggle(levelCondition, upgradeLevel)
        else
            combineToggleButton:SetText("🔄 Toggle Continuous Combine (OFF)")
            mainTab.Banner({
                Text = "Stopped continuous combining"
            })
        end
    end
})

-- Original single level upgrade button (non-toggle)
mainTab.Button({
    Text = "Upgrade Single Level (One Time)",
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

-- Toggle button for all level upgrading
local allLevelsToggleButton = mainTab.Button({
    Text = "🔄 Toggle All Levels Upgrade (OFF)",
    Callback = function()
        local startLevel = tonumber(startLevelInput.Text)
        local maxLevel = tonumber(maxLevelInput.Text)
        
        if not startLevel or not maxLevel then
            return mainTab.Banner({
                Text = "Invalid input for levels."
            })
        end
        
        isUpgradingAllLevels = not isUpgradingAllLevels
        
        if isUpgradingAllLevels then
            allLevelsToggleButton:SetText("🔄 Toggle All Levels Upgrade (ON)")
            mainTab.Banner({
                Text = "Started continuous upgrading from level " .. startLevel .. " to " .. maxLevel
            })
            upgradeAllLevelsToggle(startLevel, maxLevel)
        else
            allLevelsToggleButton:SetText("🔄 Toggle All Levels Upgrade (OFF)")
            mainTab.Banner({
                Text = "Stopped continuous upgrading"
            })
        end
    end
})

-- Original all levels upgrade button (non-toggle)
mainTab.Button({
    Text = "Upgrade All Levels (One Time)",
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

-- Toggle button for continuous buying
local buyToggleButton = mainTab.Button({
    Text = "🔄 Toggle Continuous Buy (OFF)",
    Callback = function()
        isBuyingScythes = not isBuyingScythes
        
        if isBuyingScythes then
            buyToggleButton:SetText("🔄 Toggle Continuous Buy (ON)")
            mainTab.Banner({
                Text = "Started continuous buying of Reaper Scythes"
            })
            buyReaperScythesToggle()
        else
            buyToggleButton:SetText("🔄 Toggle Continuous Buy (OFF)")
            mainTab.Banner({
                Text = "Stopped continuous buying"
            })
        end
    end
})

-- Original buy button (non-toggle)
mainTab.Button({
    Text = "Buy Specific Amount (One Time)",
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

-- Add emergency stop button
mainTab.Label({
    Text = "--- EMERGENCY CONTROLS ---",
    TextSize = 16,
    TextColor = Color3.fromRGB(255, 0, 0)
})

mainTab.Button({
    Text = "⛔ STOP ALL PROCESSES ⛔",
    Callback = function()
        isBuyingScythes = false
        isCombiningScythes = false
        isUpgradingAllLevels = false
        
        buyToggleButton:SetText("🔄 Toggle Continuous Buy (OFF)")
        combineToggleButton:SetText("🔄 Toggle Continuous Combine (OFF)")
        allLevelsToggleButton:SetText("🔄 Toggle All Levels Upgrade (OFF)")
        
        mainTab.Banner({
            Text = "Emergency stop: All processes terminated!"
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
