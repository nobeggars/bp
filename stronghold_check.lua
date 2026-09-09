local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local uiName = "NeonSecHub_AutoFarm"

-- ГЛОБАЛЬНЫЕ ФЛАГИ
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

-- Главный Фрейм
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 380)
Main.Position = UDim2.new(0.5, -140, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 150) -- Неоновый зеленый (тема фарма)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "★ NEON AUTO-FARM ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = Main

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 0, 60)
LogFrame.Position = UDim2.new(0, 10, 0, 40)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 2
LogFrame.Parent = Main
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 6)

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -10, 1, 0)
LogText.Position = UDim2.new(0, 5, 0, 0)
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(0, 255, 150)
LogText.Font = Enum.Font.Code
LogText.TextSize = 11
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Text = "[SYS] Ядро Автофарма запущено..."
LogText.Parent = LogFrame

local function AddLog(msg)
    LogText.Text = string.format("[%s] %s\n", os.date("%X"), msg) .. LogText.Text
end

local function CreateToggleBtn(name, text, posY, color)
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

local GodModeBtn, GodStroke = CreateToggleBtn("GodMode", "1. РЕЖИМ БОГА: ВЫКЛ", 110, Color3.fromRGB(255, 70, 70))
local FarmBtn, FarmStroke = CreateToggleBtn("Farm", "2. АВТОСБОР + СОРТИРОВКА: ВЫКЛ", 155, Color3.fromRGB(255, 70, 70))
local StrongholdBtn, SHStroke = CreateToggleBtn("Stronghold", "3. ВЗЛОМ СТРОНГХОЛДА: ВЫКЛ", 200, Color3.fromRGB(255, 70, 70))

-- УНИВЕРСАЛЬНЫЙ КЛИКЕР PROXIMITY PROMPT
local function FirePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            -- Ручной обход для всратых инжекторов
            local oldHold = prompt.HoldDuration
            prompt.HoldDuration = 0
            prompt:InputBegan()
            task.wait()
            prompt:InputEnded()
            prompt.HoldDuration = oldHold
        end
    end
end

-- 1. РЕЖИМ БОГА (Анти-Хитбокс + Network Bypass)
local GodConnection
GodModeBtn.MouseButton1Click:Connect(function()
    getgenv().GodMode = not getgenv().GodMode
    if getgenv().GodMode then
        GodModeBtn.Text = "1. РЕЖИМ БОГА: ВКЛ"
        GodModeBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
        GodStroke.Color = Color3.fromRGB(0, 255, 200)
        AddLog("Режим Бога активирован! Мобы ослепли.")
        
        -- Цикл удаления урона от мобов
        GodConnection = RunService.Stepped:Connect(function()
            -- Удаляем TouchInterest у всех деталей кроме игрока
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    obj:Destroy()
                end
            end
        end)
    else
        GodModeBtn.Text = "1. РЕЖИМ БОГА: ВЫКЛ"
        GodModeBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
        GodStroke.Color = Color3.fromRGB(255, 70, 70)
        AddLog("Режим Бога отключен.")
        if GodConnection then GodConnection:Disconnect() end
    end
end)

-- 2. АВТО-СБОРКА И СОРТИРОВКА
local function GetNearestBaseObject(namePart)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(string.lower(obj.Name), namePart) then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then return obj, prompt end
        end
    end
    return nil, nil
end

