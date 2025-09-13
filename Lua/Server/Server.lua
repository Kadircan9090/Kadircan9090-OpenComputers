local component = require("component")
local event = require("event")
local modem = component.modem

local PORT = 123
local clients = {} -- clients[from] = {name="Kadircan"}

modem.open(PORT)
print("Server başlatıldı. Port " .. PORT .. " dinleniyor...")

while true do
    local _, _, from, port, _, msg = event.pull("modem_message")
    
    if type(msg) == "table" and msg.type then
        if msg.type == "register" then
            clients[from] = {name = msg.name}
            modem.send(from, PORT, {type="ack", msg="Kayıt başarılı, hoşgeldin " .. msg.name .. "!"})
            print("Yeni client: " .. msg.name .. " (" .. tostring(from) .. ")")
        elseif msg.type == "say" then
            local senderName = clients[from] and clients[from].name or "Bilinmeyen"
            local text = senderName .. ": " .. msg.msg
            print(text)
            -- Mesajı tüm clientlara gönder
            for client, _ in pairs(clients) do
                modem.send(client, PORT, {type="chat", msg=text})
            end
        elseif msg.type == "whisper" then
            local targetName = msg.to
            local senderName = clients[from] and clients[from].name or "Bilinmeyen"
            for client, data in pairs(clients) do
                if data.name == targetName then
                    modem.send(client, PORT, {type="chat", msg="[Özel] " .. senderName .. ": " .. msg.msg})
                end
            end
        end
    end
end

