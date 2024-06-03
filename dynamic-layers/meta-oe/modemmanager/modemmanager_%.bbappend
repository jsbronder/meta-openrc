FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://modemmanager.initd \
    file://modemmanager.confd \
"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/modemmanager.initd
    openrc_install_confd ${UNPACKDIR}/modemmanager.confd
}
