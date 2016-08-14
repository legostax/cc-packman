--[[
1. Plant seeds
2. Wait several days
3. Harvest
4. Deposit
Go back to step 1
]]
local pl = turtle.placeDown
local fd = turtle.forward
local turnRight = false
--plant
for w = 1,14 do
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
end
