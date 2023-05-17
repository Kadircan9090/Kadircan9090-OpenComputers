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
		local action, _, _, char = event.pull()
		if action == "keypad" then
			if char == "#" then
				keypad.setDisplay("Ok")
				os.sleep(1)
				keypad.setDisplay("")
				break
			elseif char == "*" then
				keypad.setDisplay("Reseted")
				pin = ""
				os.sleep(1)
				keypad.setDisplay("Your PIN")
			else
				pin = pin .. char
			end
		end
	end
end
local request = "username=" .. args[1] .. "&pin=" .. pin
local response = internet.request("http://localhost/create", request)
local id
while true do
	local tmp = response.read()
	if not (tmp == "") then
		id = tmp
		break
	end
end
response.close()
cardwriter.write(id, "Bankcard", false)
