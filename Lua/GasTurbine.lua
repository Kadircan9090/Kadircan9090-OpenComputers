print("Code")
print("-----STARTING-----")

local component = require("component")
local sides = require("sides")
local colors = require("colors")
local rs = component.redstone
local computer = require("computer")
local term = require("term")

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