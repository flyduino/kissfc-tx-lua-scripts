return {
      title = " Names",
      text = {
		{ t = "1:", x = 10, y = 13 },
		{ t = "2:", x = 10, y = 23 },
		{ t = "3:", x = 10, y = 33 },
		{ t = "4:", x = 10, y = 43 },
		{ t = "5:", x = 10, y = 53 }
		},
      fields = {
         -- model data
         {t="1",  d="",  x = 20, y = 13, sp = 12, i=1, min=1, max=500 },
         {t="2",  d="",  x = 20, y = 23, sp = 12, i=2, min=1, max=500 },
         {t="3",  d="",  x = 20, y = 33, sp = 12, i=3, min=0, max=600 },
         {t="4",  d="",  x = 20, y = 43, sp = 12, i=4, min=0, max=600 },
		 {t="5",  d="",  x = 20, y = 53, sp = 12, i=5, min=0, max=600 }
      },
      read  = select_model_load,
      write = select_model_save
}
