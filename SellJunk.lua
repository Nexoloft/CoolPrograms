-- List of junk weapon base names
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
            game:GetService("ReplicatedStorage")
                :WaitForChild("BridgeNet2")
                :WaitForChild("dataRemoteEvent")
                :FireServer(unpack(args))
            wait(0.3)
            break -- Stop checking other names once matched
        end
    end
end
