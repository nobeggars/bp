local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local uiName = "VoidwareStyle_AutoFarm"

getgenv().GodMode = false
getgenv().AutoLoot = false
getgenv().AutoStronghold = false

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный Фрейм (Стиль Voidware)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 280)
Main.Position = UDim2.new(0.5, -210, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 15) -- Темно-изумрудный/черный фон
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(30, 45, 40) -- Легкий бордер

-- Левая панель (Сайдбар)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- Линия разделителя (чтобы скрыть скругление справа у сайдбара)
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 10, 1, 0)
Divider.Position = UDim2.new(1, -5, 0, 0)
Divider.BackgroundColor3 = Color3.fromRGB(16, 20, 20)
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Text = "Voidware\nFarm Edition"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

-- Динамическая полоса загрузки в сайдбаре
local LoadingBg = Instance.new("Frame")
LoadingBg.Size = UDim2.new(1, -20, 0, 4)
LoadingBg.Position = UDim2.new(0, 10, 0, 60)
LoadingBg.BackgroundColor3 = Color3.fromRGB(25, 35, 30)
LoadingBg.Parent = Sidebar
Instance.new("UICorner", LoadingBg).CornerRadius = UDim.new(1, 0)

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 200, 120) -- Красивый зеленый акцент
LoadingBar.Parent = LoadingBg
Instance.new("UICorner", LoadingBar).CornerRadius = UDim.new(1, 0)

local function PulseLoader()
    TweenService:Create(LoadingBar, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()
end
PulseLoader()

-- Консоль Логов
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
LogText.Text = "> Загрузка ядра...\n> Voidware UI готов."
LogText.Parent = LogFrame

local function AddLog(msg, isErr)
    local color = isErr and '<font color="rgb(255,80,80)">' or '<font color="rgb(0,200,120)">'
    LogText.RichText = true
    LogText.Text = string.format("%s[%s] %s</font>\n", color, os.date("%X"), msg) .. LogText.Text
end

-- Кнопка копирования логов
local CopyLogBtn = Instance.new("TextButton")
CopyLogBtn.Size = UDim2.new(1, -20, 0, 30)
CopyLogBtn.Position = UDim2.new(0, 10, 1, -40)
CopyLogBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 25)
CopyLogBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CopyLogBtn.Text = "Copy Logs"
CopyLogBtn.Font = Enum.Font.GothamMedium
CopyLogBtn.TextSize = 11
CopyLogBtn.AutoButtonColor = false
CopyLogBtn.Parent = Sidebar
Instance.new("UICorner", CopyLogBtn).CornerRadius = UDim.new(0, 6)

CopyLogBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        -- Очищаем от HTML тегов для буфера
        local cleanLogs = string.gsub(LogText.Text, "<[^>]->", "")
        setclipboard(cleanLogs)
        AddLog("Логи скопированы!")
    else
        AddLog("setclipboard не найден", true)
    end
end)

-- Контейнер кнопок (Справа)
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
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(12, 14, 15) -- Прозрачный фон
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = "    " .. text -- Отступ для красоты
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Content
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 4, 0, 14)
    Indicator.Position = UDim2.new(0, 0, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 45, 45)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 22, 25)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(12, 14, 15)}):Play() end)
    
    return btn, Indicator
end

local GodModeBtn, GodInd = CreateVoidToggle("GodMode", "Entity Godmode (No Hitbox)")
local FarmBtn, FarmInd = CreateVoidToggle("Farm", "Auto Loot & Sort Base")
local StrongholdBtn, StrongholdInd = CreateVoidToggle("Stronghold", "Force Hack Stronghold")

-- БЕЗОПАСНЫЙ КЛИКЕР (ДЛЯ МОБИЛОК)
local function SafeFirePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if fireproximityprompt then
        fireproximityprompt(prompt, 1)
        fireproximityprompt(prompt, 0)
    else
        -- Ручное удержание для всратых инжекторов
        local hold = prompt.HoldDuration > 0 and prompt.HoldDuration or 0.1
        prompt:InputBegan()
        task.wait(hold + 0.1)
        prompt:InputEnded()
    end
end

