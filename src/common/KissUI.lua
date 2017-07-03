-- BEGIN UI

local currentPage = 1
local currentLine = 1
local saveTS = 0
local saveTimeout = 0
local saveRetries = 0
local saveMaxRetries = 0

local REQ_TIMEOUT = 200 -- 1000ms request timeout

--local PAGE_REFRESH = 1
local PAGE_DISPLAY = 2
local EDITING      = 3
local PAGE_SAVING  = 4
local MENU_DISP    = 5
local MODEL_WRITE  = 6
local MODEL_LOAD   = 7
local MODEL_EDIT   = 8
local MENU_NAME    = 9

local telemetryScreenActive = false
local menuActive = false
local lastRunTS = 0

local gState = PAGE_DISPLAY
ActivePage = nil

AllPages = { "pids", "rates", "tpa", "filters", "alarms", "vtx", "memory" }

local function formatKissFloat(v, d)
	local s = string.format("%0.4d", v);
	local part1 = string.sub(s, 1, string.len(s)-3)
	local part2 = string.sub(string.sub(s,-3), 1, d)
	if d>0 then 
		return part1.."."..part2
	else
		return part1
	end
end

local function clearTable(t)
	if type(t)=="table" then
  		for i,v in pairs(t) do
    		if type(v) == "table" then
      			clearTable(v)
    		end
    		t[i] = nil
  		end
	end
	collectgarbage()
	return t
end

local function saveSettings(new)
   if ActivePage.values then
      if ActivePage.preWrite then
         kissSendRequest(ActivePage.write, ActivePage.preWrite(ActivePage.values))
      else
         kissSendRequest(ActivePage.write, ActivePage.values)
      end
      saveTS = getTime()
      if gState == PAGE_SAVING then
         saveRetries = saveRetries + 1
      else
         gState = PAGE_SAVING
         saveRetries = 0
         saveMaxRetries = ActivePage.saveMaxRetries or 2 -- default 2
         saveTimeout = ActivePage.saveTimeout or 400     -- default 4s
      end
   end
end

local function invalidatePage()
	ActivePage.values = nil
	gState = PAGE_DISPLAY
	saveTS = 0
end

local function loadPage(pageId) 
	local file = "/SCRIPTS/TELEMETRY/KISS/"..AllPages[pageId]..".lua"
	AP = ActivePage
	clearTable(ActivePage)
	local tmp = assert(loadScript(file))
    ActivePage = tmp()
end

--set state and open DataType select Page to save
local function openSaveMenu()
gState = MODEL_WRITE
	local page = ActivePage --AllPages[currentPage]
	if page.values then
		--if page.getWriteValues then
			payload = page.Values
			currentPage = #(AllPages)
			currentLine = 1
			loadPage(currentPage)
		--end
	end
end

local function readModel(modelNum)
loadPage(PREV_PAGE)
local val = CP.data[modelNum]
ActivePage.values = val
end

--set state and open DataType select Page to load
local function openLoadMenu()
gState = MODEL_LOAD
currentPage = #(AllPages) -- goto LoadList
currentLine = 1 -- set Line 1
loadPage(currentPage)
end

local function openEditMenu()
gState = MODEL_EDIT
currentPage = #(AllPages) -- goto LoadList
currentLine = 1 -- set Line 1
loadPage(currentPage)
end

local function tableToString(v)
local vStr
vStr = v[1]
for i = 2,#(v) do
	vStr = vStr..v[i]
end
return vStr
end

local function getMemData(fileNum)

local file = "/SCRIPTS/TELEMETRY/KISS/"..AllPages[fileNum]..".lua"
	clearTable(CP)
	local tmp = assert(loadScript(file))
    CP = tmp()
	
local dLen = CP.dL
local f = io.open("/SCRIPTS/TELEMETRY/KISS/"..CP.title, "r")
io.seek(f,0)

for i = 1,5 do
io.seek(f,(i-1)*(nL+dLen))
CP.wrName[i] = io.read(f,nL)
var = {}
	for j = 1,dLen/5 do
		io.seek(f,nL+(i-1)*(nL+dLen)+(j-1)*5)
		var[j] = tonumber(io.read(f,5))
	end
	CP.data[i] = var
end
io.close(f)
end

