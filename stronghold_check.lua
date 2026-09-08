local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local uiName = "AndroidSecPanel"
getgenv().AutoHopEnabled = getgenv().AutoHopEnabled or false

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 190)
Frame.Position = UDim2.new(0.5, -125, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
Frame.Active = true
Frame.Draggable = true 
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = " Mobile Sec-Panel | 99 Nights"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.Parent = Frame

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(1, -20, 0, 40)
CheckBtn.Position = UDim2.new(0, 10, 0, 40)
CheckBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.Text = "1. Проверить сервер"
CheckBtn.Font = Enum.Font.Code
CheckBtn.TextSize = 14
CheckBtn.Parent = Frame

local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1, -20, 0, 40)
TpBtn.Position = UDim2.new(0, 10, 0, 90)
TpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Text = "2. Телепорт (ESP)"
TpBtn.Font = Enum.Font.Code
TpBtn.TextSize = 14
TpBtn.Parent = Frame

local AutoHopBtn = Instance.new("TextButton")
AutoHopBtn.Size = UDim2.new(1, -20, 0, 40)
AutoHopBtn.Position = UDim2.new(0, 10, 0, 140)
AutoHopBtn.BackgroundColor3 = getgenv().AutoHopEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
AutoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoHopBtn.Text = getgenv().AutoHopEnabled and "3. Авто-Хоп: ВКЛ" or "3. Авто-Хоп: ВЫКЛ"
AutoHopBtn.Font = Enum.Font.Code
AutoHopBtn.TextSize = 14
AutoHopBtn.Parent = Frame

-- ЧЕК СТРОНГХОЛДА
local function CheckStronghold()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
            return obj
        end
    end
    return nil
end

-- СЕРВЕР ХОП
local isHopping = false
local function ServerHop()
    if isHopping then return end
    isHopping = true
    Title.Text = " Ищу сервер..."

    local placeId = game.PlaceId
    local currentJob = game.JobId
    local cursor = ""
    local found = false

    -- Очередь для перезапуска скрипта при прыжке
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

    -- Перебор серверов через ропрокси и обычный домен
    for attempt = 1, 5 do
        local raw = nil
        local urlProxy = "https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/Public?limit=100" .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
        local urlDirect = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?limit=100" .. (cursor ~= "" and ("&cursor=" .. cursor) or "")

        -- Пробуем через прокси
        local s, res = pcall(function() return game:HttpGet(urlProxy) end)
        if s and res and not string.find(res, "errors") then
            raw = res
        else
            -- Фоллбэк напрямую
            local s2, res2 = pcall(function() return game:HttpGet(urlDirect) end)
            if s2 and res2 then raw = res2 end
        end

        if raw then
            local decSuccess, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if decSuccess and data and data.data then
                for _, srv in ipairs(data.data) do
                    if srv.id ~= currentJob and srv.playing and srv.maxPlayers and (srv.playing < srv.maxPlayers) then
                        Title.Text = " Прыгаем на " .. tostring(srv.playing) .. " игроков..."
                        local tpSuccess = pcall(function()
                            TeleportService:TeleportToPlaceInstance(placeId, srv.id, LocalPlayer)
                        end)
                        if tpSuccess then
                            found = true
                            return
                        end
                    end
                end

                if data.nextPageCursor then
                    cursor = data.nextPageCursor
                else
                    cursor = ""
                end
            end
        end
        task.wait(1.5)
    end

    if not found then
        isHopping = false
        Title.Text = " Лимит API. Ретрай через 5с..."
        task.wait(5)
        ServerHop()
    end
end

-- КНОПКИ
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
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot()) or target.CFrame
            if pos then hrp.CFrame = pos end
        end
    end
end)

AutoHopBtn.MouseButton1Click:Connect(function()
    getgenv().AutoHopEnabled = not getgenv().AutoHopEnabled
    if getgenv().AutoHopEnabled then
        AutoHopBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        AutoHopBtn.Text = "3. Авто-Хоп: ВКЛ"
        task.spawn(function()
            local target = CheckStronghold()
            if target then
                getgenv().AutoHopEnabled = false
                AutoHopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
                AutoHopBtn.Text = "НАЙДЕН! СТОП"
                Title.Text = " Стронгхолд тут!"
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

-- АВТО-ПРОВЕРКА ПРИ ЗАГРУЗКЕ
if getgenv().AutoHopEnabled then
    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        task.wait(4)
        local target = CheckStronghold()
        if target then
            getgenv().AutoHopEnabled = false
            AutoHopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            AutoHopBtn.Text = "НАЙДЕН! СТОП"
            Title.Text = " Стронгхолд тут!"
            
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                local pos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot()) or target.CFrame
                if pos then hrp.CFrame = pos end
            end
        else
            ServerHop()
        end
    end)
end
