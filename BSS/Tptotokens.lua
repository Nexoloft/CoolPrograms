-- Tptotokens - Standalone Token Teleporter
-- Easy to configure token teleporter with checklist

-- Services
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Utility functions
local function Notify(title, message)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = message,
			Duration = 5
		})
	end)
end

local function GetChar()
	return LocalPlayer.Character
end

local function GetHuman()
	local char = GetChar()
	if char then
		return char:FindFirstChildOfClass("Humanoid")
	end
end

local function WaitForChar()
	if not LocalPlayer.Character then
		LocalPlayer.CharacterAdded:Wait()
	end
	return LocalPlayer.Character
end

print("Loading Tptotokens...")
wait(0.3)
WaitForChar()

-- ===== CONFIGURATION =====
-- Set token priorities: 3 = Very Rare (TP immediately), 2 = Rare, 1 = Low Priority, 0 = Ignore
local TOKEN_CONFIG = {
	-- Very Rare Tokens (Priority 3)
	[2314214749] = {name = "Stinger", priority = 3, enabled = false},
	[3967304192] = {name = "Spirit Petal", priority = 3, enabled = false},
	[2028603146] = {name = "Star Treat", priority = 3, enabled = false},
	[4483267595] = {name = "Neon Berry", priority = 3, enabled = false},
	[4483236276] = {name = "Bitter Berry", priority = 3, enabled = false},
	[4520736128] = {name = "Atomic Treat", priority = 3, enabled = false},
	[4528640710] = {name = "Box of Frogs", priority = 3, enabled = false},
	[2319943273] = {name = "Star Jelly", priority = 3, enabled = false},
	[1674686518] = {name = "Ticket", priority = 3, enabled = false},
	[1674871631] = {name = "Ticket Alt", priority = 3, enabled = false},
	[1987257040] = {name = "Gifted Diamond Egg", priority = 3, enabled = false},
	[1987253833] = {name = "Gifted Silver Egg", priority = 3, enabled = false},
	[1987255318] = {name = "Gifted Gold Egg", priority = 3, enabled = false},
	[2007771339] = {name = "Star Basic Egg", priority = 3, enabled = false},
	[2529092020] = {name = "Magic Bean", priority = 3, enabled = false},
	[2584584968] = {name = "Enzymes", priority = 3, enabled = false},
	[1471850677] = {name = "Diamond Egg", priority = 3, enabled = false},
	[1471848094] = {name = "Silver Egg", priority = 3, enabled = false},
	[1471849394] = {name = "Gold Egg", priority = 3, enabled = false},
	[1471846464] = {name = "Basic Egg", priority = 3, enabled = false},
	[3081760043] = {name = "Plastic Egg", priority = 3, enabled = false},
	[2863122826] = {name = "Micro-Converter", priority = 3, enabled = false},
	[2060626811] = {name = "Ant Pass", priority = 3, enabled = false},
	[4520739302] = {name = "Mythic Egg", priority = 3, enabled = false},
	[2495936060] = {name = "Blue Extract", priority = 3, enabled = false},
	[2545746569] = {name = "Oil", priority = 3, enabled = false},
	[3036899811] = {name = "Robo Pass", priority = 3, enabled = false},
	[2676671613] = {name = "Night Bell", priority = 3, enabled = false},
	[3835877932] = {name = "Tropical Drink", priority = 3, enabled = false},
	[2542899798] = {name = "Glitter", priority = 3, enabled = false},
	[2495935291] = {name = "Red Extract", priority = 3, enabled = false},
	[3030569073] = {name = "Cloud Vial", priority = 3, enabled = false},
	[2676715441] = {name = "Festive Sprout", priority = 3, enabled = false},
	[3080740120] = {name = "Jelly Beans", priority = 3, enabled = false},
	[2863468407] = {name = "Field Dice", priority = 3, enabled = false},
	[2504978518] = {name = "Glue", priority = 3, enabled = false},
	[2594434716] = {name = "Translator", priority = 3, enabled = false},
	[3027672238] = {name = "Marshmallow Bee", priority = 3, enabled = false},
	
	-- Rare Tokens (Priority 2)
	[2306224708] = {name = "Moon Charm", priority = 2, enabled = false},
	[1471882621] = {name = "Royal Jelly", priority = 2, enabled = false},
	[2659216738] = {name = "Present", priority = 2, enabled = false},
	[3012679515] = {name = "Coconut", priority = 2, enabled = false},
	[1629547638] = {name = "Token Link", priority = 2, enabled = false},
	[3582519526] = {name = "Tornado", priority = 2, enabled = false},
	[4889322534] = {name = "Fuzzy Bombs", priority = 2, enabled = false},
	[1671281844] = {name = "Photon Bee", priority = 2, enabled = false},
	[2305425690] = {name = "Puppy Bond", priority = 2, enabled = false},
	[2000457501] = {name = "Inspire", priority = 2, enabled = false},
	[3582501342] = {name = "Cloud", priority = 2, enabled = false},
	[2319083910] = {name = "Vicious Spikes", priority = 2, enabled = false},
	[1472256444] = {name = "Baby Bee Loot", priority = 2, enabled = false},
	[177997841] = {name = "Bear Bee Morph", priority = 2, enabled = false},
	[1442764904] = {name = "Gummy Storm+", priority = 2, enabled = false},
	
	-- Low Priority (Priority 1)
	[2028574353] = {name = "Treat", priority = 1, enabled = false},
	[1472135114] = {name = "Honey", priority = 1, enabled = false},
}

