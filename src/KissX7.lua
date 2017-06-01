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
      read  = KISS_GET_PIDS,
      write = KISS_SET_PIDS,
      postRead = postReadPIDS,
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
      read  = KISS_GET_RATES,
      write = KISS_SET_RATES,
      postRead = postReadRates,
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
      read  = KISS_GET_FILTERS,
      write = KISS_SET_FILTERS,
      postRead = postReadFilters,
      getWriteValues = getWriteValuesFilters
   },
   {
      title = "TPA",
      text = {
         { t = "P",     x = 45, y = 10 },
         { t = "I",     x = 78, y = 10 },
         { t = "D",     x = 107,y = 10 },
         { t = "TPA",   x = 3,  y = 20 },
         { t = "0",     x = 35,  y = 43 },
         { t = "100",   x = 105, y = 43 },
         { t = "Thr%",  x = 3,  y = 43 },
         { t = "Inf%",  x = 3, y = 53 },
      },
      lines = {
         { x1 = 1, y1 = 30, x2 = 125, y2 = 30 }
      },
      fields = {
         -- TPA
         { x = 20,  y = 20, i=1, max=900, prec=2 },
         { x = 53,  y = 20, i=2, max=900, prec=2 },
         { x = 80,  y = 20, i=3, max=900, prec=2 },
         { t = "Custom TPA", x = 3,  y = 33, sp=65, i=4, min=1, max=2, table = { "Off", "On" } },
         { x = 38,   y = 43, i=5, max=100},
         { x = 61,   y = 43, i=6, max=100},
         { x = 15,   y = 53, i=7, max=100},
         { x = 38,   y = 53, i=8, max=100},
         { x = 61,   y = 53, i=9, max=100},
         { x = 85,   y = 53, i=10,max=100},
      },
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
   }
}

local drawScreenTitle = function(screen_title, currentPage)
     lcd.drawScreenTitle('Kiss Setup:  '..screen_title,currentPage,#(SetupPages))
end

local drawTelemetry = function()
	lcd.drawText(35,55,"No telemetry", BLINK)
end

local drawSaving = function()
    lcd.drawFilledRectangle(5,12,120,30, ERASE)
    lcd.drawRectangle(5,12,120,30, SOLID)
    lcd.drawText(33,18,"Saving...", DBLSIZE + BLINK)
end

local function drawMenu(menuList, menuActive)
   local x = 5
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

local function getDefaultTextOptions() 
	return 0
end

local EVT_MENU_LONG = bit32.bor(bit32.band(EVT_MENU_BREAK,0x1f),0x80)


