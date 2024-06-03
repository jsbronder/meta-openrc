FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://connman.initd file://connman.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/connman.initd
    openrc_install_confd ${UNPACKDIR}/connman.confd
}