local menuList = {
{ t = "Send to FC", f = saveSettings }, { t = "Restore from FC", f = invalidatePage }, { t = "Edit Files", f = openEditMenu }, { t = "Save to File", f = openSaveMenu }, { t = "Load from File", f = openLoadMenu }
}

local function writeToFile(values, fName)
if values  then
local f = io.open("/SCRIPTS/TELEMETRY/KISS/"..fName, "w")
if type(values) == "table" then
 v = string.format("%5d",values[1])
 for i = 2,#(values) do
	v = v..string.format("%5d",values[i])
 end
else
 v = values
end
io.write(f,v)
io.close(f)
end
end

local function savePageValues(values)
if values  then
if type(values) == "table" then
 v = string.format("%5d",values[1])
 for i = 2,#(values) do
	v = v..string.format("%5d",values[i])
 end
else
 v = values
end

return v
end
end

local function saveValues( mN, newName)
	local file = "/SCRIPTS/TELEMETRY/KISS/"..AllPages[PREV_PAGE]..".lua"
	clearTable(SP)
	local tmp = assert(loadScript(file))
    SP = tmp()
	
	local dLen = SP.dL
	local f = io.open("/SCRIPTS/TELEMETRY/KISS/"..SP.title, "r")
	if newName == nil then
		n = CP.wrName[mN]
	else
		n = newName
	end
		if mN == 1 then
			s = n
		else
			s = io.read(f,(dLen+nL)*(mN-1))..n
		end
		s = s..sVal
		io.seek(f,mN*(dLen+nL))
		s = s..io.read(f,(dLen+nL)*(5-mN))
		io.close(f)
		f = io.open("/SCRIPTS/TELEMETRY/KISS/"..SP.title, "w")
		io.write(f,s)
		io.close(f)
end

local function init()
local str
local ret = {}
for i = 1,#(AllPages)-2 do
	loadPage(i)
	local f = io.open("/SCRIPTS/TELEMETRY/KISS/"..ActivePage.title, "r")
	if not f then
		f = io.open("/SCRIPTS/TELEMETRY/KISS/"..ActivePage.title, "a")
		for j = 1,5 do  --number of available saved values sets
			io.write(f,ActivePage.defValues)
		end
		io.close(f)
	else
		io.close(f)
	end
end	
loadPage(1)
end

local function processKissReply(cmd, rx_buf)

   if cmd == nil or rx_buf == nil then
      return
   end
   
   -- response on saving
   if cmd == ActivePage.write then
      gState = PAGE_DISPLAY
      ActivePage.values = nil
      saveTS = 0
      return
   end
   
   if cmd ~= ActivePage.read then
      return
   end

   if #(rx_buf) > 0 then
      ActivePage.values = {}
      for i=1,#(rx_buf) do
         ActivePage.values[i] = rx_buf[i]
      end

      if ActivePage.postRead ~= nil then
         ActivePage.values = ActivePage.postRead(ActivePage.values)
      end
   end
end
   
local function MaxLines()
   return #(ActivePage.fields)
end

local function changeWithLimit(value, direction, min, max) 
	local tmp = value + direction
	if tmp > max and direction>0 then
		tmp = min
	elseif tmp < 1 and direction<0 then
		tmp = max
	end
	return tmp
end

