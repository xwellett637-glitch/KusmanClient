_G.Kusman = _G.Kusman or {}
local K = _G.Kusman

-- === ESP ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

K.GeneratorHighlights = {}
K.PlayersHighlights = {}
K.originalSizes = {}
K.tinyActive = false
K.playerHighlight = nil

-- Список имён убийц
K.KillerNames = {
    "Killer","Murderer","Stalker","Slasher","The Slasher","The Stalker",
    "The Masked","Masked","The Hidden","Hidden","The Abysswalker","Abysswalker",
    "The Veil","Veil","The Veli","Veli","The Killer","The Cure","Cure",
    "The Hunter","Hunter","The Jacket","Jacket","Michael Myers","Myers",
    "Jason Voorhees","Jason","Jeff the Killer","Jeff"
}

function K.IsKiller(player)
    if player == LocalPlayer then return false end
    local c = player.Character
    if not c then return false end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and (t.Name:lower():find("dagger") or t.Name:lower():find("knife") or t.Name:lower():find("blade")) then
            return true
        end
    end
    for _, kn in ipairs(K.KillerNames) do
        if player.Name:lower() == kn:lower() or player.DisplayName:lower() == kn:lower() then return true end
    end
    if player.Team and player.Team.Name:lower() == "killer" then return true end
    return false
end

function K.IsDowned()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BoolValue") and (v.Name:lower():find("down") or v.Name:lower():find("knocked")) and v.Value == true then
            return true
        end
    end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.FallenDown or state == Enum.HumanoidStateType.PlatformStanding then
            return true
        end
    end
    return false
end

function K.ApplySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if K.IsDowned() then
        if hum.WalkSpeed ~= 8 then hum.WalkSpeed = 8 end
    else
        if hum.WalkSpeed ~= K.Settings.SpeedValue then hum.WalkSpeed = K.Settings.SpeedValue end
    end
end

function K.UpdateGensESP()
    for _, h in ipairs(K.GeneratorHighlights) do pcall(function() h:Destroy() end) end
    K.GeneratorHighlights = {}
    if not K.Settings.ESPGens then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillColor = Color3.fromRGB(255,255,0)
            hl.FillTransparency = 0.4
            hl.OutlineColor = Color3.fromRGB(255,255,0)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = obj
            table.insert(K.GeneratorHighlights, hl)
        end
    end
end

function K.UpdatePlayersESP()
    for _, h in ipairs(K.PlayersHighlights) do pcall(function() h:Destroy() end) end
    K.PlayersHighlights = {}
    if not K.Settings.ESPPlayers and not K.Settings.KillerESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if not player.Character then continue end
        local isK = K.IsKiller(player)
        local color
        if player == LocalPlayer then
            color = Color3.fromRGB(255,255,255)
        elseif isK and K.Settings.KillerESP then
            color = Color3.fromRGB(255,50,50)
        elseif player.Team == LocalPlayer.Team and K.Settings.ESPPlayers then
            color = Color3.fromRGB(80,180,255)
        elseif K.Settings.ESPPlayers then
            color = Color3.fromRGB(255,140,50)
        else
            continue
        end
        local hl = Instance.new("Highlight")
        hl.Adornee = player.Character
        hl.FillColor = color
        hl.FillTransparency = 0.4
        hl.OutlineColor = color
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = player.Character
        table.insert(K.PlayersHighlights, hl)
    end
end

function K.SaveBodySizes(character)
    K.originalSizes = {}
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:match("Head|Torso|Arm|Leg|HumanoidRootPart") then
            K.originalSizes[part] = part.Size
        end
    end
end

function K.SetBodyScale(character, scale)
    for part, originalSize in pairs(K.originalSizes) do
        if part and part.Parent then
            part.Size = originalSize * scale
        end
    end
end

function K.UpdateTinyHitbox()
    local char = LocalPlayer.Character
    if not char then return end
    if K.Settings.TinyHitbox then
        if not K.tinyActive then
            K.SaveBodySizes(char)
            K.SetBodyScale(char, 0.95)
            K.tinyActive = true
        end
        if not K.playerHighlight then
            K.playerHighlight = Instance.new("Highlight")
            K.playerHighlight.Adornee = char
            K.playerHighlight.FillColor = Color3.fromRGB(255,255,255)
            K.playerHighlight.FillTransparency = 0.85
            K.playerHighlight.OutlineColor = Color3.fromRGB(255,255,255)
            K.playerHighlight.OutlineTransparency = 0.5
            K.playerHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            K.playerHighlight.Parent = char
        end
    else
        if K.tinyActive then
            for part, origSize in pairs(K.originalSizes) do
                if part and part.Parent then
                    part.Size = origSize
                end
            end
            K.originalSizes = {}
            K.tinyActive = false
        end
        if K.playerHighlight then
            K.playerHighlight:Destroy()
            K.playerHighlight = nil
        end
    end
end

function K.UpdateFastTurn()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if K.Settings.FastTurn then
        hum.TurnSpeed = 360
    else
        hum.TurnSpeed = 120
    end
end

-- Прицел (Crosshair)
K.crosshair = nil
function K.CreateCrosshair()
    if K.crosshair then return end
    K.crosshair = Drawing.new("Circle")
    K.crosshair.Thickness = 2
    K.crosshair.NumSides = 24
    K.crosshair.Color = Color3.fromRGB(255,255,255)
    K.crosshair.Filled = false
    K.crosshair.Transparency = 0.7
    K.crosshair.Visible = true
    K.crosshair.Radius = 6
    local dot = Drawing.new("Circle")
    dot.Thickness = 1
    dot.NumSides = 12
    dot.Color = Color3.fromRGB(255,255,255)
    dot.Filled = true
    dot.Transparency = 0.5
    dot.Visible = true
    dot.Radius = 1.5
    K.crosshair.Dot = dot
end

function K.DestroyCrosshair()
    if K.crosshair then
        if K.crosshair.Dot then K.crosshair.Dot:Destroy() end
        K.crosshair:Destroy()
        K.crosshair = nil
    end
end

function K.UpdateCrosshair()
    if K.Settings.Crosshair then
        if not K.crosshair then K.CreateCrosshair() end
        local viewport = Camera.ViewportSize
        local center = Vector2.new(viewport.X/2, viewport.Y/2)
        K.crosshair.Position = center
        if K.crosshair.Dot then K.crosshair.Dot.Position = center end
    else
        K.DestroyCrosshair()
    end
end

-- Основной цикл ядра (запускается в gui.lua)
function K.StartCoreLoop()
    task.spawn(function()
        while true do
            if K.Settings.ESPGens then K.UpdateGensESP() end
            K.UpdatePlayersESP()
            task.wait(1.2)
        end
    end)

    RunService.RenderStepped:Connect(function()
        K.ApplySpeed()
        if K.Settings.TinyHitbox then K.UpdateTinyHitbox() end
        if K.Settings.FastTurn then K.UpdateFastTurn() end
        if K.Settings.Crosshair then K.UpdateCrosshair() end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        K.ApplySpeed()
        if K.Settings.TinyHitbox then K.UpdateTinyHitbox() end
        if K.Settings.FastTurn then K.UpdateFastTurn() end
    end)
end