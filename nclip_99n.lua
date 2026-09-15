--[[
    FARM DIAMOND 99 NIGHTS — DELTA ADAPTED v2
    Author: I.S.-1
    Fixes:
    - Правильный поиск сундука (Stronghold Diamond Chest)
    - Рабочий хоп через TeleportService:Teleport с TeleportData
    - Автоматический старт после загрузки в игру
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== БЕЗОПАСНЫЙ ДОСТУП К REMOTE ==========
local Remote
pcall(function()
    Remote = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
    if Remote then
        Remote = Remote:WaitForChild("RequestTakeDiamonds", 5)
    end
end)

-- ========== ИНТЕРФЕЙС ==========
local DiamondCount
pcall(function()
    local interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface", 5)
    if interface then
        local dc = interface:FindFirstChild("DiamondCount")
        if dc then
            DiamondCount = dc:FindFirstChild("Count")
        end
    end
end)

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FarmDiamondUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 110)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = ScreenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(0, 255, 200)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "★ FARM DIAMOND v2 ★"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 0, 25)
statusText.Position = UDim2.new(0, 10, 0, 32)
statusText.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 11
statusText.Text = "Diamonds: ..."
statusText.BorderSizePixel = 0
statusText.Parent = frame
Instance.new("UICorner", statusText).CornerRadius = UDim.new(0, 5)

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -20, 0, 40)
logText.Position = UDim2.new(0, 10, 0, 62)
logText.BackgroundTransparency = 1
logText.TextColor3 = Color3.fromRGB(150, 170, 160)
logText.Font = Enum.Font.Code
logText.TextSize = 9
logText.Text = "Статус: загрузка..."
logText.TextWrapped = true
logText.Parent = frame

local function setStatus(msg)
    logText.Text = "Статус: " .. msg
    print("[FARM] " .. msg)
end

task.spawn(function()
    while task.wait(0.5) do
        if DiamondCount then
            statusText.Text = "Diamonds: " .. DiamondCount.Text
        else
            statusText.Text = "Diamonds: N/A"
        end
    end
end)

-- ========== ПОИСК СУНДУКА (РАСШИРЕННЫЙ) ==========
local function findChest()
    -- 1. Прямой поиск по имени
    local items = workspace:FindFirstChild("Items")
    if items then
        local chest = items:FindFirstChild("Stronghold Diamond Chest")
        if chest then return chest end
        
        -- 2. Поиск по частичному совпадению
        for _, obj in ipairs(items:GetDescendants()) do
            local n = string.lower(obj.Name)
            if string.find(n, "stronghold") and string.find(n, "chest") then
                return obj
            end
            if string.find(n, "diamond") and string.find(n, "chest") then
                return obj
            end
        end
    end
    
    -- 3. Поиск по всему workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = string.lower(obj.Name)
        if string.find(n, "stronghold") and string.find(n, "chest") then
            return obj
        end
    end
    
    return nil
end

-- ========== ХОП СЕРВЕРА (ИСПРАВЛЕННЫЙ) ==========
local isHopping = false
local function hopServer()
    if isHopping then return end
    isHopping = true
    setStatus("Ищу сервер...")
    
    local gameId = game.PlaceId
    local success, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
    end)
    
    if success then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(body) end)
        if decodeOk and data and data.data then
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    setStatus("Хоп на: " .. string.sub(server.id, 1, 8))
                    
                    -- Пробуем разные методы ТП
                    local tpSuccess = pcall(function()
                        TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                    end)
                    
                    if not tpSuccess then
                        pcall(function()
                            local options = Instance.new("TeleportOptions")
                            options.ServerInstanceId = server.id
                            TeleportService:TeleportAsync(gameId, {LocalPlayer}, options)
                        end)
                    end
                    return
                end
            end
        end
    end
    
    setStatus("Серверы не найдены. Жду 5 сек...")
    task.wait(5)
    isHopping = false
    hopServer() -- повторяем
end

-- ========== FORCE INTERACT ==========
local function forceInteract(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    local success = false
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(prompt.HoldDuration, 0.05) + 0.05)
        prompt:InputHoldEnd()
        success = true
    end)
    return success
end

-- ========== ОСНОВНАЯ ЛОГИКА ==========
task.spawn(function()
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    setStatus("Жду прогрузку карты (5 сек)...")
    task.wait(5)
    
    -- Ищем сундук
    setStatus("Ищу сундук...")
    local chest = findChest()
    
    if not chest then
        setStatus("Сундук не найден. Хопаю...")
        task.wait(1)
        hopServer()
        return
    end
    
    setStatus("Сундук найден: " .. chest.Name)
    
    -- ТП к сундуку
    pcall(function()
        LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 3, 0)))
    end)
    task.wait(0.5)
    
    -- Ищем ProximityPrompt
    setStatus("Ищу Prompt...")
    local proxPrompt
    local startWait = tick()
    repeat
        task.wait(0.1)
        local main = chest:FindFirstChild("Main")
        if main then
            local attach = main:FindFirstChild("ProximityAttachment")
            if attach then
                proxPrompt = attach:FindFirstChild("ProximityInteraction")
            end
        end
        if not proxPrompt then
            proxPrompt = chest:FindFirstChildOfClass("ProximityPrompt", true)
        end
    until proxPrompt or (tick() - startWait) > 5
    
    if not proxPrompt then
        setStatus("Prompt не найден. Хопаю...")
        task.wait(1)
        hopServer()
        return
    end
    
    -- Пытаемся открыть
    setStatus("Открываю сундук...")
    local startTime = tick()
    while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 do
        forceInteract(proxPrompt)
        task.wait(0.3)
    end
    
    if proxPrompt and proxPrompt.Parent then
        setStatus("Стронгхолд не открыт. Хопаю...")
        task.wait(1)
        hopServer()
        return
    end
    
    -- Ждём алмазы
    setStatus("Жду алмазы...")
    local diamondWait = tick()
    repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or (tick() - diamondWait) > 5
    
    -- Забираем
    setStatus("Забираю алмазы...")
    local count = 0
    if Remote then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.ClassName == "Model" and v.Name == "Diamond" then
                pcall(function()
                    Remote:FireServer(v)
                    count = count + 1
                end)
            end
        end
    end
    
    setStatus("Забрано: " .. count)
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Farm Diamond",
            Text = "Забрано: " .. count,
            Duration = 3
        })
    end)
    
    task.wait(1)
    hopServer()
end)
