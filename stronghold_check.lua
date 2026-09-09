local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local uiName = "NeonSecHub_99Nights"
getgenv().AutoHopEnabled = getgenv().AutoHopEnabled or false

-- ИНИЦИАЛИЗАЦИЯ КЕША СЕРВЕРОВ!
getgenv().ServerCache = getgenv().ServerCache or {}
getgenv().NextCursor = getgenv().NextCursor or ""

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 360)
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

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "★ NEON SEC-PANEL ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = Main

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
LogText.Text = "[SYS] Ядро: CACHE-MEMORY 1.0"
LogText.Parent = LogFrame

local function AddLog(msg, isErr)
    LogText.Text = string.format("[%s] %s\n", os.date("%X"), msg) .. LogText.Text
    if isErr then Title.TextColor3 = Color3.fromRGB(255, 70, 70)
    else Title.TextColor3 = Color3.fromRGB(255, 255, 255) end
end

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
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play() end)
    return btn, stroke
end

local CheckBtn, _ = CreateNeonButton("CheckBtn", "1. Проверить Стронгхолд", 105, Color3.fromRGB(255, 255, 255))
local TpBtn, _ = CreateNeonButton("TpBtn", "2. Телепорт к сундуку", 150, Color3.fromRGB(255, 255, 255))
local AutoHopBtn, HopStroke = CreateNeonButton("AutoHopBtn", getgenv().AutoHopEnabled and "3. Авто-Хоп: ВКЛ" or "3. Авто-Хоп: ВЫКЛ", 195, getgenv().AutoHopEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 70, 100))
local ReserveHopBtn, _ = CreateNeonButton("ReserveHopBtn", "РЕЗЕРВНЫЙ ХОП (БЕЗ API)", 240, Color3.fromRGB(255, 150, 50))
local DumpBtn, _ = CreateNeonButton("DumpBtn", "Копировать лог ошибок", 285, Color3.fromRGB(200, 150, 255))

local function CheckStronghold()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then return obj end
    end
    return nil
end

local executor_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)

