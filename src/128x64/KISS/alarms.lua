return {
    read = 0x49,
    write = 0x4A,
    postRead = function(values)
        local ret = {}
        ret[1] = 100 * (bit32.lshift(values[1], 8) + values[2])
        ret[2] = bit32.lshift(values[3], 8) + values[4]
        return ret
    end,
    preWrite = function(values)
        local ret = {}
        local tmp = bit32.band(math.floor(values[1] / 100), 0xFFFF)
        ret[1] = bit32.band(bit32.rshift(tmp, 8), 0xFF)
        ret[2] = bit32.band(tmp, 0xFF)
        ret[3] = bit32.band(bit32.rshift(values[2], 8), 0xFF)
        ret[4] = bit32.band(values[2], 0xFF)
        return ret
    end,
    title = 'Alarms',
    text = {},
    fields = {
        {t = 'VBat', x = 15, y = 27, sp = 70, i = 1, min = 0, max = 26000, prec = 1},
        {t = 'mAH', x = 15, y = 40, sp = 70, i = 2, min = 0, max = 26000, inc = 10}
    }
}
