--[[
1. Plant seeds
2. Wait several days
3. Harvest
4. Deposit
Go back to step 1
]]

--plant
--[[for w = 1,14 do
    for l = 1,15 do
        pl()
        fd()
    end
    pl()
    if w < 14 then
        if turnRight then turtle.turnRight()
        else turtle.turnLeft() end
        fd()
        if turnRight then turtle.turnRight()
        else turtle.turnLeft() end
        turnRight = not turnRight
    else
        turtle.turnLeft()
        for i = 1,15 do fd() end
        break
    end
end]]--

--local commands
local pl = turtle.placeDown
local fd = turtle.forward

--vars
local nLastHarvest = 0 -- stores last day of harvest
local nNextHarvest = 0 -- stores predicted day of harvest
local pLastHarvest = "lastharvest.txt" -- last day of harvest saved to file

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

local function plantWheat()

end

local function harvestWheat()

end

local function harvestCane()

end

local function init()
    if fs.exists(pLastHarvest) then
        nLastHarvest = tonumber(readFile(pLastHarvest))
        print("Last harvest on: "..tostring(nLastHarvest))
        nNextHarvest = nLastHarvest+3
        print("Next harvest on: "..tostring(nNextHarvest))
    end
end

local function main()
    writeFile(pLastHarvest,nLastHarvest)
end
init()
main()