-- ФУНКЦИЯ ЗАГРУЗКИ КЕША СЕРВЕРОВ (ВЫЗЫВАЕТСЯ РЕДКО!)
local function PopulateServerCache()
    if not executor_request then return false, "No Request Func" end
    
    AddLog("СКАЧИВАЮ БАЗУ СЕРВЕРОВ...")
    SetProgress(0.3)
    
    local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc&limit=100"
    if getgenv().NextCursor ~= "" then url = url .. "&cursor=" .. getgenv().NextCursor end
    
    local headers = {
        ["User-Agent"] = "Roblox/WinInet",
        ["Origin"] = "https://www.roblox.com",
        ["Referer"] = "https://www.roblox.com/",
        ["Accept"] = "application/json"
    }
    
    local success, res = pcall(function()
        return executor_request({ Url = url, Method = "GET", Headers = headers })
    end)
    
    if success and res and res.StatusCode == 200 then
        local decOk, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if decOk and data and data.data then
            -- Очищаем старый кеш и заливаем новый
            getgenv().ServerCache = {}
            for _, srv in ipairs(data.data) do
                if srv.id ~= game.JobId and srv.playing and srv.maxPlayers and (srv.playing < srv.maxPlayers) then
                    table.insert(getgenv().ServerCache, srv.id)
                end
            end
            getgenv().NextCursor = data.nextPageCursor or ""
            AddLog("В кеше " .. tostring(#getgenv().ServerCache) .. " серверов!")
            return true, "OK"
        end
    elseif success and res and res.StatusCode == 429 then
        return false, "429 RateLimit! Жди 30 сек!"
    end
    
    return false, "HTTP " .. tostring(res and res.StatusCode or "nil")
end

local isHopping = false
local function ServerHop()
    if isHopping then return end
    isHopping = true
    SetProgress(0.5)
    
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

    -- ЕСЛИ КЕШ ПУСТ - КАЧАЕМ СПИСОК
    if #getgenv().ServerCache == 0 then
        local ok, err = PopulateServerCache()
        if not ok then
            AddLog("ОШИБКА АПИ: " .. tostring(err), true)
            isHopping = false
            SetProgress(0)
            if string.find(err, "429") then
                AddLog("ОТКЛЮЧИ АВТОХОП И ЖДИ 1 МИНУТУ!", true)
                getgenv().AutoHopEnabled = false
                AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
                AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ (БЛОК)"
            end
            return
        end
    end

    -- БЕРЕМ ПЕРВЫЙ СЕРВЕР ИЗ КЕША
    if #getgenv().ServerCache > 0 then
        local targetJobId = table.remove(getgenv().ServerCache, 1) -- Достаем и удаляем из кеша
        AddLog("Прыжок из кеша! Осталось: " .. tostring(#getgenv().ServerCache))
        SetProgress(1.0)
        
        local tpOk, tpErr = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
        end)
        
        if not tpOk then
            AddLog("Ошибка ТП. Беру следующий...", true)
            isHopping = false
            task.wait(1)
            if getgenv().AutoHopEnabled then ServerHop() end
        end
    else
        AddLog("Кеш пуст после загрузки?", true)
        isHopping = false
    end
end

-- КНОПКИ
CheckBtn.MouseButton1Click:Connect(function()
    AddLog("Проверка карты...")
    local target = CheckStronghold()
    if target then
        CheckBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        CheckBtn.Text = "★ СТРОНГХОЛД НАЙДЕН!"
        AddLog("Найдено!")
    else
        CheckBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
        CheckBtn.Text = "НЕТ НА КАРТЕ"
        AddLog("Отсутствует.")
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
            if pos then hrp.CFrame = pos AddLog("Успешный ТП!") end
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
        AddLog("Авто-хоп включен")
        task.spawn(function()
            local target = CheckStronghold()
            if target then
                getgenv().AutoHopEnabled = false
                AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
                HopStroke.Color = Color3.fromRGB(255, 70, 100)
                AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ"
            else
                ServerHop()
            end
        end)
    else
        AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
        HopStroke.Color = Color3.fromRGB(255, 70, 100)
        AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ"
        isHopping = false
        AddLog("Авто-хоп отключен")
    end
end)

-- ЖЕЛЕЗОБЕТОННЫЙ РЕЗЕРВНЫЙ ХОП (БЕЗ HTTP API)
ReserveHopBtn.MouseButton1Click:Connect(function()
    AddLog("ЗАПУСК СЛЕПОГО ТЕЛЕПОРТА!")
    ReserveHopBtn.Text = "ВЫПОЛНЯЮ ТП..."
    ReserveHopBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    
    local q_on_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if q_on_tp then
        pcall(function()
            q_on_tp([[
                getgenv().AutoHopEnabled = false
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/nobeggars/bp/refs/heads/main/stronghold_check.lua'))()
            ]])
        end)
    end
    
    -- Слепой ТП использует внутренний механизм матчмейкинга Роблокса
    local success, err = pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    
    if not success then
        AddLog("Слепой ТП упал: " .. tostring(err), true)
        ReserveHopBtn.Text = "ОШИБКА ТП!"
    end
    task.wait(2)
    ReserveHopBtn.Text = "РЕЗЕРВНЫЙ ХОП (БЕЗ API)"
    ReserveHopBtn.TextColor3 = Color3.fromRGB(255, 150, 50)
end)

DumpBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(LogText.Text) AddLog("Лог скопирован!") end
end)

if getgenv().AutoHopEnabled then
    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        task.wait(3)
        local target = CheckStronghold()
        if target then
            getgenv().AutoHopEnabled = false
            AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
            HopStroke.Color = Color3.fromRGB(255, 70, 100)
            AutoHopBtn.Text = "3. Авто-Хоп: ВЫКЛ"
            AddLog("СТРОНГХОЛД НАЙДЕН!")
        else
            ServerHop()
        end
    end)
end

