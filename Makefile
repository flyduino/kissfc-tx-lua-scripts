
VERSION = 0.12
GIT_HASH = $(shell git log -1 --pretty=format:"%h")

.PHONY: all
all: clean prepare luatmp lua

.PHONY: luatmp
luatmp:
	cat src/common/KissProtocolSPort.lua src/X9/Kiss.lua src/common/KissUI.lua > X9SP.lua
	cat src/common/KissProtocolSPort.lua src/X7/Kiss.lua src/common/KissUI.lua > X7SP.lua
	cat src/common/KissProtocolSPort.lua src/X-Lite/Kiss.lua src/common/KissUI.lua > X-LiteSP.lua
	cat src/common/KissProtocolSPort.lua src/Horus/Kiss.lua src/common/KissUI.lua > HorusSP.lua
	cat src/common/KissProtocolCF.lua src/X9/Kiss.lua src/common/KissUI.lua > X9CF.lua
	cat src/common/KissProtocolCF.lua src/X7/Kiss.lua src/common/KissUI.lua > X7CF.lua
	cat src/common/KissProtocolCF.lua src/X-Lite/Kiss.lua src/common/KissUI.lua > X-LiteCF.lua
	cat src/common/KissProtocolCF.lua src/Horus/Kiss.lua src/common/KissUI.lua > HorusCF.lua


.PHONY: clean
clean:
	rm -f *.lua
	rm -rf tmp
	rm -rf dist
	rm -rf release

.PHONY: prepare
prepare:
	mkdir -p tmp/X9
	mkdir -p tmp/X7
	mkdir -p tmp/Horus
	mkdir -p tmp/X-Lite

.PHONY: lua
lua:
	cp X9SP.lua tmp/X9/KissSP.lua
	cp X7SP.lua tmp/X7/KissSP.lua
	cp X-LiteSP.lua tmp/X-Lite/KissSP.lua
	cp HorusSP.lua tmp/Horus/KissSP.lua

	cp X9CF.lua tmp/X9/KissCF.lua
	cp X7CF.lua tmp/X7/KissCF.lua
	cp X-LiteCF.lua tmp/X-Lite/KissCF.lua
	cp HorusCF.lua tmp/Horus/KissCF.lua

	cp -R src/X7/KISS tmp/X7/KISS
	cp -R src/X7/KISS tmp/X-Lite/KISS
	cp -R src/X9/KISS tmp/X9/KISS
	cp -R src/Horus/KISS tmp/Horus/KISS
	find ./tmp/ -type f -name '*.lua' -exec sh -c './node_modules/luamin/bin/luamin --file {} > {}.tmp' \; -exec sh -c 'mv {}.tmp {} ' \;
	
.PHONY: zip
zip: 
	test -d dist || mkdir dist
	cd tmp/X9/; zip -r ../../dist/kiss-x9-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	cd tmp/X7/; zip -r ../../dist/kiss-x7-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	cd tmp/X-Lite/; zip -r ../../dist/kiss-x_lite-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	cd tmp/Horus/; zip -r ../../dist/kiss-horus-lua-scripts-${VERSION}-${GIT_HASH}.zip *
	
.PHONY: dist
dist:   clean prepare luatmp lua zip

