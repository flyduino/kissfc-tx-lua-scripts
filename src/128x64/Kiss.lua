-- BEGIN 128x64

local RADIO = '128x64'

local drawScreenTitle = function(title, currentPage, totalPages)
    lcd.drawScreenTitle('KISS: ' .. title, currentPage, totalPages)
end

local drawTelemetry = function()
    lcd.drawText(35, 55, 'No telemetry', BLINK)
end

local drawSaving = function()
    lcd.drawFilledRectangle(6, 12, 120, 30, ERASE)
    lcd.drawRectangle(6, 12, 120, 30, SOLID)
    lcd.drawText(34, 18, 'Saving...', DBLSIZE + BLINK)
end

local function drawMenu(menuList, menuActive)
    local x = 6
    local y = 12
    local w = 120
    local h = #(menuList) * 8 + 6
    lcd.drawFilledRectangle(x, y, w, h, ERASE)
    lcd.drawRectangle(x, y, w - 1, h - 1, SOLID)
    lcd.drawText(x + 4, y + 3, 'Menu:')

    for i, e in ipairs(menuList) do
        if menuActive == i then
            lcd.drawText(x + 36, y + (i - 1) * 8 + 3, e.t, INVERS)
        else
            lcd.drawText(x + 36, y + (i - 1) * 8 + 3, e.t)
        end
    end
end

local function getDefaultTextOptions()
    return 0
end

-- END 128x64
