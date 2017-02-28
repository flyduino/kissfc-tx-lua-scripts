--
-- KISS/SPORT code
--
-- Based on Betaflight LUA script
--
-- Kiss version by Alex Fedorov aka FedorComander

-- Protocol version
SPORT_KISS_VERSION = bit32.lshift(1,5)

SPORT_KISS_STARTFLAG = bit32.lshift(1,4)

-- Sensor ID used by the local LUA script
LOCAL_SENSOR_ID  = 0x0D

-- Sensor ID used by the KISS server (BF, CF, MW, etc...)
REMOTE_SENSOR_ID = 0x1B

REQUEST_FRAME_ID = 0x30
REPLY_FRAME_ID   = 0x32

-- Sequence number for next KISS/SPORT packet
local sportKissSeq = 0
local sportKissRemoteSeq = 0

local kissRxBuf = {}
local kissRxIdx = 1
local kissRxCRC = 0
local kissStarted = false
local kissLastReq = 0

-- Stats
kissRequestsSent    = 0
kissRepliesReceived = 0
kissPkRxed = 0
kissErrorPk = 0
kissStartPk = 0
kissOutOfOrder = 0
kissCRCErrors = 0

-- Format kiss float value
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

local function subrange(t, first, last)
  local sub = {}
  for i=first,last do
    sub[#sub + 1] = t[i]
  end
  return sub
end

local function kissResetStats()
   kissRequestsSent    = 0
   kissRepliesReceived = 0
   kissPkRxed = 0
   kissErrorPk = 0
   kissStartPk = 0
   kissOutOfOrderPk = 0
   kissCRCErrors = 0
end

local kissTxBuf = {}
local kissTxIdx = 1
local kissTxCRC = 0

local kissTxPk = 0

local function kissSendSport(payload)

   local dataId = 0
   dataId = payload[1] + bit32.lshift(payload[2],8)

   local value = 0
   value = payload[3] + bit32.lshift(payload[4],8)
      + bit32.lshift(payload[5],16) + bit32.lshift(payload[6],24)

   local ret = sportTelemetryPush(LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId, value)
   if ret then
      kissTxPk = kissTxPk + 1
   end
end

local function kissProcessTxQ()

   if (#(kissTxBuf) == 0) then
      return false
   end

   if not sportTelemetryPush() then
      return true
   end

   local payload = {}
   payload[1] = sportKissSeq + SPORT_KISS_VERSION
   sportKissSeq = bit32.band(sportKissSeq + 1, 0x0F)

   if kissTxIdx == 1 then
      -- start flag
      payload[1] = payload[1] + SPORT_KISS_STARTFLAG
   end

   local i = 2
   while (i <= 6) do
      payload[i] = kissTxBuf[kissTxIdx]
      kissTxIdx = kissTxIdx + 1
      i = i + 1
      if kissTxIdx > #(kissTxBuf) then
         break
      end
   end

   if i <= 6 then
      -- zero fill
      while i <= 6 do
         payload[i] = 0
         i = i + 1
      end
      kissSendSport(payload)
      kissTxBuf = {}
      kissTxIdx = 1
      return false
   else 
      kissSendSport(payload)
   	  if kissTxIdx > #(kissTxBuf) then
 		kissTxBuf = {}
      	kissTxIdx = 1
      	return false
   	  else 
   	    return true
   	  end
   end
end

local function kissSendRequest(cmd,payload)

   -- busy
   if #(kissTxBuf) ~= 0 then
      return nil
   end

   local checksum = 0

   kissTxBuf[1] = bit32.band(cmd,0xFF)  -- KISS command
   kissTxBuf[2] = bit32.band(#(payload), 0xFF) -- KISS payload size

   for i=1,#(payload) do
      kissTxBuf[i+2] = payload[i]
      checksum = checksum + payload[i]
   end
   checksum = bit32.band(checksum, 0xFFFF)
   local tmpSum = 0;
   if (#(payload) > 0) then 
   		tmpSum = checksum / #(payload)
   end
   kissTxBuf[#(payload)+3] = bit32.band(math.floor(tmpSum), 0xFF)
   
   kissLastReq = cmd
   kissRequestsSent = kissRequestsSent + 1
   return kissProcessTxQ()
end

local function kissReceivedReply(payload)

   kissPkRxed = kissPkRxed + 1
   
   local idx      = 1
   local head     = payload[idx]
   local err_flag = (bit32.band(head,0x20) ~= 0)
   idx = idx + 1

   if err_flag then
      -- error flag set
      kissStarted = false

      kissErrorPk = kissErrorPk + 1

      -- return error
      -- CRC checking missing

      --return payload[idx]
      return nil
   end
   
   local start = (bit32.band(head,0x10) ~= 0)
   local seq   = bit32.band(head,0x0F)

   if start then
      -- start flag set
      kissRxIdx = 1
      kissRxBuf = {}

      kissRxSize = payload[idx + 1] + 3
      kissRxCRC  = 0
      kissStarted = true
      
      kissStartPk = kissStartPk + 1

   elseif not kissStarted then
      kissOutOfOrder = kissOutOfOrder + 1
      return nil

   elseif bit32.band(sportKissRemoteSeq + 1, 0x0F) ~= seq then
      kissOutOfOrder = kissOutOfOrder + 1
      kissStarted = false
      return nil
   end

   while (idx <= 6) and (kissRxIdx <= kissRxSize) do
      kissRxBuf[kissRxIdx] = payload[idx]
      if (kissRxIdx>2) and (kissRxIdx < kissRxSize) then
      		kissRxCRC = kissRxCRC + payload[idx]
      end
      kissRxIdx = kissRxIdx + 1
      idx = idx + 1
   end

   if kissRxIdx <= kissRxSize then
      sportKissRemoteSeq = seq
      return true
   end

   if kissRxSize>3 then
   		kissRxCRC = bit32.band(math.floor(kissRxCRC / (kissRxSize-3)), 0xFF)
   		if kissRxCRC ~= kissRxBuf[kissRxSize] then
   	  		kissStarted = false
   			kissCRCErrors = kissCRCErrors + 1
   			return nil
   		end
   	end

   kissRepliesReceived = kissRepliesReceived + 1
   kissStarted = false
   return subrange(kissRxBuf, 3, kissRxSize-1)
end

local function kissPollReply()
   while true do
      local sensorId, frameId, dataId, value = sportTelemetryPop()
       
      if sensorId == REMOTE_SENSOR_ID and frameId == REPLY_FRAME_ID then

         local payload = {}
         payload[1] = bit32.band(dataId,0xFF)
         dataId = bit32.rshift(dataId,8)
         payload[2] = bit32.band(dataId,0xFF)

         payload[3] = bit32.band(value,0xFF)
         value = bit32.rshift(value,8)
         payload[4] = bit32.band(value,0xFF)
         value = bit32.rshift(value,8)
         payload[5] = bit32.band(value,0xFF)
         value = bit32.rshift(value,8)
         payload[6] = bit32.band(value,0xFF)

         local ret = kissReceivedReply(payload)
         if type(ret) == "table" then
            return kissLastReq,ret
         end
      else
         break
      end
   end

   return nil
end

--
-- End of KISS/SPORT code
--

local KISS_GET_RATES    		= 0x41
local KISS_SET_RATES 			= 0x42
local KISS_GET_PIDS     		= 0x43
local KISS_SET_PIDS     		= 0x44
local KISS_GET_VTX_CONFIG       = 0x45
local KISS_SET_VTX_CONFIG   	= 0x46
local KISS_GET_FILTERS       	= 0x47
local KISS_SET_FILTERS   		= 0x48
local KISS_GET_ALARMS       	= 0x49
local KISS_SET_ALARMS   		= 0x4A

local REQ_TIMEOUT = 200 -- 1000ms request timeout

--local PAGE_REFRESH = 1
local PAGE_DISPLAY = 2
local EDITING      = 3
local PAGE_SAVING  = 4
local MENU_DISP    = 5

local gState = PAGE_DISPLAY

local function postReadVTX(page)
   local vtx = {}
   vtx[1] = page.values[1]
   vtx[2] = 1 + bit32.rshift(page.values[2], 3)
   vtx[3] = 1 + bit32.band(page.values[2], 0x07)
   vtx[4] = bit32.lshift(page.values[3], 8) + page.values[4]
   vtx[5] = bit32.lshift(page.values[5], 8) + page.values[6]
   page.values = vtx
end

local function getWriteValuesVTX(values)
   local ret = {}
   ret[1] = bit32.band(values[1], 0xFF)
   ret[2] = bit32.band((values[2]-1) * 8 + values[3]-1, 0xFF)
   ret[3] = bit32.band(bit32.rshift(values[4], 8), 0xFF)
   ret[4] = bit32.band(values[4], 0xFF)
   ret[5] = bit32.band(bit32.rshift(values[5], 8), 0xFF)
   ret[6] = bit32.band(values[5], 0xFF)
   return ret
end

local function postReadFilters(page)
   local filters = {}
   filters[1] = page.values[3] + 1
   filters[2] = bit32.lshift(page.values[4], 8) + page.values[5]
   filters[3] = bit32.lshift(page.values[6], 8) + page.values[7]
   filters[4] = page.values[8] + 1
   filters[5] = bit32.lshift(page.values[9], 8) + page.values[10]
   filters[6] = bit32.lshift(page.values[11], 8) + page.values[12]
   filters[7] = page.values[1] + 1
   filters[8] = page.values[2]
   page.values = filters
end

local function getWriteValuesFilters(values)
   local ret = {}
   ret[1] = bit32.band(values[7]-1, 0xFF)
   ret[2] = bit32.band(values[8], 0xFF)
   ret[3] = bit32.band(values[1]-1, 0xFF);
   ret[4] = bit32.band(bit32.rshift(values[2], 8), 0xFF)
   ret[5] = bit32.band(values[2], 0xFF)
   ret[6] = bit32.band(bit32.rshift(values[3], 8), 0xFF)
   ret[7] = bit32.band(values[3], 0xFF)
   ret[8] = bit32.band(values[4]-1, 0xFF);
   ret[9] = bit32.band(bit32.rshift(values[5], 8), 0xFF)
   ret[10] = bit32.band(values[5], 0xFF)
   ret[11] = bit32.band(bit32.rshift(values[6], 8), 0xFF)
   ret[12] = bit32.band(values[6], 0xFF)
   return ret
end

local function postReadPIDS(page)
   local pids = {}
   for i=0,2 do
   	 pids[i*3+1] = bit32.lshift(page.values[i*6+1], 8) + page.values[i*6+2]
  	 pids[i*3+2] = bit32.lshift(page.values[i*6+3], 8) + page.values[i*6+4]
     pids[i*3+3] = bit32.lshift(page.values[i*6+5], 8) + page.values[i*6+6]
   end
   page.values = pids
end

local function getWriteValuesPIDS(values)
   local ret = {}
   local tmp
   for i=0,2 do 
    	ret[i*6+1] = bit32.rshift(values[i*3+1], 8)
   		ret[i*6+2] = bit32.band(values[i*3+1], 0xFF)
    	ret[i*6+3] = bit32.rshift(values[i*3+2], 8)
   		ret[i*6+4] = bit32.band(values[i*3+2], 0xFF)
    	ret[i*6+5] = bit32.rshift(values[i*3+3], 8)
   		ret[i*6+6] = bit32.band(values[i*3+3], 0xFF)
   end
   return ret
end

local function postReadRates(page)
  local rates = {}
  for i=1,9 do
  	rates[i] = bit32.lshift(page.values[(i-1)*2 + 1], 8) + page.values[(i-1)*2 + 2]
  end
  page.values = rates;
end

local function getWriteValuesRates(values)
   local ret = {}
   for i=1,9 do 
        ret[(i-1)*2 + 1] = bit32.rshift(values[i], 8)
   		ret[(i-1)*2 + 2] = bit32.band(values[i], 0xFF)
   end
   return ret
end

local function postReadAlarms(page)
   local alarms = {}
   alarms[1] = 100 * (bit32.lshift(page.values[1], 8) + page.values[2])
   alarms[2] = bit32.lshift(page.values[3], 8) + page.values[4]
   page.values = alarms
end

local function getWriteValuesAlarms(values)
   local ret = {}
   local tmp = bit32.band(math.floor(values[1]/100), 0xFFFF)
   ret[1] = bit32.band(bit32.rshift(tmp, 8), 0xFF)
   ret[2] = bit32.band(tmp, 0xFF)
   ret[3] = bit32.band(bit32.rshift(values[2], 8), 0xFF)
   ret[4] = bit32.band(values[2], 0xFF)
   return ret
end

SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "P", x = 60,  y = 14 },
         { t = "I", x = 120, y = 14 },
         { t = "D", x = 175, y = 14 },
         { t = "Roll",  x = 10,  y = 25 },
         { t = "Pitch", x = 10,  y = 38 },
         { t = "Yaw",   x = 10,  y = 50 }
      },
      fields = {
         -- P
         { x = 35,  y = 25, i=1, max=65000, prec=2 },
         { x = 90,  y = 25, i=2, max=65000, prec=3 },
         { x = 145, y = 25, i=3, max=65000, prec=2 },
         -- I
         { x = 35,  y = 38, i=4, max=65000, prec=2 },
         { x = 90,  y = 38, i=5, max=65000, prec=3 },
         { x = 145, y = 38, i=6, max=65000, prec=2 },
         -- D
         { x = 35,  y = 50, i=7, max=65000, prec=2 },
         { x = 90,  y = 50, i=8, max=65000, prec=3 },
         { x = 145, y = 50, i=9, max=65000, prec=2 }
      },
      read  = KISS_GET_PIDS,
      write = KISS_SET_PIDS,
      postRead = postReadPIDS,
      getWriteValues = getWriteValuesPIDS
   },
   {
      title = "Rates",
      text = {
         { t = "RC Rate", x = 45,  y = 14 },
         { t = "Rate",    x = 107, y = 14 },
         { t = "RC Curve", x = 150, y = 14 },
         { t = "Roll",  x = 10,  y = 25 },
         { t = "Pitch", x = 10,  y = 38 },
         { t = "Yaw",   x = 10,  y = 50 }
      },
      fields = {
         -- RC Rate
         { x = 35,  y = 25, i=1, max=65000, prec=2 },
         { x = 90,  y = 25, i=2, max=65000, prec=2 },
         { x = 145, y = 25, i=3, max=65000, prec=2 },
         -- Rate
         { x = 35,  y = 38, i=4, max=65000, prec=2 },
         { x = 90,  y = 38, i=5, max=65000, prec=2 },
         { x = 145, y = 38, i=6, max=65000, prec=2 },
         -- RC Curve
         { x = 35,  y = 50, i=7, max=65000, prec=2 },
         { x = 90,  y = 50, i=8, max=65000, prec=2 },
         { x = 145, y = 50, i=9, max=65000, prec=2 }
      },
      read  = KISS_GET_RATES,
      write = KISS_SET_RATES,
      postRead = postReadRates,
      getWriteValues = getWriteValuesRates
   },
   {
      title = "Filters",
      text = {
         { t = "Notch",  x = 47,  y = 14 },
         { t = "Center", x = 100, y = 14 },
         { t = "Cutoff", x = 150, y = 14 },
         { t = "Roll",  x = 10,  y = 25 },
         { t = "Pitch", x = 10,  y = 38 },
         { t = "LPF",   x = 10,  y = 50 },
         { t = "Yaw",   x = 110, y = 50 }
      },
      fields = {
         -- Filters
         { x = 35,  y = 25,  i=1, min=1, max=2, table = { "Off", "On" }},
         { x = 90,  y = 25,  i=2, min=0, max=490 },
         { x = 145, y = 25,  i=3, min=0, max=490 },
         { x = 35,  y = 38,  i=4, min=1, max=2, table = { "Off", "On" }},
         { x = 90,  y = 38,  i=5, min=0, max=490 },
         { x = 145, y = 38,  i=6, min=0, max=490 },
         { x = 35,  y = 50,  i=7, min=1, max=7, table = { "Off", "High", "Med. High", "Medium", "Med. Low", "Low", "Very Low" } },
         { x = 145, y = 50,  i=8, min=0, max=97},
      },
      read  = KISS_GET_FILTERS,
      write = KISS_SET_FILTERS,
      postRead = postReadFilters,
      getWriteValues = getWriteValuesFilters
   },
   {
      title = "Alarms",
      text = {},
      fields = {
         -- Alarms
         { t = "VBat",    x = 15,  y = 25, sp = 30, i=1, min=0, max=26000, prec=1 },
         { t = "mAH",     x = 120, y = 25, sp = 30, i=2, min=0, max=26000, inc=10 }
      },
      read  = KISS_GET_ALARMS,
      write = KISS_SET_ALARMS,
      postRead = postReadAlarms,
      getWriteValues = getWriteValuesAlarms
   },  
   {
      title = "VTX",
      text = {},
      fields = {
         -- VTX
         { t = "Band",    	   x = 15,  y = 25, sp = 60, i=2, min=1, max=5, table = { "A", "B", "E", "FS", "RB" } },
         { t = "Channel",      x = 110, y = 25, sp = 70, i=3, min=1, max=8 },
         { t = "Low Power",    x = 15,  y = 38, sp = 60, i=4, min=0, max=600 },
         { t = "High Power",   x = 110, y = 38, sp = 70, i=5, min=0, max=600 }
      },
      read  = KISS_GET_VTX_CONFIG,
      write = KISS_SET_VTX_CONFIG,
      postRead = postReadVTX,
      getWriteValues = getWriteValuesVTX
   }
}

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

   lcd.drawScreenTitle('Kiss Setup:  '..screen_title,currentPage,#(SetupPages))

   for i=1,#(page.text) do
      local f = page.text[i]
      lcd.drawText(f.x, f.y, f.t, text_options) 
   end
   
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
      	lcd.drawText(f.x, f.y, f.t .. ":", 0)
      end
      
      -- draw some value
      local spacing = 20
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

local function drawMenu()
   local x = 40
   local y = 12
   local w = 120
   local h = #(menuList) * 8 + 6
   lcd.drawFilledRectangle(x,y,w,h,ERASE)
   lcd.drawRectangle(x,y,w-1,h-1,SOLID)
   lcd.drawText(x+4,y+3,"Menu:")

   for i,e in ipairs(menuList) do
      if menuActive == i then
         lcd.drawText(x+36,y+(i-1)*8+3,e.t,INVERS)
      else
         lcd.drawText(x+36,y+(i-1)*8+3,e.t)
      end
   end
end

local EVT_MENU_LONG = bit32.bor(bit32.band(EVT_MENU_BREAK,0x1f),0x80)

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

   -- menu is currently displayed
   elseif gState == MENU_DISP then
      if event == EVT_EXIT_BREAK then
         gState = PAGE_DISPLAY
      elseif event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
         incMenu(-1)
      elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
         incMenu(1)
      elseif event == EVT_ENTER_BREAK then
         gState = PAGE_DISPLAY
         menuList[menuActive].f()
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
   if getValue("RSSI") == 0 then
      -- No!
      lcd.drawText(70,55,"No telemetry",BLINK)
      invalidatePages()
   end

   if gState == MENU_DISP then
      drawMenu()
   elseif gState == PAGE_SAVING then
      lcd.drawFilledRectangle(40,12,120,30,ERASE)
      lcd.drawRectangle(40,12,120,30,SOLID)
      lcd.drawText(64,18,"Saving...", DBLSIZE + BLINK)
   end

   processKissReply(kissPollReply())
   return 0
end

return {run=run}
