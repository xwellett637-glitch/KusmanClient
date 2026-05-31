_G.Kusman = _G.Kusman or {}
local K = _G.Kusman

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

K.MenuVisible = true
K.ScreenGui = nil
K.MenuFrame = nil
K.SpeedSliderFill = nil
K.SpeedLabel = nil
K.Labels = {}

function K.CreateMenu()
    if K.ScreenGui then pcall(function() K.ScreenGui:Destroy() end) end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then pg = LocalPlayer:WaitForChild("PlayerGui") end

    K.ScreenGui = Instance.new("ScreenGui")
    K.ScreenGui.Name = "KusmanMenu"
    K.ScreenGui.ResetOnSpawn = false
    K.ScreenGui.Parent = pg

    K.MenuFrame = Instance.new("Frame")
    K.MenuFrame.Size = UDim2.new(0, 280, 0, 230)
    K.MenuFrame.Position = UDim2.new(1, -295, 0, 10)
    K.MenuFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
    K.MenuFrame.BorderSizePixel = 0
    K.MenuFrame.Parent = K.ScreenGui
    Instance.new("UICorner").CornerRadius = UDim.new(0,6)
    Instance.new("UICorner").Parent = K.MenuFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,25)
    title.BackgroundColor3 = Color3.fromRGB(255,50,80)
    title.Text = "KUSMAN — FINAL"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.Parent = K.MenuFrame

    local items = {
        {key="1", name="Gens ESP", cfg="ESPGens"},
        {key="2", name="Players ESP", cfg="ESPPlayers"},
        {key="3", name="Killer ESP", cfg="KillerESP"},
        {key="4", name="Tiny Hitbox", cfg="TinyHitbox"},
        {key="5", name="Fast Turn", cfg="FastTurn"},
        {key="6", name="Crosshair", cfg="Crosshair"},
    }
    for i, item in ipairs(items) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,0,18)
        lbl.Position = UDim2.new(0,10,0,25+(i-1)*18)
        lbl.BackgroundTransparency = 1
        lbl.Text = "["..item.key.."] "..item.name..": OFF"
        lbl.TextColor3 = Color3.fromRGB(200,80,80)
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = K.MenuFrame
        K.Labels[item.cfg] = lbl
    end

    -- Ползунок скорости
    K.SpeedLabel = Instance.new("TextLabel")
    K.SpeedLabel.Size = UDim2.new(1,0,0,18)
    K.SpeedLabel.Position = UDim2.new(0,10,0,25+6*18+5)
    K.SpeedLabel.BackgroundTransparency = 1
    K.SpeedLabel.Text = "Speed: "..K.Settings.SpeedValue
    K.SpeedLabel.TextColor3 = Color3.fromRGB(255,200,100)
    K.SpeedLabel.TextSize = 10
    K.SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    K.SpeedLabel.Font = Enum.Font.Gotham
    K.SpeedLabel.Parent = K.MenuFrame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.7,0,0,4)
    sliderBg.Position = UDim2.new(0,10,0,25+7*18+7)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,70)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = K.MenuFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0,2)
    Instance.new("UICorner").Parent = sliderBg

    K.SpeedSliderFill = Instance.new("Frame")
    K.SpeedSliderFill.Size = UDim2.new((K.Settings.SpeedValue-16)/(50-16),0,1,0)
    K.SpeedSliderFill.BackgroundColor3 = Color3.fromRGB(255,70,70)
    K.SpeedSliderFill.BorderSizePixel = 0
    K.SpeedSliderFill.Parent = sliderBg
    Instance.new("UICorner").CornerRadius = UDim.new(0,2)
    Instance.new("UICorner").Parent = K.SpeedSliderFill

    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local newVal = math.floor(16 + (50-16) * pos)
            K.Settings.SpeedValue = newVal
            K.SpeedSliderFill.Size = UDim2.new(pos,0,1,0)
            K.SpeedLabel.Text = "Speed: "..K.Settings.SpeedValue
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local newVal = math.floor(16 + (50-16) * pos)
            K.Settings.SpeedValue = newVal
            K.SpeedSliderFill.Size = UDim2.new(pos,0,1,0)
            K.SpeedLabel.Text = "Speed: "..K.Settings.SpeedValue
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    K.UpdateMenu()
end

function K.UpdateMenu()
    for cfg, lbl in pairs(K.Labels) do
        local state = K.Settings[cfg]
        local key = (cfg=="ESPGens" and "1" or cfg=="ESPPlayers" and "2" or cfg=="KillerESP" and "3" or cfg=="TinyHitbox" and "4" or cfg=="FastTurn" and "5" or "6")
        local name = (cfg=="ESPGens" and "Gens ESP" or cfg=="ESPPlayers" and "Players ESP" or cfg=="KillerESP" and "Killer ESP" or cfg=="TinyHitbox" and "Tiny Hitbox" or cfg=="FastTurn" and "Fast Turn" or "Crosshair")
        lbl.Text = "["..key.."] "..name..": "..(state and "ON" or "OFF")
        lbl.TextColor3 = state and Color3.fromRGB(80,200,80) or Color3.fromRGB(200,80,80)
    end
    if K.SpeedLabel then
        K.SpeedLabel.Text = "Speed: "..K.Settings.SpeedValue
        if K.SpeedSliderFill then
            local pos = (K.Settings.SpeedValue-16)/(50-16)
            K.SpeedSliderFill.Size = UDim2.new(pos,0,1,0)
        end
    end
end

function K.SetupHotkeys()
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.One then
            K.Settings.ESPGens = not K.Settings.ESPGens
            K.UpdateMenu()
        elseif key == Enum.KeyCode.Two then
            K.Settings.ESPPlayers = not K.Settings.ESPPlayers
            K.UpdateMenu()
        elseif key == Enum.KeyCode.Three then
            K.Settings.KillerESP = not K.Settings.KillerESP
            K.UpdateMenu()
        elseif key == Enum.KeyCode.Four then
            K.Settings.TinyHitbox = not K.Settings.TinyHitbox
            K.UpdateMenu()
        elseif key == Enum.KeyCode.Five then
            K.Settings.FastTurn = not K.Settings.FastTurn
            K.UpdateMenu()
        elseif key == Enum.KeyCode.Six then
            K.Settings.Crosshair = not K.Settings.Crosshair
            K.UpdateMenu()
        elseif key == Enum.KeyCode.F1 then
            K.MenuVisible = not K.MenuVisible
            if K.MenuFrame then K.MenuFrame.Visible = K.MenuVisible end
        end
    end)
end

-- Запуск
K.CreateMenu()
K.SetupHotkeys()
K.StartCoreLoop()
