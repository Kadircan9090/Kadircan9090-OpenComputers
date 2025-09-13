local component = require("component")
local event = require("event")
local modem = component.modem
local term = require("term")

local SERVER_PORT = 123

-- Kullanıcı adı sor
io.write("Kullanıcı adınızı girin: ")
local username = io.read()

-- Server'a kayıt
modem.open(SERVER_PORT)
modem.broadcast(SERVER_PORT, {type="register", name=username})
print("Server'a kayıt gönderildi. Mesaj bekleniyor...")

-- Mesaj alma için event dinleyici
local function listenMessages()
    while true do
        local _, _, from, port, _, msg = event.pull("modem_message")
        if type(msg) == "table" and msg.type == "chat" then
            print(msg.msg)
        elseif type(msg) == "table" and msg.type == "ack" then
            print("[Server] " .. msg.msg)
        end
    end
end

-- Mesaj gönderme fonksiyonu
local function sendMessage(text)
    -- Özel mesaj kontrolü
    if text:sub(1,5) == "/msg " then
        local _, _, target, message = text:find("^/msg (%S+) (.+)")
        if target and message then
            modem.broadcast(SERVER_PORT, {type="whisper", to=target, msg=message})
            return
        end
    end
    modem.broadcast(SERVER_PORT, {type="say", msg=text})
end

-- Mesaj alma işlemini arka planda çalıştır
local co = coroutine.create(listenMessages)
coroutine.resume(co)

-- Kullanıcıdan mesaj al
while true do
    io.write("> ")
    local input = io.read()
    if input ~= "" then
        sendMessage(input)
    end
end
