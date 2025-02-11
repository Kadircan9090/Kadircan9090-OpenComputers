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

-- Çerçeve çizimi
local function drawBox(x1, y1, x2, y2, title)
  gpu.setForeground(0xFFFFFF) -- Beyaz renk
  for x = x1, x2 do
    gpu.set(x, y1, "-")
    gpu.set(x, y2, "-")
  end
  for y = y1, y2 do
    gpu.set(x1, y, "|")
    gpu.set(x2, y, "|")
  end
  gpu.set(x1, y1, "+")
  gpu.set(x2, y1, "+")
  gpu.set(x1, y2, "+")
  gpu.set(x2, y2, "+")
  if title then
    gpu.set(x1 + 2, y1, "[" .. title .. "]")
  end
end

-- Statik UI
local function drawStaticUI()
  term.clear()
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000080) -- Lacivert arka plan
  gpu.fill(1, 1, 80, 1, " ") -- Başlık çubuğu
  gpu.set(30, 1, " REACTOR CONTROL PANEL ")
  gpu.setBackground(0x000000) -- Siyah arka plan

  -- Çerçeve alanları
  drawBox(1, 3, 39, 12, "Reactor 1")
  drawBox(41, 3, 79, 12, "Reactor 2")
  drawBox(1, 14, 39, 20, "Backup System")
  drawBox(41, 14, 79, 20, "System Info")
end

-- Progress Bar Çizimi
local function drawProgressBar(x, y, width, percent, color)
  local filled = math.floor(width * percent / 100)
  gpu.setForeground(color)
  gpu.set(x, y, string.rep("█", filled))
  gpu.setForeground(0x444444)
  gpu.set(x + filled, y, string.rep("░", width - filled))
end

-- Dinamik Veriler
local function updateUI()
  -- Reactor 1
  local r1_power = reactor.getEnergyStored()
  local r1_heat = reactor.getHeatLevel()
  gpu.setForeground(r1_power > 5000 and 0x00FF00 or 0xFF0000) -- Yeşil veya Kırmızı
  gpu.set(3, 4, "Power: " .. r1_power .. " RF")
  gpu.set(3, 5, "Heat: " .. r1_heat)
  gpu.set(3, 6, "Cooling Rate: " .. reactor.getReactorCoolingRate())
  drawProgressBar(3, 7, 35, r1_power / reactor.getMaxEnergyStored() * 100, 0x00FF00)

  -- Reactor 2
  local r2_power = reactor2.getEnergyStored()
  local r2_heat = reactor2.getHeatLevel()
  gpu.setForeground(r2_power > 5000 and 0x00FF00 or 0xFF0000) -- Yeşil veya Kırmızı
  gpu.set(43, 4, "Power: " .. r2_power .. " RF")
  gpu.set(43, 5, "Heat: " .. r2_heat)
  gpu.set(43, 6, "Cooling Rate: " .. reactor2.getReactorCoolingRate())
  drawProgressBar(43, 7, 35, r2_power / reactor2.getMaxEnergyStored() * 100, 0x00FF00)

  -- Backup System
  local turbine_speed = turbine.getSpeed()
  local diesel_level = (rs.getBundledInput(sides.left, colors.cyan) / 195) * 100
  gpu.setForeground(0xFFFFFF)
  gpu.set(3, 15, "Turbine Speed: " .. turbine_speed)
  drawProgressBar(3, 16, 35, turbine_speed / 20000 * 100, 0x0000FF) -- Mavi bar (Turbine hız)
  gpu.set(3, 17, "Diesel Level: " .. diesel_level .. "%")
  drawProgressBar(3, 18, 35, diesel_level, 0xFFFF00)

  -- System Info
  local total_power = r1_power + r2_power
  gpu.setForeground(total_power > 2000 and 0x00FF00 or 0xFF0000)
  gpu.set(43, 15, "Total Power: " .. total_power .. " RF")
  gpu.set(43, 16, "Backup Active: " .. tostring(backup))
end

-- Ana Döngü
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