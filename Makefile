install:
	@sudo chmod 775 haxip
	@sudo cp haxip /usr/local/bin/haxip

uninstall:
	@sudo rm -f /usr/local/bin/haxip

.PHONY: install uninstall
