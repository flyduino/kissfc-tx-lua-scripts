local RADIO = "TARANIS"

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
        -- { t = "Notch",  x = 47,  y = 14 },
         { t = "Center", x = 100, y = 14 },
         { t = "Cutoff", x = 150, y = 14 },
         { t = "Notch Filter", x = 10,  y = 14 },
         { t = "Roll",  x = 10,  y = 25 },
         { t = "Pitch", x = 10,  y = 38 },
         { t = "LPF",   x = 10,  y = 52 },
         { t = "Yaw",   x = 110, y = 52 }
      },
      lines = {
      	 { x1 = 4, y1 = 48, x2 = 190, y2 = 48 }
      },
      fields = {
         -- Filters
         { x = 35,  y = 25,  i=1, min=1, max=2, table = { "Off", "On" }},
         { x = 90,  y = 25,  i=2, min=0, max=490 },
         { x = 145, y = 25,  i=3, min=0, max=490 },
         { x = 35,  y = 38,  i=4, min=1, max=2, table = { "Off", "On" }},
         { x = 90,  y = 38,  i=5, min=0, max=490 },
         { x = 145, y = 38,  i=6, min=0, max=490 },
         { x = 35,  y = 52,  i=7, min=1, max=7, table = { "Off", "High", "Med. High", "Medium", "Med. Low", "Low", "Very Low" } },
         { x = 145, y = 52,  i=8, min=0, max=97},
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

local drawScreenTitle = function(screen_title, currentPage)
	lcd.drawScreenTitle('Kiss Setup:  '..screen_title,currentPage,#(SetupPages))
end

local drawTelemetry = function()
	lcd.drawText(75,55,"No telemetry",BLINK)
end

local drawSaving = function() 
	lcd.drawFilledRectangle(6,12,120,30,ERASE)
    lcd.drawRectangle(6,12,120,30,SOLID)
    lcd.drawText(34,18,"Saving...", DBLSIZE + BLINK)
end

local function drawMenu(menuList)
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

local function getDefaultTextOptions() 
	return 0
end

local EVT_MENU_LONG = bit32.bor(bit32.band(EVT_MENU_BREAK,0x1f),0x80)


