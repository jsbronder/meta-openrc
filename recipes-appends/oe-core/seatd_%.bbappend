FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://seatd.initd file://seatd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/seatd.initd
    openrc_install_confd ${UNPACKDIR}/seatd.confd
}
