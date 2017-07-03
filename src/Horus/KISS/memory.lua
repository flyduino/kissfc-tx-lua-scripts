return {
      title = " Names",
      text = {
		{ t = "1:", x = 40, y = 43 },
		{ t = "2:", x = 40, y = 63 },
		{ t = "3:", x = 40, y = 83 },
		{ t = "4:", x = 40, y = 103 },
		{ t = "5:", x = 40, y = 123 }
		},
      fields = {
         -- model data
         {t="1",  d="",  x = 60, y = 43, sp = 12, i=1, min=1, max=500 },
         {t="2",  d="",  x = 60, y = 63, sp = 12, i=2, min=1, max=500 },
         {t="3",  d="",  x = 60, y = 83, sp = 12, i=3, min=0, max=600 },
         {t="4",  d="",  x = 60, y = 103, sp = 12, i=4, min=0, max=600 },
		 {t="5",  d="",  x = 60, y = 123, sp = 12, i=5, min=0, max=600 }
      },
      read  = select_model_load,
      write = select_model_save
}
