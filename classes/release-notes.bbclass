RELEASE_NOTES_DIRECTORY = "${DEPLOY_DIR}/release-notes"
MACHINE_DIR = "${DEPLOY_DIR}/images/${MACHINE}"
RELEASE_NOTES_TEX_DIRECTORY = "${MACHINE_DIR}/release-notes"
RELEASE_NOTES_LIST = "${RELEASE_NOTES_TEX_DIRECTORY}/release-notes"

# Creates the following files:
# description.tex	SUMMARY = DESCRIPTION

python create_package_descriptions() {
    import oe.packagedata
    import shutil
    from oe.rootfs import image_list_installed_packages

    create_release_notes = d.getVar('RELEASE_NOTES')
    if not create_release_notes == "1":
        return 0

    pkg_dic = {}
    for pkg in sorted(image_list_installed_packages(d)):
        pkg_info = os.path.join(d.getVar('PKGDATA_DIR'),
                                'runtime-reverse', pkg)
        pkg_name = os.path.basename(os.readlink(pkg_info))

        pkg_dic[pkg_name] = oe.packagedata.read_pkgdatafile(pkg_info)

        release_notes_dir = os.path.join(d.getVar('RELEASE_NOTES_TEX_DIRECTORY'), pkg)
        bb.utils.mkdirhier(release_notes_dir)

        package_description_file = os.path.join(release_notes_dir, 'description.tex')

        with open(package_description_file, "w") as description_file:

            if "SUMMARY" in pkg_dic[pkg_name].keys():
                soutput = pkg_dic[pkg_name]["SUMMARY"]
            else:
                soutput = ""
            description_file.write("SUMMARY: %s\n\n" % soutput)

            if "DESCRIPTION" in pkg_dic[pkg_name].keys():
                doutput = pkg_dic[pkg_name]["DESCRIPTION"]
            else:
                doutput = ""

            if not doutput == soutput:
                description_file.write("DESCRIPTION: %s\n\n" % doutput)
            description_file.close()
}


# Creates the following files
# ${DEPLOY_DIR}/images/${MACHINE}/release-notes/release-notes	list of packages
# <package>/header.tex
# <package>/package.tex
# <package>/license.tex
# <package>/cve.tex
# <package>/
# <package>/
# <package>/

release_notes () {
	if [ -z "${RELEASE_NOTES}" ] ; then
		return 0
	fi
	INSTALLED_PKGS=$(cat ${LICENSE_DIRECTORY}/${IMAGE_NAME}/package.manifest)
	rm -fr		${RELEASE_NOTES_TEX_DIRECTORY}
	mkdir	-p	${RELEASE_NOTES_TEX_DIRECTORY}
	for pkg in ${INSTALLED_PKGS}; do
		filename=`ls ${PKGDATA_DIR}/runtime-reverse/${pkg}| head -1`
		pkged_pn="$(sed -n 's/^PN: //p' ${filename})"
		pkged_pv="$(sed -n 's/^PV: //p' ${filename})"

		TEX_DIR=${RELEASE_NOTES_TEX_DIRECTORY}/${pkged_pn}
		TEX_FILE=${TEX_DIR}/${pkged_pn}.tex
		mkdir	-p	"${TEX_DIR}"
		# Add package name and version first
		if ! [ -f ${TEX_FILE} ] ; then
			echo	"${pkged_pn}" 						>> ${RELEASE_NOTES_LIST}.dat

			printf	"\\section{%s}\n" "${pkged_pn}"				>  ${TEX_DIR}/header.tex
			printf	"\n"							>> ${TEX_DIR}/header.tex

			touch								   ${TEX_FILE}

			printf	"\\"							>  ${TEX_DIR}/package.tex
			printf	"begin{itemize}\n"					>> ${TEX_DIR}/package.tex
			printf	"\n"							>> ${TEX_DIR}/package.tex
			printf	"\\item %-20s%s\n" "Version:" "${pkged_pn}-${pkged_pv}"	>> ${TEX_DIR}/package.tex
			printf	"\n"							>> ${TEX_DIR}/package.tex
			printf	"\\"							>> ${TEX_DIR}/package.tex
			printf	"end{itemize}\n"					>> ${TEX_DIR}/package.tex
			printf	"\n"							>> ${TEX_DIR}/package.tex

			echo	"${pkged_pv}"						>  ${TEX_DIR}/version.dat

			printf	"\\"							>  ${TEX_DIR}/license.tex
			printf	"begin{itemize}\n"					>> ${TEX_DIR}/license.tex
			printf	"\n"							>> ${TEX_DIR}/license.tex

			licenses=false
			PACKAGE_LICENSE_DIRECTORY="${LICENSE_DIRECTORY}/${pkged_pn}"
			if [ -d ${PACKAGE_LICENSE_DIRECTORY} ] ; then
				LICENSE_LIST=$(cd ${PACKAGE_LICENSE_DIRECTORY} ; ls generic_* 2>/dev/null | sed -e 's/generic_//g' -e 's/^[ \t]*//g')
				if ! [ -z "${LICENSE_LIST}" ] ; then
					for lic in $LICENSE_LIST ; do
						lic=$(echo $lic | sed -e 's/Firmware-//g')
						printf	"\\item %-20s%s\n" "License: " "${lic}"	\
											>> ${TEX_DIR}/license.tex
						printf	"\n"				>> ${TEX_DIR}/license.tex
					done
					licenses=true
				fi
			fi

			if ! ${licenses} ; then
						printf	"\\item %-20s%s\n" "License: " "UNAVAILABLE"	\
											>> ${TEX_DIR}/license.tex
						printf	"\n"				>> ${TEX_DIR}/license.tex
			fi

			printf	"\\"							>> ${TEX_DIR}/license.tex
			printf	"end{itemize}\n"					>> ${TEX_DIR}/license.tex
			printf	"\n"							>> ${TEX_DIR}/license.tex

			if [ -f ${DEPLOY_DIR}/cve/${pkged_pn} ] ; then
				cp	${DEPLOY_DIR}/cve/${pkged_pn}			${TEX_DIR}/cve.tex
			fi

			sed	-i	's/_/-/g'					${TEX_DIR}/*.tex


			# Don't add release-notes if none present
			if [ -z "$(ls -A ${RELEASE_NOTES_DIRECTORY}/${pkged_pn}/release-note-* 2>/dev/null)" ]; then
				continue
			fi

			# Loop to add all release notes for the specific package
			RN_FILES=$(ls ${RELEASE_NOTES_DIRECTORY}/${pkged_pn}/release-notes-*.tex)
			for rn in "${RN_FILES}" ; do
				cp	${rn}						${TEX_DIR}/
			done
			sed	-i	's/_/-/g'					${TEX_DIR}/*.tex
		fi
	done
	printf	"%s\n"	"export	RELEASE_PACKAGES=\" \\"				> ${RELEASE_NOTES_LIST}
	for pkg in $(cat ${RELEASE_NOTES_LIST}.dat | sort | uniq) ; do
			printf "\t\t%s\n"	"${pkg} \\" 			>> ${RELEASE_NOTES_LIST}
	done
	printf	"\"\n"	>>	${RELEASE_NOTES_LIST}
	chmod	a+x		${RELEASE_NOTES_LIST}
	rm -f			${RELEASE_NOTES_LIST}.dat
}

release_notes_artifacts () {
	tar	-zcf	${MACHINE_DIR}/release-notes-${PFM_VERSION}.tar.gz	-C ${DEPLOY_DIR}/images/${MACHINE} release-notes
}
