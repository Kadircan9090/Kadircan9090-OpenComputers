local event = require "event"
local component = require "component"
local reactor = component.reactor
local redstone = component.proxy(component.get("297"))
local menet = component.proxy(component.get("d57"))
local gpu = component.gpu
local w, h = gpu.getResolution()
local inv = component.inventory_controller
local invs = inv.getInventorySize(2)
local power = 0
local changing = false
local rods = {}
local ri=1
local lzhs = {}
local li=1
local vents = {}
local vi=1
local warn=false
 
function getElement(pos)
  local l=" "
  if inv.getStackInSlot(2,pos) then
    l=inv.getStackInSlot(2,pos)
  end
  return l
end
 
function fillDmg(i,j,el,dmg)
  if el=="LZH" then
    dmg=(100000-dmg)/10000
  elseif el=="Rod" then
    dmg=(20000-dmg)/2000
  elseif el=="Vent" then
    dmg=(1000-dmg)/100
  end
  gpu.setBackground(0xFF0000)
  gpu.fill(j+2,i+5,dmg,1," ")
  gpu.setBackground(0x1E1E1E)
  gpu.fill(j+2+dmg,i+5,10-dmg,1," ")
end
 
function checkDmg()
  local dmg=0
  for i=1,li-1,1 do
    if inv.getStackInSlot(2,lzhs[i][3]) then
      dmg=inv.getStackInSlot(2,lzhs[i][3]).customDamage
      fillDmg(lzhs[i][1],lzhs[i][2],"LZH",dmg)
    else
      fillDmg(lzhs[i][1],lzhs[i][2],"LZH",100000)
    end
  end  
  local r
  for i=1,ri-1,1 do
    r=inv.getStackInSlot(2,rods[i][3])
    if r and not string.match(r.label,"Depleted") then
      dmg=inv.getStackInSlot(2,rods[i][3]).customDamage
      fillDmg(rods[i][1],rods[i][2],"Rod",dmg)
    else
      fillDmg(rods[i][1],rods[i][2],"Rod",20000)
    end
  end  
  for i=1,vi-1,1 do
    if inv.getStackInSlot(2,vents[i][3]) then
      dmg=inv.getStackInSlot(2,vents[i][3]).customDamage
      fillDmg(vents[i][1],vents[i][2],"Vent",dmg)
    else
      fillDmg(vents[i][1],vents[i][2],"Vent",1000)
    end
  end  
end
 
