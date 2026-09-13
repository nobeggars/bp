--[[
    GHOSTWARE MINIMAL v1.1 — SAFE VERSION
    Author: I.S.-1
    ONLY: Fly, Noclip, Anti-TP
    NO: gethui, setclipboard, Highlight
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local uiName = "GhostWareMinimal"

-- STATE
local flyEnabled = false
local noclipEnabled = false
local bypassEnabled = false
local bypassConnection = nil
local savedPos = nil
local savedCF = nil

-- CLEANUP (безопасный)
pcall(function()
    if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
end)
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild(uiName) then LocalPlayer.PlayerGui[uiName]:Destroy() end
end)

-- UI (безопасный)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false

-- Пробуем разные варианты parent
local parentSet = false
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
        parentSet = true
    end
end)
if not parentSet then
    pcall(function()
        ScreenGui.Parent = CoreGui
        parentSet = true
    end)
end
if not parentSet then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 180)
Main.Position = UDim2.new(0.5, -125, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "★ GHOSTWARE MINIMAL ★"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local function CreateBtn(text, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local FlyBtn = CreateBtn("FLY & NOCLIP: ВЫКЛ", 45)
local AntiTpBtn = CreateBtn("ANTI-TP: ВЫКЛ", 85)

local function getHRP()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- FLY & NOCLIP
FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    noclipEnabled = flyEnabled
    
    if flyEnabled then
        FlyBtn.Text = "FLY & NOCLIP: ВКЛ"
        FlyBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        local hrp = getHRP()
        if hrp then
            local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end
        end
    else
        FlyBtn.Text = "FLY & NOCLIP: ВЫКЛ"
        FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

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
    if not flyEnabled then return end
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
        if md.Magnitude > 0 then
            move = (Camera.CFrame.LookVector * (md.Z * -1)) + (Camera.CFrame.RightVector * md.X)
        end
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    
    if move.Magnitude > 0 then hrp.Velocity = move.Unit * 100
    else hrp.Velocity = Vector3.new(0, 0, 0) end
end)

-- ANTI-TP
AntiTpBtn.MouseButton1Click:Connect(function()
    bypassEnabled = not bypassEnabled
    
    if bypassEnabled then
        AntiTpBtn.Text = "ANTI-TP: ВКЛ"
        AntiTpBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        
        local hrp = getHRP()
        if hrp then
            savedPos = hrp.Position
            savedCF = hrp.CFrame
            
            if bypassConnection then bypassConnection:Disconnect() end
            bypassConnection = RunService.Heartbeat:Connect(function()
                if not bypassEnabled then return end
                local h = getHRP()
                if not h then return end
                
                local dist = (h.Position - savedPos).Magnitude
                if dist > 150 then
                    h.CFrame = savedCF
                else
                    savedCF = h.CFrame
                    savedPos = h.Position
                end
            end)
        end
    else
        AntiTpBtn.Text = "ANTI-TP: ВЫКЛ"
        AntiTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        if bypassConnection then bypassConnection:Disconnect() bypassConnection = nil end
    end
end)
