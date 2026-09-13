--[[
    GHOSTWARE v3.6 — REMOTE BLOCKER + CHEST OPENER
    Author: I.S.-1
    Features:
    - Fly (F)
    - Noclip (G)
    - ESP (H) — Diamond Chest: bright cyan
    - Anti-TP (B)
    - Night Vision (N)
    - Grid Scan (X)
    - Stop Scan (Z)
    - TP to Found (Y)
    - Debug (J)
    - Scan Remotes (R)
    - Block Remote (K)
    - Force Open Chest (O)
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
    WAIT = 0.5,
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
local espMode = "highlight"
local fullLog = ""
local originalLighting = {}
local espConnections = {}
local blockedRemotes = {}
local remoteHookConnection = nil

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
Main.Size = UDim2.new(0, 420, 0, 480)
Main.Position = UDim2.new(0.5, -210, 0.1, 0)
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
Title.Text = "GhostWare v3.6\nRemote Blocker"
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
LogText.Text = "> v3.6 загружен.\n"
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
local ScanBtn, ScanInd = CreateToggle("5. GRID SCAN (X)")
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

-- ========== 2. ESP ==========
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
    
    if espMode == "highlight" then
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
    else
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

local function isDiamondChest(obj)
    if not obj or not obj.Name then return false end
    local name = string.lower(obj.Name)
    if string.find(name, "diamond") and string.find(name, "chest") then
        return true
    end
    return false
end

local function isStronghold(obj)
    if not obj or not obj.Name then return false end
    local name = string.lower(obj.Name)
    if string.find(name, "stronghold") or string.find(name, "cultist") or string.find(name, "ritual") or string.find(name, "altar") then
        return true
    end
    return false
end

local function isNormalChest(obj)
    if not obj or not obj.Name then return false end
    local name = string.lower(obj.Name)
    if string.find(name, "chest") and not string.find(name, "diamond") then
        return true
    end
    return false
end

local function updateESP()
    clearESP()
    if not espEnabled then return end
    
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isDiamondChest(obj) then
            if not obj:IsA("Bone") then
                createESP(obj, Color3.fromRGB(0, 191, 255), "💎 DIAMOND CHEST 💎", true)
                count = count + 1
            end
        elseif isStronghold(obj) then
            if not obj:IsA("Bone") then
                createESP(obj, Color3.fromRGB(200, 0, 255), "★ STRONGHOLD ★", true)
                count = count + 1
            end
        elseif isNormalChest(obj) then
            if not obj:IsA("Bone") then
                createESP(obj, Color3.fromRGB(255, 200, 0), "Chest", false)
                count = count + 1
            end
        end
    end
    
    AddLog("ESP: подсвечено " .. count .. " объектов")
end

EspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("ESP ВКЛ (режим: " .. espMode .. ")")
        updateESP()
        
        local conn = workspace.DescendantAdded:Connect(function(obj)
            if not espEnabled then return end
            if isDiamondChest(obj) then
                AddLog("★ DIAMOND CHEST ПОЯВИЛСЯ: " .. obj:GetFullName())
                createESP(obj, Color3.fromRGB(0, 191, 255), "💎 DIAMOND CHEST 💎", true)
            elseif isStronghold(obj) then
                AddLog("★ STRONGHOLD ПОЯВИЛСЯ: " .. obj:GetFullName())
                createESP(obj, Color3.fromRGB(200, 0, 255), "★ STRONGHOLD ★", true)
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
        if hrp and hrp:FindFirstChild("GhostLight") then
            hrp.GhostLight:Destroy()
        end
        AddLog("Night Vision ВЫКЛ")
    end
end)

-- ========== 5. GRID SCAN ==========
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
    AddLog("=== GRID SCAN НАЧАТ ===")
    
    task.spawn(function()
        local startPos = hrp.Position
        local totalPoints = 0
        local found = false
        
        for x = -SCAN.RANGE, SCAN.RANGE, SCAN.STEP do
            if not scanEnabled then break end
            for z = -SCAN.RANGE, SCAN.RANGE, SCAN.STEP do
                if not scanEnabled then break end
                
                local pos = Vector3.new(startPos.X + x, SCAN.Y, startPos.Z + z)
                hrp.CFrame = CFrame.new(pos)
                totalPoints = totalPoints + 1
                
                if totalPoints % 10 == 0 then
                    AddLog(string.format("Точка %d: X=%.0f Z=%.0f", totalPoints, pos.X, pos.Z))
                end
                
                task.wait(SCAN.WAIT)
                
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
                    
                    hrp.CFrame = CFrame.new(targetPos.X, SCAN.Y, targetPos.Z)
                    
                    scanEnabled = false
                    AddLog("Скан завершён! Включи ESP (H).")
                    break
                end
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
        AddLog("НЕ ПРОГРУЖЕН. Лети ближе!", true)
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
            AddLog("RemoteEvent: " .. obj:GetFullName())
        elseif obj:IsA("RemoteFunction") then
            count = count + 1
            AddLog("RemoteFunction: " .. obj:GetFullName())
        end
    end
    AddLog("Всего: " .. count)
    TweenService:Create(RemoteScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
    task.wait(1)
    TweenService:Create(RemoteScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== 11. БЛОК ТП-REMOTE ==========
local function enableRemoteBlock()
    if remoteHookConnection then remoteHookConnection:Disconnect() end
    
    -- Хукаем __namecall
    local mt = getrawmetatable(game)
    if not mt then AddLog("getrawmetatable не поддерживается", true) return end
    
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Блокируем все FireServer на RemoteEvent, которые содержат "tp", "teleport", "position", "check"
        if method == "FireServer" and self:IsA("RemoteEvent") then
            local name = string.lower(self.Name)
            if string.find(name, "tp") or string.find(name, "teleport") or string.find(name, "position") or string.find(name, "check") or string.find(name, "anticheat") then
                AddLog("Заблокирован: " .. self:GetFullName(), true)
                return nil
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    AddLog("Remote Blocker ВКЛ")
end

BlockRemoteBtn.MouseButton1Click:Connect(function()
    local state = not BlockRemoteInd:GetAttribute("state")
    BlockRemoteInd:SetAttribute("state", state)
    
    if state then
        TweenService:Create(BlockRemoteInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 100)}):Play()
        enableRemoteBlock()
    else
        TweenService:Create(BlockRemoteInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Remote Blocker ВЫКЛ. Перезайди в игру для сброса.")
    end
end)

-- ========== 12. ОТКРЫТЬ СУНДУК ==========
ForceChestBtn.MouseButton1Click:Connect(function()
    AddLog("=== ПОИСК И ОТКРЫТИЕ DIAMOND CHEST ===")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isDiamondChest(obj) then
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt") 
                          or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))
            if prompt then
                count = count + 1
                AddLog("Найден prompt: " .. prompt:GetFullName())
                pcall(function()
                    fireproximityprompt(prompt)
                end)
                AddLog("fireproximityprompt вызван!")
            end
        end
    end
    
    if count == 0 then
        AddLog("Diamond Chest с ProximityPrompt не найден!", true)
    else
        AddLog("Открыто сундуков: " .. count)
    end
    
    TweenService:Create(ForceChestInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
    task.wait(1)
    TweenService:Create(ForceChestInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

AddLog("GhostWare v3.6 загружен!")
AddLog("10. Скан Remotes (R)")
AddLog("11. Блок Remote (K)")
AddLog("12. Открыть сундук (O)")
