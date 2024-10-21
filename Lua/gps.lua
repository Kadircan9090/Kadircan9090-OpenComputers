local component = require('component')
local event = require('event')
local modem = component.modem

modem.open(2)
modem.broadcast(2, 'LOCATE', math.random())

local ev = {true}

while ev[1] ~= nil do
    ev = { event.pull(1, 'modem_message') }
    if ev[1] then
        print(table.unpack(ev))
    end
end