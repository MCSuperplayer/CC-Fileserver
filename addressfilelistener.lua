while true do
local id = rednet.receive("update_addressfile")
print("Receiving updated Address file from Computer "..id)
local vpn = tostring(math.random(1024))
rednet.send(id, vpn, "private_key")
local file = fs.open("addressfile.txt","w+")
local receiving = true
while receiving do
    rednet.send(id, "", vpn)
    local id, line = rednet.receive(vpn)
    if line=="EOF" then 
        receiving=false
        file.close()
    else do
        file.writeLine(line)
    end
    end
end
end
