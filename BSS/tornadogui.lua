-- Simple standalone GUI to toggle the tornado helper on/off with a checkbox-style button.

-- Tornado logic (no external module required)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PARTICLE_ROOT_NAME = "Root"
local PARTICLE_PLANE_NAME = "Plane"
local TWEEN_TIME = 0.3
local MAX_DISTANCE = 500

local running = false
local loopThread

local function getRoot()
    local plr = Players.LocalPlayer
    local char = plr and plr.Character
    return char and char:FindFirstChild("HumanoidRootPart"), plr
end

local function stepOnce()
    local hrp, plr = getRoot()
    if not hrp or not plr then return end

    local info = TweenInfo.new(TWEEN_TIME)
    local targetProps = {}
    local nameA = tostring(plr.Name)

    for _, part in pairs(Workspace.Particles:GetDescendants()) do
        if part.Name == PARTICLE_ROOT_NAME or part.Name == PARTICLE_PLANE_NAME then
            
            -- [[ NEW CHECK START ]] --
            -- We need to find the DangerBlink script to check its status.
            local dangerScript = part:FindFirstChild("DangerBlink")

            -- If we are processing the "Root", the script is likely in the sibling "Plane"
            if not dangerScript and part.Parent then
                local siblingPlane = part.Parent:FindFirstChild("Plane")
                if siblingPlane then
                    dangerScript = siblingPlane:FindFirstChild("DangerBlink")
                end
            end

            -- Logic: If DangerBlink exists AND it is Enabled (Disabled is false), skip this tornado.
            if dangerScript and dangerScript.Disabled == false then
                continue
            end
            -- [[ NEW CHECK END ]] --

            for _, c in pairs(Workspace.Collectibles:GetChildren()) do
                local nameStr = tostring(c)
                if nameStr == nameA or nameStr == "C" then
                    if (c.Position - hrp.Position).Magnitude <= MAX_DISTANCE then
                        targetProps.CFrame = CFrame.new(c.Position.X, hrp.Position.Y, c.Position.Z)
                        local tween = TweenService:Create(part, info, targetProps)
                        tween:Play()
                    end
                end
            end
        end
    end
end

local function startTornado()
    if running then return end
    running = true
    loopThread = task.spawn(function()
        while running do
            stepOnce()
            task.wait(0.3)
        end
    end)
end

local function stopTornado()
    running = false
    loopThread = nil
end

-- Build GUI
local ui = Instance.new("ScreenGui")
ui.Name = "TornadoToggleGUI"
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true
ui.Parent = game.CoreGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Parent = ui
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
panel.BorderSizePixel = 0
panel.Position = UDim2.new(0, 20, 0, 200)
panel.Size = UDim2.new(0, 200, 0, 70)
panel.Active = true
panel.Draggable = true

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = panel
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.new(0, 10, 0, 6)
title.Font = Enum.Font.GothamBold
title.Text = "Tornado"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.Parent = panel
toggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
toggle.BorderSizePixel = 0
toggle.Position = UDim2.new(0, 10, 0, 36)
toggle.Size = UDim2.new(0, 180, 0, 26)
toggle.Font = Enum.Font.GothamBold
toggle.Text = "[ ] Bring Tornado"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 14

local on = false

local function setState(nextState)
    on = nextState
    if on then
        toggle.BackgroundColor3 = Color3.fromRGB(60, 170, 90)
        toggle.Text = "[X] Bring Tornado"
        startTornado()
    else
        toggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        toggle.Text = "[ ] Bring Tornado"
        stopTornado()
    end
end

toggle.MouseButton1Click:Connect(function()
    setState(not on)
end)

-- Stop the tornado when the GUI is destroyed (e.g., teleport, re-execution).
ui.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        setState(false)
    end
end)

-- Start enabled by default.
setState(true)