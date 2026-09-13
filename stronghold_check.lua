--[[
    NEON SEC-PANEL v3.3 — DIAGNOSTIC EDITION
    Author: I.S.-1
    Features:
    - Auto-scan all ProximityPrompts and show names in log
    - Find campfire by prompt action text
    - Find wood by prompt or by name
    - Teleport to chest, not campfire
    - Hop checks JobId before/after
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- ========== CONFIG ==========
local CONFIG = {
    MAX_PAGES = 15,
    CAMPFIRE_WAIT = 3,
    WOOD_WAIT = 2,
    STRONGHOLD_KEYWORDS = {"Stronghold", "DiamondChest", "ChestDEF"},
    CAMPFIRE_ACTION_KEYWORDS = {"ignite", "light", "fire", "camp", "burn", "start"},
    WOOD_ACTION_KEYWORDS = {"pick", "collect", "gather", "take", "wood", "log", "stick"},
    CHEST_KEYWORDS = {"ChestDEF", "DiamondChest", "Chest"},
    CHEST_EXCLUDE = {"Campfire", "FirePit", "Bonfire"},
}

-- ========== CLEANUP ==========
local uiName = "NeonSecHub_99Nights"
getgenv().AutoHopEnabled = getgenv().AutoHopEnabled or false
getgenv().ServerCache = getgenv().ServerCache or {}

if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end
if CoreGui:FindFirstChild("NeonLoader") then CoreGui["NeonLoader"]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("NeonLoader") then LocalPlayer.PlayerGui["NeonLoader"]:Destroy() end

-- ========== SERVICES ==========
local executor_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
local queue_on_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

-- ========== LOADER (same as before) ==========
local function ShowLoader()
    local LoaderGui = Instance.new("ScreenGui")
    LoaderGui.Name = "NeonLoader"
    LoaderGui.ResetOnSpawn = false
    LoaderGui.IgnoreGuiInset = true
    LoaderGui.DisplayOrder = 999
    pcall(function() LoaderGui.Parent = (gethui and gethui()) or CoreGui end)
    if not LoaderGui.Parent then LoaderGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local LoaderBg = Instance.new("Frame")
    LoaderBg.Size = UDim2.new(1, 0, 1, 0)
    LoaderBg.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    LoaderBg.BorderSizePixel = 0
    LoaderBg.ZIndex = 1
    LoaderBg.Parent = LoaderGui

    local G = Instance.new("UIGradient")
    G.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 5, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 0, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10)),
    }
    G.Rotation = 45
    G.Parent = LoaderBg

    local LTitle = Instance.new("TextLabel")
    LTitle.Size = UDim2.new(1, 0, 0, 60)
    LTitle.Position = UDim2.new(0, 0, 0.4, 0)
    LTitle.BackgroundTransparency = 1
    LTitle.Text = "★ NEON SEC-PANEL ★"
    LTitle.TextColor3 = Color3.fromRGB(255, 0, 150)
    LTitle.Font = Enum.Font.GothamBlack
    LTitle.TextSize = 36
    LTitle.TextTransparency = 1
    LTitle.ZIndex = 2
    LTitle.Parent = LoaderBg

    local LSub = Instance.new("TextLabel")
    LSub.Size = UDim2.new(1, 0, 0, 25)
    LSub.Position = UDim2.new(0, 0, 0.4, 60)
    LSub.BackgroundTransparency = 1
    LSub.Text = "v3.3 DIAGNOSTIC EDITION"
    LSub.TextColor3 = Color3.fromRGB(0, 255, 200)
    LSub.Font = Enum.Font.GothamMedium
    LSub.TextSize = 14
    LSub.TextTransparency = 1
    LSub.ZIndex = 2
    LSub.Parent = LoaderBg

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(0, 400, 0, 6)
    BarBg.Position = UDim2.new(0.5, -200, 0.5, 80)
    BarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    BarBg.BorderSizePixel = 0
    BarBg.ZIndex = 2
    BarBg.Parent = LoaderBg
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 0, 1, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(255, 0, 150)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 3
    Bar.Parent = BarBg
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local BarGrad = Instance.new("UIGradient")
    BarGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150)),
    }
    BarGrad.Parent = Bar

    TweenService:Create(LTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(0.2)
    TweenService:Create(LSub, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(0.3)
    for i = 1, 10 do
        TweenService:Create(Bar, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {Size = UDim2.new(i/10, 0, 1, 0)}):Play()
        task.wait(0.1)
    end
    task.wait(0.3)
    TweenService:Create(LTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(LSub, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    LoaderGui:Destroy()
end

-- ========== MAIN UI ==========
local function CreateMainUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 10
    pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 340, 0, 560)
    Main.Position = UDim2.new(0.5, -170, 0.1, 50)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.BackgroundTransparency = 1
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

    local MG = Instance.new("UIGradient")
    MG.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 10, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 15)),
    }
    MG.Rotation = 135
    MG.Parent = Main

    local MS = Instance.new("UIStroke", Main)
    MS.Thickness = 1.5
    MS.Color = Color3.fromRGB(255, 0, 150)
    MS.Transparency = 0.3

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 15)
    TitleFix.Position = UDim2.new(0, 0, 1, -15)
    TitleFix.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar

    local TG = Instance.new("UIGradient")
    TG.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 0, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 80)),
    }
    TG.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "★ NEON SEC-PANEL v3.3"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.Position = UDim2.new(1, -25, 0.5, -4)
    Dot.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Dot.BorderSizePixel = 0
    Dot.Parent = TitleBar
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        while Dot.Parent do
            TweenService:Create(Dot, TweenInfo.new(0.8), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.8)
            TweenService:Create(Dot, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
            task.wait(0.8)
        end
    end)

    local LoadBg = Instance.new("Frame")
    LoadBg.Size = UDim2.new(1, -24, 0, 5)
    LoadBg.Position = UDim2.new(0, 12, 0, 52)
    LoadBg.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    LoadBg.BorderSizePixel = 0
    LoadBg.Parent = Main
    Instance.new("UICorner", LoadBg).CornerRadius = UDim.new(1, 0)

    local LoadBar = Instance.new("Frame")
    LoadBar.Size = UDim2.new(0, 0, 1, 0)
    LoadBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    LoadBar.BorderSizePixel = 0
    LoadBar.Parent = LoadBg
    Instance.new("UICorner", LoadBar).CornerRadius = UDim.new(1, 0)

    local LG = Instance.new("UIGradient")
    LG.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150)),
    }
    LG.Parent = LoadBar

    local function SetProgress(r)
        TweenService:Create(LoadBar, TweenInfo.new(0.3), {Size = UDim2.new(math.clamp(r, 0, 1), 0, 1, 0)}):Play()
    end

    local LogFrame = Instance.new("Frame")
    LogFrame.Size = UDim2.new(1, -24, 0, 140)
    LogFrame.Position = UDim2.new(0, 12, 0, 65)
    LogFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    LogFrame.BorderSizePixel = 0
    LogFrame.Parent = Main
    Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 8)

    local LS = Instance.new("UIStroke", LogFrame)
    LS.Thickness = 1
    LS.Color = Color3.fromRGB(0, 255, 200)
    LS.Transparency = 0.7

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
    LogText.TextSize = 10
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Text = "[SYS] Ядро v3.3 загружено"
    LogText.RichText = true
    LogText.Parent = LogScroll

    local function AddLog(msg, isErr)
        local c = isErr and "255,80,80" or "0,255,180"
        LogText.Text = string.format('<font color="rgb(%s)">[%s] %s</font>\n', c, os.date("%X"), msg) .. LogText.Text
        LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogText.AbsoluteSize.Y + 10)
        Title.TextColor3 = isErr and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(255, 255, 255)
    end

    local function CreateButton(text, yPos, c1, c2)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -24, 0, 38)
        btn.Position = UDim2.new(0, 12, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.Parent = Main
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        }
        g.Rotation = 90
        g.Transparency = NumberSequence.new(0.7)
        g.Parent = btn

        local s = Instance.new("UIStroke", btn)
        s.Color = c1
        s.Thickness = 1
        s.Transparency = 0.4

        btn.MouseEnter:Connect(function()
            TweenService:Create(g, TweenInfo.new(0.2), {Transparency = NumberSequence.new(0.3)}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(g, TweenInfo.new(0.2), {Transparency = NumberSequence.new(0.7)}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        return btn, g, s
    end

    local yPos = 215
    local ScanBtn = CreateButton("🔍 Сканировать объекты (костёр/дрова/сундук)", yPos, Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 100, 200))
    yPos = yPos + 46
    local CheckBtn = CreateButton("1. Проверить Стронгхолд", yPos, Color3.fromRGB(255, 255, 255), Color3.fromRGB(100, 150, 255))
    yPos = yPos + 46
    local IgniteBtn = CreateButton("2. Собрать дрова + Разжечь", yPos, Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 100, 0))
    yPos = yPos + 46
    local TpBtn = CreateButton("3. Телепорт к сундуку", yPos, Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 100, 255))
    yPos = yPos + 46
    local AutoHopBtn, HopG, HopS = CreateButton("4. Авто-Хоп: ВЫКЛ", yPos, Color3.fromRGB(255, 70, 100), Color3.fromRGB(150, 0, 50))
    yPos = yPos + 46
    local ReserveHopBtn = CreateButton("СБРОСИТЬ КЕШ СЕРВЕРОВ", yPos, Color3.fromRGB(255, 150, 50), Color3.fromRGB(200, 80, 0))
    yPos = yPos + 46
    local DumpBtn = CreateButton("Копировать лог", yPos, Color3.fromRGB(200, 150, 255), Color3.fromRGB(100, 50, 200))

    -- ========== HELPERS ==========
    local function getCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
    local function getHRP() local c = getCharacter() return c:FindFirstChild("HumanoidRootPart") end

    local function getActionText(prompt)
        return (prompt.ActionText or "") .. " " .. (prompt.ObjectText or "")
    end

    -- ========== SCANNER ==========
    local function ScanAllPrompts()
        AddLog("=== СКАНЕР ОБЪЕКТОВ ===")
        local found = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                local text = getActionText(prompt)
                table.insert(found, {
                    name = obj.Name,
                    full = obj:GetFullName(),
                    action = text,
                    prompt = prompt
                })
            end
        end

        if #found == 0 then
            AddLog("ProximityPrompt'ов не найдено вообще!", true)
            return
        end

        AddLog("Найдено " .. #found .. " объектов с ProximityPrompt:")
        for i, data in ipairs(found) do
            AddLog(string.format("  [%d] %s | Action: %s", i, data.full, data.action))
        end
    end

    -- ========== FIND CAMPFIRE ==========
    local function findCampfire()
        -- Ищем по ActionText/ ObjectText
        for _, obj in ipairs(workspace:GetDescendants()) do
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                local text = getActionText(prompt):lower()
                for _, kw in ipairs(CONFIG.CAMPFIRE_ACTION_KEYWORDS) do
                    if text:find(kw) then
                        return obj, prompt
                    end
                end
            end
        end
        -- Если не нашли по действию — ищем по имени, исключая меши
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("campfire") or obj.Name:lower():find("bonfire") or obj.Name:lower():find("firepit") then
                if not obj.Name:lower():find("mesh") and not obj.Name:lower():find("cylinder") and not obj.Name:lower():find("firefly") then
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                    return obj, prompt
                end
            end
        end
        return nil, nil
    end

    -- ========== FIND WOOD ==========
    local function findWood()
        local woodObjects = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                local text = getActionText(prompt):lower()
                for _, kw in ipairs(CONFIG.WOOD_ACTION_KEYWORDS) do
                    if text:find(kw) then
                        table.insert(woodObjects, {obj = obj, prompt = prompt})
                        break
                    end
                end
            end
        end
        return woodObjects
    end

    -- ========== COLLECT WOOD ==========
    local function CollectWood()
        AddLog("Ищу дрова...")
        local woods = findWood()
        if #woods == 0 then
            AddLog("Дрова не найдены. Возможно, они не имеют ProximityPrompt.", true)
            return 0
        end
        AddLog("Найдено дров: " .. #woods)
        local hrp = getHRP()
        if not hrp then return 0 end

        local collected = 0
        for i, data in ipairs(woods) do
            if collected >= 10 then break end
            local obj = data.obj
            local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position) or (obj:IsA("BasePart") and obj.Position or nil)
            if pos then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.3)
                pcall(function() fireproximityprompt(data.prompt) end)
                collected = collected + 1
                AddLog("Собрано: " .. obj.Name .. " (" .. collected .. ")")
                task.wait(0.4)
            end
        end
        return collected
    end

    -- ========== IGNITE CAMPFIRE ==========
    local function TryIgniteCampfire()
        AddLog("Ищу костёр...")
        local cf, prompt = findCampfire()
        if not cf then
            AddLog("Костёр не найден. Попробуй сканирование.", true)
            return false
        end
        AddLog("Костёр: " .. cf:GetFullName())
        if prompt then AddLog("Prompt: " .. getActionText(prompt)) end

        -- Собираем дрова
        local wood = CollectWood()
        if wood > 0 then AddLog("Дров собрано: " .. wood) end

        -- ТП к костру
        local hrp = getHRP()
        if hrp then
            local pos = cf:IsA("Model") and (cf.PrimaryPart and cf.PrimaryPart.CFrame or cf:GetPivot()) or cf.CFrame
            hrp.CFrame = pos + Vector3.new(0, 3, 0)
            task.wait(0.5)
        end

        -- Прожигаем prompt
        if prompt then
            pcall(function() fireproximityprompt(prompt) end)
            AddLog("Костёр разожжён (Prompt)!")
            task.wait(CONFIG.CAMPFIRE_WAIT)
            return true
        end

        -- Если нет prompt — ищем RemoteEvent внутри
        for _, obj in ipairs(cf:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                pcall(function() obj:FireServer() end)
                AddLog("Костёр разожжён (Remote)!" )
                task.wait(CONFIG.CAMPFIRE_WAIT)
                return true
            end
        end

        -- Если всё ещё нет — ищем в ReplicatedStorage
        for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("fire") or obj.Name:lower():find("ignite") or obj.Name:lower():find("camp")) then
                pcall(function() obj:FireServer() end)
                AddLog("Костёр разожжён (RS Remote)!")
                task.wait(CONFIG.CAMPFIRE_WAIT)
                return true
            end
        end

        AddLog("Не удалось разжечь! Может, нужен другой предмет.", true)
        return false
    end

    -- ========== FIND CHEST ==========
    local function findChest()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("chest") then
                local excluded = false
                for _, ex in ipairs(CONFIG.CHEST_EXCLUDE) do
                    if obj.Name:lower():find(ex:lower()) then excluded = true break end
                end
                if not excluded then
                    return obj
                end
            end
        end
        return nil
    end

    -- ========== SERVER CACHE ==========
    local function PopulateServerCache()
        if not executor_request then AddLog("Нет request!", true) return false, "No Request" end
        AddLog("Поиск серверов...")
        SetProgress(0.3)
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc&limit=100"
        local headers = {["User-Agent"] = "Roblox/WinInet", ["Accept"] = "application/json"}
        getgenv().ServerCache = {}
        local cursor = ""
        local pages = 0
        while pages < CONFIG.MAX_PAGES do
            local u = url
            if cursor ~= "" then u = u .. "&cursor=" .. cursor end
            local ok, res = pcall(function() return executor_request({Url = u, Method = "GET", Headers = headers}) end)
            if ok and res and res.StatusCode == 200 then
                local dok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                if dok and data and data.data then
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

    -- ========== SERVER HOP ==========
    local isHopping = false
    local function ServerHop()
        if isHopping then return end
        isHopping = true
        SetProgress(0.5)
        local oldJobId = game.JobId
        AddLog("Старый JobId: " .. oldJobId:sub(1, 8) .. "...")

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
            AddLog("Целевой JobId: " .. targetJobId:sub(1, 8) .. "...")
            SetProgress(1.0)

            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
            end)
            if not ok then
                AddLog("ТП провалился: " .. tostring(err), true)
                pcall(function()
                    local opts = Instance.new("TeleportOptions")
                    opts.ServerInstanceId = targetJobId
                    TeleportService:TeleportAsync(game.PlaceId, {LocalPlayer}, opts)
                end)
            end

            task.wait(5)
            if game.JobId == oldJobId then
                AddLog("JobId не сменился! Пробую следующий...", true)
                isHopping = false
                task.wait(2)
                if getgenv().AutoHopEnabled then ServerHop() end
            else
                AddLog("УСПЕШНЫЙ ХОП! Новый JobId: " .. game.JobId:sub(1, 8) .. "...")
                isHopping = false
            end
        else
            AddLog("Серверы не найдены!", true)
            isHopping = false
        end
    end

    -- ========== BUTTON HANDLERS ==========
    ScanBtn.MouseButton1Click:Connect(function()
        ScanAllPrompts()
    end)

    CheckBtn.MouseButton1Click:Connect(function()
        AddLog("Проверка...")
        local t = findStronghold()
        if t then
            CheckBtn.Text = "★ СТРОНГХОЛД НАЙДЕН!"
            AddLog("Найдено: " .. t.Name)
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
        IgniteBtn.Text = "2. Собрать дрова + Разжечь"
    end)

    TpBtn.MouseButton1Click:Connect(function()
        AddLog("Ищу сундук...")
        local chest = findChest()
        if chest then
            local hrp = getHRP()
            if hrp then
                local pos = chest:IsA("Model") and (chest.PrimaryPart and chest.PrimaryPart.CFrame or chest:GetPivot()) or chest.CFrame
                if pos then
                    hrp.CFrame = pos + Vector3.new(0, 5, 0)
                    AddLog("ТП к " .. chest.Name)
                end
            end
        else
            AddLog("Сундук не найден!", true)
        end
    end)

    AutoHopBtn.MouseButton1Click:Connect(function()
        getgenv().AutoHopEnabled = not getgenv().AutoHopEnabled
        if getgenv().AutoHopEnabled then
            AutoHopBtn.Text = "4. Авто-Хоп: ВКЛ"
            AutoHopBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
            HopG.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 80)),
            }
            HopS.Color = Color3.fromRGB(0, 255, 150)
            AddLog("Авто-хоп ВКЛ")
            task.spawn(function()
                local t = findStronghold()
                if t then
                    AddLog("Стронгхолд уже здесь! Хоп не нужен.")
                    getgenv().AutoHopEnabled = false
                    AutoHopBtn.Text = "4. Авто-Хоп: ВЫКЛ"
                    AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
                    return
                end
                ServerHop()
            end)
        else
            AutoHopBtn.Text = "4. Авто-Хоп: ВЫКЛ"
            AutoHopBtn.TextColor3 = Color3.fromRGB(255, 70, 100)
            HopG.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 50)),
            }
            HopS.Color = Color3.fromRGB(255, 70, 100)
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

    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -170, 0.1, 0)
    }):Play()

    AddLog("Скрипт загружен. v3.3 DIAGNOSTIC EDITION")
end

ShowLoader()
CreateMainUI()
