local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local remote = ReplicatedStorage
    :WaitForChild('BridgeNet2')
    :WaitForChild('dataRemoteEvent')

-- Create the ScreenGui
local screenGui = Instance.new('ScreenGui')
screenGui.Parent = player:WaitForChild('PlayerGui')

-- Create a frame to hold our UI elements
local frame = Instance.new('Frame')
frame.Size = UDim2.new(0, 350, 0, 300)
frame.Position = UDim2.new(0.5, -175, 0.5, -150)
frame.BackgroundTransparency = 0.2
frame.Active = true -- To allow dragging
frame.Draggable = true -- Make the frame movable
frame.Parent = screenGui

-- Input for current level condition (for upgrade from)
local levelLabel = Instance.new('TextLabel')
levelLabel.Size = UDim2.new(1, 0, 0, 30)
levelLabel.Position = UDim2.new(0, 0, 0, 0)
levelLabel.Text = 'Start Level (e.g. 1):'
levelLabel.Parent = frame

local levelTextBox = Instance.new('TextBox')
levelTextBox.Size = UDim2.new(1, 0, 0, 30)
levelTextBox.Position = UDim2.new(0, 0, 0, 30)
levelTextBox.Text = '1'
levelTextBox.ClearTextOnFocus = false
levelTextBox.Parent = frame

-- Input for upgrade level (for upgrade to; normally startLevel+1)
local upgradeLabel = Instance.new('TextLabel')
upgradeLabel.Size = UDim2.new(1, 0, 0, 30)
upgradeLabel.Position = UDim2.new(0, 0, 0, 70)
upgradeLabel.Text = 'Next Level (e.g. 2):'
upgradeLabel.Parent = frame

local upgradeTextBox = Instance.new('TextBox')
upgradeTextBox.Size = UDim2.new(1, 0, 0, 30)
upgradeTextBox.Position = UDim2.new(0, 0, 0, 100)
upgradeTextBox.Text = '2'
upgradeTextBox.ClearTextOnFocus = false
upgradeTextBox.Parent = frame

-- Input for maximum level to upgrade until
local maxLabel = Instance.new('TextLabel')
maxLabel.Size = UDim2.new(1, 0, 0, 30)
maxLabel.Position = UDim2.new(0, 0, 0, 140)
maxLabel.Text = 'Max Level (stop before upgrading to this level):'
maxLabel.Parent = frame

local maxTextBox = Instance.new('TextBox')
maxTextBox.Size = UDim2.new(1, 0, 0, 30)
maxTextBox.Position = UDim2.new(0, 0, 0, 170)
maxTextBox.Text = '4'
maxTextBox.ClearTextOnFocus = false
maxTextBox.Parent = frame

-- Button to upgrade a single level (using current inputs for level condition and upgrade level)
local runButton = Instance.new('TextButton')
runButton.Size = UDim2.new(1, 0, 0, 40)
runButton.Position = UDim2.new(0, 0, 0, 210)
runButton.Text = 'Upgrade Single Level'
runButton.Parent = frame

-- Button to upgrade through all levels (from startLevel to maxLevel-1)
local runAllButton = Instance.new('TextButton')
runAllButton.Size = UDim2.new(1, 0, 0, 40)
runAllButton.Position = UDim2.new(0, 0, 0, 260)
runAllButton.Text = 'Upgrade All Levels'
runAllButton.Parent = frame

-- Add a button to buy a custom number of reaper scythes
local buyButton = Instance.new('TextButton')
buyButton.Size = UDim2.new(1, 0, 0, 40)
buyButton.Position = UDim2.new(0, 0, 0, 310)
buyButton.Text = 'Buy Custom Amount of Reaper Scythes'
buyButton.Parent = frame

-- Input for how many scythes to buy
local buyAmountBox = Instance.new('TextBox')
buyAmountBox.Size = UDim2.new(1, 0, 0, 30)
buyAmountBox.Position = UDim2.new(0, 0, 0, 350)
buyAmountBox.Text = '10'
buyAmountBox.ClearTextOnFocus = false
buyAmountBox.PlaceholderText = 'Enter number of scythes to buy'
buyAmountBox.Parent = frame

-- Hook up button to buying scythes
buyButton.MouseButton1Click:Connect(function()
    local amount = tonumber(buyAmountBox.Text)
    if not amount then
        print('Invalid number entered.')
        return
    end
    buyReaperScythes(amount)
end)

-- Initially, the GUI is visible
local guiVisible = true

-- Function to toggle the visibility of the GUI
local function toggleGUI()
    guiVisible = not guiVisible
    screenGui.Enabled = guiVisible
end

-- Use UserInputService to detect when the LeftControl key is pressed
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end -- Prevents the function from running when the game already processed the event

    if input.KeyCode == Enum.KeyCode.LeftControl then
        toggleGUI()
    end
end)

---------------------------------
-- Utility Functions
---------------------------------

-- Buy scythes with 0.3s delay
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
        wait(0.3)
    end
end


-- Returns an array of weapon names that have the required level.
local function getWeaponsAtLevel(levelCondition)
    local weaponFolder = player.leaderstats.Inventory.Weapons
    local matchingWeapons = {}

    -- Instead of going through every weapon on every call, you could
    -- maintain a lookup table if you update it on changes.
    -- For now, we directly search.
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
-- Button Event Handlers
---------------------------------

-- Upgrade a single level using the values from levelTextBox and upgradeTextBox.
runButton.MouseButton1Click:Connect(function()
    local levelCondition = tonumber(levelTextBox.Text)
    local upgradeLevel = tonumber(upgradeTextBox.Text)

    if not levelCondition or not upgradeLevel then
        print('Invalid input for level or upgrade level.')
        return
    end

    combineWeaponsForLevel(levelCondition, upgradeLevel)
end)

-- Upgrade through all levels starting from levelTextBox to maxTextBox.
runAllButton.MouseButton1Click:Connect(function()
    local startLevel = tonumber(levelTextBox.Text)
    local nextLevel = tonumber(upgradeTextBox.Text)
    local maxLevel = tonumber(maxTextBox.Text)

    if not startLevel or not nextLevel or not maxLevel then
        print('Invalid input for levels.')
        return
    end

    -- Loop from the starting level until one less than the maximum.
    for currentLevel = startLevel, maxLevel - 1 do
        local upgradeLevel = currentLevel + 1
        print('Upgrading weapons from level', currentLevel, 'to', upgradeLevel)
        combineWeaponsForLevel(currentLevel, upgradeLevel)
        wait(1) -- Delay between level upgrades; adjust as needed
    end
end)
