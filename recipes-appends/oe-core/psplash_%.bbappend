FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://psplash.initd file://psplash.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/psplash.initd
    openrc_install_confd ${UNPACKDIR}/psplash.confd
}
