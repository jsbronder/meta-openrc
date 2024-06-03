FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dhcpcd.initd file://dhcpcd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/dhcpcd.initd
    openrc_install_confd ${UNPACKDIR}/dhcpcd.confd
}
