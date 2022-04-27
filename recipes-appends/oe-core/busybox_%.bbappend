FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://busybox-klogd.confd \
    file://busybox-klogd.initd \
    file://busybox-syslogd.confd \
    file://busybox-syslogd.initd \
"

inherit openrc

OPENRC_PACKAGES = "busybox busybox-syslog"
OPENRC_SERVICES = "busybox-klogd"
OPENRC_SERVICES:${PN}-syslog = "busybox-syslogd"

do_install:append() {
    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        return
    fi

    local svc
    for svc in klogd syslogd; do
        openrc_install_initd ${WORKDIR}/busybox-${svc}.initd
        openrc_install_confd ${WORKDIR}/busybox-${svc}.confd
    done
}
