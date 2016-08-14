--[[
    1. Go down to diamond level
    2. Mine all of diamond level (y5-12)
        A. turtle.drop() everything not valuable
    3. Come back up and deposit.
]]
local yLevel = nil
local origY = nil

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
local oldDigUp = turtle.digUp
local oldDig = turtle.dig
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

local function dig()
    print("called dig()")
    local b,d = turtle.inspect()
    oldDig()
    if b then
        if getBlockName(d) == "gravel" or getBlockName(d) == "sand" then
            sleep(1)
        end
    end
end
local function digUp()
    print("called digUp()")
    local b,d = turtle.inspectUp()
    oldDigUp()
    if b then
        if getBlockname(d) == "gravel" or getBlockName(d) == "sand" then
            sleep(1)
        end
    end
end

local function init()
    print("Please enter the current Y level:")
    write("> ")
    yLevel = tonumber(read())
    origY = yLevel
    return true
end

local function main()
    while yLevel > 12 do
        digDn()
        go("dn")
        yLevel = yLevel-1
    end

    go("dn", 2)
    local turnRight = true
    for h = yLevel,6,-1 do
        for w = 1,16 do
            for l = 1,15 do
                digUp()
                digDn()
                dig()
                go("fd")
            end
            digUp()
            digDn()
            for i = 1,16 do
                if turtle.getItemDetail(i) then
                    local n = getBlockName(turtle.getItemDetail(i))
                    if n == "stone" or n == "cobblestone" or n == "dirt" or n == "gravel" then
                        turtle.select(i)
                        turtle.drop()
                    end
                end
            end
            turtle.select(1)
            if w < 16 then
                if turnRight then
                    go("rt")
                    dig()
                    go("fd")
                    go("rt")
                else
                    go("lt")
                    dig()
                    go("fd")
                    go("lt")
                end
                turnRight = not turnRight
            else break end
        end
        go("dn", 3)
        go("rt", 2)
        turnRight = false
    end
    while yLevel < origY do
        digUp()
        go("up")
        yLevel = yLevel+1
    end
end

if init() then main() end
