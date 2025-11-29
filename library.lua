diskdrive = peripheral.wrap("bottom")
local uistate,uitimerid = 0,0
req = dofile("request.lua")
function idlemode_initiate()
    uistate = 0
    uitimerid = os.startTimer(1)
    term.setCursorBlink(false)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(14,5)
    term.setTextColor(colors.red)
    term.write("MC's Digital File Library")
    term.setCursorPos(51,1)
    term.blit("X","0","e")
    term.setCursorPos(21,14)
    term.setTextColor(colors.white)
    term.write("Insert disk")
    term.setCursorPos(26,10)
    term.blit("-","0","f")
end
function updateui()
    term.setCursorPos(26,10)
    if uistate == 0 then
        term.blit("\\","0","f")
        uistate = 1
    elseif uistate == 1 then
        term.blit("|","0","f")
        uistate = 2
    elseif uistate == 2 then
        term.blit("/","0","f")
        uistate = 3
    elseif uistate == 3 then
        term.blit("-","0","f")
        uistate = 0
    end
    uitimerid = os.startTimer(1)
end
function activemode_initiate()
    query = ""
    term.setCursorBlink(false)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(14,1)
    term.setTextColor(colors.red)
    term.write("MC's Digital File Library")
    term.setCursorPos(47,18)
    term.blit("Eject","00000","eeeee")
    term.setCursorPos(47,19)
    term.blit("Drive","00000","eeeee")
    term.setCursorPos(23,16)
    term.blit("Request","fffffff","ddddddd")
    term.setCursorPos(10,10)
    term.setTextColor(colors.white)
    term.write("File: ")
    term.setBackgroundColor(colors.gray)
    term.write(string.rep(" ",maxlength))
    term.setCursorPos(16,10)
    term.setCursorBlink(true)
end
function typing(char)
    if #query < maxlength then
        query = query..char
        term.write(char)
    end
end
function backspace()
    if #query > 0 then
        query = query:sub(1,-2)
        local x,y = term.getCursorPos()
        term.setCursorPos(x-1,y)
        term.write(" ")
        term.setCursorPos(x-1,y)
    end
end
function exitButton()
    running = false
    idlemode_initiate()
end
local function submit()
    term.setCursorBlink(false)

    statustxt("Requesting File...")
    request(query)
    activemode_initiate()
end
local function eject()
    diskdrive.ejectDisk()
end
function activemode()
    running = true
    query = ""
    maxlength = 27


    activemode_initiate()
    while running do
        local eventdata = {os.pullEvent()}
        local event = eventdata[1]
        if event == "char" then
            typing(eventdata[2])
        elseif event == "key" then
            if eventdata[2] == keys.backspace then
                backspace()
            end
        elseif event == "disk_eject" then
            exitButton()
        elseif event == "mouse_click" then
            local mx,my = eventdata[3], eventdata[4]
            if mx >= 47 and mx <=51 and my >= 18 and my <= 19 then
                eject()
                exitButton()
            elseif my == 16 and mx >=23 and mx <= 29 then
                submit()
            end

        end
    end
end
idlemode_initiate()
while true do
    local event = {os.pullEvent()}
    if event[1] == "timer" then
        updateui()
    elseif event[1] == "disk" then
        os.cancelTimer(uitimerid)
        activemode()
    elseif event[1] == "mouse_click" then
        if event[3] == 51 and event[4] == 1 then
            statustxt("Library Shutting down...")
            os.sleep(3)
            return
        end
    end
end