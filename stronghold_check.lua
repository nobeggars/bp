-- Защита от двойного запуска
local uiName = "AndroidSecPanel"
if game.CoreGui:FindFirstChild(uiName) then game.CoreGui[uiName]:Destroy() end
if game.Players.LocalPlayer.PlayerGui:FindFirstChild(uiName) then game.Players.LocalPlayer.PlayerGui[uiName]:Destroy() end

-- Создаем интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false

-- Обход для Android-экзекуторов (если CoreGui заблокирован)
local success = pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game.CoreGui
end)
if not success then
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Главная панель
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 140)
Frame.Position = UDim2.new(0.5, -125, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
Frame.Active = true
Frame.Draggable = true -- Можно таскать пальцем по экрану
Frame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = " Mobile Sec-Panel | 99 Nights"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- Кнопка 1: Проверка
local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(1, -20, 0, 40)
CheckBtn.Position = UDim2.new(0, 10, 0, 40)
CheckBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.Text = "1. Проверить Стронгхолд"
CheckBtn.Font = Enum.Font.Code
CheckBtn.TextSize = 14
CheckBtn.Parent = Frame

-- Кнопка 2: Телепорт
local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1, -20, 0, 40)
TpBtn.Position = UDim2.new(0, 10, 0, 90)
TpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Text = "2. Телепорт к нему (ESP)"
TpBtn.Font = Enum.Font.Code
TpBtn.TextSize = 14
TpBtn.Parent = Frame

-- Логика кнопок
CheckBtn.MouseButton1Click:Connect(function()
    local found = false
    -- Ищем сундук/стронгхолд
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
            found = true
            CheckBtn.Text = "НАЙДЕН В WORKSPACE!"
            CheckBtn.TextColor3 = Color3.fromRGB(50, 255, 50)
            task.wait(3)
            CheckBtn.Text = "1. Проверить Стронгхолд"
            CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            break
        end
    end
    if not found then
        CheckBtn.Text = "БЕЗОПАСНО (Не найден)"
        CheckBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(3)
        CheckBtn.Text = "1. Проверить Стронгхолд"
        CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

TpBtn.MouseButton1Click:Connect(function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.CFrame or obj.CFrame
                if pos then
                    char.HumanoidRootPart.CFrame = pos
                end
            end
            break
        end
    end
end)
