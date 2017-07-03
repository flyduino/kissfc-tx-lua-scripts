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
    { t = "RC Rate",  x = 139, y = 68 },
    { t = "Rate",     x = 227, y = 68 },
    { t = "RC Curve", x = 289, y = 68 },
    { t = "Roll",     x = 35,  y = 96 },
    { t = "Pitch",    x = 35,  y = 124 },
    { t = "Yaw",      x = 35,  y = 152 }
  },
  fields = {
    -- RC Rate
    { x = 129,  y = 96, i=1, max=65000, prec=2 },
    { x = 209,  y = 96, i=2, max=65000, prec=2 },
    { x = 289,  y = 96, i=3, max=65000, prec=2 },
    -- Rate
    { x = 129,  y = 124, i=4, max=65000, prec=2 },
    { x = 209,  y = 124, i=5, max=65000, prec=2 },
    { x = 289,  y = 124, i=6, max=65000, prec=2 },
    -- RC Curve
    { x = 129,  y = 152, i=7, max=65000, prec=2 },
    { x = 209,  y = 152, i=8, max=65000, prec=2 },
    { x = 289,  y = 152, i=9, max=65000, prec=2 }
  },
  wrName = {},
  dL = 45,
  data = {},
  defValues= "Default___   70   70   40   70   70   40   70   70   40"
}
