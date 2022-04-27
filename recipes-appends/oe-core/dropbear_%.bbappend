FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dropbear.initd file://dropbear.confd"

inherit openrc

do_install:append() {
    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        return
    fi

    install -d ${D}${OPENRC_INITDIR}
    install -m 0755 ${WORKDIR}/dropbear.initd ${D}${OPENRC_INITDIR}/dropbear
    sed -i 's,@SBINDIR@,${sbindir},' ${D}${OPENRC_INITDIR}/dropbear

    install -d ${D}${OPENRC_CONFDIR}
    install -m 0644 ${WORKDIR}/dropbear.confd ${D}${OPENRC_CONFDIR}/dropbear
}
