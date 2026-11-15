--[[
  LICENSE PLATE GENERATOR | AutoFarm (loadstring-ready)
  Repo target: raw.githubusercontent.com/nobeggars/bp/refs/heads/main/plate_farm.lua
  Usage: loadstring(game:HttpGet('URL'))()
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

-- ============ CONFIG ============
local CFG = {
    AutoRoll = true,
    AutoSell = true,
    AutoUpgrade = true,
    RollDelay = 0.25,
    SellDelay = 2.0,
    UpgradeDelay = 12.0,
    Notify = true,
}

-- ============ REMOTES ============
-- Замени пути после прогона SimpleSpy. Если путь неверный — модуль просто отключится.
local Remotes = {}
local function tryGet(path)
    local ok, obj = pcall(function()
        local cur = ReplicatedStorage
        for _, p in ipairs(path) do
            cur = cur:WaitForChild(p, 5)
        end
        return cur
    end)
    return ok and obj or nil
end

Remotes.Roll      = tryGet({"Remotes", "Roll"})           -- <-- ПУТЬ 1
Remotes.Sell      = tryGet({"Remotes", "Sell"})           -- <-- ПУТЬ 2
Remotes.UpLucky   = tryGet({"Remotes", "UpgradeLucky"})   -- <-- ПУТЬ 3
Remotes.UpSpeed   = tryGet({"Remotes", "UpgradeSpeed"})   -- <-- ПУТЬ 4

-- ============ HELPERS ============
local function log(msg)
    if CFG.Notify then
        print("[gorilla] " .. msg)
    end
end

local function safeFire(remote, ...)
    if not remote then return false end
    local ok = pcall(function()
        remote:FireServer(...)
    end)
    return ok
end

-- ============ AUTO ROLL ============
task.spawn(function()
    while CFG.AutoRoll do
        if Remotes.Roll then
            safeFire(Remotes.Roll)
        end
        task.wait(CFG.RollDelay)
    end
end)

-- ============ AUTO SELL ============
task.spawn(function()
    while CFG.AutoSell do
        if Remotes.Sell then
            -- Если игра принимает аргумент "All" — оставь как есть.
            -- Если Sell принимает ID — раскомментируй вторую строку.
            safeFire(Remotes.Sell, "All")
            -- safeFire(Remotes.Sell, somePlateId)
        end
        task.wait(CFG.SellDelay)
    end
end)

-- ============ AUTO UPGRADE ============
task.spawn(function()
    while CFG.AutoUpgrade do
        safeFire(Remotes.UpLucky)
        task.wait(CFG.UpgradeDelay)
    end
end)

task.spawn(function()
    while CFG.AutoUpgrade do
        safeFire(Remotes.UpSpeed)
        task.wait(CFG.UpgradeDelay)
    end
end)

-- ============ ANTI-AFK ============
LP.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

log("loaded. Проверь Remotes через SimpleSpy.")
log("Roll="..tostring(Remotes.Roll ~= nil).." Sell="..tostring(Remotes.Sell ~= nil))
log("UpLucky="..tostring(Remotes.UpLucky ~= nil).." UpSpeed="..tostring(Remotes.UpSpeed ~= nil))
