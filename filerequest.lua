filename = ...
rednet.open("top")
local server = rednet.lookup("fileserver",filename)
if server == nil then
    print("No Server is hosting the requested file.")
    return
    end
rednet.send(server,"","fileserver")
local server, vpn = rednet.receive("private_key")
local file = fs.open(filename,"w+")
local running = true
while running do
    rednet.send(server,"request",vpn)
    sender,line = rednet.receive(vpn)
    if line=="#EOF" then
        file.close()
        running=false
    elseif line=="#INTERRUPT" then
        file.close()
        running=false
        print("Conflict occured, please restart program.")
        io.read()
    else do
        file.writeLine(line)
    end
    end
end
