local event = require("event")
local os = require("os")
local term = require("term")
local io = require("io")
local internet = require("internet")
local component = require("component")
local gpu = component.gpu
local magreader = component.os_magreader
local redstone = component.redstone
local inventory_controller = component.inventory_controller
local url = "http://localhost"
gpu.setResolution(160, 50)
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
local function error_(message)
	gpu.setForeground(0xFF0000)
	print("Error: " .. message)
	gpu.setForeground(0x000000)
end
local function start_screen()
	term.clear()
	print("Hoşgeldiniz ATM")
	print("Kartı Yerleştirin")
end
local function count_iron()
	local count = 0
	for i = 1, 18 do
		local item = inventory_controller.getStackInSlot(0, i)
		if not (item == nil) then
			if item.name == "minecraft:iron_ingot" then
				count = count + item.size
			end
		end
	end
	return count
end
local function choose_screen(name, now)
	term.clear()
	print("Welcome to ATM")
	print("Hello, " .. name)
	print("Now Irons: " .. tostring(now))
	print("")
	print("Choose:")
	print("1) - Deposit")
	print("2) - Withdraw")
	print("")
	print("CTRL + ALT + C to exit")
end
local function deposit_screen(name, now)
	term.clear()
	print("Welcome to ATM")
	print("Hello, " .. name)
	print("Now Irons: " .. tostring(now))
	print("")
	print("Write how much you want to deposit irons")
end
local function deposit_count_screen(name, now, irons, count)
	term.clear()
	print("Welcome to ATM")
	print("Hello, " .. name)
	print("Now Irons: " .. tostring(now))
	print("")
	print("Irons: " .. tostring(count) .. " / " .. irons)
end
local function withdraw_screen(name, now)
	term.clear()
	print("Welcome to ATM")
	print("Hello, " .. name)
	print("Now Irons: " .. tostring(now))
	print("")
	print("Write how much you want to withdraw irons")
end
local function loading_screen(name, now)
	term.clear()
	print("Welcome to ATM")
	print("Hello, " .. name)
	print("Now Irons: " .. tostring(now))
	print("")
	print("Loading...")
end
start_screen()
local id = ""
local name = ""
local irons = 0
while true do
	local event, _, _, _id = event.pull()
	if event == "magData" then
		local response = internet.request(url .. "/getUsername", _id)
		local _name = response()
		if not (_name == nil) then
			id = _id
			name = _name
			now_irons = tonumber(internet.request(url .. "/getIrons", _id)())
			while true do
				choose_screen(name, now_irons)
				local selection = io.read()
				if selection == "1" then
					deposit_screen(name, now_irons)
					local irons = tonumber(io.read())
					redstone.setOutput(0, 15)
					local count = 0
					repeat
						local count = count_iron()
						deposit_count_screen(name, now_irons, irons, count)
					until count == irons
					redstone.setOutput(0, 0)
					loading_screen(name, now_irons)
					repeat
						local count = count_iron()
					until count == 0
					internet.request(url .. "/deposit", "id=" .. id .. "&amount=" .. irons)
					now_irons = tonumber(internet.request(url .. "/getIrons", _id)())
				elseif selection == "2" then
					withdraw_screen(name, now_irons) 
					local irons = tonumber(io.read())
					print("Write your PIN")
					local pin = io.read()
					loading_screen(name, now_irons)
					local msg = internet.request(url .. "/withdraw", "id=" .. id .. "&pin=" .. pin .."&amount=" .. irons)()
					if msg == "wrongpin" then
						error_("Wrong PIN")
						os.sleep(2)
					elseif msg == "dontenough" then
						error_("Don't enough irons")
						os.sleep(2)
					else
						loading_screen(name, now_irons)
						for i=1, irons do
							redstone.setOutput(1, 15)
							redstone.setOutput(1, 0)
						end
						now_irons = tonumber(internet.request(url .. "/getIrons", _id)())
					end
				end
			end
			break
		else
			error_("You have problems with your debit card")
			os.sleep(2)
			start_screen()
		end
	end
end
