-- BEGIN X7

local RADIO = "X7"

local drawScreenTitle = function(title, cPage, tPages)
 local str
 if cPage == #(AllPages) then
	str = "Mem: "..CP.title 
	cPage = 0
	tPages = 0
 else     
	str = "Kiss Setup:  "
 end
  lcd.drawScreenTitle(str..title, cPage, tPages)
end

local drawTelemetry = function()
	lcd.drawText(35,55,"No telemetry", BLINK)
end

local drawSaving = function()
	lcd.drawFilledRectangle(6,12,120,30, ERASE)
	lcd.drawRectangle(6,12,120,30, SOLID)
	lcd.drawText(34,18,"Saving...", DBLSIZE + BLINK)
end

local function drawMenu(menuList, menuActive)
local vTx
if ActivePage.title== "VTX" then vTx = 2 else vTx = #(menuList) end

   local x = 4
   local y = 12
   local w = 120
   local h = vTx * 8 + 6
   lcd.drawFilledRectangle(x-2,y-2,w+4,h+4,ERASE)
   lcd.drawRectangle(x-2,y-2,w+3,h+3,SOLID)
   lcd.drawRectangle(x,y,w-1,h-1,SOLID)
   lcd.drawText(x+2,y+3,"Menu:")

   for i,e in ipairs(menuList) do
	if vTx == 2 and i == 3 then break end
      if menuActive == i then
	  if vTx == 2 and i == 3 then break end
         lcd.drawText(x+33,y+(i-1)*8+3,e.t,INVERS)
      else
         lcd.drawText(x+33,y+(i-1)*8+3,e.t)
      end
   end
end

local function getFieldFlags(p)
local flg = 0
if activeField==p then
	flg=INVERS
	if editMode then
		flg=INVERS+BLINK
	end
end
return flg
end

local function drawEditMenu()
currentLine = 1
local x = 6
local y = 12
local w = 120
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
lcd.drawText(x+5, y+26, "[SAVE NAME]", getFieldFlags(10))
lcd.drawText(x+75, y+26, "[..LOAD..]", getFieldFlags(11))

end

local function getDefaultTextOptions() 
	return 0
end

local EVT_MENU_LONG = bit32.bor(bit32.band(EVT_MENU_BREAK,0x1f),0x80)

-- END X7

