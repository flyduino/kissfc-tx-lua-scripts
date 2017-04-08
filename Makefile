
VERSION = "0.2"

lua=KissFC.lua KissX7.lua KissHorus.lua

.PHONY: all
all: clean $(lua) 

KissFC.lua: 
	cat src/common/KissProtocol.lua src/KissFC.lua src/common/KissUI.lua > KissFC.lua

KissX7.lua: 
	cat src/common/KissProtocol.lua src/KissX7.lua src/common/KissUI.lua > KissX7.lua

KissHorus.lua: 
	cat src/common/KissProtocol.lua src/KissHorus.lua src/common/KissUI.lua > KissHorus.lua

.PHONY: clean
clean: 
	rm -f $(lua)

.PHONY: zip
zip: 
	test -d dist || mkdir dist
	zip dist/kiss-lua-scripts-${VERSION}.zip ${lua}

.PHONY: dist
dist:   clean ${lua} zip

