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

local KISS_GET_RATES    		= 0x4D
local KISS_SET_RATES 			= 0x4E
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
local EDITING = 3
local PAGE_SAVING = 4
local MENU_DISP = 5
local MODEL_WRITE = 6
local MODEL_LOAD = 7
local MODEL_EDIT = 8
local MENU_NAME = 9
local PREV_PAGE = 1
local gState = PAGE_DISPLAY
local nL = 10 --DataSet Name Length
local fv = 1

local function init()
local str
local ret = {}
for i = 1,#(SetupPages)-1 do
	x=SetupPages[i]
	local f = io.open("/SCRIPTS/"..x.title, "r")
	if not f then
		f = io.open("/SCRIPTS/"..x.title, "a")
		for j = 1,5 do  --number of available saved values sets
			io.write(f,x.defValues)
		end
		io.close(f)
	else
		io.close(f)
	end
end	

end

--End Code for Validate files exist
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

local function postReadFilters(page,val)
local filters = {}
local rates = {}
local v = {}
if val ~= nil then
	v = val
else
	v = page.values
end
filters[1] = v[3] + 1
filters[2] = bit32.lshift(v[4], 8) + v[5]
filters[3] = bit32.lshift(v[6], 8) + v[7]
filters[4] = v[8] + 1
filters[5] = bit32.lshift(v[9], 8) + v[10]
filters[6] = bit32.lshift(v[11], 8) + v[12]
filters[7] = v[1] + 1
filters[8] = v[2]
if val ~= nil then
	return filters
else
	page.values = filters
end
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

local function postReadPIDS(page,val)
local pids = {}
local v = {}
if val ~= nil then
	v = val
else
	v = page.values
end
for i=0,2 do
	pids[i*3+1] = bit32.lshift(v[i*6+1], 8) + v[i*6+2]
	pids[i*3+2] = bit32.lshift(v[i*6+3], 8) + v[i*6+4]
	pids[i*3+3] = bit32.lshift(v[i*6+5], 8) + v[i*6+6]
end
if val ~= nil then
	return pids
else
	page.values = pids
end

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

local function postReadRates(page,val)
local rates = {}
local v = {}
if val ~= nil then
	v = val
else
	v = page.values
end
for i=1,9 do
	rates[i] = bit32.lshift(v[(i-1)*2 + 1], 8) + v[(i-1)*2 + 2]
end
if val ~= nil then
	return rates
else
	page.values = rates
end
end

local function getWriteValuesRates(values)
local ret = {}
for i=1,9 do 
	ret[(i-1)*2 + 1] = bit32.rshift(values[i], 8)
	ret[(i-1)*2 + 2] = bit32.band(values[i], 0xFF)
end
return ret
end

local function postReadAlarms(page,val)
local alarms = {}
local v = {}
if val ~= nil then
	v = val
else
	v = page.values
end
alarms[1] = 100 * (bit32.lshift(v[1], 8) + v[2])
alarms[2] = bit32.lshift(v[3], 8) + v[4]
if val ~= nil then
	return alarms
else
	page.values = alarms
end
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

local function postReadTPA(page, val)
    local tpa = {}
	local v = {}
	if val ~= nil then
		v = val
	else
		v = page.values
	end
    for i=1,3 do
 		tpa[i] = bit32.lshift(v[(i-1)*2 + 1], 8) + v[(i-1)*2 + 2]
    end
    tpa[4] = v[7] + 1
    for i=5,10 do
 		tpa[i] = v[i + 3]
    end
	if val ~= nil then
		return tpa
	else
		page.values = tpa
	end
 end
 
 local function getWriteValuesTPA(values)
    local ret = {}
    for i=1,3 do
 	   ret[(i-1)*2 + 1] = bit32.rshift(values[i], 8)
 	   ret[(i-1)*2 + 2] = bit32.band(values[i], 0xFF)
    end
   ret[7] = bit32.band(values[4]-1, 0xFF)
    for i=5,10 do
     ret[i+3] = bit32.band(values[i], 0xFF)
    end
    return ret
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

local SP = SetupPages[fileNum]
local dLen = SP.dL
local f = io.open("/SCRIPTS/"..SP.title, "r")
io.seek(f,0)

for i = 1,5 do
io.seek(f,(i-1)*(nL+dLen))
SP.wrName[i] = io.read(f,nL)
var = {}
	for j = 1,dLen/4 do
		io.seek(f,nL+(i-1)*(nL+dLen)+(j-1)*4)
		var[j] = tonumber(io.read(f,4))
	end
	SP.data[i] = var
end
io.close(f)
end



