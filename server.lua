local file = ...
if file == nil then
    printError("Missing Parameter: <filename>")
    return
end
if not fs.exists(file) then
    print("404 File ".. file .." not found.")
    return
end
modem = peripheral.wrap("back")
modem.closeAll()
if not modem then
    printError("Error, No Network Found. Please attach a Modem to the back of the Server")
    return
end
if modem.isWireless() then
    printError("404 Internet not found. Wireless Modem is unable to connect to the servers. Connect to a local network with a Wired Modem.")
    return
end

shell.run("label set ".. file)

shell.run("label set ".. file)
modem.open(987)
while true do
    event = {os.pullEventRaw()}
    if event[1] == "terminate" then
        print("Server shutting down...")
        os.sleep(2)
        os.shutdown()
    elseif event[1] == "modem_message" then
        local packet = event[5]
        if packet.status == "CONNECT" and packet.content.filename == os.getComputerLabel() then
            print("incoming request from "..packet.sender)
            shell.run("bg sendfile.lua "..packet.content.vpn)
        end
    end
end