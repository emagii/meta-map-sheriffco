FILESEXTRAPATHS:prepend := "${YOCTO_COMPONENT_PATH}/${SRC_REPO}:${YOCTO_COMPONENT_PATH}/misc/${SRC_REPO}:"

SRC_URI = "file://.;subdir=${SRC_SUBDIR}"

SRC_REPO ?= "${BPN}"
SRC_SUBDIR ?= "${BP}"
S = "${WORKDIR}/${BP}"
B = "${S}"

# List of files that should be excluded from the unpacked source
# directory, the file paths must be relative to ${S}.
EXCLUDE_FROM_SOURCE = " \
    .pc \
    .config \
"

do_unpack[cleandirs] += "${S}"
do_unpack[postfuncs] += "remove_excluded_files"
do_unpack[vardepsexclude] += "remove_excluded_files"

remove_excluded_files() {
    for file in $(echo -n "${EXCLUDE_FROM_SOURCE}" | awk -v RS=" " '{print $0}'); do
        if [ -e "${S}/$file" ]; then
            rm -rf ${S}/$file
        fi
    done
}

# Skip processing of this recipe if the component folder does not exist or is empty.
# This ensures the potential issues are detected at parsing time, to avoid running out
# to some strange errors at build time, which could be very difficult to debug.
python validate_component_url_handler () {
    import os
    import bb.event

    if not e.data:
        return

    # We need invalidate SRCPV here, or else if SRCPV is set into PV in some places, which
    # usually happens in git/svn/hg recipes, then bitbake will try to expand it by fetching
    # AUTOINC from remote repositories, which is done in bb.fetch2.get_srcrev() function, but
    # since bitbake python variable expanding syntax does not support recursive functions, it
    # will lead to:
    # FILESPATH = "${@base_set_filespath(["${FILE_DIRNAME}/${BP}", "${FILE_DIRNAME}/${BPN}", "${FILE_DIRNAME}/files"], d)}"
    # not to be expanded because BP is set to:
    # BP = "${BPN}-${PV}"
    # and that would lead bb.fetch2.get_srcrev() to be recursively called.
    e.data.setVar("SRCPV", "Invalid")

    # Get the existing files from the checksum file list.
    filelist = []
    for url in bb.fetch.get_checksum_file_list(e.data).split():
        if url.startswith("/"):
            exist = url.split(":")[1]
            if exist == "False":
                continue
            filelist.append(url.split(":")[0])

    bb.debug(2, "Validating %s urls: %s" % (e.data.getVar('PN'), filelist))

    valid = False
    yocto_component_dir = e.data.getVar('YOCTO_COMPONENT_PATH')
    for file in filelist:
        if file.startswith(yocto_component_dir):
            if os.path.isdir(file) and os.listdir(file):
                valid = True
                break
    if not valid:
        bb.fatal("Can't find the component folder!\n"
                 "Please make sure %s exists in %s or %s/misc and is not empty.\n"
                 "Or you need set SRC_REPO correctly."
                 % (e.data.getVar('SRC_REPO'), yocto_component_dir))
}

addhandler validate_component_url_handler
validate_component_url_handler[eventmask] = "bb.event.RecipeParsed"
