--[[
    NEON SEC-PANEL v3.0 — HYPER DESIGN
    Author: I.S.-1
    Functionality: Auto-Hop + Stronghold Looter + Campfire Igniter
    Design: Gradient, glow, smooth animations, inject loader
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ========== CONFIG ==========
local CONFIG = {
    MAX_PAGES = 15,
    HOP_DELAY = 2,
    CAMPFIRE_WAIT = 5,
    STRONGHOLD_KEYWORDS = {"Stronghold", "DiamondChest", "Chest", "Fortress"},
    CAMPFIRE_KEYWORDS = {"Campfire", "Fire", "Bonfire"},
}

-- ========== CLEANUP ==========
local uiName = "NeonSecHub_99Nights"
getgenv().AutoHopEnabled = getgenv().AutoHopEnabled or false
getgenv().ServerCache = getgenv().ServerCache or {}

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

-- ========== INJECT LOADER (SPLASH SCREEN) ==========
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "NeonLoader"
LoaderGui.ResetOnSpawn = false
LoaderGui.IgnoreGuiInset = true
pcall(function() LoaderGui.Parent = (gethui and gethui()) or CoreGui end)
if not LoaderGui.Parent then LoaderGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local LoaderBg = Instance.new("Frame")
LoaderBg.Size = UDim2.new(1, 0, 1, 0)
LoaderBg.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LoaderBg.BorderSizePixel = 0
LoaderBg.Parent = LoaderGui

local LoaderGradient = Instance.new("UIGradient")
LoaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 5, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 0, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10)),
}
LoaderGradient.Rotation = 45
LoaderGradient.Parent = LoaderBg

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 60)
LoaderTitle.Position = UDim2.new(0, 0, 0.4, 0)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "★ NEON SEC-PANEL ★"
LoaderTitle.TextColor3 = Color3.fromRGB(255, 0, 150)
LoaderTitle.Font = Enum.Font.GothamBlack
LoaderTitle.TextSize = 36
LoaderTitle.TextTransparency = 1
LoaderTitle.Parent = LoaderBg

local LoaderSub = Instance.new("TextLabel")
LoaderSub.Size = UDim2.new(1, 0, 0, 25)
LoaderSub.Position = UDim2.new(0, 0, 0.4, 60)
LoaderSub.BackgroundTransparency = 1
LoaderSub.Text = "v3.0 HYPER EDITION"
LoaderSub.TextColor3 = Color3.fromRGB(0, 255, 200)
LoaderSub.Font = Enum.Font.GothamMedium
LoaderSub.TextSize = 14
LoaderSub.TextTransparency = 1
LoaderSub.Parent = LoaderBg

local LoaderBarBg = Instance.new("Frame")
LoaderBarBg.Size = UDim2.new(0, 400, 0, 6)
LoaderBarBg.Position = UDim2.new(0.5, -200, 0.5, 80)
LoaderBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
LoaderBarBg.BorderSizePixel = 0
LoaderBarBg.Parent = LoaderBg
Instance.new("UICorner", LoaderBarBg).CornerRadius = UDim.new(1, 0)

local LoaderBar = Instance.new("Frame")
LoaderBar.Size = UDim2.new(0, 0, 1, 0)
LoaderBar.BackgroundColor3 = Color3.fromRGB(255, 0, 150)
LoaderBar.BorderSizePixel = 0
LoaderBar.Parent = LoaderBarBg
Instance.new("UICorner", LoaderBar).CornerRadius = UDim.new(1, 0)

local LoaderBarGlow = Instance.new("UIGradient")
LoaderBarGlow.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150)),
}
LoaderBarGlow.Parent = LoaderBar

-- Animate loader
task.spawn(function()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(0.3)
    TweenService:Create(LoaderSub, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(0.5)
    for i = 1, 10 do
        TweenService:Create(LoaderBar, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.new(i/10, 0, 1, 0)}):Play()
        task.wait(0.12)
    end
    task.wait(0.4)
    TweenService:Create(LoaderBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(LoaderSub, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(LoaderBarBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.6)
    LoaderGui:Destroy()
end)

-- ========== MAIN UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 480)
Main.Position = UDim2.new(0.5, -160, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 10, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 15)),
}
MainGradient.Rotation = 135
MainGradient.Parent = Main

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(255, 0, 150)
MainStroke.Transparency = 0.3

