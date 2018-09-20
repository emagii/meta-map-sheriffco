# Class for use in BBCLASSEXTEND to make it easier to have a single recipe that
# build and generate packages separately for debug and normal images.
#
# Usage:
# BBCLASSEXTEND = "debug"

CLASSOVERRIDE .= ":class-debug"

python debug_virtclass_handler () {
    # Do nothing if this is inherited, as it's for BBCLASSEXTEND
    if "debug" not in (d.getVar('BBCLASSEXTEND') or ""):
        bb.error("Don't inherit debug, use BBCLASSEXTEND")
        return

    # Restore BPN
    bpn = d.getVar('BPN')
    newbpn = bpn.replace('-debug', '')
    d.setVar('BPN', newbpn)

    # Use default FILESPATH searching for patches and files
    filespath = d.getVar('FILESPATH')
    newfilespath = filespath.replace('-debug', '')
    d.setVar('FILESPATH', newfilespath)
}

addhandler debug_virtclass_handler
debug_virtclass_handler[eventmask] = "bb.event.RecipePreFinalise"
