
-- Kiss protocol adapters

local KISS_GET_RATES    		= 0x4D
local KISS_SET_RATES 			= 0x4E
local KISS_GET_PIDS     		= 0x43
local KISS_SET_PIDS     		= 0x44
local KISS_GET_VTX_CONFIG       = 0x45
local KISS_SET_VTX_CONFIG       = 0x46
local KISS_GET_FILTERS          = 0x47
local KISS_SET_FILTERS          = 0x48
local KISS_GET_ALARMS           = 0x49
local KISS_SET_ALARMS           = 0x4A
local KISS_GET_TPA              = 0x4B
local KISS_SET_TPA              = 0x4C

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

local function postReadTPA(page)
   local tpa = {}
   for i=1,3 do
        tpa[i] = bit32.lshift(page.values[(i-1)*2 + 1], 8) + page.values[(i-1)*2 + 2]
   end
   tpa[4] = page.values[7] + 1
   for i=5,10 do
        tpa[i] = page.values[i + 3]
   end
   page.values = tpa
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




