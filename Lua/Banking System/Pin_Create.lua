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
            if pin == "" then
                keypad.setDisplay("Empty PIN")
                os.sleep(1)
                keypad.setDisplay("Your PIN")
            else
                keypad.setDisplay("Ok")
                os.sleep(1)
                keypad.setDisplay("")
                break
            end
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

local request = "username=" .. (args[1] or "") .. "&pin=" .. pin
local headers = {["Content-Type"] = "application/x-www-form-urlencoded"}

local success, response = pcall(internet.request, "http://localhost/create", "POST", request, headers)

if success then
    local id = ""
    for chunk in response do
        id = id .. chunk
    end
    response.close()

    local wrote = cardwriter.write(id, "Bankcard", false)
    if not wrote then
        print("Failed to write to card")
    end
else
    print("Error occurred: " .. response)
end
