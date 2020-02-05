return {
    read = 0x47,
    write = 0x48,
    postRead = function(values)
        local ret = {}
        ret[1] = values[3] + 1
        ret[2] = bit32.lshift(values[4], 8) + values[5]
        ret[3] = bit32.lshift(values[6], 8) + values[7]
        ret[4] = values[8] + 1
        ret[5] = bit32.lshift(values[9], 8) + values[10]
        ret[6] = bit32.lshift(values[11], 8) + values[12]
        ret[7] = values[1] + 1
        ret[8] = values[2]
        ret[9] = values[13] + 1
        ret[10] = values[14] + 1
        return ret
    end,
    preWrite = function(values)
        local ret = {}
        ret[1] = bit32.band(values[7] - 1, 0xFF)
        ret[2] = bit32.band(values[8], 0xFF)
        ret[3] = bit32.band(values[1] - 1, 0xFF)
        ret[4] = bit32.band(bit32.rshift(values[2], 8), 0xFF)
        ret[5] = bit32.band(values[2], 0xFF)
        ret[6] = bit32.band(bit32.rshift(values[3], 8), 0xFF)
        ret[7] = bit32.band(values[3], 0xFF)
        ret[8] = bit32.band(values[4] - 1, 0xFF)
        ret[9] = bit32.band(bit32.rshift(values[5], 8), 0xFF)
        ret[10] = bit32.band(values[5], 0xFF)
        ret[11] = bit32.band(bit32.rshift(values[6], 8), 0xFF)
        ret[12] = bit32.band(values[6], 0xFF)
        ret[13] = bit32.band(values[9] - 1, 0xFF)
        ret[14] = bit32.band(values[10] - 1, 0xFF)
        return ret
    end,
    title = 'Filters',
    text = {
        {t = 'Center', x = 100, y = 10},
        {t = 'Cutoff', x = 150, y = 10},
        {t = 'Notch Filter', x = 10, y = 10},
        {t = 'Roll', x = 10, y = 21},
        {t = 'Pitch', x = 10, y = 32},
        {t = 'R/P LPF', x = 10, y = 44},
        {t = 'Yaw Filter', x = 110, y = 44},
        {t = 'Yaw LPF', x = 10, y = 55},
        {t = 'Dterm LPF', x = 110, y = 55}
    },
    lines = {
        {x1 = 1, y1 = 41, x2 = 210, y2 = 41}
    },
    fields = {
        {x = 35, y = 21, i = 1, min = 1, max = 2, table = {'Off', 'On'}},
        {x = 90, y = 21, i = 2, min = 0, max = 490},
        {x = 145, y = 21, i = 3, min = 0, max = 490},
        {x = 35, y = 32, i = 4, min = 1, max = 2, table = {'Off', 'On'}},
        {x = 90, y = 32, i = 5, min = 0, max = 490},
        {x = 145, y = 32, i = 6, min = 0, max = 490},
        {
            x = 35,
            y = 44,
            i = 7,
            min = 1,
            max = 7,
            table = {'Off', 'High', 'Med. High', 'Medium', 'Med. Low', 'Low', 'Very Low'}
        },
        {x = 145, y = 44, i = 8, min = 0, max = 97},
        {
            x = 35,
            y = 55,
            i = 9,
            min = 1,
            max = 7,
            table = {'Off', 'High', 'Med. High', 'Medium', 'Med. Low', 'Low', 'Very Low'}
        },
        {
            x = 145,
            y = 55,
            i = 10,
            min = 1,
            max = 7,
            table = {'Off', 'High', 'Med. High', 'Medium', 'Med. Low', 'Low', 'Very Low'}
        }
    }
}
