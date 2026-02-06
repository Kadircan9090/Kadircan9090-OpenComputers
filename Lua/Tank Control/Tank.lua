local component = require("component")
local sides = require("sides")
local term = require("term")

local tank = component.tank_controller
local rs = component.redstone
local gpu = component.gpu

-- Ayarlar
local TANK_SIDE = sides.back
local PUMP_SIDE = sides.back

local ON, OFF = 15, 0
local STOP_AT  = 0.90
local START_AT = 0.75

local BAR_WIDTH = 30
local pumpOn = false

-- Renkler (RGB)
local GREEN  = 0x00FF00
local YELLOW = 0xFFFF00
local RED    = 0xFF0000
local GRAY   = 0x555555
local WHITE  = 0xFFFFFF

local function clamp(x,a,b)
  if x<a then return a end
  if x>b then return b end
  return x
end

local function barColor(ratio)
  if ratio < 0.5 then
    return GREEN
  elseif ratio < 0.8 then
    return YELLOW
  else
    return RED
  end
end

while true do
  local level = tank.getTankLevel(TANK_SIDE)
  local cap   = tank.getTankCapacity(TANK_SIDE)

  term.clear()
  gpu.setForeground(WHITE)
  print("Railcraft Tank Kontrol")
  print("----------------------")

  if not level or not cap or cap == 0 then
    gpu.setForeground(RED)
    print("Tank okunamadi!")
    rs.setOutput(PUMP_SIDE, OFF)
    os.sleep(2)
  else
    local ratio = level / cap
    local pct = ratio * 100

    -- Pompa kontrol
    if pumpOn and ratio >= STOP_AT then
      rs.setOutput(PUMP_SIDE, OFF)
      pumpOn = false
    elseif (not pumpOn) and ratio <= START_AT then
      rs.setOutput(PUMP_SIDE, ON)
      pumpOn = true
    end

    print(string.format("Miktar:   %d mB", level))
    print(string.format("Kapasite: %d mB", cap))
    print("")

    -- Bar çizimi
    local filled = math.floor(clamp(ratio,0,1) * BAR_WIDTH + 0.5)

    gpu.setForeground(barColor(ratio))
    io.write("[")
    io.write(string.rep("█", filled))

    gpu.setForeground(GRAY)
    io.write(string.rep("█", BAR_WIDTH - filled))
    io.write("] ")

    gpu.setForeground(WHITE)
    print(string.format("%.1f%%", pct))
    print("")

    gpu.setForeground(pumpOn and GREEN or RED)
    print("Pompa: " .. (pumpOn and "ACIK" or "KAPALI"))

    gpu.setForeground(WHITE)
    print(string.format("Baslat <= %.0f%% | Durdur >= %.0f%%",
      START_AT*100, STOP_AT*100))

    os.sleep(1)
  end
end
