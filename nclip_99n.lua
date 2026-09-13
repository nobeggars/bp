--[[
    NEON FLY + ESP + ANTI-TP v3.0 — WORLD CONTROL
    Author: I.S.-1
    Features:
    - Fly (F)
    - Noclip (G)
    - ESP (H)
    - Anti-TP Bypass (B)
    - Night Vision (N)
    - Remove Trees/Grass/Fog (R)
    - Chunk Loader
    - TP to chest (T)
    - TP to stronghold (Y)
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
    ESP_LOG_COLOR = Color3.fromRGB(200, 150, 100),
    NIGHT_VISION_COLOR = Color3.fromRGB(0, 255, 200),
    TREE_KEYWORDS = {"tree", "pine", "oak", "birch", "spruce", "forest"},
    GRASS_KEYWORDS = {"grass", "bush", "flower", "plant", "shrub"},
}

-- ========== STATE ==========
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local bypassEnabled = false
local nightVisionEnabled = false
local worldCleanEnabled = false
local savedCFrame = nil
local bypassConnection = nil
local originalLighting = {}
local removedObjects = {}

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 360)
Main.Position = UDim2.new(0.5, -140, 0.15, 0)
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
Title.Text = "★ NEON v3.0 WORLD CONTROL ★"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 12
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
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    return btn
end

local FlyBtn = CreateButton("FLY: ВЫКЛ (F)", 45, Color3.fromRGB(0, 255, 200))
local NoclipBtn = CreateButton("NOCLIP: ВЫКЛ (G)", 78, Color3.fromRGB(255, 200, 0))
local EspBtn = CreateButton("ESP: ВЫКЛ (H)", 111, Color3.fromRGB(100, 150, 255))
local BypassBtn = CreateButton("ANTI-TP: ВЫКЛ (B)", 144, Color3.fromRGB(255, 0, 150))
local NightBtn = CreateButton("NIGHT VISION: ВЫКЛ (N)", 177, Color3.fromRGB(200, 150, 255))
local WorldBtn = CreateButton("CLEAN WORLD: ВЫКЛ (R)", 210, Color3.fromRGB(255, 150, 50))
local TpChestBtn = CreateButton("TP К СУНДУКУ (T)", 243, Color3.fromRGB(0, 255, 100))
local TpStrongBtn = CreateButton("TP К СТРОНГХОЛДУ (Y)", 276, Color3.fromRGB(255, 100, 200))
local ChunkBtn = CreateButton("ЗАГРУЗИТЬ ЧАНКИ", 309, Color3.fromRGB(0, 200, 255))

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

-- ========== ANTI-TELEPORT BYPASS ==========
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
    print("[ANTI-TP] Safe bypass enabled")
end

local function disableAntiTP()
    if bypassConnection then
        bypassConnection:Disconnect()
        bypassConnection = nil
    end
    print("[ANTI-TP] Bypass disabled")
end

local function setBypass(state)
    bypassEnabled = state
    BypassBtn.Text = "ANTI-TP: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (B)"
    if state then enableAntiTP() else disableAntiTP() end
end

-- ========== NIGHT VISION ==========
local function saveLighting()
    originalLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        FogColor = Lighting.FogColor,
        GlobalShadows = Lighting.GlobalShadows,
    }
end

local function setNightVision(state)
    nightVisionEnabled = state
    NightBtn.Text = "NIGHT VISION: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (N)"
    if state then
        if not originalLighting.Ambient then saveLighting() end
        Lighting.Ambient = CONFIG.NIGHT_VISION_COLOR
        Lighting.OutdoorAmbient = CONFIG.NIGHT_VISION_COLOR
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.FogColor = CONFIG.NIGHT_VISION_COLOR
        Lighting.GlobalShadows = false
        -- Добавляем PointLight к персонажу для подсветки
        local hrp = getHRP()
        if hrp then
            local light = hrp:FindFirstChild("NeonLight") or Instance.new("PointLight")
            light.Name = "NeonLight"
            light.Brightness = 5
            light.Range = 100
            light.Color = CONFIG.NIGHT_VISION_COLOR
            light.Parent = hrp
        end
    else
        Lighting.Ambient = originalLighting.Ambient or Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient or Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = originalLighting.Brightness or 1
        Lighting.ClockTime = originalLighting.ClockTime or 14
        Lighting.FogEnd = originalLighting.FogEnd or 1000
        Lighting.FogStart = originalLighting.FogStart or 0
        Lighting.FogColor = originalLighting.FogColor or Color3.fromRGB(192, 192, 192)
        Lighting.GlobalShadows = originalLighting.GlobalShadows ~= false
        local hrp = getHRP()
        if hrp and hrp:FindFirstChild("NeonLight") then
            hrp.NeonLight:Destroy()
        end
    end
end

