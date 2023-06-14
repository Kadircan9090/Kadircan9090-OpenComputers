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

local request = "username=" .. args[1] .. "&pin=" .. pin
local response = internet.request("http://localhost/create", request)

local id
repeat
    local tmp = response.read()
    if tmp then
        id = tmp
        break
    end
until not tmp

response.close()
cardwriter.write(id, "Bankcard", false)
