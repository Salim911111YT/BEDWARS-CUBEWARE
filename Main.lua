local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/magbux/BorealisUiLib/refs/heads/main/Library.Lua"))()
local Window = Library.new("CubeWare (BEDWARS EDITION) (HAPPY BIRTHDAY OWNER!!!) (V1.0.0)")

local BlatantTab = Window:MakeTab("BLATANT")

local Settings = {
  ["KillAura"] = {
    ["Enabled"] = false,
    ["Reach"] = 0,
	["WallCheck"] = false;
	["Angle"] = 180
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
	(plr.Character.PrimaryPart.CFrame.LookVector.Unit * Settings["KillAura"]["Angle"]))

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

BlatantTab:AddToggle({
  Name = "KillAura",
  Callback = function(Value)
      Settings["KillAura"]["Enabled"] = Value
  end
})

BlatantTab:AddSlider({
  Name = "KillAura Reach",
  Min = 0,
  Max = 50,
  Callback = function(Value)
    Settings["KillAura"]["Reach"] = Value
  end
})

BlatantTab:AddToggle({
	Name = "WallCheck",
	Callback = function(Value)
		Settings["KillAura"]["WallCheck"] = Value
	end
})

BlatantTab:AddSlider({
  Name = "KillAura Attack Angle",
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
        for _, p in pairs(workspace:GetDescendants()) do
			if p:IsA("Humanoid") then continue end

            if p.Parent ~= lp and p.Parent and p.Parent:FindFirstChild("HumanoidRootPart") then
                local pPos = p.Parent.HumanoidRootPart.Position
                local lpPos = lp.Character.HumanoidRootPart.Position

				if Settings["KillAura"]["WallCheck"] == true then
					if checkBehindWalls() == false then
						continue
					end
				end
			          if dist(lpPos, pPos) <= Settings["KillAura"]["Reach"] then
                      local args = {
                              [1] = {
                                      ["entityInstance"] = p.Parent,
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

                    net:FireServer(unpack(args))
                end
            end
        end
    end
end

pcall(function()
	task.spawn(function()
    	while task.wait(0.15) do
        	if Settings["KillAura"]["Enabled"] == false then continue end
       		
			SwordHit()
       	 	task.wait(0.15)
    	end
	end)
end)
