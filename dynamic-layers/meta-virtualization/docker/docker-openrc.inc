FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://docker.initd \
    file://docker.confd \
"

inherit openrc

OPENRC_SERVICES = "docker"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/docker.initd
    openrc_install_confd ${UNPACKDIR}/docker.confd
}
