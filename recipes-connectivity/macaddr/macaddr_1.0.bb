SUMMARY = "Utilities for retrieving network addresses"
DESCRIPTION = "Get MAC/IP address of network device"

inherit license-mit

S = "${WORKDIR}/macaddr"

SRC_URI = " \
        file://macaddr/macaddr.c \
        file://macaddr/ipaddr.c \
        file://macaddr/Makefile \
"

EXTRA_OEMAKE = "DESTDIR=${D}${bindir}"

do_install () {
	oe_runmake	install
}

FILES_${PN} = "${bindir}/*"
