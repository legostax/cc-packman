-- Command Computer Clearing program
local tArgs = {...}
if not commands then
	print("Command Computers only")
	return
end
if #tArgs < 6 then
	print(fs.getName(shell.getRunningProgram()).." <x1> <y1> <z1> <x2> <y2> <z2>")
	return
end
-- filter args
local x1 = math.floor(tonumber(tArgs[1]))
local y1 = math.floor(tonumber(tArgs[2]))
local z1 = math.floor(tonumber(tArgs[3]))
local x2 = math.floor(tonumber(tArgs[4]))
local y2 = math.floor(tonumber(tArgs[5]))
local z2 = math.floor(tonumber(tArgs[6]))
local volume = (math.abs((x1-x2)+1))*(math.abs((y1-y2)+1))*(math.abs((z1-z2)+1))
-- confirmation
print("Are you sure you want to delete "..volume.." blocks?")
print("X1: "..tArgs[1].." Y1: "..tArgs[2].." Z1: "..tArgs[3])
print("X2: "..tArgs[4].." Y2: "..tArgs[5].." Z2: "..tArgs[6])
while true do
	e = {os.pullEvent("key")}
	if e[2] == keys.y then
		print("Clearing "..volume.." blocks")
		-- clear space
		for y = y1,y2 do
			for z = z1,z2 do
				for x = x1,x2 do
					commands.exec("/setblock "..x.." "..y.." "..z.." minecraft:air")
				end
			end
		end
		print("Success")
		break
	elseif e[2] == keys.n then
		print("Aborted")
		break
	end
end
coroutine.yield()
