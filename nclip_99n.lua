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
getgenv().FlySpeed = 50

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный Фрейм (Стиль Voidware)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 300)
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

-- Сайдбар
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

local LoadingBg = Instance.new("Frame")
LoadingBg.Size = UDim2.new(1, -20, 0, 4)
LoadingBg.Position = UDim2.new(0, 10, 0, 60)
LoadingBg.BackgroundColor3 = Color3.fromRGB(25, 35, 30)
LoadingBg.Parent = Sidebar
Instance.new("UICorner", LoadingBg).CornerRadius = UDim.new(1, 0)

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
LoadingBar.Parent = LoadingBg
Instance.new("UICorner", LoadingBar).CornerRadius = UDim.new(1, 0)

TweenService:Create(LoadingBar, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Size = UDim2.new(1, 0, 1, 0)
}):Play()

-- Консоль
local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 1, -140)
LogFrame.Position = UDim2.new(0, 10, 0, 75)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 12)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 1
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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
LogText.Text = "> Загрузка GhostWare...\n> Готов к обходу."
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
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(12, 14, 15)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = "    " .. text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Content
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 4, 0, 20)
    Indicator.Position = UDim2.new(0, 0, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 45, 45)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 22, 25)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(12, 14, 15)}):Play() end)
    
    return btn, Indicator
end

local AntiTpBtn, AntiTpInd = CreateVoidToggle("AntiTP", "1. Anti-TP & Barrier Bypass")
local NoclipBtn, NoclipInd = CreateVoidToggle("Noclip", "2. Fly & Noclip (Сквозь стены)")
local SearchBtn, SearchInd = CreateVoidToggle("Search", "3. Искать Стронгхолд ПОД картой")

-- 1. ANTI-TP (УДАЛЕНИЕ ТРИГГЕРОВ И БЛОК ТЕЛЕПОРТОВ)
local AntiTpConn
AntiTpBtn.MouseButton1Click:Connect(function()
    getgenv().AntiTP = not getgenv().AntiTP
    if getgenv().AntiTP then
        TweenService:Create(AntiTpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Анти-ТП включен. Удаляю барьеры...")
        
        -- Удаляем все зоны телепортации на карте
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj:Destroy()
            end
        end
        
        -- Жестко привязываем позицию, если игра пытается нас откинуть
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lastPos = hrp.Position
            AntiTpConn = RunService.Stepped:Connect(function()
                if not getgenv().Noclip and not getgenv().AutoUnderground then
                    -- Если нас телепортировало больше чем на 100 стадов за кадр без нашей команды - возвращаем
                    if (hrp.Position - lastPos).Magnitude > 100 then
                        hrp.CFrame = CFrame.new(lastPos)
                        AddLog("Заблокирована попытка телепортации!", true)
                    else
                        lastPos = hrp.Position
                    end
                end
            end)
        end
    else
        TweenService:Create(AntiTpInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Анти-ТП отключен.")
        if AntiTpConn then AntiTpConn:Disconnect() end
    end
end)

-- 2. FLY & NOCLIP
local FlyBody, FlyGyro, FlyConn, NoclipConn
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastCtrl = {f = 0, b = 0, l = 0, r = 0}
local speed = 0

-- Управление для мобилок (джойстик) и ПК
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    getgenv().Noclip = not getgenv().Noclip
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if getgenv().Noclip and hrp then
        TweenService:Create(NoclipInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Полет сквозь стены АКТИВЕН.")
        
        FlyBody = Instance.new("BodyVelocity")
        FlyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBody.Parent = hrp
        
        FlyGyro = Instance.new("BodyGyro")
        FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyGyro.P = 1000
        FlyGyro.Parent = hrp
        
        local bg = char:FindFirstChildWhichIsA("Humanoid")
        if bg then bg.PlatformStand = true end
        
        -- Логика полета
        FlyConn = RunService.RenderStepped:Connect(function()
            if char and hrp then
                -- Для мобилок берем вектор движения из Humanoid.MoveDirection, для ПК из кнопок
                local moveDir = bg.MoveDirection
                if moveDir.Magnitude > 0 then
                    FlyBody.Velocity = Camera.CFrame:VectorToWorldSpace(Vector3.new(ctrl.l + ctrl.r, 0, ctrl.f + ctrl.b)) * getgenv().FlySpeed
                    if ctrl.l == 0 and ctrl.r == 0 and ctrl.f == 0 and ctrl.b == 0 then
                        -- Мобильный джойстик
                        FlyBody.Velocity = Camera.CFrame.LookVector * (moveDir.Z * -getgenv().FlySpeed) + Camera.CFrame.RightVector * (moveDir.X * getgenv().FlySpeed)
                    end
                else
                    FlyBody.Velocity = Vector3.new(0, 0, 0)
                end
                FlyGyro.CFrame = Camera.CFrame
            end
        end)
        
        -- Отключаем коллизию (Сквозь стены)
        NoclipConn = RunService.Stepped:Connect(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
        
    else
        TweenService:Create(NoclipInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Полет отключен.")
        
        if FlyBody then FlyBody:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        if FlyConn then FlyConn:Disconnect() end
        if NoclipConn then NoclipConn:Disconnect() end
        
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)

-- 3. ПОИСК СТРОНГХОЛДА ПОД КАРТОЙ
SearchBtn.MouseButton1Click:Connect(function()
    getgenv().AutoUnderground = not getgenv().AutoUnderground
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if getgenv().AutoUnderground and hrp then
        TweenService:Create(SearchInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 100)}):Play()
        AddLog("Ищу Стронгхолд...")
        
        task.spawn(function()
            local target = nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
                    target = obj
                    break
                end
            end
            
            if target then
                local tPos = target:IsA("Model") and target:GetPivot() or target.CFrame
                AddLog("Нашел! Ухожу под землю...")
                
                -- Отключаем гравитацию, чтобы не упасть в бездну
                if not getgenv().Noclip then
                    local bp = Instance.new("BodyPosition")
                    bp.MaxForce = Vector3.new(0, 9e9, 0)
                    bp.Position = hrp.Position
                    bp.Name = "UndergroundHold"
                    bp.Parent = hrp
                end
                
                -- Телепорт прямо ПОД сундук (на 15 стадов ниже)
                hrp.CFrame = tPos * CFrame.new(0, -15, 0)
                AddLog("Ожидаю под сундуком. Включай Noclip и всплывай!")
            else
                AddLog("Стронгхолд не найден на карте!", true)
            end
            
            getgenv().AutoUnderground = false
            TweenService:Create(SearchInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        end)
    else
        getgenv().AutoUnderground = false
        TweenService:Create(SearchInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        if hrp and hrp:FindFirstChild("UndergroundHold") then hrp.UndergroundHold:Destroy() end
    end
end)

