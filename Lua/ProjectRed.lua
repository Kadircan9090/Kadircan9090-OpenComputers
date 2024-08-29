--###################################################################
--################# ProjectRed SISD Display v1.2 ####################
--#################      (c) 2015 GigaToni       ####################
--#################     DO NOT REDISTRIBUTE!     ####################
--###################################################################

component = require("component")
sides = require("sides")

local redstoneAddresses = {  
  {
      ["address"] = "7c6d5491-a963-4430-a14a-cfc5ec4b3541",
      ["validSides"] = {
        sides.north,
        sides.west,
        sides.south
      }
  },
  
  {
      ["address"] = "1785bfc1-6954-4bfa-8aba-af149ef604a0",
      ["validSides"] = {
        sides.north,
        sides.west,
        sides.south
      }
  },
  {
      ["address"] = "ade52eb1-7641-4fc0-b6f9-4380b966e5c4",
      ["validSides"] = {
        sides.north,
        sides.west,
        sides.south
      }
  }
}

local segments = {
  ["*"] = 65280,
  ["+"] = 43520,
  ["-"] = 34816,
  ["0"] = 17663,
  ["1"] = 12,
  ["2"] = 34935,
  ["3"] = 34879,
  ["4"] = 34956,
  ["5"] = 37043,
  ["6"] = 35067,
  ["7"] = 15,
  ["8"] = 35071,
  ["9"] = 35007,
  
  ["A"] = 35023,
  ["B"] = 10815,
  ["C"] = 243,
  ["D"] = 8767,
  ["E"] = 35059,
  ["F"] = 35011,
  ["G"] = 2299,
  ["H"] = 35020,
  ["I"] = 8755,
  ["J"] = 124,
  ["K"] = 38080,
  ["L"] = 240,
  ["M"] = 1484,
  ["N"] = 4556,
  ["O"] = 255,
  ["P"] = 35015,
  ["Q"] = 4351,
  ["R"] = 39111,
  ["S"] = 35003,
  ["T"] = 8707,
  ["U"] = 252,
  ["V"] = 17600,
  ["W"] = 20684,
  ["X"] = 21760,
  ["Y"] = 43140,
  ["Z"] = 17459,
}

local nullCols = {
  [0] = 0,
  [1] = 0,
  [2] = 0,
  [3] = 0,
  [4] = 0,
  [5] = 0,
  [6] = 0,
  [7] = 0,
  [8] = 0,
  [9] = 0,
  [10] = 0,
  [11] = 0,
  [12] = 0,
  [13] = 0,
  [14] = 0,
  [15] = 0,
}

function resetDisplay()
  for k,v in pairs(redstoneAddresses) do
    if(#v["validSides"] > 5) then
      print("Address " .. v["address"] .. " Error: You may only have 5 sides!")
    end
    
    if(component.list(v["address"]) == nil) then
      print("Address " .. v["address"] .. " Error: Address is not available!")
    end
    
    for key, side in pairs(v["validSides"]) do
      if(sides[side] == nil) then
        print("Side (".. key ..") " .. side .. " Error: The specified side is invalid!")
      else
        print("Clearing ("..v["address"]..") Side: " .. sides[side] .. "")
        component.invoke(v["address"], "setBundledOutput", side, nullCols)
      end
    end
  end
end

function displaySegment(address, side, value)
  local setCols = {}   
  for n = 0, 15, 1 do
    setCols[n] = bit32.band(bit32.rshift(value, n), 0x1) * 255
  end
  
  if(address == nil) then
    print("No address given!")
    return
  end
  if(component.list(address) == nil) then
    print("Unavailable address found: " .. address)
    return
  end
  component.invoke(address, "setBundledOutput", side, setCols)
end

function splitSegment(str)
  if(type(str) == number) then
    str = tostring(str)
  end
  
  local sID = 1
  for _, add in pairs(redstoneAddresses) do
    for _, side in pairs(add["validSides"]) do
      local c = str:sub(sID, sID)
      if(c ~= nil and c ~= "" and c ~= " ") then
        if(segments[c] ~= nil) then
          displaySegment(add["address"], side, segments[c])
        else
          print(add["address"] .. " (" .. sides[side] .. ") received unknown character '" .. c .. "'")
        end
      elseif(c == " ") then
        -- skip whitespace
      else
        return
      end
      sID = sID + 1
    end
  end
end

function marqueeDisplay(str)
  str = str .. "  "
  
  splitSegment(str)
  os.sleep(1)
  
  while true do
    resetDisplay()
    
    local c = str:sub(1, 1)
    str = str:sub(2, #str) .. c
    splitSegment(str)
    
    os.sleep(1)
  end
end

-------------------------------------------------------------------------------------
------------------------------------ Program start ----------------------------------
-------------------------------------------------------------------------------------
resetDisplay()

----- Examples:
--splitSegment("ABCDEFGHI")
--marqueeDisplay("HELLO")