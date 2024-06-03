FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://sysklogd.initd file://sysklogd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/sysklogd.initd
    openrc_install_confd ${UNPACKDIR}/sysklogd.confd
}
