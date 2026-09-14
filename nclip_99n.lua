--[[
    GHOSTWARE v4.8 — AUTO-FARM FIX (Fuel Canister)
    Author: I.S.-1
    Fixes:
    - Auto-Farm теперь ищет "Fuel Canister" и "FuelAdded"
    - Всё остальное сохранено
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local uiName = "GhostWare_v4"

-- ========== НАСТРОЙКИ ==========
local SCAN = {
    Y = -50,
    STEP = 180,
    MAX_RINGS = 12,
    TWEEN_SPEED = 120,
    WAIT_AT_POINT = 0.3,
}

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local bypassEnabled = false
local nightVisionEnabled = false
local scanEnabled = false
local autoFarmEnabled = false
local killAuraEnabled = false
local godModeEnabled = false
local foundObject = nil
local highlightObjects = {}
local fullLog = ""
local originalLighting = {}
local espConnections = {}
local bypassConnection = nil
local savedPos = nil
local savedCF = nil
local autoFarmConnection = nil
local killAuraConnection = nil
local godModeConnection = nil
local isCollapsed = false
local logLines = {}

-- ========== CLEANUP ==========
pcall(function() if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end end)
pcall(function() if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
local parentSet = false
pcall(function() if gethui then ScreenGui.Parent = gethui() parentSet = true end end)
if not parentSet then pcall(function() ScreenGui.Parent = CoreGui parentSet = true end) end
if not parentSet then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ========== UI ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 320)
Main.Position = UDim2.new(0.5, -190, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(30, 45, 40)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 22, 22)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "★ GHOSTWARE v4.8"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 22)
MinimizeBtn.Position = UDim2.new(1, -55, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 45)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 22)
CloseBtn.Position = UDim2.new(1, -28, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local TabsBar = Instance.new("Frame")
TabsBar.Size = UDim2.new(1, -20, 0, 26)
TabsBar.Position = UDim2.new(0, 10, 0, 38)
TabsBar.BackgroundColor3 = Color3.fromRGB(16, 20, 20)
TabsBar.BorderSizePixel = 0
TabsBar.Parent = Main
Instance.new("UICorner", TabsBar).CornerRadius = UDim.new(0, 6)

local TabsLayout = Instance.new("UIListLayout", TabsBar)
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -130)
ContentArea.Position = UDim2.new(0, 10, 0, 70)
ContentArea.BackgroundColor3 = Color3.fromRGB(10, 12, 12)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = Main
Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 6)

local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, -20, 0, 50)
LogFrame.Position = UDim2.new(0, 10, 1, -60)
LogFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 10)
LogFrame.BorderSizePixel = 0
LogFrame.Parent = Main
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 6)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -6, 1, -6)
LogScroll.Position = UDim2.new(0, 3, 0, 3)
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 2
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, 0, 0, 0)
LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(0, 200, 120)
LogText.Font = Enum.Font.Code
LogText.TextSize = 9
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.RichText = true
LogText.Text = "[v4.8] Загружен.\n"
LogText.Parent = LogScroll

local function AddLog(msg, isErr)
    local color = isErr and '<font color="rgb(255,80,80)">' or '<font color="rgb(0,200,120)">'
    local line = string.format("%s[%s] %s</font>\n", color, os.date("%X"), msg)
    LogText.Text = line .. LogText.Text
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogText.AbsoluteSize.Y + 10)
    table.insert(logLines, line)
    if #logLines > 50 then table.remove(logLines, 1) end
end

-- ========== TAB SYSTEM ==========
local tabContents = {}
local tabButtons = {}

local function CreateTabContent(tabName)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -6, 1, -6)
    frame.Position = UDim2.new(0, 3, 0, 3)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 2
    frame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 120)
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.Visible = false
    frame.Parent = ContentArea
    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    tabContents[tabName] = frame
    return frame
end

local function CreateTabButton(tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 30, 30)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(150, 170, 160)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = TabsBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        for name, frame in pairs(tabContents) do frame.Visible = (name == tabName) end
        for name, button in pairs(tabButtons) do
            if name == tabName then
                button.BackgroundColor3 = Color3.fromRGB(0, 80, 60)
                button.TextColor3 = Color3.fromRGB(0, 255, 200)
            else
                button.BackgroundColor3 = Color3.fromRGB(25, 30, 30)
                button.TextColor3 = Color3.fromRGB(150, 170, 160)
            end
        end
    end)
    tabButtons[tabName] = btn
    return btn
end

