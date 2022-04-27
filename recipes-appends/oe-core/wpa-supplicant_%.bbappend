FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://wpa_supplicant.initd file://wpa_supplicant.confd"

inherit openrc

OPENRC_SERVICES = "wpa_supplicant"

do_install:append() {
    openrc_install_initd ${WORKDIR}/wpa_supplicant.initd
    openrc_install_confd ${WORKDIR}/wpa_supplicant.confd
}
