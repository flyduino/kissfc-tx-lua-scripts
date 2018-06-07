
VERSION = 0.11

.PHONY: all
all: clean prepare luatmp lua

.PHONY: luatmp
luatmp:
	cat src/common/KissProtocolSPort.lua src/X9/Kiss.lua src/common/KissUI.lua > X9SP.lua
	cat src/common/KissProtocolSPort.lua src/X7/Kiss.lua src/common/KissUI.lua > X7SP.lua
	cat src/common/KissProtocolSPort.lua src/Horus/Kiss.lua src/common/KissUI.lua > HorusSP.lua
	cat src/common/KissProtocolCF.lua src/X9/Kiss.lua src/common/KissUI.lua > X9CF.lua
	cat src/common/KissProtocolCF.lua src/X7/Kiss.lua src/common/KissUI.lua > X7CF.lua
	cat src/common/KissProtocolCF.lua src/Horus/Kiss.lua src/common/KissUI.lua > HorusCF.lua

.PHONY: clean
clean:
	rm -f *.lua
	rm -rf tmp

.PHONY: prepare
prepare:
	mkdir -p tmp/X9
	mkdir -p tmp/X7
	mkdir -p tmp/Horus

.PHONY: lua
lua:
	cp X9SP.lua tmp/X9/KissSP.lua
	cp X7SP.lua tmp/X7/KissSP.lua
	cp HorusSP.lua tmp/Horus/KissSP.lua
	cp X9CF.lua tmp/X9/KissCF.lua
	cp X7CF.lua tmp/X7/KissCF.lua
	cp HorusCF.lua tmp/Horus/KissCF.lua
	cp -R src/X7/KISS tmp/X7/KISS
	cp -R src/X9/KISS tmp/X9/KISS
	cp -R src/Horus/KISS tmp/Horus/KISS
	find ./tmp/ -type f -name '*.lua' -exec sh -c './node_modules/luamin/bin/luamin --file {} > {}.tmp' \; -exec sh -c 'mv {}.tmp {} ' \;
	
.PHONY: zip
zip: 
	test -d dist || mkdir dist
	cd tmp/X9/; zip -r ../../dist/kiss-x9-lua-scripts-${VERSION}.zip *
	cd tmp/X7/; zip -r ../../dist/kiss-x7-lua-scripts-${VERSION}.zip *
	cd tmp/Horus/; zip -r ../../dist/kiss-horus-lua-scripts-${VERSION}.zip *
	
.PHONY: dist
dist:   clean prepare luatmp lua zip

