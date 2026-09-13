--[[
    NEON SCANNER v1.0 — SIMPLE + AUTO-SCAN
    Author: I.S.-1
    Features:
    - Fly (F)
    - Noclip (G)
    - ESP (H)
    - Anti-TP Simple (B)
    - Night Vision (N)
    - Auto-Scan Under Map (X) — ищет лагерь культистов
    - Stop Scan (Z)
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- ========== CLEANUP ==========
local uiName = "NeonScanner"
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

-- ========== CONFIG ==========
local CONFIG = {
    FLY_SPEED = 100,
    SCAN_SPEED = 200,
    SCAN_DEPTH = -500, -- глубина под картой
    SCAN_RANGE = 2000, -- радиус сканирования
    ESP_CHEST_COLOR = Color3.fromRGB(255, 200, 0),
    ESP_ALMAZ_COLOR = Color3.fromRGB(200, 0, 255),
    ESP_CULTIST_COLOR = Color3.fromRGB(255, 0, 0),
    ESP_BUILDING_COLOR = Color3.fromRGB(100, 150, 255),
    NIGHT_VISION_COLOR = Color3.fromRGB(0, 255, 200),
}

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local bypassEnabled = false
local nightVisionEnabled = false
local scanEnabled = false
local scanPosition = nil
local bypassConnection = nil
local originalLighting = {}

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 300)
Main.Position = UDim2.new(0.5, -130, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Transparency = 0.3

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "★ NEON SCANNER ★"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 12
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local function CreateButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    return btn
end

local FlyBtn = CreateButton("FLY: ВЫКЛ (F)", 45, Color3.fromRGB(0, 255, 200))
local NoclipBtn = CreateButton("NOCLIP: ВЫКЛ (G)", 80, Color3.fromRGB(255, 200, 0))
local EspBtn = CreateButton("ESP: ВЫКЛ (H)", 115, Color3.fromRGB(100, 150, 255))
local BypassBtn = CreateButton("ANTI-TP: ВЫКЛ (B)", 150, Color3.fromRGB(255, 0, 150))
local NightBtn = CreateButton("NIGHT VISION: ВЫКЛ (N)", 185, Color3.fromRGB(200, 150, 255))
local ScanBtn = CreateButton("AUTO-SCAN: ВЫКЛ (X)", 220, Color3.fromRGB(255, 0, 200))
local StopScanBtn = CreateButton("СТОП СКАН (Z)", 255, Color3.fromRGB(255, 100, 100))

-- ========== HELPERS ==========
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- ========== FLY ==========
local function setFly(state)
    flyEnabled = state
    FlyBtn.Text = "FLY: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (F)"
    local hrp = getHRP()
    if hrp then
        local humanoid = hrp.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = state end
    end
end

RunService.RenderStepped:Connect(function()
    if not flyEnabled or scanEnabled then return end
    local hrp = getHRP()
    if not hrp then return end
    local move = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then hrp.Velocity = move * CONFIG.FLY_SPEED else hrp.Velocity = Vector3.new(0, 0, 0) end
end)

-- ========== NOCLIP ==========
local function setNoclip(state)
    noclipEnabled = state
    NoclipBtn.Text = "NOCLIP: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (G)"
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = not state end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if noclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ========== ANTI-TP SIMPLE ==========
local function enableAntiTP()
    local hrp = getHRP()
    if not hrp then return end
    if bypassConnection then bypassConnection:Disconnect() end
    local savedPos = hrp.Position
    local savedCF = hrp.CFrame
    bypassConnection = RunService.Heartbeat:Connect(function()
        if not bypassEnabled then return end
        local h = getHRP()
        if not h then return end
        local dist = (h.Position - savedPos).Magnitude
        if dist > 100 then
            h.CFrame = savedCF
        else
            savedCF = h.CFrame
            savedPos = h.Position
        end
    end)
end

local function setBypass(state)
    bypassEnabled = state
    BypassBtn.Text = "ANTI-TP: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (B)"
    if state then enableAntiTP()
    elseif bypassConnection then bypassConnection:Disconnect() bypassConnection = nil end
end

-- ========== NIGHT VISION ==========
local function setNightVision(state)
    nightVisionEnabled = state
    NightBtn.Text = "NIGHT VISION: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (N)"
    if state then
        originalLighting = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            FogColor = Lighting.FogColor,
            GlobalShadows = Lighting.GlobalShadows,
        }
        Lighting.Ambient = CONFIG.NIGHT_VISION_COLOR
        Lighting.OutdoorAmbient = CONFIG.NIGHT_VISION_COLOR
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.FogColor = CONFIG.NIGHT_VISION_COLOR
        Lighting.GlobalShadows = false
        local hrp = getHRP()
        if hrp then
            local light = hrp:FindFirstChild("NeonLight") or Instance.new("PointLight")
            light.Name = "NeonLight"
            light.Brightness = 5
            light.Range = 100
            light.Color = CONFIG.NIGHT_VISION_COLOR
            light.Parent = hrp
        end
    else
        if originalLighting.Ambient then
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart
            Lighting.FogColor = originalLighting.FogColor
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end
        local hrp = getHRP()
        if hrp and hrp:FindFirstChild("NeonLight") then hrp.NeonLight:Destroy() end
    end
end

-- ========== ESP ==========
local espObjects = {}

local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
end

local function createESP(target, color, label, big)
    if not target then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 4, 4)
    box.Transparency = 0.5
    box.Color3 = color
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = target
    box.Parent = target
    table.insert(espObjects, box)

    if label then
        local billboard = Instance.new("BillboardGui")
        if big then
            billboard.Size = UDim2.new(0, 300, 0, 50)
        else
            billboard.Size = UDim2.new(0, 120, 0, 20)
        end
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.Adornee = target
        billboard.Parent = target
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = color
        text.Font = Enum.Font.GothamBlack
        text.TextSize = big and 24 or 10
        text.TextStrokeTransparency = 0
        text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        text.Parent = billboard
        table.insert(espObjects, billboard)
    end
