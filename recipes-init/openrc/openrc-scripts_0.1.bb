LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = " \
    file://acpid.initd \
    file://avahi-daemon.initd \
    file://bluetooth.initd \
    file://busybox-klogd.initd \
    file://busybox-klogd.confd \
    file://busybox-syslogd.initd \
    file://busybox-syslogd.confd \
    file://connman.initd \
    file://connman.confd \
    file://dbus.initd \
    file://dhcpcd.initd \
    file://sshd.initd \
    file://udev.initd \
    file://wpa_supplicant.initd \
    file://wpa_supplicant.confd \
"

# List of services to install
SERVICES = " \
    acpid \
    avahi-daemon \
    bluetooth \
    busybox-klogd \
    busybox-syslogd \
    connman \
    dbus \
    dhcpcd \
    sshd \
    udev \
    wpa_supplicant \
"

S="${WORKDIR}"

inherit openrc

do_compile() {
    :
}

do_install() {
    local svc

    install -d -m 755 ${D}${OPENRC_INITDIR}
    install -d -m 755 ${D}${OPENRC_CONFDIR}

    for svc in ${SERVICES}; do
        openrc_install_script ${svc}.initd

        if [ -f ${svc}.confd ]; then
            install -m 644 ${svc}.confd ${D}${OPENRC_CONFDIR}/${svc}
        fi
    done

    install -d -m 755 ${D}${sysconfdir}/runlevels/default
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN} = "openrc"

