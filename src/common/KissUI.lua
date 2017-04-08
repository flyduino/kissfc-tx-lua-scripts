
local currentPage = 1
local currentLine = 1
local saveTS = 0
local saveTimeout = 0
local saveRetries = 0
local saveMaxRetries = 0

local function saveSettings(new)
local page = SetupPages[currentPage]
if page.values then
	if page.getWriteValues then
		kissSendRequest(page.write,page.getWriteValues(page.values))
	else
		kissSendRequest(page.write,page.values)
	end
	saveTS = getTime()
	if gState == PAGE_SAVING then
		saveRetries = saveRetries + 1
	else
		gState = PAGE_SAVING
		saveRetries = 0
		saveMaxRetries = page.saveMaxRetries or 3 -- default 2
		saveTimeout = page.saveTimeout or 600 -- default 4s (400)
	end
end
end

local function incPage(inc)
currentPage = currentPage + inc
if currentPage > #(SetupPages) then
	currentPage = 1
elseif currentPage < 1 then
	currentPage = #(SetupPages)
end
currentLine = 1
end

--write DataType Settings to specified line in file
local function saveValues( mN , payload, newName)
	local SP = SetupPages[PREV_PAGE]
	local dLen = SP.dL
	local f = io.open("/SCRIPTS/"..SP.title, "r")
	if newName == nil then
		n = SP.wrName[mN]
	else
		n = newName
	end
		if mN == 1 then
			s = n
		else
			s = io.read(f,(dLen+nL)*(mN-1))..n
		end
		for j=1,#(payload) do
			s = s..string.format("%4d", payload[j])
		end
		io.seek(f,mN*(dLen+nL))
		s = s..io.read(f,(dLen+nL)*(5-mN))
		io.close(f)
		f = io.open("/SCRIPTS/"..SP.title, "w")
		io.write(f,s)
		io.close(f)

end

--set state and open DataType select Page to save
local function openSaveMenu()
gState = MODEL_WRITE
	local page = SetupPages[currentPage]
	if page.values then
		if page.getWriteValues then
			payload = page.getWriteValues(page.values)
			currentPage = #(SetupPages)
		end
	end
end

local function readModel(modelNum)
SP = SetupPages[PREV_PAGE]
local val = SP.data[modelNum]
SP.values = SP.postRead(page,val)
end

--set state and open DataType select Page to load
local function openLoadMenu()
gState = MODEL_LOAD
currentPage = #(SetupPages) -- goto LoadList
currentLine = 1 -- set Line 1
end

local function openEditMenu()
gState = MODEL_EDIT
currentPage = #(SetupPages) -- goto LoadList
currentLine = 1 -- set Line 1

end

local function invalidatePages()
   for i=1,#(SetupPages) do
      local page = SetupPages[i]
      page.values = nil
   end
   gState = PAGE_DISPLAY
   saveTS = 0
end

local menuList = {

   { t = "Send to FC",
     f = saveSettings },
   { t = "Restore from FC",
     f = invalidatePages },
	 { t = "Edit Files",
     f = openEditMenu },
	{ t = "Save to File",
     f = openSaveMenu },
	 { t = "Load from File",
     f = openLoadMenu }
}

local editList = {"","","","","","SAVE","LOAD","EDIT NAME","EDIT NAME"}

local telemetryScreenActive = false
local menuActive = false

local function processKissReply(cmd,rx_buf)

   if cmd == nil or rx_buf == nil then
      return
   end

   local page = SetupPages[currentPage]

   -- response on saving
   if cmd == page.write then
      gState = PAGE_DISPLAY
      page.values = nil
      saveTS = 0
      return
   end
   
   if cmd ~= page.read then
      return
   end

   if #(rx_buf) > 0 then
      page.values = {}
      for i=1,#(rx_buf) do
         page.values[i] = rx_buf[i]
      end

      if page.postRead ~= nil then
         page.postRead(page)
      end
   end
end
   
local function MaxLines()
   return #(SetupPages[currentPage].fields)
end

local function incLine(inc)
   currentLine = currentLine + inc
   if currentLine > MaxLines() then
      currentLine = 1
   elseif currentLine < 1 then
      currentLine = MaxLines()
   end
end

local function incMenu(inc)
 menuActive = menuActive + inc
   if menuActive > #(menuList) then
      menuActive = 1
   elseif menuActive < 1 then
      menuActive = #(menuList)
   end
end
local function requestPage(page)
   if page.read and ((page.reqTS == nil) or (page.reqTS + REQ_TIMEOUT <= getTime())) then
      page.reqTS = getTime()
      kissSendRequest(page.read,{})
   end
