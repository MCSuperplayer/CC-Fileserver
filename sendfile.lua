vpn = ...
vpn = tonumber(vpn)

modem = peripheral.wrap("back")
modem.open(vpn)
function packet(status,content)
    return {
        status = status,
        content = content,
        sender = modem.getNameLocal()
    }
end
function authentication()
    local authkeys = {}
    if not fs.exists(".auth") then
        modem.transmit(vpn,0,packet("200 OK",""))
        return
    end
    local authfile = fs.open(".auth","r")
    local line = authfile.readLine()
    if not line or line == "" then
        printError(".auth is empty, either delete it or set a password(s) in it.")
        modem.transmit(vpn,0,packet("200 OK",""))
        return
    end
    while line do
        if not line == "" then
            authkeys[line] = true
            line = authfile.readLine()
        end
    end
    authfile.close()
    modem.transmit(vpn,0,packet("401 Unauthorized"))
    auth = false
    while not auth do
        local event = os.pullEventRaw("modem_message")
        local msg = event[5]
        if msg.status == "499 Cancel" then
            print("failed auth from "..msg.sender.." at "..os.time("!%b%d_%H%M%S"))
            multishell.setFocus(multishell.getCurrent())
            shell.exit()
        end
        if authkeys[msg.content] == true then
            auth = true
            modem.transmit(vpn,0,packet("200 OK",""))
            return
        end
        modem.transmit(vpn,0,packet("403 Forbidden",""))

    end
end
function transmission()
    print("transmission()")
    while true do
        local event = {os.pullEventRaw("modem_message")}
        if event[3] == vpn and event[5].status == "100 Continue" then break end
    end
    print("continue")
    local file = fs.open(os.getComputerLabel(),"rb")
    local chunk = file.read(1)
    modem.transmit(vpn,0,packet("206 Content",chunk))
    while true do
        local mm = {os.pullEventRaw("modem_message")}
        if mm[3] == vpn then
            chunk = file.read(512)
            if chunk == nil then
                modem.transmit(vpn,0,packet("200 OK"))
                file.close()
                modem.close(vpn)
                return
            end
            modem.transmit(vpn,0,packet("206 Content",chunk))
        end
    end
end
authentication()
transmission()
multishell.setFocus(multishell.getCurrent())
