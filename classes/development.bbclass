# Class for use in BBCLASSEXTEND to make it easier to have a single recipe that
# build and generate packages separately for development and normal images.
#
# Usage:
# BBCLASSEXTEND = "development"

CLASSOVERRIDE .= ":class-development"

python development_virtclass_handler () {
    # Do nothing if this is inherited, as it's for BBCLASSEXTEND
    if "development" not in (d.getVar('BBCLASSEXTEND') or ""):
        bb.error("Don't inherit development, use BBCLASSEXTEND")
        return

    # Restore BPN
    bpn = d.getVar('BPN')
    newbpn = bpn.replace('-development', '')
    d.setVar('BPN', newbpn)

    # Use default FILESPATH searching for patches and files
    filespath = d.getVar('FILESPATH')
    newfilespath = filespath.replace('-development', '')
    d.setVar('FILESPATH', newfilespath)
}

addhandler development_virtclass_handler
development_virtclass_handler[eventmask] = "bb.event.RecipePreFinalise"
