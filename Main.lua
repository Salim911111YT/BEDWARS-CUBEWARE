local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/magbux/BorealisUiLib/refs/heads/main/Library.Lua"))()
local Window = Library.new("CubeWare (HAPPY BIRTHDAY OWNER!!!)")

local BlatantTab = Window:MakeTab("BLATANT")

local Settings = {
  ["KillAura"] = {
    ["Enabled"] = false,
    ["KillAuraReach"] = 14 
  }
}

local plrs = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local lp = plrs.LocalPlayer
local net = rs.rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.SwordHit
local inv = rs.Inventories:FindFirstChild(lp.Name)
local range = 16

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

BlatantTab:AddToggle({
  Name = "KillAura",
  Callback = function(Value)
      Settings["KillAura"]["Enabled"] = Value
  end
})

BlatantTab:AddSlider({
  Name = "KillAura Reach",
  Min = 0,
  Max = 16,
  Callback = function(Value)
    Settings["KillAura"]["KillAuraReach"] = Value
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
            
			          if dist(lpPos, pPos) <= Settings["KillAura"]["KillAuraReach"] then
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
