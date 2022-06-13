install:
	@cp man/haxip.1 /usr/local/man/man1/haxip.1
	@cp src/haxip /usr/local/bin/haxip
	@chmod 775 /usr/local/bin/haxip

uninstall:
	@rm -f /usr/local/bin/haxip
	@rm -f /usr/local/man/man1/haxip.1

.PHONY: install uninstall