function fillElement(i,j,el,pos,set,elw)
  local j1=9+j
  local i1=2+i
  set=set or 0x696969
  pos=pos or 1
  elw=elw or 14
  gpu.setBackground(set)
  gpu.fill(j1,i1,elw,6," ")
  local l=" "
  if el.label then
    l=el.label
  end
  if el=="X" then
    gpu.setForeground(0x3C3C3C)
    gpu.fill(j1+1,i1,1,1,"＼")
    gpu.fill(j1+11,i1,1,1,"／")
    gpu.fill(j1+3,i1+1,1,1,"＼")
    gpu.fill(j1+9,i1+1,1,1,"／")
    gpu.fill(j1+5,i1+2,1,1,"＼")
    gpu.fill(j1+7,i1+2,1,1,"／")
    gpu.fill(j1+7,i1+3,1,1,"＼")
    gpu.fill(j1+5,i1+3,1,1,"／")
    gpu.fill(j1+9,i1+4,1,1,"＼")
    gpu.fill(j1+3,i1+4,1,1,"／")
    gpu.fill(j1+11,i1+5,1,1,"＼")
    gpu.fill(j1+1,i1+5,1,1,"／")
  elseif el=="0" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+1,i1+5,6,1,"═")
    gpu.fill(j1,i1+1,1,4,"║")
    gpu.fill(j1+7,i1+1,1,4,"║")
  elseif el=="1" then
    gpu.fill(j1+7,i1+1,1,4,"║")
  elseif el=="2" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+1,i1+2,6,1,"═")
    gpu.fill(j1+1,i1+5,6,1,"═")
    gpu.fill(j1,i1+3,1,2,"║")
    gpu.fill(j1+7,i1+1,1,1,"║")
  elseif el=="3" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+1,i1+2,6,1,"═")
    gpu.fill(j1+1,i1+5,6,1,"═")
    gpu.fill(j1+7,i1+3,1,2,"║")
    gpu.fill(j1+7,i1+1,1,1,"║")
  elseif el=="4" then
    gpu.fill(j1+1,i1+2,6,1,"═")
    gpu.fill(j1,i1+1,1,1,"║")
    gpu.fill(j1+7,i1+1,1,1,"║")
    gpu.fill(j1+7,i1+3,1,2,"║")
  elseif el=="5" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+1,i1+2,6,1,"═")
    gpu.fill(j1+1,i1+5,6,1,"═")
    gpu.fill(j1,i1+1,1,1,"║")
    gpu.fill(j1+7,i1+3,1,2,"║")
  elseif el=="6" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+1,i1+2,6,1,"═")
    gpu.fill(j1+1,i1+5,6,1,"═")
    gpu.fill(j1,i1+1,1,1,"║")
    gpu.fill(j1,i1+3,1,2,"║")
    gpu.fill(j1+7,i1+3,1,2,"║")
  elseif el=="7" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+7,i1+1,1,4,"║")
  elseif el=="8" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+1,i1+2,6,1,"═")
    gpu.fill(j1+1,i1+5,6,1,"═")
    gpu.fill(j1,i1+1,1,1,"║")
    gpu.fill(j1+7,i1+1,1,1,"║")
    gpu.fill(j1,i1+3,1,2,"║")
    gpu.fill(j1+7,i1+3,1,2,"║")
  elseif el=="9" then
    gpu.fill(j1+1,i1,6,1,"═")
    gpu.fill(j1+1,i1+2,6,1,"═")
    gpu.fill(j1+1,i1+5,6,1,"═")
    gpu.fill(j1,i1+1,1,1,"║")
    gpu.fill(j1+7,i1+3,1,2,"║")
    gpu.fill(j1+7,i1+1,1,1,"║")
  elseif string.match(l,"LZH") then
    gpu.setBackground(0x0000C0)
    gpu.fill(j1+1,i1+1,12,4," ")
    fillDmg(i1,j1,"LZH",el.customDamage)
    lzhs[li]={i1,j1,pos}
    li=li+1
  elseif string.match(l,"Overclocked") then
    gpu.setBackground(0xFFFF40)
    gpu.fill(j1+1,i1+1,12,4," ")
    fillDmg(i1,j1,"Vent",el.customDamage)
    vents[vi]={i1,j1,pos}
    vi=vi+1
  elseif string.match(l,"Quad") then
    gpu.setBackground(0x006D00)
    gpu.fill(j1+1,i1+1,2,4," ")
    gpu.fill(j1+4,i1+1,2,4," ")
    gpu.fill(j1+8,i1+1,2,4," ")
    gpu.fill(j1+11,i1+1,2,4," ")
    if not string.match(l,"Depleted") then
      fillDmg(i1,j1,"Rod",el.customDamage)
    else
      fillDmg(i1,j1,"Rod",20000)
    end
    rods[ri]={i1,j1,pos}
    ri=ri+1
  elseif string.match(l,"Plating") then
    gpu.setBackground(0xB4B4B4)
    gpu.fill(j1+1,i1+1,12,4," ")
  end
end
 
function drawElement(i,j)
  local i1=i/7
  local j1=j/16+1
  local pos=i1*9+j1
  local s=(invs-4)/6
  if s<9 then
    for g=8,s,-1 do
      local m=math.fmod(pos,g+1)
      if m==0 then
        fillElement(i,j,"X")
        return 
      end
      local d=(pos-m)/(g+1)
      pos=pos-d
    end
  end
  local el=getElement(pos)
  fillElement(i,j,el,pos)
end
 
function fillEU(eu)
  gpu.setBackground(0x000000)
  gpu.fill(88,44,72,6," ")
  gpu.setForeground(0x00B6FF)
  local l = string.len(eu)
  for i=l,1,-1 do
    fillElement(42,140-(l-i)*10,string.sub(eu,i,i),1,0x000000,10)
  end
end
 
function fillPower(power)
  if power>0 then
    gpu.setBackground(0x00FF00)
  else
    gpu.setBackground(0xFF0000)
  end
  gpu.fill(2,45,14,5," ")
end
 
function fillWarning(w)
  gpu.setBackground(w)
  gpu.fill(18,45,14,5," ")
end
 
