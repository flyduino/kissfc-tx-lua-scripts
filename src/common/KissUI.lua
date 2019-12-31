-- BEGIN UI

local currentPage = 1
local currentLine = 1
local saveTS = 0
local saveTimeout = 0
local saveRetries = 0
local saveMaxRetries = 0

local REQ_TIMEOUT = 200 -- 1000ms request timeout

--local PAGE_REFRESH = 1
local PAGE_DISPLAY = 2
local EDITING = 3
local PAGE_SAVING = 4
local MENU_DISP = 5

local telemetryScreenActive = false
local menuActive = false
local lastRunTS = 0

local gState = PAGE_DISPLAY
ActivePage = nil

AllPages = {'pids', 'rates', 'tpa', 'filters', 'alarms', 'vtx', 'setpnt'}

local function formatKissFloat(v, d)
    local s = string.format('%0.4d', v)
    local part1 = string.sub(s, 1, string.len(s) - 3)
    local part2 = string.sub(string.sub(s, -3), 1, d)
    if d > 0 then
        return part1 .. '.' .. part2
    else
        return part1
    end
end

local function clearTable(t)
    if type(t) == 'table' then
        for i, v in pairs(t) do
            if type(v) == 'table' then
                clearTable(v)
            end
            t[i] = nil
        end
    end
    collectgarbage()
    return t
end

local function saveSettings(new)
    if ActivePage.values then
        if ActivePage.preWrite then
            kissSendRequest(ActivePage.write, ActivePage.preWrite(ActivePage.values))
        else
            kissSendRequest(ActivePage.write, ActivePage.values)
        end
        saveTS = getTime()
        if gState == PAGE_SAVING then
            saveRetries = saveRetries + 1
        else
            gState = PAGE_SAVING
            saveRetries = 0
            saveMaxRetries = ActivePage.saveMaxRetries or 2 -- default 2
            saveTimeout = ActivePage.saveTimeout or 400 -- default 4s
        end
    end
end

local function invalidatePage()
    ActivePage.values = nil
    gState = PAGE_DISPLAY
    saveTS = 0
end

local function loadPage(pageId)
    local file = '/KISS/' .. AllPages[pageId] .. '.lua'
    clearTable(ActivePage)
    local tmp = assert(loadScript(file))
    ActivePage = tmp()
end

local menuList = {
    {t = 'save page', f = saveSettings},
    {t = 'reload', f = invalidatePage}
}

local function processKissReply(cmd, rx_buf)
    if cmd == nil or rx_buf == nil then
        return
    end

    -- response on saving
    if cmd == ActivePage.write then
        gState = PAGE_DISPLAY
        ActivePage.values = nil
        saveTS = 0
        return
    end

    if cmd ~= ActivePage.read then
        return
    end

    if #(rx_buf) > 0 then
        ActivePage.values = {}
        for i = 1, #(rx_buf) do
            ActivePage.values[i] = rx_buf[i]
        end

        if ActivePage.postRead ~= nil then
            ActivePage.values = ActivePage.postRead(ActivePage.values)
        end
    end
end

local function MaxLines()
    return #(ActivePage.fields)
end

local function changeWithLimit(value, direction, min, max)
    local tmp = value + direction
    if tmp > max and direction > 0 then
        tmp = min
    elseif tmp < 1 and direction < 0 then
        tmp = max
    end
    return tmp
end

