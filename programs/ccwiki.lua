-- CCWiki Database Browser
local running = true
local PCODE = "zzqM8062"
local BUFFER = {}
local PDATA = { -- this is the default database, more data will be added to the Pastebin as needed. Nothing more will be added here.
	[1] = {
		n = "computer",
		d = "Computer^^Recipe:^S = stone, R = redstone, G = glass pane^=======^|S|S|S|^=======^|S|R|S|^=======^|S|G|S|^=======",
	},
	[2] = {
		n = "advanced computer",
		d = "Advanced Computer^^Recipe:^G = gold ingot, R = redstone, P = glass pane^=======^|G|G|G|^=======^|G|R|G|^=======^|G|P|G|^=======",
	},
	[3] = {
		n = "wired modem",
		d = "Wired Modem^^Recipe:^S = stone, R = redstone^=======^|S|S|S|^=======^|S|R|S|^=======^|S|S|S|^=======",
	},
	[4] = {
		n = "networking cable",
		d = "Networking Cable^^Recipe:^S = stone, R = redstone^=======^| |S| |^=======^|S|R|S|^=======^| |S| |^=======",
	},
	[5] = {
		n = "wireless modem",
		d = "Wireless Modem^^Recipe:^S = stone, E = ender pearl^=======^|S|S|S|^=======^|S|E|S|^=======^|S|S|S|^=======",
	},
	[6] = {
		n = "disk drive",
		d = "Disk Drive^^Recipe:^S = stone, R = redstone^=======^|S|S|S|^=======^|S|R|S|^=======^|S|R|S|^=======",
	},
	[7] = {
		n = "floppy disk",
		d = "Floppy Disk^^Recipe:^R = redstone, P = paper^=======^| |R| |^=======^| |P| |^=======^| | | |^=======",
	},
	[8] = {
		n = "turtle",
		d = "Turtle^^Recipe:^I = iron ingot, C = computer, H = chest^=======^|I|I|I|^=======^|I|C|I|^=======^|I|H|I|^=======",
	},
	[9] = {
		n = "monitor",
		d = "Monitor^^Recipe:^S = stone, G = glass pane^=======^|S|S|S|^=======^|S|G|S|^=======^|S|S|S|^=======",
	},
	[10] = {
		n = "printer",
		d = "Printer^^Recipe:^S = stone, R = redstone, I = ink sac^=======^|S|S|S|^=======^|S|R|S|^=======^|S|I|S|^=======",
	},
	[11] = {
		n = "advanced monitor",
		d = "Advanced Monitor^^Recipe:^G = gold ingot, P = glass pane^=======^|G|G|G|^=======^|G|P|G|^=======^|G|G|G|^=======",
	},
	[12] = {
		n = "advanced turtle",
		d = "Advanced Turtle^^Recipe:^G = gold ingot, A = advanced computer, C = chest^=======^|G|G|G|^=======^|G|A|G|^=======^|G|C|G|^=======",
	},
	[13] = {
		n = "pocket computer",
		d = "Pocket Computer^^Recipe:^S = stone, G = golden apple, P = glass pane^=======^|S|S|S|^=======^|S|G|S|^=======^|S|P|S|^=======",
	},
	[14] = {
		n = "advanced pocket computer",
		d = "Advanced Pocket Computer^^Recipe:^I = gold ingot, G = golden apple, P = glass pane^=======^|I|I|I|^=======^|I|G|I|^=======^|I|P|I|^=======",
	},
	[15] = {
		n = "wireless pocket computer",
		d = "Wireless Pocket Computer^^Recipe:^W = wireless modem, P = pocket computer^=======^| | | |^=======^| |W| |^=======^| |P| |^=======",
	},
	[16] = {
		n = "golden apple",
		d = "Golden Apple^^Recipe:^G = block of gold, A = apple^=======^|G|G|G|^=======^|G|A|G|^=======^|G|G|G|^=======^^",
	},
}
local w,h = term.getSize()
local choice = 1
local searchmode = false
local curresults = ""
local input = ""
local xread = 2
local scrollpos = 1
local pospossible = 1

if not term.isColor() or not term.isColour() then
	running = false
	print("Colorful display required")
end

local function printPos(msg,x,y,bg,fg)
	if bg then term.setBackgroundColor(bg) end
	if fg then term.setTextColor(fg) end
	term.setCursorPos(x,y)
	term.write(msg)
end

function download(url,fn)
	if not http then
		os.queueEvent("ccwiki_error","HTTP API disabled. Please re-enable it")
	else
		local response = http.get(url)
		if response then
			local data = response.readAll()
			response.close()
			local f = fs.open(fn, "w")
			f.write(data)
			f.close()
		else
			os.queueEvent("ccwiki_error","No response from Pastebin servers.")
		end
	end
end

local function clearViewport(c)
	term.setBackgroundColor(c)
	for y = 2,h-1 do
		term.setCursorPos(1,y)
		term.clearLine()
	end
end

local function calcScroll()
	scrollpos = 1
	pospossible = #BUFFER-(h-3)
	if pospossible < 1 then pospossible = 1 end
end

