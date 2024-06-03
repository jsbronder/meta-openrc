FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://kea-dhcp4.initd \
    file://kea-dhcp4.confd \
    file://kea-dhcp6.initd \
    file://kea-dhcp6.confd \
    file://kea-dhcp-ddns.initd \
    file://kea-dhcp-ddns.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "kea-dhcp4 kea-dhcp6 kea-dhcp-ddns"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/kea-dhcp4.initd
    openrc_install_confd ${UNPACKDIR}/kea-dhcp4.confd
    openrc_install_initd ${UNPACKDIR}/kea-dhcp6.initd
    openrc_install_confd ${UNPACKDIR}/kea-dhcp6.confd
    openrc_install_initd ${UNPACKDIR}/kea-dhcp-ddns.initd
    openrc_install_confd ${UNPACKDIR}/kea-dhcp-ddns.confd
}
