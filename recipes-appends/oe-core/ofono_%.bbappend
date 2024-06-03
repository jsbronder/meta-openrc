FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://ofono.initd file://ofono.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/ofono.initd
    openrc_install_confd ${UNPACKDIR}/ofono.confd
}
