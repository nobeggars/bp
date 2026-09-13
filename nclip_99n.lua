--[[
    GHOSTWARE v3.8 — SMOOTH SCAN + SMART ESP
    Author: I.S.-1 + Gemini Fix
    Features:
    - Fly (F)
    - Noclip (G)
    - ESP (H) — Diamond Chest: cyan, Stronghold: pink
    - Anti-TP (B)
    - Night Vision (N)
    - Smooth Grid Scan (X) — Tween вместо ТП
    - Stop Scan (Z)
    - TP to Found (Y)
    - Debug (J)
    - Scan Remotes (R)
    - Block Remote (K)
    - Force Open (O)
    - Copy Logs (C)
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local uiName = "GhostWare_v3"

-- ========== НАСТРОЙКИ СКАНА ==========
local SCAN = {
    Y = -50,
    STEP = 200,
    RANGE = 2000,
    WAIT = 0.2,
    TWEEN_TIME = 0.15,  -- время плавного перелёта
    STREAM_WAIT = 0.15,
}

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local bypassEnabled = false
local nightVisionEnabled = false
local scanEnabled = false
local foundObject = nil
local bypassConnection = nil
local savedPos = nil
local savedCF = nil
local highlightObjects = {}
local fullLog = ""
local originalLighting = {}
local espConnections = {}
local remoteBlockEnabled = false

-- ========== CLEANUP ==========
pcall(function()
    if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
end)
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false

local parentSet = false
pcall(function()
    if gethui then ScreenGui.Parent = gethui() parentSet = true end
end)
if not parentSet then
    pcall(function() ScreenGui.Parent = CoreGui parentSet = true end)
end
if not parentSet then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== UI ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 500)
Main.Position = UDim2.new(0.5, -210, 0.08, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(30, 45, 40)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Text = "GhostWare v3.8\nSmooth Scan"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 1, -80)
LogFrame.Position = UDim2.new(0, 10, 0, 70)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 12)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 1
LogFrame.Parent = Sidebar
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 6)

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -5, 1, 0)
LogText.Position = UDim2.new(0, 2, 0, 0)
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(150, 170, 160)
LogText.Font = Enum.Font.Code
LogText.TextSize = 8
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.RichText = true
LogText.Text = "> v3.8 загружен.\n"
LogText.Parent = LogFrame

local function AddLog(msg, isErr)
    local color = isErr and '<font color="rgb(255,80,80)">' or '<font color="rgb(0,200,120)">'
    local line = string.format("%s[%s] %s</font>\n", color, os.date("%X"), msg)
    LogText.Text = line .. LogText.Text
    fullLog = fullLog .. line .. "\n"
end

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -20)
Content.Position = UDim2.new(0, 150, 0, 10)
Content.BackgroundTransparency = 1
Content.Parent = Main

local UIListLayout = Instance.new("UIListLayout", Content)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function CreateToggle(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(12, 14, 15)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = "    " .. text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Content
    
    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 4, 0, 14)
    Ind.Position = UDim2.new(0, 0, 0.5, -7)
    Ind.BackgroundColor3 = Color3.fromRGB(40, 45, 45)
    Ind.BorderSizePixel = 0
    Ind.Parent = btn
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 22, 25)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(12, 14, 15)}):Play() end)
    
    return btn, Ind
end

local FlyBtn, FlyInd = CreateToggle("1. FLY & NOCLIP")
local EspBtn, EspInd = CreateToggle("2. ESP (H)")
local AntiTpBtn, AntiTpInd = CreateToggle("3. ANTI-TP (B)")
local NightBtn, NightInd = CreateToggle("4. NIGHT VISION (N)")
local ScanBtn, ScanInd = CreateToggle("5. SMOOTH GRID SCAN (X)")
local TpBtn, TpInd = CreateToggle("6. TP К НАЙДЕННОМУ (Y)")
local StopBtn, StopInd = CreateToggle("7. СТОП СКАН (Z)")
local DebugBtn, DebugInd = CreateToggle("8. ПОКАЗАТЬ ВСЁ (J)")
local LogBtn, LogInd = CreateToggle("9. КОПИРОВАТЬ ЛОГ (C)")
local RemoteScanBtn, RemoteScanInd = CreateToggle("10. СКАН REMOTES (R)")
local BlockRemoteBtn, BlockRemoteInd = CreateToggle("11. БЛОК ТП-REMOTE (K)")
local ForceChestBtn, ForceChestInd = CreateToggle("12. ОТКРЫТЬ СУНДУК (O)")

