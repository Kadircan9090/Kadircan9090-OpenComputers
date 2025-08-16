print("Lo")
print("-----STARTING-----")

local component = require("component")
local sides = require("sides")
local colors = require("colors")
local rs = component.redstone
local computer = require("computer")
local term = require("term")

-- Extreme Reactors bileşenleri
reactor = component.proxy("UUID_REACTOR_1") -- Birinci reaktörün UUID'si
reactor2 = component.proxy("UUID_REACTOR_2") -- İkinci reaktörün UUID'si
turbine = component.br_turbine

print("-----RESETTING BACKUP-----")
rs.setBundledOutput(sides.left, colors.green, 0)
rs.setBundledOutput(sides.left, colors.yellow, 0)
rs.setBundledOutput(sides.left, colors.black, 0)

computer.beep(1000, 1)

function totalPowerLevel()
  return (reactor.getEnergyStored() + reactor2.getEnergyStored())
end

function checkPowerSwitch()
  -- Orange = Reactor1 switch, red = reactor1 input, lime = reactor2 input, purple = reactor2 input.
  if rs.getBundledInput(sides.left, colors.orange) > 0 and rs.getBundledInput(sides.left, colors.lime) > 0 then
    rs.setBundledOutput(sides.left, colors.red, 255)
    rs.setBundledOutput(sides.left, colors.purple, 255)
    print("1|----|  2|----| ")
    print("~|****|~ *|####|*")
    print(" |----|   |----| ")
  elseif rs.getBundledInput(sides.left, colors.orange) == 0 and rs.getBundledInput(sides.left, colors.lime) == 0 then
    rs.setBundledOutput(sides.left, colors.red, 0)
    rs.setBundledOutput(sides.left, colors.purple, 0)
    print("1|----|  2|----|")
    print(" |    |   |    |")
    print(" |----|   |----|")
  elseif rs.getBundledInput(sides.left, colors.orange) > 0 and rs.getBundledInput(sides.left, colors.lime) == 0 then 
    rs.setBundledOutput(sides.left, colors.red, 255)
    rs.setBundledOutput(sides.left, colors.purple, 0)
    print("1|----|  2|----|")
    print("~|****|~  |    |")
    print(" |----|   |----|")
  elseif rs.getBundledInput(sides.left, colors.orange) == 0 and rs.getBundledInput(sides.left, colors.lime) > 0 then
    rs.setBundledOutput(sides.left, colors.red, 0)
    rs.setBundledOutput(sides.left, colors.purple, 255)
    print("1|----|  2|----| ")
    print(" |    |  *|####|*")
    print(" |----|   |----| ")
 end
end

backup = false

function startGasTurbine()
  print("=====Starting Gas Turbine=====")
  print("Disconnecting from grid")
  computer.beep(500, 1)
  computer.beep(700, 1)
  rs.setBundledOutput(sides.left, colors.magenta, 255)
  print("Generator start: status:ON, spool:ON, ignition:ON")
  rs.setBundledOutput(sides.left, colors.black, 255)
  rs.setBundledOutput(sides.left, colors.yellow, 255)
  rs.setBundledOutput(sides.left, colors.green, 255)
  os.sleep(15)
  print("Generator start: spool:OFF")
  rs.setBundledOutput(sides.left, colors.yellow, 0)
  os.sleep(5)
  print("Generator start: ignition:OFF")
  rs.setBundledOutput(sides.left, colors.green, 0)
  -- Turn off dieselGen
  print("Generator start: Diesel-Backup:OFF")
  rs.setBundledOutput(sides.left, colors.white, 0)
  print("Connecting back to grid")
  rs.setBundledOutput(sides.left, colors.magenta, 0)
  os.sleep(5)
  backup = true
  
  while(backup)
  do
    os.sleep(1)
    term.clear()
   
    -- Print info about current state of backup system.
    print("Current turbine speed: ", turbine.getRotorSpeed())
    print("Diesel backup level: ", ((rs.getBundledInput(sides.left, colors.cyan)/195)*100))

    if totalPowerLevel() > 1000 then
      backup = false
    end

    if rs.getInput(sides.back) > 0 then
      -- shutdown system
      x = false
      backup = false
    end
    checkPowerSwitch()
  end
end

function resetBackUp()
  rs.setBundledOutput(sides.left, colors.white, 0)
  rs.setBundledOutput(sides.left, colors.black, 0)
end

local x = true

while(x)
do
  if totalPowerLevel() < 1000 and backup == false then
    computer.beep(500, 1)
    print("Trying to start diesel generator")
    rs.setBundledOutput(sides.left, colors.white, 255)
    os.sleep(10)
    startGasTurbine()
  elseif totalPowerLevel() > 100 then
    backup = false
    resetBackUp()
    os.sleep(1)
    term.clear()
    print("Power in reactor 1: ", reactor.getEnergyStored())
    print("Power in reactor 2:", reactor2.getEnergyStored())
    print("Reactor 1 Fuel Temp: ", reactor.getFuelTemperature())
    print("Reactor 2 Fuel Temp: ", reactor2.getFuelTemperature())
    print("Reactor 1 Casing Temp: ", reactor.getCasingTemperature())
    print("Reactor 2 Casing Temp: ", reactor2.getCasingTemperature())
    print("Reactor 1 Fuel Type: ", reactor.getFuelType())
    print("Reactor 2 Fuel Type: ", reactor2.getFuelType())
    print("Reactor 1 Fuel Amount: ", reactor.getFuelAmount())
    print("Reactor 2 Fuel Amount: ", reactor2.getFuelAmount())
    print("Reactor 1 Waste Amount: ", reactor.getWasteAmount())
    print("Reactor 2 Waste Amount: ", reactor2.getWasteAmount())
    print("Power in base: ", totalPowerLevel())
    print("Gas Turbine Status", turbine.getRotorSpeed())
    print("Diesel backup level: ", ((rs.getBundledInput(sides.left, colors.cyan)/195)*100))
    checkPowerSwitch()  
  end
  
  -- Check if program termination switch is triggered.
  if rs.getInput(sides.top) > 0 then
    print("Reactor closing")
    os.sleep(5)
    rs.setBundledOutput(sides.left, colors.red, 0)
    print("Reactor closing")
    os.sleep(5)
    rs.setBundledOutput(sides.left, colors.purple, 0)
    print("Turbine closing")
    os.sleep(5)
    rs.setBundledOutput(sides.left, colors.black, 0)
    os.sleep(5)
    print("Generator closing")
    os.sleep(5)
    rs.setBundledOutput(sides.left, colors.white, 0)
    resetBackUp()
    x = false
  end
end
