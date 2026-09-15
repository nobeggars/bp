--[[
    FARM DIAMOND 99 NIGHTS — DELTA ADAPTED
    Original: Cáo Mod
    Adapted: I.S.-1
    Features:
    - Server hop if chest not found
    - TP to Stronghold Diamond Chest
    - Force interact via InputHoldBegin/End
    - Auto-collect diamonds via Remote
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- ========== БЕЗОПАСНЫЙ ДОСТУП К REMOTE ==========
local Remote
pcall(function()
    Remote = game:GetService("ReplicatedStorage").RemoteEvents.RequestTakeDiamonds
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
frame.Size = UDim2.new(0, 220, 0, 100)
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
title.Text = "★ FARM DIAMOND ★"
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
logText.Size = UDim2.new(1, -20, 0, 35)
logText.Position = UDim2.new(0, 10, 0, 60)
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

-- ========== ОБНОВЛЕНИЕ СЧЁТЧИКА ==========
task.spawn(function()
    while task.wait(0.5) do
        if DiamondCount then
            statusText.Text = "Diamonds: " .. DiamondCount.Text
        else
            statusText.Text = "Diamonds: N/A"
        end
    end
end)

-- ========== ХОП СЕРВЕРА ==========
local isHopping = false
local function hopServer()
    if isHopping then return end
    isHopping = true
    setStatus("Хопаю на другой сервер...")
    
    local gameId = game.PlaceId
    local success, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
    end)
    
    if success then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(body) end)
        if decodeOk and data and data.data then
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    setStatus("ТП на сервер: " .. string.sub(server.id, 1, 8))
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                    end)
                    return
                end
            end
        end
    end
    
    setStatus("Серверы не найдены, жду...")
    isHopping = false
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
    
    task.wait(3) -- ждём прогрузку карты
    
    -- Ищем сундук
    setStatus("Ищу Stronghold Diamond Chest...")
    local chest = nil
    local items = workspace:FindFirstChild("Items")
    if items then
        for _, obj in ipairs(items:GetDescendants()) do
            if string.find(string.lower(obj.Name), "stronghold") and string.find(string.lower(obj.name or obj.Name), "chest") then
                chest = obj
                break
            end
        end
        if not chest then
            chest = items:FindFirstChild("Stronghold Diamond Chest")
        end
    end
    
    if not chest then
        setStatus("Сундук не найден. Хопаю...")
        task.wait(1)
        hopServer()
        return
    end
    
    setStatus("Сундук найден! ТП...")
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
    
    -- Пытаемся открыть сундук 10 секунд
    setStatus("Открываю сундук...")
    local startTime = tick()
    while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 do
        forceInteract(proxPrompt)
        task.wait(0.3)
    end
    
    -- Если сундук не открылся
    if proxPrompt and proxPrompt.Parent then
        setStatus("Стронгхолд не открыт. Хопаю...")
        task.wait(1)
        hopServer()
        return
    end
    
    setStatus("Сундук открыт! Жду алмазы...")
    
    -- Ждём алмазы
    local diamondWait = tick()
    repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or (tick() - diamondWait) > 5
    
    -- Забираем алмазы
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
    
    setStatus("Забрано алмазов: " .. count)
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Farm Diamond",
            Text = "Забрано алмазов: " .. count,
            Duration = 3
        })
    end)
    
    task.wait(1)
    hopServer()
end)
