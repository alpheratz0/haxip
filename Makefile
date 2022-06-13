install:
	@cp haxip /usr/local/bin/haxip
	@chmod 775 /usr/local/bin/haxip

uninstall:
	@rm -f /usr/local/bin/haxip

.PHONY: install uninstall
