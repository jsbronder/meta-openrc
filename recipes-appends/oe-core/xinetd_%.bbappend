FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://xinetd.initd file://xinetd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/xinetd.initd
    openrc_install_confd ${UNPACKDIR}/xinetd.confd
}
