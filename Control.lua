local component = require("component")
local computer = require("computer")
local term = require("term")
local event = require("event")
local keyboard = require("keyboard")
local os = require("os")
 
target = "Kadircan"
 
x = -878
y = 0
z = -547
 
dx = 0
dy = 0
dz = 0
 
currx = -1
curry = -3
currz = 0
 
 
 
while true do
    t = { event.pull() }
    if t[1] == "motion" and t[6] == target then
        x = math.floor(t[3])
        y = math.floor(t[4])
        z = math.floor(t[5])
        
        dx = x-currx
        dy = y-curry
        dz = z-currz
 
        currx = x
        curry = y
        currz = z
 
        cmd = "drone.move(" .. dx .. ", " .. dy .. ", " .. dz .. ")"
        print (cmd)
        component.modem.broadcast(2412, cmd)
    end
end