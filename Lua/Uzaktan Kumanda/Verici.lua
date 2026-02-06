local component = require("component")
local term = require("term")

if not component.isAvailable("modem") then
  error("PC'de Wireless Network Card yok!")
end

local modem = component.modem
local TOKEN = "1234"
local PORT  = 2468

local function send(id, cmd)
  modem.broadcast(PORT, TOKEN .. " " .. id .. " " .. cmd)
end

term.clear()
print("Ev Otomasyonu Kumandasi")
print("Komut: <cihazId> <on/off/toggle/pulse>")
print("Ornek: DieselGenerator on")
print("Cikis: exit")
print("")

while true do
  io.write("> ")
  local line = io.read()
  if not line then break end
  if line == "exit" then break end

  local id, cmd = line:match("^(%S+)%s+(%S+)$")
  if id and cmd then
    send(id, cmd)
    print("Gonderildi: " .. id .. " " .. cmd)
  else
    print("Format: cihazId komut  (or: EV toggle)")
  end
end