-- Script Settings
local SETTINGS = {
	enabled = false,
	transparency_threshold = 0.2,
	size_threshold = 5,
	auto_honey_mondo = false, -- Auto-enable honey for Mondo Chick
}

-- ===== SCRIPT VARIABLES =====
local running = false
local maytp = true
local blacklistedTokens = {} -- Track tokens that took too long

-- ===== UTILITY FUNCTIONS =====
local function tp(pos, char)
	if not char then
		char = GetChar()
	end
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(pos)
	end
end

local function restate()
	local h = GetHuman()
	if h then
		h:ChangeState(Enum.HumanoidStateType.Running)
	end
end

local function getActiveTokens()
	local tokens = {}
	for id, config in pairs(TOKEN_CONFIG) do
		if config.enabled and config.priority > 0 then
			tokens[id] = config.priority
		end
	end
	return tokens
end

local function findTokenByTextureId(textureId)
	local Collectibles = workspace:FindFirstChild("Collectibles")
	if not Collectibles then
		return nil
	end
	
	for _, token in pairs(Collectibles:GetChildren()) do
		if token:IsA("BasePart") then
			local decal = token:FindFirstChildOfClass("Decal")
			if decal and decal.Texture then
				local id = tonumber(string.match(decal.Texture, "%d+"))
				if id == textureId then
					return token
				end
			end
		end
	end
	
	return nil
end

local function findBestToken()
	local bestToken = nil
	local bestPriority = 0
	
	local activeTokens = getActiveTokens()
	
	for id, priority in pairs(activeTokens) do
		if priority >= 1 then -- Check all priorities (1, 2, 3)
			local token = findTokenByTextureId(id)
			if token and typeof(token) == "Instance" and token:IsA("BasePart") then
				-- Skip blacklisted tokens
				if not blacklistedTokens[token] then
					if token.Transparency < SETTINGS.transparency_threshold and token.Size.Y < SETTINGS.size_threshold then
						if priority > bestPriority then
							bestToken = token
							bestPriority = priority
						end
					end
				end
				end
			end
		end
	
	return bestToken, bestPriority
end