local function getHRP()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- ========== 1. FLY & NOCLIP ==========
FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    noclipEnabled = flyEnabled
    
    if flyEnabled then
        TweenService:Create(FlyInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Fly & Noclip ВКЛ")
        local hrp = getHRP()
        if hrp then
            local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end
        end
    else
        TweenService:Create(FlyInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Fly & Noclip ВЫКЛ")
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not flyEnabled or scanEnabled then return end
    local hrp = getHRP()
    if not hrp then return end
    
    local move = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and move.Magnitude == 0 then
        local md = hum.MoveDirection
        if md.Magnitude > 0 then
            move = (Camera.CFrame.LookVector * (md.Z * -1)) + (Camera.CFrame.RightVector * md.X)
        end
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    
    if move.Magnitude > 0 then hrp.Velocity = move.Unit * 100
    else hrp.Velocity = Vector3.new(0, 0, 0) end
end)

-- ========== 2. ESP (SMART) ==========
local function clearESP()
    for _, hl in ipairs(highlightObjects) do
        if hl and hl.Parent then hl:Destroy() end
    end
    highlightObjects = {}
end

local function createESP(target, color, label, big)
    if not target then return end
    
    local adornee = target
    if target:IsA("Model") then
        adornee = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    end
    if not adornee then return end
    
    local success = pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "GhostWareESP"
        hl.Adornee = target
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        pcall(function()
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end)
        hl.Parent = target
        table.insert(highlightObjects, hl)
    end)
    
    if not success then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = target:IsA("Model") and target:GetExtentsSize() or target.Size
        box.Transparency = 0.4
        box.Color3 = color
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Adornee = adornee
        box.Parent = adornee
        table.insert(highlightObjects, box)
    end
    
    if label then
        pcall(function()
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 250, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = math.huge
            billboard.StudsOffset = Vector3.new(0, 10, 0)
            billboard.Adornee = adornee
            billboard.Parent = adornee
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = label
            text.TextColor3 = color
            text.Font = Enum.Font.GothamBlack
            text.TextSize = big and 18 or 12
            text.TextStrokeTransparency = 0
            text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            text.Parent = billboard
            table.insert(highlightObjects, billboard)
        end)
    end
end

-- УМНАЯ ПРОВЕРКА DIAMOND CHEST
local function isDiamondChest(obj)
    if not obj or not obj.Name then return false end
    local name = string.lower(obj.Name)
    
    -- 1. Прямое совпадение
    if string.find(name, "diamond") and string.find(name, "chest") then
        return true
    end
    
    -- 2. Chest внутри Stronghold
    if name == "chest" and obj.Parent then
        local pName = string.lower(obj.Parent.Name)
        if string.find(pName, "stronghold") or string.find(pName, "cultist") then
            return true
        end
        local gp = obj.Parent.Parent
        if gp and gp.Name then
            local gpn = string.lower(gp.Name)
            if string.find(gpn, "stronghold") or string.find(gpn, "cultist") then
                return true
            end
        end
    end
    
    return false
end

local function isStronghold(obj)
    if not obj or not obj.Name then return false end
    local name = string.lower(obj.Name)
    if string.find(name, "stronghold") or string.find(name, "cultist") then
        return true
    end
    return false
end

local function isNormalChest(obj)
    if not obj or not obj.Name then return false end
    local name = string.lower(obj.Name)
    if string.find(name, "chest") and not isDiamondChest(obj) then
        return true
    end
    return false
end

