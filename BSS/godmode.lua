-- Godmode script extracted from Pepsi Swarm
-- This script provides godmode functionality for Bee Swarm Simulator

spawn(function()
	while not shared.PepsiSwarm.running or (shared.PepsiSwarm.panic and not shared.PepsiSwarm.values.scooppanic) do
		wait(1)
	end
	while wait(1) do
		pcall(function()
			while not shared.PepsiSwarm.mods.god or shared.PepsiSwarm.panic or Pepsi.Health() <= 0 or Pepsi.IsMarked(Pepsi.Human(), "god") do
				pcall(function()
					if not shared.PepsiSwarm.mods.god and Pepsi.IsMarked(Pepsi.Human(), "god") then
						local me = Pepsi.Lp
						local c, h = (me.Character or workspace:FindFirstChild(me.Name)), Pepsi.Human()
						h:SetStateEnabled(15, true)
						h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
						me.Character = nil
						h:ChangeState(15)
						me.Character = c
						h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
						Pepsi.Mark(h, "god", false)
						if dbg and type(dbg.gse) == "function" then
							pcall(function() -- I would use securecall, however this game doesnt check that kinda stuff
								dbg.gse(Pepsi.Tool().ClientScriptMouse).onEquippedLocal(Pepsi.Mouse())
							end)
						end
						wait(5.5)
					end
				end)
				wait(1)
			end
			if shared.PepsiSwarm.mods.god and not shared.PepsiSwarm.panic then
				local tool = nil
				if shared.PepsiSwarm.mods.scoop then
					tool = Pepsi.Tool()
				end
				--if shared["I know what I'm doing!"] == "confirm" then
					if tool and shared.PepsiSwarm.mods.scoop and dbg and dbg.sc and dbg.gse and (math.random(3) == 2 or Pepsi.IsMarked(tool, "scoop")) then
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
				--end
				wait(0.5)
				local cam = Pepsi.GetCam()
				local cf, me = cam.CFrame, Pepsi.Lp
				local c, h = (me.Character or workspace:FindFirstChild(me.Name)), Pepsi.Human()
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
			end
		end)
	end
end)
