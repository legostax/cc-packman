--[[
    1.Place down, place up, move back, place front
    2.repeat step 1 until width is reached
    3.if height is reached stop.
    4.move up, place down, move up, place down, move up, turnRight twice
    5.Goto step 1

    NOTE: Slots 1-15 are blocks, slot 16 is fuel
]]
local tArgs = {...}
local buildWidth, buildHeight = nil, nil
if #tArgs < 2 then
    print(fs.getName(shell.getRunningProgram()).." <width> <height>")
    return
else
    buildWidth = tArgs[1]
    buildHeight = tArgs[2]
end

-- speed up calling
local goUp = turtle.up
local goDn = turtle.down
local goLt = turtle.turnLeft
local goRt = turtle.turnRight
local goFd = turtle.forward
local goBk = turtle.back

local function go(d,s)
    if d == "up" then
        for i = 1,s do
            goUp()
        end
    elseif d == "dn" then
        for i = 1,s do
            goDn()
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
            goFd()
        end
    elseif d == "bk" then
        for i = 1,s do
            goBk()
        end
    end
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
        turtle.placeUp()
    elseif side == "dn" then
        turtle.placeDown()
    else
        turtle.place()
    end
end

local function init()

end

local function mainLoop()

end

if init() then mainLoop() end
