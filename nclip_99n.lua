local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local uiName = "GhostWare_Hybrid_Fix"

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local bypassEnabled = false
local scanEnabled = false

local savedPos = nil
local savedCF = nil
local bypassConnection = nil
local espObjects = {}

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ========== UI VOIDWARE STYLE ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 280)
Main.Position = UDim2.new(0.5, -210, 0.2, 0)
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

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 10, 1, 0)
Divider.Position = UDim2.new(1, -5, 0, 0)
Divider.BackgroundColor3 = Color3.fromRGB(16, 20, 20)
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Text = "GhostWare\nDipstick Edit"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
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
LogText.TextSize = 10
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Text = "> Фикс Анти-ТП загружен.\n> Ждем команд, принцесса."
LogText.Parent = LogFrame

local function AddLog(msg, isErr)
    local color = isErr and '<font color="rgb(255,80,80)">' or '<font color="rgb(0,200,120)">'
    LogText.RichText = true
    LogText.Text = string.format("%s[%s] %s</font>\n", color, os.date("%X"), msg) .. LogText.Text
end

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -20)
Content.Position = UDim2.new(0, 150, 0, 10)
Content.BackgroundTransparency = 1
Content.Parent = Main

local UIListLayout = Instance.new("UIListLayout", Content)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local function CreateVoidToggle(name, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(12, 14, 15)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = "    " .. text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Content
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 4, 0, 16)
    Indicator.Position = UDim2.new(0, 0, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 45, 45)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 22, 25)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(12, 14, 15)}):Play() end)
    
    return btn, Indicator
end

local AntiTpBtn, AntiTpInd = CreateVoidToggle("AntiTP", "1. ANTI-TP (Dipsik)")
local FlyBtn, FlyInd = CreateVoidToggle("Fly", "2. FLY & NOCLIP (Mobile)")
local EspBtn, EspInd = CreateVoidToggle("ESP", "3. ESP (All Items)")
local ScanBtn, ScanInd = CreateVoidToggle("Scan", "4. AUTO-SCAN СТРОНГХОЛД")

