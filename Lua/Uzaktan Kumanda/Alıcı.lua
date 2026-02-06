local component = require("component")
local event = require("event")

-- Güvenlik + ağ
local TOKEN = "1234"
local PORT  = 2468

-- Bu microcontroller'ın adı (her cihaz farklı olmalı)
local DEVICE_ID = "DieselGenerator"

-- Redstone ayarı
local OUT_SIDE = 5  -- 0-5 (kablo hangi yüze bağlıysa)

-- Bileşen kontrolleri
if not component.isAvailable("modem") then error("Wireless Network Card yok!") end
if not component.isAvailable("redstone") then error("Redstone I/O yok!") end

local modem = component.modem
local rs = component.redstone

modem.open(PORT)

local state = false
rs.setOutput(OUT_SIDE, 0)

local function apply()
  rs.setOutput(OUT_SIDE, state and 15 or 0)
end

while true do
  local _, _, from, port, _, msg = event.pull("modem_message")
  if port == PORT and type(msg) == "string" then
    -- msg: "TOKEN deviceId cmd"
    local t, id, cmd = msg:match("^(%S+)%s+(%S+)%s+(%S+)$")
    if t == TOKEN and id == DEVICE_ID then
      if cmd == "on" then
        state = true; apply()
      elseif cmd == "off" then
        state = false; apply()
      elseif cmd == "toggle" then
        state = not state; apply()
      elseif cmd == "pulse" then
        rs.setOutput(OUT_SIDE, 15)
        os.sleep(0.2)
        rs.setOutput(OUT_SIDE, state and 15 or 0)
      end
    end
  end
end
