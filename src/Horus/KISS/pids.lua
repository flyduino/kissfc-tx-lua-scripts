return {
  read =  0x43,
  write = 0x44,

  postRead = function(values)
    local ret = {}
    for i=0,2 do
      ret[i*3+1] = bit32.lshift(values[i*6+1], 8) + values[i*6+2]
      ret[i*3+2] = bit32.lshift(values[i*6+3], 8) + values[i*6+4]
      ret[i*3+3] = bit32.lshift(values[i*6+5], 8) + values[i*6+6]
    end
    return ret
  end,

  preWrite = function(values)
    local ret = {}
    for i=0,2 do
      ret[i*6+1] = bit32.rshift(values[i*3+1], 8)
      ret[i*6+2] = bit32.band(values[i*3+1], 0xFF)
      ret[i*6+3] = bit32.rshift(values[i*3+2], 8)
      ret[i*6+4] = bit32.band(values[i*3+2], 0xFF)
      ret[i*6+5] = bit32.rshift(values[i*3+3], 8)
      ret[i*6+6] = bit32.band(values[i*3+3], 0xFF)
    end
    return ret
  end,
  
  title = "PIDs",
  text = {
    { t = "P",      x = 151,  y =  68 },
    { t = "I",      x = 229,  y =  68 },
    { t = "D",      x = 309,  y =  68 },
    { t = "Roll",   x =  35,  y =  96 },
    { t = "Pitch",  x =  35,  y = 124 },
    { t = "Yaw",    x =  35,  y = 152 }
  },
  fields = {
    -- P
    { x = 129,  y =  96, i=1, max=65000, prec=2 },
    { x = 129,  y = 124, i=4, max=65000, prec=2 },
    { x = 129,  y = 152, i=7, max=65000, prec=2 },
    -- I
    { x = 209,  y =  96, i=2, max=65000, prec=3 },
    { x = 209,  y = 124, i=5, max=65000, prec=3 },
    { x = 209,  y = 152, i=8, max=65000, prec=3 },
    -- D
    { x = 289,  y =  96, i=3, max=65000, prec=2 },
    { x = 289,  y = 124, i=6, max=65000, prec=2 },
    { x = 289,  y = 152, i=9, max=65000, prec=2 }
  },
  wrName = {},
  dL = 45,
  data = {},
  defValues = "Default___ 3000   3510000 3000   3510000 8000   50    0"
}
