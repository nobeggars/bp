--[[
    NEON FLY + ESP + ANTI-TP v3.0
    Author: I.S.-1
    Features:
    - Fly (F)
    - Noclip (G)
    - ESP on all (H)
    - Anti-TP (B)
    - TP to chest (T)
    - TP to stronghold (Y)
    - Remove trees/fog/grass (R)
    - Night vision (N)
    - Max graphics distance (M)
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- ========== CLEANUP ==========
local uiName = "NeonFlyESP"
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end

-- ========== CONFIG ==========
local CONFIG = {
    FLY_SPEED = 80,
    ESP_ENABLED = false,
    ESP_COLOR = Color3.fromRGB(0, 255, 200),
    ESP_CHEST_COLOR = Color3.fromRGB(255, 200, 0),
    ESP_STRONGHOLD_COLOR = Color3.fromRGB(255, 0, 150),
    ESP_BUILDING_COLOR = Color3.fromRGB(100, 150, 255),
    ESP_ITEM_COLOR = Color3.fromRGB(0, 255, 100),
    ESP_NPC_COLOR = Color3.fromRGB(255, 70, 70),
    NIGHT_VISION = false,
    REMOVE_OBJECTS = false,
    MAX_DISTANCE = false,
}

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local bypassEnabled = false
local nightVisionEnabled = false
local removeEnabled = false
local maxDistanceEnabled = false
local savedCFrame = nil
local bypassConnection = nil
local removedObjects = {}
local originalLighting = {}

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 400)
Main.Position = UDim2.new(0.5, -140, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Transparency = 0.3

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "★ NEON FLY + ESP v3 ★"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local function CreateButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    return btn
end

local y = 42
local FlyBtn = CreateButton("FLY: ВЫКЛ (F)", y, Color3.fromRGB(0, 255, 200)); y = y + 34
local NoclipBtn = CreateButton("NOCLIP: ВЫКЛ (G)", y, Color3.fromRGB(255, 200, 0)); y = y + 34
local EspBtn = CreateButton("ESP: ВЫКЛ (H)", y, Color3.fromRGB(100, 150, 255)); y = y + 34
local BypassBtn = CreateButton("ANTI-TP: ВЫКЛ (B)", y, Color3.fromRGB(255, 0, 150)); y = y + 34
local NightBtn = CreateButton("НОЧНОЕ ЗРЕНИЕ: ВЫКЛ (N)", y, Color3.fromRGB(200, 200, 255)); y = y + 34
local RemoveBtn = CreateButton("УБРАТЬ ДЕРЕВЬЯ/ТУМАН: ВЫКЛ (R)", y, Color3.fromRGB(150, 255, 100)); y = y + 34
local MaxDistBtn = CreateButton("МАКС. ДАЛЬНОСТЬ: ВЫКЛ (M)", y, Color3.fromRGB(255, 150, 50)); y = y + 34
local TpChestBtn = CreateButton("TP К СУНДУКУ (T)", y, Color3.fromRGB(0, 255, 100)); y = y + 34
local TpStrongBtn = CreateButton("TP К СТРОНГХОЛДУ (Y)", y, Color3.fromRGB(255, 100, 200))

-- ========== HELPERS ==========
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- ========== FLY ==========
local function setFly(state)
    flyEnabled = state
    FlyBtn.Text = "FLY: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (F)"
    local hrp = getHRP()
    if hrp then
        local humanoid = hrp.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = state
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not flyEnabled then return end
    local hrp = getHRP()
    if not hrp then return end
    local move = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then
        hrp.Velocity = move * CONFIG.FLY_SPEED
    else
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end)

-- ========== NOCLIP ==========
local function setNoclip(state)
    noclipEnabled = state
    NoclipBtn.Text = "NOCLIP: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (G)"
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if noclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ========== ANTI-TP ==========
local function enableAntiTP()
    local hrp = getHRP()
    if not hrp then return end
    savedCFrame = hrp.CFrame
    if bypassConnection then bypassConnection:Disconnect() end
    local lastCFrame = hrp.CFrame
    bypassConnection = RunService.Heartbeat:Connect(function()
        if not bypassEnabled then return end
        local h = getHRP()
        if not h then return end
        local dist = (h.Position - lastCFrame.Position).Magnitude
        if dist > 50 and flyEnabled then
            h.CFrame = lastCFrame
        else
            lastCFrame = h.CFrame
        end
    end)
    print("[ANTI-TP] Enabled")
end

local function disableAntiTP()
    if bypassConnection then
        bypassConnection:Disconnect()
        bypassConnection = nil
    end
    print("[ANTI-TP] Disabled")
end

local function setBypass(state)
    bypassEnabled = state
    BypassBtn.Text = "ANTI-TP: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (B)"
    if state then enableAntiTP() else disableAntiTP() end
end

-- ========== NIGHT VISION ==========
local function setNightVision(state)
    nightVisionEnabled = state
    NightBtn.Text = "НОЧНОЕ ЗРЕНИЕ: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (N)"
    if state then
        -- Сохраняем оригинальные настройки
        originalLighting.Ambient = Lighting.Ambient
        originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLighting.Brightness = Lighting.Brightness
        originalLighting.ClockTime = Lighting.ClockTime
        originalLighting.FogEnd = Lighting.FogEnd
        originalLighting.FogStart = Lighting.FogStart
        originalLighting.FogColor = Lighting.FogColor

        -- Включаем ночное зрение
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 3
        Lighting.ClockTime = 12 -- день
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.FogColor = Color3.fromRGB(200, 200, 200)
        Lighting.GlobalShadows = false

        -- Добавляем Brightness
        local brightness = Instance.new("ColorCorrectionEffect")
        brightness.Name = "NeonNightVision"
        brightness.Brightness = 1
        brightness.Contrast = 0.2
        brightness.Saturation = -0.2
        brightness.Parent = Lighting
    else
        -- Восстанавливаем
        if originalLighting.Ambient then Lighting.Ambient = originalLighting.Ambient end
        if originalLighting.OutdoorAmbient then Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient end
        if originalLighting.Brightness then Lighting.Brightness = originalLighting.Brightness end
        if originalLighting.ClockTime then Lighting.ClockTime = originalLighting.ClockTime end
        if originalLighting.FogEnd then Lighting.FogEnd = originalLighting.FogEnd end
        if originalLighting.FogStart then Lighting.FogStart = originalLighting.FogStart end
        if originalLighting.FogColor then Lighting.FogColor = originalLighting.FogColor end
        Lighting.GlobalShadows = true
        local nv = Lighting:FindFirstChild("NeonNightVision")
        if nv then nv:Destroy() end
    end
end

-- ========== REMOVE OBJECTS ==========
local function setRemoveObjects(state)
    removeEnabled = state
    RemoveBtn.Text = "УБРАТЬ ДЕРЕВЬЯ/ТУМАН: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (R)"
    if state then
        -- Удаляем туман
        originalLighting.FogEnd = Lighting.FogEnd
        originalLighting.FogStart = Lighting.FogStart
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000

        -- Удаляем деревья и траву
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("tree") or n:find("grass") or n:find("bush") or n:find("plant") or n:find("leaf") or n:find("foliage") then
                    if obj:IsA("BasePart") then
                        obj.Transparency = 1
                        table.insert(removedObjects, {obj = obj, orig = obj.Transparency})
                    elseif obj:IsA("Model") then
                        for _, part in ipairs(obj:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                                table.insert(removedObjects, {obj = part, orig = part.Transparency})
                            end
                        end
                    end
                end
            end
        end
        print("[REMOVE] Removed " .. #removedObjects .. " objects")
    else
        -- Восстанавливаем
        for _, data in ipairs(removedObjects) do
            if data.obj and data.obj.Parent then
                data.obj.Transparency = data.orig
            end
        end
        removedObjects = {}
        if originalLighting.FogEnd then Lighting.FogEnd = originalLighting.FogEnd end
        if originalLighting.FogStart then Lighting.FogStart = originalLighting.FogStart end
    end
end

-- ========== MAX DISTANCE ==========
local function setMaxDistance(state)
    maxDistanceEnabled = state
    MaxDistBtn.Text = "МАКС. ДАЛЬНОСТЬ: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (M)"
    if state then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
        print("[MAXDIST] Enabled")
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
        print("[MAXDIST] Disabled")
    end
end

-- ========== ESP ==========
local espObjects = {}

local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
end

local function createESP(target, color, label)
    if not target then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(6, 6, 6)
    box.Transparency = 0.4
    box.Color3 = color
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = target
    box.Parent = target
    table.insert(espObjects, box)

    if label then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 150, 0, 30)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.Adornee = target
        billboard.Parent = target
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = color
        text.Font = Enum.Font.GothamBold
        text.TextSize = 12
        text.TextStrokeTransparency = 0
        text.TextStrokeColor3 = Color3.new(0, 0, 0)
        text.Parent = billboard
        table.insert(espObjects, billboard)
    end
end

local function updateESP()
    clearESP()
    if not espEnabled then return end

    -- Сундуки
    local items = workspace:FindFirstChild("Items")
    if items then
        for _, obj in ipairs(items:GetChildren()) do
            if obj.Name:lower():find("chest") then
                if obj.Name == "ChestDEF" then
                    createESP(obj, CONFIG.ESP_STRONGHOLD_COLOR, "СТРОНГХОЛД СУНДУК")
                else
                    createESP(obj, CONFIG.ESP_CHEST_COLOR, "СУНДУК: " .. obj.Name)
                end
            elseif obj:IsA("Model") or obj:IsA("BasePart") then
                createESP(obj, CONFIG.ESP_ITEM_COLOR, "ПРЕДМЕТ: " .. obj.Name)
            end
        end
    end

    -- Здания и ландмарки
    local map = workspace:FindFirstChild("Map")
    if map then
        local landmarkKeywords = {"hut", "cabin", "tower", "lodge", "shack", "house", "treehouse", "castle", "shed", "camp", "fire", "tent", "cave", "burnt", "fishing", "fairy", "jail", "tool", "stronghold", "fort"}
        for _, landmark in ipairs(map:GetDescendants()) do
            if landmark:IsA("Model") then
                local n = landmark.Name:lower()
                for _, kw in ipairs(landmarkKeywords) do
                    if n:find(kw) then
                        createESP(landmark, CONFIG.ESP_BUILDING_COLOR, "ЗДАНИЕ: " .. landmark.Name)
                        break
                    end
                end
            end
        end
    end

    -- NPC
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, npc in ipairs(chars:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                createESP(npc, CONFIG.ESP_NPC_COLOR, "NPC: " .. npc.Name)
            end
        end
    end
end

local function setESP(state)
    espEnabled = state
    EspBtn.Text = "ESP: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (H)"
    if state then updateESP() else clearESP() end
end

-- ========== TELEPORT ==========
local function findNearestChest()
    local items = workspace:FindFirstChild("Items")
    if not items then return nil end
    local hrp = getHRP()
    if not hrp then return nil end
    local nearest, dist = nil, math.huge
    for _, obj in ipairs(items:GetChildren()) do
        if obj.Name:lower():find("chest") then
            local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position) or obj.Position
            if pos then
                local d = (pos - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

local function findStrongholdChest()
    local cg = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Campground")
    if not cg then return nil end
    for _, obj in ipairs(cg:GetDescendants()) do
        if obj.Name == "ChestDEF" then
            return obj
        end
    end
    return nil
end

local function teleportTo(target)
    if not target then return false end
    local hrp = getHRP()
    if not hrp then return false end
    local pos
    if target:IsA("Model") then
        pos = target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot()
    else
        pos = target.CFrame
    end
    hrp.CFrame = pos + Vector3.new(0, 5, 0)
    return true
end

-- ========== INPUT ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then setFly(not flyEnabled)
    elseif input.KeyCode == Enum.KeyCode.G then setNoclip(not noclipEnabled)
    elseif input.KeyCode == Enum.KeyCode.H then setESP(not espEnabled)
    elseif input.KeyCode == Enum.KeyCode.B then setBypass(not bypassEnabled)
    elseif input.KeyCode == Enum.KeyCode.N then setNightVision(not nightVisionEnabled)
    elseif input.KeyCode == Enum.KeyCode.R then setRemoveObjects(not removeEnabled)
    elseif input.KeyCode == Enum.KeyCode.M then setMaxDistance(not maxDistanceEnabled)
    elseif input.KeyCode == Enum.KeyCode.T then
        local chest = findNearestChest()
        if chest then teleportTo(chest) end
    elseif input.KeyCode == Enum.KeyCode.Y then
        local strong = findStrongholdChest()
        if strong then teleportTo(strong) end
    end
end)

-- ========== BUTTON HANDLERS ==========
FlyBtn.MouseButton1Click:Connect(function() setFly(not flyEnabled) end)
NoclipBtn.MouseButton1Click:Connect(function() setNoclip(not noclipEnabled) end)
EspBtn.MouseButton1Click:Connect(function() setESP(not espEnabled) end)
BypassBtn.MouseButton1Click:Connect(function() setBypass(not bypassEnabled) end)
NightBtn.MouseButton1Click:Connect(function() setNightVision(not nightVisionEnabled) end)
RemoveBtn.MouseButton1Click:Connect(function() setRemoveObjects(not removeEnabled) end)
MaxDistBtn.MouseButton1Click:Connect(function() setMaxDistance(not maxDistanceEnabled) end)
TpChestBtn.MouseButton1Click:Connect(function()
    local chest = findNearestChest()
    if chest then teleportTo(chest) end
end)
TpStrongBtn.MouseButton1Click:Connect(function()
    local strong = findStrongholdChest()
    if strong then teleportTo(strong) end
end)

-- ========== AUTO-UPDATE ESP ==========
task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then updateESP() end
    end
end)

-- ========== APPEAR ==========
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, -140, 0.1, 30)
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -140, 0.1, 0)
}):Play()

print("[NEON] v3.0 loaded. Keys: F=fly, G=noclip, H=esp, B=anti-tp, N=night, R=remove, M=maxdist, T=chest, Y=stronghold")