local function CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(18, 22, 22)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = "  " .. text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 3, 0, 12)
    Ind.Position = UDim2.new(0, 3, 0.5, -6)
    Ind.BackgroundColor3 = Color3.fromRGB(40, 45, 45)
    Ind.BorderSizePixel = 0
    Ind.Parent = btn
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 30, 30)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18, 22, 22)}):Play() end)
    btn.MouseButton1Click:Connect(callback)
    return btn, Ind
end

CreateTabButton("MAIN")
CreateTabButton("VISUAL")
CreateTabButton("SCAN")
CreateTabButton("FARM")
CreateTabButton("DEBUG")

CreateTabContent("MAIN")
CreateTabContent("VISUAL")
CreateTabContent("SCAN")
CreateTabContent("FARM")
CreateTabContent("DEBUG")

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ========== MAIN TAB ==========
local mainTab = tabContents["MAIN"]

CreateToggle(mainTab, "1. FLY & NOCLIP", function()
    flyEnabled = not flyEnabled
    noclipEnabled = flyEnabled
    AddLog("Fly: " .. (flyEnabled and "ВКЛ" or "ВЫКЛ"))
    local hrp = getHRP()
    if hrp then
        local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = flyEnabled end
    end
end)

CreateToggle(mainTab, "2. ANTI-TP", function()
    bypassEnabled = not bypassEnabled
    AddLog("Anti-TP: " .. (bypassEnabled and "ВКЛ" or "ВЫКЛ"))
    if bypassEnabled then
        local hrp = getHRP()
        if hrp then
            if bypassConnection then bypassConnection:Disconnect() end
            savedPos = hrp.Position
            savedCF = hrp.CFrame
            bypassConnection = RunService.Heartbeat:Connect(function()
                if not bypassEnabled or scanEnabled then return end
                local h = getHRP()
                if not h then return end
                local dist = (h.Position - savedPos).Magnitude
                if dist > 150 then h.CFrame = savedCF
                else savedCF = h.CFrame savedPos = h.Position end
            end)
        end
    else
        if bypassConnection then bypassConnection:Disconnect() bypassConnection = nil end
    end
end)

-- ========== GOD MODE (безопасный) ==========
CreateToggle(mainTab, "3. GOD MODE (безопасный)", function()
    godModeEnabled = not godModeEnabled
    AddLog("God Mode: " .. (godModeEnabled and "ВКЛ" or "ВЫКЛ"))
    
    if godModeEnabled then
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("GhostShield") then
            local ff = Instance.new("ForceField")
            ff.Name = "GhostShield"
            ff.Visible = false
            ff.Parent = char
        end
        
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("TouchTransmitter") then
                    pcall(function() part:Destroy() end)
                end
            end
        end
        
        if godModeConnection then godModeConnection:Disconnect() end
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not godModeEnabled then return end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
                if not char:FindFirstChild("GhostShield") then
                    local ff = Instance.new("ForceField")
                    ff.Name = "GhostShield"
                    ff.Visible = false
                    ff.Parent = char
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("GhostShield") then
            char.GhostShield:Destroy()
        end
        if godModeConnection then godModeConnection:Disconnect() godModeConnection = nil end
    end
end)

-- ========== VISUAL TAB ==========
local visualTab = tabContents["VISUAL"]

CreateToggle(visualTab, "1. ESP (Diamond Chest)", function()
    espEnabled = not espEnabled
    AddLog("ESP: " .. (espEnabled and "ВКЛ" or "ВЫКЛ"))
    local function isTargetChest(obj)
        local name = string.lower(obj.Name)
        if string.find(name, "diamond") and string.find(name, "chest") then return true, "💎 DIAMOND CHEST", Color3.fromRGB(0, 240, 255) end
        if name == "chest" and obj.Parent then
            local p = string.lower(obj.Parent.Name)
            if string.find(p, "stronghold") or string.find(p, "cultist") then return true, "💎 STRONGHOLD CHEST", Color3.fromRGB(0, 240, 255) end
        end
        if string.find(name, "stronghold") or string.find(name, "cultist") then
            if obj:IsA("Model") then return true, "🏰 STRONGHOLD", Color3.fromRGB(255, 0, 255) end
        end
        return false
    end
    local function createESP(object, color, text)
        if highlightObjects[object] then return end
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.FillColor = color
            hl.FillTransparency = 0.6
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Adornee = object
            hl.Parent = object
            table.insert(highlightObjects, hl)
        end)
        pcall(function()
            local adornee = object:IsA("Model") and (object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")) or object
            if adornee then
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 200, 0, 40)
                bb.AlwaysOnTop = true
                bb.MaxDistance = math.huge
                bb.StudsOffset = Vector3.new(0, 8, 0)
                bb.Adornee = adornee
                bb.Parent = adornee
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = text
                tl.TextColor3 = color
                tl.Font = Enum.Font.GothamBlack
                tl.TextSize = 14
                tl.TextStrokeTransparency = 0
                tl.Parent = bb
                table.insert(highlightObjects, bb)
            end
        end)
        if string.find(text, "CHEST") then foundObject = object end
    end
    if espEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            local isT, lbl, clr = isTargetChest(obj)
            if isT then createESP(obj, clr, lbl) end
        end
        table.insert(espConnections, workspace.DescendantAdded:Connect(function(obj)
            if not espEnabled then return end
            local isT, lbl, clr = isTargetChest(obj)
            if isT then createESP(obj, clr, lbl) end
        end))
    else
        for _, hl in pairs(highlightObjects) do pcall(function() hl:Destroy() end) end
        highlightObjects = {}
        for _, c in pairs(espConnections) do pcall(function() c:Disconnect() end) end
        espConnections = {}
    end
