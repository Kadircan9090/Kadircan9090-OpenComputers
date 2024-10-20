local component = require("component")
local tty = require("tty")
local event = require("event")
local gpu = component.gpu
local lift = component.lift
local screen = component.screen

local bkgrdColor = gpu.getBackground()

local buttons = {}


local screens = {
"a4bd2de3-cbaf-4a4b-ac3b-acf2dbd62bc1",
"f48c1033-81ea-432d-ae91-73bfaca47334",
"2bb63258-c785-42be-8598-573e457a38d7",
"c07ce065-ac3a-4877-9802-ee381036d1a1",
"cc5570bc-cbb1-4966-9586-171938103bcd",
"ef89a0c1-615a-4998-a6e2-d701a22260cf",
"acce1910-793e-4668-81a0-8ddac3f26bab",
}

local floors = { --The Y-coordinates the elevator stops by 1-7.
"67",
"72",
"78",
"83",
"88",
"93",
"98",
}

local currentScreen = screens[1]

local function newButton(x,y,number)
  gpu.setBackground(0x990000)
  gpu.fill(x,y,3,3," ")
  gpu.set(x+1,y+1,number)
  gpu.setBackground(bkgrdColor)
  buttons[number] = {x,y}
end

local function doButtons()
  newButton(2,2,"1")
  newButton(6,2,"2")
  newButton(10,2,"3")
  newButton(14,2,"4")
  newButton(18,2,"5")
  newButton(22,2,"6")
  newButton(26,2,"7")
end

gpu.setResolution(29,15)
tty.clear()


doButtons()


while true do
  local _,_,x,y = event.pull("touch")
  
  
  
  for i in pairs(buttons) do
    
  
  
  
    if x >= buttons[i][1] and x <= buttons[i][1]+3 and y >= buttons[i][2] and y <= buttons[i][2]+3 then
    
    currentScreen = screens[i]
    
      gpu.setBackground(0x008153)
    gpu.fill(buttons[i][1],buttons[i][2],3,3," ")
    os.sleep(0.05)
    lift.callFloor(tonumber(i))
    gpu.setBackground(0x990000)
    gpu.fill(buttons[i][1],buttons[i][2],3,3," ")
    gpu.set(buttons[i][1]+1,buttons[i][2]+1,i)
    gpu.setBackground(bkgrdColor)
    end
  end
end