-- loadstring(game:HttpGet("RAW_ССЫЛКА_НА_ЭТОТ_ФАЙЛ"))()
local function loadModule(url)
    local success, result = pcall(game.HttpGet, game, url, true)
    if success then
        loadstring(result)()
    else
        warn("Ошибка загрузки модуля: " .. url)
    end
end

-- ✅ Твои настоящие данные для подключения
local BASE = "https://raw.githubusercontent.com/xwellett637-glitch/KusmanClient/refs/heads/main/"

loadModule(BASE .. "config.lua")
loadModule(BASE .. "core.lua")
loadModule(BASE .. "gui.lua")
