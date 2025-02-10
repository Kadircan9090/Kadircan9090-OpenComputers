local GUI = require("GUI")
local event = require("event")

-- Workspace oluştur
local workspace = GUI.workspace()

-- Başlık ekle
workspace:addChild(GUI.label(2, 2, 50, 1, 0xFFFFFF, "Mob Duplication GUI v4.1"))

-- Essence üretim grafiği çerçevesi
local graph = workspace:addChild(GUI.chart(2, 4, 50, 15, 0x333333, 0xFFFFFF, 0x00FF00, 0x00FF00, "Time", "mB", true, {}))
graph.values = {0, 100, -50, 200, 150, -100} -- Örnek veriler

-- Essence durumu
workspace:addChild(GUI.label(55, 4, 20, 1, 0xFFFFFF, "Essence Level:"))
local essenceBar = workspace:addChild(GUI.progressBar(55, 6, 20, 0x00FF00, 0xFFFFFF, 0x000000, 97, true, true, "", "%"))

-- Essence miktarı
workspace:addChild(GUI.label(55, 8, 40, 1, 0xFFFFFF, "13974929 Essence"))

-- Öğe seviyeleri çerçevesi
workspace:addChild(GUI.label(55, 10, 20, 1, 0xFFFFFF, "Item Levels:"))
workspace:addChild(GUI.label(55, 12, 20, 1, 0xFFFFFF, "Redstone:"))
local redstoneBar = workspace:addChild(GUI.progressBar(65, 12, 20, 0xFF0000, 0xFFFFFF, 0x000000, 80, false, false, "", ""))

workspace:addChild(GUI.label(55, 14, 20, 1, 0xFFFFFF, "Gold:"))
local goldBar = workspace:addChild(GUI.progressBar(65, 14, 20, 0xFFD700, 0xFFFFFF, 0x000000, 50, false, false, "", ""))

workspace:addChild(GUI.label(55, 16, 20, 1, 0xFFFFFF, "Iron:"))
local ironBar = workspace:addChild(GUI.progressBar(65, 16, 20, 0xAAAAAA, 0xFFFFFF, 0x000000, 60, false, false, "", ""))

-- Başlatma ve kapatma butonları
local startButton = workspace:addChild(GUI.roundedButton(2, 20, 20, 3, 0x00FF00, 0xFFFFFF, 0xFFFFFF, 0x00FF00, "Start"))
local shutdownButton = workspace:addChild(GUI.roundedButton(25, 20, 20, 3, 0xFF0000, 0xFFFFFF, 0xFFFFFF, 0xFF0000, "Shutdown"))
local exitButton = workspace:addChild(GUI.roundedButton(48, 20, 20, 3, 0xFFFFFF, 0x000000, 0x000000, 0xFFFFFF, "Exit"))

-- Buton işlevleri
startButton.onTouch = function()
    GUI.alert("Starting system...")
end

shutdownButton.onTouch = function()
    GUI.alert("Shutting down system...")
end

exitButton.onTouch = function()
    workspace:stop()
end

-- Sürekli güncelleme döngüsü
workspace.eventHandler = function(workspace, object, e1)
    -- Grafiği güncellemek için (örnek veri ekleme)
    if e1 == "touch" then
        table.insert(graph.values, math.random(-100, 200))
        if #graph.values > 10 then
            table.remove(graph.values, 1)
        end

        -- Çubukları güncelleme (örnek veriler)
        essenceBar.value = math.random(50, 100)
        redstoneBar.value = math.random(0, 100)
        goldBar.value = math.random(0, 100)
        ironBar.value = math.random(0, 100)
    end
end

-- Çalıştır
workspace:draw()
workspace:start()
