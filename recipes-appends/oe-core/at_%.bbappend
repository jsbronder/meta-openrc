FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://atd.initd file://atd.confd"

inherit openrc

OPENRC_SERVICES:${PN} = "atd"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/atd.initd
    openrc_install_confd ${UNPACKDIR}/atd.confd
}
