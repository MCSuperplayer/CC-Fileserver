term.redirect(_G.mainTerm)
function exit()
    multishell.setFocus(multishell.getCurrent())
    shell.exit()
end

id, vpn, filename = ...
id = tonumber(id)
running = true
authkeys = {}


local function authentication()
    if not fs.exists(".auth") then
        rednet.send(id, 200, vpn)
        return
    end
    authfile = fs.open(".auth")
    local line = authfile.readLine()
    if not line then
        printError(".auth is empty, either delete it or set a password in it.")
        rednet.send(id, 200, vpn)
        return
    end
    while line do
        authkeys[line] = true
        line = authfile.readLine()
    end
    rednet.send(id, 401, vpn)
    auth = false
    while not auth do
        local _, key = rednet.receive(vpn)
        if key == 417 then
            print("Requester ID: "..id.." failed Authentication")
            exit()
        end
        if authkeys[key] == true then
            auth = true
            rednet.send(id, 200, vpn)
            return
        else do
            rednet.send(id, 403, vpn)
        end
        end
    end
end

authentication()
file = fs.open(filename, "r")
while running do
    local sender, msg = rednet.receive(vpn)
    if not sender == id then
        rednet.send(sender, "#COLLISION",vpn)
        rednet.send(id, "#COLLISION",vpn)
        print("Collision with IDs "..sender.." and "..id)
        break
    end
    if msg == 100 then
        line = file.readLine()
        if line == nil then
            rednet.send(id, "#EOF", vpn)
            running = false
            print("Finished transmitting file to ID: "..id)
            exit()
        else do
            rednet.send(id, line, vpn)
        end
        end
    end
end
