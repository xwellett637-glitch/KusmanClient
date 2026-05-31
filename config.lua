_G.Kusman = _G.Kusman or {}
local Config = _G.Kusman

Config.Settings = {
    ESPGens = false,
    ESPPlayers = false,
    KillerESP = false,
    TinyHitbox = false,
    FastTurn = false,
    Crosshair = false,
    SpeedValue = 20,
}

Config.Hotkeys = {
    [Enum.KeyCode.One] = "ESPGens",
    [Enum.KeyCode.Two] = "ESPPlayers",
    [Enum.KeyCode.Three] = "KillerESP",
    [Enum.KeyCode.Four] = "TinyHitbox",
    [Enum.KeyCode.Five] = "FastTurn",
    [Enum.KeyCode.Six] = "Crosshair",
    [Enum.KeyCode.F1] = "ToggleMenu",
}