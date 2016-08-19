local tArgs = {...}

if #tArgs < 2 then
    print(fs.getName(shell.getRunningProgram()).." <spaces_out> <buckets>")
    return
else
    local spaces = tonumber(tArgs[1])
    local buckets = tonumber(tArgs[2])
    local fd = turtle.forward
    local bk = turtle.back
    local pl = turtle.placeDown

    for i = 1,spaces do
        fd()
    end
    for i = 1,buckets do
        pl()
        fd()
    end
    for i = 1,buckets do
        bk()
    end
    for i = 1,spaces do
        bk()
    end
    print("Fuel level: "..turtle.getFuelLevel())
end
