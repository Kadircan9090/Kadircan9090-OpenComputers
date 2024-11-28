local modem = component.proxy(component.list("modem")())
local connected
 
modem.open(122)
 
computer.beep(500, .2)
computer.beep(700, .2)
 
::connect::
local _, _, from, port, _, message = computer.pullSignal()
 
if (message == "dcaccepted") then
  computer.beep(800, .2)
  computer.beep(800, .2)
  connected = from
else 
  goto connect 
end
 
while true do
  local _, _, from, port, _, message, arg1 = computer.pullSignal() 
 
  if(message == "call") then
    if arg1 then
      local l, err  = load("return "..arg1)
      if l then
        local ok, f = pcall(l)
        if ok then
          f()
        end
      end
    end
  end
end