end)

CreateToggle(visualTab, "2. NIGHT VISION", function()
    nightVisionEnabled = not nightVisionEnabled
    AddLog("Night Vision: " .. (nightVisionEnabled and "ВКЛ" or "ВЫКЛ"))
    if nightVisionEnabled then
        originalLighting = {
            Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
            FogColor = Lighting.FogColor, GlobalShadows = Lighting.GlobalShadows,
        }
        Lighting.Ambient = Color3.fromRGB(100, 255, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 255, 200)
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.FogColor = Color3.fromRGB(200, 200, 200)
        Lighting.GlobalShadows = false
        local hrp = getHRP()
        if hrp then
            local light = hrp:FindFirstChild("GhostLight") or Instance.new("PointLight")
            light.Name = "GhostLight"
            light.Brightness = 5
            light.Range = 100
            light.Color = Color3.fromRGB(0, 255, 200)
            light.Parent = hrp
        end
    else
        if originalLighting.Ambient then
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart
            Lighting.FogColor = originalLighting.FogColor
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end
        local hrp = getHRP()
        if hrp and hrp:FindFirstChild("GhostLight") then hrp.GhostLight:Destroy() end
    end
end)

-- ========== SCAN TAB ==========
local scanTab = tabContents["SCAN"]

CreateToggle(scanTab, "1. SPIRAL SCAN", function()
    if scanEnabled then scanEnabled = false AddLog("Скан остановлен") return end
    local hrp = getHRP()
    if not hrp then AddLog("HRP не найден", true) return end
    scanEnabled = true
    AddLog("Запуск спирального сканирования...")
    local startPos = hrp.Position
    local x, z = 0, 0
    local dx, dz = 0, -1
    task.spawn(function()
        for i = 1, (SCAN.MAX_RINGS * 2)^2 do
            if not scanEnabled then break end
            if (-SCAN.MAX_RINGS < x and x <= SCAN.MAX_RINGS) and (-SCAN.MAX_RINGS < z and z <= SCAN.MAX_RINGS) then
                local targetPos = Vector3.new(startPos.X + x * SCAN.STEP, SCAN.Y, startPos.Z + z * SCAN.STEP)
                local distance = (hrp.Position - targetPos).Magnitude
                local duration = distance / SCAN.TWEEN_SPEED
                if duration > 0 then
                    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                    tween:Play()
                    tween.Completed:Wait()
                end
                pcall(function() LocalPlayer:RequestStreamAroundAsync(hrp.Position) end)
                task.wait(SCAN.WAIT_AT_POINT)
                if foundObject then AddLog("★ ЦЕЛЬ НАЙДЕНА!") break end
            end
            if x == z or (x < 0 and x == -z) or (x > 0 and x == 1 - z) then dx, dz = -dz, dx end
            x, z = x + dx, z + dz
        end
        scanEnabled = false
        AddLog("Скан завершён")
    end)
end)

CreateToggle(scanTab, "2. TP К НАЙДЕННОМУ", function()
    local hrp = getHRP()
    if hrp and foundObject then
        local pos = foundObject:IsA("Model") and (foundObject.PrimaryPart and foundObject.PrimaryPart.Position or foundObject:GetPivot().Position) or foundObject.Position
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        AddLog("ТП выполнен")
    else
        AddLog("Цель не найдена", true)
    end
end)

