-- LICENSE PLATE GENERATOR | AutoFarm Skeleton
-- Executor: Delta / Xeno / Solara / Wave
-- Assumption: game uses RemoteEvents in ReplicatedStorage

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

-- CONFIG
local AUTO_ROLL = true
local AUTO_SELL = true
local AUTO_UPGRADE = true
local ROLL_DELAY = 0.3
local SELL_DELAY = 2
local UPGRADE_DELAY = 10

-- PLACEHOLDER REMOTES — замени на реальные пути из SimpleSpy
-- Пример: ReplicatedStorage.Remotes.RollEvent
local Remotes = {
    Roll = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Roll"),           -- подставить
    Sell = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sell"),           -- подставить
    UpgradeLucky = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeLucky"), -- подставить
    UpgradeSpeed = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeSpeed"), -- подставить
}

-- AUTO ROLL
task.spawn(function()
    while AUTO_ROLL do
        pcall(function()
            Remotes.Roll:FireServer()
        end)
        task.wait(ROLL_DELAY)
    end
end)

-- AUTO SELL (продаёт всё что ниже Epic)
-- Если в игре есть кнопка "Sell All" — шлём её
task.spawn(function()
    while AUTO_SELL do
        pcall(function()
            -- Вариант A: прямой Sell конкретного номера (нужен аргумент)
            -- Remotes.Sell:FireServer(plateId)
            
            -- Вариант B: если есть SellAll
            Remotes.Sell:FireServer("All")
        end)
        task.wait(SELL_DELAY)
    end
end)

-- AUTO UPGRADE
task.spawn(function()
    while AUTO_UPGRADE do
        pcall(function()
            Remotes.UpgradeLucky:FireServer()
        end)
        task.wait(UPGRADE_DELAY)
    end
end)

task.spawn(function()
    while AUTO_UPGRADE do
        pcall(function()
            Remotes.UpgradeSpeed:FireServer()
        end)
        task.wait(UPGRADE_DELAY)
    end
end)

-- ANTI-AFK
local VirtualUser = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("[gorilla] AutoFarm loaded. Замени пути Remotes на реальные.")
print("[gorilla] Используй SimpleSpy: log remotes, нажми кнопку в игре, скопируй путь.")
