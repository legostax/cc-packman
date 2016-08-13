--[[
    1.Place down, place up, move back, place front
    2.repeat step 1 until width is reached
    3.if height is reached stop.
    4.move up, place down, move up, place down, move up, turnRight twice
    5.Goto step 1

    NOTE: Slots 1-15 are blocks, slot 16 is fuel
    TODO: react to insufficient fuel level and block count
]]
local tArgs = {...}
local buildWidth, buildHeight = nil, nil
local currentHeight = 2
local blockType = nil
if #tArgs < 2 then
    print(fs.getName(shell.getRunningProgram()).." <width> <height>")
    return
else
    buildWidth = tonumber(tArgs[1])
    buildHeight = tonumber(tArgs[2])
end

-- speed up calling
local goUp = turtle.up
local goDn = turtle.down
local goLt = turtle.turnLeft
local goRt = turtle.turnRight
local goFd = turtle.forward
local goBk = turtle.back
local plUp = turtle.placeUp
local pl = turtle.place
local plDn = turtle.placeDown
local atUp = turtle.attackUp
local at = turtle.attack
local atDn = turtle.attackDown
local digUp = turtle.digUp
local dig = turtle.dig
local digDn = turtle.digDown

local function go(d,s)
    s = s or 1
    if d == "up" then
        for i = 1,s do
            if not goUp() then
                digUp()
                atUp()
                goUp()
            end
        end
    elseif d == "dn" then
        for i = 1,s do
            if not goDn() then
                digDn()
                atDn()
                goDn()
            end
        end
    elseif d == "lt" then
        for i = 1,s do
            goLt()
        end
    elseif d == "rt" then
        for i = 1,s do
            goRt()
        end
    elseif d == "fd" then
        for i = 1,s do
            if not goFd() then
                dig()
                at()
                goFd()
            end
        end
    elseif d == "bk" then
        for i = 1,s do
            if not goBk() then
                go("rt", 2)
                dig()
                at()
                go("rt", 2)
                goBk()
            end
        end
    end
end

local function getBlockName(data)
    return string.sub(data.name, 11)
end

local function placeBlock(side)
    for i = 1,15 do
        if turtle.getItemCount(i) > 0 then
            if turtle.getSelectedSlot() ~= i then
                turtle.select(i)
            end
            break
        end
    end
    if side == "up" then
        if not plUp() then
            digUp()
            atUp()
            plUp()
        end
    elseif side == "dn" then
        if not plDn() then
            digDn()
            atDn()
            plDn()
        end
    else
        if not pl() then
            dig()
            at()
            pl()
        end
    end
end
-- 1 lava bucket = 1000 fuel
local function init()
    local canRun = true
    local rows = math.floor(buildHeight/3)
    local extramoves = (buildHeight*buildWidth)-(rows*3*buildWidth)
    if extramoves > 0 then
        extramoves = extramoves-2
    end
    print("excess moves: "..extramoves)
    print("Rows: "..rows)
    requiredFuel = ((rows*buildWidth)+rows*2)+buildHeight+extramoves
    startFuel = turtle.getFuelLevel()
    print("Current fuel: "..startFuel)
    print("Required fuel: "..requiredFuel)
    if requiredFuel > startFuel then
        turtle.select(16)
        while true do
            term.clear()
            print("Current fuel: "..turtle.getFuelLevel())
            print("Required fuel: "..requiredFuel)
            print("Slots 1-15: blocks")
            print("Slot 16: fuel")
            print("[r] = Refuel current slot")
            print("[q] = Quit")
            print("[f] = Force run")
            local input = read()
            if input == "r" or input == "R" then
                turtle.refuel(turtle.getItemCount())
                if turtle.getFuelLevel() >= requiredFuel then
                    break
                end
            elseif input == "q" or input == "Q" then
                canRun = false
                break
            elseif input == "f" or input == "F" then break
            else
                print("Invalid input")
                sleep(1)
            end
        end
        turtle.select(1)
    end

    requiredBlocks = buildHeight*buildWidth
    print("Required blocks: "..requiredBlocks)
    blockType = getBlockName(turtle.getItemDetail())
    write("Run? [y/n] ")
    while true do
        local input = read()
        if input == "y" or input == "Y" then
            break
        elseif input == "n" or input == "N" then
            canRun = false
            break
        else
            print("Invalid Input")
        end
    end
    return canRun
end

local function singleBlockPlace()
    for h = currentHeight,buildHeight do
        go("rt",2)
        for i = 1,buildWidth-1 do
            go("bk")
            placeBlock()
        end
        if currentHeight == buildHeight then
            go("rt")
            go("bk")
            placeBlock()
            return true
        else
            go("up")
            placeBlock("dn")
            currentHeight = currentHeight+1
        end
    end
    return false
end
-- buildHeight = 11, currentHeight = 9,
local function mainLoop()
    --term.clear()
    --term.setCursorPos(1,1)
    for j = 1,math.floor(buildHeight/3) do
        --print("currentHeight: "..currentHeight)
        for i = 1,buildWidth-1 do
            placeBlock("up")
            placeBlock("dn")
            go("bk")
            placeBlock()
        end
        placeBlock("dn")
        go("up")
        placeBlock("dn")
        go("up")
        placeBlock("dn")
        currentHeight = currentHeight+2

        --check fuel level and block count

        if currentHeight >= buildHeight-2 then
            if not singleBlockPlace() then go("rt") go("bk") end
            go("dn", currentHeight-1)
            break
        end
        go("up")
        go("rt", 2)
        currentHeight = currentHeight+1
    end
    print("currentHeight: "..currentHeight)
end

if init() then mainLoop()
    print("Used fuel: "..tostring(startFuel-turtle.getFuelLevel()))
end