local function drawHeader()
	printPos(" CC Wiki",1,1,colors.gray,colors.white)
	for x = 9,w-1 do printPos(" ",x,1) end
	printPos("X",w,1,colors.red,colors.white)
end

local function drawFooter()
	printPos(" Search",1,h,colors.gray,colors.lightGray)
	for x = 8,w do printPos(" ",x,h) end
end

local function drawFocus()
	clearViewport(colors.white)
	if xread > 2 then
		-- Draw selected choice bar
		term.setBackgroundColor(colors.lightGray)
		term.setCursorPos(1,choice+1)
		term.clearLine()
	end
	term.setTextColor(colors.black)
	term.setCursorPos(1,2)
	for i = scrollpos,#BUFFER do
		if i > #BUFFER then break end
		term.write(BUFFER[i])
		local x,y = term.getCursorPos()
		if y+1 > h-1 then break end
		term.setCursorPos(1,y+1)
	end
end

local function drawScreen()
	term.setBackgroundColor(colors.white)
	term.clear()
	drawHeader()
	drawFooter()
	drawFocus()
end

local function writeBuffer(data)
	BUFFER = {}
	local add = ""
	for i = 1,data:len() do
		if string.sub(data,i,i) == "^" then
			table.insert(BUFFER,add)
			add = ""
		else
			add = add .. string.sub(data,i,i)
		end
		if add:len() == w or i == data:len() then
			table.insert(BUFFER,add)
			add = ""
		end
	end
	calcScroll()
	drawFocus()
end

local function writeError(e)
	printPos(e,2,3,colors.white,colors.red)
end

local function searchDatabase(data)
	local list = ""
	for i = 1,#PDATA do
		if data == string.sub(PDATA[i].n, 1, data:len()) then
			list = list .. PDATA[i].n .. "^"
		end
	end
	return list
end

local function displayResult(keyword)
	for i = 1,#PDATA do
		if PDATA[i].n == keyword then
			writeBuffer(PDATA[i].d)
		end
	end
end

local function indexDatabase()
	local b = ""
	for i = 1,#PDATA do
		b = b .. PDATA[i].n .. "^"
	end
	writeBuffer(b)
	while true do
		local e = {os.pullEvent()}
		if e[1] == "mouse_click" and e[2] == 1 then
			if e[3] == 51 and e[4] == 1 then
				running = false
				break
			elseif e[4] == 1 then
				writeBuffer("^ Start typing to search^^ Click the title bar to view the index")
				break
			else
				displayResult(BUFFER[e[4]-1])
				break
			end
		end
	end
end

-- Initialize
if fs.exists(".ccwiki/latest") then -- overwrite backup
	local f = fs.open(".ccwiki/latest", "r")
	local d = f.readAll()
	f.close()
	local f = fs.open(".ccwiki/backup", "w")
	f.write(d)
	f.close()
end
download("http://pastebin.com/raw.php?i="..PCODE, ".ccwiki/latest") -- download database file
local f = fs.open(".ccwiki/latest", "r")
PDATA = textutils.unserialize(f.readAll()) -- load database file
f.close()

local function main()
	writeBuffer("^ Start typing to search^^ Click the title bar to view the index")
	drawScreen()
	while running do
		local e = {os.pullEvent()}
		if e[1] == "mouse_click" and e[2] == 1 then
			if e[3] == w and e[4] == 1 then
				running = false
				break
			elseif e[4] == 1 then
				indexDatabase()
			end
		elseif e[1] == "mouse_scroll" then
			if e[2] == 1 and scrollpos < pospossible then
				scrollpos = scrollpos+1
				drawFocus()
			elseif e[2] == -1 and scrollpos > 1 then
				scrollpos = scrollpos-1
				drawFocus()
			end
		elseif e[1] == "ccwiki_error" then
			writeError(e[2])
		elseif e[1] == "char" then
			if input == "" then
				term.setBackgroundColor(colors.gray)
				term.setCursorPos(1,h)
				term.clearLine()
			end
			input = input .. e[2]
			printPos(e[2],xread,h,colors.gray,colors.lightGray)
			xread = xread+1
			-- search with current input and display results
			curresults = searchDatabase(input)
			writeBuffer(curresults)
		elseif e[1] == "key" then
			if e[2] == keys.enter then
				-- select current option
				input = ""
				xread = 2
				drawFooter()
				-- display searched wiki article
				displayResult(BUFFER[choice])
				choice = 1
			elseif e[2] == keys.backspace and xread > 2 then
				curresults = searchDatabase(input)
				writeBuffer(curresults)
				input = string.sub(input,1,input:len()-1)
				xread = xread-1
				term.setBackgroundColor(colors.gray)
				term.setCursorPos(xread,h)
				term.write("  ")
				term.setCursorPos(xread,h)
				if xread == 2 then
					choice = 1
					writeBuffer("^ Start typing to search^^ Click the title bar to view the index")
					drawFooter()
				end
			elseif e[2] == keys.up and choice > 1 then
				choice = choice-1
				writeBuffer(curresults)
			elseif e[2] == keys.down and choice < #BUFFER-1 then
				choice = choice+1
				writeBuffer(curresults)
			end
		elseif e[1] == "term_resize" then
			drawScreen()
		end
	end
end
main()
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
coroutine.yield()
