	return { 
		read  = 0x45, 
		write = 0x46,
		
		postRead = function(page)
  			local vtx = {}
   			vtx[1] = page.values[1]
   			vtx[2] = 1 + bit32.rshift(page.values[2], 3)
   			vtx[3] = 1 + bit32.band(page.values[2], 0x07)
   			vtx[4] = bit32.lshift(page.values[3], 8) + page.values[4]
   			vtx[5] = bit32.lshift(page.values[5], 8) + page.values[6]
   			return vtx
		end,

		getWriteValues = function(values)
   			local ret = {}
   			ret[1] = bit32.band(values[1], 0xFF)
  			ret[2] = bit32.band((values[2]-1) * 8 + values[3]-1, 0xFF)
   			ret[3] = bit32.band(bit32.rshift(values[4], 8), 0xFF)
   			ret[4] = bit32.band(values[4], 0xFF)
   			ret[5] = bit32.band(bit32.rshift(values[5], 8), 0xFF)
  			ret[6] = bit32.band(values[5], 0xFF)
   			return ret
		end,

		title = "VTX",
      	text = {},
      	fields = {
         	{ t = "Band",    	   x = 15,  y = 25, sp = 60, i=2, min=1, max=5, table = { "A", "B", "E", "FS", "RB" } },
         	{ t = "Channel",      x = 110, y = 25, sp = 70, i=3, min=1, max=8 },
         	{ t = "Low Power",    x = 15,  y = 38, sp = 60, i=4, min=0, max=600 },
         	{ t = "High Power",   x = 110, y = 38, sp = 70, i=5, min=0, max=600 }
      	}
   }
