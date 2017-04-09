local RADIO = "X7"

SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "P", x = 45, y = 14 },
         { t = "I", x = 78, y = 14 },
         { t = "D", x = 107, y = 14 },
         { t = "Roll",  x = 3,  y = 25 },
         { t = "Pitch", x = 3,  y = 38 },
         { t = "Yaw",   x = 3,  y = 50 }
      },
      fields = {
         { x = 20,  y = 25, i=1, max=65000, prec=2 },
         { x = 48,  y = 25, i=2, max=65000, prec=3 },
         { x = 80,  y = 25, i=3, max=65000, prec=2 },
         
         { x = 20,  y = 38, i=4, max=65000, prec=2 },
         { x = 48,  y = 38, i=5, max=65000, prec=3 },
         { x = 80,  y = 38, i=6, max=65000, prec=2 },
         
         { x = 20,  y = 50, i=7, max=65000, prec=2 },
         { x = 48,  y = 50, i=8, max=65000, prec=3 },
         { x = 80,  y = 50, i=9, max=65000, prec=2 }
      },
	wrName = {},
	dL = 72,
	data = {},
	defValues = "Default___  11 184   0  35  39  16  11 184   0  35  39  16  31  64   0  50   0   0",
      read  = KISS_GET_PIDS,
      write = KISS_SET_PIDS,
      postRead = postReadPIDS,
	  postWrite = wrReadPIDS,
      getWriteValues = getWriteValuesPIDS
   },
   
   {
      title = "Rates",
      text = {
         { t = "RC",     x = 41, y = 14 },
         { t = "Rate",   x = 65, y = 14 },
         { t = "Curve",  x = 95, y = 14 },
         { t = "Roll",   x = 3,  y = 25 },
         { t = "Pitch",  x = 3,  y = 38 },
         { t = "Yaw",    x = 3,  y = 50 }
      },
      fields = {
         -- RC Rate
         { x = 16,  y = 25, i=1, max=65000, prec=2 },
         { x = 48,  y = 25, i=2, max=65000, prec=2 },
         { x = 80,  y = 25, i=3, max=65000, prec=2 },
         -- Rate
         { x = 16,  y = 38, i=4, max=65000, prec=2 },
         { x = 48,  y = 38, i=5, max=65000, prec=2 },
         { x = 80,  y = 38, i=6, max=65000, prec=2 },
         -- RC Curve
         { x = 16,  y = 50, i=7, max=65000, prec=2 },
         { x = 48,  y = 50, i=8, max=65000, prec=2 },
         { x = 80,  y = 50, i=9, max=65000, prec=2 }
      },
	  wrName = {},
	varName = {},
	dL = 72,
	data = {},
	defValues= "Default___   2 192   2 192   1 144   2 192   2 192   1 144   2 192   2 192   1 144",
      read  = KISS_GET_RATES,
      write = KISS_SET_RATES,
      postRead = postReadRates,
	  postWrite = wrReadRates,
      getWriteValues = getWriteValuesRates
   },
   {
      title = "Filters",
      text = {
         { t = "Center", 			x = 50, y = 14 },
         { t = "Cutoff", 			x = 90, y = 14 },
         { t = "Notch", 			x = 3,  y = 14 },
         { t = "Roll",  			x = 3,  y = 25 },
         { t = "Pitch", 			x = 3,  y = 38 },
         { t = "LPF",   			x = 3,  y = 52 },
         { t = "Yaw",   			x = 65, y = 52 }
      },
      lines = {
      	 { x1 = 1, y1 = 48, x2 = 125, y2 = 48 }
      },
      fields = {
         -- Filters
         { x = 15,  y = 25,  i=1, min=1, max=2, table = { "Off", "On" }},
         { x = 45,  y = 25,  i=2, min=0, max=490 },
         { x = 80,  y = 25,  i=3, min=0, max=490 },
         { x = 15,  y = 38,  i=4, min=1, max=2, table = { "Off", "On" }},
         { x = 45,  y = 38,  i=5, min=0, max=490 },
         { x = 80,  y = 38,  i=6, min=0, max=490 },
         { x = 15,  y = 52,  i=7, min=1, max=7, table = { "Off", "High", "MedHi", "Med", "MedLo", "Low", "VerLo" } },
         { x = 80,  y = 52,  i=8, min=0, max=97},
      }, 
	  wrName = {},
		varName = {},
		dL = 48,
		data = {},
	  defValues = "Default___   1  92   0   0 200   0 100   0   0 200   0 100",
      read  = KISS_GET_FILTERS,
      write = KISS_SET_FILTERS,
      postRead = postReadFilters,
      getWriteValues = getWriteValuesFilters
   },
   {
       title = "TPA",
       text = {
 		 { t = "P", 	x = 45, y = 10 },
          { t = "I", 	x = 78, y = 10 },
          { t = "D", 	x = 107,y = 10 },
          { t = "TPA",  	x = 3,  y = 20 },
		  { t = "Custom TPA", x = 3,  y = 33},
 		 { t = "Thr%",  x = 3,  y = 43 },
		 { t = "0",  	x = 38,  y = 43 },
 		 { t = "100",   x = 100, y = 43 },
 		 { t = "Inf%",  x = 3, y = 53 },
 	  },
 	  lines = {
       	 { x1 = 3, y1 = 30, x2 = 122, y2 = 30 }
       },
       fields = {
          -- TPA
          { x = 20,  y = 20, i=1, max=900, prec=2 },
          { x = 48,  y = 20, i=2, max=900, prec=2 },
          { x = 80,  y = 20, i=3, max=900, prec=2 },
 		 { x = 80,  y = 33, i=4, min=1, max=2, table = { "Off", "On" } },
 		 { x = 35,   y = 43, i=5, max=100},
 		 { x = 58,   y = 43, i=6, max=100},
 		 { x = 12,   y = 53, i=7, max=100},
 		 { x = 35,   y = 53, i=8, max=100},
 		 { x = 58,   y = 53, i=9, max=100},
 		 { x = 80,   y = 53, i=10,max=100},
       },
       wrName = {},
		dL = 52,
		data = {},
		defValues = "Default___   1 144   0 200   1 144   0  30  50  30   0   0 100",
      read  = KISS_GET_TPA,
       write = KISS_SET_TPA,
       postRead = postReadTPA,
       getWriteValues = getWriteValuesTPA
    },
	{
      title = "Alarms",
      text = {},
      fields = {
         -- Alarms
         { t = "VBat",    x = 15,  y = 27, sp = 70, i=1, min=0, max=26000, prec=1 },
         { t = "mAH",     x = 15,  y = 40, sp = 70, i=2, min=0, max=26000, inc=10 }
      },
	  wrName = {},
		dL = 16,
		data = {},
	  defValues = "Default___   0 144   3 232",
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
         { t = "Band",    	   x = 15,  y = 14, sp = 70, i=2, min=1, max=5, table = { "A", "B", "E", "FS", "RB" } },
         { t = "Channel",      x = 15,  y = 27, sp = 70, i=3, min=1, max=8 },
         { t = "Low Power",    x = 15,  y = 40, sp = 70, i=4, min=0, max=600 },
         { t = "High Power",   x = 15,  y = 53, sp = 70, i=5, min=0, max=600 }
      },
      read  = KISS_GET_VTX_CONFIG,
      write = KISS_SET_VTX_CONFIG,
      postRead = postReadVTX,
      getWriteValues = getWriteValuesVTX
   },
   
   {
      title = "Memory Saved:  ",
      text = {
		{ t = "1:", x = 10, y = 13 },
		{ t = "2:", x = 10, y = 23 },
		{ t = "3:", x = 10, y = 33 },
		{ t = "4:", x = 10, y = 43 },
		{ t = "5:", x = 10, y = 53 }
		},
      fields = {
         -- model data
         {t="1",  d="",  x = 20, y = 13, sp = 12, i=1, min=1, max=500 },
         {t="2",  d="",  x = 20, y = 23, sp = 12, i=2, min=1, max=500 },
         {t="3",  d="",  x = 20, y = 33, sp = 12, i=3, min=0, max=600 },
         {t="4",  d="",  x = 20, y = 43, sp = 12, i=4, min=0, max=600 },
		 {t="5",  d="",  x = 20, y = 53, sp = 12, i=5, min=0, max=600 }
      },
      read  = select_model_load,
      write = select_model_save
   }
}
	

