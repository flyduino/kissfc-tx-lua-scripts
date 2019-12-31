return {
    read = 0x43,
    write = 0x44,
    postRead = function(values)
        local ret = {}
        for i = 0, 2 do
            ret[i * 3 + 1] = bit32.lshift(values[i * 6 + 1], 8) + values[i * 6 + 2]
            ret[i * 3 + 2] = bit32.lshift(values[i * 6 + 3], 8) + values[i * 6 + 4]
            ret[i * 3 + 3] = bit32.lshift(values[i * 6 + 5], 8) + values[i * 6 + 6]
        end
        return ret
    end,
    preWrite = function(values)
        local ret = {}
        for i = 0, 2 do
            ret[i * 6 + 1] = bit32.rshift(values[i * 3 + 1], 8)
            ret[i * 6 + 2] = bit32.band(values[i * 3 + 1], 0xFF)
            ret[i * 6 + 3] = bit32.rshift(values[i * 3 + 2], 8)
            ret[i * 6 + 4] = bit32.band(values[i * 3 + 2], 0xFF)
            ret[i * 6 + 5] = bit32.rshift(values[i * 3 + 3], 8)
            ret[i * 6 + 6] = bit32.band(values[i * 3 + 3], 0xFF)
        end
        return ret
    end,
    title = 'PIDs',
    text = {
        {t = 'P', x = 45, y = 14},
        {t = 'I', x = 78, y = 14},
        {t = 'D', x = 107, y = 14},
        {t = 'Roll', x = 3, y = 25},
        {t = 'Pitch', x = 3, y = 38},
        {t = 'Yaw', x = 3, y = 50}
    },
    fields = {
        {x = 20, y = 25, i = 1, max = 65000, prec = 2},
        {x = 48, y = 25, i = 2, max = 65000, prec = 3},
        {x = 80, y = 25, i = 3, max = 65000, prec = 2},
        {x = 20, y = 38, i = 4, max = 65000, prec = 2},
        {x = 48, y = 38, i = 5, max = 65000, prec = 3},
        {x = 80, y = 38, i = 6, max = 65000, prec = 2},
        {x = 20, y = 50, i = 7, max = 65000, prec = 2},
        {x = 48, y = 50, i = 8, max = 65000, prec = 3},
        {x = 80, y = 50, i = 9, max = 65000, prec = 2}
    }
}
