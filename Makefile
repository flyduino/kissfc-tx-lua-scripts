
VERSION = `git describe --tags --long`

lua=KissFC.lua KissX7.lua KissHorus.lua

.PHONY: all
all: $(lua) 

KissFC.lua: 
	@cat src/common/KissProtocol.lua src/KissFC.lua src/common/KissUI.lua > KissFC.lua

KissX7.lua: 
	@cat src/common/KissProtocol.lua src/KissX7.lua src/common/KissUI.lua > KissX7.lua

KissHorus.lua: 
	@cat src/common/KissProtocol.lua src/KissHorus.lua src/common/KissUI.lua > KissHorus.lua

.PHONY: clean
clean: 
	rm -f $(lua)
