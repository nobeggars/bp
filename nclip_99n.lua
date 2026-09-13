--[[
    GHOSTWARE v3.0 — GRID SCANNER
    Author: I.S.-1
    Features:
    - Fly (F)
    - Noclip (G)
    - ESP Highlight (H)
    - Grid Scan Under Map (X) — сетка под картой
    - Stop Scan (Z)
    - TP to Found (Y)
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local uiName = "GhostWare_v3"

-- ========== НАСТРОЙКИ СКАНА ==========
local SCAN = {
    Y = -50,          -- высота под картой (ближе к поверхности)
    STEP = 200,       -- шаг сетки
    RANGE = 2000,     -- радиус покрытия (от -2000 до +2000)
    WAIT = 0.5,       -- задержка на точку
    KEYWORDS = {      -- что ищем
        "chestdef", "diamondchest", "stronghold", "cultist", "ritual", "altar"
    }
}

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local scanEnabled = false
local foundObject = nil
local bypassConnection = nil
local savedPos = nil
local savedCF = nil
local highlightObjects = {}

-- ========== CLEANUP ==========
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ========== UI ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 340)
Main.Position = UDim2.new(0.5, -200, 0.2, 0)
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
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Text = "GhostWare v3\nGrid Scanner"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
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
LogText.TextSize = 9
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.RichText = true
LogText.Text = "> GhostWare v3 загружен.\n> Grid Scanner готов.\n"
LogText.Parent = LogFrame

local function AddLog(msg, isErr)
    local color = isErr and '<font color="rgb(255,80,80)">' or '<font color="rgb(0,200,120)">'
    LogText.Text = string.format("%s[%s] %s</font>\n", color, os.date("%X"), msg) .. LogText.Text
end

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -20)
Content.Position = UDim2.new(0, 140, 0, 10)
Content.BackgroundTransparency = 1
Content.Parent = Main

local UIListLayout = Instance.new("UIListLayout", Content)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

local function CreateToggle(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(12, 14, 15)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = "    " .. text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
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
local EspBtn, EspInd = CreateToggle("2. ESP HIGHLIGHT")
local ScanBtn, ScanInd = CreateToggle("3. GRID SCAN (X)")
local TpBtn, TpInd = CreateToggle("4. TP К НАЙДЕННОМУ (Y)")
local StopBtn, StopInd = CreateToggle("5. СТОП СКАН (Z)")
local DebugBtn, DebugInd = CreateToggle("6. ПОКАЗАТЬ ВСЁ (J)")

local function getHRP()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- ========== FLY & NOCLIP ==========
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

-- ========== ESP HIGHLIGHT ==========
local function clearHighlight()
    for _, hl in ipairs(highlightObjects) do
        if hl and hl.Parent then hl:Destroy() end
    end
    highlightObjects = {}
end

local function applyHighlight(target, fillColor, outlineColor)
    if not target then return end
    local hl = Instance.new("Highlight")
    hl.Name = "GhostWareESP"
    hl.Adornee = target
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = target
    table.insert(highlightObjects, hl)
end

local function updateESP()
    clearHighlight()
    if not espEnabled then return end
    
    -- Подсвечиваем найденный объект
    if foundObject then
        applyHighlight(foundObject, Color3.fromRGB(200, 0, 255), Color3.fromRGB(255, 0, 255))
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, kw in ipairs(SCAN.KEYWORDS) do
                if n:find(kw) and not obj:IsA("Bone") then
                    applyHighlight(obj, Color3.fromRGB(200, 0, 255), Color3.fromRGB(255, 0, 255))
                    break
                end
            end
            if n:find("chest") and not n:find("def") and not obj:IsA("Bone") then
                applyHighlight(obj, Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 150, 0))
            end
        end
    end
end

EspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("ESP ВКЛ")
        updateESP()
    else
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("ESP ВЫКЛ")
        clearHighlight()
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if espEnabled then updateESP() end
    end
end)

-- ========== GRID SCAN ==========
local function findTarget()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, kw in ipairs(SCAN.KEYWORDS) do
                if n:find(kw) and not obj:IsA("Bone") then
                    if not obj:IsDescendantOf(LocalPlayer.Character or game) then
                        return obj
                    end
                end
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
    AddLog("Высота: " .. SCAN.Y .. " | Шаг: " .. SCAN.STEP .. " | Радиус: " .. SCAN.RANGE)
    
    task.spawn(function()
        local startPos = hrp.Position
        local totalPoints = 0
        local found = false
        
        -- Проходим по сетке
        for x = -SCAN.RANGE, SCAN.RANGE, SCAN.STEP do
            if not scanEnabled then break end
            for z = -SCAN.RANGE, SCAN.RANGE, SCAN.STEP do
                if not scanEnabled then break end
                
                local pos = Vector3.new(startPos.X + x, SCAN.Y, startPos.Z + z)
                hrp.CFrame = CFrame.new(pos)
                totalPoints = totalPoints + 1
                
                -- Логируем каждые 10 точек
                if totalPoints % 10 == 0 then
                    AddLog(string.format("Точка %d: X=%.0f Z=%.0f", totalPoints, pos.X, pos.Z))
                end
                
                task.wait(SCAN.WAIT)
                
                -- Сканируем
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
                    
                    AddLog("★ НАЙДЕНО: " .. target:GetFullName())
                    AddLog(string.format("Позиция: X=%.0f Y=%.0f Z=%.0f", targetPos.X, targetPos.Y, targetPos.Z))
                    
                    -- Останавливаемся под найденным объектом
                    hrp.CFrame = CFrame.new(targetPos.X, SCAN.Y, targetPos.Z)
                    
                    scanEnabled = false
                    AddLog("Скан завершён! Нажми ESP (H) чтобы увидеть.")
                    break
                end
            end
            if found then break end
        end
        
        if not found then
            AddLog("Ничего не найдено в радиусе " .. SCAN.RANGE, true)
            AddLog("Попробуй увеличить RANGE в настройках.")
        end
        
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
    end)
end)

-- ========== TP К НАЙДЕННОМУ ==========
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
    
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    TweenService:Create(TpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
    AddLog("ТП к найденному!")
    task.wait(1)
    TweenService:Create(TpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

-- ========== СТОП СКАН ==========
StopBtn.MouseButton1Click:Connect(function()
    scanEnabled = false
    AddLog("Скан остановлен.")
end)

-- ========== DEBUG ==========
DebugBtn.MouseButton1Click:Connect(function()
    AddLog("=== ПОЛНЫЙ СКАН WORKSPACE ===")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        for _, kw in ipairs(SCAN.KEYWORDS) do
            if n:find(kw) and not obj:IsA("Bone") then
                count = count + 1
                AddLog(obj:GetFullName() .. " | " .. obj.ClassName)
                break
            end
        end
    end
    AddLog("Всего найдено: " .. count)
    TweenService:Create(DebugInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
    task.wait(1)
    TweenService:Create(DebugInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
end)

AddLog("GhostWare v3 загружен!")
AddLog("Жми GRID SCAN и жди.")
