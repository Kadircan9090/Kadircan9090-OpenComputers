local component = require("component")
local event = require("event")
local term = require("term")
local fs = require("filesystem")
local magReader = component.os_magreader

local accountsFile = "/accounts.txt"
local accounts = {}

-- Hesapları yükle
function loadAccounts()
  accounts = {}
  if fs.exists(accountsFile) then
    for line in io.lines(accountsFile) do
      local user, balance = line:match("([^:]+):(%d+)")
      accounts[user] = tonumber(balance)
    end
  end
end

-- Hesapları kaydet
function saveAccounts()
  local file = io.open(accountsFile, "w")
  for user, balance in pairs(accounts) do
    file:write(user .. ":" .. balance .. "\n")
  end
  file:close()
end

-- Para işlemleri
function deposit(user, amount)
  accounts[user] = (accounts[user] or 0) + amount
  saveAccounts()
end

function withdraw(user, amount)
  if (accounts[user] or 0) >= amount then
    accounts[user] = accounts[user] - amount
    saveAccounts()
    return true
  else
    return false
  end
end

-- Ana fonksiyon
function runATM()
  loadAccounts()
  term.clear()
  print("ATM'ye Hoşgeldiniz")
  print("Lütfen kartınızı okutun...")

  local _, _, _, _, _, user = event.pull("magData")
  print("Merhaba, " .. user)
  if accounts[user] == nil then
    print("Yeni hesap oluşturuluyor...")
    accounts[user] = 0
    saveAccounts()
  end

  while true do
    print("\n1. Bakiye Görüntüle")
    print("2. Para Yatır")
    print("3. Para Çek")
    print("4. Çıkış")
    io.write("> ")
    local choice = io.read()

    if choice == "1" then
      print("Bakiyeniz: " .. accounts[user])
    elseif choice == "2" then
      io.write("Yatırılacak miktar: ")
      local amount = tonumber(io.read())
      if amount and amount > 0 then
        deposit(user, amount)
        print("Yatırma başarılı. Yeni bakiye: " .. accounts[user])
      else
        print("Geçersiz miktar.")
      end
    elseif choice == "3" then
      io.write("Çekilecek miktar: ")
      local amount = tonumber(io.read())
      if amount and amount > 0 then
        if withdraw(user, amount) then
          print("Çekme başarılı. Yeni bakiye: " .. accounts[user])
        else
          print("Yetersiz bakiye.")
        end
      else
        print("Geçersiz miktar.")
      end
    elseif choice == "4" then
      print("Çıkış yapılıyor. İyi günler!")
      break
    else
      print("Geçersiz seçim.")
    end
  end
end

-- Çalıştır
runATM()
