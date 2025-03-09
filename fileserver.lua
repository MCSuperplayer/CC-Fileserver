file = ...
shell.run("label set "..file)
rednet.open("top")
rednet.host("fileserver",file)
while true do
    event, id, message, protocol = os.pullEventRaw()
    if event == "terminate" then
        rednet.unhost("fileserver")
        print("unhosted "..file)
        io.read()
        return
    elseif event == "rednet_message" then
        if protocol == "fileserver" then
            print("sending "..file.."to computer"..id)
            vpn = tostring(math.random(1024))
            rednet.send(id,vpn,"private_key")
            shell.run("parallelFileSender.lua", id, vpn, file)
        end
    end
end

