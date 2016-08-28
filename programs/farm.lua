--v0.3
--vars
local nFarmWidth = 12
local nFarmLength = 8
local nSugarWidth = 12
local nSugarLength = 5
local daywait = 3
local nLastHarvest = 1 -- stores last day of harvest
local nNextHarvest = 0 -- stores predicted day of harvest
local pLastHarvest = "lastharvest.txt" -- last day of harvest saved to file
local status = "Waiting..."

--local commands
local pl = turtle.placeDown
local fd = turtle.forward
local bk = turtle.back
local up = turtle.up
local dn = turtle.down
local lt = turtle.turnLeft
local rt = turtle.turnRight
local digDn = turtle.digDown
local digUp = turtle.digUp
local dig = turtle.dig
local plDn = turtle.placeDown

local function readFile(p)
    local f = fs.open(p, "r")
    local d = f.readAll()
    f.close()
    return d
end

local function writeFile(p,d)
    local f = fs.open(p, "w")
    f.write(d)
    f.close()
    return true
end

local function go(d,s)
    local dummy = nil
    if d == "up" then
        dummy = up
    elseif d == "dn" then
        dummy = dn
    elseif d == "lt" then
        dummy = lt
    elseif d == "rt" then
        dummy = rt
    elseif d == "fd" then
        dummy = fd
    elseif d == "bk" then
        dummy = bk
    end
    if dummy then
        for i = 1,s do
            dummy()
        end
    end
end

local function harvestWheat()
    status = "Harvesting Wheat"
    local turnRight = false
    for l = 1,nFarmLength do
        for w = 1,nFarmWidth do
            digDn()
            plDn()
            if w < nFarmWidth then fd() end
        end
        if l < nFarmLength then
            if turnRight then rt() fd() rt()
            else lt() fd() lt() end
            turnRight = not turnRight
        end
    end
    if turnRight then lt()
    else rt() end
    for i = 1,nFarmLength do
        fd()
    end
    lt()
end

local function harvestCane()
    status = "Harvesting Sugar Cane"
    up()
    lt()
    go("fd",nFarmLength)
    rt()
    local turnRight = false
    for l = 1,nSugarLength do
        for w = 1,nSugarWidth do
            dig()
            digDn()
            if w < nSugarWidth then fd() end
        end
        if l < nSugarLength then
            print("l < nSugarLength")
            if turnRight then
                rt() dig()
                fd() rt()
                print("turnRight is true")
            else
                lt() dig()
                fd() lt()
            end
            turnRight = not turnRight
        end
    end
    if turnRight then lt()
    else
        go("lt",2)
        go("fd",nSugarWidth-1)
        lt()
    end
    go("fd",nSugarLength+nFarmLength-1)
    lt()
    dn()
end

local function returnItems()
    status = "Depositing Items"
    go("up",2)
    lt()
    go("fd",nFarmLength+nSugarLength)
    go("dn",4)
    for i = 2,16 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.dropDown()
        end
    end
    turtle.select(1)
    if turtle.getFuelLevel() < ((nFarmLength*nFarmWidth)+(nSugarLength*nSugarWidth)+nFarmWidth+50) then
        print("Refueling...")
        turtle.select(2)
        rt()
        fd()
        turtle.suckDown()
        turtle.refuel()
        turtle.dropDown()
        turtle.select(1)
        bk()
        lt()
    end
    go("up",4)
    go("bk",nFarmLength+nSugarLength)
    rt()
    go("dn",2)
end

local function init()
    if fs.exists(pLastHarvest) then
        local d = readFile(pLastHarvest)
        nLastHarvest = tonumber(d)
        print("Last harvest on: "..tostring(nLastHarvest))
        nNextHarvest = nLastHarvest+daywait
        print("Next harvest on: "..tostring(nNextHarvest))
    else
        print("Last harvest unknown")
        nLastHarvest = os.day()
        nNextHarvest = nLastHarvest+daywait
        writeFile(pLastHarvest,tostring(nLastHarvest))
    end
end

local function statusUpdate()
    local function draw()
        term.clear()
        term.setCursorPos(1,1)
        term.write("Day: "..os.day().."  Time: "..textutils.formatTime(os.time()))
        term.setCursorPos(1,3)
        term.write("Last Harvest: "..nLastHarvest)
        term.setCursorPos(1,5)
        term.write("Next Harvest: "..nNextHarvest)
        term.setCursorPos(1,7)
        term.write("Fuel Level: "..turtle.getFuelLevel())
        term.setCursorPos(1,9)
        term.write("Status: "..status)
    end
    draw()
    local timeofdayTimer = os.startTimer(0.8)
    while true do
        local e = {os.pullEvent("timer")}
        if e[2] == timeofdayTimer then
            timeofdayTimer = os.startTimer(0.8)
            draw()
        end
    end
end

local function main()
    local timeout = os.startTimer(1)
    while true do
        local e = {os.pullEvent()}
        if e[1] == "timer" and e[2] == timeout then
            if os.day() >= nNextHarvest then
                harvestWheat()
                harvestCane()
                returnItems()
                nLastHarvest = tonumber(os.day())
                nNextHarvest = nNextHarvest+daywait
                writeFile(pLastHarvest, tostring(nLastHarvest))
                status = "Waiting..."
                timeout = os.startTimer(300)
            else
                timeout = os.startTimer(300)
            end
        end
    end
end
init()
parallel.waitForAny(main,statusUpdate)
