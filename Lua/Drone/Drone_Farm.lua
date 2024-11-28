local d = component.proxy(component.list("drone", true)())
local g = component.proxy(component.list("geolyzer", true)())
local c = computer

d.setLightColor(0xff00ff)

local no_farm = {
[15] = { [15] = true, },
[12] = { [3] = true, [12] = true, },
[3] = { [3] = true, [12] = true, },
}
local to_collect = {
["minecraft:potatoes"] = true,
["minecraft:carrots"] = true,
}
local seed_slot = {
[1] = true,
[2] = true,
}
local keep_seeds = 4
local ensure_space = 2
local localX = 15
local localZ = 15
local minX = 0
local minZ = 0
local maxX = 15
local maxZ = 15
local inv_side = 1
local inv_name = "minecraft:chest"

local startX = localX
local startZ = localZ

local function sleep(sec)
  local dl = c.uptime() + sec
  repeat
    c.pullSignal(dl - computer.uptime())
  until c.uptime() >= dl
end

local function attn()
  c.beep(1500, 0.2)
  c.beep(1700, 0.2)
  c.beep(1300, 0.2)
  sleep(3)
end

local function plant()
  local slot = localX % 2 + 1
  if d.count(slot) > 1 then
    d.select(slot)
    if not d.place(0) then attn() end
  else
    attn()
  end
end

local first_free

local function got_free_slots(wanted, no_heur)
  local found = 0
  for slot = first_free or 1, d.inventorySize() do
    if d.count(slot) == 0 then
      found = found + 1
      first_free = first_free or slot
    end
    if found >= wanted then
      return true
    end
  end
  if first_free and not no_heur then
    first_free = nil
    return got_free_slots(wanted, true)
  end
  return false
end

local function farm()
  local found, desc = d.detect(0)
  if not found and desc == "air" then
    plant()
  elseif found and desc == "passable" then
    local block = g.analyze(0)
    if block ~= nil and block.growth ~= nil then
      if block.growth == 1 and to_collect[block.name] then
        d.select(1)
        d.swing(0)
        plant()
      end
    else
      attn()
    end
  else
    attn()
  end
end

local function put_away_excess()
  while true do
    local found, desc = d.detect(inv_side)
    if found and desc == "solid" then
      local block = g.analyze(inv_side)
      if block ~= nil and block.name == inv_name then break end
    end
    attn()
  end
  repeat
    local done = true
    for slot = 1, d.inventorySize() do
      local amt = d.count(slot)
      if amt > 0 then
        d.select(slot)
        local to_drop = math.huge
        if seed_slot[slot] then to_drop = amt - keep_seeds end
        if to_drop > 0 and not d.drop(inv_side, to_drop) then done = false attn() break end
      end
    end
  until done
  first_free = nil
end

local function vec_len(oX, oZ)
  return math.sqrt(oX*oX + oZ*oZ)
end

local function move_to(tgtX, tgtZ, precise)
  local offX = tgtX - localX
  local offZ = tgtZ - localZ
  if offX == 0 and offZ == 0 then return end
  d.move(offX, 0, offZ)
  local moved
  local goaldist = 0.45
  local goalvel = 2
  local timemult = 1
  if precise then
    goaldist = 0.1
    goalvel = 0.1
    timemult = timemult * 2
  end
  local dl = c.uptime() + vec_len(offX, offZ) * timemult
  repeat
    moved = d.getOffset() <= goaldist and d.getVelocity() <= goalvel
    if c.uptime() >= dl then break end
  until moved
  if moved then
    localX = localX + offX
    localZ = localZ + offZ
  else
    d.move(-offX, 0, -offZ)
    attn()
  end
end

local workX = startX
local workZ = startZ

local function next_spot()
  if workX < maxX then
    workX = workX + 1
  else
    workX = minX
    if workZ < maxZ then
      workZ = workZ + 1
    else
      workZ = minZ
    end
  end
  if no_farm[workX] ~= nil and no_farm[workX][workZ] then
    next_spot()
  end
  return workX, workZ
end

local function dock(optional)
  if optional and c.energy() >= 500 and got_free_slots(ensure_space) then return end
  move_to(startX, startZ, true)
  put_away_excess()
  while c.energy() < c.maxEnergy() - 500 do sleep(3) end
end

dock(false)

while true do
  dock(true)
  move_to(next_spot())
  farm()
end
