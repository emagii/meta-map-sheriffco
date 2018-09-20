DESTDIR ?= /usr/bin

MACADDR = macaddr
IPADDR = ipaddr

all:	$(MACADDR) $(IPADDR)

$(MACADDR):	$(MACADDR).c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

$(IPADDR):	$(IPADDR).c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

install: $(DESTDIR)/$(MACADDR) $(DESTDIR)/$(IPADDR)

$(DESTDIR)/$(MACADDR):	$(MACADDR)
	mkdir	-p	$(DESTDIR)
	install	-m 0755 $(MACADDR)	$@

$(DESTDIR)/$(IPADDR):	$(IPADDR)
	mkdir	-p	$(DESTDIR)
	install	-m 0755 $(IPADDR)	$@

clean:
	rm -f	$(MACADDR)
	rm -f	$(IPADDR)
