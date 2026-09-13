local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local uiName = "GhostWare_99Nights"

-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
getgenv().Noclip = false
getgenv().AntiTP = false
getgenv().AutoUnderground = false
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local uiName = "GhostWare_Mobile_V2"

-- Глобалки
getgenv().Noclip = false
getgenv().AntiTP = false
getgenv().ESP = false
getgenv().ScanActive = false
getgenv().FlySpeed = 50

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный Фрейм
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 340)
Main.Position = UDim2.new(0.5, -160, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(150, 0, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "★ GHOSTWARE MOBILE ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.BackgroundTransparency = 1
Title.Parent = Main

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 0, 60)
LogFrame.Position = UDim2.new(0, 10, 0, 45)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 2
LogFrame.Parent = Main
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 6)

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -10, 1, 0)
LogText.Position = UDim2.new(0, 5, 0, 0)
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(150, 0, 255)
LogText.Font = Enum.Font.Code
LogText.TextSize = 11
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Text = "[SYS] Дипсик попущен. Ядро запущено..."
LogText.Parent = LogFrame

local function AddLog(msg, isErr)
    local color = isErr and '<font color="rgb(255,70,70)">' or '<font color="rgb(150,0,255)">'
    LogText.RichText = true
    LogText.Text = string.format("%s[%s] %s</font>\n", color, os.date("%X"), msg) .. LogText.Text
end

