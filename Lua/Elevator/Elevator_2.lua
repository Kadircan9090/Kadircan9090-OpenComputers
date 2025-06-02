local component = require("component")
local event = require("event")
local term = require("term")
local sides = require("sides")

-- Asansör controller'a bağlı redstone çıkışları
local rs = component.redstone

-- Katların sinyal haritası (örnek: arka çıkış, farklı sinyaller)
local floors = {
  ["1"] = 1,  -- arka çıkıştan 1 sinyal seviyesi
  ["2"] = 2,
  ["3"] = 3
}

-- Belirtilen kata git
local function goToFloor(floor)
  local signal = floors[floor]
  if not signal then
    print("Geçersiz kat seçimi!")
    return
  end

  rs.setOutput(sides.back, signal)
  print("Asansör " .. floor .. ". kata gönderiliyor...")
  os.sleep(1) -- sinyal süresi
  rs.setOutput(sides.back, 0)
end

-- Menü fonksiyonu
local function main()
  term.clear()
  print("Thut's Elevator Kontrol Paneli")
  print("-----------------------------")

  while true do
    print("\nMevcut Katlar:")
    for k, _ in pairs(floors) do
      print("Kat " .. k)
    end

    io.write("Lütfen bir kat numarası girin ('exit' ile çık): ")
    local input = io.read()

    if input == "exit" then
      break
    end

    goToFloor(input)
  end
end

main()
