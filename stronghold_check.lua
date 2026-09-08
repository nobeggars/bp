-- Инициализация библиотеки Orion (популярная UI-библиотека для скриптов)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexsoftware/Orion/main/source')))()

-- Создаем главное окно
local Window = OrionLib:MakeWindow({
    Name = "Security Test Panel | Parody Game", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Loading Security Test..."
})

-- Создаем вкладку
local Tab = Window:MakeTab({
    Name = "Exploit Checks",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Текст статуса
local StatusLabel = Tab:AddLabel("Статус Стронгхолда: Ожидание проверки...")

-- Кнопка для поиска сундука/стронгхолда
Tab:AddButton({
    Name = "Найти Стронгхолд с алмазами",
    Callback = function()
        local found = false
        local foundPath = ""
        
        -- Перебираем все объекты на карте
        for _, obj in pairs(workspace:GetDescendants()) do
            -- Укажи здесь точное название твоего сундука/стронгхолда или его деталей
            -- Например: "Stronghold", "DiamondChest", "Diamonds"
            if obj.Name == "Stronghold" or obj.Name == "DiamondChest" then
                found = true
                foundPath = obj:GetFullName()
                break
            end
        end
        
        if found then
            StatusLabel:Set("Статус: НАЙДЕН! Уязвимость открыта.")
            OrionLib:MakeNotification({
                Name = "Уязвимость найдена",
                Content = "Стронгхолд обнаружен по пути: " .. foundPath,
                Image = "rbxassetid://4483345998",
                Time = 10
            })
        else
            StatusLabel:Set("Статус: НЕ НАЙДЕН. Безопасно.")
            OrionLib:MakeNotification({
                Name = "Безопасно",
                Content = "Стронгхолд не найден в Workspace.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end    
})

-- Телепорт к стронгхолду (типичная функция читеров)
Tab:AddButton({
    Name = "Телепорт к Стронгхолду (ESP)",
    Callback = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj.Name == "Stronghold" or obj.Name == "DiamondChest") and obj:IsA("Model") or obj:IsA("BasePart") then
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    -- Если это модель, телепортируемся к её PrimaryPart, если обычный Part - прямо к нему
                    local targetCFrame = obj:IsA("Model") and obj.PrimaryPart.CFrame or obj.CFrame
                    character.HumanoidRootPart.CFrame = targetCFrame
                    break
                end
            end
        end
    end    
})

-- Завершение инициализации UI
OrionLib:Init()
