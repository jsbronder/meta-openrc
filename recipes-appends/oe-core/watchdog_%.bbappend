FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://watchdog.initd file://watchdog.confd file://wd_keepalive.initd file://wd_keepalive.confd"

inherit openrc

OPENRC_PACKAGES = "${PN} ${PN}-keepalive"
OPENRC_SERVICES:${PN}-keepalive = "wd_keepalive"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/watchdog.initd
    openrc_install_confd ${UNPACKDIR}/watchdog.confd
    openrc_install_initd ${UNPACKDIR}/wd_keepalive.initd
    openrc_install_confd ${UNPACKDIR}/wd_keepalive.confd
}
