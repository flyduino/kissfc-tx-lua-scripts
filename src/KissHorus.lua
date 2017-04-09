local RADIO = "HORUS"

SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "P",      x = 129,  y =  68 },
         { t = "I",      x = 209,  y =  68 },
         { t = "D",      x = 289,  y =  68 },
         { t = "ROLL",   x =  35,  y =  96 },
         { t = "PITCH",  x =  35,  y = 124 },
         { t = "YAW",    x =  35,  y = 152 }
      },
      fields = {
         -- P
         { x = 129,  y =  96, i=1, max=65000, prec=2 },
         { x = 129,  y = 124, i=4, max=65000, prec=2 },
         { x = 129,  y = 152, i=7, max=65000, prec=2 },
         -- I
         { x = 209,  y =  96, i=2, max=65000, prec=3 },
         { x = 209,  y = 124, i=5, max=65000, prec=3 },
         { x = 209,  y = 152, i=8, max=65000, prec=3 },
         -- D
         { x = 289,  y =  96, i=3, max=65000, prec=2 },
         { x = 289,  y = 124, i=6, max=65000, prec=2 },
         { x = 289,  y = 152, i=9, max=65000, prec=2 }
      },
      read  = KISS_GET_PIDS,
      write = KISS_SET_PIDS,
      postRead = postReadPIDS,
      getWriteValues = getWriteValuesPIDS
   },
   {
      title = "Rates",
      text = {
         { t = "RC Rate", x = 129,  y = 68 },
         { t = "Rate",    x = 209, y = 68 },
         { t = "RC Curve", x = 289, y = 68 },
         { t = "Roll",  x = 35,  y = 96 },
         { t = "Pitch", x = 35,  y = 124 },
         { t = "Yaw",   x = 35,  y = 152 }
      },
      fields = {
         -- RC Rate
         { x = 129,  y = 96, i=1, max=65000, prec=2 },
         { x = 209,  y = 96, i=2, max=65000, prec=2 },
         { x = 289, y = 96, i=3, max=65000, prec=2 },
         -- Rate
         { x = 129,  y = 124, i=4, max=65000, prec=2 },
         { x = 209,  y = 124, i=5, max=65000, prec=2 },
         { x = 289, y = 124, i=6, max=65000, prec=2 },
         -- RC Curve
         { x = 129,  y = 152, i=7, max=65000, prec=2 },
         { x = 209,  y = 152, i=8, max=65000, prec=2 },
         { x = 289, y = 152, i=9, max=65000, prec=2 }
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
         { t = "Center", x = 180, y = 68 },
         { t = "Cutoff", x = 280, y = 68 },
         { t = "Notch Filter", x = 70,  y = 68 },
         { t = "Roll",  x = 35,  y = 96 },
         { t = "Pitch", x = 35,  y = 124 },
         { t = "LPF",   x = 35,  y = 158 },
         { t = "Yaw",   x = 35, y = 186 }
      },
      lines = {
      	 { x1 = 4, y1 = 48, x2 = 190, y2 = 48 }
      },
      fields = {
         -- Filters
         { x = 100,  y = 96,  i=1, min=1, max=2, table = { "Off", "On" }},
         { x = 180,  y = 96,  i=2, min=0, max=490 },
         { x = 280, y = 96,  i=3, min=0, max=490 },
         { x = 100,  y = 124,  i=4, min=1, max=2, table = { "Off", "On" }},
         { x = 180,  y = 124,  i=5, min=0, max=490 },
         { x = 280, y = 124,  i=6, min=0, max=490 },
         { x = 100,  y = 158,  i=7, min=1, max=7, table = { "Off", "High", "Med. High", "Medium", "Med. Low", "Low", "Very Low" } },
         { x = 100, y = 186,  i=8, min=0, max=97},
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
         { t = "VBat",    x = 100,  y = 96, sp = 60, i=1, min=0, max=26000, prec=1 },
         { t = "mAH",     x = 250, y = 96, sp = 60, i=2, min=0, max=26000, inc=10 }
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
         { t = "Band",    	   x = 35,  y = 96, sp = 100, i=2, min=1, max=5, table = { "A", "B", "E", "FS", "RB" } },
         { t = "Channel",      x = 210, y = 96, sp = 120, i=3, min=1, max=8 },
         { t = "Low Power",    x = 35,  y = 158, sp = 100, i=4, min=0, max=600 },
         { t = "High Power",   x = 210, y = 158, sp = 120, i=5, min=0, max=600 }
      },
      read  = KISS_GET_VTX_CONFIG,
      write = KISS_SET_VTX_CONFIG,
      postRead = postReadVTX,
      getWriteValues = getWriteValuesVTX
   }
}

local drawScreenTitle = function(title, currentPage)
	lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
	lcd.drawText(1, 5, title, MENU_TITLE_COLOR)
end

local drawTelemetry = function()
	lcd.drawText(192,LCD_H - 28,"No telemetry",TEXT_COLOR + INVERS + BLINK)
end

local drawSaving = function()
	lcd.drawFilledRectangle(120,100,180,60,TEXT_BGCOLOR)
	lcd.drawRectangle(120,100,180,60,SOLID)
	lcd.drawText(120+12,100+12,"Saving...",DBLSIZE + BLINK + (TEXT_COLOR))
end

local function drawMenu(menuList, menuActive)
   local x = 120
   local y = 100
   local w = 200
   local x_offset = 68
   local h_line = 20
   local h_offset = 6
   local h = #(menuList) * h_line + h_offset*2

   lcd.drawFilledRectangle(x,y,w,h,TEXT_BGCOLOR)
   lcd.drawRectangle(x,y,w-1,h-1,LINE_COLOR)
   lcd.drawText(x+h_line/2,y+h_offset,"Menu:", TEXT_COLOR)

   for i,e in ipairs(menuList) do
      local text_options = TEXT_COLOR
      if menuActive == i then
         text_options = text_options + INVERS
      end
      lcd.drawText(x+x_offset,y+(i-1)*h_line+h_offset,e.t,text_options)
   end
end

local function getDefaultTextOptions() 
	return TEXT_COLOR
end
