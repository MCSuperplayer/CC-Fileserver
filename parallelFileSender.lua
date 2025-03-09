local id, vpn, filename = ...
id = tonumber(id)
local running = true
local file = fs.open(filename,"r")
local sender,msg
local line
while running do
    sender, msg = rednet.receive(vpn)
    if not sender == id then
        rednet.send(sender,"You should not be on this channel, please reconnect.")
        rednet.send(id,"#INTERRUPT",vpn)
        break
    end
    if (msg=="request") then
        line = file.readLine()
        if line==nil then
            rednet.send(id,"#EOF",vpn)
            running = false
        else do
            rednet.send(id,line,vpn)
        end
        end
    end
end
