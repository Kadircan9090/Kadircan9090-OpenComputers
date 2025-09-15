local component = require("component")
local term = require("term")
local event = require("event")
local sides = require("sides")
local energyDevice = component.energy_device
local rs = component.redstone

local outputSide = sides.back

local generatorOn = false
local autoMode = true

local startThreshold = 0.20
local stopThreshold = 0.95

local function getEnergyPercent()
  local current = energyDevice.getEnergyStored()
  local max = energyDevice.getMaxEnergyStored()
  if max == 0 then return 0 end
  return current / max
end

local function updateGenerator()
  rs.setOutput(outputSide, generatorOn and 15 or 0)
end

local function drawUI()
  term.setCursor(1,1)
  term.clear()
  local percent = getEnergyPercent()
  print("=== Diesel Generator Control ===\n")
  print("Mode: " .. (autoMode and "AUTO" or "MANUAL"))
  print(string.format("Energy: %.1f%%", percent * 100))
  local bar = "[" .. string.rep("█", math.floor(percent * 30)) .. string.rep("░", 30 - math.floor(percent * 30)) .. "]"
  print(bar)
  print("Generator: " .. (generatorOn and "ON ✅" or "OFF ❌"))
  print("\n[s] Start/Stop (Manual Mode)")
  print("[m] Toggle Mode (Auto/Manual)")
  print("[q] Quit")
end

-- Başlat
updateGenerator()
drawUI()

while true do
  if autoMode then
    local level = getEnergyPercent()
    if level <= startThreshold then
      generatorOn = true
    elseif level >= stopThreshold then
      generatorOn = false
    end
    updateGenerator()
  end

  drawUI()

  -- key_down event: returns (name, address, char, code, playerName)
  local evt, _, char = event.pull(1, "key_down")
  if evt then
    local key = string.char(char):lower()
    if key == "s" and not autoMode then
      generatorOn = not generatorOn
      updateGenerator()
    elseif key == "m" then
      autoMode = not autoMode
    elseif key == "q" then
      term.clear()
      print("Exited.")
      break
    end
  end
end

