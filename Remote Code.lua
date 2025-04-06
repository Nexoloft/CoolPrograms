local args = {
    [1] = {
        [1] = {
            ["Event"] = "JoinCastle",
        },
        [2] = "\n"
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))