--[[
    GHOSTWARE v4.0 — SPIRAL SCAN + FULL FEATURES
    Author: I.S.-1 + Gemini Core Fix
    Features:
    - Fly (F)
    - Noclip (G)
    - ESP (H) — Diamond Chest: Cyan, Stronghold: Pink
    - Anti-TP (B)
    - Night Vision (N)
    - Spiral Grid Scan (X)
    - Stop Scan (Z)
    - TP to Found (Y)
    - Debug (J)
    - Scan Remotes (R)
    - Block Remote (K)
    - Force Open (O) — CFrame Spoofing
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

local uiName = "GhostWare_v4"

-- ========== НАСТРОЙКИ ==========
local SCAN = {
    Y = -50,
    STEP = 180,
    MAX_RINGS = 12,
    TWEEN_SPEED = 120,
    WAIT_AT_POINT = 0.3,
}

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local bypassEnabled = false
local nightVisionEnabled = false
local scanEnabled = false
local foundObject = nil
local highlightObjects = {}
local fullLog = ""
local originalLighting = {}
local espConnections = {}
local remoteBlockEnabled = false
local bypassConnection = nil
local savedPos = nil
local savedCF = nil

-- ========== CLEANUP ==========
pcall(function() if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end end)
pcall(function() if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false

local parentSet = false
pcall(function() if gethui then ScreenGui.Parent = gethui() parentSet = true end end)
if not parentSet then pcall(function() ScreenGui.Parent = CoreGui parentSet = true end) end
if not parentSet then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
Title.Text = "GhostWare v4.0\nSpiral Full"
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
LogFrame.ScrollBarThickness = 1
LogFrame.Parent = Sidebar
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 6)

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -5, 1, 0)
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(150, 170, 160)
LogText.Font = Enum.Font.Code
LogText.TextSize = 8
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.RichText = true
LogText.Text = "> v4.0 запущен.\n"
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
local ScanBtn, ScanInd = CreateToggle("5. SPIRAL SCAN (X)")
local TpBtn, TpInd = CreateToggle("6. TP К НАЙДЕННОМУ (Y)")
local StopBtn, StopInd = CreateToggle("7. СТОП СКАН (Z)")
local DebugBtn, DebugInd = CreateToggle("8. ПОКАЗАТЬ ВСЁ (J)")
local LogBtn, LogInd = CreateToggle("9. КОПИРОВАТЬ ЛОГ (C)")
local RemoteScanBtn, RemoteScanInd = CreateToggle("10. СКАН REMOTES (R)")
local BlockRemoteBtn, BlockRemoteInd = CreateToggle("11. БЛОК ТП-REMOTE (K)")
local ForceChestBtn, ForceChestInd = CreateToggle("12. ОТКРЫТЬ СУНДУК (O)")

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
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
local function isTargetChest(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "diamond") and string.find(name, "chest") then
        return true, "💎 DIAMOND CHEST 💎", Color3.fromRGB(0, 240, 255)
    end
    if name == "chest" and obj.Parent then
        local pName = string.lower(obj.Parent.Name)
        if string.find(pName, "stronghold") or string.find(pName, "cultist") then
            return true, "💎 STRONGHOLD CHEST 💎", Color3.fromRGB(0, 240, 255)
        end
    end
    if string.find(name, "stronghold") or string.find(name, "cultist") then
        if obj:IsA("Model") or obj:IsA("BasePart") then
            return true, "🏰 STRONGHOLD 🏰", Color3.fromRGB(255, 0, 255)
        end
    end
    return false
end

local function createESP(object, color, text)
    if highlightObjects[object] then return end
    
    local success = pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "GhostESP"
        highlight.FillColor = color
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.2
        highlight.Adornee = object
        highlight.Parent = object
        table.insert(highlightObjects, highlight)
    end)
    
    if not success then
        local adornee = object
        if object:IsA("Model") then
            adornee = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
        end
        if adornee then
            local box = Instance.new("BoxHandleAdornment")
            box.Size = object:IsA("Model") and object:GetExtentsSize() or object.Size
            box.Color3 = color
            box.AlwaysOnTop = true
            box.Adornee = adornee
            box.Parent = adornee
            table.insert(highlightObjects, box)
        end
    end
    
    -- Billboard
    pcall(function()
        local adornee = object
        if object:IsA("Model") then
            adornee = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
        end
        if adornee then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 250, 0, 50)
            bb.AlwaysOnTop = true
            bb.MaxDistance = math.huge
            bb.StudsOffset = Vector3.new(0, 10, 0)
            bb.Adornee = adornee
            bb.Parent = adornee
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = text
            tl.TextColor3 = color
            tl.Font = Enum.Font.GothamBlack
            tl.TextSize = 16
            tl.TextStrokeTransparency = 0
            tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            tl.Parent = bb
            table.insert(highlightObjects, bb)
        end
    end)
    
    AddLog("ESP: " .. text)
    if string.find(text, "CHEST") then foundObject = object end