local drawScreenTitle = function(screen_title, currentPage,ofPage)
	lcd.drawScreenTitle('Kiss Setup:  '..screen_title,currentPage,ofPage)
end

local drawTelemetry = function()
	lcd.drawText(35,55,"No telemetry",BLINK)
end

local drawSaving = function() 
	lcd.drawFilledRectangle(6,12,120,30,ERASE)
	lcd.drawRectangle(6,12,120,30,SOLID)
	lcd.drawText(34,18,"Saving...", DBLSIZE + BLINK)
end

local function drawMenu()
local vTx
if currentPage == #(SetupPages)-1 then vTx = 2 else vTx = #(menuList) end
local x = 3
local y = 11
local w = 123
local h = vTx * 8 + 10
lcd.drawFilledRectangle(x-2,y-2,w+4,h+4,ERASE)
lcd.drawRectangle(x-2,y-2,w+3,h+3,SOLID)
lcd.drawRectangle(x,y,w-1,h-1,SOLID)
lcd.drawText(x+4,y+3,"Menu: ", INVERS)

if currentPage #(SetupPages)-1 then e = 2 end

for i,e in ipairs(menuList) do
	if vTx == 2 and i == 3 then break end
	if menuActive == i then
		lcd.drawText(x+36,y+(i-1)*9+3,e.t,INVERS)
	else
		lcd.drawText(x+36,y+(i-1)*9+3,e.t)
	end
end
end

local function getDefaultTextOptions() 
	return 0
end


local function drawEditMenu()
	
local x = 3
local y = 11
local w = 123
local h = 38
lcd.drawFilledRectangle(x-2,y-2,w+4,h+4,ERASE)
lcd.drawRectangle(x-2,y-2,w+3,h+3,SOLID)
lcd.drawRectangle(x,y,w-1,h-1,SOLID)
lcd.drawFilledRectangle(x+2,y+2,w-5,10, SOLID)
lcd.drawText(x+5,y+3,CP.title.." Set: ",INVERS)
lcd.drawText(lcd.getLastPos() + 20, y+3, currentLine, INVERS)
lcd.drawText(x+4,y+16,"Name:  ")
for i = 0,9 do
	lcd.drawText ( x+36+i*6,y+16,CPvN[i+1],getFieldFlags(i))
end
lcd.drawText(x+6, y+27, "[SAVE NAME]", getFieldFlags(10))
lcd.drawText(x+78, y+27, "[..LOAD..]", getFieldFlags(11))
end