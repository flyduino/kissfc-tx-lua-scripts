return {
  read  = 0x4B,
  write = 0x4C,
  
  postRead = function(values)
    local ret = {}
    for i=1,3 do
      ret[i] = bit32.lshift(values[(i-1)*2 + 1], 8) + values[(i-1)*2 + 2]
    end
    ret[4] = values[7] + 1
    for i=5,10 do
      ret[i] = values[i + 3]
    end
	return ret
  end,
  preWrite = function(values)
    local ret = {}
    for i=1,3 do
      ret[(i-1)*2 + 1] = bit32.rshift(values[i], 8)
      ret[(i-1)*2 + 2] = bit32.band(values[i], 0xFF)
    end
    ret[7] = bit32.band(values[4]-1, 0xFF)
    for i=5,10 do
      ret[i+3] = bit32.band(values[i], 0xFF)
    end
    return ret
  end,
  title = "TPA",
  text = {
	{ t = "P",     x = 45, y = 10 },
	{ t = "I",     x = 78, y = 10 },
	{ t = "D",     x = 107,y = 10 },
	{ t = "TPA",   x = 3,  y = 20 },
	{ t = "0",     x = 35, y = 43 },
	{ t = "100",   x = 105,y = 43 },
	{ t = "Thr%",  x = 3,  y = 43 },
	{ t = "Inf%",  x = 3,  y = 53 },
  },
  lines = {
    { x1 = 1, y1 = 30, x2 = 125, y2 = 30 }
  },
  fields = {
    -- TPA
    { x = 20,  y = 20, i=1, max=900, prec=2 },
    { x = 53,  y = 20, i=2, max=900, prec=2 },
    { x = 80,  y = 20, i=3, max=900, prec=2 },
    { t = "Custom TPA", x = 3,  y = 33, sp=65, i=4, min=1, max=2, table = { "Off", "On" } },
    { x = 38,  y = 43, i=5, max=100},
    { x = 61,  y = 43, i=6, max=100},
    { x = 15,  y = 53, i=7, max=100},
    { x = 38,  y = 53, i=8, max=100},
    { x = 61,  y = 53, i=9, max=100},
    { x = 85,  y = 53, i=10,max=100},
  },
  wrName = {},
  dL = 50,
  data = {},
  defValues = "Default___   40   20   40    1   30   50   30    0    0  100"
}