local function incPage(inc)
    currentPage = changeWithLimit(currentPage, inc, 1, #(AllPages))
    loadPage(currentPage)
end

local function incLine(inc)
    currentLine = changeWithLimit(currentLine, inc, 1, MaxLines())
end

local function incMenu(inc)
    menuActive = changeWithLimit(menuActive, inc, 1, #(menuList))
end

local function requestPage()
    if ActivePage.read and ((ActivePage.reqTS == nil) or (ActivePage.reqTS + REQ_TIMEOUT <= getTime())) then
        ActivePage.reqTS = getTime()
        kissSendRequest(ActivePage.read, {})
    end
end

local function drawScreen(page_locked)
    drawScreenTitle(ActivePage.title, currentPage, #(AllPages))

    for i = 1, #(ActivePage.text) do
        local f = ActivePage.text[i]
        if f.to == nil then
            lcd.drawText(f.x, f.y, f.t, getDefaultTextOptions())
        else
            lcd.drawText(f.x, f.y, f.t, f.to)
        end
    end

    if ActivePage.lines ~= nil then
        for i = 1, #(ActivePage.lines) do
            local f = ActivePage.lines[i]
            lcd.drawLine(f.x1, f.y1, f.x2, f.y2, SOLID, 0)
        end
    end

    for i = 1, #(ActivePage.fields) do
        local f = ActivePage.fields[i]

        local text_options = getDefaultTextOptions()
        if i == currentLine then
            text_options = INVERS
            if gState == EDITING then
                text_options = text_options + BLINK
            end
        end

        local spacing = 20

        if f.t ~= nil then
            lcd.drawText(f.x, f.y, f.t .. ':', getDefaultTextOptions())
        end

        -- draw some value
        if f.sp ~= nil then
            spacing = f.sp
        end

        local idx = f.i or i
        if ActivePage.values and ActivePage.values[idx] then
            local val = ActivePage.values[idx]
            if f.table and f.table[ActivePage.values[idx]] then
                val = f.table[ActivePage.values[idx]]
            end

            if f.prec ~= nil then
                val = formatKissFloat(val, f.prec, f.base)
            end

            lcd.drawText(f.x + spacing, f.y, val, text_options)
        else
            lcd.drawText(f.x + spacing, f.y, '---', text_options)
        end
    end

    if ActivePage.customDraw ~= nil then
        ActivePage.customDraw()
    end
end

local function clipValue(val, min, max)
    if val < min then
        val = min
    elseif val > max then
        val = max
    end
    return val
end

local function getCurrentField()
    return ActivePage.fields[currentLine]
end

local function incValue(inc)
    local field = ActivePage.fields[currentLine]
    local idx = field.i or currentLine

    local tmpInc = inc
    if field.prec ~= nil then
        tmpInc = tmpInc * 10 ^ (3 - field.prec)
    end

    if field.inc ~= nil then
        tmpInc = tmpInc * field.inc
    end

    ActivePage.values[idx] = clipValue(ActivePage.values[idx] + tmpInc, field.min or 0, field.max or 255)
end

local function run(event)
    if ActivePage == nil then
        loadPage(currentPage)
    end

    local now = getTime()

    -- if lastRunTS old than 500ms
    if lastRunTS + 50 < now then
        invalidatePage()
    end
    lastRunTS = now

    if (gState == PAGE_SAVING) and (saveTS + saveTimeout < now) then
        if saveRetries < saveMaxRetries then
            saveSettings()
        else
            -- max retries reached
            gState = PAGE_DISPLAY
            invalidatePage()
        end
    end

    if #(kissTxBuf) > 0 then
        kissProcessTxQ()
    end

    -- navigation
    if event == EVT_VIRTUAL_MENU_LONG or event == EVT_SHIFT_LONG then
        menuActive = 1
        gState = MENU_DISP
    elseif EVT_PAGEUP_FIRST and event == EVT_VIRTUAL_ENTER_LONG then
        -- menu is currently displayed
        menuActive = 1
        killEnterBreak = 1
        gState = MENU_DISP
    elseif gState == MENU_DISP then
        -- normal page viewing
        if event == EVT_EXIT_BREAK then
            gState = PAGE_DISPLAY
        elseif event == EVT_VIRTUAL_PREV then
            incMenu(-1)
        elseif event == EVT_VIRTUAL_NEXT then
            incMenu(1)
        elseif event == EVT_ENTER_BREAK then
            if RADIO == '480x272' then
                if killEnterBreak == 1 then
                    killEnterBreak = 0
                else
                    gState = PAGE_DISPLAY
                    menuList[menuActive].f()
                end
            else
                gState = PAGE_DISPLAY
                menuList[menuActive].f()
            end
        end
    elseif gState <= PAGE_DISPLAY then
        -- editing value
        if event == EVT_VIRTUAL_PREV_PAGE then
            incPage(-1)
        elseif event == EVT_VIRTUAL_NEXT_PAGE then
            incPage(1)
        elseif event == EVT_VIRTUAL_PREV or event == EVT_VIRTUAL_PREV_REPT then
            incLine(-1)
        elseif event == EVT_VIRTUAL_NEXT or event == EVT_VIRTUAL_NEXT_REPT then
            incLine(1)
        elseif event == EVT_VIRTUAL_ENTER then
            local field = ActivePage.fields[currentLine]
            local idx = field.i or currentLine
            if ActivePage.values and ActivePage.values[idx] and (field.ro ~= true) then
                gState = EDITING
            end
        end
    elseif gState == EDITING then
        if event == EVT_VIRTUAL_EXIT or event == EVT_VIRTUAL_ENTER then
            gState = PAGE_DISPLAY
        elseif event == EVT_VIRTUAL_INC then
            incValue(1)
        elseif event == EVT_VIRTUAL_INC_REP then
            incValue(10)
        elseif event == EVT_VIRTUAL_DEC then
            incValue(-1)
        elseif event == EVT_VIRTUAL_DEC_REPT then
            incValue(-10)
        end
    end

    local page_locked = false

    if ActivePage.values == nil then
        requestPage()
        page_locked = true
    end

    lcd.clear()
    drawScreen(page_locked)

    if isTelemetryPresent() ~= true then
        drawTelemetry()
        invalidatePage()
    end

    if gState == MENU_DISP then
        drawMenu(menuList, menuActive)
    elseif gState == PAGE_SAVING then
        drawSaving()
    end

    processKissReply(kissPollReply())
    return 0
end

return {run = run}

-- END UI