local function incPage(inc)
   currentPage = changeWithLimit(currentPage, inc, 1, #(AllPages)-1)
   loadPage(currentPage)
end

local function incLine(inc)
   currentLine = changeWithLimit(currentLine, inc, 1, MaxLines())
end

local function incMenu(inc)
   menuActive = changeWithLimit(menuActive, inc, 1, #(menuList))
end

local function valueIncDec(event,value,min,max,step)
	if editMode then
		if event == EVT_PLUS_FIRST or event == EVT_ROT_RIGHT or event==EVT_PLUS_REPT then
			if value<=max-step then
				value=value+step
			else 
				value = min
			end
	elseif event == EVT_MINUS_FIRST or event == EVT_ROT_LEFT or event==EVT_MINUS_REPT then
		if value>=min+step then
			value=value-step
		else
			value = max
        end
	end
end
return value
end

local function fieldIncDec(event,value,max,force)
	if editMode or force==true then
		if event==EVT_PLUS_FIRST or event == EVT_ROT_RIGHT  then
			value=value+max
		elseif event==EVT_MINUS_FIRST or event == EVT_ROT_LEFT	 then
			value=value+max+2
		end
	value=value%(max+1)
    end
return value
end

local function requestPage()
   if ActivePage.read and ((ActivePage.reqTS == nil) or (ActivePage.reqTS + REQ_TIMEOUT <= getTime())) then
      ActivePage.reqTS = getTime()
      kissSendRequest(ActivePage.read, {})
   end
end

local function drawScreen(page_locked)

   drawScreenTitle(ActivePage.title, currentPage, #(AllPages)-1)	
  
   for i=1,#(ActivePage.text) do
      local f = ActivePage.text[i]
      if f.to == nil then
         lcd.drawText(f.x, f.y, f.t, getDefaultTextOptions())
      else
         lcd.drawText(f.x, f.y, f.t, f.to)
      end
   end
   
   if ActivePage.lines ~= nil then
   	for i=1,#(ActivePage.lines) do
    	  local f = ActivePage.lines[i]
      	lcd.drawLine (f.x1, f.y1, f.x2, f.y2, SOLID, 0)
   	end
   end
   
   for i=1,#(ActivePage.fields) do
      local f = ActivePage.fields[i]

      local text_options = getDefaultTextOptions()
      if i == currentLine then
         text_options = INVERS
         if gState == EDITING then
            text_options = text_options + BLINK
         end
      end

	  local spacing = 20

      if f.t ~= nil then
		if currentPage == #(AllPages) and gState >= 6 then
			lcd.drawText(f.x, f.y, CP.wrName[i] , text_options)
		else
			lcd.drawText(f.x, f.y, f.t .. ":", getDefaultTextOptions())
		end
         
	  end
	  
      -- draw some value
      if f.sp ~= nil then
          spacing = f.sp
      end

      local idx = f.i or i
      if ActivePage.values and ActivePage.values[idx] then
         local val = ActivePage.values[idx]
         if f.table and f.table[ActivePage.values[idx]] then
            val = f.table[ActivePage.values[idx]]
         end
         
          if f.prec ~= nil then
          	val = formatKissFloat(val, f.prec, f.base)
          end
          
         lcd.drawText(f.x + spacing, f.y, val, text_options)
      else
         if currentPage ~= #(AllPages) then
			lcd.drawText(f.x + spacing, f.y, "---", text_options)
		end
      end
   end
   
   if ActivePage.customDraw ~= nil then
  		ActivePage.customDraw()
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

local function getCurrentField()
   return ActivePage.fields[currentLine]
end

local function incValue(inc)
   local field = ActivePage.fields[currentLine]
   local idx = field.i or currentLine
   
   local tmpInc = inc
   if field.prec ~= nil then
      tmpInc = tmpInc * 10^(3-field.prec)
   end
   
   if field.inc ~= nil then
   	  tmpInc = tmpInc * field.inc
   end
          
   ActivePage.values[idx] = clipValue(ActivePage.values[idx] + tmpInc, field.min or 0, field.max or 255)
   
end

local function run(event)

	if ActivePage==nil then
		loadPage(currentPage)
	end

   local now = getTime()
   if currentPage < #AllPages then 
	PREV_PAGE = currentPage
	end
   -- if lastRunTS old than 500ms
   if lastRunTS + 50 < now then
      invalidatePage()
   end
   lastRunTS = now

   if (gState == PAGE_SAVING) and (saveTS + saveTimeout < now) then
      if saveRetries < saveMaxRetries then
         saveSettings()
      else
         -- max retries reached
         gState = PAGE_DISPLAY
         invalidatePage()
      end
   end
   
   if #(kissTxBuf) > 0 then
      kissProcessTxQ()
   end

   -- navigation
 
   if event == EVT_MENU_LONG then
      menuActive = 1
	  sVal = savePageValues(ActivePage.values)
	  tmpModelNum = modelNum
      gState = MENU_DISP

   elseif EVT_PAGEUP_FIRST and (event == EVT_ENTER_LONG) then
      menuActive = 1
      killEnterBreak = 1
      gState = MENU_DISP
	  PREV_PAGE = currentPage
      
   -- menu is currently displayed
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

			if RADIO == "HORUS" then
				if killEnterBreak == 1 then
					killEnterBreak = 0
				end
			end
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
		currentPage = PREV_PAGE
		loadPage(PREV_PAGE)
		--readModel ( tmpModelNum )
		gState = MODEL_EDIT
	end
	if editMode then
		if activeField <= 9 then
			CPvN[activeField+1] = string.char(valueIncDec(event, string.byte(CPvN[activeField+1]), 34, 127, 1))
		elseif activeField == 10 then
			activeField = 0
			sVal = savePageValues(CP.data[modelNum])
			saveValues(modelNum, tableToString(CPvN))
			currentPage = PREV_PAGE
			loadPage(PREV_PAGE)
			gState = PAGE_DISPLAY
			--readModel ( tmpModelNum )
			currentLine=1
			editMode = not editMode
			
		elseif activeField == 11 then
			activeField = 0
			modelNum = currentLine
			editMode = not editMode
			currentPage = PREV_PAGE
			gState = PAGE_DISPLAY
			readModel ( modelNum )
			currentLine=1
		end
	else
		activeField = fieldIncDec(event, activeField, 11, true)
	end
   -- normal page viewing
   elseif gState <= PAGE_DISPLAY then
   	  if event == EVT_PAGEUP_FIRST then
         incPage(-1)
      elseif event == EVT_MENU_BREAK  or event == EVT_PAGEDN_FIRST then
         incPage(1)
      elseif event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
         incLine(-1)
      elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
         incLine(1)
      elseif event == EVT_ENTER_BREAK then
         local field = ActivePage.fields[currentLine]
         local idx = field.i or currentLine
         if ActivePage.values and ActivePage.values[idx] and (field.ro ~= true) then
            gState = EDITING
         end
      end
   -- editing value
   elseif gState == EDITING then
      if (event == EVT_EXIT_BREAK) or (event == EVT_ENTER_BREAK) then
         gState = PAGE_DISPLAY
      elseif event == EVT_PLUS_FIRST or event == EVT_ROT_RIGHT then
         incValue(1)
      elseif event == EVT_PLUS_REPT then
         incValue(10)
      elseif event == EVT_MINUS_FIRST or event == EVT_ROT_LEFT then
         incValue(-1)
      elseif event == EVT_MINUS_REPT then
		 incValue(-10)
      end
--READ/WRITE values to assigned Page and Line(Model)Number (ie: PIDS, Rates etc)
elseif gState >= 6 and gState < 9 then
	if event == EVT_ENTER_BREAK then
		modelNum = currentLine
		--CP = SetupPages[PREV_PAGE]
		for i = 1,#(CP.wrName[currentLine]) do
			CPvN[i] = string.sub(CP.wrName[currentLine],i,i)
		end
		if gState == MODEL_WRITE then
			currentPage = PREV_PAGE
			saveValues(modelNum)
			gState = PAGE_DISPLAY
			currentLine=1
			getMemData(PREV_PAGE)
			readModel(modelNum)
			
		elseif gState == MODEL_LOAD then
			currentPage = PREV_PAGE
			readModel(modelNum)
			gState = PAGE_DISPLAY
			currentLine=1
		elseif gState == MODEL_EDIT then
			gState = MENU_NAME
		end
	elseif event == EVT_PLUS_FIRST or event == EVT_PLUS_REPT or event == EVT_ROT_RIGHT then
		incLine(1)
	elseif event == EVT_MINUS_FIRST or event == EVT_MINUS_REPT or event == EVT_ROT_LEFT then
		incLine(-1)
	elseif event == EVT_EXIT_BREAK  then
		currentPage = PREV_PAGE
		loadPage(PREV_PAGE)
		gState = PAGE_DISPLAY
		
		
	end
   end

   local page_locked = false

   if ActivePage.values == nil then
      requestPage()
      page_locked = true
   end

   lcd.clear()
   drawScreen(page_locked)
  
   if isTelemetryPresent()~=true then
      drawTelemetry()
      invalidatePage()
   end

   if gState == MENU_DISP then
      drawMenu(menuList, menuActive)
   elseif gState == MENU_NAME then
	  drawEditMenu()
   elseif gState == PAGE_SAVING then
     drawSaving()
   end

   processKissReply(kissPollReply())
   return 0
end

return {init=init, run=run}

-- END UI