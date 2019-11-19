
VERSION = 0.14
GIT_HASH = $(shell git log -1 --pretty=format:"%h")

.PHONY: all
all: clean prepare luatmp lua zip

.PHONY: luatmp
luatmp:
	cat src/common/KissProtocolSPort.lua src/X9/Kiss.lua src/common/KissUI.lua > tmp/X9SP.lua
	cat src/common/KissProtocolSPort.lua src/X7/Kiss.lua src/common/KissUI.lua > tmp/X7SP.lua
	cat src/common/KissProtocolSPort.lua src/X-Lite/Kiss.lua src/common/KissUI.lua > tmp/X-LiteSP.lua
	cat src/common/KissProtocolSPort.lua src/Horus/Kiss.lua src/common/KissUI.lua > tmp/HorusSP.lua
	cat src/common/KissProtocolCF.lua src/X9/Kiss.lua src/common/KissUI.lua > tmp/X9CF.lua
	cat src/common/KissProtocolCF.lua src/X7/Kiss.lua src/common/KissUI.lua > tmp/X7CF.lua
	cat src/common/KissProtocolCF.lua src/X-Lite/Kiss.lua src/common/KissUI.lua > tmp/X-LiteCF.lua
	cat src/common/KissProtocolCF.lua src/Horus/Kiss.lua src/common/KissUI.lua > tmp/HorusCF.lua



.PHONY: clean
clean:
	rm -f *.lua
	rm -rf tmp
	rm -rf dist
	rm -rf release
	rm -rf obj

.PHONY: prepare
prepare:
	mkdir -p obj/X9/
	mkdir -p obj/X7/
	mkdir -p obj/Horus/
	mkdir -p obj/X-Lite/

	mkdir -p tmp/
.PHONY: lua
lua:
	cp tmp/X9SP.lua obj/X9/KissSP.lua
	cp tmp/X7SP.lua obj/X7/KissSP.lua
	cp tmp/X-LiteSP.lua obj/X-Lite/KissSP.lua
	cp tmp/HorusSP.lua obj/Horus/KissSP.lua


	cp tmp/X9CF.lua obj/X9/KissCF.lua
	cp tmp/X7CF.lua obj/X7/KissCF.lua
	cp tmp/X-LiteCF.lua obj/KissCF.lua
	cp tmp/HorusCF.lua obj/Horus/KissCF.lua


	cp -R src/X7/KISS obj/X7/KISS
	cp -R src/X7/KISS obj/X-Lite/KISS
	cp -R src/X9/KISS obj/X9/KISS
	cp -R src/Horus/KISS obj/Horus/KISS

	find ./obj/ -type f -name '*.lua' -exec sh -c 'node node_modules/luamin/bin/luamin --file {} > {}.tmp' \; -exec sh -c 'mv {}.tmp {} ' \;
		
.PHONY: zip
zip: 
	test -d dist || mkdir dist
	cd obj/X9/; zip -r ../../dist/kiss-x9-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	cd obj/X7/; zip -r ../../dist/kiss-x7-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	cd obj/X-Lite/; zip -r ../../dist/kiss-x_lite-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	cd obj/Horus/; zip -r ../../dist/kiss-horus-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	
.PHONY: dist
dist:   clean prepare luatmp lua zip

