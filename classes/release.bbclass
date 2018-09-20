# Class for use in BBCLASSEXTEND to make it easier to have a single recipe that
# build and generate packages separately for release and normal images.
#
# Usage:
# BBCLASSEXTEND = "release"

CLASSOVERRIDE .= ":class-release"

python release_virtclass_handler () {
    # Do nothing if this is inherited, as it's for BBCLASSEXTEND
    if "release" not in (d.getVar('BBCLASSEXTEND') or ""):
        bb.error("Don't inherit release, use BBCLASSEXTEND")
        return

    # Restore BPN
    bpn = d.getVar('BPN')
    newbpn = bpn.replace('-release', '')
    d.setVar('BPN', newbpn)

    # Use default FILESPATH searching for patches and files
    filespath = d.getVar('FILESPATH')
    newfilespath = filespath.replace('-release', '')
    d.setVar('FILESPATH', newfilespath)
}

addhandler release_virtclass_handler
release_virtclass_handler[eventmask] = "bb.event.RecipePreFinalise"