end

EspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    
    if espEnabled then
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("ESP ВКЛ")
        
        for _, obj in pairs(workspace:GetDescendants()) do
            local isTarget, label, color = isTargetChest(obj)
            if isTarget then createESP(obj, color, label) end
        end
        
        table.insert(espConnections, workspace.DescendantAdded:Connect(function(obj)
            if not espEnabled then return end
            local isTarget, label, color = isTargetChest(obj)
            if isTarget then createESP(obj, color, label) end
        end))
    else
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        for _, hl in pairs(highlightObjects) do pcall(function() hl:Destroy() end) end
        highlightObjects = {}
        for _, conn in pairs(espConnections) do pcall(function() conn:Disconnect() end) end
        espConnections = {}
        AddLog("ESP ВЫКЛ")
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

-- ========== 5. SPIRAL SCAN ==========
ScanBtn.MouseButton1Click:Connect(function()
    if scanEnabled then
        AddLog("Скан уже запущен", true)
        return
    end
    
    local hrp = getHRP()
    if not hrp then
        AddLog("HRP не найден", true)
        return
    end
    
    scanEnabled = true
    TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 150)}):Play()
    AddLog("Запуск спирального сканирования...")
    
    local startPos = hrp.Position
    local x, z = 0, 0
    local dx, dz = 0, -1
    
    task.spawn(function()
        for i = 1, (SCAN.MAX_RINGS * 2)^2 do
            if not scanEnabled then break end
            
            if (-SCAN.MAX_RINGS < x and x <= SCAN.MAX_RINGS) and (-SCAN.MAX_RINGS < z and z <= SCAN.MAX_RINGS) then
                local targetX = startPos.X + (x * SCAN.STEP)
                local targetZ = startPos.Z + (z * SCAN.STEP)
                local targetPos = Vector3.new(targetX, SCAN.Y, targetZ)
                
                local distance = (hrp.Position - targetPos).Magnitude
                local duration = distance / SCAN.TWEEN_SPEED
                
                if duration > 0 then
                    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                    tween:Play()
                    tween.Completed:Wait()
                end
                
                pcall(function() LocalPlayer:RequestStreamAroundAsync(hrp.Position) end)
                task.wait(SCAN.WAIT_AT_POINT)
                
                if foundObject then
                    AddLog("★ ЦЕЛЬ НАЙДЕНА! Скан остановлен.")
                    break
                end
            end
            
            if x == z or (x < 0 and x == -z) or (x > 0 and x == 1 - z) then
                dx, dz = -dz, dx
            end
            x, z = x + dx, z + dz
        end
        
        scanEnabled = false
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Спиральный скан завершён.")
    end)
end)

-- ========== 6. TP К НАЙДЕННОМУ ==========
TpBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if hrp and foundObject then
        local pos
        if foundObject:IsA("Model") then
            pos = foundObject.PrimaryPart and foundObject.PrimaryPart.Position or foundObject:GetPivot().Position
        else
            pos = foundObject.Position
        end
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        AddLog("ТП к найденному!")
    else
        AddLog("Цель не найдена", true)
    end
