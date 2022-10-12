FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://mosquitto.initd \
    file://mosquitto.confd \
"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/mosquitto.initd
    openrc_install_confd ${WORKDIR}/mosquitto.confd
}
