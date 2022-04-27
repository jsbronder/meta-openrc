FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dbus.initd file://dbus.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/dbus.initd
    openrc_install_confd ${WORKDIR}/dbus.confd
}