local function getHRP()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- ========== 1. ANTI-TP (С ИСПРАВЛЕНИЕМ ГОНКИ ПОТОКОВ) ==========
local function enableAntiTP()
    local hrp = getHRP()
    if not hrp then return end
    if bypassConnection then bypassConnection:Disconnect() end
    
    savedPos = hrp.Position
    savedCF = hrp.CFrame
    
    bypassConnection = RunService.Heartbeat:Connect(function()
        if not bypassEnabled then return end
        if scanEnabled then return end -- Пока ищем, не блочим
        
        local h = getHRP()
        if not h then return end
        
        local dist = (h.Position - savedPos).Magnitude
        if dist > 150 then
            h.CFrame = savedCF
            AddLog("Анти-ТП: Телепорт заблокирован!", true)
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
        AddLog("Anti-TP включен.")
        enableAntiTP()
    else
        TweenService:Create(AntiTpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Anti-TP отключен.")
        if bypassConnection then bypassConnection:Disconnect() bypassConnection = nil end
    end
end)

-- ========== 2. FLY & NOCLIP ==========
local noclipLoop
FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    noclipEnabled = flyEnabled
    
    local hrp = getHRP()
    local char = LocalPlayer.Character
    
    if flyEnabled and hrp then
        TweenService:Create(FlyInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Fly & Noclip включены!")
        
        local humanoid = hrp.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = true end
        
        noclipLoop = RunService.Stepped:Connect(function()
            if noclipEnabled and char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        TweenService:Create(FlyInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Fly & Noclip выключены.")
        if noclipLoop then noclipLoop:Disconnect() end
        
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end)

RunService.RenderStepped:Connect(function()
    if not flyEnabled or scanEnabled then return end
    local hrp = getHRP()
    if not hrp then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local move = Vector3.new(0, 0, 0)
    
    -- ПК Управление
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    
    -- МОБИЛЬНЫЙ ДЖОЙСТИК
    if hum and move.Magnitude == 0 then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            move = (Camera.CFrame.LookVector * (moveDir.Z * -1)) + (Camera.CFrame.RightVector * moveDir.X)
        end
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    
    if move.Magnitude > 0 then 
        hrp.Velocity = move.Unit * 100
    else 
        hrp.Velocity = Vector3.new(0, 0, 0) 
    end
end)

-- ========== 3. ESP (УЛУЧШЕНО БИНОМ) ==========
local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
end

local function createESP(target, color, label, big)
    if not target then return end
    
    -- Рамка на объект
    local box = Instance.new("BoxHandleAdornment")
    box.Size = target:IsA("Model") and target:GetExtentsSize() or target.Size
    box.Transparency = 0.6
    box.Color3 = color
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = target:IsA("Model") and target.PrimaryPart or target
    if not box.Adornee then box.Adornee = target end
    box.Parent = box.Adornee
    table.insert(espObjects, box)

    -- Текст, который видно издалека
    if label then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = math.huge -- Видно с любого расстояния!
        billboard.StudsOffset = Vector3.new(0, target:IsA("Model") and 10 or 3, 0)
        billboard.Adornee = box.Adornee
        billboard.Parent = box.Adornee
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = color
        text.Font = Enum.Font.GothamBlack
        text.TextSize = big and 16 or 12
        text.TextStrokeTransparency = 0
        text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        text.Parent = billboard
        table.insert(espObjects, billboard)
    end
end

local function updateESP()
    clearESP()
    if not espEnabled then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        -- Ищем Стронгхолд
        if obj.Name == "Stronghold" then
            createESP(obj, Color3.fromRGB(200, 0, 255), "★ СТРОНГХОЛД ЗДЕСЬ ★", true)
        -- Ищем Алмазный сундук
        elseif (obj.Name == "ChestDEF" or obj.Name == "DiamondChest") and not obj:IsA("Bone") and not obj:IsDescendantOf(LocalPlayer.Character or game) then
            createESP(obj, Color3.fromRGB(0, 255, 255), "💎 АЛМАЗНЫЙ СУНДУК 💎", true)
        -- Ищем обычные сундуки
        elseif string.find(obj.Name:lower(), "chest") and not string.find(obj.Name:lower(), "def") then
            createESP(obj, Color3.fromRGB(255, 200, 0), "Сундук", false)
        end
    end
    
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, npc in ipairs(chars:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                local n = npc.Name:lower()
                if n:find("cultist") or n:find("cult") then
                    createESP(npc, Color3.fromRGB(255, 50, 50), "Cultist", false)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2) -- Раз в 2 секунды, чтобы не лагал телефон
        if espEnabled then updateESP() end
    end
end)

EspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("ESP включен (Видно издалека).")
        updateESP()
    else
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("ESP отключен.")
        clearESP()
    end
end)

-- ========== 4. АВТО-ПОИСК ПОД КАРТОЙ (ФИКС ОТКИДЫВАНИЯ) ==========
ScanBtn.MouseButton1Click:Connect(function()
    if scanEnabled then
        scanEnabled = false
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Поиск остановлен.")
        return
    end
    
    local hrp = getHRP()
    if not hrp then return end
    
    scanEnabled = true
    TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 150)}):Play()
    AddLog("Ухожу под землю на сканирование...")
    
    task.spawn(function()
        local startPos = hrp.Position
        local scanY = -150
        local step = 150
        local radius = 0
        local angle = 0
        
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.P = 10000
        bp.Parent = hrp
        
        while scanEnabled do
            local x = startPos.X + math.cos(math.rad(angle)) * radius
            local z = startPos.Z + math.sin(math.rad(angle)) * radius
            
            bp.Position = Vector3.new(x, scanY, z)
            
            local found = nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                -- ТОЧНО ищем тот самый сундук!
                if (obj.Name == "ChestDEF" or obj.Name == "DiamondChest") and not obj:IsDescendantOf(LocalPlayer.Character or game) then
                    found = obj
                    break
                end
            end
            
            if found then
                local targetPos = found:IsA("Model") and found:GetPivot().Position or found.Position
                
                -- Паркуемся ровно ПОД сундуком
                bp.Position = Vector3.new(targetPos.X, targetPos.Y - 20, targetPos.Z)
                hrp.CFrame = CFrame.new(bp.Position)
                
                AddLog("★ АЛМАЗНЫЙ СУНДУК НАЙДЕН!")
                
                -- КРИТИЧЕСКИЙ ФИКС: ОБНОВЛЯЕМ АНТИ-ТП ДО ВЫКЛЮЧЕНИЯ СКАНА
                if bypassEnabled then
                    savedPos = hrp.Position
                    savedCF = hrp.CFrame
                end
                
                task.wait(0.1) -- Даем кадру прогрузиться
                scanEnabled = false -- ВЫКЛЮЧАЕМ СКАН. АНТИ-ТП ПРИНИМАЕТ НОВУЮ ПОЗИЦИЮ.
                
                AddLog("Завис внизу! Врубай Fly и лутай!")
                break
            end
            
            angle = angle + 45
            if angle >= 360 then
                angle = 0
                radius = radius + step
            end
            task.wait(0.2)
        end
        
        if bp then bp:Destroy() end
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
    end)
end)
