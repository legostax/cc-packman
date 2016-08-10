--[[
	GSet - LegoStax
	GUI program for global CC settings
]]--
local tArgs = {...}
local running = true
local w,h = term.getSize()
local SETTINGS_PATH = ".settings"
local SETTINGS = settings.getNames()
local scrollpos = 1
local pospossible = #SETTINGS-(h-4)
table.sort(SETTINGS)
local choice = 1
local advMode

if term.isColor() or term.isColour() then
	advMode = true
else
	advMode = false
end

if fs.exists(SETTINGS_PATH) then settings.load(SETTINGS_PATH) end

if tArgs[1] ~= nil then
	if tArgs[1] == "-?" or tArgs[1] == "-help" then
		print(fs.getName(shell.getRunningProgram()).." [settings_path]")
		running = false
		return
	elseif fs.exists(tArgs[1]) then
		SETTINGS_PATH = tArgs[1]
		settings.load(SETTINGS_PATH)
	else
		print("Create new settings file? (y/n)")
		while true do
			local e = {os.pullEvent("key")}
			if e[2] == keys.y then
				SETTINGS_PATH = tArgs[1]
				break
			elseif e[2] == keys.n then
				print("Aborted")
				sleep(1)
				running = false
				break
			end
		end
	end
end

local function drawTitleBar()
	term.setCursorPos(1,1)
	term.setTextColor(colors.white)
	if advMode then
		term.setBackgroundColor(colors.blue)
		term.clearLine()
		term.write("GSet")
		term.setBackgroundColor(colors.red)
		term.setCursorPos(w,1)
		term.write("X")
	else
		term.setBackgroundColor(colors.lightGray)
		term.clearLine()
		term.write("GSet - Press Q to quit")
	end
end

local function drawSettings()
	term.setCursorPos(1,2)
	if advMode then
		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.lightGray)
		term.write("Name")
		term.setTextColor(colors.black)
		term.setCursorPos(1,3)
	else
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.lightGray)
		term.write("Name")
		term.setTextColor(colors.white)
		term.setCursorPos(3,3)
	end
	for i = scrollpos,#SETTINGS do
		if i > #SETTINGS then break end
		local x,y = term.getCursorPos()

		-- determine color
		if advMode then
			if settings.get(SETTINGS[i]) == true then
				term.setTextColor(colors.lime)
			elseif settings.get(SETTINGS[i]) == false then
				term.setTextColor(colors.red)
			else
				term.setTextColor(colors.black)
			end
			term.write(SETTINGS[i])
		else
			if choice == i then
				term.setCursorPos(1,y)
				term.write("> "..SETTINGS[i])
			else
				term.write(SETTINGS[i])
			end
		end

		y = y+1
		if y > h-1 then break end
		if advMode then term.setCursorPos(1,y)
		else term.setCursorPos(3,y) end
	end
end

local function drawButtons()
	if advMode then
		term.setBackgroundColor(colors.lime)
		term.setTextColor(colors.white)
		term.setCursorPos(w-4,3)
		term.write("     ")
		term.setCursorPos(w-4,4)
		term.write("  +  ")
		term.setCursorPos(w-4,5)
		term.write("     ")
		term.setBackgroundColor(colors.red)
		term.setCursorPos(w-4,6)
		term.write("     ")
		term.setCursorPos(w-4,7)
		term.write("  -  ")
		term.setCursorPos(w-4,8)
		term.write("     ")
	else
		term.setBackgroundColor(colors.black)
		term.setCursorPos(w-2,2)
		term.write("+ -")
	end
end

local function newDialog()
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.setCursorPos(1,h)
	term.clearLine()
	write("New: ")
	local new = read()
	table.insert(SETTINGS, new)
	return new
end

local function setDialog(i)
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.setCursorPos(1,h)
	term.clearLine()
	local s = settings.get(SETTINGS[i])
	if s ~= nil then
		s = tostring(s)
		for i = 1,#s do
			os.queueEvent("char", s:sub(i,i))
		end
	end
	local d = read()
	if tonumber(d) ~= nil then
		d = tonumber(d)
	elseif d == "true" then
		d = true
	elseif d == "false" then
		d = false
	end
	settings.set(SETTINGS[i], d)
end

local function alertDialog(s)
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.setCursorPos(1,h)
	term.clearLine()
	write(s)
end

local function resetScroll()
	SETTINGS = settings.getNames()
	scrollpos = 1
	pospossible = #SETTINGS-(h-4)
	table.sort(SETTINGS)
