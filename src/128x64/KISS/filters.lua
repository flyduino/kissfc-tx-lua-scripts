return {
  read  = 0x47,
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
    ret[1] = bit32.band(values[7]-1, 0xFF)
    ret[2] = bit32.band(values[8], 0xFF)
    ret[3] = bit32.band(values[1]-1, 0xFF);
    ret[4] = bit32.band(bit32.rshift(values[2], 8), 0xFF)
    ret[5] = bit32.band(values[2], 0xFF)
    ret[6] = bit32.band(bit32.rshift(values[3], 8), 0xFF)
    ret[7] = bit32.band(values[3], 0xFF)
    ret[8] = bit32.band(values[4]-1, 0xFF);
    ret[9] = bit32.band(bit32.rshift(values[5], 8), 0xFF)
    ret[10] = bit32.band(values[5], 0xFF)
    ret[11] = bit32.band(bit32.rshift(values[6], 8), 0xFF)
    ret[12] = bit32.band(values[6], 0xFF)
    ret[13] = bit32.band(values[9]-1, 0xFF)
    ret[14] = bit32.band(values[10]-1, 0xFF)
    return ret
  end,
  title = "Filters",
  text = {
    { t = "Center",      x = 50, y = 10 },
    { t = "Cutoff",      x = 90, y = 10 },
    { t = "Notch",       x = 3,  y = 10 },
    { t = "Roll",        x = 3,  y = 20 },
    { t = "Pitch",       x = 3,  y = 30 },
    { t = "R/P",         x = 3,  y = 42 },
    { t = "Yaw f.",      x = 65, y = 42 },
    { t = "Yaw",         x = 3,  y = 52 },
    { t = "Dterm",       x = 65, y = 52 }
  },
  lines = {
    { x1 = 1, y1 = 39, x2 = 125, y2 = 39 }
  },
  fields = {
    -- Filters
    { x = 15,  y = 20,  i=1,  min=1, max=2, table = { "Off", "On" }},
    { x = 45,  y = 20,  i=2,  min=0, max=490 },
    { x = 80,  y = 20,  i=3,  min=0, max=490 },
    { x = 15,  y = 30,  i=4,  min=1, max=2, table = { "Off", "On" }},
    { x = 45,  y = 30,  i=5,  min=0, max=490 },
    { x = 80,  y = 30,  i=6,  min=0, max=490 },
    { x = 15,  y = 42,  i=7,  min=1, max=7, table = { "Off", "High", "MedHi", "Med", "MedLo", "Low", "VerLo" } },
    { x = 80,  y = 42,  i=8,  min=0, max=97},
    { x = 15,  y = 52,  i=9,  min=1, max=7, table = { "Off", "High", "MedHi", "Med", "MedLo", "Low", "VerLo" } },
    { x = 80,  y = 52,  i=10, min=1, max=7, table = { "Off", "High", "MedHi", "Med", "MedLo", "Low", "VerLo" } },
  }
}
