FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://bootchart2.initd"

inherit openrc

OPENRC_PACKAGES = "bootchartd-stop-initscript"
OPENRC_SERVICES:bootchartd-stop-initscript = "bootchart2"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/bootchart2.initd
}
