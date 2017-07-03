-- BEGIN HORUS

local RADIO = "HORUS"

local drawScreenTitle = function(title, currentPage, totalPages)
   lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
   lcd.drawText(1, 5, title, MENU_TITLE_COLOR)
end

local drawScreenTitle = function(title, cPage, tPages)
 local str
 if cPage == #(AllPages) then
	str = "Mem: "..CP.title 
	cPage = 0
	tPages = 0
 else     
	str = "Kiss Setup:  "
 end
 lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
  lcd.drawText(1,5,str..title,MENU_TITLE_COLOR)
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
 local vTx
if ActivePage.title== "VTX" then vTx = 2 else vTx = #(menuList) end

  local x = 120
  local y = 100
  local w = 240
  local x_offset = 68
  local h_line = 20
  local h_offset = 6
  local h = vTx * h_line + h_offset*2

lcd.drawFilledRectangle(x-2,y-2,w+4,h+4,ERASE)
lcd.drawRectangle(x-2,y-2,w+3,h+3,SOLID)
lcd.drawRectangle(x,y,w-1,h-1,SOLID)
lcd.drawText(x+4,y+3,"Menu: ", INVERS)
  
  lcd.drawFilledRectangle(x,y,w,h,TEXT_BGCOLOR)
  lcd.drawRectangle(x,y,w-1,h-1,LINE_COLOR)
  lcd.drawText(x+h_line/2,y+h_offset,"Menu:", TEXT_COLOR)

  for i,e in ipairs(menuList) do
    local text_options = TEXT_COLOR
	if vTx == 2 and i == 3 then break end
    if menuActive == i then
      text_options = text_options + INVERS
    end
    lcd.drawText(x+x_offset,y+(i-1)*h_line+h_offset,e.t,text_options)
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
local x = 30
local y = 60
local w = 240
local h = 120

lcd.drawFilledRectangle(x,y,w,h,TEXT_BGCOLOR)
lcd.drawRectangle(x,y,w,h,LINE_COLOR)
lcd.drawRectangle(x+1,y+1,w-2,h-3,LINE_COLOR)

lcd.drawText(x+5,y+3,CP.title.." Set: ",TEXT_COLOR)
lcd.drawText(x + w - 30, y+3, currentLine, TEXT_COLOR)
lcd.drawText(x+4,y+32,"Name:  ")
for i = 0,9 do
	lcd.drawText ( x+80+i*15,y+32,CPvN[i+1],getFieldFlags(i))
end
lcd.drawText(x+6, y+80, "[SAVE NAME]", getFieldFlags(10))
lcd.drawText(x+w-90, y+80, "[..LOAD..]", getFieldFlags(11))

end

local function getDefaultTextOptions()
  return TEXT_COLOR
end

-- END HORUS

