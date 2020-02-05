
VERSION = 1.0.0
GIT_HASH = $(shell git log -1 --pretty=format:"%h")

.PHONY: all
all: clean prepare luatmp lua zip

.PHONY: luatmp
luatmp:
	cat src/common/KissProtocolSPort.lua src/212x64/Kiss.lua src/common/KissUI.lua > tmp/212x64_SPORT.lua
	cat src/common/KissProtocolSPort.lua src/128x64/Kiss.lua src/common/KissUI.lua > tmp/128x64_SPORT.lua
	cat src/common/KissProtocolSPort.lua src/480x272/Kiss.lua src/common/KissUI.lua > tmp/480x272_SPORT.lua
	
	cat src/common/KissProtocolCF.lua src/212x64/Kiss.lua src/common/KissUI.lua > tmp/212x64_CF.lua
	cat src/common/KissProtocolCF.lua src/128x64/Kiss.lua src/common/KissUI.lua > tmp/128x64_CF.lua
	cat src/common/KissProtocolCF.lua src/480x272/Kiss.lua src/common/KissUI.lua > tmp/480x272_CF.lua



.PHONY: clean
clean:
	rm -f *.lua
	rm -rf tmp
	rm -rf dist
	rm -rf release
	rm -rf obj

.PHONY: prepare
prepare:
	mkdir -p obj/212x64/
	mkdir -p obj/128x64/
	mkdir -p obj/480x272/

	mkdir -p tmp/
.PHONY: lua
lua:
	cp tmp/212x64_SPORT.lua obj/212x64/KissSP.lua
	cp tmp/128x64_SPORT.lua obj/128x64/KissSP.lua
	cp tmp/480x272_SPORT.lua obj/480x272/KissSP.lua

	cp tmp/212x64_CF.lua obj/212x64/KissCF.lua
	cp tmp/128x64_CF.lua obj/128x64/KissCF.lua
	cp tmp/480x272_CF.lua obj/480x272/KissCF.lua


	cp -R src/212x64/KISS obj/212x64/KISS
	cp -R src/128x64/KISS obj/128x64/KISS
	cp -R src/480x272/KISS obj/480x272/KISS

.PHONY: luamin
luamin:
	find ./obj/ -type f -name '*.lua' -exec sh -c 'node node_modules/luamin/bin/luamin --file {} > {}.tmp' \; -exec sh -c 'mv {}.tmp {} ' \;
		
.PHONY: zip
zip: 
	test -d dist || mkdir dist
	cd obj/212x64/; zip -r ../../dist/kiss-212x64-lua-scripts-${VERSION}.zip *
	cd obj/128x64/; zip -r ../../dist/kiss-128x64-lua-scripts-${VERSION}.zip *
	cd obj/480x272/; zip -r ../../dist/kiss-480x272-lua-scripts-${VERSION}.zip *
	
.PHONY: dist
dist: clean prepare luatmp lua luamin zip
.PHONY: debug
debug: clean prepare luatmp lua 