FarmBtn.MouseButton1Click:Connect(function()
    getgenv().AutoLoot = not getgenv().AutoLoot
    if getgenv().AutoLoot then
        FarmBtn.Text = "2. АВТОСБОР + СОРТИРОВКА: ВКЛ"
        FarmBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
        FarmStroke.Color = Color3.fromRGB(0, 255, 200)
        AddLog("Авто-Пылесос запущен!")
        
        task.spawn(function()
            while getgenv().AutoLoot do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(1) continue end
                
                local foundItem = false
                
                -- Ищем лут по карте
                for _, item in ipairs(workspace:GetDescendants()) do
                    if not getgenv().AutoLoot then break end
                    if item:IsA("Model") or item:IsA("Tool") then
                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                        -- Списки лута
                        local isWoodOrGas = string.find(string.lower(item.Name), "wood") or string.find(string.lower(item.Name), "gas") or string.find(string.lower(item.Name), "log")
                        local isMetal = string.find(string.lower(item.Name), "metal") or string.find(string.lower(item.Name), "scrap") or string.find(string.lower(item.Name), "iron")
                        
                        if prompt and (isWoodOrGas or isMetal) then
                            foundItem = true
                            local oldPos = hrp.CFrame
                            
                            -- ТП к луту
                            local itemPos = item:IsA("Model") and (item.PrimaryPart and item.PrimaryPart.CFrame or item:GetPivot()) or item.CFrame
                            hrp.CFrame = itemPos
                            task.wait(0.2)
                            FirePrompt(prompt)
                            AddLog("Собрал: " .. item.Name)
                            task.wait(0.5)
                            
                            -- ТП к базе для сортировки
                            local targetBase, targetPrompt
                            if isWoodOrGas then
                                targetBase, targetPrompt = GetNearestBaseObject("fire") -- Костер
                            elseif isMetal then
                                targetBase, targetPrompt = GetNearestBaseObject("crush") -- Дробилка
                            end
                            
                            if targetBase and targetPrompt then
                                hrp.CFrame = targetBase:GetPivot()
                                task.wait(0.2)
                                FirePrompt(targetPrompt)
                                AddLog("Закинул " .. item.Name .. " в базу!")
                            end
                            
                            -- Возврат на место
                            hrp.CFrame = oldPos
                            task.wait(0.1)
                        end
                    end
                end
                
                if not foundItem then
                    AddLog("Нет предметов для сбора. Жду 2с...")
                    task.wait(2)
                end
            end
        end)
    else
        FarmBtn.Text = "2. АВТОСБОР + СОРТИРОВКА: ВЫКЛ"
        FarmBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
        FarmStroke.Color = Color3.fromRGB(255, 70, 70)
        AddLog("Авто-Пылесос остановлен.")
    end
end)

-- 3. ПРИНУДИТЕЛЬНЫЙ ВЗЛОМ СТРОНГХОЛДА
StrongholdBtn.MouseButton1Click:Connect(function()
    getgenv().AutoStronghold = not getgenv().AutoStronghold
    if getgenv().AutoStronghold then
        StrongholdBtn.Text = "3. ВЗЛОМ СТРОНГХОЛДА: ВКЛ"
        StrongholdBtn.TextColor3 = Color3.fromRGB(255, 0, 255)
        SHStroke.Color = Color3.fromRGB(255, 0, 255)
        AddLog("ИЩУ СУНДУКИ И АЛМАЗЫ...")
        
        task.spawn(function()
            while getgenv().AutoStronghold do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local target = nil
                    local prompt = nil
                    
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
                            target = obj
                            prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            break
                        end
                    end
                    
                    if target and prompt then
                        AddLog("ВЗЛОМ! Сосу алмазы...")
                        local pos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot()) or target.CFrame
                        -- Телепортируемся прямо внутрь сундука
                        hrp.CFrame = pos + Vector3.new(0, 1, 0) 
                        task.wait(0.1)
                        -- Спамим хук
                        FirePrompt(prompt)
                    else
                        AddLog("Стронгхолда пока нет...")
                    end
                end
                task.wait(1.5) -- Цикл взлома
            end
        end)
    else
        StrongholdBtn.Text = "3. ВЗЛОМ СТРОНГХОЛДА: ВЫКЛ"
        StrongholdBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
        SHStroke.Color = Color3.fromRGB(255, 70, 70)
        AddLog("Взлом отключен.")
    end
end)
