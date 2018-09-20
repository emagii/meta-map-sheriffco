# Class for use in BBCLASSEXTEND to make it easier to have a single recipe that
# build and generate packages separately for production and normal images.
#
# Usage:
# BBCLASSEXTEND = "production"

CLASSOVERRIDE .= ":class-production"

python production_virtclass_handler () {
    # Do nothing if this is inherited, as it's for BBCLASSEXTEND
    if "production" not in (d.getVar('BBCLASSEXTEND') or ""):
        bb.error("Don't inherit production, use BBCLASSEXTEND")
        return

    # Restore BPN
    bpn = d.getVar('BPN')
    newbpn = bpn.replace('-production', '')
    d.setVar('BPN', newbpn)

    # Use default FILESPATH searching for patches and files
    filespath = d.getVar('FILESPATH')
    newfilespath = filespath.replace('-production', '')
    d.setVar('FILESPATH', newfilespath)
}

addhandler production_virtclass_handler
production_virtclass_handler[eventmask] = "bb.event.RecipePreFinalise"