end

local function updateESP()
    clearESP()
    if not espEnabled then return end

    -- ChestDEF (алмазный сундук)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "ChestDEF" and not obj:IsA("Bone") and not obj:IsDescendantOf(LocalPlayer.Character or game) then
            createESP(obj, CONFIG.ESP_ALMAZ_COLOR, "★ ALMAZ CHEST ★", true)
            local parent = obj.Parent
            while parent and parent ~= workspace do
                if parent:IsA("Model") then
                    createESP(parent, CONFIG.ESP_ALMAZ_COLOR, "★ CULTIST CAMP ★", true)
                    break
                end
                parent = parent.Parent
            end
        end
    end

    -- Items
    local items = workspace:FindFirstChild("Items")
    if items then
        for _, obj in ipairs(items:GetChildren()) do
            if obj.Name:lower():find("chest") then
                createESP(obj, CONFIG.ESP_CHEST_COLOR, obj.Name, false)
            end
        end
    end

    -- NPC
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, npc in ipairs(chars:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                local n = npc.Name:lower()
                if n:find("cultist") or n:find("cult") or n:find("bat") then
                    createESP(npc, CONFIG.ESP_CULTIST_COLOR, "CULTIST: " .. npc.Name, true)
                else
                    createESP(npc, CONFIG.ESP_CULTIST_COLOR, npc.Name, false)
                end
            end
        end
    end
end

local function setESP(state)
    espEnabled = state
    EspBtn.Text = "ESP: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (H)"
    if state then updateESP() else clearESP() end
end

-- ========== AUTO-SCAN UNDER MAP ==========
local function findCultistCamp()
    -- Ищем ChestDEF (алмазный сундук)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "ChestDEF" and not obj:IsA("Bone") and not obj:IsDescendantOf(LocalPlayer.Character or game) then
            return obj
        end
    end
    -- Ищем культистов
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, npc in ipairs(chars:GetChildren()) do
            if npc:IsA("Model") then
                local n = npc.Name:lower()
                if n:find("cultist") or n:find("cult") then
                    return npc
                end
            end
        end
    end
    return nil
end

local function autoScan()
    if scanEnabled then return end
    scanEnabled = true
    ScanBtn.Text = "AUTO-SCAN: ВКЛ (X)"
    
    local hrp = getHRP()
    if not hrp then
        scanEnabled = false
        return
    end
    
    -- Запоминаем начальную позицию
    local startPos = hrp.Position
    local scanY = CONFIG.SCAN_DEPTH
    
    -- Летим под карту
    hrp.CFrame = CFrame.new(startPos.X, scanY, startPos.Z)
    task.wait(0.5)
    
    print("[SCAN] Starting under-map scan...")
    
    -- Сканируем по спирали
    local step = 100
    local radius = 0
    local maxRadius = CONFIG.SCAN_RANGE
    local angle = 0
    
    while scanEnabled and radius < maxRadius do
        -- Вычисляем позицию
        local x = startPos.X + math.cos(math.rad(angle)) * radius
        local z = startPos.Z + math.sin(math.rad(angle)) * radius
        
        -- Телепортируемся под картой
        hrp.CFrame = CFrame.new(x, scanY, z)
        task.wait(0.2)
        
        -- Проверяем, есть ли лагерь культистов
        local camp = findCultistCamp()
        if camp then
            -- Нашли! Останавливаемся
            scanEnabled = false
            ScanBtn.Text = "AUTO-SCAN: НАЙДЕНО!"
            print("[SCAN] Cultist camp found: " .. camp:GetFullName())
            
            -- Телепортируемся к нему
            local pos
            if camp:IsA("Model") then
                pos = camp.PrimaryPart and camp.PrimaryPart.Position or camp:GetPivot().Position
            else
                pos = camp.Position
            end
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            return
        end
        
        -- Увеличиваем радиус и угол
        angle = angle + 15
        if angle >= 360 then
            angle = 0
            radius = radius + step
            print("[SCAN] Radius: " .. radius)
        end
    end
    
    scanEnabled = false
    ScanBtn.Text = "AUTO-SCAN: НЕ НАЙДЕНО"
    print("[SCAN] Scan finished. Camp not found.")
    
    -- Возвращаемся на старт
    hrp.CFrame = CFrame.new(startPos)
end

local function stopScan()
    scanEnabled = false
    ScanBtn.Text = "AUTO-SCAN: ВЫКЛ (X)"
    print("[SCAN] Stopped by user.")
end

-- ========== INPUT ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then setFly(not flyEnabled)
    elseif input.KeyCode == Enum.KeyCode.G then setNoclip(not noclipEnabled)
    elseif input.KeyCode == Enum.KeyCode.H then setESP(not espEnabled)
    elseif input.KeyCode == Enum.KeyCode.B then setBypass(not bypassEnabled)
    elseif input.KeyCode == Enum.KeyCode.N then setNightVision(not nightVisionEnabled)
    elseif input.KeyCode == Enum.KeyCode.X then autoScan()
    elseif input.KeyCode == Enum.KeyCode.Z then stopScan()
    end
end)

-- ========== BUTTON HANDLERS ==========
FlyBtn.MouseButton1Click:Connect(function() setFly(not flyEnabled) end)
NoclipBtn.MouseButton1Click:Connect(function() setNoclip(not noclipEnabled) end)
EspBtn.MouseButton1Click:Connect(function() setESP(not espEnabled) end)
BypassBtn.MouseButton1Click:Connect(function() setBypass(not bypassEnabled) end)
NightBtn.MouseButton1Click:Connect(function() setNightVision(not nightVisionEnabled) end)
ScanBtn.MouseButton1Click:Connect(function() autoScan() end)
StopScanBtn.MouseButton1Click:Connect(function() stopScan() end)

-- ========== AUTO-UPDATE ESP ==========
task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then updateESP() end
    end
end)

-- ========== APPEAR ==========
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, -130, 0.15, 30)
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -130, 0.15, 0)
}):Play()

print("[NEON] SCANNER loaded. Keys: F=fly, G=noclip, H=esp, B=anti-tp, N=night, X=auto-scan, Z=stop")