local function collectToken(token)
	if not token then
		return
	end
	
	local char = GetChar()
	if not char then
		return
	end
	
	local h = GetHuman()
	if not h or h.Health <= 0 then
		return
	end
	
	local startTime = tick()
	local maxTime = 5 -- Maximum 5 seconds per token
	
	while h and h.Health > 0 and token and token.Parent and token.Size.Y < SETTINGS.size_threshold and token.Transparency < SETTINGS.transparency_threshold do
		if not SETTINGS.enabled then
			break
		end
		
		-- Check if we've been stuck on this token for too long
		if tick() - startTime > maxTime then
			blacklistedTokens[token] = true
			-- Clear blacklist after 30 seconds in case token becomes accessible
			spawn(function()
				wait(30)
				blacklistedTokens[token] = nil
			end)
			Notify("Tptotokens", "Token stuck, skipping to next one...")
			break
		end
		
		maytp = false
		h = GetHuman()
		
		tp(token.Position, char)
		
		wait()
	end
	
	restate()
	maytp = true
end

-- ===== MONDO CHICK MONITOR =====
local mondoLastSeen = 0
local function checkMondoChick()
	while running do
		wait(2)
		
		if SETTINGS.auto_honey_mondo then
			local Monsters = workspace:FindFirstChild("Monsters")
			if Monsters then
				local mondoChick = Monsters:FindFirstChild("Mondo Chick")
				
				if mondoChick then
					-- Mondo is alive, enable honey
					mondoLastSeen = tick()
					if not TOKEN_CONFIG[1472135114].enabled then
						TOKEN_CONFIG[1472135114].enabled = true
						Notify("Tptotokens", "Mondo Chick detected! Honey collection enabled.")
					end
				else
					-- Mondo is not alive, check if 20 seconds passed
					local timeSinceLastSeen = tick() - mondoLastSeen
					if timeSinceLastSeen > 20 then
						if TOKEN_CONFIG[1472135114].enabled then
							TOKEN_CONFIG[1472135114].enabled = false
							Notify("Tptotokens", "Mondo Chick gone for 20s. Honey collection disabled.")
						end
					end
				end
			end
		end
	end
end

-- ===== MAIN LOOP =====
local function mainLoop()
	while running do
		wait(0.1)
		
		if not SETTINGS.enabled then
			wait(1)
			continue
		end
		
		if maytp then
			local token, priority = findBestToken()
			if token and priority >= 1 then
				collectToken(token)
			end
		end
	end
end

