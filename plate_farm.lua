-- LICENSE PLATE FARMER — NO OBFUSCATION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlateFarmGui"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 220, 0, 150)
main.Position = UDim2.new(0, 20, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = ScreenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 255, 200)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "PLATE FARMER"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

-- Тумблеры
local function makeToggle(txt, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 25)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.Text = txt .. ": OFF"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
        b.Text = txt .. ": " .. (state and "ON" or "OFF")
    end)
    return function() return state end
end

local getRoll = makeToggle("Auto Roll", 35)
local getSell = makeToggle("Auto Sell", 65)
local getUpg = makeToggle("Auto Upgrade", 95)

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, -20, 0, 20)
lbl.Position = UDim2.new(0, 10, 0, 125)
lbl.BackgroundTransparency = 1
lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
lbl.Font = Enum.Font.Code
lbl.TextSize = 9
lbl.Text = "Ready."
lbl.Parent = main

-- ========== SEARCH REMOTES ==========
local function findRemote(name)
    local ok, obj = pcall(function() return ReplicatedStorage:FindFirstChild(name, true) end)
    if ok and obj and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then return obj end
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == name and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then return v end
    end
    return nil
end

local Roll = findRemote("Roll") or findRemote("Spin") or findRemote("RollEvent")
local Sell = findRemote("Sell") or findRemote("SellAll") or findRemote("SellEvent")
local Upg  = findRemote("Upgrade") or findRemote("UpgradeLuck") or findRemote("Luck")

-- ========== LOOPS ==========
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if getRoll() and Roll then pcall(function() Roll:FireServer() end) task.wait(0.15) end
        if getSell() and Sell then pcall(function() Sell:FireServer("All") end) task.wait(2) end
        if getUpg() and Upg then pcall(function() Upg:FireServer() end) task.wait(10) end
    end
end)

lbl.Text = "Loaded. Roll:"..tostring(Roll~=nil).." Sell:"..tostring(Sell~=nil).." Upg:"..tostring(Upg~=nil)
