local component = require("component")
local sides = require("sides")
local term = require("term")
local gpu = component.gpu
local adapter = component.proxy(component.get("604cd1e3-331e-40c0-8382-9175f322093e"))

local side = sides.top  -- Adapter'ın bağlı olduğu taraf

-- Renk indeksleri (bundled cable için)
local RED = 0
local YELLOW = 1
local GREEN = 5

function clear()
  term.clear()
  term.setCursor(1,1)
end

function drawState(state)
  clear()
  if state == "red" then
    gpu.setForeground(0xFF0000)
    print("🟥 KIRMIZI - DUR")
  elseif state == "yellow" then
    gpu.setForeground(0xFFFF00)
    print("🟨 SARI - HAZIRLAN")
  elseif state == "green" then
    gpu.setForeground(0x00FF00)
    print("🟩 YEŞİL - GEÇ")
  end
  gpu.setForeground(0xFFFFFF) -- Varsayılan rengi geri ayarla
end

function setLights(r, y, g)
  adapter.setBundledOutput(side, RED, r and 255 or 0)
  adapter.setBundledOutput(side, YELLOW, y and 255 or 0)
  adapter.setBundledOutput(side, GREEN, g and 255 or 0)
end

while true do
  -- Kırmızı ışık
  setLights(true, false, false)
  drawState("red")
  os.sleep(20)

  -- Sarı ışık
  setLights(false, true, false)
  drawState("yellow")
  os.sleep(1)

  -- Yeşil ışık
  setLights(false, false, true)
  drawState("green")
  os.sleep(5)
end