--[[
    TEST SCRIPT — ПРОВЕРКА РАБОТЫ LOADSTRING
    Author: I.S.-1
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Создаём окно с результатом
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TestResult"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.5, -150, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = ScreenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.Text = "★ ТЕСТ LOADSTRING ★"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BorderSizePixel = 0
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local resultText = Instance.new("TextLabel")
resultText.Size = UDim2.new(1, -20, 1, -60)
resultText.Position = UDim2.new(0, 10, 0, 45)
resultText.BackgroundTransparency = 1
resultText.Text = "✅ СКРИПТ ЗАГРУЖЕН!\n\nloadstring работает.\n\nИнжектор: " .. tostring(identifyexecutor and identifyexecutor() or "неизвестно") .. "\n\nВремя: " .. os.date("%X")
resultText.TextColor3 = Color3.fromRGB(0, 255, 100)
resultText.Font = Enum.Font.Code
resultText.TextSize = 12
resultText.TextWrapped = true
resultText.TextXAlignment = Enum.TextXAlignment.Left
resultText.TextYAlignment = Enum.TextYAlignment.Top
resultText.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, -20, 0, 35)
closeBtn.Position = UDim2.new(0, 10, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
closeBtn.Text = "ЗАКРЫТЬ"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Уведомление
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Тест",
        Text = "loadstring работает!",
        Duration = 5
    })
end)

print("[TEST] Скрипт загружен успешно!")
print("[TEST] Инжектор: " .. tostring(identifyexecutor and identifyexecutor() or "неизвестно"))