-- ===== GUI SETUP =====
local function setupGUI()
	local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))()
	
	local GUI = Library:CreateWindow("Tptotokens")
	
	-- Make GUI draggable with custom implementation
	spawn(function()
		task.wait(0.5)
		pcall(function()
			local UserInputService = game:GetService("UserInputService")
			local playerGui = LocalPlayer:WaitForChild("PlayerGui")
			
			-- Find the GUI
			local mainFrame
			for _, child in pairs(playerGui:GetChildren()) do
				if child:IsA("ScreenGui") then
					local main = child:FindFirstChild("Main", true)
					if main and main:IsA("GuiObject") then
						mainFrame = main
						break
					end
				end
			end
			
			if mainFrame then
				local dragging = false
				local dragInput
				local dragStart
				local startPos
				
				local function update(input)
					local delta = input.Position - dragStart
					mainFrame.Position = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + delta.X,
						startPos.Y.Scale,
						startPos.Y.Offset + delta.Y
					)
				end
				
				mainFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						dragStart = input.Position
						startPos = mainFrame.Position
						
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								dragging = false
							end
						end)
					end
				end)
				
				mainFrame.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						dragInput = input
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if input == dragInput and dragging then
						update(input)
					end
				end)
				
				print("✓ GUI is now draggable!")
			else
				warn("Could not find Main frame for dragging")
			end
		end)
	end)
	
	-- Main Controls Section
	local MainTab = GUI:CreateFolder("Main Controls")
	
	MainTab:Toggle("Enable Token Teleporter", function(bool)
		SETTINGS.enabled = bool
		if bool then
			Notify("Tptotokens", "Token teleporter enabled!")
		else
			Notify("Tptotokens", "Token teleporter disabled!")
		end
	end, {default = false})
	
	MainTab:Toggle("Auto-Enable Honey for Mondo", function(bool)
		SETTINGS.auto_honey_mondo = bool
		if bool then
			Notify("Tptotokens", "Will auto-collect honey when Mondo Chick spawns!")
		else
			Notify("Tptotokens", "Mondo Chick honey auto-collect disabled!")
		end
	end, {default = false})
	
	-- Very Rare Tokens Section
	local VeryRareTab = GUI:CreateFolder("Very Rare Tokens (Priority 3)")
	
	for id, config in pairs(TOKEN_CONFIG) do
		if config.priority == 3 then
			VeryRareTab:Toggle(config.name, function(bool)
				TOKEN_CONFIG[id].enabled = bool
			end, {default = config.enabled})
		end
	end
	
	-- Rare Tokens Section
	local RareTab = GUI:CreateFolder("Rare Tokens (Priority 2)")
	
	for id, config in pairs(TOKEN_CONFIG) do
		if config.priority == 2 then
			RareTab:Toggle(config.name, function(bool)
				TOKEN_CONFIG[id].enabled = bool
			end, {default = config.enabled})
		end
	end
	
	-- Low Priority Tokens Section
	local LowPriorityTab = GUI:CreateFolder("Low Priority Tokens (Priority 1)")
	
	for id, config in pairs(TOKEN_CONFIG) do
		if config.priority == 1 then
			LowPriorityTab:Toggle(config.name, function(bool)
				TOKEN_CONFIG[id].enabled = bool
			end, {default = config.enabled})
		end
	end
	
	-- Quick Toggles Section
	local QuickTab = GUI:CreateFolder("Quick Toggles")
	
	QuickTab:Button("Enable All Very Rare", function()
		for id, config in pairs(TOKEN_CONFIG) do
			if config.priority == 3 then
				TOKEN_CONFIG[id].enabled = true
			end
		end
		Notify("Tptotokens", "All very rare tokens enabled! Reload GUI to see changes.")
	end)
	
	QuickTab:Button("Enable All Rare", function()
		for id, config in pairs(TOKEN_CONFIG) do
			if config.priority == 2 then
				TOKEN_CONFIG[id].enabled = true
			end
		end
		Notify("Tptotokens", "All rare tokens enabled! Reload GUI to see changes.")
	end)
	
	QuickTab:Button("Enable All", function()
		for id, config in pairs(TOKEN_CONFIG) do
			TOKEN_CONFIG[id].enabled = true
		end
		Notify("Tptotokens", "All tokens enabled! Reload GUI to see changes.")
	end)
	
	QuickTab:Button("Disable All", function()
		for id, config in pairs(TOKEN_CONFIG) do
			TOKEN_CONFIG[id].enabled = false
		end
		Notify("Tptotokens", "All tokens disabled! Reload GUI to see changes.")
	end)
	
	-- Info Section
	local InfoTab = GUI:CreateFolder("Info")
	
	InfoTab:Label("Tptotokens v1.0", {TextSize = 15, TextColor = Color3.fromRGB(255, 255, 255), BgColor = Color3.fromRGB(50, 50, 50)})
	InfoTab:Label("Standalone token teleporter", {TextSize = 12, TextColor = Color3.fromRGB(200, 200, 200), BgColor = Color3.fromRGB(50, 50, 50)})
	InfoTab:Label("Based on Pepsiswarm logic", {TextSize = 12, TextColor = Color3.fromRGB(200, 200, 200), BgColor = Color3.fromRGB(50, 50, 50)})
end

-- ===== STARTUP =====
Notify("Tptotokens", "Initializing...")

running = true

-- Start main loop
spawn(function()
	mainLoop()
end)

-- Start Mondo Chick monitor
spawn(function()
	checkMondoChick()
end)

-- Setup GUI
pcall(function()
	setupGUI()
end)

Notify("Tptotokens", "Ready! Use the GUI to configure and enable.")

-- Keep script running after character respawn
LocalPlayer.CharacterAdded:Connect(function()
	wait(1)
	Notify("Tptotokens", "Character respawned - script still active!")
end)
