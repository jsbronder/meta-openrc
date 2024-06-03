FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://mosquitto.initd \
    file://mosquitto.confd \
"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/mosquitto.initd
    openrc_install_confd ${UNPACKDIR}/mosquitto.confd
}
