	return { 
		read = 0x43, 
		write = 0x44,
		postRead = function(page)
   						local pids = {}
   						for i=0,2 do
   	 						pids[i*3+1] = bit32.lshift(page.values[i*6+1], 8) + page.values[i*6+2]
  	 						pids[i*3+2] = bit32.lshift(page.values[i*6+3], 8) + page.values[i*6+4]
     						pids[i*3+3] = bit32.lshift(page.values[i*6+5], 8) + page.values[i*6+6]
   						end
   						return pids
					end,
		getWriteValues = function(values)
   						local ret = {}
   						local tmp
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
         	{ t = "P", x = 60,  y = 14 },
         	{ t = "I", x = 120, y = 14 },
         	{ t = "D", x = 175, y = 14 },
         	{ t = "Roll",  x = 10,  y = 25 },
         	{ t = "Pitch", x = 10,  y = 38 },
         	{ t = "Yaw",   x = 10,  y = 50 }
     	},
      	fields = {
         	{ x = 35,  y = 25, i=1, max=65000, prec=2 },
        	{ x = 90,  y = 25, i=2, max=65000, prec=3 },
         	{ x = 145, y = 25, i=3, max=65000, prec=2 },
         	{ x = 35,  y = 38, i=4, max=65000, prec=2 },
         	{ x = 90,  y = 38, i=5, max=65000, prec=3 },
         	{ x = 145, y = 38, i=6, max=65000, prec=2 },
         	{ x = 35,  y = 50, i=7, max=65000, prec=2 },
         	{ x = 90,  y = 50, i=8, max=65000, prec=3 },
         	{ x = 145, y = 50, i=9, max=65000, prec=2 }
      	}
   }