CreateToggle(scanTab, "3. FORCE OPEN CHEST", function()
    local hrp = getHRP()
    if not hrp then AddLog("HRP не найден", true) return end
    if not foundObject then AddLog("Сундук не найден", true) return end
    local prompt = foundObject:FindFirstChildOfClass("ProximityPrompt") or (foundObject.Parent and foundObject.Parent:FindFirstChildOfClass("ProximityPrompt"))
    if not prompt then
        for _, c in ipairs(foundObject:GetDescendants()) do
            if c:IsA("ProximityPrompt") then prompt = c break end
        end
    end
    if not prompt then AddLog("Prompt не найден", true) return end
    AddLog("CFrame Spoofing...")
    local spoofActive = true
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, index)
        if spoofActive and self == hrp and index == "CFrame" and not checkcaller() then
            return foundObject.CFrame
        end
        return oldIndex(self, index)
    end)
    local oldCF = hrp.CFrame
    hrp.CFrame = foundObject.CFrame + Vector3.new(0, 1, 0)
    task.wait(0.1)
    pcall(function() fireproximityprompt(prompt) end)
    AddLog("Пакет отправлен!")
    task.wait(0.1)
    spoofActive = false
    hrp.CFrame = oldCF
end)

-- ========== FARM TAB ==========
local farmTab = tabContents["FARM"]

