rednet.open("top")
local addressserver = rednet.lookup("fileserver", "addressfile.txt")
if not addressserver then
    print("Addressfile server could not be reached...")
    return
end
rednet.send(addressserver,"update", "update_addressfile")
local server, vpn = rednet.receive("private_key")
local file = fs.open("addressfile.txt","r")
local running = true
while running do
    rednet.receive(vpn)
    local line = file.readLine()
    if line==nil then line="EOF" running=false end
    rednet.send(server, line, vpn)
end
