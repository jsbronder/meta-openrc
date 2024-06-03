FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://rngd.initd file://rngd.confd"

inherit openrc

OPENRC_SERVICES = "rngd"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/rngd.initd
    openrc_install_confd ${UNPACKDIR}/rngd.confd
}
