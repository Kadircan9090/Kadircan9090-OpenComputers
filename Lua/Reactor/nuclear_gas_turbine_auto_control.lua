print("Lo")
print("-----STARTING-----")

local component = require("component")
local sides = require("sides")
local colors = require("colors")
local rs = component.redstone
local computer = require("computer")
local term = require("term")

-- reactor = component.nc_fission_reactor
reactor = component.proxy("aa77a84c-ecd3-4678-98d7-29961d71b252")
reactor2 = component.proxy("865789e6-fd68-45a2-a2a0-4af145a819f0")

turbine = component.it_gas_turbine

print("-----RESETTING BACKUP-----")
rs.setBundledOutput(sides.left, colors.green, 0)
rs.setBundledOutput(sides.left, colors.yellow, 0)
rs.setBundledOutput(sides.left, colors.black, 0)


computer.beep(1000, 1)

function totalPowerLevel()
  return (reactor.getEnergyStored() + reactor2.getEnergyStored())
end

function checkPowerSwitch()
  -- Orange = Reactor1 switch, red = reactor1 input, lime = reactor2 input, purple = reactor 2 input.
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
   
     -- Print info about current state of backup  system.

    print("Current turbine speed: ", turbine.getSpeed())
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
  -- Don't print here
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
    print("Reactor 1 temprature: ", reactor.getHeatLevel())
    print("Reactor 2 temprature: ", reactor2.getHeatLevel())
    print("Reactor 1 fuel heat: ", reactor.getFissionFuelHeat())
    print("Reactor 2 fuel heat: ", reactor2.getFissionFuelHeat())
    print("Reactor 1 cells in use: ", reactor.getNumberOfCells(), " with: ", reactor.getFissionFuelName())
    print("Reactor 2 cells in use: ", reactor2.getNumberOfCells(), " with: ", reactor2.getFissionFuelName())
    print("Current cooling rate: ", reactor.getReactorCoolingRate())
    print("Reactor 1 max heat: ", reactor.getMaxHeatLevel())
    print("Reactor 2 max heat: ", reactor2.getMaxHeatLevel())
    print("Power in base: ", totalPowerLevel())
    print("Gas Turbine Status", turbine.getSpeed())
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
