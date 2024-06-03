FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://cronie.initd file://cronie.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/cronie.initd
    openrc_install_confd ${UNPACKDIR}/cronie.confd
}
