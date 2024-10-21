local filesystem = require("filesystem")
local component = require("component")
local thread = require("thread")
local term = require("term")
local modem = component.modem
local event = require("event")
local gpu = component.gpu
local computer = component.computer
 
local connected = {}
 
term.clear()
print("Drone Control v.01")
print("------------------")
print("Listening On: 122")
 
modem.open(122)
modem.setStrength(100)
print(modem.isOpen(122))
 
os.sleep(.25)
 
term.clear()
gpu.setForeground(0x00ff00)
print("> ")
gpu.setForeground(0xffffff)
term.setCursor(3, 1)
 
function split (instr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(instr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end
 
function nextLine()
  gpu.setForeground(0x00ff00)
  term.write("> ")
  gpu.setForeground(0xffffff)
end
 
local listen = thread.create(function()
  ::connect::
  local _, _, from, port, _, message = event.pull("modem_message")
  if (message == "dconnect") then
    table.insert(connected, from)
    modem.send(from, port, "dcaccepted")
    computer.beep(500, .2)
    computer.beep(500, .2)
  end
  goto connect
end)
 
while true do
  local input = io.read()
  input = split(input, " ")
 
  if (input[1] == "exit") then
    listen:kill()
    return
  elseif (input[1] == "upload") then
    local file = io.open(input[2])
    local src = file:read(10000000)
    for k,d in pairs(connected) do
      modem.send(d, 122, "call", src)
    end
    nextLine()
  elseif (input[1] == "connected") then
    for k,d in pairs(connected) do
      print("["..k.."] "..d)
    end
    nextLine()
  elseif (input[1] == "help") then
    print("upload <filename> : uploads specified file to drone. Remember to wrap your code in a generic function!")
    print("connected : lists connected drones.")
    print("exit : exits shell.")
    nextLine()
  else
    nextLine()
  end 
end