local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local uiName = "Voidware_GhostHunter"

-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
local flyNoclipEnabled = false
local antiTpEnabled = false
local espEnabled = false
local scanEnabled = false

local savedPos = nil
local savedCF = nil
local AntiTpConn = nil
local espObjects = {}

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный Фрейм (Voidware Style)
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
Title.Text = "GhostWare\nUnderground"
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
LogText.Text = "> Ядро загружено.\n> Код Бина + Дипсика."
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

local AntiTpBtn, AntiTpInd = CreateVoidToggle("AntiTP", "1. Anti-TP (Dipsik Base)")
local FlyBtn, FlyInd = CreateVoidToggle("Fly", "2. Fly & Noclip")
local EspBtn, EspInd = CreateVoidToggle("ESP", "3. ESP (Stronghold/Chests)")
local ScanBtn, ScanInd = CreateVoidToggle("Scan", "4. ПОИСК ПОД КАРТОЙ (Bin Core)")

-- ХЕЛПЕРЫ
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- 1. ANTI-TP (КОПИЯ ДИПСИКА С УЛУЧШЕНИЯМИ)
AntiTpBtn.MouseButton1Click:Connect(function()
    antiTpEnabled = not antiTpEnabled
    if antiTpEnabled then
        TweenService:Create(AntiTpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Anti-TP включен!")
        
        local hrp = getHRP()
        if hrp then
            savedPos = hrp.Position
            savedCF = hrp.CFrame
        end
        
        AntiTpConn = RunService.Heartbeat:Connect(function()
            local h = getHRP()
            if not h then return end
            -- Если мы летим сканером, не блочим ТП
            if scanEnabled then
                savedCF = h.CFrame
                savedPos = h.Position
                return
            end
            
            local dist = (h.Position - savedPos).Magnitude
            if dist > 150 then -- Если откинуло далеко - возвращаем
                h.CFrame = savedCF
                AddLog("Телепорт заблокирован!", true)
            else
                savedCF = h.CFrame
                savedPos = h.Position
            end
        end)
    else
        TweenService:Create(AntiTpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Anti-TP выключен.")
        if AntiTpConn then AntiTpConn:Disconnect() AntiTpConn = nil end
    end
end)

-- 2. FLY & NOCLIP (Улучшенный Дипсик для мобилок)
local FlyConn, NoclipConn
FlyBtn.MouseButton1Click:Connect(function()
    flyNoclipEnabled = not flyNoclipEnabled
    local hrp = getHRP()
    local char = LocalPlayer.Character
    
    if flyNoclipEnabled and hrp then
        TweenService:Create(FlyInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Fly & Noclip включены!")
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
        
        FlyConn = RunService.RenderStepped:Connect(function()
            local h = getHRP()
            local hm = char:FindFirstChildOfClass("Humanoid")
            if not h or not hm then return end
            
            local move = Vector3.new(0, 0, 0)
            -- Поддержка ПК
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            
            -- Поддержка Мобильного Джойстика
            local moveDir = hm.MoveDirection
            if move.Magnitude == 0 and moveDir.Magnitude > 0 then
                move = (Camera.CFrame.LookVector * moveDir.Z * -1) + (Camera.CFrame.RightVector * moveDir.X)
            end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            
            if move.Magnitude > 0 then
                h.Velocity = move.Unit * 60
            else
                h.Velocity = Vector3.new(0, 0, 0)
            end
        end)
        
        NoclipConn = RunService.Stepped:Connect(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        TweenService:Create(FlyInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Fly & Noclip выключены.")
        if FlyConn then FlyConn:Disconnect() end
        if NoclipConn then NoclipConn:Disconnect() end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

-- 3. ESP
local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
end

local function createESP(target, color, text)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = target:IsA("Model") and target:GetExtentsSize() or target.Size
    box.Transparency = 0.5
    box.Color3 = color
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = target:IsA("Model") and target.PrimaryPart or target
    box.Parent = box.Adornee
    table.insert(espObjects, box)

    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.AlwaysOnTop = true
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.Adornee = box.Adornee
    bg.Parent = box.Adornee
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0
    label.Parent = bg
    table.insert(espObjects, bg)
end

EspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("ESP включен.")
        task.spawn(function()
            while espEnabled do
                clearESP()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "Stronghold" then
                        createESP(obj, Color3.fromRGB(255, 0, 255), "★ STRONGHOLD ★")
                    elseif obj.Name == "DiamondChest" then
                        createESP(obj, Color3.fromRGB(0, 255, 255), "💎 DIAMOND CHEST 💎")
                    end
                end
                task.wait(2)
            end
        end)
    else
        TweenService:Create(EspInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("ESP выключен.")
        clearESP()
    end
end)

-- 4. АВТО-ПОИСК СТРОНГХОЛДА (ЯДРО БИНА)
ScanBtn.MouseButton1Click:Connect(function()
    if scanEnabled then
        scanEnabled = false
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Сканирование остановлено.")
        return
    end
    
    local hrp = getHRP()
    if not hrp then return end
    
    scanEnabled = true
    TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 150)}):Play()
    AddLog("Ухожу под землю для скана...")
    
    task.spawn(function()
        local startPos = hrp.Position
        local scanY = -150 -- Летаем глубоко под картой
        
        -- Спиральный поиск для прогрузки чанков
        local step = 150
        local radius = 0
        local angle = 0
        local foundTarget = nil
        
        -- Ставим платформу, чтобы не падать во время скана
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.P = 10000
        bp.Parent = hrp
        
        while scanEnabled do
            local x = startPos.X + math.cos(math.rad(angle)) * radius
            local z = startPos.Z + math.sin(math.rad(angle)) * radius
            
            bp.Position = Vector3.new(x, scanY, z)
            
            -- Ищем Стронгхолд
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
                    foundTarget = obj
                    break
                end
            end
            
            if foundTarget then
                AddLog("СТРОНГХОЛД НАЙДЕН!")
                local tPos = foundTarget:IsA("Model") and foundTarget:GetPivot().Position or foundTarget.Position
                
                -- Зависаем ровно под ним!
                bp.Position = Vector3.new(tPos.X, tPos.Y - 25, tPos.Z)
                hrp.CFrame = CFrame.new(bp.Position)
                
                if antiTpEnabled then
                    savedPos = hrp.Position
                    savedCF = hrp.CFrame
                end
                
                AddLog("Завис под сундуком! Врубай Fly и лутай!")
                scanEnabled = false
                break
            end
            
            angle = angle + 45
            if angle >= 360 then
                angle = 0
                radius = radius + step
                AddLog("Радиус скана: " .. tostring(radius))
            end
            task.wait(0.2)
        end
        
        if bp then bp:Destroy() end
        TweenService:Create(ScanInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
    end)
end)
