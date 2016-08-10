-- Rednet Snooper
local tArgs = {...}
local RUNNING = true
local w,h = term.getSize()
local scrollpos = 1
local data = {}
local blink = true
local minchan, maxchan = nil
if not term.isColor() or not term.isColour() then
	RUNNING = false
	print("Get an advanced computer. It likely will not be this way in the future.")
end
if #tArgs < 2 then
	print(fs.getName(shell.getRunningProgram()).." <minchan> <maxchan>")
	RUNNING = false
else
	minchan = tonumber(tArgs[1])
	maxchan = tonumber(tArgs[2])
	if maxchan - minchan > 127 then
		print("Only 128 channels can be open at once")
		RUNNING = false
	end
end
local m = nil
local pospossible = 1
local input = ""
local function drawTopBar()
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(1,1)
	term.clearLine()
	term.write(" Rednet Snooper "..minchan.."-"..maxchan)
	term.setCursorPos(w-4,1)
	term.write(" ? ")
	term.setBackgroundColor(colors.red)
	term.setCursorPos(w,1)
	term.write("X")
end
local function drawBottomBar()
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(1,h)
	term.clearLine()
	term.write("> ")
end
local function drawListen()
	term.setBackgroundColor(colors.black)
	for y = 2,h-1 do
		term.setCursorPos(1,y)
		term.clearLine()
	end
	term.setCursorPos(1,2)
	for i = scrollpos,#data do
		if i > #data then break end
		term.write(data[i])
		local x,y = term.getCursorPos()
		y = y+1
		if y > h-1 then break end
		term.setCursorPos(1,y)
	end
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(3,h)
end
local function drawScreen()
	term.clear()
	drawTopBar()
	drawBottomBar()
	drawListen()
end
local function scanPeripherals()
	local sides = {"top", "bottom", "left", "right", "front", "back"}
	for i = 1,#sides do
		if peripheral.isPresent(sides[i]) then
			if peripheral.getType(sides[i]) == "modem" then
				m = peripheral.wrap(sides[i])
				m.closeAll()
			end
		end
	end
	if m == nil then
		print("Please attach a modem")
		RUNNING = false
	end
end
local function openRange()
	if RUNNING then
		for i = minchan,maxchan do
			if not m.isOpen(i) then m.open(i) end
		end
	end
end
local function processInput()
	local chan = nil
	local msg = nil
	for i = 1,input:len() do
		if string.sub(input,i,i) == " " then
			chan = tonumber(string.sub(input,1,i-1))
			msg = string.sub(input,i+1)
			break
		end
	end
	if chan then
	    local nMessageID = math.random( 1, 2147483647 ) -- transmit with rednet protocol
		local tMessage = {
			nMessageID = nMessageID,
			nRecipient = chan,
			message = msg,
			sProtocol = nil,
		}
		local temp = nil
		if not m.isOpen(chan) then
			m.close(maxchan)
			m.open(chan)
			m.transmit(chan,maxchan,msg)
			m.transmit(chan,maxchan,tMessage)
			temp = "C"..chan.."/"..maxchan.." D:0: "
		else
			m.transmit(chan,chan,msg)
			m.transmit(chan,chan,tMessage)
			temp = "C"..chan.."/"..chan.." D:0: "
		end
		-- insert sent message to data table
		if msg:len() + temp:len() > w then
			table.insert(data, temp .. string.sub(msg,1,w - temp:len()))
			for i = w-temp:len()+1,msg:len(),w do
				table.insert(data, string.sub(msg,i,i+w))
			end
		else
			table.insert(data, temp .. msg)
		end
		pospossible = #data-(h-3)
		if pospossible < 1 then pospossible = 1 end
		scrollpos = pospossible
		drawListen()
		if not m.isOpen(maxchan) then
			m.close(chan)
			m.open(maxchan)
		end
	end