end)

-- ========== 7. СТОП СКАН ==========
StopBtn.MouseButton1Click:Connect(function()
    scanEnabled = false
    TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
    AddLog("Скан остановлен.")
end)

-- ========== 8. DEBUG ==========
DebugBtn.MouseButton1Click:Connect(function()
    AddLog("=== ПОЛНЫЙ СКАН ===")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        local isTarget, label, color = isTargetChest(obj)
        if isTarget then
            count = count + 1
            AddLog(obj:GetFullName() .. " | " .. label)
        end
    end
    AddLog("Всего найдено: " .. count)
    TweenService:Create(DebugInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
    task.wait(1)
    TweenService:Create(DebugInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== 9. КОПИРОВАТЬ ЛОГ ==========
LogBtn.MouseButton1Click:Connect(function()
    local success = false
    pcall(function()
        if setclipboard then setclipboard(fullLog) success = true
        elseif toclipboard then toclipboard(fullLog) success = true end
    end)
    if success then AddLog("Лог скопирован!") else AddLog("Нет setclipboard", true) end
    TweenService:Create(LogInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
    task.wait(1)
    TweenService:Create(LogInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== 10. СКАН REMOTES ==========
RemoteScanBtn.MouseButton1Click:Connect(function()
    AddLog("=== REMOTES ===")
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

-- ========== 11. БЛОК REMOTE ==========
BlockRemoteBtn.MouseButton1Click:Connect(function()
    remoteBlockEnabled = not remoteBlockEnabled
    
    if remoteBlockEnabled then
        TweenService:Create(BlockRemoteInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 100)}):Play()
        
        local mt = getrawmetatable(game)
        if not mt then AddLog("getrawmetatable нет", true) return end
        
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self:IsA("RemoteEvent") then
                local name = string.lower(self.Name)
                if string.find(name, "tp") or string.find(name, "teleport") or string.find(name, "check") or string.find(name, "anticheat") then
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
        AddLog("Remote Blocker ВЫКЛ. Перезайди.")
    end
end)

-- ========== 12. FORCE OPEN (CFrame Spoofing) ==========
ForceChestBtn.MouseButton1Click:Connect(function()
    AddLog("=== FORCE OPEN ===")
    
    local hrp = getHRP()
    if not hrp then AddLog("HRP не найден", true) return end
    if not foundObject then AddLog("Сначала найди сундук!", true) return end
    
    local prompt = foundObject:FindFirstChildOfClass("ProximityPrompt") 
                   or (foundObject.Parent and foundObject.Parent:FindFirstChildOfClass("ProximityPrompt"))
    
    if not prompt then
        for _, child in ipairs(foundObject:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                prompt = child
                break
            end
        end
    end
    
    if not prompt then AddLog("ProximityPrompt не найден", true) return end
    
    AddLog("Спуфинг CFrame...")
    
    -- CFrame Spoofing через hookmetamethod
    local spoofActive = true
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, index)
        if spoofActive and self == hrp and index == "CFrame" and not checkcaller() then
            return foundObject.CFrame
        end
        return oldIndex(self, index)
    end)
    
    local oldCF = hrp.CFrame
    hrp.CFrame = foundObject.CFrame + Vector3.new(0, 1, 0)
    task.wait(0.1)
    
    pcall(function() fireproximityprompt(prompt) end)
    AddLog("Пакет отправлен!")
    task.wait(0.1)
    
    spoofActive = false
    hrp.CFrame = oldCF
    AddLog("Позиция восстановлена.")
    
    TweenService:Create(ForceChestInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
    task.wait(1)
    TweenService:Create(ForceChestInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

AddLog("GhostWare v4.0 загружен!")
AddLog("Spiral Scan + CFrame Spoofing")
