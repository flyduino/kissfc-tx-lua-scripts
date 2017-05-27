
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
         saveMaxRetries = page.saveMaxRetries or 2 -- default 2
         saveTimeout = page.saveTimeout or 400     -- default 4s
      end
   end
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

   { t = "save page",
     f = saveSettings },

   { t = "reload",
     f = invalidatePages }
}

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

local function incPage(inc)
   currentPage = currentPage + inc
   if currentPage > #(SetupPages) then
      currentPage = 1
   elseif currentPage < 1 then
      currentPage = #(SetupPages)
   end
   currentLine = 1
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

local function drawScreen(page,page_locked)

   local screen_title = page.title

   drawScreenTitle(screen_title, currentPage)	
 
   for i=1,#(page.text) do
      local f = page.text[i]
      if f.to == nil then
         lcd.drawText(f.x, f.y, f.t, getDefaultTextOptions())
      else
         lcd.drawText(f.x, f.y, f.t, f.to)
      end
   end
   
   if page.lines ~= nil then
   	for i=1,#(page.lines) do
    	  local f = page.lines[i]
      	lcd.drawLine (f.x1, f.y1, f.x2, f.y2, SOLID, FORCE)
   	end
   end
   
   for i=1,#(page.fields) do
      local f = page.fields[i]

      local text_options = getDefaultTextOptions()
      if i == currentLine then
         text_options = INVERS
         if gState == EDITING then
            text_options = text_options + BLINK
         end
      end

	  local spacing = 20

      if f.t ~= nil then
         lcd.drawText(f.x, f.y, f.t .. ":", getDefaultTextOptions())
	  end
	  
      -- draw some value
      if f.sp ~= nil then
          spacing = f.sp
      end
     

      local idx = f.i or i
      if page.values and page.values[idx] then
         local val = page.values[idx]
         if f.table and f.table[page.values[idx]] then
            val = f.table[page.values[idx]]
         end
         
          if f.prec ~= nil then
          	val = formatKissFloat(val, f.prec, f.base)
          end
          
         lcd.drawText(f.x + spacing, f.y, val, text_options)
      else
         lcd.drawText(f.x + spacing, f.y, "---", text_options)
      end
   end
   
   -- Custom drawing code
   if page.customDraw ~= nil then
  		page.customDraw()
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
   local page = SetupPages[currentPage]
   return page.fields[currentLine]
end

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

local lastRunTS = 0

local function run(event)

   local now = getTime()

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
   if event == EVT_MENU_LONG then
      menuActive = 1
      gState = MENU_DISP

   elseif EVT_PAGEUP_FIRST and (event == EVT_ENTER_LONG) then
      menuActive = 1
      killEnterBreak = 1
      gState = MENU_DISP
      
   -- menu is currently displayed
   elseif gState == MENU_DISP then
      if event == EVT_EXIT_BREAK then
         gState = PAGE_DISPLAY
      elseif event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
         incMenu(-1)
      elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
         incMenu(1)
      elseif event == EVT_ENTER_BREAK then
      	if RADIO == "HORUS" then
      		if killEnterBreak == 1 then
            	killEnterBreak = 0
         	else
            	gState = PAGE_DISPLAY
            	menuList[menuActive].f()
         	end
      	else
         	gState = PAGE_DISPLAY
         	menuList[menuActive].f()
        end 
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
      elseif event == EVT_PLUS_FIRST or event == EVT_ROT_RIGHT then
         incValue(1)
      elseif event == EVT_PLUS_REPT then
         incValue(10)
      elseif event == EVT_MINUS_FIRST or event == EVT_ROT_LEFT then
         incValue(-1)
      elseif event == EVT_MINUS_REPT then
		 incValue(-10)
      end
   end

   local page = SetupPages[currentPage]
   local page_locked = false

   if not page.values then
      -- request values
      requestPage(page)
      page_locked = true
   end

   -- draw screen
   lcd.clear()
   drawScreen(page,page_locked)
   
   -- do we have valid telemetry data?
   if isTelemetryPresent()~=true then
      -- No!
      drawTelemetry()
      invalidatePages()
   end

   if gState == MENU_DISP then
      drawMenu(menuList, menuActive)
   elseif gState == PAGE_SAVING then
     drawSaving()
   end

   processKissReply(kissPollReply())
   return 0
end

return {run=run}
