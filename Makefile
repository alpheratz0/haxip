.POSIX:
.PHONY: install uninstall default

PREFIX    = /usr/local
MANPREFIX = $(PREFIX)/share/man

default:
	@true

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f haxip $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/haxip
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f haxip.1 $(DESTDIR)$(MANPREFIX)/man1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/haxip.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/haxip
	rm -f $(DESTDIR)$(MANPREFIX)/man1/haxip.1
