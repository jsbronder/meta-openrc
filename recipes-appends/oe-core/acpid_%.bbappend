FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://acpid.initd file://acpid.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/acpid.initd
    openrc_install_confd ${UNPACKDIR}/acpid.confd
}
