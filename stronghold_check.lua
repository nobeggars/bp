local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local uiName = "NeonSecHub_99Nights"
getgenv().AutoHopEnabled = getgenv().AutoHopEnabled or false

-- Очистка старого UI
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный Неоновый Фрейм
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 320)
Main.Position = UDim2.new(0.5, -140, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 0, 127)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "★ NEON SEC-PANEL ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = Main

-- Анимированная полоса загрузки
local LoadingBg = Instance.new("Frame")
LoadingBg.Size = UDim2.new(1, -20, 0, 4)
LoadingBg.Position = UDim2.new(0, 10, 0, 35)
LoadingBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
LoadingBg.BorderSizePixel = 0
LoadingBg.Parent = Main
Instance.new("UICorner", LoadingBg).CornerRadius = UDim.new(1, 0)

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingBg
Instance.new("UICorner", LoadingBar).CornerRadius = UDim.new(1, 0)

local function SetProgress(ratio)
    TweenService:Create(LoadingBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0)
    }):Play()
end

-- Лог-консоль
local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 0, 50)
LogFrame.Position = UDim2.new(0, 10, 0, 45)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 2
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.Parent = Main
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 6)

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -10, 1, 0)
LogText.Position = UDim2.new(0, 5, 0, 0)
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(0, 255, 180)
LogText.Font = Enum.Font.Code
LogText.TextSize = 11
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Text = "[SYS] Ядро переписано. Готов..."
LogText.Parent = LogFrame

local function AddLog(msg, isErr)
    local col = isErr and "FF4444" or "00FFC8"
    LogText.Text = string.format("[%s] %s\n", os.date("%X"), msg) .. LogText.Text
    if isErr then
        Title.TextColor3 = Color3.fromRGB(255, 70, 70)
    else
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Кнопки
local function CreateNeonButton(name, text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
    end)
    return btn, stroke
end

local CheckBtn, _ = CreateNeonButton("CheckBtn", "1. Проверить Стронгхолд", 105, Color3.fromRGB(255, 255, 255))
local TpBtn, _ = CreateNeonButton("TpBtn", "2. Телепорт к сундуку", 150, Color3.fromRGB(255, 255, 255))
local AutoHopBtn, HopStroke = CreateNeonButton("AutoHopBtn", getgenv().AutoHopEnabled and "3. Авто-Хоп: ВКЛ" or "3. Авто-Хоп: ВЫКЛ", 195, getgenv().AutoHopEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 70, 100))
local DumpBtn, _ = CreateNeonButton("DumpBtn", "4. Копировать лог ошибок", 240, Color3.fromRGB(200, 150, 255))

-- ФУНКЦИЯ ПОИСКА
local function CheckStronghold()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
            return obj
        end
    end
    return nil
end

-- УНИВЕРСАЛЬНЫЙ HTTP РЕКВЕСТЕР
local executor_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)

local function FetchServers(url)
    if executor_request then
        local success, res = pcall(function()
            return executor_request({
                Url = url,
                Method = "GET"
            })
        end)
        if success and res then
            if res.StatusCode == 200 then
                return true, res.Body
            else
                return false, "HTTP " .. tostring(res.StatusCode)
            end
        else
            return false, "Request throw: " .. tostring(res)
        end
    else
        -- Фоллбэк только если вообще нет функции request (крайний случай)
        local success, res = pcall(function() return game:HttpGet(url) end)
        if success then return true, res else return false, "HttpGet err: " .. tostring(res) end
    end
end