-- ========== TITLE BAR ==========
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 15)
TitleBarFix.Position = UDim2.new(0, 0, 1, -15)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 0, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 80)),
}
TitleGradient.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "★ NEON SEC-PANEL v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -25, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TitleBar
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

-- pulse animation for dot
task.spawn(function()
    while StatusDot.Parent do
        TweenService:Create(StatusDot, TweenInfo.new(0.8), {BackgroundTransparency = 0.5}):Play()
        task.wait(0.8)
        TweenService:Create(StatusDot, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
        task.wait(0.8)
    end
end)

-- ========== PROGRESS BAR ==========
local LoadingBg = Instance.new("Frame")
LoadingBg.Size = UDim2.new(1, -24, 0, 5)
LoadingBg.Position = UDim2.new(0, 12, 0, 52)
LoadingBg.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
LoadingBg.BorderSizePixel = 0
LoadingBg.Parent = Main
Instance.new("UICorner", LoadingBg).CornerRadius = UDim.new(1, 0)

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingBg
Instance.new("UICorner", LoadingBar).CornerRadius = UDim.new(1, 0)

local LoadGrad = Instance.new("UIGradient")
LoadGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150)),
}
LoadGrad.Parent = LoadingBar

local function SetProgress(ratio)
    TweenService:Create(LoadingBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0)
    }):Play()
end

-- ========== LOG FRAME ==========
local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, -24, 0, 90)
LogFrame.Position = UDim2.new(0, 12, 0, 65)
LogFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
LogFrame.BorderSizePixel = 0
LogFrame.Parent = Main
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 8)

local LogStroke = Instance.new("UIStroke", LogFrame)
LogStroke.Thickness = 1
LogStroke.Color = Color3.fromRGB(0, 255, 200)
LogStroke.Transparency = 0.7

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -10, 1, -10)
LogScroll.Position = UDim2.new(0, 5, 0, 5)
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 2
LogScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, 0, 0, 0)
LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(0, 255, 180)
LogText.Font = Enum.Font.Code
LogText.TextSize = 11
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Text = "[SYS] Ядро v3 загружено"
LogText.Parent = LogScroll

local function AddLog(msg, isErr)
    local color = isErr and "255,80,80" or "0,255,180"
    LogText.Text = string.format('<font color="rgb(%s)">[%s] %s</font>\n', color, os.date("%X"), msg) .. LogText.Text
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogText.AbsoluteSize.Y + 10)
    Title.TextColor3 = isErr and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(255, 255, 255)
end

