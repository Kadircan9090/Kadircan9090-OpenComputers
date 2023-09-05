local component = require("component")
local term = require("term")
local gpu = component.gpu

-- Setup components

if not component.isAvailable("draconic_rf_storage") then
  print("Draconic Energy Core not connected.  Please connect computer to Energy Core with an Adapter")
  os.exit()
end

storage = component.draconic_rf_storage

if not component.isAvailable("screen") then
  print("How do you expect to view this?")
  os.exit()
end

-- Set Resolution
res_x = 120
res_y = 25
gpu.setResolution(res_x, res_y)

-- Set Max Value and increment for bottom bars
io_max_rate = 600000
io_increment = io_max_rate / 100

-- Functions

function exit_msg(msg)
  term.clear()
  print(msg)
  os.exit()
end

function get_tier_level(maxrf)
  local tier_level = 0
  if maxrf == 45500000 then
    tier_level = 1
  elseif maxrf == 273000000 then
    tier_level = 2
  elseif maxrf == 1640000000 then
    tier_level = 3
  elseif maxrf == 9880000000 then
    tier_level = 4
  elseif maxrf == 59300000000 then
    tier_level = 5
  elseif maxrf == 356000000000 then
    tier_level = 6
  elseif maxrf == 2140000000000 then
    tier_level = 7
  else
    tier_level = 8
  end
  return tier_level
end

function convert_value(rf)
  if rf == 0 then return "0 RF" end
  local i, units = 1, { "RF", "K RF", "M RF", "G RF", "T RF", "P RF", "E RF", "Y RF" }
  while rf >= 1000 do
    rf = rf / 1000
    i = i + 1
  end
  local unit = units[ i ] or "?"
  local fstr
  if unit == "RF" then
    fstr = "%.0f %s"
  else
    fstr = "%.2f %s"
  end
  return string.format( fstr, rf, unit )
end

function get_percent_color(energy)
  local energycolor
  if energy <= 5 then
    energycolor = RED
  elseif energy <= 25 then
    energycolor = ORANGE
  elseif energy <= 50 then
    energycolor = YELLOW
  elseif energy <= 75 then
    energycolor = GREEN
  elseif energy <= 99 then
    energycolor = BLUE
  else
    energycolor = BLACK
  end
  return energycolor
end

function draw_legend(io)
  gpu.setForeground(fg_default)

  for loc = 0, 100, 10
  do
    term.setCursor(offset + loc, visual_y_start + 11)
    term.write(loc)
    term.setCursor(offset + loc, visual_y_start + 12)
    term.write("|")
  end

  draw_direction(io)

end

function draw_direction(io)

local is_neg
local pos_num

  if io == 0
  then
    return
  elseif io > 0
  then
    is_neg = 0
    pos_num = io
  elseif io < 0
  then
    is_neg = 1
    pos_num = io * -1
  end

  -- Determine how many "="
  local num_col = pos_num / io_increment
  if num_col > 100 then num_col = 100 end
  if num_col < 1 then num_col = 1 end

  -- Create the bars

  local base_bar = ""
  local base_bar1 = ""
  local base_bar2 = ""
  local base_bar3 = ""
  local num_spaces = 100 - num_col
  local space_offset = num_spaces / 2


  for int_space = 0, space_offset, 1
  do
    base_bar = base_bar .. " "
  end

  if is_neg == 1
  then
    base_bar1 = base_bar .. "/"
    base_bar2 = base_bar .. "<="
    base_bar3 = base_bar .. "\\"
  else
    base_bar1 = base_bar
    base_bar2 = base_bar
    base_bar3 = base_bar
  end

  for int_eq = 0, num_col, 1
  do
    base_bar1 = base_bar1 .. "="
    base_bar2 = base_bar2 .. "="
    base_bar3 = base_bar3 .. "="
  end

  if is_neg == 0
  then
    base_bar1 = base_bar1 .. "\\"
    base_bar2 = base_bar2 .. "=>"
    base_bar3 = base_bar3 .. "/"
  end

  -- Draw the actual bars
  if is_neg == 1
  then
    gpu.setForeground(RED)
    term.setCursor(offset, visual_y_start + 15)
    term.write(base_bar1)
    term.setCursor(offset - 1, visual_y_start + 16)
    term.write(base_bar2)
    term.setCursor(offset, visual_y_start + 17)
    term.write(base_bar3)
    gpu.setForeground(fg_default)
  else
    gpu.setForeground(GREEN)
    term.setCursor(offset, visual_y_start + 15)
    term.write(base_bar1)
    term.setCursor(offset, visual_y_start + 16)
    term.write(base_bar2)
    term.setCursor(offset, visual_y_start + 17)
    term.write(base_bar3)
    gpu.setForeground(fg_default)
  end

end

function draw_visuals(percent)

  term.setCursor(offset, visual_y_start + 13)
  for check = 0, 100, 1
  do
    if check <= percent
    then
      gpu.setForeground(get_percent_color(check))
      term.write("|")
      gpu.setForeground(fg_default)
    else
      gpu.setForeground(fg_default)
      term.write(".")
    end
  end
end

-- Define Colors

RED = 0xFF0000
BLUE = 0x0000FF
GREEN = 0x00FF00
BLACK = 0x000000
WHITE = 0xFFFFFF
PURPLE = 0x800080
YELLOW = 0xFFFF00
ORANGE = 0xFFA500
DARKRED = 0x880000

-- Main Code

loopdelay = 1

event_loop = true
while event_loop do

  if not component.isAvailable( "draconic_rf_storage" ) then
    exit_msg("Energy Core disconnected.  Exiting.")
  end

  local storedenergyinit = storage.getEnergyStored()
  local maxenergyinit = storage.getMaxEnergyStored()
  local iorate = storage.getTransferPerTick()
  local tier = get_tier_level(maxenergyinit)

  local percentenergy = storedenergyinit / maxenergyinit * 100

  local convstored = convert_value( storedenergyinit )
  local convmax = convert_value( maxenergyinit )

  offset = 10
  visual_y_start = 5
  fg_default = WHITE
  fg_color_max = PURPLE
  local fg_color_stored = get_percent_color(percentenergy)
  local fg_color_percent = fg_color_stored

  local fg_color_io

  if iorate <= 0 then
    fg_color_io = RED
  else
    fg_color_io = GREEN
  end

  if percentenergy <= 99 then
    gpu.setBackground(BLACK)
  else
    gpu.setBackground(DARKRED)
  end

  term.clear()
  gpu.setForeground(fg_color_max)
  term.setCursor(48, visual_y_start)
  term.write("Energy Storage Tier: " .. tier)
  gpu.setForeground(fg_default)
  term.setCursor(30, visual_y_start + 1)
  term.write("Current Stored Energy / Max Energy: ")
  gpu.setForeground(fg_color_stored)
  term.write(convstored)
  gpu.setForeground(fg_default)
  term.write (" / ")
  gpu.setForeground(fg_color_max)
  term.write(convmax)
  gpu.setForeground(fg_default)
  term.setCursor(44,visual_y_start + 2)
  term.write("Percent Full: ")
  gpu.setForeground(fg_color_percent)
  term.write(string.format("%.12f %s", percentenergy, " %"))
  gpu.setForeground(fg_default)
  term.setCursor(48,visual_y_start + 3)
  term.write("RF/Tick Change: ")
  gpu.setForeground(fg_color_io)
  term.write(iorate)

  draw_visuals(percentenergy)
  draw_legend(iorate)

  os.sleep(loopdelay)

end
