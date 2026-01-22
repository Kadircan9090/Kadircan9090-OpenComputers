local component = require("component")
local term = require("term")
local event = require("event")
local sides = require("sides")

local cap = component.capacitor_bank
local tank = component.fluid_tank
local redstone = component.redstone
local gpu = component.gpu
local beep = component.beep

gpu.setResolution(60, 20)
term.clear()

-- Ayarlar
local startThreshold = 0.25
local stopThreshold  = 0.90
local minFuelPercent = 0.10
local side = sides.back

local mode = "auto"
local running = false
local alarmActive = false

-- Tank bilgisi
local function getFuel()
  local fluids = tank.getFluids()
  if fluids and fluids[1] then
    return fluids[1].amount, tank.getCapacity()
  end
  return 0, tank.getCapacity()
end

local function bar(x, y, percent, color)
  local width = 40
  local fill = math.floor(width * percent)
  gpu.setForeground(color)
  term.setCursor(x, y)
  term.write("[" .. string.rep("=", fill) .. string.rep(" ", width - fill) .. "]")
end

local function alarm(on)
  if on and not alarmActive then
    alarmActive = true
    beep.beep(1200, 0.3)
  elseif not on then
    alarmActive = false
  end
end

local function draw(energyP, fuelP)
  term.clear()

  gpu.setForeground(0x00FF00)
  term.setCursor(20, 1)
  term.write("ENDER IO GENERATOR CONTROL")

  gpu.setForeground(0xFFFFFF)
  term.setCursor(5, 3)
  term.write("Energy: " .. math.floor(energyP * 100) .. "%")
  bar(5, 4, energyP, 0x00AAFF)

  term.setCursor(5, 6)
  term.write("Fuel:   " .. math.floor(fuelP * 100) .. "%")
  bar(5, 7, fuelP, fuelP > minFuelPercent and 0x00FF00 or 0xFF0000)

  term.setCursor(5, 9)
  gpu.setForeground(running and 0xFFAA00 or 0xAAAAAA)
  term.write("Generator: " .. (running and "RUNNING" or "STOPPED"))

  gpu.setForeground(0xFFFFFF)
  term.setCursor(5, 11)
  term.write("Mode: " .. mode:upper() .. " (A=Auto  M=Manual)")

  if fuelP < minFuelPercent then
    gpu.setForeground(0xFF0000)
    term.setCursor(5, 13)
    term.write("!!! LOW FUEL ALERT !!!")
  end
end

while true do
  local stored = cap.getEnergyStored()
  local max = cap.getMaxEnergyStored()
  local energyP = stored / max

  local fuel, fuelMax = getFuel()
  local fuelP = fuel / fuelMax

  -- ALARM
  if fuelP < minFuelPercent then
    alarm(true)
    redstone.setOutput(side, 0)
    running = false
  else
    alarm(false)
  end

  -- AUTO MODE
  if mode == "auto" and fuelP >= minFuelPercent then
    if energyP < startThreshold then
      redstone.setOutput(side, 15)
      running = true
    elseif energyP > stopThreshold then
      redstone.setOutput(side, 0)
      running = false
    end
  end

  draw(energyP, fuelP)

  local _, _, _, key = event.pull(0.5, "key_down")
  if key then
    if key == 0x1E then mode = "auto" end
    if key == 0x32 then mode = "manual" end

    if mode == "manual" and fuelP >= minFuelPercent then
      if key == 0x18 then
        redstone.setOutput(side, 15)
        running = true
      elseif key == 0x2E then
        redstone.setOutput(side, 0)
        running = false
      end
    end
  end
end
