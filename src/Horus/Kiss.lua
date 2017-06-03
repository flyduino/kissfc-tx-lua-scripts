-- BEGIN HORUS

local RADIO = "HORUS"

local drawScreenTitle = function(title, currentPage, totalPages)
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

-- END HORUS

