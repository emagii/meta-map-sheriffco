SUMMARY = ""
DESCRIPTION = ""

inherit license-mit

SRC_URI = " \
	file://class/class-recipe.c \
	file://class/Makefile \
"

EXTRA_OEMAKE_class-development = 'CFLAGS="${CFLAGS} -DDEVELOPMENT"'
EXTRA_OEMAKE_class-production  = 'CFLAGS="${CFLAGS} -DPRODUCTION"'
EXTRA_OEMAKE_class-release     = 'CFLAGS="${CFLAGS} -DRELEASE"'

do_install-class-development () {
	install	-d	${D}${bindir}
	install	-m 0755	class	${D}${bindir}/development
}

do_install-class-production () {
	install	-d	${D}${bindir}
	install	-m 0755	class	${D}${bindir}/production
}

do_install-class-release () {
	install	-d	${D}${bindir}
	install	-m 0755	class	${D}${bindir}/release
}

BBCLASSEXTEND = "development production release"
