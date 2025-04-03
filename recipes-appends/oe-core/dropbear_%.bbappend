FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dropbear.initd file://dropbear.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/dropbear.initd
    openrc_install_confd ${UNPACKDIR}/dropbear.confd
}
