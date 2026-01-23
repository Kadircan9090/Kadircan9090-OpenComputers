local component = require("component")
local term = require("term")
local event = require("event")
local sides = require("sides")
local computer = require("computer")

-- ---------- Yardımcı: ilk bulunan component türünü proxy olarak al ----------
local function tryProxy(typeName)
  local addr = component.list(typeName)()
  if addr then return component.proxy(addr) end
  return nil
end

-- ---------- Enerji kaynağı (sen hangisini kullanıyorsan onu bulsun) ----------
local cap =
  tryProxy("capacitor_bank") or
  tryProxy("ie_capacitor") or
  tryProxy("connector")

if not cap then
  error("Enerji depolama bulunamadı! (capacitor_bank / ie_capacitor / connector) components ile kontrol et.")
end

local function getEnergyStoredSafe()
  if cap.getEnergyStored then return cap.getEnergyStored() end
  if cap.energyStored then return cap.energyStored() end
  return 0
end

local function getMaxEnergyStoredSafe()
  if cap.getMaxEnergyStored then return cap.getMaxEnergyStored() end
  if cap.maxEnergyStored then return cap.maxEnergyStored() end
  return 1
end

-- ---------- Railcraft Tank (Valve yanındaki Adapter -> tank_controller) ----------
local tank = tryProxy("tank_controller")
if not tank then
  error("Railcraft Tank bulunamadı! Adapter Valve yanında mı? components içinde tank_controller var mı?")
end

-- ---------- Redstone + GPU ----------
local redstone = tryProxy("redstone")
local gpu = tryProxy("gpu")
if not redstone then error("Redstone Card yok!") end
if not gpu then error("GPU yok!") end

-- ---------- Beep Card (opsiyonel) ----------
local beep = tryProxy("beep") -- yoksa nil

-- ---------- Ekran ----------
gpu.setResolution(60, 20)
term.clear()

-- ---------- Ayarlar ----------
local startThreshold = 0.25   -- enerji %25 altı -> aç
local stopThreshold  = 0.90   -- enerji %90 üstü -> kapat
local minFuelPercent = 0.10   -- yakıt %10 altı -> alarm + zorla kapat
local side = sides.back       -- redstone çıkışı (gerekirse değiştir)

-- ---------- Durum ----------
local mode = "auto"           -- auto / manual
local running = (redstone.getOutput(side) or 0) > 0
local lastBeepAt = 0

-- ---------- Railcraft tank okuma: getTankInfo() ----------
-- Dönüş genelde: info[1].amount, info[1].capacity, info[1].name
local function getFuel()
  if tank.getTankInfo then
    local info = tank.getTankInfo()
    if info and info[1] then
      return (info[1].amount or 0), (info[1].capacity or 1), (info[1].name or "unknown")
    end
  end
  return 0, 1, "empty"
end

local function clamp01(x)
  if x < 0 then return 0 end
  if x > 1 then return 1 end
  return x
end

local function bar(x, y, percent, color)
  local width = 40
  local p = clamp01(percent)
  local fill = math.floor(width * p)
  gpu.setForeground(color)
  term.setCursor(x, y)
  term.write("[" .. string.rep("=", fill) .. string.rep(" ", width - fill) .. "]")
end

local function setGen(on)
  redstone.setOutput(side, on and 15 or 0)
  running = on
end

local function maybeBeep()
  if not beep then return end
  local now = computer.uptime()
  if now - lastBeepAt >= 1.0 then
    lastBeepAt = now
    beep.beep(1200, 0.25)
  end
end

local function draw(energyP, fuelP, fuelName)
  term.clear()

  gpu.setForeground(0x00FF00)
  term.setCursor(16, 1)
  term.write("GENERATOR CONTROL (RAILCRAFT TANK)")

  gpu.setForeground(0xFFFFFF)
  term.setCursor(5, 3)
  term.write("Energy: " .. math.floor(energyP * 100) .. "%")
  bar(5, 4, energyP, 0x00AAFF)

  term.setCursor(5, 6)
  term.write("Fuel:   " .. math.floor(fuelP * 100) .. "%")
  bar(5, 7, fuelP, (fuelP >= minFuelPercent) and 0x00FF00 or 0xFF0000)

  term.setCursor(5, 8)
  gpu.setForeground(0xFFFFFF)
  term.write("Fuel type: " .. tostring(fuelName))

  term.setCursor(5, 10)
  gpu.setForeground(running and 0xFFAA00 or 0xAAAAAA)
  term.write("Generator: " .. (running and "RUNNING" or "STOPPED"))

  gpu.setForeground(0xFFFFFF)
  term.setCursor(5, 12)
  term.write("Mode: " .. mode:upper() .. "   (A=Auto  M=Manual)")

  if mode == "manual" then
    term.setCursor(5, 14)
    term.write("Manual: O=ON  C=OFF")
  end

  if fuelP < minFuelPercent then
    gpu.setForeground(0xFF0000)
    term.setCursor(5, 16)
    term.write("!!! LOW FUEL ALERT !!! (forced OFF)")
  end

  if not beep then
    gpu.setForeground(0xAAAAAA)
    term.setCursor(5, 19)
    term.write("(Beep Card yok: sesli alarm calmaz)")
  end
end

while true do
  local stored = getEnergyStoredSafe()
  local max = getMaxEnergyStoredSafe()
  local energyP = (max > 0) and (stored / max) or 0

  local fuel, fuelMax, fuelName = getFuel()
  local fuelP = (fuelMax > 0) and (fuel / fuelMax) or 0

  -- Yakıt düşükse: zorla kapat + alarm
  if fuelP < minFuelPercent then
    setGen(false)
    maybeBeep()
  else
    -- Auto kontrol (yakıt yeterliyse)
    if mode == "auto" then
      if energyP < startThreshold then
        setGen(true)
      elseif energyP > stopThreshold then
        setGen(false)
      end
    end
  end

  draw(energyP, fuelP, fuelName)

  -- Tuşlar
  local _, _, _, key = event.pull(0.5, "key_down")
  if key then
    if key == 0x1E then mode = "auto" end    -- A
    if key == 0x32 then mode = "manual" end  -- M

    if mode == "manual" then
      if key == 0x18 then -- O
        if fuelP >= minFuelPercent then setGen(true) end
      elseif key == 0x2E then -- C
        setGen(false)
      end
    end
  end
end