end

local function drawScreen()
	if advMode then
		term.setBackgroundColor(colors.white)
	else
		term.setBackgroundColor(colors.black)
	end
	term.clear()
	drawTitleBar()
	drawSettings()
	drawButtons()
end
drawScreen()

local function evtHandler()
	while running do
		local e = {os.pullEvent()}
		if e[1] == "set_change" then
			settings.save(SETTINGS_PATH)
		end
		if advMode then
			if e[1] == "mouse_scroll" then
				if e[2] == 1 and scrollpos < pospossible then
					scrollpos = scrollpos+1
				elseif e[2] == -1 and scrollpos > 1 then
					scrollpos = scrollpos-1
				end
				drawScreen()
			elseif e[1] == "mouse_click" and e[3] == w and e[4] == 1 then
				running = false
			elseif e[1] == "mouse_click" and e[3] >= w-5 and e[4] >= 3 and e[4] <= 5 then
				newDialog()
				setDialog(#SETTINGS)
				resetScroll()
				os.queueEvent("set_change")
				drawScreen()
			elseif e[1] == "mouse_click" and e[3] >= w-5 and e[4] >= 6 and e[4] <= 8 then
				alertDialog("Click a setting to delete it")
				while true do
					local e = {os.pullEvent("mouse_click")}
					if e[3] <= w-5 and e[4] >= 3 and e[4] <= h-1 then
						local ref = (e[4]-3)+scrollpos
						if SETTINGS[ref] ~= nil then
							settings.unset(SETTINGS[ref])
							table.remove(SETTINGS, ref)
							break
						end
					end
				end
				resetScroll()
				os.queueEvent("set_change")
				drawScreen()
			elseif e[1] == "mouse_click" and e[3] <= w-5 and e[4] >= 3 and e[4] <= h-1 then
				local ref = (e[4]-3)+scrollpos
				if SETTINGS[ref] ~= nil then
					if e[2] == 2 then
						setDialog(ref)
					else
						if type(settings.get(SETTINGS[ref])) == "boolean" then
							if settings.get(SETTINGS[ref]) then
								settings.set(SETTINGS[ref], false)
							else
								settings.set(SETTINGS[ref], true)
							end
						else
							setDialog(ref)
						end
					end
					os.queueEvent("set_change")
					drawScreen()
				end
			elseif e[1] == "char" and e[2] == "q" then
				running = false
			elseif e[1] == "char" and e[2] == "a" or e[2] == "+" then
				newDialog()
				setDialog(#SETTINGS)
				resetScroll()
				os.queueEvent("set_change")
				drawScreen()
			elseif e[1] == "char" and e[2] == "d" or e[2] == "-" then
				alertDialog("Click a setting to delete it")
				while true do
					local e = {os.pullEvent("mouse_click")}
					if e[3] <= w-5 and e[4] >= 3 and e[4] <= h-1 then
						local ref = (e[4]-3)+scrollpos
						if SETTINGS[ref] ~= nil then
							settings.unset(SETTINGS[ref])
							table.remove(SETTINGS, ref)
							break
						end
					elseif e[3] == w and e[4] == 1 then
						running = false
						break
					end
				end
				resetScroll()
				os.queueEvent("set_change")
				drawScreen()
			end
		else
			if e[1] == "char" and e[2] == "q" then
				running = false
			elseif e[1] == "char" and e[2] == "+" or e[2] == "a" then
				newDialog()
				setDialog(#SETTINGS)
				resetScroll()
				os.queueEvent("set_change")
				drawScreen()
			elseif e[1] == "char" and e[2] == "-" or e[2] == "d" then
				settings.unset(SETTINGS[choice])
				table.remove(SETTINGS,choice)
				resetScroll()
				os.queueEvent("set_change")
				drawScreen()
			elseif e[1] == "key" then
				if e[2] == keys.w or e[2] == keys.up then
					if choice > 1 then
						choice = choice-1
						if scrollpos > 1 then
							scrollpos = scrollpos-1
						end
						drawScreen()
					end
				elseif e[2] == keys.s or e[2] == keys.down then
					if choice < #SETTINGS then
						choice = choice+1
						if scrollpos < pospossible then
							scrollpos = scrollpos+1
						end
						drawScreen()
					end
				elseif e[2] == keys.enter then
					setDialog(choice)
					os.queueEvent("set_change")
					drawScreen()
				end
			end
		end
	end
end
evtHandler()
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
print("Thank you for using GSet\nby LegoStax")
coroutine.yield()
