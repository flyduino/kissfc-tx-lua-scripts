
VERSION = 0.4

.PHONY: all
all: clean prepare luatmp lua

.PHONY: luatmp
luatmp:

	cat src/common/KissProtocolSPort.lua src/common/KissProtocolAdapters.lua src/KissX9.lua src/common/KissUI.lua > TmpX9SP.lua
	cat src/common/KissProtocolSPort.lua src/common/KissProtocolAdapters.lua src/KissX7.lua src/common/KissUI.lua > TmpX7SP.lua
	cat src/common/KissProtocolSPort.lua src/common/KissProtocolAdapters.lua src/KissHorus.lua src/common/KissUI.lua > TmpHorusSP.lua
	cat src/common/KissProtocolCF.lua src/common/KissProtocolAdapters.lua src/KissX9.lua src/common/KissUI.lua > TmpX9CF.lua
	cat src/common/KissProtocolCF.lua src/common/KissProtocolAdapters.lua src/KissX7.lua src/common/KissUI.lua > TmpX7CF.lua
	cat src/common/KissProtocolCF.lua src/common/KissProtocolAdapters.lua src/KissHorus.lua src/common/KissUI.lua > TmpHorusCF.lua

.PHONY: clean
clean:
	rm -f Tmp*.lua
	rm -rf tmp

.PHONY: prepare
prepare:
	mkdir -p tmp/X9
	mkdir -p tmp/X7
	mkdir -p tmp/Horus

.PHONY: lua
lua:
	./node_modules/luamin/bin/luamin --file TmpX9SP.lua > tmp/X9/KissSP.lua
	./node_modules/luamin/bin/luamin --file TmpX7SP.lua > tmp/X7/KissSP.lua
	./node_modules/luamin/bin/luamin --file TmpHorusSP.lua > tmp/Horus/KissSP.lua
	./node_modules/luamin/bin/luamin --file TmpX9CF.lua > tmp/X9/KissCF.lua
	./node_modules/luamin/bin/luamin --file TmpX7CF.lua > tmp/X7/KissCF.lua
	./node_modules/luamin/bin/luamin --file TmpHorusCF.lua > tmp/Horus/KissCF.lua

.PHONY: zip
zip: 
	test -d dist || mkdir dist
	cd tmp; zip -r ../dist/kiss-lua-scripts-${VERSION}.zip *
	
.PHONY: dist
dist:   clean prepare luatmp lua zip

