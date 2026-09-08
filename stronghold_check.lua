local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Настройки
local uiName = "AndroidSecPanel"
getgenv().AutoHopEnabled = getgenv().AutoHopEnabled or false -- Глобальная переменная для авто-хопа

-- Удаление старого UI
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

-- Создаем интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главная панель (сделал чуть выше для новой кнопки)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 190)
Frame.Position = UDim2.new(0.5, -125, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
Frame.Active = true
Frame.Draggable = true 
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
CheckBtn.Text = "1. Проверить сервер"
CheckBtn.Font = Enum.Font.Code
CheckBtn.TextSize = 14
CheckBtn.Parent = Frame

-- Кнопка 2: Телепорт
local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1, -20, 0, 40)
TpBtn.Position = UDim2.new(0, 10, 0, 90)
TpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Text = "2. Телепорт (ESP)"
TpBtn.Font = Enum.Font.Code
TpBtn.TextSize = 14
TpBtn.Parent = Frame

-- Кнопка 3: Авто-Хоп
local AutoHopBtn = Instance.new("TextButton")
AutoHopBtn.Size = UDim2.new(1, -20, 0, 40)
AutoHopBtn.Position = UDim2.new(0, 10, 0, 140)
AutoHopBtn.BackgroundColor3 = getgenv().AutoHopEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
AutoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoHopBtn.Text = getgenv().AutoHopEnabled and "3. Авто-Хоп: ВКЛ" or "3. Авто-Хоп: ВЫКЛ"
AutoHopBtn.Font = Enum.Font.Code
AutoHopBtn.TextSize = 14
AutoHopBtn.Parent = Frame

-- ФУНКЦИИ
local function CheckStronghold()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
            return obj
        end
    end
    return nil
end

local function ServerHop()
    Title.Text = " Ищу новый сервер..."
    local PlaceId = game.PlaceId
    local serversApi = "https://games.roblox.com/v1/games/"..tostring(PlaceId).."/servers/Public?sortOrder=Desc&limit=100"
    
    local success, result = pcall(function()
        return game:HttpGet(serversApi)
    end)

    if success then
        local data = HttpService:JSONDecode(result)
        if data and data.data then
            for _, server in ipairs(data.data) do
                -- Ищем сервер, где есть место и это не текущий сервер
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    -- Заставляем скрипт загрузиться снова после телепорта
                    local q_on_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or function() end
                    pcall(function()
                        q_on_tp([[
                            getgenv().AutoHopEnabled = true
                            task.wait(2) -- Ждем прогрузки
                            loadstring(game:HttpGet('https://raw.githubusercontent.com/nobeggars/bp/refs/heads/main/stronghold_check.lua'))()
                        ]])
                    end)
                    
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end
end

-- ЛОГИКА КНОПОК
CheckBtn.MouseButton1Click:Connect(function()
    local target = CheckStronghold()
    if target then
        CheckBtn.Text = "НАЙДЕН!"
        CheckBtn.TextColor3 = Color3.fromRGB(50, 255, 50)
    else
        CheckBtn.Text = "НЕТ НА СЕРВЕРЕ"
        CheckBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
    task.wait(2)
    CheckBtn.Text = "1. Проверить сервер"
    CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

TpBtn.MouseButton1Click:Connect(function()
    local target = CheckStronghold()
    if target then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = target:IsA("Model") and target.PrimaryPart and target.PrimaryPart.CFrame or target.CFrame
            if pos then char.HumanoidRootPart.CFrame = pos end
        end
    end
end)

AutoHopBtn.MouseButton1Click:Connect(function()
    getgenv().AutoHopEnabled = not getgenv().AutoHopEnabled
    if getgenv().AutoHopEnabled then
        AutoHopBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        AutoHopBtn.Text = "3. Авто-Хоп: ВКЛ"
        -- Запускаем цикл проверки
        task.spawn(function()
            local target = CheckStronghold()
            if target then
                -- Если уже тут, выключаем хоп
                getgenv().AutoHopEnabled = false
                AutoHopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
                AutoHopBtn.Text = "НАЙДЕН! ХОП ОСТАНОВЛЕН"
                Title.Text = " Стронгхолд найден!"
            else
                ServerHop()
            end
        end)
    else
        AutoHopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ"
        Title.Text = " Mobile Sec-Panel | 99 Nights"
    end
end)

-- АВТО-ЗАПУСК ПРИ ПРЫЖКЕ (Если скрипт прогрузился с включенным AutoHopEnabled)
if getgenv().AutoHopEnabled then
    task.spawn(function()
        task.wait(1)
        local target = CheckStronghold()
        if target then
            getgenv().AutoHopEnabled = false
            AutoHopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            AutoHopBtn.Text = "НАЙДЕН! ХОП ОСТАНОВЛЕН"
            
            -- Опционально: можно сразу телепортироваться к нему при заходе!
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                local pos = target:IsA("Model") and target.PrimaryPart and target.PrimaryPart.CFrame or target.CFrame
                if pos then hrp.CFrame = pos end
            end
        else
            -- Если не найден, снова прыгаем
            ServerHop()
        end
    end)
end

