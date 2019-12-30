return {
  read  = 0x4D,
  write = 0x4E,
  
  postRead = function(values)
    local ret = {}
    for i=1,9 do
      ret[i] = bit32.lshift(values[(i-1)*2 + 1], 8) + values[(i-1)*2 + 2]
    end
    return ret
  end,
  preWrite = function(values)
    local ret = {}
    for i=1,9 do
      ret[(i-1)*2 + 1] = bit32.rshift(values[i], 8)
      ret[(i-1)*2 + 2] = bit32.band(values[i], 0xFF)
    end
    return ret
  end,
  title = "Rates",
  text = {
    { t = "RC",     x = 41, y = 14 },
    { t = "Rate",   x = 65, y = 14 },
    { t = "Curve",  x = 95, y = 14 },
    { t = "Roll",   x = 3,  y = 25 },
    { t = "Pitch",  x = 3,  y = 38 },
    { t = "Yaw",    x = 3,  y = 50 }
  },
  fields = {
    -- RC Rate
    { x = 16,  y = 25, i=1, max=65000, prec=2 },
    { x = 48,  y = 25, i=2, max=65000, prec=2 },
    { x = 80,  y = 25, i=3, max=65000, prec=2 },
    -- Rate
    { x = 16,  y = 38, i=4, max=65000, prec=2 },
    { x = 48,  y = 38, i=5, max=65000, prec=2 },
    { x = 80,  y = 38, i=6, max=65000, prec=2 },
    -- RC Curve
    { x = 16,  y = 50, i=7, max=65000, prec=2 },
    { x = 48,  y = 50, i=8, max=65000, prec=2 },
    { x = 80,  y = 50, i=9, max=65000, prec=2 }
  }
}
