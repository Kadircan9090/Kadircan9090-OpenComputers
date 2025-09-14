local component = require("component")
local event = require("event")
local fs = require("filesystem")
local serialization = require("serialization")

local modem = component.modem
local port = 1234  -- İstediğin port
local dataFile = "/home/data.db" -- Verilerin kaydedileceği dosya
local database = {}

-- Veritabanını yükle
local function loadDB()
    if fs.exists(dataFile) then
        local file = io.open(dataFile, "r")
        if file then
            local content = file:read("*a")
            file:close()
            if content and #content > 0 then
                local ok, tbl = pcall(serialization.unserialize, content)
                if ok and type(tbl) == "table" then
                    database = tbl
                end
            end
        end
    end
end

-- Veritabanını kaydet
local function saveDB()
    local file = io.open(dataFile, "w")
    if file then
        file:write(serialization.serialize(database))
        file:close()
    end
end

-- Sunucuyu başlat
modem.open(port)
print("Sunucu port " .. port .. " üzerinde dinliyor...")

-- Veritabanını yükle
loadDB()

while true do
    local _, _, from, senderPort, _, message, key, value = event.pull("modem_message")
    
    if message == "set" and key and value then
        database[key] = value
        saveDB()
        modem.send(from, senderPort, "OK: Veri kaydedildi")
    
    elseif message == "get" and key then
        local result = database[key]
        if result then
            modem.send(from, senderPort, "VALUE: " .. tostring(result))
        else
            modem.send(from, senderPort, "ERROR: Veri bulunamadı")
        end
    
    elseif message == "list" then
        modem.send(from, senderPort, "DATABASE: " .. serialization.serialize(database))
    
    else
        modem.send(from, senderPort, "ERROR: Geçersiz komut")
    end
end
