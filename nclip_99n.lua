--[[
    ANTI-TELEPORT BYPASS v1.0
    Author: I.S.-1
    Features:
    - Bypass server-side teleport check
    - 3 methods: CFrame hook, workspace hook, RemoteEvent hook
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ========== CONFIG ==========
local CAMP_POSITION = Vector3.new(0, 0, 0) -- ЗАМЕНИ НА КООРДИНАТЫ ЛАГЕРЯ!
local METHOD = 1 -- 1 = CFrame hook, 2 = workspace hook, 3 = RemoteEvent hook
local BYPASS_ENABLED = false

-- ========== GET HRP ==========
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- ========== METHOD 1: CFrame Hook ==========
local function enableMethod1()
    local hrp = getHRP()
    if not hrp then return end
    local oldCFrame = hrp.CFrame
    local fakePosition = CAMP_POSITION

    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    setreadonly(mt, false)

    mt.__index = newcclosure(function(self, key)
        if self == hrp and key == "Position" then
            return fakePosition
        end
        if self == hrp and key == "CFrame" then
            return CFrame.new(fakePosition)
        end
        return oldIndex(self, key)
    end)

    mt.__newindex = newcclosure(function(self, key, value)
        if self == hrp and key == "CFrame" then
            oldCFrame = value
            return oldNewIndex(self, key, value)
        end
        return oldNewIndex(self, key, value)
    end)

    setreadonly(mt, true)
    print("[ANTI-TP] Method 1 (CFrame hook) enabled")
end

-- ========== METHOD 2: Workspace Hook ==========
local function enableMethod2()
    local hrp = getHRP()
    if not hrp then return end
    local fakeHRP = Instance.new("Part")
    fakeHRP.Name = "HumanoidRootPart"
    fakeHRP.Size = Vector3.new(2, 2, 1)
    fakeHRP.Transparency = 1
    fakeHRP.CanCollide = false
    fakeHRP.Anchored = true
    fakeHRP.CFrame = CFrame.new(CAMP_POSITION)
    fakeHRP.Parent = workspace

    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)

    mt.__index = newcclosure(function(self, key)
        if self == workspace and key == "FindFirstChild" then
            return function(ws, name, recursive)
                if name == "HumanoidRootPart" then
                    return fakeHRP
                end
                return oldIndex(ws, key)(ws, name, recursive)
            end
        end
        return oldIndex(self, key)
    end)

    setreadonly(mt, true)
    print("[ANTI-TP] Method 2 (workspace hook) enabled")
end

-- ========== METHOD 3: RemoteEvent Hook ==========
local function enableMethod3()
    for _, remote in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local oldFire = remote.FireServer
            remote.FireServer = newcclosure(function(self, ...)
                local args = {...}
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = CAMP_POSITION
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(CAMP_POSITION)
                    end
                end
                return oldFire(self, unpack(args))
            end)
        end
    end
    print("[ANTI-TP] Method 3 (RemoteEvent hook) enabled")
end

-- ========== TOGGLE ==========
local function toggleBypass()
    BYPASS_ENABLED = not BYPASS_ENABLED
    if BYPASS_ENABLED then
        if METHOD == 1 then enableMethod1()
        elseif METHOD == 2 then enableMethod2()
        elseif METHOD == 3 then enableMethod3() end
        print("[ANTI-TP] Bypass ENABLED (method " .. METHOD .. ")")
    else
        print("[ANTI-TP] Bypass DISABLED. Rejoin to reset hooks.")
    end
end

-- ========== INPUT ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        toggleBypass()
    end
end)

print("[ANTI-TP] Loaded. Press B to toggle bypass.")
