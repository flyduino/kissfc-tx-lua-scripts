	return { 
		read  = 0x49, 
		write = 0x4A,
		
		postRead = function(page)
   			local alarms = {}
   			alarms[1] = 100 * (bit32.lshift(page.values[1], 8) + page.values[2])
   			alarms[2] = bit32.lshift(page.values[3], 8) + page.values[4]
  	 		return alarms
		end,

		getWriteValues = function(values)
   			local ret = {}
   			local tmp = bit32.band(math.floor(values[1]/100), 0xFFFF)
   			ret[1] = bit32.band(bit32.rshift(tmp, 8), 0xFF)
   			ret[2] = bit32.band(tmp, 0xFF)
   			ret[3] = bit32.band(bit32.rshift(values[2], 8), 0xFF)
   			ret[4] = bit32.band(values[2], 0xFF)
   			return ret
		end,

      	title = "Alarms",
      	text = {},
      	fields = {
         	{ t = "VBat",    x = 15,  y = 25, sp = 30, i=1, min=0, max=26000, prec=1 },
         	{ t = "mAH",     x = 120, y = 25, sp = 30, i=2, min=0, max=26000, inc=10 }
      	}
   }
