FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://lighttpd.initd file://lighttpd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/lighttpd.initd
    openrc_install_confd ${UNPACKDIR}/lighttpd.confd
}
