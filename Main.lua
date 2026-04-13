local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/magbux/BorealisUiLib/refs/heads/main/Library.Lua"))()
local Alurt = loadstring(game:HttpGet("https://raw.githubusercontent.com/azir-py/project/refs/heads/main/Zwolf/AlurtUI.lua"))()

local Window = Library.new("CubeWare (BEDWARS EDITION) (HAPPY BIRTHDAY OWNER!!!) (V1.0.0)")

local shouldNotify = false

local SettingsTab = Window:MakeTab("Settings")
local BlatantTab = Window:MakeTab("BLATANT")
local keybind_cooldown = false

local Settings = {
  ["KillAura"] = {
    ["Enabled"] = false,
    ["Reach"] = 0,
	["WallCheck"] = false;
	["Angle"] = 180,
	["Cooldown"] = 0.05
  }
}

local plrs = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local lp = plrs.LocalPlayer
local net = rs.rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.SwordHit
local inv = rs.Inventories:FindFirstChild(lp.Name)

local function getSword()
  return inv:FindFirstChild("wood_sword") or
  inv:FindFirstChild("stone_sword") or
  inv:FindFirstChild("iron_sword") or
  inv:FindFirstChild("diamond_sword") or
  inv:FindFirstChild("emerald_sword")
end

local function dist(p1, p2)
   return (p1 - p2).Magnitude
end

local function checkBehindWalls()
	local plr = game:GetService("Players").LocalPlayer
	local ray = workspace:Raycast(plr.Character.PrimaryPart.Position, 
	(plr.Character.PrimaryPart.Position + plr.Character.PrimaryPart.CFrame.LookVector.Unit * Settings["KillAura"]["Angle"]))

	if ray then
		if ray.Instance then
			if ray.Instance.Parent:FindFirstChildOfClass("Humanoid") then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end

	return false
end

SettingsTab:AddToggle({
	Name = "Spawn Notifications?",
	Callback = function(Value)
		shouldNotify = Value
		print(shouldNotify)
	end
})

BlatantTab:AddKeybind("KillAura", Enum.KeyCode.K, function()
	if keybind_cooldown == true then return end
	
	Settings["KillAura"]["Enabled"] = not Settings["KillAura"]["Enabled"]

	if shouldNotify == true and keybind_cooldown == false then
		local notif1 = Alurt.CreateNode({
   				Title = "Cubeware | KillAura",
   		 		Content = "Kill Aura has been "..(Settings["KillAura"]["Enabled"] == true and "Enabled" or "Disabled").."!",
   		 		Audio = "rbxassetid://0",
    			Length = 3,
   				Image = "rbxassetid://0", 
    			BarColor = Color3.fromRGB(75, 75, 75)
		})
	end

	keybind_cooldown = true
	task.wait(0.35)
	keybind_cooldown = false
end)

BlatantTab:AddSlider({
  Name = "KillAura Reach",
  Min = 0,
  Max = 50,
  Callback = function(Value)
    Settings["KillAura"]["Reach"] = Value
  end
})

BlatantTab:AddSlider({
  Name = "KillAura Cooldown (In Hundreth)",
  Min = 0,
  Value = 5,
  Max = 100,
  Callback = function(Value)
    Settings["KillAura"]["Cooldown"] = (Value / 100)
  end
})

BlatantTab:AddToggle({
	Name = "WallCheck",
	Callback = function(Value)
		Settings["KillAura"]["WallCheck"] = Value
	end
})

BlatantTab:AddSlider({
  Name = "KillAura Wall Check Angle",
  Min = 0,
  Value = 180,
  Max = 360,
  Callback = function(Value)
    Settings["KillAura"]["Angle"] = Value
  end
})

local function SwordHit()
    local sword = getSword()

    if sword then
        for _, p in pairs(plrs:GetPlayers()) do
			--if p:IsA("Humanoid") then continue end
			if p == lp then continue end
			
            if p and p.Character:FindFirstChild("HumanoidRootPart") then
                local pPos = p.Character.HumanoidRootPart.Position
                local lpPos = lp.Character.HumanoidRootPart.Position

				if Settings["KillAura"]["WallCheck"] == true then
					if checkBehindWalls() == false then
						continue
					end
				end
			          if dist(lpPos, pPos) <= Settings["KillAura"]["Reach"] then
                      local args = {
                              [1] = {
                                      ["entityInstance"] = p.Character,
                                      ["chargedAttack"] = {
                                      ["chargeRatio"] = 0
                                 },
              
                                ["validate"] = {
                                    ["targetPosition"] = {
                                        ["value"] = pPos
                                    },
                                    ["selfPosition"] = {
                                    ["value"] = lpPos
                                }
                            },

                            ["weapon"] = sword
                        }
                    }

					print(unpack(args))
                    net:FireServer(unpack(args))
                end
            end

			task.wait(0.0125)
        end
    end
end

pcall(function()
	task.spawn(function()
    	while task.wait(Settings["KillAura"]["Cooldown"]) do
        	if Settings["KillAura"]["Enabled"] == false then continue end
       		
			SwordHit()
       	 	task.wait(Settings["KillAura"]["Cooldown"])
    	end
	end)
end)
