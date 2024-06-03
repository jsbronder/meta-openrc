FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://rpcbind.initd file://rpcbind.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/rpcbind.initd
    openrc_install_confd ${UNPACKDIR}/rpcbind.confd
}
