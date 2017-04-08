
VERSION = "0.2"

lua = KissFC.lua KissX7.lua KissHorus.lua
luac = KissFC.luac KissX7.luac KissHorus.luac

.PHONY: all
all: clean $(lua) $(luac)

KissFC.lua: 
	cat src/common/KissProtocol.lua src/KissFC.lua src/common/KissUI.lua > KissFC.lua

KissX7.lua: 
	cat src/common/KissProtocol.lua src/KissX7.lua src/common/KissUI.lua > KissX7.lua

KissHorus.lua: 
	cat src/common/KissProtocol.lua src/KissHorus.lua src/common/KissUI.lua > KissHorus.lua

.PHONY: clean
clean: 
	rm -f $(lua) $(luac)

KissFC.luac:
	luac -s -o KissFC.luac KissFC.lua 
	
KissX7.luac:
	luac -s -o KissX7.luac KissX7.lua 
	
KissHorus.luac:
	luac -s -o KissHorus.luac KissHorus.lua 

.PHONY: zip
zip: 
	test -d dist || mkdir dist
	zip dist/kiss-lua-scripts-${VERSION}.zip ${lua} ${luac}

.PHONY: dist
dist:   clean $(lua) $(luac) zip

