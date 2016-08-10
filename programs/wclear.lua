local args = {...}
if not commands then
	print("This program is for Command Computers only")
	return
end
if args[1] == "?" or args[1] == "/?" or args[1] == "-?" or args[1] == "help" then
	print("Usage:")
	print(fs.getName(shell.getRunningProgram()).." [ticksToWait] [programToRun]")
	return
end
local ticksToWait = tonumber(args[1]) or 999999
local prog = args[2] or "rom/programs/shell"
print("WClear Daemon Waiting "..ticksToWait.." for each command")
local function main()
	while true do
		commands.exec("/weather clear 999999")
		sleep(ticksToWait/20)
	end
end
parallel.waitForAny(function() shell.run(prog) end, main)
print("Daemon killed")