-- АВТО-ХОП БЕЗ КРИВЫХ ФОЛЛБЭКОВ
local isHopping = false
local function ServerHop()
    if isHopping then return end
    isHopping = true
    SetProgress(0.2)
    AddLog("Старт поиска (Request API)...")

    local placeId = game.PlaceId
    local currentJob = game.JobId
    local cursor = ""
    local found = false

    local q_on_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if q_on_tp then
        pcall(function()
            q_on_tp([[
                getgenv().AutoHopEnabled = true
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/nobeggars/bp/refs/heads/main/stronghold_check.lua'))()
            ]])
        end)
    end

    local endpoints = {
        "https://games.roproxy.com/v1/games/%s/servers/Public?limit=100",
        "https://games.roblox.com/v1/games/%s/servers/Public?limit=100"
    }

    for attempt = 1, 3 do
        if found then break end
        
        for idx, baseUri in ipairs(endpoints) do
            AddLog("Чек Endpoint #" .. tostring(idx))
            SetProgress(0.4 + (idx * 0.1))

            local uri = string.format(baseUri, tostring(placeId))
            local reqOk, raw = FetchServers(uri)

            if not reqOk then
                AddLog("Req Err: " .. tostring(raw):sub(1, 35), true)
            elseif raw and raw ~= "" then
                local decOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if not decOk then
                    AddLog("JSON Parse Err", true)
                elseif data and data.data then
                    for _, srv in ipairs(data.data) do
                        if srv.id ~= currentJob and srv.playing and srv.maxPlayers and (srv.playing < srv.maxPlayers) then
                            AddLog("Сервер найден! ТП...")
                            SetProgress(1.0)
                            local tpOk, tpErr = pcall(function()
                                TeleportService:TeleportToPlaceInstance(placeId, srv.id, LocalPlayer)
                            end)
                            if tpOk then
                                found = true
                                return
                            else
                                AddLog("TP 773/Err: " .. tostring(tpErr):sub(1, 30), true)
                            end
                        end
                    end
                elseif data and data.errors then
                    AddLog("API Err: " .. tostring(data.errors[1] and data.errors[1].message or "Unknown"), true)
                end
            end
            task.wait(1.5)
        end
    end

    if not found then
        AddLog("Сервер не найден! Ждем 5с...", true)
        SetProgress(0)
        isHopping = false
        task.wait(5)
        -- Ретрай нормального поиска, без кривого Teleport(placeId)!
        if getgenv().AutoHopEnabled then
            ServerHop()
        end
    end
end

-- ОБРАБОТЧИКИ КНОПОК
CheckBtn.MouseButton1Click:Connect(function()
    AddLog("Проверка карты...")
    local target = CheckStronghold()
    if target then
        CheckBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        CheckBtn.Text = "★ СТРОНГХОЛД НАЙДЕН!"
        AddLog("Стронгхолд обнаружен!")
    else
        CheckBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
        CheckBtn.Text = "НЕТ НА КАРТЕ"
        AddLog("Стронгхолд отсутствует.")
    end
    task.wait(2)
    CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheckBtn.Text = "1. Проверить Стронгхолд"
end)

TpBtn.MouseButton1Click:Connect(function()
    local target = CheckStronghold()
    if target then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot()) or target.CFrame
            if pos then 
                hrp.CFrame = pos 
                AddLog("Успешный ТП к сундуку!")
            end
        end
    else
        AddLog("Не к чему ТПшиться!", true)
    end
end)

AutoHopBtn.MouseButton1Click:Connect(function()
    getgenv().AutoHopEnabled = not getgenv().AutoHopEnabled
    if getgenv().AutoHopEnabled then
        AutoHopBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        HopStroke.Color = Color3.fromRGB(0, 255, 150)
        AutoHopBtn.Text = "3. Авто-Хоп: ВКЛ"
        AddLog("Авто-хоп активирован")
        task.spawn(function()
            local target = CheckStronghold()
            if target then
                getgenv().AutoHopEnabled = false
                AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
                HopStroke.Color = Color3.fromRGB(255, 70, 100)
                AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ"
                AddLog("Найдено на этом сервере!")
            else
                ServerHop()
            end
        end)
    else
        AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
        HopStroke.Color = Color3.fromRGB(255, 70, 100)
        AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ"
        SetProgress(0)
        isHopping = false
        AddLog("Авто-хоп отключен")
    end
end)

DumpBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(LogText.Text)
        AddLog("Логи скопированы в буфер!")
    else
        AddLog("Clipboard не поддерживается", true)
    end
end)

if getgenv().AutoHopEnabled then
    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        SetProgress(0.5)
        AddLog("Загрузка мира... ждем 4с")
        task.wait(4)
        local target = CheckStronghold()
        if target then
            getgenv().AutoHopEnabled = false
            AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
            HopStroke.Color = Color3.fromRGB(255, 70, 100)
            AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ"
            AddLog("СТРОНГХОЛД НАЙДЕН!")
            SetProgress(1.0)
        else
            ServerHop()
        end
    end)
end
