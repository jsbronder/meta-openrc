FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dbus.initd file://dbus.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/dbus.initd
    openrc_install_confd ${UNPACKDIR}/dbus.confd
}
