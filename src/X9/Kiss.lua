-- BEGIN X9



RADIO = "X9"

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
	lcd.drawText(75,55,"No telemetry",BLINK)
end

local drawSaving = function() 
	lcd.drawFilledRectangle(40,12,120,30,ERASE)
	lcd.drawRectangle(40,12,120,30,SOLID)
	lcd.drawText(64,18,"Saving...", DBLSIZE + BLINK)
end

local function drawMenu(menuList, menuActive)
 local vTx
if ActivePage.title== "VTX" then vTx = 2 else vTx = #(menuList) end

local x = 30
local y = 11
local w = 150
local h = vTx * 8 + 10
lcd.drawFilledRectangle(x-2,y-2,w+4,h+4,ERASE)
lcd.drawRectangle(x-2,y-2,w+3,h+3,SOLID)
lcd.drawRectangle(x,y,w-1,h-1,SOLID)
lcd.drawText(x+4,y+3,"Menu: ", INVERS)

for i,e in ipairs(menuList) do
	if vTx == 2 and i == 3 then break end
	if menuActive == i then
		lcd.drawText(x+50,y+(i-1)*9+3,e.t,INVERS)
	else
		lcd.drawText(x+50,y+(i-1)*9+3,e.t)
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
local x = 25
local y = 14
local w = 170
local h = 38
lcd.drawFilledRectangle(x-2,y-2,w+4,h+4,ERASE)
lcd.drawRectangle(x-2,y-2,w+3,h+3,SOLID)
lcd.drawRectangle(x,y,w-1,h-1,SOLID)
lcd.drawFilledRectangle(x+2,y+2,w-5,10, SOLID)
lcd.drawText(x+5,y+3,CP.title.." Set: ",INVERS)
lcd.drawText(lcd.getLastPos() + 20, y+3, currentLine, INVERS)
lcd.drawText(x+4,y+16,"Name:  ")
for i = 0,9 do
	lcd.drawText ( x+36+i*6,30,CPvN[i+1],getFieldFlags(i))
end
lcd.drawText(x+105, y+16, "[SAVE NAME]", getFieldFlags(10))
lcd.drawText(x+114, y+26, "[..LOAD..]", getFieldFlags(11))

end

local function getDefaultTextOptions() 
	return 0
end

local EVT_MENU_LONG = bit32.bor(bit32.band(EVT_MENU_BREAK,0x1f),0x80)

-- END X9