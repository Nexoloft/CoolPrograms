local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = ReplicatedStorage:WaitForChild("BridgeNet2")
local RemoteEvent = BridgeNet2:WaitForChild("dataRemoteEvent")

local items = {
    "DgHealthRune",
    "DgRoomRune",
    "DgTimeRune",
    "DgMoreRoomRune",
    "DgCashRune",
    "DgGemsRune",
    "DgURankUpRune"
}

-- Function to fire the remote with the correct args
local function fireRemote(itemName)
    local args = {
        {
            {
                ["Action"] = "Buy",
                ["Shop"] = "RuneShop",
                ["Item"] = itemName,
                ["Event"] = "ItemShopAction"
            },
            "\n"
        }
    }
    RemoteEvent:FireServer(unpack(args))
end

-- Fire each item 15 times with a 0.5 second delay
for i = 1, 15 do
    for _, item in ipairs(items) do
        fireRemote(item)
        task.wait(0.5)
    end
end
