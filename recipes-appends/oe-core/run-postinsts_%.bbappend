FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://run-postinsts.initd"

inherit openrc

do_install:append() {
    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        return
    fi

    sed -i \
        -e 's,which update-rc.d,which rc-update,' \
        -e 's,update-rc.d -f run-postinsts remove,rc-update del run-postinsts boot,' \
        ${D}${sbindir}/run-postinsts

    openrc_install_initd ${UNPACKDIR}/run-postinsts.initd
    install -d ${D}${sysconfdir}/runlevels/boot
    ln -snf ${OPENRC_INITDIR}/run-postinsts ${D}${sysconfdir}/runlevels/boot
}
