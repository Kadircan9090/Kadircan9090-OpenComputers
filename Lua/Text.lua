local event = require("event")
local component = require("component")
local internet = component.internet
local cardwriter = component.os_cardwriter
local keypad = component.os_keypad

local args = {...}
local pin = ""

do
    keypad.setDisplay("Your PIN")
    while true do
        local _, _, _, char = event.pull("keypad")
        if char == "#" then
            keypad.setDisplay("Ok")
            os.sleep(1)
            keypad.setDisplay("")
            break
        elseif char == "*" then
            keypad.setDisplay("Resetted")
            pin = ""
            os.sleep(1)
            keypad.setDisplay("Your PIN")
        else
            pin = pin .. char
        end
    end
end