-- ========== WORLD CLEANUP ==========
local function removeWorldObjects()
    local removed = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            local shouldRemove = false
            for _, kw in ipairs(CONFIG.TREE_KEYWORDS) do
                if name:find(kw) and not name:find("treehouse") then
                    shouldRemove = true
                    break
                end
            end
            if not shouldRemove then
                for _, kw in ipairs(CONFIG.GRASS_KEYWORDS) do
                    if name:find(kw) then
                        shouldRemove = true
                        break
                    end
                end
            end
            if shouldRemove then
                table.insert(removedObjects, {obj = obj, parent = obj.Parent})
                obj.Parent = nil
                removed = removed + 1
            end
        end
        if obj:IsA("ParticleEmitter") then
            if obj.Name:lower():find("fog") or obj.Name:lower():find("mist") then
                obj.Enabled = false
            end
        end
    end
    return removed
end

local function restoreWorldObjects()
    for _, data in ipairs(removedObjects) do
        if data.obj then
            data.obj.Parent = data.parent
        end
    end
    removedObjects = {}
end

local function setWorldClean(state)
    worldCleanEnabled = state
    WorldBtn.Text = "CLEAN WORLD: " .. (state and "ВКЛ" or "ВЫКЛ") .. " (R)"
    if state then
        local count = removeWorldObjects()
        print("[WORLD] Removed " .. count .. " objects")
    else
        restoreWorldObjects()
        print("[WORLD] Restored objects")
    end
end

-- ========== CHUNK LOADER ==========
local function loadAllChunks()
    print("[CHUNK] Loading all chunks...")
    local hrp = getHRP()
    if not hrp then return end
    -- Принудительно прогружаем все части карты
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 0
        end
    end
    -- Если есть StreamingEnabled — отключаем его
    pcall(function()
        workspace.StreamingEnabled = false
    end)
    print("[CHUNK] Done")
end

-- ========== ESP ==========
local espObjects = {}

local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

local function createESP(target, color, label)
    if not target then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 4, 4)
    box.Transparency = 0.5
    box.Color3 = color
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = target
    box.Parent = target
    table.insert(espObjects, box)

    if label then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 120, 0, 20)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = target
        billboard.Parent = target
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = color
        text.Font = Enum.Font.GothamBold
        text.TextSize = 10
        text.TextStrokeTransparency = 0
        text.Parent = billboard
        table.insert(espObjects, billboard)
    end
end

local function updateESP()
    clearESP()
    if not espEnabled then return end

    local items = workspace:FindFirstChild("Items")
    if items then
        for _, obj in ipairs(items:GetChildren()) do
            if obj.Name:lower():find("chest") then
                if obj.Name == "ChestDEF" then
                    createESP(obj, CONFIG.ESP_STRONGHOLD_COLOR, "★ STRONGHOLD CHEST ★")
                else
                    createESP(obj, CONFIG.ESP_CHEST_COLOR, obj.Name)
                end
            elseif obj.Name:lower() == "log" then
                createESP(obj, CONFIG.ESP_LOG_COLOR, "LOG")
            elseif obj:IsA("Model") or obj:IsA("BasePart") then
                createESP(obj, CONFIG.ESP_ITEM_COLOR, obj.Name)
            end
        end
    end

    local map = workspace:FindFirstChild("Map")
    if map then
        for _, landmark in ipairs(map:GetDescendants()) do
            if landmark:IsA("Model") then
                local n = landmark.Name:lower()
                if n:find("hut") or n:find("cabin") or n:find("tower") or n:find("lodge") or n:find("shack") or n:find("house") or n:find("treehouse") or n:find("castle") or n:find("shed") or n:find("camp") or n:find("cellar") or n:find("jail") or n:find("smith") then
                    createESP(landmark, CONFIG.ESP_BUILDING_COLOR, landmark.Name)
                end
            end
        end
    end

    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, npc in ipairs(chars:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                createESP(npc, CONFIG.ESP_NPC_COLOR, npc.Name)
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
                if d < dist then dist = d nearest = obj end
            end
        end
    end
    return nearest
end

local function findStrongholdChest()
    local cg = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Campground")
    if not cg then return nil end
    for _, obj in ipairs(cg:GetDescendants()) do
        if obj.Name == "ChestDEF" then return obj end
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
    elseif input.KeyCode == Enum.KeyCode.R then setWorldClean(not worldCleanEnabled)
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
WorldBtn.MouseButton1Click:Connect(function() setWorldClean(not worldCleanEnabled) end)
TpChestBtn.MouseButton1Click:Connect(function()
    local chest = findNearestChest()
    if chest then teleportTo(chest) end
end)
TpStrongBtn.MouseButton1Click:Connect(function()
    local strong = findStrongholdChest()
    if strong then teleportTo(strong) end
end)
ChunkBtn.MouseButton1Click:Connect(function()
    loadAllChunks()
    ChunkBtn.Text = "ЧАНКИ ЗАГРУЖЕНЫ"
    task.wait(2)
    ChunkBtn.Text = "ЗАГРУЗИТЬ ЧАНКИ"
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
Main.Position = UDim2.new(0.5, -140, 0.15, 30)
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -140, 0.15, 0)
}):Play()

print("[NEON] v3.0 WORLD CONTROL loaded. Keys: F=fly, G=noclip, H=esp, B=anti-tp, N=night, R=clean, T=chest, Y=stronghold")