end

local function drawScreen(page,page_locked,page_from)
local screen_title = page.title
--normal pages 1 to 5
if currentPage < #(SetupPages) then 
	screen_title = 'Kiss Setup:  '..screen_title
	drawScreenTitle(screen_title,currentPage,#(SetupPages)-1)   ---new function
--skip page 6
elseif gState < 6 then
	currentPage = PREV_PAGE
	drawScreen(page,page_locked,PREV_PAGE)
	PREV_PAGE = 1
--Memory Data Screen Active
else
	screen_title = editList[gState]
	drawScreenTitle(screen_title.." "..SetupPages[page_from].title,0,0)  ----new fucntion
end
for i=1,#(page.text) do
	local f = page.text[i]
	lcd.drawText(f.x, f.y, f.t, text_options) 
end
if page.lines ~= nil then
	for i=1,#(page.lines) do
		local f = page.lines[i]
		lcd.drawLine (f.x1, f.y1, f.x2, f.y2, SOLID, FORCE)
	end
end
local SP = SetupPages[PREV_PAGE]

for i=1,#(page.fields) do
	local f = page.fields[i]
	local text_options = 0
	if i == currentLine then
		text_options = INVERS
		if gState == EDITING then
			text_options = text_options + BLINK
		end
	end
	if f.t ~= nil then
		if currentPage == #(SetupPages) and gState >= 6 then
			lcd.drawText(f.x, f.y, SP.wrName[i] , text_options)
		else
			lcd.drawText(f.x, f.y, f.t , 0)
		end
	end
	-- draw some value
	local spacing = 20
	if f.sp ~= nil then
		spacing = f.sp
	end
    local idx = f.i or i
	if page.values and page.values[idx]  then
		local val = page.values[idx]
		if f.table and f.table[page.values[idx]] then
			val = f.table[page.values[idx]]
		end
		if f.prec ~= nil then
			val = formatKissFloat(val, f.prec, f.base)
        end
        lcd.drawText(f.x + spacing, f.y, val, text_options)
		--lcd.drawText(5,5,"x"..page.wrName[1])
    else
		if currentPage ~= #(SetupPages) then
			lcd.drawText(f.x + spacing, f.y, "---", text_options)
		end
      end
   end

end

local function clipValue(val,min,max)
	if val < min then
		val = min
	elseif val > max then
		val = max
	end
return val
end

local fieldMax = 11
local activeField = 0

local function incValue(inc)
local page = SetupPages[currentPage]
local field = page.fields[currentLine]
local idx = field.i or currentLine
local tmpInc = inc
if field.prec ~= nil then
	tmpInc = tmpInc * 10^(3-field.prec)
end
if field.inc ~= nil then
	tmpInc = tmpInc * field.inc
end
page.values[idx] = clipValue(page.values[idx] + tmpInc, field.min or 0, field.max or 255)
end

local function fieldIncDec(event,value,max,force)
	if editMode or force==true then
		if event==EVT_PLUS_FIRST then
			value=value+max
		elseif event==EVT_MINUS_FIRST then
			value=value+max+2
		end
	value=value%(max+1)
    end
return value
end
  
local function valueIncDec(event,value,min,max,step)
	if editMode then
		if event==EVT_PLUS_FIRST or event==EVT_PLUS_REPT then
			if value<=max-step then
				value=value+step
			else 
				value = min
			end
	elseif event==EVT_MINUS_FIRST or event==EVT_MINUS_REPT then
		if value>=min+step then
			value=value-step
		else
			value = max
        end
	end
end
return value
end
  
  local function getFieldFlags(p)
local flg = 0
if activeField==p then
	flg=INVERS
	if editMode then
		flg=INVERS+BLINK
	end
end
return flg
end

local EVT_MENU_LONG = bit32.bor(bit32.band(EVT_MENU_BREAK,0x1f),0x80)
local lastRunTS = 0

local function run(event)
local now = getTime()
local page = SetupPages[currentPage]
local page_locked = false
local v = {}
local pidNum
-- if lastRunTS old than 500ms
if lastRunTS + 50 < now then
	invalidatePages()
end
lastRunTS = now
if (gState == PAGE_SAVING) and (saveTS + saveTimeout < now) then
	if saveRetries < saveMaxRetries then
		saveSettings()
	else
	-- max retries reached
		gState = PAGE_DISPLAY
		invalidatePages()
	end
end
if #(kissTxBuf) > 0 then
	kissProcessTxQ()
end
-- navigation

  if event == EVT_MENU_LONG and currentPage < #(SetupPages) then
    menuActive = 1
    gState = MENU_DISP
	PREV_PAGE = currentPage  
	
-- menu1 is currently displayed
elseif gState == MENU_DISP then
	if event == EVT_EXIT_BREAK then
		gState = PAGE_DISPLAY
	elseif event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
		incMenu(-1)
	elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
		incMenu(1)
	elseif event == EVT_ENTER_BREAK then
		if menuActive ==3 then
			gState = MENU_NAME
		else
			gState = PAGE_DISPLAY
		end
		if menuActive >= 3 then getMemData(PREV_PAGE) end
		menuList[menuActive].f()
	end
--menu2 - pid model name change screen is displayed
elseif gState == MENU_NAME then
	if event == EVT_ENTER_BREAK then
		editMode = not editMode
	elseif  event == EVT_EXIT_BREAK then
		gState = MODEL_EDIT
	end
	if editMode then
		if activeField <= 9 then
			CPvN[activeField+1] = string.char(valueIncDec(event, string.byte(CPvN[activeField+1]), 34, 127, 1))
		elseif activeField == 10 then
			activeField = 0
			saveValues(modelNum, CP.data[modelNum], tableToString(CPvN))
			getMemData(PREV_PAGE)
			gState = PAGE_DISPLAY
			editMode = not editMode
		elseif activeField == 11 then
			activeField = 0
			modelNum = currentLine
			editMode = not editMode
			currentPage = PREV_PAGE
			readModel ( modelNum )
			gState = PAGE_DISPLAY
		end
	else
		activeField = fieldIncDec(event, activeField, fieldMax, true)
	end
-- normal page viewing
elseif gState <= PAGE_DISPLAY then
	if event == EVT_MENU_BREAK then
		incPage(1)
	elseif event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
		incLine(-1)
	elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
		incLine(1)
	elseif event == EVT_ENTER_BREAK then
		local page = SetupPages[currentPage]
		local field = page.fields[currentLine]
		local idx = field.i or currentLine
		if page.values and page.values[idx] and (field.ro ~= true) then
			gState = EDITING
		end
	end
-- editing value
elseif gState == EDITING then
	if (event == EVT_EXIT_BREAK) or (event == EVT_ENTER_BREAK) then
		gState = PAGE_DISPLAY
	elseif event == EVT_PLUS_FIRST or event == EVT_PLUS_REPT or event == EVT_ROT_RIGHT then
		incValue(1)
	elseif event == EVT_MINUS_FIRST or event == EVT_MINUS_REPT or event == EVT_ROT_LEFT then
		incValue(-1)
	end
--READ/WRITE values to assigned Page and Line(Model)Number (ie: PIDS, Rates etc)
elseif gState >= 6 and gState < 9 then
	if event == EVT_ENTER_BREAK then
		modelNum = currentLine
		CP = SetupPages[PREV_PAGE]
		for i = 1,#(CP.wrName[currentLine]) do
			CPvN[i] = string.sub(CP.wrName[currentLine],i,i)
		end
		if gState == MODEL_WRITE then
			saveValues(modelNum, payload)
			gState = PAGE_DISPLAY
			currentLine=1
		elseif gState == MODEL_LOAD then
			readModel(modelNum)
			gState = PAGE_DISPLAY
			currentLine=1
		elseif gState == MODEL_EDIT then
			gState = MENU_NAME
		end
	elseif event == EVT_PLUS_FIRST or event == EVT_PLUS_REPT or event == EVT_ROT_RIGHT then
		incLine(-1)
	elseif event == EVT_MINUS_FIRST or event == EVT_MINUS_REPT or event == EVT_ROT_LEFT then
		incLine(1)
	elseif event == EVT_EXIT_BREAK  then
		gState = PAGE_DISPLAY
	end
end
if not page.values then
	-- request values
	requestPage(page)
	page_locked = true
end
-- draw screen
lcd.clear()
drawScreen(page,page_locked,PREV_PAGE)
-- do we have valid telemetry data?
if getValue("RSSI") == 0 then
	-- No!
	drawTelemetry  -----new function
	invalidatePages()
end
if gState == MENU_DISP then
	drawMenu()
elseif gState == MENU_NAME then
	
	drawEditMenu()
elseif gState == PAGE_SAVING then  -----new function
	drawSaving
end
processKissReply(kissPollReply())
return 0
end

return {run=run, init=init}

