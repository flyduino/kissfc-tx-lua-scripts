return {
    read = 0x4B,
    write = 0x4C,
    postRead = function(values)
        local ret = {}
        for i = 1, 3 do
            ret[i] = bit32.lshift(values[(i - 1) * 2 + 1], 8) + values[(i - 1) * 2 + 2]
        end
        ret[4] = values[7] + 1
        for i = 5, 10 do
            ret[i] = values[i + 3]
        end
        return ret
    end,
    preWrite = function(values)
        local ret = {}
        for i = 1, 3 do
            ret[(i - 1) * 2 + 1] = bit32.rshift(values[i], 8)
            ret[(i - 1) * 2 + 2] = bit32.band(values[i], 0xFF)
        end
        ret[7] = bit32.band(values[4] - 1, 0xFF)
        for i = 5, 10 do
            ret[i + 3] = bit32.band(values[i], 0xFF)
        end
        return ret
    end,
    title = 'TPA',
    text = {
        {t = 'P', x = 151, y = 68},
        {t = 'I', x = 229, y = 68},
        {t = 'D', x = 309, y = 68},
        {t = 'TPA', x = 35, y = 96},
        {t = '0', x = 151, y = 162},
        {t = '100', x = 309, y = 162},
        {t = 'Throttle %', x = 35, y = 162},
        {t = 'Influence%', x = 35, y = 190}
    },
    lines = {
        {x1 = 30, y1 = 125, x2 = 350, y2 = 125}
    },
    fields = {
        -- TPA
        {x = 129, y = 96, i = 1, max = 900, prec = 2},
        {x = 209, y = 96, i = 2, max = 900, prec = 2},
        {x = 289, y = 96, i = 3, max = 900, prec = 2},
        {t = 'Custom TPA', x = 35, y = 134, sp = 115, i = 4, min = 1, max = 2, table = {'Off', 'On'}},
        {x = 190, y = 162, i = 5, max = 100},
        {x = 240, y = 162, i = 6, max = 100},
        {x = 129, y = 190, i = 7, max = 100},
        {x = 190, y = 190, i = 8, max = 100},
        {x = 240, y = 190, i = 9, max = 100},
        {x = 289, y = 190, i = 10, max = 100}
    }
}
