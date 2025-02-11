local component = require("component")
local gpu = component.gpu
local term = require("term")
local rs = component.redstone
local sides = require("sides")
local colors = require("colors")
local computer = require("computer")

reactor = component.proxy("aa77a84c-ecd3-4678-98d7-29961d71b252")
reactor2 = component.proxy("865789e6-fd68-45a2-a2a0-4af145a819f0")
turbine = component.it_gas_turbine

-- Ekran çözünürlüğünü ayarla
gpu.setResolution(80, 25)

-- Başlık ve statik metinler
local function drawStaticUI()
  term.clear()
  gpu.setForeground(0xFFFFFF)  -- Beyaz renk
  gpu.setBackground(0x000080)  -- Lacivert arka plan
  gpu.fill(1, 1, 80, 1, " ")  -- Başlık çubuğu
  gpu.set(30, 1, " REACTOR CONTROL PANEL ")
  
  gpu.setBackground(0x000000)  -- Siyah arka plan
  gpu.set(2, 3, "Reactor 1 Status:")
  gpu.set(2, 8, "Reactor 2 Status:")
  gpu.set(2, 13, "Backup System:")
  gpu.set(2, 18, "System Info:")
end

-- Dinamik verileri güncelle
local function updateUI()
  gpu.setForeground(0x00FF00) -- Yeşil renk
  gpu.set(2, 4, "Power: " .. reactor.getEnergyStored() .. " RF")
  gpu.set(2, 5, "Heat: " .. reactor.getHeatLevel())
  gpu.set(2, 6, "Cooling Rate: " .. reactor.getReactorCoolingRate())

  gpu.set(2, 9, "Power: " .. reactor2.getEnergyStored() .. " RF")
  gpu.set(2, 10, "Heat: " .. reactor2.getHeatLevel())
  gpu.set(2, 11, "Cooling Rate: " .. reactor2.getReactorCoolingRate())

  gpu.set(2, 14, "Turbine Speed: " .. turbine.getSpeed())
  gpu.set(2, 15, "Diesel Level: " .. ((rs.getBundledInput(sides.left, colors.cyan) / 195) * 100) .. "%")
  
  gpu.set(2, 19, "Total Power: " .. (reactor.getEnergyStored() + reactor2.getEnergyStored()) .. " RF")
  gpu.set(2, 20, "Backup Active: " .. tostring(backup))
end

-- Ana döngü
local x = true
drawStaticUI()
while x do
  updateUI()
  os.sleep(1)

  -- Programı durdurmak için switch kontrolü
  if rs.getInput(sides.top) > 0 then
    gpu.setForeground(0xFFFFFF)
    gpu.set(30, 23, "System shutting down...")
    os.sleep(3)
    x = false
  end
end