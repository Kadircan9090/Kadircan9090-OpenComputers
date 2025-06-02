local component = require("component")
local sides = require("sides")
local colors = require("colors")
local os = require("os")

-- Adapter bileşenini bul
local adapter = component.proxy(component.list("adapter")())

-- Bağlı olduğu yön (örnek: doğu yönü)
local cableSide = sides.east  -- ihtiyaca göre değiştir

-- Işıkları kontrol et
local function setLight(color)
  adapter.setBundledOutput(cableSide, color)
end

while true do
  -- 1. Kırmızı ışık (dur)
  setLight(colors.red)
  print("Kırmızı ışık: DUR")
  os.sleep(5)

  -- 2. Sarı ışık (hazırlan)
  setLight(colors.yellow)
  print("Sarı ışık: HAZIRLAN")
  os.sleep(2)

  -- 3. Yeşil ışık (geç)
  setLight(colors.green)
  print("Yeşil ışık: GEÇ")
  os.sleep(5)

  -- 4. Sarı ışık (yavaşla)
  setLight(colors.yellow)
  print("Sarı ışık: YAVAŞLA")
  os.sleep(2)
end
