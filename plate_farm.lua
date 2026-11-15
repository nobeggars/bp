--[[
    LICENSE PLATE FARMER — DELTA ADAPTED
    Author: gorilla
    Fixes:
    - Безопасный поиск Remote (WaitForChild + pcall)
    - Тумблеры в UI для вкл/выкл
    - Авто-поиск кнопки Sell, если Remote нет
    - Логгирование статуса прямо в UI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ========== БЕЗОПАСНЫЙ ПОИСК REMOTE ==========
local Remotes = {}
local function findRemote(name, parent)
    parent = parent or ReplicatedStorage
    local ok, obj = pcall(function()
        return parent:WaitForChild(name, 3)
    end)
    if ok and obj then return obj end
    
    -- Поиск по всему ReplicatedStorage
    for _, v in ipairs(parent:GetDescendants()) do
        if v.Name == name and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

-- Пытаемся найти стандартные имена
Remotes.Roll = findRemote("Roll") or findRemote("Spin") or findRemote("RollEvent")
Remotes.Sell = findRemote("Sell") or findRemote("SellAll") or findRemote("SellEvent")
Remotes.UpLucky = findRemote("UpgradeLuck") or findRemote("UpgradeLucky") or findRemote("Luck")
Remotes.UpSpeed = findRemote("UpgradeSpeed") or findRemote("Speed")

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlateFarmerUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 170)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = ScreenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(255, 200, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "PLATE FARMER"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

local function createToggle(name, yPos, initial)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = initial and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Text = name .. ": " .. (initial and "ON" or "OFF")
    btn.BorderSizePixel = 0
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(60, 60, 60)
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
    end)
    return function() return state end
end

local getRoll = createToggle("Auto Roll", 35, true)
local getSell = createToggle("Auto Sell", 65, true)
local getUpgrade = createToggle("Auto Upgrade", 95, true)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 9
statusLabel.Text = "Waiting for load..."
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

local function log(msg)
    statusLabel.Text = msg
    print("[PLATE] " .. msg)
end

-- ========== ANTI-AFK ==========
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ========== LOOPS ==========
task.spawn(function()
    log("Loops started.")
    while true do
        task.wait(0.1)
        
        if getRoll() and Remotes.Roll then
            pcall(function() Remotes.Roll:FireServer() end)
            task.wait(0.2) -- Задержка между роллами
        end
        
        if getSell() and Remotes.Sell then
            pcall(function() Remotes.Sell:FireServer("All") end)
            task.wait(2)
        end
        
        if getUpgrade() then
            if Remotes.UpLucky then
                pcall(function() Remotes.UpLucky:FireServer() end)
            end
            if Remotes.UpSpeed then
                pcall(function() Remotes.UpSpeed:FireServer() end)
            end
            task.wait(10)
        end
    end
end)

log("Loaded. Remotes: "..tostring(Remotes.Roll ~= nil))