-- ========== BUTTONS ==========
local function CreateButton(text, posY, color1, color2, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 40)
    btn.Position = UDim2.new(0, 12, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2),
    }
    grad.Rotation = 90
    grad.Transparency = NumberSequence.new(0.7)
    grad.Parent = btn
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color1
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(grad, TweenInfo.new(0.2), {Transparency = NumberSequence.new(0.3)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(grad, TweenInfo.new(0.2), {Transparency = NumberSequence.new(0.7)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn, grad, stroke
end

local y = 170
local CheckBtn = CreateButton("1. Проверить Стронгхолд", y, Color3.fromRGB(255, 255, 255), Color3.fromRGB(100, 150, 255), function() end)
y = y + 46
local IgniteBtn = CreateButton("2. Разжечь костёр", y, Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 100, 0), function() end)
y = y + 46
local TpBtn = CreateButton("3. Телепорт к сундуку", y, Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 100, 255), function() end)
y = y + 46
local AutoHopBtn, HopGrad, HopStroke = CreateButton("4. Авто-Хоп: ВЫКЛ", y, Color3.fromRGB(255, 70, 100), Color3.fromRGB(150, 0, 50), function() end)
y = y + 46
local ReserveHopBtn = CreateButton("СБРОСИТЬ КЕШ СЕРВЕРОВ", y, Color3.fromRGB(255, 150, 50), Color3.fromRGB(200, 80, 0), function() end)
y = y + 46
local DumpBtn = CreateButton("Копировать лог", y, Color3.fromRGB(200, 150, 255), Color3.fromRGB(100, 50, 200), function() end)

-- ========== HELPERS ==========
local executor_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
local queue_on_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local char = getCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function findObjectByName(keywords)
    for _, obj in ipairs(workspace:GetDescendants()) do
        for _, kw in ipairs(keywords) do
            if obj.Name:lower():find(kw:lower()) then return obj end
        end
    end
    return nil
end

local function findStronghold() return findObjectByName(CONFIG.STRONGHOLD_KEYWORDS) end
local function findCampfire() return findObjectByName(CONFIG.CAMPFIRE_KEYWORDS) end

-- ========== CAMPFIRE ==========
local function TryIgniteCampfire()
    AddLog("Ищу костёр...")
    local campfire = findCampfire()
    if not campfire then AddLog("Костёр не найден!", true) return false end
    AddLog("Костёр: " .. campfire.Name)
    local hrp = getHRP()
    if hrp then
        local cf = campfire:IsA("Model") and (campfire.PrimaryPart and campfire.PrimaryPart.CFrame or campfire:GetPivot()) or campfire.CFrame
        hrp.CFrame = cf + Vector3.new(0, 3, 0)
        task.wait(1)
    end
    local prompt = campfire:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        pcall(function() fireproximityprompt(prompt) end)
        AddLog("Костёр разожжён (Prompt)!")
        task.wait(CONFIG.CAMPFIRE_WAIT)
        return true
    end
    for _, obj in ipairs(campfire:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function() obj:FireServer() end)
            AddLog("Костёр разожжён (Remote)!")
            task.wait(CONFIG.CAMPFIRE_WAIT)
            return true
        end
    end
    local cd = campfire:FindFirstChildOfClass("ClickDetector")
    if cd then
        pcall(function() fireclickdetector(cd) end)
        AddLog("Костёр разожжён (Click)!")
        task.wait(CONFIG.CAMPFIRE_WAIT)
        return true
    end
    AddLog("Не удалось разжечь!", true)
    return false
end

-- ========== SERVER CACHE ==========
local function PopulateServerCache()
    if not executor_request then AddLog("Нет request!", true) return false, "No Request" end
    AddLog("Поиск серверов...")
    SetProgress(0.3)
    local baseUrl = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc&limit=100"
    local headers = {["User-Agent"] = "Roblox/WinInet", ["Accept"] = "application/json"}
    getgenv().ServerCache = {}
    local cursor = ""
    local pages = 0
    while pages < CONFIG.MAX_PAGES do
        local url = baseUrl
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end
        local ok, res = pcall(function() return executor_request({Url = url, Method = "GET", Headers = headers}) end)
        if ok and res and res.StatusCode == 200 then
            local decOk, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if decOk and data and data.data then
                for _, srv in ipairs(data.data) do
                    if srv.id ~= game.JobId and srv.playing and srv.maxPlayers and (srv.playing < srv.maxPlayers) then
                        table.insert(getgenv().ServerCache, srv.id)
                    end
                end
                if data.nextPageCursor then
                    cursor = data.nextPageCursor
                    pages = pages + 1
                    AddLog("Страница " .. pages .. " | Кеш: " .. #getgenv().ServerCache)
                    task.wait(0.7)
                else break end
            else break end
        elseif ok and res and res.StatusCode == 429 then
            return false, "429 RateLimit!"
        else
            return false, "HTTP " .. tostring(res and res.StatusCode or "nil")
        end
    end
    if #getgenv().ServerCache > 0 then
        AddLog("Найдено: " .. #getgenv().ServerCache)
        return true, "OK"
    end
    return false, "Все забиты!"
end

-- ========== HOP ==========
local isHopping = false
local function ServerHop()
    if isHopping then return end
    isHopping = true
    SetProgress(0.5)
    if queue_on_tp then
        pcall(function()
            queue_on_tp([[
                getgenv().AutoHopEnabled = true
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/nobody/neon_sec/main/auto_farmer.lua'))()
            ]])
        end)
    end
    if #getgenv().ServerCache == 0 then
        local ok, err = PopulateServerCache()
        if not ok then
            AddLog("ОШИБКА: " .. tostring(err), true)
            isHopping = false
            SetProgress(0)
            if string.find(err, "429") then
                getgenv().AutoHopEnabled = false
                AutoHopBtn.Text = "4. Авто-Хоп: ВЫКЛ (БЛОК)"
            end
            return
        end
    end
    if #getgenv().ServerCache > 0 then
        local targetJobId = table.remove(getgenv().ServerCache, 1)
        AddLog("Прыжок! Осталось: " .. #getgenv().ServerCache)
        SetProgress(1.0)
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
        end)
        if not ok then
            AddLog("ТП провалился: " .. tostring(err), true)
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer, {JobId = targetJobId})
            end)
        end
        task.wait(5)
        if game.JobId == targetJobId or not game:IsLoaded() then
            AddLog("ТП не удался, следующий...", true)
            isHopping = false
            task.wait(1)
            if getgenv().AutoHopEnabled then ServerHop() end
        end
    else
        AddLog("Серверы не найдены!", true)
        isHopping = false
    end
end

-- ========== BUTTON LOGIC ==========
CheckBtn.MouseButton1Click:Connect(function()
    AddLog("Проверка...")
    local target = findStronghold()
    if target then
        CheckBtn.Text = "★ СТРОНГХОЛД НАЙДЕН!"
        AddLog("Найдено: " .. target.Name)
    else
        CheckBtn.Text = "НЕТ (разожги костёр)"
        AddLog("Стронгхолд не виден.", true)
    end
    task.wait(2)
    CheckBtn.Text = "1. Проверить Стронгхолд"
end)

IgniteBtn.MouseButton1Click:Connect(function()
    AddLog("Разжигаю костёр...")
    local ok = TryIgniteCampfire()
    IgniteBtn.Text = ok and "★ РАЗОЖЖЁН!" or "НЕ УДАЛОСЬ :("
    task.wait(2)
    IgniteBtn.Text = "2. Разжечь костёр"
end)

TpBtn.MouseButton1Click:Connect(function()
    local target = findStronghold()
    if target then
        local hrp = getHRP()
        if hrp then
            local pos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot()) or target.CFrame
            if pos then hrp.CFrame = pos + Vector3.new(0, 5, 0) AddLog("ТП к " .. target.Name) end
        end
    else
        AddLog("Не к чему ТП!", true)
    end
end)

AutoHopBtn.MouseButton1Click:Connect(function()
    getgenv().AutoHopEnabled = not getgenv().AutoHopEnabled
    if getgenv().AutoHopEnabled then
        AutoHopBtn.Text = "4. Авто-Хоп: ВКЛ"
        AutoHopBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        HopGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 80)),
        }
        HopStroke.Color = Color3.fromRGB(0, 255, 150)
        AddLog("Авто-хоп ВКЛ")
        task.spawn(function()
            TryIgniteCampfire()
            local target = findStronghold()
            if target then
                getgenv().AutoHopEnabled = false
                AutoHopBtn.Text = "4. Авто-Хоп: ВЫКЛ"
                AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
                AddLog("СТРОНГХОЛД НАЙДЕН!")
            else
                ServerHop()
            end
        end)
    else
        AutoHopBtn.Text = "4. Авто-Хоп: ВЫКЛ"
        AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
        HopGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 50)),
        }
        HopStroke.Color = Color3.fromRGB(255, 70, 100)
        isHopping = false
        AddLog("Авто-хоп ВЫКЛ")
    end
end)

ReserveHopBtn.MouseButton1Click:Connect(function()
    getgenv().ServerCache = {}
    AddLog("Кеш очищен!")
    ReserveHopBtn.Text = "КЕШ ОЧИЩЕН"
    task.wait(2)
    ReserveHopBtn.Text = "СБРОСИТЬ КЕШ СЕРВЕРОВ"
end)

DumpBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(LogText.Text)
        AddLog("Лог в буфере!")
    end
end)

-- ========== APPEAR ANIMATION ==========
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, -160, 0.15, 30)
TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -160, 0.15, 0)
}):Play()

AddLog("Скрипт загружен. v3.0 HYPER")