-- ========== AUTO-FARM (ИСПРАВЛЕННЫЙ — Fuel Canister + FuelAdded) ==========
CreateToggle(farmTab, "1. AUTO-FARM КОСТРА", function()
    autoFarmEnabled = not autoFarmEnabled
    AddLog("Auto-Farm: " .. (autoFarmEnabled and "ВКЛ" or "ВЫКЛ"))
    
    if autoFarmEnabled then
        task.spawn(function()
            while autoFarmEnabled do
                task.wait(0.5)
                local hrp = getHRP()
                if not hrp then continue end
                
                local mainFire = workspace:FindFirstChild("MainFire", true)
                if not mainFire then
                    AddLog("MainFire не найден", true)
                    task.wait(2)
                    continue
                end
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not autoFarmEnabled then break end
                    
                    local n = string.lower(obj.Name)
                    local isFuel = false
                    
                    -- ИСПРАВЛЕНО: Fuel Canister, FuelAdded, Log
                    if string.find(n, "fuel canister") or string.find(n, "fueladded") or string.find(n, "log") then
                        if obj:IsA("BasePart") or obj:IsA("Model") then
                            -- Исключаем меши
                            if not string.find(n, "mesh") and not string.find(n, "stack") and not string.find(n, "sign") then
                                isFuel = true
                            end
                        end
                    end
                    
                    if isFuel then
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt", true) 
                                      or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt", true))
                        
                        if prompt then
                            local previousLocation = hrp.CFrame
                            local pos
                            if obj:IsA("Model") then
                                pos = obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
                            else
                                pos = obj.Position
                            end
                            
                            if pos then
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                                task.wait(0.15)
                                pcall(function() fireproximityprompt(prompt) end)
                                AddLog("Собран: " .. obj.Name)
                                task.wait(0.15)
                                
                                -- ТП к костру
                                local firePos
                                if mainFire:IsA("Model") then
                                    firePos = mainFire.PrimaryPart and mainFire.PrimaryPart.Position or mainFire:GetPivot().Position
                                else
                                    firePos = mainFire.Position
                                end
                                
                                if firePos then
                                    hrp.CFrame = CFrame.new(firePos + Vector3.new(0, 3, 0))
                                    task.wait(0.15)
                                    
                                    local firePrompt = mainFire:FindFirstChildOfClass("ProximityPrompt", true)
                                    if firePrompt then
                                        pcall(function() fireproximityprompt(firePrompt) end)
                                        AddLog("Сдан в костёр")
                                    end
                                    task.wait(0.15)
                                end
                                
                                hrp.CFrame = previousLocation
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ========== KILL AURA ==========
CreateToggle(farmTab, "2. KILL AURA (CULTISTS)", function()
    killAuraEnabled = not killAuraEnabled
    AddLog("Kill Aura: " .. (killAuraEnabled and "ВКЛ" or "ВЫКЛ"))
    
    if killAuraEnabled then
        killAuraConnection = RunService.Heartbeat:Connect(function()
            if not killAuraEnabled then return end
            local hrp = getHRP()
            if not hrp then return end
            
            local chars = workspace:FindFirstChild("Characters")
            if not chars then return end
            
            for _, npc in ipairs(chars:GetChildren()) do
                if npc:IsA("Model") then
                    local name = string.lower(npc.Name)
                    if string.find(name, "cultist") then
                        local hum = npc:FindFirstChildOfClass("Humanoid")
                        local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                        
                        if hum and hum.Health > 0 and npcHRP then
                            local dist = (npcHRP.Position - hrp.Position).Magnitude
                            if dist < 100 then
                                hrp.CFrame = CFrame.new(npcHRP.Position + Vector3.new(0, 3, 0))
                                
                                local char = LocalPlayer.Character
                                local tool = char and char:FindFirstChildOfClass("Tool")
                                if tool then
                                    pcall(function() tool:Activate() end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if killAuraConnection then killAuraConnection:Disconnect() killAuraConnection = nil end
    end
end)

-- ========== DEBUG TAB ==========
local debugTab = tabContents["DEBUG"]

CreateToggle(debugTab, "1. ПОКАЗАТЬ ИМЕНА", function()
    AddLog("=== УНИКАЛЬНЫЕ ИМЕНА ===")
    local woodNames, fireNames, npcNames = {}, {}, {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = string.lower(obj.Name)
        if (string.find(n, "wood") or string.find(n, "stick") or string.find(n, "branch") or string.find(n, "log") or string.find(n, "fuel") or string.find(n, "gas") or string.find(n, "canister")) and not obj:IsA("Bone") then
            woodNames[obj.Name] = (woodNames[obj.Name] or 0) + 1
        end
        if (string.find(n, "campfire") or string.find(n, "mainfire") or string.find(n, "firepit")) and not obj:IsA("Bone") and not string.find(n, "light") and not string.find(n, "particle") then
            fireNames[obj.Name] = (fireNames[obj.Name] or 0) + 1
        end
    end
    
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, npc in ipairs(chars:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                npcNames[npc.Name] = (npcNames[npc.Name] or 0) + 1
            end
        end
    end
    
    AddLog("--- ДРОВА / ГОРЮЧЕЕ ---")
    for name, count in pairs(woodNames) do AddLog("  " .. name .. " (x" .. count .. ")") end
    AddLog("--- КОСТЁР ---")
    for name, count in pairs(fireNames) do AddLog("  " .. name .. " (x" .. count .. ")") end
    AddLog("--- NPC ---")
    for name, count in pairs(npcNames) do AddLog("  " .. name .. " (x" .. count .. ")") end
    AddLog("=== КОНЕЦ ===")
end)

CreateToggle(debugTab, "2. ПОКАЗАТЬ ИНСТРУМЕНТЫ", function()
    AddLog("=== ИНСТРУМЕНТЫ ===")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then AddLog("Backpack: " .. tool.Name) end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then AddLog("Equipped: " .. tool.Name) end
        end
    end
    AddLog("=== КОНЕЦ ===")
end)

CreateToggle(debugTab, "3. СКАН REMOTES", function()
    AddLog("=== REMOTES ===")
    local rs = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(rs:GetDescendants()) do
        if obj:IsA("RemoteEvent") then AddLog("RE: " .. obj:GetFullName())
        elseif obj:IsA("RemoteFunction") then AddLog("RF: " .. obj:GetFullName()) end
    end
end)

CreateToggle(debugTab, "4. КОПИРОВАТЬ ЛОГ (безопасно)", function()
    AddLog("Копирую последние 50 строк...")
    local toCopy = ""
    for i = math.max(1, #logLines - 50), #logLines do
        toCopy = toCopy .. logLines[i]
    end
    local success = false
    pcall(function()
        if setclipboard then setclipboard(toCopy) success = true
        elseif toclipboard then toclipboard(toCopy) success = true end
    end)
    if success then AddLog("Скопировано!")
    else AddLog("setclipboard не работает", true) end
end)

-- ========== COLLAPSE / CLOSE ==========
MinimizeBtn.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    if isCollapsed then
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 32)}):Play()
        TabsBar.Visible = false
        ContentArea.Visible = false
        LogFrame.Visible = false
    else
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 320)}):Play()
        TabsBar.Visible = true
        ContentArea.Visible = true
        LogFrame.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ========== DEFAULT TAB ==========
tabContents["MAIN"].Visible = true
tabButtons["MAIN"].BackgroundColor3 = Color3.fromRGB(0, 80, 60)
tabButtons["MAIN"].TextColor3 = Color3.fromRGB(0, 255, 200)

-- ========== LOOPS ==========
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not flyEnabled or scanEnabled then return end
    local hrp = getHRP()
    if not hrp then return end
    local move = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and move.Magnitude == 0 then
        local md = hum.MoveDirection
        if md.Magnitude > 0 then move = (Camera.CFrame.LookVector * (md.Z * -1)) + (Camera.CFrame.RightVector * md.X) end
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then hrp.Velocity = move.Unit * 100 else hrp.Velocity = Vector3.new(0, 0, 0) end
end)

AddLog("v4.8 AUTO-FARM FIX загружен!")
AddLog("FARM → Fuel Canister + FuelAdded")