local function updateESP()
    clearESP()
    if not espEnabled then return end
    
    local count = 0
    local diamondCount = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isDiamondChest(obj) then
            if not obj:IsA("Bone") then
                createESP(obj, Color3.fromRGB(0, 240, 255), "💎 DIAMOND CHEST 💎", true)
                count = count + 1
                diamondCount = diamondCount + 1
            end
        elseif isStronghold(obj) then
            if not obj:IsA("Bone") then
                createESP(obj, Color3.fromRGB(255, 0, 255), "🏰 STRONGHOLD 🏰", true)
                count = count + 1
            end
        elseif isNormalChest(obj) then
            if not obj:IsA("Bone") then
                createESP(obj, Color3.fromRGB(255, 200, 0), "Chest", false)
                count = count + 1
            end
        end
    end
    
    AddLog("ESP: " .. count .. " (Diamond: " .. diamondCount .. ")")
end

EspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("ESP ВКЛ")
        updateESP()
        
        local conn = workspace.DescendantAdded:Connect(function(obj)
            if not espEnabled then return end
            if isDiamondChest(obj) then
                AddLog("★ DIAMOND CHEST: " .. obj:GetFullName())
                createESP(obj, Color3.fromRGB(0, 240, 255), "💎 DIAMOND CHEST 💎", true)
            elseif isStronghold(obj) then
                AddLog("★ STRONGHOLD: " .. obj:GetFullName())
                createESP(obj, Color3.fromRGB(255, 0, 255), "🏰 STRONGHOLD 🏰", true)
            end
        end)
        table.insert(espConnections, conn)
    else
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("ESP ВЫКЛ")
        clearESP()
        for _, conn in ipairs(espConnections) do
            if conn then conn:Disconnect() end
        end
        espConnections = {}
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if espEnabled then updateESP() end
    end
end)

-- ========== 3. ANTI-TP ==========
local function enableAntiTP()
    local hrp = getHRP()
    if not hrp then return end
    if bypassConnection then bypassConnection:Disconnect() end
    
    savedPos = hrp.Position
    savedCF = hrp.CFrame
    
    bypassConnection = RunService.Heartbeat:Connect(function()
        if not bypassEnabled then return end
        if scanEnabled then return end
        
        local h = getHRP()
        if not h then return end
        
        local dist = (h.Position - savedPos).Magnitude
        if dist > 150 then
            h.CFrame = savedCF
        else
            savedCF = h.CFrame
            savedPos = h.Position
        end
    end)
end

