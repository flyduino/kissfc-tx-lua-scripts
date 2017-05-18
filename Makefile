
VERSION = "0.3"

luatmp = TmpFC.lua TmpX7.lua TmpHorus.lua
lua = KissFC.lua KissX7.lua KissHorus.lua

.PHONY: all
all: clean $(luatmp) $(lua)

TmpFC.lua: 
	cat src/common/KissProtocol.lua src/KissFC.lua src/common/KissUI.lua > TmpFC.lua

TmpX7.lua: 
	cat src/common/KissProtocol.lua src/KissX7.lua src/common/KissUI.lua > TmpX7.lua

TmpHorus.lua: 
	cat src/common/KissProtocol.lua src/KissHorus.lua src/common/KissUI.lua > TmpHorus.lua

.PHONY: clean
clean: 
	rm -f $(lua) $(luatmp)

KissFC.lua:
	./node_modules/luamin/bin/luamin --file TmpFC.lua > KissFC.lua
		
KissX7.lua:
	./node_modules/luamin/bin/luamin --file TmpX7.lua > KissX7.lua

KissHorus.lua:
	./node_modules/luamin/bin/luamin --file TmpHorus.lua > KissHorus.lua

.PHONY: zip
zip: 
	test -d dist || mkdir dist
	zip dist/kiss-lua-scripts-${VERSION}.zip ${lua}

.PHONY: dist
dist:   clean $(luatmp) $(lua) zip