local function CreateBtn(name, text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.TextColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color
    stroke.Thickness = 1
    return btn, stroke
end

local AntiTpBtn, AntiTpStroke = CreateBtn("AntiTP", "1. ANTI-TP (Удалить барьеры)", 115, Color3.fromRGB(200, 200, 200))
local NoclipBtn, NoclipStroke = CreateBtn("Noclip", "2. FLY & NOCLIP (Мобильный)", 160, Color3.fromRGB(200, 200, 200))
local EspBtn, EspStroke = CreateBtn("ESP", "3. ESP (Неон-Подсветка)", 205, Color3.fromRGB(200, 200, 200))
local ScanBtn, ScanStroke = CreateBtn("Scan", "4. ИСКАТЬ СТРОНГХОЛД ПОД КАРТОЙ", 250, Color3.fromRGB(255, 100, 100))
local StopBtn, _ = CreateBtn("Stop", "АВАРИЙНЫЙ СТОП (Сбросить Fly)", 295, Color3.fromRGB(255, 50, 50))

-- 1. АНТИ-ТП
local AntiTpConn
AntiTpBtn.MouseButton1Click:Connect(function()
    getgenv().AntiTP = not getgenv().AntiTP
    if getgenv().AntiTP then
        AntiTpBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        AntiTpStroke.Color = Color3.fromRGB(0, 255, 150)
        AddLog("Анти-ТП включен. Режу триггеры...")
        
        -- Постоянно удаляем зоны телепорта, чтобы не выкинуло из-под текстур
        AntiTpConn = RunService.Stepped:Connect(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    obj:Destroy()
                end
            end
        end)
    else
        AntiTpBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        AntiTpStroke.Color = Color3.fromRGB(200, 200, 200)
        AddLog("Анти-ТП отключен.")
        if AntiTpConn then AntiTpConn:Disconnect() end
    end
end)

-- 2. FLY & NOCLIP ДЛЯ МОБИЛОК (ИДЕАЛЬНЫЙ)
local FlyBody, FlyGyro, FlyConn, NoclipConn

NoclipBtn.MouseButton1Click:Connect(function()
    getgenv().Noclip = not getgenv().Noclip
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if getgenv().Noclip and hrp and hum then
        NoclipBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        NoclipStroke.Color = Color3.fromRGB(0, 255, 150)
        AddLog("Мобильный Fly включен!")
        
        hum.PlatformStand = true
        
        FlyBody = Instance.new("BodyVelocity")
        FlyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBody.Parent = hrp
        
        FlyGyro = Instance.new("BodyGyro")
        FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyGyro.P = 10000
        FlyGyro.Parent = hrp
        
        FlyConn = RunService.RenderStepped:Connect(function()
            -- Берем направление с джойстика в мировых координатах. Никакой инверсии!
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                FlyBody.Velocity = moveDir * getgenv().FlySpeed
            else
                FlyBody.Velocity = Vector3.new(0, 0, 0)
            end
            FlyGyro.CFrame = Camera.CFrame
        end)
        
        -- Сквозь стены
        NoclipConn = RunService.Stepped:Connect(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    else
        NoclipBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        NoclipStroke.Color = Color3.fromRGB(200, 200, 200)
        AddLog("Fly отключен.")
        if FlyBody then FlyBody:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        if FlyConn then FlyConn:Disconnect() end
        if NoclipConn then NoclipConn:Disconnect() end
        if hum then hum.PlatformStand = false end
    end
end)

-- 3. ESP
local espObjects = {}
EspBtn.MouseButton1Click:Connect(function()
    getgenv().ESP = not getgenv().ESP
    if getgenv().ESP then
        EspBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        EspStroke.Color = Color3.fromRGB(0, 255, 150)
        AddLog("ESP включен.")
        
        task.spawn(function()
            while getgenv().ESP do
                for _, obj in ipairs(espObjects) do if obj then obj:Destroy() end end
                espObjects = {}
                
                for _, item in ipairs(workspace:GetDescendants()) do
                    if item.Name == "Stronghold" or item.Name == "DiamondChest" then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = item:IsA("Model") and item or item.Parent
                        hl.FillColor = Color3.fromRGB(150, 0, 255)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Parent = CoreGui
                        table.insert(espObjects, hl)
                    end
                end
                task.wait(2)
            end
        end)
    else
        EspBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        EspStroke.Color = Color3.fromRGB(200, 200, 200)
        AddLog("ESP отключен.")
        for _, obj in ipairs(espObjects) do if obj then obj:Destroy() end end
        espObjects = {}
    end
end)

-- 4. ПОИСК ПОД КАРТОЙ (С ПРОГРУЗКОЙ ЧАНКОВ)
ScanBtn.MouseButton1Click:Connect(function()
    if getgenv().ScanActive then return end
    getgenv().ScanActive = true
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then getgenv().ScanActive = false return end
    
    ScanBtn.Text = "СКАНИРУЮ..."
    ScanBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    AddLog("Ухожу под землю. Гружу чанки...")
    
    task.spawn(function()
        -- Отключаем коллизию и гравитацию на время скана
        if not getgenv().Noclip then
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(0, 9e9, 0)
            bp.Position = hrp.Position
            bp.Name = "ScanHold"
            bp.Parent = hrp
        end

        local startPos = hrp.Position
        local depthY = -40 -- Высота под картой
        local radius = 0
        local angle = 0
        
        -- Спускаемся
        hrp.CFrame = CFrame.new(startPos.X, depthY, startPos.Z)
        task.wait(1)
        
        local foundTarget = nil
        
        -- Спиралевидный полет для загрузки карты
        while getgenv().ScanActive and radius < 2500 do
            local x = startPos.X + math.cos(math.rad(angle)) * radius
            local z = startPos.Z + math.sin(math.rad(angle)) * radius
            
            -- ПЛАВНО перемещаемся, чтобы сервер отдавал чанки
            if hrp:FindFirstChild("ScanHold") then
                hrp.ScanHold.Position = Vector3.new(x, depthY, z)
            end
            hrp.CFrame = CFrame.new(x, depthY, z)
            
            -- Ищем Стронгхолд
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
                    foundTarget = obj
                    break
                end
            end
            
            if foundTarget then break end
            
            angle = angle + 45
            if angle >= 360 then
                angle = 0
                radius = radius + 80 -- Расширяем радиус поиска
                AddLog("Радиус скана: " .. tostring(radius) .. "м")
            end
            task.wait(0.1) -- Время на прогрузку
        end
        
        if foundTarget then
            AddLog("СТРОНГХОЛД НАЙДЕН! Зависаю под ним.")
            local tPos = foundTarget:IsA("Model") and foundTarget:GetPivot() or foundTarget.CFrame
            hrp.CFrame = tPos * CFrame.new(0, -15, 0) -- Встаем ровно ПОД сундуком
            if hrp:FindFirstChild("ScanHold") then hrp.ScanHold.Position = hrp.Position end
            AddLog("Врубай Noclip и плыви вверх за алмазами!")
        else
            AddLog("Стронгхолд не найден на сервере.", true)
            hrp.CFrame = CFrame.new(startPos)
        end
        
        getgenv().ScanActive = false
        ScanBtn.Text = "4. ИСКАТЬ СТРОНГХОЛД ПОД КАРТОЙ"
        ScanBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    getgenv().ScanActive = false
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("ScanHold") then hrp.ScanHold:Destroy() end
    AddLog("Аварийная остановка выполнена.", true)
end)