function continueWork()
  if reactor.getHeat()>0 then
    power=0
    redstone.setOutput(1,power)
    menet.setOutput(2,15)
    fillPower(power)
    fillWarning(0xFFB600)
    fillEU(0)
    warn=true
    return true
  end
  local eu = reactor.getReactorEUOutput()
  if changing then
    if   not inv.getStackInSlot(2,11) or (inv.getStackInSlot(2,11) and string.match(inv.getStackInSlot(2,11).label,"Depleted"))
      or not inv.getStackInSlot(2,12) or (inv.getStackInSlot(2,12) and string.match(inv.getStackInSlot(2,12).label,"Depleted"))
      or not inv.getStackInSlot(2,15) or (inv.getStackInSlot(2,15) and string.match(inv.getStackInSlot(2,15).label,"Depleted"))
      or not inv.getStackInSlot(2,16) or (inv.getStackInSlot(2,16) and string.match(inv.getStackInSlot(2,16).label,"Depleted"))
      or not inv.getStackInSlot(2,20) or (inv.getStackInSlot(2,20) and string.match(inv.getStackInSlot(2,20).label,"Depleted"))
      or not inv.getStackInSlot(2,21) or (inv.getStackInSlot(2,21) and string.match(inv.getStackInSlot(2,21).label,"Depleted"))
      or not inv.getStackInSlot(2,24) or (inv.getStackInSlot(2,24) and string.match(inv.getStackInSlot(2,24).label,"Depleted"))
      or not inv.getStackInSlot(2,25) or (inv.getStackInSlot(2,25) and string.match(inv.getStackInSlot(2,25).label,"Depleted"))
      or not inv.getStackInSlot(2,29) or (inv.getStackInSlot(2,29) and string.match(inv.getStackInSlot(2,29).label,"Depleted"))
      or not inv.getStackInSlot(2,30) or (inv.getStackInSlot(2,30) and string.match(inv.getStackInSlot(2,30).label,"Depleted"))
      or not inv.getStackInSlot(2,33) or (inv.getStackInSlot(2,33) and string.match(inv.getStackInSlot(2,33).label,"Depleted"))
      or not inv.getStackInSlot(2,34) or (inv.getStackInSlot(2,34) and string.match(inv.getStackInSlot(2,34).label,"Depleted"))
      or not inv.getStackInSlot(2,38) or (inv.getStackInSlot(2,38) and string.match(inv.getStackInSlot(2,38).label,"Depleted"))
      or not inv.getStackInSlot(2,39) or (inv.getStackInSlot(2,39) and string.match(inv.getStackInSlot(2,39).label,"Depleted"))
      or not inv.getStackInSlot(2,42) or (inv.getStackInSlot(2,42) and string.match(inv.getStackInSlot(2,42).label,"Depleted"))
      or not inv.getStackInSlot(2,43) or (inv.getStackInSlot(2,43) and string.match(inv.getStackInSlot(2,43).label,"Depleted"))
      or not inv.getStackInSlot(2,51) or (inv.getStackInSlot(2,51) and string.match(inv.getStackInSlot(2,51).label,"Depleted"))
      or not inv.getStackInSlot(2,52) or (inv.getStackInSlot(2,52) and string.match(inv.getStackInSlot(2,52).label,"Depleted")) then
      return true --do nothing
    else
      changing=false
      power=15
      redstone.setOutput(1,power)
      menet.setOutput(2,power)
      fillWarning(0x000000)
    end
  else
    if eu<2000 and power>0 then
      changing=true
      power=0
      redstone.setOutput(1,power)
      menet.setOutput(2,power)
      fillWarning(0x006D00)
      fillEU(0)
      return true
    end
  end
  fillEU(eu)
  checkDmg()
  return true
end
 
local myEventHandlers = setmetatable({}, { __index = function() return continueWork end })
 
function myEventHandlers.key_up(adress, char, code, playerName)
  if code==57 then
    if not changing then
      if power==0 then
        --print("Enable")
        if warn then
          warn=false
          fillWarning(0x000000)
        end
        power=15
      else
        --print("Shutdown")
        power=0
      end
      fillPower(power)
      redstone.setOutput(1,power)
      --menet.setOutput(2,power)
    end
  end
  return true
end
 
function myEventHandlers.interrupted(...)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, w, h, " ")
  return false
end
 
function handleEvent(eventID, ...)
  if (eventID) then 
    return myEventHandlers[eventID](...)
  end
  return continueWork()
end
 
gpu.setBackground(0xC3C3C3)
 
gpu.fill(1, 1, w, h-7, " ")
 
for i=0,35,7 do
  for j=0,128,16 do
    drawElement(i,j)
  end
end
 
if reactor.getReactorEUOutput()>0 then
  power=15
end
fillPower(power)
while handleEvent(event.pull(1)) do
  --nothing
end