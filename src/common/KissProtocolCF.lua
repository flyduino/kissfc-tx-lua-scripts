--
-- KISS/CF code
-- Kiss version by Alex Fedorov aka FedorComander

LOCAL_DEVICE_ID  = 0xEA -- transmitter
REMOTE_DEVICE_ID = 0xC8 -- flight controller

FC_REQUEST_COMMAND  = 0x78
FC_RESPONSE_COMMAND = 0x79

local kissLastReq = 0
local kissTxBuf = {}

local function isTelemetryPresent()
  return true
end

local function subrange(t, first, last)
  local sub = {}
  for i=first,last do
    sub[#sub + 1] = t[i]
  end
  return sub
end

local function kissProcessTxQ()
  if (#(kissTxBuf) == 0) then
    return false
  end

  if not crossfireTelemetryPush() then
    return true
  end

  local tmp = {}
  tmp[1] = REMOTE_DEVICE_ID
  tmp[2] = LOCAL_DEVICE_ID
  for i=1,#(kissTxBuf) do
    tmp[2 + i] = kissTxBuf[i]
  end
  local ret = crossfireTelemetryPush(FC_REQUEST_COMMAND, tmp)

  kissTxBuf = {}
  return false
end

local function kissSendRequest(cmd, payload)
  if #(kissTxBuf) ~= 0 then
    return nil
  end

  local crc = 0

  kissTxBuf[1] = bit32.band(cmd, 0xFF)  -- KISS command
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
  local crc = 0

  for i=3, (#(payload)-1) do
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

  if crc ~= payload[#(payload)] then
    return nil
  end

  return subrange(payload, 3, #(payload)-1)
end

local function kissPollReply()

  while true do
    local command, value = crossfireTelemetryPop()
    if command == nil then
      break
    end

    if (value ~=nil) then -- bit32.band(command, 0xFF) == 0x79
      local ret = kissReceivedReply(subrange(value, 3, #(value)))
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
-- End of KISS/CROSSFIRE code
--

