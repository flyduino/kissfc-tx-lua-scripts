--
-- KISS/SPORT code
--
-- Based on Betaflight LUA script
--
-- Kiss version by Alex Fedorov aka FedorComander


-- SPORT BEGIN

SPORT_KISS_VERSION = bit32.lshift(1,5)
SPORT_KISS_STARTFLAG = bit32.lshift(1,4)
LOCAL_SENSOR_ID  = 0x0D
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
local kissTxBuf = {}
local kissTxIdx = 1
local kissTxCRC = 0
local kissTxPk = 0

local function isTelemetryPresent() 
	return getValue("RSSI")>0
end

local function subrange(t, first, last)
  local sub = {}
  for i=first,last do
    sub[#sub + 1] = t[i]
  end
  return sub
end

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

   local crc = 0

   kissTxBuf[1] = bit32.band(cmd,0xFF)  -- KISS command
   kissTxBuf[2] = bit32.band(#(payload), 0xFF) -- KISS payload size

   for i=1,#(payload) do
      kissTxBuf[i+2] = payload[i]
      crc = bit32.bxor(crc, payload[i]);
      for i=1,8 do
       	if bit32.band(crc, 0x80) ~= 0 then
       		crc = bit32.bxor(bit32.lshift(crc, 1), 0xD5)
       	else
       		crc = bit32.lshift(crc, 1)
       	end
       	crc = bit32.band(crc, 0xFF)
      end
   end
   kissTxBuf[#(payload)+3] = crc
   kissLastReq = cmd
   return kissProcessTxQ()
end

local function kissReceivedReply(payload)

   local idx      = 1
   local head     = payload[idx]
   local err_flag = (bit32.band(head,0x20) ~= 0)
   idx = idx + 1

   if err_flag then
      -- error flag set
      kissStarted = false
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

   elseif not kissStarted then
      return nil

   elseif bit32.band(sportKissRemoteSeq + 1, 0x0F) ~= seq then
      kissStarted = false
      return nil
   end

   while (idx <= 6) and (kissRxIdx <= kissRxSize) do
      kissRxBuf[kissRxIdx] = payload[idx]
      if (kissRxIdx>2) and (kissRxIdx < kissRxSize) then
      		kissRxCRC = bit32.bxor(kissRxCRC, payload[idx]);
      		for i=1,8 do
       			if bit32.band(kissRxCRC, 0x80) ~= 0 then
       				kissRxCRC = bit32.bxor(bit32.lshift(kissRxCRC, 1), 0xD5)
       			else
       				kissRxCRC = bit32.lshift(kissRxCRC, 1)
       			end
       			kissRxCRC = bit32.band(kissRxCRC, 0xFF)
      		end
      end
      kissRxIdx = kissRxIdx + 1
      idx = idx + 1
   end

   if kissRxIdx <= kissRxSize then
      sportKissRemoteSeq = seq
      return true
   end

   if kissRxSize>3 then
   		if kissRxCRC ~= kissRxBuf[kissRxSize] then
   	  		kissStarted = false
   			return nil
   		end
   	end

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

-- SPORT END