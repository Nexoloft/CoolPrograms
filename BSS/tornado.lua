-- Tornado helper extracted from DarkCyber GUI
-- Tweens tornado particle parts toward nearby collectibles near the player.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LOCAL_PLAYER = Players.LocalPlayer
local ROOT = function()
	local char = LOCAL_PLAYER and LOCAL_PLAYER.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local PARTICLE_ROOT_NAME = "Root"
local PARTICLE_PLANE_NAME = "Plane"

local TWEEN_TIME = 0.3
local COLLECTIBLE_MATCH_A = function()
	return tostring(LOCAL_PLAYER and LOCAL_PLAYER.Name)
end
local COLLECTIBLE_MATCH_B = "C"
local MAX_DISTANCE = 60

local running = false

local function stepOnce()
	local hrp = ROOT()
	if not hrp then return end

	local info = TweenInfo.new(TWEEN_TIME)
	local targetProps = {}

	for _, part in pairs(Workspace.Particles:GetDescendants()) do
		if part.Name == PARTICLE_ROOT_NAME or part.Name == PARTICLE_PLANE_NAME then
			for _, c in pairs(Workspace.Collectibles:GetChildren()) do
				local nameStr = tostring(c)
				if nameStr == COLLECTIBLE_MATCH_A() or nameStr == COLLECTIBLE_MATCH_B then
					local mag = (c.Position - hrp.Position).Magnitude
					if mag <= MAX_DISTANCE then
						targetProps.CFrame = CFrame.new(c.Position.X, hrp.Position.Y, c.Position.Z)
						local tween = TweenService:Create(part, info, targetProps)
						tween:Play()
					end
				end
			end
		end
	end
end

local function runLoop()
	running = true
	while running do
		stepOnce()
		task.wait(0.3)
	end
end

local function stopLoop()
	running = false
end

-- Public API
return {
	start = runLoop,
	stop = stopLoop,
	step = stepOnce,
}

