FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://neard.initd file://neard.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/neard.initd
    openrc_install_confd ${UNPACKDIR}/neard.confd
}
