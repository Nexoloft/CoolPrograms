-- When executed, immediately enables godmode once without the background loop
pcall(function()
	shared.PepsiSwarm.mods.god = true
	shared.PepsiSwarm.panic = false

	local me = Pepsi.Lp
	local c = me and (me.Character or workspace:FindFirstChild(me.Name))
	local h = Pepsi.Human()
	if not (me and c and h) then
		return
	end

	local tool = shared.PepsiSwarm.mods.scoop and Pepsi.Tool() or nil
	if tool and dbg and dbg.sc and dbg.gse and (math.random(3) == 2 or Pepsi.IsMarked(tool, "scoop")) then
		pcall(function()
			pcall(dbg.sc, rawget(dbg.gse(tool:FindFirstChild("ClientScriptMouse")), "collectStart"), 11, ((shared.PepsiSwarm.mods.scoop and "GetMouseButtonsPressed") or "IsMouseButtonPressed"))
		end)
		if dbg and type(dbg.gse) == "function" then
			pcall(function()
				dbg.gse(Pepsi.Tool().ClientScriptMouse).onEquippedLocal(Pepsi.Mouse())
			end)
		end
		Pepsi.Mark(tool, "scoop")
	end

	local cam = Pepsi.GetCam()
	local cf = cam and cam.CFrame
	if not cam or not cf then
		return
	end

	h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local nh = h:Clone()
	Pepsi.Mark(nh, "god")
	me.Character = nil
	nh:SetStateEnabled(15, false)
	nh:SetStateEnabled(1, false)
	nh:SetStateEnabled(0, false)
	nh.Parent = c
	h:Destroy()
	me.Character, cam.CameraSubject = c, nh
	Pepsi.Rs:Wait()
	cam.CFrame = cf
	h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local s = c:FindFirstChild("Animate")
	if s then
		s.Disabled = true
		Pepsi.Rs:Wait()
		s.Disabled = false
	end
	delay(2, function()
		if nh then
			nh.Health = 100
		end
	end)
	if dbg and type(dbg.gse) == "function" then
		pcall(function()
			dbg.gse(Pepsi.Tool().ClientScriptMouse).onEquippedLocal(Pepsi.Mouse())
		end)
	end
end)