-- 1. РЕЖИМ БОГА
local GodConnection
GodModeBtn.MouseButton1Click:Connect(function()
    getgenv().GodMode = not getgenv().GodMode
    if getgenv().GodMode then
        TweenService:Create(GodInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Годмод включен.")
        GodConnection = RunService.Stepped:Connect(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    obj:Destroy()
                end
            end
        end)
    else
        TweenService:Create(GodInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Годмод выключен.")
        if GodConnection then GodConnection:Disconnect() end
    end
end)

-- 2. АВТОСБОР И СОРТИРОВКА (ИСПРАВЛЕННОЕ)
local function FindNearestBase(hrp, typeStr)
    local bestObj = nil
    local shortest = math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = string.lower(obj.Name)
            local isMatch = false
            
            if typeStr == "wood" and (string.find(name, "fire") or string.find(name, "camp") or string.find(name, "base")) then isMatch = true end
            if typeStr == "metal" and (string.find(name, "crush") or string.find(name, "grind") or string.find(name, "forge")) then isMatch = true end
            
            if isMatch then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    local dist = (obj:GetPivot().Position - hrp.Position).Magnitude
                    if dist < shortest then
                        shortest = dist
                        bestObj = {obj, prompt}
                    end
                end
            end
        end
    end
    return bestObj
end

FarmBtn.MouseButton1Click:Connect(function()
    getgenv().AutoLoot = not getgenv().AutoLoot
    if getgenv().AutoLoot then
        TweenService:Create(FarmInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)}):Play()
        AddLog("Пылесос запущен!")
        
        task.spawn(function()
            while getgenv().AutoLoot do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(1) continue end
                
                local foundAny = false
                for _, item in ipairs(workspace:GetDescendants()) do
                    if not getgenv().AutoLoot then break end
                    
                    local isWood = string.find(string.lower(item.Name), "wood") or string.find(string.lower(item.Name), "log") or string.find(string.lower(item.Name), "gas")
                    local isMetal = string.find(string.lower(item.Name), "metal") or string.find(string.lower(item.Name), "scrap") or string.find(string.lower(item.Name), "iron")
                    
                    if isWood or isMetal then
                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            foundAny = true
                            local oldPos = hrp.CFrame
                            local itemPos = item:IsA("Model") and item:GetPivot() or item.CFrame
                            
                            -- Прыгаем ЧУТЬ ВЫШЕ предмета, чтобы не застрять
                            hrp.CFrame = itemPos * CFrame.new(0, 3, 0)
                            AddLog("ТП к " .. item.Name)
                            task.wait(0.5) -- ДАЕМ ПРОГРУЗИТЬСЯ ИГРЕ (ВАЖНО!)
                            
                            SafeFirePrompt(prompt)
                            task.wait(0.5)
                            
                            -- Поиск базы
                            local baseData = FindNearestBase(hrp, isWood and "wood" or "metal")
                            if baseData then
                                hrp.CFrame = baseData[1]:GetPivot() * CFrame.new(0, 3, 0)
                                AddLog("Скидываю лут в базу...")
                                task.wait(0.5)
                                SafeFirePrompt(baseData[2])
                            else
                                AddLog("База для сброса НЕ НАЙДЕНА!", true)
                            end
                            
                            -- Возврат
                            hrp.CFrame = oldPos
                            task.wait(0.5)
                        end
                    end
                end
                
                if not foundAny then
                    AddLog("Нет лута. Жду 3с...")
                    task.wait(3)
                end
            end
        end)
    else
        TweenService:Create(FarmInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Пылесос выключен.")
    end
end)

-- 3. ВЗЛОМ СТРОНГХОЛДА
StrongholdBtn.MouseButton1Click:Connect(function()
    getgenv().AutoStronghold = not getgenv().AutoStronghold
    if getgenv().AutoStronghold then
        TweenService:Create(StrongholdInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 100)}):Play()
        AddLog("ВЗЛОМ АКТИВИРОВАН!")
        
        task.spawn(function()
            while getgenv().AutoStronghold do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local targetPrompt = nil
                    local targetCFrame = nil
                    
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
                            targetPrompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            targetCFrame = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                            break
                        end
                    end
                    
                    if targetPrompt and targetCFrame then
                        hrp.CFrame = targetCFrame * CFrame.new(0, 2, 0)
                        task.wait(0.3)
                        SafeFirePrompt(targetPrompt)
                        AddLog("Граблю сундук...")
                    else
                        AddLog("Сундук не найден.")
                    end
                end
                task.wait(1.5)
            end
        end)
    else
        TweenService:Create(StrongholdInd, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 45)}):Play()
        AddLog("Взлом отключен.")
    end
end)

