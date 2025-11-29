local filename
local modem = peripheral.wrap("back")
function check_network()
    if filename == "" then
        statustxt("Please enter a file to request.")
        return false
    end
    modem.closeAll()
    if not modem then
        statustxt("Error, No Network Found.")
        return false
    end
    if modem.isWireless() then
        statustxt("404 Internet not found.")
        return false
    end
    return true
end

function packet(status,content)
    return {
        status = status,
        content = content,
        sender = modem.getNameLocal()
    }
end

function authenticate()
    if not fs.exists("disk/.auth") then
        statustxt("No Auth file found.")
        sleep(2)
        return
    end
    local authfile = fs.open("disk/.auth","r")
    while not authed do
        local pw = authfile.readLine()
        if not pw then
            statustxt("No valid passcode in Authfile, terminating...")
            modem.transmit(vpn,0,packet("499 Cancel"))
            return
        end
        modem.transmit(vpn,0,packet("100 Continue", pw))
        local _,_,_,data = os.pullEvent("modem_message")
        if data.status == "403 Forbidden" then

        end
    end
end
function request(query)
    filename = query
    if not check_network() then os.sleep(2) return end
    local vpn = 6--math.random(10000,65500)
    local waiting = true
    local timer = os.startTimer(10)
    modem.transmit(987,0,packet("CONNECT",{filename=filename,vpn=vpn}))

    modem.open(vpn)
    local event,t,rec,data
    while waiting do
        event,t,rec,_,data = os.pullEvent()
        if event == "timer" and t == timer then
            statustxt("Request Timed out.")
            sleep(3)
            return
        elseif event == "modem_message" and rec == vpn then
            waiting = false
            statustxt("Received Response")
            os.cancelTimer(timer)
        end
    end
    if data.status == "401 Unauthorized" then
        statustxt("Authentication required..")
        local authed = false
        authenticate()
        if not authed then return end
    else do
        statustxt("No Authentication required. Downloading...")
    end
    end
    local done = false
    modem.transmit(vpn,0,packet("100 Continue",""))
    local file = fs.open("disk/"..filename,"w+b")
    while not done do
        event,_,rec,_,data = os.pullEvent("modem_message")
        if data.status == "206 Content" then
            file.write(data.content)
            modem.transmit(vpn,0,packet("100 Continue",""))
        elseif data.status == "200 OK" then
            file.close()
            done =  true
            statustxt("Transfer Complete.")
            os.sleep(2)
        end

    end
end

function statustxt(msg)
    local oldtxt = term.getTextColor()
    local oldbg = term.getBackgroundColor()
    term.setTextColor(colors.lightGray)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1,12)
    term.write(string.rep(" ",51))
    term.setCursorPos(math.floor((51-#msg)/2)+1,12)
    term.write(msg)
    term.setTextColor(oldtxt)
    term.setBackgroundColor(oldbg)
end

return {request,statustxt}
