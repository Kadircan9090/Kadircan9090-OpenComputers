local GUI = require("GUI")
local component = require("component")
local computer = require("computer")
local sides = require("sides")
local colors = require("colors")
local event = require("event")
local rs = component.redstone

-- Reaktör ve türbin bilgileri
local reactor = component.proxy("aa77a84c-ecd3-4678-98d7-29961d71b252")
local reactor2 = component.proxy("865789e6-fd68-45a2-a2a0-4af145a819f0")
local turbine = component.it_gas_turbine

-- GUI başlatma
local workspace = GUI.workspace()

-- Başlık
workspace:addChild(GUI.label(2, 2, 50, 1, 0xFFFFFF, "Power Management System"))

-- Essence seviyesini temsil eden çubuk
local essenceBar = workspace:addChild(GUI.progressBar(2, 4, 50, 0x00FF00, 0xFFFFFF, 0x000000, 0, true, true, "Energy Level: ", "%"))

-- Reaktör sıcaklık bilgileri
workspace:addChild(GUI.label(2, 6, 50, 1, 0xFFFFFF, "Reactor 1 Temperature:"))
local reactor1Temp = workspace:addChild(GUI.label(25, 6, 20, 1, 0xFFFFFF, "N/A"))

workspace:addChild(GUI.label(2, 7, 50, 1, 0xFFFFFF, "Reactor 2 Temperature:"))
local reactor2Temp = workspace:addChild(GUI.label(25, 7, 20, 1, 0xFFFFFF, "N/A"))

-- Türbin durumu
workspace:addChild(GUI.label(2, 9, 50, 1, 0xFFFFFF, "Turbine Speed:"))
local turbineSpeed = workspace:addChild(GUI.label(25, 9, 20, 1, 0xFFFFFF, "N/A"))

-- Çıkış düğmesi
local exitButton = workspace:addChild(GUI.roundedButton(2, 12, 20, 3, 0xFFFFFF, 0x000000, 0x000000, 0xFFFFFF, "Exit"))

-- Çıkış düğmesi işlevi
exitButton.onTouch = function()
    workspace:stop()
end

-- Bilgileri güncelleme fonksiyonu
local function updateValues()
    -- Toplam enerji seviyesi
    local totalEnergy = reactor.getEnergyStored() + reactor2.getEnergyStored()
    essenceBar.value = (totalEnergy / 2000000) * 100 -- Maksimum değer 2.000.000 kabul edildi

    -- Reaktör sıcaklık bilgileri
    reactor1Temp.text = tostring(reactor.getHeatLevel()) .. " K"
    reactor2Temp.text = tostring(reactor2.getHeatLevel()) .. " K"

    -- Türbin hızı
    turbineSpeed.text = tostring(turbine.getSpeed()) .. " RPM"
end

-- Sürekli döngü
workspace.eventHandler = function(workspace, object, e1)
    if e1 == "update" then
        updateValues()
    end
end

-- Çalıştırma
workspace:draw()
workspace:start()