end
local function helpMenu()
	term.setBackgroundColor(colors.lightGray)
	term.setCursorPos(w-4,1)
	term.write(" ? ")
	term.setBackgroundColor(colors.black)
	for y = 2,h-1 do
		for x = 1,w do
			term.setCursorPos(x,y)
			term.write(" ")
		end
	end
	term.setCursorPos(1,3)
	print("Help Menu:")
	print()
	print("Message data:")
	print("C<channel>/<replychannel> D:<distance>: ")
	print()
	print("To send a message:")
	print("<channel> <message>")
	print("and press enter")
	while true do
		local e = {os.pullEvent()}
		if e[1] == "mouse_click" and e[2] == 1 and e[3] == w and e[4] == 1 then
			RUNNING = false
			break
		elseif e[1] == "mouse_click" and e[2] == 1 and e[3] >= w-4 and e[3] <= w-2 and e[4] == 1 then
			break
		elseif e[1] == "modem_message" then -- Receiving messages
			local temp = "C"..e[3].."/"..e[4].." D:"..e[6]..": "
			if type(e[5]) == "table" then
				if e[5].message:len() + temp:len() > w then -- text wrapping
					table.insert(data, temp .. string.sub(e[5].message,1,w - temp:len()))
					for i = w-temp:len()+1,e[5].message:len(),w do
						table.insert(data, string.sub(e[5].message,i,i+w))
					end
				else
					table.insert(data, temp .. e[5].message)
				end
			else
				if e[5]:len() + temp:len() > w then -- text wrapping
					table.insert(data, temp .. string.sub(e[5],1,w - temp:len()))
					for i = w-temp:len()+1,e[5]:len(),w do
						table.insert(data, string.sub(e[5],i,i+w))
					end
				else
					table.insert(data, temp .. e[5])
				end
			end
			pospossible = #data-(h-3)
			if pospossible < 1 then pospossible = 1 end
			scrollpos = pospossible
		end
	end
end
local function evtListen()
	openRange()
	drawScreen()
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(3,h)
	local xread = 3
	local cursor = os.startTimer(0.3)
	while RUNNING do
		local e = {os.pullEvent()}
		if e[1] == "modem_message" then -- Receiving messages
			local temp = "C"..e[3].."/"..e[4].." D:"..e[6]..": "
			if type(e[5]) == "table" then
				if e[5].message:len() + temp:len() > w then -- text wrapping
					table.insert(data, temp .. string.sub(e[5].message,1,w - temp:len()))
					for i = w-temp:len()+1,e[5].message:len(),w do
						table.insert(data, string.sub(e[5].message,i,i+w))
					end
				else
					table.insert(data, temp .. e[5].message)
				end
			else
				if e[5]:len() + temp:len() > w then -- text wrapping
					table.insert(data, temp .. string.sub(e[5],1,w - temp:len()))
					for i = w-temp:len()+1,e[5]:len(),w do
						table.insert(data, string.sub(e[5],i,i+w))
					end
				else
					table.insert(data, temp .. e[5])
				end
			end
			pospossible = #data-(h-3)
			if pospossible < 1 then pospossible = 1 end
			scrollpos = pospossible
			drawListen()
		elseif e[1] == "mouse_scroll" then -- Mouse Input
			if e[2] == 1 and scrollpos < pospossible then
				scrollpos = scrollpos+1
				drawListen()
			elseif e[2] == -1 and scrollpos > 1 then
				scrollpos = scrollpos-1
				drawListen()
			end
		elseif e[1] == "mouse_click" and e[2] == 1 and e[3] == w and e[4] == 1 then
			RUNNING = false
		elseif e[1] == "mouse_click" and e[2] == 1 and e[3] >= w-4 and e[3] <= w-2 and e[4] == 1 then
			helpMenu()
			drawScreen()
			cursor = os.startTimer(0.3)
		elseif e[1] == "key" then -- custom read() function
			if e[2] == keys.enter then
				processInput()
				input = ""
				xread = 3
				drawBottomBar()
			elseif e[2] == keys.backspace and input ~= "" then
				input = string.sub(input,1,input:len()-1)
				xread = xread-1
				term.setBackgroundColor(colors.gray)
				term.setCursorPos(xread,h)
				term.write("  ")
				term.setCursorPos(xread,h)
			end
		elseif e[1] == "char" then
			input = input .. e[2]
			term.setBackgroundColor(colors.gray)
			term.setCursorPos(xread,h)
			term.write(e[2])
			xread = xread+1
		elseif e[1] == "timer" and e[2] == cursor then
			if blink then term.setBackgroundColor(colors.lightGray)
			else term.setBackgroundColor(colors.gray) end
			term.setCursorPos(xread,h)
			term.write(" ")
			blink = not blink
			cursor = os.startTimer(0.3)
		end
	end
end
scanPeripherals()
if RUNNING then
	parallel.waitForAll(evtListen, userInput)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	m.closeAll()
end
