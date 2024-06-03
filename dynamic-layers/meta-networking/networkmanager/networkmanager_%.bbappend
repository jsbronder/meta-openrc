FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://networkmanager.initd \
"

LICENSE += "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', '& GPL-2.0-only', '', d)}"

inherit openrc

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/networkmanager.initd
}