AntiTpBtn.MouseButton1Click:Connect(function()
    bypassEnabled = not bypassEnabled
    if bypassEnabled then
        TweenService:Create(AntiTpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Anti-TP ВКЛ")
        enableAntiTP()
    else
        TweenService:Create(AntiTpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Anti-TP ВЫКЛ")
        if bypassConnection then bypassConnection:Disconnect() bypassConnection = nil end
    end
end)

-- ========== 4. NIGHT VISION ==========
NightBtn.MouseButton1Click:Connect(function()
    nightVisionEnabled = not nightVisionEnabled
    NightBtn.Text = "    NIGHT VISION: " .. (nightVisionEnabled and "ВКЛ" or "ВЫКЛ") .. " (N)"
    
    if nightVisionEnabled then
        TweenService:Create(NightInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
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
        Lighting.Ambient = Color3.fromRGB(100, 255, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 255, 200)
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.FogColor = Color3.fromRGB(200, 200, 200)
        Lighting.GlobalShadows = false
        
        local hrp = getHRP()
        if hrp then
            local light = hrp:FindFirstChild("GhostLight") or Instance.new("PointLight")
            light.Name = "GhostLight"
            light.Brightness = 5
            light.Range = 100
            light.Color = Color3.fromRGB(0, 255, 200)
            light.Parent = hrp
        end
        AddLog("Night Vision ВКЛ")
    else
        TweenService:Create(NightInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
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
        if hrp and hrp:FindFirstChild("GhostLight") then hrp.GhostLight:Destroy() end
        AddLog("Night Vision ВЫКЛ")
    end
end)

-- ========== 5. SMOOTH GRID SCAN (TWEEN ВМЕСТО ТП) ==========
local function findTarget()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isDiamondChest(obj) and not obj:IsA("Bone") then
            if not obj:IsDescendantOf(LocalPlayer.Character or game) then
                return obj
            end
        end
    end
    return nil
end

ScanBtn.MouseButton1Click:Connect(function()
    if scanEnabled then
        scanEnabled = false
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Скан остановлен.")
        return
    end
    
    local hrp = getHRP()
    if not hrp then return end
    
    scanEnabled = true
    TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 150)}):Play()
    AddLog("=== SMOOTH GRID SCAN (TWEEN) ===")
    
    task.spawn(function()
        local startPos = hrp.Position
        local totalPoints = 0
        local found = false
        
        for x = -SCAN.RANGE, SCAN.RANGE, SCAN.STEP do
            if not scanEnabled then break end
            for z = -SCAN.RANGE, SCAN.RANGE, SCAN.STEP do
                if not scanEnabled then break end
                
                local targetPosition = Vector3.new(startPos.X + x, SCAN.Y, startPos.Z + z)
                
                -- ПЛАВНЫЙ ПЕРЕЛЁТ ЧЕРЕЗ TWEEN
                local tweenInfo = TweenInfo.new(SCAN.TWEEN_TIME, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
                tween:Play()
                tween.Completed:Wait() -- ждём, пока долетит
                
                totalPoints = totalPoints + 1
                
                -- ПРИНУДИТЕЛЬНЫЙ ЗАПРОС СТРИМИНГА
                pcall(function()
                    LocalPlayer:RequestStreamAroundAsync(targetPosition)
                end)
                
                if totalPoints % 10 == 0 then
                    AddLog(string.format("Точка %d: X=%.0f Z=%.0f", totalPoints, targetPosition.X, targetPosition.Z))
                end
                
                task.wait(SCAN.STREAM_WAIT)
                
                local target = findTarget()
                if target then
                    found = true
                    foundObject = target
                    
                    local targetPos
                    if target:IsA("Model") then
                        targetPos = target.PrimaryPart and target.PrimaryPart.Position or target:GetPivot().Position
                    else
                        targetPos = target.Position
                    end
                    
                    AddLog("★ DIAMOND CHEST НАЙДЕН: " .. target:GetFullName())
                    AddLog(string.format("Позиция: X=%.0f Y=%.0f Z=%.0f", targetPos.X, targetPos.Y, targetPos.Z))
                    
                    -- Плавно подлетаем к сундуку
                    local finalTween = TweenService:Create(hrp, TweenInfo.new(0.3), {CFrame = CFrame.new(targetPos.X, SCAN.Y, targetPos.Z)})
                    finalTween:Play()
                    finalTween.Completed:Wait()
                    
                    scanEnabled = false
                    AddLog("Скан завершён! Включи ESP (H).")
                    break
                end
                
                task.wait(SCAN.WAIT)
            end
            if found then break end
        end
        
        if not found then
            AddLog("Diamond Chest не найден в радиусе " .. SCAN.RANGE, true)
        end
        
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
    end)
end)

-- ========== 6. TP К НАЙДЕННОМУ ==========
TpBtn.MouseButton1Click:Connect(function()
    if not foundObject then
        AddLog("Сначала найди объект (X)", true)
        return
    end
    
    local hrp = getHRP()
    if not hrp then return end
    
    local pos
    if foundObject:IsA("Model") then
        pos = foundObject.PrimaryPart and foundObject.PrimaryPart.Position or foundObject:GetPivot().Position
    else
        pos = foundObject.Position
    end
    
    savedCF = CFrame.new(pos + Vector3.new(0, 5, 0))
    savedPos = savedCF.Position
    hrp.CFrame = savedCF
    
    TweenService:Create(TpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
    AddLog("ТП к найденному!")
    task.wait(1)
    TweenService:Create(TpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== 7. СТОП СКАН ==========
StopBtn.MouseButton1Click:Connect(function()
    scanEnabled = false
    AddLog("Скан остановлен.")
end)

-- ========== 8. DEBUG ==========
DebugBtn.MouseButton1Click:Connect(function()
    AddLog("=== ПОИСК DIAMOND CHEST ===")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isDiamondChest(obj) and not obj:IsA("Bone") then
            count = count + 1
            AddLog(obj:GetFullName() .. " | " .. obj.ClassName)
        end
    end
    AddLog("Всего Diamond Chest: " .. count)
    if count == 0 then
        AddLog("НЕ ПРОГРУЖЕН. Используй Smooth Scan (X)!", true)
    end
    TweenService:Create(DebugInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
    task.wait(1)
    TweenService:Create(DebugInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== 9. КОПИРОВАТЬ ЛОГ ==========
LogBtn.MouseButton1Click:Connect(function()
    local success = false
    pcall(function()
        if setclipboard then
            setclipboard(fullLog)
            success = true
        elseif toclipboard then
            toclipboard(fullLog)
            success = true
        end
    end)
    if success then AddLog("Лог скопирован!") else AddLog("Нет setclipboard", true) end
    TweenService:Create(LogInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
    task.wait(1)
    TweenService:Create(LogInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== 10. СКАН REMOTES ==========
RemoteScanBtn.MouseButton1Click:Connect(function()
    AddLog("=== СКАН REMOTES ===")
    local rs = game:GetService("ReplicatedStorage")
    local count = 0
    for _, obj in ipairs(rs:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            count = count + 1
            AddLog("RE: " .. obj:GetFullName())
        elseif obj:IsA("RemoteFunction") then
            count = count + 1
            AddLog("RF: " .. obj:GetFullName())
        end
    end
    AddLog("Всего: " .. count)
    TweenService:Create(RemoteScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
    task.wait(1)
    TweenService:Create(RemoteScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== 11. БЛОК ТП-REMOTE ==========
BlockRemoteBtn.MouseButton1Click:Connect(function()
    remoteBlockEnabled = not remoteBlockEnabled
    
    if remoteBlockEnabled then
        TweenService:Create(BlockRemoteInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 100)}):Play()
        
        local mt = getrawmetatable(game)
        if not mt then AddLog("getrawmetatable не поддерживается", true) return end
        
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self:IsA("RemoteEvent") then
                local name = string.lower(self.Name)
                if string.find(name, "tp") or string.find(name, "teleport") or string.find(name, "position") or string.find(name, "check") or string.find(name, "anticheat") then
                    AddLog("Заблокирован: " .. self.Name, true)
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
        AddLog("Remote Blocker ВКЛ")
    else
        TweenService:Create(BlockRemoteInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Remote Blocker ВЫКЛ. Перезайди для сброса.")
    end
end)

-- ========== 12. FORCE OPEN (CFrame Spoofing) ==========
ForceChestBtn.MouseButton1Click:Connect(function()
    AddLog("=== FORCE OPEN ===")
    
    local hrp = getHRP()
    if not hrp then AddLog("HRP не найден", true) return end
    
    local targetChest = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if isDiamondChest(obj) then
            targetChest = obj
            break
        end
    end
    
    if not targetChest then
        AddLog("Diamond Chest не найден!", true)
        return
    end
    
    AddLog("Найден: " .. targetChest:GetFullName())
    
    local prompt = targetChest:FindFirstChildOfClass("ProximityPrompt") 
                   or (targetChest.Parent and targetChest.Parent:FindFirstChildOfClass("ProximityPrompt"))
    
    if not prompt then
        for _, child in ipairs(targetChest:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                prompt = child
                break
            end
        end
    end
    
    if not prompt then
        AddLog("ProximityPrompt не найден!", true)
        return
    end
    
    local originalCFrame = hrp.CFrame
    
    local chestPos
    if targetChest:IsA("Model") then
        chestPos = targetChest.PrimaryPart and targetChest.PrimaryPart.Position or targetChest:GetPivot().Position
    else
        chestPos = targetChest.Position
    end
    
    hrp.CFrame = CFrame.new(chestPos + Vector3.new(0, 2, 0))
    task.wait(0.05)
    
    pcall(function()
        fireproximityprompt(prompt)
    end)
    
    task.wait(0.05)
    hrp.CFrame = originalCFrame
    
    AddLog("Пакет отправлен!")
    
    TweenService:Create(ForceChestInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
    task.wait(1)
    TweenService:Create(ForceChestInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

AddLog("GhostWare v3.8 загружен!")
AddLog("Smooth Scan (Tween)")
AddLog("Smart Diamond Chest Detection")
