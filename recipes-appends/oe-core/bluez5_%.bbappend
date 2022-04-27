FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://bluetooth.initd file://bluetooth.confd"

inherit openrc

OPENRC_SERVICES = "bluetooth"

do_install:append() {
    openrc_install_initd ${WORKDIR}/bluetooth.initd
    openrc_install_confd ${WORKDIR}/bluetooth.confd
}
