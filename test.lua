local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local remote = ReplicatedStorage
    :WaitForChild('BridgeNet2')
    :WaitForChild('dataRemoteEvent')
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

for i = 1, 100 do
    buyRareDust()
    wait(0.2)
end
